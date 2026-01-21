# Cheat Sheet - Bash Scripting Profesional

> **Sisteme de Operare** | ASE București - CSIE
> Seminar 11-12: CAPSTONE Projects

---

## Structură Script Profesional

```bash
#!/usr/bin/env bash
#
# script_name.sh - Descriere scurtă
# Autor: Nume | Data: YYYY-MM-DD
#

set -euo pipefail
IFS=$'\n\t'

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_NAME="$(basename "$0")"

# === CONFIGURARE ===
readonly LOG_FILE="${LOG_FILE:-/var/log/${SCRIPT_NAME%.sh}.log}"
readonly CONFIG_FILE="${CONFIG_FILE:-/etc/${SCRIPT_NAME%.sh}.conf}"

# === FUNCȚII UTILITARE ===
log() {
    local level="${1:-INFO}"
    shift
    printf '[%s] [%-5s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$level" "$*" | tee -a "$LOG_FILE"
}

die() {
    log "FATAL" "$*"
    exit 1
}

cleanup() {
    # Eliberare resurse
    rm -f "$TEMP_FILE" 2>/dev/null || true
}

trap cleanup EXIT INT TERM

usage() {
    cat << EOF
Utilizare: $SCRIPT_NAME [OPȚIUNI] <argumente>

Descriere...

Opțiuni:
    -h, --help      Afișează acest mesaj
    -v, --verbose   Mod verbose
    -c FILE         Fișier configurare

Exemple:
    $SCRIPT_NAME -v /path/to/dir
    $SCRIPT_NAME --help
EOF
}

main() {
    # Parsare argumente
    # Validare
    # Logică principală
    :
}

main "$@"
```

---

## Variabile

### Declarare și Atribuire
```bash
var="valoare"              # Fără spații în jurul =
readonly CONST="fix"       # Constantă (nu poate fi modificată)
local var="doar în funcție" # Doar în funcții
declare -i num=10          # Integer
declare -a arr=()          # Array indexat
declare -A map=()          # Array asociativ
```

### Expansion
```bash
${var}                     # Valoare (sigur în stringuri)
${var:-default}            # Default dacă unset/null
${var:=default}            # Setează default dacă unset/null
${var:?error message}      # Eroare dacă unset/null
${var:+alternate}          # Alternate dacă setat

${#var}                    # Lungime string
${var%pattern}             # Șterge suffix (cel mai scurt match)
${var%%pattern}            # Șterge suffix (cel mai lung match)
${var#pattern}             # Șterge prefix (cel mai scurt match)
${var##pattern}            # Șterge prefix (cel mai lung match)

${var/pattern/replacement} # Prima înlocuire
${var//pattern/replacement} # Toate înlocuirile
${var^}                    # Prima literă uppercase
${var^^}                   # Tot uppercase
${var,}                    # Prima literă lowercase
${var,,}                   # Tot lowercase
```

### Variabile Speciale
```bash
$0                         # Numele scriptului
$1, $2, ..., ${10}         # Argumente poziționale
$#                         # Număr argumente
$@                         # Toate argumentele (separate)
$*                         # Toate argumentele (un string)
"$@"                       # CORECT: păstrează quoting
$$                         # PID proces curent
$!                         # PID ultimul proces background
$?                         # Exit code ultimei comenzi
$_                         # Ultimul argument comandă anterioară
```

---

## Structuri de Control

### Condiții
```bash
# Sintaxa [[ ]] (preferată - mai sigură)
if [[ condition ]]; then
    commands
elif [[ other_condition ]]; then
    commands
else
    commands
fi

# Comparații string
[[ "$a" == "$b" ]]         # Egal
[[ "$a" != "$b" ]]         # Diferit
[[ "$a" < "$b" ]]          # Lexicografic mai mic
[[ "$a" =~ regex ]]        # Regex match
[[ -z "$a" ]]              # String gol
[[ -n "$a" ]]              # String non-gol

# Comparații numerice
[[ $a -eq $b ]]            # Egal
[[ $a -ne $b ]]            # Diferit
[[ $a -lt $b ]]            # Mai mic
[[ $a -le $b ]]            # Mai mic sau egal
[[ $a -gt $b ]]            # Mai mare
[[ $a -ge $b ]]            # Mai mare sau egal

# Arithmetic (preferă (( )) pentru numere)
(( a == b ))
(( a < b ))
(( a++ ))
(( total = a + b * c ))

# Fișiere
[[ -e "$file" ]]           # Există
[[ -f "$file" ]]           # Fișier regular
[[ -d "$dir" ]]            # Director
[[ -r "$file" ]]           # Readable
[[ -w "$file" ]]           # Writable
[[ -x "$file" ]]           # Executable
[[ -s "$file" ]]           # Non-zero size
[[ "$a" -nt "$b" ]]        # a mai nou decât b
[[ "$a" -ot "$b" ]]        # a mai vechi decât b

# Operatori logici
[[ cond1 && cond2 ]]       # AND
[[ cond1 || cond2 ]]       # OR
[[ ! condition ]]          # NOT
```

