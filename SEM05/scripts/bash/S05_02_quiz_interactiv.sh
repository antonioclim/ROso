#!/bin/bash
#
# S05_02_quiz_interactiv.sh - Quiz Interactiv pentru Seminar
# 
# Sisteme de Operare | ASE București - CSIE
# Seminar 9-10: Advanced Bash Scripting
#
# SCOP: Quiz interactiv cu întrebări MCQ pentru verificarea cunoștințelor.
#       Poate fi rulat în timpul seminarului sau ca auto-evaluare.
#
# UTILIZARE:
#   ./S05_02_quiz_interactiv.sh              # Quiz complet
#   ./S05_02_quiz_interactiv.sh --topic functions  # Doar funcții
#   ./S05_02_quiz_interactiv.sh --quick      # Versiune scurtă (5 întrebări)
#

set -euo pipefail

# ============================================================
# CONSTANTE ȘI CULORI
# ============================================================
readonly SCRIPT_NAME=$(basename "$0")
readonly VERSION="1.0.0"

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly DIM='\033[2m'
readonly NC='\033[0m'

# ============================================================
# STATE
# ============================================================
SCORE=0
TOTAL=0
ANSWERS=()

# ============================================================
# HELPER FUNCTIONS
# ============================================================

clear_screen() {
    printf '\033[2J\033[H'
}

print_header() {
    echo -e "${BOLD}${BLUE}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║          Quiz: Advanced Bash Scripting                      ║"
    echo "║          ASE București - CSIE                               ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_progress() {
    local current=$1
    local total=$2
    local pct=$((current * 100 / total))
    local filled=$((pct / 5))
    local empty=$((20 - filled))
    
    printf "${CYAN}Progress: [${NC}"
    printf "${GREEN}%${filled}s${NC}" | tr ' ' '█'
    printf "${DIM}%${empty}s${NC}" | tr ' ' '░'
    printf "${CYAN}] %d/%d${NC}\n" "$current" "$total"
}

ask_question() {
    local question="$1"
    local option_a="$2"
    local option_b="$3"
    local option_c="$4"
    local option_d="$5"
    local correct="$6"
    local explanation="$7"
    
    ((TOTAL++))
    
    echo ""
    echo -e "${BOLD}Întrebarea $TOTAL:${NC}"
    echo ""
    echo -e "$question"
    echo ""
    echo -e "  ${CYAN}A)${NC} $option_a"
    echo -e "  ${CYAN}B)${NC} $option_b"
    echo -e "  ${CYAN}C)${NC} $option_c"
    echo -e "  ${CYAN}D)${NC} $option_d"
    echo ""
    
    local answer=""
    while [[ ! "$answer" =~ ^[AaBbCcDd]$ ]]; do
        read -r -p "Răspunsul tău (A/B/C/D): " answer
    done
    
    answer=$(echo "$answer" | tr '[:lower:]' '[:upper:]')
    ANSWERS+=("$answer")
    
    echo ""
    if [[ "$answer" == "$correct" ]]; then
        ((SCORE++))
        echo -e "${GREEN}✓ CORECT!${NC}"
    else
        echo -e "${RED}✗ GREȘIT! Răspunsul corect era: $correct${NC}"
    fi
    
    echo ""
    echo -e "${DIM}Explicație: $explanation${NC}"
    echo ""
    
    read -r -p "Apasă Enter pentru a continua..." </dev/tty
}

# ============================================================
# QUESTIONS: FUNCTIONS
# ============================================================

