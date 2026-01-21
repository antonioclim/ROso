#!/usr/bin/env python3
"""
S04_02_quiz_generator.py - Generator de Quiz-uri pentru Seminarul 7-8

Generează quiz-uri randomizate pentru verificarea cunoștințelor
despre grep, sed, awk și expresii regulate.

Usage:
    python3 S04_02_quiz_generator.py [--count N] [--category CAT] [--format FMT]
    python3 S04_02_quiz_generator.py --export-all

Options:
    --count N       Numărul de întrebări (default: 10)
    --category CAT  regex|grep|sed|awk|all (default: all)
    --format FMT    text|html|json|moodle (default: text)
    --export-all    Exportă toate întrebările în toate formatele
"""

import random
import json
import sys
import html
from dataclasses import dataclass, asdict
from typing import List, Optional
from pathlib import Path
from datetime import datetime

#===============================================================================
# BAZA DE DATE CU ÎNTREBĂRI
#===============================================================================

@dataclass
class Question:
    """Reprezintă o întrebare de quiz."""
    id: str
    category: str
    difficulty: int  # 1-3
    question: str
    options: List[str]
    correct: int  # index 0-based
    explanation: str
    misconception: Optional[str] = None

# Baza de întrebări
QUESTIONS = [
    # REGEX Questions
    Question(
        id="R1",
        category="regex",
        difficulty=1,
        question="Ce potrivește metacaracterul '.' (punct) în regex?",
        options=["Un punct literal", "Orice caracter singular", "Zero sau mai multe caractere", "Începutul liniei"],
        correct=1,
        explanation="Punctul (.) potrivește exact un caracter oarecare, cu excepția newline în unele implementări.",
        misconception="Confuzie cu * care înseamnă 'zero sau mai multe'"
    ),
    Question(
        id="R2",
        category="regex",
        difficulty=1,
        question="Ce face '^' când apare în AFARA parantezelor []?",
        options=["Negație", "Orice caracter", "Începutul liniei", "Sfârșitul liniei"],
        correct=2,
        explanation="^ în afara [] este un anchor care potrivește începutul liniei.",
        misconception="Confuzie cu [^...] unde ^ înseamnă negație"
    ),
    Question(
        id="R3",
        category="regex",
        difficulty=2,
        question="Ce face '^' când apare LA ÎNCEPUTUL expresiei [^abc]?",
        options=["Începutul liniei", "Negație - orice EXCEPTÂND a, b, c", "Caracterul ^", "Eroare de sintaxă"],
        correct=1,
        explanation="[^abc] înseamnă 'orice caracter EXCEPTÂND a, b sau c'.",
        misconception="Confuzie cu ^ în afara [] (anchor)"
    ),
    Question(
        id="R4",
        category="regex",
        difficulty=2,
        question="Care este diferența dintre '*' și '+' în ERE?",
        options=["Nicio diferență", "* = 0+, + = 1+", "* = 1+, + = 0+", "* = exact 1"],
        correct=1,
        explanation="* potrivește 0 sau mai multe apariții, + potrivește 1 sau mai multe (minim una).",
        misconception="Confuzia că * cere cel puțin o apariție"
    ),
    Question(
        id="R5",
        category="regex",
        difficulty=2,
        question="De ce grep 'ab+c' NU găsește 'abc' dar grep -E 'ab+c' găsește?",
        options=["Bug în grep", "În BRE, + e literal", "abc nu conține +", "Nicio diferență"],
        correct=1,
        explanation="În BRE (Basic RE), + este caracter literal. Trebuie \\+ sau -E pentru quantificator.",
        misconception="Neînțelegerea diferenței BRE vs ERE"
    ),
    Question(
        id="R6",
        category="regex",
        difficulty=3,
        question="Pattern-ul [0-9]* poate potrivi...",
        options=["Cel puțin o cifră", "Exact o cifră", "Zero sau mai multe cifre", "Doar numere complete"],
        correct=2,
        explanation="* permite ZERO repetări! [0-9]* potrivește și string-ul gol.",
        misconception="Presupunerea că * cere cel puțin o apariție"
    ),
    Question(
        id="R7",
        category="regex",
        difficulty=1,
        question="Ce clasă POSIX reprezintă [[:digit:]]?",
        options=["[a-z]", "[A-Z]", "[0-9]", "[a-zA-Z0-9]"],
        correct=2,
        explanation="[[:digit:]] este echivalent cu [0-9] - doar cifre.",
        misconception="Confuzie între clasele POSIX"
    ),
    Question(
        id="R8",
        category="regex",
        difficulty=2,
        question="Ce pattern găsește linii COMPLET goale?",
        options=[".*", "^$", ".+", "^."],
        correct=1,
        explanation="^$ = început imediat urmat de sfârșit = linie goală.",
        misconception="Confuzie cu .* care potrivește orice, inclusiv gol"
    ),
    
    # GREP Questions
    Question(
        id="G1",
        category="grep",
        difficulty=1,
        question="Ce face opțiunea -i în grep?",
        options=["Inversează output", "Case insensitive", "Include filename", "Ignoră erori"],
        correct=1,
        explanation="-i face căutarea case insensitive (ignoră majuscule/minuscule).",
        misconception="Confuzie cu -v (inversare)"
    ),
    Question(
        id="G2",
        category="grep",
        difficulty=1,
        question="Ce face opțiunea -v în grep?",
        options=["Verbose output", "Inversează - linii care NU potrivesc", "Version", "Validate"],
        correct=1,
        explanation="-v afișează liniile care NU potrivesc pattern-ul.",
        misconception="Confuzie cu -i"
    ),
    Question(
        id="G3",
        category="grep",
        difficulty=2,
        question="Ce returnează grep -c 'error' file.txt?",
        options=["Numărul de caractere", "Numărul de apariții", "Numărul de LINII cu match", "Exit code"],
        correct=2,
        explanation="-c numără LINIILE care conțin pattern-ul, nu aparițiile individuale!",
        misconception="Credința că -c numără toate aparițiile"
    ),
    Question(
        id="G4",
        category="grep",
        difficulty=2,
        question="Cum numeri TOATE aparițiile lui 'error' într-un fișier?",
        options=["grep -c 'error' file", "grep -n 'error' file", "grep -o 'error' file | wc -l", "grep --count-all 'error'"],
        correct=2,
        explanation="grep -o afișează fiecare match pe linie separată, wc -l le numără.",
        misconception="Credința că -c face asta"
    ),
    Question(
        id="G5",
        category="grep",
        difficulty=1,
        question="Ce face grep -E?",
        options=["Error mode", "Extended Regular Expressions", "Exact match", "Exclude files"],
        correct=1,
        explanation="-E activează Extended RE (ERE), echivalent cu egrep.",
        misconception="Confuzie cu opțiuni similare"
    ),
    Question(
        id="G6",
        category="grep",
        difficulty=2,
        question="Care opțiune afișează DOAR numele fișierelor cu matches?",
        options=["-n", "-c", "-l", "-o"],
        correct=2,
        explanation="-l (lowercase L) afișează doar numele fișierelor cu cel puțin un match.",
        misconception="Confuzie cu -L (fișiere FĂRĂ match)"
    ),
    Question(
        id="G7",
        category="grep",
        difficulty=2,
        question="grep -A 2 -B 1 afișează...",
        options=["2 linii înainte, 1 după", "1 linie înainte, 2 după", "Total 3 linii", "Doar linia match"],
        correct=1,
        explanation="-A = After (după), -B = Before (înainte). Deci 1 înainte, linia match, 2 după.",
        misconception="Inversarea A și B"
    ),
    Question(
        id="G8",
        category="grep",
        difficulty=3,
        question="Ce face grep -r --include='*.py'?",
        options=["Caută în Python", "Recursiv doar în fișiere .py", "Include output Python", "Eroare"],
        correct=1,
        explanation="--include filtrează fișierele procesate în căutarea recursivă.",
        misconception="Neînțelegerea opțiunilor avansate"
    ),
    
    # SED Questions
    Question(
        id="S1",
        category="sed",
        difficulty=1,
        question="Sintaxa corectă pentru substituție în sed este:",
        options=["r/old/new/", "s/old/new/", "c/old/new/", "x/old/new/"],
        correct=1,
        explanation="s = substitute. s/pattern/replacement/[flags]",
        misconception="Confuzie cu alte comenzi sed (d, p, etc.)"
    ),
    Question(
        id="S2",
        category="sed",
        difficulty=1,
        question="Ce face flag-ul /g în sed s///g?",
        options=["Get", "Global - toate aparițiile", "Grep mode", "Generate"],
        correct=1,
        explanation="/g înlocuiește TOATE aparițiile pe linie, nu doar prima.",
        misconception="Presupunerea că implicit înlocuiește toate"
    ),
    Question(
        id="S3",
        category="sed",
        difficulty=2,
        question="Comanda 'sed 's/a/b/' file.txt' scrie în...",
        options=["file.txt", "stdout (terminal)", "file.txt.bak", "/dev/null"],
        correct=1,
        explanation="sed implicit scrie în stdout, NU modifică fișierul original!",
        misconception="Credința că sed modifică fișierul direct"
    ),
    Question(
        id="S4",
        category="sed",
        difficulty=2,
        question="Ce face sed -i.bak comparativ cu sed -i?",
        options=["Nicio diferență", "Creează backup înainte de editare", "Refuză editarea", "Mode interactiv"],
        correct=1,
        explanation="-i.bak creează file.bak ca backup înainte de a modifica file.",
        misconception="Ignorarea importanței backup-ului"
    ),
    Question(
        id="S5",
        category="sed",
        difficulty=2,
        question="Ce reprezintă '&' în replacement-ul sed s/pattern/&/?",
        options=["Caracter literal &", "Întregul text potrivit", "And logic", "Append"],
        correct=1,
        explanation="& este înlocuit cu tot ce a potrivit pattern-ul.",
        misconception="Tratarea & ca literal"
    ),
    Question(
        id="S6",
        category="sed",
        difficulty=2,
        question="Ce face comanda sed '/^#/d' file?",
        options=["Dublează liniile cu #", "Șterge liniile care ÎNCEP cu #", "Afișează # lines", "Eroare"],
        correct=1,
        explanation="/^#/d șterge (delete) liniile care încep cu # (comentarii).",
        misconception="Confuzie cu alte comenzi sed"
    ),
    Question(
        id="S7",
        category="sed",
        difficulty=3,
        question="Care delimitator este VALID în sed?",
        options=["Doar /", "Doar # sau |", "Orice caracter consistent", "Doar caractere speciale"],
        correct=2,
        explanation="Poți folosi orice caracter ca delimitator: s|old|new| sau s#old#new#.",
        misconception="Credința că doar / e valid"
    ),
    Question(
        id="S8",
        category="sed",
        difficulty=3,
        question="sed 's/\\(.*\\)/[\\1]/' face ce?",
        options=["Eroare", "Pune text între []", "Șterge text", "Duplică text"],
        correct=1,
        explanation="\\(.*\\) capturează tot, \\1 referă captarea, rezultat: [text original].",
        misconception="Neînțelegerea backreferences"
    ),
    
    # AWK Questions
    Question(
        id="A1",
        category="awk",
        difficulty=1,
        question="Ce conține variabila $0 în awk?",
        options=["Primul câmp", "Numele programului", "Întreaga linie curentă", "Ultimul câmp"],
        correct=2,
        explanation="$0 reprezintă întreaga linie (record) curentă.",
        misconception="Confuzie cu $1 sau alte limbaje"
    ),
    Question(
        id="A2",
        category="awk",
        difficulty=1,
        question="Ce conține $NF în awk?",
        options=["Numărul de câmpuri", "Ultimul câmp", "Newline flag", "Next file"],
        correct=1,
        explanation="NF = Number of Fields. $NF = câmpul cu numărul NF = ultimul câmp.",
        misconception="Confuzie între NF (variabilă) și $NF (câmp)"
    ),
    Question(
        id="A3",
        category="awk",
        difficulty=1,
        question="Cum setezi separatorul de câmpuri la virgulă în awk?",
        options=["-s ','", "-F','", "-d ','", "--sep=','"],
        correct=1,
        explanation="-F specifică Field Separator. -F',' pentru CSV.",
        misconception="Confuzie cu opțiuni din alte comenzi"
    ),
    Question(
        id="A4",
        category="awk",
        difficulty=2,
        question="awk '{print $1, $2}' - virgula dintre $1 și $2 face ce?",
        options=["Nimic, e opțională", "Adaugă spațiu (OFS)", "Concatenează direct", "Eroare"],
        correct=1,
        explanation="Virgula inserează OFS (Output Field Separator, default spațiu).",
        misconception="Ignorarea diferenței print cu/fără virgulă"
    ),
    Question(
        id="A5",
        category="awk",
        difficulty=2,
        question="awk '{print $1 $2}' (FĂRĂ virgulă) face ce?",
        options=["Adaugă spațiu", "Concatenează direct (fără separator)", "Eroare", "Ignoră $2"],
        correct=1,
        explanation="Fără virgulă = concatenare directă, fără separator.",
        misconception="Presupunerea că spațiul e automat"
    ),
    Question(
        id="A6",
        category="awk",
        difficulty=2,
        question="Ce reprezintă NR în awk?",
        options=["Next Record", "Number of Records (linia curentă)", "Null Reference", "New Row"],
        correct=1,
        explanation="NR = Number of Records = numărul liniei curente (global, nu per fișier).",
        misconception="Confuzie cu FNR"
    ),
    Question(
        id="A7",
        category="awk",
        difficulty=2,
        question="BEGIN { } se execută când?",
        options=["La fiecare linie", "O dată, ÎNAINTE de procesare", "O dată, DUPĂ procesare", "Niciodată"],
        correct=1,
        explanation="BEGIN rulează o singură dată, înainte de a citi orice input.",
        misconception="Confuzie cu END sau execuția normală"
    ),
    Question(
        id="A8",
        category="awk",
        difficulty=2,
        question="Ce efect are 'NR > 1' ca pattern în awk?",
        options=["Numără linii", "Procesează doar de la linia 2 (skip header)", "Compară numere", "Eroare"],
        correct=1,
        explanation="NR > 1 e true pentru toate liniile cu excepția primei (header).",
        misconception="Neînțelegerea pattern-urilor condiționale"
    ),
]

