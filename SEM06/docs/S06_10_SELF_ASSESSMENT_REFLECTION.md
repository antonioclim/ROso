# Autoevaluare - CAPSTONE Bash Scripting

> **Sisteme de Operare** | ASE București - CSIE
> Seminar 6: Proiecte CAPSTONE

---

## Scop

Acest document te ajută să îți evaluezi progresul și să identifici ariile care necesită îmbunătățire. Completează-l **onest** - scopul nu este nota, ci înțelegerea propriului nivel.

---

## Rubric de Autoevaluare

### Cum să te evaluezi

| Nivel | Descriere | Indicator |
|-------|-----------|-----------|
| ⬜ **0 - Nu știu** | Nu am auzit de concept | Nu pot explica deloc |
| 🟨 **1 - Începător** | Am văzut, dar nu folosesc | Pot recunoaște, dar nu pot scrie |
| 🟧 **2 - Familiar** | Pot folosi cu documentație | Trebuie să caut sintaxa |
| 🟩 **3 - Competent** | Pot folosi independent | Scriu corect din prima |
| 🟦 **4 - Avansat** | Pot explica altora | Înțeleg nuanțele și edge cases |

---

## SECȚIUNEA 1: Fundamentele Bash

### 1.1 Variabile și Expansiune

| Concept | Auto | Verificare |
|---------|------|------------|
| Declarare variabile simple | ⬜🟨🟧🟩🟦 | `var="value"` |
| Variabile `readonly` | ⬜🟨🟧🟩🟦 | `readonly CONST="fix"` |
| Variabile `local` în funcții | ⬜🟨🟧🟩🟦 | `local x=10` |
| Default values `${var:-default}` | ⬜🟨🟧🟩🟦 | Când `var` e unset |
| Error on unset `${var:?error}` | ⬜🟨🟧🟩🟦 | Eșuează dacă `var` e unset |
| String length `${#var}` | ⬜🟨🟧🟩🟦 | Număr caractere |
| Substring removal `${var%pattern}` | ⬜🟨🟧🟩🟦 | Suffix matching |
| Pattern replacement `${var//old/new}` | ⬜🟨🟧🟩🟦 | Înlocuire globală |

**📝 Reflecție:** Ce expansiune de variabilă folosești cel mai des? Ce nu ai folosit niciodată?

```
[Răspuns]

```

### 1.2 Variabile Speciale

| Concept | Auto | Verificare |
|---------|------|------------|
| `$0` - numele scriptului | ⬜🟨🟧🟩🟦 | |
| `$1, $2, ...` - argumente | ⬜🟨🟧🟩🟦 | |
| `$#` - număr argumente | ⬜🟨🟧🟩🟦 | |
| `"$@"` vs `"$*"` diferența | ⬜🟨🟧🟩🟦 | Quoting și word splitting |
| `$$` - PID curent | ⬜🟨🟧🟩🟦 | |
| `$?` - exit code | ⬜🟨🟧🟩🟦 | |
| `$!` - PID background | ⬜🟨🟧🟩🟦 | |

---

## SECȚIUNEA 2: Structuri de Control

### 2.1 Condiții

| Concept | Auto | Verificare |
|---------|------|------------|
| Sintaxa `if/elif/else/fi` | ⬜🟨🟧🟩🟦 | |
| `[[ ]]` vs `[ ]` diferența | ⬜🟨🟧🟩🟦 | Extended vs POSIX |
| Comparații string (`==`, `!=`, `<`) | ⬜🟨🟧🟩🟦 | |
| Comparații numerice (`-eq`, `-lt`, `-ge`) | ⬜🟨🟧🟩🟦 | |
| `(( ))` pentru aritmetică | ⬜🟨🟧🟩🟦 | |
| Teste fișiere (`-f`, `-d`, `-r`, `-w`, `-x`) | ⬜🟨🟧🟩🟦 | |
| Regex matching `[[ $var =~ regex ]]` | ⬜🟨🟧🟩🟦 | |
| Operatori logici (`&&`, `||`, `!`) | ⬜🟨🟧🟩🟦 | |

**📝 Test:** Ce returnează `[[ -z "" ]]`?

```
[Răspuns]

```

### 2.2 Bucle

