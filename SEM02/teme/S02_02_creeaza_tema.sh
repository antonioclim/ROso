#!/bin/bash
# 
#  S02_02_creeaza_tema.sh - Generator Template Temă Seminar 2
# 
#
# DESCRIERE:
#     Creează structura de directoare și fișierele template pentru tema
#     Seminarului 3-4. Include template-uri pentru toate exercițiile și
#     un script de auto-verificare.
#
# UTILIZARE:
#     ./S02_02_creeaza_tema.sh "Popescu Ion" 1051
#     ./S02_02_creeaza_tema.sh --interactive
#
# AUTOR: Assistant pentru ASE București - CSIE
# VERSIUNE: 1.0
# DATA: Ianuarie 2025
# 

set -e

# 
# SECȚIUNEA 1: CONFIGURARE ȘI CULORI
# 

# Culori ANSI
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    MAGENTA='\033[0;35m'
    CYAN='\033[0;36m'
    WHITE='\033[1;37m'
    NC='\033[0m' # No Color
    BOLD='\033[1m'
else
    RED='' GREEN='' YELLOW='' BLUE='' MAGENTA='' CYAN='' WHITE='' NC='' BOLD=''
fi

# Configurare
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SEMINAR_NUM="03-04"
TEMA_PREFIX="TEMA_SEM${SEMINAR_NUM}"

# 
# SECȚIUNEA 2: FUNCȚII UTILITARE
# 

print_banner() {
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                                                                               ║"
    echo "║   📝  GENERATOR TEMPLATE TEMĂ - Seminarul 3-4                                 ║"
    echo "║       Operatori | Redirecționare | Filtre | Bucle                             ║"
    echo "║                                                                               ║"
    echo "║       ASE București - CSIE | Sisteme de Operare                               ║"
    echo "║                                                                               ║"
    echo "╚═══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_usage() {
    echo -e "${BOLD}Utilizare:${NC}"
    echo "  $0 \"Nume Student\" grupa"
    echo "  $0 --interactive"
    echo ""
    echo -e "${BOLD}Exemple:${NC}"
    echo "  $0 \"Popescu Ion\" 1051"
    echo "  $0 \"Maria Ionescu\" 1052"
    echo ""
    echo -e "${BOLD}Opțiuni:${NC}"
    echo "  -i, --interactive    Mod interactiv (solicită datele)"
    echo "  -h, --help           Afișează acest mesaj"
    echo "  -o, --output DIR     Directorul de output (default: directorul curent)"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1" >&2
}

# Curăță numele pentru a fi valid ca director
sanitize_name() {
    local name="$1"
    # Înlocuiește caracterele non-alfanumerice cu `_`
    # Păstrează literele românești transformate în ASCII
    echo "$name" | \
        sed 's/ă/a/g; s/â/a/g; s/î/i/g; s/ș/s/g; s/ț/t/g' | \
        sed 's/Ă/A/g; s/Â/A/g; s/Î/I/g; s/Ș/S/g; s/Ț/T/g' | \
        tr '[:upper:]' '[:lower:]' | \
        tr ' ' '_' | \
        tr -cd '[:alnum:]_-'
}

# 
# SECȚIUNEA 3: PARSARE ARGUMENTE
# 

INTERACTIVE=false
OUTPUT_DIR="."
STUDENT_NAME=""
STUDENT_GROUP=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--interactive)
            INTERACTIVE=true
            shift
            ;;
        -h|--help)
            print_banner
            print_usage
            exit 0
            ;;
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -*)
            print_error "Opțiune necunoscută: $1"
            print_usage
            exit 1
            ;;
        *)
            if [[ -z "$STUDENT_NAME" ]]; then
                STUDENT_NAME="$1"
            elif [[ -z "$STUDENT_GROUP" ]]; then
                STUDENT_GROUP="$1"
            else
                print_error "Prea multe argumente!"
                print_usage
                exit 1
            fi
            shift
            ;;
    esac
done

# 
# SECȚIUNEA 4: COLECTARE DATE
# 

print_banner

