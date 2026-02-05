# S06_06: Gestionarea Erorilor în Scripturi Bash

> **Observație din laborator:** un reflex bun: după o comandă care *poate* eșua, uită-te la exit code (`echo $?`) și la output. În Bash, `set -euo pipefail` te ajută, dar nu te scutește de gândit: verifică input-ul și tratează cazurile-limită.
## Introducere

Gestionarea solidă a erorilor constituie un element diferențiator fundamental între scripturile ad-hoc și software-ul de nivel producție. În contextul sistemelor Unix/Linux, unde scripturile shell orchestrează procese critice și manipulează resurse sistemului, tratarea riguroasă a condițiilor de eroare devine imperativă pentru menținerea integrității datelor și stabilității operaționale.

Acest capitol explorează mecanismele native Bash pentru detecția și propagarea erorilor, pattern-uri arhitecturale pentru recovery graceful și strategii de logging care facilitează diagnosticarea post-mortem.

---

## Exit Codes: Limbajul Universal al Erorilor

### Convenții Standard

În mediul Unix, codul de ieșire (exit code) reprezintă canalul principal de comunicare a stării de terminare între procese. Convențiile stabilite:

| Exit Code | Semnificație | Exemple |
|-----------|--------------|---------|
| 0 | Succes | Operație completă fără erori |
| 1 | Eroare generică | Eroare nespecificată |
| 2 | Utilizare incorectă | Argumente invalide, sintaxă greșită |
| 64-78 | Erori standard (sysexits.h) | EX_USAGE=64, EX_DATAERR=65, etc. |
| 126 | Comandă neexecutabilă | Permisiuni lipsă |
| 127 | Comandă inexistentă | Command not found |
| 128+N | Terminare prin semnal N | 130=SIGINT, 137=SIGKILL, 143=SIGTERM |
| 255 | Exit code în afara range-ului | Eroare la specificare cod |

### Definire Exit Codes Personalizate

```bash
#!/bin/bash
#===============================================================================
# exit_codes.sh - Coduri de eroare standardizate pentru proiect
#===============================================================================

# Success
declare -gr EXIT_SUCCESS=0

# Erori generale (1-19)
declare -gr EXIT_FAILURE=1
declare -gr EXIT_USAGE=2
declare -gr EXIT_INVALID_ARGUMENT=3
declare -gr EXIT_MISSING_ARGUMENT=4

# Erori de dependențe (20-39)
declare -gr EXIT_MISSING_DEPENDENCY=20
declare -gr EXIT_INCOMPATIBLE_VERSION=21
declare -gr EXIT_MISSING_CONFIG=22

# Erori I/O (40-59)
declare -gr EXIT_FILE_NOT_FOUND=40
declare -gr EXIT_FILE_NOT_READABLE=41
declare -gr EXIT_FILE_NOT_WRITABLE=42
declare -gr EXIT_DIR_NOT_FOUND=43
declare -gr EXIT_PERMISSION_DENIED=44
declare -gr EXIT_DISK_FULL=45

# Erori de rețea (60-79)
declare -gr EXIT_NETWORK_ERROR=60
declare -gr EXIT_CONNECTION_REFUSED=61
declare -gr EXIT_TIMEOUT=62
declare -gr EXIT_DNS_FAILURE=63

# Erori de proces (80-99)
declare -gr EXIT_PROCESS_FAILED=80
declare -gr EXIT_ALREADY_RUNNING=81
declare -gr EXIT_LOCK_FAILED=82

# Erori interne (100-119)
declare -gr EXIT_INTERNAL_ERROR=100
declare -gr EXIT_NOT_IMPLEMENTED=101
declare -gr EXIT_ASSERTION_FAILED=102

# Mapping code -> message pentru diagnosticare
declare -grA EXIT_MESSAGES=(
    [$EXIT_SUCCESS]="Success"
    [$EXIT_FAILURE]="General failure"
    [$EXIT_USAGE]="Invalid usage"
    [$EXIT_INVALID_ARGUMENT]="Invalid argument"
    [$EXIT_MISSING_ARGUMENT]="Missing required argument"
    [$EXIT_MISSING_DEPENDENCY]="Missing dependency"
    [$EXIT_INCOMPATIBLE_VERSION]="Incompatible version"
    [$EXIT_MISSING_CONFIG]="Configuration file missing"
    [$EXIT_FILE_NOT_FOUND]="File not found"
    [$EXIT_FILE_NOT_READABLE]="File not readable"
    [$EXIT_FILE_NOT_WRITABLE]="File not writable"
    [$EXIT_DIR_NOT_FOUND]="Directory not found"
    [$EXIT_PERMISSION_DENIED]="Permission denied"
    [$EXIT_DISK_FULL]="Disk full"
    [$EXIT_NETWORK_ERROR]="Network error"
    [$EXIT_CONNECTION_REFUSED]="Connection refused"
    [$EXIT_TIMEOUT]="Operation timeout"
    [$EXIT_DNS_FAILURE]="DNS resolution failed"
    [$EXIT_PROCESS_FAILED]="Process execution failed"
    [$EXIT_ALREADY_RUNNING]="Process already running"
    [$EXIT_LOCK_FAILED]="Failed to acquire lock"
    [$EXIT_INTERNAL_ERROR]="Internal error"
    [$EXIT_NOT_IMPLEMENTED]="Feature not implemented"
    [$EXIT_ASSERTION_FAILED]="Assertion failed"
)

# Funcție helper pentru obținere mesaj eroare
get_exit_message() {
    local code="$1"
    echo "${EXIT_MESSAGES[$code]:-Unknown error (code: $code)}"
}

# Verificare dacă un cod indică eroare
is_error_code() {
    local code="$1"
    [[ $code -ne 0 ]]
}

# Exit cu mesaj formatat
die() {
    local code="${1:-$EXIT_FAILURE}"
    local message="${2:-$(get_exit_message "$code")}"
    
    echo "[FATAL] $message (exit code: $code)" >&2
    exit "$code"
}
```

