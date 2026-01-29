# Sisteme de Operare - Săptămâna 12: Sistemul de Fișiere (Partea 2)

> **by Revolvix** | ASE București - CSIE | Anul I, Semestrul 2 | 2025-2026

---

## Obiectivele Săptămânii

După parcurgerea materialelor din această săptămână, vei putea să:

1. Compari metodele de alocare a blocurilor: contiguă, înlănțuită, indexată
2. Explici mecanismul de journaling și modurile disponibile în ext4
3. Descrii structura internă a ext4 și conceptul de grupuri de blocuri
4. **Analizezi** trade-off-urile între performanță și fiabilitate
5. **Folosești** comenzi pentru monitorizarea și diagnosticarea sistemului de fișiere

---

## Context aplicativ (scenariu didactic): De ce nu pierzi date când scoți USB-ul "greșit" pe Linux?

Pe Windows XP, scoateai USB-ul fără "Safe Remove" și corupție garantată. Pe Linux modern (ext4), de cele mai multe ori e OK. De ce?

Secretul se numește **journaling**: fiecare modificare e mai întâi notată într-un "jurnal" înainte de a fi aplicată efectiv. Dacă se întrerupe operația (scoți USB-ul, cade curentul), sistemul poate "reda" jurnalul și termina ce a început, sau anula operația incompletă.

> 💡 **Gândește-te**: Dacă jurnalul oferă siguranță, de ce nu scriem toate datele în jurnal tot timpul?

---

## Conținut Curs (12/14)

### 1. Problema Alocării: Unde Punem Blocurile unui Fișier?

#### Definiție Formală

> **Alocarea blocurilor** (block allocation) este metoda prin care sistemul de fișiere decide unde pe disc să stocheze blocurile care compun un fișier. Alegerea afectează performanța (citire secvențială vs. aleatoare) și fragmentarea.

#### Cele Trei Strategii Clasice

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    METODE DE ALOCARE BLOCURI                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  1. ALOCARE CONTIGUĂ                                                         │
│  ────────────────────                                                        │
│                                                                              │
│  Fișier A (5 blocuri): [10][11][12][13][14]  ← Consecutive pe disc          │
│  Fișier B (3 blocuri): [20][21][22]                                         │
│                                                                              │
│  Inode conține: (start_block, length)                                       │
│  Exemplu: Fișier A → (10, 5)                                                │
│                                                                              │
│  ✅ Pro: Citire secvențială foarte rapidă (un singur seek)                  │
│  ✅ Pro: Simplu de implementat                                              │
│  ❌ Con: Fragmentare externă severă                                         │
│  ❌ Con: Fișierele nu pot crește ușor                                       │
│  📍 Folosit: CD-ROM, DVD (read-only, cunoscut în avans)                     │
│                                                                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  2. ALOCARE ÎNLĂNȚUITĂ (FAT)                                                 │
│  ────────────────────────────                                                │
│                                                                              │
│  Fișier A: [10]──→[25]──→[11]──→[30]──→[15]──→NULL                          │
│            │      │      │      │      │                                     │
│            └──────┴──────┴──────┴──────┴── Fiecare bloc conține             │
│                                             pointer la următorul            │
│                                                                              │
│  FAT (File Allocation Table):                                               │
│  Index │ Next                                                               │
│  ──────┼──────                                                              │
│   10   │  25                                                                │
│   11   │  30                                                                │
│   15   │  EOF                                                               │
│   25   │  11                                                                │
│   30   │  15                                                                │
│                                                                              │
│  ✅ Pro: Fără fragmentare externă                                           │
│  ✅ Pro: Fișierele cresc ușor                                               │
│  ❌ Con: Acces aleator LENT (trebuie parcursă lista)                        │
│  ❌ Con: Pierderea unui bloc = pierderea restului fișierului                │
│  📍 Folosit: FAT12/16/32, USB sticks (compatibilitate)                      │
│                                                                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  3. ALOCARE INDEXATĂ (ext2/3/4, NTFS)                                       │
│  ───────────────────────────────────────                                     │
│                                                                              │
│  Inode conține un INDEX (array de pointeri):                                │
│                                                                              │
│  Inode Fișier A:                                                            │
│  ┌─────────────┐                                                            │
│  │ Direct[0]→10│                                                            │
│  │ Direct[1]→25│        Blocuri de date:                                    │
│  │ Direct[2]→11│        [10] [25] [11] [30] [15]                            │
│  │ Direct[3]→30│                                                            │
│  │ Direct[4]→15│                                                            │
│  │ ...         │                                                            │
│  │ Indirect →──┼──→ [Bloc cu 1024 pointeri]                                │
│  │ 2xIndirect→─┼──→ [Bloc cu pointeri la blocuri de pointeri]              │
│  └─────────────┘                                                            │
│                                                                              │
│  ✅ Pro: Acces aleator RAPID (O(1) pentru direct, O(log n) pentru indirect) │
│  ✅ Pro: Suportă fișiere foarte mari                                        │
│  ❌ Con: Overhead pentru fișiere mici                                       │
│  ❌ Con: Mai complex de implementat                                         │
│  📍 Folosit: ext2/3/4, NTFS, HFS+, majoritatea sistemelor moderne          │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### Calcul: Acces la Blocul N într-un Fișier

