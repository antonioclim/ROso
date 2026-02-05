# S06_GUIDE — Ghid de integrare CAPSTONE

> **Sisteme de Operare** | ASE București - CSIE  
> Material de laborator - Seminarul 6 (NOU - redistribuit)

---

> 🚨 **ÎNAINTE SĂ ÎNCEPEȚI TEMA**
>
> 1. Descărcați și configurați pachetul `002HWinit` (vedeți GHID_STUDENT_RO.md)
> 2. Deschideți un terminal și navigați la `~/HOMEWORKS`
> 3. Porniți înregistrarea cu:
>    ```bash
>    python3 record_homework_tui_RO.py
>    ```
>    sau varianta Bash:
>    ```bash
>    ./record_homework_RO.sh
>    ```
> 4. Completați datele cerute (nume, grupă, numărul temei)
> 5. **ABIA DUPĂ ACEEA** începeți rezolvarea cerințelor de mai jos

---


## Introducere

Acest ghid explică modul în care cele trei proiecte CAPSTONE (Monitor, Backup, Deployer) se integrează pentru a forma un sistem complet de administrare.

---

## 1. Arhitectură integrată

### 1.1 Diagramă de ansamblu

```
┌─────────────────────────────────────────────────────────────────┐
│                  CAPSTONE INTEGRATED SYSTEM                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   ┌─────────────┐    ┌─────────────┐    ┌─────────────┐        │
│   │   MONITOR   │    │   BACKUP    │    │  DEPLOYER   │        │
│   │             │    │             │    │             │        │
│   │ • CPU/MEM   │    │ • Full      │    │ • Deploy    │        │
│   │ • Disk      │◄──►│ • Incremental│◄──►│ • Rollback  │        │
│   │ • Services  │    │ • Rotation  │    │ • Hooks     │        │
│   │ • Alerts    │    │ • Verify    │    │ • Health    │        │
│   └──────┬──────┘    └──────┬──────┘    └──────┬──────┘        │
│          │                  │                  │                │
│          └────────────┬─────┴──────────────────┘                │
│                       │                                         │
│                       ▼                                         │
│              ┌────────────────┐                                 │
│              │  SHARED LIBS   │                                 │
│              │  • config.sh   │                                 │
│              │  • utils.sh    │                                 │
│              │  • logging.sh  │                                 │
│              └────────────────┘                                 │
│                       │                                         │
│                       ▼                                         │
│              ┌────────────────┐                                 │
│              │     CRON       │                                 │
│              │  Automation    │                                 │
│              └────────────────┘                                 │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 1.2 Flux de date

```
1. MONITOR detectează probleme
         ↓
2. Trimite alerte
         ↓
3. Poate declanșa BACKUP preventiv
         ↓
4. DEPLOYER execută rollback automat (dacă este configurat)
         ↓
5. MONITOR verifică dacă sistemul este stabil
```

---

## 2. Componente și responsabilități

### 2.1 Monitor (HW01)

**Responsabilități:**
- monitorizare resurse (CPU, memorie, disc)
- verificarea serviciilor critice
- generarea de alerte când pragurile sunt depășite
- jurnalizare periodică a stării sistemului

**Output:**
- fișiere de log
- alerte (email, Slack, și altele)
- coduri de ieșire pentru integrare cu alte scripturi

**Integrare:**
```bash
# Trigger backup when disk > 90%
monitor.sh --check disk --threshold 90 --on-alert "backup.sh create --type quick"
```

### 2.2 Backup (HW02)

**Responsabilități:**
- creare backup (full, incremental)
- rotație automată a arhivelor vechi
- verificare integritate backup
- restaurare date

**Output:**
- arhive comprimate (.tar.gz, .tar.xz)
- manifest cu lista fișierelor
- checksum pentru verificare

**Integrare:**
```bash
# Backup before deploy
backup.sh create --source /var/www/app --tag "pre-deploy-$(date +%Y%m%d)"

# Restore for rollback
backup.sh restore --backup-id 20250127_153045 --dest /var/www/app
```

### 2.3 Deployer (HW03)

**Responsabilități:**
- deployment de aplicație cu zero‑downtime
- rollback la versiuni anterioare
- execuție hook‑uri pre/post deploy
- health checks după deploy

**Output:**
- release‑uri versionate
- symlink "current" către release‑ul activ
- loguri de deployment

**Integrare:**
```bash
# Deploy with automatic backup
deployer.sh deploy --source ./dist --pre-hook "backup.sh create"

