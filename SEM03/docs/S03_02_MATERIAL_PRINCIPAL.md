# Material Principal: Utilitare, Scripturi, Permisiuni, Automatizare
## Sisteme de Operare | ASE București - CSIE

> Seminar 3 | Material teoretic complet cu Subgoal Labels  
> Versiune: 1.0 | Data: Ianuarie 2025

---

## Obiective de Învățare

La finalul acestui material, vei putea:

| Nivel Bloom | Obiectiv |
|-------------|----------|
| 🔵 Remember | Enumera opțiunile principale ale comenzilor find, chmod, crontab |
| 🟢 Understand | Explica diferența între $@ și $*, între find -exec și xargs |
| 🟡 Apply | Construi comenzi find complexe și scripturi cu getopts |
| 🟠 Analyze | Depana probleme cu permisiuni și cron jobs |
| 🔴 Evaluate | Critica și îmbunătăți comenzi și scripturi |
| 🟣 Create | Dezvolta soluții complete de automatizare |

---

## Cuprins

1. [Modulul 1: Utilitare Avansate de Căutare](#modulul-1-utilitare-avansate-de-căutare)
2. [Modulul 2: Parametri și Opțiuni în Scripturi](#modulul-2-parametri-și-opțiuni-în-scripturi)
3. [Modulul 3: Sistemul de Permisiuni Unix](#modulul-3-sistemul-de-permisiuni-unix)
4. [Modulul 4: Automatizare cu Cron](#modulul-4-automatizare-cu-cron)
5. [Rezumat și Cheat Sheet Extins](#-rezumat-și-cheat-sheet-extins)

---

# MODULUL 1: UTILITARE AVANSATE DE CĂUTARE

## 1.1 Comanda find - Introducere

### SUBGOAL 1.1.1: Înțelege structura comenzii find

Comanda `find` este unul dintre cele mai puternice utilitare Unix pentru căutarea fișierelor. Spre deosebire de `ls` care afișează conținutul unui director, `find` parcurge **recursiv** întreaga ierarhie de directoare.

Sintaxa generală:
```
find [cale_start] [expresii/teste] [acțiuni]
```

Componente:

| Componentă | Descriere | Exemple |
|------------|-----------|---------|
| `cale_start` | De unde începe căutarea | `.`, `/home`, `/var/log` |
| `expresii` | Criterii de filtrare | `-name`, `-type`, `-size` |
| `acțiuni` | Ce să facă cu rezultatele | `-print`, `-exec`, `-delete` |

Exemple de bază:
```bash
# Căutare în directorul curent
find . -name "*.txt"

# Căutare în mai multe locații
find /home /var -name "*.log"

# Căutare în tot sistemul (suprimă erori de permisiuni)
find / -name "config.ini" 2>/dev/null
```

---

## 1.2 find - Teste de Bază

### SUBGOAL 1.2.1: Caută după nume

Opțiunile pentru nume:

| Opțiune | Descriere | Exemplu |
|---------|-----------|---------|
| `-name` | Potrivire exactă (case-sensitive) | `-name "README.md"` |
| `-iname` | Potrivire case-insensitive | `-iname "readme.md"` |
| `-path` | Potrivire pe calea completă | `-path "*src/*.c"` |
| `-regex` | Expresie regulată | `-regex ".*\\.txt$"` |

Wildcards acceptate în -name:

| Pattern | Semnificație | Exemplu |
|---------|--------------|---------|
| `*` | Oricâte caractere | `*.txt` |
| `?` | Exact un caracter | `file?.txt` |
| `[...]` | Un caracter din set | `[abc].txt` |
| `[!...]` | Un caracter care NU e în set | `[!0-9].txt` |

```bash
# Exemple practice
find . -name "*.txt"           # Toate fișierele .txt
find . -name "data_*"          # Începe cu "data_"
find . -name "*backup*"        # Conține "backup"
find . -iname "README*"        # Case-insensitive

# Caută în căi specifice
find . -path "*/src/*.c"       # Fișiere .c în orice director src/
find . -path "*/test/*" -name "*.py"  # .py în directoare test/
```

### SUBGOAL 1.2.2: Caută după tip

Tipuri de fișiere în Unix:

| Flag | Tip | Descriere |
|------|-----|-----------|
| `f` | File | Fișier obișnuit |
| `d` | Directory | Director |
| `l` | Symbolic link | Link simbolic |
| `b` | Block device | Dispozitiv bloc (disk) |
| `c` | Character device | Dispozitiv caracter (terminal) |
| `p` | Named pipe | FIFO |
| `s` | Socket | Socket Unix |

```bash
# Exemple
find . -type f              # Doar fișiere
find . -type d              # Doar directoare
find . -type l              # Doar symlinks

# Combinații frecvente
find . -type f -name "*.sh"  # Scripturi shell (fișiere, nu directoare)
find . -type d -name "test*" # Directoare care încep cu "test"
```

---

## 1.3 find - Teste Avansate

### SUBGOAL 1.3.1: Caută după dimensiune

Sintaxa: `-size [+-]N[cwbkMG]`

| Sufix | Unitate | Echivalent |
|-------|---------|------------|
| `c` | bytes | 1 byte |
| `w` | words | 2 bytes |
| `b` | blocks | 512 bytes (default) |
| `k` | kilobytes | 1024 bytes |
| `M` | megabytes | 1048576 bytes |
| `G` | gigabytes | 1073741824 bytes |

| Prefix | Semnificație |
|--------|--------------|
| (nimic) | Exact acea dimensiune |
| `+` | Mai mare decât |
| `-` | Mai mic decât |

```bash
# Exemple
find . -size 100c        # Exact 100 bytes
find . -size +10M        # Mai mare de 10 MB
find . -size -1k         # Mai mic de 1 KB
find . -size +1G         # Mai mare de 1 GB

# Range de dimensiuni
find . -size +10M -size -100M   # Între 10 și 100 MB

# Fișiere goale
find . -empty                    # Fișiere sau directoare goale

*(`find` combinat cu `-exec` e extrem de util. Odată ce-l stăpânești, nu mai poți fără el.)*

find . -type f -empty            # Doar fișiere goale
find . -type d -empty            # Doar directoare goale
```

### SUBGOAL 1.3.2: Caută după timp

Tipuri de timestamp în Unix:

| Timestamp | Descriere | Actualizat când |
|-----------|-----------|-----------------|
| `mtime` | Modification time | Conținutul se schimbă |
| `atime` | Access time | Fișierul e citit |
| `ctime` | Change time | Metadata se schimbă (permisiuni, owner) |

Opțiuni pentru timp:

| Opțiune | Unitate | Exemplu |
|---------|---------|---------|
| `-mtime N` | Zile | `-mtime -7` (ultimele 7 zile) |
| `-mmin N` | Minute | `-mmin -60` (ultima oră) |
| `-atime N` | Zile (access) | `-atime +30` (neaccesat > 30 zile) |
| `-amin N` | Minute (access) | `-amin -10` |
| `-ctime N` | Zile (change) | `-ctime 0` (azi) |
| `-newer FILE` | Comparație | Mai nou ca FILE |

```bash
# Exemple
find . -mtime 0          # Modificate în ultimele 24h
find . -mtime -7         # Modificate în ultimele 7 zile
find . -mtime +30        # Modificate acum mai mult de 30 zile
find . -mmin -60         # Modificate în ultima oră
find . -newer reference.txt  # Mai noi decât reference.txt

# Combinații practice
find /var/log -name "*.log" -mtime +30  # Log-uri vechi
find . -type f -mmin -5                  # Modificări recente
```

### SUBGOAL 1.3.3: Caută după permisiuni și owner

```bash
# După permisiuni exacte
find . -perm 644          # Exact 644 (rw-r--r--)
find . -perm 755          # Exact 755 (rwxr-xr-x)

# După permisiuni minime (toți biții specificați trebuie setați)
find . -perm -644         # Cel puțin rw-r--r--
find . -perm -u+x         # Owner are execute

# După oricare din biți (cel puțin unul setat)
find . -perm /644         # Owner: rw SAU group: r SAU others: r
find . -perm /u+x,g+x     # Owner SAU group are execute

# După owner
find . -user student      # Fișiere ale utilizatorului "student"
find . -group developers  # Fișiere ale grupului "developers"
find . -nouser            # Fișiere fără owner valid (UID șters)
find . -nogroup           # Fișiere fără group valid
```

---

## 1.4 find - Operatori Logici

### SUBGOAL 1.4.1: Combină condiții cu AND, OR, NOT

Operatori:

| Operator | Sintaxă | Descriere |
|----------|---------|-----------|
| AND | (implicit) sau `-a` | Ambele condiții true |
| OR | `-o` | Cel puțin una true |
| NOT | `!` sau `-not` | Negație |
| Grupare | `\( ... \)` | Prioritate |

```bash
# AND implicit
find . -type f -name "*.txt"      # fișier ȘI .txt

# OR explicit (necesită paranteze de regulă)
find . -name "*.txt" -o -name "*.md"
find . \( -name "*.c" -o -name "*.h" \)  # Corecte parantezele

# NOT
find . ! -name "*.txt"            # NU are extensia .txt
find . -type f ! -name "*.bak"    # Fișiere care NU sunt backup

# Combinații complexe
find . -type f \( -name "*.txt" -o -name "*.md" \) ! -name "*backup*"
# Explicație: fișiere .txt sau .md, DAR nu cele cu "backup" în nume
```

**⚠️ Atenție la precedență:**
```bash
# GREȘIT - OR are precedență mai mică
find . -type f -name "*.txt" -o -name "*.md"
# Interpretare: (type f AND name *.txt) OR (name *.md)
# Rezultat: poate returna și DIRECTOARE .md!

# CORECT
find . -type f \( -name "*.txt" -o -name "*.md" \)
```

---

## 1.5 find - Acțiuni

### SUBGOAL 1.5.1: -print și variante

```bash
# -print (default)
find . -name "*.txt" -print       # Afișează căile

# -print0 (pentru xargs -0)
find . -name "*.txt" -print0      # Delimitator NULL (pentru spații)

# -printf (format personalizat)
find . -name "*.txt" -printf "%p %s bytes\n"    # Cale și dimensiune
find . -name "*.txt" -printf "%f\n"              # Doar numele
find . -type f -printf "%m %u %p\n"              # Permisiuni, owner, cale

# Formate printf utile:
# %p = cale completă
# %f = doar numele fișierului
# %s = dimensiune în bytes
# %m = permisiuni octal
# %M = permisiuni simbolice
# %u = owner (nume)
# %g = group (nume)
# %T+ = timestamp modificare
```

### SUBGOAL 1.5.2: -exec și -ok

-exec execută o comandă pentru fiecare fișier găsit.

Sintaxa:
```
-exec comandă {} \;    # Execută pentru FIECARE fișier (un proces per fișier)
-exec comandă {} +     # Execută O DATĂ cu toate fișierele ca argumente
```

```bash
# Cu \; - execuție individuală
find . -name "*.txt" -exec cat {} \;
find . -name "*.sh" -exec chmod +x {} \;

# Cu + - execuție batch (mai eficient)
find . -name "*.txt" -exec cat {} +
find . -name "*.log" -exec wc -l {} +

# -ok - ca -exec dar cu confirmare
find . -name "*.bak" -ok rm {} \;
# Întreabă pentru FIECARE fișier: "rm ... ?"
```

Comparație performanță:
```bash
# Lent (100 fișiere = 100 procese cat)
find . -name "*.txt" -exec cat {} \;

# Rapid (100 fișiere = 1 proces cat cu 100 argumente)
find . -name "*.txt" -exec cat {} +
```

### SUBGOAL 1.5.3: -delete

```bash
# Capcană: -delete este permanent și irecuperabil!

# CORECT: testează întâi cu -print
find . -name "*.tmp" -print          # Vezi ce va șterge
find . -name "*.tmp" -delete         # Apoi șterge

# GREȘIT: rulezi direct -delete fără verificare
find . -name "*.log" -delete         # Periculos!

# Combinație sigură cu confirmare
find . -name "*.bak" -ok rm -v {} \;
```

---

## 1.6 xargs - Procesare Batch

### SUBGOAL 1.6.1: De ce xargs?

Problema: Shell-ul are limite pentru lungimea liniei de comandă. Cu foarte multe fișiere, `find -exec` cu `+` poate eșua.

Soluția: `xargs` citește din stdin și construiește comenzi eficient.

```bash
# Diferența conceptuală
echo "file1 file2 file3" | cat       # cat citește STDIN
echo "file1 file2 file3" | xargs cat # cat file1 file2 file3
```

### SUBGOAL 1.6.2: Sintaxă și opțiuni xargs

| Opțiune | Descriere | Exemplu |
|---------|-----------|---------|
| `-n N` | Maximum N argumente per execuție | `xargs -n 2` |
| `-I{}` | Placeholder personalizat | `xargs -I{} cp {} backup/` |
| `-0` | Delimitator NULL (pentru -print0) | `xargs -0` |
| `-P N` | Execuție paralelă (N procese) | `xargs -P 4` |
| `-t` | Afișează comanda înainte de execuție | `xargs -t` |
| `-p` | Cere confirmare | `xargs -p` |

```bash
# Limitare argumente
echo "1 2 3 4 5 6" | xargs -n 2 echo
# Output:
# 1 2
# 3 4
# 5 6

# Placeholder
find . -name "*.txt" | xargs -I{} cp {} backup/
find . -name "*.jpg" | xargs -I FILE convert FILE FILE.png

# Execuție paralelă (4 procese simultan)
find . -name "*.jpg" | xargs -P 4 -I{} convert {} {}.png

# Verbose (afișează comanda)
find . -name "*.tmp" | xargs -t rm

# Cu confirmare
find . -name "*.bak" | xargs -p rm
```

### SUBGOAL 1.6.3: Combinații find | xargs

⚠️ Problema spațiilor în nume de fișiere:

```bash
# GREȘIT - se strică cu spații
touch "fisier cu spatii.txt"
find . -name "*.txt" | xargs rm
# xargs interpretează: rm "fisier" "cu" "spatii.txt"
# Eroare: fișierele nu există!

# CORECT - folosește -print0 și -0
find . -name "*.txt" -print0 | xargs -0 rm
# -print0: separă cu NULL în loc de newline
# -0: xargs citește cu delimitator NULL
```

Pattern-uri comune:
```bash
# Numără linii în fișiere
find . -name "*.py" | xargs wc -l

# Caută pattern în cod
find . -name "*.c" -print0 | xargs -0 grep "main"

# Arhivează fișiere
find . -name "*.log" -mtime +30 | xargs tar -cvf old_logs.tar

# Procesare paralelă
find . -name "*.mp4" -print0 | xargs -0 -P 4 -I{} ffmpeg -i {} {}.mp3
```

---

## 1.7 locate - Căutare Rapidă

### SUBGOAL 1.7.1: Înțelege diferența locate vs find

| Aspect | locate | find |
|--------|--------|------|
| Viteză | Foarte rapid (milisecunde) | Mai lent (parcurge disk) |
| Actualizare | Database pre-indexată | Timp real |
| Criterii | Doar nume/cale | Multiple (size, time, perm) |
| Acțiuni | Doar afișare | exec, delete, etc. |

```bash
# Utilizare locate
locate filename              # Caută în baza de date
locate -i README             # Case-insensitive
locate -n 10 "*.log"         # Primele 10 rezultate
locate -c "*.txt"            # Numără potrivirile

# Actualizare bază de date (necesită root)
sudo updatedb

# Când folosești locate vs find?
# locate: căutări rapide după nume când nu-ți pasă de fișiere noi
# find: căutări complexe, fișiere recente, acțiuni automate
```

---

# MODULUL 2: PARAMETRI ȘI OPȚIUNI ÎN SCRIPTURI

## 2.1 Parametri Poziționali

### SUBGOAL 2.1.1: Variabilele de bază

Variabile speciale pentru argumente:

| Variabilă | Descriere | Exemplu |
|-----------|-----------|---------|
| `$0` | Numele scriptului | `./script.sh` |
| `$1` - `$9` | Argumentele 1-9 | `$1` = primul argument |
| `${10}` | Argumentul 10+ | Necesită acolade! |
| `$#` | Numărul de argumente | 3 dacă ai 3 argumente |
| `$@` | Toate argumentele (ca listă) | Iterare în for |
| `$*` | Toate argumentele (ca string) | Un singur string |
| `$?` | Exit code ultima comandă | 0 = succes |
| `$$` | PID-ul procesului curent | Pentru fișiere temporare |

```bash
#!/bin/bash
# demo_params.sh

echo "Numele scriptului: $0"
echo "Primul argument: $1"
echo "Al doilea argument: $2"
echo "Numărul total: $#"
echo "Toate (listă): $@"
echo "Toate (string): $*"

# Rulare: ./demo_params.sh arg1 arg2 arg3
```

### SUBGOAL 2.1.2: $@ vs $* - diferența crucială

Aceasta este una dintre cele mai frecvente surse de bug-uri!

```bash
#!/bin/bash
# test_at_vs_star.sh

echo "=== Cu \"\$@\" (CORECT pentru iterare) ==="
for arg in "$@"; do
    echo "Argument: '$arg'"
done

echo ""
echo "=== Cu \"\$*\" (un singur string) ==="
for arg in "$*"; do
    echo "Argument: '$arg'"
done
```

Rulare:
```bash
./test_at_vs_star.sh "hello world" test

# Output:
# === Cu "$@" (CORECT pentru iterare) ===
# Argument: 'hello world'
# Argument: 'test'
#
# === Cu "$*" (un singur string) ===
# Argument: 'hello world test'
```

Regula de aur: Folosește întotdeauna `"$@"` pentru a itera prin argumente!

### SUBGOAL 2.1.3: Argumente peste 9

```bash
#!/bin/bash
# Accesarea argumentului 10+

echo "Arg 1: $1"
echo "Arg 10: ${10}"    # CORECT - cu acolade
echo "Arg 10: $10"      # GREȘIT - afișează $1 urmat de "0"!
```

---

## 2.2 shift - Procesare Iterativă

### SUBGOAL 2.2.1: Înțelege și folosește shift

`shift` elimină primul argument și mută toate celelalte cu o poziție.

```bash
#!/bin/bash
# demo_shift.sh

echo "Înainte de shift:"
echo "  \$1 = $1"
echo "  \$2 = $2"
echo "  \$# = $#"

shift

echo "După shift:"
echo "  \$1 = $1"    # fostul $2
echo "  \$2 = $2"    # fostul $3
echo "  \$# = $#"    # decrementat cu 1

# Rulare: ./demo_shift.sh a b c
```

Pattern clasic - procesează toate argumentele:
```bash
#!/bin/bash
echo "Procesez $# argumente:"

while [ $# -gt 0 ]; do
    echo "  Argument: $1"
    shift
done

echo "Gata! Mai sunt $# argumente."
```

shift cu număr:
```bash
shift 2    # Elimină primele 2 argumente
shift 3    # Elimină primele 3
```

---

## 2.3 Valori Implicite

### SUBGOAL 2.3.1: Expansiuni cu default

| Sintaxă | Descriere | Rezultat |
|---------|-----------|----------|
| `${VAR:-default}` | Folosește default dacă VAR e gol/unset | Nu modifică VAR |
| `${VAR:=default}` | Setează VAR la default dacă e gol/unset | Modifică VAR |
| `${VAR:+alt}` | Folosește alt dacă VAR e setat | - |
| `${VAR:?mesaj}` | Eroare dacă VAR e gol/unset | Exit cu mesaj |

```bash
#!/bin/bash
# Argumente cu valori implicite

INPUT="${1:-input.txt}"      # Default: input.txt
OUTPUT="${2:-output.txt}"    # Default: output.txt
COUNT="${3:-10}"             # Default: 10

echo "Input: $INPUT"
echo "Output: $OUTPUT"
echo "Count: $COUNT"

# Rulare fără argumente: folosește defaults
# Rulare cu argumente: folosește valorile date
```

---

## 2.4 getopts - Opțiuni Scurte

### SUBGOAL 2.4.1: Sintaxa getopts

```bash
while getopts "optstring" variable; do
    case $variable in
        ...
    esac
done
```

optstring:
- `a` = opțiunea `-a` fără argument
- `a:` = opțiunea `-a` CU argument obligatoriu
- `:` la început = silent error mode

### SUBGOAL 2.4.2: OPTARG și OPTIND

| Variabilă | Descriere |
|-----------|-----------|
| `$opt` | Litera opțiunii curente |
| `$OPTARG` | Valoarea argumentului opțiunii |
| `$OPTIND` | Indexul următorului argument de procesat |

```bash
#!/bin/bash
# script_getopts.sh

VERBOSE=false
OUTPUT=""
COUNT=1

usage() {
    echo "Utilizare: $0 [-h] [-v] [-o FILE] [-c NUM] file..."
    exit 1
}

while getopts ":hvo:c:" opt; do
    case $opt in
        h) usage ;;
        v) VERBOSE=true ;;
        o) OUTPUT="$OPTARG" ;;
        c) COUNT="$OPTARG" ;;
        :) echo "Eroare: -$OPTARG necesită argument"; exit 1 ;;
        \?) echo "Eroare: opțiune necunoscută -$OPTARG"; exit 1 ;;
    esac
done

# Elimină opțiunile procesate
shift $((OPTIND - 1))

# Acum $@ conține doar argumentele poziționale rămase
echo "Verbose: $VERBOSE"
echo "Output: $OUTPUT"
echo "Count: $COUNT"
echo "Files: $@"
```

---

## 2.5 Opțiuni Lungi - Parsare Manuală

### SUBGOAL 2.5.1: Pattern pentru --option

`getopts` nu suportă opțiuni lungi (`--help`). Folosim `while` și `case`:

```bash
#!/bin/bash
# script_long_opts.sh

VERBOSE=false
OUTPUT=""

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
        --output=*)
            OUTPUT="${1#*=}"    # Extrage valoarea după =
            shift
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

# $@ conține argumentele rămase
```

---

## 2.6 Best Practices pentru CLI

### SUBGOAL 2.6.1: Template script profesional

```bash
#!/bin/bash
set -euo pipefail

readonly VERSION="1.0"
readonly SCRIPT_NAME=$(basename "$0")

# Valori default
VERBOSE=false
DRY_RUN=false
OUTPUT=""

usage() {
    cat << EOF
$SCRIPT_NAME v$VERSION - Descriere scurtă

Utilizare: $SCRIPT_NAME [opțiuni] <input>

Opțiuni:
    -h, --help      Afișează acest ajutor
    -V, --version   Afișează versiunea
    -v, --verbose   Mod verbose
    -n, --dry-run   Simulare (nu execută acțiuni)
    -o, --output    Fișier output

Exemple:
    $SCRIPT_NAME -v input.txt
    $SCRIPT_NAME --output=result.txt data.csv
EOF
    exit 1
}

log() { $VERBOSE && echo "[INFO] $*" >&2; }
error() { echo "[EROARE] $*" >&2; exit 1; }
warn() { echo "[WARN] $*" >&2; }

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help) usage ;;
            -V|--version) echo "$VERSION"; exit 0 ;;
            -v|--verbose) VERBOSE=true; shift ;;
            -n|--dry-run) DRY_RUN=true; shift ;;
            -o|--output) OUTPUT="$2"; shift 2 ;;
            --output=*) OUTPUT="${1#*=}"; shift ;;
            --) shift; break ;;
            -*) error "Opțiune necunoscută: $1" ;;
            *) break ;;
        esac
    done
    
    [[ $# -ge 1 ]] || error "Lipsește argumentul input"
    INPUT="$1"
}

main() {
    parse_args "$@"
    
    log "Procesez: $INPUT"
    log "Output: ${OUTPUT:-stdout}"
    
    # Logica principală aici
    if $DRY_RUN; then
        echo "[DRY-RUN] Ar procesa $INPUT"
    else
        # Procesare reală
        cat "$INPUT"
    fi
}

main "$@"
```

---

# MODULUL 3: SISTEMUL DE PERMISIUNI UNIX

## 3.1 Fundamentele Permisiunilor

### SUBGOAL 3.1.1: Structura rwx

```
-rwxr-xr--  1 user group  4096 Jan 10 12:00 fisier.txt
│└┬┘└┬┘└┬┘
│ │  │  └── Permisiuni others: r-- (read only)
│ │  └── Permisiuni group: r-x (read + execute)
│ └── Permisiuni owner: rwx (full)
└── Tip: - fișier, d director, l symlink
```

Semnificația pe fișiere:

| Permisiune | Literă | Octal | Efect pe FIȘIER |
|------------|--------|-------|-----------------|
| Read | r | 4 | Poate citi conținutul |
| Write | w | 2 | Poate modifica conținutul |
| Execute | x | 1 | Poate rula ca program |

### SUBGOAL 3.1.2: Semnificația pe fișiere vs directoare

⚠️ Capcană: x pe director NU înseamnă "executare"!

| Permisiune | Pe FIȘIER | Pe DIRECTOR |
|------------|-----------|-------------|
| r (read) | Citește conținutul | Poate lista cu `ls` |
| w (write) | Modifică conținutul | Poate crea/șterge fișiere |
| x (execute) | Rulează ca program | Poate accesa cu `cd` |

```bash
# Exemplu practic
mkdir test_dir
chmod 700 test_dir      # rwx------

chmod 600 test_dir      # rw------- (fără x)
cd test_dir             # EROARE: Permission denied
ls test_dir             # Funcționează (are r)

chmod 100 test_dir      # --x------
cd test_dir             # Funcționează (are x)
ls                      # EROARE: nu are r
cat test_dir/file.txt   # Funcționează dacă știi numele exact!
```

---

## 3.2 chmod - Modul Octal

### SUBGOAL 3.2.1: Calculul octal

```
r = 4 (read)
w = 2 (write)
x = 1 (execute)

Exemple:
rwx = 4+2+1 = 7
rw- = 4+2+0 = 6
r-x = 4+0+1 = 5
r-- = 4+0+0 = 4
--- = 0+0+0 = 0
```

Permisiuni comune:

| Octal | Simbolic | Utilizare |
|-------|----------|-----------|
| 755 | rwxr-xr-x | Scripturi, directoare publice |
| 644 | rw-r--r-- | Fișiere normale (documente) |
| 700 | rwx------ | Director privat |
| 600 | rw------- | Fișier privat (chei SSH) |
| 777 | rwxrwxrwx | ⚠️ EVITĂ! Vulnerabilitate |

```bash
chmod 755 script.sh     # Executabil de toți
chmod 644 document.txt  # Citibil de toți, editabil de owner
chmod 600 ~/.ssh/id_rsa # Cheie privată - doar owner
chmod 700 ~/private/    # Director privat
```

---

## 3.3 chmod - Modul Simbolic

### SUBGOAL 3.3.1: Operatori +, -, =

| Categorie | Literă |
|-----------|--------|
| Owner | u |
| Group | g |
| Others | o |
| All | a |

| Operator | Efect |
|----------|-------|
| + | Adaugă permisiune |
| - | Elimină permisiune |
| = | Setează exact |

```bash
chmod u+x script.sh         # Owner +execute
chmod g-w file.txt          # Group -write
chmod o=r file.txt          # Others = doar read
chmod a+r file.txt          # Toți +read
chmod u=rwx,g=rx,o=r f.txt  # Setare completă
chmod go-rwx private.txt    # Elimină tot pentru group și others
```

### SUBGOAL 3.3.2: chmod recursiv

```bash
chmod -R 755 director/      # Recursiv

# PROBLEMĂ: 755 pe fișiere le face executabile!

# SOLUȚIE: X (majusculă) = execute doar pentru directoare
chmod -R u=rwX,g=rX,o=rX director/

# Sau mai explicit:
find director/ -type d -exec chmod 755 {} \;
find director/ -type f -exec chmod 644 {} \;
```

---

## 3.4 Ownership - chown și chgrp

```bash
# Schimbă owner
sudo chown john file.txt

# Schimbă owner și group
sudo chown john:developers file.txt

# Doar group
sudo chown :developers file.txt
# sau
chgrp developers file.txt

# Recursiv
sudo chown -R john:developers project/

# Copiază ownership de la alt fișier
sudo chown --reference=model.txt target.txt
```

---

## 3.5 umask - Permisiuni Default

### SUBGOAL 3.5.1: Cum funcționează umask

⚠️ umask ELIMINĂ biți, nu setează!

```
Default pentru fișiere noi: 666 (rw-rw-rw-)
Default pentru directoare noi: 777 (rwxrwxrwx)

Permisiuni finale = Default - umask

Exemple cu umask 022:
  Fișiere: 666 - 022 = 644 (rw-r--r--)
  Directoare: 777 - 022 = 755 (rwxr-xr-x)

Exemple cu umask 077:
  Fișiere: 666 - 077 = 600 (rw-------)
  Directoare: 777 - 077 = 700 (rwx------)
```

```bash
umask              # Afișează valoarea curentă
umask -S           # Afișează simbolic
umask 022          # Setează (temporar)

# Permanent - adaugă în ~/.bashrc
echo "umask 022" >> ~/.bashrc
```

---

## 3.6 Permisiuni Speciale

### SUBGOAL 3.6.1: SUID (4xxx)

Fișierul se execută cu permisiunile owner-ului, nu ale celui care îl rulează.

```bash
ls -l /usr/bin/passwd
# -rwsr-xr-x 1 root root ... /usr/bin/passwd
# ^-- 's' în loc de 'x'

# De ce? passwd trebuie să modifice /etc/shadow (owned by root)
# Oricine poate rula passwd, dar procesul are permisiunile lui root

chmod u+s program    # Setează SUID
chmod 4755 program   # Octal: 4 + 755
```

### SUBGOAL 3.6.2: SGID (2xxx)

Pe fișiere: Se execută cu permisiunile grupului.

Pe directoare: Fișierele noi moștenesc grupul directorului (nu al creatorului).

```bash
# Setup director shared pentru echipă
sudo mkdir /projects/team1
sudo chgrp developers /projects/team1
sudo chmod 2775 /projects/team1

# Acum, orice fișier creat în /projects/team1
# va aparține automat grupului "developers"
```

### SUBGOAL 3.6.3: Sticky Bit (1xxx)

Pe directoare: Doar owner-ul unui fișier poate să-l șteargă, chiar dacă directorul e writable de toți.

```bash
ls -ld /tmp
# drwxrwxrwt 15 root root ... /tmp
# ^-- 't' în loc de 'x'

# Toți pot crea fișiere în /tmp
# Dar fiecare poate șterge DOAR fișierele proprii

chmod +t directory    # Setează sticky
chmod 1777 directory  # Octal
```

---

## 3.7 Securitate și Best Practices

```
⚠️ REGULI DE AUR:

1. NICIODATĂ chmod 777 - întotdeauna există o soluție mai bună
2. Principiul "least privilege" - dă minimum de permisiuni necesare
3. Testează în sandbox înainte de chmod recursiv
4. Verifică cu ls -la înainte de a modifica
5. Fii atent la SUID - poate fi vulnerabilitate
```

---

# MODULUL 4: AUTOMATIZARE CU CRON

## 4.1 Ce este Cron?

Cron este un daemon care execută comenzi programate. Esențial pentru:
- Backup-uri automate
- Curățare log-uri
- Rapoarte periodice
- Mentenanță sistem

---

## 4.2 Formatul Crontab

### SUBGOAL 4.2.1: Cele 5 câmpuri

```
┌───────────── minut (0-59)
│ ┌───────────── oră (0-23)
│ │ ┌───────────── zi din lună (1-31)
│ │ │ ┌───────────── lună (1-12 sau jan-dec)
│ │ │ │ ┌───────────── zi din săptămână (0-7, 0 și 7 = Duminică)
│ │ │ │ │
│ │ │ │ │
* * * * * comandă
```

### SUBGOAL 4.2.2: Caractere speciale

| Simbol | Descriere | Exemplu |
|--------|-----------|---------|
| `*` | Orice valoare | `* * * * *` |
| `,` | Lista | `1,15,30` |
| `-` | Range | `1-5` |
| `/` | Step | `*/5` |

### SUBGOAL 4.2.3: String-uri speciale

| String | Echivalent | Descriere |
|--------|------------|-----------|
| @reboot | - | La pornirea sistemului |
| @yearly | 0 0 1 1 * | 1 ianuarie, miezul nopții |
| @monthly | 0 0 1 * * | Prima zi din lună |
| @weekly | 0 0 * * 0 | Duminică, miezul nopții |
| @daily | 0 0 * * * | Zilnic, miezul nopții |
| @hourly | 0 * * * * | În fiecare oră |

---

## 4.3 Gestionarea Crontab

```bash
crontab -e          # Editează crontab-ul tău
crontab -l          # Listează job-urile
crontab -r          # ⚠️ ȘTERGE TOTUL!

sudo crontab -u user -e  # Editează pentru alt user
```

---

## 4.4 Best Practices Cron

### SUBGOAL 4.4.1: Mediul de execuție

Cron NU are variabilele tale de mediu!

```bash
# În crontab, setează PATH explicit
PATH=/usr/local/bin:/usr/bin:/bin
SHELL=/bin/bash
MAILTO=Issues: Open an issue in GitHub

0 3 * * * /full/path/to/script.sh
```

### SUBGOAL 4.4.2: Logging și debugging

```bash
# Redirecționează output
0 3 * * * /path/script.sh >> /var/log/myscript.log 2>&1

# Cu timestamp
0 3 * * * /path/script.sh 2>&1 | while read line; do echo "$(date): $line"; done >> /var/log/script.log

# Suprimă output
0 3 * * * /path/script.sh > /dev/null 2>&1
```

### SUBGOAL 4.4.3: Prevenire execuții multiple

```bash
#!/bin/bash
LOCKFILE="/tmp/myscript.lock"

if [ -f "$LOCKFILE" ]; then
    echo "Script deja în execuție"
    exit 1
fi

echo $$ > "$LOCKFILE"
trap "rm -f $LOCKFILE" EXIT

# Logica ta aici
```

---

## 4.5 at - Task-uri One-Time

```bash
at 15:30                    # La 15:30 azi
at now + 1 hour             # Peste o oră
at midnight                 # La miezul nopții
at noon tomorrow            # Mâine la prânz

atq                         # Listează job-uri
atrm job_number             # Șterge un job
```

---

# REZUMAT ȘI CHEAT SHEET EXTINS

## find
```bash
find . -name "*.txt"                    # După nume
find . -type f -size +10M               # Fișiere > 10MB
find . -mtime -7                        # Modificate în 7 zile
find . -perm 644                        # Permisiuni exacte
find . -exec cmd {} \;                  # Execută per fișier
find . -print0 | xargs -0 cmd           # Sigur pentru spații
```

## xargs
```bash
cmd | xargs                             # Construiește argumente
cmd | xargs -n 1                        # Câte un argument
cmd | xargs -I{} action {}              # Placeholder
cmd | xargs -P 4                        # 4 procese paralele
find . -print0 | xargs -0               # Pentru spații
```

## Parametri Script
```bash
$0                    # Numele scriptului
$1-$9                 # Argumente 1-9
${10}                 # Argument 10+
$#                    # Număr argumente
$@                    # Toate (ca listă)
shift                 # Elimină $1
getopts "ab:c:" opt   # Parsare opțiuni
```

## chmod
```bash
chmod 755 file        # rwxr-xr-x
chmod 644 file        # rw-r--r--
chmod u+x file        # +execute owner
chmod -R 755 dir/     # Recursiv
chmod 4755 file       # SUID
chmod 2775 dir        # SGID
chmod 1777 dir        # Sticky
```

## cron
```bash
* * * * *             # Fiecare minut
*/5 * * * *           # La 5 minute
0 3 * * *             # Zilnic 3 AM
0 9 * * 1-5           # L-V 9 AM
@reboot               # La boot
```

---

*Material creat pentru Seminar 3 SO | ASE București - CSIE*
