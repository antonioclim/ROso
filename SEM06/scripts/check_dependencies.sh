#!/bin/bash
#===============================================================================
# CHECK_DEPENDENCIES.SH - Verificare Dependențe Sistem
#===============================================================================
# Scop: Verifică disponibilitatea tuturor dependențelor pentru proiectele CAPSTONE
# Utilizare: ./check_dependencies.sh [--install] [--verbose]
# Autor: Seminarul 11-12 CAPSTONE - Sisteme de Operare ASE București
#===============================================================================

set -euo pipefail

#-------------------------------------------------------------------------------
# CONSTANTE
#-------------------------------------------------------------------------------
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly VERSION="1.0.0"

# Culori
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly MAGENTA='\033[0;35m'
readonly BOLD='\033[1m'
readonly DIM='\033[2m'
readonly NC='\033[0m'

#-------------------------------------------------------------------------------
# VARIABILE
#-------------------------------------------------------------------------------
VERBOSE=false
INSTALL_MISSING=false
EXIT_CODE=0

# Contoare
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNING_CHECKS=0

#-------------------------------------------------------------------------------
# DEFINIȚII DEPENDENȚE
#-------------------------------------------------------------------------------

# Format: "comanda:categorie:obligatoriu:pachet_debian:pachet_redhat:descriere"
declare -a DEPENDENCIES=(
    # Core
    "bash:core:required:bash:bash:Bourne Again Shell"
    "coreutils:core:required:coreutils:coreutils:GNU Core Utilities"
    
    # Arhivare și compresie
    "tar:archive:required:tar:tar:Tape archive utility"
    "gzip:archive:required:gzip:gzip:GNU compression utility"
    "bzip2:archive:optional:bzip2:bzip2:Block-sorting file compressor"
    "xz:archive:optional:xz-utils:xz:XZ compression utility"
    "zstd:archive:optional:zstd:zstd:Zstandard fast compression"
    
    # Checksum și securitate
    "md5sum:checksum:required:coreutils:coreutils:MD5 message digest"
    "sha1sum:checksum:required:coreutils:coreutils:SHA1 message digest"
    "sha256sum:checksum:required:coreutils:coreutils:SHA256 message digest"
    
    # Networking
    "curl:network:optional:curl:curl:Command-line URL transfer tool"
    "wget:network:optional:wget:wget:Network downloader"
    "nc:network:optional:netcat-openbsd:nc:Network utility (netcat)"
    "ss:network:optional:iproute2:iproute:Socket statistics"
    
    # Procesare text
    "awk:text:required:gawk:gawk:Pattern scanning utility"
    "sed:text:required:sed:sed:Stream editor"
    "grep:text:required:grep:grep:Pattern matching utility"
    "sort:text:required:coreutils:coreutils:Sort lines of text"
    "uniq:text:required:coreutils:coreutils:Report unique lines"
    "wc:text:required:coreutils:coreutils:Word, line, byte count"
    "head:text:required:coreutils:coreutils:Output first part of files"
    "tail:text:required:coreutils:coreutils:Output last part of files"
    "cut:text:required:coreutils:coreutils:Remove sections from lines"
    "tr:text:required:coreutils:coreutils:Translate characters"
    
    # Filesystem
    "find:fs:required:findutils:findutils:Search for files"
    "mkdir:fs:required:coreutils:coreutils:Make directories"
    "chmod:fs:required:coreutils:coreutils:Change file mode"
    "chown:fs:required:coreutils:coreutils:Change file owner"
    "ln:fs:required:coreutils:coreutils:Make links"
    "cp:fs:required:coreutils:coreutils:Copy files"
    "mv:fs:required:coreutils:coreutils:Move files"
    "rm:fs:required:coreutils:coreutils:Remove files"
    "df:fs:required:coreutils:coreutils:Disk free space"
    "du:fs:required:coreutils:coreutils:Disk usage"
    "stat:fs:required:coreutils:coreutils:File status"
    "mktemp:fs:required:coreutils:coreutils:Make temporary file"
    
    # Monitoring
    "ps:monitor:required:procps:procps-ng:Process status"
    "top:monitor:optional:procps:procps-ng:Process monitor"
    "free:monitor:required:procps:procps-ng:Memory usage"
    "uptime:monitor:required:procps:procps-ng:System uptime"
    "vmstat:monitor:optional:procps:procps-ng:Virtual memory stats"
    "iostat:monitor:optional:sysstat:sysstat:I/O statistics"
    "mpstat:monitor:optional:sysstat:sysstat:CPU statistics"
    
    # Date și timp
    "date:time:required:coreutils:coreutils:Display date and time"
    
    # Procese
    "kill:process:required:procps:procps-ng:Send signals to processes"
    "pkill:process:optional:procps:procps-ng:Signal processes by name"
    "pgrep:process:optional:procps:procps-ng:Look up processes"
    "nohup:process:required:coreutils:coreutils:Run immune to hangups"
    
    # Servicii
    "systemctl:service:optional:systemd:systemd:systemd control"
    
    # Containerizare
    "docker:container:optional:docker.io:docker-ce:Container platform"
    
    # Alte utilități
    "tree:util:optional:tree:tree:Directory listing"
    "jq:util:optional:jq:jq:JSON processor"
    "bc:util:optional:bc:bc:Calculator"
    "file:util:required:file:file:File type determination"
    "basename:util:required:coreutils:coreutils:Strip directory"
    "dirname:util:required:coreutils:coreutils:Strip filename"
    "realpath:util:required:coreutils:coreutils:Resolve path"
    "tee:util:required:coreutils:coreutils:Pipe fitting"
    "xargs:util:required:findutils:findutils:Build and execute commands"
)

