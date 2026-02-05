# Materiale suplimentare — pregătire pentru examen

> Sisteme de operare | ASE București — CSIE  
> Versiune: 1.0 | ianuarie 2026

## Scop

Acest director conține materiale de recapitulare pentru examenul final la disciplina Sisteme de operare, acoperind toate cele 14 săptămâni de curs prin exerciții, diagrame și răspunsuri model.

## Conținut

| Resursă | Descriere | Acoperire |
|---------|-----------|-----------|
| `Exam_Exercises_Part1.md` | Exerciții și diagrame | Săptămânile 1–4: introducere în SO, apeluri de sistem, procese, planificare |
| `Exam_Exercises_Part2.md` | Exerciții și diagrame | Săptămânile 5–8: fire de execuție, sincronizare, interblocare |
| `Exam_Exercises_Part3.md` | Exerciții și diagrame | Săptămânile 9–14: memorie, sisteme de fișiere, securitate, virtualizare |
| `REFERENCES.md` | Bibliografie academică | 12 articole fundamentale cu linkuri DOI |
| `diagrams_png/` | Diagrame conceptuale pre‑randate | 26 fișiere PNG, rezoluție înaltă |

## Mod de utilizare

1. **Înainte de curs:** parcurgeți rapid diagramele săptămânii relevante pentru a pre‑vizualiza conceptele
2. **După curs:** rezolvați exercițiile fără a consulta soluțiile din prima încercare
3. **Înainte de examen:** cronometrați întrebările tip examen (țintă: 5 min/întrebare)

## Regenerarea diagramelor

Dacă modificați sursele PlantUML din `diagrams_common/`, regenerați PNG‑urile:

```bash
# Necesită Java și conexiune la internet (descărcare automată a PlantUML JAR)
python3 generate_diagrams.py --output diagrams_png/ --dpi 200
```

## Distribuția pe niveluri cognitive

Materialele progresează deliberat prin niveluri cognitive:

| Nivel | Proporție | Exemple de tipuri de exerciții |
|-------|-----------|--------------------------------|
| Reamintire | ~15% | Definiții, asocierea terminologiei |
| Înțelegere | ~25% | Explicații de concepte, comparații |
| Aplicare | ~40% | Calcule, trasarea algoritmilor |
| Analiză | ~20% | Interpretarea diagramelor, analiza compromisurilor |

## Legendă de dificultate

| Simbol | Nivel | Timp tipic |
|--------|-------|------------|
| ⭐ | Ușor | 3–5 min |
| ⭐⭐ | Mediu | 5–10 min |
| ⭐⭐⭐ | Dificil | 10–15 min |
| ⭐⭐⭐⭐ | Expert | 15–20 min |

## Capcane frecvente la examen

> 💡 **Sfat:** Studenții confundă adesea „page fault” cu „segmentation fault”. Primul este un mecanism normal de demand paging; al doilea este o eroare fatală.

> ⚠️ **Atenție:** Întrebarea despre condițiile Coffman apare în aproape fiecare sesiune de examen. Rețineți-le în ordine: **E**xcludere mutuală, **P**ăstrează & așteaptă, **F**ără preempțiune, **A**șteptare circulară.

## Suport

- **Forum curs:** verificați Moodle pentru anunțuri
- **Consultații:** conform orarului disciplinei
- **Cadru didactic:** ing. dr. Antonio Clim

---

*Materiale dezvoltate pentru ASE București — CSIE*
