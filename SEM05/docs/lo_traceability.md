# Matrice Trasabilitate Learning Outcomes

> Sisteme de Operare | ASE București - CSIE  
> Seminar 5: Advanced Bash Scripting  
> Versiune: 1.0.0 | Data: 2025-01

---

## 1. Obiective de Învățare (Learning Outcomes)

| ID | Learning Outcome | Nivel Bloom |
|----|------------------|-------------|
| **LO1** | Definește funcții cu variabile locale folosind `local` | Apply |
| **LO2** | Explică diferența între variabile globale și locale în funcții | Understand |
| **LO3** | Folosește `echo` pentru returnarea valorilor din funcții | Apply |
| **LO4** | Declară și manipulează arrays indexate | Apply |
| **LO5** | Declară și folosește arrays asociative cu `declare -A` | Apply |
| **LO6** | Iterează corect prin arrays folosind ghilimele | Apply |
| **LO7** | Explică efectele `set -e`, `set -u`, `set -o pipefail` | Understand |
| **LO8** | Implementează trap pentru cleanup la EXIT | Apply |
| **LO9** | Identifică excepțiile unde `set -e` NU funcționează | Analyse |
| **LO10** | Scrie scripturi folosind template-ul profesional | Create |

---

## 2. Matrice Trasabilitate: LO → Activități

| LO | Material Principal | Peer Instruction | Parsons | Live Coding | Exerciții Sprint | Quiz |
|----|--------------------|------------------|---------|-------------|------------------|------|
| **LO1** | §1.1-1.2 | Q1 | P1 | LC1.2 | E1 | q01, q15 |
| **LO2** | §1.2 | Q1, Q3 | P1 | LC1.2 | E1 | q01, q02, q03 |
| **LO3** | §1.3 | Q2 | P2 | LC1.3 | E2 | q02 |
| **LO4** | §2.1 | Q4, Q7 | P3 | LC2.1 | E3 | q04, q07 |
| **LO5** | §2.2 | Q5 | P4 | LC2.2 | E4 | q05, q16 |
| **LO6** | §2.3 | Q6 | P3 | LC2.3 | E5 | q06 |
| **LO7** | §4.1-4.3 | Q8-Q12 | P5 | LC3.1 | E6 | q08-q12, q17, q18 |
| **LO8** | §5.1-5.2 | Q13, Q14 | P5 | LC3.2 | E7 | q13, q14 |
| **LO9** | §4.4 | Q9, Q10 | - | LC3.1 | E8 | q09, q10, q12 |
| **LO10** | §8 | - | - | LC4.1 | E9 | - |

### Legendă

- **Material Principal**: Secțiuni din `S05_02_MATERIAL_PRINCIPAL.md`
- **Peer Instruction**: Întrebări din `S05_03_PEER_INSTRUCTION.md`
- **Parsons**: Probleme Parsons din secțiunea 3 de mai jos
- **Live Coding**: Sesiuni din `S05_05_LIVE_CODING_GUIDE.md`
- **Exerciții Sprint**: Exerciții din `S05_06_EXERCITII_SPRINT.md`
- **Quiz**: Întrebări din `formative/quiz.yaml`

---

## 3. Parsons Problems cu Distractori Bash-Specifici

Fiecare problemă include **distractori** — linii greșite ce testează misconceptii comune.

---

### P1: Funcție cu Variabilă Locală

**Obiectiv LO1, LO2**: Demonstrează importanța `local` pentru variabile în funcții.

**Context**: Creează o funcție care numără caractere fără a modifica variabila globală.

#### Linii de aranjat (amestecate):

```
A) echo "Global: $count"
B) count_chars "hello world"
C) local count=${#1}
D) count=100
E) echo "În funcție: $count"
F) }
G) count_chars() {
```

#### Distractori (linii GREȘITE):

```
X1) count_chars {           # Lipsește ()
X2) count = ${#1}           # Spații în jurul =
X3) var count=${#1}         # var nu există în Bash
```

<details>
<summary>Soluție</summary>

**Ordinea corectă: D, G, C, E, F, B, A**

```bash
count=100
count_chars() {
    local count=${#1}
    echo "În funcție: $count"
}
count_chars "hello world"
echo "Global: $count"
```

**Output:**
```
În funcție: 11
Global: 100
```

