# Sisteme de Operare - Săptămâna 3: Procese

> by Revolvix | ASE București - CSIE | Anul I, Semestrul 2 | 2025-2026

---

## Obiectivele Săptămânii

După parcurgerea materialelor din această săptămână, vei putea să:

1. Definești conceptul de proces și să-l diferențiezi de program
2. Descrii stările unui proces și tranzițiile între ele
3. Explici structura Process Control Block (PCB) și rolul său
4. Demonstrezi operații cu procese în Linux folosind comenzi și /proc
5. Analizezi algoritmul de creare procese (fork) și implicațiile sale

---

## Context aplicativ (scenariu didactic): Cum poate un procesor să ruleze Spotify, Chrome și VS Code "simultan"?

Ai un laptop cu 4 core-uri. Dar în Task Manager vezi 200+ procese. Cum e posibil? Răspunsul: nu rulează simultan - procesorul "jonglează" între ele atât de repede (mii de ori pe secundă) încât creează iluzia paralelismului.

Fiecare switch între procese se numește comutare de context și durează microsecunde. În acest timp, SO-ul salvează tot starea procesului curent și restaurează starea următorului proces. Totul invizibil pentru tine.

> 💡 Gândește-te: De ce crezi că un calculator "îngheață" când are prea multe procese?

---

## Conținut Curs (3/14)

### 1. Program vs. Proces

#### Definiție Formală

> Procesul este o instanță în execuție a unui program, reprezentând unitatea de bază a activității într-un sistem de operare modern. Un proces include codul programului, starea curentă a execuției (registre, program counter), stiva, heap-ul și resursele alocate. (Silberschatz et al., 2018)

Formal, un proces P poate fi definit ca un tuplu:
```
P = (Code, Data, Stack, Heap, PCB)
```

unde PCB (Process Control Block) conține metadatele de gestiune.

#### Explicație Intuitivă

Imaginează-ți o rețetă de prăjitură (programul) și actul de a face prăjitura (procesul):

- Rețeta (program): Stă în carte, nu face nimic singură, e pasivă
- Prepararea (proces): Acțiune activă - ai ingrediente pe masă, cuptor încălzit, mâinile murdare

Diferențe cheie:
| Rețetă (Program) | Preparare (Proces) |
|------------------|-------------------|
| Text pe hârtie | Acțiune în desfășurare |
| Un singur exemplar | Poți face 5 prăjituri simultan |
| Nu consumă resurse | Consumă ingrediente (memorie), cuptor (CPU) |
| Statică | Dinamic - stare se schimbă |

Mai multe procese din același program: Poți deschide 3 ferestre Chrome (3 procese) din același program `/usr/bin/chrome`.

#### Componentele unui Proces

```
┌─────────────────────────────────────────────────────┐
│              SPAȚIUL DE ADRESE AL PROCESULUI         │
├─────────────────────────────────────────────────────┤
│  Adrese mari                                         │
│  ┌─────────────────────────────────────────────┐    │
│  │              KERNEL SPACE                    │    │ (inaccesibil direct)
│  │          (mapare partajată)                 │    │
│  ├─────────────────────────────────────────────┤    │
│  │              STACK                          │    │ ↓ crește în jos
│  │         (variabile locale,                  │    │
│  │          adrese de return)                  │    │
│  ├─────────────────────────────────────────────┤    │
│  │                                             │    │
│  │           SPAȚIU LIBER                      │    │
│  │                                             │    │
│  ├─────────────────────────────────────────────┤    │
│  │              HEAP                           │    │ ↑ crește în sus
│  │         (alocare dinamică:                  │    │
│  │          malloc, new)                       │    │
│  ├─────────────────────────────────────────────┤    │
│  │              BSS                            │    │ (variabile neinițializate)
│  ├─────────────────────────────────────────────┤    │
│  │              DATA                           │    │ (variabile inițializate)
│  ├─────────────────────────────────────────────┤    │
│  │              TEXT                           │    │ (codul executabil)
│  └─────────────────────────────────────────────┘    │
│  Adrese mici (0x0)                                  │
└─────────────────────────────────────────────────────┘
```

---

### 2. Stările unui Proces

#### Definiție Formală

> Diagrama de stări a procesului (Process State Diagram) este un automat finit determinist care modelează ciclul de viață al unui proces. Stările reprezintă stadii distincte ale execuției, iar tranzițiile sunt declanșate de evenimente sistem sau acțiuni ale scheduler-ului.

