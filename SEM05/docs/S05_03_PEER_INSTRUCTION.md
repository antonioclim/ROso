# S05_03 - Peer Instruction: Întrebări pentru Discuție

> Sisteme de Operare | ASE București - CSIE  
> Seminar 5: Advanced Bash Scripting
> Versiune: 2.0.0 | Data: 2025-01

---

## Despre Peer Instruction

Peer Instruction este o metodă pedagogică dezvoltată de Eric Mazur (Harvard) care:
1. Prezintă o întrebare conceptuală (MCQ)
2. Studenții votează individual
3. Discuție în perechi/grupuri mici (2-3 min)
4. Revot
5. Explicație din partea instructorului

### Când să folosești fiecare întrebare

| Secțiune Seminar | Întrebări Recomandate |
|------------------|----------------------|
| După funcții (0:20) | Q1, Q2, Q3 |
| După arrays (0:40) | Q4, Q5, Q6, Q7 |
| După pauză - reactivare | Q8 |
| După stabilitate (1:20) | Q9, Q10, Q11, Q12 |
| După logging/trap (1:35) | Q13, Q14 |
| Final - consolidare | Q15, Q16, Q17, Q18 |

---

## Secțiunea 1: FUNCȚII

### Q1: Variabile în Funcții (Misconceptie 80%)

```bash
#!/bin/bash
count=10

increment() {
    count=$((count + 1))
    echo "În funcție: $count"
}

increment
echo "După funcție: $count"
```

Ce afișează ultima linie?

- A) `După funcție: 10`
- B) `După funcție: 11`
- C) `După funcție: ` (gol)
- D) Eroare - count nu e definit în main

<details>
<summary>📋 Răspuns și Explicație</summary>

Răspuns corect: B) `După funcție: 11`

Explicație:

Principalele aspecte: în bash, variabilele din funcții sunt globale by default, `count` din funcție modifică variabila globală și aceasta e opusul comportamentului din python/java/c.


Misconceptie vizată: 80% cred că variabilele sunt locale by default

Întrebare follow-up: "Cum facem ca variabila să rămână locală?"
→ Răspuns: `local count=$((count + 1))`

</details>

---

### Q2: Return vs Echo (Misconceptie 75%)

```bash
#!/bin/bash

get_value() {
    return 42
}

result=$(get_value)
echo "Result: '$result'"
```

Ce afișează?

- A) `Result: '42'`
- B) `Result: ''` (string gol)
- C) `Result: '0'`
- D) Eroare de sintaxă

<details>
<summary>📋 Răspuns și Explicație</summary>

Răspuns corect: B) `Result: ''` (string gol)

Explicație:
- `return` în Bash setează doar exit code (0-255), nu returnează valori
- `$()` capturează **stdout**, nu exit code-ul
- Funcția nu face `echo`, deci stdout e gol
- Folosește `man` sau `--help` când ai dubii

Cum verificăm exit code-ul:
```bash
get_value
echo "Exit code: $?"    # 42
```

Cum returnăm valori:
```bash
get_value() {
    echo 42    # Aceasta e "returnarea" în Bash
}
result=$(get_value)    # result="42"
```

Misconceptie vizată: 75% cred că return funcționează ca în alte limbaje

</details>

---

### Q3: Argumentele Funcției vs Script (Misconceptie 65%)

```bash
#!/bin/bash
# Script salvat ca test.sh și rulat cu: ./test.sh SCRIPT_ARG

show_arg() {
    echo "Funcție vede: $1"
}

echo "Script vede: $1"
show_arg "FUNC_ARG"
```

Rulat cu `./test.sh SCRIPT_ARG`, ce afișează a doua linie?

- A) `Funcție vede: SCRIPT_ARG`
- B) `Funcție vede: FUNC_ARG`
- C) `Funcție vede: ` (gol)
- D) `Funcție vede: $1`

<details>
<summary>📋 Răspuns și Explicație</summary>

Răspuns corect: B) `Funcție vede: FUNC_ARG`

Explicație:
- `$1` în funcție se referă la argumentul funcției, nu al scriptului
- Funcțiile au propriul set de argumente poziționale
- Pentru a accesa argumentele scriptului din funcție, trebuie transmise explicit

Demonstrație:
```bash
show_arg() {
    echo "Arg funcție: $1"
    echo "Toate args funcție: $@"
}

show_arg "A" "B" "C"
# Arg funcție: A
# Toate args funcție: A B C
```

