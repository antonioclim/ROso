#!/bin/bash
#
#  S02_04_demo_filtre.sh - Demo Spectaculos Filtre de Text
#
# DESCRIERE:
#   Demonstrații vizuale pentru filtrele Unix de procesare text:
#   - sort (sortare pe diverse criterii)
#   - uniq (eliminare duplicate CONSECUTIVE - capcană frecventă!)
#   - cut (extragere coloane/caractere)
#   - paste (îmbinare fișiere)
#   - tr (translate/delete/squeeze caractere)
#   - wc (numărare linii/cuvinte/caractere)
#   - head/tail (primele/ultimele linii)
#   - Pipeline-uri complexe
#
# UTILIZARE:
#   ./S02_04_demo_filtre.sh [demo_number]
#   ./S02_04_demo_filtre.sh          # Rulează toate demo-urile
#   ./S02_04_demo_filtre.sh menu     # Afișează meniu interactiv
#
# DEPENDENȚE:
#   - Obligatorii: bash 4.0+, coreutils
#   - Opționale: figlet, lolcat, cowsay (pentru efecte vizuale)
#
# AUTOR: Kit Pedagogic SO | ASE București - CSIE
# VERSIUNE: 1.0 | Ianuarie 2025
#

set -euo pipefail

#
# CONFIGURARE CULORI ȘI SIMBOLURI
#
if [[ -t 1 ]]; then
    RED='\033[1;31m'
    GREEN='\033[1;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[1;34m'
    MAGENTA='\033[1;35m'
    CYAN='\033[1;36m'
    WHITE='\033[1;37m'
    DIM='\033[2m'
    BOLD='\033[1m'
    RESET='\033[0m'
    BG_RED='\033[41m'
    BG_GREEN='\033[42m'
    
    CHECK="✓"
    CROSS="✗"
    ARROW="→"
    PIPE_SYM="│"
    BULLET="•"
    STAR="★"
    WARNING="⚠️"
else
    RED='' GREEN='' YELLOW='' BLUE='' MAGENTA='' CYAN='' WHITE=''
    DIM='' BOLD='' RESET='' BG_RED='' BG_GREEN=''
    CHECK="[OK]" CROSS="[X]" ARROW="->" PIPE_SYM="|" BULLET="*" STAR="*" WARNING="[!]"
fi

#
# DIRECTOARE DE LUCRU
#
DEMO_DIR="${TMPDIR:-/tmp}/demo_filtre_$$"
mkdir -p "$DEMO_DIR"
cd "$DEMO_DIR"

cleanup() {
    cd /
    rm -rf "$DEMO_DIR" 2>/dev/null || true
}
trap cleanup EXIT

#
# FUNCȚII HELPER
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
    echo -e "\n${YELLOW}━━━ $1 ━━━${RESET}\n"
}

print_code() {
    echo -e "${DIM}┌─────────────────────────────────────────────────────────────────┐${RESET}"
    echo -e "${GREEN}  $1${RESET}"
    echo -e "${DIM}└─────────────────────────────────────────────────────────────────┘${RESET}"
}

print_warning() {
    echo -e "\n${BG_RED}${WHITE} ${WARNING} ATENȚIE ${RESET} ${RED}$1${RESET}\n"
}

print_tip() {
    echo -e "${GREEN}💡 TIP: $1${RESET}"
}

print_explanation() {
    echo -e "${MAGENTA}  ${BULLET} $1${RESET}"
}

wait_for_user() {
    echo ""
    echo -e "${DIM}Apasă ENTER pentru a continua...${RESET}"
    read -r
}

side_by_side() {
    local left_title="$1"
    local right_title="$2"
    local left_content="$3"
    local right_content="$4"
    
    echo -e "${YELLOW}$left_title${RESET}              ${YELLOW}$right_title${RESET}"
    echo "─────────────────────    ─────────────────────"
    paste <(echo "$left_content") <(echo "$right_content") | column -t -s $'\t' 2>/dev/null || {
        echo "$left_content"
        echo "---"
        echo "$right_content"
    }
}

fancy_title() {
    local text="$1"
    
    if command -v figlet &>/dev/null; then
        if command -v lolcat &>/dev/null; then
            figlet -f small "$text" 2>/dev/null | lolcat -f 2>/dev/null || echo "=== $text ==="
        else
            echo -e "${CYAN}"
            figlet -f small "$text" 2>/dev/null || echo "=== $text ==="
            echo -e "${RESET}"
        fi
    else
        echo ""
        echo -e "${CYAN}╭────────────────────────────────────────╮${RESET}"
        echo -e "${CYAN}│${RESET}  ${BOLD}${WHITE}$text${RESET}  ${CYAN}│${RESET}"
        echo -e "${CYAN}╰────────────────────────────────────────╯${RESET}"
    fi
}

