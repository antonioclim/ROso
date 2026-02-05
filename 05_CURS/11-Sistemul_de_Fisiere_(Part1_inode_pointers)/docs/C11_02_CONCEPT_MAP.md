# Hartă Conceptuală — Filesystem P1

```
              ┌──────────────────┐
              │      INODE       │
              │ (index node)     │
              └────────┬─────────┘
                       │
    ┌──────────────────┼──────────────────┐
    ▼                  ▼                  ▼
┌─────────┐     ┌─────────────┐     ┌─────────┐
│Metadata │     │  Pointeri   │     │  Links  │
└────┬────┘     └──────┬──────┘     └────┬────┘
     │                 │                 │
┌────┴────┐     ┌──────┴──────┐     ┌────┴────┐
│• Size   │     │• 12 Direct  │     │Hard Link│
│• Perms  │     │• 1 Single   │     │ Same    │
│• Owner  │     │   Indirect  │     │ inode   │
│• Times  │     │• 1 Double   │     ├─────────┤
│• Links  │     │• 1 Triple   │     │Soft Link│
└─────────┘     └─────────────┘     │ Path    │
                                    │ string  │
                                    └─────────┘

INODE vs DIRECTORY:
┌──────────────────────────────────────────────┐
│  Director = Fișier special                   │
│  Conține: (nume, inode_number) pairs         │
│                                              │
│  "file.txt" │ 12345                         │
│  "data"     │ 12350                         │
│  "."        │ 12300  (self)                 │
│  ".."       │ 12200  (parent)               │
└──────────────────────────────────────────────┘
```