#!/bin/bash
#===============================================================================
#
#          FILE: S04_01_hook_demo.sh
#
#         USAGE: ./S04_01_hook_demo.sh
#
#   DESCRIPTION: Demo spectaculos pentru hook-ul de la începutul seminarului
#                Analizează un access.log și generează un raport de securitate
#                în timp real, demonstrând puterea text processing-ului
#
#        AUTHOR: Asistent Universitar - Seminarul SO
#       VERSION: 1.0
#
#===============================================================================

set -euo pipefail

readonly DATA_DIR="$HOME/demo_sem4/data"

# Culori
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# Funcție pentru typing effect
type_text() {
    local text="$1"
    local delay="${2:-0.03}"
    for ((i=0; i<${#text}; i++)); do
        echo -n "${text:$i:1}"
        sleep "$delay"
    done
    echo ""
}

# Funcție pentru pause dramatică
pause() {
    local msg="${1:-Apasă Enter pentru a continua...}"
    echo ""
    read -rp "$msg"
}

# Verificare date
if [[ ! -f "$DATA_DIR/access.log" ]]; then
    echo -e "${RED}[ERROR] Rulează mai întâi: ./S04_01_setup_seminar.sh${NC}"
    exit 1
fi

cd "$DATA_DIR"

clear

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}                                                                          ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}     ${BOLD}🚨 SCENARIUL: INCIDENT DE SECURITATE 🚨${NC}                           ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}                                                                          ${CYAN}║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

type_text "Șeful vine la tine în birou la ora 9 dimineața..." 0.05
sleep 1
echo ""
type_text "  \"Site-ul a fost atacat ieri noapte.\"" 0.05
type_text "  \"Am nevoie de un raport în 5 minute:\"" 0.05
type_text "    - Cine a făcut atacul?\"" 0.05
type_text "    - De unde?\"" 0.05
type_text "    - Ce au încercat să acceseze?\"" 0.05
echo ""

pause

echo ""
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}PASUL 1: Verificăm dimensiunea log-ului${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo ""

echo -e "${BLUE}$ wc -l access.log${NC}"
sleep 0.5
wc -l access.log
echo ""
echo -e "${GREEN}→ Peste 2000 de linii de log! Manual ar dura ore...${NC}"

pause

echo ""
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}PASUL 2: Top 5 IP-uri suspecte${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo ""

echo -e "${BLUE}$ awk '{print \$1}' access.log | sort | uniq -c | sort -rn | head -5${NC}"
sleep 0.5
awk '{print $1}' access.log | sort | uniq -c | sort -rn | head -5
echo ""
echo -e "${GREEN}→ IP-urile cu cele mai multe cereri - posibili atacatori!${NC}"

pause

echo ""
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}PASUL 3: Ce au încercat să acceseze?${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo ""

echo -e "${BLUE}$ grep -E '(admin|config|\.env|wp-)' access.log | awk '{print \$7}' | sort | uniq -c | sort -rn${NC}"
sleep 0.5
grep -E '(admin|config|\.env|wp-)' access.log | awk '{print $7}' | sort | uniq -c | sort -rn | head -10
echo ""
echo -e "${RED}→ Scanare de vulnerabilități! Caută panouri admin și fișiere sensibile!${NC}"

pause

echo ""
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}PASUL 4: Câte cereri eșuate?${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo ""

echo -e "${BLUE}$ grep -cE '\" [45][0-9]{2} ' access.log${NC}"
sleep 0.5
grep -cE '" [45][0-9]{2} ' access.log || echo "0"
echo ""
echo -e "${GREEN}→ Numarul de cereri cu erori 4xx și 5xx${NC}"

pause

echo ""
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}RAPORT FINAL - GENERAT ÎN 30 SECUNDE!${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo ""

echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║           📊 SECURITY INCIDENT REPORT 📊                    ║${NC}"
echo -e "${CYAN}╠══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${CYAN}║${NC}"

echo -e "${CYAN}║${NC} ${BOLD}🔍 Top 5 Source IPs:${NC}"
awk '{print $1}' access.log | sort | uniq -c | sort -rn | head -5 | while read count ip; do
    printf "${CYAN}║${NC}    %-20s %6d requests\n" "$ip" "$count"
done

echo -e "${CYAN}║${NC}"
echo -e "${CYAN}║${NC} ${BOLD}🚨 Suspicious Requests:${NC}"
susp_count=$(grep -cE '(admin|config|\.env|wp-|phpmyadmin)' access.log || echo "0")
echo -e "${CYAN}║${NC}    Total: ${RED}$susp_count${NC} potential attack attempts"

echo -e "${CYAN}║${NC}"
echo -e "${CYAN}║${NC} ${BOLD}❌ Failed Requests (4xx/5xx):${NC}"
fail_count=$(grep -cE '" [45][0-9]{2} ' access.log || echo "0")
echo -e "${CYAN}║${NC}    Total: ${YELLOW}$fail_count${NC} failed requests"

echo -e "${CYAN}║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"

echo ""
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC}                                                              ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}  ${BOLD}Asta e puterea text processing-ului în Linux!${NC}             ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}                                                              ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}  Astăzi învățați să faceți exact asta cu:                   ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}    • grep - căutare pattern-uri                             ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}    • sed  - transformări text                               ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}    • awk  - procesare structurată                           ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}                                                              ${GREEN}║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
