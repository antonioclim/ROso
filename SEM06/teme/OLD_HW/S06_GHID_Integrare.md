# S06_GHID - Ghid de Integrare CAPSTONE

> **Sisteme de Operare** | ASE București - CSIE  
> Material de laborator - Seminar 6 (NOU - Redistribuit)

---

> 🚨 **ÎNAINTE DE A ÎNCEPE TEMA**
>
> 1. Descarcă și configurează pachetul `002HWinit` (vezi GHID_STUDENT_RO.md)
> 2. Deschide un terminal și navighează în `~/HOMEWORKS`
> 3. Pornește înregistrarea cu:
>    ```bash
>    python3 record_homework_tui_RO.py
>    ```
>    sau varianta Bash:
>    ```bash
>    ./record_homework_RO.sh
>    ```
> 4. Completează datele cerute (nume, grupă, nr. temă)
> 5. **ABIA APOI** începe să rezolvi cerințele de mai jos

---


## Introducere

Acest ghid explică cum cele trei proiecte CAPSTONE (Monitor, Backup, Deployer) se integrează pentru a forma un sistem complet de administrare.

---

## 1. Arhitectura Integrată

### 1.1 Diagrama de Ansamblu

```
┌─────────────────────────────────────────────────────────────────┐
│                    SISTEM INTEGRAT CAPSTONE                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   ┌─────────────┐    ┌─────────────┐    ┌─────────────┐        │
│   │   MONITOR   │    │   BACKUP    │    │  DEPLOYER   │        │
│   │             │    │             │    │             │        │
│   │ • CPU/MEM   │    │ • Full      │    │ • Deploy    │        │
│   │ • Disk      │◄──►│ • Incremental│◄──►│ • Rollback  │        │
│   │ • Services  │    │ • Rotație   │    │ • Hooks     │        │
│   │ • Alerts    │    │ • Verificare│    │ • Health    │        │
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
│              │  Automatizare  │                                 │
│              └────────────────┘                                 │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 1.2 Fluxul de Date

```
1. MONITOR detectează probleme
         ↓
2. Trimite alerte
         ↓
3. Poate declanșa BACKUP preventiv
         ↓
4. DEPLOYER face rollback automat (dacă configurat)
         ↓
5. MONITOR verifică că sistemul e stabil
```

---

## 2. Componente și Responsabilități

### 2.1 Monitor (HW01)

**Responsabilități:**
- Monitorizare resurse sistem (CPU, memorie, disk)
- Verificare servicii critice
- Generare alerte când se depășesc threshold-uri
- Logging periodic al stării sistemului

**Output-uri:**
- Fișiere de log
- Alerte (email, Slack, etc.)
- Exit codes pentru integrare cu alte scripturi

**Integrare:**
```bash
# Declanșare backup când disk > 90%
monitor.sh --check disk --threshold 90 --on-alert "backup.sh create --type quick"
```

### 2.2 Backup (HW02)

**Responsabilități:**
- Creare backup-uri (full, incremental)
- Rotație automată a arhivelor vechi
- Verificare integritate backup-uri
- Restaurare date

**Output-uri:**
- Arhive comprimate (.tar.gz, .tar.xz)
- Manifest cu lista fișierelor
- Checksum pentru verificare

**Integrare:**
```bash
# Backup înainte de deploy
backup.sh create --source /var/www/app --tag "pre-deploy-$(date +%Y%m%d)"

# Restaurare pentru rollback
backup.sh restore --backup-id 20250127_153045 --dest /var/www/app
```

### 2.3 Deployer (HW03)

**Responsabilități:**
- Deployment aplicații cu zero-downtime
- Rollback la versiuni anterioare
- Execuție hook-uri pre/post deploy
- Health checks după deploy

**Output-uri:**
- Release-uri versionate
- Symlink "current" spre release activ
- Log-uri de deployment

**Integrare:**
```bash
# Deploy cu backup automat
deployer.sh deploy --source ./dist --pre-hook "backup.sh create"

# Rollback cu verificare
deployer.sh rollback --steps 1 --post-hook "monitor.sh --check all"
```

---

## 3. Structura de Directoare Comună

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
│   ├── config.sh          # Funcții comune de configurare
│   ├── utils.sh           # Utilitare generale
│   └── logging.sh         # Sistem unificat de logging
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

## 4. Bibliotecă Comună (lib/)

### 4.1 config.sh

```bash
#!/bin/bash
# lib/config.sh - Funcții comune de configurare

# Încarcă un fișier de configurare
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

# Obține valoare cu default
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
# lib/logging.sh - Sistem unificat de logging

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
# lib/utils.sh - Utilitare generale

# Verifică dacă o comandă există
require_cmd() {
    command -v "$1" >/dev/null 2>&1 || {
        log_fatal "Required command not found: $1"
    }
}

# Lock file pentru a preveni rularea simultană
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

### 5.1 Exemplu crontab

