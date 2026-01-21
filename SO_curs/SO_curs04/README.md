# Sisteme de Operare - Săptămâna 4: Planificarea Proceselor (Scheduling)

> by Revolvix | ASE București - CSIE | Anul I, Semestrul 2 | 2025-2026

---

## Obiectivele Săptămânii

După parcurgerea materialelor din această săptămână, vei putea să:

1. Enumeri criteriile de performanță pentru algoritmii de planificare
2. Compari algoritmii FCFS, SJF, SRTF, RR, Priority și MLFQ
3. Calculezi timpii de așteptare și turnaround pentru diverse scenarii
4. Explici funcționarea planificatorului CFS folosit în Linux modern
5. Analizezi trade-off-urile între algoritmi pentru diferite scenarii

---

## Context aplicativ (scenariu didactic): De ce jocul tău lagează când Windows Update rulează în fundal?

Ești în ranked match la CS2, 1v1, round decisiv... și brusc FPS-ul scade de la 144 la 30. Task Manager arată: Windows Update descarcă în fundal. Dar ai un procesor cu 8 core-uri! De ce "simte" jocul update-ul?

Răspunsul stă în planificatorul de procese (scheduler). Chiar dacă ai multe core-uri, există resurse partajate: cache L3, bandwidth memorie, acces la disc. Iar algoritmul de scheduling decide cum să împartă timpul CPU între joc și update. Dacă update-ul are prioritate prea mare sau face multe operații I/O, jocul tău suferă.

> 💡 Gândește-te: Dacă ai fi arhitectul Windows-ului, cum ai prioritiza procesele pentru gaming?

---

## Conținut Curs (4/14)

### 1. Criteriile Planificării

#### Definiție Formală

> Planificarea proceselor (CPU Scheduling) este funcția sistemului de operare care decide care proces din ready queue va fi executat pe CPU și pentru cât timp. Obiectivul este optimizarea unuia sau mai multor criterii de performanță. (Silberschatz et al., 2018)

#### Metrici de Performanță

| Criteriu | Definiție Formală | Formula | Obiectiv |
|----------|-------------------|---------|----------|
| CPU Utilization | Fracțiunea de timp în care CPU execută procese | `U = (T_busy / T_total) × 100%` | Maximizare (ideal: 100%) |
| Throughput | Numărul de procese completate pe unitate de timp | `X = N_completed / T` | Maximizare |
| Turnaround Time | Timpul total de la submit la completare | `T_turnaround = T_completion - T_arrival` | Minimizare |
| Waiting Time | Timpul petrecut în coada Ready | `T_wait = T_turnaround - T_burst` | Minimizare |
| Response Time | Timpul până la primul răspuns | `T_response = T_first_run - T_arrival` | Minimizare (sisteme interactive) |

#### Trade-off-uri Fundamentale

```
       ┌─────────────────────────────────────────────────────────┐
       │                   THROUGHPUT                             │
       │                      ▲                                   │
       │                      │                                   │
       │    Batch Systems     │                                   │
       │    (servere, calcul) │                                   │
       │                      │                                   │
       │         ◄────────────┼────────────►                      │
       │                      │                                   │
       │                      │    Interactive Systems            │

> 💡 De-a lungul anilor, am constatat că exemplele practice bat teoria de fiecare dată.

       │                      │    (desktop, gaming)              │
       │                      ▼                                   │
       │               RESPONSE TIME                              │
       └─────────────────────────────────────────────────────────┘
```

---

### 2. FCFS (First-Come, First-Served)

#### Definiție Formală

> First-Come, First-Served (FCFS), cunoscut și ca FIFO (First-In, First-Out), este algoritmul de planificare care servește procesele în ordinea exactă a sosirii lor în ready queue. Este un algoritm **non-preemptiv** - odată ce un proces începe execuția, rulează până la completare sau blocare.

Formal:
```
Pentru procesele P = {p₁, p₂, ..., pₙ} cu arrival times A = {a₁, a₂, ..., aₙ}:
Ordinea de execuție: sort(P) by A ascending
```

