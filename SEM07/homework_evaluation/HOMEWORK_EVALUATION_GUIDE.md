# Ghid de evaluare a temelor

> **Sisteme de Operare** | ASE Bucharest - CSIE  
> Document de referință pentru cadre didactice

---

## Prezentare generală

Acest ghid descrie procedurile de evaluare a predărilor pentru componenta de teme în cadrul disciplinei Sisteme de Operare. Componenta de teme reprezintă **25%** din nota finală.

---

## 1. Cerințe de predare

### 1.1 Formatul fișierelor

Toate temele trebuie predate sub forma **înregistrărilor asciinema** (fișiere `.cast`) generate utilizând scripturile oficiale de înregistrare:

```bash
# Python TUI version
python3 record_homework_tui_EN.py

# Bash version
./record_homework_EN.sh
```

### 1.2 Metadate obligatorii

Fiecare fișier `.cast` trebuie să conțină un header JSON cu:

```json
{
    "version": 2,
    "width": 120,
    "height": 30,
    "timestamp": 1706612345,
    "student_id": "123456",
    "student_name": "Ion Popescu",
    "student_group": "1234A",
    "seminar": "SEM02",
    "homework_id": "S02b_Control_Operators"
}
```

### 1.3 Semnătură criptografică

Fiecare predare trebuie să includă o semnătură criptografică validă, anexată ca ultima linie:

```
# SIGNATURE: <base64_encoded_signature>
```

Semnătura se generează prin:
1. calcularea hash‑ului SHA‑256 pentru întregul conținut (cu excepția liniei de semnătură);
2. semnarea hash‑ului cu cheia privată a studentului;
3. codarea semnăturii în Base64.

---

## 2. Inventarul temelor

### 2.1 Lista completă pe seminare

| Seminar | ID | Subiect | Scor maxim |
|---------|-----|-------|-----------|
| **SEM01** | S01b | Utilizarea shell‑ului | 10 |
| | S01c | Configurarea shell‑ului | 10 |
| | S01d | Variabile în shell | 10 |
| | S01e | Globbing pentru fișiere | 10 |
| | S01f | Globbing avansat | 10 |
| | S01g | Comenzi fundamentale | 10 |
| **SEM02** | S02b | Operatori de control | 10 |
| | S02c | Redirecționare I/O | 10 |
| | S02d | Pipe‑uri și tee | 10 |
| | S02e | Filtre de text | 10 |
| | S02f | Bucle în scripting | 10 |
| **SEM03** | S03b | Find și locate | 10 |
| | S03c | Xargs avansat | 10 |
| | S03d | Parametrii unui script | 10 |
| | S03e | CLI cu getopts | 10 |
| | S03f | Permisiuni Unix | 10 |
| | S03g | Automatizare CRON | 10 |
| **SEM04** | S04b | Expresii regulate | 10 |
| | S04c | Familia grep | 10 |
| | S04d | Editorul de flux sed | 10 |
| | S04e | Procesare cu awk | 10 |
| | S04f | Editoare de text | 10 |
| **SEM05** | S05a | Recapitulare prerequisite‑uri | 10 |
| | S05b | Funcții avansate | 10 |
| | S05c | Arrays în Bash | 10 |
| | S05d | Robusteză în scripting | 10 |
| | S05e | Trap și tratarea erorilor | 10 |
| | S05f | Logging și depanare | 10 |
| **SEM06** | S06_HW01 | Șablon monitor | 10 |
| | S06_HW02 | Șablon backup | 10 |
| | S06_HW03 | Șablon deployer | 10 |

**Total: 31 teme**

### 2.2 Cerințe de prag

- **Minim predări:** 25 (80.6%)
- **Absențe maxime:** 6 teme

---

## 3. Criterii de notare

### 3.1 Rubrică standard (10 puncte)

| Criteriu | Puncte | Descriere |
|-----------|--------|-------------|
| **Completare** | 4.0 | Toate sarcinile obligatorii sunt abordate |
| **Corectitudine** | 4.0 | Comenzile rulează corect, output așteptat |
| **Stil** | 2.0 | Comenzi curate, bune practici, comentarii |

### 3.2 Defalcarea completării

| Nivel | Puncte | Descriere |
|-------|--------|-------------|
| Complet | 4.0 | Toate sarcinile sunt realizate |
| Substanțial | 3.0 | 75–99% din sarcini |
| Parțial | 2.0 | 50–74% din sarcini |
| Minim | 1.0 | 25–49% din sarcini |
| Inexistent | 0.0 | < 25% din sarcini |

### 3.3 Defalcarea corectitudinii

| Nivel | Puncte | Descriere |
|-------|--------|-------------|
| Perfect | 4.0 | Toate output‑urile corespund rezultatelor așteptate |
| Erori minore | 3.0 | 1–2 greșeli mici |
| Unele erori | 2.0 | Mai multe greșeli, conceptele de bază sunt corecte |
| Erori majore | 1.0 | Neînțelegeri fundamentale |
| Incorect | 0.0 | Abordare complet greșită |

### 3.4 Defalcarea stilului

| Nivel | Puncte | Descriere |
|-------|--------|-------------|
| Excelent | 2.0 | Curat, bine organizat, bune practici |
| Bun | 1.5 | Preponderent curat, probleme minore |
| Acceptabil | 1.0 | Funcțional, dar dezordonat |
| Slab | 0.5 | Greu de urmărit |
| Inexistent | 0.0 | Fără atenție pentru stil |

---

## 4. Politica de predare cu întârziere

### 4.1 Penalizări

