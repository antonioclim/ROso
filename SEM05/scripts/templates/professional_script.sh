#!/bin/bash
#
# Script:      professional_script.sh
# Descriere:   Template complet pentru scripturi Bash de producție
# Autor:       ASE București - CSIE
# Versiune:    1.0.0
# Data:        2025-01-10
#
# Utilizare:   ./professional_script.sh [opțiuni] <input>
# Exemplu:     ./professional_script.sh -v -o output.txt input.txt
#
# Note:        Acest template include toate best practices pentru
#              scripturi solide și mentenabile.
#

# ============================================================
# SAFETY OPTIONS - ÎNTOTDEAUNA PRIMUL LUCRU DUPĂ SHEBANG
# ============================================================
# set -e: Exit imediat dacă o comandă returnează non-zero
# set -u: Tratează variabilele nedefinite ca eroare
# set -o pipefail: Returnează eroarea din orice comandă din pipe
set -euo pipefail

# IFS sigur: Doar newline și tab sunt separatori
# Previne probleme cu spații în nume de fișiere
IFS=$'\n\t'

# ============================================================
# CONSTANTE - readonly pentru a preveni modificări accidentale
# ============================================================
readonly SCRIPT_NAME=$(basename "$0")
readonly SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
readonly SCRIPT_VERSION="1.0.0"

# Timestamp pentru logging și fișiere temporare
readonly TIMESTAMP=$(date '+%Y%m%d_%H%M%S')

# ============================================================
# CONFIGURARE DEFAULT - Suprascrise de argumente sau environment
# ============================================================
VERBOSE=${VERBOSE:-0}                    # Nivel de verbose (0, 1, 2)
DRY_RUN=${DRY_RUN:-false}               # Simulare fără modificări
LOG_FILE="${LOG_FILE:-/tmp/${SCRIPT_NAME%.*}_${TIMESTAMP}.log}"
OUTPUT="${OUTPUT:-}"                     # Fișier output (opțional)

# ============================================================
# CULORI PENTRU OUTPUT (opțional, pentru terminale care suportă)
# ============================================================
if [[ -t 1 ]]; then
    readonly RED='\033[0;31m'
    readonly GREEN='\033[0;32m'
    readonly YELLOW='\033[0;33m'
    readonly BLUE='\033[0;34m'
    readonly NC='\033[0m'  # No Color
else
    readonly RED=''
    readonly GREEN=''
    readonly YELLOW=''
    readonly BLUE=''
    readonly NC=''
fi

# ============================================================
# LOGGING SYSTEM
# ============================================================
declare -A LOG_LEVELS=([DEBUG]=0 [INFO]=1 [WARN]=2 [ERROR]=3)
LOG_LEVEL="${LOG_LEVEL:-INFO}"

log() {
    local level=$1
    shift
    local message="$*"
    
    # Skip dacă sub nivelul curent
    [[ ${LOG_LEVELS[$level]:-1} -lt ${LOG_LEVELS[$LOG_LEVEL]:-1} ]] && return 0
    
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local log_line="[$timestamp] [$level] $message"
    
    # Scrie în log file
    echo "$log_line" >> "$LOG_FILE"
    
    # Pe ecran pentru niveluri >= WARN sau dacă VERBOSE
    if [[ ${LOG_LEVELS[$level]:-1} -ge ${LOG_LEVELS[WARN]:-2} ]] || [[ $VERBOSE -ge 1 ]]; then
        case $level in
            DEBUG) echo -e "${BLUE}$log_line${NC}" >&2 ;;
            INFO)  echo -e "${GREEN}$log_line${NC}" >&2 ;;
            WARN)  echo -e "${YELLOW}$log_line${NC}" >&2 ;;
            ERROR) echo -e "${RED}$log_line${NC}" >&2 ;;
        esac
    fi
}

log_debug() { log DEBUG "$@"; }
log_info()  { log INFO "$@"; }
log_warn()  { log WARN "$@"; }
log_error() { log ERROR "$@"; }

