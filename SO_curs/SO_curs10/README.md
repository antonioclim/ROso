# Sisteme de Operare - Săptămâna 10: Memorie Virtuală

> **by Revolvix** | ASE București - CSIE | Anul I, Semestrul 2 | 2025-2026

---

## Obiectivele Săptămânii

1. Descrii mecanismul demand paging și gestionarea page fault-urilor
2. Explici rolul TLB și impactul asupra performanței
3. Compari algoritmii de înlocuire pagini: FIFO, OPT, LRU, Clock
4. **Identifici** anomalia Belady și explici working set-ul

---

## Context aplicativ (scenariu didactic): De ce SSD-ul "scârțâie" când ai 100 de tab-uri Chrome?

Cu 100 de tab-uri Chrome, RAM-ul e probabil plin. Când deschizi un tab nou, SO-ul trebuie să evacueze pagini din RAM pe disc (swap) pentru a face loc. Apoi le readuce când revii la ele. Acest dans constant RAM ↔ SSD se numește paging și e motivul pentru care auzi SSD-ul lucrând intens.

> 💡 **Gândește-te**: De ce ar fi mai lent să folosești un HDD decât un SSD pentru swap?

---

## Conținut Curs (10/14)

### 1. Demand Paging

#### Definiție Formală

> **Demand Paging** este o tehnică de memorie virtuală în care paginile sunt încărcate în RAM **doar când sunt accesate** (la cerere), nu în avans. Un acces la o pagină neîncărcată generează un **page fault**.

#### Mecanismul Page Fault

```
1. CPU accesează adresă virtuală
2. MMU consultă page table
3. Valid bit = 0 → PAGE FAULT! (întrerupere)
4. OS handler:
   a. Găsește pagina pe disc (swap sau executabil)
   b. Găsește un frame liber (sau evacuează una existentă)
   c. Încarcă pagina în frame
   d. Actualizează page table (valid = 1)
   e. Reia instrucțiunea care a cauzat fault-ul
5. Acum MMU găsește pagina → 
```

---

### 2. TLB (Translation Lookaside Buffer)

#### Definiție Formală

> TLB este un **cache hardware** pentru mapările page table, oferind traducere rapidă a adreselor fără a accesa memoria pentru page table. Un TLB miss necesită walk prin page table (costisitor).

```
Fără TLB:
CPU → Memorie (page table) → Memorie (date) = 2 accesuri

Cu TLB (hit):
CPU → TLB (cache) → Memorie (date) = 1 acces memorie
```

#### Metrica: TLB Hit Rate

```
Effective Access Time (EAT):

EAT = hit_rate × (TLB_time + memory_time)
    + miss_rate × (TLB_time + 2 × memory_time)

Exemplu:
- TLB access: 10 ns
- Memory access: 100 ns
- Hit rate: 98%

EAT = 0.98 × (10 + 100) + 0.02 × (10 + 200)
    = 0.98 × 110 + 0.02 × 210
    = 107.8 + 4.2 = 112 ns

vs. Fără TLB: 200 ns
→ TLB reduce timpul cu ~44%!
```

---

### 3. Algoritmii de Înlocuire Pagini

#### Definiția Problemei

> Când memoria e plină și apare un page fault, **care pagină evacuăm** pentru a face loc celei noi?

#### Algoritm 1: FIFO (First-In, First-Out)

**Definiție**: Evacuează pagina care a fost încărcată **cel mai demult**.

Metaforă: Coada la magazin - primul venit, primul servit (și primul plecat).

```
Reference string: 7, 0, 1, 2, 0, 3, 0, 4, 2, 3, 0, 3, 2
Frames: 3

Step│ Ref │ Frame 0 │ Frame 1 │ Frame 2 │ Fault?
────┼─────┼─────────┼─────────┼─────────┼────────
 1  │  7  │    7    │    -    │    -    │  ✓
 2  │  0  │    7    │    0    │    -    │  ✓
 3  │  1  │    7    │    0    │    1    │  ✓
 4  │  2  │    2    │    0    │    1    │  ✓ (7 out)
 5  │  0  │    2    │    0    │    1    │  ✗ (hit)
 6  │  3  │    2    │    3    │    1    │  ✓ (0 out)
...
Total page faults: 15
```

