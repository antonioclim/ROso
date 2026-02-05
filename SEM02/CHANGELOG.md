# Jurnal de modificări — SEM02 Operatori, redirecționare, filtre, bucle

Toate modificările notabile pentru acest seminar sunt documentate în acest fișier.
Formatul este bazat pe [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [2.0.0] - 2025-01-30

### Adăugate
- **sistem de penalizare pentru AI** în autograder: penalizări graduale (5–10%) pentru indicatori excesivi
- **Exercițiul L6: Detectivul de amprente** — îi învață pe studenți să recunoască tipare de cod generate de AI
- secțiunea **Politica de utilizare AI** în README, cu ghidaj explicit
- secțiunea „Lucruri care merg prost” în Ghidul instructorului, cu capcane frecvente
- anecdote didactice în documentația pedagogică (reduce amprentele artificiale)
- câmpul `ai_penalty_applied` în rapoartele de notare

### Modificate
- **BREAKING**: autograder-ul așteaptă acum nume de fișiere în engleză:
  - `ex1_operatori.sh` → `ex1_operators.sh`
  - `ex2_redirectare.sh` → `ex2_redirection.sh`
  - `ex3_filtre.sh` → `ex3_filters.sh`
  - `ex4_bucle.sh` → `ex4_loops.sh`
  - `ex5_integrat.sh` → `ex5_integrated.sh`
- `S02_01_ASSIGNMENT.md` → `S02_01_HOMEWORK.md` (standardizare de denumire)
- durata pentru bucle a crescut de la 15 la 20 minute în planul de seminar
- durata pentru filtre a scăzut de la 20 la 15 minute (ajustare compensatorie)
- versiunea autograder-ului a fost actualizată la 2.0, cu structură de cod mai curată
- matricea de competențe LLM include acum L6 și „Recunoașterea amprentelor AI”

### Corectate
- **CRITIC**: neconcordanță între autograder (nume românești) și validator (nume englezești)
- resturi de română în header-ul `S02_02_create_homework.sh`
- referințe inconsistente la convențiile vechi de denumire

### Eliminat
- detectarea AI doar informativă (acum are impact real asupra punctajelor)

## [1.2.0] - 2025-01-29

### Adăugate
- `S02_00_PEDAGOGICAL_ANALYSIS_PLAN.md` — document anterior lipsă, acum complet
- `S02_01_INSTRUCTOR_GUIDE.md` — ghid practic detaliat pentru predare
- `S02_02_interactive_quiz.sh` — alternativă Bash la runner-ul de quiz în Python
- Partea 6 în temă: exercițiu de verificare a înțelegerii (anti‑AI)
- detecția indicatorilor de conținut AI în autograder (informativ, fără penalizare)
- teste unitare suplimentare pentru cazuri limită și detecție AI

### Modificate
- standardizare nume fișiere: română → engleză
  - `MATERIAL_PRINCIPAL` → `MAIN_MATERIAL`
  - `prezentare.html` → `presentation.html`
  - `creeaza_tema.sh` → `create_homework.sh`
  - `demo_redirectare/filtre/bucle` → `demo_redirection/filters/loops`
- consolidarea `assignments/` în `homework/` (eliminare duplicare)
- actualizarea referințelor încrucișate în `lo_traceability.md`
- îmbunătățirea autograder-ului cu secțiune de detecție AI
- actualizarea rubricii de evaluare pentru a include Partea 6

### Corectate
- referințe rupte între documente
- căi din Makefile după restructurare
- inconsistențe în convențiile de denumire

## [1.1.0] - 2025-01-15

### Adăugate
- probleme Parsons noi (PP‑13 până la PP‑17) pentru capcane Bash frecvente
- exerciții LLM-aware cu rubrici de evaluare complete
- matrice de trasabilitate extinsă pentru toate rezultatele de învățare
- cheat sheet vizual cu diagrame SVG

### Modificate
- quiz-ul formativ extins de la 20 la 25 întrebări
- redistribuirea nivelurilor Bloom pentru nivel introductiv
- restructurarea demonstrațiilor cu curățare automată

## [1.0.0] - 2025-01-08

### Adăugate
- structură inițială de seminar conform șablonului ENos
- material principal cu 5 secțiuni tematice
- quiz formativ YAML cu 20 întrebări
- scripturi demonstrative pentru fiecare concept
- autograder Python pentru evaluarea temei
- configurare CI/CD (GitHub Actions, linting)

---

## Convenții

- **Adăugate** pentru funcționalități noi
- **Modificate** pentru schimbări în funcționalități existente
- **Depreciate** pentru funcționalități ce vor fi eliminate
- **Eliminate** pentru funcționalități scoase
- **Corectate** pentru bugfix-uri
- **Securitate** pentru vulnerabilități

---

*Întreținut de ing. dr. Antonio Clim | ASE București - CSIE*