```
ALOCARE CONTIGUĂ:
  Acces bloc N = start + N
  Complexitate: O(1)
  Seek-uri disc: 1

ALOCARE ÎNLĂNȚUITĂ:
  Acces bloc N = parcurge N linkuri
  Complexitate: O(N)
  Seek-uri disc: N (worst case, blocuri împrăștiate)

ALOCARE INDEXATĂ (ext4):
  Bloc N < 12: Direct[N]                    → O(1), 1 seek
  Bloc N < 12 + 1024: Indirect              → O(1), 2 seeks
  Bloc N < 12 + 1024 + 1024²: 2xIndirect    → O(1), 3 seeks
  
  Exemplu: Acces la blocul 50.000 într-un fișier de 200MB
  - Contiguă: 1 seek
  - Înlănțuită: 50.000 seeks (!)
  - Indexată: 3 seeks (double indirect)
```

---

### 2. Extents: Evoluția Modernă (ext4)

#### Definiție Formală

> Un **extent** este o secvență de blocuri contigue descrisă ca (start_block, length). În loc să stocăm pointeri pentru fiecare bloc, stocăm un singur extent pentru un grup contiguu.

#### Comparație: Pointeri vs. Extents

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      POINTERI TRADIȚIONALI vs EXTENTS                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  Fișier de 100 MB, blocuri contigue pe disc:                                │
│                                                                              │
│  METODA VECHE (ext2/3): Pointeri individuali                                │
│  ──────────────────────────────────────────────                              │
│  Inode:                                                                      │
│  [0]→Block 1000                                                             │
│  [1]→Block 1001                                                             │
│  [2]→Block 1002                                                             │
│  ... (25.600 de pointeri pentru 100 MB!)                                    │
│  [25599]→Block 26599                                                        │
│                                                                              │
│  Overhead: 25.600 × 4 bytes = 100 KB de metadate                            │
│                                                                              │
│  ════════════════════════════════════════════════════════════════════════   │
│                                                                              │
│  METODA NOUĂ (ext4): Extents                                                │
│  ───────────────────────────────                                             │
│  Inode:                                                                      │
│  Extent 0: (start=1000, length=25600)                                       │
│                                                                              │
│  Overhead: 12 bytes!                                                        │
│                                                                              │
│  Un extent ext4 = 12 bytes:                                                 │
│  - 4 bytes: logical block (poziție în fișier)                               │
│  - 2 bytes: length (până la 32K blocuri = 128 MB per extent)                │
│  - 6 bytes: physical block (poziție pe disc)                                │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### Structura Extents în ext4

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          INODE ext4 CU EXTENTS                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────┐            │
│  │                    EXTENT HEADER (12 bytes)                  │            │
│  │  magic: 0xF30A                                               │            │
│  │  entries: 2 (câte extents în acest nod)                     │            │
│  │  max: 4 (capacitate maximă)                                  │            │
│  │  depth: 0 (0=leaf cu date, >0=index intern)                 │            │
│  └─────────────────────────────────────────────────────────────┘            │
│                             │                                                │
│                             ▼                                                │
│  ┌─────────────────────────────────────────────────────────────┐            │
│  │ EXTENT 0                                                     │            │
│  │   logical: 0 (începe la blocul 0 al fișierului)             │            │
│  │   length: 10000                                              │            │
│  │   physical: 50000 (bloc pe disc)                            │            │
│  │   → Blocurile 0-9999 ale fișierului sunt în 50000-59999     │            │
│  └─────────────────────────────────────────────────────────────┘            │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────┐            │
│  │ EXTENT 1                                                     │            │
│  │   logical: 10000                                             │            │
│  │   length: 5000                                               │            │
│  │   physical: 80000                                            │            │
│  │   → Blocurile 10000-14999 sunt în 80000-84999               │            │
│  └─────────────────────────────────────────────────────────────┘            │
│                                                                              │
│  Fișier de 60 MB descris cu doar 2 extents = 24 bytes!                      │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### Verificare Practică

