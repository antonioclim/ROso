#!/bin/bash
#
# DEMO VARIABILE - Vizualizare Local vs Export
# Sisteme de Operare | ASE București - CSIE
#

# Culori
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
MAGENTA='\033[0;35m'
NC='\033[0m'
BOLD='\033[1m'

# Funcție pentru pauză dramatică
pause() {
    echo -e "\n${YELLOW}[Apasă Enter pentru a continua...]${NC}"
    read
}

clear

echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}              ${WHITE}${BOLD}DEMONSTRAȚIE: VARIABILE ÎN BASH${NC}                                ${CYAN}║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

#
# PARTEA 1: Tipuri de Variabile
#

echo -e "${WHITE}${BOLD}PARTEA 1: Tipuri de Variabile${NC}"
echo ""

echo -e "${CYAN}┌─────────────────────────────────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}                         ${BOLD}TIPURI DE VARIABILE${NC}                                  ${CYAN}│${NC}"
echo -e "${CYAN}├─────────────────────┬─────────────────────┬─────────────────────────────────┤${NC}"
echo -e "${CYAN}│${NC}      ${YELLOW}LOCALE${NC}         ${CYAN}│${NC}   ${GREEN}MEDIU (export)${NC}    ${CYAN}│${NC}         ${MAGENTA}SPECIALE${NC}              ${CYAN}│${NC}"
echo -e "${CYAN}├─────────────────────┼─────────────────────┼─────────────────────────────────┤${NC}"
echo -e "${CYAN}│${NC} VAR=\"valoare\"       ${CYAN}│${NC} export VAR=\"val\"    ${CYAN}│${NC} \$? \$\$ \$! \$0 \$1-\$9             ${CYAN}│${NC}"
echo -e "${CYAN}│${NC}                     ${CYAN}│${NC}                     ${CYAN}│${NC}                                 ${CYAN}│${NC}"
echo -e "${CYAN}│${NC} Există DOAR în     ${CYAN}│${NC} Moștenite de        ${CYAN}│${NC} Setate automat de shell         ${CYAN}│${NC}"
echo -e "${CYAN}│${NC} shell-ul curent    ${CYAN}│${NC} subprocese          ${CYAN}│${NC}                                 ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────┴─────────────────────┴─────────────────────────────────┘${NC}"
echo ""

pause

#
# PARTEA 2: Demonstrație Locală vs Export
#

clear
echo -e "${WHITE}${BOLD}PARTEA 2: Local vs Export - Demonstrație Practică${NC}"
echo ""

echo -e "${YELLOW}Pas 1: Setăm o variabilă LOCALĂ${NC}"
echo -e "${BLUE}Comandă:${NC} LOCAL_VAR=\"Sunt locală\""
LOCAL_VAR="Sunt locală"
echo ""

echo -e "${YELLOW}Pas 2: Setăm o variabilă de MEDIU (export)${NC}"
echo -e "${BLUE}Comandă:${NC} export GLOBAL_VAR=\"Sunt globală\""
export GLOBAL_VAR="Sunt globală"
echo ""

echo -e "${WHITE}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${WHITE}${BOLD}Vizualizare: Ce vede fiecare proces?${NC}"
echo -e "${WHITE}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo ""

echo -e "${CYAN}┌─────────────────────────────────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}                    ${BOLD}SHELL PRINCIPAL (PID: $$)${NC}                                ${CYAN}│${NC}"
echo -e "${CYAN}│${NC}  LOCAL_VAR = ${GREEN}\"$LOCAL_VAR\"${NC}                                              ${CYAN}│${NC}"
echo -e "${CYAN}│${NC}  GLOBAL_VAR = ${GREEN}\"$GLOBAL_VAR\"${NC}                                            ${CYAN}│${NC}"
echo -e "${CYAN}│${NC}                                                                             ${CYAN}│${NC}"
echo -e "${CYAN}│${NC}        │                                                                    ${CYAN}│${NC}"
echo -e "${CYAN}│${NC}        │ fork()                                                             ${CYAN}│${NC}"
echo -e "${CYAN}│${NC}        ▼                                                                    ${CYAN}│${NC}"
echo -e "${CYAN}│${NC}   ┌─────────────────────────────────────────────────────────────────┐      ${CYAN}│${NC}"
echo -e "${CYAN}│${NC}   │              ${BOLD}SUBSHELL (proces copil)${NC}                            │      ${CYAN}│${NC}"
echo -e "${CYAN}│${NC}   │  LOCAL_VAR = ${RED}(gol - nu se moștenește!)${NC}                        │      ${CYAN}│${NC}"
echo -e "${CYAN}│${NC}   │  GLOBAL_VAR = ${GREEN}\"Sunt globală\"${NC}                                  │      ${CYAN}│${NC}"
echo -e "${CYAN}│${NC}   └─────────────────────────────────────────────────────────────────┘      ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────────────────────────────────┘${NC}"
echo ""

echo -e "${YELLOW}Verificare în subshell:${NC}"
echo -e "${BLUE}Comandă:${NC} bash -c 'echo \"LOCAL: \$LOCAL_VAR | GLOBAL: \$GLOBAL_VAR\"'"
echo -e "${GREEN}Output:${NC}  $(bash -c 'echo "LOCAL: $LOCAL_VAR | GLOBAL: $GLOBAL_VAR"')"
echo ""

