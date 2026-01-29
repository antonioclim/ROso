# M12: File Integrity Monitor

> **Nivel:** MEDIUM | **Timp estimat:** 25-35 ore | **Bonus K8s:** +10%

---

## Descriere

Sistem de monitorizare a integrității fișierelor critice: detectare modificări (hash-based), alertare în timp real, audit trail complet și rapoarte de compliance. Similar cu AIDE sau Tripwire, dar implementat în Bash.

---

## Obiective de Învățare

- Funcții hash criptografice (MD5, SHA-256)
- Monitorizare filesystem events (inotify)
- Baseline management și comparație
- Audit logging și compliance
- Alertare și notificări

---

## Cerințe Funcționale

### Obligatorii (pentru notă de trecere)

1. **Baseline management**
   - Creare baseline (hash + metadata pentru fișiere)
   - Actualizare baseline selectivă
   - Stocare securizată a baseline-ului

2. **Verificare integritate**
   - Comparație hash curent vs baseline
   - Detectare: modificare, adăugare, ștergere
   - Verificare permisiuni și ownership

3. **Monitorizare real-time**
   - Watch mode cu inotify
   - Alertare imediată la modificare
   - Excludere pattern-uri (logs, temp)

4. **Raportare**
   - Raport diferențe detaliat
   - Audit trail cu timestamp
   - Export pentru compliance

5. **Configurare flexibilă**
   - Directoare/fișiere de monitorizat
   - Excluderi (glob patterns)
   - Algoritm hash selectabil

### Opționale (pentru punctaj complet)

6. **Verificare programată** - Cron integration cu rapoarte
7. **Rollback capability** - Restaurare din backup la modificare
8. **Extended attributes** - Verificare ACL, SELinux context
9. **Database backend** - SQLite pentru istoric
10. **Web dashboard** - Vizualizare status și istoric

---

## Interfață CLI

```bash
./fim.sh <command> [opțiuni]

Comenzi:
  init                  Inițializează configurare și baseline gol
  baseline              Creează/actualizează baseline
  check                 Verifică integritate față de baseline
  watch                 Monitorizare real-time (inotify)
  report [period]       Generează raport modificări
  history [file]        Afișează istoric modificări
  restore <file>        Restaurează fișier din backup (dacă există)
  status                Status sistem și ultimul check

Opțiuni:
  -c, --config FILE     Fișier configurare
  -d, --dir DIR         Director de monitorizat (poate fi repetat)
  -e, --exclude PATT    Pattern de exclus (poate fi repetat)
  -a, --algorithm ALG   Algoritm hash: md5|sha1|sha256|sha512
  -o, --output FILE     Salvează raport
  -f, --format FMT      Format: text|json|html
  -q, --quiet           Doar erori și warning-uri
  -v, --verbose         Output detaliat
  --deep                Include și extended attributes

Exemple:
  ./fim.sh init
  ./fim.sh baseline -d /etc -d /usr/bin --exclude "*.log"
  ./fim.sh check
  ./fim.sh watch -d /etc/ssh
  ./fim.sh report --format html -o report.html
```

---

## Exemple Output

### Baseline Creation

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    FILE INTEGRITY MONITOR - BASELINE                         ║
║                    Creating baseline...                                      ║
╚══════════════════════════════════════════════════════════════════════════════╝

Scanning directories...
  [1/3] /etc ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 100%
  [2/3] /usr/bin ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 100%
  [3/3] /usr/sbin ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 100%

BASELINE SUMMARY
═══════════════════════════════════════════════════════════════════════════════
  Total files:          4,521
  Total directories:    342
  Total size:           1.2 GB
  Hash algorithm:       SHA-256
  
  By directory:
    /etc                1,234 files (45 MB)
    /usr/bin            2,456 files (890 MB)
    /usr/sbin             831 files (265 MB)
  
  Excluded:
    *.log               23 files
    *.tmp               5 files
    /etc/mtab           1 file

Baseline saved: /var/lib/fim/baseline.db
Backup created: /var/lib/fim/baseline.db.20250120

✓ Baseline created successfully
  Next: Run './fim.sh check' to verify integrity
