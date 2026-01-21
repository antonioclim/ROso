#!/bin/bash
#
# S05_01_setup_seminar.sh - Setup Environment pentru Seminar Advanced Bash
# 
# Sisteme de Operare | ASE București - CSIE
# Seminar 9-10: Advanced Bash Scripting
#
# SCOP: Pregătește mediul de lucru pentru seminar:
#       - Creează structura de directoare
#       - Copiază template-urile și scripturile demo
#       - Verifică dependențele
#       - Generează fișiere de test
#
# UTILIZARE:
#   ./S05_01_setup_seminar.sh              # Setup complet
#   ./S05_01_setup_seminar.sh --check      # Doar verificare
#   ./S05_01_setup_seminar.sh --clean      # Curăță și refă
#

set -euo pipefail
IFS=$'\n\t'

# ============================================================
# CONSTANTE
# ============================================================
readonly SCRIPT_NAME=$(basename "$0")
readonly SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
readonly SCRIPT_VERSION="1.0.0"

# Directorul de lucru pentru seminar
WORK_DIR="${WORK_DIR:-$HOME/seminar_bash}"
readonly SEMINAR_NAME="S05_Advanced_Bash"

# Culori
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# ============================================================
# HELPER FUNCTIONS
# ============================================================

log_info() {
    echo -e "${GREEN}[INFO]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*" >&2
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

log_step() {
    echo -e "\n${BOLD}${BLUE}▶ $*${NC}"
}

die() {
    log_error "$*"
    exit 1
}

check_command() {
    local cmd=$1
    local required=${2:-false}
    
    if command -v "$cmd" &>/dev/null; then
        echo -e "  ${GREEN}✓${NC} $cmd: $(command -v "$cmd")"
        return 0
    else
        if [[ "$required" == "true" ]]; then
            echo -e "  ${RED}✗${NC} $cmd: NOT FOUND (REQUIRED)"
            return 1
        else
            echo -e "  ${YELLOW}○${NC} $cmd: not found (optional)"
            return 0
        fi
    fi
}

usage() {
    cat << EOF
${BOLD}$SCRIPT_NAME v$SCRIPT_VERSION${NC}

Pregătește mediul de lucru pentru Seminarul de Advanced Bash Scripting.

${BOLD}UTILIZARE:${NC}
    $SCRIPT_NAME [opțiuni]

${BOLD}OPȚIUNI:${NC}
    -h, --help          Afișează acest mesaj
    -c, --check         Doar verifică dependențele (fără setup)
    -C, --clean         Șterge și recreează directorul de lucru
    -d, --dir PATH      Specifică directorul de lucru (default: ~/seminar_bash)
    -v, --verbose       Mod verbose

${BOLD}EXEMPLE:${NC}
    $SCRIPT_NAME                      # Setup standard
    $SCRIPT_NAME --check              # Verifică doar
    $SCRIPT_NAME --dir /tmp/seminar   # Director custom
    $SCRIPT_NAME --clean              # Resetare completă

${BOLD}STRUCTURA CREATĂ:${NC}
    $WORK_DIR/
    ├── exercitii/         # Exerciții pentru studenți
    ├── solutii/           # Soluții (instructor)
    ├── templates/         # Template-uri de pornire
    ├── test_files/        # Fișiere pentru testare
    └── submissions/       # Director pentru teme

EOF
}

# ============================================================
# CHECK DEPENDENCIES
# ============================================================

check_dependencies() {
    log_step "Verificare Dependențe"
    
    local errors=0
    
    echo "Bash version: ${BASH_VERSION}"
    
    # Required
    check_command bash true || ((errors++))
    check_command cat true || ((errors++))
    check_command grep true || ((errors++))
    check_command sed true || ((errors++))
    check_command awk true || ((errors++))
    
    # Optional but recommended
    check_command shellcheck false
    check_command tree false
    check_command jq false
    check_command python3 false
    check_command curl false
    
    echo ""
    if [[ $errors -gt 0 ]]; then
        log_error "$errors required dependencies missing!"
        return 1
    else
        log_info "All required dependencies found."
        return 0
    fi
}

# ============================================================
# CREATE DIRECTORY STRUCTURE
# ============================================================

create_structure() {
    log_step "Creare Structură Directoare"
    
    local dirs=(
        "exercitii/ex01_functii"
        "exercitii/ex02_arrays"
        "exercitii/ex03_robust"
        "exercitii/ex04_template"
        "solutii"
        "templates"
        "test_files"
        "submissions"
        "logs"
    )
    
    for dir in "${dirs[@]}"; do
        mkdir -p "$WORK_DIR/$dir"
        echo -e "  ${GREEN}✓${NC} Created: $dir"
    done
}

# ============================================================
# CREATE TEMPLATE FILES
# ============================================================

create_templates() {
    log_step "Creare Template-uri"
    
    # Template simplu
    cat > "$WORK_DIR/templates/simple_template.sh" << 'TEMPLATE'
#!/bin/bash
#
# Script: [NUME]
# Descriere: [DESCRIERE]
# Autor: [NUME STUDENT]
# Data: [DATA]
#

set -euo pipefail

# === Variabile ===

# === Funcții ===

# === Main ===
main() {
    echo "Hello, World!"
}

main "$@"
TEMPLATE

    # Template profesional
    cat > "$WORK_DIR/templates/professional_template.sh" << 'TEMPLATE'
#!/bin/bash
#
# Script: [NUME]
# Descriere: [DESCRIERE]
# Autor: [NUME STUDENT]
# Versiune: 1.0.0
# Data: [DATA]
#

set -euo pipefail
IFS=$'\n\t'

# ============================================================
# CONSTANTE
# ============================================================
readonly SCRIPT_NAME=$(basename "$0")
readonly SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
readonly VERSION="1.0.0"

# ============================================================
# CONFIGURARE
# ============================================================
VERBOSE="${VERBOSE:-0}"
DEBUG="${DEBUG:-false}"
LOG_FILE="${LOG_FILE:-/tmp/${SCRIPT_NAME%.*}.log}"

# ============================================================
# FUNCȚII HELPER
# ============================================================
usage() {
    cat << EOF
$SCRIPT_NAME v$VERSION

DESCRIERE:
    [Descriere script]

UTILIZARE:
    $SCRIPT_NAME [opțiuni] <argumente>

OPȚIUNI:
    -h, --help      Afișează acest mesaj
    -v, --verbose   Mod verbose
    -V, --version   Afișează versiunea

EXEMPLE:
    $SCRIPT_NAME input.txt
    $SCRIPT_NAME -v --output result.txt input.txt

EOF
}

log() {
    local level=$1
    shift
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $*" | tee -a "$LOG_FILE"
}

die() {
    log ERROR "$*"
    exit 1
}

debug() {
    [[ "$DEBUG" == "true" ]] && log DEBUG "$@"
    return 0
}

# ============================================================
# CLEANUP
# ============================================================
cleanup() {
    local exit_code=$?
    debug "Cleanup triggered with exit code: $exit_code"
    # Add cleanup code here
    exit $exit_code
}

trap cleanup EXIT
trap 'log WARN "Interrupted"; exit 130' INT TERM

# ============================================================
# PARSARE ARGUMENTE
# ============================================================
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            -v|--verbose)
                ((VERBOSE++))
                shift
                ;;
            -V|--version)
                echo "$SCRIPT_NAME v$VERSION"
                exit 0
                ;;
            --)
                shift
                break
                ;;
            -*)
                die "Unknown option: $1"
                ;;
            *)
                break
                ;;
        esac
    done
    
    # Validate required arguments
    # [[ $# -ge 1 ]] || die "Missing required argument"
}

