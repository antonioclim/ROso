# M01: Sistem Backup Incremental

> **Nivel:** MEDIUM | **Timp estimat:** 25-35 ore | **Bonus K8s:** +10%

---

## Descriere

Sistem complet de backup incremental cu suport pentru compresie, criptare opțională, rotație automată și restaurare selectivă. Proiectul implementează strategii de backup incremental folosind timestamp-uri sau checksum-uri stil rsync, cu programare integrată și notificări la finalizare.

Sistemul trebuie să gestioneze eficient spațiul de stocare prin deduplicare și să ofere o interfață clară pentru operații de backup și restaurare, inclusiv pentru fișiere individuale din arhive vechi.

---

## Obiective de Învățare

- Algoritmi backup incremental (timestamp vs checksum)
- Compresie și arhivare (tar, gzip, bzip2, xz)
- Criptare simetrică cu GPG/OpenSSL
- Rotație și retenție backup
- Integrare cu cron/systemd pentru programare
- Verificare integritate cu checksum-uri

---

## Cerințe Funcționale

### Obligatorii (pentru nota de trecere)

1. **Backup incremental**
   - Identificare fișiere modificate de la ultimul backup
   - Metodă bazată pe mtime sau checksum
   - Stocare eficientă doar a diferențelor

2. **Backup complet**
   - Snapshot periodic (configurabil: zilnic, săptămânal)
   - Arhivare completă a sursei
   - Bază pentru backup-urile incrementale ulterioare

3. **Compresie**
   - Suport pentru gzip, bzip2, xz
   - Nivel compresie configurabil
   - Estimare mărime înainte de backup

4. **Rotație automată**
   - Păstrare N backup-uri (configurabil)
   - Ștergere automată cele mai vechi
   - Politici: retenție zilnică, săptămânală, lunară

5. **Restaurare**
   - Restaurare completă din orice punct
   - Restaurare selectivă (fișiere/directoare individuale)
   - Restaurare în locație alternativă

6. **Programare**
   - Generare automată cron job
   - Suport pentru systemd timers
   - Verificare și listare programare existentă

7. **Logging**
   - Jurnal detaliat pentru fiecare operație
   - Statistici: fișiere procesate, mărimi, durată
   - Rotație log-uri

8. **Verificare integritate**
   - Checksum pentru fiecare arhivă
   - Verificare la restaurare
   - Raport corupție dacă există

### Opționale (pentru punctaj complet)

9. **Criptare** - GPG sau OpenSSL pentru backup-uri sensibile
10. **Backup remote** - transfer SCP/SFTP/rsync către destinație remotă
11. **Notificări** - Email sau webhook la succes/eșec
12. **Deduplicare** - Hard links pentru fișiere identice între backup-uri
13. **Excluderi** - Pattern-uri de ignorat (*.tmp, .cache, etc.)
14. **Limitare lățime bandă** - Pentru backup remote
15. **Dry-run** - Simulare fără realizare backup efectiv

---

## Interfață CLI

