#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
═══════════════════════════════════════════════════════════════════════════════
📝 S02_01_autograder.py - Autograder pentru Tema Seminar 2
═══════════════════════════════════════════════════════════════════════════════

DESCRIERE:
    Evaluator automat pentru temele studenților la Seminarul 3-4 SO.
    Verifică structura, sintaxa, funcționalitatea și stilul codului.

UTILIZARE:
    python3 S02_01_autograder.py <director_tema>
    python3 S02_01_autograder.py ~/tema_student/
    python3 S02_01_autograder.py --help

OUTPUT:
    - Raport detaliat în consolă
    - Fișier JSON cu rezultatele
    - Scor final și nota

AUTOR: Kit Pedagogic SO | ASE București - CSIE
VERSIUNE: 1.0 | Ianuarie 2025
═══════════════════════════════════════════════════════════════════════════════
"""

import os
import sys
import json
import subprocess
import argparse
import re
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Tuple, Optional, Any
from dataclasses import dataclass, field, asdict
from enum import Enum

# 
# CONFIGURARE
# 

class Colors:
    """Culori ANSI pentru output în terminal."""
    RED = '\033[1;31m'
    GREEN = '\033[1;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[1;34m'
    MAGENTA = '\033[1;35m'
    CYAN = '\033[1;36m'
    WHITE = '\033[1;37m'
    DIM = '\033[2m'
    RESET = '\033[0m'
    
    @classmethod
    def disable(cls):
        """Dezactivează culorile pentru output non-TTY."""
        for attr in dir(cls):
            if attr.isupper() and not attr.startswith('_'):
                setattr(cls, attr, '')

# Dezactivare culori dacă nu e terminal
if not sys.stdout.isatty():
    Colors.disable()

# Fișierele așteptate în temă
EXPECTED_FILES = {
    'ex1_operatori.sh': 10,
    'ex2_redirectare.sh': 12,
    'ex3_filtre.sh': 12,
    'ex4_bucle.sh': 11,
    'ex5_integrat.sh': 15
}

# Punctaj maxim pe categorii
MAX_SCORES = {
    'structure': 10,
    'syntax': 20,
    'ex1_operatori': 10,
    'ex2_redirectare': 12,
    'ex3_filtre': 12,
    'ex4_bucle': 11,
    'ex5_integrat': 15,
    'style': 10
}

# Pattern-uri pentru verificări
PATTERNS = {
    'operators': {
        'sequential': r';\s*(?!;)',
        'and': r'&&',
        'or': r'\|\|',
        'background': r'&\s*$|&\s*[^&]',
        'pipe': r'\|(?!\|)'
    },
    'redirect': {
        'stdout': r'>\s*[^>]|1>',
        'append': r'>>',
        'stderr': r'2>',
        'stderr_stdout': r'2>&1|&>',
        'stdin': r'<\s*[^<]',
        'here_doc': r'<<\s*[\'"]?\w+[\'"]?',
        'here_string': r'<<<'
    },
    'filters': {
        'sort': r'\bsort\b',
        'uniq': r'\buniq\b',
        'cut': r'\bcut\b',
        'paste': r'\bpaste\b',
        'tr': r'\btr\b',
        'wc': r'\bwc\b',
        'head': r'\bhead\b',
        'tail': r'\btail\b',
        'tee': r'\btee\b',
        'awk': r'\bawk\b',
        'sed': r'\bsed\b',
        'grep': r'\bgrep\b'
    },
    'loops': {
        'for': r'\bfor\b.*\bdo\b',
        'while': r'\bwhile\b.*\bdo\b',
        'until': r'\buntil\b.*\bdo\b',
        'break': r'\bbreak\b',
        'continue': r'\bcontinue\b'
    },
    'good_practices': {
        'shebang': r'^#!/bin/bash|^#!/usr/bin/env bash',
        'comments': r'#[^!].*$',
        'quoting': r'"\$\w+"|\'\$\w+\'',
        'functions': r'\bfunction\s+\w+|\w+\s*\(\s*\)\s*\{',
        'error_handling': r'set\s+-e|set\s+-o\s+errexit|\|\|\s*exit',
        'help': r'--help|-h\)'
    },
    'bugs': {
        'brace_var': r'\{\d+\.\.\$\w+\}|\{\$\w+\.\.\d+\}|\{\$\w+\.\.\$\w+\}',
        'cat_pipe_while': r'\bcat\s+[^|]+\|\s*while\s+read',
        'unquoted_var': r'\$\w+[^"\'}\s]|\s\$\w+\s',
    }
}

# 
# DATA CLASSES
# 

@dataclass
class CheckResult:
    """Rezultatul unei verificări individuale."""
    name: str
    passed: bool
    points: float
    max_points: float
    message: str
    details: List[str] = field(default_factory=list)

@dataclass
class FileResult:
    """Rezultatul evaluării unui fișier."""
    filename: str
    exists: bool
    syntax_ok: bool
    executable: bool
    checks: List[CheckResult] = field(default_factory=list)
    score: float = 0.0
    max_score: float = 0.0

@dataclass
class GradeReport:
    """Raportul complet de evaluare."""
    student_dir: str
    timestamp: str
    files: Dict[str, FileResult] = field(default_factory=dict)
    total_score: float = 0.0
    max_score: float = 100.0
    percentage: float = 0.0
    grade: str = "F"
    warnings: List[str] = field(default_factory=list)
    errors: List[str] = field(default_factory=list)

# 
# FUNCȚII HELPER
# 

def print_header(title: str) -> None:
    """Afișează un header formatat."""
    width = 70
    print()
    print(f"{Colors.CYAN}{'═' * width}{Colors.RESET}")
    print(f"{Colors.CYAN}║{Colors.RESET} {Colors.WHITE}{title:<{width-4}}{Colors.RESET} {Colors.CYAN}║{Colors.RESET}")
    print(f"{Colors.CYAN}{'═' * width}{Colors.RESET}")

def print_subheader(title: str) -> None:
    """Afișează un subheader."""
    print(f"\n{Colors.YELLOW}━━━ {title} ━━━{Colors.RESET}\n")

def print_check(result: CheckResult) -> None:
    """Afișează rezultatul unei verificări."""
    if result.passed:
        status = f"{Colors.GREEN}✓ PASS{Colors.RESET}"
    else:
        status = f"{Colors.RED}✗ FAIL{Colors.RESET}"
    
    points_str = f"[{result.points:.1f}/{result.max_points:.1f}]"
    print(f"  {status} {result.name:<40} {Colors.CYAN}{points_str}{Colors.RESET}")
    
    if result.details:
        for detail in result.details[:3]:  # Limitare la 3 detalii
            print(f"       {Colors.DIM}{detail}{Colors.RESET}")

def run_command(cmd: List[str], timeout: int = 10) -> Tuple[int, str, str]:
    """Rulează o comandă și returnează (returncode, stdout, stderr)."""
    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=timeout
        )
        return result.returncode, result.stdout, result.stderr
    except subprocess.TimeoutExpired:
        return -1, "", "Timeout expired"
    except Exception as e:
        return -1, "", str(e)

def check_syntax(filepath: str) -> Tuple[bool, str]:
    """Verifică sintaxa unui script bash."""
    returncode, stdout, stderr = run_command(['bash', '-n', filepath])
    return returncode == 0, stderr.strip()

def count_pattern_matches(content: str, pattern: str) -> int:
    """Numără aparițiile unui pattern în conținut."""
    return len(re.findall(pattern, content, re.MULTILINE))

def has_pattern(content: str, pattern: str) -> bool:
    """Verifică dacă pattern-ul există în conținut."""
    return bool(re.search(pattern, content, re.MULTILINE))

# 
# VERIFICĂRI SPECIFICE
# 

def check_structure(student_dir: Path) -> List[CheckResult]:
    """Verifică structura fișierelor."""
    results = []
    
    for filename, max_points in EXPECTED_FILES.items():
        filepath = student_dir / filename
        exists = filepath.exists()
        
        if exists:
            # Verificare shebang
            with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                first_line = f.readline().strip()
            
            has_shebang = first_line.startswith('#!')
            is_executable = os.access(filepath, os.X_OK)
            
            if has_shebang and is_executable:
                result = CheckResult(
                    name=f"Fișier {filename}",
                    passed=True,
                    points=2.0,
                    max_points=2.0,
                    message="Fișier valid cu shebang",
                    details=[f"Shebang: {first_line}"]
                )
            else:
                details = []
                if not has_shebang:
                    details.append("⚠ Lipsește shebang (#!/bin/bash)")
                if not is_executable:
                    details.append("⚠ Fișierul nu e executabil (chmod +x)")
                
                result = CheckResult(
                    name=f"Fișier {filename}",
                    passed=False,
                    points=1.0,
                    max_points=2.0,
                    message="Fișier parțial valid",
                    details=details
                )
        else:
            result = CheckResult(
                name=f"Fișier {filename}",
                passed=False,
                points=0.0,
                max_points=2.0,
                message="Fișier lipsă!",
                details=[]
            )
        
        results.append(result)
    
    return results

def check_ex1_operators(filepath: Path) -> List[CheckResult]:
    """Verifică exercițiul 1 - Operatori de control."""
    results = []
    
    if not filepath.exists():
        return [CheckResult(
            name="Ex1 - Fișier lipsă",
            passed=False, points=0, max_points=10,
            message="Fișierul ex1_operatori.sh nu există"
        )]
    
    with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
    
    # Verificare operatori
    operators_checks = [
        ('&&', PATTERNS['operators']['and'], 2.0),
        ('||', PATTERNS['operators']['or'], 2.0),
        ('& (background)', PATTERNS['operators']['background'], 2.0),
        ('| (pipe)', PATTERNS['operators']['pipe'], 2.0),
    ]
    
    for name, pattern, points in operators_checks:
        found = has_pattern(content, pattern)
        results.append(CheckResult(
            name=f"Ex1 - Operator {name}",
            passed=found,
            points=points if found else 0,
            max_points=points,
            message=f"Folosește {name}" if found else f"Nu folosește {name}",
            details=[f"Pattern: {pattern}"] if not found else []
        ))
    
    # Verificare execuție
    returncode, stdout, stderr = run_command(['bash', str(filepath)])
    exec_ok = returncode == 0
    results.append(CheckResult(
        name="Ex1 - Execuție fără erori",
        passed=exec_ok,
        points=2.0 if exec_ok else 0,
        max_points=2.0,
        message="Rulează fără erori" if exec_ok else f"Eroare: {stderr[:100]}",
        details=[]
    ))
    
    return results

def check_ex2_redirect(filepath: Path) -> List[CheckResult]:
    """Verifică exercițiul 2 - Redirecționare."""
    results = []
    
    if not filepath.exists():
        return [CheckResult(
            name="Ex2 - Fișier lipsă",
            passed=False, points=0, max_points=12,
            message="Fișierul ex2_redirectare.sh nu există"
        )]
    
    with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
    
    redirect_checks = [
        ('> (stdout)', PATTERNS['redirect']['stdout'], 2.0),
        ('>> (append)', PATTERNS['redirect']['append'], 2.0),
        ('2> (stderr)', PATTERNS['redirect']['stderr'], 2.0),
        ('2>&1 sau &>', PATTERNS['redirect']['stderr_stdout'], 2.0),
        ('<< (here document)', PATTERNS['redirect']['here_doc'], 2.0),
    ]
    
    for name, pattern, points in redirect_checks:
        found = has_pattern(content, pattern)
        results.append(CheckResult(
            name=f"Ex2 - Redirecționare {name}",
            passed=found,
            points=points if found else 0,
            max_points=points,
            message=f"Folosește {name}" if found else f"Nu folosește {name}"
        ))
    
    # Execuție
    returncode, stdout, stderr = run_command(['bash', str(filepath)])
    exec_ok = returncode == 0
    results.append(CheckResult(
        name="Ex2 - Execuție fără erori",
        passed=exec_ok,
        points=2.0 if exec_ok else 0,
        max_points=2.0,
        message="Rulează fără erori" if exec_ok else "Erori la execuție"
    ))
    
    return results

def check_ex3_filters(filepath: Path) -> List[CheckResult]:
    """Verifică exercițiul 3 - Filtre."""
    results = []
    
    if not filepath.exists():
        return [CheckResult(
            name="Ex3 - Fișier lipsă",
            passed=False, points=0, max_points=12,
            message="Fișierul ex3_filtre.sh nu există"
        )]
    
    with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
    
    # Verificare filtre esențiale
    filter_checks = [
        ('sort', PATTERNS['filters']['sort'], 2.0),
        ('uniq', PATTERNS['filters']['uniq'], 2.0),
        ('cut', PATTERNS['filters']['cut'], 2.0),
        ('tr', PATTERNS['filters']['tr'], 2.0),
    ]
    
    for name, pattern, points in filter_checks:
        found = has_pattern(content, pattern)
        results.append(CheckResult(
            name=f"Ex3 - Filtru {name}",
            passed=found,
            points=points if found else 0,
            max_points=points,
            message=f"Folosește {name}" if found else f"Nu folosește {name}"
        ))
    
    # Verificare pattern sort | uniq
    sort_uniq_pattern = r'\bsort\b[^|]*\|\s*uniq\b'
    has_sort_uniq = has_pattern(content, sort_uniq_pattern)
    results.append(CheckResult(
        name="Ex3 - Pattern sort | uniq",
        passed=has_sort_uniq,
        points=2.0 if has_sort_uniq else 0,
        max_points=2.0,
        message="Folosește corect sort | uniq" if has_sort_uniq else "Nu are sort | uniq (capcană uniq!)",
        details=["⚠ uniq fără sort nu elimină toate duplicatele!"] if not has_sort_uniq else []
    ))
    
    # Pipeline complexity (minim 3 comenzi)
    pipe_count = content.count('|')
    complex_pipeline = pipe_count >= 3
    results.append(CheckResult(
        name="Ex3 - Complexitate pipeline",
        passed=complex_pipeline,
        points=2.0 if complex_pipeline else 1.0,
        max_points=2.0,
        message=f"Pipeline cu {pipe_count} pipes" if complex_pipeline else "Pipeline prea simplu"
    ))
    
    return results

def check_ex4_loops(filepath: Path) -> List[CheckResult]:
    """Verifică exercițiul 4 - Bucle."""
    results = []
    
    if not filepath.exists():
        return [CheckResult(
            name="Ex4 - Fișier lipsă",
            passed=False, points=0, max_points=11,
            message="Fișierul ex4_bucle.sh nu există"
        )]
    
    with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
    
    # Verificare bucle
    loop_checks = [
        ('for', PATTERNS['loops']['for'], 3.0),
        ('while', PATTERNS['loops']['while'], 3.0),
    ]
    
    for name, pattern, points in loop_checks:
        found = has_pattern(content, pattern)
        results.append(CheckResult(
            name=f"Ex4 - Buclă {name}",
            passed=found,
            points=points if found else 0,
            max_points=points,
            message=f"Folosește {name}" if found else f"Nu folosește {name}"
        ))
    
    # Verificare bug {1..$N}
    has_brace_var_bug = has_pattern(content, PATTERNS['bugs']['brace_var'])
    results.append(CheckResult(
        name="Ex4 - Evitare bug {1..$N}",
        passed=not has_brace_var_bug,
        points=2.0 if not has_brace_var_bug else 0,
        max_points=2.0,
        message="Nu are bug-ul brace expansion" if not has_brace_var_bug else "⚠ Bug: {1..$N} nu funcționează!",
        details=["Folosește $(seq 1 $N) sau for ((i=1;i<=N;i++))"] if has_brace_var_bug else []
    ))
    
    # Verificare bug cat | while read
    has_cat_while_bug = has_pattern(content, PATTERNS['bugs']['cat_pipe_while'])
    results.append(CheckResult(
        name="Ex4 - Evitare bug cat|while",
        passed=not has_cat_while_bug,
        points=2.0 if not has_cat_while_bug else 0,
        max_points=2.0,
        message="Nu are bug-ul subshell" if not has_cat_while_bug else "⚠ Bug: cat|while pierde variabile!",
        details=["Folosește while read ... < file"] if has_cat_while_bug else []
    ))
    
    # Verificare while read < file (pattern corect)
    correct_while_read = r'while.*read.*<\s*\S+'
    has_correct_read = has_pattern(content, correct_while_read)
    results.append(CheckResult(
        name="Ex4 - Pattern while read < file",
        passed=has_correct_read,
        points=1.0 if has_correct_read else 0,
        max_points=1.0,
        message="Folosește pattern-ul corect" if has_correct_read else "Nu folosește while read < file"
    ))
    
    return results

def check_ex5_integrated(filepath: Path) -> List[CheckResult]:
    """Verifică exercițiul 5 - Script integrat."""
    results = []
    
    if not filepath.exists():
        return [CheckResult(
            name="Ex5 - Fișier lipsă",
            passed=False, points=0, max_points=15,
            message="Fișierul ex5_integrat.sh nu există"
        )]
    
    with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
        lines = content.split('\n')
    
    # Lungime minimă (50 linii)
    line_count = len([l for l in lines if l.strip() and not l.strip().startswith('#')])
    is_substantial = line_count >= 30
    results.append(CheckResult(
        name="Ex5 - Dimensiune script",
        passed=is_substantial,
        points=3.0 if is_substantial else 1.0,
        max_points=3.0,
        message=f"Script cu {line_count} linii de cod" if is_substantial else f"Script prea scurt ({line_count} linii)"
    ))
    
    # Funcții definite
    has_functions = has_pattern(content, PATTERNS['good_practices']['functions'])
    func_count = count_pattern_matches(content, PATTERNS['good_practices']['functions'])
    results.append(CheckResult(
        name="Ex5 - Folosire funcții",
        passed=has_functions,
        points=3.0 if func_count >= 2 else (1.5 if func_count >= 1 else 0),
        max_points=3.0,
        message=f"Definește {func_count} funcții" if has_functions else "Nu definește funcții"
    ))
    
    # Error handling
    has_error_handling = has_pattern(content, PATTERNS['good_practices']['error_handling'])
    results.append(CheckResult(
        name="Ex5 - Gestionare erori",
        passed=has_error_handling,
        points=3.0 if has_error_handling else 0,
        max_points=3.0,
        message="Gestionează erorile" if has_error_handling else "Nu gestionează erorile"
    ))
    
    # Argumente (getopts sau $1, $2, etc.)
    arg_pattern = r'\$[1-9#@*]|getopts|\$\{[1-9]'
    has_args = has_pattern(content, arg_pattern)
    results.append(CheckResult(
        name="Ex5 - Procesare argumente",
        passed=has_args,
        points=3.0 if has_args else 0,
        max_points=3.0,
        message="Procesează argumente" if has_args else "Nu procesează argumente"
    ))
    
    # Help/usage
    has_help = has_pattern(content, PATTERNS['good_practices']['help'])
    results.append(CheckResult(
        name="Ex5 - Mesaj help/usage",
        passed=has_help,
        points=3.0 if has_help else 0,
        max_points=3.0,
        message="Are opțiune --help" if has_help else "Nu are help message"
    ))
    
    return results

def check_style(student_dir: Path) -> List[CheckResult]:
    """Verifică stilul codului."""
    results = []
    total_comments = 0
    total_lines = 0
    quoted_vars = 0
    unquoted_vars = 0
    
    for filename in EXPECTED_FILES.keys():
        filepath = student_dir / filename
        if not filepath.exists():
            continue
        
        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
            lines = content.split('\n')
        
        total_lines += len(lines)
        total_comments += count_pattern_matches(content, PATTERNS['good_practices']['comments'])
        
        # Verificare quoting variabile
        quoted_vars += count_pattern_matches(content, r'"\$\w+"')
        unquoted_vars += count_pattern_matches(content, r'\$\w+(?!["\'])')
    
    # Comentarii suficiente (>10%)
    comment_ratio = total_comments / max(total_lines, 1)
    good_comments = comment_ratio > 0.05
    results.append(CheckResult(
        name="Stil - Comentarii",
        passed=good_comments,
        points=5.0 if good_comments else (2.0 if total_comments > 5 else 0),
        max_points=5.0,
        message=f"{total_comments} comentarii ({comment_ratio*100:.1f}%)" if good_comments else "Comentarii insuficiente"
    ))
    
    # Variable quoting
    quoting_ratio = quoted_vars / max(quoted_vars + unquoted_vars, 1)
    good_quoting = quoting_ratio > 0.3 or quoted_vars > 5
    results.append(CheckResult(
        name="Stil - Quoting variabile",
        passed=good_quoting,
        points=5.0 if good_quoting else 2.0,
        max_points=5.0,
        message=f"Quoting: {quoted_vars} quoted, {unquoted_vars} unquoted" if good_quoting else "Quoting insuficient"
    ))
    
    return results

# 
# FUNCȚIA PRINCIPALĂ DE EVALUARE
# 

def grade_submission(student_dir: str) -> GradeReport:
    """Evaluează o temă și returnează raportul complet."""
    student_path = Path(student_dir).resolve()
    
    report = GradeReport(
        student_dir=str(student_path),
        timestamp=datetime.now().isoformat()
    )
    
    if not student_path.exists():
        report.errors.append(f"Directorul {student_path} nu există!")
        return report
    
    # Verificări
    all_checks: List[CheckResult] = []
    
    # 1. Structură
    print_subheader("📁 VERIFICARE STRUCTURĂ")
    structure_checks = check_structure(student_path)
    for check in structure_checks:
        print_check(check)
        all_checks.append(check)
    
    # 2. Exercițiu 1 - Operatori
    print_subheader("⚡ EXERCIȚIUL 1: OPERATORI")
    ex1_checks = check_ex1_operators(student_path / 'ex1_operatori.sh')
    for check in ex1_checks:
        print_check(check)
        all_checks.append(check)
    
    # 3. Exercițiu 2 - Redirecționare
    print_subheader("📤 EXERCIȚIUL 2: REDIRECȚIONARE")
    ex2_checks = check_ex2_redirect(student_path / 'ex2_redirectare.sh')
    for check in ex2_checks:
        print_check(check)
        all_checks.append(check)
    
    # 4. Exercițiu 3 - Filtre
    print_subheader("🔧 EXERCIȚIUL 3: FILTRE")
    ex3_checks = check_ex3_filters(student_path / 'ex3_filtre.sh')
    for check in ex3_checks:
        print_check(check)
        all_checks.append(check)
    
    # 5. Exercițiu 4 - Bucle
    print_subheader("🔄 EXERCIȚIUL 4: BUCLE")
    ex4_checks = check_ex4_loops(student_path / 'ex4_bucle.sh')
    for check in ex4_checks:
        print_check(check)
        all_checks.append(check)
    
    # 6. Exercițiu 5 - Integrat
    print_subheader("🎯 EXERCIȚIUL 5: SCRIPT INTEGRAT")
    ex5_checks = check_ex5_integrated(student_path / 'ex5_integrat.sh')
    for check in ex5_checks:
        print_check(check)
        all_checks.append(check)
    
    # 7. Stil
    print_subheader("🎨 VERIFICARE STIL")
    style_checks = check_style(student_path)
    for check in style_checks:
        print_check(check)
        all_checks.append(check)
    
    # Calculare scor total
    report.total_score = sum(c.points for c in all_checks)
    report.max_score = sum(c.max_points for c in all_checks)
    report.percentage = (report.total_score / report.max_score * 100) if report.max_score > 0 else 0
    
    # Determinare notă
    if report.percentage >= 90:
        report.grade = "A"
    elif report.percentage >= 80:
        report.grade = "B"
    elif report.percentage >= 70:
        report.grade = "C"
    elif report.percentage >= 60:
        report.grade = "D"
    elif report.percentage >= 50:
        report.grade = "E"
    else:
        report.grade = "F"
    
    return report

def print_final_report(report: GradeReport) -> None:
    """Afișează raportul final."""
    print_header("📊 RAPORT FINAL")
    
    print(f"\n  {Colors.WHITE}Director:{Colors.RESET} {report.student_dir}")
    print(f"  {Colors.WHITE}Data:{Colors.RESET}     {report.timestamp}")
    print()
    
    # Scor cu bară de progres
    bar_width = 40
    filled = int(report.percentage / 100 * bar_width)
    bar = '█' * filled + '░' * (bar_width - filled)
    
    color = Colors.GREEN if report.percentage >= 70 else (Colors.YELLOW if report.percentage >= 50 else Colors.RED)
    
    print(f"  {Colors.WHITE}Scor:{Colors.RESET}     {report.total_score:.1f} / {report.max_score:.1f}")
    print(f"  {Colors.WHITE}Procent:{Colors.RESET}  {color}{report.percentage:.1f}%{Colors.RESET}")
    print(f"  {Colors.WHITE}Progres:{Colors.RESET}  [{color}{bar}{Colors.RESET}]")
    print()
    print(f"  {Colors.WHITE}NOTA FINALĂ:{Colors.RESET}  {color}{Colors.WHITE}{report.grade}{Colors.RESET}")
    
    # Warnings și errors
    if report.warnings:
        print(f"\n  {Colors.YELLOW}⚠ AVERTISMENTE:{Colors.RESET}")
        for w in report.warnings:
            print(f"    • {w}")
    
    if report.errors:
        print(f"\n  {Colors.RED}✗ ERORI:{Colors.RESET}")
        for e in report.errors:
            print(f"    • {e}")
    
    print()

def save_report(report: GradeReport, output_path: str) -> None:
    """Salvează raportul în format JSON."""
    # Convertire la dict pentru serializare
    report_dict = {
        'student_dir': report.student_dir,
        'timestamp': report.timestamp,
        'total_score': report.total_score,
        'max_score': report.max_score,
        'percentage': report.percentage,
        'grade': report.grade,
        'warnings': report.warnings,
        'errors': report.errors
    }
    
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(report_dict, f, indent=2, ensure_ascii=False)
    
    print(f"  {Colors.GREEN}✓{Colors.RESET} Raport salvat în: {output_path}")

# 
# MAIN
# 

def main():
    """Funcția principală."""
    parser = argparse.ArgumentParser(
        description='Autograder pentru temele Seminarului 3-4 SO',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Exemple:
  python3 S02_01_autograder.py ~/tema_mea/
  python3 S02_01_autograder.py ./student_submissions/Ion_Popescu/
  python3 S02_01_autograder.py --output raport.json ./tema/
        """
    )
    
    parser.add_argument(
        'directory',
        help='Directorul cu tema studentului'
    )
    
    parser.add_argument(
        '-o', '--output',
        help='Fișier JSON pentru salvarea raportului',
        default=None
    )
    
    parser.add_argument(
        '-q', '--quiet',
        action='store_true',
        help='Mod silențios (doar scorul final)'
    )
    
    args = parser.parse_args()
    
    if args.quiet:
        Colors.disable()
    
    print_header("🎓 AUTOGRADER - Seminar 2 SO")
    
    # Evaluare
    report = grade_submission(args.directory)
    
    # Afișare raport final
    print_final_report(report)
    
    # Salvare JSON dacă e specificat
    if args.output:
        save_report(report, args.output)
    
    # Exit code bazat pe notă
    if report.grade in ['A', 'B', 'C']:
        sys.exit(0)
    elif report.grade in ['D', 'E']:
        sys.exit(1)
    else:
        sys.exit(2)

if __name__ == '__main__':
    main()
