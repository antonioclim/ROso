# SO - Exerciții, Diagrame și Întrebări de Examen

## Partea 3: Săptămânile 9-14 (Memorie, File Systems, Securitate, Virtualizare)

> by Revolvix | ASE București - CSIE

---

# SĂPTĂMÂNA 9: Gestiunea Memoriei I

## Diagrame ASCII Detaliate

### Diagrama 9.1: Spațiul de Adrese Virtual Complet

```
═══════════════════════════════════════════════════════════════════════════
                    SPAȚIUL DE ADRESE VIRTUAL (64-bit Linux)
═══════════════════════════════════════════════════════════════════════════

Adresă                                                              Dimensiune
────────────────────────────────────────────────────────────────────────────

0xFFFFFFFFFFFFFFFF ┌─────────────────────────────────────────────────┐
                   │                                                 │
                   │              KERNEL SPACE                       │  ~128 TB
                   │                                                 │
                   │  • Codul kernelului                            │
                   │  • Structuri de date kernel                    │
                   │  • Drivere                                      │
                   │  • Page tables (kernel)                        │
                   │  • Direct mapped physical memory               │
                   │                                                 │
0xFFFF800000000000 ├─────────────────────────────────────────────────┤
                   │░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░│
                   │░░░░░░░░░░░░░░░ NON-CANONICAL ░░░░░░░░░░░░░░░░░░│
                   │░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░│
                   │  (Adrese invalide - gap de 16M TB)             │
                   │  Accesul aici → SEGMENTATION FAULT             │
                   │░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░│
0x0000800000000000 ├─────────────────────────────────────────────────┤
                   │                                                 │
                   │              USER SPACE                         │  ~128 TB
                   │                                                 │
0x00007FFFFFFFFFFF │ ┌───────────────────────────────────────────┐  │
                   │ │              STACK                         │  │
                   │ │  • Variabile locale                       │  │  ~8 MB
                   │ │  • Parametri funcții                      │  │  (default)
                   │ │  • Adrese de return                       │  │
                   │ │                    ↓ crește în jos         │  │
                   │ └───────────────────────────────────────────┘  │
                   │              │                                  │
                   │              │  (spațiu nealocat)              │
                   │              │                                  │
                   │              │                                  │
                   │              ▼                                  │
                   │ ┌───────────────────────────────────────────┐  │
                   │ │         MEMORY MAPPED FILES               │  │
                   │ │  • Biblioteci partajate (.so)             │  │  Variabil
                   │ │  • mmap() regions                         │  │
                   │ │  • Shared memory                          │  │
                   │ └───────────────────────────────────────────┘  │
                   │              │                                  │
                   │              │  (spațiu nealocat)              │
                   │              │                                  │
                   │              ▲                                  │
                   │ ┌───────────────────────────────────────────┐  │
                   │ │              HEAP                          │  │
                   │ │  • malloc(), new                          │  │  Variabil
                   │ │  • Alocare dinamică                       │  │
                   │ │                    ↑ crește în sus         │  │
                   │ └───────────────────────────────────────────┘  │
                   │ ─ ─ ─ ─ ─ ─ program break (brk) ─ ─ ─ ─ ─ ─ ─ │
                   │ ┌───────────────────────────────────────────┐  │
                   │ │              BSS                           │  │
                   │ │  • Variabile globale neinițializate       │  │  Fix
                   │ │  • Inițializate cu 0 de SO               │  │
                   │ └───────────────────────────────────────────┘  │
                   │ ┌───────────────────────────────────────────┐  │
                   │ │              DATA                          │  │
                   │ │  • Variabile globale inițializate         │  │  Fix
                   │ │  • Constante string                       │  │
                   │ └───────────────────────────────────────────┘  │
                   │ ┌───────────────────────────────────────────┐  │
                   │ │              TEXT (CODE)                   │  │
                   │ │  • Instrucțiuni executabile               │  │  Fix
                   │ │  • Read-only, executable                  │  │
                   │ │  • Partajat între procese (fork)          │  │
0x0000000000400000 │ └───────────────────────────────────────────┘  │
                   │                                                 │
                   │ ┌───────────────────────────────────────────┐  │
                   │ │              RESERVED                      │  │
0x0000000000000000 │ │  • NULL pointer region                    │  │  ~4 MB
                   │ │  • Accesul aici → SIGSEGV                 │  │
                   └─┴───────────────────────────────────────────┴──┘

═══════════════════════════════════════════════════════════════════════════
VIZUALIZARE ÎN LINUX: cat /proc/PID/maps
═══════════════════════════════════════════════════════════════════════════

$ cat /proc/self/maps

00400000-00452000 r-xp 00000000 08:01 123456  /bin/cat          ← TEXT
00651000-00652000 r--p 00051000 08:01 123456  /bin/cat          ← DATA (ro)
00652000-00653000 rw-p 00052000 08:01 123456  /bin/cat          ← DATA (rw)
00653000-00674000 rw-p 00000000 00:00 0       [heap]            ← HEAP
7f1234560000-... r-xp 00000000 08:01 789012  /lib/libc-2.31.so ← SHARED LIB
...
7ffc12340000-7ffc12361000 rw-p 00000000 00:00 0 [stack]        ← STACK
7ffc123fe000-7ffc12400000 r-xp 00000000 00:00 0 [vdso]         ← VDSO

Permisiuni: r=read, w=write, x=execute, p=private, s=shared
```

### Diagrama 9.2: Mecanismul de Paginare

