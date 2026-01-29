#!/bin/bash
#===============================================================================
#
#          FILE: S04_03_validator.sh
#
#         USAGE: ./S04_03_validator.sh <exercise_id> "<student_command>"
#
#   DESCRIPTION: Validează soluțiile studenților pentru exercițiile de seminar
#                Compară output-ul comenzii student cu output-ul așteptat
#
#       OPTIONS: --list     Listează exercițiile disponibile
#                --help     Afișează ajutor
#
#        AUTHOR: Asistent Universitar - Seminarul SO
#       VERSION: 1.0
#
#===============================================================================

set -euo pipefail

#-------------------------------------------------------------------------------
# CONFIGURARE
#-------------------------------------------------------------------------------

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly DATA_DIR="$HOME/demo_sem4/data"

# Culori
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

#-------------------------------------------------------------------------------
# DEFINIREA EXERCIȚIILOR
#-------------------------------------------------------------------------------

# Format: id|description|expected_output_generator|hints

declare -A EXERCISES

# GREP exercises
EXERCISES[G1]="Găsește liniile cu cod 404 în access.log|grep ' 404 ' \"\$DATA_DIR/access.log\"|Folosește pattern ' 404 ' cu spații"
EXERCISES[G2]="Numără cererile POST în access.log|grep -c 'POST' \"\$DATA_DIR/access.log\"|Folosește grep -c"
EXERCISES[G3]="Extrage IP-urile unice din access.log|grep -oE '^[0-9.]+' \"\$DATA_DIR/access.log\" | sort -u|Combină grep -o cu sort -u"
EXERCISES[G4]="Găsește liniile cu /admin în access.log|grep '/admin' \"\$DATA_DIR/access.log\"|Pattern simplu: /admin"
EXERCISES[G5]="Extrage email-urile valide din emails.txt|grep -E '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$' \"\$DATA_DIR/emails.txt\"|Regex pentru email cu anchors"

# SED exercises
EXERCISES[S1]="Înlocuiește localhost cu 127.0.0.1 în config.txt|sed 's/localhost/127.0.0.1/g' \"\$DATA_DIR/config.txt\"|s/old/new/g pentru toate aparițiile"
EXERCISES[S2]="Șterge comentariile din config.txt|sed '/^#/d' \"\$DATA_DIR/config.txt\"|Pattern /^#/d"
EXERCISES[S3]="Șterge liniile goale din config.txt|sed '/^$/d' \"\$DATA_DIR/config.txt\"|Pattern /^$/d"
EXERCISES[S4]="Șterge comentarii ȘI linii goale|sed '/^#/d; /^$/d' \"\$DATA_DIR/config.txt\"|Combină: /^#/d; /^$/d"

# AWK exercises
EXERCISES[A1]="Afișează coloana Name din employees.csv|awk -F',' '{print \$2}' \"\$DATA_DIR/employees.csv\"|awk -F',' pentru CSV"
EXERCISES[A2]="Afișează angajații din IT|awk -F',' '\$3 == \"IT\"' \"\$DATA_DIR/employees.csv\"|Condiție pe câmp"
EXERCISES[A3]="Calculează suma salariilor (skip header)|awk -F',' 'NR > 1 {sum += \$4} END {print sum}' \"\$DATA_DIR/employees.csv\"|NR > 1 pentru skip header"
EXERCISES[A4]="Numără angajații per departament|awk -F',' 'NR > 1 {count[\$3]++} END {for (d in count) print d, count[d]}' \"\$DATA_DIR/employees.csv\"|Array asociativ pentru numărare"

#-------------------------------------------------------------------------------
# FUNCȚII
#-------------------------------------------------------------------------------

show_help() {
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════╗
║                    VALIDATOR EXERCIȚII - TEXT PROCESSING                 ║
╚══════════════════════════════════════════════════════════════════════════╝

USAGE:
    ./S04_03_validator.sh <exercise_id> "<student_command>"
    ./S04_03_validator.sh --list

OPTIONS:
    --list      Listează toate exercițiile disponibile
    --help      Afișează acest mesaj

EXEMPLE:
    ./S04_03_validator.sh G1 "grep ' 404 ' access.log"
    ./S04_03_validator.sh A3 "awk -F',' 'NR>1{s+=\$4}END{print s}' employees.csv"
    ./S04_03_validator.sh --list

EXERCIȚII DISPONIBILE:
    G1-G5: Exerciții GREP
    S1-S4: Exerciții SED
    A1-A4: Exerciții AWK

EOF
}

