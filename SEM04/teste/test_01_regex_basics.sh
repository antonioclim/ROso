#!/bin/bash
# Test 01: Regex Basics - BRE vs ERE
# Punctaj: 10 puncte (2 puncte per exercițiu)
set -euo pipefail

SCORE=0
TOTAL=10
DATA_DIR="../resurse/sample_data"

echo "=== TEST 01: REGEX BASICS ==="
echo ""

# Ex 1: Găsește liniile care încep cu # (comentarii)
echo -n "Ex 1 - Comentarii (^#): "
EXPECTED=6
RESULT=$(grep -c '^#' "$DATA_DIR/config.ini" 2>/dev/null || echo 0)
if [[ "$RESULT" == "$EXPECTED" ]]; then
    echo "✅ CORECT ($RESULT)"
    ((SCORE+=2))
else
    echo "❌ Greșit (ai: $RESULT, corect: $EXPECTED)"
fi

# Ex 2: Găsește linii goale
echo -n "Ex 2 - Linii goale (^$): "
EXPECTED=6
RESULT=$(grep -c '^$' "$DATA_DIR/config.ini" 2>/dev/null || echo 0)
if [[ "$RESULT" == "$EXPECTED" ]]; then
    echo "✅ CORECT ($RESULT)"
    ((SCORE+=2))
else
    echo "❌ Greșit (ai: $RESULT, corect: $EXPECTED)"
fi

# Ex 3: Găsește adrese IP (pattern simplu)
echo -n "Ex 3 - Adrese IP: "
EXPECTED=6
RESULT=$(grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' "$DATA_DIR/contacts.txt" 2>/dev/null | wc -l)
if [[ "$RESULT" == "$EXPECTED" ]]; then
    echo "✅ CORECT ($RESULT)"
    ((SCORE+=2))
else
    echo "❌ Greșit (ai: $RESULT, corect: $EXPECTED)"
fi

# Ex 4: Găsește email-uri
echo -n "Ex 4 - Email-uri: "
EXPECTED=10
RESULT=$(grep -oE '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' "$DATA_DIR/contacts.txt" 2>/dev/null | wc -l)
if [[ "$RESULT" == "$EXPECTED" ]]; then
    echo "✅ CORECT ($RESULT)"
    ((SCORE+=2))
else
    echo "❌ Greșit (ai: $RESULT, corect: $EXPECTED)"
fi

# Ex 5: Găsește cuvinte duplicate consecutive
echo -n "Ex 5 - Cuvinte duplicate: "
EXPECTED=1
RESULT=$(grep -oE '\b(\w+)\s+\1\b' "$DATA_DIR/contacts.txt" 2>/dev/null | wc -l)
if [[ "$RESULT" == "$EXPECTED" ]]; then
    echo "✅ CORECT ($RESULT)"
    ((SCORE+=2))
else
    echo "❌ Greșit (ai: $RESULT, corect: $EXPECTED)"
fi

echo ""
echo "=== SCOR FINAL: $SCORE / $TOTAL ==="
