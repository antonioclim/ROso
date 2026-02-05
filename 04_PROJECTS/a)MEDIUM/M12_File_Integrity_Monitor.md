# M12: Monitor Integritate Fișiere

> **Nivel:** MEDIUM | **Timp estimat:** 25-35 ore | **Bonus K8s:** +10%

---

## Descriere

Sistem critic monitorizare integritate fișiere: detectare modificări bazată pe hash, alertare timp real, trail audit complet și rapoarte conformitate. Similar cu AIDE sau Tripwire, dar implementat în Bash.

---

## Obiective de Învățare

- Funcții hash criptografice (MD5, SHA-256)
- Monitorizare evenimente filesystem (inotify)
- Gestionare baseline și comparație
- Logging audit și conformitate
- Alertare și notificări

---

## Cerințe Funcționale

### Obligatorii (pentru nota de trecere)

1. **Gestionare baseline**
   - Creare baseline (hash + metadata pentru fișiere)
   - Actualizare selectivă baseline
   - Stocare securizată baseline

2. **Verificare integritate**
   - Comparație hash curent vs baseline
   - Detectare: modificare, adăugare, ștergere
   - Verificare permisiuni și ownership

3. **Monitorizare timp real**
   - Mod watch cu inotify
   - Alertă imediată la modificare
   - Excludere pattern-uri (log-uri, temp)

4. **Raportare**
   - Raport detaliat diferențe
   - Trail audit cu timestamp
   - Export pentru conformitate

5. **Configurare flexibilă**
   - Directoare/fișiere de monitorizat
   - Excluderi (pattern-uri glob)
   - Algorithm hash selectabil

### Opționale (pentru punctaj complet)

6. **Verificare programată** - Integrare cron cu rapoarte
7. **Capabilitate rollback** - Restaurare din backup la modificare
8. **Atribute extinse** - Verificare ACL, context SELinux
9. **Backend bază date** - SQLite pentru istoric
10. **Dashboard web** - Vizualizare status și istoric

---

## Interfață CLI

```bash
./fim.sh <command> [options]

Commands:
  init                  Initialise configuration and empty baseline
  baseline              Create/update baseline
  check                 Verify integrity against baseline
  watch                 Real-time monitoring (inotify)
  report [period]       Generate modification report
  history [file]        Display modification history
  restore <file>        Restore file from backup (if available)
  status                System status and last check

Options:
  -c, --config FILE     Configuration file
  -d, --dir DIR         Directory to monitor (can be repeated)
  -e, --exclude PATT    Pattern to exclude (can be repeated)
  -a, --algorithm ALG   Hash algorithm: md5|sha1|sha256|sha512
  -o, --output FILE     Save report
  -f, --format FMT      Format: text|json|html
  -q, --quiet           Errors and warnings only
  -v, --verbose         Detailed output
  --deep                Include extended attributes

Examples:
  ./fim.sh init
  ./fim.sh baseline -d /etc -d /usr/bin --exclude "*.log"
  ./fim.sh check
  ./fim.sh watch -d /etc/ssh
  ./fim.sh report --format html -o report.html
```

---

## Exemple Output

### Creare Baseline

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    MONITOR INTEGRITATE FIȘIERE - BASELINE                    ║
║                    Creare baseline···                                        ║
╚══════════════════════════════════════════════════════════════════════════════╝

Scanare directoare···
  [1/3] /etc ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 100%
  [2/3] /usr/bin ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 100%
  [3/3] /usr/sbin ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 100%

REZUMAT BASELINE
═══════════════════════════════════════════════════════════════════════════════
  Total fișiere:        4,521
  Total directoare:     342
  Mărime totală:        1.2 GB
  Algorithm hash:       SHA-256
  
  Pe director:
    /etc                1,234 fișiere (45 MB)
    /usr/bin            2,456 fișiere (890 MB)
    /usr/sbin             831 fișiere (265 MB)
  
  Excluse:
    *.log               23 fișiere
    *.tmp               5 fișiere
    /etc/mtab           1 fișier

Baseline salvat: /var/lib/fim/baseline.db
Backup creat: /var/lib/fim/baseline.db.20250120

✓ Baseline creat cu succes
  Următorul: Rulează './fim.sh check' pentru verificare integritate
