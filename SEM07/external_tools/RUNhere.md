# External Tools — detectarea plagiatului

> **Locație:** `SEM07/external_tools/`  
> **Scop:** Integrare cu servicii externe pentru detecția plagiatului  
> **Public țintă:** Doar cadre didactice

## Conținut

| Script | Serviciu | Scop |
|--------|----------|------|
| `run_moss.sh` | Stanford MOSS | Detecția similarității de cod |
| `run_plagiarism_check.sh` | Pipeline combinat | Orchestrarea tuturor verificărilor |

---

## Integrare MOSS

### Precondiții

1. **Înregistrare pentru MOSS:**
   - Vizitați: http://theory.stanford.edu/~aiken/moss/
   - Solicitați un user ID prin canalul oficial
   - Salvați ID‑ul: `echo "YOUR_ID" > ~/.moss_userid`

2. **Instalarea clientului MOSS:**
   ```bash
   # Usually bundled, or download from MOSS website
   chmod +x moss.pl
   ```

### Utilizare

```bash
./run_moss.sh <submissions_dir> [options]

Options:
  -l LANG       Language: bash, python, c, java, etc.
  -d            Directory mode (one submission per folder)
  -b FILE       Base file (template code to ignore)
  -m N          Maximum matches to show (default: 250)
  -n N          Maximum files in a match (default: 2)
```

### Exemple

```bash
# Check Bash scripts
./run_moss.sh submissions/ -l bash

# With base file (ignore template code)
./run_moss.sh submissions/ -l bash -b template.sh

# Multiple languages
./run_moss.sh submissions/ -l bash -l python
```

### Output

MOSS întoarce un URL pentru vizualizarea rezultatelor:
```
Results available at: http://moss.stanford.edu/results/XXXXX
```

---

## Verificare combinată de plagiat

### Utilizare

```bash
./run_plagiarism_check.sh <submissions_dir> [options]

Options:
  --threshold N     Similarity threshold (0.0-1.0, default: 0.7)
  --report FILE     Output report file
  --format FMT      Report format: html, csv, json
  --include-moss    Include MOSS analysis
  --local-only      Skip external services
```

### Ce verifică

| Verificare | Metodă | Detectează |
|------------|--------|------------|
| Potriviri exacte | Comparație de hash | Plagiat prin copiere‑lipire |
| Potriviri apropiate | Analiză de diff | Modificări minore |
| Similaritate structurală | Comparație AST | Cod refactorizat |
| Analiză MOSS | Serviciu extern | Plagiat sofisticat |

### Flux de lucru exemplu

```bash
# Quick local check
./run_plagiarism_check.sh submissions/ --local-only --threshold 0.8

# Full analysis with report
./run_plagiarism_check.sh submissions/ --include-moss --report plagiarism_report.html

# CSV for spreadsheet analysis
./run_plagiarism_check.sh submissions/ --format csv --report results.csv
```

---

## Interpretarea rezultatelor

### Scoruri de similaritate

| Scor | Interpretare | Acțiune |
|------|--------------|---------|
| < 30% | Normal | Nu este necesară nicio acțiune |
| 30–50% | Ridicat | Review manual |
| 50–70% | Înalt | Colaborare probabilă |
| > 70% | Foarte înalt | Plagiat probabil |

### Formatul raportului

```
═══════════════════════════════════════════════════════════════
 PLAGIARISM ANALYSIS REPORT
═══════════════════════════════════════════════════════════════

Submissions analysed: 45
Pairs checked: 990
Flagged pairs: 12

HIGH SIMILARITY (>70%):
  student_A ↔ student_B: 85% (MOSS: 82%)
  student_C ↔ student_D: 78% (MOSS: 75%)

ELEVATED (50-70%):
  student_E ↔ student_F: 62% (MOSS: 58%)
  ...

Full MOSS report: http://moss.stanford.edu/results/XXXXX
═══════════════════════════════════════════════════════════════
```

---

## Bune practici

### Înainte de rulare

- Eliminați codul de tip template/starter din analiză
- Excludeți importurile comune de biblioteci
- Setați un prag adecvat tipului de temă

### Interpretarea rezultatelor

- **Revedeți întotdeauna manual** — apar frecvent rezultate fals‑pozitive
- Luați în calcul constrângerile temei (pot exista puține soluții distincte)
- Verificați timpii de predare (timestamps)
- Intervievați studenții suspectați

### Documentare

Păstrați evidențe pentru proceduri de integritate academică:
- Capturi de ecran ale rezultatelor MOSS
- Raportul de analiză locală
- Timestamps‑urile predărilor
- Notițe de interviu

---

*Vedeți și: [`MOSS_JPLAG_GUIDE.md`](MOSS_JPLAG_GUIDE.md) pentru documentație detaliată*  
*Vedeți și: [`../homework_evaluation/`](../homework_evaluation/) pentru notare*

*Ultima actualizare: ianuarie 2026*
