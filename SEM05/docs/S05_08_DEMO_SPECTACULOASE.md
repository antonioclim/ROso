# S05_08 - Demo-uri Spectaculoase: Impact Vizual Memorabil

> **Observație din laborator:** notează-ţi comenzi‑cheie şi output‑ul relevant (2–3 linii) pe măsură ce lucrezi. Te ajută la debug şi, sincer, la final îţi iese şi un README bun fără efort suplimentar.
> **Sisteme de Operare** | ASE București - CSIE  
> Seminar 5: Advanced Bash Scripting
> Versiune: 2.0.0 | Data: 2025-01

---

## Filosofia Demo-urilor Spectaculoase

Demo-urile spectaculoase au un scop pedagogic specific:
- **Creează momente memorabile** - studenții își amintesc emoția
- **Demonstrează consecințe** - "uite ce se poate întâmpla!"
- **Ancorează conceptele** - asociază teoria cu experiența
- **Motivează atenția** - "nu vreau să mi se întâmple și mie!"

### Principiul "Fragil vs solid"

Fiecare demo contrastează:
1. **FRAGIL** - ce poate merge rău
2. **solid** - cum facem corect

---

## Demo 1: DEZASTRUL rm -rf (Hook de Deschidere)

### Pregătire (înainte de seminar)

```bash
# Creează environment sandbox
mkdir -p ~/demo_disaster/{important_project,backup,temp}
echo "class User { ... }" > ~/demo_disaster/important_project/main.py
echo "def calculate() { ... }" > ~/demo_disaster/important_project/utils.py
echo "DATABASE_URL=..." > ~/demo_disaster/important_project/.env
tree ~/demo_disaster
```

### Script FRAGIL (demo_fragil.sh)

```bash
#!/bin/bash
# Script FRAGIL - NU FOLOSIȚI în producție!

cleanup_dir="$1"

echo "🧹 Cleaning up: $cleanup_dir"
cd $cleanup_dir
rm -rf *
echo "✓ Cleanup complete!"
```

### Demonstrație Live

```bash
# 1. Arată structura
$ tree ~/demo_disaster
demo_disaster/
├── important_project/
│   ├── main.py
│   ├── utils.py
│   └── .env
├── backup/
└── temp/

# 2. Întreabă clasa: "Ce se întâmplă dacă rulez cu director invalid?"

$ ./demo_fragil.sh /nonexistent/path
🧹 Cleaning up: /nonexistent/path
./demo_fragil.sh: line 6: cd: /nonexistent/path: No such file or directory
✓ Cleanup complete!

# 3. DRAMA: Verifică ce s-a întâmplat!
$ ls ~/demo_disaster
# TOTUL E GOL! cd a eșuat, rm a rulat în directorul curent!

# 4. Pauză dramatică... lasă să se scufunde informația
```

### Script solid

```bash
#!/bin/bash
set -euo pipefail

cleanup_dir="${1:?Error: Directory required}"

echo "🧹 Cleaning up: $cleanup_dir"

# Verificări EXPLICITE
[[ -d "$cleanup_dir" ]] || {
    echo "Error: Not a directory: $cleanup_dir" >&2
    exit 1
}

# Prevenim ștergerea root sau home
[[ "$cleanup_dir" == "/" || "$cleanup_dir" == "$HOME" ]] && {
    echo "Error: Refusing to clean $cleanup_dir" >&2
    exit 1
}

cd "$cleanup_dir" || exit 1
rm -rf ./*
echo "✓ Cleanup complete!"
```

### Lecție Cheie (pe tablă)

```
┌──────────────────────────────────────────────────┐
│  NICIODATĂ:                                      │
│  cd $dir; rm -rf *                               │
│                                                  │
│  ÎNTOTDEAUNA:                                    │
│  set -e + verificare director + path absolut    │
└──────────────────────────────────────────────────┘
```

---

## Demo 2: VARIABILA DISPĂRUTĂ

### Setup

```bash
#!/bin/bash
# mystery.sh - De ce nu funcționează?

total=0

echo "10
20
30" | while read num; do
    total=$((total + num))
    echo "Adding $num, total=$total"
done

echo "Final total: $total"
```

### Demonstrație

```bash

*(Bash-ul are o sintaxă urâtă, recunosc. Dar rulează peste tot, și asta contează enorm în practică.)*

$ ./mystery.sh
Adding 10, total=10
Adding 20, total=30
Adding 30, total=60
Final total: 0          # ???

# Întrebare: DE CE?!
```

### Explicație Vizuală

