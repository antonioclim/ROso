#!/bin/bash
#
# S03_05_demo_cron.sh - Demonstrație Cron și Automatizare
#
# Sisteme de Operare | ASE București - CSIE | Seminar 5-6
#
# DESCRIERE:
#   Script interactiv pentru demonstrarea conceptelor cron:
#   - Formatul crontab (cele 5 câmpuri)
#   - Caractere speciale (*, /, -, ,)
#   - String-uri speciale (@reboot, @daily, etc.)
#   - Gestionare crontab (crontab -e/-l/-r)
#   - Mediul de execuție și PATH
#   - Logging și debugging
#   - Best practices și lock files
#   - Comanda at pentru task-uri one-time
#
# UTILIZARE:
#   ./S03_05_demo_cron.sh              # Mod interactiv complet
#   ./S03_05_demo_cron.sh -s NUM       # Secțiune specifică (1-8)
#   ./S03_05_demo_cron.sh -i           # Mod interactiv cu pauze
#   ./S03_05_demo_cron.sh --generator  # Tool: generator expresii cron
#   ./S03_05_demo_cron.sh --validator  # Tool: validator/explicator expresii
#   ./S03_05_demo_cron.sh --monitor    # Tool: monitor cron jobs live
#   ./S03_05_demo_cron.sh -c           # Cleanup demo environment
#
# AUTOR: Echipa SO | VERSIUNE: 1.0 | DATA: 2025
#

set -e

#
# CONFIGURARE CULORI ȘI VARIABILE GLOBALE
#

# Culori
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# Culori pentru niveluri de importanță
INFO="${CYAN}"
SUCCESS="${GREEN}"
WARNING="${YELLOW}"
DANGER="${RED}"
CONCEPT="${MAGENTA}"
CODE="${WHITE}"

# Directoare și fișiere
DEMO_DIR="$HOME/cron_demo_lab"
LOG_DIR="$DEMO_DIR/logs"
SCRIPTS_DIR="$DEMO_DIR/scripts"
BACKUP_DIR="$DEMO_DIR/backups"
LOCK_DIR="$DEMO_DIR/locks"

# Mod interactiv
INTERACTIVE=false

# Număr secțiune pentru rulare specifică
SECTION_NUM=0

#
# FUNCȚII UTILITARE DE AFIȘARE
#

print_header() {
    local title="$1"
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${RESET}"
    printf "${CYAN}║${RESET} ${BOLD}${WHITE}%-76s${RESET} ${CYAN}║${RESET}\n" "$title"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${RESET}"
    echo ""
}

print_subheader() {
    local title="$1"
    echo ""
    echo -e "${YELLOW}┌──────────────────────────────────────────────────────────────────────────────┐${RESET}"
    printf "${YELLOW}│${RESET} ${BOLD}%-76s${RESET} ${YELLOW}│${RESET}\n" "$title"
    echo -e "${YELLOW}└──────────────────────────────────────────────────────────────────────────────┘${RESET}"
    echo ""
}

print_concept() {
    local concept="$1"
    echo -e "${CONCEPT}💡 CONCEPT: ${concept}${RESET}"
}

print_warning() {
    local msg="$1"
    echo -e "${WARNING}⚠️  Capcană: ${msg}${RESET}"
}

print_danger() {
    local msg="$1"
    echo -e "${DANGER}☠️  PERICOL: ${msg}${RESET}"
}

print_tip() {
    local tip="$1"
    echo -e "${GREEN}💡 TIP: ${tip}${RESET}"
}

print_command() {
    local cmd="$1"
    echo -e "${GRAY}┌─────────────────────────────────────────────────────────────────────────────┐${RESET}"
    echo -e "${GRAY}│${RESET} ${GREEN}\$${RESET} ${CODE}${cmd}${RESET}"
    echo -e "${GRAY}└─────────────────────────────────────────────────────────────────────────────┘${RESET}"
}

print_output() {
    echo -e "${DIM}$1${RESET}"
}

print_box() {
    local content="$1"
    local width=76
    echo -e "${BLUE}┌$(printf '─%.0s' $(seq 1 $width))┐${RESET}"
    while IFS= read -r line; do
        printf "${BLUE}│${RESET} %-74s ${BLUE}│${RESET}\n" "$line"
    done <<< "$content"
    echo -e "${BLUE}└$(printf '─%.0s' $(seq 1 $width))┘${RESET}"
}

run_demo() {
    local description="$1"
    local command="$2"
    
    echo ""
    echo -e "${GRAY}# ${description}${RESET}"
    print_command "$command"
    echo -e "${DIM}Output:${RESET}"
    eval "$command" 2>&1 | head -30 || true
    echo ""
}

pause_interactive() {
    if $INTERACTIVE; then
        echo ""
        echo -e "${CYAN}[Apasă ENTER pentru a continua sau 'q' pentru a ieși...]${RESET}"
        read -r response
        if [[ "$response" == "q" ]]; then
            echo "Demo întrerupt."
            exit 0
        fi
    fi
}

ask_prediction() {
    local question="$1"
    echo ""
    echo -e "${YELLOW}🤔 PREDICȚIE: ${question}${RESET}"
    if $INTERACTIVE; then
        echo -e "${DIM}(Gândește-te înainte de a continua...)${RESET}"
        read -r -p "Răspunsul tău: " answer
    fi
    echo ""
}

#
# FUNCȚII DE SETUP ȘI CLEANUP
#

setup_demo_environment() {
    print_subheader "🔧 SETUP MEDIU DEMONSTRAȚIE"
    
    echo "Creare structură directoare pentru demo cron..."
    
    # Creează structura de directoare
    mkdir -p "$DEMO_DIR"
    mkdir -p "$LOG_DIR"
    mkdir -p "$SCRIPTS_DIR"
    mkdir -p "$BACKUP_DIR"
    mkdir -p "$LOCK_DIR"
    
    echo -e "${GREEN}✓${RESET} Directoare create în $DEMO_DIR"
    
    # Creează scripturi demonstrative
    
    # Script simplu de logging
    cat > "$SCRIPTS_DIR/simple_logger.sh" << 'SCRIPT_EOF'
#!/bin/bash
# Simple logger script pentru demo cron
LOG_FILE="$HOME/cron_demo_lab/logs/simple.log"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Script executat cu succes" >> "$LOG_FILE"
SCRIPT_EOF
    chmod +x "$SCRIPTS_DIR/simple_logger.sh"
    
    # Script cu variabile de mediu
    cat > "$SCRIPTS_DIR/env_test.sh" << 'SCRIPT_EOF'
#!/bin/bash
# Test pentru variabile de mediu în cron
LOG_FILE="$HOME/cron_demo_lab/logs/env_test.log"
{
    echo "=== $(date) ==="
    echo "PATH: $PATH"
    echo "HOME: $HOME"
    echo "USER: $USER"
    echo "SHELL: $SHELL"
    echo "PWD: $PWD"
    echo "LANG: $LANG"
    echo ""
} >> "$LOG_FILE"
SCRIPT_EOF
    chmod +x "$SCRIPTS_DIR/env_test.sh"
    
    # Script de backup cu timestamp
    cat > "$SCRIPTS_DIR/backup_demo.sh" << 'SCRIPT_EOF'
#!/bin/bash
# Demo backup script cu logging complet
set -e

BACKUP_DIR="$HOME/cron_demo_lab/backups"
LOG_FILE="$HOME/cron_demo_lab/logs/backup.log"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

log "START: Backup process inițiat"

# Simulare backup
mkdir -p "$BACKUP_DIR/backup_$TIMESTAMP"
echo "Backup data for $TIMESTAMP" > "$BACKUP_DIR/backup_$TIMESTAMP/data.txt"

log "SUCCESS: Backup completat - backup_$TIMESTAMP"
log "END: Process finalizat"
SCRIPT_EOF
    chmod +x "$SCRIPTS_DIR/backup_demo.sh"
    
    # Script cu lock file pentru prevenire execuții simultane
    cat > "$SCRIPTS_DIR/locked_task.sh" << 'SCRIPT_EOF'
#!/bin/bash
# Demo script cu lock file pentru a preveni execuții simultane
LOCK_FILE="$HOME/cron_demo_lab/locks/task.lock"
LOG_FILE="$HOME/cron_demo_lab/logs/locked_task.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Verifică și creează lock
if [ -f "$LOCK_FILE" ]; then
    PID=$(cat "$LOCK_FILE")
    if ps -p "$PID" > /dev/null 2>&1; then
        log "SKIP: Altă instanță rulează (PID: $PID)"
        exit 0
    else
        log "WARN: Lock file vechi găsit, se șterge"
        rm -f "$LOCK_FILE"
    fi
fi

# Creează lock file
echo $$ > "$LOCK_FILE"
trap "rm -f '$LOCK_FILE'" EXIT

log "START: Task inițiat (PID: $$)"

# Simulare task lung
sleep 5

log "END: Task completat"
SCRIPT_EOF
    chmod +x "$SCRIPTS_DIR/locked_task.sh"
    
    # Script cu flock pentru locking mai solid
    cat > "$SCRIPTS_DIR/flock_task.sh" << 'SCRIPT_EOF'
#!/bin/bash
# Demo script cu flock pentru locking atomic
LOCK_FILE="$HOME/cron_demo_lab/locks/flock.lock"
LOG_FILE="$HOME/cron_demo_lab/logs/flock_task.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Încearcă să obții lock-ul (non-blocking)
exec 200>"$LOCK_FILE"
if ! flock -n 200; then
    log "SKIP: Nu s-a putut obține lock-ul"
    exit 0
fi

log "START: Task cu flock inițiat (PID: $$)"

# Simulare muncă
sleep 3
echo "Work done at $(date)" >> "$HOME/cron_demo_lab/logs/flock_output.log"

log "END: Task completat"
SCRIPT_EOF
    chmod +x "$SCRIPTS_DIR/flock_task.sh"
    
    # Script pentru cleanup vechi
    cat > "$SCRIPTS_DIR/cleanup_old.sh" << 'SCRIPT_EOF'
#!/bin/bash
# Demo cleanup pentru fișiere vechi
BACKUP_DIR="$HOME/cron_demo_lab/backups"
LOG_FILE="$HOME/cron_demo_lab/logs/cleanup.log"
DAYS_OLD=7

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

log "START: Cleanup fișiere mai vechi de $DAYS_OLD zile"

count=0
while IFS= read -r -d '' file; do
    log "DELETE: $file"
    rm -rf "$file"
    ((count++)) || true
done < <(find "$BACKUP_DIR" -maxdepth 1 -type d -name "backup_*" -mtime +$DAYS_OLD -print0 2>/dev/null)

log "END: $count directoare șterse"
SCRIPT_EOF
    chmod +x "$SCRIPTS_DIR/cleanup_old.sh"
    
    # Script de notificare (simulare)
    cat > "$SCRIPTS_DIR/notify.sh" << 'SCRIPT_EOF'
#!/bin/bash
# Demo notification script
MESSAGE="${1:-Notificare cron}"
LOG_FILE="$HOME/cron_demo_lab/logs/notifications.log"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] NOTIFY: $MESSAGE" >> "$LOG_FILE"

