# Sisteme de Operare - Săptămâna 2: Concepte de Bază ale SO

> by Revolvix | ASE București - CSIE | Anul I, Semestrul 2 | 2025-2026

---

## Obiectivele Săptămânii

După parcurgerea materialelor din această săptămână, vei putea să:

1. Enumeri serviciile principale oferite de un sistem de operare
2. Explici mecanismul apelurilor de sistem (system calls) și tranziția user-kernel
3. Descrii structura internă a unui SO și diferitele abordări arhitecturale
4. Folosești comenzi de bază Linux pentru navigare și gestiunea fișierelor
5. Analizezi system calls folosind instrumente ca `strace`

---

## Context aplicativ (scenariu didactic): Cum știe Linux că ai tastat 'ls' și nu 'rm -rf /'?

Când tastezi `ls` în terminal și apeși Enter, ce se întâmplă de fapt? Shell-ul (bash) nu are acces direct la disc pentru a citi directorul - ar fi un dezastru de securitate! În schimb, face un system call către kernel, cerându-i politicos: "Poți să-mi spui ce fișiere sunt în directorul curent?"

Kernel-ul verifică dacă ai permisiunile necesare, accesează disc-ul în siguranță, și returnează lista. Tot acest dans complex se întâmplă de mii de ori pe secundă pe sistemul tău.

> 💡 Gândește-te: Ce s-ar întâmpla dacă orice aplicație ar putea citi/scrie oriunde pe disc fără permisiunea kernel-ului?

---

## Conținut Curs (2/14)

### 1. Serviciile Sistemului de Operare

SO-ul oferă servicii atât pentru utilizatori, cât și pentru programe:

#### Pentru utilizatori (User-facing)
| Serviciu | Descriere | Exemplu |
|----------|-----------|---------|
| Interfață utilizator | CLI sau GUI pentru interacțiune | bash, GNOME, Windows Explorer |
| Execuția programelor | Încărcare și rulare programe | `./program`, double-click |
| Operații I/O | Citire/scriere fișiere, rețea | `cat file.txt`, download |
| Manipulare fișiere | Creare, ștergere, redenumire | `mkdir`, `rm`, `mv` |
| Comunicații | Transfer date între procese/sisteme | pipes, sockets, shared memory |
| Detecție erori | Identificare și raportare probleme | Segfault handling, disk errors |

#### Pentru sistem (System-facing)
| Serviciu | Descriere | Implementare |
|----------|-----------|--------------|
| Alocarea resurselor | Distribuție CPU, memorie, I/O | Scheduler, Memory Manager |
| Accounting | Monitorizare utilizare resurse | `/proc`, cgroups, auditd |
| Protecție și securitate | Izolarea proceselor, control acces | Permissions, capabilities, SELinux |

---

### 2. Apeluri de Sistem (System Calls)

#### Definiție Formală

> System Call (apel de sistem) este interfața programatică prin care un proces din user space solicită un serviciu de la kernel-ul sistemului de operare. Reprezintă punctul de intrare controlat în kernel mode. (Tanenbaum, 2015)

Din perspectiva arhitecturii:
- System calls formează API-ul kernel-ului
- Sunt singura modalitate legitimă pentru user space de a accesa hardware sau resurse protejate
- Implementate prin mecanisme hardware (instrucțiuni privilegiate, trap/interrupt)

#### Explicație Intuitivă

Imaginează-ți că locuiești într-un bloc de apartamente foarte sigur:

- Tu (aplicația) ești locatarul dintr-un apartament
- Administratorul (kernel-ul) are acces la toate zonele: subsol, acoperiș, camerele tehnice
- Interfon-ul (system call) este modul prin care ceri ceva administratorului

Când vrei să:
- Citești contorul de gaz → Suni la interfon: "Poți să-mi spui consumul?"
- Accesezi subsolul → Suni: "Pot să iau bicicleta din boxă?"
- Instalezi AC pe fațadă → Suni: "Am voie să montez asta?"

De ce nu mergi direct?
- Nu ai cheile (nu ai privilegii)
- Ar fi haos dacă toți locatarii ar umbla prin subsol
- Administratorul verifică dacă ai dreptul (permisiuni)

