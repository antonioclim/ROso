# S05_TC04 - Trap și Error Handling

> **Sisteme de Operare** | ASE București - CSIE  
> Material de laborator - Seminar 5 (SPLIT din TC6b)

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
- Folosească `trap` pentru gestionarea semnalelor
- Implementeze cleanup automat la ieșire
- Creeze error handlers profesioniști
- Gestioneze întreruperi graceful

---


## 2. Trap EXIT - Cleanup Automat

### 2.1 Pattern de Bază

```bash
#!/bin/bash
set -euo pipefail

# Creează resurse temporare
TEMP_FILE=$(mktemp)
TEMP_DIR=$(mktemp -d)

# Funcția de cleanup
cleanup() {
    echo "Cleaning up..."
    rm -f "$TEMP_FILE"
    rm -rf "$TEMP_DIR"
}

# Setează trap pentru EXIT
trap cleanup EXIT

# Restul scriptului
echo "Working with $TEMP_FILE"
echo "Working with $TEMP_DIR"

# cleanup() se execută AUTOMAT la ieșire
# - fie la final normal
# - fie la eroare (cu set -e)
# - fie la Ctrl+C (INT)
```

### 2.2 Cleanup cu Exit Code Preservat

```bash
#!/bin/bash
set -euo pipefail

TEMP_FILE=$(mktemp)

cleanup() {
    local exit_code=$?  # Salvează exit code-ul ORIGINAL
    rm -f "$TEMP_FILE"
    exit $exit_code     # Ieși cu codul original
}

trap cleanup EXIT

# Script...
```

### 2.3 Cleanup Condițional

```bash
#!/bin/bash
set -euo pipefail

TEMP_FILE=""
KEEP_TEMP=false

cleanup() {
    if [[ "$KEEP_TEMP" == false && -n "$TEMP_FILE" ]]; then
        rm -f "$TEMP_FILE"
    fi
}

trap cleanup EXIT

TEMP_FILE=$(mktemp)
# ...

if [[ "$DEBUG" == true ]]; then
    KEEP_TEMP=true
    echo "Temp file kept: $TEMP_FILE"
fi
```

---

## 3. Trap ERR - Error Handler

### 3.1 Handler pentru Erori

```bash
#!/bin/bash
set -euo pipefail

error_handler() {
    local line=$1
    local cmd=$2
    local code=$3
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
    echo "ERROR in script at line $line" >&2
    echo "Command: $cmd" >&2
    echo "Exit code: $code" >&2
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
}

trap 'error_handler $LINENO "$BASH_COMMAND" $?' ERR

# Test
echo "Before error"
false  # Declanșează error_handler
echo "After error"  # Nu se execută
```

### 3.2 Handler cu Stack Trace

```bash
#!/bin/bash
set -euo pipefail

error_handler() {
    local exit_code=$?
    
    echo "━━━━━━━━━━━ ERROR ━━━━━━━━━━━" >&2
    echo "Exit code: $exit_code" >&2
    echo "Command: $BASH_COMMAND" >&2
    echo "" >&2
    echo "Stack trace:" >&2
    
    local i=0
    while caller $i; do
        ((i++))
    done | while read line func file; do
        echo "  $file:$line in $func()" >&2
    done
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
}

trap error_handler ERR
```

---

## 4. Trap INT/TERM - Întreruperi

### 4.1 Gestionare Ctrl+C

```bash
#!/bin/bash
set -euo pipefail

interrupted=false

handle_interrupt() {
    interrupted=true
    echo ""
    echo "Interrupt received, finishing current task..."
}

trap handle_interrupt INT

for i in {1..100}; do
    if [[ "$interrupted" == true ]]; then
        echo "Exiting gracefully at iteration $i"
        break
    fi
    
    echo "Processing $i..."
    sleep 1
done

echo "Cleanup complete"
```

### 4.2 Ignorare Semnale Temporar

```bash
#!/bin/bash
set -euo pipefail

# Secțiune critică - ignoră întreruperi
trap '' INT TERM

echo "Critical section - cannot be interrupted"
# ... operații critice
sleep 5

# Restaurează comportament normal
trap - INT TERM

echo "Normal section - can be interrupted"
sleep 5
```

### 4.3 Exit Codes pentru Semnale

```bash
#!/bin/bash

cleanup() {
    echo "Cleanup..."
}

trap 'cleanup; exit 130' INT   # 128 + 2 (SIGINT)
trap 'cleanup; exit 143' TERM  # 128 + 15 (SIGTERM)
trap cleanup EXIT

# Script...
```

---

## 5. Pattern-uri Avansate

### 5.1 Trap Complet (Best Practice)

