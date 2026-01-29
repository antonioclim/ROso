# M09: Scheduled Tasks Manager

> **Nivel:** MEDIUM | **Timp estimat:** 25-35 ore | **Bonus K8s:** +10%

---

## Descriere

Manager unificat pentru task-uri programate: interfață simplificată pentru cron și systemd timers, suport pentru task-uri one-shot și recurente, logging centralizat, notificări la succes/eșec și dashboard cu status și istoric.

---

## Obiective de Învățare

- Gestionare cron jobs (`crontab`, `/etc/cron.d/`)
- Systemd timers și services
- Validare expresii cron
- Logging și monitorizare execuție
- Notificări și alertare

---

## Cerințe Funcționale

### Obligatorii (pentru notă de trecere)

1. **Gestionare task-uri**
   - Adăugare/editare/ștergere task-uri
   - Suport expresii cron standard
   - Suport intervale simple (every 5min, daily at 3am)
   - Enable/disable fără ștergere

2. **Execuție și monitorizare**
   - Logging automat pentru fiecare execuție
   - Capturare stdout/stderr
   - Tracking exit code și durată
   - Run manual (trigger imediat)

3. **Backend dual**
   - Cron pentru compatibilitate
   - Systemd timers pentru features avansate
   - Conversie automată între formate

4. **Dashboard**
   - Lista task-uri cu status
   - Ultimele execuții per task
   - Task-uri failed

5. **Notificări**
   - Email la fail
   - Desktop notification
   - Configurabil per task

### Opționale (pentru punctaj complet)

6. **Dependency chains** - Task B rulează după Task A
7. **Resource limits** - CPU/memory limits per task
8. **Retry logic** - Reîncercare la eșec
9. **Web interface** - Simple HTTP dashboard
10. **Export/Import** - Backup și restore configurare

---

## Interfață CLI

```bash
./taskman.sh <command> [opțiuni]

Comenzi:
  list                  Listează toate task-urile
  add <name>            Adaugă task nou
  edit <name>           Editează task existent
  remove <name>         Șterge task
  enable <name>         Activează task
  disable <name>        Dezactivează task
  run <name>            Rulează task manual
  logs <name>           Afișează log-uri task
  status [name]         Status task sau toate
  dashboard             Afișează dashboard
  export                Exportă configurare
  import <file>         Importă configurare

Opțiuni:
  -s, --schedule EXPR   Expresie cron sau interval
  -c, --command CMD     Comanda de executat
  -u, --user USER       User sub care rulează
  -e, --env KEY=VAL     Variabile de mediu
  -t, --timeout SEC     Timeout execuție
  --backend TYPE        cron|systemd (default: auto)
  --notify CHANNEL      Notificare: email|desktop|slack
  --retry N             Număr reîncercări la fail
  -q, --quiet           Output minimal

Exemple:
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
║                    SCHEDULED TASKS MANAGER                                   ║
║                    Host: server01 | Tasks: 12 active                        ║
╚══════════════════════════════════════════════════════════════════════════════╝

TASK STATUS OVERVIEW
═══════════════════════════════════════════════════════════════════════════════
  ✅ Running:     0
  ✅ Succeeded:   10
  ❌ Failed:      2
  ⏸️  Disabled:    3

ACTIVE TASKS
═══════════════════════════════════════════════════════════════════════════════
┌─────────────────┬─────────────────────┬───────────┬─────────────┬───────────┐
│ Name            │ Schedule            │ Last Run  │ Status      │ Next Run  │
├─────────────────┼─────────────────────┼───────────┼─────────────┼───────────┤
│ backup-daily    │ 0 3 * * *           │ 03:00:12  │ ✅ OK (45s)  │ 03:00     │
│ log-rotate      │ 0 0 * * 0           │ Sun 00:00 │ ✅ OK (2s)   │ Sun 00:00 │
│ db-cleanup      │ */30 * * * *        │ 16:30:00  │ ❌ FAIL      │ 17:00     │
│ health-check    │ */5 * * * *         │ 16:55:00  │ ✅ OK (1s)   │ 17:00     │
│ report-gen      │ 0 8 * * 1-5         │ Mon 08:00 │ ✅ OK (120s) │ Tue 08:00 │
│ cache-clear     │ 0 */6 * * *         │ 12:00:00  │ ✅ OK (5s)   │ 18:00     │
│ sync-remote     │ 0 * * * *           │ 16:00:00  │ ❌ FAIL      │ 17:00     │
└─────────────────┴─────────────────────┴───────────┴─────────────┴───────────┘

DISABLED TASKS
═══════════════════════════════════════════════════════════════════════════════
  ⏸️  old-backup (disabled 2025-01-15)
  ⏸️  test-task (disabled 2025-01-18)
  ⏸️  migration (disabled 2025-01-19)

RECENT FAILURES
═══════════════════════════════════════════════════════════════════════════════
❌ db-cleanup (16:30:00)
   Exit code: 1
   Error: Connection refused to database
   Command: /opt/scripts/db_cleanup.sh
   Duration: 0.5s
   
❌ sync-remote (16:00:00)
   Exit code: 255
   Error: SSH connection timeout
   Command: rsync -avz /data/ remote:/backup/
   Duration: 30s (timeout)

UPCOMING (next 2 hours)
═══════════════════════════════════════════════════════════════════════════════
  17:00  health-check, db-cleanup, sync-remote
  17:05  health-check
  17:10  health-check
  ...
  18:00  cache-clear, health-check
```