#### Explicație Intuitivă

Metafora: Coada la supermarket fără case rapide

- Ai 5 clienți la coadă
- Primul venit = primul servit
- Chiar dacă ai doar un baton de ciocolată, aștepți după cel cu căruciorul plin
- Fair? Da! Eficient? Nu neapărat...

Exemplul clasic:
```
Imaginează-ți la McDonald's:

Trei lucruri contează aici: client a: comandă meniu complet (10 minute), client b: doar o apă (30 secunde), și client c: desert (1 minut).


Cu FCFS: B și C așteaptă 10 minute pentru că A a venit primul!
```

#### Context Istoric

| An | Context |
|----|---------|
| 1950s | Primul algoritm folosit (batch processing) |
| ~1956 | GM-NAA I/O folosea FCFS pentru job-uri |
| 1960s | Înlocuit de algoritmi mai sofisticați pentru time-sharing |
| Azi | Încă folosit: imprimante, cozi de mesaje, I/O requests |

#### Exemplu Calcul

```
Procese: P1(burst=24), P2(burst=3), P3(burst=3)
Toate sosesc la t=0

Ordinea sosirii: P1, P2, P3

Gantt Chart:
┌──────────────────────────┬─────┬─────┐
│            P1            │ P2  │ P3  │
└──────────────────────────┴─────┴─────┘
0                         24   27    30

Calcule:
P1: Wait=0,  Turnaround=24
P2: Wait=24, Turnaround=27
P3: Wait=27, Turnaround=30

Average Waiting Time = (0+24+27)/3 = 17.0
Average Turnaround = (24+27+30)/3 = 27.0
```

#### Costuri și Trade-off-uri

| Avantaj | Dezavantaj |
|---------|------------|
| foarte simplu de implementat | Convoy Effect - procese scurte așteaptă după cele lungi |
| Fair (în sensul ordinii) | Waiting time mediu poate fi foarte mare |
| Zero overhead scheduling | Response time slab pentru sisteme interactive |
| Predictibil | Nu ține cont de caracteristicile proceselor |

Convoy Effect ilustrat:
```
Worst case:
- P1 (burst=1000) sosește la t=0
- P2, P3, ..., P100 (burst=1 fiecare) sosesc la t=1

Toți cei 99 de procese scurte așteaptă ~1000 unități!
```

#### Implementare Comparativă

| Aspect | Linux | Windows | macOS |
|--------|-------|---------|-------|
| Folosit pentru | I/O scheduling (Deadline, NOOP) | Print queue, COM ports | I/O queues |
| Nivel | Kernel (I/O scheduler) | Kernel (Spooler) | Kernel |
| Implementare | Simple linked list | Queue object | Queue |

#### Reproducere în Python

