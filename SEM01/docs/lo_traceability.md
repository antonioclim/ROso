# Learning Outcomes Traceability - Seminar 1

## Obiective de Învățare (Learning Outcomes)

| ID | Obiectiv | Bloom | Verificare |
|----|----------|-------|------------|
| LO1.1 | Identifică comenzile de navigare în sistemul de fișiere | Remember | Quiz Q01 |
| LO1.2 | Descrie structura FHS (Filesystem Hierarchy Standard) | Remember | Quiz Q02 |
| LO2.1 | Explică diferența dintre shell și terminal | Understand | Quiz Q03 |
| LO2.2 | Diferențiază căi absolute de căi relative | Understand | Quiz Q04 |
| LO3.1 | Explică comportamentul variabilelor de mediu | Understand | Quiz Q05 |
| LO4.1 | Utilizează mkdir pentru structuri de directoare | Apply | Quiz Q06 |
| LO4.2 | Aplică source pentru a reîncărca configurații | Apply | Quiz Q07 |
| LO5.1 | Utilizează brace expansion pentru operații multiple | Apply | Quiz Q08 |
| LO6.1 | Analizează diferența dintre single și double quotes | Analyse | Quiz Q09 |
| LO6.2 | Interpretează exit codes pentru depanare | Analyse | Quiz Q10 |

## Matrice Trasabilitate

| LO | Parsons | Quiz | Sprint | Live Coding | LLM Exercise |
|----|---------|------|--------|-------------|--------------|
| LO1.1 | - | Q01 | S1 | - | - |
| LO1.2 | - | Q02 | S1 | - | - |
| LO2.1 | - | Q03 | - | LC1 | - |
| LO2.2 | PP-A | Q04 | S2 | - | - |
| LO3.1 | PP-B | Q05 | - | LC2 | LLM1 |
| LO4.1 | PP-C | Q06 | S3 | - | - |
| LO4.2 | - | Q07 | - | LC3 | - |
| LO5.1 | PP-D | Q08 | S4 | - | LLM2 |
| LO6.1 | PP-E | Q09 | - | LC4 | - |
| LO6.2 | - | Q10 | S5 | - | - |

## Distribuție Bloom Taxonomy

| Nivel | Target | Actual |
|-------|--------|--------|
| Remember | 20% | 20% (2/10) |
| Understand | 30% | 30% (3/10) |
| Apply | 30% | 30% (3/10) |
| Analyse | 20% | 20% (2/10) |

---

## Parsons Problems cu Distractori Bash-Specifici

### PP-A: Verificare Director cu Exit Code

**Obiectiv:** Verifică dacă un director dat există și afișează mesaj corespunzător.

**Linii de cod (amestecate + distractori):**

```
#!/bin/bash
[ -d $1 ]                    # DISTRACTOR: lipsesc ghilimele
[ -d "$1" ]
[ -f "$1" ]                  # DISTRACTOR: -f e pentru fișiere
if [ -d "$1" ]; then
if [ -d "$1" ]               # DISTRACTOR: lipsește ; then
    echo "Directorul există"
    echo Directorul există   # DISTRACTOR: lipsesc ghilimele
else
    echo "Directorul NU există"
fi
```

<details>
<summary>Soluție</summary>

```bash
#!/bin/bash
if [ -d "$1" ]; then
    echo "Directorul există"
else
    echo "Directorul NU există"
fi
```

**Explicații distractori:**
- `[ -d $1 ]` — fără ghilimele, word splitting poate cauza erori dacă path-ul are spații
- `[ -f "$1" ]` — `-f` verifică fișiere, nu directoare
- `if [ -d "$1" ]` — lipsește `; then` sau newline înainte de `then`
- `echo Directorul există` — funcționează, dar ghilimelele sunt recomandate pentru claritate

</details>

---

### PP-B: Export Variabilă în Subshell

**Obiectiv:** Setează o variabilă și fă-o disponibilă într-un subshell.

**Linii de cod (amestecate + distractori):**

```
#!/bin/bash
export $NUME="Student"       # DISTRACTOR: $ în stânga
NUME = "Student"             # DISTRACTOR: spații la =
NUME="Student"
export NUME
bash -c 'echo "Salut $NUME"'
bash -c "echo 'Salut $NUME'" # DISTRACTOR: expandează în shell-ul părinte
```

<details>
<summary>Soluție</summary>

```bash
#!/bin/bash
NUME="Student"
export NUME
bash -c 'echo "Salut $NUME"'
```