# În realitate, aici ar fi:
# - send email: mail -s "Subject" user@domain.com
# - send slack: curl -X POST -H 'Content-type: application/json' --data '{"text":"'$MESSAGE'"}' URL
# - desktop notification: notify-send "$MESSAGE"
SCRIPT_EOF
    chmod +x "$SCRIPTS_DIR/notify.sh"
    
    # Inițializare log files
    touch "$LOG_DIR/simple.log"
    touch "$LOG_DIR/env_test.log"
    touch "$LOG_DIR/backup.log"
    touch "$LOG_DIR/locked_task.log"
    touch "$LOG_DIR/flock_task.log"
    touch "$LOG_DIR/cleanup.log"
    touch "$LOG_DIR/notifications.log"
    
    echo -e "${GREEN}✓${RESET} Scripturi demo create în $SCRIPTS_DIR"
    
    # Listare structură
    echo ""
    echo "Structura creată:"
    tree "$DEMO_DIR" 2>/dev/null || find "$DEMO_DIR" -type f | head -20
    
    echo ""
    echo -e "${SUCCESS}✅ Mediu demo pregătit!${RESET}"
}

cleanup_demo() {
    print_subheader "🧹 CLEANUP MEDIU DEMONSTRAȚIE"
    
    if [ -d "$DEMO_DIR" ]; then
        echo "Se șterge $DEMO_DIR..."
        rm -rf "$DEMO_DIR"
        echo -e "${GREEN}✓${RESET} Director demo șters"
    else
        echo "Directorul demo nu există."
    fi
    
    # Afișare crontab curent (pentru verificare)
    echo ""
    echo "Crontab curent (pentru verificare manuală):"
    crontab -l 2>/dev/null || echo "  (gol)"
    
    echo ""
    print_warning "Crontab-ul NU a fost modificat de cleanup."
    echo "  Pentru a șterge intrări din crontab, folosește: crontab -e"
    echo ""
}

#
# SECȚIUNEA 1: INTRODUCERE ÎN CRON
#

section_1_introduction() {
    print_header "SECȚIUNEA 1: INTRODUCERE ÎN CRON"
    
    print_concept "Ce este cron?"
    
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────────────────────┐
│                         🕐 CE ESTE CRON?                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  cron = "χρόνος" (chronos) = timp în greacă                                 │
│                                                                             │
│  • Daemon (serviciu de fundal) care execută comenzi programate              │
│  • Rulează continuu în background                                           │
│  • Verifică la fiecare minut dacă trebuie executat ceva                    │
│  • Disponibil pe toate sistemele Unix/Linux                                 │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│  COMPONENTE:                                                                │
│                                                                             │
│  ┌──────────────┐      ┌──────────────┐      ┌──────────────┐              │
│  │  crond       │ ───► │  crontab     │ ───► │  comenzi     │              │
│  │  (daemon)    │      │  (tabel)     │      │  executate   │              │
│  └──────────────┘      └──────────────┘      └──────────────┘              │
│                                                                             │
│  crond   = procesul care rulează în background                             │
│  crontab = tabelul cu job-uri programate                                   │
│  jobs    = comenzile/scripturile care se execută                           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    pause_interactive
    
    print_subheader "Verificare serviciu cron"
    
    run_demo "Verifică dacă serviciul cron rulează" \
        "systemctl status cron 2>/dev/null | head -5 || service cron status 2>/dev/null | head -3 || echo 'Verifică manual cu: ps aux | grep cron'"
    
    run_demo "Procesul cron în sistem" \
        "ps aux | grep -E '[c]ron' | head -5"
    
    pause_interactive
    
    print_subheader "Locații importante pentru cron"
    
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────────────────────┐
│                    📂 LOCAȚII CRON ÎN SISTEM                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  FIȘIERE DE CONFIGURARE:                                                    │
│  ├── /etc/crontab           ← Crontab sistem (necesită user specificat)    │
│  ├── /var/spool/cron/       ← Crontab-uri per utilizator                   │
│  │   └── crontabs/USER                                                      │
│  └── /etc/cron.d/           ← Crontab-uri suplimentare sistem              │
│                                                                             │
│  DIRECTOARE PREDEFINITE (drop-in):                                          │
│  ├── /etc/cron.hourly/      ← Scripturi rulate la fiecare oră              │
│  ├── /etc/cron.daily/       ← Scripturi rulate zilnic                       │
│  ├── /etc/cron.weekly/      ← Scripturi rulate săptămânal                   │
│  └── /etc/cron.monthly/     ← Scripturi rulate lunar                        │
│                                                                             │
│  LOGURI:                                                                    │
│  ├── /var/log/syslog        ← Log general (include cron)                   │
│  └── /var/log/cron.log      ← Log dedicat cron (dacă e configurat)         │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│  💡 TIP: Scripturile din cron.daily/ etc. sunt rulate de anacron           │
│         (care recuperează job-uri ratate când sistemul a fost oprit)       │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    run_demo "Conținutul /etc/crontab (crontab sistem)" \
        "cat /etc/crontab 2>/dev/null | head -20 || echo 'Fișierul poate lipsi sau necesită sudo'"
    
    run_demo "Ce scripturi sunt în cron.daily?" \
        "ls -la /etc/cron.daily/ 2>/dev/null | head -10"
    
    pause_interactive
    
    print_subheader "Diferența: crontab user vs /etc/crontab"
    
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────────────────────┐
│          CRONTAB UTILIZATOR vs CRONTAB SISTEM                               │
├──────────────────────────────────┬──────────────────────────────────────────┤
│  crontab -e (UTILIZATOR)         │  /etc/crontab (SISTEM)                   │
├──────────────────────────────────┼──────────────────────────────────────────┤
│  • Per utilizator                │  • Pentru întreg sistemul                │
│  • Gestionat cu comanda crontab  │  • Editat direct cu sudo                 │
│  • NU specifică user             │  • TREBUIE să specifice user             │
│  • Stocat în /var/spool/cron     │  • În /etc/crontab sau /etc/cron.d/      │
│                                  │                                          │
│  FORMAT (6 câmpuri):             │  FORMAT (7 câmpuri):                     │
│  min hour dom mon dow command    │  min hour dom mon dow USER command       │
│                                  │                    ^^^^                  │
│  * * * * * /path/to/script       │  * * * * * root /path/to/script          │
│                                  │                                          │
├──────────────────────────────────┴──────────────────────────────────────────┤
│  ⚠️  Capcană: În /etc/crontab trebuie specificat USER-ul!                   │
│                                                                             │
│  # GREȘIT în /etc/crontab (lipsește user):                                  │
│  0 3 * * * /root/backup.sh                                                  │
│                                                                             │
│  # CORECT în /etc/crontab:                                                  │
│  0 3 * * * root /root/backup.sh                                             │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    pause_interactive
    
    print_subheader "De ce cron? Cazuri de utilizare"
    
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────────────────────┐
│                   🎯 CAZURI DE UTILIZARE CRON                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  📦 BACKUP ȘI ARHIVARE                                                      │
│     • Backup zilnic baze de date                                            │
│     • Sincronizare fișiere cu rsync                                         │
│     • Arhivare și rotație loguri                                            │
│                                                                             │
│  🧹 MENTENANȚĂ SISTEM                                                       │
│     • Cleanup fișiere temporare                                             │
│     • Actualizare baze de date (updatedb pentru locate)                     │
│     • Verificări de securitate                                              │
│     • Rotație și compresie loguri                                           │
│                                                                             │
│  📊 RAPOARTE ȘI MONITORIZARE                                                │
│     • Generare rapoarte zilnice/săptămânale                                 │
│     • Monitorizare disk space                                               │
│     • Health checks pentru servicii                                         │
│     • Alertare când ceva e în neregulă                                      │
│                                                                             │
│  📧 COMUNICARE                                                              │
│     • Trimitere emailuri programate                                         │
│     • Notificări periodice                                                  │
│     • Sincronizare date cu API-uri externe                                  │
│                                                                             │
│  🔄 SINCRONIZARE                                                            │
│     • Pull date de la servere remote                                        │
│     • Update feeds RSS/news                                                 │
│     • Sincronizare cu cloud storage                                         │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    echo -e "${SUCCESS}✅ Secțiunea 1 completă!${RESET}"
    pause_interactive
}

#
# SECȚIUNEA 2: FORMATUL CRONTAB (CELE 5 CÂMPURI)
#

