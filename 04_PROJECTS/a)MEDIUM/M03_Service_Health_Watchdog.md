# M03: Watchdog Sănătate Servicii

> **Nivel:** MEDIUM | **Timp estimat:** 25-35 ore | **Bonus K8s:** +10%

---

## Descriere

Sistem de monitorizare continuă pentru servicii (unități systemd, procese, porturi) cu alertare automată, restart automat configurabil și dashboard terminal. Ideal pentru administrare servere de producție.

---

## Obiective de Învățare

- Interacțiune cu systemd (`systemctl`, `journalctl`)
- Monitorizare procese și porturi (`ps`, `ss`, `netstat`)
- Implementare daemon Bash cu fișier PID
- Notificări și alertare (email, webhook, desktop)
- Gestionare configurație YAML/TOML în Bash

---

## Cerințe Funcționale

### Obligatorii (pentru nota de trecere)

1. **Monitorizare servicii systemd**
   - Verificare status (active, inactive, failed)
   - Detectare crash și restart automat (configurabil)
   - Istoric evenimente pe serviciu

2. **Monitorizare procese**
   - Verificare existență proces după nume sau PID
   - Alertă la dispariție proces critic
   - Monitorizare utilizare CPU/RAM pe proces

3. **Monitorizare porturi**
   - Verificare port deschis (TCP/UDP)
   - Alertă dacă serviciul nu răspunde
   - Opțional HTTP health check (status code)

4. **Sistem alertare**
   - Logging local (cu rotație)
   - Notificare desktop (`notify-send`)
   - Email via `sendmail` sau SMTP extern

5. **Mod daemon**
   - Rulare în fundal cu fișier PID
   - Comenzi: start, stop, status, reload
   - Interval verificare configurabil

### Opționale (pentru punctaj complet)

6. **Dashboard terminal** - Vizualizare în timp real cu `watch` sau ncurses
7. **Health check avansat** - Verificare body răspuns, latență
8. **Alertare webhook** - Slack, Discord, Teams
9. **Escaladare alertă** - Alertă repetată dacă problema persistă
10. **Metrici Prometheus** - Endpoint export `/metrics`

---

## Interfață CLI

```bash
./watchdog.sh <command> [options]

Commands:
  start                 Start the daemon
  stop                  Stop the daemon
  status                Display daemon and services status
  reload                Reload configuration
  check                 One-shot verification (without daemon)
  add <service>         Add service to monitoring
  remove <service>      Remove service from monitoring
  list                  List monitored services
  logs [service]        Display logs (all or per service)
  dashboard             Display interactive dashboard

Options:
  -c, --config FILE     Configuration file (default: /etc/watchdog.conf)
  -i, --interval SEC    Check interval (default: 30)
  -d, --debug           Debug mode (verbose)
  -q, --quiet           No output (log only)
  --no-restart          Disable automatic restart
  --dry-run             Simulation without actions

Examples:
  ./watchdog.sh start -i 60
  ./watchdog.sh add nginx --restart --alert email
  ./watchdog.sh check --dry-run
  ./watchdog.sh logs nginx --last 50
```

---

## Exemple Output

### Dashboard Status

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    WATCHDOG SĂNĂTATE SERVICII v1.0                           ║
║                    Ultima verificare: 2025-01-20 14:30:45                   ║
╚══════════════════════════════════════════════════════════════════════════════╝

