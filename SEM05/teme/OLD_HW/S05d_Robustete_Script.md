# S05_TC03 - Robustețe în Scripturi Bash

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
- Folosească `set -euo pipefail` pentru scripturi sigure
- Configure IFS pentru procesare sigură
- Implementeze verificări defensive
- Scrie cod care gestionează cazurile limită

---


## 2. IFS (Internal Field Separator)

### 2.1 Problema

```bash
# IFS default include spațiu
text="one two three"
for word in $text; do
    echo "$word"
done
# Output: one, two, three (separat)
```

### 2.2 IFS Sigur

```bash
#!/bin/bash
IFS=$'\n\t'  # Doar newline și tab ca separatori

# Acum spațiile NU mai separă
text="one two three"
for word in $text; do
    echo "$word"
done
# Output: "one two three" (ca un singur element)
```

### 2.3 IFS Temporar

```bash
# Salvare și restaurare
OLD_IFS="$IFS"
IFS=','
# ... operații
IFS="$OLD_IFS"

# Sau cu subshell
(IFS=','; read -ra arr <<< "a,b,c"; echo "${arr[@]}")
```

---

## 3. Verificări Defensive

### 3.1 Verificare Argumente

```bash
#!/bin/bash
set -euo pipefail

# Verificare număr argumente
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <filename>" >&2
    exit 1
fi

# Alternativ cu pattern
[[ $# -ge 1 ]] || { echo "Usage: $0 <filename>" >&2; exit 1; }

# Cu mesaj în variabilă
FILENAME="${1:?Error: filename required}"
```

### 3.2 Verificare Fișiere

```bash
#!/bin/bash
set -euo pipefail

FILE="$1"

# Existență
[[ -e "$FILE" ]] || { echo "Error: $FILE doesn't exist" >&2; exit 1; }

# Este fișier (nu director)
[[ -f "$FILE" ]] || { echo "Error: $FILE is not a file" >&2; exit 1; }

# Readable
[[ -r "$FILE" ]] || { echo "Error: Cannot read $FILE" >&2; exit 1; }

# Writable
[[ -w "$FILE" ]] || { echo "Error: Cannot write to $FILE" >&2; exit 1; }

# Non-empty
[[ -s "$FILE" ]] || { echo "Warning: $FILE is empty" >&2; }
```

### 3.3 Verificare Directoare

```bash
#!/bin/bash
set -euo pipefail

DIR="${1:?Error: directory required}"

# Existență și tip
[[ -d "$DIR" ]] || { echo "Error: $DIR is not a directory" >&2; exit 1; }

# Creare dacă nu există
mkdir -p "$DIR"

# Cu verificare
if ! mkdir -p "$DIR" 2>/dev/null; then
    echo "Error: Cannot create $DIR" >&2
    exit 1
fi
```

### 3.4 Verificare Comenzi

```bash
#!/bin/bash
set -euo pipefail

# Verifică dacă comanda există
command -v jq >/dev/null 2>&1 || { 
    echo "Error: jq is required but not installed" >&2
    exit 1
}

# Alternativ
if ! type -P docker &>/dev/null; then
    echo "Error: docker not found" >&2
    exit 1
fi

# Verificare multiple comenzi
for cmd in git curl jq; do
    command -v "$cmd" >/dev/null 2>&1 || {
        echo "Error: $cmd is required" >&2
        exit 1
    }
done
```

---

## 4. Pattern-uri Defensive

### 4.1 Funcția `die`

```bash
#!/bin/bash
set -euo pipefail

die() {
    echo "FATAL: $*" >&2
    exit 1
}

# Utilizare
[[ -f config.txt ]] || die "config.txt not found"
[[ -n "$API_KEY" ]] || die "API_KEY not set"
```

### 4.2 Validare Input

```bash
#!/bin/bash
set -euo pipefail

validate_port() {
    local port="$1"
    [[ "$port" =~ ^[0-9]+$ ]] || die "Port must be numeric: $port"
    (( port >= 1 && port <= 65535 )) || die "Port out of range: $port"
}

validate_email() {
    local email="$1"
    [[ "$email" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]] || \
        die "Invalid email: $email"
}

validate_port "$PORT"
validate_email "$EMAIL"
```

### 4.3 Safe Defaults

```bash
#!/bin/bash
set -euo pipefail

# Variabile cu default
CONFIG_FILE="${CONFIG_FILE:-/etc/app/config.conf}"
LOG_LEVEL="${LOG_LEVEL:-INFO}"
MAX_RETRIES="${MAX_RETRIES:-3}"
TIMEOUT="${TIMEOUT:-30}"

# Variabile obligatorii (fail if not set)
DB_HOST="${DB_HOST:?Error: DB_HOST must be set}"
DB_PASSWORD="${DB_PASSWORD:?Error: DB_PASSWORD must be set}"
```

### 4.4 Quoting Corect

```bash
#!/bin/bash
set -euo pipefail

# ÎNTOTDEAUNA quote variabilele
file="my file with spaces.txt"

# GREȘIT
rm $file        # Încearcă să șteargă "my", "file", "with", "spaces.txt"

# CORECT
rm "$file"      # Șterge "my file with spaces.txt"

# Arrays - folosește @
files=("file 1.txt" "file 2.txt")

# GREȘIT
for f in ${files[*]}; do echo "$f"; done

# CORECT
for f in "${files[@]}"; do echo "$f"; done
```

---

## 5. Dezactivare Temporară

### 5.1 Pentru o Comandă

```bash
#!/bin/bash
set -euo pipefail

# Comandă care poate eșua
set +e
result=$(might_fail 2>&1)
status=$?
set -e

if [[ $status -ne 0 ]]; then
    echo "Command failed: $result"
fi

# Alternativ cu ||
might_fail || true
might_fail || echo "Failed but continuing"
```

### 5.2 Pentru Variabile Nedefinite

```bash
#!/bin/bash
set -euo pipefail

# Verificare variabilă opțională
if [[ -n "${OPTIONAL_VAR:-}" ]]; then
    echo "OPTIONAL_VAR is set to: $OPTIONAL_VAR"
fi

# Sau
set +u
if [[ -n "$OPTIONAL_VAR" ]]; then
    # ...
fi
set -u
```

---

## 6. Exerciții

### Exercițiul 1
Scrieți un script care validează că toate dependențele (curl, jq, git) sunt instalate.

### Exercițiul 2
Creați un script care primește un path ca argument și verifică că e un fișier citibil și non-gol.

### Exercițiul 3
Implementați un script cu variabile obligatorii ($DB_HOST) și opționale ($LOG_LEVEL cu default).

---

## Cheat Sheet

```bash
# OPȚIUNI STANDARD
set -euo pipefail
IFS=$'\n\t'

# VERIFICĂRI FIȘIERE
[[ -e "$f" ]]     # există
[[ -f "$f" ]]     # e fișier
[[ -d "$f" ]]     # e director
[[ -r "$f" ]]     # readable
[[ -w "$f" ]]     # writable
[[ -s "$f" ]]     # non-empty

# VERIFICĂRI COMENZI
command -v cmd >/dev/null 2>&1

# VARIABILE CU DEFAULT
"${VAR:-default}"           # default dacă VAR e gol/nedefinit
"${VAR:?Error message}"     # eroare dacă VAR e gol/nedefinit

# DEZACTIVARE TEMPORARĂ
set +e; cmd; status=$?; set -e
cmd || true

# DIE PATTERN
die() { echo "FATAL: $*" >&2; exit 1; }
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
