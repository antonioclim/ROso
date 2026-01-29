# Exerciții Sprint — CAPSTONE SEM06

> **Sisteme de Operare** | ASE București - CSIE  
> Seminar 6: Proiecte Integrate (Monitor, Backup, Deployer)

---

## Despre Exercițiile Sprint

Exerciții scurte (5-10 minute) pentru practică rapidă. Fiecare exercițiu:
- Are un obiectiv clar și măsurabil
- Poate fi verificat imediat
- Construiește pe concepte CAPSTONE

**Cum se folosesc:**
- Individual sau în perechi
- La începutul seminarului (warmup)
- Ca pauză între secțiuni mai lungi
- Ca temă pentru acasă

---

## Sprint 1: Trap Cleanup (5 min)

### Obiectiv
Scrie un script care creează un director temporar și îl șterge automat la terminare.

### Cerință

```bash
# Când rulezi scriptul:
./sprint1.sh
# Creează /tmp/sprint_XXXXX
# La exit (normal sau Ctrl+C), directorul dispare

# Verificare:
ls /tmp/sprint_*  # Nu există
```

### Template de Start

```bash
#!/bin/bash
set -euo pipefail

# TODO: Creează director temporar
TEMP_DIR=

# TODO: Definește funcție cleanup


# TODO: Setează trap


echo "Director temporar: $TEMP_DIR"
echo "Apasă Ctrl+C sau așteaptă 5 secunde..."
sleep 5
echo "Terminare normală"
```

### Verificare

```bash
# Rulează scriptul
./sprint1.sh &
PID=$!
sleep 2
# Verifică directorul există
ls /tmp/sprint_* 2>/dev/null && echo "OK: Dir exists"
# Trimite SIGINT
kill -INT $PID
sleep 1
# Verifică directorul a dispărut
ls /tmp/sprint_* 2>/dev/null || echo "OK: Cleaned up"
```

---

## Sprint 2: Citire Config (7 min)

### Obiectiv
Încarcă variabile dintr-un fișier de configurare.

### Fișier Config (sprint2.conf)

```ini
# Configurare backup
BACKUP_DIR=/var/backups
MAX_BACKUPS=5
COMPRESSION=gzip
# Comentariu ignorat
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

### Template de Start

```bash
#!/bin/bash
set -euo pipefail

CONFIG_FILE="${1:-config.conf}"

# TODO: Verifică fișierul există


# TODO: Citește și afișează variabilele (ignoră comentarii și linii goale)

```

### Hint
Folosește `grep -v "^#\|^$"` pentru a filtra comentariile și liniile goale.

---

## Sprint 3: Logging Function (5 min)

### Obiectiv
Implementează o funcție de logging cu nivele.

### Cerință

```bash
LOG_LEVEL=INFO

log DEBUG "Mesaj debug"      # Nu se afișează
log INFO "Mesaj info"        # [2024-01-15 10:30:00] [INFO] Mesaj info
log WARN "Mesaj warning"     # [2024-01-15 10:30:00] [WARN] Mesaj warning
log ERROR "Mesaj eroare"     # [2024-01-15 10:30:00] [ERROR] Mesaj eroare
```

### Template de Start

```bash
#!/bin/bash

LOG_LEVEL="${LOG_LEVEL:-INFO}"

# Niveluri: DEBUG=0, INFO=1, WARN=2, ERROR=3
declare -A LEVELS=([DEBUG]=0 [INFO]=1 [WARN]=2 [ERROR]=3)

log() {
    local level="$1"
    local message="$2"
    
    # TODO: Verifică dacă trebuie afișat
    
    # TODO: Afișează cu timestamp
    
}

# Test
log DEBUG "Debug message"
log INFO "Info message"
log WARN "Warning message"
log ERROR "Error message"
```

---

## Sprint 4: Process Check (5 min)

### Obiectiv
Verifică dacă un proces rulează după nume.

### Cerință

```bash
./sprint4.sh bash
# Output: Process 'bash' is running (PID: 1234, 5678)

./sprint4.sh nonexistent
# Output: Process 'nonexistent' is not running
# Exit code: 1
```

### Template de Start

```bash
#!/bin/bash
set -euo pipefail

PROCESS_NAME="${1:-}"

# TODO: Verifică argument


# TODO: Găsește PID-urile (exclus propriul proces grep)


