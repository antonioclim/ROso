#!/bin/bash
#===============================================================================
# UNINSTALL.SH - Dezinstalare Proiecte CAPSTONE
#===============================================================================
# Scop: Dezinstalează toate componentele instalate de install.sh
# Utilizare: sudo ./uninstall.sh [--prefix=/usr/local] [--purge]
# Autor: Seminarul 11-12 CAPSTONE - Sisteme de Operare ASE București
#===============================================================================

set -euo pipefail

#-------------------------------------------------------------------------------
# CONSTANTE
#-------------------------------------------------------------------------------
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly VERSION="1.0.0"

# Directoare implicite (trebuie să corespundă cu cele din install.sh)
DEFAULT_PREFIX="/usr/local"
DEFAULT_CONFIG_DIR="/etc"
DEFAULT_LOG_DIR="/var/log"
DEFAULT_DATA_DIR="/var/lib"

# Culori
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

#-------------------------------------------------------------------------------
# VARIABILE CONFIGURABILE
#-------------------------------------------------------------------------------
PREFIX="$DEFAULT_PREFIX"
CONFIG_DIR="$DEFAULT_CONFIG_DIR"
LOG_DIR="$DEFAULT_LOG_DIR"
DATA_DIR="$DEFAULT_DATA_DIR"
DRY_RUN=false
PURGE=false
FORCE=false
VERBOSE=false

#-------------------------------------------------------------------------------
# FUNCȚII UTILITATE
#-------------------------------------------------------------------------------

print_banner() {
    echo -e "${YELLOW}"
    cat << 'EOF'
╔═══════════════════════════════════════════════════════════════════════╗
║              CAPSTONE PROJECTS - UNINSTALLER v1.0.0                   ║
║                  Sisteme de Operare ASE București                     ║
╚═══════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[OK]${NC}   $1"
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

log_verbose() {
    [[ "$VERBOSE" == "true" ]] && echo -e "${CYAN}[DEBUG]${NC} $1"
}

die() {
    log_error "$1"
    exit 1
}

confirm() {
    local prompt="$1"
    local default="${2:-n}"
    
    if [[ "$FORCE" == "true" ]]; then
        return 0
    fi
    
    local choice
    read -r -p "$prompt [y/N]: " choice
    
    case "$choice" in
        y|Y|yes|YES)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

safe_remove() {
    local path="$1"
    local description="${2:-$path}"
    
    if [[ ! -e "$path" ]]; then
        log_verbose "Nu există: $path"
        return 0
    fi
    
    log_verbose "Ștergere: $path"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo -e "${YELLOW}[DRY-RUN]${NC} Ar șterge: $path"
        return 0
    fi
    
    if rm -rf "$path" 2>/dev/null; then
        log_success "Șters: $description"
    else
        log_warning "Nu s-a putut șterge: $path"
    fi
}

#-------------------------------------------------------------------------------
# FUNCȚII DEZINSTALARE
#-------------------------------------------------------------------------------

check_installation() {
    log_info "Verificare instalare existentă..."
    
    local found=false
    
    # Verificare binare
    for bin in sysmonitor sysbackup sysdeploy; do
        if [[ -f "${PREFIX}/bin/$bin" ]]; then
            log_success "Găsit: ${PREFIX}/bin/$bin"
            found=true
        fi
    done
    
    # Verificare directoare
    if [[ -d "${PREFIX}/lib/capstone" ]]; then
        log_success "Găsit: ${PREFIX}/lib/capstone"
        found=true
    fi
    
    if [[ "$found" != "true" ]]; then
        log_warning "Nu s-a găsit nicio instalare în $PREFIX"
        return 1
    fi
    
    return 0
}

remove_binaries() {
    log_info "Ștergere binare..."
    
    safe_remove "${PREFIX}/bin/sysmonitor" "Binary sysmonitor"
    safe_remove "${PREFIX}/bin/sysbackup" "Binary sysbackup"
    safe_remove "${PREFIX}/bin/sysdeploy" "Binary sysdeploy"
}

remove_libraries() {
    log_info "Ștergere biblioteci..."
    
    safe_remove "${PREFIX}/lib/capstone" "Directorul biblioteci"
}

remove_documentation() {
    log_info "Ștergere documentație..."
    
    safe_remove "${PREFIX}/share/capstone" "Directorul documentație"
}

remove_configs() {
    log_info "Ștergere configurații..."
    
    if [[ -d "${CONFIG_DIR}/capstone" ]]; then
        if [[ "$PURGE" == "true" ]] || confirm "Ștergeți configurațiile din ${CONFIG_DIR}/capstone?"; then
            safe_remove "${CONFIG_DIR}/capstone" "Directorul configurații"
        else
            log_warning "Configurațiile păstrate în: ${CONFIG_DIR}/capstone"
        fi
    fi
}

remove_logs() {
    log_info "Ștergere loguri..."
    
    if [[ -d "${LOG_DIR}/capstone" ]]; then
        if [[ "$PURGE" == "true" ]] || confirm "Ștergeți logurile din ${LOG_DIR}/capstone?"; then
            safe_remove "${LOG_DIR}/capstone" "Directorul loguri"
        else
            log_warning "Logurile păstrate în: ${LOG_DIR}/capstone"
        fi
    fi
}

remove_data() {
    log_info "Ștergere date aplicație..."
    
    if [[ -d "${DATA_DIR}/capstone" ]]; then
        if [[ "$PURGE" == "true" ]] || confirm "Ștergeți datele din ${DATA_DIR}/capstone?"; then
            safe_remove "${DATA_DIR}/capstone" "Directorul date"
        else
            log_warning "Datele păstrate în: ${DATA_DIR}/capstone"
        fi
    fi
}

remove_systemd_units() {
    log_info "Verificare unități systemd..."
    
    local units=(
        "/etc/systemd/system/sysmonitor.service"
        "/etc/systemd/system/sysmonitor.timer"
        "/etc/systemd/system/sysbackup.service"
        "/etc/systemd/system/sysbackup.timer"
    )
    
    local found=false
    for unit in "${units[@]}"; do
        if [[ -f "$unit" ]]; then
            found=true
            
            # Oprire și dezactivare serviciu
            local unit_name=$(basename "$unit")
            
            if [[ "$DRY_RUN" != "true" ]]; then
                systemctl stop "$unit_name" 2>/dev/null || true
                systemctl disable "$unit_name" 2>/dev/null || true
            fi
            
            safe_remove "$unit" "Systemd unit $unit_name"
        fi
    done
    
    if [[ "$found" == "true" ]] && [[ "$DRY_RUN" != "true" ]]; then
        systemctl daemon-reload 2>/dev/null || true
    fi
}

#-------------------------------------------------------------------------------
# HELP ȘI ARGUMENTE
#-------------------------------------------------------------------------------

show_help() {
    cat << EOF
CAPSTONE Projects Uninstaller v${VERSION}

Utilizare: $(basename "$0") [OPȚIUNI]

Opțiuni:
  --prefix=DIR       Director instalare (implicit: $DEFAULT_PREFIX)
  --config-dir=DIR   Director configurări (implicit: $DEFAULT_CONFIG_DIR)
  --log-dir=DIR      Director loguri (implicit: $DEFAULT_LOG_DIR)
  --data-dir=DIR     Director date (implicit: $DEFAULT_DATA_DIR)
  
  --purge            Șterge și configurațiile, logurile și datele
  --force            Nu cere confirmare
  --dry-run          Afișează ce ar fi șters fără a executa
  --verbose          Mod verbose
  --help             Afișează acest ajutor

Exemple:
  sudo ./uninstall.sh                     # Dezinstalare standard
  sudo ./uninstall.sh --purge             # Dezinstalare completă
  ./uninstall.sh --prefix=\$HOME/.local    # Dezinstalare din home
  ./uninstall.sh --dry-run                # Simulare
EOF
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --prefix=*)
                PREFIX="${1#*=}"
                shift
                ;;
            --config-dir=*)
                CONFIG_DIR="${1#*=}"
                shift
                ;;
            --log-dir=*)
                LOG_DIR="${1#*=}"
                shift
                ;;
            --data-dir=*)
                DATA_DIR="${1#*=}"
                shift
                ;;
            --purge)
                PURGE=true
                shift
                ;;
            --force|-f)
                FORCE=true
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --verbose|-v)
                VERBOSE=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                log_error "Opțiune necunoscută: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

