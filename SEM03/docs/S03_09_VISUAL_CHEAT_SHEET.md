# CHEAT SHEET VIZUAL: Utilitare, Scripturi, Permisiuni, Cron

## Seminarul 03 | Sisteme de Operare | ASE București - CSIE

> **Referință rapidă** - Printează acest document (2-3 pagini) pentru acces instant la toate comenzile

---


# MODULUL 1: FIND ȘI XARGS


## 1.1 Sintaxa Generală find

```
┌─────────────────────────────────────────────────────────────────────┐
│                    STRUCTURA COMENZII FIND                         │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   find [CALE] [EXPRESII] [ACȚIUNI]                                 │
│         │         │           │                                     │
│         │         │           └── Ce faci cu rezultatele            │
│         │         └── Criterii de filtrare (teste)                  │
│         └── Unde cauți (default: directorul curent)                 │
│                                                                     │
│   EXEMPLU COMPLET:                                                  │
│   find /var/log -type f -name "*.log" -size +10M -exec ls -lh {} \; │
│        └─CALE─┘ └────────EXPRESII──────────────┘ └────ACȚIUNE────┘  │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```


## 1.2 Teste find - După Nume

*(`find` combinat cu `-exec` e extrem de util. Odată ce-l stăpânești, nu mai poți fără el.)*


```
┌────────────────────────────────────────────────────────────────────┐
│ TEST           │ DESCRIERE                    │ EXEMPLU            │
├────────────────┼──────────────────────────────┼────────────────────┤
│ -name PATTERN  │ Potrivire exactă (case sens.)│ -name "*.txt"      │
│ -iname PATTERN │ Case insensitive             │ -iname "*.TXT"     │
│ -path PATTERN  │ Potrivește calea completă    │ -path "*src/*.c"   │
│ -regex PATTERN │ Regex pe calea completă      │ -regex ".*\\.log$" │
└────────────────────────────────────────────────────────────────────┘

⚠️  Capcană: Folosește GHILIMELE pentru pattern-uri!
    CORECT:   find . -name "*.txt"
    GREȘIT:   find . -name *.txt  ← shell-ul expandează înainte!
```


## 1.3 Teste find - După Tip

```
┌─────────────────────────────────────────────────────────────────┐
│                     -type CARACTER                              │
├──────┬──────────────────────────────────────────────────────────┤
│  f   │ Fișier regular                    find . -type f         │
│  d   │ Director                          find . -type d         │
│  l   │ Link simbolic                     find . -type l         │
│  b   │ Dispozitiv block (hard disk)      find /dev -type b      │
│  c   │ Dispozitiv character (terminal)   find /dev -type c      │
│  p   │ Named pipe (FIFO)                 find /tmp -type p      │
│  s   │ Socket                            find /var -type s      │
└──────┴──────────────────────────────────────────────────────────┘
```


## 1.4 Teste find - După Dimensiune

```
┌───────────────────────────────────────────────────────────────────┐
│                    -size [+/-]N[SUFFIX]                           │
├───────────────────────────────────────────────────────────────────┤
│                                                                   │
│ SUFIXE:   c = bytes      k = KB      M = MB      G = GB          │
│                                                                   │
│ PREFIXE:  +N = mai mare decât N                                  │
│           -N = mai mic decât N                                   │
│            N = exact N                                           │
│                                                                   │
├───────────────────────────────────────────────────────────────────┤
│ EXEMPLE:                                                          │
│   -size +100M     │ Mai mare de 100 MB                           │
│   -size -1k       │ Mai mic de 1 KB                              │
│   -size 0         │ Fișiere goale                                │
│   -size +1G       │ Mai mare de 1 GB (atenție la HDD!)           │
└───────────────────────────────────────────────────────────────────┘
```


## 1.5 Teste find - După Timp

