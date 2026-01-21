#!/bin/bash
#
# S03_02_quiz_interactiv.sh - Quiz Interactiv Seminar 5-6
# Sisteme de Operare | ASE București - CSIE
#
#
# DESCRIERE:
#   Quiz interactiv cu 25+ întrebări despre:
#   - find și xargs
#   - Parametri script și getopts
#   - Permisiuni Unix
#   - Cron și automatizare
#
# UTILIZARE:
#   ./S03_02_quiz_interactiv.sh [-h] [-n NUM] [-c CATEGORY] [-r]
#
# OPȚIUNI:
#   -h              Afișează help
#   -n NUM          Număr de întrebări (default: 10)
#   -c CATEGORY     Categorie: find, script, perm, cron, all (default: all)
#   -r              Ordine aleatorie
#   -p              Mod practică (afișează explicații)
#
# AUTOR: Echipa SO ASE
# VERSIUNE: 1.0
#

# Culori
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'
BOLD='\033[1m'

# Configurări default
NUM_QUESTIONS=10
CATEGORY="all"
RANDOM_ORDER=false
PRACTICE_MODE=false

# Statistici
CORRECT=0
WRONG=0
TOTAL=0

#
# FUNCȚII UTILITARE
#

usage() {
    cat << EOF
${BOLD}Quiz Interactiv - Seminar 5-6 SO${NC}

${BOLD}UTILIZARE:${NC}
    $0 [-h] [-n NUM] [-c CATEGORY] [-r] [-p]

${BOLD}OPȚIUNI:${NC}
    -h              Afișează acest help
    -n NUM          Număr de întrebări (default: 10, max: 25)
    -c CATEGORY     Categorie:
                      find   - Întrebări despre find și xargs
                      script - Întrebări despre parametri și getopts
                      perm   - Întrebări despre permisiuni
                      cron   - Întrebări despre cron
                      all    - Toate categoriile (default)
    -r              Ordine aleatorie a întrebărilor
    -p              Mod practică (afișează explicații după fiecare răspuns)

${BOLD}EXEMPLE:${NC}
    $0                     # 10 întrebări din toate categoriile
    $0 -n 5 -c find        # 5 întrebări doar despre find
    $0 -r -p               # Mod practică cu ordine aleatorie
    $0 -c perm -n 8        # 8 întrebări despre permisiuni

EOF
    exit 0
}

clear_screen() {
    printf '\033[2J\033[H'
}

print_header() {
    echo -e "\n${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}$1${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}\n"
}

print_question() {
    local num=$1
    local total=$2
    local category=$3
    local question=$4
    
    echo -e "${BLUE}┌─────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BLUE}│${NC} ${BOLD}Întrebarea $num/$total${NC} ${MAGENTA}[$category]${NC}"
    echo -e "${BLUE}├─────────────────────────────────────────────────────────────────┤${NC}"
    echo -e "${BLUE}│${NC}"
    # Word wrap pentru întrebare
    echo "$question" | fold -s -w 65 | while read -r line; do
        printf "${BLUE}│${NC} %s\n" "$line"
    done
    echo -e "${BLUE}│${NC}"
    echo -e "${BLUE}└─────────────────────────────────────────────────────────────────┘${NC}"
}

print_options() {
    local -n opts=$1
    echo ""
    for i in "${!opts[@]}"; do
        local letter=$(echo "$i" | tr '0123' 'ABCD')
        echo -e "  ${YELLOW}$letter)${NC} ${opts[$i]}"
    done
    echo ""
}

get_answer() {
    local valid_answers="$1"
    local answer
    
    while true; do
        echo -n -e "${CYAN}Răspunsul tău [${valid_answers}]: ${NC}"
        read -r answer
        answer=$(echo "$answer" | tr '[:lower:]' '[:upper:]')
        
        if [[ "$valid_answers" == *"$answer"* ]] && [ -n "$answer" ]; then
            echo "$answer"
            return
        else
            echo -e "${RED}Răspuns invalid. Alege din: $valid_answers${NC}"
        fi
    done
}

