#!/bin/bash
#==============================================================================
# core.sh - Bibliotecă de funcții fundamentale pentru System Monitor
#==============================================================================
# DESCRIERE:
#   Funcții core pentru logging, error handling, și validare.
#   Acest modul reprezintă fundația arhitecturală a aplicației.
#
# UTILIZARE:
#   source "${SCRIPT_DIR}/lib/core.sh"
#
# AUTOR: ASE București - CSIE | Sisteme de Operare
# VERSIUNE: 1.0.0
#==============================================================================

#------------------------------------------------------------------------------
# CONSTANTE GLOBALE
#------------------------------------------------------------------------------
readonly CORE_VERSION="1.0.0"
readonly LOG_LEVELS=(DEBUG INFO WARN ERROR FATAL)

# Coduri culoare ANSI (pentru output terminal)
readonly COLOR_RESET='\033[0m'
readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[0;33m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_MAGENTA='\033[0;35m'
readonly COLOR_CYAN='\033[0;36m'
readonly COLOR_BOLD='\033[1m'

#------------------------------------------------------------------------------
# VARIABILE DE CONFIGURARE (pot fi suprascrise)
#------------------------------------------------------------------------------
LOG_LEVEL="${LOG_LEVEL:-INFO}"
LOG_FILE="${LOG_FILE:-}"
LOG_TO_STDOUT="${LOG_TO_STDOUT:-true}"
LOG_TIMESTAMP_FORMAT="${LOG_TIMESTAMP_FORMAT:-%Y-%m-%d %H:%M:%S}"
LOG_USE_COLORS="${LOG_USE_COLORS:-true}"

#------------------------------------------------------------------------------
# FUNCȚII DE LOGGING
#------------------------------------------------------------------------------

# Obține timestamp curent formatat
_get_timestamp() {
    date "+${LOG_TIMESTAMP_FORMAT}"
}

# Convertește nivel log la index numeric pentru comparație
_log_level_to_int() {
    local level="$1"
    case "$level" in
        DEBUG) echo 0 ;;
        INFO)  echo 1 ;;
        WARN)  echo 2 ;;
        ERROR) echo 3 ;;
        FATAL) echo 4 ;;
        *)     echo 1 ;;  # Default INFO
    esac
}

# Obține culoarea pentru un nivel de log
_get_level_color() {
    local level="$1"
    case "$level" in
        DEBUG) echo "$COLOR_CYAN" ;;
        INFO)  echo "$COLOR_GREEN" ;;
        WARN)  echo "$COLOR_YELLOW" ;;
        ERROR) echo "$COLOR_RED" ;;
        FATAL) echo "${COLOR_BOLD}${COLOR_RED}" ;;
        *)     echo "$COLOR_RESET" ;;
    esac
}

# Verifică dacă un mesaj trebuie logat bazat pe nivel
_should_log() {
    local msg_level="$1"
    local current_level="${LOG_LEVEL:-INFO}"
    
    local msg_int=$(_log_level_to_int "$msg_level")
    local current_int=$(_log_level_to_int "$current_level")
    
    [[ $msg_int -ge $current_int ]]
}

# Funcția principală de logging
# Utilizare: log LEVEL "mesaj"
log() {
    local level="${1:-INFO}"
    shift
    local message="$*"
    
    # Verifică dacă trebuie logat
    _should_log "$level" || return 0
    
    local timestamp=$(_get_timestamp)
    local formatted_msg
    
    # Formatare cu sau fără culori
    if [[ "$LOG_USE_COLORS" == "true" ]] && [[ -t 1 ]]; then
        local color=$(_get_level_color "$level")
        formatted_msg="${color}[${timestamp}] [${level}]${COLOR_RESET} ${message}"
    else
        formatted_msg="[${timestamp}] [${level}] ${message}"
    fi
    
    # Output la stdout dacă e activat
    if [[ "$LOG_TO_STDOUT" == "true" ]]; then
        if [[ "$level" == "ERROR" ]] || [[ "$level" == "FATAL" ]]; then
            echo -e "$formatted_msg" >&2
        else
            echo -e "$formatted_msg"
        fi
    fi
    
    # Output la fișier dacă e configurat
    if [[ -n "$LOG_FILE" ]]; then
        # Fără culori în fișier
        local file_msg="[${timestamp}] [${level}] ${message}"
        echo "$file_msg" >> "$LOG_FILE"
    fi
}