---

## Opțiuni Shell pentru Comportament Defensiv

### set -e (errexit)

Opțiunea `errexit` determină terminarea imediată a scriptului când o comandă returnează cod non-zero:

```bash
#!/bin/bash
set -e  # Sau: set -o errexit

echo "Pas 1"
false           # Script se termină aici cu exit code 1
echo "Pas 2"    # Nu se execută niciodată
```

**Excepții de la errexit**:
- Comenzi în condiții (`if cmd; then`)
- Comenzi cu `||` sau `&&`
- Comenzi în subshell-uri `$(...)` (depinde de versiune)
- Comenzi în funcții apelate din contexte condiționale

```bash
# Aceste pattern-uri NU declanșează errexit
if false; then echo "nu"; fi           # OK - în condiție
false || true                           # OK - are ||
false && echo "nu"                      # OK - are &&
result=$(false; echo "după")            # ATENȚIE - comportament variabil!

# Funcție apelată din context condițional
may_fail() {
    false  # NU termină scriptul când funcția e apelată cu if
}
if may_fail; then echo "ok"; fi
```

### set -u (nounset)

Opțiunea `nounset` tratează variabilele nedefinite ca erori:

```bash
#!/bin/bash
set -u  # Sau: set -o nounset

echo "$UNDEFINED_VAR"  # Eroare: unbound variable

# Pattern-uri pentru valori default
echo "${VAR:-default}"     # Folosește "default" dacă VAR nedefinită sau goală
echo "${VAR-default}"      # Folosește "default" doar dacă VAR nedefinită
echo "${VAR:=default}"     # Setează și returnează "default" dacă nedefinită
echo "${VAR:+replacement}" # "replacement" doar dacă VAR e definită și non-goală

# Verificare explicită
if [[ -v VAR ]]; then
    echo "VAR is set to: $VAR"
else
    echo "VAR is not set"
fi

# Arrays - verificare index
declare -a arr=(one two three)
echo "${arr[10]:-}"  # Safe - returnează gol pentru index invalid
```

