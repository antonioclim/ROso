#!/usr/bin/env python3
"""
═══════════════════════════════════════════════════════════════════════════════
QUIZ GENERATOR - Generare chestionare randomizate
Sisteme de Operare | ASE București - CSIE

Scop: Generează variante unice de quiz pentru fiecare student
Utilizare: python3 quiz_generator.py --students 30 --output quizzes/
═══════════════════════════════════════════════════════════════════════════════
"""

import json
import random
import argparse
from pathlib import Path
from typing import List, Dict
from datetime import datetime

# Banca de întrebări - Seminar 1-2
QUESTION_BANK = [
    # Categoria: Shell Basics
    {
        "id": "SH001",
        "category": "Shell Basics",
        "difficulty": 1,
        "question": "Care este rolul principal al shell-ului în Linux?",
        "options": [
            "Gestionează hardware-ul direct",
            "Interpretează comenzi și le transmite kernel-ului",
            "Stochează fișierele utilizatorului",
            "Afișează interfața grafică"
        ],
        "correct": 1,
        "explanation": "Shell-ul este un interpret de comenzi care traduce comenzile utilizatorului pentru kernel."
    },
    {
        "id": "SH002",
        "category": "Shell Basics",
        "difficulty": 1,
        "question": "Ce afișează comanda 'pwd'?",
        "options": [
            "Lista de procese active",
            "Password-ul utilizatorului curent",
            "Directorul curent de lucru",
            "Utilizatorul conectat"
        ],
        "correct": 2,
        "explanation": "pwd = Print Working Directory - afișează calea completă a directorului curent."
    },
    {
        "id": "SH003",
        "category": "Shell Basics",
        "difficulty": 1,
        "question": "Ce semnifică exit code-ul 0 în Linux?",
        "options": [
            "Eroare fatală",
            "Comandă inexistentă",
            "Succes - comanda s-a executat corect",
            "Permisiuni insuficiente"
        ],
        "correct": 2,
        "explanation": "În convenția Unix/Linux, exit code 0 = succes, orice valoare non-zero = eroare."
    },
    
    # Categoria: Navigare
    {
        "id": "NAV001",
        "category": "Navigare",
        "difficulty": 1,
        "question": "Unde te duce comanda 'cd ~'?",
        "options": [
            "În directorul rădăcină (/)",
            "În directorul home al utilizatorului",
            "În directorul anterior",
            "În directorul părinte"
        ],
        "correct": 1,
        "explanation": "Tilda (~) este o scurtătură pentru $HOME - directorul home al utilizatorului curent."
    },
    {
        "id": "NAV002",
        "category": "Navigare",
        "difficulty": 2,
        "question": "Ce face comanda 'cd -'?",
        "options": [
            "Merge în directorul părinte",
            "Merge în directorul home",
            "Revine la directorul anterior (OLDPWD)",
            "Afișează o eroare"
        ],
        "correct": 2,
        "explanation": "cd - schimbă în directorul anterior (echivalent cu cd $OLDPWD)."
    },
    {
        "id": "NAV003",
        "category": "Navigare",
        "difficulty": 2,
        "question": "Care director conține configurările sistemului în Linux?",
        "options": [
            "/home",
            "/etc",
            "/var",
            "/usr"
        ],
        "correct": 1,
        "explanation": "/etc conține fișierele de configurare ale sistemului (Editable Text Configuration)."
    },
    
    # Categoria: Variabile
    {
        "id": "VAR001",
        "category": "Variabile",
        "difficulty": 1,
        "question": "Care sintaxă este CORECTĂ pentru setarea unei variabile în Bash?",
        "options": [
            "NUME = \"Ion\"",
            "NUME=\"Ion\"",
            "$NUME=\"Ion\"",
            "set NUME \"Ion\""
        ],
        "correct": 1,
        "explanation": "În Bash, atribuirea variabilelor NU permite spații în jurul semnului =."
    },
    {
        "id": "VAR002",
        "category": "Variabile",
        "difficulty": 2,
        "question": "Ce face comanda 'export VARIABILA'?",
        "options": [
            "Șterge variabila",
            "Face variabila accesibilă în subprocese",
            "Salvează variabila permanent pe disk",
            "Trimite variabila la alt calculator"
        ],
        "correct": 1,
        "explanation": "export face variabila parte din mediul (environment) - va fi moștenită de procesele copil."
    },
    {
        "id": "VAR003",
        "category": "Variabile",
        "difficulty": 2,
        "question": "Care variabilă specială conține exit code-ul ultimei comenzi?",
        "options": [
            "$!",
            "$0",
            "$?",
            "$$"
        ],
        "correct": 2,
        "explanation": "$? conține exit code-ul ultimei comenzi executate."
    },
    
    # Categoria: Quoting
    {
        "id": "QUO001",
        "category": "Quoting",
        "difficulty": 2,
        "question": "Care este diferența dintre single quotes și double quotes în Bash?",
        "options": [
            "Nu există nicio diferență",
            "Single quotes permit expansiunea variabilelor, double quotes nu",
            "Double quotes permit expansiunea variabilelor, single quotes nu",
            "Single quotes sunt pentru numere, double quotes pentru text"
        ],
        "correct": 2,
        "explanation": "În double quotes variabilele se expandează. În single quotes totul rămâne literal."
    },
    {
        "id": "QUO002",
        "category": "Quoting",
        "difficulty": 2,
        "question": "Dacă NUME=\"Student\", ce afișează echo '$NUME'?",
        "options": [
            "Student",
            "$NUME",
            "Nimic (linie goală)",
            "Eroare"
        ],
        "correct": 1,
        "explanation": "Single quotes păstrează totul literal - $NUME nu se interpretează."
    },
    
    # Categoria: Globbing
    {
        "id": "GLO001",
        "category": "Globbing",
        "difficulty": 2,
        "question": "Ce potrivește pattern-ul '?' în globbing?",
        "options": [
            "Zero sau mai multe caractere",
            "Exact un caracter",
            "Un caracter opțional",
            "Orice caracter inclusiv /"
        ],
        "correct": 1,
        "explanation": "? potrivește exact UN singur caracter, spre deosebire de * care potrivește zero sau mai multe."
    },
    {
        "id": "GLO002",
        "category": "Globbing",
        "difficulty": 2,
        "question": "Fișiere: file1.txt, file2.txt, file10.txt. Ce returnează 'ls file?.txt'?",
        "options": [
            "file1.txt file2.txt file10.txt",
            "file1.txt file2.txt",
            "file10.txt",
            "Niciun fișier"
        ],
        "correct": 1,
        "explanation": "? potrivește exact un caracter. file10 are DOUĂ caractere (1,0), deci nu se potrivește."
    },
    {
        "id": "GLO003",
        "category": "Globbing",
        "difficulty": 3,
        "question": "Comanda 'ls *' include fișierele ascunse (cele cu . la început)?",
        "options": [
            "Da, include toate fișierele",
            "Nu, * nu include fișierele ascunse",
            "Depinde de setările shell-ului",
            "Doar în mode interactiv"
        ],
        "correct": 1,
        "explanation": "În mod implicit, * NU potrivește fișierele care încep cu punct. Folosește ls .* pentru ascunse."
    },
    
    # Categoria: Configurare
    {
        "id": "CFG001",
        "category": "Configurare",
        "difficulty": 2,
        "question": "Când se execută fișierul ~/.bashrc?",
        "options": [
            "La pornirea calculatorului",
            "La fiecare comandă executată",
            "La deschiderea unui terminal nou (shell interactiv non-login)",
            "Niciodată automat, doar manual"
        ],
        "correct": 2,
        "explanation": "~/.bashrc se execută la fiecare shell interactiv nou. Pentru aplicare imediată: source ~/.bashrc"
    },
    {
        "id": "CFG002",
        "category": "Configurare",
        "difficulty": 2,
        "question": "Cum aplici imediat modificările făcute în ~/.bashrc?",
        "options": [
            "Repornești calculatorul",
            "Rulezi: source ~/.bashrc",
            "Aștepți 60 secunde",
            "Modificările se aplică automat"
        ],
        "correct": 1,
        "explanation": "source (sau .) execută scriptul în shell-ul curent, aplicând imediat modificările."
    },
    {
        "id": "CFG003",
        "category": "Configurare",
        "difficulty": 1,
        "question": "Ce este un alias în Bash?",
        "options": [
            "O variabilă de mediu",
            "O scurtătură pentru o comandă sau serie de comenzi",
            "Un fișier de configurare",
            "Un tip de permisiune"
        ],
        "correct": 1,
        "explanation": "Un alias permite definirea unei scurtături pentru comenzi frecvent folosite."
    },
    
    # Categoria: FHS
    {
        "id": "FHS001",
        "category": "FHS",
        "difficulty": 1,
        "question": "Ce conține directorul /tmp în Linux?",
        "options": [
            "Fișiere temporare (se șterge la reboot)",
            "Template-uri de sistem",
            "Backup-uri temporare ale utilizatorilor",
            "Fișiere de configurare temporare"
        ],
        "correct": 0,
        "explanation": "/tmp conține fișiere temporare care sunt de obicei șterse la repornirea sistemului."
    },
    {
        "id": "FHS002",
        "category": "FHS",
        "difficulty": 2,
        "question": "Care director conține jurnalele (log-urile) sistemului?",
        "options": [
            "/etc/log",
            "/var/log",
            "/log",
            "/usr/log"
        ],
        "correct": 1,
        "explanation": "/var/log conține jurnalele sistemului și aplicațiilor."
    }
]

