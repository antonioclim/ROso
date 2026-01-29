#!/bin/bash
#
#  S03_03_demo_getopts.sh
# Demonstrație: Parsare argumente și opțiuni în scripturi Bash
#
#
# DESCRIERE:
#   Script de demonstrație pentru parametri poziționali, $@, $*, shift,
#   getopts și parsare opțiuni lungi.
#
# UTILIZARE:
#   ./S03_03_demo_getopts.sh [opțiuni]
#
# OPȚIUNI:
#   -h, --help      Afișează acest ajutor
#   -i, --interactive   Mod interactiv
#   -s, --section NUM   Rulează doar o secțiune (1-7)
#   -d, --demo NAME     Rulează un demo specific
#
# AUTOR: Kit Seminar SO - ASE București
# VERSIUNE: 1.0
#

set -e

#
# CONFIGURARE
#

DEMO_DIR="$HOME/getopts_demo_lab"
INTERACTIVE=false
RUN_SECTION=""
SPECIFIC_DEMO=""

# Culori
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'

#
# FUNCȚII UTILITARE
#

print_header() {
    local title="$1"
    local width=70
    echo ""
    echo -e "${CYAN}╔$(printf '═%.0s' $(seq 1 $((width-2))))╗${NC}"
    printf "${CYAN}║${NC} ${BOLD}${WHITE}%-$((width-4))s${NC} ${CYAN}║${NC}\n" "$title"
    echo -e "${CYAN}╚$(printf '═%.0s' $(seq 1 $((width-2))))╝${NC}"
    echo ""
}

print_subheader() {
    local title="$1"
    echo ""
    echo -e "${YELLOW}┌──────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${YELLOW}│${NC} ${BOLD}$title${NC}"
    echo -e "${YELLOW}└──────────────────────────────────────────────────────────────────┘${NC}"
}

print_concept() {
    local concept="$1"
    echo -e "\n${MAGENTA}💡 CONCEPT:${NC} ${WHITE}$concept${NC}\n"
}

print_code_block() {
    local title="$1"
    echo ""
    echo -e "${GREEN}┌─ 📝 $title ─────────────────────────────────────────────────────┐${NC}"
}

print_code_end() {
    echo -e "${GREEN}└────────────────────────────────────────────────────────────────────┘${NC}"
}

print_warning() {
    local text="$1"
    echo -e "\n${RED}⚠️  Capcană:${NC} ${YELLOW}$text${NC}"
}

print_tip() {
    local text="$1"
    echo -e "\n${GREEN}💚 TIP:${NC} $text"
}

print_prediction() {
    local question="$1"
    echo ""
    echo -e "${BLUE}┌─ 🤔 PREDICȚIE ─────────────────────────────────────────────────────┐${NC}"
    echo -e "${BLUE}│${NC} $question"
    echo -e "${BLUE}└────────────────────────────────────────────────────────────────────┘${NC}"
}

run_script_demo() {
    local script_content="$1"
    local script_args="$2"
    local description="$3"
    
    # Creează script temporar
    local tmp_script="$DEMO_DIR/tmp_demo_$$.sh"
    echo "$script_content" > "$tmp_script"
    chmod +x "$tmp_script"
    
    echo -e "${GREEN}▶${NC} ${BOLD}./script.sh $script_args${NC}"
    [[ -n "$description" ]] && echo -e "  ${GRAY}↳ $description${NC}"
    echo -e "${DIM}─────────── OUTPUT ───────────${NC}"
    bash "$tmp_script" $script_args 2>&1 || true
    echo -e "${DIM}──────────────────────────────${NC}"
    
    rm -f "$tmp_script"
}

pause_interactive() {
    if [[ "$INTERACTIVE" == true ]]; then
        echo ""
        echo -e "${CYAN}⏸  Apasă ENTER pentru a continua...${NC}"
        read -r
    fi
}

show_usage() {
    cat << 'EOF'
═══════════════════════════════════════════════════════════════════════════════
 📋 Demo getopts și Parsare Argumente - Utilizare
═══════════════════════════════════════════════════════════════════════════════

SINTAXĂ:
  ./S03_03_demo_getopts.sh [opțiuni]

OPȚIUNI:
  -h, --help          Afișează acest ajutor
  -i, --interactive   Mod interactiv cu pauze între secțiuni
  -s, --section NUM   Rulează doar secțiunea specificată (1-7)
  -d, --demo NAME     Rulează un demo specific

SECȚIUNI:
  1 - Parametri poziționali ($1, $2, etc.)
  2 - $@ vs $* - diferența crucială
  3 - shift și procesare iterativă
  4 - Valori implicite și expansiuni
  5 - getopts pentru opțiuni scurte
  6 - Opțiuni lungi (--option)
  7 - Script complet profesional

EXEMPLE:
  ./S03_03_demo_getopts.sh -i              # Demo interactiv complet
  ./S03_03_demo_getopts.sh -s 5            # Doar secțiunea getopts
  ./S03_03_demo_getopts.sh -d professional # Demo script profesional

═══════════════════════════════════════════════════════════════════════════════
EOF
}

