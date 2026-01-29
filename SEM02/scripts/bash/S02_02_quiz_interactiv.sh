#!/bin/bash
#
# S02_02_quiz_interactiv.sh - Quiz interactiv pentru Seminarul 3-4
# Sisteme de Operare | ASE București - CSIE
#
#
# DESCRIERE: Quiz cu 15 întrebări randomizate despre operatori, redirecționare,
#            filtre și bucle. Folosește dialog dacă e disponibil, altfel text.
#
# UTILIZARE: ./S02_02_quiz_interactiv.sh
#
# DEPENDENȚE: dialog (opțional, pentru interfață grafică)
#
#

# Configurare
declare -i SCORE=0
declare -i TOTAL=0
declare -i QUESTIONS_TO_ASK=10
RESULTS_FILE="${HOME}/.quiz_results_sem02_$(date +%Y%m%d_%H%M%S).txt"

# Verificare dialog
USE_DIALOG=false
if command -v dialog &>/dev/null; then
    USE_DIALOG=true
fi

# Culori pentru mod text
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;36m'
NC='\033[0m' # No Color

#
# BAZA DE ÎNTREBĂRI
#

# Format: QUESTION|CORRECT_ANSWER|OPTION_A|OPTION_B|OPTION_C|OPTION_D|EXPLANATION
declare -a QUESTIONS=(
    # Operatori de control
    "Ce afișează: ls /home && echo OK || echo FAIL (dacă /home există)?|A|OK|FAIL|OK și FAIL|Nimic|&& execută următoarea comandă doar dacă prima reușește"
    
    "Ce face operatorul ; (punct și virgulă)?|B|Execută a doua comandă doar dacă prima reușește|Execută ambele comenzi secvențial, indiferent de rezultat|Execută a doua comandă doar dacă prima eșuează|Pornește comanda în background|; este secvențial simplu, fără condiții"
    
    "Ce returnează o comandă reușită în Bash?|A|0 (zero)|1 (unu)|-1 (minus unu)|true (text)|În Bash, 0 = succes, orice altceva = eroare"
    
    "Ce face operatorul & la sfârșitul unei comenzi?|C|Oprește comanda|Execută comanda cu drepturi root|Pornește comanda în background|Redirecționează output|& pornește procesul în background"
    
    # Redirecționare
    "Ce face 2>&1?|B|Redirecționează stdin la stdout|Redirecționează stderr la stdout|Redirecționează stdout la stderr|Redirecționează ambele la fișier|2>&1 trimite erori (fd 2) unde merge output-ul (fd 1)"
    
    "Care e diferența între > și >>?|A|> suprascrie, >> adaugă la final|> adaugă, >> suprascrie|Sunt identice|> e pentru stdout, >> pentru stderr|> creează/suprascrie, >> append"
    
    "Ce e /dev/null?|C|Un fișier normal|Directorul pentru device-uri|Un 'black hole' care ignoră tot ce primește|Locația pentru fișiere temporare|/dev/null este un device special care discardă datele"
    
    "Ce face operatorul < ?|A|Redirecționează input din fișier|Redirecționează output în fișier|Compară două valori|Creează un link|< citește input din fișier (stdin)"
    
    # Filtre
    "Ce face comanda uniq FĂRĂ sort înainte?|B|Elimină TOATE duplicatele|Elimină doar duplicatele CONSECUTIVE|Sortează fișierul|Afișează doar liniile unice|uniq vede doar duplicate adiacente!"
    
    "Ce face sort -n?|A|Sortare numerică (1, 2, 10 nu 1, 10, 2)|Sortare inversă|Sortare case-insensitive|Sortare după al N-lea câmp|sort -n interpretează numerele corect"
    
    "Ce face cut -d':' -f1?|B|Taie primul caracter|Extrage primul câmp, delimitator ':'|Șterge linia 1|Taie după primul ':'|-d setează delimitatorul, -f selectează câmpul"
    
    "Ce face tr 'a-z' 'A-Z'?|C|Șterge literele mici|Inversează textul|Convertește litere mici în majuscule|Numără literele|tr translate caractere, aici lowercase→uppercase"
    
    # Bucle
    "Ce afișează: N=5; for i in {1..\$N}; do echo \$i; done?|D|1 2 3 4 5|5 4 3 2 1|Eroare de sintaxă|{1..\$N} (literal)|Brace expansion se face ÎNAINTE de substituția variabilelor!"
    
    "Ce problemă are: cat file | while read line; do ((count++)); done; echo \$count?|A|count rămâne 0 (problema subshell)|Eroare de sintaxă|Funcționează corect|cat nu poate citi fișierul|Pipe creează subshell, variabilele nu persistă"
    
    "Care e diferența între break și exit?|B|Sunt identice|break iese din buclă, exit iese din script|break iese din script, exit din buclă|break e pentru for, exit pentru while|break = ieșire buclă, exit = terminare script"
)

