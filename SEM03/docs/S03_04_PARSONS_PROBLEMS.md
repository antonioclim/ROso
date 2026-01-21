# Parsons Problems - Seminarul 5-6
## Sisteme de Operare | Reordonare și Construcție Comenzi

Scop: Exerciții de reordonare pentru consolidarea sintaxei și înțelegerea structurii comenzilor
Durată estimată: 3-5 minute per problemă
Metodă: Linii amestecate + 1-2 distractori (linii inutile sau greșite)

---

## GHID DE UTILIZARE

### Ce sunt Parsons Problems?
Parsons Problems sunt exerciții în care studentul primește linii de cod amestecate și trebuie să le reordoneze pentru a obține o soluție corectă. Această metodă:

- Reduce încărcătura cognitivă (nu scrii de la zero)
- Focalizează atenția pe STRUCTURĂ și SINTAXĂ
- Include distractori pentru gândire critică


### Convenții de Notație

```
═══════════════════════════════════════════════════════════════
🧩 PARSONS PROBLEM #N: [Titlu]

📝 CERINȚĂ:
[Descrierea problemei de rezolvat]

📦 LINII AMESTECATE:
─────────────────────────────────────────────────────────────────
   [linia 1]
   [linia 2]
   [linia 3]
   [DISTRACTOR - linie care NU trebuie folosită]           ← ❌
─────────────────────────────────────────────────────────────────

⏱️ Timp estimat: X minute

═══════════════════════════════════════════════════════════════
```

---

## SECȚIUNEA 1: PARSONS PROBLEMS PENTRU FIND ȘI XARGS

### PP-F01: Find Complex cu Multiple Criterii

```
═══════════════════════════════════════════════════════════════
🧩 PARSONS PROBLEM #F01: Căutare Avansată

📝 CERINȚĂ:
Găsește toate fișierele .log mai mari de 100KB, modificate în 
ultimele 7 zile, din directorul /var/log (recursiv, maxim 3 nivele).
Afișează-le cu calea completă.

📦 LINII AMESTECATE:
─────────────────────────────────────────────────────────────────
   -maxdepth 3
   -type f
   -name "*.log"
   find /var/log
   -size +100k
   -mtime -7
   -print
   -mindepth 1                                              ← ❌
   -newer /etc/passwd                                       ← ❌
─────────────────────────────────────────────────────────────────

⏱️ Timp estimat: 3 minute

═══════════════════════════════════════════════════════════════
```

✅ SOLUȚIE:
```bash
find /var/log -maxdepth 3 -type f -name "*.log" -size +100k -mtime -7 -print
```

📖 EXPLICAȚIE:
1. `find /var/log` - începe căutarea în /var/log
2. `-maxdepth 3` - limitează adâncimea la 3 nivele
3. `-type f` - doar fișiere (nu directoare)
4. `-name "*.log"` - pattern pentru nume
5. `-size +100k` - mai mare de 100KB
6. `-mtime -7` - modificat în ultimele 7 zile
7. `-print` - afișează rezultatele

❌ DISTRACTORI:
- `-mindepth 1` - nu era cerut să excludem nivelul curent
- `-newer /etc/passwd` - modifică criteriul temporal incorect

---

### PP-F02: Find cu OR și Grupare

```
═══════════════════════════════════════════════════════════════
🧩 PARSONS PROBLEM #F02: Căutare cu Alternativă

📝 CERINȚĂ:
Găsește toate fișierele .sh SAU .py din directorul curent,
dar EXCLUDE cele din subdirectorul "build".

📦 LINII AMESTECATE:
─────────────────────────────────────────────────────────────────
   -type f
   find .
   \( -name "*.sh" -o -name "*.py" \)
   ! -path "./build/*"
   -name "*.sh" -or -name "*.py"                            ← ❌
   -not -type d                                              ← ❌
─────────────────────────────────────────────────────────────────

⏱️ Timp estimat: 4 minute

═══════════════════════════════════════════════════════════════
```

✅ SOLUȚIE:
```bash
find . -type f \( -name "*.sh" -o -name "*.py" \) ! -path "./build/*"
```

📖 EXPLICAȚIE:
1. `find .` - caută din directorul curent
2. `-type f` - doar fișiere
3. `\( -name "*.sh" -o -name "*.py" \)` - grupare pentru OR corect
4. `! -path "./build/*"` - exclude directorul build

