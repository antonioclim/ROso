# M08: Disk Storage Manager

> **Nivel:** MEDIUM | **Timp estimat:** 25-35 ore | **Bonus K8s:** +10%

---

## Descriere

Manager inteligent pentru storage: monitorizare spațiu în timp real, cleanup automat (fișiere temporare, cache, logs vechi), sistem de quotas per user/director, alertare la threshold-uri și predicție când discul va fi plin.

---

## Obiective de Învățare

- Gestionare filesystem (`df`, `du`, `find`, `quota`)
- Automatizare cleanup și maintenance
- Predicție și trend analysis
- Implementare politici de retenție
- Alertare și notificări

---

## Cerințe Funcționale

### Obligatorii (pentru notă de trecere)

1. **Monitorizare spațiu**
   - Status per partiție (used/free/percentage)
   - Top directoare consumatoare
   - Trend utilizare (creștere zilnică/săptămânală)

2. **Cleanup automat**
   - Fișiere temporare (`/tmp`, `/var/tmp`)
   - Cache aplicații (browser, package manager)
   - Logs vechi (bazat pe politică de retenție)
   - Trash/Recycle bin

3. **Detectare fișiere problematice**
   - Fișiere mari (peste threshold)
   - Fișiere duplicate
   - Fișiere vechi neaccesate

4. **Alertare**
   - Notificare la utilizare peste threshold
   - Notificare la rată de creștere anormală
   - Email/desktop notifications

5. **Raportare**
   - Raport zilnic/săptămânal
   - Istoric utilizare
   - Export CSV

### Opționale (pentru punctaj complet)

6. **Quotas management** - Setare și monitorizare quotas
7. **Predictive alerts** - Predicție când discul va fi plin
8. **Deduplication** - Înlocuire duplicate cu hard links
9. **Compression** - Compresie fișiere vechi
10. **Web dashboard** - Vizualizare în browser

---

## Interfață CLI

```bash
./diskman.sh <command> [opțiuni]

Comenzi:
  status                Afișează status disc curent
  analyze [path]        Analizează utilizare director
  cleanup [profile]     Rulează cleanup (dry-run default)
  duplicates [path]     Găsește fișiere duplicate
  large [path]          Găsește fișiere mari
  old [path]            Găsește fișiere vechi
  report [period]       Generează raport utilizare
  alert                 Verifică și trimite alerte
  daemon                Pornește monitorizare continuă
  quota                 Gestionare quotas

Opțiuni:
  -t, --threshold PCT   Threshold alertă (default: 80%)
  -s, --size SIZE       Dimensiune minim fișiere mari (default: 100M)
  -d, --days N          Zile pentru fișiere vechi (default: 90)
  -p, --profile PROF    Profil cleanup: minimal|standard|aggressive
  -f, --force           Execută cleanup (nu doar dry-run)
  -o, --output FILE     Salvează raport
  -q, --quiet           Output minimal
  --no-color            Fără culori

Exemple:
  ./diskman.sh status
  ./diskman.sh analyze /home --size 50M
  ./diskman.sh cleanup standard --force
  ./diskman.sh duplicates /home/user -o dupes.txt
  ./diskman.sh daemon --threshold 85
```

---

## Exemple Output

### Status Dashboard

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    DISK STORAGE MANAGER                                      ║
║                    Host: server01 | Date: 2025-01-20                        ║
╚══════════════════════════════════════════════════════════════════════════════╝

PARTITION STATUS
═══════════════════════════════════════════════════════════════════════════════

/dev/sda1 mounted on /
┌──────────────────────────────────────────────────────────────────────────────┐
│ [████████████████████████████████████░░░░░░░░░░░░░░] 72% used               │
│ Used: 144 GB / 200 GB    Free: 56 GB    Inodes: 45% used                   │
│ Growth: +2.3 GB/week     Full in: ~24 weeks                                 │
└──────────────────────────────────────────────────────────────────────────────┘

/dev/sda2 mounted on /home
┌──────────────────────────────────────────────────────────────────────────────┐
│ [█████████████████████████████████████████████████░] 89% used  ⚠️ WARNING   │
│ Used: 445 GB / 500 GB    Free: 55 GB    Inodes: 23% used                   │
│ Growth: +8.1 GB/week     Full in: ~7 weeks  ⚠️                              │
└──────────────────────────────────────────────────────────────────────────────┘

/dev/sdb1 mounted on /data
┌──────────────────────────────────────────────────────────────────────────────┐
│ [█████████████████████████████████████████████████████████░░] 95% used 🔴   │
│ Used: 950 GB / 1 TB      Free: 50 GB     Inodes: 12% used                  │
│ Growth: +15 GB/week      Full in: ~3 weeks 🔴 CRITICAL                      │
└──────────────────────────────────────────────────────────────────────────────┘

