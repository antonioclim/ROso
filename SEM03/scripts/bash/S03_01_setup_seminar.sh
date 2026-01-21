#!/bin/bash
#
# S03_01_setup_seminar.sh - Setup pentru Seminarul 5-6 SO
# Sisteme de Operare | ASE București - CSIE
#
#
# DESCRIERE:
#   Pregătește mediul pentru exercițiile din Seminar 5-6:
#   - Verifică dependențe (find, xargs, locate, cron)
#   - Creează structura de directoare pentru exerciții
#   - Generează fișiere de test cu diverse permisiuni și dimensiuni
#   - Configurează sandbox pentru exerciții permisiuni
#
# UTILIZARE:
#   ./S03_01_setup_seminar.sh [-h] [-v] [-c] [-d DIR]
#
# OPȚIUNI:
#   -h          Afișează acest help
#   -v          Mod verbose
#   -c          Curăță setup-ul anterior înainte de instalare
#   -d DIR      Directorul de bază (default: ~/sem5-6_lab)
#
# AUTOR: Echipa SO ASE
# VERSIUNE: 1.0
#

set -e  # Exit on error

# Culori pentru output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Configurări default
BASE_DIR="${HOME}/sem5-6_lab"
VERBOSE=false
CLEANUP=false

#
# FUNCȚII UTILITARE
#

print_header() {
    echo -e "\n${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}$1${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}\n"
}

print_step() {
    echo -e "${BLUE}▶${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    if [ "$VERBOSE" = true ]; then
        echo -e "${CYAN}ℹ${NC} $1"
    fi
}

usage() {
    cat << EOF
${BOLD}UTILIZARE:${NC}
    $0 [-h] [-v] [-c] [-d DIR]

${BOLD}OPȚIUNI:${NC}
    -h          Afișează acest help
    -v          Mod verbose
    -c          Curăță setup-ul anterior înainte de instalare
    -d DIR      Directorul de bază (default: ~/sem5-6_lab)

${BOLD}EXEMPLE:${NC}
    $0                    # Setup standard
    $0 -v                 # Setup cu output detaliat
    $0 -c -d ~/mylab      # Curăță și instalează în ~/mylab

${BOLD}STRUCTURA CREATĂ:${NC}
    ~/sem5-6_lab/
    ├── find_exercises/      # Exerciții find și xargs
    ├── script_exercises/    # Exerciții parametri și getopts
    ├── permission_lab/      # Exerciții permisiuni (sandbox)
    ├── cron_exercises/      # Exerciții cron
    └── integration/         # Exerciții integrate

EOF
}

#
# VERIFICARE DEPENDENȚE
#

check_dependencies() {
    print_header "🔍 VERIFICARE DEPENDENȚE"
    
    local missing=0
    local commands=("find" "xargs" "locate" "chmod" "chown" "crontab" "at" "bc" "file")
    
    for cmd in "${commands[@]}"; do
        if command -v "$cmd" &> /dev/null; then
            print_success "$cmd - instalat ($(command -v "$cmd"))"
        else
            print_error "$cmd - LIPSEȘTE!"
            missing=$((missing + 1))
        fi
    done
    
    echo ""
    
    # Verifică serviciul cron
    print_step "Verificare serviciu cron..."
    if systemctl is-active --quiet cron 2>/dev/null || \
       systemctl is-active --quiet crond 2>/dev/null || \
       pgrep -x cron > /dev/null 2>&1; then
        print_success "Serviciul cron rulează"
    else
        print_warning "Serviciul cron nu pare să ruleze (exercițiile cron pot să nu funcționeze)"
    fi
    
    # Verifică baza de date locate
    print_step "Verificare bază de date locate..."
    if [ -f /var/lib/mlocate/mlocate.db ] || [ -f /var/lib/plocate/plocate.db ]; then
        print_success "Baza de date locate există"
        print_info "Ultima actualizare: $(stat -c '%y' /var/lib/mlocate/mlocate.db 2>/dev/null || stat -c '%y' /var/lib/plocate/plocate.db 2>/dev/null | cut -d'.' -f1)"
    else
        print_warning "Baza de date locate nu există sau e outdated"
        print_info "Rulează 'sudo updatedb' pentru a actualiza"
    fi
    
    echo ""
    
    if [ $missing -gt 0 ]; then
        print_error "Lipsesc $missing dependențe! Instalează-le înainte de a continua."
        echo -e "\nPentru Ubuntu/Debian:"
        echo "  sudo apt update && sudo apt install findutils mlocate cron at bc file"
        return 1
    fi
    
    print_success "Toate dependențele sunt prezente!"
    return 0
}

