#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
╔══════════════════════════════════════════════════════════════════════════════╗
║              GENERATOR DE QUIZ-URI - SEMINAR 5-6                              ║
║              Sisteme de Operare | ASE București - CSIE                        ║
╠══════════════════════════════════════════════════════════════════════════════╣
║  Generează quiz-uri personalizate din banca de întrebări pentru:              ║
║  • Utilitare avansate (find, xargs, locate)                                   ║
║  • Parametri și opțiuni în scripturi ($@, getopts, shift)                     ║
║  • Sistemul de permisiuni Unix (chmod, chown, umask, SUID/SGID)               ║
║  • Automatizare cu cron (format, expresii, best practices)                    ║
╠══════════════════════════════════════════════════════════════════════════════╣
║  UTILIZARE:                                                                   ║
║    python3 S03_02_quiz_generator.py --generate 10                             ║
║    python3 S03_02_quiz_generator.py --category permissions --count 5          ║
║    python3 S03_02_quiz_generator.py --export quiz.json                        ║
║    python3 S03_02_quiz_generator.py --interactive                             ║
║    python3 S03_02_quiz_generator.py --difficulty hard --count 15              ║
╚══════════════════════════════════════════════════════════════════════════════╝

Versiune: 1.0
Data: Ianuarie 2025
"""

import argparse
import json
import random
import sys
import os
import time
from dataclasses import dataclass, field, asdict
from enum import Enum, auto
from typing import List, Optional, Dict, Any, Tuple
from datetime import datetime
import html
import textwrap

# 
# CONSTANTE ȘI CONFIGURARE
# 

VERSION = "1.0"
PROGRAM_NAME = "Quiz Generator - SEM03"

# Culori ANSI pentru terminal
class Colors:
    """Culori ANSI pentru formatare terminal."""
    HEADER = '\033[95m'
    BLUE = '\033[94m'
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'
    END = '\033[0m'
    
    # Fundal
    BG_GREEN = '\033[42m'
    BG_RED = '\033[41m'
    BG_YELLOW = '\033[43m'
    BG_BLUE = '\033[44m'

def color_text(text: str, color: str, use_color: bool = True) -> str:
    """Aplică culoare textului dacă este activată."""
    if not use_color:
        return text
    return f"{color}{text}{Colors.END}"

# 
# MODELE DE DATE
# 

class Category(Enum):
    """Categorii de întrebări."""
    FIND_XARGS = "find_xargs"
    PARAMETERS = "parameters"
    PERMISSIONS = "permissions"
    CRON = "cron"
    MIXED = "mixed"

class Difficulty(Enum):
    """Niveluri de dificultate."""
    EASY = "easy"
    MEDIUM = "medium"
    HARD = "hard"

class QuestionType(Enum):
    """Tipuri de întrebări."""
    MULTIPLE_CHOICE = "multiple_choice"
    TRUE_FALSE = "true_false"
    FILL_BLANK = "fill_blank"
    CODE_OUTPUT = "code_output"
    PRACTICAL = "practical"

@dataclass
class Question:
    """Model pentru o întrebare."""
    id: str
    category: Category
    difficulty: Difficulty
    question_type: QuestionType
    text: str
    options: List[str]  # Pentru MCQ
    correct_answer: str  # Index pentru MCQ, text pentru alte tipuri
    explanation: str
    code_snippet: Optional[str] = None
    tags: List[str] = field(default_factory=list)
    points: int = 1
    misconception_addressed: Optional[str] = None
    
    def to_dict(self) -> Dict[str, Any]:
        """Convertește la dicționar."""
        return {
            'id': self.id,
            'category': self.category.value,
            'difficulty': self.difficulty.value,
            'question_type': self.question_type.value,
            'text': self.text,
            'options': self.options,
            'correct_answer': self.correct_answer,
            'explanation': self.explanation,
            'code_snippet': self.code_snippet,
            'tags': self.tags,
            'points': self.points,
            'misconception_addressed': self.misconception_addressed
        }

@dataclass
class QuizResult:
    """Rezultatul unui quiz."""
    total_questions: int
    correct_answers: int
    wrong_answers: int
    skipped: int
    score_percentage: float
    time_taken_seconds: float
    questions_results: List[Dict[str, Any]]
    categories_breakdown: Dict[str, Dict[str, int]]
    
    @property
    def grade(self) -> str:
        """Calculează nota estimată (4-10)."""
        if self.score_percentage >= 90:
            return "10"
        elif self.score_percentage >= 80:
            return "9"
        elif self.score_percentage >= 70:
            return "8"
        elif self.score_percentage >= 60:
            return "7"
        elif self.score_percentage >= 50:
            return "6"
        elif self.score_percentage >= 40:
            return "5"
        else:
            return "4"

# 
# BANCA DE ÎNTREBĂRI
# 

class QuestionBank:
    """Banca de întrebări pentru quiz-uri."""
    
    def __init__(self):
        self.questions: List[Question] = []
        self._load_questions()
    
    def _load_questions(self):
        """Încarcă toate întrebările în bancă."""
        self._load_find_xargs_questions()
        self._load_parameters_questions()
        self._load_permissions_questions()
        self._load_cron_questions()
    
    # 
    # ÎNTREBĂRI FIND ȘI XARGS
    # 
    
    def _load_find_xargs_questions(self):
        """Întrebări despre find și xargs."""
        
        # F01: find -type (Easy)
        self.questions.append(Question(
            id="F01",
            category=Category.FIND_XARGS,
            difficulty=Difficulty.EASY,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="Ce afișează comanda: find /home -type f -name '*.txt'?",
            options=[
                "A) Toate fișierele .txt din /home (inclusiv subdirectoare)",
                "B) Doar fișierele .txt din /home (fără subdirectoare)",
                "C) Toate directoarele .txt din /home",
                "D) Toate fișierele care conțin '.txt' în nume"
            ],
            correct_answer="A",
            explanation="""Comanda find caută recursiv în mod implicit. Opțiunea -type f 
restricționează la fișiere regulate (nu directoare), iar -name '*.txt' 
filtrează după extensie. Pentru a limita adâncimea, ar trebui -maxdepth.""",
            tags=["find", "-type", "-name", "recursiv"],
            misconception_addressed="find caută doar în directorul specificat"
        ))
        
        # F02: find -maxdepth (Easy)
        self.questions.append(Question(
            id="F02",
            category=Category.FIND_XARGS,
            difficulty=Difficulty.EASY,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="Care comandă find caută DOAR în directorul curent, fără subdirectoare?",
            options=[
                "A) find . -name '*.log'",
                "B) find . -maxdepth 1 -name '*.log'",
                "C) find . -depth 1 -name '*.log'",
                "D) find . -nodirs -name '*.log'"
            ],
            correct_answer="B",
            explanation="""-maxdepth 1 restricționează căutarea la directorul specificat 
(nivelul 0 = directorul însuși, nivelul 1 = conținutul direct).
Opțiunea -depth face traversare depth-first, nu limitează adâncimea.""",
            tags=["find", "-maxdepth"],
            misconception_addressed="find nu caută recursiv implicit"
        ))
        
        # F03: locate vs find (Medium)
        self.questions.append(Question(
            id="F03",
            category=Category.FIND_XARGS,
            difficulty=Difficulty.MEDIUM,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="""Ai creat tocmai fișierul ~/proiect/config.txt. 
Imediat după, rulezi: locate config.txt
Ce se întâmplă?""",
            options=[
                "A) Găsește fișierul instant",
                "B) Nu găsește fișierul (baza de date nu e actualizată)",
                "C) Eroare - locate nu caută în home",
                "D) Găsește toate fișierele config.txt, inclusiv cel nou"
            ],
            correct_answer="B",
            explanation="""locate folosește o bază de date precompilată (updatedb), 
care de obicei se actualizează zilnic via cron. Fișierele create recent 
nu apar până la următorul updatedb. Pentru căutare în timp real, folosiți find.""",
            tags=["locate", "updatedb", "vs find"],
            misconception_addressed="locate caută în timp real ca find"
        ))
        
        # F04: find -exec (Medium)
        self.questions.append(Question(
            id="F04",
            category=Category.FIND_XARGS,
            difficulty=Difficulty.MEDIUM,
            question_type=QuestionType.CODE_OUTPUT,
            text="Care este diferența între aceste două comenzi?",
            code_snippet="""# Comanda 1:
find . -name "*.txt" -exec echo {} \\;

# Comanda 2:
find . -name "*.txt" -exec echo {} +""",
            options=[
                "A) Sunt identice - afișează fiecare fișier găsit",
                "B) \\; execută comanda pentru fiecare fișier; + trimite toate fișierele ca argumente",
                "C) + execută comenzi în paralel; \\; în serie",
                "D) \\; este sintaxă greșită, doar + funcționează"
            ],
            correct_answer="B",
            explanation="""Cu \\; (backslash-semicolon), -exec rulează comanda separat 
pentru fiecare fișier găsit. Cu +, -exec acumulează fișierele și 
execută comanda o singură dată cu toate ca argumente (mai eficient).
Exemplu vizual:
  \\; → echo file1.txt; echo file2.txt; echo file3.txt
  +  → echo file1.txt file2.txt file3.txt""",
            tags=["find", "-exec", "performanță"],
            points=2
        ))
        
        # F05: find -size (Medium)
        self.questions.append(Question(
            id="F05",
            category=Category.FIND_XARGS,
            difficulty=Difficulty.MEDIUM,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="Ce găsește comanda: find /var/log -size +100M?",
            options=[
                "A) Fișiere de exact 100MB",
                "B) Fișiere mai mari de 100MB",
                "C) Fișiere mai mici de 100MB",
                "D) Fișiere de cel puțin 100MB"
            ],
            correct_answer="B",
            explanation="""+100M înseamnă strict mai mare de 100 megabytes.
Sintaxa completă:
  +N = mai mare decât N
  -N = mai mic decât N
  N  = exact N (în unități de 512 bytes fără sufix)
Sufixe: c (bytes), k (KB), M (MB), G (GB)""",
            tags=["find", "-size"],
            points=1
        ))
        
        # F06: find -mtime (Medium)
        self.questions.append(Question(
            id="F06",
            category=Category.FIND_XARGS,
            difficulty=Difficulty.MEDIUM,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="Care comandă găsește fișierele modificate în ultimele 24 de ore?",
            options=[
                "A) find . -mtime 1",
                "B) find . -mtime -1",
                "C) find . -mtime +1",
                "D) find . -mtime 0"
            ],
            correct_answer="B",
            explanation="""-mtime măsoară în zile de 24h. Valorile:
  -mtime -1 = modificat mai puțin de 1 zi în urmă (ultimele ~24h)
  -mtime 1  = modificat între 1 și 2 zile în urmă
  -mtime +1 = modificat mai mult de 1 zi în urmă
  -mtime 0  = modificat în ultimele 24h (similar cu -1)
Pentru minute, folosiți -mmin.""",
            tags=["find", "-mtime", "timp"],
            points=2
        ))
        
        # F07: find cu OR (Medium)
        self.questions.append(Question(
            id="F07",
            category=Category.FIND_XARGS,
            difficulty=Difficulty.MEDIUM,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="Cum găsești fișierele cu extensia .txt SAU .log?",
            options=[
                "A) find . -name '*.txt' -name '*.log'",
                "B) find . -name '*.txt' -o -name '*.log'",
                "C) find . -name '*.txt,*.log'",
                "D) find . -name '*.txt' | find . -name '*.log'"
            ],
            correct_answer="B",
            explanation="""Operatorul -o (OR) combină condiții alternative. 
Condiții consecutive fără operator sunt AND implicit.
Sintaxa completă cu grupare pentru complexitate:
  find . \\( -name '*.txt' -o -name '*.log' \\) -type f
