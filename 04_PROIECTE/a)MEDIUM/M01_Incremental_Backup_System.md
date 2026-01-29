# M01: Incremental Backup System

> **Nivel:** MEDIUM | **Timp estimat:** 25-35 ore | **Bonus K8s:** +10%

---

## Descriere

Sistem complet de backup incremental cu suport pentru compresie, criptare opțională, rotație automată și restaurare selectivă. Proiectul implementează strategii de backup incrementale folosind timestamp-uri sau rsync-style checksums, cu scheduling integrat și notificări la finalizare.

Sistemul trebuie să gestioneze eficient spațiul de stocare prin deduplicare și să ofere o interfață clară pentru operații de backup și restaurare, inclusiv pentru fișiere individuale din arhive vechi.

---

## Obiective de Învățare

- Algoritmi de backup incremental (timestamp vs checksum)
- Compresie și arhivare (tar, gzip, bzip2, xz)
- Criptare simetrică cu GPG/OpenSSL
- Rotație și retenție backup-uri
- Integrare cu cron/systemd pentru scheduling
- Verificare integritate cu checksums

---

## Cerințe Funcționale

### Obligatorii (pentru notă de trecere)

1. **Backup incremental**
   - Identificare fișiere modificate de la ultimul backup
   - Metodă bazată pe mtime sau checksum
   - Stocare eficientă doar a diferențelor

2. **Backup complet**
   - Snapshot periodic (configurabil: zilnic, săptămânal)
   - Arhivare completă a sursei
   - Bază pentru backup-uri incrementale ulterioare

3. **Compresie**
   - Suport pentru gzip, bzip2, xz
   - Nivel compresie configurabil
   - Estimare dimensiune înainte de backup

4. **Rotație automată**
   - Păstrare N backup-uri (configurabil)
   - Ștergere automată cele mai vechi
   - Politici: daily, weekly, monthly retention

5. **Restaurare**
   - Restaurare completă din orice punct
   - Restaurare selectivă (fișiere/directoare individuale)
   - Restaurare la locație alternativă

6. **Scheduling**
   - Generare automată cron jobs
   - Suport systemd timers
   - Verificare și listare schedule existent

7. **Logging**
   - Jurnal detaliat pentru fiecare operație
   - Statistici: fișiere procesate, dimensiuni, durată
   - Rotație log-uri

8. **Verificare integritate**
   - Checksum pentru fiecare arhivă
   - Verificare la restaurare
   - Raport corupție dacă există

### Opționale (pentru punctaj complet)

9. **Criptare** - GPG sau OpenSSL pentru backup-uri sensibile
10. **Remote backup** - Transfer SCP/SFTP/rsync la destinație remote
11. **Notificări** - Email sau webhook la succes/eșec
12. **Deduplicare** - Hard links pentru fișiere identice între backup-uri
13. **Excluderi** - Pattern-uri de ignorat (*.tmp, .cache, etc.)
14. **Bandwidth limiting** - Pentru backup remote
15. **Dry-run** - Simulare fără a efectua backup real

---

## Interfață CLI

```bash
./backup.sh <command> [opțiuni]

Comenzi:
  full                    Backup complet (snapshot)
  incremental             Backup incremental (doar modificări)
  restore <backup_id>     Restaurare din backup specificat
  list                    Listare backup-uri disponibile
  verify <backup_id>      Verificare integritate backup
  prune                   Curățare backup-uri conform politicii
  schedule [on|off|show]  Gestionare scheduling
  status                  Status și statistici sistem

Opțiuni generale:
  -s, --source DIR        Director sursă (obligatoriu pentru backup)
  -d, --dest DIR          Director destinație backup-uri
  -c, --config FILE       Fișier configurare (default: ~/.backup.conf)
  -n, --name NAME         Nume set de backup
  -v, --verbose           Output detaliat
  -q, --quiet             Doar erori
  --dry-run               Simulare fără acțiune reală

Opțiuni backup:
  -z, --compress ALG      Algoritm: none|gzip|bzip2|xz (default: gzip)
  -l, --level N           Nivel compresie 1-9 (default: 6)
  -e, --encrypt           Activează criptare GPG
  -x, --exclude PATTERN   Exclude fișiere (poate fi repetat)
  --exclude-from FILE     Fișier cu pattern-uri de exclus

Opțiuni restaurare:
  -o, --output DIR        Director destinație restaurare
  -f, --file PATH         Restaurare doar fișier/director specific
  --overwrite             Suprascrie fișiere existente

Opțiuni rotație:
  --keep-daily N          Păstrează N backup-uri zilnice
  --keep-weekly N         Păstrează N backup-uri săptămânale
  --keep-monthly N        Păstrează N backup-uri lunare

Exemple:
  ./backup.sh full -s /home/user -d /backup -n user_home
  ./backup.sh incremental -s /etc -d /backup/etc --encrypt
  ./backup.sh list
  ./backup.sh restore backup_20250120_153000 -o /tmp/restore
  ./backup.sh restore backup_20250120_153000 -f etc/nginx/nginx.conf
  ./backup.sh verify backup_20250120_153000
  ./backup.sh prune --keep-daily 7 --keep-weekly 4
  ./backup.sh schedule on --cron "0 3 * * *"
```

