# Sisteme de Operare - Săptămâna 8: Deadlock

> by Revolvix | ASE București - CSIE | Anul I, Semestrul 2 | 2025-2026

---

## Obiectivele Săptămânii

După parcurgerea materialelor din această săptămână, vei putea să:

1. Definești deadlock-ul și să enumeri cele 4 condiții Coffman
2. Construiești și analizezi grafuri de alocare resurse
3. Compari strategiile de gestionare: prevenire, evitare, detectare
4. Aplici algoritmul Banker pentru evitarea deadlock-ului
5. Rezolvi problema filozofilor la masă cu diferite abordări

---

## Context aplicativ (scenariu didactic): De ce se blochează traficul într-o intersecție?

Imaginează-ți o intersecție fără semafoare: 4 mașini ajung simultan din cele 4 direcții. Fiecare așteaptă să treacă mașina din dreapta. Nimeni nu mișcă. Nimeni nu poate mișca. Aceasta este un deadlock - o situație în care fiecare participant așteaptă o resursă deținută de altul, formând un ciclu de așteptare infinit.

> 💡 Gândește-te: Cum ar rezolva problema un semafor? Dar un polițist? Sunt soluții diferite pentru același deadlock.

---

## Conținut Curs (8/14)

### 1. Ce este Deadlock-ul?

#### Definiție Formală

> Deadlock (impas/interblocare) este o situație în care un set de procese sunt blocate permanent, fiecare așteptând o resursă deținută de alt proces din set, formând un ciclu de dependențe. Niciun proces din set nu poate avansa. (Coffman et al., 1971)

Formal, fie R = {R₁, R₂, ..., Rₘ} mulțimea resurselor și P = {P₁, P₂, ..., Pₙ} mulțimea proceselor:

```
Deadlock ⟺ ∃ ciclu în graful wait-for:
P₁ → R₁ → P₂ → R₂ → ... → Pₙ → Rₙ → P₁
```

#### Explicație Intuitivă

Metafora: Standul de biciclete partajate

- 4 prieteni vor să meargă cu bicicleta
- Fiecare bicicletă are nevoie de 2 roți
- Sunt 4 roți în total
- Fiecare prieten apucă câte o roată și refuză să o dea înainte să primească a doua

Rezultat: Nimeni nu are 2 roți. Nimeni nu pleacă. Toți așteaptă la infinit!

Ilustrație proces:
```
P1 deține R1, vrea R2
P2 deține R2, vrea R3
P3 deține R3, vrea R4
P4 deține R4, vrea R1
→ CICLU → DEADLOCK!
```

#### Context Istoric

| An | Eveniment | Semnificație |
|----|-----------|--------------|
| 1965 | Dijkstra identifică problema în THE System | Prima descriere formală |
| 1971 | Coffman, Elphick, Shoshani | Cele 4 condiții necesare |
| 1971 | Havender | Strategii de prevenire |
| 1977 | Holt | Algoritmul de detectare |
| 1983 | Dijkstra | Problema filozofilor (simplificată) |

> 💡 Fun fact: Problema "Dining Philosophers" a fost inventată de Dijkstra în 1965 ca exercițiu pentru studenți, dar a devenit una dintre cele mai studiate probleme în concurență!

---

### 2. Condițiile Coffman (Necesare pentru Deadlock)

#### Definiție Formală

> Deadlock-ul poate apărea dacă și numai dacă toate cele 4 condiții următoare sunt îndeplinite simultan:

| # | Condiție | Definiție Formală | Metaforă |
|---|----------|-------------------|----------|
| 1 | Mutual Exclusion | Resursa poate fi deținută de cel mult un proces | O cheie, o încuietoare |
| 2 | Hold and Wait | Procesul deține resurse și așteaptă altele | Ții roata și vrei alta |
| 3 | No Preemption | Resursa nu poate fi luată forțat | Nu smulgi roata din mână |
| 4 | Circular Wait | Există ciclu de așteptare | Toți așteaptă în cerc |

#### Explicație Intuitivă pentru fiecare

1. Mutual Exclusion - "O singură persoană poate folosi wc-ul"
- Resursa NU poate fi partajată simultan
- Dacă ar putea (ex: memorie read-only), nu ar fi problemă

2. Hold and Wait - "Ții furculița și aștepți cuțitul"
- Ai deja ceva, dar vrei și altceva
- Dacă ar trebui să iei totul odată sau nimic, nu ar mai fi problemă