```
┌───────────────────────────────────────────────────────────────────┐
│                    TESTE BAZATE PE TIMP                           │
├────────────┬──────────────────────────────────────────────────────┤
│            │                    UNITATE                           │
│ ATRIBUT    ├────────────────────┬─────────────────────────────────┤
│            │   ZILE (-time)     │   MINUTE (-min)                │
├────────────┼────────────────────┼─────────────────────────────────┤
│ Modificare │ -mtime             │ -mmin                           │
│ Acces      │ -atime             │ -amin                           │
│ Creare*    │ -ctime             │ -cmin                           │
└────────────┴────────────────────┴─────────────────────────────────┘
* ctime = change time (metadate, nu conținut)

INTERPRETARE VALORI:
┌─────────────────────────────────────────────────────────────────┐
│  -mtime 0   │ Modificat în ultimele 24 ore                      │
│  -mtime 1   │ Modificat între 24-48 ore în urmă                 │
│  -mtime +7  │ Modificat acum mai mult de 7 zile                 │
│  -mtime -7  │ Modificat în ultimele 7 zile                      │
└─────────────────────────────────────────────────────────────────┘

ALTE TESTE TEMPORALE:
  -newer FILE    │ Mai nou decât FILE
  -newermt DATE  │ Mai nou decât data specificată
```


## 1.6 Teste find - După Permisiuni și Owner

```
┌───────────────────────────────────────────────────────────────────┐
│                  TESTE PERMISIUNI ȘI OWNERSHIP                    │
├───────────────────────────────────────────────────────────────────┤
│ -perm MODE    │ Permisiuni EXACT mode                            │
│ -perm -MODE   │ Toate biturile din mode sunt setate              │
│ -perm /MODE   │ Cel puțin UN bit din mode este setat             │
├───────────────────────────────────────────────────────────────────┤
│ -user NAME    │ Owner este NAME (sau UID)                        │
│ -group NAME   │ Grup este NAME (sau GID)                         │
│ -nouser       │ Fișiere fără owner valid                         │
│ -nogroup      │ Fișiere fără grup valid                          │
└───────────────────────────────────────────────────────────────────┘

EXEMPLE PERMISIUNI:
  find . -perm 644        # Exact rw-r--r--
  find . -perm -u+x       # Owner are execute
  find . -perm /o+w       # Others au write (PERICULOS!)
  find . -perm -4000      # SUID setat
  find . -perm -2000      # SGID setat
```


## 1.7 Operatori Logici find

```
┌───────────────────────────────────────────────────────────────────┐
│                    OPERATORI LOGICI                               │
├───────────────────────────────────────────────────────────────────┤
│                                                                   │
│   AND:  implicit (sau -a)     find . -type f -name "*.c"         │
│                                                                   │
│   OR:   -o                    find . -name "*.c" -o -name "*.h"  │
│                                                                   │
│   NOT:  ! sau -not            find . ! -name "*.txt"             │
│                                                                   │
│   GRUPARE: \( ... \)          find . \( -name "*.c" -o \         │
│                                        -name "*.h" \) -mtime -7  │
│                                                                   │
└───────────────────────────────────────────────────────────────────┘

⚠️  Spații obligatorii în jurul \( și \)
⚠️  Backslash pentru escape în shell
```


## 1.8 Acțiuni find

```
┌───────────────────────────────────────────────────────────────────┐
│                        ACȚIUNI                                    │
├───────────────────────────────────────────────────────────────────┤
│ -print         │ Afișează calea (default)                        │
│ -print0        │ Afișează cu null terminator (pentru xargs -0)   │
│ -ls            │ Format ls -l                                    │
│ -printf FORMAT │ Format personalizat                             │
│ -delete        │ Șterge (⚠️ ATENȚIE!)                            │
│ -exec CMD {} \;│ Execută CMD pentru fiecare fișier               │
│ -exec CMD {} + │ Execută CMD cu toate fișierele (batch)          │
│ -ok CMD {} \;  │ Ca -exec dar cere confirmare                    │
└───────────────────────────────────────────────────────────────────┘

-printf SPECIFIERS:
  %p - calea completă      %f - numele fișierului
  %s - dimensiune (bytes)  %M - permisiuni (rwx)
  %u - owner name          %g - group name
  %T+ - modification time  %m - permisiuni (octal)
  \n - newline             \t - tab

EXEMPLU:
  find . -type f -printf '%M %u %s %p\n'
```


