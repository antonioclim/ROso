# Exerciții LLM-Aware - Seminarul 03
## Sisteme de Operare | Evaluare Critică a Codului Generat de AI

**Scop**: Dezvoltarea abilității de a evalua, corecta și îmbunătăți codul generat de LLM-uri
**Principiu**: AI-ul e un instrument puternic, dar necesită verificare umană
Metodă: Generare → Evaluare → Identificare Probleme → Îmbunătățire

---

## INTRODUCERE

### De Ce Exerciții LLM-Aware?

În 2025, studenții vor folosi inevitabil LLM-uri pentru a genera cod. În loc să ignorăm această realitate, îi învățăm să:
1. **Evalueze critic** output-ul AI
2. **Identifice probleme** comune (securitate, eficiență, corectitudine)
3. **Îmbunătățească** codul generat
4. **Înțeleagă** ce face codul, nu doar să-l copieze

### Structura Exercițiilor

```
╔═══════════════════════════════════════════════════════════════╗
║  📝 CERINȚĂ INIȚIALĂ                                          ║
║  → Ce am cerut LLM-ului să genereze                          ║
║                                                               ║
║  🤖 OUTPUT LLM (simulat realistic)                            ║
║  → Cod generat cu probleme subtile sau evidente              ║
║                                                               ║
║  🔍 TASK STUDENT                                              ║
║  → Identifică X probleme                                      ║
║  → Explică de ce sunt probleme                               ║
║  → Propune soluții                                           ║
║                                                               ║
║  ✅ SOLUȚIE ȘI EXPLICAȚIE                                     ║
║  → Problemele reale și codul corectat                        ║
╚═══════════════════════════════════════════════════════════════╝
```

---

## EXERCIȚIU L1: Find Command Generator

### CERINȚĂ TRIMISĂ LA LLM

```
"Generează o comandă find care găsește toate fișierele .log 
mai mari de 100MB, mai vechi de 30 de zile, și le șterge 
pentru a elibera spațiu pe disk."
```

### OUTPUT LLM

```bash
# LLM a generat:
find /var/log -name "*.log" -size +100M -mtime +30 -exec rm {} \;
```

### TASK STUDENT

```
═══════════════════════════════════════════════════════════════
🎯 EVALUARE CRITICĂ

Analizează comanda generată și răspunde:

1. Identifică MINIM 3 probleme cu această comandă
   (securitate, eficiență, corectitudine)

2. Pentru fiecare problemă:

Pe scurt: De ce este o problemă?; Ce poate merge rău?; Cum o corectezi?.


3. Rescrie comanda într-o versiune SIGURĂ și EFICIENTĂ

4. Ce întrebare de clarificare ar fi trebuit să pui înainte 
   de a rula această comandă?

⏱️ Timp: 8 minute
═══════════════════════════════════════════════════════════════
```

### SOLUȚIE ȘI EXPLICAȚIE

#### Problemele Identificate:

| # | Problemă | Risc | Severitate |
|---|----------|------|------------|
| 1 | Nu are `-type f` | Poate șterge directoare numite `*.log` | 🔴 High |
| 2 | Nu filtrează erorile | Permission denied spam în output | 🟡 Medium |
| 3 | `-exec rm {} \;` fără confirmare | Ștergere ireversibilă | 🔴 High |
| 4 | Nu verifică mai întâi ce șterge | Pierdere date | 🔴 High |
| 5 | Caută în /var/log care poate avea logs critice | Poate șterge logs de audit | 🔴 High |
| 6 | `-exec {} \;` e ineficient | Pornește un proces rm per fișier | 🟡 Medium |

#### Cod Corectat:

