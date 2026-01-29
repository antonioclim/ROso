#!/bin/bash
# ============================================================================
# ex3_data_transform.sh - Soluție Model
# modificare date CSV: raport tabelar, statistici, actualizare
#
# Autor: [Instructor]
# Versiune: 1.0
# ============================================================================
set -euo pipefail

# Culori
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# ============================================================================
# Verificare argumente
# ============================================================================
if [[ $# -lt 1 ]]; then
    echo -e "${RED}Utilizare: $0 <csv_file>${NC}"
    exit 1
fi

CSV_FILE="$1"
OUTPUT_DIR="./output"

if [[ ! -f "$CSV_FILE" ]]; then
    echo -e "${RED}Eroare: Fișierul '$CSV_FILE' nu există!${NC}"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

# ============================================================================
# Funcție: Format număr cu separator mii
# ============================================================================
format_currency() {
    printf "$%'d" "$1"
}

# ============================================================================
# Funcție: Raport Tabelar
# ============================================================================
generate_table_report() {
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                       RAPORT ANGAJAȚI TECHCORP                             ║${NC}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════════════════════════╣${NC}"
    printf "${CYAN}║${NC} %-6s │ %-20s │ %-12s │ %10s │ %-8s ${CYAN}║${NC}\n" \
        "ID" "Nume" "Departament" "Salariu" "Status"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════════════════════════╣${NC}"
    
    # Procesează CSV și formatează
    awk -F',' 'NR > 1 {
        id = $1
        name = $2
        dept = $4
        salary = $5
        status = $7
        
        # Formatare salariu cu separator mii
        sal_fmt = sprintf("$%\047d", salary)
        
        # Culoare status
        if(status == "active") 
            status_color = "\033[0;32m"  # verde
        else 
            status_color = "\033[0;31m"  # roșu
        
        printf "\033[0;36m║\033[0m %-6s │ %-20s │ %-12s │ %10s │ %s%-8s\033[0m \033[0;36m║\033[0m\n", 
            id, name, dept, sal_fmt, status_color, status
    }' "$CSV_FILE"
    
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# ============================================================================
# Funcție: Statistici per Departament
# ============================================================================
department_stats() {
    echo -e "${CYAN}📊 STATISTICI PER DEPARTAMENT:${NC}"
    echo ""
    echo "┌──────────────┬──────────┬────────────┬────────────┬────────────┐"
    echo "│ Departament  │ Angajați │ Sal. Mediu │ Sal. Min   │ Sal. Max   │"
    echo "├──────────────┼──────────┼────────────┼────────────┼────────────┤"
    
    awk -F',' '
    NR > 1 {
        dept = $4
        salary = $5
        
        count[dept]++
        sum[dept] += salary
        
        if(!(dept in min) || salary < min[dept]) min[dept] = salary
        if(salary > max[dept]) max[dept] = salary
    }
    END {
        # Sortare departamente
        n = asorti(count, sorted)
        for(i=1; i<=n; i++) {
            d = sorted[i]
            avg = sum[d] / count[d]
            printf "│ %-12s │ %8d │ $%9.0f │ $%9d │ $%9d │\n", 
                d, count[d], avg, min[d], max[d]
        }
    }' "$CSV_FILE"
    
    echo "└──────────────┴──────────┴────────────┴────────────┴────────────┘"
    echo ""
}

# ============================================================================
# Funcție: Generare Fișier Actualizat
# ============================================================================
generate_updated_csv() {
    local output_file="$OUTPUT_DIR/employees_updated.csv"
    local current_year
    current_year=$(date +%Y)
    
    echo -e "${CYAN}📁 Generare fișier actualizat: $output_file${NC}"
    echo ""
    
    awk -F',' -v year="$current_year" '
    BEGIN {
        OFS = ","
    }
    NR == 1 {
        # Header - adaugă coloana nouă
        print $0 ",years_employed"
        next
    }
    {
        # Lowercase pentru email
        email = tolower($3)
        
        # Schimbă status
        status = $7
        if(status == "inactive") status = "on_leave"
        
        # Calculează ani de angajare
        # hire_date este în format YYYY-MM-DD
        split($6, date_parts, "-")
        hire_year = date_parts[1]
        years = year - hire_year
        
        # Reconstruiește linia
        printf "%s,%s,%s,%s,%s,%s,%s,%d\n", 
            $1, $2, email, $4, $5, $6, status, years
    }' "$CSV_FILE" > "$output_file"
    
    echo -e "  ${GREEN}✅ Fișier creat cu succes!${NC}"
    echo "  Modificări aplicate:"
    echo "    - Email-uri normalizate la lowercase"
    echo "    - Status 'inactive' → 'on_leave'"
    echo "    - Adăugată coloana 'years_employed'"
    echo ""
    
    # Arată primele linii
    echo "  Preview (primele 5 linii):"
    head -5 "$output_file" | while IFS= read -r line; do
        echo "    $line"
    done
    echo ""
}

# ============================================================================
# Main
# ============================================================================
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           TRANSFORMARE DATE - EMPLOYEES CSV                ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

generate_table_report
department_stats
generate_updated_csv

echo -e "${GREEN}✅ Transformare completă!${NC}"
