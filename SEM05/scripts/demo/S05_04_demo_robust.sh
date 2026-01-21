#!/bin/bash
#
# S05_04_demo_robust.sh - Demonstrație set -euo pipefail
# 
# Sisteme de Operare | ASE București - CSIE
# Seminar 9-10: Advanced Bash Scripting
#
# SCOP: Demonstrează comportamentul set -euo pipefail și
#       cazurile UNDE NU FUNCȚIONEAZĂ (misconceptie critică 75%).
#
# UTILIZARE:
#   ./S05_04_demo_robust.sh           # Toate demo-urile
#   ./S05_04_demo_robust.sh errexit   # Doar set -e
#   ./S05_04_demo_robust.sh nounset   # Doar set -u
#   ./S05_04_demo_robust.sh pipefail  # Doar pipefail
#   ./S05_04_demo_robust.sh limits    # Limitările set -e
#

# NU activăm set -euo pipefail aici pentru a putea demonstra comportamentul!

# ============================================================
# CONSTANTE ȘI CULORI
# ============================================================
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly DIM='\033[2m'
readonly NC='\033[0m'

# ============================================================
# HELPER FUNCTIONS
# ============================================================

header() {
    echo ""
    echo -e "${BOLD}${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${BLUE}  $1${NC}"
    echo -e "${BOLD}${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo ""
}

subheader() {
    echo ""
    echo -e "${CYAN}▶ $1${NC}"
    echo -e "${CYAN}────────────────────────────────────────${NC}"
}

code() {
    echo -e "${YELLOW}${DIM}$1${NC}"
}

run_in_subshell() {
    echo -e "${BOLD}Running in subshell:${NC}"
    echo -e "${YELLOW}$1${NC}"
    echo -e "${DIM}---output---${NC}"
    bash -c "$1" 2>&1 || true
    echo -e "${DIM}---end output---${NC}"
}

good() {
    echo -e "${GREEN}✓ $1${NC}"
}

bad() {
    echo -e "${RED}✗ $1${NC}"
}

info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

critical() {
    echo -e "${RED}${BOLD}⚠⚠⚠ $1 ⚠⚠⚠${NC}"
}

pause() {
    echo ""
    read -r -p "Apasă Enter pentru a continua..." </dev/tty 2>/dev/null || true
    echo ""
}

# ============================================================
# DEMO 1: SET -E (ERREXIT)
# ============================================================

demo_errexit() {
    header "SET -E (ERREXIT) - Exit la Prima Eroare"
    
    subheader "Comportament FĂRĂ set -e"
    
    code '#!/bin/bash
# Fără set -e
echo "Start"
false         # Comandă care eșuează (exit code 1)
echo "Aceasta SE EXECUTĂ (scriptul continuă)"
true
echo "End"'
    
    echo ""
    run_in_subshell '
echo "Start"
false
echo "Aceasta SE EXECUTĂ"
true
echo "End"
'
    warning "Scriptul a continuat după eroare!"
    
    pause
    
    subheader "Comportament CU set -e"
    
    code '#!/bin/bash
set -e        # Activează errexit
echo "Start"
false         # Script se OPREȘTE aici
echo "Aceasta NU se execută"'
    
    echo ""
    run_in_subshell '
set -e
echo "Start"
false
echo "Aceasta NU se execută"
'
    good "Scriptul s-a oprit la eroare!"
    
    pause
    
    subheader "Exemplu Practic: Script Fragil vs Robust"
    
    echo "FRAGIL (fără set -e):"
    code '#!/bin/bash
cd /director/inexistent
rm -rf *      # PERICOL: rulează în directorul curent!'
    
    echo ""
    warning "Dacă cd eșuează, rm rulează în directorul curent!"
    
    echo ""
    echo "ROBUST (cu set -e):"
    code '#!/bin/bash
set -e
cd /director/inexistent  # Script se oprește aici
rm -rf *                 # NU se execută'
    
    good "Cu set -e, scriptul se oprește înainte de rm!"
}

# ============================================================
# DEMO 2: SET -U (NOUNSET)
# ============================================================

