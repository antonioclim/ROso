# M11: Instrument Forensics Memorie

> **Nivel:** MEDIUM | **Timp estimat:** 25-35 ore | **Bonus K8s:** +10%

---

## Descriere

Instrument pentru analiză și forensics memorie: investigare utilizare memorie per proces, detectare memory leak-uri, analiză heap/stack, identificare fișiere mapate în memorie și generare rapoarte pentru troubleshooting și optimizare.

---

## Obiective de Învățare

- Structură memorie Linux (memorie virtuală, pagini)
- Informații din `/proc/[pid]/maps`, `/proc/meminfo`
- Detectare memory leak-uri și pattern-uri anormale
- Mapare memorie și memorie partajată
- Debugging și profiling memorie

---

## Cerințe Funcționale

### Obligatorii (pentru nota de trecere)

1. **Analiză sistem**
   - RAM total, folosit, liber, cached, buffers
   - Utilizare și activitate swap
   - Indicatori presiune memorie

2. **Analiză per proces**
   - RSS, VSZ, memorie partajată
   - Hărți memorie (heap, stack, libs, mmap)
   - Tendință utilizare în timp

3. **Detectare probleme**
   - Procese cu consum excesiv
   - Potențiale memory leak-uri (creștere continuă)
   - Evaluare risc OOM

4. **Hărți memorie**
   - Parsare `/proc/[pid]/maps`
   - Librării încărcate
   - Mapări anonime (heap)

5. **Raportare**
   - Snapshot sistem
   - Comparație între snapshot-uri
   - Export pentru analiză

### Opționale (pentru punctaj complet)

6. **Detectare leak-uri** - Monitorizare continuă cu alertare
7. **Analiză heap** - Analiză detaliată alocări
8. **Audit memorie partajată** - Segmente IPC, tmpfs
9. **NUMA awareness** - Distribuție pe noduri NUMA
10. **Integrare cu valgrind** - Rapoarte combinate

---

## Interfață CLI

```bash
./memtool.sh <command> [options]

Commands:
  overview              System memory usage summary
  top [n]               Top N processes by memory
  analyze <pid>         Detailed process analysis
  maps <pid>            Display memory maps
  compare <pid>         Compare snapshots (leak detection)
  snapshot <pid>        Save snapshot for comparison
  shared                List shared memory segments
  watch <pid>           Continuous monitoring
  report                Generate complete report

Options:
  -s, --sort FIELD      Sort: rss|vsz|shared|swap
  -n, --number N        Number of results
  -i, --interval SEC    Monitoring interval
  -o, --output FILE     Save output
  -f, --format FMT      Format: text|json|csv
  --human               Human-readable sizes
  --include-kernel      Include kernel memory

Examples:
  ./memtool.sh overview
  ./memtool.sh top 20 --sort rss
  ./memtool.sh analyze $$ --human
  ./memtool.sh maps $(pgrep nginx | head -1)
  ./memtool.sh snapshot 1234 && sleep 60 && ./memtool.sh compare 1234
```

---

## Exemple Output

### Privire Ansamblu Sistem

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    INSTRUMENT FORENSICS MEMORIE                              ║
║                    Host: server01 | Kernel: 5.15.0-91-generic               ║
╚══════════════════════════════════════════════════════════════════════════════╝

PRIVIRE ANSAMBLU MEMORIE SISTEM
═══════════════════════════════════════════════════════════════════════════════

Memorie Fizică: 16 GB
┌──────────────────────────────────────────────────────────────────────────────┐
│ [████████████████████████████▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░] │
│ ████ Folosită: 7.2 GB (45%)  ▓▓▓▓ Cached: 5.1 GB (32%)  ░░░░ Liberă: 3.7 GB│
└──────────────────────────────────────────────────────────────────────────────┘

Swap: 4 GB
┌──────────────────────────────────────────────────────────────────────────────┐
│ [██████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░] │
│ ████ Folosit: 512 MB (12.5%)                       ░░░░ Liber: 3.5 GB       │
└──────────────────────────────────────────────────────────────────────────────┘