```bash
# Creează un fișier de test
dd if=/dev/zero of=test_file bs=1M count=100

# Vizualizare extents cu filefrag
filefrag -v test_file

# Output tipic:
# Filesystem type is: ef53
# File size of test_file is 104857600 (25600 blocks of 4096 bytes)
#  ext:     logical_offset:        physical_offset: length:   expected: flags:
#    0:        0..   25599:      50000..     75599:  25600:             last,eof
#
# Un singur extent pentru 100 MB!

# Fișier fragmentat (după multe modificări)
filefrag -v /var/log/syslog
# Poate arăta zeci de extents dacă a fost scris incremental
```

---

### 3. Fragmentare: Inamic al Performanței

#### Definiție Formală

> **Fragmentarea** apare când blocurile unui fișier sunt împrăștiate pe disc în loc să fie contigue. Există fragmentare **internă** (spațiu irosit în ultimul bloc) și **externă** (blocuri necontigue).

#### Tipuri de Fragmentare

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         TIPURI DE FRAGMENTARE                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  FRAGMENTARE INTERNĂ                                                         │
│  ───────────────────────                                                     │
│                                                                              │
│  Fișier: 5 KB                                                               │
│  Bloc: 4 KB                                                                 │
│                                                                              │
│  ┌────────────────┐ ┌────────────────┐                                      │
│  │ Bloc 1: 4 KB   │ │ Bloc 2: 1 KB   │                                      │
│  │ ████████████   │ │ ██░░░░░░░░░░░  │                                      │
│  │ (plin)         │ │ (3 KB irosit)  │                                      │
│  └────────────────┘ └────────────────┘                                      │
│                                                                              │
│  Spațiu alocat: 8 KB                                                        │
│  Spațiu folosit: 5 KB                                                       │
│  Irosit: 3 KB (37.5%)                                                       │
│                                                                              │
│  ════════════════════════════════════════════════════════════════════════   │
│                                                                              │
│  FRAGMENTARE EXTERNĂ                                                         │
│  ───────────────────────                                                     │
│                                                                              │
│  Disc după multe creare/ștergere:                                           │
│                                                                              │
│  [A][A][_][B][A][_][_][B][C][_][A][B][_][C][A]                              │
│                                                                              │
│  Fișier A: blocuri în pozițiile 0,1,4,10,14                                 │
│  Fișier B: blocuri în pozițiile 3,7,11                                      │
│  Fișier C: blocuri în pozițiile 8,13                                        │
│                                                                              │
│  Citire secvențială a fișierului A:                                         │
│  - Trebuie 5 seek-uri în loc de 1!                                          │
│  - Pe HDD: diferența e ENORMĂ (ms vs µs)                                    │
│  - Pe SSD: mai puțin critic (dar tot contează pentru prefetch)              │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### Impact asupra Performanței

```
CITIRE 100 MB SECVENȚIAL:

Fișier contiguu (1 extent):
  HDD: 1 seek (10 ms) + 100 MB read (0.7 s) = ~0.71 s
  SSD: Neglijabil seek + 100 MB read (0.2 s) = ~0.2 s

Fișier fragmentat (1000 fragmente):
  HDD: 1000 seeks (10 s!) + 100 MB read (0.7 s) = ~10.7 s
       → 15x mai lent!
  SSD: 1000 seeks neglijabile + read (0.25 s) = ~0.25 s
       → 25% mai lent

Concluzie: Fragmentarea e critică pentru HDD, mai puțin pentru SSD,
dar tot afectează performanța prin overhead metadata și cache misses.
```

#### Defragmentare în ext4

```bash
# Verificare fragmentare
sudo e4defrag -c /home/

# Output:
# Total/best extents: 1523/1200
# Average size per extent: 128 KB
# Fragmentation score: 3 (0=perfect, 100=severe)

# Defragmentare (doar dacă e necesar)
sudo e4defrag /home/user/large_file.db

# ext4 face alocare inteligentă (delayed allocation)
# care previne fragmentarea în majoritatea cazurilor
```