```bash
./backup.sh <command> [options]

Commands:
  full                    Full backup (snapshot)
  incremental             Incremental backup (changes only)
  restore <backup_id>     Restore from specified backup
  list                    List available backups
  verify <backup_id>      Verify backup integrity
  prune                   Clean backups according to policy
  schedule [on|off|show]  Manage scheduling
  status                  System status and statistics

General options:
  -s, --source DIR        Source directory (required for backup)
  -d, --dest DIR          Backup destination directory
  -c, --config FILE       Configuration file (default: ~/.backup.conf)
  -n, --name NAME         Backup set name
  -v, --verbose           Detailed output
  -q, --quiet             Errors only
  --dry-run               Simulation without actual action

Backup options:
  -z, --compress ALG      Algorithm: none|gzip|bzip2|xz (default: gzip)
  -l, --level N           Compression level 1-9 (default: 6)
  -e, --encrypt           Enable GPG encryption
  -x, --exclude PATTERN   Exclude files (can be repeated)
  --exclude-from FILE     File with exclusion patterns

Restore options:
  -o, --output DIR        Restore destination directory
  -f, --file PATH         Restore only specific file/directory
  --overwrite             Overwrite existing files

Rotation options:
  --keep-daily N          Keep N daily backups
  --keep-weekly N         Keep N weekly backups
  --keep-monthly N        Keep N monthly backups

Examples:
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
║                         SISTEM BACKUP v1.0                                   ║
║                         Backup Complet Început                               ║
╚══════════════════════════════════════════════════════════════════════════════╝

Configurație:
  Sursă:       /home/student/projects
  Destinație:  /backup/projects
  Nume backup: projects_full
  Compresie:   gzip (nivel 6)
  Criptare:    dezactivată

Scanare director sursă···
  Fișiere găsite:  2,456
  Directoare:      128
  Mărime totală:   1.2 GB
  Excluse:         45 fișiere (potrivire *.tmp, .cache/*)

Creare arhivă···
  [████████████████████████████████████████████████████████████] 100%

REZUMAT BACKUP
═══════════════════════════════════════════════════════════════════════════════
  ID Backup:       backup_20250120_153000_full
  Arhivă:          projects_full_20250120_153000.tar.gz
  Mărime originală: 1.2 GB
  Comprimat:       342 MB (raport compresie: 72%)
  Fișiere salvate: 2,411
  Durată:          2m 34s
  Checksum:        sha256:a1b2c3d4e5f6···

  Locație: /backup/projects/backup_20250120_153000_full/

✓ Backup completat cu succes
  Următorul incremental va folosi acesta ca bază
```

### Backup Incremental

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                         BACKUP INCREMENTAL                                   ║
║                         Bază: backup_20250120_153000_full                    ║
╚══════════════════════════════════════════════════════════════════════════════╝

Comparare cu backup bază···
  Fișiere scanate: 2,456
  Modificate:      45
  Noi:             12
  Șterse:          3
  Nemodificate:    2,396

Creare arhivă incrementală···
  [████████████████████████████████████████████████████████████] 100%

REZUMAT BACKUP
═══════════════════════════════════════════════════════════════════════════════
  ID Backup:       backup_20250121_030000_incr
  Tip:             Incremental
  Backup bază:     backup_20250120_153000_full
  Modificări:      57 fișiere (45 modificate, 12 noi)
  Mărime arhivă:   8.2 MB
  Durată:          12s

✓ Backup incremental completat
```

### Listare Backup-uri

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                         BACKUP-URI DISPONIBILE                               ║
║                         Set: projects                                        ║
╚══════════════════════════════════════════════════════════════════════════════╝

ID                              Tip     Dată                 Mărime    Status
─────────────────────────────────────────────────────────────────────────────────
backup_20250120_153000_full     FULL    2025-01-20 15:30    342 MB    ✓ verificat
backup_20250121_030000_incr     INCR    2025-01-21 03:00    8.2 MB    ✓ verificat
backup_20250122_030000_incr     INCR    2025-01-22 03:00    5.1 MB    ✓ verificat
backup_20250123_030000_incr     INCR    2025-01-23 03:00    12 MB     ✓ verificat
backup_20250124_030000_incr     INCR    2025-01-24 03:00    3.4 MB    ⚠ neverificat
backup_20250125_153000_full     FULL    2025-01-25 15:30    356 MB    ✓ verificat

Total: 6 backup-uri (2 complete, 4 incrementale)
Stocare folosită: 726.7 MB
Politică retenție: 7 zilnice, 4 săptămânale, 3 lunare

Comenzi:
  Restaurare ultimul: ./backup.sh restore backup_20250125_153000_full
  Verificare toate:   ./backup.sh verify --all
```

### Restaurare Selectivă

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                         RESTAURARE SELECTIVĂ                                 ║
║                         Din: backup_20250120_153000_full                     ║
╚══════════════════════════════════════════════════════════════════════════════╝

Căutare: etc/nginx/nginx.conf

Găsit în arhivă:
  Path:        etc/nginx/nginx.conf
  Mărime:      2.3 KB
  Modificat:   2025-01-20 14:25:00
  Mod:         644

Extragere în: /tmp/restore/etc/nginx/nginx.conf
  [████████████████████████████████████████████████████████████] 100%