### Bucle
```bash
# For (C-style)
for ((i=0; i<10; i++)); do
    echo "$i"
done

# For (listă)
for item in "${array[@]}"; do
    echo "$item"
done

# For (fișiere - CORECT)
for file in /path/*.txt; do
    [[ -e "$file" ]] || continue
    process "$file"
done

# While
while [[ condition ]]; do
    commands
done

# While read (citire fișier/output)
while IFS= read -r line; do
    echo "Linie: $line"
done < "$file"

# Until
until [[ condition ]]; do
    commands
done

# Break/Continue
break                      # Ieși din buclă
continue                   # Salt la iterația următoare
```

### Case
```bash
case "$var" in
    pattern1)
        commands
        ;;
    pattern2|pattern3)
        commands
        ;;
    *)
        # default
        ;;
esac
```

---

## Funcții

```bash
# Declarare
function_name() {
    local arg1="${1:?Argument 1 obligatoriu}"
    local arg2="${2:-default}"
    
    # Logică
    
    return 0  # sau alt exit code
}

# Apel
result=$(function_name "val1" "val2")
function_name "val1" "val2"
exit_code=$?

# Output multiplu (folosind array)
get_data() {
    local -n result_ref=$1  # nameref (Bash 4.3+)
    result_ref=("item1" "item2" "item3")
}

declare -a data
get_data data
echo "${data[@]}"
```

---

## Arrays

### Array Indexat
```bash
# Declarare
declare -a arr=()
arr=("elem1" "elem2" "elem3")
arr[0]="first"

# Acces
echo "${arr[0]}"           # Element specific
echo "${arr[@]}"           # Toate elementele
echo "${#arr[@]}"          # Număr elemente
echo "${!arr[@]}"          # Toți indicii

# Iterare
for item in "${arr[@]}"; do
    echo "$item"
done

# Slice
echo "${arr[@]:1:2}"       # De la index 1, 2 elemente

# Adăugare
arr+=("new_element")
```

### Array Asociativ (Hash/Map)
```bash
# Declarare (obligatoriu declare -A)
declare -A map=()
map=([key1]="value1" [key2]="value2")
map["key3"]="value3"

# Acces
echo "${map[key1]}"
echo "${map[@]}"           # Toate valorile
echo "${!map[@]}"          # Toate cheile
echo "${#map[@]}"          # Număr perechi

# Verificare cheie
if [[ -v map[key1] ]]; then
    echo "Key exists"
fi

# Iterare
for key in "${!map[@]}"; do
    echo "$key -> ${map[$key]}"
done
```

---

## I/O și Redirectări

```bash
# Redirectări de bază
command > file             # Stdout în fișier (overwrite)
command >> file            # Stdout în fișier (append)
command 2> file            # Stderr în fișier
command &> file            # Stdout + stderr în fișier
command > file 2>&1        # Echivalent (portabil)

# Pipe
command1 | command2        # Stdout cmd1 -> stdin cmd2
command1 |& command2       # Stdout + stderr -> stdin

# Process substitution
diff <(command1) <(command2)
while read line; do ... done < <(command)

# Here-doc
cat << 'EOF'
Text literal $var nu se expandează
EOF

cat << EOF
Text cu expansiune: $var
EOF

# Here-string
command <<< "string input"

# File descriptors
exec 3> outfile            # Deschide FD 3 pentru scriere
echo "text" >&3            # Scrie pe FD 3
exec 3>&-                  # Închide FD 3

exec 4< infile             # Deschide FD 4 pentru citire
read line <&4              # Citește din FD 4
exec 4<&-                  # Închide FD 4
```

---

## Procesare Text

### Grep
```bash
grep "pattern" file        # Linii care conțin pattern
grep -i "pattern" file     # Case insensitive
grep -v "pattern" file     # Linii care NU conțin
grep -E "regex" file       # Extended regex
grep -o "pattern" file     # Doar partea care matchează
grep -c "pattern" file     # Numără matchuri
grep -n "pattern" file     # Cu numere linie
grep -r "pattern" dir/     # Recursiv în director
grep -l "pattern" files    # Doar numele fișierelor
```

### Sed
```bash
sed 's/old/new/' file      # Prima înlocuire per linie
sed 's/old/new/g' file     # Toate înlocuirile
sed -i 's/old/new/g' file  # In-place edit
sed -n '5p' file           # Printează doar linia 5
sed -n '5,10p' file        # Linii 5-10
sed '5d' file              # Șterge linia 5
sed '/pattern/d' file      # Șterge linii cu pattern
sed 's/.*://' file         # Șterge până la :
```

