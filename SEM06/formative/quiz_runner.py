#!/usr/bin/env python3
"""
Quiz Runner pentru CAPSTONE SEM06 - Sisteme de Operare
======================================================

Rulează quiz-uri formative din fișiere YAML cu suport pentru:
- Afișare interactivă în terminal
- Scoring automat cu feedback
- Export rezultate
- Mode de practică și evaluare

Utilizare:
    python quiz_runner.py formative/quiz.yaml
    python quiz_runner.py formative/quiz.yaml --practice
    python quiz_runner.py formative/quiz.yaml --export results.json

Autor: ASE București - CSIE
Versiune: 1.0.0
"""

import argparse
import json
import random
import sys
from datetime import datetime
from pathlib import Path
from typing import Optional

try:
    import yaml
except ImportError:
    print("Eroare: PyYAML necesar. Instalează cu: pip install pyyaml")
    sys.exit(1)


# ═══════════════════════════════════════════════════════════════════════════════
# CONSTANTE
# ═══════════════════════════════════════════════════════════════════════════════

COLORS = {
    "reset": "\033[0m",
    "bold": "\033[1m",
    "red": "\033[91m",
    "green": "\033[92m",
    "yellow": "\033[93m",
    "blue": "\033[94m",
    "cyan": "\033[96m",
}

BLOOM_LEVELS = ["remember", "understand", "apply", "analyse", "evaluate", "create"]


# ═══════════════════════════════════════════════════════════════════════════════
# FUNCȚII UTILITATE
# ═══════════════════════════════════════════════════════════════════════════════

def color_text(text: str, color: str) -> str:
    """Aplică culoare ANSI la text."""
    return f"{COLORS.get(color, '')}{text}{COLORS['reset']}"


def clear_screen():
    """Curăță ecranul terminalului."""
    print("\033[2J\033[H", end="")


def print_separator(char: str = "─", width: int = 70):
    """Afișează un separator."""
    print(char * width)


def print_header(text: str):
    """Afișează un header formatat."""
    print_separator("═")
    print(color_text(f"  {text}", "bold"))
    print_separator("═")


# ═══════════════════════════════════════════════════════════════════════════════
# CLASE PRINCIPALE
# ═══════════════════════════════════════════════════════════════════════════════

class Question:
    """Reprezintă o întrebare din quiz."""

    def __init__(self, data: dict):
        self.id = data.get("id", "unknown")
        self.tip = data.get("tip", "mcq")
        self.bloom = data.get("bloom", "understand")
        self.puncte = data.get("puncte", 5)
        self.subiect = data.get("subiect", "")
        self.text = data.get("text", "").strip()
        self.optiuni = data.get("optiuni", {})
        self.corect = data.get("corect", "")
        self.explicatie = data.get("explicatie", "").strip()
        self.misconceptii = data.get("misconceptii", {})

    def display(self, index: int, total: int, show_bloom: bool = False):
        """Afișează întrebarea formatată."""
        bloom_badge = f" [{self.bloom.upper()}]" if show_bloom else ""
        print(f"\n{color_text(f'Întrebarea {index}/{total}', 'cyan')}{bloom_badge}")
        print(f"{color_text(f'[{self.puncte}p]', 'yellow')} {self.subiect}\n")
        print(self.text)
        print()

        for key, value in self.optiuni.items():
            print(f"  {color_text(key.upper(), 'bold')}) {value}")

    def check_answer(self, answer: str) -> bool:
        """Verifică dacă răspunsul e corect."""
        return answer.lower() == str(self.corect).lower()

    def show_feedback(self, answer: str, show_misconception: bool = True):
        """Afișează feedback pentru răspuns."""
        is_correct = self.check_answer(answer)

        if is_correct:
            print(color_text("\n✓ Corect!", "green"))
        else:
            print(color_text(f"\n✗ Incorect. Răspunsul corect: {self.corect.upper()}", "red"))

            if show_misconception and answer.lower() in self.misconceptii:
                misconception = self.misconceptii[answer.lower()]
                print(color_text(f"  → {misconception}", "yellow"))

        if self.explicatie:
            print(f"\n{color_text('Explicație:', 'blue')}")
            print(f"  {self.explicatie}")