În sistem:
- Aplicația (user mode) nu poate accesa direct hardware-ul
- Kernel-ul (kernel mode) are acces complet
- System call = "telefonul" prin care ceri acces

#### Context Istoric

| An | Eveniment | Semnificație |
|----|-----------|--------------|
| 1960s | Supervisor Call (SVC) pe IBM | Primele instrucțiuni pentru tranziție în mod privilegiat |
| 1969 | UNIX System Calls | ~20 system calls inițiale; design influent |
| 1983 | POSIX standardizat | Standardizare API-uri pentru portabilitate |
| 1991 | Linux 0.01 | ~100 system calls |
| 2024 | Linux 6.x | ~450+ system calls |

> 💡 Fun fact: UNIX a avut inițial doar ~20 system calls. Filosofia "do one thing well" a rezultat în primitive simple și puternice.

#### Mecanismul System Call

```
┌─────────────────────────────────────────────────────────────┐
│                      USER SPACE                              │
│                                                              │
│   ┌──────────┐     ┌──────────────────┐                     │
│   │ Program  │────►│ libc wrapper     │                     │
│   │ read()   │     │ (glibc)          │                     │
│   └──────────┘     └────────┬─────────┘                     │
│                             │                                │
│                             ▼                                │
│                    ┌────────────────┐                       │
│                    │ SYSCALL instr  │                       │
│                    │ (sau INT 0x80) │                       │
│                    └────────┬───────┘                       │
├─────────────────────────────┼───────────────────────────────┤
│                      KERNEL │SPACE                           │
│                             ▼                                │
│                    ┌────────────────┐                       │
│                    │ sys_call_table │                       │
│                    │ [__NR_read]    │                       │
│                    └────────┬───────┘                       │
│                             ▼                                │
│                    ┌────────────────┐                       │
│                    │   sys_read()   │                       │
│                    │ (kernel impl)  │                       │
│                    └────────┬───────┘                       │
│                             │                                │
│                             ▼                                │
│                    Return to user space                     │
└─────────────────────────────────────────────────────────────┘
```

Pașii detaliați:
1. Programul apelează funcția C `read(fd, buf, count)`
2. glibc wrapper pune argumentele în registre și numărul syscall în `%rax`
3. Instrucțiunea `syscall` (x86-64) sau `int 0x80` (x86) declanșează trap
4. CPU salvează starea, comută în kernel mode
5. Kernel caută în `sys_call_table[__NR_read]` și execută `sys_read()`
6. Rezultatul e pus în `%rax`, se revine în user mode

#### Categorii de System Calls

| Categorie | Exemple Linux | Funcționalitate |
|-----------|--------------|-----------------|
| Procese | `fork()`, `exec()`, `exit()`, `wait()`, `clone()` | Creare, execuție, terminare |
| Fișiere | `open()`, `read()`, `write()`, `close()`, `stat()` | Operații I/O pe fișiere |
| Directoare | `mkdir()`, `rmdir()`, `getdents()`, `chdir()` | Manipulare directoare |
| Dispozitive | `ioctl()`, `mmap()` | Control dispozitive, memory mapping |
| Informații | `getpid()`, `time()`, `uname()`, `getuid()` | Informații proces și sistem |
| Comunicare | `pipe()`, `socket()`, `send()`, `recv()`, `shmget()` | IPC și rețea |
| Memorie | `brk()`, `mmap()`, `munmap()`, `mprotect()` | Gestiune memorie |
| Semnale | `kill()`, `signal()`, `sigaction()` | Comunicare asincronă |

#### Costuri și Trade-off-uri

| Aspect | Detalii |
|--------|---------|
| Cost temporal | ~100-1000 cicluri CPU per syscall (context switch) |
| Overhead | Salvare/restaurare registre, TLB flush parțial |
| Securitate | Fiecare syscall = punct de verificare pentru permisiuni |
| Flexibilitate | API stabil; programele nu depind de implementare kernel |

Trade-off principal: Securitate vs. Performanță
- Mai multe verificări = mai sigur, dar mai lent
- Soluții moderne: vDSO (virtual syscalls pentru operații sigure), io_uring