section_2_crontab_format() {
    print_header "SECȚIUNEA 2: FORMATUL CRONTAB - CELE 5 CÂMPURI"
    
    print_concept "Structura unei intrări crontab"
    
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────────────────────┐
│                     📋 FORMATUL CRONTAB                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌───────────────── minut (0 - 59)                                          │
│  │ ┌─────────────── oră (0 - 23)                                            │
│  │ │ ┌───────────── zi din lună (1 - 31)                                    │
│  │ │ │ ┌─────────── lună (1 - 12 sau jan-dec)                               │
│  │ │ │ │ ┌───────── zi din săptămână (0 - 7, 0 și 7 = Duminică)             │
│  │ │ │ │ │                                                                   │
│  │ │ │ │ │                                                                   │
│  * * * * *  comandă_de_executat                                              │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│  CÂMP        │  VALORI        │  DESCRIERE                                  │
│──────────────┼────────────────┼─────────────────────────────────────────────│
│  Minut       │  0-59          │  În ce minut să se execute                  │
│  Oră         │  0-23          │  În ce oră (format 24h)                     │
│  Zi lună     │  1-31          │  În ce zi a lunii                           │
│  Lună        │  1-12          │  În ce lună (sau jan, feb, mar...)          │
│  Zi săpt.    │  0-7           │  În ce zi din săptămână (0,7=Dum)           │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    pause_interactive
    
    print_subheader "Diagrama vizuală a câmpurilor"
    
    cat << 'EOF'

        ┌─────────────────────────────────────────────────────────────────────┐
        │                    ANATOMIA UNEI INTRĂRI CRON                       │
        ├─────────────────────────────────────────────────────────────────────┤
        │                                                                     │
        │         30    8    15    6    1    /home/user/backup.sh             │
        │          │    │     │    │    │              │                      │
        │          │    │     │    │    │              └── Comandă/Script     │
        │          │    │     │    │    │                                     │
        │          │    │     │    │    └────── Zi săptămână: 1 = Luni        │
        │          │    │     │    │                                          │
        │          │    │     │    └─────────── Lună: 6 = Iunie               │
        │          │    │     │                                               │
        │          │    │     └──────────────── Zi lună: 15                   │
        │          │    │                                                     │
        │          │    └────────────────────── Oră: 8 (8:00 AM)              │
        │          │                                                          │
        │          └─────────────────────────── Minut: 30                     │
        │                                                                     │
        │   🗓️ Se execută: Pe 15 Iunie, dacă e Luni, la 8:30 AM               │
        │                                                                     │
        └─────────────────────────────────────────────────────────────────────┘

   ⚠️  Observație: Când ambele "zi lună" ȘI "zi săptămână" sunt specificate,
             job-ul se execută când ORICARE din condiții e îndeplinită (OR)!

EOF

    pause_interactive
    
    print_subheader "Exemple de bază"
    
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────────────────────┐
│                      🕐 EXEMPLE ORARE CRON                                  │
├────────────────────────┬────────────────────────────────────────────────────┤
│  EXPRESIE              │  SEMNIFICAȚIE                                      │
├────────────────────────┼────────────────────────────────────────────────────┤
│  0 * * * *             │  La minutul 0 al fiecărei ore (XX:00)             │
│  30 8 * * *            │  Zilnic la 8:30 AM                                 │
│  0 0 * * *             │  Zilnic la miezul nopții (00:00)                   │
│  0 12 * * *            │  Zilnic la amiază (12:00)                          │
│  0 0 1 * *             │  În prima zi a fiecărei luni, la 00:00             │
│  0 0 * * 0             │  În fiecare Duminică la 00:00                      │
│  0 0 * * 1             │  În fiecare Luni la 00:00                          │
│  0 0 1 1 *             │  Pe 1 Ianuarie la 00:00 (Anul Nou!)                │
│  30 4 1,15 * *         │  Pe 1 și 15 ale lunii, la 4:30 AM                  │
│  0 9-17 * * 1-5        │  La fiecare oră, 9-17, Luni-Vineri                 │
└────────────────────────┴────────────────────────────────────────────────────┘

EOF

    pause_interactive
    
    ask_prediction "Ce înseamnă: 0 0 * * * ?"
    
    echo -e "${GREEN}Răspuns:${RESET} Zilnic la miezul nopții (00:00)"
    echo "  - Minut: 0"
    echo "  - Oră: 0"  
    echo "  - Zi lună: orice (*)"
    echo "  - Lună: orice (*)"
    echo "  - Zi săptămână: orice (*)"
    
    pause_interactive
    
    ask_prediction "Ce înseamnă: 30 4 1,15 * * ?"
    
    echo -e "${GREEN}Răspuns:${RESET} Pe 1 și 15 ale fiecărei luni, la 4:30 AM"
    echo "  - Minut: 30"
    echo "  - Oră: 4"
    echo "  - Zi lună: 1 ȘI 15 (lista cu virgulă)"
    echo "  - Lună: orice (*)"
    echo "  - Zi săptămână: orice (*)"
    
    pause_interactive
    
    print_subheader "Zilele săptămânii - atenție la convenții!"
    
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────────────────────┐
│                   📅 ZILELE SĂPTĂMÂNII                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   NUMĂR    │  ZI                │  NOTĂ                                     │
│  ──────────┼────────────────────┼────────────────────────────────────────── │
│     0      │  Duminică          │  ← Ambele 0 și 7 = Duminică               │
│     1      │  Luni              │                                           │
│     2      │  Marți             │                                           │
│     3      │  Miercuri          │                                           │
│     4      │  Joi               │                                           │
│     5      │  Vineri            │                                           │
│     6      │  Sâmbătă           │                                           │
│     7      │  Duminică          │  ← Ambele 0 și 7 = Duminică               │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ALTERNATIV: Poți folosi nume (primele 3 litere, case insensitive):        │
│                                                                             │
│   sun, mon, tue, wed, thu, fri, sat                                         │
│                                                                             │
│   EXEMPLE:                                                                  │
│   0 0 * * sun      = Duminică la miezul nopții                             │
│   0 9 * * mon-fri  = Luni-Vineri la 9:00                                   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    pause_interactive
    
    print_subheader "Lunile anului"
    
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────────────────────┐
│                      📆 LUNILE ANULUI                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   NUMĂR │ LUNĂ        │ ABREVIERE        NUMĂR │ LUNĂ        │ ABREVIERE   │
│   ──────┼─────────────┼──────────       ───────┼─────────────┼───────────  │
│      1  │ Ianuarie    │ jan                 7  │ Iulie       │ jul         │
│      2  │ Februarie   │ feb                 8  │ August      │ aug         │
│      3  │ Martie      │ mar                 9  │ Septembrie  │ sep         │
│      4  │ Aprilie     │ apr                10  │ Octombrie   │ oct         │
│      5  │ Mai         │ may                11  │ Noiembrie   │ nov         │
│      6  │ Iunie       │ jun                12  │ Decembrie   │ dec         │
│                                                                             │
│   EXEMPLE:                                                                  │
│   0 0 1 jan *     = 1 Ianuarie la 00:00                                    │
│   0 0 1 1,4,7,10  = Prima zi a fiecărui trimestru                          │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    echo -e "${SUCCESS}✅ Secțiunea 2 completă!${RESET}"
    pause_interactive
}

#
# SECȚIUNEA 3: CARACTERE SPECIALE
#

section_3_special_characters() {
    print_header "SECȚIUNEA 3: CARACTERE SPECIALE ÎN CRON"
    
    print_concept "Asterisk (*) - wildcard pentru orice valoare"
    
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────────────────────┐
│                       ✱ ASTERISK (*)                                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   * = "orice valoare posibilă în acest câmp"                                │
│                                                                             │
│   EXEMPLE:                                                                  │
│                                                                             │
│   * * * * *  cmd       = În fiecare minut                                   │
│               │                                                             │
│               └── Toate câmpurile sunt *, deci ORICE moment                 │
│                                                                             │
│   0 * * * *  cmd       = La minutul 0 al fiecărei ore                      │
│                 │                                                           │
│                 └── Ora poate fi orice (0-23)                               │
│                                                                             │
│   0 0 * * *  cmd       = Zilnic la miezul nopții                           │
│                   │                                                         │
│                   └── În orice zi din lună, orice lună, orice zi săpt.     │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    pause_interactive
    
    print_concept "Slash (/) - interval/step"
    
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────────────────────┐
│                        / SLASH (STEP/INTERVAL)                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   */N = "la fiecare N unități"                                              │
│                                                                             │
│   EXEMPLE:                                                                  │
│                                                                             │
│   */5 * * * *  cmd     = La fiecare 5 minute                               │
│     │                                                                       │
│     └── Minut: 0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55                │
│                                                                             │
│   0 */2 * * *  cmd     = La fiecare 2 ore (la minutul 0)                   │
│       │                                                                     │
│       └── Oră: 0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22                   │
│                                                                             │
│   0 0 */3 * *  cmd     = La fiecare 3 zile, la miezul nopții               │
│         │                                                                   │
│         └── Zi: 1, 4, 7, 10, 13, 16, 19, 22, 25, 28, 31                    │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ⚠️  Capcană: */5 NU înseamnă "la 5 minute DUPĂ ultima execuție"!         │
│                                                                             │
│   */5 = minute care sunt MULTIPLI de 5 (0, 5, 10, 15...)                   │
│                                                                             │
│   Dacă serverul pornește la 12:07, primul job */5 va rula la 12:10,        │
│   NU la 12:12 (7+5)!                                                        │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    pause_interactive
    
    ask_prediction "Ce face: */15 * * * * ? În ce minute se execută?"
    
    echo -e "${GREEN}Răspuns:${RESET} La fiecare 15 minute"
    echo "  Minute: 0, 15, 30, 45 ale fiecărei ore"
    echo "  → 4 execuții pe oră, 96 execuții pe zi"
    
    pause_interactive
    
    print_concept "Virgulă (,) - listă de valori"
    
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────────────────────┐
│                       , VIRGULĂ (LISTĂ)                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   val1,val2,val3 = "execută pentru oricare din valorile specificate"        │
│                                                                             │
│   EXEMPLE:                                                                  │
│                                                                             │
│   0 8,12,18 * * *  cmd    = La 8:00, 12:00 și 18:00 zilnic                 │
│       │                                                                     │
│       └── 3 ore specifice într-o listă                                      │
│                                                                             │
│   0 0 1,15 * *  cmd       = Pe 1 și 15 ale lunii                           │
│         │                                                                   │
│         └── 2 zile specifice                                                │
│                                                                             │
│   0 0 * * 1,3,5  cmd      = Luni, Miercuri, Vineri                         │
│             │                                                               │
│             └── 3 zile din săptămână                                        │
│                                                                             │
│   0 9 * 1,4,7,10 *  cmd   = Pe 1 ale lunilor Jan, Apr, Jul, Oct            │
│             │               (începutul fiecărui trimestru, presupunând      │
│             │               că zi lună = implicit prima sau alt context)   │
│             └── 4 luni specifice                                            │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    pause_interactive
    
    print_concept "Liniuță (-) - interval continuu"
    
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────────────────────┐
│                       - LINIUȚĂ (INTERVAL/RANGE)                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   start-end = "toate valorile de la start până la end (inclusiv)"           │
│                                                                             │
│   EXEMPLE:                                                                  │
│                                                                             │
│   0 9-17 * * *  cmd       = La fiecare oră între 9:00 și 17:00             │
│       │                                                                     │
│       └── Ore: 9, 10, 11, 12, 13, 14, 15, 16, 17 (9 ore)                   │
│                                                                             │
│   0 0 * * 1-5  cmd        = Luni până Vineri (zilele lucrătoare)           │
│           │                                                                 │
│           └── Zile: 1, 2, 3, 4, 5 (Luni-Vineri)                            │
│                                                                             │
│   */10 8-18 * * 1-5  cmd  = La fiecare 10 min, 8-18, Luni-Vineri           │
│     │    │       │         (ore de lucru!)                                  │
│     │    │       └── Doar în zile lucrătoare                                │
│     │    └── Doar în ore de lucru                                           │
│     └── La 10 minute interval                                               │
│                                                                             │
│   0 0 1-7 * 1  cmd        = Primul Luni al lunii                           │
│         │   │              (orice zi 1-7 care e Luni)                       │
│         │   └── Doar Luni                                                   │
│         └── Doar primele 7 zile                                             │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    pause_interactive
    
    print_subheader "Combinații de operatori"
    
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────────────────────┐
│                    🔀 COMBINAȚII COMPLEXE                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   Poți combina operatorii pentru expresii mai complexe:                     │
│                                                                             │
│   0,30 9-17 * * 1-5         = La minutul 0 și 30, ore 9-17, Luni-Vineri    │
│   │     │       │                                                           │
│   │     │       └── Interval zile (1-5)                                     │
│   │     └── Interval ore (9-17)                                             │
│   └── Listă minute (0,30)                                                   │
│                                                                             │
│   0 */4 1,15 * *            = La fiecare 4 ore, pe 1 și 15 ale lunii       │
│       │  │                                                                  │
│       │  └── Listă zile                                                     │
│       └── Step ore (0,4,8,12,16,20)                                         │
│                                                                             │
│   0-30/10 9 * * *           = La 9:00, 9:10, 9:20, 9:30                    │
│     │    │                     (step de 10 în intervalul 0-30)             │
│     └────┴── Interval cu step                                               │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ⚠️  SUBTILITATE: zi_lună ȘI zi_săptămână sunt în relație OR!             │
│                                                                             │
│   0 0 15 * 5            = Pe 15 ale lunii SAU în Vineri                    │
│         │   │                                                               │
│         │   └── Orice Vineri                                                │
│         └── Orice zi 15                                                     │
│                                                                             │
│   Asta înseamnă că se execută MULT mai des decât ai crede!                 │
│   (~4 vineri + 1 zi = ~5 execuții/lună, NU doar când 15 e Vineri)          │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    print_warning "Zi lună + zi săptămână = OR logic, nu AND!"
    
    echo ""
    echo "Dacă vrei DOAR zilele când o dată specifică cade într-o zi specifică,"
    echo "trebuie să folosești un script cu logică condițională."
    
    pause_interactive
    
    print_subheader "Tabel rezumativ operatori"
    
    cat << 'EOF'

┌───────────┬─────────────────────────────────────────────────────────────────┐
│ OPERATOR  │ DESCRIERE ȘI EXEMPLE                                            │
├───────────┼─────────────────────────────────────────────────────────────────┤
│    *      │ Orice valoare                                                   │
│           │ * * * * *  = fiecare minut                                      │
├───────────┼─────────────────────────────────────────────────────────────────┤
│    /      │ Step/Interval                                                   │
│           │ */5 = la fiecare 5 (0,5,10,15...)                               │
│           │ 10-30/5 = în intervalul 10-30, la fiecare 5 (10,15,20,25,30)   │
├───────────┼─────────────────────────────────────────────────────────────────┤
│    ,      │ Listă de valori                                                  │
│           │ 1,15,30 = valorile 1, 15 și 30                                   │
├───────────┼─────────────────────────────────────────────────────────────────┤
│    -      │ Interval continuu                                               │
│           │ 9-17 = de la 9 la 17 inclusiv                                   │
│           │ mon-fri = de luni până vineri                                   │
├───────────┼─────────────────────────────────────────────────────────────────┤
│  L,W,#    │ ⚠️  Capcană: Acestea sunt extensii VIXIE CRON sau alte         │
│           │ implementări (nu standard POSIX)!                               │
│           │ Verifică dacă cron-ul tău le suportă.                           │
└───────────┴─────────────────────────────────────────────────────────────────┘

EOF

    echo -e "${SUCCESS}✅ Secțiunea 3 completă!${RESET}"
    pause_interactive
}

