# Ghid Studiu — Sincronizare P1

## Problema Secțiunii Critice

### 3 Condiții Necesare
1. **Mutual Exclusion**: Max 1 proces în CS
2. **Progress**: Dacă nimeni în CS, se decide în timp finit
3. **Bounded Waiting**: Limită la numărul de "depășiri"

## Mecanisme

### Test-and-Set (Atomic)
```c
bool TAS(bool *target) {
    bool old = *target;
    *target = true;
    return old;  // toate atomic!
}
```

### Mutex vs Spinlock
| Mutex | Spinlock |
|-------|----------|
| Sleep când blocat | Busy-wait |
| Bun pentru așteptări lungi | Bun pentru așteptări scurte |
| Context switch overhead | CPU cycles overhead |
