#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# S05_ex01_functii_sol.sh — Soluție Exercițiu 1: Funcții cu Variabile Locale
# ═══════════════════════════════════════════════════════════════════════════════
# Sisteme de Operare | ASE București - CSIE
# Seminar 05: Advanced Bash Scripting
#
# CERINȚĂ:
#   Creează funcții care demonstrează folosirea corectă a variabilelor locale
#   și returnarea valorilor prin echo.
#
# UTILIZARE:
#   ./S05_ex01_functii_sol.sh
#
# PUNCTE CHEIE:
#   - Folosirea keyword-ului 'local' pentru variabile în funcții
#   - Returnarea valorilor prin echo (nu return)
#   - Capturarea rezultatelor cu $()
# ═══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

# ─────────────────────────────────────────────────────────────────────────────
# Funcție: numara_cuvinte
# Descriere: Numără cuvintele dintr-un string
# Argumente: $1 - string de analizat
# Returnează: Numărul de cuvinte (prin echo)
# ─────────────────────────────────────────────────────────────────────────────
numara_cuvinte() {
    local text="$1"
    local count
    
    # Folosim wc -w pentru numărare
    count=$(echo "$text" | wc -w)
    
    # Returnăm prin echo (NU return!)
    echo "$count"
}

# ─────────────────────────────────────────────────────────────────────────────
# Funcție: calculeaza_suma
# Descriere: Calculează suma a N numere
# Argumente: $@ - lista de numere
# Returnează: Suma (prin echo)
# ─────────────────────────────────────────────────────────────────────────────
calculeaza_suma() {
    local suma=0
    local numar
    
    for numar in "$@"; do
        # Verificăm că e număr valid
        if [[ "$numar" =~ ^-?[0-9]+$ ]]; then
            suma=$((suma + numar))
        fi
    done
    
    echo "$suma"
}

# ─────────────────────────────────────────────────────────────────────────────
# Funcție: valideaza_email
# Descriere: Verifică dacă un string e email valid (simplu)
# Argumente: $1 - string de verificat
# Returnează: 0 (valid) sau 1 (invalid) prin exit code
# ─────────────────────────────────────────────────────────────────────────────
valideaza_email() {
    local email="$1"
    local pattern='^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    
    if [[ "$email" =~ $pattern ]]; then
        return 0  # Valid
    else
        return 1  # Invalid
    fi
}

# ─────────────────────────────────────────────────────────────────────────────
# Funcție: gaseste_maxim
# Descriere: Găsește valoarea maximă din lista de numere
# Argumente: $@ - lista de numere
# Returnează: Maximul (prin echo)
# ─────────────────────────────────────────────────────────────────────────────
gaseste_maxim() {
    local max
    local numar
    
    # Inițializăm cu primul argument
    max="${1:-}"
    
    if [[ -z "$max" ]]; then
        echo ""
        return 1
    fi
    
    for numar in "$@"; do
        if [[ "$numar" =~ ^-?[0-9]+$ ]] && (( numar > max )); then
            max="$numar"
        fi
    done
    
    echo "$max"
}

# ─────────────────────────────────────────────────────────────────────────────
# Funcție: transforma_uppercase
# Descriere: Convertește string la uppercase
# Argumente: $1 - string de transformat
# Returnează: String în uppercase (prin echo)
# ─────────────────────────────────────────────────────────────────────────────
transforma_uppercase() {
    local text="$1"
    local rezultat
    
    # Bash 4.0+ feature
    rezultat="${text^^}"
    
    echo "$rezultat"
}

# ═══════════════════════════════════════════════════════════════════════════════
# TESTE / DEMONSTRAȚII
# ═══════════════════════════════════════════════════════════════════════════════

main() {
    echo "═══════════════════════════════════════════════════════════════"
    echo "  Demonstrație: Funcții cu Variabile Locale"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    
    # Test numara_cuvinte
    echo "1. numara_cuvinte:"
    local rezultat
    rezultat=$(numara_cuvinte "Aceasta este o propoziție test")
    echo "   Input: 'Aceasta este o propoziție test'"
    echo "   Rezultat: $rezultat cuvinte"
    echo ""
    
    # Test calculeaza_suma
    echo "2. calculeaza_suma:"
    rezultat=$(calculeaza_suma 10 20 30 40)
    echo "   Input: 10 20 30 40"
    echo "   Rezultat: $rezultat"
    echo ""
    
    # Test valideaza_email
    echo "3. valideaza_email:"
    local email1="test@exemplu.com"
    local email2="invalid-email"
    
    if valideaza_email "$email1"; then
        echo "   '$email1' → VALID"
    else
        echo "   '$email1' → INVALID"
    fi
    
    if valideaza_email "$email2"; then
        echo "   '$email2' → VALID"
    else
        echo "   '$email2' → INVALID"
    fi
    echo ""
    
    # Test gaseste_maxim
    echo "4. gaseste_maxim:"
    rezultat=$(gaseste_maxim 5 23 7 42 15 8)
    echo "   Input: 5 23 7 42 15 8"
    echo "   Maxim: $rezultat"
    echo ""
    
    # Test transforma_uppercase
    echo "5. transforma_uppercase:"
    rezultat=$(transforma_uppercase "hello world")
    echo "   Input: 'hello world'"
    echo "   Rezultat: '$rezultat'"
    echo ""
    
    echo "═══════════════════════════════════════════════════════════════"
    echo "  Toate testele au trecut!"
    echo "═══════════════════════════════════════════════════════════════"
}

# Rulare dacă e executat direct
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