show_result() {
    local is_correct=$1
    local correct_answer=$2
    local explanation=$3
    
    echo ""
    if [ "$is_correct" = true ]; then
        echo -e "${GREEN}✓ CORECT!${NC}"
        ((CORRECT++))
    else
        echo -e "${RED}✗ GREȘIT!${NC} Răspunsul corect era: ${YELLOW}$correct_answer${NC}"
        ((WRONG++))
    fi
    
    if [ "$PRACTICE_MODE" = true ] && [ -n "$explanation" ]; then
        echo ""
        echo -e "${CYAN}📝 Explicație:${NC}"
        echo "$explanation" | fold -s -w 65 | while read -r line; do
            echo "   $line"
        done
    fi
    
    echo ""
    echo -e "${BLUE}─────────────────────────────────────────────────────────────────${NC}"
    read -p "Apasă Enter pentru a continua..."
}

#
# BAZA DE DATE ÎNTREBĂRI - FIND
#

declare -a QUESTIONS_FIND
declare -a OPTIONS_FIND
declare -a ANSWERS_FIND
declare -a EXPLANATIONS_FIND

# Q1
QUESTIONS_FIND+=("Ce face opțiunea -type f în comanda find?")
OPTIONS_FIND+=("A:Caută fișiere care încep cu 'f'|B:Caută doar fișiere regulate|C:Caută în format full|D:Filtrează rezultatele")
ANSWERS_FIND+=("B")
EXPLANATIONS_FIND+=("-type f caută doar fișiere regulate (regular files), excluzând directoare (-type d), link-uri (-type l), etc.")

# Q2
QUESTIONS_FIND+=("Care este diferența principală între find și locate?")
OPTIONS_FIND+=("A:find este mai rapid|B:locate caută live în filesystem|C:locate folosește o bază de date pre-indexată|D:Nu există diferență")
ANSWERS_FIND+=("C")
EXPLANATIONS_FIND+=("locate caută într-o bază de date pre-indexată (rapidă dar poate fi outdated), pe când find scanează filesystem-ul în timp real (mai lent dar mereu actual).")

# Q3
QUESTIONS_FIND+=("Ce înseamnă -mtime -7 în find?")
OPTIONS_FIND+=("A:Fișiere modificate exact acum 7 zile|B:Fișiere modificate în ultimele 7 zile|C:Fișiere mai vechi de 7 zile|D:Fișiere modificate la ora 7")
ANSWERS_FIND+=("B")
EXPLANATIONS_FIND+=("-mtime -7 înseamnă 'modification time mai mic de 7 zile', adică modificate în ultimele 7 zile. +7 ar însemna mai vechi de 7 zile.")

# Q4
QUESTIONS_FIND+=("Care este diferența între -exec {} \\; și -exec {} +?")
OPTIONS_FIND+=("A:Nu există diferență|B:\\; e pentru Windows, + pentru Linux|C:\\; execută o dată per fișier, + execută în batch|D:\\; e mai rapid")
ANSWERS_FIND+=("C")
EXPLANATIONS_FIND+=("\\; execută comanda separat pentru fiecare fișier găsit (mai lent). + colectează toate fișierele și le trimite ca argumente într-o singură execuție (mai eficient).")

# Q5
QUESTIONS_FIND+=("De ce este important să folosim ghilimele în find -name \"*.txt\"?")
OPTIONS_FIND+=("A:Pentru stilul codului|B:Pentru a preveni expansiunea glob de către shell|C:Pentru case sensitivity|D:Nu este important")
ANSWERS_FIND+=("B")
EXPLANATIONS_FIND+=("Fără ghilimele, shell-ul ar expanda *.txt ÎNAINTE de find, transformându-l în lista de fișiere din directorul curent care se potrivesc.")

# Q6
QUESTIONS_FIND+=("Ce problemă rezolvă combinația find -print0 | xargs -0?")
OPTIONS_FIND+=("A:Fișiere cu spații în nume|B:Fișiere foarte mari|C:Lipsa permisiunilor|D:Fișiere ascunse")
ANSWERS_FIND+=("A")
EXPLANATIONS_FIND+=("-print0 folosește null character ca separator, iar xargs -0 îl interpretează corect. Aceasta rezolvă problema fișierelor cu spații sau caractere speciale în nume.")

# Q7
QUESTIONS_FIND+=("Ce face comanda: find . -size +10M -size -100M?")
OPTIONS_FIND+=("A:Fișiere de exact 10MB sau 100MB|B:Fișiere între 10MB și 100MB|C:Fișiere mai mici de 10MB sau mai mari de 100MB|D:Eroare de sintaxă")
ANSWERS_FIND+=("B")
EXPLANATIONS_FIND+=("Condițiile în find sunt implicit AND. +10M înseamnă mai mare de 10MB, -100M înseamnă mai mic de 100MB, combinat = interval.")

