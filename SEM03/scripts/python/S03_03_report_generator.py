#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
╔══════════════════════════════════════════════════════════════════════════════╗
║              GENERATOR DE RAPOARTE - SEMINAR 5-6                              ║
║              Sisteme de Operare | ASE București - CSIE                        ║
╠══════════════════════════════════════════════════════════════════════════════╣
║  Generează rapoarte de progres bazate pe:                                     ║
║  • Rezultate quiz-uri (din S03_02_quiz_generator.py)                          ║
║  • Rezultate autograder (din S03_01_autograder.py)                             ║
║  • Activitate laborator și participare                                        ║
╠══════════════════════════════════════════════════════════════════════════════╣
║  UTILIZARE:                                                                   ║
║    python3 S03_03_report_generator.py --student RESULTS_DIR                   ║
║    python3 S03_03_report_generator.py --class SUBMISSIONS_DIR                 ║
║    python3 S03_03_report_generator.py --individual student1.json -o report.md ║
║    python3 S03_03_report_generator.py --summary --format html                 ║
╚══════════════════════════════════════════════════════════════════════════════╝

Versiune: 1.0
Data: Ianuarie 2025
"""

import argparse
import json
import os
import sys
import glob
from dataclasses import dataclass, field
from datetime import datetime
from typing import List, Dict, Any, Optional, Tuple
from pathlib import Path
import statistics
import textwrap

# 
# CONSTANTE ȘI CONFIGURARE
# 

VERSION = "1.0"
PROGRAM_NAME = "Report Generator - SEM05-06"

# Praguri pentru notare
GRADE_THRESHOLDS = {
    10: 90,
    9: 80,
    8: 70,
    7: 60,
    6: 50,
    5: 40,
    4: 0
}

# Categorii din seminar
CATEGORIES = {
    'find_xargs': {
        'name': 'Find și Xargs',
        'emoji': '🔍',
        'weight': 0.20,
        'description': 'Utilitare avansate de căutare și procesare batch'
    },
    'parameters': {
        'name': 'Parametri Script',
        'emoji': '📝',
        'weight': 0.25,
        'description': 'Argumente, getopts, shift, validare'
    },
    'permissions': {
        'name': 'Permisiuni Unix',
        'emoji': '🔒',
        'weight': 0.30,
        'description': 'chmod, chown, umask, SUID/SGID/Sticky'
    },
    'cron': {
        'name': 'Automatizare Cron',
        'emoji': '⏰',
        'weight': 0.25,
        'description': 'Planificare task-uri, crontab, at'
    }
}

# Culori ANSI
class Colors:
    HEADER = '\033[95m'
    BLUE = '\033[94m'
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    BOLD = '\033[1m'
    DIM = '\033[2m'
    END = '\033[0m'

def color(text: str, c: str, use_color: bool = True) -> str:
    """Aplică culoare textului."""
    return f"{c}{text}{Colors.END}" if use_color else text

# 
# MODELE DE DATE
# 

@dataclass
class QuizResult:
    """Rezultatul unui quiz."""
    quiz_id: str
    timestamp: datetime
    score_percentage: float
    correct: int
    wrong: int
    skipped: int
    time_seconds: float
    categories_breakdown: Dict[str, Dict[str, int]]
    questions_results: List[Dict[str, Any]] = field(default_factory=list)
    
    @classmethod
    def from_json(cls, data: Dict[str, Any], quiz_id: str = "unknown") -> 'QuizResult':
        """Creează din dicționar JSON."""
        return cls(
            quiz_id=quiz_id,
            timestamp=datetime.fromisoformat(data.get('timestamp', datetime.now().isoformat())),
            score_percentage=data.get('score_percentage', 0),
            correct=data.get('correct', 0),
            wrong=data.get('wrong', 0),
            skipped=data.get('skipped', 0),
            time_seconds=data.get('time_seconds', 0),
            categories_breakdown=data.get('categories', {}),
            questions_results=data.get('questions', [])
        )

@dataclass
class AutograderResult:
    """Rezultatul autograder-ului."""
    submission_id: str
    timestamp: datetime
    total_points: float
    max_points: float
    percentage: float
    grade: str
    categories: Dict[str, Dict[str, Any]]
    security_issues: List[str] = field(default_factory=list)
    suggestions: List[str] = field(default_factory=list)
    
    @classmethod
    def from_json(cls, data: Dict[str, Any], submission_id: str = "unknown") -> 'AutograderResult':
        """Creează din dicționar JSON."""
        return cls(
            submission_id=submission_id,
            timestamp=datetime.fromisoformat(data.get('timestamp', datetime.now().isoformat())),
            total_points=data.get('total_points', 0),
            max_points=data.get('max_points', 100),
            percentage=data.get('percentage', 0),
            grade=data.get('grade', 'N/A'),
            categories=data.get('categories', {}),
            security_issues=data.get('security_issues', []),
            suggestions=data.get('suggestions', [])
        )

@dataclass
class StudentProgress:
    """Progresul complet al unui student."""
    student_id: str
    name: str
    quiz_results: List[QuizResult] = field(default_factory=list)
    autograder_results: List[AutograderResult] = field(default_factory=list)
    participation_notes: List[str] = field(default_factory=list)
    
    @property
    def average_quiz_score(self) -> float:
        """Media scorurilor la quiz-uri."""
        if not self.quiz_results:
            return 0.0
        return statistics.mean(q.score_percentage for q in self.quiz_results)
    
    @property
    def best_quiz_score(self) -> float:
        """Cel mai bun scor la quiz."""
        if not self.quiz_results:
            return 0.0
        return max(q.score_percentage for q in self.quiz_results)
    
    @property
    def average_homework_score(self) -> float:
        """Media scorurilor la teme."""
        if not self.autograder_results:
            return 0.0
        return statistics.mean(a.percentage for a in self.autograder_results)
    
    @property
    def category_strengths(self) -> Dict[str, float]:
        """Punctele forte pe categorii."""
        scores = {cat: [] for cat in CATEGORIES}
        
        for quiz in self.quiz_results:
            for cat, data in quiz.categories_breakdown.items():
                total = data.get('correct', 0) + data.get('wrong', 0) + data.get('skipped', 0)
                if total > 0:
                    scores[cat].append(data.get('correct', 0) / total * 100)
        
        return {cat: statistics.mean(s) if s else 0 for cat, s in scores.items()}
    
    @property
    def weakest_category(self) -> Optional[str]:
        """Categoria cu cele mai slabe rezultate."""
        strengths = self.category_strengths
        if not any(strengths.values()):
            return None
        return min(strengths, key=strengths.get)
    
    @property
    def strongest_category(self) -> Optional[str]:
        """Categoria cu cele mai bune rezultate."""
        strengths = self.category_strengths
        if not any(strengths.values()):
            return None
        return max(strengths, key=strengths.get)
    
    def calculate_final_grade(self) -> Tuple[float, str]:
        """Calculează nota finală estimată."""
        quiz_weight = 0.3
        homework_weight = 0.7
        
        quiz_score = self.average_quiz_score if self.quiz_results else 50
        hw_score = self.average_homework_score if self.autograder_results else 50
        
        final = quiz_score * quiz_weight + hw_score * homework_weight
        
        grade = '4'
        for g, threshold in sorted(GRADE_THRESHOLDS.items(), reverse=True):
            if final >= threshold:
                grade = str(g)
                break
        
        return final, grade

@dataclass
class ClassStatistics:
    """Statistici pentru o clasă/grupă."""
    total_students: int
    students_with_submissions: int
    average_score: float
    median_score: float
    std_deviation: float
    min_score: float
    max_score: float
    grade_distribution: Dict[str, int]
    category_averages: Dict[str, float]
    common_mistakes: List[Tuple[str, int]]
    security_issues_count: int

# 
# ÎNCĂRCAREA DATELOR
# 

class DataLoader:
    """Încărcător de date din fișiere JSON."""
    
    @staticmethod
    def load_quiz_results(directory: str) -> List[QuizResult]:
        """Încarcă rezultatele quiz-urilor din director."""
        results = []
        pattern = os.path.join(directory, "quiz_result_*.json")
        
        for filepath in glob.glob(pattern):
            try:
                with open(filepath, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                quiz_id = os.path.basename(filepath).replace('.json', '')
                results.append(QuizResult.from_json(data, quiz_id))
            except (json.JSONDecodeError, IOError) as e:
                print(f"⚠️  Eroare la încărcarea {filepath}: {e}")
        
        return sorted(results, key=lambda x: x.timestamp)
    
    @staticmethod
    def load_autograder_results(directory: str) -> List[AutograderResult]:
        """Încarcă rezultatele autograder-ului din director."""
        results = []
        pattern = os.path.join(directory, "autograder_*.json")
        
        for filepath in glob.glob(pattern):
            try:
                with open(filepath, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                submission_id = os.path.basename(filepath).replace('.json', '')
                results.append(AutograderResult.from_json(data, submission_id))
            except (json.JSONDecodeError, IOError) as e:
                print(f"⚠️  Eroare la încărcarea {filepath}: {e}")
        
        return sorted(results, key=lambda x: x.timestamp)
    
    @staticmethod
    def load_student_progress(student_dir: str, student_id: str, 
                              name: str = "") -> StudentProgress:
        """Încarcă progresul complet al unui student."""
        progress = StudentProgress(
            student_id=student_id,
            name=name or student_id,
            quiz_results=DataLoader.load_quiz_results(student_dir),
            autograder_results=DataLoader.load_autograder_results(student_dir)
        )
        return progress
    
    @staticmethod
    def load_class_data(submissions_dir: str) -> List[StudentProgress]:
        """Încarcă datele pentru toată clasa."""
        students = []
        
        if not os.path.isdir(submissions_dir):
            return students
        
        for entry in os.scandir(submissions_dir):
            if entry.is_dir():
                student_id = entry.name
                progress = DataLoader.load_student_progress(entry.path, student_id)
                if progress.quiz_results or progress.autograder_results:
                    students.append(progress)
        
        return students

# 
# ANALIZATOR DE DATE
# 

class DataAnalyzer:
    """Analizează datele și calculează statistici."""
    
    @staticmethod
    def analyze_class(students: List[StudentProgress]) -> ClassStatistics:
        """Analizează statisticile clasei."""
        if not students:
            return ClassStatistics(
                total_students=0,
                students_with_submissions=0,
                average_score=0,
                median_score=0,
                std_deviation=0,
                min_score=0,
                max_score=0,
                grade_distribution={},
                category_averages={},
                common_mistakes=[],
                security_issues_count=0
            )
        
        # Scoruri finale
        scores = []
        grades = []
        category_scores = {cat: [] for cat in CATEGORIES}
        mistake_counts = {}
        security_count = 0
        
        for student in students:
            score, grade = student.calculate_final_grade()
            scores.append(score)
            grades.append(grade)
            
            # Categorii
            for cat, cat_score in student.category_strengths.items():
                if cat_score > 0:
                    category_scores[cat].append(cat_score)
            
            # Greșeli comune din quiz-uri
            for quiz in student.quiz_results:
                for q_result in quiz.questions_results:
                    if not q_result.get('is_correct', True):
                        q_id = q_result.get('question_id', 'unknown')
                        mistake_counts[q_id] = mistake_counts.get(q_id, 0) + 1
            
            # Probleme de securitate
            for ag in student.autograder_results:
                security_count += len(ag.security_issues)
        
        # Calculează statistici
        grade_dist = {}
        for g in grades:
            grade_dist[g] = grade_dist.get(g, 0) + 1
        
        common_mistakes = sorted(mistake_counts.items(), key=lambda x: -x[1])[:10]
        
        return ClassStatistics(
            total_students=len(students),
            students_with_submissions=len([s for s in students 
                                          if s.quiz_results or s.autograder_results]),
            average_score=statistics.mean(scores) if scores else 0,
            median_score=statistics.median(scores) if scores else 0,
            std_deviation=statistics.stdev(scores) if len(scores) > 1 else 0,
            min_score=min(scores) if scores else 0,
            max_score=max(scores) if scores else 0,
            grade_distribution=grade_dist,
            category_averages={cat: statistics.mean(s) if s else 0 
                             for cat, s in category_scores.items()},
            common_mistakes=common_mistakes,
            security_issues_count=security_count
        )
    
    @staticmethod
    def identify_struggling_students(students: List[StudentProgress], 
                                    threshold: float = 50.0) -> List[StudentProgress]:
        """Identifică studenții cu dificultăți."""
        struggling = []
        for student in students:
            score, _ = student.calculate_final_grade()
            if score < threshold:
                struggling.append(student)
        return sorted(struggling, key=lambda s: s.calculate_final_grade()[0])
    
    @staticmethod
    def identify_top_performers(students: List[StudentProgress], 
                               top_n: int = 5) -> List[StudentProgress]:
        """Identifică cei mai buni studenți."""
        return sorted(students, 
                     key=lambda s: s.calculate_final_grade()[0], 
                     reverse=True)[:top_n]
    
    @staticmethod
    def get_improvement_suggestions(student: StudentProgress) -> List[str]:
        """Generează sugestii de îmbunătățire personalizate."""
        suggestions = []
        
        # Verifică categoria cea mai slabă
        weakest = student.weakest_category
        if weakest:
            cat_info = CATEGORIES.get(weakest, {})
            suggestions.append(
                f"📚 Concentrează-te pe {cat_info.get('name', weakest)}: "
                f"{cat_info.get('description', '')}"
            )
        
        # Verifică evoluția în timp
        if len(student.quiz_results) >= 2:
            recent = student.quiz_results[-1].score_percentage
            previous = student.quiz_results[-2].score_percentage
            if recent < previous:
                suggestions.append(
                    f"📉 Scorul la ultimul quiz ({recent:.0f}%) e mai mic decât cel anterior "
                    f"({previous:.0f}%). Revizuiește materialele!"
                )
        
        # Verifică timpul la quiz
        for quiz in student.quiz_results:
            avg_time = quiz.time_seconds / (quiz.correct + quiz.wrong + quiz.skipped)
            if avg_time < 15:  # mai puțin de 15 secunde per întrebare
                suggestions.append(
                    "⏱️ Petreci foarte puțin timp pe fiecare întrebare. "
                    "Citește mai atent enunțurile!"
                )
                break
        
        # Verifică probleme de securitate
        for ag in student.autograder_results:
            if ag.security_issues:
                suggestions.append(
                    "🔒 Ai probleme de securitate în cod! Revizuiește: "
                    + ", ".join(ag.security_issues[:3])
                )
                break
        
        # Verifică skipped questions
        total_skipped = sum(q.skipped for q in student.quiz_results)
        if total_skipped > 3:
            suggestions.append(
                f"⏭️ Ai sărit {total_skipped} întrebări. "
                "Încearcă să răspunzi la toate, chiar dacă nu ești sigur!"
            )
        
        if not suggestions:
            suggestions.append("✨ Continuă așa! Ești pe drumul cel bun.")
        
        return suggestions

# 
# GENERATOR DE RAPOARTE
# 

class ReportGenerator:
    """Generează rapoarte în diverse formate."""
    
    def __init__(self, use_color: bool = True):
        self.use_color = use_color
    
    # 
    # RAPOARTE PENTRU STUDENȚI INDIVIDUALI
    # 
    
    def generate_student_report_console(self, student: StudentProgress) -> str:
        """Generează raport pentru student în format text/console."""
        lines = []
        
        # Header
        lines.append("═" * 70)
        lines.append(color(f"  📊 RAPORT DE PROGRES - {student.name.upper()}", 
                          Colors.BOLD + Colors.CYAN, self.use_color))
        lines.append(f"  Generat: {datetime.now().strftime('%Y-%m-%d %H:%M')}")
        lines.append("═" * 70)
        
        # Nota finală estimată
        final_score, grade = student.calculate_final_grade()
        grade_color = Colors.GREEN if int(grade) >= 5 else Colors.RED
        lines.append(f"\n  📝 NOTA FINALĂ ESTIMATĂ: {color(grade, grade_color + Colors.BOLD, self.use_color)}")
        lines.append(f"  📈 Scor general: {final_score:.1f}%")
        
        # Statistici quiz-uri
        lines.append(color("\n  🎯 QUIZ-URI", Colors.YELLOW, self.use_color))
        lines.append("  " + "─" * 40)
        if student.quiz_results:
            lines.append(f"  Quiz-uri completate: {len(student.quiz_results)}")
            lines.append(f"  Media scorurilor:    {student.average_quiz_score:.1f}%")
            lines.append(f"  Cel mai bun scor:    {student.best_quiz_score:.1f}%")
            
            # Ultimul quiz
            last = student.quiz_results[-1]
            lines.append(f"  Ultimul quiz:        {last.score_percentage:.1f}% "
                        f"({last.correct}/{last.correct + last.wrong + last.skipped} corecte)")
        else:
            lines.append("  ⚠️  Nu ai completat niciun quiz.")
        
        # Statistici teme
        lines.append(color("\n  📚 TEME (AUTOGRADER)", Colors.YELLOW, self.use_color))
        lines.append("  " + "─" * 40)
        if student.autograder_results:
            lines.append(f"  Teme evaluate:       {len(student.autograder_results)}")
            lines.append(f"  Media scorurilor:    {student.average_homework_score:.1f}%")
            
            # Ultima temă
            last = student.autograder_results[-1]
            lines.append(f"  Ultima temă:         {last.percentage:.1f}% (nota {last.grade})")
            
            if last.security_issues:
                lines.append(color(f"  ⚠️  Probleme securitate: {len(last.security_issues)}", 
                                  Colors.RED, self.use_color))
        else:
            lines.append("  ⚠️  Nu ai trimis nicio temă evaluată.")
        
        # Categorii
        lines.append(color("\n  📊 PUNCTE FORTE / SLABE PE CATEGORII", Colors.YELLOW, self.use_color))
        lines.append("  " + "─" * 40)
        
        strengths = student.category_strengths
        for cat_id, score in sorted(strengths.items(), key=lambda x: -x[1]):
            cat = CATEGORIES.get(cat_id, {})
            emoji = cat.get('emoji', '📋')
            name = cat.get('name', cat_id)
            
            bar_len = int(score / 5)
            bar = "█" * bar_len + "░" * (20 - bar_len)
            score_color = Colors.GREEN if score >= 70 else (Colors.YELLOW if score >= 50 else Colors.RED)
            
            lines.append(f"  {emoji} {name:20} [{bar}] {color(f'{score:.0f}%', score_color, self.use_color)}")
        
        # Sugestii
        suggestions = DataAnalyzer.get_improvement_suggestions(student)
        lines.append(color("\n  💡 SUGESTII DE ÎMBUNĂTĂȚIRE", Colors.YELLOW, self.use_color))
        lines.append("  " + "─" * 40)
        for suggestion in suggestions:
            wrapped = textwrap.wrap(suggestion, width=60)
            for i, line in enumerate(wrapped):
                prefix = "  • " if i == 0 else "    "
                lines.append(prefix + line)
        
        # Evoluție
        if len(student.quiz_results) >= 2:
            lines.append(color("\n  📈 EVOLUȚIE QUIZ-URI", Colors.YELLOW, self.use_color))
            lines.append("  " + "─" * 40)
            for i, quiz in enumerate(student.quiz_results[-5:], 1):
                date = quiz.timestamp.strftime('%Y-%m-%d')
                lines.append(f"  {i}. [{date}] {quiz.score_percentage:.0f}%")
        
        lines.append("\n" + "═" * 70)
        
        return '\n'.join(lines)
    
    def generate_student_report_markdown(self, student: StudentProgress) -> str:
        """Generează raport pentru student în format Markdown."""
        final_score, grade = student.calculate_final_grade()
        
        md = f"""# 📊 Raport de Progres - {student.name}