┌─────────────────────────────────────────────────────────────────────────────┐
│ SERVICII SYSTEMD                                                            │
├──────────────────┬──────────┬──────────┬─────────────┬─────────────────────┤
│ Serviciu         │ Status   │ Uptime   │ Restart-uri │ Ultima Problemă     │
├──────────────────┼──────────┼──────────┼─────────────┼─────────────────────┤
│ nginx            │ ✅ active │ 5z 12h   │ 0           │ -                   │
│ postgresql       │ ✅ active │ 5z 12h   │ 0           │ -                   │
│ redis            │ ⚠️ restart│ 0h 5m    │ 3 (astăzi)  │ OOM killed 14:25    │
│ myapp            │ ❌ failed │ -        │ 5 (max)     │ Exit code 1         │
└──────────────────┴──────────┴──────────┴─────────────┴─────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│ VERIFICĂRI PORTURI                                                          │
├──────────────────┬──────────┬──────────┬─────────────────────────────────────┤
│ Serviciu         │ Port     │ Status   │ Timp Răspuns                        │
├──────────────────┼──────────┼──────────┼─────────────────────────────────────┤
│ nginx            │ 80/tcp   │ ✅ open   │ 2ms                                 │
│ nginx            │ 443/tcp  │ ✅ open   │ 3ms                                 │
│ postgresql       │ 5432/tcp │ ✅ open   │ 1ms                                 │
│ redis            │ 6379/tcp │ ✅ open   │ 1ms                                 │
│ myapp            │ 8080/tcp │ ❌ closed │ timeout                             │
└──────────────────┴──────────┴──────────┴─────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│ ALERTE RECENTE (ultimele 24h)                                              │
├─────────────────────────────────────────────────────────────────────────────┤
│ 14:25 [CRIT] redis: OOM killed, se restartează···                          │
│ 14:25 [INFO] redis: restart reușit                                         │
│ 12:00 [WARN] myapp: utilizare CPU ridicată (95%)                           │
│ 10:30 [CRIT] myapp: serviciu eșuat, încercare restart 5/5                  │
│ 10:30 [CRIT] myapp: restart-uri maxime atinse, alertare admin              │
└─────────────────────────────────────────────────────────────────────────────┘

Daemon PID: 12345 | Uptime: 2z 5h | Următoarea verificare în: 15s
Apasă 'q' pentru ieșire, 'r' pentru refresh, 'l' pentru log-uri
```

### Alertă Email

```
Subject: [WATCHDOG ALERT] Serviciu redis eșuat pe server01

Alertă Sănătate Serviciu
========================
Server:    server01.example.com
Serviciu:  redis
Status:    FAILED
Ora:       2025-01-20 14:25:30 UTC

Detalii:
- Stare anterioară: active
- Cod ieșire: 137 (OOM killed)
- Memorie la eșec: 2048MB / 2048MB limită

Acțiune Întreprinsă:
- Restart automat inițiat
- Restart reușit la 14:25:35

Log-uri recente:
Jan 20 14:25:29 server01 redis[1234]: Out of memory
Jan 20 14:25:30 server01 systemd[1]: redis.service: Main process exited
```

---

## Fișier Configurație

```yaml
# /etc/watchdog.conf
general:
  interval: 30          # Seconds between checks
  log_file: /var/log/watchdog.log
  pid_file: /var/run/watchdog.pid
  max_restarts: 5       # Per service per hour
  restart_cooldown: 60  # Seconds between restarts

alerts:
  email:
    enabled: true
    to: [adresă eliminată]
    smtp_host: localhost
  desktop:
    enabled: true
  webhook:
    enabled: false
    url: https://hooks.slack.com/xxx

services:
  - name: nginx
    type: systemd
    restart: true
    alert: [email, desktop]
    
  - name: postgresql
    type: systemd
    restart: false        # Databases don't auto-restart
    alert: [email]
    
  - name: myapp
    type: process
    pattern: "python.*myapp"
    restart_cmd: "systemctl restart myapp"
    alert: [email, webhook]

ports:
  - name: nginx-http
    host: localhost
    port: 80
    protocol: tcp
    
  - name: api-health
    host: localhost
    port: 8080
    protocol: http
    path: /health
    expect_status: 200
    timeout: 5
```

---

## Structură Proiect

```
M03_Service_Health_Watchdog/
├── README.md
├── Makefile
├── src/
│   ├── watchdog.sh              # Main script (daemon)
│   └── lib/
│       ├── config.sh            # YAML configuration parser
│       ├── checks.sh            # Service check functions
│       ├── alerts.sh            # Alerting system
│       ├── daemon.sh            # Daemon functions (start/stop/pid)
│       ├── logging.sh           # Logging with rotation
│       └── dashboard.sh         # Terminal UI
├── etc/
│   ├── watchdog.conf            # Default configuration
│   └── watchdog.conf.example
├── tests/
│   ├── test_checks.sh
│   ├── test_alerts.sh
│   └── mock_services/           # Mock services for tests
├── docs/
│   ├── INSTALL.md
│   ├── CONFIGURATION.md
│   └── ALERTS.md
└── examples/
    ├── minimal.conf
    └── production.conf