### set -o pipefail

În mod normal, codul de ieșire al unui pipeline este cel al ultimei comenzi. `pipefail` modifică acest comportament:

```bash
#!/bin/bash

# Fără pipefail
false | true
echo $?  # 0 - codul ultimei comenzi

# Cu pipefail
set -o pipefail
false | true
echo $?  # 1 - codul primei comenzi care eșuează

# Exemplu practic
cat /nonexistent/file 2>/dev/null | grep "pattern"
# Fără pipefail: $? = exit code grep (poate fi 0 sau 1)
# Cu pipefail: $? = 1 (cat a eșuat)
```

### Combinația Recomandată

```bash
#!/bin/bash
#===============================================================================
# Preambul defensiv standard
#===============================================================================

set -o errexit   # -e: Exit imediat la eroare
set -o nounset   # -u: Eroare la variabile nedefinite  
set -o pipefail  # Propagare erori în pipeline

# Opțional pentru debugging
# set -o xtrace # -x: Print comenzi înainte de execuție

# Alternativ, forma compactă:
# set -euo pipefail

# Pentru scripturi care necesită compatibilitate POSIX:
# Evitați pipefail (nu e POSIX) și folosiți alte mecanisme
```

---

## Trap Handlers: Interceptarea Semnalelor

### Mecanismul Trap

Comanda `trap` permite definirea handler-elor pentru semnale și pseudo-semnale:

```bash
# Sintaxă
trap 'commands' SIGNALS

# Pseudo-semnale Bash
# EXIT - La terminarea scriptului (orice exit code)
# ERR - La eroare (când errexit ar declanșa exit)
# DEBUG - Înainte de fiecare comandă
# RETURN - La ieșirea din funcție sau source

# Semnale comune
# SIGINT (2) - Ctrl+C
# SIGTERM (15) - kill default
# SIGHUP (1) - Terminal închis
# SIGQUIT (3) - Ctrl+\
```

### Pattern: Cleanup la Exit

```bash
#!/bin/bash
set -euo pipefail

#-------------------------------------------------------------------------------
# Variabile pentru cleanup
#-------------------------------------------------------------------------------
declare -g TEMP_DIR=""
declare -g LOCK_FILE=""
declare -ga CLEANUP_FILES=()

#-------------------------------------------------------------------------------
# Handler de cleanup
#-------------------------------------------------------------------------------
cleanup() {
    local exit_code=$?
    
    # Dezactivare trap pentru a evita recursivitate
    trap - EXIT ERR INT TERM
    
    echo "[CLEANUP] Starting cleanup (exit code: $exit_code)..."
    
    # Cleanup fișiere temporare
    for file in "${CLEANUP_FILES[@]}"; do
        if [[ -e "$file" ]]; then
            rm -f "$file" && echo "[CLEANUP] Removed: $file"
        fi
    done
    
    # Cleanup director temporar
    if [[ -n "$TEMP_DIR" && -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR" && echo "[CLEANUP] Removed temp dir: $TEMP_DIR"
    fi
    
    # Release lock
    if [[ -n "$LOCK_FILE" && -f "$LOCK_FILE" ]]; then
        rm -f "$LOCK_FILE" && echo "[CLEANUP] Released lock: $LOCK_FILE"
    fi
    
    echo "[CLEANUP] Cleanup completed"
    exit "$exit_code"
}

# Înregistrare handler
trap cleanup EXIT ERR INT TERM

#-------------------------------------------------------------------------------
# Funcții helper pentru management resurse
#-------------------------------------------------------------------------------
register_temp_file() {
    local file="$1"
    CLEANUP_FILES+=("$file")
}

create_temp_dir() {
    TEMP_DIR=$(mktemp -d)
    echo "$TEMP_DIR"
}

acquire_lock() {
    local lock_file="$1"
    
    if [[ -f "$lock_file" ]]; then
        local pid
        pid=$(<"$lock_file")
        if kill -0 "$pid" 2>/dev/null; then
            echo "Already running (PID: $pid)" >&2
            return 1
        fi
        echo "Removing stale lock file"
        rm -f "$lock_file"
    fi
    
    echo $$ > "$lock_file"
    LOCK_FILE="$lock_file"
    return 0
}

#-------------------------------------------------------------------------------
# Main
#-------------------------------------------------------------------------------
main() {
    # Resurse care vor fi curățate automat
    local tmp_dir
    tmp_dir=$(create_temp_dir)
    
    local tmp_file="${tmp_dir}/data.tmp"
    register_temp_file "$tmp_file"
    
    acquire_lock "/var/run/myapp.lock" || exit 1
    
    # Simulare lucru
    echo "Working in $tmp_dir..."
    echo "data" > "$tmp_file"
    
    # Eroare intenționată pentru demonstrație
    # false
    
    echo "Success!"
}

main "$@"
```