**Generat**: {datetime.now().strftime('%Y-%m-%d %H:%M')}  
**ID Student**: {student.student_id}

---

##  Sumar

| Metric | Valoare |
|--------|---------|
| **Nota Finală Estimată** | **{grade}** |
| Scor General | {final_score:.1f}% |
| Quiz-uri Completate | {len(student.quiz_results)} |
| Teme Trimise | {len(student.autograder_results)} |

---

##  Rezultate Quiz-uri

"""
        if student.quiz_results:
            md += f"""- **Media scorurilor**: {student.average_quiz_score:.1f}%
- **Cel mai bun scor**: {student.best_quiz_score:.1f}%
- **Ultimul quiz**: {student.quiz_results[-1].score_percentage:.1f}%

### Istoric Quiz-uri

| Data | Scor | Corecte | Greșite | Sărite |
|------|------|---------|---------|--------|
"""
            for quiz in student.quiz_results[-10:]:
                md += f"| {quiz.timestamp.strftime('%Y-%m-%d')} | {quiz.score_percentage:.0f}% | {quiz.correct} | {quiz.wrong} | {quiz.skipped} |\n"
        else:
            md += "*Nu ai completat niciun quiz.*\n"
        
        md += """
---

##  Rezultate Teme (Autograder)

"""
        if student.autograder_results:
            md += f"""- **Media scorurilor**: {student.average_homework_score:.1f}%

