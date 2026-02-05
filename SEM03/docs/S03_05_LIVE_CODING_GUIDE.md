# Ghid Live Coding - Seminarul 03
## Sisteme de Operare | Sesiuni Interactive de Programare

**Scop**: Script detaliat pentru toate sesiunile de live coding din seminar
Metodă: Anunț → Predicție → Execuție → Explicație
**Principiu**: "Nu tastezi niciodată cod neînțeles de audiență"

---

## STRUCTURA DOCUMENTULUI

| Sesiune | Subiect | Durată | Locație în seminar |
|---------|---------|--------|-------------------|
| LC-01 | find de la simplu la complex | 15 min | Prima parte [0:10-0:25] |
| LC-02 | xargs și pattern-uri avansate | 8 min | Prima parte [0:25-0:33] |
| LC-03 | Parametri și getopts | 12 min | Pauză sau Prima parte |
| LC-04 | Permisiuni pas cu pas | 12 min | A doua parte [0:05-0:17] |
| LC-05 | Demo cron și automatizare | 5 min | A doua parte [0:40-0:45] |

---

## PREGĂTIRE COMUNĂ

### Setup Director de Lucru

```bash
#!/bin/bash
# Rulează înainte de seminar!

# Creează structura
mkdir -p ~/live_demo/{project,temp,backup,logs,src,config}
cd ~/live_demo

# Populează cu fișiere de test
touch project/{main.c,utils.c,config.h,README.md}
touch project/{app.py,test_app.py,requirements.txt}
touch temp/{cache_001.tmp,cache_002.tmp,old_backup.bak}
touch logs/{app.log,error.log,debug.log,access.log}
touch src/{module1.sh,module2.sh,helpers.bash}
touch config/{prod.conf,dev.conf,test.conf}

# Fișiere cu spații (pentru demonstrații)
touch "project/my document.txt"
touch "project/special file (backup).txt"

# Fișiere de dimensiuni diferite
dd if=/dev/zero of=logs/large.log bs=1M count=5 2>/dev/null
dd if=/dev/zero of=temp/huge.tmp bs=1M count=10 2>/dev/null

# Fișiere cu timestamp-uri diferite
touch -d "2 days ago" temp/recent.tmp
touch -d "15 days ago" temp/old.tmp
touch -d "60 days ago" temp/ancient.tmp

# Script-uri executabile și non-executabile
echo '#!/bin/bash' > src/runnable.sh

*Notă personală: Bash-ul are o sintaxă urâtă, recunosc. Dar rulează peste tot, și asta contează enorm în practică.*

echo 'echo "Hello"' >> src/runnable.sh
chmod +x src/runnable.sh

*(Permisiunile par complicate la început, dar regula e simplă: gândește-te cine are nevoie de ce access.)*


echo '#!/bin/bash' > src/not_exec.sh
echo 'echo "World"' >> src/not_exec.sh
# Intenționat fără chmod +x

echo "✅ Setup complet!"
ls -laR ~/live_demo
```

### Verificări Pre-Sesiune

```bash
# Verifică că totul e ok
[ -d ~/live_demo ] && echo "✅ Director există"
[ -f ~/live_demo/project/main.c ] && echo "✅ Fișiere test există"
[ -f ~/live_demo/logs/large.log ] && echo "✅ Fișiere mari există"
which find xargs locate && echo "✅ Comenzi disponibile"
```

---

## LC-01: FIND DE LA SIMPLU LA COMPLEX (15 min)

### Obiective Sesiune

La final, studenții vor putea:
- Înțelege structura comenzii `find`
- Combina criterii de căutare
- Identifica diferența între teste și acțiuni


### Pregătire Mentală Instructor
> "Find e cea mai puternică unealtă de căutare din Unix. Voi demonstra
> progresiv, de la simplu la complex. La fiecare pas, voi întreba 
> audiența ce cred că va face comanda ÎNAINTE de a o rula."

---

### SEGMENT 1: Structura de bază find (3 minute)

#### [ANUNȚ]
```
📢 "Vom începe cu structura de bază a comenzii find.
    Find are trei componente: UNDE căutăm, CE căutăm, CE FACEM."
```