### Pattern: Error Handler cu Stack Trace

```bash
#!/bin/bash
set -euo pipefail

#-------------------------------------------------------------------------------
# Error Handler cu informații de diagnostic
#-------------------------------------------------------------------------------
error_handler() {
    local exit_code=$?
    local line_no="${1:-}"
    local bash_lineno="${2:-}"
    local last_command="${3:-}"
    local func_stack="${4:-}"
    
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo "  ERROR OCCURRED"
    echo "═══════════════════════════════════════════════════════════════"
    echo "  Exit Code:    $exit_code"
    echo "  Line Number:  $line_no"
    echo "  Command:      $last_command"
    echo ""
    
    # Stack trace
    if [[ -n "$func_stack" ]]; then
        echo "  Stack Trace:"
        echo "  ------------"
        local i=0
        local frames
        IFS=' ' read -ra frames <<< "$func_stack"
        for func in "${frames[@]}"; do
            local lineno="${BASH_LINENO[$i]:-?}"
            echo "    [$i] $func (line $lineno)"
            ((i++))
        done
    fi
    
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
}

# Trap ERR cu informații extinse
trap 'error_handler "${LINENO}" "${BASH_LINENO[*]}" "$BASH_COMMAND" "${FUNCNAME[*]}"' ERR

#-------------------------------------------------------------------------------
# Funcții de test
#-------------------------------------------------------------------------------
level3() {
    echo "In level3..."
    false  # Eroare aici
}

level2() {
    echo "In level2..."
    level3
}

level1() {
    echo "In level1..."
    level2
}

#-------------------------------------------------------------------------------
# Main
#-------------------------------------------------------------------------------
main() {
    echo "Starting..."
    level1
    echo "Finished"  # Nu ajunge aici
}

main "$@"
```

Output exemplu:
```
Starting...
In level1...
In level2...
In level3...

═══════════════════════════════════════════════════════════════
  ERROR OCCURRED
═══════════════════════════════════════════════════════════════
  Exit Code:    1
  Line Number:  42
  Command:      false

  Stack Trace:
  ------------
    [0] level3 (line 47)
    [1] level2 (line 52)
    [2] level1 (line 57)
    [3] main (line 63)

═══════════════════════════════════════════════════════════════
```

---

## Pattern-uri de Error Handling

### Pattern 1: Try-Catch Simulat

Bash nu are try-catch nativ, dar putem simula comportamentul:

```bash
#!/bin/bash

#-------------------------------------------------------------------------------
# Implementare try-catch
#-------------------------------------------------------------------------------

# Variabile globale pentru excepții
declare -g EXCEPTION=""
declare -g EXCEPTION_CODE=0

# "throw" - ridică excepție
throw() {
    EXCEPTION="$1"
    EXCEPTION_CODE="${2:-1}"
    return "$EXCEPTION_CODE"
}

# "try" - execută bloc cu capturare erori
try() {
    local -a commands=("$@")
    
    EXCEPTION=""
    EXCEPTION_CODE=0
    
    # Dezactivare temporară errexit
    local old_errexit
    old_errexit=$(set +o | grep errexit)
    set +e
    
    # Execuție comenzi
    "${commands[@]}"
    EXCEPTION_CODE=$?
    
    # Restaurare errexit
    eval "$old_errexit"
    
    return 0  # try returnează mereu 0
}

# "catch" - verifică dacă a apărut excepție
catch() {
    local pattern="${1:-.*}"
    
    if [[ $EXCEPTION_CODE -ne 0 ]]; then
        if [[ "$EXCEPTION" =~ $pattern ]]; then
            return 0  # Excepție prinză
        fi
    fi
    return 1  # Nu s-a prins excepție
}

#-------------------------------------------------------------------------------
# Exemplu utilizare
#-------------------------------------------------------------------------------
risky_operation() {
    local success_probability=$((RANDOM % 10))
    
    if [[ $success_probability -lt 3 ]]; then
        throw "NetworkError: Connection failed" 60
    elif [[ $success_probability -lt 5 ]]; then
        throw "IOError: File not accessible" 40
    fi
    
    echo "Operation successful"
}

main() {
    try risky_operation
    
    if catch "NetworkError"; then
        echo "Caught network error: $EXCEPTION"
        echo "Retrying..."
        try risky_operation
    fi
    
    if catch "IOError"; then
        echo "Caught IO error: $EXCEPTION"
        echo "Using fallback..."
    fi
    
    if catch; then
        echo "Caught unexpected error: $EXCEPTION (code: $EXCEPTION_CODE)"
    fi
    
    echo "Continuing execution..."
}

main "$@"
```

### Pattern 2: Result Type (Success/Error)

```bash
#!/bin/bash

#-------------------------------------------------------------------------------
# Result Type Implementation
#-------------------------------------------------------------------------------

# Result este reprezentat ca "OK:value" sau "ERR:message"

result_ok() {
    echo "OK:$1"
}

result_err() {
    echo "ERR:$1"
}

is_ok() {
    [[ "$1" == OK:* ]]
}

is_err() {
    [[ "$1" == ERR:* ]]
}

unwrap() {
    local result="$1"
    
    if is_ok "$result"; then
        echo "${result#OK:}"
        return 0
    else
        echo "Attempted to unwrap error: ${result#ERR:}" >&2
        return 1
    fi
}

unwrap_err() {
    local result="$1"
    
    if is_err "$result"; then
        echo "${result#ERR:}"
        return 0
    else
        echo "Not an error result" >&2
        return 1
    fi
}

unwrap_or() {
    local result="$1"
    local default="$2"
    
    if is_ok "$result"; then
        echo "${result#OK:}"
    else
        echo "$default"
    fi
}

#-------------------------------------------------------------------------------
# Exemplu: Funcții care returnează Result
#-------------------------------------------------------------------------------
divide() {
    local a="$1"
    local b="$2"
    
    if [[ "$b" -eq 0 ]]; then
        result_err "Division by zero"
        return
    fi
    
    result_ok "$(( a / b ))"
}

read_config() {
    local file="$1"
    
    if [[ ! -f "$file" ]]; then
        result_err "Config file not found: $file"
        return
    fi
    
    if [[ ! -r "$file" ]]; then
        result_err "Config file not readable: $file"
        return
    fi
    
    result_ok "$(<"$file")"
}

#-------------------------------------------------------------------------------
# Utilizare
#-------------------------------------------------------------------------------
main() {
    local result
    
    # Exemplu divide
    result=$(divide 10 2)
    if is_ok "$result"; then
        echo "10 / 2 = $(unwrap "$result")"
    fi
    
    result=$(divide 10 0)
    if is_err "$result"; then
        echo "Error: $(unwrap_err "$result")"
    fi
    
    # Cu unwrap_or
    result=$(divide 10 0)
    echo "Result with default: $(unwrap_or "$result" "N/A")"
    
    # Chain results
    result=$(read_config "/etc/myapp/config.conf")
    if is_err "$result"; then
        echo "Using default config"
        result=$(result_ok "default=true")
    fi
    local config
    config=$(unwrap "$result")
    echo "Config: $config"
}

main "$@"
```

