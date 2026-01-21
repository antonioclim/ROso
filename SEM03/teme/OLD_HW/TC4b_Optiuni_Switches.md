# TC4b - Opțiuni și Switch-uri în Scripturi

> **Sisteme de Operare** | ASE București - CSIE  
> Material de laborator - Seminar 3

---

## Obiective

La finalul acestui laborator, studentul va fi capabil să:
- Parseze argumente în linia de comandă în scripturi Bash
- Folosească `getopts` pentru opțiuni scurte
- Implementeze opțiuni lungi manual
- Creeze interfețe CLI profesionale

---

## 1. Introducere în Parsarea Argumentelor

### 1.1 Tipuri de Argumente

```bash
./script.sh -v -o output.txt --config=file.conf input.txt

# Tipuri:
# -v → opțiune scurtă (flag)
# -o output.txt → opțiune scurtă cu argument
# --config=file.conf → opțiune lungă cu argument
# input.txt → argument pozițional
```

### 1.2 Variabile Speciale pentru Argumente

```bash
$0          # Numele scriptului
$1, $2...   # Argumentele poziționale
$#          # Numărul total de argumente
$@          # Toate argumentele ca listă
$*          # Toate argumentele ca string
shift       # Elimină primul argument, deplasează restul
```

---

## 2. Parsare Manuală Simplă

### 2.1 Cu shift

```bash
#!/bin/bash

VERBOSE=false
OUTPUT=""
ARGS=()

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            echo "Ajutor: $0 [-v] [-o FILE] input"
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
        --)
            shift
            break
            ;;
        -*)
            echo "Opțiune necunoscută: $1" >&2
            exit 1
            ;;
        *)
            ARGS+=("$1")
            shift
            ;;
    esac
done

echo "Verbose: $VERBOSE"
echo "Output: $OUTPUT"
echo "Argumente: ${ARGS[@]}"
```

---

## 3. getopts - Parsare Standard

### 3.1 Sintaxă de Bază

```bash
while getopts "optstring" opt; do
    case $opt in
        ...
    esac
done

# optstring format:
# a → opțiune -a fără argument
# a: → opțiune -a CU argument obligatoriu
# :a → : la început = silent error mode
```

### 3.2 Variabile getopts

| Variabilă | Descriere |
|-----------|-----------|
| `$opt` | Opțiunea curentă |
| `$OPTARG` | Argumentul opțiunii curente |
| `$OPTIND` | Indexul următorului argument de procesat |

### 3.3 Exemplu Complet

```bash
#!/bin/bash

usage() {
    cat << EOF
Utilizare: $0 [opțiuni] <fișier>

Opțiuni:
    -h          Afișează acest mesaj
    -v          Mod verbose
    -o FILE     Fișier output
    -n NUM      Număr de iterații
    -f          Forțează suprascrierea

Exemple:
    $0 -v input.txt
    $0 -o output.txt -n 5 input.txt
EOF
    exit 1
}

# Valori default
VERBOSE=false
FORCE=false
OUTPUT=""
NUM=1

# Parsare opțiuni
while getopts ":hvo:n:f" opt; do
    case $opt in
        h) usage ;;
        v) VERBOSE=true ;;
        o) OUTPUT="$OPTARG" ;;
        n)
            NUM="$OPTARG"
            if ! [[ "$NUM" =~ ^[0-9]+$ ]]; then
                echo "Eroare: -n necesită un număr" >&2
                exit 1
            fi
            ;;
        f) FORCE=true ;;
        :)
            echo "Eroare: Opțiunea -$OPTARG necesită un argument" >&2
            exit 1
            ;;
        \?)
            echo "Eroare: Opțiune invalidă -$OPTARG" >&2
            exit 1
            ;;
    esac
done

# Elimină opțiunile procesate
shift $((OPTIND - 1))

# Verifică argumentele poziționale
if [ $# -eq 0 ]; then
    echo "Eroare: Lipsește fișierul de input" >&2
    usage
fi

INPUT="$1"

# Afișare configurație
if $VERBOSE; then
    echo "Input:   $INPUT"
    echo "Output:  ${OUTPUT:-stdout}"
    echo "Iterații: $NUM"
    echo "Force:   $FORCE"
fi
```

---

## 4. Opțiuni Lungi (GNU-style)

### 4.1 Implementare Manuală

```bash
#!/bin/bash

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
        -c|--config)
            CONFIG="$2"
            shift 2
            ;;
        --config=*)
            CONFIG="${1#*=}"
            shift
            ;;
        --)
            shift
            break
            ;;
        -*)
            echo "Opțiune necunoscută: $1" >&2
            exit 1
            ;;
        *)
            break
            ;;
    esac
done

ARGS=("$@")
```

