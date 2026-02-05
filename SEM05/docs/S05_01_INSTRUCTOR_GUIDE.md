# Ghid Instructor: Seminarul 9-10
## Sisteme de Operare | Advanced Bash Scripting

> Observație din laborator: notează-ți comenzi‑cheie și output‑ul relevant (2–3 linii) pe măsură ce lucrezi. Te ajută la debug și, sincer, la final îți iese și un README bun fără efort suplimentar.
> Document: Ghid complet pas-cu-pas pentru instructor  
> Durată totală: 100 minute (2 × 50 min + pauză)  
> Tip seminar: Advanced Scripting - Best Practices  
> Nivel: Avansat (presupune SEM01-08 completate)

---

## OBIECTIVE SESIUNE

La finalul acestui seminar, studenții vor fi capabili să:

1. Creeze funcții cu variabile locale și multiple mecanisme de return values
2. Lucreze cu arrays indexate și asociative corect (cu ghilimele și declare -A)
3. Implementeze error handling solid cu set -euo pipefail și trap
4. Creeze sisteme de logging cu nivele și output configurable
5. Folosească template-ul profesional ca bază pentru orice script nou

---

## ATENȚIONĂRI SPECIALE - CITEȘTE ÎNAINTE!

### Importanța Template-ului Profesional

> CRITIC: Template-ul profesional este ESENȚA acestui seminar!

- ÎNCEPE demonstrațiile cu template-ul, NU cu concepte izolate
- Arată DE CE fiecare secțiune există
- Studenții vor COPIA acest template pentru TOATE scripturile viitoare
- Dacă nu rețin altceva, trebuie să rețină template-ul

### Pitfall-uri Comune de Evitat

| Pitfall | Ce să faci |
|---------|------------|
| Variabile globale vs locale | DEMONSTREAZĂ cu exemplu concret - nu doar spune |
| `declare -A` pentru hash | Repetă de 3 ori în contexte diferite - e OBLIGATORIU |
| `set -e` magic thinking | Arată cazurile când NU funcționează |
| trap în subshells | Demonstrează că NU se moștenește |
| `${arr[@]}` fără ghilimele | Arată word splitting în acțiune |

### Erori Deliberate de Introdus

În live coding, introduce INTENȚIONAT aceste erori și repară-le:
1. Uită `local` și arată poluarea globală
2. Uită `declare -A` și arată comportamentul incorect
3. Uită ghilimelele la array iteration
4. Arată script care "funcționează" dar eșuează silențios

---

## POVESTIRI DIN „TRANȘEE”

> *Incidente reale observate în predarea acestui material. Împărtășiți-le cu studenții — rețin mai bine poveștile decât regulile.*

### Sesiunea de depanare de la miezul nopții (decembrie 2023)

În sesiunea de restanțe, un student a petrecut 3 ore depanând un script care „eșua misterios”. Simptomele: scriptul funcționa când era rulat manual, dar eșua în `cron`. Cauza? Un singur set de ghilimele lipsă în jurul `${array[@]}`, combinat cu nume de fișiere care conțineau spații (care existau doar în setul de date „de producție”, nu și în datele lor de test).

**Lecția pe care o subliniez acum:** „Datele tale de test sunt aproape întotdeauna mai curate decât realitatea. Pune ghilimele peste tot, chiar și atunci când «pare» să meargă fără ghilimele.”

### Dezastrul `declare -A` (semestrul 2, 2023–2024)

Am urmărit un student depanând 45 de minute de ce „array-ul asociativ” producea chei numerice. Scrisese:

```bash
config[name]="test"    # Missing declare -A above!
echo "${!config[@]}"   # Output: 0 (not "name"!)
```

Fără `declare -A`, Bash tratează structura ca array indexat și interpretează `name` drept expresie aritmetică (care evaluează la 0).

**Ce fac acum invariabil:** desenez acest lucru pe tablă cu marker roșu. De trei ori. În contexte diferite.

### Încrederea falsă în `set -e` (recurent)

În fiecare semestru, cel puțin un student predă cod de tipul:

```bash
set -e
if grep -q "pattern" file.txt; then
    echo "Found"
fi
echo "Script continues"  # They expect this to NOT run if grep fails
```

Apoi este surprins când scriptul continuă. Capcana: `set -e` nu întrerupe execuția în anumite contexte, iar `if` este unul dintre ele.

**Răspunsul meu:** am creat `S05_04_demo_robust.sh` special pentru a demonstra toate cazurile în care `set -e` NU funcționează. Durează 15 minute, dar economisește ore de confuzie.

### Tipare pe care le-am observat la studenții români

