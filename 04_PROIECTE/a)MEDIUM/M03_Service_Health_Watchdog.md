# M03: Service Health Watchdog

> **Nivel:** MEDIUM | **Timp estimat:** 25-35 ore | **Bonus K8s:** +10%

---

## Descriere

Sistem de monitorizare continuă a serviciilor (systemd units, procese, porturi) cu alertare automată, restart automat configurabil și dashboard în terminal. Ideal pentru administrarea serverelor de producție.

---

## Obiective de Învățare

- Interacțiunea cu systemd (`systemctl`, `journalctl`)
- Monitorizare procese și porturi (`ps`, `ss`, `netstat`)
- Implementare daemon Bash cu PID file
- Notificări și alertare (email, webhook, desktop)
- Gestionarea configurațiilor YAML/TOML în Bash

---

## Cerințe Funcționale

### Obligatorii (pentru notă de trecere)

1. **Monitorizare servicii systemd**
   - Verificare status (active, inactive, failed)
   - Detectare crash și restart automat (configurabil)
   - Istoric evenimente per serviciu

2. **Monitorizare procese**
   - Verificare existență proces după nume sau PID
   - Alertă la dispariție proces critic
   - Monitorizare utilizare CPU/RAM per proces

3. **Monitorizare porturi**
   - Verificare port deschis (TCP/UDP)
   - Alertă dacă serviciul nu răspunde
   - Health check HTTP opțional (status code)

4. **Sistem de alertare**
   - Logare locală (cu rotație)
   - Notificare desktop (`notify-send`)
   - Email prin `sendmail` sau SMTP extern

5. **Mod daemon**
   - Rulare în background cu PID file
   - Comenzi: start, stop, status, reload
   - Interval de verificare configurabil

### Opționale (pentru punctaj complet)

6. **Dashboard terminal** - Vizualizare real-time cu `watch` sau ncurses
7. **Health check avansat** - Verificare response body, latență
8. **Webhook alerting** - Slack, Discord, Teams
9. **Escalare alertă** - Alertă repetată dacă problema persistă
10. **Metrici Prometheus** - Export endpoint `/metrics`

---

## Interfață CLI

```bash
./watchdog.sh <command> [opțiuni]

Comenzi:
  start                 Pornește daemon-ul
  stop                  Oprește daemon-ul
  status                Afișează status daemon și servicii
  reload                Reîncarcă configurația
  check                 Verificare one-shot (fără daemon)
  add <service>         Adaugă serviciu la monitorizare
  remove <service>      Elimină serviciu din monitorizare
  list                  Listează serviciile monitorizate
  logs [service]        Afișează log-uri (toate sau per serviciu)
  dashboard             Afișează dashboard interactiv

Opțiuni:
  -c, --config FILE     Fișier configurare (default: /etc/watchdog.conf)
  -i, --interval SEC    Interval verificare (default: 30)
  -d, --debug           Mod debug (verbose)
  -q, --quiet           Fără output (doar log)
  --no-restart          Dezactivează restart automat
  --dry-run             Simulare fără acțiuni

Exemple:
  ./watchdog.sh start -i 60
  ./watchdog.sh add nginx --restart --alert email
  ./watchdog.sh check --dry-run
  ./watchdog.sh logs nginx --last 50
```

---

## Exemple Output

### Status Dashboard

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    SERVICE HEALTH WATCHDOG v1.0                              ║
║                    Last check: 2025-01-20 14:30:45                          ║
╚══════════════════════════════════════════════════════════════════════════════╝

┌─────────────────────────────────────────────────────────────────────────────┐
│ SYSTEMD SERVICES                                                            │
├──────────────────┬──────────┬──────────┬─────────────┬─────────────────────┤
│ Service          │ Status   │ Uptime   │ Restarts    │ Last Issue          │
├──────────────────┼──────────┼──────────┼─────────────┼─────────────────────┤
│ nginx            │ ✅ active │ 5d 12h   │ 0           │ -                   │
│ postgresql       │ ✅ active │ 5d 12h   │ 0           │ -                   │
│ redis            │ ⚠️ restart│ 0h 5m    │ 3 (today)   │ OOM killed 14:25    │
│ myapp            │ ❌ failed │ -        │ 5 (max)     │ Exit code 1         │
└──────────────────┴──────────┴──────────┴─────────────┴─────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│ PORT CHECKS                                                                 │
├──────────────────┬──────────┬──────────┬─────────────────────────────────────┤
│ Service          │ Port     │ Status   │ Response Time                       │
├──────────────────┼──────────┼──────────┼─────────────────────────────────────┤
│ nginx            │ 80/tcp   │ ✅ open   │ 2ms                                 │
│ nginx            │ 443/tcp  │ ✅ open   │ 3ms                                 │
│ postgresql       │ 5432/tcp │ ✅ open   │ 1ms                                 │
│ redis            │ 6379/tcp │ ✅ open   │ 1ms                                 │
│ myapp            │ 8080/tcp │ ❌ closed │ timeout                             │
└──────────────────┴──────────┴──────────┴─────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│ RECENT ALERTS (last 24h)                                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│ 14:25 [CRIT] redis: OOM killed, restarting...                              │
│ 14:25 [INFO] redis: restart successful                                      │
│ 12:00 [WARN] myapp: high CPU usage (95%)                                   │
│ 10:30 [CRIT] myapp: service failed, restart attempt 5/5                    │
│ 10:30 [CRIT] myapp: max restarts reached, alerting admin                   │
└─────────────────────────────────────────────────────────────────────────────┘

