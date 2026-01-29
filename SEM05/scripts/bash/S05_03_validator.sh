#!/bin/bash
#
# S05_03_validator.sh - Validator pentru Scripturi Bash
# 
# Sisteme de Operare | ASE București - CSIE
# Seminar 5: Advanced Bash Scripting
#
# SCOP: Verifică dacă un script respectă best practices:
#       - Prezența set -euo pipefail
#       - Folosirea local în funcții
#       - declare -A pentru arrays asociative
#       - Ghilimele în for loops cu arrays
#       - Funcții de cleanup cu trap
#
# UTILIZARE:
#   ./S05_03_validator.sh script.sh           # Validare standard
#   ./S05_03_validator.sh -v script.sh        # Verbose
#   ./S05_03_validator.sh -s script.sh        # Cu shellcheck
#   ./S05_03_validator.sh --dir ./submissions # Validare director
#

set -euo pipefail
IFS=$'\n\t'

# ============================================================
# CONSTANTE
# ============================================================
readonly SCRIPT_NAME=$(basename "$0")
readonly VERSION="1.0.0"

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly DIM='\033[2m'
readonly NC='\033[0m'

# Scoring weights
readonly WEIGHT_STRICT_MODE=20
readonly WEIGHT_LOCAL_VARS=15
readonly WEIGHT_DECLARE_A=15
readonly WEIGHT_QUOTED_ARRAYS=15
readonly WEIGHT_TRAP_EXIT=10
readonly WEIGHT_USAGE_FUNC=10
readonly WEIGHT_SHELLCHECK=15

# ============================================================
# STATE
# ============================================================
VERBOSE=false
USE_SHELLCHECK=false
TOTAL_SCORE=0
MAX_SCORE=100
ISSUES=()
WARNINGS=()

# ============================================================
# HELPER FUNCTIONS
# ============================================================

log_check() {
    local status=$1
    local message=$2
    local points=${3:-0}
    
    if [[ "$status" == "pass" ]]; then
        echo -e "  ${GREEN}✓${NC} $message ${DIM}(+$points pts)${NC}"
    elif [[ "$status" == "fail" ]]; then
        echo -e "  ${RED}✗${NC} $message"
        ISSUES+=("$message")
    elif [[ "$status" == "warn" ]]; then
        echo -e "  ${YELLOW}○${NC} $message"
        WARNINGS+=("$message")
    else
        echo -e "  ${BLUE}ℹ${NC} $message"
    fi
}

verbose() {
    [[ "$VERBOSE" == "true" ]] && echo -e "${DIM}$*${NC}"
}

usage() {
    cat << EOF
${BOLD}$SCRIPT_NAME v$VERSION${NC}

Validează scripturi Bash pentru conformitate cu best practices.

${BOLD}UTILIZARE:${NC}
    $SCRIPT_NAME [opțiuni] <script.sh>
    $SCRIPT_NAME [opțiuni] --dir <director>

${BOLD}OPȚIUNI:${NC}
    -h, --help          Afișează acest mesaj
    -v, --verbose       Output detaliat
    -s, --shellcheck    Include verificare shellcheck
    -d, --dir PATH      Validează toate scripturile dintr-un director
    -q, --quiet         Doar scorul final

${BOLD}VERIFICĂRI:${NC}
    • Strict mode (set -euo pipefail)     - $WEIGHT_STRICT_MODE pts
    • Variabile locale în funcții         - $WEIGHT_LOCAL_VARS pts
    • declare -A pentru arrays asociative - $WEIGHT_DECLARE_A pts
    • Ghilimele în "\${arr[@]}"           - $WEIGHT_QUOTED_ARRAYS pts
    • trap EXIT pentru cleanup            - $WEIGHT_TRAP_EXIT pts
    • Funcție usage()/help                - $WEIGHT_USAGE_FUNC pts
    • shellcheck fără erori               - $WEIGHT_SHELLCHECK pts

${BOLD}EXEMPLE:${NC}
    $SCRIPT_NAME script.sh
    $SCRIPT_NAME -v -s submission.sh
    $SCRIPT_NAME --dir ./submissions/

EOF
}

# ============================================================
# VALIDATION CHECKS
# ============================================================

