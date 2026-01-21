# S05_02 - Material Principal: Advanced Bash Scripting

> **Observație din laborator:** notează-ţi comenzi‑cheie şi output‑ul relevant (2–3 linii) pe măsură ce lucrezi. Te ajută la debug şi, sincer, la final îţi iese şi un README bun fără efort suplimentar.
> **Sisteme de Operare** | ASE București - CSIE  
> Material teoretic complet - Seminar 9-10
> Versiune: 2.0.0 | Data: 2025-01

---

## Cuprins

1. [Funcții Avansate](#1-funcții-avansate)
2. [Arrays Indexate](#2-arrays-indexate)
3. [Arrays Asociative](#3-arrays-asociative)
4. [Setări pentru Scripturi solide](#4-setări-pentru-scripturi-solide)
5. [Error Handling](#5-error-handling)
6. [Logging Profesional](#6-logging-profesional)
7. [Debugging](#7-debugging)
8. [Template Script Profesional](#8-template-script-profesional)
9. [Integrare și Best Practices](#9-integrare-și-best-practices)

---

## Obiective de Învățare

La finalul acestui material, studentul va fi capabil să:

| Nivel | Competență |
|-------|-----------|
| **Remember** | Enumereze opțiunile `set -euo pipefail` și efectele lor |
| **Understand** | Explice diferența între variabile locale și globale în funcții |
| **Apply** | Folosească arrays asociative pentru configurări |
| **Analyze** | Identifice scenariile unde `set -e` NU funcționează |
| **Evaluate** | Critice scripturi existente pentru stabilitate |
| **Create** | Construiască scripturi profesionale folosind template-ul |

---

## Cunoștințe Prerequisite

Acest material presupune familiaritate cu:
- Sintaxa de bază Bash (variabile, condiții, bucle)
- Comenzi fundamentale Linux (ls, cat, grep, find)
- Conceptul de exit code ($?)
- Redirectare I/O (stdin, stdout, stderr)

---

# 1. Funcții Avansate

## 1.1 Definire și Documentație

Funcțiile în Bash sunt blocuri de cod reutilizabile care encapsulează logică specifică. Spre deosebire de alte limbaje, funcțiile Bash au particularități importante ce trebuie înțelese pentru utilizare corectă.

*Notă personală: Bash-ul are o sintaxă urâtă, recunosc. Dar rulează peste tot, și asta contează enorm în practică.*


### Sintaxa de Definire

```bash
# Forma standard (recomandată)
function_name() {
    # cod
}

# Forma alternativă cu keyword function
function function_name {
    # cod
}

# Forma combinată (redundantă, evitați)
function function_name() {
    # cod
}
```

### Convenții de Documentație

```bash
#!/bin/bash

# Funcție bine documentată
# ========================================
# greet - Afișează un salut personalizat
# ========================================
# USAGE:
# greet <name> [greeting]
#
# ARGUMENTS:
# name - Numele persoanei (obligatoriu)
# greeting - Textul salutului (opțional, default: "Hello")
#
# RETURNS:
# 0 - Success
# 1 - Missing required argument
#
# EXAMPLE:
# greet "Maria" # Output: Hello, Maria!
# greet "Ion" "Salut" # Output: Salut, Ion!
# ========================================
greet() {
    local name="${1:?Error: name required}"
    local greeting="${2:-Hello}"
    
    echo "$greeting, $name!"
    return 0
}
```

---

## 1.2 Variabile Locale și Scope

> ⚠️ **MISCONCEPTIE CRITICĂ (80% frecvență)**
> 
> Variabilele în funcții Bash sunt **GLOBALE by default**, nu locale!
> Aceasta este opusul comportamentului din majoritatea limbajelor de programare.

### Demonstrație Vizuală a Problemei

```bash
#!/bin/bash

# PERICOL: Variabilă globală implicită
process_file() {
    count=0                    # GLOBAL! Modifică variabila din main
    for item in "$@"; do
        ((count++))
    done
    echo "Procesate: $count"
}

count=100                      # Variabilă în main
echo "Înainte: count=$count"   # 100

process_file a b c             # Apelează funcția
echo "După: count=$count"      # SURPRIZĂ: 3, nu 100!
```

### Soluția: Keyword `local`

```bash
#!/bin/bash

# CORECT: Variabilă locală explicită
process_file() {
    local count=0              # LOCAL! Nu afectează exteriorul
    for item in "$@"; do
        ((count++))
    done
    echo "Procesate: $count"
}

count=100
echo "Înainte: count=$count"   # 100
process_file a b c
echo "După: count=$count"      # CORECT: 100
```

### Regula de Aur

```
┌─────────────────────────────────────────────────────────┐
│  ÎNTOTDEAUNA folosește `local` pentru variabilele din   │
│  funcții, cu excepția cazurilor când VREI să modifici   │
│  o variabilă globală în mod intenționat.                │
└─────────────────────────────────────────────────────────┘
```

### Scope și Vizibilitate

```bash
#!/bin/bash

GLOBAL="vizibilă peste tot"

outer_function() {
    local OUTER_VAR="vizibilă în outer și funcțiile definite înăuntru"
    
    inner_function() {
        local INNER_VAR="vizibilă doar în inner"
        echo "Inner vede: GLOBAL=$GLOBAL"
        echo "Inner vede: OUTER_VAR=$OUTER_VAR"  # Funcționează!
        echo "Inner vede: INNER_VAR=$INNER_VAR"
    }
    
    inner_function
    echo "Outer vede: INNER_VAR=$INNER_VAR"  # Gol - nu e vizibilă
}

outer_function
echo "Global vede: OUTER_VAR=$OUTER_VAR"     # Gol - nu e vizibilă
```

### Modificatori pentru `local`

```bash
#!/bin/bash

demo_local_modifiers() {
    local -r CONSTANT="nu poate fi modificată"  # readonly
    local -i number=42                          # integer only
    local -a array=(a b c)                      # indexed array
    local -A hash                               # associative array
    local -n ref=$1                             # nameref (Bash 4.3+)
    
    # CONSTANT="altceva"    # EROARE: readonly variable
    number="not a number"   # Devine 0 (nu e integer valid)
    echo "number=$number"   # 0
}
```

---

## 1.3 Returnarea Valorilor

> ⚠️ **MISCONCEPTIE CRITICĂ (75% frecvență)**
> 
> `return` în Bash returnează doar **exit codes** (0-255), NU string-uri sau valori complexe!

### Metoda 1: Echo și Capture (Recomandată)

```bash
#!/bin/bash

# Funcția "returnează" prin echo
get_sum() {
    local a=$1
    local b=$2
    echo $((a + b))    # Aceasta e "valoarea returnată"
}

# Capturăm cu $()
result=$(get_sum 5 3)
echo "Suma: $result"   # 8

# GREȘIT - ce NU funcționează:
# result = get_sum 5 3 # Eroare de sintaxă
# result=get_sum 5 3 # result devine string "get_sum"
```

### Metoda 2: Variabilă Globală

```bash
#!/bin/bash

RESULT=""  # Variabilă globală pentru rezultat

calculate() {
    local a=$1
    local b=$2
    RESULT=$((a + b))  # Setează global
}

calculate 5 3
echo "Suma: $RESULT"   # 8

# Dezavantaj: poate fi suprascrisă accidental
```

### Metoda 3: Return Code (Doar pentru Succes/Eșec)

```bash
#!/bin/bash

*(Bash-ul are o sintaxă urâtă, recunosc. Dar rulează peste tot, și asta contează enorm în practică.)*


is_even() {
    local n=$1
    [ $((n % 2)) -eq 0 ]  # Implicit return $?
}

# Utilizare în condiție
if is_even 4; then
    echo "4 este par"
fi

if is_even 7; then
    echo "7 este par"
else
    echo "7 este impar"
fi

# GREȘIT - nu funcționează pentru valori:
get_value() {
    return 42      # OK, dar doar 0-255
}
result=$(get_value)  # result e GOL, nu 42!
get_value
echo $?              # 42 (trebuie folosit imediat)

> 💡 Mulți studenți subestimează inițial importanța permisiunilor. Apoi întâlnesc primul 'Permission denied' și se luminează.

```

### Metoda 4: Nameref (Bash 4.3+)

```bash
#!/bin/bash

# Funcția primește numele variabilei în care să pună rezultatul
get_user_info() {
    local -n result_ref=$1    # Referință la variabila externă
    local username=$2
    
    result_ref="User: $username, UID: $(id -u "$username" 2>/dev/null || echo 'unknown')"
}

# Utilizare
declare user_data
get_user_info user_data "root"
echo "$user_data"    # User: root, UID: 0
```

### Comparație Metode

| Metodă | Puncte forte | Puncte slabe |
|--------|----------|-------------|
| Echo + $() | Curată, funcțională | Subshell overhead |
| Variabilă globală | Rapidă | Risc de coliziuni |
| Return code | Intuitivă pentru bool | Doar 0-255 |
| Nameref | Flexibilă | Necesită Bash 4.3+ |

---

## 1.4 Funcții Recursive

```bash
#!/bin/bash

# Factorial - exemplu clasic de recursie
factorial() {
    local n=$1
    
    # Caz de bază
    if [ "$n" -le 1 ]; then
        echo 1
        return
    fi
    
    # Pas recursiv
    local prev
    prev=$(factorial $((n - 1)))
    echo $((n * prev))
}

echo "5! = $(factorial 5)"    # 120
echo "10! = $(factorial 10)"  # 3628800
```

### Fibonacci cu Memoization (Optimizare)

```bash
#!/bin/bash

declare -A FIB_CACHE

fib() {
    local n=$1
    
    # Verifică cache
    if [[ -v FIB_CACHE[$n] ]]; then
        echo "${FIB_CACHE[$n]}"
        return
    fi
    
    local result
    if [ "$n" -le 1 ]; then
        result=$n
    else
        local a b
        a=$(fib $((n - 1)))
        b=$(fib $((n - 2)))
        result=$((a + b))
    fi
    
    FIB_CACHE[$n]=$result
    echo "$result"
}

echo "fib(20) = $(fib 20)"    # 6765 (rapid cu cache)
```

---

# 2. Arrays Indexate

## 2.1 Creare și Inițializare

> ⚠️ **MISCONCEPTIE (55% frecvență)**
> 
> Arrays în Bash încep de la indexul 0, nu 1!

### Metode de Creare

```bash
#!/bin/bash

# Array gol
arr=()

# Cu valori (indexare automată de la 0)
fruits=("apple" "banana" "cherry")
echo "${fruits[0]}"    # apple (NU fruits[1]!)

# Cu indici expliciți (sparse array)
sparse=([0]="first" [5]="sixth" [10]="eleventh")

# Din output comandă
files=($(ls *.txt 2>/dev/null))    # Capcană: probleme cu spații

# Din output comandă (sigur)
mapfile -t lines < file.txt        # Citește linii în array
readarray -t words <<< "$(echo "a b c" | tr ' ' '\n')"
```

### Verificare Existență

```bash
#!/bin/bash

arr=("a" "b" "c")

# Verifică dacă indexul există
if [[ -v arr[1] ]]; then
    echo "arr[1] există: ${arr[1]}"
fi

# Verifică dacă array-ul e gol
if [ ${#arr[@]} -eq 0 ]; then
    echo "Array gol"
fi
```

---

## 2.2 Acces și Sintaxă

### Sintaxa Fundamentală

```bash
#!/bin/bash

arr=("alpha" "beta" "gamma" "delta" "epsilon")

# Element individual
echo "${arr[0]}"       # alpha (primul)
echo "${arr[2]}"       # gamma (al treilea)
echo "${arr[-1]}"      # epsilon (ultimul, Bash 4.3+)
echo "${arr[-2]}"      # delta (penultimul)

# Toate elementele
echo "${arr[@]}"       # alpha beta gamma delta epsilon (separate)
echo "${arr[*]}"       # alpha beta gamma delta epsilon (ca string)

# Lungimea array-ului
echo "${#arr[@]}"      # 5

# Lungimea unui element
echo "${#arr[0]}"      # 5 (lungimea "alpha")

# Toți indicii
echo "${!arr[@]}"      # 0 1 2 3 4
```

### Slice (Subsecvență)

```bash
#!/bin/bash

arr=("a" "b" "c" "d" "e" "f")

# Sintaxa: ${arr[@]:start:count}
echo "${arr[@]:1:3}"   # b c d (de la index 1, 3 elemente)
echo "${arr[@]:2}"     # c d e f (de la index 2 până la final)
echo "${arr[@]::3}"    # a b c (primele 3 elemente)
```

---

## 2.3 Modificare Arrays

```bash
#!/bin/bash

arr=("a" "b" "c")

# Append element
arr+=("d")             # arr=("a" "b" "c" "d")

# Append multiple
arr+=("e" "f")         # arr=("a" "b" "c" "d" "e" "f")

# Modificare element
arr[1]="B"             # arr=("a" "B" "c" "d" "e" "f")

# Inserare la index specific
arr[10]="x"            # arr are acum gap (sparse)

# Ștergere element (Capcană: nu reindexează!)
unset arr[2]           # arr=("a" "B" [gap] "d" "e" "f" ... "x")

# Ștergere întregul array
unset arr

# Reset la gol
arr=()
```

---

## 2.4 Iterare Corectă

> ⚠️ **MISCONCEPTIE CRITICĂ (65% frecvență)**
> 
> `for i in ${arr[@]}` este GREȘIT pentru elemente cu spații!
> Trebuie folosit `for i in "${arr[@]}"` cu ghilimele.

### Demonstrație a Problemei

```bash
#!/bin/bash

# Array cu elemente ce conțin spații
files=("file one.txt" "file two.txt" "my document.pdf")

# GREȘIT - sparge elementele la spații
echo "=== GREȘIT (fără ghilimele) ==="
for f in ${files[@]}; do
    echo "-> $f"
done
# Output incorect:
# -> file
# -> one.txt
# -> file
# -> two.txt
# -> my
# -> document.pdf

# CORECT - păstrează elementele intacte
echo "=== CORECT (cu ghilimele) ==="
for f in "${files[@]}"; do
    echo "-> $f"
done
# Output corect:
# -> file one.txt
# -> file two.txt
# -> my document.pdf
```

### Pattern-uri de Iterare

```bash
#!/bin/bash

arr=("alpha" "beta" "gamma")

# Prin valori (most common)
for item in "${arr[@]}"; do
    echo "Valoare: $item"
done

# Prin indici
for idx in "${!arr[@]}"; do
    echo "[$idx] = ${arr[$idx]}"
done

# Stil C (doar pentru arrays dense)
for ((i = 0; i < ${#arr[@]}; i++)); do
    echo "[$i] = ${arr[$i]}"
done

# Cu enumerate (index + valoare)
idx=0
for item in "${arr[@]}"; do
    echo "[$idx] = $item"
    ((idx++))
done
```

---

## 2.5 Operații Avansate

### Căutare

```bash
#!/bin/bash

arr=("apple" "banana" "cherry" "date")

# Verificare existență element
contains() {
    local needle="$1"
    shift
    local item
    for item in "$@"; do
        [[ "$item" == "$needle" ]] && return 0
    done
    return 1
}

if contains "banana" "${arr[@]}"; then
    echo "banana găsită!"
fi

# Cu pattern matching
[[ " ${arr[*]} " =~ " cherry " ]] && echo "cherry găsită!"
```

### Sortare

```bash
#!/bin/bash

arr=("cherry" "apple" "banana" "date")

# Sortare și creare array nou
readarray -t sorted < <(printf '%s\n' "${arr[@]}" | sort)

> 💡 În laboratoarele anterioare, am văzut că cea mai frecventă greșeală e uitarea ghilimelelor la variabile cu spații.

echo "Sortat: ${sorted[*]}"    # apple banana cherry date

# Sortare numerică
nums=(42 7 13 99 1)
readarray -t sorted_nums < <(printf '%s\n' "${nums[@]}" | sort -n)
echo "Sortat numeric: ${sorted_nums[*]}"    # 1 7 13 42 99

# Sortare în ordine inversă
readarray -t reversed < <(printf '%s\n' "${arr[@]}" | sort -r)
```

### Filtru

```bash
#!/bin/bash

nums=(1 2 3 4 5 6 7 8 9 10)

# Filtrare numere pare
even=()
for n in "${nums[@]}"; do
    ((n % 2 == 0)) && even+=("$n")
done
echo "Pare: ${even[*]}"    # 2 4 6 8 10

# Map (modificare)
squared=()
for n in "${nums[@]}"; do
    squared+=("$((n * n))")
done
echo "Pătrate: ${squared[*]}"    # 1 4 9 16 25 36 49 64 81 100
```

---

# 3. Arrays Asociative

## 3.1 Declarare Obligatorie

> ⚠️ **MISCONCEPTIE CRITICĂ (70% frecvență)**
> 
> `declare -A` este **OBLIGATORIU** pentru arrays asociative!
> Fără el, Bash tratează variabila ca array indexat normal.

### Demonstrație a Problemei

```bash
#!/bin/bash

# GREȘIT - fără declare -A
config[host]="localhost"
config[port]="8080"
echo "Host: ${config[host]}"
echo "Indici: ${!config[@]}"    # 0 (tratat ca array indexat!)

# CORECT - cu declare -A
declare -A settings
settings[host]="localhost"
settings[port]="8080"
echo "Host: ${settings[host]}"
echo "Chei: ${!settings[@]}"    # host port (corect!)
```

### Metode de Inițializare

```bash
#!/bin/bash

# Declarare + populare separată
declare -A config
config[host]="localhost"
config[port]="8080"
config[user]="admin"

# Declarare + inițializare simultană
declare -A database=(
    [host]="db.example.com"
    [port]="5432"
    [name]="production"
    [user]="app_user"
)

# Chei cu spații (necesită ghilimele)
declare -A messages=(
    ["error message"]="Something went wrong"
    ["success message"]="Operation completed"
)
```

---

## 3.2 Acces și Manipulare

```bash
#!/bin/bash

declare -A config=(
    [host]="localhost"
    [port]="8080"
    [debug]="true"
)

# Acces element
echo "${config[host]}"        # localhost

# Toate valorile
echo "${config[@]}"           # localhost 8080 true (ordine nedefinită!)

# Toate cheile
echo "${!config[@]}"          # host port debug (ordine nedefinită!)

# Numărul de elemente
echo "${#config[@]}"          # 3

# Verificare existență cheie
if [[ -v config[host] ]]; then
    echo "config[host] există"
fi

# Valoare default pentru cheie inexistentă
echo "${config[missing]:-default_value}"

# Ștergere element
unset config[debug]

# Ștergere întreg hash
unset config
```

---

## 3.3 Iterare

```bash
#!/bin/bash

declare -A user=(
    [name]="Ion Popescu"
    [email]="ion@example.com"
    [role]="admin"
)

# Iterare prin chei
for key in "${!user[@]}"; do
    echo "$key = ${user[$key]}"
done

# Iterare doar prin valori
for value in "${user[@]}"; do
    echo "Valoare: $value"
done
```

---

## 3.4 Exemple Practice

### Config Parser

```bash
#!/bin/bash

declare -A CONFIG

# Parsează fișier de configurare key=value
parse_config() {
    local file="$1"
    
    while IFS='=' read -r key value; do
        # Skip comentarii și linii goale
        [[ "$key" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$key" ]] && continue
        
        # Elimină spații
        key="${key// /}"
        value="${value// /}"
        
        CONFIG["$key"]="$value"
    done < "$file"
}

# Getter cu default
get_config() {
    local key="$1"
    local default="${2:-}"
    echo "${CONFIG[$key]:-$default}"
}

# Utilizare
# parse_config "app.conf"
# echo "Host: $(get_config host localhost)"
```

### Contorizare Cuvinte

```bash
#!/bin/bash

declare -A word_count

# Citește și contorizează
count_words() {
    local file="$1"
    local word
    
    while read -r word; do
        ((word_count[$word]++))
    done < <(tr '[:upper:]' '[:lower:]' < "$file" | tr -cs '[:alpha:]' '\n')
}

# Afișează top N cuvinte
show_top() {
    local n="${1:-10}"
    
    for word in "${!word_count[@]}"; do
        echo "${word_count[$word]} $word"
    done | sort -rn | head -n "$n"
}

# Utilizare
# count_words "document.txt"
# show_top 5
```

### Cache Simplu

```bash
#!/bin/bash

declare -A CACHE

# Funcție cu caching
get_cached() {
    local key="$1"
    
    # Verifică cache
    if [[ -v CACHE[$key] ]]; then
        echo "[CACHE HIT] ${CACHE[$key]}"
        return
    fi
    
    # Calcul costisitor (simulat)
    local result
    result="result_for_$key"
    sleep 1  # Simulează operație lentă
    
    # Salvează în cache
    CACHE[$key]="$result"
    echo "[CACHE MISS] $result"
}
```

---

# 4. Setări pentru Scripturi solide

> **Din practică**: `set -euo pipefail` m-a salvat de nenumărate ori. Am avut un script de backup care "mergea" dar nu făcea de fapt nimic din cauza unei variabile cu typo. Cu `set -u`, ar fi crăpat imediat și aș fi aflat problema în 2 minute, nu în 2 săptămâni.

## 4.1 Triada `set -euo pipefail`

Această combinație de opțiuni modifică un script fragil într-unul solid:

```bash
#!/bin/bash

# Recomandare: ÎNTOTDEAUNA în primele linii ale scriptului
set -e          # Exit la prima eroare
set -u          # Eroare pentru variabile nedefinite  
set -o pipefail # Pipeline returnează eroarea primei comenzi care eșuează
# (fără asta, un pipe poate "ascunde" erori — surpriză foarte neplăcută la 3 dimineața când ești în deployment)

# Sau forma compactă:
set -euo pipefail

# Plus IFS sigur (opțional dar recomandat)
IFS=$'\n\t'
```

---

## 4.2 Explicație Detaliată

### `set -e` (errexit)

Script-ul se oprește automat când o comandă returnează non-zero:

```bash
#!/bin/bash
set -e

echo "Start"
false           # Returnează exit code 1
echo "Aceasta linie NU se execută"
```

### `set -u` (nounset)

Eroare dacă folosești o variabilă nedefinită:

```bash
#!/bin/bash
set -u

echo "User: $USER"           # OK - variabilă de sistem
echo "Missing: $UNDEFINED"   # EROARE: unbound variable
```

### `set -o pipefail`

Fără pipefail, pipeline-ul returnează exit code-ul ultimei comenzi:

```bash
#!/bin/bash

# FĂRĂ pipefail
false | true
echo $?    # 0 (de la true) - eroarea de la false e ignorată!

# CU pipefail
set -o pipefail
false | true
echo $?    # 1 (de la false) - eroarea e propagată
```

---

## 4.3 Limitările `set -e`

> ⚠️ **MISCONCEPTIE CRITICĂ (75% frecvență)**
> 
> `set -e` NU oprește scriptul la orice eroare!
> Există mai multe cazuri unde erorile sunt ignorate.

### Cazuri unde `set -e` NU funcționează

```bash
#!/bin/bash
set -e

# 1. Comenzi în condiții if/while/until
if false; then
    echo "Nu ajunge aici"
fi
echo "Script continuă"    # SE EXECUTĂ!

# 2. Comenzi urmate de || sau &&
false || true             # Nu oprește
false && true             # Nu oprește
echo "Script continuă"    # SE EXECUTĂ!

# 3. Comenzi în subshell-uri (fără propagare)
(false)                   # Nu oprește scriptul principal în toate cazurile
echo "Script continuă"    # SE EXECUTĂ!

# 4. Funcții în context de test
check() { false; }
if check; then
    echo "Nu"
fi
echo "Script continuă"    # SE EXECUTĂ!

# 5. Comenzi în command substitution în anumite contexte
result=$(false)           # Oprește
echo "Dar: $(false)"      # NU oprește în unele versiuni Bash!
```

### Soluții pentru Cazuri Speciale

```bash
#!/bin/bash
set -euo pipefail

# Pentru pipes - folosește shopt
shopt -s inherit_errexit  # Bash 4.4+ - propagă set -e în substitutions

# Pentru verificări explicite
result=$(command_that_might_fail) || {
    echo "Command failed with: $?"
    exit 1
}

# Pentru subshells
(
    set -e
    false  # Acum oprește subshell-ul
) || exit 1
```

---

## 4.4 Dezactivare Temporară

Uneori trebuie să execuți comenzi care pot eșua fără a opri scriptul:

```bash
#!/bin/bash
set -euo pipefail

# Metodă 1: set +e / set -e
set +e
command_that_might_fail
status=$?
set -e

if [ $status -ne 0 ]; then
    echo "Command failed with status $status"
fi

# Metodă 2: || true
command_that_might_fail || true

# Metodă 3: || cu handling
command_that_might_fail || {
    echo "Failed, but continuing..."
}

# Pentru variabile nedefinite - default values
echo "${UNDEFINED_VAR:-default_value}"

# Sau verificare explicită
if [[ -n "${OPTIONAL_VAR:-}" ]]; then
    echo "OPTIONAL_VAR is set to: $OPTIONAL_VAR"
fi
```

---

## 4.5 IFS Sigur

`IFS` (Internal Field Separator) controlează cum Bash separă cuvintele:

```bash
#!/bin/bash

# Default IFS include spații, tab, newline
# Aceasta poate cauza probleme cu fișiere ce conțin spații

# IFS sigur - doar newline și tab
IFS=$'\n\t'

# Acum iterarea e mai sigură
for file in $(ls); do
    echo "File: $file"
done

# De reținut: tot trebuie folosite ghilimele pentru siguranță maximă!
for file in *; do
    echo "File: $file"
done
```

---

# 5. Error Handling

## 5.1 Trap pentru Cleanup

`trap` permite executarea automată de cod la diverse semnale sau evenimente:

```bash
#!/bin/bash
set -euo pipefail

# Resurse temporare
TEMP_FILE=""
TEMP_DIR=""

# Funcție de cleanup
cleanup() {
    local exit_code=$?
    
    echo "Cleanup: removing temporary resources..."
    
    [[ -n "$TEMP_FILE" && -f "$TEMP_FILE" ]] && rm -f "$TEMP_FILE"
    [[ -n "$TEMP_DIR" && -d "$TEMP_DIR" ]] && rm -rf "$TEMP_DIR"
    
    exit $exit_code
}

# Setează trap pentru EXIT (se execută ÎNTOTDEAUNA la ieșire)
trap cleanup EXIT

# Trap pentru semnale de întrerupere
trap 'echo "Interrupted!"; exit 130' INT TERM

# Creează resurse temporare
TEMP_FILE=$(mktemp)
TEMP_DIR=$(mktemp -d)

echo "Working with $TEMP_FILE and $TEMP_DIR"

# ... restul scriptului ...
# Cleanup se execută automat la sfârșit (sau la eroare)
```

---

## 5.2 Trap pentru ERR

```bash
#!/bin/bash
set -euo pipefail

# Handler pentru erori
error_handler() {
    local line=$1
    local command=$2
    local code=$3
    
    echo "═══════════════════════════════════════════" >&2
    echo "ERROR at line $line" >&2
    echo "Command: $command" >&2
    echo "Exit code: $code" >&2
    echo "═══════════════════════════════════════════" >&2
}

# Trap ERR (se execută când o comandă eșuează)
trap 'error_handler $LINENO "$BASH_COMMAND" $?' ERR

# Test - această comandă va eșua
echo "About to fail..."
false
echo "This line won't execute"
```

> ⚠️ **Capcană: trap NU se moștenește în subshell-uri!**
> 
> ```bash
> trap 'echo "Error"' ERR
> (
>     false    # trap-ul NU se execută aici!
> )
> ```

---

## 5.3 Funcția `die()`

Pattern standard pentru erori fatale:

```bash
#!/bin/bash
set -euo pipefail

# Funcție pentru erori fatale
die() {
    echo "FATAL ERROR: $*" >&2
    exit 1
}

# Utilizare
[ $# -ge 1 ] || die "Usage: $0 <filename>"
[ -f "$1" ]  || die "File not found: $1"
[ -r "$1" ]  || die "Cannot read: $1"

command -v jq >/dev/null 2>&1 || die "Required tool 'jq' not installed"
```

---

## 5.4 Pattern-uri de Verificare

```bash
#!/bin/bash
set -euo pipefail

# === VERIFICARE ARGUMENTE ===
[ $# -ge 2 ] || { echo "Usage: $0 <input> <output>"; exit 1; }

INPUT="$1"
OUTPUT="$2"

# === VERIFICARE FIȘIERE ===
# Fișier există
[ -f "$INPUT" ] || die "Input file not found: $INPUT"

# Fișier citibil
[ -r "$INPUT" ] || die "Cannot read input: $INPUT"

# Director există
[ -d "$(dirname "$OUTPUT")" ] || die "Output directory doesn't exist"

# Poate scrie în director
[ -w "$(dirname "$OUTPUT")" ] || die "Cannot write to output directory"

# === VERIFICARE DEPENDENȚE ===
for cmd in jq curl grep; do
    command -v "$cmd" >/dev/null 2>&1 || die "Required: $cmd"
done

# === VERIFICARE PERMISIUNI ===
[ "$(id -u)" -eq 0 ] && die "Do not run as root!"

# === VERIFICARE ENVIRONMENT ===
: "${API_KEY:?Error: API_KEY environment variable required}"
: "${DB_HOST:?Error: DB_HOST environment variable required}"
```

---

# 6. Logging Profesional

## 6.1 Sistem Complet cu Nivele

```bash
#!/bin/bash

# Configurare logging
readonly LOG_FILE="${LOG_FILE:-/tmp/$(basename "$0" .sh).log}"
LOG_LEVEL="${LOG_LEVEL:-INFO}"

# Nivele de logging (ordine crescătoare severitate)
declare -A LOG_LEVELS=(
    [DEBUG]=0
    [INFO]=1
    [WARN]=2
    [ERROR]=3
    [FATAL]=4
)

# Funcția principală de logging
log() {
    local level="$1"
    shift
    local message="$*"
    
    # Verifică dacă acest nivel trebuie logat
    local level_num="${LOG_LEVELS[$level]:-1}"
    local threshold="${LOG_LEVELS[$LOG_LEVEL]:-1}"
    
    [ "$level_num" -lt "$threshold" ] && return
    
    # Format: [TIMESTAMP] [LEVEL] [SCRIPT:LINE] Message
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local log_line="[$timestamp] [$level] [$(basename "$0"):${BASH_LINENO[0]}] $message"
    
    # Scrie în fișierul de log
    echo "$log_line" >> "$LOG_FILE"
    
    # Afișează pe ecran bazat pe nivel
    case "$level" in
        DEBUG|INFO)
            [ "$level_num" -ge "$threshold" ] && echo "$log_line"
            ;;
        WARN)
            echo "$log_line" >&2
            ;;
        ERROR|FATAL)
            echo "$log_line" >&2
            ;;
    esac
}

# Helper functions
log_debug() { log DEBUG "$@"; }
log_info()  { log INFO "$@"; }
log_warn()  { log WARN "$@"; }
log_error() { log ERROR "$@"; }
log_fatal() { log FATAL "$@"; exit 1; }
```

---

## 6.2 Logging Simplu

Pentru scripturi mai mici, o variantă simplificată:

```bash
#!/bin/bash

readonly LOG_FILE="/tmp/$(basename "$0" .sh).log"

# Logging simplu
log() {
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $*" | tee -a "$LOG_FILE"
}

# Error logging
err() {
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] ERROR: $*" | tee -a "$LOG_FILE" >&2
}

# Utilizare
log "Script started"
log "Processing file: $INPUT"
err "File not found!"
log "Script completed"
```

---

# 7. Debugging

## 7.1 Opțiuni de Debug

```bash
#!/bin/bash

# Activare debug complet - afișează fiecare comandă înainte de execuție
set -x

# Dezactivare debug
set +x

# Debug selectiv pentru o secțiune
echo "Before debug"
set -x
# comenzi de debugat
set +x
echo "After debug"

# Verbose mode - afișează liniile citite
set -v

# Combinație completă pentru debugging maxim
set -xv
```

---

## 7.2 Debug Mode Condițional

```bash
#!/bin/bash

# Activare din environment
DEBUG="${DEBUG:-false}"
VERBOSE="${VERBOSE:-0}"

# Activare set -x din environment
[[ "$DEBUG" == "true" ]] && set -x

# Funcții de debug
debug() {
    [[ "$DEBUG" == "true" ]] && echo "[DEBUG] $*" >&2
}

verbose() {
    [ "$VERBOSE" -ge 1 ] && echo "$*" >&2
}

very_verbose() {
    [ "$VERBOSE" -ge 2 ] && echo "[VERBOSE] $*" >&2
}

# Utilizare
debug "Variable x=$x"
verbose "Processing step 1"
very_verbose "Internal state: $internal_var"
```

---

## 7.3 Tehnici Practice de Debug

```bash
#!/bin/bash

# Print checkpoints
echo "=== Checkpoint 1: before processing ===" >&2

# Dump variables
echo "DEBUG: var1=$var1, var2=$var2" >&2

# Dump array
echo "DEBUG: array=(${arr[*]})" >&2

# Call stack (who called this function?)
echo "Called from: $(caller 0)" >&2

# Full call stack
local frame=0
while caller $frame; do
    ((frame++))
done

# Trap pentru a vedea fiecare linie executată
trap 'echo "DEBUG: Line $LINENO: $BASH_COMMAND"' DEBUG

# Pause pentru debugging interactiv
read -p "Press Enter to continue..." </dev/tty
```

---

# 8. Template Script Profesional

Acest template încorporează toate best practices discutate:

```bash
#!/bin/bash
#
# Script: template.sh
# Descriere: Template pentru scripturi de producție
# Autor: [Nume]
# Versiune: 1.0.0
# Data: 2025-01
# Licență: MIT
#
# USAGE:
# ./template.sh [options] <input_file>
#
# EXAMPLE:
# ./template.sh -v -o output.txt input.txt
#

# ============================================================
# STRICT MODE
# ============================================================
set -euo pipefail
IFS=$'\n\t'

# ============================================================
# CONSTANTE (readonly - nu pot fi modificate)
# ============================================================
readonly SCRIPT_NAME=$(basename "$0")
readonly SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
readonly SCRIPT_VERSION="1.0.0"

# ============================================================
# CONFIGURARE DEFAULT (pot fi suprascrise din environment)
# ============================================================
VERBOSE="${VERBOSE:-0}"
DEBUG="${DEBUG:-false}"
DRY_RUN="${DRY_RUN:-false}"
LOG_FILE="${LOG_FILE:-/tmp/${SCRIPT_NAME%.*}.log}"

# Variabile de lucru
INPUT=""
OUTPUT=""

# ============================================================
# FUNCȚII HELPER
# ============================================================

usage() {
    cat << EOF
$SCRIPT_NAME v$SCRIPT_VERSION

Descriere scurtă a ce face scriptul.

USAGE:
    $SCRIPT_NAME [options] <input_file>

OPTIONS:
    -h, --help          Afișează acest mesaj
    -V, --version       Afișează versiunea
    -v, --verbose       Mod verbose (poate fi repetat: -vv)
    -n, --dry-run       Simulare fără modificări
    -o, --output FILE   Fișier output (default: stdout)

ENVIRONMENT:
    DEBUG=true          Activează debug mode
    LOG_FILE=/path      Specifică fișierul de log

EXAMPLES:
    $SCRIPT_NAME input.txt
    $SCRIPT_NAME -v -o output.txt input.txt
    DEBUG=true $SCRIPT_NAME input.txt

EOF
}

version() {
    echo "$SCRIPT_NAME versiunea $SCRIPT_VERSION"
}

log() {
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $*" | tee -a "$LOG_FILE"
}

die() {
    echo "FATAL: $*" >&2
    exit 1
}

debug() {
    [[ "$DEBUG" == "true" ]] && echo "[DEBUG] $*" >&2
    return 0
}

verbose() {
    [ "$VERBOSE" -ge 1 ] && echo "$*" >&2
    return 0
}

# ============================================================
# CLEANUP (se execută automat la EXIT)
# ============================================================
cleanup() {
    local exit_code=$?
    
    debug "Cleanup triggered with exit code: $exit_code"
    
    # Cleanup code here (delete temp files, etc.)
    
    exit $exit_code
}

trap cleanup EXIT
trap 'echo "Interrupted"; exit 130' INT TERM

# ============================================================
# PARSARE ARGUMENTE
# ============================================================
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            -V|--version)
                version
                exit 0
                ;;
            -v|--verbose)
                ((VERBOSE++))
                shift
                ;;
            -n|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -o|--output)
                OUTPUT="$2"
                shift 2
                ;;
            --output=*)
                OUTPUT="${1#*=}"
                shift
                ;;
            --)
                shift
                break
                ;;
            -*)
                die "Unknown option: $1"
                ;;
            *)
                break
                ;;
        esac
    done
    
    # Argumente poziționale
    [[ $# -ge 1 ]] || die "Missing required argument: input_file"
    INPUT="$1"
}

# ============================================================
# VALIDARE
# ============================================================
validate() {
    debug "Validating input: $INPUT"
    
    [[ -f "$INPUT" ]] || die "File not found: $INPUT"
    [[ -r "$INPUT" ]] || die "Cannot read: $INPUT"
    
    if [[ -n "$OUTPUT" && -e "$OUTPUT" ]]; then
        verbose "Warning: output file exists, will be overwritten"
    fi
}

# ============================================================
# LOGICA PRINCIPALĂ
# ============================================================
process() {
    log "Processing: $INPUT"
    debug "Verbose level: $VERBOSE"
    debug "Dry run: $DRY_RUN"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log "DRY RUN - no changes made"
        return 0
    fi
    
    # === IMPLEMENTARE AICI ===
    
    log "Processing complete"
}

main() {
    parse_args "$@"
    validate
    process
}

# ============================================================
# EXECUȚIE
# ============================================================
main "$@"
```

---

# 9. Integrare și Best Practices

## 9.1 Checklist Pre-Commit

Înainte de a considera un script "gata":

```
□ Shebang corect: #!/bin/bash
□ set -euo pipefail în primele linii
□ Toate variabilele din funcții au `local`
□ declare -A pentru toate arrays asociative
□ Ghilimele pentru "${array[@]}" în for loops
□ Funcție cleanup() cu trap EXIT
□ Funcție die() pentru erori fatale
□ Funcție usage() pentru help
□ Validare argumente înainte de procesare
□ Verificare dependențe externe
□ Log pentru operații importante
□ shellcheck rulat fără warnings
```

---

## 9.2 Shellcheck

```bash
# Instalare
sudo apt install shellcheck

# Utilizare
shellcheck script.sh

# Ignorare warning specific (în script)
# shellcheck disable=SC2086
echo $variable    # intenționat fără ghilimele

# Verificare toate scripturile dintr-un director
find . -name "*.sh" -exec shellcheck {} \;
```

---

## 9.3 Pattern-uri de Evitat

```bash
# GREȘIT: Variabilă globală în funcție
process() {
    result="value"    # Modifică global
}

# CORECT:
process() {
    local result="value"
    echo "$result"
}

# GREȘIT: Array asociativ fără declare
hash[key]="value"

# CORECT:
declare -A hash
hash[key]="value"

# GREȘIT: Iterare fără ghilimele
for i in ${arr[@]}; do

# CORECT:
for i in "${arr[@]}"; do

# GREȘIT: Presupunere că set -e prinde tot
set -e
if command_that_fails; then ...

# CORECT: Verificare explicită
if ! command_that_fails; then
    die "Command failed"
fi
```

---

## 9.4 Resurse Adiționale

| Resursă | URL |
|---------|-----|
| Bash Manual | https://www.gnu.org/software/bash/manual/ |
| ShellCheck | https://www.shellcheck.net/ |
| Google Shell Style Guide | https://google.github.io/styleguide/shellguide.html |
| Bash Hackers Wiki | https://wiki.bash-hackers.org/ |
| explainshell.com | https://explainshell.com/ |

---

## Quick Reference Card

```bash
# === solidEȚE ===
set -euo pipefail
IFS=$'\n\t'

# === VARIABILE ===
local var="value"              # În funcții
readonly CONST="value"         # Constante
VAR="${VAR:-default}"          # Default value
: "${REQUIRED:?Error msg}"     # Required

# === ARRAYS ===
arr=(a b c)                    # Indexat
declare -A hash                # Asociativ (OBLIGATORIU!)
"${arr[@]}"                    # Iterare (CU GHILIMELE!)

# === FUNCȚII ===
func() { local v="..."; echo "$1"; return 0; }
result=$(func arg)

# === ERROR HANDLING ===
trap cleanup EXIT
trap 'handler $LINENO' ERR
die() { echo "ERR: $*" >&2; exit 1; }

# === VERIFICĂRI ===
[[ -f "$f" ]] || die "nu există"
[[ -n "$v" ]] || die "variabilă goală"
command -v cmd >/dev/null || die "cmd lipsește"

# === DEBUGGING ===
set -x / set +x
debug() { [[ "$DEBUG" == "true" ]] && echo "[D] $*" >&2; }
```

---

*Material de laborator pentru cursul de Sisteme de Operare | ASE București - CSIE*
*Adaptat pentru seminarul de Advanced Bash Scripting*