```
┌─────────────────────────────────────────────────────────┐
│  MAIN PROCESS                                           │

> 💡 Din experiența cu grupele din anii trecuți, am observat că studenții care exersează zilnic progresează semnificativ mai repede.

│  total=0                                                │
│  │                                                      │
│  ▼                                                      │
│  echo "..." ──PIPE──► ┌──────────────────────┐          │
│                       │ SUBSHELL (while)     │          │
│                       │ total=10             │          │
│                       │ total=30             │          │
│                       │ total=60             │          │
│                       └──────────────────────┘          │
│                              │                          │
│                              ▼                          │
│                         SUBSHELL DISPARE                │
│                         (total=60 pierdut!)             │
│  │                                                      │
│  ▼                                                      │
│  echo "Final total: $total"  ──► total=0 (original!)    │
└─────────────────────────────────────────────────────────┘
```

### Soluția: Process Substitution

```bash
#!/bin/bash

*Notă personală: Mulți preferă `zsh`, dar eu rămân la Bash pentru că e standardul pe servere. Consistența bate confortul.*

total=0

while read num; do
    total=$((total + num))
    echo "Adding $num, total=$total"
done < <(echo "10
20
30")

echo "Final total: $total"  # 60 - CORECT!
```

---

## Demo 3: THE QUOTING DISASTER

### Setup

```bash
# Creăm fișiere cu nume "ciudate"
mkdir -p ~/demo_quotes
touch ~/demo_quotes/"my file.txt"
touch ~/demo_quotes/"another file.txt"
touch ~/demo_quotes/"file with  two spaces.txt"
```

### Script FRAGIL

```bash
#!/bin/bash
# count_lines_bad.sh

total=0
for file in $(ls ~/demo_quotes); do
    lines=$(wc -l < "$file")
    total=$((total + lines))
    echo "Processed: $file"
done
echo "Total lines: $total"
```

### Demonstrație

```bash
$ ./count_lines_bad.sh
wc: my: No such file or directory
wc: file.txt: No such file or directory
wc: another: No such file or directory
...
# DEZASTRU!
```

### Vizualizare Word Splitting

```
Original:
  "my file.txt" "another file.txt"

După $(ls):
  my file.txt another file.txt

După word splitting:
  [my] [file.txt] [another] [file.txt]

Loop vede 4 "fișiere", nu 2!
```

### Script solid

```bash
#!/bin/bash
set -euo pipefail

total=0
for file in ~/demo_quotes/*; do
    [[ -f "$file" ]] || continue
    lines=$(wc -l < "$file")
    total=$((total + lines))
    echo "Processed: $file"
done
echo "Total lines: $total"
```

---

## Demo 4: CASCADA DE ERORI (pipefail)

### Setup

```bash
# Simulăm o pipeline de procesare date
```

### Script FRAGIL

```bash
#!/bin/bash
# Pipeline periculoasă

cat /etc/shadow |     # Probabil eșuează (no permission)
grep "root" |
cut -d: -f1 |
head -1

echo "Exit code: $?"
echo "SUCCESS! 🎉"
```

### Demonstrație

```bash
$ ./pipeline_bad.sh
cat: /etc/shadow: Permission denied
Exit code: 0
SUCCESS! 🎉

# WAT?! Script raportează SUCCESS deși cat a eșuat!
```

### Explicație Vizuală

```
Pipeline fără pipefail:
┌─────────┐    ┌──────┐    ┌─────┐    ┌──────┐
│ cat ❌  │───►│ grep │───►│ cut │───►│ head │
│ exit=1  │    │      │    │     │    │exit=0│
└─────────┘    └──────┘    └─────┘    └──────┘
                                          │
                            $? = 0 ◄──────┘
                            (doar ultimul!)

Pipeline CU pipefail:
┌─────────┐    ┌──────┐    ┌─────┐    ┌──────┐
│ cat ❌  │───►│ grep │───►│ cut │───►│ head │
│ exit=1  │    │      │    │     │    │      │
└─────────┘    └──────┘    └─────┘    └──────┘
      │
      $? = 1 (prima eroare!)
```

### Script solid

```bash
#!/bin/bash
set -euo pipefail

cat /etc/shadow |
grep "root" |
cut -d: -f1 |
head -1

echo "SUCCESS! 🎉"
```

```bash
$ ./pipeline_good.sh
cat: /etc/shadow: Permission denied
# Script se oprește, nu ajunge la SUCCESS
```

---

## Demo 5: ASOCIATIV vs INDEXAT

### Demo Vizual