Daemon PID: 12345 | Uptime: 2d 5h | Next check in: 15s
Press 'q' to quit, 'r' to refresh, 'l' for logs
```

### Alertă Email

```
Subject: [WATCHDOG ALERT] Service redis failed on server01

Service Health Alert
====================
Server:    server01.example.com
Service:   redis
Status:    FAILED
Time:      2025-01-20 14:25:30 UTC

Details:
- Previous state: active
- Exit code: 137 (OOM killed)
- Memory at failure: 2048MB / 2048MB limit

Action Taken:
- Automatic restart initiated
- Restart successful at 14:25:35

Recent logs:
Jan 20 14:25:29 server01 redis[1234]: Out of memory
Jan 20 14:25:30 server01 systemd[1]: redis.service: Main process exited
```

---

## Fișier Configurare

```yaml
# /etc/watchdog.conf
general:
  interval: 30          # Secunde între verificări
  log_file: /var/log/watchdog.log
  pid_file: /var/run/watchdog.pid
  max_restarts: 5       # Per serviciu per oră
  restart_cooldown: 60  # Secunde între restart-uri

alerts:
  email:
    enabled: true
    to: admin@example.com
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
    restart: false        # DB-urile nu se restartează automat
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
│   ├── watchdog.sh              # Script principal (daemon)
│   └── lib/
│       ├── config.sh            # Parser configurație YAML
│       ├── checks.sh            # Funcții verificare servicii
│       ├── alerts.sh            # Sistem alertare
│       ├── daemon.sh            # Funcții daemon (start/stop/pid)
│       ├── logging.sh           # Logging cu rotație
│       └── dashboard.sh         # UI terminal
├── etc/
│   ├── watchdog.conf            # Configurare default
│   └── watchdog.conf.example
├── tests/
│   ├── test_checks.sh
│   ├── test_alerts.sh
│   └── mock_services/           # Servicii mock pentru teste
├── docs/
│   ├── INSTALL.md
│   ├── CONFIGURATION.md
│   └── ALERTS.md
└── examples/
    ├── minimal.conf
    └── production.conf
```

---

## Hints Implementare

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

# Obține detalii despre serviciu
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
    
    # Metodă 1: cu timeout și bash
    timeout "$timeout" bash -c "echo >/dev/tcp/$host/$port" 2>/dev/null
    
    # Metodă 2: cu nc (mai portabil)
    # nc -z -w "$timeout" "$host" "$port" 2>/dev/null
}

# Health check HTTP
check_http() {
    local url="$1"
    local expect_status="${2:-200}"
    local timeout="${3:-5}"
    
    local status
    status=$(curl -s -o /dev/null -w "%{http_code}" --max-time "$timeout" "$url")
    
    [[ "$status" == "$expect_status" ]]
}
```

### Daemon cu PID file

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
# Pentru configurații simple, parsare cu grep/sed
# Pentru YAML complex, folosește yq sau Python helper

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

# Sau folosește yq (recomandat)
# apt install yq
# yq '.services[0].name' config.yaml
```

---

## Criterii Evaluare Specifice

| Criteriu | Pondere | Descriere |
|----------|---------|-----------|
| Monitorizare systemd | 15% | Status corect, istoric, detalii |
| Monitorizare porturi | 10% | TCP check, HTTP health check |
| Sistem alertare | 15% | Minim 2 canale funcționale |
| Mod daemon | 15% | Start/stop/reload, PID file, signals |
| Restart automat | 10% | Cu cooldown și max restarts |
| Dashboard | 10% | Vizualizare status în terminal |
| Funcționalități extra | 10% | Webhook, escalare, metrici |
| Calitate cod + teste | 10% | ShellCheck clean, teste |
| Documentație | 5% | README, INSTALL, config docs |

---

## Resurse

- `man systemctl` - Gestionare servicii systemd
- `man journalctl` - Citire logs systemd
- `man ss` - Socket statistics (înlocuiește netstat)
- Seminar 2-4 - Scripting, procese, text processing

---

*Proiect MEDIUM | Sisteme de Operare | ASE-CSIE*
