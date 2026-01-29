# S05_ANEXA - Referințe Seminar 5 (Redistribuit)

> **Sisteme de Operare** | ASE București - CSIE  
> Material suplimentar - Advanced Scripting

---

## Diagrame ASCII

### Structura unui Script Profesional

```
┌──────────────────────────────────────────────────────────────────────┐
│                  ANATOMY OF A PROFESSIONAL BASH SCRIPT               │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  #!/bin/bash                           ← SHEBANG (obligatoriu)      │
│  #                                                                   │
│  # Script: name.sh                     ← HEADER                      │
│  # Description: What it does           │ Documentație                │
│  # Author: Name                        │                             │
│  # Version: 1.0.0                      │                             │
│  # Date: 2025-01-10                    │                             │
│  #                                     ◄─────────────────────────────┤
│                                                                      │
│  set -euo pipefail                     ← SAFETY OPTIONS             │
│  IFS=$'\n\t'                           │ Previne erori comune        │
│                                        ◄─────────────────────────────┤
│                                                                      │
│  # === CONSTANTS ===                   ← CONSTANTE                   │
│  readonly VERSION="1.0.0"              │ Nu se pot modifica          │
│  readonly SCRIPT_DIR=$(...)            │                             │
│                                        ◄─────────────────────────────┤
│                                                                      │
│  # === GLOBALS ===                     ← VARIABILE GLOBALE           │
│  VERBOSE=false                         │ Cu valori default           │
│  OUTPUT=""                             │                             │
│                                        ◄─────────────────────────────┤
│                                                                      │
│  # === FUNCTIONS ===                   ← FUNCȚII                     │
│  usage() { ... }                       │ Helper functions            │
│  log() { ... }                         │ (definite înainte de        │
│  die() { ... }                         │ utilizare)                  │
│  cleanup() { ... }                     │                             │
│  parse_args() { ... }                  │                             │
│  validate() { ... }                    │                             │
│  process() { ... }                     │                             │
│                                        ◄─────────────────────────────┤
│                                                                      │
│  # === TRAPS ===                       ← ERROR HANDLING              │
│  trap cleanup EXIT                     │ Cleanup automat             │
│  trap 'die "Interrupted"' INT TERM     │ Handle signals              │
│                                        ◄─────────────────────────────┤
│                                                                      │
│  # === MAIN ===                        ← ENTRY POINT                 │
│  main() {                              │                             │
│      parse_args "$@"                   │ 1. Parsare argumente        │
│      validate                          │ 2. Validare                 │
│      process                           │ 3. Logica principală        │
│  }                                     │                             │
│                                        │                             │
│  main "$@"                             ← INVOCĂ MAIN                 │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

### Signal Handling și Trap

```
┌──────────────────────────────────────────────────────────────────────┐
│                        SIGNAL HANDLING                               │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌─────────────┐     ┌─────────────┐     ┌─────────────────────┐    │
│  │   SIGNAL    │────►│    TRAP     │────►│      HANDLER        │    │
│  └─────────────┘     └─────────────┘     └─────────────────────┘    │
│                                                                      │
│  SEMNALE COMUNE:                                                     │
│  ┌────────┬───────────────────────────────────────────────────────┐ │
│  │ SIGINT │ Ctrl+C - Întrerupere interactivă                      │ │
│  │ (2)    │ trap 'echo "Interrupted"; exit 130' INT               │ │
│  ├────────┼───────────────────────────────────────────────────────┤ │
│  │ SIGTERM│ Kill default - Terminare graceful                     │ │
│  │ (15)   │ trap cleanup TERM                                     │ │
│  ├────────┼───────────────────────────────────────────────────────┤ │
│  │ SIGKILL│ Kill -9 - NU POATE FI PRINS                           │ │
│  │ (9)    │ Nu există trap pentru SIGKILL                         │ │
│  ├────────┼───────────────────────────────────────────────────────┤ │
│  │ SIGHUP │ Terminal închis                                       │ │
│  │ (1)    │ trap 'reload_config' HUP                              │ │
│  ├────────┼───────────────────────────────────────────────────────┤ │
│  │ EXIT   │ Pseudo-signal - La ieșirea scriptului                 │ │
│  │        │ trap cleanup EXIT  (se execută ÎNTOTDEAUNA)           │ │
│  ├────────┼───────────────────────────────────────────────────────┤ │
│  │ ERR    │ Pseudo-signal - La eroare (cu set -e)                 │ │
│  │        │ trap 'error_handler $LINENO' ERR                      │ │
│  ├────────┼───────────────────────────────────────────────────────┤ │
│  │ DEBUG  │ Pseudo-signal - La fiecare comandă                    │ │
│  │        │ trap 'echo "Line $LINENO: $BASH_COMMAND"' DEBUG       │ │
│  └────────┴───────────────────────────────────────────────────────┘ │
│                                                                      │
│  PATTERN COMPLET:                                                    │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │  cleanup() {                                                   │ │
│  │      local exit_code=$?                                        │ │
│  │      echo "Cleanup: removing temp files..."                    │ │
│  │      rm -rf "$TEMP_DIR"                                        │ │
│  │      exit $exit_code  # Păstrează exit code original           │ │
│  │  }                                                             │ │
│  │                                                                │ │
│  │  trap cleanup EXIT          # Cleanup la orice ieșire          │ │
│  │  trap 'exit 130' INT        # Ctrl+C                           │ │
│  │  trap 'exit 143' TERM       # kill                             │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