```python
#!/usr/bin/env python3
"""
FCFS (First-Come, First-Served) Scheduler

Demonstrează:

- Algoritmul FCFS de bază
- Calculul metricilor (waiting time, turnaround time)
- Convoy effect

"""

from dataclasses import dataclass
from typing import List

@dataclass
class Process:
    """Reprezentare proces pentru scheduling."""
    pid: str
    arrival_time: int
    burst_time: int
    
    # Calculated fields
    start_time: int = 0
    completion_time: int = 0
    waiting_time: int = 0
    turnaround_time: int = 0

def fcfs_schedule(processes: List[Process]) -> List[Process]:
    """
    Algoritm FCFS.
    
    Complexitate: O(n log n) pentru sortare, O(n) pentru scheduling
    Spațiu: O(1) extra
    """
    # Sortăm după arrival time
    sorted_procs = sorted(processes, key=lambda p: p.arrival_time)
    
    current_time = 0
    
    for proc in sorted_procs:
        # Dacă CPU e idle, avansăm la arrival
        if current_time < proc.arrival_time:
            current_time = proc.arrival_time
        
        proc.start_time = current_time
        proc.completion_time = current_time + proc.burst_time

> 💡 În laboratoarele anterioare, am văzut că cea mai frecventă greșeală e uitarea ghilimelelor la variabile cu spații.

        proc.turnaround_time = proc.completion_time - proc.arrival_time
        proc.waiting_time = proc.turnaround_time - proc.burst_time
        
        current_time = proc.completion_time
    
    return sorted_procs

def print_gantt_chart(processes: List[Process]):
    """Afișează Gantt Chart ASCII."""
    print("\nGantt Chart:")
    print("┌" + "─" * 50 + "┐")
    
    timeline = ""
    labels = ""
    current = 0
    
    for proc in processes:
        width = max(3, proc.burst_time // 2)
        timeline += f"│{proc.pid:^{width}}"
        labels += f"{current:<{width+1}}"
        current = proc.completion_time
    
    timeline += "│"
    labels += str(current)
    
    print(timeline)
    print("└" + "─" * 50 + "┘")
    print(labels)

def print_metrics(processes: List[Process]):
    """Afișează metricile de performanță."""
    print("\n" + "="*60)
    print(f"{'PID':<6} {'Arrival':<8} {'Burst':<7} {'Start':<7} "
          f"{'Complete':<10} {'Wait':<6} {'Turnaround':<10}")
    print("="*60)
    
    for p in processes:
        print(f"{p.pid:<6} {p.arrival_time:<8} {p.burst_time:<7} "
              f"{p.start_time:<7} {p.completion_time:<10} "
              f"{p.waiting_time:<6} {p.turnaround_time:<10}")
    
    avg_wait = sum(p.waiting_time for p in processes) / len(processes)
    avg_turn = sum(p.turnaround_time for p in processes) / len(processes)
    
    print("="*60)
    print(f"Average Waiting Time: {avg_wait:.2f}")
    print(f"Average Turnaround Time: {avg_turn:.2f}")

def demonstrate_convoy_effect():
    """Demonstrează convoy effect."""
    print("\n" + "="*60)
    print("DEMONSTRAȚIE CONVOY EFFECT")
    print("="*60)
    
    # Scenario 1: Proces lung primul
    print("\n--- Scenario 1: Proces LUNG primul ---")
    procs1 = [
        Process("P1", 0, 24),  # Lung
        Process("P2", 0, 3),   # Scurt
        Process("P3", 0, 3),   # Scurt
    ]
    result1 = fcfs_schedule(procs1)
    print_metrics(result1)
    
    # Scenario 2: Procese scurte primul
    print("\n--- Scenario 2: Procese SCURTE primul ---")
    procs2 = [
        Process("P2", 0, 3),   # Scurt
        Process("P3", 0, 3),   # Scurt
        Process("P1", 0, 24),  # Lung
    ]
    # Simulăm că P2 sosește primul
    procs2[0].arrival_time = 0
    procs2[1].arrival_time = 0.001
    procs2[2].arrival_time = 0.002
    result2 = fcfs_schedule(procs2)
    print_metrics(result2)
    
    print("\n📊 Observație: Aceleași procese, ordine diferită → "
          "waiting time dramatic diferit!")

if __name__ == "__main__":
    # Exemplu de bază
    processes = [
        Process("P1", 0, 24),
        Process("P2", 0, 3),
        Process("P3", 0, 3),
    ]
    
    result = fcfs_schedule(processes)
    print_gantt_chart(result)
    print_metrics(result)
    
    demonstrate_convoy_effect()
```

Output:
```
Gantt Chart:
┌──────────────────────────────────────────────────┐
│     P1      │ P2 │ P3 │
└──────────────────────────────────────────────────┘
0             24   27   30

============================================================
PID    Arrival  Burst   Start   Complete   Wait   Turnaround
============================================================
P1     0        24      0       24         0      24        
P2     0        3       24      27         24     27        
P3     0        3       27      30         27     30        
============================================================
Average Waiting Time: 17.00
Average Turnaround Time: 27.00
```

#### Tendințe Moderne