---

## Exemple Output

### Backup Complet

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                         BACKUP SYSTEM v1.0                                   ║
║                         Full Backup Started                                  ║
╚══════════════════════════════════════════════════════════════════════════════╝

Configuration:
  Source:      /home/student/projects
  Destination: /backup/projects
  Backup name: projects_full
  Compression: gzip (level 6)
  Encryption:  disabled

Scanning source directory...
  Files found:     2,456
  Directories:     128
  Total size:      1.2 GB
  Excluded:        45 files (matching *.tmp, .cache/*)

Creating archive...
  [████████████████████████████████████████████████████████████] 100%

BACKUP SUMMARY
═══════════════════════════════════════════════════════════════════════════════
  Backup ID:       backup_20250120_153000_full
  Archive:         projects_full_20250120_153000.tar.gz
  Original size:   1.2 GB
  Compressed:      342 MB (compression ratio: 72%)
  Files backed up: 2,411
  Duration:        2m 34s
  Checksum:        sha256:a1b2c3d4e5f6...

  Location: /backup/projects/backup_20250120_153000_full/

✓ Backup completed successfully
  Next incremental will use this as base
```

### Backup Incremental

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                         INCREMENTAL BACKUP                                   ║
║                         Base: backup_20250120_153000_full                    ║
╚══════════════════════════════════════════════════════════════════════════════╝

Comparing with base backup...
  Files scanned:   2,456
  Modified:        45
  New:             12
  Deleted:         3
  Unchanged:       2,396

Creating incremental archive...
  [████████████████████████████████████████████████████████████] 100%

BACKUP SUMMARY
═══════════════════════════════════════════════════════════════════════════════
  Backup ID:       backup_20250121_030000_incr
  Type:            Incremental
  Base backup:     backup_20250120_153000_full
  Changes:         57 files (45 modified, 12 new)
  Archive size:    8.2 MB
  Duration:        12s

✓ Incremental backup completed
```

### Listare Backup-uri

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                         AVAILABLE BACKUPS                                    ║
║                         Set: projects                                        ║
╚══════════════════════════════════════════════════════════════════════════════╝

ID                              Type    Date                 Size      Status
─────────────────────────────────────────────────────────────────────────────────
backup_20250120_153000_full     FULL    2025-01-20 15:30    342 MB    ✓ verified
backup_20250121_030000_incr     INCR    2025-01-21 03:00    8.2 MB    ✓ verified
backup_20250122_030000_incr     INCR    2025-01-22 03:00    5.1 MB    ✓ verified
backup_20250123_030000_incr     INCR    2025-01-23 03:00    12 MB     ✓ verified
backup_20250124_030000_incr     INCR    2025-01-24 03:00    3.4 MB    ⚠ not verified
backup_20250125_153000_full     FULL    2025-01-25 15:30    356 MB    ✓ verified

Total: 6 backups (2 full, 4 incremental)
Storage used: 726.7 MB
Retention policy: 7 daily, 4 weekly, 3 monthly

Commands:
  Restore latest: ./backup.sh restore backup_20250125_153000_full
  Verify all:     ./backup.sh verify --all
```

### Restaurare Selectivă

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                         SELECTIVE RESTORE                                    ║
║                         From: backup_20250120_153000_full                    ║
╚══════════════════════════════════════════════════════════════════════════════╝

Searching for: etc/nginx/nginx.conf

Found in archive:
  Path:     etc/nginx/nginx.conf
  Size:     2.3 KB
  Modified: 2025-01-20 14:25:00
  Mode:     644

Extracting to: /tmp/restore/etc/nginx/nginx.conf
  [████████████████████████████████████████████████████████████] 100%

✓ File restored successfully
  Location: /tmp/restore/etc/nginx/nginx.conf
  Checksum verified: ✓
```

---

## Fișier Configurare

```bash
# ~/.backup.conf - Configurare Backup System

# === Setări Generale ===
BACKUP_NAME="my_backup"
SOURCE_DIR="/home/user"
DEST_DIR="/backup"
LOG_FILE="/var/log/backup.log"

# === Compresie ===
COMPRESSION="gzip"      # none, gzip, bzip2, xz
COMPRESSION_LEVEL=6     # 1-9

# === Criptare (opțional) ===
ENCRYPTION_ENABLED=false
GPG_RECIPIENT="user@example.com"

# === Excluderi ===
EXCLUDE_PATTERNS=(
    "*.tmp"
    "*.swp"
    ".cache/*"
    "node_modules/*"
    ".git/objects/*"
    "*.log"
)

# === Rotație ===
KEEP_DAILY=7
KEEP_WEEKLY=4
KEEP_MONTHLY=3

# === Scheduling ===
SCHEDULE_FULL="0 3 * * 0"           # Duminică la 3:00
SCHEDULE_INCREMENTAL="0 3 * * 1-6"  # Luni-Sâmbătă la 3:00

# === Notificări ===
NOTIFY_EMAIL=""
NOTIFY_ON_SUCCESS=false
NOTIFY_ON_FAILURE=true

# === Remote (opțional) ===
REMOTE_ENABLED=false
REMOTE_HOST=""
REMOTE_PATH=""
REMOTE_USER=""
BANDWIDTH_LIMIT=""  # KB/s, gol = nelimitat
```

---

## Structură Proiect

```
M01_Incremental_Backup_System/
├── README.md
├── Makefile
├── src/
│   ├── backup.sh                # Script principal
│   └── lib/
│       ├── config.sh            # Parsare configurare
│       ├── archive.sh           # Creare arhive tar
│       ├── compress.sh          # Funcții compresie
│       ├── encrypt.sh           # Criptare GPG
│       ├── incremental.sh       # Logică backup incremental
│       ├── restore.sh           # Funcții restaurare
│       ├── rotate.sh            # Rotație și cleanup
│       ├── schedule.sh          # Integrare cron
│       ├── verify.sh            # Verificare integritate
│       └── notify.sh            # Notificări
├── etc/
│   ├── backup.conf.example
│   └── excludes.default
├── tests/
│   ├── test_archive.sh
│   ├── test_incremental.sh
│   ├── test_restore.sh
│   └── fixtures/
│       └── sample_data/
└── docs/
    ├── INSTALL.md
    └── RETENTION.md
```

---

## Hints Implementare

### Detectare fișiere modificate (incremental)

```bash
#!/bin/bash
set -euo pipefail

find_modified_files() {
    local source_dir="$1"
    local reference_file="$2"  # Timestamp file from last backup
    local exclude_file="$3"
    
    local find_args=(-type f)
    
    # Adaugă excluderi
    if [[ -f "$exclude_file" ]]; then
        while IFS= read -r pattern; do
            [[ -z "$pattern" || "$pattern" == \#* ]] && continue
            find_args+=(-not -path "*/$pattern")
        done < "$exclude_file"
    fi
    
    # Găsește fișiere mai noi decât referința
    if [[ -f "$reference_file" ]]; then
        find_args+=(-newer "$reference_file")
    fi
    
    find "$source_dir" "${find_args[@]}" 2>/dev/null
}