#### [COD + PREDICȚIE]
```bash
cd ~/live_demo

# PREDICȚIE: "Ce credeți că va afișa această comandă?"
find .
# [pauză pentru răspunsuri]
```

#### [EXECUȚIE]
```bash
find .
# Output: listează TOTUL recursiv
```

#### [EXPLICAȚIE]
```
📖 "Find fără criterii afișează TOTUL din punctul de start.
    Este echivalentul lui 'ls -R' dar în format de căi complete.
    Observați: afișează și directoare, și fișiere."
```

#### [COD + PREDICȚIE]
```bash
# PREDICȚIE: "Dar dacă specific un director?"
find ./project
```

#### [EXECUȚIE + EXPLICAȚIE]
```bash
find ./project
# Output: doar ce e în project/

📖 "Primul argument e punctul de plecare. 
    Poate fi: . (curent), / (root), ~ (home), sau orice cale."
```

---

### SEGMENT 2: Teste de bază - nume și tip (4 minute)

#### [ANUNȚ]
```
📢 "Acum adăugăm CRITERII de căutare. Cele mai comune: -name și -type."
```

#### [COD + PREDICȚIE]
```bash
# PREDICȚIE: "Ce va găsi această comandă?"
find . -name "*.c"
# [pauză]
```

#### [EXECUȚIE]
```bash
find . -name "*.c"
# Output: ./project/main.c, ./project/utils.c
```

#### [EXPLICAȚIE]
```
📖 "-name folosește pattern-uri (glob).
    De reținut: Ghilimele sunt OBLIGATORII pentru *.c
    Fără ghilimele, shell-ul expandează ÎNAINTE de find!"
```

#### [DEMONSTRAȚIE EROARE]
```bash
# EROARE DELIBERATĂ - fără ghilimele
touch test.c  # creăm un .c în directorul curent
find . -name *.c
# Poate da erori sau rezultate neașteptate!

# CORECT:
find . -name "*.c"
rm test.c  # cleanup
```

#### [COD + PREDICȚIE]
```bash
# PREDICȚIE: "Ce face -type d?"
find . -type d
```

#### [EXECUȚIE + EXPLICAȚIE]
```bash
find . -type d
# Output: doar directoarele

📖 "Tipuri comune:
    -type f = fișiere (files)
    -type d = directoare (directories)
    -type l = link-uri simbolice"
```

#### [COD COMBINAT]
```bash
# PREDICȚIE: "Combinația?"
find . -type f -name "*.log"
# Output: doar fișierele .log
```

---

### SEGMENT 3: Teste avansate - dimensiune și timp (4 minute)

#### [ANUNȚ]
```
📢 "Find poate căuta și după dimensiune sau timestamp. 
    Aici devine cu adevărat puternic pentru administrare."

> 💡 Mulți studenți subestimează inițial importanța permisiunilor. Apoi întâlnesc primul 'Permission denied' și se luminează.

```

#### [COD + PREDICȚIE]
```bash
# PREDICȚIE: "Ce înseamnă +1M?"
find . -type f -size +1M
```

#### [EXECUȚIE + EXPLICAȚIE]
```bash
find . -type f -size +1M
# Output: logs/large.log, temp/huge.tmp (cele create cu dd)

📖 "Sintaxa pentru size:
    +N = mai mare decât N
    -N = mai mic decât N
    N  = exact N
    
    Sufixe: c=bytes, k=KB, M=MB, G=GB"
```

#### [COD + PREDICȚIE]
```bash
# PREDICȚIE: "Ce înseamnă -mtime -7?"
find . -type f -mtime -7
```

#### [EXECUȚIE + EXPLICAȚIE]
```bash
find . -type f -mtime -7
# Output: fișierele modificate în ultimele 7 zile

📖 "Timp în find:
    -mtime = modification time (conținut)
    -atime = access time (citire)
    -ctime = change time (metadate)
    
    -N = mai puțin de N zile
    +N = mai mult de N zile
    N  = exact N zile"
```

#### [COD DEMO]
```bash
# Fișierele modificate în ultimele 30 de minute
find . -type f -mmin -30

# Fișiere MAI VECHI de 10 zile
find . -type f -mtime +10
```