check_shebang() {
    local file="$1"
    
    local first_line
    first_line=$(head -n 1 "$file")
    
    if [[ "$first_line" == "#!/bin/bash" ]] || [[ "$first_line" == "#!/usr/bin/env bash" ]]; then
        log_check "pass" "Shebang corect: $first_line" 0
        return 0
    else
        log_check "fail" "Shebang lipsă sau incorect (găsit: '$first_line')"
        return 1
    fi
}

check_strict_mode() {
    local file="$1"
    local score=0
    
    verbose "Checking strict mode..."
    
    if grep -qE '^\s*set\s+.*-e' "$file" || grep -qE '^\s*set\s+-euo' "$file"; then
        log_check "pass" "set -e (errexit) prezent" 7
        ((score += 7))
    else
        log_check "fail" "Lipsă set -e (errexit)"
    fi
    
    if grep -qE '^\s*set\s+.*-u' "$file" || grep -qE '^\s*set\s+-euo' "$file"; then
        log_check "pass" "set -u (nounset) prezent" 7
        ((score += 7))
    else
        log_check "fail" "Lipsă set -u (nounset)"
    fi
    
    if grep -qE '^\s*set\s+-o\s+pipefail' "$file" || grep -qE '^\s*set\s+-euo\s+pipefail' "$file"; then
        log_check "pass" "set -o pipefail prezent" 6
        ((score += 6))
    else
        log_check "fail" "Lipsă set -o pipefail"
    fi
    
    TOTAL_SCORE=$((TOTAL_SCORE + score))
    return 0
}

check_local_variables() {
    local file="$1"
    
    verbose "Checking local variables in functions..."
    
    # Find all function definitions
    local functions
    functions=$(grep -oE '^[a-zA-Z_][a-zA-Z0-9_]*\s*\(\)\s*\{' "$file" | sed 's/().*//g' | tr -d ' ' || true)
    
    if [[ -z "$functions" ]]; then
        log_check "info" "Nu s-au găsit funcții definite"
        return 0
    fi
    
    local func_count
    func_count=$(echo "$functions" | wc -l)
    
    # Check if local is used
    local local_count
    local_count=$(grep -c '^\s*local\s' "$file" || echo 0)
    
    if [[ $local_count -eq 0 ]] && [[ $func_count -gt 0 ]]; then
        log_check "fail" "Nicio variabilă 'local' în $func_count funcții"
        return 1
    elif [[ $local_count -lt $func_count ]]; then
        log_check "warn" "Puține variabile 'local' ($local_count) pentru $func_count funcții"
        TOTAL_SCORE=$((TOTAL_SCORE + WEIGHT_LOCAL_VARS / 2))
        return 0
    else
        log_check "pass" "Variabile 'local' folosite ($local_count instanțe)" $WEIGHT_LOCAL_VARS
        TOTAL_SCORE=$((TOTAL_SCORE + WEIGHT_LOCAL_VARS))
        return 0
    fi
}

check_declare_A() {
    local file="$1"
    
    verbose "Checking associative array declarations..."
    
    # Look for associative array patterns without declare -A
    # Pattern: var[string_key]= where string_key is not a variable or number
    
    local assoc_patterns
    assoc_patterns=$(grep -oE '\b[a-zA-Z_][a-zA-Z0-9_]*\[[a-zA-Z_]+\]=' "$file" | cut -d'[' -f1 | sort -u || true)
    
    if [[ -z "$assoc_patterns" ]]; then
        log_check "info" "Nu s-au detectat arrays asociative"
        TOTAL_SCORE=$((TOTAL_SCORE + WEIGHT_DECLARE_A))  # No penalty if none used
        return 0
    fi
    
    local declare_A_count
    declare_A_count=$(grep -c 'declare\s\+-A' "$file" || echo 0)
    
    if [[ $declare_A_count -eq 0 ]]; then
        log_check "fail" "Arrays asociative fără 'declare -A': $assoc_patterns"
        return 1
    else
        log_check "pass" "declare -A folosit corect ($declare_A_count declarații)" $WEIGHT_DECLARE_A
        TOTAL_SCORE=$((TOTAL_SCORE + WEIGHT_DECLARE_A))
        return 0
    fi
}