#
# DATE DE TEST
#
create_test_files() {
    # Fișier cu numere
    cat > numere.txt << 'EOF'
42
7
100
23
7
85
42
100
7
EOF
    
    # Fișier cu culori (cu duplicate neconsecutive)
    cat > culori.txt << 'EOF'
rosu
verde
rosu
albastru
verde
rosu
galben
EOF
    
    # Fișier CSV
    cat > studenti.csv << 'EOF'
Ion,Popescu,8.5,Informatica
Maria,Ionescu,9.2,Matematica
Andrei,Vasilescu,7.8,Informatica
Elena,Dumitrescu,9.5,Fizica
Mihai,Georgescu,8.0,Matematica
Ana,Constantinescu,9.8,Informatica
EOF
    
    # Log simulat
    cat > access.log << 'EOF'
192.168.1.10 - - [01/Jan/2025:10:15:32] "GET /index.html HTTP/1.1" 200 1234
192.168.1.20 - - [01/Jan/2025:10:15:35] "GET /api/users HTTP/1.1" 200 5678
192.168.1.10 - - [01/Jan/2025:10:16:01] "POST /api/login HTTP/1.1" 401 89
192.168.1.30 - - [01/Jan/2025:10:16:15] "GET /images/logo.png HTTP/1.1" 200 45678
192.168.1.10 - - [01/Jan/2025:10:17:22] "GET /api/users HTTP/1.1" 200 5678
192.168.1.20 - - [01/Jan/2025:10:17:45] "GET /index.html HTTP/1.1" 200 1234
192.168.1.40 - - [01/Jan/2025:10:18:30] "GET /api/products HTTP/1.1" 500 123
EOF
    
    # Text pentru tr
    cat > text.txt << 'EOF'
Hello World! This is a TEST.
Bash scripting is    AWESOME!
Multiple    spaces   here.
EOF
}

#
# DEMO 1: SORT - SORTARE
#
demo_sort() {
    print_header "📊 DEMO 1: SORT - SORTARE"
    create_test_files
    
    print_subheader "Sortare alfabetică (implicit)"
    
    echo -e "${BLUE}Fișier culori.txt:${RESET}"
    cat culori.txt | sed 's/^/  /'
    echo ""
    
    print_code "sort culori.txt"
    echo -e "${BLUE}Rezultat:${RESET}"
    sort culori.txt | sed 's/^/  /'
    
    wait_for_user
    
    print_subheader "Sortare numerică (-n)"
    
    echo -e "${BLUE}Fișier numere.txt:${RESET}"
    cat numere.txt | head -5 | sed 's/^/  /'
    echo ""
    
    echo -e "${RED}GREȘIT - sort alfabetic:${RESET}"
    print_code "sort numere.txt"
    sort numere.txt | head -5 | sed 's/^/  /'
    print_explanation "100 apare înaintea 23 (compară '1' cu '2' alfabetic!)"
    
    echo ""
    echo -e "${GREEN}CORECT - sort numeric:${RESET}"
    print_code "sort -n numere.txt"
    sort -n numere.txt | head -5 | sed 's/^/  /'
    
    wait_for_user
    
    print_subheader "Opțiuni importante"
    
    echo -e "${CYAN}sort -r${RESET} = reverse (descrescător)"
    print_code "sort -rn numere.txt | head -3"
    sort -rn numere.txt | head -3 | sed 's/^/  /'
    
    echo ""
    echo -e "${CYAN}sort -u${RESET} = unique (elimină duplicate)"
    print_code "sort -u numere.txt"
    sort -u numere.txt | sed 's/^/  /'
    
    wait_for_user
    
    print_subheader "Sortare pe coloane (-k)"
    
    echo -e "${BLUE}Fișier studenti.csv:${RESET}"
    cat studenti.csv | sed 's/^/  /'
    echo ""
    
    echo -e "${CYAN}Sortare după coloana 3 (nota), numeric, descrescător:${RESET}"
    print_code "sort -t',' -k3 -rn studenti.csv"
    sort -t',' -k3 -rn studenti.csv | sed 's/^/  /'
    
    print_explanation "-t',' = delimitator virgulă"
    print_explanation "-k3   = coloana 3"
    print_explanation "-rn   = reverse numeric"
    
    wait_for_user
}

