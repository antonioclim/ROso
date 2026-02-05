# 📁 Instrumente Python — SEM01

> **Locație:** `SEM01/scripts/python/`  
> **Scop:** Instrumente de evaluare automată, generare și analiză  
> **Versiune Python:** ≥ 3.10 necesară

## Conținut

| Instrument | Scop | CLI |
|------------|------|-----|
| `S01_01_autograder.py` | Evaluare automată teme | Da |
| `S01_02_quiz_generator.py` | Generare quiz-uri randomizate | Da |
| `S01_03_report_generator.py` | Creare rapoarte PDF/HTML | Da |
| `S01_04_assignment_generator.py` | Generare teme personalizate | Da |
| `S01_05_plagiarism_detector.py` | Detecție similaritate cod | Da |
| `S01_06_ai_fingerprint_scanner.py` | Detecție conținut generat AI | Da |

## Instalare

```bash
# Instalare dependențe
cd SEM01/
pip install -r requirements.txt

# Sau instalare individuală
pip install pyyaml pytest
```

---

## S01_01_autograder.py

**Scop:** Evaluare automată teme cu feedback detaliat

### Utilizare

```bash
python3 S01_01_autograder.py <submission> [opțiuni]

Argumente:
  submission       Cale către directorul sau fișierul temei

Opțiuni:
  --rubric PATH    Fișier rubrică personalizat
  --output FILE    Fișier output pentru note (CSV)
  --verbose        Detaliere punctaj
  --batch          Procesează întreg directorul de teme
  --timeout SEC    Timeout per test (implicit: 30)
```

### Exemple

```bash
# Notează o singură temă
python3 S01_01_autograder.py ~/submissions/student123/

# Notează toate temele cu raport
python3 S01_01_autograder.py ~/submissions/ --batch --output grades.csv

# Notare detaliată
python3 S01_01_autograder.py submission/ --verbose
```

### Criterii de notare

| Criteriu | Pondere | Descriere |
|----------|---------|-----------|
| Corectitudine | 60% | Trece cazurile de test |
| Stil | 20% | Conformitate shellcheck |
| Documentare | 20% | Comentarii, README |

---

## S01_02_quiz_generator.py

**Scop:** Generare quiz-uri randomizate din banca de întrebări

### Utilizare

```bash
python3 S01_02_quiz_generator.py [opțiuni]

Opțiuni:
  --count N        Număr de quiz-uri unice de generat
  --questions N    Întrebări per quiz (implicit: 10)
  --seed N         Seed random pentru reproductibilitate
  --output DIR     Director output pentru quiz-uri generate
  --format FMT     Format output: yaml, json, pdf, moodle
```

### Exemple

```bash
# Generează 5 quiz-uri unice
python3 S01_02_quiz_generator.py --count 5 --output quizzes/

# Generare reproductibilă
python3 S01_02_quiz_generator.py --seed 42 --count 3

# Export pentru Moodle
python3 S01_02_quiz_generator.py --format moodle --output moodle_quiz.xml
```

---

## S01_03_report_generator.py

**Scop:** Generare rapoarte PDF/HTML din datele de notare

### Utilizare

```bash
python3 S01_03_report_generator.py <grades_file> [opțiuni]

Argumente:
  grades_file      Fișier CSV cu datele notelor

Opțiuni:
  --format FMT     Format output: pdf, html, md (implicit: pdf)
  --individual     Generează rapoarte per student
  --summary        Include statistici clasă
  --output DIR     Director output
```

### Exemple

```bash
# Generează raport sumar
python3 S01_03_report_generator.py grades.csv --summary

# Rapoarte individuale per student
python3 S01_03_report_generator.py grades.csv --individual --output reports/
```


## S01_04_assignment_generator.py

**Scop:** Generare teme personalizate

```bash
python3 S01_04_assignment_generator.py --help
```

## S01_05_plagiarism_detector.py

**Scop:** Detecție similaritate cod

```bash
python3 S01_05_plagiarism_detector.py --help
```

## S01_06_ai_fingerprint_scanner.py

**Scop:** Detecție conținut generat AI

```bash
python3 S01_06_ai_fingerprint_scanner.py --help
```


---

## Opțiuni comune

Toate instrumentele Python suportă:

| Opțiune | Descriere |
|---------|-----------|
| `--help` | Afișează ajutor detaliat |
| `--version` | Afișează versiunea instrumentului |
| `--quiet` | Suprimă outputul neesențial |
| `--debug` | Activează logging debug |

## Configurare PYTHONPATH

Pentru importul modulelor partajate din `lib/`:

```bash
# Adăugați în .bashrc sau rulați înainte de scripturi
export PYTHONPATH="${PYTHONPATH}:$(pwd)/../.."

# Sau rulați cu cale
PYTHONPATH="../.." python3 S01_01_autograder.py submission/
```

---

*Vezi și: [`../../lib/`](../../lib/) pentru utilitare partajate*  
*Vezi și: [`../../teste/`](../../teste/) pentru suita de teste*

*Ultima actualizare: Ianuarie 2026*