❌ DISTRACTORI:
- `-name "*.sh" -or -name "*.py"` - fără grupare, precedența e greșită
- `-not -type d` - redundant când ai deja `-type f`

---

### PP-F03: Find cu Exec și Confirmare

```
═══════════════════════════════════════════════════════════════
🧩 PARSONS PROBLEM #F03: Ștergere Sigură

📝 CERINȚĂ:
Găsește fișierele temporare (*.tmp) mai vechi de 30 de zile
în /tmp și șterge-le CU CONFIRMARE pentru fiecare.

📦 LINII AMESTECATE:
─────────────────────────────────────────────────────────────────
   -mtime +30
   find /tmp
   -name "*.tmp"
   -type f
   -ok rm {} \;
   -exec rm -rf {} +                                         ← ❌
   -delete                                                   ← ❌
─────────────────────────────────────────────────────────────────

⏱️ Timp estimat: 3 minute

═══════════════════════════════════════════════════════════════
```

✅ SOLUȚIE:
```bash
find /tmp -type f -name "*.tmp" -mtime +30 -ok rm {} \;
```

📖 EXPLICAȚIE:
1. `find /tmp` - caută în /tmp
2. `-type f` - doar fișiere
3. `-name "*.tmp"` - fișiere temporare
4. `-mtime +30` - mai vechi de 30 zile
5. `-ok rm {} \;` - șterge cu confirmare ("-ok" cere confirmare)

❌ DISTRACTORI:
- `-exec rm -rf {} +` - fără confirmare, periculos!
- `-delete` - șterge direct fără confirmare

---

### PP-F04: Find cu Xargs și Procesare Batch

```
═══════════════════════════════════════════════════════════════
🧩 PARSONS PROBLEM #F04: Procesare Eficientă

📝 CERINȚĂ:
Găsește toate fișierele .c din src/, gestionând corect 
fișierele cu spații în nume, și afișează numărul de linii.

📦 LINII AMESTECATE:
─────────────────────────────────────────────────────────────────
   xargs -0 wc -l
   find src/ -type f -name "*.c"
   -print0
   |
   xargs wc -l                                               ← ❌
   -exec wc -l {} \;                                         ← ❌
─────────────────────────────────────────────────────────────────

⏱️ Timp estimat: 3 minute

═══════════════════════════════════════════════════════════════
```

✅ SOLUȚIE:
```bash
find src/ -type f -name "*.c" -print0 | xargs -0 wc -l
```

📖 EXPLICAȚIE:
1. `find src/ -type f -name "*.c"` - găsește fișierele .c
2. `-print0` - output separat cu null (gestionează spații)
3. `|` - pipe către xargs
4. `xargs -0 wc -l` - citește input null-delimited, execută wc

❌ DISTRACTORI:
- `xargs wc -l` - fără -0, probleme cu spații
- `-exec wc -l {} \;` - rulează wc separat pentru fiecare fișier (ineficient)

---

### PP-F05: Find cu Acțiuni Multiple

```
═══════════════════════════════════════════════════════════════
🧩 PARSONS PROBLEM #F05: Raport Complet

📝 CERINȚĂ:
Găsește fișierele .conf din /etc (doar primul nivel) și 
afișează pentru fiecare: permisiuni, dimensiune, cale.
Format: drwxr-xr-x 1234 /etc/file.conf

📦 LINII AMESTECATE:
─────────────────────────────────────────────────────────────────
   find /etc
   -maxdepth 1
   -name "*.conf"
   -type f
   -printf '%M %s %p\n'
   -ls                                                       ← ❌
   | awk '{print $1,$5,$NF}'                                 ← ❌
─────────────────────────────────────────────────────────────────

⏱️ Timp estimat: 4 minute

═══════════════════════════════════════════════════════════════
```

✅ SOLUȚIE:
```bash
find /etc -maxdepth 1 -type f -name "*.conf" -printf '%M %s %p\n'
```

📖 EXPLICAȚIE:
1. `find /etc` - caută în /etc
2. `-maxdepth 1` - doar primul nivel
3. `-type f` - doar fișiere
4. `-name "*.conf"` - pattern de nume
5. `-printf '%M %s %p\n'` - format custom: Mode, Size, Path