demo_nounset() {
    header "SET -U (NOUNSET) - Eroare pentru Variabile Nedefinite"
    
    subheader "Comportament FĂRĂ set -u"
    
    code '#!/bin/bash
# Fără set -u
echo "User: $USER"           # OK - variabilă de sistem
echo "Missing: $UNDEFINED"   # Gol, dar nu eroare
echo "Script continuă"'
    
    echo ""
    run_in_subshell '
echo "User: $USER"
echo "Missing: $UNDEFINED"
echo "Script continuă"
'
    warning "Variabila nedefinită e tratată ca string gol!"
    
    pause
    
    subheader "Comportament CU set -u"
    
    code '#!/bin/bash
set -u
echo "User: $USER"
echo "Missing: $UNDEFINED"   # EROARE!
echo "Nu se execută"'
    
    echo ""
    run_in_subshell '
set -u
echo "User: $USER"
echo "Missing: $UNDEFINED"
echo "Nu se execută"
'
    good "Scriptul a detectat variabila nedefinită!"
    
    pause
    
    subheader "Cum să folosești variabile opționale cu set -u"
    
    code '# Metodă 1: Default value
echo "${OPTIONAL:-valoare_default}"

# Metodă 2: Empty string ca default
echo "${OPTIONAL:-}"

# Metodă 3: Verificare explicită
if [[ -n "${OPTIONAL:-}" ]]; then
    echo "OPTIONAL e setat: $OPTIONAL"
fi'
    
    echo ""
    echo "Demonstrație:"
    run_in_subshell '
set -u
echo "Default: ${UNDEFINED:-valoare_default}"
echo "Empty: \"${UNDEFINED:-}\""
if [[ -n "${UNDEFINED:-}" ]]; then
    echo "Setat"
else
    echo "Nesetat sau gol"
fi
echo "Script continuă normal!"
'
}

# ============================================================
# DEMO 3: SET -O PIPEFAIL
# ============================================================

demo_pipefail() {
    header "SET -O PIPEFAIL - Propagarea Erorilor în Pipeline"
    
    subheader "Comportament FĂRĂ pipefail"
    
    code '#!/bin/bash
# Pipeline: false (exit 1) | true (exit 0)
false | true
echo "Exit code: $?"'
    
    echo ""
    run_in_subshell '
false | true
echo "Exit code: $?"
'
    warning "Exit code e 0 (de la true) - eroarea de la false e IGNORATĂ!"
    
    pause
    
    subheader "Comportament CU pipefail"
    
    code '#!/bin/bash
set -o pipefail
false | true
echo "Exit code: $?"'
    
    echo ""
    run_in_subshell '
set -o pipefail
false | true
echo "Exit code: $?"
'
    good "Exit code e 1 (de la false) - eroarea e PROPAGATĂ!"
    
    pause
    
    subheader "Exemplu Practic: Pipe cu Grep"
    
    echo "FĂRĂ pipefail:"
    code 'cat fisier_inexistent.txt | grep "pattern"
echo "Status: $?"'
    
    run_in_subshell '
cat fisier_inexistent.txt 2>/dev/null | grep "pattern" 2>/dev/null
echo "Status: $?"
'
    warning "Status 1 e de la grep (no match), nu de la cat!"
    
    echo ""
    echo "CU pipefail + PIPESTATUS:"
    code 'set -o pipefail
cat fisier_inexistent.txt | grep "pattern"
echo "Pipeline status: $?"
echo "Individual: ${PIPESTATUS[@]}"'
    
    run_in_subshell '
set -o pipefail
cat fisier_inexistent.txt 2>&1 | grep "pattern" 2>/dev/null
echo "Pipeline status: $?"
'
}

# ============================================================
# DEMO 4: LIMITĂRILE SET -E
# ============================================================

