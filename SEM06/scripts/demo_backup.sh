#!/bin/bash
#===============================================================================
# DEMO BACKUP - Demonstrație Interactivă Sistem Backup
#===============================================================================
# Scop: Demonstrează funcționalitățile complete ale sistemului de backup
# Utilizare: ./demo_backup.sh [--auto|--interactive|--quick]
# Autor: Seminarul 11-12 CAPSTONE - Sisteme de Operare ASE București
#===============================================================================

set -euo pipefail

#-------------------------------------------------------------------------------
# CONSTANTE ȘI CONFIGURARE
#-------------------------------------------------------------------------------
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_DIR="${SCRIPT_DIR}/projects/backup"
readonly DEMO_BASE="/tmp/backup_demo_$$"
readonly DEMO_SOURCE="${DEMO_BASE}/source"
readonly DEMO_DEST="${DEMO_BASE}/backups"
readonly DEMO_RESTORE="${DEMO_BASE}/restored"

# Culori ANSI
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly BOLD='\033[1m'
readonly DIM='\033[2m'
readonly NC='\033[0m'

# Variabile globale
DEMO_MODE="interactive"
DEMO_STEP=0
PAUSE_ENABLED=true

#-------------------------------------------------------------------------------
# FUNCȚII UTILITATE
#-------------------------------------------------------------------------------

