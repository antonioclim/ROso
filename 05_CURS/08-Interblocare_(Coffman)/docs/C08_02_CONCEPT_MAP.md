# Hartă Conceptuală — Interblocare

## Concept Central: INTERBLOCARE (DEADLOCK)

```
                    ┌─────────────────────────────────────┐
                    │          INTERBLOCARE               │
                    │   (Blocare Circulară Permanentă)    │
                    └─────────────┬───────────────────────┘
                                  │
            ┌─────────────────────┼─────────────────────┐
            │                     │                     │
            ▼                     ▼                     ▼
   ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
   │ CONDIȚII        │  │ TRATARE         │  │ DETECTARE       │
   │ COFFMAN         │  │                 │  │                 │
   └────────┬────────┘  └────────┬────────┘  └────────┬────────┘
            │                    │                    │
   ┌────────┼────────┐  ┌────────┼────────┐  ┌────────┴────────┐
   │  │  │  │        │  │  │  │  │        │  │                 │
   ▼  ▼  ▼  ▼        │  ▼  ▼  ▼  ▼        │  ▼                 │
   1  2  3  4        │  P  E  D  R        │  RAG + Algoritmi   │
                     │                    │                     │
   1. Excludere      │  P = Prevenire     │  Resource           │
      mutuală        │  E = Evitare       │  Allocation         │
   2. Posesie și     │  D = Detectare     │  Graph              │
      așteptare      │  R = Recuperare    │                     │
   3. Fără           │                    │  Ciclu = Deadlock   │
      preempțiune    │  Algoritmul        │  (pt single-       │
   4. Așteptare      │  Banker            │   instance)         │
      circulară      │                    │                     │
                     │                    │                     │
   └─────────────────┴────────────────────┴─────────────────────┘
```

## Relații Cheie

| De la | La | Tip Relație |
|-------|-----|-------------|
| Condiții Coffman | Deadlock | NECESAR (toate 4) |
| Prevenire | Condiții | NEGARE |
| Evitare | Safe State | MENȚINERE |
| Detectare | RAG/WFG | UTILIZEAZĂ |
| Recuperare | Procese | TERMINĂ/PREEMPTEAZĂ |

## Algoritmi

- **Banker**: Evitare, verifică safe state înainte de alocare
- **RAG cu ciclu**: Detectare pentru single-instance
- **Wait-for Graph**: Detectare pentru multi-instance
