#!/bin/bash
# validate_000supplementary.sh
# Script de validare pentru directorul 00_SUPPLEMENTARY
# Rulați din interiorul directorului 00_SUPPLEMENTARY

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║         000SUPPLEMENTARY Validation Script v1.0                ║"
echo "║                    ASE Bucharest — CSIE                        ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

ERRORS=0
WARNINGS=0

# Check README.md
echo "Verific documentația..."
if [ -f "README.md" ]; then
    echo "  ✓ README.md există"
else
    echo "  ✗ README.md LIPSEȘTE"
    ((ERRORS++))
fi

if [ -f "QUICK_REFERENCE_CARD.md" ]; then
    echo "  ✓ QUICK_REFERENCE_CARD.md există"
else
    echo "  ⚠ QUICK_REFERENCE_CARD.md lipsește (opțional)"
    ((WARNINGS++))
fi

if [ -f ".gitignore" ]; then
    echo "  ✓ .gitignore există"
else
    echo "  ⚠ .gitignore lipsește (recomandat)"
    ((WARNINGS++))
fi

# Check folder names (English)
echo ""
echo "Verific structura de directoare..."
if [ -d "diagrams_png" ]; then
    echo "  ✓ diagrams_png folder (English naming)"
else
    echo "  ✗ diagrams_png directorul lipsește"
    ((ERRORS++))
fi

if [ -d "diagrams_common" ]; then
    echo "  ✓ diagrams_common folder (English naming)"
else
    echo "  ✗ diagrams_common directorul lipsește"
    ((ERRORS++))
fi

# Check no __pycache__
if [ -d "__pycache__" ]; then
    echo "  ✗ __pycache__ should be removed"
    ((ERRORS++))
else
    echo "  ✓ No __pycache__ directory"
fi

# Check Romanian filenames in diagrams
echo ""
echo "Verific numele fișierelor de diagrame..."
if [ -d "diagrams_png" ]; then
    RO_FILES=$(ls diagrams_png/ 2>/dev/null | grep -cE "algoritmi|conditiile|diagrama|evolutia|mecanismul|modele|producator|sectiunea|securitate|spatiu|straturile|structura|tlb_acces|arhitecturi|categorii|comparatie")
    if [ "$RO_FILES" -eq 0 ]; then
        echo "  ✓ Toate numele fișierelor PNG sunt în engleză"
    else
        echo "  ✗ $RO_FILES au rămas nume PNG în română"
        ((ERRORS++))
    fi
    
    PNG_COUNT=$(ls diagrams_png/*.png 2>/dev/null | wc -l)
    echo "  ℹ Total fișiere PNG: $PNG_COUNT"
fi

# Check Python syntax
echo ""
echo "Verific calitatea codului..."
python3 -m py_compile generate_diagrams.py 2>/dev/null
if [ $? -eq 0 ]; then
    echo "  ✓ Sintaxa Python este OK"
else
    echo "  ✗ Erori de sintaxă Python"
    ((ERRORS++))
fi

# Check for type hints in Python
if grep -q "def.*) -> " generate_diagrams.py 2>/dev/null; then
    echo "  ✓ Există type hints"
else
    echo "  ⚠ Lipsesc type hints"
    ((WARNINGS++))
fi

# Check for Oxford comma
echo ""
echo "Verific calitatea limbii..."
OXFORD=$(grep -c ", and " Exam_Exercises_Part*.md 2>/dev/null || echo 0)
if [ "$OXFORD" -eq 0 ]; then
    echo "  ✓ Nu a fost detectată virgula Oxford"
else
    echo "  ⚠ $OXFORD posibile apariții ale virgulei Oxford"
    ((WARNINGS++))
fi

# Check for AI patterns
AI_PATTERNS=$(grep -ciE "It is important to note|Let's explore|This ensures|Furthermore|Moreover|Additionally" Exam_Exercises_Part*.md 2>/dev/null | awk -F: '{sum+=$2} END {print sum+0}')
if [ "$AI_PATTERNS" -eq 0 ]; then
    echo "  ✓ Nu au fost detectate pattern-uri de tip amprentă AI"
else
    echo "  ⚠ $AI_PATTERNS au fost detectate formulări de tip AI"
    ((WARNINGS++))
fi

# Check British spelling
BRITISH=$(grep -c "isation\|ise\b" Exam_Exercises_Part*.md 2>/dev/null | awk -F: '{sum+=$2} END {print sum+0}')
AMERICAN=$(grep -cE "ization|ize\b" Exam_Exercises_Part*.md 2>/dev/null | awk -F: '{sum+=$2} END {print sum+0}')
echo "  ℹ ortografii britanice: $BRITISH, ortografii americane: $AMERICAN"

# Check content volume
echo ""
echo "Verific volumul de conținut..."
TOTAL_LINES=$(wc -l Exam_Exercises_Part*.md 2>/dev/null | tail -1 | awk '{print $1}')
echo "  ℹ Conținut total exerciții: $TOTAL_LINES lines"

TOTAL_WORDS=$(wc -w Exam_Exercises_Part*.md 2>/dev/null | tail -1 | awk '{print $1}')
echo "  ℹ Număr total de cuvinte: $TOTAL_WORDS words"

# Summary
echo ""
echo "════════════════════════════════════════════════════════════════"
echo "REZUMAT VALIDARE"
echo "════════════════════════════════════════════════════════════════"
echo "  Erori:   $ERRORS"
echo "  Avertismente: $WARNINGS"
echo ""

if [ $ERRORS -eq 0 ]; then
    if [ $WARNINGS -eq 0 ]; then
        echo "✓ TOATE VERIFICĂRILE AU TRECUT — gata pentru 10/10!"
    else
        echo "✓ Nu există erori critice — $WARNINGS avertismente minore"
    fi
    exit 0
else
    echo "✗ $ERRORS erori găsite — corectați înainte de livrare"
    exit 1
fi
