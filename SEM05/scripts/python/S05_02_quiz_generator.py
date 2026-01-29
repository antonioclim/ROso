#!/usr/bin/env python3
"""
S05_02_quiz_generator.py - Generator Quiz pentru Bash Scripting

Sisteme de Operare | ASE București - CSIE
Seminar 5: Advanced Bash Scripting

Generează quiz-uri interactive pentru conceptele de Bash:
- Funcții (scope, return, local)
- Arrays (indexate, asociative, iterare)
- Robustețe (set -euo pipefail)
- Trap și cleanup

UTILIZARE:
    python3 S05_02_quiz_generator.py                    # Quiz interactiv
    python3 S05_02_quiz_generator.py --topic functions  # Quiz specific
    python3 S05_02_quiz_generator.py --export quiz.json # Export întrebări
    python3 S05_02_quiz_generator.py --html quiz.html   # Generează HTML
"""

import argparse
import json
import random
import sys
from dataclasses import dataclass, field, asdict
from typing import List, Optional
from html import escape

@dataclass
class Question:
    """O întrebare de quiz."""
    id: str
    topic: str
    difficulty: str  # easy, medium, hard
    question: str
    code: Optional[str]
    options: List[str]
    correct: int  # index (0-based)
    explanation: str
    misconception: Optional[str] = None
    frequency: Optional[int] = None  # % who get it wrong

# ============================================================
# BANCA DE ÎNTREBĂRI
# ============================================================

