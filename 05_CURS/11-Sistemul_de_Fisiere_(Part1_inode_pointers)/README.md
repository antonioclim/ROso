# Sisteme de Operare - Săptămâna 11: Sistemul de Fișiere (Partea 1)

> **by Revolvix** | ASE București - CSIE | Anul I, Semestrul 2 | 2025-2026

---

## Obiectivele Săptămânii

După parcurgerea materialelor din această săptămână, vei putea să:

1. Explici conceptul de persistență și necesitatea sistemelor de fișiere
2. Descrii structura unui inode și informațiile pe care le conține
3. **Diferențiezi** între hard links și symbolic links și explici implicațiile practice
4. **Folosești** comenzi pentru explorarea metadatelor fișierelor
5. **Analizezi** structura directoarelor și rezolvarea căilor (path resolution)

---

## Context aplicativ (scenariu didactic): Cum găsește Linux un fișier printre milioane în milisecunde?

Ai un disc cu 500.000 de fișiere. Tastezi `cat /home/user/document.txt`. În milisecunde, sistemul găsește exact acel fișier. Nu caută la întâmplare - folosește **structuri de date optimizate**: directoare ca arbori, inoduri ca indexuri. E ca diferența dintre a căuta o carte după culoare vs. după codul de clasificare din bibliotecă.

Dar stai: de ce ai nevoie de un "sistem de fișiere"? RAM-ul e rapid, dar se șterge la restart. HDD/SSD-ul păstrează datele, dar e lent și trebuie organizat. Sistemul de fișiere face puntea între cele două lumi.

> 💡 **Gândește-te**: Când ștergi un fișier, datele dispar imediat de pe disc?

---

## Conținut Curs (11/14)

### 1. De la RAM la Persistență: De Ce Avem Nevoie de Filesystems

#### Definiție Formală

> **Persistența** este proprietatea datelor de a supraviețui opririi sistemului. Un **sistem de fișiere** (filesystem) este metoda de organizare și stocare a datelor pe medii persistente, oferind abstractizarea "fișier" și "director".

#### Ierarhia de Stocare

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        IERARHIA MEMORIEI                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  REGISTRE CPU     ←───  1 ns      │  ~1 KB     │  Volatilă                 │
│       ↓                           │            │                            │
│  CACHE L1/L2/L3   ←───  5-50 ns   │  KB-MB     │  Volatilă                 │
│       ↓                           │            │                            │
│  RAM (DRAM)       ←───  100 ns    │  GB        │  Volatilă                 │
│       ↓                           │            │                            │
│  ════════════════════════════════════════════════════════════               │
│       ↓           BARIERA VOLATILITATE                                      │
│  ════════════════════════════════════════════════════════════               │
│       ↓                           │            │                            │
│  SSD (NVMe)       ←───  100 µs    │  TB        │  PERSISTENTĂ              │
│       ↓                           │            │                            │
│  HDD              ←───  10 ms     │  TB        │  PERSISTENTĂ              │
│       ↓                           │            │                            │
│  TAPE/CLOUD       ←───  secunde   │  PB        │  PERSISTENTĂ              │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘

