# ✅ Quiz formativ — SEM05

> **Locație:** `formative/`  
> **Scop:** quiz local (CLI) + export LMS (JSON) dintr-o singură sursă YAML

---

## Conținut

| Fișier | Rol |
|-------|-----|
| `quiz.yaml` | sursa unică a întrebărilor (metadate, topicuri, întrebări) |
| `quiz_runner.py` | rulează quiz-ul în terminal, calculează scor, afișează feedback |
| `quiz_lms.json` | export pentru încărcare în LMS (generat din YAML) |

---

## Rulare rapidă

Din rădăcina proiectului:

```bash
python formative/quiz_runner.py
```

---

## Export LMS

Pentru a genera/actualiza exportul JSON pentru LMS:

```bash
python formative/quiz_runner.py --export-lms formative/quiz_lms.json
```

---

## Notă tehnică

- Nu traduceți cheile structurale YAML/JSON (sunt folosite programatic).
- Puteți ajusta textul întrebărilor și explicațiile, păstrând structura.