După mai mulți ani de predare a acestui curs, am observat:

1. **Denumirea variabilelor:** studenții folosesc instinctiv `numar`, `lista`, `rezultat` — lucru care ajută, de fapt, la identificarea lucrărilor autentice în detectarea utilizării AI (modelele tind să „default”-eze pe engleză)

2. **Mesaje de eroare:** scriu „Eroare: fișierul nu există”, apoi își amintesc să traducă — uneori rămân comentarii în limbaj mixt

3. **Corelația cu cafeaua:** grupa de la 8:00 face cu ~15% mai multe erori la exercițiile cu arrays decât grupa de la 14:00. De aceea programez demo-ul „spectaculos” la început, ca să-i trezesc.

---

## PREGĂTIRE ÎNAINTE DE SEMINAR

### Verificare Bash Version (OBLIGATORIU)

```bash
# Pe mașina de demo
bash --version
# Trebuie >= 4.0 pentru arrays asociative

# Verificare rapidă funcționalitate
declare -A test_hash
test_hash[key]="value"
echo "${test_hash[key]}"  # Trebuie să afișeze "value"
```

### Setup Demo Environment

```bash
# Creează structura de lucru
mkdir -p ~/demo_sem5/{functions,arrays,robust,logs}
cd ~/demo_sem5

# Pregătește fișiere de test
echo "test content" > test.txt
echo -e "line1\nline2\nline3" > lines.txt

# Verifică shellcheck
shellcheck --version || sudo apt install shellcheck
```

### Pregătire Prezentare

```bash
# Deschide prezentarea HTML
firefox ../presentations/S05_01_prezentare.html &

# Deschide cheat sheet
firefox ../presentations/S05_02_cheat_sheet.html &

# Ține template-ul la îndemână
cat ../scripts/templates/professional_script.sh
```

---

## TIMELINE DETALIATĂ - PRIMA PARTE (50 min)

### [0:00-0:05] HOOK: Script Fragil vs solid

Scop: Impact emoțional - arată DRAMATIC diferența

Setup (înainte de seminar):
```bash
mkdir -p /tmp/fragile_demo
echo "precious data" > /tmp/fragile_demo/important.txt
```

Demonstrație în clasă:

```bash
#!/bin/bash
# Script FRAGIL (nu rula pe sistem real!)

cd /tmp/nonexistent_dir    # Ce dacă nu există?
rm -rf *                    # DEZASTRU dacă cd a eșuat!
process_file $1             # Ce dacă $1 e gol?
```

Întreabă clasa: "Ce se întâmplă dacă /tmp/nonexistent_dir nu există?"

Răspuns dramatic: `rm -rf *` se execută în directorul CURENT!

Arată versiunea solidă:

```bash
#!/bin/bash
# Script solid
set -euo pipefail

cd /tmp/some_dir || { echo "ERROR: Cannot cd"; exit 1; }
[[ -n "${1:-}" ]] || { echo "Usage: $0 <file>"; exit 1; }
rm -rf ./*                  # ./* nu șterge tot / dacă cd a eșuat
process_file "$1"
```

Punch line: "Care script rulezi pe serverul de producție la ora 3 dimineața?"

---

### [0:05-0:20] LIVE CODING: Funcții

#### Segment 1: Funcții de bază (5 min)

Fișier: `~/demo_sem5/functions/01_basics.sh`

```bash

*Notă personală: Prefer scripturi Bash pentru automatizări simple și Python când logica devine complexă. E o chestiune de pragmatism.*

#!/bin/bash
set -euo pipefail

# === DEFINIRE FUNCȚIE ===
# Două sintaxe valide (preferăm a doua)
function greet() {
    echo "Hello from function syntax 1"
}

greet_v2() {
    echo "Hello from POSIX syntax (preferred)"
}

# Apel
greet
greet_v2

# === CU ARGUMENTE ===
greet_name() {
    echo "Hello, $1!"
}

greet_name "World"        # Hello, World!
greet_name                # Hello, !  (PROBLEMĂ!)

# === CU VERIFICARE ===
greet_safe() {
    local name="${1:?Error: name required}"
    echo "Hello, $name!"
}

greet_safe                # Eroare explicită!
greet_safe "Student"      # OK: Hello, Student!
```

Puncte de discuție:
- Ce se întâmplă când apelăm `greet_name` fără argument?
- De ce `${1:?Error}` e mai bun decât verificare manuală?

---

#### Segment 2: Variabile Locale și Scope (5 min) CRITIC!

Fișier: `~/demo_sem5/functions/02_scope.sh`

