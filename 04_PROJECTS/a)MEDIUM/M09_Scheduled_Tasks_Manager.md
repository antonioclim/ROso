# M09: Manager Task-uri Programate

> **Nivel:** MEDIUM | **Timp estimat:** 25-35 ore | **Bonus K8s:** +10%

---

## Descriere

Manager unificat pentru task-uri programate: interfață simplificată pentru cron și systemd timers, suport pentru task-uri one-shot și recurente, logging centralizat, notificări succes/eșec și dashboard cu status și istoric.

---

## Obiective de Învățare

- Gestionare job-uri cron (`crontab`, `/etc/cron.d/`)
- Timer-e și servicii systemd
- Validare expresii cron
- Logging și monitorizare execuție
- Notificări și alertare

---

## Cerințe Funcționale

### Obligatorii (pentru nota de trecere)

1. **Gestionare task-uri**
   - Adăugare/editare/ștergere task-uri
   - Suport expresii cron standard
   - Suport interval simplu (la fiecare 5min, zilnic la 3am)
   - Activare/dezactivare fără ștergere

2. **Execuție și monitorizare**
   - Logging automat pentru fiecare execuție
   - Capturare stdout/stderr
   - Urmărire exit code și durată
   - Rulare manuală (trigger imediat)

3. **Backend dual**
   - Cron pentru compatibilitate
   - Timer-e systemd pentru funcționalități avansate
   - Conversie automată între formate

4. **Dashboard**
   - Listă task-uri cu status
   - Execuții recente per task
   - Task-uri eșuate

5. **Notificări**
   - Email la eșec
   - Notificare desktop
   - Configurabil per task

### Opționale (pentru punctaj complet)

6. **Lanțuri dependențe** - Task B rulează după Task A
7. **Limite resurse** - Limite CPU/memorie per task
8. **Logică retry** - Retry la eșec
9. **Interfață web** - Dashboard HTTP simplu
10. **Export/Import** - Backup și restore configurație

---

## Interfață CLI

```bash
./taskman.sh <command> [options]

Commands:
  list                  List all tasks
  add <name>            Add new task
  edit <name>           Edit existing task
  remove <name>         Delete task
  enable <name>         Enable task
  disable <name>        Disable task
  run <name>            Run task manually
  logs <name>           Display task logs
  status [name]         Task status or all
  dashboard             Display dashboard
  export                Export configuration
  import <file>         Import configuration

Options:
  -s, --schedule EXPR   Cron expression or interval
  -c, --command CMD     Command to execute
  -u, --user USER       User to run as
  -e, --env KEY=VAL     Environment variables
  -t, --timeout SEC     Execution timeout
  --backend TYPE        cron|systemd (default: auto)
  --notify CHANNEL      Notification: email|desktop|slack
  --retry N             Number of retries on failure
  -q, --quiet           Minimal output

Examples:
  ./taskman.sh add backup --schedule "0 3 * * *" --command "/opt/backup.sh"
  ./taskman.sh add cleanup --schedule "every 6 hours" --command "cleanup.sh"
  ./taskman.sh status backup
  ./taskman.sh run backup
  ./taskman.sh logs backup --last 10
```

---

## Exemple Output

### Dashboard

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    MANAGER TASK-URI PROGRAMATE                               ║
║                    Host: server01 | Task-uri: 12 active                     ║
╚══════════════════════════════════════════════════════════════════════════════╝

PRIVIRE ANSAMBLU STATUS TASK-URI
═══════════════════════════════════════════════════════════════════════════════
  ✅ Rulează:     0
  ✅ Reușite:     10
  ❌ Eșuate:      2
  ⏸️  Dezactivate: 3

TASK-URI ACTIVE
═══════════════════════════════════════════════════════════════════════════════
┌─────────────────┬─────────────────────┬───────────┬─────────────┬───────────┐
│ Nume            │ Program             │ Ult Rul   │ Status      │ Urm Rul   │
├─────────────────┼─────────────────────┼───────────┼─────────────┼───────────┤
│ backup-daily    │ 0 3 * * *           │ 03:00:12  │ ✅ OK (45s)  │ 03:00     │
│ log-rotate      │ 0 0 * * 0           │ Dum 00:00 │ ✅ OK (2s)   │ Dum 00:00 │
│ db-cleanup      │ */30 * * * *        │ 16:30:00  │ ❌ FAIL      │ 17:00     │
│ health-check    │ */5 * * * *         │ 16:55:00  │ ✅ OK (1s)   │ 17:00     │
│ report-gen      │ 0 8 * * 1-5         │ Lun 08:00 │ ✅ OK (120s) │ Mar 08:00 │
│ cache-clear     │ 0 */6 * * *         │ 12:00:00  │ ✅ OK (5s)   │ 18:00     │
│ sync-remote     │ 0 * * * *           │ 16:00:00  │ ❌ FAIL      │ 17:00     │
└─────────────────┴─────────────────────┴───────────┴─────────────┴───────────┘