| Concept | Auto | Verificare |
|---------|------|------------|
| `for` C-style `for ((i=0; i<10; i++))` | ⬜🟨🟧🟩🟦 | |
| `for item in list` | ⬜🟨🟧🟩🟦 | |
| `for` pe array `for item in "${arr[@]}"` | ⬜🟨🟧🟩🟦 | |
| `while` cu condiție | ⬜🟨🟧🟩🟦 | |
| `while read` pentru fișiere | ⬜🟨🟧🟩🟦 | |
| `until` | ⬜🟨🟧🟩🟦 | |
| `break` și `continue` | ⬜🟨🟧🟩🟦 | |

**📝 Test:** De ce `for file in $(ls *.txt)` e problematic?

```
[Răspuns]

```

### 2.3 Case Statement

| Concept | Auto | Verificare |
|---------|------|------------|
| Sintaxa `case/esac` | ⬜🟨🟧🟩🟦 | |
| Pattern matching în `case` | ⬜🟨🟧🟩🟦 | |
| Multiple patterns `pattern1|pattern2)` | ⬜🟨🟧🟩🟦 | |
| Default case `*)` | ⬜🟨🟧🟩🟦 | |

---

## SECȚIUNEA 3: Funcții

| Concept | Auto | Verificare |
|---------|------|------------|
| Declarare funcție | ⬜🟨🟧🟩🟦 | |
| Parametri poziționali în funcții | ⬜🟨🟧🟩🟦 | |
| `local` variables | ⬜🟨🟧🟩🟦 | |
| Return values vs exit codes | ⬜🟨🟧🟩🟦 | |
| Command substitution pentru output | ⬜🟨🟧🟩🟦 | `result=$(func)` |
| Passing arrays | ⬜🟨🟧🟩🟦 | |
| Nameref `local -n` | ⬜🟨🟧🟩🟦 | Bash 4.3+ |

**📝 Test:** Ce e diferența între `return 1` și `exit 1` într-o funcție?

```
[Răspuns]

```

---

## SECȚIUNEA 4: Arrays

### 4.1 Arrays Indexate

| Concept | Auto | Verificare |
|---------|------|------------|
| Declarare `arr=()` | ⬜🟨🟧🟩🟦 | |
| Acces element `${arr[0]}` | ⬜🟨🟧🟩🟦 | |
| Toate elementele `${arr[@]}` | ⬜🟨🟧🟩🟦 | |
| Număr elemente `${#arr[@]}` | ⬜🟨🟧🟩🟦 | |
| Toți indicii `${!arr[@]}` | ⬜🟨🟧🟩🟦 | |
| Adăugare `arr+=("new")` | ⬜🟨🟧🟩🟦 | |
| Slice `${arr[@]:1:3}` | ⬜🟨🟧🟩🟦 | |

### 4.2 Arrays Asociative

| Concept | Auto | Verificare |
|---------|------|------------|
| Declarare `declare -A map` | ⬜🟨🟧🟩🟦 | |
| Setare `map[key]="value"` | ⬜🟨🟧🟩🟦 | |
| Acces `${map[key]}` | ⬜🟨🟧🟩🟦 | |
| Toate cheile `${!map[@]}` | ⬜🟨🟧🟩🟦 | |
| Verificare cheie `-v map[key]` | ⬜🟨🟧🟩🟦 | |

**📝 Test:** De ce TREBUIE să folosești `"${arr[@]}"` cu ghilimele?

```
[Răspuns]

```

---

## SECȚIUNEA 5: I/O și Redirectări

| Concept | Auto | Verificare |
|---------|------|------------|
| Stdout redirect `>` și `>>` | ⬜🟨🟧🟩🟦 | |
| Stderr redirect `2>` | ⬜🟨🟧🟩🟦 | |
| Combined `&>` sau `2>&1` | ⬜🟨🟧🟩🟦 | |
| Pipe `|` | ⬜🟨🟧🟩🟦 | |
| Process substitution `<(cmd)` | ⬜🟨🟧🟩🟦 | |
| Here-doc `<< EOF` | ⬜🟨🟧🟩🟦 | |
| Here-string `<<<` | ⬜🟨🟧🟩🟦 | |
| File descriptors (`exec 3>`, etc.) | ⬜🟨🟧🟩🟦 | |

---

## SECȚIUNEA 6: Procesare Text

### 6.1 Grep

