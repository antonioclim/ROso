# Live Coding Guide — CAPSTONE SEM06

> **Sisteme de Operare** | ASE București - CSIE  
> Seminar 6: Proiecte Integrate (Monitor, Backup, Deployer)  
> Ghid pentru Instructor

---

## Principii Live Coding (Brown & Wilson)

1. **Tastează în timp real** — nu copia/lipește blocuri mari
2. **Greșește intenționat** — arată debugging
3. **Cere predicții** — "Ce va afișa această comandă?"
4. **Verbalizează** — explică ce gândești în timp ce scrii
5. **Pauze pentru întrebări** — după fiecare bloc logic

---

## Demo 1: System Monitor (20 min)

### Obiectiv
Construiește pas cu pas un monitor de CPU care citește din `/proc/stat`.

### Setup

```bash
# Terminalul trebuie vizibil pentru toată clasa
cd ~/sem06/monitor_demo
# Font size mare, contrast bun
```

### Pas 1: Citire /proc/stat (5 min)

**Spune:** "Toate informațiile despre CPU vin din pseudo-fișierul /proc/stat. Să vedem ce conține."

```bash
# Întrebare: Ce credeți că găsim în /proc/stat?
cat /proc/stat | head -5
```

**Output așteptat:**
```
cpu  1234567 12345 234567 8901234 12345 0 1234 0 0 0
cpu0 309891 3086 58641 2225308 3086 0 308 0 0 0
...
```

**Explică:** "Prima linie e totalul. Numerele sunt: user, nice, system, idle, iowait..."

### Pas 2: Extragere cu awk (5 min)

```bash
# Întrebare: Cum extragem doar prima linie?
grep "^cpu " /proc/stat

# Acum extragem valorile
grep "^cpu " /proc/stat | awk '{print $2, $3, $4, $5}'
```

**Greșeală intenționată:**
```bash
# Ooops, am uitat că awk folosește spații ca separator
grep "^cpu " /proc/stat | awk -F: '{print $2}'
# Nu funcționează! De ce?
```

### Pas 3: Calcularea procentului (5 min)

```bash
# Prima citire
read -r cpu user nice system idle rest < <(grep "^cpu " /proc/stat)
total1=$((user + nice + system + idle))
idle1=$idle

# Așteptăm o secundă
sleep 1

# A doua citire
read -r cpu user nice system idle rest < <(grep "^cpu " /proc/stat)
total2=$((user + nice + system + idle))
idle2=$idle

# Calculăm diferența
total_diff=$((total2 - total1))
idle_diff=$((idle2 - idle1))

# CPU usage = 100 - idle%
cpu_usage=$((100 * (total_diff - idle_diff) / total_diff))
echo "CPU Usage: ${cpu_usage}%"
```

### Pas 4: Funcție reutilizabilă (5 min)

```bash
get_cpu_usage() {
    local cpu user nice system idle rest
    local total1 idle1 total2 idle2
    
    read -r cpu user nice system idle rest < <(grep "^cpu " /proc/stat)
    total1=$((user + nice + system + idle))
    idle1=$idle
    
    sleep 1
    
    read -r cpu user nice system idle rest < <(grep "^cpu " /proc/stat)
    total2=$((user + nice + system + idle))
    idle2=$idle
    
    echo $((100 * (total2 - total1 - idle2 + idle1) / (total2 - total1)))
}

# Test
echo "CPU: $(get_cpu_usage)%"
```

### Checkpoint

- Toți au înțeles cum citim din /proc?
- Întrebări despre awk sau read?

---

## Demo 2: Backup System (25 min)

### Obiectiv
Construiește un sistem de backup incremental cu verificare checksum.

### Pas 1: Structură directoare (3 min)

```bash
mkdir -p ~/backup_demo/{source,backups}
cd ~/backup_demo

# Creăm fișiere test
echo "Document important v1" > source/doc1.txt
echo "Configurare aplicație" > source/config.ini
mkdir source/logs
echo "Log entry 1" > source/logs/app.log
```

### Pas 2: Backup full cu tar (5 min)

**Întrebare:** "Ce opțiuni folosim pentru tar? c-create, z-gzip, v-verbose, f-file"

```bash
BACKUP_NAME="backup_$(date +%Y%m%d_%H%M%S).tar.gz"
tar czvf "backups/$BACKUP_NAME" source/

# Verificăm
ls -lh backups/
tar tzvf "backups/$BACKUP_NAME"
```

### Pas 3: Checksum pentru integritate (5 min)

```bash
# Generăm checksum
cd backups
sha256sum "$BACKUP_NAME" > "$BACKUP_NAME.sha256"
cat "$BACKUP_NAME.sha256"

# Verificăm
sha256sum -c "$BACKUP_NAME.sha256"
# OK!

# Simulăm corupție
echo "corrupt" >> "$BACKUP_NAME"
sha256sum -c "$BACKUP_NAME.sha256"
# FAILED!
```

### Pas 4: Backup incremental (7 min)

```bash
cd ~/backup_demo

# Creăm timestamp marker
touch backups/.last_backup

# Modificăm un fișier
sleep 2
echo "Document important v2" > source/doc1.txt
echo "Fișier nou" > source/new_file.txt

# Găsim fișierele modificate
find source -newer backups/.last_backup -type f

# Backup incremental
INCR_BACKUP="incremental_$(date +%Y%m%d_%H%M%S).tar.gz"
find source -newer backups/.last_backup -type f -print0 | \
    xargs -0 tar czvf "backups/$INCR_BACKUP"

# Actualizăm marker
touch backups/.last_backup
```

