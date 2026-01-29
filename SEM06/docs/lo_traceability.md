# Learning Outcomes Traceability — CAPSTONE SEM06

> **Sisteme de Operare** | ASE București - CSIE  
> Seminar 6: Proiecte Integrate (Monitor, Backup, Deployer)

---

## Despre Acest Document

Matricea de trasabilitate conectează:
- **Learning Outcomes (LO)** — ce trebuie să știe/facă studentul
- **Materiale** — unde se predă fiecare LO
- **Evaluare** — cum verificăm atingerea LO
- **Bloom Level** — nivelul cognitiv vizat

---

## Learning Outcomes SEM06

| ID | Learning Outcome | Bloom | Verificabil |
|----|------------------|-------|-------------|
| **LO6.1** | Proiectează arhitectură modulară pentru scripturi Bash | Create | Da |
| **LO6.2** | Implementează error handling cu trap și exit codes | Apply | Da |
| **LO6.3** | Construiește sistem de logging cu nivele | Apply | Da |
| **LO6.4** | Citește și interpretează date din /proc | Understand | Da |
| **LO6.5** | Implementează backup incremental cu find -newer | Apply | Da |
| **LO6.6** | Verifică integritatea datelor cu checksums | Apply | Da |
| **LO6.7** | Aplică strategii de deployment (rolling, blue-green) | Apply | Da |
| **LO6.8** | Implementează health checks cu retry și backoff | Apply | Da |
| **LO6.9** | Scrie teste unitare pentru funcții Bash | Create | Da |
| **LO6.10** | Automatizează sarcini cu cron/systemd timers | Apply | Da |
| **LO6.11** | Debugează scripturi folosind set -x și strace | Analyse | Da |
| **LO6.12** | Evaluează trade-off-uri în design decizii | Evaluate | Parțial |

---

## Matricea de Trasabilitate

### LO → Materiale

