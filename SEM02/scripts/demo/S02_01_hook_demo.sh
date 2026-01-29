#!/bin/bash
#
# S02_01_hook_demo.sh - Hook Spectaculos de Deschidere pentru Seminarul 3-4
#
# 
# DESCRIERE:
#   Demonstrație vizuală spectaculoasă care arată puterea pipeline-urilor
#   și combinării comenzilor în Bash. Folosit pentru a capta atenția
#   studenților la începutul seminarului.
#
# DEPENDENȚE (opționale):
#   - figlet: pentru text ASCII mare
#   - lolcat: pentru culori rainbow
#   - pv: pentru progress bar
#   Dacă lipsesc, scriptul folosește fallback-uri text simple.
#
# UTILIZARE:
#   chmod +x S02_01_hook_demo.sh
#   ./S02_01_hook_demo.sh
#
# DURATA: ~2-3 minute
#
# AUTOR: Materiale SO ASE-CSIE
# VERSIUNE: 1.0
#

#
# CONFIGURARE
#

# Mod simplu (fără efecte vizuale) - setează SIMPLE_MODE=1 pentru a dezactiva
SIMPLE_MODE=${SIMPLE_MODE:-0}

# Culori ANSI
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color
BOLD='\033[1m'

#
# FUNCȚII HELPER
#

# Verifică dacă o comandă există
cmd_exists() {
    command -v "$1" &>/dev/null
}

# Print cu culoare
cprint() {
    local color=$1
    shift
    echo -e "${color}$*${NC}"
}

# Pauză dramatică
pause() {
    sleep "${1:-1}"
}

# Banner cu figlet sau fallback
banner() {
    local text="$1"
    if [[ $SIMPLE_MODE -eq 0 ]] && cmd_exists figlet; then
        if cmd_exists lolcat; then
            figlet -c "$text" | lolcat
        else
            figlet -c "$text"
        fi
    else
        echo ""
        cprint "$CYAN" "════════════════════════════════════════"
        cprint "$WHITE" "         $text"
        cprint "$CYAN" "════════════════════════════════════════"
        echo ""
    fi
}

# Typing effect pentru demo
type_cmd() {
    local cmd="$1"
    cprint "$GREEN" "$ $cmd"
    pause 0.5
}

#
# PARTEA 1: INTRO
#

intro() {
    clear
    
    banner "BASH PIPES"
    
    pause 1
    
    cprint "$YELLOW" "╔══════════════════════════════════════════════════════════════════╗"
    cprint "$YELLOW" "║  🐧 Seminar 2: Operatori, Redirecționare, Filtre, Bucle       ║"
    cprint "$YELLOW" "║                                                                  ║"
    cprint "$YELLOW" "║  Astăzi vom învăța să combinăm comenzi ca un profesionist!      ║"
    cprint "$YELLOW" "╚══════════════════════════════════════════════════════════════════╝"
    
    pause 2
}

#
# PARTEA 2: DEMO PIPELINE POWER
#

demo_pipeline_power() {
    clear
    
    cprint "$CYAN" ""
    cprint "$CYAN" ">>> DEMO 1: PUTEREA PIPELINE-URILOR <<<"
    cprint "$CYAN" ""
    
    pause 1
    
    cprint "$WHITE" "Provocare: Găsește cele mai mari 5 fișiere din /usr"
    cprint "$WHITE" "           ...într-o singură linie de comandă!"
    
    pause 2
    
    cprint "$YELLOW" ""
    cprint "$YELLOW" "Pipeline-ul magic:"
    cprint "$GREEN" '$ find /usr -type f -printf "%s %p\n" 2>/dev/null | sort -rn | head -5'
    
    pause 2
    
    cprint "$CYAN" ""
    cprint "$CYAN" "Rezultat:"
    cprint "$CYAN" "─────────────────────────────────────────────────────────────────"
    
    # Execută pipeline-ul real
    find /usr -type f -printf '%s %p\n' 2>/dev/null | \
        sort -rn | \
        head -5 | \
        while read size path; do
            # Formatare frumoasă cu numere mari
            if [ "$size" -gt 1073741824 ]; then
                human=$(echo "scale=2; $size/1073741824" | bc)
                unit="GB"
            elif [ "$size" -gt 1048576 ]; then
                human=$(echo "scale=2; $size/1048576" | bc)
                unit="MB"
            elif [ "$size" -gt 1024 ]; then
                human=$(echo "scale=2; $size/1024" | bc)
                unit="KB"
            else
                human=$size
                unit="B"
            fi
            printf "${GREEN}%10s ${WHITE}%s${NC} → %s\n" "${human}${unit}" " " "$path"
            sleep 0.3
        done
    
    cprint "$CYAN" "─────────────────────────────────────────────────────────────────"
    
    pause 1
    
    cprint "$MAGENTA" ""
    cprint "$MAGENTA" "✓ 4 comenzi combinate:"
    cprint "$WHITE" "  find    → caută fișiere și afișează dimensiunea"
    cprint "$WHITE" "  sort    → sortează numeric descrescător"
    cprint "$WHITE" "  head    → ia doar primele 5"
    cprint "$WHITE" "  while   → formatează output-ul"
    
    pause 3
}

