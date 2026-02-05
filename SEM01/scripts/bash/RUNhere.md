# 📁 Utilitare Bash — SEM01

> **Locație:** `SEM01/scripts/bash/`  
> **Scop:** Configurare seminar, validare și instrumente interactive

## Conținut

| Script | Scop | Necesită Sudo? |
|--------|------|----------------|
| `S01_01_setup_seminar.sh` | Instalare dependențe, creare spațiu lucru | Da (prima rulare) |
| `S01_02_interactive_quiz.sh` | Quiz CLI cu feedback instant | Nu |
| `S01_03_validator.sh` | Validare teme trimise | Nu |

## Pornire rapidă

```bash
# Faceți toate scripturile executabile (o singură dată)
chmod +x *.sh

# Configurare mediu seminar
./S01_01_setup_seminar.sh

# Rezolvați un quiz de practică
./S01_02_interactive_quiz.sh

# Validați tema
./S01_03_validator.sh ~/my_homework/
```

---

## S01_01_setup_seminar.sh

**Scop:** Pregătește sistemul cu toate instrumentele necesare și creează spațiul de lucru pentru seminar.

### Utilizare

```bash
./S01_01_setup_seminar.sh [opțiuni]

Opțiuni:
  --minimal     Sare pachetele opționale (mai rapid)
  --force       Reinstalează chiar dacă pachetele există
  --workspace   Creează doar directorul spațiu de lucru
  --check       Verifică instalarea fără a instala
```

### Ce instalează

- Pachete sistem necesare
- Dependențe Python din `requirements.txt`
- Directoare spațiu lucru (`~/os_seminar_sem01/`)
- Fișiere exemplu pentru exerciții

### Exemplu

```bash
# Instalare completă
./S01_01_setup_seminar.sh

# Verificare rapidă dacă totul e pregătit
./S01_01_setup_seminar.sh --check
```

---

## S01_02_interactive_quiz.sh

**Scop:** Quiz în terminal pentru autoevaluare cu feedback imediat.

### Utilizare

```bash
./S01_02_interactive_quiz.sh [opțiuni]

Opțiuni:
  --timed         Limită 30 secunde per întrebare
  --shuffle       Randomizează ordinea întrebărilor
  --hard-only     Arată doar întrebările dificile
  --count N       Limitează la N întrebări
```

### Caracteristici

- Output colorat pentru corect/incorect
- Afișare scor curent
- Explicații detaliate după fiecare răspuns
- Statistici sumare la final

### Exemplu

```bash
# Quiz standard
./S01_02_interactive_quiz.sh

# Modul provocare cronometrat
./S01_02_interactive_quiz.sh --timed --shuffle
```

---

## S01_03_validator.sh

**Scop:** Verifică temele trimise conform cerințelor.

### Utilizare

```bash
./S01_03_validator.sh <submission_dir> [opțiuni]

Opțiuni:
  --strict      Eșec la avertismente (pentru verificare finală)
  --report      Generează fișier raport detaliat
  --fix         Încearcă auto-corectare probleme comune
  --quiet       Output minimal
```

### Ce validează

| Verificare | Severitate |
|------------|------------|
| Fișiere necesare prezente | EROARE |
| Sintaxă script (bash -n) | EROARE |
| Conformitate shellcheck | AVERTISMENT |
| Linii shebang corecte | AVERTISMENT |
| Fără căi hardcodate | AVERTISMENT |
| Permisiuni executabile | AVERTISMENT |

### Exemplu

```bash
# Validare de bază
./S01_03_validator.sh ~/homework/

# Mod strict înainte de trimitere
./S01_03_validator.sh ~/homework/ --strict --report
```

---

## Dependențe

- `bash` ≥ 4.0
- `shellcheck` (pentru validare)
- Instrumente Unix standard (`grep`, `sed`, `awk`)

## Depanare

| Problemă | Soluție |
|----------|---------|
| „Permission denied" | Rulați `chmod +x *.sh` |
| „shellcheck not found" | Rulați scriptul setup sau `sudo apt install shellcheck` |
| Quiz-ul nu pornește | Verificați că terminalul suportă culori ANSI |

---

*Vezi și: [`../demo/`](../demo/) pentru demonstrații live coding*  
*Vezi și: [`../python/`](../python/) pentru instrumente notare automată*

*Ultima actualizare: Ianuarie 2026*
