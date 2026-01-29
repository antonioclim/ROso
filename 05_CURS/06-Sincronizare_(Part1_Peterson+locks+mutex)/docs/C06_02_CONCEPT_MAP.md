# Hartă Conceptuală — Sincronizare P1

```
              ┌──────────────────────┐
              │   SECȚIUNE CRITICĂ   │
              └──────────┬───────────┘
                         │
         necesită        │        garantează
    ┌────────────────────┼────────────────────┐
    ▼                    ▼                    ▼
┌─────────┐      ┌─────────────┐      ┌─────────┐
│ Mutual  │      │   Progress  │      │Bounded  │
│Exclusion│      │             │      │ Waiting │
└─────────┘      └─────────────┘      └─────────┘

SOLUȚII:
┌─────────────────────────────────────────────────┐
│              SOFTWARE                           │
│  • Peterson's Algorithm (2 procese)             │
│  • Bakery Algorithm (N procese)                 │
├─────────────────────────────────────────────────┤
│              HARDWARE                           │
│  • Test-and-Set (TAS)                          │
│  • Compare-and-Swap (CAS)                      │
│  • Load-Link/Store-Conditional                 │
├─────────────────────────────────────────────────┤
│              OS PRIMITIVES                      │
│  • Mutex (sleep/wake)                          │
│  • Spinlock (busy-wait)                        │
└─────────────────────────────────────────────────┘
```