#
# CURĂȚARE SETUP ANTERIOR
#

cleanup_previous() {
    if [ -d "$BASE_DIR" ]; then
        print_header "🧹 CURĂȚARE SETUP ANTERIOR"
        print_warning "Directorul $BASE_DIR există deja"
        
        echo -n "Dorești să-l ștergi? [y/N] "
        read -r response
        
        if [[ "$response" =~ ^[Yy]$ ]]; then
            print_step "Ștergere $BASE_DIR..."
            rm -rf "$BASE_DIR"
            print_success "Director șters"
        else
            print_error "Anulat de utilizator"
            exit 1
        fi
    fi
}

#
# CREARE STRUCTURĂ DIRECTOARE
#

create_directory_structure() {
    print_header "📁 CREARE STRUCTURĂ DIRECTOARE"
    
    local dirs=(
        "$BASE_DIR"
        "$BASE_DIR/find_exercises"
        "$BASE_DIR/find_exercises/project"
        "$BASE_DIR/find_exercises/project/src"
        "$BASE_DIR/find_exercises/project/include"
        "$BASE_DIR/find_exercises/project/docs"
        "$BASE_DIR/find_exercises/project/tests"
        "$BASE_DIR/find_exercises/project/build"
        "$BASE_DIR/find_exercises/logs"
        "$BASE_DIR/find_exercises/backups"
        "$BASE_DIR/find_exercises/temp"
        "$BASE_DIR/find_exercises/data"
        "$BASE_DIR/script_exercises"
        "$BASE_DIR/script_exercises/input"
        "$BASE_DIR/script_exercises/output"
        "$BASE_DIR/permission_lab"
        "$BASE_DIR/permission_lab/public"
        "$BASE_DIR/permission_lab/private"
        "$BASE_DIR/permission_lab/shared"
        "$BASE_DIR/permission_lab/scripts"
        "$BASE_DIR/permission_lab/config"
        "$BASE_DIR/cron_exercises"
        "$BASE_DIR/cron_exercises/scripts"
        "$BASE_DIR/cron_exercises/logs"
        "$BASE_DIR/cron_exercises/output"
        "$BASE_DIR/integration"
    )
    
    for dir in "${dirs[@]}"; do
        mkdir -p "$dir"
        print_info "Creat: $dir"
    done
    
    print_success "Structură directoare creată (${#dirs[@]} directoare)"
}

#
# CREARE FIȘIERE PENTRU EXERCIȚII FIND
#

