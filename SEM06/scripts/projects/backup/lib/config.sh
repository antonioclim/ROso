#!/bin/bash
#==============================================================================
# config.sh - Gestiunea configurării pentru Backup System
#==============================================================================
# DESCRIERE:
#   Funcții pentru încărcarea, validarea și gestiunea configurării backup.
#
# AUTOR: ASE București - CSIE | Sisteme de Operare
# VERSIUNE: 1.0.0
#==============================================================================

readonly CONFIG_VERSION="1.0.0"

#------------------------------------------------------------------------------
# VALORI DEFAULT
#------------------------------------------------------------------------------

# Surse de backup (array)
declare -ga BACKUP_SOURCES=()

# Destinație
declare -g BACKUP_DEST="${BACKUP_DEST:-./backups}"

# Compresie: gz, bz2, xz, zstd, none
declare -g COMPRESSION="${COMPRESSION:-gz}"

# Retenție (număr de backup-uri păstrate)
declare -g RETENTION_DAILY="${RETENTION_DAILY:-7}"
declare -g RETENTION_WEEKLY="${RETENTION_WEEKLY:-4}"
declare -g RETENTION_MONTHLY="${RETENTION_MONTHLY:-12}"

# Tip backup forțat (altfel auto-detect)
declare -g BACKUP_TYPE="${BACKUP_TYPE:-auto}"

# Excluderi (patterns)
declare -ga EXCLUDE_PATTERNS=()

# Notificări
declare -g NOTIFY_EMAIL="${NOTIFY_EMAIL:-}"
declare -g NOTIFY_ON_SUCCESS="${NOTIFY_ON_SUCCESS:-false}"
declare -g NOTIFY_ON_ERROR="${NOTIFY_ON_ERROR:-true}"

# Verificări
declare -g VERIFY_BACKUP="${VERIFY_BACKUP:-true}"
declare -g SAVE_CHECKSUM="${SAVE_CHECKSUM:-true}"
declare -g CHECKSUM_ALGORITHM="${CHECKSUM_ALGORITHM:-sha256}"

# Logging
declare -g LOG_FILE="${LOG_FILE:-}"
declare -g LOG_LEVEL="${LOG_LEVEL:-INFO}"

# Opțiuni
declare -g DRY_RUN="${DRY_RUN:-false}"
declare -g VERBOSE="${VERBOSE:-false}"

# Lock
declare -g LOCK_FILE="${LOCK_FILE:-}"

# Prefix pentru nume backup
declare -g BACKUP_PREFIX="${BACKUP_PREFIX:-backup}"

#------------------------------------------------------------------------------
# SETUP PATHS
#------------------------------------------------------------------------------

_setup_backup_paths() {
    if [[ -z "${SCRIPT_DIR:-}" ]]; then
        SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[1]:-$0}")" && pwd)"
    fi
    
    readonly PROJECT_DIR="${SCRIPT_DIR}"
    readonly LIB_DIR="${PROJECT_DIR}/lib"
    readonly ETC_DIR="${PROJECT_DIR}/etc"
    readonly VAR_DIR="${PROJECT_DIR}/var"
    readonly LOG_DIR="${VAR_DIR}/log"
    readonly RUN_DIR="${VAR_DIR}/run"
    
    readonly DEFAULT_CONFIG_FILE="${ETC_DIR}/backup.conf"
    
    [[ -z "$LOCK_FILE" ]] && LOCK_FILE="${RUN_DIR}/backup.pid"
    [[ -z "$LOG_FILE" ]] && LOG_FILE="${LOG_DIR}/backup.log"
}

#------------------------------------------------------------------------------
# ÎNCĂRCARE CONFIGURARE
#------------------------------------------------------------------------------

load_config_file() {
    local config_file="${1:-$DEFAULT_CONFIG_FILE}"
    
    [[ -f "$config_file" ]] || { log_debug "Config nu există: $config_file"; return 0; }
    [[ -r "$config_file" ]] || { log_warn "Nu pot citi config: $config_file"; return 1; }
    
    log_info "Încarc configurarea din: $config_file"
    
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Skip comentarii și linii goale
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line// /}" ]] && continue
        
        # Curăță whitespace
        line="${line#"${line%%[![:space:]]*}"}"
        line="${line%"${line##*[![:space:]]}"}"
        
        # Parsează KEY=VALUE
        if [[ "$line" =~ ^([A-Za-z_][A-Za-z0-9_]*)=(.*)$ ]]; then
            local key="${BASH_REMATCH[1]}"
            local value="${BASH_REMATCH[2]}"
            
            # Elimină ghilimele
            value="${value#\"}"
            value="${value%\"}"
            value="${value#\'}"
            value="${value%\'}"
            
            # Tratare specială pentru array-uri
            case "$key" in
                BACKUP_SOURCES)
                    IFS=' ' read -ra BACKUP_SOURCES <<< "$value"
                    ;;
                EXCLUDE_PATTERNS)
                    IFS=' ' read -ra EXCLUDE_PATTERNS <<< "$value"
                    ;;
                *)
                    export "$key=$value"
                    ;;
            esac
            
            log_debug "Config: $key = $value"
        fi
    done < "$config_file"
    
    return 0
}