#### Implementare Comparativă

| Aspect | Linux | Windows | macOS |
|--------|-------|---------|-------|
| Mecanism | `syscall` (x86-64), `int 0x80` | `syscall`, `int 0x2e` | `syscall` (Mach + BSD) |
| Tabel | `sys_call_table[]` | SSDT (System Service Descriptor Table) | Mach traps + BSD syscalls |
| Nr. syscalls | ~450 | ~460 (documented) | ~500 (Mach + BSD) |
| Wrapper | glibc | ntdll.dll → kernel32.dll | libSystem.dylib |
| Numerotare | Stabilă între versiuni | Se poate schimba | Stabilă (POSIX) |
| Documentare | Excelentă (man pages) | Parțială (multe undocumented) | Bună |

#### Reproducere în Python

```python
#!/usr/bin/env python3
"""
Demonstrație System Calls - Simulare și Acces Real

Acest script arată:
1. Cum funcționează conceptual un system call dispatcher
2. Cum accesăm syscalls direct din Python (pentru educational)
"""

import os
import ctypes
import time

# ============================================
# PARTEA 1: Simulare Conceptuală
# ============================================

class MockKernel:
    """
    Simulare simplificată a kernel-ului.
    Demonstrează conceptul de system call table.
    """
    
    # Numerele system calls (ca în Linux)
    SYS_READ = 0
    SYS_WRITE = 1
    SYS_OPEN = 2
    SYS_CLOSE = 3
    SYS_GETPID = 39
    SYS_TIME = 201
    
    def __init__(self):
        self.files = {
            0: ("stdin", "r"),
            1: ("stdout", "w"),
            2: ("stderr", "w"),
        }
        self.next_fd = 3
        self.pid = 12345
        
        # System Call Table - mapare număr → funcție
        self.syscall_table = {
            self.SYS_READ: self._sys_read,
            self.SYS_WRITE: self._sys_write,
            self.SYS_OPEN: self._sys_open,
            self.SYS_CLOSE: self._sys_close,
            self.SYS_GETPID: self._sys_getpid,
            self.SYS_TIME: self._sys_time,
        }
    
    def syscall(self, number: int, *args):
        """
        Entry point pentru toate system calls.
        Echivalent cu sys_call_table[number](*args) în kernel.
        """
        if number not in self.syscall_table:
            raise OSError(f"Invalid syscall number: {number}")
        
        print(f"[KERNEL] Syscall #{number} with args {args}")
        
        # Verificări de securitate ar fi aici
        # ...
        
        # Dispatch către handler
        result = self.syscall_table[number](*args)
        
        print(f"[KERNEL] Syscall #{number} returned: {result}")
        return result
    
    def _sys_read(self, fd: int, count: int) -> str:
        """Citește din file descriptor."""
        if fd not in self.files:
            return -1  # EBADF
        return f"[data from fd {fd}]"
    
    def _sys_write(self, fd: int, data: str) -> int:
        """Scrie în file descriptor."""
        if fd not in self.files:
            return -1
        print(f"[OUTPUT fd={fd}]: {data}")
        return len(data)
    
    def _sys_open(self, path: str, flags: str) -> int:
        """Deschide un fișier."""
        fd = self.next_fd
        self.files[fd] = (path, flags)
        self.next_fd += 1
        return fd
    
    def _sys_close(self, fd: int) -> int:
        """Închide un file descriptor."""
        if fd in self.files and fd > 2:  # Nu închide stdin/out/err
            del self.files[fd]
            return 0
        return -1
    
    def _sys_getpid(self) -> int:
        """Returnează PID-ul procesului."""
        return self.pid
    
    def _sys_time(self) -> int:
        """Returnează timpul curent."""
        return int(time.time())

# Utilizare simulare
def demo_simulation():
    print("=" * 50)
    print("SIMULARE SYSTEM CALLS")
    print("=" * 50)
    
    kernel = MockKernel()
    
    # Echivalent cu: pid = getpid()
    pid = kernel.syscall(MockKernel.SYS_GETPID)
    print(f"\nPID: {pid}\n")
    
    # Echivalent cu: fd = open("/tmp/test.txt", "w")
    fd = kernel.syscall(MockKernel.SYS_OPEN, "/tmp/test.txt", "w")
    print(f"Opened file, fd={fd}\n")
    
    # Echivalent cu: write(fd, "Hello!")
    written = kernel.syscall(MockKernel.SYS_WRITE, fd, "Hello from syscall!")
    print(f"Wrote {written} bytes\n")
    
    # Echivalent cu: close(fd)
    kernel.syscall(MockKernel.SYS_CLOSE, fd)

# ============================================
# PARTEA 2: System Calls Reale în Python
# ============================================

def demo_real_syscalls():
    print("\n" + "=" * 50)
    print("SYSTEM CALLS REALE")
    print("=" * 50)
    
    # Python's os module wraps system calls
    
    # getpid() - syscall #39 pe Linux x86-64
    print(f"\nos.getpid() = {os.getpid()}")
    
    # time() - syscall #201
    print(f"time.time() = {time.time()}")
    
    # uname() - syscall #63
    uname = os.uname()
    print(f"os.uname() = {uname.sysname} {uname.release}")
    
    # getuid() - syscall #102
    print(f"os.getuid() = {os.getuid()}")
    
    # getcwd() - syscall #79
    print(f"os.getcwd() = {os.getcwd()}")
    
    # Pentru syscalls directe (Linux only):
    print("\n--- Direct syscall via ctypes ---")
    try:
        libc = ctypes.CDLL("libc.so.6")
        
        # getpid via libc
        pid = libc.getpid()
        print(f"libc.getpid() = {pid}")
        
        # syscall direct (getpid = 39 pe x86-64)
        # Aceasta e o funcție care apelează direct syscall()
        libc.syscall.restype = ctypes.c_long
        pid_direct = libc.syscall(39)  # __NR_getpid
        print(f"syscall(39) = {pid_direct}")
        
    except OSError as e:
        print(f"(Nu se poate pe acest sistem: {e})")

# ============================================
# PARTEA 3: Vizualizare cu strace (output similar)
# ============================================

def demo_strace_output():
    print("\n" + "=" * 50)
    print("OUTPUT SIMILAR CU strace")
    print("=" * 50)
    
    print("""
Când rulezi: strace ls

Vei vedea ceva de genul:

execve("/bin/ls", ["ls"], 0x7ffd...) = 0
brk(NULL)                                 = 0x55a8...
openat(AT_FDCWD, "/etc/ld.so.cache", O_RDONLY) = 3
fstat(3, {st_mode=S_IFREG|0644, ...})     = 0
mmap(NULL, 12345, PROT_READ, ...)         = 0x7f...
close(3)                                  = 0
...
write(1, "file1.txt  file2.txt\\n", 22)   = 22
close(1)                                  = 0
exit_group(0)                             = ?

Fiecare linie = un system call!
""")

if __name__ == "__main__":
    demo_simulation()
    demo_real_syscalls()
    demo_strace_output()
```