#
# BAZA DE DATE ÎNTREBĂRI - SCRIPT
#

declare -a QUESTIONS_SCRIPT
declare -a OPTIONS_SCRIPT
declare -a ANSWERS_SCRIPT
declare -a EXPLANATIONS_SCRIPT

# Q1
QUESTIONS_SCRIPT+=("Care este diferența dintre \"\$@\" și \"\$*\" într-un script?")
OPTIONS_SCRIPT+=("A:Nu există diferență|B:\$@ păstrează argumentele separate, \$* le concatenează|C:\$@ e pentru numere, \$* pentru text|D:\$* e deprecated")
ANSWERS_SCRIPT+=("B")
EXPLANATIONS_SCRIPT+=("Cu ghilimele: \"\$@\" tratează fiecare argument separat (ideal pentru bucle), \"\$*\" concatenează toate argumentele într-un singur string.")

# Q2
QUESTIONS_SCRIPT+=("Ce afișează \$# într-un script bash?")
OPTIONS_SCRIPT+=("A:Numărul de argumente|B:Ultimul argument|C:PID-ul procesului|D:Exit status")
ANSWERS_SCRIPT+=("A")
EXPLANATIONS_SCRIPT+=("\$# returnează numărul de argumente poziționale transmise scriptului, fără a include \$0 (numele scriptului).")

# Q3
QUESTIONS_SCRIPT+=("Ce face comanda shift într-un script?")
OPTIONS_SCRIPT+=("A:Mută cursorul|B:Elimină primul argument și mută restul în sus|C:Sortează argumentele|D:Schimbă majuscule/minuscule")
ANSWERS_SCRIPT+=("B")
EXPLANATIONS_SCRIPT+=("shift elimină \$1, apoi \$2 devine \$1, \$3 devine \$2, etc. și decrementează \$#. shift N elimină primele N argumente.")

# Q4
QUESTIONS_SCRIPT+=("În getopts \"a:b:c\", ce semnifică caracterul ':'?")
OPTIONS_SCRIPT+=("A:Opțiunea este obligatorie|B:Opțiunea necesită un argument|C:Opțiunea este deprecată|D:Separator între opțiuni")
ANSWERS_SCRIPT+=("B")
EXPLANATIONS_SCRIPT+=("Două puncte după o literă (ex: a:) indică că opțiunea -a necesită un argument (stocat în OPTARG). 'c' fără : nu necesită argument.")

# Q5
QUESTIONS_SCRIPT+=("Ce conține variabila OPTARG în getopts?")
OPTIONS_SCRIPT+=("A:Numărul de opțiuni|B:Argumentul opțiunii curente|C:Toate argumentele|D:Eroarea curentă")
ANSWERS_SCRIPT+=("B")
EXPLANATIONS_SCRIPT+=("OPTARG conține valoarea argumentului pentru opțiunea curentă care necesită argument (cele marcate cu : în optstring).")

# Q6
QUESTIONS_SCRIPT+=("Ce face \${VAR:-default}?")
OPTIONS_SCRIPT+=("A:Setează VAR la 'default'|B:Returnează 'default' dacă VAR e gol, fără a modifica VAR|C:Șterge VAR|D:Compară VAR cu 'default'")
ANSWERS_SCRIPT+=("B")
EXPLANATIONS_SCRIPT+=("\${VAR:-default} returnează valoarea lui VAR dacă e setată și non-vidă, altfel returnează 'default', fără a modifica VAR. \${VAR:=default} ar seta VAR.")

# Q7
QUESTIONS_SCRIPT+=("De ce e important shift \$((OPTIND-1)) după getopts?")
OPTIONS_SCRIPT+=("A:Pentru a reseta getopts|B:Pentru a elimina opțiunile procesate și a păstra argumentele non-opțiune|C:Pentru performanță|D:E opțional")
ANSWERS_SCRIPT+=("B")
EXPLANATIONS_SCRIPT+=("OPTIND conține indexul următorului argument de procesat. După getopts, shift \$((OPTIND-1)) elimină toate opțiunile, lăsând doar argumentele poziționale.")

#
# BAZA DE DATE ÎNTREBĂRI - PERMISIUNI
#

