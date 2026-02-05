# C02_01_PLAN_CURS.md
# Plan de Curs — Concepte de Bază ale SO

> Sisteme de Operare | ASE București - CSIE | 2025-2026  
> Săptămâna 2 | by Revolvix

---

## Obiective de Învățare

La finalul acestui curs, studentul va fi capabil să:

1. **Explice** mecanismul întreruperilor hardware și software
2. **Diferențieze** între polling și interrupt-driven I/O
3. **Descrie** funcționarea DMA și avantajele sale
4. **Analizeze** fluxul de tratare a întreruperilor

---

## Structura Cursului (100 minute)

### Partea I: Întreruperi (40 min)
| Timp | Subiect | Metodă |
|------|---------|--------|
| 0-15 | Ce sunt întreruperile? Hardware vs Software | Diagrame |
| 15-25 | Interrupt Vector Table (IVT) | Exemplu x86 |
| 25-40 | Fluxul de tratare: save context → handler → restore | Animație |

### Partea II: I/O și DMA (35 min)
| Timp | Subiect | Metodă |
|------|---------|--------|
| 40-55 | Polling vs Interrupts: trade-offs | Comparație |
| 55-70 | DMA: transfer fără CPU | Demo conceptual |
| 70-75 | I/O synchronous vs asynchronous | Diagrame |

### Partea III: Integrare (25 min)
| Timp | Subiect | Metodă |
|------|---------|--------|
| 75-90 | Priorități întreruperi, nested interrupts | Scenarii |
| 90-100 | Recapitulare și Q&A | Discuție |

---

## Evaluare
- Quiz formativ: 12 întrebări MCQ
- Focus examen: ~8% din nota finală

---

*Material actualizat: Ianuarie 2026*