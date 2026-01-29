#!/usr/bin/env python3
"""
quiz_runner.py — Runner pentru Quiz-uri YAML

Sisteme de Operare | ASE București - CSIE
Seminar 05: Advanced Bash Scripting

UTILIZARE:
    python3 quiz_runner.py quiz.yaml
    python3 quiz_runner.py quiz.yaml --shuffle
    python3 quiz_runner.py quiz.yaml --category functii

DEPENDINȚE:
    pip install pyyaml rich
"""

import argparse
import json
import random
import sys
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path
from typing import Optional

try:
    import yaml
except ImportError:
    print("Eroare: PyYAML nu e instalat. Rulează: pip install pyyaml")
    sys.exit(1)

try:
    from rich.console import Console
    from rich.panel import Panel
    from rich.syntax import Syntax
    from rich.table import Table
    RICH_AVAILABLE = True
except ImportError:
    RICH_AVAILABLE = False


@dataclass
class QuizResult:
    """Rezultatul unui quiz."""
    total_questions: int = 0
    correct_answers: int = 0
    answers: list = field(default_factory=list)
    start_time: str = ""
    end_time: str = ""
    categories_score: dict = field(default_factory=dict)
    bloom_score: dict = field(default_factory=dict)


class QuizRunner:
    """Runner pentru quiz-uri YAML."""

    def __init__(self, quiz_path: str, use_rich: bool = True):
        self.quiz_path = Path(quiz_path)
        self.quiz_data = self._load_quiz()
        self.result = QuizResult()
        self.use_rich = use_rich and RICH_AVAILABLE
        if self.use_rich:
            self.console = Console()

    def _load_quiz(self) -> dict:
        """Încarcă quiz-ul din fișierul YAML."""
        if not self.quiz_path.exists():
            print(f"Eroare: Fișierul {self.quiz_path} nu există.")
            sys.exit(1)
        with open(self.quiz_path, 'r', encoding='utf-8') as f:
            return yaml.safe_load(f)

    def _print_header(self):
        """Afișează header-ul quiz-ului."""
        meta = self.quiz_data.get('metadata', {})
        if self.use_rich:
            title = f"[bold blue]{meta.get('titlu', 'Quiz')}[/bold blue]"
            subtitle = meta.get('subtitlu', '')
            self.console.print()
            self.console.print(Panel(
                f"{title}\n{subtitle}\n\n"
                f"Timp estimat: {meta.get('timp_estimat_minute', 20)} minute\n"
                f"Întrebări: {len(self.quiz_data.get('intrebari', []))}",
                title="Quiz Formativ", border_style="blue"
            ))
        else:
            print("\n" + "=" * 60)
            print(f"  {meta.get('titlu', 'Quiz')}")
            print(f"  Timp estimat: {meta.get('timp_estimat_minute', 20)} minute")
            print("=" * 60 + "\n")

    def _display_question(self, q: dict, num: int, total: int):
        """Afișează o întrebare."""
        if self.use_rich:
            self.console.print(
                f"\n[bold cyan]Întrebarea {num}/{total}[/bold cyan] "
                f"[dim]({q.get('bloom', '').upper()} | {q.get('categorie', '')})[/dim]"
            )
            self.console.print(f"\n[bold]{q.get('text', '')}[/bold]")
            if 'cod' in q and q['cod']:
                self.console.print()
                syntax = Syntax(q['cod'].strip(), "bash", theme="monokai", line_numbers=True)
                self.console.print(syntax)
            self.console.print()
            for i, opt in enumerate(q.get('optiuni', [])):
                letter = chr(65 + i)
                self.console.print(f"  [yellow]{letter})[/yellow] {opt}")
        else:
            print(f"\n--- Întrebarea {num}/{total} ({q.get('bloom', '').upper()}) ---")
            print(f"\n{q.get('text', '')}")
            if 'cod' in q and q['cod']:
                print("\n```bash")
                print(q['cod'].strip())
                print("```")
            print()
            for i, opt in enumerate(q.get('optiuni', [])):
                print(f"  {chr(65 + i)}) {opt}")

    def _get_answer(self, num_options: int) -> int:
        """Obține răspunsul de la utilizator."""
        valid = [chr(65 + i) for i in range(num_options)]
        while True:
            if self.use_rich:
                self.console.print()
                answer = self.console.input("[bold green]Răspunsul tău (A/B/C/D): [/bold green]")
            else:
                answer = input("\nRăspunsul tău (A/B/C/D): ")
            answer = answer.strip().upper()
            if answer in valid:
                return ord(answer) - 65
            print("Răspuns invalid. Introdu A, B, C sau D.")

    def _show_feedback(self, q: dict, user_answer: int, correct: bool):
        """Afișează feedback după răspuns."""
        correct_letter = chr(65 + q.get('corect', 0))
        user_letter = chr(65 + user_answer)
        if self.use_rich:
            self.console.print()
            if correct:
                self.console.print(Panel(
                    f"[bold green]✓ CORECT![/bold green]\n\n{q.get('explicatie', '')}",
                    border_style="green"
                ))
            else:
                self.console.print(Panel(
                    f"[bold red]✗ INCORECT[/bold red]\n\n"
                    f"Răspunsul tău: {user_letter}\n"
                    f"Răspuns corect: {correct_letter}\n\n"
                    f"[yellow]Explicație:[/yellow] {q.get('explicatie', '')}",
                    border_style="red"
                ))
        else:
            print()
            if correct:
                print(f"✓ CORECT! {q.get('explicatie', '')}")
            else:
                print(f"✗ INCORECT (răspuns: {user_letter}, corect: {correct_letter})")
                print(f"  Explicație: {q.get('explicatie', '')}")

    def _show_results(self):
        """Afișează rezultatele finale."""
        pct = (self.result.correct_answers / self.result.total_questions * 100
               if self.result.total_questions > 0 else 0)
        if self.use_rich:
            table = Table(title="Rezultate Finale", border_style="blue")
            table.add_column("Metric", style="cyan")
            table.add_column("Valoare", style="green")
            table.add_row("Răspunsuri corecte",
                          f"{self.result.correct_answers}/{self.result.total_questions}")
            table.add_row("Scor", f"{pct:.1f}%")
            self.console.print("\n")
            self.console.print(table)
        else:
            print("\n" + "=" * 60)
            print(f"  Corecte: {self.result.correct_answers}/{self.result.total_questions}")
            print(f"  Scor: {pct:.1f}%")
            print("=" * 60)

    def run(self, shuffle: bool = False, category: Optional[str] = None,
            limit: Optional[int] = None):
        """Rulează quiz-ul."""
        self._print_header()
        questions = self.quiz_data.get('intrebari', [])
        if category:
            questions = [q for q in questions if q.get('categorie') == category]
        if shuffle:
            questions = questions.copy()
            random.shuffle(questions)
        if limit and limit < len(questions):
            questions = questions[:limit]

        self.result.total_questions = len(questions)
        self.result.start_time = datetime.now().isoformat()

        for i, q in enumerate(questions, 1):
            self._display_question(q, i, len(questions))
            user_answer = self._get_answer(len(q.get('optiuni', [])))
            correct = user_answer == q.get('corect', 0)
            if correct:
                self.result.correct_answers += 1

            cat = q.get('categorie', 'unknown')
            if cat not in self.result.categories_score:
                self.result.categories_score[cat] = [0, 0]
            self.result.categories_score[cat][1] += 1
            if correct:
                self.result.categories_score[cat][0] += 1

            self._show_feedback(q, user_answer, correct)
            if i < len(questions):
                input("\nApasă Enter pentru următoarea întrebare...")

        self.result.end_time = datetime.now().isoformat()
        self._show_results()

    def export_results(self, output_path: str):
        """Exportă rezultatele în JSON."""
        results = {
            'quiz_file': str(self.quiz_path),
            'total_questions': self.result.total_questions,
            'correct_answers': self.result.correct_answers,
            'score_percent': (self.result.correct_answers / self.result.total_questions * 100
                              if self.result.total_questions > 0 else 0),
            'categories': self.result.categories_score,
        }
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(results, f, indent=2, ensure_ascii=False)
        print(f"Rezultate exportate în: {output_path}")


def main():
    """Entry point."""
    parser = argparse.ArgumentParser(description="Runner pentru Quiz-uri YAML")
    parser.add_argument('quiz_file', help='Calea către fișierul quiz.yaml')
    parser.add_argument('--shuffle', action='store_true', help='Amestecă întrebările')
    parser.add_argument('--category', type=str, help='Filtrează pe categorie')
    parser.add_argument('--limit', type=int, help='Limitează numărul de întrebări')
    parser.add_argument('--no-rich', action='store_true', help='Dezactivează formatarea rich')
    parser.add_argument('--export-results', type=str, help='Exportă rezultatele în JSON')

    args = parser.parse_args()
    runner = QuizRunner(args.quiz_file, use_rich=not args.no_rich)
    runner.run(shuffle=args.shuffle, category=args.category, limit=args.limit)
    if args.export_results:
        runner.export_results(args.export_results)


if __name__ == '__main__':
    main()
