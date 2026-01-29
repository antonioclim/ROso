#!/bin/bash
#
#  S02_02_demo_pipes.sh
#  Demonstrație interactivă pentru construirea pipeline-urilor
#  Sisteme de Operare | ASE București - CSIE
#   Durată: 8-10 minute
#  Dependențe: bash 4.0+, opțional: figlet, lolcat, pv
#

set -o pipefail

#
# CONFIGURARE CULORI ȘI STILURI
#
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly BOLD='\033[1m'
readonly DIM='\033[2m'
readonly RESET='\033[0m'

readonly CHECKMARK="${GREEN}✓${RESET}"
readonly CROSS="${RED}✗${RESET}"
readonly ARROW="${CYAN}→${RESET}"
readonly PIPE_SYMBOL="${YELLOW}│${RESET}"

#
# FUNCȚII UTILITARE
#

print_header() {
    local title="$1"
    local width=70
    
    echo ""
    echo -e "${CYAN}╔$(printf '═%.0s' $(seq 1 $((width-2))))╗${RESET}"
    printf "${CYAN}║${RESET} ${BOLD}${WHITE}%-$((width-4))s${RESET} ${CYAN}║${RESET}\n" "$title"
    echo -e "${CYAN}╚$(printf '═%.0s' $(seq 1 $((width-2))))╝${RESET}"
    echo ""
}

print_subheader() {
    echo -e "\n${YELLOW}▶ $1${RESET}\n"
}

print_command() {
    echo -e "${DIM}$ ${RESET}${GREEN}$1${RESET}"
}

print_explanation() {
    echo -e "${DIM}   ℹ️  $1${RESET}"
}

print_step() {
    echo -e "${MAGENTA}[Pas $1]${RESET} $2"
}

wait_for_user() {
    echo ""
    echo -e "${DIM}Apasă ${BOLD}ENTER${RESET}${DIM} pentru a continua...${RESET}"
    read -r
}

run_with_highlight() {
    local cmd="$1"
    local desc="$2"
    
    echo -e "${CYAN}┌─ Comandă ─────────────────────────────────────────────────────┐${RESET}"
    echo -e "${CYAN}│${RESET} ${GREEN}$cmd${RESET}"
    echo -e "${CYAN}└───────────────────────────────────────────────────────────────┘${RESET}"
    if [[ -n "$desc" ]]; then
        print_explanation "$desc"
    fi
    echo -e "${YELLOW}Output:${RESET}"
    eval "$cmd" 2>&1 | sed 's/^/  /'
    echo ""
}

show_pipeline_diagram() {
    local components=("$@")
    local diagram=""
    
    echo -e "${CYAN}┌─ Pipeline Vizual ─────────────────────────────────────────────┐${RESET}"
    
    local first=true
    for comp in "${components[@]}"; do
        if [[ "$first" == "true" ]]; then
            diagram="[$comp]"
            first=false
        else
            diagram="$diagram ──▶ [$comp]"
        fi
    done
    
    echo -e "${CYAN}│${RESET} ${WHITE}$diagram${RESET}"
    echo -e "${CYAN}│${RESET}"
    echo -e "${CYAN}│${RESET} ${DIM}Date: stdin ══▶ procesare ══▶ stdout${RESET}"
    echo -e "${CYAN}└───────────────────────────────────────────────────────────────┘${RESET}"
}

#
# VERIFICARE DEPENDENȚE
#

check_dependencies() {
    local missing=()
    
    for cmd in ps awk sort head cut grep; do
        if ! command -v "$cmd" &>/dev/null; then
            missing+=("$cmd")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo -e "${RED}Eroare: Comenzi lipsă: ${missing[*]}${RESET}"
        exit 1
    fi
    
    # Optional tools
    if command -v figlet &>/dev/null; then
        HAS_FIGLET=true
    else
        HAS_FIGLET=false
    fi
    
    if command -v lolcat &>/dev/null; then
        HAS_LOLCAT=true
    else
        HAS_LOLCAT=false
    fi
    
    if command -v pv &>/dev/null; then
        HAS_PV=true
    else
        HAS_PV=false
    fi
}

#
# DEMO 1: INTRODUCERE PIPELINE
#

