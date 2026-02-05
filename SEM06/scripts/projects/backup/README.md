# SysBackup - Sistem Profesional de Backup

## Descriere

SysBackup este un sistem complet de backup scris în Bash, demonstrând concepte avansate
de scripting pentru automatizarea operațiilor de backup cu suport pentru multiple surse,
compresie configurabilă, rotație automată și verificare integritate.

Proiectul face parte din materialele didactice pentru cursul de Sisteme de Operare
(ASE București, CSIE) și ilustrează tehnici profesionale de dezvoltare scripturi shell.

## Caracteristici

### Funcționalități Core
- **Backup multi-sursă**: suport pentru directoare și fișiere multiple
- **Compresie flexibilă**: gzip, bzip2, xz, zstd (cu auto-detectare disponibilitate) — și legat de asta, **Politici de backup**: daily, weekly, monthly cu retenție configurabilă
- **Verificare integritate**: checksum MD5/SHA1/SHA256 pentru validare
- **Rotație automată**: după număr sau vârstă, cu suport politici diferențiate

### Caracteristici Tehnice
- **Arhitectură modulară**: separare core/utils/config
- **Error handling solid**: validare, retry, cleanup automat
- **Logging complet**: multi-nivel cu output color și fișier
- **Lock files**: prevenire execuții concurente
- **Mod daemon**: execuție programată cu interval configurabil

### Opțiuni Avansate
- **Exclude patterns**: suport glob patterns pentru excluderi
- **Dry run**: simulare backup fără modificări
- **Notificări**: email la succes/eroare
- **Restaurare**: extragere și listare arhive
- **Statistici**: raportare detaliate post-backup

## Structura Proiectului

```
backup/
├── backup.sh           # Script principal (entry point)
├── bin/
│   └── sysbackup       # Wrapper pentru instalare sistem
├── etc/
│   └── backup.conf     # Fișier configurare
├── lib/
│   ├── core.sh         # Funcții fundamentale (logging, errors, locks)
│   ├── utils.sh        # Funcții backup (arhivare, rotație, verificare)
│   └── config.sh       # Parsare configurare și CLI
├── tests/
│   └── test_backup.sh  # Suite teste unitare și integrare
└── var/
    ├── log/            # Fișiere log
    └── run/            # PID și lock files
```

## Instalare

### Cerințe
- Bash 4.0+ (verificat automat)
- Utilitare standard: tar, gzip, find, date
- Opțional: bzip2, xz, zstd (pentru compresie alternativă)
- Opțional: md5sum/sha1sum/sha256sum (pentru verificare integritate)

### Instalare Rapidă

```bash
# Clonare/copiere în locația dorită
cp -r backup/ /opt/sysbackup/

# Configurare permisiuni
chmod +x /opt/sysbackup/backup.sh
chmod +x /opt/sysbackup/bin/sysbackup

# Link simbolic pentru acces global
sudo ln -s /opt/sysbackup/bin/sysbackup /usr/local/bin/sysbackup

# Copiere configurare
sudo cp /opt/sysbackup/etc/backup.conf /etc/sysbackup.conf
```

## Utilizare

### Comenzi de Bază

```bash
# Backup simplu (folosește configurația default)
./backup.sh

# Backup sursă specifică
./backup.sh -s /home/user/documents

# Backup multiple surse
./backup.sh -s /home/user/documents -s /etc -s /var/www

# Specificare destinație
./backup.sh -s /home/user -d /mnt/backup

# Specificare tip compresie
./backup.sh -s /home/user -d /mnt/backup --compression xz
```

### Politici de Backup

```bash
# Backup zilnic (default)
./backup.sh -t daily

# Backup săptămânal (se păstrează mai mult)
./backup.sh -t weekly

# Backup lunar (arhivare pe termen lung)
./backup.sh -t monthly

# Auto-detectare tip bazat pe ziua curentă
./backup.sh -t auto
# Duminică → weekly, Prima zi a lunii → monthly, Altfel → daily
```

### Opțiuni de Retenție

```bash
# Păstrare ultimele 7 backup-uri zilnice
./backup.sh --retention-daily 7

# Configurare completă retenție
./backup.sh --retention-daily 7 --retention-weekly 4 --retention-monthly 12

# Rotație după vârstă (zile)
./backup.sh --rotate-by-age --max-age 30
```

### Excluderi

```bash
# Excludere pattern-uri
./backup.sh -s /home/user -x "*.log" -x "*.tmp" -x "cache/"

# Excludere din fișier
./backup.sh -s /home/user --exclude-file /etc/backup-exclude.txt
```

### Verificare și Restaurare

```bash
# Backup cu verificare integritate
./backup.sh --verify

# Salvare checksum
./backup.sh --checksum --checksum-algo sha256

# Listare conținut arhivă
./backup.sh --list /mnt/backup/backup_daily_20250120_120000.tar.gz

# Restaurare completă
./backup.sh --restore /mnt/backup/backup_daily_20250120_120000.tar.gz -d /tmp/restore

# Restaurare fișiere specifice
./backup.sh --restore /mnt/backup/backup.tar.gz -d /tmp/restore --files "etc/passwd etc/group"
```