#
# PARTEA 3: DEMO OPERATORI CONDIȚIONALI
#

demo_conditional() {
    clear
    
    cprint "$CYAN" ""
    cprint "$CYAN" ">>> DEMO 2: OPERATORI CONDIȚIONALI <<<"
    cprint "$CYAN" ""
    
    pause 1
    
    cprint "$WHITE" "Scenariu: Vrem să creăm un director și să intrăm în el"
    cprint "$WHITE" "          ...dar DOAR dacă crearea reușește!"
    
    pause 2
    
    # Cleanup
    rm -rf /tmp/demo_test_dir 2>/dev/null
    
    cprint "$YELLOW" ""
    cprint "$YELLOW" "Metoda GREȘITĂ (cu ;):"
    type_cmd 'mkdir /root/nu_am_permisiuni ; cd /root/nu_am_permisiuni ; echo "Sunt în director!"'
    
    cprint "$RED" ""
    mkdir /root/nu_am_permisiuni 2>&1 | head -1
    # cd va eșua dar echo se execută oricum
    cprint "$GREEN" 'Sunt în director!'
    cprint "$RED" "↑ GREȘIT! Echo s-a executat deși mkdir a eșuat!"
    
    pause 3
    
    cprint "$YELLOW" ""
    cprint "$YELLOW" "Metoda CORECTĂ (cu &&):"
    type_cmd 'mkdir /tmp/demo_test && cd /tmp/demo_test && echo "Sunt în director!"'
    
    cprint "$GREEN" ""
    if mkdir /tmp/demo_test_dir 2>/dev/null && cd /tmp/demo_test_dir; then
        pwd
        cprint "$GREEN" "✓ Funcționează perfect!"
    fi
    
    pause 2
    
    cprint "$YELLOW" ""
    cprint "$YELLOW" "Cu fallback (&&...||):"
    type_cmd 'mkdir /root/test && echo "Creat!" || echo "Eroare la creare!"'
    
    cprint "$GREEN" ""
    mkdir /root/test 2>/dev/null && echo "Creat!" || cprint "$RED" "Eroare la creare!"
    
    pause 3
    
    # Cleanup
    cd ~
    rm -rf /tmp/demo_test_dir 2>/dev/null
}

#
# PARTEA 4: DEMO FILTRE
#