### Task Detail

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    TASK: backup-daily                                        ║
╚══════════════════════════════════════════════════════════════════════════════╝

CONFIGURATION
───────────────────────────────────────────────────────────────────────────────
  Name:         backup-daily
  Command:      /opt/scripts/backup.sh --full
  Schedule:     0 3 * * * (Daily at 03:00)
  User:         root
  Backend:      systemd timer
  Status:       ✅ Enabled
  Timeout:      3600s
  Notify on:    failure

STATISTICS
───────────────────────────────────────────────────────────────────────────────
  Total runs:       45
  Successful:       43 (95.6%)
  Failed:           2
  Avg duration:     42s
  Last success:     2025-01-20 03:00:12 (45s)
  Last failure:     2025-01-15 03:00:00 (disk full)

RECENT EXECUTIONS
───────────────────────────────────────────────────────────────────────────────
  2025-01-20 03:00:12  ✅ OK      45s    exit 0
  2025-01-19 03:00:08  ✅ OK      43s    exit 0
  2025-01-18 03:00:15  ✅ OK      48s    exit 0
  2025-01-17 03:00:11  ✅ OK      41s    exit 0
  2025-01-16 03:00:09  ✅ OK      42s    exit 0

View full logs: ./taskman.sh logs backup-daily
```

---

## Fișier Configurare

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
    - email: admin@example.com
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
│   ├── taskman.sh               # Script principal
│   └── lib/
│       ├── cron.sh              # Backend cron
│       ├── systemd.sh           # Backend systemd
│       ├── scheduler.sh         # Parse schedule expressions
│       ├── executor.sh          # Execuție și logging
│       ├── notify.sh            # Notificări
│       └── dashboard.sh         # UI terminal
├── etc/
│   ├── taskman.conf             # Configurare globală
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

## Hints Implementare

### Parsare expresii schedule

```bash
parse_schedule() {
    local expr="$1"
    
    # Expresii simple
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
            # Presupunem cron expression valid
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
    
    # Validare simplificată
    # În practică, folosește o bibliotecă sau regex complex
    return 0
}
```

### Creare cron job

```bash
add_cron_job() {
    local name="$1"
    local schedule="$2"
    local command="$3"
    local user="${4:-$(whoami)}"
    
    local cron_file="/etc/cron.d/taskman-${name}"
    local log_file="/var/log/taskman/${name}.log"
    
    # Wrapper pentru logging
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

### Creare systemd timer

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
    
    # Conversie simplificată
    # Pentru conversie completă, vezi systemd.time(7)
    
    if [[ "$min" == "0" && "$hour" == "0" && "$dom" == "*" && "$mon" == "*" && "$dow" == "*" ]]; then
        echo "daily"
    elif [[ "$min" == "0" && "$hour" == "*" ]]; then
        echo "hourly"
    else
        # Format generic
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
    
    # Execută și capturează output
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
    
    # Salvează metadata ultimei rulări
    cat > "$run_file" << EOF
timestamp=$start_time
exit_code=$exit_code
duration=$duration
EOF
    
    # Notificare dacă a eșuat
    if [[ $exit_code -ne 0 ]]; then
        send_notification "$name" "FAILED" "Exit code: $exit_code"
    fi
    
    return $exit_code
}
```

---

## Criterii Evaluare Specifice

| Criteriu | Pondere | Descriere |
|----------|---------|-----------|
| CRUD task-uri | 20% | Add/edit/remove/enable/disable |
| Backend cron | 15% | Creare și gestionare cron jobs |
| Backend systemd | 15% | Creare timers și services |
| Logging | 15% | Capturare output, istoric |
| Dashboard | 15% | Status, failures, next runs |
| Notificări | 10% | Email/desktop la fail |
| Funcționalități extra | 5% | Dependencies, retry |
| Calitate cod + teste | 5% | ShellCheck, teste |

---

## Resurse

- `man 5 crontab` - Format cron
- `man systemd.timer` - Systemd timers
- `man systemd.time` - Calendar expressions
- Seminar 3 - Cron și programare

---

*Proiect MEDIUM | Sisteme de Operare | ASE-CSIE*