# TODO: Afișează rezultatul și returnează exit code

```

### Hint
`pgrep -x "$PROCESS_NAME"` găsește procese exact după nume.

---

## Sprint 5: Disk Usage Alert (7 min)

### Obiectiv
Verifică spațiul pe disk și alertează dacă depășește un prag.

### Cerință

```bash
./sprint5.sh /home 80
# Dacă /home folosește <80%:
# OK: /home at 45%

# Dacă /home folosește >=80%:
# ALERT: /home at 92% (threshold: 80%)
# Exit code: 1
```

### Template de Start

```bash
#!/bin/bash
set -euo pipefail

MOUNT_POINT="${1:-/}"
THRESHOLD="${2:-90}"

# TODO: Obține procentul de utilizare cu df


# TODO: Compară cu threshold și afișează

```

### Hint
`df -h "$MOUNT_POINT" | awk 'NR==2 {print $5}' | tr -d '%'`

---

## Sprint 6: File Age Check (5 min)

### Obiectiv
Găsește fișiere mai vechi de N zile.

### Cerință

```bash
./sprint6.sh /var/log 7
# Output:
# Files older than 7 days in /var/log:
# /var/log/old.log (15 days)
# /var/log/ancient.log (30 days)
# Total: 2 files
```

### Template de Start

```bash
#!/bin/bash
set -euo pipefail

DIRECTORY="${1:-.}"
DAYS="${2:-30}"

# TODO: Validare argumente


# TODO: Găsește fișierele cu find -mtime


# TODO: Afișează rezultate formatate

```

---

## Sprint 7: Simple Health Check (7 min)

### Obiectiv
Verifică dacă un URL răspunde cu HTTP 200.

### Cerință

```bash
./sprint7.sh https://google.com
# Output: OK: https://google.com responded with 200

./sprint7.sh https://nonexistent.invalid
# Output: FAIL: https://nonexistent.invalid did not respond
# Exit code: 1
```

### Template de Start

```bash
#!/bin/bash
set -euo pipefail

URL="${1:-}"

# TODO: Verifică argument


# TODO: Verifică cu curl și analizează răspunsul


```

### Hint
`curl -s -o /dev/null -w "%{http_code}" "$URL"` returnează codul HTTP.

---

## Sprint 8: Rotate Files (10 min)

### Obiectiv
Implementează rotație de fișiere (păstrează ultimele N).

### Cerință

```bash
# Dacă avem: backup_1.tar backup_2.tar ... backup_10.tar
./sprint8.sh /backups "backup_*.tar" 5
# Păstrează: backup_6.tar ... backup_10.tar
# Șterge: backup_1.tar ... backup_5.tar
# Output:
# Keeping 5 newest files
# Deleted: backup_1.tar
# ...
# Deleted: backup_5.tar
```

### Template de Start

```bash
#!/bin/bash
set -euo pipefail

DIRECTORY="${1:-.}"
PATTERN="${2:-*}"
KEEP="${3:-5}"

# TODO: Validare


# TODO: Listează fișierele sortate după dată


# TODO: Șterge cele mai vechi, păstrează KEEP

```

### Hint
`ls -t` sortează după timp (newest first).

---

## Soluții Rapide

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
    printf "[%s] [%s] %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$level" "$message"
}
```

### Sprint 4

```bash
#!/bin/bash
set -euo pipefail
[[ -n "${1:-}" ]] || { echo "Usage: $0 process_name"; exit 1; }
PIDS=$(pgrep -x "$1" 2>/dev/null) || { echo "Process '$1' not running"; exit 1; }
echo "Process '$1' running (PID: $(echo $PIDS | tr '\n' ' '))"
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

---

## Tracking Progress

| Sprint | Concepte | Completat | Note |
|--------|----------|-----------|------|
| 1 | trap, cleanup, mktemp | ☐ | |
| 2 | config parsing, grep | ☐ | |
| 3 | logging, arrays, date | ☐ | |
| 4 | pgrep, process check | ☐ | |
| 5 | df, disk monitoring | ☐ | |
| 6 | find -mtime, file age | ☐ | |
| 7 | curl, health check | ☐ | |
| 8 | file rotation, sort | ☐ | |

---

*Document generat pentru SEM06 CAPSTONE — Sisteme de Operare*  
*ASE București - CSIE | 2024-2025*
