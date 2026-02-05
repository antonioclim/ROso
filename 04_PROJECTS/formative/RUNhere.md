# 📁 Chestionar de pregătire pentru proiect

> **Locație:** `04_PROJECTS/formative/`  
> **Scop:** chestionar de autoevaluare pentru verificarea pregătirii înainte de începerea proiectului de semestru

## Conținut

| Fișier | Scop |
|------|------|
| `project_readiness_quiz.yaml` | Bază de întrebări pentru verificarea cunoștințelor preliminare |

## Scop

Acest chestionar te ajută să evaluezi dacă ai cunoștințele necesare pentru a finaliza cu succes un proiect de semestru. Completează-l **înainte** de a selecta și de a începe proiectul.

## Cum se rulează

### Opțiunea 1: folosind SEM Quiz Runner

```bash
# Din orice folder SEM care conține quiz_runner.py
cd ../SEM01/formative/
python3 quiz_runner.py --file ../../04_PROJECTS/formative/project_readiness_quiz.yaml
```

### Opțiunea 2: evaluare manuală

Deschide `project_readiness_quiz.yaml` într-un editor de text și evaluează-te pentru fiecare întrebare.

## Tematici acoperite

Chestionarul de pregătire acoperă următoarele arii preliminare:

| Temă | Seminare | Întrebări |
|------|----------|-----------|
| Noțiuni de bază pentru scripting în shell | SEM01 | 2–3 |
| Redirecționare I/O și pipe-uri | SEM02 | 2–3 |
| Operații pe fișiere și permisiuni | SEM03 | 2–3 |
| Procesare text (grep/sed/awk) | SEM04 | 2–3 |
| Funcții și array-uri | SEM05 | 2–3 |
| Organizare proiect | SEM06 | 2–3 |

## Interpretarea scorului

| Scor | Interpretare | Recomandare |
|------|--------------|-------------|
| 90–100% | Pregătire completă | Poți începe la orice nivel |
| 75–89% | Pregătire bună | Începe proiecte Easy sau Medium |
| 60–74% | Pregătire de bază | Revizuiește zonele slabe, începe Easy |
| < 60% | Necesită consolidare | Parcurge întâi exercițiile de seminar |

## Structura YAML

```yaml
metadata:
  title: "Evaluare de pregătire pentru proiect"
  version: "1.0"
  estimated_time_minutes: 20
  passing_score: 75

questions:
  - id: pr01
    topic: "shell_basics"
    text: "Întrebare exemplu despre fundamentele shell-ului"
    options: ["A", "B", "C", "D"]
    correct: 1
    explanation: "Explicația răspunsului corect"
    seminar_reference: "SEM01"
```

---

*Tratează chestionarul cu seriozitate: scorul anticipează, de regulă, succesul proiectului.*  
*Vezi și: [`../PROJECT_SELECTION_GUIDE.md`](../PROJECT_SELECTION_GUIDE.md)*

*Ultima actualizare: ianuarie 2026*
