# M10: Analizor Arbore Procese

> **Nivel:** MEDIUM | **Timp estimat:** 25-35 ore | **Bonus K8s:** +10%

---

## Descriere

> 💡 **Notă instructor:** Acest proiect va transforma modul în care înțelegi Linux. După finalizare, nu vei mai privi niciodată `ps aux` la fel. Am văzut studenți care au rezolvat probleme de producție în stagii folosind competențe din acest proiect. Sistemul de fișiere `/proc` este unul dintre cele mai elegante design-uri Linux — acest proiect te învață să îl citești ca pe o carte.

Instrument avansat pentru analiză ierarhie procese: vizualizare arbore cu relații părinte-copil, urmărire resurse per proces și per grup, detectare procese orfane/zombie/scăpate de sub control și export pentru analiză ulterioară.

---

## Obiective de Învățare

- Structură procese Linux (PID, PPID, SID, PGID)
- Informații din sistemul de fișiere `/proc`
- Vizualizare arbore în terminal
- Detectare anomalii procese
- Relație cu cgroups și namespace-uri

---

## Cerințe Funcționale

### Obligatorii (pentru nota de trecere)

1. **Vizualizare arbore procese**
   - Afișare ierarhică (similar `pstree`)
   - Cu informații extinse (PID, utilizator, CPU, RAM)
   - Filtrare după utilizator, comandă, PID

2. **Analiză per proces**
   - Utilizare CPU și memorie
   - Thread-uri, descriptori fișiere
   - Variabile environment
   - Director lucru, cale executabil

3. **Detectare anomalii**
   - Procese zombie (defunct)
   - Procese orfane (PPID=1)
   - Consumatori mari CPU/memorie
   - Procese cu FD leak (prea mulți descriptori fișiere)

4. **Grupare și agregare**
   - Resurse per utilizator
   - Resurse per sesiune/grup procese
   - Top consumatori

5. **Export**
   - JSON pentru procesare
   - Format DOT pentru Graphviz
   - Text pentru documentație

### Opționale (pentru punctaj complet)

6. **Monitorizare timp real** - Actualizare continuă (ca `top`)
7. **Timeline procese** - Istoric start/stop
8. **Container awareness** - Detectare procese în containere
9. **Interfață kill/semnal** - Trimitere semnale din instrument
10. **Suport namespace** - Vizualizare pe namespace-uri

---

## Interfață CLI

```bash
./proctree.sh <command> [options]

Commands:
  tree [pid]            Display process tree (from PID or root)
  info <pid>            Detailed information about process
  children <pid>        List children (direct or recursive)
  analyze               Complete system analysis
  anomalies             Detect problematic processes
  top                   Top consumers (CPU/RAM)
  watch [pid]           Real-time monitoring
  export                Export data for analysis

Options:
  -u, --user USER       Filter by user
  -d, --depth N         Max tree depth
  -f, --format FMT      Output format (text|json|dot)
  -s, --sort FIELD      Sort by field (cpu|mem|pid|name)
  -n, --limit N         Limit results
  --threads             Include threads
  --env                 Include environment variables
  --fds                 Include file descriptors

Examples:
  ./proctree.sh tree 1 --depth 3
  ./proctree.sh info $$
  ./proctree.sh anomalies
  ./proctree.sh top --sort mem -n 10
  ./proctree.sh export --format dot | dot -Tpng -o tree.png
```

---

## Exemple Output

### Arbore Procese

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    ANALIZOR ARBORE PROCESE                                   ║
║                    Host: server01 | Procese: 234 | Thread-uri: 892          ║
╚══════════════════════════════════════════════════════════════════════════════╝

ARBORE PROCESE
═══════════════════════════════════════════════════════════════════════════════

