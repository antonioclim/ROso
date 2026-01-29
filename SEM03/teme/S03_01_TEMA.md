# Tema Seminar 3: System Administrator Toolkit
## Sisteme de Operare | ASE București - CSIE

**Versiune**: 1.0 | **Data limită**: [A se completa de instructor]  
**Punctaj total**: 100% + 20 bonus  
**Timp estimat**: 4-6 ore

---

## Cuprins

1. [Obiective și Competențe](#-obiective-și-competențe)
2. [Instrucțiuni de Predare](#-instrucțiuni-de-predare)
3. [Partea 1: Find Master](#partea-1-find-master-20-procente)
4. [Partea 2: Script Profesional](#partea-2-script-profesional-30-procente)
5. [Partea 3: Permission Manager](#partea-3-permission-manager-25-procente)
6. [Partea 4: Cron Jobs](#partea-4-cron-jobs-15-procente)
7. [Partea 5: Integration Challenge](#partea-5-integration-challenge-10-procente)
8. [Bonusuri](#-bonusuri-până-la-20-procente-extra)
9. [Criterii de Evaluare](#-criterii-de-evaluare)
10. [Resurse Permise](#-resurse-permise)

---

## Obiective și Competențe

La finalizarea acestei teme, vei demonstra că poți:

### Nivel APLICARE (Anderson-Bloom)
- ✅ Construi comenzi `find` complexe cu multiple criterii și acțiuni
- ✅ Utiliza `xargs` pentru procesare batch eficientă
- ✅ Scrie scripturi care acceptă argumente și opțiuni folosind `getopts`
- ✅ Calcula și aplica permisiuni în format octal și simbolic
- ✅ Configura `cron jobs` cu logging și error handling

### Nivel ANALIZĂ
- ✅ Diagnostica probleme de permisiuni într-o structură de directoare
- ✅ Identifica riscuri de securitate în configurări de permisiuni
- ✅ Evalua eficiența diferitelor abordări de căutare și procesare

### Nivel CREARE
- ✅ Proiecta scripturi profesionale cu interfață CLI completă
- ✅ Implementa soluții de automatizare solide
- ✅ Integra multiple concepte într-o soluție coerentă

---

## Instrucțiuni de Predare

### Structura Arhivei

Predă o arhivă `tema_sem03_NUME_PRENUME.tar.gz` cu structura:

```
tema_sem03_NUME_PRENUME/
├── README.md                    # Documentație personală
├── parte1_find/
│   └── comenzi_find.sh          # Script cu toate comenzile find
├── parte2_script/
│   ├── fileprocessor.sh         # Scriptul principal
│   └── test_fileprocessor.sh    # Script de testare (opțional)
├── parte3_permissions/
│   ├── permaudit.sh             # Scriptul de audit permisiuni
│   └── raport_demo.txt          # Exemplu de raport generat
├── parte4_cron/
│   ├── cron_entries.txt         # Liniile crontab
│   └── backup_script.sh         # Script de backup referențiat
└── parte5_integration/
    └── sysadmin_toolkit.sh      # Scriptul integrat
```

### Comenzi pentru Creare Arhivă

```bash
# Creează structura
mkdir -p tema_sem03_NUME_PRENUME/{parte1_find,parte2_script,parte3_permissions,parte4_cron,parte5_integration}

# După ce ai completat toate fișierele:
cd ~
tar -czvf tema_sem03_NUME_PRENUME.tar.gz tema_sem03_NUME_PRENUME/

# Verifică conținutul:
tar -tzvf tema_sem03_NUME_PRENUME.tar.gz
```

### Reguli Importante

1. **Toate scripturile** trebuie să fie executabile (`chmod +x`)
2. **Toate scripturile** trebuie să aibă shebang corect (`#!/bin/bash`)
3. **Testează** tot înainte de predare pe Ubuntu 24.04 / WSL2
4. NU include fișiere binare mari sau directoare generate
5. **Comentează** codul pentru claritate

---

## Partea 1: Find Master (20%)

### Cerință

Creează scriptul `comenzi_find.sh` care conține **10 comenzi find** pentru scenariile de mai jos. Fiecare comandă trebuie să fie funcțională și comentată.

### Scenarii

Presupunem că lucrezi în directorul `/home/student/proiect/` care are structura:

```
proiect/
├── src/
│   ├── main.c
│   ├── utils.c
│   ├── utils.h
│   ├── config.h
│   └── deprecated/
│       └── old_main.c
├── docs/
│   ├── README.md
│   ├── manual.pdf
│   ├── notes.txt
│   └── images/
│       ├── logo.png
│       └── diagram.svg
├── build/
│   ├── main.o
│   ├── utils.o
│   └── debug.log
├── tests/
│   ├── test_main.py
│   ├── test_utils.py
│   └── data/
│       ├── input.txt
│       └── expected.txt
├── backup_2024_01.tar.gz
├── backup_2024_02.tar.gz
└── temp_file.tmp
```

### Task-uri Find (2p fiecare)

```bash
#!/bin/bash
# Tema Sem 03 Partea 1: Find Master
# Nume: [COMPLETEAZĂ]
# Grupa: [COMPLETEAZĂ]

# Crează structura de test (rulează o singură dată)
setup_test_structure() {
    mkdir -p ~/proiect/{src/deprecated,docs/images,build,tests/data}
    touch ~/proiect/src/{main.c,utils.c,utils.h,config.h}
    touch ~/proiect/src/deprecated/old_main.c
    touch ~/proiect/docs/{README.md,manual.pdf,notes.txt}
    touch ~/proiect/docs/images/{logo.png,diagram.svg}
    touch ~/proiect/build/{main.o,utils.o,debug.log}
    touch ~/proiect/tests/{test_main.py,test_utils.py}
    touch ~/proiect/tests/data/{input.txt,expected.txt}
    dd if=/dev/zero of=~/proiect/backup_2024_01.tar.gz bs=1M count=5 2>/dev/null
    dd if=/dev/zero of=~/proiect/backup_2024_02.tar.gz bs=1M count=3 2>/dev/null
    touch ~/proiect/temp_file.tmp
    # Setează timestamp-uri diferite
    touch -d "30 days ago" ~/proiect/src/deprecated/old_main.c
    touch -d "7 days ago" ~/proiect/build/debug.log
}

# Task 1: Găsește toate fișierele .c (inclusiv în subdirectoare)
# Rezultat așteptat: main.c, utils.c, old_main.c
task1() {
    echo "=== Task 1: Fișiere .c ==="
    # COMPLETEAZĂ COMANDA FIND
}

# Task 2: Găsește toate fișierele header (.h) doar în src/ (nu în subdirectoare)
# Hint: folosește -maxdepth
task2() {
    echo "=== Task 2: Fișiere .h în src/ ==="
    # COMPLETEAZĂ COMANDA FIND
}

# Task 3: Găsește fișierele mai mari de 1MB
# Rezultat așteptat: backup_*.tar.gz
task3() {
    echo "=== Task 3: Fișiere > 1MB ==="
    # COMPLETEAZĂ COMANDA FIND
}

# Task 4: Găsește fișierele modificate în ultimele 7 zile
# Hint: -mtime -7
task4() {
    echo "=== Task 4: Modificate în ultimele 7 zile ==="
    # COMPLETEAZĂ COMANDA FIND
}

# Task 5: Găsește toate directoarele goale
# Hint: -type d -empty
task5() {
    echo "=== Task 5: Directoare goale ==="
    # COMPLETEAZĂ COMANDA FIND
}

# Task 6: Găsește fișiere .py SAU .c (folosește -o)
task6() {
    echo "=== Task 6: Fișiere .py sau .c ==="
    # COMPLETEAZĂ COMANDA FIND
}

# Task 7: Găsește fișiere temporare (.tmp, .log, .o) și afișează dimensiunea
# Hint: -printf '%s %p\n'
task7() {
    echo "=== Task 7: Fișiere temporare cu dimensiune ==="
    # COMPLETEAZĂ COMANDA FIND
}

# Task 8: Șterge fișierele .o din build/ (cu confirmare -ok)
# Capcană: Testează cu echo înainte de rm!
task8() {
    echo "=== Task 8: Ștergere .o cu confirmare ==="
    # COMPLETEAZĂ COMANDA FIND (folosește -ok pentru siguranță)
}

# Task 9: Folosește xargs pentru a număra liniile din toate fișierele .c
# Hint: find ... | xargs wc -l
task9() {
    echo "=== Task 9: Linii în fișiere .c cu xargs ==="
    # COMPLETEAZĂ COMANDA FIND + XARGS
}

# Task 10: Găsește și arhivează toate fișierele .md în docs.tar.gz
# Hint: find ... -print0 | xargs -0 tar ...
task10() {
    echo "=== Task 10: Arhivare .md cu find + xargs ==="
    # COMPLETEAZĂ COMANDA FIND + XARGS + TAR
}

# Rulează toate task-urile
main() {
    cd ~/proiect || exit 1
    for i in {1..10}; do
        task$i
        echo ""
    done
}

# Decomentează pentru a rula setup (doar prima dată)
# setup_test_structure

# Rulează testele
main
```

### Criterii de Evaluare - Partea 1

| Criteriu | Puncte | Descriere |
|----------|--------|-----------|
| Corectitudine | 10% | Comenzile produc rezultatul corect |
| Sintaxă | 4% | Utilizare corectă a opțiunilor find/xargs |
| Eficiență | 3% | Abordare optimă (ex: -print0 cu xargs -0) |
| Comentarii | 3% | Explicații clare pentru fiecare comandă |

---

## Partea 2: Script Profesional (30%)

### Cerință

Creează scriptul `fileprocessor.sh` - un utilitar profesional pentru procesarea fișierelor în batch.

### Specificații Funcționale

```
UTILIZARE:
    fileprocessor.sh [OPȚIUNI] [FIȘIERE...]

DESCRIERE:
    Procesează fișiere text: numără linii, cuvinte, caractere,
    caută pattern-uri, sau transformă conținutul.

OPȚIUNI:
    -h, --help          Afișează acest mesaj de ajutor
    -v, --verbose       Mod detaliat (afișează progresul)
    -q, --quiet         Mod silențios (doar erori)
    -o, --output FILE   Scrie rezultatul în FILE (default: stdout)
    -m, --mode MODE     Modul de procesare:
                        count   - numără linii/cuvinte/caractere
                        search  - caută pattern
                        upper   - convertește la majuscule
                        lower   - convertește la minuscule
                        stats   - statistici complete
    -p, --pattern PAT   Pattern pentru modul search (obligatoriu dacă mode=search)
    -r, --recursive     Procesează recursiv directoarele
    -e, --extension EXT Filtrează după extensie (ex: .txt)

EXEMPLE:
    fileprocessor.sh -m count file1.txt file2.txt
    fileprocessor.sh -v -m search -p "TODO" -r src/
    fileprocessor.sh -m upper -o output.txt input.txt
    fileprocessor.sh -m stats -e .c src/
```

### Cerințe

> ⚠️ **Avertisment serios**: SUID pe scripturi Bash e o idee FOARTE proastă din punct de vedere al securității. În acest exercițiu îl folosim pentru a înțelege conceptul, dar în producție — NICIODATĂ. Am văzut servere compromise din cauza asta. Tehnice Obligatorii

1. **Parsare argumente** cu `getopts` pentru opțiuni scurte
2. **Suport pentru opțiuni lungi** (manual, nu getopt extern)
3. **Funcție usage()** completă și formatată
4. **Validare argumente**: verifică parametri obligatorii, fișiere existente
5. **Error handling**: mesaje clare, exit codes corecte (0=succes, 1=eroare utilizare, 2=eroare fișier)
6. **Logging** cu nivel configurabil (verbose/normal/quiet)

### Scheletul Scriptului

```bash
#!/bin/bash
#
# fileprocessor.sh - Utilitar profesional pentru procesare fișiere
# Autor: [NUMELE TĂU]
# Versiune: 1.0
# Data: [DATA]
#

set -o nounset  # Eroare pentru variabile nedefinite

#
# CONSTANTE ȘI DEFAULTS
#
readonly VERSION="1.0"
readonly SCRIPT_NAME=$(basename "$0")

# Valori implicite
MODE="count"
VERBOSE=0
QUIET=0
OUTPUT=""
PATTERN=""
RECURSIVE=0
EXTENSION=""

# Exit codes
readonly E_SUCCESS=0
readonly E_USAGE=1
readonly E_FILE=2

#
# FUNCȚII HELPER
#

# Afișează mesaj dacă verbose este activat
log_verbose() {
    [[ $VERBOSE -eq 1 ]] && echo "[INFO] $*" >&2
}

# Afișează eroare și iese
die() {
    [[ $QUIET -eq 0 ]] && echo "[ERROR] $*" >&2
    exit "${E_FILE}"
}

# Afișează warning
warn() {
    [[ $QUIET -eq 0 ]] && echo "[WARN] $*" >&2
}

# Afișează usage
usage() {
    cat << EOF
UTILIZARE:
    $SCRIPT_NAME [OPȚIUNI] [FIȘIERE...]

DESCRIERE:
    [COMPLETEAZĂ DESCRIEREA]

OPȚIUNI:
    -h, --help          [COMPLETEAZĂ]
    [ADAUGĂ TOATE OPȚIUNILE]

EXEMPLE:
    $SCRIPT_NAME -m count file.txt
    [ADAUGĂ MAI MULTE EXEMPLE]

VERSIUNE: $VERSION
EOF
}

#
# FUNCȚII DE PROCESARE
#

# Procesare mod count
process_count() {
    local file="$1"
    # COMPLETEAZĂ: numără linii, cuvinte, caractere
}

# Procesare mod search
process_search() {
    local file="$1"
    local pattern="$2"
    # COMPLETEAZĂ: caută pattern și afișează liniile potrivite
}

# Procesare mod upper/lower
process_transform() {
    local file="$1"
    local transform="$2"  # "upper" sau "lower"
    # COMPLETEAZĂ: modifică conținutul
}

# Procesare mod stats
process_stats() {
    local file="$1"
    # COMPLETEAZĂ: statistici complete (linii, cuvinte, caractere, 
    # linia cea mai lungă, cuvânt cel mai frecvent, etc.)
}

# Procesează un singur fișier
process_file() {
    local file="$1"
    
    # Verifică existența fișierului
    [[ -f "$file" ]] || { warn "Nu este fișier: $file"; return 1; }
    [[ -r "$file" ]] || { warn "Nu pot citi: $file"; return 1; }
    
    log_verbose "Procesez: $file"
    
    case "$MODE" in
        count)  process_count "$file" ;;
        search) process_search "$file" "$PATTERN" ;;
        upper)  process_transform "$file" "upper" ;;
        lower)  process_transform "$file" "lower" ;;
        stats)  process_stats "$file" ;;
        *)      die "Mod necunoscut: $MODE" ;;
    esac
}

#
# PARSARE ARGUMENTE
#

parse_args() {
    # Parsare opțiuni lungi (modifică în scurte)
    local args=()
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --help)      args+=("-h") ;;
            --verbose)   args+=("-v") ;;
            --quiet)     args+=("-q") ;;
            --output)    args+=("-o" "$2"); shift ;;
            --mode)      args+=("-m" "$2"); shift ;;
            --pattern)   args+=("-p" "$2"); shift ;;
            --recursive) args+=("-r") ;;
            --extension) args+=("-e" "$2"); shift ;;
            --)          args+=("--"); shift; break ;;
            *)           args+=("$1") ;;
        esac
        shift
    done
    
    # Adaugă argumentele rămase
    args+=("$@")
    
    # Resetează argumentele
    set -- "${args[@]}"
    
    # Parsare cu getopts
    while getopts ":hvqo:m:p:re:" opt; do
        case $opt in
            h)  usage; exit $E_SUCCESS ;;
            v)  VERBOSE=1 ;;
            q)  QUIET=1 ;;
            o)  OUTPUT="$OPTARG" ;;
            m)  MODE="$OPTARG" ;;
            p)  PATTERN="$OPTARG" ;;
            r)  RECURSIVE=1 ;;
            e)  EXTENSION="$OPTARG" ;;
            :)  die "Opțiunea -$OPTARG necesită un argument" ;;
            \?) die "Opțiune invalidă: -$OPTARG" ;;
        esac
    done
    
    shift $((OPTIND - 1))
    
    # Salvează fișierele rămase
    FILES=("$@")
}

#
# VALIDARE
#

validate_args() {
    # Verifică mod valid
    case "$MODE" in
        count|search|upper|lower|stats) ;;
        *) die "Mod invalid: $MODE. Folosește: count, search, upper, lower, stats" ;;
    esac
    
    # Verifică pattern pentru search
    if [[ "$MODE" == "search" && -z "$PATTERN" ]]; then
        die "Modul search necesită -p/--pattern"
    fi
    
    # Verifică că avem fișiere
    if [[ ${#FILES[@]} -eq 0 ]]; then
        die "Nu ai specificat fișiere de procesat"
    fi
    
    # Verbose și quiet sunt mutual exclusive
    if [[ $VERBOSE -eq 1 && $QUIET -eq 1 ]]; then
        warn "Opțiunile -v și -q sunt mutual exclusive. Folosesc -v."
        QUIET=0
    fi
}

#
# MAIN
#

main() {
    # Parsează argumentele
    parse_args "$@"
    
    # Validează
    validate_args
    
    log_verbose "Mod: $MODE"
    log_verbose "Fișiere: ${FILES[*]}"
    
    # Pregătește output
    local output_cmd="cat"
    [[ -n "$OUTPUT" ]] && output_cmd="tee $OUTPUT"
    
    # Procesează fișierele
    {
        for file in "${FILES[@]}"; do
            if [[ -d "$file" && $RECURSIVE -eq 1 ]]; then
                # Procesare recursivă
                while IFS= read -r -d '' f; do
                    process_file "$f"
                done < <(find "$file" -type f ${EXTENSION:+-name "*$EXTENSION"} -print0)
            else
                process_file "$file"
            fi
        done
    } | $output_cmd
    
    log_verbose "Procesare completă."
    exit $E_SUCCESS
}

# Rulează main cu toate argumentele
main "$@"
```

### Criterii de Evaluare - Partea 2

| Criteriu | Puncte | Descriere |
|----------|--------|-----------|
| Funcție usage() | 4% | Completă, formatată, cu exemple |
| Parsare getopts | 6% | Toate opțiunile scurte funcționează |
| Opțiuni lungi | 4% | --help, --verbose, etc. funcționează |
| Validare | 4% | Verifică parametri, fișiere, dependențe |
| Modurile de procesare | 6% | Toate cele 5 moduri funcționează |
| Error handling | 3% | Mesaje clare, exit codes corecte |
| Logging | 3% | Verbose/quiet funcționează corect |

---

## Partea 3: Permission Manager (25%)

### Cerință

Creează scriptul `permaudit.sh` - un instrument pentru auditarea și corectarea permisiunilor.

### Specificații

```
UTILIZARE:
    permaudit.sh [OPȚIUNI] DIRECTOR

DESCRIERE:
    Analizează permisiunile unui director, identifică probleme
    de securitate și oferă opțiuni de corectare.

OPȚIUNI:
    -h, --help          Afișează ajutor
    -v, --verbose       Afișează toate fișierele, nu doar problemele
    -f, --fix           Corectează automat problemele (cu confirmare)
    -F, --force-fix     Corectează fără confirmare (PERICULOS!)
    -r, --report FILE   Salvează raportul în FILE
    -s, --standard STD  Standard de verificare:
                        strict   - doar owner poate scrie (644/755)
                        normal   - group poate citi (644/755) [default]
                        relaxed  - world readable (644/755)

PROBLEME DETECTATE:
    ⚠️  World-writable files (permisiuni xx7 sau xx6 cu w)
    ⚠️  SUID/SGID pe script-uri (risc de securitate)
    ⚠️  Fișiere executabile care nu ar trebui
    ⚠️  Directoare fără x pentru owner
    ⚠️  Fișiere 777 (permisiuni maxime - PERICULOS)

RAPORT GENERAT:
    - Statistici generale (total fișiere, directoare)
    - Lista problemelor găsite cu severitate
    - Recomandări de corectare
    - Comenzi chmod sugerate
```

### Scheletul Scriptului

```bash
#!/bin/bash
#
# permaudit.sh - Auditor permisiuni cu funcții de corectare
# Autor: [NUMELE TĂU]
#

set -o nounset

#
# CONSTANTE
#

readonly SCRIPT_NAME=$(basename "$0")

# Severitate probleme
readonly SEV_CRITICAL="CRITIC"
readonly SEV_WARNING="WARNING"
readonly SEV_INFO="INFO"

# Culori pentru output
readonly RED='\033[0;31m'
readonly YELLOW='\033[0;33m'
readonly GREEN='\033[0;32m'
readonly NC='\033[0m' # No Color

# Contoare
declare -i total_files=0
declare -i total_dirs=0
declare -i problems_critical=0
declare -i problems_warning=0

#
# FUNCȚII DE ANALIZĂ
#

# Verifică dacă fișierul este world-writable
check_world_writable() {
    local file="$1"
    local perms=$(stat -c "%a" "$file")
    # COMPLETEAZĂ: verifică dacă ultima cifră permite write (2, 3, 6, 7)
}

# Verifică dacă fișierul are SUID/SGID
check_special_bits() {
    local file="$1"
    # COMPLETEAZĂ: verifică biții speciali
}

# Verifică dacă e 777
check_full_permissions() {
    local file="$1"
    # COMPLETEAZĂ: verifică 777
}

# Verifică dacă directorul are x pentru owner
check_dir_access() {
    local dir="$1"
    # COMPLETEAZĂ: verifică x pe director
}

# Analizează un fișier/director
analyze_entry() {
    local entry="$1"
    local issues=()
    
    # COMPLETEAZĂ: rulează toate verificările
    # Adaugă problemele găsite în array-ul issues
    # Afișează cu severitate și culoare corespunzătoare
}

#
# FUNCȚII DE CORECTARE
#

# Sugerează și aplică corecție
fix_permission() {
    local file="$1"
    local suggested_perm="$2"
    local current_perm=$(stat -c "%a" "$file")
    
    echo "Fișier: $file"
    echo "  Actual: $current_perm"
    echo "  Sugerat: $suggested_perm"
    
    if [[ $FORCE_FIX -eq 1 ]]; then
        chmod "$suggested_perm" "$file"
        echo "  ✓ Corectat automat"
    elif [[ $FIX -eq 1 ]]; then
        read -p "  Aplic corecția? [y/N] " response
        if [[ "$response" =~ ^[Yy] ]]; then
            chmod "$suggested_perm" "$file"
            echo "  ✓ Corectat"
        else
            echo "  ✗ Ignorat"
        fi
    else
        echo "  Comandă: chmod $suggested_perm \"$file\""
    fi
}

#
# FUNCȚII DE RAPORT
#

generate_report() {
    cat << EOF
═══════════════════════════════════════════════════════════════════
                    RAPORT AUDIT PERMISIUNI
═══════════════════════════════════════════════════════════════════
Director analizat: $TARGET_DIR
Data: $(date '+%Y-%m-%d %H:%M:%S')
Standard: $STANDARD

STATISTICI:
───────────────────────────────────────────────────────────────────
  Total fișiere:    $total_files
  Total directoare: $total_dirs
  
PROBLEME GĂSITE:
───────────────────────────────────────────────────────────────────
  Critice:   $problems_critical
  Warning:   $problems_warning

EOF

    # COMPLETEAZĂ: adaugă lista detaliată de probleme
}

#
# MAIN
#

# COMPLETEAZĂ:
# 1. Parsare argumente
# 2. Validare director
# 3. Parcurgere recursivă cu find sau while
# 4. Analiză fiecare entry
# 5. Generare raport
# 6. Opțional: corectare probleme

main() {
    # COMPLETEAZĂ
}

main "$@"
```

### Criterii de Evaluare - Partea 3

| Criteriu | Puncte | Descriere |
|----------|--------|-----------|
| Detectare world-writable | 4% | Identifică corect fișiere xx7/xx6 |
| Detectare SUID/SGID | 4% | Identifică biți speciali pe scripturi |
| Detectare 777 | 3% | Flaggează ca critic |
| Raport formatat | 4% | Include statistici, probleme, comenzi |
| Funcție fix | 5% | Corectează cu confirmare |
| Validare input | 3% | Verifică director valid, permisiuni |
| Output colorat | 2% | Severități cu culori diferite |

---

## Partea 4: Cron Jobs (15%)

### Cerință

Creează fișierul `cron_entries.txt` cu **5 cron jobs** funcționale și scriptul `backup_script.sh` referențiat.

### Scenarii pentru Cron Jobs

```bash
# Fișier: cron_entries.txt
# Format: Linia crontab + comentariu explicativ

#
# JOB 1 (3%): Backup zilnic la 3:00 AM
#
# Cerință: Rulează backup_script.sh zilnic la 3 dimineața
# Trebuie să: logheze output-ul în /var/log/backup.log
# COMPLETEAZĂ LINIA CRONTAB:

#
# JOB 2 (3%): Cleanup fișiere temporare
#
# Cerință: La fiecare 6 ore, șterge fișierele .tmp mai vechi de 24h din /tmp
# Capcană: Folosește find cu -mtime, NU rm -rf
# COMPLETEAZĂ LINIA CRONTAB:

#
# JOB 3 (3%): Monitorizare spațiu disk
#
# Cerință: La fiecare 30 minute, verifică spațiul disk
# Dacă orice partiție > 90%, trimite email (sau loghează warning)
# Hint: df -h | awk '...'
# COMPLETEAZĂ LINIA CRONTAB:

#
# JOB 4 (3%): Sincronizare săptămânală
#
# Cerință: În fiecare duminică la 2:00 AM, sincronizează /home/user/docs
# cu /backup/docs folosind rsync
# COMPLETEAZĂ LINIA CRONTAB:

#
# JOB 5 (3%): Rotire log-uri
#
# Cerință: În prima zi a fiecărei luni, la miezul nopții,
# comprimă și arhivează log-urile din /var/log/myapp/
# COMPLETEAZĂ LINIA CRONTAB:

```

### Scriptul de Backup

```bash
#!/bin/bash
# backup_script.sh - Script de backup solid pentru cron
#
# Acest script este referențiat de cron job-ul 1
# Trebuie să:
# 1. Aibă logging complet
# 2. Verifice că nu rulează deja altă instanță (lock file)
# 3. Raporteze erori
# 4. Creeze backup incremental sau complet

# COMPLETEAZĂ IMPLEMENTAREA
```

### Criterii de Evaluare - Partea 4

| Criteriu | Puncte | Descriere |
|----------|--------|-----------|
| Sintaxă corectă | 5% | Toate liniile crontab sunt valide |
| Logging | 3% | Output redirecționat corect (>> log 2>&1) |
| Căi absolute | 3% | Toate comenzile cu cale absolută |
| backup_script.sh | 4% | Funcțional, cu lock file și logging |

---

## Partea 5: Integration Challenge (10%)

### Cerință

Creează `sysadmin_toolkit.sh` - un script care integrează toate conceptele într-un meniu interactiv.

### Specificații

```
SYSADMIN TOOLKIT v1.0
═══════════════════════════════════════════════════════════════════

1) 🔍 Find Operations
   - Căutare fișiere după diverse criterii
   - Cleanup fișiere vechi
   - Statistici disk usage

2) 📄 File Processing
   - Numărare linii/cuvinte în fișiere
   - Căutare pattern în fișiere
   - Transformări text
- Documentează ce ai făcut pentru viitor

3) 🔐 Permission Manager
   - Audit permisiuni director
   - Corectare probleme
   - Setare permisiuni batch

4) ⏰ Cron Helper
   - Listează cron jobs curente
   - Adaugă cron job nou (asistat)
   - Validează expresie cron

5) 📊 System Report
   - Generează raport complet
   - Include toate modulele

0) Exit

Selectează opțiunea [0-5]:
```

### Cerințe

> ⚠️ **Avertisment serios**: SUID pe scripturi Bash e o idee FOARTE proastă din punct de vedere al securității. În acest exercițiu îl folosim pentru a înțelege conceptul, dar în producție — NICIODATĂ. Am văzut servere compromise din cauza asta.

- Meniu interactiv cu `select` sau `case`
- Fiecare opțiune apelează funcții din scripturile anterioare sau le reimplementează
- Include validare input la fiecare pas
- Funcționează fără sudo pentru operațiile normale

### Criterii de Evaluare - Partea 5

| Criteriu | Puncte | Descriere |
|----------|--------|-----------|
| Meniu funcțional | 3% | Navigare corectă, exit funcționează |
| Integrare module | 4% | Apelează funcții din celelalte părți |
| User experience | 3% | Mesaje clare, validare input |

---

## Bonusuri (până la 20% extra)

### Bonus B1: Paralelizare (5%)

Implementează procesare paralelă în `fileprocessor.sh`:

```bash
# Opțiune nouă
-j, --jobs N    Număr de job-uri paralele (default: 1)

# Exemplu utilizare
./fileprocessor.sh -m stats -j 4 *.txt
```

Folosește `xargs -P` sau `parallel` (dacă e disponibil).

### Bonus B2: Opțiuni Lungi Avansate (5%)

Adaugă suport pentru:

Pe scurt: Opțiuni cu `=`: `--output=file.txt`; Opțiuni combinate: `-vro output.txt`; Completare automată (script pentru bash completion).


### Bonus B3: Lock File solid (5%)

Implementează în `backup_script.sh`:
- Lock file cu PID
- Timeout pentru lock
- Cleanup automat la signals (trap)
- Verificare proces zombie

```bash
# Exemplu verificare lock solid
LOCKFILE="/var/run/backup.lock"
LOCK_TIMEOUT=3600  # 1 oră

if [[ -f "$LOCKFILE" ]]; then
    pid=$(cat "$LOCKFILE")
    if kill -0 "$pid" 2>/dev/null; then
        # Proces încă activ - verifică timeout
        # COMPLETEAZĂ
    else
        # Proces mort - cleanup lock
        rm -f "$LOCKFILE"
    fi
fi
```

### Bonus B4: Test Suite (5%)

Creează `test_fileprocessor.sh` cu teste automate:
- Minimum 10 teste
- Verifică toate modurile
- Verifică error handling
- Output pass/fail pentru fiecare test

---

## Criterii de Evaluare

### Rezumat Punctaj

| Parte | Punctaj | Pondere |
|-------|---------|---------|
| Partea 1: Find Master | 20% | 20% |
| Partea 2: Script Profesional | 30% | 30% |
| Partea 3: Permission Manager | 25% | 25% |
| Partea 4: Cron Jobs | 15% | 15% |
| Partea 5: Integration | 10% | 10% |
| **Total** | **100%** | **100%** |
| Bonusuri | +20p | +20% |

### Criterii Generale

| Criteriu | Descriere | Impact |
|----------|-----------|--------|
| Funcționalitate | Scripturile rulează corect | OBLIGATORIU |
| Cod curat | Indentare, comentarii, structură | 10% |
| Error handling | Mesaje clare, exit codes | 10% |
| Documentare | README, usage, comentarii | 10% |
| Securitate | Fără rm -rf /*, verificări | OBLIGATORIU |

### Penalizări

| Problemă | Penalizare |
|----------|------------|
| Nu compilează/rulează | -50% din partea respectivă |
| Lipsă shebang | -5p per script |
| Scripturi neexecutabile | -5p per script |
| Cod copiat fără înțelegere | -100% |
| Utilizare chmod 777 ca soluție | -10p |
| rm -rf fără verificări | -10p |

---

## Resurse Permise

### Documentație
- `man find`, `man xargs`, `man bash`, `man chmod`, `man crontab`
- GNU Coreutils documentation
- Bash Reference Manual
- Materialele de curs și seminar

### Instrumente
- ShellCheck pentru verificare sintaxă: `shellcheck script.sh`
- Explainshell.com pentru înțelegere comenzi
- Crontab.guru pentru validare expresii cron

### NU este permis
- Copierea codului de la colegi
- Utilizarea AI pentru generare completă (poți folosi pentru înțelegere/debugging)
- Scripturi descărcate de pe internet fără adaptare și înțelegere

---

## Suport

### Întrebări frecvente

**Q: Pot folosi alte shell-uri (zsh, fish)?**  
A: Nu, tema trebuie să funcționeze în Bash pe Ubuntu 24.04.

**Q: Trebuie să funcționeze și pe Mac?**  
A: Nu, doar Ubuntu/WSL2.

**Q: Pot adăuga funcționalități extra?**  
A: Da, dar asigură-te că cerințele de bază sunt îndeplinite.

**Q: Ce fac dacă find nu găsește nimic?**  
A: Verifică path-ul și pattern-ul. Testează cu opțiuni mai simple.

### Contact

- Forum curs: [LINK]
- Email instructor: [EMAIL]
- Ore de consultații: [PROGRAM]

---

## Checklist Final

Înainte de predare, verifică:

- [ ] Toate fișierele sunt în structura corectă
- [ ] Toate scripturile au shebang `#!/bin/bash`
- [ ] Toate scripturile sunt executabile (`chmod +x`)
- [ ] Am testat pe Ubuntu 24.04 / WSL2
- [ ] `shellcheck` nu raportează erori majore
- [ ] README.md este completat cu observații personale
- [ ] Arhiva are numele corect: `tema_sem03_NUME_PRENUME.tar.gz`
- [ ] Am verificat conținutul arhivei înainte de trimitere

---

*Tema Seminar 3 | Sisteme de Operare | ASE București - CSIE*
