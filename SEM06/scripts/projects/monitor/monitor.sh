#!/bin/bash
#==============================================================================
# monitor.sh - System Monitor - Aplicație completă de monitorizare sistem
#==============================================================================
# DESCRIERE:
#   Aplicație profesională pentru monitorizarea resurselor sistem:
#   CPU, memorie, disk, swap, load average.
#   Suportă alerting, notificări, mod daemon și multiple formate de output.
#
# ARHITECTURĂ:
#   monitor.sh (acest fișier) - Entry point și logica principală
#    lib/core.sh          - Funcții fundamentale (logging, error handling)
#    lib/utils.sh         - Funcții de colectare metrici sistem
#    lib/config.sh        - Gestiunea configurării
#    etc/monitor.conf     - Configurare default
#    var/
#        log/             - Fișiere log
#        run/             - PID file pentru daemon
#
# UTILIZARE:
#   ./monitor.sh              # Verificare single-shot
#   ./monitor.sh -d           # Mod daemon
#   ./monitor.sh -v           # Verbose/debug mode
#   ./monitor.sh -o json      # Output JSON
#
# AUTOR: ASE București - CSIE | Sisteme de Operare
# VERSIUNE: 1.0.0
# LICENȚĂ: Educational Use
#==============================================================================

set -euo pipefail
IFS=$'\n\t'

#------------------------------------------------------------------------------
# SETUP INIȚIAL
#------------------------------------------------------------------------------