if [[ "$INTERACTIVE" == true ]] || [[ -z "$STUDENT_NAME" ]] || [[ -z "$STUDENT_GROUP" ]]; then
    echo -e "${BOLD}📋 Completează datele tale:${NC}"
    echo ""
    
    if [[ -z "$STUDENT_NAME" ]]; then
        read -p "Nume și prenume: " STUDENT_NAME
    fi
    
    if [[ -z "$STUDENT_GROUP" ]]; then
        read -p "Grupa (ex: 1051): " STUDENT_GROUP
    fi
    
    echo ""
fi

# Validare
if [[ -z "$STUDENT_NAME" ]]; then
    print_error "Numele studentului este obligatoriu!"
    exit 1
fi

if [[ -z "$STUDENT_GROUP" ]]; then
    print_error "Grupa este obligatorie!"
    exit 1
fi

# Generare nume director
SAFE_NAME=$(sanitize_name "$STUDENT_NAME")
DIR_NAME="${TEMA_PREFIX}_${SAFE_NAME}_${STUDENT_GROUP}"
TARGET_DIR="${OUTPUT_DIR}/${DIR_NAME}"

# Verificare existență
if [[ -d "$TARGET_DIR" ]]; then
    print_warning "Directorul $TARGET_DIR există deja!"
    read -p "Suprascrii? (y/n): " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        print_info "Operațiune anulată."
        exit 0
    fi
    rm -rf "$TARGET_DIR"
fi

# 
# SECȚIUNEA 5: CREARE STRUCTURĂ
# 

echo -e "${BOLD}🔨 Creare structură temă...${NC}"
echo ""

# Creare directoare
mkdir -p "$TARGET_DIR"/{exercitii,teste,output}
print_success "Creat: $TARGET_DIR/"

# 
# SECȚIUNEA 6: GENERARE FIȘIERE TEMPLATE
# 

# --- README.md ---
cat > "$TARGET_DIR/README.md" << EOF
#  Tema Seminar 2: Operatori, Redirecționare, Filtre, Bucle

**Student:** ${STUDENT_NAME}  
**Grupa:** ${STUDENT_GROUP}  
**Data generării:** $(date '+%Y-%m-%d %H:%M')

##  Structura Temei

