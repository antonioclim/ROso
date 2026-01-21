#!/bin/bash
#==============================================================================
# config.sh - Gestiunea configurării pentru System Monitor
#==============================================================================
# DESCRIERE:
#   Funcții pentru încărcarea, validarea și gestiunea configurării.
#   Suportă fișiere de configurare, environment variables și argumente CLI.
#
# ORDINE PRIORITATE (de la cel mai mic la cel mai mare):
#   1. Valori default hardcodate
#   2. Fișier de configurare (/etc/sysmonitor.conf sau $CONFIG_FILE)
#   3. Environment variables
#   4. Argumente command line
#
# AUTOR: ASE București - CSIE | Sisteme de Operare
# VERSIUNE: 1.0.0
#==============================================================================

readonly CONFIG_VERSION="1.0.0"

#------------------------------------------------------------------------------
# VALORI DEFAULT
#------------------------------------------------------------------------------

# Thresholds pentru alerte (procente)
declare -g THRESHOLD_CPU="${THRESHOLD_CPU:-80}"
declare -g THRESHOLD_MEM="${THRESHOLD_MEM:-90}"
declare -g THRESHOLD_DISK="${THRESHOLD_DISK:-85}"
declare -g THRESHOLD_SWAP="${THRESHOLD_SWAP:-50}"
declare -g THRESHOLD_LOAD_MULT="${THRESHOLD_LOAD_MULT:-2}"

# Interval monitorizare (secunde)
declare -g MONITOR_INTERVAL="${MONITOR_INTERVAL:-60}"

# Configurare logging
declare -g LOG_FILE="${LOG_FILE:-}"
declare -g LOG_LEVEL="${LOG_LEVEL:-INFO}"
declare -g LOG_MAX_SIZE="${LOG_MAX_SIZE:-10485760}"  # 10MB
declare -g LOG_ROTATE_COUNT="${LOG_ROTATE_COUNT:-5}"

# Configurare notificări
declare -g NOTIFY_EMAIL="${NOTIFY_EMAIL:-}"
declare -g NOTIFY_SLACK_WEBHOOK="${NOTIFY_SLACK_WEBHOOK:-}"
declare -g NOTIFY_ON_RECOVERY="${NOTIFY_ON_RECOVERY:-true}"

# Opțiuni
declare -g DRY_RUN="${DRY_RUN:-false}"
declare -g VERBOSE="${VERBOSE:-false}"
declare -g DAEMON_MODE="${DAEMON_MODE:-false}"
declare -g OUTPUT_FORMAT="${OUTPUT_FORMAT:-text}"  # text, json, csv

# Excluderi (mount points de ignorat)
declare -ga DISK_EXCLUDE_MOUNTS=()

# Lock file
declare -g LOCK_FILE="${LOCK_FILE:-}"

#------------------------------------------------------------------------------
# CONFIGURARE PATHS
#------------------------------------------------------------------------------

