#!/bin/bash
#===============================================================================
# GENERATE_CONFIGS.SH - Generator Configurații Template
#===============================================================================
# Scop: Generează fișiere de configurare template pentru toate proiectele
# Utilizare: ./generate_configs.sh [--output-dir=DIR] [--project=NAME]
# Autor: Seminarul 11-12 CAPSTONE - Sisteme de Operare ASE București
#===============================================================================

set -euo pipefail

#-------------------------------------------------------------------------------
# CONSTANTE
#-------------------------------------------------------------------------------
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly VERSION="1.0.0"
readonly DEFAULT_OUTPUT_DIR="./generated_configs"

# Culori
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly MAGENTA='\033[0;35m'
readonly BOLD='\033[1m'
readonly DIM='\033[2m'
readonly NC='\033[0m'

#-------------------------------------------------------------------------------
# VARIABILE
#-------------------------------------------------------------------------------
OUTPUT_DIR="$DEFAULT_OUTPUT_DIR"
PROJECT=""
INTERACTIVE=false
VERBOSE=false

# Valorile vor fi populat în mod interactiv sau din variabile de mediu
HOSTNAME="${HOSTNAME:-$(hostname)}"
USER_NAME="${USER:-$(whoami)}"
USER_HOME="${HOME:-/home/$USER_NAME}"
CURRENT_DATE=$(date +%Y-%m-%d)

#-------------------------------------------------------------------------------
# FUNCȚII UTILITATE
#-------------------------------------------------------------------------------