Formal, automatul poate fi descris ca:
```
M = (Q, Σ, δ, q₀, F)
unde:
  Q = {new, ready, running, waiting, terminated}
  Σ = {admitted, dispatch, interrupt, I/O_wait, I/O_done, exit}
  q₀ = new
  F = {terminated}
```

#### Explicație Intuitivă

Imaginează-ți un **restaurant** unde procesele sunt clienți:

| Stare | În restaurant | Explicație |
|-------|---------------|------------|
| NEW | Clientul intră în restaurant | Procesul a fost creat, dar nu e încă în sistem |
| READY | Clientul stă la coadă | Gata de execuție, așteaptă CPU |
| RUNNING | Clientul e servit | Procesul rulează pe CPU |
| WAITING | Clientul așteaptă mâncarea | Așteaptă I/O sau alt eveniment |
| TERMINATED | Clientul a plecat | Procesul s-a terminat |

#### Diagrama Completă

```
                    ┌─────────────┐
        create      │             │     terminate
    ─────────────►  │     NEW     │  ─────────────►
                    │             │
                    └──────┬──────┘
                           │ admitted
                           ▼
                    ┌─────────────┐
                    │             │
         ┌─────────►│    READY    │◄─────────┐
         │          │   (queue)   │          │
         │          └──────┬──────┘          │
         │                 │                 │
         │   I/O or event  │ scheduler      │ interrupt
         │   completion    │ dispatch       │ (preemption)
         │                 ▼                 │
         │          ┌─────────────┐          │
         │          │             │          │
         └──────────│   RUNNING   │──────────┘
                    │   (on CPU)  │
                    └──────┬──────┘
                           │ I/O or event wait
                           ▼
                    ┌─────────────┐
                    │             │
                    │   WAITING   │
                    │  (blocked)  │
                    └─────────────┘
```

#### Codurile de Stare în Linux

```bash
# Vizualizare stări
ps aux | head -5
# USER PID %CPU %MEM VSZ RSS TTY STAT START TIME COMMAND

# Coloana STAT:
# R = Running sau Runnable (în ready queue)
# S = Sleeping (interruptible) - așteaptă eveniment
# D = Disk sleep (uninterruptible) - așteaptă I/O disc
# T = Stopped (SIGSTOP sau debugger)
# Z = Zombie - terminat dar părintele n-a citit exit status
# I = Idle kernel thread
# + = foreground process group
# < = high priority
# N = low priority (nice)
# L = pages locked in memory
# s = session leader

# Exemple
ps aux | grep -E "^USER|R |D |Z "
```

---

### 3. Process Control Block (PCB)

#### Definiție Formală

> Process Control Block (PCB), numit și Task Control Block (TCB), este structura de date centrală care conține toate informațiile necesare pentru gestionarea unui proces. PCB-ul permite sistemului de operare să suspende și să reia execuția unui proces, realizând comutarea de context. (Tanenbaum, 2015)

În Linux, PCB-ul este structura `task_struct` din kernel (definită în `include/linux/sched.h`), cu ~700+ câmpuri!

#### Explicație Intuitivă

PCB-ul e ca dosarul personal al unui angajat la HR:

| Informație HR | Echivalent PCB |
|---------------|----------------|
| Număr legitimație | PID (Process ID) |
| Stare angajare | State (running, ready, etc.) |
| Poziția în firmă | Priority |
| Biroul curent | Program Counter (unde a rămas) |
| Documentele pe birou | Registre CPU |
| Proiectele curente | Open files |
| Bugetul alocat | Memory limits |
| Șeful direct | Parent PID |

Când șeful (scheduler-ul) îți zice "pauză, vine altul la birou", tot ce ai pe birou se salvează în dosar (PCB). Când revii, deschizi dosarul și continui de unde ai rămas.

#### Structura PCB

