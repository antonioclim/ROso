# 📋 Format pentru evaluare formativă — sistem de chestionare pe curs

> **Locație:** `05_LECTURES/*/docs/CXX_05_FORMATIVE_ASSESSMENT.yaml`  
> **Scop:** Standardizează chestionarele de evaluare formativă pentru fiecare curs, folosind o structură YAML unitară, compatibilă cu rularea locală și cu conversia către platforme LMS.

Acest document definește formatul YAML utilizat pentru chestionarele formative din cadrul cursului de **Sisteme de Operare**. Formatul este proiectat pentru a sprijini învățarea activă, prin întrebări de tip alegere multiplă (MCQ) și o distribuție cognitivă echilibrată conform taxonomiei lui Bloom.

## Prezentare generală

```
05_LECTURES/XX-Topic/docs/CXX_05_FORMATIVE_ASSESSMENT.yaml
```

Fiecare fișier de chestionar conține:

- **Metadate** (subiect, versiune, autor, distribuție Bloom, timp estimat)
- **Întrebări** (în mod tipic 12 întrebări MCQ, fiecare cu 4 opțiuni și o explicație)

---

## Locații ale fișierelor

Fiecare curs include propriul fișier YAML de evaluare formativă, localizat în subdirectorul `docs/`:

| Curs | Fișier chestionar |
|------|-------------------|
| 01 — Introducere în sisteme de operare | `01-.../docs/C01_05_FORMATIVE_ASSESSMENT.yaml` |
| 02 — Concepte de bază ale sistemelor de operare | `02-.../docs/C02_05_FORMATIVE_ASSESSMENT.yaml` |
| ... | ... |
| 18 — Generalizare a conceptelor și sinteză | `18-.../docs/C18_05_FORMATIVE_ASSESSMENT.yaml` |

---

## Structura YAML

### Exemplu complet

```yaml
# CXX_05_FORMATIVE_ASSESSMENT.yaml
# Course X: Topic Name
# Formative Assessment — Conceptual Quiz

metadata:
  course: 5                           # Lecture number
  subject: "Execution Threads"        # Lecture title
  version: "2.0"                      # Quiz version
  creation_date: "2026-01-28"         # ISO date
  author: "by Revolvix"               # Creator
  number_of_questions: 12             # Total questions
  estimated_time_minutes: 15          # Suggested time
  bloom_distribution:                 # Taxonomy breakdown
    remember: 3                       # Knowledge recall
    understand: 5                     # Comprehension
    analyse: 3                        # Breaking down
    apply: 1                          # Using in new situations

questions:
  # ═══════════════════════════════════════════════════════════════
  # REMEMBER (knowledge retrieval)
  # ═══════════════════════════════════════════════════════════════
  
  - id: q01                           # Unique identifier
    bloom: remember                   # Taxonomy level
    difficulty: easy                  # easy | medium | hard
    text: "What is a thread?"         # Question text
    options:                          # Answer choices
      - "An independent process"
      - "The smallest unit of execution"
      - "A type of memory"
      - "An executable file"
    correct: 1                        # 0-indexed correct answer (B)
    explanation: "Thread = lightweight process, shares address space"
  
  # ═══════════════════════════════════════════════════════════════
  # UNDERSTAND (comprehension)
  # ═══════════════════════════════════════════════════════════════
  
  - id: q02
    bloom: understand
    difficulty: medium
    text: "Why are threads more efficient than processes for..."
    options:
      - "Option A"
      - "Option B"
      - "Option C"
      - "Option D"
    correct: 2
    explanation: "Detailed explanation of why C is correct"
    
  # Additional questions follow same pattern...
```

### Câmpuri obligatorii

Fiecare fișier YAML trebuie să includă aceste chei de nivel superior:

- `metadata`: descrierea chestionarului (subiect, autor, distribuție cognitivă)
- `questions`: lista de întrebări (MCQ), fiecare cu opțiuni și explicație

#### Câmpuri din `metadata`

- `course` (număr): identificator numeric al cursului (de exemplu `1`, `2`, ...)
- `subject` (șir): tema chestionarului (ex.: „Introducere în Sisteme de Operare”)
- `version` (șir): versiune semantică (ex.: `1.0`)
- `creation_date` (șir): data generării fișierului (format recomandat: `YYYY-MM-DD`)
- `author` (șir): autor / contributor (nume, fără adresă de e-mail)
- `number_of_questions` (număr): numărul total de întrebări
- `estimated_time_minutes` (număr): timp estimat pentru parcurgere
- `bloom_distribution` (obiect): distribuția țintă a nivelurilor Bloom (procente)