# Rollback with verification
deployer.sh rollback --steps 1 --post-hook "monitor.sh --check all"
```

---

## 3. Structură comună de directoare

```
/opt/sysadmin/
├── bin/
│   ├── sysmonitor         # → ../scripts/monitor/monitor.sh
│   ├── sysbackup          # → ../scripts/backup/backup.sh
│   └── sysdeploy          # → ../scripts/deployer/deployer.sh
│
├── etc/
│   ├── monitor.conf
│   ├── backup.conf
│   └── deployer.conf
│
├── lib/
│   ├── config.sh          # Common configuration functions
│   ├── utils.sh           # General utilities
│   └── logging.sh         # Unified logging system
│
├── scripts/
│   ├── monitor/
│   │   ├── monitor.sh
│   │   └── checks/
│   │       ├── cpu.sh
│   │       ├── memory.sh
│   │       └── disk.sh
│   │
│   ├── backup/
│   │   ├── backup.sh
│   │   └── strategies/
│   │       ├── full.sh
│   │       └── incremental.sh
│   │
│   └── deployer/
│       ├── deployer.sh
│       └── hooks/
│           ├── pre-deploy.sh
│           └── post-deploy.sh
│
├── var/
│   ├── log/
│   │   ├── monitor.log
│   │   ├── backup.log
│   │   └── deployer.log
│   │
│   └── run/
│       ├── monitor.pid
│       └── backup.lock
│
└── tests/
    ├── test_monitor.sh
    ├── test_backup.sh
    └── test_deployer.sh
```

---

## 4. Bibliotecă comună (lib/)

### 4.1 config.sh

```bash
#!/bin/bash
# lib/config.sh - Common configuration functions

