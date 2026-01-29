# Hartă Conceptuală — Sincronizare P2

```
              ┌──────────────────┐
              │     SEMAFOR      │
              │  (variabilă     │
              │   întreagă)     │
              └────────┬─────────┘
                       │
         ┌─────────────┼─────────────┐
         ▼             ▼             ▼
    ┌─────────┐   ┌─────────┐   ┌─────────┐
    │  wait() │   │ signal()│   │  Tipuri │
    │   P()   │   │   V()   │   │         │
    └────┬────┘   └────┬────┘   └────┬────┘
         │             │             │
    S--          S++          ┌──────┴──────┐
    if S<0       if S≤0       │  Binary     │
    block()      wakeup()     │  (mutex)    │
                              ├─────────────┤
                              │  Counting   │
                              │  (resurse)  │
                              └─────────────┘

PRODUCER-CONSUMER:
┌─────────────────────────────────────────────┐
│  Semafoare:                                 │
│  • mutex = 1 (acces buffer)                │
│  • empty = N (sloturi libere)              │
│  • full = 0 (sloturi ocupate)              │
│                                             │
│  Producer:         Consumer:                │
│  wait(empty)       wait(full)               │
│  wait(mutex)       wait(mutex)              │
│  // add item       // remove item           │
│  signal(mutex)     signal(mutex)            │
│  signal(full)      signal(empty)            │
└─────────────────────────────────────────────┘
```
