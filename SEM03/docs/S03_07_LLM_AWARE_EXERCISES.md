# Exerciții LLM-Aware - Seminarul 03
## Operating Systems | Critical Evaluation of AI-Generated Code

**SCOP**: Teaching students to catch AI mistakes before those mistakes catch them  
**Reality check**: They're going to use ChatGPT anyway. Let's make them *good* at it.

---

## INTRODUCERE

### Why Bother With This?

Let's be honest. Pretending students don't use ChatGPT is like pretending calculators don't exist in 1985. We tried the "just ban it" approach. Three students submitted nearly identical "original" scripts last semester. That was fun to notă.

So here's Plan B: teach them that AI is a powerful **research assistant** that occasionally hallucinates with complete confidence. You know the type—that one colleague who's always *certain* they're right even when they're spectacularly wrong.

**What we're actually teaching:**
1. **Scepticism** — "That looks reasonable" is not verification
2. **Pattern recognition** — AI makes predictable mistakes
3. **Security instincts** — AI optimises for "works" not "safe"
4. **Real understanding** — If you can't explain it, you didn't learn it

The goal isn't catching cheaters. Obiectivul este graduates who can tell the difference between working code and *confidently wrong* code.

### How These Exercises Work

```
╔═══════════════════════════════════════════════════════════════╗
║  📝 THE PROMPT                                                ║
║  → What some hypothetical lazy student asked ChatGPT          ║
║                                                               ║
║  🤖 WHAT THE AI SPIT OUT                                      ║
║  → Looks reasonable. Compiles. Probably has 3-5 bugs.        ║
║                                                               ║
║  🔍 YOUR JOB                                                  ║
║  → Find the bugs before they find you                        ║
║  → Explain WHY they're bugs (not just "it's wrong")          ║
║  → Fix them properly                                         ║
║                                                               ║
║  ✅ THE ANSWER KEY                                            ║
║  → What a senior sysadmin would have written                 ║
╚═══════════════════════════════════════════════════════════════╝
```

---

## EXERCIȚIU L1: Find Command Generator

### CERINȚĂ TRIMISĂ LA LLM

```
"Generate a find command that finds all .log files 
larger than 100MB, older than 30 days and deletes them 
to free up disk space."
```

### OUTPUT LLM

```bash
#!/bin/bash
# LLM generated:
find /var/log -name "*.log" -size +100M -mtime +30 -exec rm {} \;
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

#### Probleme Identificate:

| # | Problem | Risk | Severity |
|---|---------|------|----------|
| 1 | No `-type f` | May șterge directories named `*.log` | 🔴 High |
| 2 | Doesn't filter errors | Permission denied spam in output | 🟡 Medium |
| 3 | `-exec rm {} \;` without confirmation | Irreversible deletion | 🔴 High |
| 4 | Doesn't verify first what it deletes | Data loss | 🔴 High |
| 5 | Searches in /var/log which may have critical logs | May șterge audit logs | 🔴 High |
| 6 | `-exec {} \;` is inefficient | Starts one rm process per file | 🟡 Medium |

#### Cod Corectat:

```bash
# STEP 1: First verify WHAT it would șterge (DRY RUN)
find /var/log -type f -name "*.log" -size +100M -mtime +30 \
    -printf "%s %p\n" 2>/dev/null | sort -rn

# STEP 2: If the list is OK, șterge with confirmation
find /var/log -type f -name "*.log" -size +100M -mtime +30 \
    -ok rm {} \; 2>/dev/null

# OR for batch deletion (with prior verification):
find /var/log -type f -name "*.log" -size +100M -mtime +30 \
    -print0 2>/dev/null | xargs -0 rm -i

# SAFE VERSION FOR PRODUCTION:
find /var/log -type f -name "*.log" -size +100M -mtime +30 \
    ! -name "*.gz" \
    -exec mv {} /tmp/logs_to_delete/ \; 2>/dev/null