# Detectează directorul scriptului
_detect_script_dir() {
    local script_path="${BASH_SOURCE[1]:-$0}"
    local script_dir
    
    # Rezolvă symlinks
    while [[ -L "$script_path" ]]; do
        script_dir=$(cd -P "$(dirname "$script_path")" && pwd)
        script_path=$(readlink "$script_path")
        [[ "$script_path" != /* ]] && script_path="$script_dir/$script_path"
    done
    
    script_dir=$(cd -P "$(dirname "$script_path")" && pwd)
    echo "$script_dir"
}

# Setează path-uri bazate pe locația scriptului
_setup_paths() {
    # Dacă SCRIPT_DIR nu e setat, îl detectăm
    if [[ -z "${SCRIPT_DIR:-}" ]]; then
        SCRIPT_DIR=$(_detect_script_dir)
        readonly SCRIPT_DIR
    fi
    
    # Path-uri derivate
    readonly PROJECT_DIR="${SCRIPT_DIR}"
    readonly LIB_DIR="${PROJECT_DIR}/lib"
    readonly ETC_DIR="${PROJECT_DIR}/etc"
    readonly VAR_DIR="${PROJECT_DIR}/var"
    readonly LOG_DIR="${VAR_DIR}/log"
    readonly RUN_DIR="${VAR_DIR}/run"
    
    # Fișier configurare default
    readonly DEFAULT_CONFIG_FILE="${ETC_DIR}/monitor.conf"
    
    # Lock file default
    if [[ -z "$LOCK_FILE" ]]; then
        LOCK_FILE="${RUN_DIR}/monitor.pid"
    fi
    
    # Log file default
    if [[ -z "$LOG_FILE" ]]; then
        LOG_FILE="${LOG_DIR}/monitor.log"
    fi
}

#------------------------------------------------------------------------------
# FUNCȚII DE ÎNCĂRCARE CONFIGURARE
#------------------------------------------------------------------------------

# Încarcă configurarea dintr-un fișier
# Format fișier: KEY=value (shell-style)
load_config_file() {
    local config_file="${1:-$DEFAULT_CONFIG_FILE}"
    
    if [[ ! -f "$config_file" ]]; then
        log_debug "Fișier de configurare nu există: $config_file"
        return 0
    fi
    
    if [[ ! -r "$config_file" ]]; then
        log_warn "Nu pot citi fișierul de configurare: $config_file"
        return 1
    fi
    
    log_info "Încarc configurarea din: $config_file"
    
    # Citește linie cu linie, ignoră comentarii și linii goale
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Skip comentarii și linii goale
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line// /}" ]] && continue
        
        # Curăță whitespace
        line="${line#"${line%%[![:space:]]*}"}"
        line="${line%"${line##*[![:space:]]}"}"
        
        # Extrage KEY=VALUE
        if [[ "$line" =~ ^([A-Za-z_][A-Za-z0-9_]*)=(.*)$ ]]; then
            local key="${BASH_REMATCH[1]}"
            local value="${BASH_REMATCH[2]}"
            
            # Elimină ghilimele
            value="${value#\"}"
            value="${value%\"}"
            value="${value#\'}"
            value="${value%\'}"
            
            # Setează variabila
            export "$key=$value"
            log_debug "Config: $key = $value"
        fi
    done < "$config_file"
    
    return 0
}

# Parsează argumente command line
# Utilizare: parse_args "$@"
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -c|--config)
                CONFIG_FILE="$2"
                shift 2
                ;;
            --cpu-threshold)
                THRESHOLD_CPU="$2"
                shift 2
                ;;
            --mem-threshold)
                THRESHOLD_MEM="$2"
                shift 2
                ;;
            --disk-threshold)
                THRESHOLD_DISK="$2"
                shift 2
                ;;
            -i|--interval)
                MONITOR_INTERVAL="$2"
                shift 2
                ;;
            -l|--log-file)
                LOG_FILE="$2"
                shift 2
                ;;
            --log-level)
                LOG_LEVEL="$2"
                shift 2
                ;;
            -e|--email)
                NOTIFY_EMAIL="$2"
                shift 2
                ;;
            -d|--daemon)
                DAEMON_MODE="true"
                shift
                ;;
            -n|--dry-run)
                DRY_RUN="true"
                shift
                ;;
            -v|--verbose)
                VERBOSE="true"
                LOG_LEVEL="DEBUG"
                shift
                ;;
            -o|--output)
                OUTPUT_FORMAT="$2"
                shift 2
                ;;
            --exclude-mount)
                DISK_EXCLUDE_MOUNTS+=("$2")
                shift 2
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            --version)
                show_version
                exit 0
                ;;
            --)
                shift
                break
                ;;
            -*)
                log_error "Opțiune necunoscută: $1"
                show_help
                exit 1
                ;;
            *)
                # Argument pozițional
                shift
                ;;
        esac
    done
}

#------------------------------------------------------------------------------
# VALIDARE CONFIGURARE
#------------------------------------------------------------------------------

# Validează toate setările de configurare
validate_config() {
    local errors=0
    
    # Validare thresholds
    for threshold_var in THRESHOLD_CPU THRESHOLD_MEM THRESHOLD_DISK THRESHOLD_SWAP; do
        local value="${!threshold_var}"
        if ! is_integer "$value" || ! in_range "$value" 0 100; then
            log_error "Valoare invalidă pentru $threshold_var: $value (trebuie să fie 0-100)"
            ((errors++))
        fi
    done
    
    # Validare interval
    if ! is_integer "$MONITOR_INTERVAL" || [[ $MONITOR_INTERVAL -lt 1 ]]; then
        log_error "Interval de monitorizare invalid: $MONITOR_INTERVAL (trebuie să fie >= 1)"
        ((errors++))
    fi
    
    # Validare log level
    case "$LOG_LEVEL" in
        DEBUG|INFO|WARN|ERROR|FATAL) ;;
        *)
            log_error "Nivel de logging invalid: $LOG_LEVEL"
            ((errors++))
            ;;
    esac
    
    # Validare output format
    case "$OUTPUT_FORMAT" in
        text|json|csv) ;;
        *)
            log_error "Format output invalid: $OUTPUT_FORMAT (trebuie: text, json, csv)"
            ((errors++))
            ;;
    esac
    
    # Validare email (dacă e setat)
    if [[ -n "$NOTIFY_EMAIL" ]] && ! [[ "$NOTIFY_EMAIL" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
        log_warn "Format email posibil invalid: $NOTIFY_EMAIL"
    fi
    
    # Creează directoare necesare
    for dir in "$LOG_DIR" "$RUN_DIR"; do
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir" 2>/dev/null || {
                log_error "Nu pot crea directorul: $dir"
                ((errors++))
            }
        fi
    done
    
    return $errors
}

#------------------------------------------------------------------------------
# AFIȘARE CONFIGURARE
#------------------------------------------------------------------------------

# Afișează configurarea curentă
show_config() {
    cat << EOF
=== CONFIGURARE CURENTĂ ===

THRESHOLDS:
  CPU:        ${THRESHOLD_CPU}%
  Memorie:    ${THRESHOLD_MEM}%
  Disk:       ${THRESHOLD_DISK}%
  Swap:       ${THRESHOLD_SWAP}%
  Load Mult:  ${THRESHOLD_LOAD_MULT}x

MONITORIZARE:
  Interval:   ${MONITOR_INTERVAL}s
  Daemon:     ${DAEMON_MODE}
  Dry-run:    ${DRY_RUN}
  Output:     ${OUTPUT_FORMAT}

LOGGING:
  Fișier:     ${LOG_FILE:-<stdout>}
  Nivel:      ${LOG_LEVEL}
  Max size:   ${LOG_MAX_SIZE} bytes
  Rotații:    ${LOG_ROTATE_COUNT}

NOTIFICĂRI:
  Email:      ${NOTIFY_EMAIL:-<nesetat>}
  Slack:      ${NOTIFY_SLACK_WEBHOOK:+<setat>}${NOTIFY_SLACK_WEBHOOK:-<nesetat>}
  Recovery:   ${NOTIFY_ON_RECOVERY}

PATHS:
  Script:     ${SCRIPT_DIR:-<nedetectat>}
  Config:     ${CONFIG_FILE:-$DEFAULT_CONFIG_FILE}
  Lock:       ${LOCK_FILE}

EXCLUDERI DISK:
  ${DISK_EXCLUDE_MOUNTS[*]:-<niciuna>}

===========================
EOF
}

# Afișează help
show_help() {
    cat << EOF
System Monitor - Monitorizare resurse sistem

UTILIZARE:
    $(basename "$0") [opțiuni]

OPȚIUNI:
    -c, --config FILE       Fișier de configurare
    --cpu-threshold N       Threshold alertă CPU (default: ${THRESHOLD_CPU}%)
    --mem-threshold N       Threshold alertă memorie (default: ${THRESHOLD_MEM}%)
    --disk-threshold N      Threshold alertă disk (default: ${THRESHOLD_DISK}%)
    -i, --interval N        Interval monitorizare în secunde (default: ${MONITOR_INTERVAL})
    -l, --log-file FILE     Fișier pentru loguri
    --log-level LEVEL       Nivel logging: DEBUG, INFO, WARN, ERROR (default: ${LOG_LEVEL})
    -e, --email ADDRESS     Adresă email pentru notificări
    -d, --daemon            Rulează în mod daemon
    -n, --dry-run           Doar afișează, nu trimite notificări
    -v, --verbose           Output detaliat (activează DEBUG)
    -o, --output FORMAT     Format output: text, json, csv (default: ${OUTPUT_FORMAT})
    --exclude-mount PATH    Exclude mount point din monitorizare
    -h, --help              Afișează acest mesaj
    --version               Afișează versiunea

FIȘIER CONFIGURARE:
    Formatul este KEY=VALUE, câte o setare pe linie.
    Locații verificate: ./etc/monitor.conf, /etc/sysmonitor.conf
    
EXEMPLE:
    # Monitorizare single-shot
    $(basename "$0")
    
    # Daemon cu notificări email
    $(basename "$0") -d -e admin@example.com
    
    # Thresholds personalizate
    $(basename "$0") --cpu-threshold 90 --disk-threshold 95
    
    # Output JSON
    $(basename "$0") -o json

ENVIRONMENT VARIABLES:
    THRESHOLD_CPU, THRESHOLD_MEM, THRESHOLD_DISK
    MONITOR_INTERVAL, LOG_FILE, LOG_LEVEL
    NOTIFY_EMAIL, NOTIFY_SLACK_WEBHOOK

EXIT CODES:
    0 - Succes, toate resursele OK
    1 - Eroare de configurare
    2 - Cel puțin o alertă activă
    3 - Eroare fatală

AUTOR: ASE București - CSIE | Sisteme de Operare
EOF
}

# Afișează versiunea
show_version() {
    echo "System Monitor v1.0.0"
    echo "Core library: v${CORE_VERSION:-unknown}"
    echo "Utils library: v${UTILS_VERSION:-unknown}"
    echo "Config library: v${CONFIG_VERSION}"
}

#------------------------------------------------------------------------------
# EXPORT CONFIGURARE (pentru JSON)
#------------------------------------------------------------------------------

# Exportă configurarea în format JSON
export_config_json() {
    cat << EOF
{
  "thresholds": {
    "cpu": ${THRESHOLD_CPU},
    "memory": ${THRESHOLD_MEM},
    "disk": ${THRESHOLD_DISK},
    "swap": ${THRESHOLD_SWAP},
    "load_multiplier": ${THRESHOLD_LOAD_MULT}
  },
  "monitoring": {
    "interval": ${MONITOR_INTERVAL},
    "daemon_mode": ${DAEMON_MODE},
    "dry_run": ${DRY_RUN},
    "output_format": "${OUTPUT_FORMAT}"
  },
  "logging": {
    "file": "${LOG_FILE}",
    "level": "${LOG_LEVEL}",
    "max_size": ${LOG_MAX_SIZE},
    "rotate_count": ${LOG_ROTATE_COUNT}
  },
  "notifications": {
    "email": "${NOTIFY_EMAIL}",
    "slack_webhook": "${NOTIFY_SLACK_WEBHOOK:+true}${NOTIFY_SLACK_WEBHOOK:-false}",
    "notify_on_recovery": ${NOTIFY_ON_RECOVERY}
  }
}
EOF
}

#------------------------------------------------------------------------------
# INIȚIALIZARE
#------------------------------------------------------------------------------

# Funcție de inițializare completă
# Utilizare: init_config "$@"
init_config() {
    # 1. Setup paths
    _setup_paths
    
    # 2. Încarcă fișier de configurare default
    if [[ -f "$DEFAULT_CONFIG_FILE" ]]; then
        load_config_file "$DEFAULT_CONFIG_FILE"
    fi
    
    # 3. Parsează argumentele (pot suprascrie config file)
    parse_args "$@"
    
    # 4. Încarcă fișier de configurare specificat
    if [[ -n "${CONFIG_FILE:-}" ]] && [[ "$CONFIG_FILE" != "$DEFAULT_CONFIG_FILE" ]]; then
        load_config_file "$CONFIG_FILE"
    fi
    
    # 5. Validează configurarea finală
    if ! validate_config; then
        log_error "Configurare invalidă"
        return 1
    fi
    
    # 6. Setări verbose
    if [[ "$VERBOSE" == "true" ]]; then
        LOG_LEVEL="DEBUG"
        show_config
    fi
    
    log_debug "Configurare inițializată cu succes"
    return 0
}

log_debug "config.sh v${CONFIG_VERSION} încărcat"
