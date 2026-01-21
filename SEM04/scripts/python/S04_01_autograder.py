#!/usr/bin/env python3
"""
S04_01_autograder.py - Autograder pentru Seminarul 7-8: Text Processing

Evaluează automat soluțiile studenților pentru exercițiile de grep, sed, awk.

Usage:
    python3 S04_01_autograder.py <submission_file> [--verbose]
    python3 S04_01_autograder.py --self-test
"""

import subprocess
import sys
import os
import json
import tempfile
from pathlib import Path
from dataclasses import dataclass
from typing import Optional, Tuple, List

#===============================================================================
# CONFIGURARE
#===============================================================================

DATA_DIR = Path.home() / "demo_sem4" / "data"

@dataclass
class TestCase:
    """Definește un test case pentru autograder."""
    id: str
    description: str
    expected_command: str
    points: int
    partial_credit: bool = True
    hints: List[str] = None

# Definirea exercițiilor și testelor
EXERCISES = {
    # GREP Exercises
    "G1": TestCase(
        id="G1",
        description="Găsește liniile cu cod 404 în access.log",
        expected_command="grep ' 404 ' access.log",
        points=10,
        hints=["Pattern-ul include spații în jurul lui 404"]
    ),
    "G2": TestCase(
        id="G2",
        description="Numără cererile POST",
        expected_command="grep -c 'POST' access.log",
        points=10,
        hints=["Folosește grep -c pentru numărare"]
    ),
    "G3": TestCase(
        id="G3",
        description="Extrage IP-uri unice",
        expected_command="grep -oE '^[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+' access.log | sort -u",
        points=15,
        hints=["Combină grep -o cu sort -u"]
    ),
    "G4": TestCase(
        id="G4",
        description="Extrage email-uri valide",
        expected_command="grep -E '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$' emails.txt",
        points=15,
        hints=["Folosește regex pentru validare email"]
    ),
    
    # SED Exercises
    "S1": TestCase(
        id="S1",
        description="Înlocuiește localhost cu 127.0.0.1",
        expected_command="sed 's/localhost/127.0.0.1/g' config.txt",
        points=10,
        hints=["Nu uita flag-ul /g pentru toate aparițiile"]
    ),
    "S2": TestCase(
        id="S2",
        description="Șterge comentariile din config",
        expected_command="sed '/^#/d' config.txt",
        points=10,
        hints=["Pattern /^#/d șterge liniile care încep cu #"]
    ),
    "S3": TestCase(
        id="S3",
        description="Șterge comentarii și linii goale",
        expected_command="sed '/^#/d; /^$/d' config.txt",
        points=15,
        hints=["Combină /^#/d și /^$/d"]
    ),
    
    # AWK Exercises
    "A1": TestCase(
        id="A1",
        description="Afișează coloana Name din CSV",
        expected_command="awk -F',' '{print $2}' employees.csv",
        points=10,
        hints=["Folosește -F',' pentru CSV"]
    ),
    "A2": TestCase(
        id="A2",
        description="Suma salariilor (skip header)",
        expected_command="awk -F',' 'NR > 1 {sum += $4} END {print sum}' employees.csv",
        points=15,
        hints=["NR > 1 pentru skip header, END pentru afișare"]
    ),
    "A3": TestCase(
        id="A3",
        description="Numără angajați per departament",
        expected_command="awk -F',' 'NR > 1 {count[$3]++} END {for (d in count) print d, count[d]}' employees.csv",
        points=20,
        hints=["Folosește array asociativ pentru numărare"]
    ),
}

#===============================================================================
# FUNCȚII DE EVALUARE
#===============================================================================

def run_command(cmd: str, cwd: Path, timeout: int = 10) -> Tuple[str, str, int]:
    """Rulează o comandă și returnează (stdout, stderr, returncode)."""
    try:
        result = subprocess.run(
            cmd,
            shell=True,
            capture_output=True,
            text=True,
            timeout=timeout,
            cwd=cwd
        )
        return result.stdout.strip(), result.stderr.strip(), result.returncode
    except subprocess.TimeoutExpired:
        return "", "TIMEOUT", -1
    except Exception as e:
        return "", str(e), -1

def normalize_output(output: str) -> str:
    """Normalizează output-ul pentru comparare flexibilă."""
    lines = output.strip().split('\n')
    lines = [' '.join(line.split()) for line in lines]  # Normalize whitespace
    lines = sorted(lines)  # Sort pentru ordine consistentă
    return '\n'.join(lines)

def compare_outputs(expected: str, actual: str, exact: bool = False) -> Tuple[bool, float]:
    """
    Compară două output-uri.
    Returnează (match, similarity_score).
    """
    if exact:
        return expected == actual, 1.0 if expected == actual else 0.0
    
    # Normalizare
    exp_norm = normalize_output(expected)
    act_norm = normalize_output(actual)
    
    if exp_norm == act_norm:
        return True, 1.0
    
    # Calculează similaritate
    exp_lines = set(exp_norm.split('\n'))
    act_lines = set(act_norm.split('\n'))
    
    if not exp_lines:
        return False, 0.0
    
    correct = len(exp_lines.intersection(act_lines))
    total = len(exp_lines)
    similarity = correct / total
    
    return similarity >= 0.9, similarity

