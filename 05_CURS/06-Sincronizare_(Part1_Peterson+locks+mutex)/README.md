# Sisteme de Operare - Săptămâna 6: Sincronizare (Partea 1)

> **by Revolvix** | ASE București - CSIE | Anul I, Semestrul 2 | 2025-2026

---

## Obiectivele Săptămânii

1. **Identifici** problemele de race condition în cod concurent
2. Explici conceptul de secțiune critică și proprietățile necesare
3. Descrii algoritmul Peterson și mecanismele hardware de sincronizare
4. **Folosești** lacăte (locks/mutex) pentru protejarea secțiunilor critice

---

## Context aplicativ (scenariu didactic): Cum pierzi bani din cont dacă doi ATM-uri procesează simultan?

Ai 1000 lei în cont. Mergi la un ATM să scoți 800 lei. În același moment, soția ta plătește online 500 lei. Ambele sisteme citesc soldul: 1000 lei. Ambele decid că e suficient. Ambele scad. Rezultat final: ai scos 1300 lei din 1000 lei disponibili! Aceasta este o **race condition**.

---

## Conținut Curs (6/14)

### 1. Race Condition

#### Definiție Formală

> **Race condition** este o situație în care **rezultatul execuției depinde de ordinea (nedeterministă) în care thread-urile sunt planificate** pe procesor. Apare când mai multe thread-uri accesează date partajate și cel puțin unul modifică datele.

#### Explicație Intuitivă

Imaginează-ți doi oameni care încearcă să treacă simultan prin aceeași ușă:
- Dacă unul ajunge primul: OK
- Dacă ajung exact simultan: se blochează sau se lovesc

În cod:
```python
# Thread 1 și Thread 2 fac ambele:
counter = counter + 1

# Descompus:
# 1. LOAD counter → registru
# 2. ADD 1
# 3. STORE registru → counter

# Dacă Thread 2 face LOAD înainte ca Thread 1 să facă STORE:
# Ambele văd aceeași valoare, ambele incrementează, una se pierde!
```

#### Context Istoric

| An | Eveniment |
|----|-----------|
| **1965** | Dijkstra identifică formal problema și introduce semafoare |
| **1966** | Problema "critical section" definită |
| **1981** | Peterson publică algoritmul pentru 2 procese |
| **2000s** | Memory barriers devin critice pe multi-core |

---

### 2. Secțiunea Critică

#### Definiție Formală

> **Secțiunea critică** este porțiunea de cod în care un proces **accesează resurse partajate**. O soluție corectă trebuie să satisfacă: **Mutual Exclusion**, Progress și **Bounded Waiting**.

```
entry_section();      // Cere acces
CRITICAL_SECTION;     // Accesează resursa
exit_section();       // Eliberează acces
remainder_section();  // Cod non-critic
```

#### Proprietățile Necesare

| Proprietate | Descriere | Metaforă |
|-------------|-----------|----------|
| **Mutual Exclusion** | Maxim un proces în secțiunea critică | Doar o persoană în toaletă |
| Progress | Dacă nimeni nu e în CS, cineva poate intra | Toaleta nu rămâne ocupată fără nimeni |
| **Bounded Waiting** | Limită pe numărul de "depășiri" | Nu poți fi sărit la infinit |

---

### 3. Algoritmul Peterson (2 Procese)

#### Definiție Formală

> **Algoritmul Peterson** este o soluție software pentru problema secțiunii critice pentru **2 procese**, folosind doar variabile partajate, fără suport hardware special.

#### Pseudocod

```c
// Variabile partajate
int turn;          // Al cui e rândul
bool flag[2];      // flag[i] = true dacă Pi vrea să intre

// Proces Pi (i = 0 sau 1)
flag[i] = true;        // Vreau să intru
turn = 1 - i;          // Dau prioritate celuilalt
while (flag[1-i] && turn == 1-i)
    ;                  // Așteaptă (busy-wait)
// CRITICAL SECTION
flag[i] = false;       // Am terminat
```

#### De ce funcționează?

- **Mutual exclusion**: Dacă ambele flag sunt true, turn decide cine intră
- Progress: Dacă celălalt nu vrea (flag=false), intri imediat
- **Bounded waiting**: Maximum o "depășire"