Parantezele trebuie escape-uite în shell.""",
            tags=["find", "OR", "operatori"],
            points=2
        ))
        
        # F08: xargs basics (Easy)
        self.questions.append(Question(
            id="F08",
            category=Category.FIND_XARGS,
            difficulty=Difficulty.EASY,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="Ce face comanda: find . -name '*.txt' | xargs wc -l?",
            options=[
                "A) Afișează fișierele .txt",
                "B) Numără liniile din fiecare fișier .txt găsit",
                "C) Numără fișierele .txt",
                "D) Șterge fișierele .txt"
            ],
            correct_answer="B",
            explanation="""xargs primește input de la stdin și îl transformă în 
argumente pentru comanda specificată. wc -l numără linii.
Echivalent conceptual cu:
  wc -l file1.txt file2.txt file3.txt ...""",
            tags=["xargs", "wc", "pipe"],
            points=1
        ))
        
        # F09: xargs cu spații (Hard)
        self.questions.append(Question(
            id="F09",
            category=Category.FIND_XARGS,
            difficulty=Difficulty.HARD,
            question_type=QuestionType.CODE_OUTPUT,
            text="Ai fișierul 'my document.txt'. Ce se întâmplă cu această comandă?",
            code_snippet="""echo "my document.txt" | xargs rm""",
            options=[
                "A) Șterge fișierul 'my document.txt'",
                "B) Încearcă să șteargă 'my' și 'document.txt' separat (eroare!)",
                "C) Eroare de sintaxă",
                "D) Nu face nimic"
            ],
            correct_answer="B",
            explanation="""xargs implicit desparte input-ul după whitespace.
'my document.txt' devine două argumente: 'my' și 'document.txt'.
Soluții:
  1) find . -print0 | xargs -0 rm  (separator NUL)
  2) echo "my document.txt" | xargs -I{} rm "{}"
  3) find . -name "*.txt" -exec rm {} \\;""",
            tags=["xargs", "spații", "securitate"],
            points=3,
            misconception_addressed="xargs gestionează automat spațiile"
        ))
        
        # F10: find -delete (Hard)
        self.questions.append(Question(
            id="F10",
            category=Category.FIND_XARGS,
            difficulty=Difficulty.HARD,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="""⚠️ ATENȚIE: Care dintre aceste comenzi este PERICULOASĂ 
și ar trebui evitată?""",
            options=[
                "A) find . -name '*.tmp' -print | xargs rm -i",
                "B) find . -name '*.tmp' -delete",
                "C) find . -delete -name '*.tmp'",
                "D) find . -name '*.tmp' -exec rm -i {} \\;"
            ],
            correct_answer="C",
            explanation="""⚠️ PERICOL: Ordinea opțiunilor în find contează!
În varianta C, -delete vine ÎNAINTEA -name, deci:
1. find începe traversarea
2. -delete ȘTERGE fiecare fișier/director
3. -name filtrează doar output-ul (prea târziu!)

Rezultat: TOȚI fișierele și directoarele sunt șterse!

Regulă de aur: Testează ÎNTOTDEAUNA cu -print înainte de -delete!""",
            tags=["find", "-delete", "securitate", "pericol"],
            points=3,
            misconception_addressed="-delete e sigur oriunde în comandă"
        ))
        
        # F11: find -perm (Hard)
        self.questions.append(Question(
            id="F11",
            category=Category.FIND_XARGS,
            difficulty=Difficulty.HARD,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="Ce găsește: find /home -perm -002?",
            options=[
                "A) Fișiere cu permisiunea exact 002",
                "B) Fișiere care au CEL PUȚIN world-writable (others write)",
                "C) Fișiere care nu sunt world-writable",
                "D) Fișiere cu owner=002"
            ],
            correct_answer="B",
            explanation="""-perm cu prefix - verifică că biții specificați sunt setați 
(pot fi și alți biți în plus).

Sintaxa:
  -perm 644  → exact 644
  -perm -644 → cel puțin 644 (și 755 match-uiește)
  -perm /644 → oricare din biți (r owner SAU w owner SAU r group...)

002 = -------w- (others write) - fișiere world-writable!""",
            tags=["find", "-perm", "securitate"],
            points=3
        ))
        
        # F12: xargs -P (Hard)
        self.questions.append(Question(
            id="F12",
            category=Category.FIND_XARGS,
            difficulty=Difficulty.HARD,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="Ce face opțiunea -P în xargs?",
            options=[
                "A) Print - afișează comanda înainte de execuție",
                "B) Parallel - execută comenzi în paralel",
                "C) Prompt - cere confirmare",
                "D) Path - specifică directorul de lucru"
            ],
            correct_answer="B",
            explanation="""-P (--max-procs) specifică numărul maxim de procese 
care rulează simultan.

Exemple:
  find . -name '*.jpg' | xargs -P 4 -I{} convert {} {}.png
  # Procesează 4 imagini simultan

  -P 0 = cât mai multe procese posibil
  -P 1 = secvențial (implicit)

Foarte util pentru CPU-intensive tasks!""",
            tags=["xargs", "-P", "paralel", "performanță"],
            points=2
        ))
        
        # F13: find -newer (Medium)
        self.questions.append(Question(
            id="F13",
            category=Category.FIND_XARGS,
            difficulty=Difficulty.MEDIUM,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="Ce găsește: find . -newer reference.txt?",
            options=[
                "A) Fișiere cu același timestamp ca reference.txt",
                "B) Fișiere modificate MAI RECENT decât reference.txt",
                "C) Fișiere mai vechi decât reference.txt",
                "D) Fișiere cu același conținut ca reference.txt"
            ],
            correct_answer="B",
            explanation="""-newer FILE găsește fișiere cu timestamp de modificare 
mai recent decât FILE.