# Load a configuration file
load_config() {
    local config_file="$1"

    [[ -f "$config_file" ]] || return 1

    while IFS='=' read -r key value; do
        [[ "$key" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$key" ]] && continue

        key=$(echo "$key" | tr -d ' ')
        value=$(echo "$value" | tr -d ' ')

        export "$key"="$value"
    done < "$config_file"
}

# Get value with default
get_config() {
    local key="$1"
    local default="${2:-}"

    local value
    eval "value=\${$key:-}"

    echo "${value:-$default}"
}
```

### 4.2 logging.sh

```bash
#!/bin/bash
# lib/logging.sh - Unified logging system

declare -A LOG_LEVELS=([DEBUG]=0 [INFO]=1 [WARN]=2 [ERROR]=3 [FATAL]=4)
LOG_LEVEL="${LOG_LEVEL:-INFO}"
LOG_FILE="${LOG_FILE:-/var/log/sysadmin.log}"

_log() {
    local level="$1"; shift
    local component="${COMPONENT:-SYSTEM}"

    local current="${LOG_LEVELS[$LOG_LEVEL]}"
    local msg_level="${LOG_LEVELS[$level]}"

    (( msg_level >= current )) || return 0

    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local msg="[$timestamp] [$component] [$level] $*"

    echo "$msg" >> "$LOG_FILE"

    if (( msg_level >= 2 )); then
        echo "$msg" >&2
    else
        echo "$msg"
    fi
}

log_debug() { _log DEBUG "$@"; }
log_info()  { _log INFO "$@"; }
log_warn()  { _log WARN "$@"; }
log_error() { _log ERROR "$@"; }
log_fatal() { _log FATAL "$@"; exit 1; }
```

### 4.3 utils.sh

```bash
#!/bin/bash
# lib/utils.sh - General utilities

# Check if a command exists
require_cmd() {
    command -v "$1" >/dev/null 2>&1 || {
        log_fatal "Required command not found: $1"
    }
}

# Lock file to prevent simultaneous execution
acquire_lock() {
    local lock_file="$1"

    if [[ -f "$lock_file" ]]; then
        local pid
        pid=$(cat "$lock_file")
        if kill -0 "$pid" 2>/dev/null; then
            log_error "Already running (PID $pid)"
            return 1
        fi
        log_warn "Removing stale lock file"
        rm -f "$lock_file"
    fi

    echo $$ > "$lock_file"
}

release_lock() {
    local lock_file="$1"
    rm -f "$lock_file"
}

# Human readable bytes
human_readable() {
    local bytes=$1

    if (( bytes >= 1073741824 )); then
        printf "%.2f GB" "$(echo "$bytes / 1073741824" | bc -l)"
    elif (( bytes >= 1048576 )); then
        printf "%.2f MB" "$(echo "$bytes / 1048576" | bc -l)"
    elif (( bytes >= 1024 )); then
        printf "%.2f KB" "$(echo "$bytes / 1024" | bc -l)"
    else
        printf "%d B" "$bytes"
    fi
}
```

---

## 5. Automatizare cu CRON

### 5.1 Exemplu de crontab

```bash
# /etc/cron.d/sysadmin

# Environment variables
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
LOG_LEVEL=INFO

# Monitor: Check every 5 minutes
*/5 * * * * root /opt/sysadmin/bin/sysmonitor --check all --quiet

# Backup: Daily at 2:00 AM
0 2 * * * root /opt/sysadmin/bin/sysbackup create --type daily

# Backup: Weekly (full) Sunday at 3:00 AM
0 3 * * 0 root /opt/sysadmin/bin/sysbackup create --type full

# Cleanup: Monthly - delete old backups
0 4 1 * * root /opt/sysadmin/bin/sysbackup rotate --keep 30

# Log rotation: Daily
0 0 * * * root /usr/sbin/logrotate /etc/logrotate.d/sysadmin
```

### 5.2 Integrare în workflow

```bash
#!/bin/bash
# /opt/sysadmin/scripts/daily_maintenance.sh
# Runs all daily maintenance tasks

set -euo pipefail
source /opt/sysadmin/lib/logging.sh
COMPONENT="MAINTENANCE"

log_info "Starting daily maintenance"

# 1. System verification
log_info "Running system checks..."
/opt/sysadmin/bin/sysmonitor --check all --report /var/log/daily_report.txt

# 2. Incremental backup
log_info "Creating incremental backup..."
/opt/sysadmin/bin/sysbackup create --type incremental

# 3. Cleanup
log_info "Cleaning up old data..."
/opt/sysadmin/bin/sysbackup rotate --keep 7
find /tmp -type f -mtime +7 -delete 2>/dev/null || true

# 4. Deployment health verification
log_info "Checking deployment health..."
/opt/sysadmin/bin/sysdeploy status

log_info "Daily maintenance completed"
```

---

## 6. Scenarii de utilizare

### 6.1 Deploy cu backup și verificare

```bash
#!/bin/bash
# deploy_safe.sh - Deploy with all verifications

set -euo pipefail

SOURCE="$1"
TAG="${2:-$(date +%Y%m%d_%H%M%S)}"

echo "=== Safe Deploy: $TAG ==="

# 1. Pre-deploy verification
echo "1. Checking system health..."
sysmonitor --check all || { echo "System unhealthy, aborting"; exit 1; }

# 2. Backup before deploy
echo "2. Creating pre-deploy backup..."
sysbackup create --tag "pre-deploy-$TAG" --source /var/www/app

# 3. Deploy
echo "3. Deploying..."
sysdeploy deploy --source "$SOURCE" --tag "$TAG"

# 4. Health check
echo "4. Verifying deployment..."
sleep 5
if ! sysmonitor --check services; then
    echo "Deployment failed health check, rolling back..."
    sysdeploy rollback --steps 1
    exit 1
fi

echo "=== Deploy $TAG completed successfully ==="
```

### 6.2 Recuperare în caz de dezastru

```bash
#!/bin/bash
# disaster_recovery.sh - Complete restoration

set -euo pipefail

BACKUP_ID="${1:?Specify backup ID}"

echo "=== Disaster Recovery from $BACKUP_ID ==="

# 1. Backup verification
echo "1. Verifying backup integrity..."
sysbackup verify --backup-id "$BACKUP_ID"

# 2. Restoration
echo "2. Restoring data..."
sysbackup restore --backup-id "$BACKUP_ID" --dest /var/www/app

# 3. Redeploy
echo "3. Redeploying application..."
sysdeploy deploy --source /var/www/app --tag "recovery-$(date +%Y%m%d)"

# 4. Verification
echo "4. Final health check..."
sysmonitor --check all

echo "=== Recovery completed ==="
```

---

## 7. Evaluare CAPSTONE

### 7.1 Criterii de evaluare

| Criteriu | Scor | Descriere |
|-----------|-------|-------------|
| Funcționalitate | 40% | Toate funcțiile implementate corect |
| Integrare | 20% | Toate cele 3 componente funcționează împreună |
| Robusteză | 15% | set -euo, trap, validări |
| Cod | 15% | Structură, comentarii, stil |
| Documentație | 10% | README, utilizare, exemple |

### 7.2 Checklist final

- [ ] Monitor: verifică CPU, memorie, disc
- [ ] Monitor: generează alerte
- [ ] Backup: creează backup full și incremental
- [ ] Backup: rotație și curățare
- [ ] Deployer: deploy cu zero‑downtime
- [ ] Deployer: rollback funcțional
- [ ] Integrare: hook‑uri între componente
- [ ] Automatizare: job‑uri cron configurate
- [ ] Logging: sistem unificat
- [ ] Teste: cel puțin 3 teste per componentă

---

## 8. Resurse suplimentare

- [Linux System Administration](https://www.tldp.org/LDP/sag/html/)
- [Bash Best Practices](https://mywiki.wooledge.org/BashGuide)
- [12 Factor App](https://12factor.net/)
- [Blue-Green Deployments](https://martinfowler.com/bliki/BlueGreenDeployment.html)

---

*Material nou creat pentru redistribuire curriculară | Sisteme de Operare | ASE București - CSIE*

---

## 📤 Finalizare și predare

După ce finalizați toate cerințele:

1. **Opriți înregistrarea** tastând:
   ```bash
   STOP_tema
   ```
   sau apăsați `Ctrl+D`

2. **Așteptați** — scriptul va:
   - genera semnătura criptografică;
   - încărca automat fișierul pe server.

3. **Verificați mesajul final**:
   - ✅ `UPLOAD SUCCESSFUL!` - tema a fost predată
   - ❌ dacă upload‑ul eșuează, fișierul `.cast` este salvat local — predați-l manual ulterior cu comanda afișată

> ⚠️ **Nu modificați fișierul `.cast`** după generare — semnătura devine invalidă!

---

*De Revolvix pentru cursul SISTEME DE OPERARE | licență restricționată 2017-2030*
