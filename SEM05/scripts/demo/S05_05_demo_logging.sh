#!/bin/bash
#
# S05_05_demo_logging.sh - Demonstrație Sisteme de Logging
# 
# Sisteme de Operare | ASE București - CSIE
# Seminar 9-10: Advanced Bash Scripting
#
# SCOP: Demonstrează implementarea unui sistem de logging profesional
#       cu nivele (DEBUG, INFO, WARN, ERROR, FATAL), output dual,
#       și best practices pentru scripturi de producție.
#
# UTILIZARE:
#   ./S05_05_demo_logging.sh              # Toate demo-urile
#   ./S05_05_demo_logging.sh simple       # Logging simplu
#   ./S05_05_demo_logging.sh levels       # Cu nivele
#   ./S05_05_demo_logging.sh advanced     # Sistem complet
#   LOG_LEVEL=DEBUG ./S05_05_demo_logging.sh  # Cu nivel specific
#

set -euo pipefail

# ============================================================
# CONSTANTE ȘI CULORI
# ============================================================
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly MAGENTA='\033[0;35m'
readonly BOLD='\033[1m'
readonly DIM='\033[2m'
readonly NC='\033[0m'

# Director temporar pentru demo
DEMO_LOG_DIR="/tmp/logging_demo_$$"
mkdir -p "$DEMO_LOG_DIR"

# Cleanup la exit
cleanup_demo() {
    rm -rf "$DEMO_LOG_DIR" 2>/dev/null || true
}
trap cleanup_demo EXIT

# ============================================================
# HELPER FUNCTIONS
# ============================================================

header() {
    echo ""
    echo -e "${BOLD}${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${BLUE}  $1${NC}"
    echo -e "${BOLD}${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo ""
}

subheader() {
    echo ""
    echo -e "${CYAN}▶ $1${NC}"
    echo -e "${CYAN}────────────────────────────────────────${NC}"
}

code() {
    echo -e "${YELLOW}$1${NC}"
}

info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

pause() {
    echo ""
    read -r -p "Apasă Enter pentru a continua..." </dev/tty 2>/dev/null || true
    echo ""
}

show_file() {
    local file="$1"
    echo -e "${DIM}─── Conținut $file ───${NC}"
    cat "$file"
    echo -e "${DIM}─── End ───${NC}"
}

# ============================================================
# DEMO 1: LOGGING SIMPLU
# ============================================================

demo_simple_logging() {
    header "LOGGING SIMPLU - Pentru Scripturi Mici"
    
    local LOG_FILE="$DEMO_LOG_DIR/simple.log"
    
    subheader "Varianta Minimalistă"
    
    code 'log() {
    echo "[$(date "+%H:%M:%S")] $*"
}'
    
    # Implementare
    simple_log() {
        echo "[$(date '+%H:%M:%S')] $*"
    }
    
    echo ""
    echo "Demonstrație:"
    simple_log "Script pornit"
    simple_log "Procesez date..."
    simple_log "Finalizat"
    
    pause
    
    subheader "Cu Salvare în Fișier"
    
    code 'LOG_FILE="/tmp/script.log"

log() {
    echo "[$(date "+%Y-%m-%d %H:%M:%S")] $*" | tee -a "$LOG_FILE"
}'
    
    # Implementare
    file_log() {
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
    }
    
    echo ""
    echo "Demonstrație (salvează și în $LOG_FILE):"
    file_log "Operație 1: inițializare"
    file_log "Operație 2: procesare"
    file_log "Operație 3: finalizare"
    
    echo ""
    show_file "$LOG_FILE"
    
    pause
    
    subheader "Cu Funcție de Eroare Separată"
    
    code 'log() {
    echo "[$(date "+%H:%M:%S")] $*" | tee -a "$LOG_FILE"
}

err() {
    echo "[$(date "+%H:%M:%S")] ERROR: $*" | tee -a "$LOG_FILE" >&2
}'
    
    # Implementare
    err_log() {
        echo "[$(date '+%H:%M:%S')] ERROR: $*" | tee -a "$LOG_FILE" >&2
    }
    
    echo ""
    echo "Demonstrație:"
    file_log "Procesare normală"
    err_log "Nu pot accesa fișierul X"
    file_log "Continuăm cu alt fișier"
    
    echo ""
    show_file "$LOG_FILE"
}

# ============================================================
# DEMO 2: LOGGING CU NIVELE
# ============================================================