#### constrângeri

- Doar 2 procese
- **Busy-waiting** (spinlock)
- **Nu funcționează pe CPU moderne** fără memory barriers (reordonare instrucțiuni!)

---

### 4. Instrucțiuni Atomice Hardware

#### Definiție Formală

> **Instrucțiunile atomice** sunt operații hardware **indivizibile** - odată începute, se completează fără întrerupere.

#### Test-and-Set (TAS)

```c
// Hardware atomic
bool test_and_set(bool *target) {
    bool rv = *target;
    *target = true;
    return rv;
}

// Lock cu TAS
bool lock = false;

void acquire() {
    while (test_and_set(&lock))
        ;  // Spin până lock era false
}

void release() {
    lock = false;
}
```

#### Compare-and-Swap (CAS)

```c
// Hardware atomic
bool compare_and_swap(int *val, int expected, int new_val) {
    if (*val == expected) {
        *val = new_val;
        return true;
    }
    return false;
}

// Lock-free increment
void atomic_increment(int *counter) {
    int old;
    do {
        old = *counter;
    } while (!compare_and_swap(counter, old, old + 1));
}
```

#### Implementare Comparativă

| Aspect | x86/x64 | ARM |
|--------|---------|-----|
| TAS | `lock xchg` | `ldrex/strex` |
| CAS | `lock cmpxchg` | `ldrex/strex` + loop |
| Atomic add | `lock add` | `ldadd` (ARMv8.1+) |

---

### 5. Mutex (Mutual Exclusion Lock)

#### Definiție Formală

> Mutex este un mecanism de sincronizare care asigură că **doar un thread** poate "deține" lock-ul la un moment dat. Alte thread-uri care încearcă să-l obțină sunt blocate (puse în sleep) până când lock-ul e eliberat.

#### Diferența: Spinlock vs Mutex

| Spinlock | Mutex |
|----------|-------|
| Busy-wait (CPU 100%) | Sleep (CPU 0%) |
| Bun pentru CS scurte | Bun pentru CS lungi |
| Fără context switch | Cu context switch |
| Irosește CPU dacă așteaptă mult | Overhead la acquire/release |

#### Implementare Python

```python
import threading
import time

# Mutex în Python
lock = threading.Lock()
counter = 0

def increment_safe():
    global counter
    with lock:  # acquire() + release() automat
        temp = counter
        time.sleep(0.001)  # Simulează procesare
        counter = temp + 1

# Race condition demo
def increment_unsafe():
    global counter
    temp = counter
    time.sleep(0.001)
    counter = temp + 1

# Test
counter = 0
threads = [threading.Thread(target=increment_safe) for _ in range(10)]
for t in threads: t.start()
for t in threads: t.join()
print(f"Safe counter: {counter}")  # 10

counter = 0
threads = [threading.Thread(target=increment_unsafe) for _ in range(10)]
for t in threads: t.start()
for t in threads: t.join()
print(f"Unsafe counter: {counter}")  # Probabil < 10!
```

---

## Laborator/Seminar (Sesiunea 3/7)

### Materiale TC
- TC2e - Unix Tools (find, xargs)
- TC4b - File Permissions
- TC4g - Positional Parameters
- TC4h - Cron Jobs

### Tema 3: `tema3_backup.sh`

Script de backup cu rotație:
- `-s SOURCE` - director sursă
- `-d DEST` - destinație
- `-n NUM` - backups păstrate
- `-v` - verbose

---

## Lectură Recomandată