3. No Preemption - "Nu poți lua forțat mâncarea din farfuria altuia"
- Nimeni nu-ți poate lua resursa până n-o dai tu
- Dacă s-ar putea, cineva ar debloca situația

4. Circular Wait - "Toți așteaptă în cerc, nimeni nu cedează"
- A așteaptă B, B așteaptă C, C așteaptă A
- Dacă n-ar fi ciclu, lanțul s-ar termina undeva

---

### 3. Graful de Alocare Resurse (RAG)

#### Definiție Formală

> Resource Allocation Graph (RAG) este un graf direcționat G = (V, E) unde:
> - V = P ∪ R (noduri: procese și resurse)
> - E = Request edges (P → R) ∪ Assignment edges (R → P)

```
Notații:
○ P1, P2, ... = Procese (cercuri)
□ R1, R2, ... = Resurse (dreptunghiuri)
   ● = instanță a resursei
   
P → R = "P cere R" (request edge)
R → P = "R e alocată lui P" (assignment edge)
```

#### Exemplu

```
        ┌───┐         ┌───┐
        │ ○ │ P1      │ ○ │ P2
        └─┬─┘         └─┬─┘
          │             │
          │ request     │ holds
          ▼             │
        ┌─────┐         │
        │ ●   │ R1      │
        └──┬──┘         │
           │            │
           │ holds      │
           ▼            ▼
        ┌───┐         ┌─────┐
        │ ○ │ P3 ───► │ ●   │ R2
        └───┘ request └─────┘

Interpretare:
- P1 cere R1
- R1 e alocată lui P3
- P3 cere R2
- R2 e alocată lui P2
- NU există ciclu → NU e deadlock (încă)
```

#### Regula Ciclului

| Situație | Deadlock? |
|----------|-----------|
| Fără ciclu | ❌ Imposibil |
| Ciclu + 1 instanță per resursă | ✅ Sigur deadlock |
| Ciclu + mai multe instanțe | ⚠️ Posibil (dar nu sigur) |

---

### 4. Strategii de Gestionare

#### Comparație

| Strategie | Metodă | Cost | Utilizare |
|-----------|--------|------|-----------|
| Prevenire | Elimină o condiție Coffman | Mare (restricții) | Design-time |
| Evitare | Nu intra în stare unsafe | Mediu (algoritm) | Run-time |
| Detectare + Recovery | Lasă să apară, apoi rezolvă | Mic + overhead detectare | Sisteme tolerante |
| Ignorare | "Ostrich algorithm" | Zero | UNIX, Windows (parțial) |

---

### 5. Algoritmul Banker (Evitare Deadlock)

#### Definiție Formală

> Algoritmul Banker (Dijkstra, 1965) este un algoritm de evitare a deadlock-ului care decide dacă o cerere de resurse poate fi satisfăcută fără a duce sistemul într-o stare nesigură. Funcționează ca un bancher prudent care nu acordă împrumuturi riscante.

Stare sigură (safe): Există o secvență de procese astfel încât toate pot termina.
Stare nesigură (unsafe): NU garantat deadlock, dar posibil.

#### Explicație Intuitivă

Metafora: Bancherul prudent

Ești bancher cu 10.000€ cash. Ai 3 clienți cu împrumuturi aprobate:
- Client A: Poate cere până la 8.000€, are deja 2.000€
- Client B: Poate cere până la 5.000€, are deja 2.000€  
- Client C: Poate cere până la 4.000€, are deja 3.000€

Total în circulație: 7.000€, Cash disponibil: 3.000€

Întrebare: Dacă B cere încă 1.000€, îi dai?

Răspuns Banker: 
1. După împrumut: cash = 2.000€
2. Cine poate termina cu 2.000€?
   - C are nevoie de max 1.000€ (4.000 - 3.000) → ✅ poate termina
   - C returnează 4.000€ → cash = 6.000€
   - A are nevoie de max 6.000€ → ✅ poate termina
   - B poate termina cu ce a primit
3. Există secvență sigură: C, A, B → APROBARE!

#### Structuri de Date

```
n = numărul de procese
m = numărul de tipuri de resurse

Available[m]        // Resurse disponibile per tip
Max[n][m]           // Cerere maximă per proces
Allocation[n][m]    // Resurse alocate curent
Need[n][m]          // Need = Max - Allocation
```

#### Algoritmul Safety Check