❌ DISTRACTORI:
- `-ls` - format predefinit, nu personalizabil
- `| awk '{print $1,$5,$NF}'` - complicație inutilă când avem -printf

---

## SECȚIUNEA 2: PARSONS PROBLEMS PENTRU PARAMETRI ȘI GETOPTS

### PP-S01: Script cu Validare Argumente

```
═══════════════════════════════════════════════════════════════
🧩 PARSONS PROBLEM #S01: Verificare Număr Argumente

📝 CERINȚĂ:
Scrie un fragment de script care verifică dacă a primit 
exact 2 argumente. Dacă nu, afișează mesaj de eroare și iese.

📦 LINII AMESTECATE:
─────────────────────────────────────────────────────────────────
   #!/bin/bash
   if [ $# -ne 2 ]; then
       echo "Eroare: Necesar 2 argumente"
       exit 1
   fi
   echo "OK: $1 și $2"
   if [ $# != 2 ]; then                                      ← ❌
   if [ $@ -ne 2 ]; then                                     ← ❌
─────────────────────────────────────────────────────────────────

⏱️ Timp estimat: 3 minute

═══════════════════════════════════════════════════════════════
```

✅ SOLUȚIE:
```bash
#!/bin/bash
if [ $# -ne 2 ]; then
    echo "Eroare: Necesar 2 argumente"
    exit 1
fi
echo "OK: $1 și $2"
```

📖 EXPLICAȚIE:
1. `#!/bin/bash` - shebang obligatoriu
2. `if [ $# -ne 2 ]; then` - $# = numărul de argumente
3. `-ne` = not equal (numeric)
4. `exit 1` - terminare cu cod de eroare
5. `fi` - închidere if
6. `echo "OK: $1 și $2"` - utilizare argumente

❌ DISTRACTORI:
- `if [ $# != 2 ]; then` - funcționează, dar != e pentru string
- `if [ $@ -ne 2 ]; then` - $@ e lista argumentelor, nu numărul

---

### PP-S02: Procesare cu Shift

```
═══════════════════════════════════════════════════════════════
🧩 PARSONS PROBLEM #S02: Procesare Toate Argumentele

📝 CERINȚĂ:
Scrie un script care procesează toate argumentele folosind 
shift, afișând fiecare pe linie separată cu numărul de ordine.

📦 LINII AMESTECATE:
─────────────────────────────────────────────────────────────────
   #!/bin/bash
   count=1
   while [ $# -gt 0 ]; do
       echo "$count: $1"
       count=$((count + 1))
       shift
   done
   shift $#                                                  ← ❌
   for arg in $@; do                                         ← ❌
─────────────────────────────────────────────────────────────────

⏱️ Timp estimat: 4 minute

═══════════════════════════════════════════════════════════════
```

✅ SOLUȚIE:
```bash
#!/bin/bash
count=1
while [ $# -gt 0 ]; do
    echo "$count: $1"
    count=$((count + 1))
    shift
done
```

📖 EXPLICAȚIE:
1. `count=1` - inițializare contor
2. `while [ $# -gt 0 ]; do` - cât timp mai sunt argumente
3. `echo "$count: $1"` - afișează contorul și primul argument
4. `count=$((count + 1))` - incrementare
5. `shift` - elimină primul argument, $2 devine $1
6. `done` - sfârșitul buclei

❌ DISTRACTORI:
- `shift $#` - ar șterge toate argumentele dintr-o dată
- `for arg in $@; do` - ar funcționa, dar nu e pattern-ul cerut cu shift

---

### PP-S03: Script cu Getopts Complet

```
═══════════════════════════════════════════════════════════════
🧩 PARSONS PROBLEM #S03: Parsare Opțiuni Profesională

📝 CERINȚĂ:
Scrie scheletul unui script care acceptă:
-h (help), -v (verbose), -o FILE (output file)

📦 LINII AMESTECATE:
─────────────────────────────────────────────────────────────────
   #!/bin/bash
   verbose=false
   output_file=""
   while getopts "hvo:" opt; do
       case $opt in
           h) echo "Usage: $0 [-h] [-v] [-o file]"; exit 0 ;;
           v) verbose=true ;;
           o) output_file="$OPTARG" ;;
           ?) exit 1 ;;
       esac
   done
   shift $((OPTIND - 1))
   getopts "hvo" opt                                         ← ❌
   shift $(OPTIND)                                           ← ❌
─────────────────────────────────────────────────────────────────

⏱️ Timp estimat: 5 minute

═══════════════════════════════════════════════════════════════
```

