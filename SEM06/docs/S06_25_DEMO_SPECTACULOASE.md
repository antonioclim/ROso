# Demo-uri Spectaculoase — CAPSTONE SEM06

> **Sisteme de Operare** | ASE București - CSIE  
> Seminar 6: Proiecte Integrate (Monitor, Backup, Deployer)

---

## Scopul Demo-urilor

Demo-urile spectaculoase au rolul de a:
- **Capta atenția** — efect "wow" vizual sau conceptual
- **Demonstra relevanța** — "uite ce poți face în industrie"
- **Motiva învățarea** — "vreau să știu cum funcționează asta"
- **Ancora conceptele** — asociere emoțională cu materialul

---

## Demo 1: Real-Time System Dashboard 🖥️

### Wow Factor
Un dashboard live care arată starea sistemului în timp real, actualizat la fiecare secundă, direct în terminal.

### Pregătire

```bash
cd ~/sem06/demo
```

### Script Demo

```bash
#!/bin/bash
# dashboard_live.sh - Real-time system dashboard

while true; do
    clear
    
    # Header cu efect
    echo -e "\033[1;36m"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║           SYSTEM DASHBOARD - $(date '+%H:%M:%S')                    ║"
    echo "║           Host: $(hostname)                                   "
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "\033[0m"
    
    # CPU Bar
    cpu=$(grep "^cpu " /proc/stat | awk '{u=$2+$4; t=$2+$4+$5; if(NR==1){u1=u;t1=t}else{print int((u-u1)*100/(t-t1))}}')
    cpu=${cpu:-$(top -bn1 | grep "Cpu(s)" | awk '{print int($2)}')}
    bar=$(printf "%-${cpu}s" | tr ' ' '█')
    empty=$(printf "%-$((100-cpu))s" | tr ' ' '░')
    echo -e "CPU:  [\033[32m${bar}\033[0m${empty}] ${cpu}%"
    
    # Memory Bar
    mem=$(free | awk '/Mem:/ {print int($3/$2*100)}')
    bar=$(printf "%-${mem}s" | tr ' ' '█')
    empty=$(printf "%-$((100-mem))s" | tr ' ' '░')
    echo -e "MEM:  [\033[33m${bar}\033[0m${empty}] ${mem}%"
    
    # Disk Bar
    disk=$(df / | awk 'NR==2 {print int($3/$2*100)}')
    bar=$(printf "%-${disk}s" | tr ' ' '█')
    empty=$(printf "%-$((100-disk))s" | tr ' ' '░')
    echo -e "DISK: [\033[34m${bar}\033[0m${empty}] ${disk}%"
    
    echo ""
    echo -e "\033[1mTop Processes:\033[0m"
    ps aux --sort=-%cpu | head -6 | tail -5 | awk '{printf "  %-10s %5s%% CPU  %5s%% MEM  %s\n", $1, $3, $4, $11}'
    
    echo ""
    echo -e "\033[90mPress Ctrl+C to exit\033[0m"
    
    sleep 1
done
```

### Moment Cheie
"Totul vine din /proc - fișiere text pe care le puteți citi. Nu e magie, e Unix."

### Variante
- Adaugă network traffic cu `/proc/net/dev`
- Adaugă alerting când CPU > 80%
- Export în format Prometheus

---

## Demo 2: Backup Time Machine ⏰

### Wow Factor
Demonstrație de "călătorie în timp" - restore la orice punct din trecut.

### Pregătire

```bash
mkdir -p ~/demo_backup/{source,snapshots}
cd ~/demo_backup
echo "Version 1 - Original" > source/document.txt
```

### Script Demo

```bash
#!/bin/bash
# time_machine.sh - Snapshot-based backup with time travel

SNAPSHOTS_DIR="snapshots"
SOURCE="source"

snapshot() {
    local ts=$(date +%Y%m%d_%H%M%S)
    local snap_dir="$SNAPSHOTS_DIR/$ts"
    
    echo "📸 Creating snapshot: $ts"
    cp -r "$SOURCE" "$snap_dir"
    echo "$ts" >> "$SNAPSHOTS_DIR/history.log"
    echo "✓ Snapshot created"
}

list_snapshots() {
    echo "📜 Available snapshots:"
    ls -1 "$SNAPSHOTS_DIR" | grep -v history.log | while read snap; do
        echo "  → $snap"
    done
}

restore() {
    local target="$1"
    if [[ -d "$SNAPSHOTS_DIR/$target" ]]; then
        echo "⏰ Traveling back to: $target"
        rm -rf "$SOURCE"
        cp -r "$SNAPSHOTS_DIR/$target" "$SOURCE"
        echo "✓ Restored to $target"
    else
        echo "❌ Snapshot not found: $target"
    fi
}

# Demo flow
echo "=== BACKUP TIME MACHINE ==="
echo ""

# Create initial snapshot
snapshot
sleep 2

# Modify file
echo "Version 2 - Modified" > source/document.txt
echo "📝 File modified: $(cat source/document.txt)"
snapshot
sleep 2

# Modify again
echo "Version 3 - Oops, wrong changes!" > source/document.txt
echo "📝 File modified: $(cat source/document.txt)"
snapshot

# Show history
echo ""
list_snapshots

# Restore to first version
echo ""
first_snap=$(ls -1 "$SNAPSHOTS_DIR" | grep -v history.log | head -1)
restore "$first_snap"
echo "📄 Current content: $(cat source/document.txt)"
```