# Apoi verifici /tmp/logs_to_delete/ și ștergi manual
```

#### Întrebări de Clarificare Necesare:

1. "Are there logs that must NOT be deleted? (audit, security)"
2. "Should they be archived before deletion?"
3. "Running with root privileges or normal user?"
4. "Is this a production or test system?"

---

## EXERCIȚIU L2: Script cu getopts

### CERINȚĂ TRIMISĂ LA LLM

```
"Write a bash script that accepts -v for verbose,
-o for output file and processes files given as arguments."
```

### OUTPUT LLM

```bash
#!/bin/bash
# LLM generated:

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

#### Probleme Identificate:

| # | Line | Problem | explicație |
|---|------|---------|-------------|
| 1 | `for file in $@` | Missing quotes | Files with spaces break |
| 2 | `if [ $verbose == 1 ]` | `==` is for string, not number | Use `-eq` for numbers |
| 3 | `cat $file >> $output` | Without quotes | Problems with spaces |
| 4 | - | Missing `shift $((OPTIND-1))` | $@ includes options too! |
| 5 | - | Doesn't check if $output is set | If -o is missing, >> "" gives error |
| 6 | - | Doesn't check if files exist | cat on non-existent file = error |
| 7 | - | Missing help (-h) | Best practică |
| 8 | - | Doesn't handle invalid options | `?` in case |

#### Cod Corectat:

```bash
#!/bin/bash
# Correct and solid script

verbose=false
output=""

usage() {
    echo "Usage: $0 [-h] [-v] [-o output_file] files..."
    echo "  -h  Show help"
    echo "  -v  verbose mode"
    echo "  -o  Output file (required)"
    exit 1
}

# Option parsing
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
if [ ! -d "$PROJECT_DIR" ]; then
    echo "Eroare: '$PROJECT_DIR' nu există sau nu e director!" >&2
    exit 1
fi

echo "🔧 Fixing permissions in: $PROJECT_DIR"
echo "   Files: $FILE_PERM, Directories: $DIR_PERM"
[ "$DRY_RUN" = true ] && echo "   MODE: DRY RUN (no changes)"

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
"Generate a cron job that backs up the database daily 
at 2 AM and sends an email with the result."
```

### OUTPUT LLM

```bash
#!/bin/bash
# LLM generated:
0 2 * * * mysqldump mydb > /backup/db_$(date +%Y%m%d).sql && mail -s "backup OK" Issues: Open an issue in GitHub
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

#### Probleme Identificate:

| # | Problem | Why it doesn't work in cron |
|---|---------|----------------------------|
| 1 | `$(date +%Y%m%d)` | Cron uses /bin/sh, not bash. `$()` may not work in all shells |
| 2 | Relative paths | `mysqldump`, `mail` are not in cron's minimal PATH |
| 3 | `/backup/` | Directory may not exist or cron doesn't have permissions |
| 4 | `>` overwrites | If there are 2 backups on the same day, the second overwrites |
| 5 | `&&` ignores partial errors | If mysqldump fails, no error email is sent |
| 6 | No logging | You don't know if it ran or not |
| 7 | DB credentials | Where are user/pass for mysqldump? |

#### Cod Corectat:

```cron
# Corrected crontab - add at the beginning:
SHELL=/bin/bash
PATH=/usr/local/bin:/usr/bin:/bin
MAILTO=Issues: Open an issue in GitHub

# Backup zilnic la 2 AM
0 2 * * * /home/user/scripts/backup_db.sh >> /var/log/backup.log 2>&1
```

```bash
#!/bin/bash
# /home/user/scripts/backup_db.sh

# Configuration
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
"Write a script that sets correct permissions for 
a web project: files should be 644, directories 755."
```

### OUTPUT LLM

```bash
#!/bin/bash
# LLM generated:

chmod -R 644 /var/www/project
chmod -R 755 /var/www/project

echo "Permissions fixed!"
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

#### Problem Analysis:

```
Original script:
1. chmod -R 644 /var/www/project
   → ALL files AND directories become 644 (rw-r--r--)
   → Directories without x = you can't cd into them!

2. chmod -R 755 /var/www/project
   → OVERWRITES everything with 755 (rwxr-xr-x)
   → Now ALL files are executable!

RESULT: All files are 755, not 644!
        It's exactly the OPPOSITE of what we wanted.
```

#### Cod Corectat:

```bash
#!/bin/bash
# fix_permissions.sh - Corect și sigur

set -euo pipefail

# Configurări
REPORT_FILE="/tmp/security_audit_$(date +%Y%m%d_%H%M%S).txt"
EXCLUDE_PATHS="/proc|/sys|/run|/dev|/snap"

# Argument parsing
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

# Counting for report
file_count=0
dir_count=0

# Fix directories FIRST (to be able to access contents)
echo "📁 Setting directory permissions..."
while IFS= citește -r -d '' dir; do
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

# Verification
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
# Correct and concise version:
find /var/www/project -type d -exec chmod 755 {} +
find /var/www/project -type f -exec chmod 644 {} +

# SAU cu -R și X (execute doar pe directoare):
chmod -R u=rwX,g=rX,o=rX /var/www/project
```

---

## EXERCIȚIU L5: Security Checker

### CERINȚĂ TRIMISĂ LA LLM

```
"Write a script that checks if the system has security 
problems with file permissions."
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

## CHECKLIST EVALUARE OUTPUT LLM

### Când Primești Cod de la LLM, Verifică:

```
╔═══════════════════════════════════════════════════════════════╗
║  ✓ SECURITY                                                   ║
║    □ Validates input                                          ║
║    □ No injection vulnerabilities                             ║
║    □ Doesn't expose sensitive data                           ║
║    □ Uses absolute paths where necessary                     ║
║                                                               ║
║  ✓ CORRECTNESS                                                ║
║    □ Test with edge cases (spaces, special characters)       ║
║    □ Handles errors                                           ║
║    □ Does what it should (not what it seems)                 ║
║                                                               ║
║  ✓ ROBUSTNESS                                                 ║
║    □ Checks if files/directories exist                       ║
║    □ Has fallback for errors                                 ║
║    □ Doesn't overwrite data without confirmation             ║
║                                                               ║
║  ✓ EFFICIENCY                                                 ║
║    □ Doesn't launch unnecessary processes                    ║
║    □ Uses batch operations where possible                    ║
║    □ Avoids inefficient loops                                ║
║                                                               ║
║  ✓ BEST PRACTICES                                             ║
║    □ Has help/usage                                          ║
║    □ Has logging                                             ║
║    □ Has dry-run mode for dangerous operations               ║
║    □ Comments where necessary                                ║
╚═══════════════════════════════════════════════════════════════╝
```

---

*Document generated for UES Bucharest - CSIE | Operating Systems | Seminar 3*

---

## EXERCIȚIU L6: Arheologie Cod (Depanare Cod Legacy)

### SCOP

Acest exercițiu simulates a real-world SCENARIU: you inherit code from a colleague who left the company. Unlike LLM-generated code (which is usually syntactically correct) legacy code often has subtle bugs that accumulated over time.

**Why this is AI-resistant**: LLMs can fix obvious syntax errors but they struggle with:
- Understanding the INTENT behind buggy code
- Explaining WHY each change matters
- Recognising dangerous patterns that "work" in testing but fail in production

---

### SCENARIU

You received this script from a former colleague. It "works on their machine" but crashes randomly in production.

```bash
#!/bin/sh
# backup_old.sh - "DO NOT MODIFY" (comment from 2019)
# TODO: fix sometime

BACKUP_DIR=/backup
LOG=/tmp/backup.log

for f in `find /home -name "*.important"`; do
    cp $f $BACKUP_DIR
    echo "Copied $f" >> $LOG
done

