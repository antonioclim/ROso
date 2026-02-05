# S05 - Resurse și Referințe

> **Sisteme de Operare** | ASE București - CSIE  
> Seminar 5: Scripting Bash avansat

---

## Documentație Oficială

| Resursă | URL | Descriere |
|---------|-----|-----------|
| **Bash Manual** | https://www.gnu.org/software/bash/manual/ | Referința completă oficială |
| **Bash Reference** | https://www.gnu.org/software/bash/manual/bash.html | HTML navigabil |
| **POSIX Shell** | https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html | Standard POSIX |

---

## Instrumente

### ShellCheck - Linter pentru Bash

```bash
# Instalare
sudo apt install shellcheck      # Ubuntu/Debian
brew install shellcheck          # macOS

# Utilizare
shellcheck script.sh
shellcheck -f gcc script.sh      # Format GCC
shellcheck -x script.sh          # Urmărește source-uri
```

**Online:** https://www.shellcheck.net/

### Explainshell - Explică comenzi

**URL:** https://explainshell.com/

Paste orice comandă și primești explicație detaliată pentru fiecare parte.

---

## Tutoriale și Ghiduri

### Ghiduri de Stil

| Ghid | URL |
|------|-----|
| Google Shell Style Guide | https://google.github.io/styleguide/shellguide.html |
| Bash Best Practices | https://bertvv.github.io/cheat-sheets/Bash.html |
| Pure Bash Bible | https://github.com/dylanaraps/pure-bash-bible |

### Tutoriale Interactive

| Resursă | URL | Nivel |
|---------|-----|-------|
| Learn Shell | https://www.learnshell.org/ | Începător |
| Bash Academy | https://guide.bash.academy/ | Intermediar |
| Advanced Bash Guide | https://tldp.org/LDP/abs/html/ | Avansat |

---

## Video Resurse

### Canale YouTube Recomandate

- **Learn Linux TV** - Tutoriale practice Linux/Bash
- **NetworkChuck** - DevOps și scripting
- **The Linux Foundation** - Cursuri oficiale

### Cursuri Online

| Platformă | Curs | Durată |
|-----------|------|--------|
| Linux Foundation | Linux System Administration | 40h |
| Udemy | Bash Scripting and Shell Programming | 8h |
| Pluralsight | Bash Shell Scripting | 5h |

---

## Cheat Sheets

### Quick Reference

```bash
# === VARIABILE ===
var="value"                 # Atribuire (fără spații!)
echo "$var"                 # Expandare (cu ghilimele)
readonly CONST="value"      # Constantă
local var="value"           # Variabilă locală (în funcții)
export VAR="value"          # Variabilă de environment

# === DEFAULTS ===
${var:-default}             # Returnează default dacă var e gol/nesetat
${var:=default}             # Setează și returnează default
${var:+value}               # Returnează value dacă var e setat
${var:?error}               # Eroare dacă var e gol/nesetat

# === STRING OPERATIONS ===
${#var}                     # Lungime string
${var#pattern}              # Șterge pattern de la început (shortest)
${var##pattern}             # Șterge pattern de la început (longest)
${var%pattern}              # Șterge pattern de la final (shortest)
${var%%pattern}             # Șterge pattern de la final (longest)
${var/old/new}              # Înlocuiește prima apariție
${var//old/new}             # Înlocuiește toate aparițiile
${var:start:length}         # Substring

# === ARRAYS INDEXATE ===
arr=("a" "b" "c")           # Creare
${arr[0]}                   # Element (indexare de la 0!)
${arr[@]}                   # Toate elementele
${#arr[@]}                  # Număr elemente
${!arr[@]}                  # Toți indicii
arr+=("d")                  # Append
unset arr[1]                # Șterge element (NU reindexează!)

# === ARRAYS ASOCIATIVE ===
declare -A hash             # OBLIGATORIU!
hash[key]="value"           # Setare
${hash[key]}                # Acces
${!hash[@]}                 # Toate cheile
${hash[@]}                  # Toate valorile

# === ITERARE ===
for item in "${arr[@]}"; do echo "$item"; done    # Cu ghilimele!
for key in "${!hash[@]}"; do echo "$key=${hash[$key]}"; done
for ((i=0; i<10; i++)); do echo $i; done

# === FUNCȚII ===
func() {
    local var="value"       # ÎNTOTDEAUNA local!
    echo "$1"               # Primul argument
    return 0                # Exit code (doar 0-255!)
}
result=$(func "arg")        # Capturare output

# === CONDIȚII ===
[[ -f file ]]               # Fișier există
[[ -d dir ]]                # Director există
[[ -r file ]]               # Poate citi
[[ -w file ]]               # Poate scrie
[[ -x file ]]               # Poate executa
[[ -z "$var" ]]             # String gol
[[ -n "$var" ]]             # String non-gol
[[ "$a" == "$b" ]]          # Egalitate string
[[ "$a" =~ regex ]]         # Regex match
[[ $a -eq $b ]]             # Egalitate numerică
[[ $a -lt $b ]]             # Mai mic

# === solidEȚE ===
set -e                      # Exit la eroare
set -u                      # Eroare pentru variabile nedefinite
set -o pipefail             # Propagă erori în pipes
set -euo pipefail           # Toate trei

# === TRAP ===
trap cleanup EXIT           # La orice ieșire
trap 'handler $LINENO' ERR  # La eroare
trap 'echo INT' INT TERM    # La Ctrl+C

# === REDIRECT ===
cmd > file                  # Stdout în fișier
cmd >> file                 # Append stdout
cmd 2> file                 # Stderr în fișier
cmd &> file                 # Stdout și stderr
cmd 2>&1                    # Stderr la stdout
cmd < file                  # Stdin din fișier
cmd <<< "string"            # Here string
cmd << EOF                  # Here document
...
EOF

# === PIPES ȘI SUBSTITUTION ===
cmd1 | cmd2                 # Pipe
$(cmd)                      # Command substitution
<(cmd)                      # Process substitution (ca fișier)
```