print_banner() {
    clear
    echo -e "${CYAN}"
    cat << 'EOF'
    ╔══════════════════════════════════════════════════════════════════════╗
    ║                                                                      ║
    ║   ██████╗  █████╗  ██████╗██╗  ██╗██╗   ██╗██████╗                   ║
    ║   ██╔══██╗██╔══██╗██╔════╝██║ ██╔╝██║   ██║██╔══██╗                  ║
    ║   ██████╔╝███████║██║     █████╔╝ ██║   ██║██████╔╝                  ║
    ║   ██╔══██╗██╔══██║██║     ██╔═██╗ ██║   ██║██╔═══╝                   ║
    ║   ██████╔╝██║  ██║╚██████╗██║  ██╗╚██████╔╝██║                       ║
    ║   ╚═════╝ ╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝                       ║
    ║                                                                      ║
    ║              SISTEM DE BACKUP AUTOMAT - DEMONSTRAȚIE                 ║
    ║                  Seminarul 11-12 CAPSTONE                            ║
    ╚══════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

print_section() {
    local title="$1"
    local width=70
    
    echo ""
    echo -e "${BLUE}$(printf '═%.0s' $(seq 1 $width))${NC}"
    echo -e "${BOLD}${WHITE}  $title${NC}"
    echo -e "${BLUE}$(printf '═%.0s' $(seq 1 $width))${NC}"
    echo ""
}

print_step() {
    ((DEMO_STEP++))
    echo -e "\n${MAGENTA}[Pasul $DEMO_STEP]${NC} ${BOLD}$1${NC}\n"
}

print_info() {
    echo -e "${CYAN}ℹ${NC}  $1"
}

print_success() {
    echo -e "${GREEN}✓${NC}  $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC}  $1"
}

print_error() {
    echo -e "${RED}✗${NC}  $1"
}

print_command() {
    echo -e "${DIM}${WHITE}\$ $1${NC}"
}

run_command() {
    local cmd="$1"
    local description="${2:-}"
    
    [[ -n "$description" ]] && print_info "$description"
    print_command "$cmd"
    echo ""
    
    eval "$cmd" 2>&1 | while IFS= read -r line; do
        echo -e "   ${DIM}$line${NC}"
    done
    
    local exit_code=${PIPESTATUS[0]}
    echo ""
    
    if [[ $exit_code -eq 0 ]]; then
        print_success "Comandă executată cu succes"
    else
        print_warning "Comandă terminată cu cod: $exit_code"
    fi
    
    return $exit_code
}

pause_demo() {
    if [[ "$PAUSE_ENABLED" == "true" ]]; then
        echo ""
        echo -e "${YELLOW}Apasă ENTER pentru a continua...${NC}"
        read -r
    else
        sleep 1
    fi
}

#-------------------------------------------------------------------------------
# SETUP ȘI CLEANUP
#-------------------------------------------------------------------------------

setup_demo_environment() {
    print_section "PREGĂTIRE MEDIU DEMONSTRAȚIE"
    
    print_step "Creare structură directoare demo"
    
    # Cleanup dacă există
    rm -rf "$DEMO_BASE"
    
    # Creare structură
    mkdir -p "$DEMO_SOURCE"/{documents,projects,configs,logs}
    mkdir -p "$DEMO_DEST"
    mkdir -p "$DEMO_RESTORE"
    
    print_success "Directoare create: $DEMO_BASE"
    
    # Populare cu date demonstrative
    print_step "Generare fișiere demonstrative"
    
    # Documente
    for i in {1..5}; do
        cat > "$DEMO_SOURCE/documents/document_$i.txt" << EOF
Document demonstrativ #$i
========================
Acesta este un fișier de test pentru demonstrația sistemului de backup.
Data creării: $(date)
Dimensiune planificată: aproximativ 1KB

Lorem ipsum dolor sit amet, consectetur adipiscing elit.
Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.

Secțiune tehnică:
- Sistem: $(uname -s)
- Kernel: $(uname -r)
- User: $(whoami)

EOF
    done
    print_success "5 documente create în documents/"
    
    # Proiecte (cod sursă simulat)
    cat > "$DEMO_SOURCE/projects/main.c" << 'EOF'
/*
 * Program demonstrativ C
 * Pentru testarea backup-ului cod sursă
 */
#include <stdio.h>
#include <stdlib.h>

#define VERSION "1.0.0"
#define MAX_ITEMS 100

typedef struct {
    int id;
    char name[50];
    double value;
} Item;

int main(int argc, char *argv[]) {
    printf("Demo Program v%s\n", VERSION);
    printf("Arguments: %d\n", argc);
    
    Item items[MAX_ITEMS];
    int count = 0;
    
    // Simulare procesare
    for (int i = 0; i < 10; i++) {
        items[count].id = i;
        sprintf(items[count].name, "Item_%d", i);
        items[count].value = i * 3.14159;
        count++;
    }
    
    printf("Processed %d items\n", count);
    return EXIT_SUCCESS;
}
EOF
    
    cat > "$DEMO_SOURCE/projects/utils.py" << 'EOF'
#!/usr/bin/env python3
"""
Modul utilitar Python pentru demonstrație backup
"""

import os
import sys
import json
from datetime import datetime
from pathlib import Path

class BackupHelper:
    """Clasă helper pentru operații backup."""
    
    def __init__(self, base_path: str):
        self.base_path = Path(base_path)
        self.timestamp = datetime.now()
    
    def get_files(self, pattern: str = "*") -> list:
        """Returnează lista fișierelor matching pattern."""
        return list(self.base_path.glob(pattern))
    
    def calculate_size(self) -> int:
        """Calculează dimensiunea totală."""
        total = 0
        for f in self.base_path.rglob("*"):
            if f.is_file():
                total += f.stat().st_size
        return total
    
    def to_json(self) -> str:
        """Serializare JSON."""
        return json.dumps({
            "path": str(self.base_path),
            "timestamp": self.timestamp.isoformat(),
            "size": self.calculate_size()
        }, indent=2)

if __name__ == "__main__":
    helper = BackupHelper(sys.argv[1] if len(sys.argv) > 1 else ".")
    print(helper.to_json())
EOF
    
    cat > "$DEMO_SOURCE/projects/Makefile" << 'EOF'
# Makefile demonstrativ
CC = gcc
CFLAGS = -Wall -Wextra -O2
TARGET = demo_app

.PHONY: all clean install

all: $(TARGET)

$(TARGET): main.c
	$(CC) $(CFLAGS) -o $@ $<

clean:
	rm -f $(TARGET) *.o

install: $(TARGET)
	install -m 755 $(TARGET) /usr/local/bin/
EOF
    print_success "Proiecte cod sursă create în projects/"
    
    # Configurări
    cat > "$DEMO_SOURCE/configs/app.conf" << 'EOF'
# Configurare aplicație demonstrativă
[general]
app_name = DemoApp
version = 1.0.0
debug = false

[database]
host = localhost
port = 5432
name = demo_db
user = demo_user
# password = secret (nu include în backup!)

[logging]
level = INFO
file = /var/log/demo.log
max_size = 10M
backup_count = 5

[features]
feature_a = enabled
feature_b = disabled
experimental = false
EOF
    
    cat > "$DEMO_SOURCE/configs/network.yaml" << 'EOF'
# Configurare rețea
network:
  interfaces:
    eth0:
      type: static
      address: 192.168.1.100
      netmask: 255.255.255.0
      gateway: 192.168.1.1
    eth1:
      type: dhcp
  dns:
    servers:
      - 8.8.8.8
      - 8.8.4.4
    search:
      - example.com
      - local
EOF
    print_success "Fișiere configurare create în configs/"
    
    # Loguri (pentru a demonstra excluderi)
    for i in {1..3}; do
        dd if=/dev/urandom bs=1024 count=100 2>/dev/null | base64 > "$DEMO_SOURCE/logs/app_$i.log"
    done
    print_success "Fișiere log create în logs/ (vor fi excluse)"
    
    # Afișare structură
    print_step "Structura directorului sursă"
    if command -v tree &>/dev/null; then
        tree -L 2 --dirsfirst "$DEMO_SOURCE"
    else
        find "$DEMO_SOURCE" -type f | head -20
    fi
    
    # Statistici
    local total_files=$(find "$DEMO_SOURCE" -type f | wc -l)
    local total_size=$(du -sh "$DEMO_SOURCE" | cut -f1)
    
    echo ""
    print_info "Total fișiere: $total_files"
    print_info "Dimensiune totală: $total_size"
    
    pause_demo
}

cleanup_demo() {
    print_section "CURĂȚARE MEDIU DEMO"
    
    if [[ -d "$DEMO_BASE" ]]; then
        rm -rf "$DEMO_BASE"
        print_success "Director demo șters: $DEMO_BASE"
    fi
}

#-------------------------------------------------------------------------------
# DEMONSTRAȚII FUNCȚIONALITĂȚI
#-------------------------------------------------------------------------------

demo_basic_backup() {
    print_section "DEMONSTRAȚIE 1: BACKUP SIMPLU"
    
    print_info "Vom crea un backup simplu al directorului sursă"
    print_info "Acest exemplu demonstrează funcționalitatea de bază"
    
    pause_demo
    
    print_step "Executare backup simplu"
    
    local backup_script="${PROJECT_DIR}/backup.sh"
    
    if [[ -f "$backup_script" ]]; then
        run_command "bash '$backup_script' --source '$DEMO_SOURCE' --destination '$DEMO_DEST' --name 'demo_simple' --verbose" \
            "Backup cu opțiuni explicite"
    else
        # Simulare dacă scriptul nu există
        print_warning "Script backup.sh nu este disponibil, simulare..."
        
        local archive_name="demo_simple_$(date +%Y%m%d_%H%M%S).tar.gz"
        tar -czvf "$DEMO_DEST/$archive_name" -C "$DEMO_SOURCE" . 2>&1 | head -20
        print_success "Arhivă creată: $archive_name"
    fi
    
    # Verificare rezultat
    print_step "Verificare backup creat"
    ls -lh "$DEMO_DEST"/ 2>/dev/null || print_warning "Directorul backup este gol"
    
    pause_demo
}

demo_compression_comparison() {
    print_section "DEMONSTRAȚIE 2: COMPARAȚIE METODE COMPRESIE"
    
    print_info "Vom compara diferite metode de compresie:"
    print_info "  • gzip  - rapidă, compresie medie"
    print_info "  • bzip2 - mai lentă, compresie mai bună"
    print_info "  • xz    - cea mai lentă, compresie excelentă"
    
    pause_demo
    
    local test_dir="$DEMO_SOURCE/documents"
    local results_file="$DEMO_BASE/compression_results.txt"
    
    echo "Metodă     | Timp (s) | Dimensiune | Rată" > "$results_file"
    echo "-----------|----------|------------|------" >> "$results_file"
    
    for method in gzip bzip2 xz; do
        print_step "Testare compresie: $method"
        
        local output_file="$DEMO_DEST/test_${method}.tar"
        local start_time=$(date +%s.%N)
        
        case $method in
            gzip)
                tar -czf "${output_file}.gz" -C "$test_dir" . 2>/dev/null
                output_file="${output_file}.gz"
                ;;
            bzip2)
                tar -cjf "${output_file}.bz2" -C "$test_dir" . 2>/dev/null
                output_file="${output_file}.bz2"
                ;;
            xz)
                tar -cJf "${output_file}.xz" -C "$test_dir" . 2>/dev/null
                output_file="${output_file}.xz"
                ;;
        esac
        
        local end_time=$(date +%s.%N)
        local duration=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "N/A")
        local size=$(stat -c%s "$output_file" 2>/dev/null || echo "0")
        local size_human=$(ls -lh "$output_file" 2>/dev/null | awk '{print $5}')
        
        printf "%-10s | %7.3f  | %10s | -\n" "$method" "$duration" "$size_human" >> "$results_file"
        
        print_success "$method: $size_human în ${duration}s"
    done
    
    echo ""
    print_step "Rezultate comparație"
    cat "$results_file"
    
    pause_demo
}