#
# SECȚIUNEA 4: STRING-URI SPECIALE
#

section_4_special_strings() {
    print_header "SECȚIUNEA 4: STRING-URI SPECIALE ÎN CRON"
    
    print_concept "Scurtături predefinite pentru ore comune"
    
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────────────────────┐
│                    📌 STRING-URI SPECIALE CRON                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  În loc să scrii cele 5 câmpuri, poți folosi aceste scurtături:             │
│                                                                             │
│  ┌─────────────┬──────────────────┬───────────────────────────────────────┐ │
│  │  STRING     │  ECHIVALENT      │  DESCRIERE                            │ │
│  ├─────────────┼──────────────────┼───────────────────────────────────────┤ │
│  │  @reboot    │  (la pornire)    │  O singură dată, la boot sistem      │ │
│  │  @yearly    │  0 0 1 1 *       │  Anual, 1 Ianuarie la 00:00          │ │
│  │  @annually  │  0 0 1 1 *       │  Sinonim cu @yearly                   │ │
│  │  @monthly   │  0 0 1 * *       │  Lunar, prima zi la 00:00            │ │
│  │  @weekly    │  0 0 * * 0       │  Săptămânal, Duminică la 00:00       │ │
│  │  @daily     │  0 0 * * *       │  Zilnic la miezul nopții             │ │
│  │  @midnight  │  0 0 * * *       │  Sinonim cu @daily                    │ │
│  │  @hourly    │  0 * * * *       │  La fiecare oră, minutul 0           │ │
│  └─────────────┴──────────────────┴───────────────────────────────────────┘ │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  EXEMPLE DE UTILIZARE:                                                      │
│                                                                             │
│  @reboot /home/user/start_service.sh                                       │
│  @daily /home/user/backup.sh                                                │
│  @hourly /home/user/check_health.sh                                         │
│  @weekly /home/user/send_report.sh                                          │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    pause_interactive
    
    print_subheader "@reboot - execuție la pornirea sistemului"
    
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────────────────────┐
│                      🔄 @reboot - SPECIAL                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  @reboot este UNIC printre string-urile speciale:                          │
│                                                                             │
│  • NU este un orar periodic                                                 │
│  • Se execută O SINGURĂ DATĂ după pornirea serviciului cron                │
│  • Perfect pentru pornirea de servicii/daemoni                             │
│                                                                             │
│  CAZURI DE UTILIZARE:                                                       │
│                                                                             │
│  @reboot /home/user/start_server.sh                                        │
│     └── Pornește un server la boot                                         │
│                                                                             │
│  @reboot sleep 60 && /home/user/monitor.sh                                 │
│     └── Așteaptă 60 secunde după boot, apoi pornește                       │
│         (pentru a lăsa sistemul să se stabilizeze)                         │
│                                                                             │
│  @reboot screen -dmS myapp /home/user/myapp.sh                             │
│     └── Pornește aplicația într-o sesiune screen                           │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ⚠️  Capcană: @reboot se execută când cron pornește, NU când OS-ul        │
│              pornește. Dacă cron e restartat manual, @reboot rulează!      │
│                                                                             │
│  💡 TIP: Pentru servicii persistente, consideră systemd în loc de @reboot │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    pause_interactive
    
    print_subheader "Comparație: string-uri vs expresii echivalente"
    
    echo ""
    echo "Care variantă preferi?"
    echo ""
    
    cat << 'EOF'
  ┌───────────────────────────────────────────────────────────────────────────┐
  │  VARIANTA CU STRING:            │  VARIANTA CU EXPRESIE:                  │
  ├───────────────────────────────────────────────────────────────────────────┤
  │  @daily /path/to/backup.sh      │  0 0 * * * /path/to/backup.sh           │
  │  @hourly /path/to/check.sh      │  0 * * * * /path/to/check.sh            │
  │  @weekly /path/to/report.sh     │  0 0 * * 0 /path/to/report.sh           │
  └───────────────────────────────────────────────────────────────────────────┘
  
  PRO string-uri:
    ✓ Mai lizibile
    ✓ Mai puțin proeminente la greșeli
    ✓ Auto-documentate
  
  CONTRA string-uri:
    ✗ Mai puțin flexibile (nu poți spune @daily la 3 AM)
    ✗ Unele implementări cron nu le suportă
    ✗ Programatori experimentați preferă expresiile

EOF

    print_tip "Recomandare: folosește string-uri pentru cazuri simple, expresii pentru control fin"
    
    echo -e "${SUCCESS}✅ Secțiunea 4 completă!${RESET}"
    pause_interactive
}

#
# SECȚIUNEA 5: GESTIONAREA CRONTAB
#

section_5_crontab_management() {
    print_header "SECȚIUNEA 5: GESTIONAREA CRONTAB"
    
    print_concept "Comenzile crontab"
    
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────────────────────┐
│                    📝 COMENZI CRONTAB                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  crontab -e        Editează crontab-ul curent (deschide editor)            │
│  crontab -l        Listează (afișează) crontab-ul curent                    │
│  crontab -r        Șterge (remove) ÎNTREGUL crontab                         │
│  crontab -i        Cere confirmare înainte de -r                            │
│  crontab file      Înlocuiește crontab cu conținutul fișierului            │
│  crontab -u USER   Operează pe crontab-ul altui user (necesită root)       │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ☠️  PERICOL EXTREM: crontab -r                                             │
│                                                                             │
│  crontab -r șterge TOATE intrările, fără confirmare!                       │
│                                                                             │
│  Tastele 'e' și 'r' sunt ADIACENTE pe tastatură!                           │
│  crontab -e  vs  crontab -r   ← O greșeală costisitoare!                   │
│                                                                             │
│  💡 SOLUȚIE: Folosește alias în ~/.bashrc:                                  │
│     alias crontab='crontab -i'                                              │
│     (cere confirmare pentru -r)                                             │
│                                                                             │
│  💡 BACKUP: Înainte de modificări:                                          │
│     crontab -l > ~/crontab_backup_$(date +%Y%m%d).txt                      │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    pause_interactive
    
    print_subheader "Demonstrație: crontab -l"
    
    run_demo "Afișează crontab-ul curent" \
        "crontab -l 2>/dev/null || echo '(crontab gol sau nu există)'"
    
    pause_interactive
    
    print_subheader "Demonstrație: crontab -e (conceptual)"
    
    echo ""
    echo "Când rulezi 'crontab -e', se întâmplă următoarele:"
    echo ""
    
    cat << 'EOF'
  1. Crontab-ul curent e copiat într-un fișier temporar
  2. Se deschide editorul (determinat de $EDITOR sau $VISUAL)
  3. Editezi și salvezi fișierul
  4. La închiderea editorului, cron verifică sintaxa
  5. Dacă e validă, noul crontab e instalat
  6. Dacă e invalidă, primești eroare și opțiunea de a re-edita

EOF

    print_warning "Editorul implicit poate fi vi/vim. Pentru nano, rulează:"
    echo ""
    echo "  export EDITOR=nano"
    echo "  crontab -e"
    echo ""
    echo "Sau adaugă în ~/.bashrc pentru permanent:"
    echo "  echo 'export EDITOR=nano' >> ~/.bashrc"
    
    pause_interactive
    
    print_subheader "Demonstrație: încărcare crontab din fișier"
    
    # Creează un exemplu de fișier crontab
    cat > "$DEMO_DIR/example_crontab.txt" << 'CRON_EOF'
# Exemplu de crontab - nu instalați acest fișier!
# Format: min hour dom mon dow command

# Logging la fiecare 5 minute (DEZACTIVAT - # la început)
# */5 * * * * /home/user/scripts/logger.sh

# Backup zilnic la 3 AM
# 0 3 * * * /home/user/scripts/backup.sh >> /home/user/logs/backup.log 2>&1

# Cleanup fișiere vechi, Duminică la miezul nopții
# 0 0 * * 0 /home/user/scripts/cleanup.sh

# Health check la fiecare oră în timpul zilei
# 0 9-18 * * 1-5 /home/user/scripts/health_check.sh

# Notificare la pornirea sistemului
# @reboot /home/user/scripts/notify_boot.sh
CRON_EOF
    
    run_demo "Afișare exemplu fișier crontab" \
        "cat $DEMO_DIR/example_crontab.txt"
    
    echo ""
    print_warning "Pentru a instala un fișier crontab, folosești:"
    echo ""
    echo "  crontab /path/to/crontab_file.txt"
    echo ""
    echo "  ⚠️  Capcană: Aceasta ÎNLOCUIEȘTE crontab-ul existent!"
    echo ""
    echo "  Pentru a ADĂUGA la cel existent:"
    echo "  (crontab -l; cat new_entries.txt) | crontab -"
    
    pause_interactive
    
    print_subheader "Best practice: versionare crontab"
    
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────────────────────┐
│              💾 VERSIONARE ȘI BACKUP CRONTAB                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. BACKUP ÎNAINTE DE MODIFICARE:                                           │
│     crontab -l > ~/crontab_backup_$(date +%Y%m%d_%H%M%S).txt               │
│                                                                             │
│  2. PĂSTREAZĂ CRONTAB ÎN GIT:                                              │
│     mkdir ~/crontab-repo && cd ~/crontab-repo                              │
│     git init                                                                │
│     crontab -l > crontab.txt                                                │
│     git add crontab.txt && git commit -m "Initial crontab"                 │
│                                                                             │
│  3. SCRIPT DE SYNC (rulat periodic):                                        │
│     #!/bin/bash                                                             │
│     cd ~/crontab-repo                                                       │
│     crontab -l > crontab.txt                                                │
│     if ! git diff --quiet; then                                             │
│         git add crontab.txt                                                 │
│         git commit -m "Crontab update $(date +%Y-%m-%d)"                   │
│     fi                                                                      │
│                                                                             │
│  4. RESTAURARE DIN BACKUP:                                                  │
│     crontab ~/crontab_backup_20250115.txt                                  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    echo -e "${SUCCESS}✅ Secțiunea 5 completă!${RESET}"
    pause_interactive
}