### Awk
```bash
awk '{print $1}' file      # Prima coloană
awk '{print $NF}' file     # Ultima coloană
awk -F: '{print $1}' file  # Separator : 
awk '/pattern/' file       # Linii cu pattern
awk 'NR==5' file           # Linia 5
awk 'NR>=5 && NR<=10' file # Linii 5-10
awk '{sum+=$1} END{print sum}' file  # Sumă coloană
awk '{print NR": "$0}' file # Numerotare linii

# Awk complex
awk '
BEGIN { FS=":"; OFS="\t" }
/pattern/ { count++; print $1, $3 }
END { print "Total:", count }
' file
```

### Cut, Sort, Uniq
```bash
cut -d: -f1 file           # Coloana 1, separator :
cut -c1-10 file            # Caractere 1-10

sort file                  # Sort alfabetic
sort -n file               # Sort numeric
sort -r file               # Reverse
sort -k2 file              # După coloana 2
sort -t: -k3 -n file       # Coloana 3, separator :, numeric
sort -u file               # Unique (ca sort | uniq)

uniq file                  # Elimină duplicate consecutive
uniq -c file               # Cu numărătoare
uniq -d file               # Doar duplicatele
```

---

## Error Handling

```bash
# Set options
set -e                     # Exit la prima eroare
set -u                     # Eroare pentru variabile undefined
set -o pipefail            # Propagă erori din pipe
set -x                     # Debug mode (afișează comenzi)

# Trap
trap 'cleanup' EXIT        # La ieșire normală
trap 'cleanup' INT TERM    # La SIGINT (Ctrl+C), SIGTERM
trap 'echo "Error line $LINENO"' ERR  # La eroare

# Error handling pattern
command || {
    log "ERROR" "Command failed"
    exit 1
}

# Sau cu if
if ! command; then
    log "ERROR" "Command failed"
    exit 1
fi

# Retry pattern
retry() {
    local max_attempts="${1:-3}"
    local delay="${2:-5}"
    local attempt=1
    shift 2
    
    until "$@"; do
        if ((attempt >= max_attempts)); then
            log "ERROR" "Failed after $max_attempts attempts"
            return 1
        fi
        log "WARN" "Attempt $attempt failed, retrying in ${delay}s..."
        sleep "$delay"
        ((attempt++))
    done
}

# Utilizare
retry 5 10 curl -f "$url"
```

---

## Parsing Argumente

### Getopts (POSIX, recomandat)
```bash
usage() {
    echo "Usage: $0 [-v] [-c config] [-n num] file..."
    exit 1
}

verbose=false
config=""
num=10

while getopts ":vc:n:h" opt; do
    case $opt in
        v) verbose=true ;;
        c) config="$OPTARG" ;;
        n) num="$OPTARG" ;;
        h) usage ;;
        :) echo "Option -$OPTARG requires argument" >&2; usage ;;
        \?) echo "Invalid option: -$OPTARG" >&2; usage ;;
    esac
done

shift $((OPTIND - 1))
files=("$@")
```

### Long Options Manual
```bash
while [[ $# -gt 0 ]]; do
    case "$1" in
        -v|--verbose)
            verbose=true
            shift
            ;;
        -c|--config)
            config="$2"
            shift 2
            ;;
        -n|--number)
            num="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        --)
            shift
            break
            ;;
        -*)
            echo "Unknown option: $1" >&2
            usage
            ;;
        *)
            break
            ;;
    esac
done

files=("$@")
```

---

## Debugging

```bash
# Activare debug
set -x                     # Începe trace
set +x                     # Oprește trace

bash -x script.sh          # Rulează cu trace
bash -n script.sh          # Syntax check (nu execută)
bash -v script.sh          # Afișează linii înainte de execuție

# Debug selectiv
debug() {
    [[ "$DEBUG" == "true" ]] && echo "DEBUG: $*" >&2
}

# Trace funcții
set -o functrace           # Trap-urile se moștenesc în funcții

# Logging detaliat
PS4='+ ${BASH_SOURCE}:${LINENO}:${FUNCNAME[0]:-main}: '
set -x

# Assert
assert() {
    local condition="$1"
    local message="${2:-Assertion failed}"
    
    if ! eval "$condition"; then
        echo "ASSERT FAILED: $message" >&2
        echo "  Condition: $condition" >&2
        echo "  Location: ${BASH_SOURCE[1]}:${BASH_LINENO[0]}" >&2
        exit 1
    fi
}

assert '[[ -f "$config_file" ]]' "Config file must exist"
```

---

## Networking

