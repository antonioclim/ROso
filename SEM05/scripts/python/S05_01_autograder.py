#!/usr/bin/env python3
"""
S05_01_autograder.py - Autograder pentru Scripturi Bash

Sisteme de Operare | ASE București - CSIE
Seminar 5: Advanced Bash Scripting

Evaluează scripturi Bash pentru:
- Robustețe (set -euo pipefail)
- Best practices (local în funcții, declare -A, ghilimele)
- Funcționalitate (execuție corectă)
- Stil (shellcheck)

UTILIZARE:
    python3 S05_01_autograder.py script.sh
    python3 S05_01_autograder.py --batch submissions/
    python3 S05_01_autograder.py script.sh --verbose
"""

import argparse
import os
import re
import subprocess
import sys
import json
from dataclasses import dataclass, field
from typing import List, Dict, Optional, Tuple
from pathlib import Path

@dataclass
class CheckResult:
    """Rezultatul unei verificări."""
    name: str
    passed: bool
    points: float
    max_points: float
    message: str = ""
    details: List[str] = field(default_factory=list)

@dataclass
class GradeReport:
    """Raport complet de notare."""
    script_name: str
    total_score: float
    max_score: float
    checks: List[CheckResult]
    execution_output: str = ""
    shellcheck_output: str = ""
    errors: List[str] = field(default_factory=list)

