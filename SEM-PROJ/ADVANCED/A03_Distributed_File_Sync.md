# A03: Distributed File Sync

> **Nivel:** ADVANCED | **Timp estimat:** 40-50 ore | **Componente:** Bash + C

---

## Descriere

Sistem de sincronizare fișiere între mașini multiple: detecție conflicte, merge, versioning și consistency. Componenta C gestionează hashing eficient și diff binary.

---

## De ce C?

Componenta C oferă:
- **Fast hashing** - rolling hash pentru block-level diff (similar rsync)
- **Binary diff** - detecție modificări la nivel de block
- **Network protocol** - comunicare eficientă între noduri

---

## Cerințe

### Obligatorii (Bash)
1. **Sync bidirectional** - între 2+ noduri
2. **Conflict detection** - modificări simultane
3. **Conflict resolution** - manual sau policy-based
4. **Selective sync** - patterns include/exclude
5. **Versioning** - păstrare N versiuni anterioare
6. **Incremental** - transfer doar diferențe
7. **Secure** - SSH transport

### Componenta C (Obligatorie)
8. **Rolling hash** - pentru block matching
9. **Block diff** - rdiff-style algorithm
10. **Protocol** - binary protocol pentru eficiență

### Opționale
11. **Multi-node** - sync N mașini
12. **Compression** - înainte de transfer
13. **Real-time** - inotify-based watching

---

## Arhitectură

```
┌─────────────┐         ┌─────────────┐
│   Node A    │◄───────►│   Node B    │
│             │   SSH   │             │
│ ┌─────────┐ │         │ ┌─────────┐ │
│ │ watcher │ │         │ │ watcher │ │
│ └────┬────┘ │         │ └────┬────┘ │
│      ▼      │         │      ▼      │
│ ┌─────────┐ │         │ ┌─────────┐ │
│ │ hasher  │ │         │ │ hasher  │ │
│ │  (C)    │ │         │ │  (C)    │ │
│ └─────────┘ │         │ └─────────┘ │
└─────────────┘         └─────────────┘
```

---

## Criterii Evaluare

| Criteriu | Pondere |
|----------|---------|
| Sync corect | 20% |
| Conflict handling | 15% |
| Componenta C | 25% |
| Incremental transfer | 15% |
| Calitate cod | 10% |
| Securitate | 5% |
| Teste | 5% |
| Documentație | 5% |

---

*Proiect ADVANCED | Sisteme de Operare | ASE-CSIE*
