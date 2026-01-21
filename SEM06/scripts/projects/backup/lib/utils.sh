#!/bin/bash
#==============================================================================
# utils.sh - Funcții utilitare pentru operațiuni de backup
#==============================================================================
# DESCRIERE:
#   Funcții pentru arhivare, compresie, rotație și verificare backup-uri.
#
# AUTOR: ASE București - CSIE | Sisteme de Operare
# VERSIUNE: 1.0.0
#==============================================================================

readonly UTILS_VERSION="1.0.0"

#------------------------------------------------------------------------------
# COMPRESIE ȘI ARHIVARE
#------------------------------------------------------------------------------

# Determină extensia bazată pe tipul de compresie
get_archive_extension() {
    local compression="${1:-gz}"
    
    case "$compression" in
        gz|gzip)    echo ".tar.gz" ;;
        bz2|bzip2)  echo ".tar.bz2" ;;
        xz)         echo ".tar.xz" ;;
        zstd)       echo ".tar.zst" ;;
        none|tar)   echo ".tar" ;;
        *)          echo ".tar.gz" ;;
    esac
}

# Determină opțiunea tar pentru compresie
get_tar_compress_option() {
    local compression="${1:-gz}"
    
    case "$compression" in
        gz|gzip)    echo "-z" ;;
        bz2|bzip2)  echo "-j" ;;
        xz)         echo "-J" ;;
        zstd)       echo "--zstd" ;;
        none|tar)   echo "" ;;
        *)          echo "-z" ;;
    esac
}

# Creează o arhivă
# Utilizare: create_archive SOURCE DESTINATION [COMPRESSION] [EXCLUDE_FILE]
create_archive() {
    local source="$1"
    local destination="$2"
    local compression="${3:-gz}"
    local exclude_file="${4:-}"
    
    local compress_opt
    compress_opt=$(get_tar_compress_option "$compression")
    
    local source_dir source_name
    source_dir=$(dirname "$source")
    source_name=$(basename "$source")
    
    # Construiește comanda tar
    local tar_cmd=(tar)
    
    # Adaugă compresie dacă e specificată
    if [[ -n "$compress_opt" ]]; then
        tar_cmd+=("$compress_opt")
    fi
    
    # Adaugă fișier de excluderi dacă există
    if [[ -n "$exclude_file" ]] && [[ -f "$exclude_file" ]]; then
        tar_cmd+=(--exclude-from="$exclude_file")
    fi
    
    # Adaugă opțiuni standard
    tar_cmd+=(
        --create
        --file="$destination"
        --directory="$source_dir"
        "$source_name"
    )
    
    log_debug "Execut: ${tar_cmd[*]}"
    
    if "${tar_cmd[@]}" 2>&1 | while read -r line; do log_debug "tar: $line"; done; then
        return 0
    else
        return 1
    fi
}

# Extrage o arhivă
# Utilizare: extract_archive ARCHIVE DESTINATION
extract_archive() {
    local archive="$1"
    local destination="$2"
    
    [[ -f "$archive" ]] || { log_error "Arhiva nu există: $archive"; return 1; }
    
    mkdir -p "$destination" || { log_error "Nu pot crea: $destination"; return 1; }
    
    local extension="${archive##*.}"
    local tar_opts=()
    
    # Auto-detectează compresie
    case "$archive" in
        *.tar.gz|*.tgz)   tar_opts+=("-z") ;;
        *.tar.bz2|*.tbz2) tar_opts+=("-j") ;;
        *.tar.xz|*.txz)   tar_opts+=("-J") ;;
        *.tar.zst)        tar_opts+=(--zstd) ;;
    esac
    
    tar "${tar_opts[@]}" -xf "$archive" -C "$destination" || return 1
    
    log_info "Arhivă extrasă în: $destination"
    return 0
}

# Listează conținutul unei arhive
list_archive_contents() {
    local archive="$1"
    
    [[ -f "$archive" ]] || { log_error "Arhiva nu există: $archive"; return 1; }
    
    local tar_opts=()
    
    case "$archive" in
        *.tar.gz|*.tgz)   tar_opts+=("-z") ;;
        *.tar.bz2|*.tbz2) tar_opts+=("-j") ;;
        *.tar.xz|*.txz)   tar_opts+=("-J") ;;
        *.tar.zst)        tar_opts+=(--zstd) ;;
    esac
    
    tar "${tar_opts[@]}" -tvf "$archive"
}

#------------------------------------------------------------------------------
# ROTAȚIE BACKUP-URI
#------------------------------------------------------------------------------

# Obține lista de backup-uri sortate după dată (cele mai vechi primele)
# Utilizare: get_sorted_backups DIRECTORY PATTERN
get_sorted_backups() {
    local directory="$1"
    local pattern="${2:-backup_*.tar*}"
    
    find "$directory" -maxdepth 1 -type f -name "$pattern" -printf '%T+ %p\n' 2>/dev/null | \
        sort | cut -d' ' -f2-
}

