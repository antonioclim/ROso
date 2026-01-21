#!/bin/bash
#
# QUIZ INTERACTIV - Seminar 1-2: Shell Bash
# Sisteme de Operare | ASE București - CSIE
#
# Scop: Auto-evaluare cunoștințe shell bash
# Utilizare: ./quiz_seminar1.sh
#

# Culori
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'
BOLD='\033[1m'

# Scoruri
SCORE=0
TOTAL=0

# Funcții utilitare
clear_screen() { clear; }

show_header() {
    echo -e "\n${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}        ${WHITE}${BOLD}QUIZ: Shell Bash - Seminar 1-2${NC}                        ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}        Sisteme de Operare | ASE București - CSIE             ${BLUE}║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}\n"
}

show_progress() {
    echo -e "${CYAN}Scor curent: $SCORE/$TOTAL${NC}\n"
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
    
    echo -e "${WHITE}${BOLD}Întrebarea $TOTAL:${NC}"
    echo -e "${YELLOW}$question${NC}\n"
    echo -e "  ${CYAN}A)${NC} $option_a"
    echo -e "  ${CYAN}B)${NC} $option_b"
    echo -e "  ${CYAN}C)${NC} $option_c"
    echo -e "  ${CYAN}D)${NC} $option_d"
    echo ""
    
    read -p "Răspunsul tău (A/B/C/D): " -n 1 answer
    echo -e "\n"
    
    answer=$(echo "$answer" | tr '[:lower:]' '[:upper:]')
    
    if [ "$answer" == "$correct" ]; then
        ((SCORE++))
        echo -e "${GREEN}✓ CORECT!${NC}"
    else
        echo -e "${RED}✗ GREȘIT! Răspunsul corect era: $correct${NC}"
    fi
    
    echo -e "${BLUE}Explicație:${NC} $explanation\n"
    
    read -p "Apasă Enter pentru a continua..."
    clear_screen
    show_header
    show_progress
}

# Întrebare cu predicție (rulează cod)
ask_prediction() {
    local question="$1"
    local code="$2"
    local correct="$3"
    local explanation="$4"
    
    ((TOTAL++))
    
    echo -e "${WHITE}${BOLD}Întrebarea $TOTAL (Predicție):${NC}"
    echo -e "${YELLOW}$question${NC}\n"
    echo -e "${CYAN}Cod:${NC}"
    echo -e "${WHITE}$code${NC}\n"
    
    read -p "Ce va afișa? " answer
    
    echo -e "\n${BLUE}Rezultat real:${NC}"
    eval "$code" 2>&1
    echo ""
    
    if [[ "$answer" == *"$correct"* ]] || [[ "$correct" == *"$answer"* ]]; then
        ((SCORE++))
        echo -e "${GREEN}✓ CORECT (sau aproape)!${NC}"
    else
        echo -e "${RED}✗ Răspunsul așteptat conținea: $correct${NC}"
    fi
    
    echo -e "${BLUE}Explicație:${NC} $explanation\n"
    
    read -p "Apasă Enter pentru a continua..."
    clear_screen
    show_header
    show_progress
}

#
# QUIZ QUESTIONS
#