#
# SECȚIUNEA 6: MEDIUL DE EXECUȚIE ȘI PATH
#

section_6_environment() {
    print_header "SECȚIUNEA 6: MEDIUL DE EXECUȚIE CRON"
    
    print_danger "CAUZA #1 DE JOB-URI EȘUATE: MEDIUL DE EXECUȚIE"
    
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────────────────────┐
│            ⚠️  CRON NU ARE MEDIUL TĂU DE SHELL!                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Când cron execută un job, NU încarcă:                                     │
│  • ~/.bashrc                                                                │
│  • ~/.bash_profile                                                          │
│  • ~/.profile                                                               │
│  • Variabilele de mediu din sesiunea ta                                    │
│                                                                             │
│  CONSECINȚE:                                                                │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────────┐│
│  │  SHELL INTERACTIV:              │  MEDIU CRON:                         ││
│  ├─────────────────────────────────────────────────────────────────────────┤│
│  │  PATH=/usr/local/bin:/usr/bin:  │  PATH=/usr/bin:/bin                  ││
│  │       /bin:/home/user/bin:...   │  (mult mai scurt!)                   ││
│  │                                 │                                       ││
│  │  HOME=/home/user                │  HOME=/home/user (de obicei)         ││
│  │                                 │                                       ││
│  │  LANG=en_US.UTF-8               │  LANG=(poate lipsi!)                 ││
│  │                                 │                                       ││
│  │  USER=user                      │  USER=(poate lipsi!)                 ││
│  │                                 │                                       ││
│  │  DISPLAY=:0                     │  DISPLAY=(lipsește - no GUI!)        ││
│  └─────────────────────────────────────────────────────────────────────────┘│
│                                                                             │
│  💀 SIMPTOM COMUN: "Script-ul merge din terminal dar nu din cron"          │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    pause_interactive
    
    print_subheader "Demonstrație: diferența de mediu"
    
    echo "Mediul shell-ului curent vs mediul cron:"
    echo ""
    
    run_demo "PATH în shell-ul curent" \
        "echo \$PATH | tr ':' '\n' | head -5"
    
    echo ""
    echo "PATH tipic în cron: /usr/bin:/bin"
    echo ""
    
    # Demonstrează cu scriptul nostru de test
    if [ -f "$SCRIPTS_DIR/env_test.sh" ]; then
        run_demo "Rulare script test mediu (din shell)" \
            "$SCRIPTS_DIR/env_test.sh && tail -10 $LOG_DIR/env_test.log"
    fi
    
    pause_interactive
    
    print_subheader "Soluții pentru probleme de mediu"
    
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────────────────────┐
│                    🔧 SOLUȚII PENTRU PATH ȘI MEDIU                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  SOLUȚIA 1: Folosește CĂI ABSOLUTE pentru toate comenzile                  │
│  ───────────────────────────────────────────────────────────────────────── │
│                                                                             │
│  # GREȘIT:                                                                  │
│  * * * * * python3 /home/user/script.py                                    │
│                                                                             │
│  # CORECT:                                                                  │
│  * * * * * /usr/bin/python3 /home/user/script.py                           │
│                                                                             │
│  💡 Găsește calea cu: which python3                                        │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  SOLUȚIA 2: Definește PATH în crontab                                      │
│  ───────────────────────────────────────────────────────────────────────── │
│                                                                             │
│  # La începutul crontab-ului:                                               │
│  PATH=/usr/local/bin:/usr/bin:/bin:/home/user/bin                          │
│  SHELL=/bin/bash                                                            │
│  HOME=/home/user                                                            │
│                                                                             │
│  # Apoi job-urile normale:                                                  │
│  * * * * * myscript.sh                                                     │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  SOLUȚIA 3: Încarcă profilul în script                                     │
│  ───────────────────────────────────────────────────────────────────────── │
│                                                                             │
│  #!/bin/bash                                                                │
│  source ~/.bashrc    # sau source ~/.profile                               │
│  # ... restul script-ului                                                   │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  SOLUȚIA 4: Wrapper care setează mediul                                    │
│  ───────────────────────────────────────────────────────────────────────── │
│                                                                             │
│  # În crontab:                                                              │
│  * * * * * /bin/bash -l -c '/home/user/script.sh'                          │
│                  │  │                                                       │
│                  │  └── -c = execută comanda                                │
│                  └── -l = login shell (încarcă profile)                    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    pause_interactive
    
    print_subheader "Alte variabile importante în crontab"
    
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────────────────────┐
│                VARIABILE CE POT FI SETATE ÎN CRONTAB                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  # Variabile comune de setat la începutul crontab-ului:                    │
│                                                                             │
│  SHELL=/bin/bash                    # Shell folosit (default: /bin/sh)     │
│  PATH=/usr/local/bin:/usr/bin:/bin  # Căi de căutare comenzi               │
│  MAILTO=user@example.com            # Unde trimite output-ul               │
│  MAILTO=""                          # Dezactivează email                    │
│  HOME=/home/user                    # Director home                         │
│  LANG=en_US.UTF-8                   # Locale pentru caractere              │
│                                                                             │
│  # Jobs după definirea variabilelor:                                        │
│  0 * * * * /path/to/script.sh                                              │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  💡 MAILTO: Cron trimite output prin email!                                │
│                                                                             │
│  • Dacă job-ul produce output (stdout sau stderr), cron îl trimite         │
│    la adresa din MAILTO                                                     │
│  • Pentru a dezactiva: MAILTO="" sau redirecționează: cmd > /dev/null     │
│  • Necesită MTA configurat (postfix, sendmail, etc.)                       │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    echo -e "${SUCCESS}✅ Secțiunea 6 completă!${RESET}"
    pause_interactive
}

#
# SECȚIUNEA 7: LOGGING ȘI DEBUGGING
#

section_7_logging_debugging() {
    print_header "SECȚIUNEA 7: LOGGING ȘI DEBUGGING CRON"
    
    print_concept "De ce logging este ESENȚIAL pentru cron"
    
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────────────────────┐
│                    📋 LOGGING ÎN CRON JOBS                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  PROBLEMA: Cron jobs rulează în background, fără terminal!                 │
│                                                                             │
│  • Nu vezi output-ul                                                        │
│  • Nu vezi erorile                                                          │
│  • Nu știi dacă a rulat sau nu                                             │
│  • Nu știi DE CE a eșuat                                                   │
│                                                                             │
│  SOLUȚIA: Logging explicit pentru ORICE cron job                           │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  PATTERN DE BAZĂ: Redirecționare output                                    │
│                                                                             │
│  * * * * * /path/script.sh >> /path/to/logfile.log 2>&1                   │
│                             │                    │                          │
│                             │                    └── stderr → stdout        │
│                             └── append stdout la log                        │
│                                                                             │
│  DESFĂȘURARE:                                                               │
│  ┌─────────────────────────────────────────────────────────────────────────┐│
│  │  >>         = append (adaugă la sfârșit, nu suprascrie)                ││
│  │  2>&1       = redirecționează stderr (2) la stdout (1)                 ││
│  │  2>&1       = TREBUIE să fie DUPĂ >>                                    ││
│  └─────────────────────────────────────────────────────────────────────────┘│
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    pause_interactive
    
    print_subheader "Pattern-uri de logging"
    
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────────────────────┐
│                    📝 PATTERN-URI DE LOGGING                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. LOGGING SIMPLU (doar append):                                          │
│     * * * * * /script.sh >> /var/log/script.log 2>&1                       │
│                                                                             │
│  2. LOGGING CU TIMESTAMP (în crontab):                                     │
│     * * * * * /script.sh >> /var/log/script_$(date +\%Y\%m\%d).log 2>&1   │
│                                             ↑                               │
│                                             └── % trebuie escaped cu \     │
│                                                                             │
│  3. LOGGING ÎN SCRIPT (RECOMANDAT):                                        │
│     #!/bin/bash                                                             │
│     LOG="/var/log/myapp/script.log"                                        │
│     log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG"; }         │
│                                                                             │
│     log "START: Script inițiat"                                            │
│     # ... cod ...                                                           │
│     log "END: Script finalizat cu succes"                                  │
│                                                                             │
│  4. LOGGING PROFESIONAL (cu nivele):                                       │
│     log_info()  { echo "[$(date '+%F %T')] [INFO] $*" >> "$LOG"; }        │
│     log_warn()  { echo "[$(date '+%F %T')] [WARN] $*" >> "$LOG"; }        │
│     log_error() { echo "[$(date '+%F %T')] [ERROR] $*" >> "$LOG"; }       │
│                                                                             │
│  5. LOGGING SYSLOG (pentru integrare centralizată):                        │
│     * * * * * /script.sh 2>&1 | logger -t myscript                         │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    pause_interactive
    
    # Demonstrație cu scriptul de logging
    if [ -f "$SCRIPTS_DIR/simple_logger.sh" ]; then
        run_demo "Rulare script de logging" \
            "$SCRIPTS_DIR/simple_logger.sh && cat $LOG_DIR/simple.log"
    fi
    
    pause_interactive
    
    print_subheader "Debugging cron jobs"
    
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────────────────────┐
│                    🔍 DEBUGGING CRON JOBS                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  PASUL 1: Verifică dacă cron rulează                                       │
│  ─────────────────────────────────────────────────────────────────────────  │
│  systemctl status cron                                                      │
│  ps aux | grep cron                                                         │
│                                                                             │
│  PASUL 2: Verifică logurile sistem                                         │
│  ─────────────────────────────────────────────────────────────────────────  │
│  grep CRON /var/log/syslog | tail -20                                      │
│  journalctl -u cron --since "1 hour ago"                                   │
│                                                                             │
│  PASUL 3: Testează scriptul manual                                         │
│  ─────────────────────────────────────────────────────────────────────────  │
│  # Simulează mediul cron:                                                   │
│  env -i HOME=$HOME /bin/bash -c '/path/to/script.sh'                       │
│     │                                                                       │
│     └── env -i = mediu gol (ca în cron)                                    │
│                                                                             │
│  PASUL 4: Adaugă debugging în script                                       │
│  ─────────────────────────────────────────────────────────────────────────  │
│  #!/bin/bash                                                                │
│  exec >> /tmp/debug_$$.log 2>&1  # Redirecționează TOTUL                  │
│  set -x                          # Afișează fiecare comandă                │
│  echo "PATH: $PATH"                                                         │
│  echo "PWD: $PWD"                                                           │
│  echo "USER: $USER"                                                         │
│  # ... restul script-ului                                                   │
│                                                                             │
│  PASUL 5: Test cu timing rapid                                             │
│  ─────────────────────────────────────────────────────────────────────────  │
│  # Setează job să ruleze la fiecare minut pentru test:                     │
│  * * * * * /path/to/script.sh >> /tmp/cron_test.log 2>&1                  │
│  # Apoi verifică: tail -f /tmp/cron_test.log                               │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    pause_interactive
    
    print_subheader "Verificare execuție în syslog"
    
    run_demo "Verifică execuții cron recente în syslog" \
        "grep -i cron /var/log/syslog 2>/dev/null | tail -10 || echo 'Verifică cu: journalctl -u cron'"
    
    pause_interactive
    
    print_subheader "Template script cu logging complet"
    
    cat << 'TEMPLATE_EOF'

┌─────────────────────────────────────────────────────────────────────────────┐
│              📄 TEMPLATE: Script pentru Cron cu Logging                     │
├─────────────────────────────────────────────────────────────────────────────┘

#!/bin/bash
#
# Script pentru cron job cu logging și error handling complet
#

#  CONFIGURARE 
SCRIPT_NAME=$(basename "$0")
LOG_DIR="$HOME/logs"
LOG_FILE="$LOG_DIR/${SCRIPT_NAME%.*}.log"
LOCK_FILE="/tmp/${SCRIPT_NAME%.*}.lock"

# Asigură existența directorului de loguri
mkdir -p "$LOG_DIR"

#  FUNCȚII LOGGING 
log() {
    local level="$1"; shift
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $*" >> "$LOG_FILE"
}

log_info()  { log "INFO" "$@"; }
log_warn()  { log "WARN" "$@"; }
log_error() { log "ERROR" "$@"; }

#  LOCK FILE (prevenire execuții simultane) 
if [ -f "$LOCK_FILE" ]; then
    pid=$(cat "$LOCK_FILE")
    if ps -p "$pid" > /dev/null 2>&1; then
        log_warn "Altă instanță rulează (PID: $pid). Exit."
        exit 0
    fi
fi
echo $$ > "$LOCK_FILE"
trap "rm -f '$LOCK_FILE'" EXIT

#  LOGICĂ PRINCIPALĂ 
log_info "═══ START: $SCRIPT_NAME ═══"

# Cod aici...
# ...

if [ $? -eq 0 ]; then
    log_info "Task completat cu succes"
else
    log_error "Task eșuat!"
    exit 1
fi

log_info "═══ END: $SCRIPT_NAME ═══"
log_info ""

TEMPLATE_EOF

    echo -e "${SUCCESS}✅ Secțiunea 7 completă!${RESET}"
    pause_interactive
}

