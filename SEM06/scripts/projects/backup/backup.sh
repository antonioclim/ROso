#!/bin/bash
# =============================================================================
# ENTERPRISE BACKUP SYSTEM - Main Script
# =============================================================================
# Sistem profesional de backup cu arhitectură modulară
#
# Caracteristici:
#   - Backup incremental și complet
#   - Compresie multiplă (gzip, bzip2, xz, zstd)
#   - Politici de retenție flexibile
#   - Verificare integritate cu checksum
#   - Rotație automată
#   - Logging complet
#   - Notificări email
#
# Autor: Kit Educațional SO - ASE București CSIE
# Versiune: 1.0.0
# =============================================================================

set -euo pipefail

# =============================================================================
# CONFIGURAȚIE GLOBALĂ
# =============================================================================

readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_VERSION="1.0.0"

# Directoare relative la script
readonly LIB_DIR="${SCRIPT_DIR}/lib"
readonly ETC_DIR="${SCRIPT_DIR}/etc"
readonly VAR_DIR="${SCRIPT_DIR}/var"

# Fișiere configurare
readonly DEFAULT_CONFIG="${ETC_DIR}/backup.conf"

# =============================================================================
# ÎNCĂRCARE MODULE
# =============================================================================

# Verifică și încarcă modulele în ordine
load_modules() {
    local modules=("core" "utils" "config")
    local module
    
    for module in "${modules[@]}"; do
        local module_file="${LIB_DIR}/${module}.sh"
        
        if [[ ! -f "$module_file" ]]; then
            echo "[FATAL] Modul lipsă: ${module_file}" >&2
            exit 1
        fi
        
        # shellcheck source=/dev/null
        source "$module_file"
    done
}

# Încarcă modulele
load_modules

# =============================================================================
# FUNCȚII PRINCIPALE DE BACKUP
# =============================================================================

# -----------------------------------------------------------------------------
# Pregătește mediul pentru backup
# -----------------------------------------------------------------------------
prepare_backup_environment() {
    log_info "Pregătire mediu de backup..."
    
    # Creează directoare necesare
    local dirs=("$BACKUP_DEST" "$LOG_DIR" "${VAR_DIR}/log" "${VAR_DIR}/run")
    local dir
    
    for dir in "${dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            if ! mkdir -p "$dir" 2>/dev/null; then
                log_warn "Nu pot crea directorul: $dir (continuă fără)"
            else
                log_debug "Director creat: $dir"
            fi
        fi
    done
    
    # Verifică spațiu disponibil
    local available_mb
    available_mb=$(get_available_space_mb "$BACKUP_DEST" 2>/dev/null || echo "0")
    
    if [[ "$available_mb" -lt 100 ]]; then
        log_warn "Spațiu redus în destinație: ${available_mb}MB disponibil"
    else
        log_debug "Spațiu disponibil în destinație: ${available_mb}MB"
    fi
    
    return 0
}

# -----------------------------------------------------------------------------
# Execută script pre-backup
# -----------------------------------------------------------------------------
run_pre_backup_script() {
    if [[ -z "${PRE_BACKUP_SCRIPT:-}" ]]; then
        return 0
    fi
    
    if [[ ! -x "$PRE_BACKUP_SCRIPT" ]]; then
        log_warn "Script pre-backup nu este executabil: $PRE_BACKUP_SCRIPT"
        return 0
    fi
    
    log_info "Execut script pre-backup: $PRE_BACKUP_SCRIPT"
    
    local timeout="${SCRIPT_TIMEOUT:-300}"
    
    if timeout "$timeout" "$PRE_BACKUP_SCRIPT"; then
        log_info "Script pre-backup executat cu succes"
        return 0
    else
        local exit_code=$?
        log_error "Script pre-backup a eșuat cu cod: $exit_code"
        return "$exit_code"
    fi
}