Observații:
- Sub bariera de volatilitate: datele supraviețuiesc restart-ului
- Trade-off: viteză vs. persistență vs. cost
- Filesystem-ul gestionează zona persistentă
```

#### Explicație Intuitivă

**Metafora: Biblioteca**

Imaginează-ți o bibliotecă uriașă:
- **Discul** = Depozitul cu milioane de cărți (date brute)
- **Filesystem** = Sistemul de catalogare (organizare)
- **Inode** = Fișa cărții (autor, an, locație pe raft)
- **Director** = Catalogul tematic ("Matematică" → lista de cărți)
- **Path** = Adresa completă ("Etaj 3, Raft B, Poziția 42")

Fără un sistem de catalogare, ai căuta printre milioane de cărți la întâmplare!

#### Context Istoric

| An | Eveniment | Semnificație |
|----|-----------|--------------|
| 1965 | Multics introduce ierarhia de directoare | Prima structură arborescentă |
| 1969 | UNIX filesystem | Conceptul de inode, "totul e fișier" |
| 1983 | ext (Extended Filesystem) | Primul filesystem Linux |
| 1993 | ext2 | Standard Linux pentru un deceniu |
| 2001 | ext3 | Adaugă journaling |
| 2008 | ext4 | Extents, timestamps nanosecunde |
| 2013 | Btrfs | Copy-on-write, snapshots |

---

### 2. Structura Discului: De la Blocuri la Fișiere

#### Definiție Formală

> Un disc este împărțit în **blocuri** (tipic 4 KB). Sistemul de fișiere organizează aceste blocuri în **superblock** (metadate globale), **bitmap-uri** (free/used), **inode table** și **blocuri de date**.

#### Layout ext4 Simplificat

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          DISC PARTIȚIONAT                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌────────────┬───────────────────────────────────────────────────────────┐ │
│  │ BOOT BLOCK │                    PARTIȚIA ext4                          │ │
│  │  (512 B)   │                                                           │ │
│  └────────────┴───────────────────────────────────────────────────────────┘ │
│                │                                                             │
│                ▼                                                             │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │ BLOCK GROUP 0                                                         │   │
│  ├──────────────────────────────────────────────────────────────────────┤   │
│  │ Super  │ Group   │ Block  │ Inode  │ Inode   │ Data Blocks           │   │
│  │ Block  │ Descrip │ Bitmap │ Bitmap │ Table   │ (fișiere)             │   │
│  │ 1 bloc │ 1 bloc  │ 1 bloc │ 1 bloc │ N blocs │ ... mii de blocuri    │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │ BLOCK GROUP 1                                                         │   │
│  │ ... (structură similară, cu copii backup ale superblock-ului)         │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  ... (mii de block groups)                                                   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘

Componente:
- Superblock: Informații globale (dimensiune, număr blocuri/inoduri, mount count)
- Block Bitmap: 1 bit per bloc (0=liber, 1=ocupat)
- Inode Bitmap: 1 bit per inode (0=liber, 1=ocupat)
- Inode Table: Array de structuri inode
- Data Blocks: Conținutul efectiv al fișierelor
```

#### Verificare Practică

```bash
# Informații superblock
sudo dumpe2fs /dev/sda1 | head -50

# Statistici filesystem
df -h           # Spațiu folosit
df -i           # Inoduri folosite

# Dimensiune bloc
sudo blockdev --getbsz /dev/sda1
# Output tipic: 4096 (4 KB)
```

---

### 3. Inode (Index Node): Nucleul Metadatelor

#### Definiție Formală

> **Inode** (index node) este structura de date care conține **toate metadatele unui fișier**, cu excepția numelui. Include: tipul, permisiunile, owner (UID/GID), dimensiunea, timestamps și pointeri către blocurile de date.