```bash
#!/bin/bash
set -euo pipefail

# DEMONSTRAȚIE CRITICĂ - Scrie pe tablă!
GLOBAL="initial"

bad_function() {
    GLOBAL="modified by bad_function"    # Modifică globala!
    TEMP="created by bad_function"       # Creează o nouă globală!
}

good_function() {
    local GLOBAL="local copy"            # NU afectează globala
    local temp="truly local"
    echo "Inside good: GLOBAL=$GLOBAL"
}

echo "Before: GLOBAL=$GLOBAL"
# Output: Before: GLOBAL=initial

bad_function
echo "After bad: GLOBAL=$GLOBAL"
# Output: After bad: GLOBAL=modified by bad_function
echo "TEMP=$TEMP"
# Output: TEMP=created by bad_function

good_function
# Output: Inside good: GLOBAL=local copy
echo "After good: GLOBAL=$GLOBAL"
# Output: After good: GLOBAL=modified by bad_function (de la bad!)
```

PREDICȚIE (cere studenților să prezică înainte de rulare):
- Ce va afișa `GLOBAL` după `bad_function`?
- Ce va afișa `GLOBAL` după `good_function`?

Lecție cheie: Variabilele sunt GLOBALE by default! Folosește `local` ÎNTOTDEAUNA în funcții!

---

#### Segment 3: Return Values (5 min)

Fișier: `~/demo_sem5/functions/03_return.sh`

```bash
#!/bin/bash

*(Bash-ul are o sintaxă urâtă, recunosc. Dar rulează peste tot, și asta contează enorm în practică.)*

set -euo pipefail

# === METODA 1: echo (pentru string/output) ===
get_sum() {
    local a=$1 b=$2
    echo $((a + b))
}
result=$(get_sum 5 3)
echo "Sum via echo: $result"    # 8

# === METODA 2: return (doar exit code 0-255!) ===
is_even() {
    local n=$1
    (( n % 2 == 0 ))    # Returnează 0 (true) sau 1 (false)
}

if is_even 4; then
    echo "4 is even"
fi

if ! is_even 7; then
    echo "7 is odd"
fi

# === EROARE DELIBERATĂ: return cu număr mare ===
get_large_number() {
    return 1000    # WRONG! Se trunchiază la 1000 % 256 = 232
}

get_large_number
echo "Exit code: $?"    # 232, NU 1000!

# === METODA 3: Variabilă globală (evită dacă posibil) ===
calculate_and_store() {
    RESULT=$((${1} * ${2}))
}
calculate_and_store 6 7
echo "Stored result: $RESULT"    # 42

# === METODA 4: nameref (Bash 4.3+) ===
store_in() {
    local -n ref=$1    # nameref
    ref="calculated value"
}
declare output
store_in output
echo "Via nameref: $output"
```

Puncte cheie:

- `return` e doar pentru exit code (0-255)
- Pentru string-uri, folosește `echo` și capturează cu `$()`
- `nameref` e elegant dar necesită Bash 4.3+


---

### [0:20-0:25] PEER INSTRUCTION Q1: Variabile Locale

Afișează pe ecran:

```
╔════════════════════════════════════════════════════════════════╗
║  PEER INSTRUCTION Q1: Ce afișează acest cod?                   ║
╠════════════════════════════════════════════════════════════════╣
║                                                                ║
║  X=10                                                          ║
║  func() {                                                      ║
║      local X=20                                                ║
║      echo "Inside: $X"                                         ║
║  }                                                             ║
║  func                                                          ║
║  echo "Outside: $X"                                            ║
║                                                                ║

> 💡 Când am predat prima dată acest concept, jumătate din grupă a făcut exact aceeași greșeală — și e perfect normal.

║  ────────────────────────────────────────────────────────────  ║
║                                                                ║
║  A) Inside: 20, Outside: 20                                    ║
║  B) Inside: 20, Outside: 10                                    ║
║  C) Inside: 10, Outside: 10                                    ║
║  D) Eroare - X nu poate fi redefinită                          ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
```

Protocol:
1. [1 min] Votare individuală (target: 40-60% corect)
2. [3 min] Discuție în perechi
3. [1 min] Revot

Răspuns corect: B

Explicație pentru clasă:
- `local X=20` creează o variabilă LOCALĂ care există doar în funcție
- Variabila globală `X=10` nu este afectată
- După ieșirea din funcție, se vede din nou `X=10`
- `local` face "shadowing", nu modificare

Misconceptii vizate:

- **A**: Cred că `local` modifică globala
- **C**: Cred că `local` nu are efect
- **D**: Cred că variabila nu poate fi redeclarată


---

### [0:25-0:40] LIVE CODING: Arrays

