# 📜 Jurnal de modificări (CHANGELOG)

Toate modificările notabile ale acestui proiect sunt documentate aici.

Formatul urmează recomandările din [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [1.1.1] - 2025-01-30

### Adăugate

#### Fișiere noi
- **check_my_submission.sh** — script de auto-verificare pentru studenți
  - Verifică existența fișierului, extensia, dimensiunea și prezența semnăturii
  - Validează formatul numelui de fișier
  - Oferă feedback clar PASS/FAIL împreună cu sugestii
- **examples/sample_submission_demo.cast** — înregistrare exemplu pentru previzualizare
  - Ilustrează cum arată o înregistrare completă
  - Include comenzi demonstrative și încheiere cu STOP_homework

#### Îmbunătățiri ale documentației
- Secțiune **Rulare de probă** în STUDENT_GUIDE, cu instrucțiuni pas cu pas
- **Traseu de escaladare** pentru suport (auto-ajutor → coleg → cadru didactic)
- Placeholder pentru tutorial video (conținut viitor)
- Anecdote „din teren” — situații reale din semestre anterioare
- Secțiune de **verificare** care explică utilizarea `check_my_submission.sh`

#### Calitate cod — script Bash
- **Mod strict complet**: `set -euo pipefail` cu `IFS=$'\n\t'`
- **Instalare pachete pe bază de array** — mai sigură decât concatenarea de șiruri
- **`read -r`** pentru citirea sigură a input-ului
- Declarații **`readonly`** pentru toate constantele
- Tratare explicită a codurilor de ieșire în încărcare cu `set +e` / `set -e`
- Îmbunătățirea citării variabilelor pentru cazuri-limită

### Modificate

- README_RO.md reorganizat (secțiuni de verificare și exemple)
- FAQ_RO.md extins (secțiune de verificare și anecdote)
- Versiunea actualizată la 1.1.1 în toate fișierele
- Varierea structurii frazelor pentru reducerea repetițiilor
- Adăugarea unor formulări naturale („Sincer, asta prinde pe cineva în fiecare semestru”)

### Remediate

- Acuratețea CHANGELOG — reflectă corect conținutul scripturilor
- Mod strict declarat, dar incomplet implementat; acum este corect
- Posibil „word splitting” în instalarea pachetelor

---

## [1.1.0] - 2025-01-27

### Adăugate

#### Documentație
- **Secțiune FAQ** cu peste 20 de întrebări frecvente, organizate pe categorii
- **Diagramă ASCII** a procesului de înregistrare
- Secțiune extinsă de depanare cu peste 20 de scenarii și soluții
- **Output așteptat** după fiecare comandă din ghid
- Limbaj de încurajare pentru începători („Nu intra în panică!”, „Ești pe drumul cel bun!”)
- Secțiune „Sfaturi pentru reușită”
- Secțiune „Ai reușit!” cu competențe dobândite
- Versionare în documentație

#### Calitate cod — script Bash
- Comentarii detaliate privind modul strict
- Variabile declarate `readonly` pentru constante
- Variabile locale în funcții (`local`)
- Citare îmbunătățită pentru toate variabilele
- Versiune actualizată în antet (1.1.0)

#### Calitate cod — script Python
- **Type hints complete** pentru toate funcțiile (parametri și return)
- Import `from __future__ import annotations` pentru forward references
- Type variables (`TypeVar`) pentru funcții generice
- Docstring-uri îmbunătățite cu secțiuni Args, Returns, Raises, Examples
- Constante cu adnotări de tip explicite
- Versiune actualizată în banner și docstring (1.1.0)
- Changelog în docstring-ul modulului

### Modificate

- Mesaje de eroare îmbunătățite (mai descriptive)
- Reorganizarea secțiunilor din STUDENT_GUIDE_RO.md pentru un flux logic
- Instrucțiuni actualizate pentru Ubuntu 24.04 LTS
- Refactorizarea validării input-ului folosind array-uri în Bash
- Standardizarea formatării în întregul cod

### Remediate

- Citarea variabilelor în Bash pentru cazuri-limită cu spații
- Tratarea situației `externally-managed-environment` pe Python 3.12+
- Posibile probleme de „word splitting” în Bash

---

## [1.0.0] - 2025-01-21

### Adăugate

#### Funcționalități de bază
- Script Python TUI cu tematică Matrix (efecte vizuale, animații)
- Script Bash alternativ pentru înregistrare
- Ghid pentru studenți în Markdown și HTML
- Instalare automată a dependențelor (pip, rich, questionary, asciinema, openssl, sshpass)
- Semnătură RSA pentru autenticitate
- Încărcare automată cu logică de retry (maxim 3 încercări)
- Salvarea locală a configurației pentru precompletarea datelor
- Validare input pentru toate câmpurile

#### Interfață utilizator
- Efecte Matrix (ploaie digitală, text „glitch”, efect de tastare)
- Indicatoare animate și bare de progres
- Meniuri interactive cu navigare din tastele săgeți
- Stiluri consecvente (tematică verde Matrix)
- Mesaje clare de succes/eroare/atenționare

#### Documentație
- README_RO.md cu instrucțiuni de bază
- STUDENT_GUIDE_RO.md cu pași detaliați
- STUDENT_GUIDE_RO.html (versiune HTML)

---

## Versiuni planificate

### [1.2.0] - TBD

- [ ] suport macOS (brew în loc de apt)
- [ ] opțiune de previzualizare a înregistrării înainte de încărcare
- [ ] integrare cu asciinema.org pentru redare
- [ ] mod offline complet (fără dependență de internet pentru funcțiile de bază)
- [ ] tutorial video (walkthrough de aproximativ 3 minute)

### [1.3.0] - TBD

- [ ] teste unitare pentru funcțiile de validare
- [ ] teste de integrare pentru întregul flux
- [ ] pipeline CI/CD pentru verificare automată
- [ ] Makefile pentru operații uzuale

---

## Convenții de versionare

Acest proiect folosește [Semantic Versioning](https://semver.org/):

- **MAJOR** (X.0.0): modificări incompatibile de API/interfață
- **MINOR** (0.X.0): funcționalități noi, compatibile înapoi
- **PATCH** (0.0.X): corecții de erori, compatibile înapoi

---

*Menținut pentru: Sisteme de Operare 2023-2027 - ASE București*