demo_intro() {
    print_header "🔄 DEMO: INTRODUCERE ÎN PIPELINE-URI"
    
    echo -e "${WHITE}Ce este un pipeline?${RESET}"
    echo ""
    echo "  Un pipeline conectează stdout-ul unei comenzi la stdin-ul alteia."
    echo "  Simbolul | (pipe) face această conexiune."
    echo ""
    
    cat << 'DIAGRAM'
    ┌──────────┐     PIPE     ┌──────────┐
    │ Comandă  │──────────────│ Comandă  │
    │    1     │   stdout→    │    2     │   → stdout final
    │          │   stdin      │          │
    └──────────┘              └──────────┘
         ↑
      stdin
DIAGRAM
    
    wait_for_user
    
    print_subheader "Exemplu simplu: numără fișierele"
    
    echo -e "${YELLOW}Fără pipe (2 comenzi separate):${RESET}"
    run_with_highlight "ls /etc" "Listează fișiere"
    echo -e "${DIM}...și apoi manual numărăm? Nu!${RESET}"
    
    wait_for_user
    
    echo -e "${YELLOW}Cu pipe (o singură comandă compusă):${RESET}"
    run_with_highlight "ls /etc | wc -l" "stdout de la ls devine stdin pentru wc"
    
    show_pipeline_diagram "ls /etc" "wc -l"
}

#
# DEMO 2: CONSTRUIRE INCREMENTALĂ
#

demo_incremental() {
    print_header "📈 DEMO: CONSTRUIRE INCREMENTALĂ A PIPELINE-ULUI"
    
    echo -e "${WHITE}Regula de aur: construiește pipeline-ul pas cu pas!${RESET}"
    echo -e "${DIM}Verifică output-ul la fiecare pas înainte de a adăuga altul.${RESET}"
    echo ""
    
    wait_for_user
    
    print_subheader "Obiectiv: Top 5 utilizatori cu cele mai multe procese"
    
    print_step "1" "Începem cu date brute"
    run_with_highlight "ps aux | head -5" "Vedem structura - coloana 1 e username"
    
    wait_for_user
    
    print_step "2" "Extragem doar username-urile"
    show_pipeline_diagram "ps aux" "awk '{print \$1}'"
    run_with_highlight "ps aux | awk '{print \$1}' | head -10" "Doar coloana 1"
    
    wait_for_user
    
    print_step "3" "Sortăm pentru a pregăti uniq"
    echo -e "${RED}⚠️  Capcană: uniq funcționează doar pe date SORTATE!${RESET}"
    show_pipeline_diagram "ps aux" "awk" "sort"
    run_with_highlight "ps aux | awk '{print \$1}' | sort | head -10" "Acum sunt sortate"
    
    wait_for_user
    
    print_step "4" "Numărăm duplicatele cu uniq -c"
    show_pipeline_diagram "ps aux" "awk" "sort" "uniq -c"
    run_with_highlight "ps aux | awk '{print \$1}' | sort | uniq -c | head -10" "Frecvența fiecărui user"
    
    wait_for_user
    
    print_step "5" "Sortăm numeric descrescător"
    show_pipeline_diagram "ps aux" "awk" "sort" "uniq -c" "sort -rn"
    run_with_highlight "ps aux | awk '{print \$1}' | sort | uniq -c | sort -rn | head -5" "Top 5 useri"
    
    wait_for_user
    
    print_step "6" "Pipeline-ul final complet"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${WHITE}ps aux | awk '{print \$1}' | sort | uniq -c | sort -rn | head -5${RESET}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
}

#
# DEMO 3: PIPESTATUS ȘI EXIT CODES
#

demo_pipestatus() {
    print_header "🎯 DEMO: EXIT CODES ÎN PIPELINE-URI"
    
    echo -e "${WHITE}Întrebare: Care e exit code-ul unui pipeline?${RESET}"
    echo ""
    echo "  Implicit: exit code-ul ULTIMEI comenzi din pipeline"
    echo "  Cu pipefail: primul exit code nenul"
    echo ""
    
    wait_for_user
    
    print_subheader "Exemplu: comandă care eșuează în mijloc"
    
    echo -e "${YELLOW}Pipeline cu eroare la început:${RESET}"
    run_with_highlight "ls /inexistent 2>/dev/null | wc -l; echo \"Exit code: \$?\"" \
        "ls eșuează, dar wc reușește, deci exit=0"
    
    wait_for_user
    
    echo -e "${YELLOW}Verificăm cu PIPESTATUS:${RESET}"
    ls /inexistent 2>/dev/null | wc -l
    echo -e "  ${CYAN}PIPESTATUS: (${PIPESTATUS[0]}, ${PIPESTATUS[1]})${RESET}"
    echo -e "  ${DIM}Prima comandă a returnat ${PIPESTATUS[0]}, a doua ${PIPESTATUS[1]}${RESET}"
    
    wait_for_user
    
    print_subheader "Activarea pipefail"
    
    echo -e "${GREEN}set -o pipefail${RESET} - face pipeline-ul să returneze prima eroare"
    echo ""
    
    (
        set -o pipefail
        ls /inexistent 2>/dev/null | wc -l
        echo -e "  ${CYAN}Cu pipefail, exit code: $?${RESET}"
    )
}

