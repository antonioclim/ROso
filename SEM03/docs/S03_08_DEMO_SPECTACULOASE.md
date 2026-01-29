# Demo-uri Spectaculoase - Seminarul 03
## Sisteme de Operare | Demonstrații Vizuale pentru Engagement

**Scop**: Captarea atenției și demonstrarea puterii conceptelor
Când: Hook la început, tranziții între secțiuni, moment "wow"
**Principiu**: "Arată, nu spune" - vizual > verbal

---

## LISTA DEMO-URI

| Demo | Moment | Durată | Impact |
|------|--------|--------|--------|
| D1: File System Explorer | Hook Seminar | 2 min | 🔥🔥🔥 |
| D2: Permission Visualizer | După teorie permisiuni | 3 min | 🔥🔥 |
| D3: Live Cron Monitor | Secțiunea cron | 2 min | 🔥🔥 |
| D4: Disk Space Analyzer | Oricând | 2 min | 🔥🔥🔥 |
| D5: Security Audit Live | Final seminar | 3 min | 🔥🔥🔥 |
| D6: Process Tree Visualizer | Opțional | 2 min | 🔥 |

---

## D1: FILE SYSTEM EXPLORER (Hook Demo)

### Scop
Demonstrează puterea lui `find` într-un one-liner spectaculos care analizează sistemul.

### Scriptul

```bash
#!/bin/bash
# S03_01_hook_demo.sh - File System Explorer
# Descoperă secrete ascunse în sistemul de fișiere!

clear

# Culori
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

# Animație titlu
echo -e "${CYAN}"
cat << "EOF"
    ╔═══════════════════════════════════════════════════════════╗
    ║     🔍 FILE SYSTEM EXPLORER - Powered by FIND 🔍         ║

*(`find` combinat cu `-exec` e extrem de util. Odată ce-l stăpânești, nu mai poți fără el.)*

    ╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"
sleep 1

# Funcție animație typing
type_text() {
    local text="$1"
    local delay="${2:-0.02}"
    for ((i=0; i<${#text}; i++)); do
        echo -n "${text:$i:1}"
        sleep $delay
    done
    echo ""
}

# Demo 1: Statistici rapide
echo -e "\n${BOLD}${YELLOW}▸ Analyzing your file system...${NC}\n"
sleep 0.5

echo -e "${PURPLE}📊 Quick Statistics:${NC}"
echo -n "   Total files:      "
find /usr -type f 2>/dev/null | wc -l | xargs printf "%'d\n"
echo -n "   Total directories: "
find /usr -type d 2>/dev/null | wc -l | xargs printf "%'d\n"
echo -n "   Symbolic links:    "
find /usr -type l 2>/dev/null | wc -l | xargs printf "%'d\n"
sleep 1

# Demo 2: Top 10 cele mai mari fișiere
echo -e "\n${PURPLE}📦 Top 10 Largest Files in /usr:${NC}"
echo -e "${CYAN}───────────────────────────────────────────────────${NC}"
find /usr -type f -printf '%s %p\n' 2>/dev/null | \
    sort -rn | head -10 | \
    while read size path; do
        size_mb=$(echo "scale=2; $size/1048576" | bc)
        bar_len=$(echo "$size_mb / 5" | bc)
        bar=$(printf '█%.0s' $(seq 1 $bar_len 2>/dev/null) 2>/dev/null || echo "█")
        printf "   ${GREEN}%8.2f MB${NC} │ ${YELLOW}%-20s${NC} │ %s\n" \
            "$size_mb" "$bar" "$(basename "$path")"
        sleep 0.1
    done

# Demo 3: Fișiere recente
echo -e "\n${PURPLE}🕐 Files Modified in Last Hour:${NC}"
recent_count=$(find /var/log -type f -mmin -60 2>/dev/null | wc -l)
echo -e "   Found ${GREEN}$recent_count${NC} recently modified files"
find /var/log -type f -mmin -60 -printf '   %TH:%TM  %p\n' 2>/dev/null | head -5
sleep 1

# Demo 4: Distribuție extensii
echo -e "\n${PURPLE}📁 File Type Distribution:${NC}"
echo -e "${CYAN}───────────────────────────────────────────────────${NC}"
find /usr/share -type f -name "*.*" 2>/dev/null | \
    sed 's/.*\.//' | sort | uniq -c | sort -rn | head -8 | \
    while read count ext; do
        bar_len=$((count / 100))
        [ $bar_len -gt 30 ] && bar_len=30
        bar=$(printf '▓%.0s' $(seq 1 $bar_len))
        printf "   ${GREEN}%-6s${NC} │ %5d │ ${BLUE}%s${NC}\n" ".$ext" "$count" "$bar"

> 💡 *Am avut studenți care au învățat Bash în două săptămâni pornind de la zero — se poate, cu practică consistentă.*

        sleep 0.05
    done

# Final
echo -e "\n${CYAN}"
cat << "EOF"
    ╔═══════════════════════════════════════════════════════════╗
    ║  ✨ All of this with just ONE command: find              ║
    ║     Today we'll master this powerful tool!               ║
    ╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"
```

