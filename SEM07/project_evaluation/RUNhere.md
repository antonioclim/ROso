# Evaluarea proiectului — autograder și susținere orală

> **Locație:** `SEM07/project_evaluation/`  
> **Scop:** Evaluare automată și manuală a proiectelor de semestru  
> **Public țintă:** Doar cadre didactice (CONFIDENȚIAL)

## Conținut

| Fișier | Scop |
|------|---------|
| `run_auto_eval_EN.sh` | Script principal pentru evaluare automată |
| `run_plagiarism_check.sh` | Verificări de plagiat pentru proiecte |
| `scripts/` | Scripturi Python auxiliare |
| `Docker/` | Mediu izolat de evaluare (container) |
| `templates/` | Șabloane pentru rapoarte |
| `manual_eval_checklist_EN.md` | Checklist pentru evaluare manuală |
| `oral_defence_questions_EN.md` | Întrebări pentru susținerea orală |

---

## Autograder‑ul de proiect (run_auto_eval_EN.sh)

### Utilizare

```bash
./run_auto_eval_EN.sh <project_dir> [options]

Options:
  --docker            Run evaluation in Docker container
  --timeout SEC       Per-test timeout (default: 60)
  --report FILE       Output report file
  --verbose           Detailed output
  --keep-temp         Keep temporary files
  --no-style-check    Skip style checks
```

### Exemple

```bash
# Evaluate single project
./run_auto_eval_EN.sh submissions/student123_project/

# Batch evaluation
./run_auto_eval_EN.sh submissions/ --batch --report project_results.csv

# Docker-based evaluation (recommended)
./run_auto_eval_EN.sh submissions/student123_project/ --docker
```

---

## Mediu Docker (recomandat)

Evaluarea în container oferă:

- reproducibilitate;
- izolare;
- limite de resurse;
- lipsa accesului la rețea.

### Precondiții

- Docker instalat
- Proiectul este mount‑at în container în `/project`
- Suitele de test există (în `Docker/` sau în proiect)

### Build pentru imaginea Docker

```bash
cd Docker/
docker build -t enos-eval:latest .

# Verify
docker run --rm enos-eval:latest bash --version
```

### Testare manuală

```bash
# Interactive debugging
docker run -it --rm -v $(pwd)/project:/project enos-eval:latest /bin/bash

# Run make test manually
docker run --rm -v $(pwd)/project:/project enos-eval:latest make -C /project test
```

---

## Procesul de evaluare

### Pasul 1: Validare

```bash
# Automatic checks before evaluation
- Archive integrity
- Required files (README, Makefile, src/)
- No forbidden files
- Size limits
```

### Pasul 2: Build

```bash
# Inside container
cd /project
make all
```

### Pasul 3: Testare

```bash
# Run project test suite
make test

# Run evaluation test suite
/eval/run_tests.sh
```

### Pasul 4: Colectarea rezultatelor

```bash
# Parse test output
# Calculate scores
# Generate feedback
```

---

## Formatul output‑ului

### Raport de evaluare

```
═══════════════════════════════════════════════════════════════
 PROJECT EVALUATION REPORT
═══════════════════════════════════════════════════════════════

Student: student123
Project: M02_Process_Lifecycle_Monitor
Date: 2026-01-30 14:32:15

BUILD: ✅ PASSED
  make all completed in 2.3s

TESTS: 8/10 PASSED (80%)
  ✅ test_basic_functionality
  ✅ test_process_detection
  ✅ test_output_format
  ⚠️ test_edge_cases (partial: 5/10)
  ❌ test_performance (timeout)
  ...

STYLE: 85%
  shellcheck: 2 warnings
  Documentation: Complete

TOTAL: 78/100

═══════════════════════════════════════════════════════════════
```

---

## Considerații de securitate

| Măsură | Implementare |
|---------|----------------|
| Izolare | Container Docker |
| Fără rețea | flag `--network none` |
| Limite de resurse | CPU, memorie, cote disc |
| Timeout | Terminare forțată după timeout |
| Non-root | utilizator `evaluator` în container |
| Read-only | sursa este montată read‑only |

---

## Evaluare manuală

După evaluarea automată, utilizați:

- `manual_eval_checklist_EN.md` — checklist pentru review manual
- `oral_defence_questions_EN.md` — întrebări pentru interviul de proiect

```bash
# Example checklist items
□ Code is readable and well-organised
□ Solution demonstrates understanding
□ Error handling is appropriate
□ Documentation is complete
```

---

*Vedeți și: [`Docker/`](Docker/) pentru configurarea containerului*  
*Vedeți și: [`../grade_aggregation/`](../grade_aggregation/) pentru nota finală*

*Ultima actualizare: ianuarie 2026*