**Explicații distractori:**
- `export $NUME="Student"` — nu folosim $ când atribuim valoare
- `NUME = "Student"` — spațiile în jurul `=` fac ca Bash să interpreteze ca comandă
- `bash -c "echo 'Salut $NUME'"` — variabila se expandează în shell-ul părinte, nu în subshell

</details>

---

### PP-C: Backup cu Timestamp

**Obiectiv:** Creează o copie de backup a unui fișier cu timestamp.

**Linii de cod (amestecate + distractori):**

```
#!/bin/bash
TIMESTAMP=`date +%Y%m%d`     # DISTRACTOR: backticks depreciate
TIMESTAMP = $(date +%Y%m%d)  # DISTRACTOR: spații la =
TIMESTAMP=$(date +%Y%m%d)
FISIER="document.txt"
BACKUP=${FISIER}.${TIMESTAMP}.bak
cp "$FISIER" "$BACKUP"
cp $FISIER $BACKUP           # DISTRACTOR: lipsesc ghilimele
echo "Backup creat: $BACKUP"
```

<details>
<summary>Soluție</summary>

```bash
#!/bin/bash
TIMESTAMP=$(date +%Y%m%d)
FISIER="document.txt"
BACKUP="${FISIER}.${TIMESTAMP}.bak"
cp "$FISIER" "$BACKUP"
echo "Backup creat: $BACKUP"
```

**Explicații distractori:**
- `` `date +%Y%m%d` `` — backticks funcționează dar sunt depreciate; folosește `$(...)`
- `TIMESTAMP = $(...)` — spațiile fac ca Bash să interpreteze greșit
- `cp $FISIER $BACKUP` — funcționează, dar nesigur cu fișiere cu spații în nume

</details>

---

### PP-D: Listare Fișiere cu Pattern

**Obiectiv:** Listează toate fișierele .sh și .py și numără-le.

**Linii de cod (amestecate + distractori):**

```
#!/bin/bash
contor=0
for fisier in *.sh *.py; do
for $fisier in *.sh *.py; do  # DISTRACTOR: $ în variabila loop
for fisier in *.sh,py; do     # DISTRACTOR: virgulă nu e valid
    if [ -f "$fisier" ]; then
        echo "Găsit: $fisier"
        ((contor++))
        contor++              # DISTRACTOR: lipsește $((...))
    fi
done
echo "Total: $contor fișiere"
```

<details>
<summary>Soluție</summary>

```bash
#!/bin/bash
contor=0
for fisier in *.sh *.py; do
    if [ -f "$fisier" ]; then
        echo "Găsit: $fisier"
        ((contor++))
    fi
done
echo "Total: $contor fișiere"
```

**Explicații distractori:**
- `for $fisier` — nu folosim $ când declarăm variabila de iterație
- `*.sh,py` — virgula nu funcționează pentru multiple pattern-uri; folosește spațiu
- `contor++` — în Bash, incrementarea necesită `((contor++))` sau `contor=$((contor+1))`

</details>

---

### PP-E: Funcție cu Validare Parametri

**Obiectiv:** Definește o funcție care salută un utilizator, cu validare parametri.

**Linii de cod (amestecate + distractori):**

```
#!/bin/bash
function saluta {            # DISTRACTOR: lipsesc ()
saluta() {
    if [ -z "$1" ]; then
    if [ -z $1 ]; then       # DISTRACTOR: lipsesc ghilimele
        echo "Eroare: Specifică un nume"
        exit 1               # DISTRACTOR: exit închide script-ul
        return 1
    fi
    echo "Salut, $1!"
}
saluta "Maria"
saluta                       # Testează eroarea
```

<details>
<summary>Soluție</summary>

```bash
#!/bin/bash
saluta() {
    if [ -z "$1" ]; then
        echo "Eroare: Specifică un nume"
        return 1
    fi
    echo "Salut, $1!"
}
saluta "Maria"
saluta                       # Testează eroarea
```

**Explicații distractori:**
- `function saluta {` — sintaxă validă dar non-POSIX; preferă `saluta() {`
- `[ -z $1 ]` — fără ghilimele, dacă $1 e gol, comanda devine `[ -z ]` care e eroare
- `exit 1` — închide întregul script; în funcții folosim `return`

</details>

---

## Notă Metodologică

Distractorii sunt selectați pe baza erorilor frecvente observate la studenți:
- 70% — spații la atribuire (VAR = "val")
- 60% — lipsă ghilimele la variabile
- 45% — confuzie single/double quotes
- 40% — backticks în loc de $()
- 35% — $ în stânga la atribuire

Fiecare distractor reprezintă o eroare reală de sintaxă sau comportament neașteptat.
