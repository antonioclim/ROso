# 📁 Evaluare formativă — SEM03

> **Locație:** `SEM03/formative/`  
> **Scop:** sistem de autoevaluare (chestionar) pentru conceptele din seminar


## Conținut

| Fișier | Scop |
|------|---------|
| `quiz.yaml` | bancă de întrebări (12+ întrebări, distribuite pe Bloom) |
| `quiz_runner.py` | runner interactiv (CLI) pentru chestionar |
| `quiz_lms.json` | export compatibil cu LMS (Moodle/Canvas) |


## Quick Start

```bash

# Rulare chestionar interactiv
python3 quiz_runner.py


# Rulare cu un număr specific de întrebări
python3 quiz_runner.py --questions 10


# Amestecare ordine întrebări
python3 quiz_runner.py --shuffle


# Show answers immediately after each question
python3 quiz_runner.py --show-answers
```


## Opțiuni pentru quiz_runner.py

```bash
python3 quiz_runner.py [options]

Options:
  --questions N     Number of questions to ask (default: all)
  --shuffle         Randomize question order
  --show-answers    Show correct answer after each question
  --timed SEC       Time limit per question in seconds
  --file PATH       Use alternative quiz file
  --validate        Validate quiz.yaml structure without running
  --export FORMAT   Export to format: json, csv, moodle
```


## Formatul chestionarului (quiz.yaml)

```yaml
metadata:
  seminar: 3
  subject: "Find, Xargs, Permissions"
  version: "2.0"
  creation_date: "2026-01-XX"
  number_of_questions: 12
  estimated_time_minutes: 15
  bloom_distribution:
    remember: 3      # Knowledge recall
    understand: 5    # Comprehension  
    apply: 2         # Practical usage
    analyse: 2       # Problem solving

questions:
  - id: q01
    bloom: remember
    difficulty: easy
    text: "Question text here?"
    options:
      - "Option A"
      - "Option B"  
      - "Option C"
      - "Option D"
    correct: 1       # 0-indexed (Option B is correct)
    explanation: "Explanation of why B is correct"
```


## Integrare LMS

1. Edit `quiz.yaml`
2. Follow Bloom taxonomy distribution guidelines
3. Validate: `python3 quiz_runner.py --validate`
4. Test: `python3 quiz_runner.py --questions 5`


## Adăugarea de întrebări

1. Editează `quiz.yaml`
2. Respectă ghidul de distribuție pe taxonomia Bloom
3. Validează: `python3 quiz_runner.py --validate`
4. Testează: `python3 quiz_runner.py --questions 5`


### Export pentru Moodle

```bash
python3 quiz_runner.py --export moodle > quiz_moodle.xml
```


### Export pentru Canvas

Folosește fișierul pre-generat `quiz_lms.json` sau:

```bash
python3 quiz_runner.py --export canvas > quiz_canvas.qti
```


## Referință: Taxonomia Bloom

| Nivel | Proces cognitiv | Tipuri de întrebări |
|-------|-------------------|----------------|
| Remember | Reamintire de fapte | Definiții, liste, terminologie |
| Understand | Explicare a sensului | Comparații, descrieri |
| Apply | Utilizare a cunoașterii | Completare cod, utilizare comenzi |
| Analyse | Descompunere / analiză | Depanare, predicție de output |

---

*Vezi și: [`../docs/`](../docs/) pentru materiale de studiu*  
*Vezi și: [`../tests/`](../tests/) pentru testare automată*

*Ultima actualizare: ianuarie 2026*

