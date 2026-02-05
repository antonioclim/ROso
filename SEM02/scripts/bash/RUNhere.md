# 📁 Utilitare Bash — SEM02

> **Locație:** `SEM02/scripts/bash/`  
> **Scop:** configurare seminar, validare, instrumente interactive

## Conținut

| Script | Scop | Necesită sudo? |
|--------|---------|----------------|
| `S02_01_setup_seminar.sh` | instalează dependențe, creează workspace | Da (prima rulare) |
| `S02_02_interactive_quiz.sh` | quiz CLI cu feedback imediat | Nu |
| `S02_03_validator.sh` | validează predările pentru temă | Nu |

## Pornire rapidă

```bash
# Marchează toate scripturile ca executabile (o singură dată)
chmod +x *.sh

# Configurează mediul pentru seminar
./S02_01_setup_seminar.sh

# Quiz de exersare
./S02_02_interactive_quiz.sh

# Validează tema
./S02_03_validator.sh ~/my_homework/
```

---

## S02_01_setup_seminar.sh

**Scop:** pregătește sistemul cu toate instrumentele necesare și creează workspace-ul seminarului.

### Utilizare

```bash
./S02_01_setup_seminar.sh [options]

Options:
  --minimal     Skip optional packages (faster)
  --force       Reinstall even if packages exist
  --workspace   Create workspace directory only
  --check       Verify installation without installing
```

### Ce instalează

- pachete de sistem necesare
- dependențe Python din `requirements.txt`
- directoare pentru workspace (`~/os_seminar_sem02/`)
- fișiere exemplu pentru exerciții

### Exemplu

```bash
# Instalare completă
./S02_01_setup_seminar.sh

# Verificare rapidă (fără instalare)
./S02_01_setup_seminar.sh --check
```

---

## S02_02_interactive_quiz.sh

**Scop:** quiz în terminal pentru autoevaluare, cu feedback imediat.

### Utilizare

```bash
./S02_02_interactive_quiz.sh [options]

Options:
  --timed         30-second limit per question
  --shuffle       Randomize question order
  --hard-only     Show only difficult questions
  --count N       Limit to N questions
```

### Funcționalități

- output colorat pentru corect/greșit
- afișarea scorului pe parcurs
- explicații detaliate după fiecare răspuns
- statistici rezumative la final

### Exemplu

```bash
# Quiz standard
./S02_02_interactive_quiz.sh

# Mod cronometrat
./S02_02_interactive_quiz.sh --timed --shuffle
```

---

## S02_03_validator.sh

**Scop:** verifică temele în raport cu cerințele.

### Utilizare

```bash
./S02_03_validator.sh <submission_dir> [options]

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
| Linii shebang corecte | WARNING |
| Fără căi hardcodate | WARNING |
| Permisiuni executabile | WARNING |

### Exemplu

```bash
# Validare de bază
./S02_03_validator.sh ~/homework/

# Mod strict înainte de predare
./S02_03_validator.sh ~/homework/ --strict --report
```

---

## Dependențe

- `bash` ≥ 4.0
- `shellcheck` (pentru validare)
- utilitare Unix standard (`grep`, `sed`, `awk`)

## Depanare

| Problemă | Soluție |
|-------|----------|
| "Permission denied" | Rulează `chmod +x *.sh` |
| "shellcheck not found" | Rulează setup sau `sudo apt install shellcheck` |
| Quiz-ul nu pornește | Verifică suportul terminalului pentru culori ANSI |

---

*Vezi și: [`../demo/`](../demo/) pentru demonstrații de live coding*  
*Vezi și: [`../python/`](../python/) pentru instrumente de evaluare automată*

*Ultima actualizare: ianuarie 2026*
