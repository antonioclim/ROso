# 📁 Instrumente Python — SEM02

> **Locație:** `SEM02/scripts/python/`  
> **Scop:** instrumente pentru evaluare automată, generare și analiză  
> **Versiune Python:** este necesar ≥ 3.10

## Conținut

| Instrument | Scop | CLI |
|------|---------|-----|
| `S02_01_autograder.py` | evaluare automată a temei | Da |
| `S02_02_quiz_generator.py` | generare de quiz-uri randomizate | Da |
| `S02_03_report_generator.py` | generare rapoarte | Da |

## Instalare

```bash
# Instalare dependențe
cd SEM02/
pip install -r requirements.txt

# Sau instalare individuală
pip install pyyaml pytest
```

---

## S02_01_autograder.py

**Scop:** evaluare automată a temei, cu feedback detaliat

### Utilizare

```bash
python3 S02_01_autograder.py <submission> [options]

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
# Notează o singură predare
python3 S02_01_autograder.py ~/submissions/student123/

# Notează toate predările cu raport
python3 S02_01_autograder.py ~/submissions/ --batch --output grades.csv

# Notare detaliată
python3 S02_01_autograder.py submission/ --verbose
```

### Criterii de notare

| Criteriu | Pondere | Descriere |
|-----------|--------|-------------|
| Corectitudine | 60% | trece cazurile de test |
| Stil | 20% | conformitate shellcheck |
| Documentație | 20% | comentarii, README |

---

## S02_02_quiz_generator.py

**Scop:** generare de quiz-uri randomizate din banca de întrebări

### Utilizare

```bash
python3 S02_02_quiz_generator.py [options]

Options:
  --count N        Number of unique quizzes to generate
  --questions N    Questions per quiz (default: 10)
  --seed N         Random seed for reproducibility
  --output DIR     Output directory for generated quizzes
  --format FMT     Output format: yaml, json, pdf, moodle
```

### Exemple

```bash
# Generează 5 quiz-uri unice
python3 S02_02_quiz_generator.py --count 5 --output quizzes/

# Generare reproductibilă
python3 S02_02_quiz_generator.py --seed 42 --count 3

# Export pentru Moodle
python3 S02_02_quiz_generator.py --format moodle --output moodle_quiz.xml
```

---

## S02_03_report_generator.py

**Scop:** generare de rapoarte PDF/HTML din datele de notare

### Utilizare

```bash
python3 S02_03_report_generator.py <grades_file> [options]

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
# Raport sumar
python3 S02_03_report_generator.py grades.csv --summary

# Rapoarte individuale
python3 S02_03_report_generator.py grades.csv --individual --output reports/
```

---

## Opțiuni comune

Toate instrumentele Python suportă:

| Opțiune | Descriere |
|--------|-------------|
| `--help` | afișează help detaliat |
| `--version` | afișează versiunea |
| `--quiet` | suprimă output-ul neesențial |
| `--debug` | activează logare debug |

## Setare PYTHONPATH

Pentru importul modulelor comune din `lib/`:

```bash
# Adaugă în .bashrc sau rulează înainte de scripturi
export PYTHONPATH="${PYTHONPATH}:$(pwd)/../.."

# Sau rulează cu path
PYTHONPATH="../.." python3 S02_01_autograder.py submission/
```

---

*Vezi și: `../../lib/` pentru utilitare comune*  
*Vezi și: [`../../tests/`](../../tests/) pentru suita de teste*

*Ultima actualizare: ianuarie 2026*
