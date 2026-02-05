# S05_01 — TEMĂ: Scripting Bash avansat

> Seminar 5: Scripting Bash avansat  
> Versiune: 1.1 | Data: ianuarie 2025

---

## ⚠️ Declarație de integritate academică (OBLIGATORIU)

Includeți următorul bloc **în partea de sus a FIECĂRUI script** pe care îl predați:

```bash
#!/usr/bin/env bash
# ============================================================
# ACADEMIC INTEGRITY DECLARATION
# This script is my own work. I did not copy from other students
# or use unauthorized resources. I understand plagiarism penalties.
#
# Student Name: <YOUR_NAME>
# Group: <YOUR_GROUP>
# Date: <DATE>
# ============================================================
```

**Declarație lipsă = penalizare automată de 10%**

---

## 🎤 Cerință de susținere orală (20% din notă)

Trebuie să susțineți o scurtă apărare orală a temei.

- Format: 5–10 minute (întrebări + demonstrație live)
- Când: după predarea temei (programarea va fi anunțată)
- Vizați: explicați fiecare cerință și demonstrați că înțelegeți codul vostru
- Dacă nu puteți explica elementele de bază, puteți pica tema chiar dacă „merge”

> 💡 *Sugestie:* Pregătiți-vă să rulați scripturile și să explicați cod la întâmplare (alegere aleatorie de linii).

Detalii: `S05_04_ORAL_DEFENCE_GUIDE.md`

---

## 📁 Structura de predare

Creați un folder cu următoarea structură:

```
homework_S05_YourName/
├── README.md                 # Overview and self-assessment
├── log_analyzer.sh           # Requirement 1 (40%)
├── config_manager.sh         # Requirement 2 (30%)
├── refactored_script.sh      # Requirement 3 (30%)
├── test_files/
│   ├── sample.log            # Your test log file
│   ├── large.log             # (Optional) Large file for stress testing
│   └── app.conf              # Your test config file
└── screenshots/
    ├── log_analyzer_output.png
    ├── config_manager_output.png
    └── shellcheck_clean.png  # Proof of zero shellcheck errors
```

**Arhivați ca:** `homework_S05_YourName_GroupNumber.zip`

---

## Cerințe

### R1: Analizor de log-uri (40%)

**Script:** `log_analyzer.sh`

Creați un analizor de fișiere log care procesează fișiere în acest format:

```
[2025-01-15 10:00:00] [INFO] Application started
[2025-01-15 10:00:05] [ERROR] Connection failed
```

#### Funcționalități obligatorii

| Funcționalitate | Puncte | Descriere |
|---------|--------|-------------|
| Parsare argumente | 8 | `-h`, `-v`, `-l LEVEL`, `-o FILE`, `--top N` |
| Filtrare după nivel | 6 | arată doar log-urile cu nivelul selectat |
| Top N mesaje | 10 | cele mai frecvente N mesaje |
| Statistici | 8 | total linii, linii invalide, distribuție pe niveluri |
| Robusteză | 8 | gestionează fișier lipsă, format invalid, fără crash |

#### Exemplu de output așteptat

Salvați output-ul vostru într-un fișier: `evidence/output_log_analyzer.txt`

Exemplu:

```
=== Log Analyzer Report ===
Input: sample.log
Total lines: 150
Invalid lines: 3

Level distribution:
INFO: 120
WARN: 20
ERROR: 7

Top 5 messages:
1. Application started (45)
2. Connection failed (7)
...
```

#### Cerințe tehnice

- trebuie să folosiți `declare -A LEVEL_COUNT` pentru numărare
- trebuie să folosiți `declare -A MESSAGE_COUNT` pentru frecvența mesajelor
- funcții: `parse_line()`, `count_levels()`, `get_top_messages()`, `print_report()`
- toate funcțiile trebuie să folosească `local` pentru variabile
- trebuie să existe `set -euo pipefail` și `trap EXIT`

---

### R2: Manager de configurație (30%)

**Script:** `config_manager.sh`

Creați un manager de fișiere de configurație care gestionează fișiere `key=value`.

#### Comenzi de implementat

| Comandă | Utilizare | Descriere |
|---------|-------|-------------|
| `get` | `./config_manager.sh get HOST` | Afișează valoarea cheii |
| `set` | `./config_manager.sh set PORT 9090` | Setează/actualizează o cheie |
| `delete` | `./config_manager.sh delete DEBUG` | Șterge o cheie |
| `list` | `./config_manager.sh list` | Afișează toate perechile key=value |
| `validate` | `./config_manager.sh validate` | Verifică existența cheilor obligatorii |
| `export` | `./config_manager.sh export` | Afișează ca `export KEY=value` |

#### Comportament așteptat

