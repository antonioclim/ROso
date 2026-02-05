# S05_05 - Ghid Live Coding pentru Instructor

> **Sisteme de Operare** | ASE București - CSIE  
> Seminar 5: Scripting Bash avansat
> Versiune: 2.0.0 | Data: 2025-01

---

## Filosofia Live Coding

### Principii Fundamentale

1. **Fă greșeli INTENȚIONAT** - normalizează procesul de debugging
2. **Gândește cu voce tare** - verbalizează raționamentul
3. **Ritm lent** - studenții copiază, nu doar privesc
4. **Întreabă frecvent** - "Ce credeți că se va întâmpla?"
5. **Folosește erori ca momente de învățare**

### Setup Recomandat

```
┌─────────────────────────────────────────────────────────┐
│  Terminal (font mare: 18-20pt)                          │
│  - Prompt scurt: PS1='$ '                               │
│  - Culori activate                                      │
│  - History vizibil                                      │
├─────────────────────────────────────────────────────────┤
│  Editor (side-by-side cu terminal)                      │
│  - Syntax highlighting                                  │
│  - Line numbers                                         │
│  - Font mare                                            │
└─────────────────────────────────────────────────────────┘
```

---

## Sesiunea 1: FUNCȚII (20 minute)

### LC1.1: Prima Funcție (5 min)

**Obiectiv:** Sintaxa de bază și apelare

```bash
# Deschide terminal, scrie direct:

$ # Hai să creăm prima funcție
$ greet() {
>     echo "Hello, World!"
> }

$ # Observați - nu s-a întâmplat nimic vizibil
$ # Funcția e definită, dar nu executată

$ # Cum o apelăm?
$ greet
Hello, World!

$ # Cu argumente?
$ greet Ana
Hello, World!

$ # Hmm, nu a folosit argumentul. De ce?
$ # Pentru că nu i-am spus să-l folosească!
```

**🎯 Moment de învățare:**
```bash
$ greet() {
>     echo "Hello, $1!"
> }

$ greet Ana
Hello, Ana!

$ greet "Ion Popescu"
Hello, Ion Popescu!

$ # Ce e $1? Primul argument al FUNCȚIEI
```

---

### LC1.2: Variabile Locale vs Globale (7 min)

**Obiectiv:** Demonstrare vizuală a problemei cu variabile globale

**PASUL 1: Setup problema**
```bash
$ cat > demo_global.sh << 'EOF'
#!/bin/bash

count=100
echo "Înainte: count=$count"

process() {
    count=0
    for item in a b c; do
        ((count++))
    done
    echo "În funcție: count=$count"
}

process
echo "După: count=$count"
EOF

$ chmod +x demo_global.sh
```

**PASUL 2: Predicție**
```bash
$ # ÎNTREBARE PENTRU CLASĂ:
$ # Ce va afișa "După: count=..." ?
$ # A) 100
$ # B) 3
$ # C) 0
$ # Votați!
```

**PASUL 3: Execuție și surpriză**
```bash
$ ./demo_global.sh
Înainte: count=100
În funcție: count=3
După: count=3

$ # SURPRIZĂ! count din main a fost modificat!
$ # De ce? Variabilele în funcții sunt GLOBALE by default!
```

**PASUL 4: Soluția**
```bash
$ # Edităm fișierul - adăugăm 'local'
$ cat > demo_local.sh << 'EOF'
#!/bin/bash

count=100
echo "Înainte: count=$count"

process() {
    local count=0    # <-- SINGURA DIFERENȚĂ
    for item in a b c; do
        ((count++))
    done
    echo "În funcție: count=$count"
}

process
echo "După: count=$count"
EOF

$ ./demo_local.sh
Înainte: count=100
În funcție: count=3
După: count=100    # Corect acum!
```

**📝 Regula de aur pe tablă:**
```
┌─────────────────────────────────────────────┐
│  ÎNTOTDEAUNA folosește `local` în funcții!  │
└─────────────────────────────────────────────┘
```

---

### LC1.3: Return vs Echo (8 min)

**PASUL 1: Greșeala comună**
```bash
$ get_sum() {
>     return $(($1 + $2))
> }

$ result=$(get_sum 5 3)
$ echo "Rezultat: '$result'"
Rezultat: ''

$ # Gol?! De ce?
```

**PASUL 2: Explicație**
```bash
$ # return setează EXIT CODE, nu returnează valori!
$ get_sum 5 3
$ echo "Exit code: $?"
Exit code: 8

$ # Exit code e limitat la 0-255
$ get_sum 200 100
$ echo "Exit code: $?"
Exit code: 44    # 300 % 256 = 44 (overflow!)
```

**PASUL 3: Soluția corectă**
```bash
$ get_sum() {
>     echo $(($1 + $2))    # Echo pentru "a returna" valori
> }

$ result=$(get_sum 5 3)
$ echo "Rezultat: $result"
Rezultat: 8

$ # Funcționează și pentru valori mari
$ result=$(get_sum 200 100)
$ echo "Rezultat: $result"
Rezultat: 300
```

