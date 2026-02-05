# M06: Istoric Utilizare Resurse

> **Nivel:** MEDIUM | **Timp estimat:** 25-35 ore | **Bonus K8s:** +10%

---

## Descriere

Sistem pentru colectare, stocare și analiză istorică a utilizării resurselor (CPU, RAM, disc, rețea). Include vizualizare în terminal cu grafice ASCII, detectare anomalii și predicție tendințe pentru planificare capacitate.

---

## Obiective de Învățare

- Colectare metrici sistem (`/proc`, `vmstat`, `iostat`)
- Stocare date time-series (SQLite sau text structurat)
- Vizualizare date în terminal (grafice ASCII)
- Analiză statistică de bază (medie, deviere std, tendință)
- Alertare bazată pe praguri și anomalii

---

## Cerințe Funcționale

### Obligatorii (pentru nota de trecere)

1. **Colectare metrici**
   - CPU: utilizare per core, load average
   - Memorie: folosită, liberă, cached, swap
   - Disc: utilizare per partiție, I/O wait
   - Rețea: bytes in/out per interfață

2. **Stocare date**
   - Format: SQLite sau CSV cu timestamp
   - Rotație: retenție configurabilă (7/30/90 zile)
   - Compresie pentru date vechi

3. **Vizualizare terminal**
   - Grafice ASCII pentru fiecare metrică
   - Perioadă selectabilă (oră/zi/săptămână/lună)
   - Comparare între perioade

4. **Rapoarte**
   - Rezumate zilnice/săptămânale/lunare
   - Export CSV pentru analiză externă
   - Top consumatori (procese)

5. **Mod daemon**
   - Colectare la interval configurabil
   - Start/stop/status
   - Overhead minimal

### Opționale (pentru punctaj complet)

6. **Analiză tendințe** - Predicție utilizare viitoare
7. **Detectare anomalii** - Alertă la valori neobișnuite
8. **Urmărire procese** - Istoric utilizare per proces
9. **Alertare** - Email/webhook la prag
10. **Dashboard web** - Server HTTP simplu cu grafice

---

## Interfață CLI

```bash
./historian.sh <command> [options]

Commands:
  start                 Start collection (daemon)
  stop                  Stop the daemon
  status                Daemon status and latest values
  collect               One-shot collection
  show <metric>         Display graph for metric
  report [period]       Generate report (hour|day|week|month)
  export <file>         Export data to CSV
  query <sql>           Direct query on database
  cleanup               Delete old data

Available metrics:
  cpu                   CPU usage (total and per core)
  memory                Memory usage
  disk                  Disk usage and I/O
  network               Network traffic
  load                  Load average
  all                   All metrics

Options:
  -p, --period PERIOD   Period: 1h|6h|24h|7d|30d (default: 24h)
  -i, --interval SEC    Collection interval (default: 60)
  -f, --format FMT      Output format: ascii|json|csv
  -w, --width N         Graph width (default: 80)
  --no-color            No colours
  --threshold PCT       Alert above this percentage

Examples:
  ./historian.sh start -i 30
  ./historian.sh show cpu -p 7d
  ./historian.sh show memory --width 120
  ./historian.sh report week -f csv > report.csv
  ./historian.sh query "SELECT * FROM metrics WHERE cpu > 90"
```

---

## Exemple Output

### Dashboard Timp Real

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    ISTORIC UTILIZARE RESURSE                                 ║
║                    Host: server01 | Uptime: 45z 12h                         ║
╚══════════════════════════════════════════════════════════════════════════════╝

┌─ Utilizare CPU (ultimele 24h) ───────────────────────────────────────────────┐
│ 100%│                              ▄▄                                        │
│  80%│                    ▄▄       ████                                       │
│  60%│        ▄▄         ████     ██████    ▄▄                               │
│  40%│       ████   ▄▄  ██████   ████████  ████                              │
│  20%│▄▄▄▄▄▄██████▄████▄████████▄██████████████▄▄▄▄▄▄▄▄▄▄▄▄                  │
│   0%└────────────────────────────────────────────────────────────────────────│
│     00:00    04:00    08:00    12:00    16:00    20:00    acum               │
│     Min: 12%  Max: 87%  Med: 34%  Curent: 23%                               │
└──────────────────────────────────────────────────────────────────────────────┘

┌─ Utilizare Memorie (ultimele 24h) ───────────────────────────────────────────┐
│ 16G │████████████████████████████████████████████████████████████████       │
│ 12G │████████████████████████████████████████████████████████▓▓▓▓▓▓▓▓       │
│  8G │██████████████████████████████████████▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░       │
│  4G │████████████████▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░░░░░░░░░░░░░░░░       │
│  0G └────────────────────────────────────────────────────────────────────────│
│     ████ Folosită (8.2G)  ▓▓▓▓ Cached (4.1G)  ░░░░ Liberă (3.7G)            │
└──────────────────────────────────────────────────────────────────────────────┘

