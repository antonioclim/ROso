#!/bin/bash
#===============================================================================
# NUME:        test_runner.sh
# DESCRIERE:   Runner pentru teste de proiect
# AUTOR:       Kit SO - ASE CSIE
# VERSIUNE:    1.0.0
#===============================================================================

set -euo pipefail

# Culori
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Contoare
TOTAL=0
PASSED=0
FAILED=0

usage() {
    cat << EOF
Utilizare: $(basename "$0") [opțiuni] <tests_dir>

Rulează toate testele dintr-un director.

Opțiuni:
  -h, --help        Afișează ajutor
  -v, --verbose     Output detaliat
  -s, --stop        Oprește la primul eșec
  -p, --pattern PAT Rulează doar testele matching pattern

Exemple:
  $(basename "$0") ./tests
  $(basename "$0") -v ./tests
  $(basename "$0") -p "test_main*" ./tests
EOF
}

VERBOSE=false
STOP_ON_FAIL=false
PATTERN="test_*.sh"

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help) usage; exit 0 ;;
        -v|--verbose) VERBOSE=true; shift ;;
        -s|--stop) STOP_ON_FAIL=true; shift ;;
        -p|--pattern) PATTERN="$2"; shift 2 ;;
        *) TESTS_DIR="$1"; shift ;;
    esac
done

[[ -z "${TESTS_DIR:-}" ]] && { usage; exit 1; }
[[ ! -d "$TESTS_DIR" ]] && { echo "Eroare: '$TESTS_DIR' nu există"; exit 1; }

echo "╔══════════════════════════════════════════════╗"
echo "║        TEST RUNNER - SO ASE CSIE             ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
echo "Director teste: $TESTS_DIR"
echo "Pattern: $PATTERN"
echo ""
echo "════════════════════════════════════════"

# Găsire și rulare teste
while IFS= read -r test_file; do
    [[ -z "$test_file" ]] && continue
    
    test_name=$(basename "$test_file")
    ((TOTAL++))
    
    echo -ne "${CYAN}Running:${NC} $test_name ... "
    
    # Rulare test și capturare output
    set +e
    if $VERBOSE; then
        output=$(bash "$test_file" 2>&1)
        exit_code=$?
        echo ""
        echo "$output"
    else
        output=$(bash "$test_file" 2>&1)
        exit_code=$?
    fi
    set -e
    
    if [[ $exit_code -eq 0 ]]; then
        echo -e "${GREEN}PASSED${NC}"
        ((PASSED++))
    else
        echo -e "${RED}FAILED${NC}"
        ((FAILED++))
        if ! $VERBOSE; then
            echo "  Output: ${output:0:100}..."
        fi
        if $STOP_ON_FAIL; then
            echo ""
            echo -e "${RED}Oprire la primul eșec.${NC}"
            break
        fi
    fi
done < <(find "$TESTS_DIR" -name "$PATTERN" -type f | sort)

# Sumar
echo ""
echo "════════════════════════════════════════"
echo "SUMAR TESTE"
echo "════════════════════════════════════════"
echo -e "  Total:   $TOTAL"
echo -e "  ${GREEN}Passed:${NC}  $PASSED"
echo -e "  ${RED}Failed:${NC}  $FAILED"

if [[ $TOTAL -gt 0 ]]; then
    PERCENT=$((PASSED * 100 / TOTAL))
    echo "  Rate:    $PERCENT%"
fi

echo "════════════════════════════════════════"

# Exit code bazat pe rezultate
[[ $FAILED -eq 0 ]] && exit 0 || exit 1
