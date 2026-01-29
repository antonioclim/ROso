#!/usr/bin/env python3
"""
S04_03_report_generator.py - Generator de Rapoarte pentru Instructor

Generează rapoarte de progres și statistici pentru seminarul 7-8.

Usage:
    python3 S04_03_report_generator.py --grades FILE
    python3 S04_03_report_generator.py --summary
"""

import json
import sys
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Optional
from collections import defaultdict

#===============================================================================
# CONFIGURARE
#===============================================================================

EXERCISE_INFO = {
    "G1": {"name": "Grep cod 404", "category": "grep", "points": 10},
    "G2": {"name": "Grep numărare POST", "category": "grep", "points": 10},
    "G3": {"name": "Grep extragere IP-uri", "category": "grep", "points": 15},
    "G4": {"name": "Grep validare email", "category": "grep", "points": 15},
    "S1": {"name": "Sed înlocuire", "category": "sed", "points": 10},
    "S2": {"name": "Sed șterge comentarii", "category": "sed", "points": 10},
    "S3": {"name": "Sed cleanup complet", "category": "sed", "points": 15},
    "A1": {"name": "Awk extragere coloană", "category": "awk", "points": 10},
    "A2": {"name": "Awk suma salariilor", "category": "awk", "points": 15},
    "A3": {"name": "Awk numărare per dept", "category": "awk", "points": 20},
}

#===============================================================================
# FUNCȚII
#===============================================================================

def load_grades_file(filepath: Path) -> List[Dict]:
    """Încarcă un fișier cu rezultate autograder."""
    with open(filepath) as f:
        return json.load(f)