#
# SECȚIUNEA 8: COMANDA AT ȘI BEST PRACTICES
#

section_8_at_and_best_practices() {
    print_header "SECȚIUNEA 8: COMANDA AT ȘI BEST PRACTICES"
    
    print_concept "at - task-uri one-time (nu periodice)"
    
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────────────────────┐
│                    ⏰ COMANDA at - TASK-URI ONE-TIME                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Cron = task-uri PERIODICE (se repetă)                                     │
│  at   = task-uri ONE-TIME (o singură execuție)                             │
│                                                                             │
│  SINTAXĂ DE BAZĂ:                                                          │
│                                                                             │
│  at TIME                          # Introdu comenzi interactiv              │
│  at TIME < script.sh              # Execută conținutul fișierului          │
│  echo "cmd" | at TIME             # Execută o comandă                       │
│  at -f script.sh TIME             # Execută scriptul                        │
│                                                                             │
│  FORMATE PENTRU TIME:                                                      │
│                                                                             │
│  at now + 5 minutes               # Peste 5 minute                          │
│  at now + 1 hour                  # Peste o oră                             │
│  at now + 2 days                  # Peste 2 zile                            │
│  at 17:00                         # La 17:00 azi (sau mâine dacă a trecut) │
│  at 17:00 tomorrow                # Mâine la 17:00                          │
│  at 9:00 AM Dec 25                # 25 Decembrie la 9:00                    │
│  at midnight                      # La miezul nopții                        │
│  at noon                          # La amiază                               │
│  at teatime                       # La 16:00 (4 PM)                         │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    pause_interactive
    
    print_subheader "Comenzi de gestionare at"
    
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────────────────────┐
│                    📋 GESTIONARE at JOBS                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  atq             Listează job-urile at în așteptare                        │
│  at -l           Sinonim cu atq                                             │
│  atrm JOB_ID     Șterge un job după ID                                     │
│  at -c JOB_ID    Afișează conținutul unui job                              │
│                                                                             │
│  EXEMPLU WORKFLOW:                                                          │
│                                                                             │
│  $ echo "echo 'Reminder!' >> /tmp/reminder.txt" | at now + 30 minutes      │
│  job 42 at Sat Jan 18 15:30:00 2025                                        │
│                                                                             │
│  $ atq                                                                      │
│  42      Sat Jan 18 15:30:00 2025 a user                                   │
│                                                                             │
│  $ atrm 42    # Anulează job-ul                                            │
│                                                                             │
│  $ atq                                                                      │
│  (gol - job-ul a fost șters)                                               │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  💡 batch - execută când sistemul e idle                                   │
│                                                                             │
│  batch < script.sh                                                          │
│                                                                             │
│  Execută când load average scade sub 1.5 (sau altă valoare configurată)   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    pause_interactive
    
    # Verifică dacă atd rulează
    run_demo "Verifică serviciul atd" \
        "systemctl status atd 2>/dev/null | head -3 || service atd status 2>/dev/null | head -3 || echo 'atd poate să nu fie instalat'"
    
    run_demo "Listează jobs at curente" \
        "atq 2>/dev/null || echo 'at nu este disponibil sau nu sunt job-uri'"
    
    pause_interactive
    
    print_subheader "BEST PRACTICES PENTRU CRON"
    
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────────────────────┐
│                    ✅ BEST PRACTICES CRON                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. FOLOSEȘTE CĂI ABSOLUTE                                                 │
│     ────────────────────────────────────────────────────────────────────── │
│     ✗ GREȘIT:  * * * * * backup.sh                                         │
│     ✓ CORECT:  * * * * * /home/user/scripts/backup.sh                      │
│                                                                             │
│  2. REDIRECȚIONEAZĂ OUTPUT                                                 │
│     ────────────────────────────────────────────────────────────────────── │
│     ✗ GREȘIT:  0 3 * * * /path/script.sh                                   │
│     ✓ CORECT:  0 3 * * * /path/script.sh >> /var/log/script.log 2>&1      │
│                                                                             │
│  3. TESTEAZĂ ÎNTÂI CU ECHO                                                 │
│     ────────────────────────────────────────────────────────────────────── │
│     # Mai întâi:                                                            │
│     0 3 * * * echo "Would delete old files" >> /tmp/test.log               │
│     # După verificare:                                                      │
│     0 3 * * * find /tmp -mtime +7 -delete                                  │
│                                                                             │
│  4. PREVINO EXECUȚII SIMULTANE (LOCK FILES)                                │
│     ────────────────────────────────────────────────────────────────────── │
│     # În script sau cu flock:                                               │
│     * * * * * flock -n /tmp/myjob.lock /path/script.sh                     │
│                                                                             │
│  5. GESTIONEAZĂ ERORILE                                                    │
│     ────────────────────────────────────────────────────────────────────── │
│     # În script: set -e (exit la prima eroare)                             │
│     # sau: cmd || log_error "cmd a eșuat"                                  │
│                                                                             │
│  6. BACKUP CRONTAB                                                         │
│     ────────────────────────────────────────────────────────────────────── │
│     crontab -l > ~/crontab_backup.txt                                      │
│                                                                             │
│  7. COMENTEAZĂ JOB-URILE                                                   │
│     ────────────────────────────────────────────────────────────────────── │
│     # Backup zilnic la 3 AM - ultimul modified: 2025-01-15                 │
│     0 3 * * * /home/user/backup.sh                                         │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    pause_interactive
    
    print_subheader "Lock files și flock"
    
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────────────────────┐
│                    🔒 PREVENIREA EXECUȚIILOR SIMULTANE                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  PROBLEMA: Dacă un cron job durează mai mult decât intervalul,             │
│            pot rula mai multe instanțe simultan!                            │
│                                                                             │
│  Exemplu: Job rulează la fiecare minut, dar durează 3 minute               │
│           → 3 instanțe simultane!                                           │
│                                                                             │
│  SOLUȚIA 1: flock (recomandat)                                             │
│  ─────────────────────────────────────────────────────────────────────────  │
│  * * * * * flock -n /tmp/myjob.lock -c '/path/to/script.sh'                │
│                 │                                                           │
│                 └── -n = non-blocking (skip dacă locked)                   │
│                                                                             │
│  SAU în script:                                                             │
│  #!/bin/bash                                                                │
│  exec 200>/tmp/myjob.lock                                                  │
│  flock -n 200 || exit 1                                                    │
│  # ... cod ...                                                              │
│                                                                             │
│  SOLUȚIA 2: Lock file manual (în script)                                   │
│  ─────────────────────────────────────────────────────────────────────────  │
│  LOCK="/tmp/myjob.lock"                                                    │
│  if [ -f "$LOCK" ]; then                                                   │
│      PID=$(cat "$LOCK")                                                    │
│      if ps -p "$PID" > /dev/null 2>&1; then                               │
│          echo "Already running (PID: $PID)"                                │
│          exit 0                                                             │
│      fi                                                                     │
│  fi                                                                         │
│  echo $$ > "$LOCK"                                                         │
│  trap "rm -f '$LOCK'" EXIT                                                 │
│  # ... cod ...                                                              │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    pause_interactive
    
    print_subheader "Anti-pattern-uri de evitat"
    
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────────────────────┐
│                    ❌ ANTI-PATTERN-URI DE EVITAT                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ☠️  EDITARE DIRECTĂ /var/spool/cron/crontabs/                             │
│      → Folosește crontab -e, niciodată editare directă                     │
│                                                                             │
│  ☠️  CRON JOBS CARE NECESITĂ INTERACȚIUNE                                  │
│      → Nu există terminal! Nu poți citi input.                             │
│                                                                             │
│  ☠️  COMENZI CU OUTPUT MASIV FĂRĂ REDIRECȚIONARE                          │
│      → Umple mailbox-ul sau syslog-ul                                      │
│                                                                             │
│  ☠️  RULARE CA ROOT CÂND NU E NECESAR                                      │
│      → Principiul least privilege                                          │
│                                                                             │
│  ☠️  NU TESTEAZĂ SCRIPTUL ÎNAINTE                                          │
│      → Test manual: ./script.sh                                            │
│      → Test cu mediu gol: env -i HOME=$HOME bash -c './script.sh'         │
│                                                                             │
│  ☠️  PRESUPUNERI DESPRE DIRECTORUL CURENT                                  │
│      → Directorul de lucru în cron e adesea / sau $HOME                   │
│      → Folosește cd explicit sau căi absolute                              │
│                                                                             │
│  ☠️  UITAREA DE % ÎN CRONTAB                                               │
│      → % e caracter special în crontab (newline)!                          │
│      → Trebuie escaped: \%                                                  │
│      → date +%Y%m%d → date +\%Y\%m\%d                                      │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    echo -e "${SUCCESS}✅ Secțiunea 8 completă!${RESET}"
    pause_interactive
}