TOP SPACE CONSUMERS (/home)
═══════════════════════════════════════════════════════════════════════════════
  1.  125 GB   /home/user1/Videos
  2.   89 GB   /home/user2/Downloads
  3.   67 GB   /home/user1/.cache
  4.   45 GB   /home/user3/Documents
  5.   34 GB   /home/user2/.local/share

CLEANUP RECOMMENDATIONS
═══════════════════════════════════════════════════════════════════════════════
  🗑️  Potential savings: 45.2 GB

  Category                Size      Files    Command
  ─────────────────────────────────────────────────────────────────────────────
  Package cache          12.3 GB    4,521    diskman.sh cleanup apt
  Logs > 30 days          8.7 GB      234    diskman.sh cleanup logs
  Trash                   6.2 GB    1,892    diskman.sh cleanup trash
  Browser cache           5.4 GB   12,456    diskman.sh cleanup browser
  Temp files              4.1 GB    3,211    diskman.sh cleanup temp
  Duplicate files         8.5 GB      156    diskman.sh duplicates --link

ALERTS
═══════════════════════════════════════════════════════════════════════════════
  🔴 /data at 95% - CRITICAL: Immediate action required
  ⚠️  /home at 89% - WARNING: Cleanup recommended
  ⚠️  /home will be full in 7 weeks at current growth rate
```

### Cleanup Report

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    CLEANUP REPORT - Standard Profile                         ║
║                    Date: 2025-01-20 16:00:00                                ║
╚══════════════════════════════════════════════════════════════════════════════╝

DRY RUN MODE - No files were deleted
Run with --force to execute cleanup

CLEANUP SUMMARY
═══════════════════════════════════════════════════════════════════════════════

Category              Files      Size        Status
─────────────────────────────────────────────────────────────────────────────
Temp files             3,211     4.1 GB      [WILL DELETE]
  /tmp/*                 892     1.2 GB
  /var/tmp/*             456     0.8 GB
  ~/.cache/tmp/*       1,863     2.1 GB

Log files > 30d          234     8.7 GB      [WILL DELETE]
  /var/log/*.gz          123     5.2 GB
  /var/log/journal/*      89     2.8 GB
  Application logs        22     0.7 GB

Package cache          4,521    12.3 GB      [WILL DELETE]
  apt cache            2,345     8.1 GB
  pip cache            1,234     3.2 GB
  npm cache              942     1.0 GB

Trash                  1,892     6.2 GB      [WILL DELETE]
  ~/.local/share/Trash 1,892     6.2 GB

─────────────────────────────────────────────────────────────────────────────
TOTAL                  9,858    31.3 GB

⚠️  The following will NOT be cleaned (excluded):
  - Files modified in last 24 hours
  - System logs for current month
  - Application state files

To execute: ./diskman.sh cleanup standard --force
```

---

## Fișier Configurare

```yaml
# /etc/diskman.conf
general:
  check_interval: 3600    # Secunde
  log_file: /var/log/diskman.log

thresholds:
  warning: 80
  critical: 90
  growth_alert: 10        # GB/week

alerts:
  email:
    enabled: true
    to: admin@example.com
  desktop:
    enabled: true

cleanup_profiles:
  minimal:
    - temp_files: 7d
    - trash: 30d
    
  standard:
    - temp_files: 1d
    - trash: 7d
    - logs: 30d
    - apt_cache: all
    - pip_cache: all
    
  aggressive:
    - temp_files: 0d
    - trash: 0d
    - logs: 7d
    - all_caches: all
    - thumbnails: all

paths:
  temp:
    - /tmp
    - /var/tmp
    - ~/.cache/tmp
  logs:
    - /var/log
  cache:
    apt: /var/cache/apt/archives
    pip: ~/.cache/pip
    npm: ~/.npm/_cacache
```

---

## Structură Proiect

```
M08_Disk_Storage_Manager/
├── README.md
├── Makefile
├── src/
│   ├── diskman.sh               # Script principal
│   └── lib/
│       ├── analyze.sh           # Analiză utilizare
│       ├── cleanup.sh           # Funcții cleanup
│       ├── duplicates.sh        # Detectare duplicate
│       ├── alerts.sh            # Sistem alertare
│       ├── predict.sh           # Predicție utilizare
│       ├── quota.sh             # Gestionare quotas
│       └── report.sh            # Generare rapoarte
├── etc/
│   ├── diskman.conf
│   └── profiles/
│       ├── minimal.conf
│       ├── standard.conf
│       └── aggressive.conf
├── tests/
│   ├── test_analyze.sh
│   ├── test_cleanup.sh
│   └── test_data/
└── docs/
    ├── INSTALL.md
    └── PROFILES.md
```

---

## Hints Implementare

### Analiză spațiu disc

