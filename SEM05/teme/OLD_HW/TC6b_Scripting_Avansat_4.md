# TC6b - Scripting Avansat - Best Practices

> **Sisteme de Operare** | ASE București - CSIE  
> Material de laborator - Seminar 5

---

## Obiective

La finalul acestui laborator, studentul va fi capabil să:
- Scrie scripturi solide și sigure
- Implementeze error handling profesional
- Folosească logging și debugging
- Aplice best practices în producție

---

## 1. Setări pentru Scripturi solide

### 1.1 Opțiuni de Bază

```bash
#!/bin/bash

# Recomandare: întotdeauna folosește aceste opțiuni
set -e          # Exit la prima eroare
set -u          # Eroare pentru variabile nedefinite
set -o pipefail # Eroare dacă orice din pipe eșuează

# Sau combinate
set -euo pipefail

# IFS sigur
IFS=$'\n\t'
```

### 1.2 Ce Fac Aceste Opțiuni

```bash
# set -e (errexit)
# Script-ul se oprește la prima comandă care returnează non-zero
set -e
false           # Script-ul se oprește aici
echo "Nu ajunge aici"

# set -u (nounset)
# Eroare dacă folosești variabile nedefinite
set -u
echo $NEDEFINITA  # Eroare!

# set -o pipefail
# Pipeline returnează eroarea primei comenzi care eșuează
set -o pipefail
false | true    # Returnează 1 (de la false)
```

### 1.3 Când să Dezactivezi temporar

```bash
# Temporar dezactivează -e pentru o comandă
set +e
comanda_care_poate_esua
status=$?
set -e

# Sau cu ||
comanda_care_poate_esua || true

# Verificare variabilă care poate fi nedefinită
set +u
if [ -z "${OPTIONAL_VAR:-}" ]; then
    OPTIONAL_VAR="default"
fi
set -u

# Mai elegant cu ${VAR:-default}
echo "${OPTIONAL_VAR:-valoare_default}"
```

---

## 2. Error Handling

### 2.1 Trap pentru Cleanup

```bash
#!/bin/bash
set -euo pipefail

# Creează fișiere temporare
TEMP_FILE=$(mktemp)
TEMP_DIR=$(mktemp -d)

# Funcția de cleanup
cleanup() {
    local exit_code=$?
    echo "Cleanup: șterg fișiere temporare..."
    rm -f "$TEMP_FILE"
    rm -rf "$TEMP_DIR"
    exit $exit_code
}

# Setează trap pentru cleanup la ieșire
trap cleanup EXIT

# Trap pentru semnale
trap 'echo "Întrerupt!"; exit 130' INT TERM

# Restul scriptului...
echo "Working with $TEMP_FILE"
# La ieșire (normală sau eroare), cleanup() se execută automat
```

### 2.2 Error Handler

```bash
#!/bin/bash
set -euo pipefail

# Handler pentru erori
error_handler() {
    local line=$1
    local cmd=$2
    local code=$3
    echo "Eroare la linia $line: '$cmd' a returnat $code" >&2
}

# Trap pentru ERR
trap 'error_handler $LINENO "$BASH_COMMAND" $?' ERR

# Funcție pentru erori fatale
die() {
    echo "FATAL: $*" >&2
    exit 1
}

# Utilizare
[ -f config.txt ] || die "Fișierul config.txt lipsește"
```

### 2.3 Pattern-uri de Verificare

```bash
# Verificare argumente
[ $# -ge 1 ] || { echo "Usage: $0 <file>"; exit 1; }

# Verificare fișier
[ -f "$1" ] || die "Fișierul nu există: $1"
[ -r "$1" ] || die "Nu pot citi: $1"

# Verificare dependențe
command -v jq >/dev/null 2>&1 || die "jq nu este instalat"

# Verificare permisiuni
[ -w "$OUTPUT_DIR" ] || die "Nu pot scrie în: $OUTPUT_DIR"
```

---

## 3. Logging Profesional

### 3.1 Sistem de Logging