print_banner() {
    echo -e "${MAGENTA}"
    cat << 'EOF'
╔═══════════════════════════════════════════════════════════════════════╗
║          CAPSTONE PROJECTS - CONFIG GENERATOR v1.0.0                  ║
║                  Sisteme de Operare ASE București                     ║
╚═══════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[OK]${NC}   $1"
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

prompt_value() {
    local prompt="$1"
    local default="$2"
    local var_name="$3"
    
    local value
    read -r -p "$prompt [$default]: " value
    value="${value:-$default}"
    
    eval "$var_name=\"$value\""
}

#-------------------------------------------------------------------------------
# GENERATOARE CONFIGURAȚII
#-------------------------------------------------------------------------------

generate_monitor_config() {
    local output_file="${OUTPUT_DIR}/monitor.conf"
    
    log_info "Generare configurație Monitor..."
    
    cat > "$output_file" << EOF
#===============================================================================
# SYSMONITOR - Configuration File
#===============================================================================
# Generated: ${CURRENT_DATE}
# Host: ${HOSTNAME}
# 
# Documentație: https://github.com/capstone/monitor
#===============================================================================

#-------------------------------------------------------------------------------
# GENERAL SETTINGS
#-------------------------------------------------------------------------------

# Nume instanță (pentru identificare în loguri și notificări)
MONITOR_NAME="${HOSTNAME}_monitor"

# Interval default monitorizare (secunde)
MONITOR_INTERVAL=60

# Nivel logging: DEBUG, INFO, WARN, ERROR
LOG_LEVEL="INFO"

# Director loguri
LOG_DIR="/var/log/capstone/monitor"

# Fișier log principal
LOG_FILE="\${LOG_DIR}/monitor.log"

# Rotație loguri: număr fișiere păstrate
LOG_ROTATE_COUNT=7

# Dimensiune maximă log înainte de rotație (bytes)
LOG_MAX_SIZE=10485760  # 10MB

#-------------------------------------------------------------------------------
# CPU MONITORING
#-------------------------------------------------------------------------------

# Activare monitorizare CPU
CPU_MONITOR_ENABLED=true

# Prag alertă utilizare CPU (procent)
CPU_THRESHOLD_WARNING=70
CPU_THRESHOLD_CRITICAL=90

# Interval mediere (secunde) - pentru a evita false pozitive
CPU_AVERAGE_INTERVAL=5

#-------------------------------------------------------------------------------
# MEMORY MONITORING
#-------------------------------------------------------------------------------

# Activare monitorizare memorie
MEMORY_MONITOR_ENABLED=true

# Prag alertă utilizare memorie (procent)
MEMORY_THRESHOLD_WARNING=75
MEMORY_THRESHOLD_CRITICAL=90

# Monitorizare swap
SWAP_MONITOR_ENABLED=true
SWAP_THRESHOLD_WARNING=50
SWAP_THRESHOLD_CRITICAL=80

#-------------------------------------------------------------------------------
# DISK MONITORING
#-------------------------------------------------------------------------------

# Activare monitorizare disk
DISK_MONITOR_ENABLED=true

# Prag alertă utilizare disk (procent)
DISK_THRESHOLD_WARNING=80
DISK_THRESHOLD_CRITICAL=95

# Partiții de monitorizat (virgulă separate, sau "all")
DISK_PARTITIONS="all"

# Excluderi (pattern-uri)
DISK_EXCLUDE="/dev/loop*,/snap/*"

# Monitorizare I/O
DISK_IO_MONITOR=true

#-------------------------------------------------------------------------------
# NETWORK MONITORING
#-------------------------------------------------------------------------------

# Activare monitorizare rețea
NETWORK_MONITOR_ENABLED=true

# Interfețe de monitorizat (virgulă separate, sau "all")
NETWORK_INTERFACES="all"

# Verificare conectivitate
NETWORK_PING_ENABLED=true
NETWORK_PING_HOST="8.8.8.8"
NETWORK_PING_TIMEOUT=5

#-------------------------------------------------------------------------------
# PROCESS MONITORING
#-------------------------------------------------------------------------------

# Activare monitorizare procese
PROCESS_MONITOR_ENABLED=true

# Procese critice (virgulă separate) - alertă dacă nu rulează
PROCESS_CRITICAL="sshd"

# Prag număr procese
PROCESS_COUNT_WARNING=500
PROCESS_COUNT_CRITICAL=1000

# Top N procese după CPU/memorie în rapoarte
PROCESS_TOP_COUNT=10

#-------------------------------------------------------------------------------
# ALERTS & NOTIFICATIONS
#-------------------------------------------------------------------------------

# Activare notificări
NOTIFICATIONS_ENABLED=false

# Email notificări
EMAIL_ENABLED=false
EMAIL_TO="admin@example.com"
EMAIL_FROM="monitor@${HOSTNAME}"
EMAIL_SMTP_HOST="localhost"
EMAIL_SMTP_PORT=25

# Slack notificări
SLACK_ENABLED=false
SLACK_WEBHOOK_URL=""
SLACK_CHANNEL="#alerts"

# Cooldown între alerte identice (secunde)
ALERT_COOLDOWN=300

#-------------------------------------------------------------------------------
# OUTPUT SETTINGS
#-------------------------------------------------------------------------------

# Format output: text, json, csv
OUTPUT_FORMAT="text"

# Timestamp format
TIMESTAMP_FORMAT="%Y-%m-%d %H:%M:%S"

# Colorare output terminal
OUTPUT_COLORS=true

#-------------------------------------------------------------------------------
# DAEMON MODE
#-------------------------------------------------------------------------------

# PID file pentru daemon
DAEMON_PID_FILE="/var/run/sysmonitor.pid"

# Lock file pentru a preveni instanțe multiple
LOCK_FILE="/var/lock/sysmonitor.lock"

#-------------------------------------------------------------------------------
# CUSTOM CHECKS
#-------------------------------------------------------------------------------

# Director pentru verificări custom
CUSTOM_CHECKS_DIR="/etc/capstone/monitor.d"

# Timeout pentru verificări custom (secunde)
CUSTOM_CHECK_TIMEOUT=30
EOF
    
    log_success "Monitor config: $output_file"
}

generate_backup_config() {
    local output_file="${OUTPUT_DIR}/backup.conf"
    
    log_info "Generare configurație Backup..."
    
    cat > "$output_file" << EOF
#===============================================================================
# SYSBACKUP - Configuration File
#===============================================================================
# Generated: ${CURRENT_DATE}
# Host: ${HOSTNAME}
#
# Documentație: https://github.com/capstone/backup
#===============================================================================

#-------------------------------------------------------------------------------
# GENERAL SETTINGS
#-------------------------------------------------------------------------------

# Nume backup set
BACKUP_NAME="${HOSTNAME}_backup"

# Director destinație backup
BACKUP_DESTINATION="/var/backups/capstone"

# Director temporar pentru operații
BACKUP_TEMP_DIR="/tmp/backup_tmp"

# Nivel logging
LOG_LEVEL="INFO"

# Director loguri
LOG_DIR="/var/log/capstone/backup"

# Fișier log principal
LOG_FILE="\${LOG_DIR}/backup.log"

#-------------------------------------------------------------------------------
# SOURCE DIRECTORIES
#-------------------------------------------------------------------------------

# Directoare de backup (separate prin spațiu sau pe linii multiple)
# Folosiți calea absolută
BACKUP_SOURCES="
    /etc
    /home
    /var/www
    /opt
"

# Fișiere/directoare individuale (opțional)
BACKUP_FILES=""

#-------------------------------------------------------------------------------
# EXCLUSIONS
#-------------------------------------------------------------------------------

# Pattern-uri de excludere (glob patterns)
BACKUP_EXCLUDE="
    *.tmp
    *.temp
    *.log
    *.cache
    .cache
    .npm
    node_modules
    __pycache__
    *.pyc
    .git
    .svn
    lost+found
    /proc/*
    /sys/*
    /dev/*
    /run/*
    /tmp/*
    /var/tmp/*
"

# Fișier cu excluderi adiționale
EXCLUDE_FILE="/etc/capstone/backup.exclude"

#-------------------------------------------------------------------------------
# COMPRESSION
#-------------------------------------------------------------------------------

# Metodă compresie: none, gzip, bzip2, xz, zstd
COMPRESSION_METHOD="gzip"

# Nivel compresie (1-9, unde 9 = maxim)
COMPRESSION_LEVEL=6

# Threads pentru compresie paralelă (xz, zstd)
COMPRESSION_THREADS=2

#-------------------------------------------------------------------------------
# ARCHIVE FORMAT
#-------------------------------------------------------------------------------

# Format arhivă: tar, tar.gz, tar.bz2, tar.xz, tar.zst
ARCHIVE_FORMAT="tar.gz"

# Prefix nume arhivă
ARCHIVE_PREFIX="\${BACKUP_NAME}"

# Pattern timestamp pentru nume arhivă
ARCHIVE_TIMESTAMP="%Y%m%d_%H%M%S"

# Exemplu rezultat: hostname_backup_20240115_143022.tar.gz

#-------------------------------------------------------------------------------
# RETENTION POLICY
#-------------------------------------------------------------------------------

# Activare rotație automată
ROTATION_ENABLED=true

# Tip rotație: count (după număr) sau age (după vârstă)
ROTATION_TYPE="count"

# Pentru count: număr backup-uri păstrate
ROTATION_COUNT=7

# Pentru age: vârstă maximă (days)
ROTATION_MAX_AGE=30

# Politici avansate (dacă toate sunt definite)
RETENTION_DAILY=7      # Păstrare backup-uri zilnice
RETENTION_WEEKLY=4     # Păstrare backup-uri săptămânale
RETENTION_MONTHLY=6    # Păstrare backup-uri lunare

#-------------------------------------------------------------------------------
# INTEGRITY & VERIFICATION
#-------------------------------------------------------------------------------

# Algoritm checksum: md5, sha1, sha256
CHECKSUM_ALGORITHM="sha256"

# Verificare integritate după backup
VERIFY_AFTER_BACKUP=true

# Creare fișier checksum separat
CREATE_CHECKSUM_FILE=true

# Test extragere după backup (mai lent dar sigur)
TEST_EXTRACT=false

#-------------------------------------------------------------------------------
# INCREMENTAL BACKUP
#-------------------------------------------------------------------------------

# Activare backup incremental
INCREMENTAL_ENABLED=false

# Director pentru snapshot files (tar --listed-incremental)
SNAPSHOT_DIR="/var/lib/capstone/backup/snapshots"

# Interval backup complet forțat (zile)
# 0 = doar la cerere explicită
FULL_BACKUP_INTERVAL=7

#-------------------------------------------------------------------------------
# ENCRYPTION (opțional)
#-------------------------------------------------------------------------------

# Activare criptare
ENCRYPTION_ENABLED=false

# Metodă criptare: gpg, openssl
ENCRYPTION_METHOD="gpg"

# Pentru GPG: recipient (key ID sau email)
GPG_RECIPIENT=""

# Pentru OpenSSL: algoritm
OPENSSL_CIPHER="aes-256-cbc"

#-------------------------------------------------------------------------------
# REMOTE BACKUP (opțional)
#-------------------------------------------------------------------------------

# Activare copiere remotă
REMOTE_ENABLED=false

# Metodă: rsync, scp, s3
REMOTE_METHOD="rsync"

# Destinație remotă
# rsync/scp: user@host:/path
# s3: s3://bucket/prefix
REMOTE_DESTINATION=""

# Opțiuni rsync
RSYNC_OPTIONS="-avz --progress"

# Păstrare backup local după copiere remotă
KEEP_LOCAL_AFTER_REMOTE=true

#-------------------------------------------------------------------------------
# NOTIFICATIONS
#-------------------------------------------------------------------------------

# Notificări la 
NOTIFY_ON_SUCCESS=false

# Notificări la eșec
NOTIFY_ON_FAILURE=true

# Email pentru notificări
NOTIFY_EMAIL="admin@example.com"

# Comandă notificare custom
# Variabile disponibile: \$BACKUP_NAME, \$BACKUP_FILE, \$BACKUP_SIZE, \$STATUS
NOTIFY_COMMAND=""

#-------------------------------------------------------------------------------
# HOOKS
#-------------------------------------------------------------------------------

# Script executat înainte de backup
PRE_BACKUP_HOOK=""

# Script executat după backup (succes)
POST_BACKUP_HOOK=""

# Script executat la eșec
ON_FAILURE_HOOK=""

# Exemple:
# PRE_BACKUP_HOOK="/etc/capstone/hooks/pre_backup.sh"
# POST_BACKUP_HOOK="/etc/capstone/hooks/post_backup.sh"

#-------------------------------------------------------------------------------
# PERFORMANCE
#-------------------------------------------------------------------------------

# Nice level pentru proces backup (-20 to 19)
NICE_LEVEL=10

# Ionice class (0=none, 1=realtime, 2=best-effort, 3=idle)
IONICE_CLASS=3

# Bandwidth limit pentru rsync (KB/s, 0 = unlimited)
BANDWIDTH_LIMIT=0

#-------------------------------------------------------------------------------
# LOCK & CONCURRENCY
#-------------------------------------------------------------------------------

# Lock file pentru a preveni backup-uri simultane
LOCK_FILE="/var/lock/sysbackup.lock"

# Timeout pentru așteptare lock (secunde)
LOCK_TIMEOUT=3600

# Forțare deblocare după timeout
LOCK_FORCE_UNLOCK=false
EOF
    
    log_success "Backup config: $output_file"
}

generate_deployer_config() {
    local output_file="${OUTPUT_DIR}/deployer.conf"
    
    log_info "Generare configurație Deployer..."
    
    cat > "$output_file" << EOF
#===============================================================================
# SYSDEPLOY - Configuration File
#===============================================================================
# Generated: ${CURRENT_DATE}
# Host: ${HOSTNAME}
#
# Documentație: https://github.com/capstone/deployer
#===============================================================================

#-------------------------------------------------------------------------------
# GENERAL SETTINGS
#-------------------------------------------------------------------------------

# Nume instanță deployer
DEPLOYER_NAME="${HOSTNAME}_deployer"

# Director bază pentru deployments
DEPLOY_BASE_DIR="/opt/deployments"

# Director pentru releases
RELEASES_DIR="\${DEPLOY_BASE_DIR}/releases"

# Director shared (fișiere persistente între releases)
SHARED_DIR="\${DEPLOY_BASE_DIR}/shared"

# Symlink către versiunea curentă
CURRENT_LINK="\${DEPLOY_BASE_DIR}/current"

# Nivel logging
LOG_LEVEL="INFO"

# Director loguri
LOG_DIR="/var/log/capstone/deployer"

#-------------------------------------------------------------------------------
# DEPLOYMENT STRATEGY
#-------------------------------------------------------------------------------

# Strategie default: simple, rolling, blue-green, canary
DEFAULT_STRATEGY="simple"

# Pentru rolling: număr instanțe simultan
ROLLING_BATCH_SIZE=1

# Pentru rolling: pauză între batches (secunde)
ROLLING_PAUSE=5

# Pentru canary: procent inițial
CANARY_INITIAL_PERCENT=10

# Pentru canary: increment
CANARY_INCREMENT=10

#-------------------------------------------------------------------------------
# RELEASES MANAGEMENT
#-------------------------------------------------------------------------------

# Număr releases păstrate (pentru rollback)
RELEASES_KEEP=5

# Cleanup releases vechi automat
RELEASES_CLEANUP=true

# Format timestamp pentru release
RELEASE_TIMESTAMP="%Y%m%d%H%M%S"

# Prefix release
RELEASE_PREFIX="release_"

#-------------------------------------------------------------------------------
# HEALTH CHECKS
#-------------------------------------------------------------------------------

# Activare health checks
HEALTH_CHECK_ENABLED=true

# Timeout health check (secunde)
HEALTH_CHECK_TIMEOUT=30

# Interval între retry-uri
HEALTH_CHECK_INTERVAL=5

# Număr retry-uri
HEALTH_CHECK_RETRIES=3

# Delay inițial înainte de primul check
HEALTH_CHECK_INITIAL_DELAY=10

# Tipuri suportate: http, tcp, process, command
DEFAULT_HEALTH_CHECK_TYPE="http"

# Pentru HTTP health check
HEALTH_CHECK_PATH="/health"
HEALTH_CHECK_PORT=8080
HEALTH_CHECK_EXPECTED_STATUS=200

# Pentru TCP health check
HEALTH_CHECK_TCP_PORT=8080

# Pentru process health check
HEALTH_CHECK_PROCESS_NAME=""

# Pentru command health check
HEALTH_CHECK_COMMAND=""

#-------------------------------------------------------------------------------
# SERVICE MANAGEMENT
#-------------------------------------------------------------------------------

# Tip serviciu: systemd, docker, script, none
SERVICE_TYPE="systemd"

# Nume serviciu systemd
SERVICE_NAME=""

# Timeout pentru operații serviciu (secunde)
SERVICE_TIMEOUT=60

# Restart la deployment
SERVICE_RESTART=true

# Verificare status după restart
SERVICE_VERIFY_STATUS=true

#-------------------------------------------------------------------------------
# DOCKER SETTINGS (dacă SERVICE_TYPE=docker)
#-------------------------------------------------------------------------------

# Imagine Docker
DOCKER_IMAGE=""

# Tag imagine
DOCKER_TAG="latest"

# Nume container
DOCKER_CONTAINER_NAME=""

# Opțiuni docker run
DOCKER_RUN_OPTIONS=""

# Registry (dacă nu e Docker Hub)
DOCKER_REGISTRY=""

# Cleanup imagini vechi
DOCKER_CLEANUP_IMAGES=true

#-------------------------------------------------------------------------------
# HOOKS
#-------------------------------------------------------------------------------

# Director hooks
HOOKS_DIR="/etc/capstone/deployer/hooks"

# Hook înainte de orice operație
HOOK_PRE_DEPLOY=""

# Hook după copiere fișiere
HOOK_POST_COPY=""

# Hook înainte de switch la noua versiune
HOOK_PRE_SWITCH=""

# Hook după switch (deployment complet)
HOOK_POST_DEPLOY=""

# Hook la rollback
HOOK_ON_ROLLBACK=""

# Hook la eșec
HOOK_ON_FAILURE=""

# Timeout hooks (secunde)
HOOK_TIMEOUT=300

#-------------------------------------------------------------------------------
# ENVIRONMENT VARIABLES
#-------------------------------------------------------------------------------

# Fișier environment
ENV_FILE="\${SHARED_DIR}/.env"

# Variabile adiționale (YAML/KEY=VALUE)
DEPLOY_ENV=""

# Exemplu:
# DEPLOY_ENV="
#     NODE_ENV=production
#     LOG_LEVEL=info
# "

#-------------------------------------------------------------------------------
# FILE PERMISSIONS
#-------------------------------------------------------------------------------

# User pentru fișiere deployate
DEPLOY_USER="${USER_NAME}"

# Grup pentru fișiere deployate
DEPLOY_GROUP="${USER_NAME}"

# Permisiuni directoare
DIR_PERMISSIONS="0755"

# Permisiuni fișiere
FILE_PERMISSIONS="0644"

# Permisiuni fișiere executabile
EXEC_PERMISSIONS="0755"

#-------------------------------------------------------------------------------
# NOTIFICATIONS
#-------------------------------------------------------------------------------

# Activare notificări
NOTIFICATIONS_ENABLED=false

# Email pentru notificări
NOTIFICATION_EMAIL=""

# Slack webhook
SLACK_WEBHOOK_URL=""
SLACK_CHANNEL="#deployments"

# Notificare la începutul deployment
NOTIFY_ON_START=true

# Notificare la 
NOTIFY_ON_SUCCESS=true

# Notificare la eșec
NOTIFY_ON_FAILURE=true

# Notificare la rollback
NOTIFY_ON_ROLLBACK=true

#-------------------------------------------------------------------------------
# ROLLBACK
#-------------------------------------------------------------------------------

# Rollback automat la health check fail
AUTO_ROLLBACK=true

# Păstrare release eșuat pentru debugging
KEEP_FAILED_RELEASE=true

# Timeout pentru rollback
ROLLBACK_TIMEOUT=120

#-------------------------------------------------------------------------------
# LOCK & CONCURRENCY
#-------------------------------------------------------------------------------

# Lock file
LOCK_FILE="/var/lock/sysdeploy.lock"

# Timeout pentru așteptare lock
LOCK_TIMEOUT=600

# Permite deployment-uri paralele (diferite aplicații)
PARALLEL_DEPLOYS=false

#-------------------------------------------------------------------------------
# MANIFEST
#-------------------------------------------------------------------------------

# Fișier manifest default
DEFAULT_MANIFEST="deploy.yaml"

# Validare manifest înainte de deployment
VALIDATE_MANIFEST=true

# Strict mode (fail on unknown keys)
MANIFEST_STRICT=false

#-------------------------------------------------------------------------------
# ADVANCED
#-------------------------------------------------------------------------------

# Dry run by default (pentru testing)
DRY_RUN=false

# Verbose output
VERBOSE=false

# Force deployment (ignore warnings)
FORCE=false

# Timeout global deployment
DEPLOY_TIMEOUT=1800

# Nice level
NICE_LEVEL=10
EOF
    
    log_success "Deployer config: $output_file"
}

generate_cron_examples() {
    local output_file="${OUTPUT_DIR}/cron_examples.txt"
    
    log_info "Generare exemple crontab..."
    
    cat > "$output_file" << EOF
#===============================================================================
# CRONTAB EXAMPLES - CAPSTONE Projects
#===============================================================================
# Generated: ${CURRENT_DATE}
#
# Adăugare în crontab: crontab -e
# Sau plasare în /etc/cron.d/capstone
#===============================================================================

#-------------------------------------------------------------------------------
# MONITOR - System Monitoring
#-------------------------------------------------------------------------------

# Raport sistem la fiecare 5 minute
*/5 * * * * /usr/local/bin/sysmonitor --report >> /var/log/capstone/monitor/cron.log 2>&1

# Verificare critică la fiecare minut
* * * * * /usr/local/bin/sysmonitor --check --critical-only >> /var/log/capstone/monitor/critical.log 2>&1

# Raport zilnic complet la 6:00 AM
0 6 * * * /usr/local/bin/sysmonitor --report --format=json > /var/log/capstone/monitor/daily_$(date +\%Y\%m\%d).json 2>&1

# Raport săptămânal duminică la 23:00
0 23 * * 0 /usr/local/bin/sysmonitor --weekly-report | mail -s "Weekly System Report" admin@example.com

#-------------------------------------------------------------------------------
# BACKUP - System Backup
#-------------------------------------------------------------------------------

# Backup zilnic la 2:00 AM
0 2 * * * /usr/local/bin/sysbackup --daily >> /var/log/capstone/backup/cron.log 2>&1

# Backup săptămânal duminică la 3:00 AM
0 3 * * 0 /usr/local/bin/sysbackup --weekly >> /var/log/capstone/backup/cron.log 2>&1

# Backup lunar în prima zi la 4:00 AM
0 4 1 * * /usr/local/bin/sysbackup --monthly >> /var/log/capstone/backup/cron.log 2>&1

# Backup incremental la fiecare 6 ore
0 */6 * * * /usr/local/bin/sysbackup --incremental >> /var/log/capstone/backup/incremental.log 2>&1

# Verificare integritate săptămânal
0 5 * * 1 /usr/local/bin/sysbackup --verify >> /var/log/capstone/backup/verify.log 2>&1

# Cleanup backup-uri vechi
0 6 * * * /usr/local/bin/sysbackup --cleanup >> /var/log/capstone/backup/cleanup.log 2>&1

#-------------------------------------------------------------------------------
# MAINTENANCE
#-------------------------------------------------------------------------------

# Rotație loguri la miezul nopții
0 0 * * * /usr/sbin/logrotate /etc/logrotate.d/capstone

# Cleanup temporar săptămânal
0 4 * * 0 find /tmp -type f -name 'capstone_*' -mtime +7 -delete

# Verificare dependențe lunar
0 0 1 * * /usr/local/share/capstone/check_dependencies.sh --json > /var/log/capstone/deps_$(date +\%Y\%m).json

#-------------------------------------------------------------------------------
# TIPS
#-------------------------------------------------------------------------------
# 
# Format: minute hour day_of_month month day_of_week command
#
# Special strings:
#   @reboot    - Run once at startup
#   @yearly    - Run once a year (0 0 1 1 *)
#   @monthly   - Run once a month (0 0 1 * *)
#   @weekly    - Run once a week (0 0 * * 0)
#   @daily     - Run once a day (0 0 * * *)
#   @hourly    - Run once an hour (0 * * * *)
#
# Exemple:
#   */15 * * * *     - La fiecare 15 minute
#   0 */2 * * *      - La fiecare 2 ore
#   0 9-17 * * 1-5   - În fiecare oră între 9-17, luni-vineri
#   0 0 * * 0        - Duminică la miezul nopții
#
EOF
    
    log_success "Cron examples: $output_file"
}

generate_systemd_units() {
    local output_dir="${OUTPUT_DIR}/systemd"
    mkdir -p "$output_dir"
    
    log_info "Generare unități systemd..."
    
    # Monitor service
    cat > "$output_dir/sysmonitor.service" << EOF
[Unit]
Description=System Monitor Daemon
Documentation=https://github.com/capstone/monitor
After=network.target

[Service]
Type=simple
User=root
Group=root
ExecStart=/usr/local/bin/sysmonitor --daemon
ExecReload=/bin/kill -HUP \$MAINPID
Restart=always
RestartSec=10
StandardOutput=append:/var/log/capstone/monitor/daemon.log
StandardError=append:/var/log/capstone/monitor/daemon.log

# Security
NoNewPrivileges=yes
ProtectSystem=strict
ProtectHome=read-only
ReadWritePaths=/var/log/capstone/monitor /var/lib/capstone/monitor

[Install]
WantedBy=multi-user.target
EOF
    
    # Monitor timer
    cat > "$output_dir/sysmonitor.timer" << EOF
[Unit]
Description=System Monitor Periodic Check
Documentation=https://github.com/capstone/monitor

[Timer]
OnBootSec=1min
OnUnitActiveSec=5min
AccuracySec=1s

[Install]
WantedBy=timers.target
EOF
    
    # Backup service
    cat > "$output_dir/sysbackup.service" << EOF
[Unit]
Description=System Backup Service
Documentation=https://github.com/capstone/backup
After=network.target

[Service]
Type=oneshot
User=root
Group=root
ExecStart=/usr/local/bin/sysbackup --daily
StandardOutput=append:/var/log/capstone/backup/service.log
StandardError=append:/var/log/capstone/backup/service.log

# Performance
Nice=10
IOSchedulingClass=idle

# Security
NoNewPrivileges=yes
PrivateTmp=yes
EOF
    
    # Backup timer
    cat > "$output_dir/sysbackup.timer" << EOF
[Unit]
Description=Daily System Backup Timer
Documentation=https://github.com/capstone/backup

[Timer]
OnCalendar=*-*-* 02:00:00
RandomizedDelaySec=1800
Persistent=true

[Install]
WantedBy=timers.target
EOF
    
    log_success "Systemd units: $output_dir/"
}

generate_logrotate_config() {
    local output_file="${OUTPUT_DIR}/logrotate.d/capstone"
    mkdir -p "$(dirname "$output_file")"
    
    log_info "Generare configurație logrotate..."
    
    cat > "$output_file" << EOF
# Logrotate configuration for CAPSTONE Projects
# Place in /etc/logrotate.d/capstone

/var/log/capstone/monitor/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 0640 root root
    sharedscripts
    postrotate
        systemctl reload sysmonitor 2>/dev/null || true
    endscript
}

/var/log/capstone/backup/*.log {
    weekly
    rotate 4
    compress
    delaycompress
    missingok
    notifempty
    create 0640 root root
}

/var/log/capstone/deployer/*.log {
    daily
    rotate 14
    compress
    delaycompress
    missingok
    notifempty
    create 0640 root root
    dateext
    dateformat -%Y%m%d
}
EOF
    
    log_success "Logrotate config: $output_file"
}

#-------------------------------------------------------------------------------
# MAIN
#-------------------------------------------------------------------------------

show_help() {
    cat << EOF
CAPSTONE Projects Config Generator v${VERSION}

Utilizare: $(basename "$0") [OPȚIUNI]

Opțiuni:
  --output-dir=DIR    Director output (implicit: $DEFAULT_OUTPUT_DIR)
  --project=NAME      Generează doar pentru proiect (monitor, backup, deployer)
  --interactive       Mod interactiv cu întrebări
  --all               Generează toate configurațiile
  --verbose           Mod verbose
  --help              Afișează acest ajutor

Exemple:
  ./generate_configs.sh                      # Toate configurațiile
  ./generate_configs.sh --project=monitor    # Doar Monitor
  ./generate_configs.sh --output-dir=/etc    # Output în /etc
  ./generate_configs.sh --interactive        # Mod interactiv
EOF
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --output-dir=*)
                OUTPUT_DIR="${1#*=}"
                shift
                ;;
            --project=*)
                PROJECT="${1#*=}"
                shift
                ;;
            --interactive|-i)
                INTERACTIVE=true
                shift
                ;;
            --all)
                PROJECT=""
                shift
                ;;
            --verbose|-v)
                VERBOSE=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                log_error "Opțiune necunoscută: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

main() {
    parse_args "$@"
    
    print_banner
    
    log_info "Output directory: $OUTPUT_DIR"
    
    # Creare director output
    mkdir -p "$OUTPUT_DIR"
    
    # Generare configurații
    case "$PROJECT" in
        monitor)
            generate_monitor_config
            ;;
        backup)
            generate_backup_config
            ;;
        deployer)
            generate_deployer_config
            ;;
        "")
            # Toate
            generate_monitor_config
            generate_backup_config
            generate_deployer_config
            generate_cron_examples
            generate_systemd_units
            generate_logrotate_config
            ;;
        *)
            log_error "Proiect necunoscut: $PROJECT"
            exit 1
            ;;
    esac
    
    echo ""
    log_success "Configurații generate în: $OUTPUT_DIR/"
    
    if [[ "$VERBOSE" == "true" ]]; then
        echo ""
        log_info "Fișiere create:"
        find "$OUTPUT_DIR" -type f | sort | while read -r f; do
            echo "  - $f"
        done
    fi
}

main "$@"
