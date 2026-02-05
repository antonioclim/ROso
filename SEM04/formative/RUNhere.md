# 📁 Evaluare formativă — SEM04

> **Locație:** `SEM04/formative/`  
> **Scop:** sistem de quiz pentru auto‑evaluarea conceptelor de seminar

## Conținut

| Fișier | Rol |
|------|---------|
| `quiz.yaml` | banca de întrebări (12+ întrebări, distribuite pe Bloom) |
| `quiz_runner.py` | runner interactiv CLI pentru quiz |
| `quiz_lms.json` | export compatibil LMS (Moodle/Canvas) |

## Pornire rapidă

```bash
# Run interactive quiz
python3 quiz_runner.py

# Run with specific number of questions
python3 quiz_runner.py --questions 10

# Shuffle question order
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

## Format quiz (quiz.yaml)

```yaml
metadata:
  seminar: 4
  subject: "Text Processing (grep/sed/awk)"
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

## Adăugarea de întrebări

1. Editați `quiz.yaml`
2. Urmați ghidul de distribuție pe taxonomia Bloom
3. Validați: `python3 quiz_runner.py --validate`
4. Testați: `python3 quiz_runner.py --questions 5`

## Integrare LMS

### Export pentru Moodle

```bash
python3 quiz_runner.py --export moodle > quiz_moodle.xml
```

### Export pentru Canvas

Folosiți `quiz_lms.json` deja generat sau:
```bash
python3 quiz_runner.py --export canvas > quiz_canvas.qti
```

## Referință — Taxonomia Bloom

| Nivel | Proces cognitiv | Tipuri de întrebări |
|-------|-------------------|----------------|
| Remember | Reamintire fapte | Definiții, liste, terminologie |
| Understand | Explicare sens | Comparații, descrieri |
| Apply | Aplicare cunoștințe | Completare de cod, utilizare de comenzi |
| Analyse | Analiză / descompunere | Debugging, predicție de output |

---

*Vezi și: [`../docs/`](../docs/) pentru materiale de studiu*  
*Vezi și: [`../tests/`](../tests/) pentru testare automată*

*Ultima actualizare: ianuarie 2026*