| Concept | Auto | Verificare |
|---------|------|------------|
| Pattern matching de bază | ⬜🟨🟧🟩🟦 | |
| `-i` case insensitive | ⬜🟨🟧🟩🟦 | |
| `-v` invert match | ⬜🟨🟧🟩🟦 | |
| `-E` extended regex | ⬜🟨🟧🟩🟦 | |
| `-o` only matching | ⬜🟨🟧🟩🟦 | |
| `-r` recursive | ⬜🟨🟧🟩🟦 | |
| `-l` și `-L` file names | ⬜🟨🟧🟩🟦 | |

### 6.2 Sed

| Concept | Auto | Verificare |
|---------|------|------------|
| Substitution `s/old/new/` | ⬜🟨🟧🟩🟦 | |
| Global `s/old/new/g` | ⬜🟨🟧🟩🟦 | |
| In-place `-i` | ⬜🟨🟧🟩🟦 | |
| Delete lines `/pattern/d` | ⬜🟨🟧🟩🟦 | |
| Print specific lines `-n 'Np'` | ⬜🟨🟧🟩🟦 | |
| Range `5,10` | ⬜🟨🟧🟩🟦 | |

### 6.3 Awk

| Concept | Auto | Verificare |
|---------|------|------------|
| Print columns `{print $1}` | ⬜🟨🟧🟩🟦 | |
| Field separator `-F:` | ⬜🟨🟧🟩🟦 | |
| Pattern matching `/pattern/` | ⬜🟨🟧🟩🟦 | |
| NR, NF variabile | ⬜🟨🟧🟩🟦 | |
| BEGIN/END blocks | ⬜🟨🟧🟩🟦 | |
| Arithmetic în awk | ⬜🟨🟧🟩🟦 | |

---

## SECȚIUNEA 7: Error Handling

| Concept | Auto | Verificare |
|---------|------|------------|
| `set -e` exit on error | ⬜🟨🟧🟩🟦 | |
| `set -u` undefined vars | ⬜🟨🟧🟩🟦 | |
| `set -o pipefail` | ⬜🟨🟧🟩🟦 | |
| `trap` pentru cleanup | ⬜🟨🟧🟩🟦 | |
| `trap` pentru semnale | ⬜🟨🟧🟩🟦 | |
| Exit codes personalizate | ⬜🟨🟧🟩🟦 | |
| Pattern `cmd || { error; }` | ⬜🟨🟧🟩🟦 | |
| Retry logic | ⬜🟨🟧🟩🟦 | |

**📝 Test:** Ce face `set -euo pipefail`?

```
[Răspuns]

```

---

## SECȚIUNEA 8: Proiecte CAPSTONE

### 8.1 Monitor System

| Competență | Auto | Dovadă |
|------------|------|--------|
| Pot parsa `/proc/stat` pentru CPU | ⬜🟨🟧🟩🟦 | |
| Pot calcula % CPU usage | ⬜🟨🟧🟩🟦 | |
| Pot parsa `/proc/meminfo` | ⬜🟨🟧🟩🟦 | |
| Pot implementa threshold alerting | ⬜🟨🟧🟩🟦 | |
| Pot genera output JSON | ⬜🟨🟧🟩🟦 | |
| Înțeleg load average | ⬜🟨🟧🟩🟦 | |

### 8.2 Backup System

| Competență | Auto | Dovadă |
|------------|------|--------|
| Pot crea archive cu `tar` | ⬜🟨🟧🟩🟦 | |
| Înțeleg backup incremental | ⬜🟨🟧🟩🟦 | |
| Pot implementa rotație | ⬜🟨🟧🟩🟦 | |
| Pot verifica integritate | ⬜🟨🟧🟩🟦 | |
| Înțeleg opțiunile de compresie | ⬜🟨🟧🟩🟦 | |
| Pot implementa locking | ⬜🟨🟧🟩🟦 | |

### 8.3 Deployer

| Competență | Auto | Dovadă |
|------------|------|--------|
| Înțeleg rolling deployment | ⬜🟨🟧🟩🟦 | |
| Înțeleg blue-green deployment | ⬜🟨🟧🟩🟦 | |
| Înțeleg canary deployment | ⬜🟨🟧🟩🟦 | |
| Pot implementa health checks | ⬜🟨🟧🟩🟦 | |
| Pot implementa rollback | ⬜🟨🟧🟩🟦 | |
| Pot gestiona hooks | ⬜🟨🟧🟩🟦 | |