### Arrays în Bash

```
┌──────────────────────────────────────────────────────────────────────┐
│                        BASH ARRAYS                                   │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  INDEXED ARRAYS (numerice):                                          │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │  arr=(apple banana cherry)                                     │ │
│  │        │      │       │                                        │ │
│  │        ▼      ▼       ▼                                        │ │
│  │      [0]    [1]     [2]                                        │ │
│  │                                                                │ │
│  │  ${arr[0]}     → "apple"        Primul element                 │ │
│  │  ${arr[-1]}    → "cherry"       Ultimul (Bash 4.3+)            │ │
│  │  ${arr[@]}     → toate elementele (ca listă)                   │ │
│  │  ${#arr[@]}    → 3              Lungime                        │ │
│  │  ${!arr[@]}    → 0 1 2          Indici                         │ │
│  │  ${arr[@]:1:2} → banana cherry  Slice                          │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                      │
│  ASSOCIATIVE ARRAYS (hash/dict):                                     │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │  declare -A config                    # OBLIGATORIU!           │ │
│  │                                                                │ │
│  │  config[host]="localhost"             ┌─────────┬────────────┐ │ │
│  │  config[port]="8080"                  │   KEY   │   VALUE    │ │ │
│  │  config[debug]="true"                 ├─────────┼────────────┤ │ │
│  │                                       │ "host"  │"localhost" │ │ │
│  │  ${config[host]}  → "localhost"       │ "port"  │  "8080"    │ │ │
│  │  ${!config[@]}    → host port debug   │ "debug" │  "true"    │ │ │
│  │  ${config[@]}     → toate valorile    └─────────┴────────────┘ │ │
│  │  ${#config[@]}    → 3                                          │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                      │
│  OPERAȚII PE ARRAYS:                                                 │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │                                                                │ │
│  │  ADĂUGARE:                                                     │ │
│  │  arr+=(date)              # Append                             │ │
│  │  arr[${#arr[@]}]="date"   # Append explicit                    │ │
│  │  arr[10]="fig"            # La index specific (sparse)         │ │
│  │                                                                │ │
│  │  ȘTERGERE:                                                     │ │
│  │  unset arr[1]             # Șterge element (devine sparse)     │ │
│  │  arr=("${arr[@]:0:1}" "${arr[@]:2}")  # Șterge și compactează │ │
│  │  unset arr                # Șterge tot array-ul                │ │
│  │                                                                │ │
│  │  ITERARE:                                                      │ │
│  │  for item in "${arr[@]}"; do echo "$item"; done                │ │
│  │  for i in "${!arr[@]}"; do echo "[$i]=${arr[$i]}"; done        │ │
│  │                                                                │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

---

## Exerciții Rezolvate Complet

### Exercițiul 1: Framework de Logging

```bash
#!/bin/bash
# logger.sh - Framework de logging reutilizabil

# === CONFIGURARE ===
LOG_FILE="${LOG_FILE:-/tmp/app.log}"
LOG_LEVEL="${LOG_LEVEL:-INFO}"
LOG_FORMAT="${LOG_FORMAT:-default}"  # default, json, simple