#
# TOOL: GENERATOR EXPRESII CRON
#

tool_generator() {
    print_header "🔧 TOOL: GENERATOR EXPRESII CRON"
    
    cat << 'EOF'
┌─────────────────────────────────────────────────────────────────────────────┐
│              GENERATOR INTERACTIV DE EXPRESII CRON                          │
├─────────────────────────────────────────────────────────────────────────────┤
│  Răspunde la întrebări pentru a genera expresia cron dorită.               │
│  Introdu 'q' pentru a ieși.                                                 │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    while true; do
        echo ""
        echo -e "${CYAN}═══ NOU CRON JOB ═══${RESET}"
        echo ""
        
        # Frequență
        echo "Ce frecvență dorești?"
        echo "  1) La fiecare X minute"
        echo "  2) La fiecare X ore"
        echo "  3) Zilnic la o anumită oră"
        echo "  4) Săptămânal (anumite zile)"
        echo "  5) Lunar (anumite zile ale lunii)"
        echo "  6) Custom (introduci manual)"
        echo "  q) Ieșire"
        echo ""
        read -r -p "Alege (1-6 sau q): " freq_choice
        
        case "$freq_choice" in
            q|Q)
                echo "La revedere!"
                return 0
                ;;
            1)
                read -r -p "La câte minute? (1-59): " mins
                if [[ "$mins" =~ ^[0-9]+$ ]] && [ "$mins" -ge 1 ] && [ "$mins" -le 59 ]; then
                    cron_expr="*/$mins * * * *"
                else
                    echo -e "${RED}Valoare invalidă!${RESET}"
                    continue
                fi
                ;;
            2)
                read -r -p "La câte ore? (1-23): " hours
                read -r -p "La ce minut al orei? (0-59, default 0): " minute
                minute=${minute:-0}
                if [[ "$hours" =~ ^[0-9]+$ ]] && [ "$hours" -ge 1 ] && [ "$hours" -le 23 ]; then
                    cron_expr="$minute */$hours * * *"
                else
                    echo -e "${RED}Valoare invalidă!${RESET}"
                    continue
                fi
                ;;
            3)
                read -r -p "La ce oră? (0-23): " hour
                read -r -p "La ce minut? (0-59, default 0): " minute
                minute=${minute:-0}
                if [[ "$hour" =~ ^[0-9]+$ ]] && [ "$hour" -ge 0 ] && [ "$hour" -le 23 ]; then
                    cron_expr="$minute $hour * * *"
                else
                    echo -e "${RED}Valoare invalidă!${RESET}"
                    continue
                fi
                ;;
            4)
                read -r -p "La ce oră? (0-23): " hour
                read -r -p "La ce minut? (0-59, default 0): " minute
                minute=${minute:-0}
                echo "Ce zile din săptămână? (0=Dum, 1=Luni, ..., 6=Sâm)"
                echo "  Exemple: 1-5 (Luni-Vineri), 0,6 (weekend), 1,3,5 (L,Mi,V)"
                read -r -p "Zile: " dow
                cron_expr="$minute $hour * * $dow"
                ;;
            5)
                read -r -p "La ce oră? (0-23): " hour
                read -r -p "La ce minut? (0-59, default 0): " minute
                minute=${minute:-0}
                echo "Ce zile din lună? (1-31)"
                echo "  Exemple: 1 (prima zi), 1,15 (prima și a 15-a), 1-7 (primele 7 zile)"
                read -r -p "Zile: " dom
                cron_expr="$minute $hour $dom * *"
                ;;
            6)
                echo "Introdu expresia cron (5 câmpuri separate de spații):"
                read -r -p "Expresie: " cron_expr
                ;;
            *)
                echo -e "${RED}Opțiune invalidă!${RESET}"
                continue
                ;;
        esac
        
        # Validare simplă
        field_count=$(echo "$cron_expr" | awk '{print NF}')
        if [ "$field_count" -ne 5 ]; then
            echo -e "${RED}Expresie invalidă! Trebuie să aibă exact 5 câmpuri.${RESET}"
            continue
        fi
        
        # Afișare rezultat
        echo ""
        echo -e "${GREEN}════════════════════════════════════════════════════════════════════════════${RESET}"
        echo -e "${GREEN}  EXPRESIE CRON GENERATĂ:${RESET}"
        echo ""
        echo -e "    ${BOLD}${WHITE}$cron_expr${RESET}"
        echo ""
        
        # Explicare
        explain_cron_expression "$cron_expr"
        
        echo ""
        echo -e "${GREEN}════════════════════════════════════════════════════════════════════════════${RESET}"
        
        # Exemplu de utilizare
        echo ""
        echo "Exemplu de utilizare în crontab:"
        echo ""
        echo -e "  ${DIM}# Descrierea job-ului${RESET}"
        echo -e "  ${WHITE}$cron_expr /path/to/your/script.sh >> /path/to/log.log 2>&1${RESET}"
        echo ""
        
        read -r -p "Mai generezi o expresie? (y/n): " again
        if [[ "$again" != "y" && "$again" != "Y" ]]; then
            break
        fi
    done
}

#
# TOOL: VALIDATOR/EXPLICATOR EXPRESII CRON
#

explain_cron_expression() {
    local expr="$1"
    
    # Parse câmpurile
    local minute=$(echo "$expr" | awk '{print $1}')
    local hour=$(echo "$expr" | awk '{print $2}')
    local dom=$(echo "$expr" | awk '{print $3}')
    local month=$(echo "$expr" | awk '{print $4}')
    local dow=$(echo "$expr" | awk '{print $5}')
    
    echo -e "  ${CYAN}Interpretare:${RESET}"
    echo ""
    
    # Explică fiecare câmp
    echo -n "  • Minut:         "
    explain_field "$minute" "minute" 0 59
    
    echo -n "  • Oră:           "
    explain_field "$hour" "hour" 0 23
    
    echo -n "  • Zi din lună:   "
    explain_field "$dom" "dom" 1 31
    
    echo -n "  • Lună:          "
    explain_field "$month" "month" 1 12
    
    echo -n "  • Zi săptămână:  "
    explain_field "$dow" "dow" 0 7
    
    echo ""
    
    # Generează descriere în limbaj natural
    generate_natural_description "$minute" "$hour" "$dom" "$month" "$dow"
}

explain_field() {
    local value="$1"
    local field_type="$2"
    local min="$3"
    local max="$4"
    
    if [[ "$value" == "*" ]]; then
        echo "orice valoare ($min-$max)"
    elif [[ "$value" == *"/"* ]]; then
        local step="${value#*/}"
        local range="${value%/*}"
        if [[ "$range" == "*" ]]; then
            echo "la fiecare $step (din $min-$max)"
        else
            echo "la fiecare $step în intervalul $range"
        fi
    elif [[ "$value" == *","* ]]; then
        echo "valorile: $value"
    elif [[ "$value" == *"-"* ]]; then
        echo "intervalul $value"
    else
        case "$field_type" in
            dow)
                case "$value" in
                    0|7) echo "Duminică" ;;
                    1) echo "Luni" ;;
                    2) echo "Marți" ;;
                    3) echo "Miercuri" ;;
                    4) echo "Joi" ;;
                    5) echo "Vineri" ;;
                    6) echo "Sâmbătă" ;;
                    *) echo "$value" ;;
                esac
                ;;
            month)
                case "$value" in
                    1) echo "Ianuarie" ;;
                    2) echo "Februarie" ;;
                    3) echo "Martie" ;;
                    4) echo "Aprilie" ;;
                    5) echo "Mai" ;;
                    6) echo "Iunie" ;;
                    7) echo "Iulie" ;;
                    8) echo "August" ;;
                    9) echo "Septembrie" ;;
                    10) echo "Octombrie" ;;
                    11) echo "Noiembrie" ;;
                    12) echo "Decembrie" ;;
                    *) echo "$value" ;;
                esac
                ;;
            *)
                echo "$value"
                ;;
        esac
    fi
}

generate_natural_description() {
    local minute="$1"
    local hour="$2"
    local dom="$3"
    local month="$4"
    local dow="$5"
    
    echo -e "  ${YELLOW}📅 Descriere:${RESET}"
    echo -n "     "
    
    # Construiește descrierea
    local desc=""
    
    # Verifică pattern-uri comune
    if [[ "$minute" == "*" && "$hour" == "*" && "$dom" == "*" && "$month" == "*" && "$dow" == "*" ]]; then
        desc="La fiecare minut"
    elif [[ "$minute" == "0" && "$hour" == "*" && "$dom" == "*" && "$month" == "*" && "$dow" == "*" ]]; then
        desc="La fiecare oră (la minutul 0)"
    elif [[ "$minute" == "0" && "$hour" == "0" && "$dom" == "*" && "$month" == "*" && "$dow" == "*" ]]; then
        desc="Zilnic la miezul nopții (00:00)"
    elif [[ "$minute" == */[0-9]* && "$hour" == "*" ]]; then
        local step="${minute#*/}"
        desc="La fiecare $step minute"
    elif [[ "$hour" == */[0-9]* ]]; then
        local step="${hour#*/}"
        desc="La fiecare $step ore, la minutul $minute"
    elif [[ "$dow" == "1-5" || "$dow" == "mon-fri" ]]; then
        desc="Luni-Vineri la $hour:$(printf '%02d' $minute)"
    elif [[ "$dow" == "0,6" || "$dow" == "sat,sun" ]]; then
        desc="Weekend la $hour:$(printf '%02d' $minute)"
    elif [[ "$dom" != "*" && "$dow" == "*" && "$month" == "*" ]]; then
        desc="Pe zilele $dom ale fiecărei luni, la $hour:$(printf '%02d' $minute)"
    elif [[ "$dow" != "*" && "$dom" == "*" && "$month" == "*" ]]; then
        desc="În zilele $dow din săptămână, la $hour:$(printf '%02d' $minute)"
    else
        # Generic
        local time_part=""
        if [[ "$minute" != "*" && "$hour" != "*" ]]; then
            time_part="la $(printf '%02d:%02d' $hour $minute)"
        elif [[ "$minute" == "*" && "$hour" != "*" ]]; then
            time_part="în ora $hour"
        elif [[ "$minute" != "*" && "$hour" == "*" ]]; then
            time_part="la minutul $minute al fiecărei ore"
        fi
        
        local date_part=""
        if [[ "$dom" != "*" ]]; then
            date_part="pe $dom ale lunii"
        fi
        if [[ "$month" != "*" ]]; then
            date_part="$date_part în luna $month"
        fi
        if [[ "$dow" != "*" ]]; then
            date_part="$date_part în zilele $dow"
        fi
        
        desc="$time_part $date_part"
    fi
    
    echo "$desc"
}