**Punct cheie**: `local` previne modificarea variabilei globale. Fără `local`, count ar deveni 11.

**De ce distractorii sunt greșiți:**
- `X1`: Funcțiile necesită `()` sau keyword `function`
- `X2`: Bash nu permite spații în jurul `=` la atribuire
- `X3`: `var` nu este keyword valid în Bash; folosește `local`

</details>

---

### P2: Funcție cu Return Value prin Echo

**Obiectiv LO3**: Folosirea `echo` pentru returnarea valorilor.

**Context**: Creează o funcție care calculează suma a două numere.

#### Linii de aranjat (amestecate):

```
A) result=$(add_numbers 5 3)
B) add_numbers() {
C) local sum=$(( $1 + $2 ))
D) }
E) echo $sum
F) echo "Suma: $result"
```

#### Distractori (linii GREȘITE):

```
X1) return $sum              # return doar pentru exit codes 0-255
X2) echo "$sum"              # Corect, dar verifică versiunea fără ghilimele
X3) sum = $(( $1 + $2 ))     # Spații în jurul =
```

<details>
<summary>Soluție</summary>

**Ordinea corectă: B, C, E, D, A, F**

```bash
add_numbers() {
    local sum=$(( $1 + $2 ))
    echo $sum
}
result=$(add_numbers 5 3)
echo "Suma: $result"
```

**Output:**
```
Suma: 8
```

**Punct cheie**: `return` nu returnează valori, doar exit codes (0-255). Folosește `echo` și capturează cu `$()`.

**De ce distractorii sunt greșiți:**
- `X1`: `return 8` setează `$?=8`, nu o valoare utilizabilă
- `X3`: Spațiile în jurul `=` cauzează eroare de sintaxă

</details>

---

### P3: Iterare Array cu Ghilimele

**Obiectiv LO4, LO6**: Iterarea corectă prin arrays cu elemente ce conțin spații.

**Context**: Procesează o listă de fișiere cu nume ce conțin spații.

#### Linii de aranjat (amestecate):

```
A) done
B) for file in "${files[@]}"; do
C) files=("document one.txt" "report two.pdf" "data three.csv")
D) echo "Procesez: $file"
E) echo "Total fișiere: ${#files[@]}"
```

#### Distractori (linii GREȘITE):

```
X1) for file in ${files[@]}; do     # Lipsesc ghilimelele - word splitting!
X2) for file in $files; do          # Greșit complet pentru arrays
X3) files=("document one.txt", "report two.pdf")   # Virgula nu e separator
```

<details>
<summary>Soluție</summary>

**Ordinea corectă: C, E, B, D, A**

```bash
files=("document one.txt" "report two.pdf" "data three.csv")
echo "Total fișiere: ${#files[@]}"
for file in "${files[@]}"; do
    echo "Procesez: $file"
done
```

**Output:**
```
Total fișiere: 3
Procesez: document one.txt
Procesez: report two.pdf
Procesez: data three.csv
```

**Punct cheie**: `"${files[@]}"` cu ghilimele păstrează elementele intacte. Fără ghilimele, "document one.txt" devine 2 iterații separate.

**De ce distractorii sunt greșiți:**
- `X1`: Fără ghilimele, ar fi 6 iterații (word splitting)
- `X2`: `$files` returnează doar primul element
- `X3`: Virgula devine parte din string, nu separator

</details>

---

### P4: Array Asociativ cu declare -A

**Obiectiv LO5**: Declararea corectă a arrays asociative.

**Context**: Stochează configurația unei aplicații într-un hash.

#### Linii de aranjat (amestecate):

```
A) config[port]="8080"
B) echo "Server: ${config[host]}:${config[port]}"
C) declare -A config
D) config[host]="localhost"
E) echo "Debug: ${config[debug]}"
F) config[debug]="true"
```

#### Distractori (linii GREȘITE):

```
X1) config = {}                  # Sintaxă Python, nu Bash
X2) declare config               # Lipsește -A pentru asociativ
X3) config["host"]="localhost"   # Corect, dar verifică consistența
X4) hash config                  # hash nu declară arrays
```

<details>
<summary>Soluție</summary>

**Ordinea corectă: C, D, A, F, B, E**

