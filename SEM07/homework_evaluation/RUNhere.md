# Evaluarea temelor — pipeline de notare

> **Locație:** `SEM07/homework_evaluation/`  
> **Scop:** Infrastructură de notare automată și manuală a temelor  
> **Public țintă:** Cadre didactice și asistenți didactici

## Conținut

| Fișier | Scop |
|------|---------|
| `verify_homework_EN.sh` | Validare structurală înainte de notare |
| `grade_homework_EN.py` | Notare automată cu feedback |
| `homework_rubrics/` | Rubrici de notare per seminar |

---

## Prezentare generală a fluxului

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│ Student submits │ ──► │ verify_homework │ ──► │ grade_homework  │
│                 │     │  (structure)    │     │  (auto + manual)│
└─────────────────┘     └─────────────────┘     └─────────────────┘
                                                        │
                        ┌───────────────────────────────┘
                        ▼
                ┌─────────────────┐
                │ Manual review   │
                │ (partial credit)│
                └─────────────────┘
```

---

## verify_homework_EN.sh

**Scop:** validare structurală rapidă înainte de notarea detaliată.

### Utilizare

```bash
./verify_homework_EN.sh <submission_dir> [options]

Options:
  --seminar N       Validate against seminar N requirements
  --strict          Fail on any warning
  --report FILE     Generate verification report
  --batch DIR       Verify entire submissions directory
```

### Ce verifică

| Verificare | Descriere |
|-------|-------------|
| Existența fișierelor | Există fișierele obligatorii |
| Denumirea fișierelor | Respectă convenția de nume |
| Sintaxa scripturilor | `bash -n` trece |
| Permisiuni | Scripturile sunt executabile |
| Fără fișiere interzise | Fără `.env`, credențiale |
| Terminatori de linie | LF, nu CRLF |

### Exemple

```bash
# Single submission
./verify_homework_EN.sh submissions/student123/ --seminar 4

# Batch verification
./verify_homework_EN.sh --batch submissions/ --seminar 4 --report verify_report.txt
```

---

## grade_homework_EN.py

**Scop:** notare automată pe baza rubricilor configurabile.

### Utilizare

```bash
python3 grade_homework_EN.py <submission> [options]

Arguments:
  submission        Single submission or directory of submissions

Options:
  --seminar N       Use rubric for seminar N
  --rubric FILE     Custom rubric file
  --output FILE     Output grades file (CSV)
  --feedback        Generate per-student feedback files
  --batch           Process directory of submissions
  --timeout SEC     Per-test timeout (default: 30)
  --verbose         Detailed grading output
```

### Exemple

```bash
# Grade single submission
python3 grade_homework_EN.py submissions/student123/ --seminar 4

# Batch grading with feedback
python3 grade_homework_EN.py submissions/ --batch --feedback --output grades.csv

# Custom rubric
python3 grade_homework_EN.py submissions/ --rubric custom_rubric.yaml
```

### Componentele notării

| Componentă | Pondere | Auto‑corectabil |
|-----------|--------|---------------|
| Corectitudine | 60% | Da (teste) |
| Calitatea codului | 20% | Parțial (shellcheck) |
| Documentație | 20% | Parțial (verificări de prezență) |

---

## Formatul rubricii

Fiecare seminar are o rubrică în `homework_rubrics/`:

```yaml
# S04_HOMEWORK_RUBRIC.md structure
seminar: 4
title: "Text Processing with grep/sed/awk"
max_points: 100

criteria:
  - name: "Exercise 1: grep patterns"
    points: 25
    tests:
      - description: "Basic pattern matching"
        points: 10
        command: "./test_grep_basic.sh"
      - description: "Extended regex"
        points: 15
        command: "./test_grep_extended.sh"

  - name: "Code quality"
    points: 20
    manual: true
    guidelines:
      - "Proper quoting"
      - "Error handling"
      - "Readable formatting"
```

---

## Generarea feedback‑ului

La utilizarea opțiunii `--feedback`, se generează fișiere per student:

```
feedback/
├── student123_feedback.md
├── student456_feedback.md
└── ...
```

### Format feedback

```markdown
# Homework Feedback — Seminar 4
**Student:** student123
**Total Score:** 78/100

## Exercise 1: grep patterns (22/25)
✅ Basic pattern matching: 10/10
⚠️ Extended regex: 12/15
   - Missing case-insensitive flag

## Code Quality (16/20)
- Good error handling
- Improve variable quoting

## Documentation (10/15)
- README present but incomplete
- Add usage examples

---
*Graded: 2026-01-30*
```

---

## Review manual

După notarea automată, revedeți:

1. cazurile de punctaj parțial;
2. soluții alternative corecte;
3. nuanțe privind calitatea codului;
4. profunzimea documentației.

```bash
# Flag submissions for manual review
python3 grade_homework_EN.py submissions/ --batch --flag-review
```

---

*Vedeți și: [`homework_rubrics/`](homework_rubrics/) pentru criterii de notare*  
*Vedeți și: [`../grade_aggregation/`](../grade_aggregation/) pentru nota finală*

*Ultima actualizare: ianuarie 2026*