**📝 Pe tablă:**
```
┌─────────────────────────────────────────┐
│  return = exit code (0-255)             │
│  echo = "returnează" valori (capture)   │
│                                         │
│  result=$(functie args)                 │
└─────────────────────────────────────────┘
```

---

## Sesiunea 2: ARRAYS (20 minute)

### LC2.1: Array Indexat Basic (5 min)

```bash
$ # Creăm un array
$ fruits=("apple" "banana" "cherry")

$ # Primul element - Capcană: index 0, nu 1!
$ echo "${fruits[0]}"
apple

$ # Greșeală comună:
$ echo "${fruits[1]}"
banana    # NU e primul!

$ # Toate elementele
$ echo "${fruits[@]}"
apple banana cherry

$ # Câte elemente?
$ echo "${#fruits[@]}"
3

$ # Adăugăm element
$ fruits+=("date")
$ echo "${fruits[@]}"
apple banana cherry date
```

---

### LC2.2: Problema Ghilimelelor (8 min)

**PASUL 1: Setup problema**
```bash
$ # Array cu elemente ce conțin spații
$ files=("file one.txt" "file two.txt" "document.pdf")

$ # Câte elemente?
$ echo "${#files[@]}"
3
```

**PASUL 2: Iterare GREȘITĂ**
```bash

*Notă personală: Mulți preferă `zsh`, dar eu rămân la Bash pentru că e standardul pe servere. Consistența bate confortul.*

$ # GREȘIT - fără ghilimele
$ for f in ${files[@]}; do
>     echo "-> $f"
> done
-> file
-> one.txt
-> file
-> two.txt
-> document.pdf

$ # 5 iterații în loc de 3! Ce s-a întâmplat?
$ # Word splitting a spart elementele la spații!
```

**PASUL 3: Iterare CORECTĂ**
```bash
$ # CORECT - cu ghilimele
$ for f in "${files[@]}"; do
>     echo "-> $f"
> done
-> file one.txt
-> file two.txt
-> document.pdf

$ # Exact 3 iterații, elementele intacte!
```

**📝 Pe tablă:**
```
┌────────────────────────────────────────────────┐
│  GREȘIT: for i in ${arr[@]}                    │
│  CORECT: for i in "${arr[@]}"                  │
│                                                │
│  Ghilimelele PROTEJEAZĂ de word splitting!     │
└────────────────────────────────────────────────┘
```

---

### LC2.3: Array Asociativ (7 min)

**PASUL 1: Greșeala (FĂRĂ declare -A)**
```bash
$ # Încercăm să creăm un "hash" fără declare -A
$ wrong[host]="localhost"
$ wrong[port]="8080"

$ echo "Host: ${wrong[host]}"
Host: 8080    # Ciudat...

$ echo "Chei: ${!wrong[@]}"
Chei: 0       # Doar un index numeric!

$ # Ce s-a întâmplat? Bash a interpretat host și port
$ # ca variabile (nedefinite = 0), deci ambele au scris la wrong[0]
```

**PASUL 2: Soluția (CU declare -A)**
```bash
$ declare -A config    # OBLIGATORIU!
$ config[host]="localhost"
$ config[port]="8080"

$ echo "Host: ${config[host]}"
Host: localhost

$ echo "Chei: ${!config[@]}"
Chei: host port

$ # Acum funcționează corect!
```

**PASUL 3: Iterare prin hash**
```bash
$ for key in "${!config[@]}"; do
>     echo "$key = ${config[$key]}"
> done
host = localhost
port = 8080
```

**📝 Pe tablă:**
```
┌─────────────────────────────────────────────┐
│  declare -A hash    # OBLIGATORIU!          │
│  hash[key]="value"                          │
│                                             │
│  ${hash[key]}       # acces valoare         │
│  ${!hash[@]}        # toate cheile          │
└─────────────────────────────────────────────┘
```

---

## Sesiunea 3: solidEȚE (20 minute)

### LC3.1: Demonstrație Script Fragil (5 min)

```bash
$ cat > fragil.sh << 'EOF'
#!/bin/bash
# Script FRAGIL - NU face asta!

cd "$1"
rm -rf temp/*
echo "Cleanup done in $1"
EOF

$ # Ce se întâmplă dacă $1 e gol sau directorul nu există?
$ ./fragil.sh ""
# rm -rf temp/* rulează în directorul CURENT!
# DEZASTRU!

$ ./fragil.sh /nonexistent
# cd eșuează SILENT, rm rulează în directorul curent!
```

---

### LC3.2: Adăugăm set -euo pipefail (10 min)

**PASUL 1: set -e**
```bash
$ cat > robust1.sh << 'EOF'
#!/bin/bash
set -e    # Exit la prima eroare

cd "$1"
rm -rf temp/*
echo "Cleanup done"
EOF

$ ./robust1.sh /nonexistent
# Script se oprește la cd (eroare)
# rm NU se execută - suntem în siguranță!
```