---

### 4. Journaling: Consistență în Fața Eșecului

#### Definiție Formală

> **Journaling** este o tehnică care menține **integritatea sistemului de fișiere** prin scrierea modificărilor într-un jurnal (log circular) **înainte** de aplicarea lor efectivă. În caz de crash, sistemul redă jurnalul pentru a ajunge la o stare consistentă.

#### Problema: Crash în Mijlocul unei Operații

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    SCENARIUL DE CRASH FĂRĂ JOURNALING                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  Operație: Creare fișier "test.txt" cu conținut                             │
│                                                                              │
│  Pașii necesari (simplificat):                                              │
│  1. Alocă un inode liber (marchează în bitmap)                              │
│  2. Inițializează inode-ul (permisiuni, timestamps)                         │
│  3. Alocă blocuri de date (marchează în bitmap)                             │
│  4. Scrie datele în blocuri                                                 │
│  5. Adaugă intrarea în directorul părinte                                   │
│                                                                              │
│  ══════════════════════════════════════════════════════════════════════     │
│                                                                              │
│  CE SE ÎNTÂMPLĂ LA CRASH DUPĂ PASUL 3?                                       │
│                                                                              │
│  ✓ Inode alocat și inițializat                                              │
│  ✓ Blocuri de date alocate                                                  │
│  ✗ Date NESCRISE în blocuri (conțin garbage)                                │
│  ✗ Intrare director NEADĂUGATĂ                                              │
│                                                                              │
│  Rezultat: INCONSISTENȚĂ                                                     │
│  - Inode există dar nu e referit de niciun director → "orphan inode"        │
│  - Blocuri alocate dar pline de gunoi                                       │
│  - Spațiu pierdut permanent                                                 │
│                                                                              │
│  Alt scenariu: Crash după pasul 5 dar înainte de 4                          │
│  - Fișier "există" în director                                              │
│  - Dar conține GARBAGE!                                                     │
│  - Corupție silențioasă - cel mai rău caz                                   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### Soluția: Write-Ahead Logging (Journaling)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       JOURNALING WORKFLOW                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  FAZA 1: SCRIERE ÎN JURNAL                                                   │
│  ──────────────────────────                                                  │
│                                                                              │
│  Jurnal (zonă dedicată pe disc):                                            │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │ [TXN_BEGIN id=42]                                                    │    │
│  │ [INODE_UPDATE: inode 1234, mode=0644, size=100]                     │    │
│  │ [BLOCK_ALLOC: blocks 5000-5002]                                     │    │
│  │ [DIR_ENTRY: parent=500, name="test.txt", inode=1234]                │    │
│  │ [TXN_END id=42]                                                      │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  La acest punct: jurnalul e COMPLET pe disc (fsync)                         │
│                                                                              │
│  ════════════════════════════════════════════════════════════════════════   │
│                                                                              │
│  FAZA 2: CHECKPOINT (aplicare efectivă)                                      │
│  ──────────────────────────────────────                                      │
│                                                                              │
│  Acum scriem modificările în locațiile finale:                              │
│  - Actualizează bitmap inoduri                                              │
│  - Actualizează bitmap blocuri                                              │
│  - Scrie inode-ul                                                           │
│  - Scrie intrarea în director                                               │
│                                                                              │
│  ════════════════════════════════════════════════════════════════════════   │
│                                                                              │
│  FAZA 3: ȘTERGERE DIN JURNAL                                                 │
│  ──────────────────────────────                                              │
│                                                                              │
│  Marcăm tranzacția ca completă → spațiul din jurnal poate fi refolosit      │
│                                                                              │
│  ════════════════════════════════════════════════════════════════════════   │
│                                                                              │
│  LA RECOVERY (după crash):                                                   │
│  ──────────────────────────                                                  │
│                                                                              │
│  1. Scanează jurnalul                                                       │
│  2. Găsește tranzacții complete (TXN_BEGIN + TXN_END)                       │
│  3. Re-aplică acele tranzacții                                              │
│  4. Ignoră tranzacții incomplete (TXN_BEGIN fără TXN_END)                   │
│                                                                              │
│  Rezultat: Filesystem CONSISTENT, fără fsck lung!                           │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### Modurile de Journaling în ext4

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    MODURI JOURNALING ext4                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌───────────────┬───────────────┬───────────────┬───────────────────────┐  │
│  │    MOD        │ CE E JOURNALED│   VITEZĂ      │     SIGURANȚĂ         │  │
│  ├───────────────┼───────────────┼───────────────┼───────────────────────┤  │
│  │               │               │               │                       │  │
│  │  journal      │ Metadate +    │    LENT       │     MAXIMĂ            │  │
│  │  (safest)     │ DATE          │   (2x write)  │  Date nu se pierd     │  │
│  │               │               │               │                       │  │
│  ├───────────────┼───────────────┼───────────────┼───────────────────────┤  │
│  │               │               │               │                       │  │
│  │  ordered      │ Doar metadate │    MEDIU      │     BUNĂ              │  │
│  │  (DEFAULT)    │ (date scrise  │               │  Metadate consistente │  │
│  │               │  înainte)     │               │  Date pot fi vechi    │  │
│  │               │               │               │                       │  │
│  ├───────────────┼───────────────┼───────────────┼───────────────────────┤  │
│  │               │               │               │                       │  │
│  │  writeback    │ Doar metadate │    RAPID      │     MINIMĂ            │  │
│  │  (fastest)    │ (fără ordine) │               │  Date pot fi garbage  │  │
│  │               │               │               │                       │  │
│  └───────────────┴───────────────┴───────────────┴───────────────────────┘  │
│                                                                              │
│  EXPLICAȚIE DETALIATĂ:                                                       │
│                                                                              │
│  MODE=journal:                                                               │
│    Scrie atât metadate CÂT ȘI datele în jurnal                              │
│    Apoi scrie datele în locația finală                                      │
│    → 2x overhead scriere, dar 100% consistență                              │
│    → Recomandat pentru baze de date critice                                 │
│                                                                              │
│  MODE=ordered (default):                                                     │
│    Scrie DATELE în locația finală ÎNAINTE de commit metadata                │
│    La crash: datele sunt acolo, metadata consistentă                        │
│    → Compromis bun între viteză și siguranță                                │
│                                                                              │
│  MODE=writeback:                                                             │
│    Scrie metadatele în jurnal, datele când apucă                            │
│    La crash: metadata OK, dar fișierele pot conține gunoi                   │
│    → Rapid pentru workloads non-critice                                     │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### Verificare și Configurare