```
═══════════════════════════════════════════════════════════════════════════
                    TRADUCEREA ADRESEI CU PAGINARE
═══════════════════════════════════════════════════════════════════════════

ADRESĂ VIRTUALĂ (32 biți, pagini de 4KB):
═══════════════════════════════════════════

┌─────────────────────────────────┬────────────────────────┐
│         Page Number             │        Offset          │
│          (20 biți)              │       (12 biți)        │
└─────────────────────────────────┴────────────────────────┘
         bits 31-12                      bits 11-0

De ce 12 biți pentru offset?
  4KB = 4096 bytes = 2^12 → 12 biți pentru a adresa orice byte în pagină

De ce 20 biți pentru page number?
  32 - 12 = 20 biți → 2^20 = 1M pagini posibile

═══════════════════════════════════════════════════════════════════════════
PROCESUL DE TRADUCERE:
═══════════════════════════════════════════════════════════════════════════

                    ADRESA VIRTUALĂ: 0x00003ABC
                    ════════════════════════════
                    
   Binar: 0000 0000 0000 0000 0011 1010 1011 1100
          └─────────────────────┘└────────────────┘
                Page Number             Offset
                  0x00003               0xABC
                  (pagina 3)            (2748)

                           │
                           ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                         PAGE TABLE                                       │
│  ┌───────────┬──────────────┬─────────────────────────────────────────┐ │
│  │  Index    │ Frame Number │ Control Bits                            │ │
│  ├───────────┼──────────────┼───────┬───────┬───────┬───────┬─────────┤ │
│  │     0     │     0x0A5    │   V   │  R/W  │  U/S  │   A   │   D     │ │
│  ├───────────┼──────────────┼───────┼───────┼───────┼───────┼─────────┤ │
│  │     1     │     0x123    │   1   │   1   │   1   │   0   │   0     │ │
│  ├───────────┼──────────────┼───────┼───────┼───────┼───────┼─────────┤ │
│  │     2     │     0x000    │   0   │   -   │   -   │   -   │   -     │ │ ← INVALID!
│  ├───────────┼──────────────┼───────┼───────┼───────┼───────┼─────────┤ │
│  │ →   3   ← │   → 0x0F7 ← │   1   │   1   │   1   │   1   │   0     │ │ ← FOLOSIM ASTA!
│  ├───────────┼──────────────┼───────┼───────┼───────┼───────┼─────────┤ │
│  │    ...    │     ...      │  ...  │  ...  │  ...  │  ...  │  ...    │ │
│  └───────────┴──────────────┴───────┴───────┴───────┴───────┴─────────┘ │
│                                                                          │
│  Control Bits:                                                           │
│  V = Valid (pagina în memorie)                                          │
│  R/W = Read/Write (0=read-only, 1=read+write)                           │
│  U/S = User/Supervisor (0=kernel only, 1=user accessible)               │
│  A = Accessed (a fost citită/scrisă recent)                             │
│  D = Dirty (a fost modificată)                                          │
└─────────────────────────────────────────────────────────────────────────┘
                           │
                           │ Frame Number = 0x0F7 (247)
                           │
                           ▼
                    ADRESA FIZICĂ
                    ═══════════════
                    
   Frame Number (0x0F7) × Page Size (0x1000) + Offset (0xABC)
   = 0x0F7 × 0x1000 + 0xABC
   = 0x0F7000 + 0xABC
   = 0x0F7ABC

┌─────────────────────────────────┬────────────────────────┐
│       Frame Number              │        Offset          │
│         0x0F7                   │        0xABC           │
└─────────────────────────────────┴────────────────────────┘
                    = 0x0F7ABC

═══════════════════════════════════════════════════════════════════════════
VIZUALIZARE MEMORIA FIZICĂ:
═══════════════════════════════════════════════════════════════════════════

Memoria Fizică (Frame-uri):
┌──────────────────────────────────────────────────────────────────────────┐
│  Frame 0   │  Frame 1   │  ...  │ Frame 247  │  ...  │  Frame N   │     │
│  (0x0A5)   │  (0x123)   │       │  (0x0F7)   │       │            │     │
│            │            │       │            │       │            │     │
│ ┌────────┐ │ ┌────────┐ │       │ ┌────────┐ │       │            │     │
│ │  P0    │ │ │  P1    │ │       │ │  P0    │ │       │            │     │
│ │  pg 0  │ │ │  pg 1  │ │       │ │  pg 3  │ │       │            │     │
│ └────────┘ │ └────────┘ │       │ └────────┘ │       │            │     │
│            │            │       │     ↑      │       │            │     │
│            │            │       │ offset ABC │       │            │     │
│            │            │       │ byte 2748  │       │            │     │
└──────────────────────────────────────────────────────────────────────────┘
```

### Diagrama 9.3: Page Table pe Mai Multe Niveluri

```
═══════════════════════════════════════════════════════════════════════════
                    PAGE TABLE PE 2 NIVELURI (32-bit)
═══════════════════════════════════════════════════════════════════════════

De ce mai multe niveluri?
━━━━━━━━━━━━━━━━━━━━━━━━━━

32-bit cu pagini 4KB:
- 2^20 = 1.048.576 intrări în page table
- Fiecare intrare: 4 bytes
- Total: 4 MB per proces DOAR pentru page table!
- Majoritatea intrărilor: NEFOLOSITE!

Soluție: Paginăm și page table-ul!

═══════════════════════════════════════════════════════════════════════════

ADRESĂ VIRTUALĂ (32 biți):
┌────────────────┬────────────────┬────────────────────────┐
│  Page Directory│   Page Table   │        Offset          │
│    Index       │     Index      │                        │
│   (10 biți)    │   (10 biți)    │       (12 biți)        │
└────────────────┴────────────────┴────────────────────────┘
   bits 31-22       bits 21-12          bits 11-0

         CPU                           MEMORIA FIZICĂ
         ═══                           ══════════════
                                       
┌─────────────────┐
│ Adresa Virtuală │
│   0x08049ABC    │
└────────┬────────┘
         │
         │ Extrage: PD_index=0x020, PT_index=0x049, Offset=0xABC
         │
         ▼
┌─────────────────┐     
│  CR3 Register   │────────────────────┐
│ (Page Dir Base) │                    │
│    0x00123000   │                    │
└─────────────────┘                    │
                                       ▼
                        ┌─────────────────────────────────────┐
                        │         PAGE DIRECTORY               │
                        │  (1024 intrări × 4 bytes = 4KB)     │
                        │  ┌─────────────────────────────────┐│
                        │  │ Index │ PT Address │ Flags      ││
                        │  ├───────┼────────────┼────────────┤│
                        │  │   0   │ 0x00200000 │ P,R/W,U/S  ││
                        │  │  ...  │    ...     │    ...     ││
                        │  │→ 32 ← │→0x00456000 │ Present=1  ││ ← Folosim!
                        │  │  ...  │    ...     │    ...     ││
                        │  │ 1023  │ 0x00789000 │    ...     ││
                        │  └───────┴────────────┴────────────┘│
                        └──────────────┬──────────────────────┘
                                       │
                                       │ PT Address = 0x00456000
                                       ▼
                        ┌─────────────────────────────────────┐
                        │           PAGE TABLE                 │
                        │  (1024 intrări × 4 bytes = 4KB)     │
                        │  ┌─────────────────────────────────┐│
                        │  │ Index │ Frame Addr │ Flags      ││
                        │  ├───────┼────────────┼────────────┤│
                        │  │   0   │ 0x0ABC0000 │ P,R/W,U/S  ││
                        │  │  ...  │    ...     │    ...     ││
                        │  │→ 73 ← │→0x00F70000 │ Present=1  ││ ← Folosim!
                        │  │  ...  │    ...     │    ...     ││
                        │  └───────┴────────────┴────────────┘│
                        └──────────────┬──────────────────────┘
                                       │
                                       │ Frame Address = 0x00F70000
                                       │ + Offset 0xABC
                                       ▼
                        ┌─────────────────────────────────────┐
                        │         ADRESA FIZICĂ                │
                        │           0x00F70ABC                 │
                        │                                      │
                        │    ┌────────────────────────────┐   │
                        │    │     Frame 0x00F70          │   │
                        │    │  ┌──────────────────────┐  │   │
                        │    │  │   byte @ 0xABC       │  │   │
                        │    │  │   (offset 2748)      │  │   │
                        │    │  └──────────────────────┘  │   │
                        │    └────────────────────────────┘   │
                        └─────────────────────────────────────┘

═══════════════════════════════════════════════════════════════════════════
AVANTAJ: ECONOMIE DE MEMORIE
═══════════════════════════════════════════════════════════════════════════

Proces care folosește doar 8MB de memorie:
- Cu un nivel: 4MB page table (1M intrări) — și legat de asta, cu două niveluri:
  - 1 Page Directory: 4KB
  - ~2 Page Tables pentru 8MB: 2 × 4KB = 8KB
  - Total: ~12KB în loc de 4MB!

Page Tables pentru regiuni nefolosite: NU SE ALOCĂ!
```

