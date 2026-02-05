# Seminar 3 Assignment: System Administrator Toolkit
## Operating Systems | Bucharest UES - CSIE

**Version**: 1.0 | **termen limită**: [To be completed by instructor]  
**Total marks**: 100% + 20 bonus  
**Estimated time**: 4-6 hours

---

## Table of Contents

1. [Objectives and Competencies](#-objectives-and-competencies)
2. [submisie Instructions](#-submisie-instructions)
3. [Part 1: Find Master](#part-1-find-master-20-percent)
4. [Part 2: Professional Script](#part-2-professional-script-30-percent)
5. [Part 3: Permission Manager](#part-3-permission-manager-25-percent)
6. [Part 4: Cron Jobs](#part-4-cron-jobs-15-percent)
7. [Part 5: Integration Challenge](#part-5-integration-challenge-10-percent)
8. [Bonuses](#-bonuses-up-to-20-percent-extra)
9. [evaluare Criteria](#-evaluare-criteria)
10. [Permitted Resources](#-permitted-resources)

---

## Objectives and Competencies

Upon completing this sarcină, you will demonstrate that you can:

### Nivel APLICARE (Anderson-Bloom)
- ✅ Construi comenzi `find` complexe cu multiple criterii și acțiuni
- ✅ Utiliza `xargs` pentru procesare batch eficientă
- ✅ Scrie scripturi care acceptă argumente și opțiuni folosind `getopts`
- ✅ Calcula și aplica permisiuni în format octal și simbolic
- ✅ Configura `cron jobs` cu logging și error handling

### ANALYSIS Level
- ✅ Diagnose permission problems in a directory structure
- ✅ Identify security risks in permission configurations
- ✅ Evaluate the efficiency of different search and processing approaches

### CREATION Level
- ✅ Design professional scripts with a complete CLI interface
- ✅ Implement robust automation solutions
- ✅ Integrate multiple concepts into a coherent soluție

---

## Submission Instructions

### Archive Structure

Submit an arhivă `tema_sem03_SURNAME_FIRSTNAME.tar.gz` with the structure:

```
tema_sem03_SURNAME_FIRSTNAME/
├── README.md                    # Personal documentation
├── parte1_find/
│   └── comenzi_find.sh          # Script with all find commands
├── parte2_script/
│   ├── fileprocessor.sh         # Main script
│   └── test_fileprocessor.sh    # Test script (optional)
├── parte3_permissions/
│   ├── permaudit.sh             # Permission audit script
│   └── raport_demo.txt          # Example generated report
├── parte4_cron/
│   ├── cron_entries.txt         # Crontab lines
│   └── backup_script.sh         # Referenced backup script
└── parte5_integration/
    └── sysadmin_toolkit.sh      # Integrated script
```

### Commands for Creating Archive

```bash
# Creează structura
mkdir -p tema_sem03_NUME_PRENUME/{parte1_find,parte2_script,parte3_permissions,parte4_cron,parte5_integration}

# After completing toate fișierele:
cd ~
tar -czvf tema_sem03_SURNAME_FIRSTNAME.tar.gz tema_sem03_SURNAME_FIRSTNAME/

# Verify contents:
tar -tzvf tema_sem03_SURNAME_FIRSTNAME.tar.gz
```

### Reguli Importante

1. **Toate scripturile** trebuie să fie executabile (`chmod +x`)
2. **Toate scripturile** trebuie să aibă shebang corect (`#!/bin/bash`)
3. **Testează** tot înainte de predare pe Ubuntu 24.04 / WSL2
4. NU include fișiere binare mari sau directoare generate
5. **Comentează** codul pentru claritate

---

## ⚠️ AI-Assistance Policy and Verification

### The Reality

You're going to use ChatGPT or similar tools. I know it. You know it. Let's be adults about this.

**What's allowed:**
- Using AI to explain concepts you don't understand
- Getting syntax reminders ("how does getopts work again?")
- Debugging help ("why does this error appear?")

**What defeats the SCOP:**
- Pasting the entire sarcină and submitting whatever comes back
- Not understanding what your own code does

### Mandatory Development Log

Every script must include a development log in the header. No log = automatic -10%.

```bash
#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# fileprocessor.sh - Assignment Part 2
# Author: [Your Name]
# Student ID: [Your ID]
# 
# DEVELOPMENT LOG:
# 2025-01-28 14:30 - Started with getopts template from lecture
# 2025-01-28 15:45 - Stuck on OPTARG, asked ChatGPT for clarification
# 2025-01-28 16:00 - Realised I needed quotes around $OPTARG
# 2025-01-29 09:00 - Added verbose mode, tested with sample files
# 2025-01-29 10:30 - Fixed bug where -n 0 was accepted (should error)
# ═══════════════════════════════════════════════════════════════
```

This isn't about catching you—it's about proving you actually worked through the problems.

### Live Verification Questions

During lab or oral examination, be prepared to răspuns questions like:

1. **"Explain line X"** — punct to any line in your script, explain what it does
2. **"What if I change..."** — Predict what happens if we modifică one parameter
3. **"Why not use Y?"** — Justify your choice over an alternative approach
4. **"What error would appear if..."** — Demonstrate debugging knowledge

**exemplu questions for this sarcină:**

| Part | întrebare you might be asked |
|------|----------------------------|
| Part 1 | "Your find uses -mtime +7. What changes if we use -mmin instead?" |
| Part 2 | "In your getopts string 'hvo:', what does the colon mean?" |
| Part 3 | "You set permissions 755. What happens to fișierul if we use 754?" |
| Part 4 | "Your cron runs at */15. List the exact times it runs in one hour." |

If you can't răspuns basic questions about your own code, we have a problem.

### Unique Seed Requirement

Your student ID determines your test directory structure. Use the last 3 digits of your student ID as SEED.

```bash
# Exemplu: Student ID 12345678 → SEED=678
SEED=678

# Your find commands in Part 1 must work with:
mkdir -p ~/sem03_test_${SEED}/{logs,data,temp,arhivă}
# ... (setup script will creează test files)
```

Generic solutions that ignore the SEED will be flagged for review.

---

## Partea 1: Find Master (20%)

### Requirement

creează scriptul `comenzi_find.sh` containing **10 find commands** for the scenarios below. Each command trebuie să fie functional and commented.

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

### Find Tasks (2p each)

```bash
#!/bin/bash
# Assignment Sem 03 Part 1: Find Master
# Nume: [COMPLETEAZĂ]
# Grupa: [COMPLETEAZĂ]

# Create test structure (run once only)
setup_test_structure() {
    mkdir -p ~/proiect/{src/deprecated,docs/images,build,tests/data}
    touch ~/proiect/src/{main.c,utils.c,utils.h,config.h}
    touch ~/proiect/src/deprecated/old_main.c
    touch ~/proiect/docs/{README.md,manual.pdf,notes.txt}
    touch ~/proiect/docs/images/{logo.png,diagram.svg}
    touch ~/proiect/build/{main.o,utils.o,debug.log}
    touch ~/proiect/tests/{test_main.py,test_utils.py}
    touch ~/proiect/tests/data/{input.txt,Așteptat.txt}
    dd if=/dev/zero of=~/proiect/backup_2024_01.tar.gz bs=1M count=5 2>/dev/null
    dd if=/dev/zero of=~/proiect/backup_2024_02.tar.gz bs=1M count=3 2>/dev/null
    touch ~/proiect/temp_file.tmp
    # Set different timestamps
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

# Task 3: Find files larger than 1MB
# Așteptat result: backup_*.tar.gz
task3() {
    echo "=== task 3: Files > 1MB ==="
    # COMPLETE THE FIND COMMAND
}

# Task 4: Find files modified in the last 7 days
# Hint: -mtime -7
task4() {
    echo "=== Task 4: Modificate în ultimele 7 zile ==="
    # COMPLETEAZĂ COMANDA FIND
}

# Task 5: Find all gol directories
# Hint: -type d -empty
task5() {
    echo "=== Task 5: Directoare goale ==="
    # COMPLETEAZĂ COMANDA FIND
}

# Task 6: Find .py OR .c files (use -o)
task6() {
    echo "=== task 6: .py or .c files ==="
    # COMPLETE THE FIND COMMAND
}

# Task 7: Găsește fișiere temporare (.tmp, .log, .o) și afișează dimensiunea
# Hint: -printf '%s %p\n'
task7() {
    echo "=== Task 7: Fișiere temporare cu dimensiune ==="
    # COMPLETEAZĂ COMANDA FIND
}

# Task 8: Delete .o files from build/ (with confirmation -ok)
# Trap: Test with echo before rm!
task8() {
    echo "=== task 8: șterge .o with confirmation ==="
    # COMPLETE THE FIND COMMAND (use -ok for safety)
}

# Task 9: Use xargs to count lines in all .c files
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

# Run all tasks
main() {
    cd ~/proiect || exit 1
    for i in {1..10}; do
        task$i
        echo ""
    done
}

# Uncomment pentru a rula setup (first time only)
# setup_test_structure

# Run tests
main
```

### Evaluation Criteria - Part 1

| Criterion | Points | Description |
|-----------|--------|-------------|
| Correctness | 10% | Commands produce the correct result |
| Syntax | 4% | Correct use of find/xargs options |
| Efficiency | 3% | Optimal approach (e.g., -print0 with xargs -0) |
| Comments | 3% | Clear explanations for each command |

---

## Partea 2: Script Profesional (30%)

### Requirement

creează scriptul `fileprocessor.sh` - a professional utility for batch file processing.

### Functional Specifications

```
USAGE:
    fileprocessor.sh [OPTIONS] [FILES...]

DESCRIPTION:
    Processes text files: counts lines, words, characters,
    searches for patterns, or transforms content.

OPTIONS:
    -h, --help          Display this help message
    -v, --verbose       Verbose mode (displays progress)
    -q, --quiet         Quiet mode (errors only)
    -o, --output FILE   Write result to FILE (default: stdout)
    -m, --mode MODE     Processing mode:
                        count   - count lines/words/characters
                        search  - search for pattern
                        upper   - convert to uppercase
                        lower   - convert to lowercase
                        stats   - complete statistics
    -p, --pattern PAT   Pattern for search mode (required if mode=search)
    -r, --recursive     Process directories recursively
    -e, --extension EXT Filter by extension (e.g., .txt)

EXAMPLES:
    fileprocessor.sh -m count file1.txt file2.txt
    fileprocessor.sh -v -m search -p "TODO" -r src/
    fileprocessor.sh -m upper -o output.txt input.txt
    fileprocessor.sh -m stats -e .c src/
```

### Requirements

> ⚠️ **Serious warning**: SUID on Bash scripts is a VERY bad idea from a security standpoint. În acest exercițiu we use it to understand the concept, but in production — NEVER. I've seen servers compromised because of this. Technical Mandatory Requirements

1. **argument parsing** with `getopts` for short options
2. **Support for long options** (manual, not external getopt)
3. **Complete and formatted usage() function**
4. **argument validation**: check mandatory parameters, existing files
5. **Error handling**: clear messages, correct exit codes (0=success, 1=usage error, 2=file error)
6. **Logging** with configurable level (verbose/normal/silențios)

### Script Skeleton

```bash
#!/bin/bash
#
# fileprocessor.sh - Utilitar profesional pentru procesare fișiere
# Author: [YOUR NAME]
# Versiune: 1.0
# Data: [DATA]
#

set -o nounset  # Eroare pentru variabile nedefinite

#
# CONSTANTE ȘI DEFAULTS
#
readonly VERSION="1.0"
readonly SCRIPT_NAME=$(basename "$0")

# Default values
MODE="count"
verbose=0
silențios=0
OUTPUT=""
PATTERN=""
recursiv=0
EXTENSION=""

# Exit codes
readonly E_SUCCESS=0
readonly E_USAGE=1
readonly E_FILE=2

#
# HELPER FUNCTIONS
#

# Display message if verbose is enabled
log_verbose() {
    [[ $verbose -eq 1 ]] && echo "[INFO] $*" >&2
}

# Display error and exit
die() {
    [[ $silențios -eq 0 ]] && echo "[ERROR] $*" >&2
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
# PROCESSING FUNCTIONS
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
# ARGUMENT PARSING
#

parse_args() {
    # Parse long opțiunes (convert to short)
    local args=()
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --help)      args+=("-h") ;;
            --verbose)   args+=("-v") ;;
            --silențios)     args+=("-q") ;;
            --output)    args+=("-o" "$2"); shift ;;
            --mode)      args+=("-m" "$2"); shift ;;
            --pattern)   args+=("-p" "$2"); shift ;;
            --recursiv) args+=("-r") ;;
            --extension) args+=("-e" "$2"); shift ;;
            --)          args+=("--"); shift; break ;;
            *)           args+=("$1") ;;
        esac
        shift
    done
    
    # Add remaining arguments
    args+=("$@")
    
    # Reset arguments
    set -- "${args[@]}"
    
    # Parse with getopts
    while getopts ":hvqo:m:p:re:" opt; do
        case $opt in
            h)  usage; exit $E_SUCCESS ;;
            v)  verbose=1 ;;
            q)  silențios=1 ;;
            o)  OUTPUT="$OPTARG" ;;
            m)  MODE="$OPTARG" ;;
            p)  PATTERN="$OPTARG" ;;
            r)  recursiv=1 ;;
            e)  EXTENSION="$OPTARG" ;;
            :)  die "opțiune -$OPTARG requires an argument" ;;
            \?) die "Invalid opțiune: -$OPTARG" ;;
        esac
    done
    
    shift $((OPTIND - 1))
    
    # Save remaining files
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
    # Parse arguments
    parse_args "$@"
    
    # Validate
    validate_args
    
    log_verbose "Mode: $MODE"
    log_verbose "Files: ${FILES[*]}"
    
    # Prepare output
    local output_cmd="cat"
    [[ -n "$OUTPUT" ]] && output_cmd="tee $OUTPUT"
    
    # Process files
    {
        for file in "${FILES[@]}"; do
            if [[ -d "$file" && $recursiv -eq 1 ]]; then
                # Recursive processing
                while IFS= citește -r -d '' f; do
                    process_file "$f"
                done < <(find "$file" -type f ${EXTENSION:+-name "*$EXTENSION"} -print0)
            else
                process_file "$file"
            fi
        done
    } | $output_cmd
    
    log_verbose "Processing complete."
    exit $E_SUCCESS
}

# Rulează main cu toate argumentele
main "$@"
```

### Evaluation Criteria - Part 2

| Criterion | Points | Description |
|-----------|--------|-------------|
| usage() function | 4% | Complete, formatted, with examples |
| getopts parsing | 6% | All short options work |
| Long options | 4% | --help, --verbose, etc. work |
| Validation | 4% | Checks parameters, files, dependencies |
| Processing modes | 6% | All 5 modes work |
| Error handling | 3% | Clear messages, correct exit codes |
| Logging | 3% | verbose/silențios work correctly |

---

## Partea 3: Permission Manager (25%)

### Requirement

creează scriptul `permaudit.sh` - a tool for auditing and correcting permissions.

### Specifications

```
USAGE:
    permaudit.sh [OPTIONS] DIRECTORY

DESCRIPTION:
    Analyses permissions of a directory, identifies security
    problems and offers correction options.

OPTIONS:
    -h, --help          Display help
    -v, --verbose       Display all files, not just problems
    -f, --fix           Automatically correct problems (with confirmation)
    -F, --force-fix     Correct without confirmation (DANGEROUS!)
    -r, --report FILE   Save report to FILE
    -s, --standard STD  Verification standard:
                        strict   - only owner can write (644/755)
                        normal   - group can read (644/755) [default]
                        relaxed  - world readable (644/755)

PROBLEMS DETECTED:
    ⚠️  World-writable files (permissions xx7 or xx6 with w)
    ⚠️  SUID/SGID on scripts (security risk)
    ⚠️  Executable files that shouldn't be
    ⚠️  Directories without x for owner
    ⚠️  777 files (maximum permissions - DANGEROUS)

GENERATED REPORT:
    - General statistics (total files, directories)
    - List of problems found with severity
    - Correction recommendations
    - Suggested chmod commands
```

### Script Skeleton

```bash
#!/bin/bash
#
# permaudit.sh - Permission auditor with correction functions
# Author: [YOUR NAME]
#

set -o nounset

#
# CONSTANTE
#

readonly SCRIPT_NAME=$(basename "$0")

# Problem severity
readonly SEV_CRITICAL="CRITICAL"
readonly SEV_WARNING="WARNING"
readonly SEV_INFO="INFO"

# Colours for output
readonly RED='\033[0;31m'
readonly YELLOW='\033[0;33m'
readonly GREEN='\033[0;32m'
readonly NC='\033[0m' # No Colour

# Contoare
declare -i total_files=0
declare -i total_dirs=0
declare -i problems_critical=0
declare -i problems_warning=0

#
# ANALYSIS FUNCTIONS
#

# Verifică dacă fișierul este world-writable
check_world_writable() {
    local file="$1"
    local perms=$(stat -c "%a" "$file")
    # COMPLETEAZĂ: verifică dacă ultima cifră permite write (2, 3, 6, 7)
}

# Check if file has SUID/SGID
check_special_bits() {
    local file="$1"
    # COMPLETE: check special bits
}

# Check if it's 777
check_full_permissions() {
    local file="$1"
    # COMPLETE: check 777
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
# CORRECTION FUNCTIONS
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
# REPORT FUNCTIONS
#

generate_report() {
    cat << EOF
═══════════════════════════════════════════════════════════════════
                    PERMISSION AUDIT REPORT
═══════════════════════════════════════════════════════════════════
Analysed directory: $TARGET_DIR
Date: $(date '+%Y-%m-%d %H:%M:%S')
Standard: $STANDARD

STATISTICS:
───────────────────────────────────────────────────────────────────
  Total files:       $total_files
  Total directories: $total_dirs
  
PROBLEMS FOUND:
───────────────────────────────────────────────────────────────────
  Critical:   $problems_critical
  Warning:    $problems_warning

EOF

    # COMPLETE: add detailed list of problems
}

#
# MAIN
#

# COMPLETEAZĂ:
# 1. Parsare argumente
# 2. Validare director
# 3. Recursive traversal with find or while
# 4. Analiză fiecare entry
# 5. Generare raport
# 6. Opțional: corectare probleme

main() {
    # COMPLETEAZĂ
}

main "$@"
```

### Evaluation Criteria - Part 3

| Criterion | Points | Description |
|-----------|--------|-------------|
| Detect world-writable | 4% | Correctly identifies xx7/xx6 files |
| Detect SUID/SGID | 4% | Identifies special bits on scripts |
| Detect 777 | 3% | Flags as critical |
| Formatted report | 4% | Includes statistics, problems, commands |
| Fix function | 5% | Corrects with confirmation |
| Input validation | 3% | Checks valid directory, permissions |
| Coloured output | 2% | Different severities with colours |

---

## Partea 4: Cron Jobs (15%)

### Requirement

creează fișierul `cron_entries.txt` with **5 functional cron jobs** and the referenced `backup_script.sh` script.

### Scenarii pentru Cron Jobs

```bash
# Fișier: cron_entries.txt
# Format: Crontab line + explanatory comment

#
# JOB 1 (3%): Backup zilnic la 3:00 AM
#
# Requirement: Run backup_script.sh daily at 3 in the morning
# Trebuie să: logheze output-ul în /var/log/backup.log
# COMPLETEAZĂ LINIA CRONTAB:

```

# JOB 2 (3%): Cleanup fișiere temporare
#
# Requirement: Every 6 hours, șterge .tmp files older than 24h from /tmp
# Capcană: Folosește find cu -mtime, NU rm -rf
# COMPLETEAZĂ LINIA CRONTAB:

```

# JOB 3 (3%): Disk space monitoring
#
# Requirement: Every 30 minutes, check disk space
# Dacă orice partiție > 90%, trimite email (sau loghează warning)
# Hint: df -h | awk '...'
# COMPLETEAZĂ LINIA CRONTAB:

```

# JOB 4 (3%): Weekly synchronisation
#
# Cerință: În fiecare duminică la 2:00 AM, sincronizează /home/user/docs
# cu /backup/docs folosind rsync
# COMPLETEAZĂ LINIA CRONTAB:

```

# JOB 5 (3%): Rotire log-uri
#
# Requirement: On the first day of each month, at midnight,
# comprimă și arhivează log-urile din /var/log/myapp/
# COMPLETEAZĂ LINIA CRONTAB:

```

### Backup Script

```bash
#!/bin/bash
# backup_script.sh - Script de backup solid pentru cron
#
# Acest script este referențiat de cron job-ul 1
# Must:
# 1. Have complete logging
# 2. Check that another instance is not alciteștey running (lock file)
# 3. Raporteze erori
# 4. Create incremental or full backup

# COMPLETEAZĂ IMPLEMENTAREA
```

### Evaluation Criteria - Part 4

| Criterion | Points | Description |
|-----------|--------|-------------|
| Correct syntax | 5% | All crontab lines are valid |
| Logging | 3% | Output correctly redirected (>> log 2>&1) |
| Absolute paths | 3% | All commands with absolute path |
| backup_script.sh | 4% | Functional, with lock file and logging |

---

## Partea 5: Integration Challenge (10%)

### Requirement

creează `sysadmin_toolkit.sh` - a script that integrates all concepts into an interactiv menu.

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

### Requirements

> ⚠️ **Serious warning**: SUID on Bash scripts is a VERY bad idea from a security standpoint. În acest exercițiu we use it to understand the concept, but in production — NEVER. I've seen servers compromised because of this.

- interactiv menu with `select` or `case`
- Each opțiune calls functions from previous scripts or reimplements them
- Include input validation at each step
- Works without sudo for normal operations

### Evaluation Criteria - Part 5

| Criterion | Points | Description |
|-----------|--------|-------------|
| Functional menu | 3% | Correct navigation, exit works |
| Module integration | 4% | Calls functions from other parts |
| User experience | 3% | Clear messages, input validation |

---

## Bonusuri (până la 20% extra)

### Bonus B1: Paralelizare (5%)

Implementează procesare paralelă în `fileprocessor.sh`:

```bash
# New opțiune
-j, --jobs N    Number of parallel jobs (default: 1)

# Usage exemplu
./fileprocessor.sh -m stats -j 4 *.txt
```

Use `xargs -P` or `parallel` (if available).

### Bonus B2: Advanced Long Options (5%)

Add support for:

In short: Options with `=`: `--output=file.txt`; Combined options: `-vro output.txt`; Automatic completion (script for bash completion).


### Bonus B3: Lock File solid (5%)

Implementează în `backup_script.sh`:
- Lock file cu PID
- Timeout pentru lock
- Cleanup automat la signals (trap)
- Verificare proces zombie

```bash
# Example robust lock verification
LOCKFILE="/var/run/backup.lock"
LOCK_TIMEOUT=3600  # 1 hour

if [[ -f "$LOCKFILE" ]]; then
    pid=$(cat "$LOCKFILE")
    if kill -0 "$pid" 2>/dev/null; then
        # Process still active - check timeout
        # COMPLETE
    else
        # Dead process - cleanup lock
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

## Evaluation Criteria

### Points Summary

| Part | Points | Weight |
|------|--------|--------|
| Part 1: Find Master | 20% | 20% |
| Part 2: Professional Script | 30% | 30% |
| Part 3: Permission Manager | 25% | 25% |
| Part 4: Cron Jobs | 15% | 15% |
| Part 5: Integration | 10% | 10% |
| **Total** | **100%** | **100%** |
| Bonuses | +20p | +20% |

### General Criteria

| Criterion | Description | Impact |
|-----------|-------------|--------|
| Functionality | Scripts run correctly | MANDATORY |
| Clean code | Indentation, comments and structure | 10% |
| Error handling | Clear messages and exit codes | 10% |
| Documentation | README, usage and comments | 10% |
| Security | No rm -rf /* and verifications | MANDATORY |

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

## 🔐 VERIFICATION CHALLENGES (Mandatory - 15% of final notă)

> **Why this section exists**: We want to ensure you UNDERSTAND what you submit
> not just that you can produce working code. These challenges cannot be solved 
> by simply using ChatGPT or copying from colleagues.

### Challenge V1: Screenshot with Timestamp (5%)

**Requirement**: Run your most complex find command (from Part 1) on YOUR system and provide a screenshot showing:

1. The terminal with comanda and output visible
2. Your username in the prompt or output of `whoami`
3. Current date/time (run `date` before your command)

**submisie**: Include `screenshot_v1.png` in your arhivă.

**What we check**:
- Timestamp trebuie să fie within 48 hours of submisie termen limită
- Username must match your submisie name
- Output trebuie să fie consistent with comanda shown

**Note**: If the screenshot appears manipulated or inconsistent you va fi asked to reproduce comanda live during lab hours.

---

### Challenge V2: Debugging Preparation (5%)

**Requirement**: In your README.md include a section titled "Debugging Notes" with:

1. **Three errors you encountered** whilst developing your scripts
   - What was the mesaj de eroare?
   - What caused it?
   - How did you fix it?

2. **Two things you learnt** that were not obvious from the seminar materials
   - exemplu: "I discovered that xargs -I {} does not work with -P for parallel execution"

**Format**:
```markdown
## Debugging Notes

### Error 1: [Brief description]
- **mesaj de eroare**: `[exact error text]`
- **Cause**: [your explicație]
- **Fix**: [what you changed]

### Error 2: ...

### Lessons Learnt
1. [First insight]
2. [Second insight]
```

**What we check**:
- Errors must be SPECIFIC to your code (not generic examples)
- Lessons must demonstrate understanding beyond copy-paste

---

### Challenge V3: Oral Verification Readiness (5%)

**Requirement**: Be prepared to explain ANY line of your submitted code during lab hours.

**How it works**:
1. During the next lab session you may be randomly selected
2. You va fi asked to explain 3-5 lines from your own submisie
3. You must explain WITHOUT looking at documentation or notes

**exemplu questions**:
- "Your script has `shift $((OPTIND - 1))`. What does this do and why is it needed?"
- "Why did you use `-print0` instead of `-print` in this find command?"
- "What happens if someone runs your script with an invalid permission like `999`?"

**Scoring**:
- Clear and correct explicație: Full marks
- Partially correct: Partial marks
- Cannot explain own code: 0 marks + investigation for academic integrity

---

### Important Notes on Verification

> ⚠️ **AI Usage Policy**
> 
> You MAY use AI tools (ChatGPT, Claude and Copilot) for:
> - Understanding error messages
> - Learning syntax
> - Debugging suggestions
> 
> You MAY NOT use AI tools for:
> - Generating complete solutions
> - Writing code you do not understand
> - Circumventing the verification challenges
> 
> **"I got it from ChatGPT" is not an acceptable explicație** during oral verification.
> If you used AI assistance you must understand the code well enough to explain it yourself.

---

## Permitted Resources

### Documentație
- `man find`, `man xargs`, `man bash`, `man chmod`, `man crontab`
- GNU Coreutils documentation
- Bash Reference Manual
- Materialele de curs și seminar

### Tools
- ShellCheck for syntax checking: `shellcheck script.sh`
- Explainshell.com for understanding commands
- crontab.guru for validating cron expressions

### NOT permitted
- Copying code from colleagues
- Using AI for complete generation (you can use it for understanding/debugging)
- Scripts downloaded from the internet without adaptation and understanding

---

## Suport

### Frequently Asked Questions

**Q: Can I use other shells (zsh, fish)?**  
A: No, the sarcină must work in Bash on Ubuntu 24.04.

**Q: Does it need to work on Mac too?**  
A: No, only Ubuntu/WSL2.

**Q: Can I add extra functionality?**  
A: Yes, but ensure the basic requirements are met.

**Q: What do I do if find doesn't find anything?**  
A: Check the path and pattern. Test with simpler options.

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