### Output Așteptat

```
╔═══════════════════════════════════════════════════════════╗
║     🔍 FILE SYSTEM EXPLORER - Powered by FIND 🔍         ║
╚═══════════════════════════════════════════════════════════╝

▸ Analyzing your file system...

📊 Quick Statistics:
   Total files:      123,456
   Total directories: 12,345
   Symbolic links:    1,234

📦 Top 10 Largest Files in /usr:
───────────────────────────────────────────────────────────
   125.30 MB │ █████████████████████ │ libLLVM-14.so.1
    89.42 MB │ ███████████████       │ chromium
    ...

🕐 Files Modified in Last Hour:
   Found 23 recently modified files
   14:32  /var/log/syslog
   ...

📁 File Type Distribution:
───────────────────────────────────────────────────────────
   .gz    │  2345 │ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
   .png   │  1234 │ ▓▓▓▓▓▓▓▓
   ...
```

---

## D2: PERMISSION VISUALIZER

### Scop
Vizualizare intuitivă a permisiunilor pentru înțelegere rapidă.

### Scriptul

```bash
#!/bin/bash
# S03_04_demo_permissions.sh - Permission Visualizer

clear

# Culori
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'

echo -e "${BLUE}"
cat << "EOF"
    ╔═══════════════════════════════════════════════════════════╗
    ║        🔐 PERMISSION VISUALIZER 🔐                        ║
    ╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Funcție vizualizare permisiune
visualize_perm() {
    local file="$1"
    local perms=$(stat -c %A "$file" 2>/dev/null)
    local octal=$(stat -c %a "$file" 2>/dev/null)
    local owner=$(stat -c %U "$file" 2>/dev/null)
    local group=$(stat -c %G "$file" 2>/dev/null)
    
    echo -e "\n${BOLD}📄 File: ${YELLOW}$file${NC}"
    echo -e "   ${DIM}Owner: $owner | Group: $group${NC}"
    echo ""
    
    # Vizualizare grafică
    echo -e "   ┌─────────┬─────────┬─────────┬─────────┐"
    echo -e "   │  TYPE   │  OWNER  │  GROUP  │ OTHERS  │"
    echo -e "   ├─────────┼─────────┼─────────┼─────────┤"
    
    # Parse permissions
    type_char="${perms:0:1}"
    owner_perms="${perms:1:3}"
    group_perms="${perms:4:3}"
    other_perms="${perms:7:3}"
    
    # Type icon
    case $type_char in
        d) type_icon="📁 DIR" ;;
        l) type_icon="🔗 LNK" ;;
        -) type_icon="📄 FILE" ;;
        *) type_icon="❓ $type_char" ;;
    esac
    
    # Color function for permissions
    color_perm() {
        local p="$1"
        local result=""
        for ((i=0; i<3; i++)); do
            char="${p:$i:1}"
            case $char in
                r) result+="${GREEN}R${NC}" ;;
                w) result+="${YELLOW}W${NC}" ;;
                x) result+="${RED}X${NC}" ;;
                s) result+="${RED}S${NC}" ;;
                S) result+="${DIM}S${NC}" ;;
                t) result+="${BLUE}T${NC}" ;;
                T) result+="${DIM}T${NC}" ;;
                -) result+="${DIM}-${NC}" ;;
            esac
        done
        echo -e "$result"
    }
    
    printf "   │ %-7s │   %b   │   %b   │   %b   │\n" \
        "$type_icon" \
        "$(color_perm "$owner_perms")" \
        "$(color_perm "$group_perms")" \
        "$(color_perm "$other_perms")"
    
    echo -e "   └─────────┴─────────┴─────────┴─────────┘"
    echo -e "   ${DIM}Octal: ${NC}${BOLD}$octal${NC} ${DIM}| String: $perms${NC}"
    
    # Explică octal
    owner_oct=$((0${octal:0:1}))
    group_oct=$((0${octal:1:1}))
    other_oct=$((0${octal:2:1}))
    
    echo -e "\n   ${DIM}Octal breakdown:${NC}"
    printf "   Owner: %d = " $owner_oct
    [ $((owner_oct & 4)) -ne 0 ] && echo -n "r(4)" || echo -n "-(0)"
    [ $((owner_oct & 2)) -ne 0 ] && echo -n "+w(2)" || echo -n "+-(0)"
    [ $((owner_oct & 1)) -ne 0 ] && echo -n "+x(1)" || echo -n "+-(0)"
    echo ""
}

# Demo cu diferite fișiere
echo -e "${CYAN}Demo: Different permission patterns${NC}"

# Creăm fișiere de test
mkdir -p /tmp/perm_demo
touch /tmp/perm_demo/normal.txt
chmod 644 /tmp/perm_demo/normal.txt

touch /tmp/perm_demo/script.sh
chmod 755 /tmp/perm_demo/script.sh

touch /tmp/perm_demo/private.key
chmod 600 /tmp/perm_demo/private.key

mkdir /tmp/perm_demo/shared
chmod 2775 /tmp/perm_demo/shared

# Vizualizăm
for file in /tmp/perm_demo/*; do
    visualize_perm "$file"
    sleep 0.5
done

# Comparație cu fișiere sistem importante
echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}System files comparison:${NC}"

for sysfile in /etc/passwd /etc/shadow /usr/bin/passwd /tmp; do
    [ -e "$sysfile" ] && visualize_perm "$sysfile"
    sleep 0.3
done

# Cleanup
rm -rf /tmp/perm_demo

echo -e "\n${GREEN}✨ Notice the patterns:${NC}"
echo "   • Config files: 644 (owner writes, everyone reads)"
echo "   • Private keys: 600 (only owner accesses)"
echo "   • Scripts: 755 (everyone executes)"
echo "   • /etc/shadow: 640 (passwords protected!)"
echo "   • /usr/bin/passwd: has SUID bit (runs as root)"
```