✓ Fișier restaurat cu succes
  Locație: /tmp/restore/etc/nginx/nginx.conf
  Checksum verificat: ✓
```

---

## Fișier Configurație

```bash
# ~/.backup.conf - Backup System Configuration

# === General Settings ===
BACKUP_NAME="my_backup"
SOURCE_DIR="/home/user"
DEST_DIR="/backup"
LOG_FILE="/var/log/backup.log"

# === Compression ===
COMPRESSION="gzip"      # none, gzip, bzip2, xz
COMPRESSION_LEVEL=6     # 1-9

# === Encryption (optional) ===
ENCRYPTION_ENABLED=false
GPG_RECIPIENT="[adresă eliminată]"

# === Exclusions ===
EXCLUDE_PATTERNS=(
    "*.tmp"
    "*.swp"
    ".cache/*"
    "node_modules/*"
    ".git/objects/*"
    "*.log"
)

# === Rotation ===
KEEP_DAILY=7
KEEP_WEEKLY=4
KEEP_MONTHLY=3

# === Scheduling ===
SCHEDULE_FULL="0 3 * * 0"           # Sunday at 3:00
SCHEDULE_INCREMENTAL="0 3 * * 1-6"  # Monday-Saturday at 3:00

# === Notifications ===
NOTIFY_EMAIL=""
NOTIFY_ON_SUCCESS=false
NOTIFY_ON_FAILURE=true

# === Remote (optional) ===
REMOTE_ENABLED=false
REMOTE_HOST=""
REMOTE_PATH=""
REMOTE_USER=""
BANDWIDTH_LIMIT=""  # KB/s, empty = unlimited
```

---

## Structură Proiect

```
M01_Incremental_Backup_System/
├── README.md
├── Makefile
├── src/
│   ├── backup.sh                # Main script
│   └── lib/
│       ├── config.sh            # Configuration parsing
│       ├── archive.sh           # Tar archive creation
│       ├── compress.sh          # Compression functions
│       ├── encrypt.sh           # GPG encryption
│       ├── incremental.sh       # Incremental backup logic
│       ├── restore.sh           # Restore functions
│       ├── rotate.sh            # Rotation and cleanup
│       ├── schedule.sh          # Cron integration
│       ├── verify.sh            # Integrity verification
│       └── notify.sh            # Notifications
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

## Indicii de Implementare

### Detectare fișiere modificate (incremental)

```bash
#!/bin/bash
set -euo pipefail

find_modified_files() {
    local source_dir="$1"
    local reference_file="$2"  # Timestamp file from last backup
    local exclude_file="$3"
    
    local find_args=(-type f)
    
    # Add exclusions
    if [[ -f "$exclude_file" ]]; then
        while IFS= read -r pattern; do
            [[ -z "$pattern" || "$pattern" == \#* ]] && continue
            find_args+=(-not -path "*/$pattern")
        done < "$exclude_file"
    fi
    
    # Find files newer than reference
    if [[ -f "$reference_file" ]]; then
        find_args+=(-newer "$reference_file")
    fi
    
    find "$source_dir" "${find_args[@]}" 2>/dev/null
}

# Alternative: using rsync dry-run
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
    local file_list="$5"  # Optional: file list for incremental
    
    local tar_args=(--create --file=-)
    local compress_cmd
    local extension
    
    # Configure compression
    case "$compression" in
        gzip)  compress_cmd="gzip -${level}"; extension=".tar.gz" ;;
        bzip2) compress_cmd="bzip2 -${level}"; extension=".tar.bz2" ;;
        xz)    compress_cmd="xz -${level}"; extension=".tar.xz" ;;
        none)  compress_cmd="cat"; extension=".tar" ;;
        *)     echo "Unknown algorithm: $compression" >&2; return 1 ;;
    esac
    
    # Add file list or directory
    if [[ -n "$file_list" && -f "$file_list" ]]; then
        tar_args+=(--files-from="$file_list")
    else
        tar_args+=(-C "$(dirname "$source_dir")" "$(basename "$source_dir")")
    fi
    
    # Create archive
    tar "${tar_args[@]}" | $compress_cmd > "${archive_path}${extension}"
    
    # Generate checksum
    sha256sum "${archive_path}${extension}" > "${archive_path}${extension}.sha256"
    
    echo "${archive_path}${extension}"
}
```