```python
def is_safe_state(available, max_matrix, allocation):
    """
    Verifică dacă starea curentă e sigură.
    
    Returns: (bool, safe_sequence) sau (False, None)
    """
    n = len(allocation)      # Număr procese
    m = len(available)       # Număr tipuri resurse
    
    # Need[i] = Max[i] - Allocation[i]
    need = [[max_matrix[i][j] - allocation[i][j] 
             for j in range(m)] for i in range(n)]
    
    work = available.copy()  # Resurse disponibile
    finish = [False] * n     # Cine a terminat
    safe_sequence = []
    
    # Încearcă să găsești o secvență sigură
    while True:
        # Caută un proces care poate termina
        found = False
        for i in range(n):
            if not finish[i]:
                # Verifică dacă Need[i] <= Work
                if all(need[i][j] <= work[j] for j in range(m)):
                    # Procesul i poate termina
                    # Eliberează resursele
                    for j in range(m):
                        work[j] += allocation[i][j]
                    finish[i] = True
                    safe_sequence.append(f"P{i}")
                    found = True
                    break
        
        if not found:
            break
    
    if all(finish):
        return True, safe_sequence
    else:
        return False, None

def request_resources(process_id, request, available, max_m, allocation):
    """
    Procesul process_id cere resurse.
    
    Returns: True dacă cererea e aprobată, False altfel.
    """
    n = len(allocation)
    m = len(available)
    
    need = [[max_m[i][j] - allocation[i][j] 
             for j in range(m)] for i in range(n)]
    
    # 1. Verifică Request <= Need
    for j in range(m):
        if request[j] > need[process_id][j]:
            raise ValueError("Cerere depășește nevoia declarată!")
    
    # 2. Verifică Request <= Available
    for j in range(m):
        if request[j] > available[j]:
            return False  # Nu sunt suficiente resurse
    
    # 3. Pretinde că alocăm și verifică safety
    new_available = [available[j] - request[j] for j in range(m)]
    new_allocation = [row.copy() for row in allocation]
    for j in range(m):
        new_allocation[process_id][j] += request[j]
    
    safe, sequence = is_safe_state(new_available, max_m, new_allocation)
    
    if safe:
        print(f"✅ Cerere aprobată. Secvență sigură: {sequence}")
        return True
    else:
        print("❌ Cerere respinsă - ar duce în stare unsafe!")
        return False

# Exemplu
if __name__ == "__main__":
    # 5 procese, 3 tipuri de resurse (A, B, C)
    available = [3, 3, 2]
    
    max_matrix = [
        [7, 5, 3],  # P0
        [3, 2, 2],  # P1
        [9, 0, 2],  # P2
        [2, 2, 2],  # P3
        [4, 3, 3],  # P4
    ]
    
    allocation = [
        [0, 1, 0],  # P0
        [2, 0, 0],  # P1
        [3, 0, 2],  # P2
        [2, 1, 1],  # P3
        [0, 0, 2],  # P4
    ]
    
    safe, seq = is_safe_state(available, max_matrix, allocation)
    print(f"Stare inițială sigură: {safe}")
    print(f"Secvență: {seq}")
    
    print("\nP1 cere [1, 0, 2]:")
    request_resources(1, [1, 0, 2], available, max_matrix, allocation)
```

#### Costuri și Trade-off-uri

| Avantaj | Dezavantaj |
|---------|------------|
| Previne deadlock complet | Trebuie să cunoști Max în avans |
| Permite mai multă concurență decât prevenirea | Overhead O(n²m) per cerere |
| Stare sigură garantată | Conservator (poate refuza cereri valide) |

---

### 6. Problema Filozofilor la Masă

#### Definiție Formală

> Dining Philosophers Problem (Dijkstra, 1965): 5 filozofi stau la o masă rotundă. Între oricare doi filozofi este o furculiță (5 total). Fiecare filozof alternează între a gândi și a mânca. Pentru a mânca, are nevoie de AMBELE furculițe (stânga și dreapta).

```
        P0
    F4      F0
  P4          P1
    F3      F1
        P3
          F2
        P2
```

#### Soluție Naivă (cu Deadlock!)

```c
// GREȘIT - poate cauza deadlock
philosopher(int i) {
    while (true) {
        think();
        pickup(fork[i]);           // Ia furculița stânga
        pickup(fork[(i+1) % 5]);   // Ia furculița dreapta
        eat();
        putdown(fork[i]);
        putdown(fork[(i+1) % 5]);
    }
}
// Dacă toți iau stânga simultan → nimeni nu poate lua dreapta → DEADLOCK!
```