create_find_exercises_files() {
    print_header "📄 CREARE FIȘIERE PENTRU EXERCIȚII FIND"
    
    local find_dir="$BASE_DIR/find_exercises"
    
    # Fișiere sursă C
    print_step "Creare fișiere sursă..."
    for name in main utils config parser network database; do
        echo "// $name.c - Source file" > "$find_dir/project/src/$name.c"
        echo "// $name.h - Header file" > "$find_dir/project/include/$name.h"
    done
    
    # Fișiere Python pentru teste
    for i in {1..5}; do
        cat > "$find_dir/project/tests/test_$i.py" << 'PYEOF'
#!/usr/bin/env python3
"""Test file for exercises"""
import unittest

class TestExample(unittest.TestCase):
    def test_placeholder(self):
        self.assertTrue(True)

if __name__ == '__main__':
    unittest.main()
PYEOF
    done
    
    # Documentație
    print_step "Creare fișiere documentație..."
    echo "# README" > "$find_dir/project/docs/README.md"
    echo "API Documentation" > "$find_dir/project/docs/api.txt"
    echo "<html><body>Manual</body></html>" > "$find_dir/project/docs/manual.html"
    echo "Change Log" > "$find_dir/project/docs/CHANGELOG.md"
    
    # Fișiere log cu date diferite
    print_step "Creare fișiere log..."
    for i in {1..10}; do
        log_file="$find_dir/logs/app_$i.log"
        echo "Log entry $i - $(date)" > "$log_file"
        # Modifică timestamp-ul pentru a simula fișiere vechi
        if [ $i -le 3 ]; then
            touch -d "$i days ago" "$log_file"
        elif [ $i -le 6 ]; then
            touch -d "$((i * 7)) days ago" "$log_file"
        else
            touch -d "$((i * 30)) days ago" "$log_file"
        fi
    done
    
    # Fișiere cu dimensiuni diferite
    print_step "Creare fișiere cu dimensiuni diferite..."
    dd if=/dev/zero of="$find_dir/data/small.bin" bs=1K count=10 2>/dev/null
    dd if=/dev/zero of="$find_dir/data/medium.bin" bs=1M count=1 2>/dev/null
    dd if=/dev/zero of="$find_dir/data/large.bin" bs=1M count=5 2>/dev/null
    
    # Fișiere cu spații în nume (pentru xargs exercises)
    print_step "Creare fișiere cu spații în nume..."
    echo "Content 1" > "$find_dir/data/my document.txt"
    echo "Content 2" > "$find_dir/data/file with spaces.txt"
    echo "Content 3" > "$find_dir/data/another file here.txt"
    
    # Fișiere backup
    print_step "Creare fișiere backup..."
    for ext in bak old backup "~"; do
        echo "Backup content" > "$find_dir/backups/config.$ext"
    done
    
    # Fișiere temporare
    print_step "Creare fișiere temporare..."
    for ext in tmp temp swp; do
        echo "Temp content" > "$find_dir/temp/file.$ext"
    done
    touch "$find_dir/temp/.hidden_temp"
    
    # Fișiere goale
    touch "$find_dir/data/empty1.txt"
    touch "$find_dir/data/empty2.dat"
    
    # Link simbolic
    ln -sf "$find_dir/project/src/main.c" "$find_dir/project/main_link.c"
    
    # Numără fișierele create
    local file_count
    file_count=$(find "$find_dir" -type f | wc -l)
    print_success "Create $file_count fișiere pentru exerciții find"
}

#
# CREARE FIȘIERE PENTRU EXERCIȚII SCRIPTURI
#

create_script_exercises_files() {
    print_header "📜 CREARE FIȘIERE PENTRU EXERCIȚII SCRIPTURI"
    
    local script_dir="$BASE_DIR/script_exercises"
    
    # Fișiere de input pentru procesare
    print_step "Creare fișiere input..."
    for i in {1..5}; do
        cat > "$script_dir/input/data_$i.txt" << EOF
Line 1 of file $i
Line 2 of file $i
Line 3 of file $i
Special chars: <>&"'
Numbers: 123 456 789
EOF
    done
    
    # Script template pentru modificare
    print_step "Creare template-uri script..."
    cat > "$script_dir/template_basic.sh" << 'SHEOF'
#!/bin/bash
# Template: Script de bază cu argumente
# TODO: Completează acest script

# Verificare număr argumente
if [ $# -lt 1 ]; then
    echo "Utilizare: $0 <argument>"
    exit 1
fi

# Procesare argument
echo "Argument primit: $1"

# TODO: Adaugă logica ta aici
SHEOF
    
    cat > "$script_dir/template_getopts.sh" << 'SHEOF'
#!/bin/bash
# Template: Script cu getopts
# TODO: Completează parsarea opțiunilor

usage() {
    echo "Utilizare: $0 [-h] [-v] [-o FILE] <args>"
    echo "  -h        Afișează acest help"
    echo "  -v        Mod verbose"
    echo "  -o FILE   Fișier output"
}

verbose=false
output=""

# TODO: Completează while getopts
while getopts ":hvo:" opt; do
    case $opt in
        h) usage; exit 0 ;;
        v) verbose=true ;;
        o) output="$OPTARG" ;;
        \?) echo "Opțiune invalidă: -$OPTARG"; exit 1 ;;
        :) echo "Opțiunea -$OPTARG necesită argument"; exit 1 ;;
    esac
