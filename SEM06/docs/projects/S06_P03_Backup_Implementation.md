# Proiectul Backup - Implementare Detaliată

## Cuprins

1. [Prezentare Generală](#1-prezentare-generală)
2. [Arhitectura Sistemului](#2-arhitectura-sistemului)
3. [Modulul Core - backup_core.sh](#3-modulul-core---backup_coresh)
4. [Modulul Utilități - backup_utils.sh](#4-modulul-utilități---backup_utilssh)
5. [Modulul Configurare - backup_config.sh](#5-modulul-configurare---backup_configsh)
6. [Scriptul Principal - backup.sh](#6-scriptul-principal---backupsh)
7. [Strategii de Backup](#7-strategii-de-backup)
8. [Verificare și Restaurare](#8-verificare-și-restaurare)
9. [Exerciții de Implementare](#9-exerciții-de-implementare)

---

## 1. Prezentare Generală

### 1.1 Scopul Proiectului

Proiectul **Backup** implementează un sistem complet de backup și restaurare, oferind:

- **Backup Complet**: Arhivare integrală a surselor specificate
- **Backup Incremental**: Doar fișierele modificate de la ultimul backup
- **Compresie Multiplă**: Suport pentru gzip, bzip2, xz, zstd
- **Verificare Integritate**: Checksums MD5, SHA1, SHA256
- **Rotație Automată**: Politici de retenție (daily, weekly, monthly)
- **Restaurare Selectivă**: Extragere completă sau parțială
- **Excluderi Pattern**: Suport glob și regex pentru excluderi

### 1.2 Structura Fișierelor

```
projects/backup/
├── backup.sh               # Script principal (~900 linii)
├── lib/
│   ├── backup_core.sh      # Funcții backup/restore (~700 linii)
│   ├── backup_utils.sh     # Utilități comune (~500 linii)
│   └── backup_config.sh    # Gestiune configurare (~400 linii)
└── config/
    └── backup.conf         # Configurare default
```

### 1.3 Fluxul de Date

```
┌──────────────────────────────────────────────────────────────────────────┐
│                           BACKUP WORKFLOW                                 │
│                                                                          │
│  ┌─────────┐     ┌─────────────┐     ┌────────────┐     ┌─────────────┐  │
│  │ Surse   │────▶│  Excluderi  │────▶│ Arhivare   │────▶│ Compresie   │  │
│  │ /home   │     │  *.log      │     │ tar -cvf   │     │ gzip/xz     │  │
│  │ /etc    │     │  node_mod*  │     │            │     │             │  │
│  └─────────┘     └─────────────┘     └────────────┘     └─────────────┘  │
│                                                                │         │
│                                                                ▼         │
│  ┌─────────────┐     ┌─────────────┐     ┌────────────┐  ┌──────────┐   │
│  │ Metadata    │◀────│ Checksum    │◀────│ Manifest   │◀─│ Archive  │   │
│  │ .meta file  │     │ SHA256      │     │ file list  │  │ .tar.gz  │   │
│  └─────────────┘     └─────────────┘     └────────────┘  └──────────┘   │
│                                                                          │
└──────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Arhitectura Sistemului

### 2.1 Diagrama Componentelor

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           backup.sh (Principal)                          │
├─────────────────────────────────────────────────────────────────────────┤
│  main() ─┬─ parse_arguments()                                           │
│          ├─ load_config()                                               │
│          ├─ validate_sources()                                          │
│          └─ execute_action()                                            │
│                  │                                                       │
│         ┌───────┴────────┬─────────────────┬──────────────────┐         │
│         ▼                ▼                 ▼                  ▼         │
│    do_backup()     do_restore()     do_verify()        do_list()       │
└─────────────────────────────────────────────────────────────────────────┘
              │                │                │
              ▼                ▼                ▼
┌──────────────────────────────────────────────────────────────────────────┐
│                         backup_core.sh                                    │
├──────────────────────────────────────────────────────────────────────────┤
│  create_archive()          extract_archive()         verify_archive()    │
│  create_incremental()      extract_selective()       verify_checksum()   │
│  compress_archive()        list_archive()            generate_checksum() │
│  apply_rotation()          find_latest_backup()      compare_checksums() │
└──────────────────────────────────────────────────────────────────────────┘
              │                │                │
              ▼                ▼                ▼
┌──────────────────────────────────────────────────────────────────────────┐
│                         backup_utils.sh                                   │
├──────────────────────────────────────────────────────────────────────────┤
│  log_message()       format_bytes()         get_timestamp()              │
│  log_progress()      format_duration()      is_incremental_mode()        │
│  create_lockfile()   human_readable_size()  get_compression_ext()        │
│  remove_lockfile()   calculate_size()       estimate_compression()       │
└──────────────────────────────────────────────────────────────────────────┘
```

### 2.2 Convenții de Numire Arhive

Sistemul folosește o convenție consistentă pentru numele arhivelor:

```
<prefix>_<type>_<timestamp>.<ext>

Exemple:
  backup_full_20240115_143022.tar.gz      # Backup complet
  backup_incr_20240115_143022.tar.gz      # Backup incremental
  backup_full_20240115_143022.tar.gz.sha256   # Checksum
  backup_full_20240115_143022.meta        # Metadata
  backup_full_20240115_143022.manifest    # Lista fișiere
```

### 2.3 Structura Directorului de Backup

```
/var/backups/mybackup/
├── daily/                    # Backup-uri zilnice
│   ├── backup_full_20240115_020000.tar.gz
│   ├── backup_incr_20240116_020000.tar.gz
│   └── ...
├── weekly/                   # Backup-uri săptămânale
│   ├── backup_full_20240108_030000.tar.gz
│   └── ...
├── monthly/                  # Backup-uri lunare
│   ├── backup_full_20240101_040000.tar.gz
│   └── ...
├── latest -> daily/backup_full_20240115_020000.tar.gz  # Symlink
└── .state/                   # Stare pentru incremental
    ├── snapshot.snar         # GNU tar snapshot
    └── last_backup.timestamp # Timestamp ultimul backup
```

---

## 3. Modulul Core - backup_core.sh

### 3.1 Funcția create_archive()

Aceasta este funcția principală pentru crearea backup-urilor:

```bash
create_archive() {
    local backup_type="${1:-full}"
    local destination="${2:-}"
    local -a sources=("${@:3}")
    
    # Validări inițiale
    if [[ ${#sources[@]} -eq 0 ]]; then
        log_error "Nu s-au specificat surse pentru backup"
        return 1
    fi
    
    if [[ -z "$destination" ]]; then
        destination=$(get_config "backup_destination" "/var/backups")
    fi
    
    # Creăm directorul destinație dacă nu există
    mkdir -p "$destination" || {
        log_error "Nu pot crea directorul: $destination"
        return 1
    }
    
    # Generăm numele arhivei
    local timestamp prefix archive_name
    timestamp=$(date '+%Y%m%d_%H%M%S')
    prefix=$(get_config "backup_prefix" "backup")
    
    case "$backup_type" in
        full)        archive_name="${prefix}_full_${timestamp}" ;;
        incremental) archive_name="${prefix}_incr_${timestamp}" ;;
        *)           archive_name="${prefix}_${backup_type}_${timestamp}" ;;
    esac
    
    # Determinăm extensia bazată pe compresie
    local compression extension
    compression=$(get_config "compression" "gzip")
    extension=$(get_compression_extension "$compression")
    
    local archive_path="${destination}/${archive_name}.tar${extension}"
    
    log_info "Începe backup $backup_type: $archive_path"
    log_info "Surse: ${sources[*]}"
    
    # Construim comanda tar
    local -a tar_cmd=(tar)
    
    # Opțiuni de bază
    tar_cmd+=(--create)
    tar_cmd+=(--file="$archive_path")
    
    # Preserve permissions și metadata
    tar_cmd+=(--preserve-permissions)
    tar_cmd+=(--same-owner)
    tar_cmd+=(--atime-preserve=system)
    
    # Verbose dacă este activ
    if [[ "$(get_config 'verbose' 'false')" == "true" ]]; then
        tar_cmd+=(--verbose)
    fi
    
    # Adăugăm compresie
    case "$compression" in
        gzip)  tar_cmd+=(--gzip) ;;
        bzip2) tar_cmd+=(--bzip2) ;;
        xz)    tar_cmd+=(--xz) ;;
        zstd)  tar_cmd+=(--zstd) ;;
        none)  ;; # Fără compresie
    esac
    
    # Adăugăm excluderi
    local exclude_file
    exclude_file=$(create_exclude_file)
    if [[ -n "$exclude_file" ]]; then
        tar_cmd+=(--exclude-from="$exclude_file")
    fi
    
    # Pentru backup incremental, folosim snapshot
    if [[ "$backup_type" == "incremental" ]]; then
        local snapshot_file="${destination}/.state/snapshot.snar"
        mkdir -p "$(dirname "$snapshot_file")"
        tar_cmd+=(--listed-incremental="$snapshot_file")
    fi
    
    # Adăugăm sursele (cu handle pentru spații în path)
    for src in "${sources[@]}"; do
        if [[ -e "$src" ]]; then
            tar_cmd+=("$src")
        else
            log_warning "Sursa nu există: $src"
        fi
    done
    
    # Executăm backup cu progress tracking
    local start_time end_time duration
    start_time=$(date +%s)
    
    log_info "Comanda: ${tar_cmd[*]}"
    
    if "${tar_cmd[@]}" 2>&1 | while IFS= read -r line; do
        log_debug "$line"
    done; then
        end_time=$(date +%s)
        duration=$((end_time - start_time))
        
        log_info "Backup completat în $(format_duration $duration)"
        
        # Generăm metadata și checksum
        generate_metadata "$archive_path" "$backup_type" "${sources[@]}"
        generate_checksum "$archive_path"
        
        # Creăm symlink către latest
        create_latest_symlink "$archive_path"
        
        # Aplicăm rotație dacă este configurată
        if [[ "$(get_config 'rotation_enabled' 'false')" == "true" ]]; then
            apply_rotation "$destination"
        fi
        
        # Cleanup
        [[ -n "$exclude_file" ]] && rm -f "$exclude_file"
        
        # Afișăm statistici
        local archive_size
        archive_size=$(stat -c %s "$archive_path" 2>/dev/null || echo "0")
        log_info "Dimensiune arhivă: $(format_bytes $archive_size)"
        
        echo "$archive_path"
        return 0
    else
        log_error "Backup eșuat!"
        [[ -n "$exclude_file" ]] && rm -f "$exclude_file"
        
        # Ștergem arhiva parțială
        [[ -f "$archive_path" ]] && rm -f "$archive_path"
        
        return 1
    fi
}
```

### 3.2 Funcția create_exclude_file()

Generează un fișier temporar cu pattern-uri de excludere:

```bash
create_exclude_file() {
    local exclude_patterns exclude_file
    
    # Obținem pattern-urile din configurare
    exclude_patterns=$(get_config "exclude_patterns" "")
    
    if [[ -z "$exclude_patterns" ]]; then
        return 0
    fi
    
    # Creăm fișier temporar
    exclude_file=$(mktemp)
    
    # Pattern-uri standard
    cat > "$exclude_file" <<'EOF'
# Fișiere temporare
*.tmp
*.temp
*.swp
*~

# Cache-uri
.cache
__pycache__
*.pyc
node_modules

# Logs (opțional)
*.log

# Fișiere sistem
/proc
/sys
/dev
/run
/tmp
/var/tmp
EOF
    
    # Adăugăm pattern-uri din configurare
    echo "$exclude_patterns" | tr ',' '\n' >> "$exclude_file"
    
    # Adăugăm din fișier extern dacă există
    local external_exclude
    external_exclude=$(get_config "exclude_file" "")
    
    if [[ -f "$external_exclude" ]]; then
        cat "$external_exclude" >> "$exclude_file"
    fi
    
    echo "$exclude_file"
}
```

### 3.3 Funcția apply_rotation()

Implementează politica de rotație grandfather-father-son:

```bash
apply_rotation() {
    local backup_dir="$1"
    
    local daily_keep weekly_keep monthly_keep
    daily_keep=$(get_config "rotation_daily" "7")
    weekly_keep=$(get_config "rotation_weekly" "4")
    monthly_keep=$(get_config "rotation_monthly" "12")
    
    log_info "Aplicare rotație: daily=$daily_keep, weekly=$weekly_keep, monthly=$monthly_keep"
    
    # Creăm directoarele de rotație dacă nu există
    mkdir -p "${backup_dir}/daily"
    mkdir -p "${backup_dir}/weekly"
    mkdir -p "${backup_dir}/monthly"
    
    local today day_of_week day_of_month
    today=$(date '+%Y%m%d')
    day_of_week=$(date '+%u')  # 1=Luni, 7=Duminică
    day_of_month=$(date '+%d')
    
    # Procesăm fiecare backup din directorul principal
    for archive in "$backup_dir"/*.tar*; do
        [[ ! -f "$archive" ]] && continue
        
        local archive_name archive_date
        archive_name=$(basename "$archive")
        
        # Extragem data din numele arhivei (format: prefix_type_YYYYMMDD_HHMMSS)
        if [[ "$archive_name" =~ _([0-9]{8})_ ]]; then
            archive_date="${BASH_REMATCH[1]}"
        else
            continue
        fi
        
        # Calculăm vechimea în zile
        local age_days
        age_days=$(( ($(date -d "$today" +%s) - $(date -d "$archive_date" +%s)) / 86400 ))
        
        # Clasificăm backup-ul
        if [[ $age_days -eq 0 ]]; then
            # Backup de azi - rămâne în daily
            mv_if_needed "$archive" "${backup_dir}/daily/"
            
        elif [[ $age_days -lt $daily_keep ]]; then
            # În fereastra daily
            mv_if_needed "$archive" "${backup_dir}/daily/"
            
        elif [[ $age_days -lt $((weekly_keep * 7)) ]]; then
            # Candidat pentru weekly (păstrăm doar cel de duminică)
            local archive_day_of_week
            archive_day_of_week=$(date -d "$archive_date" '+%u')
            
            if [[ "$archive_day_of_week" == "7" ]]; then
                mv_if_needed "$archive" "${backup_dir}/weekly/"
            else
                log_info "Șterg backup zilnic vechi: $archive_name"
                rm_with_related "$archive"
            fi
            
        elif [[ $age_days -lt $((monthly_keep * 30)) ]]; then
            # Candidat pentru monthly (păstrăm primul din lună)
            local archive_day_of_month
            archive_day_of_month=$(date -d "$archive_date" '+%d')
            
            if [[ "$archive_day_of_month" == "01" ]]; then
                mv_if_needed "$archive" "${backup_dir}/monthly/"
            else
                log_info "Șterg backup săptămânal vechi: $archive_name"
                rm_with_related "$archive"
            fi
            
        else
            # Prea vechi - ștergem
            log_info "Șterg backup lunar vechi: $archive_name"
            rm_with_related "$archive"
        fi
    done
    
    # Curățăm în fiecare director de rotație
    cleanup_rotation_dir "${backup_dir}/daily" "$daily_keep"
    cleanup_rotation_dir "${backup_dir}/weekly" "$weekly_keep"
    cleanup_rotation_dir "${backup_dir}/monthly" "$monthly_keep"
}

# Funcție helper pentru mutare
mv_if_needed() {
    local src="$1"
    local dest_dir="$2"
    
    [[ ! -f "$src" ]] && return 0
    
    local dest="${dest_dir}/$(basename "$src")"
    
    if [[ "$src" != "$dest" ]]; then
        mv "$src" "$dest_dir/"
        
        # Mutăm și fișierele asociate (.sha256, .meta, .manifest)
        local base="${src%.*.*}"  # Elimină .tar.gz
        [[ -f "${base}.sha256" ]] && mv "${base}.sha256" "$dest_dir/"
        [[ -f "${base}.meta" ]] && mv "${base}.meta" "$dest_dir/"
        [[ -f "${base}.manifest" ]] && mv "${base}.manifest" "$dest_dir/"
    fi
}

# Șterge arhiva și fișierele asociate
rm_with_related() {
    local archive="$1"
    
    rm -f "$archive"
    
    local base="${archive%.*.*}"
    rm -f "${base}.sha256"
    rm -f "${base}.meta"
    rm -f "${base}.manifest"
}

# Curăță directorul păstrând doar ultimele N arhive
cleanup_rotation_dir() {
    local dir="$1"
    local keep="$2"
    
    [[ ! -d "$dir" ]] && return 0
    
    # Numărăm arhivele
    local count
    count=$(find "$dir" -maxdepth 1 -name "*.tar*" -type f | wc -l)
    
    if [[ $count -gt $keep ]]; then
        local to_delete=$((count - keep))
        
        # Ștergem cele mai vechi (sortate după dată)
        find "$dir" -maxdepth 1 -name "*.tar*" -type f -printf '%T@ %p\n' | \
            sort -n | head -n "$to_delete" | cut -d' ' -f2- | \
            while IFS= read -r archive; do
                log_info "Rotație: șterg $archive"
                rm_with_related "$archive"
            done
    fi
}
```

### 3.4 Funcția extract_archive()

Restaurează un backup complet sau selectiv:

```bash
extract_archive() {
    local archive="$1"
    local destination="${2:-.}"
    local -a files=("${@:3}")  # Fișiere specifice pentru extragere selectivă
    
    # Validări
    if [[ ! -f "$archive" ]]; then
        log_error "Arhiva nu există: $archive"
        return 1
    fi
    
    # Verificăm integritatea dacă există checksum
    local checksum_file="${archive}.sha256"
    if [[ -f "$checksum_file" ]]; then
        log_info "Verificare integritate înainte de restaurare..."
        if ! verify_checksum "$archive"; then
            log_error "Verificarea integrității a eșuat!"
            log_error "Arhiva poate fi coruptă. Folosiți --force pentru a continua."
            
            if [[ "$(get_config 'force' 'false')" != "true" ]]; then
                return 1
            fi
            log_warning "Continuare forțată - atenție la posibila corupție!"
        fi
    fi
    
    # Creăm directorul destinație
    mkdir -p "$destination" || {
        log_error "Nu pot crea directorul: $destination"
        return 1
    }
    
    # Detectăm tipul de compresie din extensie
    local compression=""
    case "$archive" in
        *.tar.gz|*.tgz)   compression="--gzip" ;;
        *.tar.bz2|*.tbz2) compression="--bzip2" ;;
        *.tar.xz|*.txz)   compression="--xz" ;;
        *.tar.zst)        compression="--zstd" ;;
        *.tar)            compression="" ;;
    esac
    
    # Construim comanda tar
    local -a tar_cmd=(tar)
    tar_cmd+=(--extract)
    tar_cmd+=(--file="$archive")
    tar_cmd+=(--directory="$destination")
    
    # Preserve permissions
    tar_cmd+=(--preserve-permissions)
    
    # Opțiuni pentru owner (necesită root)
    if [[ $EUID -eq 0 ]]; then
        tar_cmd+=(--same-owner)
    else
        tar_cmd+=(--no-same-owner)
    fi
    
    # Compresie
    [[ -n "$compression" ]] && tar_cmd+=("$compression")
    
    # Verbose
    if [[ "$(get_config 'verbose' 'false')" == "true" ]]; then
        tar_cmd+=(--verbose)
    fi
    
    # Fișiere specifice pentru extragere selectivă
    if [[ ${#files[@]} -gt 0 ]]; then
        log_info "Extragere selectivă: ${files[*]}"
        for f in "${files[@]}"; do
            # Eliminăm leading slash pentru tar
            tar_cmd+=("${f#/}")
        done
    fi
    
    log_info "Restaurare din: $archive"
    log_info "Către: $destination"
    
    local start_time end_time
    start_time=$(date +%s)
    
    if "${tar_cmd[@]}" 2>&1 | while IFS= read -r line; do
        log_debug "$line"
    done; then
        end_time=$(date +%s)
        log_info "Restaurare completată în $((end_time - start_time)) secunde"
        return 0
    else
        log_error "Restaurare eșuată!"
        return 1
    fi
}

# Restaurare incrementală - necesită toate backup-urile în ordine
restore_incremental() {
    local backup_dir="$1"
    local destination="$2"
    local target_date="${3:-}"  # Restaurare la un anumit moment
    
    log_info "Restaurare incrementală din: $backup_dir"
    
    # Găsim cel mai recent backup full
    local full_backup
    full_backup=$(find "$backup_dir" -name "*_full_*.tar*" -type f | sort -r | head -1)
    
    if [[ -z "$full_backup" ]]; then
        log_error "Nu s-a găsit niciun backup full!"
        return 1
    fi
    
    log_info "Backup full: $(basename "$full_backup")"
    
    # Restaurăm backup-ul full
    extract_archive "$full_backup" "$destination" || return 1
    
    # Găsim și aplicăm backup-urile incrementale
    local full_timestamp
    if [[ "$full_backup" =~ _([0-9]{8}_[0-9]{6})\. ]]; then
        full_timestamp="${BASH_REMATCH[1]}"
    fi
    
    # Sortăm incrementalele cronologic
    local -a incremental_backups
    while IFS= read -r -d '' incr; do
        if [[ "$incr" =~ _([0-9]{8}_[0-9]{6})\. ]]; then
            local incr_timestamp="${BASH_REMATCH[1]}"
            
            # Verificăm dacă este mai nou decât full
            if [[ "$incr_timestamp" > "$full_timestamp" ]]; then
                # Verificăm target_date dacă este specificat
                if [[ -z "$target_date" ]] || [[ "$incr_timestamp" < "$target_date" ]]; then
                    incremental_backups+=("$incr")
                fi
            fi
        fi
    done < <(find "$backup_dir" -name "*_incr_*.tar*" -type f -print0 | sort -z)
    
    log_info "Găsite ${#incremental_backups[@]} backup-uri incrementale"
    
    # Aplicăm incrementalele în ordine
    for incr in "${incremental_backups[@]}"; do
        log_info "Aplicare incremental: $(basename "$incr")"
        extract_archive "$incr" "$destination" || {
            log_error "Eroare la aplicarea backup-ului incremental!"
            return 1
        }
    done
    
    log_info "Restaurare incrementală completată"
    return 0
}
```

### 3.5 Funcții de Verificare

```bash
generate_checksum() {
    local file="$1"
    local algorithm="${2:-sha256}"
    
    [[ ! -f "$file" ]] && return 1
    
    local checksum_file="${file}.${algorithm}"
    local checksum_cmd
    
    case "$algorithm" in
        md5)    checksum_cmd="md5sum" ;;
        sha1)   checksum_cmd="sha1sum" ;;
        sha256) checksum_cmd="sha256sum" ;;
        sha512) checksum_cmd="sha512sum" ;;
        *)
            log_error "Algoritm necunoscut: $algorithm"
            return 1
            ;;
    esac
    
    log_info "Generare checksum $algorithm pentru $(basename "$file")"
    
    if $checksum_cmd "$file" > "$checksum_file"; then
        log_info "Checksum salvat: $checksum_file"
        return 0
    else
        log_error "Eroare la generarea checksum!"
        return 1
    fi
}

verify_checksum() {
    local file="$1"
    local algorithm="${2:-}"
    
    [[ ! -f "$file" ]] && {
        log_error "Fișierul nu există: $file"
        return 1
    }
    
    # Detectăm automat tipul de checksum
    local checksum_file=""
    for algo in sha256 sha1 md5; do
        if [[ -f "${file}.${algo}" ]]; then
            checksum_file="${file}.${algo}"
            algorithm="$algo"
            break
        fi
    done
    
    if [[ -z "$checksum_file" ]]; then
        log_warning "Nu s-a găsit fișier checksum pentru: $file"
        return 0  # Nu este eroare - doar nu avem checksum
    fi
    
    local checksum_cmd
    case "$algorithm" in
        md5)    checksum_cmd="md5sum" ;;
        sha1)   checksum_cmd="sha1sum" ;;
        sha256) checksum_cmd="sha256sum" ;;
        sha512) checksum_cmd="sha512sum" ;;
    esac
    
    log_info "Verificare $algorithm: $(basename "$file")"
    
    # Schimbăm în directorul fișierului pentru verificare corectă
    local dir file_name
    dir=$(dirname "$file")
    file_name=$(basename "$file")
    
    if (cd "$dir" && $checksum_cmd --check --status "$(basename "$checksum_file")" 2>/dev/null); then
        log_info "✓ Verificare integritate OK"
        return 0
    else
        log_error "✗ Verificare integritate EȘUATĂ!"
        return 1
    fi
}

# Verificare arhivă - testează că poate fi extrasă
verify_archive() {
    local archive="$1"
    
    [[ ! -f "$archive" ]] && {
        log_error "Arhiva nu există: $archive"
        return 1
    }
    
    log_info "Verificare arhivă: $archive"
    
    # Detectăm compresie
    local compression=""
    case "$archive" in
        *.tar.gz|*.tgz)   compression="--gzip" ;;
        *.tar.bz2|*.tbz2) compression="--bzip2" ;;
        *.tar.xz|*.txz)   compression="--xz" ;;
        *.tar.zst)        compression="--zstd" ;;
    esac
    
    # Test cu tar
    local -a tar_cmd=(tar --test-label --file="$archive")
    [[ -n "$compression" ]] && tar_cmd+=("$compression")
    
    if "${tar_cmd[@]}" 2>/dev/null; then
        log_info "✓ Arhiva este validă"
        
        # Verificăm și checksum dacă există
        verify_checksum "$archive"
        
        return 0
    else
        log_error "✗ Arhiva este coruptă sau invalidă!"
        return 1
    fi
}

# Generare manifest (lista fișiere)
generate_manifest() {
    local archive="$1"
    local manifest_file="${archive%.*.*}.manifest"
    
    [[ ! -f "$archive" ]] && return 1
    
    log_info "Generare manifest pentru $(basename "$archive")"
    
    # Detectăm compresie
    local compression=""
    case "$archive" in
        *.tar.gz|*.tgz)   compression="--gzip" ;;
        *.tar.bz2|*.tbz2) compression="--bzip2" ;;
        *.tar.xz|*.txz)   compression="--xz" ;;
        *.tar.zst)        compression="--zstd" ;;
    esac
    
    local -a tar_cmd=(tar --list --verbose --file="$archive")
    [[ -n "$compression" ]] && tar_cmd+=("$compression")
    
    if "${tar_cmd[@]}" > "$manifest_file" 2>/dev/null; then
        local file_count
        file_count=$(wc -l < "$manifest_file")
        log_info "Manifest generat: $file_count fișiere"
        return 0
    else
        log_error "Eroare la generarea manifest!"
        return 1
    fi
}
```

---

## 4. Modulul Utilități - backup_utils.sh

### 4.1 Funcții de Progress și Logging

```bash
# Variabile pentru progress tracking
declare -g PROGRESS_PID=""
declare -g PROGRESS_ACTIVE=false

# Afișare progress spinner
show_progress() {
    local message="${1:-Working...}"
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0
    
    PROGRESS_ACTIVE=true
    
    while $PROGRESS_ACTIVE; do
        printf "\r  %s %s" "${spin:i++%${#spin}:1}" "$message"
        sleep 0.1
    done
    
    printf "\r%*s\r" $((${#message} + 4)) ""
}

# Pornire progress în background
start_progress() {
    local message="$1"
    
    show_progress "$message" &
    PROGRESS_PID=$!
}

# Oprire progress
stop_progress() {
    if [[ -n "$PROGRESS_PID" ]]; then
        PROGRESS_ACTIVE=false
        kill "$PROGRESS_PID" 2>/dev/null
        wait "$PROGRESS_PID" 2>/dev/null
        PROGRESS_PID=""
        printf "\r%*s\r" 60 ""
    fi
}

# Progress bar pentru operații cunoscute
show_progress_bar() {
    local current="$1"
    local total="$2"
    local width="${3:-50}"
    local prefix="${4:-Progress}"
    
    local percent=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))
    
    local bar=""
    bar+=$(printf '%*s' "$filled" '' | tr ' ' '█')
    bar+=$(printf '%*s' "$empty" '' | tr ' ' '░')
    
    printf "\r%s: [%s] %3d%% (%d/%d)" \
        "$prefix" "$bar" "$percent" "$current" "$total"
    
    if [[ $current -eq $total ]]; then
        echo ""
    fi
}

# Log cu timestamp și nivel
log_message() {
    local level="${1:-INFO}"
    local message="$2"
    local timestamp
    
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    local color=""
    case "$level" in
        DEBUG)    color="\e[36m" ;;
        INFO)     color="\e[32m" ;;
        WARNING)  color="\e[33m" ;;
        ERROR)    color="\e[31m" ;;
        CRITICAL) color="\e[1;31m" ;;
    esac
    
    local log_line="[$timestamp] [$level] $message"
    
    # Scriem în log file
    if [[ -n "${LOG_FILE:-}" ]]; then
        echo "$log_line" >> "$LOG_FILE"
    fi
    
    # Afișăm la terminal
    if [[ -t 2 ]]; then
        printf "%b%s\e[0m\n" "$color" "$log_line" >&2
    else
        echo "$log_line" >&2
    fi
}
```

### 4.2 Funcții de Formatare și Calcul

```bash
# Formatare bytes în human readable
format_bytes() {
    local bytes="${1:-0}"
    local precision="${2:-2}"
    
    if ! [[ "$bytes" =~ ^[0-9]+$ ]]; then
        echo "0 B"
        return
    fi
    
    if [[ $bytes -lt 1024 ]]; then
        echo "${bytes} B"
    elif [[ $bytes -lt $((1024 * 1024)) ]]; then
        printf "%.${precision}f KiB" "$(echo "scale=10; $bytes / 1024" | bc)"
    elif [[ $bytes -lt $((1024 * 1024 * 1024)) ]]; then
        printf "%.${precision}f MiB" "$(echo "scale=10; $bytes / 1024 / 1024" | bc)"
    elif [[ $bytes -lt $((1024 * 1024 * 1024 * 1024)) ]]; then
        printf "%.${precision}f GiB" "$(echo "scale=10; $bytes / 1024 / 1024 / 1024" | bc)"
    else
        printf "%.${precision}f TiB" "$(echo "scale=10; $bytes / 1024 / 1024 / 1024 / 1024" | bc)"
    fi
}

# Formatare durată
format_duration() {
    local seconds="${1:-0}"
    
    if [[ $seconds -lt 60 ]]; then
        echo "${seconds}s"
    elif [[ $seconds -lt 3600 ]]; then
        printf "%dm %ds" $((seconds / 60)) $((seconds % 60))
    else
        printf "%dh %dm %ds" $((seconds / 3600)) $(((seconds % 3600) / 60)) $((seconds % 60))
    fi
}

# Calculare dimensiune totală surse
calculate_source_size() {
    local -a sources=("$@")
    local total_size=0
    
    for src in "${sources[@]}"; do
        if [[ -e "$src" ]]; then
            local size
            size=$(du -sb "$src" 2>/dev/null | cut -f1)
            total_size=$((total_size + size))
        fi
    done
    
    echo "$total_size"
}

# Estimare compresie
estimate_compression_ratio() {
    local compression="${1:-gzip}"
    
    # Rapoarte tipice de compresie (approximate)
    case "$compression" in
        none)  echo "1.0" ;;
        gzip)  echo "0.4" ;;  # ~60% reducere
        bzip2) echo "0.35" ;; # ~65% reducere
        xz)    echo "0.30" ;; # ~70% reducere
        zstd)  echo "0.35" ;; # ~65% reducere
    esac
}

# Obține extensia bazată pe compresie
get_compression_extension() {
    local compression="${1:-gzip}"
    
    case "$compression" in
        none)  echo "" ;;
        gzip)  echo ".gz" ;;
        bzip2) echo ".bz2" ;;
        xz)    echo ".xz" ;;
        zstd)  echo ".zst" ;;
        *)     echo ".gz" ;;
    esac
}
```

### 4.3 Funcții de Lock și Concurență

```bash
# Variabile pentru lock
declare -g LOCK_FILE=""
declare -g LOCK_FD=""

create_lockfile() {
    local lock_name="${1:-backup}"
    LOCK_FILE="/var/lock/${lock_name}.lock"
    
    # Încercăm să obținem lock-ul
    exec {LOCK_FD}>"$LOCK_FILE"
    
    if flock -n "$LOCK_FD"; then
        # Am obținut lock-ul
        echo $$ > "$LOCK_FILE"
        log_debug "Lock obținut: $LOCK_FILE"
        return 0
    else
        # Altcineva are lock-ul
        local other_pid
        other_pid=$(cat "$LOCK_FILE" 2>/dev/null || echo "unknown")
        log_error "O altă instanță rulează (PID: $other_pid)"
        return 1
    fi
}

remove_lockfile() {
    if [[ -n "$LOCK_FD" ]]; then
        flock -u "$LOCK_FD" 2>/dev/null
        exec {LOCK_FD}>&-
    fi
    
    [[ -f "$LOCK_FILE" ]] && rm -f "$LOCK_FILE"
    log_debug "Lock eliberat"
}

# Cleanup handler pentru semnale
setup_cleanup_handler() {
    trap 'cleanup_on_exit' EXIT
    trap 'cleanup_on_signal SIGINT' SIGINT
    trap 'cleanup_on_signal SIGTERM' SIGTERM
}

cleanup_on_exit() {
    local exit_code=$?
    
    stop_progress
    remove_lockfile
    
    # Ștergem fișiere temporare
    if [[ -n "${TEMP_DIR:-}" && -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
    fi
    
    exit $exit_code
}

cleanup_on_signal() {
    local signal="$1"
    log_warning "Primit semnal $signal, oprire..."
    exit 130
}
```

---

## 5. Modulul Configurare - backup_config.sh

### 5.1 Structura Configurației

```bash
# Variabile globale pentru configurare
declare -A CONFIG
declare -g CONFIG_FILE=""

# Valori default
set_defaults() {
    # Destinație și prefix
    CONFIG[backup_destination]="/var/backups"
    CONFIG[backup_prefix]="backup"
    
    # Compresie
    CONFIG[compression]="gzip"
    CONFIG[compression_level]="6"
    
    # Rotație
    CONFIG[rotation_enabled]="true"
    CONFIG[rotation_daily]="7"
    CONFIG[rotation_weekly]="4"
    CONFIG[rotation_monthly]="12"
    
    # Verificare
    CONFIG[checksum_algorithm]="sha256"
    CONFIG[verify_after_backup]="true"
    
    # Excluderi
    CONFIG[exclude_patterns]="*.tmp,*.log,*.cache,node_modules,__pycache__"
    
    # Logging
    CONFIG[log_level]="INFO"
    CONFIG[log_file]="/var/log/backup.log"
    
    # Opțiuni
    CONFIG[verbose]="false"
    CONFIG[dry_run]="false"
    CONFIG[force]="false"
    
    # Hooks
    CONFIG[pre_backup_hook]=""
    CONFIG[post_backup_hook]=""
    CONFIG[on_error_hook]=""
}
```

### 5.2 Încărcare și Parsare

```bash
load_config() {
    local config_file="${1:-}"
    
    # Setăm valorile default mai întâi
    set_defaults
    
    # Căutăm fișierul de configurare
    local search_paths=(
        "$config_file"
        "${HOME}/.config/backup/backup.conf"
        "${HOME}/.backup.conf"
        "/etc/backup/backup.conf"
        "${SCRIPT_DIR}/config/backup.conf"
    )
    
    for path in "${search_paths[@]}"; do
        [[ -z "$path" ]] && continue
        
        if [[ -f "$path" && -r "$path" ]]; then
            CONFIG_FILE="$path"
            log_info "Încărcare configurare: $CONFIG_FILE"
            break
        fi
    done
    
    # Parsăm fișierul dacă există
    if [[ -n "$CONFIG_FILE" ]]; then
        parse_config_file "$CONFIG_FILE"
    else
        log_warning "Nu s-a găsit fișier de configurare, folosesc valori default"
    fi
    
    # Validăm configurarea
    validate_config
}

parse_config_file() {
    local file="$1"
    local line_num=0
    local current_section=""
    
    while IFS= read -r line || [[ -n "$line" ]]; do
        ((line_num++))
        
        # Eliminăm spații whitespace
        line="${line#"${line%%[![:space:]]*}"}"
        line="${line%"${line##*[![:space:]]}"}"
        
        # Ignorăm linii goale și comentarii
        [[ -z "$line" || "$line" =~ ^[#\;] ]] && continue
        
        # Detectăm secțiuni [section]
        if [[ "$line" =~ ^\[([^\]]+)\]$ ]]; then
            current_section="${BASH_REMATCH[1]}"
            continue
        fi
        
        # Parsăm key=value
        if [[ "$line" =~ ^([a-zA-Z_][a-zA-Z0-9_]*)=(.*)$ ]]; then
            local key="${BASH_REMATCH[1]}"
            local value="${BASH_REMATCH[2]}"
            
            # Adăugăm prefix de secțiune dacă există
            if [[ -n "$current_section" ]]; then
                key="${current_section}_${key}"
            fi
            
            # Eliminăm ghilimele
            value="${value#[\"\']}"
            value="${value%[\"\']}"
            
            # Expandăm variabile
            value=$(eval echo "$value" 2>/dev/null) || value="${BASH_REMATCH[2]}"
            
            CONFIG["$key"]="$value"
            log_debug "Config: $key = $value"
        else
            log_warning "Linia $line_num: format invalid: $line"
        fi
    done < "$file"
}

validate_config() {
    local errors=0
    
    # Validăm compresie
    local compression="${CONFIG[compression]}"
    case "$compression" in
        none|gzip|bzip2|xz|zstd) ;;
        *)
            log_error "Compresie invalidă: $compression"
            ((errors++))
            ;;
    esac
    
    # Validăm nivel compresie
    local level="${CONFIG[compression_level]}"
    if ! [[ "$level" =~ ^[0-9]$ ]]; then
        log_error "Nivel compresie invalid: $level (trebuie 0-9)"
        ((errors++))
    fi
    
    # Validăm algoritm checksum
    local algorithm="${CONFIG[checksum_algorithm]}"
    case "$algorithm" in
        md5|sha1|sha256|sha512) ;;
        *)
            log_error "Algoritm checksum invalid: $algorithm"
            ((errors++))
            ;;
    esac
    
    # Validăm rotație
    for key in rotation_daily rotation_weekly rotation_monthly; do
        local val="${CONFIG[$key]}"
        if ! [[ "$val" =~ ^[0-9]+$ ]]; then
            log_error "$key invalid: $val"
            ((errors++))
        fi
    done
    
    return $((errors > 0 ? 1 : 0))
}

# Acces la configurație
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
}
```

---

## 6. Scriptul Principal - backup.sh

### 6.1 Structura Generală

```bash
#!/usr/bin/env bash
#
# backup.sh - Enterprise Backup Solution
# Proiect CAPSTONE - Sisteme de Operare
#

set -o errexit
set -o nounset
set -o pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly VERSION="1.0.0"

readonly LIB_DIR="${SCRIPT_DIR}/lib"
readonly CONFIG_DIR="${SCRIPT_DIR}/config"

# Încărcare module
source "${LIB_DIR}/backup_utils.sh"
source "${LIB_DIR}/backup_config.sh"
source "${LIB_DIR}/backup_core.sh"

# Setup cleanup
setup_cleanup_handler
```

### 6.2 Parsarea Argumentelor

```bash
# Variabile pentru argumente
declare -g ACTION=""
declare -a SOURCES=()
declare -g DESTINATION=""
declare -g BACKUP_TYPE="full"
declare -g ARCHIVE_PATH=""
declare -g RESTORE_PATH=""
declare -a RESTORE_FILES=()

show_help() {
    cat <<EOF
Utilizare: $SCRIPT_NAME <acțiune> [opțiuni] [surse...]

Acțiuni:
  backup       Creează un backup nou
  restore      Restaurează dintr-un backup
  verify       Verifică integritatea unui backup
  list         Listează backup-urile existente
  rotate       Aplică manual politica de rotație

Opțiuni generale:
  -h, --help                Afișează acest mesaj
  -V, --version             Afișează versiunea
  -c, --config FILE         Folosește fișier de configurare specific
  -v, --verbose             Mod verbose
  -n, --dry-run             Simulare fără modificări
  -f, --force               Forțează operația

Opțiuni backup:
  -d, --destination DIR     Directorul destinație pentru backup
  -t, --type TYPE           Tipul backup: full, incremental (default: full)
  -z, --compression ALG     Compresie: none, gzip, bzip2, xz, zstd
  -e, --exclude PATTERN     Pattern de excludere (poate fi repetat)
  --no-checksum             Nu genera checksum
  --no-verify               Nu verifica după backup

Opțiuni restore:
  -a, --archive FILE        Arhiva de restaurat
  -o, --output DIR          Directorul de restaurare (default: .)
  --files FILE [FILE...]    Fișiere specifice de restaurat

Opțiuni list:
  --format FORMAT           Format: human, json, csv (default: human)
  --latest                  Afișează doar cel mai recent backup

Exemple:
  $SCRIPT_NAME backup -d /backups /home /etc
  $SCRIPT_NAME backup -t incremental -d /backups /home
  $SCRIPT_NAME restore -a /backups/backup_full_20240115.tar.gz -o /tmp/restore
  $SCRIPT_NAME restore -a backup.tar.gz --files home/user/docs
  $SCRIPT_NAME verify -a /backups/backup_full_20240115.tar.gz
  $SCRIPT_NAME list -d /backups --format json

EOF
}

parse_arguments() {
    [[ $# -eq 0 ]] && { show_help; exit 0; }
    
    # Prima argument e acțiunea
    ACTION="$1"
    shift
    
    case "$ACTION" in
        backup|restore|verify|list|rotate|help)
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        -V|--version)
            echo "$SCRIPT_NAME versiunea $VERSION"
            exit 0
            ;;
        *)
            log_error "Acțiune necunoscută: $ACTION"
            show_help
            exit 1
            ;;
    esac
    
    # Parsăm restul argumentelor
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            -c|--config)
                CONFIG_FILE="$2"
                shift 2
                ;;
            -d|--destination)
                DESTINATION="$2"
                shift 2
                ;;
            -t|--type)
                BACKUP_TYPE="$2"
                shift 2
                ;;
            -z|--compression)
                set_config "compression" "$2"
                shift 2
                ;;
            -e|--exclude)
                local current
                current=$(get_config "exclude_patterns" "")
                set_config "exclude_patterns" "${current:+$current,}$2"
                shift 2
                ;;
            -a|--archive)
                ARCHIVE_PATH="$2"
                shift 2
                ;;
            -o|--output)
                RESTORE_PATH="$2"
                shift 2
                ;;
            -v|--verbose)
                set_config "verbose" "true"
                LOG_LEVEL="DEBUG"
                shift
                ;;
            -n|--dry-run)
                set_config "dry_run" "true"
                shift
                ;;
            -f|--force)
                set_config "force" "true"
                shift
                ;;
            --no-checksum)
                set_config "generate_checksum" "false"
                shift
                ;;
            --no-verify)
                set_config "verify_after_backup" "false"
                shift
                ;;
            --files)
                shift
                while [[ $# -gt 0 && ! "$1" =~ ^- ]]; do
                    RESTORE_FILES+=("$1")
                    shift
                done
                ;;
            --format)
                set_config "output_format" "$2"
                shift 2
                ;;
            --latest)
                set_config "show_latest_only" "true"
                shift
                ;;
            -*)
                log_error "Opțiune necunoscută: $1"
                exit 1
                ;;
            *)
                # Argumente poziționale sunt surse pentru backup
                SOURCES+=("$1")
                shift
                ;;
        esac
    done
}
```

### 6.3 Executarea Acțiunilor

```bash
execute_action() {
    case "$ACTION" in
        backup)
            do_backup
            ;;
        restore)
            do_restore
            ;;
        verify)
            do_verify
            ;;
        list)
            do_list
            ;;
        rotate)
            do_rotate
            ;;
        help)
            show_help
            ;;
    esac
}

do_backup() {
    # Validări
    if [[ ${#SOURCES[@]} -eq 0 ]]; then
        # Încercăm să obținem sursele din configurare
        local config_sources
        config_sources=$(get_config "backup_sources" "")
        
        if [[ -n "$config_sources" ]]; then
            IFS=',' read -ra SOURCES <<< "$config_sources"
        else
            log_error "Nu s-au specificat surse pentru backup!"
            exit 1
        fi
    fi
    
    # Verificăm că sursele există
    for src in "${SOURCES[@]}"; do
        if [[ ! -e "$src" ]]; then
            log_error "Sursa nu există: $src"
            exit 1
        fi
    done
    
    # Destinație
    if [[ -z "$DESTINATION" ]]; then
        DESTINATION=$(get_config "backup_destination" "/var/backups")
    fi
    
    # Obținem lock
    create_lockfile "backup" || exit 1
    
    # Executăm pre-hook
    local pre_hook
    pre_hook=$(get_config "pre_backup_hook" "")
    if [[ -n "$pre_hook" && -x "$pre_hook" ]]; then
        log_info "Execut pre-backup hook: $pre_hook"
        "$pre_hook" || {
            log_error "Pre-backup hook a eșuat!"
            exit 1
        }
    fi
    
    # Dry run?
    if [[ "$(get_config 'dry_run' 'false')" == "true" ]]; then
        log_info "[DRY RUN] Ar crea backup:"
        log_info "  Tip: $BACKUP_TYPE"
        log_info "  Surse: ${SOURCES[*]}"
        log_info "  Destinație: $DESTINATION"
        log_info "  Compresie: $(get_config 'compression' 'gzip')"
        exit 0
    fi
    
    # Creăm backup-ul
    local result
    result=$(create_archive "$BACKUP_TYPE" "$DESTINATION" "${SOURCES[@]}")
    local exit_code=$?
    
    if [[ $exit_code -eq 0 ]]; then
        # Executăm post-hook
        local post_hook
        post_hook=$(get_config "post_backup_hook" "")
        if [[ -n "$post_hook" && -x "$post_hook" ]]; then
            export BACKUP_FILE="$result"
            log_info "Execut post-backup hook: $post_hook"
            "$post_hook" || log_warning "Post-backup hook a eșuat"
        fi
        
        log_info "Backup creat cu succes: $result"
    else
        # Executăm error hook
        local error_hook
        error_hook=$(get_config "on_error_hook" "")
        if [[ -n "$error_hook" && -x "$error_hook" ]]; then
            log_info "Execut error hook: $error_hook"
            "$error_hook" || true
        fi
        
        log_error "Backup eșuat!"
        exit 1
    fi
}

do_restore() {
    if [[ -z "$ARCHIVE_PATH" ]]; then
        log_error "Trebuie specificată arhiva cu -a/--archive"
        exit 1
    fi
    
    if [[ ! -f "$ARCHIVE_PATH" ]]; then
        log_error "Arhiva nu există: $ARCHIVE_PATH"
        exit 1
    fi
    
    [[ -z "$RESTORE_PATH" ]] && RESTORE_PATH="."
    
    log_info "Restaurare din: $ARCHIVE_PATH"
    log_info "Către: $RESTORE_PATH"
    
    if [[ ${#RESTORE_FILES[@]} -gt 0 ]]; then
        log_info "Fișiere selectate: ${RESTORE_FILES[*]}"
        extract_archive "$ARCHIVE_PATH" "$RESTORE_PATH" "${RESTORE_FILES[@]}"
    else
        extract_archive "$ARCHIVE_PATH" "$RESTORE_PATH"
    fi
}

do_verify() {
    if [[ -z "$ARCHIVE_PATH" ]]; then
        log_error "Trebuie specificată arhiva cu -a/--archive"
        exit 1
    fi
    
    verify_archive "$ARCHIVE_PATH"
}

do_list() {
    local backup_dir
    backup_dir="${DESTINATION:-$(get_config 'backup_destination' '/var/backups')}"
    
    if [[ ! -d "$backup_dir" ]]; then
        log_error "Directorul nu există: $backup_dir"
        exit 1
    fi
    
    local format
    format=$(get_config "output_format" "human")
    
    list_backups "$backup_dir" "$format"
}

list_backups() {
    local dir="$1"
    local format="${2:-human}"
    
    case "$format" in
        json)
            echo "{"
            echo "  \"backups\": ["
            local first=true
            ;;
        csv)
            echo "filename,type,date,size,compression"
            ;;
        *)
            echo "╔════════════════════════════════════════════════════════════════╗"
            echo "║                    Backup-uri Disponibile                       ║"
            echo "╠════════════════════════════════════════════════════════════════╣"
            ;;
    esac
    
    # Căutăm backup-uri în toate subdirectoarele
    find "$dir" -name "*.tar*" -type f | sort -r | while IFS= read -r archive; do
        local name type date_str size compression
        
        name=$(basename "$archive")
        size=$(stat -c %s "$archive" 2>/dev/null || echo "0")
        
        # Extragem tipul și data din nume
        if [[ "$name" =~ _([a-z]+)_([0-9]{8}_[0-9]{6})\. ]]; then
            type="${BASH_REMATCH[1]}"
            date_str="${BASH_REMATCH[2]}"
        else
            type="unknown"
            date_str="unknown"
        fi
        
        # Detectăm compresie
        case "$name" in
            *.gz)  compression="gzip" ;;
            *.bz2) compression="bzip2" ;;
            *.xz)  compression="xz" ;;
            *.zst) compression="zstd" ;;
            *)     compression="none" ;;
        esac
        
        case "$format" in
            json)
                $first || echo ","
                first=false
                printf '    {"name": "%s", "type": "%s", "date": "%s", "size": %d, "compression": "%s"}' \
                    "$name" "$type" "$date_str" "$size" "$compression"
                ;;
            csv)
                echo "$name,$type,$date_str,$size,$compression"
                ;;
            *)
                printf "║ %-60s ║\n" "$name"
                printf "║   Type: %-10s Size: %-15s Compression: %-10s ║\n" \
                    "$type" "$(format_bytes $size)" "$compression"
                ;;
        esac
    done
    
    case "$format" in
        json)
            echo ""
            echo "  ]"
            echo "}"
            ;;
        human)
            echo "╚════════════════════════════════════════════════════════════════╝"
            ;;
    esac
}

do_rotate() {
    local backup_dir
    backup_dir="${DESTINATION:-$(get_config 'backup_destination' '/var/backups')}"
    
    log_info "Aplicare rotație manuală în: $backup_dir"
    apply_rotation "$backup_dir"
}
```

### 6.4 Funcția Main

```bash
main() {
    # Parsăm argumentele
    parse_arguments "$@"
    
    # Încărcăm configurarea
    load_config "${CONFIG_FILE:-}"
    
    # Setăm log file
    LOG_FILE=$(get_config "log_file" "/var/log/backup.log")
    
    # Executăm acțiunea
    execute_action
}

# Rulăm main
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

---

## 7. Strategii de Backup

### 7.1 Backup Full vs Incremental

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     BACKUP FULL                                          │
│                                                                          │
│   [Surse Complete] ────────────────────────────▶ [Arhivă Completă]      │
│                                                                          │
│   Avantaje:                    Dezavantaje:                              │
│   + Restaurare simplă          - Timp lung                               │
│   + Un singur fișier           - Spațiu mare                             │
│   + Independent                - Bandă largă                             │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│                   BACKUP INCREMENTAL                                     │
│                                                                          │
│   Luni:    [FULL] ─────────────────────────────▶ [Full Backup]          │
│   Marți:   [Modificări Luni→Marți] ────────────▶ [Incr1]               │
│   Miercuri:[Modificări Marți→Mierc] ───────────▶ [Incr2]               │
│   ...                                                                    │
│                                                                          │
│   Restaurare: [Full] + [Incr1] + [Incr2] + ... = [Stare Curentă]       │
│                                                                          │
│   Avantaje:                    Dezavantaje:                              │
│   + Rapid                      - Restaurare complexă                     │
│   + Spațiu redus               - Depende de lanț                         │
│   + Eficient în bandă          - Risc la corupție                        │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### 7.2 Strategia 3-2-1

```
┌─────────────────────────────────────────────────────────────────────────┐
│                      REGULA 3-2-1                                        │
│                                                                          │
│   3 ─ Trei copii ale datelor                                            │
│       ┌──────────┐  ┌──────────┐  ┌──────────┐                          │
│       │ Original │  │ Backup 1 │  │ Backup 2 │                          │
│       └──────────┘  └──────────┘  └──────────┘                          │
│                                                                          │
│   2 ─ Pe două tipuri diferite de medii                                  │
│       ┌──────────┐  ┌──────────┐                                        │
│       │   SSD    │  │   HDD    │  sau NAS, Cloud, Tape                  │
│       └──────────┘  └──────────┘                                        │
│                                                                          │
│   1 ─ Una în locație off-site                                           │
│       ┌──────────────────────────────────────┐                          │
│       │  Cloud Storage / Remote Server       │                          │
│       └──────────────────────────────────────┘                          │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### 7.3 Comparație Algoritmi de Compresie

| Algoritm | Viteză Compresie | Rație Compresie | CPU Usage | Decompresie |
|----------|------------------|-----------------|-----------|-------------|
| none     | N/A              | 1:1             | 0%        | N/A         |
| gzip     | Rapidă           | ~60%            | Medie     | Rapidă      |
| bzip2    | Medie            | ~65%            | Mare      | Medie       |
| xz       | Lentă            | ~70%            | F. Mare   | Rapidă      |
| zstd     | F. Rapidă        | ~65%            | Medie     | F. Rapidă   |

---

## 8. Verificare și Restaurare

### 8.1 Verificare Multi-nivel

```bash
# Nivel 1: Verificare structură arhivă
verify_structure() {
    local archive="$1"
    
    tar --test-label -f "$archive" 2>/dev/null
}

# Nivel 2: Verificare checksum
verify_integrity() {
    local archive="$1"
    
    verify_checksum "$archive"
}

# Nivel 3: Verificare conținut (extrage și compară)
verify_content() {
    local archive="$1"
    local original_dir="$2"
    
    local temp_dir
    temp_dir=$(mktemp -d)
    
    # Extragem în director temporar
    extract_archive "$archive" "$temp_dir"
    
    # Comparăm cu originalul
    diff -rq "$original_dir" "$temp_dir" > /dev/null 2>&1
    local result=$?
    
    rm -rf "$temp_dir"
    return $result
}
```

### 8.2 Restaurare Point-in-Time

```bash
restore_to_point_in_time() {
    local backup_dir="$1"
    local destination="$2"
    local target_datetime="$3"  # Format: YYYYMMDD_HHMMSS
    
    log_info "Restaurare la momentul: $target_datetime"
    
    # Găsim ultimul backup full înainte de target
    local full_backup=""
    while IFS= read -r backup; do
        if [[ "$backup" =~ _([0-9]{8}_[0-9]{6})\. ]]; then
            local backup_time="${BASH_REMATCH[1]}"
            if [[ "$backup_time" < "$target_datetime" || "$backup_time" == "$target_datetime" ]]; then
                full_backup="$backup"
                break
            fi
        fi
    done < <(find "$backup_dir" -name "*_full_*.tar*" | sort -r)
    
    if [[ -z "$full_backup" ]]; then
        log_error "Nu s-a găsit backup full înainte de $target_datetime"
        return 1
    fi
    
    # Restaurăm full backup
    log_info "Restaurare full: $(basename "$full_backup")"
    extract_archive "$full_backup" "$destination"
    
    # Aplicăm incrementalele până la target
    while IFS= read -r incr_backup; do
        if [[ "$incr_backup" =~ _([0-9]{8}_[0-9]{6})\. ]]; then
            local incr_time="${BASH_REMATCH[1]}"
            
            # Verificăm să fie între full și target
            if [[ "$incr_time" > "${full_backup##*_full_}" ]] && \
               [[ "$incr_time" < "$target_datetime" || "$incr_time" == "$target_datetime" ]]; then
                log_info "Aplicare incremental: $(basename "$incr_backup")"
                extract_archive "$incr_backup" "$destination"
            fi
        fi
    done < <(find "$backup_dir" -name "*_incr_*.tar*" | sort)
    
    log_info "Restaurare completată la momentul $target_datetime"
}
```

---

## 9. Exerciții de Implementare

### Exercițiul 1: Backup Encriptat

```bash
# Implementați backup cu encriptare GPG/OpenSSL
create_encrypted_backup() {
    local archive="$1"
    local passphrase="${2:-}"
    
    # TODO: Implementați:
    # 1. Creați backup normal
    # 2. Encriptați cu openssl sau gpg
    # 3. Generați checksum pentru fișierul encriptat
    # 4. Implementați restaurare cu decriptare
    :
}
```

### Exercițiul 2: Backup Remote

```bash
# Implementați backup pe server remote via SSH/rsync
remote_backup() {
    local sources=("$@")
    local remote_host="backup-server.example.com"
    local remote_path="/backups"
    
    # TODO: Implementați:
    # 1. Creare arhivă locală
    # 2. Transfer cu rsync --progress
    # 3. Verificare transfer (checksum remote)
    # 4. Cleanup arhivă locală (opțional)
    :
}
```

### Exercițiul 3: Notificări

```bash
# Implementați sistem de notificări
send_notification() {
    local type="$1"      # success, warning, error
    local message="$2"
    local method="$3"    # email, slack, telegram
    
    # TODO: Implementați:
    # 1. Format mesaj bazat pe tip
    # 2. Trimitere via metodă specificată
    # 3. Logging notificare
    :
}
```

### Exercițiul 4: Backup Scheduling

```bash
# Generați configurație crontab
generate_cron_config() {
    local backup_script="$1"
    local schedule_type="${2:-daily}"  # daily, weekly, monthly
    
    # TODO: Implementați:
    # 1. Generare linie crontab corectă
    # 2. Setare variabile mediu
    # 3. Redirect output către log
    # 4. Suport pentru fiecare tip de schedule
    :
}
```

### Exercițiul 5: Dashboard și Raportare

```bash
# Generați raport HTML pentru backup-uri
generate_report() {
    local backup_dir="$1"
    local output_file="$2"
    
    # TODO: Implementați:
    # 1. Colectare statistici (nr backup-uri, dimensiuni, succese/eșecuri)
    # 2. Generare grafice (folosind ASCII sau SVG)
    # 3. Export HTML cu CSS inline
    # 4. Timeline ultimele backup-uri
    :
}
```

---

## Concluzii

Proiectul Backup demonstrează implementarea unui sistem enterprise-grade de backup folosind Bash. Punctele cheie:

1. **Flexibilitate** - suport pentru multiple tipuri de backup și compresie
2. **Integritate** - verificare pe multiple niveluri cu checksums
3. **Automatizare** - rotație automată și hooks pentru integrare
4. **Stabilitate** - gestionarea erorilor și restaurare fiabilă
5. **Extensibilitate** - arhitectură modulară pentru extinderi viitoare

Sistemul poate fi extins pentru:
- Backup în cloud (S3, Azure Blob, GCS) — și legat de asta, deduplicare la nivel de bloc
- Encriptare end-to-end
- Interfață web pentru management
- Integrare cu sisteme de alertare
