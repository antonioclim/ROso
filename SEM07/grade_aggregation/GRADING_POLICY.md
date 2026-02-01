# GRADING_POLICY.md - Politica oficială de notare

> **Sisteme de Operare** | ASE Bucharest - CSIE  
> An universitar 2024-2025

---

## 1. Formula de notare

Nota finală se calculează utilizând următoarea formulă ponderată:

```
FINAL_GRADE = (HOMEWORK_SCORE × 0.25) + (PROJECT_SCORE × 0.50) + (TEST_SCORE × 0.25)
```

### Ponderi pe componente

| Componentă | Pondere | Punctaj maxim | Descriere |
|-----------|--------|---------------|-----------|
| **Teme** | 25% | 10.00 | Media temelor predate complet |
| **Proiect** | 50% | 10.00 | Evaluarea proiectului de semestru |
| **Teste** | 25% | 10.00 | Media testelor de seminar |

### Intervalele de notare

| Notă | Interval scor | Descriere |
|-------|-------------|-----------|
| 10 | 9.50 - 10.00 | Excelent |
| 9 | 8.50 - 9.49 | Foarte bine |
| 8 | 7.50 - 8.49 | Bine |
| 7 | 6.50 - 7.49 | Satisfăcător |
| 6 | 5.50 - 6.49 | Suficient |
| 5 | 5.00 - 5.49 | Promovat |
| 4 | 0.00 - 4.99 | Nepromovat |

---

## 2. Criterii eliminatorii

### ⚠️ CRITIC: prag cantitativ de 80%

**Toate cele trei componente au praguri minime obligatorii de participare. Nerespectarea ORICĂRUI prag conduce la nepromovarea automată a disciplinei (nota 4), indiferent de scorurile obținute la celelalte componente.**

### 2.1 Prag pentru teme

| Metrică | Valoare |
|--------|---------|
| **Număr total de teme** | 31 |
| **Minim obligatoriu** | 25 (80.6%) |
| **Absențe maxime** | 6 |

**Distribuția temelor:**

| Seminar | Teme | Fișiere |
|---------|-------------|-------|
| SEM01 | 6 | S01b_Shell_Usage → S01g_Fundamental_Commands |
| SEM02 | 5 | S02b_Control_Operators → S02f_Scripting_Loops |
| SEM03 | 6 | S03b_Find_Locate → S03g_CRON_Automatizare |
| SEM04 | 5 | S04b_Expresii_Regulate → S04f_Editoare_Text |
| SEM05 | 6 | S05a_Prerequisite_Review → S05f_Logging_Debug |
| SEM06 | 3 | S06_HW01_Monitor → S06_HW03_Deployer |
| **TOTAL** | **31** | |

**Cerințe pentru o predare validă:**
- Tema este completată **integral** (toate sarcinile)
- Este predată **la timp** (înainte de termenul‑limită)
- Există o **semnătură criptografică** validă pe fișierul `.cast`
- Nu este detectată **alterarea** (tampering)

### 2.2 Prag pentru teste

| Metrică | Valoare |
|--------|-------|
| **Număr total de teste** | 6 |
| **Minim obligatoriu** | 5 (83.3%) |
| **Absențe maxime** | 1 |

**Calendarul testelor:**

| Test | Moment | Subiecte acoperite |
|------|--------|---------------------|
| T1 | Începutul SEM01 | Prerequisite‑uri, noțiuni de bază în shell |
| T2 | Începutul SEM02 | Conținut SEM01 |
| T3 | Începutul SEM03 | Conținut SEM01–SEM02 |
| T4 | Începutul SEM04 | Conținut SEM01–SEM03 |
| T5 | Începutul SEM05 | Conținut SEM01–SEM04 |
| T6 | Începutul SEM06 | Conținut SEM01–SEM05 |

**Reguli pentru teste:**
- Nu se susțin re‑examinări („make‑up tests”) în afara urgențelor medicale documentate
- Documentele medicale trebuie transmise în maximum 48 de ore
- Maximum o absență motivată per semestru