#
# DEMO 2: UNIQ - CAPCANA DUPLICATELOR
#
demo_uniq() {
    print_header "🔍 DEMO 2: UNIQ - CAPCANA DUPLICATELOR"
    create_test_files
    
    print_warning "UNIQ ELIMINĂ DOAR DUPLICATELE CONSECUTIVE!"
    
    print_subheader "Demonstrația capcanei"
    
    echo -e "${BLUE}Fișier culori.txt:${RESET}"
    nl culori.txt | sed 's/^/  /'
    echo ""
    
    echo -e "${RED}GREȘIT - uniq FĂRĂ sort:${RESET}"
    print_code "uniq culori.txt"
    uniq culori.txt | sed 's/^/  /'
    
    echo ""
    echo -e "${DIM}Observă: rosu apare de 3 ori în fișier dar uniq păstrează 2!${RESET}"
    echo -e "${DIM}Verde apare de 2 ori și uniq păstrează 2!${RESET}"
    echo ""
    
    print_explanation "'rosu' pe liniile 1, 3, 6 - nu sunt consecutive!"
    print_explanation "uniq vede: rosu→verde (diferite), verde→rosu (diferite)"
    
    wait_for_user
    
    echo -e "${GREEN}CORECT - sort | uniq:${RESET}"
    print_code "sort culori.txt | uniq"
    sort culori.txt | uniq | sed 's/^/  /'
    
    print_explanation "Sort grupează duplicatele, apoi uniq le elimină"
    
    wait_for_user
    
    print_subheader "Opțiuni utile uniq"
    
    echo -e "${CYAN}uniq -c${RESET} = numără aparițiile"
    print_code "sort culori.txt | uniq -c"
    sort culori.txt | uniq -c | sed 's/^/  /'
    
    echo ""
    echo -e "${CYAN}sort | uniq -c | sort -rn${RESET} = frecvență descrescătoare"
    print_code "sort culori.txt | uniq -c | sort -rn"
    sort culori.txt | uniq -c | sort -rn | sed 's/^/  /'
    
    wait_for_user
    
    print_subheader "Vizualizare: De ce trebuie sort?"
    
    cat << 'DIAGRAM'
    
    FĂRĂ SORT:                      CU SORT:
    ───────────                     ────────
    rosu    ─┐                      albastru ─┐
    verde    │ diferite             galben    │ toate unice
    rosu    ─┘ păstrează            rosu      │ adiacente
    albastru                        rosu      ├→ elimină duplicate
    verde                           rosu     ─┘
    rosu                            verde
    galben                          verde    ─┬→ elimină
                                             ─┘
    
    Rezultat: 6 linii              Rezultat: 4 linii (corect!)

DIAGRAM
    
    wait_for_user
    
    print_subheader "Alte opțiuni uniq"
    
    echo -e "${CYAN}uniq -d${RESET} = afișează DOAR duplicatele"
    print_code "sort culori.txt | uniq -d"
    sort culori.txt | uniq -d | sed 's/^/  /' || echo "  (niciunul)"
    
    echo ""
    echo -e "${CYAN}uniq -u${RESET} = afișează DOAR liniile unice"
    print_code "sort culori.txt | uniq -u"
    sort culori.txt | uniq -u | sed 's/^/  /'
    
    print_tip "Reține: sort | uniq este un pattern atât de comun încât sort -u face același lucru!"
    
    wait_for_user
}