---

## D3: LIVE CRON MONITOR

### Scop
Demonstrează cron în acțiune cu feedback vizual în timp real.

### Scriptul

```bash
#!/bin/bash
# S03_05_demo_cron.sh - Live Cron Monitor

clear

# Culori
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

echo -e "${CYAN}"
cat << "EOF"
    ╔═══════════════════════════════════════════════════════════╗
    ║           ⏰ LIVE CRON MONITOR ⏰                          ║
    ╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Creăm un job de test
TEST_LOG="/tmp/cron_demo_$$.log"
TEST_SCRIPT="/tmp/cron_demo_$$.sh"

cat > "$TEST_SCRIPT" << 'SCRIPT'
#!/bin/bash
echo "$(date '+%H:%M:%S') - ⚡ CRON JOB EXECUTED!" >> /tmp/cron_demo_*.log
SCRIPT
chmod +x "$TEST_SCRIPT"

# Instalăm job temporar
(crontab -l 2>/dev/null; echo "* * * * * $TEST_SCRIPT") | crontab -

echo -e "${YELLOW}📋 Current crontab:${NC}"
crontab -l | tail -3
echo ""

echo -e "${GREEN}▸ Created test job that runs every minute${NC}"
echo -e "${GREEN}▸ Watching for execution...${NC}"
echo ""

# Afișare cronometru până la următorul minut
show_countdown() {
    local now=$(date +%S)
    local remaining=$((60 - now))
    
    echo -e "${CYAN}Next cron tick in:${NC}"
    while [ $remaining -gt 0 ]; do
        printf "\r   ${BOLD}%02d${NC} seconds " $remaining
        
        # Progress bar
        filled=$((60 - remaining))
        bar=""
        for ((i=0; i<60; i+=2)); do
            if [ $i -lt $filled ]; then
                bar+="█"
            else
                bar+="░"
            fi
        done
        echo -ne "[${GREEN}$bar${NC}]"
        
        sleep 1
        remaining=$((remaining - 1))
    done
    echo -e "\n\n${GREEN}⚡ TICK!${NC}"
}

# Monitorizare log
monitor_log() {
    echo -e "\n${YELLOW}📊 Log output:${NC}"
    echo "─────────────────────────────────────"
    tail -f "$TEST_LOG" 2>/dev/null &
    TAIL_PID=$!
}

# Rulăm demo
touch "$TEST_LOG"
monitor_log
show_countdown

# Așteaptă să apară output
sleep 2

# Cleanup
kill $TAIL_PID 2>/dev/null
crontab -l 2>/dev/null | grep -v "cron_demo" | crontab -
rm -f "$TEST_SCRIPT" "$TEST_LOG"

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✨ Demo complete! Test job removed.${NC}"
echo ""
echo "Key takeaways:"
echo "  • Cron runs jobs at the START of each minute"
echo "  • Always use absolute paths in cron jobs"
echo "  • Log your cron job output for debugging"
```