DETALIERE MEMORIE
───────────────────────────────────────────────────────────────────────────────
  Total:           16,384 MB
  Folosită:         7,372 MB (45.0%)
  Liberă:           3,789 MB (23.1%)
  Buffere:            234 MB (1.4%)
  Cached:           5,123 MB (31.3%)
  Partajată:          456 MB (2.8%)
  Disponibilă:      8,456 MB (51.6%)  ← Efectiv disponibilă pentru aplicații
  
  Swap Total:       4,096 MB
  Swap Folosit:       512 MB (12.5%)
  Swap Liber:       3,584 MB

INDICATORI PRESIUNE MEMORIE
───────────────────────────────────────────────────────────────────────────────
  Page faults/sec:     1,234 (minor: 1,200, major: 34)
  Swap in/out:         12 MB/s in, 2 MB/s out
  Scor OOM:            Risc scăzut ✓
  Presiune memorie:    some (medie 10s: 2.3%)

TOP CONSUMATORI MEMORIE
───────────────────────────────────────────────────────────────────────────────
  PID      User       RSS        %MEM    Proces
  2234     postgres   1.8 GB     11.2%   postgresql
  3240     1000       1.2 GB     7.5%    python myapp.py
  2045     root       512 MB     3.2%    dockerd
  12456    mysql      456 MB     2.8%    mysqld
  8901     www-data   256 MB     1.6%    php-fpm
```

### Analiză Memorie Proces

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    ANALIZĂ MEMORIE: PID 3240 (python)                        ║
╚══════════════════════════════════════════════════════════════════════════════╝

INFO DE BAZĂ
───────────────────────────────────────────────────────────────────────────────
  Proces:     python /opt/myapp/main.py
  Utilizator: appuser (1000)
  Pornit:     2025-01-20 08:00:00 (acum 9h 45m)

REZUMAT MEMORIE
───────────────────────────────────────────────────────────────────────────────
  Mărime Virtuală (VSZ):  2.4 GB
  Set Rezident (RSS):     1.2 GB     ← Efectiv în RAM
  Memorie Partajată:      45 MB
  Memorie Privată:        1.15 GB    ← Specific proces
  Utilizare Swap:         0 MB
  
  RSS Vârf:               1.8 GB (la 14:30)
  Curent vs Vârf:         66% din vârf

DETALIERE HARTĂ MEMORIE
───────────────────────────────────────────────────────────────────────────────
  Categorie         Mărime      Count    Descriere
  ─────────────────────────────────────────────────────────────────────────────
  [heap]            890 MB      1        Alocări dinamice
  [stack]           8 MB        1        Stack thread
  Librării          156 MB      47       Librării partajate (.so)
  [anon]            234 MB      89       Mapări anonime
  Fișiere mapate    45 MB       12       Fișiere mmap'd
  ─────────────────────────────────────────────────────────────────────────────
  Total mapat:      1.3 GB

TOP LIBRĂRII DUPĂ MĂRIME
───────────────────────────────────────────────────────────────────────────────
  45 MB    /usr/lib/python3.10/site-packages/numpy/core/_multiarray_umath.so
  23 MB    /usr/lib/x86_64-linux-gnu/libpython3.10.so.1.0
  18 MB    /usr/lib/python3.10/site-packages/pandas/_libs/lib.so
  12 MB    /lib/x86_64-linux-gnu/libc.so.6
  8 MB     /usr/lib/python3.10/site-packages/scipy/···

TENDINȚĂ MEMORIE (ultimele 8 ore)
───────────────────────────────────────────────────────────────────────────────
RSS:
  1.8G │                    ▄▄▄▄
  1.5G │          ▄▄▄▄▄▄▄▄▄█████▄▄▄▄
  1.2G │▄▄▄▄▄▄▄▄▄██████████████████████▄▄▄▄▄▄▄▄▄▄▄▄▄
  0.9G │██████████████████████████████████████████████
       └──────────────────────────────────────────────
         08:00    10:00    12:00    14:00    16:00

  ⚠️ Memorie a atins vârful la 14:30, apoi s-a stabilizat
  📈 Rată creștere: +50MB/oră medie (posibil leak lent)

DETECTARE LEAK-URI
───────────────────────────────────────────────────────────────────────────────
  Status: ⚠️ POSIBIL LEAK DETECTAT
  
  Observații:
  - RSS a crescut 400 MB peste 8 ore
  - Heap-ul a crescut de la 600 MB la 890 MB
  - Fără scădere corespunzătoare
  
  Recomandare:
  - Profilează cu: valgrind --leak-check=full
  - Sau: python -m memory_profiler
```