```

### Integrity Check

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    FILE INTEGRITY CHECK                                      ║
║                    Baseline: 2025-01-15 03:00:00                            ║
║                    Check time: 2025-01-20 17:30:00                          ║
╚══════════════════════════════════════════════════════════════════════════════╝

Checking 4,521 files...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 100%

INTEGRITY STATUS: ⚠️ CHANGES DETECTED
═══════════════════════════════════════════════════════════════════════════════

🔴 MODIFIED FILES (3)
───────────────────────────────────────────────────────────────────────────────

  /etc/passwd
  ├─ Hash changed:     a1b2c3d4... → e5f6g7h8...
  ├─ Modified:         2025-01-18 14:30:22
  ├─ Size:             2,456 → 2,512 bytes (+56)
  └─ Permissions:      unchanged (644)
  
  /etc/ssh/sshd_config
  ├─ Hash changed:     x9y8z7w6... → m3n4o5p6...
  ├─ Modified:         2025-01-19 09:15:00
  ├─ Size:             3,312 → 3,298 bytes (-14)
  └─ Permissions:      unchanged (600)
  
  /usr/bin/sudo
  ├─ Hash changed:     q1r2s3t4... → u5v6w7x8...
  ├─ Modified:         2025-01-17 02:30:00 (apt update)
  ├─ Size:             232,416 → 234,512 bytes
  └─ Permissions:      unchanged (4755)

🟡 NEW FILES (2)
───────────────────────────────────────────────────────────────────────────────

  /etc/cron.d/backup-job
  ├─ Created:          2025-01-16 10:00:00
  ├─ Size:             156 bytes
  ├─ Permissions:      644
  └─ Owner:            root:root
  
  /usr/local/bin/custom-script.sh
  ├─ Created:          2025-01-19 16:45:00
  ├─ Size:             2,048 bytes
  ├─ Permissions:      755
  └─ Owner:            admin:admin

🔵 DELETED FILES (1)
───────────────────────────────────────────────────────────────────────────────

  /etc/cron.d/old-backup (was in baseline, now missing)

⚪ PERMISSION CHANGES (1)
───────────────────────────────────────────────────────────────────────────────

  /etc/shadow
  └─ Permissions:      640 → 600 (more restrictive ✓)

═══════════════════════════════════════════════════════════════════════════════
SUMMARY
───────────────────────────────────────────────────────────────────────────────
  Files checked:       4,521
  Modified:            3 ⚠️
  New:                 2
  Deleted:             1
  Permission changes:  1
  Unchanged:           4,514 ✓

  Critical findings:   1 (sudo binary changed - verify if apt update)
  
Time: 12.3 seconds
Report saved: /var/log/fim/check_20250120_173000.log
```

### Watch Mode

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    FILE INTEGRITY MONITOR - WATCH MODE                       ║
║                    Monitoring: /etc, /usr/bin                               ║
║                    Press Ctrl+C to stop                                      ║
╚══════════════════════════════════════════════════════════════════════════════╝

[17:45:00] Starting inotify watches on 342 directories...
[17:45:01] Watch mode active. Waiting for events...

[17:45:23] 📝 MODIFY  /etc/hosts
           Hash: a1b2c3d4 → e5f6g7h8
           Action: Logged, notification sent

[17:46:05] ➕ CREATE  /etc/cron.d/new-job
           Size: 234 bytes, Owner: root
           Action: Logged

[17:48:12] 🔒 ATTRIB  /etc/shadow
           Permissions changed: 640 → 600
           Action: Logged

[17:52:30] ❌ DELETE  /tmp/test.conf
           Action: Ignored (excluded path)

───────────────────────────────────────────────────────────────────────────────
Events today: 12 (4 logged, 8 excluded)
Last event: 17:52:30
```

---

## Format Baseline (SQLite)

```sql
-- Schema pentru baseline
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
│   ├── fim.sh                   # Script principal
│   └── lib/
│       ├── baseline.sh          # Creare/update baseline
│       ├── check.sh             # Verificare integritate
│       ├── watch.sh             # Monitorizare inotify
│       ├── hash.sh              # Funcții hash
│       ├── report.sh            # Generare rapoarte
│       ├── notify.sh            # Notificări
│       └── db.sh                # Operații SQLite
├── etc/
│   ├── fim.conf                 # Configurare
│   └── excludes.conf            # Pattern-uri excluse
├── tests/
│   ├── test_hash.sh
│   ├── test_baseline.sh
│   └── test_files/
└── docs/
    ├── INSTALL.md
    └── COMPLIANCE.md
```

---

## Hints Implementare

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

# Calcul paralel pentru performanță
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
    
    # Inițializează DB
    sqlite3 "$db" < "$SCHEMA_FILE"
    
    # Pentru fiecare director configurat
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
    
    # Verifică fișierele din baseline
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
    
    # Verifică fișiere noi
    find_new_files "$db"
    
    return $((changes > 0 ? 1 : 0))
}
```

### Monitorizare cu inotify

```bash
watch_directories() {
    local dirs=("$@")
    
    # Verifică dacă inotifywait e disponibil
    command -v inotifywait &>/dev/null || {
        echo "Error: inotify-tools not installed"
        echo "Install with: apt install inotify-tools"
        return 1
    }
    
    # Construiește lista de directoare
    local watch_args=()
    for dir in "${dirs[@]}"; do
        watch_args+=(-r "$dir")
    done
    
    # Monitorizare
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

## Criterii Evaluare Specifice

| Criteriu | Pondere | Descriere |
|----------|---------|-----------|
| Baseline management | 20% | Creare, stocare, update |
| Verificare integritate | 25% | Hash compare, detectare toate tipurile |
| Watch mode | 15% | inotify funcțional |
| Raportare | 15% | Format clar, detalii, export |
| Configurare | 10% | Dirs, excludes, algorithm |
| Alertare | 5% | Notificări la modificare |
| Calitate cod + teste | 5% | ShellCheck, teste |
| Documentație | 5% | README, compliance info |

---

## Resurse

- `man inotifywait` - Monitorizare filesystem
- `man sha256sum` - Hash functions
- AIDE documentation (pentru inspirație)
- CIS Benchmarks - File integrity requirements

---

*Proiect MEDIUM | Sisteme de Operare | ASE-CSIE*