## 1.9 xargs - Sintaxă și Opțiuni

```
┌───────────────────────────────────────────────────────────────────┐
│                         XARGS                                     │
├───────────────────────────────────────────────────────────────────┤
│                                                                   │
│   cmd | xargs [OPȚIUNI] COMANDĂ                                  │
│                                                                   │
│   Input (stdin) → xargs → Argumente pentru COMANDĂ               │
│                                                                   │
├───────────────────────────────────────────────────────────────────┤
│ OPȚIUNE        │ EFECT                                           │
├────────────────┼─────────────────────────────────────────────────┤
│ -0             │ Input delimitat cu null (cu find -print0)       │
│ -n NUM         │ Maximum NUM argumente per execuție              │
│ -I{}           │ Placeholder pentru substituție                  │
│ -P NUM         │ Rulează NUM procese în paralel                  │
│ -t             │ Verbose - afișează comanda executată            │
│ -p             │ Interactive - cere confirmare                   │
│ -L NUM         │ Maximum NUM linii per execuție                  │
└───────────────────────────────────────────────────────────────────┘

PATTERN ESENȚIAL (SPAȚII ÎN NUME):
  find . -name "*.txt" -print0 | xargs -0 rm

PARALELISM:
  find . -name "*.jpg" -print0 | xargs -0 -P4 -I{} convert {} {}.png
```


## 1.10 locate vs find

```
┌───────────────────────────────────────────────────────────────────┐
│                    LOCATE vs FIND                                 │
├─────────────────────┬─────────────────────────────────────────────┤
│      LOCATE         │              FIND                           │
├─────────────────────┼─────────────────────────────────────────────┤
│ Caută în bază date  │ Caută live în filesystem                   │
│ Foarte rapid        │ Mai lent (traversează directoare)          │
│ Poate fi outdated   │ Întotdeauna actual                         │
│ Doar după nume      │ Criteriii multiple (dimensiune, timp etc.) │
│ Necesită updatedb   │ Nu necesită setup                          │
└─────────────────────┴─────────────────────────────────────────────┘

COMENZI locate:
  locate PATTERN      # Caută pattern
  locate -i PATTERN   # Case insensitive
  locate -c PATTERN   # Doar count
  sudo updatedb       # Actualizează baza de date
```

---


# MODULUL 2: PARAMETRI SCRIPT


## 2.1 Variabilele Speciale

```
┌───────────────────────────────────────────────────────────────────┐
│                  VARIABILE SPECIALE BASH                          │
├────────┬──────────────────────────────────────────────────────────┤
│  $0    │ Numele scriptului                                       │
│  $1-$9 │ Argumentele 1-9                                         │
│ ${10}+ │ Argumentele 10+ (cu acolade!)                           │
│  $#    │ Numărul de argumente                                    │
│  $@    │ Toate argumentele (ca array)                            │
│  $*    │ Toate argumentele (ca string)                           │
│  $?    │ Exit status ultima comandă                              │
│  $$    │ PID-ul procesului curent                                │
│  $!    │ PID-ul ultimului proces background                      │
└────────┴──────────────────────────────────────────────────────────┘

⚠️  DIFERENȚA CRITICĂ "$@" vs "$*":

┌───────────────────────────────────────────────────────────────────┐
│ Rulare: ./script.sh "arg one" "arg two"                          │
├───────────────────────────────────────────────────────────────────┤
│ "$@" → "arg one" "arg two"    (2 argumente separate)             │
│ "$*" → "arg one arg two"      (1 string concatenat)              │
└───────────────────────────────────────────────────────────────────┘
REGULĂ: Folosește întotdeauna "$@" în bucle!
```


## 2.2 shift - Procesare Iterativă

