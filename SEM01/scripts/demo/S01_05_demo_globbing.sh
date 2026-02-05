#!/bin/bash
#
# DEMO GLOBBING - Wildcards și Pattern Matching
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

# Crează director temporar pentru demo
DEMO_DIR=$(mktemp -d)
cd "$DEMO_DIR"

# Funcție cleanup
cleanup() {
    cd ~
    rm -rf "$DEMO_DIR"
}
trap cleanup EXIT

clear

echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}            ${WHITE}${BOLD}DEMONSTRAȚIE: GLOBBING (WILDCARDS)${NC}                              ${CYAN}║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

#
# Creare fișiere de test
#

echo -e "${YELLOW}► Creare fișiere de test...${NC}"
touch file{1..10}.txt
touch doc{A..E}.pdf
touch image{01..05}.jpg
touch script{1..3}.sh
touch .hidden_file
touch "Document cu spatii.txt"
echo ""

echo -e "${GREEN}Fișiere create:${NC}"
ls -la
echo ""

read -p "Apasă Enter pentru a continua..."
clear

#
# Pattern: * (asterisk)
#

echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}  ${BOLD}PATTERN: * (asterisk)${NC} - Potrivește ZERO sau MAI MULTE caractere             ${CYAN}║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${YELLOW}Comandă:${NC} ls *.txt"
echo -e "${GREEN}Rezultat:${NC}"
ls *.txt
echo ""

echo -e "${YELLOW}Comandă:${NC} ls file*"
echo -e "${GREEN}Rezultat:${NC}"
ls file*
echo ""

echo -e "${YELLOW}Comandă:${NC} ls *"
echo -e "${GREEN}Rezultat:${NC}"
ls *
echo ""

echo -e "${RED}⚠️  Capcană: * NU include fișierele ascunse (.hidden_file)!${NC}"
echo -e "${BLUE}Pentru a vedea fișierele ascunse, folosește: ls .*${NC}"
echo ""

read -p "Apasă Enter pentru a continua..."
clear

#
# Pattern: ? (question mark)
#

echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}  ${BOLD}PATTERN: ? (question mark)${NC} - Potrivește EXACT UN caracter                    ${CYAN}║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${YELLOW}Comandă:${NC} ls file?.txt"
echo -e "${GREEN}Rezultat:${NC}"
ls file?.txt 2>/dev/null || echo "(niciun rezultat)"
echo ""
echo -e "${BLUE}Explicație:${NC} Potrivește file1.txt - file9.txt, dar ${RED}NU${NC} file10.txt"
echo -e "            (10 are DOUĂ caractere, ? potrivește doar unul)"
echo ""

echo -e "${YELLOW}Comandă:${NC} ls image??.jpg"
echo -e "${GREEN}Rezultat:${NC}"
ls image??.jpg
echo ""
echo -e "${BLUE}Explicație:${NC} ?? potrivește exact 2 caractere (01, 02, 03...)"
echo ""

read -p "Apasă Enter pentru a continua..."
clear

#
# Pattern: [...] (bracket expression)
#

echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}  ${BOLD}PATTERN: [...] (brackets)${NC} - Potrivește UN caracter din set                   ${CYAN}║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${YELLOW}Comandă:${NC} ls file[135].txt"
echo -e "${GREEN}Rezultat:${NC}"
ls file[135].txt
echo ""
echo -e "${BLUE}Explicație:${NC} Potrivește file1.txt, file3.txt, file5.txt"
echo ""

echo -e "${YELLOW}Comandă:${NC} ls file[1-5].txt"
echo -e "${GREEN}Rezultat:${NC}"
ls file[1-5].txt
echo ""
echo -e "${BLUE}Explicație:${NC} Range - potrivește file1.txt până la file5.txt"
echo ""

echo -e "${YELLOW}Comandă:${NC} ls doc[A-C].pdf"
echo -e "${GREEN}Rezultat:${NC}"
ls doc[A-C].pdf
echo ""
echo -e "${BLUE}Explicație:${NC} Range alfabetic - potrivește docA.pdf, docB.pdf, docC.pdf"
echo ""

read -p "Apasă Enter pentru a continua..."
clear

#
# Brace Expansion {...}
#

echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}  ${BOLD}BRACE EXPANSION: {...}${NC} - Generează liste (NU e globbing!)                    ${CYAN}║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${MAGENTA}De reținut: Brace expansion e diferit de globbing!${NC}"
echo -e "Brace expansion generează text ÎNAINTE de a verifica ce fișiere există."
echo ""

echo -e "${YELLOW}Comandă:${NC} echo {A,B,C}"
echo -e "${GREEN}Rezultat:${NC} $(echo {A,B,C})"
echo ""

