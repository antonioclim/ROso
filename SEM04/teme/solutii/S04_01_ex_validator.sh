#!/bin/bash
# ============================================================================
# ex1_validator.sh - Soluție Model
# Validare și extragere date (email, IP, telefon)
# 
# Autor: [Instructor]
# Versiune: 1.0
# ============================================================================
set -euo pipefail

# Culori pentru output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ============================================================================
# Verificare argumente
# ============================================================================
if [[ $# -lt 1 ]]; then
    echo -e "${RED}Utilizare: $0 <fisier>${NC}"
    echo "Exemplu: $0 contacts.txt"
    exit 1
fi

INPUT_FILE="$1"

if [[ ! -f "$INPUT_FILE" ]]; then
    echo -e "${RED}Eroare: Fișierul '$INPUT_FILE' nu există!${NC}"
    exit 1
fi

# ============================================================================
# Funcție: Validare Email
# Pattern-ul acceptă: user@domain.tld
# ============================================================================
validate_emails() {
    echo -e "${BLUE}=== VALIDARE EMAIL ===${NC}"
    echo ""
    
    # Pattern pentru extragere email (permisiv)
    local extract_pattern='[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'
    
    # Pattern strict pentru validare
    local valid_pattern='^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    
    # Extrage toate email-urile
    local all_emails
    all_emails=$(grep -oE "$extract_pattern" "$INPUT_FILE" | sort -u)
    
    local total=0
    local valid_count=0
    local invalid_count=0
    local valid_list=""
    local invalid_list=""
    
    while IFS= read -r email; do
        [[ -z "$email" ]] && continue
        ((total++))
        
        # Validare suplimentară: nu începe/termină cu punct, nu are puncte consecutive
        if [[ "$email" =~ $valid_pattern ]] && \
           [[ ! "$email" =~ ^\\. ]] && \
           [[ ! "$email" =~ \\.@ ]] && \
           [[ ! "$email" =~ \\.\\. ]]; then
            ((valid_count++))
            valid_list+="  - $email"$'\n'
        else
            ((invalid_count++))
            invalid_list+="  - $email"$'\n'
        fi
    done <<< "$all_emails"
    
    echo -e "Total găsite: ${YELLOW}$total${NC}"
    echo -e "${GREEN}✅ Valide: $valid_count${NC}"
    if [[ -n "$valid_list" ]]; then
        echo -e "$valid_list"
    fi
    
    if [[ $invalid_count -gt 0 ]]; then
        echo -e "${RED}❌ Invalide: $invalid_count${NC}"
        echo -e "$invalid_list"
    fi
    
    echo ""
}

# ============================================================================
# Funcție: Extragere IP-uri
# Validare strictă: fiecare octet 0-255
# ============================================================================
extract_ips() {
    echo -e "${BLUE}=== ADRESE IP UNICE ===${NC}"
    echo ""
    
    # Pattern permisiv pentru extragere
    local extract_pattern='[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'
    
    # Extrage și validează
    grep -oE "$extract_pattern" "$INPUT_FILE" 2>/dev/null | while read -r ip; do
        # Validare strictă: fiecare octet între 0-255
        IFS='.' read -ra octets <<< "$ip"
        local valid=true
        for octet in "${octets[@]}"; do
            if [[ $octet -lt 0 || $octet -gt 255 ]]; then
                valid=false
                break
            fi
        done
        if $valid; then
            echo "$ip"
        fi
    done | sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u
    
    echo ""
}

# ============================================================================
# Funcție: Extragere Numere Telefon RO
# Formate acceptate: 07XX-XXX-XXX, 07XX.XXX.XXX, 07XX XXX XXX, 07XXXXXXXX
# ============================================================================
extract_phones() {
    echo -e "${BLUE}=== NUMERE TELEFON RO ===${NC}"
    echo ""
    
    # Pattern pentru telefoane românești mobile
    # Acceptă: 07XX-XXX-XXX, 07XX.XXX.XXX, 07XX XXX XXX, 07XXXXXXXX
    # Și variantele cu +40
    local patterns=(
        '\+40[-. ]?7[0-9]{2}[-. ]?[0-9]{3}[-. ]?[0-9]{3}'
        '07[2-9][0-9][-. ]?[0-9]{3}[-. ]?[0-9]{3}'
    )
    
    for pattern in "${patterns[@]}"; do
        grep -oE "$pattern" "$INPUT_FILE" 2>/dev/null
    done | sort -u
    
    echo ""
}

# ============================================================================
# Main
# ============================================================================
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         VALIDATOR DATE - $INPUT_FILE${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

validate_emails
extract_ips
extract_phones

echo -e "${GREEN}✅ Validare completă!${NC}"