QUESTIONS = [
    # ==================== FUNCTIONS ====================
    Question(
        id="func_01",
        topic="functions",
        difficulty="medium",
        question="Ce afișează acest script?",
        code='''count=10
process() {
    count=$((count + 1))
}
process
echo $count''',
        options=["10", "11", "Eroare: variabilă nedefinită", "0"],
        correct=1,
        explanation="Variabilele în funcții Bash sunt GLOBALE by default. Fără 'local', count este modificată.",
        misconception="Variabilele în funcții sunt locale by default",
        frequency=80
    ),
    Question(
        id="func_02",
        topic="functions",
        difficulty="hard",
        question="Ce valoare are 'result' după execuție?",
        code='''get_value() {
    return 42
}
result=$(get_value)''',
        options=["42", "String gol", "0", "Eroare"],
        correct=1,
        explanation="'return' setează exit code, nu returnează valori. $() capturează stdout, care e gol.",
        misconception="return returnează valori ca în alte limbaje",
        frequency=75
    ),
    Question(
        id="func_03",
        topic="functions",
        difficulty="easy",
        question="Care e diferența între 'local x=5' și 'x=5' într-o funcție?",
        code=None,
        options=[
            "Nicio diferență",
            "'local' face variabila vizibilă doar în funcție",
            "'local' face variabila readonly",
            "'local' exportă variabila"
        ],
        correct=1,
        explanation="'local' limitează scope-ul variabilei la funcția curentă și funcțiile apelate din ea.",
        frequency=40
    ),
    Question(
        id="func_04",
        topic="functions",
        difficulty="medium",
        question="Ce afișează scriptul când e rulat cu './script.sh EXTERNAL'?",
        code='''#!/bin/bash
show() {
    echo "$1"
}
show "INTERNAL"''',
        options=["EXTERNAL", "INTERNAL", "EXTERNAL INTERNAL", "Nimic"],
        correct=1,
        explanation="$1 în funcție se referă la argumentele funcției, nu ale scriptului.",
        misconception="$1 în funcție e argumentul scriptului",
        frequency=65
    ),
    
    # ==================== ARRAYS ====================
    Question(
        id="arr_01",
        topic="arrays",
        difficulty="easy",
        question="Ce afișează?",
        code='''arr=("apple" "banana" "cherry")
echo ${arr[1]}''',
        options=["apple", "banana", "cherry", "Eroare"],
        correct=1,
        explanation="Arrays în Bash încep de la INDEX 0. arr[0]=apple, arr[1]=banana.",
        misconception="Arrays încep de la index 1",
        frequency=55
    ),
    Question(
        id="arr_02",
        topic="arrays",
        difficulty="hard",
        question="Câte iterații are acest loop?",
        code='''files=("file one.txt" "file two.txt")
for f in ${files[@]}; do
    echo "$f"
done''',
        options=["2", "4", "1", "Eroare"],
        correct=1,
        explanation="Fără ghilimele, word splitting separă 'file one.txt' în 'file' și 'one.txt'.",
        misconception="for i in ${arr[@]} funcționează corect",
        frequency=65
    ),
    Question(
        id="arr_03",
        topic="arrays",
        difficulty="hard",
        question="Ce afișează 'Keys'?",
        code='''config[host]="localhost"
config[port]="8080"
echo "Keys: ${!config[@]}"''',
        options=["Keys: host port", "Keys: 0", "Keys: localhost 8080", "Eroare"],
        correct=1,
        explanation="Fără 'declare -A', Bash tratează config ca array indexat. 'host' devine 0.",
        misconception="declare -A e opțional pentru arrays asociative",
        frequency=70
    ),
    Question(
        id="arr_04",
        topic="arrays",
        difficulty="medium",
        question="După 'unset arr[2]', ce e la arr[2]?",
        code='''arr=(a b c d e)
unset arr[2]
echo "Index 2: ${arr[2]}"''',
        options=["c", "d", "Gol/nedefinit", "Eroare"],
        correct=2,
        explanation="unset NU reindexează array-ul. Creează un 'sparse array' cu gap.",
        misconception="unset reindexează array-ul",
        frequency=50
    ),
    Question(
        id="arr_05",
        topic="arrays",
        difficulty="easy",
        question="Ce returnează ${#arr[@]} pentru arr=(a b c)?",
        code=None,
        options=["abc", "3", "1", "a b c"],
        correct=1,
        explanation="${#arr[@]} returnează numărul de elemente din array.",
        frequency=30
    ),
    
    # ==================== solidNESS ====================
    Question(
        id="robust_01",
        topic="robustness",
        difficulty="hard",
        question="Ce afișează acest script?",
        code='''#!/bin/bash
set -e
if false; then
    echo "A"
fi
echo "B"''',
        options=["Nimic (se oprește)", "B", "A și B", "Doar A"],
        correct=1,
        explanation="set -e NU funcționează în context de test (if, while, until).",
        misconception="set -e oprește la ORICE eroare",
        frequency=75
    ),
    Question(
        id="robust_02",
        topic="robustness",
        difficulty="medium",
        question="Ce exit code returnează pipeline-ul FĂRĂ pipefail?",
        code='''false | true | true
echo $?''',
        options=["0", "1", "2", "127"],
        correct=0,
        explanation="Fără pipefail, pipeline returnează exit code-ul ultimei comenzi (true=0).",
        misconception="Pipeline returnează eroarea primei comenzi",
        frequency=50
    ),
    Question(
        id="robust_03",
        topic="robustness",
        difficulty="medium",
        question="Ce afișează cu set -u?",
        code='''#!/bin/bash
set -u
echo "Value: ${UNDEFINED:-default}"''',
        options=["Eroare: unbound variable", "Value: default", "Value: ", "Value: UNDEFINED"],
        correct=1,
        explanation="${VAR:-default} oferă valoare default și NU declanșează eroarea set -u.",
        frequency=45
    ),
    Question(
        id="robust_04",
        topic="robustness",
        difficulty="hard",
        question="Ce afișează?",
        code='''#!/bin/bash
set -e
false || echo "Recovered"
echo "Continues"''',
        options=["Nimic", "Recovered apoi se oprește", "Recovered și Continues", "Doar Continues"],
        correct=2,
        explanation="|| 'salvează' eroarea - întreaga expresie returnează 0, set -e nu se declanșează.",
        frequency=60
    ),
    
    # ==================== TRAP ====================
    Question(
        id="trap_01",
        topic="trap",
        difficulty="medium",
        question="Când se execută 'trap cleanup EXIT'?",
        code=None,
        options=[
            "Doar la exit explicit",
            "La orice ieșire (normală, eroare, signal)",
            "Doar la erori",
            "Doar la semnale (SIGINT, etc.)"
        ],
        correct=1,
        explanation="trap EXIT se execută la ORICE ieșire din script, indiferent de cauză.",
        frequency=45
    ),
    Question(
        id="trap_02",
        topic="trap",
        difficulty="hard",
        question="Ce afișează?",
        code='''trap 'echo "Cleanup"' EXIT
(
    echo "Subshell"
    false
)
echo "After"''',
        options=["Subshell, Cleanup, After, Cleanup", "Subshell, After, Cleanup", "Subshell, Cleanup", "Eroare"],
        correct=1,
        explanation="Trap NU se moștenește în subshell. Cleanup se execută doar la ieșirea scriptului principal.",
        misconception="trap se moștenește în subshell",
        frequency=45
    ),
    Question(
        id="trap_03",
        topic="trap",
        difficulty="easy",
        question="Care e scopul principal al funcției die()?",
        code='''die() {
    echo "FATAL: $*" >&2
    exit 1
}''',
        options=[
            "Afișează mesaj și continuă",
            "Afișează eroare pe stderr și oprește scriptul",
            "Loghează mesaj în fișier",
            "Trimite email de alertă"
        ],
        correct=1,
        explanation="die() e un pattern standard pentru erori fatale - mesaj pe stderr + exit.",
        frequency=25
    ),
    
    # ==================== INTEGRATION ====================
    Question(
        id="integ_01",
        topic="integration",
        difficulty="hard",
        question="Care afirmație e ADEVĂRATĂ despre acest cod?",
        code='''#!/bin/bash
set -euo pipefail
declare -A config
config[timeout]=30
process() {
    result="${config[timeout]}"
    echo $result
}
value=$(process)''',
        options=[
            "result modifică o variabilă globală (problemă)",
            "Scriptul va eșua din cauza set -u",
            "declare -A nu e necesar",
            "Scriptul funcționează corect"
        ],
        correct=3,
        explanation="Deși result devine globală, nu afectează funcționalitatea aici. Codul e corect.",
        frequency=40
    ),
    Question(
        id="integ_02",
        topic="integration",
        difficulty="hard",
        question="Care e problema PRINCIPALĂ dacă nu există fișiere .txt?",
        code='''#!/bin/bash
set -euo pipefail
files=$(ls *.txt 2>/dev/null)
for f in $files; do
    echo "Processing: $f"
done
echo "Done!"''',
        options=[
            "Nimic, funcționează",
            "ls returnează eroare, set -e oprește scriptul",
            "for loop dă eroare",
            "echo Done nu se execută"
        ],
        correct=1,
        explanation="ls returnează non-zero când nu găsește fișiere. Cu set -e, scriptul se oprește.",
        frequency=55
    ),
]