#
# DEMO 3: CUT - EXTRAGERE COLOANE
#
demo_cut() {
    print_header "✂️  DEMO 3: CUT - EXTRAGERE COLOANE"
    create_test_files
    
    print_subheader "Extragere după delimiter (-d, -f)"
    
    echo -e "${BLUE}Fișier studenti.csv:${RESET}"
    cat studenti.csv | sed 's/^/  /'
    echo ""
    
    print_code "cut -d',' -f1 studenti.csv    # Prima coloană (prenume)"
    cut -d',' -f1 studenti.csv | sed 's/^/  /'
    
    echo ""
    print_code "cut -d',' -f1,2 studenti.csv  # Coloanele 1 și 2"
    cut -d',' -f1,2 studenti.csv | sed 's/^/  /'
    
    echo ""
    print_code "cut -d',' -f3 studenti.csv    # Coloana 3 (nota)"
    cut -d',' -f3 studenti.csv | sed 's/^/  /'
    
    wait_for_user
    
    print_subheader "Interval de coloane"
    
    print_code "cut -d',' -f2-4 studenti.csv  # Coloanele 2 până la 4"
    cut -d',' -f2-4 studenti.csv | sed 's/^/  /'
    
    echo ""
    print_code "cut -d',' -f2- studenti.csv   # De la coloana 2 până la final"
    cut -d',' -f2- studenti.csv | sed 's/^/  /'
    
    wait_for_user
    
    print_subheader "Extragere după caractere (-c)"
    
    echo -e "${BLUE}Text pentru demonstrație:${RESET}"
    echo "  ABCDEFGHIJ"
    echo ""
    
    print_code "echo 'ABCDEFGHIJ' | cut -c1-3"
    echo "  $(echo 'ABCDEFGHIJ' | cut -c1-3)"
    
    print_code "echo 'ABCDEFGHIJ' | cut -c5-"
    echo "  $(echo 'ABCDEFGHIJ' | cut -c5-)"
    
    print_code "echo 'ABCDEFGHIJ' | cut -c1,3,5,7,9"
    echo "  $(echo 'ABCDEFGHIJ' | cut -c1,3,5,7,9)"
    
    wait_for_user
    
    print_subheader "Use Case: Extragere din /etc/passwd"
    
    print_code "cut -d':' -f1,3,7 /etc/passwd | head -5"
    echo -e "${DIM}(username:UID:shell)${RESET}"
    cut -d':' -f1,3,7 /etc/passwd | head -5 | sed 's/^/  /'
    
    wait_for_user
}

#
# DEMO 4: PASTE - ÎMBINARE FIȘIERE
#
demo_paste() {
    print_header "📋 DEMO 4: PASTE - ÎMBINARE FIȘIERE"
    
    # Creare fișiere pentru paste
    cat > prenume.txt << 'EOF'
Ion
Maria
Andrei
EOF
    
    cat > nume.txt << 'EOF'
Popescu
Ionescu
Vasilescu
EOF
    
    cat > note.txt << 'EOF'
8.5
9.2
7.8
EOF
    
    print_subheader "paste simplu (implicit TAB)"
    
    echo -e "${BLUE}prenume.txt:${RESET}  ${BLUE}nume.txt:${RESET}   ${BLUE}note.txt:${RESET}"
    paste prenume.txt nume.txt note.txt | head -3 | \
        awk -F'\t' '{printf "%-12s %-12s %-12s\n", $1, $2, $3}'
    echo ""
    
    print_code "paste prenume.txt nume.txt note.txt"
    paste prenume.txt nume.txt note.txt | sed 's/^/  /'
    
    wait_for_user
    
    print_subheader "Delimiter personalizat (-d)"
    
    print_code "paste -d',' prenume.txt nume.txt note.txt"
    paste -d',' prenume.txt nume.txt note.txt | sed 's/^/  /'
    
    echo ""
    print_code "paste -d':' prenume.txt nume.txt"
    paste -d':' prenume.txt nume.txt | sed 's/^/  /'
    
    wait_for_user
    
    print_subheader "Serializare (-s)"
    
    echo -e "${BLUE}prenume.txt vertical:${RESET}"
    cat prenume.txt | sed 's/^/  /'
    echo ""
    
    print_code "paste -s prenume.txt    # Tot pe o linie"
    paste -s prenume.txt | sed 's/^/  /'
    
    echo ""
    print_code "paste -sd',' prenume.txt    # Cu virgulă"
    paste -sd',' prenume.txt | sed 's/^/  /'
    
    wait_for_user
    
    print_subheader "Use Case: Formatare două coloane"
    
    seq 1 6 > col1.txt
    seq 7 12 > col2.txt
    
    echo -e "${DIM}Transformă 2 fișiere verticale în tabel:${RESET}"
    print_code "paste col1.txt col2.txt"
    paste col1.txt col2.txt | sed 's/^/  /'
    
    wait_for_user
}