demo_incremental_backup() {
    print_section "DEMONSTRAȚIE 3: BACKUP INCREMENTAL"
    
    print_info "Backup incremental salvează doar modificările"
    print_info "Economisește spațiu și timp pentru date mari"
    
    pause_demo
    
    # Backup inițial complet
    print_step "Creare backup complet inițial"
    
    local full_backup="$DEMO_DEST/full_$(date +%Y%m%d_%H%M%S).tar.gz"
    local snapshot="$DEMO_BASE/snapshot.snar"
    
    tar --listed-incremental="$snapshot" -czf "$full_backup" -C "$DEMO_SOURCE" . 2>/dev/null
    print_success "Backup complet: $(ls -lh "$full_backup" | awk '{print $5}')"
    
    # Modificare fișiere
    print_step "Simulare modificări în fișiere"
    
    echo "Modificare la $(date)" >> "$DEMO_SOURCE/documents/document_1.txt"
    echo "Fișier nou creat" > "$DEMO_SOURCE/documents/new_file.txt"
    rm -f "$DEMO_SOURCE/documents/document_5.txt"
    
    print_success "Modificat: document_1.txt"
    print_success "Creat: new_file.txt"
    print_success "Șters: document_5.txt"
    
    # Backup incremental
    print_step "Creare backup incremental"
    sleep 1
    
    local incr_backup="$DEMO_DEST/incr_$(date +%Y%m%d_%H%M%S).tar.gz"
    tar --listed-incremental="$snapshot" -czf "$incr_backup" -C "$DEMO_SOURCE" . 2>/dev/null
    print_success "Backup incremental: $(ls -lh "$incr_backup" | awk '{print $5}')"
    
    # Comparație dimensiuni
    print_step "Comparație dimensiuni"
    echo ""
    printf "%-20s %10s\n" "Tip" "Dimensiune"
    printf "%-20s %10s\n" "---" "----------"
    printf "%-20s %10s\n" "Backup complet" "$(ls -lh "$full_backup" | awk '{print $5}')"
    printf "%-20s %10s\n" "Backup incremental" "$(ls -lh "$incr_backup" | awk '{print $5}')"
    
    pause_demo
}

