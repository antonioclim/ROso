# S05_TC01 - Funcții Avansate în Bash

> **Sisteme de Operare** | ASE București - CSIE  
> Material de laborator - Seminar 5 (SPLIT din TC6a)

---

> 🚨 **ÎNAINTE DE A ÎNCEPE TEMA**
>
> 1. Descarcă și configurează pachetul `002HWinit` (vezi GHID_STUDENT_RO.md)
> 2. Deschide un terminal și navighează în `~/HOMEWORKS`
> 3. Pornește înregistrarea cu:
>    ```bash
>    python3 record_homework_tui_RO.py
>    ```
>    sau varianta Bash:
>    ```bash
>    ./record_homework_RO.sh
>    ```
> 4. Completează datele cerute (nume, grupă, nr. temă)
> 5. **ABIA APOI** începe să rezolvi cerințele de mai jos

---

## Obiective

La finalul acestui laborator, studentul va fi capabil să:
- Creeze funcții cu variabile locale și return values
- Folosească nameref pentru return by reference
- Implementeze funcții recursive
- Proceseze argumente în moduri avansate (getopts)

---


## 2. Variabile Locale și Scope

### 2.1 Keyword `local`

```bash
GLOBAL="global"

my_function() {
    local LOCAL_VAR="local"       # vizibilă doar în funcție
    GLOBAL="modified"             # modifică variabila globală
    
    echo "Inside: GLOBAL=$GLOBAL, LOCAL_VAR=$LOCAL_VAR"
}

my_function
echo "Outside: GLOBAL=$GLOBAL"
echo "Outside: LOCAL_VAR=$LOCAL_VAR"  # gol - nu e vizibilă
```

### 2.2 Scope și Funcții Nested

```bash
#!/bin/bash

GLOBAL="global"

outer() {
    local OUTER_LOCAL="outer"
    
    inner() {
        local INNER_LOCAL="inner"
        echo "Inner sees:"
        echo "  GLOBAL=$GLOBAL"
        echo "  OUTER_LOCAL=$OUTER_LOCAL"
        echo "  INNER_LOCAL=$INNER_LOCAL"
    }
    
    inner
    echo "Outer: INNER_LOCAL=$INNER_LOCAL"  # gol
}

outer
```

---

## 3. Returnare Valori

### 3.1 Metoda 1: Echo și Capturare

```bash
get_sum() {
    local a=$1 b=$2
    echo $((a + b))
}

result=$(get_sum 5 3)
echo "Suma: $result"  # 8
```

### 3.2 Metoda 2: Variabilă Globală

```bash
calculate() {
    RESULT=$((${1} + ${2}))
}

calculate 5 3
echo "Rezultat: $RESULT"  # 8
```

### 3.3 Metoda 3: Return Code (0-255)

```bash
is_even() {
    (( $1 % 2 == 0 ))
}

if is_even 4; then
    echo "4 este par"
fi

is_even 4
echo "Exit code: $?"  # 0 (true)
```

### 3.4 Metoda 4: Nameref (Bash 4.3+)

```bash
get_data() {
    local -n ref=$1     # nameref - referință la variabila pasată
    ref="valoare calculată"
}

declare result
get_data result
echo "$result"  # "valoare calculată"

# Util pentru returnare multipla
get_dimensions() {
    local -n width_ref=$1
    local -n height_ref=$2
    width_ref=800
    height_ref=600
}

declare w h
get_dimensions w h
echo "Width: $w, Height: $h"
```

---

## 4. Funcții Recursive

### 4.1 Factorial

```bash
factorial() {
    local n=$1
    if (( n <= 1 )); then
        echo 1
    else
        local prev=$(factorial $((n - 1)))
        echo $((n * prev))
    fi
}

echo "5! = $(factorial 5)"  # 120
```

### 4.2 Fibonacci

```bash
fib() {
    local n=$1
    if (( n <= 1 )); then
        echo $n
    else
        local a=$(fib $((n - 1)))
        local b=$(fib $((n - 2)))
        echo $((a + b))
    fi
}

echo "fib(10) = $(fib 10)"  # 55
```

### 4.3 Traversare Director (Recursiv)

```bash
traverse() {
    local dir="${1:-.}"
    local indent="${2:-}"
    
    for item in "$dir"/*; do
        [[ -e "$item" ]] || continue
        echo "${indent}$(basename "$item")"
        
        if [[ -d "$item" ]]; then
            traverse "$item" "${indent}  "
        fi
    done
}

traverse /etc 2>/dev/null | head -20
```

---

## 5. Procesare Argumente cu getopts

### 5.1 Sintaxă getopts

