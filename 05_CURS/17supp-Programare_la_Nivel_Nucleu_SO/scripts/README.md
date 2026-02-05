# Scripturi Demo — Curs 17 Suplimentar: eBPF și Programare la Nivel Nucleu

> Sisteme de Operare | ASE București - CSIE | 2025-2026  
> by Revolvix

---

## Cuprins Scripturi

| Script | Limbaj | Scop | Complexitate |
|--------|--------|------|--------------|
| `netmonitor.py` | Python + BCC | Monitor trafic rețea cu eBPF | Avansată |
| `system_monitor.bt` | bpftrace | Trasare apeluri sistem și latențe | Avansată |

---

## Utilizare Rapidă

### Network Monitor (necesită root + BCC)

```bash
# Monitorizare toate conexiunile TCP noi
sudo python3 netmonitor.py

# Filtrare după port destinație
sudo python3 netmonitor.py --port 80
sudo python3 netmonitor.py --port 443

# Filtrare după nume proces
sudo python3 netmonitor.py --comm nginx
sudo python3 netmonitor.py --comm curl

# Filtrare după PID
sudo python3 netmonitor.py --pid 1234

# Combinație de filtre
sudo python3 netmonitor.py --port 443 --comm firefox

# Output în format JSON (pentru procesare)
sudo python3 netmonitor.py --json > connections.jsonl

# Mod verbose cu detalii adiționale
sudo python3 netmonitor.py --verbose
```

### System Monitor (necesită root + bpftrace)

```bash
# Rulare script complet
sudo bpftrace system_monitor.bt

# Trasare doar syscalls specifice
sudo bpftrace -e 'tracepoint:syscalls:sys_enter_open* { printf("%s opened %s\n", comm, str(args->filename)); }'

# Histogramă latență read()
sudo bpftrace -e 'tracepoint:syscalls:sys_enter_read { @start[tid] = nsecs; }
                  tracepoint:syscalls:sys_exit_read /@start[tid]/ { 
                      @latency = hist(nsecs - @start[tid]); 
                      delete(@start[tid]); 
                  }'

# Top procese după număr de syscalls
sudo bpftrace -e 'tracepoint:raw_syscalls:sys_enter { @[comm] = count(); }'

# Monitorizare page faults
sudo bpftrace -e 'software:page-faults:1 { @[comm] = count(); }'
```

---

## Legătura cu Conceptele din Curs

### Arhitectura eBPF (netmonitor.py)

Scriptul demonstrează ciclul complet eBPF:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         FLOW eBPF                                       │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  [User Space]                      [Kernel Space]                       │
│                                                                         │
│  netmonitor.py                                                          │
│       │                                                                 │
│       │ 1. Compilează cod C → bytecode eBPF                            │
│       │    (via BCC/LLVM)                                              │
│       ↓                                                                 │
│  ┌─────────┐      bpf()        ┌─────────────────┐                     │
│  │ Program │ ──────syscall────→│   Verificator   │                     │
│  │  eBPF   │                   │   eBPF          │                     │
│  └─────────┘                   └────────┬────────┘                     │
│                                         │                              │
│                                    2. Verifică:                        │
│                                    - Terminare garantată               │
│                                    - Acces memorie valid               │
│                                    - Fără pointeri invalizi            │
│                                         │                              │
│                                         ↓                              │
│                                ┌─────────────────┐                     │
│                                │   JIT Compiler  │                     │
│                                │ (bytecode→nativ)│                     │
│                                └────────┬────────┘                     │
│                                         │                              │
│                                         ↓                              │
│                                ┌─────────────────┐                     │
│                                │   Atașare la    │                     │
│                                │   kprobe/       │                     │
│                                │   tracepoint    │                     │
│                                └────────┬────────┘                     │
│                                         │                              │
│       ┌─────────────────────────────────┘                              │
│       │ 3. La fiecare eveniment:                                       │
│       │    - Execută program eBPF                                      │
│       │    - Scrie în BPF map                                         │
│       ↓                                                                 │
│  ┌─────────┐     perf_buffer    ┌─────────────────┐                    │
│  │ Python  │ ←─────read────────│    BPF Map      │                    │
│  │ callback│                   │ (ring buffer)   │                    │
│  └─────────┘                   └─────────────────┘                     │
│       │                                                                 │
│       │ 4. Procesare și afișare                                        │
│       ↓                                                                 │
│  [Terminal output]                                                      │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### Puncte de Ancorare (Hooks)