#-------------------------------------------------------------------------------
# FUNCȚII UTILITATE
#-------------------------------------------------------------------------------

print_banner() {
    echo -e "${CYAN}"
    cat << 'EOF'
╔═══════════════════════════════════════════════════════════════════════╗
║          CAPSTONE PROJECTS - DEPENDENCY CHECKER v1.0.0                ║
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
    echo -e "${RED}[FAIL]${NC} $1"
}

log_verbose() {
    [[ "$VERBOSE" == "true" ]] && echo -e "${DIM}       $1${NC}"
}

#-------------------------------------------------------------------------------
# FUNCȚII VERIFICARE
#-------------------------------------------------------------------------------

detect_os() {
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        OS_ID="${ID:-unknown}"
        OS_VERSION="${VERSION_ID:-unknown}"
        OS_NAME="${NAME:-Unknown}"
    elif command -v lsb_release &>/dev/null; then
        OS_ID=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
        OS_VERSION=$(lsb_release -sr)
        OS_NAME=$(lsb_release -sd)
    else
        OS_ID="unknown"
        OS_VERSION="unknown"
        OS_NAME="Unknown"
    fi
    
    # Determinare familie
    case "$OS_ID" in
        ubuntu|debian|linuxmint|pop)
            OS_FAMILY="debian"
            PKG_MANAGER="apt"
            ;;
        centos|rhel|fedora|rocky|almalinux)
            OS_FAMILY="redhat"
            PKG_MANAGER="dnf"
            [[ "$OS_ID" == "centos" ]] && [[ "${OS_VERSION%%.*}" -lt 8 ]] && PKG_MANAGER="yum"
            ;;
        arch|manjaro)
            OS_FAMILY="arch"
            PKG_MANAGER="pacman"
            ;;
        alpine)
            OS_FAMILY="alpine"
            PKG_MANAGER="apk"
            ;;
        *)
            OS_FAMILY="unknown"
            PKG_MANAGER="unknown"
            ;;
    esac
}

check_command() {
    local cmd="$1"
    local category="$2"
    local required="$3"
    local pkg_debian="$4"
    local pkg_redhat="$5"
    local description="$6"
    
    ((TOTAL_CHECKS++))
    
    local status
    local version=""
    
    if command -v "$cmd" &>/dev/null; then
        status="ok"
        ((PASSED_CHECKS++))
        
        # Încercare obținere versiune
        if [[ "$VERBOSE" == "true" ]]; then
            version=$($cmd --version 2>/dev/null | head -1 || echo "")
        fi
        
        printf "  ${GREEN}✓${NC} %-15s ${DIM}%s${NC}\n" "$cmd" "$description"
        [[ -n "$version" ]] && log_verbose "Version: $version"
        
    else
        if [[ "$required" == "required" ]]; then
            status="fail"
            ((FAILED_CHECKS++))
            EXIT_CODE=1
            printf "  ${RED}✗${NC} %-15s ${DIM}%s${NC} ${RED}[REQUIRED]${NC}\n" "$cmd" "$description"
        else
            status="warn"
            ((WARNING_CHECKS++))
            printf "  ${YELLOW}○${NC} %-15s ${DIM}%s${NC} ${YELLOW}[optional]${NC}\n" "$cmd" "$description"
        fi
        
        # Sugestie pachet
        if [[ "$VERBOSE" == "true" ]]; then
            case "$OS_FAMILY" in
                debian)
                    log_verbose "Install: sudo apt install $pkg_debian"
                    ;;
                redhat)
                    log_verbose "Install: sudo $PKG_MANAGER install $pkg_redhat"
                    ;;
            esac
        fi
    fi
}

