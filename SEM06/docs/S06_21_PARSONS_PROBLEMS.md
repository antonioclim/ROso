# Parsons Problems — CAPSTONE SEM06

> **Sisteme de Operare** | ASE București - CSIE  
> Seminar 6: Proiecte Integrate (Monitor, Backup, Deployer)

---

## Despre Parsons Problems

Parsons Problems sunt exerciții în care studenții aranjează linii de cod amestecate pentru a forma un program corect. Această abordare:

- Reduce sarcina cognitivă (nu trebuie să memorezi sintaxa)
- Focusează pe înțelegerea logicii și structurii
- Include **distractori** — linii greșite ce testează misconceptii
- Eficiență dovedită pentru începători (Parsons & Haden, 2006)

### Instrucțiuni pentru Studenți

1. Citește cu atenție cerința
2. Identifică liniile corecte (unele sunt distractori!)
3. Aranjează liniile în ordinea corectă
4. Verifică indentarea (dacă e cazul)

---

## PP-01: Trap Handler pentru Cleanup

### Cerință

Scrie un script care creează un fișier temporar, îl folosește, apoi îl șterge automat la terminare (inclusiv Ctrl+C).

### Linii Amestecate

```
A)  rm -f "$TEMP_FILE"
B)  TEMP_FILE=$(mktemp)
C)  trap cleanup EXIT INT
D)  #!/bin/bash
E)  cleanup() {
F)  echo "Date procesate: $(cat "$TEMP_FILE")"
G)  echo "test data" > "$TEMP_FILE"
H)  }
```

### Distractori (Linii Greșite)

```
X1) trap 'cleanup' ON_EXIT          # ON_EXIT nu există, corect e EXIT
X2) TEMP_FILE = $(mktemp)           # Spații în jurul = cauzează eroare
X3) trap cleanup() EXIT             # Parantezele după cleanup sunt greșite
X4) rm "$TEMP_FILE" -f              # Ordinea argumentelor e nestandard
```

### Soluție Corectă

```bash
#!/bin/bash

cleanup() {
    rm -f "$TEMP_FILE"
}

trap cleanup EXIT INT

TEMP_FILE=$(mktemp)
echo "test data" > "$TEMP_FILE"
echo "Date procesate: $(cat "$TEMP_FILE")"
```

**Ordinea:** D → E → A → H → C → B → G → F

**Concepte testate:**
- Definirea funcției înainte de utilizare
- Sintaxa trap fără paranteze
- Atribuire fără spații

---

## PP-02: Backup Incremental cu find -newer

### Cerință

Creează un script care face backup incremental — copiază doar fișierele modificate după ultimul backup.

### Linii Amestecate

```
A)  find "$SOURCE" -newer "$TIMESTAMP_FILE" -type f -print0 | \
B)  tar czf "$BACKUP_FILE" -T -
C)  touch "$TIMESTAMP_FILE"
D)  #!/bin/bash
E)  TIMESTAMP_FILE="/var/backup/.last_backup"
F)  SOURCE="/home/user/documents"
G)  BACKUP_FILE="/var/backup/incremental_$(date +%Y%m%d).tar.gz"
H)  xargs -0 tar czf "$BACKUP_FILE"
```

### Distractori (Linii Greșite)

```
X1) find "$SOURCE" --newer "$TIMESTAMP_FILE"   # --newer nu există, e -newer
X2) find $SOURCE -newer $TIMESTAMP_FILE        # Lipsesc ghilimelele (spații!)
X3) tar czf $BACKUP_FILE < $(find ...)         # Sintaxă incorectă pentru input
X4) BACKUP_FILE = "..."                        # Spații la atribuire
```

### Soluție Corectă

```bash
#!/bin/bash

TIMESTAMP_FILE="/var/backup/.last_backup"
SOURCE="/home/user/documents"
BACKUP_FILE="/var/backup/incremental_$(date +%Y%m%d).tar.gz"

find "$SOURCE" -newer "$TIMESTAMP_FILE" -type f -print0 | \
    xargs -0 tar czf "$BACKUP_FILE"

touch "$TIMESTAMP_FILE"
```

**Ordinea:** D → E → F → G → A → H → C

**Concepte testate:**
- Sintaxa find cu -newer
- Pattern -print0 | xargs -0 pentru fișiere cu spații
- Actualizarea timestamp după backup

---

## PP-03: Health Check cu Retry

### Cerință

Scrie o funcție care verifică dacă un server web răspunde, cu retry și backoff.

### Linii Amestecate

```
A)  ((retry++))
B)  return 1
C)  check_health() {
D)  if curl -sf "$URL" > /dev/null; then
E)  local retry=0
F)  while [[ $retry -lt $MAX_RETRIES ]]; do
G)  sleep $((2 ** retry))
H)  return 0
I)  fi
J)  done
K)  }
L)  local MAX_RETRIES=3
M)  local URL="http://localhost:8080/health"
```

### Distractori (Linii Greșite)

```
X1) if curl -sf $URL; then              # Lipsesc ghilimelele
X2) while [ $retry < $MAX_RETRIES ]     # < nu funcționează în [ ], e -lt
X3) retry = $((retry + 1))              # Spații la atribuire
X4) sleep 2 * retry                     # Sintaxă incorectă pentru multiplicare
```

### Soluție Corectă

```bash
check_health() {
    local MAX_RETRIES=3
    local URL="http://localhost:8080/health"
    local retry=0
    
    while [[ $retry -lt $MAX_RETRIES ]]; do
        if curl -sf "$URL" > /dev/null; then
            return 0
        fi
        ((retry++))
        sleep $((2 ** retry))
    done
    return 1
}
```

**Ordinea:** C → L → M → E → F → D → H → I → A → G → J → B → K