\`\`\`
${DIR_NAME}/
├── README.md              # Acest fișier
├── exercitii/
│   ├── ex1_operatori.sh   # Exercițiul 1: Operatori de control
│   ├── ex2_redirectare.sh # Exercițiul 2: Redirecționare I/O
│   ├── ex3_filtre.sh      # Exercițiul 3: Filtre de text
│   ├── ex4_bucle.sh       # Exercițiul 4: Bucle
│   └── ex5_integrat.sh    # Exercițiul 5: Script integrat
├── teste/
│   └── test_data/         # Date pentru testare
├── output/                # Directorul pentru output-uri
└── verifica_tema.sh       # Script de auto-verificare
\`\`\`

##  Cerințe

Completează fiecare exercițiu conform instrucțiunilor din comentarii.
Rulează \`./verifica_tema.sh\` pentru a verifica progresul.

##  Checklist Predare

- [ ] Toate scripturile au shebang (\`#!/bin/bash\`)
- [ ] Toate scripturile sunt executabile (\`chmod +x\`)
- [ ] Fiecare exercițiu funcționează fără erori
- [ ] Am rulat \`./verifica_tema.sh\` și am corectat erorile
- [ ] Am arhivat tema: \`tar -czvf ${DIR_NAME}.tar.gz ${DIR_NAME}/\`

##  Predare

1. Verifică tema: \`./verifica_tema.sh\`
2. Arhivează: \`tar -czvf ${DIR_NAME}.tar.gz ${DIR_NAME}/\`
3. Încarcă pe platforma de curs

---
*Generată automat de S02_02_creeaza_tema.sh*
EOF
print_success "Creat: README.md"

# --- Exercițiul 1: Operatori ---
cat > "$TARGET_DIR/exercitii/ex1_operatori.sh" << 'SCRIPT'
#!/bin/bash
# 
# EXERCIȚIUL 1: Operatori de Control (10%)
# 
#
# OBIECTIV: Demonstrează înțelegerea operatorilor de control
#
# CERINȚE:
# 1. Folosește operatorul && pentru a executa comenzi doar dacă precedenta reușește
# 2. Folosește operatorul || pentru tratarea erorilor
# 3. Folosește operatorul | (pipe) pentru a conecta comenzi
# 4. Folosește operatorul & pentru a rula în background
# 5. Combină operatorii într-o comandă complexă
#
# Capcană: NU modifica comentariile de secțiune (# [TEST-...])
# 

# [TEST-1] Creează directorul "backup" dacă nu există, apoi afișează "OK"
# TIP: Folosește && pentru a executa echo doar dacă mkdir reușește
# SCRIE COMANDA TA MAI JOS:

# [TEST-2] Încearcă să citești un fișier inexistent și afișează eroare
# TIP: Folosește || pentru a trata cazul când cat eșuează
# SCRIE COMANDA TA MAI JOS:

# [TEST-3] Găsește procesele tale și numără-le
# TIP: Folosește | pentru a conecta ps cu wc
# SCRIE COMANDA TA MAI JOS:

# [TEST-4] Demonstrează rularea în background
# TIP: Pornește un sleep în background și afișează PID-ul
# SCRIE COMANDA TA MAI JOS:

# [TEST-5] Comandă complexă: verifică un fișier, procesează-l și tratează eroarea
# TIP: Combinație de &&, ||, și |
# Exemplu: Verifică dacă /etc/passwd există, extrage userii, și numără-i
# SCRIE COMANDA TA MAI JOS:

echo "Exercițiul 1 completat!"
SCRIPT
chmod +x "$TARGET_DIR/exercitii/ex1_operatori.sh"
print_success "Creat: exercitii/ex1_operatori.sh"

# --- Exercițiul 2: Redirecționare ---
cat > "$TARGET_DIR/exercitii/ex2_redirectare.sh" << 'SCRIPT'
#!/bin/bash
# 
# EXERCIȚIUL 2: Redirecționare I/O (12%)
# 
#
# OBIECTIV: Demonstrează înțelegerea redirecționării I/O
#
# CERINȚE:
# 1. Folosește > pentru a suprascrie un fișier
# 2. Folosește >> pentru a adăuga la un fișier
# 3. Folosește 2> pentru a redirecționa stderr
# 4. Folosește 2>&1 pentru a combina stdout și stderr
# 5. Folosește << (here document) pentru input multi-line
#
# Capcană: NU modifica comentariile de secțiune (# [TEST-...])
# 

# Director de lucru
WORK_DIR="../output"
mkdir -p "$WORK_DIR"

# [TEST-1] Creează fișierul "test1.txt" cu textul "Prima linie"
# TIP: Folosește > pentru suprascrie
# SCRIE COMANDA TA MAI JOS:

# [TEST-2] Adaugă "A doua linie" la fișierul creat anterior
# TIP: Folosește >> pentru append
# SCRIE COMANDA TA MAI JOS:

# [TEST-3] Redirecționează erorile de la ls /inexistent într-un fișier
# TIP: Folosește 2> pentru stderr
# SCRIE COMANDA TA MAI JOS:

# [TEST-4] Combină stdout și stderr într-un singur fișier
# TIP: Folosește comanda: ls /home /inexistent 2>&1 > combined.txt
# sau mai bine: ls /home /inexistent &> combined.txt
# SCRIE COMANDA TA MAI JOS:

# [TEST-5] Folosește un Here Document pentru a crea un fișier de configurare
# Fișierul trebuie să conțină cel puțin 3 linii
# TIP: Folosește << EOF ... EOF
# SCRIE COMANDA TA MAI JOS:

echo "Exercițiul 2 completat!"
echo "Verifică fișierele create în $WORK_DIR"
SCRIPT
chmod +x "$TARGET_DIR/exercitii/ex2_redirectare.sh"
print_success "Creat: exercitii/ex2_redirectare.sh"

# --- Exercițiul 3: Filtre ---
cat > "$TARGET_DIR/exercitii/ex3_filtre.sh" << 'SCRIPT'
#!/bin/bash
# 
# EXERCIȚIUL 3: Filtre de Text (12%)
# 
#
# OBIECTIV: Demonstrează utilizarea filtrelor Unix
#
# CERINȚE:
# 1. Folosește sort pentru sortare
# 2. Folosește uniq pentru eliminarea duplicatelor (Capcană: trebuie sort înainte!)
# 3. Folosește cut pentru extragerea coloanelor
# 4. Folosește tr pentru modificări de caractere
# 5. Construiește un pipeline complex cu minim 3 filtre
#
# Capcană: NU modifica comentariile de secțiune (# [TEST-...])
# 

# Creează fișier de test
TEST_FILE="../teste/test_data/colors.txt"
mkdir -p "$(dirname "$TEST_FILE")"

cat > "$TEST_FILE" << 'EOF'
rosu
verde
rosu
albastru
verde
rosu
galben
albastru
EOF

# [TEST-1] Sortează fișierul colors.txt alfabetic și afișează rezultatul
# SCRIE COMANDA TA MAI JOS:

# [TEST-2] Elimină duplicatele din colors.txt (Capcană: trebuie sortat întâi!)
# TIP: pattern-ul corect este sort | uniq, NU doar uniq
# SCRIE COMANDA TA MAI JOS:

# [TEST-3] Extrage prima coloană din /etc/passwd (username-uri)
# TIP: Folosește cut cu delimitatorul ':'
# SCRIE COMANDA TA MAI JOS:

# [TEST-4] modifică toate literele mici în majuscule din colors.txt
# TIP: Folosește tr 'a-z' 'A-Z'
# SCRIE COMANDA TA MAI JOS:

# [TEST-5] Pipeline complex: din /etc/passwd, extrage username-urile,
# sortează-le, numără-le pe fiecare (chiar dacă sunt unice) și afișează top 5
# TIP: cut -d':' -f1 | sort | uniq -c | sort -rn | head -5
# SCRIE COMANDA TA MAI JOS:

echo "Exercițiul 3 completat!"
SCRIPT
chmod +x "$TARGET_DIR/exercitii/ex3_filtre.sh"
print_success "Creat: exercitii/ex3_filtre.sh"

# --- Exercițiul 4: Bucle ---
cat > "$TARGET_DIR/exercitii/ex4_bucle.sh" << 'SCRIPT'
#!/bin/bash
# 
# EXERCIȚIUL 4: Bucle (11%)
# 
#
# OBIECTIV: Demonstrează utilizarea buclelor în Bash
#
# CERINȚE:
# 1. Folosește for cu o listă de valori
# 2. Folosește for cu brace expansion ({1..5})
# 3. Folosește while pentru citirea unui fișier
# 4. Demonstrează înțelegerea break și continue
#
#  CAPCANE DE EVITAT:
# - {1..$N} NU funcționează cu variabile! Folosește $(seq 1 $N) sau for ((i=1; i<=N; i++))
# - cat file | while read pierde variabilele! Folosește while read < file
#
# Capcană: NU modifica comentariile de secțiune (# [TEST-...])
# 

# [TEST-1] Bucla for cu listă: afișează culorile rosu, verde, albastru
# SCRIE COMANDA TA MAI JOS:

# [TEST-2] Bucla for cu brace expansion: afișează numerele de la 1 la 5
# TIP: Folosește {1..5}
# SCRIE COMANDA TA MAI JOS:

# [TEST-3] Bucla for cu variabilă
# GREȘIT: for i in {1..$N} - NU VA FUNCȚIONA!
# CORECT: Folosește $(seq 1 $N) sau for ((i=1; i<=N; i++))
N=3
echo "Afișează numerele de la 1 la $N:"
# SCRIE COMANDA TA MAI JOS (folosind sintaxa CORECTĂ):

# [TEST-4] Bucla while pentru citirea unui fișier linie cu linie
# GREȘIT: cat file | while read line - pierde variabilele!
# CORECT: while read line; do ... done < file
# Citește fișierul ../teste/test_data/colors.txt și afișează fiecare linie numerotată
# SCRIE COMANDA TA MAI JOS:

# [TEST-5] Demonstrează break: ieși din buclă când găsești "verde"
echo "Caută 'verde' și oprește-te:"
# SCRIE COMANDA TA MAI JOS:

echo "Exercițiul 4 completat!"
SCRIPT
chmod +x "$TARGET_DIR/exercitii/ex4_bucle.sh"
print_success "Creat: exercitii/ex4_bucle.sh"

# --- Exercițiul 5: Script Integrat ---
cat > "$TARGET_DIR/exercitii/ex5_integrat.sh" << 'SCRIPT'
#!/bin/bash
# 
# EXERCIȚIUL 5: Script Integrat (15%)
# 
#
# OBIECTIV: Creează un script complet care combină toate conceptele
#
# CERINȚE OBLIGATORII:
# - Minim 30 de linii de cod (fără comentarii goale)
# - Minim 2 funcții definite
# - Tratarea erorilor (verificare argumente, fișiere existente)
# - Procesare de argumente din linia de comandă
# - Afișarea unui mesaj de help cu -h sau --help
# - Folosirea buclelor
# - Folosirea filtrelor (sort, uniq, cut, etc.)
# - Redirecționare I/O (log-uri, output în fișiere)
#
# SUGESTIE DE TEMĂ:
# Creează un "Analizator de Directoare" care:
# 1. Primește un director ca argument
# 2. Analizează toate fișierele din director
# 3. Generează un raport cu:
#    - Numărul de fișiere per extensie
#    - Top 5 cele mai mari fișiere
#    - Data ultimei modificări
# 4. Salvează raportul într-un fișier
#
# 

# SCRIE SCRIPTUL TĂU MAI JOS:
# (Șterge acest comentariu și înlocuiește cu codul tău)

echo "TODO: Implementează scriptul integrat"
SCRIPT
chmod +x "$TARGET_DIR/exercitii/ex5_integrat.sh"
print_success "Creat: exercitii/ex5_integrat.sh"

# --- Script de Verificare ---
cat > "$TARGET_DIR/verifica_tema.sh" << 'SCRIPT'
#!/bin/bash
# 
#  Script de Auto-Verificare Temă
# 

set -e

# Culori
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'
BOLD='\033[1m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXERCITII_DIR="$SCRIPT_DIR/exercitii"
TOTAL_SCORE=0
MAX_SCORE=0

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}   🔍 VERIFICARE TEMĂ - Seminar 2${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo ""

check_file() {
    local file="$1"
    local points="$2"
    local name=$(basename "$file")
    
    MAX_SCORE=$((MAX_SCORE + points))
    
    echo -e "${BOLD}📄 Verificare: $name ($points puncte)${NC}"
    
    # Verifică existența
    if [[ ! -f "$file" ]]; then
        echo -e "  ${RED}✗${NC} Fișierul nu există!"
        return
    fi
    
    # Verifică shebang
    if ! head -1 "$file" | grep -q '^#!/bin/bash'; then
        echo -e "  ${YELLOW}⚠${NC} Lipsește shebang (#!/bin/bash)"
    else
        echo -e "  ${GREEN}✓${NC} Shebang prezent"
    fi
    
    # Verifică permisiuni
    if [[ ! -x "$file" ]]; then
        echo -e "  ${YELLOW}⚠${NC} Fișierul nu este executabil"
        chmod +x "$file"
        echo -e "  ${BLUE}ℹ${NC} Am adăugat permisiunea de execuție"
    else
        echo -e "  ${GREEN}✓${NC} Permisiuni corecte"
    fi
    
    # Verifică sintaxa
    if ! bash -n "$file" 2>/dev/null; then
        echo -e "  ${RED}✗${NC} Erori de sintaxă!"
        bash -n "$file" 2>&1 | head -5 | sed 's/^/    /'
        return
    else
        echo -e "  ${GREEN}✓${NC} Sintaxă corectă"
    fi
    
    # Verificări specifice per exercițiu
    case "$name" in
        ex1_operatori.sh)
            check_operators "$file"
            ;;
        ex2_redirectare.sh)
            check_redirection "$file"
            ;;
        ex3_filtre.sh)
            check_filters "$file"
            ;;
        ex4_bucle.sh)
            check_loops "$file"
            ;;
        ex5_integrat.sh)
            check_integrated "$file"
            ;;
    esac
    
    echo ""
}

check_operators() {
    local file="$1"
    local score=0
    
    # Verifică prezența operatorilor
    grep -q '&&' "$file" && { echo -e "  ${GREEN}✓${NC} Folosește &&"; ((score+=2)); } || echo -e "  ${RED}✗${NC} Lipsește &&"
    grep -q '||' "$file" && { echo -e "  ${GREEN}✓${NC} Folosește ||"; ((score+=2)); } || echo -e "  ${RED}✗${NC} Lipsește ||"
    grep -q '|' "$file" && { echo -e "  ${GREEN}✓${NC} Folosește | (pipe)"; ((score+=2)); } || echo -e "  ${RED}✗${NC} Lipsește |"
    grep -q '&$\|& ' "$file" && { echo -e "  ${GREEN}✓${NC} Folosește & (background)"; ((score+=2)); } || echo -e "  ${RED}✗${NC} Lipsește &"
    
    # Verifică execuția
    if timeout 5 bash "$file" &>/dev/null; then
        echo -e "  ${GREEN}✓${NC} Scriptul rulează fără erori"
        ((score+=2))
    else
        echo -e "  ${YELLOW}⚠${NC} Scriptul are probleme la execuție"
    fi
    
    TOTAL_SCORE=$((TOTAL_SCORE + score))
    echo -e "  ${BLUE}Scor parțial: $score/10${NC}"
}

check_redirection() {
    local file="$1"
    local score=0
    
    grep -q '>' "$file" && { echo -e "  ${GREEN}✓${NC} Folosește > (suprascrie)"; ((score+=2)); } || echo -e "  ${RED}✗${NC} Lipsește >"
    grep -q '>>' "$file" && { echo -e "  ${GREEN}✓${NC} Folosește >> (append)"; ((score+=2)); } || echo -e "  ${RED}✗${NC} Lipsește >>"
    grep -q '2>' "$file" && { echo -e "  ${GREEN}✓${NC} Folosește 2> (stderr)"; ((score+=2)); } || echo -e "  ${RED}✗${NC} Lipsește 2>"
    grep -qE '2>&1|&>' "$file" && { echo -e "  ${GREEN}✓${NC} Folosește 2>&1 sau &>"; ((score+=2)); } || echo -e "  ${RED}✗${NC} Lipsește combinare streams"
    grep -q '<<' "$file" && { echo -e "  ${GREEN}✓${NC} Folosește << (here doc)"; ((score+=4)); } || echo -e "  ${RED}✗${NC} Lipsește here document"
    
    TOTAL_SCORE=$((TOTAL_SCORE + score))
    echo -e "  ${BLUE}Scor parțial: $score/12${NC}"
}

check_filters() {
    local file="$1"
    local score=0
    
    grep -q 'sort' "$file" && { echo -e "  ${GREEN}✓${NC} Folosește sort"; ((score+=2)); } || echo -e "  ${RED}✗${NC} Lipsește sort"
    grep -q 'uniq' "$file" && { echo -e "  ${GREEN}✓${NC} Folosește uniq"; ((score+=2)); } || echo -e "  ${RED}✗${NC} Lipsește uniq"
    grep -q 'cut' "$file" && { echo -e "  ${GREEN}✓${NC} Folosește cut"; ((score+=2)); } || echo -e "  ${RED}✗${NC} Lipsește cut"
    grep -q 'tr' "$file" && { echo -e "  ${GREEN}✓${NC} Folosește tr"; ((score+=2)); } || echo -e "  ${RED}✗${NC} Lipsește tr"
    
    # Verifică pattern-ul corect sort | uniq
    if grep -q 'sort.*|.*uniq' "$file"; then
        echo -e "  ${GREEN}✓${NC} Pattern corect: sort | uniq"
        ((score+=2))
    else
        echo -e "  ${YELLOW}⚠${NC} Verifică dacă folosești sort ÎNAINTE de uniq!"
    fi
    
    # Verifică pipeline complex (minim 3 |)
    if grep -qE '\|.*\|.*\|' "$file"; then
        echo -e "  ${GREEN}✓${NC} Pipeline complex (3+ comenzi)"
        ((score+=2))
    else
        echo -e "  ${YELLOW}⚠${NC} Adaugă un pipeline cu minim 3 comenzi"
    fi
    
    TOTAL_SCORE=$((TOTAL_SCORE + score))
    echo -e "  ${BLUE}Scor parțial: $score/12${NC}"
}

check_loops() {
    local file="$1"
    local score=0
    
    grep -q 'for' "$file" && { echo -e "  ${GREEN}✓${NC} Folosește for"; ((score+=3)); } || echo -e "  ${RED}✗${NC} Lipsește for"
    grep -q 'while' "$file" && { echo -e "  ${GREEN}✓${NC} Folosește while"; ((score+=3)); } || echo -e "  ${RED}✗${NC} Lipsește while"
    
    # Verifică BUG-ul {1..$N}
    if grep -qE '\{1\.\.\$[A-Za-z_]' "$file"; then
        echo -e "  ${RED}✗${NC} BUG DETECTAT: {1..\$N} nu funcționează cu variabile!"
        echo -e "    ${YELLOW}→ Folosește \$(seq 1 \$N) sau for ((i=1; i<=N; i++))${NC}"
    else
        echo -e "  ${GREEN}✓${NC} Nu are bug-ul brace expansion"
        ((score+=2))
    fi
    
    # Verifică BUG-ul cat | while
    if grep -qE 'cat.*\|.*while\s+read' "$file"; then
        echo -e "  ${RED}✗${NC} BUG DETECTAT: cat file | while read pierde variabilele!"
        echo -e "    ${YELLOW}→ Folosește: while read line; do ... done < file${NC}"
    else
        echo -e "  ${GREEN}✓${NC} Nu are bug-ul subshell"
        ((score+=2))
    fi
    
    # Verifică while read < file (pattern-ul corect)
    if grep -qE 'while.*read.*<|done\s*<' "$file"; then
        echo -e "  ${GREEN}✓${NC} Pattern corect: while read ... < file"
        ((score+=1))
    fi
    
    TOTAL_SCORE=$((TOTAL_SCORE + score))
    echo -e "  ${BLUE}Scor parțial: $score/11${NC}"
}

check_integrated() {
    local file="$1"
    local score=0
    local lines=$(grep -v '^\s*#' "$file" | grep -v '^\s*$' | wc -l)
    
    echo -e "  ${BLUE}Linii de cod: $lines${NC}"
    
    if [[ $lines -ge 30 ]]; then
        echo -e "  ${GREEN}✓${NC} Minim 30 linii ($lines)"
        ((score+=3))
    else
        echo -e "  ${YELLOW}⚠${NC} Sub 30 linii ($lines)"
    fi
    
    # Verifică funcții
    local func_count=$(grep -cE '^\s*[a-zA-Z_][a-zA-Z_0-9]*\s*\(\)' "$file" || echo 0)
    if [[ $func_count -ge 2 ]]; then
        echo -e "  ${GREEN}✓${NC} Minim 2 funcții ($func_count)"
        ((score+=3))
    else
        echo -e "  ${YELLOW}⚠${NC} Sub 2 funcții ($func_count)"
    fi
    
    # Verifică tratare erori
    grep -qE '\$#|if.*\[.*-[fdeznr]|\[\[.*\]\]' "$file" && { echo -e "  ${GREEN}✓${NC} Tratare erori/verificări"; ((score+=2)); } || echo -e "  ${YELLOW}⚠${NC} Lipsește tratarea erorilor"
    
    # Verifică help
    grep -qE '\-h|--help|usage|Usage|USAGE' "$file" && { echo -e "  ${GREEN}✓${NC} Mesaj de help"; ((score+=2)); } || echo -e "  ${YELLOW}⚠${NC} Lipsește help"
    
    # Verifică bucle
    grep -qE 'for|while' "$file" && { echo -e "  ${GREEN}✓${NC} Folosește bucle"; ((score+=2)); } || echo -e "  ${YELLOW}⚠${NC} Lipsesc buclele"
    
    # Verifică filtre
    grep -qE 'sort|uniq|cut|tr|wc|head|tail' "$file" && { echo -e "  ${GREEN}✓${NC} Folosește filtre"; ((score+=2)); } || echo -e "  ${YELLOW}⚠${NC} Lipsesc filtrele"
    
    # Verifică redirecționare
    grep -qE '>|>>' "$file" && { echo -e "  ${GREEN}✓${NC} Folosește redirecționare"; ((score+=1)); } || echo -e "  ${YELLOW}⚠${NC} Lipsește redirecționarea"
    
    TOTAL_SCORE=$((TOTAL_SCORE + score))
    echo -e "  ${BLUE}Scor parțial: $score/15${NC}"
}

# Rulează verificările
check_file "$EXERCITII_DIR/ex1_operatori.sh" 10
check_file "$EXERCITII_DIR/ex2_redirectare.sh" 12
check_file "$EXERCITII_DIR/ex3_filtre.sh" 12
check_file "$EXERCITII_DIR/ex4_bucle.sh" 11
check_file "$EXERCITII_DIR/ex5_integrat.sh" 15

# Scor total
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo ""
PERCENTAGE=$((TOTAL_SCORE * 100 / 60))

if [[ $PERCENTAGE -ge 90 ]]; then
    GRADE="A"
    COLOR=$GREEN
elif [[ $PERCENTAGE -ge 80 ]]; then
    GRADE="B"
    COLOR=$GREEN
elif [[ $PERCENTAGE -ge 70 ]]; then
    GRADE="C"
    COLOR=$YELLOW
elif [[ $PERCENTAGE -ge 60 ]]; then
    GRADE="D"
    COLOR=$YELLOW
elif [[ $PERCENTAGE -ge 50 ]]; then
    GRADE="E"
    COLOR=$YELLOW
else
    GRADE="F"
    COLOR=$RED
fi

echo -e "${BOLD}📊 REZULTAT FINAL${NC}"
echo -e "   Scor: ${COLOR}${TOTAL_SCORE}/60${NC} (${PERCENTAGE}%)"
echo -e "   Observație: ${COLOR}${BOLD}${GRADE}${NC}"
echo ""

if [[ $PERCENTAGE -lt 50 ]]; then
    echo -e "${YELLOW}💡 Trebuie să mai lucrezi la temă pentru a promova!${NC}"
elif [[ $PERCENTAGE -lt 80 ]]; then
    echo -e "${BLUE}💡 Tema este acceptabilă, dar poți îmbunătăți!${NC}"
else
    echo -e "${GREEN}🎉 Excelent! Tema este foarte bună!${NC}"
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}"
SCRIPT
chmod +x "$TARGET_DIR/verifica_tema.sh"
print_success "Creat: verifica_tema.sh"

# Creare date de test
mkdir -p "$TARGET_DIR/teste/test_data"
cat > "$TARGET_DIR/teste/test_data/sample.txt" << 'EOF'
Linia 1 - test
Linia 2 - exemplu
Linia 3 - demo
EOF
print_success "Creat: teste/test_data/"

# 
# SECȚIUNEA 7: FINALIZARE
# 

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}  ✅ TEMPLATE TEMĂ CREAT CU SUCCES!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "  📁 Locație: ${CYAN}${TARGET_DIR}${NC}"
echo ""
echo -e "  ${BOLD}Pași următori:${NC}"
echo -e "  1. ${BLUE}cd ${TARGET_DIR}${NC}"
echo -e "  2. Completează fiecare exercițiu din ${CYAN}exercitii/${NC}"
echo -e "  3. Rulează ${CYAN}./verifica_tema.sh${NC} pentru verificare"
echo -e "  4. Arhivează: ${CYAN}tar -czvf ${DIR_NAME}.tar.gz ${DIR_NAME}/${NC}"
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════════════════════════${NC}"