class BashAutograder:
    """Autograder pentru scripturi Bash."""
    
    def __init__(self, verbose: bool = False):
        self.verbose = verbose
        self.checks: List[CheckResult] = []
    
    def log(self, message: str):
        """Log verbose."""
        if self.verbose:
            print(f"[DEBUG] {message}")
    
    def read_script(self, filepath: str) -> str:
        """Citește conținutul scriptului."""
        with open(filepath, 'r', encoding='utf-8', errors='replace') as f:
            return f.read()
    
    def check_shebang(self, content: str) -> CheckResult:
        """Verifică shebang-ul."""
        first_line = content.split('\n')[0].strip()
        
        valid_shebangs = ['#!/bin/bash', '#!/usr/bin/env bash']
        
        if any(first_line.startswith(s) for s in valid_shebangs):
            return CheckResult(
                name="Shebang",
                passed=True,
                points=1.0,
                max_points=1.0,
                message="Shebang corect"
            )
        else:
            return CheckResult(
                name="Shebang",
                passed=False,
                points=0.0,
                max_points=1.0,
                message=f"Shebang lipsă sau incorect: {first_line[:30]}"
            )
    
    def check_strict_mode(self, content: str) -> CheckResult:
        """Verifică set -euo pipefail."""
        details = []
        points = 0.0
        max_points = 3.0
        
        # Verifică set -e (sau errexit)
        if re.search(r'set\s+-[a-z]*e|set\s+-o\s+errexit', content):
            points += 1.0
            details.append("✓ set -e (errexit)")
        else:
            details.append("✗ set -e lipsă")
        
        # Verifică set -u (sau nounset)
        if re.search(r'set\s+-[a-z]*u|set\s+-o\s+nounset', content):
            points += 1.0
            details.append("✓ set -u (nounset)")
        else:
            details.append("✗ set -u lipsă")
        
        # Verifică pipefail
        if re.search(r'set\s+-o\s+pipefail', content):
            points += 1.0
            details.append("✓ set -o pipefail")
        else:
            details.append("✗ pipefail lipsă")
        
        return CheckResult(
            name="Strict Mode",
            passed=(points == max_points),
            points=points,
            max_points=max_points,
            message="set -euo pipefail" if points == max_points else "Strict mode incomplet",
            details=details
        )
    
    def check_local_variables(self, content: str) -> CheckResult:
        """Verifică folosirea `local` în funcții."""
        # Găsește toate funcțiile
        func_pattern = r'(\w+)\s*\(\)\s*\{([^}]+)\}'
        functions = re.findall(func_pattern, content, re.DOTALL)
        
        if not functions:
            return CheckResult(
                name="Local Variables",
                passed=True,
                points=1.0,
                max_points=2.0,
                message="Nicio funcție definită"
            )
        
        details = []
        issues = 0
        
        for func_name, func_body in functions:
            # Caută atribuiri fără local
            # Exclude linii cu local, readonly, declare, export
            lines = func_body.split('\n')
            for line in lines:
                line = line.strip()
                # Skip comments, empty lines, and proper declarations
                if not line or line.startswith('#'):
                    continue
                if re.match(r'^(local|readonly|declare|export)\s+', line):
                    continue
                # Check for bare assignments
                if re.match(r'^[a-zA-Z_][a-zA-Z0-9_]*=', line):
                    # Exclude common patterns that are OK
                    if not re.match(r'^(OPTIND|OPTARG|REPLY)=', line):
                        issues += 1
                        details.append(f"⚠ În {func_name}(): posibilă variabilă globală: {line[:40]}")
        
        if issues == 0:
            return CheckResult(
                name="Local Variables",
                passed=True,
                points=2.0,
                max_points=2.0,
                message="Toate variabilele din funcții par locale",
                details=details
            )
        else:
            points = max(0, 2.0 - issues * 0.5)
            return CheckResult(
                name="Local Variables",
                passed=False,
                points=points,
                max_points=2.0,
                message=f"{issues} posibile variabile globale în funcții",
                details=details
            )
    
    def check_associative_arrays(self, content: str) -> CheckResult:
        """Verifică declare -A pentru arrays asociative."""
        # Găsește utilizări de arrays cu chei non-numerice
        assoc_usage = re.findall(r'(\w+)\[([a-zA-Z_][a-zA-Z0-9_]*)\]', content)
        
        if not assoc_usage:
            return CheckResult(
                name="Associative Arrays",
                passed=True,
                points=1.0,
                max_points=1.0,
                message="Nicio utilizare de arrays asociative"
            )
        
        # Verifică dacă sunt declarate
        declarations = re.findall(r'declare\s+-A\s+(\w+)', content)
        
        details = []
        issues = 0
        
        for arr_name, _ in set(assoc_usage):
            if arr_name not in declarations:
                issues += 1
                details.append(f"⚠ {arr_name}[key] folosit fără declare -A")
        
        if issues == 0:
            return CheckResult(
                name="Associative Arrays",
                passed=True,
                points=1.0,
                max_points=1.0,
                message="Toate arrays asociative declarate corect",
                details=details
            )
        else:
            return CheckResult(
                name="Associative Arrays",
                passed=False,
                points=0.0,
                max_points=1.0,
                message=f"{issues} arrays asociative fără declare -A",
                details=details
            )
    
    def check_quoted_arrays(self, content: str) -> CheckResult:
        """Verifică ghilimele pentru ${arr[@]}."""
        # Găsește iterări peste arrays
        unquoted = re.findall(r'for\s+\w+\s+in\s+\$\{[^}]+\[@\]\}', content)
        quoted = re.findall(r'for\s+\w+\s+in\s+"\$\{[^}]+\[@\]\}"', content)
        
        total = len(unquoted) + len(quoted)
        
        if total == 0:
            return CheckResult(
                name="Quoted Array Expansion",
                passed=True,
                points=1.0,
                max_points=1.0,
                message="Nicio iterare peste arrays"
            )
        
        if unquoted:
            details = [f"⚠ Iterare fără ghilimele: {u[:50]}" for u in unquoted]
            return CheckResult(
                name="Quoted Array Expansion",
                passed=False,
                points=0.0,
                max_points=1.0,
                message=f'{len(unquoted)} iterări fără ghilimele ("${{arr[@]}}")',
                details=details
            )
        
        return CheckResult(
            name="Quoted Array Expansion",
            passed=True,
            points=1.0,
            max_points=1.0,
            message="Toate iterările au ghilimele"
        )
    
    def check_trap_cleanup(self, content: str) -> CheckResult:
        """Verifică trap pentru cleanup."""
        has_trap_exit = bool(re.search(r'trap\s+[\'"]?\w+[\'"]?\s+EXIT', content))
        has_trap_err = bool(re.search(r'trap\s+.*\s+ERR', content))
        has_cleanup_func = bool(re.search(r'cleanup\s*\(\)', content))
        
        details = []
        points = 0.0
        
        if has_trap_exit:
            points += 1.0
            details.append("✓ trap EXIT")
        else:
            details.append("✗ trap EXIT lipsă")
        
        if has_cleanup_func:
            points += 0.5
            details.append("✓ funcție cleanup()")
        
        if has_trap_err:
            points += 0.5
            details.append("✓ trap ERR")
        
        return CheckResult(
            name="Trap & Cleanup",
            passed=(points >= 1.0),
            points=min(points, 2.0),
            max_points=2.0,
            message="Error handling configurat" if points >= 1.0 else "trap EXIT lipsă",
            details=details
        )
    
    def check_usage_function(self, content: str) -> CheckResult:
        """Verifică existența funcției usage()."""
        has_usage = bool(re.search(r'usage\s*\(\)', content))
        
        if has_usage:
            return CheckResult(
                name="Usage Function",
                passed=True,
                points=0.5,
                max_points=0.5,
                message="Funcție usage() prezentă"
            )
        else:
            return CheckResult(
                name="Usage Function",
                passed=False,
                points=0.0,
                max_points=0.5,
                message="Funcția usage() lipsește"
            )
    
    def run_shellcheck(self, filepath: str) -> Tuple[CheckResult, str]:
        """Rulează shellcheck."""
        try:
            result = subprocess.run(
                ['shellcheck', '-f', 'json', filepath],
                capture_output=True,
                text=True,
                timeout=30
            )
            
            output = result.stdout
            
            try:
                issues = json.loads(output) if output else []
            except json.JSONDecodeError:
                issues = []
            
            errors = [i for i in issues if i.get('level') == 'error']
            warnings = [i for i in issues if i.get('level') == 'warning']
            
            details = []
            for issue in (errors + warnings)[:5]:  # Max 5 issues
                details.append(f"L{issue.get('line', '?')}: {issue.get('message', 'Unknown')[:60]}")
            
            if not errors and not warnings:
                return CheckResult(
                    name="ShellCheck",
                    passed=True,
                    points=2.0,
                    max_points=2.0,
                    message="Niciun warning shellcheck"
                ), output
            elif not errors:
                points = max(0, 2.0 - len(warnings) * 0.2)
                return CheckResult(
                    name="ShellCheck",
                    passed=False,
                    points=points,
                    max_points=2.0,
                    message=f"{len(warnings)} warnings",
                    details=details
                ), output
            else:
                return CheckResult(
                    name="ShellCheck",
                    passed=False,
                    points=0.0,
                    max_points=2.0,
                    message=f"{len(errors)} errors, {len(warnings)} warnings",
                    details=details
                ), output
                
        except FileNotFoundError:
            return CheckResult(
                name="ShellCheck",
                passed=True,
                points=1.0,
                max_points=2.0,
                message="shellcheck not installed (skipped)"
            ), ""
        except subprocess.TimeoutExpired:
            return CheckResult(
                name="ShellCheck",
                passed=False,
                points=0.0,
                max_points=2.0,
                message="shellcheck timeout"
            ), ""
    
    def run_script(self, filepath: str, args: List[str] = None, 
                   input_data: str = None, timeout: int = 10) -> Tuple[bool, str, int]:
        """Execută scriptul și returnează output."""
        try:
            cmd = ['bash', filepath] + (args or [])
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                input=input_data,
                timeout=timeout,
                cwd=os.path.dirname(filepath) or '.'
            )
            return True, result.stdout + result.stderr, result.returncode
        except subprocess.TimeoutExpired:
            return False, "Timeout expired", -1
        except Exception as e:
            return False, str(e), -1
    
    def grade(self, filepath: str, test_cases: List[Dict] = None) -> GradeReport:
        """Notează un script."""
        self.log(f"Grading: {filepath}")
        
        if not os.path.exists(filepath):
            return GradeReport(
                script_name=filepath,
                total_score=0,
                max_score=0,
                checks=[],
                errors=[f"Fișierul nu există: {filepath}"]
            )
        
        content = self.read_script(filepath)
        checks = []
        
        # Verificări statice
        checks.append(self.check_shebang(content))
        checks.append(self.check_strict_mode(content))
        checks.append(self.check_local_variables(content))
        checks.append(self.check_associative_arrays(content))
        checks.append(self.check_quoted_arrays(content))
        checks.append(self.check_trap_cleanup(content))
        checks.append(self.check_usage_function(content))
        
        # ShellCheck
        shellcheck_result, shellcheck_output = self.run_shellcheck(filepath)
        checks.append(shellcheck_result)
        
        # Test cases (dacă sunt furnizate)
        execution_output = ""
        if test_cases:
            for i, tc in enumerate(test_cases):
                success, output, code = self.run_script(
                    filepath,
                    args=tc.get('args'),
                    input_data=tc.get('input'),
                    timeout=tc.get('timeout', 10)
                )
                execution_output += f"--- Test {i+1} ---\n{output}\n"
                
                expected_code = tc.get('expected_code', 0)
                expected_output = tc.get('expected_output')
                
                passed = (code == expected_code)
                if expected_output and expected_output not in output:
                    passed = False
                
                checks.append(CheckResult(
                    name=f"Test Case {i+1}",
                    passed=passed,
                    points=tc.get('points', 1.0) if passed else 0.0,
                    max_points=tc.get('points', 1.0),
                    message=tc.get('description', f"Test {i+1}"),
                    details=[f"Exit code: {code}", f"Output: {output[:100]}"]
                ))
        
        total_score = sum(c.points for c in checks)
        max_score = sum(c.max_points for c in checks)
        
        return GradeReport(
            script_name=filepath,
            total_score=total_score,
            max_score=max_score,
            checks=checks,
            execution_output=execution_output,
            shellcheck_output=shellcheck_output
        )