Misconceptie vizată: 65% confundă $1 din funcție cu $1 din script

</details>

---

## Secțiunea 2: ARRAYS

### Q4: Indexare Arrays (Misconceptie 55%)

```bash
#!/bin/bash
arr=("first" "second" "third")
echo "${arr[1]}"
```

Ce afișează?

- A) `first`
- B) `second`
- C) `third`
- D) Eroare - indexul 1 nu există

<details>
<summary>📋 Răspuns și Explicație</summary>

Răspuns corect: B) `second`

Explicație:
- Arrays în Bash încep de la index 0, nu 1
- `arr[0]` = "first"
- `arr[1]` = "second"
- `arr[2]` = "third"

**Atenție pentru studenți familiari cu Lua, R, sau alte limbaje 1-indexed!**

Misconceptie vizată: 55% cred că arrays încep de la 1

</details>

---

### Q5: declare -A (Misconceptie 70%)

```bash
#!/bin/bash
# Fără declare -A
config[host]="localhost"
config[port]="8080"
echo "Chei: ${!config[@]}"
```

Ce afișează?

- A) `Chei: host port`
- B) `Chei: 0`
- C) `Chei: 0 0`
- D) Eroare - config nu e declarat

<details>
<summary>📋 Răspuns și Explicație</summary>

Răspuns corect: B) `Chei: 0`

Explicație:
- Fără `declare -A`, Bash tratează `config` ca array **indexat**
- `host` și `port` sunt evaluate ca variabile (nedefinite = 0)
- Ambele asignări scriu la `config[0]`!
- Prima valoare e suprascrisă de a doua

Demonstrație completă:
```bash
# Fără declare -A
config[host]="localhost"    # config[0]="localhost"
config[port]="8080"         # config[0]="8080" (suprascrie!)
echo "${config[@]}"         # 8080
echo "${!config[@]}"        # 0

# Cu declare -A
declare -A config
config[host]="localhost"
config[port]="8080"
echo "${!config[@]}"        # host port (corect!)
```

Misconceptie vizată: 70% cred că declare -A e opțional

</details>

---

### Q6: Iterare cu Ghilimele (Misconceptie 65%)

```bash
#!/bin/bash
files=("file one.txt" "file two.txt")

count=0
for f in ${files[@]}; do
    ((count++))
done
echo "Iterații: $count"
```

Câte iterații are loop-ul?

- A) 2
- B) 4
- C) 1
- D) Eroare

<details>
<summary>📋 Răspuns și Explicație</summary>

Răspuns corect: B) 4

Explicație:
- Fără ghilimele, Bash aplică word splitting
- "file one.txt" devine 2 cuvinte: "file" și "one.txt"
- "file two.txt" devine 2 cuvinte: "file" și "two.txt"
- Total: 4 iterații

Corect:
```bash
for f in "${files[@]}"; do    # Cu ghilimele!
    ((count++))
done
# Acum sunt doar 2 iterații
```

Regulă de aur: ÎNTOTDEAUNA folosește `"${arr[@]}"` cu ghilimele!

Misconceptie vizată: 65% uită ghilimelele la iterare

</details>

---

### Q7: Ștergere Element din Array

```bash
#!/bin/bash
arr=("a" "b" "c" "d" "e")
unset arr[2]
echo "Indici: ${!arr[@]}"
echo "Lungime: ${#arr[@]}"
```

Ce afișează?

- A) `Indici: 0 1 2 3` și `Lungime: 4`
- B) `Indici: 0 1 3 4` și `Lungime: 4`
- C) `Indici: 0 1 2 3 4` și `Lungime: 5`
- D) Eroare

<details>
<summary>📋 Răspuns și Explicație</summary>

Răspuns corect: B) `Indici: 0 1 3 4` și `Lungime: 4`

Explicație:
- `unset arr[2]` șterge elementul, dar NU reindexează
- Array-ul devine "sparse" (cu gap)
- Indicii rămași: 0, 1, 3, 4 (lipsește 2)
- Lungimea e 4 (numărul de elemente existente)

Implicații practice:
- Loop-ul clasic `for ((i=0; i<${#arr[@]}; i++))` poate rata elemente!
- Folosește `for i in "${!arr[@]}"` pentru siguranță

</details>

---

## Secțiunea 3: solidEȚE (set -euo pipefail)

### Q8: Reactivare după Pauză

```bash
#!/bin/bash
set -euo pipefail

x="${UNDEFINED_VAR}"
echo "Continuă..."
```