#-------------------------------------------------------------------------------
# MAIN
#-------------------------------------------------------------------------------

show_summary() {
    echo ""
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}                    DEZINSTALARE COMPLETĂ!${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    if [[ "$PURGE" != "true" ]]; then
        echo "Locații păstrate (pentru a le șterge, folosiți --purge):"
        [[ -d "${CONFIG_DIR}/capstone" ]] && echo "  - ${CONFIG_DIR}/capstone (configurații)"
        [[ -d "${LOG_DIR}/capstone" ]] && echo "  - ${LOG_DIR}/capstone (loguri)"
        [[ -d "${DATA_DIR}/capstone" ]] && echo "  - ${DATA_DIR}/capstone (date)"
        echo ""
    fi
}

main() {
    parse_args "$@"
    
    print_banner
    
    log_info "Început dezinstalare CAPSTONE Projects"
    log_info "Prefix: $PREFIX"
    [[ "$DRY_RUN" == "true" ]] && log_warning "MOD DRY-RUN ACTIV"
    [[ "$PURGE" == "true" ]] && log_warning "MOD PURGE ACTIV - toate datele vor fi șterse"
    
    echo ""
    
    # Verificare instalare
    if ! check_installation; then
        exit 0
    fi
    
    echo ""
    
    # Confirmare
    if ! confirm "Continuați cu dezinstalarea?" && [[ "$FORCE" != "true" ]]; then
        log_info "Dezinstalare anulată"
        exit 0
    fi
    
    echo ""
    
    # Dezinstalare
    remove_systemd_units
    remove_binaries
    remove_libraries
    remove_documentation
    remove_configs
    remove_logs
    remove_data
    
    show_summary
}

main "$@"
