#!/bin/bash
#===============================================================================
#
#          FILE: S04_02_quiz_interactiv.sh
#
#         USAGE: ./S04_02_quiz_interactiv.sh [--category CATEGORY] [--count N]
#
#   DESCRIPTION: Quiz interactiv pentru verificarea cunoștințelor
#                despre grep, sed, awk și expresii regulate
#
#       OPTIONS: --category  regex|grep|sed|awk|all (default: all)
#                --count     Număr de întrebări (default: 10)
#                --help      Afișează ajutor
#
#        AUTHOR: Asistent Universitar - Seminarul SO
#       VERSION: 1.0
#
#===============================================================================

set -euo pipefail

#-------------------------------------------------------------------------------
# CONFIGURARE
#-------------------------------------------------------------------------------

# Culori
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# Variabile quiz
CATEGORY="all"
QUESTION_COUNT=10
SCORE=0
TOTAL=0

#-------------------------------------------------------------------------------
# BAZA DE ÎNTREBĂRI
#-------------------------------------------------------------------------------

# Format: question|optionA|optionB|optionC|optionD|correct_letter|explanation

declare -a REGEX_QUESTIONS=(
    "Ce potrivește pattern-ul '.' în regex?|Punct literal|Orice caracter|Zero sau mai multe|Început de linie|B|Punctul (.) potrivește orice caracter singular."
    "Ce face '^' în afara parantezelor []?|Negație|Orice caracter|Început de linie|Sfârșit de linie|C|^ în afara [] este anchor pentru începutul liniei."
    "Ce face '^' înăuntrul [] la început?|Început de linie|Negație set|Orice caracter|Sfârșit de linie|B|[^abc] înseamnă 'orice EXCEPTÂND a, b, c'."
    "Care e diferența dintre * și + în ERE?|Nicio diferență|* = 0+, + = 1+|* = 1+, + = 0+|* = exact 1|B|* permite zero repetări, + cere minim una."
    "Ce pattern găsește linii goale?|^$|.*|.+|^.|A|^ imediat urmat de $ = linie fără conținut."
    "Ce face [[:alpha:]]?|Doar majuscule|Doar minuscule|Orice literă|Orice caracter|C|POSIX class alpha = toate literele."
    "Ce înseamnă regex 'colou?r'?|color|colour|color sau colour|Eroare|C|? face 'u' opțional: zero sau una."
    "Pattern-ul [0-9]* poate potrivi...|Cel puțin o cifră|Zero sau mai multe cifre|Exact o cifră|Niciun caracter|B|* permite zero repetări!"
)

declare -a GREP_QUESTIONS=(
    "Ce face opțiunea -i în grep?|Inversează|Case insensitive|Include linii|Ignoră fișier|B|-i ignoră diferențele de majuscule/minuscule."
    "Ce face opțiunea -v în grep?|Verbose|Inversează potriviri|Version|Validate|B|-v arată liniile care NU potrivesc."
    "Ce face opțiunea -c în grep?|Colorează|Numără linii|Confirmă|Curăță|B|-c returnează numărul de linii care potrivesc."
    "Ce face opțiunea -o în grep?|Output file|Doar match-ul|Omite erori|Ordine|B|-o afișează DOAR partea care potrivește."
    "grep -E este echivalent cu...|egrep|fgrep|pgrep|zgrep|A|-E activează Extended Regular Expressions."
    "Ce face grep -r?|Reverse|Recursiv|Regex|Replace|B|-r caută recursiv în directoare."
    "Ce face grep -l?|Line numbers|Doar nume fișiere|Last match|Long output|B|-l afișează doar numele fișierelor cu potriviri."
    "grep -c numără...|Caractere|Cuvinte|Linii|Toate aparițiile|C|-c numără LINII, nu aparițiile individuale!"
)

