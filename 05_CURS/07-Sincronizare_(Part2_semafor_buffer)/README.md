# Sisteme de Operare - Săptămâna 7: Sincronizare (Partea 2)

> by Revolvix | ASE București - CSIE | Anul I, Semestrul 2 | 2025-2026

---

## Obiectivele Săptămânii

După parcurgerea materialelor din această săptămână, vei putea să:

1. Definești semafoarele și să explici diferența dintre binare și counting
2. Implementezi soluția producător-consumator folosind semafoare
3. Descrii conceptul de monitor și variabile de condiție
4. Analizezi problemele clasice de sincronizare și soluțiile lor

---

## Context aplicativ (scenariu didactic): Cum sincronizează Netflix streaming-ul cu buffer-ul?

Când vizionezi un film pe Netflix, un producător (thread de download) descarcă frame-uri și le pune într-un buffer. Un **consumator** (thread de redare) le citește și le afișează. Dacă producătorul e prea lent → buffering. Dacă consumatorul e prea lent → buffer overflow. Cum se sincronizează perfect? Răspunsul: **semafoare** și buffer circular.

> 💡 Gândește-te: Ce s-ar întâmpla dacă buffer-ul ar avea doar 1 element? Dar 1000?

---

## Conținut Curs (7/14)

### 1. Semafoare

#### Definiție Formală

> Semaforul este o variabilă întreagă non-negativă S care poate fi accesată doar prin două operații atomice: wait() (P, proberen = "a testa" în olandeză) și signal() (V, verhogen = "a incrementa"). Introdus de Edsger Dijkstra în 1965.

```
wait(S):    // P(S)
    while S <= 0: block()
    S = S - 1

signal(S):  // V(S)
    S = S + 1
    wakeup_one_waiting_process()
```

Varianta fără busy-wait (cu blocking):
```
typedef struct {
    int value;
    list<process> waiting_queue;
} semaphore;

wait(S):
    S.value--
    if S.value < 0:
        add_to_queue(S.waiting_queue, current_process)
        block()

signal(S):
    S.value++
    if S.value <= 0:
        P = remove_from_queue(S.waiting_queue)
        wakeup(P)
```

#### Explicație Intuitivă

Metafora: Chei la vestiar

Imaginează-ți un vestiar cu 5 dulăpioare, fiecare cu câte o cheie:
- Semaforul = cutia cu cheile
- wait() = iei o cheie (dacă există); dacă nu, aștepți
- signal() = returnezi cheia

| Semafor S | Semnificație |
|-----------|--------------|
| S = 5 | 5 chei disponibile |
| S = 0 | Nicio cheie, toți așteaptă |
| S < 0 | |S| procese în așteptare |

Semafor binar (S ∈ {0, 1}): O singură cheie → mutex!

Semafor counting (S ≥ 0): Mai multe resurse identice (ex: 5 conexiuni DB).

#### Context Istoric

| An | Eveniment | Semnificație |
|----|-----------|--------------|
| 1965 | Dijkstra introduce semafoarele | Primul mecanism formal de sincronizare |
| 1968 | THE multiprogramming system | Prima implementare practică |
| 1972 | UNIX introduce semafoare | `semget()`, `semop()` |
| 1974 | Hoare introduce monitoare | Nivel de abstractizare mai înalt |
| 2003 | POSIX semaphores | Standardizare: `sem_init()`, `sem_wait()` |

> 💡 Fun fact: Dijkstra a folosit inițial litere olandeze: P (proberen = "a testa") și V (verhogen = "a incrementa"). Termenii au rămas în uz academic!

#### Tipuri de Semafoare