#
# DEMO 4: TEE - DUPLICARE STREAM
#

demo_tee() {
    print_header "🔀 DEMO: COMANDA TEE - DUPLICARE STREAM"
    
    echo -e "${WHITE}tee citește stdin și scrie atât în fișier cât și în stdout${RESET}"
    echo ""
    
    cat << 'DIAGRAM'
                        ┌──────────────┐
                     ┌──│   fișier     │
    stdin ───▶ tee ──┤  └──────────────┘
                     │
                     └──▶ stdout (continuă în pipe)
DIAGRAM
    
    wait_for_user
    
    # Creăm director temporar
    local tmpdir="/tmp/demo_tee_$$"
    mkdir -p "$tmpdir"
    
    print_subheader "Exemplu: salvăm output intermediar"
    
    echo -e "${YELLOW}Problemă: vrem să vedem și să salvăm simultan${RESET}"
    
    run_with_highlight "echo 'test' | tee $tmpdir/output.txt" \
        "Afișează pe ecran ȘI salvează în fișier"
    
    echo -e "${CYAN}Conținut fișier:${RESET}"
    cat "$tmpdir/output.txt"
    echo ""
    
    wait_for_user
    
    print_subheader "Debugging pipeline-uri cu tee"
    
    echo -e "${YELLOW}Vedem ce iese după fiecare pas:${RESET}"
    
    show_pipeline_diagram "ps aux" "tee step1.txt" "awk" "tee step2.txt" "sort"
    
    run_with_highlight "ps aux | head -5 | tee $tmpdir/step1.txt | awk '{print \$1,\$4}' | tee $tmpdir/step2.txt | sort" \
        "Salvăm output intermediar pentru debug"
    
    echo -e "\n${CYAN}Conținut step1.txt (după head):${RESET}"
    head -3 "$tmpdir/step1.txt"
    echo "..."
    
    echo -e "\n${CYAN}Conținut step2.txt (după awk):${RESET}"
    head -3 "$tmpdir/step2.txt"
    echo "..."
    
    # Curățare
    rm -rf "$tmpdir"
}

#
# DEMO 5: PIPELINE AVANSAT - ANALIZA LOG
#

demo_log_analysis() {
    print_header "📊 DEMO: PIPELINE AVANSAT - ANALIZĂ LOG"
    
    # Creăm un fișier log de test
    local tmplog="/tmp/demo_access_$$.log"
    
    cat > "$tmplog" << 'EOF'
192.168.1.100 - - [15/Jan/2025:10:00:01] "GET /index.html HTTP/1.1" 200 1234
192.168.1.101 - - [15/Jan/2025:10:00:02] "GET /style.css HTTP/1.1" 200 567
192.168.1.100 - - [15/Jan/2025:10:00:03] "GET /api/data HTTP/1.1" 500 89
10.0.0.50 - - [15/Jan/2025:10:00:04] "POST /login HTTP/1.1" 200 234
192.168.1.100 - - [15/Jan/2025:10:00:05] "GET /images/logo.png HTTP/1.1" 200 45678
192.168.1.102 - - [15/Jan/2025:10:00:06] "GET /index.html HTTP/1.1" 200 1234
10.0.0.50 - - [15/Jan/2025:10:00:07] "GET /dashboard HTTP/1.1" 403 123
192.168.1.100 - - [15/Jan/2025:10:00:08] "GET /api/users HTTP/1.1" 200 5678
192.168.1.101 - - [15/Jan/2025:10:00:09] "GET /index.html HTTP/1.1" 200 1234
192.168.1.103 - - [15/Jan/2025:10:00:10] "GET /index.html HTTP/1.1" 404 234
EOF
    
    echo -e "${WHITE}Analizăm un fișier de log Apache:${RESET}"
    echo ""
    run_with_highlight "head -3 $tmplog" "Structura log-ului"
    
    wait_for_user
    
    print_subheader "Analiza 1: Top IP-uri după număr de request-uri"
    
    echo -e "${YELLOW}Construim incremental:${RESET}"
    
    print_step "1" "Extragem IP-urile (prima coloană)"
    run_with_highlight "cat $tmplog | awk '{print \$1}'" ""
    
    wait_for_user
    
    print_step "2" "Sort + uniq -c + sort -rn"
    run_with_highlight "cat $tmplog | awk '{print \$1}' | sort | uniq -c | sort -rn" \
        "Top IP-uri"
    
    wait_for_user
    
    print_subheader "Analiza 2: Doar erorile (status 4xx și 5xx)"
    
    run_with_highlight "cat $tmplog | awk '\$9 >= 400 {print \$1, \$9, \$7}'" \
        "IP-uri cu erori, status code și URL"
    
    wait_for_user
    
    print_subheader "Analiza 3: Statistici status codes"
    
    run_with_highlight "cat $tmplog | awk '{print \$9}' | sort | uniq -c | sort -rn" \
        "Distribuția status codes"
    
    wait_for_user
    
    print_subheader "Pipeline complet: Raport de securitate"
    
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${WHITE}cat log | grep 'POST\\|DELETE' | awk '{print \$1}' | sort | uniq -c | sort -rn${RESET}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    
    cat "$tmplog" | grep -E 'POST|DELETE' | awk '{print $1}' | sort | uniq -c | sort -rn
    
    # Curățare
    rm -f "$tmplog"
}