systemd(1) root [CPU: 0.1%, MEM: 12MB]
├── systemd-journald(456) root [CPU: 0.3%, MEM: 45MB]
├── systemd-udevd(489) root [CPU: 0.0%, MEM: 8MB]
├── sshd(1023) root [CPU: 0.0%, MEM: 5MB]
│   └── sshd(15234) root [CPU: 0.0%, MEM: 6MB]
│       └── sshd(15236) antonio [CPU: 0.0%, MEM: 6MB]
│           └── bash(15237) antonio [CPU: 0.0%, MEM: 4MB]
│               └── vim(15890) antonio [CPU: 0.2%, MEM: 28MB]
├── nginx(2045) root [CPU: 0.0%, MEM: 3MB]
│   ├── nginx(2046) www-data [CPU: 1.2%, MEM: 45MB]
│   ├── nginx(2047) www-data [CPU: 0.8%, MEM: 42MB]
│   ├── nginx(2048) www-data [CPU: 0.9%, MEM: 43MB]
│   └── nginx(2049) www-data [CPU: 1.1%, MEM: 44MB]
├── postgresql(2234) postgres [CPU: 2.3%, MEM: 256MB]
│   ├── postgres(2235) postgres [CPU: 0.1%, MEM: 12MB] (checkpointer)
│   ├── postgres(2236) postgres [CPU: 0.2%, MEM: 15MB] (background writer)
│   ├── postgres(2237) postgres [CPU: 0.1%, MEM: 10MB] (walwriter)
│   └── postgres(2238) postgres [CPU: 5.2%, MEM: 180MB] (connection)
├── dockerd(3001) root [CPU: 0.5%, MEM: 89MB]
│   └── containerd(3012) root [CPU: 0.3%, MEM: 45MB]
│       └── containerd-shim(3234) root [CPU: 0.0%, MEM: 12MB]
│           └── python(3240) 1000:1000 [CPU: 8.5%, MEM: 512MB] 🐳 myapp
└── cron(1890) root [CPU: 0.0%, MEM: 2MB]

Legendă: 🐳 = container | [Z] = zombie | ⚠️ = resurse mari

Total: 234 procese, 892 thread-uri
CPU sistem: 15.2% | Memorie sistem: 4.2GB / 16GB (26%)
```

### Info Proces

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    DETALII PROCES: 15890 (vim)                              ║
╚══════════════════════════════════════════════════════════════════════════════╝

INFO DE BAZĂ
───────────────────────────────────────────────────────────────────────────────
  PID:          15890
  PPID:         15237 (bash)
  Utilizator:   antonio (1000)
  Grup:         antonio (1000)
  Stare:        S (Sleeping)
  Pornit:       2025-01-20 15:30:45 (acum 2h 15m)
  
EXECUTABIL
───────────────────────────────────────────────────────────────────────────────
  Comandă:      vim /home/antonio/project/main.py
  Executabil:   /usr/bin/vim.basic
  CWD:          /home/antonio/project
  
UTILIZARE RESURSE
───────────────────────────────────────────────────────────────────────────────
  CPU:          0.2% (user: 0.15%, system: 0.05%)
  Memorie:      28 MB (RSS)
  Virtuală:     156 MB (VSZ)
  Partajată:    8 MB
  Thread-uri:   1
  
DESCRIPTORI FIȘIERE (12 deschise)
───────────────────────────────────────────────────────────────────────────────
  0  → /dev/pts/1 (stdin)
  1  → /dev/pts/1 (stdout)
  2  → /dev/pts/1 (stderr)
  3  → /home/antonio/project/main.py
  4  → /home/antonio/project/.main.py.swp
  ···

ENVIRONMENT (parțial)
───────────────────────────────────────────────────────────────────────────────
  HOME=/home/antonio
  PATH=/usr/local/bin:/usr/bin:/bin
  SHELL=/bin/bash
  TERM=xterm-256color
  EDITOR=vim

IERARHIE
───────────────────────────────────────────────────────────────────────────────
  Sesiune:      15237 (bash)
  Grup procese: 15890
  Terminal:     /dev/pts/1
  
  Strămoși:
    └── systemd(1) → sshd(1023) → sshd(15234) → bash(15237) → vim(15890)
```

### Raport Anomalii

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    ANOMALII PROCESE DETECTATE                                ║
╚══════════════════════════════════════════════════════════════════════════════╝

🔴 PROCESE ZOMBIE (2)
───────────────────────────────────────────────────────────────────────────────
  PID      PPID     Comandă              Din
  8923     8901     defunct              2h 45m
  9012     8901     defunct              1h 30m
  
  Părinte: 8901 (python /opt/worker.py) - nu colectează copiii!
  Acțiune: Omoară părinte sau repară cod să apeleze wait()

