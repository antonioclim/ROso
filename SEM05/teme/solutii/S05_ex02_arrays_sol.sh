#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# S05_ex02_arrays_sol.sh — Soluție Exercițiu 2: Manipulare Arrays
# ═══════════════════════════════════════════════════════════════════════════════
# Sisteme de Operare | ASE București - CSIE
# Seminar 05: Advanced Bash Scripting
#
# CERINȚĂ:
#   Demonstrează operații cu arrays indexate și asociative.
#
# UTILIZARE:
#   ./S05_ex02_arrays_sol.sh
# ═══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

demo_arrays_indexate() {
    echo "═══════════════════════════════════════════════════════════════"
    echo "  ARRAYS INDEXATE"
    echo "═══════════════════════════════════════════════════════════════"
    
    # Declarare și inițializare
    local -a fructe=("măr" "pară" "banană" "portocală")
    
    echo "1. Array inițial: ${fructe[*]}"
    echo "2. Element [0]: ${fructe[0]}"
    echo "3. Lungime: ${#fructe[@]}"
    echo "4. Indici: ${!fructe[@]}"
    
    echo "5. Iterare corectă:"
    for fruct in "${fructe[@]}"; do
        echo "   - $fruct"
    done
    
    # Append
    fructe+=("kiwi")
    echo "6. După append: ${fructe[*]}"
    
    # Delete (creează sparse array)
    unset 'fructe[1]'
    echo "7. După unset [1] - Indici: ${!fructe[@]} (sparse!)"
}

demo_arrays_asociative() {
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo "  ARRAYS ASOCIATIVE (Hash)"
    echo "═══════════════════════════════════════════════════════════════"
    
    # OBLIGATORIU: declare -A
    declare -A config
    config[host]="localhost"
    config[port]="8080"
    config[debug]="true"
    
    echo "1. Chei: ${!config[*]}"
    echo "2. Valori: ${config[*]}"
    echo "3. Acces: config[host]=${config[host]}"
    
    echo "4. Iterare cheie=valoare:"
    for key in "${!config[@]}"; do
        echo "   $key = ${config[$key]}"
    done
}

demo_files_cu_spatii() {
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo "  FIȘIERE CU SPAȚII (importanța ghilimelelor)"
    echo "═══════════════════════════════════════════════════════════════"
    
    local -a files=("document one.txt" "report two.pdf" "data three.csv")
    
    echo "GREȘIT (fără ghilimele) - ar fi ${#files[@]} * 2 iterații"
    echo "CORECT (cu ghilimele):"
    local count=0
    for f in "${files[@]}"; do
        ((count++))
        echo "   $count: '$f'"
    done
    echo "Total iterații corecte: $count"
}

main() {
    demo_arrays_indexate
    demo_arrays_asociative
    demo_files_cu_spatii
    echo ""
    echo "Toate demonstrațiile complete!"
}

main "$@"