---

### SEGMENT 4: Operatori logici (4 minute)

#### [ANUNȚ]
```
📢 "Până acum, criteriile se combină cu AND implicit.
    Dar putem face și OR sau NOT."
```

#### [COD + PREDICȚIE]
```bash
# PREDICȚIE: "Aceasta găsește ce?"
find . -type f -name "*.c" -size +0
# [implicit AND între toate]
```

#### [EXECUȚIE + EXPLICAȚIE]
```bash
📖 "Când pui mai multe teste, find le combină cu AND.
    Fișierul trebuie să satisfacă TOATE condițiile."

> 💡 De-a lungul anilor, am constatat că exemplele practice bat teoria de fiecare dată.

```

#### [COD + PREDICȚIE - OR]
```bash
# PREDICȚIE: "Cum găsesc .c SAU .py?"
find . -type f \( -name "*.c" -o -name "*.py" \)
```

#### [EXECUȚIE + EXPLICAȚIE]
```bash
find . -type f \( -name "*.c" -o -name "*.py" \)
# Output: toate .c și .py

📖 "Pentru OR:
    -o = OR
    \( \) = grupare (escaped pentru shell)
    FĂRĂ grupare, precedența e confuză!"
```

#### [DEMONSTRAȚIE EROARE]
```bash
# EROARE: fără grupare
find . -type f -name "*.c" -o -name "*.py"
# Rezultat GREȘIT! OR se aplică doar între name-uri,
# dar -type f se aplică doar primului -name

# CORECT:
find . -type f \( -name "*.c" -o -name "*.py" \)
```

#### [COD + PREDICȚIE - NOT]
```bash
# PREDICȚIE: "Cum EXCLUD .tmp?"
find . -type f ! -name "*.tmp"
```

#### [EXECUȚIE + EXPLICAȚIE]
```bash
find . -type f ! -name "*.tmp"
# Output: toate fișierele EXCEPTÂND .tmp

📖 "NOT:
    ! = negație
    -not = alternativă (mai explicit)
    Plasare: ÎNAINTE de testul negat"
```

---

## LC-02: XARGS ȘI PATTERN-URI AVANSATE (8 min)

### Obiective Sesiune

Trei lucruri contează aici: studenții înțeleg de ce există xargs, studenții pot folosi xargs cu find în siguranță, și studenții recunosc problema spațiilor în nume.


---

### SEGMENT 1: De ce xargs? (2 minute)

#### [ANUNȚ]
```
📢 "Xargs rezolvă o problemă fundamentală: cum transmitem
    output-ul unui command către altul ca ARGUMENTE."
```

#### [COD + PREDICȚIE]
```bash
# PREDICȚIE: "Diferența dintre acestea?"
find . -name "*.log" -exec wc -l {} \;
find . -name "*.log" | xargs wc -l
```

#### [EXECUȚIE]
```bash
find . -name "*.log" -exec wc -l {} \;
# Output: wc rulează separat pentru FIECARE fișier
# 10 ./logs/app.log
# 5 ./logs/error.log
# ...

find . -name "*.log" | xargs wc -l
# Output: wc rulează O SINGURĂ DATĂ cu toate fișierele
# 10 ./logs/app.log
# 5 ./logs/error.log
# 15 total
```

#### [EXPLICAȚIE]
```
📖 "Diferențe:
    -exec {} \; = rulează comandă pentru FIECARE fișier (lent)
    | xargs     = colectează și rulează O DATĂ (rapid)
    
    Pentru 1000 fișiere:
    -exec {} \; = 1000 procese
    | xargs     = 1-10 procese"
```

---

### SEGMENT 2: Problema spațiilor (3 minute)

#### [ANUNȚ]
```
📢 "Dar xargs are o vulnerabilitate critică. 
    Demonstrez EROAREA pe care o face toată lumea."
```

#### [DEMONSTRAȚIE EROARE]
```bash
# Avem fișiere cu spații:
ls -la project/

# EROARE: xargs simplu
find . -name "*.txt" | xargs ls -l
# EROARE! "my" și "document.txt" sunt tratate separat!
```