```
┌─────────────────────────────────────────────┐
│          PROCESS CONTROL BLOCK              │
├─────────────────────────────────────────────┤
│ ┌─────────────────────────────────────────┐ │
│ │ IDENTIFICARE                            │ │
│ │ • PID (Process ID)                      │ │
│ │ • PPID (Parent PID)                     │ │
│ │ • UID, GID (User/Group ID)              │ │
│ │ • Session ID, Process Group             │ │
│ └─────────────────────────────────────────┘ │
│ ┌─────────────────────────────────────────┐ │
│ │ STARE EXECUȚIE                          │ │
│ │ • State (ready, running, etc.)          │ │
│ │ • Program Counter                       │ │
│ │ • CPU Registers (snapshot complet)      │ │
│ │ • Stack Pointer                         │ │
│ │ • Flags (carry, zero, overflow, etc.)   │ │
│ └─────────────────────────────────────────┘ │
│ ┌─────────────────────────────────────────┐ │
│ │ SCHEDULING                              │ │
│ │ • Priority (nice value, RT priority)    │ │
│ │ • Scheduling class (CFS, RT, etc.)      │ │
│ │ • CPU time used                         │ │
│ │ • Time slice remaining                  │ │
│ └─────────────────────────────────────────┘ │
│ ┌─────────────────────────────────────────┐ │
│ │ MEMORIE                                 │ │
│ │ • Page table pointer                    │ │
│ │ • Memory limits                         │ │
│ │ • Memory maps (VMA list)                │ │
│ │ • Shared memory segments                │ │
│ └─────────────────────────────────────────┘ │
│ ┌─────────────────────────────────────────┐ │
│ │ I/O & FILES                             │ │
│ │ • File descriptor table                 │ │
│ │ • Current working directory             │ │
│ │ • Root directory                        │ │
│ │ • umask                                 │ │
│ └─────────────────────────────────────────┘ │
│ ┌─────────────────────────────────────────┐ │
│ │ SEMNALE                                 │ │
│ │ • Pending signals                       │ │
│ │ • Signal handlers                       │ │
│ │ • Signal masks                          │ │
│ └─────────────────────────────────────────┘ │
│ ┌─────────────────────────────────────────┐ │
│ │ ACCOUNTING                              │ │
│ │ • Start time                            │ │
│ │ • User/System CPU time                  │ │
│ │ • Resource usage (rusage)               │ │
│ └─────────────────────────────────────────┘ │
└─────────────────────────────────────────────┘
```

#### Explorare în Linux

```bash
# PID-ul shell-ului curent
echo $$

# Conținutul "PCB-ului" vizibil în /proc
ls /proc/$$/

# Informații de bază (status)
cat /proc/$$/status | head -30

# Câmpuri importante:
# Name: bash ← numele procesului
# State: S (sleeping) ← starea
# Pid: 12345 ← PID
# PPid: 12344 ← Parent PID
# Uid: 1000 1000 ← User IDs (real, effective, saved, fs)
# Gid: 1000 1000 ← Group IDs
# VmPeak: 12000 kB ← Peak virtual memory
# VmSize: 11500 kB ← Current virtual memory
# VmRSS: 4000 kB ← Resident Set Size (in RAM)
# Threads: 1 ← Number of threads

# File descriptors deschise
ls -la /proc/$$/fd/
# 0 -> /dev/pts/0 (stdin)
# 1 -> /dev/pts/0 (stdout)
# 2 -> /dev/pts/0 (stderr)

# Memory maps
cat /proc/$$/maps | head -10

# Linia de comandă
cat /proc/$$/cmdline | tr '\0' ' '

# Current working directory
readlink /proc/$$/cwd

# Executable
readlink /proc/$$/exe
```

---

### 4. Algoritmul fork(): Crearea Proceselor

#### Definiție Formală

> fork() este un system call POSIX care creează un nou proces (copil) prin duplicarea procesului apelant (părinte). Procesul copil este o copie aproape identică a părintelui: primește copii ale segmentelor de date, heap și stack, dar partajează segmentul de cod (text) și resurse read-only prin Copy-on-Write (CoW).

Semnătura:
```c
pid_t fork(void);
// Returnează:
//   - În părinte: PID-ul copilului (> 0)
//   - În copil: 0
//   - La eroare: -1
```

#### Explicație Intuitivă

Imaginează-ți mitoza celulară:
- O celulă (procesul părinte) se divide
- Rezultă două celule aproape identice
- Fiecare continuă să trăiască independent
- Au același ADN (cod), dar evoluează diferit

Sau: xerox-ul magic
1. Ai un dosar (procesul părinte)
2. Faci o copie la xerox (fork)
3. Acum ai 2 dosare identice
4. Fiecare poate fi modificat independent

După fork():
- Ambele procese continuă execuția de la instrucțiunea de după `fork()`
- Singura diferență: valoarea returnată
- Părinte vede PID-ul copilului
- Copilul vede 0

