#!/bin/bash
# Test 04: AWK Data Analysis
# Punctaj: 10 puncte (2 puncte per exercițiu)
set -euo pipefail

SCORE=0
TOTAL=10
DATA_DIR="../resurse/sample_data"

echo "=== TEST 04: AWK DATA ANALYSIS ==="
echo ""

# Ex 1: Număr total de angajați activi
echo -n "Ex 1 - Angajați activi: "
EXPECTED=13
RESULT=$(awk -F',' 'NR>1 && $7=="active" {count++} END {print count}' "$DATA_DIR/employees.csv" 2>/dev/null || echo 0)
if [[ "$RESULT" == "$EXPECTED" ]]; then
    echo "✅ CORECT ($RESULT)"
    ((SCORE+=2))
else
    echo "❌ Greșit (ai: $RESULT, corect: $EXPECTED)"
fi

# Ex 2: Suma salariilor din Engineering
echo -n "Ex 2 - Total salarii Engineering: "
EXPECTED=490000
RESULT=$(awk -F',' 'NR>1 && $4=="Engineering" {sum+=$5} END {print sum}' "$DATA_DIR/employees.csv" 2>/dev/null || echo 0)
if [[ "$RESULT" == "$EXPECTED" ]]; then
    echo "✅ CORECT (\$$RESULT)"
    ((SCORE+=2))
else
    echo "❌ Greșit (ai: $RESULT, corect: $EXPECTED)"
fi

# Ex 3: Media salariilor
echo -n "Ex 3 - Media salariilor: "
EXPECTED=70600
RESULT=$(awk -F',' 'NR>1 {sum+=$5; count++} END {printf "%.0f", sum/count}' "$DATA_DIR/employees.csv" 2>/dev/null || echo 0)
if [[ "$RESULT" == "$EXPECTED" ]]; then
    echo "✅ CORECT (\$$RESULT)"
    ((SCORE+=2))
else
    echo "❌ Greșit (ai: $RESULT, corect: $EXPECTED)"
fi

# Ex 4: Vânzări totale pentru Laptop
echo -n "Ex 4 - Revenue Laptop: "
EXPECTED=22800
RESULT=$(awk -F',' 'NR>1 && $2=="Laptop" {sum+=$3*$4} END {printf "%.0f", sum}' "$DATA_DIR/sales.csv" 2>/dev/null || echo 0)
if [[ "$RESULT" == "$EXPECTED" ]]; then
    echo "✅ CORECT (\$$RESULT)"
    ((SCORE+=2))
else
    echo "❌ Greșit (ai: $RESULT, corect: $EXPECTED)"
fi

# Ex 5: Departamentul cu cei mai mulți angajați
echo -n "Ex 5 - Cel mai mare departament: "
EXPECTED="Engineering"
RESULT=$(awk -F',' 'NR>1 {count[$4]++} END {max=0; for(d in count) if(count[d]>max) {max=count[d]; dept=d} print dept}' "$DATA_DIR/employees.csv" 2>/dev/null || echo "")
if [[ "$RESULT" == "$EXPECTED" ]]; then
    echo "✅ CORECT ($RESULT)"
    ((SCORE+=2))
else
    echo "❌ Greșit (ai: $RESULT, corect: $EXPECTED)"
fi

echo ""
echo "=== SCOR FINAL: $SCORE / $TOTAL ==="