demo_levels_logging() {
    header "LOGGING CU NIVELE - DEBUG, INFO, WARN, ERROR"
    
    local LOG_FILE="$DEMO_LOG_DIR/levels.log"
    > "$LOG_FILE"  # Reset file
    
    subheader "Conceptul de Log Levels"
    
    echo "Nivelele standard de logging (în ordine crescătoare de severitate):"
    echo ""
    echo -e "  ${DIM}DEBUG${NC}   - Informații detaliate pentru debugging"
    echo -e "  ${GREEN}INFO${NC}    - Operații normale, progres"
    echo -e "  ${YELLOW}WARN${NC}    - Situații neobișnuite, dar nu erori"
    echo -e "  ${RED}ERROR${NC}   - Erori care permit continuarea"
    echo -e "  ${BOLD}${RED}FATAL${NC}   - Erori critice, script-ul se oprește"
    echo ""
    
    info "LOG_LEVEL controlează ce mesaje apar"
    echo "  LOG_LEVEL=WARN → apar doar WARN, ERROR, FATAL"
    echo "  LOG_LEVEL=DEBUG → apar toate mesajele"
    
    pause
    
    subheader "Implementare cu Array Asociativ"
    
    code 'declare -A LOG_LEVELS=([DEBUG]=0 [INFO]=1 [WARN]=2 [ERROR]=3 [FATAL]=4)
LOG_LEVEL="${LOG_LEVEL:-INFO}"

log() {
    local level=$1; shift
    local message="$*"
    
    # Verifică dacă trebuie logat
    [ "${LOG_LEVELS[$level]:-0}" -lt "${LOG_LEVELS[$LOG_LEVEL]:-1}" ] && return
    
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}'
    
    # Implementare reală
    declare -A DEMO_LOG_LEVELS=([DEBUG]=0 [INFO]=1 [WARN]=2 [ERROR]=3 [FATAL]=4)
    DEMO_LOG_LEVEL="${LOG_LEVEL:-INFO}"
    
    demo_log() {
        local level=$1
        shift
        local message="$*"
        
        local level_num="${DEMO_LOG_LEVELS[$level]:-0}"
        local threshold="${DEMO_LOG_LEVELS[$DEMO_LOG_LEVEL]:-1}"
        
        [ "$level_num" -lt "$threshold" ] && return 0
        
        local timestamp
        timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        
        # Culori pentru terminal
        local color=""
        case "$level" in
            DEBUG) color="${DIM}" ;;
            INFO)  color="${GREEN}" ;;
            WARN)  color="${YELLOW}" ;;
            ERROR) color="${RED}" ;;
            FATAL) color="${BOLD}${RED}" ;;
        esac
        
        # Afișare cu culori
        echo -e "${color}[$timestamp] [$level] $message${NC}"
        
        # Salvare în fișier (fără culori)
        echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    }
    
    log_debug() { demo_log DEBUG "$@"; }
    log_info()  { demo_log INFO "$@"; }
    log_warn()  { demo_log WARN "$@"; }
    log_error() { demo_log ERROR "$@"; }
    
    echo ""
    echo "Demonstrație cu LOG_LEVEL=$DEMO_LOG_LEVEL:"
    echo ""
    
    log_debug "Variabile inițializate: x=5, y=10"
    log_info "Script pornit"
    log_info "Procesez fișierul: data.txt"
    log_warn "Fișierul e mare (>100MB), poate dura"
    log_error "Nu pot accesa: /etc/shadow"
    log_info "Script finalizat"
    
    echo ""
    info "DEBUG nu apare pentru că LOG_LEVEL=$DEMO_LOG_LEVEL"
    
    pause
    
    echo "Acum cu LOG_LEVEL=DEBUG:"
    DEMO_LOG_LEVEL="DEBUG"
    > "$LOG_FILE"
    
    log_debug "Variabile inițializate: x=5, y=10"
    log_info "Script pornit"
    log_debug "Checking file permissions..."
    log_info "Procesez fișierul: data.txt"
    log_debug "File size: 150MB"
    log_warn "Fișierul e mare, poate dura"
    
    echo ""
    show_file "$LOG_FILE"
}

# ============================================================
# DEMO 3: SISTEM AVANSAT DE LOGGING
# ============================================================

