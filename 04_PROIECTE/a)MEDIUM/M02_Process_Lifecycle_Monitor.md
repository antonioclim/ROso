# M02: Process Lifecycle Monitor

> **Nivel:** MEDIUM | **Timp estimat:** 25-35 ore | **Bonus K8s:** +10%

---

## Descriere

Tool avansat pentru monitorizarea ciclului de viață al proceselor: tracking complet de la pornire până la terminare, monitorizare resurse în timp real (CPU, memorie, I/O), vizualizare ierarhie procese și alertare la anomalii sau evenimente critice.

Sistemul oferă atât monitorizare interactivă în terminal (dashboard) cât și mod daemon pentru logging continuu și alertare automată când procesele monitorizate depășesc threshold-uri sau se opresc neașteptat.

---

## Obiective de Învățare

- Sistemul de fișiere /proc și informații despre procese
- Semnale și ciclul de viață al proceselor
- Monitorizare resurse (CPU, memorie, I/O)
- Vizualizare arbore de procese (ppid, children)
- Alertare și notificări în timp real
- Dashboard terminal cu ncurses/ANSI

---

## Cerințe Funcționale

### Obligatorii (pentru notă de trecere)

1. **Monitorizare procese specifice**
   - După PID exact
   - După nume proces (pgrep style)
   - După pattern regex în command line
   - Monitorizare multiplă simultan

2. **Tracking resurse**
   - CPU usage (% și timp total)
   - Memorie (RSS, VSZ, shared)
   - I/O (bytes read/written)
   - File descriptors deschise
   - Threads count

3. **Ierarhie procese**
   - Afișare arbore (parent → children)
   - Tracking fork/exec
   - Agregare resurse pe arbore

4. **Detecție evenimente**
   - Start proces nou
   - Stop/exit (cu exit code)
   - Crash (SIGSEGV, SIGABRT, etc.)
   - Restart (același nume, PID nou)

5. **Alerting**
   - La depășire threshold CPU/memorie
   - La evenimente (crash, stop)
   - Notificare desktop/email/webhook

6. **Istoric**
   - Log evenimente cu timestamp
   - Metrici periodice (sampling)
   - Export pentru analiză

7. **Dashboard terminal**
   - Vizualizare în timp real
   - Refresh configurabil
   - Grafice ASCII pentru trend

### Opționale (pentru punctaj complet)

8. **Auto-restart** - Repornire automată procese critice la crash
9. **Profiling** - Analiza pattern-uri de utilizare în timp
10. **Export Prometheus** - Metrici în format Prometheus
11. **Corelație** - Grupare procese relacionate (servicii)
12. **Resource limits** - Alertare bazată pe cgroups
13. **Web dashboard** - Interfață HTTP simplă

---

## Interfață CLI

```bash
./procmon.sh <command> [opțiuni]

Comenzi:
  watch <target>          Monitorizare interactivă
  daemon <target>         Rulare ca daemon (background)
  status [target]         Status rapid procese
  tree [pid]              Afișare arbore procese
  history [target]        Istoric evenimente
  alerts                  Gestionare alerte
  stop                    Oprește daemon-ul

Target (moduri de specificare):
  1234                    PID exact
  nginx                   Nume proces
  "python.*server"        Pattern regex
  @service:mysql          Toate procesele unui serviciu

Opțiuni monitorizare:
  -i, --interval SEC      Interval refresh (default: 2)
  -d, --duration MIN      Durată monitorizare (default: infinit)
  -c, --children          Include procesele copil
  -r, --recursive         Monitorizează și subprocesele noi

Opțiuni alertare:
  --cpu-alert N           Alertă când CPU > N%
  --mem-alert N           Alertă când memorie > N MB
  --fd-alert N            Alertă când FD count > N
  --on-exit CMD           Comandă la terminare proces
  --on-crash CMD          Comandă la crash
  --auto-restart          Repornire automată la crash

Opțiuni output:
  -l, --log FILE          Salvare log
  -o, --output FORMAT     Format: text|json|csv
  -q, --quiet             Fără output terminal
  -v, --verbose           Output detaliat

Exemple:
  ./procmon.sh watch nginx
  ./procmon.sh watch 1234 -i 1 --cpu-alert 80
  ./procmon.sh daemon mysql --auto-restart --on-crash "notify.sh"
  ./procmon.sh tree 1
  ./procmon.sh status "python.*"
  ./procmon.sh history nginx --since "1 hour ago"
```

