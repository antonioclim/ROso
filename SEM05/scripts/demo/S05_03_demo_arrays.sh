#!/bin/bash
#
# S05_03_demo_arrays.sh - Demonstrație Arrays Indexate și Asociative
# 
# Sisteme de Operare | ASE București - CSIE
# Seminar 5: Advanced Bash Scripting
#
# SCOP: Demonstrează diferențele între arrays indexate și asociative,
#       precum și misconceptiile comune (ghilimele, declare -A, indexare).
#
# UTILIZARE:
#   ./S05_03_demo_arrays.sh           # Rulează toate demo-urile
#   ./S05_03_demo_arrays.sh indexed   # Doar arrays indexate
#   ./S05_03_demo_arrays.sh assoc     # Doar arrays asociative
#   ./S05_03_demo_arrays.sh gotchas   # Doar greșeli comune
#

set -euo pipefail

# ============================================================
# CONSTANTE ȘI CULORI
# ============================================================
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# ============================================================
# HELPER FUNCTIONS
# ============================================================

header() {
    echo ""
    echo -e "${BOLD}${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${BLUE}  $1${NC}"
    echo -e "${BOLD}${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo ""
}

subheader() {
    echo ""
    echo -e "${CYAN}▶ $1${NC}"
    echo -e "${CYAN}────────────────────────────────────────${NC}"
}

code_block() {
    echo -e "${YELLOW}$1${NC}"
}

good() {
    echo -e "${GREEN}✓ $1${NC}"
}

bad() {
    echo -e "${RED}✗ $1${NC}"
}

info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

pause() {
    echo ""
    read -r -p "Apasă Enter pentru a continua..." </dev/tty 2>/dev/null || true
    echo ""
}

# ============================================================
# DEMO 1: ARRAYS INDEXATE - BAZĂ
# ============================================================

demo_indexed_basic() {
    header "ARRAYS INDEXATE - OPERAȚII DE BAZĂ"
    
    subheader "Creare Array"
    
    code_block 'arr=()'
    arr=()
    good "Array gol creat: arr=()"
    echo "Lungime: ${#arr[@]}"
    
    code_block 'fruits=("apple" "banana" "cherry")'
    fruits=("apple" "banana" "cherry")
    good "Array cu valori: ${fruits[*]}"
    echo "Lungime: ${#fruits[@]}"
    
    pause
    
    subheader "Acces Elemente"
    
    info "Capcană: Arrays încep de la index 0, NU de la 1!"
    echo ""
    
    code_block 'echo ${fruits[0]}'
    echo "Primul element (index 0): ${fruits[0]}"
    
    code_block 'echo ${fruits[1]}'
    echo "Al doilea element (index 1): ${fruits[1]}"
    
    code_block 'echo ${fruits[-1]}'
    echo "Ultimul element (index -1): ${fruits[-1]}"
    
    code_block 'echo ${fruits[@]}'
    echo "Toate elementele: ${fruits[@]}"
    
    code_block 'echo ${#fruits[@]}'
    echo "Număr elemente: ${#fruits[@]}"
    
    code_block 'echo ${!fruits[@]}'
    echo "Toți indicii: ${!fruits[@]}"
    
    pause
    
    subheader "Modificare Array"
    
    code_block 'fruits+=("date")'
    fruits+=("date")
    good "Append: ${fruits[*]}"
    
    code_block 'fruits[1]="BANANA"'
    fruits[1]="BANANA"
    good "Modificare index 1: ${fruits[*]}"
    
    code_block 'fruits[10]="extra"'
    fruits[10]="extra"
    warning "Inserare la index 10 (sparse array)!"
    echo "Array: ${fruits[*]}"
    echo "Indici: ${!fruits[@]}"
    
    code_block 'unset fruits[10]'
    unset 'fruits[10]'
    good "Șters index 10: ${fruits[*]}"
}

# ============================================================
# DEMO 2: ARRAYS INDEXATE - ITERARE
# ============================================================