```bash
# PASUL 1: Verifică mai întâi CE ar șterge (DRY RUN)
find /var/log -type f -name "*.log" -size +100M -mtime +30 \
    -printf "%s %p\n" 2>/dev/null | sort -rn

# PASUL 2: Dacă lista e OK, șterge cu confirmare
find /var/log -type f -name "*.log" -size +100M -mtime +30 \
    -ok rm {} \; 2>/dev/null

# SAU pentru ștergere batch (cu verificare prealabilă):
find /var/log -type f -name "*.log" -size +100M -mtime +30 \
    -print0 2>/dev/null | xargs -0 rm -i

# VARIANTA SIGURĂ PENTRU PRODUCȚIE:
find /var/log -type f -name "*.log" -size +100M -mtime +30 \
    ! -name "*.gz" \
    -exec mv {} /tmp/logs_to_delete/ \; 2>/dev/null
# Apoi verifici /tmp/logs_to_delete/ și ștergi manual
```

#### Întrebări de Clarificare Necesare:

1. "Există logs care NU trebuie șterse? (audit, security)"
2. "Trebuie arhivate înainte de ștergere?"
3. "Rulează cu privilegii root sau user normal?"
4. "Este un sistem de producție sau test?"

---

## EXERCIȚIU L2: Script cu getopts

### CERINȚĂ TRIMISĂ LA LLM

```
"Scrie un script bash care acceptă opțiunile -v pentru verbose,
-o pentru output file, și procesează fișierele date ca argumente."
```

### OUTPUT LLM

```bash
#!/bin/bash
# LLM a generat:

verbose=0
output=""

while getopts "vo:" opt; do
    case $opt in
        v) verbose=1 ;;
        o) output=$OPTARG ;;
    esac
done

for file in $@; do
    if [ $verbose == 1 ]; then
        echo "Processing $file"
    fi
    cat $file >> $output
done

echo "Done!"
```

### TASK STUDENT

```
═══════════════════════════════════════════════════════════════
🎯 EVALUARE CRITICĂ

Analizează scriptul și:

1. Identifică MINIM 5 probleme (sintaxă, securitate, logică)

2. Testează mental cu aceste input-uri:

Trei lucruri contează aici: ./script.sh -v -o result.txt file1.txt "file 2.txt", ./script.sh file.txt  (fără -o), și ./script.sh -o  (fără argument pentru -o).


3. Rescrie scriptul corect și solid

⏱️ Timp: 10 minute
═══════════════════════════════════════════════════════════════
```

### SOLUȚIE ȘI EXPLICAȚIE

#### Problemele Identificate:

| # | Linie | Problemă | Explicație |
|---|-------|----------|------------|
| 1 | `for file in $@` | Lipsesc ghilimele | Fișierele cu spații se sparg |
| 2 | `if [ $verbose == 1 ]` | `==` e pentru string, nu număr | Folosește `-eq` pentru numere |
| 3 | `cat $file >> $output` | Fără ghilimele | Probleme cu spații |
| 4 | - | Lipsește `shift $((OPTIND-1))` | $@ include și opțiunile! |
| 5 | - | Nu verifică dacă $output e setat | Dacă lipsește -o, >> "" dă eroare |
| 6 | - | Nu verifică dacă fișierele există | cat pe fișier inexistent = eroare |
| 7 | - | Lipsește help (-h) | Best practice |
| 8 | - | Nu gestionează opțiuni invalide | `?` în case |

#### Cod Corectat:

```bash
#!/bin/bash
# Script corect și solid

verbose=false
output=""

usage() {
    echo "Usage: $0 [-h] [-v] [-o output_file] files..."
    echo "  -h  Show help"
    echo "  -v  Verbose mode"
    echo "  -o  Output file (required)"
    exit 1
}

# Parsare opțiuni
while getopts "hvo:" opt; do
    case $opt in
        h) usage ;;
        v) verbose=true ;;
        o) output="$OPTARG" ;;
        ?) usage ;;
    esac
done
shift $((OPTIND - 1))

# Validări
if [ -z "$output" ]; then
    echo "Eroare: -o output_file este obligatoriu!" >&2
    usage
fi

if [ $# -eq 0 ]; then
    echo "Eroare: Specificați cel puțin un fișier!" >&2
    usage
fi

# Procesare
for file in "$@"; do
    if [ ! -f "$file" ]; then
        echo "Warning: '$file' nu există, skip..." >&2
        continue
    fi
    
    if [ "$verbose" = true ]; then
        echo "Processing: $file"
    fi
    
    cat "$file" >> "$output"
done

echo "Done! Output: $output"
```