#### Context Istoric

| An | Eveniment | Semnificație |
|----|-----------|--------------|
| 1969 | fork() în UNIX v1 | Ken Thompson, Bell Labs |
| 1971 | fork()+exec() model | Separarea creare/execuție - design influent |
| 1983 | POSIX standardizează fork() | Portabilitate garantată |
| 1995 | Linux introduce vfork() | Optimizare pentru fork+exec |
| 2002 | Copy-on-Write în Linux 2.4+ | Fork devine O(1) în loc de O(n) |
| 2008 | clone() extins | Baza pentru threads și containere |

> 💡 Fun fact: Designul fork()+exec() a fost considerat "temporar" de Thompson, dar s-a dovedit atât de elegant încât a supraviețuit 50+ ani!

#### Mecanismul fork()

```
ÎNAINTE DE FORK:
┌────────────────────────────┐
│      PROCES PĂRINTE        │
│  PID: 1000                 │
│  ┌─────────┬─────────┐     │
│  │  Code   │  Data   │     │
│  ├─────────┼─────────┤     │
│  │  Heap   │  Stack  │     │
│  └─────────┴─────────┘     │
│  Page Table: PT_parent     │
│  Files: [stdin,stdout,err] │
└────────────────────────────┘

─────────── fork() ───────────

DUPĂ FORK (Copy-on-Write):
┌────────────────────────┐        ┌────────────────────────┐
│    PROCES PĂRINTE      │        │     PROCES COPIL       │
│  PID: 1000             │        │  PID: 1001             │
│  fork() returns: 1001  │        │  fork() returns: 0     │
│                        │        │                        │
│  Page Table: PT_p      │        │  Page Table: PT_c      │
│      │                 │        │      │                 │
│      │   ┌─────────────┴────────┴──────┘                 │
│      │   │                                               │
│      ▼   ▼    PAGINI FIZICE (partajate read-only)       │
│  ┌─────────────────────────────────────────────────┐    │
│  │  Code (RO)  │  Data (CoW)  │  Stack (CoW)      │    │
│  └─────────────────────────────────────────────────┘    │
│                                                          │
│  La prima SCRIERE într-o pagină CoW:                    │
│  → Se face copie reală a paginii                        │
│  → Procesul modificator primește propria copie          │
└──────────────────────────────────────────────────────────┘
```

#### Costuri și Trade-off-uri

| Aspect | Detalii |
|--------|---------|
| Cost temporal | ~100μs pe sisteme moderne (datorită CoW) |
| Cost memorie | Minim inițial (doar page tables), crește la scriere |
| Overhead | Creare PCB, copiere page tables, setup signal handlers |
| Copy-on-Write | Amână copierea efectivă până la modificare |

Trade-off-uri:
| Pro | Con |
|-----|-----|
| Simplu de folosit | Costisitor dacă copilul doar exec() |
| Copilul moștenește totul | Memoria poate crește rapid dacă ambele scriu |
| Izolare completă | Fork bomb poate crăpa sistemul |
| Baza pentru paralelism | Nu ideal pentru threads |

Alternativă modernă: `clone()` (Linux-specific) permite control fin asupra ce se partajează.

#### Implementare Comparativă

| Aspect | Linux | Windows | macOS |
|--------|-------|---------|-------|
| System call | `fork()`, `clone()`, `vfork()` | `CreateProcess()` | `fork()` (POSIX) |
| Model | fork()+exec() | Create process cu parametri | fork()+exec() |
| CoW | ✅ Complet | N/A (nu are fork) | ✅ Complet |
| Threads | `clone(CLONE_VM\|...)` | `CreateThread()` | `pthread_create()` |
| Kernel struct | `task_struct` | `EPROCESS` | `proc` |

De ce Windows nu are fork()?
Windows a ales un model diferit: `CreateProcess()` creează un proces nou de la zero, specificând programul de rulat. E mai complex dar evită overhead-ul fork-ului când nu e nevoie de duplicare.

#### Reproducere în Python și Bash