---

## SECȚIUNEA 9: Debugging și Testing

| Concept | Auto | Verificare |
|---------|------|------------|
| `set -x` pentru debugging | ⬜🟨🟧🟩🟦 | |
| `bash -n` syntax check | ⬜🟨🟧🟩🟦 | |
| ShellCheck usage | ⬜🟨🟧🟩🟦 | |
| Scriere unit tests | ⬜🟨🟧🟩🟦 | |
| Test assertions (`assert_equals`, etc.) | ⬜🟨🟧🟩🟦 | |
| Setup/teardown pattern | ⬜🟨🟧🟩🟦 | |
| Mocking în Bash | ⬜🟨🟧🟩🟦 | |

---

## SECȚIUNEA 10: Sistemd și Automatizare

| Concept | Auto | Verificare |
|---------|------|------------|
| Format crontab | ⬜🟨🟧🟩🟦 | |
| Scriere service systemd | ⬜🟨🟧🟩🟦 | |
| Scriere timer systemd | ⬜🟨🟧🟩🟦 | |
| `systemctl` comenzi | ⬜🟨🟧🟩🟦 | |
| `journalctl` pentru logs | ⬜🟨🟧🟩🟦 | |

---

## CALCULARE SCOR

### Instrucțiuni
1. Numără câte competențe ai marcat la fiecare nivel
2. Calculează scorul ponderat
3. Identifică ariile de îmbunătățire

### Tabel Scor

| Nivel | Număr competențe | Multiplicator | Subtotal |
|-------|------------------|---------------|----------|
| ⬜ 0 | | × 0 | |
| 🟨 1 | | × 1 | |
| 🟧 2 | | × 2 | |
| 🟩 3 | | × 3 | |
| 🟦 4 | | × 4 | |
| **Total** | | | |

**Scor maxim posibil:** ~400 puncte (100 competențe × 4)

### Interpretare Scor

| Procent | Nivel | Recomandare |
|---------|-------|-------------|
| 0-25% | Începător | Focus pe fundamentale, parcurge docs S06_00-S06_02 |
| 26-50% | Intermediar | Practică activă, completează proiectele CAPSTONE |
| 51-75% | Competent | Aprofundează testing și error handling |
| 76-100% | Avansat | Mentorează colegi, contribuie cu îmbunătățiri |

---

## PLAN DE ACȚIUNE

### Top 3 Arii de Îmbunătățit

1. **Arie:**
   - **Scor curent:**
   - **Scor țintă:**
   - **Acțiuni concrete:**
   
2. **Arie:**

- **Scor curent:**
- **Scor țintă:**
- **Acțiuni concrete:**


3. **Arie:**
   - **Scor curent:**
   - **Scor țintă:**
   - **Acțiuni concrete:**

### Resurse pentru Îmbunătățire

| Arie | Resursă recomandată |
|------|---------------------|
| Variabile/Expansiune | `docs/S06_09_VISUAL_CHEAT_SHEET.md` |
| Control Flow | `docs/projects/S06_P01_Project_Architecture.md` |
| Funcții/Arrays | `docs/projects/S06_P01_Project_Architecture.md` |
| I/O/Text Processing | `docs/projects/S06_P02_Monitor_Implementation.md` |
| Error Handling | `docs/projects/S06_P06_Error_Handling.md` |
| Testing | `docs/projects/S06_P05_Testing_Framework.md` |
| Proiecte | Cod sursă în `scripts/projects/` |

---

## TRACKING PROGRES

| Data | Scor Total | Note |
|------|------------|------|
| | | |
| | | |
| | | |
| | | |

---

## REFLECȚIE FINALĂ

### Ce am învățat cel mai bine?

```
[Răspuns]

```

### Ce mi se pare încă dificil?

```
[Răspuns]

```

### Ce mă motivează să continui?

```
[Răspuns]

```

### Un lucru pe care îl voi face diferit data viitoare:

```
[Răspuns]

```

---

*Document de Autoevaluare pentru Sisteme de Operare | ASE București - CSIE*
*Seminar 6 CAPSTONE | Completează-l la începutul și sfârșitul modulului*