#===============================================================================
# FUNCȚII DE GENERARE
#===============================================================================

def get_questions_by_category(category: str = "all") -> List[Question]:
    """Returnează întrebările filtrate pe categorie."""
    if category == "all":
        return QUESTIONS.copy()
    return [q for q in QUESTIONS if q.category == category]

def generate_quiz(
    count: int = 10,
    category: str = "all",
    shuffle_options: bool = True
) -> List[Question]:
    """Generează un quiz randomizat."""
    questions = get_questions_by_category(category)
    random.shuffle(questions)
    
    selected = questions[:min(count, len(questions))]
    
    if shuffle_options:
        for q in selected:
            # Shuffle opțiunile păstrând track of correct answer
            correct_text = q.options[q.correct]
            random.shuffle(q.options)
            q.correct = q.options.index(correct_text)
    
    return selected

#===============================================================================
# FORMATARE OUTPUT
#===============================================================================

def format_text(questions: List[Question]) -> str:
    """Formatează quiz-ul ca text simplu."""
    output = []
    output.append("=" * 60)
    output.append("QUIZ: TEXT PROCESSING - GREP, SED, AWK")
    output.append(f"Generat: {datetime.now().strftime('%Y-%m-%d %H:%M')}")
    output.append("=" * 60)
    output.append("")
    
    for i, q in enumerate(questions, 1):
        output.append(f"Întrebarea {i} [{q.category.upper()}] (Dificultate: {'⭐' * q.difficulty})")
        output.append("-" * 40)
        output.append(q.question)
        output.append("")
        for j, opt in enumerate(q.options):
            output.append(f"  {chr(65+j)}) {opt}")
        output.append("")
    
    output.append("=" * 60)
    output.append("RĂSPUNSURI CORECTE")
    output.append("=" * 60)
    for i, q in enumerate(questions, 1):
        output.append(f"{i}. {chr(65 + q.correct)} - {q.explanation}")
    
    return "\n".join(output)