#### Segment 1: Arrays Indexate (7 min)

Fișier: `~/demo_sem5/arrays/01_indexed.sh`

```bash
#!/bin/bash
set -euo pipefail

# === CREARE ===
files=()                              # Array gol
files=("a.txt" "b.txt" "c.txt")       # Cu valori
# Capcană: Fără spații în jurul lui =

# === ACCES ===
echo "First: ${files[0]}"             # a.txt (index 0!)
echo "Last: ${files[-1]}"             # c.txt (Bash 4.3+)
echo "All: ${files[@]}"               # toate elementele
echo "Length: ${#files[@]}"           # 3 (număr elemente)
echo "Indices: ${!files[@]}"          # 0 1 2 (indicii)

# === MODIFICARE ===
files+=("d.txt")                      # Adaugă la final
echo "After append: ${files[@]}"      # a.txt b.txt c.txt d.txt

files[0]="new.txt"                    # Modifică element
echo "After modify: ${files[@]}"

unset files[1]                        # Șterge element (NU array-ul!)
echo "After unset [1]: ${files[@]}"   # new.txt c.txt d.txt
echo "Indices now: ${!files[@]}"      # 0 2 3 (sparse!)

# === ITERARE CORECTĂ ===
echo ""
echo "=== ITERARE CORECTĂ ==="
for f in "${files[@]}"; do            # GHILIMELE OBLIGATORII!
    echo "File: $f"
done

# === ITERARE GREȘITĂ (demonstrează problema) ===
spacey_files=("one two.txt" "three.txt")
echo ""
echo "=== ITERARE GREȘITĂ (fără ghilimele) ==="
for f in ${spacey_files[@]}; do       # GREȘIT!
    echo "File: [$f]"
done
# Output: File: [one], File: [two.txt], File: [three.txt]

echo ""
echo "=== ITERARE CORECTĂ ==="
for f in "${spacey_files[@]}"; do     # CORECT!
    echo "File: [$f]"
done
# Output: File: [one two.txt], File: [three.txt]
```

Puncte cheie:
- Arrays încep de la 0
- `unset arr[i]` face array-ul sparse
- `"${arr[@]}"` păstrează elementele cu spații

---

#### Segment 2: Arrays Asociative (8 min) CRITIC!

Fișier: `~/demo_sem5/arrays/02_associative.sh`

```bash
#!/bin/bash
set -euo pipefail

# === declare -A e OBLIGATORIU! ===
# GREȘIT (fără declare):
# settings[host]="localhost" # NU FACE ASTA!

# CORECT:
declare -A config

# === POPULARE ===
config[host]="localhost"
config[port]="8080"
config[user]="admin"
config[debug]="true"

# === SAU TOT ODATĂ ===
declare -A config2=(
    [host]="localhost"
    [port]="8080"
    [user]="admin"
)

# === ACCES ===
echo "Host: ${config[host]}"
echo "Port: ${config[port]}"
echo ""

# === TOATE VALORILE ===
echo "All values: ${config[@]}"

# === TOATE CHEILE ===
echo "All keys: ${!config[@]}"

# === NUMĂR ELEMENTE ===
echo "Count: ${#config[@]}"
echo ""

# === ITERARE (IMPORTANT!) ===
echo "=== CONFIG DUMP ==="
for key in "${!config[@]}"; do
    echo "  $key = ${config[$key]}"
done

# === VERIFICARE EXISTENȚĂ CHEIE ===
if [[ -v config[host] ]]; then
    echo "Host is set"
fi

if [[ ! -v config[missing] ]]; then
    echo "Missing key is not set"
fi

# === DEFAULT VALUE ===
echo "Database: ${config[database]:-not_configured}"
```

**DEMONSTRAȚIE EROARE** (fără declare -A):

```bash
# Ce se întâmplă fără declare -A?
wrong[name]="John"        # Bash tratează [name] ca pattern!
echo "${wrong[name]}"     # Comportament imprevizibil!
```

Repetă de 3 ori: `declare -A` e OBLIGATORIU pentru hash-uri!

---

### [0:40-0:45] SPRINT #1: Function & Array Challenge

Afișează pe ecran:

```
╔════════════════════════════════════════════════════════════════╗
║  🏃 SPRINT #1: Function & Array Challenge (5 min)              ║
╠════════════════════════════════════════════════════════════════╣
║                                                                ║
║  Scrie o funcție `count_extensions` care:                      ║
║                                                                ║
║  1. Primește un array de nume de fișiere ca argumente          ║
║  2. Numără câte fișiere sunt pentru fiecare extensie           ║
║  3. Afișează rezultatul                                        ║
║                                                                ║
║  Exemplu de utilizare:                                         ║
║  ┌──────────────────────────────────────────────────────────┐  ║
║  │  files=("a.txt" "b.txt" "c.py" "d.txt" "e.py")           │  ║
║  │  count_extensions "${files[@]}"                          │  ║
║  │                                                          │  ║
║  │  # Output:                                               │  ║
║  │  # txt: 3                                                │  ║
║  │  # py: 2                                                 │  ║
║  └──────────────────────────────────────────────────────────┘  ║
║                                                                ║
║  HINT: Folosește array asociativ pentru contorizare!           ║
║                                                                ║
║  ⏱️ TIMP RĂMAS: 5:00                                          ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
```

Soluție (pentru instructor):

```bash
count_extensions() {
    declare -A counts
    for file in "$@"; do
        ext="${file##*.}"
        (( counts[$ext]++ )) || true
    done
    for ext in "${!counts[@]}"; do
        echo "$ext: ${counts[$ext]}"
    done
}
```

---

### [0:45-0:50] PEER INSTRUCTION Q2: Array Iteration

Afișează pe ecran:

```
╔════════════════════════════════════════════════════════════════╗
║  PEER INSTRUCTION Q2: Ce afișează acest cod?                   ║
╠════════════════════════════════════════════════════════════════╣
║                                                                ║
║  arr=("one two" "three")                                       ║
║  for item in ${arr[@]}; do                                     ║
║      echo "[$item]"                                            ║
║  done                                                          ║
║                                                                ║

> 💡 Experiența arată că debugging-ul e 80% citit cu atenție și 20% scris cod nou.

║  ────────────────────────────────────────────────────────────  ║
║                                                                ║
║  A) [one two]  [three]                                         ║
║  B) [one]  [two]  [three]                                      ║
║  C) [one two three]                                            ║
║  D) Eroare de sintaxă                                          ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
```

Răspuns corect: B

Explicație:
- Fără ghilimele, `${arr[@]}` se expandează și apoi se face word splitting
- "one two" devine două cuvinte separate: "one" și "two"
- CORECT: `for item in "${arr[@]}"`

---

## PAUZĂ 10 MINUTE

În pauză, pregătește:
- Demo-urile pentru stabilitate
- Fișierele temporare pentru trap demo

---

## TIMELINE DETALIATĂ - A DOUA PARTE (50 min)

### [0:00-0:05] REACTIVARE: Quiz Rapid

Întrebări rapide (30 sec fiecare):

```
1. Cum faci o variabilă locală în funcție?
   → local var="value"

2. Cum declari un array asociativ?
   → declare -A hashmap

3. Ce returnează `return` în Bash?
   → Un cod numeric 0-255 (NU string!)
```

---

### [0:05-0:20] LIVE CODING: Stabilitate

#### Segment 1: set -euo pipefail (7 min)

Fișier: `~/demo_sem5/robust/01_set_options.sh`

```bash
#!/bin/bash

# === DEMONSTRAȚIE: Fără protecție ===
echo "=== FĂRĂ PROTECȚIE ==="

false                    # Eroare ignorată!
echo "Continuă după false..."

echo "$UNDEFINED"        # String gol, fără eroare!
echo "Continuă după undefined..."

false | true             # Eroare ascunsă în pipe!
echo "Continuă după pipe..."

echo "Script terminat 'cu succes'"
```

Rulează: Script-ul se termină "cu succes" dar are erori!

```bash
#!/bin/bash
# === CU PROTECȚIE ===
set -euo pipefail

echo "=== CU SET -EUO PIPEFAIL ==="

# Decomentează pe rând pentru a vedea efectul:
# false # Script se oprește
# echo "$UNDEFINED" # Script se oprește
# false | true # Script se oprește (pipefail)
```

Explicație detaliată:

| Opțiune | Efect | Exemplu |
|---------|-------|---------|
| `set -e` | Exit la prima eroare | `false` oprește script-ul |
| `set -u` | Eroare la variabile nedefinite | `$UNDEFINED` = eroare |
| `set -o pipefail` | Eroare dacă orice din pipe eșuează | `false \| true` = eroare |

Când NU funcționează set -e:

```bash
# set -e NU funcționează în aceste contexte:
cmd || handle_error      # Intenționat să permită eșec
if cmd; then ...         # Testat explicit
while cmd; do ...        # Condiție de buclă
$(cmd)                   # Command substitution
```

---

#### Segment 2: trap și cleanup (8 min)

Fișier: `~/demo_sem5/robust/02_trap.sh`

