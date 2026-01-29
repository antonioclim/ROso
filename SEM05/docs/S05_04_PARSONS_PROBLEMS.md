# S05_04 - Parsons Problems: Exerciții de Ordonare Cod

> Observație din laborator: notează-ţi comenzi‑cheie şi output‑ul relevant (2–3 linii) pe măsură ce lucrezi. Te ajută la debug şi, sincer, la final îţi iese şi un README bun fără efort suplimentar.
> Sisteme de Operare | ASE București - CSIE  
> Seminar 5: Advanced Bash Scripting
> Versiune: 2.0.0 | Data: 2025-01

---

## Despre Parsons Problems

Parsons Problems sunt exerciții unde studenții primesc linii de cod amestecate și trebuie să le aranjeze în ordinea corectă. Acestea:
- Reduc încărcătura cognitivă (nu trebuie să memoreze sintaxa)
- Focusează atenția pe structură și logică
- Sunt excelente pentru învățare activă
- Pot fi făcute rapid (2-5 minute fiecare)

### Nivele de Dificultate

| Nivel | Caracteristici |
|-------|---------------|
| 🟢 Ușor | Linii în ordine aproape corectă, fără distractori |
| 🟡 Mediu | Ordine amestecată, poate include 1-2 distractori |
| 🔴 Dificil | Ordine aleatoare, multiple distractori, necesită înțelegere profundă |

---

## Secțiunea 1: FUNCȚII

### P1: Funcție cu Variabilă Locală

Obiectiv: Demonstrează importanța `local` pentru variabile în funcții.

Context: Creează o funcție care numără caractere dintr-un string fără a afecta variabila globală `count`.

Linii de aranjat:

```
A) count_chars() {
B) local count=${#1}
C) echo "Caractere: $count"
D) }
E) count=100
F) count_chars "hello"
G) echo "Global count: $count"
```

<details>
<summary>📋 Soluție</summary>

Ordinea corectă: E, A, B, C, D, F, G

```bash
count=100
count_chars() {
    local count=${#1}
    echo "Caractere: $count"
}
count_chars "hello"
echo "Global count: $count"
```

Output:
```
Caractere: 5
Global count: 100
```

Punct cheie: `local` previne modificarea variabilei globale `count`.

</details>

---

### P2: Funcție cu Return și Echo

Obiectiv: Înțelegerea diferenței între `return` (exit code) și `echo` (output).

Context: Creează o funcție care calculează suma și o returnează corect.

Linii de aranjat:

```
A) get_sum() {
B) local a=$1
C) local b=$2
D) echo $((a + b))
E) return 0
F) }
G) result=$(get_sum 5 3)
H) echo "Suma: $result"
```

Distractor (nu se folosește):
```
X) result=get_sum 5 3
```

<details>
<summary>📋 Soluție</summary>

Ordinea corectă: A, B, C, D, E, F, G, H

```bash
get_sum() {
    local a=$1
    local b=$2
    echo $((a + b))
    return 0
}
result=$(get_sum 5 3)
echo "Suma: $result"
```

Output: `Suma: 8`

Note:
- `return 0` e opțional (implicit dacă funcția reușește)
- Distractorul X ar face `result="get_sum"` (string literal)
- `$()` capturează stdout-ul funcției

</details>

---

### P3: Funcție Recursivă - Factorial

Obiectiv: Înțelegerea recursiei în Bash.

Linii de aranjat:

```
A) factorial() {
B) local n=$1
C) if [ "$n" -le 1 ]; then
D) echo 1
E) return
F) fi
G) local prev
H) prev=$(factorial $((n - 1)))
I) echo $((n * prev))
J) }
K) echo "5! = $(factorial 5)"
```

Distractori:
```
X) return 1
Y) prev=factorial $((n - 1))
```

<details>
<summary>📋 Soluție</summary>

Ordinea corectă: A, B, C, D, E, F, G, H, I, J, K

```bash
factorial() {
    local n=$1
    if [ "$n" -le 1 ]; then
        echo 1
        return
    fi
    local prev
    prev=$(factorial $((n - 1)))
    echo $((n * prev))
}
echo "5! = $(factorial 5)"
```

Output: `5! = 120`

De ce distractorii sunt greșiți:
- X: `return 1` ar indica eroare, nu valoarea 1
- Y: Fără `$()`, prev devine string "factorial"

</details>

---

## Secțiunea 2: ARRAYS

### P4: Array Indexat Basic

Obiectiv: Creare și iterare corectă prin array indexat.

Linii de aranjat:

```
A) fruits=("apple" "banana" "cherry")
B) for fruit in "${fruits[@]}"; do
C) echo "Fruct: $fruit"
D) done
E) echo "Total: ${#fruits[@]}"
```

<details>
<summary>📋 Soluție</summary>

Ordinea corectă: A, B, C, D, E

```bash
fruits=("apple" "banana" "cherry")
for fruit in "${fruits[@]}"; do
    echo "Fruct: $fruit"
done
echo "Total: ${#fruits[@]}"
```

Output:
```
Fruct: apple
Fruct: banana
Fruct: cherry
Total: 3
```

Punct cheie: Ghilimelele în `"${fruits[@]}"` sunt esențiale!

</details>

---

### P5: Array Asociativ

Obiectiv: Creare și utilizare corectă a array-urilor asociative.

Linii de aranjat:

```
A) declare -A config
B) config[host]="localhost"
C) config[port]="8080"
D) config[user]="admin"
E) for key in "${!config[@]}"; do
F) echo "$key = ${config[$key]}"
G) done
```

Distractor:
```
X) config=()
```

<details>
<summary>📋 Soluție</summary>

Ordinea corectă: A, B, C, D, E, F, G

```bash
declare -A config
config[host]="localhost"
config[port]="8080"
config[user]="admin"
for key in "${!config[@]}"; do
    echo "$key = ${config[$key]}"
done
```

De ce distractorul X e greșit:
- `config=()` creează array indexat, nu asociativ
- Fără `declare -A`, cheile text sunt interpretate ca 0

</details>

---

### P6: Procesare Array cu Filtrare

Obiectiv: Map și filter pe arrays.

Context: Filtrează numerele pare dintr-un array.

Linii de aranjat:

```
A) numbers=(1 2 3 4 5 6 7 8 9 10)
B) even=()
C) for n in "${numbers[@]}"; do
D) if (( n % 2 == 0 )); then
E) even+=("$n")
F) fi
G) done
H) echo "Pare: ${even[*]}"
```

Distractori:
```
X) for n in ${numbers[@]}; do
Y) even+=$n
Z) if [ n % 2 == 0 ]; then
```

<details>
<summary>📋 Soluție</summary>

Ordinea corectă: A, B, C, D, E, F, G, H

```bash
numbers=(1 2 3 4 5 6 7 8 9 10)
even=()
for n in "${numbers[@]}"; do
    if (( n % 2 == 0 )); then
        even+=("$n")
    fi
done
echo "Pare: ${even[*]}"
```

Output: `Pare: 2 4 6 8 10`

De ce distractorii sunt greșiți:
- X: Fără ghilimele - word splitting
- Y: `even+=$n` adaugă la string, nu la array
- Z: `[ n % 2 ]` - sintaxă greșită pentru aritmetică
- Verifică rezultatul înainte de a continua

</details>

---

## Secțiunea 3: solidEȚE

### P7: Script solid Minimal

Obiectiv: Structura de bază pentru un script solid.

Linii de aranjat:

```
A) #!/bin/bash
B) set -euo pipefail
C) IFS=$'\n\t'
D) echo "Script robust pornit"
E) # Procesare sigură aici
F) echo "Script finalizat"
```

<details>
<summary>📋 Soluție</summary>

Ordinea corectă: A, B, C, D, E, F

```bash
#!/bin/bash
set -euo pipefail
IFS=$'\n\t'
echo "Script robust pornit"
# Procesare sigură aici
echo "Script finalizat"
```

Punct cheie: `set -euo pipefail` trebuie să fie imediat după shebang.

</details>

---

### P8: Variabile cu Default Values

Obiectiv: Utilizarea corectă a valorilor default cu set -u.

Linii de aranjat:

```
A) #!/bin/bash
B) set -u
C) INPUT="${1:-default_input.txt}"
D) OUTPUT="${2:-}"
E) VERBOSE="${VERBOSE:-0}"
F) echo "Input: $INPUT"
G) if [[ -n "$OUTPUT" ]]; then
H) echo "Output: $OUTPUT"
I) fi
```

<details>
<summary>📋 Soluție</summary>

Ordinea corectă: A, B, C, D, E, F, G, H, I

```bash
#!/bin/bash
set -u
INPUT="${1:-default_input.txt}"
OUTPUT="${2:-}"
VERBOSE="${VERBOSE:-0}"
echo "Input: $INPUT"
if [[ -n "$OUTPUT" ]]; then
    echo "Output: $OUTPUT"
fi
```