```bash
# Curl
curl -s "$url"             # Silent
curl -f "$url"             # Fail on HTTP error
curl -o file "$url"        # Save to file
curl -I "$url"             # Headers only
curl -X POST -d "data" "$url"  # POST request
curl -H "Authorization: Bearer $token" "$url"  # Custom header

# Check port
nc -zv host port           # TCP check
timeout 5 bash -c "</dev/tcp/host/port" && echo "Open"

# Get IPs
hostname -I                # All IPs
ip addr show | grep 'inet '

# Download with wget
wget -q "$url" -O file     # Quiet, output to file
wget -c "$url"             # Continue interrupted download
```

---

## Security Best Practices

```bash
# 1. Quoting - ÎNTOTDEAUNA quote variabilele
rm "$file"                 # CORECT
rm $file                   # GREȘIT - word splitting

# 2. Validare input
[[ "$input" =~ ^[a-zA-Z0-9_]+$ ]] || die "Invalid input"

# 3. Temp files sigure
temp_file=$(mktemp)
trap 'rm -f "$temp_file"' EXIT

# 4. Evită eval
# GREȘIT
eval "$user_input"

# 5. Folosește arrays pentru comenzi cu argumente
cmd=("command" "--arg1" "--arg2" "$variable")
"${cmd[@]}"

# 6. Setează PATH explicit
PATH="/usr/local/bin:/usr/bin:/bin"
export PATH

# 7. Nu stoca parole în scripturi
password=$(cat /secure/path/password_file)
# sau
read -s -p "Password: " password
```

---

## /proc Filesystem

```bash
# CPU
cat /proc/cpuinfo
cat /proc/stat             # CPU times
grep "cpu " /proc/stat | awk '{u=$2+$4; t=$2+$4+$5; print u/t*100"%"}'

# Memory
cat /proc/meminfo
free -h
awk '/MemTotal|MemFree|MemAvailable/' /proc/meminfo

# Process info
cat /proc/$$/status        # Status proces curent
cat /proc/$$/cmdline       # Command line
ls -la /proc/$$/fd/        # File descriptors
cat /proc/$$/limits        # Limits

# System
cat /proc/loadavg          # Load average
cat /proc/uptime           # Uptime
cat /proc/version          # Kernel version

# Disk
cat /proc/diskstats
cat /proc/mounts
```

---

## Cron & Systemd

### Cron
```bash
# Format: min hour day month weekday command
# Editare: crontab -e

# Exemple
*/5 * * * *   command       # La fiecare 5 minute
0 3 * * *     command       # Zilnic la 3:00
0 0 * * 0     command       # Duminica la miezul nopții
0 0 1 * *     command       # Prima zi din lună

# Best practices
SHELL=/bin/bash
PATH=/usr/local/bin:/usr/bin:/bin
MAILTO=admin@example.com

0 3 * * * /path/script.sh >> /var/log/script.log 2>&1
```

### Systemd Service
```ini
# /etc/systemd/system/myservice.service
[Unit]
Description=My Service
After=network.target

[Service]
Type=simple
User=myuser
WorkingDirectory=/opt/myapp
ExecStart=/opt/myapp/start.sh
ExecStop=/opt/myapp/stop.sh
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

### Systemd Timer
```ini
# /etc/systemd/system/myservice.timer
[Unit]
Description=Run My Service Daily

[Timer]
OnCalendar=daily
OnCalendar=*-*-* 03:00:00
Persistent=true

[Install]
WantedBy=timers.target
```

```bash
systemctl daemon-reload
systemctl enable myservice.timer
systemctl start myservice.timer
systemctl list-timers
```

---

## Quick Reference - Comenzi Frecvente

```bash
# Fișiere și directoare
find . -name "*.log" -mtime +7 -delete
find . -type f -exec chmod 644 {} \;
du -sh */                  # Dimensiune directoare
tree -L 2                  # Arbore 2 nivele

# Procese
ps aux | grep process
pgrep -f "pattern"
pkill -f "pattern"
kill -9 $pid
nohup command &

# Disk
df -h                      # Spațiu disk
du -sh *                   # Dimensiune fișiere/dirs
lsblk                      # Block devices
mount | grep /dev

# Networking
ss -tlnp                   # Listening ports
netstat -an | grep LISTEN
ip route                   # Routing table
dig domain.com             # DNS lookup

# Utilizatori
id                         # Current user info
whoami                     # Username
groups                     # Groups
sudo -l                    # Sudo permissions

# System
uname -a                   # System info
lsb_release -a            # Distribution info
uptime                     # Uptime + load
dmesg | tail               # Kernel messages
journalctl -xe             # System logs
```

---

*Cheat Sheet pentru Sisteme de Operare | ASE București - CSIE*
*Versiunea 1.0 | Seminar 11-12 CAPSTONE*