**Concepte testate:**
- Declarare variabile locale în funcții
- `[[ ]]` cu `-lt` pentru comparație numerică
- Exponential backoff: `$((2 ** retry))`

---

## PP-04: Source Libraries în Ordine

### Cerință

Scrie secțiunea de încărcare biblioteci pentru un script modular. Core trebuie încărcat primul.

### Linii Amestecate

```
A)  source "$LIB_DIR/utils.sh"
B)  source "$LIB_DIR/core.sh"
C)  for lib in "$LIB_DIR"/*.sh; do
D)  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
E)  LIB_DIR="$SCRIPT_DIR/lib"
F)  done
G)  #!/bin/bash
H)  source "$lib"
I)  source "$LIB_DIR/config.sh"
```

### Distractori (Linii Greșite)

```
X1) SCRIPT_DIR=$(dirname $0)            # Nu rezolvă symlinks, $0 fără ghilimele
X2) source $LIB_DIR/core.sh             # Lipsesc ghilimelele
X3) . "$LIB_DIR"/core.sh                # Ghilimelele sunt în loc greșit
X4) for lib in $LIB_DIR/*.sh; do        # Lipsesc ghilimelele (glob poate fi ok dar risky)
```

### Soluție Corectă

```bash
#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"

# Core trebuie încărcat primul (definește funcții de bază)
source "$LIB_DIR/core.sh"
source "$LIB_DIR/config.sh"
source "$LIB_DIR/utils.sh"
```

**Ordinea:** G → D → E → B → I → A

**Varianta cu loop (mai flexibilă dar fără ordine garantată):**
```bash
for lib in "$LIB_DIR"/*.sh; do
    source "$lib"
done
```

**Concepte testate:**
- `BASH_SOURCE[0]` vs `$0` pentru a găsi locația scriptului
- Ordinea de încărcare a dependențelor
- Ghilimele la source

---

## PP-05: Logging Function

### Cerință

Implementează o funcție de logging cu timestamp și nivel (INFO, WARN, ERROR).

### Linii Amestecate

```
A)  local level="$1"
B)  local message="$2"
C)  log() {
D)  local timestamp
E)  timestamp=$(date '+%Y-%m-%d %H:%M:%S')
F)  echo "[$timestamp] [$level] $message"
G)  }
H)  echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
```

### Distractori (Linii Greșite)

```
X1) local level = "$1"                  # Spații la atribuire
X2) timestamp=`date '+%Y-%m-%d %H:%M:%S'`  # Backticks (funcționează dar deprecated)
X3) echo [$timestamp] [$level] $message # Lipsesc ghilimelele, parantezele drepte se expandează
X4) log() (                             # Paranteze rotunde creează subshell
```

### Soluție Corectă

```bash
log() {
    local level="$1"
    local message="$2"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message"
}

# Utilizare
log "INFO" "Script started"
log "ERROR" "Connection failed"
```

**Ordinea:** C → A → B → D → E → F → G

**Concepte testate:**
- Parametri poziționali `$1`, `$2`
- Variabile locale în funcții
- Command substitution cu `$()`

---

## PP-06: Array și Iterare

### Cerință

Iterează peste un array de servere și verifică fiecare.

### Linii Amestecate

```
A)  for server in "${SERVERS[@]}"; do
B)  done
C)  SERVERS=("web01" "web02" "db01")
D)  check_server "$server"
E)  echo "Verificare: $server"
F)  #!/bin/bash
```

### Distractori (Linii Greșite)

```
X1) for server in $SERVERS; do          # Fără [@], ia doar primul element
X2) for server in ${SERVERS[@]}; do     # Fără ghilimele, spațiile sparg
X3) SERVERS = ("web01" "web02")         # Spații la atribuire array
X4) for server in SERVERS[@]; do        # Lipsește $ și {}
```

### Soluție Corectă

```bash
#!/bin/bash

SERVERS=("web01" "web02" "db01")

for server in "${SERVERS[@]}"; do
    echo "Verificare: $server"
    check_server "$server"
done
```

**Ordinea:** F → C → A → E → D → B

**Concepte testate:**
- Sintaxa array `(elem1 elem2 elem3)`
- Iterare cu `"${ARRAY[@]}"` (ghilimele importante!)
- Word splitting la arrays

---

## Sumar Concepte Testate

| Problem | Concepte Principale | Misconceptii Adresate |
|---------|---------------------|----------------------|
| PP-01 | trap, cleanup, funcții | spații la `=`, sintaxă trap |
| PP-02 | find -newer, xargs -0 | --newer vs -newer, ghilimele |
| PP-03 | while, curl, backoff | `< ` vs `-lt`, spații |
| PP-04 | source, BASH_SOURCE | $0 vs BASH_SOURCE |
| PP-05 | funcții, local, date | backticks vs $() |
| PP-06 | arrays, iterare | ${ARR[@]} vs "${ARR[@]}" |

---

## Utilizare în Seminar

1. **Individual (5-7 min):** Studenții rezolvă pe hârtie sau online
2. **Pair check (3 min):** Verifică cu colegul de bancă
3. **Discuție clasă (5 min):** Analizează distractorii și de ce sunt greșiți
4. **Live coding (5 min):** Demonstrează soluția și variante

### Platforme Recomandate

- **js-parsons:** http://js-parsons.github.io/
- **Runestone Interactive:** https://runestone.academy/
- **Manual:** pe hârtie/whiteboard

---

## Resurse

- Parsons, D., & Haden, P. (2006). *Parson's programming puzzles*
- Ericson, B. J. (2017). *Parsons Problems for Learning*
- Brown & Wilson (2018). *Ten Quick Tips for Teaching Programming*

---

*Document generat pentru SEM06 CAPSTONE — Sisteme de Operare*  
*ASE București - CSIE | 2024-2025*
