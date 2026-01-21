# TC6a - Scripting Avansat - Funcții și Arrays

> **Sisteme de Operare** | ASE București - CSIE  
> Material de laborator - Seminar 5

---

## Obiective

La finalul acestui laborator, studentul va fi capabil să:
- Creeze și folosească funcții avansate
- Lucreze cu arrays indexate și asociative
- Proceseze argumente în moduri complexe
- Implementeze pattern-uri de programare în Bash

---

## 1. Funcții Avansate

### 1.1 Definire și Structură

```bash
#!/bin/bash

# Funcție cu documentație
# Usage: greet <name> [greeting]
# Returns: 0 on success, 1 on error
greet() {
    local name="${1:?Error: name required}"
    local greeting="${2:-Hello}"
    
    echo "$greeting, $name!"
    return 0
}
```

### 1.2 Returnare Valori

```bash
# Metoda 1: Prin echo (capturare cu $())
get_sum() {
    local a=$1 b=$2
    echo $((a + b))
}
result=$(get_sum 5 3)

# Metoda 2: Prin variabilă globală
calculate() {
    RESULT=$((${1} + ${2}))
}
calculate 5 3
echo $RESULT

# Metoda 3: Prin return (doar 0-255)
is_even() {
    [ $(($1 % 2)) -eq 0 ]
}
if is_even 4; then echo "Par"; fi

# Metoda 4: Prin nameref (Bash 4.3+)
get_data() {
    local -n ref=$1
    ref="valoare calculată"
}
declare result
get_data result
echo "$result"
```

### 1.3 Variabile Locale și Scope

```bash
#!/bin/bash

GLOBAL="global"

outer() {
    local OUTER_LOCAL="outer local"
    GLOBAL="modified by outer"
    
    inner() {
        local INNER_LOCAL="inner local"
        echo "Inner sees: GLOBAL=$GLOBAL"
        echo "Inner sees: OUTER_LOCAL=$OUTER_LOCAL"
    }
    
    inner
}

outer
echo "After: GLOBAL=$GLOBAL"
echo "After: OUTER_LOCAL=$OUTER_LOCAL"  # gol
```

### 1.4 Funcții Recursive

```bash
# Factorial
factorial() {
    local n=$1
    if [ $n -le 1 ]; then
        echo 1
    else
        local prev=$(factorial $((n - 1)))
        echo $((n * prev))
    fi
}
echo "5! = $(factorial 5)"

# Fibonacci
fib() {
    local n=$1
    if [ $n -le 1 ]; then
        echo $n
    else
        local a=$(fib $((n-1)))
        local b=$(fib $((n-2)))
        echo $((a + b))
    fi
}
```

---

## 2. Arrays Indexate

### 2.1 Creare și Acces

```bash
# Creare
arr=()                          # array gol
arr=(a b c d e)                 # cu valori
arr=([0]=a [2]=c [5]=f)         # cu indici specifici

# Acces
echo ${arr[0]}                  # primul element
echo ${arr[-1]}                 # ultimul element (Bash 4.3+)
echo ${arr[@]}                  # toate elementele
echo ${arr[*]}                  # toate ca string
echo ${#arr[@]}                 # lungimea

# Indici
echo ${!arr[@]}                 # toți indicii
```

### 2.2 Modificare

```bash
# Adăugare
arr+=(element)                  # append
arr[${#arr[@]}]="element"       # append explicit
arr[10]="element"               # la index specific

# Modificare
arr[0]="nou"

# Ștergere
unset arr[2]                    # element specific
unset arr                       # întreg array
arr=()                          # resetare la gol
```

### 2.3 Iterare

```bash
# Prin valori
for item in "${arr[@]}"; do
    echo "$item"
done

# Prin indici
for i in "${!arr[@]}"; do
    echo "[$i] = ${arr[$i]}"
done

# Clasic (index numeric)
for ((i=0; i<${#arr[@]}; i++)); do
    echo "[$i] = ${arr[$i]}"
done
```

### 2.4 Operații pe Arrays

```bash
# Slice
echo "${arr[@]:1:3}"            # elemente 1,2,3

# Căutare
[[ " ${arr[@]} " =~ " element " ]] && echo "Găsit"

# Sortare
sorted=($(printf '%s\n' "${arr[@]}" | sort))

# Reverse
for ((i=${#arr[@]}-1; i>=0; i--)); do
    reversed+=("${arr[$i]}")
done

# Filtru (doar numere pare)
for item in "${arr[@]}"; do
    (( item % 2 == 0 )) && filtered+=("$item")
done
```

---

## 3. Arrays Asociative (Hash/Dict)

### 3.1 Declarare și Utilizare

```bash
# Declarare OBLIGATORIE
declare -A config

# Populare
config[host]="localhost"
config[port]="8080"
config[user]="admin"

# Sau tot odată
declare -A config=(
    [host]="localhost"
    [port]="8080"
    [user]="admin"
)

# Acces
echo ${config[host]}
echo ${config[@]}               # toate valorile
echo ${!config[@]}              # toate cheile
echo ${#config[@]}              # numărul de chei
```

