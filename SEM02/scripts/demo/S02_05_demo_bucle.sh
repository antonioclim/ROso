#!/bin/bash
#
#  S02_05_demo_bucle.sh - Demo Spectaculos Bucle Bash
#
# DESCRIERE:
#   Demonstrații vizuale pentru buclele Bash:
#   - for (listă, brace expansion, glob, C-style)
#   - while (condiție, read, infinite loops)
#   - until (inversul lui while)
#   - break și continue (control flow)
#   - CAPCANE FRECVENTE:
#     * {1..$N} cu variabile (NU funcționează!)
#     * Problema subshell cu pipe | while read
#
# UTILIZARE:
#   ./S02_05_demo_bucle.sh [demo_number]
#   ./S02_05_demo_bucle.sh          # Rulează toate demo-urile
#   ./S02_05_demo_bucle.sh menu     # Afișează meniu interactiv
#
# DEPENDENȚE:
#   - Obligatorii: bash 4.0+
#   - Opționale: figlet, lolcat, pv (pentru efecte vizuale)
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
    BG_YELLOW='\033[43m'
    
    CHECK="✓"
    CROSS="✗"
    ARROW="→"
    BULLET="•"
    STAR="★"
    WARNING="⚠️"
    LOOP="🔄"
else
    RED='' GREEN='' YELLOW='' BLUE='' MAGENTA='' CYAN='' WHITE=''
    DIM='' BOLD='' RESET='' BG_RED='' BG_GREEN='' BG_YELLOW=''
    CHECK="[OK]" CROSS="[X]" ARROW="->" BULLET="*" STAR="*" WARNING="[!]" LOOP="[O]"
fi

#
# DIRECTOARE DE LUCRU
#
DEMO_DIR="${TMPDIR:-/tmp}/demo_bucle_$$"
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

print_multiline_code() {
    echo -e "${DIM}┌─────────────────────────────────────────────────────────────────┐${RESET}"
    while IFS= read -r line; do
        echo -e "${GREEN}  $line${RESET}"
    done
    echo -e "${DIM}└─────────────────────────────────────────────────────────────────┘${RESET}"
}