# Nivele de logging (ordine crescătoare)
declare -A LOG_LEVELS=(
    [DEBUG]=0
    [INFO]=1
    [WARN]=2
    [ERROR]=3
    [FATAL]=4
)

# Culori pentru terminal
declare -A LOG_COLORS=(
    [DEBUG]="\033[36m"    # Cyan
    [INFO]="\033[32m"     # Green
    [WARN]="\033[33m"     # Yellow
    [ERROR]="\033[31m"    # Red
    [FATAL]="\033[35m"    # Magenta
    [RESET]="\033[0m"
)

# === FUNCȚII DE LOGGING ===

_should_log() {
    local level=$1
    [[ ${LOG_LEVELS[$level]:-0} -ge ${LOG_LEVELS[$LOG_LEVEL]:-0} ]]
}

_format_log() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local caller="${BASH_SOURCE[2]:-unknown}:${BASH_LINENO[1]:-0}"
    
    case $LOG_FORMAT in
        json)
            printf '{"timestamp":"%s","level":"%s","caller":"%s","message":"%s"}\n' \
                "$timestamp" "$level" "$caller" "$message"
            ;;
        simple)
            printf "[%s] %s\n" "$level" "$message"
            ;;
        *)  # default
            printf "[%s] [%-5s] [%s] %s\n" "$timestamp" "$level" "$caller" "$message"
            ;;
    esac
}

_log() {
    local level=$1
    shift
    local message="$*"
    
    _should_log "$level" || return 0
    
    local formatted=$(_format_log "$level" "$message")
    
    # Scrie în fișier
    echo "$formatted" >> "$LOG_FILE"
    
    # Afișează pe terminal (cu culori dacă e TTY)
    if [[ -t 2 ]]; then
        echo -e "${LOG_COLORS[$level]}${formatted}${LOG_COLORS[RESET]}" >&2
    else
        echo "$formatted" >&2
    fi
}

# Funcții publice
log_debug() { _log DEBUG "$@"; }
log_info()  { _log INFO "$@"; }
log_warn()  { _log WARN "$@"; }
log_error() { _log ERROR "$@"; }
log_fatal() { _log FATAL "$@"; exit 1; }

# === EXEMPLU UTILIZARE ===
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "=== Demo Logger ==="
    
    LOG_LEVEL=DEBUG
    LOG_FILE="/tmp/demo.log"
    
    log_debug "Acesta este un mesaj DEBUG"
    log_info "Aplicația a pornit"
    log_warn "Resurse limitate"
    log_error "Conexiune eșuată"
    
    echo ""
    echo "Log file contents:"
    cat "$LOG_FILE"
fi
```

### Exercițiul 2: Implementare Stack și Queue

```bash
#!/bin/bash
# data_structures.sh - Stack și Queue în Bash

# === STACK (LIFO) ===
declare -a STACK=()

stack_push() {
    local value="$1"
    STACK+=("$value")
    echo "Pushed: $value (size: ${#STACK[@]})"
}

