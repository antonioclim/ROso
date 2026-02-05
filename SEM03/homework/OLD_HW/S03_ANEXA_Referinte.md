# S03_ANEXA - Referințe Seminar 3 (Redistribuit)

> **Sisteme de Operare** | ASE București - CSIE  
> Material suplimentar

---


## Diagrame ASCII Suplimentare


### Permisiuni Speciale

```
┌──────────────────────────────────────────────────────────────────────┐
│                    PERMISIUNI SPECIALE                               │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  SUID (Set User ID) - Bit 4xxx                              │    │
│  │                                                              │    │
│  │  -rwsr-xr-x  (s în loc de x pentru owner)                   │    │
│  │                                                              │    │
│  │  • Procesul rulează cu UID-ul owner-ului fișierului         │    │
│  │  • Folosit pentru: passwd, ping, sudo                       │    │
│  │                                                              │    │
│  │  Exemplu:                                                    │    │
│  │  $ ls -l /usr/bin/passwd                                    │    │
│  │  -rwsr-xr-x 1 root root ... /usr/bin/passwd                 │    │
│  │        ^                                                     │    │
│  │  Orice user poate schimba parola (necesită scriere în       │    │
│  │  /etc/shadow care e owned de root)                          │    │
│  │                                                              │    │
│  │  chmod u+s file    sau    chmod 4755 file                   │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  SGID (Set Group ID) - Bit 2xxx                             │    │
│  │                                                              │    │
│  │  Pe fișiere: -rwxr-sr-x (s în loc de x pentru group)        │    │
│  │  Pe directoare: drwxr-sr-x                                  │    │
│  │                                                              │    │
│  │  Pe fișiere:                                                 │    │
│  │  • Procesul rulează cu GID-ul grupului fișierului           │    │
│  │                                                              │    │
│  │  Pe directoare (mai comun):                                  │    │
│  │  • Fișierele noi moștenesc grupul directorului              │    │
│  │  • Util pentru directoare de proiect shared                 │    │
│  │                                                              │    │
│  │  Exemplu:                                                    │    │
│  │  $ mkdir /shared/project                                    │    │
│  │  $ chgrp developers /shared/project                         │    │
│  │  $ chmod g+s /shared/project                                │    │
│  │  $ chmod 2775 /shared/project                               │    │
│  │  # Acum toate fișierele noi aparțin grupului "developers"   │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  Sticky Bit - Bit 1xxx                                      │    │
│  │                                                              │    │
│  │  drwxrwxrwt (t în loc de x pentru others)                   │    │
│  │                                                              │    │
│  │  • Doar owner-ul fișierului poate șterge/redenumi           │    │
│  │  • Folosit pe directoare publice (/tmp)                     │    │
│  │                                                              │    │
│  │  $ ls -ld /tmp                                              │    │
│  │  drwxrwxrwt 15 root root ... /tmp                           │    │
│  │          ^                                                   │    │
│  │  Toți pot crea fișiere, dar fiecare șterge doar ale lui     │    │
│  │                                                              │    │
│  │  chmod +t directory    sau    chmod 1777 directory          │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```


### Caractere Speciale CRON