---

## EXERCIȚIU L3: Cron Job Reviewer

### CERINȚĂ TRIMISĂ LA LLM

```
"Generează un cron job care face backup zilnic la baza de date 
la ora 2 AM și trimite un email cu rezultatul."
```

### OUTPUT LLM

```cron
# LLM a generat:
0 2 * * * mysqldump mydb > /backup/db_$(date +%Y%m%d).sql && mail -s "Backup OK" Issues: Open an issue in GitHub
```

### TASK STUDENT

```
═══════════════════════════════════════════════════════════════
🎯 EVALUARE CRITICĂ

1. Identifică MINIM 4 probleme cu acest cron job

2. Pentru fiecare problemă, explică:
   - Ce se întâmplă când rulează în cron?
   - De ce funcționează în terminal dar nu în cron?

3. Rescrie cron job-ul corect, incluzând:
   - Logging adecvat
   - Error handling
   - Rotație backup-uri

⏱️ Timp: 8 minute
═══════════════════════════════════════════════════════════════
```

### SOLUȚIE ȘI EXPLICAȚIE

#### Problemele Identificate:

| # | Problemă | De ce nu merge în cron |
|---|----------|------------------------|
| 1 | `$(date +%Y%m%d)` | Cron folosește /bin/sh, nu bash. `$()` poate să nu funcționeze în toate shell-urile |
| 2 | Path-uri relative | `mysqldump`, `mail` nu sunt în PATH-ul minimal al cron |
| 3 | `/backup/` | Directorul poate să nu existe sau cron nu are permisiuni |
| 4 | `>` suprascrie | Dacă sunt 2 backup-uri în aceeași zi, al doilea suprascrie |
| 5 | `&&` ignoră erori parțiale | Dacă mysqldump eșuează, nu se trimite email de eroare |
| 6 | Fără logging | Nu știi dacă a rulat sau nu |
| 7 | Credențiale DB | Unde sunt user/pass pentru mysqldump? |

#### Cod Corectat:

```cron
# Crontab corectat - adaugă la început:
SHELL=/bin/bash
PATH=/usr/local/bin:/usr/bin:/bin
MAILTO=Issues: Open an issue in GitHub

# Backup zilnic la 2 AM
0 2 * * * /home/user/scripts/backup_db.sh >> /var/log/backup.log 2>&1
```

```bash
#!/bin/bash
# /home/user/scripts/backup_db.sh

# Configurări
BACKUP_DIR="/backup/mysql"
DB_NAME="mydb"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/db_${DATE}.sql.gz"
LOG_PREFIX="[$(date '+%Y-%m-%d %H:%M:%S')]"
KEEP_DAYS=7

# Verificări
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR" || {
        echo "$LOG_PREFIX EROARE: Nu pot crea $BACKUP_DIR"
        exit 1
    }
fi

# Backup cu compresie
echo "$LOG_PREFIX START backup $DB_NAME"

if /usr/bin/mysqldump --defaults-file=/home/user/.my.cnf "$DB_NAME" | gzip > "$BACKUP_FILE"; then
    SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    echo "$LOG_PREFIX SUCCESS: $BACKUP_FILE ($SIZE)"
    
    # Rotație - șterge backup-uri vechi
    find "$BACKUP_DIR" -name "db_*.sql.gz" -mtime +$KEEP_DAYS -delete
    DELETED=$?
    echo "$LOG_PREFIX Cleanup: șters backup-uri > $KEEP_DAYS zile"
else
    echo "$LOG_PREFIX EROARE: Backup eșuat!"
    # Cron trimite automat email pentru output (via MAILTO)
    exit 1
fi

echo "$LOG_PREFIX END backup"
```

```ini
# ~/.my.cnf (pentru credențiale)
[mysqldump]
user=backup_user
password=secure_password
```

---

## EXERCIȚIU L4: Permission Script Improver

