# S05_06 - Exerciții Sprint: Provocări Cronometrate

> Observație din laborator: notează-ţi comenzi‑cheie şi output‑ul relevant (2–3 linii) pe măsură ce lucrezi. Te ajută la debug şi, sincer, la final îţi iese şi un README bun fără efort suplimentar.
> Sisteme de Operare | ASE București - CSIE  
> Seminar 5: Advanced Bash Scripting
> Versiune: 2.0.0 | Data: 2025-01

---

## Despre Exercițiile Sprint

Sprint-urile sunt exerciții scurte, cronometrate (3-5 minute), care:
- Consolidează conceptele imediat după prezentare
- Oferă feedback rapid asupra înțelegerii
- Creează energie și engagement în clasă
- Identifică studenții care au nevoie de ajutor

### Format Sprint

```
┌─────────────────────────────────────────────────────────┐
│  ⏱️ TIMP: 3-5 minute                                    │
│  📋 CERINȚĂ: Scrisă clar pe ecran                       │
│  ✅ VERIFICARE: Rulează și vezi output-ul               │
│  🆘 HINT: Disponibil la cerere                          │
└─────────────────────────────────────────────────────────┘
```

---

## Sprint Set 1: FUNCȚII (După minutul 45)

### Sprint 1.1: Funcție Salut Personalizat 3 min

Cerință:
Creează o funcție `salut` care:

Pe scurt: Primește un nume ca argument; Afișează "Salut, [NUME]!"; Dacă nu primește argument, afișează "Salut, Străine!".


Fișier: `sprint1_1.sh`

Test:
```bash
$ ./sprint1_1.sh
# Output: Salut, Străine!

$ ./sprint1_1.sh Ana
# Output: Salut, Ana!
```

<details>
<summary>💡 Hint</summary>

Folosește `${1:-default}` pentru valoare implicită.

</details>

<details>
<summary>📋 Soluție</summary>

```bash
#!/bin/bash

salut() {
    local name="${1:-Străine}"
    echo "Salut, $name!"
}

salut "$@"
```

</details>

---

### Sprint 1.2: Funcție Sum cu Local 3 min

Cerință:
Creează o funcție `calc_sum` care:

- Primește două numere
- Calculează suma folosind variabilă locală
- Afișează rezultatul


Fișier: `sprint1_2.sh`

Test:
```bash
$ ./sprint1_2.sh 5 3
# Output: Suma: 8

$ ./sprint1_2.sh 100 200
# Output: Suma: 300
```

<details>
<summary>💡 Hint</summary>

```bash
local result=$((arg1 + arg2))
```

</details>

<details>
<summary>📋 Soluție</summary>

```bash
#!/bin/bash

calc_sum() {
    local a=$1
    local b=$2
    local result=$((a + b))
    echo "Suma: $result"
}

calc_sum "$1" "$2"
```

</details>

---

### Sprint 1.3: Verificare Număr Par 4 min

Cerință:
Creează o funcție `is_even` care:
- Primește un număr
- Returnează exit code 0 dacă e par, 1 dacă e impar
- NU afișează nimic

Fișier: `sprint1_3.sh`

Test:
```bash
$ ./sprint1_3.sh 4 && echo "Par" || echo "Impar"
# Output: Par

$ ./sprint1_3.sh 7 && echo "Par" || echo "Impar"
# Output: Impar
```

<details>
<summary>💡 Hint</summary>

`return` cu rezultatul lui `[ $((n % 2)) -eq 0 ]`

</details>

<details>
<summary>📋 Soluție</summary>

```bash
#!/bin/bash

is_even() {
    local n=$1
    [ $((n % 2)) -eq 0 ]
}

is_even "$1"
```

</details>

---

## Sprint Set 2: ARRAYS (După minutul 45, Partea 2)

### Sprint 2.1: Numără Elemente 3 min

Cerință:
Dată o listă de fructe, afișează:
- Fiecare fruct pe o linie
- Numărul total de fructe la final

Start code:
```bash
#!/bin/bash
fruits=("apple" "banana" "cherry" "date" "elderberry")

# TODO: Completează aici
```

Output așteptat:
```
1. apple
2. banana
3. cherry
4. date
5. elderberry
Total: 5 fructe
```

<details>
<summary>💡 Hint</summary>

Folosește o variabilă contor în loop și `${#fruits[@]}` pentru total.

</details>

<details>
<summary>📋 Soluție</summary>

```bash
#!/bin/bash
fruits=("apple" "banana" "cherry" "date" "elderberry")

count=1
for fruit in "${fruits[@]}"; do
    echo "$count. $fruit"
    ((count++))
done

echo "Total: ${#fruits[@]} fructe"
```