```bash
get_partition_usage() {
    df -h --output=source,target,size,used,avail,pcent | tail -n +2
}

get_top_directories() {
    local path="${1:-.}"
    local count="${2:-10}"
    
    du -h --max-depth=1 "$path" 2>/dev/null | sort -rh | head -n "$count"
}

get_large_files() {
    local path="${1:-.}"
    local min_size="${2:-100M}"
    
    find "$path" -type f -size "+${min_size}" -exec ls -lh {} \; 2>/dev/null | \
        awk '{print $5, $9}' | sort -rh
}
```

### Cleanup funcții

```bash
cleanup_temp() {
    local days="${1:-1}"
    local dry_run="${2:-true}"
    
    local temp_dirs=(/tmp /var/tmp "$HOME/.cache/tmp")
    
    for dir in "${temp_dirs[@]}"; do
        [[ -d "$dir" ]] || continue
        
        if [[ "$dry_run" == "true" ]]; then
            find "$dir" -type f -atime "+$days" -exec ls -lh {} \;
        else
            find "$dir" -type f -atime "+$days" -delete
        fi
    done
}

cleanup_logs() {
    local days="${1:-30}"
    local dry_run="${2:-true}"
    
    # Compressed logs
    if [[ "$dry_run" == "true" ]]; then
        find /var/log -name "*.gz" -mtime "+$days" -ls
    else
        find /var/log -name "*.gz" -mtime "+$days" -delete
    fi
    
    # Journald (păstrează ultimele N zile)
    if [[ "$dry_run" != "true" ]]; then
        sudo journalctl --vacuum-time="${days}d"
    fi
}

cleanup_package_cache() {
    local dry_run="${1:-true}"
    
    if [[ "$dry_run" == "true" ]]; then
        echo "APT cache: $(du -sh /var/cache/apt/archives 2>/dev/null | cut -f1)"
    else
        sudo apt-get clean
    fi
    
    # pip cache
    if command -v pip &>/dev/null; then
        if [[ "$dry_run" != "true" ]]; then
            pip cache purge
        fi
    fi
}
```

### Găsire duplicate

```bash
find_duplicates() {
    local path="${1:-.}"
    local min_size="${2:-1M}"
    
    # Grupează fișiere după dimensiune, apoi verifică hash
    find "$path" -type f -size "+$min_size" -printf "%s %p\n" 2>/dev/null | \
        sort -n | \
        awk '{
            if ($1 == prev_size) {
                print prev_path
                print $2
            }
            prev_size = $1
            prev_path = $2
        }' | \
        xargs -I {} md5sum {} 2>/dev/null | \
        sort | \
        awk '{
            if ($1 == prev_hash) {
                print prev_path
                print $2
                dupes++
            }
            prev_hash = $1
            prev_path = $2
        }'
}

# Replace duplicates with hard links
deduplicate() {
    local file1="$1"
    local file2="$2"
    
    # Verifică că sunt pe același filesystem
    local dev1 dev2
    dev1=$(stat -c '%d' "$file1")
    dev2=$(stat -c '%d' "$file2")
    
    if [[ "$dev1" != "$dev2" ]]; then
        echo "Files on different filesystems, cannot hard link"
        return 1
    fi
    
    # Creează hard link
    rm "$file2"
    ln "$file1" "$file2"
}
```

### Predicție utilizare

```bash
predict_full_date() {
    local partition="$1"
    local db="$DISKMAN_DB"
    
    # Obține datele din ultimele 30 zile
    local data
    data=$(sqlite3 "$db" "
        SELECT date, used_bytes 
        FROM disk_usage 
        WHERE partition='$partition' 
        AND date > date('now', '-30 days')
        ORDER BY date
    ")
    
    # Calculează rata de creștere (simplificat: linear regression)
    # În practică, folosește un script Python pentru calcul mai precis
    
    local growth_per_day
    growth_per_day=$(echo "$data" | awk -F'|' '
        NR==1 {first=$2; first_day=NR}
        END {
            diff = $2 - first
            days = NR - first_day
            if (days > 0) print diff / days
        }
    ')
    
    local free_bytes
    free_bytes=$(df --output=avail "$partition" | tail -1)
    
    local days_until_full
    days_until_full=$(echo "scale=0; $free_bytes / $growth_per_day" | bc)
    
    echo "$days_until_full"
}
```

---

## Criterii Evaluare Specifice

| Criteriu | Pondere | Descriere |
|----------|---------|-----------|
| Monitorizare spațiu | 15% | Status corect, top consumers |
| Cleanup funcțional | 25% | Temp, logs, cache - cu dry-run |
| Detectare probleme | 15% | Large files, duplicates, old files |
| Alertare | 15% | Threshold, email/desktop |
| Predicție | 10% | Trend, estimare full date |
| Funcționalități extra | 10% | Quotas, dedup, compression |
| Calitate cod + teste | 5% | ShellCheck, teste |
| Documentație | 5% | README, profiles doc |

---

## Resurse

- `man df`, `man du`, `man find`
- `man quota`, `man edquota`
- Seminar 2-3 - Comenzi find, procesare text

---

*Proiect MEDIUM | Sisteme de Operare | ASE-CSIE*