#### Structura Detaliată a unui Inode

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              INODE #12345                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │ MODE (16 biți)                                                       │    │
│  │   - Tip fișier: regular(-), director(d), symlink(l), device(b/c)    │    │
│  │   - Permisiuni: rwxr-xr-x (755 octal)                               │    │
│  │   - Special bits: setuid, setgid, sticky                            │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │ OWNERSHIP                                                            │    │
│  │   - UID: 1000 (owner user)                                          │    │
│  │   - GID: 1000 (owner group)                                         │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │ TIMESTAMPS (nanosecunde în ext4)                                     │    │
│  │   - atime: Last Access      (2025-01-15 10:30:45)                   │    │
│  │   - mtime: Last Modify      (2025-01-14 09:15:22)                   │    │
│  │   - ctime: Last Change      (2025-01-14 09:15:22)                   │    │
│  │   - crtime: Creation        (2025-01-10 14:00:00) [ext4 only]       │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │ DIMENSIUNE ȘI LINK COUNT                                             │    │
│  │   - Size: 15360 bytes                                               │    │
│  │   - Blocks: 32 (512-byte blocks)                                    │    │
│  │   - Links: 2 (câte nume referă acest inode)                         │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │ POINTERI CĂTRE DATE (ext4 cu extents)                                │    │
│  │                                                                      │    │
│  │   Direct Blocks [0-11]:  12 × 4KB = 48 KB direct                    │    │
│  │      [0] → Block 5000                                               │    │
│  │      [1] → Block 5001                                               │    │
│  │      ...                                                            │    │
│  │                                                                      │    │
│  │   Single Indirect [12]:  1024 pointeri × 4KB = 4 MB                 │    │
│  │      → Block 6000 (conține 1024 pointeri)                           │    │
│  │         [0] → Block 7000                                            │    │
│  │         [1] → Block 7001                                            │    │
│  │         ...                                                         │    │
│  │                                                                      │    │
│  │   Double Indirect [13]: 1024 × 1024 × 4KB = 4 GB                    │    │
│  │      → Block 8000 (1024 pointeri la blocuri de pointeri)            │    │
│  │                                                                      │    │
│  │   Triple Indirect [14]: 1024³ × 4KB = 4 TB                          │    │
│  │      → Block 9000 (adresare pentru fișiere uriașe)                  │    │
│  │                                                                      │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘

IMPORTANT: Inode-ul NU conține numele fișierului!
Numele este stocat în DIRECTORUL părinte.
```

#### Explicație Intuitivă

**Metafora: Fișa de Bibliotecă**

- **Inode** = Fișa cărții (conține toate informațiile despre carte: autor, an, editură, locație pe raft)
- **Director** = Catalogul care spune "Titlul X are fișa #12345"
- **Blocuri de date** = Paginile cărții (conținutul propriu-zis)

De ce numele nu e în inode? Pentru că aceeași carte poate avea mai multe titluri în catalog (hard links)!

#### Calcul: Dimensiunea Maximă a unui Fișier

```
Cu blocuri de 4 KB (4096 bytes) și pointeri de 4 bytes:

Direct blocks:        12 × 4 KB =                        48 KB
Single indirect:      1024 × 4 KB =                       4 MB
Double indirect:      1024 × 1024 × 4 KB =                4 GB
Triple indirect:      1024 × 1024 × 1024 × 4 KB =         4 TB
────────────────────────────────────────────────────────────────
Total teoretic:                                          ~4 TB

ext4 actual: limită de 16 TB per fișier (cu extents)
```

#### Verificare Practică

```bash
# Creează un fișier de test
echo "Hello, filesystem!" > test.txt

# Vizualizare inode cu stat
stat test.txt

# Output:
#   File: test.txt
#   Size: 19              Blocks: 8          IO Block: 4096   regular file
# Device: 8,1     Inode: 1234567    Links: 1
# Access: (0644/-rw-r--r--)  Uid: ( 1000/   user)   Gid: ( 1000/  group)
# Access: 2025-01-15 10:30:45.123456789 +0200
# Modify: 2025-01-15 10:30:40.987654321 +0200
# Change: 2025-01-15 10:30:40.987654321 +0200
#  Birth: 2025-01-15 10:30:40.987654321 +0200

# Doar numărul inode
ls -i test.txt
# 1234567 test.txt