TASK-URI DEZACTIVATE
═══════════════════════════════════════════════════════════════════════════════
  ⏸️  old-backup (dezactivat 2025-01-15)
  ⏸️  test-task (dezactivat 2025-01-18)
  ⏸️  migration (dezactivat 2025-01-19)

EȘECURI RECENTE
═══════════════════════════════════════════════════════════════════════════════
❌ db-cleanup (16:30:00)
   Cod ieșire: 1
   Eroare: Connection refused to database
   Comandă: /opt/scripts/db_cleanup.sh
   Durată: 0.5s
   
❌ sync-remote (16:00:00)
   Cod ieșire: 255
   Eroare: SSH connection timeout
   Comandă: rsync -avz /data/ remote:/backup/
   Durată: 30s (timeout)

VIITOARE (următoarele 2 ore)
═══════════════════════════════════════════════════════════════════════════════
  17:00  health-check, db-cleanup, sync-remote
  17:05  health-check
  17:10  health-check
  ···
  18:00  cache-clear, health-check
```

### Detaliu Task

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    TASK: backup-daily                                        ║
╚══════════════════════════════════════════════════════════════════════════════╝

CONFIGURAȚIE
───────────────────────────────────────────────────────────────────────────────
  Nume:         backup-daily
  Comandă:      /opt/scripts/backup.sh --full
  Program:      0 3 * * * (Zilnic la 03:00)
  Utilizator:   root
  Backend:      systemd timer
  Status:       ✅ Activat
  Timeout:      3600s
  Notifică la:  eșec

STATISTICI
───────────────────────────────────────────────────────────────────────────────
  Total rulări:     45
  Reușite:          43 (95.6%)
  Eșuate:           2
  Durată medie:     42s
  Ultimul succes:   2025-01-20 03:00:12 (45s)
  Ultimul eșec:     2025-01-15 03:00:00 (disc plin)

EXECUȚII RECENTE
───────────────────────────────────────────────────────────────────────────────
  2025-01-20 03:00:12  ✅ OK      45s    exit 0
  2025-01-19 03:00:08  ✅ OK      43s    exit 0
  2025-01-18 03:00:15  ✅ OK      48s    exit 0
  2025-01-17 03:00:11  ✅ OK      41s    exit 0
  2025-01-16 03:00:09  ✅ OK      42s    exit 0

Vizualizare log-uri complete: ./taskman.sh logs backup-daily
```

---

## Fișier Configurație

```yaml
# /etc/taskman/tasks/backup-daily.yaml
name: backup-daily
description: Daily full backup to remote storage
command: /opt/scripts/backup.sh --full
schedule: "0 3 * * *"
user: root
backend: systemd

settings:
  timeout: 3600
  retry: 2
  retry_delay: 300
  
environment:
  BACKUP_DEST: /mnt/backup
  RETENTION_DAYS: 30
  
notify:
  on_failure:
    - email: [adresă eliminată]
    - slack: "#alerts"
  on_success: false
  
dependencies:
  after:
    - db-dump
```

---

## Structură Proiect

```
M09_Scheduled_Tasks_Manager/
├── README.md
├── Makefile
├── src/
│   ├── taskman.sh               # Main script
│   └── lib/
│       ├── cron.sh              # Cron backend
│       ├── systemd.sh           # Systemd backend
│       ├── scheduler.sh         # Parse schedule expressions
│       ├── executor.sh          # Execution and logging
│       ├── notify.sh            # Notifications
│       └── dashboard.sh         # Terminal UI
├── etc/
│   ├── taskman.conf             # Global configuration
│   └── tasks/                   # Task definitions
│       └── example.yaml
├── templates/
│   ├── systemd-service.tmpl
│   └── systemd-timer.tmpl
├── tests/
│   ├── test_scheduler.sh
│   ├── test_cron.sh
│   └── test_systemd.sh
└── docs/
    ├── INSTALL.md
    ├── SCHEDULE_SYNTAX.md
    └── BACKENDS.md
```

---

## Indicii de Implementare

### Parsare expresii program

```bash
parse_schedule() {
    local expr="$1"
    
    # Simple expressions
    case "$expr" in
        "every minute")     echo "* * * * *" ;;
        "every 5 minutes")  echo "*/5 * * * *" ;;
        "hourly")           echo "0 * * * *" ;;
        "daily")            echo "0 0 * * *" ;;
        "daily at "*)
            local time="${expr#daily at }"
            local hour="${time%:*}"
            local min="${time#*:}"
            echo "$min $hour * * *"
            ;;
        "weekly")           echo "0 0 * * 0" ;;
        *)
            # Assume valid cron expression
            if validate_cron "$expr"; then
                echo "$expr"
            else
                return 1
            fi
            ;;
    esac
}

validate_cron() {
    local expr="$1"
    local fields
    read -ra fields <<< "$expr"
    
    [[ ${#fields[@]} -eq 5 ]] || return 1
    
    # Simplified validation
    # In practice, use a library or complex regex
    return 0
}
```

