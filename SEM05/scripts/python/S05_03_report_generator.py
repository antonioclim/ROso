#!/usr/bin/env python3
"""
S05_03_report_generator.py - Generator de Rapoarte pentru Instructor

Sisteme de Operare | ASE București - CSIE
Seminar 9-10: Advanced Bash Scripting

Generează rapoarte de progres și statistici pentru evaluarea
scripturilor Bash avansate (funcții, arrays, robustețe, debugging).

UTILIZARE:
    python3 S05_03_report_generator.py --grades FILE
    python3 S05_03_report_generator.py --grades FILE --format json
    python3 S05_03_report_generator.py --summary
    python3 S05_03_report_generator.py --help
"""

import json
import sys
import argparse
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Optional, Any
from collections import defaultdict

#===============================================================================
# CONFIGURARE
#===============================================================================

EXERCISE_INFO = {
    # Stabilitate
    "R1": {"name": "Shebang corect", "category": "robustness", "points": 1},
    "R2": {"name": "set -e (errexit)", "category": "robustness", "points": 1},
    "R3": {"name": "set -u (nounset)", "category": "robustness", "points": 1},
    "R4": {"name": "set -o pipefail", "category": "robustness", "points": 1},
    "R5": {"name": "IFS setare sigură", "category": "robustness", "points": 1},
    
    # Funcții
    "F1": {"name": "Funcții definite", "category": "functions", "points": 2},
    "F2": {"name": "Variabile locale (local)", "category": "functions", "points": 3},
    "F3": {"name": "Documentație funcții", "category": "functions", "points": 2},
    "F4": {"name": "Return codes corecte", "category": "functions", "points": 2},
    "F5": {"name": "Validare argumente", "category": "functions", "points": 2},
    
    # Arrays
    "A1": {"name": "Arrays indexate", "category": "arrays", "points": 2},
    "A2": {"name": "Iterare cu ghilimele", "category": "arrays", "points": 3},
    "A3": {"name": "declare -A pentru hash", "category": "arrays", "points": 3},
    "A4": {"name": "Accesare corectă ${arr[@]}", "category": "arrays", "points": 2},
    
    # Error Handling
    "E1": {"name": "Trap cleanup", "category": "error_handling", "points": 3},
    "E2": {"name": "Error messages >&2", "category": "error_handling", "points": 2},
    "E3": {"name": "Exit codes custom", "category": "error_handling", "points": 2},
    "E4": {"name": "Validare input fișiere", "category": "error_handling", "points": 2},
    
    # Best Practices
    "B1": {"name": "Ghilimele la variabile", "category": "best_practices", "points": 2},
    "B2": {"name": "readonly pentru constante", "category": "best_practices", "points": 1},
    "B3": {"name": "main() function", "category": "best_practices", "points": 2},
    "B4": {"name": "ShellCheck fără erori", "category": "best_practices", "points": 3},
}

CATEGORIES = {
    "robustness": {"name": "🛡️ Robustețe", "weight": 1.0},
    "functions": {"name": "📦 Funcții", "weight": 1.2},
    "arrays": {"name": "📚 Arrays", "weight": 1.2},
    "error_handling": {"name": "⚠️ Error Handling", "weight": 1.1},
    "best_practices": {"name": "✨ Best Practices", "weight": 1.0},
}

#===============================================================================
# FUNCȚII
#===============================================================================

def load_grades_file(filepath: Path) -> List[Dict]:
    """Încarcă un fișier JSON cu rezultate autograder."""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
            # Acceptă atât listă cât și dict cu cheie 'results'
            if isinstance(data, list):
                return data
            elif isinstance(data, dict) and 'results' in data:
                return data['results']
            else:
                return [data]
    except json.JSONDecodeError as e:
        print(f"Eroare la parsarea JSON: {e}", file=sys.stderr)
        return []
    except FileNotFoundError:
        print(f"Fișierul nu a fost găsit: {filepath}", file=sys.stderr)
        return []