```bash
$ ./config_manager.sh list
HOST=localhost
PORT=8080

$ ./config_manager.sh get PORT
8080

$ ./config_manager.sh set PORT 9090
Updated: PORT=9090

$ ./config_manager.sh validate
✓ HOST: localhost
✓ PORT: 9090
✗ DB_HOST: missing (required)
Validation failed: 1 missing key(s)
```

#### Cerințe tehnice

- trebuie să folosiți `declare -A CONFIG` pentru stocare
- trebuie să ignorați comentariile (`#`) și liniile goale
- trebuie să gestionați atât `key=value`, cât și `key = value` (spații în jurul `=`)
- funcții: `load_config()`, `save_config()`, `get_value()`, `set_value()`

---

### R3: Refactorizarea scriptului (30%)

**Script:** `refactored_script.sh`

Vi se oferă un script „rupt” (defectuos) în repo. Trebuie să îl reparați și să îl transformați într-un script robust.

#### Probleme de reparat

Trebuie să corectați cel puțin aceste 10 tipuri de probleme:

1. Lipsă `set -euo pipefail`
2. Variabile globale care ar trebui să fie `local`
3. Folosire greșită a arrays (indexate vs asociative)
4. Iterare fără quoting: `for x in ${arr[@]}`
5. Comenzi fără verificare de eroare
6. Lipsă validare argumente
7. Lipsă cleanup (trap)
8. Bug-uri de logică (output greșit)
9. Hardcoding de căi
10. Lipsă logging / debugging

#### Format de predare

În `evidence/explanation_bugfixes.txt`, listați:

- fiecare problemă identificată
- fix-ul aplicat
- motivul (de ce e o problemă)

Exemplu:

```
# BUG01: missing set -euo pipefail
Fixed by adding `set -euo pipefail` at top of script.
```

Salvați explicațiile voastre în `evidence/explanation_bugfixes.txt`.

---

## 📋 Checklist înainte de predare

### Calitatea codului

- [ ] fiecare script are declarația de integritate
- [ ] `shellcheck` rulează fără erori (0 errors)
- [ ] nu există variabile globale în funcții (folosiți `local`)
- [ ] arrays asociative declarate cu `declare -A`
- [ ] quoting corect peste tot

### Funcționalitate

- [ ] `log_analyzer.sh` funcționează pe `sample.log` și `large.log`
- [ ] `config_manager.sh` get/set/delete/list/validate/export funcționează
- [ ] scriptul refactorizat rulează fără crash

### Bune practici

- [ ] scrieți funcții clare și reutilizabile
- [ ] nu hardcodați căi
- [ ] adăugați `trap cleanup EXIT` dacă utilizați fișiere temporare

### Documentație

- [ ] README complet și clar
- [ ] fișierele `evidence/*.txt` sunt completate
- [ ] capturile de ecran există în `screenshots/`

---

## ❓ Întrebări frecvente

### General

**Î: Pot folosi AI (ChatGPT, Copilot etc.)?**  
R: Puteți, dar trebuie să declarați clar ce ați folosit și ce ați modificat. La susținerea orală trebuie să demonstrați înțelegerea completă.

**Î: Pot lucra cu un coleg?**  
R: Puteți discuta concepte, dar codul predat trebuie să fie al vostru.

### Tehnic

**Î: Ce versiune Bash trebuie?**  
R: Bash 4+ (pentru `declare -A`).

**Î: Pot folosi `awk` / `sed` / `grep`?**  
R: Da, sunt permise.

### Predare

**Î: Ce se întâmplă dacă lipsesc capturile / dovezile?**  
R: Se aplică penalizări la rubrică.

---

## 🚫 Greșeli frecvente din anii anteriori

- uitarea lui `declare -A` pentru arrays asociative
- iterarea `for x in ${arr[@]}` fără ghilimele
- folosirea variabilelor globale în funcții
- presupunerea că `set -e` oprește scriptul în orice context
- lipsa validării argumentelor
- output neclar sau lipsă `--help`

---

## 📊 Defalcarea notării

| Componentă | Puncte |
|-----------|--------|
| R1: Analizor de log-uri | 40 |
| R2: Manager de configurație | 30 |
| R3: Refactorizare | 30 |
| **Total (scris)** | **100** |

### Multiplicator pentru susținerea orală

Nota finală = nota scrisă × 0.8 + nota orală × 0.2

### Penalizări

- lipsă declarație de integritate: **-10%**
- lipsă `set -euo pipefail`: **-5%** per script
- erori shellcheck: **-2p** per eroare
- work care nu rulează: **0p** pe cerința respectivă

---

## 🆘 Cum obțineți ajutor

1. consultați materialul: `docs/S05_02_MAIN_MATERIAL.md`
2. rulați `shellcheck` și citiți mesajele
3. puneți întrebări pe canalul oficial al disciplinei (cu detalii și fragmente relevante de cod)

*Această temă este proiectată să fie dificilă. Scopul ei este să vă pregătească pentru lucrul real în shell scripting.*
