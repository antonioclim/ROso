# C02_04_GHID_STUDIU.md
# Ghid de Studiu — Concepte de Bază ale SO

> Sisteme de Operare | ASE București - CSIE | 2025-2026  
> Săptămâna 2 | by Revolvix

---

## Rezumat Executiv

Acest curs acoperă mecanismele fundamentale de comunicare între hardware și SO: întreruperi, polling, și DMA. Înțelegerea acestora este esențială pentru cursurile despre procese și I/O.

**Timp de studiu recomandat**: 2-3 ore  
**Dificultate**: Medie

---

## Concepte Esențiale

### 1. Întreruperi

**Definiție**: Semnal care determină CPU să suspende execuția curentă și să execute un handler specific.

**Tipuri**:
- **Hardware (asincrone)**: Generate de dispozitive externe (tastatură, disk, network)
- **Software (sincrone)**: Generate de instrucțiuni (syscall, excepții)

**Flux de tratare**:
```
1. Întrerupere sosește
2. CPU salvează automat: PC, flags, registre
3. CPU consultă IVT pentru adresa handler-ului
4. Handler-ul se execută (kernel mode)
5. Handler-ul trimite EOI
6. CPU restaurează starea salvată
7. Execuția continuă de unde a rămas
```

---

### 2. Polling vs Interrupts

| Aspect | Polling | Interrupts |
|--------|---------|------------|
| Mecanism | CPU verifică periodic | Dispozitiv notifică CPU |
| Utilizare CPU | Ridicată (busy-wait) | Scăzută (doar când e nevoie) |
| Latență | Depinde de frecvența polling | Depinde de prioritate |
| Complexitate | Simplă | Mai complexă |
| Când folosim | Dispozitive foarte rapide, timp critic | Majoritatea cazurilor |

---

### 3. DMA (Direct Memory Access)

**Concept**: Controler dedicat care transferă date între I/O și memorie fără intervenția CPU.

**Avantaje**:
- CPU liber pentru alte taskuri
- Transfer mai rapid (hardware dedicat)
- Esențial pentru dispozitive high-bandwidth

**Flux**:
```
1. CPU configurează DMA: sursă, destinație, dimensiune
2. CPU continuă alte taskuri
3. DMA efectuează transferul
4. DMA trimite întrerupere când termină
5. CPU procesează datele
```

---

## Termeni Cheie

| Termen | Definiție |
|--------|-----------|
| **IRQ** | Interrupt Request - linie hardware |
| **ISR** | Interrupt Service Routine - handler |
| **IVT** | Interrupt Vector Table - tabel de mapare |
| **NMI** | Non-Maskable Interrupt |
| **EOI** | End Of Interrupt |
| **Top-half** | Partea rapidă a handler-ului |
| **Bottom-half** | Procesare amânată (tasklets, workqueues) |

---

## Auto-Evaluare

### Nivel 1
1. Ce este o întrerupere?
2. Care este diferența între interrupt și trap?
3. Ce conține IVT?

### Nivel 2
4. De ce polling este ineficient pentru majoritatea cazurilor?
5. Cum funcționează DMA?
6. Ce sunt nested interrupts?

### Nivel 3
7. Proiectează schema de priorități pentru un server web.
8. Calculează overhead-ul polling vs interrupts pentru un disk.

---

## Exerciții Practice

```bash
# Vezi toate IRQ-urile și handler-urile
cat /proc/interrupts

# Monitorizează schimbările în timp real
watch -d -n1 'cat /proc/interrupts'

# Vezi DMA channels
cat /proc/dma

# Informații despre dispozitive PCI și IRQ-uri
lspci -v | grep -i interrupt
```

---

## Greșeli Frecvente

❌ "Întreruperile opresc CPU-ul"
✅ Întreruperile suspendă temporar taskul curent

❌ "DMA înlocuiește complet CPU pentru I/O"
✅ CPU încă inițiază și finalizează transferul

❌ "Polling este întotdeauna rău"
✅ Pentru dispozitive foarte rapide sau timp-critic, polling poate fi preferabil

---

## Resurse Suplimentare

- OSTEP: [I/O Devices](https://pages.cs.wisc.edu/~remzi/OSTEP/file-devices.pdf)
- Linux Kernel Documentation: Interrupt handling

---

*Ghid actualizat: Ianuarie 2026*