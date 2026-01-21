#!/bin/bash
#
# S03_03_validator.sh - Validator Temă Seminar 5-6
# Sisteme de Operare | ASE București - CSIE
#
#
# DESCRIERE:
#   Validează tema studentului pentru Seminarul 5-6:
#   - Verifică structura și prezența fișierelor
#   - Testează scripturile cu argumente
#   - Verifică sintaxa cron jobs
#   - Validează permisiunile setate
#   - Generează raport de evaluare
#
# UTILIZARE:
#   ./S03_03_validator.sh [-h] [-v] [-o REPORT] <director_tema>
#
# OPȚIUNI:
#   -h          Afișează help
#   -v          Mod verbose (detalii pentru fiecare test)
#   -o REPORT   Salvează raportul în fișier
#   -s          Mod strict (orice warning devine eroare)
#
# AUTOR: Echipa SO ASE
# VERSIUNE: 1.0
#

set -e

# Culori
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'
BOLD='\033[1m'

# Configurări
VERBOSE=false
STRICT=false
REPORT_FILE=""
HOMEWORK_DIR=""

# Contoare
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_WARNED=0
TOTAL_TESTS=0
TOTAL_POINTS=0
MAX_POINTS=100

# Array pentru rezultate
declare -a TEST_RESULTS

#
# FUNCȚII UTILITARE
#

usage() {
    cat << EOF
${BOLD}Validator Temă - Seminar 5-6 SO${NC}

${BOLD}UTILIZARE:${NC}
    $0 [-h] [-v] [-o REPORT] [-s] <director_tema>

${BOLD}OPȚIUNI:${NC}
    -h          Afișează acest help
    -v          Mod verbose (detalii pentru fiecare test)
    -o REPORT   Salvează raportul în fișier
    -s          Mod strict (orice warning devine eroare)

${BOLD}STRUCTURA AȘTEPTATĂ:${NC}
    tema_sem5-6/
    ├── find_commands.sh       # Comenzi find (Partea 1)
    ├── professional_script.sh # Script cu getopts (Partea 2)
    ├── permission_manager.sh  # Manager permisiuni (Partea 3)
    ├── cron_jobs.txt          # Expresii cron (Partea 4)
    └── integration.sh         # Script integrat (Partea 5)

${BOLD}EXEMPLE:${NC}
    $0 ./tema_mea              # Validare simplă
    $0 -v ./tema_mea           # Cu detalii
    $0 -v -o raport.txt ./tema # Salvează raport

EOF
    exit 0
}

log() {
    local level=$1
    shift
    local message="$*"
    local timestamp=$(date '+%H:%M:%S')
    
    case "$level" in
        PASS)
            echo -e "${GREEN}✓${NC} $message"
            ;;
        FAIL)
            echo -e "${RED}✗${NC} $message"
            ;;
        WARN)
            echo -e "${YELLOW}⚠${NC} $message"
            ;;
        INFO)
            if [ "$VERBOSE" = true ]; then
                echo -e "${CYAN}ℹ${NC} $message"
            fi
            ;;
        DEBUG)
            if [ "$VERBOSE" = true ]; then
                echo -e "${MAGENTA}🔍${NC} $message"
            fi
            ;;
    esac
    
    # Adaugă la raport dacă specificat
    if [ -n "$REPORT_FILE" ]; then
        echo "[$timestamp] [$level] $message" >> "$REPORT_FILE"
    fi
}

print_header() {
    echo -e "\n${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}$1${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}\n"
}

print_section() {
    echo -e "\n${BLUE}───────────────────────────────────────────────────────────────${NC}"
    echo -e "${BOLD}$1${NC}"
    echo -e "${BLUE}───────────────────────────────────────────────────────────────${NC}\n"
}

