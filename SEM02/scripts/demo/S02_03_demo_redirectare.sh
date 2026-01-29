#!/bin/bash
#
#  S02_03_demo_redirectare.sh - Demo Spectaculos Redirecționare I/O
#
# DESCRIERE:
#   Demonstrații vizuale pentru conceptele de redirecționare I/O:
#   - File descriptors (stdin=0, stdout=1, stderr=2)
#   - Redirecționare output (>, >>)
#   - Redirecționare stderr (2>, 2>>)
#   - Combinarea stream-urilor (2>&1, &>)
#   - Here documents (<<) și here strings (<<<)
#   - /dev/null și suprimarea output-ului
#   - tee pentru duplicare stream
#
# UTILIZARE:
#   ./S02_03_demo_redirectare.sh [demo_number]
#   ./S02_03_demo_redirectare.sh          # Rulează toate demo-urile
#   ./S02_03_demo_redirectare.sh 3        # Rulează doar demo #3
#   ./S02_03_demo_redirectare.sh menu     # Afișează meniu interactiv
#
# DEPENDENȚE:
#   - Obligatorii: bash 4.0+, coreutils
#   - Opționale: figlet, lolcat, pv, dialog (pentru efecte vizuale)
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
    
    # Simboluri
    CHECK="✓"
    CROSS="✗"
    ARROW="→"
    PIPE_SYM="│"
    BULLET="•"
    STAR="★"
else
    RED='' GREEN='' YELLOW='' BLUE='' MAGENTA='' CYAN='' WHITE=''
    DIM='' BOLD='' RESET=''
    CHECK="[OK]" CROSS="[X]" ARROW="->" PIPE_SYM="|" BULLET="*" STAR="*"
fi

#
# DIRECTOARE DE LUCRU
#
DEMO_DIR="${TMPDIR:-/tmp}/demo_redirect_$$"
mkdir -p "$DEMO_DIR"
cd "$DEMO_DIR"

# Cleanup la ieșire
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

print_output() {
    echo -e "${BLUE}  Output: ${WHITE}$1${RESET}"
}

print_explanation() {
    echo -e "${MAGENTA}  ${BULLET} $1${RESET}"
}

wait_for_user() {
    echo ""
    echo -e "${DIM}Apasă ENTER pentru a continua...${RESET}"
    read -r
}