### Istoric Teme

| Data | Scor | Nota | Probleme Securitate |
|------|------|------|---------------------|
"""
            for ag in student.autograder_results[-10:]:
                sec_issues = len(ag.security_issues)
                sec_badge = f"⚠️ {sec_issues}" if sec_issues else "✅ 0"
                md += f"| {ag.timestamp.strftime('%Y-%m-%d')} | {ag.percentage:.0f}% | {ag.grade} | {sec_badge} |\n"
        else:
            md += "*Nu ai trimis nicio temă evaluată.*\n"
        
        md += """
---

##  Performanță pe Categorii

"""
        strengths = student.category_strengths
        for cat_id, score in sorted(strengths.items(), key=lambda x: -x[1]):
            cat = CATEGORIES.get(cat_id, {})
            emoji = cat.get('emoji', '📋')
            name = cat.get('name', cat_id)
            
            if score >= 70:
                status = "🟢"
            elif score >= 50:
                status = "🟡"
            else:
                status = "🔴"
            
            md += f"- {emoji} **{name}**: {score:.0f}% {status}\n"
        
        strongest = student.strongest_category
        weakest = student.weakest_category
        
        if strongest:
            md += f"\n**Punct forte**: {CATEGORIES[strongest]['emoji']} {CATEGORIES[strongest]['name']}\n"
        if weakest:
            md += f"**De îmbunătățit**: {CATEGORIES[weakest]['emoji']} {CATEGORIES[weakest]['name']}\n"
        
        md += """
