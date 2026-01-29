# 📜 CHANGELOG

Toate modificările notabile ale acestui proiect sunt documentate aici.

Formatul urmează [Keep a Changelog](https://keepachangelog.com/ro/1.0.0/).

---

## [1.1.0] - 2025-01-27

### Adăugat

#### Documentație
- **FAQ section** cu 20+ întrebări frecvente organizate pe categorii
- **Diagramă flowchart** ASCII a procesului de înregistrare
- **Secțiune troubleshooting extinsă** cu 20 scenarii de probleme și soluții
- **Output așteptat** după fiecare comandă din ghid
- **Limbaj încurajator** pentru începători ("Nu te panica!", "Ești pe drumul cel bun!")
- Secțiune "Sfaturi pentru Succes"
- Secțiune "Ai Reușit!" cu competențele dobândite
- Versioning în documentație

#### Code Quality - Bash Script
- **Strict mode complet**: `set -euo pipefail` + `IFS=$'\n\t'`
- Comentarii detaliate pentru strict mode
- Variabile declarate `readonly` pentru constante
- **Array-based package installation** în loc de string concatenation
- `read -r` pentru citire sigură input
- Variabile locale în funcții (`local`)
- Quoting îmbunătățit pentru toate variabilele
- Gestionare explicită a exit codes în upload (dezactivare temporară errexit)
- Versiune actualizată în header (1.1.0)

#### Code Quality - Python Script
- **Type hints complete** pentru toate funcțiile (parametri și return types)
- Import `from __future__ import annotations` pentru forward references
- Type variables (`TypeVar`) pentru funcții generice
- Docstrings îmbunătățite cu secțiuni Args, Returns, Raises, Examples
- Constante cu type annotations explicite
- Versiune actualizată în banner și docstring (1.1.0)
- Changelog în docstring-ul modulului

### Modificat

- Îmbunătățit mesajele de eroare (mai descriptive)
- Reorganizat secțiunile din GHID_STUDENT_RO.md pentru flux logic
- Actualizat instrucțiunile pentru Ubuntu 24.04 LTS
- Refactorizat validarea input-ului folosind arrays în Bash
- Standardizat formatarea în tot codul

### Corectat

- Variable quoting în Bash pentru cazuri edge cu spații
- Handling pentru `externally-managed-environment` pe Python 3.12+
- Potențiale probleme de word splitting în Bash

---

## [1.0.0] - 2025-01-21

### Adăugat

#### Funcționalități Core
- Script Python TUI cu temă Matrix (efecte vizuale, animații)
- Script Bash alternativ pentru înregistrare
- Ghid student în Markdown și HTML
- Auto-instalare dependențe (pip, rich, questionary, asciinema, openssl, sshpass)
- Semnătură criptografică RSA pentru autenticitate
- Upload automat cu retry logic (max 3 încercări)
- Salvare configurație locală pentru date precompletate
- Validare input pentru toate câmpurile

#### Interfață Utilizator
- Efecte Matrix (digital rain, glitch text, typing effect)
- Spinners și bare de progres animate
- Meniuri interactive cu navigare prin săgeți
- Culori și stiluri consistente (tema Matrix verde)
- Mesaje clare de succes/eroare/warning

#### Documentație
- README_RO.md cu instrucțiuni de bază
- GHID_STUDENT_RO.md cu pași detaliați
- GHID_STUDENT_RO.html (versiune interactivă)

---

## Versiuni Planificate

### [1.2.0] - TBD

- [ ] Suport pentru macOS (brew în loc de apt)
- [ ] Opțiune de preview înregistrare înainte de upload
- [ ] Integrare cu asciinema.org pentru vizualizare
- [ ] Mod offline complet (fără dependență de internet pentru funcționalități de bază)
- [ ] Traducere în engleză a ghidului

### [1.3.0] - TBD

- [ ] Unit tests pentru funcțiile de validare
- [ ] Integration tests pentru fluxul complet
- [ ] CI/CD pipeline pentru verificare automată
- [ ] Makefile pentru operații comune

---

## Convenții Versioning

Acest proiect folosește [Semantic Versioning](https://semver.org/):

- **MAJOR** (X.0.0): Schimbări incompatibile în API/interfață
- **MINOR** (0.X.0): Funcționalități noi, backward-compatible
- **PATCH** (0.0.X): Bug fixes, backward-compatible

---

*Menținut de: Sisteme de Operare 2023-2027 - ASE București*