class QuizGenerator:
    def __init__(self, question_bank: List[Dict]):
        self.question_bank = question_bank
        
    def generate_quiz(self, num_questions: int = 10, 
                      categories: List[str] = None,
                      shuffle_options: bool = True) -> Dict:
        """Generează un quiz cu întrebări randomizate."""
        
        # Filtrează după categorii dacă e specificat
        available = self.question_bank
        if categories:
            available = [q for q in available if q['category'] in categories]
        
        # Selectează întrebări random
        if num_questions > len(available):
            num_questions = len(available)
        
        selected = random.sample(available, num_questions)
        
        # Procesează întrebările
        quiz_questions = []
        for idx, q in enumerate(selected, 1):
            processed = {
                "number": idx,
                "id": q["id"],
                "category": q["category"],
                "question": q["question"],
                "options": q["options"].copy(),
                "correct_original": q["correct"]
            }
            
            # Amestecă opțiunile dacă e cerut
            if shuffle_options:
                # Păstrează răspunsul corect
                correct_text = q["options"][q["correct"]]
                random.shuffle(processed["options"])
                processed["correct"] = processed["options"].index(correct_text)
            else:
                processed["correct"] = q["correct"]
            
            processed["explanation"] = q["explanation"]
            quiz_questions.append(processed)
        
        return {
            "generated_at": datetime.now().isoformat(),
            "num_questions": num_questions,
            "questions": quiz_questions
        }
    
    def generate_student_quiz(self, student_name: str, student_id: str,
                             num_questions: int = 10) -> Dict:
        """Generează quiz personalizat pentru un student."""
        quiz = self.generate_quiz(num_questions)
        quiz["student"] = {
            "name": student_name,
            "id": student_id
        }
        return quiz
    
    def export_quiz_txt(self, quiz: Dict, filepath: Path) -> None:
        """Exportă quiz-ul în format text printabil."""
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write("═" * 70 + "\n")
            f.write("           CHESTIONAR - Seminar 1-2: Shell Bash\n")
            f.write("           Sisteme de Operare | ASE București - CSIE\n")
            f.write("═" * 70 + "\n\n")
            
            if "student" in quiz:
                f.write(f"Nume: {quiz['student']['name']}\n")
                f.write(f"ID: {quiz['student']['id']}\n\n")
            
            f.write(f"Data: {quiz['generated_at'][:10]}\n")
            f.write(f"Număr întrebări: {quiz['num_questions']}\n")
            f.write("─" * 70 + "\n\n")
            
            for q in quiz['questions']:
                f.write(f"{q['number']}. [{q['category']}] {q['question']}\n\n")
                for i, opt in enumerate(q['options']):
                    letter = chr(65 + i)  # A, B, C, D
                    f.write(f"   {letter}) {opt}\n")
                f.write("\n   Răspuns: ______\n\n")
                f.write("─" * 70 + "\n\n")
            
            f.write("\n" + "═" * 70 + "\n")
            f.write("Succes!\n")
    
    def export_quiz_html(self, quiz: Dict, filepath: Path) -> None:
        """Exportă quiz-ul în format HTML interactiv."""
        html = f"""<!DOCTYPE html>
<html lang="ro">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quiz - Shell Bash</title>
    <style>
        :root {{
            --bg: #1a1a2e;
            --card: #16213e;
            --accent: #4f46e5;
            --success: #10b981;
            --error: #ef4444;
            --text: #e5e7eb;
        }}
        * {{ margin: 0; padding: 0; box-sizing: border-box; }}
        body {{
            font-family: 'Segoe UI', sans-serif;
            background: var(--bg);
            color: var(--text);
            line-height: 1.6;
            padding: 20px;
        }}
        .container {{ max-width: 800px; margin: 0 auto; }}
        h1 {{
            text-align: center;
            margin-bottom: 30px;
            color: var(--accent);
        }}
        .question {{
            background: var(--card);
            border-radius: 12px;
            padding: 25px;
            margin-bottom: 20px;
        }}
        .question-header {{
            display: flex;
            justify-content: space-between;
            margin-bottom: 15px;
        }}
        .question-number {{
            font-weight: bold;
            color: var(--accent);
        }}
        .category {{
            font-size: 0.85em;
            background: rgba(79, 70, 229, 0.2);
            padding: 4px 10px;
            border-radius: 20px;
        }}
        .question-text {{
            font-size: 1.1em;
            margin-bottom: 20px;
        }}
        .options {{ display: flex; flex-direction: column; gap: 10px; }}
        .option {{
            background: rgba(255,255,255,0.05);
            border: 2px solid transparent;
            border-radius: 8px;
            padding: 12px 15px;
            cursor: pointer;
            transition: all 0.3s;
            display: flex;
            align-items: center;
            gap: 10px;
        }}
        .option:hover {{ border-color: var(--accent); }}
        .option.selected {{ border-color: var(--accent); background: rgba(79, 70, 229, 0.2); }}
        .option.correct {{ border-color: var(--success); background: rgba(16, 185, 129, 0.2); }}
        .option.incorrect {{ border-color: var(--error); background: rgba(239, 68, 68, 0.2); }}
        .option-letter {{
            width: 28px; height: 28px;
            background: rgba(255,255,255,0.1);
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-weight: bold;
        }}
        .explanation {{
            margin-top: 15px;
            padding: 15px;
            background: rgba(16, 185, 129, 0.1);
            border-left: 4px solid var(--success);
            border-radius: 0 8px 8px 0;
            display: none;
        }}
        .explanation.show {{ display: block; }}
        .submit-btn {{
            background: var(--accent);
            color: white;
            border: none;
            padding: 15px 40px;
            font-size: 1.1em;
            border-radius: 8px;
            cursor: pointer;
            display: block;
            margin: 30px auto;
            transition: transform 0.2s;
        }}
        .submit-btn:hover {{ transform: scale(1.05); }}
        .result {{
            text-align: center;
            padding: 30px;
            background: var(--card);
            border-radius: 12px;
            display: none;
        }}
        .result.show {{ display: block; }}
        .score {{ font-size: 3em; color: var(--accent); }}
    </style>
</head>
<body>
    <div class="container">
        <h1>🐧 Quiz: Shell Bash</h1>
        
        <div id="quiz-container">
"""
        
        for q in quiz['questions']:
            html += f"""
            <div class="question" data-correct="{q['correct']}">
                <div class="question-header">
                    <span class="question-number">Întrebarea {q['number']}</span>
                    <span class="category">{q['category']}</span>
                </div>
                <div class="question-text">{q['question']}</div>
                <div class="options">
"""
            for i, opt in enumerate(q['options']):
                letter = chr(65 + i)
                html += f"""                    <div class="option" data-index="{i}" onclick="selectOption(this)">
                        <span class="option-letter">{letter}</span>
                        <span>{opt}</span>
                    </div>
"""
            html += f"""                </div>
                <div class="explanation">{q['explanation']}</div>
            </div>
"""
        
        html += """
        </div>
        
        <button class="submit-btn" onclick="submitQuiz()">Verifică Răspunsurile</button>
        
        <div class="result" id="result">
            <div class="score" id="score">0/0</div>
            <p>Felicitări pentru completarea quiz-ului!</p>
        </div>
    </div>
    
    <script>
        function selectOption(el) {
            const question = el.closest('.question');
            question.querySelectorAll('.option').forEach(opt => opt.classList.remove('selected'));
            el.classList.add('selected');
        }
        
        function submitQuiz() {
            const questions = document.querySelectorAll('.question');
            let correct = 0;
            
            questions.forEach(q => {
                const correctIdx = parseInt(q.dataset.correct);
                const selected = q.querySelector('.option.selected');
                const explanation = q.querySelector('.explanation');
                
                q.querySelectorAll('.option').forEach((opt, idx) => {
                    opt.classList.remove('correct', 'incorrect');
                    if (idx === correctIdx) {
                        opt.classList.add('correct');
                    }
                });
                
                if (selected) {
                    const selectedIdx = parseInt(selected.dataset.index);
                    if (selectedIdx === correctIdx) {
                        correct++;
                    } else {
                        selected.classList.add('incorrect');
                    }
                }
                
                explanation.classList.add('show');
            });
            
            document.getElementById('score').textContent = `${correct}/${questions.length}`;
            document.getElementById('result').classList.add('show');
            document.querySelector('.submit-btn').style.display = 'none';
        }
    </script>
</body>
</html>
"""
        
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(html)
    
    def export_answer_key(self, quiz: Dict, filepath: Path) -> None:
        """Exportă cheia de răspunsuri (pentru instructor)."""
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write("═" * 50 + "\n")
            f.write("    CHEIE RĂSPUNSURI - CONFIDENȚIAL\n")
            f.write("═" * 50 + "\n\n")
            
            if "student" in quiz:
                f.write(f"Student: {quiz['student']['name']} ({quiz['student']['id']})\n\n")
            
            for q in quiz['questions']:
                letter = chr(65 + q['correct'])
                f.write(f"{q['number']}. {letter}\n")
            
            f.write("\n" + "═" * 50 + "\n")