```bash
#!/bin/bash

usage() {
    cat << EOF
Usage: $0 [-h] [-v] [-o file] [-n num] [args...]

Options:
    -h          Show this help
    -v          Verbose mode
    -o FILE     Output file
    -n NUM      Number of iterations
EOF
    exit 1
}

# Defaults
VERBOSE=false
OUTPUT=""
NUM=1

# Parse options
# ":" la început = silent mode (gestionăm noi erorile)
# ":" după literă = opțiunea necesită argument
while getopts ":hvo:n:" opt; do
    case $opt in
        h) usage ;;
        v) VERBOSE=true ;;
        o) OUTPUT="$OPTARG" ;;
        n) 
            [[ "$OPTARG" =~ ^[0-9]+$ ]] || { echo "Error: -n requires number"; exit 1; }
            NUM="$OPTARG" 
            ;;
        :) echo "Option -$OPTARG requires an argument"; exit 1 ;;
        \?) echo "Invalid option: -$OPTARG"; exit 1 ;;
    esac
done

# Shift pentru a elimina opțiunile procesate
shift $((OPTIND - 1))

# Argumente rămase
ARGS=("$@")

echo "VERBOSE=$VERBOSE"
echo "OUTPUT=$OUTPUT"
echo "NUM=$NUM"
echo "Remaining args: ${ARGS[*]}"
```

### 5.2 Opțiuni Lungi (Manual)

```bash
#!/bin/bash

VERBOSE=false
OUTPUT=""
NUM=1
ARGS=()

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        -v|--verbose)
            VERBOSE=true
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
        -n|--num)
            NUM="$2"
            shift 2
            ;;
        --num=*)
            NUM="${1#*=}"
            shift
            ;;
        --)
            shift
            ARGS+=("$@")
            break
            ;;
        -*)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
        *)
            ARGS+=("$1")
            shift
            ;;
    esac
done
```

---

## 6. Pattern-uri Utile

### 6.1 Funcție cu Validare

```bash
process_file() {
    local file="${1:?Error: filename required}"
    
    [[ -f "$file" ]] || { echo "Error: not a file: $file" >&2; return 1; }
    [[ -r "$file" ]] || { echo "Error: cannot read: $file" >&2; return 1; }
    
    # Procesare...
    cat "$file"
}
```

### 6.2 Wrapper Function

```bash
# Log wrapper
log_run() {
    echo "[$(date '+%H:%M:%S')] Running: $*" >&2
    "$@"
    local status=$?
    echo "[$(date '+%H:%M:%S')] Finished with status: $status" >&2
    return $status
}

log_run ls -la
log_run grep pattern file.txt
```

### 6.3 Memoization (Caching)

```bash
declare -A _cache

memoized_expensive() {
    local key="$*"
    
    if [[ -v _cache[$key] ]]; then
        echo "${_cache[$key]}"
        return
    fi
    
    # Calculul scump
    local result=$(expensive_operation "$@")
    _cache[$key]="$result"
    
    echo "$result"
}
```

---

## 7. Exerciții

### Exercițiul 1
Creați o funcție `validate_ip` care verifică dacă un string este o adresă IP validă.

### Exercițiul 2
Implementați o funcție `tree_lite` care afișează structura de directoare similar comenzii `tree`.

### Exercițiul 3
Creați un script cu getopts care acceptă: `-i input`, `-o output`, `-v` verbose, `-h` help.

---

## Cheat Sheet

```bash
# DEFINIRE FUNCȚIE
func() { local v="..."; echo "$1"; return 0; }

# VARIABILE LOCALE
local var="value"
local -n ref=$1        # nameref

# RETURN VALUES
result=$(func arg)     # capture output
func; echo $?          # exit code
local -n ref=$1; ref="value"  # by reference

# GETOPTS
while getopts ":hvo:" opt; do
    case $opt in
        h) usage ;;
        v) VERBOSE=true ;;
        o) OUTPUT="$OPTARG" ;;
        :) echo "Needs arg" ;;
        \?) echo "Invalid" ;;
    esac
done
shift $((OPTIND-1))
```

---

## 📤 Finalizare și Trimitere

După ce ai terminat toate cerințele:

1. **Oprește înregistrarea** tastând:
   ```bash
   STOP_tema
   ```
   sau apasă `Ctrl+D`

2. **Așteaptă** - scriptul va:
   - Genera semnătura criptografică
   - Încărca automat fișierul pe server

3. **Verifică mesajul final**:
   - ✅ `ÎNCĂRCARE REUȘITĂ!` - tema a fost trimisă
   - ❌ Dacă upload-ul eșuează, fișierul `.cast` este salvat local - trimite-l manual mai târziu cu comanda afișată

> ⚠️ **NU modifica fișierul `.cast`** după generare - semnătura devine invalidă!

---

*By Revolvix for OPERATING SYSTEMS class | restricted licence 2017-2030*