```bash
#!/bin/bash
set -euo pipefail

# Variabile globale pentru resurse
TEMP_FILES=()
LOCK_FILE=""
PID_FILE=""

# Cleanup function
cleanup() {
    local exit_code=$?
    
    # Cleanup temp files
    for f in "${TEMP_FILES[@]:-}"; do
        [[ -f "$f" ]] && rm -f "$f"
    done
    
    # Remove lock file
    [[ -f "$LOCK_FILE" ]] && rm -f "$LOCK_FILE"
    
    # Remove PID file
    [[ -f "$PID_FILE" ]] && rm -f "$PID_FILE"
    
    exit $exit_code
}

# Error handler
on_error() {
    echo "[ERROR] Line $1: Command '$2' failed with exit code $3" >&2
}

# Interrupt handler
on_interrupt() {
    echo "" >&2
    echo "[WARN] Script interrupted" >&2
    exit 130
}

# Setup traps
trap cleanup EXIT
trap 'on_error $LINENO "$BASH_COMMAND" $?' ERR
trap on_interrupt INT TERM

# Helper pentru temp files
create_temp() {
    local f
    f=$(mktemp)
    TEMP_FILES+=("$f")
    echo "$f"
}

# Script principal
main() {
    local temp1
    temp1=$(create_temp)
    
    echo "Working..."
    # ...
}

main "$@"
```

### 5.2 Lock File cu Trap

```bash
#!/bin/bash
set -euo pipefail

LOCK_FILE="/var/run/myscript.lock"

acquire_lock() {
    if [[ -f "$LOCK_FILE" ]]; then
        local pid
        pid=$(cat "$LOCK_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            echo "Error: Script already running (PID $pid)" >&2
            exit 1
        fi
        echo "Warning: Stale lock file, removing..."
        rm -f "$LOCK_FILE"
    fi
    
    echo $$ > "$LOCK_FILE"
}

release_lock() {
    rm -f "$LOCK_FILE"
}

trap release_lock EXIT

acquire_lock

# Script...
echo "Running with PID $$"
sleep 30
```

### 5.3 Nested Traps

```bash
#!/bin/bash
set -euo pipefail

# Lista de cleanup handlers
declare -a CLEANUP_HANDLERS=()

# Adaugă handler
add_cleanup() {
    CLEANUP_HANDLERS+=("$1")
}

# Execută toate handlers (în ordine inversă)
run_cleanup() {
    local i
    for ((i=${#CLEANUP_HANDLERS[@]}-1; i>=0; i--)); do
        eval "${CLEANUP_HANDLERS[$i]}"
    done
}

trap run_cleanup EXIT

# Utilizare
TEMP1=$(mktemp)
add_cleanup "rm -f '$TEMP1'"

TEMP2=$(mktemp)
add_cleanup "rm -f '$TEMP2'"

# Handlers se execută în ordine inversă la EXIT
```

---

## 6. Debug și Troubleshooting

### 6.1 Debug Mode cu Trap

```bash
#!/bin/bash
set -euo pipefail

DEBUG="${DEBUG:-false}"

if [[ "$DEBUG" == true ]]; then
    # Afișează fiecare comandă înainte de execuție
    trap 'echo "+ $BASH_COMMAND" >&2' DEBUG
fi

# Script...
```

### 6.2 Timing cu Trap

```bash
#!/bin/bash
set -euo pipefail

START_TIME=$(date +%s)

show_duration() {
    local end_time
    end_time=$(date +%s)
    local duration=$((end_time - START_TIME))
    echo "Script completed in ${duration}s"
}

trap show_duration EXIT

# Script...
```

---

## 7. Exerciții

### Exercițiul 1
Scrieți un script care creează 3 fișiere temporare și le șterge automat la ieșire.

### Exercițiul 2
Implementați un error handler care afișează linia și comanda care a cauzat eroarea.

### Exercițiul 3
Creați un script cu lock file care previne rularea multiplă simultană.

---

## Cheat Sheet

```bash
# TRAP SYNTAX
trap 'commands' SIGNAL

# SEMNALE COMUNE
EXIT          # Orice ieșire
ERR           # Eroare (cu set -e)
INT           # Ctrl+C
TERM          # kill
DEBUG         # Înainte de fiecare comandă

# PATTERN CLEANUP
trap cleanup EXIT

cleanup() {
    local exit_code=$?
    rm -f "$TEMP_FILE"
    exit $exit_code
}

# PATTERN ERROR
trap 'error_handler $LINENO "$BASH_COMMAND" $?' ERR

# PATTERN INTERRUPT
trap 'echo "Interrupted"; exit 130' INT TERM

# IGNORARE SEMNAL
trap '' INT       # Ignoră
trap - INT        # Restaurează default

# VARIABILE UTILE
$LINENO           # Linia curentă
$BASH_COMMAND     # Comanda curentă
$?                # Exit code
$$                # PID script
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
