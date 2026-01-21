#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
═══════════════════════════════════════════════════════════════════════════════
📝 S02_02_quiz_generator.py - Generator Quiz-uri Personalizate
═══════════════════════════════════════════════════════════════════════════════

DESCRIERE:
    Generator de quiz-uri unice pentru fiecare student.
    Randomizează întrebări și variante de răspuns pentru a preveni copiatul.
    Exportă în multiple formate: TXT, HTML, JSON, PDF-ready Markdown.

UTILIZARE:
    python3 S02_02_quiz_generator.py --students lista.txt --output ./quiz_output/
    python3 S02_02_quiz_generator.py --student "Popescu Ion" --grupa 1051
    python3 S02_02_quiz_generator.py --count 30 --format html --seed 42

AUTOR: Assistant pentru ASE București - CSIE
VERSIUNE: 1.0
DATA: Ianuarie 2025
═══════════════════════════════════════════════════════════════════════════════
"""

import argparse
import json
import random
import hashlib
import os
import sys
from dataclasses import dataclass, field, asdict
from typing import List, Dict, Optional, Tuple
from datetime import datetime
from pathlib import Path
import html
import re

# 
# SECȚIUNEA 1: STRUCTURI DE DATE
# 

@dataclass
class Question:
    """Structură pentru o întrebare de quiz."""
    id: str
    category: str  # operators, redirection, filters, loops
    difficulty: str  # easy, medium, hard
    question_text: str
    code_block: Optional[str]
    options: List[str]
    correct_index: int
    explanation: str
    misconception_targeted: Optional[str] = None
    
    def get_shuffled_options(self, seed: int) -> Tuple[List[str], int]:
        """Returnează opțiunile amestecate și noul index corect."""
        rng = random.Random(seed)
        indexed_options = list(enumerate(self.options))
        rng.shuffle(indexed_options)
        new_correct = next(i for i, (orig_i, _) in enumerate(indexed_options) 
                         if orig_i == self.correct_index)
        return [opt for _, opt in indexed_options], new_correct

@dataclass
class Quiz:
    """Structură pentru un quiz complet."""
    student_name: str
    student_group: str
    quiz_id: str
    generated_at: str
    questions: List[Dict]
    seed: int
    total_points: int = 100
    time_limit_minutes: int = 30

@dataclass
class QuestionBank:
    """Bancă de întrebări organizată pe categorii și dificultăți."""
    questions: List[Question] = field(default_factory=list)
    
    def add(self, q: Question):
        self.questions.append(q)
    
    def filter_by(self, category: Optional[str] = None, 
                  difficulty: Optional[str] = None) -> List[Question]:
        result = self.questions
        if category:
            result = [q for q in result if q.category == category]
        if difficulty:
            result = [q for q in result if q.difficulty == difficulty]
        return result
    
    def get_balanced_selection(self, count: int, seed: int) -> List[Question]:
        """Selectează întrebări echilibrat pe categorii și dificultăți."""
        rng = random.Random(seed)
        
        # Distribuție țintă
        categories = ['operators', 'redirection', 'filters', 'loops']
        difficulties = {'easy': 0.3, 'medium': 0.5, 'hard': 0.2}
        
        selected = []
        per_category = count // len(categories)
        remainder = count % len(categories)
        
        for cat in categories:
            cat_questions = self.filter_by(category=cat)
            if not cat_questions:
                continue
                
            # Selectează proporțional pe dificultăți
            cat_count = per_category + (1 if remainder > 0 else 0)
            remainder -= 1
            
            easy = [q for q in cat_questions if q.difficulty == 'easy']
            medium = [q for q in cat_questions if q.difficulty == 'medium']
            hard = [q for q in cat_questions if q.difficulty == 'hard']
            
            target_easy = int(cat_count * difficulties['easy'])
            target_medium = int(cat_count * difficulties['medium'])
            target_hard = cat_count - target_easy - target_medium
            
            rng.shuffle(easy)
            rng.shuffle(medium)
            rng.shuffle(hard)
            
            selected.extend(easy[:target_easy])
            selected.extend(medium[:target_medium])
            selected.extend(hard[:target_hard])
        
        # Completează dacă nu avem destule
        if len(selected) < count:
            remaining = [q for q in self.questions if q not in selected]
            rng.shuffle(remaining)
            selected.extend(remaining[:count - len(selected)])
        
        rng.shuffle(selected)
        return selected[:count]

# 
# SECȚIUNEA 2: BANCA DE ÎNTREBĂRI
# 

def create_question_bank() -> QuestionBank:
    """Creează banca de întrebări pentru Seminarul 3-4."""
    bank = QuestionBank()
    
    # 
    # CATEGORIA: OPERATORI DE CONTROL
    # 
    
    bank.add(Question(
        id="OP001",
        category="operators",
        difficulty="easy",
        question_text="Ce se întâmplă când executăm: `mkdir test && echo 'OK'` dacă directorul 'test' EXISTĂ deja?",
        code_block="mkdir test && echo 'OK'",
        options=[
            "Se afișează 'OK'",
            "Se afișează eroare de la mkdir, dar NU se afișează 'OK'",
            "Se afișează eroare de la mkdir ȘI se afișează 'OK'",
            "Comanda eșuează silențios fără niciun output"
        ],
        correct_index=1,
        explanation="Operatorul && execută comanda din dreapta DOAR dacă comanda din stânga reușește (exit code 0). mkdir eșuează când directorul există, deci echo nu se execută.",
        misconception_targeted="M1.1: && și ; sunt echivalente"
    ))
    
    bank.add(Question(
        id="OP002",
        category="operators",
        difficulty="easy",
        question_text="Care este diferența principală între `;` și `&&`?",
        code_block=None,
        options=[
            "; execută secvențial indiferent de succes, && execută a doua comandă doar dacă prima reușește",
            "; execută în paralel, && execută secvențial",
            "Nu există diferență, sunt echivalente",
            "; este pentru scripturi, && este pentru linia de comandă"
        ],
        correct_index=0,
        explanation="`;` execută comenzile secvențial ignorând exit code-ul. `&&` (AND logic) execută a doua comandă DOAR dacă prima returnează exit code 0.",
        misconception_targeted="M1.1: && și ; sunt echivalente"
    ))
    
    bank.add(Question(
        id="OP003",
        category="operators",
        difficulty="medium",
        question_text="Ce afișează următorul cod?",
        code_block="false && echo 'A' || echo 'B' && echo 'C'",
        options=[
            "B și C (pe linii separate)",
            "Doar B",
            "A și C (pe linii separate)",
            "Doar C"
        ],
        correct_index=0,
        explanation="false returnează 1 (eșec), deci && echo 'A' nu se execută. || echo 'B' se execută (deoarece stânga a eșuat). echo 'B' reușește, deci && echo 'C' se execută.",
        misconception_targeted="M1.2: Confuzie în lanțul && și ||"
    ))
    
    bank.add(Question(
        id="OP004",
        category="operators",
        difficulty="medium",
        question_text="Ce face operatorul `&` la sfârșitul unei comenzi?",
        code_block="sleep 10 &",
        options=[
            "Rulează comanda în background și returnează imediat prompt-ul",
            "Face comanda să ruleze mai rapid",
            "Execută comanda dacă cea anterioară a eșuat",
            "Salvează output-ul comenzii într-un fișier"
        ],
        correct_index=0,
        explanation="Operatorul & pornește comanda ca job în background, eliberând terminalul. Procesul primește un job ID și PID.",
        misconception_targeted="M1.4: & face comanda mai rapidă"
    ))
    
    bank.add(Question(
        id="OP005",
        category="operators",
        difficulty="hard",
        question_text="Ce returnează `$?` după executarea următorului cod?",
        code_block="(exit 42); echo $?",
        options=[
            "42",
            "0",
            "1",
            "Eroare de sintaxă"
        ],
        correct_index=0,
        explanation="Parantezele () creează un subshell. `exit 42` termină subshell-ul cu codul 42, care devine exit code-ul grupului. `;` ignoră acest cod, dar $? îl păstrează.",
        misconception_targeted=None
    ))
    
    bank.add(Question(
        id="OP006",
        category="operators",
        difficulty="hard",
        question_text="Care este diferența între `{ cmd1; cmd2; }` și `(cmd1; cmd2)`?",
        code_block=None,
        options=[
            "{} execută în shell-ul curent, () creează un subshell",
            "Nu există diferență, sunt echivalente",
            "() execută în shell-ul curent, {} creează un subshell",
            "{} este pentru funcții, () este pentru grupare"
        ],
        correct_index=0,
        explanation="Acoladele {} grupează comenzi în shell-ul curent (variabilele modificate persistă). Parantezele () creează un subshell izolat (variabilele nu persistă în shell-ul părinte).",
        misconception_targeted=None
    ))
    
    bank.add(Question(
        id="OP007",
        category="operators",
        difficulty="medium",
        question_text="Ce face comanda `jobs` în Bash?",
        code_block=None,
        options=[
            "Listează toate procesele background ale shell-ului curent",
            "Afișează toate procesele sistemului",
            "Creează un nou job în background",
            "Oprește toate procesele background"
        ],
        correct_index=0,
        explanation="`jobs` afișează lista job-urilor (procese background) ale shell-ului curent, cu status și job ID.",
        misconception_targeted=None
    ))
    
    bank.add(Question(
        id="OP008",
        category="operators",
        difficulty="easy",
        question_text="Ce exit code returnează comanda `true`?",
        code_block="true; echo $?",
        options=[
            "0",
            "1",
            "true",
            "Nu returnează nimic"
        ],
        correct_index=0,
        explanation="Comanda `true` returnează întotdeauna exit code 0 (succes). Este utilă în scripturi pentru bucle infinite sau condiții garantat adevărate.",
        misconception_targeted=None
    ))
    
    # 
    # CATEGORIA: REDIRECȚIONARE I/O
    # 
    
    bank.add(Question(
        id="RD001",
        category="redirection",
        difficulty="easy",
        question_text="Ce face operatorul `>` în comanda `echo 'test' > file.txt`?",
        code_block="echo 'test' > file.txt",
        options=[
            "Suprascrie conținutul file.txt cu 'test'",
            "Adaugă 'test' la sfârșitul file.txt",
            "Citește din file.txt",
            "Creează un link către file.txt"
        ],
        correct_index=0,
        explanation="Operatorul `>` redirecționează stdout către un fișier, SUPRASCRIIND conținutul existent. Dacă fișierul nu există, îl creează.",
        misconception_targeted="M2.1: > și >> sunt echivalente"
    ))
    
    bank.add(Question(
        id="RD002",
        category="redirection",
        difficulty="easy",
        question_text="Ce face operatorul `>>` diferit de `>`?",
        code_block=None,
        options=[
            ">> adaugă (append) la fișier, > suprascrie",
            ">> suprascrie, > adaugă",
            ">> este pentru stderr, > este pentru stdout",
            "Nu există diferență"
        ],
        correct_index=0,
        explanation="Operatorul `>>` adaugă la sfârșitul fișierului (append), păstrând conținutul existent. `>` suprascrie tot conținutul.",
        misconception_targeted="M2.1"
    ))
    
    bank.add(Question(
        id="RD003",
        category="redirection",
        difficulty="medium",
        question_text="Ce face `2>&1` în comanda `cmd 2>&1`?",
        code_block="ls /nonexistent 2>&1",
        options=[
            "Redirecționează stderr (fd 2) către aceeași destinație ca stdout (fd 1)",
            "Redirecționează stdout către stderr",
            "Redirecționează stderr către stdin",
            "Combină două fișiere"
        ],
        correct_index=0,
        explanation="`2>&1` înseamnă 'redirecționează file descriptor 2 (stderr) către unde pointează file descriptor 1 (stdout)'. Util pentru a captura atât output normal cât și erori.",
        misconception_targeted="M2.2: 2>&1 trimite stderr la stdin"
    ))
    
    bank.add(Question(
        id="RD004",
        category="redirection",
        difficulty="hard",
        question_text="Care este ordinea corectă pentru a trimite AMBELE (stdout și stderr) într-un fișier?",
        code_block=None,
        options=[
            "cmd > file.txt 2>&1",
            "cmd 2>&1 > file.txt",
            "cmd 2> file.txt 1>&2",
            "Toate variantele sunt echivalente"
        ],
        correct_index=0,
        explanation="ORDINEA CONTEAZĂ! În `cmd > file.txt 2>&1`, mai întâi stdout merge în file.txt, apoi stderr merge 'unde pointează stdout' (file.txt). În varianta inversă, 2>&1 se evaluează ÎNAINTE de redirectare, deci stderr merge la stdout original (terminal).",
        misconception_targeted="M2.2"
    ))
    
    bank.add(Question(
        id="RD005",
        category="redirection",
        difficulty="medium",
        question_text="Ce face operatorul `<` în comanda `wc -l < file.txt`?",
        code_block="wc -l < file.txt",
        options=[
            "Redirecționează conținutul file.txt ca stdin pentru wc",
            "Salvează output-ul wc în file.txt",
            "Compară wc cu file.txt",
            "Creează file.txt dacă nu există"
        ],
        correct_index=0,
        explanation="Operatorul `<` redirecționează conținutul unui fișier ca stdin pentru comandă. E diferit de `cat file.txt | wc -l` care creează un proces suplimentar.",
        misconception_targeted="M2.3: < e la fel cu cat file |"
    ))
    
    bank.add(Question(
        id="RD006",
        category="redirection",
        difficulty="medium",
        question_text="Ce este un 'Here Document' în Bash?",
        code_block="cat << EOF\nLinia 1\nLinia 2\nEOF",
        options=[
            "O modalitate de a furniza input multi-line inline în script",
            "Un fișier temporar creat automat",
            "Un alias pentru redirecționare",
            "O comandă pentru citirea fișierelor"
        ],
        correct_index=0,
        explanation="Here Document (`<< DELIMITER`) permite includerea de text multi-line direct în script/comandă. Textul dintre << și DELIMITER devine stdin.",
        misconception_targeted="M2.4: Here document citește din fișier"
    ))
    
    bank.add(Question(
        id="RD007",
        category="redirection",
        difficulty="hard",
        question_text="Care este diferența între `<< 'EOF'` și `<< EOF` (cu și fără ghilimele)?",
        code_block=None,
        options=[
            "Cu ghilimele, variabilele NU se expandează; fără ghilimele, se expandează",
            "Nu există diferență",
            "Cu ghilimele creează fișier, fără ghilimele nu",
            "Cu ghilimele e pentru text, fără ghilimele e pentru comenzi"
        ],
        correct_index=0,
        explanation="Când delimiter-ul e între ghilimele (`<< 'EOF'`), conținutul e tratat literal (fără expansion). Fără ghilimele, variabilele $VAR și comenzile $(cmd) sunt expandate.",
        misconception_targeted=None
    ))
    
    bank.add(Question(
        id="RD008",
        category="redirection",
        difficulty="easy",
        question_text="Ce face `/dev/null` în Linux?",
        code_block="cmd > /dev/null 2>&1",
        options=[
            "Este un fișier special care ignoră tot ce primește (\"gaura neagră\")",
            "Este directorul pentru fișiere șterse",
            "Este un fișier gol pe care îl poți citi",
            "Este locația pentru log-uri de sistem"
        ],
        correct_index=0,
        explanation="`/dev/null` este un device special care acceptă orice input și îl ignoră. Util pentru a suprima output nedorit.",
        misconception_targeted=None
    ))
    
    bank.add(Question(
        id="RD009",
        category="redirection",
        difficulty="medium",
        question_text="Ce face comanda `tee`?",
        code_block="echo 'test' | tee file.txt",
        options=[
            "Citește stdin și scrie atât în stdout cât și în fișier(e)",
            "Comprimă fișiere",
            "Creează link-uri simbolice",
            "Compară două fișiere"
        ],
        correct_index=0,
        explanation="`tee` duplică stream-ul: scrie în fișier ȘI trimite la stdout. Util pentru logging în pipeline-uri: `cmd | tee log.txt | next_cmd`.",
        misconception_targeted=None
    ))
    
    bank.add(Question(
        id="RD010",
        category="redirection",
        difficulty="hard",
        question_text="Ce face `<<<` (Here String) în Bash?",
        code_block="cat <<< 'Hello World'",
        options=[
            "Trimite un string direct ca stdin pentru o comandă",
            "Concatenează trei fișiere",
            "Creează un fișier temporar",
            "Este un alias pentru echo"
        ],
        correct_index=0,
        explanation="Here String (`<<<`) trimite un singur string ca stdin. E mai compact decât `echo 'string' |`. Ex: `wc -w <<< 'hello world'` returnează 2.",
        misconception_targeted=None
    ))
    
    # 
    # CATEGORIA: FILTRE DE TEXT
    # 
    
    bank.add(Question(
        id="FT001",
        category="filters",
        difficulty="easy",
        question_text="Ce face comanda `sort` fără opțiuni?",
        code_block="sort file.txt",
        options=[
            "Sortează liniile alfabetic/lexicografic",
            "Sortează liniile numeric",
            "Sortează liniile după lungime",
            "Inversează ordinea liniilor"
        ],
        correct_index=0,
        explanation="Fără opțiuni, `sort` sortează alfabetic (lexicografic). Pentru sortare numerică, folosește `-n`. Pentru inversare, folosește `-r`.",
        misconception_targeted=None
    ))
    
    bank.add(Question(
        id="FT002",
        category="filters",
        difficulty="medium",
        question_text="Ce afișează următorul cod?",
        code_block="echo -e 'a\\nb\\na\\nb' | uniq",
        options=[
            "a, b, a, b (4 linii) - uniq elimină doar duplicatele CONSECUTIVE",
            "a, b (2 linii) - toate duplicatele eliminate",
            "Eroare - uniq necesită fișier",
            "a, a, b, b (liniile sortate)"
        ],
        correct_index=0,
        explanation="CAPCANĂ FRECVENTĂ! `uniq` elimină doar duplicatele CONSECUTIVE. Pentru a elimina TOATE duplicatele, trebuie mai întâi `sort`: `sort | uniq`.",
        misconception_targeted="M3.1: uniq elimină TOATE duplicatele"
    ))
    
    bank.add(Question(
        id="FT003",
        category="filters",
        difficulty="easy",
        question_text="Cum extragi doar prima coloană dintr-un fișier CSV (delimitat cu virgulă)?",
        code_block=None,
        options=[
            "cut -d',' -f1 file.csv",
            "cut -c1 file.csv",
            "awk file.csv column1",
            "head -c1 file.csv"
        ],
        correct_index=0,
        explanation="`cut -d',' -f1` specifică delimitatorul (-d) ca virgulă și selectează primul câmp (-f1). `-c1` ar extrage doar primul caracter.",
        misconception_targeted=None
    ))
    
    bank.add(Question(
        id="FT004",
        category="filters",
        difficulty="medium",
        question_text="Ce face comanda `tr 'a-z' 'A-Z'`?",
        code_block="echo 'hello' | tr 'a-z' 'A-Z'",
        options=[
            "Convertește literele mici în litere mari (HELLO)",
            "Șterge literele mici și mari",
            "Inversează cazul literelor",
            "Înlocuiește textul 'a-z' cu 'A-Z'"
        ],
        correct_index=0,
        explanation="`tr` translatează caractere. 'a-z' reprezintă range-ul de la a la z, care sunt înlocuite cu 'A-Z'. Operează la nivel de CARACTER, nu string.",
        misconception_targeted="M3.3: tr înlocuiește stringuri"
    ))
    
    bank.add(Question(
        id="FT005",
        category="filters",
        difficulty="hard",
        question_text="Ce face `tr -s ' '` (cu opțiunea -s)?",
        code_block="echo 'a    b   c' | tr -s ' '",
        options=[
            "Comprimă spațiile consecutive multiple într-unul singur (squeeze)",
            "Șterge toate spațiile",
            "Înlocuiește spațiile cu tab-uri",
            "Sortează după spații"
        ],
        correct_index=0,
        explanation="Opțiunea `-s` (squeeze) comprimă secvențele de caractere repetate într-unul singur. `tr -s ' '` transformă '  ' în ' '.",
        misconception_targeted=None
    ))
    
    bank.add(Question(
        id="FT006",
        category="filters",
        difficulty="easy",
        question_text="Ce numără `wc -l file.txt`?",
        code_block="wc -l file.txt",
        options=[
            "Numărul de linii din fișier",
            "Numărul de litere din fișier",
            "Numărul de cuvinte din fișier",
            "Lungimea celei mai lungi linii"
        ],
        correct_index=0,
        explanation="`wc -l` numără liniile (newlines). `-w` pentru cuvinte, `-c` pentru bytes, `-m` pentru caractere, `-L` pentru cea mai lungă linie.",
        misconception_targeted=None
    ))
    
    bank.add(Question(
        id="FT007",
        category="filters",
        difficulty="medium",
        question_text="Cum afișezi ultimele 5 linii dintr-un fișier?",
        code_block=None,
        options=[
            "tail -5 file.txt sau tail -n 5 file.txt",
            "head -5 file.txt",
            "cat -5 file.txt",
            "last 5 file.txt"
        ],
        correct_index=0,
        explanation="`tail -n 5` sau prescurtat `tail -5` afișează ultimele 5 linii. `head` afișează de la ÎNCEPUT.",
        misconception_targeted=None
    ))
    
    bank.add(Question(
        id="FT008",
        category="filters",
        difficulty="hard",
        question_text="Cum extragi liniile 10-20 dintr-un fișier?",
        code_block=None,
        options=[
            "head -20 file | tail -11  SAU  sed -n '10,20p' file",
            "tail -10 file | head -20",
            "cat -n 10-20 file",
            "cut -l 10-20 file"
        ],
        correct_index=0,
        explanation="Metodă 1: `head -20` ia primele 20, apoi `tail -11` ia ultimele 11 (liniile 10-20). Metodă 2: `sed -n '10,20p'` printează direct liniile 10-20.",
        misconception_targeted=None
    ))
    
    bank.add(Question(
        id="FT009",
        category="filters",
        difficulty="medium",
        question_text="Ce face `sort -k2 -t':'` ?",
        code_block="sort -k2 -t':' /etc/passwd",
        options=[
            "Sortează după al doilea câmp, folosind ':' ca delimitator",
            "Sortează după caracterul 2",
            "Sortează invers după 2 coloane",
            "Sortează și elimină duplicatele"
        ],
        correct_index=0,
        explanation="`-k2` specifică să sorteze după câmpul 2 (key). `-t':'` specifică delimitatorul de câmpuri. Util pentru fișiere structurate.",
        misconception_targeted=None
    ))
    
    bank.add(Question(
        id="FT010",
        category="filters",
        difficulty="hard",
        question_text="Care este pattern-ul universal pentru analiză de frecvență?",
        code_block=None,
        options=[
            "sort | uniq -c | sort -rn | head",
            "uniq -c | sort | head",
            "head | sort | uniq",
            "cat | count | sort"
        ],
        correct_index=0,
        explanation="Pattern universal: sortează (pentru uniq), numără duplicate (uniq -c), sortează numeric descrescător (sort -rn), ia top N (head). Funcționează pentru orice analiză de frecvență.",
        misconception_targeted="M3.1"
    ))
    
    # 
    # CATEGORIA: BUCLE
    # 
    
    bank.add(Question(
        id="LP001",
        category="loops",
        difficulty="easy",
        question_text="Ce afișează următorul cod?",
        code_block="for i in 1 2 3; do echo $i; done",
        options=[
            "1, 2, 3 (pe linii separate)",
            "1 2 3 (pe o singură linie)",
            "{1..3}",
            "Eroare de sintaxă"
        ],
        correct_index=0,
        explanation="Bucla `for` iterează prin lista de valori (1, 2, 3). Pentru fiecare valoare, execută corpul (echo $i), deci afișează fiecare pe o linie.",
        misconception_targeted=None
    ))
    
    bank.add(Question(
        id="LP002",
        category="loops",
        difficulty="hard",
        question_text="Ce afișează următorul cod?",
        code_block="N=5\nfor i in {1..$N}; do echo $i; done",
        options=[
            "{1..5} (literal, NU numerele 1-5)",
            "1, 2, 3, 4, 5 (pe linii separate)",
            "Eroare de sintaxă",
            "Nimic"
        ],
        correct_index=0,
        explanation="CAPCANĂ MAJORĂ! Brace expansion ({1..5}) se face la PARSE TIME, ÎNAINTE de substituția variabilelor. Deci $N nu e încă evaluat. Soluții: `seq 1 $N` sau `for ((i=1; i<=N; i++))`.",
        misconception_targeted="M4.1: {1..$N} funcționează cu variabile"
    ))
    
    bank.add(Question(
        id="LP003",
        category="loops",
        difficulty="medium",
        question_text="Ce face sintaxa `for file in *.txt; do ... done`?",
        code_block="for file in *.txt; do echo $file; done",
        options=[
            "Iterează prin toate fișierele .txt din directorul curent",
            "Caută recursiv toate fișierele .txt",
            "Creează fișiere .txt",
            "Citește conținutul fișierelor .txt"
        ],
        correct_index=0,
        explanation="Glob pattern-ul `*.txt` se expandează la lista fișierelor matching. Bucla iterează prin fiecare. ATENȚIE: nu funcționează recursiv fără `**/*.txt` și `shopt -s globstar`.",
        misconception_targeted=None
    ))
    
    bank.add(Question(
        id="LP004",
        category="loops",
        difficulty="medium",
        question_text="Care este sintaxa corectă pentru o buclă `for` în stil C în Bash?",
        code_block=None,
        options=[
            "for ((i=0; i<10; i++)); do ... done",
            "for (i=0; i<10; i++) { ... }",
            "for i = 0 to 10 do ... done",
            "for i in range(10); do ... done"
        ],
        correct_index=0,
        explanation="Bash suportă sintaxa C-style cu duble paranteze: `for ((init; cond; incr)); do ... done`. Variabilele se referă fără $ în interiorul (()).",
        misconception_targeted=None
    ))
    
    bank.add(Question(
        id="LP005",
        category="loops",
        difficulty="hard",
        question_text="Ce problemă are următorul cod?",
        code_block="cat file.txt | while read line; do\n  count=$((count+1))\ndone\necho $count",
        options=[
            "Variabila count va fi goală/0 - while rulează într-un subshell din cauza pipe-ului",
            "Sintaxa read este greșită",
            "cat nu poate fi folosit cu pipe",
            "Codul funcționează corect"
        ],
        correct_index=0,
        explanation="CAPCANĂ SUBSHELL! Pipe-ul (`|`) creează un subshell pentru while. Variabilele modificate în subshell NU persistă. Soluție: `while read ... < file.txt` sau `while read ... < <(cat file.txt)`.",
        misconception_targeted="M4.3: while read în pipe păstrează variabilele"
    ))
    
    bank.add(Question(
        id="LP006",
        category="loops",
        difficulty="easy",
        question_text="Ce face `break` într-o buclă?",
        code_block="for i in 1 2 3 4 5; do\n  if [ $i -eq 3 ]; then break; fi\n  echo $i\ndone",
        options=[
            "Iese complet din buclă (afișează 1, 2)",
            "Sare la următoarea iterație (afișează 1, 2, 4, 5)",
            "Iese din script complet",
            "Generează eroare"
        ],
        correct_index=0,
        explanation="`break` iese imediat din bucla curentă. `continue` ar sări la următoarea iterație. `exit` ar ieși din script complet.",
        misconception_targeted="M4.2: break iese din script"
    ))
    
    bank.add(Question(
        id="LP007",
        category="loops",
        difficulty="medium",
        question_text="Ce face `continue` într-o buclă?",
        code_block="for i in 1 2 3 4 5; do\n  if [ $i -eq 3 ]; then continue; fi\n  echo $i\ndone",
        options=[
            "Sare la următoarea iterație (afișează 1, 2, 4, 5)",
            "Iese din buclă complet (afișează 1, 2)",
            "Repetă iterația curentă",
            "Pornește bucla de la început"
        ],
        correct_index=0,
        explanation="`continue` sare restul corpului buclei și trece la următoarea iterație. Aici sare echo pentru i=3, dar continuă cu 4 și 5.",
        misconception_targeted=None
    ))
    
    bank.add(Question(
        id="LP008",
        category="loops",
        difficulty="medium",
        question_text="Care este diferența dintre `while` și `until`?",
        code_block=None,
        options=[
            "while rulează CÂT TIMP condiția e adevărată, until rulează PÂNĂ CÂND condiția devine adevărată",
            "Nu există diferență, sunt sinonime",
            "until este pentru bucle infinite, while pentru bucle finite",
            "while este POSIX, until nu este"
        ],
        correct_index=0,
        explanation="`while` continuă când condiția e TRUE (exit 0). `until` continuă când condiția e FALSE (exit != 0). Sunt logic opuse.",
        misconception_targeted=None
    ))
    
    bank.add(Question(
        id="LP009",
        category="loops",
        difficulty="hard",
        question_text="Ce face `break 2` într-un context de bucle imbricate?",
        code_block="for i in 1 2; do\n  for j in a b; do\n    if [ $j = b ]; then break 2; fi\n    echo \"$i$j\"\n  done\ndone",
        options=[
            "Iese din AMBELE bucle (afișează doar '1a')",
            "Iese doar din bucla interioară",
            "Eroare de sintaxă - break nu acceptă argumente",
            "Afișează '1a', '1b', '2a'"
        ],
        correct_index=0,
        explanation="`break N` iese din N niveluri de bucle. `break 2` iese și din bucla interioară ȘI din cea exterioară. Similar, `continue N` există.",
        misconception_targeted=None
    ))
    
    bank.add(Question(
        id="LP010",
        category="loops",
        difficulty="medium",
        question_text="Care este modul corect de a citi un fișier linie cu linie în Bash?",
        code_block=None,
        options=[
            "while IFS= read -r line; do ... done < file.txt",
            "for line in $(cat file.txt); do ... done",
            "cat file.txt | for line; do ... done",
            "read file.txt into lines; for line in lines; do ... done"
        ],
        correct_index=0,
        explanation="`while read` cu redirecționare `< file` e idiomul corect. `IFS=` previne strip-ul de whitespace, `-r` previne interpretarea backslash-urilor. Varianta `for line in $(cat)` eșuează cu spații/newlines în linii.",
        misconception_targeted="M4.3"
    ))
    
    # Adaugă mai multe întrebări pentru a atinge diversitatea necesară
    bank.add(Question(
        id="OP009",
        category="operators",
        difficulty="medium",
        question_text="Ce se întâmplă cu exit code-ul într-un pipeline `cmd1 | cmd2`?",
        code_block="false | true; echo $?",
        options=[
            "Exit code-ul este al ULTIMEI comenzi (0 în acest caz)",
            "Exit code-ul este al primei comenzi (1)",
            "Exit code-ul este combinația ambelor",
            "Pipeline-ul nu are exit code"
        ],
        correct_index=0,
        explanation="În mod implicit, $? returnează exit code-ul ultimei comenzi din pipeline. Pentru a obține toate, folosește array-ul `${PIPESTATUS[@]}`.",
        misconception_targeted="M1.3: | transmite și exit code-ul"
    ))
    
    bank.add(Question(
        id="FT011",
        category="filters",
        difficulty="medium",
        question_text="Ce face comanda `paste file1.txt file2.txt`?",
        code_block="paste file1.txt file2.txt",
        options=[
            "Combină liniile corespunzătoare din ambele fișiere, separate de tab",
            "Concatenează fișierele vertical",
            "Copiază file1 în file2",
            "Compară cele două fișiere"
        ],
        correct_index=0,
        explanation="`paste` merge liniile din fișiere în paralel, separate implicit de TAB. Linia 1 din file1 + TAB + linia 1 din file2, etc.",
        misconception_targeted=None
    ))
    
    bank.add(Question(
        id="RD011",
        category="redirection",
        difficulty="easy",
        question_text="Ce reprezintă numerele 0, 1, și 2 în contextul I/O?",
        code_block=None,
        options=[
            "stdin (0), stdout (1), stderr (2) - file descriptors standard",
            "Prioritățile proceselor",
            "Nivelurile de eroare",
            "Tipurile de fișiere"
        ],
        correct_index=0,
        explanation="Fiecare proces are 3 file descriptors standard: 0 (stdin - input), 1 (stdout - output normal), 2 (stderr - mesaje de eroare).",
        misconception_targeted=None
    ))
    
    bank.add(Question(
        id="LP011",
        category="loops",
        difficulty="easy",
        question_text="Ce returnează `seq 1 5`?",
        code_block="seq 1 5",
        options=[
            "Numerele 1, 2, 3, 4, 5 pe linii separate",
            "Secvența '1 5'",
            "Eroare - seq nu există în Bash",
            "Un fișier cu numerele 1-5"
        ],
        correct_index=0,
        explanation="`seq START END` generează o secvență de numere. Util ca alternativă la brace expansion când ai nevoie de variabile: `for i in $(seq 1 $N)`.",
        misconception_targeted="M4.1"
    ))
    
    return bank

# 
# SECȚIUNEA 3: GENERATORUL DE QUIZ
# 

class QuizGenerator:
    """Generator de quiz-uri personalizate."""
    
    def __init__(self, question_bank: QuestionBank):
        self.bank = question_bank
    
    def _generate_seed(self, student_name: str, student_group: str) -> int:
        """Generează un seed unic bazat pe numele și grupa studentului."""
        data = f"{student_name.lower().strip()}:{student_group}"
        return int(hashlib.md5(data.encode()).hexdigest()[:8], 16)
    
    def generate_quiz(self, student_name: str, student_group: str,
                      question_count: int = 15) -> Quiz:
        """Generează un quiz personalizat pentru un student."""
        seed = self._generate_seed(student_name, student_group)
        
        # Selectează întrebări echilibrat
        selected_questions = self.bank.get_balanced_selection(question_count, seed)
        
        # Randomizează opțiunile pentru fiecare întrebare
        quiz_questions = []
        for idx, q in enumerate(selected_questions, 1):
            shuffled_opts, new_correct = q.get_shuffled_options(seed + idx)
            quiz_questions.append({
                'number': idx,
                'id': q.id,
                'category': q.category,
                'difficulty': q.difficulty,
                'question_text': q.question_text,
                'code_block': q.code_block,
                'options': shuffled_opts,
                'correct_index': new_correct,
                'correct_letter': chr(ord('A') + new_correct),
                'explanation': q.explanation,
                'points': self._calculate_points(q.difficulty, question_count)
            })
        
        quiz_id = hashlib.sha256(
            f"{student_name}:{student_group}:{datetime.now().isoformat()}".encode()
        ).hexdigest()[:12].upper()
        
        return Quiz(
            student_name=student_name,
            student_group=student_group,
            quiz_id=quiz_id,
            generated_at=datetime.now().isoformat(),
            questions=quiz_questions,
            seed=seed,
            total_points=100,
            time_limit_minutes=30
        )
    
    def _calculate_points(self, difficulty: str, total_questions: int) -> int:
        """Calculează punctele per întrebare bazat pe dificultate."""
        base = 100 // total_questions
        multipliers = {'easy': 0.8, 'medium': 1.0, 'hard': 1.3}
        return round(base * multipliers.get(difficulty, 1.0))

# 
# SECȚIUNEA 4: EXPORTATORI
# 

class QuizExporter:
    """Exportă quiz-uri în diferite formate."""
    
    @staticmethod
    def to_txt(quiz: Quiz, include_answers: bool = False) -> str:
        """Exportă quiz-ul în format text."""
        lines = []
        lines.append("=" * 70)
        lines.append(f"  QUIZ: Seminarul 3-4 - Operatori, Redirecționare, Filtre, Bucle")
        lines.append("=" * 70)
        lines.append(f"  Student: {quiz.student_name}")
        lines.append(f"  Grupa: {quiz.student_group}")
        lines.append(f"  ID Quiz: {quiz.quiz_id}")
        lines.append(f"  Timp limită: {quiz.time_limit_minutes} minute")
        lines.append(f"  Total puncte: {quiz.total_points}")
        lines.append("=" * 70)
        lines.append("")
        
        for q in quiz.questions:
            lines.append(f"[{q['number']:02d}] [{q['difficulty'].upper()}] ({q['points']}p)")
            lines.append("-" * 50)
            lines.append(q['question_text'])
            
            if q['code_block']:
                lines.append("")
                lines.append("```bash")
                lines.append(q['code_block'])
                lines.append("```")
            
            lines.append("")
            for i, opt in enumerate(q['options']):
                letter = chr(ord('A') + i)
                marker = " ✓" if include_answers and i == q['correct_index'] else ""
                lines.append(f"  {letter}) {opt}{marker}")
            
            if include_answers:
                lines.append("")
                lines.append(f"  → Răspuns corect: {q['correct_letter']}")
                lines.append(f"  → Explicație: {q['explanation']}")
            
            lines.append("")
            lines.append("")
        
        lines.append("=" * 70)
        lines.append("  FOAIA DE RĂSPUNS")
        lines.append("=" * 70)
        for q in quiz.questions:
            lines.append(f"  {q['number']:02d}. [ A ]  [ B ]  [ C ]  [ D ]")
        lines.append("")
        lines.append("  Nume student: _______________________")
        lines.append("  Semnătură: __________________________")
        lines.append("=" * 70)
        
        return "\n".join(lines)
    
    @staticmethod
    def to_html(quiz: Quiz, include_answers: bool = False) -> str:
        """Exportă quiz-ul în format HTML printabil."""
        html_content = f"""<!DOCTYPE html>
