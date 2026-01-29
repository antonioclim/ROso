#!/bin/bash
#===============================================================================
# INSTALL.SH - Instalare Automată Proiecte CAPSTONE
#===============================================================================
# Scop: Instalează toate cele 3 proiecte (monitor, backup, deployer) în sistem
# Utilizare: sudo ./install.sh [--prefix=/usr/local] [--user=claude]
# Autor: Seminarul 11-12 CAPSTONE - Sisteme de Operare ASE București
#===============================================================================

set -euo pipefail

#-------------------------------------------------------------------------------
# CONSTANTE
#-------------------------------------------------------------------------------
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECTS_DIR="${SCRIPT_DIR}/projects"
readonly VERSION="1.0.0"

# Directoare instalare implicite
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
INSTALL_USER="${SUDO_USER:-$(whoami)}"
INSTALL_GROUP="${SUDO_USER:-$(whoami)}"
DRY_RUN=false
VERBOSE=false
FORCE=false

# Proiecte de instalat
INSTALL_MONITOR=true
INSTALL_BACKUP=true
INSTALL_DEPLOYER=true

#-------------------------------------------------------------------------------
# FUNCȚII UTILITATE
#-------------------------------------------------------------------------------

print_banner() {
    echo -e "${CYAN}"
    cat << 'EOF'
╔═══════════════════════════════════════════════════════════════════════╗
║              CAPSTONE PROJECTS - INSTALLER v1.0.0                     ║
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

run_cmd() {
    local cmd="$1"
    local description="${2:-Running command}"
    
    log_verbose "$description: $cmd"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo -e "${YELLOW}[DRY-RUN]${NC} Would execute: $cmd"
        return 0
    fi
    
    if ! eval "$cmd"; then
        log_error "Command failed: $cmd"
        return 1
    fi
}

#-------------------------------------------------------------------------------
# VERIFICĂRI PRELIMINARE
#-------------------------------------------------------------------------------

check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_warning "Rulați ca root pentru instalare în directoare sistem"
        log_info "Sau folosiți --prefix pentru instalare în home directory"
        
        if [[ "$PREFIX" == "$DEFAULT_PREFIX" ]]; then
            die "Instalarea în $PREFIX necesită permisiuni root"
        fi
    fi
}