# Informații detaliate despre inode (necesită debugfs)
sudo debugfs -R "stat <1234567>" /dev/sda1
```

---

### 4. Directoare: Catalogul Sistemului de Fișiere

#### Definiție Formală

> Un **director** (directory) este un tip special de fișier care conține o listă de **intrări** (directory entries). Fiecare intrare mapează un **nume** la un **număr de inode**.

#### Structura unui Director

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    DIRECTOR /home/user (inode #500)                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  Conținutul directorului (ca fișier special):                               │
│                                                                              │
│  ┌────────────────┬───────────────────────────────────────────────────────┐ │
│  │  Inode Number  │  Nume                                                 │ │
│  ├────────────────┼───────────────────────────────────────────────────────┤ │
│  │     500        │  .           (referință la sine)                      │ │
│  │     400        │  ..          (referință la părinte: /home)            │ │
│  │     501        │  document.txt                                         │ │
│  │     502        │  photos/                                              │ │
│  │     501        │  doc_link    (HARD LINK! Același inode ca document)   │ │
│  │     503        │  Downloads/                                           │ │
│  └────────────────┴───────────────────────────────────────────────────────┘ │
│                                                                              │
│  Observații:                                                                 │
│  - "." și ".." sunt intrări reale în director                               │
│  - document.txt și doc_link au ACELAȘI inode (501) = hard link              │
│  - Numele e stocat aici, NU în inode                                        │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### Path Resolution: Cum Găsește SO un Fișier

```
Cerere: open("/home/user/document.txt")