```

### Verificare Integritate

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    VERIFICARE INTEGRITATE FIȘIERE                            ║
║                    Baseline: 2025-01-15 03:00:00                            ║
║                    Timp verificare: 2025-01-20 17:30:00                     ║
╚══════════════════════════════════════════════════════════════════════════════╝

Verificare 4,521 fișiere···
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 100%

STATUS INTEGRITATE: ⚠️ MODIFICĂRI DETECTATE
═══════════════════════════════════════════════════════════════════════════════

🔴 FIȘIERE MODIFICATE (3)
───────────────────────────────────────────────────────────────────────────────

  /etc/passwd
  ├─ Hash schimbat:    a1b2c3d4··· → e5f6g7h8···
  ├─ Modificat:        2025-01-18 14:30:22
  ├─ Mărime:           2,456 → 2,512 bytes (+56)
  └─ Permisiuni:       neschimbate (644)
  
  /etc/ssh/sshd_config
  ├─ Hash schimbat:    x9y8z7w6··· → m3n4o5p6···
  ├─ Modificat:        2025-01-19 09:15:00
  ├─ Mărime:           3,312 → 3,298 bytes (-14)
  └─ Permisiuni:       neschimbate (600)
  
  /usr/bin/sudo
  ├─ Hash schimbat:    q1r2s3t4··· → u5v6w7x8···
  ├─ Modificat:        2025-01-17 02:30:00 (apt update)
  ├─ Mărime:           232,416 → 234,512 bytes
  └─ Permisiuni:       neschimbate (4755)

🟡 FIȘIERE NOI (2)
───────────────────────────────────────────────────────────────────────────────

  /etc/cron.d/backup-job
  ├─ Creat:            2025-01-16 10:00:00
  ├─ Mărime:           156 bytes
  ├─ Permisiuni:       644
  └─ Proprietar:       root:root
  
  /usr/local/bin/custom-script.sh
  ├─ Creat:            2025-01-19 16:45:00
  ├─ Mărime:           2,048 bytes
  ├─ Permisiuni:       755
  └─ Proprietar:       admin:admin

🔵 FIȘIERE ȘTERSE (1)
───────────────────────────────────────────────────────────────────────────────

  /etc/cron.d/old-backup (era în baseline, acum lipsește)

⚪ MODIFICĂRI PERMISIUNI (1)
───────────────────────────────────────────────────────────────────────────────

  /etc/shadow
  └─ Permisiuni:       640 → 600 (mai restrictive ✓)

═══════════════════════════════════════════════════════════════════════════════
REZUMAT
───────────────────────────────────────────────────────────────────────────────
  Fișiere verificate:  4,521
  Modificate:          3 ⚠️
  Noi:                 2
  Șterse:              1
  Modificări permis:   1
  Neschimbate:         4,514 ✓

  Descoperiri critice: 1 (binar sudo modificat - verifică dacă apt update)
  
Timp: 12.3 secunde
Raport salvat: /var/log/fim/check_20250120_173000.log
```

### Mod Watch

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    MONITOR INTEGRITATE FIȘIERE - MOD WATCH                   ║
║                    Monitorizare: /etc, /usr/bin                             ║
║                    Apasă Ctrl+C pentru oprire                                ║
╚══════════════════════════════════════════════════════════════════════════════╝

[17:45:00] Pornire watch-uri inotify pe 342 directoare···
[17:45:01] Mod watch activ. Așteptare evenimente···

[17:45:23] 📝 MODIFY  /etc/hosts
           Hash: a1b2c3d4 → e5f6g7h8
           Acțiune: Logat, notificare trimisă

[17:46:05] ➕ CREATE  /etc/cron.d/new-job
           Mărime: 234 bytes, Proprietar: root
           Acțiune: Logat

[17:48:12] 🔒 ATTRIB  /etc/shadow
           Permisiuni schimbate: 640 → 600
           Acțiune: Logat

[17:52:30] ❌ DELETE  /tmp/test.conf
           Acțiune: Ignorat (cale exclusă)

───────────────────────────────────────────────────────────────────────────────
Evenimente astăzi: 12 (4 logate, 8 excluse)
Ultimul eveniment: 17:52:30
```

---

## Format Baseline (SQLite)

```sql
-- Schema for baseline
CREATE TABLE files (
    id INTEGER PRIMARY KEY,
    path TEXT UNIQUE NOT NULL,
    hash TEXT NOT NULL,
    size INTEGER,
    mtime INTEGER,
    permissions TEXT,
    uid INTEGER,
    gid INTEGER,
    type TEXT,  -- file, directory, symlink
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE changes (
    id INTEGER PRIMARY KEY,
    path TEXT NOT NULL,
    change_type TEXT,  -- modified, added, deleted, permission
    old_hash TEXT,
    new_hash TEXT,
    old_value TEXT,
    new_value TEXT,
    detected_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_files_path ON files(path);
CREATE INDEX idx_changes_path ON changes(path);
```

---

## Structură Proiect

```
M12_File_Integrity_Monitor/
├── README.md
├── Makefile
├── src/
│   ├── fim.sh                   # Main script
│   └── lib/
│       ├── baseline.sh          # Create/update baseline
│       ├── check.sh             # Integrity verification
│       ├── watch.sh             # inotify monitoring
│       ├── hash.sh              # Hash functions
│       ├── report.sh            # Report generation
│       ├── notify.sh            # Notifications
│       └── db.sh                # SQLite operations
├── etc/
│   ├── fim.conf                 # Configuration
│   └── excludes.conf            # Excluded patterns
├── tests/
│   ├── test_hash.sh
│   ├── test_baseline.sh
│   └── test_files/
└── docs/
    ├── INSTALL.md
    └── COMPLIANCE.md
```

---

## Indicii de Implementare

### Calcul hash fișier

```bash
compute_hash() {
    local file="$1"
    local algorithm="${2:-sha256}"
    
    case "$algorithm" in
        md5)    md5sum "$file" | cut -d' ' -f1 ;;
        sha1)   sha1sum "$file" | cut -d' ' -f1 ;;
        sha256) sha256sum "$file" | cut -d' ' -f1 ;;
        sha512) sha512sum "$file" | cut -d' ' -f1 ;;
        *)      echo "Unknown algorithm: $algorithm" >&2; return 1 ;;
    esac
}

