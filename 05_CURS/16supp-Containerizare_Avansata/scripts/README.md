# Scripturi Demo — Curs 16 Suplimentar: Containerizare Avansată

> Sisteme de Operare | ASE București - CSIE | 2025-2026  
> by Revolvix

---

## Cuprins Scripturi

| Script | Limbaj | Scop | Complexitate |
|--------|--------|------|--------------|
| `cgroup_monitor.py` | Python | Monitor cgroups v2 în timp real | Avansată |
| `mini_container.sh` | Bash | Container minimal cu namespaces | Avansată |

### Scripturi Partajate (din Cursul 15)

Următoarele scripturi sunt utilizate pentru testarea izolării de rețea și sunt partajate cu **Cursul 15 Suplimentar: Conectarea la Rețea**. Le găsiți în directorul `../15supp-Conectarea_la_Retea/scripts/`:

| Script | Locație | Scop în context containerizare |
|--------|---------|-------------------------------|
| `echo_server.py` | `../15supp-Conectarea_la_Retea/scripts/` | Server TCP pentru teste izolare rețea |
| `echo_client.py` | `../15supp-Conectarea_la_Retea/scripts/` | Client TCP pentru teste conectivitate |
| `network_diag.sh` | `../15supp-Conectarea_la_Retea/scripts/` | Diagnosticare rețea din container |
| `firewall_basic.sh` | `../15supp-Conectarea_la_Retea/scripts/` | Reguli iptables pentru containere |

> **Notă**: Aceste scripturi sunt identice funcțional. Partajarea elimină duplicarea și asigură consistența între cursuri.

---

## Utilizare Rapidă

### Monitor Cgroups v2

```bash
# Monitorizare toate grupurile cgroups
python3 cgroup_monitor.py

# Monitorizare container Docker specific (după ID sau nume)
python3 cgroup_monitor.py --docker <container_id>
python3 cgroup_monitor.py --docker nginx

# Monitorizare cale cgroup specifică
python3 cgroup_monitor.py /sys/fs/cgroup/user.slice/

# Refresh la fiecare 2 secunde
python3 cgroup_monitor.py --interval 2

# Output JSON pentru procesare ulterioară
python3 cgroup_monitor.py --json > metrics.json
```

### Mini-Container (necesită root)

```bash
# Container minimal cu izolare completă
sudo ./mini_container.sh

# Cu limitare memorie (100MB)
sudo ./mini_container.sh --memory 100M

# Cu limitare CPU (50% din un core)
sudo ./mini_container.sh --cpu 0.5

# Cu izolare rețea (namespace network separat)
sudo ./mini_container.sh --net-isolate

# Cu root filesystem personalizat
sudo ./mini_container.sh --rootfs /path/to/rootfs

# Combinație: container limitat cu bash interactiv
sudo ./mini_container.sh --memory 50M --cpu 0.25 --net-isolate -- /bin/bash
```

### Teste Izolare Rețea (folosind scripturile partajate din Cursul 15)

```bash
# Path către scripturile partajate
SHARED_SCRIPTS="../15supp-Conectarea_la_Retea/scripts"

# În container: pornește server
sudo ./mini_container.sh --net-isolate -- python3 $SHARED_SCRIPTS/echo_server.py --port 8080

# Din host: testează că NU poți conecta (izolat)
python3 $SHARED_SCRIPTS/echo_client.py --host 127.0.0.1 --port 8080  # Ar trebui să eșueze

# Diagnosticare rețea din interiorul containerului
sudo ./mini_container.sh --net-isolate -- bash $SHARED_SCRIPTS/network_diag.sh
```

---

## Legătura cu Conceptele din Curs

### Cgroups v2 (cgroup_monitor.py)

Scriptul citește metrici din ierarhia `/sys/fs/cgroup`:

```
/sys/fs/cgroup/
├── cgroup.controllers      # Controllere disponibile
├── cgroup.subtree_control  # Controllere active pentru copii
├── cpu.stat               # Statistici CPU (usage_usec, user_usec, system_usec)
├── memory.current         # Memorie folosită curent
├── memory.max             # Limită memorie
├── memory.swap.current    # Swap folosit
├── pids.current           # Număr procese/thread-uri
├── pids.max               # Limită PID-uri
├── io.stat                # Statistici I/O per device
└── <subgroup>/            # Subgrupuri (ex: docker/, user.slice/)
```

**Metrici expuse:**
- **CPU**: timp total, user, system (în microsecunde)
- **Memorie**: curent, maxim, swap
- **PID-uri**: număr curent, limită
- **I/O**: bytes citite/scrise per device

### Namespaces (mini_container.sh)

Scriptul folosește `unshare` pentru izolare:

| Namespace | Flag | Izolează |
|-----------|------|----------|
| Mount | `--mount` | Filesystem mounts |
| UTS | `--uts` | Hostname, domainname |
| IPC | `--ipc` | System V IPC, POSIX queues |
| Network | `--net` | Network stack complet |
| PID | `--pid` | Process ID space |
| User | `--user` | UID/GID mappings |
| Cgroup | `--cgroup` | Cgroup root |

```bash
# Echivalent manual:
unshare --mount --uts --ipc --net --pid --fork --mount-proc /bin/bash
```

### Docker Internals

Docker folosește aceleași mecanisme:
1. **Namespaces** pentru izolare
2. **Cgroups** pentru limite resurse
3. **Union FS** (overlay2) pentru layere imagine
4. **Seccomp** pentru filtrare syscalls
5. **Capabilities** pentru privilegii granulare

---

## Exemple Output

### cgroup_monitor.py

