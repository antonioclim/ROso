# S06_00_README - Arhivă Teme Anterioare (Redistribuit)

> **Sisteme de Operare** | ASE București - CSIE
> Exemple de teme din anii anteriori pentru referință

---

## NOTĂ IMPORTANTĂ

Aceste exemple sunt pentru **referință și inspirație**. 
**NU copiați direct** - adaptați și personalizați!

---

## Cuprins

1. [HW01 - Monitor Simplu](#hw01---monitor-simplu)
2. [HW02 - Backup Basic](#hw02---backup-basic)
3. [HW03 - Log Analyzer](#hw03---log-analyzer)
4. [HW04 - File Organizer](#hw04---file-organizer)

---

## HW01 - Monitor Simplu

**Anul:** 2023-2024
**Cerință originală:** Crează un script care monitorizează CPU și memorie

### Soluție Student (Observație: 8/10)

```bash
#!/bin/bash
# monitor_simple.sh - Soluție student
# Cerință: Monitor CPU și memorie cu alertă

THRESHOLD_CPU=80
THRESHOLD_MEM=85

# Funcție pentru CPU
get_cpu() {
    top -bn1 | grep "Cpu(s)" | awk '{print $2}'
}

# Funcție pentru memorie
get_mem() {
    free | awk '/Mem:/ {printf "%.0f", $3/$2 * 100}'
}

# Verificări
cpu=$(get_cpu)
mem=$(get_mem)

echo "CPU: ${cpu}%"
echo "Memorie: ${mem}%"

# Alerte simple
if (( ${cpu%.*} > THRESHOLD_CPU )); then
    echo "ALERTA: CPU peste threshold!"
fi

if (( mem > THRESHOLD_MEM )); then
    echo "ALERTA: Memorie peste threshold!"
fi
```

### Feedback Instructor

**Puncte Forte:**
- Funcții separate pentru fiecare metrică
- Threshold-uri configurabile
- Output clar

**De îmbunătățit:**
- Lipsește `set -euo pipefail`
- Parsing CPU poate eșua pe alte distribuții
- Ar trebui logging în fișier
- Lipsește validare input
- Exit codes nepersonalizate

### Versiune Îmbunătățită

```bash
#!/usr/bin/env bash
# monitor_improved.sh - Versiune corectată
set -euo pipefail

readonly SCRIPT_NAME=$(basename "$0")
readonly LOG_FILE="/var/log/${SCRIPT_NAME%.sh}.log"
readonly THRESHOLD_CPU="${THRESHOLD_CPU:-80}"
readonly THRESHOLD_MEM="${THRESHOLD_MEM:-85}"

log() {
    printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" | tee -a "$LOG_FILE"
}

get_cpu() {
    # Metodă mai solidă folosind /proc/stat
    local cpu_line
    cpu_line=$(head -1 /proc/stat)
    
    local user nice system idle
    read -r _ user nice system idle _ <<< "$cpu_line"
    
    local total=$((user + nice + system + idle))
    local active=$((user + nice + system))
    
    echo $((active * 100 / total))
}

get_mem() {
    awk '/MemTotal:/ {total=$2} /MemAvailable:/ {avail=$2} 
         END {printf "%.0f", (1 - avail/total) * 100}' /proc/meminfo
}

main() {
    local cpu mem alerts=0
    
    cpu=$(get_cpu)
    mem=$(get_mem)
    
    log "CPU: ${cpu}% | Memorie: ${mem}%"
    
    if ((cpu > THRESHOLD_CPU)); then
        log "ALERTĂ: CPU ${cpu}% > ${THRESHOLD_CPU}%"
        ((alerts++))
    fi
    
    if ((mem > THRESHOLD_MEM)); then
        log "ALERTĂ: Memorie ${mem}% > ${THRESHOLD_MEM}%"
        ((alerts++))
    fi
    
    exit $alerts
}

main "$@"
```

---

## HW02 - Backup Basic

**Anul:** 2023-2024
**Cerință originală:** Script de backup cu compresie și rotație

### Soluție Student (Observație: 7/10)

```bash
#!/bin/bash
# backup.sh - Backup simplu

SOURCE=$1
DEST="/backup"
DATE=$(date +%Y%m%d)

# Creare backup
tar czf "$DEST/backup_$DATE.tar.gz" "$SOURCE"

# Ștergere backup-uri vechi
find "$DEST" -name "*.tar.gz" -mtime +7 -delete

echo "Backup complet!"
```

### Feedback Instructor

**Puncte Forte:**

Trei lucruri contează aici: simplu și funcțional, folosește date în numele fișierului, și rotație automată.


**De îmbunătățit:**
- Nu validează input-ul
- Nu verifică dacă sursa există
- Nu are error handling
- Nu verifică spațiu disponibil
- Hardcoded destination

### Versiune Îmbunătățită

```bash
#!/usr/bin/env bash
# backup_improved.sh - Versiune corectată
set -euo pipefail

readonly SCRIPT_NAME=$(basename "$0")

usage() {
    cat << EOF
Utilizare: $SCRIPT_NAME [OPȚIUNI] <sursă>

Opțiuni:
    -d, --dest DIR      Director destinație (default: /backup)
    -r, --retention N   Zile de păstrare (default: 7)
    -c, --compress ALG  Algoritm compresie: gz, bz2, xz (default: gz)
    -h, --help          Afișează acest mesaj
EOF
    exit "${1:-0}"
}

log() { printf '[%s] %s\n' "$(date '+%H:%M:%S')" "$*"; }
die() { log "EROARE: $*" >&2; exit 1; }

# Defaults
DEST="/backup"
RETENTION=7
COMPRESS="gz"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -d|--dest) DEST="$2"; shift 2 ;;
        -r|--retention) RETENTION="$2"; shift 2 ;;
        -c|--compress) COMPRESS="$2"; shift 2 ;;
        -h|--help) usage ;;
        -*) die "Opțiune necunoscută: $1" ;;
        *) break ;;
    esac
done

SOURCE="${1:?Specifică directorul sursă}"

# Validări
[[ -d "$SOURCE" ]] || die "Sursa nu există: $SOURCE"
[[ -d "$DEST" ]] || mkdir -p "$DEST"

# Verificare spațiu
source_size=$(du -s "$SOURCE" | awk '{print $1}')
dest_avail=$(df "$DEST" | awk 'NR==2 {print $4}')
((dest_avail > source_size * 2)) || die "Spațiu insuficient în $DEST"

# Selectare extensie compresie
case "$COMPRESS" in
    gz)  TAR_OPT="z"; EXT="tar.gz" ;;
    bz2) TAR_OPT="j"; EXT="tar.bz2" ;;
    xz)  TAR_OPT="J"; EXT="tar.xz" ;;
    *)   die "Compresie necunoscută: $COMPRESS" ;;
esac

# Creare backup
BACKUP_FILE="$DEST/backup_$(date +%Y%m%d_%H%M%S).$EXT"
log "Creare backup: $BACKUP_FILE"

if tar c${TAR_OPT}f "$BACKUP_FILE" -C "$(dirname "$SOURCE")" "$(basename "$SOURCE")"; then
    log "Backup creat: $(du -h "$BACKUP_FILE" | cut -f1)"
else
    die "Backup eșuat"
fi

# Rotație
deleted=$(find "$DEST" -name "backup_*.$EXT" -mtime +"$RETENTION" -delete -print | wc -l)
log "Șterse $deleted backup-uri vechi"

log "Backup complet!"
```

---

## HW03 - Log Analyzer

**Anul:** 2022-2023
**Cerință originală:** Analizează fișiere de log și generează raport

### Soluție Student (Observație: 9/10)

```bash
#!/usr/bin/env bash
# log_analyzer.sh - Analizator log-uri
set -euo pipefail

LOG_FILE="${1:?Specifică fișierul de log}"

[[ -f "$LOG_FILE" ]] || { echo "Fișier inexistent: $LOG_FILE"; exit 1; }

echo "=== Analiza: $LOG_FILE ==="
echo ""

# Total linii
total=$(wc -l < "$LOG_FILE")
echo "Total intrări: $total"
echo ""

# Erori
echo "=== ERORI ==="
errors=$(grep -ci "error\|fail\|critical" "$LOG_FILE" || true)
echo "Erori găsite: $errors"

if ((errors > 0)); then
    echo "Top 5 erori:"
    grep -i "error\|fail\|critical" "$LOG_FILE" | 
        awk '{print $NF}' | 
        sort | uniq -c | sort -rn | head -5
fi
echo ""

# Warnings
echo "=== WARNINGS ==="
warnings=$(grep -ci "warn" "$LOG_FILE" || true)
echo "Warnings găsite: $warnings"
echo ""

# Top IPs (dacă e log web)
echo "=== TOP IPs ==="
grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' "$LOG_FILE" 2>/dev/null |
    sort | uniq -c | sort -rn | head -10 || echo "Nu s-au găsit IP-uri"
echo ""

# Distribuție pe ore
echo "=== DISTRIBUȚIE PE ORE ==="
grep -oE '[0-9]{2}:[0-9]{2}:[0-9]{2}' "$LOG_FILE" 2>/dev/null |
    cut -d: -f1 | sort | uniq -c | sort -k2n || echo "Nu s-au găsit timestamp-uri"

echo ""
echo "=== Analiză completă ==="
```

### Feedback Instructor

**Puncte Forte:**
- Structură clară
- Multiple analize utile
- Handling pentru cazul când nu găsește pattern-uri
- `set -euo pipefail`

**De îmbunătățit:**

Trei lucruri contează aici: ar putea genera output html/json, lipșesc grafice ascii, și ar putea fi parametrizabil (care patterns să caute).


---

## HW04 - File Organizer

**Anul:** 2022-2023  
**Cerință originală:** Organizează fișiere după extensie/dată

### Soluție Student (Observație: 6/10)

```bash
#!/bin/bash
# organize.sh - Organizator fișiere

DIR=$1

for file in "$DIR"/*; do
    ext="${file##*.}"
    mkdir -p "$DIR/$ext"
    mv "$file" "$DIR/$ext/"
done

echo "Done!"
```

### Feedback Instructor

**Probleme Majore:**
1. Mută și directoarele (ar trebui `-f` check)
2. Nu gestionează fișiere fără extensie
3. Nu gestionează conflicte de nume
4. Mută și fișierele ascunse
5. Nu are dry-run mode
6. Feedback minim

### Versiune Îmbunătățită

```bash
#!/usr/bin/env bash
# organize_improved.sh - Organizator fișiere îmbunătățit
set -euo pipefail

usage() {
    cat << EOF
Utilizare: $(basename "$0") [OPȚIUNI] <director>

Opțiuni:
    -m, --mode MODE     Mod organizare: ext|date|size (default: ext)
    -n, --dry-run       Simulare, nu mută fișiere
    -v, --verbose       Output detaliat
    -h, --help          Afișează acest mesaj
    
Exemple:
    $(basename "$0") ~/Downloads
    $(basename "$0") -m date -n ~/Pictures
EOF
    exit "${1:-0}"
}

log() { echo "[$(date '+%H:%M:%S')] $*"; }
verbose() { [[ "$VERBOSE" == true ]] && log "$*" || true; }

# Defaults
MODE="ext"
DRY_RUN=false
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        -m|--mode) MODE="$2"; shift 2 ;;
        -n|--dry-run) DRY_RUN=true; shift ;;
        -v|--verbose) VERBOSE=true; shift ;;
        -h|--help) usage ;;
        -*) echo "Opțiune necunoscută: $1" >&2; usage 1 ;;
        *) break ;;
    esac
done

DIR="${1:?Specifică directorul}"
[[ -d "$DIR" ]] || { echo "Director inexistent: $DIR"; exit 1; }

# Funcții pentru determinare categorie
get_ext_category() {
    local file="$1"
    local ext="${file##*.}"
    
    # Fișiere fără extensie
    [[ "$ext" == "$file" ]] && echo "no_extension" && return
    
    # Lowercase
    ext="${ext,,}"
    
    case "$ext" in
        jpg|jpeg|png|gif|bmp|svg|webp) echo "images" ;;
        mp3|wav|flac|ogg|m4a) echo "audio" ;;
        mp4|avi|mkv|mov|wmv) echo "video" ;;
        pdf|doc|docx|xls|xlsx|ppt|pptx|odt) echo "documents" ;;
        zip|tar|gz|rar|7z) echo "archives" ;;
        sh|py|js|c|cpp|java|go|rs) echo "code" ;;
        *) echo "other_$ext" ;;
    esac
}

get_date_category() {
    local file="$1"
    stat -c %y "$file" | cut -d' ' -f1 | tr -d '-'
}

get_size_category() {
    local file="$1"
    local size
    size=$(stat -c %s "$file")
    
    if ((size < 1024)); then
        echo "tiny_under_1K"
    elif ((size < 1048576)); then
        echo "small_under_1M"
    elif ((size < 104857600)); then
        echo "medium_under_100M"
    else
        echo "large_over_100M"
    fi
}

# Procesare
moved=0
skipped=0

shopt -s nullglob  # Nu expanda glob la literalul dacă nu match
for file in "$DIR"/*; do
    # Skip directoare
    [[ -f "$file" ]] || continue
    
    # Skip fișiere ascunse
    [[ "$(basename "$file")" == .* ]] && continue
    
    # Determinare categorie
    case "$MODE" in
        ext) category=$(get_ext_category "$file") ;;
        date) category=$(get_date_category "$file") ;;
        size) category=$(get_size_category "$file") ;;
        *) echo "Mod necunoscut: $MODE"; exit 1 ;;
    esac
    
    dest_dir="$DIR/$category"
    dest_file="$dest_dir/$(basename "$file")"
    
    # Handling conflicte
    if [[ -e "$dest_file" ]]; then
        base="${dest_file%.*}"
        ext="${dest_file##*.}"
        counter=1
        while [[ -e "${base}_${counter}.${ext}" ]]; do
            ((counter++))
        done
        dest_file="${base}_${counter}.${ext}"
    fi
    
    verbose "  $file -> $dest_file"
    
    if [[ "$DRY_RUN" == false ]]; then
        mkdir -p "$dest_dir"
        mv "$file" "$dest_file"
        ((moved++))
    else
        ((moved++))  # Count pentru dry-run
    fi
done

log "Organizare completă: $moved fișiere procesate"
[[ "$DRY_RUN" == true ]] && log "(DRY-RUN - nimic nu a fost mutat)"
```

---

## Lecții Învățate din Greșeli Comune

### 1. Quoting și Word Splitting
```bash
# GREȘIT
for file in $(ls *.txt); do ...

# CORECT
for file in *.txt; do
    [[ -e "$file" ]] || continue
    ...
done
```

### 2. Variabile Nevalidate
```bash
# GREȘIT
rm -rf $DIR/*

# CORECT
[[ -n "$DIR" && -d "$DIR" ]] || exit 1
rm -rf "${DIR:?}"/*
```

### 3. Lipsa Error Handling
```bash
# GREȘIT
tar czf backup.tar.gz /data
echo "Done!"

# CORECT
if ! tar czf backup.tar.gz /data 2>/dev/null; then
    echo "Backup EȘUAT!" >&2
    exit 1
fi
echo "Backup complet"
```

### 4. Hardcoded Paths
```bash
# GREȘIT
LOG_FILE="/home/student/logs/app.log"

# CORECT
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_FILE="${LOG_DIR:-$SCRIPT_DIR/logs}/app.log"
```

### 5. Ignorarea Exit Codes
```bash
# GREȘIT
command
echo "Continuăm..."

# CORECT
if ! command; then
    echo "Command a eșuat" >&2
    exit 1
fi
```

---

*Arhivă Teme Anterioare | Sisteme de Operare | ASE București - CSIE*

---

*By Revolvix for OPERATING SYSTEMS class | restricted licence 2017-2030*