#### Tendințe Moderne în System Calls

| Evoluție | Descriere | Exemplu |
|----------|-----------|---------|
| vDSO | Virtual Dynamic Shared Object - syscalls în user space pentru operații sigure | `gettimeofday()` fără trap în kernel |
| **io_uring** | Async I/O cu batch submission | Reduce overhead pentru I/O intensiv |
| eBPF | Extend kernel fără module | Observabilitate, networking, security |
| Seccomp | Syscall filtering | Sandboxing aplicații (Docker, Chrome) |
| Kernel bypass | Evită complet kernel-ul | DPDK pentru networking, SPDK pentru storage |

---

### 3. Structura Sistemului de Operare

#### Layered Approach (Abordare pe straturi)

```
Layer N:     User Interface
Layer N-1:   User Programs
...
Layer 3:     I/O Management
Layer 2:     Communication (IPC)
Layer 1:     Memory Management
Layer 0:     Hardware Abstraction
```

Avantaj: Modularitate, debugging mai ușor
Dezavantaj: Overhead la traversarea straturilor, dificil de definit straturile

#### Virtual Machines

```
┌─────────────────────────────────────────────────────────────┐
│   VM 1           VM 2           VM 3                        │
│ ┌─────────┐   ┌─────────┐   ┌─────────┐                    │
│ │  App    │   │  App    │   │  App    │                    │
│ ├─────────┤   ├─────────┤   ├─────────┤                    │
│ │ Ubuntu  │   │ Windows │   │ FreeBSD │                    │
│ └────┬────┘   └────┬────┘   └────┬────┘                    │
│      │             │             │                          │
├──────┴─────────────┴─────────────┴──────────────────────────┤
│                    HYPERVISOR                                │
│              (VMware, KVM, Hyper-V)                         │
├─────────────────────────────────────────────────────────────┤
│                      HARDWARE                                │
└─────────────────────────────────────────────────────────────┘
```