declare -a SED_QUESTIONS=(
    "Sintaxa de bază pentru substituție în sed este...|s/old/new|r/old/new|c/old/new|x/old/new|A|s = substitute."
    "Ce face flag-ul /g în sed s///g?|Global (toate)|Get|Grep|Generate|A|/g înlocuiește TOATE aparițiile pe linie."
    "sed implicit scrie în...|Fișier|stdout|stderr|/dev/null|B|sed scrie în stdout, NU modifică fișierul!"
    "Ce face sed -i?|Input|Inverse|In-place|Ignore|C|-i editează fișierul direct (PERICULOS fără backup!)."
    "Ce face & în replacement-ul sed?|And logic|Întregul match|Append|Anchor|B|& reprezintă tot ce a fost potrivit."
    "Ce face comanda d în sed?|Duplicate|Delete linia|Display|Divide|B|d șterge liniile potrivite."
    "Ce delimitator e VALID în sed?|Doar /|Doar #|Orice caracter|Doar | și /|C|Poți folosi orice: s|old|new| sau s#old#new#."
    "sed '/^#/d' face...|Șterge toate liniile|Șterge comentarii|Șterge linii goale|Șterge prima linie|B|Șterge liniile care ÎNCEP cu #."
)

declare -a AWK_QUESTIONS=(
    "Ce conține \$0 în awk?|Primul câmp|Numele programului|Linia întreagă|Ultimul câmp|C|\$0 este ÎNTREAGA linie (record)."
    "Ce conține \$NF în awk?|Numărul de câmpuri|Ultimul câmp|Newline|Primul câmp|B|\$NF = field-ul cu numărul NF (ultimul)."
    "Cum setezi separatorul la virgulă?|-s ','|-F','|-d ','|--sep=','|B|-F specifică Field Separator."
    "awk '{print \$1, \$2}' - virgula...|E opțională|Adaugă spațiu (OFS)|Concatenează|Face eroare|B|Virgula inserează OFS (default: spațiu)."
    "awk '{print \$1 \$2}' (fără virgulă)...|Adaugă spațiu|Concatenează direct|Face eroare|Ignoră \$2|B|Fără virgulă = concatenare directă."
    "NR în awk reprezintă...|Număr real|Number of Records|Next Row|Null Reference|B|NR = numărul curent al liniei (global)."
    "BEGIN { } se execută...|La fiecare linie|Înainte de procesare|După procesare|Niciodată|B|BEGIN rulează O SINGURĂ DATĂ, înainte de input."
    "Ce face NR > 1 în awk?|Numără linii|Sare peste header|Verifică numere|Nimic|B|NR > 1 exclude prima linie (header)."
)

#-------------------------------------------------------------------------------
# FUNCȚII
#-------------------------------------------------------------------------------

show_help() {
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════╗
║                    QUIZ INTERACTIV - TEXT PROCESSING                     ║
╚══════════════════════════════════════════════════════════════════════════╝

USAGE:
    ./S04_02_quiz_interactiv.sh [OPTIONS]

OPTIONS:
    --category CATEGORY   Alege categoria: regex, grep, sed, awk, all
    --count N             Număr de întrebări (default: 10)
    --help                Afișează acest mesaj

EXEMPLE:
    ./S04_02_quiz_interactiv.sh                    # Quiz complet, 10 întrebări
    ./S04_02_quiz_interactiv.sh --category grep    # Doar grep
    ./S04_02_quiz_interactiv.sh --count 5          # Doar 5 întrebări

EOF
}