```
┌──────────────────────────────────────────────────────────────────────┐
│                    SPECIAL PERMISSIONS                               │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  SUID (Set User ID) - Bit 4xxx                              │    │
│  │                                                              │    │
│  │  -rwsr-xr-x  (s instead of x for owner)                     │    │
│  │                                                              │    │
│  │  • Process runs with UID of the file owner                  │    │
│  │  • Used for: passwd, ping, sudo                             │    │
│  │                                                              │    │
│  │  Example:                                                    │    │
│  │  $ ls -l /usr/bin/passwd                                    │    │
│  │  -rwsr-xr-x 1 root root ... /usr/bin/passwd                 │    │
│  │        ^                                                     │    │
│  │  Any user can change password (requires writing to          │    │
│  │  /etc/shadow which is owned by root)                        │    │
│  │                                                              │    │
│  │  chmod u+s file    or    chmod 4755 file                    │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  SGID (Set Group ID) - Bit 2xxx                             │    │
│  │                                                              │    │
│  │  On files: -rwxr-sr-x (s instead of x for group)            │    │
│  │  On directories: drwxr-sr-x                                 │    │
│  │                                                              │    │
│  │  On files:                                                   │    │
│  │  • Process runs with GID of the file's group                │    │
│  │                                                              │    │
│  │  On directories (more common):                               │    │
│  │  • New files inherit the directory's group                  │    │
│  │  • Useful for shared project directories                    │    │
│  │                                                              │    │
│  │  Example:                                                    │    │
│  │  $ mkdir /shared/project                                    │    │
│  │  $ chgrp developers /shared/project                         │    │
│  │  $ chmod g+s /shared/project                                │    │
│  │  $ chmod 2775 /shared/project                               │    │
│  │  # Now all new files belong to the "developers" group       │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  Sticky Bit - Bit 1xxx                                      │    │
│  │                                                              │    │
│  │  drwxrwxrwt (t instead of x for others)                     │    │
│  │                                                              │    │
│  │  • Only the file owner can delete/rename                    │    │
│  │  • Used on public directories (/tmp)                        │    │
│  │                                                              │    │
│  │  $ ls -ld /tmp                                              │    │
│  │  drwxrwxrwt 15 root root ... /tmp                           │    │
│  │          ^                                                   │    │
│  │  Everyone can create files, but each can only delete their  │    │
│  │  own                                                         │    │
│  │                                                              │    │
│  │  chmod +t directory    or    chmod 1777 directory           │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```


### CRON - Flux de Execuție

```
┌──────────────────────────────────────────────────────────────────────┐
│                       CRON SYSTEM                                    │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │                    CRON DAEMON                               │    │
│  │                    (crond/cron)                              │    │
│  │              Rulează continuu în background                  │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                              │                                       │
│              La fiecare minut verifică:                             │
│                              │                                       │
│         ┌────────────────────┼────────────────────┐                 │
│         ▼                    ▼                    ▼                  │
│  ┌─────────────┐    ┌──────────────┐    ┌──────────────────┐       │
│  │ User        │    │ System       │    │ Cron Directories │       │
│  │ Crontabs    │    │ Crontab      │    │ /etc/cron.*     │       │
│  │             │    │              │    │                  │       │
│  │ /var/spool/ │    │ /etc/crontab │    │ cron.hourly/    │       │
│  │ cron/       │    │              │    │ cron.daily/     │       │
│  │ crontabs/   │    │ Include user │    │ cron.weekly/    │       │
│  │             │    │ field        │    │ cron.monthly/   │       │
│  └─────────────┘    └──────────────┘    └──────────────────┘       │
│                                                                      │
│  Format crontab:                                                     │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  ┌─────────── minute (0-59)                                 │    │
│  │  │ ┌─────────── hour (0-23)                                 │    │
│  │  │ │ ┌─────────── day of month (1-31)                       │    │
│  │  │ │ │ ┌─────────── month (1-12)                            │    │
│  │  │ │ │ │ ┌─────────── day of week (0-7, 0,7=Sunday)         │    │
│  │  │ │ │ │ │                                                   │    │
│  │  │ │ │ │ │                                                   │    │
│  │  * * * * * command                                          │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  Exemple vizuale:                                                    │
│                                                                      │
│  */5 * * * *     La fiecare 5 minute                               │
│  ──────────────────────────────────────────────────────►           │
│  │    │    │    │    │    │    │    │    │    │    │    │          │
│  0    5   10   15   20   25   30   35   40   45   50   55          │
│                                                                      │
│  0 3 * * *       Zilnic la 03:00                                    │
│  ──────────────────────────────────────────────────────►           │
│  │                        ▲                             │          │
│  00:00                 03:00                         23:59         │
│                                                                      │
│  0 9 * * 1-5     Luni-Vineri la 09:00                              │
│        L    M    M    J    V    S    D                              │
│        ▲    ▲    ▲    ▲    ▲                                       │
│       09:00                                                         │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

---


## Fully Solved Exercises


### Exercițiul 2: Script de Parsare Argumente Complet

**Cerință:** Creează un script profesional cu suport pentru opțiuni scurte și lungi.

```bash
#!/bin/bash
#