Folosire tipică pentru backup incremental:
  touch /tmp/last_backup  # la backup anterior
  # ... timp trece ...
  find /data -newer /tmp/last_backup -type f
  # găsește fișierele modificate de la ultimul backup""",
            tags=["find", "-newer", "backup"],
            points=2
        ))
        
        # F14: xargs -I (Medium)
        self.questions.append(Question(
            id="F14",
            category=Category.FIND_XARGS,
            difficulty=Difficulty.MEDIUM,
            question_type=QuestionType.CODE_OUTPUT,
            text="Ce face această comandă?",
            code_snippet="""find . -name "*.txt" | xargs -I{} cp {} {}.backup""",
            options=[
                "A) Copiază fiecare .txt în .txt.backup",
                "B) Eroare - {} nu poate fi folosit de două ori",
                "C) Copiază toate .txt într-un fișier .backup",
                "D) Mută fișierele în directorul backup"
            ],
            correct_answer="A",
            explanation="""-I{} definește un placeholder care este înlocuit cu 
fiecare linie de input.

Echivalent cu:
  cp file1.txt file1.txt.backup
  cp file2.txt file2.txt.backup
  ...

Notă: Cu -I, implicit se procesează câte o linie pe execuție.""",
            tags=["xargs", "-I", "placeholder"],
            points=2
        ))
        
        # F15: find NOT (Easy)
        self.questions.append(Question(
            id="F15",
            category=Category.FIND_XARGS,
            difficulty=Difficulty.EASY,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="Cum găsești toate fișierele CARE NU SUNT .txt?",
            options=[
                "A) find . -name '!*.txt'",
                "B) find . ! -name '*.txt'",
                "C) find . -not '*.txt'",
                "D) find . -exclude '*.txt'"
            ],
            correct_answer="B",
            explanation="""! sau -not negează condiția următoare.
Trebuie plasat ÎNAINTE de condiția de negat.

Exemple:
  find . ! -name '*.txt'        # nu .txt
  find . ! -type d              # nu directoare
  find . ! \\( -name '*.txt' -o -name '*.log' \\)  # nici .txt, nici .log""",
            tags=["find", "NOT", "operatori"],
            points=1
        ))
    
    # 
    # ÎNTREBĂRI PARAMETRI ȘI SCRIPTURI
    # 
    
    def _load_parameters_questions(self):
        """Întrebări despre parametri și getopts."""
        
        # P01: $@ vs $* (Medium)
        self.questions.append(Question(
            id="P01",
            category=Category.PARAMETERS,
            difficulty=Difficulty.MEDIUM,
            question_type=QuestionType.CODE_OUTPUT,
            text="Dat scriptul și rularea:",
            code_snippet="""#!/bin/bash
for arg in "$@"; do echo "[$arg]"; done
echo "---"
for arg in "$*"; do echo "[$arg]"; done

# Rulare: ./script.sh "hello world" test""",
            options=[
                "A) [hello world] [test] --- [hello world test]",
                "B) [hello] [world] [test] --- [hello] [world] [test]",
                "C) [hello world] [test] --- [hello world] [test]",
                "D) [hello world test] --- [hello world] [test]"
            ],
            correct_answer="A",
            explanation=""""$@" păstrează argumentele ca entități separate (fiecare
în ghilimele proprii), iar "$*" le combină într-un singur string.

Cu "$@": "hello world" și "test" → 2 iterații
Cu "$*": "hello world test" → 1 iterație

⚠️ IMPORTANT: Fără ghilimele, ambele se comportă la fel și 
                se sparg după whitespace!""",
            tags=["$@", "$*", "arguments"],
            points=2,
            misconception_addressed="$@ și $* sunt identice"
        ))
        
        # P02: ${10} (Easy)
        self.questions.append(Question(
            id="P02",
            category=Category.PARAMETERS,
            difficulty=Difficulty.EASY,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="Într-un script cu 15 argumente, cum accesezi argumentul 10?",
            options=[
                "A) $10",
                "B) ${10}",
                "C) $[10]",
                "D) $(10)"
            ],
            correct_answer="B",
            explanation="""$10 este interpretat ca $1 urmat de caracterul '0'.
Pentru argumente >= 10, trebuie acolade: ${10}, ${11}, etc.

Exemplu:
  ./script.sh a b c d e f g h i j k l m n o
  echo $10   # afișează: a0
  echo ${10} # afișează: j""",
            tags=["parametri", "poziționali", "acolade"],
            points=1,
            misconception_addressed="$10 funcționează direct"
        ))
        
        # P03: shift (Medium)
        self.questions.append(Question(
            id="P03",
            category=Category.PARAMETERS,
            difficulty=Difficulty.MEDIUM,
            question_type=QuestionType.CODE_OUTPUT,
            text="Ce afișează acest script?",
            code_snippet="""#!/bin/bash
echo "Înainte: $1 $2 $3 $#"
shift 2
echo "După: $1 $2 $3 $#"

# Rulare: ./script.sh A B C D E""",
            options=[
                "A) Înainte: A B C 5 | După: C D E 3",
                "B) Înainte: A B C 5 | După: A B C 3",
                "C) Înainte: A B C 5 | După: C D  3",
                "D) Eroare - shift distruge toate argumentele"
            ],
            correct_answer="A",
            explanation="""shift N elimină primele N argumente, deplasând restul.

Înainte: $1=A, $2=B, $3=C, $4=D, $5=E, $#=5
După shift 2:
  - A și B sunt eliminate
  - $1=C (fost $3), $2=D (fost $4), $3=E (fost $5)
  - $#=3

shift fără argument = shift 1""",
            tags=["shift", "parametri"],
            points=2
        ))
        
        # P04: getopts optstring (Medium)
        self.questions.append(Question(
            id="P04",
            category=Category.PARAMETERS,
            difficulty=Difficulty.MEDIUM,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="""În getopts, ce înseamnă optstring "a:b:c"?""",
            options=[
                "A) -a, -b, -c toate necesită argument",
                "B) -a și -b necesită argument, -c nu",
                "C) -a, -b, -c sunt obligatorii",
                "D) : separă opțiuni incompatibile"
            ],
            correct_answer="B",
            explanation=""": după o literă înseamnă că opțiunea necesită argument.

"a:b:c" înseamnă:
  -a ARG  (obligatoriu argument)
  -b ARG  (obligatoriu argument)
  -c      (fără argument)

Exemplu valid: ./script.sh -a val1 -b val2 -c
Exemplu invalid: ./script.sh -a -b val (lipsește arg pentru -a)""",
            tags=["getopts", "optstring"],
            points=2
        ))
        
        # P05: OPTARG (Easy)
        self.questions.append(Question(
            id="P05",
            category=Category.PARAMETERS,
            difficulty=Difficulty.EASY,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="Ce conține variabila OPTARG în getopts?",
            options=[
                "A) Numele opțiunii curente",
                "B) Argumentul opțiunii curente (dacă există)",
                "C) Numărul total de opțiuni",
                "D) Indexul opțiunii curente"
            ],
            correct_answer="B",
            explanation="""OPTARG conține valoarea argumentului pentru opțiunea curentă.

while getopts "f:v" opt; do
    case $opt in
        f) echo "Fișier: $OPTARG" ;;  # OPTARG = argument pentru -f
        v) echo "Verbose mode" ;;       # OPTARG nu e setat
    esac
done

OPTIND conține indexul următorului argument de procesat.""",
            tags=["getopts", "OPTARG"],
            points=1
        ))
        
        # P06: shift după getopts (Hard)
        self.questions.append(Question(
            id="P06",
            category=Category.PARAMETERS,
            difficulty=Difficulty.HARD,
            question_type=QuestionType.CODE_OUTPUT,
            text="Ce afișează acest script?",
            code_snippet="""#!/bin/bash
while getopts "v" opt; do
    case $opt in v) verbose=1 ;; esac
done
shift $((OPTIND - 1))
echo "Argumente rămase: $@"

# Rulare: ./script.sh -v file1.txt file2.txt""",
            options=[
                "A) Argumente rămase: -v file1.txt file2.txt",
                "B) Argumente rămase: file1.txt file2.txt",
                "C) Argumente rămase: file2.txt",
                "D) Argumente rămase:"
            ],
            correct_answer="B",
            explanation="""OPTIND indică indexul primului argument ne-opțiune.
După getopts, OPTIND=2 (primul argument după -v).

shift $((OPTIND - 1)) elimină toate opțiunile procesate,
lăsând doar argumentele non-opțiune.

Pattern standard:
  while getopts "..." opt; do ... done
  shift $((OPTIND - 1))
  # Acum $@ conține doar argumentele, nu opțiunile""",
            tags=["getopts", "OPTIND", "shift"],
            points=3
        ))
        
        # P07: Default values (Medium)
        self.questions.append(Question(
            id="P07",
            category=Category.PARAMETERS,
            difficulty=Difficulty.MEDIUM,
            question_type=QuestionType.CODE_OUTPUT,
            text="Ce afișează?",
            code_snippet="""#!/bin/bash
NAME=""
echo "${NAME:-default}"
echo "${NAME:=assigned}"
echo "$NAME"
echo "${NAME:+replacement}"
echo "$NAME"

# Nu are argumente la rulare""",
            options=[
                "A) default, assigned, assigned, replacement, assigned",
                "B) default, default, , replacement, ",
                "C) default, assigned, , replacement, assigned",
                "D) default, assigned, assigned, assigned, assigned"
            ],
            correct_answer="A",
            explanation="""Expansiuni cu valori implicite:

${VAR:-default} → returnează default dacă VAR e gol/nesetat (NU modifică VAR)
${VAR:=assign}  → returnează assign ȘI setează VAR la assign
${VAR:+alt}     → returnează alt DOAR dacă VAR e setat și non-gol

Pas cu pas:
1. NAME="" (gol), ${NAME:-default} → "default"
2. ${NAME:=assigned} → NAME devine "assigned", returnează "assigned"
3. echo $NAME → "assigned"
4. ${NAME:+replacement} → NAME e setat, returnează "replacement"
5. echo $NAME → "assigned" (neschimbat)""",
            tags=["expansiuni", "default", "variabile"],
            points=2
        ))
        
        # P08: $# (Easy)
        self.questions.append(Question(
            id="P08",
            category=Category.PARAMETERS,
            difficulty=Difficulty.EASY,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="Ce conține $# într-un script bash?",
            options=[
                "A) PID-ul scriptului",
                "B) Numărul de argumente",
                "C) Exit code-ul ultimei comenzi",
                "D) Numele scriptului"
            ],
            correct_answer="B",
            explanation="""Variabile speciale:
$# = numărul de argumente poziționale
$0 = numele scriptului
$$ = PID-ul shell-ului curent
$? = exit code-ul ultimei comenzi
$! = PID-ul ultimului job în background
$- = opțiunile curente ale shell-ului""",
            tags=["variabile speciale", "$#"],
            points=1
        ))
        
        # P09: Opțiuni lungi (Hard)
        self.questions.append(Question(
            id="P09",
            category=Category.PARAMETERS,
            difficulty=Difficulty.HARD,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="De ce acest cod NU funcționează pentru --verbose?",
            code_snippet="""while getopts "v-:verbose" opt; do
    case $opt in
        v) verbose=1 ;;
        verbose) verbose=1 ;;
    esac
done""",
            options=[
                "A) getopts nu suportă opțiuni lungi",
                "B) Lipsește : după verbose",
                "C) Case nu poate avea 'verbose' ca pattern",
                "D) Trebuie folosit getopt în loc de getopts"
            ],
            correct_answer="A",
            explanation="""getopts (built-in bash) suportă DOAR opțiuni scurte!

Pentru opțiuni lungi, alternative:
1. Parsare manuală cu while/case:
   while [[ "$1" =~ ^- ]]; do
       case "$1" in
           -v|--verbose) verbose=1 ;;
       esac
       shift
   done

2. getopt (comandă externă, nu built-in):
   OPTS=$(getopt -o v -l verbose -- "$@")

3. Librării: shflags, bash-argsparse""",
            tags=["getopts", "opțiuni lungi", "limitări"],
            points=3,
            misconception_addressed="getopts poate parsa --verbose"
        ))
        
        # P10: $0 (Easy)
        self.questions.append(Question(
            id="P10",
            category=Category.PARAMETERS,
            difficulty=Difficulty.EASY,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="Ce conține $0 în scriptul /home/user/scripts/backup.sh?",
            options=[
                "A) backup.sh",
                "B) /home/user/scripts/backup.sh sau ./backup.sh",
                "C) Primul argument de la rulare",
                "D) Mereu calea absolută completă"
            ],
            correct_answer="B",
            explanation="""$0 conține exact cum a fost invocat scriptul:
  ./backup.sh           → $0 = "./backup.sh"
  /home/user/backup.sh  → $0 = "/home/user/backup.sh"
  bash backup.sh        → $0 = "backup.sh"

Pentru doar numele: basename "$0"
Pentru directorul: dirname "$0" """,
            tags=["$0", "parametri"],
            points=1
        ))
        
        # P11: Arrays (Medium)
        self.questions.append(Question(
            id="P11",
            category=Category.PARAMETERS,
            difficulty=Difficulty.MEDIUM,
            question_type=QuestionType.CODE_OUTPUT,
            text="Ce afișează?",
            code_snippet="""#!/bin/bash
args=("$@")
echo "Count: ${#args[@]}"
echo "First: ${args[0]}"
echo "All: ${args[@]}"

# Rulare: ./script.sh one "two three" four""",
            options=[
                "A) Count: 3, First: one, All: one two three four",
                "B) Count: 4, First: one, All: one two three four",
                "C) Count: 3, First: ./script.sh, All: one two three four",
                "D) Count: 3, First: one, All: one \"two three\" four"
            ],
            correct_answer="A",
            explanation="""args=("$@") creează un array din argumentele scriptului.

${#args[@]} = numărul de elemente (3)
${args[0]}  = primul element (one)
${args[@]}  = toate elementele (spațiile din "two three" se păstrează intern 
              dar la afișare par combinate)

Array indices încep de la 0 (nu 1 ca $1).""",
            tags=["arrays", "$@", "parametri"],
            points=2
        ))
        
        # P12: Validare argumente (Medium)
        self.questions.append(Question(
            id="P12",
            category=Category.PARAMETERS,
            difficulty=Difficulty.MEDIUM,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="Care este CEL MAI BUN mod de a verifica că scriptul primește exact 2 argumente?",
            options=[
                "A) if [ $# != 2 ]; then usage; fi",
                "B) if [ $# -ne 2 ]; then usage; exit 1; fi",
                "C) if (( $# != 2 )); then usage; exit 1; fi",
                "D) B și C sunt ambele corecte și complete"
            ],
            correct_answer="D",
            explanation="""Ambele B și C sunt corecte:

[ $# -ne 2 ] - sintaxă POSIX, portabilă
(( $# != 2 )) - sintaxă bash, mai citibilă

Ambele includ exit 1 care e esențial!
Varianta A: != funcționează dar e pentru stringuri,
            și lipsește exit - scriptul continuă!

Pattern complet:
if [[ $# -ne 2 ]]; then
    echo "Usage: $(basename $0) arg1 arg2" >&2
    exit 1
fi""",
            tags=["validare", "argumente", "best practice"],
            points=2
        ))
    
    # 
    # ÎNTREBĂRI PERMISIUNI
    # 
    
    def _load_permissions_questions(self):
        """Întrebări despre sistemul de permisiuni Unix."""
        
        # M01: x pe director (Medium)
        self.questions.append(Question(
            id="M01",
            category=Category.PERMISSIONS,
            difficulty=Difficulty.MEDIUM,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="""Un director are permisiunile: drwxr-x---
Ce POT face membrii grupului?""",
            options=[
                "A) Pot lista conținutul (ls) și intra (cd)",
                "B) Pot doar lista conținutul",
                "C) Pot doar intra în director",
                "D) Nu pot face nimic"
            ],
            correct_answer="A",
            explanation="""Pentru directoare:
r = poți citi lista de fișiere (ls)
x = poți accesa/traversa (cd, și accesa fișiere dacă știi numele)
w = poți crea/șterge fișiere în director

Group are r-x, deci:
✓ pot face ls (r)
✓ pot face cd (x)
✗ nu pot crea/șterge fișiere (lipsește w)

⚠️ IMPORTANT: x pe director ≠ executare fișiere!""",
            tags=["permisiuni", "director", "r-x"],
            points=2,
            misconception_addressed="x pe director = pot executa fișierele din el"
        ))
        
        # M02: chmod octal (Easy)
        self.questions.append(Question(
            id="M02",
            category=Category.PERMISSIONS,
            difficulty=Difficulty.EASY,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="Ce permisiuni setează chmod 644?",
            options=[
                "A) rwxr--r--",
                "B) rw-r--r--",
                "C) rw-rw-r--",
                "D) rw-------"
            ],
            correct_answer="B",
            explanation="""Calcul octal: fiecare cifră e suma r(4) + w(2) + x(1)

6 = 4+2   = rw-  (owner)
4 = 4     = r--  (group)
4 = 4     = r--  (others)

Rezultat: rw-r--r--

Valori comune:
755 = rwxr-xr-x (executabil public)
644 = rw-r--r-- (fișier public)
600 = rw------- (fișier privat)
700 = rwx------ (director privat)""",
            tags=["chmod", "octal", "calcul"],
            points=1
        ))
        
        # M03: chmod 777 (Medium)
        self.questions.append(Question(
            id="M03",
            category=Category.PERMISSIONS,
            difficulty=Difficulty.MEDIUM,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="⚠️ De ce este chmod 777 APROAPE ÎNTOTDEAUNA o greșeală?",
            options=[
                "A) E sintaxă invalidă",
                "B) Oferă acces complet tuturor - vulnerabilitate de securitate",
                "C) Șterge fișierul",
                "D) Necesită permisiuni root"
            ],
            correct_answer="B",
            explanation="""777 = rwxrwxrwx - TOȚI utilizatorii pot:
- Citi fișierul
- Modifica fișierul  
- Executa fișierul (sau pentru directoare: crea/șterge în el)

⚠️ PROBLEME:
1. Orice user poate modifica/șterge fișierele tale
2. Pe server web: atacatorii pot încărca/rula malware
3. Scripturile pot fi modificate să facă lucruri malițioase

🛡️ SOLUȚII CORECTE:
- 755 pentru directoare publice
- 644 pentru fișiere publice
- 750/640 pentru acces de grup
- 700/600 pentru fișiere private""",
            tags=["chmod", "777", "securitate"],
            points=2,
            misconception_addressed="chmod 777 rezolvă problemele de permisiuni"
        ))
        
        # M04: umask (Hard)
        self.questions.append(Question(
            id="M04",
            category=Category.PERMISSIONS,
            difficulty=Difficulty.HARD,
            question_type=QuestionType.CODE_OUTPUT,
            text="Cu umask 027, ce permisiuni va avea un fișier nou creat?",
            code_snippet="""umask 027
touch newfile.txt
ls -l newfile.txt""",
            options=[
                "A) -rw-r----- (640)",
                "B) -rwxr-x--- (750)",
                "C) -rw-rw-r-- (664)",
                "D) --------- (000)"
            ],
            correct_answer="A",
            explanation="""⚠️ umask ELIMINĂ biți, nu setează!

Fișierele noi pornesc cu 666 (fără x), directoarele cu 777.

Calcul pentru fișier:
  666  = rw-rw-rw-
- 027  = ---r-xrwx (umask = ce se ELIMINĂ)
= 640  = rw-r-----

umask 027:
- 0: nimic eliminat de la owner (rw- rămâne)
- 2: w eliminat de la group (rw- → r--)
- 7: tot eliminat de la others (rw- → ---)

⚠️ ATENȚIE: umask 077 e recomandat pentru fișiere private!""",
            tags=["umask", "permisiuni default"],
            points=3,
            misconception_addressed="umask setează permisiunile"
        ))
        
        # M05: SUID (Hard)
        self.questions.append(Question(
            id="M05",
            category=Category.PERMISSIONS,
            difficulty=Difficulty.HARD,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="""Fișierul /usr/bin/passwd are: -rwsr-xr-x root root
Ce înseamnă 's' și de ce e necesar?""",
            options=[
                "A) Sticky bit - nu poate fi șters decât de root",
                "B) SUID - rulează cu permisiunile owner-ului (root), necesar pentru a modifica /etc/shadow",
                "C) Symlink special către parola root",
                "D) Signed - fișierul e verificat criptografic"
            ],
            correct_answer="B",
            explanation="""SUID (Set User ID) - 's' în poziția x a owner:
Când un user normal rulează passwd, procesul rulează cu UID-ul 
owner-ului (root), nu al userului care l-a lansat.

DE CE E NECESAR:
- /etc/shadow (hash-uri parole) e readable doar de root
- Userii trebuie să-și poată schimba propria parolă
- Soluție: passwd e SUID root, poate scrie în shadow

⚠️ SUID pe script bash NU funcționează! (securitate)
   Funcționează doar pe executabile binare.

Setare: chmod u+s file sau chmod 4755 file""",
            tags=["SUID", "passwd", "securitate"],
            points=3,
            misconception_addressed="SUID funcționează pe scripturi bash"
        ))
        
        # M06: SGID pe director (Hard)
        self.questions.append(Question(
            id="M06",
            category=Category.PERMISSIONS,
            difficulty=Difficulty.HARD,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="Ce face SGID setat pe un DIRECTOR?",
            options=[
                "A) Fișierele noi moștenesc grupul directorului, nu al creatorului",
                "B) Doar membrii grupului pot accesa directorul",
                "C) Procesele din director rulează cu permisiunile grupului",
                "D) Directorul devine read-only pentru grup"
            ],
            correct_answer="A",
            explanation="""SGID pe director = moștenire grup

Fără SGID: fișierele noi au grupul primar al creatorului
Cu SGID: fișierele noi au grupul directorului părinete

Util pentru directoare de proiect partajate:
  mkdir /project
  chgrp developers /project
  chmod g+s /project
  # Acum toate fișierele vor avea grupul 'developers'

Setare: chmod g+s dir sau chmod 2755 dir
Verificare: drwxr-sr-x (s în poziția x a group)""",
            tags=["SGID", "director", "partajare"],
            points=3
        ))
        
        # M07: Sticky bit (Medium)
        self.questions.append(Question(
            id="M07",
            category=Category.PERMISSIONS,
            difficulty=Difficulty.MEDIUM,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="""Directorul /tmp are: drwxrwxrwt
Ce înseamnă 't' și ce efect are?""",
            options=[
                "A) Temporary - fișierele se șterg automat",
                "B) Sticky bit - userii pot șterge doar fișierele proprii",
                "C) Trust - toți userii au acces complet",
                "D) Timestamp - se loghează accesul"
            ],
            correct_answer="B",
            explanation="""Sticky bit (t în poziția x a others):

Fără sticky: oricine cu w pe director poate șterge ORICE fișier
Cu sticky: poți șterge doar fișierele unde ești:
  - Ownerul fișierului
  - Ownerul directorului
  - Root

Esențial pentru /tmp unde toți au write:
  - Poți crea fișiere temporare
  - Nimeni nu poate șterge fișierele tale (doar tu sau root)

Setare: chmod +t dir sau chmod 1777 dir
Verificare: drwxrwxrwt""",
            tags=["sticky bit", "/tmp", "securitate"],
            points=2
        ))
        
        # M08: chown (Easy)
        self.questions.append(Question(
            id="M08",
            category=Category.PERMISSIONS,
            difficulty=Difficulty.EASY,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="Ce face comanda: chown user:group file.txt?",
            options=[
                "A) Schimbă permisiunile fișierului",
                "B) Schimbă ownerul la user și grupul la group",
                "C) Copiază fișierul la user în grupul group",
                "D) Verifică dacă user e în grupul group"
            ],
            correct_answer="B",
            explanation="""chown = change owner

Sintaxe:
  chown user file        # schimbă doar owner
  chown user:group file  # schimbă owner și grup
  chown :group file      # schimbă doar grup (sau chgrp)
  chown -R user:group dir # recursiv

⚠️ Doar root poate schimba ownerul!
   Userii normali pot schimba doar grupul (la un grup din care fac parte).""",
            tags=["chown", "owner", "group"],
            points=1
        ))
        
        # M09: chmod simbolic (Medium)
        self.questions.append(Question(
            id="M09",
            category=Category.PERMISSIONS,
            difficulty=Difficulty.MEDIUM,
            question_type=QuestionType.CODE_OUTPUT,
            text="Ce permisiuni rezultă?",
            code_snippet="""# Fișierul începe cu: -rw-r--r-- (644)
chmod u+x,g+w,o-r file.txt
ls -l file.txt""",
            options=[
                "A) -rwxrw---- (760)",
                "B) -rwxrw-r-- (764)",
                "C) -rwxr-xr-x (755)",
                "D) -rwxrw---x (761)"
            ],
            correct_answer="A",
            explanation="""Pornind de la rw-r--r-- (644):

u+x: owner +execute → rwx
g+w: group +write   → rw-
o-r: others -read   → ---

Rezultat: rwxrw---- = 760

Sintaxa chmod simbolic:
  u/g/o/a = user/group/others/all
  +/-/= = add/remove/set exact
  r/w/x = read/write/execute

Poți combina: chmod u=rwx,g=rx,o= file""",
            tags=["chmod", "simbolic"],
            points=2
        ))
        
        # M10: -R vs X (Hard)
        self.questions.append(Question(
            id="M10",
            category=Category.PERMISSIONS,
            difficulty=Difficulty.HARD,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="Care este diferența între aceste două comenzi?",
            code_snippet="""chmod -R a+x /dir
chmod -R a+X /dir""",
            options=[
                "A) Sunt identice",
                "B) x adaugă execute tuturor; X adaugă execute DOAR directoarelor și fișierelor deja executabile",
                "C) X e versiune silențioasă",
                "D) x e recursiv, X nu"
            ],
            correct_answer="B",
            explanation="""X (majusculă) e INTELIGENT pentru x:

a+x: Adaugă execute la TOATE fișierele și directoarele
     → Fișierele text devin executabile (nedorit!)

a+X: Adaugă execute DOAR la:
     - Directoare (au nevoie de x pentru acces)
     - Fișiere care AU DEJA x pentru cineva

Pattern recomandat pentru reparare permisiuni:
  chmod -R u=rwX,g=rX,o=rX /project

Aceasta setează:
  - Directoare: 755
  - Fișiere non-executabile: 644
  - Fișiere executabile: 755""",
            tags=["chmod", "-R", "X majusculă"],
            points=3
        ))
        
        # M11: r fără x pe director (Medium)
        self.questions.append(Question(
            id="M11",
            category=Category.PERMISSIONS,
            difficulty=Difficulty.MEDIUM,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="""Un director are: drw-r----- (640)
Ce se întâmplă când faci: ls /dir ?""",
            options=[
                "A) Listează normal conținutul",
                "B) Listează fișierele dar nu afișează detalii (-l)",
                "C) Afișează erorile pentru fiecare fișier",
                "D) Permission denied"
            ],
            correct_answer="C",
            explanation="""r fără x pe director = situație ciudată!

Poți face ls și vezi NUMELE fișierelor (r = citire listă),
DAR nu poți accesa metadatele lor (x lipsește pentru traversare).

Rezultat: ls -l /dir afișează:
  ls: cannot access '/dir/file1': Permission denied
  ls: cannot access '/dir/file2': Permission denied
  ...dar tot vezi numele fișierelor!

În practică, nu are sens r fără x pe directoare.
Fie dai ambele (rx), fie niciunul (---).""",
            tags=["permisiuni", "director", "r vs x"],
            points=2
        ))
        
        # M12: w pe fișier vs director (Medium)
        self.questions.append(Question(
            id="M12",
            category=Category.PERMISSIONS,
            difficulty=Difficulty.MEDIUM,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="""Fișierul /dir/file.txt are: -r--r--r-- (444)
Directorul /dir/ are: drwxr-xrwx (757)
Poate un user din 'others' să ȘTEARGĂ file.txt?""",
            options=[
                "A) Nu, fișierul e read-only",
                "B) Da, are w pe director",
                "C) Nu, ar avea nevoie de w pe fișier",
                "D) Doar root poate șterge"
            ],
            correct_answer="B",
            explanation="""⚠️ Pentru a ȘTERGE un fișier, ai nevoie de w pe DIRECTOR, 
nu pe fișier!

Ștergerea = modifică directorul (elimină intrarea din directory).
Nu modifici fișierul în sine.

Cu w pe director poți:
- Crea fișiere noi
- Șterge orice fișier (chiar și cele read-only!)
- Redenumi fișiere

Fără w pe fișier, nu poți modifica CONȚINUTUL, 
dar poți șterge fișierul complet.

Sticky bit ('t') previne ștergerea fișierelor altora!""",
            tags=["permisiuni", "w", "ștergere"],
            points=2
        ))
        
        # M13: Calcul octal invers (Easy)
        self.questions.append(Question(
            id="M13",
            category=Category.PERMISSIONS,
            difficulty=Difficulty.EASY,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="Ce permisiuni în octal reprezintă: rwxr-x--x?",
            options=[
                "A) 754",
                "B) 751",
                "C) 745",
                "D) 715"
            ],
            correct_answer="B",
            explanation="""Calcul:
Owner: rwx = 4+2+1 = 7
Group: r-x = 4+0+1 = 5
Others: --x = 0+0+1 = 1

Rezultat: 751

Tabel rapid:
--- = 0    r-- = 4
--x = 1    r-x = 5
-w- = 2    rw- = 6
-wx = 3    rwx = 7""",
            tags=["chmod", "octal", "calcul"],
            points=1
        ))
        
        # M14: Permisiuni speciale în octal (Hard)
        self.questions.append(Question(
            id="M14",
            category=Category.PERMISSIONS,
            difficulty=Difficulty.HARD,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="Ce setează chmod 4755?",
            options=[
                "A) rwxr-xr-x cu SUID",
                "B) rwxr-xr-x cu SGID",
                "C) rwxr-xr-x cu Sticky",
                "D) Eroare - format invalid"
            ],
            correct_answer="A",
            explanation="""Formatul cu 4 cifre: SPECIAL-OWNER-GROUP-OTHERS

Prima cifră (special bits):
4 = SUID  (s în poziția x a owner)
2 = SGID  (s în poziția x a group)
1 = Sticky (t în poziția x a others)

4755:
4 = SUID
755 = rwxr-xr-x

Afișare: -rwsr-xr-x

Combinații posibile:
  6755 = SUID + SGID (4+2)
  1777 = Sticky (pentru /tmp)
  2755 = SGID pe director de proiect""",
            tags=["SUID", "SGID", "sticky", "octal"],
            points=3
        ))
        
        # M15: ACL (Hard)
        self.questions.append(Question(
            id="M15",
            category=Category.PERMISSIONS,
            difficulty=Difficulty.HARD,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="Ce indică '+' la finalul permisiunilor: -rw-r--r--+ ?",
            options=[
                "A) Fișierul are atribute extinse (extended attributes)",
                "B) Fișierul are ACL (Access Control List)",
                "C) Fișierul e comprimat",
                "D) Fișierul e immutable"
            ],
            correct_answer="B",
            explanation="""'+' indică prezența ACL-urilor (Access Control Lists).

ACL permit permisiuni granulare pentru useri/grupuri specifici,
dincolo de owner-group-others.

Comenzi ACL:
  getfacl file        # vezi ACL
  setfacl -m u:john:rw file  # john poate citi/scrie
  setfacl -m g:dev:r file    # grupul dev poate citi
  setfacl -x u:john file     # elimină ACL pentru john
  setfacl -b file            # elimină toate ACL-urile

Pentru atribute extinse ('.' în loc de spațiu) vezi:
  lsattr file
  chattr +i file  # immutable""",
            tags=["ACL", "getfacl", "setfacl"],
            points=3
        ))
    
    # 
    # ÎNTREBĂRI CRON
    # 
    
    def _load_cron_questions(self):
        """Întrebări despre cron și automatizare."""
        
        # C01: Format crontab (Easy)
        self.questions.append(Question(
            id="C01",
            category=Category.CRON,
            difficulty=Difficulty.EASY,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="Care este formatul corect al unei linii crontab?",
            options=[
                "A) comandă minut oră zi lună dow",
                "B) minut oră zi lună dow comandă",
                "C) oră minut zi lună dow comandă",
                "D) dow lună zi oră minut comandă"
            ],
            correct_answer="B",
            explanation="""Formatul crontab (5 câmpuri + comandă):

┌───────────── minut (0-59)
│ ┌─────────── oră (0-23)
│ │ ┌───────── ziua lunii (1-31)
│ │ │ ┌─────── luna (1-12 sau jan-dec)
│ │ │ │ ┌───── ziua săptămânii (0-7, 0=7=Duminică)
│ │ │ │ │
* * * * * comandă

Mnemonice: "Minutes Hours Day-of-month Month Day-of-week"
           sau "M H DOM MON DOW" """,
            tags=["cron", "format", "crontab"],
            points=1
        ))
        
        # C02: */5 (Medium)
        self.questions.append(Question(
            id="C02",
            category=Category.CRON,
            difficulty=Difficulty.MEDIUM,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="Când rulează: */5 * * * * /script.sh?",
            options=[
                "A) La 5 minute după fiecare oră",
                "B) La fiecare 5 minute (0, 5, 10, 15, ...)",
                "C) La fiecare oră, timp de 5 minute",
                "D) La 5 minute după ultima execuție"
            ],
            correct_answer="B",
            explanation="""*/N înseamnă "la fiecare N unități".

*/5 în câmpul minut = la minutele: 0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55

⚠️ NU înseamnă "5 minute după ultima execuție"!
   Cron nu urmărește când a rulat ultima dată.

Alte exemple:
  */15 * * * *    # la fiecare 15 minute
  0 */2 * * *     # la fiecare 2 ore (la minutul 0)
  0 9-17 * * 1-5  # la fiecare oră, 9-17, Lun-Vin""",
            tags=["cron", "*/N", "interval"],
            points=2,
            misconception_addressed="*/5 = 5 minute după ultima execuție"
        ))
        
        # C03: crontab -r (Hard)
        self.questions.append(Question(
            id="C03",
            category=Category.CRON,
            difficulty=Difficulty.HARD,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="⚠️ Ce face comanda: crontab -r?",
            options=[
                "A) Reîncarcă crontab",
                "B) Rulează toate job-urile acum",
                "C) ȘTERGE ÎNTREGUL crontab fără confirmare!",
                "D) Afișează crontab curent"
            ],
            correct_answer="C",
            explanation="""☠️ PERICOL: crontab -r ȘTERGE tot crontab-ul!

Comenzi crontab:
  -e = edit (deschide editor)
  -l = list (afișează)
  -r = REMOVE (șterge TOT, fără confirmare!)
  -i = interactive (cere confirmare pentru -r)

Tastele 'e' și 'r' sunt ADIACENTE pe tastatură!
O greșeală de tastare poate șterge ore de muncă.

🛡️ PROTECȚIE: alias crontab='crontab -i'
   Sau backup regulat: crontab -l > ~/crontab_backup.txt""",
            tags=["crontab", "-r", "pericol"],
            points=3,
            misconception_addressed="crontab -r elimină doar un job"
        ))
        
        # C04: Mediul cron (Hard)
        self.questions.append(Question(
            id="C04",
            category=Category.CRON,
            difficulty=Difficulty.HARD,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="""Un script funcționează perfect din terminal dar 
NU funcționează când e rulat de cron. 
Care este cea mai probabilă cauză?""",
            options=[
                "A) Cron nu poate rula scripturi",
                "B) Cron are un mediu minimal (PATH diferit, fără variabilele tale)",
                "C) Scriptul are permisiuni greșite",
                "D) Cron rulează ca root"
            ],
            correct_answer="B",
            explanation="""⚠️ Cron NU încarcă ~/.bashrc, ~/.profile, etc.!

Mediul cron e MINIMAL:
  PATH=/usr/bin:/bin (mult mai scurt!)
  SHELL=/bin/sh
  HOME setat
  Fără DISPLAY, LANG minimal

SOLUȚII:
1. Folosește căi absolute:
   /usr/bin/python3 /home/user/script.py

2. Definește PATH în crontab:
   PATH=/usr/local/bin:/usr/bin:/bin
   * * * * * script.sh

3. Sourcuiește profilul în script:
   #!/bin/bash
   source ~/.bashrc

4. Wrapper cu login shell:
   * * * * * /bin/bash -l -c '/path/to/script.sh' """,
            tags=["cron", "mediu", "PATH", "debugging"],
            points=3,
            misconception_addressed="Cron are acces la variabilele mele"
        ))
        
        # C05: @reboot (Medium)
        self.questions.append(Question(
            id="C05",
            category=Category.CRON,
            difficulty=Difficulty.MEDIUM,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="Când rulează: @reboot /home/user/startup.sh?",
            options=[
                "A) La fiecare repornire a sistemului",
                "B) La fiecare repornire a serviciului cron",
                "C) O singură dată, la instalare",
                "D) La boot-ul sistemului de operare, nu la restart cron"
            ],
            correct_answer="B",
            explanation="""@reboot rulează când CRON pornește, nu neapărat la boot OS!

În practică, cron pornește la boot, deci efectul e similar.
DAR: dacă restartuiești serviciul cron, job-ul rulează din nou!

String-uri speciale crontab:
  @reboot     - la pornirea cron
  @yearly     - 0 0 1 1 * (1 ianuarie, miezul nopții)
  @monthly    - 0 0 1 * * (prima zi a lunii)
  @weekly     - 0 0 * * 0 (duminică la miezul nopții)
  @daily      - 0 0 * * * (miezul nopții)
  @hourly     - 0 * * * * (la fiecare oră)

@midnight = @daily""",
            tags=["cron", "@reboot", "string-uri speciale"],
            points=2
        ))
        
        # C06: DOM vs DOW (Hard)
        self.questions.append(Question(
            id="C06",
            category=Category.CRON,
            difficulty=Difficulty.HARD,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="Când rulează: 0 9 15 * 1?",
            options=[
                "A) Pe 15 ale lunii, dacă e Luni",
                "B) Pe 15 ale lunii SAU în orice Luni",
                "C) Niciodată - 15 și Luni se exclud",
                "D) Eroare de sintaxă"
            ],
            correct_answer="B",
            explanation="""⚠️ CAPCANĂ CRON: Day-of-month ȘI Day-of-week = SAU!

Dacă AMBELE sunt specificate (nu *), cron folosește OR:
  - Rulează pe data 15 a oricărei luni
  - SAU în orice Luni

Pentru a rula pe 15, DOAR dacă e Luni, ai nevoie de script:
  0 9 15 * * [ "$(date +\\%u)" = 1 ] && /script.sh

Sau cu cron modern (unele implementări):
  0 9 15 * 1  # verifică implementarea!

Aceasta e una dintre cele mai confuze caracteristici cron!""",
            tags=["cron", "DOM", "DOW", "OR"],
            points=3
        ))
        
        # C07: Logging cron (Medium)
        self.questions.append(Question(
            id="C07",
            category=Category.CRON,
            difficulty=Difficulty.MEDIUM,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="Cum redirecționezi CORECT output-ul (inclusiv erori) unui cron job?",
            options=[
                "A) * * * * * /script.sh > /var/log/script.log",
                "B) * * * * * /script.sh >> /var/log/script.log 2>&1",
                "C) * * * * * /script.sh 2>&1 >> /var/log/script.log",
                "D) * * * * * /script.sh &> /var/log/script.log"
            ],
            correct_answer="B",
            explanation="""Redirecționare corectă cu append:

>> = append (> suprascrie)
2>&1 = redirecționează stderr la stdout

⚠️ ORDINEA CONTEAZĂ:
✓ >> file 2>&1  (corect - stderr merge unde e stdout, adică file)
✗ 2>&1 >> file  (greșit - 2>&1 e evaluat înainte, stderr merge la stdout original)

Pattern recomandat cu timestamp:
  * * * * * /script.sh >> /var/log/script.$(date +\\%Y\\%m\\%d).log 2>&1

⚠️ În crontab, % trebuie escape-uit cu \\""",
            tags=["cron", "logging", "redirecționare"],
            points=2
        ))
        
        # C08: at vs cron (Easy)
        self.questions.append(Question(
            id="C08",
            category=Category.CRON,
            difficulty=Difficulty.EASY,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="Care este diferența principală între cron și at?",
            options=[
                "A) cron e pentru root, at pentru useri normali",
                "B) cron e pentru task-uri periodice, at pentru task-uri one-time",
                "C) at e mai rapid decât cron",
                "D) cron suportă scripturi, at doar comenzi simple"
            ],
            correct_answer="B",
            explanation="""cron = task-uri PERIODICE (repetitive)
at = task-uri ONE-TIME (programate pentru un moment specific)

Exemple at:
  at now + 5 minutes
  at 17:00
  at midnight
  at 09:00 tomorrow
  at 15:00 next week

Comenzi at:
  at TIME      # programează (introduce comenzi, Ctrl+D pentru a termina)
  atq          # listează job-uri programate
  atrm ID      # anulează job
  batch        # rulează când sistemul e idle""",
            tags=["cron", "at", "diferențe"],
            points=1
        ))
        
        # C09: Lock files (Hard)
        self.questions.append(Question(
            id="C09",
            category=Category.CRON,
            difficulty=Difficulty.HARD,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="""Un cron job durează uneori 10 minute, dar e programat 
să ruleze la fiecare 5 minute. Ce se poate întâmpla?""",
            options=[
                "A) Cron așteaptă finalizarea înainte de a rula din nou",
                "B) Mai multe instanțe ale scriptului rulează simultan",
                "C) Cron oprește instanța precedentă",
                "D) Cron sare execuțiile suprapuse"
            ],
            correct_answer="B",
            explanation="""⚠️ Cron NU verifică dacă job-ul anterior s-a terminat!

Rezultat: Instanțe multiple rulând simultan = DEZASTRU
  - Corupție date
  - Lock-uri pe resurse
  - Consum excesiv resurse

SOLUȚIA: Lock files!

Cu flock (recomandat):
  * * * * * flock -n /tmp/job.lock /script.sh

Manual în script:
  LOCKFILE=/tmp/myjob.lock
  if [ -f "$LOCKFILE" ]; then
      echo "Already running" >&2
      exit 1
  fi
  trap "rm -f $LOCKFILE" EXIT
  touch "$LOCKFILE"
  # ... rest of script""",
            tags=["cron", "lock file", "flock", "race condition"],
            points=3
        ))
        
        # C10: MAILTO (Medium)
        self.questions.append(Question(
            id="C10",
            category=Category.CRON,
            difficulty=Difficulty.MEDIUM,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="""Ce se întâmplă cu output-ul unui cron job dacă nu e redirecționat?""",
            options=[
                "A) Se pierde",
                "B) Se trimite prin email la userul care deține crontab-ul",
                "C) Se scrie în /var/log/cron",
                "D) Se afișează în terminal"
            ],
            correct_answer="B",
            explanation="""Output-ul cron (stdout + stderr) se trimite prin EMAIL!

Dacă MTA (mail server) e configurat, primești email cu output-ul.
Dacă nu, mesajele se acumulează în /var/mail/user.

Control cu MAILTO în crontab:
  MAILTO=Issues: Open an issue in GitHub    # trimite aici
  MAILTO=""                    # dezactivează email
  
  * * * * * /script.sh

⚠️ BEST PRACTICE: ÎNTOTDEAUNA redirecționează output!
  * * * * * /script.sh >> /var/log/script.log 2>&1

Astfel eviți:
  - Email spam
  - Spațiu de disk consumat de mail queue""",
            tags=["cron", "MAILTO", "email", "output"],
            points=2
        ))
        
        # C11: Interval specific (Medium)
        self.questions.append(Question(
            id="C11",
            category=Category.CRON,
            difficulty=Difficulty.MEDIUM,
            question_type=QuestionType.MULTIPLE_CHOICE,
            text="Cum programezi un job să ruleze doar în zilele lucrătoare (Luni-Vineri)?",
            options=[
                "A) 0 9 * * 1,2,3,4,5",
                "B) 0 9 * * 1-5",
                "C) 0 9 * * Mon-Fri",
                "D) Toate sunt corecte"
            ],
            correct_answer="D",
            explanation="""Toate trei sintaxele sunt echivalente!

Zilele săptămânii: 0-7 (0 și 7 = Duminică)
Sau nume: sun, mon, tue, wed, thu, fri, sat

Sintaxe valide:
  1,2,3,4,5   - enumerare
  1-5         - interval
  Mon-Fri     - nume

Alte exemple:
  0 9 1,15 * *     # pe 1 și 15 ale lunii
  0 9 * 1-6 *      # ianuarie-iunie
  0 */2 * * *      # la fiecare 2 ore
  0 9-17 * * 1-5   # 9-17, Lun-Vin""",
            tags=["cron", "interval", "zilele săptămânii"],
            points=2
        ))
        
        # C12: % în crontab (Hard)
        self.questions.append(Question(
            id="C12",
            category=Category.CRON,
            difficulty=Difficulty.HARD,
            question_type=QuestionType.CODE_OUTPUT,
            text="De ce această linie crontab NU funcționează corect?",
            code_snippet="""# În crontab:
0 0 * * * /script.sh >> /var/log/backup_$(date +%Y%m%d).log 2>&1""",
            options=[
                "A) Sintaxa date e greșită",
                "B) % are semnificație specială în crontab și trebuie escape-uit",
                "C) $(command) nu funcționează în crontab",
                "D) 2>&1 trebuie să fie primul"
            ],
            correct_answer="B",
            explanation="""În crontab, % are semnificație specială:
- Primul % = sfârșitul comenzii, restul devine stdin
- Fiecare % următor = newline în stdin

Trebuie escape-uit cu backslash:
  0 0 * * * /script.sh >> /var/log/backup_$(date +\\%Y\\%m\\%d).log 2>&1

SAU pune comanda într-un script separat:
  0 0 * * * /path/to/backup_with_logging.sh

Scripturi separate sunt de preferat pentru:
  - Evită probleme de escape
  - Mai ușor de testat
  - Versionabile în git""",
            tags=["cron", "%", "escape", "date"],
            points=3
        ))
    
    # 
    # METODE DE FILTRARE ȘI SELECȚIE
    # 
    
    def get_by_category(self, category: Category) -> List[Question]:
        """Returnează întrebările dintr-o categorie."""
        if category == Category.MIXED:
            return self.questions.copy()
        return [q for q in self.questions if q.category == category]
    
    def get_by_difficulty(self, difficulty: Difficulty) -> List[Question]:
        """Returnează întrebările de o anumită dificultate."""
        return [q for q in self.questions if q.difficulty == difficulty]
    
    def get_by_tags(self, tags: List[str]) -> List[Question]:
        """Returnează întrebările care au cel puțin unul din tag-uri."""
        return [q for q in self.questions 
                if any(tag in q.tags for tag in tags)]
    
    def get_random_selection(
        self, 
        count: int, 
        category: Optional[Category] = None,
        difficulty: Optional[Difficulty] = None
    ) -> List[Question]:
        """Selectează întrebări random cu filtre opționale."""
        pool = self.questions.copy()
        
        if category and category != Category.MIXED:
            pool = [q for q in pool if q.category == category]
        
        if difficulty:
            pool = [q for q in pool if q.difficulty == difficulty]
        
        if len(pool) < count:
            return pool
        
        return random.sample(pool, count)
    
    def get_balanced_selection(self, total: int) -> List[Question]:
        """Selectează întrebări balansate pe categorii."""
        categories = [Category.FIND_XARGS, Category.PARAMETERS, 
                     Category.PERMISSIONS, Category.CRON]
        per_category = total // len(categories)
        remainder = total % len(categories)
        
        selected = []
        for i, cat in enumerate(categories):
            count = per_category + (1 if i < remainder else 0)
            pool = self.get_by_category(cat)
            if len(pool) <= count:
                selected.extend(pool)
            else:
                selected.extend(random.sample(pool, count))
        
        random.shuffle(selected)
        return selected
    
    def get_statistics(self) -> Dict[str, Any]:
        """Returnează statistici despre banca de întrebări."""
        stats = {
            'total': len(self.questions),
            'by_category': {},
            'by_difficulty': {},
            'by_type': {}
        }
        
        for cat in Category:
            if cat != Category.MIXED:
                stats['by_category'][cat.value] = len(self.get_by_category(cat))
        
        for diff in Difficulty:
            stats['by_difficulty'][diff.value] = len(self.get_by_difficulty(diff))
        
        for qtype in QuestionType:
            count = len([q for q in self.questions if q.question_type == qtype])
            if count > 0:
                stats['by_type'][qtype.value] = count
        
        return stats