#
# DEMO 5: TR - TRANSLATE/DELETE CARACTERE
#
demo_tr() {
    print_header "🔤 DEMO 5: TR - TRANSLATE/DELETE CARACTERE"
    create_test_files
    
    print_warning "tr lucrează cu CARACTERE, nu cu stringuri!"
    
    print_subheader "Traducere caractere"
    
    print_code "echo 'hello world' | tr 'a-z' 'A-Z'"
    echo "  $(echo 'hello world' | tr 'a-z' 'A-Z')"
    
    echo ""
    print_code "echo 'HELLO WORLD' | tr 'A-Z' 'a-z'"
    echo "  $(echo 'HELLO WORLD' | tr 'A-Z' 'a-z')"
    
    echo ""
    print_code "echo 'hello' | tr 'aeiou' '12345'"
    echo "  $(echo 'hello' | tr 'aeiou' '12345')"
    print_explanation "h→h, e→2, l→l, l→l, o→5"
    
    wait_for_user
    
    print_subheader "Ștergere caractere (-d)"
    
    print_code "echo 'Hello123World456' | tr -d '0-9'"
    echo "  $(echo 'Hello123World456' | tr -d '0-9')"
    
    echo ""
    print_code "echo 'Hello World!' | tr -d ' '"
    echo "  $(echo 'Hello World!' | tr -d ' ')"
    
    echo ""
    print_code "echo 'email@test.com' | tr -d '@.'"
    echo "  $(echo 'email@test.com' | tr -d '@.')"
    
    wait_for_user
    
    print_subheader "Squeeze (-s) - Comprimare repetări"
    
    echo -e "${BLUE}text.txt conține spații multiple:${RESET}"
    cat text.txt | sed 's/^/  /'
    echo ""
    
    print_code "cat text.txt | tr -s ' '"
    cat text.txt | tr -s ' ' | sed 's/^/  /'
    
    print_explanation "-s ' ' comprimă spațiile consecutive într-unul singur"
    
    wait_for_user
    
    print_subheader "Complement (-c) - Inversare set"
    
    print_code "echo 'abc123xyz' | tr -dc '0-9'"
    echo "  $(echo 'abc123xyz' | tr -dc '0-9')"
    print_explanation "-d = delete, -c = complement (tot CE NU E cifră)"
    
    echo ""
    print_code "echo 'Hello World!' | tr -dc 'a-zA-Z'"
    echo "  $(echo 'Hello World!' | tr -dc 'a-zA-Z')"
    
    wait_for_user
    
    print_subheader "Use Case: Numărare cuvinte"
    
    TEXT="Aceasta este o propoziție cu mai multe cuvinte."
    
    print_code "echo '\$TEXT' | tr ' ' '\\n' | wc -l"
    echo "  $(echo "$TEXT" | tr ' ' '\n' | wc -l) cuvinte"
    
    print_explanation "tr ' ' '\\n' transformă spațiile în newlines"
    
    wait_for_user
    
    # Capcana tr vs sed
    print_subheader "⚠️ CAPCANA: tr nu înlocuiește stringuri!"
    
    echo -e "${RED}GREȘIT - încercare de a înlocui string:${RESET}"
    print_code "echo 'hello' | tr 'ell' 'XXX'"
    echo "  $(echo 'hello' | tr 'ell' 'XXX')"
    print_explanation "tr mapează: e→X, l→X, l→X (caracter cu caracter!)"
    
    echo ""
    echo -e "${GREEN}CORECT - folosește sed pentru stringuri:${RESET}"
    print_code "echo 'hello' | sed 's/ell/XXX/'"
    echo "  $(echo 'hello' | sed 's/ell/XXX/')"
    
    wait_for_user
}

#
# DEMO 6: WC - NUMĂRARE
#
demo_wc() {
    print_header "🔢 DEMO 6: WC - WORD COUNT"
    create_test_files
    
    print_subheader "Output complet"
    
    print_code "wc studenti.csv"
    echo "  $(wc studenti.csv)"
    
    echo ""
    echo -e "${DIM}Format: linii   cuvinte   bytes   fișier${RESET}"
    
    wait_for_user
    
    print_subheader "Opțiuni specifice"
    
    echo -e "${CYAN}-l${RESET} = linii (lines)"
    print_code "wc -l studenti.csv"
    echo "  $(wc -l < studenti.csv) linii"
    
    echo ""
    echo -e "${CYAN}-w${RESET} = cuvinte (words)"
    print_code "wc -w text.txt"
    echo "  $(wc -w < text.txt) cuvinte"
    
    echo ""
    echo -e "${CYAN}-c${RESET} = bytes"
    print_code "wc -c studenti.csv"
    echo "  $(wc -c < studenti.csv) bytes"
    
    echo ""
    echo -e "${CYAN}-m${RESET} = caractere (poate diferi de -c pentru UTF-8)"
    print_code "wc -m studenti.csv"
    echo "  $(wc -m < studenti.csv) caractere"
    
    wait_for_user
    
    print_subheader "Use Cases practice"
    
    echo -e "${YELLOW}Număr fișiere într-un director:${RESET}"
    print_code "ls -1 /etc | wc -l"
    echo "  $(ls -1 /etc 2>/dev/null | wc -l) fișiere"
    
    echo ""
    echo -e "${YELLOW}Număr procese active:${RESET}"
    print_code "ps aux | wc -l"
    echo "  $(($(ps aux | wc -l) - 1)) procese (minus header)"
    
    echo ""
    echo -e "${YELLOW}Lungime cea mai mare linie:${RESET}"
    print_code "wc -L studenti.csv"
    echo "  $(wc -L < studenti.csv) caractere (linia cea mai lungă)"
    
    wait_for_user
}