# Scenariul: Echipa "developers" trebuie să lucreze pe un proiect comun


# Pas 1: Creează grupul (dacă nu există)
sudo groupadd developers


# Pas 2: Adaugă utilizatori la grup
sudo usermod -aG developers alice
sudo usermod -aG developers bob
sudo usermod -aG developers charlie


# Pas 3: Verifică membrii grupului
grep developers /etc/group

# developers:x:1001:alice,bob,charlie


# Pas 4: Creează structura de directoare
sudo mkdir -p /projects/webapp/{src,docs,tests,config}


# Pas 5: Setează ownership
sudo chown -R root:developers /projects/webapp


# Pas 6: Setează permisiuni de bază (owner=rwx, group=rwx, others=---)
sudo chmod -R 770 /projects/webapp


# Pas 7: Setează SGID pe directoare (fișierele noi moștenesc grupul)
sudo find /projects/webapp -type d -exec chmod g+s {} \;


# Pas 8: Verifică rezultatul
ls -la /projects/webapp/

# drwxrws--- 6 root developers 4096 Jan 10 12:00 .

# drwxrws--- 2 root developers 4096 Jan 10 12:00 config

# drwxrws--- 2 root developers 4096 Jan 10 12:00 docs

# drwxrws--- 2 root developers 4096 Jan 10 12:00 src

# drwxrws--- 2 root developers 4096 Jan 10 12:00 tests


# Pas 9: Testează ca alice
su - alice
cd /projects/webapp/src
touch test_file.py
ls -l test_file.py

# -rw-rw---- 1 alice developers 0 Jan 10 12:01 test_file.py

# Observă: grupul este "developers" datorită SGID!


# Pas 10: Setează umask pentru grup
echo "umask 007" >> ~/.bashrc

# Fișierele noi vor fi 770/660 (nu accesibile pentru others)
```


### Exercițiul 3: Job Cron Complet cu Logging

**Requirement:** Create a professional script with support for short and long options.

```bash
#!/bin/bash
#

# Script: backup_tool.sh

# Descriere: Tool de backup cu opțiuni complete
#

set -euo pipefail


# === CONSTANTE ===
readonly VERSION="1.0.0"
readonly SCRIPT_NAME=$(basename "$0")


# === VARIABILE DEFAULT ===
VERBOSE=false
DRY_RUN=false
COMPRESS=false
OUTPUT_DIR="./backup"
RETENTION_DAYS=7
SOURCE=""


# === FUNCȚII ===
usage() {
    cat << EOF
$SCRIPT_NAME v$VERSION - Tool de backup

UTILIZARE:
    $SCRIPT_NAME [opțiuni] <sursa>

OPȚIUNI:
    -h, --help              Afișează acest mesaj
    -V, --version           Afișează versiunea
    -v, --verbose           Mod verbose
    -n, --dry-run           Simulare (nu execută)
    -c, --compress          Comprimă backup-ul (tar.gz)
    -o, --output DIR        Director output (default: ./backup)
    -r, --retention DAYS    Păstrează backup-uri DAYS zile (default: 7)

EXEMPLE:
    $SCRIPT_NAME /home/user/documents
    $SCRIPT_NAME -v -c -o /backup /var/www
    $SCRIPT_NAME --dry-run --retention 30 /data

EOF
    exit 0
}

version() {
    echo "$SCRIPT_NAME versiunea $VERSION"
    exit 0
}