### Moduri de Execuție

```bash
# Dry run - simulare fără acțiuni
./backup.sh -s /home/user -d /mnt/backup --dry-run

# Mod verbose
./backup.sh -v

# Mod debug (foarte detaliat)
./backup.sh --debug

# Mod silențios (doar erori)
./backup.sh -q

# Mod daemon (execuție periodică)
./backup.sh --daemon --interval 3600
```

### Formate Output

```bash
# Output text (default)
./backup.sh --output text

# Output JSON (pentru parsare)
./backup.sh --output json

# Output CSV (pentru rapoarte)
./backup.sh --output csv
```

## Configurare

### Fișier de Configurare

Locații căutate (în ordine):
1. `./etc/backup.conf` (relativ la script)
2. `~/.config/sysbackup/backup.conf`
3. `/etc/sysbackup.conf`

### Opțiuni Configurare

```bash
# ===== SURSE ȘI DESTINAȚIE =====
BACKUP_SOURCES=("/home/user" "/etc" "/var/www")
BACKUP_DEST="/mnt/backup"
BACKUP_PREFIX="myserver"

# ===== COMPRESIE =====
# Opțiuni: gz, bz2, xz, zstd, none
COMPRESSION="gz"
# Nivel compresie: 1-9 (unde aplicabil)
COMPRESSION_LEVEL=6

# ===== POLITICI RETENȚIE =====
RETENTION_DAILY=7
RETENTION_WEEKLY=4
RETENTION_MONTHLY=12

# ===== EXCLUDERI =====
EXCLUDE_PATTERNS=(
    "*.log"
    "*.tmp"
    "*.swp"
    "*~"
    ".cache/"
    "node_modules/"
    "__pycache__/"
)

# ===== VERIFICARE =====
VERIFY_BACKUP=true
SAVE_CHECKSUM=true
CHECKSUM_ALGORITHM="sha256"

# ===== NOTIFICĂRI =====
NOTIFY_EMAIL="contact_eliminat"
NOTIFY_ON_SUCCESS=false
NOTIFY_ON_ERROR=true

# ===== LOGGING =====
LOG_LEVEL="INFO"
LOG_FILE="/var/log/sysbackup/backup.log"

# ===== AVANSATE =====
NICE_LEVEL=19
IONICE_CLASS=3
MAX_PARALLEL_JOBS=2
```

## Integrare Sistem

### Cron Job

```bash
# Editare crontab
crontab -e

# Backup zilnic la 2:00 AM
0 2 * * * /opt/sysbackup/backup.sh -q >> /var/log/sysbackup/cron.log 2>&1

# Backup weekly duminică la 3:00 AM
0 3 * * 0 /opt/sysbackup/backup.sh -t weekly -q

# Backup monthly în prima zi a lunii
0 4 1 * * /opt/sysbackup/backup.sh -t monthly -q
```

### Systemd Timer

```ini
# /etc/systemd/system/sysbackup.service
[Unit]
Description=System Backup Service
After=network.target

[Service]
Type=oneshot
ExecStart=/opt/sysbackup/backup.sh -q
User=root
Nice=19
IOSchedulingClass=idle

[Install]
WantedBy=multi-user.target
```

```ini
# /etc/systemd/system/sysbackup.timer
[Unit]
Description=Daily System Backup Timer

[Timer]
OnCalendar=*-*-* 02:00:00
Persistent=true
RandomizedDelaySec=300

[Install]
WantedBy=timers.target
```

```bash
# Activare timer
sudo systemctl enable --now sysbackup.timer

# Verificare status
sudo systemctl list-timers sysbackup*
```

### Systemd Service (Daemon Mode)

```ini
# /etc/systemd/system/sysbackup-daemon.service
[Unit]
Description=System Backup Daemon
After=network.target

[Service]
Type=simple
ExecStart=/opt/sysbackup/backup.sh --daemon --interval 86400
Restart=on-failure
User=root

[Install]
WantedBy=multi-user.target
```

## Exit Codes

| Cod | Semnificație |
|-----|--------------|
| 0   | Succes - backup completat fără erori |
| 1   | Eroare configurare (sursă invalidă, destinație inaccesibilă) |
| 2   | Eroare în timpul backup-ului (arhivare eșuată parțial) |
| 3   | Eroare fatală (dependențe lipsă, permisiuni) |
| 4   | Eroare verificare (checksum mismatch) |
| 5   | Lock activ (altă instanță rulează) |

## Exemple Avansate

### Script Wrapper pentru Multiple Servere