### Creare job cron

```bash
add_cron_job() {
    local name="$1"
    local schedule="$2"
    local command="$3"
    local user="${4:-$(whoami)}"
    
    local cron_file="/etc/cron.d/taskman-${name}"
    local log_file="/var/log/taskman/${name}.log"
    
    # Wrapper for logging
    local wrapper_cmd="( $command ) >> $log_file 2>&1"
    
    cat > "$cron_file" << EOF
# Managed by taskman - do not edit manually
# Task: $name
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

$schedule $user $wrapper_cmd
EOF
    
    chmod 644 "$cron_file"
}

remove_cron_job() {
    local name="$1"
    rm -f "/etc/cron.d/taskman-${name}"
}
```

### Creare timer systemd

```bash
create_systemd_timer() {
    local name="$1"
    local schedule="$2"
    local command="$3"
    
    local service_file="/etc/systemd/system/taskman-${name}.service"
    local timer_file="/etc/systemd/system/taskman-${name}.timer"
    
    # Service unit
    cat > "$service_file" << EOF
[Unit]
Description=TaskMan: $name

[Service]
Type=oneshot
ExecStart=$command
StandardOutput=append:/var/log/taskman/${name}.log
StandardError=append:/var/log/taskman/${name}.log
EOF

    # Timer unit (convert cron to OnCalendar)
    local calendar
    calendar=$(cron_to_calendar "$schedule")
    
    cat > "$timer_file" << EOF
[Unit]
Description=TaskMan Timer: $name

[Timer]
OnCalendar=$calendar
Persistent=true

[Install]
WantedBy=timers.target
EOF

    systemctl daemon-reload
    systemctl enable "taskman-${name}.timer"
    systemctl start "taskman-${name}.timer"
}

cron_to_calendar() {
    local cron="$1"
    read -r min hour dom mon dow <<< "$cron"
    
    # Simplified conversion
    # For complete conversion, see systemd.time(7)
    
    if [[ "$min" == "0" && "$hour" == "0" && "$dom" == "*" && "$mon" == "*" && "$dow" == "*" ]]; then
        echo "daily"
    elif [[ "$min" == "0" && "$hour" == "*" ]]; then
        echo "hourly"
    else
        # Generic format
        echo "*-*-* ${hour}:${min}:00"
    fi
}
```

### Logging execuție

```bash
run_task_with_logging() {
    local name="$1"
    local command="$2"
    
    local log_dir="/var/log/taskman"
    local log_file="${log_dir}/${name}.log"
    local run_file="${log_dir}/${name}.last"
    
    mkdir -p "$log_dir"
    
    local start_time
    start_time=$(date +%s)
    
    echo "=== Run started: $(date) ===" >> "$log_file"
    
    # Execute and capture output
    local exit_code
    set +e
    ( eval "$command" ) >> "$log_file" 2>&1
    exit_code=$?
    set -e
    
    local end_time duration
    end_time=$(date +%s)
    duration=$((end_time - start_time))
    
    echo "=== Run finished: exit=$exit_code duration=${duration}s ===" >> "$log_file"
    echo "" >> "$log_file"
    
    # Save last run metadata
    cat > "$run_file" << EOF
timestamp=$start_time
exit_code=$exit_code
duration=$duration
EOF
    
    # Notification if failed
    if [[ $exit_code -ne 0 ]]; then
        send_notification "$name" "FAILED" "Exit code: $exit_code"
    fi
    
    return $exit_code
}
```

---

## Criterii Specifice de Evaluare

| Criteriu | Pondere | Descriere |
|-----------|--------|-------------|
| CRUD task-uri | 20% | Add/edit/remove/enable/disable |
| Backend cron | 15% | Creare și gestionare job-uri cron |
| Backend systemd | 15% | Creare timer-e și servicii |
| Logging | 15% | Capturare output, istoric |
| Dashboard | 15% | Status, eșecuri, rulări viitoare |
| Notificări | 10% | Email/desktop la eșec |
| Funcționalități extra | 5% | Dependențe, retry |
| Calitate cod + teste | 5% | ShellCheck, teste |

---

## Resurse

- `man 5 crontab` - Format cron
- `man systemd.timer` - Timer-e systemd
- `man systemd.time` - Expresii calendar
- Seminar 3 - Cron și programare

---

*Proiect MEDIUM | Sisteme de Operare | ASE-CSIE*