setup_demo() {
    mkdir -p "$DEMO_DIR"
    echo "Linia 1" > "$DEMO_DIR/test_file.txt"
    echo "Linia 2" >> "$DEMO_DIR/test_file.txt"
    echo "Linia 3" >> "$DEMO_DIR/test_file.txt"
}

#
# SECȚIUNEA 1: PARAMETRI POZIȚIONALI
#

section_1_positional() {
    print_header "📚 SECȚIUNEA 1: Parametri Poziționali"
    
    setup_demo
    cd "$DEMO_DIR"
    
    print_concept "Variabilele speciale pentru argumente în Bash"
    
    print_subheader "1.1 Variabilele de bază"
    
    echo ""
    cat << 'TABLE'
╔═══════════╦═══════════════════════════════════════════════════════════════════╗
║ Variabilă ║ Semnificație                                                      ║
╠═══════════╬═══════════════════════════════════════════════════════════════════╣
║    $0     ║ Numele scriptului                                                 ║
║    $1     ║ Primul argument                                                   ║
║    $2     ║ Al doilea argument                                                ║
║   ...     ║ ... și așa mai departe până la $9                                 ║
║  ${10}    ║ Al 10-lea argument (necesită acolade!)                            ║
║    $#     ║ Numărul total de argumente                                        ║
║    $@     ║ Toate argumentele (ca listă separată)                             ║
║    $*     ║ Toate argumentele (ca un singur string)                           ║
║    $?     ║ Exit code-ul ultimei comenzi                                      ║
║    $$     ║ PID-ul shell-ului curent                                          ║
║    $!     ║ PID-ul ultimului proces background                                ║
╚═══════════╩═══════════════════════════════════════════════════════════════════╝
TABLE
    
    print_subheader "1.2 Demonstrație $0, $1, $2, $#"
    
    local demo_script='#!/bin/bash
echo "Numele scriptului (\$0): $0"
echo "Primul argument (\$1): $1"
echo "Al doilea argument (\$2): $2"
echo "Număr argumente (\$#): $#"'
    
    print_code_block "Script demonstrativ"
    echo "$demo_script"
    print_code_end
    
    print_prediction "Ce va afișa script-ul când rulăm: ./script.sh hello world extra ?"
    pause_interactive
    
    run_script_demo "$demo_script" "hello world extra" ""
    
    # ${10} vs $10
    print_subheader "1.3 ⚠️ Capcană: \${10} vs \$10"
    
    print_warning "\$10 NU este al 10-lea argument!"
    
    echo ""
    echo "  \$10  = \$1 urmat de caracterul '0' (adică: 'hello' + '0' = 'hello0')"
    echo "  \${10} = al 10-lea argument (corect!)"
    
    local demo_10='#!/bin/bash
echo "Greșit - \$10: $10"
echo "Corect - \${10}: ${10}"'
    
    print_code_block "Demonstrație \${10}"
    echo "$demo_10"
    print_code_end
    
    run_script_demo "$demo_10" "a b c d e f g h i ZECE unsprezece" ""
    
    print_tip "Folosește întotdeauna acolade pentru argumente >= 10: \${10}, \${11}, etc."
    
    pause_interactive
}

#
# SECȚIUNEA 2: $@ VS $*
#