```
┌─────────────────────────────────────────────────────────────┐
│                    SEMAFOARE                                │
├──────────────────────────┬──────────────────────────────────┤
│    SEMAFOR BINAR         │    SEMAFOR COUNTING              │
│    (Mutex-like)          │    (Resurse multiple)            │
├──────────────────────────┼──────────────────────────────────┤
│  S ∈ {0, 1}              │  S ∈ {0, 1, 2, ..., N}          │
│                          │                                  │
│  Utilizare:              │  Utilizare:                      │
│  - Mutual exclusion      │  - Pool de conexiuni            │
│  - Lock simplu           │  - Buffer cu N sloturi          │
│                          │  - N imprimante                  │
├──────────────────────────┼──────────────────────────────────┤
│  Exemplu:                │  Exemplu:                        │
│  sem mutex = 1;          │  sem empty = N;  // sloturi goale│
│  wait(mutex);            │  sem full = 0;   // sloturi pline│
│  // critical section     │  sem mutex = 1;  // acces buffer│
│  signal(mutex);          │                                  │
└──────────────────────────┴──────────────────────────────────┘
```

#### Costuri și Trade-off-uri

| Avantaj | Dezavantaj |
|---------|------------|
| Simplu conceptual | Ușor de greșit (deadlock dacă uiți signal) |
| Poate gestiona N resurse | Fără protecție la nivel de limbaj |
| Eficient (blocking) | Debugging dificil |
| Portabil (POSIX) | Nu scalează bine pe multe core-uri |

---

### 2. Problema Producător-Consumator (Bounded Buffer)

#### Definiție Formală

> Problema Bounded Buffer constă în coordonarea unui producător care generează date și le pune într-un buffer de dimensiune finită N, și a unui **consumator** care le extrage. Producătorul trebuie să aștepte dacă buffer-ul e plin; consumatorul trebuie să aștepte dacă e gol.

#### Explicație Intuitivă

Metafora: Linia de producție la pizzerie

- Bucătarul (producător) face pizza și o pune pe tejghea
- Chelnerul (consumator) ia pizza și o duce la client
- Tejgheaua (buffer) are loc pentru 5 pizza (N=5)

Reguli:
- Bucătarul nu poate pune pizza 6 dacă sunt deja 5 pe tejghea → AȘTEAPTĂ
- Chelnerul nu poate lua pizza dacă tejgheaua e goală → AȘTEAPTĂ
- Doi bucătari nu pun simultan pe același loc → MUTEX

#### Soluția cu Semafoare

```
┌─────────────────────────────────────────────────────────────┐
│                    BOUNDED BUFFER                           │
│                                                             │
│   Producer                Buffer                Consumer    │
│   ┌──────┐     empty      ┌─┬─┬─┬─┬─┐     full   ┌──────┐  │
│   │ PROD ├───────────────►│ │ │ │ │ ├───────────►│ CONS │  │
│   └──────┘    (N slots)   └─┴─┴─┴─┴─┘  (items)   └──────┘  │
│                              mutex                          │
│                         (access control)                    │
└─────────────────────────────────────────────────────────────┘

Semafoare:
- empty = N   // câte sloturi goale (inițial toate)
- full = 0    // câte elemente în buffer (inițial zero)
- mutex = 1   // pentru acces exclusiv la buffer
```

Pseudocod:

```c
// Variabile partajate
semaphore empty = N;    // Sloturi libere
semaphore full = 0;     // Elemente în buffer
semaphore mutex = 1;    // Acces exclusiv

buffer_t buffer[N];
int in = 0, out = 0;    // Indici circulari

// PRODUCĂTOR
void producer() {
    while (true) {
        item = produce_item();
        
        wait(empty);        // Așteaptă slot liber
        wait(mutex);        // Intră în CS
        
        buffer[in] = item;
        in = (in + 1) % N;
        
        signal(mutex);      // Iese din CS
        signal(full);       // Anunță element nou
    }
}

// CONSUMATOR  
void consumer() {
    while (true) {
        wait(full);         // Așteaptă element
        wait(mutex);        // Intră în CS
        
        item = buffer[out];
        out = (out + 1) % N;
        
        signal(mutex);      // Iese din CS
        signal(empty);      // Anunță slot liber
        
        consume_item(item);
    }
}
```

