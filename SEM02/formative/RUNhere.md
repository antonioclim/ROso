# 📁 Evaluare formativă — SEM02

> **Locație:** `SEM02/formative/`  
> **Scop:** sistem de autoevaluare (quiz) pentru conceptele din seminar

## Conținut

| Fișier | Scop |
|------|---------|
| `quiz.yaml` | bancă de întrebări (≥12 întrebări, distribuite pe Bloom) |
| `quiz_runner.py` | runner CLI interactiv |
| `quiz_lms.json` | export compatibil LMS (Moodle/Canvas) |

## Pornire rapidă

```bash
# Rulează quiz-ul interactiv
python3 quiz_runner.py

# Rulează cu un număr specific de întrebări
python3 quiz_runner.py --questions 10

# Amestecă ordinea întrebărilor
python3 quiz_runner.py --shuffle

# Afișează răspunsurile imediat după fiecare întrebare
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

## Formatul quiz-ului (quiz.yaml)

```yaml
metadata:
  seminar: 2
  subject: "I/O Redirection & Loops"
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

1. Editează `quiz.yaml`
2. Respectă ghidul de distribuție după taxonomia Bloom
3. Validează: `python3 quiz_runner.py --validate`
4. Testează: `python3 quiz_runner.py --questions 5`

## Integrare cu LMS

### Export pentru Moodle

```bash
python3 quiz_runner.py --export moodle > quiz_moodle.xml
```

### Export pentru Canvas

Folosește `quiz_lms.json` (deja generat) sau:
```bash
python3 quiz_runner.py --export canvas > quiz_canvas.qti
```

## Referință: Taxonomia Bloom

| Nivel | Proces cognitiv | Tipuri de întrebări |
|-------|-------------------|----------------|
| Remember | Reamintire de fapte | Definiții, liste, terminologie |
| Understand | Explicarea sensului | Comparații, descrieri |
| Apply | Aplicarea cunoștințelor | Completare cod, utilizare comenzi |
| Analyse | Descompunere / analiză | Debugging, predicția output-ului |

---

*Vezi și: [`../docs/`](../docs/) pentru materiale de studiu*  
*Vezi și: [`../tests/`](../tests/) pentru testare automată*

*Ultima actualizare: ianuarie 2026*