### Moment Cheie
"Asta e principiul din git, Time Machine (macOS), și ZFS snapshots. Backup incremental în acțiune."

---

## Demo 3: Zero-Downtime Deployment 🚀

### Wow Factor
Schimbăm versiunea unei "aplicații" live, fără nicio secundă de downtime.

### Pregătire

```bash
mkdir -p ~/demo_deploy/{releases,shared}
cd ~/demo_deploy

# Creăm "versiunile"
mkdir releases/v1.0.0
echo "<h1>App v1.0.0</h1>" > releases/v1.0.0/index.html

mkdir releases/v2.0.0  
echo "<h1>App v2.0.0 - NEW!</h1>" > releases/v2.0.0/index.html

# Link inițial
ln -s releases/v1.0.0 current
```

### Script Demo

```bash
#!/bin/bash
# zero_downtime_deploy.sh

RELEASES="releases"
CURRENT="current"

show_status() {
    local version=$(readlink "$CURRENT" | xargs basename)
    echo "🌐 Current version: $version"
    echo "📄 Content: $(cat $CURRENT/index.html)"
}

deploy() {
    local new_version="$1"
    
    echo "🚀 Deploying $new_version..."
    echo ""
    
    # Show current state
    echo "BEFORE:"
    show_status
    echo ""
    
    # Atomic switch!
    echo "⚡ Switching (atomic operation)..."
    ln -sfn "$RELEASES/$new_version" "$CURRENT"
    
    # Show new state
    echo ""
    echo "AFTER:"
    show_status
}

rollback() {
    local versions=($(ls -1 "$RELEASES" | sort -V))
    local current=$(readlink "$CURRENT" | xargs basename)
    
    for ((i=0; i<${#versions[@]}; i++)); do
        if [[ "${versions[$i]}" == "$current" && $i -gt 0 ]]; then
            local prev="${versions[$((i-1))]}"
            echo "⏪ Rolling back to $prev..."
            ln -sfn "$RELEASES/$prev" "$CURRENT"
            echo "✓ Rollback complete"
            return 0
        fi
    done
    echo "❌ No previous version available"
}

# Demo
echo "=== ZERO-DOWNTIME DEPLOYMENT ==="
echo ""

show_status
echo ""
echo "Press ENTER to deploy v2.0.0..."
read

deploy "v2.0.0"

echo ""
echo "Press ENTER to rollback..."
read

rollback
show_status
```

### Moment Cheie
"`ln -sfn` este atomic - nu există niciun moment în care `current` nu pointează la o versiune validă. Asta e secretul zero-downtime deployment."

---

## Demo 4: Process Tree Visualizer 🌳

### Wow Factor
Vizualizare în timp real a arborelui de procese, arătând relația părinte-copil.

### Script Demo

```bash
#!/bin/bash
# process_tree.sh - Interactive process tree

show_tree() {
    echo "🌳 Process Tree (your terminal branch):"
    echo ""
    
    # Get current shell's ancestry
    local pid=$$
    local chain=""
    
    while [[ $pid -ne 1 ]]; do
        local cmd=$(ps -p $pid -o comm= 2>/dev/null)
        local ppid=$(ps -p $pid -o ppid= 2>/dev/null | tr -d ' ')
        chain="$cmd ($pid) → $chain"
        pid=$ppid
    done
    
    echo "init (1) → $chain"
    echo ""
    
    # Show children
    echo "🌿 My children:"
    pstree -p $$ 2>/dev/null || ps --ppid $$ -o pid,comm
}

spawn_children() {
    echo "🐣 Spawning child processes..."
    
    # Background processes
    sleep 100 &
    echo "  Child 1: sleep (PID: $!)"
    
    (while true; do sleep 1; done) &
    echo "  Child 2: subshell (PID: $!)"
    
    cat /dev/zero > /dev/null &
    echo "  Child 3: cat (PID: $!)"
    
    echo ""
    show_tree
}

cleanup() {
    echo ""
    echo "🧹 Cleaning up children..."
    pkill -P $$
    echo "✓ All children terminated"
}

trap cleanup EXIT

echo "=== PROCESS TREE VISUALIZER ==="
echo ""
show_tree

echo ""
echo "Press ENTER to spawn children..."
read
spawn_children

echo ""
echo "Press ENTER to see updated tree..."
read
show_tree

echo ""
echo "Press ENTER to cleanup and exit..."
read
```