---

##  Sugestii Personalizate

"""
        suggestions = DataAnalyzer.get_improvement_suggestions(student)
        for suggestion in suggestions:
            md += f"- {suggestion}\n"
        
        md += f"""
---

*Raport generat automat de Report Generator SEM05-06 v{VERSION}*
"""
        
        return md
    
    def generate_student_report_html(self, student: StudentProgress) -> str:
        """Generează raport pentru student în format HTML."""
        final_score, grade = student.calculate_final_grade()
        
        # Generează chart data
        quiz_dates = [q.timestamp.strftime('%Y-%m-%d') for q in student.quiz_results[-10:]]
        quiz_scores = [q.score_percentage for q in student.quiz_results[-10:]]
        
        strengths = student.category_strengths
        cat_labels = [CATEGORIES[c]['name'] for c in strengths]
        cat_scores = list(strengths.values())
        
        suggestions = DataAnalyzer.get_improvement_suggestions(student)
        
        grade_color = '#27ae60' if int(grade) >= 5 else '#e74c3c'
        
        return f'''<!DOCTYPE html>
<html lang="ro">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Raport Progres - {student.name}</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        * {{ box-sizing: border-box; margin: 0; padding: 0; }}
        body {{ 
            font-family: 'Segoe UI', Tahoma, sans-serif;
            background: #f5f6fa;
            color: #2d3436;
            line-height: 1.6;
        }}
        .container {{ max-width: 1000px; margin: 0 auto; padding: 20px; }}
        .header {{
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            padding: 40px;
            border-radius: 15px;
            margin-bottom: 30px;
            text-align: center;
        }}
        .header h1 {{ font-size: 2em; margin-bottom: 10px; }}
        .grade-badge {{
            display: inline-block;
            font-size: 3em;
            font-weight: bold;
            background: white;
            color: {grade_color};
            width: 100px;
            height: 100px;
            line-height: 100px;
            border-radius: 50%;
            margin: 20px 0;
        }}
        .cards {{ display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; }}
        .card {{
            background: white;
            border-radius: 15px;
            padding: 25px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }}
        .card h2 {{ color: #667eea; margin-bottom: 15px; font-size: 1.3em; }}
        .stat {{ display: flex; justify-content: space-between; padding: 10px 0; border-bottom: 1px solid #eee; }}
        .stat:last-child {{ border-bottom: none; }}
        .stat-value {{ font-weight: bold; color: #667eea; }}
        .chart-container {{ height: 300px; }}
        .category-bar {{
            display: flex;
            align-items: center;
            margin: 10px 0;
        }}
        .category-name {{ width: 140px; font-size: 0.9em; }}
        .category-progress {{
            flex: 1;
            height: 20px;
            background: #eee;
            border-radius: 10px;
            overflow: hidden;
        }}
        .category-fill {{
            height: 100%;
            border-radius: 10px;
            transition: width 0.5s;
        }}
        .category-value {{ width: 50px; text-align: right; font-weight: bold; }}
        .suggestion {{
            padding: 15px;
            background: #f8f9fa;
            border-left: 4px solid #667eea;
            margin: 10px 0;
            border-radius: 0 8px 8px 0;
        }}
        .footer {{ text-align: center; padding: 20px; color: #95a5a6; font-size: 0.9em; }}
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📊 Raport de Progres</h1>
            <p>{student.name}</p>
            <div class="grade-badge">{grade}</div>
            <p>Nota finală estimată • Scor: {final_score:.1f}%</p>
        </div>
        
        <div class="cards">
            <div class="card">
                <h2>🎯 Statistici Quiz-uri</h2>
                <div class="stat"><span>Quiz-uri completate</span><span class="stat-value">{len(student.quiz_results)}</span></div>
                <div class="stat"><span>Media scorurilor</span><span class="stat-value">{student.average_quiz_score:.1f}%</span></div>
                <div class="stat"><span>Cel mai bun scor</span><span class="stat-value">{student.best_quiz_score:.1f}%</span></div>
            </div>
            
            <div class="card">
                <h2>📚 Statistici Teme</h2>
                <div class="stat"><span>Teme trimise</span><span class="stat-value">{len(student.autograder_results)}</span></div>
                <div class="stat"><span>Media scorurilor</span><span class="stat-value">{student.average_homework_score:.1f}%</span></div>
            </div>
        </div>
        
        <div class="card" style="margin-top: 20px;">
            <h2>📈 Evoluție Quiz-uri</h2>
            <div class="chart-container">
                <canvas id="progressChart"></canvas>
            </div>
        </div>
        
        <div class="card" style="margin-top: 20px;">
            <h2>📊 Performanță pe Categorii</h2>
            {''.join(f'''
            <div class="category-bar">
                <span class="category-name">{CATEGORIES[cat]["emoji"]} {CATEGORIES[cat]["name"]}</span>
                <div class="category-progress">
                    <div class="category-fill" style="width: {score}%; background: {'#27ae60' if score >= 70 else '#f39c12' if score >= 50 else '#e74c3c'};"></div>
                </div>
                <span class="category-value">{score:.0f}%</span>
            </div>
            ''' for cat, score in strengths.items())}
        </div>
        
        <div class="card" style="margin-top: 20px;">
            <h2>💡 Sugestii Personalizate</h2>
            {''.join(f'<div class="suggestion">{s}</div>' for s in suggestions)}
        </div>
        
        <div class="footer">
            Generat: {datetime.now().strftime('%Y-%m-%d %H:%M')} • Report Generator SEM05-06 v{VERSION}
        </div>
    </div>
    
    <script>
        new Chart(document.getElementById('progressChart'), {{
            type: 'line',
            data: {{
                labels: {json.dumps(quiz_dates)},
                datasets: [{{
                    label: 'Scor Quiz (%)',
                    data: {json.dumps(quiz_scores)},
                    borderColor: '#667eea',
                    backgroundColor: 'rgba(102, 126, 234, 0.1)',
                    fill: true,
                    tension: 0.4
                }}]
            }},
            options: {{
                responsive: true,
                maintainAspectRatio: false,
                plugins: {{ legend: {{ display: false }} }},
                scales: {{
                    y: {{ min: 0, max: 100 }}
                }}
            }}
        }});
    </script>
</body>
</html>'''
    
    # 
    # RAPOARTE PENTRU CLASĂ
    # 
    
    def generate_class_report_console(self, students: List[StudentProgress]) -> str:
        """Generează raport pentru clasă în format console."""
        stats = DataAnalyzer.analyze_class(students)
        lines = []
        
        lines.append("═" * 70)
        lines.append(color("  📊 RAPORT CLASĂ - SEMINAR 5-6", Colors.BOLD + Colors.CYAN, self.use_color))
        lines.append(f"  Generat: {datetime.now().strftime('%Y-%m-%d %H:%M')}")
        lines.append("═" * 70)
        
        # Statistici generale
        lines.append(color("\n  📈 STATISTICI GENERALE", Colors.YELLOW, self.use_color))
        lines.append("  " + "─" * 40)
        lines.append(f"  Studenți total:        {stats.total_students}")
        lines.append(f"  Cu submisii:           {stats.students_with_submissions}")
        lines.append(f"  Media clasei:          {stats.average_score:.1f}%")
        lines.append(f"  Mediana:               {stats.median_score:.1f}%")
        lines.append(f"  Deviație standard:     {stats.std_deviation:.1f}%")
        lines.append(f"  Scor minim:            {stats.min_score:.1f}%")
        lines.append(f"  Scor maxim:            {stats.max_score:.1f}%")
        
        # Distribuție note
        lines.append(color("\n  📊 DISTRIBUȚIE NOTE", Colors.YELLOW, self.use_color))
        lines.append("  " + "─" * 40)
        for grade in ['10', '9', '8', '7', '6', '5', '4']:
            count = stats.grade_distribution.get(grade, 0)
            bar = "█" * count
            lines.append(f"  Nota {grade}: {bar} ({count})")
        
        # Medii pe categorii
        lines.append(color("\n  📚 MEDII PE CATEGORII", Colors.YELLOW, self.use_color))
        lines.append("  " + "─" * 40)
        for cat_id, avg in sorted(stats.category_averages.items(), key=lambda x: -x[1]):
            cat = CATEGORIES.get(cat_id, {})
            emoji = cat.get('emoji', '📋')
            name = cat.get('name', cat_id)
            bar_len = int(avg / 5)
            bar = "█" * bar_len + "░" * (20 - bar_len)
            lines.append(f"  {emoji} {name:20} [{bar}] {avg:.0f}%")
        
        # Top 5 studenți
        lines.append(color("\n  🏆 TOP 5 STUDENȚI", Colors.YELLOW, self.use_color))
        lines.append("  " + "─" * 40)
        top = DataAnalyzer.identify_top_performers(students, 5)
        for i, s in enumerate(top, 1):
            score, grade = s.calculate_final_grade()
            lines.append(f"  {i}. {s.name:20} - {score:.1f}% (nota {grade})")
        
        # Studenți cu dificultăți
        struggling = DataAnalyzer.identify_struggling_students(students)
        if struggling:
            lines.append(color("\n  ⚠️  STUDENȚI CU DIFICULTĂȚI", Colors.RED, self.use_color))
            lines.append("  " + "─" * 40)
            for s in struggling[:5]:
                score, _ = s.calculate_final_grade()
                weak = s.weakest_category
                weak_name = CATEGORIES.get(weak, {}).get('name', weak) if weak else 'N/A'
                lines.append(f"  • {s.name:20} - {score:.1f}% (slab la: {weak_name})")
        
        # Probleme de securitate
        if stats.security_issues_count > 0:
            lines.append(color(f"\n  🔒 PROBLEME SECURITATE: {stats.security_issues_count} total", 
                              Colors.RED, self.use_color))
        
        # Greșeli comune
        if stats.common_mistakes:
            lines.append(color("\n  ❌ GREȘELI FRECVENTE LA QUIZ", Colors.YELLOW, self.use_color))
            lines.append("  " + "─" * 40)
            for q_id, count in stats.common_mistakes[:5]:
                lines.append(f"  • Întrebarea {q_id}: {count} greșeli")
        
        lines.append("\n" + "═" * 70)
        
        return '\n'.join(lines)
    
    def generate_class_report_markdown(self, students: List[StudentProgress]) -> str:
        """Generează raport pentru clasă în format Markdown."""
        stats = DataAnalyzer.analyze_class(students)
        
        md = f"""# 📊 Raport Clasă - Seminar 5-6