```bash
# Verifică modul curent de journaling
mount | grep "on / "
# /dev/sda1 on / type ext4 (rw,relatime,errors=remount-ro)

# Verificare detaliată
sudo tune2fs -l /dev/sda1 | grep -i journal
# Journal inode:            8
# Journal backup:           inode blocks
# Journal features:         journal_64bit journal_checksum_v3
# Journal size:             256M

# Vizualizare statistici jurnal
sudo dumpe2fs /dev/sda1 | grep -A 10 "Journal"

# Schimbare mod (PERICULOS - doar la mount)
# În /etc/fstab:
# /dev/sda1  /  ext4  data=journal  0  1
# sau
# /dev/sda1  /  ext4  data=writeback  0  1
```

---

### 5. Free Space Management: Cum Găsim Blocuri Libere

#### Definiție Formală

> **Free space management** este mecanismul prin care sistemul de fișiere urmărește ce blocuri sunt libere și găsește rapid blocuri pentru fișiere noi.

#### Metode de Urmărire

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      METODE DE TRACKING SPAȚIU LIBER                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  1. BITMAP (ext4, NTFS)                                                      │
│  ──────────────────────                                                      │
│                                                                              │
│  1 bit per bloc: 0=liber, 1=ocupat                                          │
│                                                                              │
│  Pentru 1 TB disc cu blocuri de 4 KB:                                       │
│  - 256 milioane blocuri                                                     │
│  - 256 Mbit = 32 MB pentru bitmap                                           │
│  - 0.003% overhead                                                          │
│                                                                              │
│  Bitmap: [1][1][0][1][0][0][0][1][1][0][1][0]...                            │
│           ↓  ↓  ↓  ↓                                                        │
│          B0 B1 B2 B3                                                        │
│               ↑                                                              │
│              LIBER                                                           │
│                                                                              │
│  ✅ Pro: Compact, O(n) worst case pentru găsire                             │
│  ✅ Pro: Ușor de verificat consistența                                      │
│  ❌ Con: Scanare liniară pentru găsire bloc liber                           │
│                                                                              │
│  ════════════════════════════════════════════════════════════════════════   │
│                                                                              │
│  2. LISTĂ ÎNLĂNȚUITĂ (vechi)                                                │
│  ───────────────────────────                                                 │
│                                                                              │
│  Blocuri libere formează o listă:                                           │
│  Free list head → Block 5 → Block 12 → Block 7 → NULL                       │
│                                                                              │
│  ❌ Con: Traversare lentă                                                   │
│  ❌ Con: Pierdere pointer = pierdere tot spațiul liber                      │
│                                                                              │
│  ════════════════════════════════════════════════════════════════════════   │
│                                                                              │
│  3. GRUPARE (ext4 - block groups)                                           │
│  ─────────────────────────────────                                           │
│                                                                              │
│  Discul e împărțit în grupuri; fiecare grup are bitmap propriu              │
│                                                                              │
│  [Group 0: bitmap + data] [Group 1: bitmap + data] [Group 2...]             │
│                                                                              │
│  ✅ Pro: Localitate - fișierele tind să fie în același grup                 │
│  ✅ Pro: Bitmap-uri mai mici, mai rapide de scanat                          │
│  ✅ Pro: Metadata redundantă (copii ale superblock-ului)                    │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

