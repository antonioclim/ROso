#!/bin/bash
#
# Script:      simple_script.sh
# Descriere:   Template minimalist pentru scripturi simple
# Autor:       ing. dr. Antonio Clim (ASE București - CSIE)
# Versiune:    1.0.0
#

# ============================================================
# SAFETY OPTIONS - Obligatorii pentru ORICE script
# ============================================================
set -euo pipefail

# ============================================================
# VARIABILE
# ============================================================
readonly SCRIPT_NAME=$(basename "$0")

# ============================================================
# HELPERS
# ============================================================
usage() {
    echo "Utilizare: $SCRIPT_NAME <argument>"
    echo "Descriere scurtă a ce face scriptul."
    exit 1
}

die() {
    echo "EROARE: $*" >&2
    exit 1
}

# ============================================================
# VALIDARE
# ============================================================
[[ $# -ge 1 ]] || usage
[[ -f "$1" ]] || die "Fișierul nu există: $1"

# ============================================================
# MAIN
# ============================================================
INPUT="$1"

echo "Procesez: $INPUT"

# Logica ta aici...

echo "Gata."
