# Exerciții de tip sprint — CAPSTONE SEM06

> **Sisteme de Operare** | ASE București - CSIE  
> Seminarul 6: Proiecte integrate (Monitor, Backup, Deployer)

---

## Despre exercițiile de tip sprint

Exerciții scurte (5–10 minute) pentru practică rapidă. Fiecare exercițiu:
- are un obiectiv clar și măsurabil;
- poate fi verificat imediat;
- se bazează pe concepte CAPSTONE.

**Cum se folosesc:**
- individual sau în perechi;
- la începutul seminarului (încălzire);
- ca pauză între secțiuni mai lungi;
- ca temă.

---

## Protocol Pair Programming

Exercițiile de tip sprint funcționează foarte bine cu pair programming. Urmați acest protocol:

### Roluri

| Rol | Responsabilități |
|------|------------------|
| **Driver** | Tastează codul, se concentrează pe corectitudinea sintaxei, verbalizează raționamentul |
| **Navigator** | Revizuiește logica în timp real, identifică erori devreme, anticipează, verifică documentația |

### Program de rotație

| Timp (min) | Activitate | Driver | Navigator |
|------------|----------|--------|-----------|
| 0-5 | Exercițiul de tip sprint (prima jumătate) | Student A | Student B |
| 5-10 | Exercițiul de tip sprint (a doua jumătate) | Student B | Student A |

**Declanșator de schimbare:** după finalizarea fiecărui exercițiu de tip sprint SAU la fiecare 5–7 minute, oricare survine mai întâi.

### Reguli de comunicare

**Driver spune:**
- „Voi crea aici un handler de trap...”
- „Verific dacă această variabilă este între ghilimele...”
- „Cred că avem nevoie de `set -euo pipefail` la început”

**Navigator spune:**
- „Stai, ai omis ghilimelele în jurul acelei variabile.”
- „Ce se întâmplă dacă fișierul nu există?”
- „Codul de ieșire ar trebui să fie 1 pentru eșec, nu 0.”

### Beneficii pentru CAPSTONE

| Competență | Cum ajută pair programming |
|-------|---------------------------|
| Tratarea erorilor | Navigatorul observă cazuri-limită omise |
| Stil de cod | Ambii învață din abordări diferite |
| Depanare | Două perspective găsesc bug‑uri mai repede |
| Încredere | Reduce anxietatea la sarcini complexe |

---

## Sprint 1: Curățare cu trap (5 min)

### Obiectiv
Scrieți un script care creează un director temporar și îl șterge automat la terminare.

### Cerință

```bash
# When you run the script:
./sprint1.sh
# Creates /tmp/sprint_XXXXX
# On exit (normal or Ctrl+C), directory disappears

# Verification:
ls /tmp/sprint_*  # Doesn't exist
```

### Șablon de pornire

```bash
#!/bin/bash
set -euo pipefail

# TODO: Create temporary directory
TEMP_DIR=

# TODO: Define cleanup function


# TODO: Set trap


echo "Temporary directory: $TEMP_DIR"
echo "Press Ctrl+C or wait 5 seconds..."
sleep 5
echo "Normal termination"
```

### Verificare

```bash
# Run the script
./sprint1.sh &
PID=$!
sleep 2
# Check directory exists
ls /tmp/sprint_* 2>/dev/null && echo "OK: Dir exists"
# Send SIGINT
kill -INT $PID
sleep 1
# Check directory disappeared
ls /tmp/sprint_* 2>/dev/null || echo "OK: Cleaned up"
```

---

## Sprint 2: Citire configurație (7 min)

### Obiectiv
Încărcați variabile dintr-un fișier de configurație.

### Fișier de configurație (sprint2.conf)

```ini
# Backup configuration
BACKUP_DIR=/var/backups
MAX_BACKUPS=5
COMPRESSION=gzip
# Ignored comment
DEBUG=true
```

### Cerință

```bash
./sprint2.sh sprint2.conf
# Output:
# BACKUP_DIR=/var/backups
# MAX_BACKUPS=5
# COMPRESSION=gzip
# DEBUG=true
```

### Șablon de pornire

```bash
#!/bin/bash
set -euo pipefail

CONFIG_FILE="${1:-config.conf}"

# TODO: Check file exists


# TODO: Read and display variables (ignore comments and empty lines)

```

### Indiciu
Folosiți `grep -v "^#\|^$"` pentru a filtra comentariile și liniile goale.

---

## Sprint 3: Funcție de jurnalizare (5 min)

### Obiectiv
Implementați o funcție de jurnalizare cu niveluri.

### Cerință

```bash
LOG_LEVEL=INFO

log DEBUG "Debug message"      # Not displayed
log INFO "Info message"        # [2024-01-15 10:30:00] [INFO] Info message
log WARN "Warning message"     # [2024-01-15 10:30:00] [WARN] Warning message
log ERROR "Error message"      # [2024-01-15 10:30:00] [ERROR] Error message
```