def calculate_statistics(grades: List[Dict]) -> Dict[str, Any]:
    """Calculează statistici din rezultatele autograder."""
    if not grades:
        return {"error": "Nu sunt date disponibile", "total_students": 0}
    
    stats: Dict[str, Any] = {
        "total_students": len(grades),
        "scores": [],
        "by_exercise": defaultdict(lambda: {"attempts": 0, "passed": 0, "total_score": 0}),
        "by_category": defaultdict(lambda: {"attempts": 0, "passed": 0, "total_score": 0, "max_score": 0}),
        "common_issues": defaultdict(int),
        "timestamps": [],
    }
    
    for result in grades:
        # Extrage scorul total
        total = result.get("total_score", 0)
        stats["scores"].append(total)
        
        # Timestamp dacă există
        if "timestamp" in result:
            stats["timestamps"].append(result["timestamp"])
        
        # Procesează exercițiile
        exercises = result.get("exercises", result.get("checks", {}))
        
        for ex_id, ex_result in exercises.items():
            if ex_id not in EXERCISE_INFO:
                continue
                
            ex_info = EXERCISE_INFO[ex_id]
            category = ex_info["category"]
            
            # Statistici per exercițiu
            stats["by_exercise"][ex_id]["attempts"] += 1
            score = ex_result.get("score", ex_result.get("points", 0))
            stats["by_exercise"][ex_id]["total_score"] += score
            
            passed = ex_result.get("passed", score >= ex_info["points"])
            if passed:
                stats["by_exercise"][ex_id]["passed"] += 1
            else:
                # Track common issues
                msg = ex_result.get("message", "")
                if msg:
                    stats["common_issues"][f"{ex_id}: {msg[:50]}"] += 1
            
            # Statistici per categorie
            stats["by_category"][category]["attempts"] += 1
            stats["by_category"][category]["total_score"] += score
            stats["by_category"][category]["max_score"] += ex_info["points"]
            if passed:
                stats["by_category"][category]["passed"] += 1
    
    # Calculează statistici agregat
    if stats["scores"]:
        sorted_scores = sorted(stats["scores"])
        n = len(sorted_scores)
        
        stats["avg_score"] = sum(stats["scores"]) / n
        stats["max_score"] = max(stats["scores"])
        stats["min_score"] = min(stats["scores"])
        stats["median_score"] = sorted_scores[n // 2] if n % 2 else (sorted_scores[n//2 - 1] + sorted_scores[n//2]) / 2
        
        # Deviație standard
        variance = sum((x - stats["avg_score"]) ** 2 for x in stats["scores"]) / n
        stats["std_dev"] = variance ** 0.5
        
        # Distribuție pe intervale
        stats["distribution"] = {
            "excellent (90-100%)": sum(1 for s in stats["scores"] if s >= 90),
            "good (70-89%)": sum(1 for s in stats["scores"] if 70 <= s < 90),
            "satisfactory (50-69%)": sum(1 for s in stats["scores"] if 50 <= s < 70),
            "needs_work (<50%)": sum(1 for s in stats["scores"] if s < 50),
        }
    
    return stats

def format_text_report(stats: Dict[str, Any]) -> str:
    """Formatează statisticile într-un raport text."""
    lines = []
    
    lines.append("=" * 70)
    lines.append("RAPORT SEMINAR 9-10: ADVANCED BASH SCRIPTING")
    lines.append(f"Generat: {datetime.now().strftime('%Y-%m-%d %H:%M')}")
    lines.append("=" * 70)
    lines.append("")
    
    if stats.get("error"):
        lines.append(f"⚠️  {stats['error']}")
        return "\n".join(lines)
    
    # Overview
    lines.append("📊 STATISTICI GENERALE")
    lines.append("-" * 40)
    lines.append(f"  Total studenți evaluați: {stats.get('total_students', 0)}")
    lines.append(f"  Scor mediu:    {stats.get('avg_score', 0):6.1f} puncte")
    lines.append(f"  Scor maxim:    {stats.get('max_score', 0):6.1f} puncte")
    lines.append(f"  Scor minim:    {stats.get('min_score', 0):6.1f} puncte")
    lines.append(f"  Scor median:   {stats.get('median_score', 0):6.1f} puncte")
    lines.append(f"  Deviație std:  {stats.get('std_dev', 0):6.2f}")
    lines.append("")
    
    # Distribuție
    dist = stats.get("distribution", {})
    if dist:
        lines.append("📈 DISTRIBUȚIE SCORURI")
        lines.append("-" * 40)
        total = stats.get("total_students", 1)
        for level, count in dist.items():
            pct = (count / total * 100) if total > 0 else 0
            bar = "█" * int(pct / 5) + "░" * (20 - int(pct / 5))
            lines.append(f"  {level:20} {bar} {count:3} ({pct:5.1f}%)")
        lines.append("")
    
    # Per categorie
    lines.append("📈 PERFORMANȚĂ PE CATEGORIE")
    lines.append("-" * 40)
    for cat_id, cat_stats in sorted(stats.get("by_category", {}).items()):
        cat_info = CATEGORIES.get(cat_id, {"name": cat_id})
        attempts = cat_stats["attempts"]
        passed = cat_stats["passed"]
        rate = (passed / attempts * 100) if attempts > 0 else 0
        
        status = "✓" if rate >= 70 else "⚠" if rate >= 50 else "✗"
        lines.append(f"  {status} {cat_info['name']:20} | Rată succes: {rate:5.1f}% ({passed}/{attempts})")
    lines.append("")
    
    # Per exercițiu
    lines.append("📝 PERFORMANȚĂ PE EXERCIȚIU (detaliat)")
    lines.append("-" * 40)
    
    current_category = None
    for ex_id in sorted(EXERCISE_INFO.keys()):
        ex_info = EXERCISE_INFO[ex_id]
        ex_stats = stats.get("by_exercise", {}).get(ex_id, {"attempts": 0, "passed": 0, "total_score": 0})
        
        # Separator pentru categorie nouă
        if ex_info["category"] != current_category:
            current_category = ex_info["category"]
            cat_name = CATEGORIES.get(current_category, {}).get("name", current_category)
            lines.append(f"\n  --- {cat_name} ---")
        
        attempts = ex_stats["attempts"]
        if attempts == 0:
            continue
            
        passed = ex_stats["passed"]
        rate = (passed / attempts * 100) if attempts > 0 else 0
        avg_score = (ex_stats["total_score"] / attempts) if attempts > 0 else 0
        
        status = "✓" if rate >= 70 else "⚠" if rate >= 50 else "✗"
        lines.append(f"  {status} {ex_id}: {ex_info['name'][:28]:28} | {rate:5.1f}% | Avg: {avg_score:.1f}/{ex_info['points']}")
    lines.append("")
    
    # Probleme comune
    common_issues = stats.get("common_issues", {})
    if common_issues:
        lines.append("🔴 PROBLEME FRECVENTE")
        lines.append("-" * 40)
        sorted_issues = sorted(common_issues.items(), key=lambda x: -x[1])[:10]
        for issue, count in sorted_issues:
            lines.append(f"  • ({count}x) {issue}")
        lines.append("")
    
    # Recomandări
    lines.append("💡 RECOMANDĂRI PENTRU INSTRUCTOR")
    lines.append("-" * 40)
    
    weak_categories = []
    for cat_id, cat_stats in stats.get("by_category", {}).items():
        attempts = cat_stats["attempts"]
        passed = cat_stats["passed"]
        rate = (passed / attempts * 100) if attempts > 0 else 0
        if rate < 60 and attempts > 0:
            weak_categories.append((cat_id, rate))
    
    if weak_categories:
        lines.append("  Categorii problematice (sub 60% succes):")
        for cat_id, rate in sorted(weak_categories, key=lambda x: x[1]):
            cat_name = CATEGORIES.get(cat_id, {}).get("name", cat_id)
            lines.append(f"    • {cat_name}: {rate:.0f}%")
        lines.append("")
        lines.append("  Sugestii:")
        
        for cat_id, _ in weak_categories:
            if cat_id == "robustness":
                lines.append("    → Recapitulează 'set -euo pipefail' și efectele fiecărei opțiuni")
            elif cat_id == "functions":
                lines.append("    → Demonstrează diferența dintre local și global în funcții")
            elif cat_id == "arrays":
                lines.append("    → Exerciții practice cu arrays și declare -A")
            elif cat_id == "error_handling":
                lines.append("    → Live coding cu trap și cleanup patterns")
            elif cat_id == "best_practices":
                lines.append("    → Rulați ShellCheck împreună în clasă")
    else:
        lines.append("  ✓ Toate categoriile au rată de succes acceptabilă!")
    
    lines.append("")
    lines.append("=" * 70)
    lines.append("  📌 Teme prioritare pentru recapitulare:")
    
    weak_exercises = []
    for ex_id, ex_stats in stats.get("by_exercise", {}).items():
        attempts = ex_stats["attempts"]
        passed = ex_stats["passed"]
        rate = (passed / attempts * 100) if attempts > 0 else 0
        if rate < 50 and attempts > 0:
            weak_exercises.append((ex_id, rate))
    
    if weak_exercises:
        for ex_id, rate in sorted(weak_exercises, key=lambda x: x[1])[:5]:
            ex_info = EXERCISE_INFO.get(ex_id, {"name": ex_id})
            lines.append(f"     • {ex_info['name']} ({rate:.0f}% succes)")
    else:
        lines.append("     Niciun exercițiu sub 50% succes!")
    
    lines.append("=" * 70)
    
    return "\n".join(lines)

def format_json_report(stats: Dict[str, Any]) -> str:
    """Formatează statisticile în JSON."""
    # Convert defaultdicts to regular dicts pentru JSON serialization
    output = {
        "metadata": {
            "generated_at": datetime.now().isoformat(),
            "seminar": "9-10",
            "topic": "Advanced Bash Scripting"
        },
        "summary": {
            "total_students": stats.get("total_students", 0),
            "avg_score": round(stats.get("avg_score", 0), 2),
            "max_score": stats.get("max_score", 0),
            "min_score": stats.get("min_score", 0),
            "median_score": round(stats.get("median_score", 0), 2),
            "std_dev": round(stats.get("std_dev", 0), 2),
        },
        "distribution": stats.get("distribution", {}),
        "by_category": {k: dict(v) for k, v in stats.get("by_category", {}).items()},
        "by_exercise": {k: dict(v) for k, v in stats.get("by_exercise", {}).items()},
        "common_issues": dict(stats.get("common_issues", {})),
    }
    return json.dumps(output, indent=2, ensure_ascii=False)

def generate_summary() -> str:
    """Generează un sumar al exercițiilor disponibile."""
    lines = []
    lines.append("=" * 70)
    lines.append("SEMINAR 9-10: ADVANCED BASH SCRIPTING - EXERCIȚII DISPONIBILE")
    lines.append("=" * 70)
    lines.append("")
    
    total_points = 0
    current_category = None
    
    for ex_id in sorted(EXERCISE_INFO.keys()):
        ex_info = EXERCISE_INFO[ex_id]
        
        if ex_info["category"] != current_category:
            current_category = ex_info["category"]
            cat_info = CATEGORIES.get(current_category, {"name": current_category})
            lines.append(f"\n{cat_info['name']}")
            lines.append("-" * 40)
        
        lines.append(f"  {ex_id}: {ex_info['name']:35} [{ex_info['points']} puncte]")
        total_points += ex_info["points"]
    
    lines.append("")
    lines.append("=" * 70)
    lines.append(f"TOTAL: {len(EXERCISE_INFO)} exerciții | {total_points} puncte posibile")
    lines.append("=" * 70)
    
    return "\n".join(lines)

#===============================================================================
# MAIN
#===============================================================================

def main():
    parser = argparse.ArgumentParser(
        description="Generator de rapoarte pentru Seminar 9-10: Advanced Bash Scripting",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Exemple:
  python3 S05_03_report_generator.py --grades results.json
  python3 S05_03_report_generator.py --grades results.json --format json
  python3 S05_03_report_generator.py --grades results.json --output report.txt
  python3 S05_03_report_generator.py --summary
        """
    )
    
    parser.add_argument(
        "--grades", "-g",
        type=Path,
        help="Fișier JSON cu rezultatele autograder-ului"
    )
    
    parser.add_argument(
        "--format", "-f",
        choices=["text", "json"],
        default="text",
        help="Formatul output-ului (default: text)"
    )
    
    parser.add_argument(
        "--output", "-o",
        type=Path,
        help="Fișier de output (default: stdout)"
    )
    
    parser.add_argument(
        "--summary", "-s",
        action="store_true",
        help="Afișează sumarul exercițiilor disponibile"
    )
    
    args = parser.parse_args()
    
    # Generează output
    if args.summary:
        output = generate_summary()
    elif args.grades:
        grades = load_grades_file(args.grades)
        stats = calculate_statistics(grades)
        
        if args.format == "json":
            output = format_json_report(stats)
        else:
            output = format_text_report(stats)
    else:
        parser.print_help()
        return 1
    
    # Scrie output
    if args.output:
        with open(args.output, 'w', encoding='utf-8') as f:
            f.write(output)
        print(f"Raport salvat în: {args.output}")
    else:
        print(output)
    
    return 0

if __name__ == "__main__":
    sys.exit(main())
