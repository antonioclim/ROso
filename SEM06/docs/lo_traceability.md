# Trasabilitatea rezultatelor învățării — CAPSTONE SEM06

> **Sisteme de Operare** | ASE București - CSIE  
> Seminarul 6: Proiecte integrate (Monitor, Backup, Deployer)

---

## Despre acest document

Matricea de trasabilitate conectează:
- **Rezultatele învățării (LO)** — ce trebuie studentul să știe / să poată face
- **Materialele** — unde este predat fiecare LO
- **Evaluarea** — cum verificăm atingerea LO
- **Nivelul Bloom** — nivelul cognitiv vizat

> **Notă de laborator:** dacă nu puteți trasa un LO către cel puțin o întrebare de quiz și un exercițiu practic, acel LO este probabil sub‑evaluat. Corectați înainte de seminar.

---

## Rezultatele învățării pentru SEM06

| ID | Rezultat al învățării | Bloom | Verificabil |
|----|------------------|-------|------------|
| **LO6.1** | Proiectează o arhitectură modulară pentru scripturi Bash | Create | Da |
| **LO6.2** | Implementează tratarea erorilor cu trap și coduri de ieșire | Apply | Da |
| **LO6.3** | Construiește un sistem de jurnalizare cu niveluri | Apply | Da |
| **LO6.4** | Citește și interpretează date din /proc | Understand | Da |
| **LO6.5** | Implementează backup incremental cu find -newer | Apply | Da |
| **LO6.6** | Verifică integritatea datelor cu checksums | Apply | Da |
| **LO6.7** | Aplică strategii de deployment (rolling, blue-green) | Apply | Da |
| **LO6.8** | Implementează health checks cu retry și backoff | Apply | Da |
| **LO6.9** | Scrie teste unitare pentru funcții Bash | Create | Da |
| **LO6.10** | Automatizează sarcini cu cron/systemd timers | Apply | Da |
| **LO6.11** | Depanează scripturi folosind set -x și strace | Analyse | Da |
| **LO6.12** | Evaluează trade-off‑uri în decizii de proiectare | Evaluate | Parțial |

---

## Matrice de trasabilitate

### LO → Materiale