```
$ sudo python3 cgroup_monitor.py --docker nginx
═══════════════════════════════════════════════════════════════════════════
CGROUP MONITOR v2 — Container: nginx (a1b2c3d4e5f6)
Path: /sys/fs/cgroup/system.slice/docker-a1b2c3d4e5f6.scope
═══════════════════════════════════════════════════════════════════════════

┌─────────────────────────────────────────────────────────────────────────┐
│ CPU                                                                     │
├─────────────────────────────────────────────────────────────────────────┤
│ Total:  45.2s  │  User: 38.1s (84%)  │  System: 7.1s (16%)             │
│ Usage:  2.3%   │  Throttled: 0 periods                                  │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│ MEMORY                                                                  │
├─────────────────────────────────────────────────────────────────────────┤
│ Current: 128.5 MB  │  Max: 512.0 MB  │  Usage: 25.1%                   │
│ Swap:    0 B       │  Swap Max: 0 B                                     │
│ Cache:   45.2 MB   │  RSS: 83.3 MB                                      │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│ PIDS                                                                    │
├─────────────────────────────────────────────────────────────────────────┤
│ Current: 12  │  Max: 100  │  Usage: 12%                                 │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│ I/O                                                                     │
├─────────────────────────────────────────────────────────────────────────┤
│ Read:  234.5 MB  │  Write: 12.3 MB  │  Device: 8:0 (sda)               │
└─────────────────────────────────────────────────────────────────────────┘

[Refresh: 1s] [Press Ctrl+C to exit]
```

### mini_container.sh

```
$ sudo ./mini_container.sh --memory 100M --net-isolate
═══════════════════════════════════════════════════════════════
MINI CONTAINER — Demonstrație Namespaces + Cgroups
═══════════════════════════════════════════════════════════════

[1/4] Creez cgroup cu limite...
      Memory limit: 100M
      CPU limit: unlimited
      
[2/4] Creez namespaces (mount, uts, ipc, net, pid)...

[3/4] Configurez environment izolat...
      Hostname: container-a1b2c3
      Root FS: /
      
[4/4] Execut shell în container...

═══════════════════════════════════════════════════════════════
Ești acum într-un container izolat!
  - Hostname: container-a1b2c3
  - PID namespace: PID 1 = acest shell
  - Network: izolat (doar loopback)
  - Memory limit: 100M
  
Comenzi utile:
  hostname          # Verifică hostname izolat
  ps aux            # Vezi doar procesele din container
  ip addr           # Vezi doar interfețele container
  cat /proc/1/cgroup  # Verifică cgroup
  
Tastează 'exit' pentru a ieși.
═══════════════════════════════════════════════════════════════

root@container-a1b2c3:/# ps aux
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.0   4636  3712 pts/0    S    10:30   0:00 /bin/bash
root        15  0.0  0.0   7060  1536 pts/0    R+   10:30   0:00 ps aux

root@container-a1b2c3:/# ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
```

---

## Cerințe Sistem

### Hardware/Software

- Ubuntu 24.04 cu kernel 5.15+ (pentru cgroups v2 complet)
- Python 3.8+ cu module standard (`pathlib`, `dataclasses`)
- Cgroups v2 activat (unified hierarchy)
- Drepturi root pentru `mini_container.sh` și monitorizare Docker

### Verificare Cgroups v2

```bash
# Verificare că sistemul folosește cgroups v2
mount | grep cgroup2
# Output așteptat: cgroup2 on /sys/fs/cgroup type cgroup2 ...

# Verificare controllere disponibile
cat /sys/fs/cgroup/cgroup.controllers
# Output așteptat: cpuset cpu io memory hugetlb pids rdma misc

# Dacă vezi /sys/fs/cgroup/cpu, /sys/fs/cgroup/memory separat → cgroups v1
# Pentru WSL2: cgroups v2 e implicit din Windows 11
```

### Instalare Pachete

```bash
# Pachete necesare
sudo apt update
sudo apt install util-linux iproute2 procps

# Pentru Docker monitoring
sudo apt install docker.io
sudo usermod -aG docker $USER  # Logout/login necesar
```

---

## Troubleshooting

| Problemă | Cauză | Soluție |
|----------|-------|---------|
| "Cgroup nu există" | Path greșit sau container oprit | Verifică cu `docker ps` și folosește ID corect |
| "Permission denied" | Nu ai root | Rulează cu `sudo` |
| "cgroups v1 detected" | Sistem legacy | Adaugă `systemd.unified_cgroup_hierarchy=1` la kernel cmdline |
| "unshare: operation not permitted" | Kernel restricționat | Verifică `sysctl kernel.unprivileged_userns_clone` |
| Memorie nu e limitată | Controller neactivat | `echo "+memory" > /sys/fs/cgroup/cgroup.subtree_control` |
| Scripturi partajate lipsesc | Path greșit | Verifică existența `../15supp-Conectarea_la_Retea/scripts/` |

---

## Exerciții Propuse

1. **Observare limite**: Pornește `mini_container.sh --memory 50M` și rulează `stress --vm 1 --vm-bytes 100M`. Ce se întâmplă?

2. **Izolare PID**: În container, rulează `ps aux`. De ce vezi doar procesele tale?

3. **Docker comparison**: Compară output-ul `cgroup_monitor.py --docker <id>` cu `docker stats <id>`.

4. **Network namespace**: Creează două containere cu `mini_container.sh --net-isolate`. Pot comunica între ele? De ce?

5. **Teste izolare rețea**: Folosind scripturile partajate din Cursul 15, testează conectivitatea între host și container cu `echo_server.py`/`echo_client.py`.

---

*Materiale dezvoltate by Revolvix pentru ASE București - CSIE*  
*Sisteme de Operare | Anul I, Semestrul 2 | 2025-2026*