def calculate_statistics(grades: List[Dict]) -> Dict:
    """Calculează statistici din rezultatele autograder."""
    if not grades:
        return {"error": "Nu sunt date disponibile"}
    
    stats = {
        "total_students": len(grades),
        "scores": [],
        "by_exercise": defaultdict(lambda: {"attempts": 0, "passed": 0, "total_score": 0}),
        "by_category": defaultdict(lambda: {"attempts": 0, "passed": 0}),
    }
    
    for result in grades:
        if "exercises" not in result:
            continue
            
        total = result.get("total_score", 0)
        stats["scores"].append(total)
        
        for ex_id, ex_result in result["exercises"].items():
            ex_info = EXERCISE_INFO.get(ex_id, {"category": "unknown", "points": 0})
            
            stats["by_exercise"][ex_id]["attempts"] += 1
            stats["by_exercise"][ex_id]["total_score"] += ex_result.get("score", 0)
            if ex_result.get("passed", False):
                stats["by_exercise"][ex_id]["passed"] += 1
            
            stats["by_category"][ex_info["category"]]["attempts"] += 1
            if ex_result.get("passed", False):
                stats["by_category"][ex_info["category"]]["passed"] += 1
    
    # Calculează statistici agregat
    if stats["scores"]:
        stats["avg_score"] = sum(stats["scores"]) / len(stats["scores"])
        stats["max_score"] = max(stats["scores"])
        stats["min_score"] = min(stats["scores"])
        stats["median_score"] = sorted(stats["scores"])[len(stats["scores"]) // 2]
    
    return stats

def format_report(stats: Dict) -> str:
    """Formatează statisticile într-un raport text."""
    lines = []
    lines.append("=" * 70)
    lines.append("RAPORT SEMINAR 7-8: TEXT PROCESSING (grep, sed, awk)")
    lines.append(f"Generat: {datetime.now().strftime('%Y-%m-%d %H:%M')}")
    lines.append("=" * 70)
    lines.append("")
    
    # Overview
    lines.append("📊 STATISTICI GENERALE")
    lines.append("-" * 40)
    lines.append(f"  Total studenți evaluați: {stats.get('total_students', 0)}")
    lines.append(f"  Scor mediu: {stats.get('avg_score', 0):.1f}")
    lines.append(f"  Scor maxim: {stats.get('max_score', 0)}")
    lines.append(f"  Scor minim: {stats.get('min_score', 0)}")
    lines.append(f"  Scor median: {stats.get('median_score', 0)}")
    lines.append("")
    
    # Per categorie
    lines.append("📈 PERFORMANȚĂ PE CATEGORIE")
    lines.append("-" * 40)
    for cat, cat_stats in stats.get("by_category", {}).items():
        attempts = cat_stats["attempts"]
        passed = cat_stats["passed"]
        rate = (passed / attempts * 100) if attempts > 0 else 0
        lines.append(f"  {cat.upper():10} | Rată succes: {rate:5.1f}% ({passed}/{attempts})")
    lines.append("")
    
    # Per exercițiu
    lines.append("📝 PERFORMANȚĂ PE EXERCIȚIU")
    lines.append("-" * 40)
    for ex_id, ex_stats in sorted(stats.get("by_exercise", {}).items()):
        ex_info = EXERCISE_INFO.get(ex_id, {"name": ex_id, "points": 0})
        attempts = ex_stats["attempts"]
        passed = ex_stats["passed"]
        rate = (passed / attempts * 100) if attempts > 0 else 0
        avg = (ex_stats["total_score"] / attempts) if attempts > 0 else 0
        
        status = "✓" if rate >= 70 else "⚠" if rate >= 50 else "✗"
        lines.append(f"  {status} {ex_id}: {ex_info['name'][:25]:25} | {rate:5.1f}% | Avg: {avg:.1f}/{ex_info['points']}")
    lines.append("")
    
    # Recomandări
    lines.append("💡 RECOMANDĂRI PENTRU INSTRUCTOR")
    lines.append("-" * 40)
    
    weak_exercises = []
    for ex_id, ex_stats in stats.get("by_exercise", {}).items():
        attempts = ex_stats["attempts"]
        passed = ex_stats["passed"]
        rate = (passed / attempts * 100) if attempts > 0 else 0
        if rate < 50 and attempts > 0:
            weak_exercises.append((ex_id, rate))
    
    if weak_exercises:
        lines.append("  Exerciții problematice (sub 50% succes):")
        for ex_id, rate in sorted(weak_exercises, key=lambda x: x[1]):
            ex_info = EXERCISE_INFO.get(ex_id, {"name": ex_id})
            lines.append(f"    • {ex_id}: {ex_info['name']} ({rate:.0f}%)")
        lines.append("  → Recapitulează aceste concepte!")
    else:
        lines.append("  ✓ Toate exercițiile au rată de succes acceptabilă")
    
    lines.append("")
    lines.append("=" * 70)
    
    return "\n".join(lines)

def generate_sample_data():
    """Generează date de test pentru demonstrație."""
    import random
    
    sample = []
    for i in range(25):
        student = {
            "student_id": f"STU{1000+i}",
            "exercises": {},
            "total_score": 0,
            "max_score": 130
        }
        
        for ex_id, ex_info in EXERCISE_INFO.items():
            passed = random.random() > 0.3
            score = ex_info["points"] if passed else int(ex_info["points"] * random.random() * 0.5)
            student["exercises"][ex_id] = {
                "score": score,
                "max_points": ex_info["points"],
                "passed": passed
            }
            student["total_score"] += score
        
        sample.append(student)
    
    return sample

#===============================================================================
# MAIN
#===============================================================================

def main():
    import argparse
    
    parser = argparse.ArgumentParser(description="Generator de rapoarte pentru Seminarul 7-8")
    parser.add_argument("--grades", "-g", type=Path, help="Fișier JSON cu rezultate autograder")
    parser.add_argument("--output", "-o", type=Path, help="Fișier output")
    parser.add_argument("--sample", action="store_true", help="Folosește date de test")
    parser.add_argument("--json", action="store_true", help="Output în format JSON")
    
    args = parser.parse_args()
    
    if args.sample:
        grades = generate_sample_data()
    elif args.grades:
        if not args.grades.exists():
            print(f"Fișierul nu există: {args.grades}")
            sys.exit(1)
        grades = load_grades_file(args.grades)
    else:
        print("Folosește --grades FILE sau --sample pentru date de test")
        sys.exit(1)
    
    stats = calculate_statistics(grades)
    
    if args.json:
        output = json.dumps(stats, indent=2, default=str)
    else:
        output = format_report(stats)
    
    if args.output:
        with open(args.output, 'w') as f:
            f.write(output)
        print(f"Raport salvat în: {args.output}")
    else:
        print(output)

if __name__ == '__main__':
    main()