class QuizGenerator:
    """Generator și runner de quiz-uri."""
    
    def __init__(self, questions: List[Question] = None):
        self.questions = questions or QUESTIONS
        self.score = 0
        self.total = 0
    
    def get_by_topic(self, topic: str) -> List[Question]:
        """Filtrează întrebările după topic."""
        return [q for q in self.questions if q.topic == topic]
    
    def get_by_difficulty(self, difficulty: str) -> List[Question]:
        """Filtrează după dificultate."""
        return [q for q in self.questions if q.difficulty == difficulty]
    
    def shuffle_questions(self, questions: List[Question], n: int = None) -> List[Question]:
        """Amestecă și limitează întrebările."""
        shuffled = random.sample(questions, len(questions))
        return shuffled[:n] if n else shuffled
    
    def run_interactive(self, questions: List[Question] = None, shuffle: bool = True):
        """Rulează quiz interactiv în terminal."""
        qs = questions or self.questions
        if shuffle:
            qs = self.shuffle_questions(qs)
        
        print("\n" + "="*60)
        print("🎯 QUIZ: Advanced Bash Scripting")
        print("="*60)
        print(f"Întrebări: {len(qs)}")
        print("Tastează litera răspunsului (a/b/c/d) sau 'q' pentru quit")
        print("="*60 + "\n")
        
        self.score = 0
        self.total = 0
        
        for i, q in enumerate(qs, 1):
            print(f"\n{'─'*50}")
            print(f"📝 Întrebarea {i}/{len(qs)} [{q.topic}] [{q.difficulty}]")
            if q.frequency:
                print(f"   (Greșită de {q.frequency}% din studenți)")
            print(f"{'─'*50}")
            
            print(f"\n{q.question}\n")
            
            if q.code:
                print("```bash")
                print(q.code)
                print("```\n")
            
            # Afișează opțiuni
            letters = ['a', 'b', 'c', 'd']
            for j, opt in enumerate(q.options):
                print(f"  {letters[j]}) {opt}")
            
            # Așteaptă răspuns
            while True:
                try:
                    answer = input("\nRăspunsul tău: ").strip().lower()
                except EOFError:
                    print("\n\nQuiz întrerupt.")
                    return
                
                if answer == 'q':
                    print("\nQuiz întrerupt.")
                    self._print_score()
                    return
                
                if answer in letters[:len(q.options)]:
                    break
                print("Răspuns invalid. Folosește a/b/c/d.")
            
            self.total += 1
            user_idx = letters.index(answer)
            
            if user_idx == q.correct:
                self.score += 1
                print("\n✅ CORECT!")
            else:
                print(f"\n❌ GREȘIT! Răspunsul corect: {letters[q.correct]}) {q.options[q.correct]}")
            
            print(f"\n📚 Explicație: {q.explanation}")
            
            if q.misconception:
                print(f"⚠️  Misconceptie comună: \"{q.misconception}\"")
            
            input("\n[Enter pentru următoarea întrebare]")
        
        self._print_score()
    
    def _print_score(self):
        """Afișează scorul final."""
        print("\n" + "="*60)
        print("📊 REZULTAT FINAL")
        print("="*60)
        
        if self.total > 0:
            percentage = (self.score / self.total) * 100
            print(f"\nScor: {self.score}/{self.total} ({percentage:.0f}%)")
            
            if percentage >= 90:
                print("🏆 Excelent! Stăpânești Bash scripting!")
            elif percentage >= 70:
                print("👍 Bine! Câteva concepte de revizuit.")
            elif percentage >= 50:
                print("📖 Acceptabil. Recitește materialul.")
            else:
                print("📚 Necesită studiu suplimentar.")
        
        print("="*60 + "\n")
    
    def export_json(self, filepath: str, questions: List[Question] = None):
        """Exportă întrebările în JSON."""
        qs = questions or self.questions
        data = [asdict(q) for q in qs]
        
        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
        
        print(f"✅ Exportat {len(qs)} întrebări în {filepath}")
    
    def generate_html(self, filepath: str, questions: List[Question] = None,
                      title: str = "Quiz: Advanced Bash Scripting"):
        """Generează quiz HTML interactiv."""
        qs = questions or self.questions
        
        html = f'''<!DOCTYPE html>
<html lang="ro">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{escape(title)}</title>
    <style>
        * {{ box-sizing: border-box; }}
        body {{
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            background: #1a1a2e;
            color: #eee;
        }}
        h1 {{ color: #00d9ff; text-align: center; }}
        .question {{
            background: #16213e;
            border-radius: 10px;
            padding: 20px;
            margin: 20px 0;
        }}
        .question-header {{
            display: flex;
            justify-content: space-between;
            margin-bottom: 15px;
            font-size: 0.9em;
            color: #888;
        }}
        .code {{
            background: #0d1117;
            padding: 15px;
            border-radius: 5px;
            font-family: 'Monaco', 'Consolas', monospace;
            font-size: 0.9em;
            overflow-x: auto;
            white-space: pre;
            margin: 15px 0;
        }}
        .options {{ margin: 15px 0; }}
        .option {{
            display: block;
            background: #2d2d4a;
            padding: 12px 15px;
            margin: 8px 0;
            border-radius: 5px;
            cursor: pointer;
            transition: background 0.2s;
        }}
        .option:hover {{ background: #3d3d5a; }}
        .option.selected {{ background: #4a4a7a; }}
        .option.correct {{ background: #2e7d32 !important; }}
        .option.incorrect {{ background: #c62828 !important; }}
        .explanation {{
            display: none;
            background: #1e3a5f;
            padding: 15px;
            border-radius: 5px;
            margin-top: 15px;
        }}
        .explanation.show {{ display: block; }}
        .submit-btn {{
            background: #00d9ff;
            color: #1a1a2e;
            border: none;
            padding: 12px 25px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 1em;
            font-weight: bold;
        }}
        .submit-btn:hover {{ background: #00b8d4; }}
        .submit-btn:disabled {{ background: #555; cursor: not-allowed; }}
        .score {{
            text-align: center;
            font-size: 1.5em;
            padding: 20px;
            background: #16213e;
            border-radius: 10px;
            margin-top: 30px;
        }}
        .badge {{
            display: inline-block;
            padding: 3px 8px;
            border-radius: 3px;
            font-size: 0.8em;
        }}
        .badge.easy {{ background: #4caf50; }}
        .badge.medium {{ background: #ff9800; }}
        .badge.hard {{ background: #f44336; }}
    </style>
</head>
<body>
    <h1>🎯 {escape(title)}</h1>
    <p style="text-align: center; color: #888;">
        {len(qs)} întrebări • Selectează răspunsul și apasă "Verifică"
    </p>
    
    <div id="quiz">
'''
        
        for i, q in enumerate(qs):
            diff_class = q.difficulty
            html += f'''
        <div class="question" id="q{i}">
            <div class="question-header">
                <span>Întrebarea {i+1}/{len(qs)} • {q.topic}</span>
                <span class="badge {diff_class}">{q.difficulty}</span>
            </div>
            <p><strong>{escape(q.question)}</strong></p>
'''
            if q.code:
                html += f'            <div class="code">{escape(q.code)}</div>\n'
            
            html += '            <div class="options">\n'
            for j, opt in enumerate(q.options):
                html += f'                <label class="option" data-correct="{j == q.correct}">\n'
                html += f'                    <input type="radio" name="q{i}" value="{j}" style="margin-right: 10px;">\n'
                html += f'                    {escape(opt)}\n'
                html += '                </label>\n'
            html += '            </div>\n'
            
            html += f'''            <button class="submit-btn" onclick="checkAnswer({i}, {q.correct})">Verifică</button>
            <div class="explanation" id="exp{i}">
                <p>📚 <strong>Explicație:</strong> {escape(q.explanation)}</p>
'''
            if q.misconception:
                html += f'                <p>⚠️ <strong>Misconceptie:</strong> "{escape(q.misconception)}"</p>\n'
            html += '            </div>\n        </div>\n'
        
        html += '''
    </div>
    
    <div class="score" id="finalScore" style="display: none;">
        <p>📊 Scor final: <span id="scoreValue">0</span>/{len(qs)}</p>
        <p id="scoreMessage"></p>
    </div>
    
    <script>
        let score = 0;
        let answered = 0;
        const total = ''' + str(len(qs)) + ''';
        
        function checkAnswer(qNum, correct) {
            const options = document.querySelectorAll(`#q${qNum} .option`);
            const selected = document.querySelector(`input[name="q${qNum}"]:checked`);
            const btn = document.querySelector(`#q${qNum} .submit-btn`);
            const exp = document.getElementById(`exp${qNum}`);
            
            if (!selected) {
                alert('Selectează un răspuns!');
                return;
            }
            
            btn.disabled = true;
            answered++;
            
            const selectedValue = parseInt(selected.value);
            options.forEach((opt, i) => {
                const input = opt.querySelector('input');
                input.disabled = true;
                if (i === correct) {
                    opt.classList.add('correct');
                } else if (i === selectedValue) {
                    opt.classList.add('incorrect');
                }
            });
            
            if (selectedValue === correct) {
                score++;
            }
            
            exp.classList.add('show');
            
            if (answered === total) {
                showFinalScore();
            }
        }
        
        function showFinalScore() {
            document.getElementById('finalScore').style.display = 'block';
            document.getElementById('scoreValue').textContent = score;
            
            const percentage = (score / total) * 100;
            let message = '';
            if (percentage >= 90) message = '🏆 Excelent!';
            else if (percentage >= 70) message = '👍 Bine!';
            else if (percentage >= 50) message = '📖 Acceptabil';
            else message = '📚 Necesită studiu';
            
            document.getElementById('scoreMessage').textContent = message;
            document.getElementById('finalScore').scrollIntoView({ behavior: 'smooth' });
        }
    </script>
</body>
</html>
'''
        
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(html)
        
        print(f"✅ Generat quiz HTML: {filepath}")