def main():
    parser = argparse.ArgumentParser(description='Generare quizuri Seminar 1-2')
    parser.add_argument('--students', type=int, default=1,
                       help='Număr de studenți pentru care se generează')
    parser.add_argument('--questions', type=int, default=10,
                       help='Număr de întrebări per quiz')
    parser.add_argument('--output', type=str, default='quizzes',
                       help='Director output')
    parser.add_argument('--format', choices=['txt', 'html', 'both'], default='both',
                       help='Format export')
    
    args = parser.parse_args()
    
    output_dir = Path(args.output)
    output_dir.mkdir(exist_ok=True)
    
    generator = QuizGenerator(QUESTION_BANK)
    
    print(f"Generare {args.students} quiz-uri cu {args.questions} întrebări fiecare...")
    print(f"Output: {output_dir}/")
    print()
    
    for i in range(1, args.students + 1):
        student_id = f"S{i:03d}"
        quiz = generator.generate_student_quiz(f"Student {i}", student_id, args.questions)
        
        if args.format in ['txt', 'both']:
            generator.export_quiz_txt(quiz, output_dir / f"quiz_{student_id}.txt")
        
        if args.format in ['html', 'both']:
            generator.export_quiz_html(quiz, output_dir / f"quiz_{student_id}.html")
        
        # Cheie răspunsuri
        generator.export_answer_key(quiz, output_dir / f"key_{student_id}.txt")
        
        print(f"  ✓ Quiz generat pentru {student_id}")
    
    print()
    print(f"✓ {args.students} quiz-uri generate în {output_dir}/")

if __name__ == '__main__':
    main()