def evaluate_exercise(
    exercise_id: str,
    student_command: str,
    verbose: bool = False
) -> dict:
    """
    Evaluează o soluție pentru un exercițiu.
    
    Returns:
        dict cu 'score', 'max_points', 'feedback', 'passed'
    """
    if exercise_id not in EXERCISES:
        return {
            'score': 0,
            'max_points': 0,
            'feedback': f"Exercițiu necunoscut: {exercise_id}",
            'passed': False
        }
    
    exercise = EXERCISES[exercise_id]
    
    # Verifică dacă datele există
    if not DATA_DIR.exists():
        return {
            'score': 0,
            'max_points': exercise.points,
            'feedback': "Directorul de date nu există. Rulează setup_seminar.sh",
            'passed': False
        }
    
    # Rulează comanda așteptată
    expected_out, expected_err, expected_rc = run_command(
        exercise.expected_command, DATA_DIR
    )
    
    # Rulează comanda studentului
    student_out, student_err, student_rc = run_command(
        student_command, DATA_DIR
    )
    
    if verbose:
        print(f"\n[DEBUG] Expected output:\n{expected_out[:500]}...")
        print(f"\n[DEBUG] Student output:\n{student_out[:500]}...")
    
    # Verifică erori
    if student_err and "TIMEOUT" in student_err:
        return {
            'score': 0,
            'max_points': exercise.points,
            'feedback': "Comanda a expirat (timeout). Verifică bucle infinite.",
            'passed': False
        }
    
    if student_rc != 0 and student_rc != expected_rc:
        feedback = f"Comanda a returnat eroare: {student_err}"
        if exercise.hints:
            feedback += f"\nHint: {exercise.hints[0]}"
        return {
            'score': 0,
            'max_points': exercise.points,
            'feedback': feedback,
            'passed': False
        }
    
    # Compară output-urile
    passed, similarity = compare_outputs(expected_out, student_out)
    
    if passed:
        return {
            'score': exercise.points,
            'max_points': exercise.points,
            'feedback': "✓ Corect!",
            'passed': True
        }
    
    # Partial credit
    if exercise.partial_credit and similarity > 0.5:
        partial_score = int(exercise.points * similarity)
        feedback = f"Parțial corect ({similarity*100:.0f}% din output)"
        if exercise.hints:
            feedback += f"\nHint: {exercise.hints[0]}"
        return {
            'score': partial_score,
            'max_points': exercise.points,
            'feedback': feedback,
            'passed': False
        }
    
    # Incorect
    feedback = "Output incorect"
    if exercise.hints:
        feedback += f"\nHint: {exercise.hints[0]}"
    return {
        'score': 0,
        'max_points': exercise.points,
        'feedback': feedback,
        'passed': False
    }

#===============================================================================
# FUNCȚII PRINCIPALE
#===============================================================================

def grade_submission(submission_file: Path, verbose: bool = False) -> dict:
    """
    Evaluează un fișier de submisie.
    
    Format submisie (JSON):
    {
        "student_id": "123456",
        "solutions": {
            "G1": "grep ' 404 ' access.log",
            "G2": "grep -c 'POST' access.log",
            ...
        }
    }
    """
    try:
        with open(submission_file) as f:
            submission = json.load(f)
    except Exception as e:
        return {
            'error': f"Nu pot citi fișierul: {e}",
            'total_score': 0,
            'max_score': 0
        }
    
    student_id = submission.get('student_id', 'UNKNOWN')
    solutions = submission.get('solutions', {})
    
    results = {
        'student_id': student_id,
        'exercises': {},
        'total_score': 0,
        'max_score': 0
    }
    
    for ex_id, student_cmd in solutions.items():
        result = evaluate_exercise(ex_id, student_cmd, verbose)
        results['exercises'][ex_id] = result
        results['total_score'] += result['score']
        results['max_score'] += result['max_points']
    
    return results

def print_results(results: dict):
    """Afișează rezultatele într-un format frumos."""
    print("\n" + "="*60)
    print(f"REZULTATE AUTOGRADER - Student: {results.get('student_id', 'N/A')}")
    print("="*60)
    
    if 'error' in results:
        print(f"\n❌ EROARE: {results['error']}")
        return
    
    for ex_id, ex_result in results['exercises'].items():
        status = "✓" if ex_result['passed'] else "✗"
        print(f"\n{status} {ex_id}: {ex_result['score']}/{ex_result['max_points']} puncte")
        print(f"   {ex_result['feedback']}")
    
    print("\n" + "-"*60)
    percentage = (results['total_score'] / results['max_score'] * 100) if results['max_score'] > 0 else 0
    print(f"TOTAL: {results['total_score']}/{results['max_score']} ({percentage:.1f}%)")
    print("="*60)

def self_test():
    """Rulează auto-test pentru verificarea funcționalității."""
    print("Running self-test...")
    
    # Creează o submisie de test
    test_submission = {
        "student_id": "TEST",
        "solutions": {
            "G1": "grep ' 404 ' access.log",
            "G2": "grep -c 'POST' access.log",
            "S1": "sed 's/localhost/127.0.0.1/g' config.txt"
        }
    }
    
    with tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False) as f:
        json.dump(test_submission, f)
        temp_file = f.name
    
    try:
        results = grade_submission(Path(temp_file), verbose=True)
        print_results(results)
        
        if results['total_score'] > 0:
            print("\n✓ Self-test passed!")
        else:
            print("\n✗ Self-test failed - verifică că datele există")
    finally:
        os.unlink(temp_file)

#===============================================================================
# MAIN
#===============================================================================

def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)
    
    if sys.argv[1] == '--self-test':
        self_test()
        sys.exit(0)
    
    submission_file = Path(sys.argv[1])
    verbose = '--verbose' in sys.argv or '-v' in sys.argv
    
    if not submission_file.exists():
        print(f"Fișierul nu există: {submission_file}")
        sys.exit(1)
    
    results = grade_submission(submission_file, verbose)
    print_results(results)

if __name__ == '__main__':
    main()