### Pattern 3: Error Accumulator

Colectează multiple erori în loc să oprească la prima:

```bash
#!/bin/bash

#-------------------------------------------------------------------------------
# Error Accumulator
#-------------------------------------------------------------------------------
declare -ga ERRORS=()
declare -g ERROR_COUNT=0

clear_errors() {
    ERRORS=()
    ERROR_COUNT=0
}

add_error() {
    local message="$1"
    local code="${2:-1}"
    local context="${3:-}"
    
    local error_entry="[CODE:$code]"
    [[ -n "$context" ]] && error_entry+=" [$context]"
    error_entry+=" $message"
    
    ERRORS+=("$error_entry")
    ((ERROR_COUNT++))
}

has_errors() {
    [[ $ERROR_COUNT -gt 0 ]]
}

get_error_count() {
    echo "$ERROR_COUNT"
}

print_errors() {
    local prefix="${1:-ERROR}"
    
    if has_errors; then
        echo "══════════════════════════════════════════════════════"
        echo " $ERROR_COUNT error(s) occurred:"
        echo "══════════════════════════════════════════════════════"
        local i=1
        for error in "${ERRORS[@]}"; do
            echo " $i. $error"
            ((i++))
        done
        echo "══════════════════════════════════════════════════════"
    fi
}

#-------------------------------------------------------------------------------
# Exemplu: Validare cu acumulare erori
#-------------------------------------------------------------------------------
validate_config() {
    local config_file="$1"
    
    clear_errors
    
    # Verificare existență
    if [[ ! -f "$config_file" ]]; then
        add_error "Config file not found" 40 "validate_config"
        return 1
    fi
    
    # Citire și validare parametri
    local line_num=0
    while IFS='=' read -r key value || [[ -n "$key" ]]; do
        ((line_num++))
        
        # Skip comentarii și linii goale
        [[ "$key" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${key// /}" ]] && continue
        
        # Validare key
        if [[ ! "$key" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
            add_error "Invalid key format: '$key'" 65 "line $line_num"
        fi
        
        # Validare value non-empty pentru anumite keys
        case "$key" in
            *_required|*_path|*_dir)
                if [[ -z "$value" ]]; then
                    add_error "Required value missing for: $key" 65 "line $line_num"
                fi
                ;;
        esac
        
        # Validare paths
        if [[ "$key" == *_path ]] && [[ -n "$value" ]]; then
            if [[ ! -e "$value" ]]; then
                add_error "Path does not exist: $value" 40 "line $line_num"
            fi
        fi
        
    done < "$config_file"
    
    # Return status bazat pe erori
    has_errors && return 1 || return 0
}

#-------------------------------------------------------------------------------
# Utilizare
#-------------------------------------------------------------------------------
main() {
    local config_file="${1:-/etc/myapp/config.conf}"
    
    echo "Validating configuration..."
    
    if validate_config "$config_file"; then
        echo "Configuration is valid."
    else
        echo "Configuration validation failed!"
        print_errors
        exit 1
    fi
}

main "$@"
```

---

## Logging Framework

### Implementare Multi-nivel