# Determină directorul scriptului (rezolvă symlinks)
SCRIPT_PATH="${BASH_SOURCE[0]}"
while [[ -L "$SCRIPT_PATH" ]]; do
    SCRIPT_DIR=$(cd -P "$(dirname "$SCRIPT_PATH")" && pwd)
    SCRIPT_PATH=$(readlink "$SCRIPT_PATH")
    [[ "$SCRIPT_PATH" != /* ]] && SCRIPT_PATH="$SCRIPT_DIR/$SCRIPT_PATH"
done
SCRIPT_DIR=$(cd -P "$(dirname "$SCRIPT_PATH")" && pwd)
readonly SCRIPT_DIR

# Salvează argumentele originale
readonly ORIGINAL_ARGS=("$@")

#------------------------------------------------------------------------------
# ÎNCARCĂ BIBLIOTECILE
#------------------------------------------------------------------------------

# Verifică și încarcă bibliotecile în ordinea corectă
for lib in core utils config; do
    lib_file="${SCRIPT_DIR}/lib/${lib}.sh"
    if [[ -f "$lib_file" ]]; then
        # shellcheck source=/dev/null
        source "$lib_file"
    else
        echo "EROARE FATALĂ: Biblioteca lipsă: $lib_file" >&2
        exit 1
    fi
done

#------------------------------------------------------------------------------
# VARIABILE GLOBALE PENTRU STARE
#------------------------------------------------------------------------------

declare -g ALERTS_COUNT=0
declare -g ALERTS_MESSAGES=()
declare -g LAST_CHECK_TIME=0
declare -g RUNNING=true

#------------------------------------------------------------------------------
# FUNCȚII DE NOTIFICARE
#------------------------------------------------------------------------------

# Trimite notificare email
send_email_notification() {
    local subject="$1"
    local body="$2"
    
    if [[ -z "$NOTIFY_EMAIL" ]]; then
        log_debug "Email nesetat, skip notificare"
        return 0
    fi
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] Ar trimite email către: $NOTIFY_EMAIL"
        log_debug "Subject: $subject"
        return 0
    fi
    
    # Verifică dacă mail command există
    if ! command -v mail &>/dev/null; then
        log_warn "Comanda 'mail' nu este disponibilă pentru notificări"
        return 1
    fi
    
    echo "$body" | mail -s "$subject" "$NOTIFY_EMAIL"
    log_info "Notificare email trimisă către: $NOTIFY_EMAIL"
}

# Trimite notificare Slack
send_slack_notification() {
    local message="$1"
    local severity="${2:-warning}"
    
    if [[ -z "$NOTIFY_SLACK_WEBHOOK" ]]; then
        return 0
    fi
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] Ar trimite către Slack: $message"
        return 0
    fi
    
    local color
    case "$severity" in
        good)    color="#36a64f" ;;
        warning) color="#ffa500" ;;
        danger)  color="#ff0000" ;;
        *)       color="#808080" ;;
    esac
    
    local payload
    payload=$(cat << EOF
{
    "attachments": [
        {
            "color": "$color",
            "title": "System Monitor Alert",
            "text": "$message",
            "footer": "$(get_hostname) | $(date '+%Y-%m-%d %H:%M:%S')"
        }
    ]
}
EOF
)
    
    if command -v curl &>/dev/null; then
        curl -s -X POST -H 'Content-type: application/json' \
            --data "$payload" "$NOTIFY_SLACK_WEBHOOK" &>/dev/null
        log_debug "Notificare Slack trimisă"
    fi
}

# Trimite toate notificările
send_alerts() {
    local subject="$1"
    local body="$2"
    local severity="${3:-warning}"
    
    send_email_notification "$subject" "$body"
    send_slack_notification "$body" "$severity"
}

#------------------------------------------------------------------------------
# FUNCȚII DE VERIFICARE RESURSE
#------------------------------------------------------------------------------

# Verifică utilizarea CPU
check_cpu() {
    local cpu_usage
    cpu_usage=$(get_cpu_usage)
    
    log_debug "CPU Usage: ${cpu_usage}%"
    
    if [[ $cpu_usage -gt $THRESHOLD_CPU ]]; then
        local msg="ALERTĂ CPU: ${cpu_usage}% (threshold: ${THRESHOLD_CPU}%)"
        log_warn "$msg"
        ALERTS_MESSAGES+=("$msg")
        ((ALERTS_COUNT++))
        return 1
    fi
    
    log_info "CPU: ${cpu_usage}% - OK"
    return 0
}

# Verifică utilizarea memoriei
check_memory() {
    local mem_usage
    mem_usage=$(get_memory_usage)
    
    log_debug "Memory Usage: ${mem_usage}%"
    
    if [[ $mem_usage -gt $THRESHOLD_MEM ]]; then
        local msg="ALERTĂ MEMORIE: ${mem_usage}% (threshold: ${THRESHOLD_MEM}%)"
        log_warn "$msg"
        ALERTS_MESSAGES+=("$msg")
        ((ALERTS_COUNT++))
        return 1
    fi
    
    log_info "Memorie: ${mem_usage}% - OK"
    return 0
}

# Verifică utilizarea swap
check_swap() {
    local swap_usage
    swap_usage=$(get_swap_usage)
    
    log_debug "Swap Usage: ${swap_usage}%"
    
    if [[ $swap_usage -gt $THRESHOLD_SWAP ]]; then
        local msg="ALERTĂ SWAP: ${swap_usage}% (threshold: ${THRESHOLD_SWAP}%)"
        log_warn "$msg"
        ALERTS_MESSAGES+=("$msg")
        ((ALERTS_COUNT++))
        return 1
    fi
    
    log_info "Swap: ${swap_usage}% - OK"
    return 0
}

# Verifică utilizarea disk
check_disk() {
    local disk_alerts=0
    
    while IFS='|' read -r mount_point size used avail percent; do
        # Skip mount points excluse
        local skip=false
        for exclude in "${DISK_EXCLUDE_MOUNTS[@]}"; do
            if [[ "$mount_point" == "$exclude" ]]; then
                log_debug "Skip mount point exclus: $mount_point"
                skip=true
                break
            fi
        done
        $skip && continue
        
        log_debug "Disk $mount_point: ${percent}%"
        
        if [[ ${percent:-0} -gt $THRESHOLD_DISK ]]; then
            local msg="ALERTĂ DISK: $mount_point la ${percent}% (threshold: ${THRESHOLD_DISK}%)"
            log_warn "$msg"
            ALERTS_MESSAGES+=("$msg")
            ((disk_alerts++))
        fi
    done < <(get_all_disk_info)
    
    if [[ $disk_alerts -gt 0 ]]; then
        ((ALERTS_COUNT += disk_alerts))
        return 1
    fi
    
    log_info "Disk: Toate partițiile OK"
    return 0
}

# Verifică load average
check_load() {
    local load_avg
    load_avg=$(get_load_average)
    local load1
    load1=$(echo "$load_avg" | awk '{print $1}')
    
    local cores
    cores=$(get_cpu_cores)
    local threshold=$((cores * THRESHOLD_LOAD_MULT))
    
    log_debug "Load Average: $load_avg (threshold: $threshold)"
    
    # Convertește la întreg pentru comparație
    local load1_int=${load1%.*}
    
    if [[ ${load1_int:-0} -gt $threshold ]]; then
        local msg="ALERTĂ LOAD: $load1 (threshold: ${threshold} = ${cores} cores × ${THRESHOLD_LOAD_MULT})"
        log_warn "$msg"
        ALERTS_MESSAGES+=("$msg")
        ((ALERTS_COUNT++))
        return 1
    fi
    
    log_info "Load: $load_avg - OK"
    return 0
}

#------------------------------------------------------------------------------
# FUNCȚII DE OUTPUT
#------------------------------------------------------------------------------

# Generează output în format text
output_text() {
    local status="${1:-OK}"
    
    echo "===== SYSTEM MONITOR REPORT ====="
    echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "Host: $(get_hostname)"
    echo "Status: $status"
    echo ""
    echo "----- METRICS -----"
    echo "CPU:    $(get_cpu_usage)% (threshold: ${THRESHOLD_CPU}%)"
    echo "Memory: $(get_memory_usage)% (threshold: ${THRESHOLD_MEM}%)"
    echo "Swap:   $(get_swap_usage)% (threshold: ${THRESHOLD_SWAP}%)"
    echo "Load:   $(get_load_average)"
    echo ""
    echo "----- DISK -----"
    get_all_disk_info | while IFS='|' read -r mount size used avail percent; do
        local status_mark="✓"
        if [[ ${percent:-0} -gt $THRESHOLD_DISK ]]; then
            status_mark="✗"
        fi
        printf "  [%s] %-20s %5s%% of %8s\n" "$status_mark" "$mount" "$percent" "$size"
    done
    
    if [[ ${#ALERTS_MESSAGES[@]} -gt 0 ]]; then
        echo ""
        echo "----- ALERTS (${#ALERTS_MESSAGES[@]}) -----"
        for alert in "${ALERTS_MESSAGES[@]}"; do
            echo "  • $alert"
        done
    fi
    
    echo "================================="
}

# Generează output în format JSON
output_json() {
    local status="${1:-OK}"
    local alerts_json="[]"
    
    if [[ ${#ALERTS_MESSAGES[@]} -gt 0 ]]; then
        alerts_json="["
        local first=true
        for alert in "${ALERTS_MESSAGES[@]}"; do
            if ! $first; then alerts_json+=","; fi
            alerts_json+="\"$alert\""
            first=false
        done
        alerts_json+="]"
    fi
    
    cat << EOF
{
  "timestamp": "$(date -Iseconds)",
  "hostname": "$(get_hostname)",
  "status": "$status",
  "alerts_count": $ALERTS_COUNT,
  "metrics": {
    "cpu": {
      "usage": $(get_cpu_usage),
      "threshold": $THRESHOLD_CPU,
      "cores": $(get_cpu_cores)
    },
    "memory": {
      "usage": $(get_memory_usage),
      "threshold": $THRESHOLD_MEM
    },
    "swap": {
      "usage": $(get_swap_usage),
      "threshold": $THRESHOLD_SWAP
    },
    "load": {
      "average": "$(get_load_average)",
      "threshold_multiplier": $THRESHOLD_LOAD_MULT
    }
  },
  "alerts": $alerts_json
}
EOF
}

# Generează output în format CSV
output_csv() {
    echo "timestamp,hostname,cpu_usage,mem_usage,swap_usage,load1,alerts_count,status"
    local load1
    load1=$(get_load_average | awk '{print $1}')
    local status="${1:-OK}"
    echo "$(date -Iseconds),$(get_hostname),$(get_cpu_usage),$(get_memory_usage),$(get_swap_usage),$load1,$ALERTS_COUNT,$status"
}

# Generează output în formatul configurat
generate_output() {
    local status="OK"
    if [[ $ALERTS_COUNT -gt 0 ]]; then
        status="ALERT"
    fi
    
    case "$OUTPUT_FORMAT" in
        json) output_json "$status" ;;
        csv)  output_csv "$status" ;;
        *)    output_text "$status" ;;
    esac
}

#------------------------------------------------------------------------------
# FUNCȚIA PRINCIPALĂ DE VERIFICARE
#------------------------------------------------------------------------------

run_checks() {
    # Reset counters
    ALERTS_COUNT=0
    ALERTS_MESSAGES=()
    
    log_header "Începe verificarea sistemului"
    
    local check_errors=0
    
    # Rulează toate verificările
    check_cpu    || ((check_errors++))
    check_memory || ((check_errors++))
    check_swap   || ((check_errors++))
    check_disk   || ((check_errors++))
    check_load   || ((check_errors++))
    
    LAST_CHECK_TIME=$(date +%s)
    
    # Generează output
    generate_output
    
    # Trimite notificări dacă sunt alerte
    if [[ $ALERTS_COUNT -gt 0 ]]; then
        log_separator
        log_warn "Verificare completă: $ALERTS_COUNT alerte active"
        
        local alert_body
        alert_body=$(printf '%s\n' "${ALERTS_MESSAGES[@]}")
        
        send_alerts \
            "[ALERT] System Monitor - $(get_hostname) - $ALERTS_COUNT alerte" \
            "$alert_body" \
            "danger"
        
        return 2
    fi
    
    log_separator
    log_info "Verificare completă: Toate resursele OK"
    return 0
}

#------------------------------------------------------------------------------
# MOD DAEMON
#------------------------------------------------------------------------------

daemon_loop() {
    log_info "Pornit în mod daemon cu interval de ${MONITOR_INTERVAL}s"
    
    while $RUNNING; do
        run_checks || true
        
        log_debug "Aștept ${MONITOR_INTERVAL}s până la următoarea verificare..."
        
        # Sleep interruptibil
        local waited=0
        while $RUNNING && [[ $waited -lt $MONITOR_INTERVAL ]]; do
            sleep 1
            ((waited++))
        done
    done
    
    log_info "Daemon oprit"
}

#------------------------------------------------------------------------------
# CLEANUP ȘI SIGNAL HANDLERS
#------------------------------------------------------------------------------

cleanup() {
    log_debug "Cleanup în curs..."
    
    # Eliberează lock
    if [[ -n "${LOCK_FILE:-}" ]]; then
        release_lock "$LOCK_FILE"
    fi
    
    log_debug "Cleanup complet"
}

handle_signal() {
    local signal="$1"
    log_info "Semnal primit: $signal"
    RUNNING=false
}

#------------------------------------------------------------------------------
# MAIN
#------------------------------------------------------------------------------

main() {
    # Inițializare configurare
    init_config "${ORIGINAL_ARGS[@]}" || die "Eroare la inițializarea configurării"
    
    # Setup cleanup
    trap cleanup EXIT
    trap 'handle_signal INT' INT
    trap 'handle_signal TERM' TERM
    trap 'handle_signal HUP' HUP
    
    log_header "System Monitor v1.0.0"
    log_info "Host: $(get_hostname)"
    log_info "Started: $(date '+%Y-%m-%d %H:%M:%S')"
    
    # Achiziționează lock dacă e daemon
    if [[ "$DAEMON_MODE" == "true" ]]; then
        acquire_lock "$LOCK_FILE" || die "Nu pot achiziționa lock-ul. Altă instanță rulează?"
    fi
    
    # Rulează în modul corespunzător
    if [[ "$DAEMON_MODE" == "true" ]]; then
        daemon_loop
    else
        run_checks
        exit $?
    fi
}

# Rulează main doar dacă scriptul e executat direct
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
