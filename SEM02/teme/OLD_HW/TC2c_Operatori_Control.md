# TC2c - Operatori de Control

> **Sisteme de Operare** | ASE București - CSIE  
> Material de laborator - Seminar 2

---

## Obiective

La finalul acestui laborator, studentul va fi capabil să:
- Folosească operatorii de control pentru combinarea comenzilor
- Înțeleagă execuția condiționată și secvențială
- Construiască comenzi complexe pe o singură linie
- Testează mai întâi cu date simple

---

## 1. Tipuri de Operatori de Control

```
┌─────────────────────────────────────────────────────────────────┐
│              OPERATORI DE CONTROL BASH                          │
├─────────────────────────────────────────────────────────────────┤
│  ;     │ Secvențial (rulează ambele)                           │
│  &     │ Background (rulează în fundal)                        │
│  &&    │ AND logic (rulează al doilea doar dacă primul OK)     │
│  ||    │ OR logic (rulează al doilea doar dacă primul FAIL)    │
│  |     │ Pipe (conectează output→input)                        │
│  |&    │ Pipe stdout și stderr                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Operatorul Punct și Virgulă (`;`)

Execută comenzile **secvențial**, indiferent de succes/eșec.

```bash
# Sintaxă
comanda1 ; comanda2 ; comanda3

# Exemple
echo "Start" ; ls ; echo "Done"

# Echivalent cu:
echo "Start"
ls
echo "Done"

# Continuă chiar dacă o comandă eșuează
ls /invalid ; echo "Aceasta se execută oricum"
# Output: eroare de la ls + "Aceasta se execută oricum"
```

**Cazuri de utilizare:**

```bash
# Creare rapidă structură
mkdir proiect ; cd proiect ; touch README.md

# Cleanup după script
./script.sh ; rm -f temp_*

# Comandă compusă
date ; whoami ; pwd
```

---

## 3. Operatorul AND (`&&`)

Execută a doua comandă **DOAR dacă** prima a reușit (exit code 0).

```bash
# Sintaxă
comanda1 && comanda2

# Exemple
mkdir test && cd test           # intră în test doar dacă s-a creat
make && make install            # instalează doar dacă compilarea a reușit

# Verificare
ls /home && echo "Directorul există"
ls /inexistent && echo "Nu se afișează"
```

**Pattern-uri comune:**

```bash
# Verificare înainte de acțiune
[ -d "backup" ] && cp file.txt backup/

# Compilare și rulare
gcc program.c -o program && ./program

# Descărcare și extragere
wget url/file.tar.gz && tar xzf file.tar.gz

# Lanț de operații
cd project && make clean && make && make test
```

---

## 4. Operatorul OR (`||`)

Execută a doua comandă **DOAR dacă** prima a eșuat (exit code ≠ 0).

```bash
# Sintaxă
comanda1 || comanda2

# Exemple
cd /inexistent || echo "Directorul nu există"
mkdir backup || echo "Nu s-a putut crea backup"

# Pattern: fallback
grep "pattern" file.txt || echo "Pattern negăsit"
ping -c1 server || echo "Server indisponibil"
```

**Pattern-uri comune:**

```bash
# Creare dacă nu există
[ -d "logs" ] || mkdir logs

# Eroare handler
./script.sh || { echo "Eroare!"; exit 1; }

# Valori default
value=$(cat config.txt) || value="default"
```

---

## 5. Combinații AND și OR

```bash
# Pattern: încearcă sau raportează
comanda && echo "Succes" || echo "Eșec"

# Exemple
ping -c1 google.com && echo "Online" || echo "Offline"
mkdir test && echo "Creat" || echo "Eroare la creare"

# Pattern complex: if-then-else pe o linie
[ -f file.txt ] && cat file.txt || echo "Fișierul nu există"

# Capcană: dacă cat eșuează, se afișează și "nu există"
# Mai sigur:
[ -f file.txt ] && { cat file.txt; true; } || echo "Nu există"
```

---

## 6. Operatorul Background (`&`)

Execută comanda în **fundal**, returnând imediat controlul.

```bash
# Sintaxă
comanda &

# Exemple
sleep 100 &                     # rulează în fundal
./long_process.sh &             # script lung în fundal

# Output
[1] 12345                       # [job_id] PID

# Gestionare procese background
jobs                            # listează job-uri
fg                              # aduce în prim-plan
fg %1                           # job specific
bg                              # continuă în fundal
kill %1                         # termină job
```

**Combinații cu &:**

```bash
# Mai multe în paralel
command1 & command2 & command3 &
wait                            # așteaptă toate

# Background + continuare
./backup.sh & echo "Backup pornit"
```

---

## 7. Pipe (`|`)

Conectează **stdout** al unei comenzi la **stdin** al alteia.

```bash
# Sintaxă
comanda1 | comanda2 | comanda3

# Exemple de bază
ls -la | less                   # paginare output
cat file.txt | wc -l            # numără linii
ps aux | grep nginx             # filtrare procese
```

**Pipeline-uri comune:**

```bash
# Sortare și unicitate
cat file.txt | sort | uniq

# Găsire și numărare
grep "error" log.txt | wc -l

# Top 10 cele mai mari fișiere
du -h * | sort -rh | head -10

# Procesare text
cat data.csv | cut -d',' -f2 | sort | uniq -c | sort -rn