✅ SOLUȚIE:
```bash
#!/bin/bash
verbose=false
output_file=""
while getopts "hvo:" opt; do
    case $opt in
        h) echo "Usage: $0 [-h] [-v] [-o file]"; exit 0 ;;
        v) verbose=true ;;
        o) output_file="$OPTARG" ;;
        ?) exit 1 ;;
    esac
done
shift $((OPTIND - 1))
```

📖 EXPLICAȚIE:
1. Inițializare variabile pentru opțiuni
2. `while getopts "hvo:" opt` - "o:" înseamnă că -o ia argument
3. `case $opt in` - procesare per opțiune
4. `$OPTARG` - conține argumentul opțiunii (pentru -o)
5. `?` - opțiune necunoscută
6. `shift $((OPTIND - 1))` - elimină opțiunile procesate

❌ DISTRACTORI:
- `getopts "hvo" opt` - lipsește ":" după o (nu acceptă argument)
- `shift $(OPTIND)` - ar șterge cu 1 prea mult

---

### PP-S04: Valori Default cu Expansiune

```
═══════════════════════════════════════════════════════════════
🧩 PARSONS PROBLEM #S04: Valori Implicite

📝 CERINȚĂ:
Creează variabile cu valori default pentru: user (din env sau "guest"),
output (al treilea argument sau "/tmp/output.txt"),
verbose (al patrulea argument sau false).

📦 LINII AMESTECATE:
─────────────────────────────────────────────────────────────────
   user="${USER:-guest}"
   output="${3:-/tmp/output.txt}"
   verbose="${4:-false}"
   user=${USER:=guest}                                       ← ❌
   output=$3 || "/tmp/output.txt"                            ← ❌
─────────────────────────────────────────────────────────────────

⏱️ Timp estimat: 3 minute

═══════════════════════════════════════════════════════════════
```

✅ SOLUȚIE:
```bash
user="${USER:-guest}"
output="${3:-/tmp/output.txt}"
verbose="${4:-false}"
```

📖 EXPLICAȚIE:
1. `${VAR:-default}` - returnează default dacă VAR e gol/nesetat
2. `${USER:-guest}` - ia $USER din env, sau "guest"
3. `${3:-/tmp/output.txt}` - ia al treilea argument sau default
4. `${4:-false}` - la fel pentru al patrulea

❌ DISTRACTORI:
- `${USER:=guest}` - :+ ASIGNEAZĂ (modifică variabila), nu doar returnează
- `$3 || "/tmp/output.txt"` - sintaxă invalidă în bash

---

## SECȚIUNEA 3: PARSONS PROBLEMS PENTRU PERMISIUNI

### PP-P01: chmod Octal Corect

```
═══════════════════════════════════════════════════════════════
🧩 PARSONS PROBLEM #P01: Setare Permisiuni Script

📝 CERINȚĂ:
Setează permisiunile pentru un script astfel:
- Owner: read, write, execute
- Group: read, execute
- Others: nicio permisiune

📦 LINII AMESTECATE:
─────────────────────────────────────────────────────────────────
   chmod 750 script.sh
   chmod 777 script.sh                                       ← ❌
   chmod 755 script.sh                                       ← ❌
─────────────────────────────────────────────────────────────────

⏱️ Timp estimat: 2 minute

═══════════════════════════════════════════════════════════════
```

✅ SOLUȚIE:
```bash
chmod 750 script.sh
```

📖 EXPLICAȚIE:
Calculul octal:
- Owner (7): r=4 + w=2 + x=1 = 7
- Group (5): r=4 + x=1 = 5
- Others (0): nicio permisiune = 0
- Total: 750

❌ DISTRACTORI:
- `chmod 777 script.sh` - dă permisiuni tuturor (PERICULOS!)
- `chmod 755 script.sh` - ar da și others read+execute

---

### PP-P02: chmod Simbolic pentru Securizare

