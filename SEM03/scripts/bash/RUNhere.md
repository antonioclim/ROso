# 📁 Utilitare Bash — SEM03

> **Locație:** `SEM03/scripts/bash/`  
> **Scop:** configurare pentru seminar, validare și instrumente interactive


## Conținut

| Script | Scop | Necesită sudo? |
|--------|------|----------------|
| `S03_01_setup_seminar.sh` | Instalează dependențe, creează spațiul de lucru | Da (la prima rulare) |
| `S03_02_interactive_quiz.sh` | Chestionar CLI cu feedback imediat | Nu |
| `S03_03_validator.sh` | Validează predările pentru temă | Nu |


## Quick Start

```bash

# Fă toate scripturile executabile (o singură dată)
chmod +x *.sh


# Rulează un chestionar de antrenament
./S03_02_interactive_quiz.sh


# Validare de bază
./S03_03_validator.sh ~/homework/


# Validează tema
./S03_03_validator.sh ~/my_homework/
```

---


## S03_01_setup_seminar.sh

**Scop:** pregătește sistemul cu toate instrumentele necesare și creează spațiul de lucru al seminarului.


### Utilizare

```bash
./S03_01_setup_seminar.sh [options]

Options:
  --minimal     Skip optional packages (faster)
  --force       Reinstall even if packages exist
  --workspace   Create workspace directory only
  --check       Verify installation without installing
```


### Ce instalează

- pachete de sistem necesare
- dependențe Python din `requirements.txt`
- directoare de lucru (`~/os_seminar_sem03/`)
- fișiere exemplu pentru exerciții


### Exemplu

```bash

# Instalare completă
./S03_01_setup_seminar.sh


# Mod strict înainte de predare
./S03_03_validator.sh ~/homework/ --strict --report
```

---


## S03_02_interactive_quiz.sh

**Scop:** chestionar în terminal pentru autoevaluare, cu feedback imediat.


### Utilizare

```bash
./S03_02_interactive_quiz.sh [options]

Options:
  --timed         30-second limit per question
  --shuffle       Randomize question order
  --hard-only     Show only difficult questions
  --count N       Limit to N questions
```


### Features

- Coloured output for correct/incorrect
- Running score display
- Detailed explanations after each answer
- Summary statistics at end


### Exemplu

```bash

# Chestionar standard
./S03_02_interactive_quiz.sh


# Timed challenge mode
./S03_02_interactive_quiz.sh --timed --shuffle
```

---


## S03_03_validator.sh

**Scop:** verifică predările temei față de cerințe.


### Utilizare

```bash
./S03_03_validator.sh <submission_dir> [options]

Options:
  --strict      Fail on warnings (for final check)
  --report      Generate detailed report file
  --fix         Attempt to auto-fix common issues
  --quiet       Minimal output
```


### Ce validează

| Verificare | Severitate |
|-------|----------|
| Fișiere obligatorii prezente | ERROR |
| Sintaxă script (bash -n) | ERROR |
| Conformitate shellcheck | WARNING |
| Shebang corect | WARNING |
| Fără căi hardcodate | WARNING |
| Permisiuni de execuție | WARNING |


### Exemplu

```bash

# Basic validation
./S03_03_validator.sh ~/homework/


# Mod „provocare” cu timp limitat
./S03_02_interactive_quiz.sh --timed --shuffle
```

---


## Dependențe

- `bash` ≥ 4.0
- `shellcheck` (pentru validare)
- unelte Unix standard (`grep`, `sed`, `awk`)


## Troubleshooting

| Issue | Solution |
|-------|----------|
| "Permission denied" | Run `chmod +x *.sh` |
| "shellcheck not found" | Run setup script or `sudo apt install shellcheck` |
| Quiz won't start | Check terminal supports ANSI colours |

---

*See also: [`../demo/`](../demo/) for live coding demonstrations*  
*See also: [`../python/`](../python/) for automated grading tools*

*Last updated: January 2026*