### Pas 5: Funcție completă (5 min)

```bash
do_backup() {
    local type="${1:-full}"
    local source_dir="$2"
    local backup_dir="$3"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file
    
    if [[ "$type" == "full" ]]; then
        backup_file="$backup_dir/full_${timestamp}.tar.gz"
        tar czf "$backup_file" "$source_dir"
    else
        backup_file="$backup_dir/incr_${timestamp}.tar.gz"
        find "$source_dir" -newer "$backup_dir/.last_backup" -type f -print0 | \
            xargs -0 tar czf "$backup_file" 2>/dev/null || true
    fi
    
    sha256sum "$backup_file" > "$backup_file.sha256"
    touch "$backup_dir/.last_backup"
    
    echo "$backup_file"
}

# Test
do_backup full source backups
do_backup incremental source backups
```

---

## Demo 3: Deployer cu Rollback (20 min)

### Obiectiv
Demonstrează deployment cu symlink și rollback instant.

### Pas 1: Structura releases (5 min)

```bash
mkdir -p ~/deploy_demo/{releases,shared}
cd ~/deploy_demo

# Simulăm versiuni
mkdir releases/v1.0.0
echo "App v1.0.0" > releases/v1.0.0/index.html
echo "Config shared" > shared/config.ini

mkdir releases/v1.1.0
echo "App v1.1.0 - NEW!" > releases/v1.1.0/index.html

# Current symlink
ln -s releases/v1.0.0 current
ls -la current
cat current/index.html
```

### Pas 2: Deploy cu ln -sf (5 min)

**Întrebare:** "De ce ln -sf și nu rm + ln?"

```bash
# Demonstrăm problema cu rm + ln
# (NU RULA ÎN PRODUCȚIE!)
rm current
# În acest moment - DOWNTIME!
ln -s releases/v1.1.0 current

# Metoda corectă - atomic
ln -sf releases/v1.1.0 current
# Zero downtime!

cat current/index.html
```

### Pas 3: Health check (5 min)

```bash
check_health() {
    local url="${1:-http://localhost:8080/health}"
    local retries=3
    local wait=2
    
    for ((i=1; i<=retries; i++)); do
        if curl -sf "$url" > /dev/null 2>&1; then
            echo "Health check passed"
            return 0
        fi
        echo "Attempt $i failed, waiting ${wait}s..."
        sleep $wait
    done
    
    echo "Health check failed after $retries attempts"
    return 1
}

# Simulăm (fără server real)
# check_health http://localhost:8080/health
```

### Pas 4: Rollback (5 min)

```bash
rollback() {
    local current_version=$(readlink current | xargs basename)
    local releases=($(ls -1 releases | sort -V))
    
    # Găsim versiunea anterioară
    for ((i=0; i<${#releases[@]}; i++)); do
        if [[ "${releases[$i]}" == "$current_version" ]]; then
            if [[ $i -gt 0 ]]; then
                local prev="${releases[$((i-1))]}"
                ln -sf "releases/$prev" current
                echo "Rolled back to $prev"
                return 0
            fi
        fi
    done
    
    echo "No previous version to rollback to"
    return 1
}

# Test
readlink current
rollback
readlink current
```

---

## Tips pentru Live Coding

### Înainte de Seminar

- [ ] Testează toate comenzile
- [ ] Pregătește fișierele necesare
- [ ] Verifică display-ul (font, contrast)
- [ ] Ai backup dacă ceva nu merge

### În Timpul Sesiunii

- [ ] Vorbește în timp ce tastezi
- [ ] Oprește-te pentru întrebări
- [ ] Lasă studenții să prezică output-ul
- [ ] Când greșești, transformă în moment de învățare

### Erori Comune de Demonstrat

1. **Spații la atribuire:** `VAR = value` → eroare
2. **Ghilimele lipsă:** `$VAR` cu spații → word splitting
3. **Exit code ignorat:** comanda eșuează dar scriptul continuă
4. **Fișier nu există:** path greșit, permisiuni

### Recovery Phrases

- "Hm, nu merge cum mă așteptam. Să investigăm..."
- "Aceasta e o greșeală comună. Cine știe de ce?"
- "Să verificăm cu `echo` ce valoare are variabila"
- "Bun exemplu de debugging în timp real!"

---

## Fișiere Demo Pregătite

Scripturile demo complete sunt în:
- `scripts/demo_monitor.sh`
- `scripts/demo_backup.sh`
- `scripts/demo_deployer.sh`

Rulează cu `--help` pentru opțiuni sau `--step` pentru mod pas-cu-pas.

---

## Timing Recomandat

| Demo | Durată | Puncte Cheie |
|------|--------|--------------|
| Monitor | 20 min | /proc/stat, awk, funcții |
| Backup | 25 min | tar, checksum, incremental |
| Deployer | 20 min | symlink atomic, health check |
| Buffer | 15 min | Întrebări, debugging |
| **Total** | 80 min | Dintr-un seminar de 100 min |

---

*Document generat pentru SEM06 CAPSTONE — Sisteme de Operare*  
*ASE București - CSIE | 2024-2025*
