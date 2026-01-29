# M13: Log Aggregator

> **Nivel:** MEDIUM | **Timp estimat:** 25-35 ore | **Bonus K8s:** +10%

---

## Descriere

Sistem centralizat de agregare, parsare și analiză log-uri din multiple surse: fișiere locale, syslog, journald și aplicații. Include filtrare avansată, alertare pe pattern-uri și dashboard pentru vizualizare.

---

## Obiective de Învățare

- Formaturi de log (syslog, JSON, Apache, nginx)
- Parsare și normalizare log-uri
- Streaming și procesare în timp real
- Pattern matching și alertare
- Indexare și căutare eficientă

---

## Cerințe Funcționale

### Obligatorii (pentru notă de trecere)

1. **Colectare log-uri**
   - Din fișiere (tail -f style)
   - Din journald (journalctl)
   - Din syslog (socket sau fișier)
   - Multiple surse simultan

2. **Parsare și normalizare**
   - Auto-detectare format (syslog, JSON, Apache, nginx)
   - Extragere câmpuri (timestamp, level, source, message)
   - Normalizare timestamp la format comun

3. **Filtrare și căutare**
   - După nivel (ERROR, WARN, INFO, DEBUG)
   - După sursă/serviciu
   - După interval de timp
   - Regex pe mesaj

4. **Alertare**
   - Pattern-uri configurabile (ex: "error", "failed")
   - Rate alerts (>N erori în M minute)
   - Notificări (desktop, email)

5. **Vizualizare**
   - Dashboard terminal cu statistici
   - Live tail cu highlighting
   - Histogramă erori în timp

### Opționale (pentru punctaj complet)

6. **Stocare indexată** - SQLite pentru căutare rapidă
7. **Agregare statistici** - Count per level/source/hour
8. **Correlation** - Corelează evenimente între servicii
9. **Export** - Elastic-compatible JSON, CSV
10. **Web interface** - Simple HTTP pentru vizualizare

---

## Interfață CLI

```bash
./logagg.sh <command> [opțiuni]

Comenzi:
  collect               Pornește colectarea (daemon)
  tail [source]         Live tail cu formatting
  search <query>        Caută în log-uri
  stats [period]        Afișează statistici
  dashboard             Dashboard interactiv
  alert                 Gestionare reguli alertare
  export                Exportă log-uri

Opțiuni:
  -s, --source SOURCE   Sursă: file:/path|journald|syslog (repeatable)
  -l, --level LEVEL     Nivel minim: debug|info|warn|error
  -S, --service SVC     Filtrează după serviciu
  -f, --follow          Follow mode (ca tail -f)
  -n, --lines N         Ultimele N linii
  -t, --time RANGE      Interval: "1h"|"today"|"2025-01-20"
  -g, --grep PATTERN    Filtrare regex
  -o, --output FILE     Salvează output
  --format FMT          Format output: text|json|csv
  --no-color            Fără culori

Exemple:
  ./logagg.sh collect -s file:/var/log/syslog -s journald
  ./logagg.sh tail --level error --follow
  ./logagg.sh search "connection refused" -t "1h"
  ./logagg.sh stats today --service nginx
  ./logagg.sh alert add --pattern "OOM" --action email
```

---

## Exemple Output

### Dashboard

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    LOG AGGREGATOR DASHBOARD                                  ║
║                    Sources: 5 | Events/min: 234                             ║
╚══════════════════════════════════════════════════════════════════════════════╝

LAST HOUR OVERVIEW
═══════════════════════════════════════════════════════════════════════════════

Events by Level:
  ERROR   ████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  156 (2.3%)
  WARN    ████████████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  423 (6.2%)
  INFO    ████████████████████████████████████████████████░░  5,892 (86.5%)
  DEBUG   ████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  342 (5.0%)

Events Timeline (last hour):
  300│        ▄▄    ▄▄▄▄
  200│  ▄▄   ████  ██████   ▄▄
  100│▄████▄██████████████▄████▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
     └────────────────────────────────────────────────────────
      16:00  16:15  16:30  16:45  17:00  17:15  17:30  17:45

TOP SOURCES (by events)
───────────────────────────────────────────────────────────────────────────────
  nginx           2,345 events    12 errors    ████████████████████
  postgresql      1,234 events     3 errors    ██████████████
  myapp             892 events    45 errors    █████████
  sshd              456 events     2 errors    █████
  systemd           234 events     0 errors    ███

RECENT ERRORS
───────────────────────────────────────────────────────────────────────────────
  17:45:23  myapp      Connection refused to redis:6379
  17:44:56  myapp      Timeout waiting for database response
  17:42:12  nginx      upstream timed out (110: Connection timed out)
  17:40:05  postgres   could not open file "base/16384/1234": No such file

ACTIVE ALERTS
───────────────────────────────────────────────────────────────────────────────
  ⚠️  High error rate: myapp (45 errors in last hour, threshold: 20)
  🔴 Pattern match: "OOM" detected in journald at 17:30
