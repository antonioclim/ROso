# S03_TC03 - Parametri în Scripturi Bash

> **Sisteme de Operare** | ASE București - CSIE  
> Material de laborator - Seminar 3 (Redistribuit)

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
- Proceseze argumentele din linia de comandă în scripturi
- Folosească parametrii poziționali și variabilele speciale
- Implementeze parsarea opțiunilor cu `shift` și `getopts`

---


## 2. Comanda shift

### 2.1 Utilizare de Bază

`shift` elimină primul parametru și mută restul cu o poziție.

```bash
#!/bin/bash

echo "Înainte de shift:"
echo "  \$1 = $1"
echo "  \$2 = $2"
echo "  \$# = $#"

shift

echo "După shift:"
echo "  \$1 = $1"    # fostul $2
echo "  \$2 = $2"    # fostul $3
echo "  \$# = $#"    # decrementat
```

### 2.2 Procesare Iterativă

```bash
#!/bin/bash

echo "Procesez $# argumente:"

while [ $# -gt 0 ]; do
    echo "  Argument: $1"
    shift
done

echo "Gata! Mai sunt $# argumente."
```

### 2.3 shift cu Număr

```bash
#!/bin/bash

echo "Argumentele: $@"
shift 2    # elimină primele 2
echo "După shift 2: $@"
```

---

## 3. Comanda getopts

### 3.1 Sintaxă de Bază

```bash
#!/bin/bash

# getopts "optstring" variable
# optstring: literele opțiunilor
# : după literă = opțiunea necesită argument

while getopts "hvo:" opt; do
    case $opt in
        h)
            echo "Ajutor: ./script.sh [-h] [-v] [-o file]"
            exit 0
            ;;
        v)
            VERBOSE=true
            ;;
        o)
            OUTPUT="$OPTARG"
            ;;
        \?)
            echo "Opțiune invalidă: -$OPTARG"
            exit 1
            ;;
        :)
            echo "Opțiunea -$OPTARG necesită un argument"
            exit 1
            ;;
    esac
done

# Sari peste opțiunile procesate
shift $((OPTIND - 1))

echo "VERBOSE: $VERBOSE"
echo "OUTPUT: $OUTPUT"
echo "Argumente rămase: $@"
```

### 3.2 Explicație Variabile getopts

| Variabilă | Descriere |
|-----------|-----------|
| `$OPTARG` | Valoarea argumentului opțiunii curente |
| `$OPTIND` | Indexul următorului argument de procesat |
| `$opt` | Litera opțiunii curente |

### 3.3 Exemplu Complet

```bash
#!/bin/bash

# Valori implicite
VERBOSE=false
OUTPUT=""
INPUT=""
COUNT=1

usage() {
    cat << EOF
Utilizare: $(basename $0) [opțiuni] [fișiere...]

Opțiuni:
    -h          Afișează acest ajutor
    -v          Mod verbose
    -o FILE     Fișier output
    -c NUM      Număr de repetări (implicit: 1)
EOF
    exit 1
}

while getopts ":hvo:c:" opt; do
    case $opt in
        h) usage ;;
        v) VERBOSE=true ;;
        o) OUTPUT="$OPTARG" ;;
        c) COUNT="$OPTARG" ;;
        :) echo "Eroare: -$OPTARG necesită argument"; exit 1 ;;
        \?) echo "Eroare: Opțiune necunoscută -$OPTARG"; exit 1 ;;
    esac
done

shift $((OPTIND - 1))

# Verificare argumente obligatorii
if [ $# -eq 0 ]; then
    echo "Eroare: Lipsesc fișierele de intrare"
    usage
fi

# Procesare
$VERBOSE && echo "Mod verbose activat"
$VERBOSE && echo "Output: $OUTPUT"
$VERBOSE && echo "Repetări: $COUNT"
$VERBOSE && echo "Fișiere: $@"

for file in "$@"; do
    echo "Procesez: $file"
done
```

---

## 4. Pattern-uri Comune

### 4.1 Verificare Număr Argumente

```bash
#!/bin/bash

if [ $# -lt 2 ]; then
    echo "Utilizare: $0 <sursă> <destinație>"
    exit 1
fi

SOURCE="$1"
DEST="$2"
```

### 4.2 Argumente cu Valori Implicite

```bash
#!/bin/bash

# Folosește argumentul sau valoarea implicită
INPUT="${1:-input.txt}"
OUTPUT="${2:-output.txt}"
COUNT="${3:-10}"

echo "Input: $INPUT"
echo "Output: $OUTPUT"
echo "Count: $COUNT"
```

### 4.3 Procesare Opțiuni Lungi (manual)

```bash
#!/bin/bash

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            echo "Ajutor..."
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
            echo "Opțiune necunoscută: $1"
            exit 1
            ;;
        *)
            break
            ;;
    esac
done
```

---

## 5. Exerciții Practice

### Exercițiul 1: Script cu Parametri

```bash
#!/bin/bash
# salut.sh - salută utilizatorii

if [ $# -eq 0 ]; then
    echo "Utilizare: $0 nume1 [nume2] [nume3] ..."
    exit 1
fi

for nume in "$@"; do
    echo "Salut, $nume!"
done
```

### Exercițiul 2: Calculator Simplu

```bash
#!/bin/bash
# calc.sh num1 operator num2

if [ $# -ne 3 ]; then
    echo "Utilizare: $0 num1 [+|-|*|/] num2"
    exit 1
fi

case $2 in
    +) echo "$1 + $3 = $((${1} + ${3}))" ;;
    -) echo "$1 - $3 = $((${1} - ${3}))" ;;
    \*) echo "$1 * $3 = $((${1} * ${3}))" ;;
    /) echo "$1 / $3 = $((${1} / ${3}))" ;;
    *) echo "Operator necunoscut: $2" ;;
esac
```

### Exercițiul 3: Backup cu Opțiuni

```bash
#!/bin/bash
# backup.sh -s sursa -d dest [-v] [-c]

VERBOSE=false
COMPRESS=false

while getopts "s:d:vc" opt; do
    case $opt in
        s) SOURCE="$OPTARG" ;;
        d) DEST="$OPTARG" ;;
        v) VERBOSE=true ;;
        c) COMPRESS=true ;;
    esac
done

if [ -z "$SOURCE" ] || [ -z "$DEST" ]; then
    echo "Utilizare: $0 -s sursa -d dest [-v] [-c]"
    exit 1
fi

$VERBOSE && echo "Copiez $SOURCE -> $DEST"

if $COMPRESS; then
    tar czf "$DEST.tar.gz" "$SOURCE"
else
    cp -r "$SOURCE" "$DEST"
fi
```

---

## Cheat Sheet

```bash
# PARAMETRI POZIȚIONALI
$0        # numele scriptului
$1-$9     # parametrii 1-9
${10}     # parametrul 10+
$#        # număr parametri
$@        # toți (ca listă)
$*        # toți (ca string)

# SHIFT
shift     # elimină $1
shift N   # elimină primii N

# GETOPTS
getopts "ab:c:" opt    # a,c fără arg, b cu arg
$OPTARG               # valoarea argumentului
$OPTIND               # indexul curent
shift $((OPTIND-1))   # sari peste opțiuni

# VALORI IMPLICITE
${VAR:-default}       # folosește default
${1:-implicit}        # argument cu default

# VERIFICĂRI
[ $# -eq 0 ]          # fără argumente
[ $# -lt 2 ]          # mai puțin de 2
[ -z "$1" ]           # argument gol
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