declare -a QUESTIONS_PERM
declare -a OPTIONS_PERM
declare -a ANSWERS_PERM
declare -a EXPLANATIONS_PERM

# Q1
QUESTIONS_PERM+=("Ce înseamnă permisiunea 'x' pe un DIRECTOR?")
OPTIONS_PERM+=("A:Poți executa fișierele din el|B:Poți lista conținutul|C:Poți accesa (cd) în director|D:Poți șterge directorul")
ANSWERS_PERM+=("C")
EXPLANATIONS_PERM+=("Pe un director, x (execute) înseamnă poți ACCESA (cd în) directorul. r permite listarea, w permite crearea/ștergerea fișierelor. x pe director ≠ executare!")

# Q2
QUESTIONS_PERM+=("Calculează permisiunile octal pentru rwxr-x---")
OPTIONS_PERM+=("A:754|B:750|C:740|D:755")
ANSWERS_PERM+=("B")
EXPLANATIONS_PERM+=("rwx = 4+2+1 = 7, r-x = 4+0+1 = 5, --- = 0. Rezultat: 750")

# Q3
QUESTIONS_PERM+=("Cu umask 027, ce permisiuni vor avea fișierele noi?")
OPTIONS_PERM+=("A:777|B:750|C:640|D:660")
ANSWERS_PERM+=("C")
EXPLANATIONS_PERM+=("Default pentru fișiere este 666. umask 027 elimină 0 din owner, 2 din group, 7 din others. 666 - 027 = 640 (rw-r-----).")

# Q4
QUESTIONS_PERM+=("Ce face bitul SUID (Set User ID) pe un fișier executabil?")
OPTIONS_PERM+=("A:Fișierul devine read-only|B:Fișierul rulează cu permisiunile owner-ului|C:Fișierul poate fi șters de oricine|D:Fișierul este ascuns")
ANSWERS_PERM+=("B")
EXPLANATIONS_PERM+=("SUID face ca executabilul să ruleze cu permisiunile owner-ului, nu ale celui care îl execută. Exemplu: /usr/bin/passwd rulează ca root.")

# Q5
QUESTIONS_PERM+=("De ce chmod 777 este considerat periculos?")
OPTIONS_PERM+=("A:Consumă mult spațiu|B:Oferă acces total tuturor, compromițând securitatea|C:Șterge fișierul|D:Este lent")
ANSWERS_PERM+=("B")
EXPLANATIONS_PERM+=("777 (rwxrwxrwx) permite oricui să citească, scrie și execute fișierul. Pe un server, aceasta este o vulnerabilitate majoră de securitate.")

# Q6
QUESTIONS_PERM+=("Ce face SGID (Set Group ID) pe un DIRECTOR?")
OPTIONS_PERM+=("A:Directorul devine read-only|B:Fișierele noi moștenesc grupul directorului|C:Nimeni nu poate intra în director|D:Directorul se șterge automat")
ANSWERS_PERM+=("B")
EXPLANATIONS_PERM+=("SGID pe director face ca toate fișierele create în el să moștenească grupul directorului, nu grupul primar al utilizatorului. Ideal pentru directoare partajate.")

# Q7
QUESTIONS_PERM+=("Sticky bit pe /tmp face ca:")
OPTIONS_PERM+=("A:Fișierele să persiste după reboot|B:Doar owner-ul să poată șterge propriile fișiere|C:Fișierele să fie comprimate|D:Directorul să fie ascuns")
ANSWERS_PERM+=("B")
EXPLANATIONS_PERM+=("Sticky bit pe un director (t în poziția others x) permite doar owner-ului fișierului (sau root) să-l șteargă, chiar dacă directorul e world-writable.")

# Q8
QUESTIONS_PERM+=("Pentru a șterge un fișier, ai nevoie de permisiune pe:")
OPTIONS_PERM+=("A:Fișier (w)|B:Director părinte (w)|C:Ambele|D:Niciunul dacă ești owner")
ANSWERS_PERM+=("B")
EXPLANATIONS_PERM+=("Ștergerea unui fișier modifică directory entry, nu fișierul în sine. Ai nevoie de w pe directorul părinte, permisiunile fișierului nu contează pentru ștergere.")

#
# BAZA DE DATE ÎNTREBĂRI - CRON
#

declare -a QUESTIONS_CRON
declare -a OPTIONS_CRON
declare -a ANSWERS_CRON
declare -a EXPLANATIONS_CRON

