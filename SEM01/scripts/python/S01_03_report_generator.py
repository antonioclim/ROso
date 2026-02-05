#!/usr/bin/env python3
"""
═══════════════════════════════════════════════════════════════════════════════
REPORT GENERATOR - Generare rapoarte și statistici seminar
Sisteme de Operare | ASE București - CSIE

Scop: Generează rapoarte despre progresul studenților
Utilizare: python3 report_generator.py --input results/ --output reports/
═══════════════════════════════════════════════════════════════════════════════
"""

import json
import csv
import argparse
from pathlib import Path
from datetime import datetime
from typing import List, Dict, Optional
from collections import defaultdict
import statistics

class ReportGenerator:
    def __init__(self):
        self.students_data: List[Dict] = []
        
    def load_autograder_results(self, results_dir: Path) -> None:
        """Încarcă rezultatele din directorul de output al autograder-ului."""
        for json_file in results_dir.glob("*.json"):
            try:
                with open(json_file, 'r') as f:
                    data = json.load(f)
                    # Extract student name from filename
                    data['student_name'] = json_file.stem.replace('_result', '')
                    self.students_data.append(data)
            except (json.JSONDecodeError, KeyError) as e:
                print(f"⚠️  Eroare la citirea {json_file}: {e}")
    
    def load_csv_results(self, csv_file: Path) -> None:
        """Încarcă rezultatele dintr-un fișier CSV."""
        with open(csv_file, 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            for row in reader:
                self.students_data.append({
                    'student_name': row.get('name', row.get('student', 'Unknown')),
                    'earned_points': float(row.get('points', row.get('score', 0))),
                    'total_points': float(row.get('total', row.get('max_score', 100))),
                    'percentage': float(row.get('percentage', 0))
                })
    
    def calculate_statistics(self) -> Dict:
        """Calculează statistici despre rezultate."""
        if not self.students_data:
            return {}
        
        percentages = [s.get('percentage', s['earned_points'] / s['total_points'] * 100) 
                       for s in self.students_data]
        
        return {
            'total_students': len(self.students_data),
            'mean': statistics.mean(percentages),
            'median': statistics.median(percentages),
            'stdev': statistics.stdev(percentages) if len(percentages) > 1 else 0,
            'min': min(percentages),
            'max': max(percentages),
            'pass_rate': len([p for p in percentages if p >= 50]) / len(percentages) * 100,
            'grade_distribution': self._calculate_grade_distribution(percentages)
        }
    
    def _calculate_grade_distribution(self, percentages: List[float]) -> Dict[str, int]:
        """Calculează distribuția notelor."""
        distribution = {'A': 0, 'B': 0, 'C': 0, 'D': 0, 'F': 0}
        for p in percentages:
            if p >= 90:
                distribution['A'] += 1
            elif p >= 80:
                distribution['B'] += 1
            elif p >= 70:
                distribution['C'] += 1
            elif p >= 60:
                distribution['D'] += 1
            else:
                distribution['F'] += 1
        return distribution
    
    def generate_summary_report(self, output_file: Path) -> None:
        """Generează raport sumar în format text."""
        stats = self.calculate_statistics()
        
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write("═" * 70 + "\n")
            f.write("           RAPORT SUMAR - Seminar 1: Shell Bash\n")
            f.write("           Sisteme de Operare | ASE București - CSIE\n")
            f.write("═" * 70 + "\n\n")
            
            f.write(f"Data generării: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
            f.write(f"Total studenți evaluați: {stats['total_students']}\n\n")
            
            f.write("─" * 70 + "\n")
            f.write("STATISTICI GENERALE\n")
            f.write("─" * 70 + "\n\n")
            
            f.write(f"  Media:           {stats['mean']:.1f}%\n")
            f.write(f"  Mediana:         {stats['median']:.1f}%\n")
            f.write(f"  Deviație std:    {stats['stdev']:.1f}%\n")
            f.write(f"  Minim:           {stats['min']:.1f}%\n")
            f.write(f"  Maxim:           {stats['max']:.1f}%\n")
            f.write(f"  Rata de trecere: {stats['pass_rate']:.1f}%\n\n")
            
            f.write("─" * 70 + "\n")
            f.write("DISTRIBUȚIA NOTELOR\n")
            f.write("─" * 70 + "\n\n")
            
            for grade, count in stats['grade_distribution'].items():
                bar = "█" * count
                f.write(f"  {grade}: {bar} ({count})\n")
            
            f.write("\n")
            f.write("─" * 70 + "\n")
            f.write("LISTA STUDENȚI (sortat după punctaj)\n")
            f.write("─" * 70 + "\n\n")
            
            sorted_students = sorted(self.students_data, 
                                    key=lambda x: x.get('percentage', x['earned_points'] / x['total_points'] * 100),
                                    reverse=True)
            
            f.write(f"{'#':<4} {'Nume':<30} {'Punctaj':<15} {'Notă':<5}\n")
            f.write("─" * 60 + "\n")
            
            for i, student in enumerate(sorted_students, 1):
                pct = student.get('percentage', student['earned_points'] / student['total_points'] * 100)
                grade = self._get_grade(pct)
                f.write(f"{i:<4} {student['student_name']:<30} {pct:>5.1f}%{'':<9} {grade:<5}\n")
            
            f.write("\n" + "═" * 70 + "\n")
    
    def _get_grade(self, percentage: float) -> str:
        """Convertește procentul în notă."""
        if percentage >= 90: return 'A'
        if percentage >= 80: return 'B'
        if percentage >= 70: return 'C'
        if percentage >= 60: return 'D'
        return 'F'
    
    def generate_html_report(self, output_file: Path) -> None:
        """Generează raport HTML interactiv."""
        stats = self.calculate_statistics()
        sorted_students = sorted(self.students_data,
                                key=lambda x: x.get('percentage', x['earned_points'] / x['total_points'] * 100),
                                reverse=True)
        
        html = f"""<!DOCTYPE html>
<html lang="ro">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Raport Seminar 1 - Shell Bash</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        :root {{
            --bg: #0f172a;
            --card: #1e293b;
            --accent: #3b82f6;
            --success: #22c55e;
            --warning: #eab308;
            --error: #ef4444;
            --text: #f1f5f9;
            --text-muted: #94a3b8;
        }}
        * {{ margin: 0; padding: 0; box-sizing: border-box; }}
        body {{
            font-family: 'Segoe UI', system-ui, sans-serif;
            background: var(--bg);
            color: var(--text);
            line-height: 1.6;
        }}
        .container {{
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }}
        header {{
            text-align: center;
            padding: 40px 0;
            border-bottom: 1px solid rgba(255,255,255,0.1);
            margin-bottom: 30px;
        }}
        h1 {{
            font-size: 2.5em;
            margin-bottom: 10px;
            background: linear-gradient(135deg, #3b82f6, #8b5cf6);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }}
        .subtitle {{ color: var(--text-muted); }}
        .stats-grid {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 40px;
        }}
        .stat-card {{
            background: var(--card);
            padding: 25px;
            border-radius: 12px;
            text-align: center;
        }}
        .stat-value {{
            font-size: 2.5em;
            font-weight: bold;
            color: var(--accent);
        }}
        .stat-label {{
            color: var(--text-muted);
            margin-top: 5px;
        }}
        .charts-grid {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
            gap: 30px;
            margin-bottom: 40px;
        }}
        .chart-container {{
            background: var(--card);
            padding: 25px;
            border-radius: 12px;
        }}
        .chart-title {{
            margin-bottom: 20px;
            font-size: 1.2em;
        }}
        table {{
            width: 100%;
            border-collapse: collapse;
            background: var(--card);
            border-radius: 12px;
            overflow: hidden;
        }}
        th, td {{
            padding: 15px;
            text-align: left;
        }}
        th {{
            background: rgba(59, 130, 246, 0.2);
            font-weight: 600;
        }}
        tr:hover {{
            background: rgba(255,255,255,0.05);
        }}
        .grade {{
            padding: 4px 12px;
            border-radius: 20px;
            font-weight: bold;
            font-size: 0.9em;
        }}
        .grade-A {{ background: rgba(34, 197, 94, 0.2); color: #22c55e; }}
        .grade-B {{ background: rgba(59, 130, 246, 0.2); color: #3b82f6; }}
        .grade-C {{ background: rgba(234, 179, 8, 0.2); color: #eab308; }}
        .grade-D {{ background: rgba(249, 115, 22, 0.2); color: #f97316; }}
        .grade-F {{ background: rgba(239, 68, 68, 0.2); color: #ef4444; }}
        .progress-bar {{
            height: 8px;
            background: rgba(255,255,255,0.1);
            border-radius: 4px;
            overflow: hidden;
        }}
        .progress-fill {{
            height: 100%;
            border-radius: 4px;
            transition: width 0.5s ease;
        }}
        .search-box {{
            padding: 12px 20px;
            background: var(--card);
            border: 1px solid rgba(255,255,255,0.1);
            border-radius: 8px;
            color: var(--text);
            width: 100%;
            max-width: 400px;
            margin-bottom: 20px;
            font-size: 1em;
        }}
        .search-box:focus {{
            outline: none;
            border-color: var(--accent);
        }}
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>📊 Raport Seminar 1</h1>
            <p class="subtitle">Shell Bash - Sisteme de Operare | ASE București</p>
            <p class="subtitle">Generat: {datetime.now().strftime('%Y-%m-%d %H:%M')}</p>
        </header>
        
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-value">{stats['total_students']}</div>
                <div class="stat-label">Studenți Evaluați</div>
            </div>
            <div class="stat-card">
                <div class="stat-value">{stats['mean']:.1f}%</div>
                <div class="stat-label">Media</div>
            </div>
            <div class="stat-card">
                <div class="stat-value">{stats['median']:.1f}%</div>
                <div class="stat-label">Mediana</div>
            </div>
            <div class="stat-card">
                <div class="stat-value">{stats['pass_rate']:.0f}%</div>
                <div class="stat-label">Rata de Trecere</div>
            </div>
        </div>
        
        <div class="charts-grid">
            <div class="chart-container">
                <h3 class="chart-title">Distribuția Notelor</h3>
                <canvas id="gradeChart"></canvas>
            </div>
            <div class="chart-container">
                <h3 class="chart-title">Distribuția Punctajelor</h3>
                <canvas id="scoreChart"></canvas>
            </div>
        </div>
        
        <h2 style="margin-bottom: 20px;">📋 Lista Studenți</h2>
        <input type="text" class="search-box" placeholder="Caută student..." onkeyup="filterTable(this.value)">
        
        <table id="studentsTable">
            <thead>
                <tr>
                    <th>#</th>
                    <th>Nume</th>
                    <th>Punctaj</th>
                    <th>Progres</th>
                    <th>Notă</th>
                </tr>
            </thead>
            <tbody>
"""
        
        for i, student in enumerate(sorted_students, 1):
            pct = student.get('percentage', student['earned_points'] / student['total_points'] * 100)
            grade = self._get_grade(pct)
            color = {'A': '#22c55e', 'B': '#3b82f6', 'C': '#eab308', 'D': '#f97316', 'F': '#ef4444'}[grade]
            
            html += f"""
                <tr>
                    <td>{i}</td>
                    <td>{student['student_name']}</td>
                    <td>{pct:.1f}%</td>
                    <td>
                        <div class="progress-bar">
                            <div class="progress-fill" style="width: {pct}%; background: {color};"></div>
                        </div>
                    </td>
                    <td><span class="grade grade-{grade}">{grade}</span></td>
                </tr>
"""
        
        grades = stats['grade_distribution']
        html += f"""
            </tbody>
        </table>
    </div>
    
    <script>
        // Grade Distribution Chart
        new Chart(document.getElementById('gradeChart'), {{
            type: 'doughnut',
            data: {{
                labels: ['A (90-100%)', 'B (80-89%)', 'C (70-79%)', 'D (60-69%)', 'F (<60%)'],
                datasets: [{{
                    data: [{grades['A']}, {grades['B']}, {grades['C']}, {grades['D']}, {grades['F']}],
                    backgroundColor: ['#22c55e', '#3b82f6', '#eab308', '#f97316', '#ef4444']
                }}]
            }},
            options: {{
                responsive: true,
                plugins: {{
                    legend: {{
                        position: 'bottom',
                        labels: {{ color: '#f1f5f9' }}
                    }}
                }}
            }}
        }});
        
        // Score Distribution Chart
        const scores = [{','.join([str(s.get('percentage', s['earned_points'] / s['total_points'] * 100)) for s in sorted_students])}];
        const bins = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        scores.forEach(s => {{
            const idx = Math.min(Math.floor(s / 10), 9);
            bins[idx]++;
        }});
        
        new Chart(document.getElementById('scoreChart'), {{
            type: 'bar',
            data: {{
                labels: ['0-9', '10-19', '20-29', '30-39', '40-49', '50-59', '60-69', '70-79', '80-89', '90-100'],
                datasets: [{{
                    label: 'Studenți',
                    data: bins,
                    backgroundColor: '#3b82f6'
                }}]
            }},
            options: {{
                responsive: true,
                plugins: {{
                    legend: {{ display: false }}
                }},
                scales: {{
                    y: {{
                        beginAtZero: true,
                        ticks: {{ color: '#94a3b8' }},
                        grid: {{ color: 'rgba(255,255,255,0.1)' }}
                    }},
                    x: {{
                        ticks: {{ color: '#94a3b8' }},
                        grid: {{ display: false }}
                    }}
                }}
            }}
        }});
        
        function filterTable(query) {{
            const rows = document.querySelectorAll('#studentsTable tbody tr');
            query = query.toLowerCase();
            rows.forEach(row => {{
                const name = row.cells[1].textContent.toLowerCase();
                row.style.display = name.includes(query) ? '' : 'none';
            }});
        }}
    </script>
</body>
</html>
"""
        
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(html)
    
    def export_csv(self, output_file: Path) -> None:
        """Exportă rezultatele în format CSV."""
        with open(output_file, 'w', newline='', encoding='utf-8') as f:
            writer = csv.writer(f)
            writer.writerow(['Nume', 'Punctaj', 'Total', 'Procent', 'Nota'])
            
            for student in self.students_data:
                pct = student.get('percentage', student['earned_points'] / student['total_points'] * 100)
                writer.writerow([
                    student['student_name'],
                    student['earned_points'],
                    student['total_points'],
                    f"{pct:.1f}",
                    self._get_grade(pct)
                ])

def main():
    parser = argparse.ArgumentParser(description='Generare rapoarte seminar')
    parser.add_argument('--input', type=str, required=True,
                       help='Director cu rezultate JSON sau fișier CSV')
    parser.add_argument('--output', type=str, default='reports',
                       help='Director output pentru rapoarte')
    parser.add_argument('--format', choices=['txt', 'html', 'csv', 'all'], default='all',
                       help='Format export')
    
    args = parser.parse_args()
    
    input_path = Path(args.input)
    output_dir = Path(args.output)
    output_dir.mkdir(exist_ok=True)
    
    generator = ReportGenerator()
    
    # Încarcă datele
    if input_path.is_dir():
        generator.load_autograder_results(input_path)
    elif input_path.suffix == '.csv':
        generator.load_csv_results(input_path)
    else:
        print(f"❌ Format necunoscut: {input_path}")
        return
    
    print(f"✓ Încărcate date pentru {len(generator.students_data)} studenți")
    
    # Generează rapoartele
    if args.format in ['txt', 'all']:
        generator.generate_summary_report(output_dir / 'raport_sumar.txt')
        print(f"✓ Generat: raport_sumar.txt")
    
    if args.format in ['html', 'all']:
        generator.generate_html_report(output_dir / 'raport_interactiv.html')
        print(f"✓ Generat: raport_interactiv.html")
    
    if args.format in ['csv', 'all']:
        generator.export_csv(output_dir / 'rezultate.csv')
        print(f"✓ Generat: rezultate.csv")
    
    print(f"\n✓ Rapoarte salvate în {output_dir}/")

if __name__ == '__main__':
    main()