| Întârziere | Penalizare | Scor final |
|-------|---------|-------------|
| La timp | 0% | 100% din punctajul obținut |
| 1 zi întârziere | -20% | 80% din punctajul obținut |
| 2 zile întârziere | -40% | 60% din punctajul obținut |
| 3 zile întârziere | -60% | 40% din punctajul obținut |
| > 3 zile | Nu se acceptă | 0 |

### 4.2 Calculul termenelor

- Termen‑limită: ora de început a seminarului
- Zile de întârziere: calculate de la termen până la timestamp‑ul predării
- Zile parțiale: rotunjite în sus (de ex.: 1 oră întârziere = 1 zi)

### 4.3 Prelungiri

Prelungirile se acordă doar pentru:
- urgențe medicale documentate;
- absențe aprobate de universitate;
- probleme tehnice ale sistemului de predare (cu dovezi).

Solicitările de prelungire trebuie transmise **înainte** de termenul‑limită.

---

## 5. Proceduri de verificare

### 5.1 Verificări automate

Scriptul `verify_homework_EN.sh` realizează:

1. **Verificarea semnăturii**
   - extrage semnătura din fișier;
   - verifică folosind cheia publică;
   - marchează semnăturile invalide/lipsă.

2. **Validarea metadatelor**
   - verifică prezența câmpurilor obligatorii;
   - validează formatul ID‑ului de student;
   - verifică seminarul și ID‑ul temei.

3. **Verificarea timestamp‑ului**
   - compară cu termenele;
   - calculează penalizările de întârziere.

### 5.2 Cazuri care necesită review manual

Review manual este necesar când:
- verificarea semnăturii eșuează;
- înregistrarea este neobișnuit de scurtă (< 2 minute);
- înregistrarea este neobișnuit de lungă (> 60 minute);
- conținut identic cu o altă predare;
- studentul solicită re‑evaluare.

### 5.3 Detecția plagiatului

Indici de plagiat posibil:
- secvențe identice de comenzi;
- aceleași typo‑uri/greșeli;
- mesaje de eroare copiate;
- anomalii de timestamp.

Acțiuni:
1. marcați ambele predări;
2. intervievați studenții separat;
3. sesizați coordonatorul disciplinei dacă se confirmă.

---

## 6. Flux de notare

### 6.1 Înainte de notare

```bash
# 1. Collect submissions
./collect_submissions.sh /server/homeworks/ ./local_submissions/

# 2. Verify signatures
./verify_homework_EN.sh -r ./local_submissions/

# 3. Review verification report
cat ./verification_results/verification_report.md
```

### 6.2 Notare

```bash
# 1. Run automated grading
python3 grade_homework_EN.py     -s ./local_submissions/     -r ./homework_rubrics/     -d ./deadlines.csv     -o homework_grades.csv

# 2. Review flagged submissions manually
# 3. Update grades as needed
```

### 6.3 După notare

```bash
# 1. Generate final report
python3 generate_homework_report.py     -i homework_grades.csv     -o homework_report.pdf

# 2. Identify elimination cases
grep "ELIMINATION" homework_grades.csv > eliminations.csv

# 3. Notify affected students
```

---

## 7. Probleme frecvente

### 7.1 Probleme tehnice

| Problemă | Soluție |
|-------|----------|
| Fișier `.cast` corupt | Solicitați re‑predare |
| Semnătură lipsă | Verificați dacă scriptul a fost întrerupt |
| ID de seminar greșit | Verificați metadatele, corectați dacă este o eroare evidentă |
| Predare duplicată | Utilizați cea mai recentă predare validă |

### 7.2 Reclamații ale studenților

| Reclamație | Răspuns |
|-----------|----------|
| „Sistemul nu a acceptat predarea” | Verificați logurile serverului, validați timestamp‑ul |
| „Am predat la timp” | Comparați timestamp‑ul fișierului cu termenul‑limită |
| „Nota mea este greșită” | Revedeți înregistrarea, explicați rubricile |
| „Nu știam termenul‑limită” | Indicați fișa disciplinei și anunțurile |

---

## 8. Fișierele de rubrică

Fișierele individuale de rubrică sunt stocate în directorul `homework_rubrics/`:

- `S01_HOMEWORK_RUBRIC.md` - criterii specifice SEM01
- `S02_HOMEWORK_RUBRIC.md` - criterii specifice SEM02
- `S03_HOMEWORK_RUBRIC.md` - criterii specifice SEM03
- `S04_HOMEWORK_RUBRIC.md` - criterii specifice SEM04
- `S05_HOMEWORK_RUBRIC.md` - criterii specifice SEM05
- `S06_HOMEWORK_RUBRIC.md` - criterii specifice SEM06

Fiecare rubrică include:
- criterii de notare specifice temei;
- output‑uri așteptate pentru fiecare sarcină;
- greșeli uzuale și depunctări;
- oportunități de bonus.

---

## 9. Exemplu de calcul al scorului

**Student: Ion Popescu**

| Temă | Scor brut | Zile întârziere | Penalizare | Final |
|----------|-----------|-----------|---------|-------|
| S01b | 9.0 | 0 | 0% | 9.0 |
| S01c | 8.5 | 0 | 0% | 8.5 |
| S01d | 7.0 | 1 | 20% | 5.6 |
| S01e | 10.0 | 0 | 0% | 10.0 |
| ... | ... | ... | ... | ... |
| S06_HW03 | 8.0 | 0 | 0% | 8.0 |

**Sumar:**
- Predate: 28/31 ✓ (pragul este îndeplinit)
- Valide: 28/31
- Medie: 7.85/10
- **Componenta de teme: 7.85 × 0.25 = 1.96 puncte către nota finală**

---

*De Revolvix pentru disciplina OPERATING SYSTEMS | licență restricționată 2017-2030*
