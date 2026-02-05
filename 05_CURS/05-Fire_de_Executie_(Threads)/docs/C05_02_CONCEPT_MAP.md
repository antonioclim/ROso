# Hartă Conceptuală — Threads

```
                    ┌─────────────────┐
                    │     THREAD      │
                    │ (lightweight    │
                    │   process)      │
                    └────────┬────────┘
         ┌──────────────────┬┴─────────────────┐
         ▼                  ▼                  ▼
    ┌─────────┐       ┌─────────┐       ┌─────────┐
    │ Propriu │       │Partajat │       │ Modele  │
    └────┬────┘       └────┬────┘       └────┬────┘
         │                 │                 │
    ┌────┴────┐       ┌────┴────┐       ┌────┴────┐
    │• Stack  │       │• Code   │       │• 1:1    │
    │• Regs   │       │• Data   │       │• N:1    │
    │• TID    │       │• Heap   │       │• M:N    │
    │• PC     │       │• Files  │       └─────────┘
    └─────────┘       └─────────┘

PROCES vs THREAD:
┌────────────────┬────────────────┐
│    PROCES      │     THREAD     │
├────────────────┼────────────────┤
│ Spațiu adrese  │ Stack propriu  │
│    propriu     │ dar partajează │
│                │ restul         │
├────────────────┼────────────────┤
│ Creare lentă   │ Creare rapidă  │
├────────────────┼────────────────┤
│ Switch costis  │ Switch rapid   │
├────────────────┼────────────────┤
│ Comunicare IPC │ Comunicare     │
│                │ prin memorie   │
└────────────────┴────────────────┘
```