Ce se întâmplă?

- A) Afișează `Continuă...` cu x=""
- B) Eroare: unbound variable
- C) Afișează `Continuă...` cu x="UNDEFINED_VAR"
- D) Depinde de versiunea Bash

<details>
<summary>📋 Răspuns și Explicație</summary>

**Răspuns corect: B) Eroare: unbound variable**

Explicație:
- `set -u` (nounset) face ca variabilele nedefinite să cauzeze eroare
- `UNDEFINED_VAR` nu există → script se oprește

Cum folosim variabile opționale cu set -u:
```bash
# Default value
x="${UNDEFINED_VAR:-default}"

# Empty string ca default
x="${UNDEFINED_VAR:-}"

# Verificare explicită
if [[ -n "${UNDEFINED_VAR:-}" ]]; then
    echo "E setat"
fi
```

</details>

---

### Q9: set -e în if (Misconceptie 75%)

```bash
#!/bin/bash
set -e

if false; then
    echo "În if"
fi
echo "După if"
```

Ce se întâmplă?

- A) Script se oprește la `false`
- B) Afișează `După if`
- C) Afișează `În if` apoi `După if`
- D) Eroare de sintaxă

<details>
<summary>📋 Răspuns și Explicație</summary>

Răspuns corect: B) Afișează `După if`

Explicație:
- `set -e` NU funcționează pentru comenzi în condiții `if/while/until`
- `false` e într-un context de test, deci eroarea e ignorată
- Scriptul continuă normal

Alte cazuri unde set -e NU funcționează:
- Comenzi urmate de `||` sau `&&`
- Comenzi negate cu `!`
- Funcții apelate în context de test

Misconceptie vizată: 75% cred că set -e oprește la ORICE eroare

</details>

---

### Q10: set -e cu || (Misconceptie 60%)

```bash
#!/bin/bash
set -e

false || echo "Rescued"
echo "Continuă"
```

Ce afișează?

- A) Nimic - script se oprește
- B) `Rescued` apoi `Continuă`
- C) Doar `Continuă`
- D) Doar `Rescued`

<details>
<summary>📋 Răspuns și Explicație</summary>

Răspuns corect: B) `Rescued` apoi `Continuă`

Explicație:
- `||` "salvează" eroarea - set -e nu se aplică
- `false` eșuează → se execută partea de după `||`
- `echo "Rescued"` reușește → pipeline returnează 0
- Scriptul continuă

Pattern util:
```bash
set -e
command_that_might_fail || {
    echo "Failed, but handling it..."
}
# Scriptul continuă
```

</details>

---

### Q11: pipefail

```bash
#!/bin/bash
set -o pipefail

false | true | true
echo "Exit: $?"
```

Ce afișează?

- A) `Exit: 0`
- B) `Exit: 1`
- C) `Exit: 2`
- D) Nimic - script se oprește

<details>
<summary>📋 Răspuns și Explicație</summary>

Răspuns corect: B) `Exit: 1`

Explicație:

Concret: Cu `pipefail`, pipeline returnează exit code-ul primei comenzi care eșuează. `false` returnează 1. Și Fără pipefail, ar fi returnat 0 (de la ultimul `true`).


PIPESTATUS pentru debugging:
```bash
false | true | true
echo "Individual: ${PIPESTATUS[@]}"    # 1 0 0
```

</details>

---

### Q12: Combinație set -e și pipefail

```bash
#!/bin/bash
set -eo pipefail

cat /nonexistent | grep "pattern"
echo "După pipe"
```

Ce se întâmplă?

- A) Afișează eroarea de la cat, apoi `După pipe`
- B) Script se oprește la eroarea cat
- C) Afișează `După pipe` (grep salvează)
- D) Depinde de existența fișierului "pattern"

<details>
<summary>📋 Răspuns și Explicație</summary>

**Răspuns corect: B) Script se oprește la eroarea cat**

Explicație:
- `set -e` + `pipefail` = erori din pipe opresc scriptul
- `cat /nonexistent` eșuează (exit code ≠ 0)
- Cu pipefail, pipeline-ul returnează acest exit code
- Cu set -e, scriptul se oprește

Fără pipefail:
- Pipeline ar returna exit code-ul lui grep
- Grep pe input gol returnează 1 (no match)
- Tot s-ar opri, dar din alt motiv!

</details>

---

## Secțiunea 4: TRAP și ERROR HANDLING