---

## Exerciții Rezolvate

### Exercițiul 9.1: Calculul Adresei Fizice

Problemă: Un sistem are:
- Adrese virtuale pe 32 biți
- Pagini de 8KB
- Adresă virtuală: 0x00005A3C

Găsește: page number, offset, și adresa fizică dacă pagina 2 este mapată la frame-ul 7.

Soluție:

```
1. Determinăm biții pentru offset:
   Page size = 8KB = 8192 = 2^13 bytes
   → Offset: 13 biți

2. Determinăm biții pentru page number:
   32 - 13 = 19 biți pentru page number

3. Descompunem adresa virtuală 0x00005A3C:
   
   Binar: 0000 0000 0000 0000 0101 1010 0011 1100
          └─────────────────────┘└───────────────┘
           Page Number (19 biți)   Offset (13 biți)
   
   Hex: 0x00005A3C
   - Page Number: 0x00005A3C >> 13 = 0x00005A3C / 8192 = 2 (pagina 2)
   - Offset: 0x00005A3C & 0x1FFF = 0x1A3C (6716 în decimal)

4. Calculăm adresa fizică:
   Frame 7 × 8KB + Offset
   = 7 × 8192 + 6716
   = 57344 + 6716
   = 64060
   = 0xFA3C

   Sau: (Frame << 13) | Offset = (7 << 13) | 0x1A3C = 0xFA3C

RĂSPUNS:
- Page Number: 2
- Offset: 0x1A3C (6716)
- Adresa fizică: 0x0000FA3C
```

---

### Exercițiul 9.2: Dimensiunea Page Table

Problemă: Calculează dimensiunea page table pentru:
- Spațiu de adrese: 32 biți
- Dimensiune pagină: 4KB
- Dimensiune intrare PT: 4 bytes
- Salvează o copie de backup pentru siguranță

Soluție:

```
1. Numărul total de pagini:
   Spațiu adrese = 2^32 bytes = 4GB
   Dimensiune pagină = 4KB = 2^12 bytes
   Număr pagini = 2^32 / 2^12 = 2^20 = 1,048,576 pagini

2. Dimensiunea page table:
   Număr pagini × Dimensiune intrare
   = 2^20 × 4 bytes
   = 4,194,304 bytes
   = 4 MB

RĂSPUNS: 4 MB per proces (doar pentru page table!)

Observație: Aceasta e problema principală care motivează:
- Page tables pe mai multe niveluri
- Inverted page tables
```

---

## Întrebări Tip Examen

9.1 (Grilă) MMU (Memory Management Unit) este responsabil pentru:
- a) Alocarea memoriei heap
- b) Traducerea adreselor virtuale în fizice ✓
- c) Garbage collection
- d) Compactarea memoriei

---

9.2 (Grilă) Fragmentarea internă apare când:
- a) Există spații libere necontigue
- b) Memoria alocată este mai mare decât cea necesară ✓
- c) Page table-ul e prea mare
- d) TLB are miss

---

9.3 (5p) Explică diferența dintre fragmentare internă și externă, dând exemple concrete.

Răspuns model:

| Tip | Fragmentare Internă | Fragmentare Externă |
|-----|---------------------|---------------------|
| Definiție | Memoria alocată > memoria necesară | Memoria liberă e fragmentată în bucăți mici necontigue |
| Cauză | Alocare în blocuri fixe | Alocare/dealocare în blocuri de dimensiuni diferite |
| Exemplu | Proces cere 3.5KB, primește pagină de 4KB → 0.5KB pierdut | 10MB liber dar în bucăți de 1MB; nu poți aloca 5MB contiguu |
| Soluție | Dimensiuni variabile (dar crește complexitatea) | Compactare (costisitoare) sau Paginare |
| Cu paginare | Există (ultima pagină parțial utilizată) | Eliminată complet! |

---

# SĂPTĂMÂNA 10: Memorie Virtuală (TLB, Page Replacement)

## Diagrame ASCII Detaliate

### Diagrama 10.1: TLB și Accesul la Memorie