demo_indexed_iteration() {
    header "ARRAYS INDEXATE - ITERARE CORECTĂ"
    
    # Array cu elemente ce conțin spații - provocare!
    files=("file one.txt" "file two.txt" "my document.pdf")
    
    info "Array cu elemente ce conțin spații:"
    echo "files=(\"file one.txt\" \"file two.txt\" \"my document.pdf\")"
    echo ""
    
    subheader "❌ GREȘIT: Fără ghilimele"
    warning "for f in \${files[@]}; do ..."
    echo ""
    
    code_block '# Output incorect - sparge elementele!'
    local count=0
    # shellcheck disable=SC2068
    for f in ${files[@]}; do
        ((count++))
        bad "[$count] -> $f"
    done
    echo ""
    warning "Rezultat: $count iterații în loc de 3!"
    
    pause
    
    subheader "✓ CORECT: Cu ghilimele"
    good "for f in \"\${files[@]}\"; do ..."
    echo ""
    
    code_block '# Output corect - păstrează elementele'
    count=0
    for f in "${files[@]}"; do
        ((count++))
        good "[$count] -> $f"
    done
    echo ""
    good "Rezultat: $count iterații (corect!)"
    
    pause
    
    subheader "Alte Pattern-uri de Iterare"
    
    fruits=("apple" "banana" "cherry")
    
    echo "1. Prin indici:"
    code_block 'for idx in "${!fruits[@]}"; do'
    for idx in "${!fruits[@]}"; do
        echo "   [$idx] = ${fruits[$idx]}"
    done
    
    echo ""
    echo "2. Stil C (doar arrays dense):"
    code_block 'for ((i=0; i<${#fruits[@]}; i++)); do'
    for ((i=0; i<${#fruits[@]}; i++)); do
        echo "   [$i] = ${fruits[$i]}"
    done
}

# ============================================================
# DEMO 3: ARRAYS ASOCIATIVE
# ============================================================

demo_associative() {
    header "ARRAYS ASOCIATIVE (Hash / Dictionary)"
    
    subheader "⚠️ MISCONCEPTIE CRITICĂ: declare -A este OBLIGATORIU!"
    
    echo ""
    warning "Fără declare -A, Bash tratează ca array indexat!"
    echo ""
    
    code_block '# GREȘIT - fără declare -A'
    echo "wrong[host]=\"localhost\""
    echo "wrong[port]=\"8080\""
    
    # Demonstrăm problema (fără a o executa pentru că ar seta wrong)
    info "Ce se întâmplă:"
    echo "  - Bash interpretează 'host' ca variabilă (nedefinită = 0)"
    echo "  - wrong[0]=\"localhost\", wrong[0]=\"8080\" (suprascrie!)"
    echo "  - Indici rezultați: 0 (nu host, port)"
    
    pause
    
    subheader "✓ CORECT: Cu declare -A"
    
    code_block 'declare -A config'
    declare -A config
    
    code_block 'config[host]="localhost"'
    config[host]="localhost"
    
    code_block 'config[port]="8080"'
    config[port]="8080"
    
    code_block 'config[user]="admin"'
    config[user]="admin"
    
    good "Array asociativ creat corect!"
    echo ""
    echo "Valori: ${config[*]}"
    echo "Chei: ${!config[*]}"
    echo "Număr: ${#config[@]}"
    
    pause
    
    subheader "Acces și Iterare"
    
    echo "Acces element:"
    code_block 'echo ${config[host]}'
    echo "Host: ${config[host]}"
    
    echo ""
    echo "Valoare default pentru cheie inexistentă:"
    code_block 'echo ${config[missing]:-"N/A"}'
    echo "Missing: ${config[missing]:-"N/A"}"
    
    echo ""
    echo "Verificare existență cheie:"
    code_block '[[ -v config[host] ]] && echo "Există"'
    [[ -v config[host] ]] && echo "config[host] există!"
    
    echo ""
    echo "Iterare prin chei:"
    code_block 'for key in "${!config[@]}"; do'
    for key in "${!config[@]}"; do
        echo "   $key = ${config[$key]}"
    done
    
    pause
    
    subheader "Exemplu Practic: Contorizare Cuvinte"
    
    code_block 'declare -A word_count'
    declare -A word_count
    
    text="the cat sat on the mat and the cat saw the rat"
    info "Text: $text"
    echo ""
    
    code_block 'for word in $text; do ((word_count[$word]++)); done'
    for word in $text; do
        ((word_count[$word]++))
    done
    
    echo "Rezultat (sortat):"
    for word in "${!word_count[@]}"; do
        printf "   %s: %d\n" "$word" "${word_count[$word]}"
    done | sort -t: -k2 -rn
}

# ============================================================
# DEMO 4: GOTCHAS ȘI GREȘELI COMUNE
# ============================================================

demo_gotchas() {
    header "GOTCHAS - GREȘELI COMUNE CU ARRAYS"
    
    subheader "1. Indexare de la 0, nu de la 1"
    
    arr=("first" "second" "third")
    
    bad "arr[1] = ${arr[1]} (NU e primul element!)"
    good "arr[0] = ${arr[0]} (ACESTA e primul element)"
    
    pause
    
    subheader "2. Sparse Arrays după unset"
    
    arr=("a" "b" "c" "d" "e")
    echo "Array inițial: ${arr[*]}"
    echo "Indici inițiali: ${!arr[@]}"
    
    code_block 'unset arr[2]'
    unset 'arr[2]'
    
    warning "După unset arr[2]:"
    echo "Array: ${arr[*]}"
    echo "Indici: ${!arr[@]}"
    bad "Indicii NU se reindexează! Index 2 lipsește."
    
    pause
    
    subheader "3. Diferența între @ și *"
    
    arr=("one two" "three" "four five")
    
    echo "Array: ${arr[*]}"
    echo ""
    
    echo "Cu @:"
    code_block 'for i in "${arr[@]}"; do echo "> $i"; done'
    for i in "${arr[@]}"; do
        echo "   > $i"
    done
    
    echo ""
    echo "Cu * (fără ghilimele - GREȘIT):"
    code_block 'for i in ${arr[*]}; do echo "> $i"; done'
    # shellcheck disable=SC2068
    for i in ${arr[*]}; do
        echo "   > $i"
    done
    
    warning "Cu * fără ghilimele, word splitting se aplică!"
    
    pause
    
    subheader "4. Verificare Array Gol"
    
    empty_arr=()
    
    code_block 'if [ ${#arr[@]} -eq 0 ]; then echo "Gol"; fi'
    if [ ${#empty_arr[@]} -eq 0 ]; then
        good "Array-ul e gol (verificare corectă)"
    fi
    
    # Nu așa!
    warning "NU folosi: if [ -z \"\${arr}\" ] - verifică doar arr[0]!"
    
    pause
    
    subheader "5. Copierea Arrays"
    
    original=("a" "b" "c")
    
    bad "copy=\$original  # GREȘIT - copiază doar primul element"
    
    # Demonstrăm
    # shellcheck disable=SC2128
    wrong_copy=$original
    echo "wrong_copy conține: '$wrong_copy'"
    
    good "copy=(\"\${original[@]}\")  # CORECT"
    correct_copy=("${original[@]}")
    echo "correct_copy conține: ${correct_copy[*]}"
}

# ============================================================
# DEMO 5: OPERAȚII AVANSATE
# ============================================================

demo_advanced() {
    header "OPERAȚII AVANSATE CU ARRAYS"
    
    subheader "Slice (Subsecvență)"
    
    arr=("a" "b" "c" "d" "e" "f")
    echo "Array: ${arr[*]}"
    echo ""
    
    code_block 'echo ${arr[@]:1:3}'
    echo "De la index 1, 3 elemente: ${arr[*]:1:3}"
    
    code_block 'echo ${arr[@]:2}'
    echo "De la index 2 până la final: ${arr[*]:2}"
    
    code_block 'echo ${arr[@]::3}'
    echo "Primele 3 elemente: ${arr[*]::3}"
    
    pause
    
    subheader "Sortare"
    
    unsorted=("cherry" "apple" "banana" "date")
    echo "Nesortat: ${unsorted[*]}"
    
    code_block 'readarray -t sorted < <(printf "%s\n" "${unsorted[@]}" | sort)'
    readarray -t sorted < <(printf '%s\n' "${unsorted[@]}" | sort)
    good "Sortat: ${sorted[*]}"
    
    nums=(42 7 13 99 1 23)
    echo ""
    echo "Numere nesortate: ${nums[*]}"
    
    code_block 'readarray -t sorted_nums < <(printf "%s\n" "${nums[@]}" | sort -n)'
    readarray -t sorted_nums < <(printf '%s\n' "${nums[@]}" | sort -n)
    good "Sortat numeric: ${sorted_nums[*]}"
    
    pause
    
    subheader "Filtru și Map"
    
    numbers=(1 2 3 4 5 6 7 8 9 10)
    echo "Numere: ${numbers[*]}"
    
    echo ""
    echo "Filtru - doar pare:"
    even=()
    for n in "${numbers[@]}"; do
        ((n % 2 == 0)) && even+=("$n")
    done
    good "Pare: ${even[*]}"
    
    echo ""
    echo "Map - pătrate:"
    squared=()
    for n in "${numbers[@]}"; do
        squared+=("$((n * n))")
    done
    good "Pătrate: ${squared[*]}"
    
    pause
    
    subheader "Join și Split"
    
    arr=("one" "two" "three")
    echo "Array: ${arr[*]}"
    
    echo ""
    echo "Join cu virgulă:"
    # shellcheck disable=SC2034
    IFS_OLD=$IFS
    IFS=','
    joined="${arr[*]}"
    IFS=$'\n\t'
    good "Joined: $joined"
    
    echo ""
    echo "Split string în array:"
    csv="apple,banana,cherry"
    IFS=',' read -ra split_arr <<< "$csv"
    good "Split: ${split_arr[*]}"
}

# ============================================================
# DEMO 6: QUIZ INTERACTIV
# ============================================================

demo_quiz() {
    header "QUIZ: ARRAYS - Testează-ți Cunoștințele!"
    
    local score=0
    local total=5
    
    # Q1
    echo -e "${BOLD}Q1: Ce returnează \${#arr[@]} pentru arr=(a b c)?${NC}"
    echo "    a) 3"
    echo "    b) 1"
    echo "    c) abc"
    read -r -p "Răspuns (a/b/c): " ans </dev/tty
    if [[ "$ans" == "a" ]]; then
        good "Corect! Returnează numărul de elemente."
        ((score++))
    else
        bad "Greșit. \${#arr[@]} returnează numărul de elemente (3)."
    fi
    echo ""
    
    # Q2
    echo -e "${BOLD}Q2: Pentru a crea un array asociativ, ce e OBLIGATORIU?${NC}"
    echo "    a) Nimic special"
    echo "    b) declare -a"
    echo "    c) declare -A"
    read -r -p "Răspuns (a/b/c): " ans </dev/tty
    if [[ "$ans" == "c" ]]; then
        good "Corect! declare -A e obligatoriu pentru asociative."
        ((score++))
    else
        bad "Greșit. Fără declare -A, Bash tratează ca array indexat."
    fi
    echo ""
    
    # Q3
    echo -e "${BOLD}Q3: arr=(\"a b\" \"c\"); for i in \${arr[@]}; - câte iterații?${NC}"
    echo "    a) 2"
    echo "    b) 3"
    echo "    c) Eroare"
    read -r -p "Răspuns (a/b/c): " ans </dev/tty
    if [[ "$ans" == "b" ]]; then
        good "Corect! Fără ghilimele, \"a b\" devine 2 elemente separate."
        ((score++))
    else
        bad "Greșit. Fără ghilimele, word splitting separă \"a b\" în \"a\" și \"b\"."
    fi
    echo ""
    
    # Q4
    echo -e "${BOLD}Q4: De la ce index încep arrays în Bash?${NC}"
    echo "    a) 0"
    echo "    b) 1"
    echo "    c) Depinde de declarație"
    read -r -p "Răspuns (a/b/c): " ans </dev/tty
    if [[ "$ans" == "a" ]]; then
        good "Corect! Arrays încep de la index 0."
        ((score++))
    else
        bad "Greșit. Arrays în Bash încep întotdeauna de la 0."
    fi
    echo ""
    
    # Q5
    echo -e "${BOLD}Q5: După 'unset arr[2]', indicii se reindexează automat?${NC}"
    echo "    a) Da"
    echo "    b) Nu"
    read -r -p "Răspuns (a/b): " ans </dev/tty
    if [[ "$ans" == "b" ]]; then
        good "Corect! unset creează sparse array, indicii nu se reindexează."
        ((score++))
    else
        bad "Greșit. unset NU reindexează - array-ul devine sparse."
    fi
    echo ""
    
    # Rezultat
    header "REZULTAT QUIZ"
    echo -e "Scor: ${BOLD}$score / $total${NC}"
    
    if [ "$score" -eq "$total" ]; then
        good "Excelent! Stăpânești arrays în Bash!"
    elif [ "$score" -ge 3 ]; then
        info "Bine! Revizuiește conceptele unde ai greșit."
    else
        warning "Necesită studiu suplimentar. Recitește materialul!"
    fi
}

# ============================================================
# MAIN
# ============================================================

main() {
    case "${1:-all}" in
        indexed)
            demo_indexed_basic
            demo_indexed_iteration
            ;;
        assoc)
            demo_associative
            ;;
        gotchas)
            demo_gotchas
            ;;
        advanced)
            demo_advanced
            ;;
        quiz)
            demo_quiz
            ;;
        all)
            demo_indexed_basic
            pause
            demo_indexed_iteration
            pause
            demo_associative
            pause
            demo_gotchas
            pause
            demo_advanced
            pause
            demo_quiz
            ;;
        *)
            echo "Usage: $0 [indexed|assoc|gotchas|advanced|quiz|all]"
            exit 1
            ;;
    esac
    
    echo ""
    echo -e "${BOLD}${GREEN}═══ Demo Arrays Completat! ═══${NC}"
}

main "$@"
