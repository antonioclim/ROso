#!/bin/bash
#===============================================================================
# demo_monitor.sh - Demonstrație Sistem Monitoring
#===============================================================================
# Script demonstrativ pentru proiectul Monitor - Seminar 11-12
# Prezintă toate funcționalitățile sistemului de monitorizare
#
# Utilizare:
#   ./demo_monitor.sh [--interactive] [--quick]
#
# Copyright (c) 2024 - Educational Use Only
#===============================================================================

set -euo pipefail

#---------------------------------------
# Configurare
#---------------------------------------
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly MONITOR_DIR="${SCRIPT_DIR}/projects/monitor"
readonly MONITOR_SCRIPT="${MONITOR_DIR}/monitor.sh"

# Culori
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m'
readonly BOLD='\033[1m'

# Opțiuni
INTERACTIVE=false
QUICK=false

#---------------------------------------
# Funcții Utilitare
#---------------------------------------
print_banner() {
    clear
    echo -e "${CYAN}"
    cat << 'EOF'
    ╔═══════════════════════════════════════════════════════════════╗
    ║                                                               ║
    ║   ███████╗██╗   ██╗███████╗███╗   ███╗ ██████╗ ███╗   ██╗    ║
    ║   ██╔════╝╚██╗ ██╔╝██╔════╝████╗ ████║██╔═══██╗████╗  ██║    ║
    ║   ███████╗ ╚████╔╝ ███████╗██╔████╔██║██║   ██║██╔██╗ ██║    ║
    ║   ╚════██║  ╚██╔╝  ╚════██║██║╚██╔╝██║██║   ██║██║╚██╗██║    ║
    ║   ███████║   ██║   ███████║██║ ╚═╝ ██║╚██████╔╝██║ ╚████║    ║
    ║   ╚══════╝   ╚═╝   ╚══════╝╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═══╝    ║
    ║                                                               ║
    ║        D E M O N S T R A Ț I E   M O N I T O R I N G         ║
    ║                                                               ║
    ╚═══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    echo ""
}