| Context | Utilizare FCFS |
|---------|----------------|
| Print Queue | Document-urile se printează în ordine |
| Message Queues | RabbitMQ, SQS - opțional FIFO |
| Batch Jobs | Kubernetes Jobs (fără priority) |
| I/O Scheduling | NOOP scheduler (pentru SSD-uri) |

---

### 3. SJF (Shortest Job First)

#### Definiție Formală

> Shortest Job First (SJF), cunoscut și ca Shortest Job Next (SJN), este algoritmul care selectează procesul cu cel mai scurt CPU burst pentru execuție. Poate fi **non-preemptiv** (odată pornit, rulează complet) sau **preemptiv** (SRTF - Shortest Remaining Time First).

Formal:
```
Pentru procesele în ready queue R = {p₁, p₂, ..., pₙ}:
next_process = argmin(pᵢ ∈ R) { burst_time(pᵢ) }
```

Teoremă: SJF este optimal pentru minimizarea waiting time mediu (demonstrat matematic).

#### Explicație Intuitivă

Metafora: Casa de checkout pentru "10 articole sau mai puțin"

Supermarket-ul a descoperit că dacă:
- Clientul cu 2 articole merge la casa rapidă
- Clientul cu căruciorul merge la casa normală

→ Toată lumea e mai fericită! Media timpului de așteptare scade.

Sau: Triage la urgențe (invers)
- Cazurile "ușoare" (burst scurt) sunt rezolvate rapid
- Eliberează resurse pentru cazurile complexe

#### Context Istoric

| An | Eveniment |
|----|-----------|
| 1966 | Analiză teoretică de Conway, Maxwell, Miller |
| 1968 | Demonstrație optimality pentru waiting time |
| 1970s | Probleme practice: cum estimezi burst? |
| Azi | Variante adaptive, machine learning pentru predicție |

#### Exemplu Calcul

```
Procese: P1(burst=6), P2(burst=8), P3(burst=7), P4(burst=3)
Toate sosesc la t=0

SJF Non-preemptiv:
Ordine: P4(3) < P1(6) < P3(7) < P2(8)

Gantt Chart:
┌─────┬────────────┬────────────────┬──────────────────┐
│ P4  │     P1     │      P3        │        P2        │
└─────┴────────────┴────────────────┴──────────────────┘
0     3            9               16                  24

P4: Wait=0,  Turnaround=3
P1: Wait=3,  Turnaround=9
P3: Wait=9,  Turnaround=16
P2: Wait=16, Turnaround=24

Average Waiting Time = (0+3+9+16)/4 = 7.0  ← Mai bun decât FCFS!
Average Turnaround = (3+9+16+24)/4 = 13.0
```

#### SJF Preemptiv (SRTF - Shortest Remaining Time First)

```
Procese:
P1(arrival=0, burst=8)
P2(arrival=1, burst=4)
P3(arrival=2, burst=9)
P4(arrival=3, burst=5)

Timeline:
t=0: P1 starts (remaining=8)
t=1: P2 arrives (remaining=4 < P1's 7) → P1 preempted, P2 runs
t=2: P3 arrives (remaining=9 > P2's 3) → P2 continues
t=3: P4 arrives (remaining=5 > P2's 2) → P2 continues
t=5: P2 completes → P4 runs (remaining=5 < P1's 7 < P3's 9)
t=10: P4 completes → P1 runs (remaining=7 < P3's 9)
t=17: P1 completes → P3 runs
t=26: P3 completes

Gantt Chart:
┌────┬──────┬────────────┬────────────────┬──────────────────┐
│ P1 │  P2  │     P4     │       P1       │        P3        │
└────┴──────┴────────────┴────────────────┴──────────────────┘
0    1      5           10              17                  26
```

#### Problema: Cum știm burst-ul viitor?

NU ȘTIM! SJF e optim teoretic dar impracticabil direct.

