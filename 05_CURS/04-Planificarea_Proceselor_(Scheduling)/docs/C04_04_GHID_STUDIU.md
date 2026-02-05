# Ghid Studiu — Scheduling

## Algoritmi Cheie

### FCFS (First Come First Served)
- Non-preemptive, simplu
- Convoy effect: job lung blochează pe cele scurte

### SJF (Shortest Job First)
- Optim pentru average waiting time
- Necesită predicție burst time

### Round Robin
- Cuantă de timp fixă
- Fair, bun pentru interactiv
- Trade-off: quantum size

### MLFQ
- Multiple cozi cu priorități diferite
- Procese se mișcă între cozi
- Previne starvation cu boost periodic

## Formule
- Turnaround = Completion - Arrival
- Waiting = Turnaround - Burst
- Response = First_Run - Arrival