check_bash_version() {
    log_info "Verificare versiune Bash..."
    
    local bash_version="${BASH_VERSION:-0}"
    local major_version="${bash_version%%.*}"
    
    if [[ $major_version -ge 4 ]]; then
        log_success "Bash version: $bash_version (>= 4.0 required)"
    else
        log_error "Bash version: $bash_version (requires >= 4.0)"
        EXIT_CODE=1
    fi
    
    echo ""
}

check_category() {
    local category="$1"
    local title="$2"
    
    echo -e "\n${BOLD}${MAGENTA}[$title]${NC}"
    echo -e "${DIM}$(printf '─%.0s' {1..60})${NC}"
    
    for dep in "${DEPENDENCIES[@]}"; do
        IFS=':' read -r cmd cat req pkg_deb pkg_rh desc <<< "$dep"
        
        if [[ "$cat" == "$category" ]]; then
            check_command "$cmd" "$cat" "$req" "$pkg_deb" "$pkg_rh" "$desc"
        fi
    done
}

check_kernel_features() {
    log_info "Verificare funcționalități kernel..."
    
    echo -e "\n${BOLD}${MAGENTA}[Kernel Features]${NC}"
    echo -e "${DIM}$(printf '─%.0s' {1..60})${NC}"
    
    ((TOTAL_CHECKS++))
    
    # Verificare /proc
    if [[ -d /proc ]]; then
        ((PASSED_CHECKS++))
        printf "  ${GREEN}✓${NC} %-15s %s\n" "/proc" "Process filesystem mounted"
    else
        ((FAILED_CHECKS++))
        printf "  ${RED}✗${NC} %-15s %s\n" "/proc" "Process filesystem NOT mounted"
        EXIT_CODE=1
    fi
    
    ((TOTAL_CHECKS++))
    
    # Verificare /sys
    if [[ -d /sys ]]; then
        ((PASSED_CHECKS++))
        printf "  ${GREEN}✓${NC} %-15s %s\n" "/sys" "Sysfs mounted"
    else
        ((WARNING_CHECKS++))
        printf "  ${YELLOW}○${NC} %-15s %s\n" "/sys" "Sysfs NOT mounted (optional)"
    fi
    
    ((TOTAL_CHECKS++))
    
    # Verificare cgroups
    if [[ -d /sys/fs/cgroup ]]; then
        ((PASSED_CHECKS++))
        printf "  ${GREEN}✓${NC} %-15s %s\n" "cgroups" "Control groups available"
    else
        ((WARNING_CHECKS++))
        printf "  ${YELLOW}○${NC} %-15s %s\n" "cgroups" "Control groups NOT available"
    fi
}

check_permissions() {
    log_info "Verificare permisiuni..."
    
    echo -e "\n${BOLD}${MAGENTA}[Permissions]${NC}"
    echo -e "${DIM}$(printf '─%.0s' {1..60})${NC}"
    
    ((TOTAL_CHECKS++))
    
    # Verificare dacă rulăm ca root
    if [[ $EUID -eq 0 ]]; then
        ((PASSED_CHECKS++))
        printf "  ${GREEN}✓${NC} %-15s %s\n" "root" "Running as root"
    else
        ((WARNING_CHECKS++))
        printf "  ${YELLOW}○${NC} %-15s %s\n" "root" "Not running as root (some features limited)"
    fi
    
    ((TOTAL_CHECKS++))
    
    # Verificare scriere în /tmp
    if [[ -w /tmp ]]; then
        ((PASSED_CHECKS++))
        printf "  ${GREEN}✓${NC} %-15s %s\n" "/tmp" "Writable"
    else
        ((FAILED_CHECKS++))
        printf "  ${RED}✗${NC} %-15s %s\n" "/tmp" "NOT writable"
        EXIT_CODE=1
    fi
    
    ((TOTAL_CHECKS++))
    
    # Verificare $HOME
    if [[ -w "$HOME" ]]; then
        ((PASSED_CHECKS++))
        printf "  ${GREEN}✓${NC} %-15s %s\n" "\$HOME" "Writable ($HOME)"
    else
        ((FAILED_CHECKS++))
        printf "  ${RED}✗${NC} %-15s %s\n" "\$HOME" "NOT writable"
        EXIT_CODE=1
    fi
}