```bash
#!/usr/bin/env bash
# multi-backup.sh - Backup centralizat multiple servere

SERVERS=("web1" "web2" "db1")
BACKUP_ROOT="/mnt/central-backup"

for server in "${SERVERS[@]}"; do
    echo "=== Backup $server ==="
    ./backup.sh \
        -s "/srv/$server" \
        -d "$BACKUP_ROOT/$server" \
        --prefix "$server" \
        --compression xz \
        --verify \
        --checksum \
        -q
    
    if [[ $? -ne 0 ]]; then
        echo "EROARE: Backup $server a eșuat!"
    fi
done
```

### Backup cu Notificare Slack

```bash
#!/usr/bin/env bash
# backup-notify.sh

WEBHOOK_URL="https://hooks.slack.com/services/XXX/YYY/ZZZ"

./backup.sh "$@"
EXIT_CODE=$?

if [[ $EXIT_CODE -eq 0 ]]; then
    MESSAGE=":white_check_mark: Backup completat cu succes"
else
    MESSAGE=":x: Backup eșuat cu codul $EXIT_CODE"
fi

curl -s -X POST -H 'Content-type: application/json' \
    --data "{\"text\":\"$MESSAGE\"}" \
    "$WEBHOOK_URL"

exit $EXIT_CODE
```

### Backup Incremental Simulat

```bash
#!/usr/bin/env bash
# incremental-backup.sh - Backup doar fișiere modificate recent

DAYS_AGO=${1:-1}
SOURCE="/home/user"
DEST="/mnt/backup/incremental"

# Găsire fișiere modificate
TEMP_LIST=$(mktemp)
find "$SOURCE" -type f -mtime -"$DAYS_AGO" > "$TEMP_LIST"

if [[ -s "$TEMP_LIST" ]]; then
    tar -czf "$DEST/incremental_$(date +%Y%m%d).tar.gz" \
        -T "$TEMP_LIST" \
        --transform "s|^$SOURCE|.|"
    echo "Backup incremental: $(wc -l < "$TEMP_LIST") fișiere"
else
    echo "Niciun fișier modificat în ultimele $DAYS_AGO zile"
fi

rm -f "$TEMP_LIST"
```

## Testare

```bash
# Rulare toate testele
./tests/test_backup.sh

# Rulare teste specifice
./tests/test_backup.sh --filter "test_archive"

# Mod verbose
./tests/test_backup.sh -v

# Output rezultate
# ==========================================
# TEST RESULTS
# ==========================================
# Total: 45
# Passed: 43
# Failed: 2
# Skipped: 0
# Success Rate: 95.56%
# ==========================================
```

## Troubleshooting

### Probleme Comune

**Eroare: "tar: Cannot open: Permission denied"**
```bash
# Verificare permisiuni destinație
ls -la /mnt/backup/
# Rulare cu sudo sau ajustare permisiuni
sudo ./backup.sh
```

**Eroare: "Lock file exists"**
```bash
# Verificare proces activ
cat /var/run/sysbackup/backup.pid
ps aux | grep backup
# Dacă nu există proces, ștergere lock
rm -f /var/run/sysbackup/backup.lock
```

**Backup prea lent**
```bash
# Reducere nivel compresie
./backup.sh --compression gz  # mai rapid decât xz
# Sau folosire compresie paralelă
./backup.sh --compression zstd  # rapid și eficient
```

**Spațiu insuficient**
```bash
# Verificare spațiu disponibil
df -h /mnt/backup/
# Forțare rotație înainte de backup
./backup.sh --force-rotate --retention-daily 3
```

## Arhitectură Cod

### Fluxul de Execuție

```
backup.sh
    │
    ├─→ Încărcare lib/core.sh (logging, errors, locks)
    ├─→ Încărcare lib/utils.sh (archive, rotate, verify)
    ├─→ Încărcare lib/config.sh (parse config, CLI)
    │
    ├─→ init_config() → load_config_file() → parse_args() → validate_config()
    │
    ├─→ acquire_lock()
    │
    ├─→ [Pentru fiecare sursă]
    │       ├─→ create_exclude_file()
    │       ├─→ create_archive()
    │       ├─→ verify_backup_integrity() (opțional)
    │       └─→ calculate_checksum() (opțional)
    │
    ├─→ rotate_backups() / rotate_by_age()
    │
    ├─→ generate_backup_report()
    │
    ├─→ send_notification() (opțional)
    │
    └─→ release_lock() → cleanup() → exit
```

### Principii de Design

1. **Separare responsabilități**: Fiecare modul are un scop clar
2. **Fail-safe defaults**: Comportament sigur în absența configurării
3. **Verbose errors**: Mesaje de eroare descriptive cu sugestii
4. **Idempotent operations**: Rulări repetate nu cauzează probleme
5. **Graceful degradation**: Funcționează fără componente opționale

## Licență

Proiect educațional - Sisteme de Operare, ASE București CSIE.
Utilizare liberă în scopuri didactice și personale.

## Autor

Material didactic creat pentru cursul de Sisteme de Operare.
Seminariile 11-12: Proiecte CAPSTONE Bash.