# ============================================================
# MAIN
# ============================================================
main() {
    parse_args "$@"
    
    log INFO "Script starting..."
    
    # Your code here
    echo "Hello, World!"
    
    log INFO "Script completed successfully"
}

main "$@"
TEMPLATE

    chmod +x "$WORK_DIR/templates/"*.sh
    echo -e "  ${GREEN}✓${NC} Created: simple_template.sh"
    echo -e "  ${GREEN}✓${NC} Created: professional_template.sh"
}

# ============================================================
# CREATE TEST FILES
# ============================================================

create_test_files() {
    log_step "Creare Fișiere de Test"
    
    # Text file with various content
    cat > "$WORK_DIR/test_files/sample.txt" << 'EOF'
The quick brown fox jumps over the lazy dog.
Pack my box with five dozen liquor jugs.
How vexingly quick daft zebras jump!
The five boxing wizards jump quickly.
Sphinx of black quartz, judge my vow.
EOF
    echo -e "  ${GREEN}✓${NC} Created: sample.txt"
    
    # CSV file
    cat > "$WORK_DIR/test_files/data.csv" << 'EOF'
name,age,city,score
Alice,25,București,95
Bob,30,Cluj,88
Charlie,22,Iași,92
Diana,28,Timișoara,97
Eve,35,Constanța,85
EOF
    echo -e "  ${GREEN}✓${NC} Created: data.csv"
    
    # Config file
    cat > "$WORK_DIR/test_files/app.conf" << 'EOF'
# Application Configuration
HOST=localhost
PORT=8080
DEBUG=false
LOG_LEVEL=INFO

# Database
DB_HOST=db.example.com
DB_PORT=5432
DB_NAME=production

# Features
FEATURE_A=enabled
FEATURE_B=disabled
EOF
    echo -e "  ${GREEN}✓${NC} Created: app.conf"
    
    # JSON file
    cat > "$WORK_DIR/test_files/users.json" << 'EOF'
{
  "users": [
    {"id": 1, "name": "Alice", "role": "admin"},
    {"id": 2, "name": "Bob", "role": "user"},
    {"id": 3, "name": "Charlie", "role": "user"}
  ],
  "total": 3
}
EOF
    echo -e "  ${GREEN}✓${NC} Created: users.json"
    
    # Log file for parsing exercises
    cat > "$WORK_DIR/test_files/sample.log" << 'EOF'
[2025-01-15 10:00:00] [INFO] Application started
[2025-01-15 10:00:01] [DEBUG] Loading configuration
[2025-01-15 10:00:02] [INFO] Connected to database
[2025-01-15 10:00:05] [WARN] Slow query detected (2.3s)
[2025-01-15 10:00:10] [ERROR] Failed to send email: timeout
[2025-01-15 10:00:15] [INFO] User login: alice@example.com
[2025-01-15 10:00:20] [INFO] User login: bob@example.com
[2025-01-15 10:01:00] [WARN] High memory usage: 85%
[2025-01-15 10:02:00] [ERROR] Database connection lost
[2025-01-15 10:02:05] [INFO] Reconnected to database
EOF
    echo -e "  ${GREEN}✓${NC} Created: sample.log"
    
    # Files with spaces in names (for testing)
    mkdir -p "$WORK_DIR/test_files/tricky"
    echo "Content 1" > "$WORK_DIR/test_files/tricky/file with spaces.txt"
    echo "Content 2" > "$WORK_DIR/test_files/tricky/another file.txt"
    echo -e "  ${GREEN}✓${NC} Created: files with spaces (for testing)"
    
    # Empty file
    touch "$WORK_DIR/test_files/empty.txt"
    echo -e "  ${GREEN}✓${NC} Created: empty.txt"
    
    # Binary-like file (for testing file type detection)
    echo -e "\x00\x01\x02\x03" > "$WORK_DIR/test_files/binary.dat"
    echo -e "  ${GREEN}✓${NC} Created: binary.dat"
}