### 2.3 Prag pentru proiect

Proiectul **NU VA FI EVALUAT LA FINAL** dacă nu este îndeplinită oricare dintre condițiile următoare:

| Cerință | Metodă de verificare |
|-------------|---------------------|
| ✅ Toate cerințele intermediare din SEM06 sunt îndeplinite | Checklist pentru milestone 1 |
| ✅ Aplicația rulează fără erori | Suită de teste automate |
| ✅ Există un repository public GitHub | Verificare URL |
| ✅ Există un `README.md` complet | Verificare documentație |
| ✅ Sunt prezentate output‑uri REALE | Verificare manuală |

**Note critice:**
- Output‑urile simulate sau fabricate conduc la **nepromovare automată**
- `README.md` trebuie să includă: instalare, utilizare, capturi de ecran cu output‑uri reale
- Output‑urile trebuie să fie **comentate**, explicând ce demonstrează

---

## 3. Notarea temelor

### 3.1 Scala de notare per temă

Fiecare temă este notată pe o scală 0–10:

| Scor | Criterii |
|-------|----------|
| 10 | Toate sarcinile sunt corecte, execuție curată |
| 8-9 | Probleme minore, în mare parte corect |
| 6-7 | Completare parțială, unele erori |
| 4-5 | Lacune semnificative, erori majore |
| 1-3 | Efort minim, preponderent incorect |
| 0 | Nepredat sau semnătură invalidă |

### 3.2 Politica de predare cu întârziere

| Întârziere | Penalizare |
|-------|---------|
| ≤ 24 ore | -20% |
| 24–48 ore | -40% |
| 48–72 ore | -60% |
| > 72 ore | Nu se acceptă (nota 0) |

### 3.3 Calculul scorului final pentru teme

```python
def calculate_homework_score(submissions):
    valid_submissions = [s for s in submissions if s.is_valid]

    if len(valid_submissions) < 25:
        return "ELIMINATION - Below 80% threshold"

    total_score = sum(s.score for s in valid_submissions)
    return total_score / len(valid_submissions)
```

---

## 4. Notarea proiectului

### 4.1 Componența scorului

| Componentă | Pondere | Scor maxim |
|-----------|--------|-----------|
| **Evaluare automată** | 85% | 8.50 |
| **Evaluare manuală** | 15% | 1.50 |
| **TOTAL** | 100% | 10.00 |

### 4.2 Defalcarea evaluării automate

| Criteriu | Puncte | Descriere |
|-----------|--------|-------------|
| Trecerea testelor funcționale | 4.00 | Toate funcționalitățile obligatorii sunt implementate |
| Calitatea codului (ShellCheck/pylint) | 1.50 | Fără erori, avertismente minime |
| Completitudinea documentației | 1.50 | README, comentarii, text de help |
| Structura directoarelor | 0.75 | Respectă specificația |
| Tratarea erorilor | 0.75 | Eșec controlat, mesaje clare |
| **Subtotal** | **8.50** | |

### 4.3 Defalcarea evaluării manuale

| Criteriu | Puncte | Descriere |
|-----------|--------|-------------|
| Experiența utilizatorului | 0.50 | Interfață intuitivă, output clar |
| Eleganța codului | 0.50 | Lizibilitate, bune practici |
| Inovație/extra | 0.50 | Dincolo de cerințe, creativitate |
| **Subtotal** | **1.50** | |

### 4.4 Susținere orală

Susținerea orală este **obligatorie** pentru validarea notei. Nu adaugă puncte, dar poate conduce la reducerea notei dacă:

| Situație | Penalizare |
|-------|---------|
| Nu poate explica propriul cod | -2.00 puncte |
| Nu poate răspunde la întrebări de bază | -1.00 punct |
| Suspiciune de plagiat | Sesizare către comisia de etică |

---

## 5. Notarea testelor

### 5.1 Structura testelor

Fiecare test include:

| Secțiune | Întrebări | Puncte | Timp |
|---------|-----------|--------|------|
| Alegere multiplă | 5 | 2.50 | 5 min |
| Răspuns scurt | 3 | 3.00 | 10 min |
| Practic/Cod | 2 | 4.50 | 15 min |
| **TOTAL** | **10** | **10.00** | **30 min** |

### 5.2 Calculul scorului final pentru teste

```python
def calculate_test_score(tests):
    taken_tests = [t for t in tests if t.was_taken]

    if len(taken_tests) < 5:
        return "ELIMINATION - Below 80% threshold"

    return sum(t.score for t in taken_tests) / len(taken_tests)
```

---

## 6. Calculul notei finale

### 6.1 Algoritm

```python
def calculate_final_grade(student):
    # Step 1: Check elimination criteria
    if student.homework_count < 25:
        return 4, "FAIL: Homework threshold not met"

    if student.test_count < 5:
        return 4, "FAIL: Test threshold not met"

    if not student.project_eligible:
        return 4, "FAIL: Project requirements not met"

    # Step 2: Calculate weighted score
    hw_score = student.homework_average
    proj_score = student.project_score
    test_score = student.test_average

    final = (hw_score * 0.25) + (proj_score * 0.50) + (test_score * 0.25)

    # Step 3: Round to nearest 0.5
    final_rounded = round(final * 2) / 2

    # Step 4: Convert to grade
    if final_rounded >= 5.00:
        grade = int(final_rounded) if final_rounded == int(final_rounded) else int(final_rounded) + 1
        return min(grade, 10), "PASS"
    else:
        return 4, "FAIL: Score below passing threshold"
```

### 6.2 Exemple de calcul

**Exemplul 1: Student promovat**
```
Homework: 8.5/10 (28/31 submitted)
Project: 9.0/10 
Tests: 7.5/10 (6/6 taken)

Final = (8.5 × 0.25) + (9.0 × 0.50) + (7.5 × 0.25)
     = 2.125 + 4.5 + 1.875
     = 8.5 → Grade 9
```

**Exemplul 2: Eliminare — teme**
```
Homework: 9.0/10 but only 20/31 submitted (64%)
Project: 10.0/10
Tests: 9.5/10

Result: FAIL (Grade 4) - Homework threshold not met
```

**Exemplul 3: Eliminare — proiect**
```
Homework: 8.0/10 (30/31 submitted)
Project: NOT EVALUATED (no GitHub repository)
Tests: 8.5/10 (5/6 taken)

Result: FAIL (Grade 4) - Project requirements not met
```

---

## 7. Procedura de contestații

### 7.1 Calendar
- Contestațiile trebuie transmise în maximum **48 de ore** de la publicarea notelor
- Contestație în scris către coordonatorul disciplinei, prin e‑mail
- Includeți aspecte concrete și dovezi suport

### 7.2 Motive acceptate pentru contestație
- Eroare de calcul
- Probleme tehnice ale sistemului de predare
- Urgență medicală sau personală (cu documente)

### 7.3 Motive neacceptate pentru contestație
- Dezacord față de rubrică
- „Am muncit mult”
- Extinderea termenului‑limită retroactiv

---

## 8. Integritate academică

### 8.1 Acțiuni interzise
- Copierea codului de la colegi
- Utilizarea AI pentru generarea soluțiilor fără declarare
- Alterarea înregistrărilor `.cast`
- Predarea muncii altcuiva ca fiind proprie

### 8.2 Consecințe

| Abatere | Consecință |
|---------|-------------|
| Prima abatere | 0 la temă + avertisment |
| A doua abatere | Nepromovarea disciplinei (nota 4) |
| Caz grav | Sesizare către comisia de etică a universității |

---

## Istoric document

| Versiune | Dată | Autor | Modificări |
|---------|------|--------|---------|
| 1.0 | 2025-01-30 | A. Clim | Versiune inițială |

---

*De Revolvix pentru disciplina OPERATING SYSTEMS | licență restricționată 2017-2030*