echo -e "${YELLOW}Comandă:${NC} echo file{1..5}.txt"
echo -e "${GREEN}Rezultat:${NC} $(echo file{1..5}.txt)"
echo ""

echo -e "${YELLOW}Comandă:${NC} echo {a..z}"
echo -e "${GREEN}Rezultat:${NC} $(echo {a..z})"
echo ""

echo -e "${YELLOW}Comandă:${NC} mkdir -p proiect/{src,docs,tests}"
echo -e "${GREEN}Rezultat:${NC} Creează 3 directoare simultan!"
mkdir -p proiect/{src,docs,tests}
ls -d proiect/*/
echo ""

read -p "Apasă Enter pentru a continua..."
clear

#
# Tabel Comparativ
#

echo -e "${WHITE}${BOLD}TABEL COMPARATIV - WILDCARDS${NC}"
echo ""

echo -e "${CYAN}┌──────────┬─────────────────────────────────┬─────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC} ${BOLD}Pattern${NC}  ${CYAN}│${NC}          ${BOLD}Descriere${NC}                ${CYAN}│${NC}           ${BOLD}Exemplu${NC}               ${CYAN}│${NC}"
echo -e "${CYAN}├──────────┼─────────────────────────────────┼─────────────────────────────────┤${NC}"
echo -e "${CYAN}│${NC}    ${YELLOW}*${NC}     ${CYAN}│${NC} Zero sau mai multe caractere   ${CYAN}│${NC} *.txt → toate fișierele .txt   ${CYAN}│${NC}"
echo -e "${CYAN}├──────────┼─────────────────────────────────┼─────────────────────────────────┤${NC}"
echo -e "${CYAN}│${NC}    ${YELLOW}?${NC}     ${CYAN}│${NC} Exact UN caracter              ${CYAN}│${NC} file?.txt → file1, NU file10   ${CYAN}│${NC}"
echo -e "${CYAN}├──────────┼─────────────────────────────────┼─────────────────────────────────┤${NC}"
echo -e "${CYAN}│${NC}  ${YELLOW}[abc]${NC}  ${CYAN}│${NC} Un caracter din set            ${CYAN}│${NC} file[123].txt → file1,2,3      ${CYAN}│${NC}"
echo -e "${CYAN}├──────────┼─────────────────────────────────┼─────────────────────────────────┤${NC}"
echo -e "${CYAN}│${NC}  ${YELLOW}[a-z]${NC}  ${CYAN}│${NC} Un caracter din range          ${CYAN}│${NC} [a-c].txt → a.txt, b.txt, c.txt${CYAN}│${NC}"
echo -e "${CYAN}├──────────┼─────────────────────────────────┼─────────────────────────────────┤${NC}"
echo -e "${CYAN}│${NC}  ${YELLOW}[!ab]${NC}  ${CYAN}│${NC} Un caracter EXCEPTÂND          ${CYAN}│${NC} file[!0-5].txt → file6-9       ${CYAN}│${NC}"
echo -e "${CYAN}├──────────┼─────────────────────────────────┼─────────────────────────────────┤${NC}"
echo -e "${CYAN}│${NC} ${YELLOW}{a,b,c}${NC} ${CYAN}│${NC} Brace expansion (generare)     ${CYAN}│${NC} {a,b}.txt → a.txt b.txt        ${CYAN}│${NC}"
echo -e "${CYAN}└──────────┴─────────────────────────────────┴─────────────────────────────────┘${NC}"
echo ""

#
# Quiz Rapid
#

echo -e "${WHITE}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${WHITE}${BOLD}QUIZ RAPID: Ce va potrivi fiecare pattern?${NC}"
echo ""

echo -e "${YELLOW}Fișiere disponibile:${NC} file1.txt file2.txt file10.txt docA.pdf docB.pdf .hidden"
echo ""

echo -e "1. ${CYAN}*.pdf${NC}           → ?"
read -p "   Răspunsul tău: " ans1
echo -e "   ${GREEN}Corect: docA.pdf docB.pdf${NC}"
echo ""

echo -e "2. ${CYAN}file?.txt${NC}       → ?"
read -p "   Răspunsul tău: " ans2
echo -e "   ${GREEN}Corect: file1.txt file2.txt (NU file10.txt!)${NC}"
echo ""

echo -e "3. ${CYAN}*${NC}               → Include .hidden?"
read -p "   Răspunsul tău (da/nu): " ans3
echo -e "   ${GREEN}Corect: NU! * nu include fișierele ascunse${NC}"
echo ""

echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC}  ${BOLD}REȚINE:${NC} ? = exact 1 caracter, * = 0 sau mai multe, * NU include .files    ${GREEN}║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
