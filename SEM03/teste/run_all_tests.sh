#!/bin/bash
#
# run_all_tests.sh - Runner pentru toate testele Seminarului 03
# 
# Tema: find/xargs, getopts, Permisiuni, CRON
# Curs: Sisteme de Operare | ASE București - CSIE
#

set -euo pipefail

#
# CONFIGURARE
#
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

# Culori
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

#
# FUNCȚII HELPER
#

print_header() {
    echo -e "${BLUE}"
    echo "═══════════════════════════════════════════════════════════════"
    echo "        TESTE SEMINAR 03: System Administrator Toolkit"
    echo "═══════════════════════════════════════════════════════════════"
    echo -e "${NC}"
}

print_summary() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo "                         SUMAR"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "  ${GREEN}✓ Passed:${NC}  $TESTS_PASSED"
    echo -e "  ${RED}✗ Failed:${NC}  $TESTS_FAILED"
    echo -e "  ${YELLOW}○ Skipped:${NC} $TESTS_SKIPPED"
    echo ""
    
    local total=$((TESTS_PASSED + TESTS_FAILED))
    if [[ $total -gt 0 ]]; then
        local percentage=$((TESTS_PASSED * 100 / total))
        echo "  Score: $percentage% ($TESTS_PASSED/$total)"
    fi
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
}

run_test() {
    local test_name="$1"
    local test_file="$2"
    
    printf "  Testing: %-40s " "$test_name"
    
    if [[ ! -f "$test_file" ]]; then
        echo -e "${YELLOW}[SKIP]${NC} - File not found"
        ((TESTS_SKIPPED++))
        return
    fi
    
    if [[ ! -x "$test_file" ]]; then
        chmod +x "$test_file"
    fi
    
    if "$test_file" >/dev/null 2>&1; then
        echo -e "${GREEN}[PASS]${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}[FAIL]${NC}"
        ((TESTS_FAILED++))
    fi
}

#
# MAIN
#

main() {
    print_header
    
    echo "Running tests from: $SCRIPT_DIR"
    echo ""
    
    echo -e "${YELLOW}--- Tests ---${NC}"
    
    run_test "find & xargs" "$SCRIPT_DIR/test_01_find_xargs.sh"
    run_test "getopts parsing" "$SCRIPT_DIR/test_02_getopts.sh"
    run_test "Permissions (chmod/chown)" "$SCRIPT_DIR/test_03_permisiuni.sh"
    run_test "CRON syntax" "$SCRIPT_DIR/test_04_cron.sh"
    
    print_summary
    
    if [[ $TESTS_FAILED -gt 0 ]]; then
        exit 1
    fi
}

main "$@"