### 6. VFS: Abstractizarea Sistemelor de Fișiere

#### Definiție Formală

> **VFS (Virtual File System)** este un layer de abstractizare în kernel care oferă o interfață uniformă pentru toate tipurile de sisteme de fișiere. Aplicațiile folosesc aceleași syscalls (open, read, write) indiferent de filesystem-ul subiacent.

#### Arhitectura VFS

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          ARHITECTURA VFS LINUX                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│                         APLICAȚII (User Space)                               │
│                     open(), read(), write(), close()                         │
│                                │                                             │
│  ══════════════════════════════╪═════════════════════════════════════════   │
│                                │                                             │
│                         SYSTEM CALLS                                         │
│                                │                                             │
│  ┌─────────────────────────────┼─────────────────────────────────────────┐  │
│  │                             │                                          │  │
│  │                      VFS LAYER                                         │  │
│  │              (Virtual File System Switch)                              │  │
│  │                                                                        │  │
│  │  ┌──────────────────────────────────────────────────────────────────┐ │  │
│  │  │ Obiecte VFS comune:                                               │ │  │
│  │  │ - superblock: metadate filesystem                                 │ │  │
│  │  │ - inode: metadate fișier (abstractizat)                          │ │  │
│  │  │ - dentry: intrare director (cache)                                │ │  │
│  │  │ - file: fișier deschis (file descriptor)                         │ │  │
│  │  └──────────────────────────────────────────────────────────────────┘ │  │
│  │                             │                                          │  │
│  └─────────────────────────────┼──────────────────────────────────────────┘  │
│                                │                                             │
│        ┌───────────────────────┼───────────────────────┐                    │
│        │                       │                       │                    │
│        ▼                       ▼                       ▼                    │
│  ┌──────────┐           ┌──────────┐           ┌──────────┐                 │
│  │   ext4   │           │   NTFS   │           │   NFS    │                 │
│  │  driver  │           │  driver  │           │  driver  │                 │
│  └────┬─────┘           └────┬─────┘           └────┬─────┘                 │
│       │                      │                      │                       │
│       ▼                      ▼                      ▼                       │
│  ┌──────────┐           ┌──────────┐           ┌──────────┐                 │
│  │ Local    │           │ Local    │           │ Network  │                 │
│  │ Disk     │           │ Disk     │           │ Server   │                 │
│  └──────────┘           └──────────┘           └──────────┘                 │
│                                                                              │
│  Avantaje VFS:                                                               │
│  ✓ Aplicațiile nu știu ce filesystem folosesc                               │
│  ✓ Cod comun pentru cache, permissions, locking                             │
│  ✓ Ușor de adăugat filesystem-uri noi                                       │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### Verificare Practică

```bash
# Ce filesystem-uri sunt disponibile?
cat /proc/filesystems

# Ce filesystem-uri sunt montate?
mount | column -t

# Detalii despre un mount
findmnt /home

# Statistici VFS cache
cat /proc/slabinfo | grep -E 'dentry|inode'
```

---

### 7. Comparație Filesystems Moderne

#### Tabel Comparativ