#### [EXPLICAȚIE]
```
📖 "Xargs implicit desparte input-ul pe:

Principalele aspecte: spații, tab-uri și newline-uri.

```

#### [SOLUȚIA]
```bash
# SOLUȚIA: -print0 și -0
find . -name "*.txt" -print0 | xargs -0 ls -l
# CORECT! Null byte ca separator
```

#### [EXPLICAȚIE]
```
📖 "-print0 = find trimite nume separate cu \0 (null)
    -0      = xargs citește input null-delimited
    
    REGULĂ DE AUR: Întotdeauna -print0 | xargs -0"
```

---

### SEGMENT 3: xargs avansat (3 minute)

#### [COD + PREDICȚIE]
```bash
# PREDICȚIE: "Ce face -I{}?"
find . -name "*.c" | xargs -I{} echo "Procesez: {}"
```

#### [EXECUȚIE + EXPLICAȚIE]
```bash
find . -name "*.c" | xargs -I{} echo "Procesez: {}"
# Output:
# Procesez: ./project/main.c
# Procesez: ./project/utils.c

📖 "-I{} înlocuiește {} cu input-ul.
    Util când comanda are nevoie de argument în mijloc:
    xargs -I{} cp {} backup/
    xargs -I{} mv {} {}.bak"
```

#### [COD + PREDICȚIE]
```bash
# PREDICȚIE: "Ce face -n 2?"
echo "a b c d e f" | xargs -n 2 echo
```

#### [EXECUȚIE + EXPLICAȚIE]
```bash
echo "a b c d e f" | xargs -n 2 echo
# Output:
# a b
# c d
# e f

📖 "-n N = procesează maxim N argumente per comandă
    Util pentru comenzi cu limite de argumente."
```

#### [COD DEMO - Paralel]
```bash
# Procesare paralelă (BONUS)
find . -name "*.log" -print0 | xargs -0 -P 4 gzip
# -P 4 = 4 procese în paralel
```

---

## LC-03: PARAMETRI ȘI GETOPTS (12 min)

### Obiective Sesiune

La final, studenții vor putea:
- Înțelege `$1`, `$@`, `$#`, `shift`
- Scrie scripturi cu `getopts`
- Diferenția `$@` de `$*`


---

### SEGMENT 1: Parametri poziționali (3 minute)

#### [CREARE SCRIPT]
```bash
# Creăm un script de test
nano ~/live_demo/params.sh
```

#### [COD]
```bash
#!/bin/bash
echo "Scriptul: $0"
echo "Primul argument: $1"
echo "Al doilea argument: $2"
echo "Număr total: $#"
echo "Toate argumentele: $@"
```

#### [EXECUȚIE]
```bash
chmod +x ~/live_demo/params.sh
./params.sh hello world test
# Output:
# Scriptul: ./params.sh
# Primul argument: hello
# Al doilea argument: world
# Număr total: 3
# Toate argumentele: hello world test
```

#### [EXPLICAȚIE]
```
📖 "Variabilele speciale:
    $0 = numele scriptului
    $1-$9 = argumentele 1-9
    ${10}, ${11}... = argumente >= 10 (CU ACOLADE!)
    $# = numărul de argumente
    $@ = toate argumentele"
```

---

### SEGMENT 2: $@ vs $* - diferența critică (4 minutes)

#### [ANUNȚ]
```
📢 "Aceasta este una din cele mai comune greșeli.
    $@ și $* par identice, dar NU sunt!"
```

#### [CREARE SCRIPT]
```bash
nano ~/live_demo/at_vs_star.sh
```

#### [COD]
```bash
#!/bin/bash
echo "=== Cu \"\$@\" ==="
for arg in "$@"; do
    echo "Argument: [$arg]"
done

echo ""
echo "=== Cu \"\$*\" ==="
for arg in "$*"; do
    echo "Argument: [$arg]"
done
```

#### [EXECUȚIE]
```bash
chmod +x ~/live_demo/at_vs_star.sh
./at_vs_star.sh "hello world" test "one two"
```

#### [OUTPUT AȘTEPTAT]
```
=== Cu "$@" ===
Argument: [hello world]
Argument: [test]
Argument: [one two]

=== Cu "$*" ===
Argument: [hello world test one two]
```

