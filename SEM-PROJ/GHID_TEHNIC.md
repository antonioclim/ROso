# Ghid Tehnic - Dezvoltare Proiecte SO

> **Best Practices și Pattern-uri Recomandate**  
> **Sisteme de Operare** | ASE București - CSIE

---

## Cuprins

1. [Structura Proiectului](#-structura-proiectului)
2. [Convenții de Cod](#-convenții-de-cod)
3. [Pattern-uri Recomandate](#-pattern-uri-recomandate)
4. [Gestionarea Erorilor](#-gestionarea-erorilor)
5. [Logging și Debugging](#-logging-și-debugging)
6. [Testare](#-testare)
7. [Performanță](#-performanță)
8. [Securitate](#-securitate)

---

## Structura Proiectului

### Structură Standard Recomandată

```
proiect/
├── README.md                 # Documentație principală
├── Makefile                  # Automatizare build/test/install
├── .gitignore                # Fișiere ignorate de Git
│
├── src/                      # Cod sursă
│   ├── main.sh               # Entry point principal
│   ├── lib/                  # Biblioteci și module
│   │   ├── utils.sh          # Funcții utilitare
│   │   ├── config.sh         # Gestionare configurație
│   │   ├── logging.sh        # Sistem de logging
│   │   └── validation.sh     # Validare input
│   └── commands/             # Subcomenzi (dacă e CLI)
│       ├── cmd_start.sh
│       ├── cmd_stop.sh
│       └── cmd_status.sh
│
├── etc/                      # Fișiere de configurare
│   ├── config.conf           # Configurare implicită
│   └── config.conf.example   # Exemplu configurare
│
├── tests/                    # Teste automatizate
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
	@echo "Rulare teste..."
	@./tests/run_all_tests.sh

lint:
	@echo "Verificare ShellCheck..."
	@shellcheck -x src/*.sh src/lib/*.sh

install:
	@echo "Instalare $(PROJECT)..."
	@mkdir -p ~/.local/bin
	@cp src/main.sh ~/.local/bin/$(PROJECT)
	@chmod +x ~/.local/bin/$(PROJECT)

clean:
	@echo "Curățare..."
	@rm -rf /tmp/$(PROJECT)_*

help:
	@echo "Comenzi disponibile:"
	@echo "  make test    - Rulează testele"
	@echo "  make lint    - Verifică calitatea codului"
	@echo "  make install - Instalează local"
	@echo "  make clean   - Șterge fișiere temporare"
```

---

## Convenții de Cod

### Header Script Standard

```bash
#!/bin/bash
#===============================================================================
# NUME: script_name.sh
# DESCRIERE: Descriere scurtă a ce face scriptul
# AUTOR: Nume Prenume
# VERSIUNE: 1.0.0
# DATA: 2025-01-20
# LICENȚĂ: Uz educațional - ASE CSIE SO
#===============================================================================

set -euo pipefail
IFS=$'\n\t'

# Constante
readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly VERSION="1.0.0"
```

### Convenții Denumire

```bash
# Variabile locale: snake_case
local user_name="student"
local file_count=0

# Variabile globale/constante: UPPER_SNAKE_CASE
readonly CONFIG_DIR="/etc/myapp"
declare -g VERBOSE=false

# Funcții: snake_case cu prefix descriptiv
log_info() { ... }
validate_input() { ... }
process_file() { ... }

# Arrays: plural
declare -a files=()
declare -A config_options=()
```

### Comentarii

```bash
# Comentariu pe o linie pentru explicații scurte

#---------------------------------------
# Secțiune majoră - cu separator
#---------------------------------------

# Descriere funcție:
# Arguments:
# $1 - Primul argument (obligatoriu)
# $2 - Al doilea argument (opțional, default: "value")
# Returns:
# 0 -
# 1 - eroare validare
# Example:
# process_data "input.txt" "output.txt"
process_data() {
    local input="$1"
    local output="${2:-default.txt}"
    # ... implementare
}
```

---

## Pattern-uri Recomandate

### 1. Pattern: Sourcing Biblioteci

```bash
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Source biblioteci
source "${SCRIPT_DIR}/lib/utils.sh"
source "${SCRIPT_DIR}/lib/logging.sh"
source "${SCRIPT_DIR}/lib/config.sh"

# Verificare că funcțiile există
type log_info &>/dev/null || { echo "Eroare: logging.sh invalid"; exit 1; }
```

### 2. Pattern: Parsare Argumente cu getopts

```bash
usage() {
    cat << EOF
Utilizare: ${SCRIPT_NAME} [OPȚIUNI] <argument>

Opțiuni:
    -h, --help      Afișează acest mesaj
    -v, --verbose   Mod verbose
    -c FILE         Fișier configurare
    -o DIR          Director output

Exemple:
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
            :) echo "Eroare: -${OPTARG} necesită argument"; exit 1 ;;
            \?) echo "Eroare: opțiune invalidă -${OPTARG}"; exit 1 ;;
        esac
    done
    shift $((OPTIND - 1))
    
    # Argumente poziționale rămase
    ARGS=("$@")
}
```

### 3. Pattern: Cleanup la Exit

```bash
# Fișier temporar global
TEMP_DIR=""

cleanup() {
    local exit_code=$?
    
    # Restaurare stare
    if [[ -n "${TEMP_DIR:-}" && -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
        log_debug "Curățat: $TEMP_DIR"
    fi
    
    # Alte acțiuni de cleanup
    
    exit $exit_code
}

# Înregistrare trap la început
trap cleanup EXIT INT TERM

# Creare director temporar
TEMP_DIR="$(mktemp -d)"
```

### 4. Pattern: Lock File (Single Instance)

```bash
LOCK_FILE="/var/run/${SCRIPT_NAME}.lock"

acquire_lock() {
    if [[ -f "$LOCK_FILE" ]]; then
        local pid
        pid=$(cat "$LOCK_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            echo "Eroare: Instanță deja rulează (PID: $pid)"
            exit 1
        fi
        # Proces mort, ștergem lock-ul vechi
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

### 5. Pattern: Configurare din Fișier

```bash
# config.conf:
# KEY=value
# ANOTHER_KEY="value with spaces"

load_config() {
    local config_file="${1:-/etc/myapp/config.conf}"
    
    if [[ ! -f "$config_file" ]]; then
        log_warn "Configurare inexistentă: $config_file"
        return 1
    fi
    
    # Citire sigură (ignoră comentarii și linii goale)
    while IFS='=' read -r key value; do
        # Skip comentarii și linii goale
        [[ "$key" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$key" ]] && continue
        
        # Elimină spații și ghilimele
        key=$(echo "$key" | xargs)
        value=$(echo "$value" | xargs | sed 's/^["'\'']//;s/["'\'']$//')
        
        # Export ca variabilă
        declare -g "CONFIG_${key}=${value}"
    done < "$config_file"
}
```

---

## Gestionarea Erorilor

### Strategii de Handling

```bash
# 1. Exit imediat la eroare (recomandat pentru scripturi simple)
set -e

# 2. Handling manual pentru scripturi complexe
set +e  # Dezactivează exit automat

result=$(some_command 2>&1)
exit_code=$?

if [[ $exit_code -ne 0 ]]; then
    log_error "Comandă eșuată: $result"
    handle_error "$exit_code"
fi

set -e  # Reactivează

# 3. Pattern try-catch simulat
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

# Utilizare:
try risky_operation || catch handle_error
```

### Mesaje de Eroare Descriptive

```bash
die() {
    local message="$1"
    local code="${2:-1}"
    
    echo "EROARE [${SCRIPT_NAME}]: ${message}" >&2
    echo "  Linie: ${BASH_LINENO[0]}" >&2
    echo "  Funcție: ${FUNCNAME[1]:-main}" >&2
    
    exit "$code"
}

# Utilizare:
[[ -f "$file" ]] || die "Fișierul nu există: $file" 2
```

---

## Logging și Debugging

### Sistem de Logging Complet

```bash
# logging.sh

# Niveluri de log
declare -A LOG_LEVELS=([DEBUG]=0 [INFO]=1 [WARN]=2 [ERROR]=3 [FATAL]=4)
LOG_LEVEL="${LOG_LEVEL:-INFO}"
LOG_FILE="${LOG_FILE:-/dev/null}"

log() {
    local level="$1"
    shift
    local message="$*"
    
    # Verifică nivel
    [[ ${LOG_LEVELS[$level]} -lt ${LOG_LEVELS[$LOG_LEVEL]} ]] && return
    
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local color=""
    local reset="\033[0m"
    
    case $level in
        DEBUG) color="\033[36m" ;;  # Cyan
        INFO)  color="\033[32m" ;;  # Verde
        WARN)  color="\033[33m" ;;  # Galben
        ERROR) color="\033[31m" ;;  # Roșu
        FATAL) color="\033[35m" ;;  # Magenta
    esac
    
    # Output la terminal (cu culori)
    printf "${color}[%s] [%-5s] %s${reset}\n" "$timestamp" "$level" "$message" >&2
    
    # Output la fișier (fără culori)
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
# Activare selectivă pentru secțiuni
debug_section() {
    set -x
    # Cod de debugged
    problematic_function
    set +x
}

# Sau cu variabilă de mediu
if [[ "${DEBUG:-false}" == "true" ]]; then
    set -x
fi
```

---

## Testare

### Framework de Teste Simplu

```bash
#!/bin/bash

*Notă personală: Bash-ul are o sintaxă urâtă, recunosc. Dar rulează peste tot, și asta contează enorm în practică.*

# test_utils.sh

source "$(dirname "$0")/../src/lib/utils.sh"

# Contoare
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Funcții assert
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
    assert_true "[[ -f '$file' ]]" "Fișier există: $file"
}

# Raport final
print_summary() {
    echo ""
    echo "════════════════════════════════════"
    echo "SUMAR TESTE"
    echo "────────────────────────────────────"
    echo "Total:   $TESTS_RUN"
    echo "Passed:  $TESTS_PASSED"
    echo "Failed:  $TESTS_FAILED"
    echo "════════════════════════════════════"
    
    [[ $TESTS_FAILED -eq 0 ]] && return 0 || return 1
}

# Exemple teste
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

---

## Performanță

### Optimizări Comune

```bash
# Lent: Subshell pentru fiecare iterație
for file in *.txt; do
    count=$(wc -l < "$file")
    echo "$file: $count"
done

# Rapid: O singură comandă
wc -l *.txt

# Lent: Cat inutil
cat file.txt | grep pattern

*(`grep` e probabil comanda pe care o folosesc cel mai des. Simplu, rapid, eficient.)*


# Rapid: Direct
grep pattern file.txt

# Lent: Buclă pentru citire
while read line; do
    process "$line"
done < file.txt

# Rapid (dacă posibil): Procesare în bloc
awk '{process}' file.txt
```

### Procesare Paralelă

```bash
# Cu xargs
find . -name "*.log" | xargs -P 4 -I {} process_log {}

# Cu GNU Parallel (dacă disponibil)
parallel process_log ::: *.log

# Cu background jobs
for file in *.txt; do
    process_file "$file" &
done
wait  # Așteaptă toate job-urile
```

---

## Securitate

### Validare Input

```bash
validate_path() {
    local path="$1"
    
    # Verifică path traversal
    if [[ "$path" == *".."* ]]; then
        die "Path invalid: conține '..'"
    fi
    
    # Verifică caractere periculoase
    if [[ "$path" =~ [[:cntrl:]] ]]; then
        die "Path invalid: conține caractere de control"
    fi
    
    # Normalizează
    realpath -m "$path"
}

validate_integer() {
    local value="$1"
    local min="${2:-}"
    local max="${3:-}"
    
    if ! [[ "$value" =~ ^-?[0-9]+$ ]]; then
        die "Valoare invalidă: '$value' nu este întreg"
    fi
    
    if [[ -n "$min" && "$value" -lt "$min" ]]; then
        die "Valoare prea mică: $value < $min"
    fi
    
    if [[ -n "$max" && "$value" -gt "$max" ]]; then
        die "Valoare prea mare: $value > $max"
    fi
}
```

### Evitare Injecție

```bash
# Periculos: Expansiune directă
eval "ls $user_input"

# Sigur: Quoting corect
ls "$user_input"

# Periculos: Comandă din input
$user_command

# Sigur: Whitelist de comenzi
case "$user_command" in
    start|stop|status) execute_$user_command ;;
    *) die "Comandă necunoscută" ;;
esac
```

---

## Resurse Adiționale

- **ShellCheck Wiki:** https://github.com/koalaman/shellcheck/wiki
- **Bash Pitfalls:** https://mywiki.wooledge.org/BashPitfalls
- **Google Shell Style Guide:** https://google.github.io/styleguide/shellguide.html
- **Advanced Bash Scripting Guide:** https://tldp.org/LDP/abs/html/

---

*Ghid Tehnic - Proiecte SO | Ianuarie 2025*