**ATENȚIE la ordinea wait()!**
```c
// GREȘIT - poate cauza deadlock!
wait(mutex);    // Ai mutex
wait(empty);    // Dar buffer plin → blochezi cu mutex ținut!

// CORECT
wait(empty);    // Întâi verifici slot
wait(mutex);    // Apoi iei mutex
```

#### Implementare Comparativă

| Aspect | Linux/POSIX | Windows | Python |
|--------|-------------|---------|--------|
| API | `sem_init()`, `sem_wait()`, `sem_post()` | `CreateSemaphore()`, `WaitForSingleObject()` | `threading.Semaphore()` |
| Counting | ✅ Native | ✅ Native | ✅ Native |
| Named | `sem_open("/name")` | `CreateSemaphore(name)` | N/A |
| Max value | `SEM_VALUE_MAX` | ~2^31 | Nelimitat |

#### Implementare Python

```python
#!/usr/bin/env python3
"""
Problema Producător-Consumator cu Semafoare

Demonstrează:
- Semafoare counting pentru coordonare
- Buffer circular
- Sincronizare producător-consumator
"""

import threading
import time
import random
from queue import Queue  # Pentru comparație

# Implementare manuală cu semafoare
class BoundedBuffer:
    """Buffer circular cu semafoare."""
    
    def __init__(self, size: int):
        self.size = size
        self.buffer = [None] * size
        self.in_idx = 0
        self.out_idx = 0
        
        # Semafoare
        self.empty = threading.Semaphore(size)  # Sloturi libere
        self.full = threading.Semaphore(0)       # Elemente disponibile
        self.mutex = threading.Lock()            # Acces exclusiv
    
    def put(self, item):
        """Producător pune element."""
        self.empty.acquire()      # wait(empty)
        with self.mutex:          # wait(mutex) + signal(mutex)
            self.buffer[self.in_idx] = item
            self.in_idx = (self.in_idx + 1) % self.size
        self.full.release()       # signal(full)
    
    def get(self):
        """Consumator ia element."""
        self.full.acquire()       # wait(full)
        with self.mutex:
            item = self.buffer[self.out_idx]
            self.out_idx = (self.out_idx + 1) % self.size
        self.empty.release()      # signal(empty)
        return item

def producer(buffer: BoundedBuffer, producer_id: int, count: int):
    """Producător: generează count elemente."""
    for i in range(count):
        item = f"P{producer_id}-Item{i}"
        print(f"[Producer {producer_id}] Producing: {item}")
        time.sleep(random.uniform(0.1, 0.3))  # Simulează producție
        buffer.put(item)
        print(f"[Producer {producer_id}] Placed: {item}")

def consumer(buffer: BoundedBuffer, consumer_id: int, count: int):
    """Consumator: consumă count elemente."""
    for _ in range(count):
        item = buffer.get()
        print(f"[Consumer {consumer_id}] Got: {item}")
        time.sleep(random.uniform(0.2, 0.4))  # Simulează consum
        print(f"[Consumer {consumer_id}] Consumed: {item}")

def main():
    print("="*60)
    print("PROBLEMA PRODUCĂTOR-CONSUMATOR")
    print("="*60)
    
    BUFFER_SIZE = 3
    ITEMS_PER_PRODUCER = 5
    
    buffer = BoundedBuffer(BUFFER_SIZE)
    
    # 2 producători, 2 consumatori
    threads = [
        threading.Thread(target=producer, args=(buffer, 1, ITEMS_PER_PRODUCER)),
        threading.Thread(target=producer, args=(buffer, 2, ITEMS_PER_PRODUCER)),
        threading.Thread(target=consumer, args=(buffer, 1, ITEMS_PER_PRODUCER)),
        threading.Thread(target=consumer, args=(buffer, 2, ITEMS_PER_PRODUCER)),
    ]
    
    for t in threads:
        t.start()
    for t in threads:
        t.join()
    
    print("\n✅ Toate elementele procesate!")

if __name__ == "__main__":
    main()
```

