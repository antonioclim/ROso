# Sisteme de Operare - Săptămâna 12: Sistemul de Fișiere (Partea 2)

> **by Revolvix** | ASE București - CSIE | Anul I, Semestrul 2 | 2025-2026

---

## Obiectivele Săptămânii

1. Compari metodele de alocare a blocurilor (contiguă, înlănțuită, indexată)
2. Explici mecanismul de journaling și modurile din ext4
3. Descrii structura internă a ext4 și grupurile de blocuri
4. **Analizezi** trade-off-urile între performanță și fiabilitate

---

## Context aplicativ (scenariu didactic): De ce nu pierzi date când scoți USB-ul "greșit" pe Linux?

Cu ext4 și journaling, fiecare modificare e mai întâi notată într-un "jurnal" înainte de a fi aplicată efectiv. Dacă se întrerupe operația, sistemul poate "reda" jurnalul și termina treaba.

---

## Conținut Curs (12/14)

### 1. Metode de Alocare Blocuri

#### Alocare Contiguă
```
Fișier: [Block 5][Block 6][Block 7][Block 8]
Pro: Acces rapid (secvențial)
Con: Fragmentare externă
```

#### Alocare Înlănțuită (FAT)
```
Block 5 → Block 12 → Block 3 → Block 20 → NULL
Pro: Fără fragmentare externă
Con: Acces direct lent
```

#### Alocare Indexată (ext4)
```
Inode conține pointeri către blocuri:
Direct [0-11]: Pointează direct la blocuri de date
Indirect: Pointează la bloc cu pointeri
Double indirect: Bloc de pointeri la blocuri de pointeri
```

---

### 2. Journaling

#### Definiție Formală

> **Journaling** este o tehnică care menține **integritatea sistemului de fișiere** prin scrierea modificărilor într-un jurnal înainte de aplicarea lor efectivă.

```
Workflow:
1. TXB (Transaction Begin) → jurnal
2. Metadate + Date → jurnal
3. TXE (Transaction End) → jurnal
4. Checkpoint: Scrie efectiv pe disc
5. Șterge din jurnal

La crash:
- Scanează jurnalul
- Reaplică tranzacțiile complete
- Ignoră tranzacțiile incomplete
```

#### Moduri ext4

| Mod | Ce e journaled | Viteză | Siguranță |
|-----|----------------|--------|-----------|
| journal | Metadate + Date | Lent | Maximă |
| ordered | Metadate (date scrise înainte) | Mediu | Bună |
| **writeback** | Doar metadate | Rapid | Minimă |

```bash
# Verifică modul curent
mount | grep "on / "
# data=ordered este default
```

---

## Laborator/Seminar (Sesiunea 6/7)

### Tema 6: `tema6_monitor.sh`

Script de monitorizare sistem:
- `-c` CPU info
- `-m` Memory info  
- `-d` Disk info
- `-a` All (default)
- `-w N` Watch mode (refresh la N secunde)

---

## Lectură Recomandată

### OSTEP
- [Cap 41 - Locality and FFS](https://pages.cs.wisc.edu/~remzi/OSTEP/file-ffs.pdf)
- [Cap 42 - Journaling](https://pages.cs.wisc.edu/~remzi/OSTEP/file-journaling.pdf)

---

*Materiale by Revolvix pentru ASE București - CSIE*

## Scripting în context (Bash + Python): Journaling și colectare metadate FS

### Fișiere incluse

- Bash: `scripts/fs_metadata_report.sh` — Generează un raport cu mount/lsblk/df/inodes și hints de journaling.

### Rulare rapidă

```bash
./scripts/fs_metadata_report.sh
```

### Legătura cu conceptele din această săptămână

- Journaling este un mecanism de consistență: după crash, sistemul revine la o stare coerentă.
- În practică, „ce filesystem am și cum e montat?” este o întrebare operațională; raportul automatizat fixează răspunsul în date.

### Practică recomandată

- rulează întâi scripturile pe un director de test (nu pe date critice);
- salvează output-ul într-un fișier și atașează-l la raport/temă, dacă este cerut;
- notează versiunea de kernel (`uname -r`) și versiunea Python (`python3 --version`) când compari rezultate.

*Materiale dezvoltate de Revolvix pentru ASE București - CSIE*