```
┌───────────────────────────────────────────────────────────────────┐
│                        SHIFT                                      │
├───────────────────────────────────────────────────────────────────┤
│                                                                   │
│   shift      # Elimină $1, $2 devine $1, etc.                    │
│   shift N    # Elimină primele N argumente                       │
│                                                                   │
│   ÎNAINTE:   $1="a"  $2="b"  $3="c"   $#=3                       │
│   shift                                                          │
│   DUPĂ:      $1="b"  $2="c"           $#=2                       │
│                                                                   │
└───────────────────────────────────────────────────────────────────┘

PATTERN COMUN:
┌────────────────────────────────────────┐
│ while [ $# -gt 0 ]; do                 │
│     echo "Procesez: $1"                │
│     shift                              │
│ done                                   │
└────────────────────────────────────────┘
```


## 2.3 Expansiuni cu Default

```
┌───────────────────────────────────────────────────────────────────┐
│              EXPANSIUNI PARAMETRI                                 │
├────────────────────┬──────────────────────────────────────────────┤
│ ${VAR:-default}    │ Folosește default dacă VAR e gol/unset      │
│ ${VAR:=default}    │ Setează VAR la default dacă e gol/unset     │
│ ${VAR:+alternate}  │ Folosește alternate dacă VAR NU e gol       │
│ ${VAR:?error msg}  │ Eroare dacă VAR e gol                       │
├────────────────────┴──────────────────────────────────────────────┤
│ ${#VAR}            │ Lungimea valorii VAR                        │
│ ${VAR%pattern}     │ Șterge cel mai scurt sufix                  │
│ ${VAR%%pattern}    │ Șterge cel mai lung sufix                   │
│ ${VAR#pattern}     │ Șterge cel mai scurt prefix                 │
│ ${VAR##pattern}    │ Șterge cel mai lung prefix                  │
└───────────────────────────────────────────────────────────────────┘

EXEMPLE:
  OUTPUT=${1:-"output.txt"}    # Default output.txt
  : ${DEBUG:=false}            # Setează DEBUG la false dacă lipsește
  FILE="${path##*/}"           # Extrage filename din path
  DIR="${path%/*}"             # Extrage directory din path
```


## 2.4 getopts - Parsare Opțiuni

```
┌───────────────────────────────────────────────────────────────────┐
│                        GETOPTS                                    │
├───────────────────────────────────────────────────────────────────┤
│                                                                   │
│   while getopts "OPTSTRING" opt; do                              │
│       case $opt in                                                │
│           x) ... ;;                                               │
│       esac                                                        │
│   done                                                            │
│   shift $((OPTIND - 1))   # Mută la argumentele non-opțiune      │
│                                                                   │
├───────────────────────────────────────────────────────────────────┤
│ OPTSTRING SYNTAX:                                                 │
│   "abc"    → -a, -b, -c fără argumente                           │
│   "a:bc"   → -a necesită argument, -b -c nu                      │
│   ":abc"   → Silent mode (: la început)                          │
└───────────────────────────────────────────────────────────────────┘

VARIABILE SPECIALE:
  $opt     - opțiunea curentă
  $OPTARG  - argumentul opțiunii (când opțiunea are :)
  $OPTIND  - indexul următorului argument de procesat

EXEMPLU COMPLET:
┌─────────────────────────────────────────────────────────────────┐
│ #!/bin/bash                                                     │
│ verbose=false                                                   │
│ output=""                                                       │
│                                                                 │
│ while getopts ":hvo:n:" opt; do                                │
│     case $opt in                                                │
│         h) usage; exit 0 ;;                                     │
│         v) verbose=true ;;                                      │
│         o) output="$OPTARG" ;;                                  │
│         n) count="$OPTARG" ;;                                   │
│         :) echo "Opțiunea -$OPTARG necesită argument" ;;        │
│         \?) echo "Opțiune invalidă: -$OPTARG" ;;                │
│     esac                                                        │
│ done                                                            │
│ shift $((OPTIND - 1))                                          │
│ # Acum $@ conține argumentele non-opțiune                       │
└─────────────────────────────────────────────────────────────────┘
```