# -----------------------------------------------------------------------------
# Execută script post-backup
# -----------------------------------------------------------------------------
run_post_backup_script() {
    local archive_path="${1:-}"
    
    if [[ -z "${POST_BACKUP_SCRIPT:-}" ]]; then
        return 0
    fi
    
    if [[ ! -x "$POST_BACKUP_SCRIPT" ]]; then
        log_warn "Script post-backup nu este executabil: $POST_BACKUP_SCRIPT"
        return 0
    fi
    
    log_info "Execut script post-backup: $POST_BACKUP_SCRIPT"
    
    local timeout="${SCRIPT_TIMEOUT:-300}"
    
    if timeout "$timeout" "$POST_BACKUP_SCRIPT" "$archive_path"; then
        log_info "Script post-backup executat cu succes"
        return 0
    else
        local exit_code=$?
        log_warn "Script post-backup a eșuat cu cod: $exit_code"
        return 0  # Nu oprim procesul pentru erori post-backup
    fi
}

# -----------------------------------------------------------------------------
# Creează backup-ul efectiv
# -----------------------------------------------------------------------------
perform_backup() {
    local backup_type="${1:-daily}"
    local sources=("${BACKUP_SOURCES[@]}")
    
    # Generează numele backup-ului
    local backup_name
    backup_name=$(get_backup_name_for_type "$backup_type")
    
    local archive_path="${BACKUP_DEST}/${backup_name}"
    
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log_info "Inițiere backup ${backup_type^^}"
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log_info "Surse: ${sources[*]}"
    log_info "Destinație: $archive_path"
    log_info "Compresie: ${COMPRESSION:-gzip}"
    
    # Verifică că sursele există
    local valid_sources=()
    local source
    
    for source in "${sources[@]}"; do
        if [[ -e "$source" ]]; then
            valid_sources+=("$source")
            log_debug "Sursă validă: $source"
        else
            log_warn "Sursă inexistentă (ignorată): $source"
        fi
    done
    
    if [[ ${#valid_sources[@]} -eq 0 ]]; then
        log_error "Nicio sursă validă pentru backup!"
        return 1
    fi
    
    # Creează fișier de excluderi temporar
    local exclude_file
    exclude_file=$(mktemp)
    trap "rm -f '$exclude_file'" RETURN
    
    create_exclude_file "$exclude_file"
    
    # Mod dry-run
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        log_info "[DRY-RUN] Ar crea arhiva: $archive_path"
        log_info "[DRY-RUN] Surse: ${valid_sources[*]}"
        return 0
    fi
    
    # Estimează dimensiunea
    local estimated_size
    estimated_size=$(estimate_backup_size "${valid_sources[@]}" 2>/dev/null || echo "necunoscut")
    log_info "Dimensiune estimată: $estimated_size"
    
    # Creează arhiva
    log_info "Creare arhivă..."
    local start_time
    start_time=$(date +%s)
    
    if ! create_archive "$archive_path" "$exclude_file" "${valid_sources[@]}"; then
        log_error "Eroare la crearea arhivei!"
        return 1
    fi
    
    local end_time
    end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # Statistici arhivă
    if [[ -f "$archive_path" ]]; then
        local archive_size
        archive_size=$(get_file_size "$archive_path")
        
        log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        log_info "Backup creat cu succes!"
        log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        log_info "Arhivă: $archive_path"
        log_info "Dimensiune: $archive_size"
        log_info "Durată: ${duration}s"
        
        # Salvează în variabile globale pentru raport
        BACKUP_ARCHIVE_PATH="$archive_path"
        BACKUP_ARCHIVE_SIZE="$archive_size"
        BACKUP_DURATION="$duration"
    else
        log_error "Arhiva nu a fost creată!"
        return 1
    fi
    
    return 0
}

# -----------------------------------------------------------------------------
# Verifică backup-ul creat
# -----------------------------------------------------------------------------
verify_created_backup() {
    local archive_path="${BACKUP_ARCHIVE_PATH:-}"
    
    if [[ -z "$archive_path" || ! -f "$archive_path" ]]; then
        log_warn "Nu există arhivă de verificat"
        return 0
    fi
    
    if [[ "${VERIFY_BACKUP:-true}" != "true" ]]; then
        log_debug "Verificarea backup-ului este dezactivată"
        return 0
    fi
    
    log_info "Verificare integritate backup..."
    
    # Verifică arhiva
    if [[ "${VERIFY_ARCHIVE_LISTING:-true}" == "true" ]]; then
        if verify_backup_integrity "$archive_path"; then
            log_info "✓ Arhiva este validă"
        else
            log_error "✗ Arhiva este coruptă!"
            return 1
        fi
    fi
    
    # Salvează checksum
    if [[ "${SAVE_CHECKSUM:-true}" == "true" ]]; then
        local checksum_file="${archive_path}.${CHECKSUM_ALGORITHM:-sha256}"
        
        if save_checksum "$archive_path" "$checksum_file"; then
            log_info "✓ Checksum salvat: $checksum_file"
        else
            log_warn "Nu s-a putut salva checksum-ul"
        fi
    fi
    
    return 0
}

# -----------------------------------------------------------------------------
# Aplică politica de retenție
# -----------------------------------------------------------------------------
apply_retention_policy() {
    local backup_type="${1:-daily}"
    
    log_info "Aplicare politică de retenție pentru: $backup_type"
    
    local retention
    retention=$(get_retention_for_type "$backup_type")
    
    log_debug "Retenție pentru $backup_type: $retention backup-uri"
    
    # Rotație bazată pe număr
    local rotated
    rotated=$(rotate_backups "$BACKUP_DEST" "$retention" "${BACKUP_PREFIX:-backup}_${backup_type}")
    
    if [[ "$rotated" -gt 0 ]]; then
        log_info "Backup-uri vechi șterse: $rotated"
    else
        log_debug "Niciun backup de șters"
    fi
    
    return 0
}

# -----------------------------------------------------------------------------
# Generează raport final
# -----------------------------------------------------------------------------
generate_final_report() {
    local status="${1:-SUCCESS}"
    local error_msg="${2:-}"
    
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log_info "              RAPORT BACKUP"
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log_info "Status: $status"
    log_info "Data: $(date '+%Y-%m-%d %H:%M:%S')"
    log_info "Host: $(hostname)"
    
    if [[ -n "${BACKUP_ARCHIVE_PATH:-}" ]]; then
        log_info "Arhivă: $BACKUP_ARCHIVE_PATH"
        log_info "Dimensiune: ${BACKUP_ARCHIVE_SIZE:-necunoscut}"
        log_info "Durată: ${BACKUP_DURATION:-0}s"
    fi
    
    if [[ -n "$error_msg" ]]; then
        log_info "Eroare: $error_msg"
    fi
    
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Trimite notificare email dacă e configurat
    if [[ "${NOTIFY_EMAIL:-false}" == "true" ]]; then
        send_notification "$status" "$error_msg"
    fi
}

# -----------------------------------------------------------------------------
# Trimite notificare
# -----------------------------------------------------------------------------
send_notification() {
    local status="${1:-SUCCESS}"
    local error_msg="${2:-}"
    
    # Verifică dacă să trimită notificare
    if [[ "$status" == "SUCCESS" && "${NOTIFY_ON_SUCCESS:-false}" != "true" ]]; then
        if [[ "${NOTIFY_ON_ERROR_ONLY:-true}" == "true" ]]; then
            log_debug "Notificare succes dezactivată"
            return 0
        fi
    fi
    
    local subject
    if [[ "$status" == "SUCCESS" ]]; then
        subject="${EMAIL_SUBJECT_SUCCESS:-[BACKUP] Succes: $(hostname)}"
    else
        subject="${EMAIL_SUBJECT_ERROR:-[BACKUP] EROARE: $(hostname)}"
    fi
    
    local body="Backup Report
================
Status: $status
Date: $(date '+%Y-%m-%d %H:%M:%S')
Host: $(hostname)
Archive: ${BACKUP_ARCHIVE_PATH:-N/A}
Size: ${BACKUP_ARCHIVE_SIZE:-N/A}
Duration: ${BACKUP_DURATION:-0}s
${error_msg:+Error: $error_msg}"
    
    local recipients="${EMAIL_RECIPIENTS:-root}"
    
    if command -v mail &>/dev/null; then
        echo "$body" | mail -s "$subject" "$recipients" 2>/dev/null && \
            log_info "Notificare email trimisă" || \
            log_warn "Eroare la trimiterea notificării email"
    else
        log_debug "Comanda 'mail' nu este disponibilă"
    fi
}

# -----------------------------------------------------------------------------
# Listează backup-urile existente
# -----------------------------------------------------------------------------
list_backups() {
    log_info "Backup-uri existente în: $BACKUP_DEST"
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if [[ ! -d "$BACKUP_DEST" ]]; then
        log_warn "Directorul de backup nu există"
        return 0
    fi
    
    local count=0
    local total_size=0
    
    while IFS= read -r archive; do
        if [[ -n "$archive" ]]; then
            local size
            size=$(stat -c%s "$archive" 2>/dev/null || echo "0")
            local human_size
            human_size=$(numfmt --to=iec-i --suffix=B "$size" 2>/dev/null || echo "${size}B")
            local date
            date=$(stat -c%y "$archive" 2>/dev/null | cut -d' ' -f1,2 | cut -d'.' -f1)
            
            printf "  %-50s %10s  %s\n" "$(basename "$archive")" "$human_size" "$date"
            
            ((count++))
            total_size=$((total_size + size))
        fi
    done < <(find "$BACKUP_DEST" -maxdepth 1 -name "*.tar*" -type f 2>/dev/null | sort)
    
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    local total_human
    total_human=$(numfmt --to=iec-i --suffix=B "$total_size" 2>/dev/null || echo "${total_size}B")
    log_info "Total: $count backup-uri, $total_human"
}

# -----------------------------------------------------------------------------
# Restaurează un backup
# -----------------------------------------------------------------------------
restore_backup() {
    local archive="${1:-}"
    local dest="${2:-.}"
    
    if [[ -z "$archive" ]]; then
        log_error "Trebuie specificată arhiva de restaurat"
        return 1
    fi
    
    # Rezolvă calea arhivei
    if [[ ! -f "$archive" ]]; then
        local full_path="${BACKUP_DEST}/${archive}"
        if [[ -f "$full_path" ]]; then
            archive="$full_path"
        else
            log_error "Arhiva nu există: $archive"
            return 1
        fi
    fi
    
    # Verifică checksum dacă există
    local checksum_file="${archive}.${CHECKSUM_ALGORITHM:-sha256}"
    if [[ -f "$checksum_file" ]]; then
        log_info "Verificare checksum..."
        if verify_checksum "$archive" "$checksum_file"; then
            log_info "✓ Checksum valid"
        else
            log_error "✗ Checksum invalid! Arhiva poate fi coruptă."
            return 1
        fi
    fi
    
    log_info "Restaurare backup: $archive"
    log_info "Destinație: $dest"
    
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        log_info "[DRY-RUN] Ar extrage în: $dest"
        log_info "[DRY-RUN] Conținut arhivă:"
        list_archive_contents "$archive" | head -20
        return 0
    fi
    
    # Creează directorul destinație dacă nu există
    mkdir -p "$dest"
    
    # Extrage arhiva
    if extract_archive "$archive" "$dest"; then
        log_info "✓ Backup restaurat cu succes în: $dest"
        return 0
    else
        log_error "Eroare la restaurarea backup-ului!"
        return 1
    fi
}

# =============================================================================
# FUNCȚIA PRINCIPALĂ
# =============================================================================

main() {
    # Variabile globale pentru raport
    BACKUP_ARCHIVE_PATH=""
    BACKUP_ARCHIVE_SIZE=""
    BACKUP_DURATION=""
    
    # Inițializează configurația
    init_config "$@"
    
    # Configurează logging
    setup_logging
    
    # Procesează moduri speciale
    case "${MODE:-backup}" in
        list)
            list_backups
            exit 0
            ;;
        restore)
            restore_backup "${RESTORE_ARCHIVE:-}" "${RESTORE_DEST:-.}"
            exit $?
            ;;
        verify)
            if [[ -n "${VERIFY_ARCHIVE:-}" ]]; then
                if verify_backup_integrity "$VERIFY_ARCHIVE"; then
                    log_info "✓ Arhiva este validă"
                    exit 0
                else
                    log_error "✗ Arhiva este coruptă"
                    exit 1
                fi
            else
                log_error "Trebuie specificată arhiva de verificat (--verify-archive)"
                exit 1
            fi
            ;;
    esac
    
    # Mod backup normal
    local exit_code=0
    local error_msg=""
    
    log_info "═══════════════════════════════════════════════════════════════"
    log_info "     ENTERPRISE BACKUP SYSTEM v${SCRIPT_VERSION}"
    log_info "═══════════════════════════════════════════════════════════════"
    log_info "Pornire backup: $(date '+%Y-%m-%d %H:%M:%S')"
    log_info "Host: $(hostname)"
    
    # Achiziționează lock
    if ! acquire_lock "${LOCK_FILE:-/var/run/backup.lock}" "${LOCK_TIMEOUT:-60}"; then
        log_error "Nu pot achiziționa lock-ul. Alt backup rulează?"
        exit 1
    fi
    
    # Cleanup la exit
    trap 'release_lock "${LOCK_FILE:-/var/run/backup.lock}"; generate_final_report "${exit_code:-1}" "$error_msg"' EXIT
    
    # Pregătește mediul
    if ! prepare_backup_environment; then
        error_msg="Eroare la pregătirea mediului"
        exit_code=1
        exit "$exit_code"
    fi
    
    # Execută script pre-backup
    if ! run_pre_backup_script; then
        error_msg="Script pre-backup a eșuat"
        exit_code=1
        exit "$exit_code"
    fi
    
    # Determină tipul de backup
    local backup_type
    backup_type=$(get_backup_type_for_today)
    log_info "Tip backup determinat: $backup_type"
    
    # Override cu tipul specificat manual
    if [[ -n "${BACKUP_TYPE:-}" ]]; then
        backup_type="$BACKUP_TYPE"
        log_info "Tip backup override: $backup_type"
    fi
    
    # Execută backup-ul
    if ! perform_backup "$backup_type"; then
        error_msg="Eroare la crearea backup-ului"
        exit_code=2
        exit "$exit_code"
    fi
    
    # Verifică backup-ul
    if ! verify_created_backup; then
        error_msg="Verificarea backup-ului a eșuat"
        exit_code=3
        exit "$exit_code"
    fi
    
    # Aplică retenția
    apply_retention_policy "$backup_type"
    
    # Execută script post-backup
    run_post_backup_script "${BACKUP_ARCHIVE_PATH:-}"
    
    log_info "═══════════════════════════════════════════════════════════════"
    log_info "     BACKUP FINALIZAT CU SUCCES"
    log_info "═══════════════════════════════════════════════════════════════"
    
    exit_code=0
    exit "$exit_code"
}

# =============================================================================
# ENTRY POINT
# =============================================================================

# Rulează doar dacă nu e sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

# =============================================================================
# EXIT CODES:
# 0 = 
# 1 = Eroare configurare/mediu
# 2 = Eroare la crearea backup-ului
# 3 = Eroare la verificare
# 4 = Eroare critică
# =============================================================================