<html lang="ro">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quiz {quiz.quiz_id} - {quiz.student_name}</title>
    <style>
        * {{ box-sizing: border-box; margin: 0; padding: 0; }}
        body {{ 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
            padding: 20px;
            max-width: 800px;
            margin: 0 auto;
            background: #f5f5f5;
        }}
        .quiz-header {{
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 25px;
            border-radius: 10px;
            margin-bottom: 25px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.2);
        }}
        .quiz-header h1 {{ font-size: 1.5em; margin-bottom: 15px; }}
        .quiz-info {{ display: grid; grid-template-columns: 1fr 1fr; gap: 10px; }}
        .quiz-info span {{ font-size: 0.95em; }}
        .question {{
            background: white;
            padding: 20px;
            margin-bottom: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            page-break-inside: avoid;
        }}
        .question-header {{
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
            padding-bottom: 10px;
            border-bottom: 2px solid #eee;
        }}
        .question-number {{
            font-weight: bold;
            font-size: 1.1em;
            color: #667eea;
        }}
        .difficulty {{
            padding: 3px 10px;
            border-radius: 15px;
            font-size: 0.8em;
            font-weight: bold;
        }}
        .difficulty.easy {{ background: #d4edda; color: #155724; }}
        .difficulty.medium {{ background: #fff3cd; color: #856404; }}
        .difficulty.hard {{ background: #f8d7da; color: #721c24; }}
        .points {{ color: #666; font-size: 0.9em; }}
        .question-text {{ font-size: 1em; margin-bottom: 15px; }}
        .code-block {{
            background: #1e1e1e;
            color: #d4d4d4;
            padding: 15px;
            border-radius: 5px;
            font-family: 'Consolas', 'Monaco', monospace;
            font-size: 0.9em;
            margin: 15px 0;
            overflow-x: auto;
            white-space: pre-wrap;
        }}
        .options {{ list-style: none; }}
        .option {{
            padding: 10px 15px;
            margin: 8px 0;
            border: 2px solid #e0e0e0;
            border-radius: 5px;
            cursor: pointer;
            transition: all 0.2s;
        }}
        .option:hover {{ border-color: #667eea; background: #f8f9ff; }}
        .option-letter {{
            display: inline-block;
            width: 25px;
            height: 25px;
            background: #667eea;
            color: white;
            border-radius: 50%;
            text-align: center;
            line-height: 25px;
            margin-right: 10px;
            font-weight: bold;
        }}
        .correct {{ border-color: #28a745 !important; background: #d4edda !important; }}
        .explanation {{
            background: #e7f3ff;
            padding: 15px;
            border-radius: 5px;
            margin-top: 15px;
            border-left: 4px solid #667eea;
        }}
        .explanation strong {{ color: #667eea; }}
        .answer-sheet {{
            background: white;
            padding: 25px;
            border-radius: 10px;
            margin-top: 30px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }}
        .answer-sheet h2 {{
            color: #667eea;
            margin-bottom: 20px;
            border-bottom: 2px solid #667eea;
            padding-bottom: 10px;
        }}
        .answer-grid {{
            display: grid;
            grid-template-columns: repeat(5, 1fr);
            gap: 10px;
        }}
        .answer-row {{
            display: flex;
            align-items: center;
            gap: 5px;
            padding: 5px;
            border: 1px solid #ddd;
            border-radius: 5px;
        }}
        .answer-row span {{ font-weight: bold; min-width: 25px; }}
        .bubble {{
            width: 20px;
            height: 20px;
            border: 2px solid #667eea;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.7em;
            color: #667eea;
        }}
        .signature-area {{
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px dashed #ccc;
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 30px;
        }}
        .signature-line {{
            border-bottom: 1px solid #333;
            padding-bottom: 5px;
            margin-top: 30px;
        }}
        @media print {{
            body {{ background: white; padding: 0; }}
            .quiz-header {{ box-shadow: none; }}
            .question {{ box-shadow: none; border: 1px solid #ddd; }}
        }}
    </style>
</head>
<body>
    <div class="quiz-header">
        <h1>📝 Quiz: Operatori, Redirecționare, Filtre, Bucle</h1>
        <div class="quiz-info">
            <span>👤 Student: <strong>{html.escape(quiz.student_name)}</strong></span>
            <span>🎓 Grupa: <strong>{html.escape(quiz.student_group)}</strong></span>
            <span>🔑 ID: <strong>{quiz.quiz_id}</strong></span>
            <span>⏱️ Timp: <strong>{quiz.time_limit_minutes} minute</strong></span>
            <span>📊 Total: <strong>{quiz.total_points} puncte</strong></span>
            <span>📅 Generat: <strong>{quiz.generated_at[:10]}</strong></span>
        </div>
    </div>
"""
        
        for q in quiz.questions:
            difficulty_class = q['difficulty']
            html_content += f"""
    <div class="question">
        <div class="question-header">
            <span class="question-number">Întrebarea {q['number']}</span>
            <span class="difficulty {difficulty_class}">{q['difficulty'].upper()}</span>
            <span class="points">{q['points']} puncte</span>
        </div>
        <p class="question-text">{html.escape(q['question_text'])}</p>
"""
            
            if q['code_block']:
                html_content += f"""        <div class="code-block">{html.escape(q['code_block'])}</div>\n"""
            
            html_content += """        <ul class="options">\n"""
            
            for i, opt in enumerate(q['options']):
                letter = chr(ord('A') + i)
                correct_class = ' correct' if include_answers and i == q['correct_index'] else ''
                html_content += f"""            <li class="option{correct_class}">
                <span class="option-letter">{letter}</span>
                {html.escape(opt)}
            </li>\n"""
            
            html_content += """        </ul>\n"""
            
            if include_answers:
                html_content += f"""        <div class="explanation">
            <strong>✓ Răspuns corect: {q['correct_letter']}</strong><br>
            {html.escape(q['explanation'])}
        </div>\n"""
            
            html_content += """    </div>\n"""
        
        # Answer sheet
        html_content += """
    <div class="answer-sheet">
        <h2>📋 Foaia de Răspuns</h2>
        <div class="answer-grid">
"""
        for q in quiz.questions:
            html_content += f"""            <div class="answer-row">
                <span>{q['number']:02d}.</span>
                <div class="bubble">A</div>
                <div class="bubble">B</div>
                <div class="bubble">C</div>
                <div class="bubble">D</div>
            </div>\n"""
        
        html_content += """        </div>
        <div class="signature-area">
            <div>
                <p>Nume și prenume:</p>
                <div class="signature-line"></div>
            </div>
            <div>
                <p>Semnătură:</p>
                <div class="signature-line"></div>
            </div>
        </div>
    </div>
</body>
</html>"""
        
        return html_content
    
    @staticmethod
    def to_json(quiz: Quiz) -> str:
        """Exportă quiz-ul în format JSON."""
        return json.dumps(asdict(quiz), indent=2, ensure_ascii=False)
    
    @staticmethod
    def to_markdown(quiz: Quiz, include_answers: bool = False) -> str:
        """Exportă quiz-ul în format Markdown (pentru conversie PDF)."""
        lines = []
        lines.append("---")
        lines.append("title: Quiz Seminarul 3-4")
        lines.append(f"student: {quiz.student_name}")
        lines.append(f"grupa: {quiz.student_group}")
        lines.append(f"date: {quiz.generated_at[:10]}")
        lines.append("---")
        lines.append("")
        lines.append("# 📝 Quiz: Operatori, Redirecționare, Filtre, Bucle")
        lines.append("")
        lines.append(f"**Student:** {quiz.student_name} | **Grupa:** {quiz.student_group}")
        lines.append(f"**ID:** `{quiz.quiz_id}` | **Timp:** {quiz.time_limit_minutes} min")
        lines.append("")
        lines.append("---")
        lines.append("")
        
        for q in quiz.questions:
            lines.append(f"## {q['number']}. [{q['difficulty'].upper()}] ({q['points']}p)")
            lines.append("")
            lines.append(q['question_text'])
            
            if q['code_block']:
                lines.append("")
                lines.append("```bash")
                lines.append(q['code_block'])
                lines.append("```")
            
            lines.append("")
            for i, opt in enumerate(q['options']):
                letter = chr(ord('A') + i)
                marker = " ✓" if include_answers and i == q['correct_index'] else ""
                lines.append(f"- **{letter})** {opt}{marker}")
            
            if include_answers:
                lines.append("")
                lines.append(f"> **Răspuns:** {q['correct_letter']}")
                lines.append(f"> ")
                lines.append(f"> {q['explanation']}")
            
            lines.append("")
            lines.append("---")
            lines.append("")
        
        return "\n".join(lines)

# 
# SECȚIUNEA 5: INTERFAȚA CLI
# 

# Culori ANSI
class Colors:
    HEADER = '\033[95m'
    BLUE = '\033[94m'
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'

def print_banner():
    """Afișează banner-ul aplicației."""
    banner = """
╔═══════════════════════════════════════════════════════════════════════════════╗
║                                                                               ║
║   📝  QUIZ GENERATOR - Seminarul 3-4                                          ║
║       Operatori | Redirecționare | Filtre | Bucle                             ║
║                                                                               ║
║       ASE București - CSIE | Sisteme de Operare                               ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
"""
    print(f"{Colors.CYAN}{banner}{Colors.ENDC}")

def read_students_file(filepath: str) -> List[Tuple[str, str]]:
    """Citește lista de studenți din fișier (format: Nume,Grupa)."""
    students = []
    with open(filepath, 'r', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith('#'):
                continue
            parts = line.split(',')
            if len(parts) >= 2:
                students.append((parts[0].strip(), parts[1].strip()))
    return students

def main():
    parser = argparse.ArgumentParser(
        description='Generator de quiz-uri personalizate pentru Seminarul 3-4',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Exemple de utilizare:
  %(prog)s --student "Popescu Ion" --grupa 1051
  %(prog)s --students lista.txt --output ./quizzes/
  %(prog)s --student "Test" --grupa 1000 --format html --answers
  %(prog)s --count 20 --format all --output ./export/
        """
    )
    
    parser.add_argument('--student', '-s', 
                        help='Numele studentului')
    parser.add_argument('--grupa', '-g', 
                        help='Grupa studentului')
    parser.add_argument('--students', '-S', 
                        help='Fișier cu lista studenților (format: Nume,Grupa)')
    parser.add_argument('--count', '-c', type=int, default=15,
                        help='Numărul de întrebări (default: 15)')
    parser.add_argument('--format', '-f', 
                        choices=['txt', 'html', 'json', 'md', 'all'],
                        default='txt',
                        help='Formatul de export (default: txt)')
    parser.add_argument('--output', '-o', default='.',
                        help='Directorul de output (default: directorul curent)')
    parser.add_argument('--answers', '-a', action='store_true',
                        help='Include răspunsurile corecte')
    parser.add_argument('--seed', type=int,
                        help='Seed manual pentru randomizare')
    parser.add_argument('--list-questions', action='store_true',
                        help='Listează toate întrebările din bancă')
    parser.add_argument('--stats', action='store_true',
                        help='Afișează statistici despre banca de întrebări')
    
    args = parser.parse_args()
    
    # Inițializare
    print_banner()
    bank = create_question_bank()
    generator = QuizGenerator(bank)
    
    # Mod: statistici bancă
    if args.stats:
        print(f"{Colors.BOLD}📊 Statistici Banca de Întrebări:{Colors.ENDC}\n")
        categories = {}
        difficulties = {}
        for q in bank.questions:
            categories[q.category] = categories.get(q.category, 0) + 1
            difficulties[q.difficulty] = difficulties.get(q.difficulty, 0) + 1
        
        print(f"  Total întrebări: {Colors.GREEN}{len(bank.questions)}{Colors.ENDC}")
        print(f"\n  Per categorie:")
        for cat, count in sorted(categories.items()):
            print(f"    • {cat}: {count}")
        print(f"\n  Per dificultate:")
        for diff, count in sorted(difficulties.items()):
            print(f"    • {diff}: {count}")
        return 0
    
    # Mod: listare întrebări
    if args.list_questions:
        print(f"{Colors.BOLD}📋 Lista Întrebărilor:{Colors.ENDC}\n")
        for q in bank.questions:
            print(f"  [{q.id}] [{q.category:12}] [{q.difficulty:6}] {q.question_text[:60]}...")
        return 0
    
    # Validare argumente
    students = []
    if args.students:
        if not os.path.exists(args.students):
            print(f"{Colors.RED}❌ Eroare: Fișierul {args.students} nu există!{Colors.ENDC}")
            return 1
        students = read_students_file(args.students)
        print(f"{Colors.GREEN}✓ Încărcat {len(students)} studenți din {args.students}{Colors.ENDC}\n")
    elif args.student and args.grupa:
        students = [(args.student, args.grupa)]
    else:
        parser.print_help()
        print(f"\n{Colors.YELLOW}⚠️ Specifică --student și --grupa SAU --students{Colors.ENDC}")
        return 1
    
    # Creare director output
    output_dir = Path(args.output)
    output_dir.mkdir(parents=True, exist_ok=True)
    
    # Generare quiz-uri
    print(f"{Colors.BOLD}🔄 Generare quiz-uri...{Colors.ENDC}\n")
    
    for name, group in students:
        quiz = generator.generate_quiz(name, group, args.count)
        
        # Curăță numele pentru fișier
        safe_name = re.sub(r'[^\w\-]', '_', name)
        base_filename = f"quiz_{safe_name}_{group}_{quiz.quiz_id}"
        
        formats_to_export = ['txt', 'html', 'json', 'md'] if args.format == 'all' else [args.format]
        
        for fmt in formats_to_export:
            if fmt == 'txt':
                content = QuizExporter.to_txt(quiz, args.answers)
                ext = 'txt'
            elif fmt == 'html':
                content = QuizExporter.to_html(quiz, args.answers)
                ext = 'html'
            elif fmt == 'json':
                content = QuizExporter.to_json(quiz)
                ext = 'json'
            elif fmt == 'md':
                content = QuizExporter.to_markdown(quiz, args.answers)
                ext = 'md'
            
            filepath = output_dir / f"{base_filename}.{ext}"
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            
            print(f"  {Colors.GREEN}✓{Colors.ENDC} {name} ({group}): {filepath}")
        
        # Export și varianta cu răspunsuri pentru instructor
        if not args.answers and args.format != 'json':
            answers_filename = f"{base_filename}_ANSWERS"
            
            # TXT cu răspunsuri
            content = QuizExporter.to_txt(quiz, True)
            filepath = output_dir / f"{answers_filename}.txt"
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"  {Colors.CYAN}✓{Colors.ENDC} (răspunsuri): {filepath}")
    
    print(f"\n{Colors.GREEN}✓ Generare completă! {len(students)} quiz-uri create.{Colors.ENDC}")
    print(f"  📁 Output: {output_dir.absolute()}")
    
    return 0

if __name__ == '__main__':
    sys.exit(main())