## 2.5 Opțiuni Lungi - Pattern Manual

```
┌───────────────────────────────────────────────────────────────────┐
│                  OPȚIUNI LUNGI (MANUAL)                           │
├───────────────────────────────────────────────────────────────────┤
│ while [ $# -gt 0 ]; do                                           │
│     case "$1" in                                                 │
│         -h|--help)                                               │
│             usage; exit 0 ;;                                     │
│         -v|--verbose)                                            │
│             verbose=true; shift ;;                               │
│         -o|--output)                                             │
│             output="$2"; shift 2 ;;                              │
│         --output=*)                                              │
│             output="${1#*=}"; shift ;;                           │
│         --)                                                      │
│             shift; break ;;                                      │
│         -*)                                                      │
│             echo "Opțiune necunoscută: $1"; exit 1 ;;            │
│         *)                                                       │
│             break ;;                                             │
│     esac                                                         │
│ done                                                             │
└───────────────────────────────────────────────────────────────────┘
```

---


# MODULUL 3: PERMISIUNI UNIX


## 3.5 Permisiuni Speciale

```
┌───────────────────────────────────────────────────────────────────┐
│                  PERMISIUNI SPECIALE                              │
├───────────────────────────────────────────────────────────────────┤
│                                                                   │
│   SUID (Set User ID)     - 4xxx - chmod u+s sau chmod 4755       │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │ Pe fișier: Execută cu permisiunile OWNER-ului, nu user-ului │ │
│   │ Exemplu: /usr/bin/passwd (-rwsr-xr-x) rulează ca root       │ │
│   │ ⚠️ NU funcționează pe scripturi bash (securitate)           │ │
│   │ Afișare: 's' în poziția x a owner-ului                      │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                   │
│   SGID (Set Group ID)    - 2xxx - chmod g+s sau chmod 2755       │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │ Pe fișier: Execută cu permisiunile GRUPULUI                 │ │
│   │ Pe director: Fișierele noi moștenesc GRUPUL directorului    │ │
│   │ Util pentru directoare partajate între echipe               │ │
│   │ Afișare: 's' în poziția x a grupului                        │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                   │
│   Sticky Bit             - 1xxx - chmod +t sau chmod 1755        │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │ Pe director: Doar owner-ul fișierului poate să-l șteargă    │ │
│   │ Exemplu: /tmp (drwxrwxrwt) - toți pot scrie, doar owner     │ │
│   │          propriului fișier poate șterge                     │ │
│   │ Afișare: 't' în poziția x a others                          │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                   │
├───────────────────────────────────────────────────────────────────┤
│ CHMOD CU SPECIALE:                                                │
│   chmod 4755 file  # SUID + rwxr-xr-x                            │
│   chmod 2755 dir   # SGID + rwxr-xr-x                            │
│   chmod 1755 dir   # Sticky + rwxr-xr-x                          │
│   chmod 3770 dir   # SGID + Sticky + rwxrwx---                   │
└───────────────────────────────────────────────────────────────────┘
```


## 3.2 chmod - Modul Octal

```
┌───────────────────────────────────────────────────────────────────┐
│                    CHMOD OCTAL                                    │
├───────────────────────────────────────────────────────────────────┤
│                                                                   │
│   chmod ABC fișier                                               │
│         │││                                                       │
│         ││└── Others (o)                                         │
│         │└── Group (g)                                           │
│         └── User/Owner (u)                                       │
│                                                                   │
│   CALCUL:  r = 4    w = 2    x = 1                               │
│                                                                   │
│   rwx = 4+2+1 = 7    rw- = 4+2 = 6    r-x = 4+1 = 5             │
│   r-- = 4            -wx = 3          --x = 1                    │
│                                                                   │
├───────────────────────────────────────────────────────────────────┤
│                 PERMISIUNI COMUNE                                 │
├────────┬─────────────┬────────────────────────────────────────────┤
│  755   │ rwxr-xr-x   │ Scripturi executabile, directoare         │
│  644   │ rw-r--r--   │ Fișiere text, configurări                 │
│  600   │ rw-------   │ Fișiere private (chei SSH)                │
│  700   │ rwx------   │ Directoare private                        │
│  750   │ rwxr-x---   │ Scripturi pentru grup                     │
│  640   │ rw-r-----   │ Fișiere citibile de grup                  │
│  444   │ r--r--r--   │ Read-only pentru toți                     │
│  777   │ rwxrwxrwx   │ ⚠️ NICIODATĂ! VULNERABILITATE!            │
└────────┴─────────────┴────────────────────────────────────────────┘
```