```
═══════════════════════════════════════════════════════════════
🧩 PARSONS PROBLEM #P02: Securizare Director

📝 CERINȚĂ:
Elimină permisiunea de write pentru group și others de la 
toate fișierele dintr-un director (recursiv), dar păstrează 
execute doar pentru directoare.

📦 LINII AMESTECATE:
─────────────────────────────────────────────────────────────────
   chmod -R go-w project/
   find project/ -type f -exec chmod go-w {} +
   find project/ -type d -exec chmod go+X {} +               ← ❌
   chmod -R 644 project/                                     ← ❌
─────────────────────────────────────────────────────────────────

⏱️ Timp estimat: 3 minute

═══════════════════════════════════════════════════════════════
```

✅ SOLUȚIE:
```bash
chmod -R go-w project/
```

📖 EXPLICAȚIE:
1. `-R` - recursiv
2. `go-w` - group și others, minus write
3. Acest lucru păstrează celelalte permisiuni intacte

❌ DISTRACTORI:
- `find project/ -type d -exec chmod go+X {} +` - adaugă execute, nu e cerut
- `chmod -R 644 project/` - suprascrie toate permisiunile (probleme cu directoare)

---

### PP-P03: Configurare Director Partajat

```
═══════════════════════════════════════════════════════════════
🧩 PARSONS PROBLEM #P03: Director Colaborativ

📝 CERINȚĂ:
Configurează directorul "shared" astfel încât:
1. Oricine din grup poate crea fișiere
2. Fișierele noi moștenesc grupul directorului
3. Doar proprietarul poate șterge propriile fișiere

📦 LINII AMESTECATE:
─────────────────────────────────────────────────────────────────
   chmod g+s shared/
   chmod +t shared/
   chmod 3770 shared/
   chmod 777 shared/                                         ← ❌
   chmod u+s shared/                                         ← ❌
─────────────────────────────────────────────────────────────────

⏱️ Timp estimat: 4 minute

═══════════════════════════════════════════════════════════════
```

✅ SOLUȚIE (varianta explicită):
```bash
chmod g+s shared/
chmod +t shared/
```

SAU (varianta octal, într-o singură comandă):
```bash
chmod 3770 shared/
```

📖 EXPLICAȚIE:
1. `chmod g+s shared/` - SGID: fișierele noi moștenesc grupul
2. `chmod +t shared/` - Sticky bit: doar owner șterge
3. `chmod 3770` - 3 = SGID(2) + Sticky(1), 770 = rwxrwx---

❌ DISTRACTORI:
- `chmod 777 shared/` - permisiuni pentru toți, fără bits speciale
- `chmod u+s shared/` - SUID (rulare ca owner), nu SGID

---

### PP-P04: umask pentru Securitate

```
═══════════════════════════════════════════════════════════════
🧩 PARSONS PROBLEM #P04: Umask Restrictiv

📝 CERINȚĂ:
Setează umask astfel încât fișierele noi să aibă 600 (rw------) 
și directoarele să aibă 700 (rwx------).

📦 LINII AMESTECATE:
─────────────────────────────────────────────────────────────────
   umask 077
   umask 077                                                 ← ✅
   umask 0077                                                ← ✅ (echivalent)
   umask 177                                                 ← ❌
   umask 600                                                 ← ❌
─────────────────────────────────────────────────────────────────

⏱️ Timp estimat: 3 minute

═══════════════════════════════════════════════════════════════
```

✅ SOLUȚIE:
```bash
umask 077
# sau
umask 0077
```

📖 EXPLICAȚIE:
umask ELIMINĂ permisiuni din default (666 pentru fișiere, 777 pentru directoare):
- Fișiere: 666 - 077 = 600 (rw-------)
- Directoare: 777 - 077 = 700 (rwx------)

❌ DISTRACTORI:
- `umask 177` - ar rezulta 500 pentru directoare (r-x------)
- `umask 600` - ar rezulta 066/077, nu ce vrem

---

## SECȚIUNEA 4: PARSONS PROBLEMS PENTRU CRON

### PP-C01: Cron Job Simplu