section_2_at_vs_star() {
    print_header "📚 SECȚIUNEA 2: \$@ vs \$* - Diferența Crucială"
    
    cd "$DEMO_DIR"
    
    print_concept "Comportamentul diferit al \$@ și \$* în contexte diferite"
    
    print_subheader "2.1 Fără ghilimele - Identice"
    
    echo ""
    echo "  ${WHITE}Fără ghilimele, \$@ și \$* se comportă identic:${NC}"
    echo "  Ambele se expandează la lista de argumente separate."
    
    local demo_unquoted='#!/bin/bash
echo "=== Fără ghilimele ==="
echo "Cu \$@:"
for arg in $@; do echo "  [$arg]"; done
echo "Cu \$*:"
for arg in $*; do echo "  [$arg]"; done'
    
    run_script_demo "$demo_unquoted" "hello world" ""
    
    print_subheader "2.2 Cu ghilimele - DIFERITE!"
    
    print_warning "Cu ghilimele, comportamentul diferă complet!"
    
    echo ""
    cat << 'DIFF'
╔═══════════════════════════════════════════════════════════════════════════════╗
║                    DIFERENȚA CRUCIALĂ                                         ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║  "$@" = Fiecare argument păstrează identitatea                                ║
║         "arg1" "arg2" "arg3"  → 3 elemente separate                           ║
║                                                                               ║
║  "$*" = Toate argumentele concatenate într-un singur string                   ║
║         "arg1 arg2 arg3"      → 1 element                                     ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
DIFF
    
    local demo_quoted='#!/bin/bash
echo "=== Cu ghilimele ==="
echo ""
echo "Cu \"\$@\" (separat):"
for arg in "$@"; do echo "  [$arg]"; done

echo ""
echo "Cu \"\$*\" (concatenat):"
for arg in "$*"; do echo "  [$arg]"; done'
    
    print_code_block "Demonstrație cu ghilimele"
    echo "$demo_quoted"
    print_code_end
    
    print_prediction "Câte linii va afișa fiecare for când rulăm: ./script.sh \"hello world\" test ?"
    pause_interactive
    
    run_script_demo "$demo_quoted" '"hello world" test' ""
    
    # Când contează
    print_subheader "2.3 De ce contează? - Argumente cu spații"
    
    echo ""
    echo "  ${WHITE}Scenariu: Script care procesează fișiere${NC}"
    echo ""
    echo "  User rulează: ./process.sh 'my file.txt' 'other file.txt'"
    
    local demo_files_wrong='#!/bin/bash
echo "GREȘIT - cu \$@:"
for f in $@; do
    echo "  Procesez: [$f]"
done'
    
    local demo_files_right='#!/bin/bash
echo "CORECT - cu \"\$@\":"
for f in "$@"; do
    echo "  Procesez: [$f]"
done'
    
    print_code_block "Procesare GREȘITĂ"
    echo "$demo_files_wrong"
    print_code_end
    
    run_script_demo "$demo_files_wrong" '"my file.txt" "other file.txt"' ""
    
    print_code_block "Procesare CORECTĂ"
    echo "$demo_files_right"
    print_code_end
    
    run_script_demo "$demo_files_right" '"my file.txt" "other file.txt"' ""
    
    print_tip "Regulă de aur: ÎNTOTDEAUNA folosește \"\$@\" cu ghilimele pentru a itera prin argumente!"
    
    pause_interactive
}

#
# SECȚIUNEA 3: SHIFT
#

section_3_shift() {
    print_header "📚 SECȚIUNEA 3: shift - Procesare Iterativă"
    
    cd "$DEMO_DIR"
    
    print_concept "shift elimină primul argument și mută restul în sus"
    
    print_subheader "3.1 Cum funcționează shift"
    
    echo ""
    cat << 'DIAGRAM'
╔═══════════════════════════════════════════════════════════════════════════════╗
║  Înainte de shift:    $1=A    $2=B    $3=C    $4=D    $#=4                     ║
║                        ↓                                                      ║
║  După shift:          $1=B    $2=C    $3=D            $#=3                     ║
║                        ↓                                                      ║
║  După shift 2:        $1=D                            $#=1                     ║
╚═══════════════════════════════════════════════════════════════════════════════╝
DIAGRAM
    
    local demo_shift='#!/bin/bash
echo "Inițial: \$1=$1, \$2=$2, \$3=$3, \$#=$#"
shift
echo "După shift: \$1=$1, \$2=$2, \$3=$3, \$#=$#"
shift
echo "După alt shift: \$1=$1, \$2=$2, \$3=$3, \$#=$#"'
    
    print_code_block "Demonstrație shift"
    echo "$demo_shift"
    print_code_end
    
    run_script_demo "$demo_shift" "A B C D E" ""
    
    # shift N
    print_subheader "3.2 shift N - Elimină N argumente"
    
    local demo_shift_n='#!/bin/bash
echo "Inițial: \$@= $@, \$#=$#"
shift 3
echo "După shift 3: \$@= $@, \$#=$#"'
    
    run_script_demo "$demo_shift_n" "uno dos tres cuatro cinco" ""
    
    # Pattern procesare
    print_subheader "3.3 Pattern: Procesare iterativă cu while + shift"
    
    local demo_while_shift='#!/bin/bash
echo "Procesez argumentele:"
counter=1
while [[ $# -gt 0 ]]; do
    echo "  Argument $counter: $1"
    shift
    ((counter++))
done
echo "Gata! Nu mai sunt argumente."'
    
    print_code_block "Pattern while + shift"
    echo "$demo_while_shift"
    print_code_end
    
    run_script_demo "$demo_while_shift" "alpha beta gamma delta" ""
    
    # Pattern cu opțiuni
    print_subheader "3.4 Pattern: Parsare opțiuni manuală"
    
    local demo_manual_opts='#!/bin/bash
verbose=false
output=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -v|--verbose)
            verbose=true
            shift
            ;;
        -o|--output)
            output="$2"
            shift 2
            ;;
        -*)
            echo "Opțiune necunoscută: $1"
            exit 1
            ;;
        *)
            # Argument non-opțiune
            echo "Argument: $1"
            shift
            ;;
    esac
done

echo ""
echo "Rezultat: verbose=$verbose, output=$output"'
    
    print_code_block "Parsare manuală cu while/case/shift"
    echo "$demo_manual_opts"
    print_code_end
    
    run_script_demo "$demo_manual_opts" "-v --output results.txt file1.txt file2.txt" ""
    
    print_tip "shift 2 este esențial pentru opțiuni care au valoare (precum -o FILE)"
    
    pause_interactive
}