| Tip | Folosire în scripturi | Când se declanșează |
|-----|----------------------|---------------------|
| **kprobe** | `netmonitor.py` (tcp_connect, tcp_accept) | La intrare în funcție kernel |
| **kretprobe** | Return values | La ieșire din funcție kernel |
| **tracepoint** | `system_monitor.bt` (syscalls) | Evenimente predefinite în kernel |
| **uprobe** | Funcții userspace | La intrare în funcție din binary |
| **USDT** | Probes în aplicații | Marcaje explicite în cod |

### BPF Maps

Tipuri de maps folosite:
- **BPF_HASH**: Dicționar key-value (tracking connections)
- **BPF_PERF_OUTPUT**: Ring buffer pentru evenimente (user notification)
- **BPF_HISTOGRAM**: Agregări statistice (latency distribution)
- **BPF_ARRAY**: Array cu acces O(1)

### bpftrace Syntax (system_monitor.bt)

```
probe_type:probe_name /filter/ { action }

Exemple:
  tracepoint:syscalls:sys_enter_read    # Tracepoint pentru read()
  kprobe:vfs_read                       # Kprobe pentru vfs_read
  uprobe:/bin/bash:readline             # Uprobe în bash
  
Variabile built-in:
  pid, tid      - Process/Thread ID
  comm          - Nume proces (16 char)
  nsecs         - Timestamp nanosecunde
  args          - Argumente (pt tracepoints)
  retval        - Return value (pt ret probes)
  
Funcții:
  printf()      - Output formatat
  str()         - Conversie la string
  hist()        - Histogramă
  count()       - Contor
  @map[key]     - Acces map
```

---

## Exemple Output

### netmonitor.py

```
$ sudo python3 netmonitor.py --port 443
════════════════════════════════════════════════════════════════════════════════
eBPF NETWORK MONITOR — Tracking TCP connections (port filter: 443)
════════════════════════════════════════════════════════════════════════════════
TIME       PID    COMM             SADDR            SPORT  DADDR            DPORT
────────────────────────────────────────────────────────────────────────────────
10:15:23   1842   firefox          192.168.1.50     54321  142.250.185.68   443
10:15:23   1842   firefox          192.168.1.50     54322  142.250.185.68   443
10:15:24   1842   firefox          192.168.1.50     54323  151.101.1.140    443
10:15:25   2156   curl             192.168.1.50     54324  93.184.216.34    443
10:15:30   1842   firefox          192.168.1.50     54325  157.240.1.35     443
────────────────────────────────────────────────────────────────────────────────
[Connections: 5] [Ctrl+C to exit]
```

### system_monitor.bt

```
$ sudo bpftrace system_monitor.bt
Attaching 5 probes...

════════════════════════════════════════════════════════════════════════════════
SYSTEM MONITOR — Syscall tracing and latency analysis
════════════════════════════════════════════════════════════════════════════════

[Syscalls by process - last 5 seconds]
@syscalls[firefox]: 15234
@syscalls[Xorg]: 8421
@syscalls[pulseaudio]: 3210
@syscalls[bash]: 156

[Read latency histogram (nanoseconds)]
@read_latency:
[1K, 2K)              1523 |@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@|
[2K, 4K)               842 |@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                       |
[4K, 8K)               421 |@@@@@@@@@@@@@@                                      |
[8K, 16K)              156 |@@@@@                                               |
[16K, 32K)              42 |@                                                   |
[32K, 64K)              12 |                                                    |
[64K, 128K)              3 |                                                    |

[File opens - top 10]
@opens[/proc/stat]: 1542
@opens[/dev/null]: 823
@opens[/etc/passwd]: 156
@opens[/tmp/firefox_cache]: 89
...

^C
Cleaning up...
```