### Comparație Memory Leak

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    COMPARAȚIE MEMORIE: PID 3240                              ║
║                    Interval: 60 secunde                                      ║
╚══════════════════════════════════════════════════════════════════════════════╝

COMPARAȚIE SNAPSHOT
───────────────────────────────────────────────────────────────────────────────
                        Înainte         După            Delta
  RSS:                  1,200 MB        1,215 MB        +15 MB ⚠️
  VSZ:                  2,400 MB        2,420 MB        +20 MB
  Heap:                 890 MB          905 MB          +15 MB ⚠️
  Fișiere mapate:       45 MB           45 MB           0
  Partajat:             45 MB           45 MB           0

MAPĂRI MEMORIE NOI
───────────────────────────────────────────────────────────────────────────────
  + [anon] 7f8a12340000-7f8a12440000 (1 MB) rw-p
  + [anon] 7f8a12440000-7f8a12540000 (1 MB) rw-p

ANALIZĂ
───────────────────────────────────────────────────────────────────────────────
  ⚠️ Avertisment: Heap-ul a crescut 15 MB în 60 secunde
  
  Rată leak: ~15 MB/minut = 900 MB/oră
  La această rată, OOM în: ~45 minute
  
  Cauze probabile:
  - Creștere cache fără limite
  - Pool conexiuni nu eliberează
  - Acumulare structuri date
  
  Acțiune: Profilează aplicația sau repornește
```

---

## Structură Proiect

```
M11_Memory_Forensics_Tool/
├── README.md
├── Makefile
├── src/
│   ├── memtool.sh               # Main script
│   └── lib/
│       ├── procmem.sh           # Per-process memory info
│       ├── sysmem.sh            # System memory info
│       ├── maps.sh              # Memory maps parsing
│       ├── leak.sh              # Leak detection
│       ├── snapshot.sh          # Snapshot and comparison
│       └── report.sh            # Report generation
├── etc/
│   └── memtool.conf
├── tests/
│   ├── test_procmem.sh
│   ├── test_leak.sh
│   └── leaky_program.c          # Test program with leak
└── docs/
    ├── INSTALL.md
    └── MEMORY_LINUX.md
