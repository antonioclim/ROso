#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
═══════════════════════════════════════════════════════════════════════════════
Quiz Runner - Evaluare Formativă Interactivă
═══════════════════════════════════════════════════════════════════════════════

DESCRIERE:
    Runner interactiv pentru quiz-uri formative în format YAML.
    Afișează întrebări, colectează răspunsuri, calculează scorul.

UTILIZARE:
    python3 quiz_runner.py formative/quiz.yaml
    python3 quiz_runner.py --shuffle formative/quiz.yaml
    python3 quiz_runner.py --limit 10 formative/quiz.yaml

AUTOR: Kit Pedagogic SO | ASE București - CSIE
VERSIUNE: 1.0 | Ianuarie 2025
═══════════════════════════════════════════════════════════════════════════════
"""

import sys
import random
import argparse
from pathlib import Path
from typing import Dict, List, Any, Optional
from dataclasses import dataclass, field
from datetime import datetime
import json

# Verificare dependențe
try:
    import yaml
except ImportError:
    print("Eroare: Modulul 'pyyaml' nu e instalat.")
    print("Rulează: pip install pyyaml --break-system-packages")
    sys.exit(1)


# ═══════════════════════════════════════════════════════════════════════════════
# CONFIGURARE CULORI
# ═══════════════════════════════════════════════════════════════════════════════

class Colors:
    """Culori ANSI pentru terminal."""
    RED = '\033[1;31m'
    GREEN = '\033[1;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[1;34m'
    MAGENTA = '\033[1;35m'
    CYAN = '\033[1;36m'
    WHITE = '\033[1;37m'
    DIM = '\033[2m'
    RESET = '\033[0m'
    BOLD = '\033[1m'

    @classmethod
    def disable(cls) -> None:
        """Dezactivează culorile pentru output non-TTY."""
        for attr in dir(cls):
            if attr.isupper() and not attr.startswith('_'):
                setattr(cls, attr, '')


if not sys.stdout.isatty():
    Colors.disable()


# ═══════════════════════════════════════════════════════════════════════════════
# STRUCTURI DE DATE
# ═══════════════════════════════════════════════════════════════════════════════

@dataclass
class QuizResult:
    """Rezultatul unui quiz completat."""
    total_questions: int = 0
    correct_answers: int = 0
    wrong_answers: int = 0
    score_percent: float = 0.0
    bloom_breakdown: Dict[str, Dict[str, int]] = field(default_factory=dict)
    category_breakdown: Dict[str, Dict[str, int]] = field(default_factory=dict)
    time_started: str = ""
    time_finished: str = ""
    answers: List[Dict[str, Any]] = field(default_factory=list)


# ═══════════════════════════════════════════════════════════════════════════════
# FUNCȚII UTILITAR
# ═══════════════════════════════════════════════════════════════════════════════

def clear_screen() -> None:
    """Curăță ecranul terminalului."""
    print("\033[2J\033[H", end="")


def print_header(title: str) -> None:
    """Afișează un header formatat."""
    width = 70
    print(f"\n{Colors.CYAN}{'═' * width}{Colors.RESET}")
    print(f"{Colors.BOLD}{Colors.WHITE}{title.center(width)}{Colors.RESET}")
    print(f"{Colors.CYAN}{'═' * width}{Colors.RESET}\n")


def print_question(num: int, total: int, question: Dict[str, Any]) -> None:
    """Afișează o întrebare formatată."""
    bloom = question.get('bloom', 'unknown').upper()
    category = question.get('categorie', 'general')
    
    bloom_colors = {
        'REMEMBER': Colors.GREEN,
        'UNDERSTAND': Colors.BLUE,
        'APPLY': Colors.YELLOW,
        'ANALYSE': Colors.MAGENTA,
        'EVALUATE': Colors.RED,
        'CREATE': Colors.CYAN
    }
    bloom_color = bloom_colors.get(bloom, Colors.WHITE)
    
    print(f"{Colors.DIM}─────────────────────────────────────────────────────{Colors.RESET}")
    print(f"{Colors.BOLD}Întrebarea {num}/{total}{Colors.RESET} "
          f"[{bloom_color}{bloom}{Colors.RESET}] "
          f"[{Colors.DIM}{category}{Colors.RESET}]")
    print(f"{Colors.DIM}─────────────────────────────────────────────────────{Colors.RESET}\n")
    
    # Textul întrebării
    text = question.get('text', '').strip()
    print(f"{text}\n")
    
    # Opțiunile
    options = question.get('optiuni', [])
    for i, opt in enumerate(options):
        letter = chr(65 + i)  # A, B, C, D
        print(f"  {Colors.BOLD}{letter}){Colors.RESET} {opt}")
    print()


def get_answer(num_options: int) -> int:
    """Obține răspunsul utilizatorului."""
    valid_letters = [chr(65 + i) for i in range(num_options)]
    valid_input = valid_letters + [str(i) for i in range(num_options)]
    
    while True:
        try:
            prompt = f"{Colors.YELLOW}Răspunsul tău ({'/'.join(valid_letters)}): {Colors.RESET}"
            answer = input(prompt).strip().upper()
            
            if answer in valid_letters:
                return ord(answer) - 65
            elif answer.isdigit() and 0 <= int(answer) < num_options:
                return int(answer)
            else:
                print(f"{Colors.RED}Răspuns invalid. Introdu {'/'.join(valid_letters)}.{Colors.RESET}")
        except (KeyboardInterrupt, EOFError):
            print(f"\n{Colors.YELLOW}Quiz întrerupt.{Colors.RESET}")
            sys.exit(0)


def show_feedback(question: Dict[str, Any], user_answer: int, correct: bool) -> None:
    """Afișează feedback după răspuns."""
    correct_idx = question.get('corect', 0)
    options = question.get('optiuni', [])
    
    if correct:
        print(f"{Colors.GREEN}✓ CORECT!{Colors.RESET}")
    else:
        correct_letter = chr(65 + correct_idx)
        correct_text = options[correct_idx] if correct_idx < len(options) else "?"
        print(f"{Colors.RED}✗ GREȘIT!{Colors.RESET}")
        print(f"  Răspunsul corect: {Colors.GREEN}{correct_letter}) {correct_text}{Colors.RESET}")
    
    # Explicație
    explicatie = question.get('explicatie', '').strip()
    if explicatie:
        print(f"\n{Colors.CYAN}Explicație:{Colors.RESET}")
        for line in explicatie.split('\n'):
            print(f"  {line}")
    
    # Misconceptii (dacă a greșit)
    if not correct:
        misconceptii = question.get('misconceptii', {})
        if str(user_answer) in misconceptii:
            misc = misconceptii[str(user_answer)]
            print(f"\n{Colors.YELLOW}De ce ai greșit:{Colors.RESET} {misc}")
    
    print()
    input(f"{Colors.DIM}Apasă Enter pentru a continua...{Colors.RESET}")


def print_results(result: QuizResult, quiz_title: str) -> None:
    """Afișează rezultatele finale."""
    clear_screen()
    print_header("REZULTATE FINALE")
    
    print(f"{Colors.BOLD}Quiz:{Colors.RESET} {quiz_title}\n")
    
    # Scor general
    if result.score_percent >= 90:
        score_color = Colors.GREEN
        grade = "EXCELENT"
    elif result.score_percent >= 75:
        score_color = Colors.BLUE
        grade = "BINE"
    elif result.score_percent >= 60:
        score_color = Colors.YELLOW
        grade = "SATISFĂCĂTOR"
    else:
        score_color = Colors.RED
        grade = "NECESITĂ ÎMBUNĂTĂȚIRE"
    
    print(f"{Colors.BOLD}Scor:{Colors.RESET} {score_color}{result.correct_answers}/{result.total_questions} "
          f"({result.score_percent:.1f}%){Colors.RESET}")
    print(f"{Colors.BOLD}Calificativ:{Colors.RESET} {score_color}{grade}{Colors.RESET}\n")
    
    # Breakdown pe niveluri Bloom
    if result.bloom_breakdown:
        print(f"{Colors.BOLD}Performanță pe niveluri cognitive:{Colors.RESET}")
        for bloom, stats in sorted(result.bloom_breakdown.items()):
            correct = stats.get('correct', 0)
            total = stats.get('total', 0)
            if total > 0:
                pct = (correct / total) * 100
                bar_len = int(pct / 5)
                bar = '█' * bar_len + '░' * (20 - bar_len)
                print(f"  {bloom.upper():12} {bar} {correct}/{total} ({pct:.0f}%)")
        print()
    
    # Breakdown pe categorii
    if result.category_breakdown:
        print(f"{Colors.BOLD}Performanță pe categorii:{Colors.RESET}")
        for cat, stats in sorted(result.category_breakdown.items()):
            correct = stats.get('correct', 0)
            total = stats.get('total', 0)
            if total > 0:
                pct = (correct / total) * 100
                status = "✓" if pct >= 70 else "△" if pct >= 50 else "✗"
                color = Colors.GREEN if pct >= 70 else Colors.YELLOW if pct >= 50 else Colors.RED
                print(f"  {color}{status}{Colors.RESET} {cat}: {correct}/{total} ({pct:.0f}%)")
        print()
    
    # Timp
    print(f"{Colors.DIM}Început: {result.time_started}{Colors.RESET}")
    print(f"{Colors.DIM}Terminat: {result.time_finished}{Colors.RESET}")


def save_results(result: QuizResult, output_path: Path) -> None:
    """Salvează rezultatele în format JSON."""
    data = {
        'total_questions': result.total_questions,
        'correct_answers': result.correct_answers,
        'wrong_answers': result.wrong_answers,
        'score_percent': result.score_percent,
        'bloom_breakdown': result.bloom_breakdown,
        'category_breakdown': result.category_breakdown,
        'time_started': result.time_started,
        'time_finished': result.time_finished,
        'answers': result.answers
    }
    
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    
    print(f"{Colors.GREEN}Rezultate salvate în: {output_path}{Colors.RESET}")


# ═══════════════════════════════════════════════════════════════════════════════
# FUNCȚIA PRINCIPALĂ
# ═══════════════════════════════════════════════════════════════════════════════

def run_quiz(quiz_path: Path, shuffle: bool = False, limit: Optional[int] = None) -> QuizResult:
    """Rulează quiz-ul interactiv."""
    
    # Încarcă quiz-ul
    with open(quiz_path, 'r', encoding='utf-8') as f:
        quiz_data = yaml.safe_load(f)
    
    metadata = quiz_data.get('metadata', {})
    questions = quiz_data.get('intrebari', [])
    
    if not questions:
        print(f"{Colors.RED}Eroare: Quiz-ul nu conține întrebări.{Colors.RESET}")
        sys.exit(1)
    
    # Shuffle dacă e cerut
    if shuffle:
        questions = questions.copy()
        random.shuffle(questions)
    
    # Limitează numărul de întrebări
    if limit and limit < len(questions):
        questions = questions[:limit]
    
    # Inițializare rezultat
    result = QuizResult()
    result.total_questions = len(questions)
    result.time_started = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    # Header
    clear_screen()
    quiz_title = metadata.get('subiect', 'Quiz Formativ')
    print_header(f"📝 {quiz_title}")
    
    print(f"Total întrebări: {len(questions)}")
    print(f"Timp estimat: {metadata.get('timp_estimat_minute', 20)} minute")
    print(f"\nRăspunde cu litera corespunzătoare (A, B, C, D).")
    print(f"Poți ieși oricând cu Ctrl+C.\n")
    input(f"{Colors.CYAN}Apasă Enter pentru a începe...{Colors.RESET}")
    
    # Rulează întrebările
    for i, question in enumerate(questions, 1):
        clear_screen()
        print_question(i, len(questions), question)
        
        num_options = len(question.get('optiuni', []))
        user_answer = get_answer(num_options)
        
        correct_idx = question.get('corect', 0)
        is_correct = (user_answer == correct_idx)
        
        # Actualizare statistici
        if is_correct:
            result.correct_answers += 1
        else:
            result.wrong_answers += 1
        
        # Bloom breakdown
        bloom = question.get('bloom', 'unknown')
        if bloom not in result.bloom_breakdown:
            result.bloom_breakdown[bloom] = {'correct': 0, 'total': 0}
        result.bloom_breakdown[bloom]['total'] += 1
        if is_correct:
            result.bloom_breakdown[bloom]['correct'] += 1
        
        # Category breakdown
        category = question.get('categorie', 'general')
        if category not in result.category_breakdown:
            result.category_breakdown[category] = {'correct': 0, 'total': 0}
        result.category_breakdown[category]['total'] += 1
        if is_correct:
            result.category_breakdown[category]['correct'] += 1
        
        # Salvare răspuns
        result.answers.append({
            'question_id': question.get('id', f'q{i}'),
            'user_answer': user_answer,
            'correct_answer': correct_idx,
            'is_correct': is_correct
        })
        
        # Feedback
        show_feedback(question, user_answer, is_correct)
    
    # Finalizare
    result.time_finished = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    result.score_percent = (result.correct_answers / result.total_questions) * 100
    
    return result


def main() -> None:
    """Entry point."""
    parser = argparse.ArgumentParser(
        description='Quiz Runner - Evaluare Formativă Interactivă',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Exemple:
  python3 quiz_runner.py quiz.yaml
  python3 quiz_runner.py --shuffle quiz.yaml
  python3 quiz_runner.py --limit 10 --output results.json quiz.yaml
        """
    )
    
    parser.add_argument('quiz_file', type=Path, help='Fișierul YAML cu quiz-ul')
    parser.add_argument('--shuffle', action='store_true', help='Amestecă întrebările')
    parser.add_argument('--limit', type=int, help='Limitează numărul de întrebări')
    parser.add_argument('--output', type=Path, help='Salvează rezultatele în JSON')
    parser.add_argument('--no-color', action='store_true', help='Dezactivează culorile')
    
    args = parser.parse_args()
    
    if args.no_color:
        Colors.disable()
    
    if not args.quiz_file.exists():
        print(f"{Colors.RED}Eroare: Fișierul '{args.quiz_file}' nu există.{Colors.RESET}")
        sys.exit(1)
    
    try:
        result = run_quiz(args.quiz_file, args.shuffle, args.limit)
        
        # Afișează rezultatele
        quiz_title = "Quiz Formativ"
        try:
            with open(args.quiz_file, 'r', encoding='utf-8') as f:
                data = yaml.safe_load(f)
                quiz_title = data.get('metadata', {}).get('subiect', quiz_title)
        except Exception:
            pass
        
        print_results(result, quiz_title)
        
        # Salvează dacă e cerut
        if args.output:
            save_results(result, args.output)
            
    except KeyboardInterrupt:
        print(f"\n{Colors.YELLOW}Quiz întrerupt de utilizator.{Colors.RESET}")
        sys.exit(0)


if __name__ == '__main__':
    main()