run_quiz() {
    clear_screen
    show_header
    
    echo -e "${WHITE}Acest quiz testează cunoștințele despre Shell Bash.${NC}"
    echo -e "${WHITE}Răspunde la întrebări pentru a-ți evalua înțelegerea.${NC}\n"
    read -p "Apasă Enter pentru a începe..."
    
    clear_screen
    show_header
    show_progress
    
    # Q1: Ce este shell-ul?
    ask_question \
        "Care este rolul principal al shell-ului în Linux?" \
        "Gestionează hardware-ul direct" \
        "Interpretează comenzi și le transmite kernel-ului" \
        "Stochează fișierele utilizatorului" \
        "Afișează interfața grafică" \
        "B" \
        "Shell-ul este un INTERPRET de comenzi - primește comenzi text de la utilizator și le transmite kernel-ului pentru execuție."
    
    # Q2: pwd
    ask_question \
        "Ce afișează comanda 'pwd'?" \
        "Lista de procese active" \
        "Password-ul utilizatorului" \
        "Directorul curent de lucru" \
        "Utilizatorul curent" \
        "C" \
        "pwd = Print Working Directory. Afișează calea completă a directorului în care te afli."
    
    # Q3: cd ~
    ask_question \
        "Unde te duce comanda 'cd ~'?" \
        "În directorul rădăcină (/)" \
        "În directorul home al utilizatorului" \
        "În directorul anterior" \
        "În directorul părinte" \
        "B" \
        "Tilda (~) este o scurtătură pentru directorul HOME al utilizatorului curent (\$HOME)."
    
    # Q4: Variabile - spații
    ask_question \
        "Care dintre următoarele este CORECTĂ pentru setarea unei variabile?" \
        "NUME = \"Ion\"" \
        "NUME=\"Ion\"" \
        "\$NUME=\"Ion\"" \
        "set NUME \"Ion\"" \
        "B" \
        "În Bash, atribuirea variabilelor NU permite spații în jurul semnului =. NUME=\"Ion\" este singura formă corectă."
    
    # Q5: Single vs Double quotes
    ask_question \
        "Care este diferența dintre 'single quotes' și \"double quotes\" în Bash?" \
        "Nu există nicio diferență" \
        "Single quotes permit expansiunea variabilelor, double quotes nu" \
        "Double quotes permit expansiunea variabilelor, single quotes nu" \
        "Single quotes sunt pentru numere, double quotes pentru text" \
        "C" \
        "În double quotes (\"\"), variabilele se expandează (\$VAR devine valoarea). În single quotes (''), totul rămâne literal."
    
    # Q6: Predicție - variabile
    TEMP_VAR="test"
    export TEMP_VAR
    ask_prediction \
        "Ce va afișa următorul cod?" \
        "MESAJ=\"Salut\"; echo '\$MESAJ lume'" \
        "\$MESAJ" \
        "Single quotes păstrează totul literal - \$MESAJ nu se expandează."
    
    # Q7: Exit code
    ask_question \
        "Ce semnifică exit code-ul 0 în Linux?" \
        "Eroare fatală" \
        "Comandă inexistentă" \
        "Succes (comanda s-a executat corect)" \
        "Permisiuni insuficiente" \
        "C" \
        "În convenția Unix/Linux, exit code 0 = succes, orice non-zero = eroare."
    
    # Q8: Predicție - globbing
    ask_prediction \
        "Dacă avem fișierele: file1.txt, file2.txt, file10.txt\nCe returnează ls file?.txt?" \
        "cd /tmp && touch file1.txt file2.txt file10.txt 2>/dev/null; ls file?.txt 2>/dev/null; rm -f file*.txt" \
        "file1.txt file2.txt" \
        "? potrivește EXACT un caracter. file10.txt are DOUĂ caractere (1 și 0) după 'file', deci nu se potrivește."
    
    # Q9: export
    ask_question \
        "Ce face comanda 'export VARIABILA'?" \
        "Șterge variabila" \
        "Face variabila accesibilă în subprocese (procese copil)" \
        "Salvează variabila pe disk permanent" \
        "Trimite variabila la alt calculator" \
        "B" \
        "export face variabila parte din MEDIUL (environment) - va fi moștenită de toate procesele copil."
    
    # Q10: .bashrc
    ask_question \
        "Când se execută fișierul ~/.bashrc?" \
        "La pornirea calculatorului" \
        "La fiecare comandă" \
        "La deschiderea unui terminal nou (shell interactiv non-login)" \
        "Niciodată automat, doar manual" \
        "C" \
        "~/.bashrc se execută la fiecare terminal nou. După modificare, trebuie să rulezi 'source ~/.bashrc' pentru aplicare imediată."
    
    # Q11: rm -rf
    ask_question \
        "De ce este comanda 'rm -rf' considerată periculoasă?" \
        "Este foarte lentă" \
        "Șterge recursiv și forțat, fără confirmare și fără posibilitate de recuperare" \
        "Necesită permisiuni de root" \
        "Nu funcționează pe toate sistemele" \
        "B" \
        "rm -rf șterge tot recursiv (-r) și forțat (-f) fără a cere confirmare. NU există Recycle Bin în Linux!"
    
    # Q12: Predicție - PATH
    ask_prediction \
        "Ce afișează comanda 'which ls'?" \
        "which ls" \
        "/usr/bin/ls" \
        "'which' arată calea completă către executabil. ls se găsește de obicei în /usr/bin/ls sau /bin/ls."
    
    # Rezultat final
    clear_screen
    show_header
    
    local percentage=$((SCORE * 100 / TOTAL))
    
    echo -e "${WHITE}${BOLD}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}${BOLD}                      REZULTAT FINAL${NC}"
    echo -e "${WHITE}${BOLD}═══════════════════════════════════════════════════════════════${NC}\n"
    
    echo -e "Scor: ${CYAN}$SCORE / $TOTAL${NC} ($percentage%)\n"
    
    if [ $percentage -ge 90 ]; then
        echo -e "${GREEN}${BOLD}EXCELENT!${NC} Stăpânești foarte bine conceptele de bază ale shell-ului!"
    elif [ $percentage -ge 70 ]; then
        echo -e "${GREEN}BINE!${NC} Ai o înțelegere solidă, dar mai repetă câteva concepte."
    elif [ $percentage -ge 50 ]; then
        echo -e "${YELLOW}SATISFĂCĂTOR.${NC} Recitește materialul și exersează mai mult."
    else
        echo -e "${RED}NECESITĂ ÎMBUNĂTĂȚIRE.${NC} Te rog să revii asupra materialului de curs."
    fi
    
    echo -e "\n${BLUE}Întrebări la care ai greșit:${NC}"
    echo -e "Revizuiește secțiunile corespunzătoare din material.\n"
    
    echo -e "${WHITE}Mulțumesc pentru participare!${NC}\n"
}

#
# MAIN
#

run_quiz