#
# DEMO 7: HEAD & TAIL
#
demo_head_tail() {
    print_header "📄 DEMO 7: HEAD & TAIL"
    create_test_files
    
    print_subheader "head - Primele linii"
    
    print_code "head -3 studenti.csv"
    head -3 studenti.csv | sed 's/^/  /'
    
    echo ""
    print_code "head -1 studenti.csv    # Prima linie"
    head -1 studenti.csv | sed 's/^/  /'
    
    wait_for_user
    
    print_subheader "tail - Ultimele linii"
    
    print_code "tail -3 studenti.csv"
    tail -3 studenti.csv | sed 's/^/  /'
    
    echo ""
    print_code "tail -1 studenti.csv    # Ultima linie"
    tail -1 studenti.csv | sed 's/^/  /'
    
    wait_for_user
    
    print_subheader "Combinație: Extragere din mijloc"
    
    echo -e "${BLUE}Pentru a lua liniile 3-5:${RESET}"
    print_code "head -5 studenti.csv | tail -3"
    head -5 studenti.csv | tail -3 | sed 's/^/  /'
    
    print_explanation "head -5 ia primele 5 linii, tail -3 ia ultimele 3 din acestea"
    
    wait_for_user
    
    print_subheader "Notație + (de la linia N)"
    
    print_code "tail -n +3 studenti.csv    # De la linia 3 până la final"
    tail -n +3 studenti.csv | sed 's/^/  /'
    
    print_explanation "+N înseamnă 'începând de la linia N'"
    
    wait_for_user
    
    print_subheader "⭐ tail -f - Monitorizare live"
    
    echo -e "${YELLOW}tail -f urmărește un fișier în timp real (ex: logs)${RESET}"
    echo ""
    
    print_code "tail -f /var/log/syslog    # Monitorizare log sistem"
    
    echo -e "${DIM}Demonstrație scurtă:${RESET}"
    
    # Simulare log
    (
        for i in 1 2 3; do
            echo "[$(date '+%H:%M:%S')] Event $i" >> demo.log
            sleep 0.5
        done
    ) &
    
    timeout 2 tail -f demo.log 2>/dev/null | head -3 | sed 's/^/  /' || true
    wait 2>/dev/null
    
    print_tip "Folosește Ctrl+C pentru a opri tail -f"
    
    wait_for_user
}