done
shift $((OPTIND - 1))

# Restul scriptului
echo "Verbose: $verbose"
echo "Output: ${output:-"(nespecificat)"}"
echo "Argumente rămase: $@"
SHEOF
    
    chmod +x "$script_dir"/*.sh 2>/dev/null || true
    
    # Fișier CSV pentru procesare
    cat > "$script_dir/input/users.csv" << 'EOF'
id,name,email,department
1,Ion Popescu,ion@example.com,IT
2,Maria Ionescu,maria@example.com,HR
3,Andrei Georgescu,andrei@example.com,IT
4,Elena Dumitrescu,elena@example.com,Finance
5,Mihai Constantinescu,mihai@example.com,IT
EOF
    
    print_success "Fișiere pentru exerciții scripturi create"
}

#
# CREARE SANDBOX PERMISIUNI
#

create_permission_sandbox() {
    print_header "🔐 CREARE SANDBOX PERMISIUNI"
    
    local perm_dir="$BASE_DIR/permission_lab"
    
    print_step "Creare fișiere cu permisiuni diverse..."
    
    # Fișiere publice (644)
    for name in readme.txt info.md public_data.txt; do
        echo "Public content" > "$perm_dir/public/$name"
        chmod 644 "$perm_dir/public/$name"
    done
    
    # Fișiere private (600)
    for name in secret.txt credentials.conf private_key.pem; do
        echo "Private content - DO NOT SHARE" > "$perm_dir/private/$name"
        chmod 600 "$perm_dir/private/$name"
    done
    
    # Scripturi (755)
    for name in run.sh deploy.sh backup.sh; do
        cat > "$perm_dir/scripts/$name" << SHEOF
#!/bin/bash
echo "Running $name..."
SHEOF
        chmod 755 "$perm_dir/scripts/$name"
    done
    
    # Fișiere config (640)
    for name in app.conf database.ini settings.yaml; do
        echo "# Configuration file" > "$perm_dir/config/$name"
        chmod 640 "$perm_dir/config/$name"
    done
    
    # Fișiere pentru exerciții - permisiuni GREȘITE (pentru a fi corectate)
    print_step "Creare fișiere cu permisiuni greșite (pentru exerciții)..."
    
    mkdir -p "$perm_dir/fix_me"
    
    # Script fără execute
    echo '#!/bin/bash' > "$perm_dir/fix_me/script_no_exec.sh"
    echo 'echo "Hello"' >> "$perm_dir/fix_me/script_no_exec.sh"
    chmod 644 "$perm_dir/fix_me/script_no_exec.sh"
    
    # Fișier secret world-readable
    echo "Password: secret123" > "$perm_dir/fix_me/too_open_secret.txt"
    chmod 644 "$perm_dir/fix_me/too_open_secret.txt"
    
    # Director fără execute (nu poate fi accesat)
    mkdir -p "$perm_dir/fix_me/locked_dir"
    echo "Content" > "$perm_dir/fix_me/locked_dir/file.txt"
    chmod 600 "$perm_dir/fix_me/locked_dir"
    
    # Setări pentru director partajat (SGID exercise)
    print_step "Configurare director partajat (demonstrație SGID)..."
    chmod 770 "$perm_dir/shared"
    
    print_success "Sandbox permisiuni creat"
    
    # Afișare rezumat
    echo ""
    print_info "Rezumat permisiuni:"
    echo "  public/   - 644 (rw-r--r--) - fișiere citibile de toți"
    echo "  private/  - 600 (rw-------) - fișiere doar pentru owner"
    echo "  scripts/  - 755 (rwxr-xr-x) - scripturi executabile"
    echo "  config/   - 640 (rw-r-----) - config citibil de grup"
    echo "  fix_me/   - diverse greșeli de corectat"
}

#
# CREARE FIȘIERE PENTRU EXERCIȚII CRON
#

create_cron_exercises_files() {
    print_header "⏰ CREARE FIȘIERE PENTRU EXERCIȚII CRON"
    
    local cron_dir="$BASE_DIR/cron_exercises"
    
    # Script de test pentru cron
    print_step "Creare scripturi pentru cron..."
    
    cat > "$cron_dir/scripts/test_cron.sh" << 'SHEOF'
#!/bin/bash
# Script de test pentru cron
# Scrie timestamp-ul în log

LOG_FILE="${HOME}/sem5-6_lab/cron_exercises/logs/test_cron.log"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Cron job executed" >> "$LOG_FILE"
SHEOF
    chmod 755 "$cron_dir/scripts/test_cron.sh"
    
    # Script de backup demonstrativ
    cat > "$cron_dir/scripts/backup_demo.sh" << 'SHEOF'
#!/bin/bash
# Demo: Script de backup pentru cron
# Capcană: Acest script este doar pentru demonstrație!

set -e

# Configurări
BACKUP_DIR="${HOME}/sem5-6_lab/cron_exercises/output"
LOG_FILE="${HOME}/sem5-6_lab/cron_exercises/logs/backup.log"
SOURCE_DIR="${HOME}/sem5-6_lab/find_exercises/project"

# Funcție de logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Lock file pentru a preveni execuții simultane
LOCK_FILE="/tmp/backup_demo.lock"
exec 200>"$LOCK_FILE"
if ! flock -n 200; then
    log "ERROR: O altă instanță rulează deja"
    exit 1
fi

log "START: Backup inițiat"

# Creează backup
BACKUP_NAME="backup_$(date '+%Y%m%d_%H%M%S').tar.gz"
if tar -czf "$BACKUP_DIR/$BACKUP_NAME" -C "$(dirname "$SOURCE_DIR")" "$(basename "$SOURCE_DIR")" 2>/dev/null; then
    log "SUCCESS: Backup creat - $BACKUP_NAME"
else
    log "ERROR: Backup eșuat"
    exit 1
fi

# Curățare backup-uri vechi (păstrează ultimele 5)
cd "$BACKUP_DIR"
ls -t backup_*.tar.gz 2>/dev/null | tail -n +6 | xargs -r rm -f

log "END: Backup finalizat"
SHEOF
    chmod 755 "$cron_dir/scripts/backup_demo.sh"
    
    # Script de monitorizare
    cat > "$cron_dir/scripts/monitor_demo.sh" << 'SHEOF'
#!/bin/bash
# Demo: Script de monitorizare sistem

LOG_FILE="${HOME}/sem5-6_lab/cron_exercises/logs/monitor.log"

{
    echo "=== System Monitor Report ==="
    echo "Timestamp: $(date)"
    echo ""
    echo "--- Disk Usage ---"
    df -h / | tail -1
    echo ""
    echo "--- Memory Usage ---"
    free -h | head -2
    echo ""
    echo "--- Load Average ---"
    uptime
    echo ""
} >> "$LOG_FILE"
SHEOF
    chmod 755 "$cron_dir/scripts/monitor_demo.sh"
    
    # Template crontab
    cat > "$cron_dir/crontab_template.txt" << 'EOF'
# 
# Template Crontab pentru exerciții
# 
# 
# Format: MIN HOUR DOM MON DOW COMMAND
#
# Câmpuri:
#   MIN   - Minute (0-59)
#   HOUR  - Ora (0-23)
#   DOM   - Ziua lunii (1-31)
#   MON   - Luna (1-12)
#   DOW   - Ziua săptămânii (0-7, 0 și 7 = Duminică)
#
# Caractere speciale:
#   *     - Orice valoare
#   */N   - La fiecare N unități
#   N-M   - Range de la N la M
#   N,M   - Lista: N și M
#
# 