```bash
#!/bin/bash
#===============================================================================
# logging.sh - Framework de logging pentru producție
#===============================================================================

#-------------------------------------------------------------------------------
# Configurare
#-------------------------------------------------------------------------------
declare -g LOG_LEVEL="${LOG_LEVEL:-INFO}"
declare -g LOG_FILE="${LOG_FILE:-}"
declare -g LOG_TO_STDERR="${LOG_TO_STDERR:-1}"
declare -g LOG_TIMESTAMP="${LOG_TIMESTAMP:-1}"
declare -g LOG_PID="${LOG_PID:-1}"
declare -g LOG_FUNC="${LOG_FUNC:-0}"
declare -g LOG_COLOR="${LOG_COLOR:-1}"

# Nivele de logging (numeric pentru comparație)
declare -grA LOG_LEVELS=(
    [TRACE]=0
    [DEBUG]=1
    [INFO]=2
    [WARN]=3
    [ERROR]=4
    [FATAL]=5
    [OFF]=6
)

# Culori pentru output
declare -grA LOG_COLORS=(
    [TRACE]='\033[0;37m'   # Gri
    [DEBUG]='\033[0;36m'   # Cyan
    [INFO]='\033[0;32m'    # Verde
    [WARN]='\033[0;33m'    # Galben
    [ERROR]='\033[0;31m'   # Roșu
    [FATAL]='\033[1;31m'   # Roșu bold
)
declare -gr COLOR_RESET='\033[0m'

#-------------------------------------------------------------------------------
# Funcții interne
#-------------------------------------------------------------------------------
_log_level_value() {
    echo "${LOG_LEVELS[${1^^}]:-2}"
}

_should_log() {
    local level="$1"
    local current_level_value
    local requested_level_value
    
    current_level_value=$(_log_level_value "$LOG_LEVEL")
    requested_level_value=$(_log_level_value "$level")
    
    [[ $requested_level_value -ge $current_level_value ]]
}

_format_log_message() {
    local level="$1"
    local message="$2"
    local caller_func="${FUNCNAME[3]:-main}"
    local caller_line="${BASH_LINENO[2]:-0}"
    
    local formatted=""
    
    # Timestamp
    if [[ "$LOG_TIMESTAMP" == "1" ]]; then
        formatted+="[$(date '+%Y-%m-%d %H:%M:%S.%3N')] "
    fi
    
    # Level
    if [[ "$LOG_COLOR" == "1" && -t 2 ]]; then
        formatted+="${LOG_COLORS[$level]:-}[${level}]${COLOR_RESET} "
    else
        formatted+="[${level}] "
    fi
    
    # PID
    if [[ "$LOG_PID" == "1" ]]; then
        formatted+="[$$] "
    fi
    
    # Function și line
    if [[ "$LOG_FUNC" == "1" ]]; then
        formatted+="[$caller_func:$caller_line] "
    fi
    
    # Message
    formatted+="$message"
    
    echo -e "$formatted"
}

_write_log() {
    local formatted_message="$1"
    
    # Output la stderr
    if [[ "$LOG_TO_STDERR" == "1" ]]; then
        echo -e "$formatted_message" >&2
    fi
    
    # Output la fișier
    if [[ -n "$LOG_FILE" ]]; then
        # Strip culori pentru fișier
        local clean_message
        clean_message=$(echo -e "$formatted_message" | sed 's/\x1b\[[0-9;]*m//g')
        echo "$clean_message" >> "$LOG_FILE"
    fi
}

#-------------------------------------------------------------------------------
# Funcții publice de logging
#-------------------------------------------------------------------------------
log() {
    local level="${1:-INFO}"
    shift
    local message="$*"
    
    _should_log "$level" || return 0
    
    local formatted
    formatted=$(_format_log_message "$level" "$message")
    _write_log "$formatted"
}

log_trace() { log TRACE "$@"; }
log_debug() { log DEBUG "$@"; }
log_info()  { log INFO "$@"; }
log_warn()  { log WARN "$@"; }
log_error() { log ERROR "$@"; }
log_fatal() { log FATAL "$@"; exit 1; }

#-------------------------------------------------------------------------------
# Funcții helper
#-------------------------------------------------------------------------------

# Log cu context structural
log_context() {
    local level="$1"
    local context="$2"
    shift 2
    local message="$*"
    
    log "$level" "[$context] $message"
}

# Log pentru operații (start/end)
log_operation_start() {
    local operation="$1"
    log_info "Starting: $operation"
}

log_operation_end() {
    local operation="$1"
    local status="${2:-success}"
    local duration="${3:-}"
    
    local message="Completed: $operation ($status)"
    [[ -n "$duration" ]] && message+=" [${duration}ms]"
    
    if [[ "$status" == "success" ]]; then
        log_info "$message"
    else
        log_error "$message"
    fi
}

# Log pentru variabile (debugging)
log_var() {
    local var_name="$1"
    local var_value="${!var_name:-<undefined>}"
    log_debug "$var_name = '$var_value'"
}

# Log pentru arrays
log_array() {
    local -n arr="$1"
    local arr_name="$1"
    
    log_debug "$arr_name = [${arr[*]}] (${#arr[@]} elements)"
}

#-------------------------------------------------------------------------------
# Inițializare
#-------------------------------------------------------------------------------
init_logging() {
    local level="${1:-$LOG_LEVEL}"
    local file="${2:-$LOG_FILE}"
    
    LOG_LEVEL="${level^^}"
    LOG_FILE="$file"
    
    # Creare director pentru log file dacă necesar
    if [[ -n "$LOG_FILE" ]]; then
        local log_dir
        log_dir=$(dirname "$LOG_FILE")
        mkdir -p "$log_dir"
    fi
    
    log_debug "Logging initialized (level: $LOG_LEVEL, file: ${LOG_FILE:-<none>})"
}

#-------------------------------------------------------------------------------
# Export pentru sourcing
#-------------------------------------------------------------------------------
export -f log log_trace log_debug log_info log_warn log_error log_fatal
export -f log_context log_operation_start log_operation_end log_var
export LOG_LEVEL LOG_FILE
```