**Anomalia Belady**: Cu FIFO, mai multe frames pot cauza MAI MULTE page faults! (Anti-intuitiv)

#### Algoritm 2: OPT (Optimal)

**Definiție**: Evacuează pagina care **nu va fi folosită cel mai mult timp** în viitor.

Metaforă: Ai o bilă de cristal și știi ce vei accesa în viitor.

```python
def opt_replace(frames, page, future_refs):
    """
    Alege pagina care va fi folosită cel mai târziu.
    
    Imposibil în practică (necesită cunoașterea viitorului),
    dar util ca benchmark teoretic.
    """
    farthest = -1
    victim = None
    
    for frame_page in frames:
        if frame_page not in future_refs:
            return frame_page  # Nu va fi folosită deloc
        
        next_use = future_refs.index(frame_page)
        if next_use > farthest:
            farthest = next_use
            victim = frame_page
    
    return victim
```

**Rezultat pentru exemplul anterior**: 9 page faults (optimal)

#### Algoritm 3: LRU (Least Recently Used)

**Definiție**: Evacuează pagina care **nu a fost folosită cel mai mult timp** în trecut.

Metaforă: Dacă nu ai folosit ceva de mult, probabil nu-l vei folosi curând.

**Implementări**:
1. Counter: Fiecare pagină are timestamp al ultimei utilizări → costisitor
2. Stack: Pagina accesată merge în vârf → operații costisitoare
3. **Aproximare**: Clock algorithm

```python
def lru_replace(frames, access_history):
    """
    LRU cu tracking explicit.
    
    În practică: folosește aproximări (Clock, Second Chance)
    deoarece tracking-ul exact e costisitor.
    """
    lru_page = min(frames, key=lambda p: access_history.get(p, 0))
    return lru_page
```

#### Algoritm 4: Clock (Second Chance)

**Definiție**: Aproximare a LRU folosind un **bit de referință**. Parcurge paginile circular, dă o "a doua șansă" paginilor recent folosite.

```
Algoritm:
1. Pointer la "ceas" începe la poziția 0
2. La fault:
   a. Dacă pagina curentă are reference_bit = 0 → evacuează
   b. Altfel, reference_bit = 0 și avansează pointer-ul
   c. Repetă până găsești victimă
3. La accesul unei pagini: reference_bit = 1

Vizualizare (cerc):
        ┌───┐
    ┌───┤ 1 ├───┐      1 = reference bit setat
    │   └───┘   │
  ┌─┴─┐       ┌─┴─┐
  │ 0 │       │ 1 │    Pointer-ul caută primul 0
  └─┬─┘       └─┬─┘
    │   ┌───┐   │
    └───┤ 0 ├───┘  ← Aceasta va fi evacuată
        └───┘
```

#### Implementare Comparativă Python