#
# SECȚIUNEA 4: VALORI IMPLICITE ȘI EXPANSIUNI
#

section_4_defaults() {
    print_header "📚 SECȚIUNEA 4: Valori Implicite și Expansiuni"
    
    cd "$DEMO_DIR"
    
    print_concept "Expansiuni pentru valori default, erori și manipulare string-uri"
    
    print_subheader "4.1 Valori implicite"
    
    echo ""
    cat << 'TABLE'
╔═══════════════════╦═══════════════════════════════════════════════════════════╗
║ Sintaxă           ║ Semnificație                                              ║
╠═══════════════════╬═══════════════════════════════════════════════════════════╣
║ ${VAR:-default}   ║ Dacă VAR e nesetată/goală, folosește "default"            ║
║ ${VAR:=default}   ║ Dacă VAR e nesetată/goală, setează VAR="default"          ║
║ ${VAR:+alt}       ║ Dacă VAR e setată, folosește "alt"                        ║
║ ${VAR:?error}     ║ Dacă VAR e nesetată/goală, afișează eroare și exit        ║
╚═══════════════════╩═══════════════════════════════════════════════════════════╝
TABLE
    
    local demo_defaults='#!/bin/bash
# ${VAR:-default} - folosește default fără a modifica VAR
name="${1:-Anonymous}"
echo "Salut, $name!"

# ${VAR:=default} - setează VAR dacă e goală
: ${CONFIG_FILE:=/etc/default.conf}
echo "Config: $CONFIG_FILE"

# ${VAR:+alt} - înlocuiește doar dacă e setată
debug_flag="${DEBUG:+--debug}"
echo "Debug flag: [$debug_flag]"'
    
    print_code_block "Demonstrație valori implicite"
    echo "$demo_defaults"
    print_code_end
    
    echo -e "\n${WHITE}Fără argumente:${NC}"
    run_script_demo "$demo_defaults" "" ""
    
    echo -e "\n${WHITE}Cu argument:${NC}"
    run_script_demo "$demo_defaults" "Maria" ""
    
    # :? pentru erori
    print_subheader "4.2 Validare obligatorie cu :?"
    
    local demo_required='#!/bin/bash
# Fail fast dacă variabila lipsește
input_file="${1:?Eroare: Lipsește fișierul de intrare!}"
echo "Procesez: $input_file"'
    
    print_code_block "Validare cu :?"
    echo "$demo_required"
    print_code_end
    
    echo -e "\n${WHITE}Fără argument (eroare):${NC}"
    run_script_demo "$demo_required" "" ""
    
    echo -e "\n${WHITE}Cu argument (OK):${NC}"
    run_script_demo "$demo_required" "data.txt" ""
    
    # Manipulare strings
    print_subheader "4.3 Manipulare string-uri"
    
    echo ""
    cat << 'TABLE'
╔═══════════════════════╦═══════════════════════════════════════════════════════╗
║ Sintaxă               ║ Semnificație                                          ║
╠═══════════════════════╬═══════════════════════════════════════════════════════╣
║ ${#VAR}               ║ Lungimea string-ului                                  ║
║ ${VAR%pattern}        ║ Elimină cel mai scurt suffix care match-uiește        ║
║ ${VAR%%pattern}       ║ Elimină cel mai lung suffix                           ║
║ ${VAR#pattern}        ║ Elimină cel mai scurt prefix                          ║
║ ${VAR##pattern}       ║ Elimină cel mai lung prefix                           ║
║ ${VAR/pattern/repl}   ║ Înlocuiește prima apariție                            ║
║ ${VAR//pattern/repl}  ║ Înlocuiește toate aparițiile                          ║
╚═══════════════════════╩═══════════════════════════════════════════════════════╝
TABLE
    
    local demo_strings='#!/bin/bash
filepath="/home/user/documents/report.tar.gz"
echo "Cale completă: $filepath"
echo ""
echo "Lungime: ${#filepath}"
echo "Nume fișier (##*/): ${filepath##*/}"
echo "Director (%/*): ${filepath%/*}"
echo "Fără extensie (%.*): ${filepath%.*}"
echo "Fără toate extensiile (%%.*): ${filepath%%.*}"
echo "Extensie (#*.): ${filepath#*.}"
echo "Prima extensie (##*.): ${filepath##*.}"'
    
    print_code_block "Manipulare căi"
    echo "$demo_strings"
    print_code_end
    
    run_script_demo "$demo_strings" "" ""
    
    print_tip "Folosește basename și dirname pentru portabilitate, dar expansiunile sunt mai rapide"
    
    pause_interactive
}

#
# SECȚIUNEA 5: GETOPTS
#

section_5_getopts() {
    print_header "📚 SECȚIUNEA 5: getopts - Opțiuni Scurte"
    
    cd "$DEMO_DIR"
    
    print_concept "getopts - parsare standard POSIX pentru opțiuni de o literă"
    
    print_subheader "5.1 Sintaxa de bază"
    
    echo ""
    cat << 'SYNTAX'
╔═══════════════════════════════════════════════════════════════════════════════╗
║                                                                               ║
║   while getopts "OPTSTRING" opt; do                                           ║
║       case "$opt" in                                                          ║
║           a) ... ;;                                                           ║
║           b) ... ;;    # OPTARG conține valoarea                              ║
║           ?) ... ;;    # Opțiune invalidă                                     ║
║       esac                                                                    ║
║   done                                                                        ║
║   shift $((OPTIND - 1))    # Elimină opțiunile procesate                      ║
║                                                                               ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║ OPTSTRING:                                                                    ║
║   a     = opțiune simplă (-a)                                                 ║
║   b:    = opțiune cu valoare obligatorie (-b VALUE)                           ║
║   :     = la început: mod silențios pentru erori                              ║
║                                                                               ║
║ Variabile speciale:                                                           ║
║   OPTARG = valoarea opțiunii curente                                          ║
║   OPTIND = indexul următorului argument de procesat                           ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
SYNTAX
    
    print_subheader "5.2 Exemplu simplu"
    
    local demo_simple='#!/bin/bash
verbose=false
count=1

while getopts "vc:" opt; do
    case "$opt" in
        v) verbose=true ;;
        c) count="$OPTARG" ;;
        ?) echo "Opțiune invalidă"; exit 1 ;;
    esac