check_dependencies() {
    log_info "Verificare dependențe..."
    
    local missing=()
    local required_commands=(bash tar gzip find mkdir chmod chown)
    local optional_commands=(bzip2 xz zstd md5sum sha256sum systemctl docker)
    
    # Verificare comenzi obligatorii
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &>/dev/null; then
            missing+=("$cmd")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        die "Comenzi lipsă: ${missing[*]}"
    fi
    
    log_success "Dependențe obligatorii: OK"
    
    # Verificare comenzi opționale
    local optional_missing=()
    for cmd in "${optional_commands[@]}"; do
        if ! command -v "$cmd" &>/dev/null; then
            optional_missing+=("$cmd")
        fi
    done
    
    if [[ ${#optional_missing[@]} -gt 0 ]]; then
        log_warning "Comenzi opționale lipsă: ${optional_missing[*]}"
        log_info "Unele funcționalități vor fi limitate"
    fi
}

check_projects() {
    log_info "Verificare proiecte disponibile..."
    
    local available=0
    
    if [[ -d "${PROJECTS_DIR}/monitor" ]]; then
        log_success "Monitor: găsit"
        ((available++))
    else
        log_warning "Monitor: nu a fost găsit"
        INSTALL_MONITOR=false
    fi
    
    if [[ -d "${PROJECTS_DIR}/backup" ]]; then
        log_success "Backup: găsit"
        ((available++))
    else
        log_warning "Backup: nu a fost găsit"
        INSTALL_BACKUP=false
    fi
    
    if [[ -d "${PROJECTS_DIR}/deployer" ]]; then
        log_success "Deployer: găsit"
        ((available++))
    else
        log_warning "Deployer: nu a fost găsit"
        INSTALL_DEPLOYER=false
    fi
    
    if [[ $available -eq 0 ]]; then
        die "Niciun proiect găsit în ${PROJECTS_DIR}"
    fi
}

#-------------------------------------------------------------------------------
# FUNCȚII INSTALARE
#-------------------------------------------------------------------------------

create_directories() {
    log_info "Creare structură directoare..."
    
    local dirs=(
        "${PREFIX}/bin"
        "${PREFIX}/lib/capstone"
        "${PREFIX}/share/capstone/doc"
        "${CONFIG_DIR}/capstone"
        "${LOG_DIR}/capstone"
        "${DATA_DIR}/capstone"
    )
    
    for dir in "${dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            run_cmd "mkdir -p '$dir'" "Creare director $dir"
            log_verbose "Creat: $dir"
        fi
    done
    
    # Setare permisiuni
    run_cmd "chmod 755 '${PREFIX}/bin'" "Setare permisiuni bin"
    run_cmd "chmod 755 '${PREFIX}/lib/capstone'" "Setare permisiuni lib"
    run_cmd "chmod 755 '${CONFIG_DIR}/capstone'" "Setare permisiuni config"
    run_cmd "chmod 750 '${LOG_DIR}/capstone'" "Setare permisiuni log"
    run_cmd "chmod 750 '${DATA_DIR}/capstone'" "Setare permisiuni data"
    
    log_success "Directoare create"
}

install_monitor() {
    [[ "$INSTALL_MONITOR" != "true" ]] && return 0
    
    log_info "Instalare Monitor..."
    
    local src="${PROJECTS_DIR}/monitor"
    local lib_dest="${PREFIX}/lib/capstone/monitor"
    local bin_dest="${PREFIX}/bin"
    local config_dest="${CONFIG_DIR}/capstone"
    
    # Creare directoare specifice
    run_cmd "mkdir -p '$lib_dest'" "Creare director lib monitor"
    run_cmd "mkdir -p '${LOG_DIR}/capstone/monitor'" "Creare director log monitor"
    run_cmd "mkdir -p '${DATA_DIR}/capstone/monitor'" "Creare director data monitor"
    
    # Copiere biblioteci
    if [[ -d "${src}/lib" ]]; then
        run_cmd "cp -r '${src}/lib/'* '$lib_dest/'" "Copiere biblioteci"
    fi
    
    # Copiere script principal
    if [[ -f "${src}/monitor.sh" ]]; then
        run_cmd "cp '${src}/monitor.sh' '$lib_dest/'" "Copiere script principal"
        run_cmd "chmod 755 '$lib_dest/monitor.sh'" "Setare permisiuni executabile"
    fi
    
    # Instalare wrapper
    cat > "${bin_dest}/sysmonitor" << EOF
#!/bin/bash
# SysMonitor - System Monitoring Tool
# Wrapper generat de installer

export MONITOR_LIB_DIR="${lib_dest}"
export MONITOR_CONFIG_DIR="${config_dest}"
export MONITOR_LOG_DIR="${LOG_DIR}/capstone/monitor"
export MONITOR_DATA_DIR="${DATA_DIR}/capstone/monitor"

exec "${lib_dest}/monitor.sh" "\$@"
EOF
    run_cmd "chmod 755 '${bin_dest}/sysmonitor'" "Setare permisiuni wrapper"
    
    # Copiere configurație (fără suprascriere)
    if [[ -f "${src}/etc/monitor.conf" ]]; then
        if [[ ! -f "${config_dest}/monitor.conf" ]] || [[ "$FORCE" == "true" ]]; then
            run_cmd "cp '${src}/etc/monitor.conf' '${config_dest}/'" "Copiere configurație"
        else
            log_warning "Configurație existentă păstrată: ${config_dest}/monitor.conf"
        fi
    fi
    
    log_success "Monitor instalat: ${bin_dest}/sysmonitor"
}

install_backup() {
    [[ "$INSTALL_BACKUP" != "true" ]] && return 0
    
    log_info "Instalare Backup..."
    
    local src="${PROJECTS_DIR}/backup"
    local lib_dest="${PREFIX}/lib/capstone/backup"
    local bin_dest="${PREFIX}/bin"
    local config_dest="${CONFIG_DIR}/capstone"
    
    # Creare directoare specifice
    run_cmd "mkdir -p '$lib_dest'" "Creare director lib backup"
    run_cmd "mkdir -p '${LOG_DIR}/capstone/backup'" "Creare director log backup"
    run_cmd "mkdir -p '${DATA_DIR}/capstone/backup'" "Creare director data backup"
    
    # Copiere biblioteci
    if [[ -d "${src}/lib" ]]; then
        run_cmd "cp -r '${src}/lib/'* '$lib_dest/'" "Copiere biblioteci"
    fi
    
    # Copiere script principal
    if [[ -f "${src}/backup.sh" ]]; then
        run_cmd "cp '${src}/backup.sh' '$lib_dest/'" "Copiere script principal"
        run_cmd "chmod 755 '$lib_dest/backup.sh'" "Setare permisiuni executabile"
    fi
    
    # Instalare wrapper
    cat > "${bin_dest}/sysbackup" << EOF
#!/bin/bash
# SysBackup - System Backup Tool
# Wrapper generat de installer

export BACKUP_LIB_DIR="${lib_dest}"
export BACKUP_CONFIG_DIR="${config_dest}"
export BACKUP_LOG_DIR="${LOG_DIR}/capstone/backup"
export BACKUP_DATA_DIR="${DATA_DIR}/capstone/backup"

exec "${lib_dest}/backup.sh" "\$@"
EOF
    run_cmd "chmod 755 '${bin_dest}/sysbackup'" "Setare permisiuni wrapper"
    
    # Copiere configurație
    if [[ -f "${src}/etc/backup.conf" ]]; then
        if [[ ! -f "${config_dest}/backup.conf" ]] || [[ "$FORCE" == "true" ]]; then
            run_cmd "cp '${src}/etc/backup.conf' '${config_dest}/'" "Copiere configurație"
        else
            log_warning "Configurație existentă păstrată: ${config_dest}/backup.conf"
        fi
    fi
    
    log_success "Backup instalat: ${bin_dest}/sysbackup"
}

install_deployer() {
    [[ "$INSTALL_DEPLOYER" != "true" ]] && return 0
    
    log_info "Instalare Deployer..."
    
    local src="${PROJECTS_DIR}/deployer"
    local lib_dest="${PREFIX}/lib/capstone/deployer"
    local bin_dest="${PREFIX}/bin"
    local config_dest="${CONFIG_DIR}/capstone"
    
    # Creare directoare specifice
    run_cmd "mkdir -p '$lib_dest'" "Creare director lib deployer"
    run_cmd "mkdir -p '$lib_dest/hooks'" "Creare director hooks"
    run_cmd "mkdir -p '${LOG_DIR}/capstone/deployer'" "Creare director log deployer"
    run_cmd "mkdir -p '${DATA_DIR}/capstone/deployer/releases'" "Creare director releases"
    
    # Copiere biblioteci
    if [[ -d "${src}/lib" ]]; then
        run_cmd "cp -r '${src}/lib/'* '$lib_dest/'" "Copiere biblioteci"
    fi
    
    # Copiere hooks exemple
    if [[ -d "${src}/hooks" ]]; then
        run_cmd "cp -r '${src}/hooks/'* '$lib_dest/hooks/' 2>/dev/null || true" "Copiere hooks"
    fi
    
    # Copiere script principal
    if [[ -f "${src}/deployer.sh" ]]; then
        run_cmd "cp '${src}/deployer.sh' '$lib_dest/'" "Copiere script principal"
        run_cmd "chmod 755 '$lib_dest/deployer.sh'" "Setare permisiuni executabile"
    fi
    
    # Instalare wrapper
    cat > "${bin_dest}/sysdeploy" << EOF
#!/bin/bash
# SysDeploy - System Deployment Tool
# Wrapper generat de installer

export DEPLOYER_LIB_DIR="${lib_dest}"
export DEPLOYER_CONFIG_DIR="${config_dest}"
export DEPLOYER_LOG_DIR="${LOG_DIR}/capstone/deployer"
export DEPLOYER_DATA_DIR="${DATA_DIR}/capstone/deployer"
export DEPLOYER_HOOKS_DIR="${lib_dest}/hooks"

exec "${lib_dest}/deployer.sh" "\$@"
EOF
    run_cmd "chmod 755 '${bin_dest}/sysdeploy'" "Setare permisiuni wrapper"
    
    # Copiere configurație
    if [[ -f "${src}/etc/deployer.conf" ]]; then
        if [[ ! -f "${config_dest}/deployer.conf" ]] || [[ "$FORCE" == "true" ]]; then
            run_cmd "cp '${src}/etc/deployer.conf' '${config_dest}/'" "Copiere configurație"
        else
            log_warning "Configurație existentă păstrată: ${config_dest}/deployer.conf"
        fi
    fi
    
    log_success "Deployer instalat: ${bin_dest}/sysdeploy"
}

install_documentation() {
    log_info "Instalare documentație..."
    
    local doc_dest="${PREFIX}/share/capstone/doc"
    
    # Copiere README-uri
    for project in monitor backup deployer; do
        local readme="${PROJECTS_DIR}/${project}/README.md"
        if [[ -f "$readme" ]]; then
            run_cmd "cp '$readme' '${doc_dest}/${project}_README.md'" "Copiere README $project"
        fi
    done
    
    # Creare fișier VERSION
    echo "$VERSION" > "${doc_dest}/VERSION"
    
    log_success "Documentație instalată în: $doc_dest"
}

set_permissions() {
    log_info "Configurare permisiuni finale..."
    
    # Permisiuni pentru directoare log și data
    if [[ $EUID -eq 0 ]]; then
        run_cmd "chown -R ${INSTALL_USER}:${INSTALL_GROUP} '${LOG_DIR}/capstone'" "Setare owner log"
        run_cmd "chown -R ${INSTALL_USER}:${INSTALL_GROUP} '${DATA_DIR}/capstone'" "Setare owner data"
    fi
    
    log_success "Permisiuni configurate"
}

create_uninstall_script() {
    log_info "Generare script dezinstalare..."
    
    local uninstall_script="${PREFIX}/share/capstone/uninstall.sh"
    
    cat > "$uninstall_script" << EOF
#!/bin/bash
# Uninstall script generat automat
# Data: $(date)
# Prefix: $PREFIX

set -e

echo "Dezinstalare CAPSTONE Projects..."

# Ștergere binare
rm -f "${PREFIX}/bin/sysmonitor"
rm -f "${PREFIX}/bin/sysbackup"
rm -f "${PREFIX}/bin/sysdeploy"

# Ștergere biblioteci
rm -rf "${PREFIX}/lib/capstone"

# Ștergere documentație
rm -rf "${PREFIX}/share/capstone"

# Configurații și date (opțional - comentate implicit)
# rm -rf "${CONFIG_DIR}/capstone"
# rm -rf "${LOG_DIR}/capstone"
# rm -rf "${DATA_DIR}/capstone"

echo "Dezinstalare completă!"
echo "Observație: Configurațiile și datele au fost păstrate în:"
echo "  - ${CONFIG_DIR}/capstone"
echo "  - ${LOG_DIR}/capstone"
echo "  - ${DATA_DIR}/capstone"
EOF
    
    run_cmd "chmod 755 '$uninstall_script'" "Setare permisiuni uninstall"
    
    log_success "Script dezinstalare: $uninstall_script"
}

#-------------------------------------------------------------------------------
# HELP ȘI ARGUMENTE
#-------------------------------------------------------------------------------

show_help() {
    cat << EOF
CAPSTONE Projects Installer v${VERSION}

Utilizare: $(basename "$0") [OPȚIUNI]

Opțiuni:
  --prefix=DIR       Director instalare (implicit: $DEFAULT_PREFIX)
  --config-dir=DIR   Director configurări (implicit: $DEFAULT_CONFIG_DIR)
  --log-dir=DIR      Director loguri (implicit: $DEFAULT_LOG_DIR)
  --data-dir=DIR     Director date (implicit: $DEFAULT_DATA_DIR)
  --user=USER        User pentru permisiuni (implicit: \$SUDO_USER)
  --group=GROUP      Grup pentru permisiuni
  
  --only-monitor     Instalează doar Monitor
  --only-backup      Instalează doar Backup
  --only-deployer    Instalează doar Deployer
  
  --force            Suprascrie configurații existente
  --dry-run          Afișează comenzile fără a le executa
  --verbose          Mod verbose
  --help             Afișează acest ajutor

Exemple:
  sudo ./install.sh                         # Instalare completă în /usr/local
  ./install.sh --prefix=\$HOME/.local        # Instalare în home directory
  sudo ./install.sh --only-monitor          # Doar Monitor
  ./install.sh --dry-run --verbose          # Simulare cu detalii
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
            --user=*)
                INSTALL_USER="${1#*=}"
                shift
                ;;
            --group=*)
                INSTALL_GROUP="${1#*=}"
                shift
                ;;
            --only-monitor)
                INSTALL_BACKUP=false
                INSTALL_DEPLOYER=false
                shift
                ;;
            --only-backup)
                INSTALL_MONITOR=false
                INSTALL_DEPLOYER=false
                shift
                ;;
            --only-deployer)
                INSTALL_MONITOR=false
                INSTALL_BACKUP=false
                shift
                ;;
            --force)
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
    echo -e "${GREEN}                    INSTALARE COMPLETĂ!${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "Locații instalare:"
    echo "  Binare:      ${PREFIX}/bin/"
    echo "  Biblioteci:  ${PREFIX}/lib/capstone/"
    echo "  Configurări: ${CONFIG_DIR}/capstone/"
    echo "  Loguri:      ${LOG_DIR}/capstone/"
    echo "  Date:        ${DATA_DIR}/capstone/"
    echo ""
    echo "Comenzi disponibile:"
    [[ "$INSTALL_MONITOR" == "true" ]] && echo "  sysmonitor  - System Monitoring"
    [[ "$INSTALL_BACKUP" == "true" ]] && echo "  sysbackup   - System Backup"
    [[ "$INSTALL_DEPLOYER" == "true" ]] && echo "  sysdeploy   - System Deployment"
    echo ""
    echo "Dezinstalare:"
    echo "  ${PREFIX}/share/capstone/uninstall.sh"
    echo ""
}

main() {
    parse_args "$@"
    
    print_banner
    
    log_info "Început instalare CAPSTONE Projects v${VERSION}"
    log_info "Prefix: $PREFIX"
    [[ "$DRY_RUN" == "true" ]] && log_warning "MOD DRY-RUN ACTIV"
    
    # Verificări
    check_root
    check_dependencies
    check_projects
    
    echo ""
    
    # Instalare
    create_directories
    install_monitor
    install_backup
    install_deployer
    install_documentation
    set_permissions
    create_uninstall_script
    
    show_summary
}

main "$@"