#
# DEMO 6: PIPELINE SPECTACULOS (dacă sunt tool-uri)
#

demo_spectacular() {
    print_header "🎭 DEMO: PIPELINE SPECTACULOS"
    
    if [[ "$HAS_FIGLET" == "true" ]]; then
        echo "PIPE" | figlet -c
        
        if [[ "$HAS_LOLCAT" == "true" ]]; then
            echo "POWER!" | figlet | lolcat
        else
            echo "POWER!" | figlet
        fi
    else
        echo ""
        echo -e "${CYAN}╔════════════════════════════════════╗${RESET}"
        echo -e "${CYAN}║${RESET}     ${BOLD}${WHITE}P I P E   P O W E R !${RESET}       ${CYAN}║${RESET}"
        echo -e "${CYAN}╚════════════════════════════════════╝${RESET}"
    fi
    
    wait_for_user
    
    print_subheader "Pipeline de generare statistici sistem"
    
    echo -e "${YELLOW}One-liner pentru raport sistem:${RESET}\n"
    
    {
        echo "═══════════════════════════════════════════════════════"
        echo " RAPORT SISTEM - $(date '+%Y-%m-%d %H:%M:%S')"
        echo "═══════════════════════════════════════════════════════"
        echo ""
        echo "📊 Procese per utilizator:"
        ps aux | awk '{print $1}' | sort | uniq -c | sort -rn | head -3 | \
            awk '{printf "   %-15s %d procese\n", $2, $1}'
        echo ""
        echo "💾 Disk usage:"
        df -h / | tail -1 | awk '{printf "   Root: %s folosit din %s (%s)\n", $3, $2, $5}'
        echo ""
        echo "🔄 Load average:"
        cat /proc/loadavg | awk '{printf "   1min: %s | 5min: %s | 15min: %s\n", $1, $2, $3}'
        echo ""
        echo "═══════════════════════════════════════════════════════"
    } | if [[ "$HAS_LOLCAT" == "true" ]]; then lolcat; else cat; fi
}

#
# DEMO 7: GREȘELI COMUNE
#

demo_mistakes() {
    print_header "⚠️  DEMO: GREȘELI COMUNE CU PIPELINE-URI"
    
    print_subheader "Greșeala #1: Folosirea lui cat inutil (UUOC)"
    
    echo -e "${RED}❌ Greșit:${RESET}"
    print_command "cat file.txt | grep pattern"
    echo ""
    
    echo -e "${GREEN}✓ Corect:${RESET}"
    print_command "grep pattern file.txt"
    echo ""
    echo -e "${DIM}   'Useless Use of Cat' - grep poate citi direct din fișier${RESET}"
    
    wait_for_user
    
    print_subheader "Greșeala #2: uniq fără sort"
    
    echo -e "${RED}❌ Greșit - duplicatele nu sunt eliminate:${RESET}"
    echo -e "a\nb\na\nb" | uniq
    echo ""
    
    echo -e "${GREEN}✓ Corect - cu sort înainte:${RESET}"
    echo -e "a\nb\na\nb" | sort | uniq
    echo ""
    echo -e "${DIM}   uniq elimină doar duplicate CONSECUTIVE!${RESET}"
    
    wait_for_user
    
    print_subheader "Greșeala #3: Pierderea variabilelor în subshell"
    
    echo -e "${RED}❌ Variabila se pierde:${RESET}"
    count=0
    echo -e "a\nb\nc" | while read line; do
        ((count++))
    done
    echo "   count = $count (așteptam 3!)"
    echo ""
    
    echo -e "${GREEN}✓ Soluție: process substitution${RESET}"
    count=0
    while read line; do
        ((count++))
    done < <(echo -e "a\nb\nc")
    echo "   count = $count (corect!)"
    echo ""
    echo -e "${DIM}   while în pipe rulează în subshell!${RESET}"
}

