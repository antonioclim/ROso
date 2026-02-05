# M08: Manager Stocare Disc

> **Nivel:** MEDIUM | **Timp estimat:** 25-35 ore | **Bonus K8s:** +10%

---

## Descriere

Manager inteligent stocare: monitorizare spațiu în timp real, curățare automată (fișiere temporare, cache, log-uri vechi), sistem cote per utilizator/director, alertare prag și predicție când discul va fi plin.

---

## Obiective de Învățare

- Gestionare filesystem (`df`, `du`, `find`, `quota`)
- Automatizare curățare și mentenanță
- Predicție și analiză tendințe
- Implementare politici retenție
- Alertare și notificări

---

## Cerințe Funcționale

### Obligatorii (pentru nota de trecere)

1. **Monitorizare spațiu**
   - Status per partiție (folosit/liber/procent)
   - Top directoare consumatoare
   - Tendință utilizare (creștere zilnică/săptămânală)

2. **Curățare automată**
   - Fișiere temporare (`/tmp`, `/var/tmp`)
   - Cache aplicații (browser, package manager)
   - Log-uri vechi (bazat pe politică retenție)
   - Trash/Recycle bin

3. **Detectare fișiere problematice**
   - Fișiere mari (peste prag)
   - Fișiere duplicate
   - Fișiere vechi neaccesate

4. **Alertare**
   - Notificare când utilizarea depășește prag
   - Notificare la rată creștere anormală
   - Notificări email/desktop

5. **Raportare**
   - Raport zilnic/săptămânal
   - Istoric utilizare
   - Export CSV

### Opționale (pentru punctaj complet)

6. **Gestionare cote** - Setare și monitorizare cote
7. **Alerte predictive** - Predicție când discul va fi plin
8. **Deduplicare** - Înlocuire duplicate cu hard links
9. **Compresie** - Comprimare fișiere vechi
10. **Dashboard web** - Vizualizare în browser

---

## Interfață CLI

```bash
./diskman.sh <command> [options]

Commands:
  status                Display current disk status
  analyze [path]        Analyse directory usage
  cleanup [profile]     Run cleanup (dry-run default)
  duplicates [path]     Find duplicate files
  large [path]          Find large files
  old [path]            Find old files
  report [period]       Generate usage report
  alert                 Check and send alerts
  daemon                Start continuous monitoring
  quota                 Quota management

Options:
  -t, --threshold PCT   Alert threshold (default: 80%)
  -s, --size SIZE       Minimum size for large files (default: 100M)
  -d, --days N          Days for old files (default: 90)
  -p, --profile PROF    Cleanup profile: minimal|standard|aggressive
  -f, --force           Execute cleanup (not just dry-run)
  -o, --output FILE     Save report
  -q, --quiet           Minimal output
  --no-color            No colours

Examples:
  ./diskman.sh status
  ./diskman.sh analyze /home --size 50M
  ./diskman.sh cleanup standard --force
  ./diskman.sh duplicates /home/user -o dupes.txt
  ./diskman.sh daemon --threshold 85
```

---

## Exemple Output

### Dashboard Status

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    MANAGER STOCARE DISC                                      ║
║                    Host: server01 | Dată: 2025-01-20                        ║
╚══════════════════════════════════════════════════════════════════════════════╝

STATUS PARTIȚII
═══════════════════════════════════════════════════════════════════════════════

/dev/sda1 montat pe /
┌──────────────────────────────────────────────────────────────────────────────┐
│ [████████████████████████████████████░░░░░░░░░░░░░░] 72% folosit            │
│ Folosit: 144 GB / 200 GB    Liber: 56 GB    Inode-uri: 45% folosite        │
│ Creștere: +2.3 GB/săptămână     Plin în: ~24 săptămâni                      │
└──────────────────────────────────────────────────────────────────────────────┘

/dev/sda2 montat pe /home
┌──────────────────────────────────────────────────────────────────────────────┐
│ [█████████████████████████████████████████████████░] 89% folosit  ⚠️ WARNING│
│ Folosit: 445 GB / 500 GB    Liber: 55 GB    Inode-uri: 23% folosite        │
│ Creștere: +8.1 GB/săptămână     Plin în: ~7 săptămâni  ⚠️                   │
└──────────────────────────────────────────────────────────────────────────────┘

/dev/sdb1 montat pe /data
┌──────────────────────────────────────────────────────────────────────────────┐
│ [█████████████████████████████████████████████████████████░░] 95% folosit 🔴│
│ Folosit: 950 GB / 1 TB      Liber: 50 GB     Inode-uri: 12% folosite       │
│ Creștere: +15 GB/săptămână      Plin în: ~3 săptămâni 🔴 CRITICAL           │
└──────────────────────────────────────────────────────────────────────────────┘

TOP CONSUMATORI SPAȚIU (/home)
═══════════════════════════════════════════════════════════════════════════════
  1.  125 GB   /home/user1/Videos
  2.   89 GB   /home/user2/Downloads
  3.   67 GB   /home/user1/.cache
  4.   45 GB   /home/user3/Documents
  5.   34 GB   /home/user2/.local/share

