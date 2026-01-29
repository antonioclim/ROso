#!/bin/bash
#==============================================================================
# utils.sh - Funcții utilitare pentru colectarea informațiilor de sistem
#==============================================================================
# DESCRIERE:
#   Funcții pentru extragerea metrici de sistem: CPU, memorie, disk, procese.
#   Toate funcțiile returnează valori normalizate și verificate.
#
# DEPENDENȚE:
#   - Trebuie încărcat după core.sh
#   - Comenzi necesare: top, free, df, ps, awk
#
# UTILIZARE:
#   source "${SCRIPT_DIR}/lib/utils.sh"
#
# AUTOR: ASE București - CSIE | Sisteme de Operare
# VERSIUNE: 1.0.0
#==============================================================================

readonly UTILS_VERSION="1.0.0"

#------------------------------------------------------------------------------
# FUNCȚII CPU
#------------------------------------------------------------------------------

# Obține utilizarea CPU totală ca procent
# Returnează: număr întreg 0-100
get_cpu_usage() {
    local cpu_line
    local idle_percent
    local cpu_usage
    
    # Metodă 1: /proc/stat (mai precisă, dar necesită două citiri)
    if [[ -f /proc/stat ]]; then
        # Prima citire
        local cpu1
        cpu1=$(grep '^cpu ' /proc/stat)
        local user1 nice1 system1 idle1 iowait1 irq1 softirq1
        read -r _ user1 nice1 system1 idle1 iowait1 irq1 softirq1 _ <<< "$cpu1"
        
        sleep 0.5
        
        # A doua citire
        local cpu2
        cpu2=$(grep '^cpu ' /proc/stat)
        local user2 nice2 system2 idle2 iowait2 irq2 softirq2
        read -r _ user2 nice2 system2 idle2 iowait2 irq2 softirq2 _ <<< "$cpu2"
        
        # Calcul diferențe
        local total1=$((user1 + nice1 + system1 + idle1 + iowait1 + irq1 + softirq1))
        local total2=$((user2 + nice2 + system2 + idle2 + iowait2 + irq2 + softirq2))
        local idle_diff=$((idle2 - idle1))
        local total_diff=$((total2 - total1))
        
        if [[ $total_diff -gt 0 ]]; then
            cpu_usage=$((100 - (100 * idle_diff / total_diff)))
        else
            cpu_usage=0
        fi
    else
        # Metodă alternativă: top (mai puțin precisă)
        cpu_line=$(top -bn1 | grep "Cpu(s)" 2>/dev/null || top -bn1 | grep "CPU:" 2>/dev/null)
        
        if [[ -n "$cpu_line" ]]; then
            # Extrage idle și calculează usage
            idle_percent=$(echo "$cpu_line" | awk '{
                for(i=1; i<=NF; i++) {
                    if($i ~ /id/) { print $(i-1); exit }
                }
            }' | tr -d '%,')
            
            if [[ -n "$idle_percent" ]]; then
                cpu_usage=$(echo "100 - $idle_percent" | bc 2>/dev/null || echo $((100 - ${idle_percent%.*})))
                cpu_usage=${cpu_usage%.*}  # Convertește la întreg
            else
                cpu_usage=0
            fi
        else
            log_warn "Nu pot determina utilizarea CPU"
            cpu_usage=0
        fi
    fi
    
    # Asigură interval valid 0-100
    if [[ $cpu_usage -lt 0 ]]; then cpu_usage=0; fi
    if [[ $cpu_usage -gt 100 ]]; then cpu_usage=100; fi
    
    echo "$cpu_usage"
}

# Obține numărul de core-uri CPU
get_cpu_cores() {
    local cores
    
    if [[ -f /proc/cpuinfo ]]; then
        cores=$(grep -c "^processor" /proc/cpuinfo)
    else
        cores=$(nproc 2>/dev/null || echo 1)
    fi
    
    echo "$cores"
}

# Obține load average (1, 5, 15 minute)
# Returnează: "load1 load5 load15"
get_load_average() {
    if [[ -f /proc/loadavg ]]; then
        awk '{print $1, $2, $3}' /proc/loadavg
    else
        uptime | awk -F'load average:' '{print $2}' | tr ',' ' ' | xargs
    fi
}

# Verifică dacă load average este critic
# Utilizare: is_load_critical [threshold_multiplier]
# threshold_multiplier: factor de multiplicare pentru nr. de core-uri (default: 2)
is_load_critical() {
    local multiplier="${1:-2}"
    local cores
    cores=$(get_cpu_cores)
    local threshold=$((cores * multiplier))
    
    local load1
    load1=$(get_load_average | awk '{print $1}')
    load1=${load1%.*}  # Convertește la întreg
    
    [[ ${load1:-0} -gt $threshold ]]
}

#------------------------------------------------------------------------------
# FUNCȚII MEMORIE
#------------------------------------------------------------------------------

