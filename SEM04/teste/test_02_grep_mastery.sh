#!/bin/bash
# Test 02: GREP Mastery
# Punctaj: 10 puncte (2 puncte per exercițiu)
set -euo pipefail

SCORE=0
TOTAL=10
DATA_DIR="../resurse/sample_data"

echo "=== TEST 02: GREP MASTERY ==="
echo ""

# Ex 1: Numără ERROR-urile din log
echo -n "Ex 1 - Numără ERROR: "
EXPECTED=4
RESULT=$(grep -c 'ERROR' "$DATA_DIR/server.log" 2>/dev/null || echo 0)
if [[ "$RESULT" == "$EXPECTED" ]]; then
    echo "✅ CORECT ($RESULT)"
    ((SCORE+=2))
else
    echo "❌ Greșit (ai: $RESULT, corect: $EXPECTED)"
fi

# Ex 2: Găsește WARNING și ERROR (case insensitive)
echo -n "Ex 2 - WARNING sau ERROR: "
EXPECTED=9
RESULT=$(grep -ciE 'warning|error' "$DATA_DIR/server.log" 2>/dev/null || echo 0)
if [[ "$RESULT" == "$EXPECTED" ]]; then
    echo "✅ CORECT ($RESULT)"
    ((SCORE+=2))
else
    echo "❌ Greșit (ai: $RESULT, corect: $EXPECTED)"
fi

# Ex 3: Linii care NU conțin INFO
echo -n "Ex 3 - Linii fără INFO: "
EXPECTED=12
RESULT=$(grep -cv 'INFO' "$DATA_DIR/server.log" 2>/dev/null || echo 0)
if [[ "$RESULT" == "$EXPECTED" ]]; then
    echo "✅ CORECT ($RESULT)"
    ((SCORE+=2))
else
    echo "❌ Greșit (ai: $RESULT, corect: $EXPECTED)"
fi

# Ex 4: Extrage doar IP-urile unice
echo -n "Ex 4 - IP-uri unice: "
EXPECTED=9
RESULT=$(grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' "$DATA_DIR/server.log" 2>/dev/null | sort -u | wc -l)
if [[ "$RESULT" == "$EXPECTED" ]]; then
    echo "✅ CORECT ($RESULT)"
    ((SCORE+=2))
else
    echo "❌ Greșit (ai: $RESULT, corect: $EXPECTED)"
fi

# Ex 5: Numărul de login-uri
echo -n "Ex 5 - Login-uri: "
EXPECTED=3
RESULT=$(grep -c 'logged in' "$DATA_DIR/server.log" 2>/dev/null || echo 0)
if [[ "$RESULT" == "$EXPECTED" ]]; then
    echo "✅ CORECT ($RESULT)"
    ((SCORE+=2))
else
    echo "❌ Greșit (ai: $RESULT, corect: $EXPECTED)"
fi

echo ""
echo "=== SCOR FINAL: $SCORE / $TOTAL ==="
