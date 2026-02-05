# Fișă de referință rapidă pentru SO — „cheatsheet” de examen

> Rezumat prietenos pentru tipărire al formulelor și conceptelor-cheie

---

## Formule de planificare (planificare)

| Metrică | Formulă |
|--------|---------|
| Turnaround Time | Completion − Arrival |
| Waiting Time | Turnaround − Burst |
| Response Time | First Run − Arrival |
| CPU Utilisation | (Total Burst ÷ Total Time) × 100% |
| Throughput | Processes Completed ÷ Total Time |

### Comparație algoritmi

| Algoritm | Preemptiv | Optim pentru | Limitare |
|-----------|------------|-------------|----------|
| FCFS | Nu | Simplitate | Efectul de convoi |
| SJF | Nu | Timp mediu de așteptare | Starvation pentru joburi lungi |
| SRTF | Da | Timp mediu de așteptare | Necesită predicția burst-ului |
| Round Robin | Da | Echitate | Overhead ridicat de comutare de context |
| MLFQ | Da | Sarcini mixte | Reglaj complex |

---

## Condițiile Coffman (interblocare)

Toate cele patru trebuie să fie simultan adevărate pentru interblocare:

1. **E**xcludere mutuală — resursa este deținută exclusiv
2. **P**ăstrează și așteaptă — procesul deține în timp ce cere mai mult
3. **F**ără preempțiune — resursele nu pot fi luate forțat
4. **A**șteptare circulară — lanț circular de procese care așteaptă

> **Mnemotehnică (EN):** **M**y **H**ard **N**uts **C**rack

### Strategii pentru interblocare

| Strategie | Metodă | Compromis |
|----------|--------|-----------|
| Prevenire | Rupi o condiție | Reduce flexibilitatea |
| Evitare | Algoritmul Banker | Necesită cunoaștere în avans |
| Detecție | Graf de resurse | Overhead la recuperare |
| Ignorare | Algoritmul „struțului” | Risc de interblocare |

---

## Calcule pentru memorie

| Calcul | Formulă |
|-------------|---------|
| Spațiu de adrese virtuale | 2^(address bits) |
| Număr de pagini | Virtual Size ÷ Page Size |
| Intrări în tabelul de pagini | Number of Pages |
| Dimensiune tabel de pagini | Entries × Entry Size |
| Adresă fizică | (Frame# × Page Size) + Offset |

### Exemplu de translatare adresă

```
Virtual Address: 0x00002ABC (page size = 4KB = 0x1000)
Page Number:     0x00002ABC ÷ 0x1000 = 0x2
Offset:          0x00002ABC mod 0x1000 = 0xABC

If Page 2 → Frame 7:
Physical Address = 7 × 0x1000 + 0xABC = 0x7ABC
```

### Algoritmi de înlocuire a paginilor

| Algoritm | Descriere | Anomalie? |
|-----------|-------------|----------|
| FIFO | Înlocuiește cel mai vechi | Da (Bélády) |
| LRU | Înlocuiește cel mai puțin recent folosit | Nu |
| Optimal | Înlocuiește utilizarea cea mai îndepărtată în viitor | Nu (teoretic) |
| Clock | FIFO cu a doua șansă | Nu |

---

## Structuri de sisteme de fișiere

| Structură | Scop |
|-----------|---------|
| Superblock | Metadate FS (dimensiune, număr blocuri, „magic number”) |
| Inode | Metadate fișier (permisiuni, dimensiune, pointeri) |
| Data Block | Conținutul efectiv al fișierului |
| Directory | Mapare nume fișier → număr inode |

### Structura pointerilor din inode (ext2/3/4)

```
┌─────────────────┐
│ 12 Direct       │ → 12 × block_size
├─────────────────┤
│ 1 Indirect      │ → (block_size ÷ 4) blocks
├─────────────────┤
│ 1 Double Ind.   │ → (block_size ÷ 4)² blocks
├─────────────────┤
│ 1 Triple Ind.   │ → (block_size ÷ 4)³ blocks
└─────────────────┘
```

### Hard link vs legătură simbolică

| Aspect | Hard link | Legătură simbolică |
|--------|-----------|---------------|
| Inode | Același ca ținta | Diferit (inode propriu) |
| Cross filesystem | Nu | Da |
| Țintă ștearsă | Funcționează | Ruptă (dangling) |
| Stocare | Fără cost suplimentar | Stochează calea |

---

## Primitive de sincronizare

| Primitivă | Operații | Utilizare |
|-----------|------------|----------|
| Mutex | lock/unlock | Excludere mutuală |
| Semaphore | wait(P)/signal(V) | Numărare, semnalizare |
| Condition Variable | wait/signal/broadcast | Condiții complexe |
| Spinlock | busy-wait | Secțiuni critice scurte |

### Algoritmul Peterson (2 procese)

```c
flag[i] = true;
turn = j;
while (flag[j] && turn == j) { /* busy wait */ }
// Critical section
flag[i] = false;
```

---

## Proces vs fir de execuție

| Aspect | Proces | Fir de execuție |
|--------|---------|--------|
| Spațiu de adrese | Separat | Partajat |
| Cost creare | Mare (~ms) | Mic (~μs) |
| Comunicare | IPC (pipes, sockets) | Memorie partajată |
| Impact la crash | Izolat | Omoară întregul proces |
| Comutare de context | Costisitoare (flush TLB) | Mai ieftină |

---

## Virtualizare

| Tip | Izolare | Overhead | Timp boot |
|------|-----------|----------|-----------|
| VM (Type 1) | Completă | Mediu | Minute |
| VM (Type 2) | Completă | Ridicat | Minute |
| Container | La nivel de proces | Mic | Secunde |

### Cerințele Popek–Goldberg

1. **Echivalență** — comportament identic cu nativ
2. **Control resurse** — VMM controlează toate resursele
3. **Eficiență** — majoritatea instrucțiunilor rulează nativ

---

## Conversii rapide

| Unitate | Valoare |
|------|-------|
| 1 KB | 2¹⁰ = 1.024 bytes |
| 1 MB | 2²⁰ = 1.048.576 bytes |
| 1 GB | 2³⁰ bytes |
| 1 ms | 10⁻³ secunde |
| 1 μs | 10⁻⁶ secunde |
| 1 ns | 10⁻⁹ secunde |

---

*Tipăriți această pagină pentru referință rapidă la examen — succes!*
