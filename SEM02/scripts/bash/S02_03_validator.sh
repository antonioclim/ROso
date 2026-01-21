#!/bin/bash
#
# S02_03_validator.sh - Validator temă Seminar 3-4
# Sisteme de Operare | ASE București - CSIE
#
#
# DESCRIERE: Validează tema studentului verificând structura, sintaxa
#            și funcționalitatea scripturilor.
#
# UTILIZARE: ./S02_03_validator.sh <cale_director_tema>
#
# OUTPUT: Raport detaliat cu punctaj și sugestii de îmbunătățire
#
#

# Configurare
VERSION="1.0"
REQUIRED_FILES=(
    "ex1_operatori.sh"
    "ex2_redirectare.sh"
    "ex3_filtre.sh"
    "ex4_bucle.sh"
    "ex5_integrat.sh"
)

# Punctaje
declare -A SCORES
TOTAL_SCORE=0
MAX_SCORE=100

# Culori
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;36m'
NC='\033[0m'

#
# FUNCȚII UTILITARE
#

log_pass() {
    echo -e "${GREEN}[✓ PASS]${NC} $1"
}

log_fail() {
    echo -e "${RED}[✗ FAIL]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[⚠ WARN]${NC} $1"
}

log_info() {
    echo -e "${BLUE}[ℹ INFO]${NC} $1"
}

add_score() {
    local category="$1"
    local points="$2"
    local reason="$3"
    
    if [[ -z "${SCORES[$category]}" ]]; then
        SCORES[$category]=0
    fi
    
    SCORES[$category]=$((SCORES[$category] + points))
    TOTAL_SCORE=$((TOTAL_SCORE + points))
    
    if [[ $points -gt 0 ]]; then
        log_pass "+$points puncte: $reason"
    fi
}

subtract_score() {
    local points="$1"
    local reason="$2"
    
    TOTAL_SCORE=$((TOTAL_SCORE - points))
    log_fail "-$points puncte: $reason"
}

#
# VERIFICĂRI
#

check_directory_structure() {
    echo ""
    echo -e "${BLUE}═══ VERIFICARE STRUCTURĂ DIRECTOR ═══${NC}"
    echo ""
    
    local found=0
    local missing=0
    
    for file in "${REQUIRED_FILES[@]}"; do
        if [[ -f "$HOMEWORK_DIR/$file" ]]; then
            log_pass "Fișier găsit: $file"
            ((found++))
        else
            log_fail "Fișier lipsă: $file"
            ((missing++))
        fi
    done
    
    # Punctaj pentru structură (max 10 puncte)
    local structure_score=$((found * 2))
    add_score "structura" $structure_score "Fișiere prezente: $found/${#REQUIRED_FILES[@]}"
    
    return $missing
}