# Setări de mediu (IMPORTANT pentru cron!)
SHELL=/bin/bash
PATH=/usr/local/bin:/usr/bin:/bin
MAILTO=""

# 
# EXEMPLE (decomentează pentru a activa):
# 

# Test simplu - la fiecare minut
# * * * * * echo "Test $(date)" >> /tmp/cron_test.log

# Backup zilnic la 3 AM
# 0 3 * * * /path/to/backup.sh >> /var/log/backup.log 2>&1

# Monitorizare la fiecare 15 minute, 9-17, Luni-Vineri
# */15 9-17 * * 1-5 /path/to/monitor.sh

# Curățare logs săptămânal (Duminică la miezul nopții)
# 0 0 * * 0 find /var/log -name "*.log" -mtime +30 -delete

# La repornirea sistemului
# @reboot /path/to/startup.sh

# 
# EXERCIȚII - Completează expresiile cron:
# 

# 1. La fiecare oră, la minutul 30:
# __ __ * * * echo "Hourly at :30"

# 2. Zilnic la 6:00 AM:
# __ __ * * * echo "Daily at 6 AM"

# 3. În fiecare Luni la 9:00 AM:
# __ __ * * __ echo "Every Monday"

# 4. Pe 1 și 15 ale lunii, la 12:00:
# __ __ ____ * * echo "Twice a month"