```

---

## Indicii de Implementare

### Citire info memorie sistem

```bash
get_meminfo() {
    local meminfo="/proc/meminfo"
    
    declare -A mem
    while IFS=': ' read -r key value _; do
        mem[$key]=$value
    done < "$meminfo"
    
    echo "Total: ${mem[MemTotal]} kB"
    echo "Free: ${mem[MemFree]} kB"
    echo "Available: ${mem[MemAvailable]} kB"
    echo "Buffers: ${mem[Buffers]} kB"
    echo "Cached: ${mem[Cached]} kB"
    echo "SwapTotal: ${mem[SwapTotal]} kB"
    echo "SwapFree: ${mem[SwapFree]} kB"
}
```

### Info memorie proces

```bash
get_process_memory() {
    local pid="$1"
    
    # From /proc/[pid]/status
    local status="/proc/$pid/status"
    
    local vmrss vmsize vmswap
    vmrss=$(awk '/VmRSS/ {print $2}' "$status")
    vmsize=$(awk '/VmSize/ {print $2}' "$status")
    vmswap=$(awk '/VmSwap/ {print $2}' "$status")
    
    # From /proc/[pid]/statm (in pages)
    local statm
    read -r size resident shared text lib data dirty < "/proc/$pid/statm"
    
    local page_size
    page_size=$(getconf PAGE_SIZE)
    
    echo "RSS: $((resident * page_size / 1024)) kB"
    echo "Shared: $((shared * page_size / 1024)) kB"
    echo "Private: $(( (resident - shared) * page_size / 1024)) kB"
}
```

### Parsare hărți memorie

```bash
parse_maps() {
    local pid="$1"
    local maps="/proc/$pid/maps"
    
    declare -A categories
    
    while IFS=' ' read -r range perms offset dev inode pathname; do
        # Calculate size
        local start end size
        start=$((16#${range%-*}))
        end=$((16#${range#*-}))
        size=$(( (end - start) / 1024 ))  # in KB
        
        # Categorise
        case "$pathname" in
            "[heap]")   ((categories[heap]+=$size)) ;;
            "[stack]")  ((categories[stack]+=$size)) ;;
            "[vdso]"|"[vvar]"|"[vsyscall]") 
                        ((categories[kernel]+=$size)) ;;
            "")         ((categories[anon]+=$size)) ;;
            *.so*)      ((categories[libs]+=$size)) ;;
            *)          ((categories[files]+=$size)) ;;
        esac
    done < "$maps"
    
    for cat in "${!categories[@]}"; do
        echo "$cat: ${categories[$cat]} KB"
    done
}
```

### Detectare leak-uri

```bash
snapshot_memory() {
    local pid="$1"
    local snapshot_file="/tmp/memtool_${pid}_$(date +%s).snap"
    
    # Save all relevant data
    {
        echo "timestamp=$(date +%s)"
        echo "rss=$(awk '/VmRSS/ {print $2}' /proc/$pid/status)"
        echo "heap_size=$(awk '/\[heap\]/ {
            split($1, a, "-"); 
            print strtonum("0x"a[2]) - strtonum("0x"a[1])
        }' /proc/$pid/maps)"
        echo "maps_hash=$(md5sum /proc/$pid/maps | cut -d' ' -f1)"
    } > "$snapshot_file"
    
    echo "$snapshot_file"
}

compare_snapshots() {
    local snap1="$1"
    local snap2="$2"
    
    source "$snap1"
    local rss1=$rss heap1=$heap_size
    
    source "$snap2"
    local rss2=$rss heap2=$heap_size
    
    local rss_delta=$((rss2 - rss1))
    local heap_delta=$((heap2 - heap1))
    
    echo "RSS delta: $rss_delta KB"
    echo "Heap delta: $heap_delta KB"
    
    if ((rss_delta > 10240)); then  # > 10MB
        echo "⚠️ Significant memory growth detected"
    fi
}
```

---

## Criterii Specifice de Evaluare

| Criteriu | Pondere | Descriere |
|-----------|--------|-------------|
| Privire ansamblu sistem | 15% | Meminfo corect, calcule |
| Analiză proces | 25% | RSS, maps, detaliere |
| Detectare leak-uri | 20% | Snapshot, compare, alertă |
| Hărți memorie | 15% | Parsare, categorizare |
| Raportare | 10% | Format clar, export |
| Mod watch | 5% | Monitorizare continuă |
| Calitate cod + teste | 5% | ShellCheck, teste |
| Documentație | 5% | README, concepte memorie |

---

## Resurse

- `man proc` - /proc/[pid]/maps, /proc/[pid]/status
- `man free`, `man vmstat`
- Documentație Linux memory management
- Seminar 2-3 - Procese, memorie

---

*Proiect MEDIUM | Sisteme de Operare | ASE-CSIE*
