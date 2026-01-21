#!/usr/bin/env bash
#
# hw01_monitor_template.sh - Template pentru tema de monitorizare
#
# INSTRUCȚIUNI:
# 1. Completează funcțiile marcate cu TODO
# 2. Nu modifica signatura funcțiilor
# 3. Rulează testele cu: ./test_hw01.sh
#
# Autor: [Numele tău]
# Grupa: [Grupa ta]
# Data: [Data]
#

set -euo pipefail

# === CONFIGURARE (nu modifica) ===
readonly SCRIPT_NAME=$(basename "$0")
readonly VERSION="1.0"

# === TODO: Completează threshold-urile ===
readonly THRESHOLD_CPU="${THRESHOLD_CPU:-80}"        # Procent CPU
readonly THRESHOLD_MEM="${THRESHOLD_MEM:-85}"        # Procent memorie
readonly THRESHOLD_DISK="${THRESHOLD_DISK:-90}"      # Procent disk

# === FUNCȚII HELPER (nu modifica) ===
log() {
    local level="${1:-INFO}"
    shift
    printf '[%s] [%-5s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$level" "$*"
}

die() {
    log "FATAL" "$*" >&2
    exit 1
}

usage() {
    cat << EOF
Utilizare: $SCRIPT_NAME [OPȚIUNI]

Script de monitorizare sistem.

Opțiuni:
    -c, --cpu       Verifică doar CPU
    -m, --memory    Verifică doar memorie
    -d, --disk      Verifică doar disk
    -a, --all       Verifică toate (default)
    -j, --json      Output în format JSON
    -h, --help      Afișează acest mesaj
    -v, --version   Afișează versiunea

Exemple:
    $SCRIPT_NAME --all
    $SCRIPT_NAME --cpu --memory
    $SCRIPT_NAME --json

Exit codes:
    0 - Toate verificările OK
    1 - Eroare generală
    2 - Alerte detectate
EOF
    exit 0
}

# === TODO: IMPLEMENTEAZĂ ACESTE FUNCȚII ===

# Funcție: get_cpu_usage
# Descriere: Calculează procentul de utilizare CPU
# Input: niciunul
# Output: Număr întreg reprezentând % CPU (ex: "42")
# Hint: Folosește /proc/stat
get_cpu_usage() {
    # TODO: Implementează
    # Pași sugerați:
    # 1. Citește linia "cpu " din /proc/stat
    # 2. Extrage valorile: user, nice, system, idle, iowait, irq, softirq
    # 3. Calculează: active = user + nice + system
    # 4. Calculează: total = active + idle + iowait + irq + softirq
    # 5. Returnează: active * 100 / total
    
    echo "0"  # Placeholder - înlocuiește cu implementarea ta
}

# Funcție: get_memory_usage
# Descriere: Calculează procentul de memorie utilizată
# Input: niciunul
# Output: Număr întreg reprezentând % memorie (ex: "65")
# Hint: Folosește /proc/meminfo
get_memory_usage() {
    # TODO: Implementează
    # Pași sugerați:
    # 1. Citește MemTotal și MemAvailable din /proc/meminfo
    # 2. Calculează: used = (MemTotal - MemAvailable) * 100 / MemTotal
    # 3. Returnează valoarea
    
    echo "0"  # Placeholder
}

# Funcție: get_disk_usage
# Descriere: Returnează utilizarea diskului pentru root partition
# Input: niciunul
# Output: Număr întreg reprezentând % disk (ex: "34")
# Hint: Folosește comanda df
get_disk_usage() {
    # TODO: Implementează
    # Pași sugerați:
    # 1. Rulează df pe /
    # 2. Extrage procentul de utilizare
    # 3. Elimină caracterul %
    
    echo "0"  # Placeholder
}

# Funcție: check_threshold
# Descriere: Verifică dacă valoarea depășește threshold-ul
# Input: $1 = valoare, $2 = threshold, $3 = nume metric
# Output: Mesaj de alertă (dacă e cazul)
# Return: 0 dacă OK, 1 dacă alertă
check_threshold() {
    local value="$1"
    local threshold="$2"
    local metric="$3"
    
    # TODO: Implementează comparația și output-ul
    # Dacă value > threshold:
    #   - Afișează alertă
    #   - Return 1
    # Altfel:
    #   - Afișează OK
    #   - Return 0
    
    return 0  # Placeholder
}

# Funcție: output_json
# Descriere: Generează output în format JSON
# Input: $1 = cpu, $2 = mem, $3 = disk
# Output: JSON valid
output_json() {
    local cpu="$1"
    local mem="$2" 
    local disk="$3"
    
    # TODO: Implementează
    # Format:
    # {
    #   "timestamp": "YYYY-MM-DD HH:MM:SS",
    #   "metrics": {
    #     "cpu": {"value": N, "threshold": M, "status": "ok|alert"},
    #     "memory": {...},
    #     "disk": {...}
    #   }
    # }
    
    echo "{}"  # Placeholder
}

# === MAIN (nu modifica structura) ===
main() {
    local check_cpu=false
    local check_mem=false
    local check_disk=false
    local output_format="text"
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -c|--cpu) check_cpu=true; shift ;;
            -m|--memory) check_mem=true; shift ;;
            -d|--disk) check_disk=true; shift ;;
            -a|--all) check_cpu=true; check_mem=true; check_disk=true; shift ;;
            -j|--json) output_format="json"; shift ;;
            -h|--help) usage ;;
            -v|--version) echo "$VERSION"; exit 0 ;;
            *) die "Opțiune necunoscută: $1" ;;
        esac
    done
    
    # Default: check all
    if [[ "$check_cpu" == false && "$check_mem" == false && "$check_disk" == false ]]; then
        check_cpu=true
        check_mem=true
        check_disk=true
    fi
    
    local alerts=0
    local cpu_val=0 mem_val=0 disk_val=0
    
    # Colectare metrici
    [[ "$check_cpu" == true ]] && cpu_val=$(get_cpu_usage)
    [[ "$check_mem" == true ]] && mem_val=$(get_memory_usage)
    [[ "$check_disk" == true ]] && disk_val=$(get_disk_usage)
    
    # Output
    if [[ "$output_format" == "json" ]]; then
        output_json "$cpu_val" "$mem_val" "$disk_val"
    else
        log "INFO" "=== Monitor System ==="
        
        if [[ "$check_cpu" == true ]]; then
            check_threshold "$cpu_val" "$THRESHOLD_CPU" "CPU" || ((alerts++))
        fi
        
        if [[ "$check_mem" == true ]]; then
            check_threshold "$mem_val" "$THRESHOLD_MEM" "Memory" || ((alerts++))
        fi
        
        if [[ "$check_disk" == true ]]; then
            check_threshold "$disk_val" "$THRESHOLD_DISK" "Disk" || ((alerts++))
        fi
        
        if ((alerts > 0)); then
            log "WARN" "Total alerte: $alerts"
            exit 2
        else
            log "INFO" "Toate verificările OK"
        fi
    fi
}

main "$@"