## 3.3 chmod - Modul Simbolic

```
┌───────────────────────────────────────────────────────────────────┐
│                    CHMOD SIMBOLIC                                 │
├───────────────────────────────────────────────────────────────────┤
│                                                                   │
│   chmod [CINE][OPERATOR][CE] fișier                              │
│                                                                   │
│   CINE:     u = owner    g = group    o = others    a = all      │
│   OPERATOR: + = adaugă   - = elimină  = = setează exact          │
│   CE:       r = read     w = write    x = execute                │
│                          X = execute doar dacă e director         │
│                                                                   │
├───────────────────────────────────────────────────────────────────┤
│ EXEMPLE:                                                          │
│   chmod u+x script.sh        # Adaugă execute pentru owner       │
│   chmod go-w file.txt        # Elimină write pentru group+others │
│   chmod a+r file.txt         # Adaugă read pentru toți           │
│   chmod u=rwx,g=rx,o=r file  # Setează explicit: 754             │
│   chmod -R u+rwX,go-w dir/   # Recursiv, X doar pentru directoare│
└───────────────────────────────────────────────────────────────────┘
```


## 3.4 umask - Permisiuni Default

```
┌───────────────────────────────────────────────────────────────────┐
│                         UMASK                                     │
├───────────────────────────────────────────────────────────────────┤
│                                                                   │
│   umask SPECIFICĂ CE SE ELIMINĂ, NU CE SE SETEAZĂ!               │
│                                                                   │
│   Valori default sistem:                                         │
│   - Fișiere: 666 (rw-rw-rw-)                                     │
│   - Directoare: 777 (rwxrwxrwx)                                  │
│                                                                   │
│   Permisiuni finale = Default - umask                            │
│                                                                   │
├───────────────────────────────────────────────────────────────────┤
│ EXEMPLE:                                                          │
│                                                                   │
│   umask 022:                                                      │
│   - Fișiere:    666 - 022 = 644 (rw-r--r--)                      │
│   - Directoare: 777 - 022 = 755 (rwxr-xr-x)                      │
│                                                                   │
│   umask 077:                                                      │
│   - Fișiere:    666 - 077 = 600 (rw-------)                      │
│   - Directoare: 777 - 077 = 700 (rwx------)                      │
│                                                                   │
│   umask 027:                                                      │
│   - Fișiere:    666 - 027 = 640 (rw-r-----)                      │
│   - Directoare: 777 - 027 = 750 (rwxr-x---)                      │
│                                                                   │
└───────────────────────────────────────────────────────────────────┘

COMENZI:
  umask           # Afișează umask curent
  umask -S        # Afișează în format simbolic
  umask 077       # Setează umask
  
PERSISTENȚĂ: Adaugă în ~/.bashrc pentru permanență
```


## 3.1 Structura Permisiunilor

