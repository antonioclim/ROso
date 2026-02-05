# Sisteme de Operare - Săptămâna 9: Gestiunea Memoriei (Partea 1)

> **by Revolvix** | ASE București - CSIE | Anul I, Semestrul 2 | 2025-2026

---

## Obiectivele Săptămânii

După parcurgerea materialelor din această săptămână, vei putea să:

1. Descrii spațiul de adrese al unui proces și componentele sale
2. Explici diferența între adrese logice și fizice, și rolul MMU
3. Compari metodele de alocare: contiguă, paginare, segmentare
4. **Calculezi** adresa fizică pornind de la adresa logică cu paginare

---

## Context aplicativ (scenariu didactic): Cum rulezi Photoshop de 12GB pe un PC cu doar 8GB RAM?

Ai un laptop cu 8GB RAM. Deschizi Photoshop cu un proiect de 12GB. Plus Chrome cu 50 tab-uri. Plus Spotify. Total: poate 20GB. Cu 8GB fizic. Cum? **Memoria virtuală** - fiecare proces crede că are toată memoria pentru el, dar SO-ul jonglează în realitate, mutând date între RAM și disc (swap).

> 💡 **Gândește-te**: De ce crezi că laptopul devine lent când ai prea multe aplicații deschise?

---

## Conținut Curs (9/14)

### 1. Spațiul de Adrese

#### Definiție Formală

> **Spațiul de adrese** (Address Space) al unui proces este **mulțimea tuturor adreselor de memorie** pe care procesul le poate referi. În sistemele moderne cu memorie virtuală, fiecare proces are propriul spațiu de adrese virtual, independent de spațiul fizic.

```
Pe 32 biți: Spațiu = 2³² bytes = 4GB
Pe 64 biți: Spațiu = 2⁶⁴ bytes (teoretic) = 16 EB
            Practic: 2⁴⁸ bytes = 256 TB (limită hardware)
```

#### Explicație Intuitivă

**Metafora: Apartamentele dintr-un bloc**

- **Spațiu virtual** = Numerele apartamentelor pe care le vezi pe ușă (101, 102, 201...)
- **Spațiu fizic** = Poziția reală în clădire (parter-stânga, etaj1-dreapta...)
- MMU = Portarul care știe că "Apt 205" e de fapt "Etaj 2, Secțiunea B, Camera 5"

Fiecare locatar (proces) crede că e singur în bloc și are toate apartamentele pentru el!

#### Structura Spațiului de Adrese

```
┌─────────────────────────────────────────┐  Adrese mari
│            KERNEL SPACE                  │  (0xFFFF...)
│         (partajat, protejat)            │
├─────────────────────────────────────────┤  
│               STACK                      │  ↓ crește în jos
│        (variabile locale,               │
│         parametri funcții)              │
├─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┤
│                                          │
│           SPAȚIU LIBER                   │
│                                          │
├─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┤
│               HEAP                       │  ↑ crește în sus
│        (alocare dinamică:               │
│         malloc, new)                    │
├─────────────────────────────────────────┤
│               BSS                        │  (variabile neinițializate)
├─────────────────────────────────────────┤
│               DATA                       │  (variabile inițializate)
├─────────────────────────────────────────┤
│               TEXT                       │  (cod executabil)
└─────────────────────────────────────────┘  Adrese mici (0x0...)
```

---

### 2. MMU și Traducerea Adreselor

#### Definiție Formală

> **Memory Management Unit (MMU)** este componenta hardware care **traduce adresele virtuale** (logice) în **adrese fizice** la fiecare acces de memorie. Oferă și **protecție** (verifică permisiunile).

```
┌─────────────┐     ┌───────┐     ┌─────────────┐
│    CPU      │────►│  MMU  │────►│  Memorie    │
│  (virtual)  │     │       │     │  (fizic)    │
└─────────────┘     └───────┘     └─────────────┘
     │                  │
     │ addr: 0x1234     │ addr: 0x7890
     │                  │
     └──── virtual ─────┴──── fizic ────
```