┌─ I/O Disc (ultimele 24h) ────────────────────────────────────────────────────┐
│ Citire:  ▁▂▃▄▅▆▇█▇▆▅▄▃▂▁▁▂▃▄▅▆▇████▇▆▅▄▃▂▁▁▂▃▄▅▆▇█▇▆▅▄▃▂▁▁▂▃▄▅▆▇█          │
│ Scriere: ▁▁▂▃▄▅▆▇█▇▆▅▄▃▂▁▁▁▂▃▄▅▆████████▇▆▅▄▃▂▁▁▂▃▄▅▆▇█▇▆▅▄▃▂▁▁▂▃          │
│ Vârf citire: 450 MB/s la 14:30  |  Vârf scriere: 320 MB/s la 15:45          │
└──────────────────────────────────────────────────────────────────────────────┘

┌─ Trafic Rețea (ultimele 24h) ────────────────────────────────────────────────┐
│ eth0 IN:  ▂▃▄▅▆▇████▇▆▅▄▃▂▂▃▄▅▆▇████▇▆▅▄▃▂▂▃▄▅▆▇████▇▆▅▄▃▂                  │
│ eth0 OUT: ▁▂▃▄▅▆▇██▇▆▅▄▃▂▁▁▂▃▄▅▆▇██▇▆▅▄▃▂▁▁▂▃▄▅▆▇██▇▆▅▄▃▂▁                  │
│ Total: IN 45.2 GB  OUT 12.8 GB                                              │
└──────────────────────────────────────────────────────────────────────────────┘

Ultima actualizare: 2025-01-20 15:30:45 | Colectare la fiecare 60s | Date: 892 MB
```

### Raport Săptămânal

```
═══════════════════════════════════════════════════════════════════════════════
                         RAPORT RESURSE SĂPTĂMÂNAL
                         2025-01-13 până 2025-01-20
═══════════════════════════════════════════════════════════════════════════════

UTILIZARE CPU
─────────────────────────────────────────────────────────────────────────────
        Lun     Mar     Mie     Joi     Vin     Sâm     Dum     Med
Med:    34%     42%     38%     67%     45%     22%     18%     38%
Max:    78%     89%     72%     95%     82%     45%     34%     95%
Min:    12%     15%     14%     23%     18%      8%      6%      6%

⚠️  Joi 14:00-16:00: CPU ridicat susținut (>90%) - investighează job-uri batch

UTILIZARE MEMORIE
─────────────────────────────────────────────────────────────────────────────
Medie:   52% (8.3 GB / 16 GB)
Vârf:    78% la Joi 15:30 (12.5 GB)
Swap:    0 MB folosit (sănătos)

UTILIZARE DISC
─────────────────────────────────────────────────────────────────────────────
/         45% folosit (89 GB / 200 GB)  +2.3 GB săptămâna aceasta
/home     67% folosit (134 GB / 200 GB) +8.1 GB săptămâna aceasta
/var/log  23% folosit (4.6 GB / 20 GB)  +1.2 GB săptămâna aceasta

⚠️  /home crește 8 GB/săptămână - va fi plin în ~8 săptămâni

REȚEA
─────────────────────────────────────────────────────────────────────────────
Total IN:   312 GB
Total OUT:  89 GB
Vârf rată:  890 Mbps (Vin 10:30)

PROCESE TOP (după CPU mediu)
─────────────────────────────────────────────────────────────────────────────
1. postgres       23% CPU,  2.1 GB RAM
2. nginx          12% CPU,  450 MB RAM
3. node (myapp)    8% CPU,  890 MB RAM
4. redis           3% CPU,  1.2 GB RAM

═══════════════════════════════════════════════════════════════════════════════
```

---

## Schemă Bază Date (SQLite)

```sql
-- Main metrics table
CREATE TABLE metrics (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    cpu_percent REAL,
    cpu_user REAL,
    cpu_system REAL,
    cpu_iowait REAL,
    load_1m REAL,
    load_5m REAL,
    load_15m REAL,
    mem_total INTEGER,
    mem_used INTEGER,
    mem_free INTEGER,
    mem_cached INTEGER,
    swap_used INTEGER,
    disk_read_bytes INTEGER,
    disk_write_bytes INTEGER,
    net_rx_bytes INTEGER,
    net_tx_bytes INTEGER
);

-- Index for fast queries
CREATE INDEX idx_metrics_timestamp ON metrics(timestamp);

-- Table for generated alerts
CREATE TABLE alerts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    metric TEXT,
    value REAL,
    threshold REAL,
    message TEXT
);
```

---

## Structură Proiect

```
M06_Resource_Usage_Historian/
├── README.md
├── Makefile
├── src/
│   ├── historian.sh             # Main script
│   └── lib/
│       ├── collect.sh           # Metrics collection
│       ├── storage.sh           # DB interaction
│       ├── graph.sh             # ASCII graphs
│       ├── report.sh            # Report generation
│       ├── alert.sh             # Alerting system
│       └── daemon.sh            # Daemon functions
├── etc/
│   ├── historian.conf
│   └── thresholds.conf
├── sql/
│   ├── schema.sql
│   └── queries/
│       ├── daily_summary.sql
│       └── weekly_report.sql
├── tests/
│   ├── test_collect.sh
│   ├── test_graph.sh
│   └── sample_data.sql
└── docs/
    ├── INSTALL.md
    └── METRICS.md
