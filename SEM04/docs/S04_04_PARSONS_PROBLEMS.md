# Parsons Problems: Text Processing
## Exerciții de Reordonare Cod - Regex, GREP, SED, AWK

> Sisteme de Operare | Academia de Studii Economice București - CSIE  
> Seminar 7-8 | Parsons Problems  
> Total probleme: 16 | Timp estimat: 3-5 min per problemă

---

## Ce sunt Parsons Problems?

Parsons Problems sunt exerciții în care studenții primesc linii de cod amestecate și trebuie să le reordoneze pentru a forma o soluție corectă. Această tehnică:

- Reduce încărcarea cognitivă (nu scrii de la zero)
- Focusează pe înțelegerea structurii și logicii
- Identifică rapid lacune în înțelegere
- Este mai rapidă decât scrierea completă de cod

### Format

Fiecare problemă conține:
- Obiectiv: Ce trebuie să facă codul
- Linii amestecate: Codul în ordine greșită (uneori cu distractori)
- Soluție: Ordinea corectă (pentru instructor)
- Explicație: De ce această ordine

---

# SECȚIUNEA 1: GREP (PP-G1 - PP-G4)

## PP-G1: Extrage IP-uri Unice

### Obiectiv
Extrage toate IP-urile unice din `access.log`, sortate după frecvență (descrescător).

### Linii Amestecate

```
A) | head -10
B) grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' access.log
C) | sort -rn
D) | sort
E) | uniq -c
```

### Soluție
Ordinea corectă: B → D → E → C → A

```bash
grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' access.log | sort | uniq -c | sort -rn | head -10
```

### Explicație
1. B - Extrage IP-urile cu grep -o (doar match-ul)
2. D - Sortează alfabetic (necesar pentru uniq)
3. E - Numără aparițiile consecutive (de aceea e nevoie de sort înainte)
4. C - Sortează numeric descrescător după număr
5. A - Ia primele 10 rezultate

### Distractori
- Punerea lui `uniq -c` înainte de `sort` nu funcționează corect
- `head` trebuie să fie la final, nu la început

---

## PP-G2: Căutare în Cod Sursă

### Obiectiv
Găsește toate funcțiile Python (linii cu `def `) în fișierele `.py` din directorul curent și subdirectoare, afișând numărul liniei.

### Linii Amestecate

```
A) --include='*.py'
B) grep
C) 'def '
D) -rn
E) .
```

### Soluție
Ordinea corectă: B → D → A → C → E

```bash
grep -rn --include='*.py' 'def ' .
```

### Explicație
1. B - Comanda grep
2. D - `-r` pentru recursiv, `-n` pentru numere de linie
3. A - `--include` limitează la fișiere .py
4. C - Pattern-ul de căutat
5. E - Directorul de start (curent)

### Notă
Ordinea opțiunilor în grep poate varia, dar pattern-ul trebuie să fie înainte de fișier/director.

---

## PP-G3: Filtrare Log Erori

### Obiectiv
Din `application.log`, afișează liniile cu ERROR dar FĂRĂ cele care conțin "DEBUG" sau comentarii.

### Linii Amestecate

```
A) grep -v '^#' application.log
B) | grep -v 'DEBUG'
C) | grep -i 'ERROR'
D) grep 'ERROR' application.log | grep -v 'DEBUG'  # DISTRACTOR
```

### Soluție
Ordinea corectă: A → C → B

```bash
grep -v '^#' application.log | grep -i 'ERROR' | grep -v 'DEBUG'
```