# Q1
QUESTIONS_CRON+=("Care este ordinea celor 5 câmpuri în crontab?")
OPTIONS_CRON+=("A:hour min day month dow|B:min hour day month dow|C:min hour month day dow|D:day month year hour min")
ANSWERS_CRON+=("B")
EXPLANATIONS_CRON+=("Ordinea este: minute (0-59), hour (0-23), day of month (1-31), month (1-12), day of week (0-7). Mnemonică: Min Hour Day Month Weekday.")

# Q2
QUESTIONS_CRON+=("Ce înseamnă expresia cron: */15 * * * *?")
OPTIONS_CRON+=("A:La minutul 15 al fiecărei ore|B:La fiecare 15 minute|C:La ora 15|D:15 ori pe zi")
ANSWERS_CRON+=("B")
EXPLANATIONS_CRON+=("*/15 în câmpul minute înseamnă 'la fiecare 15 minute' - va rula la 0, 15, 30, 45 ale fiecărei ore.")

# Q3
QUESTIONS_CRON+=("De ce ar putea eșua un cron job care funcționează manual?")
OPTIONS_CRON+=("A:Cron are un mediu diferit (PATH limitat)|B:Cron rulează doar noaptea|C:Cron necesită sudo|D:Cron nu suportă bash")
ANSWERS_CRON+=("A")
EXPLANATIONS_CRON+=("Cron rulează cu un mediu minimal, fără PATH-ul complet. Soluții: folosește căi absolute, setează PATH în crontab, sau folosește scriptul cu path complet.")

# Q4
QUESTIONS_CRON+=("Ce face >> /var/log/cron.log 2>&1 într-un cron job?")
OPTIONS_CRON+=("A:Șterge log-ul|B:Redirecționează stdout și stderr în fișier (append)|C:Trimite email|D:Oprește job-ul")
ANSWERS_CRON+=("B")
EXPLANATIONS_CRON+=(">> face append la fișier (nu suprascrie), 2>&1 redirecționează stderr (2) către stdout (1), astfel încât ambele ajung în fișierul log.")

# Q5
QUESTIONS_CRON+=("Ce face crontab -r?")
OPTIONS_CRON+=("A:Reîncarcă crontab|B:Resetează la default|C:ȘTERGE tot crontab-ul fără confirmare|D:Repornește cron")
ANSWERS_CRON+=("C")
EXPLANATIONS_CRON+=("Capcană: crontab -r șterge ÎNTREGUL crontab fără confirmare! Confuzia cu -e (edit) poate fi catastrofală. Backup: crontab -l > backup.cron")

# Q6
QUESTIONS_CRON+=("Ce înseamnă @reboot în crontab?")
OPTIONS_CRON+=("A:Repornește sistemul|B:Rulează la fiecare repornire a sistemului|C:Rulează o dată pe zi|D:Este invalid")
ANSWERS_CRON+=("B")
EXPLANATIONS_CRON+=("@reboot este un string special care face ca job-ul să ruleze o singură dată, la pornirea sistemului. Util pentru scripturi de inițializare.")

# Q7
QUESTIONS_CRON+=("Cum previi execuții simultane ale unui cron job lung?")
OPTIONS_CRON+=("A:Nu se poate|B:Folosind flock pentru lock file|C:Setând nice|D:Folosind sleep")
ANSWERS_CRON+=("B")
EXPLANATIONS_CRON+=("flock -n /tmp/myjob.lock command asigură că doar o instanță rulează. -n = non-blocking (eșuează dacă lock-ul e ocupat). Alternativ: implementezi lock file manual în script.")

#
# FUNCȚIA PRINCIPALĂ DE QUIZ
#