```

---

## Indicii de Implementare

### Colectare metrici CPU

```bash
get_cpu_usage() {
    # Method 1: from /proc/stat
    local cpu_line
    cpu_line=$(head -1 /proc/stat)
    
    read -r _ user nice system idle iowait irq softirq <<< "$cpu_line"
    
    local total=$((user + nice + system + idle + iowait + irq + softirq))
    local used=$((total - idle - iowait))
    
    echo "scale=2; $used * 100 / $total" | bc
    
    # Method 2: top one-shot
    # top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}'
}

get_load_average() {
    cat /proc/loadavg | awk '{print $1, $2, $3}'
}
```

### Colectare metrici memorie

```bash
get_memory_stats() {
    local meminfo="/proc/meminfo"
    
    local total=$(awk '/MemTotal/ {print $2}' "$meminfo")
    local free=$(awk '/MemFree/ {print $2}' "$meminfo")
    local buffers=$(awk '/Buffers/ {print $2}' "$meminfo")
    local cached=$(awk '/^Cached/ {print $2}' "$meminfo")
    local swap_total=$(awk '/SwapTotal/ {print $2}' "$meminfo")
    local swap_free=$(awk '/SwapFree/ {print $2}' "$meminfo")
    
    local used=$((total - free - buffers - cached))
    local swap_used=$((swap_total - swap_free))
    
    echo "$total $used $free $cached $swap_used"
}
```

### Grafic ASCII simplu

```bash
draw_ascii_graph() {
    local -a values=("$@")
    local max_height=10
    local width=${#values[@]}
    
    # Find max for scaling
    local max=0
    for v in "${values[@]}"; do
        ((v > max)) && max=$v
    done
    
    # Draw from top to bottom
    for ((row = max_height; row >= 1; row--)); do
        local threshold=$((max * row / max_height))
        printf "%3d%% │" "$((row * 100 / max_height))"
        
        for v in "${values[@]}"; do
            if ((v >= threshold)); then
                printf "█"
            else
                printf " "
            fi
        done
        echo
    done
    
    # X axis
    printf "     └"
    printf '─%.0s' $(seq 1 "$width")
    echo
}
```

### Stocare SQLite

```bash
init_database() {
    local db="$1"
    sqlite3 "$db" << 'SQL'
CREATE TABLE IF NOT EXISTS metrics (
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    cpu_percent REAL,
    mem_used_kb INTEGER,
    disk_read_kb INTEGER,
    disk_write_kb INTEGER,
    net_rx_kb INTEGER,
    net_tx_kb INTEGER
);
CREATE INDEX IF NOT EXISTS idx_ts ON metrics(timestamp);
SQL
}

store_metrics() {
    local db="$1"
    local cpu="$2" mem="$3" disk_r="$4" disk_w="$5" net_rx="$6" net_tx="$7"
    
    sqlite3 "$db" "INSERT INTO metrics (cpu_percent, mem_used_kb, disk_read_kb, disk_write_kb, net_rx_kb, net_tx_kb) VALUES ($cpu, $mem, $disk_r, $disk_w, $net_rx, $net_tx);"
}

query_metrics() {
    local db="$1"
    local period="$2"  # e.g.: "-24 hours"
    
    sqlite3 -separator ',' "$db" \
        "SELECT strftime('%H:%M', timestamp), cpu_percent, mem_used_kb 
         FROM metrics 
         WHERE timestamp > datetime('now', '$period')
         ORDER BY timestamp;"
}
```

---

## Criterii Specifice de Evaluare

| Criteriu | Pondere | Descriere |
|-----------|--------|-------------|
| Colectare metrici | 20% | CPU, RAM, disc, rețea - date corecte |
| Stocare date | 15% | SQLite/CSV, rotație, integritate |
| Grafice ASCII | 20% | Vizualizare clară, scalare corectă |
| Rapoarte | 15% | Zilnice/săptămânale, export CSV |
| Mod daemon | 10% | Start/stop, interval configurabil |
| Funcționalități extra | 10% | Tendințe, detectare anomalii |
| Calitate cod + teste | 5% | ShellCheck, unit tests |
| Documentație | 5% | README, doc metrici |

---

## Resurse

- Documentație sistem fișiere `/proc`
- `man vmstat`, `man iostat`, `man sar`
- Documentație SQLite
- Seminar 3-4 - Procese, procesare text

---

*Proiect MEDIUM | Sisteme de Operare | ASE-CSIE*