done

shift $((OPTIND - 1))

echo "verbose: $verbose"
echo "count: $count"
echo "Argumente rămase: $@"'
    
    print_code_block "getopts simplu"
    echo "$demo_simple"
    print_code_end
    
    run_script_demo "$demo_simple" "-v -c 5 file1.txt file2.txt" ""
    
    run_script_demo "$demo_simple" "-c 10 data.txt" ""
    
    # Opțiuni combinate
    print_subheader "5.3 Opțiuni combinate"
    
    echo ""
    echo "  ${WHITE}getopts acceptă opțiuni combinate:${NC}"
    echo "  -a -b -c  este echivalent cu  -abc"
    
    run_script_demo "$demo_simple" "-vc 3 test.txt" "Opțiuni combinate"
    
    # Erori
    print_subheader "5.4 Gestionarea erorilor"
    
    echo ""
    echo "  ${WHITE}Două moduri de gestionare erori:${NC}"
    echo ""
    echo "  1. Mod implicit (fără : la început)"
    echo "     - getopts afișează eroare"
    echo "     - opt devine '?'"
    echo ""
    echo "  2. Mod silențios (: la început)"
    echo "     - Nu afișează eroare"
    echo "     - opt devine ':' pentru argument lipsă"
    echo "     - opt devine '?' pentru opțiune necunoscută"
    echo "     - OPTARG conține opțiunea problematică"
    
    local demo_silent='#!/bin/bash
while getopts ":vf:" opt; do
    case "$opt" in
        v) echo "Verbose activat" ;;
        f) echo "Fișier: $OPTARG" ;;
        :) echo "Eroare: -$OPTARG necesită argument"; exit 1 ;;
        ?) echo "Eroare: opțiune necunoscută -$OPTARG"; exit 1 ;;
    esac
done'
    
    print_code_block "Mod silențios cu mesaje personalizate"
    echo "$demo_silent"
    print_code_end
    
    run_script_demo "$demo_silent" "-f" "Argument lipsă pentru -f"
    
    run_script_demo "$demo_silent" "-x" "Opțiune necunoscută"
    
    print_subheader "5.5 Importanța shift \$((OPTIND - 1))"
    
    print_warning "Fără shift, argumentele non-opțiune nu sunt accesibile corect!"
    
    local demo_noshift='#!/bin/bash
while getopts "v" opt; do
    case "$opt" in
        v) echo "Verbose" ;;
    esac
done
# FĂRĂ shift!
echo "Primul argument: $1"
echo "Toate argumentele: $@"'
    
    local demo_withshift='#!/bin/bash
while getopts "v" opt; do
    case "$opt" in
        v) echo "Verbose" ;;
    esac
done
shift $((OPTIND - 1))
echo "Primul argument: $1"
echo "Toate argumentele: $@"'
    
    echo -e "\n${RED}GREȘIT - fără shift:${NC}"
    run_script_demo "$demo_noshift" "-v file.txt data.txt" ""
    
    echo -e "\n${GREEN}CORECT - cu shift:${NC}"
    run_script_demo "$demo_withshift" "-v file.txt data.txt" ""
    
    print_tip "OPTIND indică poziția următorului argument neprocesat. shift elimină opțiunile."
    
    pause_interactive
}

#
# SECȚIUNEA 6: OPȚIUNI LUNGI
#

