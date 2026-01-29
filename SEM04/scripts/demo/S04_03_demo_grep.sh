#!/bin/bash
#===============================================================================
#          FILE: S04_03_demo_grep.sh
#   DESCRIPTION: Demo interactiv pentru comanda grep
#===============================================================================

set -euo pipefail

readonly DATA_DIR="$HOME/demo_sem4/data"
readonly BLUE='\033[0;34m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

cd "$DATA_DIR"

run_demo() {
    echo -e "${BLUE}$ $1${NC}"
    sleep 0.3
    eval "$1" 2>/dev/null || echo "(no output)"
    echo ""
}

pause() { read -rp "Enter pentru a continua..."; }

clear
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                    DEMO: GREP                                ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${YELLOW}═══ 1. Opțiuni de bază ═══${NC}"
echo ""
echo -e "${GREEN}-i (case insensitive):${NC}"
run_demo "grep -i 'get' access.log | head -3"

echo -e "${GREEN}-v (inversare - ce NU potrivește):${NC}"
run_demo "grep -v '^#' config.txt | head -5"

echo -e "${GREEN}-n (număr linie):${NC}"
run_demo "grep -n 'IT' employees.csv"
pause

echo ""
echo -e "${YELLOW}═══ 2. Numărare și extragere ═══${NC}"
echo ""
echo -e "${GREEN}-c (numără LINII, nu aparițiile!):${NC}"
run_demo "grep -c 'GET' access.log"

echo -e "${GREEN}-o (extrage DOAR match-ul):${NC}"
run_demo "grep -oE '([0-9]{1,3}\\.){3}[0-9]{1,3}' access.log | head -5"

echo -e "${GREEN}Numară TOATE aparițiile (grep -o | wc -l):${NC}"
run_demo "grep -o 'GET' access.log | wc -l"
pause

echo ""
echo -e "${YELLOW}═══ 3. Context și recursiv ═══${NC}"
echo ""
echo -e "${GREEN}-A/-B/-C (context):${NC}"
run_demo "grep -B 1 -A 1 '403' access.log | head -10"

echo -e "${GREEN}-r (recursiv):${NC}"
run_demo "grep -rn 'localhost' . 2>/dev/null | head -5"
pause

echo ""
echo -e "${GREEN}✓ Demo grep complet!${NC}"
