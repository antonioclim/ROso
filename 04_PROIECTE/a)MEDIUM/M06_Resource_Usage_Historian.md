# M06: Resource Usage Historian

> **Nivel:** MEDIUM | **Timp estimat:** 25-35 ore | **Bonus K8s:** +10%

---

## Descriere

Sistem de colectare, stocare și analiză istorică a utilizării resurselor (CPU, RAM, disk, network). Include vizualizare în terminal cu grafice ASCII, detectare anomalii și predicție trend-uri pentru capacity planning.

---

## Obiective de Învățare

- Colectare metrici sistem (`/proc`, `vmstat`, `iostat`)
- Stocare time-series data (SQLite sau text structurat)
- Vizualizare date în terminal (grafice ASCII)
- Analiză statistică de bază (medie, std dev, trend)
- Alertare bazată pe threshold și anomalii

---

## Cerințe Funcționale

### Obligatorii (pentru notă de trecere)

1. **Colectare metrici**
   - CPU: utilizare per core, load average
   - Memorie: used, free, cached, swap
   - Disk: utilizare per partiție, I/O wait
   - Network: bytes in/out per interfață

2. **Stocare date**
   - Format: SQLite sau CSV cu timestamp
   - Rotație: păstrare configurabilă (7/30/90 zile)
   - Compresie pentru date vechi

3. **Vizualizare terminal**
   - Grafice ASCII pentru fiecare metrică
   - Perioadă selectabilă (hour/day/week/month)
   - Comparație între perioade

4. **Rapoarte**
   - Daily/weekly/monthly summaries
   - Export CSV pentru analiză externă
   - Top consumers (procese)

5. **Daemon mode**
   - Colectare la interval configurabil
   - Start/stop/status
   - Minimal overhead

### Opționale (pentru punctaj complet)

6. **Trend analysis** - Predicție utilizare viitoare
7. **Anomaly detection** - Alertă la valori neobișnuite
8. **Process tracking** - Istoric utilizare per proces
9. **Alerting** - Email/webhook la threshold
10. **Web dashboard** - Simple HTTP server cu grafice

---

## Interfață CLI

```bash
./historian.sh <command> [opțiuni]

Comenzi:
  start                 Pornește colectarea (daemon)
  stop                  Oprește daemon-ul
  status                Status daemon și ultimele valori
  collect               Colectare one-shot
  show <metric>         Afișează grafic pentru metrică
  report [period]       Generează raport (hour|day|week|month)
  export <file>         Export date CSV
  query <sql>           Query direct pe baza de date
  cleanup               Șterge date vechi

Metrici disponibile:
  cpu                   Utilizare CPU (total și per core)
  memory                Utilizare memorie
  disk                  Utilizare disk și I/O
  network               Trafic rețea
  load                  Load average
  all                   Toate metricile

Opțiuni:
  -p, --period PERIOD   Perioadă: 1h|6h|24h|7d|30d (default: 24h)
  -i, --interval SEC    Interval colectare (default: 60)
  -f, --format FMT      Format output: ascii|json|csv
  -w, --width N         Lățime grafic (default: 80)
  --no-color            Fără culori
  --threshold PCT       Alertă peste acest procent

Exemple:
  ./historian.sh start -i 30
  ./historian.sh show cpu -p 7d
  ./historian.sh show memory --width 120
  ./historian.sh report week -f csv > report.csv
  ./historian.sh query "SELECT * FROM metrics WHERE cpu > 90"
```

---

## Exemple Output

### Dashboard Real-time

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    RESOURCE USAGE HISTORIAN                                  ║
║                    Host: server01 | Uptime: 45d 12h                         ║
╚══════════════════════════════════════════════════════════════════════════════╝

┌─ CPU Usage (last 24h) ───────────────────────────────────────────────────────┐
│ 100%│                              ▄▄                                        │
│  80%│                    ▄▄       ████                                       │
│  60%│        ▄▄         ████     ██████    ▄▄                               │
│  40%│       ████   ▄▄  ██████   ████████  ████                              │
│  20%│▄▄▄▄▄▄██████▄████▄████████▄██████████████▄▄▄▄▄▄▄▄▄▄▄▄                  │
│   0%└────────────────────────────────────────────────────────────────────────│
│     00:00    04:00    08:00    12:00    16:00    20:00    now                │
│     Min: 12%  Max: 87%  Avg: 34%  Current: 23%                              │
└──────────────────────────────────────────────────────────────────────────────┘

┌─ Memory Usage (last 24h) ────────────────────────────────────────────────────┐
│ 16G │████████████████████████████████████████████████████████████████       │
│ 12G │████████████████████████████████████████████████████████▓▓▓▓▓▓▓▓       │
│  8G │██████████████████████████████████████▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░       │
│  4G │████████████████▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░░░░░░░░░░░░░░░░       │
│  0G └────────────────────────────────────────────────────────────────────────│
│     ████ Used (8.2G)  ▓▓▓▓ Cached (4.1G)  ░░░░ Free (3.7G)                  │
└──────────────────────────────────────────────────────────────────────────────┘

┌─ Disk I/O (last 24h) ────────────────────────────────────────────────────────┐
│ Read:  ▁▂▃▄▅▆▇█▇▆▅▄▃▂▁▁▂▃▄▅▆▇████▇▆▅▄▃▂▁▁▂▃▄▅▆▇█▇▆▅▄▃▂▁▁▂▃▄▅▆▇█            │
│ Write: ▁▁▂▃▄▅▆▇█▇▆▅▄▃▂▁▁▁▂▃▄▅▆████████▇▆▅▄▃▂▁▁▂▃▄▅▆▇█▇▆▅▄▃▂▁▁▂▃            │
│ Peak read: 450 MB/s at 14:30  |  Peak write: 320 MB/s at 15:45              │
└──────────────────────────────────────────────────────────────────────────────┘