```
┌───────────────────────────────────────────────────────────────────┐
│                  SPECIAL PERMISSIONS                              │
├───────────────────────────────────────────────────────────────────┤
│                                                                   │
│   SUID (Set User ID)     - 4xxx - chmod u+s or chmod 4755        │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │ On file: Executes with OWNER's permissions, not user's     │ │
│   │ Example: /usr/bin/passwd (-rwsr-xr-x) runs as root         │ │
│   │ ⚠️ Does NOT work on bash scripts (security)                │ │
│   │ Display: 's' in owner's x position                         │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                   │
│   SGID (Set Group ID)    - 2xxx - chmod g+s or chmod 2755        │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │ On file: Executes with GROUP's permissions                 │ │
│   │ On directory: New files inherit directory's GROUP          │ │
│   │ Useful for shared directories between teams                │ │
│   │ Display: 's' in group's x position                         │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                   │
│   Sticky Bit             - 1xxx - chmod +t or chmod 1755         │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │ On directory: Only file's owner can delete it              │ │
│   │ Example: /tmp (drwxrwxrwt) - all can write, only owner     │ │
│   │          of own file can delete                            │ │
│   │ Display: 't' in others' x position                         │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                   │
├───────────────────────────────────────────────────────────────────┤
│ CHMOD WITH SPECIALS:                                              │
│   chmod 4755 file  # SUID + rwxr-xr-x                            │
│   chmod 2755 dir   # SGID + rwxr-xr-x                            │
│   chmod 1755 dir   # Sticky + rwxr-xr-x                          │
│   chmod 3770 dir   # SGID + Sticky + rwxrwx---                   │
└───────────────────────────────────────────────────────────────────┘
```


## 3.6 chown și chgrp

```
┌───────────────────────────────────────────────────────────────────┐
│                    CHOWN ȘI CHGRP                                 │
├───────────────────────────────────────────────────────────────────┤
│                                                                   │
│   chown [OPȚIUNI] OWNER[:GROUP] FIȘIER                           │
│                                                                   │
│   EXEMPLE:                                                        │
│   chown user file              # Schimbă doar owner              │
│   chown user:group file        # Schimbă owner și group          │
│   chown :group file            # Schimbă doar group              │
│   chown -R user:group dir/     # Recursiv                        │
│                                                                   │
│   chgrp [OPȚIUNI] GROUP FIȘIER                                   │
│   chgrp developers file        # Schimbă grupul                  │
│   chgrp -R developers dir/     # Recursiv                        │
│                                                                   │
└───────────────────────────────────────────────────────────────────┘

⚠️  chown necesită de obicei sudo (doar root poate schimba owner)
⚠️  chgrp poate fi folosit fără sudo dacă ești membru al grupului
```

---


# MODULUL 4: CRON ȘI AUTOMATIZARE


## 4.1 Formatul Crontab

```
┌───────────────────────────────────────────────────────────────────┐
│                    FORMATUL CRONTAB                               │
├───────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌────────── minute (0-59)                                       │
│  │ ┌──────── hour (0-23)                                         │
│  │ │ ┌────── day of month (1-31)                                 │
│  │ │ │ ┌──── month (1-12)                                        │
│  │ │ │ │ ┌── day of week (0-7, 0 și 7 = Sunday)                  │
│  │ │ │ │ │                                                        │
│  * * * * *  command                                              │
│                                                                   │
├───────────────────────────────────────────────────────────────────┤
│ CARACTERE SPECIALE:                                               │
│                                                                   │
│   *      │ Orice valoare                                         │
│   ,      │ Listă de valori          (1,3,5)                       │
│   -      │ Range                    (1-5)                        │
│   /      │ Step                     (*/5 = la fiecare 5)         │
│                                                                   │
└───────────────────────────────────────────────────────────────────┘

EXEMPLE COMUNE:
┌────────────────────┬─────────────────────────────────────────────┐
│ 0 * * * *          │ La fiecare oră, la minutul 0               │
│ */15 * * * *       │ La fiecare 15 minute                       │
│ 0 3 * * *          │ Zilnic la 3:00 AM                          │
│ 0 0 * * 0          │ Duminică la miezul nopții                  │
│ 0 9-17 * * 1-5     │ Luni-Vineri, 9-17, la fiecare oră          │
│ 30 4 1,15 * *      │ Pe 1 și 15 ale lunii, la 4:30 AM           │
│ 0 0 1 1 *          │ 1 Ianuarie la miezul nopții                │
│ */5 9-17 * * 1-5   │ La fiecare 5 min, 9-17, Luni-Vineri       │
└────────────────────┴─────────────────────────────────────────────┘
```