**Generat**: {datetime.now().strftime('%Y-%m-%d %H:%M')}

---

##  Statistici Generale

| Metric | Valoare |
|--------|---------|
| Studenți total | {stats.total_students} |
| Cu submisii | {stats.students_with_submissions} |
| Media clasei | {stats.average_score:.1f}% |
| Mediana | {stats.median_score:.1f}% |
| Deviație standard | {stats.std_deviation:.1f}% |
| Scor minim | {stats.min_score:.1f}% |
| Scor maxim | {stats.max_score:.1f}% |

---

##  Distribuție Note

| Nota | Studenți | Procent |
|------|----------|---------|
"""
        total = stats.total_students or 1
        for grade in ['10', '9', '8', '7', '6', '5', '4']:
            count = stats.grade_distribution.get(grade, 0)
            pct = count / total * 100
            md += f"| {grade} | {count} | {pct:.1f}% |\n"
        
        md += """
---

##  Medii pe Categorii

"""
        for cat_id, avg in sorted(stats.category_averages.items(), key=lambda x: -x[1]):
            cat = CATEGORIES.get(cat_id, {})
            emoji = cat.get('emoji', '📋')
            name = cat.get('name', cat_id)
            if avg >= 70:
                status = "🟢"
            elif avg >= 50:
                status = "🟡"
            else:
                status = "🔴"
            md += f"- {emoji} **{name}**: {avg:.0f}% {status}\n"
        
        md += """