---

## Exemple Output

### Dashboard Monitorizare

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    PROCESS LIFECYCLE MONITOR                                 ║
║                    Target: nginx (master + workers)                          ║
╚══════════════════════════════════════════════════════════════════════════════╝

MONITORED PROCESSES (4)
═══════════════════════════════════════════════════════════════════════════════

PID     PPID    USER     STATE   CPU%   MEM(MB)   I/O(KB/s)   FDs   CMD
─────────────────────────────────────────────────────────────────────────────────
1234    1       root     S       0.1    12.3      0/0         15    nginx: master
1235    1234    www-data S       2.3    45.6      125/45      128   nginx: worker
1236    1234    www-data S       1.8    44.2      118/42      125   nginx: worker
1237    1234    www-data S       2.1    46.1      132/48      130   nginx: worker

TOTALS:  CPU: 6.3%  |  Memory: 148.2 MB  |  I/O: 375/135 KB/s  |  FDs: 398

RESOURCE HISTORY (last 5 min)
═══════════════════════════════════════════════════════════════════════════════

CPU %:
  10│                    ▄▄                                        
   5│  ▄▄    ▄▄▄▄▄▄▄▄▄▄████▄▄▄▄▄▄▄▄▄▄    ▄▄▄▄                    
   0│▄████▄▄██████████████████████████▄▄██████▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
    └──────────────────────────────────────────────────────────────
     -5m                    -2.5m                    now

Memory MB:
 150│████████████████████████████████████████████████████████████████
 100│                                                                
  50│                                                                
    └──────────────────────────────────────────────────────────────

EVENTS (last hour)
═══════════════════════════════════════════════════════════════════════════════
  17:45:23  ✓ Worker 1237 started (PID: 1237)
  17:45:23  ✓ Worker 1236 started (PID: 1236)
  17:45:23  ✓ Worker 1235 started (PID: 1235)
  17:45:22  ✓ Master process started (PID: 1234)
  17:30:00  ⚠ Config reload triggered
  17:15:45  ✗ Worker crashed (PID: 1238, SIGSEGV) - auto-restarted

ALERTS
═══════════════════════════════════════════════════════════════════════════════
  ⚠ Active: 0  |  Triggered today: 3  |  Last: 17:15:45 (worker crash)

───────────────────────────────────────────────────────────────────────────────
Refresh: 2s | Uptime: 4h 32m | Press 'q' to quit, 'h' for help
```

### Arbore Procese

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    PROCESS TREE                                              ║
║                    Root: PID 1234 (nginx)                                    ║
╚══════════════════════════════════════════════════════════════════════════════╝

nginx (1234) [root] S 0.1% CPU, 12.3 MB
├── nginx: worker (1235) [www-data] S 2.3% CPU, 45.6 MB
│   └── (128 file descriptors)
├── nginx: worker (1236) [www-data] S 1.8% CPU, 44.2 MB
│   └── (125 file descriptors)
├── nginx: worker (1237) [www-data] S 2.1% CPU, 46.1 MB
│   └── (130 file descriptors)
└── nginx: cache manager (1238) [www-data] S 0.0% CPU, 8.4 MB
    └── (12 file descriptors)

TREE SUMMARY
═══════════════════════════════════════════════════════════════════════════════
  Total processes:  5
  Total threads:    23
  Total CPU:        6.3%
  Total Memory:     156.6 MB
  Total FDs:        395
  
  Deepest level:    2
  Widest level:     4 (level 1)
```

### Status Rapid

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    PROCESS STATUS: mysql                                     ║
╚══════════════════════════════════════════════════════════════════════════════╝

SUMMARY
═══════════════════════════════════════════════════════════════════════════════
  Process:          mysqld
  PID:              2345
  Status:           Running (S - sleeping)
  Uptime:           15d 4h 23m
  Started:          2025-01-05 12:30:00
  User:             mysql
  Nice:             0

CURRENT RESOURCES
═══════════════════════════════════════════════════════════════════════════════
  CPU Usage:        12.3% (user: 10.1%, sys: 2.2%)
  Memory RSS:       1,234 MB
  Memory VSZ:       2,456 MB
  Memory %:         15.2% of system
  Threads:          45
  File Descriptors: 234 / 65536 (0.4%)
  
  I/O Read:         45.2 MB/s
  I/O Write:        12.3 MB/s
  Network:          2.1 MB/s in, 1.8 MB/s out

