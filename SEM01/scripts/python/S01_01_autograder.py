#!/usr/bin/env python3
"""
═══════════════════════════════════════════════════════════════════════════════
AUTO-GRADER - Seminar 1-2: Shell Bash
Sisteme de Operare | ASE București - CSIE

Scop: Verificare automată a temelor și exercițiilor
Utilizare: python3 autograder.py <director_student>
═══════════════════════════════════════════════════════════════════════════════
"""

import os
import sys
import subprocess
import json
import re
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Tuple, Optional

# ANSI Colors
class Colors:
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    CYAN = '\033[0;36m'
    WHITE = '\033[1;37m'
    NC = '\033[0m'
    BOLD = '\033[1m'

def log_info(msg: str) -> None:
    print(f"{Colors.BLUE}[INFO]{Colors.NC} {msg}")

def log_success(msg: str) -> None:
    print(f"{Colors.GREEN}[✓]{Colors.NC} {msg}")

def log_error(msg: str) -> None:
    print(f"{Colors.RED}[✗]{Colors.NC} {msg}")

def log_warning(msg: str) -> None:
    print(f"{Colors.YELLOW}[!]{Colors.NC} {msg}")

# 
# TEST DEFINITIONS
# 

class TestCase:
    def __init__(self, name: str, points: int, description: str):
        self.name = name
        self.points = points
        self.description = description
        self.passed = False
        self.feedback = ""
    
    def run(self, student_dir: Path) -> bool:
        raise NotImplementedError

class FileExistsTest(TestCase):
    def __init__(self, name: str, points: int, description: str, filepath: str):
        super().__init__(name, points, description)
        self.filepath = filepath
    
    def run(self, student_dir: Path) -> bool:
        target = student_dir / self.filepath
        if target.exists():
            self.passed = True
            self.feedback = f"Fișierul {self.filepath} există"
        else:
            self.feedback = f"Fișierul {self.filepath} nu a fost găsit"
        return self.passed

class DirectoryStructureTest(TestCase):
    def __init__(self, name: str, points: int, description: str, required_dirs: List[str]):
        super().__init__(name, points, description)
        self.required_dirs = required_dirs
    
    def run(self, student_dir: Path) -> bool:
        missing = []
        for d in self.required_dirs:
            if not (student_dir / d).is_dir():
                missing.append(d)
        
        if not missing:
            self.passed = True
            self.feedback = "Toate directoarele necesare există"
        else:
            self.feedback = f"Directoare lipsă: {', '.join(missing)}"
        return self.passed

class BashSyntaxTest(TestCase):
    def __init__(self, name: str, points: int, description: str, script_path: str):
        super().__init__(name, points, description)
        self.script_path = script_path
    
    def run(self, student_dir: Path) -> bool:
        script = student_dir / self.script_path
        if not script.exists():
            self.feedback = f"Scriptul {self.script_path} nu există"
            return False
        
        try:
            result = subprocess.run(
                ['bash', '-n', str(script)],
                capture_output=True,
                text=True,
                timeout=5
            )
            if result.returncode == 0:
                self.passed = True
                self.feedback = "Sintaxa Bash este corectă"
            else:
                self.feedback = f"Erori de sintaxă: {result.stderr[:200]}"
        except subprocess.TimeoutExpired:
            self.feedback = "Verificarea a depășit timeout-ul"
        except Exception as e:
            self.feedback = f"Eroare la verificare: {str(e)}"
        
        return self.passed

