# SEM07: Evaluare finală și kit de notare

Acest seminar conține **tooling complet pentru evaluare** destinat disciplinei *Sisteme de Operare* (ASE Bucharest – CSIE). Include:

- evaluarea temelor (automată + rubrici);
- evaluarea proiectului (autograder + checklist manual + întrebări pentru susținere orală);
- agregarea notelor finale (pipeline de calcul);
- bancă de întrebări pentru testul final.

---

## Cuprins

1. [Prezentare generală](#prezentare-generală)
2. [Formula de notare](#formula-de-notare)
3. [Criterii eliminatorii](#criterii-eliminatorii)
4. [Structura directoarelor](#structura-directoarelor)
5. [Ghid de utilizare rapidă](#ghid-de-utilizare-rapidă)
6. [Dependențe](#dependențe)
7. [Securitate și integritate academică](#securitate-și-integritate-academică)

---

## Prezentare generală

### Componente incluse

| Componentă | Director | Scop |
|----------|-----------|---------|
| **Evaluarea temelor** | `homework_evaluation/` | Notarea predărilor `.cast`, rubrici pe seminare |
| **Evaluarea proiectului** | `project_evaluation/` | Autograder, evaluare manuală, susținere orală |
| **Agregarea notelor** | `grade_aggregation/` | Calculul notei finale și exporturi |
| **Test final** | `final_test/` | Bancă de întrebări și generare variante |

### Public țintă

- Cadre didactice (profesori, conferențiari)
- Asistenți didactici / laboranți
- Responsabili de curs

---

## Formula de notare

Nota finală este calculată astfel:

```
NOTA_FINALĂ = (TEME × 0.25) + (PROIECT × 0.50) + (TEST × 0.25)
```

Detalii complete în: [`grade_aggregation/GRADING_POLICY.md`](grade_aggregation/GRADING_POLICY.md)

---

## Criterii eliminatorii

⚠️ **CRITIC: Pragul de 80%**

Studentul este eliminat automat (nota 4) dacă:

- A predat mai puțin de 25/31 teme (80.6%)
- A susținut mai puțin de 5/6 teste (83.3%)
- Proiectul nu îndeplinește cerințele minime (GitHub, README complet, output real)

Detalii în: [`grade_aggregation/GRADING_POLICY.md`](grade_aggregation/GRADING_POLICY.md#2-elimination-criteria)

---

## Structura directoarelor

```
SEM07/
├── README.md                         # This file
├── docs/                             # Documentation
│   ├── S07_00_PEDAGOGICAL_ANALYSIS_PLAN.md
│   └── S07_01_INSTRUCTOR_GUIDE.md
├── homework_evaluation/              # Homework grading
│   ├── verify_homework_EN.sh         # Submission verifier
│   ├── grade_homework_EN.py          # Automated grader
│   ├── HOMEWORK_EVALUATION_GUIDE.md  # Full grading guide
│   └── homework_rubrics/             # Rubrics per seminar
├── project_evaluation/               # Project grading
│   ├── run_auto_eval_EN.sh           # Project autograder
│   ├── Docker/                       # Isolated eval environment
│   ├── manual_eval_checklist_EN.md   # Manual evaluation checklist
│   └── oral_defence_questions_EN.md  # Oral defence questions
├── grade_aggregation/                # Final grade calculation
│   ├── final_grade_calculator_EN.py  # Grade calculator
│   ├── GRADING_POLICY.md             # Official policy
│   └── templates/                    # CSV templates
├── final_test/                       # Final examination
│   └── test_bank/
│       ├── questions_pool.yaml       # Question bank
│       └── RUNhere.md                # Usage instructions
└── external_tools/                   # Plagiarism detection
    ├── run_moss.sh                   # MOSS integration
    └── MOSS_JPLAG_GUIDE.md           # Setup guide
```

---

## Ghid de utilizare rapidă

### 1. Notarea temelor

```bash
cd homework_evaluation/
./verify_homework_EN.sh submissions/ --batch --seminar 4
python3 grade_homework_EN.py submissions/ --batch --feedback --output grades.csv
```

### 2. Evaluarea proiectului

```bash
cd project_evaluation/
./run_auto_eval_EN.sh submissions/student123_project/ --docker --report report.txt
```

### 3. Generarea testului final

Consultați banca de întrebări din `final_test/test_bank/` și generați o variantă de examen utilizând generatorul de quiz:

```bash
cd final_test/test_bank/

python3 ../../../SEM01/scripts/python/S01_02_quiz_generator.py     --input questions_pool.yaml     --output exam_v1.yaml     --questions 40     --points 100     --seed 2025
```

### 4. Calculul notelor finale

```bash
cd grade_aggregation/
python3 final_grade_calculator_EN.py     --homework homework_grades.csv     --project project_grades.csv     --exam exam_grades.csv     --output final_grades.csv
```

---

## Dependențe

### Dependențe necesare

- Python 3.8+ (recomandat: 3.10+)
- Bash 4.0+
- Docker (pentru evaluare izolată, recomandat)
- shellcheck (verificare de stil)

### Instalare rapidă (Ubuntu/Debian)

```bash
sudo apt update
sudo apt install -y python3 python3-pip shellcheck docker.io
```

---

## Securitate și integritate academică

### Măsuri anti‑plagiat incluse

- Semnături criptografice pe predări `.cast`
- Verificare de integritate (anti‑tampering)
- Randomizare întrebări la testul final
- Checklist pentru susținere orală
- Integrare cu MOSS și JPlag

### Recomandări operaționale

- Rulați evaluarea proiectelor în Docker (fără rețea, fără root)
- Nu păstrați chei private în directoarele de predări
- Arhivați rapoartele de plagiat și notare
- Mențineți banca de întrebări confidențială

---

**Curs:** Sisteme de Operare - ASE Bucharest CSIE  
**Autori:** ing. dr. Antonio Clim, conf. dr. Andrei Toma  
**Licență:** Restricționată 2017-2030

---

*De Revolvix pentru disciplina OPERATING SYSTEMS | licență restricționată 2017-2030*