demo_exclusion_patterns() {
    print_section "DEMONSTRAȚIE 4: PATTERN-URI DE EXCLUDERE"
    
    print_info "Excluderea fișierelor neimportante din backup:"
    print_info "  • Fișiere log (*.log)"
    print_info "  • Fișiere temporare (*.tmp, *.temp)"
    print_info "  • Cache și build artifacts"
    
    pause_demo
    
    # Creare fișiere de exclus
    print_step "Creare fișiere pentru demonstrație excludere"
    
    touch "$DEMO_SOURCE/temp_file.tmp"
    touch "$DEMO_SOURCE/cache.temp"
    mkdir -p "$DEMO_SOURCE/.cache"
    echo "cache data" > "$DEMO_SOURCE/.cache/data"
    
    # Afișare înainte de excludere
    print_step "Conținut sursă ÎNAINTE de excludere"
    find "$DEMO_SOURCE" -type f | wc -l | xargs -I {} echo "Total fișiere: {}"
    
    # Backup fără excluderi
    print_step "Backup FĂRĂ excluderi"
    local backup_all="$DEMO_DEST/no_exclude.tar.gz"
    tar -czf "$backup_all" -C "$DEMO_SOURCE" . 2>/dev/null
    print_info "Dimensiune: $(ls -lh "$backup_all" | awk '{print $5}')"
    
    # Backup cu excluderi
    print_step "Backup CU excluderi"
    local backup_filtered="$DEMO_DEST/with_exclude.tar.gz"
    tar -czf "$backup_filtered" \
        --exclude='*.log' \
        --exclude='*.tmp' \
        --exclude='*.temp' \
        --exclude='.cache' \
        --exclude='logs' \
        -C "$DEMO_SOURCE" . 2>/dev/null
    print_info "Dimensiune: $(ls -lh "$backup_filtered" | awk '{print $5}')"
    
    # Comparație
    print_step "Comparație rezultate"
    echo ""
    local size_all=$(stat -c%s "$backup_all")
    local size_filtered=$(stat -c%s "$backup_filtered")
    local saved=$((size_all - size_filtered))
    local percent=$((saved * 100 / size_all))
    
    printf "%-25s %12s\n" "Backup complet" "$(ls -lh "$backup_all" | awk '{print $5}')"
    printf "%-25s %12s\n" "Backup cu excluderi" "$(ls -lh "$backup_filtered" | awk '{print $5}')"
    printf "%-25s %12s\n" "Spațiu economisit" "${saved} bytes (${percent}%)"
    
    pause_demo
}