---

## Cerințe Sistem

### Kernel și Distribuție

- **Ubuntu 24.04** cu kernel 5.15+ (recomandat 6.0+)
- **BTF** (BPF Type Format) activat în kernel
- Drepturi root sau capabilities `CAP_BPF`, `CAP_PERFMON`

### Pachete Necesare

```bash
# BCC (BPF Compiler Collection)
sudo apt update
sudo apt install bpfcc-tools python3-bpfcc libbpfcc-dev

# bpftrace
sudo apt install bpftrace

# Headers kernel (pentru BTF)
sudo apt install linux-headers-$(uname -r)

# Opțional: pentru dezvoltare eBPF avansată
sudo apt install libbpf-dev clang llvm
```

### Verificare Suport eBPF

```bash
# Verificare versiune kernel
uname -r
# Minim: 5.8 pentru funcționalități moderne

# Verificare BTF disponibil
ls -la /sys/kernel/btf/vmlinux
# Trebuie să existe pentru BCC/bpftrace

# Verificare bpf() syscall disponibil
cat /proc/kallsyms | grep -w bpf
# Trebuie să apară __x64_sys_bpf sau similar

# Test rapid bpftrace
sudo bpftrace -e 'BEGIN { printf("eBPF works!\n"); exit(); }'

# Test rapid BCC
sudo python3 -c "from bcc import BPF; print('BCC works!')"
```

---

## Troubleshooting

| Problemă | Cauză | Soluție |
|----------|-------|---------|
| "BPF not supported" | Kernel fără CONFIG_BPF | Recompilează kernel sau folosește distribuție standard |
| "BTF not found" | Headers lipsă | `sudo apt install linux-headers-$(uname -r)` |
| "Permission denied" | Lipsă capabilities | Rulează cu `sudo` sau adaugă `CAP_BPF` |
| "Failed to load BPF program" | Eroare verificator | Verifică codul eBPF (limite, accese invalide) |
| "bcc module not found" | Python path greșit | `sudo apt install python3-bpfcc` |
| "Unknown tracepoint" | Kernel diferit | Verifică cu `sudo bpftrace -l 'tracepoint:*'` |

### Debugging eBPF

```bash
# Vezi toate tracepoints disponibile
sudo bpftrace -l 'tracepoint:*' | grep syscalls

# Vezi toate kprobes disponibile
sudo bpftrace -l 'kprobe:*' | grep tcp

# Verbose output BCC
sudo python3 netmonitor.py --debug 2>&1 | head -50

# Verifică programele eBPF încărcate
sudo bpftool prog list

# Verifică maps eBPF
sudo bpftool map list
```

---

## Exerciții Propuse

1. **Modificare netmonitor.py**: Adaugă tracking pentru UDP în plus față de TCP.

2. **Latency profiling**: Folosește bpftrace pentru a măsura latența write() și compară cu read().

3. **Process tracking**: Scrie un script bpftrace care afișează toate procesele care fac fork().

4. **Security monitoring**: Creează un monitor care alertează când un proces accesează `/etc/shadow`.

5. **Comparison**: Compară overhead-ul între `strace` și eBPF monitoring pentru același proces.

---

## Resurse Adiționale

- **Brendan Gregg's Blog**: https://www.brendangregg.com/ebpf.html
- **BCC Reference Guide**: https://github.com/iovisor/bcc/blob/master/docs/reference_guide.md
- **bpftrace Reference**: https://github.com/iovisor/bpftrace/blob/master/docs/reference_guide.md
- **eBPF.io**: https://ebpf.io/

---

*Materiale dezvoltate by Revolvix pentru ASE București - CSIE*  
*Sisteme de Operare | Anul I, Semestrul 2 | 2025-2026*