#
# DEMO 8: PIPELINE-URI COMPLEXE
#
demo_pipelines() {
    print_header "🔗 DEMO 8: PIPELINE-URI COMPLEXE"
    create_test_files
    
    print_subheader "Exemplul 1: Top IP-uri din access log"
    
    echo -e "${BLUE}access.log:${RESET}"
    cat access.log | sed 's/^/  /'
    echo ""
    
    print_code "cut -d' ' -f1 access.log | sort | uniq -c | sort -rn"
    
    echo -e "${CYAN}Pas cu pas:${RESET}"
    echo -e "  ${DIM}cut -d' ' -f1${RESET}  → extrage IP-urile"
    echo -e "  ${DIM}sort${RESET}           → grupează IP-urile identice"
    echo -e "  ${DIM}uniq -c${RESET}        → numără aparițiile"
    echo -e "  ${DIM}sort -rn${RESET}       → sortează descrescător"
    echo ""
    
    echo -e "${BLUE}Rezultat:${RESET}"
    cut -d' ' -f1 access.log | sort | uniq -c | sort -rn | sed 's/^/  /'
    
    wait_for_user
    
    print_subheader "Exemplul 2: Status codes din log"
    
    print_code "awk '{print \$9}' access.log | sort | uniq -c | sort -rn"
    echo -e "${BLUE}Rezultat (frecvența codurilor HTTP):${RESET}"
    awk '{print $9}' access.log | sort | uniq -c | sort -rn | sed 's/^/  /'
    
    wait_for_user
    
    print_subheader "Exemplul 3: Analiza completă procese"
    
    print_code "ps aux | awk 'NR>1 {print \$1}' | sort | uniq -c | sort -rn | head -5"
    echo -e "${BLUE}Top 5 useri după număr de procese:${RESET}"
    ps aux | awk 'NR>1 {print $1}' | sort | uniq -c | sort -rn | head -5 | sed 's/^/  /'
    
    wait_for_user
    
    print_subheader "Exemplul 4: Frecvență cuvinte într-un text"
    
    echo "The quick brown fox jumps over the lazy dog. The dog sleeps." > sample.txt
    
    print_code "tr ' ' '\\n' < sample.txt | tr -d '.' | tr 'A-Z' 'a-z' | sort | uniq -c | sort -rn"
    
    echo -e "${CYAN}Pipeline:${RESET}"
    echo "  tr ' ' '\\n'    → cuvinte pe linii separate"
    echo "  tr -d '.'       → elimină punctuația"
    echo "  tr 'A-Z' 'a-z'  → lowercase"
    echo "  sort | uniq -c  → numără"
    echo "  sort -rn        → ordonează"
    echo ""
    
    echo -e "${BLUE}Rezultat:${RESET}"
    tr ' ' '\n' < sample.txt | tr -d '.' | tr 'A-Z' 'a-z' | sort | uniq -c | sort -rn | sed 's/^/  /'
    
    wait_for_user
    
    print_subheader "Diagrama mentală pentru pipeline-uri"
    
    cat << 'DIAGRAM'
    
    ┌────────────────────────────────────────────────────────────────┐
    │  PATTERN UNIVERSAL pentru analiză frecvență:                   │
    │                                                                │
    │  [extrage date] | sort | uniq -c | sort -rn | head            │
    │       ↓            ↓        ↓          ↓         ↓            │
    │    ce ne         grupează   numără   ordonează  limitează     │
    │  interesează     identice            desc.      top N         │
    └────────────────────────────────────────────────────────────────┘

DIAGRAM
    
    wait_for_user
}

#
# DEMO 9: EXERCIȚIU INTEGRAT
#
demo_integrated() {
    print_header "🎯 DEMO 9: EXERCIȚIU INTEGRAT"
    create_test_files
    
    print_subheader "Scenariul: Raport automat pentru studenți"
    
    echo -e "${WHITE}Din studenti.csv, generăm un raport:${RESET}"
    echo "  1. Studenții ordonați după notă (descrescător)"
    echo "  2. Media notelor"
    echo "  3. Numărul de studenți per facultate"
    echo ""
    
    echo -e "${BLUE}studenti.csv:${RESET}"
    cat studenti.csv | sed 's/^/  /'
    
    wait_for_user
    
    print_subheader "1. Top studenți după notă"
    
    print_code "sort -t',' -k3 -rn studenti.csv | head -3"
    echo -e "${BLUE}Top 3 studenți:${RESET}"
    sort -t',' -k3 -rn studenti.csv | head -3 | \
        awk -F',' '{printf "  %s %s - %.1f (%s)\n", $1, $2, $3, $4}'
    
    wait_for_user
    
    print_subheader "2. Media notelor"
    
    print_code "cut -d',' -f3 studenti.csv | awk '{s+=\$1} END {printf \"Media: %.2f\\n\", s/NR}'"
    cut -d',' -f3 studenti.csv | awk '{s+=$1} END {printf "  Media: %.2f\n", s/NR}'
    
    wait_for_user
    
    print_subheader "3. Studenți per facultate"
    
    print_code "cut -d',' -f4 studenti.csv | sort | uniq -c | sort -rn"
    echo -e "${BLUE}Distribuție:${RESET}"
    cut -d',' -f4 studenti.csv | sort | uniq -c | sort -rn | sed 's/^/  /'
    
    wait_for_user
    
    print_subheader "Script complet de raport"
    
    cat > raport.sh << 'SCRIPT'
#!/bin/bash
# Raport automat studenți

FILE="studenti.csv"

echo "=== RAPORT STUDENȚI ==="
echo "Data: $(date '+%Y-%m-%d %H:%M')"
echo ""

echo "--- TOP 3 STUDENȚI ---"
sort -t',' -k3 -rn "$FILE" | head -3 | \
    awk -F',' '{printf "%s %s: %.1f\n", $1, $2, $3}'
echo ""

echo "--- STATISTICI ---"
cut -d',' -f3 "$FILE" | awk '{s+=$1} END {printf "Media: %.2f\n", s/NR}'
echo "Total studenți: $(wc -l < "$FILE")"
echo ""

echo "--- DISTRIBUȚIE FACULTĂȚI ---"
cut -d',' -f4 "$FILE" | sort | uniq -c | sort -rn
SCRIPT
    chmod +x raport.sh
    
    echo -e "${CYAN}Conținut raport.sh:${RESET}"
    cat raport.sh | sed 's/^/  /'
    
    echo ""
    echo -e "${YELLOW}Rulare:${RESET}"
    ./raport.sh | sed 's/^/  /'
    
    wait_for_user
}