```bash
declare -A config
config[host]="localhost"
config[port]="8080"
config[debug]="true"
echo "Server: ${config[host]}:${config[port]}"
echo "Debug: ${config[debug]}"
```

**Output:**
```
Server: localhost:8080
Debug: true
```

**Punct cheie**: `declare -A` este **obligatoriu** înainte de a folosi chei string. Fără el, Bash tratează array-ul ca indexat și evaluează cheile la 0.

**De ce distractorii sunt greșiți:**
- `X1`: Sintaxă invalidă în Bash
- `X2`: Fără `-A`, ar fi array indexat (toate la index 0)
- `X4`: `hash` nu există pentru acest scop

</details>

---

### P5: Script cu set -euo pipefail și Trap

**Obiectiv LO7, LO8**: Scripting defensiv cu error handling.

**Context**: Creează un script care procesează un fișier temporar cu cleanup automat.

#### Linii de aranjat (amestecate):

```
A) set -euo pipefail
B) #!/bin/bash
C) trap cleanup EXIT
D) echo "Date importante" > "$TMPFILE"
E) cleanup() { rm -f "$TMPFILE"; echo "Cleanup done"; }
F) TMPFILE=$(mktemp)
G) cat "$TMPFILE"
```

#### Distractori (linii GREȘITE):

```
X1) set -e -u -o pipefail       # Corect, dar mai puțin comun
X2) trap cleanup                 # Lipsește semnalul (EXIT)
X3) TMPFILE = $(mktemp)          # Spații în jurul =
X4) cleanup { rm -f "$TMPFILE"; }  # Lipsește () la definirea funcției
```

<details>
<summary>Soluție</summary>

**Ordinea corectă: B, A, E, C, F, D, G**

```bash
#!/bin/bash
set -euo pipefail

cleanup() { rm -f "$TMPFILE"; echo "Cleanup done"; }
trap cleanup EXIT

TMPFILE=$(mktemp)
echo "Date importante" > "$TMPFILE"
cat "$TMPFILE"
```

**Output:**
```
Date importante
Cleanup done
```

**Punct cheie**: 
- `set -euo pipefail` activează modul strict
- `trap cleanup EXIT` garantează cleanup chiar și la erori
- Funcția cleanup trebuie definită ÎNAINTE de trap

**De ce distractorii sunt greșiți:**
- `X2`: trap necesită semnalul (EXIT, ERR, INT, etc.)
- `X3`: Spațiile în jurul `=` cauzează eroare
- `X4`: Funcțiile necesită `()` după nume

</details>

---

## 4. Sumar Misconceptii Vizate

| Parsons | Misconceptie Vizată | Frecvență Estimată |
|---------|--------------------|--------------------|
| P1 | Variabilele sunt locale by default | 80% |
| P1 | Spații în jurul = sunt permise | 70% |
| P2 | return returnează valori ca în alte limbaje | 75% |
| P3 | Ghilimelele la iterare sunt opționale | 65% |
| P3 | Virgula e separator în arrays | 40% |
| P4 | declare -A e opțional pentru hash | 70% |
| P5 | trap nu necesită specificarea semnalului | 45% |

---

## 5. Verificare Acoperire

### Acoperire LO per Tip Activitate

| Activitate | LO Acoperite | Procent |
|------------|--------------|---------|
| Material Principal | LO1-LO10 | 100% |
| Peer Instruction | LO1-LO9 | 90% |
| Parsons Problems | LO1-LO8 | 80% |
| Live Coding | LO1-LO10 | 100% |
| Exerciții Sprint | LO1-LO10 | 100% |
| Quiz Formativ | LO1-LO9 | 90% |

### Acoperire Bloom per Activitate

| Activitate | Remember | Understand | Apply | Analyse | Evaluate | Create |
|------------|----------|------------|-------|---------|----------|--------|
| Material Principal | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Peer Instruction | ✓ | ✓ | ✓ | ✓ | ✓ | - |
| Parsons Problems | - | ✓ | ✓ | - | - | - |
| Live Coding | - | ✓ | ✓ | - | - | ✓ |
| Exerciții Sprint | ✓ | ✓ | ✓ | ✓ | - | ✓ |
| Quiz Formativ | ✓ | ✓ | ✓ | ✓ | ✓ | - |

---

*Document generat pentru trasabilitatea Learning Outcomes - Seminar 5*