### Șablon de pornire

```bash
#!/bin/bash

LOG_LEVEL="${LOG_LEVEL:-INFO}"

# Levels: DEBUG=0, INFO=1, WARN=2, ERROR=3
declare -A LEVELS=([DEBUG]=0 [INFO]=1 [WARN]=2 [ERROR]=3)

log() {
    local level="$1"
    local message="$2"

    # TODO: Check if should be displayed

    # TODO: Display with timestamp

}

# Test
log DEBUG "Debug message"
log INFO "Info message"
log WARN "Warning message"
log ERROR "Error message"
```

---

## Sprint 4: Verificare proces (5 min)

### Obiectiv
Verificați dacă un proces rulează, după nume.

### Cerință

```bash
./sprint4.sh bash
# Output: Process 'bash' is running (PID: 1234, 5678)

./sprint4.sh nonexistent
# Output: Process 'nonexistent' is not running
# Exit code: 1
```

### Șablon de pornire

```bash
#!/bin/bash
set -euo pipefail

PROCESS_NAME="${1:-}"

# TODO: Check argument


# TODO: Find PIDs (exclude own grep process)


# TODO: Display result and return exit code

```

### Indiciu
`pgrep -x "$PROCESS_NAME"` găsește procesele exact după nume.

---

## Sprint 5: Alertă utilizare disc (7 min)

### Obiectiv
Verificați spațiul pe disc și generați alertă dacă depășește un prag.

### Cerință

```bash
./sprint5.sh /home 80
# If /home uses <80%:
# OK: /home at 45%

# If /home uses >=80%:
# ALERT: /home at 92% (threshold: 80%)
# Exit code: 1
```

### Șablon de pornire

```bash
#!/bin/bash
set -euo pipefail

MOUNT_POINT="${1:-/}"
THRESHOLD="${2:-90}"

# TODO: Get usage percentage with df


# TODO: Compare with threshold and display

```

### Indiciu
`df -h "$MOUNT_POINT" | awk 'NR==2 {print $5}' | tr -d '%'`

---

## Sprint 6: Verificare vechime fișiere (5 min)

### Obiectiv
Găsiți fișiere mai vechi decât N zile.

### Cerință

```bash
./sprint6.sh /var/log 7
# Output:
# Files older than 7 days in /var/log:
# /var/log/old.log (15 days)
# /var/log/ancient.log (30 days)
# Total: 2 files
```

### Șablon de pornire

```bash
#!/bin/bash
set -euo pipefail

DIRECTORY="${1:-.}"
DAYS="${2:-30}"

# TODO: Argument validation


# TODO: Find files with find -mtime


# TODO: Display formatted results

```

---

## Sprint 7: Health check simplu (7 min)

### Obiectiv
Verificați dacă un URL răspunde cu HTTP 200.

### Cerință

```bash
./sprint7.sh https://google.com
# Output: OK: https://google.com responded with 200

./sprint7.sh https://nonexistent.invalid
# Output: FAIL: https://nonexistent.invalid did not respond
# Exit code: 1
```

### Șablon de pornire

```bash
#!/bin/bash
set -euo pipefail

URL="${1:-}"

# TODO: Check argument


# TODO: Check with curl and analyse response


```

### Indiciu
`curl -s -o /dev/null -w "%{http_code}" "$URL"` întoarce codul HTTP.

---

## Sprint 8: Rotire fișiere (10 min)

### Obiectiv
Implementați rotația fișierelor (păstrați ultimele N).

### Cerință

```bash
# If we have: backup_1.tar backup_2.tar ... backup_10.tar
./sprint8.sh /backups "backup_*.tar" 5
# Keeps: backup_6.tar ... backup_10.tar
# Deletes: backup_1.tar ... backup_5.tar
# Output:
# Keeping 5 newest files
# Deleted: backup_1.tar
# ...
# Deleted: backup_5.tar
```

### Șablon de pornire

```bash
#!/bin/bash
set -euo pipefail

DIRECTORY="${1:-.}"
PATTERN="${2:-*}"
KEEP="${3:-5}"

# TODO: Validation


# TODO: List files sorted by date


# TODO: Delete oldest, keep KEEP

```

### Indiciu
`ls -t` sortează după timp (cele mai noi primele).

---

## Sprint 9: Configurare cron (10 min)

### Obiectiv
Configurați backup automat folosind cron și înțelegeți sintaxa de programare.

### Context

Semestrul trecut, un student a configurat un backup „zilnic”, dar l-a programat accidental să ruleze în fiecare minut. Discul s-a umplut în 3 ore. Nu repetați greșeala.

### Sarcină