check_network() {
    log_info "Verificare conectivitate rețea..."
    
    echo -e "\n${BOLD}${MAGENTA}[Network]${NC}"
    echo -e "${DIM}$(printf '─%.0s' {1..60})${NC}"
    
    ((TOTAL_CHECKS++))
    
    # Verificare DNS
    if command -v getent &>/dev/null && getent hosts google.com &>/dev/null; then
        ((PASSED_CHECKS++))
        printf "  ${GREEN}✓${NC} %-15s %s\n" "DNS" "Resolution working"
    elif command -v nslookup &>/dev/null && nslookup google.com &>/dev/null; then
        ((PASSED_CHECKS++))
        printf "  ${GREEN}✓${NC} %-15s %s\n" "DNS" "Resolution working"
    else
        ((WARNING_CHECKS++))
        printf "  ${YELLOW}○${NC} %-15s %s\n" "DNS" "Resolution check failed"
    fi
    
    ((TOTAL_CHECKS++))
    
    # Verificare conectivitate
    if command -v curl &>/dev/null && curl -s --max-time 5 https://google.com &>/dev/null; then
        ((PASSED_CHECKS++))
        printf "  ${GREEN}✓${NC} %-15s %s\n" "Internet" "Connectivity OK"
    elif command -v wget &>/dev/null && wget -q --spider --timeout=5 https://google.com; then
        ((PASSED_CHECKS++))
        printf "  ${GREEN}✓${NC} %-15s %s\n" "Internet" "Connectivity OK"
    else
        ((WARNING_CHECKS++))
        printf "  ${YELLOW}○${NC} %-15s %s\n" "Internet" "No connectivity (optional)"
    fi
}