#
# MENIU PRINCIPAL
#

show_menu() {
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║${RESET}  ${BOLD}${WHITE}🔄 DEMO PIPELINE-URI - MENIU PRINCIPAL${RESET}                    ${CYAN}║${RESET}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════════════╣${RESET}"
    echo -e "${CYAN}║${RESET}  ${GREEN}1)${RESET} Introducere în pipeline-uri                              ${CYAN}║${RESET}"
    echo -e "${CYAN}║${RESET}  ${GREEN}2)${RESET} Construire incrementală                                  ${CYAN}║${RESET}"
    echo -e "${CYAN}║${RESET}  ${GREEN}3)${RESET} Exit codes și PIPESTATUS                                 ${CYAN}║${RESET}"
    echo -e "${CYAN}║${RESET}  ${GREEN}4)${RESET} Comanda tee - duplicare stream                          ${CYAN}║${RESET}"
    echo -e "${CYAN}║${RESET}  ${GREEN}5)${RESET} Analiză log avansată                                     ${CYAN}║${RESET}"
    echo -e "${CYAN}║${RESET}  ${GREEN}6)${RESET} Pipeline spectaculos                                     ${CYAN}║${RESET}"
    echo -e "${CYAN}║${RESET}  ${GREEN}7)${RESET} Greșeli comune                                           ${CYAN}║${RESET}"
    echo -e "${CYAN}║${RESET}  ${GREEN}A)${RESET} Rulează TOATE demo-urile                                 ${CYAN}║${RESET}"
    echo -e "${CYAN}║${RESET}  ${RED}Q)${RESET} Ieșire                                                   ${CYAN}║${RESET}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${RESET}"
    echo ""
}

run_all_demos() {
    demo_intro
    demo_incremental
    demo_pipestatus
    demo_tee
    demo_log_analysis
    demo_spectacular
    demo_mistakes
    
    print_header "🎉 TOATE DEMO-URILE COMPLETE!"
    echo -e "${GREEN}Acum știi să:${RESET}"
    echo "  ${CHECKMARK} Construiești pipeline-uri incremental"
    echo "  ${CHECKMARK} Folosești tee pentru debugging"
    echo "  ${CHECKMARK} Gestionezi exit codes cu PIPESTATUS"
    echo "  ${CHECKMARK} Analizezi fișiere log complex"
    echo "  ${CHECKMARK} Eviți greșeli comune"
}

main() {
    check_dependencies
    
    # Dacă primește argument, rulează acel demo direct
    case "${1:-}" in
        1) demo_intro ;;
        2) demo_incremental ;;
        3) demo_pipestatus ;;
        4) demo_tee ;;
        5) demo_log_analysis ;;
        6) demo_spectacular ;;
        7) demo_mistakes ;;
        all|a|A) run_all_demos ;;
        -h|--help)
            echo "Utilizare: $0 [1-7|all]"
            echo "  Fără argument: meniu interactiv"
            echo "  1-7: rulează demo-ul specific"
            echo "  all: rulează toate demo-urile"
            exit 0
            ;;
        "")
            # Meniu interactiv
            while true; do
                clear
                show_menu
                echo -n "Selectează opțiunea: "
                read -r choice
                
                case "$choice" in
                    1) demo_intro ;;
                    2) demo_incremental ;;
                    3) demo_pipestatus ;;
                    4) demo_tee ;;
                    5) demo_log_analysis ;;
                    6) demo_spectacular ;;
                    7) demo_mistakes ;;
                    [aA]) run_all_demos ;;
                    [qQ]) 
                        echo -e "\n${GREEN}La revedere!${RESET}\n"
                        exit 0 
                        ;;
                    *)
                        echo -e "${RED}Opțiune invalidă!${RESET}"
                        sleep 1
                        ;;
                esac
                
                wait_for_user
            done
            ;;
        *)
            echo "Opțiune necunoscută: $1"
            echo "Folosește -h pentru ajutor"
            exit 1
            ;;
    esac
}

# Pornire script
main "$@"
