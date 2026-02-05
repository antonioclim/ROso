# S05_09 - Cheat Sheet Vizual: Referință Rapidă

> **Sisteme de Operare** | ASE București - CSIE  
> Seminar 5: Scripting Bash avansat
> Versiune: 2.0.0 | Data: 2025-01

---

## STRICT MODE (Memorează: "euo pipefail IFS")

```bash
#!/bin/bash

*(Bash-ul are o sintaxă urâtă, recunosc. Dar rulează peste tot, și asta contează enorm în practică.)*

set -euo pipefail
IFS=$'\n\t'
```

| Opțiune | Ce face | Fără ea |
|---------|---------|---------|
| `-e` | Exit la eroare | Continuă după erori |
| `-u` | Eroare var nedefinită | Var nedefinită = "" |
| `-o pipefail` | Pipe returnează prima eroare | Returnează ultima |
| `IFS=...` | Separator sigur | Spațiul separă |

### Capcană: -e NU funcționează în:
```
if command          # în condiții
command || other    # cu ||
command && other    # cu &&
! command           # cu negare
```

---

## FUNCȚII

### Sintaxă
```bash
function_name() {
    local var="value"    # ÎNTOTDEAUNA local!
    echo "result"        # "returnează" valori
    return 0             # doar exit code (0-255)
}

result=$(function_name arg1 arg2)
```

### Argumente
```
$1, $2, ...   Argumente poziționale
$@            Toate argumentele (ca array)
$#            Număr argumente
$0            Numele scriptului
```

### GREȘELI COMUNE

```bash
# GREȘIT: var globală
process() {
    count=0    # Modifică global!
}

# CORECT: var locală
process() {
    local count=0
}

# GREȘIT: return pentru valori
get_sum() { return $((a+b)); }  # Max 255!

# CORECT: echo pentru valori
get_sum() { echo $((a+b)); }
result=$(get_sum)
```

---

## ARRAYS INDEXATE

### Creare și Acces
```bash
arr=("a" "b" "c")      # Creare
arr+=("d")             # Append
arr[0]="A"             # Modificare

${arr[0]}              # Element (index 0!)
${arr[@]}              # Toate elementele
${#arr[@]}             # Lungime
${!arr[@]}             # Toți indicii
```

### Iterare
```bash
# CORECT - cu ghilimele!
for item in "${arr[@]}"; do
    echo "$item"
done

# GREȘIT - fără ghilimele
for item in ${arr[@]}; do    # Word splitting!
```

### Slice
```bash
${arr[@]:1:3}    # De la index 1, 3 elemente
${arr[@]:2}      # De la index 2 până la final
```

---

## ARRAYS ASOCIATIVE

### Creare (OBLIGATORIU declare -A!)
```bash
declare -A config              # OBLIGATORIU!
config[host]="localhost"
config[port]="8080"

# Sau inline:
declare -A config=(
    [host]="localhost"
    [port]="8080"
)
```

### Acces
```bash
${config[host]}         # Valoare pentru cheie
${!config[@]}           # Toate cheile
${config[@]}            # Toate valorile
${#config[@]}           # Număr chei
```

### Iterare
```bash
for key in "${!config[@]}"; do
    echo "$key = ${config[$key]}"
done
```

### FĂRĂ declare -A:
```bash
hash[host]="x"    # hash[0]="x" (host=0!)
hash[port]="y"    # hash[0]="y" (suprascrie!)
```

---

## TRAP și CLEANUP

### Pattern Standard
```bash
TEMP_FILE=""

cleanup() {
    local exit_code=$?
    [[ -f "$TEMP_FILE" ]] && rm -f "$TEMP_FILE"
    exit $exit_code
}

trap cleanup EXIT           # La orice ieșire
trap 'echo "Ctrl+C"' INT   # La Ctrl+C
```

### Semnale Comune
```
EXIT    La ieșirea scriptului (orice mod)
ERR     La eroare (cu set -e)
INT     Ctrl+C
TERM    kill (default)
DEBUG   Înainte de fiecare comandă
```

### Trap pentru Debugging
```bash
trap 'echo "Line $LINENO: $BASH_COMMAND"' DEBUG
```

---

## VERIFICĂRI

### Fișiere
```bash
[[ -f "$f" ]]    # Fișier există
[[ -d "$d" ]]    # Director există
[[ -r "$f" ]]    # Citibil
[[ -w "$f" ]]    # Scriibil
[[ -x "$f" ]]    # Executabil
[[ -s "$f" ]]    # Non-empty
```

### Stringuri
```bash
[[ -z "$s" ]]    # Empty
[[ -n "$s" ]]    # Non-empty
[[ "$a" == "$b" ]]   # Egal
[[ "$a" != "$b" ]]   # Diferit
[[ "$s" =~ regex ]]  # Regex match
```

