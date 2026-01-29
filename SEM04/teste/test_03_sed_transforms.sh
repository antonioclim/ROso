#!/bin/bash
# Test 03: SED Transformations
# Punctaj: 10 puncte (2 puncte per exercițiu)
set -euo pipefail

SCORE=0
TOTAL=10
DATA_DIR="../resurse/sample_data"
TEMP_DIR="/tmp/sed_test_$$"
mkdir -p "$TEMP_DIR"

echo "=== TEST 03: SED TRANSFORMATIONS ==="
echo ""

# Ex 1: Șterge comentariile (linii care încep cu #)
echo -n "Ex 1 - Șterge comentarii: "
EXPECTED=31
RESULT=$(sed '/^#/d' "$DATA_DIR/config.ini" | grep -c '.' 2>/dev/null || echo 0)
if [[ "$RESULT" == "$EXPECTED" ]]; then
    echo "✅ CORECT ($RESULT linii rămase)"
    ((SCORE+=2))
else
    echo "❌ Greșit (ai: $RESULT, corect: $EXPECTED)"
fi

# Ex 2: Înlocuiește 'true' cu 'yes'
echo -n "Ex 2 - true -> yes: "
EXPECTED=2
RESULT=$(sed 's/true/yes/g' "$DATA_DIR/config.ini" | grep -c 'yes' 2>/dev/null || echo 0)
if [[ "$RESULT" == "$EXPECTED" ]]; then
    echo "✅ CORECT ($RESULT înlocuiri)"
    ((SCORE+=2))
else
    echo "❌ Greșit (ai: $RESULT, corect: $EXPECTED)"
fi

# Ex 3: Extrage doar valorile (după =)
echo -n "Ex 3 - Extrage valori după =: "
cp "$DATA_DIR/config.ini" "$TEMP_DIR/temp.ini"
EXPECTED=25
RESULT=$(sed -n '/=/s/.*= *//p' "$TEMP_DIR/temp.ini" | wc -l)
if [[ "$RESULT" == "$EXPECTED" ]]; then
    echo "✅ CORECT ($RESULT valori)"
    ((SCORE+=2))
else
    echo "❌ Greșit (ai: $RESULT, corect: $EXPECTED)"
fi

# Ex 4: Adaugă prefix "CONFIG_" la secțiuni [xxx]
echo -n "Ex 4 - Prefix la secțiuni: "
EXPECTED=6
RESULT=$(sed 's/\[\([^]]*\)\]/[CONFIG_\1]/' "$DATA_DIR/config.ini" | grep -c 'CONFIG_' 2>/dev/null || echo 0)
if [[ "$RESULT" == "$EXPECTED" ]]; then
    echo "✅ CORECT ($RESULT secțiuni modificate)"
    ((SCORE+=2))
else
    echo "❌ Greșit (ai: $RESULT, corect: $EXPECTED)"
fi

# Ex 5: Șterge liniile goale și comentariile
echo -n "Ex 5 - Curăță config: "
EXPECTED=25
RESULT=$(sed '/^#/d; /^$/d; /^[[:space:]]*$/d' "$DATA_DIR/config.ini" | wc -l)
if [[ "$RESULT" == "$EXPECTED" ]]; then
    echo "✅ CORECT ($RESULT linii curate)"
    ((SCORE+=2))
else
    echo "❌ Greșit (ai: $RESULT, corect: $EXPECTED)"
fi

rm -rf "$TEMP_DIR"

echo ""
echo "=== SCOR FINAL: $SCORE / $TOTAL ==="
