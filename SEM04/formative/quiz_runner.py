#!/usr/bin/env python3
"""
quiz_runner.py — Rulează quiz-ul formativ din format YAML

Sisteme de Operare | ASE București - CSIE
Seminarul 04: Text Processing

Utilizare:
    python3 quiz_runner.py quiz.yaml
    python3 quiz_runner.py quiz.yaml --shuffle
    python3 quiz_runner.py quiz.yaml --category understand
    python3 quiz_runner.py --self-test
"""

import sys
import random
from pathlib import Path
from dataclasses import dataclass, field
from typing import Optional

# ═══════════════════════════════════════════════════════════════════════════════
# CONFIGURARE
# ═══════════════════════════════════════════════════════════════════════════════

YAML_AVAILABLE = False
try:
    import yaml
    YAML_AVAILABLE = True
except ImportError:
    pass


@dataclass
class Question:
    """Reprezintă o întrebare din quiz."""
    id: str
    tip: str
    bloom: str
    text: str
    punctaj: int
    lo: list = field(default_factory=list)
    optiuni: list = field(default_factory=list)
    corect: int = 0
    explicatie: str = ""
    raspuns_corect: str = ""
    misconceptii: dict = field(default_factory=dict)


@dataclass
class QuizResult:
    """Rezultatul unui quiz."""
    total_puncte: int
    puncte_obtinute: int
    raspunsuri_corecte: int
    total_intrebari: int
    detalii: list = field(default_factory=list)


# ═══════════════════════════════════════════════════════════════════════════════
# FUNCȚII PRINCIPALE
# ═══════════════════════════════════════════════════════════════════════════════

def load_quiz(filepath: str) -> tuple[dict, list[Question]]:
    """Încarcă quiz-ul din fișierul YAML."""
    if not YAML_AVAILABLE:
        print("EROARE: Biblioteca 'pyyaml' nu este instalată.")
        print("Rulează: pip install pyyaml --break-system-packages")
        sys.exit(1)
    
    path = Path(filepath)
    if not path.exists():
        print(f"EROARE: Fișierul '{filepath}' nu există.")
        sys.exit(1)
    
    with open(path, 'r', encoding='utf-8') as f:
        data = yaml.safe_load(f)
    
    metadata = data.get('metadata', {})
    questions = []
    
    for q_data in data.get('intrebari', []):
        q = Question(
            id=q_data.get('id', ''),
            tip=q_data.get('tip', 'mcq'),
            bloom=q_data.get('bloom', ''),
            text=q_data.get('text', '').strip(),
            punctaj=q_data.get('punctaj', 0),
            lo=q_data.get('lo', []),
            optiuni=q_data.get('optiuni', []),
            corect=q_data.get('corect', 0),
            explicatie=q_data.get('explicatie', '').strip(),
            raspuns_corect=q_data.get('raspuns_corect', ''),
            misconceptii=q_data.get('misconceptii', {})
        )
        questions.append(q)
    
    return metadata, questions


def display_question(q: Question, index: int, total: int) -> None:
    """Afișează o întrebare în terminal."""
    print("\n" + "═" * 70)
    print(f"  Întrebarea {index}/{total} | {q.bloom.upper()} | {q.punctaj} puncte")
    print("═" * 70)
    print(f"\n{q.text}")
    
    if q.tip in ('mcq', 'predict'):
        print()
        for i, opt in enumerate(q.optiuni):
            print(f"  [{chr(65 + i)}] {opt}")
    elif q.tip == 'fill':
        print("\n  [Completează răspunsul]")


def get_user_answer(q: Question) -> str:
    """Obține răspunsul utilizatorului."""
    if q.tip in ('mcq', 'predict'):
        valid = [chr(65 + i) for i in range(len(q.optiuni))]
        while True:
            ans = input(f"\nRăspunsul tău ({'/'.join(valid)}): ").strip().upper()
            if ans in valid:
                return ans
            print(f"  Introdu una din opțiunile: {', '.join(valid)}")
    else:
        return input("\nRăspunsul tău: ").strip()


def check_answer(q: Question, answer: str) -> tuple[bool, str]:
    """Verifică dacă răspunsul este corect."""
    if q.tip in ('mcq', 'predict'):
        user_idx = ord(answer) - 65
        is_correct = (user_idx == q.corect)
        correct_letter = chr(65 + q.corect)
        feedback = f"Răspunsul corect: [{correct_letter}] {q.optiuni[q.corect]}"
    else:
        is_correct = (answer.lower() == q.raspuns_corect.lower())
        feedback = f"Răspunsul corect: {q.raspuns_corect}"
    
    return is_correct, feedback