### Q13: Trap EXIT

```bash
#!/bin/bash
set -e

cleanup() {
    echo "Cleanup executat"
}
trap cleanup EXIT

echo "Start"
false
echo "End"
```

Ce afișează?

- A) `Start` apoi `Cleanup executat`
- B) `Start`, `End`, `Cleanup executat`
- C) Doar `Start`
- D) `Cleanup executat` apoi `Start`

<details>
<summary>📋 Răspuns și Explicație</summary>

Răspuns corect: A) `Start` apoi `Cleanup executat`

Explicație:
- `trap cleanup EXIT` se execută întotdeauna la ieșire
- `false` + `set -e` → script se oprește
- Dar trap EXIT tot se execută!
- `End` nu se afișează pentru că scriptul s-a oprit

De aceea trap EXIT e perfect pentru cleanup:
- Funcționează la ieșire normală
- Funcționează la erori
- Funcționează la Ctrl+C (dacă ai și trap INT)
- Verifică întotdeauna rezultatul înainte de a continua

</details>

---

### Q14: Trap și Subshell

```bash
#!/bin/bash

cleanup() { echo "Cleanup"; }
trap cleanup EXIT

(
    echo "În subshell"
    exit 1
)

echo "După subshell: $?"
```

Câte "Cleanup" apar?

- A) 0
- B) 1
- C) 2
- D) Depinde de versiunea Bash

<details>
<summary>📋 Răspuns și Explicație</summary>

Răspuns corect: B) 1

Explicație:
- Trap-urile NU se moștenesc în subshell-uri
- Subshell-ul (în paranteze) nu are cleanup trap
- Când subshell-ul face exit 1, nu se execută cleanup
- Cleanup se execută doar când scriptul principal se termină

Output complet:
```
În subshell
După subshell: 1
Cleanup
```

Dacă vrei trap în subshell:
```bash
(
    trap cleanup EXIT
    # acum funcționează în subshell
)
```

</details>

---

## Secțiunea 5: CONSOLIDARE

### Q15: Template Profesional

Care e ordinea corectă a secțiunilor într-un script profesional?

- A) Shebang → Main → Functions → Trap → Constants
- B) Shebang → Constants → Functions → Trap → Main
- C) Shebang → set -euo pipefail → Constants → Functions → Trap → Parse Args → Main
- D) Main → Functions → Shebang → Trap

<details>
<summary>📋 Răspuns și Explicație</summary>

Răspuns corect: C)

Structura recomandată:
```bash
#!/bin/bash                    # 1. Shebang
set -euo pipefail             # 2. Strict mode
IFS=$'\n\t'                   # 3. IFS sigur

readonly SCRIPT_NAME=...      # 4. Constante
VERBOSE=${VERBOSE:-0}         # 5. Configurare

usage() { ... }               # 6. Funcții helper
die() { ... }

cleanup() { ... }             # 7. Cleanup
trap cleanup EXIT             # 8. Trap

parse_args() { ... }          # 9. Argument parsing
validate() { ... }            # 10. Validare

main() {                      # 11. Main
    parse_args "$@"
    validate
    # logică
}

main "$@"                     # 12. Execuție
```

</details>

---

### Q16: Identifică Bug-ul

```bash
#!/bin/bash
set -euo pipefail

declare -a files
files=$(find . -name "*.txt")

for f in ${files[@]}; do
    process "$f"
done
```

Câte bug-uri are acest cod?

- A) 1
- B) 2
- C) 3
- D) 4 sau mai multe

<details>
<summary>📋 Răspuns și Explicație</summary>

Răspuns corect: C) 3 bug-uri principale

Bug 1: `files=$(...)` - assignment greșit pentru array
```bash
# Greșit:
files=$(find . -name "*.txt")    # files devine STRING

# Corect:
mapfile -t files < <(find . -name "*.txt")
# sau
readarray -t files < <(find . -name "*.txt")
```

Bug 2: `${files[@]}` fără ghilimele
```bash
# Greșit:
for f in ${files[@]}; do    # Word splitting!

# Corect:
for f in "${files[@]}"; do
```

Bug 3: Potențial - `declare -a` nu e necesar pentru arrays indexate
```bash
# OK dar redundant:
declare -a files

# Suficient:
files=()
```

</details>

---

### Q17: Best Practice

Care afirmație este FALSĂ despre best practices în Bash?

> 💡 Mulți studenți subestimează inițial importanța permisiunilor. Apoi întâlnesc primul 'Permission denied' și se luminează.