| LO | docs/ | scripts/ | quiz | peer | parsons |
|----|-------|----------|------|------|---------|
| LO6.1 | S06_01 | projects/*/lib/ | q04 | PI-04 | PP-04 |
| LO6.2 | S06_06 | */lib/core.sh | q01, q09 | PI-05 | PP-01 |
| LO6.3 | S06_06 | */lib/core.sh | q07 | PI-08 | PP-05 |
| LO6.4 | S06_02 | monitor/lib/utils.sh | q04 | PI-01 | - |
| LO6.5 | S06_03 | backup/lib/core.sh | q05, q10 | PI-07 | PP-02 |
| LO6.6 | S06_03 | backup/lib/utils.sh | q14 | - | - |
| LO6.7 | S06_07 | deployer/lib/core.sh | q08, q17 | PI-10 | - |
| LO6.8 | S06_04 | deployer/lib/utils.sh | q06, q12 | PI-09 | PP-03 |
| LO6.9 | S06_05 | */tests/*.sh | - | - | - |
| LO6.10 | S06_08 | resurse/systemd/ | - | - | - |
| LO6.11 | S06_05 | test_helpers.sh | q15 | PI-06 | - |
| LO6.12 | S06_07 | - | q17, q18 | - | - |

### LO → Exerciții

| LO | Sprint | LLM-Aware | Temă |
|----|--------|-----------|------|
| LO6.1 | - | Ex5 | T1, T2, T3 |
| LO6.2 | S1 | Ex4 | T1, T2, T3 |
| LO6.3 | S3 | Ex5 | T1 |
| LO6.4 | - | Ex1, Ex3 | T1 |
| LO6.5 | S6 | - | T2 |
| LO6.6 | - | - | T2 |
| LO6.7 | - | - | T3 |
| LO6.8 | S7 | - | T3 |
| LO6.9 | - | - | T4 |
| LO6.10 | - | - | T2, T3 |
| LO6.11 | - | Ex2, Ex4 | T4 |
| LO6.12 | - | Ex6 | T4 |

---

## Distribuția Bloom

### Per Material

| Material | R | U | Ap | An | Ev | Cr |
|----------|---|---|----|----|----|----|
| docs/ | 10% | 30% | 35% | 15% | 5% | 5% |
| Quiz | 17% | 28% | 33% | 11% | 11% | 0% |
| Peer Instruction | 10% | 40% | 30% | 20% | 0% | 0% |
| Parsons | 0% | 20% | 60% | 20% | 0% | 0% |
| Sprint | 0% | 10% | 80% | 10% | 0% | 0% |
| LLM-Aware | 0% | 20% | 30% | 30% | 10% | 10% |
| Teme | 0% | 10% | 40% | 20% | 15% | 15% |

### Sumar (conform țintelor pentru începători)

| Nivel | Țintă | Actual | Status |
|-------|-------|--------|--------|
| Remember | 15-20% | 6% | ⚠️ Sub țintă |
| Understand | 25-30% | 25% | ✓ OK |
| Apply | 30-35% | 44% | ⚠️ Peste țintă |
| Analyse | 10-15% | 15% | ✓ OK |
| Evaluate | 3-5% | 7% | ⚠️ Ușor peste |
| Create | 3-5% | 5% | ✓ OK |

**Notă:** CAPSTONE are mai mult Apply și Analyse, mai puțin Remember, deoarece studenții au acumulat cunoștințe în SEM01-05.

---

## Verificare Atingere LO

### Metode de Verificare

| LO | Pre-test | În seminar | Post-test | Temă |
|----|----------|------------|-----------|------|
| LO6.1 | - | Live coding | Quiz q04 | T1-T3 |
| LO6.2 | Quiz q01 | Demo | Quiz q09 | T1-T3 |
| LO6.3 | - | Sprint S3 | - | T1 |
| LO6.4 | - | LLM Ex1 | - | T1 |
| LO6.5 | Quiz q05 | Demo backup | Quiz q10 | T2 |
| LO6.6 | - | - | Quiz q14 | T2 |
| LO6.7 | Quiz q08 | Demo deploy | Quiz q17 | T3 |
| LO6.8 | - | Sprint S7 | Quiz q12 | T3 |
| LO6.9 | - | - | - | T4 |
| LO6.10 | - | - | - | T2, T3 |
| LO6.11 | - | LLM Ex2 | Quiz q15 | T4 |
| LO6.12 | - | Discuție | Quiz q18 | T4 |

---

## Parsons Problems cu Distractori Bash-Specifici

### PP-01: Trap Handler (vezi S06_04)
**Distractori testați:**
- `TEMP_FILE = $(mktemp)` — spații la atribuire ❌
- `trap cleanup() EXIT` — paranteze greșite ❌
- `trap 'cleanup' ON_EXIT` — semnal invalid ❌

### PP-02: Backup Incremental (vezi S06_04)
**Distractori testați:**
- `find $SOURCE -newer ...` — lipsesc ghilimele ❌
- `find --newer` — flag invalid ❌
- `tar czf $BACKUP < find` — sintaxă invalidă ❌

### PP-03: Health Check (vezi S06_04)
**Distractori testați:**
- `while [ $retry < $MAX ]` — comparație invalidă în `[ ]` ❌
- `retry = $((retry+1))` — spații la atribuire ❌
- `curl -sf $URL` — lipsesc ghilimele ❌

### PP-04: Source Libraries (vezi S06_04)
**Distractori testați:**
- `SCRIPT_DIR=$(dirname $0)` — nu rezolvă symlinks ❌
- `source $LIB_DIR/core.sh` — lipsesc ghilimele ❌

### PP-05: Logging (vezi S06_04)
**Distractori testați:**
- `local level = "$1"` — spații la atribuire ❌
- `echo [$timestamp] [$level]` — brackets se expandează ❌

### PP-06: Array Iteration (vezi S06_04)
**Distractori testați:**
- `for s in $SERVERS` — ia doar primul element ❌
- `for s in ${SERVERS[@]}` — spațiile sparg ❌
- `SERVERS = (...)` — spații la atribuire array ❌

---

## Mapping Quiz → LO

| Întrebare | LO Principal | LO Secundar | Bloom |
|-----------|--------------|-------------|-------|
| q01 | LO6.2 | - | Remember |
| q02 | LO6.2 | - | Remember |
| q03 | LO6.2 | - | Remember |
| q04 | LO6.1 | - | Understand |
| q05 | LO6.5 | - | Understand |
| q06 | LO6.8 | - | Understand |
| q07 | LO6.3 | - | Understand |
| q08 | LO6.7 | - | Understand |
| q09 | LO6.2 | - | Apply |
| q10 | LO6.5 | - | Apply |
| q11 | LO6.1 | - | Apply |
| q12 | LO6.8 | - | Apply |
| q13 | LO6.1 | - | Apply |
| q14 | LO6.6 | - | Apply |
| q15 | LO6.11 | LO6.2 | Analyse |
| q16 | LO6.2 | - | Analyse |
| q17 | LO6.7 | LO6.12 | Evaluate |
| q18 | LO6.5 | LO6.12 | Evaluate |

---

## Lacune și Recomandări

### LO cu acoperire slabă

| LO | Problemă | Recomandare |
|----|----------|-------------|
| LO6.9 | Fără întrebări quiz | Adaugă în tema T4 |
| LO6.10 | Doar documentație | Adaugă sprint cron |
| LO6.12 | Greu de evaluat obiectiv | Discuție în seminar |

### Îmbunătățiri Sugerate

1. **Adaugă 2 întrebări Remember** pentru echilibrarea distribuției Bloom
2. **Quiz despre cron** pentru LO6.10
3. **Exercițiu explicit de testing** pentru LO6.9

---

## Referințe

- Anderson, L.W. & Krathwohl, D.R. (2001). *A Taxonomy for Learning, Teaching, and Assessing*
- Biggs, J. & Tang, C. (2011). *Teaching for Quality Learning at University*
- Brown & Wilson (2018). *Ten Quick Tips for Teaching Programming*

---

*Document generat pentru SEM06 CAPSTONE — Sisteme de Operare*  
*ASE București - CSIE | 2024-2025*