```bash
# /etc/cron.d/sysadmin

# Variabile de mediu
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
LOG_LEVEL=INFO

# Monitor: Verificare la fiecare 5 minute
*/5 * * * * root /opt/sysadmin/bin/sysmonitor --check all --quiet

# Backup: Daily la 2:00 AM
0 2 * * * root /opt/sysadmin/bin/sysbackup create --type daily

# Backup: Weekly (full) duminică la 3:00 AM
0 3 * * 0 root /opt/sysadmin/bin/sysbackup create --type full

# Cleanup: Lunar - șterge backup-uri vechi
0 4 1 * * root /opt/sysadmin/bin/sysbackup rotate --keep 30

# Log rotation: Daily
0 0 * * * root /usr/sbin/logrotate /etc/logrotate.d/sysadmin
```

### 5.2 Integrare Workflow

```bash
#!/bin/bash
# /opt/sysadmin/scripts/daily_maintenance.sh
# Rulează toate task-urile de mentenanță zilnică

set -euo pipefail
source /opt/sysadmin/lib/logging.sh
COMPONENT="MAINTENANCE"

log_info "Starting daily maintenance"

# 1. Verificare sistem
log_info "Running system checks..."
/opt/sysadmin/bin/sysmonitor --check all --report /var/log/daily_report.txt

# 2. Backup incremental
log_info "Creating incremental backup..."
/opt/sysadmin/bin/sysbackup create --type incremental

# 3. Cleanup
log_info "Cleaning up old data..."
/opt/sysadmin/bin/sysbackup rotate --keep 7
find /tmp -type f -mtime +7 -delete 2>/dev/null || true

# 4. Verificare deployment health
log_info "Checking deployment health..."
/opt/sysadmin/bin/sysdeploy status

log_info "Daily maintenance completed"
```

---

## 6. Scenarii de Utilizare

### 6.1 Deploy cu Backup și Verificare

```bash
#!/bin/bash
# deploy_safe.sh - Deploy cu toate verificările

set -euo pipefail

SOURCE="$1"
TAG="${2:-$(date +%Y%m%d_%H%M%S)}"

echo "=== Safe Deploy: $TAG ==="

# 1. Verificare pre-deploy
echo "1. Checking system health..."
sysmonitor --check all || { echo "System unhealthy, aborting"; exit 1; }

# 2. Backup înainte de deploy
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

### 6.2 Disaster Recovery

```bash
#!/bin/bash
# disaster_recovery.sh - Restaurare completă

set -euo pipefail

BACKUP_ID="${1:?Specify backup ID}"

echo "=== Disaster Recovery from $BACKUP_ID ==="

# 1. Verificare backup
echo "1. Verifying backup integrity..."
sysbackup verify --backup-id "$BACKUP_ID"

# 2. Restaurare
echo "2. Restoring data..."
sysbackup restore --backup-id "$BACKUP_ID" --dest /var/www/app

# 3. Redeploy
echo "3. Redeploying application..."
sysdeploy deploy --source /var/www/app --tag "recovery-$(date +%Y%m%d)"

# 4. Verificare
echo "4. Final health check..."
sysmonitor --check all

echo "=== Recovery completed ==="
```

---

## 7. Evaluare CAPSTONE

### 7.1 Criterii de Evaluare

| Criteriu | Punctaj | Descriere |
|----------|---------|-----------|
| Funcționalitate | 40% | Toate funcțiile implementate corect |
| Integrare | 20% | Cele 3 componente funcționează împreună |
| Robustețe | 15% | set -euo, trap, validări |
| Cod | 15% | Structură, comentarii, style |
| Documentație | 10% | README, usage, exemple |

### 7.2 Checklist Final

- [ ] Monitor: Verifică CPU, memorie, disk
- [ ] Monitor: Generează alerte
- [ ] Backup: Creează backup full și incremental
- [ ] Backup: Rotație și cleanup
- [ ] Deployer: Deploy cu zero-downtime
- [ ] Deployer: Rollback funcțional
- [ ] Integrare: Hook-uri între componente
- [ ] Automatizare: Cron jobs configurate
- [ ] Logging: Sistem unificat
- [ ] Teste: Cel puțin 3 teste per componentă

---

## 8. Resurse Suplimentare

- [Linux System Administration](https://www.tldp.org/LDP/sag/html/)
- [Bash Best Practices](https://mywiki.wooledge.org/BashGuide)
- [12 Factor App](https://12factor.net/)
- [Blue-Green Deployments](https://martinfowler.com/bliki/BlueGreenDeployment.html)

---

*Material nou creat pentru Redistribuirea Curriculară | Sisteme de Operare | ASE București - CSIE*

---

## 📤 Finalizare și Trimitere

După ce ai terminat toate cerințele:

1. **Oprește înregistrarea** tastând:
   ```bash
   STOP_tema
   ```
   sau apasă `Ctrl+D`

2. **Așteaptă** - scriptul va:
   - Genera semnătura criptografică
   - Încărca automat fișierul pe server

3. **Verifică mesajul final**:
   - ✅ `ÎNCĂRCARE REUȘITĂ!` - tema a fost trimisă
   - ❌ Dacă upload-ul eșuează, fișierul `.cast` este salvat local - trimite-l manual mai târziu cu comanda afișată

> ⚠️ **NU modifica fișierul `.cast`** după generare - semnătura devine invalidă!

---

*By Revolvix for OPERATING SYSTEMS class | restricted licence 2017-2030*