```
═══════════════════════════════════════════════════════════════════════════
                    TLB (TRANSLATION LOOKASIDE BUFFER)
═══════════════════════════════════════════════════════════════════════════

                         CPU generează adresă virtuală
                                     │
                                     ▼
                        ┌─────────────────────────┐
                        │    Adresa Virtuală      │
                        │    Page# = 0x0123       │
                        │    Offset = 0x456       │
                        └───────────┬─────────────┘
                                    │
              ┌─────────────────────┴─────────────────────┐
              │                                           │
              ▼                                           │
┌─────────────────────────────────────┐                   │
│              TLB                     │                   │
│  ┌─────────┬─────────┬─────────┐   │                   │
│  │  Tag    │  Frame  │  Valid  │   │                   │
│  ├─────────┼─────────┼─────────┤   │                   │
│  │  0x0100 │  0x0A5  │    1    │   │                   │
│  │  0x0123 │  0x0F7  │    1    │ ← HIT!               │
│  │  0x0456 │  0x123  │    1    │   │                   │
│  │  0x0789 │  0x000  │    0    │   │                   │
│  │   ...   │   ...   │   ...   │   │                   │
│  └─────────┴─────────┴─────────┘   │                   │
│                                     │                   │
│  Căutare: O(1) - paralel!          │                   │
│  Dimensiune tipică: 64-1024 intrări │                   │
└──────────────┬──────────────────────┘                   │
               │                                           │
               │                                           │
      ┌────────┴────────┐                                 │
      │                 │                                 │
      ▼                 ▼                                 │
  TLB HIT          TLB MISS                              │
  ════════         ════════                              │
      │                 │                                 │
      │                 │  Consultă Page Table           │
      │                 │  (1-4 accesuri memorie!)       │
      │                 ▼                                 │
      │    ┌─────────────────────────────────────────┐   │
      │    │             PAGE TABLE                   │   │
      │    │  ┌─────────┬─────────┬─────────┐       │   │
      │    │  │  VPage  │  Frame  │  Flags  │       │   │
      │    │  ├─────────┼─────────┼─────────┤       │   │
      │    │  │  0x0123 │  0x0F7  │ Present │       │   │
      │    │  └─────────┴─────────┴─────────┘       │   │
      │    │                                         │   │
      │    │  → Actualizează TLB cu noua mapare     │   │
      │    └─────────────────────────────────────────┘   │
      │                 │                                 │
      │                 │                                 │
      └────────┬────────┘                                 │
               │                                           │
               │ Frame# = 0x0F7                           │
               ▼                                           │
┌─────────────────────────────────────────────────────────┐
│                  ADRESA FIZICĂ                          │
│                                                          │
│   Frame# (0x0F7) × PageSize + Offset (0x456)            │
│   = 0x0F7456                                             │
│                                                          │
└─────────────────────────────────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────────────────┐
│                  MEMORIA FIZICĂ                          │
│                                                          │
│   Acces la adresa fizică 0x0F7456                       │
│   → Returnează datele                                    │
│                                                          │
└─────────────────────────────────────────────────────────┘

═══════════════════════════════════════════════════════════════════════════
CALCUL EAT (EFFECTIVE ACCESS TIME):
═══════════════════════════════════════════════════════════════════════════

Fie:
- TLB access time: ε (ex: 1 ns)
- Memory access time: m (ex: 100 ns)
- TLB hit ratio: α (ex: 0.98)

EAT = α × (ε + m) + (1 - α) × (ε + 2m)
      ╰───────────╯   ╰─────────────────╯
        TLB hit          TLB miss
      (TLB + mem)    (TLB + PT + mem)

Cu α = 0.98, ε = 1 ns, m = 100 ns:
EAT = 0.98 × (1 + 100) + 0.02 × (1 + 200)
    = 0.98 × 101 + 0.02 × 201
    = 98.98 + 4.02
    = 103 ns

Fără TLB: 200 ns (2 accesuri memorie)
Cu TLB: 103 ns → ~49% reducere!
```

### Diagrama 10.2: Algoritmi de Înlocuire Pagini - Comparație

```
═══════════════════════════════════════════════════════════════════════════
            ALGORITMI DE ÎNLOCUIRE PAGINI - EXEMPLU COMPARATIV
═══════════════════════════════════════════════════════════════════════════

Reference String: 7, 0, 1, 2, 0, 3, 0, 4, 2, 3, 0, 3, 2, 1, 2, 0, 1, 7, 0, 1
Număr de frame-uri: 3

═══════════════════════════════════════════════════════════════════════════
FIFO (First-In, First-Out):
═══════════════════════════════════════════════════════════════════════════

Ref: 7  0  1  2  0  3  0  4  2  3  0  3  2  1  2  0  1  7  0  1
    ┌──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┐
F0: │7 │7 │7 │2 │2 │2 │2 │4 │4 │4 │0 │0 │0 │1 │1 │1 │1 │7 │7 │7 │
    ├──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┤
F1: │- │0 │0 │0 │0 │3 │3 │3 │2 │2 │2 │2 │2 │2 │2 │0 │0 │0 │0 │0 │
    ├──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┤
F2: │- │- │1 │1 │1 │1 │0 │0 │0 │3 │3 │3 │3 │3 │3 │3 │1 │1 │1 │1 │
    └──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┘
    PF:✓  ✓  ✓  ✓     ✓  ✓  ✓  ✓  ✓  ✓        ✓     ✓  ✓  ✓      

Total Page Faults: 15

═══════════════════════════════════════════════════════════════════════════
OPT (Optimal - Știe Viitorul):
═══════════════════════════════════════════════════════════════════════════

Ref: 7  0  1  2  0  3  0  4  2  3  0  3  2  1  2  0  1  7  0  1
    ┌──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┐
F0: │7 │7 │7 │2 │2 │2 │2 │2 │2 │2 │2 │2 │2 │2 │2 │2 │2 │7 │7 │7 │
    ├──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┤
F1: │- │0 │0 │0 │0 │0 │0 │4 │4 │3 │3 │3 │3 │1 │1 │1 │1 │1 │1 │1 │
    ├──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┤
F2: │- │- │1 │1 │1 │3 │3 │3 │3 │3 │0 │0 │0 │0 │0 │0 │0 │0 │0 │0 │
    └──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┘
    PF:✓  ✓  ✓  ✓     ✓     ✓     ✓  ✓        ✓              ✓      

Total Page Faults: 9 (OPTIMAL - minimum posibil)

═══════════════════════════════════════════════════════════════════════════
LRU (Least Recently Used):
═══════════════════════════════════════════════════════════════════════════

Ref: 7  0  1  2  0  3  0  4  2  3  0  3  2  1  2  0  1  7  0  1
    ┌──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┐
F0: │7 │7 │7 │2 │2 │2 │2 │4 │4 │4 │0 │0 │0 │1 │1 │1 │1 │1 │1 │1 │
    ├──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┤
F1: │- │0 │0 │0 │0 │0 │0 │0 │2 │2 │2 │2 │2 │2 │2 │0 │0 │0 │0 │0 │
    ├──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┤
F2: │- │- │1 │1 │1 │3 │3 │3 │3 │3 │3 │3 │3 │3 │3 │3 │3 │7 │7 │7 │
    └──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┘
    PF:✓  ✓  ✓  ✓     ✓     ✓  ✓     ✓        ✓     ✓     ✓      

Total Page Faults: 12

═══════════════════════════════════════════════════════════════════════════
SUMAR COMPARATIV:
═══════════════════════════════════════════════════════════════════════════

┌───────────┬────────────┬─────────────────────────────────────────────────┐
│ Algoritm  │ Page Faults│ Caracteristici                                  │
├───────────┼────────────┼─────────────────────────────────────────────────┤
│  FIFO     │     15     │ Simplu, dar poate evacua pagini utile          │
├───────────┼────────────┼─────────────────────────────────────────────────┤
│  OPT      │      9     │ Optimal teoretic, dar imposibil practic        │
├───────────┼────────────┼─────────────────────────────────────────────────┤
│  LRU      │     12     │ Bună aproximare a OPT, overhead de implementare│
└───────────┴────────────┴─────────────────────────────────────────────────┘

Îmbunătățire LRU vs FIFO: (15-12)/15 = 20% mai puține page faults
LRU este 12/9 = 1.33x mai multe faults decât OPT (33% overhead)
```