### Numere
```bash
[[ $a -eq $b ]]    # Equal
[[ $a -ne $b ]]    # Not equal
[[ $a -lt $b ]]    # Less than
[[ $a -le $b ]]    # Less or equal
[[ $a -gt $b ]]    # Greater than
[[ $a -ge $b ]]    # Greater or equal
```

### Logice
```bash
[[ cond1 && cond2 ]]    # AND
[[ cond1 || cond2 ]]    # OR
[[ ! cond ]]            # NOT
```

---

## DEFAULT VALUES

```bash

*Notă personală: Mulți preferă `zsh`, dar eu rămân la Bash pentru că e standardul pe servere. Consistența bate confortul.*

${VAR:-default}     # Returnează default dacă VAR nesetat/gol
${VAR:=default}     # Setează VAR la default dacă nesetat/gol
${VAR:?error msg}   # Eroare dacă VAR nesetat/gol
${VAR:+alternate}   # Returnează alternate dacă VAR E setat
```

### Pattern pentru Argumente
```bash
INPUT="${1:-default.txt}"      # Arg opțional
OUTPUT="${2:-}"                # Arg opțional (poate fi gol)
: "${REQUIRED:?Must be set}"   # Variabilă obligatorie
```

---

## DEBUGGING

### Activare
```bash
set -x         # Afișează comenzi (xtrace)
set -v         # Afișează linii citite (verbose)
set +x         # Dezactivează

bash -x script.sh    # Rulează cu debug
```

### Custom PS4
```bash
PS4='+ ${BASH_SOURCE}:${LINENO}: '
```

### Variabile Debug
```bash
$LINENO          # Linia curentă
$BASH_COMMAND    # Comanda curentă
$FUNCNAME        # Funcția curentă
$BASH_SOURCE     # Fișierul curent
${PIPESTATUS[@]} # Exit codes din pipe
```

### Pattern Debug Condiționat
```bash
DEBUG="${DEBUG:-false}"
debug() {
    [[ "$DEBUG" == "true" ]] && echo "[DEBUG] $*" >&2
}
```

---

## TEMPLATE RAPID

```bash
#!/bin/bash
set -euo pipefail

readonly SCRIPT_NAME=$(basename "$0")
die() { echo "FATAL: $*" >&2; exit 1; }

cleanup() {
    local ec=$?
    # cleanup
    exit $ec
}
trap cleanup EXIT

[[ $# -ge 1 ]] || die "Usage: $SCRIPT_NAME <arg>"

main() {
    echo "Hello from $SCRIPT_NAME"
}

main "$@"
```

---

## GREȘELI FRECVENTE

| Greșit | Corect |
|--------|--------|
| `$arr[@]` | `${arr[@]}` |
| `${arr[@]}` în for | `"${arr[@]}"` |
| `hash[key]=v` | `declare -A hash; hash[key]=v` |
| `var in func` | `local var in func` |
| `return "string"` | `echo "string"` |
| `cd $dir; rm *` | `set -e; cd "$dir"; rm *` |
| `$(ls *.txt)` | `*.txt` sau `find` |

---

## QUICK REFERENCE CARD

```
╔══════════════════════════════════════════════════════════════╗
║  BASH ADVANCED - QUICK REFERENCE                             ║
╠══════════════════════════════════════════════════════════════╣
║  ROBUSTNESS          FUNCTIONS          ARRAYS               ║
║  ─────────────       ─────────────      ──────────           ║
║  set -euo pipefail   local var=x        arr=(a b c)          ║
║  IFS=$'\n\t'         echo "return"      "${arr[@]}"          ║
║                      return 0-255       ${#arr[@]}           ║
║                                                              ║
║  ASSOCIATIVE         TRAP               DEFAULTS             ║
║  ─────────────       ─────────────      ──────────           ║
║  declare -A h        trap cmd EXIT      ${V:-def}            ║
║  h[key]="val"        trap cmd INT       ${V:=def}            ║
║  ${!h[@]}            trap cmd ERR       ${V:?err}            ║
║                                                              ║
║  CHECKS              DEBUG              ITERATION            ║
║  ─────────────       ─────────────      ──────────           ║
║  [[ -f "$f" ]]       set -x / +x        for i in "${a[@]}"   ║
║  [[ -d "$d" ]]       $LINENO            for k in "${!h[@]}"  ║
║  [[ -n "$s" ]]       PS4='...'          while read line      ║
╚══════════════════════════════════════════════════════════════╝
```

---

*Print this page for quick reference during labs and exams!*

*Material de laborator pentru cursul de Sisteme de Operare | ASE București - CSIE*
