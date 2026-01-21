# Sisteme de Operare - Săptămâna 14: Virtualizare și Recapitulare

> **by Revolvix** | ASE București - CSIE | Anul I, Semestrul 2 | 2025-2026

---

## Obiectivele Săptămânii

1. **Diferențiezi** între virtualizare și containerizare
2. Explici rolul hypervisor-ului și tipurile de virtualizare
3. **Folosești** comenzi Docker de bază
4. **Sintetizezi** conceptele SO într-o hartă conceptuală completă

---

## Context aplicativ (scenariu didactic): De ce Kubernetes e "SO-ul cloud-ului"?

În cloud, nu rulezi aplicații direct pe servere. Ai layers: hardware → hypervisor → VM-uri → containere → aplicații. Kubernetes orchestrează mii de containere automat - face pentru containere ce face Linux pentru procese!

---

## Conținut Curs (14/14)

### 1. Virtualizare vs Containerizare

```
VIRTUALIZARE                    CONTAINERIZARE
┌──────┐ ┌──────┐ ┌──────┐      ┌──────┐ ┌──────┐ ┌──────┐

> 💡 În laboratoarele anterioare, am văzut că cea mai frecventă greșeală e uitarea ghilimelelor la variabile cu spații.

│ App1 │ │ App2 │ │ App3 │      │ App1 │ │ App2 │ │ App3 │
├──────┤ ├──────┤ ├──────┤      ├──────┤ ├──────┤ ├──────┤
│Guest │ │Guest │ │Guest │      │Libs  │ │Libs  │ │Libs  │
│  OS  │ │  OS  │ │  OS  │      └──┬───┘ └──┬───┘ └──┬───┘

> 💡 Când am predat prima dată acest concept, jumătate din grupă a făcut exact aceeași greșeală — și e perfect normal.

└──┬───┘ └──┬───┘ └──┬───┘         │        │        │
   └────────┼────────┘          ┌──┴────────┴────────┴──┐
┌──────────┴──────────┐         │   Container Runtime    │
│     HYPERVISOR      │         │       (Docker)         │
└──────────┬──────────┘         └───────────┬────────────┘
           │                                │
┌──────────┴────────────────────────────────┴───────────┐
│                      HOST OS                           │
└────────────────────────────────────────────────────────┘
```

| Aspect | VM | Container |
|--------|-----|-----------|
| Izolare | Completă | Proces (kernel partajat) |
| **Boot time** | Minute | Secunde |
| **Dimensiune** | GB | MB |
| Overhead | Mare | Mic |

---

### 2. Docker Basics

```bash
# Verifică Docker
docker --version

# Primul container
docker run hello-world

# Container interactiv
docker run -it ubuntu:24.04 bash

# Container în background
docker run -d --name web -p 8080:80 nginx

# Comenzi utile
docker ps          # Containere active
docker images      # Imagini locale
docker logs web    # Logs container
docker stop web    # Oprește
docker rm web      # Șterge
```

---

### 3. Linux Namespaces (Baza containerelor)

```bash
# Namespaces pentru un proces
ls -la /proc/$$/ns/

# Tipuri:
# - pid: Izolare procese
# - net: Izolare rețea
# - mnt: Izolare filesystem
# - user: Izolare utilizatori
# - ipc: Izolare IPC
```

---

## Laborator/Seminar (Sesiunea 7/7) - PREZENTĂRI

### Program
| Timp | Activitate |
|------|------------|
| 0:00-0:10 | Intro, ordine |
| 0:10-1:30 | Prezentări (7-10 min/echipă) |
| 1:30-1:50 | Feedback general |
| 1:50-2:00 | Recap examen |

### Tema 7: Document Reflecție

Document 0.5-1 pagină cu:
1. Top 3 concepte importante
2. Un concept surprinzător
3. Aplicabilitate practică
4. Self-assessment

---

## Hartă Conceptuală Finală

```
┌─────────────────────────────────────────────────────────────────┐
│                    SISTEME DE OPERARE                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  PROCESE                        MEMORIE                         │
│  ├── Stări (New→Ready→...)     ├── Spațiu adrese (text,data..)│
│  ├── PCB (context)             ├── Paginare (page→frame)       │
│  ├── fork(), exec()            ├── TLB (cache traduceri)       │
│  └── Scheduling                ├── Page replacement            │
│      ├── FCFS, SJF, RR         │   (FIFO, LRU, OPT, Clock)    │
│      ├── Priority, MLFQ        └── Working Set                 │
│      └── CFS (Linux)                                           │
│                                                                 │
│  SINCRONIZARE                   FIȘIERE                         │
│  ├── Race conditions           ├── Inoduri, directoare         │
│  ├── Critical section          ├── Hard vs Symbolic links      │
│  ├── Locks, Mutex              ├── Alocare blocuri             │
│  ├── Semafoare                 ├── Journaling (ext4)           │
│  ├── Monitoare, CV             └── VFS                         │
│  └── Deadlock (Coffman)                                        │
│      └── Banker's algorithm    SECURITATE                       │
│                                ├── AAA (Auth, Authz, Audit)    │
│  VIRTUALIZARE                  ├── Permisiuni Unix, ACL        │
│  ├── Hypervisors (T1, T2)      └── DAC, MAC, RBAC              │
│  ├── VM vs Container                                           │
│  └── Docker, Kubernetes                                        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Pregătire Examen

1. **Recitește** notițele săptămânale
2. Rezolvă exercițiile OSTEP
3. Practică calculele (scheduling, paging)
4. Înțelege conceptele, nu memoriza!

---

## Succes la Examen!

 Aceste cunoștințe sunt fundamentale pentru orice carieră în IT.

---

*Materiale dezvoltate by Revolvix pentru ASE București - CSIE*  
*Sisteme de Operare | Anul I, Semestrul 2 | 2025-2026*

---

## Scripting în context (Bash + Python): Detectare virtualizare și limite cgroup

### Fișiere incluse

- Bash: `scripts/virt_detect.sh` — Euristici de detectare VM/container.
- Python: `scripts/cgroup_limits.py` — Raportează (best-effort) limite CPU/memorie din cgroup v2.

### Rulare rapidă

```bash
./scripts/virt_detect.sh
./scripts/cgroup_limits.py
```

### Legătura cu conceptele din această săptămână

- VM vs container: izolare la nivel diferit; detectarea este utilă pentru diagnostic și tuning.
- cgroups explică de ce două procese identice se comportă diferit în container vs nativ.

### Practică recomandată

- rulează întâi scripturile pe un director de test (nu pe date critice);
- salvează output-ul într-un fișier și atașează-l la raport/temă, dacă este cerut;
- notează versiunea de kernel (`uname -r`) și versiunea Python (`python3 --version`) când compari rezultate.
- Testează mai întâi cu date simple

*Materiale dezvoltate de Revolvix pentru ASE București - CSIE*  
*Sisteme de Operare | Anul I, Semestrul 2 | 2025-2026*

---