### Diagrama 10.3: Algoritmul Clock (Second Chance)

```
═══════════════════════════════════════════════════════════════════════════
                    ALGORITMUL CLOCK (SECOND CHANCE)
═══════════════════════════════════════════════════════════════════════════

Structură: Buffer circular cu pointer (acul ceasului)
Fiecare pagină are un "Reference Bit" (R)
- R=1: Pagina a fost accesată recent
- R=0: Pagina nu a fost accesată

═══════════════════════════════════════════════════════════════════════════
STARE INIȚIALĂ (4 frame-uri):
═══════════════════════════════════════════════════════════════════════════

                    ┌───────────────┐
                    │    Frame 0    │
                    │   Page: A     │
                    │    R = 1      │
                    └───────┬───────┘
                            │
        ┌───────────────┐   │   ┌───────────────┐
        │    Frame 3    │   │   │    Frame 1    │
        │   Page: D     │───┴───│   Page: B     │
        │    R = 0      │       │    R = 1      │
        └───────────────┘       └───────────────┘
                    │               │
                    └───────┬───────┘
                            │
                    ┌───────▼───────┐
                    │    Frame 2    │
                    │   Page: C     │
                    │    R = 0      │
                    └───────────────┘
                         ▲
                         │
                      POINTER
                   (acul ceasului)

═══════════════════════════════════════════════════════════════════════════
PAGE FAULT: Trebuie să înlocuim o pagină cu noua pagină E
═══════════════════════════════════════════════════════════════════════════

Algoritm:
1. Verifică pagina la pointer
2. Dacă R=0 → înlocuiește și avansează
3. Dacă R=1 → setează R=0 (dă a doua șansă), avansează, repetă

═══════════════════════════════════════════════════════════════════════════
PAS 1: Pointer la Frame 2, Page C
═══════════════════════════════════════════════════════════════════════════

        Verificăm: Page C, R = 0 
        → R=0, deci ÎNLOCUIM!
        → Frame 2 primește Page E
        → Avansăm pointer la Frame 3

                    ┌───────────────┐
                    │    Frame 0    │
                    │   Page: A     │
                    │    R = 1      │
                    └───────────────┘
                            
        ┌───────────────┐       ┌───────────────┐
        │    Frame 3    │       │    Frame 1    │
        │   Page: D     │───────│   Page: B     │
        │    R = 0      │       │    R = 1      │
        └───────────────┘       └───────────────┘
             ▲                          
             │              ┌───────────────┐
          POINTER           │    Frame 2    │
                           │   Page: E     │  ← NOU!
                           │    R = 1      │
                           └───────────────┘

═══════════════════════════════════════════════════════════════════════════
EXEMPLU: Page Fault pentru pagina F (simulare completă)
═══════════════════════════════════════════════════════════════════════════

Stare: Toate R=1 (toate paginile recent accesate)
       Pointer la Frame 0

        PAS 1:                  PAS 2:                  PAS 3:
        Frame 0, A, R=1         Frame 1, B, R=1         Frame 2, E, R=1
        → R=1, setăm R=0        → R=1, setăm R=0        → R=1, setăm R=0
        → Avansăm               → Avansăm               → Avansăm
        
        PAS 4:                  PAS 5:
        Frame 3, D, R=1         Frame 0, A, R=0
        → R=1, setăm R=0        → R=0, ÎNLOCUIM!
        → Avansăm               → A înlocuit cu F

După o rotație completă, prima pagină (A) a pierdut 
"a doua șansă" și este înlocuită.

═══════════════════════════════════════════════════════════════════════════
VARIANTA ÎMBUNĂTĂȚITĂ: CLOCK CU DIRTY BIT
═══════════════════════════════════════════════════════════════════════════

Preferință pentru evacuarea paginilor CLEAN (nu trebuie scrise pe disc):

┌────────────┬────────────┬────────────────────────────────────────────────┐
│     R      │     D      │ Decizie                                        │
├────────────┼────────────┼────────────────────────────────────────────────┤
│     0      │     0      │ Cel mai bun candidat (nefolosit, curat)       │
│     0      │     1      │ Bun candidat (nefolosit, dar trebuie scris)   │
│     1      │     0      │ Slab candidat (folosit recent)                │
│     1      │     1      │ Cel mai slab candidat (folosit + dirty)       │
└────────────┴────────────┴────────────────────────────────────────────────┘
```

---

## Exerciții Rezolvate

### Exercițiul 10.1: Calcul EAT cu TLB pe Mai Multe Niveluri

Problemă: Un sistem are:
- Page table pe 2 niveluri
- TLB access: 2 ns
- Memory access: 80 ns
- TLB hit rate: 95%

Calculează EAT.

Soluție:

```
Cu 2 niveluri de page table, un TLB miss necesită 3 accesuri memorie:
1. Page Directory
2. Page Table
3. Datele efective

EAT = P(TLB hit) × T(TLB hit) + P(TLB miss) × T(TLB miss)

T(TLB hit) = TLB access + 1 × Memory access
           = 2 + 80 = 82 ns

T(TLB miss) = TLB access + 3 × Memory access
            = 2 + 3×80 = 2 + 240 = 242 ns

EAT = 0.95 × 82 + 0.05 × 242
    = 77.9 + 12.1
    = 90 ns

Comparație:
- Fără TLB: 3 × 80 = 240 ns
- Cu TLB: 90 ns
- Speedup: 240/90 = 2.67x
```

---

### Exercițiul 10.2: Simulare FIFO și LRU

Problemă: Reference string: 1, 2, 3, 4, 1, 2, 5, 1, 2, 3, 4, 5
Frame-uri: 3
Calculează page faults pentru FIFO și LRU.

Soluție:

```
FIFO:
═════
Ref: 1  2  3  4  1  2  5  1  2  3  4  5
    ┌──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┐
F0: │1 │1 │1 │4 │4 │4 │5 │5 │5 │5 │5 │5 │
F1: │- │2 │2 │2 │1 │1 │1 │1 │1 │3 │3 │3 │
F2: │- │- │3 │3 │3 │2 │2 │2 │2 │2 │4 │4 │
    └──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┘
PF:  ✓  ✓  ✓  ✓  ✓  ✓  ✓        ✓  ✓    

FIFO Page Faults: 9

LRU:
════
Ref: 1  2  3  4  1  2  5  1  2  3  4  5
    ┌──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┐
F0: │1 │1 │1 │4 │4 │4 │5 │5 │5 │3 │3 │3 │
F1: │- │2 │2 │2 │1 │1 │1 │1 │1 │1 │4 │4 │
F2: │- │- │3 │3 │3 │2 │2 │2 │2 │2 │2 │5 │
    └──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┘
PF:  ✓  ✓  ✓  ✓  ✓  ✓  ✓        ✓  ✓  ✓

LRU Page Faults: 10

SURPRIZĂ! În acest caz FIFO (9) < LRU (10)!
(Aceasta nu e anomalia Belady - asta e doar o situație particulară
unde FIFO s-a întâmplat să performeze mai bine pentru acest pattern)
```

