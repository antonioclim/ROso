# Changelog — Seminarul 03 (Sisteme de Operare)

Toate modificările notabile pentru acest seminar sunt documentate aici.
Format bazat pe [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [1.2.0] — 2025-01-29

### Adăugiri
- `quiz_runner.py` — în sfârșit! Studenții cereau de două semestre o versiune interactivă
  în locul acelui fișier JSON pe care nu-l deschidea nimeni
- `.shellcheckrc` cu reguli adaptate — m-am săturat să explic de ce avem avertismente 
  intenționate în demonstrații
- Secțiune „Provocări de verificare" în temă — măsuri anti-ChatGPT
- Întrebări capcană în quiz.yaml — răspunsul „evident" este greșit
- Exercițiu „Code Archaeology" — depanare cod vechi în loc de generare cod nou
- Întrebări de reflecție în Auto-evaluare — întrebări metacognitive autentice
- „Lecții învățate" în README — ce a funcționat și ce nu, plus feedback de la studenți
- Depanare pentru instructori — cazurile ciudate pe care le-am întâlnit

### Modificări
- S03_00 redenumit pentru consistență cu celelalte seminare
- Ghid instructor: adăugate note personale din experiența la clasă
- Exerciții LLM-Aware: consolidate cu exerciții care nu pot fi rezolvate doar cu AI
- Validator: comentarii mai detaliate și tratare îmbunătățită a erorilor
- README: adăugat context specific ASE și corelații cu alte cursuri

### Șterse
- Fișiere duplicate RO/EN din homework/ (păstrat doar versiunea engleză)
- `__pycache__/` — nu ar fi trebuit să fie în arhivă de la început

### Lecții învățate
Feedback-ul de la cohorta 23 a fost brutal dar util:
> „Exercițiile LLM sunt ok dar tot pot să trișez oricum"

Așa că am adăugat verificări practice: capturi de ecran cu timestamp, 
depanare live la laborator și explicații orale. Să vedem cum trișează acum.

---

## [1.1.0] — 2025-01-15

### Adăugiri
- Diagrame SVG în `docs/images/` — permissions_matrix.svg a fost un succes
- Structură aliniată la convenția ENos (homework, tests și presentations)
- PP-06 și PP-07 în lo_traceability.md
- Engleză britanică consistentă pe tot parcursul (da, contează la nivel academic)

### Modificări
- Makefile adaptat la noua structură de directoare
- Corecturi ortografice minore

### Notă
Am abandonat ideea de a include exerciții ACL.
Prea mult pentru semestrul 3 având în vedere că studenții abia au digerat chmod.
Poate pentru un seminar avansat opțional.

---

## [1.0.0] — 2025-01-08

### Prima versiune stabilă
- 4 module complete: find/xargs, getopts, permisiuni și cron
- Framework Brown & Wilson integrat
- Testat pe Ubuntu 24.04 LTS în laboratorul Dorobanți
- 35+ misconceptii documentate din sesiunile anterioare

### Probleme cunoscute
- Demo-ul cron nu funcționează în WSL fără `sudo service cron start`
- Unii studenți au macOS și se plâng că find e diferit
  (nu e un bug ci o funcționalitate — GNU vs BSD)

---

## [0.9.0] — 2024-12-20 (beta intern)

### Pentru testare
- Schițe pentru toate documentele
- Scripturi funcționale dar fără finisaj
- Testat doar pe calculatorul meu

### TODO pentru v1.0
- [x] Întrebări Peer Instruction
- [x] Parsons Problems
- [x] Exerciții LLM-aware
- [x] Validator complet
- [x] Autograder Python

---

## Note de dezvoltare

### De ce această structură?
Am încercat mai multe variante înainte să ajung aici:
1. Un singur PDF mare — nimeni nu-l citea
2. Fișiere separate fără prefix — haos la sortare
3. Structura actuală cu S03_XX_ — funcționează

### Convenții de versionare
- MAJOR: restructurare completă sau modificări incompatibile
- MINOR: conținut nou și îmbunătățiri semnificative
- PATCH: corecturi de erori, typo-uri și ajustări minore

### Cum să contribui
Deschide un issue pe GitHub sau trimite-mi un email direct.
Pull request-urile sunt binevenite dar trec prin review.

---

*Menținut de ing. dr. Antonio Clim | ASE-CSIE București*