class Quiz:
    """Gestionează quiz-ul complet."""

    def __init__(self, filepath: str):
        self.filepath = Path(filepath)
        self.data = self._load_quiz()
        self.metadata = self.data.get("metadata", {})
        self.questions = [Question(q) for q in self.data.get("intrebari", [])]
        self.config = self.data.get("configurare", {})
        self.results = []

    def _load_quiz(self) -> dict:
        """Încarcă quiz-ul din fișier YAML."""
        if not self.filepath.exists():
            raise FileNotFoundError(f"Fișierul {self.filepath} nu există")

        with open(self.filepath, "r", encoding="utf-8") as f:
            return yaml.safe_load(f)

    @property
    def title(self) -> str:
        return self.metadata.get("titlu", "Quiz")

    @property
    def total_points(self) -> int:
        return sum(q.puncte for q in self.questions)

    @property
    def passing_score(self) -> int:
        return self.metadata.get("prag_promovare", 60)

    def run_interactive(self, shuffle: bool = False, practice: bool = False):
        """Rulează quiz-ul interactiv în terminal."""
        clear_screen()
        print_header(self.title)

        print(f"\nÎntrebări: {len(self.questions)}")
        print(f"Punctaj total: {self.total_points}")
        print(f"Prag promovare: {self.passing_score}%")

        if practice:
            print(color_text("\nMod PRACTICĂ - vei vedea explicațiile după fiecare întrebare", "cyan"))

        input("\nApasă ENTER pentru a începe...")

        questions = self.questions[:]
        if shuffle:
            random.shuffle(questions)

        score = 0
        self.results = []

        for i, question in enumerate(questions, 1):
            clear_screen()
            question.display(i, len(questions), show_bloom=practice)

            while True:
                answer = input(f"\nRăspunsul tău ({'/'.join(question.optiuni.keys())}): ").strip()
                if answer.lower() in [k.lower() for k in question.optiuni.keys()]:
                    break
                print(color_text("Răspuns invalid. Încearcă din nou.", "red"))

            is_correct = question.check_answer(answer)

            if is_correct:
                score += question.puncte

            self.results.append({
                "question_id": question.id,
                "answer": answer,
                "correct": is_correct,
                "points": question.puncte if is_correct else 0,
            })

            if practice:
                question.show_feedback(answer)
                input("\nApasă ENTER pentru a continua...")

        self._show_final_results(score)

    def _show_final_results(self, score: int):
        """Afișează rezultatele finale."""
        clear_screen()
        print_header("REZULTATE FINALE")

        percentage = (score / self.total_points) * 100
        passed = percentage >= self.passing_score

        print(f"\nPunctaj: {score}/{self.total_points} ({percentage:.1f}%)")

        if passed:
            print(color_text("\n✓ PROMOVAT", "green"))
        else:
            print(color_text("\n✗ NEPROMOVAT", "red"))

        # Feedback pe nivel
        feedback = self.config.get("mesaje", {})
        for threshold, message in sorted(
            self.config.get("feedback_nivel", {}).items(),
            key=lambda x: int(x[0]),
            reverse=True
        ):
            if percentage >= int(threshold):
                print(f"\n{message}")
                break

        # Statistici per nivel Bloom
        print("\n" + color_text("Performanță per nivel Bloom:", "cyan"))
        bloom_stats = {}
        for result, question in zip(self.results, self.questions):
            level = question.bloom
            if level not in bloom_stats:
                bloom_stats[level] = {"correct": 0, "total": 0}
            bloom_stats[level]["total"] += 1
            if result["correct"]:
                bloom_stats[level]["correct"] += 1

        for level in BLOOM_LEVELS:
            if level in bloom_stats:
                stats = bloom_stats[level]
                pct = (stats["correct"] / stats["total"]) * 100
                bar = "█" * int(pct / 10) + "░" * (10 - int(pct / 10))
                print(f"  {level.capitalize():12} [{bar}] {pct:.0f}%")

    def export_results(self, filepath: str):
        """Exportă rezultatele în JSON."""
        export_data = {
            "quiz": self.title,
            "date": datetime.now().isoformat(),
            "score": sum(r["points"] for r in self.results),
            "total": self.total_points,
            "percentage": (sum(r["points"] for r in self.results) / self.total_points) * 100,
            "passed": (sum(r["points"] for r in self.results) / self.total_points) * 100 >= self.passing_score,
            "results": self.results,
        }

        with open(filepath, "w", encoding="utf-8") as f:
            json.dump(export_data, f, indent=2, ensure_ascii=False)

        print(f"Rezultate exportate în: {filepath}")


# ═══════════════════════════════════════════════════════════════════════════════
# FUNCȚII DE TEST
# ═══════════════════════════════════════════════════════════════════════════════

