#!/usr/bin/env bash
#
# firewall_basic.sh - Configurare firewall bazic cu iptables
# Sisteme de Operare | ASE București - CSIE | 2025-2026
#
# Concepte ilustrate:
# - Structura chain-urilor netfilter (INPUT, OUTPUT, FORWARD)
# - Politici implicite și reguli explicit
# - Connection tracking (conntrack)
# - Ordinea regulilor și best practices
#
# ATENȚIE: Acest script modifică configurația firewall!
# Rulați doar dacă înțelegeți implicațiile.
#
# Utilizare:
#   sudo ./firewall_basic.sh apply    # Aplică regulile
#   sudo ./firewall_basic.sh show     # Afișează regulile curente
#   sudo ./firewall_basic.sh reset    # Resetează la politici permisive
#   sudo ./firewall_basic.sh save     # Salvează configurația
#

set -euo pipefail

# Culori
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'
BOLD='\033[1m'

# Configurare
IPTABLES=$(command -v iptables)
IP6TABLES=$(command -v ip6tables)
SSH_PORT=22
HTTP_PORT=80
HTTPS_PORT=443

# Rețele considerate de încredere (personalizați!)
TRUSTED_NETS="192.168.0.0/16 10.0.0.0/8 172.16.0.0/12"

#######################################
# Funcții utilitate
#######################################

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_ok() {
    echo -e "${GREEN}[OK]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_err() {
    echo -e "${RED}[ERR]${NC} $1"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_err "Acest script necesită privilegii root"
        echo "Rulați: sudo $0 $*"
        exit 1
    fi
}

check_iptables() {
    if [[ -z "$IPTABLES" ]]; then
        log_err "iptables nu este instalat"
        exit 1
    fi
}

#######################################
# Funcții firewall
#######################################

flush_rules() {
    log_info "Golire reguli existente..."
    
    # Setare politici permisive temporar
    $IPTABLES -P INPUT ACCEPT
    $IPTABLES -P FORWARD ACCEPT
    $IPTABLES -P OUTPUT ACCEPT
    
    # Golire toate chain-urile
    $IPTABLES -F
    $IPTABLES -X
    $IPTABLES -t nat -F
    $IPTABLES -t nat -X
    $IPTABLES -t mangle -F
    $IPTABLES -t mangle -X
    
    # IPv6 (dacă există)
    if [[ -n "$IP6TABLES" ]]; then
        $IP6TABLES -P INPUT ACCEPT
        $IP6TABLES -P FORWARD ACCEPT
        $IP6TABLES -P OUTPUT ACCEPT
        $IP6TABLES -F
        $IP6TABLES -X
    fi
    
    log_ok "Reguli golite"
}

