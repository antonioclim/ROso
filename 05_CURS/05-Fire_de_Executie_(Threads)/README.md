# Sisteme de Operare - Săptămâna 5: Fire de Execuție (Threads)

> by Revolvix | ASE București - CSIE | Anul I, Semestrul 2 | 2025-2026

---

## Obiectivele Săptămânii

După parcurgerea materialelor din această săptămână, vei putea să:

1. Definești conceptul de thread și să-l diferențiezi de proces
2. Compari modelele de multithreading (many-to-one, one-to-one, many-to-many)
3. Explici avantajele și dezavantajele utilizării thread-urilor
4. Descrii implementarea thread-urilor în Linux (NPTL) și conceptul de LWP
5. Folosești API-ul POSIX Threads (pthreads) conceptual

---

## Context aplicativ (scenariu didactic): De ce browserul are 20+ procese pentru 5 tab-uri?

Deschide Chrome și uită-te în Task Manager. Pentru 5 tab-uri, vezi poate 25 de procese! De ce? 

Răspunsul modern: izolare prin procese + paralelism prin threads. Fiecare tab e un proces separat (dacă unul crashuiește, nu ia tot browserul). Dar în interiorul fiecărui proces sunt multiple threads: unul pentru rendering, unul pentru JavaScript, unul pentru network, unul pentru compositor. 

Această arhitectură hibridă oferă atât izolare (între procese) cât și eficiență (între threads).

> 💡 Gândește-te: De ce crezi că Chrome a ales procese separate pentru tab-uri în loc de threads? Ce risc ar fi existat cu threads?

---

## Conținut Curs (5/14)

### 1. Ce este un Thread?

#### Definiție Formală

> Thread-ul (fir de execuție) este unitatea de bază a utilizării CPU-ului. Un thread aparține unui proces și reprezintă o secvență de execuție independentă în cadrul acelui proces. Thread-urile aceluiași proces partajează codul, datele globale și resursele (fișiere deschise, heap), dar fiecare thread are proprii registre CPU, program counter și stivă. (Silberschatz et al., 2018)

Formal, un thread T poate fi definit ca:
```
T = (ID, PC, Registers, Stack)  // Context propriu
P = (Code, Data, Heap, Files)    // Partajat cu alte threads din proces
```

#### Explicație Intuitivă

Metafora: Bucătăria unui restaurant

- Procesul = Bucătăria întreagă
- Thread-urile = Bucătarii din bucătărie

Bucătarii (threads):
- Partajează: ingredientele (data), rețetele (code), aragazul (resurse), frigiderul (heap)
- Au proprii: mâini (registre), mintea unde au rămas (PC), propria poziție în bucătărie (stack)
- Lucrează în paralel: Unul taie, altul gătește, altul platează
- Coordonare necesară: Să nu se lovească, să nu ia același cuțit

Dacă un bucătar face o greșeală gravă (corrupt shared memory), toată bucătăria e afectată → diferența față de procese!

#### Structura Thread vs Proces

```
┌─────────────────────────────────────────────────────────────┐
│                         PROCES                              │
├─────────────────────────────────────────────────────────────┤
│  Code (Text) │ Data (Global) │ Files │ Heap (Shared)       │
├───────────────┬───────────────┬───────────────┬─────────────┤
│   Thread 1    │   Thread 2    │   Thread 3    │   ...       │
│ ┌───────────┐ │ ┌───────────┐ │ ┌───────────┐ │             │
│ │ Thread ID │ │ │ Thread ID │ │ │ Thread ID │ │             │
│ │ Registers │ │ │ Registers │ │ │ Registers │ │             │
│ │ Stack     │ │ │ Stack     │ │ │ Stack     │ │             │
│ │ PC        │ │ │ PC        │ │ │ PC        │ │             │
│ │ State     │ │ │ State     │ │ │ State     │ │             │
│ └───────────┘ │ └───────────┘ │ └───────────┘ │             │
└───────────────┴───────────────┴───────────────┴─────────────┘
```

#### Thread vs Proces - Comparație Detaliată

