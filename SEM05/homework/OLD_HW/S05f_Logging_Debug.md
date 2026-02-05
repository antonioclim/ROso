# S05_TC05 - Logging și Debugging în Bash

> **Sisteme de Operare** | ASE București - CSIE  
> Material de laborator - Seminar 5 (NOU - Redistribuit)

---

> 🚨 **ÎNAINTE DE A ÎNCEPE TEMA**
>
> 1. Descarcă și configurează pachetul `002HWinit` (vezi GHID_STUDENT_RO.md)
> 2. Deschide un terminal și navighează în `~/HOMEWORKS`
> 3. Pornește înregistrarea cu:
>    ```bash
>    python3 record_homework_tui_RO.py
>    ```
>    sau varianta Bash:
>    ```bash
>    ./record_homework_RO.sh
>    ```
> 4. Completează datele cerute (nume, grupă, nr. temă)
> 5. **ABIA APOI** începe să rezolvi cerințele de mai jos

---

## Obiective

La finalul acestui laborator, studentul va fi capabil să:
- Implementeze un sistem de logging profesional
- Folosească nivele de log (DEBUG, INFO, WARN, ERROR)
- Aplice tehnici de debugging pentru scripturi
- Configureze output pentru producție vs dezvoltare

---


## 2. Nivele de Logging

### 2.1 Sistem cu Nivele

```bash
#!/bin/bash

# Nivele de log (mai mare = mai important)
declare -A LOG_LEVELS=(
    [DEBUG]=0
    [INFO]=1
    [WARN]=2
    [ERROR]=3
    [FATAL]=4
)

# Nivel curent (default INFO)
LOG_LEVEL="${LOG_LEVEL:-INFO}"
LOG_FILE="${LOG_FILE:-/dev/null}"

# Funcție generică de log
_log() {
    local level="$1"
    shift
    local message="$*"
    
    # Verifică dacă trebuie afișat
    local current_level="${LOG_LEVELS[$LOG_LEVEL]}"
    local msg_level="${LOG_LEVELS[$level]}"
    
    if (( msg_level >= current_level )); then
        local timestamp
        timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        local output="[$timestamp] [$level] $message"
        
        # stderr pentru WARN+ , stdout pentru INFO/DEBUG
        if (( msg_level >= 2 )); then
            echo "$output" >&2
        else
            echo "$output"
        fi
        
        # Log în fișier
        echo "$output" >> "$LOG_FILE"
    fi
}

# Funcții helper pentru fiecare nivel
log_debug() { _log DEBUG "$@"; }
log_info()  { _log INFO "$@"; }
log_warn()  { _log WARN "$@"; }
log_error() { _log ERROR "$@"; }
log_fatal() { _log FATAL "$@"; exit 1; }
```

### 2.2 Utilizare

```bash
#!/bin/bash
source logging.sh

LOG_LEVEL=DEBUG
LOG_FILE="/var/log/myapp.log"

log_debug "Entering function process_data()"
log_info "Processing file: $filename"
log_warn "File size exceeds recommended limit"
log_error "Failed to parse line 42"
log_fatal "Cannot connect to database"  # Iese din script
```

### 2.3 Culori pentru Terminal

```bash
#!/bin/bash

# Culori ANSI
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
GRAY='\033[0;90m'
NC='\033[0m'  # No Color

# Verifică dacă output e terminal
if [[ -t 1 ]]; then
    USE_COLOR=true
else
    USE_COLOR=false
fi

_log_color() {
    local level="$1"
    local color="$2"
    shift 2
    
    local timestamp
    timestamp=$(date '+%H:%M:%S')
    
    if [[ "$USE_COLOR" == true ]]; then
        printf "${GRAY}[%s]${NC} ${color}[%-5s]${NC} %s\n" "$timestamp" "$level" "$*"
    else
        printf "[%s] [%-5s] %s\n" "$timestamp" "$level" "$*"
    fi
}

log_debug() { _log_color DEBUG "$GRAY" "$@"; }
log_info()  { _log_color INFO "$GREEN" "$@"; }
log_warn()  { _log_color WARN "$YELLOW" "$@" >&2; }
log_error() { _log_color ERROR "$RED" "$@" >&2; }
```

---