⚠️ CONSUMATORI CPU MARI (>50% susținut)
───────────────────────────────────────────────────────────────────────────────
  PID      User     CPU%     Durată      Comandă
  12456    mysql    85.2%    15m         mysqld (query)
  3240     1000     78.5%    8m          python myapp.py
  
🟡 CONSUMATORI MEMORIE MARI (>1GB)
───────────────────────────────────────────────────────────────────────────────
  PID      User     Memorie  %Total    Comandă
  12456    mysql    2.8 GB   17.5%     mysqld
  3240     1000     1.2 GB   7.5%      python myapp.py
  
⚠️ LEAK-URI DESCRIPTORI FIȘIERE (>1000 FD-uri)
───────────────────────────────────────────────────────────────────────────────
  PID      User     FD-uri   Limită    Comandă
  4567     www      2456     4096      node server.js
  
  Avertisment: Apropiere de limita FD, poate cauza "too many open files"

🟡 PROCESE ORFANE (PPID=1, nu daemon-uri)
───────────────────────────────────────────────────────────────────────────────
  PID      User     Pornit      Comandă
  7890     antonio  acum 3z     /usr/bin/python old_script.py
  7891     antonio  acum 3z     sleep 99999
  
  Acestea pot fi procese rămase de la părinți crash-uiți

REZUMAT
───────────────────────────────────────────────────────────────────────────────
  🔴 Critice:   2 (zombies)
  ⚠️ Avertizări: 5 (resurse mari, FD leak)
  🟡 Info:       2 (orfane)
```

---

## Structură Proiect

```
M10_Process_Tree_Analyzer/
├── README.md
├── Makefile
├── src/
│   ├── proctree.sh              # Main script
│   └── lib/
│       ├── procinfo.sh          # Read info from /proc
│       ├── tree.sh              # Build and display tree
│       ├── analyze.sh           # Analysis and anomaly detection
│       ├── export.sh            # JSON/DOT export
│       ├── watch.sh             # Real-time monitoring
│       └── utils.sh             # Common functions
├── etc/
│   └── proctree.conf
├── tests/
│   ├── test_procinfo.sh
│   ├── test_tree.sh
│   └── mock_proc/               # Mock /proc for tests
└── docs/
    ├── INSTALL.md
    └── PROC_FILESYSTEM.md
```

---

## Indicii de Implementare

### Citire info proces din /proc

```bash
get_process_info() {
    local pid="$1"
    local proc_dir="/proc/$pid"
    
    [[ -d "$proc_dir" ]] || return 1
    
    # Status
    local status
    status=$(cat "$proc_dir/status" 2>/dev/null)
    
    local name ppid state uid
    name=$(echo "$status" | awk '/^Name:/ {print $2}')
    ppid=$(echo "$status" | awk '/^PPid:/ {print $2}')
    state=$(echo "$status" | awk '/^State:/ {print $2}')
    uid=$(echo "$status" | awk '/^Uid:/ {print $2}')
    
    # Memory
    local rss
    rss=$(echo "$status" | awk '/^VmRSS:/ {print $2}')
    
    # Command line
    local cmdline
    cmdline=$(tr '\0' ' ' < "$proc_dir/cmdline" 2>/dev/null)
    
    echo "$pid|$ppid|$name|$state|$uid|$rss|$cmdline"
}

get_all_processes() {
    for pid_dir in /proc/[0-9]*; do
        local pid="${pid_dir##*/}"
        get_process_info "$pid" 2>/dev/null
    done
}
```

### Construire arbore

```bash
declare -A CHILDREN
declare -A PROC_INFO

build_tree() {
    # Read all processes
    while IFS='|' read -r pid ppid name state uid rss cmd; do
        PROC_INFO[$pid]="$name|$state|$uid|$rss|$cmd"
        CHILDREN[$ppid]+="$pid "
    done < <(get_all_processes)
}