demo_advanced_logging() {
    header "SISTEM AVANSAT - Logging de Producție"
    
    local LOG_FILE="$DEMO_LOG_DIR/advanced.log"
    > "$LOG_FILE"
    
    subheader "Sistem Complet cu Context"
    
    code '# Format: [TIMESTAMP] [LEVEL] [SCRIPT:LINE] Message
log() {
    local level=$1; shift
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    local caller_info="${BASH_SOURCE[1]##*/}:${BASH_LINENO[0]}"
    
    local log_line="[$timestamp] [$level] [$caller_info] $*"
    
    echo "$log_line" >> "$LOG_FILE"
    
    # Afișează pe ecran în funcție de nivel
    case "$level" in
        DEBUG|INFO) echo "$log_line" ;;
        WARN|ERROR|FATAL) echo "$log_line" >&2 ;;
    esac
}'
    
    # Implementare avansată
    adv_log() {
        local level=$1
        shift
        local timestamp
        timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        
        # Informații despre apelant
        local script_name="${BASH_SOURCE[1]##*/}"
        local line_no="${BASH_LINENO[0]}"
        local caller_info="$script_name:$line_no"
        
        local log_line="[$timestamp] [$level] [$caller_info] $*"
        
        # Salvare în fișier
        echo "$log_line" >> "$LOG_FILE"
        
        # Culori pentru terminal
        local color=""
        case "$level" in
            DEBUG) color="${DIM}" ;;
            INFO)  color="${GREEN}" ;;
            WARN)  color="${YELLOW}" ;;
            ERROR) color="${RED}" ;;
            FATAL) color="${BOLD}${RED}" ;;
        esac
        
        echo -e "${color}$log_line${NC}"
    }
    
    process_file() {
        local file="$1"
        adv_log INFO "Processing: $file"
        adv_log DEBUG "Checking permissions..."
        if [[ ! -f "$file" ]]; then
            adv_log WARN "File not found, skipping: $file"
            return 1
        fi
        adv_log INFO "Done processing: $file"
    }
    
    echo ""
    echo "Demonstrație (observă [SCRIPT:LINE] în output):"
    echo ""
    
    adv_log INFO "Application starting"
    adv_log DEBUG "Initializing modules..."
    process_file "/etc/passwd"
    process_file "/nonexistent/file.txt"
    adv_log INFO "Application finished"
    
    echo ""
    show_file "$LOG_FILE"
    
    pause
    
    subheader "Logging Structurat (JSON)"
    
    code 'log_json() {
    local level=$1; shift
    local message=$1; shift
    local timestamp=$(date -Iseconds)
    
    # Extra fields ca JSON
    local extra=""
    while [[ $# -gt 0 ]]; do
        extra+=", \"${1%%=*}\": \"${1#*=}\""
        shift
    done
    
    echo "{\"time\": \"$timestamp\", \"level\": \"$level\", \"msg\": \"$message\"$extra}"
}'
    
    json_log() {
        local level=$1
        shift
        local message=$1
        shift
        local timestamp
        timestamp=$(date -Iseconds)
        
        local extra=""
        while [[ $# -gt 0 ]]; do
            extra+=", \"${1%%=*}\": \"${1#*=}\""
            shift
        done
        
        echo -e "${DIM}{\"time\": \"$timestamp\", \"level\": \"$level\", \"msg\": \"$message\"$extra}${NC}"
    }
    
    echo ""
    echo "Demonstrație logging JSON:"
    json_log INFO "User logged in" "user=admin" "ip=192.168.1.100"
    json_log WARN "High memory usage" "used_mb=7500" "total_mb=8000"
    json_log ERROR "Database connection failed" "host=db.local" "retry=3"
    
    info "JSON logs sunt ușor de parsat cu jq, importat în Elasticsearch, etc."
    
    pause
    
    subheader "Rotație Automată a Log-urilor"
    
    code 'rotate_log() {
    local log_file=$1
    local max_size=${2:-10485760}  # 10MB default
    local keep=${3:-5}
    
    [[ ! -f "$log_file" ]] && return
    
    local size=$(stat -f%z "$log_file" 2>/dev/null || stat -c%s "$log_file")
    
    if [[ $size -gt $max_size ]]; then
        for ((i=keep-1; i>=1; i--)); do
            [[ -f "${log_file}.$i" ]] && mv "${log_file}.$i" "${log_file}.$((i+1))"
        done
        mv "$log_file" "${log_file}.1"
        > "$log_file"
        echo "Log rotated: $log_file"
    fi
}'
    
    info "În producție, folosește logrotate pentru rotație automată"
}

# ============================================================
# DEMO 4: BEST PRACTICES
# ============================================================

demo_best_practices() {
    header "BEST PRACTICES PENTRU LOGGING"
    
    subheader "1. Structură Recomandată"
    
    code '# La începutul scriptului
readonly SCRIPT_NAME=$(basename "$0")
readonly LOG_FILE="${LOG_FILE:-/var/log/${SCRIPT_NAME%.*}.log}"
readonly LOG_LEVEL="${LOG_LEVEL:-INFO}"

# Funcții de logging definite după constante
log_info()  { log INFO "$@"; }
log_error() { log ERROR "$@"; }
# etc.'
    
    pause
    
    subheader "2. Ce să Loghezi"
    
    echo -e "${GREEN}✓ DO:${NC}"
    echo "  • Start/stop script"
    echo "  • Operații importante (fișiere procesate, rezultate)"
    echo "  • Erori și excepții"
    echo "  • Durata operațiilor lungi"
    echo "  • Input/output pentru debugging"
    echo ""
    
    echo -e "${RED}✗ DON'T:${NC}"
    echo "  • Parole sau token-uri"
    echo "  • Date personale (PII)"
    echo "  • Fiecare iterație dintr-un loop mare"
    echo "  • Mesaje vagi: 'Error occurred'"
    
    pause
    
    subheader "3. Pattern-uri Comune"
    
    code '# Logare durată operație
log_info "Starting backup..."
start_time=$(date +%s)
do_backup
end_time=$(date +%s)
log_info "Backup completed in $((end_time - start_time)) seconds"

# Logare cu context
log_info "Processing file" file="$filename" size="$size"

# Logare eroare cu stack trace
log_error "Operation failed" function="${FUNCNAME[1]}" line="${BASH_LINENO[0]}"'
    
    pause
    
    subheader "4. Exemple din Viața Reală"
    
    echo "Backup script logging:"
    echo ""
    
    simulate_backup() {
        local src="$1"
        local dst="$2"
        
        echo -e "${GREEN}[$(date '+%H:%M:%S')] [INFO] Starting backup: $src -> $dst${NC}"
        echo -e "${DIM}[$(date '+%H:%M:%S')] [DEBUG] Checking source exists...${NC}"
        echo -e "${DIM}[$(date '+%H:%M:%S')] [DEBUG] Source size: 1.2GB${NC}"
        echo -e "${GREEN}[$(date '+%H:%M:%S')] [INFO] Copying files...${NC}"
        sleep 1
        echo -e "${YELLOW}[$(date '+%H:%M:%S')] [WARN] Slow disk I/O detected${NC}"
        sleep 1
        echo -e "${GREEN}[$(date '+%H:%M:%S')] [INFO] Backup completed in 2 seconds${NC}"
        echo -e "${GREEN}[$(date '+%H:%M:%S')] [INFO] Files copied: 1,234, Size: 1.2GB${NC}"
    }
    
    simulate_backup "/home/user" "/backup/user"
}

# ============================================================
# DEMO 5: INTEGRARE ÎN TEMPLATE
# ============================================================

demo_template_integration() {
    header "INTEGRARE ÎN TEMPLATE PROFESIONAL"
    
    code '#!/bin/bash
set -euo pipefail

# ============ CONSTANTE ============
readonly SCRIPT_NAME=$(basename "$0")
readonly LOG_FILE="${LOG_FILE:-/tmp/${SCRIPT_NAME%.*}.log}"

# ============ LOGGING ============
declare -A LOG_LEVELS=([DEBUG]=0 [INFO]=1 [WARN]=2 [ERROR]=3 [FATAL]=4)
LOG_LEVEL="${LOG_LEVEL:-INFO}"

log() {
    local level=$1; shift
    [[ ${LOG_LEVELS[$level]} -lt ${LOG_LEVELS[$LOG_LEVEL]} ]] && return
    
    local ts=$(date "+%Y-%m-%d %H:%M:%S")
    local line="[$ts] [$level] [$SCRIPT_NAME] $*"
    
    echo "$line" >> "$LOG_FILE"
    [[ ${LOG_LEVELS[$level]} -ge ${LOG_LEVELS[WARN]} ]] && echo "$line" >&2 || echo "$line"
}

log_debug() { log DEBUG "$@"; }
log_info()  { log INFO "$@"; }
log_warn()  { log WARN "$@"; }
log_error() { log ERROR "$@"; }
log_fatal() { log FATAL "$@"; exit 1; }

# ============ CLEANUP ============
cleanup() {
    local exit_code=$?
    log_debug "Cleanup triggered with exit code: $exit_code"
    # cleanup operations...
    exit $exit_code
}
trap cleanup EXIT

# ============ MAIN ============
main() {
    log_info "Script starting..."
    # your code here
    log_info "Script completed successfully"
}

main "$@"'
    
    info "Acest pattern e inclus în template-ul profesional din kit!"
}

# ============================================================
# MAIN
# ============================================================

main() {
    case "${1:-all}" in
        simple)
            demo_simple_logging
            ;;
        levels)
            demo_levels_logging
            ;;
        advanced)
            demo_advanced_logging
            ;;
        practices)
            demo_best_practices
            ;;
        template)
            demo_template_integration
            ;;
        all)
            demo_simple_logging
            pause
            demo_levels_logging
            pause
            demo_advanced_logging
            pause
            demo_best_practices
            pause
            demo_template_integration
            ;;
        *)
            echo "Usage: $0 [simple|levels|advanced|practices|template|all]"
            echo ""
            echo "Environment:"
            echo "  LOG_LEVEL=DEBUG|INFO|WARN|ERROR|FATAL"
            exit 1
            ;;
    esac
    
    echo ""
    echo -e "${BOLD}${GREEN}═══ Demo Logging Completat! ═══${NC}"
}

main "$@"