# Rotește backup-urile păstrând doar ultimele N
# Utilizare: rotate_backups DIRECTORY COUNT [PATTERN]
rotate_backups() {
    local directory="$1"
    local keep_count="$2"
    local pattern="${3:-backup_*.tar*}"
    
    log_info "Rotație backup-uri în $directory (păstrez ultimele $keep_count)"
    
    # Obține lista sortată (cele mai vechi primele)
    local backups=()
    while IFS= read -r backup; do
        [[ -n "$backup" ]] && backups+=("$backup")
    done < <(get_sorted_backups "$directory" "$pattern")
    
    local total=${#backups[@]}
    log_debug "Total backup-uri găsite: $total"
    
    if [[ $total -le $keep_count ]]; then
        log_info "Număr backup-uri ($total) <= limita ($keep_count), nimic de șters"
        return 0
    fi
    
    local to_delete=$((total - keep_count))
    local deleted=0
    
    for ((i=0; i<to_delete; i++)); do
        local backup="${backups[$i]}"
        log_info "Șterg backup vechi: $(basename "$backup")"
        
        if rm -f "$backup"; then
            ((deleted++))
        else
            log_error "Nu pot șterge: $backup"
        fi
    done
    
    log_info "Rotație completă: $deleted backup-uri șterse"
    return 0
}

# Rotație bazată pe vârstă (zile)
# Utilizare: rotate_by_age DIRECTORY DAYS [PATTERN]
rotate_by_age() {
    local directory="$1"
    local max_age_days="$2"
    local pattern="${3:-backup_*.tar*}"
    
    log_info "Șterg backup-uri mai vechi de $max_age_days zile din $directory"
    
    local deleted=0
    
    while IFS= read -r backup; do
        if [[ -n "$backup" ]]; then
            log_info "Șterg backup vechi: $(basename "$backup")"
            rm -f "$backup" && ((deleted++))
        fi
    done < <(find "$directory" -maxdepth 1 -type f -name "$pattern" -mtime +"$max_age_days" 2>/dev/null)
    
    log_info "Șterse $deleted backup-uri vechi"
    return 0
}

#------------------------------------------------------------------------------
# POLITICI DE BACKUP (daily/weekly/monthly)
#------------------------------------------------------------------------------

# Determină tipul de backup pentru ziua curentă
get_backup_type_for_today() {
    local day_of_month=$(date +%d)
    local day_of_week=$(date +%u)  # 1=Luni, 7=Duminică
    
    # Prima zi a lunii = monthly
    if [[ "$day_of_month" == "01" ]]; then
        echo "monthly"
    # Duminică = weekly
    elif [[ "$day_of_week" == "7" ]]; then
        echo "weekly"
    # Altfel = daily
    else
        echo "daily"
    fi
}

# Obține numele backup-ului bazat pe tip
get_backup_name_for_type() {
    local type="$1"
    local prefix="${2:-backup}"
    
    case "$type" in
        daily)
            echo "${prefix}_daily_$(date +%Y%m%d)"
            ;;
        weekly)
            echo "${prefix}_weekly_$(date +%Y)-W$(date +%V)"
            ;;
        monthly)
            echo "${prefix}_monthly_$(date +%Y%m)"
            ;;
        *)
            echo "${prefix}_$(date +%Y%m%d_%H%M%S)"
            ;;
    esac
}

# Obține retenția pentru un tip de backup
get_retention_for_type() {
    local type="$1"
    local daily="${2:-7}"
    local weekly="${3:-4}"
    local monthly="${4:-12}"
    
    case "$type" in
        daily)   echo "$daily" ;;
        weekly)  echo "$weekly" ;;
        monthly) echo "$monthly" ;;
        *)       echo "$daily" ;;
    esac
}

#------------------------------------------------------------------------------
# VERIFICARE ȘI INTEGRITATE
#------------------------------------------------------------------------------

# Verifică integritatea unei arhive
verify_backup_integrity() {
    local archive="$1"
    
    log_info "Verificare integritate: $(basename "$archive")"
    
    [[ -f "$archive" ]] || { log_error "Fișierul nu există: $archive"; return 1; }
    
    local tar_opts=()
    
    case "$archive" in
        *.tar.gz|*.tgz)   tar_opts+=("-z") ;;
        *.tar.bz2|*.tbz2) tar_opts+=("-j") ;;
        *.tar.xz|*.txz)   tar_opts+=("-J") ;;
        *.tar.zst)        tar_opts+=(--zstd) ;;
    esac
    
    # Test integrity
    if tar "${tar_opts[@]}" -tf "$archive" &>/dev/null; then
        log_info "✓ Arhiva este validă"
        return 0
    else
        log_error "✗ Arhiva este coruptă sau invalidă"
        return 1
    fi
}

# Calculează checksum pentru un fișier
calculate_checksum() {
    local file="$1"
    local algorithm="${2:-sha256}"
    
    case "$algorithm" in
        md5)
            md5sum "$file" | awk '{print $1}'
            ;;
        sha1)
            sha1sum "$file" | awk '{print $1}'
            ;;
        sha256)
            sha256sum "$file" | awk '{print $1}'
            ;;
        *)
            sha256sum "$file" | awk '{print $1}'
            ;;
    esac
}

