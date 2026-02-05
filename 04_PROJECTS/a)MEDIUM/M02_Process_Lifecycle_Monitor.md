# M02: Monitor Ciclu Viață Procese

> **Nivel:** MEDIUM | **Timp estimat:** 25-35 ore | **Bonus K8s:** +10%

---

## Descriere

Instrument avansat pentru monitorizarea ciclului de viață al proceselor: urmărire completă de la start la terminare, monitorizare în timp real a resurselor (CPU, memorie, I/O), vizualizare ierarhie procese și alertare la anomalii sau evenimente critice.

Sistemul oferă atât monitorizare interactivă în terminal (dashboard) cât și mod daemon pentru logging continuu și alertare automată când procesele monitorizate depășesc pragurile sau se opresc neașteptat.

---

## Obiective de Învățare

- Sistemul de fișiere /proc și informații procese
- Semnale și ciclu de viață procese
- Monitorizare resurse (CPU, memorie, I/O)
- Vizualizare arbore procese (ppid, copii)
- Alertare în timp real și notificări
- Dashboard terminal cu ncurses/ANSI

---

## Cerințe Funcționale

### Obligatorii (pentru nota de trecere)

1. **Monitorizare procese specifice**
   - După PID exact
   - După nume proces (stil pgrep)
   - După pattern regex în linie comandă
   - Monitorizare multiplă simultană

2. **Urmărire resurse**
   - Utilizare CPU (% și timp total)
   - Memorie (RSS, VSZ, shared)
   - I/O (bytes citite/scrise)
   - Descriptori fișiere deschise
   - Număr thread-uri

3. **Ierarhie procese**
   - Afișare arbore (părinte → copii)
   - Urmărire fork/exec
   - Agregare resurse pe arbore

4. **Detectare evenimente**
   - Start proces nou
   - Stop/exit (cu cod ieșire)
   - Crash (SIGSEGV, SIGABRT, etc.)
   - Restart (același nume, PID nou)

5. **Alertare**
   - La depășire prag CPU/memorie
   - La evenimente (crash, stop)
   - Notificare desktop/email/webhook

6. **Istoric**
   - Jurnal evenimente cu timestamp
   - Metrici periodice (sampling)
   - Export pentru analiză

7. **Dashboard terminal**
   - Vizualizare în timp real
   - Refresh configurabil
   - Grafice ASCII pentru tendințe

### Opționale (pentru punctaj complet)

8. **Auto-restart** - Restart automat procese critice la crash
9. **Profiling** - Analiză pattern-uri utilizare în timp
10. **Export Prometheus** - Metrici în format Prometheus
11. **Corelare** - Grupare procese înrudite (servicii)
12. **Limite resurse** - Alertare bazată pe cgroups
13. **Dashboard web** - Interfață HTTP simplă

---

## Interfață CLI