```bash
#!/bin/bash

echo "═══ FĂRĂ declare -A ═══"
bad[host]="localhost"
bad[port]="8080"
echo "Setăm: host=localhost, port=8080"
echo "Rezultat:"
echo "  Chei: ${!bad[@]}"
echo "  Valori: ${bad[@]}"
echo ""

echo "═══ CU declare -A ═══"
declare -A good
good[host]="localhost"
good[port]="8080"
echo "Setăm: host=localhost, port=8080"
echo "Rezultat:"
echo "  Chei: ${!good[@]}"
echo "  Valori: ${good[@]}"
```

### Output

```
═══ FĂRĂ declare -A ═══
Setăm: host=localhost, port=8080
Rezultat:
  Chei: 0
  Valori: 8080

═══ CU declare -A ═══
Setăm: host=localhost, port=8080
Rezultat:
  Chei: host port
  Valori: localhost 8080
```

### Diagrama pe Tablă

```
FĂRĂ declare -A:          CU declare -A:
┌─────────┐               ┌─────────┬───────────┐
│ Index 0 │               │ "host"  │ localhost │
├─────────┤               ├─────────┼───────────┤
│ "8080"  │ ← suprascris! │ "port"  │ 8080      │
└─────────┘               └─────────┴───────────┘

host = $host = "" = 0
port = $port = "" = 0
Ambele scriu la index 0!
```

---

## Demo 6: TRAP MAGIC

### Demo: Script care "supraviețuiește" Ctrl+C

```bash
#!/bin/bash

echo "PID: $$"
echo "Încearcă să mă oprești cu Ctrl+C!"
echo ""

cleanup() {
    echo ""
    echo "🛡️ Ha! Am prins Ctrl+C!"
    echo "🧹 Fac cleanup..."
    sleep 1
    echo "✓ Cleanup complet. Acum pot pleca."
    exit 0
}

trap cleanup INT

count=0
while true; do
    ((count++))
    printf "\r⏱️ Running for $count seconds... "
    sleep 1
done
```

### Demonstrație

```bash
$ ./immortal.sh
PID: 12345
Încearcă să mă oprești cu Ctrl+C!

⏱️ Running for 5 seconds... ^C
🛡️ Ha! Am prins Ctrl+C!
🧹 Fac cleanup...
✓ Cleanup complet. Acum pot pleca.
```

---

## Demo 7: DEBUGGING LIVE

### Script cu Bug Ascuns

```bash
#!/bin/bash

process_file() {
    local file=$1
    local count=0
    
    while read line; do
        count=$((count + 1))
    done < "$file"
    
    echo $count
}

total=0
for f in *.txt; do
    n=$(process_file "$f")
    total=$((total + n))
done

echo "Total lines: $total"
```

### Activăm "X-Ray Vision"

```bash
$ PS4='+ ${BASH_SOURCE}:${LINENO}: ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
$ bash -x ./debug_demo.sh

+ ./debug_demo.sh:15: total=0
+ ./debug_demo.sh:16: for f in '*.txt'
+ ./debug_demo.sh:17: process_file file1.txt
+ ./debug_demo.sh:4: process_file(): local file=file1.txt
+ ./debug_demo.sh:5: process_file(): local count=0
+ ./debug_demo.sh:7: process_file(): read line
...
```

---

## Tips pentru Demo-uri Reușite

### Pregătire

- [ ] Testează fiecare demo înainte
- [ ] Pregătește "stări curate" pentru retry
- [ ] Ai backup-uri pentru fișierele șterse
- [ ] Font mare, contrast bun

### În timpul demo-ului

- [ ] Vorbește ce tastezi
- [ ] Pauze dramatice la momente cheie
- [ ] Întreabă "Ce credeți că se va întâmpla?"
- [ ] Lasă studenții să vadă eroarea ÎNAINTE de explicație

### După demo

- [ ] Recapitulează lecția cheie
- [ ] Scrie regula pe tablă
- [ ] Conectează cu următorul concept

---

## Scripturi Pre-făcute

Toate demo-urile sunt disponibile în:
```
scripts/demo/
├── S05_01_hook_demo.sh       # Fragil vs Robust
├── S05_02_demo_functions.sh  # Variabile locale
├── S05_03_demo_arrays.sh     # Arrays
├── S05_04_demo_robust.sh     # set -euo pipefail
├── S05_05_demo_logging.sh    # Logging
└── S05_06_demo_debug.sh      # Debugging
```

---

*Material de laborator pentru cursul de Sisteme de Operare | ASE București - CSIE*
