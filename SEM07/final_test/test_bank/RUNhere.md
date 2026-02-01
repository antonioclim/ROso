# Bancă de test — întrebări pentru examinarea finală

> **Locație:** `SEM07/final_test/test_bank/`  
> **Scop:** Bancă de întrebări pentru generarea subiectelor de examinare finală  
> **Public țintă:** Doar cadre didactice (CONFIDENȚIAL)

## Conținut

| Fișier | Scop |
|------|---------|
| `questions_pool.yaml` | Banca completă de întrebări, cu metadate |

---

## Structura YAML

```yaml
metadata:
  title: "Operating Systems Final Examination"
  version: "2.0"
  total_questions: 150+
  coverage:
    - seminars: 1-6
    - lectures: 1-14
  bloom_distribution:
    remember: 25%
    understand: 35%
    apply: 25%
    analyse: 15%

questions:
  - id: "sem01_q01"
    topic: "Shell Basics"
    seminar: 1
    bloom: remember
    difficulty: easy
    points: 2
    text: "Question text..."
    type: multiple_choice
    options:
      - "Option A"
      - "Option B"
      - "Option C"
      - "Option D"
    correct: 1
    explanation: "Why B is correct"

  - id: "lec05_q03"
    topic: "Threads"
    lecture: 5
    bloom: apply
    difficulty: medium
    points: 5
    text: "Given the following code..."
    type: code_analysis
    code: |
      pthread_create(&t1, NULL, func, NULL);
      pthread_create(&t2, NULL, func, NULL);
      ...
    answer_key: "Expected analysis points..."
```

---

## Tipuri de întrebări

| Tip | Format | Auto‑corectabil |
|------|--------|-----------------|
| `multiple_choice` | 4 opțiuni, 1 corectă | Da |
| `multiple_select` | 4+ opțiuni, 1+ corecte | Da |
| `true_false` | Boolean | Da |
| `short_answer` | Text (< 50 cuvinte) | Parțial |
| `code_analysis` | Cod + întrebări | Nu |
| `code_writing` | Scriere de cod | Nu |
| `diagram` | Desenare/etichetare | Nu |

---

## Generarea examenelor

Utilizați generatorul de quiz împreună cu banca de întrebări:

```bash
# Generate randomized exam
python3 ../../../SEM01/scripts/python/S01_02_quiz_generator.py     --input questions_pool.yaml     --output exam_v1.yaml     --questions 40     --points 100     --seed 12345
```

### Variante de examen

```bash
# Generate 5 unique variants
for i in {1..5}; do
    python3 quiz_generator.py         --input questions_pool.yaml         --output "exam_variant_$i.yaml"         --seed $((12345 + i))
done
```

---

## Matrice de acoperire

Asigurați o acoperire echilibrată a subiectelor:

```
Topic                    | Questions | Points
─────────────────────────┼───────────┼────────
SEM01: Shell Basics      | 15        | 12%
SEM02: I/O & Pipes       | 15        | 12%
SEM03: Find & Perms      | 15        | 12%
SEM04: Text Processing   | 20        | 16%
SEM05: Functions/Arrays  | 15        | 12%
SEM06: Capstone          | 10        | 10%
Lectures (Theory)        | 60        | 26%
─────────────────────────┼───────────┼────────
TOTAL                    | 150+      | 100%
```

---

## Notă de securitate

⚠️ **MATERIAL CONFIDENȚIAL**

- Nu distribuiți studenților
- Stocați în siguranță
- Generați variante noi în fiecare semestru
- Urmăriți ce întrebări au fost utilizate

---

*Vedeți și: [`../../grade_aggregation/`](../../grade_aggregation/) pentru notare*

*Ultima actualizare: ianuarie 2026*