```bash
#!/bin/bash
set -euo pipefail

# === CREĂM FIȘIERE TEMPORARE ===
TEMP_FILE=$(mktemp)
TEMP_DIR=$(mktemp -d)
echo "Created: $TEMP_FILE"
echo "Created: $TEMP_DIR"

# === FUNCȚIA DE CLEANUP ===
cleanup() {
    local exit_code=$?
    echo ""
    echo "=== CLEANUP RUNNING ==="
    echo "Exit code was: $exit_code"
    echo "Removing: $TEMP_FILE"
    rm -f "$TEMP_FILE"
    echo "Removing: $TEMP_DIR"
    rm -rf "$TEMP_DIR"
    echo "Cleanup complete!"
    exit $exit_code    # Păstrează exit code-ul original
}

# === SETEAZĂ TRAP ===
# Se execută la EXIT (normal sau eroare)
trap cleanup EXIT

# === SIMULEAZĂ LUCRU ===
echo ""
echo "Working..."
echo "Some content" > "$TEMP_FILE"
touch "$TEMP_DIR/file1.txt"

# Uncomment pentru a simula eroare:
# echo "Simulating error..."
# false

echo "Work complete!"
# Cleanup se execută automat la ieșire!
```

Demonstrație:
1. Rulează normal → cleanup se execută
2. Decommentează `false` → cleanup se execută LA FEL!

Semnale trap:

| Semnal | Declanșator | Utilizare |
|--------|-------------|-----------|
| EXIT | Orice ieșire (normal sau eroare) | Cleanup files |
| ERR | Eroare (cu set -e) | Logging erori |
| INT | Ctrl+C | Cleanup la întrerupere |
| TERM | kill (default) | Shutdown graceful |

---

### [0:20-0:30] LIVE CODING: Logging

Fișier: `~/demo_sem5/logs/logging.sh`

```bash
#!/bin/bash
set -euo pipefail

# === LOGGING SYSTEM ===
LOG_FILE="/tmp/script_$$.log"
declare -A LOG_LEVELS=([DEBUG]=0 [INFO]=1 [WARN]=2 [ERROR]=3)
LOG_LEVEL="${LOG_LEVEL:-INFO}"

log() {
    local level=$1
    shift
    local message="$*"
    
    # Skip dacă sub nivelul curent
    [[ ${LOG_LEVELS[$level]} -lt ${LOG_LEVELS[$LOG_LEVEL]} ]] && return
    
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local caller="${FUNCNAME[1]:-main}"
    local log_line="[$timestamp] [$level] [$caller] $message"
    
    # Scrie în fișier
    echo "$log_line" >> "$LOG_FILE"
    
    # Pe ecran pentru WARN+
    if [[ ${LOG_LEVELS[$level]} -ge ${LOG_LEVELS[WARN]} ]]; then
        echo "$log_line" >&2
    fi
}

# Helper functions
log_debug() { log DEBUG "$@"; }
log_info()  { log INFO "$@"; }
log_warn()  { log WARN "$@"; }
log_error() { log ERROR "$@"; }

# === DEMO ===
echo "Log file: $LOG_FILE"
echo ""

log_info "Script started"
log_debug "This won't show with INFO level"

echo "Changing to DEBUG level..."
LOG_LEVEL=DEBUG

log_debug "Now this shows!"
log_info "Processing data..."
log_warn "This is a warning"
log_error "This is an error"

echo ""
echo "=== LOG FILE CONTENTS ==="
cat "$LOG_FILE"
```

---

### [0:30-0:40] TEMPLATE PROFESIONAL - Walkthrough

Deschide: `scripts/templates/professional_script.sh`

Parcurge FIECARE secțiune și explică DE CE există:

```bash
#!/bin/bash
#
# Script: my_script.sh
# Descriere: Ce face scriptul (completează)
# Autor: Nume (completează)
# Versiune: 1.0.0
# Data: 2025-01-10
#
```
→ `Header`: Documentație pentru cine citește codul

```bash
set -euo pipefail
IFS=$'\n\t'
```
→ `Safety net`: Script-ul se oprește la erori

```bash
readonly SCRIPT_NAME=$(basename "$0")
readonly SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
readonly SCRIPT_VERSION="1.0.0"
```
→ `Constante`: Nu se modifică accidental

```bash
VERBOSE=${VERBOSE:-0}
OUTPUT="${OUTPUT:-}"
```
→ `Config cu defaults`: Flexibilitate fără erori

```bash
usage() { ... }
die() { ... }
log() { ... }
```
→ `Helpers`: Funcții standard reutilizabile