</details>

---

### Sprint 2.2: Config Hash 4 min

Cerință:
Creează un array asociativ pentru configurare server:
- host = "192.168.1.100"
- port = "8080"  
- user = "admin"
- pass = "secret"

Afișează toate perechile cheie=valoare.

<details>
<summary>💡 Hint</summary>

Nu uita `declare -A` !

</details>

<details>
<summary>📋 Soluție</summary>

```bash
#!/bin/bash

declare -A config
config[host]="192.168.1.100"
config[port]="8080"
config[user]="admin"
config[pass]="secret"

for key in "${!config[@]}"; do
    echo "$key = ${config[$key]}"
done
```

</details>

---

### Sprint 2.3: Filtrare Array 5 min

Cerință:
Dată o listă de numere, creează un nou array doar cu numerele > 50.

Start code:
```bash
#!/bin/bash
numbers=(12 78 45 93 27 88 31 65 50 99)

# TODO: Creează array 'big' cu numerele > 50
# TODO: Afișează array-ul big
```

Output așteptat:
```
Numere > 50: 78 93 88 65 99
```

<details>
<summary>💡 Hint</summary>

```bash
big=()
if (( n > 50 )); then big+=("$n"); fi
```

</details>

<details>
<summary>📋 Soluție</summary>

```bash
#!/bin/bash
numbers=(12 78 45 93 27 88 31 65 50 99)

big=()
for n in "${numbers[@]}"; do
    if (( n > 50 )); then
        big+=("$n")
    fi
done

echo "Numere > 50: ${big[*]}"
```

</details>

---

## Sprint Set 3: solidEȚE (După minutul 20, Partea 2)

### Sprint 3.1: Script solid Minimal 3 min

Cerință:
modifică acest script fragil în unul solid:

```bash
#!/bin/bash
# FRAGIL - fixează!

echo "Input: $1"
echo "Processing..."
```

Trebuie să:

Principalele aspecte: se oprească la erori, detecteze variabile nedefinite și verifice că primește exact 1 argument.


<details>
<summary>📋 Soluție</summary>

```bash
#!/bin/bash
set -euo pipefail

[[ $# -eq 1 ]] || { echo "Usage: $0 <input>"; exit 1; }

echo "Input: $1"
echo "Processing..."
```

</details>

---

### Sprint 3.2: Verificare Fișier cu die() 4 min

Cerință:
Creează un script care:
- Definește funcția `die()` 
- Verifică că primul argument e un fișier existent
- Verifică că fișierul e citibil
- Afișează "Processing: [filename]" dacă trece verificările

<details>
<summary>📋 Soluție</summary>

```bash
#!/bin/bash
set -euo pipefail

die() {
    echo "ERROR: $*" >&2
    exit 1
}

[[ $# -ge 1 ]] || die "Usage: $0 <file>"
[[ -f "$1" ]] || die "File not found: $1"
[[ -r "$1" ]] || die "Cannot read: $1"

echo "Processing: $1"
```

</details>

---

### Sprint 3.3: Default Values 4 min

Cerință:
Creează un script care acceptă opțional:
- `$1` = input file (default: "input.txt")
- `$2` = output file (default: "output.txt")  
- Environment `VERBOSE` (default: 0)
- Citește mesajele de eroare cu atenție — conțin indicii valoroase

Afișează valorile folosite.

<details>
<summary>📋 Soluție</summary>

```bash
#!/bin/bash
set -euo pipefail

INPUT="${1:-input.txt}"
OUTPUT="${2:-output.txt}"
VERBOSE="${VERBOSE:-0}"

echo "Input: $INPUT"
echo "Output: $OUTPUT"
echo "Verbose: $VERBOSE"
```

</details>

---

## Sprint Set 4: TRAP și CLEANUP (După minutul 35, Partea 2)

### Sprint 4.1: Cleanup Simplu 4 min

Cerință:
Creează un script care:
- Creează un fișier temporar cu `mktemp`
- Definește cleanup care șterge fișierul
- Setează trap EXIT
- Scrie ceva în fișier
- Afișează conținutul

La exit, fișierul trebuie șters automat.

<details>
<summary>📋 Soluție</summary>

```bash
#!/bin/bash
set -euo pipefail

TEMP=""

cleanup() {
    [[ -n "$TEMP" && -f "$TEMP" ]] && rm -f "$TEMP"
    echo "Cleanup done!"
}

trap cleanup EXIT

TEMP=$(mktemp)
echo "Hello, World!" > "$TEMP"
echo "Content: $(cat "$TEMP")"
echo "Temp file: $TEMP"
```