log() {
    if $VERBOSE; then
        echo "[$(date '+%H:%M:%S')] $*"
    fi
}

error() {
    echo "EROARE: $*" >&2
    exit 1
}


# === PARSARE ARGUMENTE ===
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                ;;
            -V|--version)
                version
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -n|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -c|--compress)
                COMPRESS=true
                shift
                ;;
            -o|--output)
                [[ -z "${2:-}" ]] && error "Opțiunea -o necesită un argument"
                OUTPUT_DIR="$2"
                shift 2
                ;;
            --output=*)
                OUTPUT_DIR="${1#*=}"
                shift
                ;;
            -r|--retention)
                [[ -z "${2:-}" ]] && error "Opțiunea -r necesită un argument"
                RETENTION_DAYS="$2"
                shift 2
                ;;
            --retention=*)
                RETENTION_DAYS="${1#*=}"
                shift
                ;;
            --)
                shift
                SOURCE="${1:-}"
                break
                ;;
            -*)
                error "Opțiune necunoscută: $1"
                ;;
            *)
                SOURCE="$1"
                shift
                ;;
        esac
    done

    # Validare
    [[ -z "$SOURCE" ]] && error "Lipsește sursa pentru backup"
    [[ ! -e "$SOURCE" ]] && error "Sursa nu există: $SOURCE"
    [[ ! "$RETENTION_DAYS" =~ ^[0-9]+$ ]] && error "Retention trebuie să fie număr"
}


# === MAIN ===
do_backup() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_name="backup_$(basename "$SOURCE")_$timestamp"
    
    mkdir -p "$OUTPUT_DIR"
    
    log "Source: $SOURCE"
    log "Output: $OUTPUT_DIR"
    log "Compression: $COMPRESS"
    
    if $DRY_RUN; then
        echo "[DRY RUN] Would create backup: $OUTPUT_DIR/$backup_name"
        return 0
    fi
    
    if $COMPRESS; then
        tar czf "$OUTPUT_DIR/${backup_name}.tar.gz" -C "$(dirname "$SOURCE")" "$(basename "$SOURCE")"
        log "Created: $OUTPUT_DIR/${backup_name}.tar.gz"
    else
        cp -r "$SOURCE" "$OUTPUT_DIR/$backup_name"
        log "Created: $OUTPUT_DIR/$backup_name"
    fi
    
    # Old cleanup
    log "Deleting backups older than $RETENTION_DAYS days..."
    find "$OUTPUT_DIR" -name "backup_*" -mtime +$RETENTION_DAYS -delete 2>/dev/null || true
    
    echo "Backup complete!"
}


# === LOGICĂ PRINCIPALĂ ===
do_backup() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_name="backup_$(basename "$SOURCE")_$timestamp"
    
    mkdir -p "$OUTPUT_DIR"
    
    log "Sursa: $SOURCE"
    log "Output: $OUTPUT_DIR"
    log "Comprimare: $COMPRESS"
    
    if $DRY_RUN; then
        echo "[DRY RUN] Ar crea backup: $OUTPUT_DIR/$backup_name"
        return 0
    fi
    
    if $COMPRESS; then
        tar czf "$OUTPUT_DIR/${backup_name}.tar.gz" -C "$(dirname "$SOURCE")" "$(basename "$SOURCE")"
        log "Creat: $OUTPUT_DIR/${backup_name}.tar.gz"
    else
        cp -r "$SOURCE" "$OUTPUT_DIR/$backup_name"
        log "Creat: $OUTPUT_DIR/$backup_name"
    fi
    
    # Cleanup vechi
    log "Șterg backup-uri mai vechi de $RETENTION_DAYS zile..."
    find "$OUTPUT_DIR" -name "backup_*" -mtime +$RETENTION_DAYS -delete 2>/dev/null || true
    
    echo "Backup complet!"
}


### Exercițiul 1: Configurare Director Proiect Shared