class BashExecutionTest(TestCase):
    def __init__(self, name: str, points: int, description: str, 
                 script_path: str, expected_output: str = None,
                 expected_pattern: str = None):
        super().__init__(name, points, description)
        self.script_path = script_path
        self.expected_output = expected_output
        self.expected_pattern = expected_pattern
    
    def run(self, student_dir: Path) -> bool:
        script = student_dir / self.script_path
        if not script.exists():
            self.feedback = f"Scriptul {self.script_path} nu există"
            return False
        
        try:
            result = subprocess.run(
                ['bash', str(script)],
                capture_output=True,
                text=True,
                timeout=10,
                cwd=student_dir
            )
            
            output = result.stdout.strip()
            
            if self.expected_output:
                if self.expected_output in output:
                    self.passed = True
                    self.feedback = "Output-ul conține rezultatul așteptat"
                else:
                    self.feedback = f"Output așteptat: '{self.expected_output}', primit: '{output[:100]}'"
            
            elif self.expected_pattern:
                if re.search(self.expected_pattern, output):
                    self.passed = True
                    self.feedback = "Output-ul corespunde pattern-ului așteptat"
                else:
                    self.feedback = f"Output-ul nu corespunde pattern-ului: {self.expected_pattern}"
            else:
                # Just check it runs without error
                if result.returncode == 0:
                    self.passed = True
                    self.feedback = "Scriptul s-a executat cu succes"
                else:
                    self.feedback = f"Scriptul a returnat eroare: {result.stderr[:200]}"
                    
        except subprocess.TimeoutExpired:
            self.feedback = "Execuția a depășit timeout-ul (10s)"
        except Exception as e:
            self.feedback = f"Eroare la execuție: {str(e)}"
        
        return self.passed

class BashrcConfigTest(TestCase):
    def __init__(self, name: str, points: int, description: str,
                 required_aliases: List[str] = None,
                 required_exports: List[str] = None,
                 required_functions: List[str] = None):
        super().__init__(name, points, description)
        self.required_aliases = required_aliases or []
        self.required_exports = required_exports or []
        self.required_functions = required_functions or []
    
    def run(self, student_dir: Path) -> bool:
        bashrc = student_dir / '.bashrc'
        if not bashrc.exists():
            bashrc = student_dir / 'bashrc'  # Try without dot
        
        if not bashrc.exists():
            self.feedback = "Fișierul .bashrc nu a fost găsit"
            return False
        
        content = bashrc.read_text()
        missing = []
        
        for alias in self.required_aliases:
            if f"alias {alias}=" not in content:
                missing.append(f"alias {alias}")
        
        for export in self.required_exports:
            if f"export {export}" not in content:
                missing.append(f"export {export}")
        
        for func in self.required_functions:
            if f"{func}()" not in content and f"function {func}" not in content:
                missing.append(f"function {func}")
        
        if not missing:
            self.passed = True
            self.feedback = "Toate configurările necesare sunt prezente"
        else:
            self.feedback = f"Configurări lipsă: {', '.join(missing)}"
        
        return self.passed

class GlobbingTest(TestCase):
    def __init__(self, name: str, points: int, description: str,
                 setup_files: List[str], pattern: str, expected_matches: List[str]):
        super().__init__(name, points, description)
        self.setup_files = setup_files
        self.pattern = pattern
        self.expected_matches = expected_matches
    
    def run(self, student_dir: Path) -> bool:
        # Create temporary test directory
        test_dir = student_dir / 'glob_test_temp'
        test_dir.mkdir(exist_ok=True)
        
        try:
            # Create test files
            for f in self.setup_files:
                (test_dir / f).touch()
            
            # Run glob expansion
            result = subprocess.run(
                f'cd {test_dir} && ls {self.pattern} 2>/dev/null | sort',
                shell=True,
                capture_output=True,
                text=True
            )
            
            actual_matches = sorted([f.strip() for f in result.stdout.strip().split('\n') if f.strip()])
            expected_sorted = sorted(self.expected_matches)
            
            if actual_matches == expected_sorted:
                self.passed = True
                self.feedback = f"Pattern '{self.pattern}' a produs rezultatele corecte"
            else:
                self.feedback = f"Așteptat: {expected_sorted}, Primit: {actual_matches}"
                
        finally:
            # Cleanup
            import shutil
            shutil.rmtree(test_dir, ignore_errors=True)
        
        return self.passed

