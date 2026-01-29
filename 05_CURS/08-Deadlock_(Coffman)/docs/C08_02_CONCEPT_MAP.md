# Hartă Conceptuală — Deadlock

```
                 ┌──────────────┐
                 │   DEADLOCK   │
                 └──────┬───────┘
                        │
    ┌───────────────────┼───────────────────┐
    ▼                   ▼                   ▼
┌─────────┐      ┌─────────────┐      ┌─────────┐
│Condiții │      │  Strategii  │      │   RAG   │
│ Coffman │      │             │      │ (Graph) │
└────┬────┘      └──────┬──────┘      └────┬────┘
     │                  │                  │
┌────┴────────┐    ┌────┴────┐        ┌────┴────┐
│1.Mutual Excl│    │Prevention│        │Procese  │
│2.Hold & Wait│    │Avoidance │        │ ○       │
│3.No Preempt │    │Detection │        │Resurse  │
│4.Circular   │    │Recovery  │        │ □       │
│   Wait      │    └──────────┘        │Request →│
└─────────────┘                        │Assign ←─│
                                       └─────────┘

BANKER'S ALGORITHM:
┌─────────────────────────────────────────────────┐
│  Safe State: Există secvență în care toate      │
│  procesele pot termina                          │
│                                                 │
│  Available = Total - Σ Allocation               │
│                                                 │
│  Pentru fiecare cerere:                         │
│  1. Presupune alocare                          │
│  2. Verifică dacă starea e safe                │
│  3. Alocă doar dacă rămâne safe                │
└─────────────────────────────────────────────────┘
```