---

##  Top 5 Studenți

| Loc | Student | Scor | Nota |
|-----|---------|------|------|
"""
        top = DataAnalyzer.identify_top_performers(students, 5)
        for i, s in enumerate(top, 1):
            score, grade = s.calculate_final_grade()
            md += f"| {i} | {s.name} | {score:.1f}% | {grade} |\n"
        
        struggling = DataAnalyzer.identify_struggling_students(students)
        if struggling:
            md += """
---

##  Studenți cu Dificultăți

| Student | Scor | Categorie Slabă |
|---------|------|-----------------|
"""
            for s in struggling[:10]:
                score, _ = s.calculate_final_grade()
                weak = s.weakest_category
                weak_name = CATEGORIES.get(weak, {}).get('name', weak) if weak else 'N/A'
                md += f"| {s.name} | {score:.1f}% | {weak_name} |\n"
        
        if stats.common_mistakes:
            md += """
---

##  Greșeli Frecvente

"""
            for q_id, count in stats.common_mistakes[:10]:
                md += f"- **{q_id}**: {count} greșeli\n"
        
        md += f"""
---

*Raport generat automat de Report Generator SEM05-06 v{VERSION}*
"""
        
        return md

# 
# GENERATOR DE DATE SINTETICE (PENTRU TESTARE)
# 

class SyntheticDataGenerator:
    """Generează date sintetice pentru testare."""
    
    @staticmethod
    def generate_student(student_id: str, name: str, 
                        skill_level: float = 0.7) -> StudentProgress:
        """Generează un student cu date sintetice."""
        import random
        
        student = StudentProgress(
            student_id=student_id,
            name=name
        )
        
        # Generează quiz-uri
        num_quizzes = random.randint(2, 5)
        for i in range(num_quizzes):
            score = min(100, max(0, skill_level * 100 + random.gauss(0, 15)))
            total = random.randint(10, 15)
            correct = int(total * score / 100)
            wrong = total - correct - random.randint(0, 2)
            skipped = total - correct - wrong
            
            categories = {}
            for cat in CATEGORIES:
                cat_correct = random.randint(1, 4)
                cat_wrong = random.randint(0, 2)
                categories[cat] = {
                    'correct': cat_correct,
                    'wrong': cat_wrong,
                    'skipped': max(0, 4 - cat_correct - cat_wrong)
                }
            
            quiz = QuizResult(
                quiz_id=f"quiz_{student_id}_{i}",
                timestamp=datetime.now(),
                score_percentage=score,
                correct=correct,
                wrong=wrong,
                skipped=skipped,
                time_seconds=random.randint(300, 900),
                categories_breakdown=categories
            )
            student.quiz_results.append(quiz)
        
        # Generează rezultate autograder
        num_hw = random.randint(1, 3)
        for i in range(num_hw):
            score = min(100, max(0, skill_level * 100 + random.gauss(0, 20)))
            
            ag = AutograderResult(
                submission_id=f"hw_{student_id}_{i}",
                timestamp=datetime.now(),
                total_points=score,
                max_points=100,
                percentage=score,
                grade=str(min(10, max(4, int(score / 10) + 1))),
                categories={},
                security_issues=[] if random.random() > 0.2 else ['chmod 777 detectat']
            )
            student.autograder_results.append(ag)
        
        return student
    
    @staticmethod
    def generate_class(num_students: int = 30) -> List[StudentProgress]:
        """Generează o clasă completă."""
        import random
        
        names = [
            "Popescu Ion", "Ionescu Maria", "Popa Andrei", "Dumitrescu Elena",
            "Stan Alexandru", "Gheorghe Ana", "Stoica Mihai", "Dinu Cristina",
            "Marin Daniel", "Tudor Ioana", "Rus Adrian", "Moldovan Andreea",
            "Nistor Vlad", "Lazăr Raluca", "Neagu Bogdan", "Radu Laura",
            "Barbu Cătălin", "Constantin Diana", "Matei Florin", "Ciobanu Alina",
            "Florea Razvan", "Preda Simona", "Enache Sorin", "Voicu Bianca",
            "Petre Gabriel", "Toma Anca", "Cojocaru Marius", "Drăghici Oana",
            "Iordache Robert", "Costache Monica"
        ]
        
        students = []
        for i in range(num_students):
            name = names[i % len(names)]
            if i >= len(names):
                name += f" {i // len(names) + 1}"
            
            # Skill level variabil
            skill = random.gauss(0.65, 0.15)
            skill = min(0.95, max(0.25, skill))
            
            student = SyntheticDataGenerator.generate_student(
                f"student_{i+1:03d}",
                name,
                skill
            )
            students.append(student)
        
        return students

# 
# INTERFAȚA DE LINIE DE COMANDĂ
# 

def main():
    """Funcția principală."""
    parser = argparse.ArgumentParser(
        description='Generator de Rapoarte pentru Seminarul 5-6 SO',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog='''
Exemple:
  %(prog)s --student results_dir/student1           # Raport individual
  %(prog)s --class submissions/                     # Raport clasă
  %(prog)s --student results/ -o report.html        # Export HTML
  %(prog)s --demo                                   # Demo cu date sintetice
        '''
    )
    
    parser.add_argument('--student', '-s', metavar='DIR',
                       help='Generează raport pentru un student (director cu rezultate)')
    parser.add_argument('--class', '-c', dest='class_dir', metavar='DIR',
                       help='Generează raport pentru clasă (director cu subdirectoare studențești)')
    parser.add_argument('--output', '-o', metavar='FILE',
                       help='Fișier output (format detectat din extensie)')
    parser.add_argument('--format', '-f', choices=['console', 'markdown', 'html'],
                       default='console', help='Format output (default: console)')
    parser.add_argument('--name', metavar='NAME',
                       help='Nume student (pentru rapoarte individuale)')
    parser.add_argument('--demo', action='store_true',
                       help='Rulează demo cu date sintetice')
    parser.add_argument('--no-color', action='store_true',
                       help='Dezactivează culorile în output console')
    parser.add_argument('--version', '-v', action='version',
                       version=f'{PROGRAM_NAME} v{VERSION}')
    
    args = parser.parse_args()
    use_color = not args.no_color
    
    generator = ReportGenerator(use_color)
    
    # Demo cu date sintetice
    if args.demo:
        print(color("🧪 Generare date sintetice pentru demo...\n", Colors.CYAN, use_color))
        
        # Generează clasă sintetică
        students = SyntheticDataGenerator.generate_class(25)
        
        # Raport clasă
        if args.format == 'console':
            print(generator.generate_class_report_console(students))
        elif args.format == 'markdown':
            report = generator.generate_class_report_markdown(students)
            if args.output:
                with open(args.output, 'w', encoding='utf-8') as f:
                    f.write(report)
                print(f"✅ Raport salvat în {args.output}")
            else:
                print(report)
        
        # Un raport individual
        print("\n" + "═" * 70)
        print(color("\n📄 Exemplu raport individual:\n", Colors.YELLOW, use_color))
        sample_student = students[0]
        
        if args.format == 'html' and args.output:
            report = generator.generate_student_report_html(sample_student)
            with open(args.output, 'w', encoding='utf-8') as f:
                f.write(report)
            print(f"✅ Raport HTML salvat în {args.output}")
        else:
            print(generator.generate_student_report_console(sample_student))
        
        return 0
    
    # Raport individual pentru student
    if args.student:
        if not os.path.isdir(args.student):
            print(f"❌ Directorul nu există: {args.student}")
            return 1
        
        student_id = os.path.basename(args.student.rstrip('/'))
        name = args.name or student_id
        
        student = DataLoader.load_student_progress(args.student, student_id, name)
        
        if not student.quiz_results and not student.autograder_results:
            print(f"⚠️  Nu s-au găsit date pentru studentul {name}")
            return 1
        
        # Determină format din extensie dacă e specificat output
        fmt = args.format
        if args.output:
            ext = os.path.splitext(args.output)[1].lower()
            if ext == '.html':
                fmt = 'html'
            elif ext == '.md':
                fmt = 'markdown'
        
        # Generează raport
        if fmt == 'html':
            report = generator.generate_student_report_html(student)
        elif fmt == 'markdown':
            report = generator.generate_student_report_markdown(student)
        else:
            report = generator.generate_student_report_console(student)
        
        if args.output:
            with open(args.output, 'w', encoding='utf-8') as f:
                f.write(report)
            print(f"✅ Raport salvat în {args.output}")
        else:
            print(report)
        
        return 0
    
    # Raport pentru clasă
    if args.class_dir:
        if not os.path.isdir(args.class_dir):
            print(f"❌ Directorul nu există: {args.class_dir}")
            return 1
        
        students = DataLoader.load_class_data(args.class_dir)
        
        if not students:
            print(f"⚠️  Nu s-au găsit studenți în {args.class_dir}")
            return 1
        
        print(f"📊 Încărcat date pentru {len(students)} studenți")
        
        # Determină format
        fmt = args.format
        if args.output:
            ext = os.path.splitext(args.output)[1].lower()
            if ext == '.md':
                fmt = 'markdown'
        
        # Generează raport
        if fmt == 'markdown':
            report = generator.generate_class_report_markdown(students)
        else:
            report = generator.generate_class_report_console(students)
        
        if args.output:
            with open(args.output, 'w', encoding='utf-8') as f:
                f.write(report)
            print(f"✅ Raport salvat în {args.output}")
        else:
            print(report)
        
        return 0
    
    # Fără argumente - afișează help
    parser.print_help()
    return 0

if __name__ == '__main__':
    sys.exit(main())