Python:
```python
#!/usr/bin/env python3
"""
Demonstrație fork() în Python.

Arată:
- Cum funcționează duplicarea procesului
- Diferența între părinte și copil
- Partajarea fișierelor deschise
- Copy-on-Write în acțiune
"""

import os
import sys
import time

def demonstrate_fork():
    print(f"[Părinte original] PID: {os.getpid()}")
    
    # Variabilă înainte de fork - va fi "copiată"
    shared_value = 100
    
    print("\n--- Apelăm fork() ---\n")
    
    pid = os.fork()
    
    if pid < 0:
        print("Fork a eșuat!", file=sys.stderr)
        sys.exit(1)
    
    elif pid == 0:
        # === SUNTEM ÎN PROCESUL COPIL ===
        print(f"[Copil] Sunt copilul! PID: {os.getpid()}, PPID: {os.getppid()}")
        print(f"[Copil] fork() mi-a returnat: {pid} (adică 0)")
        print(f"[Copil] shared_value = {shared_value}")
        
        # Modificăm variabila - CoW va face copie
        shared_value = 999
        print(f"[Copil] După modificare, shared_value = {shared_value}")
        
        time.sleep(1)
        print(f"[Copil] Termin execuția.")
        sys.exit(0)  # De reținut: copilul trebuie să facă exit!
    
    else:
        # === SUNTEM ÎN PROCESUL PĂRINTE ===
        print(f"[Părinte] Am creat copilul cu PID: {pid}")
        print(f"[Părinte] Eu sunt PID: {os.getpid()}")
        print(f"[Părinte] fork() mi-a returnat: {pid}")
        print(f"[Părinte] shared_value = {shared_value}")
        
        # Așteptăm copilul să termine
        child_pid, status = os.waitpid(pid, 0)
        print(f"\n[Părinte] Copilul {child_pid} s-a terminat cu status {status}")
        print(f"[Părinte] shared_value încă = {shared_value} (CoW!)")

def demonstrate_fork_tree():
    """Creează un arbore de procese."""
    print("\n" + "="*50)
    print("ARBORE DE PROCESE")
    print("="*50 + "\n")
    
    print(f"[Root] PID: {os.getpid()}")
    
    for i in range(2):
        pid = os.fork()
        if pid == 0:
            # Copil
            print(f"  [Copil {i+1}] PID: {os.getpid()}, PPID: {os.getppid()}")
            time.sleep(0.5)
            sys.exit(0)
    
    # Părintele așteaptă toți copiii
    for _ in range(2):
        os.wait()
    
    print("[Root] Toți copiii au terminat.")

if __name__ == "__main__":
    demonstrate_fork()
    demonstrate_fork_tree()
```

Bash:
```bash
#!/bin/bash
#
# Demonstrație fork în Bash
# În Bash, fork se face implicit cu & (background) sau subshell ()
#

echo "=== Script principal PID: $$ ==="

# Metoda 1: Subshell (implicit fork)
(
    echo "  Subshell PID: $$ (păstrează variabila, dar e alt proces)"
    echo "  Subshell PPID: $PPID"
    sleep 1
)

# Metoda 2: Proces în background
echo "Lansez proces în background..."
sleep 2 &
CHILD_PID=$!
echo "Copil lansat cu PID: $CHILD_PID"

# Metoda 3: Funcție în subshell
my_function() {
    echo "  În funcție, PID: $$"
}

my_function        # Rulează în același proces
(my_function)      # Rulează în subshell (fork)

# Așteptăm procesele din background
wait
echo "Toate procesele au terminat."
```

#### Tendințe Moderne

| Evoluție | Descriere |
|----------|-----------|
| clone() | System call Linux cu control fin (baza pentru containers) |
| posix_spawn() | Alternativă la fork+exec, mai eficientă |
| io_uring + clone3 | Creare asincronă de procese |
| User namespaces | Izolare fork în containere |
| Checkpoint/Restore | CRIU - "fork" de procese rulate (pentru live migration) |

---

### 5. Comutarea de Context (Context Switch)

#### Definiție Formală

> Comutarea de context (Context Switch) este operația prin care sistemul de operare salvează starea procesului curent și restaurează starea unui alt proces, permițând multiprogramarea și time-sharing.

Formal:
```
context_switch(P_old, P_new):
    save_context(P_old) → PCB_old
    load_context(PCB_new) → CPU_registers
    update_scheduler_state()
```

#### Explicație Intuitivă

Imaginează-ți că ești profesor la mai multe clase:

1. Salvare context: Când pleci din clasa A
   - Notezi pe tablă unde ai rămas
   - Pui creta jos
   - Închizi catalogul la pagina curentă