apply_basic_rules() {
    log_info "Aplicare set de reguli bazic..."
    
    echo ""
    echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}  APLICARE REGULI FIREWALL${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    
    # ═══════════════════════════════════════════════════════════════════════════
    # PASUL 1: Politici implicite
    # ═══════════════════════════════════════════════════════════════════════════
    log_info "Setare politici implicite (DROP pentru INPUT/FORWARD, ACCEPT pentru OUTPUT)"
    
    # INPUT: implicit DROP - tot ce nu e explicit permis este blocat
    $IPTABLES -P INPUT DROP
    
    # FORWARD: implicit DROP - nu suntem router (în mod normal)
    $IPTABLES -P FORWARD DROP
    
    # OUTPUT: implicit ACCEPT - permitem trafic generat local
    # Notă: în medii cu securitate ridicată, și OUTPUT ar fi DROP
    $IPTABLES -P OUTPUT ACCEPT
    
    log_ok "Politici setate"
    
    # ═══════════════════════════════════════════════════════════════════════════
    # PASUL 2: Trafic loopback
    # ═══════════════════════════════════════════════════════════════════════════
    log_info "Permitere trafic loopback (127.0.0.1)"
    
    # Interfața lo este esențială pentru comunicarea locală
    $IPTABLES -A INPUT -i lo -j ACCEPT
    $IPTABLES -A OUTPUT -o lo -j ACCEPT
    
    log_ok "Loopback permis"
    
    # ═══════════════════════════════════════════════════════════════════════════
    # PASUL 3: Connection tracking (stare conexiune)
    # ═══════════════════════════════════════════════════════════════════════════
    log_info "Permitere conexiuni stabilite și conexe (stateful firewall)"
    
    # ESTABLISHED: pachete parte dintr-o conexiune deja stabilită
    # RELATED: pachete conexe (ex: ICMP error pentru o conexiune TCP)
    $IPTABLES -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
    
    log_ok "Connection tracking configurat"
    
    # ═══════════════════════════════════════════════════════════════════════════
    # PASUL 4: Protecție anti-spoofing bazică
    # ═══════════════════════════════════════════════════════════════════════════
    log_info "Aplicare protecție anti-spoofing"
    
    # Blocare pachete cu stare INVALID
    $IPTABLES -A INPUT -m conntrack --ctstate INVALID -j DROP
    
    # Blocare pachete NULL (fără flaguri TCP setate)
    $IPTABLES -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
    
    # Blocare XMAS scan (toate flagurile setate)
    $IPTABLES -A INPUT -p tcp --tcp-flags ALL ALL -j DROP
    
    log_ok "Protecție anti-spoofing aplicată"
    
    # ═══════════════════════════════════════════════════════════════════════════
    # PASUL 5: ICMP (ping)
    # ═══════════════════════════════════════════════════════════════════════════
    log_info "Permitere ICMP limitat (ping)"
    
    # Permitere echo-request (ping) cu rate limiting
    # Previne flood attacks
    $IPTABLES -A INPUT -p icmp --icmp-type echo-request -m limit --limit 1/s --limit-burst 4 -j ACCEPT
    
    # Permitere alte tipuri ICMP necesare
    $IPTABLES -A INPUT -p icmp --icmp-type destination-unreachable -j ACCEPT
    $IPTABLES -A INPUT -p icmp --icmp-type time-exceeded -j ACCEPT
    
    log_ok "ICMP configurat"
    
    # ═══════════════════════════════════════════════════════════════════════════
    # PASUL 6: SSH (doar din rețele de încredere)
    # ═══════════════════════════════════════════════════════════════════════════
    log_info "Permitere SSH (port ${SSH_PORT}) din rețele de încredere"
    
    for net in $TRUSTED_NETS; do
        $IPTABLES -A INPUT -p tcp --dport ${SSH_PORT} -s "$net" -m conntrack --ctstate NEW -j ACCEPT
    done
    
    log_ok "SSH permis din: ${TRUSTED_NETS}"
    
    # ═══════════════════════════════════════════════════════════════════════════
    # PASUL 7: Servicii web (opțional - comentat implicit)
    # ═══════════════════════════════════════════════════════════════════════════
    # Decomentați dacă rulați un server web
    
    # log_info "Permitere HTTP/HTTPS"
    # $IPTABLES -A INPUT -p tcp --dport ${HTTP_PORT} -m conntrack --ctstate NEW -j ACCEPT
    # $IPTABLES -A INPUT -p tcp --dport ${HTTPS_PORT} -m conntrack --ctstate NEW -j ACCEPT
    # log_ok "HTTP/HTTPS permis"
    
    # ═══════════════════════════════════════════════════════════════════════════
    # PASUL 8: Logging pentru pachete blocate
    # ═══════════════════════════════════════════════════════════════════════════
    log_info "Configurare logging pentru pachete blocate"
    
    # Creăm un chain dedicat pentru logging
    $IPTABLES -N LOG_DROP 2>/dev/null || $IPTABLES -F LOG_DROP
    $IPTABLES -A LOG_DROP -m limit --limit 5/min --limit-burst 10 -j LOG --log-prefix "IPT_DROP: " --log-level 4
    $IPTABLES -A LOG_DROP -j DROP
    
    # Redirecționăm pachetele nedorite către chain-ul de logging
    $IPTABLES -A INPUT -j LOG_DROP
    
    log_ok "Logging configurat (verificați /var/log/kern.log sau dmesg)"
    
    # ═══════════════════════════════════════════════════════════════════════════
    # IPv6 (reguli similare)
    # ═══════════════════════════════════════════════════════════════════════════
    if [[ -n "$IP6TABLES" ]]; then
        log_info "Aplicare reguli IPv6..."
        
        $IP6TABLES -P INPUT DROP
        $IP6TABLES -P FORWARD DROP
        $IP6TABLES -P OUTPUT ACCEPT
        
        $IP6TABLES -A INPUT -i lo -j ACCEPT
        $IP6TABLES -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
        $IP6TABLES -A INPUT -m conntrack --ctstate INVALID -j DROP
        
        # ICMPv6 este mai important decât ICMP pentru IPv6
        $IP6TABLES -A INPUT -p ipv6-icmp -j ACCEPT
        
        log_ok "Reguli IPv6 aplicate"
    fi
    
    echo ""
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  FIREWALL CONFIGURAT CU SUCCES${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
    echo ""
}

show_rules() {
    echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}  REGULI IPTABLES CURENTE${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    
    echo -e "${BLUE}─── Filter Table ───${NC}"
    $IPTABLES -L -n -v --line-numbers
    
    echo ""
    echo -e "${BLUE}─── NAT Table ───${NC}"
    $IPTABLES -t nat -L -n -v --line-numbers
    
    if [[ -n "$IP6TABLES" ]]; then
        echo ""
        echo -e "${BLUE}─── IPv6 Filter Table ───${NC}"
        $IP6TABLES -L -n -v --line-numbers
    fi
}

reset_rules() {
    log_warn "Resetare la politici permisive (ACCEPT all)"
    
    flush_rules
    
    echo ""
    log_ok "Firewall resetat - tot traficul este permis"
    log_warn "Sistemul este acum fără protecție firewall!"
}

save_rules() {
    log_info "Salvare reguli..."
    
    SAVE_FILE="/etc/iptables/rules.v4"
    SAVE_FILE_V6="/etc/iptables/rules.v6"
    
    # Creare director dacă nu există
    mkdir -p /etc/iptables
    
    # Salvare
    iptables-save > "$SAVE_FILE"
    log_ok "Reguli IPv4 salvate în: ${SAVE_FILE}"
    
    if [[ -n "$IP6TABLES" ]]; then
        ip6tables-save > "$SAVE_FILE_V6"
        log_ok "Reguli IPv6 salvate în: ${SAVE_FILE_V6}"
    fi
    
    echo ""
    log_info "Pentru restaurare automată la boot, instalați iptables-persistent:"
    echo "    sudo apt install iptables-persistent"
    echo "    sudo netfilter-persistent save"
}

show_help() {
    cat << EOF
${BOLD}firewall_basic.sh${NC} - Script configurare firewall bazic

${BOLD}UTILIZARE:${NC}
    sudo $0 <comandă>

${BOLD}COMENZI:${NC}
    apply    Aplică setul de reguli bazic
    show     Afișează regulile curente
    reset    Resetează la politici permisive (ACCEPT all)
    save     Salvează configurația pentru persistență

${BOLD}EXEMPLE:${NC}
    sudo $0 apply    # Aplică firewall-ul
    sudo $0 show     # Verifică regulile
    sudo $0 reset    # Dezactivează firewall-ul

${BOLD}ATENȚIE:${NC}
    - Acest script modifică configurația de securitate a sistemului
    - Testați întâi pe un sistem non-producție
    - Asigurați-vă că aveți acces alternativ (console) în caz de blocare

${BOLD}PERSONALIZARE:${NC}
    Editați variabilele din script:
    - SSH_PORT: portul SSH (implicit: 22)
    - TRUSTED_NETS: rețelele permise pentru SSH

EOF
}

#######################################
# Main
#######################################

main() {
    if [[ $# -lt 1 ]]; then
        show_help
        exit 1
    fi
    
    check_iptables
    
    case "$1" in
        apply)
            check_root
            flush_rules
            apply_basic_rules
            ;;
        show)
            show_rules
            ;;
        reset)
            check_root
            reset_rules
            ;;
        save)
            check_root
            save_rules
            ;;
        -h|--help|help)
            show_help
            ;;
        *)
            log_err "Comandă necunoscută: $1"
            show_help
            exit 1
            ;;
    esac
}

main "$@"