### Moment Cheie
"Fiecare proces are un părinte. Când părintele moare, copiii devin orfani și sunt adoptați de init/systemd. Trap-ul asigură cleanup."

---

## Demo 5: Signal Catcher 📡

### Wow Factor
Demonstrație interactivă a semnalelor Unix - trimite semnale și vezi cum sunt prinse.

### Script Demo

```bash
#!/bin/bash
# signal_catcher.sh - Interactive signal demonstration

echo "=== SIGNAL CATCHER ==="
echo "My PID: $$"
echo ""
echo "Open another terminal and send signals:"
echo "  kill -SIGUSR1 $$"
echo "  kill -SIGUSR2 $$"
echo "  kill -SIGTERM $$"
echo "  kill -SIGINT $$  (or Ctrl+C here)"
echo ""

# Signal handlers
trap 'echo "📨 Caught SIGUSR1 - Custom signal 1!"' SIGUSR1
trap 'echo "📨 Caught SIGUSR2 - Custom signal 2!"' SIGUSR2
trap 'echo "📨 Caught SIGTERM - Termination request (graceful)"; exit 0' SIGTERM
trap 'echo "📨 Caught SIGINT - Interrupt (Ctrl+C)"; exit 0' SIGINT
trap 'echo "📨 Caught SIGHUP - Hangup (terminal closed)"' SIGHUP

echo "Waiting for signals... (Ctrl+C to exit)"
echo ""

# Counter to show we're alive
count=0
while true; do
    ((count++))
    echo -ne "\r⏱️  Running for ${count}s... "
    sleep 1
done
```

### Moment Cheie
"Semnalele sunt modul în care procesele comunică. Trap le prinde și execută cod custom. SIGKILL (kill -9) nu poate fi prins - e arma nucleară."

---

## Demo 6: File Descriptor Magic 🎩

### Wow Factor
Demonstrează file descriptori și redirecționare avansată.

### Script Demo

```bash
#!/bin/bash
# fd_magic.sh - File descriptor demonstration

echo "=== FILE DESCRIPTOR MAGIC ==="
echo ""

# Show current FDs
echo "📂 Current file descriptors:"
ls -la /proc/$$/fd/
echo ""

# Create custom FD
exec 3>custom_output.txt
echo "✨ Created FD 3 pointing to custom_output.txt"
ls -la /proc/$$/fd/3
echo ""

# Write through custom FD
echo "Hello from FD 3!" >&3
echo "📝 Wrote to FD 3"
echo "Content: $(cat custom_output.txt)"
echo ""

# Duplicate FD (backup stdout)
exec 4>&1  # Save stdout to FD 4
echo "✨ Saved stdout to FD 4"

# Redirect stdout to file
exec 1>stdout_capture.txt
echo "This goes to file, not screen"

# Restore stdout
exec 1>&4
exec 4>&-  # Close FD 4
echo "✨ Restored stdout"
echo "Captured: $(cat stdout_capture.txt)"
echo ""

# Cleanup
exec 3>&-
rm -f custom_output.txt stdout_capture.txt
echo "🧹 Cleaned up"
```

### Moment Cheie
"0=stdin, 1=stdout, 2=stderr, dar poți crea FD-uri custom (3-9). Pipe-urile și redirecționările sunt doar manipulări de file descriptori."

---

## Sfaturi pentru Prezentare

### Timing

| Demo | Durată | Când să folosești |
|------|--------|-------------------|
| Dashboard | 5 min | Deschidere seminar |
| Time Machine | 7 min | După secțiunea Backup |
| Zero-Downtime | 5 min | După secțiunea Deployer |
| Process Tree | 5 min | Când discuți fork/exec |
| Signal Catcher | 5 min | La trap și signals |
| FD Magic | 7 min | La redirecționare avansată |

### Do's and Don'ts

**Do:**
- Testează înainte
- Explică în timp ce tastezi
- Lasă pauze pentru "wow"
- Conectează cu teoria

**Don't:**
- Nu citi de pe ecran
- Nu sări pași
- Nu ignora erorile
- Nu te grăbi

---

## Fișiere Demo Complete

Scripturile sunt în `scripts/`:
- `scripts/demo_monitor.sh` — Monitor complet
- `scripts/demo_backup.sh` — Backup cu toate funcțiile
- `scripts/demo_deployer.sh` — Deployer cu strategii

Rulează cu `--demo` pentru modul spectacol sau `--step` pentru pas-cu-pas.

---

*Document generat pentru SEM06 CAPSTONE — Sisteme de Operare*  
*ASE București - CSIE | 2024-2025*