#### Câmpuri pentru întrebări

Fiecare element din `questions` este un obiect cu câmpurile:

- `id` (șir): identificator unic (de forma `CXX_QYY`)
- `bloom` (șir): nivelul Bloom (`remember`, `understand`, `apply`, `analyse`)
- `difficulty` (șir): dificultate (`easy`, `medium`, `hard`)
- `type` (șir): tipul întrebării (în mod uzual `mcq`)
- `text` (șir): enunțul întrebării
- `options` (listă): cele 4 opțiuni de răspuns
- `correct` (număr): indexul opțiunii corecte (0-indexat)
- `explanation` (șir): explicație concisă care justifică răspunsul corect

### Niveluri Bloom

- `remember`: reamintire de fapte / definiții
- `understand`: explicare și interpretare conceptuală
- `apply`: utilizare a conceptelor în contexte concrete
- `analyse`: analiză, comparație, diagnosticare a comportamentului unui sistem

### Niveluri de dificultate

- `easy`: întrebări introductive, focalizate pe concepte de bază
- `medium`: necesită înțelegere și aplicare în scenarii tipice
- `hard`: necesită analiză, integrare de concepte și raționament detaliat

---

## Cum se utilizează

### Opțiunea 1: cu Quiz Runner (recomandat)

```bash
# From any SEM folder
cd ../SEM01/formative/

# Run specific lecture quiz
python3 quiz_runner.py --file ../../05_LECTURES/05-Execution_Threads/docs/C05_05_FORMATIVE_ASSESSMENT.yaml

# With options
python3 quiz_runner.py --file <path> --questions 10 --shuffle
```

### Opțiunea 2: revizuire manuală

Deschideți fișierul YAML în orice editor de text/cod. Parcurgeți întrebările manual, verificând răspunsurile față de câmpul `correct` și citind explicațiile.

### Opțiunea 3: import în LMS

Conversie în format LMS pentru Moodle/Canvas:

```bash
python3 quiz_generator.py --input <yaml_file> --output quiz_lms.json --format moodle
```

---

## Distribuția taxonomiei Bloom

Fiecare chestionar urmează o distribuție recomandată, pentru a combina reamintirea, înțelegerea, aplicarea și analiza:

| Nivel | Proces cognitiv | Verbe tipice | Țintă (%) |
|-------|------------------|--------------|-----------|
| **Remember** | Reamintire de fapte | definește, listează, enunță, identifică | 15–25% |
| **Understand** | Explicare de concepte | explică, descrie, compară, contrastează | 35–45% |
| **Apply** | Aplicare în context nou | demonstrează, implementează, calculează | 10–20% |
| **Analyse** | Descompunere și examinare | diferențiază, examinează, testează, compară | 20–30% |

### Exemplu de distribuție (12 întrebări)

```
Remember:    ███░░░░░░░░░  3 questions (25%)
Understand:  █████░░░░░░░  5 questions (42%)
Apply:       █░░░░░░░░░░░  1 question  (8%)
Analyse:     ███░░░░░░░░░  3 questions (25%)
```

---

## Documentație asociată

Fiecare folder `docs/` conține și:

| Fișier | Scop |
|------|---------|
| `CXX_01_COURSE_PLAN.md` | Obiective de învățare și planificare temporală |
| `CXX_02_CONCEPT_MAP.md` | Relații vizuale între concepte și subiecte |
| `CXX_03_DISCUSSION_QUESTIONS.md` | Întrebări pentru discuții / instruire între colegi |
| `CXX_04_STUDY_GUIDE.md` | Materiale pentru studiu individual |
| `##ex#_-_*.html` | Simulatoare HTML interactive |

---

## Validare

Pentru validarea sintaxei YAML:

```bash
python3 -c "
import yaml
with open('C05_05_FORMATIVE_ASSESSMENT.yaml') as f:
    data = yaml.safe_load(f)
    assert 'metadata' in data
    assert 'questions' in data
    print(f'Valid: {len(data[\"questions\"])} questions')
"
```

---

## Contribuții

La adăugarea sau modificarea întrebărilor:

1. Mențineți echilibrul distribuției Bloom
2. Includeți explicații clare și verificabile
3. Asigurați 4 opțiuni pentru fiecare întrebare
4. Utilizați câmpul `correct` 0-indexat
5. Testați cu `quiz_runner.py`

---

*Vezi și: fișierele README.md ale fiecărui curs pentru contextul tematic*  
*Vezi și: `SEM*/formative/` pentru chestionare specifice seminarelor*

*Ultima actualizare: ianuarie 2026*