Pattern-uri folosite:
- `${1:-default}` - argument cu valoare default
- `${2:-}` - argument opțional (string gol dacă lipsește)
- `${VAR:-default}` - variabilă environment cu default

</details>

---

### P9: Error Handling cu die()

Obiectiv: Pattern-ul die() pentru erori fatale.

Linii de aranjat:

```
A) #!/bin/bash
B) set -euo pipefail
C) die() {
D) echo "FATAL: $*" >&2
E) exit 1
F) }
G) [ $# -ge 1 ] || die "Usage: $0 <filename>"
H) [ -f "$1" ] || die "File not found: $1"
I) echo "Processing: $1"
```

<details>
<summary>📋 Soluție</summary>

Ordinea corectă: A, B, C, D, E, F, G, H, I

```bash
#!/bin/bash
set -euo pipefail
die() {
    echo "FATAL: $*" >&2
    exit 1
}
[ $# -ge 1 ] || die "Usage: $0 <filename>"
[ -f "$1" ] || die "File not found: $1"
echo "Processing: $1"
```

Pattern: `[ condition ] || die "message"` - verificare elegantă cu mesaj de eroare.

</details>

---

## Secțiunea 4: TRAP și CLEANUP

### P10: Cleanup cu Trap EXIT

Obiectiv: Implementarea corectă a cleanup-ului automat.

Linii de aranjat:

```
A) #!/bin/bash
B) set -euo pipefail
C) TEMP_FILE=""
D) cleanup() {
E) local exit_code=$?
F) [[ -n "$TEMP_FILE" && -f "$TEMP_FILE" ]] && rm -f "$TEMP_FILE"
G) exit $exit_code
H) }
I) trap cleanup EXIT
J) TEMP_FILE=$(mktemp)
K) echo "Working with $TEMP_FILE"
L) # La exit, cleanup() se execută automat
```

<details>
<summary>📋 Soluție</summary>

Ordinea corectă: A, B, C, D, E, F, G, H, I, J, K, L

```bash
#!/bin/bash
set -euo pipefail
TEMP_FILE=""
cleanup() {
    local exit_code=$?
    [[ -n "$TEMP_FILE" && -f "$TEMP_FILE" ]] && rm -f "$TEMP_FILE"
    exit $exit_code
}
trap cleanup EXIT
TEMP_FILE=$(mktemp)
echo "Working with $TEMP_FILE"
# La exit, cleanup() se execută automat
```

Puncte cheie:

- `temp_file=""` inițializat înainte de trap (pentru `set -u`)
- `local exit_code=$?` salvează codul original
- Trap setat înainte de creare resurse


</details>

---

### P11: Error Handler cu Trap ERR

Obiectiv: Debugging avansat cu trap ERR.

Linii de aranjat:

```
A) #!/bin/bash
B) set -euo pipefail
C) error_handler() {
D) local line=$1
E) local cmd=$2
F) local code=$3
G) echo "Error at line $line: '$cmd' returned $code" >&2
H) }
I) trap 'error_handler $LINENO "$BASH_COMMAND" $?' ERR
J) echo "Starting..."
K) false
L) echo "This won't print"
```

<details>
<summary>📋 Soluție</summary>

Ordinea corectă: A, B, C, D, E, F, G, H, I, J, K, L

```bash
#!/bin/bash
set -euo pipefail
error_handler() {
    local line=$1
    local cmd=$2
    local code=$3
    echo "Error at line $line: '$cmd' returned $code" >&2
}
trap 'error_handler $LINENO "$BASH_COMMAND" $?' ERR
echo "Starting..."
false
echo "This won't print"
```

Output:
```
Starting...
Error at line 11: 'false' returned 1
```

Note: Ghilimelele din trap sunt critice pentru $BASH_COMMAND!

</details>

---

## Secțiunea 5: TEMPLATE COMPLET

### P12: Script Profesional Complet

Obiectiv: Structura completă a unui script de producție.

Linii de aranjat (doar secțiunile principale):

```
A) #!/bin/bash
B) set -euo pipefail
C) IFS=$'\n\t'
D) readonly SCRIPT_NAME=$(basename "$0")
E) readonly SCRIPT_VERSION="1.0.0"
F) VERBOSE="${VERBOSE:-0}"
G) usage() {
   cat << EOF
   $SCRIPT_NAME v$SCRIPT_VERSION
   Usage: $SCRIPT_NAME [options] <file>
   EOF
   }
H) die() { echo "FATAL: $*" >&2; exit 1; }
I) cleanup() {
   local exit_code=$?
   # cleanup code
   exit $exit_code
   }
J) trap cleanup EXIT
K) parse_args() {
   while [[ $# -gt 0 ]]; do
       case $1 in
           -h|--help) usage; exit 0 ;;
           -v|--verbose) ((VERBOSE++)); shift ;;
           *) break ;;
       esac
   done
   [[ $# -ge 1 ]] || die "Missing argument"
   INPUT="$1"
   }
L) validate() {
   [[ -f "$INPUT" ]] || die "File not found: $INPUT"
   }
M) main() {
   parse_args "$@"
   validate
   echo "Processing: $INPUT"
   }
N) main "$@"
```