shuffle_array() {
    local -n arr=$1
    local i j temp
    for ((i=${#arr[@]}-1; i>0; i--)); do
        j=$((RANDOM % (i+1)))
        temp="${arr[i]}"
        arr[i]="${arr[j]}"
        arr[j]="$temp"
    done
}

ask_question() {
    local q_data="$1"
    local q_num="$2"
    
    IFS='|' read -r question optA optB optC optD correct explanation <<< "$q_data"
    
    echo ""
    echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}Întrebarea $q_num:${NC}"
    echo -e "${YELLOW}$question${NC}"
    echo ""
    echo -e "  ${BOLD}A)${NC} $optA"
    echo -e "  ${BOLD}B)${NC} $optB"
    echo -e "  ${BOLD}C)${NC} $optC"
    echo -e "  ${BOLD}D)${NC} $optD"
    echo ""
    
    local answer
    while true; do
        read -rp "Răspunsul tău (A/B/C/D): " answer
        answer=$(echo "$answer" | tr '[:lower:]' '[:upper:]')
        if [[ "$answer" =~ ^[ABCD]$ ]]; then
            break
        fi
        echo -e "${RED}Introdu A, B, C sau D${NC}"
    done
    
    ((TOTAL++))
    
    if [[ "$answer" == "$correct" ]]; then
        echo -e "${GREEN}✓ CORECT!${NC}"
        ((SCORE++))
    else
        echo -e "${RED}✗ GREȘIT! Răspunsul corect era: $correct${NC}"
    fi
    
    echo -e "${BLUE}Explicație: $explanation${NC}"
    
    read -rp "Apasă Enter pentru a continua..."
}

run_quiz() {
    local -a questions=()
    
    # Selectează întrebările în funcție de categorie
    case "$CATEGORY" in
        regex)
            questions=("${REGEX_QUESTIONS[@]}")
            ;;
        grep)
            questions=("${GREP_QUESTIONS[@]}")
            ;;
        sed)
            questions=("${SED_QUESTIONS[@]}")
            ;;
        awk)
            questions=("${AWK_QUESTIONS[@]}")
            ;;
        all)
            questions=("${REGEX_QUESTIONS[@]}" "${GREP_QUESTIONS[@]}" 
                      "${SED_QUESTIONS[@]}" "${AWK_QUESTIONS[@]}")
            ;;
    esac
    
    # Amestecă întrebările
    shuffle_array questions
    
    # Limitează la numărul cerut
    local actual_count=${#questions[@]}
    if (( QUESTION_COUNT < actual_count )); then
        actual_count=$QUESTION_COUNT
    fi
    
    clear
    echo ""
    echo "╔══════════════════════════════════════════════════════════════════════════╗"
    echo "║                    🎯 QUIZ: TEXT PROCESSING 🎯                           ║"
    echo "╠══════════════════════════════════════════════════════════════════════════╣"
    echo "║  Categorie: $(printf "%-10s" "$CATEGORY")                                           ║"
    echo "║  Întrebări: $(printf "%-10s" "$actual_count")                                           ║"
    echo "╚══════════════════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Apasă Enter pentru a începe..."
    read -r
    
    for ((i=0; i<actual_count; i++)); do
        ask_question "${questions[i]}" "$((i+1))"
    done
    
    show_results
}

show_results() {
    clear
    local percentage=$((SCORE * 100 / TOTAL))
    local grade=""
    local emoji=""
    
    if (( percentage >= 90 )); then
        grade="EXCELENT"
        emoji="🏆"
    elif (( percentage >= 70 )); then
        grade="BINE"
        emoji="👍"
    elif (( percentage >= 50 )); then
        grade="ACCEPTABIL"
        emoji="📚"
    else
        grade="NECESITĂ PRACTICĂ"
        emoji="💪"
    fi
    
    echo ""
    echo "╔══════════════════════════════════════════════════════════════════════════╗"
    echo "║                         📊 REZULTATE QUIZ 📊                             ║"
    echo "╠══════════════════════════════════════════════════════════════════════════╣"
    echo "║                                                                          ║"
    printf "║  Scor: %d / %d (%d%%)                                              ║\n" "$SCORE" "$TOTAL" "$percentage"
    echo "║                                                                          ║"
    printf "║  Calificativ: %s %s                                          ║\n" "$emoji" "$grade"
    echo "║                                                                          ║"
    echo "╠══════════════════════════════════════════════════════════════════════════╣"
    
    if (( percentage >= 70 )); then
        echo "║  ✓ Ai o bună înțelegere a conceptelor!                                 ║"
    else
        echo "║  → Recitește materialul și practică exercițiile                        ║"
    fi
    
    echo "╚══════════════════════════════════════════════════════════════════════════╝"
    echo ""
}

#-------------------------------------------------------------------------------
# MAIN
#-------------------------------------------------------------------------------

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --category)
                CATEGORY="$2"
                shift 2
                ;;
            --count)
                QUESTION_COUNT="$2"
                shift 2
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                echo "Opțiune necunoscută: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Validare categorie
    if [[ ! "$CATEGORY" =~ ^(regex|grep|sed|awk|all)$ ]]; then
        echo "Categorie invalidă: $CATEGORY"
        echo "Folosește: regex, grep, sed, awk, sau all"
        exit 1
    fi
    
    run_quiz
}

main "$@"