---

## D4: DISK SPACE ANALYZER

### Scop
ncdu-like visualization folosind doar comenzi standard.

### Scriptul

```bash
#!/bin/bash
# S03_disk_analyzer.sh - Disk Space Analyzer

clear

# Culori
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

TARGET="${1:-$HOME}"

echo -e "${CYAN}"
cat << "EOF"
    ╔═══════════════════════════════════════════════════════════╗
    ║          💾 DISK SPACE ANALYZER 💾                        ║
    ╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo -e "${YELLOW}Analyzing: $TARGET${NC}"
echo ""

# Total size
total_size=$(du -sh "$TARGET" 2>/dev/null | cut -f1)
echo -e "${BOLD}Total size: ${GREEN}$total_size${NC}"
echo ""

# Top directories by size
echo -e "${CYAN}📁 Top 10 Directories by Size:${NC}"
echo "─────────────────────────────────────────────────────────"

# Get max size for scaling
max_size=$(du -s "$TARGET"/* 2>/dev/null | sort -rn | head -1 | cut -f1)
[ -z "$max_size" ] || [ "$max_size" -eq 0 ] && max_size=1

du -sh "$TARGET"/* 2>/dev/null | sort -rh | head -10 | while read size path; do
    name=$(basename "$path")
    
    # Get numeric size for bar
    num_size=$(du -s "$path" 2>/dev/null | cut -f1)
    [ -z "$num_size" ] && num_size=0
    
    # Calculate bar length (max 30 chars)
    bar_len=$((num_size * 30 / max_size))
    [ $bar_len -gt 30 ] && bar_len=30
    [ $bar_len -lt 1 ] && bar_len=1
    
    # Color based on size
    if [ $bar_len -gt 20 ]; then
        color=$RED
    elif [ $bar_len -gt 10 ]; then
        color=$YELLOW
    else
        color=$GREEN
    fi
    
    # Create bar
    bar=$(printf '█%.0s' $(seq 1 $bar_len))
    empty=$(printf '░%.0s' $(seq 1 $((30 - bar_len))) 2>/dev/null)
    
    # Type indicator
    if [ -d "$path" ]; then
        icon="📁"
    else
        icon="📄"
    fi
    
    printf "%s ${BOLD}%8s${NC} │${color}%s${NC}%s│ %s\n" \
        "$icon" "$size" "$bar" "$empty" "$name"
done

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# File type breakdown
echo -e "\n${CYAN}📊 Space by File Type:${NC}"
echo "─────────────────────────────────────────────────────────"

# Temporar file pentru statistici
tmpfile=$(mktemp)

find "$TARGET" -type f -printf '%s %f\n' 2>/dev/null | \
    awk -F. '{if (NF>1) print $NF}' | \
    sort | uniq -c | sort -rn | head -8 > "$tmpfile"

while read count ext; do
    # Calculate approximate size
    total_bytes=$(find "$TARGET" -type f -name "*.$ext" -printf '%s\n' 2>/dev/null | \
        awk '{sum+=$1} END {print sum}')
    [ -z "$total_bytes" ] && total_bytes=0
    
    # Convert to human readable
    if [ $total_bytes -gt 1073741824 ]; then
        human=$(echo "scale=1; $total_bytes/1073741824" | bc)G
    elif [ $total_bytes -gt 1048576 ]; then
        human=$(echo "scale=1; $total_bytes/1048576" | bc)M
    elif [ $total_bytes -gt 1024 ]; then
        human=$(echo "scale=1; $total_bytes/1024" | bc)K
    else
        human="${total_bytes}B"
    fi
    
    printf "   ${GREEN}%-8s${NC} │ %6d files │ %8s\n" ".$ext" "$count" "$human"
done < "$tmpfile"

rm -f "$tmpfile"

echo ""
echo -e "${GREEN}💡 Tip: Run with path argument to analyze different directory${NC}"
echo "   Example: $0 /var/log"
```

---

## D5: SECURITY AUDIT LIVE

### Scop
Demonstrare audit de securitate în timp real.

### Scriptul

