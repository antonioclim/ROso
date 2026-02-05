# 📁 Unelte Python — SEM06

> **Locație:** `SEM06/scripts/python/`  
> **Scop:** unelte pentru notare automată, generare și analiză  
> **Versiune Python:** ≥ 3.10 necesară

## Conținut

| Unealtă | Scop | CLI |
|------|---------|-----|
| `S06_01_autograder.py` | notare automată | Da |

## Instalare

```bash
# Install dependencies
cd SEM06/
pip install -r requirements.txt

# Or install individually
pip install pyyaml pytest
```

---

## S06_01_autograder.py

**Scop:** evaluare automată a temelor, cu feedback detaliat

### Utilizare

```bash
python3 S06_01_autograder.py <submission> [options]

Arguments:
  submission       Path to submission directory or file

Options:
  --rubric PATH    Custom rubric file
  --output FILE    Output file for grades (CSV)
  --verbose        Detailed scoring breakdown
  --batch          Process entire directory of submissions
  --timeout SEC    Per-test timeout (default: 30)
```

### Exemple

```bash
# Grade single submission
python3 S06_01_autograder.py ~/submissions/student123/

# Grade all submissions with report
python3 S06_01_autograder.py ~/submissions/ --batch --output grades.csv

# Verbose grading
python3 S06_01_autograder.py submission/ --verbose
```

### Criterii de notare

| Criteriu | Pondere | Descriere |
|-----------|--------|-------------|
| Corectitudine | 60% | trece testele |
| Stil | 20% | conformitate shellcheck |
| Documentație | 20% | comentarii, README |

---

## S06_02_quiz_generator.py

**Scop:** generarea de quiz‑uri randomizate din banca de întrebări

### Utilizare

```bash
python3 S06_02_quiz_generator.py [options]

Options:
  --count N        Number of unique quizzes to generate
  --questions N    Questions per quiz (default: 10)
  --seed N         Random seed for reproducibility
  --output DIR     Output directory for generated quizzes
  --format FMT     Output format: yaml, json, pdf, moodle
```

### Exemple

```bash
# Generate 5 unique quizzes
python3 S06_02_quiz_generator.py --count 5 --output quizzes/

# Reproducible generation
python3 S06_02_quiz_generator.py --seed 42 --count 3

# Export for Moodle
python3 S06_02_quiz_generator.py --format moodle --output moodle_quiz.xml
```

---

## S06_03_report_generator.py

**Scop:** generarea de rapoarte PDF/HTML din datele de notare

### Utilizare

```bash
python3 S06_03_report_generator.py <grades_file> [options]

Arguments:
  grades_file      CSV file with grades data

Options:
  --format FMT     Output format: pdf, html, md (default: pdf)
  --individual     Generate per-student reports
  --summary        Include class statistics
  --output DIR     Output directory
```

### Exemple

```bash
# Generate summary report
python3 S06_03_report_generator.py grades.csv --summary

# Individual student reports
python3 S06_03_report_generator.py grades.csv --individual --output reports/
```

---

## Opțiuni comune

Toate uneltele Python suportă:

| Opțiune | Descriere |
|--------|-------------|
| `--help` | afișează mesajul de ajutor |
| `--verbose` | activează output detaliat |
| `--output` | fișier/director de ieșire |
| `--format` | formatul de ieșire |

---

## Configurare PYTHONPATH

Dacă rulați uneltele direct din acest director:

```bash
export PYTHONPATH="$(pwd)/../.."
python3 S06_01_autograder.py ...
```

---

## Vezi și

- [`../../tests/`](../../tests/) - exemple de suite de teste
- [`../../homework/`](../../homework/) - cerințele temelor
- [`../../docs/`](../../docs/) - documentație
- [`../../requirements.txt`](../../requirements.txt) - dependențe

---

*Unelte Python pentru SEM06 CAPSTONE — Sisteme de Operare*  
*ASE București - CSIE | 2024-2025*