demo_limits() {
    header "⚠️ LIMITĂRILE SET -E - Când NU Funcționează!"
    
    critical "Aceasta e MISCONCEPTIA #1 (75% frecvență)!"
    echo ""
    info "Mulți cred că set -e oprește scriptul la ORICE eroare."
    info "GREȘIT! Există multiple cazuri unde erorile sunt IGNORATE."
    
    pause
    
    subheader "CAZUL 1: Comenzi în IF/WHILE/UNTIL"
    
    code 'set -e
if false; then        # false returnează 1, dar script NU se oprește
    echo "Nu ajunge"
fi
echo "Script continuă!"'
    
    run_in_subshell '
set -e
if false; then
    echo "Nu ajunge aici"
fi
echo "Script continuă după if!"
'
    bad "set -e NU funcționează în condiții if!"
    
    pause
    
    subheader "CAZUL 2: Comenzi urmate de || sau &&"
    
    code 'set -e
false || true         # Nu oprește - || "salvează" eroarea
echo "Continuă"
false && true         # Nu oprește - && e "condiție"
echo "Continuă"'
    
    run_in_subshell '
set -e
false || true
echo "După || : continuă"
false && true
echo "După && : continuă"
'
    bad "set -e NU funcționează cu || sau &&!"
    
    pause
    
    subheader "CAZUL 3: Funcții în Context de Test"
    
    code 'set -e
check() {
    false             # Ar trebui să oprească?
    echo "În funcție"
}
if check; then        # NU oprește - e în context de test
    echo "true"
fi
echo "Script continuă"'
    
    run_in_subshell '
set -e
check() {
    false
    echo "În funcție - se execută!"
}
if check; then
    echo "Check returned true"
else
    echo "Check returned false"
fi
echo "Script continuă după funcție în if!"
'
    bad "set -e NU funcționează pentru funcții apelate în if!"
    
    pause
    
    subheader "CAZUL 4: Negare cu !"
    
    code 'set -e
! false               # Negarea inversează exit code-ul
echo "Continuă"
! true                # Returnează 1, dar cu ! nu oprește
echo "Continuă"'
    
    run_in_subshell '
set -e
! false
echo "După \"! false\": continuă"
! true
echo "După \"! true\": continuă (deși exit code e 1!)"
'
    bad "Negarea ! dezactivează set -e!"
    
    pause
    
    subheader "CAZUL 5: Command Substitution (parțial)"
    
    code 'set -e
x=$(false)            # OPREȘTE scriptul
echo "Nu ajunge aici"'
    
    echo "Dar:"
    code 'set -e
echo "Output: $(false)"  # În unele versiuni NU oprește!
echo "Poate continua"'
    
    run_in_subshell '
set -e
echo "Test 1: înainte"
x=$(false)
echo "Test 1: nu ajunge"
'
    
    echo ""
    warning "Comportamentul variază între versiuni Bash!"
    
    pause
    
    subheader "REZUMAT: Când set -e NU funcționează"
    
    echo -e "${BOLD}set -e IGNORĂ erori în:${NC}"
    echo ""
    echo "  1. Comenzi în if/while/until/elif"
    echo "  2. Partea stângă a && sau ||"
    echo "  3. Orice comandă negată cu !"
    echo "  4. Funcții apelate în context de test"
    echo "  5. Comenzi în pipes (fără pipefail)"
    echo "  6. Subshell-uri (fără shopt inherit_errexit)"
    echo ""
    
    warning "SOLUȚIA: Verificare EXPLICITĂ a erorilor importante!"
    
    code '# Pattern recomandat:
result=$(critical_command) || {
    echo "Command failed!" >&2
    exit 1
}

# Sau:
if ! critical_command; then
    echo "Command failed!" >&2
    exit 1
fi'
}

# ============================================================
# DEMO 5: COMBINAȚIA COMPLETĂ
# ============================================================

demo_combined() {
    header "COMBINAȚIA COMPLETĂ: set -euo pipefail"
    
    subheader "Shebang Recomandat"
    
    code '#!/bin/bash
set -euo pipefail
IFS=$'\''\n\t'\'''
    
    echo ""
    echo "Ce face fiecare:"
    echo "  -e (errexit)   : Exit la prima eroare (cu limitări!)"
    echo "  -u (nounset)   : Eroare pentru variabile nedefinite"
    echo "  -o pipefail    : Propagă erori în pipes"
    echo "  IFS            : Separator sigur (evită word splitting)"
    
    pause
    
    subheader "Script Complet Demonstrativ"
    
    code '#!/bin/bash
set -euo pipefail
IFS=$'\''\n\t'\''

# Variabile cu defaults (pentru set -u)
INPUT="${1:-}"
DEBUG="${DEBUG:-false}"

# Verificare explicită (nu te baza doar pe set -e)
[ -n "$INPUT" ] || { echo "Usage: $0 <file>"; exit 1; }
[ -f "$INPUT" ] || { echo "File not found: $INPUT"; exit 1; }

# Pipe sigur (cu pipefail)
result=$(cat "$INPUT" | grep "pattern" | wc -l)
echo "Found $result matches"

# Cleanup
trap '\''echo "Cleanup..."; rm -f /tmp/temp_$$'\'' EXIT'
    
    pause
    
    subheader "Disable Temporar (când e necesar)"
    
    echo "Pentru comenzi care pot eșua legitim:"
    code '# Metoda 1: || true
command_that_might_fail || true

# Metoda 2: set +e temporar
set +e
command_that_might_fail
status=$?
set -e
if [ $status -ne 0 ]; then
    echo "Command failed with $status"
fi

# Metoda 3: || cu handling
command_that_might_fail || {
    echo "Warning: command failed, continuing..."
}'
}

