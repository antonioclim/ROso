#!/bin/bash
#===============================================================================
#          FILE: S04_02_demo_regex.sh
#   DESCRIPTION: Demo interactiv pentru expresii regulate
#===============================================================================

set -euo pipefail

readonly DATA_DIR="$HOME/demo_sem4/data"
readonly BLUE='\033[0;34m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

cd "$DATA_DIR"

run_demo() {
    echo -e "${BLUE}$ $1${NC}"
    sleep 0.3
    eval "$1"
    echo ""
}

pause() {
    read -rp "Apasă Enter pentru a continua..."
}

clear
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║              DEMO: EXPRESII REGULATE (REGEX)                ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Demo 1: Punct
echo -e "${YELLOW}═══ 1. Metacaracterul . (punct) ═══${NC}"
echo ""
echo -e "${GREEN}Creăm un fișier de test:${NC}"
run_demo "echo -e 'abc\nac\naXc\na1c\nabbc' > test_dot.txt"
run_demo "cat test_dot.txt"
echo ""
echo -e "${GREEN}Pattern 'a.c' (punct = orice caracter):${NC}"
run_demo "grep 'a.c' test_dot.txt"
echo -e "${YELLOW}→ 'ac' nu apare pentru că . cere EXACT un caracter!${NC}"
pause

# Demo 2: Anchors
echo ""
echo -e "${YELLOW}═══ 2. Anchors: ^ și $ ═══${NC}"
echo ""
run_demo "echo -e 'Start here\nNot Start\nStarting' > test_anchor.txt"
run_demo "cat test_anchor.txt"
echo ""
echo -e "${GREEN}Pattern '^Start' (început de linie):${NC}"
run_demo "grep '^Start' test_anchor.txt"
pause

# Demo 3: BRE vs ERE
echo ""
echo -e "${YELLOW}═══ 3. BRE vs ERE - DIFERENȚA CRITICĂ ═══${NC}"
echo ""
run_demo "echo -e 'ac\nabc\nabbc\nabbbc' > test_quant.txt"
echo ""
echo -e "${RED}GREȘIT - grep în BRE:${NC}"
run_demo "grep 'ab+c' test_quant.txt || echo '(nimic găsit!)'"
echo ""
echo -e "${GREEN}CORECT - grep -E în ERE:${NC}"
run_demo "grep -E 'ab+c' test_quant.txt"
echo ""
echo -e "${YELLOW}→ În BRE, + este caracter LITERAL! Folosește -E pentru quantificatori.${NC}"
pause

# Demo 4: Clase de caractere
echo ""
echo -e "${YELLOW}═══ 4. Clase de caractere ═══${NC}"
echo ""
echo -e "${GREEN}[0-9] = cifre:${NC}"
run_demo "echo -e 'abc123\ntest\n456' | grep '[0-9]'"
echo ""
echo -e "${GREEN}[^0-9] = NOT cifre (un caracter):${NC}"
run_demo "echo -e 'abc123\n456' | grep '[^0-9]'"
echo -e "${YELLOW}→ Atenție! Găsește linii cu CEL PUȚIN un non-digit, nu linii FĂRĂ cifre!${NC}"
echo ""
echo -e "${GREEN}Linii FĂRĂ cifre (grep -v):${NC}"
run_demo "echo -e 'abc123\ntest\n456' | grep -v '[0-9]'"
pause

# Cleanup
rm -f test_dot.txt test_anchor.txt test_quant.txt 2>/dev/null

echo ""
echo -e "${GREEN}✓ Demo regex complet!${NC}"
