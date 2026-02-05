# Ghid Tehnic - Dezvoltare Proiecte SO

> **Best Practices și Modele Recomandate**  
> **Sisteme de Operare** | ASE București - CSIE

---

## Cuprins

1. [Structură Proiect](#structură-proiect)
2. [Convenții de Cod](#convenții-de-cod)
3. [Modele Recomandate](#modele-recomandate)
4. [Gestionare Erori](#gestionare-erori)
5. [Logging și Debugging](#logging-și-debugging)
6. [Testare](#testare)
7. [Performanță](#performanță)
8. [Securitate](#securitate)
9. [Povești de Război](#povești-de-război)

---

## Structură Proiect

### Structură Standard Recomandată

```
project/
├── README.md                 # Documentație principală
├── Makefile                  # Automatizare build/test/install
├── .gitignore                # Fișiere ignorate de Git
│
├── src/                      # Cod sursă
│   ├── main.sh               # Punct de intrare principal
│   ├── lib/                  # Librării și module
│   │   ├── utils.sh          # Funcții utilitare
│   │   ├── config.sh         # Gestionare configurație
│   │   ├── logging.sh        # Sistem de logging
│   │   └── validation.sh     # Validare input
│   └── commands/             # Subcomenzi (dacă CLI)
│       ├── cmd_start.sh
│       ├── cmd_stop.sh
│       └── cmd_status.sh
│
├── etc/                      # Fișiere de configurare
│   ├── config.conf           # Configurare implicită
│   └── config.conf.example   # Exemplu de configurare
│
├── tests/                    # Teste automate
│   ├── test_utils.sh
│   ├── test_main.sh
│   └── run_all_tests.sh
│
├── docs/                     # Documentație extinsă
│   ├── INSTALL.md
│   ├── USAGE.md
│   └── ARCHITECTURE.md
│
└── examples/                 # Exemple de utilizare
    ├── example_basic.sh
    └── example_advanced.sh
```

### Makefile Standard

```makefile
.PHONY: all test lint install clean help

SHELL := /bin/bash
PROJECT := $(shell basename $(CURDIR))

all: lint test

test:
	@echo "Running tests···"
	@./tests/run_all_tests.sh

lint:
	@echo "ShellCheck verification···"
	@shellcheck -x src/*.sh src/lib/*.sh

install:
	@echo "Installing $(PROJECT)···"
	@mkdir -p ~/.local/bin
	@cp src/main.sh ~/.local/bin/$(PROJECT)
	@chmod +x ~/.local/bin/$(PROJECT)

clean:
	@echo "Cleaning···"
	@rm -rf /tmp/$(PROJECT)_*

help:
	@echo "Available commands:"
	@echo "  make test    - Run tests"
	@echo "  make lint    - Check code quality"
	@echo "  make install - Install locally"
	@echo "  make clean   - Delete temporary files"
```

---

## Convenții de Cod

### Header Standard Script

```bash
#!/bin/bash
#===============================================================================
# NAME: script_name.sh
# DESCRIPTION: Short description of what the script does
# AUTHOR: Name Surname
# VERSION: 1.0.0
# DATE: 2025-01-20
# LICENCE: Educational use - ASE CSIE OS
#===============================================================================

set -euo pipefail
IFS=$'\n\t'

# Constants
readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly VERSION="1.0.0"
```

### Convenții de Denumire

```bash
# Local variables: snake_case
local user_name="student"
local file_count=0

# Global variables/constants: UPPER_SNAKE_CASE
readonly CONFIG_DIR="/etc/myapp"
declare -g VERBOSE=false

# Functions: snake_case with descriptive prefix
log_info() { ··· }
validate_input() { ··· }
process_file() { ··· }

# Arrays: plural
declare -a files=()
declare -A config_options=()
```

### Comentarii

```bash
# Single line comment for short explanations

#---------------------------------------
# Major section - with separator
#---------------------------------------

# Function description:
# Arguments:
# $1 - First argument (mandatory)
# $2 - Second argument (optional, default: "value")
# Returns:
# 0 - success
# 1 - validation error
# Example:
# process_data "input.txt" "output.txt"
process_data() {
    local input="$1"
    local output="${2:-default.txt}"
    # ··· implementation
}
```

---

## Modele Recomandate

### 1. Model: Încărcare Librării

```bash
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Source libraries
source "${SCRIPT_DIR}/lib/utils.sh"
source "${SCRIPT_DIR}/lib/logging.sh"
source "${SCRIPT_DIR}/lib/config.sh"

# Verify that functions exist
type log_info &>/dev/null || { echo "Error: logging.sh invalid"; exit 1; }
```

### 2. Model: Parsare Argumente cu getopts

```bash
usage() {
    cat << EOF
Usage: ${SCRIPT_NAME} [OPTIONS] <argument>

Options:
    -h, --help      Display this message
    -v, --verbose   Verbose mode
    -c FILE         Configuration file
    -o DIR          Output directory

Examples:
    ${SCRIPT_NAME} -v input.txt
    ${SCRIPT_NAME} -c config.conf -o /tmp/output
EOF
}

parse_args() {
    while getopts ":hvc:o:" opt; do
        case ${opt} in
            h) usage; exit 0 ;;
            v) VERBOSE=true ;;
            c) CONFIG_FILE="$OPTARG" ;;
            o) OUTPUT_DIR="$OPTARG" ;;
            :) echo "Error: -${OPTARG} requires argument"; exit 1 ;;
            \?) echo "Error: invalid option -${OPTARG}"; exit 1 ;;
        esac
    done
    shift $((OPTIND - 1))
    
    # Remaining positional arguments
    ARGS=("$@")
}
```

### 3. Model: Curățare la Ieșire

```bash
# Global temporary file
TEMP_DIR=""

cleanup() {
    local exit_code=$?
    
    # Restore state
    if [[ -n "${TEMP_DIR:-}" && -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
        log_debug "Cleaned: $TEMP_DIR"
    fi
    
    # Other cleanup actions
    
    exit $exit_code
}

# Register trap at the beginning
trap cleanup EXIT INT TERM

# Create temporary directory
TEMP_DIR="$(mktemp -d)"
```

### 4. Model: Fișier Lock (Instanță Unică)

```bash
LOCK_FILE="/var/run/${SCRIPT_NAME}.lock"

acquire_lock() {
    if [[ -f "$LOCK_FILE" ]]; then
        local pid
        pid=$(cat "$LOCK_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            echo "Error: Instance already running (PID: $pid)"
            exit 1
        fi
        # Dead process, remove old lock
        rm -f "$LOCK_FILE"
    fi
    
    echo $$ > "$LOCK_FILE"
}

release_lock() {
    rm -f "$LOCK_FILE"
}

trap release_lock EXIT
acquire_lock
```

### 5. Model: Configurare din Fișier

```bash
# config.conf:
# KEY=value
# ANOTHER_KEY="value with spaces"

load_config() {
    local config_file="${1:-/etc/myapp/config.conf}"
    
    if [[ ! -f "$config_file" ]]; then
        log_warn "Configuration missing: $config_file"
        return 1
    fi
    
    # Safe reading (ignores comments and empty lines)
    while IFS='=' read -r key value; do
        # Skip comments and empty lines
        [[ "$key" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$key" ]] && continue
        
        # Remove whitespace and quotes
        key=$(echo "$key" | xargs)
        value=$(echo "$value" | xargs | sed 's/^["'\'']//;s/["'\'']$//')
        
        # Export as variable
        declare -g "CONFIG_${key}=${value}"
    done < "$config_file"
}
```

---

## Gestionare Erori

### Strategii de Gestionare

```bash
# 1. Immediate exit on error (recommended for simple scripts)
set -e

# 2. Manual handling for complex scripts
set +e  # Disable automatic exit

result=$(some_command 2>&1)
exit_code=$?

if [[ $exit_code -ne 0 ]]; then
    log_error "Command failed: $result"
    handle_error "$exit_code"
fi

set -e  # Reactivate

# 3. Simulated try-catch pattern
try() {
    "$@"
}

catch() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        "$@"
    fi
    return $exit_code
}

# Usage:
try risky_operation || catch handle_error
```

### Mesaje de Eroare Descriptive

```bash
die() {
    local message="$1"
    local code="${2:-1}"
    
    echo "ERROR [${SCRIPT_NAME}]: ${message}" >&2
    echo "  Line: ${BASH_LINENO[0]}" >&2
    echo "  Function: ${FUNCNAME[1]:-main}" >&2
    
    exit "$code"
}

# Usage:
[[ -f "$file" ]] || die "File does not exist: $file" 2
```

---

## Logging și Debugging

### Sistem Complet de Logging

```bash
# logging.sh

# Log levels
declare -A LOG_LEVELS=([DEBUG]=0 [INFO]=1 [WARN]=2 [ERROR]=3 [FATAL]=4)
LOG_LEVEL="${LOG_LEVEL:-INFO}"
LOG_FILE="${LOG_FILE:-/dev/null}"

log() {
    local level="$1"
    shift
    local message="$*"
    
    # Check level
    [[ ${LOG_LEVELS[$level]} -lt ${LOG_LEVELS[$LOG_LEVEL]} ]] && return
    
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local colour=""
    local reset="\033[0m"
    
    case $level in
        DEBUG) colour="\033[36m" ;;  # Cyan
        INFO)  colour="\033[32m" ;;  # Green
        WARN)  colour="\033[33m" ;;  # Yellow
        ERROR) colour="\033[31m" ;;  # Red
        FATAL) colour="\033[35m" ;;  # Magenta
    esac
    
    # Output to terminal (with colours)
    printf "${colour}[%s] [%-5s] %s${reset}\n" "$timestamp" "$level" "$message" >&2
    
    # Output to file (without colours)
    if [[ "$LOG_FILE" != "/dev/null" ]]; then
        printf "[%s] [%-5s] %s\n" "$timestamp" "$level" "$message" >> "$LOG_FILE"
    fi
}

log_debug() { log DEBUG "$@"; }
log_info()  { log INFO "$@"; }
log_warn()  { log WARN "$@"; }
log_error() { log ERROR "$@"; }
log_fatal() { log FATAL "$@"; exit 1; }
```

### Debugging cu set -x

```bash
# Selective activation for sections
debug_section() {
    set -x
    # Debugged code
    problematic_function
    set +x
}

# Or with environment variable
if [[ "${DEBUG:-false}" == "true" ]]; then
    set -x
fi
```

---

## Testare

### Framework Simplu de Testare

```bash
#!/bin/bash
# test_utils.sh

source "$(dirname "$0")/../src/lib/utils.sh"

# Counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Assert functions
assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-}"
    
    ((TESTS_RUN++))
    
    if [[ "$expected" == "$actual" ]]; then
        echo "✅ PASS: $message"
        ((TESTS_PASSED++))
    else
        echo "❌ FAIL: $message"
        echo "   Expected: '$expected'"
        echo "   Actual:   '$actual'"
        ((TESTS_FAILED++))
    fi
}

assert_true() {
    local condition="$1"
    local message="${2:-}"
    
    ((TESTS_RUN++))
    
    if eval "$condition"; then
        echo "✅ PASS: $message"
        ((TESTS_PASSED++))
    else
        echo "❌ FAIL: $message (condition: $condition)"
        ((TESTS_FAILED++))
    fi
}

assert_file_exists() {
    local file="$1"
    assert_true "[[ -f '$file' ]]" "File exists: $file"
}

# Final report
print_summary() {
    echo ""
    echo "════════════════════════════════════"
    echo "TEST SUMMARY"
    echo "────────────────────────────────────"
    echo "Total:   $TESTS_RUN"
    echo "Passed:  $TESTS_PASSED"
    echo "Failed:  $TESTS_FAILED"
    echo "════════════════════════════════════"
    
    [[ $TESTS_FAILED -eq 0 ]] && return 0 || return 1
}

# Test examples
test_string_functions() {
    echo "=== Test: String Functions ==="
    
    result=$(trim "  hello  ")
    assert_equals "hello" "$result" "trim whitespace"
    
    result=$(to_upper "hello")
    assert_equals "HELLO" "$result" "to uppercase"
}

# Main
test_string_functions
print_summary
```

> 💡 *Notă personală: Bash are sintaxă urâtă, recunosc. Dar rulează peste tot și asta contează enorm în practică.*

---

## Performanță

### Optimizări Comune

```bash
# Slow: Subshell for each iteration
for file in *.txt; do
    count=$(wc -l < "$file")
    echo "$file: $count"
done

# Fast: Single command
wc -l *.txt

# Slow: Useless cat
cat file.txt | grep pattern

# Fast: Direct
grep pattern file.txt

# Slow: Loop for reading
while read line; do
    process "$line"
done < file.txt

# Fast (if possible): Block processing
awk '{process}' file.txt
```

> 💡 *`grep` este probabil comanda pe care o folosesc cel mai des. Simplă, rapidă, eficientă.*

### Procesare Paralelă

```bash
# With xargs
find . -name "*.log" | xargs -P 4 -I {} process_log {}

# With GNU Parallel (if available)
parallel process_log ::: *.log

# With background jobs
for file in *.txt; do
    process_file "$file" &
done
wait  # Wait for all jobs
```

---

## Securitate

### Validare Input

```bash
validate_path() {
    local path="$1"
    
    # Check path traversal
    if [[ "$path" == *".."* ]]; then
        die "Invalid path: contains '..'"
    fi
    
    # Check dangerous characters
    if [[ "$path" =~ [[:cntrl:]] ]]; then
        die "Invalid path: contains control characters"
    fi
    
    # Normalise
    realpath -m "$path"
}

validate_integer() {
    local value="$1"
    local min="${2:-}"
    local max="${3:-}"
    
    if ! [[ "$value" =~ ^-?[0-9]+$ ]]; then
        die "Invalid value: '$value' is not an integer"
    fi
    
    if [[ -n "$min" && "$value" -lt "$min" ]]; then
        die "Value too small: $value < $min"
    fi
    
    if [[ -n "$max" && "$value" -gt "$max" ]]; then
        die "Value too large: $value > $max"
    fi
}
```

### Evitare Injecții

```bash
# Dangerous: Direct expansion
eval "ls $user_input"

# Safe: Correct quoting
ls "$user_input"

# Dangerous: Command from input
$user_command

# Safe: Command whitelist
case "$user_command" in
    start|stop|status) execute_$user_command ;;
    *) die "Unknown command" ;;
esac
```

---

## Povești de Război

> A învăța din greșelile altora este mai ieftin decât să le faci tu însuți.

### Bucla Infinită (2023)

Script-ul de backup al unui student rula `find / -name "*.sh"` fără excludere `/proc`. Script-ul a rulat 3 ore și în cele din urmă a blocat VM-ul.

**Lecție:** Excludeți întotdeauna sistemele de fișiere virtuale:
```bash
find / -name "*.sh" -not -path "/proc/*" -not -path "/sys/*"
```

### Dezastrul Permisiunilor (2022)

Cineva a rulat `chmod -R 777 /` în loc de `chmod -R 777 ./`. A trebuit să reinstaleze Ubuntu.

**Lecție:** Testați ÎNTOTDEAUNA comenzile destructive cu `echo` mai întâi:
```bash
# SIGUR: previzualizare ce s-ar întâmpla
echo chmod -R 777 ./target

# DOAR după verificare:
chmod -R 777 ./target
```

### Catastrofa Git (2024)

Un student și-a commit-uit fișierul `.env` cu parola serverului într-un repository public. Parola a fost recolectată în câteva ore.

**Lecție:** Aveți întotdeauna un `.gitignore` corespunzător ÎNAINTE de primul commit:
```bash
# First thing in any project
echo -e ".env\n*.secret\n*.key" > .gitignore
git add .gitignore
git commit -m "Add gitignore"
```

### Bomba Fork (2021)

Un student a creat accidental o bombă fork în timpul testării gestionării proceselor:
```bash
:(){ :|:& };:  # DO NOT RUN THIS
```
Serverul de laborator s-a blocat și a afectat alți 30 de studenți.

**Lecție:** Testați codul intensiv în procese în containere sau VM-uri izolate, niciodată pe sisteme partajate.

### Predarea de la Miezul Nopții (În Fiecare Semestru)

La 23:58, cu două minute înainte de deadline, sistemul de upload era supraîncărcat. Trei studenți nu au reușit să predea la timp.

**Lecție:** Predați cu cel puțin 2 ore înainte de deadline. Puteți întotdeauna să retrimiteți.

---

## Resurse Suplimentare

- **ShellCheck Wiki:** https://github.com/koalaman/shellcheck/wiki
- **Bash Pitfalls:** https://mywiki.wooledge.org/BashPitfalls
- **Google Shell Style Guide:** https://google.github.io/styleguide/shellguide.html
- **Advanced Bash Scripting Guide:** https://tldp.org/LDP/abs/html/

---

*Ghid Tehnic - Proiecte SO | Ianuarie 2025*