# ============================================================
# HELPER FUNCTIONS
# ============================================================

# Afișează mesajul de utilizare
usage() {
    cat << EOF
${SCRIPT_NAME} v${SCRIPT_VERSION}

DESCRIERE:
    Template pentru scripturi Bash profesionale.
    Adaptează acest template pentru nevoile tale.

UTILIZARE:
    ${SCRIPT_NAME} [opțiuni] <input_file>

OPȚIUNI:
    -h, --help          Afișează acest mesaj de ajutor
    -V, --version       Afișează versiunea
    -v, --verbose       Mod verbose (poate fi repetat: -vv pentru debug)
    -n, --dry-run       Simulare fără a face modificări reale
    -o, --output FILE   Specifică fișierul de output
    -l, --log FILE      Specifică fișierul de log

VARIABILE DE MEDIU:
    VERBOSE             Nivel de verbose (0-2)
    DRY_RUN             Setează la 'true' pentru dry run
    LOG_LEVEL           Nivel de logging (DEBUG, INFO, WARN, ERROR)
    LOG_FILE            Calea către fișierul de log

EXEMPLE:
    ${SCRIPT_NAME} input.txt
        Procesează input.txt cu setări default

    ${SCRIPT_NAME} -v -o output.txt input.txt
        Procesează cu verbose, scrie în output.txt

    ${SCRIPT_NAME} -vv --dry-run input.txt
        Simulare cu debug complet

    VERBOSE=2 ${SCRIPT_NAME} input.txt
        Alternativ: setare verbose din environment

EXIT CODES:
    0   Succes
    1   Eroare generală
    2   Utilizare incorectă (argumente invalide)
    3   Fișier de input nu există sau nu poate fi citit
    4   Eroare la procesare

AUTOR:
    ASE București - CSIE

EOF
}

# Afișează versiunea
version() {
    echo "${SCRIPT_NAME} versiunea ${SCRIPT_VERSION}"
}

# Termină script-ul cu eroare
die() {
    log_error "$*"
    exit 1
}

# Verifică dacă o comandă există
require_command() {
    local cmd="$1"
    command -v "$cmd" >/dev/null 2>&1 || die "Comanda '$cmd' nu este instalată"
}

# ============================================================
# CLEANUP - Se execută ÎNTOTDEAUNA la ieșire
# ============================================================
# Variabile pentru cleanup (setate în main)
TEMP_FILES=()

cleanup() {
    local exit_code=$?
    
    log_debug "Cleanup: starting (exit code: $exit_code)"
    
    # Șterge fișierele temporare
    for tmp in "${TEMP_FILES[@]:-}"; do
        if [[ -n "$tmp" && -e "$tmp" ]]; then
            rm -rf "$tmp"
            log_debug "Cleanup: removed $tmp"
        fi
    done
    
    if [[ $exit_code -eq 0 ]]; then
        log_info "Script completed successfully"
    else
        log_error "Script failed with exit code: $exit_code"
    fi
    
    exit $exit_code
}

# Setează trap-uri
trap cleanup EXIT
trap 'log_error "Interrupted by user"; exit 130' INT
trap 'log_error "Terminated"; exit 143' TERM