LIMITS
═══════════════════════════════════════════════════════════════════════════════
  Max FDs:          65536
  Max Memory:       unlimited
  Max CPU:          unlimited
  OOM Score:        0 (protected)

HEALTH CHECK: ✓ HEALTHY
  All metrics within normal range
```

### Istoric Evenimente

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    EVENT HISTORY: nginx                                      ║
║                    Period: last 24 hours                                     ║
╚══════════════════════════════════════════════════════════════════════════════╝

2025-01-20 17:45:23  ✓ START    Master process started (PID: 1234)
2025-01-20 17:45:23  ✓ START    Worker spawned (PID: 1235, parent: 1234)
2025-01-20 17:45:23  ✓ START    Worker spawned (PID: 1236, parent: 1234)
2025-01-20 17:45:23  ✓ START    Worker spawned (PID: 1237, parent: 1234)
2025-01-20 17:30:00  ℹ CONFIG   Reload signal received (SIGHUP)
2025-01-20 17:15:45  ✗ CRASH    Worker crashed (PID: 1238)
                                Signal: SIGSEGV (Segmentation fault)
                                Core dump: /var/crash/nginx.1238.core
2025-01-20 17:15:46  ✓ RESTART  Worker auto-restarted (new PID: 1237)
2025-01-20 15:00:00  ⚠ ALERT    CPU threshold exceeded (85% > 80%)
2025-01-20 15:00:30  ℹ RECOVER  CPU returned to normal (45%)
2025-01-20 12:00:00  ✓ START    Service started after system boot

STATISTICS
═══════════════════════════════════════════════════════════════════════════════
  Total events:     12
  Starts:           5
  Stops:            0
  Crashes:          1
  Restarts:         1
  Alerts:           2
  Config reloads:   1
```

---

## Fișier Configurare

```yaml
# /etc/procmon/procmon.conf

# Setări generale
general:
  log_file: /var/log/procmon.log
  pid_file: /var/run/procmon.pid
  data_dir: /var/lib/procmon
  
# Setări monitorizare
monitoring:
  default_interval: 2        # secunde
  history_retention: 7       # zile
  sample_rate: 60            # secunde între samples pentru istoric
  
# Procese de monitorizat (pentru daemon mode)
targets:
  - name: nginx
    pattern: "nginx"
    children: true
    alerts:
      cpu: 80
      memory: 512    # MB
      fd: 1000
    actions:
      on_crash: "/opt/scripts/notify.sh nginx crash"
      auto_restart: false
      
  - name: mysql
    pattern: "mysqld"
    alerts:
      cpu: 90
      memory: 4096
    actions:
      on_crash: "/opt/scripts/notify.sh mysql crash"
      auto_restart: true
      restart_cmd: "systemctl restart mysql"
      restart_delay: 5
      max_restarts: 3

# Alertare
alerting:
  email:
    enabled: false
    to: admin@example.com
    smtp_server: localhost
  desktop:
    enabled: true
  webhook:
    enabled: false
    url: ""

# Dashboard
dashboard:
  refresh_rate: 2
  show_graphs: true
  graph_history: 300   # secunde
```

---

## Structură Proiect

```
M02_Process_Lifecycle_Monitor/
├── README.md
├── Makefile
├── src/
│   ├── procmon.sh               # Script principal
│   └── lib/
│       ├── config.sh            # Parsare configurare
│       ├── process.sh           # Funcții citire /proc
│       ├── monitor.sh           # Logică monitorizare
│       ├── tree.sh              # Construire arbore
│       ├── events.sh            # Detectare evenimente
│       ├── alerts.sh            # Sistem alertare
│       ├── dashboard.sh         # UI terminal
│       ├── history.sh           # Istoric și logging
│       └── actions.sh           # Auto-restart, comenzi
├── etc/
│   └── procmon.conf.example
├── tests/
│   ├── test_process.sh
│   ├── test_monitor.sh
│   └── test_tree.sh
└── docs/
    ├── INSTALL.md
    └── ALERTS.md
```

---

## Hints Implementare

### Citire informații proces din /proc