stack_pop() {
    local size=${#STACK[@]}
    if [[ $size -eq 0 ]]; then
        echo "Error: Stack is empty" >&2
        return 1
    fi
    local value="${STACK[-1]}"
    unset 'STACK[-1]'
    echo "$value"
}

stack_peek() {
    local size=${#STACK[@]}
    if [[ $size -eq 0 ]]; then
        echo "Error: Stack is empty" >&2
        return 1
    fi
    echo "${STACK[-1]}"
}

stack_size() {
    echo "${#STACK[@]}"
}

stack_is_empty() {
    [[ ${#STACK[@]} -eq 0 ]]
}

# === QUEUE (FIFO) ===
declare -a QUEUE=()

queue_enqueue() {
    local value="$1"
    QUEUE+=("$value")
    echo "Enqueued: $value (size: ${#QUEUE[@]})"
}

queue_dequeue() {
    local size=${#QUEUE[@]}
    if [[ $size -eq 0 ]]; then
        echo "Error: Queue is empty" >&2
        return 1
    fi
    local value="${QUEUE[0]}"
    QUEUE=("${QUEUE[@]:1}")
    echo "$value"
}

queue_front() {
    local size=${#QUEUE[@]}
    if [[ $size -eq 0 ]]; then
        echo "Error: Queue is empty" >&2
        return 1
    fi
    echo "${QUEUE[0]}"
}

queue_size() {
    echo "${#QUEUE[@]}"
}

# === DEMO ===
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "=== Stack Demo ==="
    stack_push "A"
    stack_push "B"
    stack_push "C"
    echo "Peek: $(stack_peek)"
    echo "Pop: $(stack_pop)"
    echo "Pop: $(stack_pop)"
    echo "Size: $(stack_size)"
    
    echo ""
    echo "=== Queue Demo ==="
    queue_enqueue "1"
    queue_enqueue "2"
    queue_enqueue "3"
    echo "Front: $(queue_front)"
    echo "Dequeue: $(queue_dequeue)"
    echo "Dequeue: $(queue_dequeue)"
    echo "Size: $(queue_size)"
fi
```

### Exercițiul 3: Script de Monitorizare Complet

```bash
#!/bin/bash
#
# monitor.sh - Sistem de monitorizare resurse
# Versiune: 2.0
#

set -euo pipefail

# === CONSTANTE ===
readonly VERSION="2.0"
readonly SCRIPT_NAME=$(basename "$0")

# === CONFIGURARE DEFAULT ===
INTERVAL=5
THRESHOLD_CPU=80
THRESHOLD_MEM=90
THRESHOLD_DISK=85
OUTPUT_FORMAT="text"  # text, json, csv
ALERT_CMD=""
LOG_FILE="/var/log/monitor.log"

# === FUNCȚII HELPER ===
usage() {
    cat << EOF
$SCRIPT_NAME v$VERSION - Monitorizare resurse sistem

UTILIZARE:
    $SCRIPT_NAME [opțiuni]

OPȚIUNI:
    -h, --help              Ajutor
    -i, --interval SEC      Interval între verificări (default: 5)
    -c, --cpu PCT           Threshold CPU (default: 80)
    -m, --memory PCT        Threshold memorie (default: 90)
    -d, --disk PCT          Threshold disk (default: 85)
    -f, --format FMT        Format output: text, json, csv
    -a, --alert CMD         Comandă de alertare
    -l, --log FILE          Fișier log
    -1, --once              Rulează o singură dată

EXEMPLE:
    $SCRIPT_NAME --interval 10 --format json
    $SCRIPT_NAME -c 90 -m 95 --alert "mail -s Alert admin@example.com"
    $SCRIPT_NAME --once --format csv

EOF
}

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

send_alert() {
    local message="$1"
    if [[ -n "$ALERT_CMD" ]]; then
        echo "$message" | eval "$ALERT_CMD"
    fi
}

# === FUNCȚII DE MONITORIZARE ===
get_cpu_usage() {
    # Media pe ultimele secunde
    local idle=$(top -bn2 -d0.5 | grep "Cpu(s)" | tail -1 | awk -F',' '{print $4}' | awk '{print $1}')
    echo "scale=0; 100 - $idle" | bc
}

get_memory_usage() {
    free | awk '/Mem:/ { printf "%.0f", $3/$2 * 100 }'
}

get_disk_usage() {
    df -h / | awk 'NR==2 { gsub(/%/,""); print $5 }'
}

get_load_average() {
    cat /proc/loadavg | awk '{ print $1 }'
}

get_process_count() {
    ps aux | wc -l
}

# === OUTPUT FORMATTERS ===
output_text() {
    local cpu=$1 mem=$2 disk=$3 load=$4 procs=$5
    
    echo "=== Monitor Report $(date '+%Y-%m-%d %H:%M:%S') ==="
    printf "CPU Usage:     %3d%% %s\n" "$cpu" "$( (( cpu > THRESHOLD_CPU )) && echo '[ALERT]' || echo '[OK]')"
    printf "Memory Usage:  %3d%% %s\n" "$mem" "$( (( mem > THRESHOLD_MEM )) && echo '[ALERT]' || echo '[OK]')"
    printf "Disk Usage:    %3d%% %s\n" "$disk" "$( (( disk > THRESHOLD_DISK )) && echo '[ALERT]' || echo '[OK]')"
    printf "Load Average:  %s\n" "$load"
    printf "Processes:     %s\n" "$procs"
    echo ""
}

output_json() {
    local cpu=$1 mem=$2 disk=$3 load=$4 procs=$5
    local timestamp=$(date -Iseconds)
    
    cat << EOF
{
    "timestamp": "$timestamp",
    "metrics": {
        "cpu": { "value": $cpu, "threshold": $THRESHOLD_CPU, "alert": $(( cpu > THRESHOLD_CPU ? 1 : 0 )) },
        "memory": { "value": $mem, "threshold": $THRESHOLD_MEM, "alert": $(( mem > THRESHOLD_MEM ? 1 : 0 )) },
        "disk": { "value": $disk, "threshold": $THRESHOLD_DISK, "alert": $(( disk > THRESHOLD_DISK ? 1 : 0 )) },
        "load": $load,
        "processes": $procs
    }
}
EOF
}

output_csv() {
    local cpu=$1 mem=$2 disk=$3 load=$4 procs=$5
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Header la prima rulare
    [[ ! -f "$LOG_FILE" ]] && echo "timestamp,cpu,memory,disk,load,processes"
    echo "$timestamp,$cpu,$mem,$disk,$load,$procs"
}

# === CHECK ===
check_alerts() {
    local cpu=$1 mem=$2 disk=$3
    local alerts=()
    
    (( cpu > THRESHOLD_CPU )) && alerts+=("CPU at ${cpu}% (threshold: ${THRESHOLD_CPU}%)")
    (( mem > THRESHOLD_MEM )) && alerts+=("Memory at ${mem}% (threshold: ${THRESHOLD_MEM}%)")
    (( disk > THRESHOLD_DISK )) && alerts+=("Disk at ${disk}% (threshold: ${THRESHOLD_DISK}%)")
    
    if [[ ${#alerts[@]} -gt 0 ]]; then
        local message="ALERT on $(hostname) at $(date):\n"
        for alert in "${alerts[@]}"; do
            message+="- $alert\n"
        done
        log "ALERTS: ${alerts[*]}"
        send_alert "$(echo -e "$message")"
        return 1
    fi
    return 0
}

# === MAIN LOOP ===
monitor_once() {
    local cpu=$(get_cpu_usage)
    local mem=$(get_memory_usage)
    local disk=$(get_disk_usage)
    local load=$(get_load_average)
    local procs=$(get_process_count)
    
    case $OUTPUT_FORMAT in
        json) output_json "$cpu" "$mem" "$disk" "$load" "$procs" ;;
        csv)  output_csv "$cpu" "$mem" "$disk" "$load" "$procs" ;;
        *)    output_text "$cpu" "$mem" "$disk" "$load" "$procs" ;;
    esac
    
    check_alerts "$cpu" "$mem" "$disk" || true
}

# === PARSARE ARGUMENTE ===
ONCE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help) usage; exit 0 ;;
        -i|--interval) INTERVAL="$2"; shift 2 ;;
        -c|--cpu) THRESHOLD_CPU="$2"; shift 2 ;;
        -m|--memory) THRESHOLD_MEM="$2"; shift 2 ;;
        -d|--disk) THRESHOLD_DISK="$2"; shift 2 ;;
        -f|--format) OUTPUT_FORMAT="$2"; shift 2 ;;
        -a|--alert) ALERT_CMD="$2"; shift 2 ;;
        -l|--log) LOG_FILE="$2"; shift 2 ;;
        -1|--once) ONCE=true; shift ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

# === RUN ===
if $ONCE; then
    monitor_once
else
    log "Starting monitor (interval: ${INTERVAL}s)"
    while true; do
        monitor_once
        sleep "$INTERVAL"
    done
fi
```

---

## Referințe Rapide

### Exit Codes Standard

| Code | Semnificație |
|------|--------------|
| 0 | Succes |
| 1 | Eroare generală |
| 2 | Utilizare incorectă |
| 126 | Comandă ne-executabilă |
| 127 | Comandă negăsită |
| 128+N | Fatal signal N |
| 130 | Ctrl+C (SIGINT) |
| 143 | SIGTERM |

### Test Operators

```bash
# Fișiere
-e    există
-f    fișier regulat
-d    director
-s    size > 0
-r    readable
-w    writable
-x    executable

# Stringuri
-z    empty
-n    non-empty
=     equal
!=    not equal

# Numere
-eq   equal
-ne   not equal
-lt   less than
-gt   greater than
```

---
*Material suplimentar pentru cursul de Sisteme de Operare | ASE București - CSIE*
-e 

---

*By Revolvix for OPERATING SYSTEMS class | restricted licence 2017-2030*