---

### 3. Monitoare și Variabile de Condiție

#### Definiție Formală

> Monitorul este un construct de nivel înalt (la nivel de limbaj de programare) care încapsulează date partajate și procedurile care le accesează, garantând că doar un thread poate fi activ în monitor la un moment dat. Introdus de C.A.R. Hoare în 1974.

> Variabila de condiție (condition variable) este un mecanism prin care un thread așteaptă până când o anumită condiție devine adevărată, eliberând temporar lock-ul monitorului.

```
condition x;

x.wait():   // Eliberează lock, adaugă thread la coada x, blochează
            // La trezire: re-obține lock

x.signal(): // Trezește UN thread din coada x (dacă există)
            // Sau nu face nimic dacă coada e goală
```

#### Explicație Intuitivă

Metafora: Sala de așteptare la doctor

- Monitorul = Cabinetul medical (doar un pacient înăuntru)
- Lock-ul implicit = Ușa cabinetului
- Variabila de condiție = Scaunele de așteptare

Scenarii:
- Intri în cabinet (acquiri lock-ul monitorului)
- "Așteptați rezultatul analizelor" → doctorul te trimite în sala de așteptare (condition.wait()) → alt pacient poate intra în cabinet
- "Rezultatele au venit!" → doctorul te cheamă înapoi (condition.signal()) → reintri în cabinet

#### Diferența: wait() pe Condition Variable vs Semafor

| Aspect | CV wait() | Semaphore wait() |
|--------|-----------|------------------|
| Lock | Eliberează lock-ul la wait, re-acquire la trezire | NU afectează lock |
| Memorie | NU memorează signal-uri | Numără signal-uri |
| Signal pierdut | Dacă nimeni nu așteaptă, signal se pierde | Semaforul crește |

#### Mesa vs Hoare Semantics

| Semantică | La signal() | Utilizare |
|-----------|-------------|-----------|
| Hoare | Signaler cedează CPU imediat | Teoretic mai simplu |
| Mesa | Signaler continuă, waiter pus în ready | Practic (Java, POSIX) |

MESA necesită while, nu if!
```c
// GREȘIT cu Mesa semantics
if (condition_false)
    cond.wait();
// Între trezire și obținerea lock-ului, condiția poate deveni iar falsă!

// CORECT
while (condition_false)
    cond.wait();
// Re-verifică condiția după trezire
```

#### Implementare Python

```python
#!/usr/bin/env python3
"""
Monitoare și Variabile de Condiție în Python

Python's threading.Condition = Lock + Condition Variable
"""

import threading
import time

class BoundedBufferMonitor:
    """
    Bounded Buffer implementat ca Monitor.
    
    Condition variable înglobează lock-ul!
    """
    
    def __init__(self, size: int):
        self.size = size
        self.buffer = []
        self.condition = threading.Condition()  # Lock + CV
    
    def put(self, item):
        with self.condition:  # Acquire lock automat
            # WHILE, nu IF! (Mesa semantics)
            while len(self.buffer) >= self.size:
                print(f"[PUT] Buffer plin, aștept...")
                self.condition.wait()  # Eliberează lock, așteaptă
            
            self.buffer.append(item)
            print(f"[PUT] Added: {item}, buffer size: {len(self.buffer)}")
            
            self.condition.notify_all()  # Trezește toți waiters
        # Lock eliberat automat (with statement)
    
    def get(self):
        with self.condition:
            while len(self.buffer) == 0:
                print(f"[GET] Buffer gol, aștept...")
                self.condition.wait()
            
            item = self.buffer.pop(0)
            print(f"[GET] Removed: {item}, buffer size: {len(self.buffer)}")
            
            self.condition.notify_all()
            return item

# Comparație: notify() vs notify_all()
# notify() - trezește UN thread (nedeterminist)
# notify_all() - trezește TOȚI (mai sigur, dar mai mult overhead)
```