# 5. La fiecare 5 minute:
# ____ * * * * echo "Every 5 minutes"

EOF
    
    # Inițializare fișiere log
    touch "$cron_dir/logs/test_cron.log"
    touch "$cron_dir/logs/backup.log"
    touch "$cron_dir/logs/monitor.log"
    
    print_success "Fișiere pentru exerciții cron create"
}

#
# CREARE FIȘIERE PENTRU EXERCIȚII INTEGRATE
#

create_integration_files() {
    print_header "🔗 CREARE FIȘIERE PENTRU EXERCIȚII INTEGRATE"
    
    local int_dir="$BASE_DIR/integration"
    
    # Scenariu: proiect web
    print_step "Creare structură proiect web demonstrativ..."
    
    mkdir -p "$int_dir/webproject"/{public,src,config,logs,backup}
    
    # Fișiere publice web
    echo "<html><body>Welcome</body></html>" > "$int_dir/webproject/public/index.html"
    echo "body { margin: 0; }" > "$int_dir/webproject/public/style.css"
    echo "console.log('loaded');" > "$int_dir/webproject/public/app.js"
    
    # Fișiere sursă
    cat > "$int_dir/webproject/src/server.py" << 'EOF'
#!/usr/bin/env python3
"""Simple web server for demonstration"""
from http.server import HTTPServer, SimpleHTTPRequestHandler

if __name__ == '__main__':
    server = HTTPServer(('localhost', 8000), SimpleHTTPRequestHandler)
    print("Server running on http://localhost:8000")
    server.serve_forever()
EOF
    
    # Configurări (cu date sensibile simulate)
    cat > "$int_dir/webproject/config/database.conf" << 'EOF'
# Database configuration
# Capcană: Acest fișier conține date sensibile!
DB_HOST=localhost
DB_PORT=5432
DB_NAME=myapp
DB_USER=admin
DB_PASS=secret123
EOF
    
    cat > "$int_dir/webproject/config/app.conf" << 'EOF'
# Application settings
DEBUG=false
LOG_LEVEL=INFO
SECRET_KEY=super_secret_key_here
EOF
    
    # Log files
    for i in {1..3}; do
        echo "[$(date -d "$i days ago")] Application started" > "$int_dir/webproject/logs/app_day$i.log"
        touch -d "$i days ago" "$int_dir/webproject/logs/app_day$i.log"
    done
    
    # Setare permisiuni corecte pentru exercițiul de audit
    chmod 644 "$int_dir/webproject/public"/*
    chmod 600 "$int_dir/webproject/config"/*
    chmod 755 "$int_dir/webproject/src/server.py"
    
    # README pentru exercițiu
    cat > "$int_dir/README_INTEGRATION.md" << 'EOF'
# Exercițiu Integrat: Administrare Proiect Web

## Scenariu
Ai preluat administrarea unui proiect web. Trebuie să:

1. **Audit permisiuni** - Verifică și corectează permisiunile
2. **Curățare** - Găsește și arhivează log-urile vechi
3. **Automatizare** - Creează cron job pentru backup
4. **Script profesional** - Scrie un script de mentenanță cu opțiuni

## Cerințe

### Partea 1: find
- Găsește toate fișierele de configurare
- Găsește fișierele mai mari de 1KB
- Găsește fișierele modificate în ultima zi

### Partea 2: Permisiuni
- Verifică dacă config/*.conf are permisiuni 600
- Verifică dacă src/*.py este executabil
- Identifică fișiere cu permisiuni prea deschise

### Partea 3: Script
- Creează `maintain.sh` cu opțiunile:
  - `-c` pentru cleanup logs
  - `-b` pentru backup
  - `-a` pentru audit permisiuni
  - `-v` pentru verbose
  - `-h` pentru help

### Partea 4: Cron
- Configurează backup zilnic la 2 AM
- Configurează cleanup săptămânal

EOF
    
    print_success "Fișiere pentru exerciții integrate create"
}

#
# AFIȘARE REZUMAT
#

show_summary() {
    print_header "📊 REZUMAT SETUP"
    
    echo -e "${BOLD}Directorul de bază:${NC} $BASE_DIR"
    echo ""
    
    echo -e "${BOLD}Structura creată:${NC}"
    if command -v tree &> /dev/null; then
        tree -L 2 "$BASE_DIR"
    else
        find "$BASE_DIR" -maxdepth 2 -type d | sed 's/[^-][^\/]*\//  |/g' | sed 's/|  /├── /g'
    fi
    
    echo ""
    echo -e "${BOLD}Statistici:${NC}"
    echo "  Directoare: $(find "$BASE_DIR" -type d | wc -l)"
    echo "  Fișiere:    $(find "$BASE_DIR" -type f | wc -l)"
    echo "  Dimensiune: $(du -sh "$BASE_DIR" | cut -f1)"
    
    echo ""
    print_success "Setup complet!"
    
    echo ""
    echo -e "${BOLD}Următorii pași:${NC}"
    echo "  1. cd $BASE_DIR"
    echo "  2. Explorează structura cu 'ls -la' și 'find'"
    echo "  3. Începe exercițiile din ghidul instructorului"
    echo ""
    echo -e "${YELLOW}⚠️  Capcană:${NC}"
    echo "  - Exercițiile de permisiuni se fac în permission_lab/"
    echo "  - NU folosi sudo decât dacă e explicit cerut"
    echo "  - Testează comenzile periculoase (rm, chmod) cu echo înainte"
}

#
# MAIN
#

main() {
    # Parse argumente
    while getopts ":hvcd:" opt; do
        case $opt in
            h) usage; exit 0 ;;
            v) VERBOSE=true ;;
            c) CLEANUP=true ;;
            d) BASE_DIR="$OPTARG" ;;
            \?) print_error "Opțiune invalidă: -$OPTARG"; usage; exit 1 ;;
            :) print_error "Opțiunea -$OPTARG necesită argument"; exit 1 ;;
        esac
    done
    
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}     ${BOLD}SETUP SEMINAR 5-6: Sisteme de Operare${NC}                   ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}     ASE București - CSIE                                     ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    
    # Cleanup dacă cerut
    if [ "$CLEANUP" = true ]; then
        cleanup_previous
    fi
    
    # Verificare dacă directorul există deja
    if [ -d "$BASE_DIR" ] && [ "$CLEANUP" = false ]; then
        print_warning "Directorul $BASE_DIR există deja!"
        echo "  Folosește -c pentru a curăța și reinstala"
        echo "  Sau specifică alt director cu -d DIR"
        exit 1
    fi
    
    # Verificare dependențe
    if ! check_dependencies; then
        exit 1
    fi
    
    # Creare setup
    create_directory_structure
    create_find_exercises_files
    create_script_exercises_files
    create_permission_sandbox
    create_cron_exercises_files
    create_integration_files
    
    # Afișare rezumat
    show_summary
}

# Rulare
main "$@"