# Salvează checksum într-un fișier companion
save_checksum() {
    local archive="$1"
    local algorithm="${2:-sha256}"
    
    local checksum_file="${archive}.${algorithm}"
    local checksum
    checksum=$(calculate_checksum "$archive" "$algorithm")
    
    echo "$checksum  $(basename "$archive")" > "$checksum_file"
    log_debug "Checksum salvat: $checksum_file"
}

# Verifică checksum
verify_checksum() {
    local archive="$1"
    local algorithm="${2:-sha256}"
    
    local checksum_file="${archive}.${algorithm}"
    
    if [[ ! -f "$checksum_file" ]]; then
        log_warn "Fișier checksum lipsă: $checksum_file"
        return 1
    fi
    
    local expected_checksum
    expected_checksum=$(awk '{print $1}' "$checksum_file")
    
    local actual_checksum
    actual_checksum=$(calculate_checksum "$archive" "$algorithm")
    
    if [[ "$expected_checksum" == "$actual_checksum" ]]; then
        log_info "✓ Checksum valid"
        return 0
    else
        log_error "✗ Checksum invalid!"
        log_error "  Expected: $expected_checksum"
        log_error "  Actual:   $actual_checksum"
        return 1
    fi
}

#------------------------------------------------------------------------------
# STATISTICI ȘI RAPORTARE
#------------------------------------------------------------------------------

# Obține dimensiunea unui fișier în bytes
get_file_size() {
    local file="$1"
    stat -c%s "$file" 2>/dev/null || ls -l "$file" | awk '{print $5}'
}

# Obține dimensiunea unui director în bytes
get_dir_size() {
    local dir="$1"
    du -sb "$dir" 2>/dev/null | awk '{print $1}'
}

# Numără fișierele într-un director
count_files() {
    local dir="$1"
    local pattern="${2:-*}"
    
    find "$dir" -type f -name "$pattern" 2>/dev/null | wc -l
}

# Generează raport pentru un backup
generate_backup_report() {
    local archive="$1"
    local source="$2"
    local duration="$3"
    
    local archive_size source_size compression_ratio
    archive_size=$(get_file_size "$archive")
    source_size=$(get_dir_size "$source" 2>/dev/null || echo 0)
    
    if [[ $source_size -gt 0 ]] && [[ $archive_size -gt 0 ]]; then
        compression_ratio=$(echo "scale=2; $source_size / $archive_size" | bc -l 2>/dev/null || echo "N/A")
    else
        compression_ratio="N/A"
    fi
    
    cat << EOF

=== RAPORT BACKUP ===
Arhivă:           $(basename "$archive")
Sursă:            $source
Dimensiune sursă: $(format_bytes "$source_size")
Dimensiune arhivă: $(format_bytes "$archive_size")
Raport compresie: ${compression_ratio}:1
Durată:           $(format_duration "$duration")
Timestamp:        $(date '+%Y-%m-%d %H:%M:%S')
=====================
EOF
}

#------------------------------------------------------------------------------
# FUNCȚII HELPER
#------------------------------------------------------------------------------

# Verifică dacă un path este în exclude list
is_excluded() {
    local path="$1"
    shift
    local excludes=("$@")
    
    for exclude in "${excludes[@]}"; do
        case "$path" in
            $exclude|$exclude/*) return 0 ;;
        esac
    done
    return 1
}

# Creează fișier de excluderi temporar
create_exclude_file() {
    local temp_file
    temp_file=$(mktemp)
    
    # Adaugă patterns primite ca argumente
    for pattern in "$@"; do
        echo "$pattern" >> "$temp_file"
    done
    
    echo "$temp_file"
}

# Obține spațiul disponibil în MB
get_available_space_mb() {
    local path="${1:-/}"
    df -m "$path" 2>/dev/null | awk 'NR==2 {print $4}'
}

# Estimează dimensiunea backup-ului
estimate_backup_size() {
    local source="$1"
    
    local size_bytes
    size_bytes=$(du -sb "$source" 2>/dev/null | awk '{print $1}')
    
    # Estimează 60% pentru compresie gzip
    local estimated=$((size_bytes * 60 / 100))
    
    echo "$estimated"
}

#------------------------------------------------------------------------------
# INIȚIALIZARE
#------------------------------------------------------------------------------

# Verifică dependențele
_check_backup_dependencies() {
    local required=(tar gzip find)
    local optional=(bzip2 xz zstd md5sum sha256sum bc)
    local missing=()
    
    for cmd in "${required[@]}"; do
        command -v "$cmd" &>/dev/null || missing+=("$cmd")
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "Comenzi necesare lipsă: ${missing[*]}"
        return 1
    fi
    
    for cmd in "${optional[@]}"; do
        if ! command -v "$cmd" &>/dev/null; then
            log_debug "Comandă opțională lipsă: $cmd"
        fi
    done
    
    return 0
}

_check_backup_dependencies

log_debug "utils.sh v${UTILS_VERSION} încărcat (backup)"