```bash
#!/bin/bash
# S03_security_audit_demo.sh - Live Security Audit

clear

# Culori
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

echo -e "${RED}"
cat << "EOF"
    ╔═══════════════════════════════════════════════════════════╗
    ║         🛡️  SECURITY AUDIT IN PROGRESS 🛡️                 ║
    ╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Animație scanner
scanner_animation() {
    local text="$1"
    echo -ne "${CYAN}[    ] $text${NC}\r"
    sleep 0.2
    for frame in "▰   " " ▰  " "  ▰ " "   ▰" "  ▰ " " ▰  "; do
        echo -ne "${CYAN}[$frame] $text${NC}\r"
        sleep 0.1
    done
}

report_finding() {
    local severity="$1"
    local message="$2"
    local color
    
    case $severity in
        HIGH) color=$RED; icon="🔴" ;;
        MEDIUM) color=$YELLOW; icon="🟡" ;;
        LOW) color=$GREEN; icon="🟢" ;;
        OK) color=$GREEN; icon="✅" ;;
    esac
    
    echo -e "${color}$icon [$severity]${NC} $message"
}

# Check 1: World-writable files
scanner_animation "Scanning for world-writable files..."
count=$(find /tmp /var/tmp -type f -perm -002 2>/dev/null | wc -l)
echo -e "${GREEN}[DONE]${NC} Scanning for world-writable files..."
if [ $count -gt 0 ]; then
    report_finding "MEDIUM" "Found $count world-writable files in /tmp"
else
    report_finding "OK" "No world-writable files found"
fi

# Check 2: SUID binaries
scanner_animation "Checking SUID binaries..."
suid_count=$(find /usr -type f -perm -4000 2>/dev/null | wc -l)
echo -e "${GREEN}[DONE]${NC} Checking SUID binaries..."
report_finding "LOW" "Found $suid_count SUID binaries (normal for system)"

# Check 3: Password file permissions
scanner_animation "Verifying /etc/passwd permissions..."
echo -e "${GREEN}[DONE]${NC} Verifying /etc/passwd permissions..."
passwd_perm=$(stat -c %a /etc/passwd 2>/dev/null)
if [ "$passwd_perm" = "644" ]; then
    report_finding "OK" "/etc/passwd has correct permissions (644)"
else
    report_finding "HIGH" "/etc/passwd has wrong permissions: $passwd_perm"
fi

# Check 4: Shadow file
scanner_animation "Verifying /etc/shadow permissions..."
echo -e "${GREEN}[DONE]${NC} Verifying /etc/shadow permissions..."
if [ -r /etc/shadow ]; then
    report_finding "HIGH" "/etc/shadow is readable by current user!"
else
    report_finding "OK" "/etc/shadow is properly protected"
fi

# Check 5: SSH config
scanner_animation "Checking SSH configuration..."
echo -e "${GREEN}[DONE]${NC} Checking SSH configuration..."
if [ -f ~/.ssh/id_rsa ]; then
    key_perm=$(stat -c %a ~/.ssh/id_rsa 2>/dev/null)
    if [ "$key_perm" = "600" ]; then
        report_finding "OK" "SSH private key has correct permissions"
    else
        report_finding "HIGH" "SSH private key has wrong permissions: $key_perm"
    fi
else
    report_finding "OK" "No SSH private key found (or not accessible)"
fi

# Check 6: Cron jobs
scanner_animation "Auditing cron jobs..."
echo -e "${GREEN}[DONE]${NC} Auditing cron jobs..."
cron_count=$(crontab -l 2>/dev/null | grep -v "^#" | grep -v "^$" | wc -l)
report_finding "LOW" "User has $cron_count active cron jobs"

# Summary
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}AUDIT SUMMARY:${NC}"
echo ""
echo "   Checks performed: 6"
echo "   Using tools: find, stat, crontab"
echo ""
echo -e "${GREEN}💡 This is what system administrators do regularly!${NC}"
echo -e "   Permissions are the FIRST LINE OF DEFENSE."
```

---

## UTILIZARE DEMO-URI

### Când să Folosești Fiecare Demo

| Moment în Seminar | Demo Recomandat |
|-------------------|-----------------|
| Deschidere | D1: File System Explorer |
| După teoria find | D4: Disk Space Analyzer |
| După teoria permisiuni | D2: Permission Visualizer |
| După teoria cron | D3: Live Cron Monitor |
| Închidere | D5: Security Audit |

### Setup Rapid

```bash
# Descarcă toate demo-urile
cd ~/live_demo
for demo in hook find_xargs getopts permissions cron; do
    chmod +x S03_*_demo_*.sh
done

# Test rapid
./S03_01_hook_demo.sh
```

---

*Document generat pentru ASE București - CSIE | Sisteme de Operare | Seminar 3*