section_6_long_options() {
    print_header "📚 SECȚIUNEA 6: Opțiuni Lungi (--option)"
    
    cd "$DEMO_DIR"
    
    print_concept "getopts NU suportă opțiuni lungi - trebuie parsare manuală"
    
    print_warning "getopts e doar pentru opțiuni scurte! Pentru --verbose, --output trebuie cod manual."
    
    print_subheader "6.1 Pattern manual pentru opțiuni lungi"
    
    local demo_long='#!/bin/bash
verbose=false
output=""
input_files=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        -v|--verbose)
            verbose=true
            shift
            ;;
        -o|--output)
            output="$2"
            shift 2
            ;;
        -h|--help)
            echo "Utilizare: script.sh [-v|--verbose] [-o|--output FILE] files..."
            exit 0
            ;;
        --)
            shift
            break  # Restul sunt argumente, nu opțiuni
            ;;
        -*)
            echo "Opțiune necunoscută: $1" >&2
            exit 1
            ;;
        *)
            input_files+=("$1")
            shift
            ;;
    esac
done

# Adaugă și argumentele de după --
input_files+=("$@")

echo "verbose: $verbose"
echo "output: $output"
echo "files: ${input_files[*]}"'
    
    print_code_block "Parsare opțiuni lungi"
    echo "$demo_long"
    print_code_end
    
    run_script_demo "$demo_long" "--verbose --output results.txt file1.txt file2.txt" ""
    
    run_script_demo "$demo_long" "-v -o out.txt data.csv" "Opțiuni scurte funcționează la fel"
    
    # Opțiuni cu =
    print_subheader "6.2 Opțiuni cu = (--output=file)"
    
    local demo_equal='#!/bin/bash
verbose=false
output=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -v|--verbose)
            verbose=true
            shift
            ;;
        -o|--output)
            output="$2"
            shift 2
            ;;
        --output=*)
            output="${1#*=}"  # Extrage valoarea după =
            shift
            ;;
        *)
            break
            ;;
    esac
done

echo "output: $output"
echo "remaining: $@"'
    
    print_code_block "Suport pentru --option=value"
    echo "$demo_equal"
    print_code_end
    
    run_script_demo "$demo_equal" "--output=results.txt file.txt" ""
    
    # -- pentru a opri parsarea
    print_subheader "6.3 -- pentru a opri parsarea opțiunilor"
    
    echo ""
    echo "  ${WHITE}Convenție: -- separă opțiunile de argumente${NC}"
    echo ""
    echo "  Util când argumentele încep cu - :"
    echo "  ./script.sh --output log.txt -- -strange-filename.txt"
    
    local demo_dashdash='#!/bin/bash
while [[ $# -gt 0 ]]; do
    case "$1" in
        -o) output="$2"; shift 2 ;;
        --) shift; break ;;  # Oprește parsarea
        -*) echo "Opțiune: $1"; shift ;;
        *) break ;;
    esac
done

echo "Argumente rămase:"
for arg in "$@"; do
    echo "  [$arg]"
done'
    
    run_script_demo "$demo_dashdash" "-o out.txt -- -weird-file.txt --not-option.txt" ""
    
    print_tip "Întotdeauna suportă -- pentru robusteță!"
    
    pause_interactive
}

#
# SECȚIUNEA 7: SCRIPT COMPLET PROFESIONAL
#