## 3. Logging Avansat

### 3.1 Context și Caller Info

```bash
#!/bin/bash

log_with_context() {
    local level="$1"
    shift
    
    local func="${FUNCNAME[1]:-main}"
    local line="${BASH_LINENO[0]}"
    local file="${BASH_SOURCE[1]##*/}"
    
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    printf "[%s] [%s] %s:%s in %s(): %s\n" \
        "$timestamp" "$level" "$file" "$line" "$func" "$*"
}

# Test
my_function() {
    log_with_context INFO "Processing item"
}

my_function
# Output: [2025-01-27 15:30:45] [INFO] script.sh:15 in my_function(): Processing item
```

### 3.2 Rotație Simplă a Log-urilor

```bash
#!/bin/bash

LOG_FILE="/var/log/myapp.log"
MAX_SIZE=$((10 * 1024 * 1024))  # 10MB
MAX_FILES=5

rotate_logs() {
    [[ -f "$LOG_FILE" ]] || return
    
    local size
    size=$(stat -c%s "$LOG_FILE" 2>/dev/null || echo 0)
    
    if (( size > MAX_SIZE )); then
        for ((i=MAX_FILES-1; i>=1; i--)); do
            [[ -f "${LOG_FILE}.$i" ]] && mv "${LOG_FILE}.$i" "${LOG_FILE}.$((i+1))"
        done
        mv "$LOG_FILE" "${LOG_FILE}.1"
        touch "$LOG_FILE"
        log_info "Log rotated"
    fi
}

# Apelează periodic
rotate_logs
```

### 3.3 Structured Logging (JSON)

```bash
#!/bin/bash

log_json() {
    local level="$1"
    shift
    local message="$*"
    
    local timestamp
    timestamp=$(date -Iseconds)
    
    printf '{"timestamp":"%s","level":"%s","message":"%s","pid":%d}\n' \
        "$timestamp" "$level" "$message" "$$"
}

log_json INFO "Application started"
log_json ERROR "Connection failed"

# Output:
# {"timestamp":"2025-01-27T15:30:45+00:00","level":"INFO","message":"Application started","pid":12345}
```

---

## 4. Tehnici de Debugging

### 4.1 `set -x` - Trace Mode

```bash
#!/bin/bash

# Activează trace pentru tot scriptul
set -x

# Sau doar pentru o secțiune
set -x
# ... cod de debugat
set +x
```

### 4.2 PS4 Customizat

```bash
#!/bin/bash

# PS4 controlează prefixul liniilor în trace mode
# Default: "+ "

# Cu informații utile
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

set -x
echo "test"
# Output: +(script.sh:8): main(): echo test
```

### 4.3 Debug Condițional

```bash
#!/bin/bash

DEBUG="${DEBUG:-false}"

debug() {
    if [[ "$DEBUG" == true ]]; then
        echo "[DEBUG] $*" >&2
    fi
}

debug "Variable x = $x"
debug "Entering loop"

# Rulare: DEBUG=true ./script.sh
```

### 4.4 Trap DEBUG

```bash
#!/bin/bash

# Execută cod înainte de FIECARE comandă
trap 'echo "Executing: $BASH_COMMAND"' DEBUG

x=1
y=2
z=$((x + y))
echo $z

# Output:
# Executing: x=1
# Executing: y=2
# Executing: z=$((x + y))
# Executing: echo $z
# 3
```

### 4.5 bashdb (Debugger)

```bash
# Instalare
sudo apt install bashdb

# Utilizare
bashdb script.sh

# Comenzi bashdb:
# n (next) - următoarea linie
# s (step) - intră în funcție
# c (continue) - continuă
# p VAR - afișează variabilă
# b LINE - breakpoint
# q (quit) - ieșire
```

---

## 5. Profiling

### 5.1 Timing Simplu

```bash
#!/bin/bash

time_start() {
    _START_TIME=$(date +%s.%N)
}

time_end() {
    local end_time
    end_time=$(date +%s.%N)
    local duration
    duration=$(echo "$end_time - $_START_TIME" | bc)
    echo "Duration: ${duration}s"
}

time_start
# ... operații
time_end
```

### 5.2 Profiling Funcții

