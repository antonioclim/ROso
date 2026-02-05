# Proiectul Monitor - Implementare Detaliată

## Cuprins

1. [Prezentare Generală](#1-prezentare-generală)
2. [Arhitectura Modulară](#2-arhitectura-modulară)
3. [Modulul Core - monitor_core.sh](#3-modulul-core---monitor_coresh)
4. [Modulul Utilități - monitor_utils.sh](#4-modulul-utilități---monitor_utilssh)
5. [Modulul Configurare - monitor_config.sh](#5-modulul-configurare---monitor_configsh)
6. [Scriptul Principal - monitor.sh](#6-scriptul-principal---monitorsh)
7. [Fluxul de Execuție](#7-fluxul-de-execuție)
8. [Tehnici Avansate de Monitorizare](#8-tehnici-avansate-de-monitorizare)
9. [Exerciții de Implementare](#9-exerciții-de-implementare)

---

## 1. Prezentare Generală

### 1.1 Scopul Proiectului

Proiectul **Monitor** reprezintă o soluție completă de monitorizare a resurselor sistem, construită integral în Bash. Sistemul oferă capabilități de:

- **Monitorizare CPU**: utilizare per-core și agregată, load average, procese consumatoare
- **Monitorizare Memorie**: RAM utilizat/disponibil, swap, cache, buffers
- **Monitorizare Disk**: spațiu utilizat, I/O operations, latență
- **Monitorizare Procese**: top consumers, zombie processes, thread count
- **Alerting**: sistem de threshold-uri configurabile cu notificări
- **Raportare**: output în multiple formate (text, JSON, CSV)

### 1.2 Structura Fișierelor

```
projects/monitor/
├── monitor.sh              # Script principal (~800 linii)
├── lib/
│   ├── monitor_core.sh     # Funcții monitorizare (~600 linii)
│   ├── monitor_utils.sh    # Utilități comune (~400 linii)
│   └── monitor_config.sh   # Gestiune configurare (~300 linii)
└── config/
    └── monitor.conf        # Configurare default
```

### 1.3 Principii de Design

Implementarea urmează principii fundamentale de software engineering:

**Separarea Responsabilităților (Separation of Concerns)**
Fiecare modul are o responsabilitate clar definită. `monitor_core.sh` gestionează exclusiv colectarea metricilor, `monitor_utils.sh` oferă funcții auxiliare, iar `monitor_config.sh` se ocupă de configurare.

**Modularitate și Reutilizare**
Funcțiile sunt proiectate pentru a fi reutilizate în diferite contexte. De exemplu, `format_bytes()` din utilități este folosită atât pentru afișarea memoriei cât și a spațiului pe disk.

**Fail-Safe Design**
Sistemul gestionează graceful situațiile de eroare, oferind valori default și continuând execuția chiar și când anumite surse de date nu sunt disponibile.

---

## 2. Arhitectura Modulară

### 2.1 Diagrama de Dependențe

```
┌─────────────────────────────────────────────────────────────────┐
│                        monitor.sh                                │
│                    (Script Principal)                            │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐  │
│  │   main()    │──│ parse_args()│──│ run_monitoring_cycle() │  │
│  └─────────────┘  └─────────────┘  └─────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
              │                │                    │
              ▼                ▼                    ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────────┐
│ monitor_config  │  │  monitor_utils  │  │    monitor_core     │
│     .sh         │  │      .sh        │  │        .sh          │
├─────────────────┤  ├─────────────────┤  ├─────────────────────┤
│ load_config()   │  │ log_message()   │  │ get_cpu_usage()     │
│ validate_conf() │  │ format_bytes()  │  │ get_memory_info()   │
│ get_threshold() │  │ is_numeric()    │  │ get_disk_usage()    │
│ set_default()   │  │ send_alert()    │  │ get_process_info()  │
└─────────────────┘  └─────────────────┘  └─────────────────────┘
```

### 2.2 Ordinea de Încărcare

Modulele trebuie încărcate într-o ordine specifică datorită dependențelor:

```bash
# 1. Utilități - nu depind de nimic
source "${LIB_DIR}/monitor_utils.sh"

# 2. Configurare - depinde de utilități pentru logging
source "${LIB_DIR}/monitor_config.sh"

# 3. Core - depinde de utilități și configurare
source "${LIB_DIR}/monitor_core.sh"
```

### 2.3 Comunicarea între Module

Modulele comunică prin:

1. **Variabile Globale** - pentru configurare și stare
2. **Funcții Exportate** - pentru operații specifice
3. **Exit Codes** - pentru semnalarea erorilor
4. **Stdout/Stderr** - pentru output și diagnostice

---

## 3. Modulul Core - monitor_core.sh

### 3.1 Funcția get_cpu_usage()

Această funcție calculează utilizarea CPU folosind `/proc/stat`:

```bash
get_cpu_usage() {
    local cpu_line prev_idle prev_total
    local idle total diff_idle diff_total usage
    
    # Prima citire - starea inițială
    cpu_line=$(grep '^cpu ' /proc/stat)
    read -r _ user nice system idle iowait irq softirq steal _ <<< "$cpu_line"
    
    prev_idle=$((idle + iowait))
    prev_total=$((user + nice + system + idle + iowait + irq + softirq + steal))
    
    # Așteptăm pentru a măsura diferența
    sleep "${CPU_SAMPLE_INTERVAL:-1}"
    
    # A doua citire
    cpu_line=$(grep '^cpu ' /proc/stat)
    read -r _ user nice system idle iowait irq softirq steal _ <<< "$cpu_line"
    
    idle=$((idle + iowait))
    total=$((user + nice + system + idle + iowait + irq + softirq + steal))
    
    # Calculăm diferențele
    diff_idle=$((idle - prev_idle))
    diff_total=$((total - prev_total))
    
    # Calculăm procentul de utilizare
    if [[ $diff_total -gt 0 ]]; then
        usage=$(awk "BEGIN {printf \"%.1f\", (1 - $diff_idle / $diff_total) * 100}")
    else
        usage="0.0"
    fi
    
    echo "$usage"
}
```

**Explicație Detaliată:**

Fișierul `/proc/stat` conține statistici agregate ale CPU-ului. Linia `cpu` arată timpul total petrecut în diferite stări:

| Câmp | Descriere |
|------|-----------|
| user | Timp în user mode |
| nice | Timp în user mode cu prioritate redusă |
| system | Timp în kernel mode |
| idle | Timp inactiv |
| iowait | Timp așteptând I/O |
| irq | Timp servind întreruperi hardware |
| softirq | Timp servind întreruperi software |
| steal | Timp "furat" de hypervisor (în VM) |

Formula de calcul:
```
CPU% = (1 - (idle_diff / total_diff)) × 100
```

### 3.2 Funcția get_memory_info()

```bash
get_memory_info() {
    local format="${1:-human}"
    local mem_total mem_available mem_used mem_free
    local buffers cached swap_total swap_used
    
    # Citim informațiile din /proc/meminfo
    while IFS=': ' read -r key value _; do
        case "$key" in
            MemTotal)     mem_total=$value ;;
            MemAvailable) mem_available=$value ;;
            MemFree)      mem_free=$value ;;
            Buffers)      buffers=$value ;;
            Cached)       cached=$value ;;
            SwapTotal)    swap_total=$value ;;
            SwapFree)     swap_free=$value ;;
        esac
    done < /proc/meminfo
    
    # Calculăm memoria utilizată
    # MemUsed = MemTotal - MemAvailable (metoda modernă)
    mem_used=$((mem_total - mem_available))
    
    # Calculăm swap utilizat
    swap_used=$((swap_total - swap_free))
    
    # Calculăm procentele
    local mem_percent swap_percent
    if [[ $mem_total -gt 0 ]]; then
        mem_percent=$(awk "BEGIN {printf \"%.1f\", $mem_used / $mem_total * 100}")
    else
        mem_percent="0.0"
    fi
    
    if [[ $swap_total -gt 0 ]]; then
        swap_percent=$(awk "BEGIN {printf \"%.1f\", $swap_used / $swap_total * 100}")
    else
        swap_percent="0.0"
    fi
    
    # Formatăm output-ul
    case "$format" in
        json)
            cat <<-EOF
			{
			    "total_kb": $mem_total,
			    "used_kb": $mem_used,
			    "available_kb": $mem_available,
			    "free_kb": $mem_free,
			    "buffers_kb": $buffers,
			    "cached_kb": $cached,
			    "percent_used": $mem_percent,
			    "swap_total_kb": $swap_total,
			    "swap_used_kb": $swap_used,
			    "swap_percent": $swap_percent
			}
			EOF
            ;;
        csv)
            echo "$mem_total,$mem_used,$mem_available,$mem_percent,$swap_total,$swap_used,$swap_percent"
            ;;
        *)  # human readable
            echo "Memory: $(format_bytes $((mem_used * 1024))) / $(format_bytes $((mem_total * 1024))) (${mem_percent}%)"
            echo "Swap:   $(format_bytes $((swap_used * 1024))) / $(format_bytes $((swap_total * 1024))) (${swap_percent}%)"
            ;;
    esac
}
```

**Concepte Cheie:**

1. **MemAvailable vs MemFree**: `MemAvailable` (introdus în kernel 3.14) indică memoria disponibilă pentru aplicații noi, incluzând cache-ul care poate fi eliberat. Este mai relevant decât `MemFree`.

2. **Buffers și Cached**: Kernelul Linux folosește memoria "liberă" pentru cache I/O. Aceasta poate fi eliberată la nevoie.

3. **Swap**: Memoria virtuală pe disk, utilizată când RAM-ul fizic este insuficient.

### 3.3 Funcția get_disk_usage()

```bash
get_disk_usage() {
    local mount_point="${1:-/}"
    local format="${2:-human}"
    local output
    
    # Verificăm că mount point-ul există
    if [[ ! -d "$mount_point" ]]; then
        log_error "Mount point inexistent: $mount_point"
        return 1
    fi
    
    # Folosim df pentru statistici filesystem
    # -P = format POSIX (o singură linie per filesystem)
    # -B1 = blocuri de 1 byte pentru precizie
    output=$(df -PB1 "$mount_point" 2>/dev/null | tail -1)
    
    if [[ -z "$output" ]]; then
        log_error "Nu pot obține informații pentru: $mount_point"
        return 1
    fi
    
    local filesystem size used available percent mount
    read -r filesystem size used available percent mount <<< "$output"
    
    # Eliminăm % din procent
    percent="${percent%\%}"
    
    # Obținem și statistici I/O dacă sunt disponibile
    local device io_stats=""
    device=$(findmnt -n -o SOURCE "$mount_point" 2>/dev/null)
    
    if [[ -n "$device" ]]; then
        # Extragem doar numele device-ului (fără /dev/)
        local dev_name="${device##*/}"
        
        # Citim statistici din /sys/block sau /proc/diskstats
        if [[ -f "/sys/block/${dev_name}/stat" ]]; then
            local reads writes
            read -r reads _ _ _ writes _ <<< "$(cat /sys/block/${dev_name}/stat)"
            io_stats="reads=$reads,writes=$writes"
        fi
    fi
    
    case "$format" in
        json)
            cat <<-EOF
			{
			    "mount_point": "$mount_point",
			    "filesystem": "$filesystem",
			    "size_bytes": $size,
			    "used_bytes": $used,
			    "available_bytes": $available,
			    "percent_used": $percent,
			    "io_stats": "$io_stats"
			}
			EOF
            ;;
        csv)
            echo "$mount_point,$filesystem,$size,$used,$available,$percent"
            ;;
        *)
            echo "Disk [$mount_point]: $(format_bytes "$used") / $(format_bytes "$size") (${percent}%)"
            echo "  Disponibil: $(format_bytes "$available")"
            [[ -n "$io_stats" ]] && echo "  I/O: $io_stats"
            ;;
    esac
}
```

### 3.4 Funcția get_process_info()

```bash
get_process_info() {
    local limit="${1:-10}"
    local sort_by="${2:-cpu}"
    local format="${3:-human}"
    
    local ps_output sort_field
    
    # Determinăm câmpul de sortare
    case "$sort_by" in
        cpu)    sort_field="-%cpu" ;;
        memory) sort_field="-%mem" ;;
        pid)    sort_field="pid" ;;
        time)   sort_field="-time" ;;
        *)      sort_field="-%cpu" ;;
    esac
    
    # Colectăm informații despre procese
    # Folosim ps cu format personalizat
    ps_output=$(ps ax --no-headers \
        -o pid,user,%cpu,%mem,vsz,rss,stat,start,time,comm \
        --sort="$sort_field" 2>/dev/null | head -n "$limit")
    
    # Verificăm și procesele zombie
    local zombie_count
    zombie_count=$(ps ax -o stat | grep -c '^Z' 2>/dev/null || echo "0")
    
    # Numărăm total procese și thread-uri
    local proc_count thread_count
    proc_count=$(ps ax --no-headers | wc -l)
    thread_count=$(ps axH --no-headers 2>/dev/null | wc -l || echo "N/A")
    
    case "$format" in
        json)
            echo "{"
            echo "  \"total_processes\": $proc_count,"
            echo "  \"total_threads\": $thread_count,"
            echo "  \"zombie_processes\": $zombie_count,"
            echo "  \"top_processes\": ["
            
            local first=true
            while IFS= read -r line; do
                [[ -z "$line" ]] && continue
                read -r pid user cpu mem vsz rss stat start time comm <<< "$line"
                
                $first || echo ","
                first=false
                
                printf '    {"pid": %d, "user": "%s", "cpu": %s, "mem": %s, "command": "%s"}' \
                    "$pid" "$user" "$cpu" "$mem" "$comm"
            done <<< "$ps_output"
            
            echo ""
            echo "  ]"
            echo "}"
            ;;
            
        csv)
            echo "pid,user,cpu,mem,vsz,rss,stat,start,time,command"
            while IFS= read -r line; do
                [[ -z "$line" ]] && continue
                read -r pid user cpu mem vsz rss stat start time comm <<< "$line"
                echo "$pid,$user,$cpu,$mem,$vsz,$rss,$stat,$start,$time,$comm"
            done <<< "$ps_output"
            ;;
            
        *)
            echo "=== Procese (Top $limit by $sort_by) ==="
            echo "Total: $proc_count procese, $thread_count thread-uri, $zombie_count zombie"
            echo ""
            printf "%-7s %-10s %6s %6s %10s %10s %s\n" \
                "PID" "USER" "CPU%" "MEM%" "VSZ" "RSS" "COMMAND"
            echo "--------------------------------------------------------------"
            
            while IFS= read -r line; do
                [[ -z "$line" ]] && continue
                read -r pid user cpu mem vsz rss stat start time comm <<< "$line"
                printf "%-7d %-10s %6s %6s %10s %10s %s\n" \
                    "$pid" "$user" "$cpu" "$mem" \
                    "$(format_bytes $((vsz * 1024)))" \
                    "$(format_bytes $((rss * 1024)))" \
                    "$comm"
            done <<< "$ps_output"
            ;;
    esac
}
```

### 3.5 Funcția check_thresholds()

```bash
check_thresholds() {
    local metric="$1"
    local value="$2"
    local warning_level critical_level
    
    # Obținem threshold-urile din configurare
    warning_level=$(get_config "${metric}_warning" "80")
    critical_level=$(get_config "${metric}_critical" "95")
    
    # Convertim valoarea la întreg pentru comparație
    local int_value
    int_value=$(printf "%.0f" "$value" 2>/dev/null || echo "0")
    
    # Verificăm nivelurile
    if [[ $int_value -ge $critical_level ]]; then
        send_alert "CRITICAL" "$metric" "$value" "$critical_level"
        return 2
    elif [[ $int_value -ge $warning_level ]]; then
        send_alert "WARNING" "$metric" "$value" "$warning_level"
        return 1
    fi
    
    return 0
}

send_alert() {
    local level="$1"
    local metric="$2"
    local value="$3"
    local threshold="$4"
    local timestamp
    
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Logăm alerta
    log_message "$level" "[$metric] Value: $value exceeds threshold: $threshold"
    
    # Executăm hook de alertă dacă este definit
    local alert_command
    alert_command=$(get_config "alert_command" "")
    
    if [[ -n "$alert_command" ]]; then
        # Exportăm variabile pentru scriptul extern
        export ALERT_LEVEL="$level"
        export ALERT_METRIC="$metric"
        export ALERT_VALUE="$value"
        export ALERT_THRESHOLD="$threshold"
        export ALERT_TIMESTAMP="$timestamp"
        
        # Executăm comanda
        eval "$alert_command" 2>/dev/null || \
            log_warning "Alert command failed: $alert_command"
    fi
    
    # Scriem în fișier de alerte
    local alert_file
    alert_file=$(get_config "alert_file" "/var/log/monitor_alerts.log")
    
    if [[ -w "$(dirname "$alert_file")" ]]; then
        printf "%s [%s] %s: %s (threshold: %s)\n" \
            "$timestamp" "$level" "$metric" "$value" "$threshold" \
            >> "$alert_file"
    fi
}
```

---

## 4. Modulul Utilități - monitor_utils.sh

### 4.1 Funcții de Logging

```bash
# Niveluri de log cu coduri ANSI pentru culori
declare -A LOG_LEVELS=(
    [DEBUG]=0
    [INFO]=1
    [WARNING]=2
    [ERROR]=3
    [CRITICAL]=4
)

declare -A LOG_COLORS=(
    [DEBUG]="\e[36m"      # Cyan
    [INFO]="\e[32m"       # Verde
    [WARNING]="\e[33m"    # Galben
    [ERROR]="\e[31m"      # Roșu
    [CRITICAL]="\e[1;31m" # Roșu bold
)

RESET_COLOR="\e[0m"

log_message() {
    local level="${1:-INFO}"
    local message="$2"
    local timestamp
    
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Verificăm nivelul minim de logging
    local min_level current_level
    min_level="${LOG_LEVELS[${LOG_LEVEL:-INFO}]}"
    current_level="${LOG_LEVELS[$level]}"
    
    [[ $current_level -lt $min_level ]] && return 0
    
    # Formatăm mesajul
    local formatted_message="[$timestamp] [$level] $message"
    
    # Scriem în log file dacă este definit
    if [[ -n "$LOG_FILE" && -w "$(dirname "$LOG_FILE")" ]]; then
        echo "$formatted_message" >> "$LOG_FILE"
    fi
    
    # Afișăm la terminal cu culori (dacă este TTY)
    if [[ -t 2 ]]; then
        printf "%b%s%b\n" "${LOG_COLORS[$level]}" "$formatted_message" "$RESET_COLOR" >&2
    else
        echo "$formatted_message" >&2
    fi
}

# Funcții wrapper pentru conveniență
log_debug()    { log_message "DEBUG" "$*"; }
log_info()     { log_message "INFO" "$*"; }
log_warning()  { log_message "WARNING" "$*"; }
log_error()    { log_message "ERROR" "$*"; }
log_critical() { log_message "CRITICAL" "$*"; }
```

### 4.2 Funcții de Formatare

```bash
format_bytes() {
    local bytes="${1:-0}"
    local precision="${2:-2}"
    
    # Validăm input-ul
    if ! [[ "$bytes" =~ ^[0-9]+$ ]]; then
        echo "0 B"
        return
    fi
    
    local units=("B" "KiB" "MiB" "GiB" "TiB" "PiB")
    local unit_index=0
    local value="$bytes"
    
    # Folosim bc pentru precizie în calcule
    while [[ $(echo "$value >= 1024" | bc -l) -eq 1 ]] && [[ $unit_index -lt 5 ]]; do
        value=$(echo "scale=10; $value / 1024" | bc -l)
        ((unit_index++))
    done
    
    # Formatăm rezultatul
    printf "%.*f %s" "$precision" "$value" "${units[$unit_index]}"
}

format_duration() {
    local seconds="${1:-0}"
    
    if [[ $seconds -lt 60 ]]; then
        echo "${seconds}s"
    elif [[ $seconds -lt 3600 ]]; then
        printf "%dm %ds" $((seconds / 60)) $((seconds % 60))
    elif [[ $seconds -lt 86400 ]]; then
        printf "%dh %dm" $((seconds / 3600)) $(((seconds % 3600) / 60))
    else
        printf "%dd %dh" $((seconds / 86400)) $(((seconds % 86400) / 3600))
    fi
}

format_percentage() {
    local value="$1"
    local decimals="${2:-1}"
    local bar_width="${3:-20}"
    
    # Calculăm numărul de caractere pentru bară
    local filled
    filled=$(printf "%.0f" "$(echo "$value * $bar_width / 100" | bc -l)")
    local empty=$((bar_width - filled))
    
    # Construim bara vizuală
    local bar=""
    bar+=$(printf '%*s' "$filled" '' | tr ' ' '█')
    bar+=$(printf '%*s' "$empty" '' | tr ' ' '░')
    
    # Alegem culoarea în funcție de valoare
    local color
    if (( $(echo "$value >= 90" | bc -l) )); then
        color="\e[31m"  # Roșu
    elif (( $(echo "$value >= 70" | bc -l) )); then
        color="\e[33m"  # Galben
    else
        color="\e[32m"  # Verde
    fi
    
    printf "%b[%s]%b %.*f%%" "$color" "$bar" "$RESET_COLOR" "$decimals" "$value"
}
```

### 4.3 Funcții de Validare

```bash
is_numeric() {
    local value="$1"
    [[ "$value" =~ ^-?[0-9]+\.?[0-9]*$ ]]
}

is_integer() {
    local value="$1"
    [[ "$value" =~ ^-?[0-9]+$ ]]
}

is_positive_integer() {
    local value="$1"
    [[ "$value" =~ ^[0-9]+$ ]] && [[ "$value" -gt 0 ]]
}

validate_percentage() {
    local value="$1"
    is_numeric "$value" && \
        (( $(echo "$value >= 0 && $value <= 100" | bc -l) ))
}

validate_path() {
    local path="$1"
    local type="${2:-any}"  # file, dir, any
    
    case "$type" in
        file) [[ -f "$path" ]] ;;
        dir)  [[ -d "$path" ]] ;;
        *)    [[ -e "$path" ]] ;;
    esac
}
```

### 4.4 Funcții Ajutătoare

```bash
# Generare timestamp unic
generate_timestamp() {
    date '+%Y%m%d_%H%M%S'
}

# Verificare dacă rulăm ca root
is_root() {
    [[ $EUID -eq 0 ]]
}

# Obținere informații sistem
get_hostname() {
    hostname -s 2>/dev/null || cat /etc/hostname 2>/dev/null || echo "unknown"
}

get_kernel_version() {
    uname -r
}

get_uptime_seconds() {
    cut -d' ' -f1 /proc/uptime | cut -d'.' -f1
}

# Array-uri asociative pentru cache
declare -A _CACHE
declare -A _CACHE_EXPIRY

cache_set() {
    local key="$1"
    local value="$2"
    local ttl="${3:-60}"  # Time-to-live în secunde
    
    _CACHE["$key"]="$value"
    _CACHE_EXPIRY["$key"]=$(($(date +%s) + ttl))
}

cache_get() {
    local key="$1"
    local now
    
    now=$(date +%s)
    
    if [[ -n "${_CACHE[$key]}" ]] && [[ ${_CACHE_EXPIRY[$key]} -gt $now ]]; then
        echo "${_CACHE[$key]}"
        return 0
    fi
    
    return 1
}

cache_invalidate() {
    local key="$1"
    unset "_CACHE[$key]"
    unset "_CACHE_EXPIRY[$key]"
}
```

---

## 5. Modulul Configurare - monitor_config.sh

### 5.1 Încărcarea Configurației

```bash
# Variabile globale pentru configurare
declare -A CONFIG
declare CONFIG_FILE=""
declare CONFIG_LOADED=false

load_config() {
    local config_file="${1:-}"
    
    # Căutăm fișierul de configurare în ordinea priorității
    local search_paths=(
        "$config_file"
        "${HOME}/.config/monitor/monitor.conf"
        "${HOME}/.monitor.conf"
        "/etc/monitor/monitor.conf"
        "${SCRIPT_DIR}/config/monitor.conf"
    )
    
    for path in "${search_paths[@]}"; do
        [[ -z "$path" ]] && continue
        
        if [[ -f "$path" && -r "$path" ]]; then
            CONFIG_FILE="$path"
            break
        fi
    done
    
    if [[ -z "$CONFIG_FILE" ]]; then
        log_warning "Nu s-a găsit fișier de configurare, folosim valori default"
        set_defaults
        CONFIG_LOADED=true
        return 0
    fi
    
    log_info "Încărc configurarea din: $CONFIG_FILE"
    
    # Parsăm fișierul de configurare
    parse_config_file "$CONFIG_FILE"
    
    # Validăm configurarea
    validate_config || return 1
    
    CONFIG_LOADED=true
    return 0
}

parse_config_file() {
    local file="$1"
    local line_num=0
    
    while IFS= read -r line || [[ -n "$line" ]]; do
        ((line_num++))
        
        # Ignorăm linii goale și comentarii
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
        
        # Eliminăm spații de la început/sfârșit
        line="${line#"${line%%[![:space:]]*}"}"
        line="${line%"${line##*[![:space:]]}"}"
        
        # Verificăm formatul key=value
        if [[ "$line" =~ ^([a-zA-Z_][a-zA-Z0-9_]*)=(.*)$ ]]; then
            local key="${BASH_REMATCH[1]}"
            local value="${BASH_REMATCH[2]}"
            
            # Eliminăm ghilimele dacă există
            value="${value#[\"\']}"
            value="${value%[\"\']}"
            
            # Expandăm variabile de mediu
            value=$(eval echo "$value" 2>/dev/null) || value="${BASH_REMATCH[2]}"
            
            CONFIG["$key"]="$value"
            log_debug "Config: $key = $value"
        else
            log_warning "Linia $line_num ignorată (format invalid): $line"
        fi
    done < "$file"
}
```

### 5.2 Validarea Configurației

```bash
validate_config() {
    local errors=0
    
    # Validăm threshold-uri
    for metric in cpu memory disk swap; do
        for level in warning critical; do
            local key="${metric}_${level}"
            local value="${CONFIG[$key]:-}"
            
            if [[ -n "$value" ]]; then
                if ! validate_percentage "$value"; then
                    log_error "Valoare invalidă pentru $key: $value (trebuie 0-100)"
                    ((errors++))
                fi
            fi
        done
    done
    
    # Validăm că warning < critical
    for metric in cpu memory disk swap; do
        local warning="${CONFIG[${metric}_warning]:-80}"
        local critical="${CONFIG[${metric}_critical]:-95}"
        
        if (( $(echo "$warning >= $critical" | bc -l) )); then
            log_error "Pentru $metric: warning ($warning) >= critical ($critical)"
            ((errors++))
        fi
    done
    
    # Validăm intervalul de monitoring
    local interval="${CONFIG[monitor_interval]:-5}"
    if ! is_positive_integer "$interval"; then
        log_error "monitor_interval invalid: $interval"
        ((errors++))
    fi
    
    # Validăm căi
    local log_dir="${CONFIG[log_dir]:-/var/log/monitor}"
    if [[ ! -d "$log_dir" ]]; then
        mkdir -p "$log_dir" 2>/dev/null || {
            log_warning "Nu pot crea directorul de log: $log_dir"
        }
    fi
    
    return $((errors > 0 ? 1 : 0))
}
```

### 5.3 Acces la Configurație

```bash
get_config() {
    local key="$1"
    local default="${2:-}"
    
    if [[ -n "${CONFIG[$key]+isset}" ]]; then
        echo "${CONFIG[$key]}"
    else
        echo "$default"
    fi
}

set_config() {
    local key="$1"
    local value="$2"
    
    CONFIG["$key"]="$value"
    log_debug "Config updated: $key = $value"
}

set_defaults() {
    # Threshold-uri CPU
    CONFIG[cpu_warning]=80
    CONFIG[cpu_critical]=95
    
    # Threshold-uri memorie
    CONFIG[memory_warning]=80
    CONFIG[memory_critical]=95
    
    # Threshold-uri disk
    CONFIG[disk_warning]=80
    CONFIG[disk_critical]=95
    
    # Threshold-uri swap
    CONFIG[swap_warning]=50
    CONFIG[swap_critical]=80
    
    # Setări generale
    CONFIG[monitor_interval]=5
    CONFIG[output_format]="human"
    CONFIG[log_level]="INFO"
    CONFIG[log_dir]="/var/log/monitor"
    CONFIG[enable_alerts]=true
    CONFIG[alert_command]=""
    
    # Setări procese
    CONFIG[top_processes]=10
    CONFIG[process_sort]="cpu"
    
    # Puncte de mount pentru monitorizare disk
    CONFIG[disk_mounts]="/"
    
    log_debug "Valorile default au fost setate"
}

# Export configurație în format human-readable
dump_config() {
    echo "=== Configurare Curentă ==="
    echo "Config file: ${CONFIG_FILE:-none}"
    echo ""
    
    for key in $(echo "${!CONFIG[@]}" | tr ' ' '\n' | sort); do
        printf "%-25s = %s\n" "$key" "${CONFIG[$key]}"
    done
}
```

---

## 6. Scriptul Principal - monitor.sh

### 6.1 Inițializare și Bootstrap

```bash
#!/usr/bin/env bash
#
# monitor.sh - System Resource Monitor
# Proiect CAPSTONE - Sisteme de Operare
#

set -o errexit   # Exit on error
set -o nounset   # Exit on undefined variable
set -o pipefail  # Pipeline returns last non-zero status

# Determinăm directorul scriptului
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly VERSION="1.0.0"

# Directoare standard
readonly LIB_DIR="${SCRIPT_DIR}/lib"
readonly CONFIG_DIR="${SCRIPT_DIR}/config"

# Verificăm existența modulelor
for module in monitor_utils monitor_config monitor_core; do
    module_path="${LIB_DIR}/${module}.sh"
    if [[ ! -f "$module_path" ]]; then
        echo "EROARE: Modulul lipsește: $module_path" >&2
        exit 1
    fi
done

# Încărcăm modulele în ordinea corectă
source "${LIB_DIR}/monitor_utils.sh"
source "${LIB_DIR}/monitor_config.sh"
source "${LIB_DIR}/monitor_core.sh"
```

### 6.2 Parsarea Argumentelor

```bash
# Variabile pentru argumente
declare -g OUTPUT_FORMAT="human"
declare -g DAEMON_MODE=false
declare -g SINGLE_RUN=false
declare -g CUSTOM_CONFIG=""
declare -g VERBOSE=false
declare -g MONITOR_CPU=true
declare -g MONITOR_MEMORY=true
declare -g MONITOR_DISK=true
declare -g MONITOR_PROCESSES=true

show_help() {
    cat <<EOF
Utilizare: $SCRIPT_NAME [OPȚIUNI]

System Resource Monitor - Monitorizează resursele sistemului

Opțiuni:
  -h, --help              Afișează acest mesaj
  -V, --version           Afișează versiunea
  -c, --config FILE       Folosește fișier de configurare specific
  -f, --format FORMAT     Format output: human, json, csv (default: human)
  -1, --once              Rulează o singură dată și ieși
  -d, --daemon            Rulează în mod daemon (background)
  -v, --verbose           Afișează informații detaliate
  -i, --interval SEC      Interval între măsurători (default: 5)
  
Selectare metrici (implicit toate):
  --cpu                   Monitorizează doar CPU
  --memory                Monitorizează doar memoria
  --disk                  Monitorizează doar disk-ul
  --processes             Monitorizează doar procesele
  --all                   Monitorizează toate (default)
  
Threshold override:
  --cpu-warning N         Setează warning CPU la N%
  --cpu-critical N        Setează critical CPU la N%
  --mem-warning N         Setează warning memorie la N%
  --mem-critical N        Setează critical memorie la N%

Exemple:
  $SCRIPT_NAME                    # Monitorizare continuă, format human
  $SCRIPT_NAME -1 -f json         # O singură rulare, output JSON
  $SCRIPT_NAME --cpu --memory     # Doar CPU și memorie
  $SCRIPT_NAME -d -i 60           # Daemon cu interval 60 secunde

EOF
}

parse_arguments() {
    local metrics_specified=false
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            -V|--version)
                echo "$SCRIPT_NAME versiunea $VERSION"
                exit 0
                ;;
            -c|--config)
                CUSTOM_CONFIG="$2"
                shift 2
                ;;
            -f|--format)
                OUTPUT_FORMAT="$2"
                shift 2
                ;;
            -1|--once)
                SINGLE_RUN=true
                shift
                ;;
            -d|--daemon)
                DAEMON_MODE=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                LOG_LEVEL="DEBUG"
                shift
                ;;
            -i|--interval)
                CONFIG[monitor_interval]="$2"
                shift 2
                ;;
            --cpu)
                if ! $metrics_specified; then
                    MONITOR_MEMORY=false
                    MONITOR_DISK=false
                    MONITOR_PROCESSES=false
                    metrics_specified=true
                fi
                MONITOR_CPU=true
                shift
                ;;
            --memory)
                if ! $metrics_specified; then
                    MONITOR_CPU=false
                    MONITOR_DISK=false
                    MONITOR_PROCESSES=false
                    metrics_specified=true
                fi
                MONITOR_MEMORY=true
                shift
                ;;
            --disk)
                if ! $metrics_specified; then
                    MONITOR_CPU=false
                    MONITOR_MEMORY=false
                    MONITOR_PROCESSES=false
                    metrics_specified=true
                fi
                MONITOR_DISK=true
                shift
                ;;
            --processes)
                if ! $metrics_specified; then
                    MONITOR_CPU=false
                    MONITOR_MEMORY=false
                    MONITOR_DISK=false
                    metrics_specified=true
                fi
                MONITOR_PROCESSES=true
                shift
                ;;
            --all)
                MONITOR_CPU=true
                MONITOR_MEMORY=true
                MONITOR_DISK=true
                MONITOR_PROCESSES=true
                shift
                ;;
            --cpu-warning)
                CONFIG[cpu_warning]="$2"
                shift 2
                ;;
            --cpu-critical)
                CONFIG[cpu_critical]="$2"
                shift 2
                ;;
            --mem-warning)
                CONFIG[memory_warning]="$2"
                shift 2
                ;;
            --mem-critical)
                CONFIG[memory_critical]="$2"
                shift 2
                ;;
            -*)
                log_error "Opțiune necunoscută: $1"
                show_help
                exit 1
                ;;
            *)
                log_error "Argument neașteptat: $1"
                show_help
                exit 1
                ;;
        esac
    done
}
```

### 6.3 Ciclul Principal de Monitorizare

```bash
run_monitoring_cycle() {
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case "$OUTPUT_FORMAT" in
        json)
            echo "{"
            echo "  \"timestamp\": \"$timestamp\","
            echo "  \"hostname\": \"$(get_hostname)\","
            echo "  \"metrics\": {"
            ;;
        csv)
            # Header CSV la prima rulare
            if [[ "${FIRST_RUN:-true}" == "true" ]]; then
                echo "timestamp,metric,value,unit,status"
                FIRST_RUN=false
            fi
            ;;
        *)
            echo ""
            echo "╔════════════════════════════════════════════════════════════════╗"
            printf "║  System Monitor - %-42s  ║\n" "$timestamp"
            printf "║  Host: %-52s  ║\n" "$(get_hostname)"
            echo "╚════════════════════════════════════════════════════════════════╝"
            ;;
    esac
    
    local first_metric=true
    
    # Monitorizare CPU
    if $MONITOR_CPU; then
        local cpu_usage
        cpu_usage=$(get_cpu_usage)
        
        $first_metric || [[ "$OUTPUT_FORMAT" == "json" ]] && echo ","
        first_metric=false
        
        output_metric "cpu" "$cpu_usage" "%"
        check_thresholds "cpu" "$cpu_usage"
    fi
    
    # Monitorizare Memorie
    if $MONITOR_MEMORY; then
        local mem_info
        mem_info=$(get_memory_info "raw")
        
        # Parsăm valorile
        local mem_percent
        mem_percent=$(echo "$mem_info" | grep -oP 'percent=\K[0-9.]+')
        
        [[ "$OUTPUT_FORMAT" == "json" ]] && ! $first_metric && echo ","
        first_metric=false
        
        output_metric "memory" "$mem_percent" "%"
        check_thresholds "memory" "$mem_percent"
        
        # Afișăm detalii în modul verbose
        if $VERBOSE; then
            get_memory_info "$OUTPUT_FORMAT"
        fi
    fi
    
    # Monitorizare Disk
    if $MONITOR_DISK; then
        local mounts
        IFS=',' read -ra mounts <<< "$(get_config 'disk_mounts' '/')"
        
        for mount in "${mounts[@]}"; do
            local disk_percent
            disk_percent=$(get_disk_usage "$mount" "percent")
            
            [[ "$OUTPUT_FORMAT" == "json" ]] && ! $first_metric && echo ","
            first_metric=false
            
            output_metric "disk_${mount//\//_}" "$disk_percent" "%"
            check_thresholds "disk" "$disk_percent"
        done
    fi
    
    # Monitorizare Procese
    if $MONITOR_PROCESSES; then
        if $VERBOSE || [[ "$OUTPUT_FORMAT" == "json" ]]; then
            [[ "$OUTPUT_FORMAT" == "json" ]] && ! $first_metric && echo ","
            
            local limit
            limit=$(get_config "top_processes" "10")
            local sort_by
            sort_by=$(get_config "process_sort" "cpu")
            
            get_process_info "$limit" "$sort_by" "$OUTPUT_FORMAT"
        fi
    fi
    
    # Închidere output JSON
    if [[ "$OUTPUT_FORMAT" == "json" ]]; then
        echo ""
        echo "  }"
        echo "}"
    fi
}

output_metric() {
    local name="$1"
    local value="$2"
    local unit="${3:-}"
    
    local status="OK"
    local warning critical
    warning=$(get_config "${name}_warning" "80")
    critical=$(get_config "${name}_critical" "95")
    
    local int_value
    int_value=$(printf "%.0f" "$value" 2>/dev/null || echo "0")
    
    if [[ $int_value -ge $critical ]]; then
        status="CRITICAL"
    elif [[ $int_value -ge $warning ]]; then
        status="WARNING"
    fi
    
    case "$OUTPUT_FORMAT" in
        json)
            printf '    "%s": {"value": %s, "unit": "%s", "status": "%s"}' \
                "$name" "$value" "$unit" "$status"
            ;;
        csv)
            printf "%s,%s,%s,%s,%s\n" \
                "$(date '+%Y-%m-%d %H:%M:%S')" "$name" "$value" "$unit" "$status"
            ;;
        *)
            local label
            label=$(echo "$name" | tr '_' ' ' | sed 's/\b\(.\)/\u\1/g')
            printf "  %-20s: " "$label"
            format_percentage "$value"
            [[ "$status" != "OK" ]] && printf " [%s]" "$status"
            echo ""
            ;;
    esac
}
```

### 6.4 Funcția Main și Cleanup

```bash
# Variabile pentru control
declare -g RUNNING=true
declare -g PID_FILE="/var/run/monitor.pid"

cleanup() {
    log_info "Oprire monitor..."
    RUNNING=false
    
    # Ștergem PID file dacă există
    [[ -f "$PID_FILE" ]] && rm -f "$PID_FILE"
    
    log_info "Monitor oprit"
    exit 0
}

# Instalăm signal handlers
trap cleanup SIGINT SIGTERM SIGHUP

daemonize() {
    # Verificăm dacă deja rulează
    if [[ -f "$PID_FILE" ]]; then
        local old_pid
        old_pid=$(cat "$PID_FILE")
        
        if kill -0 "$old_pid" 2>/dev/null; then
            log_error "Monitor deja rulează cu PID $old_pid"
            exit 1
        else
            log_warning "PID file vechi găsit, îl șterg"
            rm -f "$PID_FILE"
        fi
    fi
    
    # Fork în background
    log_info "Pornire în mod daemon..."
    
    # Redirectăm output
    exec >> "${LOG_FILE:-/dev/null}" 2>&1
    
    # Scriem PID
    echo $$ > "$PID_FILE"
    
    log_info "Daemon pornit cu PID $$"
}

main() {
    # Parsăm argumentele
    parse_arguments "$@"
    
    # Încărcăm configurarea
    load_config "$CUSTOM_CONFIG" || {
        log_error "Eroare la încărcarea configurației"
        exit 1
    }
    
    # Mod daemon
    if $DAEMON_MODE; then
        daemonize
    fi
    
    # Mod single run
    if $SINGLE_RUN; then
        run_monitoring_cycle
        exit 0
    fi
    
    # Ciclul principal de monitorizare
    local interval
    interval=$(get_config "monitor_interval" "5")
    
    log_info "Pornire monitorizare (interval: ${interval}s)"
    
    while $RUNNING; do
        run_monitoring_cycle
        sleep "$interval"
    done
}

# Rulăm main doar dacă scriptul este executat direct
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

---

## 7. Fluxul de Execuție

### 7.1 Diagrama de Flux

```
┌─────────────────────────────────────────────────────────────────┐
│                          START                                   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Încărcare module                              │
│    monitor_utils.sh → monitor_config.sh → monitor_core.sh       │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                  Parsare argumente CLI                           │
│         --format, --once, --daemon, --cpu, etc.                  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                  Încărcare configurație                          │
│        ~/.config/monitor/monitor.conf sau default                │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │  Daemon mode?   │
                    └─────────────────┘
                      │           │
                  Yes │           │ No
                      ▼           │
         ┌────────────────────┐   │
         │    daemonize()     │   │
         │  Fork background   │   │
         │  Write PID file    │   │
         └────────────────────┘   │
                      │           │
                      └─────┬─────┘
                            │
                            ▼
                    ┌─────────────────┐
                    │  Single run?    │
                    └─────────────────┘
                      │           │
                  Yes │           │ No
                      ▼           │
    ┌───────────────────────────┐ │
    │ run_monitoring_cycle()    │ │
    │        exit 0             │ │
    └───────────────────────────┘ │
                                  │
                                  ▼
              ┌────────────────────────────────┐
              │      MONITORING LOOP           │
              │ ┌────────────────────────────┐ │
              │ │ run_monitoring_cycle()     │ │
              │ │  ├─ get_cpu_usage()        │ │
              │ │  ├─ get_memory_info()      │ │
              │ │  ├─ get_disk_usage()       │ │
              │ │  ├─ get_process_info()     │ │
              │ │  └─ check_thresholds()     │ │
              │ └────────────────────────────┘ │
              │              │                 │
              │              ▼                 │
              │    sleep $interval            │
              │              │                 │
              │   ┌──────────┴──────────┐     │
              │   │   RUNNING=true?     │     │
              │   └──────────┬──────────┘     │
              │          Yes │                 │
              │              └─────────────────┤
              │                                │
              └────────────────────────────────┘
                               │
                          No   │
                               ▼
                    ┌─────────────────┐
                    │    cleanup()    │
                    │    exit 0       │
                    └─────────────────┘
```

### 7.2 Secvența de Apeluri (pentru un ciclu)

```
main()
├── parse_arguments()
├── load_config()
│   ├── parse_config_file()
│   └── validate_config()
└── monitoring loop
    └── run_monitoring_cycle()
        ├── get_cpu_usage()
        │   ├── read /proc/stat
        │   ├── sleep 1
        │   ├── read /proc/stat again
        │   └── calculate difference
        ├── get_memory_info()
        │   └── parse /proc/meminfo
        ├── get_disk_usage()
        │   ├── df command
        │   └── read /sys/block/*/stat
        ├── get_process_info()
        │   └── ps command
        ├── check_thresholds()
        │   └── send_alert() [if needed]
        └── output_metric()
            └── format_percentage()
```

---

## 8. Tehnici Avansate de Monitorizare

### 8.1 Monitorizare per-CPU Core

```bash
get_per_cpu_usage() {
    local -A prev_stats curr_stats
    local cpu_count cpu_id
    
    # Numărăm CPU-urile
    cpu_count=$(grep -c '^processor' /proc/cpuinfo)
    
    # Prima citire
    while IFS= read -r line; do
        if [[ "$line" =~ ^cpu([0-9]+) ]]; then
            cpu_id="${BASH_REMATCH[1]}"
            read -r _ user nice system idle iowait irq softirq steal _ <<< "$line"
            prev_stats["${cpu_id}_idle"]=$((idle + iowait))
            prev_stats["${cpu_id}_total"]=$((user + nice + system + idle + iowait + irq + softirq + steal))
        fi
    done < /proc/stat
    
    sleep "${CPU_SAMPLE_INTERVAL:-1}"
    
    # A doua citire și calcul
    echo "{"
    echo "  \"cpu_count\": $cpu_count,"
    echo "  \"per_cpu\": ["
    
    local first=true
    while IFS= read -r line; do
        if [[ "$line" =~ ^cpu([0-9]+) ]]; then
            cpu_id="${BASH_REMATCH[1]}"
            read -r _ user nice system idle iowait irq softirq steal _ <<< "$line"
            
            local curr_idle=$((idle + iowait))
            local curr_total=$((user + nice + system + idle + iowait + irq + softirq + steal))
            
            local diff_idle=$((curr_idle - prev_stats["${cpu_id}_idle"]))
            local diff_total=$((curr_total - prev_stats["${cpu_id}_total"]))
            
            local usage
            if [[ $diff_total -gt 0 ]]; then
                usage=$(awk "BEGIN {printf \"%.1f\", (1 - $diff_idle / $diff_total) * 100}")
            else
                usage="0.0"
            fi
            
            $first || echo ","
            first=false
            printf '    {"core": %d, "usage": %s}' "$cpu_id" "$usage"
        fi
    done < /proc/stat
    
    echo ""
    echo "  ]"
    echo "}"
}
```

### 8.2 Monitorizare Load Average și Context Switches

```bash
get_system_load() {
    local load_1 load_5 load_15 running_procs total_procs
    
    # Load average din /proc/loadavg
    read -r load_1 load_5 load_15 procs _ < /proc/loadavg
    
    # Parsăm running/total processes
    IFS='/' read -r running_procs total_procs <<< "$procs"
    
    # Context switches din /proc/stat
    local context_switches
    context_switches=$(grep '^ctxt' /proc/stat | awk '{print $2}')
    
    # Interrupts
    local interrupts
    interrupts=$(grep '^intr' /proc/stat | awk '{print $2}')
    
    cat <<EOF
{
    "load_average": {
        "1min": $load_1,
        "5min": $load_5,
        "15min": $load_15
    },
    "processes": {
        "running": $running_procs,
        "total": $total_procs
    },
    "context_switches": $context_switches,
    "interrupts": $interrupts
}
EOF
}
```

### 8.3 Monitorizare I/O și Network

```bash
get_io_stats() {
    local device="${1:-}"
    
    # Dacă nu e specificat, folosim toate device-urile block
    if [[ -z "$device" ]]; then
        local devices
        devices=$(lsblk -d -n -o NAME | grep -v '^loop')
    else
        devices="$device"
    fi
    
    echo "{"
    echo "  \"io_stats\": ["
    
    local first=true
    for dev in $devices; do
        [[ ! -f "/sys/block/$dev/stat" ]] && continue
        
        read -r reads read_merges read_sectors read_time \
             writes write_merges write_sectors write_time \
             io_in_progress io_time weighted_time \
             < "/sys/block/$dev/stat"
        
        $first || echo ","
        first=false
        
        cat <<EOF
    {
        "device": "$dev",
        "reads": $reads,
        "writes": $writes,
        "read_bytes": $((read_sectors * 512)),
        "write_bytes": $((write_sectors * 512)),
        "io_time_ms": $io_time,
        "weighted_io_time_ms": $weighted_time
    }
EOF
    done
    
    echo ""
    echo "  ]"
    echo "}"
}

get_network_stats() {
    local interface="${1:-}"
    
    echo "{"
    echo "  \"network_stats\": ["
    
    local first=true
    while IFS=': ' read -r iface stats; do
        [[ "$iface" == "Inter-"* || "$iface" == "face" ]] && continue
        [[ -n "$interface" && "$iface" != "$interface" ]] && continue
        
        # Parsăm statisticile
        read -r rx_bytes rx_packets rx_errs rx_drop rx_fifo rx_frame rx_compressed rx_multicast \
             tx_bytes tx_packets tx_errs tx_drop tx_fifo tx_colls tx_carrier tx_compressed \
             <<< "$stats"
        
        $first || echo ","
        first=false
        
        cat <<EOF
    {
        "interface": "$iface",
        "rx_bytes": $rx_bytes,
        "rx_packets": $rx_packets,
        "rx_errors": $rx_errs,
        "rx_dropped": $rx_drop,
        "tx_bytes": $tx_bytes,
        "tx_packets": $tx_packets,
        "tx_errors": $tx_errs,
        "tx_dropped": $tx_drop
    }
EOF
    done < /proc/net/dev
    
    echo ""
    echo "  ]"
    echo "}"
}
```

### 8.4 Monitorizare Temperatură și Senzori

```bash
get_temperature_info() {
    local temps=()
    
    # Căutăm în /sys/class/thermal
    for zone in /sys/class/thermal/thermal_zone*/; do
        [[ ! -d "$zone" ]] && continue
        
        local type temp
        type=$(cat "${zone}type" 2>/dev/null || echo "unknown")
        temp=$(cat "${zone}temp" 2>/dev/null || echo "0")
        
        # Temperatura e în mili-grade Celsius
        local temp_c
        temp_c=$(awk "BEGIN {printf \"%.1f\", $temp / 1000}")
        
        temps+=("{\"zone\": \"$type\", \"temp_celsius\": $temp_c}")
    done
    
    # Căutăm și în hwmon dacă există
    for hwmon in /sys/class/hwmon/hwmon*/; do
        [[ ! -d "$hwmon" ]] && continue
        
        local name
        name=$(cat "${hwmon}name" 2>/dev/null || echo "unknown")
        
        for temp_input in "${hwmon}"temp*_input; do
            [[ ! -f "$temp_input" ]] && continue
            
            local label temp
            local base="${temp_input%_input}"
            
            label=$(cat "${base}_label" 2>/dev/null || echo "${base##*/}")
            temp=$(cat "$temp_input" 2>/dev/null || echo "0")
            
            local temp_c
            temp_c=$(awk "BEGIN {printf \"%.1f\", $temp / 1000}")
            
            temps+=("{\"zone\": \"${name}/${label}\", \"temp_celsius\": $temp_c}")
        done
    done
    
    echo "{"
    echo "  \"temperatures\": ["
    local first=true
    for t in "${temps[@]}"; do
        $first || echo ","
        first=false
        echo "    $t"
    done
    echo ""
    echo "  ]"
    echo "}"
}
```

---

## 9. Exerciții de Implementare

### Exercițiul 1: Adăugare Metrică Nouă

**Obiectiv**: Adăugați monitorizare pentru file descriptors.

```bash
# Implementați această funcție în monitor_core.sh
get_file_descriptors() {
    # TODO: Implementați colectarea:
    # - Număr total FD-uri deschise în sistem
    # - FD-uri per proces (top 5)
    # - Limita sistem (/proc/sys/fs/file-max)
    # - Procentul utilizat
    
    # Hint: /proc/sys/fs/file-nr conține:
    # allocated  free  maximum
    :
}
```

### Exercițiul 2: Export Prometheus

**Obiectiv**: Adăugați export în format Prometheus.

```bash
# Format Prometheus example:
# cpu_usage_percent{host="server1"} 45.2
# memory_used_bytes{host="server1"} 4294967296

output_prometheus() {
    local hostname
    hostname=$(get_hostname)
    
    # TODO: Implementați generarea metricilor în format Prometheus
    # pentru toate resursele monitorizate
    :
}
```

### Exercițiul 3: Alerting Email

**Obiectiv**: Implementați trimitere alerte pe email.

```bash
# Configurație necesară în monitor.conf:
# alert_email_enabled=true
# alert_email_to=contact_eliminat
# alert_email_from=contact_eliminat
# alert_smtp_server=localhost

send_email_alert() {
    local level="$1"
    local metric="$2"
    local value="$3"
    local threshold="$4"
    
    # TODO: Implementați trimiterea emailului
    # folosind sendmail, mailx, sau curl cu SMTP API
    :
}
```

### Exercițiul 4: Istoric și Trending

**Obiectiv**: Implementați salvarea istoricului și detectarea trendurilor.

```bash
# Salvare metrici în fișier CSV rotativ
save_metric_history() {
    local metric="$1"
    local value="$2"
    local history_file="${DATA_DIR}/${metric}_history.csv"
    local max_records=1440  # 24 ore la interval de 1 minut
    
    # TODO: Implementați:
    # 1. Salvare timestamp + valoare
    # 2. Rotire automată când depășește max_records
    # 3. Funcție de calcul trend (growing/stable/declining)
    :
}

calculate_trend() {
    local metric="$1"
    local window="${2:-10}"  # Ultimele N măsurători
    
    # TODO: Calculați dacă metrica crește/scade/stabilă
    # Returnați: "rising", "falling", "stable"
    :
}
```

### Exercițiul 5: Dashboard Terminal

**Obiectiv**: Implementați un dashboard interactiv în terminal.

```bash
# Folosiți tput pentru control terminal
draw_dashboard() {
    # Curățăm ecranul
    tput clear
    
    # TODO: Implementați dashboard cu:
    # - Header cu hostname și timestamp
    # - Bare de progres pentru CPU, memory, disk
    # - Lista top procese
    # - Refresh automat (fără flicker)
    # - Tecla 'q' pentru quit
    
    # Hint: tput cup Y X pentru poziționare cursor
    :
}
```

---

## Concluzii

Proiectul Monitor demonstrează implementarea unui sistem complex de monitorizare folosind exclusiv Bash și utilitățile standard Linux. Punctele cheie sunt:

1. **Arhitectură modulară** - separarea clară a responsabilităților
2. **Parsing eficient** - utilizarea fișierelor virtuale din /proc și /sys
3. **Flexibilitate output** - suport pentru multiple formate
4. **Stabilitate** - gestionarea erorilor și valori default
5. **Extensibilitate** - ușor de adăugat noi metrici

Acest proiect poate fi extins pentru:
- Integrare cu sisteme de monitorizare (Prometheus, Grafana)
- Alerting avansat (PagerDuty, Slack)
- Clustering și agregare date de pe multiple host-uri
- Machine learning pentru detecție anomalii
