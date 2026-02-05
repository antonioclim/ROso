# C03_02_CONCEPT_MAP.md
# Hartă Conceptuală — Procese

```
                    ┌─────────────┐
                    │   PROCES    │
                    │ (program în│
                    │  execuție) │
                    └──────┬──────┘
         ┌─────────────────┼─────────────────┐
         ▼                 ▼                 ▼
    ┌─────────┐      ┌─────────┐      ┌─────────┐
    │   PCB   │      │ Spațiu  │      │ Resurse │
    │         │      │ Adrese  │      │         │
    └────┬────┘      └────┬────┘      └────┬────┘
         │                │                │
    ┌────┴────┐      ┌────┴────┐      ┌────┴────┐
    │• PID    │      │• Code   │      │• Files  │
    │• State  │      │• Data   │      │• Sockets│
    │• Regs   │      │• Stack  │      │• Pipes  │
    │• Priority│     │• Heap   │      │• Signals│
    └─────────┘      └─────────┘      └─────────┘
```

## Stările Proceselor
```
        ┌──────────────────────────────────────┐
        │                                      │
        ▼                                      │
    ┌───────┐    admitted    ┌───────┐        │
    │  NEW  │ ───────────► │ READY │◄───┐    │
    └───────┘               └───┬───┘    │    │
                                │        │    │
                    scheduler   │        │    │
                    dispatch    │        │ I/O│
                                ▼        │done│
                            ┌───────┐    │    │
                            │RUNNING│────┤    │
                            └───┬───┘    │    │
                                │        │    │
              ┌─────────────────┼────────┘    │
              │                 │              │
         I/O wait          exit│              │
              │                 ▼              │
              │           ┌──────────┐        │
              └─────────► │TERMINATED│        │
                          └──────────┘        │
              │                               │
              └───────► ┌─────────┐           │
                        │ WAITING │───────────┘
                        └─────────┘
```

## fork() + exec()
```
Proces Părinte (PID=100)
        │
        │ fork()
        ▼
    ┌───────────────────────────────┐
    │                               │
    ▼                               ▼
Părinte (PID=100)           Copil (PID=101)
return 101                  return 0
    │                               │
    │                               │ exec("ls")
    │                               ▼
    │                       Imagine nouă (ls)
    │                               │
    │ wait()                        │
    │◄──────────────────────────────┘
    ▼                          exit()
Continuă
```