check_script_syntax() {
    local script="$1"
    local name=$(basename "$script")
    
    if [[ ! -f "$script" ]]; then
        return 1
    fi
    
    # Verificare shebang
    local first_line=$(head -n1 "$script")
    if [[ "$first_line" =~ ^#!.*bash ]]; then
        log_pass "$name: Shebang corect"
        add_score "sintaxa" 1 "Shebang pentru $name"
    else
        log_warn "$name: Lipsă shebang (#!/bin/bash)"
    fi
    
    # Verificare sintaxă bash
    if bash -n "$script" 2>/dev/null; then
        log_pass "$name: Sintaxă validă"
        add_score "sintaxa" 2 "Sintaxă corectă pentru $name"
    else
        log_fail "$name: Erori de sintaxă detectate"
        bash -n "$script" 2>&1 | head -3
    fi
    
    # Verificare permisiuni executare
    if [[ -x "$script" ]]; then
        log_pass "$name: Permisiuni de executare setate"
        add_score "sintaxa" 1 "chmod +x pentru $name"
    else
        log_warn "$name: Lipsesc permisiuni de executare (chmod +x)"
    fi
}

check_all_syntax() {
    echo ""
    echo -e "${BLUE}═══ VERIFICARE SINTAXĂ SCRIPTURI ═══${NC}"
    echo ""
    
    for file in "${REQUIRED_FILES[@]}"; do
        if [[ -f "$HOMEWORK_DIR/$file" ]]; then
            check_script_syntax "$HOMEWORK_DIR/$file"
            echo ""
        fi
    done
}

check_operators_exercise() {
    local script="$HOMEWORK_DIR/ex1_operatori.sh"
    
    echo ""
    echo -e "${BLUE}═══ VERIFICARE EX1: OPERATORI ═══${NC}"
    echo ""
    
    if [[ ! -f "$script" ]]; then
        log_fail "Fișierul ex1_operatori.sh nu există"
        return 1
    fi
    
    local content=$(cat "$script")
    
    # Verificare utilizare operatori
    if grep -q '&&' "$script"; then
        log_pass "Utilizează operatorul &&"
        add_score "ex1" 3 "Operator && folosit"
    else
        log_warn "Nu folosește operatorul &&"
    fi
    
    if grep -q '||' "$script"; then
        log_pass "Utilizează operatorul ||"
        add_score "ex1" 3 "Operator || folosit"
    else
        log_warn "Nu folosește operatorul ||"
    fi
    
    if grep -qE '\s&\s*$|\s&\s' "$script"; then
        log_pass "Utilizează operatorul & (background)"
        add_score "ex1" 2 "Operator & folosit"
    fi
    
    # Test execuție
    if timeout 5 bash "$script" &>/dev/null; then
        log_pass "Scriptul se execută fără erori"
        add_score "ex1" 2 "Execuție reușită"
    else
        log_fail "Eroare la execuție sau timeout"
    fi
}

check_redirect_exercise() {
    local script="$HOMEWORK_DIR/ex2_redirectare.sh"
    
    echo ""
    echo -e "${BLUE}═══ VERIFICARE EX2: REDIRECȚIONARE ═══${NC}"
    echo ""
    
    if [[ ! -f "$script" ]]; then
        log_fail "Fișierul ex2_redirectare.sh nu există"
        return 1
    fi
    
    # Verificare utilizare redirecționări
    if grep -qE '>\s' "$script"; then
        log_pass "Utilizează redirecționare output (>)"
        add_score "ex2" 2 "Redirect > folosit"
    fi
    
    if grep -q '>>' "$script"; then
        log_pass "Utilizează append (>>)"
        add_score "ex2" 2 "Append >> folosit"
    fi
    
    if grep -qE '2>' "$script"; then
        log_pass "Utilizează redirecționare stderr (2>)"
        add_score "ex2" 3 "Redirect 2> folosit"
    fi
    
    if grep -q '2>&1' "$script"; then
        log_pass "Utilizează combinare stdout/stderr (2>&1)"
        add_score "ex2" 3 "2>&1 folosit"
    fi
    
    if grep -qE '<<\s*\w+' "$script"; then
        log_pass "Utilizează here document (<<)"
        add_score "ex2" 2 "Here document folosit"
    fi
}

check_filters_exercise() {
    local script="$HOMEWORK_DIR/ex3_filtre.sh"
    
    echo ""
    echo -e "${BLUE}═══ VERIFICARE EX3: FILTRE ═══${NC}"
    echo ""
    
    if [[ ! -f "$script" ]]; then
        log_fail "Fișierul ex3_filtre.sh nu există"
        return 1
    fi
    
    # Verificare utilizare filtre
    local filters_used=0
    
    if grep -q '\bsort\b' "$script"; then
        log_pass "Utilizează sort"
        add_score "ex3" 2 "sort folosit"
        ((filters_used++))
    fi
    
    if grep -q '\buniq\b' "$script"; then
        log_pass "Utilizează uniq"
        # Verificare dacă e precedat de sort
        if grep -qE 'sort.*\|.*uniq' "$script"; then
            log_pass "uniq precedat de sort (corect!)"
            add_score "ex3" 3 "sort | uniq corect"
        else
            log_warn "uniq fără sort înainte - posibil incorect"
            add_score "ex3" 1 "uniq folosit (posibil incorect)"
        fi
        ((filters_used++))
    fi
    
    if grep -q '\bcut\b' "$script"; then
        log_pass "Utilizează cut"
        add_score "ex3" 2 "cut folosit"
        ((filters_used++))
    fi
    
    if grep -q '\btr\b' "$script"; then
        log_pass "Utilizează tr"
        add_score "ex3" 2 "tr folosit"
        ((filters_used++))
    fi
    
    if grep -q '\bawk\b' "$script"; then
        log_pass "Utilizează awk (avansat)"
        add_score "ex3" 2 "awk folosit"
        ((filters_used++))
    fi
    
    # Verificare pipeline
    if grep -qE '\|.*\|' "$script"; then
        log_pass "Utilizează pipeline cu multiple comenzi"
        add_score "ex3" 3 "Pipeline complex"
    fi
    
    log_info "Total filtre folosite: $filters_used"
}

check_loops_exercise() {
    local script="$HOMEWORK_DIR/ex4_bucle.sh"
    
    echo ""
    echo -e "${BLUE}═══ VERIFICARE EX4: BUCLE ═══${NC}"
    echo ""
    
    if [[ ! -f "$script" ]]; then
        log_fail "Fișierul ex4_bucle.sh nu există"
        return 1
    fi
    
    # Verificare utilizare bucle
    if grep -qE '\bfor\b.*\bin\b' "$script"; then
        log_pass "Utilizează bucla for"
        add_score "ex4" 3 "for loop folosit"
    fi
    
    if grep -qE '\bwhile\b' "$script"; then
        log_pass "Utilizează bucla while"
        add_score "ex4" 3 "while loop folosit"
    fi
    
    # Verificare capcane comune
    if grep -qE '\{1\.\.\$' "$script"; then
        log_fail "Capcană: Folosește {1..\$N} - nu funcționează cu variabile!"
        subtract_score 2 "Bug: brace expansion cu variabilă"
    fi
    
    if grep -qE 'cat.*\|.*while.*read' "$script"; then
        log_warn "Folosește 'cat | while read' - variabilele nu vor persista"
    fi
    
    # Verificare citire fișier corectă
    if grep -qE 'while.*read.*<\s*\w' "$script"; then
        log_pass "Citire fișier corectă (redirect, nu pipe)"
        add_score "ex4" 3 "while read < file corect"
    fi
}

check_integrated_exercise() {
    local script="$HOMEWORK_DIR/ex5_integrat.sh"
    
    echo ""
    echo -e "${BLUE}═══ VERIFICARE EX5: PROIECT INTEGRAT ═══${NC}"
    echo ""
    
    if [[ ! -f "$script" ]]; then
        log_fail "Fișierul ex5_integrat.sh nu există"
        return 1
    fi
    
    local content=$(cat "$script")
    local score=0
    
    # Verificare complexitate
    local lines=$(wc -l < "$script")
    if [[ $lines -ge 30 ]]; then
        log_pass "Script substanțial ($lines linii)"
        add_score "ex5" 3 "Lungime adecvată"
    else
        log_warn "Script scurt ($lines linii) - poate fi prea simplu"
    fi
    
    # Verificare funcții
    if grep -qE '^\s*\w+\s*\(\)\s*\{' "$script"; then
        log_pass "Utilizează funcții"
        add_score "ex5" 3 "Funcții definite"
    fi
    
    # Verificare gestionare erori
    if grep -qE 'if\s*\[\[?\s*-[defrzs]' "$script"; then
        log_pass "Verifică existența fișierelor/directoarelor"
        add_score "ex5" 2 "Verificări de existență"
    fi
    
    # Verificare argumente
    if grep -qE '\$[1-9]|\$\{[1-9]\}|\$#' "$script"; then
        log_pass "Procesează argumente"
        add_score "ex5" 2 "Procesare argumente"
    fi
    
    # Test execuție
    if timeout 10 bash "$script" --help &>/dev/null 2>&1 || timeout 10 bash "$script" -h &>/dev/null 2>&1; then
        log_pass "Suportă --help/-h"
        add_score "ex5" 2 "Help implementat"
    fi
}

check_code_style() {
    echo ""
    echo -e "${BLUE}═══ VERIFICARE STIL COD ═══${NC}"
    echo ""
    
    local style_issues=0
    
    for file in "${REQUIRED_FILES[@]}"; do
        local script="$HOMEWORK_DIR/$file"
        [[ ! -f "$script" ]] && continue
        
        # Verificare comentarii
        if grep -qE '^#[^!]' "$script"; then
            log_pass "$file: Are comentarii"
        else
            log_warn "$file: Lipsesc comentariile"
            ((style_issues++))
        fi
        
        # Verificare variabile cu ghilimele
        if grep -qE '\$\w+[^"]' "$script" | grep -qvE '\$\(|for.*in' &>/dev/null; then
            log_warn "$file: Posibile variabile fără ghilimele"
        fi
    done
    
    if [[ $style_issues -eq 0 ]]; then
        add_score "stil" 5 "Stil cod bun"
    fi
}

#
# GENERARE RAPORT
#

generate_report() {
    local report_file="$HOMEWORK_DIR/RAPORT_VALIDARE.txt"
    
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}                    RAPORT FINAL VALIDARE${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    # Calculare punctaj final
    [[ $TOTAL_SCORE -lt 0 ]] && TOTAL_SCORE=0
    [[ $TOTAL_SCORE -gt $MAX_SCORE ]] && TOTAL_SCORE=$MAX_SCORE
    
    local percentage=$((TOTAL_SCORE * 100 / MAX_SCORE))
    local grade=""
    
    if [[ $percentage -ge 90 ]]; then
        grade="EXCELENT (A)"
    elif [[ $percentage -ge 80 ]]; then
        grade="FOARTE BINE (B)"
    elif [[ $percentage -ge 70 ]]; then
        grade="BINE (C)"
    elif [[ $percentage -ge 60 ]]; then
        grade="SATISFĂCĂTOR (D)"
    elif [[ $percentage -ge 50 ]]; then
        grade="SUFICIENT (E)"
    else
        grade="INSUFICIENT (F)"
    fi
    
    echo -e "  ${GREEN}Punctaj Total: $TOTAL_SCORE / $MAX_SCORE ($percentage%)${NC}"
    echo -e "  ${YELLOW}Calificativ: $grade${NC}"
    echo ""
    
    echo -e "${BLUE}Detalii pe categorii:${NC}"
    for category in "${!SCORES[@]}"; do
        printf "  %-15s: %d puncte\n" "$category" "${SCORES[$category]}"
    done
    
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    
    # Salvare raport
    {
        echo "═══════════════════════════════════════════════════════════════"
        echo "RAPORT VALIDARE TEMĂ SEMINAR 3-4"
        echo "Data: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "Director: $HOMEWORK_DIR"
        echo "═══════════════════════════════════════════════════════════════"
        echo ""
        echo "PUNCTAJ TOTAL: $TOTAL_SCORE / $MAX_SCORE ($percentage%)"
        echo "CALIFICATIV: $grade"
        echo ""
        echo "DETALII:"
        for category in "${!SCORES[@]}"; do
            printf "  %-15s: %d puncte\n" "$category" "${SCORES[$category]}"
        done
        echo ""
        echo "═══════════════════════════════════════════════════════════════"
    } > "$report_file"
    
    log_info "Raport salvat în: $report_file"
}

#
# MAIN
#

usage() {
    echo "Utilizare: $0 <cale_director_tema>"
    echo ""
    echo "Exemplu: $0 ~/tema_seminar2"
    echo ""
    echo "Validează tema pentru Seminarul 3-4 și generează raport."
}

main() {
    if [[ $# -lt 1 ]]; then
        usage
        exit 1
    fi
    
    HOMEWORK_DIR="$1"
    
    if [[ ! -d "$HOMEWORK_DIR" ]]; then
        echo -e "${RED}Eroare: Directorul '$HOMEWORK_DIR' nu există${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}       VALIDATOR TEMĂ SEMINAR 3-4 v$VERSION${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "Validare director: ${YELLOW}$HOMEWORK_DIR${NC}"
    
    # Rulare verificări
    check_directory_structure
    check_all_syntax
    check_operators_exercise
    check_redirect_exercise
    check_filters_exercise
    check_loops_exercise
    check_integrated_exercise
    check_code_style
    
    # Generare raport
    generate_report
}

main "$@"
