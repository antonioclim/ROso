# 📁 Evaluare Formativă — SEM01

> **Locație:** `SEM01/formative/`  
> **Scop:** Sistem quiz autoevaluare pentru conceptele seminarului

## Conținut

| Fișier | Scop |
|--------|------|
| `quiz.yaml` | Bancă de întrebări (12+ întrebări, distribuite Bloom) |
| `quiz_runner.py` | Runner quiz interactiv CLI |
| `quiz_lms.json` | Export compatibil LMS (Moodle/Canvas) |

## Pornire rapidă

```bash
# Rulează quiz interactiv
python3 quiz_runner.py

# Rulează cu număr specific de întrebări
python3 quiz_runner.py --questions 10

# Amestecă ordinea întrebărilor
python3 quiz_runner.py --shuffle

# Arată răspunsurile imediat după fiecare întrebare
python3 quiz_runner.py --show-answers
```

## Opțiuni quiz_runner.py

```bash
python3 quiz_runner.py [opțiuni]

Opțiuni:
  --questions N     Număr de întrebări de pus (implicit: toate)
  --shuffle         Randomizează ordinea întrebărilor
  --show-answers    Arată răspunsul corect după fiecare întrebare
  --timed SEC       Limită timp per întrebare în secunde
  --file PATH       Folosește fișier quiz alternativ
  --validate        Validează structura quiz.yaml fără a rula
  --export FORMAT   Exportă în format: json, csv, moodle
```

## Format quiz (quiz.yaml)

```yaml
metadata:
  seminar: 1
  subject: "Fundamentele Shell"
  version: "2.0"
  creation_date: "2026-01-XX"
  number_of_questions: 12
  estimated_time_minutes: 15
  bloom_distribution:
    remember: 3      # Reamintire cunoștințe
    understand: 5    # Înțelegere  
    apply: 2         # Utilizare practică
    analyse: 2       # Rezolvare probleme

questions:
  - id: q01
    bloom: remember
    difficulty: easy
    text: "Textul întrebării aici?"
    options:
      - "Opțiunea A"
      - "Opțiunea B"  
      - "Opțiunea C"
      - "Opțiunea D"
    correct: 1       # Index 0 (Opțiunea B este corectă)
    explanation: "Explicația de ce B este corect"
```

## Adăugare întrebări

1. Editați `quiz.yaml`
2. Urmați ghidurile de distribuție taxonomie Bloom
3. Validați: `python3 quiz_runner.py --validate`
4. Testați: `python3 quiz_runner.py --questions 5`

## Integrare LMS

### Export pentru Moodle

```bash
python3 quiz_runner.py --export moodle > quiz_moodle.xml
```

### Export pentru Canvas

Folosiți `quiz_lms.json` pre-generat sau:
```bash
python3 quiz_runner.py --export canvas > quiz_canvas.qti
```

## Referință taxonomie Bloom

| Nivel | Proces cognitiv | Tipuri întrebări |
|-------|-----------------|------------------|
| Reamintire | Reamintire fapte | Definiții, liste, terminologie |
| Înțelegere | Explicare semnificație | Comparații, descrieri |
| Aplicare | Utilizare cunoștințe | Completare cod, utilizare comenzi |
| Analiză | Descompunere | Debugging, predicție output |

---

*Vezi și: [`../docs/`](../docs/) pentru materiale de studiu*  
*Vezi și: [`../teste/`](../teste/) pentru testare automatizată*

*Ultima actualizare: Ianuarie 2026*