## 4.2 String-uri Speciale Cron

```
┌───────────────────────────────────────────────────────────────────┐
│                  STRING-URI SPECIALE                              │
├──────────────┬────────────────────────────────────────────────────┤
│ @reboot      │ La pornirea sistemului                            │
│ @yearly      │ 0 0 1 1 * (1 Ian, 00:00)                          │
│ @annually    │ (sinonim @yearly)                                  │
│ @monthly     │ 0 0 1 * * (prima zi a lunii)                       │
│ @weekly      │ 0 0 * * 0 (duminică, 00:00)                        │
│ @daily       │ 0 0 * * * (zilnic, 00:00)                          │
│ @midnight    │ (sinonim @daily)                                   │
│ @hourly      │ 0 * * * * (la fiecare oră)                         │
└──────────────┴────────────────────────────────────────────────────┘
```


## 4.3 Comenzi crontab

```
┌───────────────────────────────────────────────────────────────────┐
│                  COMENZI CRONTAB                                  │
├───────────────────────────────────────────────────────────────────┤
│ crontab -e         │ Editează crontab-ul user-ului curent        │
│ crontab -l         │ Listează crontab-ul curent                  │
│ crontab -r         │ ⚠️ ȘTERGE TOT crontab-ul! (fără confirmare) │
│ crontab -u USER -e │ Editează crontab-ul altui user (root)       │
│ crontab file       │ Instalează crontab din fișier               │
└───────────────────────────────────────────────────────────────────┘

⚠️  crontab -r șterge TOTUL fără confirmare!
    Folosește: crontab -l > backup.cron înainte de modificări
```


## 4.4 Best Practices Cron

```
┌───────────────────────────────────────────────────────────────────┐
│                  BEST PRACTICES CRON                              │
├───────────────────────────────────────────────────────────────────┤
│                                                                   │
│ 1. CĂII ABSOLUTE                                                  │
│    ✗ 0 3 * * * backup.sh                                         │
│    ✓ 0 3 * * * /home/user/scripts/backup.sh                      │
│                                                                   │
│ 2. SETEAZĂ PATH                                                   │
│    PATH=/usr/local/bin:/usr/bin:/bin                             │
│    0 3 * * * backup.sh                                           │
│                                                                   │
│ 3. LOGGING                                                        │
│    0 3 * * * /path/script.sh >> /var/log/script.log 2>&1         │
│                                                                   │
│ 4. PREVINE EXECUȚII MULTIPLE (lock file)                         │
│    0 * * * * flock -n /tmp/script.lock /path/script.sh           │
│                                                                   │
│ 5. TESTEAZĂ ÎNAINTE                                               │
│    0 3 * * * echo "Test la $(date)" >> /tmp/test.log             │
│                                                                   │
└───────────────────────────────────────────────────────────────────┘
```


## 4.5 Comanda at

```
┌───────────────────────────────────────────────────────────────────┐
│                  COMANDA AT (One-time jobs)                       │
├───────────────────────────────────────────────────────────────────┤
│                                                                   │
│   at TIME                   │ Programează job (interactive)      │
│   at -f script.sh TIME      │ Programează din fișier             │
│   atq                       │ Listează job-uri în coadă          │
│   atrm JOB_ID               │ Șterge un job                      │
│   batch                     │ Rulează când load-ul e mic         │
│                                                                   │
├───────────────────────────────────────────────────────────────────┤
│ FORMATE TIMP:                                                     │
│   at now + 5 minutes                                             │
│   at now + 2 hours                                               │
│   at 3:00 PM                                                     │
│   at 15:00                                                       │
│   at midnight                                                    │
│   at noon tomorrow                                               │
│   at 3:00 PM January 20                                          │
│   at teatime  (16:00)                                            │
└───────────────────────────────────────────────────────────────────┘

EXEMPLU INTERACTIV:
  $ at now + 10 minutes
  at> echo "Reminder!" | mail -s "Task" EMAIL_ELIMINAT
  at> 