```

---

## Indicii de Implementare

### Verificare serviciu systemd

```bash
check_systemd_service() {
    local service="$1"
    local status
    
    status=$(systemctl is-active "$service" 2>/dev/null)
    
    case "$status" in
        active)   return 0 ;;
        inactive) return 1 ;;
        failed)   return 2 ;;
        *)        return 3 ;;  # Unknown
    esac
}

# Get service details
get_service_info() {
    local service="$1"
    systemctl show "$service" --property=ActiveState,SubState,MainPID,ExecMainStartTimestamp
}
```

### Verificare port TCP

```bash
check_port() {
    local host="$1"
    local port="$2"
    local timeout="${3:-5}"
    
    # Method 1: with timeout and bash
    timeout "$timeout" bash -c "echo >/dev/tcp/$host/$port" 2>/dev/null
    
    # Method 2: with nc (more portable)
    # nc -z -w "$timeout" "$host" "$port" 2>/dev/null
}

# HTTP health check
check_http() {
    local url="$1"
    local expect_status="${2:-200}"
    local timeout="${3:-5}"
    
    local status
    status=$(curl -s -o /dev/null -w "%{http_code}" --max-time "$timeout" "$url")
    
    [[ "$status" == "$expect_status" ]]
}
```

### Daemon cu fișier PID

```bash
readonly PID_FILE="/var/run/watchdog.pid"

start_daemon() {
    if [[ -f "$PID_FILE" ]]; then
        local pid
        pid=$(<"$PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            die "Daemon already running (PID: $pid)"
        fi
        rm -f "$PID_FILE"
    fi
    
    # Fork to background
    (
        echo $$ > "$PID_FILE"
        trap 'rm -f "$PID_FILE"; exit 0' SIGTERM SIGINT
        
        while true; do
            run_all_checks
            sleep "$INTERVAL"
        done
    ) &
    
    echo "Daemon started (PID: $!)"
}

stop_daemon() {
    [[ -f "$PID_FILE" ]] || die "Daemon not running"
    
    local pid
    pid=$(<"$PID_FILE")
    kill "$pid" 2>/dev/null
    rm -f "$PID_FILE"
    echo "Daemon stopped"
}
```

### Parser YAML simplu (pentru Bash)

```bash
# For simple configurations, parsing with grep/sed
# For complex YAML, use yq or Python helper

parse_yaml() {
    local file="$1"
    local prefix="${2:-}"
    
    local s='[[:space:]]*'
    local w='[a-zA-Z0-9_]*'
    
    sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$prefix\2=\"\3\"|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$prefix\2=\"\3\"|p" \
        "$file"
}

# Or use yq (recommended)
# apt install yq
# yq '.services[0].name' config.yaml
```

---

## Criterii Specifice de Evaluare

| Criteriu | Pondere | Descriere |
|-----------|--------|-------------|
| Monitorizare systemd | 15% | Status corect, istoric, detalii |
| Monitorizare porturi | 10% | Verificare TCP, HTTP health check |
| Sistem alertare | 15% | Minimum 2 canale funcționale |
| Mod daemon | 15% | Start/stop/reload, fișier PID, semnale |
| Restart automat | 10% | Cu cooldown și restart-uri maxime |
| Dashboard | 10% | Vizualizare status în terminal |
| Funcționalități extra | 10% | Webhook, escaladare, metrici |
| Calitate cod + teste | 10% | ShellCheck curat, teste |
| Documentație | 5% | README, INSTALL, docs config |

---

## Resurse

- `man systemctl` - Gestionare servicii systemd
- `man journalctl` - Citire log-uri systemd
- `man ss` - Statistici socket-uri (înlocuiește netstat)
- Seminar 2-4 - Scripting, procese, procesare text

---

*Proiect MEDIUM | Sisteme de Operare | ASE-CSIE*