# Obține utilizarea memoriei ca procent
# Returnează: număr întreg 0-100
get_memory_usage() {
    local mem_usage
    
    if command -v free &>/dev/null; then
        # free cu opțiunea -m pentru valori în MB
        mem_usage=$(free | awk '/^Mem:/ {
            total = $2
            used = $3
            if (total > 0) {
                printf "%.0f", (used / total) * 100
            } else {
                print 0
            }
        }')
    elif [[ -f /proc/meminfo ]]; then
        # Parsare directă /proc/meminfo
        local total available
        total=$(grep "^MemTotal:" /proc/meminfo | awk '{print $2}')
        available=$(grep "^MemAvailable:" /proc/meminfo | awk '{print $2}')
        
        if [[ -z "$available" ]]; then
            # Fallback pentru kernel mai vechi
            local free buffers cached
            free=$(grep "^MemFree:" /proc/meminfo | awk '{print $2}')
            buffers=$(grep "^Buffers:" /proc/meminfo | awk '{print $2}')
            cached=$(grep "^Cached:" /proc/meminfo | awk '{print $2}')
            available=$((free + buffers + cached))
        fi
        
        local used=$((total - available))
        mem_usage=$((used * 100 / total))
    else
        log_warn "Nu pot determina utilizarea memoriei"
        mem_usage=0
    fi
    
    echo "$mem_usage"
}

# Obține detalii memorie: total, used, free, available
# Returnează: "total_mb used_mb free_mb available_mb"
get_memory_details() {
    if command -v free &>/dev/null; then
        free -m | awk '/^Mem:/ {print $2, $3, $4, $7}'
    else
        log_warn "Comanda 'free' nu este disponibilă"
        echo "0 0 0 0"
    fi
}

# Obține utilizarea swap ca procent
get_swap_usage() {
    local swap_usage
    
    swap_usage=$(free | awk '/^Swap:/ {
        total = $2
        used = $3
        if (total > 0) {
            printf "%.0f", (used / total) * 100
        } else {
            print 0
        }
    }')
    
    echo "${swap_usage:-0}"
}

#------------------------------------------------------------------------------
# FUNCȚII DISK
#------------------------------------------------------------------------------

# Obține utilizarea pentru un mount point specific
# Utilizare: get_disk_usage "/mount/point"
# Returnează: număr întreg 0-100
get_disk_usage() {
    local mount_point="${1:-/}"
    local usage
    
    usage=$(df -h "$mount_point" 2>/dev/null | awk 'NR==2 {
        gsub(/%/, "", $5)
        print $5
    }')
    
    echo "${usage:-0}"
}

# Obține informații complete despre toate partițiile
# Format: mount_point|total|used|available|percent
# Exclud: tmpfs, devtmpfs, squashfs
get_all_disk_info() {
    df -h 2>/dev/null | tail -n +2 | grep -v -E "^(tmpfs|devtmpfs|squashfs|overlay)" | \
    while read -r filesystem size used avail percent mount_point; do
        # Curăță procentul
        percent=${percent%\%}
        echo "${mount_point}|${size}|${used}|${avail}|${percent}"
    done
}

# Obține lista mount points cu utilizare peste threshold
# Utilizare: get_disks_over_threshold 85
get_disks_over_threshold() {
    local threshold="${1:-85}"
    
    get_all_disk_info | while IFS='|' read -r mount size used avail percent; do
        if [[ ${percent:-0} -ge $threshold ]]; then
            echo "${mount}:${percent}%"
        fi
    done
}

# Verifică spațiu disponibil în MB pentru un mount point
# Utilizare: get_available_space_mb "/path"
get_available_space_mb() {
    local path="${1:-/}"
    
    df -m "$path" 2>/dev/null | awk 'NR==2 {print $4}'
}

#------------------------------------------------------------------------------
# FUNCȚII PROCESE
#------------------------------------------------------------------------------

# Obține numărul total de procese
get_process_count() {
    ps aux 2>/dev/null | wc -l | awk '{print $1 - 1}'  # -1 pentru header
}

# Obține top N procese după utilizare CPU
# Utilizare: get_top_cpu_processes [N]
get_top_cpu_processes() {
    local count="${1:-5}"
    
    ps aux --sort=-%cpu 2>/dev/null | head -n $((count + 1)) | tail -n "$count" | \
    awk '{printf "%s|%s|%s|%s\n", $2, $11, $3, $4}'
    # Format: PID|COMMAND|CPU%|MEM%
}

# Obține top N procese după utilizare memorie
# Utilizare: get_top_mem_processes [N]
get_top_mem_processes() {
    local count="${1:-5}"
    
    ps aux --sort=-%mem 2>/dev/null | head -n $((count + 1)) | tail -n "$count" | \
    awk '{printf "%s|%s|%s|%s\n", $2, $11, $4, $3}'
    # Format: PID|COMMAND|MEM%|CPU%
}