### CERINȚĂ TRIMISĂ LA LLM

```
"Scrie un script care setează permisiunile corecte pentru 
un proiect web: fișierele să fie 644, directoarele 755."
```

### OUTPUT LLM

```bash
#!/bin/bash
# LLM a generat:

chmod -R 644 /var/www/project
chmod -R 755 /var/www/project

echo "Permissions fixed!"
```

### TASK STUDENT

```
═══════════════════════════════════════════════════════════════
🎯 EVALUARE CRITICĂ

1. Testează mental: ce permisiuni vor avea fișierele și 
   directoarele după rularea acestui script?

2. Identifică eroarea logică fundamentală

3. Explică de ce abordarea e greșită din punct de vedere
   al securității și funcționalității

4. Rescrie scriptul corect

5. BONUS: Adaugă validări și --dry-run mode

⏱️ Timp: 10 minute
═══════════════════════════════════════════════════════════════
```

### SOLUȚIE ȘI EXPLICAȚIE

#### Analiza Problemei:

```
Script original:
1. chmod -R 644 /var/www/project
   → TOATE fișierele ȘI directoarele devin 644 (rw-r--r--)
   → Directoarele fără x = nu poți face cd în ele!

2. chmod -R 755 /var/www/project
   → SUPRASCRIE totul cu 755 (rwxr-xr-x)
   → Acum TOATE fișierele sunt executabile!

REZULTAT: Toate fișierele sunt 755, nu 644!
          E exact OPUSUL a ce voiam.
```

#### Cod Corectat:

```bash
#!/bin/bash
# fix_permissions.sh - Corect și sigur

set -euo pipefail

# Configurări
PROJECT_DIR="${1:-/var/www/project}"
FILE_PERM="644"
DIR_PERM="755"
DRY_RUN=false

# Parsare argumente
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run|-n)
            DRY_RUN=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [--dry-run] [directory]"
            exit 0
            ;;
        *)
            PROJECT_DIR="$1"
            shift
            ;;
    esac
done

# Validări
if [ ! -d "$PROJECT_DIR" ]; then
    echo "Eroare: '$PROJECT_DIR' nu există sau nu e director!" >&2
    exit 1
fi

echo "🔧 Fixing permissions in: $PROJECT_DIR"
echo "   Files: $FILE_PERM, Directories: $DIR_PERM"
[ "$DRY_RUN" = true ] && echo "   MODE: DRY RUN (no changes)"

# Numărare pentru raport
file_count=0
dir_count=0

# Fix directoare PRIMUL (pentru a putea accesa conținutul)
echo "📁 Setting directory permissions..."
while IFS= read -r -d '' dir; do
    if [ "$DRY_RUN" = true ]; then
        echo "  Would chmod $DIR_PERM: $dir"
    else
        chmod "$DIR_PERM" "$dir"
    fi
    ((dir_count++))
done < <(find "$PROJECT_DIR" -type d -print0)

# Fix fișiere
echo "📄 Setting file permissions..."
while IFS= read -r -d '' file; do
    if [ "$DRY_RUN" = true ]; then
        echo "  Would chmod $FILE_PERM: $file"
    else
        chmod "$FILE_PERM" "$file"
    fi
    ((file_count++))
done < <(find "$PROJECT_DIR" -type f -print0)

echo "✅ Done! Processed $dir_count directories, $file_count files"

# Verificare
if [ "$DRY_RUN" = false ]; then
    echo ""
    echo "📊 Verification:"
    echo "Sample directories:"
    find "$PROJECT_DIR" -type d | head -3 | xargs ls -ld
    echo "Sample files:"
    find "$PROJECT_DIR" -type f | head -3 | xargs ls -l
fi
```

#### Varianta Simplă (One-liner):

```bash
# Varianta corectă și concisă:
find /var/www/project -type d -exec chmod 755 {} +
find /var/www/project -type f -exec chmod 644 {} +

# SAU cu -R și X (execute doar pe directoare):
chmod -R u=rwX,g=rX,o=rX /var/www/project
```

