#!/bin/bash
# ============================================================================
# ex4_sales_report.sh - Soluție Model
# Raport vânzări: top produse, regiuni, anomalii
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
MAGENTA='\033[0;35m'
NC='\033[0m'

# ============================================================================
# Verificare argumente
# ============================================================================
if [[ $# -lt 1 ]]; then
    echo -e "${RED}Utilizare: $0 <sales_csv>${NC}"
    exit 1
fi

SALES_FILE="$1"
OUTPUT_DIR="./output"
SUMMARY_FILE="$OUTPUT_DIR/sales_summary.txt"

if [[ ! -f "$SALES_FILE" ]]; then
    echo -e "${RED}Eroare: Fișierul '$SALES_FILE' nu există!${NC}"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

# ============================================================================
# Funcție: Top Produse
# ============================================================================
top_products() {
    echo -e "${CYAN}🏆 TOP 3 PRODUSE (după revenue):${NC}"
    echo ""
    
    awk -F',' '
    NR > 1 {
        product = $2
        quantity = $3
        price = $4
        revenue = quantity * price
        
        total_rev[product] += revenue
        total_qty[product] += quantity
    }
    END {
        # Sortare descrescătoare după revenue
        n = asorti(total_rev, products, "@val_num_desc")
        
        for(i=1; i<=3 && i<=n; i++) {
            p = products[i]
            printf "   %d. %-12s - $%\047.2f (%d unități)\n", 
                i, p, total_rev[p], total_qty[p]
        }
    }' "$SALES_FILE"
    
    echo ""
}

# ============================================================================
# Funcție: Top Regiuni
# ============================================================================
top_regions() {
    echo -e "${CYAN}🌍 TOP 3 REGIUNI:${NC}"
    echo ""
    
    awk -F',' '
    NR > 1 {
        region = $5
        revenue = $3 * $4
        total[region] += revenue
    }
    END {
        n = asorti(total, regions, "@val_num_desc")
        for(i=1; i<=3 && i<=n; i++) {
            r = regions[i]
            printf "   %d. %-8s - $%\047.2f\n", i, r, total[r]
        }
    }' "$SALES_FILE"
    
    echo ""
}

# ============================================================================
# Funcție: Top Vânzător per Regiune
# ============================================================================
top_salesperson_per_region() {
    echo -e "${CYAN}👤 CEL MAI BUN VÂNZĂTOR PER REGIUNE:${NC}"
    echo ""
    
    awk -F',' '
    NR > 1 {
        region = $5
        salesperson = $6
        revenue = $3 * $4
        
        # Cheie compusă region-salesperson
        key = region SUBSEP salesperson
        sales[key] += revenue
        regions[region] = 1
    }
    END {
        for(r in regions) {
            max_rev = 0
            top_person = ""
            for(key in sales) {
                split(key, parts, SUBSEP)
                if(parts[1] == r && sales[key] > max_rev) {
                    max_rev = sales[key]
                    top_person = parts[2]
                }
            }
            printf "   %-8s: %-10s ($%\047.2f)\n", r, top_person, max_rev
        }
    }' "$SALES_FILE" | sort
    
    echo ""
}

# ============================================================================
# Funcție: Detectare Anomalii
# ============================================================================
detect_anomalies() {
    echo -e "${CYAN}⚠️ ANOMALII DETECTATE:${NC}"
    echo ""
    
    local anomalies_found=0
    
    # 1. Verifică gap-uri în date
    echo "   Verificare gap-uri în date..."
    local dates
    dates=$(awk -F',' 'NR>1 {print $1}' "$SALES_FILE" | sort -u)
    
    local prev_date=""
    while IFS= read -r date; do
        if [[ -n "$prev_date" ]]; then
            # Calculează diferența în zile
            local prev_epoch curr_epoch diff
            prev_epoch=$(date -d "$prev_date" +%s 2>/dev/null || echo 0)
            curr_epoch=$(date -d "$date" +%s 2>/dev/null || echo 0)
            
            if [[ $prev_epoch -gt 0 && $curr_epoch -gt 0 ]]; then
                diff=$(( (curr_epoch - prev_epoch) / 86400 ))
                if [[ $diff -gt 1 ]]; then
                    echo -e "   ${YELLOW}- Gap detectat: $prev_date → $date ($diff zile)${NC}"
                    ((anomalies_found++))
                fi
            fi
        fi
        prev_date="$date"
    done <<< "$dates"
    
    # 2. Verifică cantități outlier (> mean + 2*stddev)
    echo "   Verificare cantități neobișnuite..."
    
    awk -F',' '
    NR > 1 {
        qty[NR] = $3
        product[NR] = $2
        date[NR] = $1
        sum += $3
        count++
    }
    END {
        if(count == 0) exit
        
        mean = sum / count
        
        # Calculează stddev
        for(i in qty) {
            variance += (qty[i] - mean)^2
        }
        stddev = sqrt(variance / count)
        
        threshold = mean + 2 * stddev
        
        found = 0
        for(i in qty) {
            if(qty[i] > threshold) {
                printf "   \033[1;33m- Cantitate mare: %s, %s - %d unități (threshold: %.1f)\033[0m\n", 
                    date[i], product[i], qty[i], threshold
                found++
            }
        }
        
        if(found == 0) {
            print "   - Nici o anomalie de cantitate detectată"
        }
    }' "$SALES_FILE"
    
    echo ""
}

# ============================================================================
# Funcție: Export Summary
# ============================================================================
export_summary() {
    echo -e "${CYAN}📁 Export raport: $SUMMARY_FILE${NC}"
    
    {
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║              RAPORT VÂNZĂRI - SUMAR                             ║"
        echo "║   Generat: $(date '+%Y-%m-%d %H:%M:%S')                                   ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo ""
        echo "TOP 3 PRODUSE (după revenue):"
        awk -F',' 'NR>1 {rev[$2]+=$3*$4; qty[$2]+=$3} END {n=asorti(rev,p,"@val_num_desc"); for(i=1;i<=3&&i<=n;i++) printf "  %d. %s - $%.2f (%d unități)\n", i, p[i], rev[p[i]], qty[p[i]]}' "$SALES_FILE"
        echo ""
        echo "TOP 3 REGIUNI:"
        awk -F',' 'NR>1 {t[$5]+=$3*$4} END {n=asorti(t,r,"@val_num_desc"); for(i=1;i<=3&&i<=n;i++) printf "  %d. %s - $%.2f\n", i, r[i], t[r[i]]}' "$SALES_FILE"
        echo ""
        echo "STATISTICI GENERALE:"
        awk -F',' 'NR>1 {total+=$3*$4; items+=$3; trans++} END {printf "  Total Revenue: $%.2f\n  Total Items: %d\n  Tranzacții: %d\n  Revenue Mediu/Tranzacție: $%.2f\n", total, items, trans, total/trans}' "$SALES_FILE"
    } > "$SUMMARY_FILE"
    
    echo -e "  ${GREEN}✅ Raport salvat!${NC}"
    echo ""
}

# ============================================================================
# Main
# ============================================================================
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║              RAPORT VÂNZĂRI - IANUARIE 2024                    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

top_products
top_regions
top_salesperson_per_region
detect_anomalies
export_summary

echo -e "${GREEN}✅ Raport complet generat!${NC}"