def format_html(questions: List[Question]) -> str:
    """Formatează quiz-ul ca HTML."""
    h = html.escape
    output = ["""<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Quiz: Text Processing</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; }
        .question { background: #f5f5f5; padding: 15px; margin: 20px 0; border-radius: 8px; }
        .category { display: inline-block; background: #007bff; color: white; padding: 2px 8px; border-radius: 4px; font-size: 12px; }
        .options { margin-left: 20px; }
        .option { margin: 8px 0; padding: 8px; background: white; border-radius: 4px; cursor: pointer; }
        .option:hover { background: #e0e0e0; }
        .answers { background: #e8f5e9; padding: 15px; margin-top: 30px; border-radius: 8px; }
        .answer { margin: 10px 0; }
        h1 { color: #333; }
        .difficulty { color: #ffc107; }
    </style>
</head>
<body>
    <h1>🎓 Quiz: Text Processing</h1>
    <p>Generarat: """ + datetime.now().strftime('%Y-%m-%d %H:%M') + """</p>
"""]
    
    for i, q in enumerate(questions, 1):
        output.append(f"""
    <div class="question">
        <span class="category">{h(q.category.upper())}</span>
        <span class="difficulty">{'⭐' * q.difficulty}</span>
        <h3>Întrebarea {i}</h3>
        <p>{h(q.question)}</p>
        <div class="options">
""")
        for j, opt in enumerate(q.options):
            output.append(f'            <div class="option">{chr(65+j)}) {h(opt)}</div>')
        output.append("""        </div>
    </div>""")
    
    output.append("""
    <div class="answers">
        <h2>📋 Răspunsuri Corecte</h2>
""")
    for i, q in enumerate(questions, 1):
        output.append(f'        <div class="answer"><strong>{i}. {chr(65+q.correct)}</strong> - {h(q.explanation)}</div>')
    
    output.append("""    </div>
</body>
</html>""")
    
    return "\n".join(output)

