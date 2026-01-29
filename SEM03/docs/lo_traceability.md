# Matrice Trasabilitate Learning Outcomes — Seminarul 03
## Sisteme de Operare | ASE București - CSIE

> **Versiune:** 1.0 | **Data:** Ianuarie 2025  
> **Subiect:** System Administration — find, xargs, getopts, permisiuni, CRON

---

## Cuprins

1. [Learning Outcomes](#1-learning-outcomes)
2. [Matrice de Acoperire](#2-matrice-de-acoperire)
3. [Parsons Problems cu Distractori](#3-parsons-problems-cu-distractori)
4. [Mapping Bloom Taxonomy](#4-mapping-bloom-taxonomy)

---

## 1. Learning Outcomes

La finalizarea Seminarului 03, studenții vor fi capabili să:

| ID | Learning Outcome | Nivel Bloom | Verb acțiune |
|----|------------------|-------------|--------------|
| **LO1** | Construiască comenzi `find` cu criterii multiple și acțiuni | Apply | construiește |
| **LO2** | Utilizeze `xargs` pentru procesare batch eficientă și sigură | Apply | utilizează |
| **LO3** | Implementeze parsare argumente folosind `getopts` | Apply | implementează |
| **LO4** | Calculeze și aplice permisiuni în format octal și simbolic | Apply | calculează, aplică |
| **LO5** | Configureze cron jobs cu logging și error handling | Apply | configurează |
| **LO6** | Diagnosticheze probleme comune de permisiuni și cron | Analyse | diagnostichează |
| **LO7** | Evalueze eficiența diferitelor abordări de procesare batch | Evaluate | evaluează |

---

## 2. Matrice de Acoperire

### 2.1 Acoperire pe Fișiere

| LO | Material Principal | Peer Instruction | Live Coding | Sprint Ex. | LLM-Aware | Quiz |
|:--:|:------------------:|:----------------:|:-----------:|:----------:|:---------:|:----:|
| LO1 | S03_02 §2.1 | PI-01, PI-02 | LC-01 | Ex 1-3 | E1, E2 | Q01-Q04 |
| LO2 | S03_02 §2.2 | PI-03, PI-04 | LC-02 | Ex 4-5 | E3 | Q05 |
| LO3 | S03_02 §3 | PI-06, PI-07, PI-08 | LC-03 | Ex 6-8 | E4, E5 | Q06-Q08 |
| LO4 | S03_02 §4 | PI-10, PI-11, PI-12 | LC-04 | Ex 9-12 | E6, E7 | Q09-Q12 |
| LO5 | S03_02 §5 | PI-15, PI-16, PI-17 | LC-05 | Ex 13-15 | E8, E9 | Q13-Q15 |
| LO6 | S03_02 §6 | PI-05, PI-09, PI-14 | LC-01, LC-04 | Ex 16-17 | E10 | Q11, Q16 |
| LO7 | S03_02 §7 | PI-03 | LC-02 | Ex 18 | E11 | Q17 |

### 2.2 Acoperire pe Activități

| Activitate | LO1 | LO2 | LO3 | LO4 | LO5 | LO6 | LO7 |
|------------|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| Prezentare teorie | ● | ● | ● | ● | ● | ○ | ○ |
| Live coding | ● | ● | ● | ● | ● | ● | ○ |
| Exerciții ghidate | ● | ● | ● | ● | ● | ● | ○ |
| Exerciții sprint | ● | ● | ● | ● | ● | ● | ● |
| Temă | ● | ● | ● | ● | ● | ● | ● |
| Quiz formativ | ● | ● | ● | ● | ● | ● | ● |

**Legendă:** ● = acoperire primară, ○ = acoperire secundară

---

## 3. Parsons Problems cu Distractori

### PP-01: Script find cu ștergere fișiere vechi

**Sarcină:** Aranjează liniile pentru a crea un script care șterge fișierele `.tmp` mai vechi de 7 zile din `/tmp`.

**LO acoperite:** LO1, LO2

**Linii corecte (ordine corectă):**
```bash
#!/bin/bash
set -euo pipefail
find /tmp -name "*.tmp" -type f -mtime +7 -print0 | xargs -0 rm -f
echo "Curățare completă"
```

**Distractori (linii greșite):**

| Linie greșită | Eroare | Misconceptie vizată |
|---------------|--------|---------------------|
| `find /tmp -name "*.tmp" -mtime 7 -print` | Lipsește `+` la mtime, lipsește `-type f`, lipsește `-print0` | Confuzie semn +/- la mtime |
| `find /tmp -name *.tmp -type f -mtime +7` | Lipsesc ghilimelele la pattern | Shell expandează prematur wildcard-ul |
| `xargs rm -f` | Lipsește `-0` pentru null separator | Probleme cu spații în nume |
| `find /tmp -type f "*.tmp" -mtime +7` | Sintaxă greșită: `-name` lipsește | Confuzie ordine opțiuni |

**Soluție cu explicații:**
```bash
#!/bin/bash
# Shebang - obligatoriu prima linie
set -euo pipefail
# Strict mode: exit on error, undefined vars, pipe failures
find /tmp -name "*.tmp" -type f -mtime +7 -print0 | xargs -0 rm -f
# -name cu ghilimele, -type f pentru doar fișiere, +7 = mai vechi de 7 zile
# -print0 și -0 pentru handling corect spații în nume
echo "Curățare completă"
```

---

### PP-02: Script cu getopts

**Sarcină:** Aranjează liniile pentru un script care acceptă `-v` (verbose) și `-f FILE` (fișier input).

**LO acoperite:** LO3

**Linii corecte (ordine corectă):**
```bash
#!/bin/bash
VERBOSE=false
INPUT_FILE=""
while getopts "vf:" opt; do
    case $opt in
        v) VERBOSE=true ;;
        f) INPUT_FILE="$OPTARG" ;;
        *) echo "Utilizare: $0 [-v] -f file" >&2; exit 1 ;;
    esac
done
```

**Distractori (linii greșite):**

| Linie greșită | Eroare | Misconceptie vizată |
|---------------|--------|---------------------|
| `while getopts "v:f:" opt; do` | `:` incorect după `v` | v e flag, nu are argument |
| `while getopts "vf" opt; do` | Lipsește `:` după `f` | f necesită argument |
| `f) INPUT_FILE=$OPTARG ;;` | Lipsesc ghilimelele | Variabilele trebuie citate |
| `case "$opt" in` | Ghilimele inutile dar nu greșite | Nu e eroare, dar poate confuza |
| `INPUT_FILE = ""` | Spații la atribuire | Eroare clasică Bash |

**Soluție cu explicații:**
```bash
#!/bin/bash
VERBOSE=false           # Inițializare variabile
INPUT_FILE=""           # FĂRĂ spații la =
while getopts "vf:" opt; do    # v=flag, f:=cu argument
    case $opt in
        v) VERBOSE=true ;;              # Flag simplu
        f) INPUT_FILE="$OPTARG" ;;      # $OPTARG conține argumentul
        *) echo "Utilizare: $0 [-v] -f file" >&2; exit 1 ;;
    esac
done
```

---

### PP-03: Verificare și setare permisiuni

**Sarcină:** Aranjează liniile pentru a verifica dacă un fișier e executabil și, dacă nu, să-l facă executabil.

**LO acoperite:** LO4, LO6

**Linii corecte (ordine corectă):**
```bash
#!/bin/bash
FILE="$1"
if [[ ! -x "$FILE" ]]; then
    chmod +x "$FILE"
    echo "Permisiune execute adăugată pentru $FILE"
fi
```

**Distractori (linii greșite):**

| Linie greșită | Eroare | Misconceptie vizată |
|---------------|--------|---------------------|
| `if [ ! -x $FILE ]; then` | Lipsesc ghilimelele la variabilă | Word splitting cu spații |
| `if [[ ! -x $FILE ]]` | Lipsește `then` | Sintaxă if incompletă |
| `if [ -x "$FILE" = false ]; then` | Sintaxă complet greșită | Confuzie cu alte limbaje |
| `chmod 777 "$FILE"` | Permisiuni excesive | Nesiguranță - dă acces tuturor |
| `FILE = "$1"` | Spații la atribuire | Eroare clasică Bash |

**Soluție cu explicații:**
```bash
#!/bin/bash
FILE="$1"                        # Primul argument, cu ghilimele
if [[ ! -x "$FILE" ]]; then      # [[ ]] e mai sigur decât [ ]
    chmod +x "$FILE"             # +x adaugă execute
    echo "Permisiune execute adăugată pentru $FILE"
fi                               # Închide if
```

---

### PP-04: Cron job cu logging

**Sarcină:** Aranjează liniile pentru un cron job care rulează zilnic la 3 AM cu logging.

**LO acoperite:** LO5, LO6

**Linii corecte (ordine corectă):**
```bash
# În crontab (crontab -e):
0 3 * * * /home/user/backup.sh >> /var/log/backup.log 2>&1

# Script backup.sh:
#!/bin/bash
set -euo pipefail
echo "[$(date '+\%Y-\%m-\%d \%H:\%M:\%S')] Backup started"
tar -czf /backup/data_$(date +\%Y\%m\%d).tar.gz /home/user/data
echo "[$(date '+\%Y-\%m-\%d \%H:\%M:\%S')] Backup completed"
```

**Distractori (linii greșite):**

| Linie greșită | Eroare | Misconceptie vizată |
|---------------|--------|---------------------|
| `3 0 * * * backup.sh` | Ordinea oră/minut inversată, cale relativă | Confuzie format crontab |
| `0 3 * * * backup.sh > /var/log/backup.log` | Cale relativă, lipsește 2>&1 | PATH minimal în cron |
| `date +%Y-%m-%d` | Lipsește escape `\%` în crontab | % are sens special în cron |
| `0 3 * * 1-5 /home/user/backup.sh` | Rulează doar luni-vineri | Confuzie cu "zilnic" |

**Soluție cu explicații:**
```bash
# Crontab: m h dom mon dow command
0 3 * * * /home/user/backup.sh >> /var/log/backup.log 2>&1
# 0=min, 3=oră, *=orice zi/lună/zi_săpt
# >> = append, 2>&1 = stderr către stdout
# CALEA ABSOLUTĂ e obligatorie!

# În script, % trebuie escaped ca \% în crontab
# Sau pune logica în script și chemă scriptul din cron
```

---

### PP-05: Procesare batch cu verificări

**Sarcină:** Aranjează liniile pentru a procesa toate fișierele `.csv` dintr-un director, verificând că există.

**LO acoperite:** LO1, LO2, LO6, LO7

**Linii corecte (ordine corectă):**
```bash
#!/bin/bash
set -euo pipefail
DIR="${1:-.}"
[[ -d "$DIR" ]] || { echo "Eroare: $DIR nu e director" >&2; exit 1; }
count=$(find "$DIR" -name "*.csv" -type f | wc -l)
if [[ $count -eq 0 ]]; then
    echo "Nu există fișiere .csv în $DIR"
    exit 0
fi
find "$DIR" -name "*.csv" -type f -exec wc -l {} +
```

**Distractori (linii greșite):**

| Linie greșită | Eroare | Misconceptie vizată |
|---------------|--------|---------------------|
| `DIR="$1:-."`  | Lipsesc acoladele la default | Sintaxă parameter expansion |
| `[ -d $DIR ] || exit 1` | Lipsesc ghilimele, mesaj lipsă | Word splitting |
| `if [ $count = 0 ]; then` | `=` pentru string, nu numeric | Comparație numerică vs string |
| `find "$DIR" -name "*.csv" -exec wc -l {} \;` | `\;` în loc de `+` | Ineficiență: un wc per fișier |
| `find $DIR -name *.csv` | Variabilă și pattern fără ghilimele | Erori cu spații și expansion |

**Soluție cu explicații:**
```bash
#!/bin/bash
set -euo pipefail
DIR="${1:-.}"                    # Default la directorul curent
# ${var:-default} = folosește default dacă var e gol/undefined

[[ -d "$DIR" ]] || { echo "Eroare: $DIR nu e director" >&2; exit 1; }
# [[ ]] nu necesită ghilimele, dar e bună practică

count=$(find "$DIR" -name "*.csv" -type f | wc -l)
if [[ $count -eq 0 ]]; then      # -eq pentru comparație numerică
    echo "Nu există fișiere .csv în $DIR"
    exit 0
fi

find "$DIR" -name "*.csv" -type f -exec wc -l {} +
# + grupează fișierele = eficient (un singur wc)
```

---

## 4. Mapping Bloom Taxonomy

### 4.1 Distribuție pe Nivele

| Nivel Bloom | % Țintă | LO-uri | Activități principale |
|-------------|:-------:|--------|----------------------|
| **Remember** | 15% | - | Quiz Q01, Q06, Q09, Q13 |
| **Understand** | 25% | - | Quiz Q02, Q04, Q07, Q10, Q14; Peer Instruction |
| **Apply** | 35% | LO1-LO5 | Live Coding, Sprint Exercises, Parsons PP-01 la PP-05 |
| **Analyse** | 15% | LO6 | Quiz Q11, Q16; Debugging exercises |
| **Evaluate** | 10% | LO7 | Quiz Q17; Comparație metode |

### 4.2 Progresie Cognitivă pe Activități

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  SEMINAR 03: PROGRESIE BLOOM                                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Prezentare     [████████░░]  Remember → Understand                         │
│  Live Coding    [░░████████]  Understand → Apply                            │
│  Sprint Ex.     [░░░░██████]  Apply → Analyse                               │
│  Temă acasă     [░░░░░░████]  Apply → Analyse → Evaluate                    │
│  Parsons        [░░██████░░]  Understand → Apply                            │
│                                                                             │
│  Legendă: █ = acoperire primară                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Referințe

- S03_02_MATERIAL_PRINCIPAL.md — Conținut teoretic detaliat
- S03_03_PEER_INSTRUCTION.md — Întrebări PI-01 la PI-18
- S03_05_LIVE_CODING_GUIDE.md — Sesiuni LC-01 la LC-05
- S03_06_EXERCITII_SPRINT.md — Exerciții practice
- S03_07_LLM_AWARE_EXERCISES.md — Exerciții rezistente la AI
- formative/quiz.yaml — Quiz formativ complet

---

*Document generat conform standardelor pedagogice Brown & Wilson (10 Quick Tips)*  
*Seminarul 03 | Sisteme de Operare | ASE București - CSIE*