---

### 4. Problema Cititori-Scriitori

#### Definiție Formală

> Readers-Writers Problem: Mai mulți cititori pot accesa resursa simultan (nu o modifică), dar un scriitor necesită acces exclusiv (cititori și scriitori nu pot coexista).

```
Variante:
1. First Readers-Writers: Cititorii au prioritate (scriitorii pot înfometa)
2. Second: Scriitorii au prioritate (cititorii pot înfometa)
3. Fair: Ordinea de sosire contează
```

#### Soluție cu Semafoare

```c
// Variabile partajate
semaphore rw_mutex = 1;   // Acces exclusiv pentru scriitori
semaphore mutex = 1;       // Protejează read_count
int read_count = 0;        // Câți cititori activi

// CITITOR
void reader() {
    wait(mutex);
    read_count++;
    if (read_count == 1)
        wait(rw_mutex);    // Primul cititor blochează scriitorii
    signal(mutex);
    
    // READ DATA
    
    wait(mutex);
    read_count--;
    if (read_count == 0)
        signal(rw_mutex);  // Ultimul cititor eliberează
    signal(mutex);
}

// SCRIITOR
void writer() {
    wait(rw_mutex);
    // WRITE DATA
    signal(rw_mutex);
}
```

---

### 5. Brainstorm: Sistem Parcare cu Barieră

Situația: O parcare are 50 de locuri. La intrare și ieșire sunt bariere. Mașinile așteaptă dacă parcarea e plină.

Întrebări:
1. Ce tip de semafor ai folosi?
2. Cum modelezi intrarea și ieșirea?
3. Ce se întâmplă dacă 100 de mașini vin simultan?

Soluție:
```python
parking_spaces = threading.Semaphore(50)

def enter_parking(car_id):
    print(f"Car {car_id} waiting...")
    parking_spaces.acquire()  # Blochează dacă 0 locuri
    print(f"Car {car_id} entered!")

def exit_parking(car_id):
    parking_spaces.release()
    print(f"Car {car_id} exited, spot freed!")
```

---

## Lectură Recomandată

