#!/bin/bash
#
# Library:     library.sh
# Descriere:   Funcții reutilizabile pentru scripturi Bash
# Autor:       ASE București - CSIE
# Versiune:    1.0.0
#
# Utilizare:   source library.sh
#              sau
#              . library.sh
#
# Observație:        Acest fișier NU trebuie executat direct!
#

# Verifică să nu fie rulat direct
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "EROARE: Acest fișier trebuie încărcat cu 'source', nu executat direct." >&2
    echo "Utilizare: source ${BASH_SOURCE[0]}" >&2
    exit 1
fi

# ============================================================
# CONSTANTE COMUNE
# ============================================================
readonly LIB_VERSION="1.0.0"

# ============================================================
# CULORI (pentru terminale)
# ============================================================
if [[ -t 1 ]]; then
    readonly _RED='\033[0;31m'
    readonly _GREEN='\033[0;32m'
    readonly _YELLOW='\033[0;33m'
    readonly _BLUE='\033[0;34m'
    readonly _BOLD='\033[1m'
    readonly _NC='\033[0m'
else
    readonly _RED=''
    readonly _GREEN=''
    readonly _YELLOW=''
    readonly _BLUE=''
    readonly _BOLD=''
    readonly _NC=''
fi

# ============================================================
# FUNCȚII DE OUTPUT
# ============================================================

# Afișează mesaj informativ
lib_info() {
    echo -e "${_GREEN}[INFO]${_NC} $*"
}

# Afișează avertisment
lib_warn() {
    echo -e "${_YELLOW}[WARN]${_NC} $*" >&2
}

# Afișează eroare
lib_error() {
    echo -e "${_RED}[ERROR]${_NC} $*" >&2
}

# Termină cu eroare
lib_die() {
    lib_error "$@"
    exit 1
}

# Afișează mesaj de debug (doar dacă DEBUG=1)
lib_debug() {
    [[ "${DEBUG:-0}" == "1" ]] && echo -e "${_BLUE}[DEBUG]${_NC} $*" >&2
}

# Afișează mesaj bold
lib_bold() {
    echo -e "${_BOLD}$*${_NC}"
}

# ============================================================
# FUNCȚII DE VERIFICARE
# ============================================================

# Verifică dacă o comandă există
lib_require_command() {
    local cmd="$1"
    local msg="${2:-Comanda '$cmd' nu este instalată}"
    command -v "$cmd" >/dev/null 2>&1 || lib_die "$msg"
}

# Verifică dacă un fișier există și este citibil
lib_require_file() {
    local file="$1"
    local msg="${2:-Fișierul nu există sau nu poate fi citit: $file}"
    [[ -f "$file" && -r "$file" ]] || lib_die "$msg"
}

# Verifică dacă un director există și este scriibil
lib_require_dir() {
    local dir="$1"
    local msg="${2:-Directorul nu există sau nu poate fi scris: $dir}"
    [[ -d "$dir" && -w "$dir" ]] || lib_die "$msg"
}

# Verifică dacă rulăm ca root
lib_require_root() {
    [[ $EUID -eq 0 ]] || lib_die "Acest script necesită privilegii root"
}

# Verifică să NU rulăm ca root
lib_forbid_root() {
    [[ $EUID -ne 0 ]] || lib_die "Acest script NU trebuie rulat ca root"
}

# ============================================================
# FUNCȚII DE STRING
# ============================================================