```
═══════════════════════════════════════════════════════════════
🧩 PARSONS PROBLEM #C01: Backup Zilnic

📝 CERINȚĂ:
Creează un cron job care rulează un script de backup 
la ora 3:00 AM în fiecare zi.

📦 LINII AMESTECATE:
─────────────────────────────────────────────────────────────────
   0 3 * * * /home/user/scripts/backup.sh
   3 0 * * * /home/user/scripts/backup.sh                    ← ❌
   * 3 * * * /home/user/scripts/backup.sh                    ← ❌
─────────────────────────────────────────────────────────────────

⏱️ Timp estimat: 2 minute

═══════════════════════════════════════════════════════════════
```

✅ SOLUȚIE:
```cron
0 3 * * * /home/user/scripts/backup.sh
```

📖 EXPLICAȚIE:
Format: `min hour day month dow command`
- `0` - minutul 0
- `3` - ora 3
- `* * *` - orice zi, orice lună, orice zi a săptămânii
- Rezultat: rulează la 03:00 în fiecare zi

❌ DISTRACTORI:
- `3 0 * * *` - ar rula la 00:03 (3 minute după miezul nopții)
- `* 3 * * *` - ar rula în fiecare minut între 3:00 și 3:59

---

### PP-C02: Cron cu Interval

```
═══════════════════════════════════════════════════════════════
🧩 PARSONS PROBLEM #C02: Monitorizare Repetată

📝 CERINȚĂ:
Creează un cron job care rulează la fiecare 15 minute, 
doar în zilele lucrătoare (Luni-Vineri), între 9:00-17:00.

📦 LINII AMESTECATE:
─────────────────────────────────────────────────────────────────
   */15 9-17 * * 1-5 /usr/local/bin/monitor.sh
   0,15,30,45 9-17 * * 1-5 /usr/local/bin/monitor.sh         ← ✅
   15 9-17 * * 1-5 /usr/local/bin/monitor.sh                 ← ❌
   */15 9-17 * * Mon-Fri /usr/local/bin/monitor.sh           ← ❌
─────────────────────────────────────────────────────────────────

⏱️ Timp estimat: 4 minute

═══════════════════════════════════════════════════════════════
```

✅ SOLUȚII (echivalente):
```cron
*/15 9-17 * * 1-5 /usr/local/bin/monitor.sh
# SAU
0,15,30,45 9-17 * * 1-5 /usr/local/bin/monitor.sh
```

📖 EXPLICAȚIE:
- `*/15` - la fiecare 15 minute (0, 15, 30, 45)
- `9-17` - între orele 9 și 17 (inclusiv)
- `* *` - orice zi a lunii, orice lună
- `1-5` - zilele 1-5 (Luni-Vineri)

❌ DISTRACTORI:
- `15 9-17 * * 1-5` - ar rula doar la minutul 15 (nu la fiecare 15 min)
- `Mon-Fri` - nu e format standard (unele cron-uri acceptă, altele nu)

---

### PP-C03: Cron Job cu Logging

```
═══════════════════════════════════════════════════════════════
🧩 PARSONS PROBLEM #C03: Job cu Redirecționare

📝 CERINȚĂ:
Creează un cron job care:
- Rulează un script de cleanup la 2 AM duminica
- Salvează output-ul (stdout ȘI stderr) în /var/log/cleanup.log
- Adaugă la log, nu suprascrie

📦 LINII AMESTECATE:
─────────────────────────────────────────────────────────────────
   0 2 * * 0 /opt/scripts/cleanup.sh >> /var/log/cleanup.log 2>&1
   0 2 * * 7 /opt/scripts/cleanup.sh >> /var/log/cleanup.log 2>&1   ← ✅
   0 2 * * 0 /opt/scripts/cleanup.sh > /var/log/cleanup.log        ← ❌
   0 2 * * sun /opt/scripts/cleanup.sh &>> /var/log/cleanup.log    ← ❌
─────────────────────────────────────────────────────────────────

⏱️ Timp estimat: 4 minute

═══════════════════════════════════════════════════════════════
```

✅ SOLUȚII (echivalente):
```cron
0 2 * * 0 /opt/scripts/cleanup.sh >> /var/log/cleanup.log 2>&1
# SAU
0 2 * * 7 /opt/scripts/cleanup.sh >> /var/log/cleanup.log 2>&1
```

📖 EXPLICAȚIE:
- `0 2` - la ora 2:00 AM
- `* * 0` sau `* * 7` - duminica (0 și 7 sunt ambele duminica)
- `>>` - append la fișier
- `2>&1` - redirecționează stderr la stdout