# 
# CLASA QUIZ
# 

class Quiz:
    """Gestionează un quiz individual."""
    
    def __init__(
        self, 
        questions: List[Question],
        title: str = "Quiz SEM03",
        time_limit_minutes: Optional[int] = None,
        use_color: bool = True
    ):
        self.questions = questions
        self.title = title
        self.time_limit = time_limit_minutes * 60 if time_limit_minutes else None
        self.use_color = use_color
        self.start_time: Optional[float] = None
        self.answers: Dict[str, str] = {}
        self.current_index = 0
    
    def run_interactive(self) -> QuizResult:
        """Rulează quiz-ul interactiv în terminal."""
        self._print_header()
        self.start_time = time.time()
        
        for i, question in enumerate(self.questions):
            self.current_index = i
            if not self._ask_question(question, i + 1):
                # User quit
                break
        
        return self._calculate_result()
    
    def _print_header(self):
        """Afișează header-ul quiz-ului."""
        print("\n" + "═" * 70)
        print(color_text(f"  🎯 {self.title}", Colors.BOLD + Colors.CYAN, self.use_color))
        print(f"  📊 {len(self.questions)} întrebări")
        if self.time_limit:
            print(f"  ⏱️  Timp: {self.time_limit // 60} minute")
        print("═" * 70)
        print(color_text("\n  Instrucțiuni:", Colors.YELLOW, self.use_color))
        print("  • Introdu litera răspunsului (A, B, C, D)")
        print("  • 's' = skip (sări peste întrebare)")
        print("  • 'q' = quit (ieși din quiz)")
        print("  • 'h' = hint (afișează indiciu)")
        input(color_text("\n  Apasă ENTER pentru a începe...", Colors.GREEN, self.use_color))
    
    def _ask_question(self, q: Question, num: int) -> bool:
        """Afișează și procesează o întrebare. Returnează False dacă user quit."""
        os.system('clear' if os.name == 'posix' else 'cls')
        
        # Header întrebare
        diff_color = {
            Difficulty.EASY: Colors.GREEN,
            Difficulty.MEDIUM: Colors.YELLOW,
            Difficulty.HARD: Colors.RED
        }[q.difficulty]
        
        cat_emoji = {
            Category.FIND_XARGS: "🔍",
            Category.PARAMETERS: "📝",
            Category.PERMISSIONS: "🔒",
            Category.CRON: "⏰"
        }.get(q.category, "📋")
        
        print("\n" + "─" * 70)
        print(f"  Întrebarea {num}/{len(self.questions)} | "
              f"{cat_emoji} {q.category.value.upper()} | "
              f"{color_text(q.difficulty.value.upper(), diff_color, self.use_color)} | "
              f"{q.points} punct{'e' if q.points > 1 else ''}")
        print("─" * 70)
        
        # Textul întrebării
        print(f"\n{color_text(q.text, Colors.BOLD, self.use_color)}")
        
        # Codul (dacă există)
        if q.code_snippet:
            print(color_text("\n┌─ Cod ─────────────────────────────────────────", Colors.CYAN, self.use_color))
            for line in q.code_snippet.strip().split('\n'):
                print(f"│ {line}")
            print(color_text("└───────────────────────────────────────────────────", Colors.CYAN, self.use_color))
        
        # Opțiunile
        print()
        for opt in q.options:
            print(f"  {opt}")
        print()
        
        # Input
        while True:
            try:
                answer = input(color_text("  Răspunsul tău: ", Colors.YELLOW, self.use_color)).strip().upper()
            except (EOFError, KeyboardInterrupt):
                return False
            
            if answer == 'Q':
                confirm = input("  Sigur vrei să ieși? (y/n): ").strip().lower()
                if confirm == 'y':
                    return False
                continue
            
            if answer == 'S':
                self.answers[q.id] = 'SKIP'
                return True
            
            if answer == 'H':
                self._show_hint(q)
                continue
            
            if answer in ['A', 'B', 'C', 'D']:
                self.answers[q.id] = answer
                self._show_feedback(q, answer)
                input(color_text("\n  Apasă ENTER pentru a continua...", Colors.CYAN, self.use_color))
                return True
            
            print(color_text("  ⚠️  Răspuns invalid! Folosește A, B, C, D, s, q sau h", 
                           Colors.RED, self.use_color))
    
    def _show_hint(self, q: Question):
        """Afișează indiciu pentru întrebare."""
        hints = []
        
        if q.misconception_addressed:
            hints.append(f"💡 Misconceptie comună: {q.misconception_addressed}")
        
        if q.tags:
            hints.append(f"🏷️  Concepte: {', '.join(q.tags[:3])}")
        
        if hints:
            print(color_text("\n  ─── Indicii ───", Colors.YELLOW, self.use_color))
            for h in hints:
                print(f"  {h}")
        else:
            print(color_text("  Nu sunt indicii disponibile pentru această întrebare.", 
                           Colors.YELLOW, self.use_color))
    
    def _show_feedback(self, q: Question, answer: str):
        """Afișează feedback după răspuns."""
        is_correct = answer == q.correct_answer
        
        print()
        if is_correct:
            print(color_text("  ✅ CORECT!", Colors.GREEN + Colors.BOLD, self.use_color))
        else:
            print(color_text(f"  ❌ INCORECT! Răspunsul corect: {q.correct_answer}", 
                           Colors.RED + Colors.BOLD, self.use_color))
        
        print(color_text("\n  📖 Explicație:", Colors.CYAN, self.use_color))
        # Wrap explanation text
        for line in q.explanation.strip().split('\n'):
            wrapped = textwrap.wrap(line, width=60)
            for w in wrapped:
                print(f"     {w}")
    
    def _calculate_result(self) -> QuizResult:
        """Calculează rezultatul final."""
        end_time = time.time()
        time_taken = end_time - self.start_time if self.start_time else 0
        
        correct = 0
        wrong = 0
        skipped = 0
        total_points = 0
        earned_points = 0
        question_results = []
        categories_breakdown = {}
        
        for q in self.questions:
            total_points += q.points
            answer = self.answers.get(q.id, 'SKIP')
            
            # Init category breakdown
            cat = q.category.value
            if cat not in categories_breakdown:
                categories_breakdown[cat] = {'correct': 0, 'wrong': 0, 'skipped': 0}
            
            result = {
                'question_id': q.id,
                'question_text': q.text[:100] + '...' if len(q.text) > 100 else q.text,
                'user_answer': answer,
                'correct_answer': q.correct_answer,
                'is_correct': False,
                'points_earned': 0,
                'points_possible': q.points
            }
            
            if answer == 'SKIP':
                skipped += 1
                categories_breakdown[cat]['skipped'] += 1
            elif answer == q.correct_answer:
                correct += 1
                earned_points += q.points
                result['is_correct'] = True
                result['points_earned'] = q.points
                categories_breakdown[cat]['correct'] += 1
            else:
                wrong += 1
                categories_breakdown[cat]['wrong'] += 1
            
            question_results.append(result)
        
        score_pct = (earned_points / total_points * 100) if total_points > 0 else 0
        
        return QuizResult(
            total_questions=len(self.questions),
            correct_answers=correct,
            wrong_answers=wrong,
            skipped=skipped,
            score_percentage=score_pct,
            time_taken_seconds=time_taken,
            questions_results=question_results,
            categories_breakdown=categories_breakdown
        )
    
    def export_to_html(self, filepath: str):
        """Exportă quiz-ul ca HTML interactiv."""
        html_content = self._generate_html()
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(html_content)
    
    def _generate_html(self) -> str:
        """Generează HTML pentru quiz."""
        questions_json = json.dumps([q.to_dict() for q in self.questions], ensure_ascii=False)
        
        return f'''<!DOCTYPE html>
<html lang="ro">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{html.escape(self.title)}</title>
    <style>
        * {{ box-sizing: border-box; margin: 0; padding: 0; }}
        body {{ 
            font-family: 'Segoe UI', Tahoma, sans-serif; 
            background: linear-gradient(135deg, #1a1a2e, #16213e);
            min-height: 100vh;
            color: #eee;
            padding: 20px;
        }}
        .container {{ max-width: 800px; margin: 0 auto; }}
        .header {{
            text-align: center;
            padding: 30px;
            background: rgba(255,255,255,0.05);
            border-radius: 20px;
            margin-bottom: 30px;
        }}
        .header h1 {{ color: #00d4ff; margin-bottom: 10px; }}
        .question-card {{
            background: rgba(255,255,255,0.1);
            border-radius: 15px;
            padding: 25px;
            margin-bottom: 20px;
            display: none;
        }}
        .question-card.active {{ display: block; }}
        .question-meta {{
            display: flex;
            gap: 15px;
            margin-bottom: 15px;
            font-size: 0.9em;
        }}
        .badge {{
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 0.8em;
        }}
        .badge-easy {{ background: #2ecc71; }}
        .badge-medium {{ background: #f39c12; }}
        .badge-hard {{ background: #e74c3c; }}
        .question-text {{ font-size: 1.2em; margin-bottom: 20px; line-height: 1.6; }}
        .code-block {{
            background: #1e1e1e;
            padding: 15px;
            border-radius: 8px;
            font-family: 'Consolas', monospace;
            margin: 15px 0;
            overflow-x: auto;
            white-space: pre;
        }}
        .options {{ display: flex; flex-direction: column; gap: 10px; }}
        .option {{
            padding: 15px 20px;
            background: rgba(255,255,255,0.05);
            border: 2px solid transparent;
            border-radius: 10px;
            cursor: pointer;
            transition: all 0.3s;
        }}
        .option:hover {{ background: rgba(0,212,255,0.1); border-color: #00d4ff; }}
        .option.selected {{ border-color: #00d4ff; background: rgba(0,212,255,0.2); }}
        .option.correct {{ border-color: #2ecc71; background: rgba(46,204,113,0.2); }}
        .option.wrong {{ border-color: #e74c3c; background: rgba(231,76,60,0.2); }}
        .feedback {{
            margin-top: 20px;
            padding: 20px;
            border-radius: 10px;
            display: none;
        }}
        .feedback.show {{ display: block; }}
        .feedback.correct {{ background: rgba(46,204,113,0.2); border-left: 4px solid #2ecc71; }}
        .feedback.wrong {{ background: rgba(231,76,60,0.2); border-left: 4px solid #e74c3c; }}
        .nav-buttons {{
            display: flex;
            justify-content: space-between;
            margin-top: 20px;
        }}
        .btn {{
            padding: 12px 30px;
            border: none;
            border-radius: 25px;
            cursor: pointer;
            font-size: 1em;
            transition: transform 0.2s;
        }}
        .btn:hover {{ transform: scale(1.05); }}
        .btn-primary {{ background: #00d4ff; color: #1a1a2e; }}
        .btn-secondary {{ background: rgba(255,255,255,0.2); color: #fff; }}
        .progress {{
            height: 8px;
            background: rgba(255,255,255,0.1);
            border-radius: 4px;
            margin-bottom: 30px;
        }}
        .progress-bar {{
            height: 100%;
            background: linear-gradient(90deg, #00d4ff, #00ff88);
            border-radius: 4px;
            transition: width 0.3s;
        }}
        .results {{
            text-align: center;
            padding: 40px;
            display: none;
        }}
        .results.show {{ display: block; }}
        .score {{
            font-size: 4em;
            font-weight: bold;
            background: linear-gradient(135deg, #00d4ff, #00ff88);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }}
        .stats {{ display: flex; justify-content: center; gap: 40px; margin: 30px 0; }}
        .stat {{ text-align: center; }}
        .stat-value {{ font-size: 2em; font-weight: bold; }}
        .stat-label {{ color: #888; }}
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🎯 {html.escape(self.title)}</h1>
            <p>{len(self.questions)} întrebări</p>
        </div>
        
        <div class="progress">
            <div class="progress-bar" id="progressBar" style="width: 0%"></div>
        </div>
        
        <div id="quizContainer"></div>
        
        <div class="results" id="results">
            <h2>🏆 Rezultate</h2>
            <div class="score" id="scoreValue">0%</div>
            <p id="gradeText">Nota estimată: -</p>
            <div class="stats">
                <div class="stat">
                    <div class="stat-value" id="correctCount">0</div>
                    <div class="stat-label">✅ Corecte</div>
                </div>
                <div class="stat">
                    <div class="stat-value" id="wrongCount">0</div>
                    <div class="stat-label">❌ Greșite</div>
                </div>
                <div class="stat">
                    <div class="stat-value" id="timeSpent">0:00</div>
                    <div class="stat-label">⏱️ Timp</div>
                </div>
            </div>
            <button class="btn btn-primary" onclick="restartQuiz()">🔄 Încearcă din nou</button>
        </div>
    </div>
    
    <script>
        const questions = {questions_json};
        let currentQuestion = 0;
        let answers = {{}};
        let startTime = Date.now();
        
        function initQuiz() {{
            const container = document.getElementById('quizContainer');
            questions.forEach((q, index) => {{
                const card = document.createElement('div');
                card.className = 'question-card' + (index === 0 ? ' active' : '');
                card.id = 'q' + index;
                
                const diffClass = 'badge-' + q.difficulty;
                const catEmoji = {{
                    'find_xargs': '🔍',
                    'parameters': '📝', 
                    'permissions': '🔒',
                    'cron': '⏰'
                }}[q.category] || '📋';
                
                let codeHtml = '';
                if (q.code_snippet) {{
                    codeHtml = '<div class="code-block">' + escapeHtml(q.code_snippet) + '</div>';
                }}
                
                let optionsHtml = q.options.map((opt, i) => 
                    `<div class="option" data-answer="${{String.fromCharCode(65+i)}}" onclick="selectOption(this, ${{index}})">${{escapeHtml(opt)}}</div>`
                ).join('');
                
                card.innerHTML = `
                    <div class="question-meta">
                        <span class="badge ${{diffClass}}">${{q.difficulty.toUpperCase()}}</span>
                        <span>${{catEmoji}} ${{q.category.replace('_', ' ').toUpperCase()}}</span>
                        <span>📊 ${{q.points}} punct${{q.points > 1 ? 'e' : ''}}</span>
                    </div>
                    <div class="question-text">${{escapeHtml(q.text)}}</div>
                    ${{codeHtml}}
                    <div class="options">${{optionsHtml}}</div>
                    <div class="feedback" id="feedback${{index}}">
                        <strong id="feedbackTitle${{index}}"></strong>
                        <p id="feedbackText${{index}}"></p>
                    </div>
                    <div class="nav-buttons">
                        <button class="btn btn-secondary" onclick="prevQuestion()" ${{index === 0 ? 'disabled' : ''}}>← Înapoi</button>
                        <button class="btn btn-primary" id="nextBtn${{index}}" onclick="nextQuestion()" disabled>
                            ${{index === questions.length - 1 ? 'Finalizează' : 'Următoarea →'}}
                        </button>
                    </div>
                `;
                container.appendChild(card);
            }});
            updateProgress();
        }}
        
        function escapeHtml(text) {{
            const div = document.createElement('div');
            div.textContent = text;
            return div.innerHTML;
        }}
        
        function selectOption(element, qIndex) {{
            const card = document.getElementById('q' + qIndex);
            const options = card.querySelectorAll('.option');
            const answered = answers[qIndex] !== undefined;
            
            if (answered) return;
            
            options.forEach(o => o.classList.remove('selected'));
            element.classList.add('selected');
            
            const answer = element.dataset.answer;
            answers[qIndex] = answer;
            
            const q = questions[qIndex];
            const isCorrect = answer === q.correct_answer;
            
            options.forEach(o => {{
                if (o.dataset.answer === q.correct_answer) o.classList.add('correct');
                else if (o.dataset.answer === answer) o.classList.add('wrong');
            }});
            
            const feedback = document.getElementById('feedback' + qIndex);
            const title = document.getElementById('feedbackTitle' + qIndex);
            const text = document.getElementById('feedbackText' + qIndex);
            
            feedback.className = 'feedback show ' + (isCorrect ? 'correct' : 'wrong');
            title.textContent = isCorrect ? '✅ Corect!' : '❌ Răspuns greșit: ' + q.correct_answer;
            text.textContent = q.explanation;
            
            document.getElementById('nextBtn' + qIndex).disabled = false;
        }}
        
        function nextQuestion() {{
            if (currentQuestion < questions.length - 1) {{
                document.getElementById('q' + currentQuestion).classList.remove('active');
                currentQuestion++;
                document.getElementById('q' + currentQuestion).classList.add('active');
                updateProgress();
            }} else {{
                showResults();
            }}
        }}
        
        function prevQuestion() {{
            if (currentQuestion > 0) {{
                document.getElementById('q' + currentQuestion).classList.remove('active');
                currentQuestion--;
                document.getElementById('q' + currentQuestion).classList.add('active');
                updateProgress();
            }}
        }}
        
        function updateProgress() {{
            const progress = ((currentQuestion + 1) / questions.length) * 100;
            document.getElementById('progressBar').style.width = progress + '%';
        }}
        
        function showResults() {{
            document.getElementById('quizContainer').style.display = 'none';
            
            let correct = 0;
            let totalPoints = 0;
            let earnedPoints = 0;
            
            questions.forEach((q, i) => {{
                totalPoints += q.points;
                if (answers[i] === q.correct_answer) {{
                    correct++;
                    earnedPoints += q.points;
                }}
            }});
            
            const score = Math.round((earnedPoints / totalPoints) * 100);
            const wrong = questions.length - correct;
            const timeSpent = Math.floor((Date.now() - startTime) / 1000);
            const minutes = Math.floor(timeSpent / 60);
            const seconds = timeSpent % 60;
            
            let grade = '4';
            if (score >= 90) grade = '10';
            else if (score >= 80) grade = '9';
            else if (score >= 70) grade = '8';
            else if (score >= 60) grade = '7';
            else if (score >= 50) grade = '6';
            else if (score >= 40) grade = '5';
            
            document.getElementById('scoreValue').textContent = score + '%';
            document.getElementById('gradeText').textContent = 'Nota estimată: ' + grade;
            document.getElementById('correctCount').textContent = correct;
            document.getElementById('wrongCount').textContent = wrong;
            document.getElementById('timeSpent').textContent = minutes + ':' + String(seconds).padStart(2, '0');
            
            document.getElementById('results').classList.add('show');
        }}
        
        function restartQuiz() {{
            answers = {{}};
            currentQuestion = 0;
            startTime = Date.now();
            document.getElementById('results').classList.remove('show');
            document.getElementById('quizContainer').style.display = 'block';
            document.getElementById('quizContainer').innerHTML = '';
            initQuiz();
        }}
        
        initQuiz();
    </script>
</body>
</html>'''
    
    def export_to_json(self, filepath: str):
        """Exportă quiz-ul ca JSON."""
        data = {
            'title': self.title,
            'generated_at': datetime.now().isoformat(),
            'total_questions': len(self.questions),
            'time_limit_minutes': self.time_limit // 60 if self.time_limit else None,
            'questions': [q.to_dict() for q in self.questions]
        }
        
        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
    
    def export_to_markdown(self, filepath: str, with_answers: bool = False):
        """Exportă quiz-ul ca Markdown."""
        lines = [
            f"# 🎯 {self.title}\n",
            f"**Total întrebări**: {len(self.questions)}",
            f"**Generat**: {datetime.now().strftime('%Y-%m-%d %H:%M')}\n",
            "---\n"
        ]
        
        for i, q in enumerate(self.questions, 1):
            diff_emoji = {'easy': '🟢', 'medium': '🟡', 'hard': '🔴'}[q.difficulty.value]
            cat_emoji = {
                'find_xargs': '🔍',
                'parameters': '📝',
                'permissions': '🔒',
                'cron': '⏰'
            }.get(q.category.value, '📋')
            
            lines.append(f"## Întrebarea {i}\n")
            lines.append(f"**{diff_emoji} {q.difficulty.value.title()}** | "
                        f"**{cat_emoji} {q.category.value.replace('_', ' ').title()}** | "
                        f"**{q.points} punct{'e' if q.points > 1 else ''}**\n")
            lines.append(f"{q.text}\n")
            
            if q.code_snippet:
                lines.append("```bash")
                lines.append(q.code_snippet)
                lines.append("```\n")
            
            for opt in q.options:
                lines.append(f"- [ ] {opt}")
            lines.append("")
            
            if with_answers:
                lines.append(f"<details>")
                lines.append(f"<summary>🔑 Răspuns</summary>\n")
                lines.append(f"**Răspuns corect: {q.correct_answer}**\n")
                lines.append(f"{q.explanation}")
                lines.append(f"</details>\n")
            
            lines.append("---\n")
        
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write('\n'.join(lines))