```bash
cleanup() { ... }
trap cleanup EXIT
```
→ `Cleanup garantat`: Indiferent cum se termină

```bash
main() {
    parse_args "$@"
    validate
    # logica principală
}
main "$@"
```
→ Structură clară: Ușor de înțeles și modificat

---

### [0:40-0:45] SPRINT #2: Complete Script

Afișează pe ecran:

```
╔════════════════════════════════════════════════════════════════╗
║  🏃 SPRINT #2: Complete Script (5 min)                         ║
╠════════════════════════════════════════════════════════════════╣
║                                                                ║
║  Folosind template-ul profesional, scrie un script care:       ║
║                                                                ║
║  1. Acceptă -h pentru help                                     ║
║  2. Acceptă -n NUM pentru a specifica un număr (default: 10)   ║
║  3. Acceptă un fișier ca argument                              ║
║  4. Afișează primele NUM linii din fișier                      ║
║  5. Are error handling pentru fișier inexistent                ║
║                                                                ║
║  Exemplu: ./script.sh -n 5 input.txt                           ║
║                                                                ║
║  ⏱️ TIMP RĂMAS: 5:00                                          ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
```

---

### [0:45-0:48] LLM EXERCISE: Script Review

Afișează pe ecran:

```
╔════════════════════════════════════════════════════════════════╗
║  🤖 LLM Exercise: Script Reviewer (3 min)                      ║
╠════════════════════════════════════════════════════════════════╣
║                                                                ║
║  Dă acest script unui LLM (ChatGPT/Claude) și cere-i           ║
║  să îl îmbunătățească:                                         ║
║                                                                ║
║  ┌──────────────────────────────────────────────────────────┐  ║
║  │  #!/bin/bash                                             │  ║
║  │  files=$(ls *.txt)                                       │  ║
║  │  for f in $files; do                                     │  ║
║  │      cat $f >> all.txt                                   │  ║
║  │  done                                                    │  ║
║  │  echo "Done"                                             │  ║
║  └──────────────────────────────────────────────────────────┘  ║
║                                                                ║
║  Evaluează sugestiile LLM-ului:                                ║
║  □ A sugerat set -euo pipefail?                                ║
║  □ A corectat $(ls *.txt) cu glob direct?                      ║
║  □ A adăugat ghilimele la variabile?                           ║
║  □ A sugerat error handling?                                   ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
```

---

### [0:48-0:50] REFLECTION

Afișează pe ecran:

```
╔════════════════════════════════════════════════════════════════╗
║  🧠 REFLECTION (2 minute)                                      ║
╠════════════════════════════════════════════════════════════════╣
║                                                                ║
║  1. Ce vei face DIFERIT de acum în scripturile tale?           ║
║     _________________________________________________          ║
║                                                                ║
║  2. Care parte din template-ul profesional ți se pare          ║
║     cea mai importantă?                                        ║
║     □ set -euo pipefail                                        ║
║     □ trap cleanup                                             ║
║     □ Logging                                                  ║
║     □ Argument parsing                                         ║
║                                                                ║
║  3. Un lucru pe care l-ai învățat azi și nu știai:             ║
║     _________________________________________________          ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
```

---

## TROUBLESHOOTING RAPID

| Problemă | Diagnostic | Soluție |
|----------|------------|---------|
| "bad array subscript" | Array asociativ fără declare | Adaugă `declare -A` |
| "unbound variable" | Variabilă nedefinită cu set -u | `${VAR:-default}` |
| Script nu se oprește la eroare | Context unde -e nu funcționează | Verifică dacă e în if/||/&& |
| trap nu se execută | exit înainte de trap setup | Mută trap sus |
| local nu funcționează | În afara funcției | Folosește doar în funcții |
| return ignorat | În subshell/pipe | Folosește variabilă globală |
| Array pare gol | Iterare fără ghilimele | `"${arr[@]}"` |
| shellcheck warning | Cod valid dar nesigur | Urmează sugestia |

---

## DUPĂ SEMINAR

### Verificare Înțelegere
- Întreabă 2-3 studenți ce vor face diferit
- Colectează feedback despre ritmul seminarului

### Pregătire Temă
- Asigură-te că toți au primit specificațiile
- Clarifică deadline și criteriile de evaluare

### Materiale pentru Studenți
- Distribuie link către cheat sheet
- Trimite template-ul profesional

---


## Note personale de predare (adăugate v2.0)

> **Din experiența mea (Antonio):** studenții subestimează consecvent dezastrul produs de lipsa lui `local` până când depanează prima coliziune de spațiu de nume la 2 noaptea. „Momentul aha” vine mai repede dacă îi lași să greșească întâi într-un demo controlat, apoi îi „salvezi”.