Soluție: Estimare folosind istoric:
```
τₙ₊₁ = α × tₙ + (1-α) × τₙ

unde:
- τₙ₊₁ = burst estimat viitor
- tₙ = burst real anterior
- τₙ = estimare anterioară
- α = factor de ponderare (0 < α ≤ 1), tipic 0.5
```

Exponential averaging - estimările recente contează mai mult.

#### Costuri și Trade-off-uri

| Avantaj | Dezavantaj |
|---------|------------|
| Optimal pentru avg waiting time | Trebuie să cunoști/estimezi burst |
| Throughput bun | Starvation - procese lungi pot aștepta la infinit |
| Response time bun pentru procese scurte | Overhead pentru estimare |

Starvation ilustrată:
```
Proces P_lung (burst=1000) ajunge în queue.
Continuu sosesc procese scurte P1, P2, P3...
P_lung nu rulează NICIODATĂ dacă mereu vin altele mai scurte!
```

#### Implementare Comparativă

| Aspect | Linux | Windows | macOS |
|--------|-------|---------|-------|
| Pure SJF | Nu (ar cauza starvation) | Nu | Nu |
| Variante | CFS estimează "virtual runtime" | DFSS folosește quantum adaptive | Similar CFS |
| I/O Scheduling | Deadline scheduler (similar) | - | - |

#### Reproducere în Python

```python
#!/usr/bin/env python3
"""
SJF (Shortest Job First) Scheduler - Non-preemptiv și Preemptiv (SRTF)
"""

from dataclasses import dataclass, field
from typing import List, Optional
import heapq

@dataclass(order=True)
class Process:
    """Proces pentru SJF."""
    burst_time: int = field(compare=True)  # Pentru heap ordering
    pid: str = field(compare=False)
    arrival_time: int = field(compare=False)
    remaining_time: int = field(compare=False, default=0)
    
    start_time: int = field(compare=False, default=-1)
    completion_time: int = field(compare=False, default=0)
    waiting_time: int = field(compare=False, default=0)
    turnaround_time: int = field(compare=False, default=0)
    
    def __post_init__(self):
        self.remaining_time = self.burst_time

def sjf_non_preemptive(processes: List[Process]) -> List[Process]:
    """
    SJF Non-preemptiv.
    
    Complexitate: O(n²) sau O(n log n) cu heap
    """
    procs = [Process(p.burst_time, p.pid, p.arrival_time) for p in processes]
    ready_queue: List[Process] = []
    completed: List[Process] = []
    
    current_time = 0
    procs.sort(key=lambda p: p.arrival_time)
    proc_index = 0
    
    while len(completed) < len(procs):
        # Adaugă procesele care au sosit
        while proc_index < len(procs) and procs[proc_index].arrival_time <= current_time:
            heapq.heappush(ready_queue, procs[proc_index])
            proc_index += 1
        
        if ready_queue:
            # Selectează procesul cu burst minim
            proc = heapq.heappop(ready_queue)
            
            proc.start_time = current_time
            proc.completion_time = current_time + proc.burst_time
            proc.turnaround_time = proc.completion_time - proc.arrival_time
            proc.waiting_time = proc.turnaround_time - proc.burst_time
            
            current_time = proc.completion_time
            completed.append(proc)
        else:
            # CPU idle - avansează la următorul arrival
            current_time = procs[proc_index].arrival_time
    
    return completed

def srtf_preemptive(processes: List[Process]) -> List[Process]:
    """
    Shortest Remaining Time First (SJF Preemptiv).
    
    La fiecare unitate de timp (sau la fiecare arrival),
    verifică dacă trebuie preemptat procesul curent.
    """
    procs = {p.pid: Process(p.burst_time, p.pid, p.arrival_time) 
             for p in processes}
    
    ready_queue: List[Process] = []
    current: Optional[Process] = None
    current_time = 0
    
    # Toate evenimentele (arrivals)
    events = sorted(set(p.arrival_time for p in procs.values()))
    next_event_idx = 0
    
    completed_count = 0
    timeline = []  # Pentru Gantt chart
    
    while completed_count < len(procs):
        # Adaugă procesele care au sosit
        while next_event_idx < len(events) and events[next_event_idx] <= current_time:
            for p in procs.values():
                if p.arrival_time == events[next_event_idx] and p.remaining_time > 0:
                    heapq.heappush(ready_queue, 
                        Process(p.remaining_time, p.pid, p.arrival_time, p.remaining_time))
            next_event_idx += 1
        
        if ready_queue:
            proc_entry = heapq.heappop(ready_queue)
            proc = procs[proc_entry.pid]
            
            if proc.start_time == -1:
                proc.start_time = current_time
            
            # Rulează până la următorul event sau completare
            next_event = events[next_event_idx] if next_event_idx < len(events) else float('inf')
            run_time = min(proc.remaining_time, next_event - current_time)
            
            timeline.append((proc.pid, current_time, current_time + run_time))
            current_time += run_time
            proc.remaining_time -= run_time
            
            if proc.remaining_time == 0:
                proc.completion_time = current_time
                proc.turnaround_time = proc.completion_time - proc.arrival_time
                proc.waiting_time = proc.turnaround_time - proc.burst_time
                completed_count += 1
            else:
                # Pune înapoi în queue pentru mai târziu
                heapq.heappush(ready_queue,
                    Process(proc.remaining_time, proc.pid, proc.arrival_time, proc.remaining_time))
        else:
            # CPU idle
            if next_event_idx < len(events):
                current_time = events[next_event_idx]
    
    return list(procs.values())

# Demo
if __name__ == "__main__":
    processes = [
        Process(6, "P1", 0),
        Process(8, "P2", 0),
        Process(7, "P3", 0),
        Process(3, "P4", 0),
    ]
    
    print("=== SJF Non-Preemptiv ===")
    result = sjf_non_preemptive(processes)
    for p in sorted(result, key=lambda x: x.start_time):
        print(f"{p.pid}: Start={p.start_time}, Complete={p.completion_time}, "
              f"Wait={p.waiting_time}")
    
    avg_wait = sum(p.waiting_time for p in result) / len(result)
    print(f"Average Waiting Time: {avg_wait:.2f}")
```

