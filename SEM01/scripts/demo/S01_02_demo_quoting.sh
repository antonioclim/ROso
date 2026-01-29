#!/bin/bash
#
# DEMO QUOTING - Demonstrație vizuală Single vs Double Quotes
# Sisteme de Operare | ASE București - CSIE
#

# Culori
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'
BOLD='\033[1m'

clear

echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}             ${WHITE}${BOLD}DEMONSTRAȚIE: SINGLE vs DOUBLE QUOTES${NC}                           ${CYAN}║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Setăm variabila de test
NUME="Student"
DATA=$(date +%Y)

echo -e "${YELLOW}Variabile setate:${NC}"
echo -e "  NUME=\"$NUME\""
echo -e "  DATA=\$(date +%Y) → \"$DATA\""
echo ""

echo -e "${WHITE}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo ""

# Demonstrație 1: Single Quotes
echo -e "${CYAN}┌─────────────────────────────────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC} ${BOLD}SINGLE QUOTES${NC} - Totul este LITERAL (nimic nu se interpretează)             ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────────────────────────────────┘${NC}"
echo ""
echo -e "${YELLOW}Comandă:${NC}  echo 'Salut \$NUME în anul \$DATA'"
echo -e "${GREEN}Output:${NC}   $(echo 'Salut $NUME în anul $DATA')"
echo ""
echo -e "${BLUE}Explicație:${NC} Caracterele \$NUME și \$DATA sunt afișate ${RED}literal${NC},"
echo -e "            nu sunt înlocuite cu valorile variabilelor."
echo ""

# Demonstrație 2: Double Quotes
echo -e "${CYAN}┌─────────────────────────────────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC} ${BOLD}DOUBLE QUOTES${NC} - Variabilele și comenzile SE interpretează                  ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────────────────────────────────┘${NC}"
echo ""
echo -e "${YELLOW}Comandă:${NC}  echo \"Salut \$NUME în anul \$DATA\""
echo -e "${GREEN}Output:${NC}   $(echo "Salut $NUME în anul $DATA")"
echo ""
echo -e "${BLUE}Explicație:${NC} \$NUME devine ${GREEN}\"$NUME\"${NC} și \$DATA devine ${GREEN}\"$DATA\"${NC}."
echo ""

# Demonstrație 3: Fără Quotes
echo -e "${CYAN}┌─────────────────────────────────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC} ${BOLD}FĂRĂ QUOTES${NC} - Interpretare + Word Splitting                                ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────────────────────────────────┘${NC}"
echo ""
echo -e "${YELLOW}Comandă:${NC}  echo Salut    \$NUME    în    anul    \$DATA"
echo -e "${GREEN}Output:${NC}   $(echo Salut    $NUME    în    anul    $DATA)"
echo ""
echo -e "${BLUE}Explicație:${NC} Variabilele se interpretează, dar ${RED}spațiile multiple${NC}"
echo -e "            sunt comprimate într-un singur spațiu (word splitting)."
echo ""

# Demonstrație 4: Problema cu spații în nume de fișiere
echo -e "${WHITE}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${CYAN}┌─────────────────────────────────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC} ${BOLD}PROBLEMĂ PRACTICĂ:${NC} Fișiere cu spații în nume                               ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────────────────────────────────┘${NC}"
echo ""

FISIER="Document Important.txt"
echo -e "${YELLOW}Variabilă:${NC} FISIER=\"Document Important.txt\""
echo ""

echo -e "${RED}❌ GREȘIT:${NC}"
echo -e "   Comandă: cat \$FISIER"
echo -e "   Bash vede: cat Document Important.txt"
echo -e "   Rezultat: ${RED}Eroare - caută 2 fișiere separate!${NC}"
echo ""

echo -e "${GREEN}✓ CORECT:${NC}"
echo -e "   Comandă: cat \"\$FISIER\""
echo -e "   Bash vede: cat \"Document Important.txt\""
echo -e "   Rezultat: ${GREEN}Funcționează corect!${NC}"
echo ""

# Tabel rezumat
echo -e "${WHITE}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${CYAN}┌─────────────────┬───────────────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}     ${BOLD}TIP${NC}         ${CYAN}│${NC}                    ${BOLD}COMPORTAMENT${NC}                         ${CYAN}│${NC}"
echo -e "${CYAN}├─────────────────┼───────────────────────────────────────────────────────────┤${NC}"
echo -e "${CYAN}│${NC} ${YELLOW}'single'${NC}        ${CYAN}│${NC} Totul literal - \$VAR rămâne \"\$VAR\"                      ${CYAN}│${NC}"
echo -e "${CYAN}├─────────────────┼───────────────────────────────────────────────────────────┤${NC}"
echo -e "${CYAN}│${NC} ${GREEN}\"double\"${NC}        ${CYAN}│${NC} \$VAR → valoare, \$(cmd) → output comandă                 ${CYAN}│${NC}"
echo -e "${CYAN}├─────────────────┼───────────────────────────────────────────────────────────┤${NC}"
echo -e "${CYAN}│${NC} ${RED}fără quotes${NC}     ${CYAN}│${NC} Ca double + word splitting (spații comprimate)           ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────┴───────────────────────────────────────────────────────────┘${NC}"
echo ""

# Regulă de aur
echo -e "${YELLOW}╔═══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║${NC}  ${BOLD}REGULĂ DE AUR:${NC} Folosește întotdeauna \"\$VARIABILA\" cu double quotes!          ${YELLOW}║${NC}"
echo -e "${YELLOW}╚═══════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