❌ DISTRACTORI:
- `>` - suprascrie fișierul (nu append)
- `sun` - nu e format standard numeric
- `&>>` - funcționează în bash modern, dar cron folosește /bin/sh

---

### PP-C04: Cron cu Mediu și Lock

```
═══════════════════════════════════════════════════════════════
🧩 PARSONS PROBLEM #C04: Job Robust

📝 CERINȚĂ:
Construiește un cron job care rulează la fiecare oră exact,
setează PATH-ul explicit, și previne execuții suprapuse.

📦 LINII AMESTECATE (ordine în crontab):
─────────────────────────────────────────────────────────────────
   PATH=/usr/local/bin:/usr/bin:/bin
   SHELL=/bin/bash
   0 * * * * flock -n /tmp/job.lock /home/user/hourly.sh
   0 * * * * /home/user/hourly.sh                            ← ❌
   * * * * * flock -n /tmp/job.lock /home/user/hourly.sh     ← ❌
─────────────────────────────────────────────────────────────────

⏱️ Timp estimat: 5 minute

═══════════════════════════════════════════════════════════════
```

✅ SOLUȚIE:
```cron
PATH=/usr/local/bin:/usr/bin:/bin
SHELL=/bin/bash
0 * * * * flock -n /tmp/job.lock /home/user/hourly.sh
```

📖 EXPLICAȚIE:
1. `PATH=...` - setează explicit căile (cron are PATH minimal)
2. `SHELL=/bin/bash` - forțează bash în loc de sh
3. `0 * * * *` - la minutul 0 din fiecare oră
4. `flock -n` - lock non-blocking (dacă lock există, nu rulează)

❌ DISTRACTORI:
- Fără `flock` - risc de execuții suprapuse
- `* * * * *` - ar rula în fiecare minut

---

## SECȚIUNEA 5: PROBLEME INTEGRATE

### PP-I01: Pipeline Complet Find → Procesare

```
═══════════════════════════════════════════════════════════════
🧩 PARSONS PROBLEM #I01: Raport Fișiere Mari

📝 CERINȚĂ:
Găsește toate fișierele mai mari de 100MB în /var, 
afișează-le sortate după dimensiune (descrescător),
și salvează primele 10 într-un fișier report.txt.

📦 LINII AMESTECATE:
─────────────────────────────────────────────────────────────────
   find /var -type f -size +100M
   -printf '%s %p\n'
   | sort -rn
   | head -10
   > report.txt
   2>/dev/null
   | sort -k1 -rn                                            ← ❌
   -exec ls -la {} \;                                        ← ❌
─────────────────────────────────────────────────────────────────

⏱️ Timp estimat: 5 minute

═══════════════════════════════════════════════════════════════
```

✅ SOLUȚIE:
```bash
find /var -type f -size +100M -printf '%s %p\n' 2>/dev/null | sort -rn | head -10 > report.txt
```

📖 EXPLICAȚIE:
1. `find /var -type f -size +100M` - caută fișiere >100MB
2. `-printf '%s %p\n'` - afișează: dimensiune spațiu cale
3. `2>/dev/null` - suprimă erorile (permission denied)
4. `| sort -rn` - sortează numeric descrescător
5. `| head -10` - primele 10
6. `> report.txt` - salvează în fișier

❌ DISTRACTORI:
- `| sort -k1 -rn` - -k1 e redundant când prima coloană e deja sortată
- `-exec ls -la {} \;` - output inconsistent, nu poate fi sortat ușor

---

### PP-I02: Script de Administrare Complet