```bash
./procmon.sh <command> [options]

Commands:
  watch <target>          Interactive monitoring
  daemon <target>         Run as daemon (background)
  status [target]         Quick process status
  tree [pid]              Display process tree
  history [target]        Event history
  alerts                  Manage alerts
  stop                    Stop the daemon

Target (specification modes):
  1234                    Exact PID
  nginx                   Process name
  "python.*server"        Regex pattern
  @service:mysql          All processes of a service

Monitoring options:
  -i, --interval SEC      Refresh interval (default: 2)
  -d, --duration MIN      Monitoring duration (default: infinite)
  -c, --children          Include child processes
  -r, --recursive         Monitor new subprocesses too

Alerting options:
  --cpu-alert N           Alert when CPU > N%
  --mem-alert N           Alert when memory > N MB
  --fd-alert N            Alert when FD count > N
  --on-exit CMD           Command on process termination
  --on-crash CMD          Command on crash
  --auto-restart          Automatic restart on crash

Output options:
  -l, --log FILE          Save log
  -o, --output FORMAT     Format: text|json|csv
  -q, --quiet             No terminal output
  -v, --verbose           Detailed output

Examples:
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
║                    MONITOR CICLU VIAȚĂ PROCESE                               ║
║                    Țintă: nginx (master + workers)                           ║
╚══════════════════════════════════════════════════════════════════════════════╝

PROCESE MONITORIZATE (4)
═══════════════════════════════════════════════════════════════════════════════

PID     PPID    USER     STARE   CPU%   MEM(MB)   I/O(KB/s)   FDs   CMD
─────────────────────────────────────────────────────────────────────────────────
1234    1       root     S       0.1    12.3      0/0         15    nginx: master
1235    1234    www-data S       2.3    45.6      125/45      128   nginx: worker
1236    1234    www-data S       1.8    44.2      118/42      125   nginx: worker
1237    1234    www-data S       2.1    46.1      132/48      130   nginx: worker

TOTALURI:  CPU: 6.3%  |  Memorie: 148.2 MB  |  I/O: 375/135 KB/s  |  FDs: 398

ISTORIC RESURSE (ultimele 5 min)
═══════════════════════════════════════════════════════════════════════════════

CPU %:
  10│                    ▄▄                                        
   5│  ▄▄    ▄▄▄▄▄▄▄▄▄▄████▄▄▄▄▄▄▄▄▄▄    ▄▄▄▄                    
   0│▄████▄▄██████████████████████████▄▄██████▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
    └──────────────────────────────────────────────────────────────
     -5m                    -2.5m                    acum

Memorie MB:
 150│████████████████████████████████████████████████████████████████
 100│                                                                
  50│                                                                
    └──────────────────────────────────────────────────────────────

EVENIMENTE (ultima oră)
═══════════════════════════════════════════════════════════════════════════════
  17:45:23  ✓ Worker 1237 pornit (PID: 1237)
  17:45:23  ✓ Worker 1236 pornit (PID: 1236)
  17:45:23  ✓ Worker 1235 pornit (PID: 1235)
  17:45:22  ✓ Proces master pornit (PID: 1234)
  17:30:00  ⚠ Reload configurație declanșat
  17:15:45  ✗ Worker crashed (PID: 1238, SIGSEGV) - restartat automat

ALERTE
═══════════════════════════════════════════════════════════════════════════════
  ⚠ Active: 0  |  Declanșate astăzi: 3  |  Ultima: 17:15:45 (worker crash)

───────────────────────────────────────────────────────────────────────────────
Refresh: 2s | Uptime: 4h 32m | Apasă 'q' pentru ieșire, 'h' pentru ajutor
```

### Arbore Procese

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    ARBORE PROCESE                                            ║
║                    Rădăcină: PID 1234 (nginx)                                ║
╚══════════════════════════════════════════════════════════════════════════════╝

nginx (1234) [root] S 0.1% CPU, 12.3 MB
├── nginx: worker (1235) [www-data] S 2.3% CPU, 45.6 MB
│   └── (128 descriptori fișiere)
├── nginx: worker (1236) [www-data] S 1.8% CPU, 44.2 MB
│   └── (125 descriptori fișiere)
├── nginx: worker (1237) [www-data] S 2.1% CPU, 46.1 MB
│   └── (130 descriptori fișiere)
└── nginx: cache manager (1238) [www-data] S 0.0% CPU, 8.4 MB
    └── (12 descriptori fișiere)

REZUMAT ARBORE
═══════════════════════════════════════════════════════════════════════════════
  Total procese:  5
  Total thread-uri: 23
  Total CPU:      6.3%
  Total Memorie:  156.6 MB
  Total FDs:      395
  
  Nivel cel mai adânc:  2
  Nivel cel mai larg:   4 (nivel 1)
```

### Status Rapid

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    STATUS PROCES: mysql                                      ║
╚══════════════════════════════════════════════════════════════════════════════╝

REZUMAT
═══════════════════════════════════════════════════════════════════════════════
  Proces:           mysqld
  PID:              2345
  Status:           Rulând (S - sleeping)
  Uptime:           15z 4h 23m
  Pornit:           2025-01-05 12:30:00
  Utilizator:       mysql
  Nice:             0

RESURSE CURENTE
═══════════════════════════════════════════════════════════════════════════════
  Utilizare CPU:    12.3% (user: 10.1%, sys: 2.2%)
  Memorie RSS:      1,234 MB
  Memorie VSZ:      2,456 MB
  Memorie %:        15.2% din sistem
  Thread-uri:       45
  Descriptori Fișiere: 234 / 65536 (0.4%)
  
  I/O Citire:       45.2 MB/s
  I/O Scriere:      12.3 MB/s
  Rețea:            2.1 MB/s in, 1.8 MB/s out

LIMITE
═══════════════════════════════════════════════════════════════════════════════
  Max FDs:          65536
  Max Memorie:      nelimitat
  Max CPU:          nelimitat
  OOM Score:        0 (protejat)

VERIFICARE SĂNĂTATE: ✓ SĂNĂTOS
  Toate metricile în interval normal
```