def print_report(report: GradeReport, verbose: bool = False):
    """Afișează raportul de notare."""
    print(f"\n{'='*60}")
    print(f"📋 RAPORT: {report.script_name}")
    print(f"{'='*60}")
    
    for check in report.checks:
        status = "✅" if check.passed else "❌"
        print(f"\n{status} {check.name}: {check.points}/{check.max_points}")
        print(f"   {check.message}")
        if verbose and check.details:
            for detail in check.details:
                print(f"      {detail}")
    
    print(f"\n{'─'*60}")
    percentage = (report.total_score / report.max_score * 100) if report.max_score > 0 else 0
    print(f"📊 TOTAL: {report.total_score:.1f}/{report.max_score:.1f} ({percentage:.0f}%)")
    
    if report.errors:
        print(f"\n⚠️ ERORI:")
        for error in report.errors:
            print(f"   {error}")
    
    print(f"{'='*60}\n")

def main():
    parser = argparse.ArgumentParser(
        description='Autograder pentru scripturi Bash'
    )
    parser.add_argument('script', nargs='?', help='Script de evaluat')
    parser.add_argument('--batch', '-b', help='Director cu scripturi de evaluat')
    parser.add_argument('--verbose', '-v', action='store_true', help='Output detaliat')
    parser.add_argument('--json', action='store_true', help='Output JSON')
    parser.add_argument('--test-config', help='Fișier JSON cu test cases')
    
    args = parser.parse_args()
    
    grader = BashAutograder(verbose=args.verbose)
    
    # Încarcă test cases dacă specificate
    test_cases = None
    if args.test_config:
        with open(args.test_config) as f:
            test_cases = json.load(f)
    
    scripts = []
    
    if args.batch:
        scripts = list(Path(args.batch).glob('*.sh'))
    elif args.script:
        scripts = [Path(args.script)]
    else:
        parser.print_help()
        sys.exit(1)
    
    reports = []
    for script in scripts:
        report = grader.grade(str(script), test_cases)
        reports.append(report)
        
        if not args.json:
            print_report(report, args.verbose)
    
    if args.json:
        output = [{
            'script': r.script_name,
            'score': r.total_score,
            'max_score': r.max_score,
            'percentage': (r.total_score / r.max_score * 100) if r.max_score > 0 else 0,
            'checks': [{
                'name': c.name,
                'passed': c.passed,
                'points': c.points,
                'max_points': c.max_points,
                'message': c.message
            } for c in r.checks]
        } for r in reports]
        print(json.dumps(output, indent=2))
    
    # Exit code bazat pe scor
    if reports:
        avg_percentage = sum(
            (r.total_score / r.max_score * 100) if r.max_score > 0 else 0 
            for r in reports
        ) / len(reports)
        sys.exit(0 if avg_percentage >= 60 else 1)

if __name__ == '__main__':
    main()