run_quiz() {
    local -a selected_questions
    local -a selected_options
    local -a selected_answers
    local -a selected_explanations
    local -a selected_categories
    
    # Colectează întrebările din categoriile selectate
    case "$CATEGORY" in
        find)
            for i in "${!QUESTIONS_FIND[@]}"; do
                selected_questions+=("${QUESTIONS_FIND[$i]}")
                selected_options+=("${OPTIONS_FIND[$i]}")
                selected_answers+=("${ANSWERS_FIND[$i]}")
                selected_explanations+=("${EXPLANATIONS_FIND[$i]}")
                selected_categories+=("FIND")
            done
            ;;
        script)
            for i in "${!QUESTIONS_SCRIPT[@]}"; do
                selected_questions+=("${QUESTIONS_SCRIPT[$i]}")
                selected_options+=("${OPTIONS_SCRIPT[$i]}")
                selected_answers+=("${ANSWERS_SCRIPT[$i]}")
                selected_explanations+=("${EXPLANATIONS_SCRIPT[$i]}")
                selected_categories+=("SCRIPT")
            done
            ;;
        perm)
            for i in "${!QUESTIONS_PERM[@]}"; do
                selected_questions+=("${QUESTIONS_PERM[$i]}")
                selected_options+=("${OPTIONS_PERM[$i]}")
                selected_answers+=("${ANSWERS_PERM[$i]}")
                selected_explanations+=("${EXPLANATIONS_PERM[$i]}")
                selected_categories+=("PERMISIUNI")
            done
            ;;
        cron)
            for i in "${!QUESTIONS_CRON[@]}"; do
                selected_questions+=("${QUESTIONS_CRON[$i]}")
                selected_options+=("${OPTIONS_CRON[$i]}")
                selected_answers+=("${ANSWERS_CRON[$i]}")
                selected_explanations+=("${EXPLANATIONS_CRON[$i]}")
                selected_categories+=("CRON")
            done
            ;;
        all|*)
            for i in "${!QUESTIONS_FIND[@]}"; do
                selected_questions+=("${QUESTIONS_FIND[$i]}")
                selected_options+=("${OPTIONS_FIND[$i]}")
                selected_answers+=("${ANSWERS_FIND[$i]}")
                selected_explanations+=("${EXPLANATIONS_FIND[$i]}")
                selected_categories+=("FIND")
            done
            for i in "${!QUESTIONS_SCRIPT[@]}"; do
                selected_questions+=("${QUESTIONS_SCRIPT[$i]}")
                selected_options+=("${OPTIONS_SCRIPT[$i]}")
                selected_answers+=("${ANSWERS_SCRIPT[$i]}")
                selected_explanations+=("${EXPLANATIONS_SCRIPT[$i]}")
                selected_categories+=("SCRIPT")
            done
            for i in "${!QUESTIONS_PERM[@]}"; do
                selected_questions+=("${QUESTIONS_PERM[$i]}")
                selected_options+=("${OPTIONS_PERM[$i]}")
                selected_answers+=("${ANSWERS_PERM[$i]}")
                selected_explanations+=("${EXPLANATIONS_PERM[$i]}")
                selected_categories+=("PERMISIUNI")
            done
            for i in "${!QUESTIONS_CRON[@]}"; do
                selected_questions+=("${QUESTIONS_CRON[$i]}")
                selected_options+=("${OPTIONS_CRON[$i]}")
                selected_answers+=("${ANSWERS_CRON[$i]}")
                selected_explanations+=("${EXPLANATIONS_CRON[$i]}")
                selected_categories+=("CRON")
            done
            ;;
    esac
    
    local total_available=${#selected_questions[@]}
    
    if [ $total_available -eq 0 ]; then
        echo -e "${RED}Eroare: Nu există întrebări pentru categoria selectată.${NC}"
        exit 1
    fi
    
    # Ajustează numărul de întrebări dacă e necesar
    if [ $NUM_QUESTIONS -gt $total_available ]; then
        NUM_QUESTIONS=$total_available
    fi
    
    # Creează array de indici
    local -a indices
    for i in $(seq 0 $((total_available - 1))); do
        indices+=($i)
    done
    
    # Amestecă dacă random
    if [ "$RANDOM_ORDER" = true ]; then
        for ((i = total_available - 1; i > 0; i--)); do
            j=$((RANDOM % (i + 1)))
            tmp=${indices[$i]}
            indices[$i]=${indices[$j]}
            indices[$j]=$tmp
        done
    fi
    
    # Afișează header
    clear_screen
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}       ${BOLD}🎓 QUIZ INTERACTIV - SEMINAR 5-6${NC}                       ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}       Sisteme de Operare | ASE București                     ${CYAN}║${NC}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC}  Întrebări: $NUM_QUESTIONS    Categorie: $CATEGORY"
    [ "$PRACTICE_MODE" = true ] && echo -e "${CYAN}║${NC}  Mod: PRACTICĂ (cu explicații)"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    read -p "Apasă Enter pentru a începe..."
    
    # Rulează quiz-ul
    for ((q = 0; q < NUM_QUESTIONS; q++)); do
        clear_screen
        
        local idx=${indices[$q]}
        local question="${selected_questions[$idx]}"
        local options_str="${selected_options[$idx]}"
        local correct="${selected_answers[$idx]}"
        local explanation="${selected_explanations[$idx]}"
        local category="${selected_categories[$idx]}"
        
        # Parsează opțiunile
        local -a opts
        IFS='|' read -ra opt_array <<< "$options_str"
        for opt in "${opt_array[@]}"; do
            opts+=("${opt#*:}")
        done
        
        # Afișează întrebarea
        print_question $((q + 1)) $NUM_QUESTIONS "$category" "$question"
        print_options opts
        
        # Obține răspunsul
        local user_answer
        user_answer=$(get_answer "ABCD")
        
        # Verifică răspunsul
        ((TOTAL++))
        if [ "$user_answer" = "$correct" ]; then
            show_result true "$correct" "$explanation"
        else
            show_result false "$correct" "$explanation"
        fi
        
        unset opts
    done
    
    # Afișează rezultatele finale
    show_final_results
}