# Funcție pentru înregistrare test
record_test() {
    local name=$1
    local result=$2  # PASS, FAIL, WARN
    local points=$3
    local max_points=$4
    local details=$5
    
    ((TOTAL_TESTS++))
    
    case "$result" in
        PASS)
            ((TESTS_PASSED++))
            TOTAL_POINTS=$((TOTAL_POINTS + points))
            log PASS "$name (+$points pts)"
            ;;
        FAIL)
            ((TESTS_FAILED++))
            log FAIL "$name (0/$max_points pts)"
            if [ -n "$details" ]; then
                log INFO "  Detalii: $details"
            fi
            ;;
        WARN)
            ((TESTS_WARNED++))
            if [ "$STRICT" = true ]; then
                ((TESTS_FAILED++))
                log FAIL "$name (WARN → FAIL în mod strict)"
            else
                TOTAL_POINTS=$((TOTAL_POINTS + points))
                log WARN "$name (+$points pts, dar cu avertisment)"
            fi
            if [ -n "$details" ]; then
                log INFO "  Detalii: $details"
            fi
            ;;
    esac
    
    TEST_RESULTS+=("$name|$result|$points|$max_points|$details")
}

#
# VALIDĂRI STRUCTURĂ
#

check_structure() {
    print_section "📁 VERIFICARE STRUCTURĂ (5 pts)"
    
    local required_files=(
        "find_commands.sh"
        "professional_script.sh"
        "permission_manager.sh"
        "cron_jobs.txt"
    )
    
    local optional_files=(
        "integration.sh"
        "README.md"
    )
    
    local found=0
    local missing=()
    
    for file in "${required_files[@]}"; do
        if [ -f "$HOMEWORK_DIR/$file" ]; then
            ((found++))
            log DEBUG "Găsit: $file"
        else
            missing+=("$file")
            log DEBUG "Lipsă: $file"
        fi
    done
    
    if [ ${#missing[@]} -eq 0 ]; then
        record_test "Toate fișierele obligatorii prezente" "PASS" 5 5 ""
    elif [ ${#missing[@]} -le 1 ]; then
        record_test "Fișiere aproape complete" "WARN" 3 5 "Lipsă: ${missing[*]}"
    else
        record_test "Fișiere incomplete" "FAIL" 0 5 "Lipsă: ${missing[*]}"
    fi
    
    # Verifică fișiere bonus
    for file in "${optional_files[@]}"; do
        if [ -f "$HOMEWORK_DIR/$file" ]; then
            log INFO "Bonus: $file prezent"
        fi
    done
}

#
# VALIDARE PARTEA 1: COMENZI FIND
#

validate_find_commands() {
    print_section "🔍 PARTEA 1: COMENZI FIND (20 pts)"
    
    local file="$HOMEWORK_DIR/find_commands.sh"
    
    if [ ! -f "$file" ]; then
        record_test "Fișier find_commands.sh" "FAIL" 0 20 "Fișierul nu există"
        return
    fi
    
    # Verifică shebang
    if head -1 "$file" | grep -q "^#!/bin/bash"; then
        record_test "Shebang corect" "PASS" 2 2 ""
    else
        record_test "Shebang" "WARN" 1 2 "Lipsește sau incorect: #!/bin/bash"
    fi
    
    # Verifică că folosește find
    local find_count=$(grep -c "^[^#]*find " "$file" 2>/dev/null || echo 0)
    if [ "$find_count" -ge 5 ]; then
        record_test "Minim 5 comenzi find" "PASS" 5 5 "Găsite: $find_count"
    elif [ "$find_count" -ge 3 ]; then
        record_test "Comenzi find" "WARN" 3 5 "Doar $find_count comenzi (necesar minim 5)"
    else
        record_test "Comenzi find" "FAIL" 0 5 "Doar $find_count comenzi"
    fi
    
    # Verifică opțiuni find avansate
    local advanced_opts=0
    
    if grep -q "\-type" "$file" 2>/dev/null; then
        ((advanced_opts++))
        log DEBUG "Folosește -type"
    fi
    
    if grep -q "\-size" "$file" 2>/dev/null; then
        ((advanced_opts++))
        log DEBUG "Folosește -size"
    fi
    
    if grep -q "\-mtime\|\-mmin" "$file" 2>/dev/null; then
        ((advanced_opts++))
        log DEBUG "Folosește -mtime/-mmin"
    fi
    
    if grep -q "\-exec\|xargs" "$file" 2>/dev/null; then
        ((advanced_opts++))
        log DEBUG "Folosește -exec sau xargs"
    fi
    
    if [ "$advanced_opts" -ge 3 ]; then
        record_test "Opțiuni avansate find" "PASS" 5 5 "$advanced_opts tipuri folosite"
    elif [ "$advanced_opts" -ge 2 ]; then
        record_test "Opțiuni avansate" "WARN" 3 5 "$advanced_opts tipuri (recomandat 3+)"
    else
        record_test "Opțiuni avansate" "FAIL" 0 5 "Doar $advanced_opts tipuri"
    fi
    
    # Verifică xargs sau -exec +
    if grep -qE "xargs|exec.*\+" "$file" 2>/dev/null; then
        record_test "Procesare eficientă (xargs/-exec +)" "PASS" 3 3 ""
    else
        record_test "Procesare eficientă" "WARN" 1 3 "Consideră xargs sau -exec {} +"
    fi
    
    # Verifică gestionarea spațiilor
    if grep -qE "print0|xargs -0" "$file" 2>/dev/null; then
        record_test "Gestionare fișiere cu spații" "PASS" 5 5 ""
    else
        record_test "Gestionare fișiere cu spații" "WARN" 2 5 "Adaugă -print0 | xargs -0 pentru robustețe"
    fi
}

#
# VALIDARE PARTEA 2: SCRIPT PROFESIONAL
#

validate_professional_script() {
    print_section "📜 PARTEA 2: SCRIPT PROFESIONAL (30 pts)"
    
    local file="$HOMEWORK_DIR/professional_script.sh"
    
    if [ ! -f "$file" ]; then
        record_test "Fișier professional_script.sh" "FAIL" 0 30 "Fișierul nu există"
        return
    fi
    
    # Verifică shebang și executabilitate
    if head -1 "$file" | grep -q "^#!/bin/bash"; then
        record_test "Shebang" "PASS" 2 2 ""
    else
        record_test "Shebang" "FAIL" 0 2 ""
    fi
    
    # Verifică getopts
    if grep -q "getopts" "$file" 2>/dev/null; then
        record_test "Folosește getopts" "PASS" 5 5 ""
        
        # Verifică opțiunile cerute
        local has_h=$(grep -c "\-h\|help" "$file" || echo 0)
        local has_v=$(grep -c "\-v\|verbose" "$file" || echo 0)
        local has_o=$(grep -c "\-o\|output" "$file" || echo 0)
        
        if [ "$has_h" -gt 0 ] && [ "$has_v" -gt 0 ] && [ "$has_o" -gt 0 ]; then
            record_test "Opțiunile -h, -v, -o implementate" "PASS" 5 5 ""
        else
            record_test "Opțiuni incomplete" "WARN" 3 5 "Verifică -h (help), -v (verbose), -o (output)"
        fi
    else
        record_test "Folosește getopts" "FAIL" 0 5 "getopts nu este folosit"
        record_test "Opțiuni" "FAIL" 0 5 ""
    fi
    
    # Verifică funcția usage
    if grep -qE "usage\(\)|show_help" "$file" 2>/dev/null; then
        record_test "Funcție usage/help" "PASS" 3 3 ""
    else
        record_test "Funcție usage/help" "WARN" 1 3 "Adaugă funcție usage() pentru -h"
    fi
    
    # Verifică validarea argumentelor
    if grep -qE '\$#|test.*\-[ez]|\[\[.*\]\]' "$file" 2>/dev/null; then
        record_test "Validare argumente" "PASS" 3 3 ""
    else
        record_test "Validare argumente" "WARN" 1 3 "Adaugă validare pentru număr/tip argumente"
    fi
    
    # Verifică shift după getopts
    if grep -qE "shift.*OPTIND|OPTIND.*shift" "$file" 2>/dev/null; then
        record_test "shift după getopts (OPTIND)" "PASS" 3 3 ""
    else
        record_test "shift după getopts" "WARN" 1 3 "Adaugă: shift \$((OPTIND-1))"
    fi
    
    # Verifică error handling
    if grep -qE "exit [1-9]|set -e" "$file" 2>/dev/null; then
        record_test "Error handling (exit codes)" "PASS" 2 2 ""
    else
        record_test "Error handling" "WARN" 1 2 "Adaugă exit codes pentru erori"
    fi
    
    # Test funcțional (rulează scriptul cu -h)
    if [ -x "$file" ] || chmod +x "$file" 2>/dev/null; then
        if timeout 5 bash "$file" -h &>/dev/null; then
            record_test "Script rulează cu -h" "PASS" 5 5 ""
        else
            record_test "Test funcțional -h" "WARN" 2 5 "Scriptul nu rulează corect cu -h"
        fi
    else
        record_test "Executabilitate script" "FAIL" 0 5 "Nu poate fi făcut executabil"
    fi
    
    # Verifică "$@" vs $@
    if grep -q '"\$@"' "$file" 2>/dev/null; then
        record_test 'Folosește "$@" corect (cu ghilimele)' "PASS" 2 2 ""
    elif grep -q '\$@' "$file" 2>/dev/null; then
        record_test 'Folosește $@ fără ghilimele' "WARN" 1 2 'Schimbă $@ în "$@"'
    fi
}

#
# VALIDARE PARTEA 3: PERMISSION MANAGER
#

validate_permission_manager() {
    print_section "🔐 PARTEA 3: PERMISSION MANAGER (25 pts)"
    
    local file="$HOMEWORK_DIR/permission_manager.sh"
    
    if [ ! -f "$file" ]; then
        record_test "Fișier permission_manager.sh" "FAIL" 0 25 "Fișierul nu există"
        return
    fi
    
    # Verifică că folosește chmod
    if grep -q "chmod" "$file" 2>/dev/null; then
        record_test "Folosește chmod" "PASS" 3 3 ""
    else
        record_test "Folosește chmod" "FAIL" 0 3 ""
    fi
    
    # Verifică stat sau ls -l pentru analiza permisiunilor
    if grep -qE "stat|ls -l" "$file" 2>/dev/null; then
        record_test "Analizează permisiuni (stat/ls)" "PASS" 3 3 ""
    else
        record_test "Analiză permisiuni" "WARN" 1 3 "Adaugă stat sau ls -l pentru verificare"
    fi
    
    # Verifică că nu folosește chmod 777
    if grep -q "chmod.*777\|chmod 777" "$file" 2>/dev/null; then
        record_test "NU folosește chmod 777" "FAIL" 0 5 "SECURITATE: chmod 777 detectat!"
    else
        record_test "Evită chmod 777" "PASS" 5 5 ""
    fi
    
    # Verifică find pentru căutare fișiere
    if grep -q "find" "$file" 2>/dev/null; then
        record_test "Folosește find pentru căutare" "PASS" 3 3 ""
    else
        record_test "Folosește find" "WARN" 1 3 ""
    fi
    
    # Verifică că diferențiază fișiere de directoare
    if grep -qE "type [fd]|\-d|\-f" "$file" 2>/dev/null; then
        record_test "Diferențiază fișiere/directoare" "PASS" 3 3 ""
    else
        record_test "Diferențiere fișiere/directoare" "WARN" 1 3 "Tratează fișierele diferit de directoare"
    fi
    
    # Verifică dry-run sau confirmare
    if grep -qE "dry.?run|echo.*chmod|\-i|confirm|read" "$file" 2>/dev/null; then
        record_test "Opțiune dry-run sau confirmare" "PASS" 3 3 ""
    else
        record_test "Safety (dry-run)" "WARN" 1 3 "Adaugă opțiune --dry-run sau confirmare"
    fi
    
    # Verifică raportare
    if grep -qE "echo|printf|report" "$file" 2>/dev/null; then
        record_test "Generează raport" "PASS" 2 2 ""
    else
        record_test "Raportare" "WARN" 1 2 ""
    fi
    
    # Verifică permisiuni speciale (SUID/SGID detection)
    if grep -qE "4[0-7][0-7][0-7]|2[0-7][0-7][0-7]|\-perm.*[42]000|SUID|SGID" "$file" 2>/dev/null; then
        record_test "Detectează permisiuni speciale" "PASS" 3 3 ""
    else
        record_test "Permisiuni speciale" "WARN" 1 3 "Consideră detectarea SUID/SGID"
    fi
}

#
# VALIDARE PARTEA 4: CRON JOBS
#

validate_cron_jobs() {
    print_section "⏰ PARTEA 4: CRON JOBS (15 pts)"
    
    local file="$HOMEWORK_DIR/cron_jobs.txt"
    
    if [ ! -f "$file" ]; then
        record_test "Fișier cron_jobs.txt" "FAIL" 0 15 "Fișierul nu există"
        return
    fi
    
    # Numără linii non-comentariu, non-goale
    local cron_lines=$(grep -v "^#" "$file" | grep -v "^$" | wc -l)
    
    if [ "$cron_lines" -ge 3 ]; then
        record_test "Minim 3 expresii cron" "PASS" 3 3 "Găsite: $cron_lines"
    else
        record_test "Expresii cron" "FAIL" 0 3 "Doar $cron_lines expresii (necesar minim 3)"
    fi
    
    # Verifică sintaxa cron
    local valid_crons=0
    local invalid_crons=()
    
    while IFS= read -r line; do
        # Ignoră comentarii și linii goale
        [[ "$line" =~ ^# ]] && continue
        [[ -z "${line// }" ]] && continue
        
        # Verifică format de bază (5 câmpuri + comandă)
        local fields=$(echo "$line" | awk '{print NF}')
        if [ "$fields" -ge 6 ]; then
            # Verifică că primele 5 câmpuri sunt valide
            local cron_expr=$(echo "$line" | awk '{print $1,$2,$3,$4,$5}')
            if [[ "$cron_expr" =~ ^[0-9\*\/\,\-]+[[:space:]][0-9\*\/\,\-]+[[:space:]][0-9\*\/\,\-]+[[:space:]][0-9\*\/\,\-]+[[:space:]][0-9\*\/\,\-]+$ ]]; then
                ((valid_crons++))
            elif [[ "$cron_expr" =~ ^@ ]]; then
                # String special (@daily, @reboot, etc.)
                ((valid_crons++))
            else
                invalid_crons+=("$line")
            fi
        else
            invalid_crons+=("$line")
        fi
    done < "$file"
    
    if [ "$valid_crons" -ge 3 ]; then
        record_test "Sintaxă cron validă" "PASS" 5 5 "$valid_crons expresii valide"
    elif [ "$valid_crons" -ge 1 ]; then
        record_test "Sintaxă cron" "WARN" 2 5 "$valid_crons valide, ${#invalid_crons[@]} invalide"
    else
        record_test "Sintaxă cron" "FAIL" 0 5 "Nicio expresie validă"
    fi
    
    # Verifică căi absolute
    if grep -vE "^#|^$" "$file" | grep -qE "^[^/]*\s+/"; then
        record_test "Folosește căi absolute" "PASS" 3 3 ""
    else
        record_test "Căi absolute" "WARN" 1 3 "Recomandare: folosește căi absolute în cron"
    fi
    
    # Verifică redirecționare output
    if grep -qE ">>" "$file" 2>/dev/null; then
        record_test "Logging (redirecționare output)" "PASS" 2 2 ""
    else
        record_test "Logging" "WARN" 1 2 "Adaugă >> log.txt 2>&1 pentru logging"
    fi
    
    # Verifică 2>&1
    if grep -q "2>&1" "$file" 2>/dev/null; then
        record_test "Capturare stderr (2>&1)" "PASS" 2 2 ""
    else
        record_test "Capturare stderr" "WARN" 1 2 "Adaugă 2>&1 pentru a captura erorile"
    fi
}

#
# VALIDARE PARTEA 5: INTEGRARE (BONUS)
#

validate_integration() {
    print_section "🔗 PARTEA 5: INTEGRARE - BONUS (10 pts)"
    
    local file="$HOMEWORK_DIR/integration.sh"
    
    if [ ! -f "$file" ]; then
        log INFO "Scriptul de integrare nu există (opțional)"
        return
    fi
    
    log INFO "Script de integrare detectat - verificare bonus"
    
    # Verifică că combină conceptele
    local concepts=0
    
    if grep -q "find" "$file" 2>/dev/null; then
        ((concepts++))
        log DEBUG "Folosește find"
    fi
    
    if grep -q "getopts" "$file" 2>/dev/null; then
        ((concepts++))
        log DEBUG "Folosește getopts"
    fi
    
    if grep -q "chmod\|chown" "$file" 2>/dev/null; then
        ((concepts++))
        log DEBUG "Gestionează permisiuni"
    fi
    
    if grep -qE "cron|crontab|>>.*log" "$file" 2>/dev/null; then
        ((concepts++))
        log DEBUG "Integrare logging/cron"
    fi
    
    if [ "$concepts" -ge 3 ]; then
        record_test "BONUS: Script integrare complet" "PASS" 10 10 "$concepts concepte integrate"
    elif [ "$concepts" -ge 2 ]; then
        record_test "BONUS: Script integrare parțial" "WARN" 5 10 "$concepts concepte (recomandat 3+)"
    else
        record_test "BONUS: Script integrare" "WARN" 2 10 "Doar $concepts concepte integrate"
    fi
}

#
# VERIFICĂRI BONUS SUPLIMENTARE
#

check_bonuses() {
    print_section "🌟 BONUSURI SUPLIMENTARE"
    
    local bonus_points=0
    
    # Verifică README
    if [ -f "$HOMEWORK_DIR/README.md" ]; then
        local readme_lines=$(wc -l < "$HOMEWORK_DIR/README.md")
        if [ "$readme_lines" -ge 20 ]; then
            log PASS "BONUS: README.md complet (+2 pts)"
            ((bonus_points += 2))
        else
            log WARN "README.md există dar e scurt"
        fi
    fi
    
    # Verifică comentarii în scripturi
    local total_comments=0
    for script in "$HOMEWORK_DIR"/*.sh; do
        [ -f "$script" ] || continue
        local comments=$(grep -c "^#" "$script" 2>/dev/null || echo 0)
        total_comments=$((total_comments + comments))
    done
    
    if [ "$total_comments" -ge 30 ]; then
        log PASS "BONUS: Documentație în cod (+2 pts)"
        ((bonus_points += 2))
    fi
    
    # Verifică opțiuni lungi
    local has_long_opts=false
    for script in "$HOMEWORK_DIR"/*.sh; do
        [ -f "$script" ] || continue
        if grep -qE "\-\-help|\-\-verbose|\-\-output" "$script" 2>/dev/null; then
            has_long_opts=true
            break
        fi
    done
    
    if [ "$has_long_opts" = true ]; then
        log PASS "BONUS: Suport opțiuni lungi (+3 pts)"
        ((bonus_points += 3))
    fi
    
    # Verifică flock pentru lock files
    for script in "$HOMEWORK_DIR"/*.sh; do
        [ -f "$script" ] || continue
        if grep -q "flock" "$script" 2>/dev/null; then
            log PASS "BONUS: Lock file cu flock (+3 pts)"
            ((bonus_points += 3))
            break
        fi
    done
    
    if [ "$bonus_points" -gt 0 ]; then
        TOTAL_POINTS=$((TOTAL_POINTS + bonus_points))
        log INFO "Total puncte bonus: +$bonus_points"
    else
        log INFO "Niciun bonus suplimentar"
    fi
}

#
# GENERARE RAPORT FINAL
#

generate_report() {
    print_header "📊 RAPORT FINAL"
    
    local percentage=$((TOTAL_POINTS * 100 / MAX_POINTS))
    local grade
    
    if [ $percentage -ge 90 ]; then
        grade="10 (Excelent)"
    elif [ $percentage -ge 80 ]; then
        grade="9 (Foarte bine)"
    elif [ $percentage -ge 70 ]; then
        grade="8 (Bine)"
    elif [ $percentage -ge 60 ]; then
        grade="7 (Satisfăcător)"
    elif [ $percentage -ge 50 ]; then
        grade="6 (Suficient)"
    elif [ $percentage -ge 40 ]; then
        grade="5 (Slab)"
    else
        grade="4 (Insuficient)"
    fi
    
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}                    ${BOLD}REZULTATE VALIDARE${NC}                        ${CYAN}║${NC}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  Director evaluat:  $HOMEWORK_DIR"
    echo -e "${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${BOLD}Statistici teste:${NC}"
    echo -e "${CYAN}║${NC}    Total teste:     $TOTAL_TESTS"
    echo -e "${CYAN}║${NC}    ✓ Trecute:       ${GREEN}$TESTS_PASSED${NC}"
    echo -e "${CYAN}║${NC}    ✗ Eșuate:        ${RED}$TESTS_FAILED${NC}"
    echo -e "${CYAN}║${NC}    ⚠ Avertismente:  ${YELLOW}$TESTS_WARNED${NC}"
    echo -e "${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${BOLD}Punctaj:${NC}"
    echo -e "${CYAN}║${NC}    Obținut:         ${BOLD}$TOTAL_POINTS${NC} / $MAX_POINTS"
    echo -e "${CYAN}║${NC}    Procentaj:       ${BOLD}$percentage%${NC}"
    echo -e "${CYAN}║${NC}    Notă estimată:   ${BOLD}$grade${NC}"
    echo -e "${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    
    if [ -n "$REPORT_FILE" ]; then
        echo ""
        echo "Raport salvat în: $REPORT_FILE"
        
        # Adaugă rezumat la raport
        {
            echo ""
            echo "═══════════════════════════════════════════════════════════════"
            echo "REZUMAT"
            echo "═══════════════════════════════════════════════════════════════"
            echo "Punctaj: $TOTAL_POINTS / $MAX_POINTS ($percentage%)"
            echo "Notă estimată: $grade"
            echo "Data: $(date)"
        } >> "$REPORT_FILE"
    fi
    
    # Sfaturi pentru îmbunătățire
    if [ $TESTS_FAILED -gt 0 ] || [ $TESTS_WARNED -gt 0 ]; then
        echo ""
        echo -e "${YELLOW}💡 Sugestii pentru îmbunătățire:${NC}"
        
        if [ $TESTS_FAILED -gt 0 ]; then
            echo "  - Verifică testele eșuate și corectează erorile"
        fi
        
        if [ $TESTS_WARNED -gt 0 ]; then
            echo "  - Adresează avertismentele pentru punctaj maxim"
        fi
        
        echo "  - Rulează validatorul cu -v pentru detalii"
    fi
}

#
# MAIN
#

main() {
    # Parse argumente
    while getopts ":hvo:s" opt; do
        case $opt in
            h) usage ;;
            v) VERBOSE=true ;;
            o) REPORT_FILE="$OPTARG" ;;
            s) STRICT=true ;;
            \?) echo -e "${RED}Opțiune invalidă: -$OPTARG${NC}"; exit 1 ;;
            :) echo -e "${RED}Opțiunea -$OPTARG necesită argument${NC}"; exit 1 ;;
        esac
    done
    shift $((OPTIND - 1))
    
    # Verifică argument director
    if [ $# -lt 1 ]; then
        echo -e "${RED}Eroare: Specifică directorul cu tema${NC}"
        echo "Utilizare: $0 [-v] [-o raport.txt] <director_tema>"
        exit 1
    fi
    
    HOMEWORK_DIR="$1"
    
    if [ ! -d "$HOMEWORK_DIR" ]; then
        echo -e "${RED}Eroare: Directorul '$HOMEWORK_DIR' nu există${NC}"
        exit 1
    fi
    
    # Convertește la cale absolută
    HOMEWORK_DIR=$(cd "$HOMEWORK_DIR" && pwd)
    
    # Inițializează raport
    if [ -n "$REPORT_FILE" ]; then
        echo "Raport validare - $(date)" > "$REPORT_FILE"
        echo "Director: $HOMEWORK_DIR" >> "$REPORT_FILE"
        echo "═══════════════════════════════════════════════════════════════" >> "$REPORT_FILE"
    fi
    
    # Header
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}     ${BOLD}VALIDATOR TEMĂ - SEMINAR 5-6 SO${NC}                          ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}     ASE București - CSIE                                     ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    
    # Rulează validări
    check_structure
    validate_find_commands
    validate_professional_script
    validate_permission_manager
    validate_cron_jobs
    validate_integration
    check_bonuses
    
    # Generează raport
    generate_report
    
    # Exit code bazat pe rezultat
    if [ $TESTS_FAILED -eq 0 ]; then
        exit 0
    else
        exit 1
    fi
}

main "$@"