#### [EXPLICAȚIE]
```
📖 "DIFERENȚA CRITICĂ:
    \"$@\" = păstrează fiecare argument separat
    \"$*\" = combină totul într-un singur string
    
    REGULĂ: Folosește ÎNTOTDEAUNA \"$@\" pentru iterare!"
```

---

### SEGMENT 3: shift (2 minute)

#### [CREARE SCRIPT]
```bash
nano ~/live_demo/shift_demo.sh
```

#### [COD]
```bash
#!/bin/bash
echo "Inițial: $@"

while [ $# -gt 0 ]; do
    echo "Procesez: $1"
    shift
    echo "  Rămase: $@"
done
```

#### [EXECUȚIE]
```bash
chmod +x ~/live_demo/shift_demo.sh
./shift_demo.sh a b c d
```

#### [EXPLICAȚIE]
```
📖 "shift elimină primul argument.
    $2 devine $1, $3 devine $2, etc.
    $# se decrementează.
    
    Pattern comun pentru procesare secvențială."
```

---

### SEGMENT 4: getopts (3 minute)

#### [CREARE SCRIPT]
```bash
nano ~/live_demo/getopts_demo.sh
```

#### [COD]
```bash
#!/bin/bash

# Valori default
verbose=false
output_file=""
count=1

# Parsare opțiuni
while getopts "hvo:n:" opt; do
    case $opt in
        h)
            echo "Usage: $0 [-h] [-v] [-o file] [-n count] args..."
            exit 0
            ;;
        v)
            verbose=true
            ;;
        o)
            output_file="$OPTARG"
            ;;
        n)
            count="$OPTARG"
            ;;
        ?)
            echo "Opțiune invalidă: -$OPTARG"
            exit 1
            ;;
    esac
done

# Elimină opțiunile procesate
shift $((OPTIND - 1))

# Afișează ce am primit
echo "verbose: $verbose"
echo "output: $output_file"
echo "count: $count"
echo "argumente rămase: $@"
```

#### [EXECUȚIE]
```bash
chmod +x ~/live_demo/getopts_demo.sh

# Test fără opțiuni
./getopts_demo.sh arg1 arg2

# Test cu opțiuni
./getopts_demo.sh -v -o test.txt -n 5 arg1 arg2

# Test cu help
./getopts_demo.sh -h
```

#### [EXPLICAȚIE]
```
📖 "Anatomia getopts:
    \"hvo:n:\" = optstring
    h, v    = opțiuni fără argument
    o:, n:  = opțiuni CU argument (: după literă)
    
    OPTARG = argumentul opțiunii curente
    OPTIND = indexul următorului argument de procesat
    
    shift $((OPTIND - 1)) = elimină opțiunile procesate"
```

---

## LC-04: PERMISIUNI PAS CU PAS (12 min)

### Obiective Sesiune

La final, studenții vor putea:
- Citi și interpreta permisiunile
- Folosi `chmod` în ambele moduri (numeric și simbolic)
- Înțelege `umask` și permisiunile speciale


---

### SEGMENT 1: Citirea permisiunilor (2 minute)

#### [ANUNȚ]
```
📢 "Înainte să schimbăm permisiuni, trebuie să le citim corect."
```

#### [COD + PREDICȚIE]
```bash
ls -l project/
# PREDICȚIE: "Ce înseamnă fiecare caracter?"
```

#### [EXPLICAȚIE CU DIAGRAMĂ]
```
📖 "Anatomia: -rwxr-xr--
    
    Poziția 0:    -  = fișier (d=director, l=link)
    Pozițiile 1-3: rwx = owner: read, write, execute
    Pozițiile 4-6: r-x = group: read, -, execute
    Pozițiile 7-9: r-- = others: read, -, -
    
    - (dash) = permisiunea NU este acordată"
```

#### [COD DEMO]
```bash
ls -ld project/   # Director
ls -l project/main.c  # Fișier
ls -l /usr/bin/passwd  # Fișier cu SUID
```

---

### SEGMENT 2: chmod octal (3 minute)

#### [ANUNȚ]
```
📢 "Modul octal e cel mai rapid. 
    Trei cifre: owner, group, others."
```