### OSTEP
- [Cap 28 - Locks](https://pages.cs.wisc.edu/~remzi/OSTEP/threads-locks.pdf)
- [Cap 29 - Lock-based Data Structures](https://pages.cs.wisc.edu/~remzi/OSTEP/threads-locks-usage.pdf)

---

*Materiale by Revolvix pentru ASE București - CSIE*

## Scripting în context (Bash + Python): Mutual exclusion în practică: lockfile pentru backup

### Fișiere incluse

- Bash: `scripts/backup_with_lock.sh` — Backup cu rotație + `flock` (evită execuții concurente).
- Python: `scripts/lock_demo.py` — Demonstrație `fcntl.flock()` în două terminale.

### Rulare rapidă

```bash
./scripts/backup_with_lock.sh -s . -d ./_backups --dry-run
./scripts/lock_demo.py --lock /tmp/demo.lock --hold 5
```

### Legătura cu conceptele din această săptămână

- Un lockfile este analogul practic al mutual exclusion: previne interleaving-ul periculos între două instanțe de proces.
- `flock`/`fcntl.flock` leagă teoria (locks) de administrarea reală (cron, backup, rotații).

### Practică recomandată

- rulează întâi scripturile pe un director de test (nu pe date critice);
- salvează output-ul într-un fișier și atașează-l la raport/temă, dacă este cerut;
- notează versiunea de kernel (`uname -r`) și versiunea Python (`python3 --version`) când compari rezultate.


---

## Auto-evaluare

### Întrebări de verificare

1. **[REMEMBER]** Ce este o race condition? Definește secțiunea critică și cele 3 condiții pentru o soluție corectă.
2. **[UNDERSTAND]** Explică cum funcționează algoritmul Peterson pentru 2 procese. De ce are nevoie de variabilele `flag[]` și `turn`?
3. **[ANALYSE]** Compară mutex-ul cu spinlock-ul. În ce situații este preferabil fiecare? Analizează overhead-ul și utilizarea CPU.

### Mini-provocare (opțional)

Demonstrează o race condition în Python folosind 2 thread-uri care incrementează același contor fără sincronizare.

---


---


---

## Nuanțe și Cazuri Speciale

### Ce NU am acoperit (limitări didactice)

- **Memory barriers / fences**: Instrucțiuni CPU care garantează ordinea operațiilor de memorie.
- **Lock-free și wait-free algorithms**: Structuri de date fără locks (ex: CAS-based queues).
- **RCU (Read-Copy-Update)**: Mecanism Linux pentru citiri frecvente fără lock.

### Greșeli frecvente de evitat

1. **Double-checked locking fără memory barriers**: Pattern clasic care nu funcționează fără `volatile` sau barriers.
2. **Busy waiting excesiv**: Spinlocks doar pentru secțiuni critice foarte scurte.
3. **Lock ordering inconsistent**: Dacă A→B într-un loc și B→A în altul, deadlock garantat.

### Întrebări rămase deschise

- Pot compilatoarele să detecteze automat race conditions la compile time?
- Cum evoluează primitiva de sincronizare pentru arhitecturi heterogene (CPU+GPU)?

## Privire înainte

**Săptămâna 7: Sincronizare (Partea 2)** — De la mutex-uri simple trecem la semafoare și monitoare. Vom studia problema clasică producător-consumator și cum se rezolvă elegant cu primitive de sincronizare de nivel mai înalt.

**Pregătire recomandată:**
- Revizuiește algoritmul Peterson și limitările sale
- Citește OSTEP Capitolul 31 (Semaphores)

## Rezumat Vizual

```
┌─────────────────────────────────────────────────────────────────┐
│                    SĂPTĂMÂNA 6: SINCRONIZARE I — RECAP          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  PROBLEMA: Race Condition                                       │
│  └── Rezultat depinde de ordinea execuției → BUG!              │
│                                                                 │
│  SECȚIUNEA CRITICĂ                                              │
│  ├── Cod care accesează resurse partajate                      │
│  └── Trebuie executat ATOMIC (mutual exclusion)                │
│                                                                 │
│  CONDIȚII SOLUȚIE CORECTĂ                                       │
│  ├── 1. Mutual Exclusion: un singur proces în CS               │
│  ├── 2. Progress: decizia se ia în timp finit                  │
│  └── 3. Bounded Waiting: limită la așteptare                   │
│                                                                 │
│  SOLUȚII SOFTWARE                                               │
│  └── Peterson: flag[] + turn (doar 2 procese)                  │
│                                                                 │
│  SOLUȚII HARDWARE                                               │
│  ├── Test-and-Set, Compare-and-Swap (atomice)                  │
│  └── Mutex (implementat cu instrucțiuni atomice)               │
│                                                                 │
│  💡 TAKEAWAY: Fără sincronizare → bug-uri subtile și rare      │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

*Materiale dezvoltate de Revolvix pentru ASE București - CSIE*