### 4.2 Pattern-uri pentru Opțiuni Lungi

```bash
# Opțiune cu =
--config=value    # ${1#*=} extrage "value"

# Opțiune cu spațiu
--config value    # $2 este "value", shift 2

# Suport pentru ambele
case $1 in
    --config=*)
        CONFIG="${1#*=}"
        shift
        ;;
    --config)
        CONFIG="$2"
        shift 2
        ;;
esac
```

---

## 5. Validare Argumente

```bash
# Verifică dacă fișierul există
validate_file() {
    local file="$1"
    [[ -f "$file" ]] || { echo "Eroare: '$file' nu există" >&2; exit 1; }
    [[ -r "$file" ]] || { echo "Eroare: nu pot citi '$file'" >&2; exit 1; }
}

# Verifică dacă e număr
validate_number() {
    local num="$1"
    [[ "$num" =~ ^[0-9]+$ ]] || { echo "Eroare: '$num' nu e număr" >&2; exit 1; }
}

# Verifică range
validate_range() {
    local num="$1" min="$2" max="$3"
    [[ $num -ge $min && $num -le $max ]] || {
        echo "Eroare: valoarea trebuie între $min și $max" >&2
        exit 1
    }
}
```

---

## 6. Template Script Profesional

```bash
#!/bin/bash
set -euo pipefail

readonly VERSION="1.0"
readonly SCRIPT_NAME=$(basename "$0")

VERBOSE=false
DRY_RUN=false
OUTPUT=""

usage() {
    cat << EOF
$SCRIPT_NAME v$VERSION

Utilizare: $SCRIPT_NAME [opțiuni] <input>

Opțiuni:
    -h, --help      Ajutor
    -V, --version   Versiune
    -v, --verbose   Mod verbose
    -n, --dry-run   Simulare
    -o, --output    Fișier output
EOF
}

log() { $VERBOSE && echo "[INFO] $*" >&2; }
error() { echo "[EROARE] $*" >&2; exit 1; }

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help) usage; exit 0 ;;
            -V|--version) echo "$VERSION"; exit 0 ;;
            -v|--verbose) VERBOSE=true; shift ;;
            -n|--dry-run) DRY_RUN=true; shift ;;
            -o|--output) OUTPUT="$2"; shift 2 ;;
            --output=*) OUTPUT="${1#*=}"; shift ;;
            --) shift; break ;;
            -*) error "Opțiune necunoscută: $1" ;;
            *) break ;;
        esac
    done
    
    [[ $# -ge 1 ]] || error "Lipsește input"
    INPUT="$1"
}

main() {
    parse_args "$@"
    log "Procesez: $INPUT"
    # Logica aici...
}

main "$@"
```

---

## 7. Exerciții Practice

### Exercițiul 1: Script cu getopts
```bash
#!/bin/bash
while getopts ":vo:n:" opt; do
    case $opt in
        v) VERBOSE=true ;;
        o) OUTPUT="$OPTARG" ;;
        n) NUM="$OPTARG" ;;
        :) echo "Lipsește arg pentru -$OPTARG"; exit 1 ;;
        \?) echo "Opțiune invalidă: -$OPTARG"; exit 1 ;;
    esac
done
shift $((OPTIND-1))
```

### Exercițiul 2: Validare Input
```bash
#!/bin/bash
[[ $# -ge 1 ]] || { echo "Utilizare: $0 <file>"; exit 1; }
[[ -f "$1" ]] || { echo "Fișierul nu există"; exit 1; }
[[ -r "$1" ]] || { echo "Nu am permisiuni de citire"; exit 1; }
```

---

## Cheat Sheet

```bash
# GETOPTS
while getopts ":hvo:n:" opt; do
    case $opt in
        h) usage ;;
        v) VERBOSE=true ;;
        o) OUTPUT="$OPTARG" ;;
        :) echo "Lipsește arg" ;;
        \?) echo "Opțiune invalidă" ;;
    esac
done
shift $((OPTIND-1))

# OPTSTRING
"abc"       # -a -b -c fără argumente
"a:b:c"     # -a ARG, -b ARG, -c fără arg
":abc"      # silent error mode

# OPȚIUNI LUNGI
--opt=val   # ${1#*=} extrage val
--opt val   # $2, shift 2

# VALIDARE
[[ -f "$f" ]]           # fișier există
[[ "$n" =~ ^[0-9]+$ ]]  # e număr
[[ -n "$v" ]]           # non-empty
```

---
*Material adaptat pentru cursul de Sisteme de Operare | ASE București - CSIE*