# 
# HOMEWORK DEFINITION
# 

def get_homework_tests() -> List[TestCase]:
    """Define all tests for Seminar 1-2 homework."""
    return [
        # Exercițiu 1: Structură Proiect (20 puncte)
        DirectoryStructureTest(
            "E1.1: Structură proiect",
            10,
            "Verifică dacă structura proiectului este corectă",
            ['proiect/src', 'proiect/docs', 'proiect/tests']
        ),
        FileExistsTest(
            "E1.2: README.md",
            5,
            "Verifică existența fișierului README.md",
            'proiect/README.md'
        ),
        FileExistsTest(
            "E1.3: main.sh",
            5,
            "Verifică existența scriptului principal",
            'proiect/src/main.sh'
        ),
        
        # Exercițiu 2: Script Variabile (25 puncte)
        BashSyntaxTest(
            "E2.1: Sintaxă variabile.sh",
            10,
            "Verifică sintaxa scriptului variabile.sh",
            'proiect/src/variabile.sh'
        ),
        BashExecutionTest(
            "E2.2: Execuție variabile.sh",
            15,
            "Verifică execuția și output-ul scriptului",
            'proiect/src/variabile.sh',
            expected_pattern=r'(USER|HOME|SHELL|PATH)'
        ),
        
        # Exercițiu 3: Configurare .bashrc (25 puncte)
        BashrcConfigTest(
            "E3.1: Alias-uri",
            10,
            "Verifică prezența alias-urilor cerute",
            required_aliases=['ll', 'cls']
        ),
        BashrcConfigTest(
            "E3.2: Funcție mkcd",
            10,
            "Verifică prezența funcției mkcd",
            required_functions=['mkcd']
        ),
        BashrcConfigTest(
            "E3.3: Export PATH",
            5,
            "Verifică exportul PATH modificat",
            required_exports=['PATH']
        ),
        
        # Exercițiu 4: Globbing (20 puncte)
        GlobbingTest(
            "E4.1: Pattern *.txt",
            10,
            "Verifică înțelegerea pattern-ului *.txt",
            ['file1.txt', 'file2.txt', 'doc.pdf', 'notes.txt'],
            '*.txt',
            ['file1.txt', 'file2.txt', 'notes.txt']
        ),
        GlobbingTest(
            "E4.2: Pattern file?.txt",
            10,
            "Verifică înțelegerea pattern-ului file?.txt",
            ['file1.txt', 'file2.txt', 'file10.txt', 'fileA.txt'],
            'file?.txt',
            ['file1.txt', 'file2.txt', 'fileA.txt']
        ),
        
        # Exercițiu 5: Script Integrat (10 puncte)
        BashSyntaxTest(
            "E5.1: Script final",
            5,
            "Verifică sintaxa scriptului final",
            'proiect/src/info_sistem.sh'
        ),
        BashExecutionTest(
            "E5.2: Execuție script final",
            5,
            "Verifică că scriptul afișează informații de sistem",
            'proiect/src/info_sistem.sh',
            expected_pattern=r'(Linux|Ubuntu|user|home)'
        ),
    ]

# 
# GRADER
# 