rm /tmp/*.old
echo Done
```

### TASK STUDENT

```
═══════════════════════════════════════════════════════════════
🏛️ CODE ARCHAEOLOGY CHALLENGE

Analyse the script above and:

1. Identify MINIMUM 6 problems (security, robustness and style)
   Hint: not all problems are syntax errors

2. For each problem:
   - What can go wrong in production?
   - Would ChatGPT detect this problem? (yes/no/maybe)
   - How do you fix it?

3. Rewrite the script as a "production-ready" version

4. Bonus: What does the comment "DO NOT MODIFY" tell you about 
   that team's culture?

⏱️ Time: 15 minutes
═══════════════════════════════════════════════════════════════
```

### SOLUȚIE ȘI EXPLICAȚIE

#### Probleme Identificate:

| # | Line | Problem | Production Impact | ChatGPT Catches? |
|---|------|---------|-------------------|------------------|
| 1 | `#!/bin/sh` | POSIX shell not bash | Some bashisms might fail | ❌ No |
| 2 | `for f in \`find...\`` | Command substitution breaks on spaces | Files skipped or wrong | ✅ Yes |
| 3 | `cp $f $BACKUP_DIR` | Unquoted variables | Fails on spaces and glob expansion | ✅ Yes |
| 4 | No `-type f` in find | Might match directories | Silent failures | ⚠️ Maybe |
| 5 | `rm /tmp/*.old` | No check if files exist | mesaj de eroare noise | ⚠️ Maybe |
| 6 | No error handling | `set -e` missing | Continues after failures | ❌ No |
| 7 | Hardcoded paths | `/backup` might not exist | Fails on different servers | ❌ No |
| 8 | No lock file | Parallel runs corrupt backup | Data loss | ❌ No |
| 9 | `echo Done` not to stderr | Output mixed with data | Parsing issues | ❌ No |
| 10 | No timestamp in log | Cannot debug timing issues | Audit nightmare | ❌ No |

**Key insight**: ChatGPT catches the OBVIOUS problems (quoting and spaces) but misses the ARCHITECTURAL problems (no locking, no verification and hardcoded paths).

#### Production-Ready Version:

```bash
#!/bin/bash
#
# backup_improved.sh - Secure backup of important files
# Author: [Your name]
# Date: 2025
# 
# Usage: ./backup_improved.sh [--dry-run]
#

set -euo pipefail

# Configuration (poate fi overridden via environment)
BACKUP_DIR="${BACKUP_DIR:-/backup}"
SOURCE_DIR="${SOURCE_DIR:-/home}"
LOG_FILE="${LOG_FILE:-/var/log/backup_important.log}"
LOCK_FILE="/var/run/backup_important.lock"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

# Cleanup function
cleanup() {
    rm -f "$LOCK_FILE"
    log "backup process ended"
}
trap cleanup EXIT

# Check prerequisites
if [[ ! -d "$BACKUP_DIR" ]]; then
    log "ERROR: backup directory $BACKUP_DIR does not exist"
    exit 1
fi

# Acquire lock (prevent parallel runs)
if [[ -f "$LOCK_FILE" ]]; then
    log "ERROR: Another backup is running (lock file exists)"
    exit 1
fi
echo $$ > "$LOCK_FILE"

# Dry run mode
DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

log "Starting backup from $SOURCE_DIR to $BACKUP_DIR"
[[ "$DRY_RUN" == true ]] && log "rulare test MODE - no changes va fi made"

# Process files safely
count=0
while IFS= citește -r -d '' file; do
    if [[ "$DRY_RUN" == true ]]; then
        log "Would copy: $file"
    else
        if cp --preserve=all "$file" "$BACKUP_DIR/"; then
            log "Copied: $file"
            ((count++))
        else
            log "FAILED: $file"
        fi
    fi
done < <(find "$SOURCE_DIR" -type f -name "*.important" -print0 2>/dev/null)

log "backup complete. Files processed: $count"

# Optional cleanup (commented - uncomment if needed)
# find /tmp -name "*.old" -type f -mtime +7 -șterge 2>/dev/null || true
```

---

## EXERCIȚIU L7: Întrebări Capcană (Detectează Plauzibil dar Greșit)

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

### TRAP QUESTION T1

```
╔══════════════════════════════════════════════════════════════════╗
║  🪤 TRAP QUESTION #1                                              ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  A colleague shows you this "elegant" one-liner:                 ║
║                                                                  ║
║    find / -name "*.log" -delete 2>/dev/null                     ║
║                                                                  ║
║  What do you tell them?                                         ║
║                                                                  ║
║  A) "Excellent! Suppressing errors makes it cleaner"            ║
║  B) "Dangerous: deletes ALL .log files including critical ones" ║
║  C) "Does not work - -delete requires -depth"                   ║
║  D) "Needs sudo to actually delete system files"                ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

**Correct răspuns: B**

**Why each răspuns is wrong/right:**
- A: WRONG - LLMs often validate "correct syntax" without considering consequences
- B: CORRECT - This deletes /var/log/auth.log, /var/log/syslog and everything!
- C: WRONG - -șterge works without -depth (though -depth is recommended)
- D: WRONG - Without sudo it will not șterge system files but will șterge user logs

**Trap mechanism**: răspuns A sounds like something an LLM would say (focusing on code style rather than real-world impact).

---

### TRAP QUESTION T2

```
╔══════════════════════════════════════════════════════════════════╗
║  🪤 TRAP QUESTION #2                                              ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  Your script needs to process files from user input:             ║
║                                                                  ║
║    read -p "Enter filename: " filename                          ║
║    cat $filename | process_data                                  ║
║                                                                  ║
║  What is wrong?                                                  ║
║                                                                  ║
║  A) Should use printf instead of read                           ║
║  B) Useless use of cat - just use: process_data < $filename     ║
║  C) Missing quotes: cat "$filename"                             ║
║  D) Both B and C are correct                                    ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

**Correct răspuns: C** (though D is tempting!)

**Why:**
- A: WRONG - printf is for output not input
- B: PARTIAL - Yes UUOC exists but it is style not security
- C: CORRECT - Missing quotes = security vulnerability + breaks on spaces
- D: TRAP - B is style preference while C is security requirement. They are not equal.

**Why this is a trap**: LLMs love to say "both X and Y" to sound comprehensive. But in security there is a hierarchy: quotes are CRITICAL while UUOC is cosmetic.

---

### TRAP QUESTION T3

```
╔══════════════════════════════════════════════════════════════════╗
║  🪤 TRAP QUESTION #3                                              ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  This cron job runs at 2:30 AM but sometimes fails silently:    ║
║                                                                  ║
║    30 2 * * * /home/user/backup.sh                              ║
║                                                                  ║
║  What is the MOST LIKELY cause?                                 ║
║                                                                  ║
║  A) backup.sh uses relative paths that do not exist in cron     ║
║  B) 2:30 AM falls during DST transition in some months          ║
║  C) The script needs >> log 2>&1 to capture errors              ║
║  D) cron uses a different shell than your terminal              ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

**Correct răspuns: A**

**Analysis:**
- A: MOST LIKELY - Scripts that work interactively often use `cd`, `~` or commands without full path. Cron has minimal PATH and no user environment.
- B: Edge case - True but rare (only 1 hour/year)
- C: True but does not cause FAILURE, just hides errors
- D: True but usually not the cause of failure (sh vs bash)

**Trap mechanism**: All answers are partially true! The întrebare asks for MOST LIKELY which requires real-world experience to răspuns correctly.

---

## GHID DE VERIFICARE ANTI-AI

### Pentru Instructori: Cum să Verifici Înțelegerea Studenților

When reviewing temă use these probes:

1. **"Explain line X"** - Students who copied cannot explain their own code
2. **"What happens if..."** - Change one parameter and ask for prediction
3. **"Why not use Y instead?"** - Forces comparison of alternatives
4. **"What error would you get if..."** - Tests debugging knowledge

### Semne de Alarmă pentru Răspunsuri Generate de AI

| Pattern | exemplu | Why Suspicious |
|---------|---------|----------------|
| Overly comprehensive | Lists 10 options when 3 would suffice | AI tries to cover all bases |
| Perfect structure | Every răspuns has intro-body-conclusion | Humans are messier |
| No personal voice | No "I think" or "in my experience" | AI speaks impersonally |
| Correct but generic | "Use quotes for safety" without specific exemplu | AI gives textbook answers |
| Inconsistent depth | Some parts detailed, alții vague | AI loses context in long answers |

### Întrebări la Care Studenții Ar Trebui să Răspundă Live

If a student submitted correct temă they ar trebui să fie able to răspuns:

1. "Run your find command but change -mtime to -mmin. What changes?"
2. "Your script uses getopts 'hv:o:'. What does the second colon mean?"
3. "You set permissions 755. What happens if a file has 754?"
4. "Your job cron runs at */15. What times exactly?"

---

*Document generated for UES Bucharest - CSIE | Operating Systems | Seminar 3*  
*Enhanced with AI-resistance measures: January 2025*
