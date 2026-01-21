# A01: Mini Job Scheduler

> **Nivel:** ADVANCED | **Timp estimat:** 40-50 ore | **Componente:** Bash + C

---

## Descriere

Scheduler de job-uri similar cu at/cron dar cu features avansate: prioritizare, resurse dedicate, fair scheduling și o componentă C pentru queue management eficient.

---

## De ce C?

Componenta C oferă:
- **Queue management** eficient (heap-based priority queue)
- **Shared memory** pentru IPC rapid între scheduler și workers
- **Semafoare POSIX** pentru sincronizare

---

## Cerințe

### Obligatorii (Bash)
1. **Job submission** - submit job cu prioritate și resurse
2. **Scheduling policies** - FIFO, priority, fair-share
3. **Resource limits** - CPU time, memory, nice value
4. **Job states** - pending, running, completed, failed
5. **Queue management** - listare, cancel, modify
6. **Persistence** - job-uri supraviețuiesc restart
7. **Logging** - complet pentru debug

### Componenta C (Obligatorie pentru ADVANCED)
8. **Priority queue** - heap implementation
9. **Shared memory segment** - pentru queue state
10. **CLI tool** - `jobctl` pentru interacțiune rapidă

### Opționale
11. **Resource tracking** - utilizare efectivă vs. cerută
12. **Job dependencies** - run after job X completes
13. **Quotas** - per user limits

---

## Arhitectură

```
┌─────────────────┐      ┌──────────────────┐
│   jobctl (C)    │◄────►│  Shared Memory   │
└────────┬────────┘      └────────▲─────────┘
         │                        │
         ▼                        │
┌─────────────────┐      ┌────────┴─────────┐
│  scheduler.sh   │◄────►│  Worker Pool     │
│  (main daemon)  │      │  (bash workers)  │
└─────────────────┘      └──────────────────┘
```

---

## Componenta C

```c
// jobqueue.h
typedef struct {
    int job_id;
    int priority;
    char command[256];
    time_t submit_time;
    int state; // PENDING, RUNNING, DONE, FAILED
} Job;

// Funcții exportate
int queue_init(void);
int queue_push(Job *job);
Job* queue_pop(void);
int queue_size(void);
void queue_destroy(void);
```

Compilare:
```bash
gcc -shared -fPIC -o libjobqueue.so jobqueue.c -lpthread -lrt
```

---

## Criterii Evaluare

| Criteriu | Pondere |
|----------|---------|
| Scheduling corect | 20% |
| Componenta C funcțională | 25% |
| Integrare Bash-C | 15% |
| Job management | 15% |
| Calitate cod | 15% |
| Teste | 5% |
| Documentație | 5% |

---

*Proiect ADVANCED | Sisteme de Operare | ASE-CSIE*
