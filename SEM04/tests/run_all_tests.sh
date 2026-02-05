#!/bin/bash
# run_all_tests.sh - Runs all tests and generates report
# Usage: ./run_all_tests.sh
set -euo pipefail

cd "$(dirname "$0")"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║    SEM07-08: TEXT PROCESSING - AUTOMATED TEST SUITE        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

TOTAL_SCORE=0
TOTAL_MAX=0
PASSED_TESTS=0
FAILED_TESTS=0

for test_script in test_*.sh; do
    [[ -f "$test_script" ]] || continue
    [[ "$test_script" == "run_all_tests.sh" ]] && continue
    
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}📋 Running: $test_script${NC}"
    echo ""
    
    output=$(bash "$test_script" 2>&1)
    echo "$output"
    
    # Extract score from output
    score_line=$(echo "$output" | grep "FINAL SCORE" | tail -1)
    if [[ -n "$score_line" ]]; then
        score=$(echo "$score_line" | grep -oE '[0-9]+' | head -1)
        max=$(echo "$score_line" | grep -oE '[0-9]+' | tail -1)
        TOTAL_SCORE=$((TOTAL_SCORE + score))
        TOTAL_MAX=$((TOTAL_MAX + max))
        
        if [[ "$score" == "$max" ]]; then
            PASSED_TESTS=$((PASSED_TESTS + 1))
        else
            FAILED_TESTS=$((FAILED_TESTS + 1))
        fi
    fi
    
    echo ""
done

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                     FINAL REPORT                           ║${NC}"
echo -e "${BLUE}╠════════════════════════════════════════════════════════════╣${NC}"
printf "${BLUE}║${NC}  Total Score: ${GREEN}%3d${NC} / ${YELLOW}%-3d${NC}                                     ${BLUE}║${NC}\n" "$TOTAL_SCORE" "$TOTAL_MAX"
printf "${BLUE}║${NC}  Percentage:  ${GREEN}%.1f%%${NC}                                          ${BLUE}║${NC}\n" "$(awk -v s="$TOTAL_SCORE" -v m="$TOTAL_MAX" 'BEGIN {printf "%.1f", (s*100)/m}')"
printf "${BLUE}║${NC}  Tests:       ${GREEN}%d perfect${NC}, ${RED}%d partial${NC}                         ${BLUE}║${NC}\n" "$PASSED_TESTS" "$FAILED_TESTS"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"

# Determine grade
PERCENT=$(awk -v s="$TOTAL_SCORE" -v m="$TOTAL_MAX" 'BEGIN {printf "%d", int((s*100)/m)}')
if [[ $PERCENT -ge 90 ]]; then
    echo -e "\n${GREEN}🏆 EXCELLENT! You have mastered text processing!${NC}"
elif [[ $PERCENT -ge 70 ]]; then
    echo -e "\n${GREEN}👍 GOOD! Practise more for perfection.${NC}"
elif [[ $PERCENT -ge 50 ]]; then
    echo -e "\n${YELLOW}📚 SATISFACTORY. Re-read the documentation.${NC}"
else
    echo -e "\n${RED}📖 NEEDS STUDY. Consult the materials and try again.${NC}"
fi