quiz_functions() {
    ask_question \
'```bash
count=10
increment() {
    count=$((count + 1))
}
increment
echo $count
```
Ce afișează acest script?' \
        '10 (variabila din funcție e locală)' \
        '11 (variabila e modificată global)' \
        'Eroare: variabila nu e definită' \
        '1 (count e resetat)' \
        'B' \
        'Variabilele în Bash sunt GLOBALE by default! Fără "local", funcția modifică variabila din scope-ul exterior.'

    ask_question \
'```bash
get_sum() {
    local a=$1 b=$2
    return $((a + b))
}
get_sum 100 200
echo $?
```
Ce afișează acest script?' \
        '300' \
        '44 (300 mod 256)' \
        '0' \
        'Eroare' \
        'B' \
        'return poate returna doar valori 0-255 (exit codes). 300 mod 256 = 44. Pentru valori mari, folosește echo + $().'

    ask_question \
'Ce face keyword-ul "local" în Bash?' \
        'Declară o constantă care nu poate fi modificată' \
        'Face variabila vizibilă doar în funcția curentă' \
        'Exportă variabila în environment' \
        'Face variabila read-only' \
        'B' \
        'local creează o variabilă cu scope limitat la funcția în care e declarată. Fără local, variabilele sunt GLOBALE.'

    ask_question \
'Care e metoda RECOMANDATĂ pentru a "returna" un string dintr-o funcție?' \
        'return "string"' \
        'RESULT="string" (variabilă globală)' \
        'echo "string" și capturat cu $()' \
        'export "string"' \
        'C' \
        'Pattern recomandat: result=$(func); funcția face echo, iar apelantul capturează cu $().'
}

# ============================================================
# QUESTIONS: ARRAYS
# ============================================================

quiz_arrays() {
    ask_question \
'```bash
arr=("alpha" "beta" "gamma")
echo ${arr[1]}
```
Ce afișează?' \
        'alpha' \
        'beta' \
        'gamma' \
        'Eroare' \
        'B' \
        'Arrays în Bash încep de la INDEX 0! arr[0]=alpha, arr[1]=beta, arr[2]=gamma.'

    ask_question \
'```bash
files=("my file.txt" "doc.pdf")
for f in ${files[@]}; do echo "[$f]"; done
```
Câte linii se afișează?' \
        '2' \
        '3' \
        '4' \
        'Depinde de shell' \
        'B' \
        'Fără ghilimele, word splitting se aplică! "my file.txt" devine 2 elemente. Corect: "${files[@]}"'

    ask_question \
'Ce e OBLIGATORIU pentru arrays asociative în Bash?' \
        'Nimic special' \
        'declare -a' \
        'declare -A' \
        'export -A' \
        'C' \
        'Fără declare -A, Bash tratează ca array indexat! Cheile text devin 0 (variabilă nedefinită).'

    ask_question \
'```bash
arr=("a" "b" "c")
unset arr[1]
echo ${!arr[@]}
```
Ce afișează?' \
        '0 1 2' \
        '0 2' \
        '0 1' \
        'a c' \
        'B' \
        'unset NU reindexează! Creează "sparse array" cu gaură. ${!arr[@]} arată indicii existenți.'
}

# ============================================================
# QUESTIONS: solidNESS
# ============================================================

quiz_robust() {
    ask_question \
'Ce face "set -e" în Bash?' \
        'Activează extended globbing' \
        'Scriptul se oprește la prima eroare' \
        'Exportă toate variabilele' \
        'Activează debug mode' \
        'B' \
        'set -e (errexit) face scriptul să se oprească când o comandă returnează non-zero. DAR are limitări!'

    ask_question \
'```bash
set -e
if false; then echo "yes"; fi
echo "continued"
```
Ce se întâmplă?' \
        'Scriptul se oprește la false' \
        'Afișează "yes" și "continued"' \
        'Afișează doar "continued"' \
        'Eroare de sintaxă' \
        'C' \
        'set -e NU funcționează în context de test (if/while/until)! false în if nu oprește scriptul.'

    ask_question \
'```bash
false | true
echo $?
```
Ce afișează FĂRĂ pipefail?' \
        '0' \
        '1' \
        'Ambele' \
        'Nimic' \
        'A' \
        'Fără pipefail, pipeline returnează exit code-ul ULTIMEI comenzi. true = 0.'

    ask_question \
'Când se execută un trap EXIT?' \
        'Doar la exit 0 (success)' \
        'Doar la erori' \
        'ÎNTOTDEAUNA la ieșirea din script' \
        'Doar la Ctrl+C' \
        'C' \
        'trap EXIT se execută mereu: la final normal, la erori, sau la semnale. Ideal pentru cleanup!'
}

# ============================================================
# QUESTIONS: MIXED
# ============================================================

quiz_mixed() {
    ask_question \
'Care combinație e recomandată la începutul scripturilor robuste?' \
        'set -e' \
        'set -eu' \
        'set -euo pipefail' \
        'set -xv' \
        'C' \
        'set -e (exit on error), -u (error on undefined), -o pipefail (propagate pipe errors). Triada sfântă!'

    ask_question \
'```bash
DEBUG=true
[[ "$DEBUG" == "true" ]] && set -x
```
Ce face acest pattern?' \
        'Setează o variabilă de mediu' \
        'Activează debug/trace mode dacă DEBUG=true' \
        'Definește o funcție de debug' \
        'Exportă DEBUG în subshells' \
        'B' \
        'Pattern comun: activează set -x (trace) condițional bazat pe variabila DEBUG din environment.'

    ask_question \
'Care e ordinea de căutare când tastezi o comandă în Bash?' \
        'builtin → alias → function → external' \
        'alias → function → builtin → external' \
        'external → builtin → function → alias' \
        'function → alias → builtin → external' \
        'B' \
        'Ordinea: alias → function → builtin → external ($PATH). Funcțiile au prioritate peste comenzile externe!'

    ask_question \
'Cum "bypass-ui" o funcție pentru a apela comanda externă originală?' \
        'external ls' \
        'command ls' \
        'builtin ls' \
        '/ls' \
        'B' \
        'command cmd sare peste funcții și alias-uri. builtin e doar pentru built-ins. /bin/ls funcționează dar necesită cale.'
}

# ============================================================
# PRINT RESULTS
# ============================================================

print_results() {
    clear_screen
    print_header
    
    local pct=$((SCORE * 100 / TOTAL))
    
    echo ""
    echo -e "${BOLD}═══════════════════ REZULTATE ═══════════════════${NC}"
    echo ""
    echo -e "Scor: ${BOLD}$SCORE / $TOTAL${NC} ($pct%)"
    echo ""
    
    # Progress bar
    local filled=$((pct / 5))
    local empty=$((20 - filled))
    printf "["
    if [[ $pct -ge 70 ]]; then
        printf "${GREEN}%${filled}s${NC}" | tr ' ' '█'
    elif [[ $pct -ge 50 ]]; then
        printf "${YELLOW}%${filled}s${NC}" | tr ' ' '█'
    else
        printf "${RED}%${filled}s${NC}" | tr ' ' '█'
    fi
    printf "${DIM}%${empty}s${NC}" | tr ' ' '░'
    printf "]\n"
    echo ""
    
    # Grade
    if [[ $pct -ge 90 ]]; then
        echo -e "${GREEN}${BOLD}EXCELENT!${NC} Stăpânești Advanced Bash! 🎉"
    elif [[ $pct -ge 70 ]]; then
        echo -e "${GREEN}BINE!${NC} Înțelegere solidă, dar mai e loc de îmbunătățire."
    elif [[ $pct -ge 50 ]]; then
        echo -e "${YELLOW}SUFICIENT${NC} - Revizuiește conceptele unde ai greșit."
    else
        echo -e "${RED}NECESITĂ STUDIU${NC} - Recitește materialul și încearcă din nou."
    fi
    
    echo ""
    echo -e "${BOLD}Răspunsurile tale:${NC} ${ANSWERS[*]}"
    echo ""
    
    echo -e "${DIM}Sfaturi pentru îmbunătățire:${NC}"
    if [[ $pct -lt 100 ]]; then
        echo "  • Recitește S05_02_MATERIAL_PRINCIPAL.md"
        echo "  • Rulează scripturile demo din scripts/demo/"
        echo "  • Practică cu exercițiile din exercitii/"
    fi
    echo ""
}

# ============================================================
# USAGE
# ============================================================

usage() {
    cat << EOF
${BOLD}$SCRIPT_NAME v$VERSION${NC}

Quiz interactiv pentru verificarea cunoștințelor de Advanced Bash.

${BOLD}UTILIZARE:${NC}
    $SCRIPT_NAME [opțiuni]

${BOLD}OPȚIUNI:${NC}
    -h, --help          Afișează acest mesaj
    -t, --topic TOPIC   Doar un topic (functions|arrays|robust)
    -q, --quick         Versiune scurtă (o întrebare per topic)
    -a, --all           Toate întrebările (default)

${BOLD}EXEMPLE:${NC}
    $SCRIPT_NAME                    # Quiz complet
    $SCRIPT_NAME --topic functions  # Doar funcții
    $SCRIPT_NAME --quick            # Versiune scurtă

EOF
}

# ============================================================
# MAIN
# ============================================================

main() {
    local topic="all"
    local quick=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            -t|--topic)
                topic="$2"
                shift 2
                ;;
            -q|--quick)
                quick=true
                shift
                ;;
            -a|--all)
                topic="all"
                shift
                ;;
            *)
                echo "Unknown option: $1" >&2
                exit 1
                ;;
        esac
    done
    
    clear_screen
    print_header
    
    echo "Bine ai venit la quiz-ul de Advanced Bash!"
    echo ""
    echo "Vei primi întrebări cu 4 variante de răspuns."
    echo "Tastează litera corespunzătoare (A/B/C/D) și apasă Enter."
    echo ""
    read -r -p "Apasă Enter pentru a începe..." </dev/tty
    
    case "$topic" in
        functions)
            quiz_functions
            ;;
        arrays)
            quiz_arrays
            ;;
        robust)
            quiz_robust
            ;;
        mixed)
            quiz_mixed
            ;;
        all)
            if [[ "$quick" == "true" ]]; then
                # One question per topic
                TOTAL=0
                ask_question \
'Ce face "local" în funcții Bash?' \
                    'Exportă variabila' \
                    'Face variabila vizibilă doar în funcție' \
                    'Declară o constantă' \
                    'Nimic special' \
                    'B' \
                    'local limitează scope-ul variabilei la funcția curentă.'
                
                ask_question \
'declare -A este OBLIGATORIU pentru:' \
                    'Arrays indexate' \
                    'Variabile întregi' \
                    'Arrays asociative' \
                    'Funcții' \
                    'C' \
                    'Fără declare -A, hash-urile nu funcționează corect!'
                
                ask_question \
'set -e NU oprește scriptul în:' \
                    'Comenzi simple' \
                    'Condiții if' \
                    'Loops' \
                    'Funcții' \
                    'B' \
                    'set -e ignoră erori în context de test (if/while/until).'
            else
                quiz_functions
                quiz_arrays
                quiz_robust
                quiz_mixed
            fi
            ;;
        *)
            echo "Topic necunoscut: $topic" >&2
            echo "Opțiuni: functions, arrays, robust, mixed, all" >&2
            exit 1
            ;;
    esac
    
    print_results
}

main "$@"