# 
# INTERFAȚA DE LINIE DE COMANDĂ
# 

def print_banner(use_color: bool = True):
    """Afișează banner-ul programului."""
    banner = r"""
    ╔══════════════════════════════════════════════════════════════════╗
    ║       ___        _       _____                          _        ║
    ║      / _ \ _   _(_)____ / ____|  ___ _ __   ___ _ __ __ _| |_ ___  ║
    ║     | | | | | | | |_  / |  ___ / _ \ '_ \ / _ \ '__/ _` | __/ _ \ ║
    ║     | |_| | |_| | |/ /  | |_| |  __/ | | |  __/ | | (_| | || (_) |║
    ║      \__\_\\__,_|_/___|  \_____|\___|_| |_|\___|_|  \__,_|\__\___/ ║
    ║                                                                  ║
    ║              Seminar 3: Find, Permisiuni, Cron                 ║
    ╚══════════════════════════════════════════════════════════════════╝
    """
    print(color_text(banner, Colors.CYAN, use_color))

def print_statistics(bank: QuestionBank, use_color: bool = True):
    """Afișează statistici despre banca de întrebări."""
    stats = bank.get_statistics()
    
    print(color_text("\n📊 Statistici Bancă de Întrebări", Colors.BOLD + Colors.CYAN, use_color))
    print("═" * 50)
    print(f"  Total întrebări: {color_text(str(stats['total']), Colors.GREEN, use_color)}")
    
    print(color_text("\n  Pe categorii:", Colors.YELLOW, use_color))
    cat_emojis = {
        'find_xargs': '🔍',
        'parameters': '📝',
        'permissions': '🔒',
        'cron': '⏰'
    }
    for cat, count in stats['by_category'].items():
        emoji = cat_emojis.get(cat, '📋')
        print(f"    {emoji} {cat:15} : {count:3}")
    
    print(color_text("\n  Pe dificultate:", Colors.YELLOW, use_color))
    diff_colors = {'easy': Colors.GREEN, 'medium': Colors.YELLOW, 'hard': Colors.RED}
    for diff, count in stats['by_difficulty'].items():
        print(f"    {color_text(diff.ljust(8), diff_colors.get(diff, ''), use_color)} : {count:3}")

