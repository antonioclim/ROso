# 📁 Temă — Find, Xargs & permisiuni

> **Locație:** `SEM03/homework/`  
> **Scop:** temă pe căutare în sistemul de fișiere, procesare în lot și permisiuni


## Conținut

| Fișier | Scop |
|------|---------|
| `S03_01_HOMEWORK.md` | specificația temei |
| `S03_02_create_homework.sh` | generatorul de teme |
| `S03_03_EVALUATION_RUBRIC.md` | criterii de evaluare |
| `S03_04_ORAL_VERIFICATION_LOG.md` | checklist pentru verificare orală |

---


## S03_02_create_homework.sh

**Scop:** generează exerciții personalizate pentru *find*, *xargs* și permisiuni.


### Utilizare

```bash
./S03_02_create_homework.sh [options]

Options:
  --student-id ID    Generate for specific student
  --batch FILE       Generate from student list
  --seed N           Random seed for reproducibility
  --output DIR       Output directory
```


### Elemente de personalizare

- structuri de directoare pentru căutare
- pattern-uri și extensii de fișiere
- scenarii de permisiuni
- output așteptat

---


## Submission

1. Complete exercises in `S03_01_HOMEWORK.md`
2. Validate: `../../03_GUIDES/check_my_submission.sh`
3. Record: `../../02_INIT_HOMEWORKS/record_homework_EN.sh`

---

*See also: [`S03_03_EVALUATION_RUBRIC.md`](S03_03_EVALUATION_RUBRIC.md)*

*Last updated: January 2026*

