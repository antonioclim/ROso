#!/usr/bin/env python3
"""
Quiz Runner - Rulează quiz-uri YAML în terminal.
Sisteme de Operare | ASE București - CSIE
"""

import argparse
import random
import sys
from pathlib import Path
from typing import Optional

try:
    import yaml
except ImportError:
    print("Eroare: PyYAML nu este instalat.")
    print("Rulează: pip install pyyaml")
    sys.exit(1)


class Colors:
    """Coduri ANSI pentru culori în terminal."""
    GREEN = '\033[92m'
    RED = '\033[91m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    BOLD = '\033[1m'
    RESET = '\033[0m'


def colorize(text: str, color: str, use_color: bool) -> str:
    """Aplică culoare textului dacă e activată."""
    if use_color:
        return f"{color}{text}{Colors.RESET}"
    return text


def load_quiz(quiz_path: Path) -> dict:
    """Încarcă quiz-ul din fișierul YAML."""
    with open(quiz_path, 'r', encoding='utf-8') as f:
        return yaml.safe_load(f)


def display_question(q: dict, index: int, total: int, use_color: bool) -> None:
    """Afișează o întrebare cu opțiunile sale."""
    print(f"\n{'─' * 50}")
    bloom = q.get('bloom', 'N/A').upper()
    print(colorize(f"Întrebarea {index}/{total}", Colors.BOLD, use_color))
    print(f"[Bloom: {bloom}]")
    print()
    print(colorize(q['text'], Colors.YELLOW, use_color))
    print()
    
    for opt in q['optiuni']:
        print(f"  {opt}")


def get_answer(num_options: int) -> str:
    """Obține răspunsul utilizatorului cu validare."""
    valid = [chr(ord('A') + i) for i in range(num_options)]
    while True:
        answer = input("\nRăspunsul tău: ").strip().upper()
        if answer in valid:
            return answer
        print(f"Răspuns invalid. Alege din: {', '.join(valid)}")


def show_feedback(q: dict, answer: str, use_color: bool) -> bool:
    """Afișează feedback pentru răspuns și returnează True dacă e corect."""
    correct = q['corect']
    is_correct = (answer == correct)
    
    if is_correct:
        print(colorize("\n✓ CORECT!", Colors.GREEN, use_color))
    else:
        print(colorize(f"\n✗ GREȘIT! Răspunsul corect: {correct}", Colors.RED, use_color))
    
    print(f"\nExplicație: {q['explicatie']}")
    return is_correct


def prepare_questions(questions: list, shuffle: bool, limit: Optional[int]) -> list:
    """Pregătește lista de întrebări (shuffle și limit)."""
    if shuffle:
        questions = questions.copy()
        random.shuffle(questions)
    if limit and limit < len(questions):
        questions = questions[:limit]
    return questions


def show_quiz_header(meta: dict, total: int, use_color: bool) -> None:
    """Afișează header-ul quiz-ului."""
    print("\n" + "═" * 60)
    title = meta.get('titlu', 'Quiz Formativ')
    print(colorize(f"  QUIZ: {title}", Colors.BOLD, use_color))
    print(f"  Întrebări: {total} | Timp estimat: {meta.get('timp_estimat', 'N/A')}")
    print("═" * 60)


def show_final_score(score: int, total: int, use_color: bool) -> None:
    """Afișează scorul final cu mesaj corespunzător."""
    percentage = (score / total) * 100
    print("\n" + "═" * 60)
    
    if percentage >= 80:
        result_color = Colors.GREEN
        message = "Excelent!"
    elif percentage >= 60:
        result_color = Colors.YELLOW
        message = "Bine, dar mai repetă conceptele greșite."
    else:
        result_color = Colors.RED
        message = "Recomandare: revizuiește materialul și încearcă din nou."
    
    print(colorize(f"  SCOR FINAL: {score}/{total} ({percentage:.0f}%)", result_color, use_color))
    print(f"  {message}")
    print("═" * 60 + "\n")


def run_quiz(quiz: dict, shuffle: bool, limit: Optional[int], use_color: bool) -> None:
    """Rulează quiz-ul interactiv."""
    meta = quiz.get('metadata', {})
    questions = quiz.get('intrebari', [])
    
    if not questions:
        print("Eroare: Quiz-ul nu conține întrebări.")
        sys.exit(1)
    
    questions = prepare_questions(questions, shuffle, limit)
    total = len(questions)
    
    show_quiz_header(meta, total, use_color)
    input("\nApasă ENTER pentru a începe...")
    
    score = 0
    for i, q in enumerate(questions, 1):
        display_question(q, i, total, use_color)
        answer = get_answer(len(q['optiuni']))
        if show_feedback(q, answer, use_color):
            score += 1
        if i < total:
            input("\nApasă ENTER pentru următoarea întrebare...")
    
    show_final_score(score, total, use_color)


def main() -> None:
    """Entry point principal."""
    parser = argparse.ArgumentParser(
        description='Rulează quiz-uri YAML în terminal.'
    )
    parser.add_argument(
        'quiz_file',
        nargs='?',
        default='quiz.yaml',
        help='Calea către fișierul quiz (implicit: quiz.yaml)'
    )
    parser.add_argument('--shuffle', action='store_true', help='Amestecă întrebările')
    parser.add_argument('--limit', type=int, help='Limitează numărul de întrebări')
    parser.add_argument('--no-color', action='store_true', help='Dezactivează culorile')
    
    args = parser.parse_args()
    
    quiz_path = Path(args.quiz_file)
    if not quiz_path.exists():
        print(f"Eroare: Fișierul '{quiz_path}' nu există.")
        sys.exit(1)
    
    quiz = load_quiz(quiz_path)
    run_quiz(quiz, args.shuffle, args.limit, not args.no_color)


if __name__ == '__main__':
    main()