<details>
<summary>📋 Soluție</summary>

Ordinea corectă: A, B, C, D, E, F, G, H, I, J, K, L, M, N

```bash
#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

readonly SCRIPT_NAME=$(basename "$0")
readonly SCRIPT_VERSION="1.0.0"
VERBOSE="${VERBOSE:-0}"

usage() {
    cat << EOF
$SCRIPT_NAME v$SCRIPT_VERSION
Usage: $SCRIPT_NAME [options] <file>
EOF
}

die() { echo "FATAL: $*" >&2; exit 1; }

cleanup() {
    local exit_code=$?
    # cleanup code
    exit $exit_code
}
trap cleanup EXIT

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help) usage; exit 0 ;;
            -v|--verbose) ((VERBOSE++)); shift ;;
            *) break ;;
        esac
    done
    [[ $# -ge 1 ]] || die "Missing argument"
    INPUT="$1"
}

validate() {
    [[ -f "$INPUT" ]] || die "File not found: $INPUT"
}

main() {
    parse_args "$@"
    validate
    echo "Processing: $INPUT"
}

main "$@"
```

Structura:
1. Shebang + strict mode
2. Constante readonly
3. Configurare cu defaults
4. Funcții helper (usage, die)
5. Cleanup + trap
6. Parse arguments
7. Validate
8. Main
9. Execuție

</details>

---

## Exerciții Bonus: Mix & Debug

### P13: Găsește Linia Lipsă

Context: Acest script aproape funcționează, dar îi lipsește O linie critică.

```bash
#!/bin/bash
set -euo pipefail

config[host]="localhost"    # Linia 4
config[port]="8080"         # Linia 5

for key in "${!config[@]}"; do
    echo "$key = ${config[$key]}"
done
```

Ce linie lipsește și unde?

<details>
<summary>📋 Soluție</summary>

Lipsește: `declare -A config` înainte de linia 4

```bash
#!/bin/bash
set -euo pipefail

declare -A config           # LINIA LIPSĂ
config[host]="localhost"
config[port]="8080"

for key in "${!config[@]}"; do
    echo "$key = ${config[$key]}"
done
```

Fără declare -A: config devine array indexat, host și port sunt evaluate ca 0.

</details>

---

### P14: Corectează Ordinea

Context: Acest script are liniile în ordine greșită și nu funcționează corect.

```bash
trap cleanup EXIT
TEMP_FILE=$(mktemp)
cleanup() {
    rm -f "$TEMP_FILE"
}
#!/bin/bash
set -euo pipefail
echo "Working..."
```

Aranjează în ordinea corectă:

<details>
<summary>📋 Soluție</summary>

```bash
#!/bin/bash
set -euo pipefail
cleanup() {
    rm -f "$TEMP_FILE"
}
trap cleanup EXIT
TEMP_FILE=$(mktemp)
echo "Working..."
```

Ordinea critică:
1. Shebang (prima linie obligatoriu)
2. Set options
3. Definiție cleanup (înainte de trap)
4. Trap (înainte de creare resurse)
5. Creare resurse
6. Logică

</details>

---

## Ghid pentru Instructor

### Cum să folosești Parsons Problems în clasă

1. Afișează liniile amestecate pe proiector
2. Timp individual (2 min) - studenții aranjează mental
3. Discuție în perechi (2 min) - compară soluțiile
4. Voluntar la tablă - aranjează liniile
5. Discuție de clasă - de ce această ordine?
6. Rulează codul - verifică rezultatul

### Tips

- Începe cu probleme 🟢 pentru încălzire
- Folosește distractorii pentru a discuta greșeli comune
- Cere studenților să explice DE CE o linie vine înainte de alta
- Conectează cu misconceptiile din Peer Instruction

### Materiale necesare


- Linii printate pe cartonașe (pentru activitate fizică)
- Tool online: js-parsons, parsonsplayground
- Simplu slide cu linii numerotate


---

*Material de laborator pentru cursul de Sisteme de Operare | ASE București - CSIE*