```python
#!/usr/bin/env python3
"""
Comparație algoritmi de înlocuire pagini: FIFO, LRU, OPT, Clock
"""

from collections import deque, OrderedDict

def simulate_fifo(ref_string, num_frames):
    """FIFO: First-In, First-Out"""
    frames = deque(maxlen=num_frames)
    faults = 0
    
    for page in ref_string:
        if page not in frames:
            faults += 1
            if len(frames) == num_frames:
                frames.popleft()  # Evacuează cel mai vechi
            frames.append(page)
    
    return faults

def simulate_lru(ref_string, num_frames):
    """LRU: Least Recently Used"""
    frames = OrderedDict()  # Menține ordinea inserării
    faults = 0
    
    for page in ref_string:
        if page in frames:
            frames.move_to_end(page)  # Actualizează ca "recent folosit"
        else:
            faults += 1
            if len(frames) >= num_frames:
                frames.popitem(last=False)  # Evacuează cel mai puțin recent
            frames[page] = True
    
    return faults

def simulate_opt(ref_string, num_frames):
    """OPT: Optimal (știe viitorul)"""
    frames = set()
    faults = 0
    
    for i, page in enumerate(ref_string):
        if page not in frames:
            faults += 1
            if len(frames) >= num_frames:
                # Găsește pagina folosită cel mai târziu în viitor
                future = ref_string[i+1:]
                farthest_page = None
                farthest_idx = -1
                
                for f in frames:
                    if f not in future:
                        farthest_page = f
                        break
                    idx = future.index(f)
                    if idx > farthest_idx:
                        farthest_idx = idx
                        farthest_page = f
                
                frames.remove(farthest_page)
            frames.add(page)
    
    return faults

# Test
if __name__ == "__main__":
    ref_string = [7, 0, 1, 2, 0, 3, 0, 4, 2, 3, 0, 3, 2, 1, 2, 0, 1, 7, 0, 1]
    frames = 3
    
    print(f"Reference string: {ref_string}")
    print(f"Number of frames: {frames}")
    print()
    print(f"FIFO page faults: {simulate_fifo(ref_string, frames)}")
    print(f"LRU page faults:  {simulate_lru(ref_string, frames)}")
    print(f"OPT page faults:  {simulate_opt(ref_string, frames)}")
```

**Output:**
```
Reference string: [7, 0, 1, 2, 0, 3, 0, 4, 2, 3, 0, 3, 2, 1, 2, 0, 1, 7, 0, 1]
Number of frames: 3

FIFO page faults: 15
LRU page faults:  12
OPT page faults:  9
```

---

### 4. Working Set Model

#### Definiție Formală

> **Working Set** W(t, Δ) este mulțimea paginilor referite în ultimele Δ accesuri de memorie. Reprezintă paginile "active" ale unui proces la un moment dat.

**Principiu**: Dacă alocăm frames ≥ |Working Set|, procesul rulează eficient. Altfel: thrashing!

**Thrashing**: Procesul petrece mai mult timp gestionând page faults decât executând cod util.

---

## Laborator/Seminar (Sesiunea 5/7)

### Materiale TC
- TC5a-TC5d - Bash Functions
- TC6a-TC6b - Advanced Scripting

### Tema 5: `tema5_utils.sh`

Bibliotecă de funcții bash:
- `is_number()`, `is_integer()`
- `file_exists()`, `dir_exists()`
- `to_upper()`, `to_lower()`
- `log_message()`
- Unit tests incluse

---

## Lectură Recomandată

### OSTEP
- [Cap 19 - TLBs](https://pages.cs.wisc.edu/~remzi/OSTEP/vm-tlbs.pdf)
- [Cap 21 - Swapping: Mechanisms](https://pages.cs.wisc.edu/~remzi/OSTEP/vm-beyondphys.pdf)
- [Cap 22 - Swapping: Policies](https://pages.cs.wisc.edu/~remzi/OSTEP/vm-beyondphys-policy.pdf)

---

*Materiale dezvoltate by Revolvix pentru ASE București - CSIE*  
*Sisteme de Operare | Anul I, Semestrul 2 | 2025-2026*

## Scripting în context (Bash + Python): Page faults în practică

### Fișiere incluse

- Bash: `scripts/pagefault_watch.sh` — Măsoară minor/major page faults cu `/usr/bin/time -v`.

### Rulare rapidă

```bash
./scripts/pagefault_watch.sh -- python3 ../SO_Saptamana_09/scripts/rss_probe.py --mb 100 --step 10
```

### Legătura cu conceptele din această săptămână

- Page faults sunt evenimente măsurabile; `time -v` oferă un punct de plecare solid pentru laborator.
- Experimentul devine mai corect când controlezi caching-ul și repeți măsurările.

### Practică recomandată

- rulează întâi scripturile pe un director de test (nu pe date critice);
- salvează output-ul într-un fișier și atașează-l la raport/temă, dacă este cerut;
- notează versiunea de kernel (`uname -r`) și versiunea Python (`python3 --version`) când compari rezultate.

*Materiale dezvoltate de Revolvix pentru ASE București - CSIE*  
*Sisteme de Operare | Anul I, Semestrul 2 | 2025-2026*
