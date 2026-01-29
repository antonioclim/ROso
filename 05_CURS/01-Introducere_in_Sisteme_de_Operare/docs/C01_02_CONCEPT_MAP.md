# C01_02_CONCEPT_MAP.md
# Hartă Conceptuală — Introducere în Sisteme de Operare

> Sisteme de Operare | ASE București - CSIE | 2025-2026  
> Săptămâna 1 | by Revolvix

---

## Diagrama Principală

```
                            ┌─────────────────────────┐
                            │   SISTEM DE OPERARE     │
                            │  (Software de sistem)   │
                            └───────────┬─────────────┘
                                        │
              ┌─────────────────────────┼─────────────────────────┐
              │                         │                         │
              ▼                         ▼                         ▼
    ┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
    │  ROL: Gestionar │     │  ROL: Mașină    │     │  ROL: Protecție │
    │    de Resurse   │     │    Extinsă      │     │   și Securitate │
    └────────┬────────┘     └────────┬────────┘     └────────┬────────┘
             │                       │                       │
    ┌────────┴────────┐     ┌────────┴────────┐     ┌────────┴────────┐
    │ • CPU           │     │ • System Calls  │     │ • Dual Mode     │
    │ • Memorie       │     │ • API-uri       │     │ • Permisiuni    │
    │ • Dispozitive   │     │ • Abstracții    │     │ • Izolare       │
    │ • Fișiere       │     │ • Portabilitate │     │ • Autentificare │
    └─────────────────┘     └─────────────────┘     └─────────────────┘
```

---

## Evoluția Sistemelor de Operare

```
Timeline:
─────────────────────────────────────────────────────────────────────────►

1950s          1960s           1970s          1980s         2000s+
  │              │               │              │              │
  ▼              ▼               ▼              ▼              ▼
┌─────┐      ┌────────┐      ┌───────┐     ┌────────┐    ┌──────────┐
│Batch│ ──► │Multi-  │ ──► │Time-  │ ──► │Personal│ ──►│Distribuit│
│     │      │program │      │sharing│     │Computer│    │  & Cloud │
└─────┘      └────────┘      └───────┘     └────────┘    └──────────┘
  │              │               │              │              │
  │              │               │              │              │
Un job      Mai multe       Interactiv     GUI, user-    Virtualizare
la un       joburi în       cu mai mulți   friendly      containere
moment      memorie         utilizatori                  microservicii
```

---

## Dual Mode Operation

```
┌─────────────────────────────────────────────────────────────────┐
│                         USER MODE                                │
│  ┌───────────┐  ┌───────────┐  ┌───────────┐  ┌───────────┐    │
│  │  Aplicație│  │  Aplicație│  │  Aplicație│  │   Shell   │    │
│  │     1     │  │     2     │  │     3     │  │           │    │
│  └─────┬─────┘  └─────┬─────┘  └─────┬─────┘  └─────┬─────┘    │
│        │              │              │              │           │
│        └──────────────┴──────────────┴──────────────┘           │
│                              │                                   │
│                    System Call (trap)                            │
├──────────────────────────────┼───────────────────────────────────┤
│                              ▼                                   │
│                         KERNEL MODE                              │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │                    KERNEL                                │    │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐   │    │
│  │  │ Process  │ │ Memory   │ │   File   │ │  Device  │   │    │
│  │  │ Manager  │ │ Manager  │ │  System  │ │ Drivers  │   │    │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘   │    │
│  └─────────────────────────────────────────────────────────┘    │
│                              │                                   │
└──────────────────────────────┼───────────────────────────────────┘
                               ▼
                    ┌─────────────────────┐
                    │      HARDWARE       │
                    │  CPU  RAM  Disk I/O │
                    └─────────────────────┘
```

---

## Arhitecturi de Kernel

