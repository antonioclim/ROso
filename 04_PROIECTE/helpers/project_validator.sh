#!/bin/bash
#===============================================================================
# NUME:        project_validator.sh
# DESCRIERE:   Validează structura și calitatea unui proiect SO
# AUTOR:       Kit SO - ASE CSIE
# VERSIUNE:    1.0.0
#===============================================================================

set -euo pipefail

# Culori
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Contoare
PASS=0
FAIL=0
WARN=0

pass() { echo -e "${GREEN}✓ PASS:${NC} $1"; ((PASS++)); }
fail() { echo -e "${RED}✗ FAIL:${NC} $1"; ((FAIL++)); }
warn() { echo -e "${YELLOW}⚠ WARN:${NC} $1"; ((WARN++)); }

usage() {
    cat << EOF
Utilizare: $(basename "$0") <project_directory>

Validează structura și calitatea unui proiect SO.

Verificări efectuate:
  - Structura de directoare
  - Prezența fișierelor obligatorii
  - Sintaxă scripturi Bash
  - ShellCheck (dacă disponibil)
  - Permisiuni executabile
  - Conținut README

Exemple:
  $(basename "$0") ./my_project
  $(basename "$0") ~/student_submission
EOF
}

check_structure() {
    echo "═══ Verificare Structură ═══"
    
    [[ -d "$1/src" ]] && pass "Director src/ există" || fail "Lipsește src/"
    [[ -f "$1/README.md" ]] && pass "README.md există" || fail "Lipsește README.md"
    [[ -f "$1/Makefile" ]] && pass "Makefile există" || warn "Lipsește Makefile (recomandat)"
    [[ -d "$1/tests" ]] && pass "Director tests/ există" || warn "Lipsește tests/"
    [[ -d "$1/docs" ]] && pass "Director docs/ există" || warn "Lipsește docs/"
}

check_scripts() {
    echo ""
    echo "═══ Verificare Scripturi Bash ═══"
    
    local scripts
    scripts=$(find "$1" -name "*.sh" -type f 2>/dev/null)
    
    if [[ -z "$scripts" ]]; then
        warn "Nu s-au găsit scripturi .sh"
        return
    fi
    
    while IFS= read -r script; do
        local name
        name=$(basename "$script")
        
        # Verificare shebang
        if head -1 "$script" | grep -q '^#!/.*bash'; then
            pass "$name: shebang corect"
        else
            fail "$name: lipsește sau shebang incorect"
        fi
        
        # Verificare sintaxă
        if bash -n "$script" 2>/dev/null; then
            pass "$name: sintaxă validă"
        else
            fail "$name: erori de sintaxă"
        fi
        
        # ShellCheck
        if command -v shellcheck &>/dev/null; then
            if shellcheck -x "$script" &>/dev/null; then
                pass "$name: ShellCheck OK"
            else
                warn "$name: ShellCheck warnings"
            fi
        fi
    done <<< "$scripts"
}

check_readme() {
    echo ""
    echo "═══ Verificare README.md ═══"
    
    local readme="$1/README.md"
    [[ ! -f "$readme" ]] && return
    
    local lines
    lines=$(wc -l < "$readme")
    
    if [[ $lines -gt 50 ]]; then
        pass "README suficient de detaliat ($lines linii)"
    elif [[ $lines -gt 20 ]]; then
        warn "README scurt ($lines linii)"
    else
        fail "README prea scurt ($lines linii)"
    fi
    
    # Verificare secțiuni comune
    grep -qi "instalare\|install" "$readme" && pass "Secțiune instalare" || warn "Lipsește secțiune instalare"
    grep -qi "utilizare\|usage" "$readme" && pass "Secțiune utilizare" || warn "Lipsește secțiune utilizare"
    grep -qi "exemplu\|example" "$readme" && pass "Exemple prezente" || warn "Lipsesc exemple"
}

check_permissions() {
    echo ""
    echo "═══ Verificare Permisiuni ═══"
    
    local main_script
    main_script=$(find "$1/src" -maxdepth 1 -name "*.sh" -type f 2>/dev/null | head -1)
    
    if [[ -n "$main_script" ]]; then
        if [[ -x "$main_script" ]]; then
            pass "Script principal executabil"
        else
            warn "Script principal nu e executabil"
        fi
    fi
}

print_summary() {
    echo ""
    echo "═══════════════════════════════════════"
    echo "SUMAR VALIDARE"
    echo "═══════════════════════════════════════"
    echo -e "  ${GREEN}Passed:${NC}  $PASS"
    echo -e "  ${RED}Failed:${NC}  $FAIL"
    echo -e "  ${YELLOW}Warnings:${NC} $WARN"
    echo "═══════════════════════════════════════"
    
    if [[ $FAIL -eq 0 ]]; then
        echo -e "${GREEN}Proiect valid pentru submisie!${NC}"
        return 0
    else
        echo -e "${RED}Proiect are probleme care trebuie rezolvate.${NC}"
        return 1
    fi
}

# Main
[[ $# -lt 1 ]] && { usage; exit 1; }
[[ ! -d "$1" ]] && { echo "Eroare: '$1' nu este un director"; exit 1; }

PROJECT_DIR="$(cd "$1" && pwd)"

echo "╔══════════════════════════════════════════════╗"
echo "║     PROJECT VALIDATOR - SO ASE CSIE          ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
echo "Validare: $PROJECT_DIR"
echo ""

check_structure "$PROJECT_DIR"
check_scripts "$PROJECT_DIR"
check_readme "$PROJECT_DIR"
check_permissions "$PROJECT_DIR"
print_summary