check_quoted_arrays() {
    local file="$1"
    
    verbose "Checking quoted array expansions..."
    
    # Unquoted array expansions in for loops - DANGEROUS
    local unquoted
    unquoted=$(grep -nE 'for\s+\w+\s+in\s+\$\{[^}]+\[@\]\}' "$file" | grep -v '"' || true)
    
    if [[ -n "$unquoted" ]]; then
        log_check "fail" "Array fără ghilimele în for loop (word splitting!)"
        verbose "  Găsit: $unquoted"
        return 1
    fi
    
    # Check for proper quoting
    local quoted_count
    quoted_count=$(grep -c '"\${[^}]*\[@\]}"' "$file" || echo 0)
    
    if [[ $quoted_count -gt 0 ]]; then
        log_check "pass" "Arrays cu ghilimele corecte ($quoted_count instanțe)" $WEIGHT_QUOTED_ARRAYS
        TOTAL_SCORE=$((TOTAL_SCORE + WEIGHT_QUOTED_ARRAYS))
    else
        # Check if arrays are used at all
        if grep -qE '\[@\]|\[\*\]' "$file"; then
            log_check "warn" "Arrays folosite, dar nu s-au găsit pattern-uri corecte cu ghilimele"
            TOTAL_SCORE=$((TOTAL_SCORE + WEIGHT_QUOTED_ARRAYS / 2))
        else
            log_check "info" "Nu s-au găsit expansiuni de arrays"
            TOTAL_SCORE=$((TOTAL_SCORE + WEIGHT_QUOTED_ARRAYS))
        fi
    fi
    
    return 0
}

check_trap_exit() {
    local file="$1"
    
    verbose "Checking trap EXIT..."
    
    if grep -qE 'trap\s+.*\s+EXIT' "$file"; then
        log_check "pass" "trap EXIT definit pentru cleanup" $WEIGHT_TRAP_EXIT
        TOTAL_SCORE=$((TOTAL_SCORE + WEIGHT_TRAP_EXIT))
        return 0
    else
        log_check "warn" "Lipsă trap EXIT (recomandat pentru cleanup)"
        return 0
    fi
}

check_usage_function() {
    local file="$1"
    
    verbose "Checking usage/help function..."
    
    if grep -qE '^usage\s*\(\)|^show_help\s*\(\)|^print_help\s*\(\)' "$file"; then
        log_check "pass" "Funcție usage/help definită" $WEIGHT_USAGE_FUNC
        TOTAL_SCORE=$((TOTAL_SCORE + WEIGHT_USAGE_FUNC))
        return 0
    elif grep -q '\-\-help' "$file"; then
        log_check "pass" "Handling pentru --help detectat" $((WEIGHT_USAGE_FUNC / 2))
        TOTAL_SCORE=$((TOTAL_SCORE + WEIGHT_USAGE_FUNC / 2))
        return 0
    else
        log_check "warn" "Lipsă funcție usage/help"
        return 0
    fi
}

check_shellcheck() {
    local file="$1"
    
    if [[ "$USE_SHELLCHECK" != "true" ]]; then
        verbose "Shellcheck skip (use -s to enable)"
        return 0
    fi
    
    if ! command -v shellcheck &>/dev/null; then
        log_check "warn" "shellcheck nu e instalat (skip)"
        return 0
    fi
    
    verbose "Running shellcheck..."
    
    local errors
    errors=$(shellcheck -f gcc "$file" 2>&1 | grep -c ':.*error:' || echo 0)
    local warnings
    warnings=$(shellcheck -f gcc "$file" 2>&1 | grep -c ':.*warning:' || echo 0)
    
    if [[ $errors -eq 0 ]] && [[ $warnings -eq 0 ]]; then
        log_check "pass" "shellcheck: fără erori sau warning-uri" $WEIGHT_SHELLCHECK
        TOTAL_SCORE=$((TOTAL_SCORE + WEIGHT_SHELLCHECK))
    elif [[ $errors -eq 0 ]]; then
        log_check "warn" "shellcheck: $warnings warnings (fără erori)"
        TOTAL_SCORE=$((TOTAL_SCORE + WEIGHT_SHELLCHECK / 2))
    else
        log_check "fail" "shellcheck: $errors erori, $warnings warnings"
        if [[ "$VERBOSE" == "true" ]]; then
            shellcheck "$file" 2>&1 | head -20
        fi
    fi
    
    return 0
}

# ============================================================
# VALIDATE FILE
# ============================================================