**PASUL 2: set -u**
```bash
$ cat > robust2.sh << 'EOF'
#!/bin/bash
set -eu    # + variabile nedefinite = eroare

echo "Processing: $UNDEFINED"
EOF

$ ./robust2.sh
# Eroare: UNDEFINED: unbound variable
# Detectăm typos în variabile!
```

**PASUL 3: pipefail**
```bash
$ # Fără pipefail
$ false | true
$ echo $?
0    # Eroarea de la false e IGNORATĂ!

$ # Cu pipefail

*(Pipe-urile sunt geniul Unix-ului. Combin comenzi simple pentru a rezolva probleme complexe.)*

$ set -o pipefail
$ false | true
$ echo $?
1    # Eroarea e propagată!
```

**PASUL 4: Combinația completă**
```bash
$ cat > robust.sh << 'EOF'
#!/bin/bash
set -euo pipefail    # Triada magică
IFS=$'\n\t'          # IFS sigur

# Acum scriptul e solid!
EOF
```

---

### LC3.3: ATENȚIE - Când set -e NU funcționează! (5 min)

```bash
$ cat > trap.sh << 'EOF'
#!/bin/bash
set -e

# SURPRIZĂ: set -e NU funcționează în if!
if false; then
    echo "În if"
fi
echo "Script continuă!"    # SE EXECUTĂ!

# Nici cu ||
false || echo "Rescued"
echo "Continuă!"           # SE EXECUTĂ!
EOF

$ ./trap.sh
Script continuă!
Rescued
Continuă!

$ # Concluzie: set -e are LIMITE!
$ # Nu te baza 100% pe el - verifică explicit erorile importante
```

---

## Sesiunea 4: TRAP și CLEANUP (10 minute)

### LC4.1: Trap EXIT pentru Cleanup

```bash
$ cat > cleanup.sh << 'EOF'
#!/bin/bash
set -euo pipefail

TEMP_FILE=""

cleanup() {
    echo "🧹 Cleanup executat!"
    [[ -n "$TEMP_FILE" && -f "$TEMP_FILE" ]] && rm -f "$TEMP_FILE"
}

trap cleanup EXIT    # Se execută ÎNTOTDEAUNA la ieșire

TEMP_FILE=$(mktemp)
echo "Lucrez cu: $TEMP_FILE"

# Simulăm eroare
echo "Acum va fi o eroare..."
false

echo "Aceasta nu se afișează"
EOF

$ ./cleanup.sh
Lucrez cu: /tmp/tmp.xxxxx
Acum va fi o eroare...
🧹 Cleanup executat!

$ # Observați: cleanup s-a executat DEȘI scriptul a eșuat!
$ # Fișierul temporar a fost șters automat
```

---

## Sesiunea 5: TEMPLATE WALKTHROUGH (10 minute)

### LC5.1: Construim Template-ul Pas cu Pas

```bash
$ cat > template.sh << 'EOF'
#!/bin/bash
#
# Script: template.sh
# Autor: [Nume]
# Versiune: 1.0.0
#

# === STRICT MODE ===
set -euo pipefail
IFS=$'\n\t'

# === CONSTANTE ===
readonly SCRIPT_NAME=$(basename "$0")

# === CONFIGURARE ===
VERBOSE="${VERBOSE:-0}"

# === HELPER FUNCTIONS ===
die() {
    echo "FATAL: $*" >&2
    exit 1
}

# === CLEANUP ===
cleanup() {
    local exit_code=$?
    # cleanup aici
    exit $exit_code
}
trap cleanup EXIT

# === MAIN ===
main() {
    echo "Hello from $SCRIPT_NAME!"
    [ $# -ge 1 ] || die "Usage: $SCRIPT_NAME <arg>"
    echo "Argument: $1"
}

main "$@"
EOF

$ chmod +x template.sh
$ ./template.sh
FATAL: Usage: template.sh <arg>

$ ./template.sh test
Hello from template.sh!
Argument: test
```

---

## Checklist Post-Live-Coding

### După fiecare secțiune, verifică:

- [ ] Studenții au copiat codul?
- [ ] Toți au obținut același output?
- [ ] Cineva are întrebări?
- [ ] Conceptul cheie e pe tablă/slide?

### Erori comune în timpul live coding:

| Situație | Soluție |
|----------|---------|
| Typo în cod | Folosește ca moment de debugging |
| Script nu rulează | Verifică `chmod +x` |
| Output diferit | Verifică versiunea Bash |
| Studenți rămân în urmă | Pauză, share cod prin chat |

---

## Scripturi Pre-preparate (Backup)

Dacă timpul e scurt, folosește scripturile din `scripts/demo/`:

```bash
./S05_02_demo_functions.sh    # Funcții
./S05_03_demo_arrays.sh       # Arrays
./S05_04_demo_robust.sh       # set -euo pipefail
./S05_05_demo_logging.sh      # Logging
./S05_06_demo_debug.sh        # Debugging
```

---

*Material de laborator pentru cursul de Sisteme de Operare | ASE București - CSIE*