---

### 4. Round Robin (RR)

#### Definiție Formală

> Round Robin este un algoritm de planificare **preemptiv** care alocă fiecărui proces o cuantă de timp (time quantum) fixă. Procesele sunt servite ciclic - fiecare primește quantum, apoi merge la sfârșitul cozii.

Formal:
```
quantum = q (tipic 10-100 ms)
while processes exist:
    for each process p in ready_queue:
        run(p, min(q, remaining_time(p)))
        if not completed(p):
            enqueue(p, ready_queue)
```

#### Explicație Intuitivă

Metafora: Jocul "Cine are mingea"

- 5 copii stau în cerc
- Fiecare ține mingea 10 secunde
- Apoi o pasează următorului
- Ciclic, toți se joacă "simultan"
- Nimeni nu monopolizează mingea

Sau: Time-sharing la calculator în anii '70
- 10 utilizatori la un mainframe
- Fiecare primește 100ms de CPU
- Schimbă rapid → toți au impresia că rulează simultan

#### Context Istoric

| An | Eveniment |
|----|-----------|
| 1961 | CTSS (Compatible Time-Sharing System) - MIT |
| 1964 | Multics folosește time slicing |
| 1969 | UNIX - primul cu quantum configurabil |
| Azi | Baza pentru CFS și alte schedulere moderne |

#### Exemplu Calcul

