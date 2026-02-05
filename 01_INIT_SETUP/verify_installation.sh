#!/bin/bash
#===============================================================================
# verify_installation.sh — Verificare Instalare pentru Cursul SO
#===============================================================================
# Utilizare: bash verify_installation.sh
# 
# Acest script verifică dacă mediul tău Ubuntu este configurat corect
# pentru cursul de Sisteme de Operare la ASE București - CSIE.
#
# Versiune: 2.1 | Ianuarie 2025
# Autor: ing. dr. Antonio Clim
#===============================================================================

set -uo pipefail

#-------------------------------------------------------------------------------
# Definiții culori pentru output
#-------------------------------------------------------------------------------
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'  # Fără culoare

#-------------------------------------------------------------------------------
# Contoare pentru sumar
#-------------------------------------------------------------------------------
PASSED=0
FAILED=0
WARNINGS=0

#-------------------------------------------------------------------------------
# Funcții ajutătoare
#-------------------------------------------------------------------------------
print_ok() {
    echo -e "  ${GREEN}[OK]${NC} $1"
    ((PASSED++))
}

print_fail() {
    echo -e "  ${RED}[FAIL]${NC} $1"
    ((FAILED++))
}

print_warn() {
    echo -e "  ${YELLOW}[WARN]${NC} $1"
    ((WARNINGS++))
}

print_info() {
    echo -e "  ${CYAN}[INFO]${NC} $1"
}

print_header() {
    echo ""
    echo -e "${BOLD}========================================${NC}"
    echo -e "${BOLD}   VERIFICARE INSTALARE - SO ASE${NC}"
    echo -e "${BOLD}========================================${NC}"
    echo ""
}

print_section() {
    echo ""
    echo -e "${BOLD}>>> $1${NC}"
}

#-------------------------------------------------------------------------------
# Verificare: Informații sistem
#-------------------------------------------------------------------------------
check_system_info() {
    print_section "Informații Sistem"
    
    local hostname_val
    hostname_val=$(hostname 2>/dev/null || echo "necunoscut")
    echo "  Hostname: ${hostname_val}"
    
    # Validare format hostname (INITIALE_GRUPA_SERIA)
    if [[ "$hostname_val" =~ ^[A-Z]{2,4}_[0-9]{4}_[A-Z]$ ]]; then
        print_ok "Formatul hostname este corect"
    else
        print_warn "Formatul hostname poate fi incorect (așteptat: AP_1001_A)"
    fi
    
    local user_val
    user_val=$(whoami 2>/dev/null || echo "necunoscut")
    echo "  Utilizator: ${user_val}"
    
    local ubuntu_val
    ubuntu_val=$(lsb_release -d 2>/dev/null | cut -f2 || echo "necunoscut")
    echo "  Ubuntu: ${ubuntu_val}"
    
    # Verificare versiune Ubuntu
    if [[ "$ubuntu_val" == *"24.04"* ]]; then
        print_ok "Ubuntu 24.04 LTS detectat"
    elif [[ "$ubuntu_val" == *"Ubuntu"* ]]; then
        print_warn "Ubuntu detectat dar nu 24.04 (găsit: ${ubuntu_val})"
    else
        print_fail "Ubuntu nu a fost detectat"
    fi
    
    local kernel_val
    kernel_val=$(uname -r 2>/dev/null || echo "necunoscut")
    echo "  Kernel: ${kernel_val}"
}

#-------------------------------------------------------------------------------
# Verificare: Conectivitate rețea
#-------------------------------------------------------------------------------
check_network() {
    print_section "Rețea"
    
    local ip_val
    ip_val=$(hostname -I 2>/dev/null | awk '{print $1}')
    
    if [[ -n "$ip_val" ]]; then
        echo "  Adresă IP: ${ip_val}"
        print_ok "Adresă IP atribuită"
    else
        echo "  Adresă IP: Indisponibilă"
        print_fail "Nu s-a găsit adresă IP"
    fi
    
    # Test conectivitate internet
    if ping -c 1 -W 3 google.com > /dev/null 2>&1; then
        print_ok "Conectivitate internet"
    elif ping -c 1 -W 3 8.8.8.8 > /dev/null 2>&1; then
        print_warn "Internetul funcționează dar DNS-ul poate avea probleme"
    else
        print_fail "Fără conexiune la internet"
    fi
}

#-------------------------------------------------------------------------------
# Verificare: Comenzi esențiale
#-------------------------------------------------------------------------------
check_commands() {
    print_section "Comenzi Esențiale"
    
    # Utilitare de bază
    local core_commands=(bash git nano vim gcc python3 ssh)
    # Unelte adiționale
    local extra_commands=(tree htop awk sed grep find tar gzip curl wget)
    
    echo "  Unelte de bază:"
    for cmd in "${core_commands[@]}"; do
        if command -v "$cmd" > /dev/null 2>&1; then
            print_ok "$cmd"
        else
            print_fail "$cmd — instalează cu: sudo apt install $cmd"
        fi
    done
    
    echo ""
    echo "  Unelte adiționale:"
    for cmd in "${extra_commands[@]}"; do
        if command -v "$cmd" > /dev/null 2>&1; then
            print_ok "$cmd"
        else
            print_warn "$cmd — opțional dar recomandat"
        fi
    done
}