pause

#
# PARTEA 3: Variabile Speciale
#

clear
echo -e "${WHITE}${BOLD}PARTEA 3: Variabile Speciale${NC}"
echo ""

echo -e "${CYAN}┌─────────────┬────────────────────────────────────┬────────────────────┐${NC}"
echo -e "${CYAN}│${NC}  ${BOLD}Variabilă${NC}  ${CYAN}│${NC}           ${BOLD}Semnificație${NC}               ${CYAN}│${NC}    ${BOLD}Valoare Actuală${NC}  ${CYAN}│${NC}"
echo -e "${CYAN}├─────────────┼────────────────────────────────────┼────────────────────┤${NC}"
echo -e "${CYAN}│${NC}    \$?       ${CYAN}│${NC} Exit code ultima comandă          ${CYAN}│${NC}        $?             ${CYAN}│${NC}"
echo -e "${CYAN}│${NC}    \$\$       ${CYAN}│${NC} PID shell curent                  ${CYAN}│${NC}        $$           ${CYAN}│${NC}"
echo -e "${CYAN}│${NC}    \$USER    ${CYAN}│${NC} Utilizatorul curent               ${CYAN}│${NC}   $(printf '%-15s' "$USER")  ${CYAN}│${NC}"
echo -e "${CYAN}│${NC}    \$HOME    ${CYAN}│${NC} Directorul home                   ${CYAN}│${NC}   $(printf '%-15s' "$HOME" | head -c 15)... ${CYAN}│${NC}"
echo -e "${CYAN}│${NC}    \$SHELL   ${CYAN}│${NC} Shell-ul curent                   ${CYAN}│${NC}   $(printf '%-15s' "$SHELL")  ${CYAN}│${NC}"
echo -e "${CYAN}│${NC}    \$PWD     ${CYAN}│${NC} Directorul curent                 ${CYAN}│${NC}   $(printf '%-15s' "$(basename "$PWD")")  ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────┴────────────────────────────────────┴────────────────────┘${NC}"
echo ""

echo -e "${YELLOW}Demonstrație \$? (exit code):${NC}"
echo ""

echo -e "${BLUE}Comandă:${NC} ls /tmp > /dev/null"
ls /tmp > /dev/null
echo -e "${GREEN}Exit code: $?${NC} (0 = succes)"
echo ""

echo -e "${BLUE}Comandă:${NC} ls /director_inexistent 2>/dev/null"
ls /director_inexistent 2>/dev/null
echo -e "${RED}Exit code: $?${NC} (non-zero = eroare)"
echo ""

pause

#
# PARTEA 4: Erori Comune
#

clear
echo -e "${WHITE}${BOLD}PARTEA 4: Erori Comune cu Variabile${NC}"
echo ""

echo -e "${RED}╔═══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║${NC}                         ${BOLD}EROARE #1: Spații${NC}                                     ${RED}║${NC}"
echo -e "${RED}╚═══════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${RED}❌ GREȘIT:${NC}  VARSTA = 25"
echo -e "            Bash interpretează 'VARSTA' ca o COMANDĂ!"
echo ""

echo -e "${GREEN}✓ CORECT:${NC}  VARSTA=25"
echo -e "            Fără spații în jurul semnului ="
echo ""

echo -e "${RED}╔═══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║${NC}                     ${BOLD}EROARE #2: $ la atribuire${NC}                                 ${RED}║${NC}"
echo -e "${RED}╚═══════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${RED}❌ GREȘIT:${NC}  \$NUME=\"Ion\""
echo -e "            \$ este pentru CITIRE, nu pentru atribuire!"
echo ""

echo -e "${GREEN}✓ CORECT:${NC}  NUME=\"Ion\"      (atribuire)"
echo -e "            echo \$NUME     (citire)"
echo ""

echo -e "${RED}╔═══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║${NC}                   ${BOLD}EROARE #3: Lipsa ghilimelelor${NC}                               ${RED}║${NC}"
echo -e "${RED}╚═══════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${RED}❌ GREȘIT:${NC}  MESAJ=Salut lume"
echo -e "            Bash vede: MESAJ=Salut și apoi încearcă să ruleze 'lume'"
echo ""

echo -e "${GREEN}✓ CORECT:${NC}  MESAJ=\"Salut lume\""
echo -e "            Ghilimelele grupează textul"
echo ""

#
# Rezumat Final
#

echo -e "${WHITE}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC}                          ${BOLD}REGULI DE AUR${NC}                                        ${GREEN}║${NC}"
echo -e "${GREEN}╠═══════════════════════════════════════════════════════════════════════════════╣${NC}"
echo -e "${GREEN}║${NC}  1. FĂRĂ spații în jurul = la atribuire: VAR=valoare                        ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}  2. Folosește \$ pentru CITIRE: echo \$VAR                                    ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}  3. export pentru a face variabila disponibilă în subprocese                ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}  4. Folosește ghilimele pentru valori cu spații: VAR=\"text cu spații\"       ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}  5. Verifică \$? după comenzi pentru a vedea dacă au reușit                  ${GREEN}║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