```bash
#!/bin/bash

# Configurare logging
LOG_FILE="${LOG_FILE:-/var/log/$(basename "$0").log}"
LOG_LEVEL="${LOG_LEVEL:-INFO}"

# Nivele de logging
declare -A LOG_LEVELS=([DEBUG]=0 [INFO]=1 [WARN]=2 [ERROR]=3 [FATAL]=4)

log() {
    local level=$1
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Verifică dacă trebuie logat (bazat pe nivel)
    [ "${LOG_LEVELS[$level]:-1}" -lt "${LOG_LEVELS[$LOG_LEVEL]:-1}" ] && return
    
    # Format: [TIMESTAMP] [LEVEL] [SCRIPT:LINE] Message
    local log_line="[$timestamp] [$level] [$(basename "$0"):${BASH_LINENO[0]}] $message"
    
    # Scrie în log și (opțional) pe ecran
    echo "$log_line" >> "$LOG_FILE"
    
    # Afișează pe ecran dacă e ERROR sau mai sus
    if [ "${LOG_LEVELS[$level]:-1}" -ge "${LOG_LEVELS[WARN]:-2}" ]; then
        echo "$log_line" >&2
    fi
}

# Helper functions
log_debug() { log DEBUG "$@"; }
log_info()  { log INFO "$@"; }
log_warn()  { log WARN "$@"; }
log_error() { log ERROR "$@"; }
log_fatal() { log FATAL "$@"; exit 1; }

# Utilizare
log_info "Script pornit"
log_debug "Variabila X=$X"
log_warn "Capcană: fișier mare"
log_error "Nu pot procesa fișierul"
log_fatal "Eroare critică - oprire"
```

### 3.2 Logging Simplu

```bash
# Varianta simplă pentru scripturi mai mici
log() {
    echo "[$(date '+%H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

err() {
    echo "[$(date '+%H:%M:%S')] ERROR: $*" >&2 | tee -a "$LOG_FILE"
}
```

---

## 4. Debugging

### 4.1 Opțiuni de Debug

```bash
# Activare debug complet
set -x          # Afișează comenzile executate

# Debug selectiv
set -x
# cod de debuggat
set +x

# Verbose mode
set -v          # Afișează liniile citite

# În script, cu opțiune
#!/bin/bash
[[ "${DEBUG:-}" == "true" ]] && set -x
```

### 4.2 Debug în Practică

```bash
#!/bin/bash

# Debug mode din environment
DEBUG=${DEBUG:-false}

debug() {
    $DEBUG && echo "[DEBUG] $*" >&2
}

# Sau cu nivel
VERBOSE=${VERBOSE:-0}

verbose() {
    [ "$VERBOSE" -ge 1 ] && echo "$*" >&2
}

very_verbose() {
    [ "$VERBOSE" -ge 2 ] && echo "$*" >&2
}

# Utilizare
debug "Procesez fișierul: $file"
verbose "Pasul 1 completat"
very_verbose "Detalii interne: $var=$value"
```

### 4.3 Tehnici de Debug

```bash
# Print variables
echo "DEBUG: var=$var" >&2

# Afișează și continuă
echo "Checkpoint 1" >&2

# Stack trace
caller 0        # Arată apelantul funcției curente

# Trap pentru debug
trap 'echo "Line $LINENO: $BASH_COMMAND"' DEBUG
```

---

## 5. Configurare Externă

### 5.1 Fișiere de Configurare

```bash
#!/bin/bash

# Calea implicită pentru config
CONFIG_FILE="${CONFIG_FILE:-/etc/myapp/config.sh}"
USER_CONFIG="$HOME/.myapprc"

# Încarcă configurația
load_config() {
    # Config sistem
    [ -f "$CONFIG_FILE" ] && source "$CONFIG_FILE"
    
    # Config utilizator (suprascrie)
    [ -f "$USER_CONFIG" ] && source "$USER_CONFIG"
}

# Valori default (înainte de încărcare)
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
LOG_LEVEL="${LOG_LEVEL:-INFO}"

load_config

# Acum variabilele pot fi suprascrise din fișiere
echo "Connecting to $DB_HOST:$DB_PORT"
```

### 5.2 Environment Variables

```bash
# Valori din environment cu defaults
export APP_ENV="${APP_ENV:-development}"
export MAX_RETRIES="${MAX_RETRIES:-3}"
export TIMEOUT="${TIMEOUT:-30}"

# Verificare variabile obligatorii
: "${API_KEY:?Error: API_KEY must be set}"
: "${DB_PASSWORD:?Error: DB_PASSWORD must be set}"
```

---

## 6. Template Script Profesional

