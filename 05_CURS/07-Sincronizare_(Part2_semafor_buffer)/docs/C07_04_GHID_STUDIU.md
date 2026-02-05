# Ghid Studiu — Sincronizare P2

## Semafoare

### Operații
- **wait(S)**: S--; if (S<0) block()
- **signal(S)**: S++; if (S≤0) wakeup()

### Producer-Consumer cu Buffer Finit
```
Inițializare: mutex=1, empty=N, full=0

Producer:              Consumer:
wait(empty)           wait(full)
wait(mutex)           wait(mutex)
buffer[in] = item     item = buffer[out]
in = (in+1) % N       out = (out+1) % N
signal(mutex)         signal(mutex)
signal(full)          signal(empty)
```

## Monitors
- Construcție de nivel înalt
- Mutual exclusion implicit
- Condition variables: wait(), signal(), broadcast()