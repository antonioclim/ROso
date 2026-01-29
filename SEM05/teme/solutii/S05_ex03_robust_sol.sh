#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# S05_ex03_robust_sol.sh — Soluție Exercițiu 3: Scripting Defensiv
# ═══════════════════════════════════════════════════════════════════════════════
# Sisteme de Operare | ASE București - CSIE
# Seminar 05: Advanced Bash Scripting
#
# CERINȚĂ:
#   Demonstrează scripting defensiv cu:
#   - set -euo pipefail
#   - trap pentru cleanup
#   - Error handling
#   - Logging
#
# UTILIZARE:
#   ./S05_ex03_robust_sol.sh [--simulate-error]
# ═══════════════════════════════════════════════════════════════════════════════

# ─────────────────────────────────────────────────────────────────────────────
# SETUP DEFENSIV
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail
IFS=$'\n\t'

readonly SCRIPT_NAME=$(basename "$0")
readonly SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
readonly TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Fișier temporar pentru demonstrație
TMPFILE=""

# ─────────────────────────────────────────────────────────────────────────────
# LOGGING
# ─────────────────────────────────────────────────────────────────────────────
log_info() {
    echo "[INFO]  $(date '+%H:%M:%S') $*"
}

log_warn() {
    echo "[WARN]  $(date '+%H:%M:%S') $*" >&2
}

log_error() {
    echo "[ERROR] $(date '+%H:%M:%S') $*" >&2
}

# ─────────────────────────────────────────────────────────────────────────────
# CLEANUP (se execută ÎNTOTDEAUNA la ieșire)
# ─────────────────────────────────────────────────────────────────────────────
cleanup() {
    local exit_code=$?
    
    log_info "Cleanup: începe curățarea..."
    
    # Șterge fișierul temporar dacă există
    if [[ -n "${TMPFILE:-}" && -f "$TMPFILE" ]]; then
        log_info "Cleanup: șterg $TMPFILE"
        rm -f "$TMPFILE"
    fi
    
    if [[ $exit_code -eq 0 ]]; then
        log_info "Cleanup: script terminat cu succes"
    else
        log_warn "Cleanup: script terminat cu eroare (exit code: $exit_code)"
    fi
    
    exit "$exit_code"
}

# Înregistrăm trap-ul pentru EXIT (se execută la orice ieșire)
trap cleanup EXIT

# Trap pentru Ctrl+C (INT) - exit code 130 e convenția pentru SIGINT
trap 'log_warn "Întrerupt de utilizator (Ctrl+C)"; exit 130' INT

# Trap pentru TERM (kill default)
trap 'log_warn "Primit semnal TERM"; exit 143' TERM

# ─────────────────────────────────────────────────────────────────────────────
# FUNCȚII UTILITARE
# ─────────────────────────────────────────────────────────────────────────────
die() {
    log_error "$*"
    exit 1
}

verifica_dependente() {
    local cmd
    for cmd in "$@"; do
        if ! command -v "$cmd" &>/dev/null; then
            die "Dependință lipsă: $cmd"
        fi
    done
}

creeaza_fisier_temp() {
    TMPFILE=$(mktemp "/tmp/${SCRIPT_NAME}.XXXXXX")
    log_info "Creat fișier temporar: $TMPFILE"
}

# ─────────────────────────────────────────────────────────────────────────────
# PROCESARE PRINCIPALĂ
# ─────────────────────────────────────────────────────────────────────────────
procesare_date() {
    log_info "Procesare: început"
    
    # Scriem date în fișierul temporar
    echo "Date importante: $TIMESTAMP" > "$TMPFILE"
    echo "Script: $SCRIPT_NAME" >> "$TMPFILE"
    echo "PID: $$" >> "$TMPFILE"
    
    log_info "Procesare: date scrise în $TMPFILE"
    
    # Citim și afișăm
    log_info "Conținut fișier temporar:"
    while IFS= read -r line; do
        echo "   | $line"
    done < "$TMPFILE"
    
    log_info "Procesare: terminat"
}

simuleaza_eroare() {
    log_warn "Simulare eroare activată!"
    log_info "Următoarea comandă va eșua..."
    
    # Aceasta va declanșa set -e
    false
    
    # Această linie nu se execută niciodată
    log_info "Acest mesaj nu apare"
}

# ─────────────────────────────────────────────────────────────────────────────
# MAIN
# ─────────────────────────────────────────────────────────────────────────────
main() {
    log_info "═══════════════════════════════════════════════════════════════"
    log_info "  Script Defensiv - Demonstrație"
    log_info "═══════════════════════════════════════════════════════════════"
    
    # Verificăm dependențele
    verifica_dependente mktemp cat
    
    # Creăm fișier temporar
    creeaza_fisier_temp
    
    # Procesăm date
    procesare_date
    
    # Verificăm dacă trebuie să simulăm eroare
    if [[ "${1:-}" == "--simulate-error" ]]; then
        simuleaza_eroare
    fi
    
    log_info "═══════════════════════════════════════════════════════════════"
    log_info "  Script terminat normal"
    log_info "═══════════════════════════════════════════════════════════════"
}

# Rulăm main
main "$@"