#
# MENIU PRINCIPAL
#
show_menu() {
    clear
    fancy_title "FILTERS"
    
    echo ""
    echo -e "${WHITE}Selectează un demo pentru a rula:${RESET}"
    echo ""
    echo -e "  ${CYAN}1${RESET})  sort - Sortare"
    echo -e "  ${CYAN}2${RESET})  ${WARNING} uniq - Capcana duplicatelor"
    echo -e "  ${CYAN}3${RESET})  cut - Extragere coloane"
    echo -e "  ${CYAN}4${RESET})  paste - Îmbinare fișiere"
    echo -e "  ${CYAN}5${RESET})  ${WARNING} tr - Translate caractere"
    echo -e "  ${CYAN}6${RESET})  wc - Word count"
    echo -e "  ${CYAN}7${RESET})  head & tail"
    echo -e "  ${CYAN}8${RESET})  ${STAR} Pipeline-uri complexe"
    echo -e "  ${CYAN}9${RESET})  ${STAR} Exercițiu integrat"
    echo ""
    echo -e "  ${CYAN}a${RESET})  Rulează TOATE demo-urile"
    echo -e "  ${CYAN}q${RESET})  Ieșire"
    echo ""
    echo -n "Alegerea ta: "
}

run_all_demos() {
    demo_sort
    demo_uniq
    demo_cut
    demo_paste
    demo_tr
    demo_wc
    demo_head_tail
    demo_pipelines
    demo_integrated
    
    print_header "🎉 TOATE DEMO-URILE COMPLETATE!"
    
    echo -e "${GREEN}Felicitări! Ai parcurs toate filtrele de text.${RESET}"
    echo ""
    echo -e "${WHITE}Recapitulare:${RESET}"
    echo "  ${BULLET} sort: -n (numeric), -r (reverse), -k (coloană), -t (delimiter)"
    echo "  ${BULLET} uniq: DOAR consecutive! Folosește sort | uniq"
    echo "  ${BULLET} cut: -d (delimiter), -f (field), -c (caractere)"
    echo "  ${BULLET} paste: îmbinare, -d (delimiter), -s (serializare)"
    echo "  ${BULLET} tr: caractere, -d (delete), -s (squeeze), -c (complement)"
    echo "  ${BULLET} wc: -l (linii), -w (cuvinte), -c (bytes)"
    echo "  ${BULLET} head/tail: -n, tail -f (monitoring)"
    echo ""
    echo -e "${CYAN}Pattern universal:${RESET}"
    echo "  [extrage] | sort | uniq -c | sort -rn | head"
    echo ""
}

#
# MAIN
#
main() {
    case "${1:-menu}" in
        1) demo_sort ;;
        2) demo_uniq ;;
        3) demo_cut ;;
        4) demo_paste ;;
        5) demo_tr ;;
        6) demo_wc ;;
        7) demo_head_tail ;;
        8) demo_pipelines ;;
        9) demo_integrated ;;
        all|a) run_all_demos ;;
        menu|"")
            while true; do
                show_menu
                read -r choice
                case "$choice" in
                    1) demo_sort ;;
                    2) demo_uniq ;;
                    3) demo_cut ;;
                    4) demo_paste ;;
                    5) demo_tr ;;
                    6) demo_wc ;;
                    7) demo_head_tail ;;
                    8) demo_pipelines ;;
                    9) demo_integrated ;;
                    a|A) run_all_demos ;;
                    q|Q) 
                        echo -e "\n${GREEN}La revedere!${RESET}"
                        exit 0 
                        ;;
                    *) echo -e "${RED}Opțiune invalidă${RESET}" ;;
                esac
            done
            ;;
        *)
            echo "Utilizare: $0 [1-9|all|menu]"
            exit 1
            ;;
    esac
}

main "$@"