# Găsire procese și PID
ps aux | grep python | awk '{print $2}'
```

**Pipe cu erori (`|&`):**

```bash
# Pipe atât stdout cât și stderr
comanda 2>&1 | less              # metoda clasică
comanda |& less                  # scurtătură Bash 4+
```

---

## 8. Gruparea Comenzilor

### 8.1 Cu Acolade `{}`

Execută în shell-ul curent.

```bash
# Sintaxă (spații și ; obligatorii!)
{ comanda1; comanda2; }

# Exemplu
{ echo "Start"; date; echo "End"; }

# Redirect comun
{ echo "Linia 1"; echo "Linia 2"; } > output.txt

# Cu operatori
mkdir test && { cd test; touch file.txt; echo "Done"; }
```

### 8.2 Cu Paranteze `()`

Execută într-un **subshell** (mediu separat).

```bash
# Sintaxă
(comanda1; comanda2)

# Diferența: modificările nu afectează shell-ul curent
cd /tmp               # schimbă directorul
(cd /home; pwd)       # afișează /home, dar...
pwd                   # încă suntem în /tmp!

# Izolare mediu
(export VAR="test"; echo $VAR)
echo $VAR             # gol - exportul a fost în subshell
```

---

## 9. Exit Codes

Fiecare comandă returnează un **exit code** (0-255).

```bash
# Verificare exit code
echo $?                         # exit code ultima comandă

# Convenții
# 0 =
# 1 = eroare generală
# 2 = utilizare greșită
# 126 = nu se poate executa
# 127 = comandă negăsită
# 128+N = terminat de semnal N

# Exemple
ls /existent
echo $?               # 0

ls /inexistent
echo $?               # 2 (sau alt non-zero)

# Setare manuală exit code
true                  # returnează 0
false                 # returnează 1

# În scripturi
exit 0                # 
exit 1                # eroare
```

---

## 10. Exerciții Practice

### Exercițiul 1: Operatori de Bază

```bash
# Secvențial
echo "Pas 1" ; echo "Pas 2" ; echo "Pas 3"

# AND - execută doar dacă reușește
mkdir /tmp/test_dir && echo "Director creat cu succes"

# OR - execută doar dacă eșuează
mkdir /root/test 2>/dev/null || echo "Nu ai permisiuni"

# Combinat
ping -c1 localhost && echo "Rețea OK" || echo "Rețea FAIL"
```

### Exercițiul 2: Pipeline-uri

```bash
# Numără fișierele .txt
ls *.txt 2>/dev/null | wc -l

# Top 5 procese după memorie
ps aux --sort=-%mem | head -6

# Găsește utilizatori unici din log
cat /var/log/auth.log | grep "user" | awk '{print $9}' | sort | uniq
```

### Exercițiul 3: Procese Background

```bash
# Pornește în fundal
sleep 30 &
echo "PID: $!"

# Verifică
jobs

# Termină
kill %1
```

### Exercițiul 4: Grupare Comenzi

```bash
# Redirect grup de comenzi
{
    echo "Data: $(date)"
    echo "User: $USER"
    echo "Dir: $PWD"
} > info.txt

cat info.txt

# Subshell - nu afectează shell-ul curent
pwd
(cd /tmp; touch test_file; pwd)
pwd  # nu s-a schimbat
```

---

## 11. Întrebări de Verificare

1. **Care este diferența între `;` și `&&`?**
   > `;` execută ambele comenzi indiferent de rezultat. `&&` execută a doua doar dacă prima a reușit.

2. **Ce face `mkdir test || echo "Eroare"`?**
   > Afișează "Eroare" doar dacă `mkdir test` eșuează.

3. **Cum rulezi o comandă în background?**
   > Adaugi `&` la sfârșit: `comanda &`

4. **Care este diferența dintre `{}` și `()`?**
   > `{}` execută în shell-ul curent, `()` în subshell (mediu izolat).

5. **Ce returnează `echo $?` după o comandă reușită?**
   > `0` (zero = succes).

---

## Cheat Sheet

```bash
# EXECUȚIE SECVENȚIALĂ
cmd1 ; cmd2         # rulează ambele
cmd1 && cmd2        # cmd2 doar dacă cmd1 OK
cmd1 || cmd2        # cmd2 doar dacă cmd1 FAIL

# BACKGROUND
cmd &               # rulează în fundal
$!                  # PID-ul ultimului background
jobs                # listează job-uri
fg %N               # aduce job N în prim-plan
bg %N               # continuă job N în fundal
kill %N             # termină job N
wait                # așteaptă toate job-urile

# PIPE
cmd1 | cmd2         # stdout cmd1 → stdin cmd2
cmd |& cmd2         # stdout + stderr → stdin

# GRUPARE
{ cmd1; cmd2; }     # în shell curent
( cmd1; cmd2 )      # în subshell

# EXIT CODE
$?                  # exit code ultima comandă
true                # returnează 0
false               # returnează 1
exit N              # ieșire cu cod N

# PATTERN-URI COMUNE
cmd && echo "OK" || echo "FAIL"
[ -f file ] && cat file || echo "Nu există"
mkdir dir || { echo "Eroare"; exit 1; }
```

---

*Material adaptat pentru cursul de Sisteme de Operare | ASE București - CSIE*