section_7_professional() {
    print_header "📚 SECȚIUNEA 7: Script Complet Profesional"
    
    cd "$DEMO_DIR"
    
    print_concept "Pattern complet cu toate best practices"
    
    print_subheader "7.1 Structura unui script profesional"
    
    cat << 'STRUCTURE'
╔═══════════════════════════════════════════════════════════════════════════════╗
║  STRUCTURA SCRIPT PROFESIONAL:                                                ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║  1. Shebang și set options (set -e, set -u)                                   ║
║  2. Header cu documentație                                                    ║
║  3. Constante și variabile globale                                            ║
║  4. Funcție usage() pentru help                                               ║
║  5. Funcții utilitare (log, error, cleanup)                                   ║
║  6. Funcția principală de business logic                                      ║
║  7. Parsare argumente                                                         ║
║  8. Validare argumente                                                        ║
║  9. Execuție                                                                  ║
╚═══════════════════════════════════════════════════════════════════════════════╝
STRUCTURE
    
    print_subheader "7.2 Script Exemplu Complet"
    
    # Creăm scriptul complet
    local professional_script='#!/bin/bash
#
# fileprocessor.sh - Procesare fișiere cu opțiuni complete
#
#
# UTILIZARE:
#   ./fileprocessor.sh [opțiuni] file [files...]
#
# OPȚIUNI:
#   -h, --help          Afișează acest ajutor
#   -v, --verbose       Mod verbose
#   -o, --output FILE   Fișier de output (default: stdout)
#   -n, --dry-run       Simulează fără a executa
#   -q, --quiet         Mod silențios
#
# EXEMPLE:
#   ./fileprocessor.sh -v file.txt
#   ./fileprocessor.sh --output=result.txt *.log
#   ./fileprocessor.sh -n --verbose data/*.csv
#
#

set -e          # Exit on error
set -u          # Error on undefined variables
set -o pipefail # Pipe fails if any command fails

#
# CONSTANTE ȘI DEFAULTS
#

readonly SCRIPT_NAME="${0##*/}"
readonly SCRIPT_VERSION="1.0.0"

# Valori default
VERBOSE=false
DRY_RUN=false
QUIET=false
OUTPUT_FILE=""
INPUT_FILES=()

#
# FUNCȚII UTILITARE
#

usage() {
    cat << EOF
Utilizare: $SCRIPT_NAME [opțiuni] file [files...]

Procesează fișierele specificate și generează un raport.

OPȚIUNI:
  -h, --help          Afișează acest ajutor și iese
  -V, --version       Afișează versiunea
  -v, --verbose       Activează output verbose
  -o, --output FILE   Scrie output în FILE (default: stdout)
  -n, --dry-run       Simulează acțiunile fără a le executa
  -q, --quiet         Suprimă toate mesajele non-eroare

EXEMPLE:
  $SCRIPT_NAME file.txt                    Procesează un fișier
  $SCRIPT_NAME -v -o out.txt *.log         Verbose, output în out.txt
  $SCRIPT_NAME --dry-run data/*.csv        Simulare pe fișiere CSV

Raportează bug-uri: Open an issue in GitHub
EOF
}

version() {
    echo "$SCRIPT_NAME versiunea $SCRIPT_VERSION"
}

log() {
    [[ "$QUIET" == true ]] && return
    echo "[INFO] $*" >&2
}

log_verbose() {
    [[ "$VERBOSE" == true ]] && log "$@"
}

error() {
    echo "[EROARE] $*" >&2
}

die() {
    error "$@"
    exit 1
}

#
# BUSINESS LOGIC
#

process_file() {
    local file="$1"
    
    log_verbose "Procesez: $file"
    
    if [[ ! -f "$file" ]]; then
        error "Fișierul nu există: $file"
        return 1
    fi
    
    if [[ "$DRY_RUN" == true ]]; then
        log "[DRY-RUN] Ar procesa: $file"
        return 0
    fi
    
    # Procesare efectivă
    local lines=$(wc -l < "$file")
    local words=$(wc -w < "$file")
    local bytes=$(wc -c < "$file")
    
    echo "$file: $lines linii, $words cuvinte, $bytes bytes"
}

main() {
    log_verbose "Încep procesarea..."
    log_verbose "Fișiere de procesat: ${#INPUT_FILES[@]}"
    
    local output_cmd="cat"
    [[ -n "$OUTPUT_FILE" ]] && output_cmd="tee $OUTPUT_FILE"
    
    for file in "${INPUT_FILES[@]}"; do
        process_file "$file"
    done | $output_cmd
    
    log_verbose "Procesare completă."
}

#
# PARSARE ARGUMENTE
#

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                usage
                exit 0
                ;;
            -V|--version)
                version
                exit 0
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -q|--quiet)
                QUIET=true
                shift
                ;;
            -n|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -o|--output)
                [[ -z "${2:-}" ]] && die "Opțiunea $1 necesită argument"
                OUTPUT_FILE="$2"
                shift 2
                ;;
            --output=*)
                OUTPUT_FILE="${1#*=}"
                shift
                ;;
            --)
                shift
                break
                ;;
            -*)
                die "Opțiune necunoscută: $1. Folosește -h pentru ajutor."
                ;;
            *)
                INPUT_FILES+=("$1")
                shift
                ;;
        esac
    done
    
    # Adaugă argumentele rămase după --
    INPUT_FILES+=("$@")
}

#
# VALIDARE
#

validate_arguments() {
    # Verifică că avem cel puțin un fișier
    if [[ ${#INPUT_FILES[@]} -eq 0 ]]; then
        error "Lipsesc fișierele de procesat."
        echo "Utilizare: $SCRIPT_NAME [opțiuni] file [files...]" >&2
        echo "Încearcă '\''$SCRIPT_NAME --help'\'' pentru mai multe informații." >&2
        exit 1
    fi
    
    # Verifică că verbose și quiet nu sunt ambele active
    if [[ "$VERBOSE" == true && "$QUIET" == true ]]; then
        die "Opțiunile --verbose și --quiet sunt mutual exclusive."
    fi
}

#
# EXECUȚIE
#

parse_arguments "$@"
validate_arguments
main'
    
    # Salvează scriptul
    echo "$professional_script" > "$DEMO_DIR/fileprocessor.sh"
    chmod +x "$DEMO_DIR/fileprocessor.sh"
    
    # Creează fișiere de test
    echo -e "Linia 1\nLinia 2\nLinia 3" > "$DEMO_DIR/test1.txt"
    echo -e "Hello World" > "$DEMO_DIR/test2.txt"
    
    print_code_block "Script complet (salvat în fileprocessor.sh)"
    head -80 "$DEMO_DIR/fileprocessor.sh"
    echo "... [continua] ..."
    print_code_end
    
    print_subheader "7.3 Testare script"
    
    echo -e "\n${WHITE}Test --help:${NC}"
    "$DEMO_DIR/fileprocessor.sh" --help 2>&1 | head -20
    
    echo -e "\n${WHITE}Test fără argumente (eroare):${NC}"
    "$DEMO_DIR/fileprocessor.sh" 2>&1 || true
    
    echo -e "\n${WHITE}Test normal:${NC}"
    "$DEMO_DIR/fileprocessor.sh" "$DEMO_DIR/test1.txt" "$DEMO_DIR/test2.txt"
    
    echo -e "\n${WHITE}Test verbose:${NC}"
    "$DEMO_DIR/fileprocessor.sh" -v "$DEMO_DIR/test1.txt"
    
    echo -e "\n${WHITE}Test dry-run:${NC}"
    "$DEMO_DIR/fileprocessor.sh" --dry-run --verbose "$DEMO_DIR/test1.txt"
    
    print_tip "Copiază acest pattern pentru scripturile tale profesionale!"
    
    pause_interactive
}

#
# REZUMAT
#

show_summary() {
    print_header "📋 REZUMAT: Parsare Argumente"
    
    cat << 'SUMMARY'
╔═══════════════════════════════════════════════════════════════════════════════╗
║                          CHEAT SHEET RAPID                                    ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║ PARAMETRI POZIȚIONALI:                                                        ║
║   $0        = Numele scriptului                                               ║
║   $1-$9     = Argumente (use ${10} pentru >= 10)                              ║
║   $#        = Numărul de argumente                                            ║
║   "$@"      = Toate argumentele (ÎNTOTDEAUNA cu ghilimele!)                   ║
║                                                                               ║
║ VALORI DEFAULT:                                                               ║
║   ${VAR:-default}   = Folosește default dacă VAR e goală                      ║
║   ${VAR:=default}   = Setează VAR la default dacă e goală                     ║
║   ${VAR:?error}     = Eroare dacă VAR e goală                                 ║
║                                                                               ║
║ SHIFT:                                                                        ║
║   shift       = Elimină $1, mută restul în sus                                ║
║   shift N     = Elimină primele N argumente                                   ║
║                                                                               ║
║ GETOPTS (opțiuni scurte):                                                     ║
║   while getopts ":vf:" opt; do                                                ║
║       case "$opt" in                                                          ║
║           v) verbose=true ;;                                                  ║
║           f) file="$OPTARG" ;;                                                ║
║           :) echo "Lipsește argument pentru -$OPTARG" ;;                      ║
║           ?) echo "Opțiune necunoscută: -$OPTARG" ;;                          ║
║       esac                                                                    ║
║   done                                                                        ║
║   shift $((OPTIND - 1))    # CRUCIAL!                                         ║
║                                                                               ║
║ OPȚIUNI LUNGI (manual):                                                       ║
║   while [[ $# -gt 0 ]]; do                                                    ║
║       case "$1" in                                                            ║
║           -v|--verbose) verbose=true; shift ;;                                ║
║           -o|--output)  output="$2"; shift 2 ;;                               ║
║           --output=*)   output="${1#*=}"; shift ;;                            ║
║           --)           shift; break ;;                                       ║
║           -*)           echo "Eroare"; exit 1 ;;                              ║
║           *)            args+=("$1"); shift ;;                                ║
║       esac                                                                    ║
║   done                                                                        ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
SUMMARY
    
    echo ""
    echo -e "${GREEN}✓ Demo complet!${NC}"
    echo ""
}

#
# MAIN
#

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_usage
                exit 0
                ;;
            -i|--interactive)
                INTERACTIVE=true
                shift
                ;;
            -s|--section)
                RUN_SECTION="$2"
                shift 2
                ;;
            -d|--demo)
                SPECIFIC_DEMO="$2"
                shift 2
                ;;
            *)
                echo -e "${RED}Opțiune necunoscută: $1${NC}"
                show_usage
                exit 1
                ;;
        esac
    done
}

main() {
    parse_args "$@"
    
    if [[ -n "$RUN_SECTION" ]]; then
        case "$RUN_SECTION" in
            1) section_1_positional ;;
            2) section_2_at_vs_star ;;
            3) section_3_shift ;;
            4) section_4_defaults ;;
            5) section_5_getopts ;;
            6) section_6_long_options ;;
            7) section_7_professional ;;
            *)
                echo -e "${RED}Secțiune invalidă: $RUN_SECTION${NC}"
                exit 1
                ;;
        esac
    elif [[ -n "$SPECIFIC_DEMO" ]]; then
        case "$SPECIFIC_DEMO" in
            professional|prof) section_7_professional ;;
            getopts) section_5_getopts ;;
            shift) section_3_shift ;;
            *)
                echo -e "${RED}Demo necunoscut: $SPECIFIC_DEMO${NC}"
                exit 1
                ;;
        esac
    else
        section_1_positional
        section_2_at_vs_star
        section_3_shift
        section_4_defaults
        section_5_getopts
        section_6_long_options
        section_7_professional
    fi
    
    show_summary
}

main "$@"