```bash
#!/bin/bash
#
# Script: template.sh
# Descriere: Template pentru scripturi de producție
# Autor: Nume
# Versiune: 1.0.0
# Data: 2025-01-10
#

set -euo pipefail
IFS=$'\n\t'

# ============================================================
# CONSTANTE
# ============================================================
readonly SCRIPT_NAME=$(basename "$0")
readonly SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
readonly SCRIPT_VERSION="1.0.0"

# ============================================================
# CONFIGURARE DEFAULT
# ============================================================
VERBOSE=${VERBOSE:-0}
DRY_RUN=${DRY_RUN:-false}
LOG_FILE="${LOG_FILE:-/tmp/${SCRIPT_NAME}.log}"

# ============================================================
# FUNCȚII HELPER
# ============================================================
usage() {
    cat << EOF
$SCRIPT_NAME v$SCRIPT_VERSION

Descriere scurtă a scriptului.

UTILIZARE:
    $SCRIPT_NAME [opțiuni] <argument>

OPȚIUNI:
    -h, --help          Afișează acest mesaj
    -V, --version       Afișează versiunea
    -v, --verbose       Mod verbose (poate fi repetat: -vv)
    -n, --dry-run       Simulare fără modificări
    -o, --output FILE   Fișier output

EXEMPLE:
    $SCRIPT_NAME input.txt
    $SCRIPT_NAME -v -o output.txt input.txt

EOF
}

version() {
    echo "$SCRIPT_NAME versiunea $SCRIPT_VERSION"
}

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

die() {
    echo "EROARE: $*" >&2
    exit 1
}

debug() {
    [ "$VERBOSE" -ge 1 ] && echo "[DEBUG] $*" >&2
}

# ============================================================
# CLEANUP
# ============================================================
cleanup() {
    local exit_code=$?
    # Cleanup code here
    exit $exit_code
}

trap cleanup EXIT
trap 'echo "Întrerupt"; exit 130' INT TERM

# ============================================================
# PARSARE ARGUMENTE
# ============================================================
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            -V|--version)
                version
                exit 0
                ;;
            -v|--verbose)
                ((VERBOSE++))
                shift
                ;;
            -n|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -o|--output)
                OUTPUT="$2"
                shift 2
                ;;
            --output=*)
                OUTPUT="${1#*=}"
                shift
                ;;
            --)
                shift
                break
                ;;
            -*)
                die "Opțiune necunoscută: $1"
                ;;
            *)
                break
                ;;
        esac
    done

    # Argumente poziționale
    [[ $# -ge 1 ]] || die "Lipsește argumentul input"
    INPUT="$1"
}

# ============================================================
# VALIDARE
# ============================================================
validate() {
    [[ -f "$INPUT" ]] || die "Fișierul nu există: $INPUT"
    [[ -r "$INPUT" ]] || die "Nu pot citi: $INPUT"
    
    if [[ -n "${OUTPUT:-}" && -e "$OUTPUT" ]]; then
        debug "Output file exists, will be overwritten"
    fi
}

# ============================================================
# LOGICA PRINCIPALĂ
# ============================================================
main() {
    parse_args "$@"
    validate
    
    log "Start procesare: $INPUT"
    debug "Verbose level: $VERBOSE"
    debug "Dry run: $DRY_RUN"
    
    if $DRY_RUN; then
        log "DRY RUN - nu se fac modificări"
        return 0
    fi
    
    # Procesare aici...
    
    log "Procesare completă"
}

# ============================================================
# EXECUȚIE
# ============================================================
main "$@"
```

---

## Cheat Sheet

```bash
# SETĂRI solidE
set -euo pipefail
IFS=$'\n\t'

# TRAP
trap cleanup EXIT
trap 'handler $LINENO' ERR

# LOGGING
log() { echo "[$(date)] $*" | tee -a "$LOG_FILE"; }
die() { echo "ERR: $*" >&2; exit 1; }

# VERIFICĂRI
[[ -f "$f" ]] || die "nu există"
[[ -n "$v" ]] || die "variabilă goală"
command -v cmd >/dev/null || die "cmd lipsește"

# DEFAULTS
VAR="${VAR:-default}"
: "${REQUIRED:?Error: must be set}"

# DEBUG
set -x          # debug on
set +x          # debug off
$DEBUG && echo "msg"

# TEMP FILES
TEMP=$(mktemp)
trap "rm -f $TEMP" EXIT
```

---
*Material adaptat pentru cursul de Sisteme de Operare | ASE București - CSIE*