2. Restaurare context: Când intri în clasa B
   - Citești de pe tablă unde ai rămas
   - Iei creta
   - Deschizi catalogul unde era

Costul: Timpul pierdut între clase (mergi pe coridor, te orientezi).

În CPU: Salvare/restaurare registre, invalidare cache-uri parțial, flush TLB entries.

#### Overhead Context Switch

```bash
# Măsurare context switch time (în jur de)
# Folosind perf (Linux)
sudo perf stat -e context-switches,cpu-migrations sleep 10

# Sau cu /proc
cat /proc/PID/status | grep ctxt
# voluntary_ctxt_switches: 150
# nonvoluntary_ctxt_switches: 10
```

Timpuri tipice:
| Sistem | Context Switch Time |
|--------|---------------------|
| Bare-metal modern | 1-10 μs |
| VM (virtualizare) | 10-100 μs |
| Container | ~1-5 μs (partajează kernel) |

---

### 6. Brainstorm: Arhitectură SO pentru ATM

Situația: Proiectezi SO-ul pentru un ATM bancar. Trebuie să gestioneze: interfața utilizator (ecran + tastatură), comunicarea cu banca (rețea), imprimanta de chitanțe, și dispozitivul de numărare bani.

Întrebări pentru reflecție:
1. Câte procese ai crea și ce responsabilitate ar avea fiecare?
2. Ce stare ar fi cea mai comună pentru procesul de comunicare cu banca?
3. Ce s-ar întâmpla dacă procesul principal crashuiește în timpul unei tranzacții?

Cum a fost rezolvat în practică: 

ATM-urile moderne folosesc arhitectură multi-proces:

| Proces | Responsabilitate | Stare dominantă |
|--------|------------------|-----------------|
| UI Process | Interacțiune utilizator | Running/Ready |
| Comms Process | Conexiune bancă | Waiting (rețea) |
| Hardware Process | Periferice (imprimantă, cash) | Waiting (I/O) |
| Watchdog Process | Monitorizare, recovery | Sleeping |

Mecanism de siguranță:
- Tranzacții atomice (commit/rollback)
- Jurnal persistent pentru recovery
- Watchdog repornește procese căzute
- Timeout pe toate operațiile

---

## Demonstrații Practice

### Demo 1: Explorare procese cu `ps` și `/proc`

```bash
# Lista proceselor curente
ps aux | head -20

# Arborele proceselor
pstree -p $$

# Informații detaliate despre shell
cat /proc/$$/status

# File descriptors
ls -la /proc/$$/fd/

# Memory maps
cat /proc/$$/maps | head -10
```

### Demo 2: Fork în timp real

```bash
# În terminal 1: monitorizare
watch -n 0.5 'ps --forest -g $$'

# În terminal 2: creează procese
bash -c 'echo "Copil PID: $$"; sleep 10' &
```

### Demo 3: Zombies și Orfani

```bash
# Creează zombie (pentru demonstrație)
bash -c 'bash -c "exit 0" & sleep 30'

# În alt terminal
ps aux | grep Z

# Orfan - părintele moare primul
bash -c 'bash -c "sleep 60" & exit'
ps -ef | grep sleep  # PPID va fi 1 (init/systemd)
```

---

## Lectură Recomandată