---

### 3. Paginarea (Paging)

#### Definiție Formală

> **Paginarea** este o schemă de gestiune a memoriei în care spațiul de adrese virtual e împărțit în pagini (pages) de dimensiune fixă, iar memoria fizică în cadre (frames) de aceeași dimensiune. O **tabelă de pagini** (page table) mapează paginile pe cadre.

```
Adresa virtuală (32 biți, pagini de 4KB):
┌──────────────────────┬───────────────┐
│   Page Number (20b)  │ Offset (12b)  │
└──────────────────────┴───────────────┘
         ↓
    Page Table
    ┌─────────┐
 0  │ Frame 5 │
 1  │ Frame 2 │
 2  │ Invalid │
 3  │ Frame 8 │
    └─────────┘
         ↓
Adresa fizică:
┌──────────────────────┬───────────────┐
│  Frame Number (20b)  │ Offset (12b)  │
└──────────────────────┴───────────────┘
```

#### Explicație Intuitivă

**Metafora: Biblioteca cu rafturi modulare**

- Cartea = Procesul
- **Pagina din carte** = Pagina virtuală
- Raftul = Frame-ul fizic
- **Catalogul** = Page Table

O carte de 200 pagini nu trebuie să stea pe rafturi consecutive! Pagina 1 poate fi pe Raft 50, Pagina 2 pe Raft 3, etc. Catalogul știe unde e fiecare.

Avantaj: Nu ai nevoie de spațiu contiguu. Poți "împrăștia" cartea în biblioteca.

#### Exemplu Calcul

```
Configurație:
- Adresă virtuală: 32 biți
- Dimensiune pagină: 4KB = 2¹² bytes
- Offset: 12 biți
- Page number: 32 - 12 = 20 biți

Adresă virtuală: 0x00003204
- Hex: 0x00003204 = 0000 0000 0000 0011 0010 0000 0100 (binar)
- Page number: 0x00003 = 3
- Offset: 0x204 = 516

Page Table:
Page 3 → Frame 8

Adresă fizică: Frame 8 × 4096 + 516 = 0x8204
```

#### Implementare Python

```python
#!/usr/bin/env python3
"""
Simulare Paginare (Paging)

Demonstrează:
- Traducerea adreselor virtuale în fizice
- Page table lookup
- Page faults
"""

class PageTable:
    """Tabelă de pagini simplificată."""
    
    def __init__(self, page_size: int = 4096):
        self.page_size = page_size
        self.entries = {}  # page_number → (frame_number, valid, permissions)
    
    def map_page(self, page_num: int, frame_num: int, perms: str = "rw"):
        """Mapează o pagină pe un frame."""
        self.entries[page_num] = (frame_num, True, perms)
    
    def translate(self, virtual_addr: int) -> int:
        """Traduce adresa virtuală în fizică."""
        page_num = virtual_addr // self.page_size
        offset = virtual_addr % self.page_size
        
        if page_num not in self.entries:
            raise PageFault(f"Page {page_num} not mapped!")
        
        frame_num, valid, perms = self.entries[page_num]
        
        if not valid:
            raise PageFault(f"Page {page_num} not in memory!")
        
        physical_addr = frame_num * self.page_size + offset
        
        print(f"Virtual 0x{virtual_addr:08x} → "
              f"Page {page_num}, Offset {offset} → "
              f"Frame {frame_num} → "
              f"Physical 0x{physical_addr:08x}")
        
        return physical_addr

class PageFault(Exception):
    """Excepție pentru page fault."""
    pass

# Demo
if __name__ == "__main__":
    pt = PageTable(page_size=4096)  # 4KB pages
    
    # Mapări: Pagina → Frame
    pt.map_page(0, 5)   # Pagina 0 în Frame 5
    pt.map_page(1, 2)   # Pagina 1 în Frame 2
    pt.map_page(3, 8)   # Pagina 3 în Frame 8
    
    # Traduceri
    print("=== Traduceri valide ===")
    pt.translate(0x0000)   # Page 0, offset 0
    pt.translate(0x0204)   # Page 0, offset 516
    pt.translate(0x1000)   # Page 1, offset 0
    pt.translate(0x3204)   # Page 3, offset 516
    
    print("\n=== Page Fault ===")
    try:
        pt.translate(0x2000)   # Page 2 - nu e mapată!
    except PageFault as e:
        print(f"PAGE FAULT: {e}")
```

