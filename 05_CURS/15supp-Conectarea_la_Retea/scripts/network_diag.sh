#!/usr/bin/env bash
#
# network_diag.sh - Script diagnostic comprehensiv pentru rețea
# Sisteme de Operare | ASE București - CSIE | 2025-2026
#
# Concepte ilustrate:
# - Utilizarea utilitarelor de diagnostic (ip, ss, ping, dig)
# - Verificare sistematică a straturilor de rețea
# - Colectare informații pentru depanare
#
# Utilizare:
#   ./network_diag.sh                    # Diagnostic complet
#   ./network_diag.sh --target google.com # Cu țintă specifică
#   ./network_diag.sh --quick            # Doar verificări esențiale
#

set -euo pipefail

# Culori pentru output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Configurare
DEFAULT_TARGET="8.8.8.8"
DNS_TARGET="google.com"
PING_COUNT=4
TIMEOUT=5

# Variabile globale
TARGET="${DEFAULT_TARGET}"
QUICK_MODE=false
VERBOSE=false

#######################################
# Funcții utilitate
#######################################

print_header() {
    echo -e "\n${BOLD}${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${BLUE}  $1${NC}"
    echo -e "${BOLD}${BLUE}════════════════════════════════════════════════════════════${NC}\n"
}

print_section() {
    echo -e "\n${CYAN}── $1 ──${NC}\n"
}

print_ok() {
    echo -e "  ${GREEN}✓${NC} $1"
}

print_warn() {
    echo -e "  ${YELLOW}⚠${NC} $1"
}

print_err() {
    echo -e "  ${RED}✗${NC} $1"
}

print_info() {
    echo -e "  ${BLUE}ℹ${NC} $1"
}

command_exists() {
    command -v "$1" &> /dev/null
}

run_with_timeout() {
    timeout "${TIMEOUT}" "$@" 2>/dev/null
}

#######################################
# Verificări sistem
#######################################

check_system_info() {
    print_section "Informații Sistem"
    
    echo "  Hostname:     $(hostname)"
    echo "  Kernel:       $(uname -r)"
    echo "  Distribuție:  $(cat /etc/os-release 2>/dev/null | grep "^PRETTY_NAME" | cut -d= -f2 | tr -d '"' || echo "N/A")"
    echo "  Data/Ora:     $(date '+%Y-%m-%d %H:%M:%S %Z')"
    echo "  Uptime:       $(uptime -p 2>/dev/null || uptime | awk -F'up ' '{print $2}' | awk -F',' '{print $1}')"
}

check_interfaces() {
    print_section "Interfețe de Rețea"
    
    if command_exists ip; then
        # Listare interfețe cu status
        echo "  Interfețe active:"
        ip -br link show | while read -r iface state rest; do
            if [[ "$state" == "UP" ]]; then
                echo -e "    ${GREEN}●${NC} ${iface}: ${state}"
            else
                echo -e "    ${RED}●${NC} ${iface}: ${state}"
            fi
        done
        
        echo ""
        echo "  Adrese IP:"
        ip -br addr show | grep -v "^lo" | while read -r iface state addrs; do
            if [[ -n "$addrs" ]]; then
                echo "    ${iface}: ${addrs}"
            fi
        done
    else
        print_warn "Comanda 'ip' nu este disponibilă"
        ifconfig 2>/dev/null || print_err "Nicio comandă de configurare rețea disponibilă"
    fi
}

check_routes() {
    print_section "Tabel de Rutare"
    
    if command_exists ip; then
        echo "  Rute principale:"
        ip route show | head -10 | while read -r line; do
            echo "    $line"
        done
        
        # Verificare gateway implicit
        default_gw=$(ip route show default 2>/dev/null | awk '{print $3}' | head -1)
        if [[ -n "$default_gw" ]]; then
            print_ok "Gateway implicit: ${default_gw}"
        else
            print_err "Niciun gateway implicit configurat"
        fi
    else
        route -n 2>/dev/null || netstat -rn 2>/dev/null || print_err "Nu se poate afișa tabela de rutare"
    fi
}

check_dns() {
    print_section "Configurație DNS"
    
    echo "  Servere DNS configurate:"
    if [[ -f /etc/resolv.conf ]]; then
        grep "^nameserver" /etc/resolv.conf | while read -r _ server; do
            echo "    - ${server}"
        done
    else
        print_warn "/etc/resolv.conf nu există"
    fi
    
    # Test rezolvare DNS
    echo ""
    echo "  Test rezolvare DNS (${DNS_TARGET}):"
    if command_exists dig; then
        resolved_ip=$(dig +short "${DNS_TARGET}" A 2>/dev/null | head -1)
        if [[ -n "$resolved_ip" ]]; then
            print_ok "Rezolvat: ${DNS_TARGET} → ${resolved_ip}"
        else
            print_err "Rezolvare DNS eșuată"
        fi
    elif command_exists host; then
        if host "${DNS_TARGET}" &>/dev/null; then
            print_ok "Rezolvare DNS funcțională"
        else
            print_err "Rezolvare DNS eșuată"
        fi
    elif command_exists nslookup; then
        if nslookup "${DNS_TARGET}" &>/dev/null; then
            print_ok "Rezolvare DNS funcțională"
        else
            print_err "Rezolvare DNS eșuată"
        fi
    else
        print_warn "Niciun utilitar DNS disponibil (dig/host/nslookup)"
    fi
}

