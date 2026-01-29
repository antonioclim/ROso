#!/bin/bash
#===============================================================================
#          FILE: S04_05_demo_awk.sh
#   DESCRIPTION: Demo interactiv pentru comanda awk
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
    eval "$1" 2>/dev/null || echo "(error)"
    echo ""
}

pause() { read -rp "Enter pentru a continua..."; }

clear
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                    DEMO: AWK                                 ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${YELLOW}═══ 1. Câmpuri și variabile ═══${NC}"
echo ""
echo -e "${GREEN}\$0 = linia întreagă:${NC}"
run_demo "echo 'John Smith 30' | awk '{print \$0}'"

echo -e "${GREEN}\$1, \$2, \$3 = câmpuri:${NC}"
run_demo "echo 'John Smith 30' | awk '{print \$1}'"
run_demo "echo 'John Smith 30' | awk '{print \$3}'"

echo -e "${GREEN}\$NF = ultimul câmp:${NC}"
run_demo "echo 'John Smith 30 IT' | awk '{print \$NF}'"
pause

echo ""
echo -e "${YELLOW}═══ 2. CSV cu -F ═══${NC}"
echo ""
run_demo "head -3 employees.csv"
echo ""
echo -e "${GREEN}Extrage coloana Name (-F','):${NC}"
run_demo "awk -F',' '{print \$2}' employees.csv | head -5"

echo -e "${GREEN}Skip header (NR > 1):${NC}"
run_demo "awk -F',' 'NR > 1 {print \$2}' employees.csv | head -5"
pause

echo ""
echo -e "${YELLOW}═══ 3. Print cu și fără virgulă ═══${NC}"
echo ""
echo -e "${RED}FĂRĂ virgulă = concatenare:${NC}"
run_demo "echo 'a b' | awk '{print \$1 \$2}'"

echo -e "${GREEN}CU virgulă = spațiu (OFS):${NC}"
run_demo "echo 'a b' | awk '{print \$1, \$2}'"
echo -e "${YELLOW}→ Aceasta e o greșeală foarte comună!${NC}"
pause

echo ""
echo -e "${YELLOW}═══ 4. Filtrare și calcule ═══${NC}"
echo ""
echo -e "${GREEN}Filtrare pe condiție:${NC}"
run_demo "awk -F',' '\$3 == \"IT\"' employees.csv"

echo -e "${GREEN}Suma salariilor:${NC}"
run_demo "awk -F',' 'NR > 1 {sum += \$4} END {print \"Total:\", sum}' employees.csv"

echo -e "${GREEN}Media:${NC}"
run_demo "awk -F',' 'NR > 1 {sum += \$4; count++} END {print \"Media:\", sum/count}' employees.csv"
pause

echo ""
echo -e "${YELLOW}═══ 5. Array-uri asociative ═══${NC}"
echo ""
echo -e "${GREEN}Numărare per departament:${NC}"
run_demo "awk -F',' 'NR > 1 {count[\$3]++} END {for (d in count) print d, count[d]}' employees.csv"

echo -e "${GREEN}Suma per departament:${NC}"
run_demo "awk -F',' 'NR > 1 {sum[\$3] += \$4} END {for (d in sum) print d, sum[d]}' employees.csv"
pause

echo ""
echo -e "${GREEN}✓ Demo awk complet!${NC}"