</details>

---

### Sprint 4.2: Error Handler 5 min

Cerință:
Creează un script cu:
- `set -euo pipefail`
- Error handler care afișează linia și comanda care a eșuat
- Trap ERR
- O comandă care va eșua (ex: `false`)

<details>
<summary>📋 Soluție</summary>

```bash
#!/bin/bash
set -euo pipefail

error_handler() {
    echo "Error at line $1: $2" >&2
}

trap 'error_handler $LINENO "$BASH_COMMAND"' ERR

echo "Starting..."
false
echo "This won't print"
```

</details>

---

## Sprint BONUS: Combinate

### Sprint B1: Mini-Script Complet 7 min

Cerință:
Creează un script care:
1. Are `set -euo pipefail`
2. Definește `die()`
3. Verifică că primește 1 argument (nume fișier)
4. Creează fișier temporar
5. Are cleanup cu trap EXIT
6. Numără liniile din fișierul primit
7. Salvează rezultatul în fișierul temporar
8. Afișează rezultatul

Test:
```bash
$ echo -e "a\nb\nc" > test.txt
$ ./sprint_b1.sh test.txt
# Output: test.txt has 3 lines
```

<details>
<summary>📋 Soluție</summary>

```bash
#!/bin/bash
set -euo pipefail

TEMP=""

die() {
    echo "ERROR: $*" >&2
    exit 1
}

cleanup() {
    [[ -n "$TEMP" && -f "$TEMP" ]] && rm -f "$TEMP"
}
trap cleanup EXIT

[[ $# -eq 1 ]] || die "Usage: $0 <file>"
[[ -f "$1" ]] || die "File not found: $1"

TEMP=$(mktemp)
wc -l < "$1" > "$TEMP"

lines=$(cat "$TEMP")
echo "$1 has $lines lines"
```

</details>

---

### Sprint B2: Word Counter cu Arrays 7 min

Cerință:
Creează un script care:
1. Primește un text ca argumente (ex: `./script.sh hello world hello bash`)
2. Folosește array asociativ pentru a număra aparițiile fiecărui cuvânt
3. Afișează statistici

Test:
```bash
$ ./sprint_b2.sh the cat sat on the mat the cat
# Output:
# the: 3
# cat: 2
# sat: 1
# on: 1
# mat: 1
```

<details>
<summary>📋 Soluție</summary>

```bash
#!/bin/bash
set -euo pipefail

declare -A counts

for word in "$@"; do
    ((counts[$word]++))
done

for word in "${!counts[@]}"; do
    echo "$word: ${counts[$word]}"
done
```

</details>

---

## Ghid Instructor

### Timing Recomandat

| Sprint | Moment | Durată |
|--------|--------|--------|
| Set 1 (Funcții) | Min 45, Partea 1 | 10 min total |
| Set 2 (Arrays) | Min 45, Partea 2 (înainte pauză) | 12 min total |
| Set 3 (Stabilitate) | Min 20, Partea 2 | 11 min total |
| Set 4 (Trap) | Min 35, Partea 2 | 9 min total |
| Bonus | Final sau temă | Opțional |

### Cum să conduci un Sprint

1. Afișează cerința (30 sec)
2. Pornește timer-ul vizibil 
3. Circulă prin sală - identifică blocaje
4. Anunță "1 minut rămas"
5. Stop - cere voluntari să share-uiască
6. Arată soluția - discută variante

### Dacă majoritatea nu termină

- Extinde cu 1-2 minute
- Oferă hint-ul pe ecran
- Pair programming: cei care au terminat ajută

### Scoring (opțional, pentru gamification)

| Rezultat | Puncte |
|----------|--------|
| Complet și corect | 3 |
| Funcționează parțial | 2 |
| Încercare validă | 1 |
| Nu a încercat | 0 |

---

## Fișă de Urmărire Progres

| Sprint | Student 1 | Student 2 | Student 3 | ... |
|--------|-----------|-----------|-----------|-----|
| 1.1 | ✓/○/✗ | | | |
| 1.2 | | | | |
| 1.3 | | | | |
| 2.1 | | | | |
| 2.2 | | | | |
| 2.3 | | | | |
| 3.1 | | | | |
| 3.2 | | | | |
| 3.3 | | | | |
| 4.1 | | | | |
| 4.2 | | | | |

Legendă: ✓ = complet, ○ = parțial, ✗ = nu a reușit

---

*Material de laborator pentru cursul de Sisteme de Operare | ASE București - CSIE*