# ============================================================
# CREATE EXERCISE STARTERS
# ============================================================

create_exercises() {
    log_step "Creare Exerciții Starter"
    
    # Exercise 1: Functions
    cat > "$WORK_DIR/exercitii/ex01_functii/start.sh" << 'EXERCISE'
#!/bin/bash
# Exercițiu 1: Funcții
#
# CERINȚE:
# 1. Creează o funcție 'validate_email' care verifică dacă un string
#    arată ca un email valid (conține @ și .)
# 2. Creează o funcție 'count_words' care returnează numărul de cuvinte
#    dintr-un fișier (folosește echo pentru a "returna")
# 3. De reținut: Folosește 'local' pentru toate variabilele din funcții!
#
# HINT: 
#   - Pentru email: [[ "$email" =~ @ ]] && [[ "$email" =~ \. ]]
#   - Pentru word count: wc -w < "$file"

set -euo pipefail

# TODO: Implementează validate_email
validate_email() {
    local email="$1"
    # Completează aici
    return 1
}

# TODO: Implementează count_words
count_words() {
    local file="$1"
    # Completează aici
    echo 0
}

# Test
main() {
    echo "=== Test validate_email ==="
    if validate_email "test@example.com"; then
        echo "✓ test@example.com e valid"
    else
        echo "✗ test@example.com ar trebui să fie valid"
    fi
    
    if validate_email "invalid-email"; then
        echo "✗ invalid-email nu ar trebui să fie valid"
    else
        echo "✓ invalid-email corect respins"
    fi
    
    echo ""
    echo "=== Test count_words ==="
    echo "one two three four five" > /tmp/test_words.txt
    local count
    count=$(count_words /tmp/test_words.txt)
    if [[ "$count" == "5" ]]; then
        echo "✓ count_words: $count (corect)"
    else
        echo "✗ count_words: $count (așteptat: 5)"
    fi
    rm -f /tmp/test_words.txt
}

main
EXERCISE
    
    # Exercise 2: Arrays
    cat > "$WORK_DIR/exercitii/ex02_arrays/start.sh" << 'EXERCISE'
#!/bin/bash
# Exercițiu 2: Arrays
#
# CERINȚE:
# 1. Creează un array INDEXAT cu 5 fructe
# 2. Creează un array ASOCIATIV pentru configurare (host, port, user)
# 3. Iterează prin fiecare array și afișează elementele
# 4. De reținut: Folosește ghilimele în for loops!
#
# HINT:
#   - Array indexat: arr=("a" "b" "c")
#   - Array asociativ: declare -A hash; hash[key]="value"
#   - Iterare: for item in "${arr[@]}"; do

set -euo pipefail

# TODO: Creează array-ul de fructe
# fruits=(...)

# TODO: Creează array-ul asociativ de configurare
# declare -A config
# config[host]=...

main() {
    echo "=== Fructe ==="
    # TODO: Iterează și afișează fructele
    # for fruit in "${fruits[@]}"; do
    #     echo "- $fruit"
    # done
    
    echo ""
    echo "=== Configurare ==="
    # TODO: Iterează și afișează config (cheie=valoare)
    # for key in "${!config[@]}"; do
    #     echo "$key = ${config[$key]}"
    # done
}

main
EXERCISE

    # Exercise 3: solid Script
    cat > "$WORK_DIR/exercitii/ex03_robust/start.sh" << 'EXERCISE'
#!/bin/bash
# Exercițiu 3: Script solid
#
# CERINȚE:
# 1. Adaugă set -euo pipefail
# 2. Implementează funcția cleanup() cu trap EXIT
# 3. Adaugă validare pentru argumentul obligatoriu (fișier input)
# 4. Verifică că fișierul există și poate fi citit
#
# RULARE: ./start.sh <fisier>

# TODO: Adaugă strict mode
# set -euo pipefail

TEMP_FILE=""

# TODO: Implementează cleanup
cleanup() {
    # Șterge fișierul temporar dacă există
    :
}

# TODO: Setează trap
# trap cleanup EXIT

# TODO: Implementează validate
validate() {
    # Verifică că avem argument
    # Verifică că fișierul există
    # Verifică că fișierul poate fi citit
    :
}

main() {
    validate "$@"
    
    local input="$1"
    TEMP_FILE=$(mktemp)
    
    echo "Procesez: $input"
    echo "Temp file: $TEMP_FILE"
    
    # Simulare procesare
    cat "$input" > "$TEMP_FILE"
    wc -l "$TEMP_FILE"
    
    echo "Done!"
}

main "$@"
EXERCISE

    chmod +x "$WORK_DIR/exercitii/"*/*.sh
    
    echo -e "  ${GREEN}✓${NC} Created: ex01_functii/start.sh"
    echo -e "  ${GREEN}✓${NC} Created: ex02_arrays/start.sh"
    echo -e "  ${GREEN}✓${NC} Created: ex03_robust/start.sh"
}

# ============================================================
# PRINT SUMMARY
# ============================================================

print_summary() {
    log_step "Setup Complet!"
    
    echo ""
    echo -e "${BOLD}Structura creată în: ${GREEN}$WORK_DIR${NC}"
    echo ""
    
    if command -v tree &>/dev/null; then
        tree -L 2 "$WORK_DIR"
    else
        find "$WORK_DIR" -maxdepth 2 -type d | head -20
    fi
    
    echo ""
    echo -e "${BOLD}Următorii pași:${NC}"
    echo "  1. cd $WORK_DIR"
    echo "  2. Începe cu exercitii/ex01_functii/start.sh"
    echo "  3. Folosește templates/ ca punct de pornire"
    echo ""
    echo -e "${BOLD}Comenzi utile:${NC}"
    echo "  shellcheck script.sh     # Verifică script"
    echo "  bash -x script.sh        # Debug mode"
    echo ""
}

# ============================================================
# MAIN
# ============================================================

main() {
    local check_only=false
    local clean=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            -c|--check)
                check_only=true
                shift
                ;;
            -C|--clean)
                clean=true
                shift
                ;;
            -d|--dir)
                WORK_DIR="$2"
                shift 2
                ;;
            *)
                die "Unknown option: $1. Use --help for usage."
                ;;
        esac
    done
    
    echo -e "${BOLD}${BLUE}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║     Setup Seminar: Advanced Bash Scripting                  ║"
    echo "║     ASE București - CSIE                                    ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    # Check dependencies
    if ! check_dependencies; then
        die "Please install missing dependencies first."
    fi
    
    if [[ "$check_only" == "true" ]]; then
        log_info "Check-only mode. Exiting."
        exit 0
    fi
    
    # Clean if requested
    if [[ "$clean" == "true" && -d "$WORK_DIR" ]]; then
        log_warn "Removing existing directory: $WORK_DIR"
        rm -rf "$WORK_DIR"
    fi
    
    # Check if directory exists
    if [[ -d "$WORK_DIR" ]]; then
        log_warn "Directory already exists: $WORK_DIR"
        read -r -p "Overwrite? [y/N] " response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            log_info "Aborting."
            exit 0
        fi
    fi
    
    # Run setup
    create_structure
    create_templates
    create_test_files
    create_exercises
    print_summary
}

main "$@"