---

## EXERCIȚIU L5: Security Checker

### CERINȚĂ TRIMISĂ LA LLM

```
"Scrie un script care verifică dacă sistemul are probleme 
de securitate cu permisiunile fișierelor."
```

### OUTPUT LLM

```bash
#!/bin/bash
# LLM a generat:

echo "Checking for security issues..."

# Find world-writable files
find / -perm 777 2>/dev/null

# Find SUID files
find / -perm -4000 2>/dev/null

# Find files without owner
find / -nouser 2>/dev/null

echo "Check complete!"
```

### TASK STUDENT

```
═══════════════════════════════════════════════════════════════
🎯 EVALUARE CRITICĂ

1. Identifică ce lipsește pentru ca acest script să fie 
   utilizabil într-un audit real

2. Problemele de performanță și output

3. Ce verificări de securitate importante lipsesc?

4. Rescrie scriptul ca tool profesional de audit, incluzând:
   - Output formatat
   - Severitate per problemă
   - Excluderi standard (/proc, /sys, etc.)
   - Raport salvabil

⏱️ Timp: 12 minute
═══════════════════════════════════════════════════════════════
```

### SOLUȚIE ȘI EXPLICAȚIE

#### Problemele Identificate:

1. **Fără context**: Nu explică DE CE e o problemă
2. **Fără excluderi**: Scanează /proc, /sys (mii de fișiere irelevante)
3. **Fără formatare**: Output greu de citit
4. **Incomplet**: Lipsesc verificări importante (SGID, sticky, .rhosts, etc.)
5. **Fără severitate**: Toate problemele par egale
6. **Fără raport**: Output se pierde

#### Cod Corectat (Profesional):

