#!/bin/bash
#
# Soluție Exercițiu 1: Creare Structură Directoare
# Seminar 01 - Shell Fundamentals
# Sisteme de Operare | ASE București - CSIE
#
# Cerință: Creează structura de directoare pentru un proiect
# cu fișiere README.md și AUTOR.txt
#

# Defensive coding - oprește execuția la prima eroare
set -euo pipefail

# Configurare - directorul țintă
TARGET_DIR="${1:-proiect_so}"

# Creare structură directoare folosind brace expansion
# -p creează părinții dacă nu există
mkdir -p "${TARGET_DIR}"/{src,docs,tests}

# Creare README.md în directorul principal
cat > "${TARGET_DIR}/README.md" << 'EOF'
# Proiect Sisteme de Operare

## Descriere
Acest director conține structura standard pentru proiectele de laborator.

## Structură
```
proiect/
├── src/      # Cod sursă
├── docs/     # Documentație
└── tests/    # Teste
```

## Autor
Completează cu numele tău în AUTOR.txt
EOF

# Creare AUTOR.txt cu data curentă
cat > "${TARGET_DIR}/AUTOR.txt" << EOF
Nume: [Completează]
Grupa: [Completează]
Data: $(date +%Y-%m-%d)
EOF

# Verificare și afișare structură
echo "Structură creată în: ${TARGET_DIR}"
echo ""

# Afișează structura (folosește tree dacă există, altfel find)
if command -v tree &>/dev/null; then
    tree "${TARGET_DIR}"
else
    find "${TARGET_DIR}" -type f -o -type d | sort
fi

echo ""
echo "Verificare completă."