def run_quiz(
    questions: list[Question],
    shuffle: bool = False,
    category: Optional[str] = None
) -> QuizResult:
    """Rulează quiz-ul interactiv."""
    if category:
        questions = [q for q in questions if q.bloom == category]
    
    if shuffle:
        questions = random.sample(questions, len(questions))
    
    if not questions:
        print("Nu există întrebări pentru criteriile selectate.")
        sys.exit(1)
    
    total_puncte = sum(q.punctaj for q in questions)
    puncte_obtinute = 0
    raspunsuri_corecte = 0
    detalii = []
    
    print("\n" + "╔" + "═" * 68 + "╗")
    print("║" + "  QUIZ FORMATIV: TEXT PROCESSING".center(68) + "║")
    print("║" + f"  {len(questions)} întrebări | {total_puncte} puncte".center(68) + "║")
    print("╚" + "═" * 68 + "╝")
    
    for i, q in enumerate(questions, 1):
        display_question(q, i, len(questions))
        answer = get_user_answer(q)
        is_correct, feedback = check_answer(q, answer)
        
        if is_correct:
            print("\n  ✅ CORECT!")
            puncte_obtinute += q.punctaj
            raspunsuri_corecte += 1
        else:
            print("\n  ❌ INCORECT")
            print(f"  {feedback}")
        
        if q.explicatie:
            print(f"\n  📝 Explicație: {q.explicatie[:200]}...")
        
        detalii.append({
            'id': q.id,
            'corect': is_correct,
            'punctaj': q.punctaj if is_correct else 0
        })
        
        input("\n  [Enter pentru a continua...]")
    
    return QuizResult(
        total_puncte=total_puncte,
        puncte_obtinute=puncte_obtinute,
        raspunsuri_corecte=raspunsuri_corecte,
        total_intrebari=len(questions),
        detalii=detalii
    )


def display_results(result: QuizResult) -> None:
    """Afișează rezultatele finale."""
    procent = (result.puncte_obtinute / result.total_puncte * 100) if result.total_puncte > 0 else 0
    
    print("\n" + "╔" + "═" * 68 + "╗")
    print("║" + "  REZULTATE FINALE".center(68) + "║")
    print("╠" + "═" * 68 + "╣")
    print(f"║  Punctaj: {result.puncte_obtinute}/{result.total_puncte} ({procent:.1f}%)".ljust(69) + "║")
    print(f"║  Răspunsuri corecte: {result.raspunsuri_corecte}/{result.total_intrebari}".ljust(69) + "║")
    print("╠" + "═" * 68 + "╣")
    
    if procent >= 90:
        msg = "Excelent! Stăpânești text processing la nivel avansat."
    elif procent >= 70:
        msg = "Bine! Ai înțeles conceptele principale."
    elif procent >= 50:
        msg = "Satisfăcător. Mai ai nevoie de practică."
    else:
        msg = "Necesită îmbunătățire. Revizuiește materialul."
    
    print(f"║  {msg}".ljust(69) + "║")
    print("╚" + "═" * 68 + "╝")


def self_test() -> bool:
    """Rulează teste interne pentru verificare."""
    print("Rulare self-test...")
    
    # Test 1: Creare Question
    q = Question(
        id="T1", tip="mcq", bloom="remember",
        text="Test?", punctaj=5,
        optiuni=["A", "B", "C"], corect=1
    )
    assert q.id == "T1", "Test 1 FAILED: id"
    assert q.corect == 1, "Test 1 FAILED: corect"
    print("  ✅ Test 1: Creare Question - OK")
    
    # Test 2: Verificare răspuns corect
    is_correct, _ = check_answer(q, "B")
    assert is_correct, "Test 2 FAILED: răspuns corect"
    print("  ✅ Test 2: Verificare răspuns corect - OK")
    
    # Test 3: Verificare răspuns greșit
    is_correct, _ = check_answer(q, "A")
    assert not is_correct, "Test 3 FAILED: răspuns greșit"
    print("  ✅ Test 3: Verificare răspuns greșit - OK")
    
    # Test 4: Întrebare fill-in
    q_fill = Question(
        id="T4", tip="fill", bloom="apply",
        text="Fill test", punctaj=5,
        raspuns_corect="answer"
    )
    is_correct, _ = check_answer(q_fill, "ANSWER")
    assert is_correct, "Test 4 FAILED: fill case-insensitive"
    print("  ✅ Test 4: Fill-in case-insensitive - OK")
    
    print("\n✅ Toate testele au trecut!")
    return True


# ═══════════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════════

def main():
    """Punct de intrare principal."""
    if len(sys.argv) < 2:
        print("Utilizare: python3 quiz_runner.py quiz.yaml [--shuffle] [--category BLOOM]")
        print("           python3 quiz_runner.py --self-test")
        sys.exit(1)
    
    if sys.argv[1] == '--self-test':
        success = self_test()
        sys.exit(0 if success else 1)
    
    filepath = sys.argv[1]
    shuffle = '--shuffle' in sys.argv
    
    category = None
    if '--category' in sys.argv:
        idx = sys.argv.index('--category')
        if idx + 1 < len(sys.argv):
            category = sys.argv[idx + 1]
    
    metadata, questions = load_quiz(filepath)
    result = run_quiz(questions, shuffle=shuffle, category=category)
    display_results(result)


if __name__ == '__main__':
    main()