# Verifică dacă un proces rulează
# Utilizare: is_process_running "process_name"
is_process_running() {
    local process_name="$1"
    pgrep -x "$process_name" &>/dev/null
}

# Obține PID-ul unui proces după nume
get_process_pid() {
    local process_name="$1"
    pgrep -x "$process_name" 2>/dev/null | head -n1
}

#------------------------------------------------------------------------------
# FUNCȚII NETWORK (opționale)
#------------------------------------------------------------------------------

# Obține statistici de rețea pentru o interfață
# Utilizare: get_network_stats "eth0"
get_network_stats() {
    local interface="${1:-eth0}"
    local rx_bytes tx_bytes
    
    if [[ -d "/sys/class/net/$interface" ]]; then
        rx_bytes=$(cat "/sys/class/net/$interface/statistics/rx_bytes" 2>/dev/null || echo 0)
        tx_bytes=$(cat "/sys/class/net/$interface/statistics/tx_bytes" 2>/dev/null || echo 0)
        echo "$rx_bytes $tx_bytes"
    else
        echo "0 0"
    fi
}

# Obține lista interfețelor de rețea active
get_active_interfaces() {
    ip -o link show 2>/dev/null | awk -F': ' '$3 ~ /UP/ {print $2}'
}

#------------------------------------------------------------------------------
# FUNCȚII SISTEM
#------------------------------------------------------------------------------

# Obține uptime în secunde
get_uptime_seconds() {
    if [[ -f /proc/uptime ]]; then
        awk '{print int($1)}' /proc/uptime
    else
        # Fallback: parsare output uptime
        uptime | awk '{
            split($3, a, ":")
            if ($4 ~ /day/) {
                days = $3
                split($5, a, ":")
                hours = a[1]
                mins = a[2]
            } else {
                days = 0
                hours = a[1]
                mins = a[2]
            }
            print (days * 86400) + (hours * 3600) + (mins * 60)
        }'
    fi
}

# Obține informații despre kernel
get_kernel_info() {
    uname -r
}

# Obține hostname
get_hostname() {
    hostname 2>/dev/null || cat /etc/hostname 2>/dev/null || echo "unknown"
}

# Obține informații despre distribuție
get_distro_info() {
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        echo "${PRETTY_NAME:-$NAME $VERSION}"
    elif [[ -f /etc/lsb-release ]]; then
        source /etc/lsb-release
        echo "${DISTRIB_DESCRIPTION:-$DISTRIB_ID $DISTRIB_RELEASE}"
    else
        echo "Unknown Linux"
    fi
}

#------------------------------------------------------------------------------
# FUNCȚII DE RAPORTARE
#------------------------------------------------------------------------------

# Generează un raport complet al stării sistemului
generate_system_report() {
    local include_processes="${1:-true}"
    
    echo "===== RAPORT SISTEM ====="
    echo "Host: $(get_hostname)"
    echo "Distribuție: $(get_distro_info)"
    echo "Kernel: $(get_kernel_info)"
    echo "Uptime: $(format_duration "$(get_uptime_seconds)")"
    echo ""
    echo "----- CPU -----"
    echo "Core-uri: $(get_cpu_cores)"
    echo "Utilizare: $(get_cpu_usage)%"
    echo "Load Average: $(get_load_average)"
    echo ""
    echo "----- MEMORIE -----"
    local mem_details
    mem_details=$(get_memory_details)
    echo "Total/Used/Free/Available (MB): $mem_details"
    echo "Utilizare: $(get_memory_usage)%"
    echo "Swap: $(get_swap_usage)%"
    echo ""
    echo "----- DISK -----"
    get_all_disk_info | while IFS='|' read -r mount size used avail percent; do
        printf "  %-20s %8s %8s %8s %5s%%\n" "$mount" "$size" "$used" "$avail" "$percent"
    done
    
    if [[ "$include_processes" == "true" ]]; then
        echo ""
        echo "----- TOP PROCESE (CPU) -----"
        get_top_cpu_processes 5 | while IFS='|' read -r pid cmd cpu mem; do
            printf "  PID %-8s CPU: %5s%% MEM: %5s%% %s\n" "$pid" "$cpu" "$mem" "$cmd"
        done
    fi
    
    echo ""
    echo "===== SFÂRȘIT RAPORT ====="
}

#------------------------------------------------------------------------------
# INIȚIALIZARE
#------------------------------------------------------------------------------

# Verificare comenzi necesare
_check_utils_dependencies() {
    local missing=()
    
    for cmd in awk grep df free ps; do
        command -v "$cmd" &>/dev/null || missing+=("$cmd")
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        log_warn "Comenzi opționale lipsă: ${missing[*]}"
    fi
}

# Verifică dependențele la încărcare
_check_utils_dependencies

log_debug "utils.sh v${UTILS_VERSION} încărcat"