| Aspect | Proces | Thread |
|--------|--------|--------|
| Spațiu de adrese | Propriu, izolat | Partajat cu alte threads |
| Creare | Lent (~1-10 ms) | Rapid (~10-100 μs) |
| Context switch | Costisitor (~1-10 μs + TLB flush) | Mai ieftin (~0.1-1 μs) |
| Comunicare | IPC explicit (pipes, sockets, shm) | Memorie partajată directă |
| Crash | Afectează doar procesul | Poate afecta tot procesul |
| Overhead memorie | Mare (~MB per proces) | Mic (~KB per stack) |
| Izolare | Completă | Minimă |
| Debugging | Mai ușor | Mai dificil (race conditions) |

---

### 2. Modele de Multithreading

#### Definiție Formală: User Threads vs Kernel Threads

> User-level threads sunt gestionate de o bibliotecă în user space, invizibile pentru kernel. Kernel-level threads sunt gestionate direct de kernel și pot fi planificate pe CPU-uri diferite.

Problema fundamentală: Cum mapăm user threads pe kernel threads?

#### Model 1: Many-to-One (N:1)

```
User Threads:    T₁    T₂    T₃    T₄
                  \    |    |    /
                   \   |   |   /
                    \  |  |  /
                     \ | | /
Kernel Thread:       [ K₁ ]
```

Caracteristici:
- Toate user threads → un singur kernel thread
- Thread switching rapid (în user space)
- Problemă: Un blocking syscall blochează TOATE threads!
- Problemă: Nu poate exploata multi-core

Exemple istorice: Green threads (Java vechi), GNU Pth

#### Model 2: One-to-One (1:1)

```
User Threads:    T₁    T₂    T₃    T₄
                  |     |     |     |
                  |     |     |     |
                  |     |     |     |
Kernel Threads:  K₁    K₂    K₃    K₄
```

Caracteristici:
- Fiecare user thread = un kernel thread
- Paralelism real pe multi-core
- Blocking syscall afectează doar un thread
- Overhead: Creare/switch prin kernel

Exemple moderne: Linux NPTL, Windows threads, macOS

#### Model 3: Many-to-Many (M:N)

```
User Threads:    T₁   T₂   T₃   T₄   T₅
                  \   |   /     \   /
                   \  |  /       \ /
Kernel Threads:    K₁   K₂       K₃
```

Caracteristici:
- M user threads pe N kernel threads (M ≥ N)
- Flexibil, scalabil
- Complex de implementat corect
- User-level scheduler + Kernel scheduler

Exemple: Go goroutines (conceptual), Solaris istoric

---

### 3. Beneficiile Thread-urilor

#### Definiție Formală

> Concurența (concurrency) este proprietatea unui sistem de a avea mai multe task-uri în progres în același interval de timp. Paralelismul este execuția simultană a mai multor task-uri pe hardware diferit. Thread-urile permit ambele.

#### Explicație Intuitivă

De ce threads?

| Beneficiu | Metaforă | Exemplu tehnic |
|-----------|----------|----------------|
| Responsiveness | Receptionist care răspunde la telefon în timp ce colegul rezolvă problema | UI thread + worker thread |
| Resource Sharing | Colegii de cameră care împart frigiderul | Threads partajează heap-ul |
| Economy | Mai ieftin să angajezi un ajutor decât să deschizi o firmă nouă | Thread vs Process creation |
| Scalability | Mai mulți muncitori pot lucra în paralel | Threads pe mai multe core-uri |

#### Cost Comparison (Ordine de mărime)

| Operație | Timp tipic |
|----------|------------|
| Process creation | 1-10 ms |
| Thread creation | 10-100 μs |
| Process context switch | 1-10 μs + TLB |
| Thread context switch | 0.1-1 μs |
| Function call | 10-100 ns |

---

### 4. Thread-uri în Linux: NPTL

#### Definiție Formală

> NPTL (Native POSIX Threads Library) este implementarea thread-urilor în Linux modernă, care folosește modelul 1:1 și system call-ul clone() pentru a crea Light-Weight Processes (LWP) care partajează spațiul de adrese.

