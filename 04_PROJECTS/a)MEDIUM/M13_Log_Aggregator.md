# M13: Agregator Log-uri

> **Nivel:** MEDIUM | **Timp estimat:** 25-35 ore | **Bonus K8s:** +10%

---

## Descriere

Sistem centralizat agregare, parsare și analiză log-uri din surse multiple: fișiere locale, syslog, journald și aplicații. Include filtrare avansată, alertare bazată pe pattern-uri și dashboard pentru vizualizare.

---

## Obiective de Învățare

- Formate log-uri (syslog, JSON, Apache, nginx)
- Parsare și normalizare log-uri
- Procesare streaming și timp real
- Pattern matching și alertare
- Indexare și căutare eficientă

---

## Cerințe Funcționale

### Obligatorii (pentru nota de trecere)

1. **Colectare log-uri**
   - Din fișiere (stil tail -f)
   - Din journald (journalctl)
   - Din syslog (socket sau fișier)
   - Surse multiple simultan

2. **Parsare și normalizare**
   - Auto-detect format (syslog, JSON, Apache, nginx)
   - Extragere câmpuri (timestamp, level, sursă, mesaj)
   - Normalizare timestamp la format comun

3. **Filtrare și căutare**
   - După nivel (ERROR, WARN, INFO, DEBUG)
   - După sursă/serviciu
   - După interval timp
   - Regex pe mesaj

4. **Alertare**
   - Pattern-uri configurabile (ex: "error", "failed")
   - Alerte rată (>N erori în M minute)
   - Notificări (desktop, email)

5. **Vizualizare**
   - Dashboard terminal cu statistici
   - Live tail cu highlighting
   - Histogramă erori în timp

### Opționale (pentru punctaj complet)

6. **Stocare indexată** - SQLite pentru căutare rapidă
7. **Agregare statistici** - Count per nivel/sursă/oră
8. **Corelare** - Corelare evenimente între servicii
9. **Export** - JSON compatibil Elastic, CSV
10. **Interfață web** - HTTP simplu pentru vizualizare

---

## Interfață CLI

```bash
./logagg.sh <command> [options]

Commands:
  collect               Start collection (daemon)
  tail [source]         Live tail with formatting
  search <query>        Search in logs
  stats [period]        Display statistics
  dashboard             Interactive dashboard
  alert                 Manage alerting rules
  export                Export logs

Options:
  -s, --source SOURCE   Source: file:/path|journald|syslog (repeatable)
  -l, --level LEVEL     Minimum level: debug|info|warn|error
  -S, --service SVC     Filter by service
  -f, --follow          Follow mode (like tail -f)
  -n, --lines N         Last N lines
  -t, --time RANGE      Interval: "1h"|"today"|"2025-01-20"
  -g, --grep PATTERN    Regex filtering
  -o, --output FILE     Save output
  --format FMT          Output format: text|json|csv
  --no-color            No colours

Examples:
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
║                    DASHBOARD AGREGATOR LOG-URI                               ║
║                    Surse: 5 | Evenimente/min: 234                           ║
╚══════════════════════════════════════════════════════════════════════════════╝

PRIVIRE ANSAMBLU ULTIMA ORĂ
═══════════════════════════════════════════════════════════════════════════════

Evenimente după Nivel:
  ERROR   ████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  156 (2.3%)
  WARN    ████████████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  423 (6.2%)
  INFO    ████████████████████████████████████████████████░░  5,892 (86.5%)
  DEBUG   ████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  342 (5.0%)

Timeline Evenimente (ultima oră):
  300│        ▄▄    ▄▄▄▄
  200│  ▄▄   ████  ██████   ▄▄
  100│▄████▄██████████████▄████▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
     └────────────────────────────────────────────────────────
      16:00  16:15  16:30  16:45  17:00  17:15  17:30  17:45

SURSE TOP (după evenimente)
───────────────────────────────────────────────────────────────────────────────
  nginx           2,345 evenimente    12 erori    ████████████████████
  postgresql      1,234 evenimente     3 erori    ██████████████
  myapp             892 evenimente    45 erori    █████████
  sshd              456 evenimente     2 erori    █████
  systemd           234 evenimente     0 erori    ███

ERORI RECENTE
───────────────────────────────────────────────────────────────────────────────
  17:45:23  myapp      Connection refused to redis:6379
  17:44:56  myapp      Timeout waiting for database response
  17:42:12  nginx      upstream timed out (110: Connection timed out)
  17:40:05  postgres   could not open file "base/16384/1234": No such file

ALERTE ACTIVE
───────────────────────────────────────────────────────────────────────────────
  ⚠️  Rată erori mare: myapp (45 erori în ultima oră, prag: 20)
  🔴 Potrivire pattern: "OOM" detectat în journald la 17:30
```