PASUL 1: Start de la root inode (inode #2, rezervat)
         Citește conținutul directorului "/"
         
PASUL 2: Caută "home" în "/"
         Găsit: inode #100
         Verifică că e director și ai permisiuni
         
PASUL 3: Citește directorul /home (inode #100)
         Caută "user"
         Găsit: inode #500
         
PASUL 4: Citește directorul /home/user (inode #500)
         Caută "document.txt"
         Găsit: inode #501
         
PASUL 5: Citește inode #501
         - Verifică permisiuni (r-- pentru user)
         - Obține pointeri către blocurile de date
         - Returnează file descriptor către aplicație

Total operații I/O:
- 4 citiri inode (/, /home, /home/user, document.txt)
- 3 citiri director (conținut /, /home, /home/user)
= 7 accesuri disc (fără cache)

Cu TLB/dentry cache: ~1-2 accesuri disc!
```

#### Verificare Practică

```bash
# Vizualizare conținut director cu inoduri
ls -lai /home/user/

# Output:
# 500 drwxr-xr-x 5 user group 4096 Jan 15 10:30 .
# 400 drwxr-xr-x 3 root root  4096 Jan 10 14:00 ..
# 501 -rw-r--r-- 2 user group   19 Jan 15 10:30 document.txt
# 502 drwxr-xr-x 2 user group 4096 Jan 12 09:00 photos
# 501 -rw-r--r-- 2 user group   19 Jan 15 10:30 doc_link
#     ^--- Observă: document.txt și doc_link au același inode!

# Verificare link count
stat document.txt | grep Links
# Links: 2
```

---

### 5. Hard Links vs Symbolic Links

#### Definiție Formală

> **Hard link** = O nouă intrare de director care referă același inode. Numele diferit, dar date identice.
> **Symbolic link (symlink)** = Un fișier special care conține **calea** către alt fișier.

#### Comparație Detaliată

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          HARD LINK                                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  Directory A                 Directory B                                     │
│  ┌──────────────────┐       ┌──────────────────┐                            │
│  │ file.txt → #1234 │       │ link.txt → #1234 │                            │
│  └────────┬─────────┘       └────────┬─────────┘                            │
│           │                          │                                       │
│           └──────────┬───────────────┘                                       │
│                      ▼                                                       │
│              ┌─────────────┐                                                 │
│              │ Inode #1234 │  ← Același inode, link count = 2               │
│              │ Links: 2    │                                                 │
│              └──────┬──────┘                                                 │
│                     ▼                                                        │
│              ┌─────────────┐                                                 │
│              │ Data Blocks │  ← Aceleași date                               │
│              │ "Hello..."  │                                                 │
│              └─────────────┘                                                 │
│                                                                              │
│  Proprietăți:                                                                │
│  ✓ Ștergerea unui nume NU șterge datele (până link count = 0)               │
│  ✓ Modificarea prin orice nume afectează toate                              │
│  ✗ NU poate traversa filesystem-uri (alt device = alte inoduri)             │
│  ✗ NU poate referi directoare (ar crea cicluri)                             │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                         SYMBOLIC LINK                                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  Directory                                                                   │
│  ┌──────────────────────────────────────────────────────────────────┐       │
│  │ original.txt → Inode #1234                                        │       │
│  │ shortcut.txt → Inode #5678 (TIP: symlink)                        │       │
│  └──────────────────────────────────────────────────────────────────┘       │
│                    │                    │                                    │
│                    ▼                    ▼                                    │
│           ┌─────────────┐      ┌─────────────────────┐                      │
│           │ Inode #1234 │      │ Inode #5678         │                      │
│           │ Type: file  │      │ Type: symlink       │                      │
│           │ Links: 1    │      │ Data: "original.txt"│ ← Conține CALEA      │
│           └──────┬──────┘      └─────────────────────┘                      │
│                  ▼                                                           │
│           ┌─────────────┐                                                    │
│           │ Data Blocks │                                                    │
│           │ "Hello..."  │                                                    │
│           └─────────────┘                                                    │
│                                                                              │
│  Proprietăți:                                                                │
│  ✓ Poate traversa filesystem-uri                                            │
│  ✓ Poate referi directoare                                                  │
│  ✓ Mai flexibil (poate pointa oriunde)                                      │
│  ✗ "Broken link" dacă ținta e ștearsă                                       │
│  ✗ Overhead suplimentar (rezoluție path)                                    │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### Tabel Comparativ

| Aspect | Hard Link | Symbolic Link |
|--------|-----------|---------------|
| **Ce conține** | Număr inode | Cale text |
| **Inode propriu** | Nu (partajat) | Da (nou) |
| **Cross-filesystem** | ❌ Imposibil | ✅ Posibil |
| **Referă directoare** | ❌ Interzis | ✅ Permis |
| **După ștergere target** | Date rămân | Link broken |
| **Permisiuni** | Ale inode-ului | lrwxrwxrwx (ignorat) |
| **Dimensiune** | 0 (doar intrare dir) | Lungimea căii |
| **Creare** | `ln original hard` | `ln -s original soft` |

#### Demonstrație Practică

```bash
# Setup
echo "Date originale" > original.txt
ls -li original.txt
# 1234567 -rw-r--r-- 1 user group 15 Jan 15 original.txt
#                    ^ link count = 1

# Creare hard link
ln original.txt hard_link.txt
ls -li original.txt hard_link.txt
# 1234567 -rw-r--r-- 2 user group 15 Jan 15 original.txt
# 1234567 -rw-r--r-- 2 user group 15 Jan 15 hard_link.txt
# ^ ACELAȘI INODE!   ^ link count = 2

# Creare symbolic link
ln -s original.txt soft_link.txt
ls -li soft_link.txt
# 9876543 lrwxrwxrwx 1 user group 12 Jan 15 soft_link.txt -> original.txt
# ^ INODE DIFERIT    ^ tip symlink

# Modificare prin hard link
echo "Modificat!" >> hard_link.txt
cat original.txt
# Date originale
# Modificat!
# Modificarea apare în AMBELE!

# Ștergere original
rm original.txt
cat hard_link.txt
# Date originale
# Modificat!
# DATELE EXISTĂ ÎNCĂ! (link count = 1)

cat soft_link.txt
# cat: soft_link.txt: No such file or directory
# BROKEN LINK! Target-ul nu mai există.

# Verificare link broken
ls -la soft_link.txt
# lrwxrwxrwx 1 user group 12 Jan 15 soft_link.txt -> original.txt
# (în terminal, va fi colorat roșu pentru broken link)
```

---

### 6. Tipuri Speciale de Fișiere: "Totul e Fișier"

#### Filosofia UNIX

> În UNIX, "totul e fișier": dispozitive hardware, socket-uri de rețea, și procese sunt accesate prin interfața unificată a sistemului de fișiere.

#### Tipurile de Fișiere

```
Primul caracter în ls -l indică tipul:

  -  Regular file      Fișier obișnuit cu date
  d  Directory         Director (listă de intrări)
  l  Symbolic link     Link simbolic
  b  Block device      Dispozitiv bloc (HDD, SSD)
  c  Character device  Dispozitiv caracter (terminal, mouse)
  p  Named pipe (FIFO) Comunicare inter-proces
  s  Socket            Comunicare rețea/local
```

#### Exemple din /dev

```bash
ls -la /dev/sda /dev/null /dev/tty /dev/random

# brw-rw---- 1 root disk 8, 0 Jan 15 /dev/sda      # Block device (disc)
# crw-rw-rw- 1 root root 1, 3 Jan 15 /dev/null     # Character device
# crw-rw-rw- 1 root tty  5, 0 Jan 15 /dev/tty      # Terminal
# crw-rw-rw- 1 root root 1, 8 Jan 15 /dev/random   # Generator random

# Utilizare
echo "test" > /dev/null     # Dispare (black hole)
cat /dev/random | head -c 16 | xxd  # 16 bytes random
```

#### Pseudo-Filesystems

```bash
# /proc - Informații despre procese și sistem
cat /proc/cpuinfo     # Info CPU
cat /proc/meminfo     # Info memorie
ls /proc/$$           # Procesul curent

# /sys - Interfață kernel
cat /sys/class/net/eth0/address  # MAC address

# /dev - Dispozitive
ls /dev/sd*           # Discuri

# Acestea NU sunt pe disc - sunt generate de kernel în timp real!
df -T /proc /sys
# Filesystem     Type  ...
# proc           proc  ...
# sysfs          sysfs ...
```

---

### 7. Trade-off-uri și Considerații Practice

#### Costuri și Beneficii

| Aspect | Beneficiu | Cost |
|--------|-----------|------|
| **Inoduri** | Acces rapid la metadate | Număr limitat (se poate termina înainte de spațiu!) |
| **Indirectare** | Fișiere mari | Mai multe accesuri disc pentru fișiere uriașe |
| **Hard links** | Partajare eficientă | Nu traversează filesystem-uri |
| **Symlinks** | Flexibilitate | Overhead rezoluție, risc de broken |
| **Directoare mari** | Organizare | Scanare lentă (folosește B-tree în ext4) |

#### Eroarea Clasică: "Nu mai am spațiu" vs "Nu mai am inoduri"

```bash
# Verificare spațiu
df -h /
# Filesystem      Size  Used Avail Use% Mounted on
# /dev/sda1        50G   45G    5G  90% /

# Verificare inoduri
df -i /
# Filesystem      Inodes  IUsed   IFree IUse% Mounted on
# /dev/sda1       3276800 3276800     0  100% /
# ZERO inoduri libere! Nu poți crea fișiere noi chiar dacă ai 5GB spațiu!

# Cauză comună: milioane de fișiere mici (cache, sesiuni, logs)
find /tmp -type f | wc -l
# 3000000 ← 3 milioane de fișiere mici în /tmp!
```

---

## Laborator/Seminar (Sesiunea 5/7)

### Materiale TC
- TC5a-TC5c: Bash Functions
- TC5d: Debugging and Error Handling

### Tema 5: `tema5_fs_explorer.sh`

Script de explorare filesystem cu funcții:
- `show_inode_info()` - Afișează informații inode pentru un fișier
- `find_hard_links()` - Găsește toate hard link-urile unui fișier
- `check_broken_symlinks()` - Verifică symlink-uri broken într-un director
- `-r` - Recursiv
- `-v` - Verbose

---

## Demonstrații Practice

### Demo 1: Inode în acțiune

```bash
#!/bin/bash
# Demo: Același inode, nume diferite

DEMO_DIR=$(mktemp -d)
cd "$DEMO_DIR"

# Creare fișier și hard links
echo "Date importante" > data.txt
ln data.txt backup1.txt
ln data.txt backup2.txt

echo "=== Toate referă același inode ==="
ls -li *.txt

echo "=== Link count = 3 ==="
stat data.txt | grep Links

echo "=== Ștergem originalul ==="
rm data.txt
cat backup1.txt  # Datele există încă!

echo "=== Link count = 2 ==="
stat backup1.txt | grep Links

cd - && rm -rf "$DEMO_DIR"
```

### Demo 2: Symlink vs Hard Link

```bash
#!/bin/bash
# Comparație vizuală

mkdir -p /tmp/link_demo/{dir1,dir2}
echo "Original" > /tmp/link_demo/dir1/file.txt

# Hard link în același director
ln /tmp/link_demo/dir1/file.txt /tmp/link_demo/dir1/hard.txt

# Symlink în alt director
ln -s ../dir1/file.txt /tmp/link_demo/dir2/soft.txt

# Vizualizare
tree /tmp/link_demo
ls -li /tmp/link_demo/dir1/
ls -li /tmp/link_demo/dir2/

# Cleanup
rm -rf /tmp/link_demo
```

---

## Lectură Recomandată

### OSTEP (Operating Systems: Three Easy Pieces)
- [Cap 39 - Files and Directories](https://pages.cs.wisc.edu/~remzi/OSTEP/file-intro.pdf)
- [Cap 40 - File System Implementation](https://pages.cs.wisc.edu/~remzi/OSTEP/file-implementation.pdf)

### Tanenbaum - Modern Operating Systems
- Capitolul 4.3: File System Implementation

### Linux Documentation
- `man 7 inode`
- `man 2 stat`
- `man 1 ln`

---

## Sumar Comenzi Noi

| Comandă | Descriere | Exemplu |
|---------|-----------|---------|
| `ls -i` | Afișează număr inode | `ls -i file.txt` |
| `stat` | Informații detaliate fișier | `stat file.txt` |
| `ln` | Creare hard link | `ln original link` |
| `ln -s` | Creare symbolic link | `ln -s target link` |
| `df -i` | Statistici inoduri | `df -i /` |
| `file` | Determină tipul fișierului | `file /dev/sda` |
| `readlink` | Citește ținta unui symlink | `readlink -f link.txt` |
| `find -inum` | Caută după inode | `find . -inum 12345` |
| `find -samefile` | Găsește hard links | `find . -samefile file.txt` |

---


---


---

## Nuanțe și Cazuri Speciale

### Ce NU am acoperit (limitări didactice)

- **Extended attributes (xattr)**: Metadata adițional pe fișiere (ACLs, SELinux labels).
- **Sparse files**: Fișiere cu "găuri" care nu ocupă spațiu pe disc.
- **Copy-on-write filesystems**: Btrfs, ZFS - nu modifică date, creează copii noi.

### Greșeli frecvente de evitat

1. **Hardlinks pentru directoare**: Interzise (ar crea cicluri în ierarhie). Excepție: `.` și `..`.
2. **Symlinks relative vs absolute**: Relative sunt portabile; absolute pot deveni invalide la mutare.
3. **Presupunerea că rm șterge datele**: Datele persistă până sunt suprascrise; pentru ștergere sigură: `shred`.

### Întrebări rămase deschise

- Vor înlocui object stores (S3-like) sistemele de fișiere tradiționale?
- Cum evoluează sistemele de fișiere pentru SSD-uri (F2FS, optimizări ext4)?

## Privire înainte

**Săptămâna 12: Sistemul de Fișiere (Partea 2)** — Continuăm cu aspecte avansate: alocarea spațiului pe disc (contiguă, linked, indexed), structura FAT și ext4, și mecanismul esențial de journaling care previne coruperea datelor.

**Pregătire recomandată:**
- Rulează `df -T` pentru a vedea sistemele de fișiere montate
- Experimentează cu `dumpe2fs` pe o partiție ext4

## Rezumat Vizual

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    SĂPTĂMÂNA 11: RECAP - FILESYSTEM (1)                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  PERSISTENȚĂ                                                                 │
│  ├── RAM = volatilă, rapidă                                                 │
│  ├── Disc = persistentă, lentă                                              │
│  └── Filesystem = punte între cele două                                     │
│                                                                              │
│  STRUCTURĂ DISC                                                              │
│  ├── Superblock (metadate globale)                                          │
│  ├── Bitmap-uri (blocuri/inoduri libere)                                    │
│  ├── Inode Table (metadate fișiere)                                         │
│  └── Data Blocks (conținut efectiv)                                         │
│                                                                              │
│  INODE                                                                       │
│  ├── Conține: tip, permisiuni, owner, timestamps, size, pointeri           │
│  ├── NU conține: numele fișierului!                                         │
│  └── Pointeri: direct (48KB) → indirect (4MB) → 2x (4GB) → 3x (4TB)        │
│                                                                              │
│  DIRECTOARE                                                                  │
│  ├── Fișier special cu perechi (nume → inode)                               │
│  ├── "." = self, ".." = parent                                              │
│  └── Path resolution: parcurge arbore de la root                            │
│                                                                              │
│  LINKURI                                                                     │
│  ├── Hard link: alt nume, ACELAȘI inode                                     │
│  │   └── Limitare: același filesystem, fără directoare                      │
│  └── Symbolic link: fișier special cu CALEA target-ului                     │
│      └── Flexibil dar poate fi "broken"                                     │
│                                                                              │
│  "TOTUL E FIȘIER"                                                            │
│  ├── Regular (-), Directory (d), Symlink (l)                                │
│  ├── Block device (b), Character device (c)                                 │
│  └── Pipe (p), Socket (s)                                                   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```


---

## Auto-evaluare

### Întrebări de verificare

1. **[REMEMBER]** Ce informații conține un inode în sistemele Unix/Linux? Enumeră cel puțin 6 câmpuri.
2. **[UNDERSTAND]** Explică diferența dintre hard link și symbolic link. De ce hard link-urile nu pot traversa sistemele de fișiere?
3. **[ANALYSE]** Analizează sistemul de pointeri din inode (directi, indirect simplu, dublu, triplu). Calculează dimensiunea maximă a unui fișier pentru blocuri de 4KB.

### Mini-provocare (opțional)

Creează un fișier, un hard link și un symbolic link către el. Folosește `ls -li` pentru a observa inode-urile și link count-ul.

---

*Materiale dezvoltate by Revolvix pentru ASE București - CSIE*  
*Sisteme de Operare | Anul I, Semestrul 2 | 2025-2026*

---

## Scripting în context (Bash + Python): Inodes, hard links, symlinks

### Fișiere incluse

- Bash: `scripts/links_demo.sh` — Creează hard link și symlink și explică efectele.
- Python: `scripts/inode_walk.py` — Grupează fișiere după (device, inode) pentru a găsi hard links.

### Rulare rapidă

```bash
./scripts/links_demo.sh
./scripts/inode_walk.py --root .
```

### Legătura cu conceptele din această săptămână

- Hard link = încă un nume pentru același inode; symlink = fișier special care conține un path.
- Gruparea după (device, inode) e o aplicație directă a metadatelor expuse de filesystem.

### Practică recomandată

- rulează întâi scripturile pe un director de test (nu pe date critice);
- salvează output-ul într-un fișier și atașează-l la raport/temă, dacă este cerut;
- notează versiunea de kernel (`uname -r`) și versiunea Python (`python3 --version`) când compari rezultate.

*Materiale dezvoltate de Revolvix pentru ASE București - CSIE*  
*Sisteme de Operare | Anul I, Semestrul 2 | 2025-2026*