#### Context Istoric

| An | Eveniment |
|----|-----------|
| 1996 | LinuxThreads - prima implementare (problematică) |
| 2002 | NPTL dezvoltat de Red Hat (Ulrich Drepper, Ingo Molnár) |
| 2003 | NPTL în Linux 2.6, înlocuiește LinuxThreads |
| 2024 | NPTL standard, optimizări continue (futex) |

#### Mecanism: clone() System Call

```c
// Creare thread în Linux (simplificat)
// clone() este system call-ul de bază

int flags = CLONE_VM        // Partajează spațiul de adrese
          | CLONE_FS        // Partajează filesystem info
          | CLONE_FILES     // Partajează file descriptors
          | CLONE_SIGHAND   // Partajează signal handlers
          | CLONE_THREAD    // Același thread group
          | CLONE_SYSVSEM;  // Partajează semafoare SysV

pid_t tid = clone(thread_function, stack_top, flags, arg);
```

Diferența față de fork():
- `fork()` = `clone()` cu flags care NU partajează nimic
- Thread = `clone()` cu flags care partajează totul (mai puțin stack)

#### Vizualizare în Linux

```bash
# Thread-uri pentru un proces
ps -eLf | grep firefox | head -5
# PID PPID LWP NLWP CMD
# 1234 1 1234 45 firefox
# 1234 1 1235 45 firefox
# 1234 1 1236 45 firefox
# NLWP = Number of Light-Weight Processes (threads)

# Sau
ls /proc/PID/task/
# Fiecare subdirector = un thread (LWP)

# Cu htop: apasă H pentru a vedea threads
htop

# Informații thread
cat /proc/PID/task/TID/status
```

---

### 5. POSIX Threads (Pthreads) API

#### Definiție Formală

> POSIX Threads (Pthreads) este API-ul standardizat (IEEE POSIX 1003.1c) pentru programarea cu thread-uri în sistemele UNIX-like. Oferă funcții pentru creare, sincronizare și gestiune threads.

#### Funcții Principale

| Funcție | Scop |
|---------|------|
| `pthread_create()` | Creează un thread nou |
| `pthread_join()` | Așteaptă terminarea unui thread |
| `pthread_exit()` | Termină thread-ul curent |
| `pthread_self()` | Returnează ID-ul thread-ului curent |
| `pthread_detach()` | Marchează thread ca "detached" |
| `pthread_cancel()` | Cere terminarea unui thread |

#### Exemplu Conceptual (C)

```c
#include <pthread.h>
#include <stdio.h>

void *thread_function(void *arg) {
    int id = *(int*)arg;
    printf("Thread %d: Hello!\n", id);
    return NULL;
}

int main() {
    pthread_t threads[4];
    int ids[4] = {0, 1, 2, 3};
    
    // Creare threads
    for (int i = 0; i < 4; i++) {
        pthread_create(&threads[i], NULL, thread_function, &ids[i]);
    }
    
    // Așteptare threads
    for (int i = 0; i < 4; i++) {
        pthread_join(threads[i], NULL);
    }
    
    return 0;
}
// Compilare: gcc -pthread program.c -o program
```

#### Echivalent Python

```python
#!/usr/bin/env python3
"""
Threading în Python

Capcană: Python are GIL (Global Interpreter Lock)!
- Pentru I/O-bound: threads funcționează bine
- Pentru CPU-bound: folosește multiprocessing
"""

import threading
import time
import os

def worker(name: str, duration: float):
    """Funcție executată de fiecare thread."""
    tid = threading.current_thread().name
    print(f"[{tid}] {name} started (PID: {os.getpid()})")
    time.sleep(duration)  # Simulează I/O
    print(f"[{tid}] {name} finished")

def demonstrate_threads():
    print(f"Main thread PID: {os.getpid()}")
    print(f"Main thread ID: {threading.current_thread().name}")
    
    # Creare threads
    threads = []
    for i in range(4):
        t = threading.Thread(
            target=worker, 
            args=(f"Task-{i}", i * 0.5),
            name=f"Worker-{i}"
        )
        threads.append(t)
        t.start()
    
    # Join (așteptare)
    for t in threads:
        t.join()
    
    print("All threads completed!")

# Thread cu rezultat
def worker_with_result(n: int) -> int:
    """Calculează suma 1..n"""
    return sum(range(1, n+1))

def thread_with_result():
    """Demonstrează obținerea rezultatului."""
    results = {}
    
    def wrapper(n, idx):
        results[idx] = worker_with_result(n)
    
    threads = [
        threading.Thread(target=wrapper, args=(1000000, 0)),
        threading.Thread(target=wrapper, args=(2000000, 1)),
    ]
    
    for t in threads:
        t.start()
    for t in threads:
        t.join()
    
    print(f"Results: {results}")

if __name__ == "__main__":
    demonstrate_threads()
    print("\n" + "="*50 + "\n")
    thread_with_result()
```