### Politică rotație

```bash
apply_retention_policy() {
    local backup_dir="$1"
    local keep_daily="${2:-7}"
    local keep_weekly="${3:-4}"
    local keep_monthly="${4:-3}"
    
    local -a to_keep=()
    local -a all_backups=()
    
    # List all backups sorted descending
    mapfile -t all_backups < <(
        find "$backup_dir" -maxdepth 1 -type d -name "backup_*" | sort -r
    )
    
    local daily_count=0 weekly_count=0 monthly_count=0
    local last_week="" last_month=""
    
    for backup in "${all_backups[@]}"; do
        # Extract date from name: backup_YYYYMMDD_HHMMSS
        local date_part
        date_part=$(basename "$backup" | grep -oP '\d{8}')
        local week month
        week=$(date -d "$date_part" +%Y-%W)
        month=$(date -d "$date_part" +%Y-%m)
        
        local keep=false
        
        # Keep dailies
        if ((daily_count < keep_daily)); then
            keep=true
            ((daily_count++))
        fi
        
        # Keep weeklies (one per week)
        if [[ "$week" != "$last_week" ]] && ((weekly_count < keep_weekly)); then
            keep=true
            ((weekly_count++))
            last_week="$week"
        fi
        
        # Keep monthlies (one per month)
        if [[ "$month" != "$last_month" ]] && ((monthly_count < keep_monthly)); then
            keep=true
            ((monthly_count++))
            last_month="$month"
        fi
        
        if $keep; then
            to_keep+=("$backup")
        else
            echo "Deleting old backup: $backup"
            rm -rf "$backup"
        fi
    done
    
    echo "Kept ${#to_keep[@]} backups"
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
    
    [[ -f "$archive" ]] || { echo "Archive not found"; return 1; }
    
    # Verify integrity
    if [[ -f "${archive}.sha256" ]]; then
        echo "Verifying checksum···"
        sha256sum -c "${archive}.sha256" || {
            echo "Checksum verification failed!"
            return 1
        }
    fi
    
    # Determine decompression command
    local decompress_cmd
    case "$archive" in
        *.tar.gz)  decompress_cmd="gzip -d" ;;
        *.tar.bz2) decompress_cmd="bzip2 -d" ;;
        *.tar.xz)  decompress_cmd="xz -d" ;;
        *.tar)     decompress_cmd="cat" ;;
    esac
    
    mkdir -p "$output_dir"
    
    if [[ -n "$specific_file" ]]; then
        # Selective restore
        $decompress_cmd < "$archive" | tar -xf - -C "$output_dir" "$specific_file"
    else
        # Complete restore
        $decompress_cmd < "$archive" | tar -xf - -C "$output_dir"
    fi
    
    echo "Restored to: $output_dir"
}
```

---

## Criterii Specifice de Evaluare

| Criteriu | Pondere | Descriere |
|-----------|--------|-------------|
| Backup incremental | 20% | Detectare corectă modificări, eficiență |
| Backup complet | 10% | Arhivare corectă, snapshot funcțional |
| Compresie | 10% | Algoritmi multipli, nivel configurabil |
| Rotație | 15% | Politici zilnice/săptămânale/lunare |
| Restaurare | 15% | Completă și selectivă, verificare |
| Programare | 10% | Cron/systemd funcțional |
| Verificare integritate | 5% | Checksum-uri, validare |
| Logging | 5% | Jurnal complet, statistici |
| Calitate cod + teste | 5% | ShellCheck, modularitate |
| Documentație | 5% | README complet, exemple |

---

## Resurse

- `man tar`, `man gzip`, `man rsync`
- `man crontab`, `man systemd.timer`
- Seminar 3-4 - Arhivare, compresie
- Seminar 5 - Programare, automatizare

---

*Proiect MEDIUM | Sisteme de Operare | ASE-CSIE*