#
# FUNCȚII
#

shuffle_array() {
    local -n arr=$1
    local i tmp size
    size=${#arr[@]}
    for ((i=size-1; i>0; i--)); do
        j=$((RANDOM % (i+1)))
        tmp=${arr[i]}
        arr[i]=${arr[j]}
        arr[j]=$tmp
    done
}

ask_question_dialog() {
    local question="$1"
    local correct="$2"
    local opt_a="$3"
    local opt_b="$4"
    local opt_c="$5"
    local opt_d="$6"
    local explanation="$7"
    
    local answer
    answer=$(dialog --stdout --title "🧠 Quiz Seminar 2" \
        --menu "$question" 18 70 4 \
        "A" "$opt_a" \
        "B" "$opt_b" \
        "C" "$opt_c" \
        "D" "$opt_d")
    
    if [[ "$answer" == "$correct" ]]; then
        ((SCORE++))
        dialog --title "✅ CORECT!" --msgbox "Bravo!\n\n$explanation" 10 60
        return 0
    else
        dialog --title "❌ GREȘIT" --msgbox "Răspuns corect: $correct\n\n$explanation" 10 60
        return 1
    fi
}

ask_question_text() {
    local question="$1"
    local correct="$2"
    local opt_a="$3"
    local opt_b="$4"
    local opt_c="$5"
    local opt_d="$6"
    local explanation="$7"
    
    clear
    echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}Întrebarea $((TOTAL+1))/${QUESTIONS_TO_ASK}${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${BLUE}$question${NC}"
    echo ""
    echo -e "  A) $opt_a"
    echo -e "  B) $opt_b"
    echo -e "  C) $opt_c"
    echo -e "  D) $opt_d"
    echo ""
    echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
    
    local answer
    while true; do
        read -p "Răspunsul tău (A/B/C/D): " answer
        answer=$(echo "$answer" | tr 'a-z' 'A-Z')
        if [[ "$answer" =~ ^[A-D]$ ]]; then
            break
        fi
        echo -e "${RED}Introdu A, B, C sau D${NC}"
    done
    
    echo ""
    if [[ "$answer" == "$correct" ]]; then
        ((SCORE++))
        echo -e "${GREEN}✅ CORECT!${NC}"
        echo -e "${GREEN}$explanation${NC}"
    else
        echo -e "${RED}❌ GREȘIT. Răspunsul corect era: $correct${NC}"
        echo -e "${YELLOW}$explanation${NC}"
    fi
    
    echo ""
    read -p "Apasă ENTER pentru a continua..."
}

show_results() {
    local percentage=$((SCORE * 100 / TOTAL))
    local grade=""
    local emoji=""
    
    if [[ $percentage -ge 90 ]]; then
        grade="EXCELENT"
        emoji="🌟"
    elif [[ $percentage -ge 70 ]]; then
        grade="BINE"
        emoji="✅"
    elif [[ $percentage -ge 50 ]]; then
        grade="SATISFĂCĂTOR"
        emoji="⚠️"
    else
        grade="NECESITĂ ÎMBUNĂTĂȚIRE"
        emoji="🔄"
    fi
    
    # Salvare rezultate
    {
        echo "═══════════════════════════════════════"
        echo "REZULTATE QUIZ SEMINAR 3-4"
        echo "Data: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "═══════════════════════════════════════"
        echo "Scor: $SCORE/$TOTAL ($percentage%)"
        echo "Calificativ: $grade"
        echo "═══════════════════════════════════════"
    } > "$RESULTS_FILE"
    
    if $USE_DIALOG; then
        dialog --title "$emoji REZULTATE QUIZ" --msgbox "
════════════════════════════════════
          QUIZ COMPLETAT!
════════════════════════════════════

Scor: $SCORE / $TOTAL

Procentaj: $percentage%

Calificativ: $grade $emoji

Rezultatele au fost salvate în:
$RESULTS_FILE

════════════════════════════════════
" 20 50
    else
        clear
        echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
        echo -e "${YELLOW}                    $emoji REZULTATE QUIZ $emoji${NC}"
        echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
        echo ""
        echo -e "  Scor: ${GREEN}$SCORE${NC} / $TOTAL"
        echo ""
        echo -e "  Procentaj: ${YELLOW}$percentage%${NC}"
        echo ""
        echo -e "  Calificativ: ${GREEN}$grade${NC}"
        echo ""
        echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
        echo ""
        echo -e "Rezultatele au fost salvate în:"
        echo -e "${YELLOW}$RESULTS_FILE${NC}"
        echo ""
    fi
}

#
# MAIN
#

main() {
    # Intro
    if $USE_DIALOG; then
        dialog --title "🧠 Quiz Interactiv - Seminar 2" --yesno "
Bine ai venit la Quiz-ul Seminar 2!

Vei răspunde la $QUESTIONS_TO_ASK întrebări despre:
• Operatori de control (&&, ||, ;, &)
• Redirecționare I/O (>, >>, <, 2>&1)
• Filtre de text (sort, uniq, cut, tr)
• Bucle (for, while, until)

Ești pregătit să începi?" 16 55
        
        [[ $? -ne 0 ]] && exit 0
    else
        clear
        echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
        echo -e "${YELLOW}           🧠 QUIZ INTERACTIV - SEMINAR 3-4${NC}"
        echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
        echo ""
        echo "Vei răspunde la $QUESTIONS_TO_ASK întrebări despre:"
        echo "  • Operatori de control (&&, ||, ;, &)"
        echo "  • Redirecționare I/O (>, >>, <, 2>&1)"
        echo "  • Filtre de text (sort, uniq, cut, tr)"
        echo "  • Bucle (for, while, until)"
        echo ""
        read -p "Apasă ENTER pentru a începe..."
    fi
    
    # Randomizare întrebări
    local indices=()
    for i in "${!QUESTIONS[@]}"; do
        indices+=($i)
    done
    shuffle_array indices
    
    # Întrebări
    for ((q=0; q<QUESTIONS_TO_ASK && q<${#QUESTIONS[@]}; q++)); do
        local idx=${indices[q]}
        IFS='|' read -r question correct opt_a opt_b opt_c opt_d explanation <<< "${QUESTIONS[$idx]}"
        
        ((TOTAL++))
        
        if $USE_DIALOG; then
            ask_question_dialog "$question" "$correct" "$opt_a" "$opt_b" "$opt_c" "$opt_d" "$explanation"
        else
            ask_question_text "$question" "$correct" "$opt_a" "$opt_b" "$opt_c" "$opt_d" "$explanation"
        fi
    done
    
    # Rezultate
    show_results
    
    clear
    echo -e "${GREEN}Mulțumim pentru participare!${NC}"
}

main "$@"