```bash
#!/bin/bash
# security_audit.sh - Professional Security Checker

set -euo pipefail

# Configurări
REPORT_FILE="/tmp/security_audit_$(date +%Y%m%d_%H%M%S).txt"
EXCLUDE_PATHS="/proc|/sys|/run|/dev|/snap"

# Culori
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m'

# Funcții
log_issue() {
    local severity="$1"
    local category="$2"
    local message="$3"
    local color
    
    case $severity in
        HIGH) color="$RED" ;;
        MEDIUM) color="$YELLOW" ;;
        LOW) color="$GREEN" ;;
    esac
    
    echo -e "${color}[$severity]${NC} [$category] $message"
    echo "[$severity] [$category] $message" >> "$REPORT_FILE"
}

header() {
    echo ""
    echo "=========================================="
    echo " $1"
    echo "=========================================="
    echo "" >> "$REPORT_FILE"
    echo "=== $1 ===" >> "$REPORT_FILE"
}

# Inițializare raport
echo "Security Audit Report - $(date)" > "$REPORT_FILE"
echo "Host: $(hostname)" >> "$REPORT_FILE"
echo "User: $(whoami)" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

echo "🔒 Security Audit Started"
echo "   Report: $REPORT_FILE"
echo ""

# 1. World-Writable Files (exclud standard paths)
header "World-Writable Files"
count=0
while IFS= read -r file; do
    # Exclude symbolic links și sticky directories
    if [ -f "$file" ] && [ ! -L "$file" ]; then
        log_issue "HIGH" "WORLD_WRITE" "$file"
        ((count++))
    fi
done < <(find / -type f -perm -002 2>/dev/null | grep -Ev "$EXCLUDE_PATHS" | head -50)
echo "Found: $count world-writable files"

# 2. SUID Binaries (exclude known safe ones)
header "SUID Binaries"
KNOWN_SUID="/usr/bin/passwd|/usr/bin/sudo|/usr/bin/su|/usr/bin/mount|/usr/bin/umount"
count=0
while IFS= read -r file; do
    if ! echo "$file" | grep -qE "$KNOWN_SUID"; then
        log_issue "MEDIUM" "SUID" "$file"
        ((count++))
    fi
done < <(find / -type f -perm -4000 2>/dev/null | grep -Ev "$EXCLUDE_PATHS")
echo "Found: $count unusual SUID files"

# 3. SGID Binaries
header "SGID Binaries"
count=0
while IFS= read -r file; do
    log_issue "LOW" "SGID" "$file"
    ((count++))
done < <(find / -type f -perm -2000 2>/dev/null | grep -Ev "$EXCLUDE_PATHS" | head -20)
echo "Found: $count SGID files"

# 4. Files without owner
header "Orphaned Files (no owner)"
count=0
while IFS= read -r file; do
    log_issue "MEDIUM" "NO_OWNER" "$file"
    ((count++))
done < <(find / \( -nouser -o -nogroup \) 2>/dev/null | grep -Ev "$EXCLUDE_PATHS" | head -20)
echo "Found: $count orphaned files"

# 5. Sensitive files with bad permissions
header "Sensitive Files Check"
sensitive_files=(
    "/etc/passwd:644"
    "/etc/shadow:600"
    "/etc/ssh/sshd_config:600"
    "~/.ssh/id_rsa:600"
    "~/.bash_history:600"
)

for entry in "${sensitive_files[@]}"; do
    file="${entry%%:*}"
    expected="${entry##*:}"
    file="${file/#\~/$HOME}"  # Expand ~
    
    if [ -f "$file" ]; then
        actual=$(stat -c %a "$file" 2>/dev/null)
        if [ "$actual" != "$expected" ]; then
            log_issue "HIGH" "BAD_PERM" "$file has $actual (expected $expected)"
        fi
    fi
done

# 6. Dangerous files
header "Dangerous Files"
dangerous_patterns=(".rhosts" ".netrc" "authorized_keys2")
for pattern in "${dangerous_patterns[@]}"; do
    while IFS= read -r file; do
        log_issue "HIGH" "DANGEROUS" "$file"
    done < <(find /home /root -name "$pattern" 2>/dev/null)
done

# Summary
header "SUMMARY"
high=$(grep -c "^\[HIGH\]" "$REPORT_FILE" || true)
medium=$(grep -c "^\[MEDIUM\]" "$REPORT_FILE" || true)
low=$(grep -c "^\[LOW\]" "$REPORT_FILE" || true)

echo ""
echo "=========================================="
echo -e " ${RED}HIGH: $high${NC} | ${YELLOW}MEDIUM: $medium${NC} | ${GREEN}LOW: $low${NC}"
echo "=========================================="
echo ""
echo "📄 Full report saved to: $REPORT_FILE"
```

---

## CHECKLIST EVALUARE LLM OUTPUT

### Când Primești Cod de la LLM, Verifică:

```
╔═══════════════════════════════════════════════════════════════╗
║  ✓ SECURITATE                                                 ║
║    □ Validează inputul                                        ║
║    □ Nu are injection vulnerabilities                         ║
║    □ Nu expune date sensibile                                ║
║    □ Folosește căi absolute unde necesar                     ║
║                                                               ║
║  ✓ CORECTITUDINE                                              ║
║    □ Testează cu edge cases (spații, caractere speciale)     ║
║    □ Gestionează erori                                        ║
║    □ Face ce trebuie (nu ce pare)                            ║
║                                                               ║
║  ✓ ROBUSTEȚE                                                  ║
║    □ Verifică dacă fișiere/directoare există                 ║
║    □ Are fallback pentru erori                               ║
║    □ Nu suprascrie date fără confirmare                      ║
║                                                               ║
║  ✓ EFICIENȚĂ                                                  ║
║    □ Nu lansează procese inutile                             ║
║    □ Folosește batch operations unde posibil                 ║
║    □ Evită loops ineficiente                                 ║
║                                                               ║
║  ✓ BEST PRACTICES                                             ║
║    □ Are help/usage                                          ║
║    □ Are logging                                             ║
║    □ Are dry-run mode pentru operații periculoase            ║
║    □ Comentarii unde necesar                                 ║
╚═══════════════════════════════════════════════════════════════╝
```

---

*Document generat pentru ASE București - CSIE | Sisteme de Operare | Seminar 3*