---

## Debugging

### Opțiuni de Debug

```bash
set -x                      # Trace comenzi executate
set -v                      # Verbose - afișează linii citite
set -xv                     # Ambele

# Debug selectiv
set -x
# cod de debugat
set +x

# Din command line
bash -x script.sh           # Rulează cu trace
bash -n script.sh           # Syntax check (nu execută)
```

### Custom PS4

```bash
# PS4 controlează prefixul pentru trace
export PS4='+ ${BASH_SOURCE}:${LINENO}:${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
```

### Variabile Utile pentru Debug

```bash
$LINENO                     # Numărul liniei curente
$FUNCNAME                   # Numele funcției curente
${FUNCNAME[@]}              # Stack de funcții
$BASH_SOURCE                # Fișierul curent
${BASH_SOURCE[@]}           # Stack de fișiere
$BASH_COMMAND               # Comanda curentă
$PIPESTATUS                 # Exit codes din pipe
```

---

## Linkuri Utile

### Comunitate

- **Stack Overflow** - https://stackoverflow.com/questions/tagged/bash
- **Unix Stack Exchange** - https://unix.stackexchange.com/
- **Reddit r/bash** - https://www.reddit.com/r/bash/

### Repositories Utile

| Repo | URL | Descriere |
|------|-----|-----------|
| Bash-it | https://github.com/Bash-it/bash-it | Framework de customizare |
| Oh My Bash | https://github.com/ohmybash/oh-my-bash | Themes și plugins |
| Awesome Bash | https://github.com/awesome-lists/awesome-bash | Lista de resurse |

---

## Playground Online

| Tool | URL | Caracteristici |
|------|-----|----------------|
| Replit | https://replit.com/ | IDE complet online |
| JDoodle | https://www.jdoodle.com/test-bash-shell-script-online | Simplu, rapid |
| OnlineGDB | https://www.onlinegdb.com/online_bash_shell | Cu debugger |

---

## Standardizare și Portabilitate

### POSIX vs Bash-isme

| Feature | POSIX | Bash |
|---------|-------|------|
| Shebang | `#!/bin/sh` | `#!/bin/bash` |
| Test | `[ ]` | `[[ ]]` (recomandat) |
| Arrays | ❌ | ✅ |
| Associative arrays | ❌ | ✅ (4.0+) |
| `local` | ❌ (unele shell-uri) | ✅ |
| `[[ =~ ]]` | ❌ | ✅ (regex) |
| Process substitution | ❌ | ✅ `<()` |
| Here string | ❌ | ✅ `<<<` |

### Verificare Versiune Bash

```bash
# Versiune
echo $BASH_VERSION

# Verificare feature
if ((BASH_VERSINFO[0] >= 4)); then
    echo "Bash 4+ features available"
fi
```

---

## Instalare Bash Modern (dacă e necesar)

### Ubuntu/Debian

```bash
sudo apt update
sudo apt install bash
```

### macOS (Bash 5)

```bash
brew install bash
# Adaugă în /etc/shells și schimbă cu chsh
```

### Din Sursă

```bash
wget https://ftp.gnu.org/gnu/bash/bash-5.2.tar.gz
tar xzf bash-5.2.tar.gz
cd bash-5.2
./configure && make && sudo make install
```

---

*Material pentru cursul de Sisteme de Operare | ASE București - CSIE*