| LO | docs/ | scripts/ | quiz | peer | parsons |
|----|-------|----------|------|------|---------|
| LO6.1 | S06_P01 | projects/*/lib/ | q04 | PI-04 | PP-04 |
| LO6.2 | S06_P06 | */lib/core.sh | q01, q09 | PI-05 | PP-01 |
| LO6.3 | S06_P06 | */lib/core.sh | q07 | PI-08 | PP-05 |
| LO6.4 | S06_P02 | monitor/lib/utils.sh | q04 | PI-01 | — |
| LO6.5 | S06_P03 | backup/lib/core.sh | q05, q10 | PI-07 | PP-02 |
| LO6.6 | S06_P03 | backup/lib/utils.sh | q14 | — | — |
| LO6.7 | S06_P07 | deployer/lib/core.sh | q08, q17 | PI-10 | — |
| LO6.8 | S06_P04 | deployer/lib/utils.sh | q06, q12 | PI-09 | PP-03 |
| LO6.9 | S06_P05 | */tests/*.sh | — | — | — |
| LO6.10 | S06_P08 | resources/systemd/ | — | — | — |
| LO6.11 | S06_P05 | test_helpers.sh | q15 | PI-06 | — |
| LO6.12 | S06_P07 | — | q17, q18 | — | — |

### LO → Exerciții

| LO | Sprint | LLM-Aware | Temă |
|----|--------|-----------|------------|
| LO6.1 | — | Ex5 | A1, A2, A3 |
| LO6.2 | S1 | Ex4 | A1, A2, A3 |
| LO6.3 | S3 | Ex5 | A1 |
| LO6.4 | — | Ex1, Ex3 | A1 |
| LO6.5 | S6 | — | A2 |
| LO6.6 | — | — | A2 |
| LO6.7 | — | — | A3 |
| LO6.8 | S7 | — | A3 |
| LO6.9 | — | — | A4 |
| LO6.10 | — | — | A2, A3 |
| LO6.11 | — | Ex2, Ex4 | A4 |
| LO6.12 | — | Ex6 | A4 |

---

## Distribuția Bloom

### Per material

| Material | R | U | Ap | An | Ev | Cr |
|----------|---|---|----|----|----|----|
| docs/ | 10% | 30% | 35% | 15% | 5% | 5% |
| Quiz | 25% | 25% | 30% | 10% | 10% | 0% |
| Peer Instruction | 10% | 40% | 30% | 20% | 0% | 0% |
| Parsons | 0% | 20% | 60% | 20% | 0% | 0% |
| Sprint | 0% | 10% | 80% | 10% | 0% | 0% |
| LLM-Aware | 0% | 20% | 30% | 30% | 10% | 10% |
| Teme | 0% | 10% | 40% | 20% | 15% | 15% |

### Sinteză (față de ținte pentru nivel începător)

| Nivel | Țintă | Realizat | Status |
|-------|--------|--------|--------|
| Remember | 15-20% | 18% | ✓ OK |
| Understand | 25-30% | 25% | ✓ OK |
| Apply | 30-35% | 35% | ✓ OK |
| Analyse | 10-15% | 12% | ✓ OK |
| Evaluate | 3-5% | 8% | ⚠️ Ușor peste (acceptabil pentru CAPSTONE) |
| Create | 3-5% | 2% | ✓ OK |

**Notă:** CAPSTONE echilibrează gândirea de nivel superior cu reamintirea fundamentelor. Procentul ușor ridicat pentru Evaluate reflectă natura integratoare a proiectelor capstone — studenții trebuie să își justifice deciziile de proiectare.

---

## Hartă de referință a fișierelor (actualizată)

### Fișiere pedagogice standard (docs/)

| Fișier | Conținut |
|------|---------|
| S06_00_PEDAGOGICAL_ANALYSIS_PLAN.md | Public țintă, alinierea LO, structura sesiunii |
| S06_01_INSTRUCTOR_GUIDE.md | Cronologie, note de facilitare, puncte de control |
| S06_02_MAIN_MATERIAL.md | Index către documentația proiectelor |
| S06_03_PEER_INSTRUCTION.md | 10 întrebări PI cu note pentru instructor |
| S06_04_PARSONS_PROBLEMS.md | 6 exerciții de ordonare a codului |
| S06_05_LIVE_CODING_GUIDE.md | Exemple lucrate pentru demonstrații |
| S06_06_SPRINT_EXERCISES.md | Exerciții cronometrate de pair programming |
| S06_07_LLM_AWARE_EXERCISES.md | Exerciții cu interacțiune AI |
| S06_08_SPECTACULAR_DEMOS.md | Scenarii hook și demo-uri |
| S06_09_VISUAL_CHEAT_SHEET.md | Referință rapidă, o pagină |
| S06_10_SELF_ASSESSMENT_REFLECTION.md | Checklist‑uri metacognitive |

### Fișiere specifice proiectelor (docs/projects/)

| Fișier | Conținut |
|------|---------|
| S06_P00_Introduction_CAPSTONE.md | Context, motivație, overview |
| S06_P01_Project_Architecture.md | Pattern‑uri comune, structură directoare |
| S06_P02_Monitor_Implementation.md | Ghid Monitor |
| S06_P03_Backup_Implementation.md | Ghid Backup |
| S06_P04_Deployer_Implementation.md | Ghid Deployer |
| S06_P05_Testing_Framework.md | Pattern‑uri de testare pentru Bash |
| S06_P06_Error_Handling.md | Trap, logging, coduri de ieșire |
| S06_P07_Deployment_Strategies.md | Rolling, blue-green, canary |
| S06_P08_Cron_Automation.md | Planificare și timers |

---

## Verificarea atingerii LO

### Metode de verificare

| LO | Pre-test | În seminar | Post-test | Temă |
|----|----------|------------|-----------|------------|
| LO6.1 | — | Live coding | Quiz q04 | A1-A3 |
| LO6.2 | Quiz q01 | Demo | Quiz q09 | A1-A3 |
| LO6.3 | — | Sprint S3 | — | A1 |
| LO6.4 | — | LLM Ex1 | — | A1 |
| LO6.5 | Quiz q05 | Demo backup | Quiz q10 | A2 |
| LO6.6 | — | — | Quiz q14 | A2 |
| LO6.7 | Quiz q08 | Demo deploy | Quiz q17 | A3 |
| LO6.8 | — | Sprint S7 | Quiz q12 | A3 |
| LO6.9 | — | — | — | A4 |
| LO6.10 | — | — | — | A2, A3 |
| LO6.11 | — | LLM Ex2 | Quiz q15 | A4 |
| LO6.12 | — | Discuție | Quiz q18 | A4 |

---

## Distractori Parsons — specifici Bash

### PP-01: Trap Handler
**Distractori testați:**
- `TEMP_FILE = $(mktemp)` — spații la atribuire ❌
- `trap cleanup() EXIT` — paranteze greșite ❌
- `trap 'cleanup' ON_EXIT` — semnal invalid ❌

### PP-02: Backup incremental
**Distractori testați:**
- `find $SOURCE -newer ...` — lipsesc ghilimelele ❌
- `find --newer` — flag invalid ❌
- `tar czf $BACKUP < find` — sintaxă invalidă ❌

### PP-03: Health Check
**Distractori testați:**
- `while [ $retry < $MAX ]` — comparație invalidă în `[ ]` ❌
- `retry = $((retry+1))` — spații la atribuire ❌
- `curl -sf $URL` — lipsesc ghilimelele ❌

### PP-04: Source Libraries
**Distractori testați:**
- `SCRIPT_DIR=$(dirname $0)` — nu rezolvă symlink‑uri ❌
- `source $LIB_DIR/core.sh` — lipsesc ghilimelele ❌

### PP-05: Logging
**Distractori testați:**
- `local level = "$1"` — spații la atribuire ❌
- `echo [$timestamp] [$level]` — parantezele pătrate se expandă ❌

### PP-06: Iterare array
**Distractori testați:**
- `for s in $SERVERS` — ia doar primul element ❌
- `for s in ${SERVERS[@]}` — spațiile rup elementele ❌
- `SERVERS = (...)` — spații la atribuire în array ❌

---

## Quiz → mapare LO

| Întrebare | LO primar | LO secundar | Bloom |
|----------|------------|--------------|-------|
| q01 | LO6.2 | — | Remember |
| q02 | LO6.2 | — | Remember |
| q03 | LO6.2 | — | Remember |
| q04 | LO6.1 | — | Understand |
| q05 | LO6.5 | — | Understand |
| q06 | LO6.8 | — | Understand |
| q07 | LO6.3 | — | Understand |
| q08 | LO6.7 | — | Understand |
| q09 | LO6.2 | — | Apply |
| q10 | LO6.5 | — | Apply |
| q11 | LO6.1 | — | Apply |
| q12 | LO6.8 | — | Apply |
| q13 | LO6.1 | — | Apply |
| q14 | LO6.6 | — | Apply |
| q15 | LO6.11 | LO6.2 | Analyse |
| q16 | LO6.2 | — | Analyse |
| q17 | LO6.7 | LO6.12 | Evaluate |
| q18 | LO6.5 | LO6.12 | Evaluate |
| q19 | LO6.2 | — | Remember |
| q20 | LO6.5 | LO6.6 | Remember |

---

## Lacune și recomandări

### LO cu acoperire adecvată

Toate rezultatele învățării primare au acum acoperire adecvată în quiz. Adăugarea q19 (semnale) și q20 (compresie) echilibrează distribuția Bloom.

| LO | Status | Note |
|----|--------|-------|
| LO6.9 | ⚠️ | Acoperit în tema A4, fără quiz direct |
| LO6.10 | ⚠️ | Acoperit în docs și exemplele cron |
| LO6.12 | ✓ | Acoperit prin q17, q18 (nivel Evaluate) |

### Îmbunătățiri finalizate

1. ✅ **Adăugate 2 întrebări Remember** (q19, q20) pentru echilibrarea distribuției Bloom
2. ✅ **Echilibrare taxonomia Bloom** — Remember este acum la 18% (era 6%)
3. ✅ **Acoperire pentru semnale și compresie** — concepte fundamentale consolidate
4. ⏳ **Sprint cron** — recomandat pentru o iterație viitoare
5. ⏳ **Exercițiu explicit de testare** — acoperit prin tema A4

---

## Referințe

- Anderson, L.W. & Krathwohl, D.R. (2001). *A Taxonomy for Learning, Teaching, and Assessing*
- Biggs, J. & Tang, C. (2011). *Teaching for Quality Learning at University*
- Brown & Wilson (2018). *Ten Quick Tips for Teaching Programming*

---

*Trasabilitatea rezultatelor învățării pentru SEM06 CAPSTONE — Sisteme de Operare*  
*ASE București - CSIE | 2024-2025*