# ============================================================
# DEMO 6: QUIZ INTERACTIV
# ============================================================

demo_quiz() {
    header "QUIZ: set -euo pipefail - Testează-ți Cunoștințele!"
    
    local score=0
    local total=5
    
    # Q1
    echo -e "${BOLD}Q1: Cu 'set -e', scriptul se oprește dacă 'false' e într-un if?${NC}"
    echo "    a) Da"
    echo "    b) Nu"
    read -r -p "Răspuns (a/b): " ans </dev/tty
    if [[ "$ans" == "b" ]]; then
        good "Corect! set -e nu funcționează în context de test (if/while)."
        ((score++))
    else
        bad "Greșit. set -e ignoră erori în if/while/until."
    fi
    echo ""
    
    # Q2
    echo -e "${BOLD}Q2: 'false | true' returnează ce exit code FĂRĂ pipefail?${NC}"
    echo "    a) 0"
    echo "    b) 1"
    echo "    c) Depinde"
    read -r -p "Răspuns (a/b/c): " ans </dev/tty
    if [[ "$ans" == "a" ]]; then
        good "Corect! Fără pipefail, returnează exit code-ul ultimei comenzi (true=0)."
        ((score++))
    else
        bad "Greșit. Fără pipefail, pipeline returnează status-ul ultimei comenzi."
    fi
    echo ""
    
    # Q3
    echo -e "${BOLD}Q3: Cu 'set -u', cum accesezi o variabilă opțională?${NC}"
    echo "    a) \$VAR"
    echo "    b) \${VAR:-default}"
    echo "    c) Nu se poate"
    read -r -p "Răspuns (a/b/c): " ans </dev/tty
    if [[ "$ans" == "b" ]]; then
        good "Corect! \${VAR:-default} oferă valoare default și evită eroarea."
        ((score++))
    else
        bad "Greșit. \${VAR:-default} returnează default dacă VAR e nedefinită."
    fi
    echo ""
    
    # Q4
    echo -e "${BOLD}Q4: 'false || true' oprește scriptul cu set -e?${NC}"
    echo "    a) Da"
    echo "    b) Nu"
    read -r -p "Răspuns (a/b): " ans </dev/tty
    if [[ "$ans" == "b" ]]; then
        good "Corect! || \"salvează\" eroarea - set -e nu se aplică."
        ((score++))
    else
        bad "Greșit. Comenzi urmate de || sau && nu declanșează set -e."
    fi
    echo ""
    
    # Q5
    echo -e "${BOLD}Q5: Ce face IFS=\$'\\n\\t'?${NC}"
    echo "    a) Setează newline și tab ca separatori (evită spații)"
    echo "    b) Activează debugging"
    echo "    c) Setează encoding UTF-8"
    read -r -p "Răspuns (a/b/c): " ans </dev/tty
    if [[ "$ans" == "a" ]]; then
        good "Corect! Elimină spațiul din IFS pentru word splitting mai sigur."
        ((score++))
    else
        bad "Greșit. IFS controlează cum Bash separă cuvintele."
    fi
    echo ""
    
    # Rezultat
    header "REZULTAT QUIZ"
    echo -e "Scor: ${BOLD}$score / $total${NC}"
    
    if [ "$score" -eq "$total" ]; then
        good "Excelent! Înțelegi perfect set -euo pipefail!"
    elif [ "$score" -ge 3 ]; then
        info "Bine! Revizuiește cazurile speciale."
    else
        warning "Recitește materialul despre limitările set -e!"
    fi
}

# ============================================================
# MAIN
# ============================================================

main() {
    case "${1:-all}" in
        errexit|-e)
            demo_errexit
            ;;
        nounset|-u)
            demo_nounset
            ;;
        pipefail)
            demo_pipefail
            ;;
        limits)
            demo_limits
            ;;
        combined)
            demo_combined
            ;;
        quiz)
            demo_quiz
            ;;
        all)
            demo_errexit
            pause
            demo_nounset
            pause
            demo_pipefail
            pause
            demo_limits
            pause
            demo_combined
            pause
            demo_quiz
            ;;
        *)
            echo "Usage: $0 [errexit|nounset|pipefail|limits|combined|quiz|all]"
            exit 1
            ;;
    esac
    
    echo ""
    echo -e "${BOLD}${GREEN}═══ Demo set -euo pipefail Completat! ═══${NC}"
}

main "$@"
