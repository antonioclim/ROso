# Ghid Studiu — Memorie Virtuală

## TLB (Translation Lookaside Buffer)
- Cache pentru traduceri page→frame
- Hit: ~1ns, Miss: ~100ns
- Fully associative, small (64-1024 entries)

## Page Replacement Algorithms

| Algorithm | Descriere | Problema |
|-----------|-----------|----------|
| FIFO | Înlocuiește cea mai veche | Belady anomaly |
| LRU | Înlocuiește least recently used | Implementare costisitoare |
| OPT | Înlocuiește cea folosită cel mai târziu | Imposibil (viitor) |
| Clock | Aproximare LRU cu reference bit | Simplu, aproximativ |

## Thrashing
- Sistem petrece mai mult timp swapping decât computing
- Cauză: Too few frames per process
- Soluție: Working set model, page fault frequency