### OSTEP
- Obligatoriu: [Cap 6 - Limited Direct Execution](https://pages.cs.wisc.edu/~remzi/OSTEP/cpu-mechanisms.pdf)

### Tanenbaum
- Capitolul 2.1-2.2: Processes (pag. 85-149)

---

## Sumar Comenzi Noi

| Comandă | Descriere | Exemplu |
|---------|-----------|---------|
| `ps aux` | Lista procese | `ps aux \| grep chrome` |
| `ps --forest` | Arbore procese | `ps --forest -g $$` |
| `pstree -p` | Arbore cu PID | `pstree -p $$` |
| `/proc/PID/status` | PCB vizibil | `cat /proc/$$/status` |
| `/proc/PID/fd/` | File descriptors | `ls /proc/$$/fd/` |
| `kill -l` | Lista semnale | `kill -l` |


---

## Auto-evaluare

### Întrebări de verificare

1. **[REMEMBER]** Ce informații conține un PCB (Process Control Block)? Enumeră cel puțin 5 componente.
2. **[UNDERSTAND]** Explică de ce `fork()` returnează valori diferite în procesul părinte și în procesul copil. Care este utilitatea acestui comportament?
3. **[ANALYSE]** Compară și contrastează `fork()` cu `exec()`. În ce situații le folosim împreună și de ce?

### Mini-provocare (opțional)

Scrie un program care creează un arbore de 3 procese (părinte → copil → nepot) și afișează PID-ul și PPID-ul fiecăruia.

---


---


---

## Nuanțe și Cazuri Speciale

### Ce NU am acoperit (limitări didactice)

- **clone()**: Syscall-ul real din Linux; `fork()` și `pthread_create()` sunt de fapt wrappere peste `clone()` cu flag-uri diferite.
- **vfork()**: Varianta "periculoasă" care partajează spațiul de adrese cu părintele. Deprecată în favoarea `fork()+COW`.
- **Process groups și sessions**: Esențiale pentru job control în shell (`fg`, `bg`, `Ctrl+C`).

### Greșeli frecvente de evitat

1. **Zombie processes**: Uitarea `wait()`/`waitpid()` lasă procese zombie care consumă PID-uri.
2. **Fork bomb**: `:(){ :|:& };:` — înțelege de ce funcționează și setează `ulimit -u`.
3. **Așteptarea că fork() copiază instant**: COW (Copy-on-Write) amână copierea până la scriere.

### Întrebări rămase deschise

- Cum optimizează containerele (cgroups) comportamentul fork() pentru aplicații cu cache mare?
- De ce Google a creat `clone3()` syscall în Linux 5.3?

## Privire înainte

**Săptămâna 4: Planificarea Proceselor (Scheduling)** — Acum că înțelegem ce sunt procesele și cum se creează, vom studia cum decide sistemul de operare care proces rulează și când. Algoritmii de scheduling sunt esențiali pentru performanța sistemului.

**Pregătire recomandată:**
- Observă comportamentul `nice` și `renice` pe procese
- Citește OSTEP Capitolele 7-8 (Scheduling)

## Rezumat Vizual

```
┌─────────────────────────────────────────────────────────────────┐
│                    SĂPTĂMÂNA 3: PROCESE — RECAP                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  PROCES = Program în execuție                                   │
│  ├── Cod + Date + Stivă + Heap + Context                       │
│  └── Identificat prin PID (Process ID)                         │
│                                                                 │
│  PCB (Process Control Block)                                    │
│  ├── PID, PPID, stare, registre, memorie                       │
│  ├── Contoare, priorități, credențiale                         │
│  └── Stocat în kernel, accesat la context switch               │
│                                                                 │
│  STĂRI PROCES: New → Ready ⇄ Running → Terminated              │
│                         ↓↑                                      │
│                       Waiting                                   │
│                                                                 │
│  API PROCESE                                                    │
│  ├── fork(): creează copie (COW)                               │
│  ├── exec(): înlocuiește imaginea                              │
│  ├── wait(): așteaptă terminare copil                          │
│  └── exit(): termină procesul                                  │
│                                                                 │
│  💡 TAKEAWAY: fork() + exec() = pattern-ul Unix de creare      │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

*Materiale dezvoltate by Revolvix pentru ASE București - CSIE*  
*Sisteme de Operare | Anul I, Semestrul 2 | 2025-2026*

## Scripting în context (Bash + Python): Procese, semnale, fork/wait

### Fișiere incluse

- Bash: `scripts/process_tree_demo.sh` — Creează procese child și arată PID/PPID, stări și semnale.
- Python: `scripts/fork_demo.py` — Demonstrează `fork()` și `waitpid()` (parent/child).

### Rulare rapidă

```bash
./scripts/process_tree_demo.sh
./scripts/fork_demo.py
```

### Legătura cu conceptele din această săptămână

- Demonstrația cu `sleep` face vizibile PID/PPID și stările proceselor; semnalele sunt mecanismul standard de control.
- `fork()` + `wait()` explică de ce există stări precum *zombie* și de ce părintele are responsabilități.

### Practică recomandată

- rulează întâi scripturile pe un director de test (nu pe date critice);
- salvează output-ul într-un fișier și atașează-l la raport/temă, dacă este cerut;
- notează versiunea de kernel (`uname -r`) și versiunea Python (`python3 --version`) când compari rezultate.

*Materiale dezvoltate de Revolvix pentru ASE București - CSIE*  
*Sisteme de Operare | Anul I, Semestrul 2 | 2025-2026*
