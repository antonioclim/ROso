#!/bin/bash
# run_all_tests.sh - Rulează toate testele și generează raport
# Utilizare: ./run_all_tests.sh
set -euo pipefail

cd "$(dirname "$0")"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║    SEM07-08: TEXT PROCESSING - SUITĂ DE TESTE AUTOMATĂ     ║${NC}"
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
    echo -e "${YELLOW}📋 Rulare: $test_script${NC}"
    echo ""
    
    output=$(bash "$test_script" 2>&1)
    echo "$output"
    
    # Extract score from output
    score_line=$(echo "$output" | grep "SCOR FINAL" | tail -1)
    if [[ -n "$score_line" ]]; then
        score=$(echo "$score_line" | grep -oE '[0-9]+' | head -1)
        max=$(echo "$score_line" | grep -oE '[0-9]+' | tail -1)
        TOTAL_SCORE=$((TOTAL_SCORE + score))
        TOTAL_MAX=$((TOTAL_MAX + max))
        
        if [[ "$score" == "$max" ]]; then
            ((PASSED_TESTS++))
        else
            ((FAILED_TESTS++))
        fi
    fi
    
    echo ""
done

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                     RAPORT FINAL                           ║${NC}"
echo -e "${BLUE}╠════════════════════════════════════════════════════════════╣${NC}"
printf "${BLUE}║${NC}  Scor Total: ${GREEN}%3d${NC} / ${YELLOW}%-3d${NC}                                      ${BLUE}║${NC}\n" "$TOTAL_SCORE" "$TOTAL_MAX"
printf "${BLUE}║${NC}  Procent:    ${GREEN}%.1f%%${NC}                                           ${BLUE}║${NC}\n" "$(echo "scale=1; $TOTAL_SCORE * 100 / $TOTAL_MAX" | bc)"
printf "${BLUE}║${NC}  Teste:      ${GREEN}%d perfect${NC}, ${RED}%d parțial${NC}                          ${BLUE}║${NC}\n" "$PASSED_TESTS" "$FAILED_TESTS"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"

# Determine grade
PERCENT=$(echo "scale=0; $TOTAL_SCORE * 100 / $TOTAL_MAX" | bc)
if [[ $PERCENT -ge 90 ]]; then
    echo -e "\n${GREEN}🏆 EXCELENT! Ai stăpânit procesarea textului!${NC}"
elif [[ $PERCENT -ge 70 ]]; then
    echo -e "\n${GREEN}👍 BINE! Mai exersează pentru perfecțiune.${NC}"
elif [[ $PERCENT -ge 50 ]]; then
    echo -e "\n${YELLOW}📚 SATISFĂCĂTOR. Recitește documentația.${NC}"
else
    echo -e "\n${RED}📖 NECESITĂ STUDIU. Consultă materialele și încearcă din nou.${NC}"
fi
