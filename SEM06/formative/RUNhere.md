# 📁 Resurse formative — SEM06

> **Locație:** `SEM06/formative/`  
> **Scop:** quiz formativ și resurse de auto‑verificare

## Conținut

| Fișier | Scop |
|------|---------|
| `quiz.yaml` | quiz formativ (20+ întrebări) cu mapare către LO |
| `RUNhere.md` | instrucțiuni pentru utilizarea resurselor formative |

## Ce este quiz‑ul formativ?

Quiz‑ul formativ este conceput pentru:
- recapitularea rapidă a conceptelor‑cheie;
- verificarea înțelegerii înainte de temă;
- identificarea lacunelor (ce trebuie revăzut).

Quiz‑ul nu este „de notă”; scopul este să vă arate ce trebuie consolidat.

## Cum rulați quiz‑ul

### 1) Vizualizați quiz‑ul (citire)

Deschideți fișierul:
- `formative/quiz.yaml`

Structura este:
- `id` — identificator întrebare (q01, q02, ...)
- `question` — enunț
- `options` — variante
- `answer` — varianta corectă
- `lo` — rezultatul învățării asociat
- `bloom` — nivel cognitiv

### 2) Verificare sintactică YAML

Rulați:

```bash
python3 -c "import yaml; yaml.safe_load(open('formative/quiz.yaml'))"
echo $?
```

Dacă output‑ul este `0`, YAML‑ul este valid.

### 3) Exercițiu de auto‑testare

Procedură recomandată:
1. citiți întrebarea;
2. notați răspunsul pe hârtie;
3. verificați în YAML;
4. dacă greșiți, reveniți la documentul/LO indicat.

## Maparea către LO

Fiecare întrebare are câmpul `lo`. Exemplu:

```yaml
- id: q05
  lo: LO6.5
  bloom: Understand
```

Aceasta înseamnă că întrebarea testează:
- **LO6.5** (backup incremental cu `find -newer`)
- la nivel **Understand**.

## Recomandări

- Nu încercați să memorați. Încercați să explicați „de ce”.
- Dacă obțineți <70% corect, revedeți materialul principal (`docs/S06_02_MAIN_MATERIAL.md`) și ghidurile proiectelor.
- Pentru LO pe care le ratați repetat, rezolvați exercițiile de tip sprint aferente.

## Depanare

| Problemă | Cauză tipică | Soluție |
|-------|---------------|---------|
| YAML invalid | indentare greșită | verificați spațiile și alinierea |
| eroare `ModuleNotFoundError: yaml` | PyYAML lipsește | `pip install pyyaml` |
| răspunsuri neclare | ambiguitate conceptuală | reveniți la documentul proiectului relevant |

---

*Resurse formative pentru SEM06 CAPSTONE — Sisteme de Operare*  
*ASE București - CSIE | 2024-2025*