### Live Tail

```
╔══════════════════════════════════════════════════════════════════════════════╗
║  LIVE LOG TAIL | Filtru: level>=WARN | Surse: toate                         ║
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
Evenimente: 1,234 | Erori: 23 | Filtrate: 892 | Apasă 'q' pentru ieșire, '/' pentru căutare
```

### Rezultate Căutare

```
╔══════════════════════════════════════════════════════════════════════════════╗
║  CĂUTARE: "connection refused" | Timp: ultima 1 oră | Rezultate: 23         ║
╚══════════════════════════════════════════════════════════════════════════════╝

Rezultate grupate după sursă:

myapp (18 potriviri)
───────────────────────────────────────────────────────────────────────────────
  17:45:26 Connection refused to redis:6379
  17:45:23 Connection refused to redis:6379
  17:44:56 Connection refused to postgres:5432
  ··· (încă 15)

nginx (3 potriviri)
───────────────────────────────────────────────────────────────────────────────
  17:42:12 connect() failed (111: Connection refused) to upstream
  17:40:05 connect() failed (111: Connection refused) to upstream
  17:38:22 connect() failed (111: Connection refused) to upstream

postgresql (2 potriviri)
───────────────────────────────────────────────────────────────────────────────
  17:35:00 connection refused from 10.0.0.5
  17:30:00 connection refused from 10.0.0.5

Export: ./logagg.sh export --query "connection refused" -t 1h -o results.json
```

---

## Configurație

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
│   ├── logagg.sh                # Main script
│   └── lib/
│       ├── collector.sh         # Collection from sources
│       ├── parser.sh            # Parsing and normalisation
│       ├── filter.sh            # Filtering and searching
│       ├── alert.sh             # Alerting system
│       ├── dashboard.sh         # Terminal UI
│       ├── storage.sh           # SQLite storage
│       └── export.sh            # Data export
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

## Indicii de Implementare

### Tail fișiere multiple

```bash
tail_multiple_files() {
    local files=("$@")
    
    # Using tail with --follow=name for rotation
    tail -F "${files[@]}" 2>/dev/null | while read -r line; do
        # Determine source from prefix added by tail
        local source file
        if [[ "$line" =~ ^==\>\ (.+)\ \<== ]]; then
            file="${BASH_REMATCH[1]}"
            continue
        fi
        
        process_log_line "$file" "$line"
    done
}

# Alternative: parallel tails
tail_parallel() {
    local pids=()
    
    for source in "${SOURCES[@]}"; do
        tail -F "$source" | while read -r line; do
            echo "$source|$line"
        done &
        pids+=($!)
    done
    
    # Cleanup on exit
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
        
        # Detect level from message
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
        
        # Parse JSON
        local timestamp service message priority
        timestamp=$(echo "$json_line" | jq -r '.__REALTIME_TIMESTAMP // empty')
        service=$(echo "$json_line" | jq -r '.SYSLOG_IDENTIFIER // ._SYSTEMD_UNIT // "unknown"')
        message=$(echo "$json_line" | jq -r '.MESSAGE // empty')
        priority=$(echo "$json_line" | jq -r '.PRIORITY // "6"')
        
        # Convert priority to level
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

### Alertare pattern-uri

```bash
check_alert_patterns() {
    local line="$1"
    local source="$2"
    
    # Load alerting rules
    while IFS='|' read -r name pattern action; do
        if [[ "$line" =~ $pattern ]]; then
            trigger_alert "$name" "$source" "$line" "$action"
        fi
    done < "$ALERTS_FILE"
}

# Rate limiting for alerts
declare -A ALERT_COUNTS
declare -A ALERT_LAST

check_rate_alert() {
    local name="$1"
    local threshold="$2"
    local window="$3"  # seconds
    
    local now
    now=$(date +%s)
    
    # Clean old entries
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

## Criterii Specifice de Evaluare

| Criteriu | Pondere | Descriere |
|-----------|--------|-------------|
| Colectare multi-sursă | 20% | Fișiere, journald, paralel |
| Parsare & normalizare | 20% | Syslog, JSON, auto-detect |
| Filtrare & căutare | 15% | Nivel, timp, regex |
| Alertare | 15% | Pattern-uri, limite rată |
| Dashboard | 15% | Statistici, timeline, live |
| Stocare/Export | 5% | SQLite, export JSON |
| Calitate cod + teste | 5% | ShellCheck, teste |
| Documentație | 5% | README, doc parsers |

---

## Resurse

- `man tail`, `man journalctl`
- Syslog RFC 5424
- Seminar 4 - Procesare text, regex

---

*Proiect MEDIUM | Sisteme de Operare | ASE-CSIE*