list_exercises() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════════════════════╗"
    echo "║                    EXERCIȚII DISPONIBILE                                 ║"
    echo "╚══════════════════════════════════════════════════════════════════════════╝"
    echo ""
    
    echo -e "${CYAN}=== GREP Exercises ===${NC}"
    for id in G1 G2 G3 G4 G5; do
        if [[ -n "${EXERCISES[$id]:-}" ]]; then
            local desc
            desc=$(echo "${EXERCISES[$id]}" | cut -d'|' -f1)
            echo -e "  ${YELLOW}$id${NC}: $desc"
        fi
    done
    
    echo ""
    echo -e "${CYAN}=== SED Exercises ===${NC}"
    for id in S1 S2 S3 S4; do
        if [[ -n "${EXERCISES[$id]:-}" ]]; then
            local desc
            desc=$(echo "${EXERCISES[$id]}" | cut -d'|' -f1)
            echo -e "  ${YELLOW}$id${NC}: $desc"
        fi
    done
    
    echo ""
    echo -e "${CYAN}=== AWK Exercises ===${NC}"
    for id in A1 A2 A3 A4; do
        if [[ -n "${EXERCISES[$id]:-}" ]]; then
            local desc
            desc=$(echo "${EXERCISES[$id]}" | cut -d'|' -f1)
            echo -e "  ${YELLOW}$id${NC}: $desc"
        fi
    done
    
    echo ""
}

validate_exercise() {
    local ex_id="$1"
    local student_cmd="$2"
    
    # Verifică dacă exercițiul există
    if [[ -z "${EXERCISES[$ex_id]:-}" ]]; then
        echo -e "${RED}[ERROR] Exercițiul '$ex_id' nu există!${NC}"
        echo "Folosește --list pentru a vedea exercițiile disponibile."
        exit 1
    fi
    
    # Parse exercise data
    local ex_data="${EXERCISES[$ex_id]}"
    local description hint
    description=$(echo "$ex_data" | cut -d'|' -f1)
    local expected_cmd
    expected_cmd=$(echo "$ex_data" | cut -d'|' -f2)
    hint=$(echo "$ex_data" | cut -d'|' -f3)
    
    echo ""
    echo "╔══════════════════════════════════════════════════════════════════════════╗"
    echo "║                         VALIDARE EXERCIȚIU                              ║"
    echo "╚══════════════════════════════════════════════════════════════════════════╝"
    echo ""
    echo -e "${CYAN}Exercițiu:${NC} $ex_id"
    echo -e "${CYAN}Cerință:${NC} $description"
    echo -e "${CYAN}Comanda ta:${NC} $student_cmd"
    echo ""
    
    # Verifică că datele există
    if [[ ! -d "$DATA_DIR" ]]; then
        echo -e "${RED}[ERROR] Directorul de date nu există: $DATA_DIR${NC}"
        echo "Rulează mai întâi: ./S04_01_setup_seminar.sh"
        exit 1
    fi
    
    # Generează output așteptat
    local expected_output student_output
    cd "$DATA_DIR" || exit 1
    
    # Evaluează comanda așteptată
    expected_output=$(eval "$expected_cmd" 2>/dev/null || echo "[COMMAND_ERROR]")
    
    # Evaluează comanda studentului (cu timeout pentru siguranță)
    student_output=$(timeout 10 bash -c "$student_cmd" 2>/dev/null || echo "[COMMAND_ERROR]")
    
    # Comparare
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    
    if [[ "$student_output" == "[COMMAND_ERROR]" ]]; then
        echo -e "${RED}✗ EROARE: Comanda ta a generat o eroare sau a durat prea mult${NC}"
        echo ""
        echo -e "${YELLOW}Hint: $hint${NC}"
        return 1
    fi
    
    # Comparare flexibilă (ignoră whitespace și ordine pentru unele cazuri)
    local expected_sorted student_sorted
    expected_sorted=$(echo "$expected_output" | sort | tr -s ' ' | sed 's/^ //;s/ $//')
    student_sorted=$(echo "$student_output" | sort | tr -s ' ' | sed 's/^ //;s/ $//')
    
    if [[ "$expected_output" == "$student_output" ]]; then
        echo -e "${GREEN}✓ PERFECT! Output-ul este identic cu cel așteptat.${NC}"
        return 0
    elif [[ "$expected_sorted" == "$student_sorted" ]]; then
        echo -e "${GREEN}✓ CORECT! Output-ul este echivalent (ordine/whitespace diferit).${NC}"
        return 0
    else
        echo -e "${RED}✗ INCORECT: Output-ul diferă de cel așteptat.${NC}"
        echo ""
        echo -e "${CYAN}Output așteptat (primele 10 linii):${NC}"
        echo "$expected_output" | head -10
        echo ""
        echo -e "${CYAN}Output-ul tău (primele 10 linii):${NC}"
        echo "$student_output" | head -10
        echo ""
        echo -e "${YELLOW}Hint: $hint${NC}"
        return 1
    fi
}

#-------------------------------------------------------------------------------
# MAIN
#-------------------------------------------------------------------------------

main() {
    # Niciun argument
    if [[ $# -eq 0 ]]; then
        show_help
        exit 0
    fi
    
    # Parse arguments
    case "$1" in
        --list|-l)
            list_exercises
            exit 0
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            if [[ $# -lt 2 ]]; then
                echo -e "${RED}[ERROR] Lipsește comanda de validat!${NC}"
                echo "Usage: $0 <exercise_id> \"<student_command>\""
                exit 1
            fi
            validate_exercise "$1" "$2"
            ;;
    esac
}

main "$@"