#### [EXPLICAȚIE]
```
📖 "Calculul octal:
    r = 4
    w = 2
    x = 1
    
    Exemple:
    7 = r+w+x = 4+2+1
    6 = r+w   = 4+2
    5 = r+x   = 4+1
    4 = r     = 4
    0 = nimic"
```

#### [COD + PREDICȚIE]
```bash
# PREDICȚIE: "Ce permisiuni setează 755?"
chmod 755 project/main.c
ls -l project/main.c
```

#### [EXECUȚIE + VERIFICARE]
```bash
chmod 755 project/main.c
ls -l project/main.c
# -rwxr-xr-x = owner: all, group: r+x, others: r+x
```

#### [EXERCIȚIU RAPID]
```bash
# "Ce setează 644?"
chmod 644 project/config.h
ls -l project/config.h
# -rw-r--r-- = owner: r+w, group: r, others: r

# "Ce setează 600?"
touch project/secret.txt
chmod 600 project/secret.txt
ls -l project/secret.txt
# -rw------- = doar owner poate citi și scrie
```

---

### SEGMENT 3: chmod simbolic (3 minute)

#### [ANUNȚ]
```
📢 "Modul simbolic e mai explicit și mai sigur pentru modificări parțiale."
```

#### [EXPLICAȚIE]
```
📖 "Sintaxa simbolică:
    WHO: u (user/owner), g (group), o (others), a (all)
    OP:  + (adaugă), - (elimină), = (setează exact)
    WHAT: r, w, x"
```

#### [COD + PREDICȚIE]
```bash
# PREDICȚIE: "Ce face u+x?"
chmod u+x project/README.md
ls -l project/README.md
```

#### [COD DEMO]
```bash
# Adaugă execute pentru owner
chmod u+x project/README.md

# Elimină write pentru group și others
chmod go-w project/README.md

# Setează exact pentru group
chmod g=rx project/README.md

# Totul dintr-o dată
chmod u=rwx,g=rx,o=r project/README.md
```

#### [COD SPECIAL - X]
```bash
# PREDICȚIE: "Ce face X (majuscul)?"
chmod -R a+X project/
```

#### [EXPLICAȚIE]
```
📖 "X (majuscul) = execute DOAR pentru:
    - Directoare (întotdeauna)
    - Fișiere care AU DEJA execute
    
    Perfect pentru: chmod -R u=rwX,g=rX,o=rX director/"
```

---

### SEGMENT 4: umask (2 minute)

#### [ANUNȚ]
```
📢 "Umask controlează permisiunile DEFAULT pentru fișiere noi.
    Capcană: umask ELIMINĂ biți, nu setează!"
```

#### [COD + PREDICȚIE]
```bash
# Ce e umask-ul curent?
umask
# Probabil 022

# PREDICȚIE: "Ce permisiuni va avea un fișier nou?"
touch test_umask.txt
ls -l test_umask.txt
```

#### [EXPLICAȚIE]
```
📖 "Calculul:
    Default fișier:  666 (rw-rw-rw-)
    umask:          -022
    Rezultat:        644 (rw-r--r--)
    
    Default director: 777 (rwxrwxrwx)
    umask:           -022
    Rezultat:         755 (rwxr-xr-x)"
```

#### [COD DEMO]
```bash
# Schimbă umask
umask 077

# Creează fișier și director
touch private.txt
mkdir private_dir

ls -l private.txt      # -rw-------
ls -ld private_dir     # drwx------

# Restaurează
umask 022
```

---

### SEGMENT 5: Permisiuni speciale (2 minute)

#### [ANUNȚ]
```
📢 "Există trei biți speciali: SUID, SGID, Sticky.
    Aceștia se pun în fața celor trei cifre."
```

#### [EXPLICAȚIE + DEMO]
```bash
# SUID (4) - rulează ca owner
ls -l /usr/bin/passwd
# -rwsr-xr-x (s în poziția owner-execute)

# SGID (2) pe director - moștenire grup
mkdir shared_project
chmod g+s shared_project
ls -ld shared_project
# drwxr-sr-x (s în poziția group-execute)

# Sticky (1) - doar owner șterge
ls -ld /tmp
# drwxrwxrwt (t în poziția others-execute)
```