check_connectivity() {
    print_section "Test Conectivitate"
    
    echo "  Test ICMP către ${TARGET}:"
    if ping -c "${PING_COUNT}" -W "${TIMEOUT}" "${TARGET}" &>/dev/null; then
        # Extragere statistici
        ping_output=$(ping -c "${PING_COUNT}" -W "${TIMEOUT}" "${TARGET}" 2>/dev/null)
        packet_loss=$(echo "$ping_output" | grep -oP '\d+(?=% packet loss)' || echo "N/A")
        avg_rtt=$(echo "$ping_output" | grep -oP 'avg.*?=.*?/([\d.]+)/' | grep -oP '[\d.]+' | head -1 || echo "N/A")
        
        print_ok "Conectivitate OK (pierdere: ${packet_loss}%, RTT mediu: ${avg_rtt}ms)"
    else
        print_err "Conectivitate ICMP eșuată către ${TARGET}"
    fi
    
    # Test gateway
    if [[ -n "${default_gw:-}" ]]; then
        echo ""
        echo "  Test gateway (${default_gw}):"
        if ping -c 2 -W 2 "${default_gw}" &>/dev/null; then
            print_ok "Gateway accesibil"
        else
            print_err "Gateway inaccesibil - verificați conexiunea fizică"
        fi
    fi
}

check_sockets() {
    print_section "Socket-uri și Conexiuni"
    
    if command_exists ss; then
        # Statistici sumar
        echo "  Sumar conexiuni:"
        ss -s 2>/dev/null | grep -E "^(TCP|UDP)" | while read -r line; do
            echo "    $line"
        done
        
        echo ""
        echo "  Porturi în ascultare (TCP):"
        ss -tlnp 2>/dev/null | tail -n +2 | head -10 | while read -r state recvq sendq local remote process; do
            port=$(echo "$local" | rev | cut -d: -f1 | rev)
            addr=$(echo "$local" | rev | cut -d: -f2- | rev)
            echo "    ${port}/tcp  ${addr}  ${process:-}"
        done
        
        echo ""
        echo "  Conexiuni TCP stabilite:"
        established=$(ss -tn state established 2>/dev/null | tail -n +2 | wc -l)
        print_info "${established} conexiuni active"
        
    elif command_exists netstat; then
        netstat -tlnp 2>/dev/null | head -15
    else
        print_warn "Niciun utilitar pentru inspecție socket-uri disponibil"
    fi
}

check_firewall() {
    print_section "Stare Firewall"
    
    # Verificare iptables
    if command_exists iptables; then
        echo "  iptables:"
        rules_count=$(iptables -L -n 2>/dev/null | grep -c "^" || echo "0")
        if [[ "$rules_count" -gt 6 ]]; then  # Header + politici implicite
            print_info "Reguli active: $((rules_count - 6)) (aproximativ)"
        else
            print_info "Doar politici implicite (fără reguli personalizate)"
        fi
        
        # Afișare politici
        echo "    Politici chain-uri:"
        for chain in INPUT FORWARD OUTPUT; do
            policy=$(iptables -L "$chain" -n 2>/dev/null | head -1 | grep -oP '\(policy \K\w+' || echo "N/A")
            echo "      ${chain}: ${policy}"
        done
    else
        print_warn "iptables nu este disponibil"
    fi
    
    # Verificare nftables
    if command_exists nft; then
        echo ""
        echo "  nftables:"
        tables=$(nft list tables 2>/dev/null | wc -l)
        if [[ "$tables" -gt 0 ]]; then
            print_info "${tables} tabele configurate"
        else
            print_info "Nicio tabelă nftables"
        fi
    fi
    
    # Verificare ufw (Ubuntu)
    if command_exists ufw; then
        echo ""
        echo "  UFW:"
        ufw status 2>/dev/null | head -1 | while read -r line; do
            print_info "$line"
        done
    fi
}

check_traceroute() {
    print_section "Trasare Rută către ${TARGET}"
    
    if command_exists traceroute; then
        echo "  (maxim 10 hop-uri)"
        traceroute -m 10 -w 2 "${TARGET}" 2>/dev/null | tail -n +2 | while read -r line; do
            echo "    $line"
        done
    elif command_exists tracepath; then
        tracepath -m 10 "${TARGET}" 2>/dev/null | head -12 | while read -r line; do
            echo "    $line"
        done
    else
        print_warn "Niciun utilitar traceroute disponibil"
    fi
}

#######################################
# Funcție principală
#######################################

show_help() {
    cat << EOF
Utilizare: $(basename "$0") [OPȚIUNI]

Script de diagnostic comprehensiv pentru rețea.

Opțiuni:
  -t, --target HOST    Țintă pentru teste conectivitate (implicit: ${DEFAULT_TARGET})
  -q, --quick          Mod rapid (doar verificări esențiale)
  -v, --verbose        Afișare detaliată
  -h, --help           Afișare acest mesaj

Exemple:
  $(basename "$0")                     # Diagnostic complet
  $(basename "$0") -t google.com       # Cu țintă specifică
  $(basename "$0") --quick             # Verificări rapide

EOF
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -t|--target)
                TARGET="$2"
                DNS_TARGET="$2"
                shift 2
                ;;
            -q|--quick)
                QUICK_MODE=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -h|--help)
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
}

main() {
    parse_args "$@"
    
    print_header "DIAGNOSTIC REȚEA - $(date '+%Y-%m-%d %H:%M')"
    
    # Verificări esențiale (mereu executate)
    check_system_info
    check_interfaces
    check_routes
    check_dns
    check_connectivity
    check_sockets
    
    # Verificări extinse (doar în mod complet)
    if [[ "$QUICK_MODE" == false ]]; then
        check_firewall
        check_traceroute
    fi
    
    print_header "DIAGNOSTIC COMPLET"
    
    echo -e "  ${GREEN}Diagnostic finalizat cu succes.${NC}"
    echo "  Raport generat la: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
}

main "$@"