type_effect() {
    local text="$1"
    local delay="${2:-0.03}"
    
    for ((i=0; i<${#text}; i++)); do
        printf "%s" "${text:$i:1}"
        sleep "$delay"
    done
    echo ""
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
# DEMO 1: FILE DESCRIPTORS - FUNDAMENTE
#
demo_file_descriptors() {
    print_header "📁 DEMO 1: FILE DESCRIPTORS - FUNDAMENTE"
    
    echo -e "${WHITE}În Unix/Linux, fiecare proces are 3 canale I/O standard:${RESET}"
    echo ""
    
    # Diagrama ASCII
    cat << 'DIAGRAM'
    ┌─────────────────────────────────────────────────────────────┐
    │                     PROCES BASH                             │
    │                                                             │
    │  ┌──────────┐                          ┌──────────┐        │
    │  │ Keyboard │ ──▶ [FD 0: stdin]  ──▶   │          │        │
    │  └──────────┘                          │          │        │
    │                                        │  Script  │        │
    │  ┌──────────┐                          │    /     │        │
    │  │ Terminal │ ◀── [FD 1: stdout] ◀──   │  Proces  │        │
    │  │  (ecran) │                          │          │        │
    │  └──────────┘                          │          │        │
    │                                        │          │        │
    │  ┌──────────┐                          │          │        │
    │  │ Terminal │ ◀── [FD 2: stderr] ◀──   │          │        │
    │  │  (erori) │                          └──────────┘        │
    │  └──────────┘                                              │
    └─────────────────────────────────────────────────────────────┘
DIAGRAM

    echo ""
    print_subheader "Demonstrație practică"
    
    # Creăm un script de test
    cat > test_fd.sh << 'EOF'
#!/bin/bash
echo "Acesta este stdout (FD 1)"
echo "Aceasta este o eroare simulată" >&2
echo "Din nou stdout"
ls /director_inexistent 2>&1 | head -1
EOF
    chmod +x test_fd.sh
    
    print_code "echo 'mesaj' >&2   # Trimite la stderr (FD 2)"
    echo ""
    
    echo -e "${WHITE}Să vedem ce produce un script care scrie pe ambele canale:${RESET}"
    echo ""
    
    print_code "./test_fd.sh"
    echo -e "${BLUE}Output combinat:${RESET}"
    ./test_fd.sh 2>&1 || true
    
    wait_for_user
    
    # Verificare descriptori
    print_subheader "Verificare File Descriptors Activi"
    
    print_code "ls -la /proc/\$\$/fd"
    echo -e "${BLUE}File descriptors ale shell-ului curent:${RESET}"
    ls -la /proc/$$/fd 2>/dev/null | head -6 || echo "(nu este disponibil)"
    
    print_explanation "FD 0 ${ARROW} /dev/pts/X = stdin (terminal input)"
    print_explanation "FD 1 ${ARROW} /dev/pts/X = stdout (terminal output)"  
    print_explanation "FD 2 ${ARROW} /dev/pts/X = stderr (terminal errors)"
    print_explanation "FD 255 ${ARROW} folosit intern de bash"
    
    wait_for_user
}

#
# DEMO 2: REDIRECȚIONARE OUTPUT (>, >>)
#
demo_output_redirect() {
    print_header "📤 DEMO 2: REDIRECȚIONARE OUTPUT (>, >>)"
    
    print_subheader "Operatorul > (suprascrie)"
    
    print_code "echo 'Prima linie' > fisier.txt"
    echo "Prima linie" > fisier.txt
    echo -e "${BLUE}Conținut fisier.txt:${RESET}"
    cat fisier.txt
    
    echo ""
    print_code "echo 'A doua linie' > fisier.txt"
    echo "A doua linie" > fisier.txt
    echo -e "${BLUE}Conținut fisier.txt (după suprascrie):${RESET}"
    cat fisier.txt
    
    print_explanation "Observație: Prima linie a DISPĂRUT! > suprascrie tot conținutul"
    
    wait_for_user
    
    print_subheader "Operatorul >> (adaugă/append)"
    
    echo "Linia 1" > fisier.txt
    print_code "echo 'Linia 1' > fisier.txt    # Creare inițială"
    print_code "echo 'Linia 2' >> fisier.txt   # Adăugare"
    print_code "echo 'Linia 3' >> fisier.txt   # Adăugare"
    
    echo "Linia 2" >> fisier.txt
    echo "Linia 3" >> fisier.txt
    
    echo -e "${BLUE}Conținut fisier.txt:${RESET}"
    cat fisier.txt
    
    print_explanation ">> ADAUGĂ la sfârșitul fișierului, nu suprascrie"
    
    wait_for_user
    
    # Demonstrație vizuală cu animație
    print_subheader "Vizualizare Animată: > vs >>"
    
    rm -f demo.txt 2>/dev/null
    
    echo -e "${WHITE}Simulare: 3 scrieri cu >${RESET}"
    for i in 1 2 3; do
        echo "Scriere $i" > demo.txt
        echo -e "  ${YELLOW}echo 'Scriere $i' > demo.txt${RESET}"
        echo -e "  ${CYAN}Conținut: $(cat demo.txt)${RESET}"
        sleep 0.5
    done
    
    echo ""
    rm -f demo.txt
    
    echo -e "${WHITE}Simulare: 3 scrieri cu >>${RESET}"
    for i in 1 2 3; do
        echo "Scriere $i" >> demo.txt
        echo -e "  ${YELLOW}echo 'Scriere $i' >> demo.txt${RESET}"
        echo -e "  ${CYAN}Conținut: $(cat demo.txt | tr '\n' ' ')${RESET}"
        sleep 0.5
    done
    
    wait_for_user
}

#
# DEMO 3: REDIRECȚIONARE STDERR (2>, 2>>)
#
demo_stderr_redirect() {
    print_header "⚠️  DEMO 3: REDIRECȚIONARE STDERR (2>, 2>>)"
    
    print_subheader "Problema: stdout și stderr merg în același loc"
    
    print_code "ls /home /director_inexistent"
    echo -e "${BLUE}Output (ambele pe terminal):${RESET}"
    ls /home /director_inexistent 2>&1 || true
    
    print_explanation "Observă: atât lista din /home cât și eroarea apar amestecate"
    
    wait_for_user
    
    print_subheader "Soluția 1: Separare cu 2>"
    
    print_code "ls /home /director_inexistent 2> erori.txt"
    ls /home /director_inexistent 2> erori.txt || true
    
    echo -e "${GREEN}stdout (pe ecran):${RESET}"
    echo "  (lista de mai sus)"
    echo ""
    echo -e "${RED}stderr (în erori.txt):${RESET}"
    echo -e "  ${DIM}$(cat erori.txt)${RESET}"
    
    wait_for_user
    
    print_subheader "Soluția 2: Ambele în fișiere separate"
    
    print_code "ls /home /inexistent > output.txt 2> erori.txt"
    ls /home /director_inexistent > output.txt 2> erori.txt || true
    
    echo -e "${GREEN}output.txt:${RESET}"
    cat output.txt | sed 's/^/  /'
    echo ""
    echo -e "${RED}erori.txt:${RESET}"
    cat erori.txt | sed 's/^/  /'
    
    wait_for_user
    
    print_subheader "Diagrama flux"
    
    cat << 'DIAGRAM'
    
    ls /home /inexistent > output.txt 2> erori.txt
    
    ┌─────────┐
    │   ls    │
    │ /home   │──▶ stdout (FD 1) ──▶ output.txt  ✓ Lista fișiere
    │ /inex   │──▶ stderr (FD 2) ──▶ erori.txt   ✗ Mesaje eroare
    └─────────┘

DIAGRAM
    
    wait_for_user
}

#
# DEMO 4: COMBINAREA STREAM-URILOR (2>&1, &>)
#
demo_stream_combine() {
    print_header "🔀 DEMO 4: COMBINAREA STREAM-URILOR (2>&1, &>)"
    
    print_subheader "Sintaxa 2>&1 - Redirect stderr la stdout"
    
    echo -e "${WHITE}Ce înseamnă ${CYAN}2>&1${WHITE}?${RESET}"
    echo ""
    echo "  2  = stderr (file descriptor 2)"
    echo "  >  = redirecționează"
    echo "  &1 = la destinația lui FD 1 (stdout)"
    echo ""
    
    print_code "ls /home /inexistent > combined.txt 2>&1"
    ls /home /director_inexistent > combined.txt 2>&1 || true
    
    echo -e "${BLUE}combined.txt conține AMBELE:${RESET}"
    cat combined.txt | sed 's/^/  /'
    
    wait_for_user
    
    print_subheader "⚠️  Capcană: ORDINEA CONTEAZĂ!"
    
    echo -e "${RED}GREȘIT:${RESET}"
    print_code "ls /home /inexistent 2>&1 > combined.txt"
    ls /home /director_inexistent 2>&1 > wrong.txt || true
    echo -e "${DIM}Eroarea apare PE ECRAN, nu în fișier!${RESET}"
    echo -e "  Fișierul conține doar: $(cat wrong.txt 2>/dev/null | head -1)"
    
    echo ""
    echo -e "${GREEN}CORECT:${RESET}"
    print_code "ls /home /inexistent > combined.txt 2>&1"
    echo -e "${DIM}Totul merge în fișier.${RESET}"
    
    wait_for_user
    
    # Diagrama explicativă
    print_subheader "De ce contează ordinea?"
    
    cat << 'DIAGRAM'
    
    GREȘIT: cmd 2>&1 > file
    ─────────────────────────────────────────────────────
    Pas 1: 2>&1   → stderr merge unde era stdout (ecran)
    Pas 2: > file → stdout merge în fișier
    Rezultat: stderr TOT pe ecran, doar stdout în fișier
    
    CORECT: cmd > file 2>&1
    ─────────────────────────────────────────────────────
    Pas 1: > file → stdout merge în fișier
    Pas 2: 2>&1   → stderr merge unde e stdout ACUM (fișier)
    Rezultat: AMBELE în fișier ✓

DIAGRAM
    
    wait_for_user
    
    print_subheader "Prescurtare: &> (bash 4+)"
    
    print_code "ls /home /inexistent &> combined.txt"
    echo -e "${DIM}&> este echivalent cu > file 2>&1${RESET}"
    
    ls /home /director_inexistent &> combined_short.txt || true
    echo -e "${BLUE}Rezultat identic:${RESET}"
    cat combined_short.txt | sed 's/^/  /'
    
    wait_for_user
}

#
# DEMO 5: REDIRECȚIONARE INPUT (<)
#
demo_input_redirect() {
    print_header "📥 DEMO 5: REDIRECȚIONARE INPUT (<)"
    
    # Pregătire fișier test
    cat > numere.txt << 'EOF'
42
7
100
23
85
EOF
    
    print_subheader "Operatorul < (input din fișier)"
    
    print_code "sort < numere.txt"
    echo -e "${BLUE}Fișier numere.txt:${RESET}"
    cat numere.txt | sed 's/^/  /'
    echo ""
    echo -e "${BLUE}Rezultat sort < numere.txt:${RESET}"
    sort -n < numere.txt | sed 's/^/  /'
    
    print_explanation "< citește din fișier în loc de stdin (tastatură)"
    
    wait_for_user
    
    print_subheader "< vs cat | - Care e mai bun?"
    
    echo -e "${YELLOW}Metodă 1: Redirecționare (recomandată)${RESET}"
    print_code "wc -l < numere.txt"
    echo -e "  Rezultat: $(wc -l < numere.txt)"
    
    echo ""
    echo -e "${YELLOW}Metodă 2: cat și pipe (funcțional dar redundant)${RESET}"
    print_code "cat numere.txt | wc -l"
    echo -e "  Rezultat: $(cat numere.txt | wc -l)"
    
    echo ""
    print_explanation "Ambele funcționează, dar < este mai eficient"
    print_explanation "cat | wc creează un proces suplimentar inutil"
    print_explanation "Aceasta e \"Useless Use of Cat\" - anti-pattern comun"
    
    wait_for_user
    
    # Demonstrație vizuală procese
    print_subheader "Diferența de procese"
    
    cat << 'DIAGRAM'
    
    wc -l < file
    ─────────────────────────
    Shell citește fișierul
           ↓
       [wc -l]  ← 1 proces
           ↓
        Rezultat
    
    
    cat file | wc -l
    ─────────────────────────
       [cat]   ← 1 proces
         │
       pipe
         │
       [wc -l] ← 1 proces
         ↓         
       Rezultat (2 procese total!)

DIAGRAM
    
    wait_for_user
}

#
# DEMO 6: HERE DOCUMENTS (<<)
#
demo_here_documents() {
    print_header "📜 DEMO 6: HERE DOCUMENTS (<<)"
    
    print_subheader "Ce este un Here Document?"
    
    echo -e "${WHITE}Un bloc de text multi-linie încorporat direct în script.${RESET}"
    echo ""
    
    print_code "cat << EOF
Aceasta este
o configurare
multi-linie
EOF"
    
    echo -e "${BLUE}Rezultat:${RESET}"
    cat << EOF
  Aceasta este
  o configurare
  multi-linie
EOF
    
    wait_for_user
    
    print_subheader "Use Case: Generare fișier de configurare"
    
    USERNAME="student"
    SERVER="192.168.1.100"
    
    print_code 'cat > config.conf << EOF
# Configurare generată automat
user=$USERNAME
server=$SERVER
port=22
EOF'
    
    cat > config.conf << EOF
# Configurare generată automat
user=$USERNAME
server=$SERVER
port=22
EOF
    
    echo -e "${BLUE}Conținut config.conf:${RESET}"
    cat config.conf | sed 's/^/  /'
    
    print_explanation "Variabilele sunt expandate! (\$USERNAME → $USERNAME)"
    
    wait_for_user
    
    print_subheader "Blocarea expansiunii cu 'EOF'"
    
    print_code "cat << 'EOF'    # Ghilimele în jurul delimiter-ului"
    
    cat > literal.txt << 'EOF'
Variabilele NU sunt expandate:
$USER = $USER
$HOME = $HOME
$(date) = $(date)
EOF
    
    echo -e "${BLUE}Cu << 'EOF' (literal):${RESET}"
    cat literal.txt | sed 's/^/  /'
    
    print_explanation "Cu 'EOF' în ghilimele, \$ și \$() rămân literale"
    
    wait_for_user
    
    print_subheader "Here Document cu Indentare: <<-"
    
    print_code '    cat <<-EOF
    	Acest text
    	poate fi indentat
    	cu TAB-uri
    	EOF'
    
    echo -e "${DIM}(<<- permite indentare cu TAB pentru cod mai curat în scripturi)${RESET}"
    
    wait_for_user
}

#
# DEMO 7: HERE STRINGS (<<<)
#
demo_here_strings() {
    print_header "📝 DEMO 7: HERE STRINGS (<<<)"
    
    print_subheader "Ce este un Here String?"
    
    echo -e "${WHITE}O modalitate de a pasa un string direct ca input la o comandă.${RESET}"
    echo ""
    
    print_code 'wc -w <<< "Aceasta este o propoziție"'
    echo -e "${BLUE}Rezultat:${RESET}"
    echo "  $(wc -w <<< "Aceasta este o propoziție") cuvinte"
    
    wait_for_user
    
    print_subheader "<<< vs echo | - Comparație"
    
    echo -e "${YELLOW}Metodă 1: Here String (elegantă)${RESET}"
    print_code 'tr a-z A-Z <<< "hello world"'
    echo "  Rezultat: $(tr a-z A-Z <<< "hello world")"
    
    echo ""
    echo -e "${YELLOW}Metodă 2: echo și pipe (clasică)${RESET}"
    print_code 'echo "hello world" | tr a-z A-Z'
    echo "  Rezultat: $(echo "hello world" | tr a-z A-Z)"
    
    print_explanation "<<< evită crearea unui proces separat pentru echo"
    
    wait_for_user
    
    print_subheader "Use Case Practic: Parsing rapid"
    
    DATA="John:Doe:42:Bucharest"
    
    print_code 'IFS=: read -r first last age city <<< "$DATA"'
    IFS=: read -r first last age city <<< "$DATA"
    
    echo -e "${BLUE}Din string-ul: $DATA${RESET}"
    echo "  First name: $first"
    echo "  Last name:  $last"
    echo "  Age:        $age"
    echo "  City:       $city"
    
    wait_for_user
}

#
# DEMO 8: /dev/null - GAURA NEAGRĂ
#
demo_dev_null() {
    print_header "🕳️  DEMO 8: /dev/null - GAURA NEAGRĂ"
    
    print_subheader "Ce este /dev/null?"
    
    cat << 'DIAGRAM'
    
    ┌─────────────────────────────────────────────────────────────┐
    │                                                             │
    │     /dev/null = un fișier special care:                     │
    │                                                             │
    │     • ÎNGHITE tot ce primește (write → dispare)             │
    │     • PRODUCE nimic când citești (read → EOF imediat)       │
    │                                                             │
    │     ┌─────────┐          ┌────────────┐                     │
    │     │  date   │ ──────▶  │ /dev/null  │ ──▶ ∅ (nimic)       │
    │     └─────────┘          │   🕳️        │                     │
    │                          └────────────┘                     │
    │                                                             │
    └─────────────────────────────────────────────────────────────┘

DIAGRAM
    
    wait_for_user
    
    print_subheader "Use Case 1: Suprimă output nedorit"
    
    print_code "find /etc -name '*.conf' 2>/dev/null | head -3"
    echo -e "${BLUE}Fără erori de permisiune:${RESET}"
    find /etc -name "*.conf" 2>/dev/null | head -3 | sed 's/^/  /'
    
    print_explanation "Erorile 'Permission denied' sunt aruncate în /dev/null"
    
    wait_for_user
    
    print_subheader "Use Case 2: Testare silențioasă"
    
    print_code "if command -v nano &>/dev/null; then echo 'nano există'; fi"
    
    if command -v nano &>/dev/null; then
        echo -e "  ${GREEN}${CHECK} nano există${RESET}"
    else
        echo -e "  ${RED}${CROSS} nano nu există${RESET}"
    fi
    
    if command -v program_inexistent &>/dev/null; then
        echo -e "  ${GREEN}${CHECK} program_inexistent există${RESET}"
    else
        echo -e "  ${RED}${CROSS} program_inexistent nu există${RESET}"
    fi
    
    print_explanation "&>/dev/null suprimă AMBELE stdout și stderr"
    
    wait_for_user
    
    print_subheader "Use Case 3: Input vid"
    
    print_code "cat /dev/null > fisier_gol.txt"
    cat /dev/null > fisier_gol.txt
    
    echo -e "${BLUE}Dimensiune fisier_gol.txt: $(wc -c < fisier_gol.txt) bytes${RESET}"
    
    print_explanation "Alternativă pentru > fisier.txt sau : > fisier.txt"
    
    wait_for_user
    
    print_subheader "Pattern-uri Comune cu /dev/null"
    
    echo ""
    echo "  ${YELLOW}1)${RESET} Ignoră stdout:     ${CYAN}cmd > /dev/null${RESET}"
    echo "  ${YELLOW}2)${RESET} Ignoră stderr:     ${CYAN}cmd 2>/dev/null${RESET}"
    echo "  ${YELLOW}3)${RESET} Ignoră ambele:     ${CYAN}cmd &>/dev/null${RESET}"
    echo "  ${YELLOW}4)${RESET} Golește fișier:    ${CYAN}cat /dev/null > file${RESET}"
    echo "  ${YELLOW}5)${RESET} Test existență:    ${CYAN}command -v cmd &>/dev/null${RESET}"
    
    wait_for_user
}

#
# DEMO 9: TEE - DUPLICARE STREAM
#
demo_tee() {
    print_header "🔀 DEMO 9: TEE - DUPLICARE STREAM"
    
    print_subheader "Ce face tee?"
    
    cat << 'DIAGRAM'
    
                          ┌──────────────┐
                    ┌────▶│ fisier.txt   │
    ┌─────────┐     │     └──────────────┘
    │  Input  │─────┤
    │ (stdin) │     │     ┌──────────────┐
    └─────────┘     └────▶│    stdout    │──▶ următoarea comandă
                          │   (ecran)    │    sau terminal
                          └──────────────┘
    
    "tee" = ca un T în instalații de apă

DIAGRAM
    
    wait_for_user
    
    print_subheader "Exemplu de bază"
    
    print_code "echo 'Date importante' | tee backup.txt"
    echo "Date importante" | tee backup.txt
    
    echo ""
    echo -e "${BLUE}backup.txt conține:${RESET}"
    cat backup.txt | sed 's/^/  /'
    
    print_explanation "Output-ul apare PE ECRAN și e salvat în fișier simultan"
    
    wait_for_user
    
    print_subheader "Use Case: Debugging Pipelines"
    
    print_code 'ps aux | tee debug1.txt | grep "bash" | tee debug2.txt | wc -l'
    
    count=$(ps aux | tee debug1.txt | grep "bash" | tee debug2.txt | wc -l)
    echo -e "${BLUE}Rezultat final: $count linii cu 'bash'${RESET}"
    
    echo ""
    echo -e "${DIM}debug1.txt: $(wc -l < debug1.txt) linii (toate procesele)${RESET}"
    echo -e "${DIM}debug2.txt: $(wc -l < debug2.txt) linii (doar bash)${RESET}"
    
    print_explanation "tee permite 'interceptarea' datelor în fiecare pas"
    
    wait_for_user
    
    print_subheader "Opțiunea -a (append)"
    
    print_code "echo 'Linia 1' | tee log.txt"
    print_code "echo 'Linia 2' | tee -a log.txt"
    
    echo "Linia 1" | tee log.txt > /dev/null
    echo "Linia 2" | tee -a log.txt > /dev/null
    
    echo -e "${BLUE}log.txt:${RESET}"
    cat log.txt | sed 's/^/  /'
    
    print_explanation "-a = append, păstrează conținutul existent"
    
    wait_for_user
    
    print_subheader "tee cu multiple fișiere"
    
    print_code "echo 'Mesaj' | tee file1.txt file2.txt file3.txt"
    echo "Mesaj comun" | tee f1.txt f2.txt f3.txt > /dev/null
    
    echo -e "${BLUE}Toate fișierele conțin același text:${RESET}"
    echo "  f1.txt: $(cat f1.txt)"
    echo "  f2.txt: $(cat f2.txt)"
    echo "  f3.txt: $(cat f3.txt)"
    
    wait_for_user
}

#
# DEMO 10: EXEMPLU INTEGRAT
#
demo_integrated() {
    print_header "🎯 DEMO 10: EXEMPLU INTEGRAT - SISTEM DE LOGGING"
    
    print_subheader "Scenariul: Sistem de procesare cu logging complet"
    
    echo -e "${WHITE}Vom crea un script care:${RESET}"
    echo "  1. Procesează date din mai multe surse"
    echo "  2. Loghează stdout și stderr separat"
    echo "  3. Păstrează un log combinat pentru audit"
    echo "  4. Afișează progresul în timp real"
    echo ""
    
    # Creare script
    cat > processor.sh << 'SCRIPT'
#!/bin/bash
# Sistem de procesare cu logging

LOG_DIR="./logs"
mkdir -p "$LOG_DIR"

{
    echo "=== Procesare începută: $(date) ==="
    
    echo "[INFO] Verificare sistem..."
    uname -a
    
    echo "[INFO] Căutare fișiere configurare..."
    find /etc -maxdepth 1 -name "*.conf" 2>&1 | head -5
    
    echo "[INFO] Încercare acces restricționat..."
    cat /etc/shadow 2>&1 || true
    
    echo "[INFO] Statistici disk..."
    df -h / 2>/dev/null | tail -1
    
    echo "=== Procesare finalizată: $(date) ==="
    
} 2>&1 | tee "$LOG_DIR/combined.log" | \
  grep -E "^\[INFO\]" | tee "$LOG_DIR/info.log"
SCRIPT
    chmod +x processor.sh
    
    print_code "# Script-ul processor.sh"
    echo -e "${DIM}$(head -15 processor.sh)${RESET}"
    echo -e "${DIM}...${RESET}"
    
    wait_for_user
    
    print_subheader "Execuție și rezultate"
    
    echo -e "${YELLOW}Rulare processor.sh:${RESET}"
    echo ""
    ./processor.sh || true
    
    echo ""
    echo -e "${BLUE}Fișiere log create:${RESET}"
    ls -la logs/
    
    wait_for_user
    
    print_subheader "Examinare loguri"
    
    echo -e "${GREEN}info.log (doar mesaje INFO):${RESET}"
    cat logs/info.log | head -5 | sed 's/^/  /'
    
    echo ""
    echo -e "${YELLOW}combined.log (tot output-ul):${RESET}"
    head -10 logs/combined.log | sed 's/^/  /'
    echo -e "  ${DIM}... ($(wc -l < logs/combined.log) linii total)${RESET}"
    
    wait_for_user
}

#
# DEMO BONUS: PROGRESS BAR CU PV
#
demo_progress_bar() {
    print_header "⏳ DEMO BONUS: PROGRESS BAR CU PV"
    
    if ! command -v pv &>/dev/null; then
        echo -e "${YELLOW}pv nu este instalat. Instalează cu: sudo apt install pv${RESET}"
        echo ""
        echo -e "${DIM}Demonstrație simulată:${RESET}"
        
        # Simulare progress bar
        echo -n "Procesare: ["
        for i in $(seq 1 50); do
            echo -n "#"
            sleep 0.05
        done
        echo "] 100%"
        
        return
    fi
    
    print_subheader "pv = Pipe Viewer - progres vizual pentru operații I/O"
    
    print_code "pv -s 10M /dev/urandom | head -c 10M > /tmp/test_file"
    echo -e "${BLUE}Generare 10MB de date aleatorii:${RESET}"
    pv -s 10M /dev/urandom 2>&1 | head -c 10M > /tmp/test_file_demo
    rm -f /tmp/test_file_demo
    
    wait_for_user
    
    print_subheader "Use Case: Monitorizare copiere fișiere"
    
    # Creăm un fișier de test
    dd if=/dev/urandom of=large_file.bin bs=1M count=5 2>/dev/null
    
    print_code "pv large_file.bin > copy.bin"
    pv large_file.bin > copy.bin 2>&1
    
    rm -f large_file.bin copy.bin
    
    wait_for_user
}

#
# MENIU PRINCIPAL
#
show_menu() {
    clear
    fancy_title "I/O REDIRECT"
    
    echo ""
    echo -e "${WHITE}Selectează un demo pentru a rula:${RESET}"
    echo ""
    echo -e "  ${CYAN}1${RESET})  File Descriptors - Fundamente"
    echo -e "  ${CYAN}2${RESET})  Redirecționare Output (>, >>)"
    echo -e "  ${CYAN}3${RESET})  Redirecționare stderr (2>, 2>>)"
    echo -e "  ${CYAN}4${RESET})  Combinare stream-uri (2>&1, &>)"
    echo -e "  ${CYAN}5${RESET})  Redirecționare Input (<)"
    echo -e "  ${CYAN}6${RESET})  Here Documents (<<)"
    echo -e "  ${CYAN}7${RESET})  Here Strings (<<<)"
    echo -e "  ${CYAN}8${RESET})  /dev/null - Gaura Neagră"
    echo -e "  ${CYAN}9${RESET})  tee - Duplicare Stream"
    echo -e "  ${CYAN}10${RESET}) Exemplu Integrat"
    echo -e "  ${CYAN}11${RESET}) ${STAR} Progress Bar cu pv"
    echo ""
    echo -e "  ${CYAN}a${RESET})  Rulează TOATE demo-urile"
    echo -e "  ${CYAN}q${RESET})  Ieșire"
    echo ""
    echo -n "Alegerea ta: "
}

run_all_demos() {
    demo_file_descriptors
    demo_output_redirect
    demo_stderr_redirect
    demo_stream_combine
    demo_input_redirect
    demo_here_documents
    demo_here_strings
    demo_dev_null
    demo_tee
    demo_integrated
    demo_progress_bar
    
    print_header "🎉 TOATE DEMO-URILE COMPLETATE!"
    echo -e "${GREEN}Felicitări! Ai parcurs toate conceptele de redirecționare I/O.${RESET}"
    echo ""
    echo -e "${WHITE}Recapitulare:${RESET}"
    echo "  ${BULLET} File Descriptors: 0=stdin, 1=stdout, 2=stderr"
    echo "  ${BULLET} Output: > (suprascrie), >> (adaugă)"
    echo "  ${BULLET} Stderr: 2>, 2>>, 2>&1, &>"
    echo "  ${BULLET} Input: <, <<, <<<"
    echo "  ${BULLET} Suprimare: /dev/null"
    echo "  ${BULLET} Duplicare: tee, tee -a"
    echo ""
}

#
# MAIN
#
main() {
    case "${1:-menu}" in
        1) demo_file_descriptors ;;
        2) demo_output_redirect ;;
        3) demo_stderr_redirect ;;
        4) demo_stream_combine ;;
        5) demo_input_redirect ;;
        6) demo_here_documents ;;
        7) demo_here_strings ;;
        8) demo_dev_null ;;
        9) demo_tee ;;
        10) demo_integrated ;;
        11) demo_progress_bar ;;
        all|a) run_all_demos ;;
        menu|"")
            while true; do
                show_menu
                read -r choice
                case "$choice" in
                    1) demo_file_descriptors ;;
                    2) demo_output_redirect ;;
                    3) demo_stderr_redirect ;;
                    4) demo_stream_combine ;;
                    5) demo_input_redirect ;;
                    6) demo_here_documents ;;
                    7) demo_here_strings ;;
                    8) demo_dev_null ;;
                    9) demo_tee ;;
                    10) demo_integrated ;;
                    11) demo_progress_bar ;;
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
            echo "Utilizare: $0 [1-11|all|menu]"
            exit 1
            ;;
    esac
}

main "$@"
