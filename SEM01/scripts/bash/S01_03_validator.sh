#!/bin/bash
#
# VALIDATOR - Verificare rapidă temă Seminar 1-2
# Sisteme de Operare | ASE București - CSIE
#
# Utilizare: ./validator.sh <director_tema>
#

set -e

# Culori
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

# Contoare
PASS=0
FAIL=0
WARN=0

# Funcții
log_pass() { echo -e "${GREEN}[✓]${NC} $1"; ((PASS++)); }
log_fail() { echo -e "${RED}[✗]${NC} $1"; ((FAIL++)); }
log_warn() { echo -e "${YELLOW}[!]${NC} $1"; ((WARN++)); }
log_info() { echo -e "${BLUE}[i]${NC} $1"; }

# Header
show_header() {
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}         ${BOLD}VALIDATOR TEMĂ - Seminar 1-2 Shell Bash${NC}             ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Verifică argument
if [ $# -lt 1 ]; then
    show_header
    echo "Utilizare: $0 <director_tema>"
    echo ""
    echo "Exemplu: $0 ~/tema_seminar1"
    exit 1
fi

TEMA_DIR="$1"

# Verifică dacă directorul există
if [ ! -d "$TEMA_DIR" ]; then
    echo -e "${RED}Eroare: Directorul '$TEMA_DIR' nu există!${NC}"
    exit 1
fi

show_header
log_info "Verificare director: $TEMA_DIR"
log_info "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

#
# TEST 1: Structura de Directoare
#

echo -e "${BOLD}═══ TEST 1: Structura de Directoare ═══${NC}"

# Directoare obligatorii
REQUIRED_DIRS=("proiect" "proiect/src" "proiect/docs" "proiect/tests")

for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$TEMA_DIR/$dir" ]; then
        log_pass "Director prezent: $dir/"
    else
        log_fail "Director lipsă: $dir/"
    fi
done

echo ""

#
# TEST 2: Fișiere Obligatorii
#

echo -e "${BOLD}═══ TEST 2: Fișiere Obligatorii ═══${NC}"

REQUIRED_FILES=(
    "AUTOR.txt"
    "proiect/docs/README.md"
    "proiect/src/main.sh"
    "proiect/src/variabile.sh"
    "proiect/src/info_sistem.sh"
    "proiect/tests/test_globbing.sh"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$TEMA_DIR/$file" ]; then
        log_pass "Fișier prezent: $file"
    else
        log_fail "Fișier lipsă: $file"
    fi
done

# .bashrc poate fi cu sau fără punct
if [ -f "$TEMA_DIR/.bashrc" ] || [ -f "$TEMA_DIR/bashrc" ]; then
    log_pass "Fișier prezent: .bashrc (sau bashrc)"
else
    log_fail "Fișier lipsă: .bashrc"
fi

echo ""

#
# TEST 3: Sintaxă Scripturi Bash
#

echo -e "${BOLD}═══ TEST 3: Sintaxă Scripturi Bash ═══${NC}"

SCRIPTS=(
    "proiect/src/main.sh"
    "proiect/src/variabile.sh"
    "proiect/src/info_sistem.sh"
    "proiect/tests/test_globbing.sh"
)

for script in "${SCRIPTS[@]}"; do
    if [ -f "$TEMA_DIR/$script" ]; then
        if bash -n "$TEMA_DIR/$script" 2>/dev/null; then
            log_pass "Sintaxă corectă: $script"
        else
            log_fail "Erori de sintaxă: $script"
            bash -n "$TEMA_DIR/$script" 2>&1 | head -3 | while read line; do
                echo "        $line"
            done
        fi
    fi
done

echo ""

#
# TEST 4: Shebang și Permisiuni
#

echo -e "${BOLD}═══ TEST 4: Shebang și Permisiuni ═══${NC}"

for script in "${SCRIPTS[@]}"; do
    if [ -f "$TEMA_DIR/$script" ]; then
        # Verifică shebang
        first_line=$(head -1 "$TEMA_DIR/$script")
        if [[ "$first_line" == "#!/bin/bash"* ]] || [[ "$first_line" == "#!/usr/bin/env bash"* ]]; then
            log_pass "Shebang corect: $script"
        else
            log_warn "Shebang lipsă sau incorect: $script (găsit: $first_line)"
        fi
        
        # Verifică permisiuni executabile
        if [ -x "$TEMA_DIR/$script" ]; then
            log_pass "Executabil: $script"
        else
            log_warn "Nu este executabil: $script (rulează: chmod +x $script)"
        fi
    fi
done

echo ""

#
# TEST 5: Conținut .bashrc
#

echo -e "${BOLD}═══ TEST 5: Conținut .bashrc ═══${NC}"

BASHRC=""
if [ -f "$TEMA_DIR/.bashrc" ]; then
    BASHRC="$TEMA_DIR/.bashrc"
elif [ -f "$TEMA_DIR/bashrc" ]; then
    BASHRC="$TEMA_DIR/bashrc"
fi

if [ -n "$BASHRC" ]; then
    # Verifică alias-uri obligatorii
    if grep -q "alias ll=" "$BASHRC" 2>/dev/null; then
        log_pass "Alias 'll' prezent"
    else
        log_fail "Alias 'll' lipsă"
    fi
    
    if grep -q "alias cls=" "$BASHRC" 2>/dev/null; then
        log_pass "Alias 'cls' prezent"
    else
        log_fail "Alias 'cls' lipsă"
    fi
    
    # Verifică funcția mkcd
    if grep -qE "(mkcd\(\)|function mkcd)" "$BASHRC" 2>/dev/null; then
        log_pass "Funcția 'mkcd' prezentă"
    else
        log_fail "Funcția 'mkcd' lipsă"
    fi
    
    # Verifică modificare PATH
    if grep -q "export PATH" "$BASHRC" 2>/dev/null; then
        log_pass "Modificare PATH prezentă"
    else
        log_warn "Modificare PATH nu a fost detectată"
    fi
fi

echo ""

#
# TEST 6: Verificare Conținut Scripturi
#

echo -e "${BOLD}═══ TEST 6: Verificare Conținut Scripturi ═══${NC}"

# variabile.sh - trebuie să conțină demonstrații
if [ -f "$TEMA_DIR/proiect/src/variabile.sh" ]; then
    if grep -q '\$USER\|\$HOME\|\$SHELL\|\$PATH' "$TEMA_DIR/proiect/src/variabile.sh"; then
        log_pass "variabile.sh: Conține variabile de mediu"
    else
        log_warn "variabile.sh: Nu s-au detectat variabile de mediu"
    fi
    
    if grep -q "export" "$TEMA_DIR/proiect/src/variabile.sh"; then
        log_pass "variabile.sh: Demonstrează export"
    else
        log_warn "variabile.sh: Nu demonstrează export"
    fi
fi

# info_sistem.sh - trebuie să afișeze informații
if [ -f "$TEMA_DIR/proiect/src/info_sistem.sh" ]; then
    if grep -qE "(uname|date|whoami|\\\$USER|\\\$HOME)" "$TEMA_DIR/proiect/src/info_sistem.sh"; then
        log_pass "info_sistem.sh: Conține comenzi de sistem"
    else
        log_warn "info_sistem.sh: Nu s-au detectat comenzi de sistem"
    fi
fi

# test_globbing.sh - trebuie să demonstreze wildcards
if [ -f "$TEMA_DIR/proiect/tests/test_globbing.sh" ]; then
    if grep -qE "(\*\.txt|\?\.[a-z]+|\[.*\])" "$TEMA_DIR/proiect/tests/test_globbing.sh"; then
        log_pass "test_globbing.sh: Conține pattern-uri globbing"
    else
        log_warn "test_globbing.sh: Nu s-au detectat pattern-uri globbing"
    fi
fi

echo ""

#
# TEST 7: Executare Scripturi (opțional, cu sandboxing)
#

echo -e "${BOLD}═══ TEST 7: Testare Execuție ═══${NC}"

for script in "proiect/src/variabile.sh" "proiect/src/info_sistem.sh"; do
    if [ -f "$TEMA_DIR/$script" ]; then
        # Rulează cu timeout și capturează output
        output=$(timeout 5 bash "$TEMA_DIR/$script" 2>&1) || true
        exit_code=$?
        
        if [ $exit_code -eq 0 ] && [ -n "$output" ]; then
            log_pass "Execuție reușită: $script"
        elif [ $exit_code -eq 124 ]; then
            log_fail "Timeout la execuție: $script"
        else
            log_warn "Execuție cu probleme: $script (exit code: $exit_code)"
        fi
    fi
done

echo ""

#
# REZUMAT
#

echo -e "${BOLD}═══════════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}                         REZUMAT                                   ${NC}"
echo -e "${BOLD}═══════════════════════════════════════════════════════════════════${NC}"
echo ""

TOTAL=$((PASS + FAIL + WARN))
SCORE=$((PASS * 100 / TOTAL))

echo -e "  ${GREEN}Trecute:${NC}     $PASS"
echo -e "  ${RED}Eșuate:${NC}      $FAIL"
echo -e "  ${YELLOW}Avertismente:${NC} $WARN"
echo ""

echo -e "  ${BOLD}Scor estimat:${NC} ${CYAN}$SCORE%${NC}"
echo ""

if [ $FAIL -eq 0 ]; then
    echo -e "  ${GREEN}${BOLD}✓ Tema pare completă!${NC}"
    echo -e "  ${GREEN}  Toate verificările de bază au trecut.${NC}"
else
    echo -e "  ${YELLOW}${BOLD}⚠ Tema necesită îmbunătățiri${NC}"
    echo -e "  ${YELLOW}  Verifică elementele marcate cu ${RED}[✗]${NC}"
fi

echo ""
echo -e "${CYAN}─────────────────────────────────────────────────────────────────${NC}"
echo -e "${BLUE}Observație: Aceasta este o verificare automată preliminară.${NC}"
echo -e "${BLUE}Evaluarea finală va fi făcută manual de instructor.${NC}"
echo ""