# Funcții shorthand pentru diferite nivele
log_debug() { log DEBUG "$@"; }
log_info()  { log INFO "$@"; }
log_warn()  { log WARN "$@"; }
log_error() { log ERROR "$@"; }
log_fatal() { log FATAL "$@"; }

#------------------------------------------------------------------------------
# FUNCȚII DE ERROR HANDLING
#------------------------------------------------------------------------------

# Termină scriptul cu mesaj de eroare
# Utilizare: die "mesaj de eroare" [exit_code]
die() {
    local message="${1:-Eroare necunoscută}"
    local exit_code="${2:-1}"
    
    log_fatal "$message"
    
    # Cleanup înainte de exit (dacă există funcția)
    if declare -f cleanup &>/dev/null; then
        cleanup
    fi
    
    exit "$exit_code"
}

# Verifică codul de retur al ultimei comenzi
# Utilizare: check_error "mesaj dacă eșuează"
check_error() {
    local exit_code=$?
    local message="${1:-Comanda anterioară a eșuat}"
    
    if [[ $exit_code -ne 0 ]]; then
        die "$message (exit code: $exit_code)"
    fi
}

# Execută o comandă cu logging și verificare erori
# Utilizare: run_cmd "descriere" comandă args...
run_cmd() {
    local description="$1"
    shift
    
    log_debug "Execut: $description"
    log_debug "Comandă: $*"
    
    if "$@"; then
        log_debug "Succes: $description"
        return 0
    else
        local exit_code=$?
        log_error "Eșec: $description (exit code: $exit_code)"
        return $exit_code
    fi
}

#------------------------------------------------------------------------------
# FUNCȚII DE VALIDARE
#------------------------------------------------------------------------------

# Verifică dacă o comandă există în PATH
# Utilizare: require_cmd "git" "jq" "curl"
require_cmd() {
    local missing=()
    
    for cmd in "$@"; do
        if ! command -v "$cmd" &>/dev/null; then
            missing+=("$cmd")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        die "Comenzi lipsă: ${missing[*]}. Instalează-le și încearcă din nou."
    fi
    
    log_debug "Toate comenzile necesare sunt disponibile: $*"
}

# Verifică dacă un fișier există și este citibil
# Utilizare: require_file "/path/to/file"
require_file() {
    local file="$1"
    local description="${2:-Fișier}"
    
    if [[ ! -f "$file" ]]; then
        die "$description nu există: $file"
    fi
    
    if [[ ! -r "$file" ]]; then
        die "$description nu poate fi citit: $file"
    fi
    
    log_debug "$description valid: $file"
}

# Verifică dacă un director există
# Utilizare: require_dir "/path/to/dir" [create_if_missing]
require_dir() {
    local dir="$1"
    local create="${2:-false}"
    local description="${3:-Director}"
    
    if [[ ! -d "$dir" ]]; then
        if [[ "$create" == "true" ]]; then
            mkdir -p "$dir" || die "Nu pot crea directorul: $dir"
            log_info "Director creat: $dir"
        else
            die "$description nu există: $dir"
        fi
    fi
    
    log_debug "$description valid: $dir"
}

# Verifică dacă o variabilă este setată și non-vidă
# Utilizare: require_var "VAR_NAME" "$VAR_VALUE"
require_var() {
    local var_name="$1"
    local var_value="$2"
    
    if [[ -z "$var_value" ]]; then
        die "Variabila $var_name nu este setată sau este vidă"
    fi
    
    log_debug "Variabilă validă: $var_name"
}

# Verifică dacă o valoare este un număr întreg
# Utilizare: is_integer "$value"
is_integer() {
    local value="$1"
    [[ "$value" =~ ^-?[0-9]+$ ]]
}

# Verifică dacă o valoare este în interval
# Utilizare: in_range "$value" $min $max
in_range() {
    local value="$1"
    local min="$2"
    local max="$3"
    
    is_integer "$value" || return 1
    [[ $value -ge $min ]] && [[ $value -le $max ]]
}

#------------------------------------------------------------------------------
# FUNCȚII PENTRU LOCK FILES (prevenire execuții concurente)
#------------------------------------------------------------------------------