1. Creați un script de backup:
   ```bash
   #!/bin/bash
   # /usr/local/bin/daily_backup.sh
   set -euo pipefail

   LOG="/var/log/backup.log"
   BACKUP_DIR="/var/backups"
   SOURCE="/home/user/important"

   echo "[$(date -Iseconds)] Starting backup" >> "$LOG"

   # Create timestamped backup
   TIMESTAMP=$(date +%Y%m%d_%H%M%S)
   tar -czf "${BACKUP_DIR}/backup_${TIMESTAMP}.tar.gz" "$SOURCE" 2>> "$LOG"

   echo "[$(date -Iseconds)] Backup complete" >> "$LOG"
   ```

2. Adăugați în cron o intrare pentru 02:30 zilnic. Completați spațiile:
   ```bash
   # Edit crontab
   crontab -e

   # Add this line (what's the correct format?)
   ___  ___  *  *  *  /usr/local/bin/daily_backup.sh
   ```

3. Verificați că cron rulează:
   ```bash
   systemctl status cron
   crontab -l
   ```

### Răspuns așteptat
```
30 2 * * * /usr/local/bin/daily_backup.sh
```

### Referință format cron
```
┌───────────── minute (0-59)
│ ┌───────────── hour (0-23)
│ │ ┌───────────── day of month (1-31)
│ │ │ ┌───────────── month (1-12)
│ │ │ │ ┌───────────── day of week (0-6, Sunday=0)
│ │ │ │ │
* * * * * command
```

### Pattern‑uri uzuale
| Expresie | Semnificație |
|------------|---------|
| `0 * * * *` | În fiecare oră, la minutul 0 |
| `0 0 * * *` | Zilnic, la miezul nopții |
| `30 2 * * *` | Zilnic, la 02:30 |
| `0 0 * * 0` | În fiecare duminică, la miezul nopții |
| `0 0 1 * *` | În prima zi a fiecărei luni |
| `*/15 * * * *` | La fiecare 15 minute |

### Greșeli frecvente
- uitarea de a face scriptul executabil (`chmod +x`);
- ordinea greșită minut/oră (cea mai frecventă);
- lipsa căii complete către script;
- script fără shebang corect;
- lipsa tratării erorilor (scriptul eșuează fără semnal).

### Provocare bonus
Ce face această expresie cron?
```
0 */4 * * 1-5 /usr/local/bin/report.sh
```
Răspuns: _______________

---

## Soluții rapide

### Sprint 1

```bash
#!/bin/bash
set -euo pipefail
TEMP_DIR=$(mktemp -d /tmp/sprint_XXXXX)
cleanup() { rm -rf "$TEMP_DIR"; echo "Cleaned: $TEMP_DIR"; }
trap cleanup EXIT INT TERM
echo "Dir: $TEMP_DIR"; sleep 5
```

### Sprint 2

```bash
#!/bin/bash
set -euo pipefail
CONFIG_FILE="${1:?Usage: $0 config_file}"
[[ -f "$CONFIG_FILE" ]] || { echo "Not found: $CONFIG_FILE"; exit 1; }
grep -v "^#\|^$" "$CONFIG_FILE"
```

### Sprint 3

```bash
log() {
    local level="$1" message="$2"
    [[ ${LEVELS[$level]}  -ge ${LEVELS[$LOG_LEVEL]} ]] || return 0
    printf "[%s] [%s] %s
" "$(date '+%Y-%m-%d %H:%M:%S')" "$level" "$message"
}
```

### Sprint 4

```bash
#!/bin/bash
set -euo pipefail
[[ -n "${1:-}" ]] || { echo "Usage: $0 process_name"; exit 1; }
PIDS=$(pgrep -x "$1" 2>/dev/null) || { echo "Process '$1' not running"; exit 1; }
echo "Process '$1' running (PID: $(echo $PIDS | tr '
' ' '))"
```

### Sprint 5

```bash
#!/bin/bash
set -euo pipefail
USAGE=$(df "$1" | awk 'NR==2 {print $5}' | tr -d '%')
if [[ $USAGE -ge $2 ]]; then
    echo "ALERT: $1 at ${USAGE}% (threshold: $2%)"; exit 1
fi
echo "OK: $1 at ${USAGE}%"
```

### Sprint 9

```bash
# Answer: 30 2 * * *
# Bonus: Every 4 hours (0, 4, 8, 12, 16, 20) on weekdays (Mon-Fri)
```

---

## Urmărirea progresului

| Sprint | Concepte | Finalizat | Note |
|--------|----------|-----------|-------|
| 1 | trap, cleanup, mktemp | ☐ | |
| 2 | config parsing, grep | ☐ | |
| 3 | logging, arrays, date | ☐ | |
| 4 | pgrep, process check | ☐ | |
| 5 | df, disk monitoring | ☐ | |
| 6 | find -mtime, file age | ☐ | |
| 7 | curl, health check | ☐ | |
| 8 | file rotation, sort | ☐ | |
| 9 | cron, scheduling | ☐ | |

---

*Document generat pentru SEM06 CAPSTONE — Sisteme de Operare*  
*ASE București - CSIE | 2024-2025*