```bash
#!/bin/bash
set -euo pipefail

get_process_info() {
    local pid="$1"
    local proc_dir="/proc/$pid"
    
    # Verifică dacă procesul există
    [[ -d "$proc_dir" ]] || return 1
    
    # Status general
    local status_file="$proc_dir/status"
    local name state ppid uid threads vmrss
    
    name=$(awk '/^Name:/ {print $2}' "$status_file")
    state=$(awk '/^State:/ {print $2}' "$status_file")
    ppid=$(awk '/^PPid:/ {print $2}' "$status_file")
    uid=$(awk '/^Uid:/ {print $2}' "$status_file")
    threads=$(awk '/^Threads:/ {print $2}' "$status_file")
    vmrss=$(awk '/^VmRSS:/ {print $2}' "$status_file")  # în KB
    
    # CPU time din /proc/[pid]/stat
    local stat_fields
    IFS=' ' read -ra stat_fields < "$proc_dir/stat"
    local utime="${stat_fields[13]}"
    local stime="${stat_fields[14]}"
    local starttime="${stat_fields[21]}"
    
    # File descriptors
    local fd_count
    fd_count=$(ls -1 "$proc_dir/fd" 2>/dev/null | wc -l)
    
    # Command line
    local cmdline
    cmdline=$(tr '\0' ' ' < "$proc_dir/cmdline" 2>/dev/null)
    
    # Output
    printf "%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s\n" \
        "$pid" "$name" "$state" "$ppid" "$uid" \
        "$threads" "${vmrss:-0}" "$utime" "$stime" \
        "$fd_count" "$cmdline"
}

# Calcul CPU usage
calculate_cpu_usage() {
    local pid="$1"
    local interval="${2:-1}"
    
    # Prima citire
    local stat1
    IFS=' ' read -ra stat1 < "/proc/$pid/stat"
    local utime1="${stat1[13]}"
    local stime1="${stat1[14]}"
    
    # Total CPU time
    local total1
    total1=$(awk '{sum=0; for(i=1;i<=NF;i++) sum+=$i; print sum}' /proc/stat | head -1)
    
    sleep "$interval"
    
    # A doua citire
    local stat2
    IFS=' ' read -ra stat2 < "/proc/$pid/stat"
    local utime2="${stat2[13]}"
    local stime2="${stat2[14]}"
    local total2
    total2=$(awk '{sum=0; for(i=1;i<=NF;i++) sum+=$i; print sum}' /proc/stat | head -1)
    
    # Calcul
    local proc_diff=$((utime2 - utime1 + stime2 - stime1))
    local total_diff=$((total2 - total1))
    
    if ((total_diff > 0)); then
        echo "scale=2; $proc_diff * 100 / $total_diff" | bc
    else
        echo "0"
    fi
}
```

### Construire arbore procese

```bash
build_process_tree() {
    local root_pid="${1:-1}"
    
    declare -A children
    declare -A proc_info
    
    # Colectează toate procesele
    for pid_dir in /proc/[0-9]*/; do
        local pid="${pid_dir#/proc/}"
        pid="${pid%/}"
        
        [[ -f "/proc/$pid/status" ]] || continue
        
        local ppid
        ppid=$(awk '/^PPid:/ {print $2}' "/proc/$pid/status")
        
        # Adaugă la lista de copii a părintelui
        children[$ppid]+="$pid "
        
        # Salvează info proces
        proc_info[$pid]=$(get_process_info "$pid")
    done
    
    # Funcție recursivă pentru afișare
    print_tree() {
        local pid="$1"
        local prefix="$2"
        local is_last="$3"
        
        local info="${proc_info[$pid]}"
        [[ -n "$info" ]] || return
        
        local name state cpu mem
        IFS='|' read -r _ name state _ _ _ mem _ _ _ _ <<< "$info"
        
        # Afișează nodul curent
        local connector="├──"
        [[ "$is_last" == "true" ]] && connector="└──"
        
        printf "%s%s %s (%s) [%s] %s MB\n" \
            "$prefix" "$connector" "$name" "$pid" "$state" "$((mem / 1024))"
        
        # Procesează copiii
        local child_pids="${children[$pid]}"
        local child_array=($child_pids)
        local child_count=${#child_array[@]}
        local i=0
        
        for child in "${child_array[@]}"; do
            ((i++))
            local child_prefix="$prefix"
            [[ "$is_last" == "true" ]] && child_prefix+="    " || child_prefix+="│   "
            
            local child_is_last="false"
            ((i == child_count)) && child_is_last="true"
            
            print_tree "$child" "$child_prefix" "$child_is_last"
        done
    }
    
    print_tree "$root_pid" "" "true"
}
```