print_section() {
    local title="$1"
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}${BOLD}  $title${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

print_step() {
    local step="$1"
    local desc="$2"
    echo -e "${GREEN}▸ ${BOLD}Pasul $step:${NC} $desc"
}

print_command() {
    local cmd="$1"
    echo -e "${YELLOW}  \$ ${cmd}${NC}"
}

print_output() {
    echo -e "${CYAN}"
    echo "$1" | head -30
    echo -e "${NC}"
}

wait_for_user() {
    if [[ "$INTERACTIVE" == "true" ]]; then
        echo ""
        read -p "$(echo -e ${WHITE}Apasă Enter pentru a continua...${NC})"
    else
        sleep 2
    fi
}

run_command() {
    local cmd="$1"
    local description="${2:-}"
    
    [[ -n "$description" ]] && echo -e "${CYAN}# $description${NC}"
    print_command "$cmd"
    echo ""
    
    # Execuție și capturare output
    local output
    output=$(eval "$cmd" 2>&1) || true
    print_output "$output"
    
    wait_for_user
}

#---------------------------------------
# Verificare Cerințe
#---------------------------------------
check_requirements() {
    print_section "VERIFICARE CERINȚE"
    
    if [[ ! -f "$MONITOR_SCRIPT" ]]; then
        echo -e "${RED}EROARE: Script monitor nu există: $MONITOR_SCRIPT${NC}"
        exit 1
    fi
    
    if [[ ! -x "$MONITOR_SCRIPT" ]]; then
        chmod +x "$MONITOR_SCRIPT"
    fi
    
    echo -e "${GREEN}✓${NC} Script monitor găsit"
    echo -e "${GREEN}✓${NC} Permisiuni OK"
    
    # Verificare dependențe
    local deps=(awk sed grep date cat)
    for dep in "${deps[@]}"; do
        if command -v "$dep" >/dev/null 2>&1; then
            echo -e "${GREEN}✓${NC} $dep disponibil"
        else
            echo -e "${YELLOW}!${NC} $dep lipsește (funcționalitate limitată)"
        fi
    done
    
    wait_for_user
}

#---------------------------------------
# Demo: Help și Versiune
#---------------------------------------
demo_help() {
    print_section "1. HELP ȘI VERSIUNE"
    
    print_step "1.1" "Afișare versiune"
    run_command "$MONITOR_SCRIPT --version"
    
    print_step "1.2" "Afișare help complet"
    run_command "$MONITOR_SCRIPT --help" "Toate opțiunile disponibile"
}

#---------------------------------------
# Demo: Monitorizare CPU
#---------------------------------------
demo_cpu() {
    print_section "2. MONITORIZARE CPU"
    
    print_step "2.1" "Verificare utilizare CPU curentă"
    run_command "$MONITOR_SCRIPT --cpu" "Afișează procentul de utilizare CPU"
    
    print_step "2.2" "CPU cu threshold warning"
    run_command "$MONITOR_SCRIPT --cpu --warn 30 --critical 80" "Alertă dacă CPU > 30%"
    
    if [[ "$QUICK" == "false" ]]; then
        print_step "2.3" "Monitorizare continuă CPU (5 secunde)"
        run_command "timeout 5 $MONITOR_SCRIPT --cpu --interval 1 --daemon 2>/dev/null || true" "Mod daemon cu interval 1s"
    fi
}

#---------------------------------------
# Demo: Monitorizare Memorie
#---------------------------------------
demo_memory() {
    print_section "3. MONITORIZARE MEMORIE"
    
    print_step "3.1" "Stare memorie RAM"
    run_command "$MONITOR_SCRIPT --memory" "Utilizare memorie RAM"
    
    print_step "3.2" "Memorie cu formatare detaliată"
    run_command "$MONITOR_SCRIPT --memory --verbose" "Informații detaliate"
    
    print_step "3.3" "Verificare SWAP"
    run_command "$MONITOR_SCRIPT --swap" "Utilizare memorie swap"
}

#---------------------------------------
# Demo: Monitorizare Disk
#---------------------------------------
demo_disk() {
    print_section "4. MONITORIZARE DISK"
    
    print_step "4.1" "Spațiu disk pe toate partițiile"
    run_command "$MONITOR_SCRIPT --disk" "Utilizare disk"
    
    print_step "4.2" "Disk cu threshold"
    run_command "$MONITOR_SCRIPT --disk --warn 50 --critical 90" "Alertă dacă disk > 50%"
    
    print_step "4.3" "Partiție specifică"
    run_command "$MONITOR_SCRIPT --disk --mount /" "Doar partiția root"
}

#---------------------------------------
# Demo: Monitorizare Procese
#---------------------------------------
demo_processes() {
    print_section "5. MONITORIZARE PROCESE"
    
    print_step "5.1" "Număr procese active"
    run_command "$MONITOR_SCRIPT --processes" "Statistici procese"
    
    print_step "5.2" "Top 5 procese după CPU"
    run_command "$MONITOR_SCRIPT --top-cpu 5" "Procese cu cel mai mare consum CPU"
    
    print_step "5.3" "Top 5 procese după memorie"
    run_command "$MONITOR_SCRIPT --top-mem 5" "Procese cu cel mai mare consum RAM"
}

#---------------------------------------
# Demo: Monitorizare Rețea
#---------------------------------------
demo_network() {
    print_section "6. MONITORIZARE REȚEA"
    
    print_step "6.1" "Statistici rețea"
    run_command "$MONITOR_SCRIPT --network" "Trafic rețea"
    
    print_step "6.2" "Conexiuni active"
    run_command "$MONITOR_SCRIPT --connections" "Conexiuni de rețea"
}

#---------------------------------------
# Demo: Raport Complet
#---------------------------------------
demo_full_report() {
    print_section "7. RAPORT COMPLET SISTEM"
    
    print_step "7.1" "Raport text"
    run_command "$MONITOR_SCRIPT --all" "Toate metrici într-un singur raport"
    
    if [[ "$QUICK" == "false" ]]; then
        print_step "7.2" "Raport JSON"
        run_command "$MONITOR_SCRIPT --all --format json | head -40" "Output în format JSON"
        
        print_step "7.3" "Raport CSV"
        run_command "$MONITOR_SCRIPT --all --format csv" "Output în format CSV"
    fi
}

#---------------------------------------
# Demo: Logging
#---------------------------------------
demo_logging() {
    print_section "8. LOGGING ȘI OUTPUT"
    
    local log_file="/tmp/monitor_demo.log"
    
    print_step "8.1" "Salvare în fișier log"
    run_command "$MONITOR_SCRIPT --all --log-file $log_file" "Output salvat în log"
    
    print_step "8.2" "Verificare conținut log"
    if [[ -f "$log_file" ]]; then
        run_command "head -20 $log_file"
    fi
    
    # Cleanup
    rm -f "$log_file"
}

#---------------------------------------
# Demo: Configurare
#---------------------------------------
demo_config() {
    print_section "9. CONFIGURARE"
    
    print_step "9.1" "Afișare configurare curentă"
    if [[ -f "${MONITOR_DIR}/etc/monitor.conf" ]]; then
        run_command "head -30 ${MONITOR_DIR}/etc/monitor.conf" "Fișier configurare"
    else
        echo -e "${YELLOW}Fișier configurare nu există${NC}"
    fi
    
    print_step "9.2" "Verificare dependențe"
    run_command "$MONITOR_SCRIPT --check-deps 2>/dev/null || echo 'Check deps nu e implementat'" "Verificare cerințe sistem"
}

#---------------------------------------
# Sumar Final
#---------------------------------------
show_summary() {
    print_section "SUMAR DEMONSTRAȚIE"
    
    echo -e "${GREEN}${BOLD}Funcționalități Prezentate:${NC}"
    echo ""
    echo "  ✓ Monitorizare CPU cu thresholds configurabile"
    echo "  ✓ Monitorizare memorie RAM și SWAP"
    echo "  ✓ Monitorizare spațiu disk pe partiții"
    echo "  ✓ Monitorizare procese (CPU, memorie)"
    echo "  ✓ Statistici rețea și conexiuni"
    echo "  ✓ Rapoarte în multiple formate (text, JSON, CSV)"
    echo "  ✓ Logging și persistență"
    echo "  ✓ Mod daemon pentru monitorizare continuă"
    echo ""
    echo -e "${CYAN}Locație proiect: ${MONITOR_DIR}${NC}"
    echo -e "${CYAN}Script principal: ${MONITOR_SCRIPT}${NC}"
    echo ""
    echo -e "${BLUE}Pentru mai multe informații:${NC}"
    echo "  $MONITOR_SCRIPT --help"
    echo "  cat ${MONITOR_DIR}/README.md"
    echo ""
}

#---------------------------------------
# Parsare Argumente
#---------------------------------------
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -i|--interactive)
                INTERACTIVE=true
                shift
                ;;
            -q|--quick)
                QUICK=true
                shift
                ;;
            -h|--help)
                echo "Utilizare: $(basename "$0") [--interactive] [--quick]"
                echo ""
                echo "Opțiuni:"
                echo "  -i, --interactive  Așteaptă input între pași"
                echo "  -q, --quick        Demonstrație rapidă (skip exemple lungi)"
                echo "  -h, --help         Afișează acest mesaj"
                exit 0
                ;;
            *)
                echo "Opțiune necunoscută: $1"
                exit 1
                ;;
        esac
    done
}

#---------------------------------------
# Main
#---------------------------------------
main() {
    parse_args "$@"
    
    print_banner
    check_requirements
    
    demo_help
    demo_cpu
    demo_memory
    demo_disk
    demo_processes
    demo_network
    demo_full_report
    demo_logging
    demo_config
    
    show_summary
    
    echo -e "${GREEN}${BOLD}Demonstrație completă!${NC}"
    echo ""
}

main "$@"