# Trim whitespace de la începutul și sfârșitul string-ului
lib_trim() {
    local var="$*"
    var="${var#"${var%%[![:space:]]*}"}"
    var="${var%"${var##*[![:space:]]}"}"
    echo "$var"
}

# Convertește la lowercase
lib_lowercase() {
    echo "${*,,}"
}

# Convertește la uppercase
lib_uppercase() {
    echo "${*^^}"
}

# Verifică dacă string-ul e gol sau doar whitespace
lib_is_empty() {
    local trimmed
    trimmed=$(lib_trim "$1")
    [[ -z "$trimmed" ]]
}

# Verifică dacă string-ul e un număr
lib_is_number() {
    [[ "$1" =~ ^[0-9]+$ ]]
}

# ============================================================
# FUNCȚII DE ARRAY
# ============================================================

# Verifică dacă elementul există în array
# Utilizare: lib_in_array "element" "${array[@]}"
lib_in_array() {
    local needle="$1"
    shift
    local item
    for item in "$@"; do
        [[ "$item" == "$needle" ]] && return 0
    done
    return 1
}

# Join array cu separator
# Utilizare: lib_join "," "${array[@]}"
lib_join() {
    local separator="$1"
    shift
    local first="$1"
    shift
    printf '%s' "$first" "${@/#/$separator}"
}

# ============================================================
# FUNCȚII DE FIȘIERE
# ============================================================

# Creează backup al fișierului
lib_backup() {
    local file="$1"
    local backup="${file}.bak.$(date +%Y%m%d_%H%M%S)"
    [[ -f "$file" ]] && cp "$file" "$backup"
    echo "$backup"
}

# Creează fișier temporar și returnează calea
lib_mktemp() {
    local prefix="${1:-tmp}"
    mktemp -t "${prefix}.XXXXXX"
}

# Creează director temporar și returnează calea
lib_mktempdir() {
    local prefix="${1:-tmp}"
    mktemp -d -t "${prefix}.XXXXXX"
}

# ============================================================
# FUNCȚII DE CONFIRMARE
# ============================================================

# Cere confirmare de la utilizator
# Utilizare: lib_confirm "Ești sigur?" && do_something
lib_confirm() {
    local prompt="${1:-Continui?}"
    local default="${2:-n}"
    
    local reply
    if [[ "$default" == "y" ]]; then
        read -r -p "$prompt [Y/n] " reply
        [[ -z "$reply" || "$reply" =~ ^[Yy] ]]
    else
        read -r -p "$prompt [y/N] " reply
        [[ "$reply" =~ ^[Yy] ]]
    fi
}

# Cere input de la utilizator cu valoare default
lib_prompt() {
    local prompt="$1"
    local default="${2:-}"
    local reply
    
    if [[ -n "$default" ]]; then
        read -r -p "$prompt [$default]: " reply
        echo "${reply:-$default}"
    else
        read -r -p "$prompt: " reply
        echo "$reply"
    fi
}

# ============================================================
# FUNCȚII DE LOGGING
# ============================================================

# Inițializează logging în fișier
# Utilizare: lib_init_log "/path/to/logfile.log"
_LIB_LOG_FILE=""

lib_init_log() {
    _LIB_LOG_FILE="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Log started" >> "$_LIB_LOG_FILE"
}

# Scrie în log
lib_log() {
    if [[ -n "$_LIB_LOG_FILE" ]]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$_LIB_LOG_FILE"
    fi
}

# ============================================================
# FUNCȚII DE PROGRESS
# ============================================================

# Spinner simplu pentru operații lungi
# Utilizare: lib_spinner $pid "Mesaj..."
lib_spinner() {
    local pid=$1
    local msg="${2:-Processing...}"
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0
    
    while kill -0 "$pid" 2>/dev/null; do
        printf "\r%s %s" "${spin:i++%${#spin}:1}" "$msg"
        sleep 0.1
    done
    printf "\r%s\n" "$msg Done!"
}

# Progress bar simplu
# Utilizare: lib_progress 50 100 "Downloading"
lib_progress() {
    local current=$1
    local total=$2
    local msg="${3:-Progress}"
    local width=40
    local percent=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))
    
    printf "\r%s: [%s%s] %d%%" "$msg" \
           "$(printf '#%.0s' $(seq 1 $filled))" \
           "$(printf '.%.0s' $(seq 1 $empty))" \
           "$percent"
    
    [[ $current -eq $total ]] && echo
}

# ============================================================
# FUNCȚII DIVERSE
# ============================================================

# Obține directorul scriptului care a încărcat biblioteca
lib_script_dir() {
    cd "$(dirname "${BASH_SOURCE[1]}")" && pwd
}

# Verifică versiunea Bash
lib_require_bash_version() {
    local required="$1"
    local current="${BASH_VERSINFO[0]}.${BASH_VERSINFO[1]}"
    
    if [[ "$(printf '%s\n' "$required" "$current" | sort -V | head -n1)" != "$required" ]]; then
        lib_die "Necesită Bash >= $required (ai $current)"
    fi
}

# Afișează informații despre bibliotecă
lib_info_version() {
    echo "Library version: $LIB_VERSION"
    echo "Bash version: ${BASH_VERSION}"
}

# ============================================================
# FIN
# ============================================================
lib_debug "Library loaded: library.sh v$LIB_VERSION"