### Detectare evenimente

```bash
declare -A KNOWN_PROCESSES

monitor_events() {
    local target_pattern="$1"
    
    while true; do
        # Găsește procesele care match-uiesc
        local current_pids
        current_pids=$(pgrep -f "$target_pattern" 2>/dev/null || true)
        
        for pid in $current_pids; do
            if [[ -z "${KNOWN_PROCESSES[$pid]:-}" ]]; then
                # Proces nou detectat
                local info
                info=$(get_process_info "$pid")
                KNOWN_PROCESSES[$pid]="$info"
                log_event "START" "$pid" "$info"
            fi
        done
        
        # Verifică procesele cunoscute
        for pid in "${!KNOWN_PROCESSES[@]}"; do
            if [[ ! -d "/proc/$pid" ]]; then
                # Procesul s-a terminat
                local exit_info
                exit_info=$(get_exit_info "$pid")
                log_event "EXIT" "$pid" "$exit_info"
                
                # Verifică dacă a fost crash
                if is_crash "$exit_info"; then
                    log_event "CRASH" "$pid" "$exit_info"
                    handle_crash "$pid" "${KNOWN_PROCESSES[$pid]}"
                fi
                
                unset "KNOWN_PROCESSES[$pid]"
            fi
        done
        
        sleep 1
    done
}

is_crash() {
    local exit_info="$1"
    # Semnale care indică crash
    local crash_signals="SIGSEGV SIGABRT SIGBUS SIGFPE SIGILL"
    
    for sig in $crash_signals; do
        [[ "$exit_info" == *"$sig"* ]] && return 0
    done
    return 1
}
```

### Dashboard terminal

```bash
draw_dashboard() {
    local pids=("$@")
    
    # Șterge ecranul
    clear
    
    # Header
    printf "╔══════════════════════════════════════════════════════════════════════════════╗\n"
    printf "║                    PROCESS LIFECYCLE MONITOR                                 ║\n"
    printf "╚══════════════════════════════════════════════════════════════════════════════╝\n\n"
    
    # Tabel procese
    printf "%-8s %-8s %-10s %-6s %-6s %-10s %-8s %s\n" \
        "PID" "PPID" "USER" "STATE" "CPU%" "MEM(MB)" "FDs" "CMD"
    printf "%s\n" "$(printf '─%.0s' {1..78})"
    
    for pid in "${pids[@]}"; do
        local info
        info=$(get_process_info "$pid") || continue
        
        IFS='|' read -r p_pid name state ppid uid threads mem utime stime fds cmd <<< "$info"
        
        local cpu
        cpu=$(calculate_cpu_usage "$pid" 0.1)
        local mem_mb=$((mem / 1024))
        local user
        user=$(id -un "$uid" 2>/dev/null || echo "$uid")
        
        printf "%-8s %-8s %-10s %-6s %-6s %-10s %-8s %s\n" \
            "$p_pid" "$ppid" "$user" "$state" "$cpu" "$mem_mb" "$fds" "${cmd:0:30}"
    done
    
    # Footer
    printf "\n%s\n" "$(printf '─%.0s' {1..78})"
    printf "Refresh: %ds | Press 'q' to quit\n" "$INTERVAL"
}
```

---

## Criterii Evaluare Specifice

| Criteriu | Pondere | Descriere |
|----------|---------|-----------|
| Monitorizare procese | 20% | PID, nume, pattern, corect |
| Tracking resurse | 20% | CPU, mem, I/O, FDs |
| Ierarhie procese | 15% | Arbore, children, agregare |
| Detecție evenimente | 15% | Start, stop, crash |
| Alerting | 10% | Thresholds, notificări |
| Dashboard | 10% | UI clar, refresh |
| Calitate cod + teste | 5% | ShellCheck, modularitate |
| Documentație | 5% | README complet |

---

## Resurse

- `man proc` - Sistemul de fișiere /proc
- `man ps`, `man top`, `man pgrep`
- `/proc/[pid]/status`, `/proc/[pid]/stat`
- Seminar 2-3 - Procese, semnale

---

*Proiect MEDIUM | Sisteme de Operare | ASE-CSIE*
