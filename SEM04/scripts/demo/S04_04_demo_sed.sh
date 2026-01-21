#!/bin/bash
#===============================================================================
#          FILE: S04_04_demo_sed.sh
#   DESCRIPTION: Demo interactiv pentru comanda sed
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
echo -e "${CYAN}║                    DEMO: SED                                 ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${YELLOW}═══ 1. Substituție de bază ═══${NC}"
echo ""
echo -e "${GREEN}Fără /g (doar prima apariție):${NC}"
run_demo "echo 'cat cat cat' | sed 's/cat/dog/'"

echo -e "${GREEN}Cu /g (toate aparițiile):${NC}"
run_demo "echo 'cat cat cat' | sed 's/cat/dog/g'"

echo -e "${RED}De reținut: sed implicit NU modifică fișierul!${NC}"
run_demo "sed 's/localhost/127.0.0.1/' config.txt | head -3"
run_demo "grep localhost config.txt | head -1"
echo -e "${YELLOW}→ Fișierul e neschimbat, output-ul e pe stdout${NC}"
pause

echo ""
echo -e "${YELLOW}═══ 2. Edit in-place (ATENȚIE!) ═══${NC}"
echo ""
echo -e "${GREEN}Cu backup (-i.bak):${NC}"
run_demo "cp config.txt config_test.txt"
run_demo "sed -i.bak 's/localhost/127.0.0.1/' config_test.txt"
run_demo "ls config_test.*"
run_demo "rm -f config_test.txt config_test.txt.bak"
pause

echo ""
echo -e "${YELLOW}═══ 3. Delete și pattern matching ═══${NC}"
echo ""
echo -e "${GREEN}Șterge comentarii (/^#/d):${NC}"
run_demo "sed '/^#/d' config.txt | head -5"

echo -e "${GREEN}Șterge linii goale (/^\$/d):${NC}"
run_demo "sed '/^$/d' config.txt | head -10"

echo -e "${GREEN}Combinat:${NC}"
run_demo "sed '/^#/d; /^\$/d' config.txt | head -5"
pause

echo ""
echo -e "${YELLOW}═══ 4. Backreferences ═══${NC}"
echo ""
echo -e "${GREEN}& = întregul match:${NC}"
run_demo "echo 'port=8080' | sed 's/[0-9][0-9]*/[&]/'"

echo -e "${GREEN}\\1, \\2 = grupuri capturate:${NC}"
run_demo "echo 'John Smith' | sed 's/\\([A-Za-z]*\\) \\([A-Za-z]*\\)/\\2, \\1/'"
pause

echo ""
echo -e "${GREEN}✓ Demo sed complet!${NC}"
