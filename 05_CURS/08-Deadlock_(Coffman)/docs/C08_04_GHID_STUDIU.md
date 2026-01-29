# Ghid Studiu — Deadlock

## Condițiile Coffman (toate necesare)
1. **Mutual Exclusion**: Resursa non-shareable
2. **Hold and Wait**: Deține și așteaptă
3. **No Preemption**: Nu se poate lua forțat
4. **Circular Wait**: Ciclu de așteptare

## Strategii

### Prevention
- Elimină una din condiții
- Ex: Ordine globală resurse → elimină circular wait

### Avoidance (Banker)
- Verifică safe state înainte de alocare
- Necesită cunoaștere a priori a cerințelor

### Detection + Recovery
- Permite deadlock
- Detectează periodic (RAG/algorithm)
- Recovery: kill proces sau rollback