print_warning() {
    echo -e "\n${BG_RED}${WHITE} ${WARNING} CAPCANĂ FRECVENTĂ ${RESET} ${RED}$1${RESET}\n"
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

animate_iteration() {
    local text="$1"
    local color="${2:-$GREEN}"
    echo -e "  ${color}${LOOP} Iterația: ${WHITE}$text${RESET}"
    sleep 0.3
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
# DEMO 1: FOR - ITERARE PESTE LISTĂ
#
demo_for_list() {
    print_header "🔄 DEMO 1: FOR - ITERARE PESTE LISTĂ"
    
    print_subheader "Sintaxa de bază"
    
    cat << 'SYNTAX'
    for variabila in lista_valori; do
        # comenzi
    done
SYNTAX
    
    echo ""
    
    print_subheader "Exemplu 1: Listă explicită"
    
    print_multiline_code << 'CODE'
for culoare in rosu verde albastru; do
    echo "Culoarea: $culoare"
done
CODE
    
    echo -e "${BLUE}Execuție:${RESET}"
    for culoare in rosu verde albastru; do
        animate_iteration "$culoare"
    done
    
    wait_for_user
    
    print_subheader "Exemplu 2: Listă din variabilă"
    
    print_multiline_code << 'CODE'
FRUCTE="mar para pruna"
for fruct in $FRUCTE; do
    echo "Fruct: $fruct"
done
CODE
    
    echo -e "${BLUE}Execuție:${RESET}"
    FRUCTE="mar para pruna"
    for fruct in $FRUCTE; do
        animate_iteration "$fruct"
    done
    
    wait_for_user
    
    print_subheader "Exemplu 3: Output comandă"
    
    print_multiline_code << 'CODE'
for user in $(cut -d: -f1 /etc/passwd | head -3); do
    echo "User: $user"
done
CODE
    
    echo -e "${BLUE}Execuție:${RESET}"
    for user in $(cut -d: -f1 /etc/passwd | head -3); do
        animate_iteration "$user"
    done
    
    wait_for_user
}

#
# DEMO 2: FOR - BRACE EXPANSION
#
demo_for_brace() {
    print_header "🔢 DEMO 2: FOR - BRACE EXPANSION {..}"
    
    print_subheader "Numere cu {start..end}"
    
    print_multiline_code << 'CODE'
for i in {1..5}; do
    echo "Număr: $i"
done
CODE
    
    echo -e "${BLUE}Execuție:${RESET}"
    for i in {1..5}; do
        animate_iteration "$i"
    done
    
    wait_for_user
    
    print_subheader "Cu pas: {start..end..step}"
    
    print_multiline_code << 'CODE'
for i in {0..10..2}; do
    echo "Par: $i"
done
CODE
    
    echo -e "${BLUE}Execuție (numere pare):${RESET}"
    for i in {0..10..2}; do
        animate_iteration "$i"
    done
    
    wait_for_user
    
    print_subheader "Descrescător"
    
    print_multiline_code << 'CODE'
for i in {5..1}; do
    echo "Countdown: $i"
done
echo "LANSARE! 🚀"
CODE
    
    echo -e "${BLUE}Execuție:${RESET}"
    for i in {5..1}; do
        animate_iteration "$i" "$YELLOW"
        sleep 0.2
    done
    echo -e "  ${GREEN}${STAR} LANSARE! 🚀${RESET}"
    
    wait_for_user
    
    print_subheader "Litere"
    
    print_multiline_code << 'CODE'
for letter in {a..e}; do
    echo "Litera: $letter"
done
CODE
    
    echo -e "${BLUE}Execuție:${RESET}"
    for letter in {a..e}; do
        animate_iteration "$letter"
    done
    
    wait_for_user
    
    # CAPCANA!
    print_warning "BRACE EXPANSION NU FUNCȚIONEAZĂ CU VARIABILE!"
    
    echo -e "${RED}Cod GREȘIT:${RESET}"
    print_multiline_code << 'CODE'
N=5
for i in {1..$N}; do    # NU FUNCȚIONEAZĂ!
    echo "$i"
done
CODE
    
    echo -e "${BLUE}Output surprinzător:${RESET}"
    N=5
    for i in {1..$N}; do
        echo -e "  ${RED}$i${RESET}"
    done
    
    echo ""
    print_explanation "Brace expansion se face ÎNAINTE de expansiunea variabilelor!"
    print_explanation "Bash vede literal {1..\$N}, nu știe că \$N=5"
    
    wait_for_user
    
    print_subheader "Soluții pentru variabile"
    
    echo -e "${GREEN}Soluția 1: seq${RESET}"
    print_multiline_code << 'CODE'
N=5
for i in $(seq 1 $N); do
    echo "$i"
done
CODE
    
    echo -e "${BLUE}Execuție:${RESET}"
    N=5
    for i in $(seq 1 $N); do
        animate_iteration "$i"
    done
    
    echo ""
    echo -e "${GREEN}Soluția 2: for C-style${RESET}"
    print_multiline_code << 'CODE'
N=5
for ((i=1; i<=N; i++)); do
    echo "$i"
done
CODE
    
    echo -e "${BLUE}Execuție:${RESET}"
    for ((i=1; i<=N; i++)); do
        animate_iteration "$i"
    done
    
    wait_for_user
}

#
# DEMO 3: FOR - GLOB (FIȘIERE)
#
demo_for_glob() {
    print_header "📁 DEMO 3: FOR - ITERARE PESTE FIȘIERE"
    
    # Creare fișiere test
    mkdir -p test_files
    touch test_files/doc1.txt test_files/doc2.txt test_files/image.png test_files/data.csv
    
    print_subheader "Iterare peste toate fișierele"
    
    print_multiline_code << 'CODE'
for file in test_files/*; do
    echo "Fișier: $file"
done
CODE
    
    echo -e "${BLUE}Execuție:${RESET}"
    for file in test_files/*; do
        animate_iteration "$(basename "$file")"
    done
    
    wait_for_user
    
    print_subheader "Doar anumite extensii (*.txt)"
    
    print_multiline_code << 'CODE'
for txt in test_files/*.txt; do
    echo "Document: $txt"
done
CODE
    
    echo -e "${BLUE}Execuție:${RESET}"
    for txt in test_files/*.txt; do
        animate_iteration "$(basename "$txt")"
    done
    
    wait_for_user
    
    print_subheader "Procesare fișiere - exemplu practic"
    
    # Adăugăm conținut în fișiere
    echo "Line 1" > test_files/doc1.txt
    echo -e "Line 1\nLine 2\nLine 3" > test_files/doc2.txt
    
    print_multiline_code << 'CODE'
for file in test_files/*.txt; do
    lines=$(wc -l < "$file")
    echo "$(basename "$file"): $lines linii"
done
CODE
    
    echo -e "${BLUE}Execuție:${RESET}"
    for file in test_files/*.txt; do
        lines=$(wc -l < "$file")
        echo -e "  ${CYAN}$(basename "$file")${RESET}: $lines linii"
    done
    
    wait_for_user
    
    print_subheader "⚠️ Capcană: Fișiere cu spații în nume"
    
    # Creare fișier cu spațiu
    touch "test_files/my document.txt"
    
    print_warning "Folosește ghilimele în jurul variabilei!"
    
    echo -e "${RED}GREȘIT:${RESET}"
    print_code 'for f in test_files/*; do cp $f backup/; done'
    print_explanation "Fișierul 'my document.txt' devine 'my' și 'document.txt'"
    
    echo ""
    echo -e "${GREEN}CORECT:${RESET}"
    print_code 'for f in test_files/*; do cp "$f" backup/; done'
    print_explanation "Ghilimelele păstrează spațiile"
    
    wait_for_user
}

#
# DEMO 4: FOR C-STYLE
#
demo_for_cstyle() {
    print_header "🔧 DEMO 4: FOR C-STYLE (( ))"
    
    print_subheader "Sintaxa"
    
    cat << 'SYNTAX'
    for ((inițializare; condiție; increment)); do
        # comenzi
    done
SYNTAX
    
    echo ""
    
    print_subheader "Exemplu clasic"
    
    print_multiline_code << 'CODE'
for ((i=1; i<=5; i++)); do
    echo "Iterația $i"
done
CODE
    
    echo -e "${BLUE}Execuție:${RESET}"
    for ((i=1; i<=5; i++)); do
        animate_iteration "$i"
    done
    
    wait_for_user
    
    print_subheader "Cu pas diferit"
    
    print_multiline_code << 'CODE'
for ((i=0; i<=20; i+=5)); do
    echo "Valoare: $i"
done
CODE
    
    echo -e "${BLUE}Execuție:${RESET}"
    for ((i=0; i<=20; i+=5)); do
        animate_iteration "$i"
    done
    
    wait_for_user
    
    print_subheader "Descrescător"
    
    print_multiline_code << 'CODE'
for ((i=10; i>=0; i-=2)); do
    printf "%2d " "$i"
done
echo ""
CODE
    
    echo -e "${BLUE}Execuție:${RESET}"
    echo -n "  "
    for ((i=10; i>=0; i-=2)); do
        printf "${CYAN}%2d ${RESET}" "$i"
        sleep 0.2
    done
    echo ""
    
    wait_for_user
    
    print_subheader "Cu variabile"
    
    print_multiline_code << 'CODE'
START=1
END=5
for ((i=START; i<=END; i++)); do
    echo "Număr: $i"
done
CODE
    
    echo -e "${BLUE}Execuție:${RESET}"
    START=1
    END=5
    for ((i=START; i<=END; i++)); do
        animate_iteration "$i"
    done
    
    print_tip "C-style for funcționează cu variabile, spre deosebire de {..}!"
    
    wait_for_user
}

#
# DEMO 5: WHILE
#
demo_while() {
    print_header "🔁 DEMO 5: WHILE - CÂT TIMP CONDIȚIA E ADEVĂRATĂ"
    
    print_subheader "Sintaxa"
    
    cat << 'SYNTAX'
    while [ condiție ]; do
        # comenzi
    done
SYNTAX
    
    echo ""
    
    print_subheader "Exemplu de bază"
    
    print_multiline_code << 'CODE'
count=1
while [ $count -le 5 ]; do
    echo "Count: $count"
    ((count++))
done
CODE
    
    echo -e "${BLUE}Execuție:${RESET}"
    count=1
    while [ $count -le 5 ]; do
        animate_iteration "$count"
        ((count++))
    done
    
    wait_for_user
    
    print_subheader "while read - Citire fișier linie cu linie"
    
    # Creare fișier test
    cat > lista.txt << 'EOF'
Ion Popescu
Maria Ionescu
Andrei Vasilescu
EOF
    
    print_multiline_code << 'CODE'
while IFS= read -r line; do
    echo "Linia: $line"
done < lista.txt
CODE
    
    echo -e "${BLUE}Execuție:${RESET}"
    while IFS= read -r line; do
        animate_iteration "$line"
    done < lista.txt
    
    print_explanation "IFS= previne trimming-ul spațiilor"
    print_explanation "-r previne interpretarea backslash-urilor"
    print_explanation "< file redirecționează fișierul ca input"
    
    wait_for_user
    
    print_subheader "while read cu delimitator"
    
    cat > data.csv << 'EOF'
Ion,Popescu,25
Maria,Ionescu,30
EOF
    
    print_multiline_code << 'CODE'
while IFS=',' read -r prenume nume varsta; do
    echo "$prenume $nume are $varsta ani"
done < data.csv
CODE
    
    echo -e "${BLUE}Execuție:${RESET}"
    while IFS=',' read -r prenume nume varsta; do
        echo -e "  ${CYAN}$prenume $nume${RESET} are ${WHITE}$varsta${RESET} ani"
    done < data.csv
    
    wait_for_user
    
    print_subheader "while true - Bucla infinită controlată"
    
    print_multiline_code << 'CODE'
count=0
while true; do
    ((count++))
    echo "Iterația $count"
    if [ $count -ge 3 ]; then
        echo "Oprire!"
        break
    fi
done
CODE
    
    echo -e "${BLUE}Execuție:${RESET}"
    count=0
    while true; do
        ((count++))
        animate_iteration "$count"
        if [ $count -ge 3 ]; then
            echo -e "  ${RED}Oprire cu break!${RESET}"
            break
        fi
    done
    
    wait_for_user
}

#
# DEMO 6: CAPCANA SUBSHELL CU PIPE
#
demo_subshell_trap() {
    print_header "🕳️  DEMO 6: CAPCANA SUBSHELL CU PIPE"
    
    print_warning "VARIABILELE NU PERSISTĂ DUPĂ | while read"
    
    print_subheader "Problema"
    
    cat > numere.txt << 'EOF'
10
20
30
EOF
    
    echo -e "${RED}Cod GREȘIT:${RESET}"
    print_multiline_code << 'CODE'
total=0
cat numere.txt | while read num; do
    ((total += num))
    echo "Adaug $num, total=$total"
done
echo "Total final: $total"    # Surpriză: total=0!
CODE
    
    echo -e "${BLUE}Execuție:${RESET}"
    total=0
    cat numere.txt | while read num; do
        ((total += num))
        echo -e "  ${CYAN}Adaug $num, total=$total${RESET}"
    done
    echo -e "  ${RED}${CROSS} Total final: $total (GREȘIT!)${RESET}"
    
    wait_for_user
    
    print_subheader "De ce se întâmplă asta?"
    
    cat << 'DIAGRAM'
    
    ┌────────────────────────────────────────────────────────────────┐
    │                                                                │
    │  cat numere.txt | while read num; do ... done                 │
    │                                                                │
    │  ┌─────────────┐          ┌─────────────────────────┐         │
    │  │ Shell       │          │ Subshell NOU            │         │
    │  │ principal   │   pipe   │ (copie a mediului)      │         │
    │  │             │ ───────▶ │                         │         │
    │  │ total=0     │          │ total=0 → 10 → 30 → 60 │         │
    │  │             │          │                         │         │
    │  │ total=0 ✗   │ ◀─────── │ (modificări PIERDUTE)   │         │
    │  └─────────────┘          └─────────────────────────┘         │
    │                                                                │
    │  Când subshell-ul se închide, variabilele lui DISPAR!         │
    │                                                                │
    └────────────────────────────────────────────────────────────────┘

DIAGRAM
    
    wait_for_user
    
    print_subheader "Soluția 1: Redirecționare în loc de pipe"
    
    echo -e "${GREEN}CORECT:${RESET}"
    print_multiline_code << 'CODE'
total=0
while read num; do
    ((total += num))
    echo "Adaug $num, total=$total"
done < numere.txt
echo "Total final: $total"
CODE
    
    echo -e "${BLUE}Execuție:${RESET}"
    total=0
    while read num; do
        ((total += num))
        echo -e "  ${GREEN}Adaug $num, total=$total${RESET}"
    done < numere.txt
    echo -e "  ${GREEN}${CHECK} Total final: $total (CORECT!)${RESET}"
    
    wait_for_user
    
    print_subheader "Soluția 2: Process substitution"
    
    echo -e "${GREEN}ALTERNATIVĂ:${RESET}"
    print_multiline_code << 'CODE'
total=0
while read num; do
    ((total += num))
done < <(cat numere.txt)
echo "Total: $total"
CODE
    
    echo -e "${BLUE}Execuție:${RESET}"
    total=0
    while read num; do
        ((total += num))
    done < <(cat numere.txt)
    echo -e "  ${GREEN}${CHECK} Total: $total${RESET}"
    
    print_explanation "< <(cmd) = process substitution"
    print_explanation "Creează un file descriptor temporar, evită subshell"
    
    wait_for_user
    
    print_subheader "Soluția 3: lastpipe (Bash 4.2+)"
    
    print_multiline_code << 'CODE'
shopt -s lastpipe    # Activează lastpipe
total=0
cat numere.txt | while read num; do
    ((total += num))
done
echo "Total: $total"
CODE
    
    print_explanation "lastpipe rulează ultima comandă din pipe în shell-ul curent"
    print_explanation "Funcționează doar în scripturi, nu în mod interactiv"
    
    wait_for_user
}

#
# DEMO 7: UNTIL
#
demo_until() {
    print_header "⏳ DEMO 7: UNTIL - PÂNĂ CÂND CONDIȚIA DEVINE ADEVĂRATĂ"
    
    print_subheader "Sintaxa"
    
    cat << 'SYNTAX'
    until [ condiție ]; do    # Rulează CÂT TIMP condiția e FALSE
        # comenzi
    done
SYNTAX
    
    echo ""
    echo -e "${WHITE}until = inversul lui while${RESET}"
    echo -e "${DIM}while [ true ] = until [ false ]${RESET}"
    
    wait_for_user
    
    print_subheader "Exemplu de bază"
    
    print_multiline_code << 'CODE'
count=1
until [ $count -gt 5 ]; do
    echo "Count: $count"
    ((count++))
done
CODE
    
    echo -e "${BLUE}Execuție:${RESET}"
    count=1
    until [ $count -gt 5 ]; do
        animate_iteration "$count"
        ((count++))
    done
    
    wait_for_user
    
    print_subheader "Use Case: Așteptare condiție"
    
    print_multiline_code << 'CODE'
# Simulare: așteaptă până când fișierul apare
echo "Aștept fișierul ready.txt..."
until [ -f ready.txt ]; do
    echo -n "."
    sleep 0.3
done
echo " Gata!"
CODE
    
    echo -e "${BLUE}Execuție (simulare):${RESET}"
    rm -f ready.txt
    echo -n "  "
    (sleep 1.5 && touch ready.txt) &  # Creează fișierul în background
    until [ -f ready.txt ]; do
        echo -n "."
        sleep 0.3
    done
    echo -e " ${GREEN}Gata!${RESET}"
    
    wait_for_user
    
    print_subheader "Comparație: while vs until"
    
    cat << 'COMPARE'
    
    ┌─────────────────────────────────────────────────────────────┐
    │                                                             │
    │  while [ $x -lt 5 ]    ═══    until [ $x -ge 5 ]           │
    │                                                             │
    │  "cât timp x < 5"      ═══    "până când x >= 5"           │
    │                                                             │
    └─────────────────────────────────────────────────────────────┘

COMPARE
    
    print_tip "Folosește ce e mai natural pentru situația dată"
    
    wait_for_user
}

#
# DEMO 8: BREAK ȘI CONTINUE
#
demo_break_continue() {
    print_header "🚦 DEMO 8: BREAK ȘI CONTINUE"
    
    print_subheader "break - Ieșire din buclă"
    
    print_multiline_code << 'CODE'
for i in {1..10}; do
    if [ $i -eq 5 ]; then
        echo "Oprire la $i"
        break
    fi
    echo "Procesez: $i"
done
echo "După buclă"
CODE
    
    echo -e "${BLUE}Execuție:${RESET}"
    for i in {1..10}; do
        if [ $i -eq 5 ]; then
            echo -e "  ${RED}Oprire la $i${RESET}"
            break
        fi
        animate_iteration "$i"
    done
    echo -e "  ${CYAN}După buclă${RESET}"
    
    wait_for_user
    
    print_subheader "continue - Salt la următoarea iterație"
    
    print_multiline_code << 'CODE'
for i in {1..7}; do
    if [ $((i % 2)) -eq 0 ]; then
        continue    # Sari peste numerele pare
    fi
    echo "Impar: $i"
done
CODE
    
    echo -e "${BLUE}Execuție (doar impare):${RESET}"
    for i in {1..7}; do
        if [ $((i % 2)) -eq 0 ]; then
            continue
        fi
        animate_iteration "$i"
    done
    
    wait_for_user
    
    print_subheader "break N - Ieșire din N bucle imbricate"
    
    print_multiline_code << 'CODE'
for i in {1..3}; do
    for j in {1..3}; do
        if [ $i -eq 2 ] && [ $j -eq 2 ]; then
            echo "Break 2 nivele la i=$i, j=$j"
            break 2    # Iese din AMBELE bucle
        fi
        echo "i=$i, j=$j"
    done
done
echo "Terminat"
CODE
    
    echo -e "${BLUE}Execuție:${RESET}"
    for i in {1..3}; do
        for j in {1..3}; do
            if [ $i -eq 2 ] && [ $j -eq 2 ]; then
                echo -e "  ${RED}Break 2 nivele la i=$i, j=$j${RESET}"
                break 2
            fi
            echo -e "  ${CYAN}i=$i, j=$j${RESET}"
        done
    done
    echo -e "  ${GREEN}Terminat${RESET}"
    
    wait_for_user
    
    print_subheader "⚠️ break vs exit"
    
    cat << 'COMPARE'
    
    ┌─────────────────────────────────────────────────────────────┐
    │                                                             │
    │  break     →  Iese din BUCLĂ, continuă scriptul            │
    │                                                             │
    │  exit      →  Termină SCRIPTUL complet                      │
    │                                                             │
    │  exit N    →  Termină scriptul cu exit code N               │
    │                                                             │
    └─────────────────────────────────────────────────────────────┘

COMPARE
    
    wait_for_user
}

#
# DEMO 9: EXEMPLE PRACTICE INTEGRATE
#
demo_practical() {
    print_header "🎯 DEMO 9: EXEMPLE PRACTICE"
    
    print_subheader "1. Batch rename fișiere"
    
    # Creare fișiere test
    mkdir -p batch_test
    touch batch_test/file{1..3}.txt
    
    print_multiline_code << 'CODE'
for file in batch_test/*.txt; do
    base=$(basename "$file" .txt)
    mv "$file" "batch_test/document_$base.txt"
done
CODE
    
    echo -e "${BLUE}Înainte:${RESET} $(ls batch_test/)"
    for file in batch_test/*.txt; do
        base=$(basename "$file" .txt)
        mv "$file" "batch_test/document_$base.txt"
    done
    echo -e "${GREEN}După:${RESET}    $(ls batch_test/)"
    
    wait_for_user
    
    print_subheader "2. Procesare CSV cu while read"
    
    cat > produse.csv << 'EOF'
Laptop,2500,10
Monitor,800,25
Tastatură,150,50
Mouse,75,100
EOF
    
    print_multiline_code << 'CODE'
total=0
while IFS=',' read -r produs pret cantitate; do
    subtotal=$((pret * cantitate))
    ((total += subtotal))
    printf "%-12s: %d x %d = %d RON\n" "$produs" "$cantitate" "$pret" "$subtotal"
done < produse.csv
echo "─────────────────────────────"
echo "TOTAL: $total RON"
CODE
    
    echo -e "${BLUE}Execuție:${RESET}"
    total=0
    while IFS=',' read -r produs pret cantitate; do
        subtotal=$((pret * cantitate))
        ((total += subtotal))
        printf "  ${CYAN}%-12s${RESET}: %d x %d = ${WHITE}%d RON${RESET}\n" "$produs" "$cantitate" "$pret" "$subtotal"
    done < produse.csv
    echo "  ─────────────────────────────"
    echo -e "  ${GREEN}TOTAL: $total RON${RESET}"
    
    wait_for_user
    
    print_subheader "3. Animație simplă"
    
    print_multiline_code << 'CODE'
chars="/-\|"
echo -n "Procesare: "
for i in {1..20}; do
    printf "\b${chars:i%4:1}"
    sleep 0.1
done
echo -e "\b ✓ Complet!"
CODE
    
    echo -e "${BLUE}Execuție:${RESET}"
    chars="/-\|"
    echo -n "  Procesare: "
    for i in {1..20}; do
        printf "\b${chars:i%4:1}"
        sleep 0.1
    done
    echo -e "\b ${GREEN}${CHECK} Complet!${RESET}"
    
    wait_for_user
    
    print_subheader "4. Menu interactiv cu select"
    
    print_multiline_code << 'CODE'
PS3="Alegerea ta: "
select opt in "Opțiunea A" "Opțiunea B" "Ieșire"; do
    case $opt in
        "Opțiunea A") echo "Ai ales A" ;;
        "Opțiunea B") echo "Ai ales B" ;;
        "Ieșire") break ;;
        *) echo "Opțiune invalidă" ;;
    esac
done
CODE
    
    echo -e "${DIM}(select creează automat un meniu numerotat)${RESET}"
    
    wait_for_user
}

#
# DEMO 10: RECAPITULARE VIZUALĂ
#
demo_recap() {
    print_header "📚 DEMO 10: RECAPITULARE"
    
    cat << 'RECAP'
    
    ┌────────────────────────────────────────────────────────────────────┐
    │                    TIPURI DE BUCLE BASH                            │
    ├────────────────────────────────────────────────────────────────────┤
    │                                                                    │
    │  FOR LISTA          for x in a b c; do ... done                   │
    │  FOR BRACE          for i in {1..10}; do ... done                 │
    │  FOR GLOB           for f in *.txt; do ... done                   │
    │  FOR C-STYLE        for ((i=0; i<10; i++)); do ... done           │
    │                                                                    │
    │  WHILE              while [ cond ]; do ... done                   │
    │  WHILE READ         while read line; do ... done < file          │
    │                                                                    │
    │  UNTIL              until [ cond ]; do ... done                   │
    │                                                                    │
    ├────────────────────────────────────────────────────────────────────┤
    │                    ⚠️ CAPCANE DE EVITAT                           │
    ├────────────────────────────────────────────────────────────────────┤
    │                                                                    │
    │  ✗ {1..$N}          Brace expansion NU funcționează cu variabile  │
    │  ✓ $(seq 1 $N)      Soluția 1                                     │
    │  ✓ for ((i=1;i<=N;i++))   Soluția 2                               │
    │                                                                    │
    │  ✗ cat f | while    Variabilele se pierd (subshell)              │
    │  ✓ while ... < f    Redirecționare în loc de pipe                │
    │                                                                    │
    │  ✗ for f in $var    Probleme cu spații                           │
    │  ✓ for f in "$var"  Ghilimele pentru siguranță                   │
    │                                                                    │
    ├────────────────────────────────────────────────────────────────────┤
    │                    CONTROL FLOW                                    │
    ├────────────────────────────────────────────────────────────────────┤
    │                                                                    │
    │  break              Ieșire din bucla curentă                      │
    │  break N            Ieșire din N bucle imbricate                  │
    │  continue           Salt la următoarea iterație                   │
    │  continue N         Salt în a N-a buclă exterioară               │
    │  exit               Termină SCRIPTUL (nu bucla!)                  │
    │                                                                    │
    └────────────────────────────────────────────────────────────────────┘

RECAP
    
    wait_for_user
}

#
# MENIU PRINCIPAL
#
show_menu() {
    clear
    fancy_title "LOOPS"
    
    echo ""
    echo -e "${WHITE}Selectează un demo pentru a rula:${RESET}"
    echo ""
    echo -e "  ${CYAN}1${RESET})  for - Iterare peste listă"
    echo -e "  ${CYAN}2${RESET})  ${WARNING} for - Brace expansion {..}"
    echo -e "  ${CYAN}3${RESET})  for - Glob (fișiere)"
    echo -e "  ${CYAN}4${RESET})  for - C-style (( ))"
    echo -e "  ${CYAN}5${RESET})  while"
    echo -e "  ${CYAN}6${RESET})  ${WARNING} Capcana subshell cu pipe"
    echo -e "  ${CYAN}7${RESET})  until"
    echo -e "  ${CYAN}8${RESET})  break și continue"
    echo -e "  ${CYAN}9${RESET})  ${STAR} Exemple practice"
    echo -e "  ${CYAN}10${RESET}) Recapitulare"
    echo ""
    echo -e "  ${CYAN}a${RESET})  Rulează TOATE demo-urile"
    echo -e "  ${CYAN}q${RESET})  Ieșire"
    echo ""
    echo -n "Alegerea ta: "
}

run_all_demos() {
    demo_for_list
    demo_for_brace
    demo_for_glob
    demo_for_cstyle
    demo_while
    demo_subshell_trap
    demo_until
    demo_break_continue
    demo_practical
    demo_recap
    
    print_header "🎉 TOATE DEMO-URILE COMPLETATE!"
    
    echo -e "${GREEN}Felicitări! Ai parcurs toate conceptele despre bucle.${RESET}"
    echo ""
    echo -e "${WHITE}Cele mai importante de reținut:${RESET}"
    echo ""
    echo -e "  ${BULLET} ${RED}{1..\$N} NU funcționează${RESET} - folosește seq sau (( ))"
    echo -e "  ${BULLET} ${RED}cat | while${RESET} pierde variabile - folosește < file"
    echo -e "  ${BULLET} Folosește ${CYAN}\"ghilimele\"${RESET} în jurul variabilelor"
    echo -e "  ${BULLET} ${CYAN}break${RESET} = ieșire buclă, ${CYAN}exit${RESET} = ieșire script"
    echo ""
}

#
# MAIN
#
main() {
    case "${1:-menu}" in
        1) demo_for_list ;;
        2) demo_for_brace ;;
        3) demo_for_glob ;;
        4) demo_for_cstyle ;;
        5) demo_while ;;
        6) demo_subshell_trap ;;
        7) demo_until ;;
        8) demo_break_continue ;;
        9) demo_practical ;;
        10) demo_recap ;;
        all|a) run_all_demos ;;
        menu|"")
            while true; do
                show_menu
                read -r choice
                case "$choice" in
                    1) demo_for_list ;;
                    2) demo_for_brace ;;
                    3) demo_for_glob ;;
                    4) demo_for_cstyle ;;
                    5) demo_while ;;
                    6) demo_subshell_trap ;;
                    7) demo_until ;;
                    8) demo_break_continue ;;
                    9) demo_practical ;;
                    10) demo_recap ;;
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
            echo "Utilizare: $0 [1-10|all|menu]"
            exit 1
            ;;
    esac
}

main "$@"