def run_tests():
    """Rulează teste unitare pentru quiz runner."""
    print_header("TESTE UNITARE - Quiz Runner")

    tests_passed = 0
    tests_failed = 0

    # Test 1: Încărcare YAML
    print("\n[TEST 1] Încărcare YAML...")
    try:
        test_yaml = """
metadata:
  titlu: "Test Quiz"
intrebari:
  - id: q1
    tip: mcq
    bloom: remember
    puncte: 5
    text: "Test question"
    optiuni:
      a: "Option A"
      b: "Option B"
    corect: a
"""
        data = yaml.safe_load(test_yaml)
        assert data["metadata"]["titlu"] == "Test Quiz"
        assert len(data["intrebari"]) == 1
        print(color_text("  ✓ PASS", "green"))
        tests_passed += 1
    except AssertionError as e:
        print(color_text(f"  ✗ FAIL: {e}", "red"))
        tests_failed += 1

    # Test 2: Question parsing
    print("\n[TEST 2] Parsare Question...")
    try:
        q_data = {
            "id": "test",
            "tip": "mcq",
            "bloom": "apply",
            "puncte": 10,
            "text": "What is 2+2?",
            "optiuni": {"a": "3", "b": "4", "c": "5"},
            "corect": "b",
        }
        q = Question(q_data)
        assert q.id == "test"
        assert q.puncte == 10
        assert q.check_answer("b") is True
        assert q.check_answer("a") is False
        assert q.check_answer("B") is True  # Case insensitive
        print(color_text("  ✓ PASS", "green"))
        tests_passed += 1
    except AssertionError as e:
        print(color_text(f"  ✗ FAIL: {e}", "red"))
        tests_failed += 1

    # Test 3: Color text
    print("\n[TEST 3] Formatare culori...")
    try:
        colored = color_text("test", "green")
        assert "\033[92m" in colored
        assert "\033[0m" in colored
        assert "test" in colored
        print(color_text("  ✓ PASS", "green"))
        tests_passed += 1
    except AssertionError as e:
        print(color_text(f"  ✗ FAIL: {e}", "red"))
        tests_failed += 1

    # Test 4: Export JSON format
    print("\n[TEST 4] Format export JSON...")
    try:
        results = [
            {"question_id": "q1", "answer": "a", "correct": True, "points": 5},
            {"question_id": "q2", "answer": "b", "correct": False, "points": 0},
        ]
        total = 10
        score = sum(r["points"] for r in results)
        percentage = (score / total) * 100
        assert score == 5
        assert percentage == 50.0
        print(color_text("  ✓ PASS", "green"))
        tests_passed += 1
    except AssertionError as e:
        print(color_text(f"  ✗ FAIL: {e}", "red"))
        tests_failed += 1

    # Test 5: Bloom levels order
    print("\n[TEST 5] Ordine niveluri Bloom...")
    try:
        assert BLOOM_LEVELS.index("remember") < BLOOM_LEVELS.index("understand")
        assert BLOOM_LEVELS.index("understand") < BLOOM_LEVELS.index("apply")
        assert BLOOM_LEVELS.index("apply") < BLOOM_LEVELS.index("analyse")
        print(color_text("  ✓ PASS", "green"))
        tests_passed += 1
    except AssertionError as e:
        print(color_text(f"  ✗ FAIL: {e}", "red"))
        tests_failed += 1

    # Sumar
    print_separator()
    total = tests_passed + tests_failed
    print(f"\nRezultat: {tests_passed}/{total} teste trecute")

    if tests_failed == 0:
        print(color_text("Toate testele au trecut!", "green"))
        return 0
    else:
        print(color_text(f"{tests_failed} teste au eșuat", "red"))
        return 1


# ═══════════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════════

def main():
    """Punct de intrare principal."""
    parser = argparse.ArgumentParser(
        description="Quiz Runner pentru Sisteme de Operare",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Exemple:
  %(prog)s quiz.yaml              # Rulează quiz-ul
  %(prog)s quiz.yaml --practice   # Mod practică cu explicații
  %(prog)s quiz.yaml --shuffle    # Întrebări în ordine aleatorie
  %(prog)s --test                 # Rulează teste unitare
""",
    )

    parser.add_argument("quiz_file", nargs="?", help="Fișier YAML cu quiz-ul")
    parser.add_argument("--practice", "-p", action="store_true", help="Mod practică cu explicații")
    parser.add_argument("--shuffle", "-s", action="store_true", help="Amestecă întrebările")
    parser.add_argument("--export", "-e", metavar="FILE", help="Exportă rezultatele în JSON")
    parser.add_argument("--test", "-t", action="store_true", help="Rulează teste unitare")
    parser.add_argument("--version", "-v", action="version", version="Quiz Runner 1.0.0")

    args = parser.parse_args()

    if args.test:
        return run_tests()

    if not args.quiz_file:
        parser.print_help()
        return 1

    try:
        quiz = Quiz(args.quiz_file)
        quiz.run_interactive(shuffle=args.shuffle, practice=args.practice)

        if args.export:
            quiz.export_results(args.export)

        return 0

    except FileNotFoundError as e:
        print(color_text(f"Eroare: {e}", "red"))
        return 1
    except yaml.YAMLError as e:
        print(color_text(f"Eroare parsare YAML: {e}", "red"))
        return 1
    except KeyboardInterrupt:
        print(color_text("\n\nQuiz întrerupt.", "yellow"))
        return 130


if __name__ == "__main__":
    sys.exit(main())