show_final_results() {
    clear_screen
    
    local percentage=$((CORRECT * 100 / TOTAL))
    local grade
    local grade_color
    
    if [ $percentage -ge 90 ]; then
        grade="EXCELENT! 🌟"
        grade_color=$GREEN
    elif [ $percentage -ge 70 ]; then
        grade="BINE! 👍"
        grade_color=$YELLOW
    elif [ $percentage -ge 50 ]; then
        grade="SUFICIENT 📚"
        grade_color=$YELLOW
    else
        grade="NECESITĂ STUDIU 📖"
        grade_color=$RED
    fi
    
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}                   ${BOLD}📊 REZULTATE FINALE${NC}                        ${CYAN}║${NC}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}     Total întrebări:    ${BOLD}$TOTAL${NC}"
    echo -e "${CYAN}║${NC}     Răspunsuri corecte: ${GREEN}$CORRECT${NC}"
    echo -e "${CYAN}║${NC}     Răspunsuri greșite: ${RED}$WRONG${NC}"
    echo -e "${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}     Scor:               ${BOLD}$percentage%${NC}"
    echo -e "${CYAN}║${NC}     Calificativ:        ${grade_color}$grade${NC}"
    echo -e "${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    
    echo ""
    
    if [ $percentage -lt 70 ]; then
        echo -e "${YELLOW}💡 Sugestii pentru îmbunătățire:${NC}"
        case "$CATEGORY" in
            find) echo "   - Revizuiește documentația: man find, man xargs" ;;
            script) echo "   - Practică scrierea de scripturi cu getopts" ;;
            perm) echo "   - Exersează calculul permisiunilor octal" ;;
            cron) echo "   - Verifică crontab.guru pentru expresii cron" ;;
            *) echo "   - Revizuiește materialul din Seminar 5-6" ;;
        esac
    fi
    
    echo ""
    read -p "Apasă Enter pentru a ieși..."
}

#
# MAIN
#

main() {
    # Parse argumente
    while getopts ":hn:c:rp" opt; do
        case $opt in
            h) usage ;;
            n) 
                if [[ "$OPTARG" =~ ^[0-9]+$ ]] && [ "$OPTARG" -ge 1 ] && [ "$OPTARG" -le 30 ]; then
                    NUM_QUESTIONS=$OPTARG
                else
                    echo -e "${RED}Eroare: -n trebuie să fie un număr între 1 și 30${NC}"
                    exit 1
                fi
                ;;
            c) 
                if [[ "$OPTARG" =~ ^(find|script|perm|cron|all)$ ]]; then
                    CATEGORY=$OPTARG
                else
                    echo -e "${RED}Eroare: Categorie invalidă. Opțiuni: find, script, perm, cron, all${NC}"
                    exit 1
                fi
                ;;
            r) RANDOM_ORDER=true ;;
            p) PRACTICE_MODE=true ;;
            \?) echo -e "${RED}Opțiune invalidă: -$OPTARG${NC}"; exit 1 ;;
            :) echo -e "${RED}Opțiunea -$OPTARG necesită argument${NC}"; exit 1 ;;
        esac
    done
    
    # Rulează quiz-ul
    run_quiz
}

main "$@"