#-------------------------------------------------------------------------------
# Verificare: Server SSH
#-------------------------------------------------------------------------------
check_ssh() {
    print_section "Server SSH"
    
    # Încearcă systemctl mai întâi (systemd), apoi service (SysV init)
    if systemctl is-active ssh > /dev/null 2>&1; then
        print_ok "Serverul SSH rulează (systemd)"
    elif systemctl is-active sshd > /dev/null 2>&1; then
        print_ok "Serverul SSH rulează (sshd)"
    elif service ssh status 2>/dev/null | grep -q "running"; then
        print_ok "Serverul SSH rulează (service)"
    else
        print_fail "Serverul SSH NU rulează"
        print_info "Pornește cu: sudo systemctl start ssh"
    fi
    
    # Verifică dacă SSH este activat la boot
    if systemctl is-enabled ssh > /dev/null 2>&1; then
        print_ok "SSH activat la boot"
    else
        print_warn "SSH nu este activat la boot — rulează: sudo systemctl enable ssh"
    fi
}

#-------------------------------------------------------------------------------
# Verificare: Foldere de lucru
#-------------------------------------------------------------------------------
check_folders() {
    print_section "Foldere de Lucru"
    
    local folders=(Books HomeworksOLD Projects ScriptsSTUD test TXT)
    local missing_folders=()
    
    for dir in "${folders[@]}"; do
        if [[ -d "$HOME/$dir" ]]; then
            print_ok "~/$dir"
        else
            print_fail "~/$dir — lipsă"
            missing_folders+=("$dir")
        fi
    done
    
    # Oferă să creeze folderele lipsă
    if [[ ${#missing_folders[@]} -gt 0 ]]; then
        echo ""
        print_info "Creează folderele lipsă cu:"
        echo "        mkdir -p ~/${missing_folders[*]// / ~/}"
    fi
}

#-------------------------------------------------------------------------------
# Verificare: Mediu Python (bonus)
#-------------------------------------------------------------------------------
check_python() {
    print_section "Mediu Python"
    
    if command -v python3 > /dev/null 2>&1; then
        local py_version
        py_version=$(python3 --version 2>&1 | awk '{print $2}')
        echo "  Versiune Python: ${py_version}"
        print_ok "Python 3 instalat"
        
        # Verifică pip
        if command -v pip3 > /dev/null 2>&1; then
            print_ok "pip3 disponibil"
        else
            print_warn "pip3 nu a fost găsit — instalează cu: sudo apt install python3-pip"
        fi
    else
        print_fail "Python 3 nu este instalat"
    fi
}

#-------------------------------------------------------------------------------
# Afișare sumar
#-------------------------------------------------------------------------------
print_summary() {
    echo ""
    echo -e "${BOLD}========================================${NC}"
    echo -e "${BOLD}   SUMAR VERIFICARE${NC}"
    echo -e "${BOLD}========================================${NC}"
    echo ""
    echo -e "  ${GREEN}Trecute:${NC}    ${PASSED}"
    echo -e "  ${YELLOW}Avertismente:${NC} ${WARNINGS}"
    echo -e "  ${RED}Eșuate:${NC}     ${FAILED}"
    echo ""
    
    if [[ $FAILED -eq 0 ]]; then
        echo -e "${GREEN}${BOLD}  ✓ Toate verificările critice au trecut!${NC}"
        echo -e "  ${CYAN}Ești pregătit pentru SEM01.${NC}"
    else
        echo -e "${RED}${BOLD}  ✗ Unele verificări au eșuat.${NC}"
        echo -e "  ${YELLOW}Analizează eșecurile de mai sus și rezolvă-le înainte de SEM01.${NC}"
    fi
    
    if [[ $WARNINGS -gt 0 ]]; then
        echo ""
        echo -e "  ${YELLOW}Notă: Avertismentele sunt recomandări, nu blocante.${NC}"
    fi
    
    echo ""
    echo -e "${BOLD}========================================${NC}"
}

#-------------------------------------------------------------------------------
# Execuție principală
#-------------------------------------------------------------------------------
main() {
    print_header
    check_system_info
    check_network
    check_commands
    check_ssh
    check_folders
    check_python
    print_summary
    
    # Ieșire cu cod corespunzător
    if [[ $FAILED -gt 0 ]]; then
        exit 1
    else
        exit 0
    fi
}

# Rulează funcția main
main "$@"