```
Procese: P1(burst=24), P2(burst=3), P3(burst=3)
Quantum = 4

Timeline:
t=0-4:   P1 rulează (remaining=20)
t=4-7:   P2 rulează (remaining=0) ✓ DONE
t=7-10:  P3 rulează (remaining=0) ✓ DONE
t=10-14: P1 rulează (remaining=16)
t=14-18: P1 rulează (remaining=12)
t=18-22: P1 rulează (remaining=8)
t=22-26: P1 rulează (remaining=4)
t=26-30: P1 rulează (remaining=0) ✓ DONE

Gantt Chart:
┌────┬────┬────┬────┬────┬────┬────┬────┐
│ P1 │ P2 │ P3 │ P1 │ P1 │ P1 │ P1 │ P1 │
└────┴────┴────┴────┴────┴────┴────┴────┘
0    4    7   10   14   18   22   26   30

P1: Wait=6 (30-24), Turnaround=30
P2: Wait=4,        Turnaround=7
P3: Wait=7,        Turnaround=10

Average Waiting Time = (6+4+7)/3 = 5.67
```

#### Trade-off Quantum

| Quantum | Comportament |
|---------|--------------|
| Prea mare (q → ∞) | Devine FCFS |
| Prea mic (q → 0) | Prea multe context switches → overhead |
| Optim | ~80% din bursts < quantum |

```
Overhead context switch: ~10-100 μs
Quantum = 10 ms → overhead = 0.1-1%
Quantum = 100 μs → overhead = 10-50% ← Problematic!
```

#### Costuri și Trade-off-uri

| Avantaj | Dezavantaj |
|---------|------------|
| Fair - toți primesc timp egal | Waiting time mediu poate fi mare |
| Response time bun | Context switch overhead |
| No starvation | Nu optimal pentru throughput |
| Simplu de implementat | Quantum fix nu e ideal pentru toate workloads |

---

### 5. Priority Scheduling

#### Definiție Formală

> Priority Scheduling este algoritmul care asociază fiecărui proces o **prioritate** (un număr) și selectează procesul cu prioritatea cea mai mare pentru execuție. Poate fi **preemptiv** sau **non-preemptiv**.

Convenție uzuală:
- Număr MIC = prioritate MARE (Linux, UNIX)
- Sau invers în alte sisteme

#### Problema: Starvation

```
P_low_priority (priority=10) ajunge în queue.
Continuu sosesc P_high (priority=1).
P_low_priority nu rulează NICIODATĂ!
```

Soluție: Aging
```
// La fiecare unitate de timp în queue:
if (process.waiting_time > threshold) {
    process.priority--;  // Crește prioritatea
}
```

---

### 6. MLFQ (Multi-Level Feedback Queue)

#### Definiție Formală

> Multi-Level Feedback Queue este un algoritm care folosește multiple cozi cu priorități diferite, permițând proceselor să migreze între cozi bazat pe comportamentul lor. Combină avantajele mai multor algoritmi.

#### Explicație Intuitivă

Metafora: Hotelul cu mai multe etaje

- Etaj 10 (VIP): Checking rapid, serviciu instant
- Etaj 5 (Standard): Serviciu normal
- Etaj 1 (Budget): Aștepți mai mult
- Salvează o copie de backup dacă modifici fișiere importante

Reguli:
- Toți oaspeții noi ajung la VIP
- Dacă faci scandal (folosești prea mult) → cobori un etaj
- Dacă stai mult și te porți frumos → urci înapoi
- Verifică întotdeauna rezultatul înainte de a continua

În SO:
- Procese I/O-bound (interactive): Stau sus (răspuns rapid)
- Procese CPU-bound (batch): Coboară (throughput)

#### Reguli MLFQ

```
┌─────────────────────────────────────────────────────────────┐
│  Queue 0 (highest priority): RR, quantum=8ms                │
│      ↓ (if uses entire quantum without blocking)            │
│  Queue 1: RR, quantum=16ms                                  │
│      ↓                                                      │
│  Queue 2: RR, quantum=32ms                                  │
│      ↓                                                      │
│  Queue 3 (lowest priority): FCFS                            │
└─────────────────────────────────────────────────────────────┘

Reguli:
1. Proces nou → Queue 0
2. Folosește tot quantum-ul → coboară o coadă
3. Renunță la CPU (I/O) → rămâne în aceeași coadă
4. Periodic (S ms): BOOST toate procesele la Queue 0
```