# Parallel calculation for performance
compute_hashes_parallel() {
    local dir="$1"
    local algorithm="${2:-sha256}"
    
    find "$dir" -type f -print0 | \
        xargs -0 -P 4 -I {} "${algorithm}sum" {} 2>/dev/null
}
```

### Creare baseline

```bash
create_baseline() {
    local config="$1"
    local db="$BASELINE_DB"
    
    # Initialise DB
    sqlite3 "$db" < "$SCHEMA_FILE"
    
    # For each configured directory
    while IFS= read -r dir; do
        find "$dir" -type f | while read -r file; do
            # Skip excluded
            if is_excluded "$file"; then
                continue
            fi
            
            local hash size mtime perms uid gid
            hash=$(compute_hash "$file")
            size=$(stat -c %s "$file")
            mtime=$(stat -c %Y "$file")
            perms=$(stat -c %a "$file")
            uid=$(stat -c %u "$file")
            gid=$(stat -c %g "$file")
            
            sqlite3 "$db" "INSERT INTO files (path, hash, size, mtime, permissions, uid, gid, type) 
                          VALUES ('$file', '$hash', $size, $mtime, '$perms', $uid, $gid, 'file');"
        done
    done < <(get_monitored_dirs "$config")
}
```

### Verificare integritate

```bash
check_integrity() {
    local db="$BASELINE_DB"
    local changes=0
    
    # Check files from baseline
    sqlite3 "$db" "SELECT path, hash, size, permissions FROM files" | \
    while IFS='|' read -r path old_hash old_size old_perms; do
        if [[ ! -e "$path" ]]; then
            report_change "deleted" "$path"
            ((changes++))
            continue
        fi
        
        local new_hash new_size new_perms
        new_hash=$(compute_hash "$path")
        new_size=$(stat -c %s "$path")
        new_perms=$(stat -c %a "$path")
        
        if [[ "$new_hash" != "$old_hash" ]]; then
            report_change "modified" "$path" "$old_hash" "$new_hash"
            ((changes++))
        fi
        
        if [[ "$new_perms" != "$old_perms" ]]; then
            report_change "permission" "$path" "$old_perms" "$new_perms"
            ((changes++))
        fi
    done
    
    # Check for new files
    find_new_files "$db"
    
    return $((changes > 0 ? 1 : 0))
}
```

### Monitorizare cu inotify

```bash
watch_directories() {
    local dirs=("$@")
    
    # Check if inotifywait is available
    command -v inotifywait &>/dev/null || {
        echo "Error: inotify-tools not installed"
        echo "Install with: apt install inotify-tools"
        return 1
    }
    
    # Build directory list
    local watch_args=()
    for dir in "${dirs[@]}"; do
        watch_args+=(-r "$dir")
    done
    
    # Monitoring
    inotifywait -m -e modify,create,delete,attrib \
        --format '%T %w%f %e' --timefmt '%Y-%m-%d %H:%M:%S' \
        "${watch_args[@]}" 2>/dev/null | \
    while read -r timestamp path event; do
        # Skip excluded
        if is_excluded "$path"; then
            log_debug "Excluded: $path"
            continue
        fi
        
        log_event "$timestamp" "$path" "$event"
        
        case "$event" in
            MODIFY)
                local old_hash new_hash
                old_hash=$(get_baseline_hash "$path")
                new_hash=$(compute_hash "$path")
                if [[ "$old_hash" != "$new_hash" ]]; then
                    alert "File modified: $path"
                fi
                ;;
            CREATE)
                alert "New file: $path"
                ;;
            DELETE)
                alert "File deleted: $path"
                ;;
            ATTRIB)
                alert "Attributes changed: $path"
                ;;
        esac
    done
}
```

---

## Criterii Specifice de Evaluare

| Criteriu | Pondere | Descriere |
|-----------|--------|-------------|
| Gestionare baseline | 20% | Creare, stocare, actualizare |
| Verificare integritate | 25% | Comparare hash, detectare toate tipurile |
| Mod watch | 15% | inotify funcțional |
| Raportare | 15% | Format clar, detalii, export |
| Configurare | 10% | Directoare, excluderi, algorithm |
| Alertare | 5% | Notificări la modificare |
| Calitate cod + teste | 5% | ShellCheck, teste |
| Documentație | 5% | README, info conformitate |

---

## Resurse

- `man inotifywait` - Monitorizare filesystem
- `man sha256sum` - Funcții hash
- Documentație AIDE (pentru inspirație)
- CIS Benchmarks - Cerințe integritate fișiere

---

*Proiect MEDIUM | Sisteme de Operare | ASE-CSIE*