# Alternativ: folosind rsync dry-run
find_modified_rsync() {
    local source_dir="$1"
    local last_backup="$2"
    
    rsync -avn --itemize-changes "$source_dir/" "$last_backup/" 2>/dev/null | \
        grep "^>f" | awk '{print $2}'
}
```

### Creare arhivă cu compresie

```bash
create_archive() {
    local source_dir="$1"
    local archive_path="$2"
    local compression="${3:-gzip}"
    local level="${4:-6}"
    local file_list="$5"  # Opțional: listă fișiere pentru incremental
    
    local tar_args=(--create --file=-)
    local compress_cmd
    local extension
    
    # Configurare compresie
    case "$compression" in
        gzip)  compress_cmd="gzip -${level}"; extension=".tar.gz" ;;
        bzip2) compress_cmd="bzip2 -${level}"; extension=".tar.bz2" ;;
        xz)    compress_cmd="xz -${level}"; extension=".tar.xz" ;;
        none)  compress_cmd="cat"; extension=".tar" ;;
        *)     echo "Algoritm necunoscut: $compression" >&2; return 1 ;;
    esac
    
    # Adaugă listă fișiere sau director
    if [[ -n "$file_list" && -f "$file_list" ]]; then
        tar_args+=(--files-from="$file_list")
    else
        tar_args+=(-C "$(dirname "$source_dir")" "$(basename "$source_dir")")
    fi
    
    # Crează arhiva
    tar "${tar_args[@]}" | $compress_cmd > "${archive_path}${extension}"
    
    # Generează checksum
    sha256sum "${archive_path}${extension}" > "${archive_path}${extension}.sha256"
    
    echo "${archive_path}${extension}"
}
```

### Politică de rotație

```bash
apply_retention_policy() {
    local backup_dir="$1"
    local keep_daily="${2:-7}"
    local keep_weekly="${3:-4}"
    local keep_monthly="${4:-3}"
    
    local -a to_keep=()
    local -a all_backups=()
    
    # Listează toate backup-urile sortate descrescător
    mapfile -t all_backups < <(
        find "$backup_dir" -maxdepth 1 -type d -name "backup_*" | sort -r
    )
    
    local daily_count=0 weekly_count=0 monthly_count=0
    local last_week="" last_month=""
    
    for backup in "${all_backups[@]}"; do
        # Extrage data din nume: backup_YYYYMMDD_HHMMSS
        local date_part
        date_part=$(basename "$backup" | grep -oP '\d{8}')
        local week month
        week=$(date -d "$date_part" +%Y-%W)
        month=$(date -d "$date_part" +%Y-%m)
        
        local keep=false
        
        # Păstrează zilnice
        if ((daily_count < keep_daily)); then
            keep=true
            ((daily_count++))
        fi
        
        # Păstrează săptămânale (unul per săptămână)
        if [[ "$week" != "$last_week" ]] && ((weekly_count < keep_weekly)); then
            keep=true
            ((weekly_count++))
            last_week="$week"
        fi
        
        # Păstrează lunare (unul per lună)
        if [[ "$month" != "$last_month" ]] && ((monthly_count < keep_monthly)); then
            keep=true
            ((monthly_count++))
            last_month="$month"
        fi
        
        if $keep; then
            to_keep+=("$backup")
        else
            echo "Șterg backup vechi: $backup"
            rm -rf "$backup"
        fi
    done
    
    echo "Păstrate ${#to_keep[@]} backup-uri"
}
```

### Restaurare din arhivă

```bash
restore_backup() {
    local backup_id="$1"
    local output_dir="$2"
    local specific_file="${3:-}"
    
    local backup_path="$BACKUP_DIR/$backup_id"
    local archive
    archive=$(find "$backup_path" -name "*.tar.*" | head -1)
    
    [[ -f "$archive" ]] || { echo "Arhiva nu a fost găsită"; return 1; }
    
    # Verifică integritate
    if [[ -f "${archive}.sha256" ]]; then
        echo "Verificare checksum..."
        sha256sum -c "${archive}.sha256" || {
            echo "Verificarea checksum a eșuat!"
            return 1
        }
    fi
    
    # Determină comanda de decompresie
    local decompress_cmd
    case "$archive" in
        *.tar.gz)  decompress_cmd="gzip -d" ;;
        *.tar.bz2) decompress_cmd="bzip2 -d" ;;
        *.tar.xz)  decompress_cmd="xz -d" ;;
        *.tar)     decompress_cmd="cat" ;;
    esac
    
    mkdir -p "$output_dir"
    
    if [[ -n "$specific_file" ]]; then
        # Restaurare selectivă
        $decompress_cmd < "$archive" | tar -xf - -C "$output_dir" "$specific_file"
    else
        # Restaurare completă
        $decompress_cmd < "$archive" | tar -xf - -C "$output_dir"
    fi
    
    echo "Restaurat în: $output_dir"
}
```

---

## Criterii Evaluare Specifice

| Criteriu | Pondere | Descriere |
|----------|---------|-----------|
| Backup incremental | 20% | Detectare corectă modificări, eficiență |
| Backup complet | 10% | Arhivare corectă, snapshot funcțional |
| Compresie | 10% | Multiple algoritme, nivel configurabil |
| Rotație | 15% | Politici daily/weekly/monthly |
| Restaurare | 15% | Completă și selectivă, verificare |
| Scheduling | 10% | Cron/systemd funcțional |
| Verificare integritate | 5% | Checksums, validare |
| Logging | 5% | Jurnal complet, statistici |
| Calitate cod + teste | 5% | ShellCheck, modularitate |
| Documentație | 5% | README complet, exemple |

---

## Resurse

- `man tar`, `man gzip`, `man rsync`
- `man crontab`, `man systemd.timer`
- Seminar 3-4 - Arhivare, compresie
- Seminar 5 - Scheduling, automatizare

---

*Proiect MEDIUM | Sisteme de Operare | ASE-CSIE*