tool_validator() {
    print_header "🔧 TOOL: VALIDATOR/EXPLICATOR EXPRESII CRON"
    
    cat << 'EOF'
┌─────────────────────────────────────────────────────────────────────────────┐
│            VALIDATOR ȘI EXPLICATOR EXPRESII CRON                            │
├─────────────────────────────────────────────────────────────────────────────┤
│  Introdu o expresie cron pentru a primi explicația în limbaj natural.      │
│  Introdu 'q' pentru a ieși.                                                 │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    while true; do
        echo ""
        read -r -p "Expresie cron (sau 'q' pentru ieșire): " input
        
        if [[ "$input" == "q" || "$input" == "Q" ]]; then
            echo "La revedere!"
            return 0
        fi
        
        # Verifică dacă e string special
        case "$input" in
            @reboot)
                echo -e "${GREEN}@reboot${RESET} = La pornirea sistemului (o singură dată)"
                continue
                ;;
            @yearly|@annually)
                echo -e "${GREEN}$input${RESET} = 0 0 1 1 * = Anual pe 1 Ianuarie la 00:00"
                continue
                ;;
            @monthly)
                echo -e "${GREEN}@monthly${RESET} = 0 0 1 * * = Lunar pe prima zi la 00:00"
                continue
                ;;
            @weekly)
                echo -e "${GREEN}@weekly${RESET} = 0 0 * * 0 = Săptămânal Duminică la 00:00"
                continue
                ;;
            @daily|@midnight)
                echo -e "${GREEN}$input${RESET} = 0 0 * * * = Zilnic la miezul nopții"
                continue
                ;;
            @hourly)
                echo -e "${GREEN}@hourly${RESET} = 0 * * * * = La fiecare oră, minutul 0"
                continue
                ;;
        esac
        
        # Validare număr câmpuri
        field_count=$(echo "$input" | awk '{print NF}')
        if [ "$field_count" -lt 5 ]; then
            echo -e "${RED}❌ Expresie invalidă! Necesită cel puțin 5 câmpuri.${RESET}"
            echo "   Format: minute hour day_of_month month day_of_week [command]"
            continue
        fi
        
        # Extrage doar primele 5 câmpuri
        cron_expr=$(echo "$input" | awk '{print $1, $2, $3, $4, $5}')
        
        echo ""
        echo -e "${GREEN}════════════════════════════════════════════════════════════════════════════${RESET}"
        echo -e "${GREEN}  ANALIZĂ EXPRESIE: ${WHITE}$cron_expr${RESET}"
        echo -e "${GREEN}════════════════════════════════════════════════════════════════════════════${RESET}"
        echo ""
        
        explain_cron_expression "$cron_expr"
        
        # Calculează următoarele execuții (simplificat)
        echo ""
        echo -e "  ${MAGENTA}💡 TIP: Pentru calcul exact al următoarelor execuții,${RESET}"
        echo -e "         ${MAGENTA}folosește: https://crontab.guru/${RESET}"
        
        echo ""
    done
}

#
# TOOL: MONITOR CRON JOBS
#

tool_monitor() {
    print_header "🔧 TOOL: MONITOR CRON JOBS LIVE"
    
    cat << 'EOF'
┌─────────────────────────────────────────────────────────────────────────────┐
│              MONITOR LIVE PENTRU CRON JOBS                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│  Monitorizează execuțiile cron în timp real.                               │
│  Apasă Ctrl+C pentru a opri.                                               │
└─────────────────────────────────────────────────────────────────────────────┘

EOF

    echo "Crontab curent:"
    echo -e "${DIM}──────────────────────────────────────────────────────────────────────────────${RESET}"
    crontab -l 2>/dev/null || echo "(gol)"
    echo -e "${DIM}──────────────────────────────────────────────────────────────────────────────${RESET}"
    echo ""
    
    echo "Monitorizare log-uri cron..."
    echo "(Apasă Ctrl+C pentru a opri)"
    echo ""
    
    # Încearcă diferite surse de log
    if [ -f /var/log/syslog ]; then
        echo -e "${CYAN}Urmăresc /var/log/syslog pentru intrări CRON...${RESET}"
        echo ""
        tail -f /var/log/syslog 2>/dev/null | grep --line-buffered -i cron
    elif command -v journalctl &> /dev/null; then
        echo -e "${CYAN}Urmăresc journalctl pentru serviciul cron...${RESET}"
        echo ""
        journalctl -f -u cron
    else
        echo -e "${YELLOW}Nu pot găsi log-uri cron standard.${RESET}"
        echo "Încearcă manual:"
        echo "  tail -f /var/log/syslog | grep CRON"
        echo "  journalctl -f -u cron"
    fi
}

#
# SUMMARY: CHEAT SHEET
#

print_cheat_sheet() {
    print_header "📋 CRON CHEAT SHEET"
    
    cat << 'EOF'
┌─────────────────────────────────────────────────────────────────────────────┐
│                         CRON CHEAT SHEET                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│  FORMAT:  min(0-59) hour(0-23) dom(1-31) month(1-12) dow(0-7) command      │
│                                                                             │
│  OPERATORI:                                                                 │
│  *         orice valoare              */5       la fiecare 5               │
│  ,         listă (1,3,5)              -         interval (1-5)             │
│                                                                             │
│  STRING-URI SPECIALE:                                                       │
│  @reboot   la pornire                 @hourly   0 * * * *                  │
│  @daily    0 0 * * *                  @weekly   0 0 * * 0                  │
│  @monthly  0 0 1 * *                  @yearly   0 0 1 1 *                  │
│                                                                             │
│  COMENZI:                                                                   │
│  crontab -e   editează                crontab -l   listează                │
│  crontab -r   șterge TOTUL (!)        crontab file instalează              │
│                                                                             │
│  EXEMPLE COMUNE:                                                            │
│  * * * * *        La fiecare minut                                         │
│  0 * * * *        La fiecare oră                                           │
│  0 0 * * *        Zilnic la miezul nopții                                  │
│  0 3 * * *        Zilnic la 3:00 AM                                        │
│  */15 * * * *     La fiecare 15 minute                                     │
│  0 9-17 * * 1-5   Ore lucru (9-17, Luni-Vineri)                           │
│  0 0 1,15 * *     Pe 1 și 15 ale lunii                                     │
│  0 0 * * 0        Duminică la miezul nopții                                │
│                                                                             │
│  BEST PRACTICES:                                                            │
│  ✓ Căi absolute              ✓ Redirecționează output                      │
│  ✓ Lock files (flock)        ✓ Logging complet                             │
│  ✓ Backup crontab            ✓ Testează înainte                            │
│                                                                             │
│  LOGGING PATTERN:                                                           │
│  0 3 * * * /path/script.sh >> /var/log/script.log 2>&1                    │
│                                                                             │
│  LOCK FILE PATTERN:                                                         │
│  * * * * * flock -n /tmp/job.lock -c '/path/script.sh'                    │
└─────────────────────────────────────────────────────────────────────────────┘

EOF
}

#
# FUNCȚIA PRINCIPALĂ
#

show_usage() {
    cat << EOF
Utilizare: $0 [OPȚIUNI]

OPȚIUNI:
  -h, --help        Afișează acest ajutor
  -i, --interactive Mod interactiv cu pauze
  -s, --section NUM Rulează doar secțiunea specificată (1-8)
  -c, --cleanup     Curăță mediul demo
  --generator       Lansează generatorul de expresii cron
  --validator       Lansează validatorul de expresii cron
  --monitor         Lansează monitorul de cron jobs
  --cheat-sheet     Afișează cheat sheet-ul

SECȚIUNI:
  1: Introducere în cron
  2: Formatul crontab (cele 5 câmpuri)
  3: Caractere speciale (*, /, -, ,)
  4: String-uri speciale (@reboot, @daily, etc.)
  5: Gestionarea crontab (crontab -e/-l/-r)
  6: Mediul de execuție și PATH
  7: Logging și debugging
  8: Comanda at și best practices

EXEMPLE:
  $0                     # Rulează tot demo-ul
  $0 -i                  # Mod interactiv
  $0 -s 3                # Doar secțiunea despre caractere speciale
  $0 --generator         # Generator expresii cron
  $0 --validator         # Validator expresii cron
EOF
}

main() {
    # Parsare argumente
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_usage
                exit 0
                ;;
            -i|--interactive)
                INTERACTIVE=true
                shift
                ;;
            -s|--section)
                SECTION_NUM="$2"
                shift 2
                ;;
            -c|--cleanup)
                cleanup_demo
                exit 0
                ;;
            --generator)
                tool_generator
                exit 0
                ;;
            --validator)
                tool_validator
                exit 0
                ;;
            --monitor)
                tool_monitor
                exit 0
                ;;
            --cheat-sheet)
                print_cheat_sheet
                exit 0
                ;;
            *)
                echo "Opțiune necunoscută: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Banner
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║${RESET}     ${BOLD}⏰ DEMONSTRAȚIE CRON ȘI AUTOMATIZARE - Seminar 5-6 SO${RESET}                   ${CYAN}║${RESET}"
    echo -e "${CYAN}║${RESET}     Academia de Studii Economice București - CSIE                           ${CYAN}║${RESET}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${RESET}"
    echo ""
    
    # Setup
    setup_demo_environment
    
    # Rulare secțiuni
    if [ "$SECTION_NUM" -ne 0 ]; then
        case "$SECTION_NUM" in
            1) section_1_introduction ;;
            2) section_2_crontab_format ;;
            3) section_3_special_characters ;;
            4) section_4_special_strings ;;
            5) section_5_crontab_management ;;
            6) section_6_environment ;;
            7) section_7_logging_debugging ;;
            8) section_8_at_and_best_practices ;;
            *)
                echo "Secțiune invalidă: $SECTION_NUM (1-8)"
                exit 1
                ;;
        esac
    else
        # Toate secțiunile
        section_1_introduction
        section_2_crontab_format
        section_3_special_characters
        section_4_special_strings
        section_5_crontab_management
        section_6_environment
        section_7_logging_debugging
        section_8_at_and_best_practices
    fi
    
    # Cheat sheet la final
    print_cheat_sheet
    
    echo ""
    echo -e "${SUCCESS}════════════════════════════════════════════════════════════════════════════${RESET}"
    echo -e "${SUCCESS}  ✅ DEMONSTRAȚIE COMPLETĂ!${RESET}"
    echo ""
    echo "  Tools disponibile:"
    echo "    $0 --generator    Generează expresii cron"
    echo "    $0 --validator    Explică expresii cron"
    echo "    $0 --monitor      Monitorizează jobs live"
    echo ""
    echo "  Cleanup: $0 -c"
    echo ""
    echo -e "${SUCCESS}════════════════════════════════════════════════════════════════════════════${RESET}"
}

# Rulare
main "$@"