print_tree() {
    local pid="${1:-1}"
    local prefix="${2:-}"
    local is_last="${3:-true}"
    
    # Get process info
    IFS='|' read -r name state uid rss cmd <<< "${PROC_INFO[$pid]}"
    
    # Display current node
    local branch
    if [[ "$is_last" == "true" ]]; then
        branch="└── "
        child_prefix="${prefix}    "
    else
        branch="├── "
        child_prefix="${prefix}│   "
    fi
    
    echo "${prefix}${branch}${name}($pid) [MEM: ${rss}KB]"
    
    # Display children
    local children="${CHILDREN[$pid]}"
    local child_array=($children)
    local count=${#child_array[@]}
    local i=0
    
    for child in $children; do
        ((i++))
        local last=$( ((i == count)) && echo "true" || echo "false" )
        print_tree "$child" "$child_prefix" "$last"
    done
}
```

### Detectare zombies

```bash
find_zombies() {
    while IFS='|' read -r pid ppid name state uid rss cmd; do
        if [[ "$state" == "Z" ]]; then
            echo "ZOMBIE|$pid|$ppid|$name"
        fi
    done < <(get_all_processes)
}

find_orphans() {
    while IFS='|' read -r pid ppid name state uid rss cmd; do
        # PPID=1 but not a system daemon
        if [[ "$ppid" == "1" && "$uid" != "0" ]]; then
            # Check if recently started
            local start_time
            start_time=$(stat -c %Y "/proc/$pid" 2>/dev/null)
            
            echo "ORPHAN|$pid|$name|$uid"
        fi
    done < <(get_all_processes)
}
```

### Export DOT pentru Graphviz

```bash
export_dot() {
    echo "digraph process_tree {"
    echo "    rankdir=TB;"
    echo "    node [shape=box];"
    
    while IFS='|' read -r pid ppid name state uid rss cmd; do
        local color="white"
        [[ "$state" == "Z" ]] && color="red"
        [[ "$state" == "R" ]] && color="green"
        
        echo "    \"$pid\" [label=\"$name\\n($pid)\" fillcolor=$color style=filled];"
        [[ "$ppid" != "0" ]] && echo "    \"$ppid\" -> \"$pid\";"
    done < <(get_all_processes)
    
    echo "}"
}
```

---

## ⚠️ Capcane Comune

> Bazat pe submissions din anii precedenți, acestea sunt greșelile pe care studenții le fac cel mai des:

### 1. Condiții de Cursă în /proc
**Problemă:** Un proces se termină între listare și citire info.
**Soluție:** Verifică întotdeauna dacă fișierele există și gestionează erorile cu grație.

### 2. Nu Gestionează Thread-urile Kernel
**Problemă:** Thread-urile kernel (ca kworker) crash-uiesc parser-ul.
**Soluție:** Verifică dacă `/proc/PID/exe` este lizibil — thread-urile kernel nu au executabil.

### 3. Construire Arbore Ineficientă
**Problemă:** Citire /proc de mai multe ori pentru fiecare traversare arbore.
**Soluție:** Construiește structura de date arbore o dată, apoi traversează în memorie.

### 4. Permisiuni Lipsă
**Problemă:** Nu poate citi /proc/PID/environ pentru procese deținute de alți utilizatori.
**Soluție:** Documentează limitarea, cere sudo pentru analiză completă, sau sari cu grație.

---

## Criterii Specifice de Evaluare

| Criteriu | Pondere | Descriere |
|-----------|--------|-------------|
| Afișare arbore | 20% | Ierarhie corectă, formatare |
| Info per proces | 20% | CPU, RAM, FD-uri, env, etc. |
| Detectare anomalii | 20% | Zombies, orfane, consumatori resurse |
| Agregare/grupare | 15% | Per utilizator, top consumatori |
| Export | 10% | JSON, DOT funcțional |
| Monitorizare timp real | 5% | Mod watch |
| Calitate cod + teste | 5% | ShellCheck, teste |
| Documentație | 5% | README, doc /proc |

---

## Resurse

- `man proc` - Sistem fișiere /proc
- `man ps`, `man pstree`
- Documentație kernel Linux despre procese
- Seminar 2 - Procese și semnale

---

*Proiect MEDIUM | Sisteme de Operare | ASE-CSIE*