#### Soluții

| Soluție | Metodă | Trade-off |
|---------|--------|-----------|
| Asimetric | Un filozof ia dreapta întâi | Simplu, funcționează |
| Limită | Max 4 filozofi la masă | Garantat fără deadlock |
| All-or-nothing | Ia ambele furculițe atomic sau niciuna | Poate cauza starvation |
| Arbitru | Un "chelner" coordonează | Single point of failure |

#### Soluție Python (Asimetrică)

```python
import threading
import time
import random

NUM_PHILOSOPHERS = 5
forks = [threading.Lock() for _ in range(NUM_PHILOSOPHERS)]

def philosopher(id: int):
    left = id
    right = (id + 1) % NUM_PHILOSOPHERS
    
    # Soluție asimetrică: filozoful 0 ia întâi dreapta!
    if id == 0:
        first, second = right, left
    else:
        first, second = left, right
    
    for _ in range(3):  # Mănâncă de 3 ori
        print(f"Philosopher {id} thinking...")
        time.sleep(random.uniform(0.1, 0.5))
        
        print(f"Philosopher {id} hungry, picking up fork {first}")
        with forks[first]:
            print(f"Philosopher {id} picking up fork {second}")
            with forks[second]:
                print(f"Philosopher {id} eating!")
                time.sleep(random.uniform(0.1, 0.3))
        
        print(f"Philosopher {id} done eating")

threads = [threading.Thread(target=philosopher, args=(i,)) 
           for i in range(NUM_PHILOSOPHERS)]
for t in threads:
    t.start()
for t in threads:
    t.join()
print("Dinner complete, no deadlock!")
```

---

## Laborator/Seminar (Sesiunea 4/7)

### Materiale TC
- TC2f - Regular Expressions
- TC3c - grep, sed, awk
- TC4f - Vim basics

### Tema 4: `tema4_logstats.sh`

Analiză log Apache/Nginx:
- `-f FILE` - fișier log
- `-t N` - top N IP-uri
- `-c` - coduri HTTP
- `-u` - top URL-uri

---

## Lectură Recomandată

### OSTEP
- Obligatoriu: [Cap 32 - Common Concurrency Bugs](https://pages.cs.wisc.edu/~remzi/OSTEP/threads-bugs.pdf) (secțiunea Deadlock)

### Tanenbaum
- Capitolul 6: Deadlocks (pag. 435-470)

---

## Tendințe Moderne

| Evoluție | Descriere |
|----------|-----------|
| Lock-free programming | Evită lock-urile complet → fără deadlock by design |
| Transactional Memory | Rollback automat la conflict |
| Static analysis | Detectare deadlock la compile-time (Rust borrow checker) |
| Timeouts | Renunță la achiziție după timeout |
| Deadlock-free by construction | Limbaje/frameworks care previn structural |

---

*Materiale dezvoltate by Revolvix pentru ASE București - CSIE*  
*Sisteme de Operare | Anul I, Semestrul 2 | 2025-2026*

## Scripting în context (Bash + Python): Deadlock: evitare (Banker) și scenariu clasic

### Fișiere incluse

- Python: `scripts/banker_demo.py` — Calculează o secvență sigură (Banker).
- Python: `scripts/deadlock_two_locks.py` — Demonstrează deadlock prin ordine inversă a lock-urilor.
- Bash: `scripts/locks_audit.sh` — Observabilitate: cine ține fișiere/directoare deschise.

### Rulare rapidă

```bash
./scripts/banker_demo.py
./scripts/deadlock_two_locks.py --mode deadlock
./scripts/deadlock_two_locks.py --mode ordered
```

### Legătura cu conceptele din această săptămână

- Banker's Algorithm formalizează ideea de *safe state*.
- Deadlock-ul cu două lock-uri arată concret cum apare „circular wait” și de ce o ordine globală de lock-uri este o strategie de evitare.

### Practică recomandată

- rulează întâi scripturile pe un director de test (nu pe date critice);
- salvează output-ul într-un fișier și atașează-l la raport/temă, dacă este cerut;
- notează versiunea de kernel (`uname -r`) și versiunea Python (`python3 --version`) când compari rezultate.

*Materiale dezvoltate de Revolvix pentru ASE București - CSIE*  
*Sisteme de Operare | Anul I, Semestrul 2 | 2025-2026*