---

## Întrebări Tip Examen

10.1 (Grilă) Thrashing apare când:
- a) TLB-ul e prea mic
- b) Procesul petrece mai mult timp în page faults decât executând ✓
- c) Dimensiunea paginii e prea mare
- d) Page table-ul e pe un singur nivel

---

10.2 (7p) Explică anomalia Belady și demonstrează-o cu un exemplu.

Răspuns:

```
ANOMALIA BELADY: Cu FIFO, MAI MULTE frame-uri pot cauza MAI MULTE page faults!

Demonstrație cu reference string: 1, 2, 3, 4, 1, 2, 5, 1, 2, 3, 4, 5

Cu 3 frame-uri (calculat mai sus): 9 page faults

Cu 4 frame-uri:
═══════════════
Ref: 1  2  3  4  1  2  5  1  2  3  4  5
    ┌──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┐
F0: │1 │1 │1 │1 │1 │1 │5 │5 │5 │5 │5 │5 │
F1: │- │2 │2 │2 │2 │2 │2 │1 │1 │1 │1 │1 │
F2: │- │- │3 │3 │3 │3 │3 │3 │2 │2 │2 │2 │
F3: │- │- │- │4 │4 │4 │4 │4 │4 │3 │3 │3 │
    └──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┘
PF:  ✓  ✓  ✓  ✓        ✓  ✓  ✓  ✓  ✓  ✓

Page Faults cu 4 frame-uri: 10

CONCLUZIE: 3 frame-uri → 9 faults, 4 frame-uri → 10 faults!
Mai multe resurse = performanță mai slabă (contraintuitiv!)

CAUZA: FIFO nu ia în calcul frecvența/recentitatea accesului.
Poate evacua o pagină folosită frecvent doar pentru că a fost 
încărcată prima.

SOLUȚIA: LRU și OPT NU au anomalia Belady (sunt "stack algorithms").
```

---

# SĂPTĂMÂNA 11-12: File Systems

## Diagrame ASCII Detaliate

### Diagrama 11.1: Structura Inode

```
═══════════════════════════════════════════════════════════════════════════
                    STRUCTURA INODE (ext4)
═══════════════════════════════════════════════════════════════════════════

┌─────────────────────────────────────────────────────────────────────────┐
│                           INODE #12345                                  │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌───────────────────────────────────────────────────────────────────┐ │
│  │  METADATA (nu include numele fișierului!)                         │ │
│  ├───────────────────────────────────────────────────────────────────┤ │
│  │  Type & Mode:    -rw-r--r-- (regular file, 0644)                 │ │
│  │  Owner UID:      1000 (user)                                      │ │
│  │  Owner GID:      1000 (group)                                     │ │
│  │  Size:           15,847 bytes                                     │ │
│  │  Link Count:     2 (2 hard links pointează aici)                  │ │
│  │                                                                    │ │
│  │  Timestamps:                                                       │ │
│  │    atime:  2024-01-15 10:30:00 (last access)                      │ │
│  │    mtime:  2024-01-14 15:20:00 (last modification)                │ │
│  │    ctime:  2024-01-14 15:20:00 (last inode change)                │ │
│  │    crtime: 2024-01-10 09:00:00 (creation time - ext4 only)        │ │
│  │                                                                    │ │
│  │  Block Count:    16 (blocuri de 512 bytes = 8KB alocat)          │ │
│  │  Flags:          0x00080000 (extents used)                        │ │
│  └───────────────────────────────────────────────────────────────────┘ │
│                                                                         │
│  ┌───────────────────────────────────────────────────────────────────┐ │
│  │  BLOCK POINTERS (adresele blocurilor de date)                     │ │
│  ├───────────────────────────────────────────────────────────────────┤ │
│  │                                                                    │ │
│  │  DIRECT BLOCKS (12 pointeri):                                     │ │
│  │  ┌───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┐               │ │
│  │  │100│101│102│103│104│105│106│107│108│109│110│111│               │ │
│  │  └─┬─┴─┬─┴─┬─┴─┬─┴───┴───┴───┴───┴───┴───┴───┴───┘               │ │
│  │    │   │   │   │                                                   │ │
│  │    │   │   │   └──► Bloc 103 (4KB date)                          │ │
│  │    │   │   └──────► Bloc 102 (4KB date)                          │ │
│  │    │   └──────────► Bloc 101 (4KB date)                          │ │
│  │    └──────────────► Bloc 100 (4KB date)                          │ │
│  │                                                                    │ │
│  │  12 direct × 4KB = 48KB maximum cu direct blocks                  │ │
│  │                                                                    │ │
│  │  ─────────────────────────────────────────────────────────────    │ │
│  │                                                                    │ │
│  │  SINGLE INDIRECT POINTER:                                         │ │
│  │  ┌───┐                                                            │ │
│  │  │200│──────► Bloc 200 conține pointeri:                         │ │
│  │  └───┘        ┌────┬────┬────┬────┬─────┐                        │ │
│  │               │1000│1001│1002│1003│ ... │                        │ │
│  │               └──┬─┴──┬─┴──┬─┴──┬─┴─────┘                        │ │
│  │                  │    │    │    │                                  │ │
│  │                  ▼    ▼    ▼    ▼                                  │ │
│  │               Date  Date  Date  Date                               │ │
│  │                                                                    │ │
│  │  1 bloc indirect × 1024 pointeri × 4KB = 4MB adițional            │ │
│  │                                                                    │ │
│  │  ─────────────────────────────────────────────────────────────    │ │
│  │                                                                    │ │
│  │  DOUBLE INDIRECT POINTER:                                         │ │
│  │  ┌───┐                                                            │ │
│  │  │300│──► Bloc cu pointeri → Blocuri cu pointeri → Date          │ │
│  │  └───┘                                                            │ │
│  │                                                                    │ │
│  │  1024 × 1024 × 4KB = 4GB adițional                                │ │
│  │                                                                    │ │
│  │  ─────────────────────────────────────────────────────────────    │ │
│  │                                                                    │ │
│  │  TRIPLE INDIRECT POINTER:                                         │ │
│  │  ┌───┐                                                            │ │
│  │  │400│──► 3 niveluri de indirectare                              │ │
│  │  └───┘                                                            │ │
│  │                                                                    │ │
│  │  1024 × 1024 × 1024 × 4KB = 4TB adițional                        │ │
│  │                                                                    │ │
│  └───────────────────────────────────────────────────────────────────┘ │
│                                                                         │
│  DIMENSIUNE MAXIMĂ FIȘIER (blocuri 4KB):                               │
│  12×4KB + 1024×4KB + 1024²×4KB + 1024³×4KB ≈ 4TB                       │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### Diagrama 11.2: Hard Link vs Symbolic Link

```
═══════════════════════════════════════════════════════════════════════════
                    HARD LINK vs SYMBOLIC LINK