```

### Live Tail

```
╔══════════════════════════════════════════════════════════════════════════════╗
║  LIVE LOG TAIL | Filter: level>=WARN | Sources: all                         ║
╚══════════════════════════════════════════════════════════════════════════════╝

17:45:23.456 [ERROR] myapp     Connection refused to redis:6379
                               Retry attempt 3/5, backing off 2s
17:45:25.789 [WARN]  nginx     upstream server temporarily disabled
17:45:26.123 [ERROR] myapp     Connection refused to redis:6379
                               Retry attempt 4/5, backing off 4s
17:45:28.456 [WARN]  postgres  checkpoints are occurring too frequently
17:45:30.789 [INFO]  myapp     Connection to redis restored
17:45:31.012 [WARN]  nginx     upstream server restored
17:46:00.000 [ERROR] sshd      Failed password for invalid user admin
                               from 192.168.1.100 port 54321

───────────────────────────────────────────────────────────────────────────────
Events: 1,234 | Errors: 23 | Filtered: 892 | Press 'q' to quit, '/' to search
```

### Search Results

```
╔══════════════════════════════════════════════════════════════════════════════╗
║  SEARCH: "connection refused" | Time: last 1 hour | Results: 23             ║
╚══════════════════════════════════════════════════════════════════════════════╝

Results grouped by source:

myapp (18 matches)
───────────────────────────────────────────────────────────────────────────────
  17:45:26 Connection refused to redis:6379
  17:45:23 Connection refused to redis:6379
  17:44:56 Connection refused to postgres:5432
  ... (15 more)

nginx (3 matches)
───────────────────────────────────────────────────────────────────────────────
  17:42:12 connect() failed (111: Connection refused) to upstream
  17:40:05 connect() failed (111: Connection refused) to upstream
  17:38:22 connect() failed (111: Connection refused) to upstream

postgresql (2 matches)
───────────────────────────────────────────────────────────────────────────────
  17:35:00 connection refused from 10.0.0.5
  17:30:00 connection refused from 10.0.0.5

Export: ./logagg.sh export --query "connection refused" -t 1h -o results.json
```

---

## Configurare

```yaml
# /etc/logagg/config.yaml
general:
  data_dir: /var/lib/logagg
  log_file: /var/log/logagg.log
  retention_days: 30

sources:
  - name: syslog
    type: file
    path: /var/log/syslog
    format: syslog
    
  - name: nginx-access
    type: file
    path: /var/log/nginx/access.log
    format: nginx_combined
    
  - name: nginx-error
    type: file
    path: /var/log/nginx/error.log
    format: nginx_error
    
  - name: journald
    type: journald
    units: [myapp, postgresql, redis]
    
  - name: app-json
    type: file
    path: /var/log/myapp/app.json
    format: json

parsers:
  syslog:
    pattern: '^(\w{3}\s+\d+\s+\d+:\d+:\d+)\s+(\S+)\s+(\S+?)(?:\[(\d+)\])?:\s+(.*)$'
    fields: [timestamp, host, service, pid, message]
    
  nginx_combined:
    pattern: '^(\S+)\s+\S+\s+(\S+)\s+\[([^\]]+)\]\s+"([^"]+)"\s+(\d+)\s+(\d+)'
    fields: [ip, user, timestamp, request, status, bytes]

alerts:
  - name: high_error_rate
    condition: "count(level=error) > 20 per 1h"
    action: [email, desktop]
    
  - name: oom_detected
    pattern: "OOM|Out of memory"
    action: [email, slack]
    severity: critical
```

---

## Structură Proiect

```
M13_Log_Aggregator/
├── README.md
├── Makefile
├── src/
│   ├── logagg.sh                # Script principal
│   └── lib/
│       ├── collector.sh         # Colectare din surse
│       ├── parser.sh            # Parsare și normalizare
│       ├── filter.sh            # Filtrare și căutare
│       ├── alert.sh             # Sistem alertare
│       ├── dashboard.sh         # UI terminal
│       ├── storage.sh           # Stocare SQLite
│       └── export.sh            # Export date
├── etc/
│   ├── config.yaml
│   └── parsers/
│       ├── syslog.conf
│       ├── nginx.conf
│       └── json.conf
├── tests/
│   ├── test_parser.sh
│   ├── test_filter.sh
│   └── sample_logs/
└── docs/
    ├── INSTALL.md
    ├── PARSERS.md
    └── ALERTS.md
```

---

## Hints Implementare

### Tail multiple fișiere

```bash
tail_multiple_files() {
    local files=("$@")
    
    # Folosind tail cu --follow=name pentru rotație
    tail -F "${files[@]}" 2>/dev/null | while read -r line; do
        # Determină sursa din prefixul adăugat de tail
        local source file
        if [[ "$line" =~ ^==\>\ (.+)\ \<== ]]; then
            file="${BASH_REMATCH[1]}"
            continue
        fi
        
        process_log_line "$file" "$line"
    done
}

