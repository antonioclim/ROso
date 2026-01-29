# M10: Process Tree Analyzer

> **Nivel:** MEDIUM | **Timp estimat:** 25-35 ore | **Bonus K8s:** +10%

---

## Descriere

Tool avansat pentru analiza ierarhiei de procese: vizualizare arbore cu relații parent-child, tracking resurse per proces și per grup, detectare procese orfane, zombie sau runaway, și export pentru analiză ulterioară.

---

## Obiective de Învățare

- Structura proceselor în Linux (PID, PPID, SID, PGID)
- Informații din `/proc` filesystem
- Vizualizare arborescentă în terminal
- Detectare anomalii în procese
- Relația cu cgroups și namespaces

---

## Cerințe Funcționale

### Obligatorii (pentru notă de trecere)

1. **Vizualizare arbore procese**
   - Afișare ierarhică (similar `pstree`)
   - Cu informații extinse (PID, user, CPU, RAM)
   - Filtrare după user, comandă, PID

2. **Analiza per proces**
   - CPU și memorie utilizată
   - Threads, file descriptors
   - Environment variables
   - Working directory, executable path

3. **Detectare anomalii**
   - Procese zombie (defunct)
   - Procese orfane (PPID=1)
   - High CPU/memory consumers
   - Procese cu FD leak (prea mulți file descriptors)

4. **Grupare și agregare**
   - Resurse per user
   - Resurse per session/process group
   - Top consumers

5. **Export**
   - JSON pentru procesare
   - DOT format pentru Graphviz
   - Text pentru documentare

### Opționale (pentru punctaj complet)

6. **Real-time monitoring** - Actualizare continuă (ca `top`)
7. **Process timeline** - Istoric porniri/opriri
8. **Container awareness** - Detectare procese în containere
9. **Kill/signal interface** - Trimitere semnale din tool
10. **Namespace support** - Vizualizare pe namespace-uri

---

## Interfață CLI

```bash
./proctree.sh <command> [opțiuni]

Comenzi:
  tree [pid]            Afișează arbore procese (de la PID sau root)
  info <pid>            Informații detaliate despre proces
  children <pid>        Lista copii (direct sau recursiv)
  analyze               Analiză completă sistem
  anomalies             Detectează procese problematice
  top                   Top consumers (CPU/RAM)
  watch [pid]           Monitorizare real-time
  export                Exportă date pentru analiză

Opțiuni:
  -u, --user USER       Filtrează după user
  -n, --name PATTERN    Filtrează după numele procesului
  -d, --depth N         Adâncime maximă arbore
  -s, --sort FIELD      Sortare: cpu|mem|pid|time
  -f, --format FMT      Format: text|json|dot
  -l, --long            Format lung cu detalii
  --show-threads        Include thread-uri
  --no-kernel           Exclude procese kernel
  --container           Doar procese din containere

Exemple:
  ./proctree.sh tree
  ./proctree.sh tree 1 --depth 3
  ./proctree.sh info $$
  ./proctree.sh anomalies
  ./proctree.sh top --sort mem -n 10
  ./proctree.sh export --format dot | dot -Tpng -o tree.png
```

---

## Exemple Output

### Process Tree

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    PROCESS TREE ANALYZER                                     ║
║                    Host: server01 | Processes: 234 | Threads: 892           ║
╚══════════════════════════════════════════════════════════════════════════════╝

PROCESS TREE
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

Legend: 🐳 = container | [Z] = zombie | ⚠️ = high resource

Total: 234 processes, 892 threads
System CPU: 15.2% | System Memory: 4.2GB / 16GB (26%)
```

### Process Info

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    PROCESS DETAILS: 15890 (vim)                             ║
╚══════════════════════════════════════════════════════════════════════════════╝

BASIC INFO
───────────────────────────────────────────────────────────────────────────────
  PID:          15890
  PPID:         15237 (bash)
  User:         antonio (1000)
  Group:        antonio (1000)
  State:        S (Sleeping)
  Started:      2025-01-20 15:30:45 (2h 15m ago)
  
EXECUTABLE
───────────────────────────────────────────────────────────────────────────────
  Command:      vim /home/antonio/project/main.py
  Executable:   /usr/bin/vim.basic
  CWD:          /home/antonio/project
  
RESOURCE USAGE
───────────────────────────────────────────────────────────────────────────────
  CPU:          0.2% (user: 0.15%, system: 0.05%)
  Memory:       28 MB (RSS)
  Virtual:      156 MB (VSZ)
  Shared:       8 MB
  Threads:      1
  
FILE DESCRIPTORS (12 open)
───────────────────────────────────────────────────────────────────────────────
  0  → /dev/pts/1 (stdin)
  1  → /dev/pts/1 (stdout)
  2  → /dev/pts/1 (stderr)
  3  → /home/antonio/project/main.py
  4  → /home/antonio/project/.main.py.swp
  ...

ENVIRONMENT (partial)
───────────────────────────────────────────────────────────────────────────────
  HOME=/home/antonio
  PATH=/usr/local/bin:/usr/bin:/bin
  SHELL=/bin/bash
  TERM=xterm-256color
  EDITOR=vim

HIERARCHY
───────────────────────────────────────────────────────────────────────────────
  Session:      15237 (bash)
  Process Group: 15890
  Terminal:     /dev/pts/1
  
  Ancestors:
    └── systemd(1) → sshd(1023) → sshd(15234) → bash(15237) → vim(15890)
```