```bash
# Verificăm dacă suntem într-o VM
systemd-detect-virt
# Returnează: oracle, vmware, kvm, none, etc.

# Sau prin dmesg
dmesg | grep -i hypervisor
```

---

### 4. Brainstorm: SO pentru sistem embedded

Situația: Proiectezi un SO pentru un sistem embedded cu doar 64KB RAM - un termostat inteligent. Trebuie să controleze temperatura, să afișeze pe un ecran mic, și să comunice prin WiFi.

Întrebări pentru reflecție:
1. Ce funcții SO ai păstra și ce ai elimina?
2. Ai folosi o arhitectură monolitică sau microkernel?
3. Ai avea multitasking sau un singur task?
4. Cum ai gestiona memoria cu doar 64KB?

Cum a fost rezolvat în practică: 

Sistemele embedded moderne folosesc RTOS (Real-Time OS) precum FreeRTOS sau Zephyr. Acestea au:
- Kernel minimal (<10KB)
- Multitasking cooperativ sau preemptiv
- Doar funcțiile esențiale: scheduling simplu, timere, cozi de mesaje
- Nu au: memorie virtuală, sistem de fișiere complex, GUI
- Fiecare KB contează!

Exemplu FreeRTOS:
```c
// Task simplu în FreeRTOS
void vTemperatureTask(void *pvParameters) {
    for (;;) {
        int temp = read_sensor();
        update_display(temp);
        vTaskDelay(1000 / portTICK_PERIOD_MS);  // Sleep 1 sec
    }
}
```

---

## Laborator/Seminar (Sesiunea 1/7)

### Materiale TC de parcurs
- [ ] TC1a - Introduction to Shell
- [ ] TC1b - Basic Commands
- [ ] TC1c - File System Navigation
- [ ] TC1o - Introduction to getopts

### Exerciții Practice

#### Exercițiul 1: Navigare în sistemul de fișiere

```bash
# Află directorul curent
pwd

# Listează conținutul
ls
ls -la        # format lung, inclusiv fișiere ascunse
ls -lh        # format "human readable" pentru dimensiuni

# Schimbă directorul
cd /home
cd ~          # shortcut pentru home
cd ..         # directorul părinte
cd -          # directorul anterior

# Crează directoare
mkdir test_so
mkdir -p proiect/src/lib    # crează și părinții

# Crează fișiere goale
touch fisier1.txt
touch proiect/README.md
```

#### Exercițiul 2: Manipulare fișiere

```bash
# Copiere
cp fisier1.txt fisier2.txt
cp -r proiect proiect_backup    # copiere recursivă

# Mutare/Redenumire
mv fisier2.txt arhiva.txt
mv arhiva.txt proiect/

# Ștergere (ATENȚIE!)
rm fisier1.txt
rm -r proiect_backup            # ștergere recursivă
rm -i fisier.txt                # cu confirmare

# Vizualizare conținut
cat /etc/hostname
head -5 /etc/passwd
tail -5 /etc/passwd
less /etc/services              # paginare
```

#### Exercițiul 3: Globbing și wildcards

```bash
# Crează fișiere de test
touch file1.txt file2.txt file3.txt script.sh data.csv

# Wildcards
ls *.txt              # toate .txt
ls file?.txt          # file + un caracter + .txt
ls file[12].txt       # file1.txt sau file2.txt
ls data.*             # data cu orice extensie
```

#### Exercițiul 4: Explorare System Calls cu `strace`