#------------------------------------------------------------------------------
# PARSARE ARGUMENTE
#------------------------------------------------------------------------------

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -c|--config)
                CONFIG_FILE="$2"
                shift 2
                ;;
            -s|--source)
                BACKUP_SOURCES+=("$2")
                shift 2
                ;;
            -d|--dest|--destination)
                BACKUP_DEST="$2"
                shift 2
                ;;
            -t|--type)
                BACKUP_TYPE="$2"
                shift 2
                ;;
            --compression)
                COMPRESSION="$2"
                shift 2
                ;;
            --retention-daily)
                RETENTION_DAILY="$2"
                shift 2
                ;;
            --retention-weekly)
                RETENTION_WEEKLY="$2"
                shift 2
                ;;
            --retention-monthly)
                RETENTION_MONTHLY="$2"
                shift 2
                ;;
            -x|--exclude)
                EXCLUDE_PATTERNS+=("$2")
                shift 2
                ;;
            --prefix)
                BACKUP_PREFIX="$2"
                shift 2
                ;;
            -e|--email)
                NOTIFY_EMAIL="$2"
                shift 2
                ;;
            --no-verify)
                VERIFY_BACKUP="false"
                shift
                ;;
            --no-checksum)
                SAVE_CHECKSUM="false"
                shift
                ;;
            -l|--log-file)
                LOG_FILE="$2"
                shift 2
                ;;
            --log-level)
                LOG_LEVEL="$2"
                shift 2
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
                # Argument pozițional - tratează ca sursă
                BACKUP_SOURCES+=("$1")
                shift
                ;;
        esac
    done
}

#------------------------------------------------------------------------------
# VALIDARE
#------------------------------------------------------------------------------

validate_config() {
    local errors=0
    
    # Verifică surse
    if [[ ${#BACKUP_SOURCES[@]} -eq 0 ]]; then
        log_error "Nicio sursă de backup specificată"
        ((errors++))
    else
        for source in "${BACKUP_SOURCES[@]}"; do
            if [[ ! -e "$source" ]]; then
                log_error "Sursa nu există: $source"
                ((errors++))
            fi
        done
    fi
    
    # Verifică/creează destinație
    if [[ -z "$BACKUP_DEST" ]]; then
        log_error "Destinația backup nu este specificată"
        ((errors++))
    else
        if [[ ! -d "$BACKUP_DEST" ]]; then
            if ! mkdir -p "$BACKUP_DEST" 2>/dev/null; then
                log_error "Nu pot crea directorul destinație: $BACKUP_DEST"
                ((errors++))
            else
                log_info "Director destinație creat: $BACKUP_DEST"
            fi
        fi
    fi
    
    # Verifică compresie
    case "$COMPRESSION" in
        gz|gzip|bz2|bzip2|xz|zstd|none|tar)
            ;;
        *)
            log_error "Tip compresie invalid: $COMPRESSION"
            ((errors++))
            ;;
    esac
    
    # Verifică retenție
    for var in RETENTION_DAILY RETENTION_WEEKLY RETENTION_MONTHLY; do
        local value="${!var}"
        if ! is_integer "$value" || [[ $value -lt 0 ]]; then
            log_error "Valoare retenție invalidă pentru $var: $value"
            ((errors++))
        fi
    done
    
    # Verifică tip backup
    case "$BACKUP_TYPE" in
        auto|daily|weekly|monthly|full)
            ;;
        *)
            log_error "Tip backup invalid: $BACKUP_TYPE"
            ((errors++))
            ;;
    esac
    
    # Creează directoare necesare
    for dir in "$LOG_DIR" "$RUN_DIR"; do
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir" 2>/dev/null || {
                log_warn "Nu pot crea directorul: $dir"
            }
        fi
    done
    
    return $errors
}

#------------------------------------------------------------------------------
# AFIȘARE
#------------------------------------------------------------------------------