### Anomalies Report

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    PROCESS ANOMALIES DETECTED                                ║
╚══════════════════════════════════════════════════════════════════════════════╝

🔴 ZOMBIE PROCESSES (2)
───────────────────────────────────────────────────────────────────────────────
  PID      PPID     Command              Since
  8923     8901     defunct              2h 45m
  9012     8901     defunct              1h 30m
  
  Parent: 8901 (python /opt/worker.py) - not reaping children!
  Action: Kill parent or fix code to call wait()

⚠️ HIGH CPU CONSUMERS (>50% sustained)
───────────────────────────────────────────────────────────────────────────────
  PID      User     CPU%     Duration    Command
  12456    mysql    85.2%    15m         mysqld (query)
  3240     1000     78.5%    8m          python myapp.py
  
🟡 HIGH MEMORY CONSUMERS (>1GB)
───────────────────────────────────────────────────────────────────────────────
  PID      User     Memory   %Total    Command
  12456    mysql    2.8 GB   17.5%     mysqld
  3240     1000     1.2 GB   7.5%      python myapp.py
  
⚠️ FILE DESCRIPTOR LEAKS (>1000 FDs)
───────────────────────────────────────────────────────────────────────────────
  PID      User     FDs      Limit     Command
  4567     www      2456     4096      node server.js
  
  Warning: Approaching FD limit, may cause "too many open files"

🟡 ORPHAN PROCESSES (PPID=1, not daemons)
───────────────────────────────────────────────────────────────────────────────
  PID      User     Started     Command
  7890     antonio  3d ago      /usr/bin/python old_script.py
  7891     antonio  3d ago      sleep 99999
  
  These may be leftover processes from crashed parents

SUMMARY
───────────────────────────────────────────────────────────────────────────────
  🔴 Critical:  2 (zombies)
  ⚠️ Warning:   5 (high resource, FD leak)
  🟡 Info:      2 (orphans)
```

---

## Structură Proiect

```
M10_Process_Tree_Analyzer/
├── README.md
├── Makefile
├── src/
│   ├── proctree.sh              # Script principal
│   └── lib/
│       ├── procinfo.sh          # Citire info din /proc
│       ├── tree.sh              # Construire și afișare arbore
│       ├── analyze.sh           # Analiză și detectare anomalii
│       ├── export.sh            # Export JSON/DOT
│       ├── watch.sh             # Real-time monitoring
│       └── utils.sh             # Funcții comune
├── etc/
│   └── proctree.conf
├── tests/
│   ├── test_procinfo.sh
│   ├── test_tree.sh
│   └── mock_proc/               # Mock /proc pentru teste
└── docs/
    ├── INSTALL.md
    └── PROC_FILESYSTEM.md
```

---

## Hints Implementare

### Citire informații proces din /proc

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
    
    # Memorie
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
    # Citește toate procesele
    while IFS='|' read -r pid ppid name state uid rss cmd; do
        PROC_INFO[$pid]="$name|$state|$uid|$rss|$cmd"
        CHILDREN[$ppid]+="$pid "
    done < <(get_all_processes)
}

print_tree() {
    local pid="${1:-1}"
    local prefix="${2:-}"
    local is_last="${3:-true}"
    
    # Obține info proces
    IFS='|' read -r name state uid rss cmd <<< "${PROC_INFO[$pid]}"
    
    # Afișează nodul curent
    local branch
    if [[ "$is_last" == "true" ]]; then
        branch="└── "
        child_prefix="${prefix}    "
    else
        branch="├── "
        child_prefix="${prefix}│   "
    fi
    
    echo "${prefix}${branch}${name}($pid) [MEM: ${rss}KB]"
    
    # Afișează copiii
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

### Detectare zombii

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
        # PPID=1 dar nu e daemon system
        if [[ "$ppid" == "1" && "$uid" != "0" ]]; then
            # Verifică dacă e lansat recent
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

## Criterii Evaluare Specifice

| Criteriu | Pondere | Descriere |
|----------|---------|-----------|
| Afișare arbore | 20% | Ierarhie corectă, formatare |
| Info per proces | 20% | CPU, RAM, FDs, env, etc. |
| Detectare anomalii | 20% | Zombies, orphans, resource hogs |
| Agregare/grupare | 15% | Per user, top consumers |
| Export | 10% | JSON, DOT funcțional |
| Real-time monitoring | 5% | Watch mode |
| Calitate cod + teste | 5% | ShellCheck, teste |
| Documentație | 5% | README, /proc doc |

---

## Resurse

- `man proc` - /proc filesystem
- `man ps`, `man pstree`
- Linux kernel documentation on processes
- Seminar 2 - Procese și semnale

---

*Proiect MEDIUM | Sisteme de Operare | ASE-CSIE*