demo_integrity_verification() {
    print_section "DEMONSTRAȚIE 5: VERIFICARE INTEGRITATE"
    
    print_info "Verificarea integrității backup-urilor este critică"
    print_info "Demonstrăm: MD5, SHA1, SHA256"
    
    pause_demo
    
    # Creare backup pentru verificare
    print_step "Creare backup pentru verificare"
    local test_backup="$DEMO_DEST/integrity_test.tar.gz"
    tar -czf "$test_backup" -C "$DEMO_SOURCE/documents" . 2>/dev/null
    print_success "Backup creat: $(basename "$test_backup")"
    
    # Generare checksums
    print_step "Generare checksums"
    
    local md5sum=$(md5sum "$test_backup" | cut -d' ' -f1)
    local sha1sum=$(sha1sum "$test_backup" | cut -d' ' -f1)
    local sha256sum=$(sha256sum "$test_backup" | cut -d' ' -f1)
    
    echo ""
    echo -e "${CYAN}MD5:${NC}    $md5sum"
    echo -e "${CYAN}SHA1:${NC}   $sha1sum"
    echo -e "${CYAN}SHA256:${NC} $sha256sum"
    
    # Salvare checksums
    echo "$md5sum  $(basename "$test_backup")" > "${test_backup}.md5"
    echo "$sha1sum  $(basename "$test_backup")" > "${test_backup}.sha1"
    echo "$sha256sum  $(basename "$test_backup")" > "${test_backup}.sha256"
    
    print_success "Fișiere checksum create"
    
    # Verificare integritate
    print_step "Verificare integritate (fișier intact)"
    
    cd "$DEMO_DEST"
    if md5sum -c "$(basename "${test_backup}.md5")" 2>/dev/null; then
        print_success "MD5 verificat cu succes"
    fi
    cd - > /dev/null
    
    # Simulare corupție
    print_step "Simulare corupție și detectare"
    
    local corrupted="$DEMO_DEST/corrupted.tar.gz"
    cp "$test_backup" "$corrupted"
    
    # Corupere prin modificare byte
    printf '\x00' | dd of="$corrupted" bs=1 seek=100 count=1 conv=notrunc 2>/dev/null
    
    local new_md5=$(md5sum "$corrupted" | cut -d' ' -f1)
    
    echo ""
    echo -e "MD5 original: ${GREEN}$md5sum${NC}"
    echo -e "MD5 corupt:   ${RED}$new_md5${NC}"
    
    if [[ "$md5sum" != "$new_md5" ]]; then
        print_warning "CORUPȚIE DETECTATĂ! Checksums nu corespund."
    fi
    
    pause_demo
}