### Revelația cafelei de la The Dose

Într-o sesiune de brainstorming cu Andrei Toma la The Dose (locul nostru obișnuit de lângă Piața Romană), ne-am dat seama că cel mai eficient demo este „variabila globală distructivă” — studenții chiar tresar când `count` devine 3 în loc de 100. Merită pauza dramatică.

### Tipare pe care le-am observat la studenții români

1. **Sindromul „merge la mine”** — mai ales în legătură cu versiunile Bash. Verificați întotdeauna `${BASH_VERSINFO[0]}` mai întâi.
2. **Copy‑paste de pe Stack Overflow** — iau `#!/bin/sh` și se întreabă de ce nu funcționează arrays.
3. **Teama de `set -e`** — „Dar dacă eșuează ceva?” Exact acesta este scopul.
4. **Iluzia „adaug error handling mai târziu”** — spoiler: nu îl adaugă.

---

## Protocol pentru examinare la distanță

> *Adăugat după perioada în care am fost forțați online, dar util și în scenarii hibride.*

### Configurare tehnică pentru sesiuni la distanță

1. **Partajare de ecran obligatorie** — studentul partajează terminalul/VS Code
2. **Camera video pornită** — fața vizibilă, ideal și mâinile pe tastatură
3. **Al doilea dispozitiv descurajat** — cereți să arate telefonul cu ecranul în jos
4. **Înregistrarea sesiunii** (cu formular de consimțământ semnat) — protejează ambele părți

### Temporizare adaptată

| Fizic | Distanță | Motiv |
|------|----------|-------|
| 5 min încălzire | 8 min | probleme tehnice, „mă auziți?” |
| 15 min live coding | 18 min | latență, corectarea typo-urilor e mai dificilă |
| Feedback imediat | ușor întârziat | folosiți chat-ul pentru note rapide |

### Verificare „low‑tech” (când nu există software de proctorizare)

1. **Pseudocod scris de mână** — înainte de cod, studentul fotografiază logica desenată. Greu de falsificat în timp real.
2. **Schimbarea limbii** — „Explică asta în română, apoi arată-mi codul în engleză.” Dezvăluie înțelegerea reală vs memorare.
3. **Audit istoric terminal** — la final: `cat ~/.bash_history | tail -50`. Arată activitatea recentă.
4. **Capcană cu eroare deliberată** — „Văd un bug pe linia 47” (când nu există). Studenții autentici verifică și spun „Nu îl văd”. Cei care copiază se precipită să „repare” ceva.

### Listă de verificare post‑sesiune

- [ ] Înregistrarea salvată într-o locație securizată
- [ ] Observațiile notate în ≤10 minute (memoria se estompează rapid)
- [ ] Orice îngrijorare documentată cu numere de linie specifice
- [ ] Nota introdusă în ≤48 de ore

---

## Reflecție la final de semestru (actualizată ianuarie 2025)

După cinci semestre de predare a acestui material, feedback-ul constant este:
- **Cel mai valoros:** template-ul profesional — îl folosesc pentru aproape orice
- **Cel mai surprinzător:** limitările lui `set -e` — „credeam că e magie”
- **Cel mai solicitat:** mai multe demo-uri de depanare live
- **Cel mai puțin folosit:** nivelurile de jurnalizare (spun „echo e suficient” până ajung în producție)

### Revelația cafelei de la The Dose

Într-o sesiune de brainstorming cu Andrei Toma la The Dose (locul nostru obișnuit de lângă Piața Romană), ne-am dat seama că cel mai eficient demo este „variabila globală distructivă” — studenții chiar tresar când `count` devine 3 în loc de 100. Merită pauza dramatică.

### Lucruri pe care am învățat să le fac diferit

1. **Începeți cu dezastrul, nu cu teoria** — demo-ul scriptului fragil la 0:00 captează atenția mai bine decât „astăzi învățăm despre…”

2. **Lăsați-i să prezică înainte de a rula** — „Ce crezi că afișează?” urmat de realitate e mai memorabil decât o prelegere.

3. **Sărbătoriți shellcheck** — inițial îl văd ca pe o pedeapsă. Reîncadrare: „e pair programming cu un expert care nu doarme niciodată.”

4. **Nota despre automatul de cafea** — automatele din clădirea Virgil Madgearu se golesc până la 21:00 în sezonul de examene. Pentru sesiuni târzii de corectare, veniți cu cafea proprie.

*Actualizat: ianuarie 2025 | ing. dr. Antonio Clim*

*Ghid generat pentru ASE București - CSIE | Sisteme de Operare*