---

### 6. Brainstorm: Aplicație de Procesare Imagini

Situația: Dezvolți o aplicație desktop pentru procesare imagini. Utilizatorul încarcă 100 de imagini și aplică un filtru (blur, resize). Fiecare imagine durează 500ms să fie procesată.

Întrebări:
1. Un singur thread - cât durează? UI-ul va fi responsive?
2. 100 de threads (unul per imagine) - e o idee bună?
3. Câte threads ai folosi și de ce?
4. Threads sau procese pentru acest caz?

Răspunsuri și Soluție:

| Abordare | Timp total | UI | Problemă |
|----------|------------|----|----|
| 1 thread | 50 secunde | ❌ Blocat | Experiență slabă |
| 100 threads | ~6.25s teoretic | ✅ | Overhead mare, context switches |
| 8 threads (= cores) | ~6.25s | ✅ | ✅ Optimal |

Soluție practică: Thread Pool
```python
from concurrent.futures import ThreadPoolExecutor
import os

with ThreadPoolExecutor(max_workers=os.cpu_count()) as executor:
    results = executor.map(process_image, images)
```

---

### 7. Când Threads vs Procese?

| Criteriu | Alege Threads | Alege Procese |
|----------|---------------|---------------|
| Comunicare frecventă | ✅ Memorie partajată | ❌ IPC overhead |
| Izolare necesară | ❌ Un crash = tot | ✅ Izolare completă |
| Securitate | ❌ Partajare = risc | ✅ Sandbox natural |
| CPU-bound în Python | ❌ GIL limitează | ✅ multiprocessing |
| I/O-bound | ✅ Eficient | ~ Similar |
| Platforme diferite | ~ | ✅ Portabilitate |

---

## Lectură Recomandată