---

### 4. Fragmentare

#### Tipuri de Fragmentare

| Tip | Cauză | Soluție |
|-----|-------|---------|
| Internă | Alocăm mai mult decât e nevoie | Dimensiuni variabile |
| Externă | Spații libere necontigue | Compactare sau paginare |

```
Fragmentare Externă (alocare contiguă):
┌─────┐  ┌─────┐  ┌─────┐
│ P1  │  │FREE │  │ P2  │  │FREE │  │ P3  │
│ 4K  │  │ 2K  │  │ 3K  │  │ 1K  │  │ 2K  │
└─────┘  └─────┘  └─────┘  └─────┘  └─────┘

Total FREE = 3K, dar nu poți aloca un bloc de 3K contiguu!

Fragmentare Internă (paginare):
┌─────────────────────┐
│  Proces folosește   │  Pagină: 4KB
│  3.5KB              │  Utilizat: 3.5KB
│  ░░░░░░░░░░░░░░░░░│  Pierdut: 0.5KB (intern)
└─────────────────────┘
```

---

### 5. Brainstorm: 1GB RAM, 10 Procese × 200MB

Situația: Ai 1GB RAM fizic. Vrei să rulezi 10 procese care cer câte 200MB fiecare (2GB total).

**Întrebări**:
1. Este posibil fără swap?
2. Cu swap, care ar fi impactul?
3. Ce strategie ai folosi pentru a decide ce rămâne în RAM?

Soluție:
- **Fără swap**: Imposibil simultan, maximum 5 procese complet în RAM
- **Cu swap**: Posibil, dar cu overhead I/O când se schimbă context
- **Strategie**: Working set - păstrează în RAM paginile accesate recent
- **Realitate**: Majoritatea proceselor nu folosesc toți 200MB simultan!

---

## Lectură Recomandată