def main():
    parser = argparse.ArgumentParser(
        description='Generator Quiz pentru Bash Scripting'
    )
    parser.add_argument('--topic', '-t', 
                        choices=['functions', 'arrays', 'robustness', 'trap', 'integration'],
                        help='Filtrează după topic')
    parser.add_argument('--difficulty', '-d',
                        choices=['easy', 'medium', 'hard'],
                        help='Filtrează după dificultate')
    parser.add_argument('--count', '-n', type=int, help='Număr de întrebări')
    parser.add_argument('--export', help='Exportă în fișier JSON')
    parser.add_argument('--html', help='Generează quiz HTML')
    parser.add_argument('--list', '-l', action='store_true', help='Listează întrebările')
    parser.add_argument('--no-shuffle', action='store_true', help='Nu amesteca întrebările')
    
    args = parser.parse_args()
    
    generator = QuizGenerator()
    questions = generator.questions
    
    # Filtrări
    if args.topic:
        questions = generator.get_by_topic(args.topic)
    if args.difficulty:
        questions = [q for q in questions if q.difficulty == args.difficulty]
    if args.count:
        questions = generator.shuffle_questions(questions, args.count)
    
    if not questions:
        print("❌ Nicio întrebare găsită cu filtrele specificate.")
        sys.exit(1)
    
    # Acțiuni
    if args.list:
        print(f"\n📋 {len(questions)} întrebări:\n")
        for q in questions:
            print(f"  [{q.id}] [{q.topic}] [{q.difficulty}] {q.question[:50]}...")
        return
    
    if args.export:
        generator.export_json(args.export, questions)
        return
    
    if args.html:
        generator.generate_html(args.html, questions)
        return
    
    # Quiz interactiv
    generator.run_interactive(questions, shuffle=not args.no_shuffle)

if __name__ == '__main__':
    main()