show_config() {
    cat << EOF
=== CONFIGURARE BACKUP ===

SURSE:
$(printf '  - %s\n' "${BACKUP_SOURCES[@]:-<niciuna>}")

DESTINAȚIE:
  Path:        $BACKUP_DEST
  Prefix:      $BACKUP_PREFIX
  Compresie:   $COMPRESSION

TIP BACKUP:
  Tip:         $BACKUP_TYPE

RETENȚIE:
  Daily:       $RETENTION_DAILY
  Weekly:      $RETENTION_WEEKLY
  Monthly:     $RETENTION_MONTHLY

EXCLUDERI:
$(printf '  - %s\n' "${EXCLUDE_PATTERNS[@]:-<niciuna>}")

VERIFICĂRI:
  Verificare:  $VERIFY_BACKUP
  Checksum:    $SAVE_CHECKSUM ($CHECKSUM_ALGORITHM)

NOTIFICĂRI:
  Email:       ${NOTIFY_EMAIL:-<nesetat>}
  La succes:   $NOTIFY_ON_SUCCESS
  La eroare:   $NOTIFY_ON_ERROR

OPȚIUNI:
  Dry-run:     $DRY_RUN
  Verbose:     $VERBOSE
  Log level:   $LOG_LEVEL
  Log file:    ${LOG_FILE:-<stdout>}

==========================
EOF
}

show_help() {
    cat << EOF
Backup System - Sistem enterprise de backup

UTILIZARE:
    $(basename "$0") [opțiuni] [surse...]

OPȚIUNI PRINCIPALE:
    -s, --source PATH       Adaugă sursă de backup (poate fi repetat)
    -d, --dest PATH         Directorul destinație pentru backup-uri
    -t, --type TYPE         Tip backup: auto, daily, weekly, monthly, full
    --compression TYPE      Compresie: gz, bz2, xz, zstd, none (default: gz)

RETENȚIE:
    --retention-daily N     Păstrează N backup-uri daily (default: 7)
    --retention-weekly N    Păstrează N backup-uri weekly (default: 4)
    --retention-monthly N   Păstrează N backup-uri monthly (default: 12)

EXCLUDERI:
    -x, --exclude PATTERN   Exclude pattern din backup (poate fi repetat)
    --prefix NAME           Prefix pentru nume backup (default: backup)

VERIFICĂRI:
    --no-verify             Nu verifica integritatea backup-ului
    --no-checksum           Nu salva fișier checksum

NOTIFICĂRI:
    -e, --email ADDRESS     Adresă email pentru notificări

LOGGING:
    -l, --log-file FILE     Fișier pentru loguri
    --log-level LEVEL       Nivel: DEBUG, INFO, WARN, ERROR

GENERALE:
    -c, --config FILE       Fișier de configurare
    -n, --dry-run           Simulare, nu execută efectiv
    -v, --verbose           Output detaliat
    -h, --help              Afișează acest mesaj
    --version               Afișează versiunea

EXEMPLE:
    # Backup simplu
    $(basename "$0") -s /home -d /backup
    
    # Backup cu excluderi
    $(basename "$0") -s /home -d /backup -x '*.tmp' -x 'cache'
    
    # Backup cu notificări
    $(basename "$0") -s /var/www -d /backup -e admin@example.com
    
    # Dry-run pentru testare
    $(basename "$0") -s /data -d /backup -n -v

TIPURI DE BACKUP:
    auto      - Detectează automat: monthly pe 1, weekly duminica, altfel daily
    daily     - Backup zilnic, retenție scurtă
    weekly    - Backup săptămânal
    monthly   - Backup lunar, retenție lungă
    full      - Backup complet fără rotație

FIȘIER CONFIGURARE:
    Format: KEY=VALUE, un parametru pe linie.
    Locație default: ./etc/backup.conf

EXIT CODES:
    0 - Succes
    1 - Eroare configurare
    2 - Eroare la backup
    3 - Eroare la verificare

AUTOR: ASE București - CSIE | Sisteme de Operare
EOF
}

show_version() {
    echo "Backup System v1.0.0"
    echo "Core: v${CORE_VERSION:-unknown}"
    echo "Utils: v${UTILS_VERSION:-unknown}"
    echo "Config: v${CONFIG_VERSION}"
}

#------------------------------------------------------------------------------
# INIȚIALIZARE
#------------------------------------------------------------------------------

init_config() {
    _setup_backup_paths
    
    # Încarcă config default dacă există
    [[ -f "$DEFAULT_CONFIG_FILE" ]] && load_config_file "$DEFAULT_CONFIG_FILE"
    
    # Parsează argumentele
    parse_args "$@"
    
    # Încarcă config custom dacă specificat
    if [[ -n "${CONFIG_FILE:-}" ]] && [[ "$CONFIG_FILE" != "$DEFAULT_CONFIG_FILE" ]]; then
        load_config_file "$CONFIG_FILE"
    fi
    
    # Validează
    if ! validate_config; then
        return 1
    fi
    
    # Setări verbose
    if [[ "$VERBOSE" == "true" ]]; then
        show_config
    fi
    
    log_debug "Configurare inițializată cu succes"
    return 0
}

log_debug "config.sh v${CONFIG_VERSION} încărcat (backup)"