demo_filters() {
    clear
    
    cprint "$CYAN" ""
    cprint "$CYAN" ">>> DEMO 3: FILTRE DE TEXT <<<"
    cprint "$CYAN" ""
    
    pause 1
    
    cprint "$WHITE" "Provocare: Analizează procesele și găsește top 5 useri"
    cprint "$WHITE" "          după numărul de procese rulate."
    
    pause 2
    
    cprint "$YELLOW" ""
    cprint "$YELLOW" "Pipeline-ul:"
    cprint "$GREEN" '$ ps aux | awk "{print \$1}" | sort | uniq -c | sort -rn | head -6'
    
    pause 2
    
    cprint "$CYAN" ""
    cprint "$CYAN" "Construim pas cu pas:"
    cprint "$CYAN" "─────────────────────────────────────────────────────────────────"
    
    cprint "$WHITE" "1. ps aux (listează toate procesele):"
    ps aux | head -3
    cprint "$YELLOW" "   ... (multe linii)"
    pause 1
    
    cprint "$WHITE" ""
    cprint "$WHITE" "2. awk '{print \$1}' (extrage doar username):"
    ps aux | awk '{print $1}' | head -5
    pause 1
    
    cprint "$WHITE" ""
    cprint "$WHITE" "3. sort (sortează pentru uniq):"
    cprint "$YELLOW" "   (necesar pentru că uniq elimină doar CONSECUTIVE!)"
    pause 1
    
    cprint "$WHITE" ""
    cprint "$WHITE" "4. uniq -c (numără aparițiile):"
    ps aux | awk '{print $1}' | sort | uniq -c | head -5
    pause 1
    
    cprint "$WHITE" ""
    cprint "$WHITE" "5. sort -rn | head -6 (sortare descrescătoare, top 6):"
    cprint "$CYAN" "─────────────────────────────────────────────────────────────────"
    ps aux | awk '{print $1}' | sort | uniq -c | sort -rn | head -6
    cprint "$CYAN" "─────────────────────────────────────────────────────────────────"
    
    pause 3
}

#
# PARTEA 5: COUNTDOWN (dacă avem figlet)
#

demo_countdown() {
    if [[ $SIMPLE_MODE -eq 0 ]] && cmd_exists figlet; then
        clear
        
        cprint "$CYAN" ""
        cprint "$CYAN" ">>> DEMO 4: BUCLE ÎN ACȚIUNE <<<"
        cprint "$CYAN" ""
        
        pause 1
        
        cprint "$WHITE" "Cod simplu, efect impresionant:"
        cprint "$GREEN" 'for i in {5..1}; do clear; figlet $i; sleep 1; done; figlet "GO!"'
        
        pause 2
        
        for i in {5..1}; do
            clear
            if cmd_exists lolcat; then
                figlet -c "$i" | lolcat
            else
                cprint "$CYAN" ""
                figlet -c "$i"
            fi
            sleep 0.7
        done
        
        clear
        if cmd_exists lolcat; then
            figlet -c "GO!" | lolcat
        else
            cprint "$GREEN" ""
            figlet -c "GO!"
        fi
        
        pause 2
    fi
}

#
# PARTEA 6: FINAL
#

finale() {
    clear
    
    banner "READY?"
    
    cprint "$YELLOW" ""
    cprint "$YELLOW" "╔══════════════════════════════════════════════════════════════════╗"
    cprint "$YELLOW" "║                                                                  ║"
    cprint "$YELLOW" "║   Astăzi vom învăța:                                            ║"
    cprint "$YELLOW" "║                                                                  ║"
    cprint "$WHITE"  "║   ✓ Operatori de control:  ;  &&  ||  &  |                      ║"
    cprint "$WHITE"  "║   ✓ Redirecționare I/O:    >  >>  <  <<  2>&1                   ║"
    cprint "$WHITE"  "║   ✓ Filtre de text:        sort uniq cut tr wc head tail       ║"
    cprint "$WHITE"  "║   ✓ Bucle:                 for while until break continue      ║"
    cprint "$YELLOW" "║                                                                  ║"
    cprint "$YELLOW" "╚══════════════════════════════════════════════════════════════════╝"
    cprint "$YELLOW" ""
    
    pause 2
    
    cprint "$GREEN" ""
    cprint "$GREEN" "Să începem! 🚀"
    cprint "$GREEN" ""
}

#
# MAIN
#

main() {
    # Verifică dependențe și avertizează dacă lipsesc
    echo "Verificare dependențe..."
    for cmd in figlet lolcat pv; do
        if cmd_exists "$cmd"; then
            echo "  ✓ $cmd găsit"
        else
            echo "  ✗ $cmd lipsește (opțional - se va folosi fallback)"
        fi
    done
    sleep 1
    
    # Rulează demo-urile
    intro
    demo_pipeline_power
    demo_conditional
    demo_filters
    demo_countdown
    finale
}

# Rulează doar dacă nu e sursat
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