demo_restore_process() {
    print_section "DEMONSTRAȚIE 6: PROCES RESTAURARE"
    
    print_info "Restaurarea datelor din backup"
    print_info "Opțiuni: completă, selectivă, într-o locație nouă"
    
    pause_demo
    
    # Backup pentru restaurare
    print_step "Pregătire backup pentru restaurare"
    local restore_backup="$DEMO_DEST/for_restore.tar.gz"
    tar -czf "$restore_backup" -C "$DEMO_SOURCE" . 2>/dev/null
    print_success "Backup creat: $(ls -lh "$restore_backup" | awk '{print $5}')"
    
    # Listare conținut
    print_step "Listare conținut arhivă (fără extragere)"
    echo ""
    tar -tzvf "$restore_backup" | head -15
    echo "..."
    
    # Restaurare completă
    print_step "Restaurare completă"
    mkdir -p "$DEMO_RESTORE/full"
    tar -xzf "$restore_backup" -C "$DEMO_RESTORE/full" 2>/dev/null
    print_success "Restaurat în: $DEMO_RESTORE/full"
    
    local orig_count=$(find "$DEMO_SOURCE" -type f | wc -l)
    local rest_count=$(find "$DEMO_RESTORE/full" -type f | wc -l)
    print_info "Fișiere originale: $orig_count | Restaurate: $rest_count"
    
    # Restaurare selectivă
    print_step "Restaurare selectivă (doar configs/)"
    mkdir -p "$DEMO_RESTORE/selective"
    tar -xzf "$restore_backup" -C "$DEMO_RESTORE/selective" --wildcards 'configs/*' 2>/dev/null || \
    tar -xzf "$restore_backup" -C "$DEMO_RESTORE/selective" configs/ 2>/dev/null || true
    
    echo "Conținut restaurat selectiv:"
    ls -la "$DEMO_RESTORE/selective/" 2>/dev/null || print_warning "Restaurare selectivă necesită structură arhivă specifică"
    
    # Verificare integritate restaurare
    print_step "Verificare integritate restaurare"
    
    if diff -rq "$DEMO_SOURCE/documents" "$DEMO_RESTORE/full/documents" &>/dev/null; then
        print_success "Directorul documents/ restaurat corect"
    else
        print_warning "Diferențe detectate în documents/"
    fi
    
    pause_demo
}

demo_rotation_policies() {
    print_section "DEMONSTRAȚIE 7: POLITICI DE ROTAȚIE"
    
    print_info "Rotația backup-urilor pentru economisire spațiu:"
    print_info "  • Retenție după număr (ultimele N backup-uri)"
    print_info "  • Retenție după vârstă (mai noi de X zile)"
    print_info "  • Politici mixte (daily/weekly/monthly)"
    
    pause_demo
    
    # Creare backup-uri simulate cu date diferite
    print_step "Simulare backup-uri cu date diferite"
    
    local rotation_dir="$DEMO_DEST/rotation_test"
    mkdir -p "$rotation_dir"
    
    # Creare 10 backup-uri "vechi"
    for i in {1..10}; do
        local fake_date=$(date -d "$i days ago" +%Y%m%d_%H%M%S)
        local backup_file="$rotation_dir/backup_${fake_date}.tar.gz"
        echo "Backup $i content" | gzip > "$backup_file"
        # Modificare timestamp
        touch -d "$i days ago" "$backup_file"
    done
    
    print_success "10 backup-uri create cu timestamps diferite"
    
    # Afișare înainte de rotație
    print_step "Backup-uri ÎNAINTE de rotație"
    ls -lt "$rotation_dir"/*.tar.gz | head -10
    
    # Simulare rotație prin număr
    print_step "Rotație: păstrare ultimele 5"
    
    local count=0
    for f in $(ls -t "$rotation_dir"/*.tar.gz); do
        ((count++))
        if [[ $count -gt 5 ]]; then
            rm -f "$f"
            print_warning "Șters: $(basename "$f")"
        fi
    done
    
    # Afișare după rotație
    print_step "Backup-uri DUPĂ rotație"
    ls -lt "$rotation_dir"/*.tar.gz 2>/dev/null || echo "Director gol"
    
    pause_demo
}

demo_automation_cron() {
    print_section "DEMONSTRAȚIE 8: AUTOMATIZARE CU CRON"
    
    print_info "Configurare backup automat folosind cron"
    
    pause_demo
    
    print_step "Exemple configurări crontab"
    
    cat << 'EOF'
# Backup zilnic la 2:00 AM
0 2 * * * /path/to/backup.sh --daily

# Backup săptămânal duminică la 3:00 AM
0 3 * * 0 /path/to/backup.sh --weekly

# Backup lunar în prima zi la 4:00 AM
0 4 1 * * /path/to/backup.sh --monthly

# Backup la fiecare 6 ore
0 */6 * * * /path/to/backup.sh --incremental

# Backup cu logging
0 2 * * * /path/to/backup.sh >> /var/log/backup.log 2>&1
EOF
    
    print_step "Script wrapper pentru cron"
    
    local cron_script="$DEMO_BASE/backup_cron.sh"
    cat > "$cron_script" << 'CRONSCRIPT'
#!/bin/bash
# Script backup pentru executare din cron
# Adaugă în crontab: 0 2 * * * /path/to/backup_cron.sh

LOG_FILE="/var/log/backup_$(date +%Y%m%d).log"
LOCK_FILE="/tmp/backup.lock"

# Previne execuții paralele
exec 200>"$LOCK_FILE"
flock -n 200 || { echo "Backup deja în execuție"; exit 1; }

{
    echo "=== Backup început: $(date) ==="
    
    # Executare backup
    /path/to/backup.sh \
        --source /home \
        --destination /backup \
        --compress gzip \
        --rotate 7
    
    EXIT_CODE=$?
    
    echo "=== Backup terminat: $(date) ==="
    echo "Exit code: $EXIT_CODE"
    
} >> "$LOG_FILE" 2>&1

# Cleanup lock
rm -f "$LOCK_FILE"
exit $EXIT_CODE
CRONSCRIPT
    
    print_success "Script cron salvat: $cron_script"
    cat "$cron_script"
    
    pause_demo
}

