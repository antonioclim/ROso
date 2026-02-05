#!/bin/bash
#===============================================================================
#
#          FILE:  check_my_submission.sh
#
#         USAGE:  ./check_my_submission.sh <homework.cast>
#
#   DESCRIPTION:  Verifică predarea temei înainte de trimitere
#                 Verifică: existența fișierului, extensia, dimensiunea, semnătura, formatul
#
#        AUTHOR:  Operating Systems 2023-2027 - Revolvix/github.com
#       VERSION:  1.0.0
#       CREATED:  2025
#
#===============================================================================

set -euo pipefail

# Culori
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# Contoare
ERRORS=0
WARNINGS=0

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
    ((ERRORS++)) || true
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARNINGS++)) || true
}

print_info() {
    echo -e "${CYAN}ℹ${NC} $1"
}

# Verifică argumentele
if [[ $# -ne 1 ]]; then
    echo -e "${RED}Utilizare: $0 <homework.cast>${NC}"
    echo ""
    echo "Exemplu:"
    echo "  $0 1029_SMITH_John_HW03b.cast"
    exit 1
fi

CAST_FILE="$1"

echo ""
echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║              🔍 VERIFICATOR PREDARE TEMĂ                       ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Verificare 1: Fișierul există
echo -e "${BOLD}Se verifică fișierul...${NC}"
if [[ -f "$CAST_FILE" ]]; then
    print_success "Fișierul există: $CAST_FILE"
else
    print_error "Fișier negăsit: $CAST_FILE"
    echo ""
    echo -e "${RED}Nu se poate continua fără fișier. Verifică calea.${NC}"
    exit 1
fi

# Verificare 2: Extensia fișierului
if [[ "$CAST_FILE" == *.cast ]]; then
    print_success "Extensie corectă (.cast)"
else
    print_error "Extensie greșită (ar trebui să fie .cast)"
fi

# Verificare 3: Dimensiunea fișierului (ar trebui > 1KB, tipic > 5KB pentru înregistrări reale)
# Folosește comanda stat portabilă
if [[ "$(uname)" == "Darwin" ]]; then
    SIZE=$(stat -f%z "$CAST_FILE" 2>/dev/null || echo "0")
else
    SIZE=$(stat -c%s "$CAST_FILE" 2>/dev/null || echo "0")
fi

if [[ $SIZE -gt 5120 ]]; then
    print_success "Dimensiune fișier OK: $SIZE octeți ($(( SIZE / 1024 )) KB)"
elif [[ $SIZE -gt 1024 ]]; then
    print_warning "Dimensiunea fișierului este mică - înregistrarea poate fi foarte scurtă"
else
    print_error "Fișier prea mic - înregistrarea pare incompletă sau coruptă"
fi

# Verificare 4: Semnătura prezentă
echo ""
echo -e "${BOLD}Se verifică semnătura...${NC}"
if tail -5 "$CAST_FILE" 2>/dev/null | grep -q "^## "; then
    print_success "Semnătură criptografică prezentă"
    
    # Extrage și afișează parțial semnătura pentru verificare
    SIG_LINE=$(tail -5 "$CAST_FILE" | grep "^## " | tail -1)
    SIG_PREVIEW="${SIG_LINE:0:50}..."
    print_info "Previzualizare semnătură: $SIG_PREVIEW"
else
    print_error "Semnătură criptografică LIPSĂ - fișierul poate fi corupt sau incomplet"
    echo ""
    echo -e "${YELLOW}   Ai oprit înregistrarea corect cu STOP_homework sau Ctrl+D?${NC}"
    echo -e "${YELLOW}   Semnătura este adăugată DUPĂ ce înregistrarea se oprește.${NC}"
fi

# Verificare 5: Header JSON valid (format asciinema)
echo ""
echo -e "${BOLD}Se verifică formatul...${NC}"
FIRST_LINE=$(head -1 "$CAST_FILE" 2>/dev/null || echo "")
if echo "$FIRST_LINE" | grep -q '"version"'; then
    print_success "Format asciinema valid detectat"
    
    # Încearcă să extragă versiunea
    if echo "$FIRST_LINE" | grep -q '"version": 2'; then
        print_info "Versiune format asciinema: 2 (curentă)"
    fi
else
    print_warning "Nu s-a putut verifica formatul asciinema - fișierul poate fi corupt"
fi

# Verificare 6: Format nume fișier
echo ""
echo -e "${BOLD}Se verifică fișierul...e format...${NC}"
BASENAME=$(basename "$CAST_FILE")

# Format așteptat: GROUP_SURNAME_FirstName_HWxxl.cast
# GROUP: 4 digits
# SURNAME: uppercase letters and hyphen
# FirstName: Title case letters and hyphen  
# HW: literal
# xx: 01-07
# l: lowercase letter
if [[ "$BASENAME" =~ ^[0-9]{4}_[A-Z][A-Z-]*_[A-Z][a-zA-Z-]*_HW0[1-7][a-z]\.cast$ ]]; then
    print_success "Format nume fișier corect: $BASENAME"
    
    # Parsează componentele
    IFS='_' read -r F_GROUP F_SURNAME F_FIRSTNAME F_HW <<< "${BASENAME%.cast}"
    print_info "  Group: $F_GROUP"
    print_info "  Surname: $F_SURNAME"
    print_info "  Prenume: $F_FIRSTNAME"
    print_info "  Homework: $F_HW"
else
    print_warning "Numele fișierului poate să nu urmeze formatul standard: $BASENAME"
    echo -e "     ${YELLOW}Așteptat: GROUP_SURNAME_FirstName_HWxxl.cast${NC}"
    echo -e "     ${YELLOW}Exemplu:  1029_SMITH_John_HW03b.cast${NC}"
fi

# Verificare 7: Fișierul nu este gol și are conținut
echo ""
echo -e "${BOLD}Se verifică conținutul...${NC}"
LINE_COUNT=$(wc -l < "$CAST_FILE" 2>/dev/null || echo "0")
if [[ $LINE_COUNT -gt 10 ]]; then
    print_success "Fișierul are conținut: $LINE_COUNT linii"
else
    print_warning "Fișierul are foarte puține linii ($LINE_COUNT) - înregistrarea poate fi prea scurtă"
fi

# Rezumat
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo ""

if [[ $ERRORS -eq 0 ]] && [[ $WARNINGS -eq 0 ]]; then
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║         ✅ TOATE VERIFICĂRILE AU TRECUT - GATA DE TRIMIS!                   ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════════╝${NC}"
    exit 0
elif [[ $ERRORS -eq 0 ]]; then
    echo -e "${YELLOW}╔═══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║     ⚠ $WARNINGS AVERTISMENT(E) - Verifică înainte de trimitere               ║${NC}"
    echo -e "${YELLOW}╚═══════════════════════════════════════════════════════════════════╝${NC}"
    exit 0
else
    echo -e "${RED}╔═══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║     ❌ $ERRORS EROARE(I) GĂSITE - Te rugăm să repari înainte de trimitere            ║${NC}"
    echo -e "${RED}╚═══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Remedieri comune:${NC}"
    echo "  • Semnătură lipsă: Reînregistrează și oprește corect cu STOP_homework"
    echo "  • Fișier prea mic: Înregistrarea s-a oprit prea devreme, reînregistrează"
    echo "  • Format greșit: Asigură-te că ai folosit scriptul oficial de înregistrare"
    exit 1
fi