generate_install_commands() {
    if [[ $FAILED_CHECKS -eq 0 ]] && [[ $WARNING_CHECKS -eq 0 ]]; then
        return 0
    fi
    
    echo -e "\n${BOLD}${MAGENTA}[Installation Commands]${NC}"
    echo -e "${DIM}$(printf '─%.0s' {1..60})${NC}"
    
    local missing_required=()
    local missing_optional=()
    
    for dep in "${DEPENDENCIES[@]}"; do
        IFS=':' read -r cmd cat req pkg_deb pkg_rh desc <<< "$dep"
        
        if ! command -v "$cmd" &>/dev/null; then
            case "$OS_FAMILY" in
                debian)
                    if [[ "$req" == "required" ]]; then
                        missing_required+=("$pkg_deb")
                    else
                        missing_optional+=("$pkg_deb")
                    fi
                    ;;
                redhat)
                    if [[ "$req" == "required" ]]; then
                        missing_required+=("$pkg_rh")
                    else
                        missing_optional+=("$pkg_rh")
                    fi
                    ;;
            esac
        fi
    done
    
    # Deduplicare
    local unique_required=($(echo "${missing_required[@]}" | tr ' ' '\n' | sort -u))
    local unique_optional=($(echo "${missing_optional[@]}" | tr ' ' '\n' | sort -u))
    
    if [[ ${#unique_required[@]} -gt 0 ]]; then
        echo -e "\n${RED}Required packages:${NC}"
        case "$OS_FAMILY" in
            debian)
                echo "  sudo apt update && sudo apt install -y ${unique_required[*]}"
                ;;
            redhat)
                echo "  sudo $PKG_MANAGER install -y ${unique_required[*]}"
                ;;
        esac
    fi
    
    if [[ ${#unique_optional[@]} -gt 0 ]]; then
        echo -e "\n${YELLOW}Optional packages:${NC}"
        case "$OS_FAMILY" in
            debian)
                echo "  sudo apt install -y ${unique_optional[*]}"
                ;;
            redhat)
                echo "  sudo $PKG_MANAGER install -y ${unique_optional[*]}"
                ;;
        esac
    fi
}

#-------------------------------------------------------------------------------
# HELP ȘI ARGUMENTE
#-------------------------------------------------------------------------------

show_help() {
    cat << EOF
CAPSTONE Projects Dependency Checker v${VERSION}

Utilizare: $(basename "$0") [OPȚIUNI]

Opțiuni:
  --verbose, -v      Afișează informații detaliate
  --install          Sugerează comenzi de instalare
  --json             Output în format JSON
  --category=CAT     Verifică doar categoria specificată
                     (core, archive, checksum, network, text, fs, monitor, etc.)
  --help             Afișează acest ajutor

Categorii disponibile:
  core       - Utilități core sistem
  archive    - Arhivare și compresie
  checksum   - Verificare integritate
  network    - Utilități rețea
  text       - Procesare text
  fs         - Operații filesystem
  monitor    - Monitorizare sistem
  time       - Date și timp
  process    - Management procese
  service    - Servicii sistem
  container  - Containerizare
  util       - Alte utilități

Exemple:
  ./check_dependencies.sh                  # Verificare completă
  ./check_dependencies.sh --verbose        # Cu detalii
  ./check_dependencies.sh --category=archive  # Doar arhivare
EOF
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --verbose|-v)
                VERBOSE=true
                shift
                ;;
            --install)
                INSTALL_MISSING=true
                shift
                ;;
            --json)
                OUTPUT_JSON=true
                shift
                ;;
            --category=*)
                CHECK_CATEGORY="${1#*=}"
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
    echo -e "${BOLD}═══════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}                           SUMMARY                                     ${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    printf "  Total checks:    %d\n" "$TOTAL_CHECKS"
    printf "  ${GREEN}Passed:${NC}          %d\n" "$PASSED_CHECKS"
    printf "  ${YELLOW}Warnings:${NC}        %d\n" "$WARNING_CHECKS"
    printf "  ${RED}Failed:${NC}          %d\n" "$FAILED_CHECKS"
    echo ""
    
    if [[ $FAILED_CHECKS -eq 0 ]]; then
        echo -e "  ${GREEN}${BOLD}✓ All required dependencies are met!${NC}"
    else
        echo -e "  ${RED}${BOLD}✗ Some required dependencies are missing!${NC}"
    fi
    
    if [[ $WARNING_CHECKS -gt 0 ]]; then
        echo -e "  ${YELLOW}${BOLD}⚠ Some optional dependencies are missing.${NC}"
    fi
    
    echo ""
}

main() {
    parse_args "$@"
    
    print_banner
    
    # Detectare OS
    detect_os
    
    log_info "System: $OS_NAME ($OS_ID $OS_VERSION)"
    log_info "Package manager: $PKG_MANAGER"
    echo ""
    
    # Verificare Bash
    check_bash_version
    
    # Verificare dependențe pe categorii
    if [[ -n "${CHECK_CATEGORY:-}" ]]; then
        check_category "$CHECK_CATEGORY" "$(echo "$CHECK_CATEGORY" | tr '[:lower:]' '[:upper:]')"
    else
        check_category "core" "CORE UTILITIES"
        check_category "archive" "ARCHIVE & COMPRESSION"
        check_category "checksum" "CHECKSUM & INTEGRITY"
        check_category "text" "TEXT PROCESSING"
        check_category "fs" "FILESYSTEM"
        check_category "monitor" "MONITORING"
        check_category "process" "PROCESS MANAGEMENT"
        check_category "network" "NETWORK"
        check_category "service" "SERVICES"
        check_category "container" "CONTAINERS"
        check_category "util" "OTHER UTILITIES"
    fi
    
    # Verificări adiționale
    check_kernel_features
    check_permissions
    check_network
    
    # Comenzi instalare
    if [[ "$INSTALL_MISSING" == "true" ]]; then
        generate_install_commands
    fi
    
    # Sumar
    show_summary
    
    exit $EXIT_CODE
}

main "$@"