RECOMANDĂRI CURĂȚARE
═══════════════════════════════════════════════════════════════════════════════
  🗑️  Economii potențiale: 45.2 GB

  Categorie              Mărime    Fișiere  Comandă
  ─────────────────────────────────────────────────────────────────────────────
  Cache pachete          12.3 GB    4,521    diskman.sh cleanup apt
  Log-uri > 30 zile       8.7 GB      234    diskman.sh cleanup logs
  Trash                   6.2 GB    1,892    diskman.sh cleanup trash
  Cache browser           5.4 GB   12,456    diskman.sh cleanup browser
  Fișiere temp            4.1 GB    3,211    diskman.sh cleanup temp
  Fișiere duplicate       8.5 GB      156    diskman.sh duplicates --link

ALERTE
═══════════════════════════════════════════════════════════════════════════════
  🔴 /data la 95% - CRITICAL: Acțiune imediată necesară
  ⚠️  /home la 89% - WARNING: Curățare recomandată
  ⚠️  /home va fi plin în 7 săptămâni la rata curentă de creștere
```

### Raport Curățare

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    RAPORT CURĂȚARE - Profil Standard                         ║
║                    Dată: 2025-01-20 16:00:00                                ║
╚══════════════════════════════════════════════════════════════════════════════╝

MOD DRY RUN - Niciun fișier nu a fost șters
Rulează cu --force pentru executare curățare

REZUMAT CURĂȚARE
═══════════════════════════════════════════════════════════════════════════════

Categorie              Fișiere    Mărime      Status
─────────────────────────────────────────────────────────────────────────────
Fișiere temp             3,211     4.1 GB      [VA ȘTERGE]
  /tmp/*                   892     1.2 GB
  /var/tmp/*               456     0.8 GB
  ~/.cache/tmp/*         1,863     2.1 GB

Log-uri > 30z              234     8.7 GB      [VA ȘTERGE]
  /var/log/*.gz            123     5.2 GB
  /var/log/journal/*        89     2.8 GB
  Log-uri aplicații         22     0.7 GB

Cache pachete            4,521    12.3 GB      [VA ȘTERGE]
  cache apt              2,345     8.1 GB
  cache pip              1,234     3.2 GB
  cache npm                942     1.0 GB

Trash                    1,892     6.2 GB      [VA ȘTERGE]
  ~/.local/share/Trash   1,892     6.2 GB

─────────────────────────────────────────────────────────────────────────────
TOTAL                    9,858    31.3 GB

⚠️  Următoarele NU vor fi curățate (excluse):
  - Fișiere modificate în ultimele 24 ore
  - Log-uri sistem pentru luna curentă
  - Fișiere stare aplicații

Pentru executare: ./diskman.sh cleanup standard --force
```

---

## Fișier Configurație

```yaml
# /etc/diskman.conf
general:
  check_interval: 3600    # Seconds
  log_file: /var/log/diskman.log

thresholds:
  warning: 80
  critical: 90
  growth_alert: 10        # GB/week

alerts:
  email:
    enabled: true
    to: [adresă eliminată]
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
│   ├── diskman.sh               # Main script
│   └── lib/
│       ├── analyze.sh           # Usage analysis
│       ├── cleanup.sh           # Cleanup functions
│       ├── duplicates.sh        # Duplicate detection
│       ├── alerts.sh            # Alerting system
│       ├── predict.sh           # Usage prediction
│       ├── quota.sh             # Quota management
│       └── report.sh            # Report generation
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

## Indicii de Implementare

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

### Funcții curățare

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
    
    # Journald (keep last N days)
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
    
    # Group files by size, then verify hash
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
    
    # Verify they are on the same filesystem
    local dev1 dev2
    dev1=$(stat -c '%d' "$file1")
    dev2=$(stat -c '%d' "$file2")
    
    if [[ "$dev1" != "$dev2" ]]; then
        echo "Files on different filesystems, cannot hard link"
        return 1
    fi
    
    # Create hard link
    rm "$file2"
    ln "$file1" "$file2"
}
```

### Predicție utilizare

```bash
predict_full_date() {
    local partition="$1"
    local db="$DISKMAN_DB"
    
    # Get data from last 30 days
    local data
    data=$(sqlite3 "$db" "
        SELECT date, used_bytes 
        FROM disk_usage 
        WHERE partition='$partition' 
        AND date > date('now', '-30 days')
        ORDER BY date
    ")
    
    # Calculate growth rate (simplified: linear regression)
    # In practice, use a Python script for more accurate calculation
    
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

## Criterii Specifice de Evaluare

| Criteriu | Pondere | Descriere |
|-----------|--------|-------------|
| Monitorizare spațiu | 15% | Status corect, top consumatori |
| Curățare funcțională | 25% | Temp, log-uri, cache - cu dry-run |
| Detectare probleme | 15% | Fișiere mari, duplicate, vechi |
| Alertare | 15% | Prag, email/desktop |
| Predicție | 10% | Tendință, estimare dată plin |
| Funcționalități extra | 10% | Cote, dedup, compresie |
| Calitate cod + teste | 5% | ShellCheck, teste |
| Documentație | 5% | README, doc profile |

---

## Resurse

- `man df`, `man du`, `man find`
- `man quota`, `man edquota`
- Seminar 2-3 - comenzi find, procesare text

---

*Proiect MEDIUM | Sisteme de Operare | ASE-CSIE*