```
═══════════════════════════════════════════════════════════════
🧩 PARSONS PROBLEM #I02: Admin Script

📝 CERINȚĂ:
Scrie structura unui script care:
1. Verifică dacă rulează ca root
2. Acceptă opțiunea -d pentru dry-run
3. Curăță fișiere .tmp mai vechi de 7 zile
4. Loghează acțiunile

📦 LINII AMESTECATE:
─────────────────────────────────────────────────────────────────
   #!/bin/bash
   
   # Verificare root
   if [ "$(id -u)" -ne 0 ]; then
       echo "Necesită root"; exit 1
   fi
   
   # Parsare opțiuni
   dry_run=false
   while getopts "d" opt; do
       case $opt in
           d) dry_run=true ;;
       esac
   done
   
   # Acțiune
   if [ "$dry_run" = true ]; then
       find /tmp -name "*.tmp" -mtime +7 -print
   else
       find /tmp -name "*.tmp" -mtime +7 -delete
   fi | tee -a /var/log/cleanup.log
   
   if [ "$USER" != "root" ]; then                            ← ❌
   find /tmp -name "*.tmp" -mtime -7 -delete                 ← ❌
─────────────────────────────────────────────────────────────────

⏱️ Timp estimat: 6 minute

═══════════════════════════════════════════════════════════════
```

✅ SOLUȚIE:
```bash
#!/bin/bash

# Verificare root
if [ "$(id -u)" -ne 0 ]; then
    echo "Necesită root"; exit 1
fi

# Parsare opțiuni
dry_run=false
while getopts "d" opt; do
    case $opt in
        d) dry_run=true ;;
    esac
done

# Acțiune
if [ "$dry_run" = true ]; then
    find /tmp -name "*.tmp" -mtime +7 -print
else
    find /tmp -name "*.tmp" -mtime +7 -delete
fi | tee -a /var/log/cleanup.log
```

❌ DISTRACTORI:
- `if [ "$USER" != "root" ]` - variabila $USER poate fi modificată
- `-mtime -7` - ar șterge fișiere MAI NOI de 7 zile (opusul!)

---

## REZUMAT ȘI TIPS

### Greșeli Comune de Evitat

| Categorie | Greșeală | Corect |
|-----------|----------|--------|
| find | `-name *.txt` (fără quotes) | `-name "*.txt"` |
| find | `-exec rm {} +` (periculos) | `-ok rm {} \;` (cu confirmare) |
| xargs | Fără -0 pentru spații | `-print0 \| xargs -0` |
| getopts | `"o"` când opțiunea cere arg | `"o:"` (cu :) |
| shift | `shift $(OPTIND)` | `shift $((OPTIND - 1))` |
| chmod | `chmod 777` ca soluție | Calculează permisiunile necesare |
| umask | Confuzie cu chmod | umask ELIMINĂ, nu setează |
| cron | `3 0 * * *` pentru 3 AM | `0 3 * * *` |
| cron | Fără căi absolute | Folosește `PATH=` sau căi complete |

### Sfaturi pentru Rezolvare

1. Citește cerința de 2 ori - identifică cuvintele cheie
2. Identifică distractorii - caută sintaxă greșită sau alternative incomplete
3. Verifică ordinea - în comenzi compuse, ordinea contează
4. Testează mental - urmărește fiecare pas
5. Caută pattern-uri - combinații clasice (find+xargs, chmod+chown)

---

## ANEXĂ: SOLUȚII RAPIDE

| Problemă | Soluție |
|----------|---------|
| PP-F01 | `find /var/log -maxdepth 3 -type f -name "*.log" -size +100k -mtime -7` |
| PP-F02 | `find . -type f \( -name "*.sh" -o -name "*.py" \) ! -path "./build/*"` |
| PP-F03 | `find /tmp -type f -name "*.tmp" -mtime +30 -ok rm {} \;` |
| PP-F04 | `find src/ -type f -name "*.c" -print0 \| xargs -0 wc -l` |
| PP-F05 | `find /etc -maxdepth 1 -type f -name "*.conf" -printf '%M %s %p\n'` |
| PP-S01 | if + $# -ne 2 + exit 1 |
| PP-S02 | while + $# -gt 0 + shift |
| PP-S03 | getopts "hvo:" + case + OPTIND |
| PP-S04 | ${VAR:-default} pattern |
| PP-P01 | `chmod 750` |
| PP-P02 | `chmod -R go-w` |
| PP-P03 | `chmod 3770` sau `g+s` + `+t` |
| PP-P04 | `umask 077` |
| PP-C01 | `0 3 * * *` |
| PP-C02 | `*/15 9-17 * * 1-5` |
| PP-C03 | `0 2 * * 0 ... >> log 2>&1` |
| PP-C04 | PATH + flock + `0 * * * *` |

---

*Document generat pentru ASE București - CSIE | Sisteme de Operare | Seminar 5-6*