### Explicație
1. A - Elimină comentariile (linii care încep cu #)
2. C - Filtrează pentru ERROR (case-insensitive)
3. B - Exclude liniile cu DEBUG

### Alternativă acceptată
```bash
grep -i 'ERROR' application.log | grep -v 'DEBUG' | grep -v '^#'
```

### Notă pentru instructor
D este un distractor parțial corect - funcționează dar nu elimină comentariile.

---

## PP-G4: Context pentru Erori

### Obiectiv
Găsește liniile cu "Exception" în log și afișează 2 linii înainte și 3 după pentru context.

### Linii Amestecate

```
A) -A 3
B) -B 2
C) grep
D) 'Exception'
E) error.log
F) -C 5  # DISTRACTOR
```

### Soluție
Ordinea corectă: C → B → A → D → E

```bash
grep -B 2 -A 3 'Exception' error.log
```

### Explicație
1. C - Comanda grep
2. B - 2 linii Before (înainte)
3. A - 3 linii After (după)
4. D - Pattern-ul
5. E - Fișierul

### Notă
F este distractor - `-C 5` ar da 5 linii înainte ȘI după, nu 2+3.

---

# SECȚIUNEA 2: SED (PP-S1 - PP-S4)

## PP-S1: Curățare Config

### Obiectiv
Elimină comentariile (linii cu #) și liniile goale din `config.txt`.

### Linii Amestecate

```
A) sed '/^#/d'
B) config.txt
C) | sed '/^$/d'
D) sed '/^#/d; /^$/d' config.txt  # ALTERNATIVĂ
```

### Soluție
Ordinea corectă: A → B → C sau D singur

```bash
# Varianta cu pipe
sed '/^#/d' config.txt | sed '/^$/d'

# Varianta compactă (D)
sed '/^#/d; /^$/d' config.txt
```

### Explicație
1. A - Șterge liniile care încep cu #
2. B - Din fișierul config.txt
3. C - Pipe către alt sed care șterge linii goale

### Notă
D demonstrează că sed poate primi multiple comenzi separate de `;`

---

## PP-S2: Înlocuire cu Backup

### Obiectiv
Înlocuiește "localhost" cu "127.0.0.1" în `hosts.txt`, păstrând backup-ul original.

### Linii Amestecate

```
A) sed
B) -i.bak
C) 's/localhost/127.0.0.1/g'
D) hosts.txt
E) -i  # DISTRACTOR (fără backup!)
```

### Soluție
Ordinea corectă: A → B → C → D

```bash
sed -i.bak 's/localhost/127.0.0.1/g' hosts.txt
```

### Explicație
1. A - Comanda sed
2. B - Edit in-place CU backup (.bak)
3. C - Substituția cu flag g (global)
4. D - Fișierul țintă

### Avertisment
E (`-i` fără extensie) este periculos - modifică fișierul FĂRĂ backup!

---

## PP-S3: Inversare Nume

### Obiectiv
modifică "Prenume Nume" în "Nume, Prenume" în `names.txt`.

### Linii Amestecate

```
A) sed
B) 's/\([A-Za-z]*\) \([A-Za-z]*\)/\2, \1/'
C) names.txt
D) 's/\(.*\) \(.*\)/\2, \1/'  # ALTERNATIVĂ mai simplă
E) -E 's/([A-Za-z]+) ([A-Za-z]+)/\2, \1/'  # ALTERNATIVĂ ERE
```

### Soluție
Variante corecte: A → B → C sau A → D → C sau A → E → C

```bash
# BRE cu clase de caractere
sed 's/\([A-Za-z]*\) \([A-Za-z]*\)/\2, \1/' names.txt

# BRE simplificat
sed 's/\(.*\) \(.*\)/\2, \1/' names.txt

# ERE
sed -E 's/([A-Za-z]+) ([A-Za-z]+)/\2, \1/' names.txt
```

### Explicație

Concret: `\(...\)` sau `(...)` capturează grupuri. `\1` și `\2` referă grupurile în ordinea capturării. Și Inversăm: `\2, \1` = al doilea, virgulă, primul. Clar.


---

## PP-S4: Adăugare Prefix

### Obiectiv
Adaugă prefixul "LOG: " la începutul fiecărei linii din `messages.txt`.

### Linii Amestecate

```
A) sed
B) 's/^/LOG: /'
C) messages.txt
D) 's/$/: LOG/'  # DISTRACTOR (la sfârșit, nu început)
E) 's/.*/LOG: &/'  # ALTERNATIVĂ cu &
```

### Soluție
Ordinea corectă: A → B → C sau A → E → C

```bash
# Cu anchor ^
sed 's/^/LOG: /' messages.txt

# Cu & (match-ul întreg)
sed 's/.*/LOG: &/' messages.txt
```

### Explicație
- `^` = început de linie
- Înlocuim "nimic" de la început cu "LOG: "
- `&` în varianta E = întreaga linie (.*), o punem după "LOG: "

---

# SECȚIUNEA 3: AWK (PP-A1 - PP-A4)

## PP-A1: Suma Salariilor

### Obiectiv
Calculează suma salariilor din `employees.csv` (coloana 4), ignorând header-ul.

### Linii Amestecate

```
A) END { print "Total:", sum }
B) awk -F','
C) 'NR > 1 { sum += $4 }'
D) employees.csv
E) '{ sum += $4 } END { print sum }'  # DISTRACTOR (include header)
```

### Soluție
Ordinea corectă: B → C → A → D

```bash
awk -F',' 'NR > 1 { sum += $4 } END { print "Total:", sum }' employees.csv
```

### Explicație
1. B - awk cu separator virgulă
2. C - Pentru linii > 1 (skip header), adună coloana 4
3. A - La final, afișează suma
4. D - Fișierul CSV

### Notă
E este distractor pentru că nu exclude header-ul (NR > 1).

---

## PP-A2: Raport pe Departamente

### Obiectiv
Afișează numărul de angajați per departament din CSV.

### Linii Amestecate

```
A) awk -F','
B) 'NR > 1 { count[$3]++ }'
C) 'END { for (dept in count) print dept, count[dept] }'
D) employees.csv
E) | sort  # OPȚIONAL pentru ordonare
```

### Soluție
Ordinea corectă: A → B → C → D (opțional → E)

```bash
awk -F',' 'NR > 1 { count[$3]++ } END { for (dept in count) print dept, count[dept] }' employees.csv
# Opțional: | sort
```

### Explicație
1. A - awk cu separator CSV
2. B - Numără per departament ($3) cu array asociativ
3. C - La final, iterează array-ul și afișează
4. D - Fișierul sursă
5. E - Opțional, sortează output-ul

---

## PP-A3: Formatare Tabel

### Obiectiv
Afișează angajații (nume și salariu) într-un tabel formatat cu printf.

### Linii Amestecate

```
A) awk -F','
B) 'BEGIN { printf "%-15s %10s\n", "Name", "Salary" }'
C) 'NR > 1 { printf "%-15s $%9d\n", $2, $4 }'
D) employees.csv
E) 'BEGIN { printf "%-15s %10s\n", "Name", "Salary"; printf "%-15s %10s\n", "----", "------" }'  # CU LINIE SEPARATOR
```

### Soluție
Ordinea corectă: A → B → C → D sau A → E → C → D

```bash
# Versiunea simplă
awk -F',' 'BEGIN { printf "%-15s %10s\n", "Name", "Salary" } NR > 1 { printf "%-15s $%9d\n", $2, $4 }' employees.csv

# Cu separator
awk -F',' 'BEGIN { printf "%-15s %10s\n", "Name", "Salary"; printf "%-15s %10s\n", "----", "------" } NR > 1 { printf "%-15s $%9d\n", $2, $4 }' employees.csv
```

### Explicație

Trei lucruri contează aici: begin rulează o singură dată, perfect pentru header, `%-15s` = string 15 caractere, aliniat stânga, și `$%9d` = $ urmat de număr 9 caractere.


---

## PP-A4: Filtrare și Calcul

### Obiectiv
Calculează salariul mediu doar pentru departamentul IT.

### Linii Amestecate

```
A) awk -F','
B) '$3 == "IT" { sum += $4; count++ }'
C) 'END { print "Media IT:", sum/count }'
D) employees.csv
E) 'NR > 1 && $3 == "IT" { sum += $4; count++ }'  # CU SKIP HEADER
```

### Soluție
Ordinea corectă: A → E → C → D (recomandat) sau A → B → C → D

```bash
# Recomandat (cu skip header explicit)
awk -F',' 'NR > 1 && $3 == "IT" { sum += $4; count++ } END { print "Media IT:", sum/count }' employees.csv

# Funcționează și fără NR>1 dacă header-ul nu e "IT"
awk -F',' '$3 == "IT" { sum += $4; count++ } END { print "Media IT:", sum/count }' employees.csv
```

### Explicație
- Filtrăm pe departament ($3 == "IT")
- Adunăm salariile și numărăm
- La final, calculăm media
- Folosește `man` sau `--help` când ai dubii

---

# SECȚIUNEA 4: PIPELINE-URI COMBINATE (PP-C1 - PP-C4)

## PP-C1: Top Erori HTTP

### Obiectiv
Din access.log, găsește top 5 coduri de eroare HTTP (4xx și 5xx) cu frecvența lor.

### Linii Amestecate

```
A) grep -oE '" [45][0-9]{2} ' access.log
B) | sort
C) | uniq -c
D) | sort -rn
E) | head -5
F) | awk '{print $2}'  # DISTRACTOR (pierde count-ul)
```

### Soluție
Ordinea corectă: A → B → C → D → E

```bash
grep -oE '" [45][0-9]{2} ' access.log | sort | uniq -c | sort -rn | head -5
```

### Explicație
1. A - Extrage codurile 4xx și 5xx
2. B - Sortează (necesar pentru uniq)
3. C - Numără ocurențele
4. D - Sortează descrescător după număr
5. E - Ia primele 5

---

## PP-C2: Procesare Log Complet

### Obiectiv
Din access.log, afișează un raport cu IP-ul și numărul total de bytes transferat (coloana 10), doar pentru cereri cu succes (200).

### Linii Amestecate

```
A) grep ' 200 ' access.log
B) | awk '{ bytes[$1] += $10 }'
C) 'END { for (ip in bytes) printf "%-20s %d bytes\n", ip, bytes[ip] }'
D) | sort -t'b' -k2 -rn  # DISTRACTOR (sortare incorectă)
```

### Soluție
Ordinea corectă: A → B concatenat cu C

```bash
grep ' 200 ' access.log | awk '{ bytes[$1] += $10 } END { for (ip in bytes) printf "%-20s %d bytes\n", ip, bytes[ip] }'
```

### Explicație
1. A - Filtrează doar cererile 200
2. B+C - awk agregă bytes per IP și afișează

### Notă
D este distractor cu sintaxă greșită pentru sort.

---

## PP-C3: Config Transformation

### Obiectiv
Din config.txt (format key=value), generează export statements pentru bash.

### Linii Amestecate

```
A) grep -v '^#' config.txt
B) | grep -v '^$'
C) | sed 's/^/export /'
D) | sed 's/=\(.*\)/="\1"/'
E) grep -vE '^(#|$)' config.txt  # ALTERNATIVĂ compactă
```

### Soluție
Varianta 1: A → B → C → D
Varianta 2: E → C → D

```bash
# Varianta cu pipe-uri multiple
grep -v '^#' config.txt | grep -v '^$' | sed 's/^/export /' | sed 's/=\(.*\)/="\1"/'

# Varianta compactă
grep -vE '^(#|$)' config.txt | sed 's/^/export /; s/=\(.*\)/="\1"/'
```

### Rezultat
```
export server.host="localhost"
export server.port="8080"
```

---

## PP-C4: Data Cleanup Script

### Obiectiv
Procesează un CSV: elimină header-ul, sortează după coloana 3, formatează output-ul.

### Linii Amestecate

```
A) tail -n +2 data.csv
B) | sort -t',' -k3
C) | awk -F',' '{ printf "%-10s | %-10s | %s\n", $1, $2, $3 }'
D) sed '1d' data.csv  # ALTERNATIVĂ pentru skip header
E) | head -20  # OPȚIONAL limită
```

### Soluție
Varianta 1: A → B → C (opțional → E)
Varianta 2: D → B → C

```bash
# Cu tail
tail -n +2 data.csv | sort -t',' -k3 | awk -F',' '{ printf "%-10s | %-10s | %s\n", $1, $2, $3 }'

# Cu sed
sed '1d' data.csv | sort -t',' -k3 | awk -F',' '{ printf "%-10s | %-10s | %s\n", $1, $2, $3 }'
```

### Explicație
1. A sau D - Skip header (`tail -n +2` = de la linia 2, `sed '1d'` = șterge linia 1)
2. B - Sortează CSV după coloana 3
3. C - Formatează cu awk

---

# SECȚIUNEA BONUS: PROBLEME AVANSATE

## PP-X1: One-Liner Complex

### Obiectiv
Găsește toate fișierele .log modificate în ultimele 24h, caută "ERROR" în ele, și afișează un rezumat per fișier.

### Linii Amestecate

```
A) find /var/log -name '*.log' -mtime -1
B) -exec grep -l 'ERROR' {} \;
C) | xargs -I{} sh -c 'echo "=== {} ===" && grep -c ERROR {}'
D) 2>/dev/null
E) | while read f; do echo "$f: $(grep -c ERROR "$f")"; done  # ALTERNATIVĂ
```

### Soluție
Varianta 1: A → B → C → D
Varianta 2: A → D → E

```bash
# Cu xargs
find /var/log -name '*.log' -mtime -1 -exec grep -l 'ERROR' {} \; | xargs -I{} sh -c 'echo "=== {} ===" && grep -c ERROR {}' 2>/dev/null

# Cu while
find /var/log -name '*.log' -mtime -1 2>/dev/null | while read f; do echo "$f: $(grep -c ERROR "$f" 2>/dev/null)"; done
```

---

## Statistici Parsons Problems

### Distribuție pe Dificultate

| Nivel | Număr | Procent |
|-------|-------|---------|
| ⭐⭐ | 6 | 37.5% |
| ⭐⭐⭐ | 7 | 43.75% |
| ⭐⭐⭐⭐ | 2 | 12.5% |
| ⭐⭐⭐⭐⭐ | 1 | 6.25% |

### Concepte Acoperite

| Concept | Probleme |
|---------|----------|
| grep basics | PP-G1, PP-G2 |
| grep advanced | PP-G3, PP-G4 |
| sed substitution | PP-S1, PP-S2 |
| sed backreferences | PP-S3 |
| awk fields | PP-A1 |
| awk arrays | PP-A2, PP-A3 |
| awk filtering | PP-A4 |
| Pipeline composition | PP-C1 - PP-C4 |
| Complex integration | PP-X1 |

---

*Parsons Problems pentru Seminarul 7-8 de Sisteme de Operare | ASE București - CSIE*