# Alternativ: parallel tails
tail_parallel() {
    local pids=()
    
    for source in "${SOURCES[@]}"; do
        tail -F "$source" | while read -r line; do
            echo "$source|$line"
        done &
        pids+=($!)
    done
    
    # Cleanup la exit
    trap 'kill "${pids[@]}" 2>/dev/null' EXIT
    wait
}
```

### Parsare syslog

```bash
parse_syslog() {
    local line="$1"
    
    # Format: Jan 20 17:45:23 hostname service[pid]: message
    local regex='^([A-Z][a-z]{2}[[:space:]]+[0-9]+[[:space:]]+[0-9:]+)[[:space:]]+([^[:space:]]+)[[:space:]]+([^[:space:]\[]+)(\[[0-9]+\])?:[[:space:]]+(.*)'
    
    if [[ "$line" =~ $regex ]]; then
        local timestamp="${BASH_REMATCH[1]}"
        local host="${BASH_REMATCH[2]}"
        local service="${BASH_REMATCH[3]}"
        local pid="${BASH_REMATCH[4]//[\[\]]/}"
        local message="${BASH_REMATCH[5]}"
        
        # Detectează level din mesaj
        local level="INFO"
        case "$message" in
            *[Ee]rror*|*ERROR*|*[Ff]ail*) level="ERROR" ;;
            *[Ww]arn*|*WARNING*) level="WARN" ;;
            *[Dd]ebug*|*DEBUG*) level="DEBUG" ;;
        esac
        
        echo "$timestamp|$host|$service|$pid|$level|$message"
    fi
}
```

### Citire din journald

```bash
read_journald() {
    local units=("$@")
    local since="${SINCE:-1h ago}"
    
    local unit_args=()
    for unit in "${units[@]}"; do
        unit_args+=(-u "$unit")
    done
    
    journalctl "${unit_args[@]}" --since "$since" \
        -o json --no-pager | while read -r json_line; do
        
        # Parsează JSON
        local timestamp service message priority
        timestamp=$(echo "$json_line" | jq -r '.__REALTIME_TIMESTAMP // empty')
        service=$(echo "$json_line" | jq -r '.SYSLOG_IDENTIFIER // ._SYSTEMD_UNIT // "unknown"')
        message=$(echo "$json_line" | jq -r '.MESSAGE // empty')
        priority=$(echo "$json_line" | jq -r '.PRIORITY // "6"')
        
        # Convertește priority la level
        local level
        case "$priority" in
            0|1|2) level="CRIT" ;;
            3)     level="ERROR" ;;
            4)     level="WARN" ;;
            5|6)   level="INFO" ;;
            7)     level="DEBUG" ;;
        esac
        
        echo "$timestamp|localhost|$service||$level|$message"
    done
}
```

### Alertare pe pattern

```bash
check_alert_patterns() {
    local line="$1"
    local source="$2"
    
    # Încarcă regulile de alertare
    while IFS='|' read -r name pattern action; do
        if [[ "$line" =~ $pattern ]]; then
            trigger_alert "$name" "$source" "$line" "$action"
        fi
    done < "$ALERTS_FILE"
}

# Rate limiting pentru alerte
declare -A ALERT_COUNTS
declare -A ALERT_LAST

check_rate_alert() {
    local name="$1"
    local threshold="$2"
    local window="$3"  # secunde
    
    local now
    now=$(date +%s)
    
    # Curăță entries vechi
    local last="${ALERT_LAST[$name]:-0}"
    if ((now - last > window)); then
        ALERT_COUNTS[$name]=0
    fi
    
    ((ALERT_COUNTS[$name]++))
    ALERT_LAST[$name]=$now
    
    if ((ALERT_COUNTS[$name] >= threshold)); then
        trigger_alert "rate_$name" "" "Rate exceeded: ${ALERT_COUNTS[$name]} in ${window}s"
        ALERT_COUNTS[$name]=0
    fi
}
```

---

## Criterii Evaluare Specifice

| Criteriu | Pondere | Descriere |
|----------|---------|-----------|
| Colectare multi-sursă | 20% | Files, journald, parallel |
| Parsare & normalizare | 20% | Syslog, JSON, auto-detect |
| Filtrare & căutare | 15% | Level, time, regex |
| Alertare | 15% | Patterns, rate limits |
| Dashboard | 15% | Stats, timeline, live |
| Stocare/Export | 5% | SQLite, JSON export |
| Calitate cod + teste | 5% | ShellCheck, teste |
| Documentație | 5% | README, parsers doc |

---

## Resurse

- `man tail`, `man journalctl`
- Syslog RFC 5424
- Seminar 4 - Text processing, regex

---

*Proiect MEDIUM | Sisteme de Operare | ASE-CSIE*