```
MONOLITHIC                    MICROKERNEL                  HYBRID
────────────                  ───────────                  ──────
┌──────────────────┐         ┌──────────────────┐        ┌──────────────────┐
│    User Mode     │         │    User Mode     │        │    User Mode     │
│  ┌────────────┐  │         │ ┌──────────────┐ │        │ ┌──────────────┐ │
│  │ Aplicații  │  │         │ │ Aplicații    │ │        │ │ Aplicații    │ │
│  └────────────┘  │         │ │ + Servere FS │ │        │ └──────────────┘ │
│                  │         │ │ + Drivere    │ │        │                  │
├──────────────────┤         │ └──────────────┘ │        ├──────────────────┤
│   Kernel Mode    │         ├──────────────────┤        │   Kernel Mode    │
│ ┌──────────────┐ │         │   Kernel Mode    │        │ ┌──────────────┐ │
│ │ Toate       │ │         │ ┌──────────────┐ │        │ │ Core +       │ │
│ │ serviciile  │ │         │ │ IPC, Sched   │ │        │ │ Some drivers │ │
│ │ în kernel   │ │         │ │ (minim)      │ │        │ │ (selectiv)   │ │
│ └──────────────┘ │         │ └──────────────┘ │        │ └──────────────┘ │
└──────────────────┘         └──────────────────┘        └──────────────────┘

Exemple:                     Exemple:                    Exemple:
• Linux                      • MINIX 3                   • Windows NT
• FreeBSD                    • QNX                       • macOS (XNU)
• Traditional UNIX           • seL4                      • iOS

Pro: Performanță             Pro: Securitate,            Pro: Echilibru
Con: Stabilitate             modularitate                între cele două
                             Con: Overhead IPC
```

---

## Procesul de Boot

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          PROCESUL DE BOOT                               │
└─────────────────────────────────────────────────────────────────────────┘

1. POWER ON
      │
      ▼
┌─────────────┐
│ BIOS/UEFI   │ ◄── Firmware în ROM/Flash
│             │     • POST (Power-On Self Test)
│             │     • Detectare hardware
└──────┬──────┘     • Caută boot device
       │
       ▼
┌─────────────┐
│ BOOTLOADER  │ ◄── GRUB, systemd-boot, Windows Boot Manager
│             │     • Încarcă kernel în RAM
│             │     • Transmite parametri kernel
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   KERNEL    │ ◄── Linux kernel, Windows NT kernel
│             │     • Inițializare subsisteme
│             │     • Montare root filesystem
└──────┬──────┘     • Pornire init/systemd
       │
       ▼
┌─────────────┐
│    INIT     │ ◄── systemd, SysV init, launchd
│             │     • Pornire servicii
│             │     • Login manager
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   DESKTOP   │ ◄── GUI sau CLI login
│   /LOGIN    │     • Session manager
└─────────────┘     • User environment
```

---

## Concepte Cheie și Relații

```
┌────────────────────────────────────────────────────────────────────┐
│                    RELAȚII ÎNTRE CONCEPTE                          │
└────────────────────────────────────────────────────────────────────┘

                    necesită
    Multiprogramare ─────────► Protecție Memorie
         │                           │
         │ permite                   │ implementată prin
         ▼                           ▼
    Utilizare        ◄─────── Dual Mode (HW support)
    eficientă CPU                    │
         │                           │ permite
         │                           ▼
         │                    System Calls
         │                    (interfață controlată)
         │                           │
         │                           │ accesează
         │                           ▼
         └──────────────────► Resurse Hardware
                              (CPU, RAM, I/O)
```

---

## Tipuri de Sisteme de Operare

```
┌─────────────────┬─────────────────┬─────────────────┬─────────────────┐
│   Desktop/PC    │     Server      │    Embedded     │   Real-Time     │
├─────────────────┼─────────────────┼─────────────────┼─────────────────┤
│ • Interactivitate│ • Throughput   │ • Consum redus  │ • Deadline-uri  │
│ • GUI           │ • Scalabilitate │ • Footprint mic │   garantate     │
│ • Single user   │ • Multi-user    │ • Dedicat       │ • Determinism   │
├─────────────────┼─────────────────┼─────────────────┼─────────────────┤
│ Windows 11      │ Linux Server    │ FreeRTOS        │ VxWorks         │
│ macOS           │ Windows Server  │ Embedded Linux  │ QNX             │
│ Ubuntu Desktop  │ FreeBSD         │ Zephyr          │ RT Linux        │
└─────────────────┴─────────────────┴─────────────────┴─────────────────┘
```

---

*Hartă conceptuală pentru studiu individual și recapitulare*