#### [COD DEMO]
```bash
# Setare combinată: SGID + Sticky
mkdir team_dir
chmod 3770 team_dir
# 3 = SGID(2) + Sticky(1)
# 770 = owner și group: rwx, others: nimic
ls -ld team_dir
# drwxrws--T (s pentru SGID, T pentru sticky dar fără x)
```

---

## LC-05: DEMO CRON ȘI AUTOMATIZARE (5 min)

### Obiective Sesiune

Principalele aspecte: studenții înțeleg formatul crontab, studenții pot crea job-uri simple și studenții cunosc best practices.


---

### SEGMENT 1: Formatul crontab (2 minute)

#### [ANUNȚ]
```
📢 "Cron folosește 5 câmpuri de timp. 
    Voi demonstra un job live."
```

#### [EXPLICAȚIE]
```
📖 "Formatul:
    * * * * * comandă
    │ │ │ │ │
    │ │ │ │ └── ziua săptămânii (0-7, 0 și 7 = duminică)
    │ │ │ └──── luna (1-12)
    │ │ └────── ziua lunii (1-31)
    │ └──────── ora (0-23)
    └────────── minutul (0-59)"
```

#### [COD DEMO]
```bash
# Afișează crontab-ul curent
crontab -l

# Exemple de expresii:
echo "0 3 * * *     # 3:00 AM zilnic"
echo "*/15 * * * *  # la fiecare 15 minute"
echo "0 9-17 * * 1-5 # la fiecare oră, 9-17, Luni-Vineri"
echo "0 0 1 * *     # prima zi a lunii, miezul nopții"
```

---

### SEGMENT 2: Creare job live (2 minute)

#### [COD DEMO]
```bash
# Creăm un script simplu
cat > ~/test_cron.sh << 'EOF'
#!/bin/bash
echo "$(date): Cron test" >> /tmp/cron_test.log
EOF
chmod +x ~/test_cron.sh

# Adăugăm în crontab (rulează în fiecare minut)
(crontab -l 2>/dev/null; echo "* * * * * $HOME/test_cron.sh") | crontab -

# Verificăm
crontab -l
```

#### [MONITORIZARE]
```bash
# Așteptăm un minut și verificăm
tail -f /tmp/cron_test.log
# [așteaptă să apară output]
```

---

### SEGMENT 3: Cleanup și best practices (1 minut)

#### [COD DEMO]
```bash
# Eliminăm job-ul de test
crontab -l | grep -v "test_cron.sh" | crontab -
crontab -l

# SAU pentru a goli complet (ATENȚIE!)
# crontab -r # ȘTERGE TOTUL!
```

#### [SFATURI]
```
📖 "Best practices cron:
    1. Folosește căi ABSOLUTE
    2. Setează PATH în crontab
    3. Redirecționează output: >> log 2>&1
    4. Testează scriptul ÎNAINTE de a-l pune în cron
    5. Folosește flock pentru a preveni suprapuneri"
```

---

## REZUMAT LIVE CODING

### Erori Deliberate Incluse

| Sesiune | Eroare | Lecție |
|---------|--------|--------|
| LC-01 | find -name *.c fără ghilimele | Shell expansion |
| LC-01 | OR fără grupare | Precedența operatorilor |
| LC-02 | xargs fără -0 | Spații în nume fișiere |
| LC-03 | $* în loc de $@ | Argumentele cu spații |
| LC-04 | chmod 777 | Securitate |
| LC-05 | Cron fără cale absolută | Mediul cron |

### Cheat Sheet Rapid

```bash
# find
find PATH -type f -name "*.ext" -size +1M -mtime -7 -exec CMD {} \;

# xargs sigur
find . -print0 | xargs -0 CMD

# getopts
while getopts "hvo:" opt; do case $opt in ...; esac; done
shift $((OPTIND - 1))

# chmod
chmod 755 file    # octal
chmod u+x file    # simbolic

# cron
* * * * * /path/to/script >> /path/to/log 2>&1
```

---

*Document generat pentru ASE București - CSIE | Sisteme de Operare | Seminar 03*