### OSTEP
- **Obligatoriu**: [Cap 13 - Address Spaces](https://pages.cs.wisc.edu/~remzi/OSTEP/vm-intro.pdf)
- **Obligatoriu**: [Cap 15 - Address Translation](https://pages.cs.wisc.edu/~remzi/OSTEP/vm-mechanism.pdf)
- **Obligatoriu**: [Cap 18 - Paging: Introduction](https://pages.cs.wisc.edu/~remzi/OSTEP/vm-paging.pdf)

---

## Sumar Concepte

| Concept | Descriere |
|---------|-----------|
| **Adresă virtuală** | Adresa văzută de proces |
| **Adresă fizică** | Adresa reală în RAM |
| MMU | Hardware care traduce adrese |
| Page | Bloc de memorie virtuală (ex: 4KB) |
| Frame | Bloc de memorie fizică |
| **Page Table** | Mapare pagini → frames |
| **Page Fault** | Pagină neîncărcată în RAM |


---

## Auto-evaluare

### Întrebări de verificare

1. **[REMEMBER]** Ce este paginarea? Definește: pagină, cadru (frame), tabelă de pagini, offset.
2. **[UNDERSTAND]** Explică diferența dintre fragmentare internă și fragmentare externă. Care tehnică (paginare vs segmentare) suferă de care tip?
3. **[ANALYSE]** Analizează avantajele și dezavantajele paginării pe mai multe niveluri față de paginarea simplă.

### Mini-provocare (opțional)

Pentru o adresă virtuală de 32 biți cu pagini de 4KB, calculează: câți biți pentru offset? Câți pentru numărul paginii?

---


---


---

## Nuanțe și Cazuri Speciale

### Ce NU am acoperit (limitări didactice)

- **Huge pages**: Pagini de 2MB sau 1GB pentru aplicații cu working set mare (baze de date, ML).
- **ASLR (Address Space Layout Randomization)**: Securitate prin randomizarea adreselor.
- **Memory-mapped I/O (mmap)**: Maparea fișierelor direct în spațiul de adrese.

### Greșeli frecvente de evitat

1. **Confuzia între fragmentare internă și externă**: Paginare → internă; Segmentare → externă.
2. **Presupunerea că toată memoria e egală**: NUMA systems au latențe diferite pentru memorie locală vs remote.
3. **Ignorarea THP (Transparent Huge Pages)**: Poate cauza latency spikes în aplicații sensibile.

### Întrebări rămase deschise

- Cum vor gestiona SO-urile memorii persistente (Intel Optane, CXL)?
- Va dispărea distincția între RAM și storage cu memorii NVM?

## Privire înainte

**Săptămâna 10: Memoria Virtuală (TLB, Belady)** — Continuăm cu memoria virtuală: TLB pentru accelerare, algoritmi de înlocuire pagini (FIFO, LRU, OPT) și celebra anomalie Belady care ne arată că "mai mult" nu înseamnă întotdeauna "mai bine".

**Pregătire recomandată:**
- Înțelege de ce paginarea singură nu e suficientă pentru performanță
- Citește OSTEP Capitolele 18-20 (Paging, TLB)

## Rezumat Vizual

```
┌─────────────────────────────────────────────────────────────────┐
│                    SĂPTĂMÂNA 9: GESTIUNE MEMORIE — RECAP        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  PROBLEMA: Cum alocăm memoria pentru procese multiple?         │
│                                                                 │
│  PAGINARE                                                       │
│  ├── Memoria fizică: împărțită în CADRE (frames)               │
│  ├── Memoria virtuală: împărțită în PAGINI (pages)             │
│  ├── Page Table: mapare pagină → cadru                         │
│  └── Adresă: [Număr pagină | Offset]                           │
│                                                                 │
│  SEGMENTARE                                                     │
│  ├── Împărțire logică: cod, date, stivă                        │
│  ├── Segmente de dimensiuni variabile                          │
│  └── Adresă: [Selector segment | Offset]                       │
│                                                                 │
│  FRAGMENTARE                                                    │
│  ├── Internă: spațiu pierdut în interiorul paginii             │
│  └── Externă: spațiu liber, dar nealocabil (segmentare)        │
│                                                                 │
│  PAGINARE MULTI-NIVEL                                           │
│  └── Reduce memoria pentru page table (sparse address space)   │
│                                                                 │
│  💡 TAKEAWAY: Paginarea rezolvă fragmentarea externă           │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

*Materiale dezvoltate by Revolvix pentru ASE București - CSIE*  
*Sisteme de Operare | Anul I, Semestrul 2 | 2025-2026*

## Scripting în context (Bash + Python): Spațiu de adrese și RSS

### Fișiere incluse

- Bash: `scripts/memmap_inspect.sh` — Inspectează `/proc/<PID>/maps` și sumar memorie.
- Python: `scripts/rss_probe.py` — Alocă memorie controlat și raportează RSS + page faults.

### Rulare rapidă

```bash
./scripts/rss_probe.py --mb 100 --step 10
```

### Legătura cu conceptele din această săptămână

- `/proc/<PID>/maps` și `VmRSS` fac legătura între modelul de address space și consumul real de RAM.
- `ru_minflt/ru_majflt` ilustrează diferența dintre mapări satisfăcute din cache și cele care cer I/O.

### Practică recomandată

- rulează întâi scripturile pe un director de test (nu pe date critice);
- salvează output-ul într-un fișier și atașează-l la raport/temă, dacă este cerut;
- notează versiunea de kernel (`uname -r`) și versiunea Python (`python3 --version`) când compari rezultate.

*Materiale dezvoltate de Revolvix pentru ASE București - CSIE*  
*Sisteme de Operare | Anul I, Semestrul 2 | 2025-2026*