# ============================================================
# PARSARE ARGUMENTE
# ============================================================
parse_args() {
    # Argumente poziționale
    local positional=()
    
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
                [[ $VERBOSE -ge 2 ]] && LOG_LEVEL=DEBUG
                shift
                ;;
            -n|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -o|--output)
                [[ -z "${2:-}" ]] && die "Opțiunea --output necesită un argument"
                OUTPUT="$2"
                shift 2
                ;;
            --output=*)
                OUTPUT="${1#*=}"
                shift
                ;;
            -l|--log)
                [[ -z "${2:-}" ]] && die "Opțiunea --log necesită un argument"
                LOG_FILE="$2"
                shift 2
                ;;
            --log=*)
                LOG_FILE="${1#*=}"
                shift
                ;;
            --)
                shift
                positional+=("$@")
                break
                ;;
            -*)
                die "Opțiune necunoscută: $1. Folosește --help pentru ajutor."
                ;;
            *)
                positional+=("$1")
                shift
                ;;
        esac
    done
    
    # Restaurează argumentele poziționale
    set -- "${positional[@]}"
    
    # Verifică argumentele obligatorii
    if [[ $# -lt 1 ]]; then
        echo "Eroare: Lipsește argumentul input_file" >&2
        echo "Utilizare: ${SCRIPT_NAME} [opțiuni] <input_file>" >&2
        echo "Folosește --help pentru mai multe informații." >&2
        exit 2
    fi
    
    INPUT_FILE="$1"
}

# ============================================================
# VALIDARE
# ============================================================
validate() {
    log_debug "Validating inputs..."
    
    # Verifică fișierul de input
    if [[ ! -f "$INPUT_FILE" ]]; then
        die "Fișierul de input nu există: $INPUT_FILE"
    fi
    
    if [[ ! -r "$INPUT_FILE" ]]; then
        die "Nu pot citi fișierul de input: $INPUT_FILE"
    fi
    
    # Verifică output (dacă specificat)
    if [[ -n "$OUTPUT" ]]; then
        local output_dir
        output_dir=$(dirname "$OUTPUT")
        if [[ ! -d "$output_dir" ]]; then
            die "Directorul pentru output nu există: $output_dir"
        fi
        if [[ ! -w "$output_dir" ]]; then
            die "Nu pot scrie în directorul: $output_dir"
        fi
        if [[ -e "$OUTPUT" && ! -w "$OUTPUT" ]]; then
            die "Fișierul de output există și nu poate fi suprascris: $OUTPUT"
        fi
    fi
    
    # Verifică dependențe (adaugă comenzile necesare)
    # require_command "jq"
    # require_command "curl"
    
    log_debug "Validation passed"
}

# ============================================================
# LOGICA PRINCIPALĂ
# ============================================================
process() {
    log_info "Starting processing: $INPUT_FILE"
    log_debug "Verbose level: $VERBOSE"
    log_debug "Dry run: $DRY_RUN"
    log_debug "Output: ${OUTPUT:-stdout}"
    
    if $DRY_RUN; then
        log_warn "DRY RUN MODE - nu se fac modificări reale"
    fi
    
    # Creează fișier temporar pentru procesare
    local temp_file
    temp_file=$(mktemp)
    TEMP_FILES+=("$temp_file")
    log_debug "Created temp file: $temp_file"
    
    # ========================================
    # AICI VINE LOGICA TA SPECIFICĂ
    # ========================================
    
    # Exemplu: procesare simplă a fișierului
    local line_count
    line_count=$(wc -l < "$INPUT_FILE")
    log_info "Input file has $line_count lines"
    
    if ! $DRY_RUN; then
        # Procesare reală
        # Exemplu: copiază conținutul cu modificări
        while IFS= read -r line; do
            # Procesează fiecare linie
            echo "$line" >> "$temp_file"
        done < "$INPUT_FILE"
        
        # Scrie rezultatul
        if [[ -n "$OUTPUT" ]]; then
            cp "$temp_file" "$OUTPUT"
            log_info "Output written to: $OUTPUT"
        else
            cat "$temp_file"
        fi
    fi
    
    # ========================================
    # SFÂRȘIT LOGICA SPECIFICĂ
    # ========================================
    
    log_info "Processing completed"
}

# ============================================================
# MAIN - Punctul de intrare
# ============================================================
main() {
    log_info "Script started: ${SCRIPT_NAME} v${SCRIPT_VERSION}"
    log_debug "Script directory: $SCRIPT_DIR"
    log_debug "Arguments: $*"
    
    parse_args "$@"
    validate
    process
}

# Execută main cu toate argumentele
main "$@"
