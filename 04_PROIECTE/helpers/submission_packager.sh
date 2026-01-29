#!/bin/bash
#===============================================================================
# NUME:        submission_packager.sh
# DESCRIERE:   Împachetează proiectul pentru submisie
# AUTOR:       Kit SO - ASE CSIE
# VERSIUNE:    1.0.0
#===============================================================================

set -euo pipefail

usage() {
    cat << EOF
Utilizare: $(basename "$0") <project_dir> <student_name> <project_id>

Împachetează proiectul pentru submisie, excluzând fișiere inutile.

Argumente:
  project_dir   Directorul proiectului
  student_name  Numele studentului (fără spații, ex: PopescuIon)
  project_id    ID-ul proiectului (ex: E01, M05, A02)

Exemple:
  $(basename "$0") ./my_project PopescuIon E01
  $(basename "$0") ~/project NumePrenume M05

Output:
  NumePrenume_ProiectID_YYYYMMDD.tar.gz
EOF
}

[[ $# -lt 3 ]] && { usage; exit 1; }

PROJECT_DIR="$1"
STUDENT_NAME="$2"
PROJECT_ID="$3"

[[ ! -d "$PROJECT_DIR" ]] && { echo "Eroare: '$PROJECT_DIR' nu există"; exit 1; }

DATE=$(date +%Y%m%d)
ARCHIVE_NAME="${STUDENT_NAME}_${PROJECT_ID}_${DATE}.tar.gz"

echo "╔══════════════════════════════════════════════╗"
echo "║     SUBMISSION PACKAGER - SO ASE CSIE        ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
echo "Proiect:  $PROJECT_DIR"
echo "Student:  $STUDENT_NAME"
echo "ID:       $PROJECT_ID"
echo "Output:   $ARCHIVE_NAME"
echo ""

# Creare arhivă excluzând fișiere inutile
echo "Împachetare..."
tar --exclude='__pycache__' \
    --exclude='*.pyc' \
    --exclude='.git' \
    --exclude='node_modules' \
    --exclude='.DS_Store' \
    --exclude='*.swp' \
    --exclude='*.tmp' \
    --exclude='.vscode' \
    --exclude='.idea' \
    -czvf "$ARCHIVE_NAME" \
    -C "$(dirname "$PROJECT_DIR")" \
    "$(basename "$PROJECT_DIR")"

# Verificare dimensiune
SIZE=$(du -h "$ARCHIVE_NAME" | cut -f1)
echo ""
echo "════════════════════════════════════════"
echo "✓ Arhivă creată: $ARCHIVE_NAME ($SIZE)"
echo "════════════════════════════════════════"

# Verificare conținut
echo ""
echo "Conținut arhivă:"
tar -tzvf "$ARCHIVE_NAME" | head -20
echo "... ($(tar -tzf "$ARCHIVE_NAME" | wc -l) fișiere total)"
