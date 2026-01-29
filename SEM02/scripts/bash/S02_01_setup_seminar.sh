#!/bin/bash
#
# S02_01_setup_seminar.sh - Setup și Verificare Mediu pentru Seminarul 3-4
#
#
# DESCRIERE:
#   Scriptul verifică și pregătește mediul pentru seminarul de SO.
#   Verifică versiuni, instalează dependențe opționale, creează directoare
#   de lucru și generează fișiere de test.
#
# UTILIZARE:
#   chmod +x S02_01_setup_seminar.sh
#   ./S02_01_setup_seminar.sh [opțiuni]
#
# OPȚIUNI:
#   --check-only    Doar verifică, nu instalează nimic
#   --install       Instalează dependențele lipsă (necesită sudo)
#   --wsl           Mod pentru Windows Subsystem for Linux
#   --help          Afișează acest mesaj
#
# AUTOR: Materiale SO ASE-CSIE
# VERSIUNE: 1.0
#

set -euo pipefail

#
# CONFIGURARE
#

# Culori
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[1;36m'
NC='\033[0m'
BOLD='\033[1m'

# Directoare
WORK_DIR="${HOME}/seminar_so"
DEMO_DIR="${WORK_DIR}/demo"
TEST_DIR="${WORK_DIR}/test_files"

# Dependențe obligatorii
REQUIRED_CMDS=(bash sort uniq cut head tail tr wc cat echo)

# Dependențe opționale (pentru demo-uri spectaculoase)
OPTIONAL_CMDS=(figlet lolcat cowsay fortune pv dialog tree ncdu htop bc jq)

# Versiuni minime
MIN_BASH_VERSION="4.0"
MIN_PYTHON_VERSION="3.8"

#
# FUNCȚII HELPER
#

print_header() {
    echo -e "\n${CYAN}═══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}   $1${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════${NC}\n"
}

print_section() {
    echo -e "\n${YELLOW}▸ $1${NC}\n"
}

ok() {
    echo -e "  ${GREEN}✓${NC} $1"
}

warn() {
    echo -e "  ${YELLOW}⚠${NC} $1"
}

fail() {
    echo -e "  ${RED}✗${NC} $1"
}

info() {
    echo -e "  ${BLUE}ℹ${NC} $1"
}

cmd_exists() {
    command -v "$1" &>/dev/null
}

version_ge() {
    # Compară versiuni: version_ge "4.4" "4.0" returnează 0 (true)
    printf '%s\n%s' "$2" "$1" | sort -V -C
}

#
# VERIFICARE VERSIUNI
#

check_bash_version() {
    print_section "Verificare versiune Bash"
    
    local bash_version="${BASH_VERSION%%(*}"
    bash_version="${bash_version%.*}"
    
    if version_ge "$bash_version" "$MIN_BASH_VERSION"; then
        ok "Bash $BASH_VERSION (minim: $MIN_BASH_VERSION)"
        return 0
    else
        fail "Bash $BASH_VERSION - versiune prea veche (minim: $MIN_BASH_VERSION)"
        return 1
    fi
}

check_python_version() {
    print_section "Verificare Python"
    
    if ! cmd_exists python3; then
        warn "Python3 nu este instalat (opțional pentru autograder)"
        return 0
    fi
    
    local py_version
    py_version=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
    
    if version_ge "$py_version" "$MIN_PYTHON_VERSION"; then
        ok "Python $py_version (minim: $MIN_PYTHON_VERSION)"
    else
        warn "Python $py_version - recomandat $MIN_PYTHON_VERSION+"
    fi
}

check_os() {
    print_section "Verificare Sistem de Operare"
    
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        ok "$NAME $VERSION_ID"
        
        if [[ "$ID" == "ubuntu" ]]; then
            local major_version="${VERSION_ID%%.*}"
            if [[ "$major_version" -lt 22 ]]; then
                warn "Recomandat Ubuntu 22.04+ (ai $VERSION_ID)"
            fi
        fi
    else
        warn "Nu pot determina sistemul de operare"
    fi
    
    # Detectare WSL
    if grep -qi microsoft /proc/version 2>/dev/null; then
        info "Rulează în WSL (Windows Subsystem for Linux)"
        WSL_MODE=1
    else
        WSL_MODE=0
    fi
}

#
# VERIFICARE DEPENDENȚE
#

check_required_commands() {
    print_section "Verificare comenzi obligatorii"
    
    local missing=()
    
    for cmd in "${REQUIRED_CMDS[@]}"; do
        if cmd_exists "$cmd"; then
            ok "$cmd"
        else
            fail "$cmd - LIPSEȘTE!"
            missing+=("$cmd")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        fail "Comenzi obligatorii lipsă: ${missing[*]}"
        return 1
    fi
    
    return 0
}

check_optional_commands() {
    print_section "Verificare comenzi opționale (pentru demo-uri)"
    
    local missing=()
    
    for cmd in "${OPTIONAL_CMDS[@]}"; do
        if cmd_exists "$cmd"; then
            ok "$cmd"
        else
            warn "$cmd - lipsește (opțional)"
            missing+=("$cmd")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo ""
        info "Pentru a instala comenzile opționale:"
        echo -e "     ${GREEN}sudo apt install ${missing[*]}${NC}"
    fi
}

#
# CREARE STRUCTURĂ DIRECTOARE
#

create_directories() {
    print_section "Creare directoare de lucru"
    
    local dirs=("$WORK_DIR" "$DEMO_DIR" "$TEST_DIR")
    
    for dir in "${dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            ok "$dir (există)"
        else
            mkdir -p "$dir"
            ok "$dir (creat)"
        fi
    done
}

#
# GENERARE FIȘIERE DE TEST
#

create_test_files() {
    print_section "Generare fișiere de test"
    
    # Fișier pentru teste sort/uniq
    cat > "${TEST_DIR}/colors.txt" << 'EOF'
rosu
verde
albastru
rosu
galben
verde
rosu
portocaliu
albastru
verde
EOF
    ok "colors.txt (pentru sort/uniq)"
    
    # Fișier CSV pentru teste cut/awk
    cat > "${TEST_DIR}/studenti.csv" << 'EOF'
nume,varsta,nota,grupa
Popescu Ion,21,9,1234
Ionescu Maria,22,10,1234
Georgescu Ana,20,8,1235
Vasilescu Dan,23,7,1235
Marinescu Elena,21,9,1234
Dumitrescu Alex,22,8,1236
EOF
    ok "studenti.csv (pentru cut/paste)"
    
    # Fișier pentru teste head/tail
    seq 1 100 > "${TEST_DIR}/numere.txt"
    ok "numere.txt (pentru head/tail)"
    
    # Fișier cu text pentru wc/tr
    cat > "${TEST_DIR}/text.txt" << 'EOF'
Aceasta este o propoziție de test.
Are mai multe linii.
Și caractere speciale: ăîșțâ!
    Și linii cu indentare.

Și o linie goală mai sus.
EOF
    ok "text.txt (pentru wc/tr)"
    
    # Fișier log simulat pentru exerciții
    cat > "${TEST_DIR}/access.log" << 'EOF'
192.168.1.1 - - [01/Jan/2025:10:00:00] "GET /index.html HTTP/1.1" 200 1234
192.168.1.2 - - [01/Jan/2025:10:00:01] "GET /about.html HTTP/1.1" 200 2345
192.168.1.1 - - [01/Jan/2025:10:00:02] "GET /contact.html HTTP/1.1" 404 567
10.0.0.5 - - [01/Jan/2025:10:00:03] "POST /login HTTP/1.1" 200 890
192.168.1.3 - - [01/Jan/2025:10:00:04] "GET /admin HTTP/1.1" 403 432
192.168.1.1 - - [01/Jan/2025:10:00:05] "GET /style.css HTTP/1.1" 200 5678
10.0.0.5 - - [01/Jan/2025:10:00:06] "GET /dashboard HTTP/1.1" 200 3456
192.168.1.2 - - [01/Jan/2025:10:00:07] "GET /api/data HTTP/1.1" 500 123
192.168.1.4 - - [01/Jan/2025:10:00:08] "GET /index.html HTTP/1.1" 200 1234
192.168.1.1 - - [01/Jan/2025:10:00:09] "GET /images/logo.png HTTP/1.1" 200 9876
EOF
    ok "access.log (pentru exerciții pipeline)"
    
    # Script de test pentru exerciții bucle
    cat > "${TEST_DIR}/test_script.sh" << 'EOF'
#!/bin/bash
# Script de test pentru exerciții

echo "Argument primit: $1"
sleep 1
echo "Procesare completă"
exit 0
EOF
    chmod +x "${TEST_DIR}/test_script.sh"
    ok "test_script.sh (pentru exerciții bucle)"
    
    echo ""
    info "Fișiere create în: $TEST_DIR"
}

#
# INSTALARE DEPENDENȚE
#

install_dependencies() {
    print_section "Instalare dependențe opționale"
    
    if [[ $EUID -ne 0 ]] && ! sudo -n true 2>/dev/null; then
        warn "Necesită sudo pentru instalare. Rulează cu sudo sau --check-only"
        return 1
    fi
    
    info "Actualizare liste pachete..."
    sudo apt update -qq
    
    local to_install=()
    for cmd in "${OPTIONAL_CMDS[@]}"; do
        if ! cmd_exists "$cmd"; then
            # Mapare comandă -> pachet (unele diferă)
            case "$cmd" in
                lolcat) to_install+=("lolcat") ;;
                ncdu)   to_install+=("ncdu") ;;
                *)      to_install+=("$cmd") ;;
            esac
        fi
    done
    
    if [[ ${#to_install[@]} -gt 0 ]]; then
        info "Instalare: ${to_install[*]}"
        sudo apt install -y "${to_install[@]}"
        ok "Instalare completă"
    else
        ok "Toate dependențele sunt deja instalate"
    fi
}

#
# AFIȘARE SUMAR
#

show_summary() {
    print_header "SUMAR SETUP"
    
    echo -e "${GREEN}✓ Mediul este pregătit pentru seminar!${NC}"
    echo ""
    echo -e "Director de lucru: ${CYAN}$WORK_DIR${NC}"
    echo -e "Fișiere de test:   ${CYAN}$TEST_DIR${NC}"
    echo ""
    echo -e "Comenzi utile:"
    echo -e "  ${GREEN}cd $WORK_DIR${NC}      # mergi în directorul de lucru"
    echo -e "  ${GREEN}ls $TEST_DIR${NC}      # vezi fișierele de test"
    echo ""
    
    if [[ -d "$(dirname "$0")/../demo" ]]; then
        echo -e "Demo-uri disponibile:"
        echo -e "  ${GREEN}./scripts/demo/S02_01_hook_demo.sh${NC}"
        echo ""
    fi
}

#
# HELP
#

show_help() {
    cat << EOF
${BOLD}S02_01_setup_seminar.sh${NC} - Setup Mediu Seminar SO

${YELLOW}UTILIZARE:${NC}
    ./S02_01_setup_seminar.sh [opțiuni]

${YELLOW}OPȚIUNI:${NC}
    --check-only    Doar verifică, nu instalează și nu creează fișiere
    --install       Instalează dependențele lipsă (necesită sudo)
    --wsl           Mod pentru Windows Subsystem for Linux
    --help, -h      Afișează acest mesaj

${YELLOW}EXEMPLE:${NC}
    ./S02_01_setup_seminar.sh                  # Setup standard
    ./S02_01_setup_seminar.sh --check-only     # Doar verificare
    sudo ./S02_01_setup_seminar.sh --install   # Cu instalare pachete

${YELLOW}DIRECTOR DE LUCRU:${NC}
    $WORK_DIR

EOF
}

#
# MAIN
#

main() {
    local check_only=0
    local do_install=0
    local wsl_mode=0
    
    # Parse argumente
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --check-only)
                check_only=1
                shift
                ;;
            --install)
                do_install=1
                shift
                ;;
            --wsl)
                wsl_mode=1
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                echo "Opțiune necunoscută: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    print_header "SETUP SEMINAR 3-4: Sisteme de Operare"
    
    # Verificări obligatorii
    check_os
    check_bash_version || exit 1
    check_required_commands || exit 1
    
    # Verificări opționale
    check_python_version
    check_optional_commands
    
    # Acțiuni (dacă nu e check-only)
    if [[ $check_only -eq 0 ]]; then
        create_directories
        create_test_files
        
        if [[ $do_install -eq 1 ]]; then
            install_dependencies
        fi
        
        show_summary
    else
        print_header "VERIFICARE COMPLETĂ"
        echo -e "${GREEN}✓ Toate verificările au trecut!${NC}"
    fi
}

# Rulează
main "$@"