validate_file() {
    local file="$1"
    
    # Reset state
    TOTAL_SCORE=0
    ISSUES=()
    WARNINGS=()
    
    echo ""
    echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}Validare: ${CYAN}$file${NC}"
    echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════${NC}"
    
    if [[ ! -f "$file" ]]; then
        echo -e "${RED}EROARE: Fișierul nu există!${NC}"
        return 1
    fi
    
    if [[ ! -r "$file" ]]; then
        echo -e "${RED}EROARE: Nu pot citi fișierul!${NC}"
        return 1
    fi
    
    echo ""
    echo -e "${BOLD}Verificări:${NC}"
    
    check_shebang "$file"
    check_strict_mode "$file"
    check_local_variables "$file"
    check_declare_A "$file"
    check_quoted_arrays "$file"
    check_trap_exit "$file"
    check_usage_function "$file"
    check_shellcheck "$file"
    
    # Print results
    echo ""
    echo -e "${BOLD}═══════════════════ REZULTAT ═══════════════════${NC}"
    echo ""
    
    # Calculate percentage
    local pct=$((TOTAL_SCORE * 100 / MAX_SCORE))
    
    echo -e "Scor: ${BOLD}$TOTAL_SCORE / $MAX_SCORE${NC} ($pct%)"
    
    # Progress bar
    local filled=$((pct / 5))
    local empty=$((20 - filled))
    printf "["
    if [[ $pct -ge 70 ]]; then
        printf "${GREEN}%${filled}s${NC}" | tr ' ' '█'
    elif [[ $pct -ge 50 ]]; then
        printf "${YELLOW}%${filled}s${NC}" | tr ' ' '█'
    else
        printf "${RED}%${filled}s${NC}" | tr ' ' '█'
    fi
    printf "${DIM}%${empty}s${NC}" | tr ' ' '░'
    printf "]\n"
    echo ""
    
    # Grade
    if [[ $pct -ge 90 ]]; then
        echo -e "Grad: ${GREEN}${BOLD}EXCELENT${NC}"
    elif [[ $pct -ge 70 ]]; then
        echo -e "Grad: ${GREEN}BINE${NC}"
    elif [[ $pct -ge 50 ]]; then
        echo -e "Grad: ${YELLOW}SUFICIENT${NC}"
    else
        echo -e "Grad: ${RED}NECESITĂ ÎMBUNĂTĂȚIRI${NC}"
    fi
    
    # Issues summary
    if [[ ${#ISSUES[@]} -gt 0 ]]; then
        echo ""
        echo -e "${RED}Probleme de rezolvat:${NC}"
        for issue in "${ISSUES[@]}"; do
            echo "  • $issue"
        done
    fi
    
    if [[ ${#WARNINGS[@]} -gt 0 ]]; then
        echo ""
        echo -e "${YELLOW}Recomandări:${NC}"
        for warn in "${WARNINGS[@]}"; do
            echo "  • $warn"
        done
    fi
    
    echo ""
    return 0
}

# ============================================================
# MAIN
# ============================================================

main() {
    local files=()
    local dir=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -s|--shellcheck)
                USE_SHELLCHECK=true
                shift
                ;;
            -d|--dir)
                dir="$2"
                shift 2
                ;;
            -q|--quiet)
                # TODO: quiet mode
                shift
                ;;
            -*)
                echo "Unknown option: $1" >&2
                exit 1
                ;;
            *)
                files+=("$1")
                shift
                ;;
        esac
    done
    
    # Handle directory mode
    if [[ -n "$dir" ]]; then
        if [[ ! -d "$dir" ]]; then
            echo "Directory not found: $dir" >&2
            exit 1
        fi
        while IFS= read -r -d '' f; do
            files+=("$f")
        done < <(find "$dir" -name "*.sh" -type f -print0)
    fi
    
    if [[ ${#files[@]} -eq 0 ]]; then
        echo "No files to validate. Use --help for usage." >&2
        exit 1
    fi
    
    echo -e "${BOLD}${BLUE}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║          Bash Script Validator v$VERSION                       ║"
    echo "║          ASE București - CSIE                               ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    for file in "${files[@]}"; do
        validate_file "$file"
    done
    
    if [[ ${#files[@]} -gt 1 ]]; then
        echo ""
        echo -e "${BOLD}Total fișiere validate: ${#files[@]}${NC}"
    fi
}

main "$@"