### Utilizare în Proiecte

```bash
#!/bin/bash
source "$(dirname "$0")/lib/logging.sh"

# Configurare
init_logging "DEBUG" "/var/log/myapp/app.log"

# Utilizare
main() {
    log_info "Application starting"
    log_var HOME
    
    log_operation_start "Database connection"
    local start_time=$SECONDS
    
    # Simulare operație
    sleep 1
    
    local duration=$(( (SECONDS - start_time) * 1000 ))
    log_operation_end "Database connection" "success" "$duration"
    
    if [[ some_condition ]]; then
        log_warn "Unusual condition detected"
    fi
    
    log_info "Application finished"
}

main "$@"
```

---

## Exerciții Practice

### Exercițiul 1: solid Script Template

Creați un template complet pentru scripturi solide:

```bash
# Cerințe:
# - Preambul defensiv (errexit, nounset, pipefail)
# - Exit codes standardizate
# - Handler cleanup la EXIT
# - Error handler cu stack trace
# - Logging configurable
# - Argument parsing cu validare
```

### Exercițiul 2: Retry Mechanism

Implementați un mecanism generic de retry cu backoff:

```bash
# Cerințe:
# - Număr configurabil de retry-uri
# - Exponential backoff cu jitter
# - Logging pentru fiecare încercare
# - Timeout per încercare
# - Callback pentru customizare
```

### Exercițiul 3: Circuit Breaker Pattern

Implementați pattern-ul Circuit Breaker:

```bash
# Cerințe:
# - Stări: CLOSED, OPEN, HALF_OPEN
# - Threshold configurabil pentru deschidere
# - Timeout pentru recovery
# - Persistență stare între execuții
```

### Exercițiul 4: Validare Input complet

Creați un framework de validare pentru input:

```bash
# Cerințe:
# - Validare tip (string, int, float, email, path)
# - Validare range (min/max)
# - Validare pattern (regex)
# - Mesaje de eroare descriptive
# - Acumulare erori multiple
```

### Exercițiul 5: Graceful Shutdown

Implementați mecanism de oprire graceful:

```bash
# Cerințe:
# - Handling SIGTERM/SIGINT
# - Finalizare task-uri în progres
# - Timeout pentru shutdown forțat
# - Checkpoint pentru resume
```

---

## Best Practices Sumar

1. **Folosiți `set -euo pipefail`** ca preambul standard
2. **Definiți exit codes** clare și documentate
3. **Implementați cleanup handlers** cu trap
4. **Logați la nivelul potrivit** - nu prea mult, nu prea puțin
5. **Validați input-ul** înainte de procesare
6. **Eșuați devreme** (fail fast) când detectați probleme
7. **Furnizați context** în mesajele de eroare
8. **Testați căile de eroare** nu doar happy path