def print_result(result: QuizResult, use_color: bool = True):
    """Afișează rezultatul quiz-ului."""
    os.system('clear' if os.name == 'posix' else 'cls')
    
    print("\n" + "═" * 70)
    print(color_text("  🏆 REZULTATE FINALE", Colors.BOLD + Colors.CYAN, use_color))
    print("═" * 70)
    
    # Scor mare
    score_color = Colors.GREEN if result.score_percentage >= 60 else Colors.RED
    print(color_text(f"\n  Scor: {result.score_percentage:.1f}%", 
                    Colors.BOLD + score_color, use_color))
    print(color_text(f"  Nota estimată: {result.grade}", Colors.BOLD, use_color))
    
    # Statistici
    minutes = int(result.time_taken_seconds // 60)
    seconds = int(result.time_taken_seconds % 60)
    
    print(f"\n  ✅ Corecte:  {result.correct_answers}")
    print(f"  ❌ Greșite:  {result.wrong_answers}")
    print(f"  ⏭️  Sărite:   {result.skipped}")
    print(f"  ⏱️  Timp:     {minutes}:{seconds:02d}")
    
    # Breakdown pe categorii
    print(color_text("\n  📊 Pe categorii:", Colors.YELLOW, use_color))
    for cat, data in result.categories_breakdown.items():
        total = data['correct'] + data['wrong'] + data['skipped']
        if total > 0:
            pct = data['correct'] / total * 100
            bar_len = int(pct / 5)
            bar = "█" * bar_len + "░" * (20 - bar_len)
            print(f"    {cat:15} [{bar}] {pct:5.1f}%")
    
    print("\n" + "═" * 70)

def main():
    """Funcția principală."""
    parser = argparse.ArgumentParser(
        description='Generator de Quiz-uri pentru Seminarul 03 SO',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog='''
Exemple:
  %(prog)s --interactive                    # Quiz interactiv cu 10 întrebări
  %(prog)s --generate 15 --difficulty hard  # Quiz hard cu 15 întrebări
  %(prog)s --category permissions --count 5 # Quiz doar permisiuni
  %(prog)s --export quiz.html               # Exportă ca HTML interactiv
  %(prog)s --stats                          # Afișează statistici
        '''
    )
    
    parser.add_argument('--interactive', '-i', action='store_true',
                       help='Pornește quiz interactiv în terminal')
    parser.add_argument('--generate', '-g', type=int, metavar='N',
                       help='Generează quiz cu N întrebări')
    parser.add_argument('--count', '-c', type=int, default=10,
                       help='Numărul de întrebări (default: 10)')
    parser.add_argument('--category', '-cat', 
                       choices=['find_xargs', 'parameters', 'permissions', 'cron', 'mixed'],
                       default='mixed',
                       help='Categoria de întrebări')
    parser.add_argument('--difficulty', '-d',
                       choices=['easy', 'medium', 'hard'],
                       help='Filtrează după dificultate')
    parser.add_argument('--balanced', '-b', action='store_true',
                       help='Selectează echilibrat din toate categoriile')
    parser.add_argument('--export', '-e', metavar='FILE',
                       help='Exportă quiz (format detectat din extensie: .html, .json, .md)')
    parser.add_argument('--with-answers', '-a', action='store_true',
                       help='Include răspunsurile în export Markdown')
    parser.add_argument('--stats', '-s', action='store_true',
                       help='Afișează statistici despre banca de întrebări')
    parser.add_argument('--list-questions', '-l', action='store_true',
                       help='Listează toate întrebările')
    parser.add_argument('--no-color', action='store_true',
                       help='Dezactivează culorile în terminal')
    parser.add_argument('--version', '-v', action='version',
                       version=f'{PROGRAM_NAME} v{VERSION}')
    
    args = parser.parse_args()
    use_color = not args.no_color
    
    # Inițializează banca de întrebări
    bank = QuestionBank()
    
    # Afișează statistici
    if args.stats:
        print_banner(use_color)
        print_statistics(bank, use_color)
        return 0
    
    # Listează întrebările
    if args.list_questions:
        print_banner(use_color)
        for q in bank.questions:
            diff_color = {
                Difficulty.EASY: Colors.GREEN,
                Difficulty.MEDIUM: Colors.YELLOW,
                Difficulty.HARD: Colors.RED
            }[q.difficulty]
            print(f"[{q.id}] {color_text(q.difficulty.value[:1].upper(), diff_color, use_color)} "
                  f"{q.category.value:12} | {q.text[:60]}...")
        print(f"\nTotal: {len(bank.questions)} întrebări")
        return 0
    
    # Selectează întrebări
    count = args.generate if args.generate else args.count
    category = Category(args.category)
    difficulty = Difficulty(args.difficulty) if args.difficulty else None
    
    if args.balanced:
        questions = bank.get_balanced_selection(count)
    else:
        questions = bank.get_random_selection(count, category, difficulty)
    
    if not questions:
        print(color_text("❌ Nu s-au găsit întrebări cu filtrele specificate!", 
                        Colors.RED, use_color))
        return 1
    
    # Creează quiz-ul
    title = f"Quiz SEM03: {category.value.replace('_', ' ').title()}"
    quiz = Quiz(questions, title, use_color=use_color)
    
    # Export
    if args.export:
        ext = os.path.splitext(args.export)[1].lower()
        if ext == '.html':
            quiz.export_to_html(args.export)
            print(f"✅ Quiz exportat în {args.export}")
        elif ext == '.json':
            quiz.export_to_json(args.export)
            print(f"✅ Quiz exportat în {args.export}")
        elif ext == '.md':
            quiz.export_to_markdown(args.export, args.with_answers)
            print(f"✅ Quiz exportat în {args.export}")
        else:
            print(f"❌ Format necunoscut: {ext}")
            return 1
        return 0
    
    # Quiz interactiv
    if args.interactive or args.generate:
        print_banner(use_color)
        result = quiz.run_interactive()
        print_result(result, use_color)
        
        # Oferă să salveze rezultatele
        save = input("\n  Salvează rezultatele? (y/n): ").strip().lower()
        if save == 'y':
            filename = f"quiz_result_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
            with open(filename, 'w', encoding='utf-8') as f:
                json.dump({
                    'score_percentage': result.score_percentage,
                    'grade': result.grade,
                    'correct': result.correct_answers,
                    'wrong': result.wrong_answers,
                    'skipped': result.skipped,
                    'time_seconds': result.time_taken_seconds,
                    'categories': result.categories_breakdown,
                    'questions': result.questions_results
                }, f, ensure_ascii=False, indent=2)
            print(f"  ✅ Rezultate salvate în {filename}")
        
        return 0
    
    # Default: arată help
    parser.print_help()
    return 0

if __name__ == '__main__':
    sys.exit(main())
