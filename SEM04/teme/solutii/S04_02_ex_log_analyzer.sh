#!/bin/bash
# ============================================================================
# ex2_log_analyzer.sh - Soluție Model
# Analiză log-uri: severitate, autentificare, statistici
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
    echo -e "${RED}Utilizare: $0 <log_file>${NC}"
    exit 1
fi

LOG_FILE="$1"

if [[ ! -f "$LOG_FILE" ]]; then
    echo -e "${RED}Eroare: Fișierul '$LOG_FILE' nu există!${NC}"
    exit 1
fi

# ============================================================================
# Funcție: Raport Severitate
# ============================================================================
severity_report() {
    echo -e "${CYAN}📊 DISTRIBUȚIE SEVERITATE:${NC}"
    echo ""
    
    # Numără fiecare nivel de severitate
    awk -F'[][]' '
    /\[(INFO|WARNING|ERROR|DEBUG)\]/ {
        level = $2
        count[level]++
        total++
    }
    END {
        # Sortare: INFO, WARNING, ERROR, DEBUG
        levels[1]="INFO"; levels[2]="WARNING"; levels[3]="ERROR"; levels[4]="DEBUG"
        for(i=1; i<=4; i++) {
            l = levels[i]
            if(count[l] > 0) {
                pct = (count[l] / total) * 100
                # Generează bara vizuală
                bar_len = int(count[l] * 2)
                bar = ""
                for(j=0; j<bar_len && j<30; j++) bar = bar "█"
                printf "  %-10s %3d mesaje (%5.1f%%) %s\n", l":", count[l], pct, bar
            }
        }
    }' "$LOG_FILE"
    
    echo ""
}

# ============================================================================
# Funcție: Tentative Autentificare Eșuate
# ============================================================================
failed_auth_report() {
    echo -e "${CYAN}🚨 TENTATIVE AUTENTIFICARE EȘUATE:${NC}"
    echo ""
    
    # Caută pattern-uri de autentificare eșuată
    local found=0
    
    while IFS= read -r line; do
        # Extrage timestamp
        local timestamp
        timestamp=$(echo "$line" | grep -oE '[0-9]{2}:[0-9]{2}:[0-9]{2}')
        
        # Extrage email/user
        local user
        user=$(echo "$line" | grep -oE '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}')
        
        # Extrage IP
        local ip
        ip=$(echo "$line" | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | tail -1)
        
        if [[ -n "$timestamp" && -n "$user" ]]; then
            echo -e "  ${RED}[${timestamp}]${NC} ${YELLOW}$user${NC} de la ${BLUE}${ip:-unknown}${NC}"
            ((found++))
        fi
    done < <(grep -iE 'authentication failed|auth.*failed|failed.*login|denied' "$LOG_FILE" 2>/dev/null)
    
    if [[ $found -eq 0 ]]; then
        echo "  (Nicio tentativă eșuată detectată)"
    fi
    
    echo ""
}

# ============================================================================
# Funcție: Statistici Generale
# ============================================================================
general_stats() {
    echo -e "${CYAN}📈 STATISTICI GENERALE:${NC}"
    echo ""
    
    # Extrage statistici cu AWK
    awk '
    BEGIN {
        first_ts = ""
        last_ts = ""
        total = 0
        errors = 0
    }
    {
        total++
        
        # Extrage timestamp (format: YYYY-MM-DD HH:MM:SS)
        if(match($0, /[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}/)) {
            ts = substr($0, RSTART, RLENGTH)
            if(first_ts == "" || ts < first_ts) first_ts = ts
            if(ts > last_ts) last_ts = ts
        }
        
        # Numără erori
        if(/\[ERROR\]/) errors++
    }
    END {
        if(total > 0) {
            error_pct = (errors / total) * 100
            printf "  Perioadă:         %s → %s\n", first_ts, substr(last_ts, 12)
            printf "  Total evenimente: %d\n", total
            printf "  Erori:            %d (%.1f%%)\n", errors, error_pct
            
            # Indicator vizual pentru rata de erori
            if(error_pct > 20) status = "🔴 CRITIC"
            else if(error_pct > 10) status = "🟠 ATENȚIE"
            else if(error_pct > 5) status = "🟡 MODERAT"
            else status = "🟢 NORMAL"
            
            printf "  Status:           %s\n", status
        }
    }' "$LOG_FILE"
    
    echo ""
}

# ============================================================================
# Main
# ============================================================================
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║              RAPORT ANALIZĂ LOG                            ║${NC}"
echo -e "${BLUE}║   Fișier: $(printf '%-45s' "$LOG_FILE")║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

severity_report
failed_auth_report
general_stats

echo -e "${GREEN}✅ Analiză completă!${NC}"