| Caracteristică | ext4 | XFS | Btrfs | ZFS |
|----------------|------|-----|-------|-----|
| **Journaling** | Da | Da (metadata) | CoW | CoW |
| **Max file size** | 16 TB | 8 EB | 16 EB | 16 EB |
| **Max volume** | 1 EB | 8 EB | 16 EB | 256 ZB |
| **Snapshots** | Nu | Nu | Da | Da |
| **Checksums** | Metadata | Nu | Da | Da |
| **RAID nativ** | Nu | Nu | Da | Da |
| **Deduplicare** | Nu | Nu | Da | Da |
| **Maturitate** | Foarte stabilă | Stabilă | În dezvoltare | Stabilă (Solaris) |
| **Use case** | General, servere | DB, fișiere mari | Backup, NAS | Enterprise storage |

---

## Laborator/Seminar (Sesiunea 6/7)

### Materiale TC
- TC6a-TC6b: Advanced Scripting
- TC6c: Debugging and Testing

### Tema 6: `tema6_monitor.sh`

Script de monitorizare sistem cu opțiuni:
- `-c` CPU info (utilizare, frecvență)
- `-m` Memory info (RAM, swap, buffere)
- `-d` Disk info (spațiu, I/O stats)
- `-a` All (default, toate cele de sus)
- `-w N` Watch mode (refresh la N secunde)
- `-o FILE` Output în fișier

---

## Demonstrații Practice

### Demo 1: Observare Journaling

```bash
#!/bin/bash
# Demo: Observăm activitatea jurnalului

# Creează un fișier mare pentru a genera activitate
dd if=/dev/zero of=/tmp/test_journal bs=1M count=100

# Monitorizează I/O pe disc (include jurnalul)
iostat -x 1 5

# Vizualizare journal commits (necesită privilegii)
sudo journalctl -k | grep -i ext4

# Forțează sync și observă
sync
echo "Journal flushed"
```

### Demo 2: Fragmentare în Timp Real

```bash
#!/bin/bash
# Demo: Creăm fragmentare artificială

DEMO_DIR=$(mktemp -d)
cd "$DEMO_DIR"

# Creează fișiere intercalate
for i in {1..100}; do
    dd if=/dev/urandom of=file_$i bs=1K count=$((RANDOM % 100 + 1)) 2>/dev/null
done

# Șterge fișiere pare (creează găuri)
rm file_{2..100..2}

# Creează un fișier mare care va fi fragmentat
dd if=/dev/zero of=fragmented_file bs=1M count=10

# Verifică fragmentarea
filefrag -v fragmented_file

cd - && rm -rf "$DEMO_DIR"
```

---

## Lectură Recomandată

