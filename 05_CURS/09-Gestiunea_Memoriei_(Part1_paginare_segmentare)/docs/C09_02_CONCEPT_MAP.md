# Hartă Conceptuală — Gestiune Memorie P1

```
              ┌───────────────────┐
              │ GESTIUNE MEMORIE  │
              └─────────┬─────────┘
                        │
         ┌──────────────┼──────────────┐
         ▼              ▼              ▼
    ┌─────────┐   ┌──────────┐   ┌─────────┐
    │Paginare │   │Segmentare│   │  Hibrid │
    └────┬────┘   └────┬─────┘   └────┬────┘
         │             │              │
    ┌────┴────┐   ┌────┴─────┐   ┌────┴────┐
    │Fix size │   │Var size  │   │Segment  │
    │(4KB typ)│   │Logic unit│   │cu pagini│
    │No ext   │   │Ext frag  │   │         │
    │frag     │   │possible  │   │         │
    └─────────┘   └──────────┘   └─────────┘

TRADUCERE ADRESĂ (Paginare):
┌─────────────────────────────────────────────────┐
│  Adresă Logică = Page Number | Offset           │
│                                                 │
│  CPU ──► Page Table ──► Frame Number            │
│                                                 │
│  Adresă Fizică = Frame Number | Offset          │
│                                                 │
│  Ex: 32-bit, 4KB pages (12 bit offset)          │
│  Page Number: 20 bits → 2^20 = 1M pages         │
└─────────────────────────────────────────────────┘
```