### OSTEP
- Obligatoriu: [Cap 30 - Condition Variables](https://pages.cs.wisc.edu/~remzi/OSTEP/threads-cv.pdf)
- Obligatoriu: [Cap 31 - Semaphores](https://pages.cs.wisc.edu/~remzi/OSTEP/threads-sema.pdf)

### Articole Originale
- Dijkstra, E.W. (1965) - "Cooperating Sequential Processes"
- Hoare, C.A.R. (1974) - "Monitors: An Operating System Structuring Concept"

---

## Tendințe Moderne

| Evoluție | Descriere |
|----------|-----------|
| Lock-free algorithms | CAS-based, evită blocarea |
| Software Transactional Memory | Tranzacții ca în baze de date |
| Async/await | Modelul Python/JavaScript pentru concurență |
| Actor model | Erlang, Akka - mesaje în loc de shared state |
| Channels | Go, Rust - comunicare ca sincronizare |


---

## Auto-evaluare

### Întrebări de verificare

1. **[REMEMBER]** Definește semaforul și operațiile sale fundamentale (wait/P și signal/V). Care este diferența dintre semafor binar și semafor de numărare?
2. **[UNDERSTAND]** Explică problema producător-consumator. Cum rezolvă semafoarele problemele de sincronizare din această situație?
3. **[ANALYSE]** Compară semafoarele cu mutex-urile. În ce situații ai folosi un semafor de numărare în loc de mutex?

### Mini-provocare (opțional)

Implementează problema producător-consumator cu un buffer de capacitate 5 folosind semafoare în Python.

---


---


---

## Nuanțe și Cazuri Speciale

### Ce NU am acoperit (limitări didactice)

- **Condition variables spurious wakeups**: `pthread_cond_wait()` poate returna fără signal real.
- **Priority inversion**: Mars Pathfinder bug (1997) - thread low-priority ține lock necesar de thread high-priority.
- **Readers-Writers problem variante**: Favoriza readers sau writers? Trade-off-uri diferite.

### Greșeli frecvente de evitat

1. **Ordinea wait-mutex-signal greșită**: Producător-consumator cu mutex înainte de semafor → deadlock.
2. **Signal vs Broadcast**: `signal()` trezește un thread; `broadcast()` trezește toate. Alege corect.
3. **Semafoare pentru mutual exclusion**: Folosește mutex când ai nevoie doar de excludere mutuală.

### Întrebări rămase deschise

- Sunt monitoarele din limbaje moderne (Java synchronized, C# lock) suficient de expresive?
- Cum se comportă semafoarele pe sisteme distribuite (Redis, Zookeeper)?

## Privire înainte

**Săptămâna 8: Deadlock (Coffman)** — Ce se întâmplă când sincronizarea merge prost? Procesele se pot bloca reciproc în impas (deadlock). Vom studia condițiile Coffman, grafurile de alocare și algoritmul bancherului pentru evitare.

**Pregătire recomandată:**
- Gândește-te la scenarii de deadlock (ex: două mașini la intersecție)
- Citește OSTEP Capitolul 32 (Common Concurrency Problems)

## Rezumat Vizual

```
┌─────────────────────────────────────────────────────────────────┐
│                    SĂPTĂMÂNA 7: SINCRONIZARE II — RECAP         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  SEMAFOR (Dijkstra, 1965)                                       │
│  ├── Variabilă întreagă S ≥ 0                                  │
│  ├── wait(S): if S>0 then S-- else BLOCK                       │
│  └── signal(S): S++ și WAKEUP dacă cineva așteaptă             │
│                                                                 │
│  TIPURI SEMAFOARE                                               │
│  ├── Binar (mutex): S ∈ {0, 1}                                 │
│  └── De numărare: S ∈ {0, 1, 2, ...N}                          │
│                                                                 │
│  PRODUCĂTOR-CONSUMATOR                                          │
│  ├── empty = N (locuri libere)                                 │
│  ├── full = 0 (elemente disponibile)                           │
│  └── mutex = 1 (acces exclusiv la buffer)                      │
│                                                                 │
│  MONITOR (Hoare, 1974)                                          │
│  ├── Abstracție de nivel înalt                                 │
│  └── Mutual exclusion automat + condition variables            │
│                                                                 │
│  💡 TAKEAWAY: Semafoarele rezolvă atât mutex cât și ordering   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

*Materiale dezvoltate by Revolvix pentru ASE București - CSIE*  
*Sisteme de Operare | Anul I, Semestrul 2 | 2025-2026*

## Scripting în context (Bash + Python): Producer–Consumer și worker pools

### Fișiere incluse

- Python: `scripts/producer_consumer.py` — Producer–Consumer cu buffer finit (blocking).
- Bash: `scripts/pipe_worker_pool.sh` — Worker pool în shell cu `xargs -P` (parallelism controlat).

### Rulare rapidă

```bash
./scripts/producer_consumer.py --producers 2 --consumers 3 --items 30 --buf 5
./scripts/pipe_worker_pool.sh -p 4 -n 20
```

### Legătura cu conceptele din această săptămână

- Producer–Consumer este un model canonic pentru buffer-e finite: exact ce se întâmplă în pipe-uri, rețea, logging.
- `xargs -P` oferă un parallelism controlat, similar conceptual cu un pool de workers.

### Practică recomandată

- rulează întâi scripturile pe un director de test (nu pe date critice);
- salvează output-ul într-un fișier și atașează-l la raport/temă, dacă este cerut;
- notează versiunea de kernel (`uname -r`) și versiunea Python (`python3 --version`) când compari rezultate.

*Materiale dezvoltate de Revolvix pentru ASE București - CSIE*  
*Sisteme de Operare | Anul I, Semestrul 2 | 2025-2026*
