# Jurnal de modificări - SEM01

Toate modificările notabile ale acestui seminar vor fi documentate în acest fișier.

Formatul se bazează pe [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [2.1.0] - 2025-01-30

### Adăugat
- **Documentație nouă**
  - `S01_11_INSTRUMENTE_EXTERNE_PLAGIAT.md` — Ghid complet de integrare MOSS și JPlag
  - `teme/S01_04_JURNAL_VERIFICARE_ORALA.md` — Formular de verificare printabil cu bancă de întrebări

- **Detecție plagiat îmbunătățită**
  - Detecție pattern-uri cod AI în `S01_05_plagiarism_detector.py`
  - 11 pattern-uri specifice AI (comentarii explicative, narare pași etc.)
  - Scor probabilitate AI (0.0–1.0) pentru fiecare temă
  - Raport combinat: similaritate + indicatori AI

- **Ținte Makefile**
  - `make test-coverage` — pytest cu prag 75%
  - `make plagiarism-check SUBMISSIONS=./` — detector intern
  - `make moss-check MOSS_USERID=... SUBMISSIONS=./` — trimitere MOSS
  - `make jplag-check SUBMISSIONS=./` — analiză JPlag

- **Îmbunătățiri CI/CD**
  - Aplicare prag acoperire (75%)
  - Validare document S01_11 în verificarea structurii
  - Validare jurnal verificare orală

- **Îmbunătățiri pedagogice**
  - Protocol detaliat programare în perechi în Ghidul Instructorului
  - Tabel responsabilități Driver/Navigator
  - Probleme frecvente și soluții
  - Provocări extinse în Exerciții Sprint (rating dificultate ★★★☆☆)

### Modificat
- **Makefile** — Înlocuit `|| true` cu gestionare erori corectă
- **Pipeline CI** — Versiune actualizată la 2.1, adăugat prag acoperire
- **Anteturi** — Standardizat „Bucharest UES" → „ASE București" în tot documentul
- **lo_traceability.md** — Adăugat index documente și coloană instrumente externe

### Reparat
- Ținta lint din Makefile raportează corect starea shellcheck/ruff
- Structura README reflectă structura reală a directoarelor

---

## [2.0.0] - 2025-01-29

### Adăugat
- **Măsuri anti-plagiat**
  - Generator teme (`S01_04_assignment_generator.py`) pentru variante randomizate per student
  - Detector plagiat (`S01_05_plagiarism_detector.py`) pentru detecție similaritate
  - Scanner amprentă AI (`S01_06_ai_fingerprint_scanner.py`) pentru revizuire documentație
  - Verificare orală obligatorie (10% din notă) în rubrica de evaluare

- **Completare taxonomie Bloom**
  - Adăugată întrebare nivel Evaluare (Q13) în quiz
  - Adăugată întrebare nivel Creare (Q14) în quiz
  - Actualizată trasabilitate OÎ pentru acoperirea tuturor celor șase niveluri

- **Suport metacogniție**
  - Șablon jurnal de învățare în documentul de autoevaluare
  - Secțiune diferențiere pentru studenți avansați
  - Întrebări pentru discuție între colegi

- **Documentație nouă**
  - CONTRIBUTING.md cu ghid de stil
  - README actualizat cu funcționalități noi

### Modificat
- **Standardizare structură directoare**
  - Redenumit `assignments/` în `homework/`
  - Redenumit `tests_runner/` și `unit_tests/` în `tests/`
  - Toate numele de directoare sunt acum doar în engleză

- **Standardizare denumiri fișiere**
  - Redenumit `S01_02_quiz_interactiv.sh` în `S01_02_interactive_quiz.sh`
  - Redenumit `S01_03_demo_variabile.sh` în `S01_03_demo_variables.sh`
  - Redenumit `S01_00_PEDAGOGICAL_ANALYSIS_AND_PLAN.md` în `S01_00_PEDAGOGICAL_ANALYSIS_PLAN.md`

- **Standardizare limbă**
  - Toată documentația convertită în engleză britanică
  - Eliminat virgula Oxford în tot documentul
  - Mesaje ieșire scripturi în engleză

- **Rubrica de evaluare**
  - Adăugată secțiune verificare orală (10% din notă)
  - Adăugate semnale de alarmă pentru detecție plagiat
  - Reduse proporțional celelalte secțiuni

- **Îmbunătățiri quiz**
  - Extins de la 12 la 14 întrebări
  - Adăugată întrebare evaluare securitate
  - Adăugată întrebare creare alias
  - Actualizată distribuție Bloom pentru includerea tuturor nivelurilor

### Reparat
- Clasă GlobbingTest incompletă în autograder
- Import shutil lipsă în autograder
- Denumiri inconsistente în anteturile documentației

### Eliminat
- Conținut în limba română din toate fișierele cu excepția directorului legacy OLD_HW
- Directoare de teste duplicate

---

## [1.0.0] - 2025-01-15

### Adăugat
- Lansare inițială a materialelor SEM01 standardizate
- Set complet de 11 fișiere documentație
- Quiz formativ cu 12 întrebări
- Autograder cu multiple tipuri de teste
- Script validator pentru verificare rapidă
- Configurare CI/CD pentru GitHub Actions
- Configurare ShellCheck

---

*Menținut de ing. dr. Antonio Clim, ASE-CSIE București*
