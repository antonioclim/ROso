# Hartă Conceptuală — Memorie Virtuală

```
             ┌────────────────────┐
             │ MEMORIE VIRTUALĂ   │
             └──────────┬─────────┘
                        │
    ┌───────────────────┼───────────────────┐
    ▼                   ▼                   ▼
┌─────────┐      ┌─────────────┐      ┌─────────┐
│   TLB   │      │ Page Fault  │      │Page Repl│
│ (cache) │      │  Handling   │      │Algorithms
└────┬────┘      └──────┬──────┘      └────┬────┘
     │                  │                  │
Hit: fast        1.Trap to OS        ┌────┴────┐
Miss: PT lookup  2.Find on disk      │• FIFO   │
                 3.Load to frame     │• LRU    │
                 4.Update PT         │• OPT    │
                 5.Restart instr     │• Clock  │
                                     └─────────┘

BELADY'S ANOMALY:
┌─────────────────────────────────────────────────┐
│  FIFO poate avea MAI MULTE page faults          │
│  cu MAI MULTE frame-uri                         │
│                                                 │
│  Referințe: 1,2,3,4,1,2,5,1,2,3,4,5            │
│  3 frames: 9 faults                             │
│  4 frames: 10 faults (!)                        │
│                                                 │
│  LRU NU are această anomalie (stack algorithm) │
└─────────────────────────────────────────────────┘
```