class Grader:
    def __init__(self, student_dir: Path):
        self.student_dir = student_dir
        self.tests = get_homework_tests()
        self.results: Dict[str, dict] = {}
        self.total_points = 0
        self.earned_points = 0
    
    def run_all_tests(self) -> None:
        print(f"\n{Colors.CYAN}{'═' * 70}{Colors.NC}")
        print(f"{Colors.WHITE}{Colors.BOLD}  AUTO-GRADER: Seminar 1-2 Shell Bash{Colors.NC}")
        print(f"{Colors.CYAN}{'═' * 70}{Colors.NC}\n")
        
        log_info(f"Verificare director: {self.student_dir}")
        log_info(f"Timestamp: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        
        for test in self.tests:
            self.total_points += test.points
            
            print(f"{Colors.YELLOW}▶ {test.name}{Colors.NC}")
            print(f"  {test.description}")
            
            try:
                passed = test.run(self.student_dir)
                if passed:
                    self.earned_points += test.points
                    log_success(f"{test.feedback} (+{test.points}p)")
                else:
                    log_error(f"{test.feedback} (0/{test.points}p)")
            except Exception as e:
                log_error(f"Eroare la test: {str(e)}")
            
            self.results[test.name] = {
                'passed': test.passed,
                'points': test.points if test.passed else 0,
                'max_points': test.points,
                'feedback': test.feedback
            }
            print()
    
    def print_summary(self) -> None:
        print(f"{Colors.CYAN}{'═' * 70}{Colors.NC}")
        print(f"{Colors.WHITE}{Colors.BOLD}  REZULTAT FINAL{Colors.NC}")
        print(f"{Colors.CYAN}{'═' * 70}{Colors.NC}\n")
        
        passed_tests = sum(1 for r in self.results.values() if r['passed'])
        total_tests = len(self.results)
        
        percentage = (self.earned_points / self.total_points * 100) if self.total_points > 0 else 0
        
        print(f"  Teste trecute: {passed_tests}/{total_tests}")
        print(f"  Punctaj: {Colors.BOLD}{self.earned_points}/{self.total_points}{Colors.NC} ({percentage:.1f}%)\n")
        
        # Grade
        if percentage >= 90:
            grade = "A"
            color = Colors.GREEN
            message = "Excelent! Ai înțeles foarte bine materialul."
        elif percentage >= 80:
            grade = "B"
            color = Colors.GREEN
            message = "Foarte bine! Câteva aspecte minore de revizuit."
        elif percentage >= 70:
            grade = "C"
            color = Colors.YELLOW
            message = "Bine. Revizuiește secțiunile unde ai pierdut puncte."
        elif percentage >= 60:
            grade = "D"
            color = Colors.YELLOW
            message = "Suficient. Recomand să repeți exercițiile."
        else:
            grade = "F"
            color = Colors.RED
            message = "Insuficient. Te rog să revii asupra materialului."
        
        print(f"  Notă: {color}{Colors.BOLD}{grade}{Colors.NC}")
        print(f"  {message}\n")
        
        # Detailed feedback
        print(f"{Colors.CYAN}Detalii:{Colors.NC}")
        for name, result in self.results.items():
            status = f"{Colors.GREEN}✓{Colors.NC}" if result['passed'] else f"{Colors.RED}✗{Colors.NC}"
            print(f"  {status} {name}: {result['points']}/{result['max_points']}p")
        print()
    
    def export_json(self, output_path: Path) -> None:
        report = {
            'timestamp': datetime.now().isoformat(),
            'student_dir': str(self.student_dir),
            'total_points': self.total_points,
            'earned_points': self.earned_points,
            'percentage': self.earned_points / self.total_points * 100 if self.total_points > 0 else 0,
            'tests': self.results
        }
        
        with open(output_path, 'w') as f:
            json.dump(report, f, indent=2)
        
        log_info(f"Raport exportat: {output_path}")

# 
# MAIN
# 

def main():
    if len(sys.argv) < 2:
        print(f"Utilizare: {sys.argv[0]} <director_student> [--json output.json]")
        print(f"\nExemplu: {sys.argv[0]} ~/teme/PopescuIon")
        sys.exit(1)
    
    student_dir = Path(sys.argv[1]).resolve()
    
    if not student_dir.exists():
        log_error(f"Directorul {student_dir} nu există!")
        sys.exit(1)
    
    grader = Grader(student_dir)
    grader.run_all_tests()
    grader.print_summary()
    
    # Export JSON if requested
    if '--json' in sys.argv:
        json_index = sys.argv.index('--json')
        if json_index + 1 < len(sys.argv):
            grader.export_json(Path(sys.argv[json_index + 1]))

if __name__ == '__main__':
    main()