```bash
#!/bin/bash

declare -A FUNC_TIMES

profile_start() {
    local func="${FUNCNAME[1]}"
    FUNC_TIMES["${func}_start"]=$(date +%s.%N)
}

profile_end() {
    local func="${FUNCNAME[1]}"
    local start="${FUNC_TIMES["${func}_start"]}"
    local end
    end=$(date +%s.%N)
    local duration
    duration=$(echo "$end - $start" | bc)
    echo "[PROFILE] $func: ${duration}s" >&2
}

my_function() {
    profile_start
    # ... operații
    sleep 1
    profile_end
}

my_function
# Output: [PROFILE] my_function: 1.003s
```

---

## 6. Template Complet

```bash
#!/bin/bash
#
# Script: myapp.sh
# Description: Application with professional logging
#

set -euo pipefail

# === CONFIGURATION ===
readonly SCRIPT_NAME=$(basename "$0")
readonly SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
readonly LOG_FILE="${LOG_FILE:-/var/log/${SCRIPT_NAME%.sh}.log}"
readonly LOG_LEVEL="${LOG_LEVEL:-INFO}"

# === LOGGING ===
declare -A LOG_LEVELS=([DEBUG]=0 [INFO]=1 [WARN]=2 [ERROR]=3)

_log() {
    local level="$1"; shift
    local current="${LOG_LEVELS[$LOG_LEVEL]}"
    local msg_level="${LOG_LEVELS[$level]}"
    
    (( msg_level >= current )) || return 0
    
    local ts=$(date '+%Y-%m-%d %H:%M:%S')
    local msg="[$ts] [$level] $*"
    
    if (( msg_level >= 2 )); then
        echo "$msg" >&2
    else
        echo "$msg"
    fi
    
    echo "$msg" >> "$LOG_FILE"
}

log_debug() { _log DEBUG "$@"; }
log_info()  { _log INFO "$@"; }
log_warn()  { _log WARN "$@"; }
log_error() { _log ERROR "$@"; }

die() {
    log_error "$@"
    exit 1
}

# === MAIN ===
main() {
    log_info "Starting $SCRIPT_NAME"
    log_debug "Log level: $LOG_LEVEL"
    log_debug "Log file: $LOG_FILE"
    
    # Script logic here
    
    log_info "Completed successfully"
}

main "$@"
```

---

## 7. Exerciții

### Exercițiul 1
Implementați un sistem de logging cu 4 nivele și output colorat.

### Exercițiul 2
Creați un script care înregistrează timing-ul pentru fiecare funcție apelată.

### Exercițiul 3
Scrieți un script cu debug mode activabil prin variabilă de mediu.

---

## Cheat Sheet

```bash
# LOGGING SIMPLU
log() { echo "[$(date '+%H:%M:%S')] $*"; }

# LOGGING ÎN FIȘIER
log() { echo "[$(date)] $*" | tee -a "$LOG_FILE"; }

# NIVELE
log_debug() { [[ "$DEBUG" == true ]] && echo "[DEBUG] $*" >&2; }
log_error() { echo "[ERROR] $*" >&2; }

# DEBUGGING
set -x              # Trace on
set +x              # Trace off
export PS4='+(${BASH_SOURCE}:${LINENO}): '

# TIMING
time command
SECONDS=0; ...; echo "${SECONDS}s"

# CULORI
RED='\033[0;31m'; NC='\033[0m'
echo -e "${RED}Error${NC}"
```

---

## 📤 Finalizare și Trimitere

După ce ai terminat toate cerințele:

1. **Oprește înregistrarea** tastând:
   ```bash
   STOP_tema
   ```
   sau apasă `Ctrl+D`

2. **Așteaptă** - scriptul va:
   - Genera semnătura criptografică
   - Încărca automat fișierul pe server

3. **Verifică mesajul final**:
   - ✅ `ÎNCĂRCARE REUȘITĂ!` - tema a fost trimisă
   - ❌ Dacă upload-ul eșuează, fișierul `.cast` este salvat local - trimite-l manual mai târziu cu comanda afișată

> ⚠️ **NU modifica fișierul `.cast`** după generare - semnătura devine invalidă!

---

*By Revolvix for OPERATING SYSTEMS class | restricted licence 2017-2030*