- A) `local` trebuie folosit pentru toate variabilele din funcții
- B) `declare -A` e obligatoriu pentru arrays asociative
- C) `set -e` oprește scriptul la absolut orice eroare
- D) `"${arr[@]}"` cu ghilimele e necesar pentru iterare corectă

<details>
<summary>📋 Răspuns și Explicație</summary>

Răspuns corect: C) este FALSĂ

Explicație:
- A) ADEVĂRAT - local previne efecte secundare
- B) ADEVĂRAT - fără el, Bash tratează ca array indexat
- C) FALS - set -e are multiple excepții (if, ||, &&, !, etc.)
- D) ADEVĂRAT - fără ghilimele, word splitting corupe elementele

Excepțiile set -e:
1. Comenzi în if/while/until
2. Partea stângă a || sau &&
3. Comenzi negate cu !
4. Funcții în context de test
5. Subshell-uri (fără inherit_errexit)

</details>

---

### Q18: Debugging

```bash
#!/bin/bash
DEBUG="${DEBUG:-false}"

process() {
    local file="$1"
    $DEBUG && echo "[DEBUG] Processing: $file" >&2
    # ... procesare
}
```

Ce face `$DEBUG && echo ...`?

- A) Întotdeauna afișează mesajul debug
- B) Afișează mesajul doar dacă DEBUG="true"
- C) Afișează mesajul doar dacă DEBUG e orice valoare non-goală
- D) Eroare de sintaxă

<details>
<summary>📋 Răspuns și Explicație</summary>

Răspuns corect: B) Afișează mesajul doar dacă DEBUG="true"

Explicație:
- `$DEBUG` se expandează la valoarea variabilei
- Dacă DEBUG="true", comanda e `true && echo ...` → echo se execută
- Dacă DEBUG="false", comanda e `false && echo ...` → echo NU se execută
- `&&` execută partea dreaptă doar dacă stânga reușește

Pattern alternativ:
```bash
[[ "$DEBUG" == "true" ]] && echo "[DEBUG] ..."
```

Activare:
```bash
DEBUG=true ./script.sh
```

</details>

---

## Ghid de Facilitare

### Înainte de Întrebare
1. Asigură-te că conceptul a fost prezentat
2. Citește întrebarea cu voce tare
3. Acordă 30 secunde pentru gândire individuală

### După Primul Vot
- Dacă >70% corect → Explicație scurtă și continuă
- Dacă 30-70% corect → Peer Discussion (2-3 min)
- Dacă <30% corect → Re-explică conceptul, apoi revot

### În Timpul Discuției Peer
- Încurajează: "Explicați-vă reciproc DE CE ați ales răspunsul"
- Circulă prin sală și ascultă argumentele
- Notează misconceptii interesante pentru explicație

### După Revot
- Arată distribuția voturilor
- Cere unui student să explice răspunsul corect
- Completează cu informații lipsă
- Conectează la conceptul următor

---

## Fișă de Înregistrare Răspunsuri

| Întrebare | Pre-vote | Post-vote | Observații |
|-----------|----------|-----------|------------|
| Q1 (local) | __ / __ % | __ / __ % | |
| Q2 (return) | __ / __ % | __ / __ % | |
| Q3 ($1 scope) | __ / __ % | __ / __ % | |
| Q4 (index 0) | __ / __ % | __ / __ % | |
| Q5 (declare -A) | __ / __ % | __ / __ % | |
| Q6 (ghilimele) | __ / __ % | __ / __ % | |
| Q7 (unset) | __ / __ % | __ / __ % | |
| Q8 (set -u) | __ / __ % | __ / __ % | |
| Q9 (set -e if) | __ / __ % | __ / __ % | |
| Q10 (set -e ||) | __ / __ % | __ / __ % | |
| Q11 (pipefail) | __ / __ % | __ / __ % | |
| Q12 (combo) | __ / __ % | __ / __ % | |
| Q13 (trap EXIT) | __ / __ % | __ / __ % | |
| Q14 (trap subshell) | __ / __ % | __ / __ % | |
| Q15 (template) | __ / __ % | __ / __ % | |
| Q16 (bugs) | __ / __ % | __ / __ % | |
| Q17 (best practice) | __ / __ % | __ / __ % | |
| Q18 (debug) | __ / __ % | __ / __ % | |

---

*Material de laborator pentru cursul de Sisteme de Operare | ASE București - CSIE*