### Istoric Evenimente

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    ISTORIC EVENIMENTE: nginx                                 ║
║                    Perioadă: ultimele 24 ore                                 ║
╚══════════════════════════════════════════════════════════════════════════════╝

2025-01-20 17:45:23  ✓ START    Proces master pornit (PID: 1234)
2025-01-20 17:45:23  ✓ START    Worker generat (PID: 1235, părinte: 1234)
2025-01-20 17:45:23  ✓ START    Worker generat (PID: 1236, părinte: 1234)
2025-01-20 17:45:23  ✓ START    Worker generat (PID: 1237, părinte: 1234)
2025-01-20 17:30:00  ℹ CONFIG   Semnal reload primit (SIGHUP)
2025-01-20 17:15:45  ✗ CRASH    Worker crashed (PID: 1238)
                                Semnal: SIGSEGV (Segmentation fault)
                                Core dump: /var/crash/nginx.1238.core
2025-01-20 17:15:46  ✓ RESTART  Worker restartat automat (PID nou: 1237)
2025-01-20 15:00:00  ⚠ ALERT    Prag CPU depășit (85% > 80%)
2025-01-20 15:00:30  ℹ RECOVER  CPU revenit la normal (45%)
2025-01-20 12:00:00  ✓ START    Serviciu pornit după boot sistem

STATISTICI
═══════════════════════════════════════════════════════════════════════════════
  Total evenimente: 12
  Porniri:          5
  Opriri:           0
  Crash-uri:        1
  Restart-uri:      1
  Alerte:           2
  Reload-uri config: 1
```

---

## Fișier Configurație

```yaml
# /etc/procmon/procmon.conf

# General settings
general:
  log_file: /var/log/procmon.log
  pid_file: /var/run/procmon.pid
  data_dir: /var/lib/procmon
  
# Monitoring settings
monitoring:
  default_interval: 2        # seconds
  history_retention: 7       # days
  sample_rate: 60            # seconds between samples for history
  
# Processes to monitor (for daemon mode)
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

# Alerting
alerting:
  email:
    enabled: false
    to: [adresă eliminată]
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
  graph_history: 300   # seconds
```

---

## Structură Proiect

```
M02_Process_Lifecycle_Monitor/
├── README.md
├── Makefile
├── src/
│   ├── procmon.sh               # Main script
│   └── lib/
│       ├── config.sh            # Configuration parsing
│       ├── process.sh           # /proc reading functions
│       ├── monitor.sh           # Monitoring logic
│       ├── tree.sh              # Tree building
│       ├── events.sh            # Event detection
│       ├── alerts.sh            # Alerting system
│       ├── dashboard.sh         # Terminal UI
│       ├── history.sh           # History and logging
│       └── actions.sh           # Auto-restart, commands
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

## Indicii de Implementare

### Citire informații proces din /proc