Boost previne starvation pentru procese CPU-bound.

#### Implementare: Linux CFS

Linux modern folosește CFS (Completely Fair Scheduler), inspirat de MLFQ:

```bash
# Prioritate "nice" (-20 la +19)
nice -n 10 ./script.sh      # Rulează cu prioritate mai mică
renice -n -5 -p PID         # Modifică prioritatea

# Informații scheduler
cat /proc/PID/sched | head -20

# Classes de scheduling
chrt -p PID                 # Afișează policy
# SCHED_OTHER - CFS (default)
# SCHED_FIFO - Real-time FIFO
# SCHED_RR - Real-time RR
```

---

### 7. Brainstorm: Scheduler pentru Server Web

Situația: Ești arhitectul SO pentru un server web care servește 3 tipuri de request-uri:

Concret: API calls (burst scurt ~5ms, multe/secundă). Page renders (burst mediu ~50ms). Și Report generation (burst lung ~5s, rare).


Întrebări:
1. Ce algoritm ai folosi?
2. Cum ai prioritiza?
3. Ce se întâmplă la spike de traffic?

Soluție practică: 
- Worker threads pentru I/O-bound (API, renders)
- Background queue separată pentru CPU-bound (reports)
- Rate limiting + circuit breaker
- MLFQ-like cu separare explicită

---

## Laborator/Seminar (Sesiunea 2/7)

### Materiale TC
- TC2a-TC2d: Variables, Control Operators
- TC3a-TC3b: Filters, Loops
- TC4a: I/O Redirection
- Salvează o copie de backup dacă modifici fișiere importante

### Tema 2: `tema2_procesare.sh`

Script care procesează fișiere .txt:
- `-d DIR` - director de scanat
- `-n NUM` - linii preview
- `-v` - verbose
- `-h` - help

---

## Lectură Recomandată

### OSTEP
- [Cap 7 - Scheduling: Introduction](https://pages.cs.wisc.edu/~remzi/OSTEP/cpu-sched.pdf)
- [Cap 8 - MLFQ](https://pages.cs.wisc.edu/~remzi/OSTEP/cpu-sched-mlfq.pdf)

---

## Sumar Algoritmi

| Algoritm | Tip | Optim pentru | Problemă |
|----------|-----|--------------|----------|
| FCFS | Non-preemptiv | Simplicitate | Convoy effect |
| SJF | Non-preemptiv | Avg wait time | Starvation, predicție |
| SRTF | Preemptiv | Avg wait time | Starvation, overhead |
| RR | Preemptiv | Fairness, response | Quantum tuning |
| Priority | Ambele | Control explicit | Starvation |
| MLFQ | Preemptiv | Adaptive | Complexitate |

---

*Materiale dezvoltate by Revolvix pentru ASE București - CSIE*  
*Sisteme de Operare | Anul I, Semestrul 2 | 2025-2026*

## Scripting în context (Bash + Python): Efectul `nice` asupra scheduling-ului

### Fișiere incluse

- Python: `scripts/cpu_hog.py` — Workload CPU-bound controlat.
- Bash: `scripts/nice_demo.sh` — Rulează două workload-uri identice cu `nice` diferit și compară.

### Rulare rapidă

```bash
./scripts/nice_demo.sh --seconds 5
```

### Legătura cu conceptele din această săptămână

- `nice` este un instrument user-space care influențează deciziile scheduler-ului (în special când există competiție pe CPU).
- Workload-ul CPU-bound izolează efectul scheduling-ului de I/O.

### Practică recomandată

- rulează întâi scripturile pe un director de test (nu pe date critice);
- salvează output-ul într-un fișier și atașează-l la raport/temă, dacă este cerut;
- notează versiunea de kernel (`uname -r`) și versiunea Python (`python3 --version`) când compari rezultate.

*Materiale dezvoltate de Revolvix pentru ASE București - CSIE*  
*Sisteme de Operare | Anul I, Semestrul 2 | 2025-2026*