### 3.2 Iterare

```bash
# Prin chei
for key in "${!config[@]}"; do
    echo "$key = ${config[$key]}"
done

# Verificare existență cheie
if [[ -v config[host] ]]; then
    echo "Host is set"
fi

# Default value
echo "${config[missing]:-default}"
```

### 3.3 Exemple Practice

```bash
# Contorizare cuvinte
declare -A word_count
while read -r word; do
    ((word_count[$word]++))
done < <(tr ' ' '\n' < text.txt)

for word in "${!word_count[@]}"; do
    echo "$word: ${word_count[$word]}"
done | sort -t: -k2 -rn

# Cache simplu
declare -A cache
get_cached() {
    local key=$1
    if [[ -v cache[$key] ]]; then
        echo "${cache[$key]}"
    else
        local value=$(expensive_operation "$key")
        cache[$key]="$value"
        echo "$value"
    fi
}
```

---

## 4. Procesare Argumente Avansată

### 4.1 getopts

```bash
#!/bin/bash

usage() {
    echo "Usage: $0 [-h] [-v] [-o file] [-n num] [args...]"
    exit 1
}

VERBOSE=false
OUTPUT=""
NUM=1

while getopts ":hvo:n:" opt; do
    case $opt in
        h) usage ;;
        v) VERBOSE=true ;;
        o) OUTPUT="$OPTARG" ;;
        n) NUM="$OPTARG" ;;
        :) echo "Option -$OPTARG requires argument"; exit 1 ;;
        \?) echo "Invalid option: -$OPTARG"; exit 1 ;;
    esac
done

shift $((OPTIND-1))
ARGS=("$@")

echo "VERBOSE=$VERBOSE, OUTPUT=$OUTPUT, NUM=$NUM"
echo "Remaining args: ${ARGS[@]}"
```

### 4.2 Opțiuni Lungi Manual

```bash
#!/bin/bash

ARGS=()
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage; exit 0 ;;
        -v|--verbose)
            VERBOSE=true; shift ;;
        -o|--output)
            OUTPUT="$2"; shift 2 ;;
        --output=*)
            OUTPUT="${1#*=}"; shift ;;
        -n|--num)
            NUM="$2"; shift 2 ;;
        --num=*)
            NUM="${1#*=}"; shift ;;
        --)
            shift; ARGS+=("$@"); break ;;
        -*)
            echo "Unknown option: $1"; exit 1 ;;
        *)
            ARGS+=("$1"); shift ;;
    esac
done
```

---

## 5. Exerciții Practice

### Exercițiul 1: Stack Implementation

```bash
#!/bin/bash

declare -a STACK=()

push() {
    STACK+=("$1")
}

pop() {
    local len=${#STACK[@]}
    if [ $len -eq 0 ]; then
        echo "Stack empty" >&2
        return 1
    fi
    echo "${STACK[-1]}"
    unset STACK[-1]
}

peek() {
    echo "${STACK[-1]:-}"
}

# Test
push "a"
push "b"
push "c"
echo "Pop: $(pop)"  # c
echo "Peek: $(peek)"  # b
```

### Exercițiul 2: Config Parser

```bash
#!/bin/bash

declare -A CONFIG

parse_config() {
    local file=$1
    while IFS='=' read -r key value; do
        [[ $key =~ ^[[:space:]]*# ]] && continue
        [[ -z $key ]] && continue
        key=$(echo "$key" | tr -d ' ')
        value=$(echo "$value" | tr -d ' ')
        CONFIG[$key]="$value"
    done < "$file"
}

get_config() {
    echo "${CONFIG[$1]:-$2}"
}

# Test
parse_config "app.conf"
echo "Host: $(get_config host localhost)"
```

---

## Cheat Sheet

```bash
# FUNCȚII
func() { local v="..."; echo $1; return 0; }
result=$(func arg)
local -n ref=$1    # nameref

# ARRAYS INDEXATE
arr=(a b c)
${arr[0]}          # element
${arr[@]}          # toate
${#arr[@]}         # lungime
${!arr[@]}         # indici
arr+=(d)           # append
unset arr[1]       # șterge

# ARRAYS ASOCIATIVE
declare -A hash
hash[key]="value"
${hash[key]}       # acces
${!hash[@]}        # chei
[[ -v hash[key] ]] # există?

# ITERARE
for item in "${arr[@]}"; do ... done
for key in "${!hash[@]}"; do ... done

# GETOPTS
while getopts ":hvo:" opt; do
    case $opt in
        h) usage ;;
        v) VERBOSE=true ;;
        o) OUTPUT="$OPTARG" ;;
    esac
done
shift $((OPTIND-1))
```

---
*Material adaptat pentru cursul de Sisteme de Operare | ASE București - CSIE*