# Achiziționează un lock exclusiv
# Utilizare: acquire_lock "/path/to/lockfile"
acquire_lock() {
    local lock_file="$1"
    local timeout="${2:-0}"
    
    require_var "LOCK_FILE" "$lock_file"
    
    # Verifică lock existent
    if [[ -f "$lock_file" ]]; then
        local existing_pid
        existing_pid=$(cat "$lock_file" 2>/dev/null)
        
        # Verifică dacă procesul încă rulează
        if [[ -n "$existing_pid" ]] && kill -0 "$existing_pid" 2>/dev/null; then
            log_error "Proces deja în execuție (PID: $existing_pid)"
            return 1
        fi
        
        # Lock stale, îl ștergem
        log_warn "Lock file stale găsit, îl elimin"
        rm -f "$lock_file"
    fi
    
    # Creează directorul dacă nu există
    local lock_dir
    lock_dir=$(dirname "$lock_file")
    require_dir "$lock_dir" true "Lock directory"
    
    # Scrie PID-ul curent
    echo $$ > "$lock_file" || die "Nu pot crea lock file: $lock_file"
    
    log_debug "Lock achiziționat: $lock_file (PID: $$)"
    return 0
}

# Eliberează un lock
# Utilizare: release_lock "/path/to/lockfile"
release_lock() {
    local lock_file="$1"
    
    if [[ -f "$lock_file" ]]; then
        local stored_pid
        stored_pid=$(cat "$lock_file" 2>/dev/null)
        
        # Șterge doar dacă e lock-ul nostru
        if [[ "$stored_pid" == "$$" ]]; then
            rm -f "$lock_file"
            log_debug "Lock eliberat: $lock_file"
        else
            log_warn "Lock file nu aparține acestui proces"
        fi
    fi
}

#------------------------------------------------------------------------------
# FUNCȚII PENTRU TRAP HANDLING
#------------------------------------------------------------------------------

# Handler implicit pentru semnale de terminare
_default_trap_handler() {
    local signal="$1"
    log_warn "Semnal primit: $signal"
    
    # Apelează cleanup dacă există
    if declare -f cleanup &>/dev/null; then
        cleanup
    fi
    
    exit 130  # 128 + 2 (SIGINT)
}

# Configurează trap handlers standard
# Utilizare: setup_traps [cleanup_function_name]
setup_traps() {
    local cleanup_func="${1:-cleanup}"
    
    trap "_default_trap_handler INT" INT
    trap "_default_trap_handler TERM" TERM
    trap "_default_trap_handler HUP" HUP
    
    # EXIT trap - cleanup final
    if declare -f "$cleanup_func" &>/dev/null; then
        trap "$cleanup_func" EXIT
    fi
    
    log_debug "Trap handlers configurate"
}

#------------------------------------------------------------------------------
# FUNCȚII UTILITARE
#------------------------------------------------------------------------------

# Afișează un separator vizual în log
log_separator() {
    local char="${1:--}"
    local length="${2:-60}"
    local line
    line=$(printf '%*s' "$length" '' | tr ' ' "$char")
    log_info "$line"
}

# Afișează header pentru o secțiune
log_header() {
    local title="$1"
    log_separator "="
    log_info "$title"
    log_separator "="
}

# Formatează bytes în format human-readable
format_bytes() {
    local bytes="$1"
    local units=("B" "KB" "MB" "GB" "TB")
    local unit=0
    
    # Conversie la float pentru calcul
    local size=$bytes
    
    while [[ $(echo "$size >= 1024" | bc -l 2>/dev/null || echo 0) -eq 1 ]] && [[ $unit -lt 4 ]]; do
        size=$(echo "scale=2; $size / 1024" | bc -l)
        ((unit++))
    done
    
    printf "%.2f %s" "$size" "${units[$unit]}"
}

# Formatează secunde în format human-readable
format_duration() {
    local seconds="$1"
    local days=$((seconds / 86400))
    local hours=$(((seconds % 86400) / 3600))
    local minutes=$(((seconds % 3600) / 60))
    local secs=$((seconds % 60))
    
    if [[ $days -gt 0 ]]; then
        printf "%dd %02d:%02d:%02d" "$days" "$hours" "$minutes" "$secs"
    elif [[ $hours -gt 0 ]]; then
        printf "%02d:%02d:%02d" "$hours" "$minutes" "$secs"
    else
        printf "%02d:%02d" "$minutes" "$secs"
    fi
}

#------------------------------------------------------------------------------
# INIȚIALIZARE
#------------------------------------------------------------------------------

# Mesaj de încărcare pentru debugging
log_debug "core.sh v${CORE_VERSION} încărcat"