```bash
# Instalare
sudo apt install strace -y

# Urmărește ce face 'ls'
strace ls 2>&1 | head -50

# Numără syscalls per tip
strace -c ls 2>&1

# Urmărește un proces existent
strace -p PID

# Filtrează doar anumite syscalls
strace -e open,read,write ls
```

#### Exercițiul 5: Introducere în getopts

```bash
#!/bin/bash
# salut.sh

while getopts "n:v" opt; do
    case $opt in
        n) NUME="$OPTARG" ;;
        v) VERBOSE=1 ;;
        *) echo "Utilizare: $0 [-n nume] [-v]"; exit 1 ;;
    esac
done

[[ -n "$VERBOSE" ]] && echo "[VERBOSE] Script pornit"
echo "Salut, ${NUME:-Utilizator}!"
```

---

### Tema 1: `tema1_arbore.sh`

Deadline: Până la următorul seminar (Săptămâna 4)

Cerințe:

Scrie un script Bash care creează următoarea structură de directoare:

```
Proiecte/
├── Linux/
│   ├── README.txt      # conține "Proiect Linux"
│   └── src/
├── Windows/
│   ├── README.txt      # conține "Proiect Windows"
│   └── src/
└── MacOS/
    ├── README.txt      # conține "Proiect MacOS"
    └── src/
```

Specificații:
- `-d DIRECTOR` - directorul de bază (default: curent)
- `-v` - verbose mode
- `-h` - help

Livrabile: `history > tema1_NumePrenume.txt` + script

---

### Milestone Proiect M1: Formarea Echipei

Cerințe:
- [ ] Echipă formată (3 membri)
- [ ] Subiect ales sau propus
- [ ] Repository Git creat
- [ ] README.md inițial

---

## Lectură Recomandată

### OSTEP
- Obligatoriu: [Cap 4 - Processes](https://pages.cs.wisc.edu/~remzi/OSTEP/cpu-intro.pdf)
- Obligatoriu: [Cap 5 - Process API](https://pages.cs.wisc.edu/~remzi/OSTEP/cpu-api.pdf)

### Tanenbaum
- Capitolul 1.5-1.7: System Calls, OS Structure

---

## Sumar Comenzi Noi

| Comandă | Descriere | Exemplu |
|---------|-----------|---------|
| `strace` | Urmărește system calls | `strace ls` |
| `strace -c` | Statistici syscalls | `strace -c ls` |
| `mkdir -p` | Crează directoare recursiv | `mkdir -p a/b/c` |
| `touch` | Crează fișier gol | `touch file.txt` |
| `systemd-detect-virt` | Detectează virtualizare | `systemd-detect-virt` |

---

*Materiale dezvoltate by Revolvix pentru ASE București - CSIE*  
*Sisteme de Operare | Anul I, Semestrul 2 | 2025-2026*

## Scripting în context (Bash + Python): System calls observate cu strace

### Fișiere incluse

- Bash: `scripts/trace_cmd.sh` — Rulează o comandă sub `strace` și produce log + rezumat statistic.
- Python: `scripts/os_open_demo.py` — Copiere fișier prin `os.open/os.read/os.write` (corelabil cu syscalls).

### Rulare rapidă

```bash
./scripts/trace_cmd.sh -e openat,read,write,close -- ./scripts/os_open_demo.py -i /etc/hosts -o /tmp/hosts_copy.txt
```

### Legătura cu conceptele din această săptămână

- `strace` arată tranzacția user-space → kernel-space: aproape orice „acțiune” relevantă (fișiere, procese, memorie) se materializează în *system calls*.
- `os.open/os.read/os.write` sunt un mod controlat de a produce syscalls ușor de recunoscut.

### Practică recomandată

- rulează întâi scripturile pe un director de test (nu pe date critice);
- salvează output-ul într-un fișier și atașează-l la raport/temă, dacă este cerut;
- notează versiunea de kernel (`uname -r`) și versiunea Python (`python3 --version`) când compari rezultate.

*Materiale dezvoltate de Revolvix pentru ASE București - CSIE*  
*Sisteme de Operare | Anul I, Semestrul 2 | 2025-2026*