┌─ Network Traffic (last 24h) ─────────────────────────────────────────────────┐
│ eth0 IN:  ▂▃▄▅▆▇████▇▆▅▄▃▂▂▃▄▅▆▇████▇▆▅▄▃▂▂▃▄▅▆▇████▇▆▅▄▃▂                  │
│ eth0 OUT: ▁▂▃▄▅▆▇██▇▆▅▄▃▂▁▁▂▃▄▅▆▇██▇▆▅▄▃▂▁▁▂▃▄▅▆▇██▇▆▅▄▃▂▁                  │
│ Total: IN 45.2 GB  OUT 12.8 GB                                              │
└──────────────────────────────────────────────────────────────────────────────┘

Last update: 2025-01-20 15:30:45 | Collecting every 60s | Data: 892 MB
```

### Weekly Report

```
═══════════════════════════════════════════════════════════════════════════════
                         WEEKLY RESOURCE REPORT
                         2025-01-13 to 2025-01-20
═══════════════════════════════════════════════════════════════════════════════

CPU USAGE
─────────────────────────────────────────────────────────────────────────────
        Mon     Tue     Wed     Thu     Fri     Sat     Sun     Avg
Avg:    34%     42%     38%     67%     45%     22%     18%     38%
Max:    78%     89%     72%     95%     82%     45%     34%     95%
Min:    12%     15%     14%     23%     18%      8%      6%      6%

⚠️  Thursday 14:00-16:00: Sustained high CPU (>90%) - investigate batch jobs

MEMORY USAGE
─────────────────────────────────────────────────────────────────────────────
Average: 52% (8.3 GB / 16 GB)
Peak:    78% at Thu 15:30 (12.5 GB)
Swap:    0 MB used (healthy)

DISK USAGE
─────────────────────────────────────────────────────────────────────────────
/         45% used (89 GB / 200 GB)  +2.3 GB this week
/home     67% used (134 GB / 200 GB) +8.1 GB this week
/var/log  23% used (4.6 GB / 20 GB)  +1.2 GB this week

⚠️  /home growing 8 GB/week - will be full in ~8 weeks

NETWORK
─────────────────────────────────────────────────────────────────────────────
Total IN:   312 GB
Total OUT:  89 GB
Peak rate:  890 Mbps (Fri 10:30)

TOP PROCESSES (by average CPU)
─────────────────────────────────────────────────────────────────────────────
1. postgres       23% CPU,  2.1 GB RAM
2. nginx          12% CPU,  450 MB RAM
3. node (myapp)    8% CPU,  890 MB RAM
4. redis           3% CPU,  1.2 GB RAM

═══════════════════════════════════════════════════════════════════════════════
```

---

## Schema Bază de Date (SQLite)

```sql
-- Tabelă principală metrici
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

-- Index pentru query-uri rapide
CREATE INDEX idx_metrics_timestamp ON metrics(timestamp);

-- Tabelă pentru alertele generate
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
│   ├── historian.sh             # Script principal
│   └── lib/
│       ├── collect.sh           # Colectare metrici
│       ├── storage.sh           # Interacțiune DB
│       ├── graph.sh             # Grafice ASCII
│       ├── report.sh            # Generare rapoarte
│       ├── alert.sh             # Sistem alertare
│       └── daemon.sh            # Funcții daemon
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

## Hints Implementare

### Colectare metrici CPU

```bash
get_cpu_usage() {
    # Metodă 1: din /proc/stat
    local cpu_line
    cpu_line=$(head -1 /proc/stat)
    
    read -r _ user nice system idle iowait irq softirq <<< "$cpu_line"
    
    local total=$((user + nice + system + idle + iowait + irq + softirq))
    local used=$((total - idle - iowait))
    
    echo "scale=2; $used * 100 / $total" | bc
    
    # Metodă 2: top one-shot
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
    
    # Găsește max pentru scalare
    local max=0
    for v in "${values[@]}"; do
        ((v > max)) && max=$v
    done
    
    # Desenează de sus în jos
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
    
    # Axa X
    printf "     └"
    printf '─%.0s' $(seq 1 "$width")
    echo
}
```

### Stocare în SQLite

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
    local period="$2"  # ex: "-24 hours"
    
    sqlite3 -separator ',' "$db" \
        "SELECT strftime('%H:%M', timestamp), cpu_percent, mem_used_kb 
         FROM metrics 
         WHERE timestamp > datetime('now', '$period')
         ORDER BY timestamp;"
}
```

---

## Criterii Evaluare Specifice

| Criteriu | Pondere | Descriere |
|----------|---------|-----------|
| Colectare metrici | 20% | CPU, RAM, disk, network - date corecte |
| Stocare date | 15% | SQLite/CSV, rotație, integritate |
| Grafice ASCII | 20% | Vizualizare clară, scalare corectă |
| Rapoarte | 15% | Daily/weekly, export CSV |
| Daemon mode | 10% | Start/stop, interval configurabil |
| Funcționalități extra | 10% | Trend, anomaly detection |
| Calitate cod + teste | 5% | ShellCheck, teste unitare |
| Documentație | 5% | README, metrics doc |

---

## Resurse

- `/proc` filesystem documentation
- `man vmstat`, `man iostat`, `man sar`
- SQLite documentation
- Seminar 3-4 - Procese, text processing

---

*Proiect MEDIUM | Sisteme de Operare | ASE-CSIE*
