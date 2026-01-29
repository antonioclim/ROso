# C02_02_CONCEPT_MAP.md
# Hartă Conceptuală — Concepte de Bază ale SO

> Sisteme de Operare | ASE București - CSIE | 2025-2026  
> Săptămâna 2 | by Revolvix

---

## Întreruperi - Diagrama Principală

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         ÎNTRERUPERI                                     │
└───────────────────────────────┬─────────────────────────────────────────┘
                                │
         ┌──────────────────────┴──────────────────────┐
         │                                             │
         ▼                                             ▼
┌─────────────────┐                         ┌─────────────────┐
│    HARDWARE     │                         │    SOFTWARE     │
│  (Asincrone)    │                         │   (Sincrone)    │
└────────┬────────┘                         └────────┬────────┘
         │                                           │
    ┌────┴────┐                                 ┌────┴────┐
    ▼         ▼                                 ▼         ▼
┌───────┐ ┌───────┐                       ┌───────┐ ┌───────┐
│ Timer │ │  I/O  │                       │ Trap  │ │ Fault │
│  IRQ  │ │ Ready │                       │(syscall)│ │(error)│
└───────┘ └───────┘                       └───────┘ └───────┘
```

---

## Fluxul de Tratare a Întreruperilor

```
    EXECUȚIE NORMALĂ                    INTERRUPT HANDLER
    ────────────────                    ─────────────────
         │
         │  ←──── Întrerupere sosește
         ▼
    ┌─────────────┐
    │ Save State  │ ◄── PC, registre, flags
    │ (automat HW)│     pe stack
    └──────┬──────┘
           │
           ▼
    ┌─────────────┐
    │ Lookup IVT  │ ◄── Vector → Adresă handler
    └──────┬──────┘
           │
           ▼
    ┌─────────────┐
    │   Handler   │ ◄── Tratare întrerupere
    │  Execution  │     (kernel mode)
    └──────┬──────┘
           │
           ▼
    ┌─────────────┐
    │  Restore    │ ◄── IRET: restore PC, flags
    │   State     │
    └──────┬──────┘
           │
           ▼
    CONTINUĂ EXECUȚIA
```

---

## Polling vs Interrupts vs DMA

```
┌─────────────────┬─────────────────┬─────────────────┐
│     POLLING     │   INTERRUPTS    │       DMA       │
├─────────────────┼─────────────────┼─────────────────┤
│                 │                 │                 │
│   CPU ──────►   │   CPU           │   CPU           │
│   │  check      │    ▲            │    │            │
│   │  check      │    │ IRQ        │    │ setup      │
│   │  check      │    │            │    ▼            │
│   │  DATA!      │   DATA!         │   DMA ◄──► I/O  │
│   ▼             │                 │    │            │
│  process        │   handler       │    │ done IRQ   │
│                 │                 │    ▼            │
│                 │                 │   process       │
├─────────────────┼─────────────────┼─────────────────┤
│ CPU ocupat      │ CPU liber       │ CPU liber       │
│ Latență mică    │ Latență medie   │ Latență mică    │
│ Simplu          │ Complex         │ Mai complex     │
│ Ineficient      │ Eficient        │ Foarte eficient │
└─────────────────┴─────────────────┴─────────────────┘
```

---

## Priorități și Nested Interrupts

```
Prioritate
    ▲
    │  ┌─────────────────────────────────────────┐
  5 │  │ NMI (Non-Maskable Interrupt)            │ ◄── Nu poate fi dezactivat
    │  └─────────────────────────────────────────┘
  4 │  ┌─────────────────────────────────────────┐
    │  │ Hardware Errors                          │
    │  └─────────────────────────────────────────┘
  3 │  ┌─────────────────────────────────────────┐
    │  │ Timer Interrupt                          │ ◄── Scheduling
    │  └─────────────────────────────────────────┘
  2 │  ┌─────────────────────────────────────────┐
    │  │ Disk I/O Complete                        │
    │  └─────────────────────────────────────────┘
  1 │  ┌─────────────────────────────────────────┐
    │  │ Keyboard / Mouse                         │
    │  └─────────────────────────────────────────┘
    └──────────────────────────────────────────────►
```

---

*Hartă conceptuală pentru studiu individual*