#-------------------------------------------------------------------------------
# MAIN
#-------------------------------------------------------------------------------

show_summary() {
    print_section "SUMAR DEMONSTRAȚIE"
    
    echo -e "${GREEN}Funcționalități demonstrate:${NC}"
    echo ""
    echo "  1. ✓ Backup simplu - creare arhive tar.gz"
    echo "  2. ✓ Comparație compresie - gzip vs bzip2 vs xz"
    echo "  3. ✓ Backup incremental - economisire spațiu"
    echo "  4. ✓ Pattern-uri excludere - filtrare fișiere"
    echo "  5. ✓ Verificare integritate - checksums MD5/SHA"
    echo "  6. ✓ Restaurare - completă și selectivă"
    echo "  7. ✓ Politici rotație - retenție automată"
    echo "  8. ✓ Automatizare - integrare cron"
    echo ""
    
    print_info "Director demo: $DEMO_BASE"
    print_info "Backup-uri create în: $DEMO_DEST"
    
    if command -v tree &>/dev/null; then
        echo ""
        tree -L 1 "$DEMO_DEST" 2>/dev/null
    fi
}

show_help() {
    echo "Utilizare: $(basename "$0") [OPȚIUNI]"
    echo ""
    echo "Opțiuni:"
    echo "  --auto        Mod automat fără pauze"
    echo "  --interactive Mod interactiv cu pauze (implicit)"
    echo "  --quick       Demonstrație rapidă (subseturi)"
    echo "  --demo N      Execută doar demonstrația N (1-8)"
    echo "  --help        Afișează acest ajutor"
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --auto)
                PAUSE_ENABLED=false
                shift
                ;;
            --interactive)
                PAUSE_ENABLED=true
                shift
                ;;
            --quick)
                DEMO_MODE="quick"
                PAUSE_ENABLED=false
                shift
                ;;
            --demo)
                DEMO_MODE="single"
                SINGLE_DEMO="${2:-1}"
                shift 2
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                print_error "Opțiune necunoscută: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

run_single_demo() {
    local demo_num="$1"
    
    case "$demo_num" in
        1) demo_basic_backup ;;
        2) demo_compression_comparison ;;
        3) demo_incremental_backup ;;
        4) demo_exclusion_patterns ;;
        5) demo_integrity_verification ;;
        6) demo_restore_process ;;
        7) demo_rotation_policies ;;
        8) demo_automation_cron ;;
        *)
            print_error "Demonstrație invalidă: $demo_num (1-8)"
            exit 1
            ;;
    esac
}

main() {
    parse_args "$@"
    
    # Verificare dependențe
    for cmd in tar gzip; do
        if ! command -v "$cmd" &>/dev/null; then
            print_error "Comandă lipsă: $cmd"
            exit 1
        fi
    done
    
    print_banner
    
    # Trap pentru cleanup
    trap cleanup_demo EXIT
    
    setup_demo_environment
    
    if [[ "$DEMO_MODE" == "single" ]]; then
        run_single_demo "$SINGLE_DEMO"
    elif [[ "$DEMO_MODE" == "quick" ]]; then
        demo_basic_backup
        demo_compression_comparison
        demo_restore_process
    else
        # Toate demonstrațiile
        demo_basic_backup
        demo_compression_comparison
        demo_incremental_backup
        demo_exclusion_patterns
        demo_integrity_verification
        demo_restore_process
        demo_rotation_policies
        demo_automation_cron
    fi
    
    show_summary
    
    echo ""
    print_success "Demonstrație completă!"
    echo ""
}

main "$@"