### OSTEP (Operating Systems: Three Easy Pieces)
- [Cap 40 - File System Implementation](https://pages.cs.wisc.edu/~remzi/OSTEP/file-implementation.pdf)
- [Cap 41 - Locality and FFS](https://pages.cs.wisc.edu/~remzi/OSTEP/file-ffs.pdf)
- [Cap 42 - Crash Consistency: FSCK and Journaling](https://pages.cs.wisc.edu/~remzi/OSTEP/file-journaling.pdf)

### Tanenbaum - Modern Operating Systems
- Capitolul 4.4: File System Implementation

### Linux Documentation
- `man 5 ext4`
- `man 8 tune2fs`
- `man 8 dumpe2fs`

---

## Sumar Comenzi Noi

| Comandă | Descriere | Exemplu |
|---------|-----------|---------|
| `filefrag` | Afișează extents/fragmentare | `filefrag -v file.dat` |
| `e4defrag` | Defragmentare ext4 | `sudo e4defrag /home/` |
| `tune2fs` | Configurare ext4 | `sudo tune2fs -l /dev/sda1` |
| `dumpe2fs` | Informații detaliate ext4 | `sudo dumpe2fs /dev/sda1` |
| `fsck` | Verificare filesystem | `sudo fsck /dev/sda1` |
| `mount` | Montare și informații | `mount \| grep ext4` |
| `findmnt` | Informații mount points | `findmnt /home` |
| `iostat` | Statistici I/O | `iostat -x 1` |

---


---


---

## Nuanțe și Cazuri Speciale

### Ce NU am acoperit (limitări didactice)

- **Log-structured filesystems**: LFS, F2FS - optimizate pentru write-heavy workloads și SSD-uri.
- **Checksumming end-to-end**: ZFS, Btrfs detectează și corectează bit rot.
- **Deduplication**: Eliminarea blocurilor duplicate (ZFS, Windows ReFS).

### Greșeli frecvente de evitat

1. **Journal mode greșit**: `data=journal` e sigur dar lent; `data=ordered` e compromisul standard.
2. **Ignorarea fsync()**: Datele pot fi pierdute fără fsync explicit pentru durabilitate.
3. **Formatare SSD cu opțiuni HDD**: Folosește `discard` mount option pentru TRIM automat.

### Întrebări rămase deschise

- Cum vor evolua sistemele de fișiere pentru storage class memory (SCM)?
- Poate un filesystem să fie simultan performant, sigur și eficient în spațiu?

## Privire înainte

**Săptămâna 13: Securitate în Sisteme de Operare** — Protejăm sistemul! Vom studia autentificarea (cine ești?), autorizarea (ce poți face?), modelul de permisiuni UNIX, ACL-uri și capabilities pentru privilegii granulare.

**Pregătire recomandată:**
- Experimentează cu `chmod`, `chown` și `getfacl`
- Citește despre principiul privilegiului minim

## Rezumat Vizual

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    SĂPTĂMÂNA 12: RECAP - FILESYSTEM (2)                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ALOCAREA BLOCURILOR                                                         │
│  ├── Contiguă: simplu dar fragmentare externă                               │
│  ├── Înlănțuită: flexibil dar acces aleator lent                            │
│  └── Indexată: rapid și flexibil (ext4)                                     │
│                                                                              │
│  EXTENTS (ext4)                                                              │
│  ├── Descrie blocuri contigue ca (start, length)                            │
│  └── Mult mai eficient decât pointeri individuali                           │
│                                                                              │
│  FRAGMENTARE                                                                 │
│  ├── Internă: spațiu irosit în ultimul bloc                                 │
│  ├── Externă: blocuri necontigue → seek-uri multiple                        │
│  └── Rezolvare: defragmentare, delayed allocation                           │
│                                                                              │
│  JOURNALING                                                                  │
│  ├── Scrie în jurnal înainte de aplicare efectivă                          │
│  ├── La crash: re-aplică sau anulează tranzacții                           │
│  └── Moduri: journal (safest) / ordered (default) / writeback (fast)       │
│                                                                              │
│  FREE SPACE MANAGEMENT                                                       │
│  ├── Bitmap: 1 bit per bloc (compact, eficient)                             │
│  └── Block groups: localitate și redundanță                                 │
│                                                                              │
│  VFS (Virtual File System)                                                   │
│  ├── Abstractizează diferite filesystems                                    │
│  └── Interfață uniformă pentru aplicații                                    │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```


---

## Auto-evaluare

### Întrebări de verificare

1. **[REMEMBER]** Ce este journaling-ul și ce problemă rezolvă? Enumeră cele 3 moduri de journaling în ext4.
2. **[UNDERSTAND]** Explică diferența dintre alocarea contiguă, alocarea înlănțuită și alocarea indexată. Care sunt avantajele ext4 cu extents?
3. **[ANALYSE]** Compară FAT32 cu ext4 din perspectiva: dimensiune maximă fișier, recuperare după crash, fragmentare.

### Mini-provocare (opțional)

Folosește `dumpe2fs` pentru a inspecta un sistem de fișiere ext4 și identifică: dimensiunea blocului, numărul de inode-uri, spațiul liber.

---

*Materiale dezvoltate by Revolvix pentru ASE București - CSIE*  
*Sisteme de Operare | Anul I, Semestrul 2 | 2025-2026*

---

## Scripting în context (Bash + Python): Journaling și colectare metadate FS

### Fișiere incluse

- Bash: `scripts/fs_metadata_report.sh` — Generează un raport cu mount/lsblk/df/inodes și hints de journaling.

### Rulare rapidă

```bash
./scripts/fs_metadata_report.sh
```

### Legătura cu conceptele din această săptămână

- Journaling este un mecanism de consistență: după crash, sistemul revine la o stare coerentă.
- În practică, „ce filesystem am și cum e montat?" este o întrebare operațională; raportul automatizat fixează răspunsul în date.

### Practică recomandată

- rulează întâi scripturile pe un director de test (nu pe date critice);
- salvează output-ul într-un fișier și atașează-l la raport/temă, dacă este cerut;
- notează versiunea de kernel (`uname -r`) și versiunea Python (`python3 --version`) când compari rezultate.

*Materiale dezvoltate de Revolvix pentru ASE București - CSIE*  
*Sisteme de Operare | Anul I, Semestrul 2 | 2025-2026*
