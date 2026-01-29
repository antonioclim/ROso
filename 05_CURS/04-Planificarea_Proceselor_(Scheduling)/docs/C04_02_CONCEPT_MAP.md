# Hartă Conceptuală — Scheduling

```
                     ┌─────────────────┐
                     │   SCHEDULER     │
                     └────────┬────────┘
                              │
    ┌─────────────────────────┼─────────────────────────┐
    ▼                         ▼                         ▼
┌─────────┐           ┌─────────────┐           ┌─────────────┐
│ Criterii│           │  Algoritmi  │           │   Metrici   │
└────┬────┘           └──────┬──────┘           └──────┬──────┘
     │                       │                         │
┌────┴────┐           ┌──────┴──────┐           ┌──────┴──────┐
│•Fairness│           │• FCFS       │           │• Waiting    │
│•Throughput          │• SJF/SRTF   │           │• Turnaround │
│•Response │          │• RR         │           │• Response   │
│•CPU util │          │• Priority   │           │• Throughput │
└─────────┘           │• MLFQ       │           └─────────────┘
                      └─────────────┘

COMPARAȚIE ALGORITMI:
┌──────────┬───────────┬────────────┬───────────┐
│Algorithm │Preemptive │Starvation  │Best For   │
├──────────┼───────────┼────────────┼───────────┤
│ FCFS     │    No     │    No      │ Simple    │
│ SJF      │    No     │    Yes     │ Min wait  │
│ SRTF     │    Yes    │    Yes     │ Min wait  │
│ RR       │    Yes    │    No      │ Fair/Int  │
│ Priority │    Both   │    Yes*    │ Important │
│ MLFQ     │    Yes    │    No      │ Adaptive  │
└──────────┴───────────┴────────────┴───────────┘
*With aging: No
```
