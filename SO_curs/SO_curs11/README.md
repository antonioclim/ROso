# Sisteme de Operare - Săptămâna 11: Sistemul de Fișiere (Partea 1)

> **by Revolvix** | ASE București - CSIE | Anul I, Semestrul 2 | 2025-2026

---

## Obiectivele Săptămânii

1. Explici conceptul de persistență și necesitatea sistemelor de fișiere
2. Descrii structura unui inode și informațiile pe care le conține
3. **Diferențiezi** între hard links și symbolic links
4. **Folosești** comenzi pentru explorarea metadatelor fișierelor

---

## Context aplicativ (scenariu didactic): Cum găsește Linux un fișier printre milioane în milisecunde?

Ai un disc cu 500.000 de fișiere. Tastezi `cat /home/user/document.txt`. În milisecunde, sistemul găsește exact acel fișier. Nu caută la întâmplare - folosește **structuri de date optimizate**: directoare ca arbori, inoduri ca indexuri. E ca diferența dintre a căuta o carte după culoare vs. după codul de clasificare.

---

## Conținut Curs (11/14)

### 1. Inode (Index Node)

#### Definiție Formală

> Inode este structura de date care conține **metadatele unui fișier**: tipul, permisiunile, owner, timestamps, dimensiunea, și pointeri către blocurile de date. NU conține numele fișierului!

```
┌─────────────────────────────────┐
│           INODE                 │
├─────────────────────────────────┤
│ Type & Permissions              │
│ Owner (UID, GID)                │
│ Size (bytes)                    │
│ Timestamps:                     │
│   - atime (access)              │
│   - mtime (modify)              │
│   - ctime (change)              │
│ Link count                      │
│ Block pointers:                 │
│   Direct [0-11]        12 blocks│
│   Single indirect     1024 blocks
│   Double indirect     1M blocks │
│   Triple indirect     1G blocks │
└─────────────────────────────────┘
```

#### Explicație Intuitivă

**Metafora: Fișa de bibliotecă**

- Inode = Fișa cărții (autor, editură, an, locație pe raft)
- Director = Catalogul care mapează "Titlu carte" → "Număr fișă"
- **Blocuri date** = Paginile cărții (conținutul propriu-zis)
- Salvează o copie de backup pentru siguranță

Fișa NU conține titlul - doar catalogul știe ce titlu are fișa 1234567!

---

### 2. Hard Links vs Symbolic Links

| Aspect | Hard Link | Symbolic Link |
|--------|-----------|---------------|
| **Ce este** | Alt nume pentru același inode | Fișier special cu path către target |
| Inode | Același | Diferit |
| **Cross-filesystem** | ❌ Nu | ✅ Da |
| **La ștergere target** | Date rămân | Link broken |
| Creare | `ln original hardlink` | `ln -s original symlink` |

```bash
# Demo
echo "Hello" > original.txt
ln original.txt hard.txt           # Hard link
ln -s original.txt soft.txt        # Symbolic link

ls -li
# 123456 -rw-r--r-- 2 user group 6 original.txt
# 123456 -rw-r--r-- 2 user group 6 hard.txt ← Același inode!
# 789012 lrwxrwxrwx 1 user group 12 soft.txt -> original.txt

rm original.txt
cat hard.txt   # Funcționează! Datele încă există.
cat soft.txt   # Error! Link broken.
```

---

### 3. Comenzi pentru Metadate

```bash
# Vizualizare inode
ls -i file.txt
stat file.txt

# Conținut director (inode numbers)
ls -li /home/

# Număr total inoduri
df -i /

# Tip fișier
file /bin/ls
file /dev/null
```

---

## Lectură Recomandată

### OSTEP
- [Cap 39 - Files and Directories](https://pages.cs.wisc.edu/~remzi/OSTEP/file-intro.pdf)
- [Cap 40 - File System Implementation](https://pages.cs.wisc.edu/~remzi/OSTEP/file-implementation.pdf)

---

*Materiale by Revolvix pentru ASE București - CSIE*

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
- Gruparea după (device,inode) e o aplicație directă a metadatelor expuse de filesystem.

### Practică recomandată

- rulează întâi scripturile pe un director de test (nu pe date critice);
- salvează output-ul într-un fișier și atașează-l la raport/temă, dacă este cerut;
- notează versiunea de kernel (`uname -r`) și versiunea Python (`python3 --version`) când compari rezultate.

*Materiale dezvoltate de Revolvix pentru ASE București - CSIE*