def format_json(questions: List[Question]) -> str:
    """Formatează quiz-ul ca JSON."""
    data = {
        "title": "Quiz: Text Processing",
        "generated": datetime.now().isoformat(),
        "questions": [asdict(q) for q in questions]
    }
    return json.dumps(data, indent=2, ensure_ascii=False)

def format_moodle(questions: List[Question]) -> str:
    """Formatează quiz-ul în format Moodle GIFT."""
    output = ["// Quiz: Text Processing - GIFT Format for Moodle", ""]
    
    for q in questions:
        # Escape special characters for GIFT
        question_text = q.question.replace("=", "\\=").replace("~", "\\~").replace("{", "\\{").replace("}", "\\}")
        
        output.append(f"// {q.id} - {q.category}")
        output.append(f"::{q.id}::{question_text} {{")
        
        for j, opt in enumerate(q.options):
            opt_text = opt.replace("=", "\\=").replace("~", "\\~")
            if j == q.correct:
                output.append(f"  ={opt_text}")
            else:
                output.append(f"  ~{opt_text}")
        
        output.append("}")
        output.append("")
    
    return "\n".join(output)

#===============================================================================
# MAIN
#===============================================================================

def main():
    import argparse
    
    parser = argparse.ArgumentParser(description="Generator de Quiz-uri pentru Text Processing")
    parser.add_argument("--count", type=int, default=10, help="Numărul de întrebări")
    parser.add_argument("--category", choices=["regex", "grep", "sed", "awk", "all"], default="all")
    parser.add_argument("--format", choices=["text", "html", "json", "moodle"], default="text")
    parser.add_argument("--output", "-o", help="Fișier output (default: stdout)")
    parser.add_argument("--export-all", action="store_true", help="Exportă toate întrebările în toate formatele")
    
    args = parser.parse_args()
    
    if args.export_all:
        base_path = Path("quiz_export")
        base_path.mkdir(exist_ok=True)
        
        all_questions = QUESTIONS.copy()
        
        for fmt in ["text", "html", "json", "moodle"]:
            formatter = {
                "text": format_text,
                "html": format_html,
                "json": format_json,
                "moodle": format_moodle
            }[fmt]
            
            ext = {"text": "txt", "html": "html", "json": "json", "moodle": "gift"}[fmt]
            output_file = base_path / f"quiz_all.{ext}"
            
            with open(output_file, "w", encoding="utf-8") as f:
                f.write(formatter(all_questions))
            
            print(f"✓ Exported: {output_file}")
        
        return
    
    questions = generate_quiz(args.count, args.category)
    
    formatter = {
        "text": format_text,
        "html": format_html,
        "json": format_json,
        "moodle": format_moodle
    }[args.format]
    
    output = formatter(questions)
    
    if args.output:
        with open(args.output, "w", encoding="utf-8") as f:
            f.write(output)
        print(f"Quiz salvat în: {args.output}")
    else:
        print(output)

if __name__ == "__main__":
    main()