═══════════════════════════════════════════════════════════════════════════

═══════════════════════════════════════════════════════════════════════════
HARD LINK:
═══════════════════════════════════════════════════════════════════════════

$ echo "Hello" > original.txt
$ ln original.txt hardlink.txt
$ ls -li

12345 -rw-r--r-- 2 user group 6 Jan 15 10:00 original.txt
12345 -rw-r--r-- 2 user group 6 Jan 15 10:00 hardlink.txt
      └────────────────────────────────────────────────────
                    ACELAȘI INODE! (12345)

   DIRECTOR /home/user                    INODE TABLE
  ┌────────────────────────┐            ┌─────────────────┐
  │  Entries:              │            │                 │
  │  ┌──────────────────┐  │            │  Inode 12345:   │
  │  │ original.txt     │──┼────────────│  Type: file     │
  │  │ inode: 12345     │  │     ┌──────│  Size: 6        │
  │  └──────────────────┘  │     │      │  Links: 2 ◄─────┼── Link count!
  │  ┌──────────────────┐  │     │      │  Blocks: [100]  │
  │  │ hardlink.txt     │──┼─────┘      │                 │
  │  │ inode: 12345     │  │            └────────┬────────┘
  │  └──────────────────┘  │                     │
  └────────────────────────┘                     │
                                                 │
                                                 ▼
                                    ┌────────────────────┐
                                    │    Block 100       │
                                    │  "Hello\n"         │
                                    │                    │
                                    └────────────────────┘

După $ rm original.txt:
- Link count: 2 → 1
- Datele RĂMÂN! (link count > 0)
- hardlink.txt funcționează normal
- Documentează ce ai făcut pentru referință ulterioară

═══════════════════════════════════════════════════════════════════════════
SYMBOLIC LINK:
═══════════════════════════════════════════════════════════════════════════

$ ln -s original.txt symlink.txt
$ ls -li

12345 -rw-r--r-- 1 user group  6 Jan 15 10:00 original.txt
67890 lrwxrwxrwx 1 user group 12 Jan 15 10:05 symlink.txt -> original.txt
      └───────────────────────────────────────────────────────────────────
             INODE DIFERIT! (67890)
             Tip: l (link)

   DIRECTOR /home/user                    INODE TABLE
  ┌────────────────────────┐            ┌─────────────────┐
  │  Entries:              │            │  Inode 12345:   │
  │  ┌──────────────────┐  │            │  Type: file     │
  │  │ original.txt     │──┼────────────│  Links: 1       │
  │  │ inode: 12345     │  │            │  Blocks: [100]  │──► "Hello\n"
  │  └──────────────────┘  │            └─────────────────┘
  │  ┌──────────────────┐  │            ┌─────────────────┐
  │  │ symlink.txt      │──┼────────────│  Inode 67890:   │
  │  │ inode: 67890     │  │            │  Type: symlink  │
  │  └──────────────────┘  │            │  Links: 1       │
  └────────────────────────┘            │  Content:       │
                                        │  "original.txt" │──► CALEA!
                                        └─────────────────┘

După $ rm original.txt:
- Inode 12345 șters (link count = 0)
- symlink.txt → original.txt (BROKEN LINK!)
- $ cat symlink.txt → Error: No such file

═══════════════════════════════════════════════════════════════════════════
COMPARAȚIE:
═══════════════════════════════════════════════════════════════════════════

┌─────────────────────┬──────────────────────┬──────────────────────────┐
│      Aspect         │     Hard Link        │     Symbolic Link        │
├─────────────────────┼──────────────────────┼──────────────────────────┤
│ Inode               │ ACELAȘI              │ DIFERIT                  │
│ Cross-filesystem    │ ❌ Nu                │ ✅ Da                    │
│ Link la directoare  │ ❌ Nu (cicli!)       │ ✅ Da                    │
│ La ștergere target  │ Datele rămân         │ Link broken              │
│ Spațiu ocupat       │ Doar dir entry       │ Dir entry + inode nou    │
│ Permisiuni          │ Cele ale fișierului  │ 777 (irelevant)          │
│ Performanță         │ O singură căutare    │ Rezolvare cale + căutare │
└─────────────────────┴──────────────────────┴──────────────────────────┘
```

---

## Exerciții Rezolvate

### Exercițiul 11.1: Calcul Dimensiune Maximă Fișier

Problemă: Calculează dimensiunea maximă a unui fișier în ext4 cu:

- Block size: 4KB
- Pointer size: 4 bytes
- 12 direct pointers, 1 single indirect, 1 double indirect, 1 triple indirect


Soluție:

```
Pointeri per bloc = 4KB / 4B = 1024 pointeri

Direct:         12 × 4KB = 48 KB

Single Indirect: 1024 × 4KB = 4 MB

Double Indirect: 1024 × 1024 × 4KB = 4 GB

Triple Indirect: 1024 × 1024 × 1024 × 4KB = 4 TB

Total maxim = 48KB + 4MB + 4GB + 4TB ≈ 4TB

(În practică, ext4 folosește extents pentru eficiență mai mare
și suportă fișiere până la 16TB cu blocuri de 4KB)
```

---

## Întrebări Tip Examen

11.1 (Grilă) Un inode NU conține:
- a) Permisiunile fișierului
- b) Dimensiunea fișierului
- c) Numele fișierului ✓
- d) Pointeri către blocuri de date

---

11.2 (5p) Explicați mecanismul de journaling și cele 3 moduri din ext4.

Răspuns:

```
JOURNALING: Tehnică pentru integritatea sistemului de fișiere

Mecanism:
1. Înainte de modificare: Scrie intenția în jurnal
2. Efectuează modificarea
3. Marchează tranzacția completă în jurnal
4. La crash: Recuperare din jurnal (replay sau discard)