### OSTEP
- Obligatoriu: [Cap 26 - Concurrency: Introduction](https://pages.cs.wisc.edu/~remzi/OSTEP/threads-intro.pdf)
- Obligatoriu: [Cap 27 - Thread API](https://pages.cs.wisc.edu/~remzi/OSTEP/threads-api.pdf)

### Tanenbaum
- Capitolul 2.2: Threads (pag. 105-120)

---

## Sumar Comenzi

| Comandă | Descriere |
|---------|-----------|
| `ps -eLf` | Lista procese cu threads |
| `ps -T -p PID` | Threads pentru un proces |
| `ls /proc/PID/task/` | Directoare threads |
| `htop` + `H` | Toggle afișare threads |


---

## Auto-evaluare

### Întrebări de verificare

1. **[REMEMBER]** Care sunt cele 3 modele de multithreading (many-to-one, one-to-one, many-to-many)? Dă un exemplu de SO pentru fiecare.
2. **[UNDERSTAND]** Explică de ce thread-urile aceluiași proces partajează memoria heap dar au stive separate. Care sunt avantajele și riscurile?
3. **[ANALYSE]** Analizează diferența de overhead între crearea unui thread și crearea unui proces. De ce thread-urile sunt "lightweight"?

### Mini-provocare (opțional)

Scrie un program Python care creează 4 thread-uri pentru a calcula suma elementelor unei liste, împărțind munca între ele.

---


---


---

## Nuanțe și Cazuri Speciale

### Ce NU am acoperit (limitări didactice)

- **Thread-local storage (TLS)**: Variabile `__thread` care sunt private per thread.
- **Futex**: Fast userspace mutex - mecanismul low-level pentru sincronizare în Linux.
- **Green threads / Coroutines**: Threads în userspace (Go goroutines, Python asyncio).

### Greșeli frecvente de evitat

1. **Variabile globale fără protecție**: Orice variabilă partajată necesită sincronizare.
2. **Thread-uri pentru I/O blocking**: Folosește I/O async sau thread pools, nu un thread per conexiune.
3. **Presupunerea ordinii de execuție**: Fără sincronizare, ordinea este nedeterministă.

### Întrebări rămase deschise

- Vor înlocui coroutines (async/await) thread-urile pentru majoritatea aplicațiilor?
- Cum gestionează sistemele embedded cu resurse limitate multithreading-ul?

## Privire înainte

**Săptămâna 6: Sincronizare (Partea 1)** — Thread-urile partajează memoria, deci pot apărea race conditions. Vom învăța despre secțiunea critică, algoritmul Peterson și mecanismele de bază pentru protecție: locks și mutex.

**Pregătire recomandată:**
- Gândește-te la scenarii de race condition din viața reală
- Citește OSTEP Capitolele 28-29 (Locks)

## Rezumat Vizual

```
┌─────────────────────────────────────────────────────────────────┐
│                    SĂPTĂMÂNA 5: THREADS — RECAP                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  THREAD = Unitate de execuție în cadrul unui proces            │
│                                                                 │
│  PROCES vs THREAD                                               │
│  ├── Proces: spațiu de adrese separat, overhead mare           │
│  └── Thread: partajează memoria, overhead mic                  │
│                                                                 │
│  CE PARTAJEAZĂ THREAD-URILE?                                    │
│  ├── DA: Cod, Date globale, Heap, File descriptors             │
│  └── NU: Stack, Registre, Thread ID                            │
│                                                                 │
│  MODELE MULTITHREADING                                          │
│  ├── Many-to-One: user threads → 1 kernel thread               │
│  ├── One-to-One: 1 user thread → 1 kernel thread (Linux)       │
│  └── Many-to-Many: M user threads → N kernel threads           │
│                                                                 │
│  AVANTAJE THREAD-URI                                            │
│  ├── Responsive: UI thread + worker threads                    │
│  ├── Resource sharing: comunicare eficientă                    │
│  └── Scalabilitate: exploatează multi-core                     │
│                                                                 │
│  💡 TAKEAWAY: Thread-uri = paralelism ușor, dar sincronizare!  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

*Materiale dezvoltate by Revolvix pentru ASE București - CSIE*  
*Sisteme de Operare | Anul I, Semestrul 2 | 2025-2026*

## Scripting în context (Bash + Python): Threads vs Processes (concurență vs paralelism)

### Fișiere incluse

- Python: `scripts/threads_vs_processes.py` — Compară threads și processes pe workload CPU-bound.
- Bash: `scripts/run_threads_bench.sh` — Rulează benchmark-ul de mai multe ori și colectează output.

### Rulare rapidă

```bash
./scripts/run_threads_bench.sh -r 3 --workers 4 --n 20000
```

### Legătura cu conceptele din această săptămână

- Threads împart address space; procesele sunt izolate. În practică, asta înseamnă trade-off între performanță și izolare.
- În Python, GIL este un detaliu de runtime care face experimentul didactic și mai interesant: OS-ul poate oferi paralelism, dar runtime-ul poate impune constrângeri.

### Practică recomandată

- rulează întâi scripturile pe un director de test (nu pe date critice);
- salvează output-ul într-un fișier și atașează-l la raport/temă, dacă este cerut;
- notează versiunea de kernel (`uname -r`) și versiunea Python (`python3 --version`) când compari rezultate.

*Materiale dezvoltate de Revolvix pentru ASE București - CSIE*  
*Sisteme de Operare | Anul I, Semestrul 2 | 2025-2026*