```bash
#!/bin/bash
set -euo pipefail

get_process_info() {
    local pid="$1"
    local proc_dir="/proc/$pid"
    
    # Check if process exists
    [[ -d "$proc_dir" ]] || return 1
    
    # General status
    local status_file="$proc_dir/status"
    local name state ppid uid threads vmrss
    
    name=$(awk '/^Name:/ {print $2}' "$status_file")
    state=$(awk '/^State:/ {print $2}' "$status_file")
    ppid=$(awk '/^PPid:/ {print $2}' "$status_file")
    uid=$(awk '/^Uid:/ {print $2}' "$status_file")
    threads=$(awk '/^Threads:/ {print $2}' "$status_file")
    vmrss=$(awk '/^VmRSS:/ {print $2}' "$status_file")  # in KB
    
    # CPU time from /proc/[pid]/stat
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

# Calculate CPU usage
calculate_cpu_usage() {
    local pid="$1"
    local interval="${2:-1}"
    
    # First reading
    local stat1
    IFS=' ' read -ra stat1 < "/proc/$pid/stat"
    local utime1="${stat1[13]}"
    local stime1="${stat1[14]}"
    
    # Total CPU time
    local total1
    total1=$(awk '{sum=0; for(i=1;i<=NF;i++) sum+=$i; print sum}' /proc/stat | head -1)
    
    sleep "$interval"
    
    # Second reading
    local stat2
    IFS=' ' read -ra stat2 < "/proc/$pid/stat"
    local utime2="${stat2[13]}"
    local stime2="${stat2[14]}"
    local total2
    total2=$(awk '{sum=0; for(i=1;i<=NF;i++) sum+=$i; print sum}' /proc/stat | head -1)
    
    # Calculation
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
    
    # Collect all processes
    for pid_dir in /proc/[0-9]*/; do
        local pid="${pid_dir#/proc/}"
        pid="${pid%/}"
        
        [[ -f "/proc/$pid/status" ]] || continue
        
        local ppid
        ppid=$(awk '/^PPid:/ {print $2}' "/proc/$pid/status")
        
        # Add to parent's children list
        children[$ppid]+="$pid "
        
        # Save process info
        proc_info[$pid]=$(get_process_info "$pid")
    done
    
    # Recursive function for display
    print_tree() {
        local pid="$1"
        local prefix="$2"
        local is_last="$3"
        
        local info="${proc_info[$pid]}"
        [[ -n "$info" ]] || return
        
        local name state cpu mem
        IFS='|' read -r _ name state _ _ _ mem _ _ _ _ <<< "$info"
        
        # Display current node
        local connector="├──"
        [[ "$is_last" == "true" ]] && connector="└──"
        
        printf "%s%s %s (%s) [%s] %s MB\n" \
            "$prefix" "$connector" "$name" "$pid" "$state" "$((mem / 1024))"
        
        # Process children
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
        # Find processes matching pattern
        local current_pids
        current_pids=$(pgrep -f "$target_pattern" 2>/dev/null || true)
        
        for pid in $current_pids; do
            if [[ -z "${KNOWN_PROCESSES[$pid]:-}" ]]; then
                # New process detected
                local info
                info=$(get_process_info "$pid")
                KNOWN_PROCESSES[$pid]="$info"
                log_event "START" "$pid" "$info"
            fi
        done
        
        # Check known processes
        for pid in "${!KNOWN_PROCESSES[@]}"; do
            if [[ ! -d "/proc/$pid" ]]; then
                # Process has terminated
                local exit_info
                exit_info=$(get_exit_info "$pid")
                log_event "EXIT" "$pid" "$exit_info"
                
                # Check if it was a crash
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
    # Signals indicating crash
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
    
    # Clear screen
    clear
    
    # Header
    printf "╔══════════════════════════════════════════════════════════════════════════════╗\n"
    printf "║                    MONITOR CICLU VIAȚĂ PROCESE                               ║\n"
    printf "╚══════════════════════════════════════════════════════════════════════════════╝\n\n"
    
    # Process table
    printf "%-8s %-8s %-10s %-6s %-6s %-10s %-8s %s\n" \
        "PID" "PPID" "USER" "STARE" "CPU%" "MEM(MB)" "FDs" "CMD"
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
    printf "Refresh: %ds | Apasă 'q' pentru ieșire\n" "$INTERVAL"
}
```

---

## Criterii Specifice de Evaluare

| Criteriu | Pondere | Descriere |
|-----------|--------|-------------|
| Monitorizare procese | 20% | PID, nume, pattern, corect |
| Urmărire resurse | 20% | CPU, mem, I/O, FDs |
| Ierarhie procese | 15% | Arbore, copii, agregare |
| Detectare evenimente | 15% | Start, stop, crash |
| Alertare | 10% | Praguri, notificări |
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
