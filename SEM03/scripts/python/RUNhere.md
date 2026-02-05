# 📁 Instrumente Python — SEM03

> **Locație:** `SEM03/scripts/python/`  
> **Scop:** instrumente pentru evaluare automată, generare și analiză  
> **Versiune Python:** ≥ 3.10


## Conținut

| Instrument | Scop | CLI |
|------|---------|-----|
| `S03_01_autograder.py` | Evaluare automată a temei | Da |
| `S03_02_quiz_generator.py` | Generare de chestionare randomizate | Da |
| `S03_03_report_generator.py` | Generare de rapoarte | Da |


## Instalare

```bash

# Install dependencies
cd SEM03/
pip install -r requirements.txt


# Or install individually
pip install pyyaml pytest
```

---


## S03_01_autograder.py

**Scop:** evaluare automată a temei, cu feedback detaliat


### Utilizare

```bash
python3 S03_01_autograder.py <submission> [options]

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
python3 S03_01_autograder.py ~/submissions/student123/


# Grade all submissions with report
python3 S03_01_autograder.py ~/submissions/ --batch --output grades.csv


# Verbose grading
python3 S03_01_autograder.py submission/ --verbose
```


### Criterii de evaluare

| Criteriu | Pondere | Descriere |
|-----------|--------|-------------|
| Corectitudine | 60% | Trece testele |
| Stil | 20% | conformitate shellcheck |
| Documentație | 20% | Comentarii, README |

---


## S03_02_quiz_generator.py

**Scop:** generare de chestionare randomizate din banca de întrebări


### Utilizare

```bash
python3 S03_02_quiz_generator.py [options]

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
python3 S03_02_quiz_generator.py --count 5 --output quizzes/


# Reproducible generation
python3 S03_02_quiz_generator.py --seed 42 --count 3


# Export for Moodle
python3 S03_02_quiz_generator.py --format moodle --output moodle_quiz.xml
```

---


## S03_03_report_generator.py

**Scop:** generare de rapoarte PDF/HTML pe baza datelor de notare


### Utilizare

```bash
python3 S03_03_report_generator.py <grades_file> [options]

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
python3 S03_03_report_generator.py grades.csv --summary


# Individual student reports
python3 S03_03_report_generator.py grades.csv --individual --output reports/
```

---


## Common Options

All Python tools support:

| Option | Description |
|--------|-------------|
| `--help` | Show detailed help |
| `--version` | Show tool version |
| `--quiet` | Suppress non-essential output |
| `--debug` | Enable debug logging |


## Configurare PYTHONPATH

Pentru importul modulelor comune din `lib/`:

```bash

# Add to your .bashrc or run before scripts
export PYTHONPATH="${PYTHONPATH}:$(pwd)/../.."


# Or run with path
PYTHONPATH="../.." python3 S03_01_autograder.py submission/
```

---

*Vezi și: `(director opțional pentru biblioteci partajate)` (director opțional) pentru utilitare comune*  
*Vezi și: [`../../tests/`](../../tests/) pentru suită de teste*

*Ultima actualizare: ianuarie 2026*