**Cerință:** Configurează un director pentru echipă cu permisiuni corecte.

```bash

# Pas 1: Creează scriptul de backup (din exercițiul anterior)
sudo cp backup_tool.sh /usr/local/bin/backup_tool
sudo chmod +x /usr/local/bin/backup_tool


# Pas 2: Creează directorul de log
sudo mkdir -p /var/log/backup
sudo chmod 755 /var/log/backup


# Pas 3: Creează wrapper script cu logging complet
sudo tee /usr/local/bin/daily_backup.sh << 'SCRIPT'
#!/bin/bash
#

# daily_backup.sh - Wrapper pentru backup zilnic cu logging
#

LOG_FILE="/var/log/backup/backup_$(date +%Y%m%d).log"
LOCK_FILE="/tmp/daily_backup.lock"


# Previne execuții simultane
if [ -f "$LOCK_FILE" ]; then
    echo "$(date): Backup deja în execuție" >> "$LOG_FILE"
    exit 1
fi


# Creează lock
echo $$ > "$LOCK_FILE"
trap "rm -f $LOCK_FILE" EXIT


# Funcție de logging
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $*" >> "$LOG_FILE"
}


# Start
log "=== Start backup zilnic ==="


# Backup 1: Documente utilizatori
log "Backup documente..."
if /usr/local/bin/backup_tool -c -o /backup/docs /home 2>> "$LOG_FILE"; then
    log "Documente: OK"
else
    log "Documente: EROARE"
fi


# Backup 2: Configurări sistem
log "Backup configurări..."
if /usr/local/bin/backup_tool -c -o /backup/config /etc 2>> "$LOG_FILE"; then
    log "Configurări: OK"
else
    log "Configurări: EROARE"
fi


# Backup 3: Baze de date (exemplu)
log "Backup MySQL..."
if mysqldump --all-databases | gzip > "/backup/db/mysql_$(date +%Y%m%d).sql.gz" 2>> "$LOG_FILE"; then
    log "MySQL: OK"
else
    log "MySQL: EROARE (sau nu e instalat)"
fi


# Cleanup log-uri vechi (păstrează 30 zile)
find /var/log/backup -name "backup_*.log" -mtime +30 -delete

log "=== Backup complet ==="


# Trimite email dacă au fost erori
if grep -q "EROARE" "$LOG_FILE"; then
    mail -s "Backup Warning $(date +%Y-%m-%d)" Issues: Open an issue in GitHub < "$LOG_FILE"
fi
SCRIPT

sudo chmod +x /usr/local/bin/daily_backup.sh


# Pas 4: Adaugă în crontab

# Backup zilnic la 3:00 AM
echo "0 3 * * * root /usr/local/bin/daily_backup.sh" | sudo tee /etc/cron.d/daily_backup


# Pas 5: Verifică
sudo crontab -l -u root
cat /etc/cron.d/daily_backup
```

---


## Referințe Rapide


### Permisiuni Comune

| Octal | Simbolic | Utilizare |
|-------|----------|-----------|
| 755 | rwxr-xr-x | Executabile, directoare publice |
| 644 | rw-r--r-- | Fișiere normale |
| 700 | rwx------ | Directoare private |
| 600 | rw------- | Fișiere private |
| 775 | rwxrwxr-x | Directoare grup |
| 664 | rw-rw-r-- | Fișiere grup |
| 777 | rwxrwxrwx | EVITĂ! Nesigur |


### CRON Special Characters

| Character | Meaning |
|-----------|---------|
| * | Any value |
| , | List (1,3,5) |
| - | Range (1-5) |
| / | Step (*/5) |
| @reboot | At boot |
| @daily | Daily 00:00 |
| @weekly | Sunday 00:00 |
| @monthly | First day 00:00 |

---
*Supplementary material for the Operating Systems course | Bucharest UES - CSIE*
-e 

---

*By Revolvix for OPERATING SYSTEMS class | restricted licence 2017-2030*