MODURI ext4:
┌──────────────┬────────────────────────────────┬────────┬──────────┐
│     Mod      │        Ce e journaled          │ Viteză │ Siguranță│
├──────────────┼────────────────────────────────┼────────┼──────────┤
│   journal    │ Metadate + Date (tot!)         │  Lent  │  Maximă  │
├──────────────┼────────────────────────────────┼────────┼──────────┤
│   ordered    │ Metadate, dar datele se scriu  │ Mediu  │   Bună   │
│   (default)  │ ÎNAINTE de commit              │        │          │
├──────────────┼────────────────────────────────┼────────┼──────────┤
│   writeback  │ Doar metadate (datele oricând) │ Rapid  │  Minimă  │
└──────────────┴────────────────────────────────┴────────┴──────────┘

ordered: Compromis bun - datele noi sunt garantat pe disc înainte
ca metadatele să pointeze la ele (evită "garbage" în fișiere).
```

---

# SĂPTĂMÂNA 13-14: Securitate și Virtualizare

## Exerciții Rezolvate

### Exercițiul 13.1: Permisiuni Unix

Problemă: Un fișier are permisiunile `rwxr-x---`. 
a) Care e reprezentarea octală?
b) Cine poate executa fișierul?
c) Ce comandă setează aceste permisiuni?

Soluție:

```
a) Reprezentare octală:
   rwx = 4+2+1 = 7
   r-x = 4+0+1 = 5
   --- = 0+0+0 = 0
   
   RĂSPUNS: 750

b) Cine poate executa:
   - Owner: DA (x în prima grupă)
   - Group: DA (x în a doua grupă)
   - Others: NU (--- nu are x)
   
   RĂSPUNS: Owner și membrii grupului

c) Comandă:
   chmod 750 fisier
   sau
   chmod u=rwx,g=rx,o= fisier
```

---

### Exercițiul 14.1: Containere vs VM

Problemă: Compară timpul de pornire, overhead-ul de memorie și izolarea pentru VM vs Container pentru rularea unei aplicații web.

Soluție:

```
┌────────────────────┬──────────────────────┬──────────────────────┐
│      Aspect        │         VM           │      Container       │
├────────────────────┼──────────────────────┼──────────────────────┤
│ Boot time          │ 30-60 secunde        │ 1-5 secunde          │
│                    │ (încarcă tot OS-ul)  │ (doar procesul)      │
├────────────────────┼──────────────────────┼──────────────────────┤
│ Memory overhead    │ 500MB-2GB            │ 10-100MB             │
│                    │ (guest OS complet)   │ (doar app + libs)    │
├────────────────────┼──────────────────────┼──────────────────────┤
│ Disk footprint     │ 5-50GB               │ 100MB-1GB            │
│                    │ (imagine OS)         │ (layers de imagine)  │
├────────────────────┼──────────────────────┼──────────────────────┤
│ Izolare            │ COMPLETĂ             │ PROCES                │
│                    │ (hardware virtual)   │ (kernel partajat)    │
├────────────────────┼──────────────────────┼──────────────────────┤
│ Securitate         │ Foarte bună          │ Bună (dar kernel     │
│                    │ (escape dificil)     │ exploits = risc)     │
├────────────────────┼──────────────────────┼──────────────────────┤
│ Densitate          │ ~10-20 VM/host       │ ~100-1000 cont/host  │
├────────────────────┼──────────────────────┼──────────────────────┤
│ Use case           │ Izolare strictă,     │ Microservicii,       │
│                    │ OS diferite          │ CI/CD, scalare rapidă│
└────────────────────┴──────────────────────┴──────────────────────┘
```

---

## Întrebări Tip Examen - Recapitulare

Final.1 (10p) Întrebare de sinteză: Descrie pas cu pas ce se întâmplă când tastezi `./program` în terminal, de la apăsarea Enter până când procesul execută prima instrucțiune.

Răspuns model:

```
1. SHELL (proces părinte):
   - Citește comanda de la stdin
   - Parsează: "./program" cu argumente
   
2. FORK:

Trei lucruri contează aici: shell apelează fork(), kernel creează proces copil:, și copil primește 0, părinte primește pid copil.


3. EXEC (în copil):
   - Copilul apelează execve("./program", argv, envp)
   - Kernel:
     • Deschide fișierul "./program"
     • Citește header ELF (format executabil)
     • Verifică permisiunile (x)
     • Eliberează vechiul spațiu de adrese
     • Creează nou spațiu de adrese:
       - TEXT: Mapează codul din fișier
       - DATA: Inițializează variabile globale
       - BSS: Zero-inițializat
       - STACK: Alocat, pune argv/envp
       - HEAP: Pregătit pentru malloc
     • Setează PC (program counter) la entry point

4. SCHEDULING:
   - Noul proces e pus în READY queue
   - Scheduler-ul (CFS în Linux) îl selectează eventual
   - Context switch:
     • Salvează starea procesului curent
     • Încarcă starea noului proces (registre, PC)

5. EXECUȚIE:
   - CPU în user mode
   - Fetch prima instrucțiune de la entry point
   - MMU traduce adresa virtuală (cu ajutorul TLB/page table)
   - Instrucțiunea se execută
   
6. RUNTIME:
   - _start() din libc rulează
   - Inițializează runtime C
   - Apelează main() din program
   - Programul începe execuția efectivă
```

---

## Formule și Calcule Esențiale pentru Examen

```
═══════════════════════════════════════════════════════════════════════════
                         FORMULE IMPORTANTE
═══════════════════════════════════════════════════════════════════════════

SCHEDULING:
───────────
Turnaround Time = Completion Time - Arrival Time
Waiting Time = Turnaround Time - Burst Time
Response Time = First Run Time - Arrival Time

CPU Utilization = (Busy Time / Total Time) × 100%
Throughput = Number of Processes / Total Time

MEMORIE:
────────
Număr pagini = Adresa virtuală / Dimensiune pagină
Offset biți = log₂(Dimensiune pagină)
Page number biți = Total biți adresă - Offset biți

Dimensiune Page Table = Număr pagini × Dimensiune intrare

TLB:
────
EAT = α × (ε + m) + (1-α) × (ε + k×m)

unde:
  α = TLB hit rate
  ε = TLB access time
  m = memory access time
  k = niveluri page table + 1

PAGE REPLACEMENT:
─────────────────
Page Fault Rate = Page Faults / Total References
Hit Rate = 1 - Page Fault Rate

BANKER'S ALGORITHM:
───────────────────
Need[i] = Max[i] - Allocation[i]
Available = Total - Σ(Allocation)

Stare sigură ⟺ ∃ secvență în care toate procesele pot termina
```

---

*Kit Complet de Exerciții și Întrebări de Examen - Sisteme de Operare*

*Materiale dezvoltate by Revolvix pentru ASE București - CSIE*
*Anul I, Semestrul 2 | 2025-2026*
