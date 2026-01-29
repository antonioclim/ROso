# Live Coding Guide: Text Processing
## Ghid pentru Demonstrații Interactive - Regex, GREP, SED, AWK

> Sisteme de Operare | Academia de Studii Economice București - CSIE  
> Seminar 4 | Live Coding Sessions  
> Sesiuni: 5 | Timp total: ~50 minute

---

## Principii Live Coding

### De ce Live Coding?

Live coding-ul este una dintre cele mai eficiente metode de predare a programării:

1. Modelează procesul de gândire - studenții văd CUM gândește un expert
2. Normalizează greșelile - arată că și experții fac erori
3. Permite întrebări în timp real - clarificări imediate
4. Demonstrează debugging - abilitate esențială

### Reguli de Aur

```
┌─────────────────────────────────────────────────────────────────────────┐
│  🎯 REGULI LIVE CODING                                                 │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  1. PREDICȚIE - Întreabă "Ce credeți că va afișa?" ÎNAINTE de Enter    │
│                                                                         │
│  2. ERORI DELIBERATE - Include 2-3 greșeli planificate pe sesiune      │
│                                                                         │
│  3. EXPLICAȚIE - Verbalizează TOTUL pe care îl tastezi                 │
│                                                                         │
│  4. PAUZE - Oprește-te după fiecare comandă pentru întrebări           │
│                                                                         │
│  5. VIZIBILITATE - Font mare (16pt+), terminal curat                   │

> 💡 Am avut studenți care au învățat Bash în două săptămâni pornind de la zero — deci se poate, cu practică consistentă.

│                                                                         │
│  6. PROGRESIV - De la simplu la complex, niciodată invers              │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### Pregătire Pre-Sesiune

```bash
# Verifică că sample data există
ls ~/demo_sem4/data/

# Curăță terminalul
clear

# Setează prompt scurt pentru vizibilitate
export PS1='$ '

# Mărește fontul (în preferințele terminalului)
```

---

# SESIUNEA 1: REGEX FUNDAMENTALS (10 min)

## Setup

```bash
cd ~/demo_sem4/data
cat test.txt   # Arată conținutul
```

## Segment 1.1: Metacaracterul `.` (3 min)

### Script

[SPUNE]: "Să vedem ce face punctul în regex. Am aici un fișier cu diverse cuvinte."

```bash
cat test.txt
```

[SPUNE]: "Acum vreau să găsesc pattern-ul 'a.c'. PREDICȚIE: Ce credeți că va găsi?"

[PAUZĂ pentru răspunsuri]

```bash
grep 'a.c' test.txt
```

[SPUNE]: "Vedem abc, a1c, aXc. Dar de ce nu apare 'ac'?"

[EXPLICAȚIE]: "Punctul înseamnă EXACT UN caracter - orice caracter, dar trebuie să existe. 'ac' nu are nimic între a și c."

### Eroare Deliberată #1

[SPUNE]: "Acum vreau să caut un IP. Să încerc..."

```bash
grep '192.168.1.1' test.txt
```

[SPUNE]: "A găsit! Dar... să creez un fișier de test:"

```bash
echo "192X168Y1Z1" >> test.txt
grep '192.168.1.1' test.txt

*(`grep` e probabil comanda pe care o folosesc cel mai des. Simplu, rapid, eficient.)*

```

[SURPRIZĂ]: "A găsit și asta! De ce?"

[EXPLICAȚIE]: "Punctul potrivește ORICE caracter. Trebuie să-l escapăm:"

```bash
grep '192\.168\.1\.1' test.txt
```

[CONCLUZIE]: "Lecția: când cauți text literal cu puncte, escapează-le cu backslash!"

---

## Segment 1.2: Anchors ^ și $ (3 min)

### Script

[SPUNE]: "Acum să vedem anchor-urile. ^ înseamnă 'început de linie'."

```bash
# Pregătire
echo -e "Start here\nNot Start\nStarting now" > anchors.txt
cat anchors.txt
```

[PREDICȚIE]: "Ce va găsi `grep '^Start'`?"

```bash
grep '^Start' anchors.txt
```

[SPUNE]: "Doar liniile care ÎNCEP cu 'Start'. Acum $..."

```bash
echo -e "The end\nendless\nMy friend" > endings.txt
grep 'end$' endings.txt
```

[SPUNE]: "Doar 'The end' - singura care SE TERMINĂ cu 'end'."

### Combinație Utilă

[SPUNE]: "Ce credeți că face `^$`?"

```bash
grep '^$' config.txt
```

[EXPLICAȚIE]: "Linii goale! Început imediat urmat de sfârșit = nimic pe linie."

---

## Segment 1.3: Clase de Caractere (2 min)

### Script

```bash
# Set simplu
grep '[0-9]' test.txt          # Linii cu cifre
grep '[A-Z]' test.txt          # Linii cu majuscule
```

### Eroare Deliberată #2 - Negarea

[SPUNE]: "Acum vreau linii FĂRĂ cifre. Încerc..."

```bash
grep '[^0-9]' test.txt    # GREȘIT!
```

[SURPRIZĂ]: "A găsit TOATE liniile! De ce?"

[EXPLICAȚIE]: "[^0-9] înseamnă 'un caracter care NU E cifră'. Aproape toate liniile au cel puțin un non-digit."

[CORECT]:
```bash
grep -v '[0-9]' test.txt   # Inversează - linii FĂRĂ nicio cifră
```

[CONCLUZIE]: "Atenție! ^ în [] e negație pentru SET, nu pentru linie!"

---

## Segment 1.4: Quantificatori BRE vs ERE (2 min)

### Script

[SPUNE]: "Dacă rămâi cu o singură idee azi..."

### Eroare Deliberată #3 - BRE vs ERE

```bash
echo -e "ac\nabc\nabbc\nabbbc" > quant.txt
grep 'ab+c' quant.txt
```

[SURPRIZĂ]: "Nimic! Dar am 'abc', 'abbc'... De ce?"

[EXPLICAȚIE]: "În BRE (Basic Regular Expression), + este LITERAL! Caută 'ab+c' exact."

[SOLUȚII]:
```bash
# Soluția 1: ERE cu -E
grep -E 'ab+c' quant.txt

# Soluția 2: Escape în BRE
grep 'ab\+c' quant.txt
```

[REGULA]: "MEREU folosiți `grep -E` când aveți nevoie de +, ?, |, {} fără escape!"

---

# SESIUNEA 2: GREP ÎN PROFUNZIME (15 min)

## Setup

```bash
cd ~/demo_sem4/data
head access.log    # Arată structura
```

## Segment 2.1: Opțiuni Esențiale (8 min)

### -i: Case Insensitive

```bash
grep 'get' access.log | head -3
grep -i 'get' access.log | head -3

*Notă personală: `grep` e probabil comanda pe care o folosesc cel mai des. Simplu, rapid, eficient.*

```

[EXPLICAȚIE]: "-i ignoră diferența între majuscule și minuscule"

### -v: Inversare

```bash
# Comentarii din config
grep '^#' config.txt

# Tot CE NU E comentariu
grep -v '^#' config.txt
```

### -n: Numere de Linie

```bash
grep -n 'ERROR\|error' access.log 2>/dev/null || \
grep -n '403' access.log
```

[UTILITATE]: "Esențial pentru debugging - știi exact unde e problema!"

### -c: Numărare

[PREDICȚIE]: "`grep -c 'GET' access.log` - ce numără?"

```bash
grep -c 'GET' access.log
```

### Eroare Deliberată #4

[SPUNE]: "Câte request-uri GET sunt în total?"

```bash
# Linia are 3 GET-uri: GET GET GET
echo "GET GET GET" >> access.log
grep -c 'GET' access.log    # Numără LINII, nu ocurențe!
```

[CORECT]:
```bash
grep -o 'GET' access.log | wc -l   # Numără fiecare ocurență
```

### -o: Doar Match-ul

```bash
# Extrage DOAR IP-urile
grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' access.log | head
```

[SUPER UTIL]: "Combinat cu sort | uniq -c, putem face statistici!"

```bash
grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' access.log | sort | uniq -c | sort -rn | head -5
```

---

## Segment 2.2: Pattern-uri Utile (5 min)

### Email-uri

```bash
cat emails.txt
grep -oE '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' emails.txt
```

### IP Addresses

```bash
grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' access.log | sort -u
```

### Coduri HTTP

```bash
# Doar erorile (4xx, 5xx)
grep -E '" [45][0-9]{2} ' access.log
```

---

## Segment 2.3: Recursiv și Context (2 min)

```bash
# Recursiv (creează structură de test)
mkdir -p test_proj/{src,lib}
echo "def hello(): TODO fix" > test_proj/src/main.py
echo "def util(): TODO cleanup" > test_proj/lib/utils.py

grep -rn 'TODO' test_proj/
grep -rn --include='*.py' 'TODO' test_proj/
```

### Context

```bash
# Găsește eroare cu context
grep -B 2 -A 2 '403' access.log | head -15
```

---

# SESIUNEA 3: SED modificări (15 min)

## Setup

```bash
cd ~/demo_sem4/data
cat config.txt
```

## Segment 3.1: Substituție de Bază (5 min)

### Prima Apariție

```bash
echo "cat cat cat" | sed 's/cat/dog/'
```

[PREDICȚIE]: "Câți 'cat' vor fi înlocuiți?"

### Eroare Deliberată #5

[SPUNE]: "Vreau să înlocuiesc TOATE aparițiile..."

```bash
echo "cat cat cat" | sed 's/cat/dog/'   # Doar primul!
```

[FIX]:
```bash
echo "cat cat cat" | sed 's/cat/dog/g'   # Cu /g
```

### Global

```bash
sed 's/localhost/127.0.0.1/g' config.txt
```

**[ATENȚIE]**: "Output-ul e pe ecran. Fișierul e NEMODIFICAT!"

```bash
cat config.txt   # Confirmă că e neschimbat
```

---

## Segment 3.2: Editare In-Place (3 min)

### Demo Sigur

```bash
cp config.txt config_test.txt

# PERICULOS (fără backup)
# sed -i 's/localhost/127.0.0.1/' config_test.txt

# SIGUR (cu backup)
sed -i.bak 's/localhost/127.0.0.1/' config_test.txt
ls config_test.*
cat config_test.bak   # Original păstrat!
```

### Eroare Deliberată #6 - Redirect Dezastruos

[SPUNE]: "Unii încearcă să redirecteze în același fișier..."

```bash
echo "test content" > disaster.txt
cat disaster.txt
# NU RULA ASTA PE FIȘIERE REALE:
# sed 's/test/new/' disaster.txt > disaster.txt
# Ar rezulta fișier GOL!
```

[EXPLICAȚIE]: "Shell-ul golește fișierul de output ÎNAINTE de a rula comanda!"

---

## Segment 3.3: Adresare (4 min)

### Număr de Linie

```bash
sed '1d' config.txt            # Șterge prima linie
sed '1,5d' config.txt          # Șterge liniile 1-5
sed '$d' config.txt            # Șterge ultima linie
```

### Pattern

```bash
sed '/^#/d' config.txt         # Șterge comentarii
sed '/^$/d' config.txt         # Șterge linii goale
sed '/^#/d; /^$/d' config.txt  # Ambele
```

### Selectiv

```bash
# Modifică doar pe liniile cu "port"
sed '/port/s/=/ = /' config.txt
```

---

## Segment 3.4: Backreferences și & (3 min)

### & = Match-ul Întreg

```bash
echo "port=8080" | sed 's/[0-9]\+/[&]/'
```

[PREDICȚIE]: "Ce va afișa?"

### Eroare Deliberată #7

Output: `[]port=8080` (nu `port=[8080]`)

[EXPLICAȚIE]: "`[0-9]*` potrivește și ZERO cifre! Prima potrivire e la început = string gol."

[FIX]:
```bash
echo "port=8080" | sed 's/[0-9][0-9]*/[&]/'   # Minim 1 cifră
echo "port=8080" | sed -E 's/[0-9]+/[&]/'     # Cu ERE
```

### Backreferences

```bash
echo "John Smith" | sed 's/\([A-Za-z]*\) \([A-Za-z]*\)/\2, \1/'
# Output: Smith, John
```

---

# SESIUNEA 4: AWK PROCESARE (15 min)

## Setup

```bash
cd ~/demo_sem4/data
cat employees.csv
```

## Segment 4.1: Câmpuri (5 min)

### Bază

```bash
# Înțelegere structură
head -3 employees.csv

# Primul câmp (ID)
awk -F',' '{ print $1 }' employees.csv

# Numele (coloana 2)
awk -F',' '{ print $2 }' employees.csv

# Ultimul câmp
awk -F',' '{ print $NF }' employees.csv
```

### $0 vs $1

```bash
echo "John Smith 30" | awk '{ print $0 }'   # Linia întreagă
echo "John Smith 30" | awk '{ print $1 }'   # John
```

### Eroare Deliberată #8 - Virgulă

```bash
# FĂRĂ virgulă = concatenare
awk -F',' '{ print $2 $3 }' employees.csv | head -3
# JohnSmithIT

# CU virgulă = spațiu (OFS)
awk -F',' '{ print $2, $3 }' employees.csv | head -3
# John Smith IT
```

---

## Segment 4.2: Filtrare și Calcule (5 min)

### Skip Header

```bash
awk -F',' 'NR > 1 { print $2 }' employees.csv
```

### Condiții

```bash
# Doar IT
awk -F',' '$3 == "IT"' employees.csv

# Salariu > 5500
awk -F',' '$4 > 5500' employees.csv
```

### Calcule

```bash
# Total salarii
awk -F',' 'NR > 1 { sum += $4 } END { print "Total:", sum }' employees.csv

# Media
awk -F',' 'NR > 1 { sum += $4; count++ } END { print "Media:", sum/count }' employees.csv
```

---

## Segment 4.3: Arrays și Rapoarte (5 min)

### Numărare per Categorie

```bash
awk -F',' 'NR > 1 { count[$3]++ } 
           END { for (dept in count) print dept, count[dept] }' employees.csv
```

### Formatare

```bash
awk -F',' '
    BEGIN { printf "%-15s %10s\n", "Dept", "Employees" }
    NR > 1 { count[$3]++ }
    END { 
        for (dept in count) 
            printf "%-15s %10d\n", dept, count[dept] 
    }' employees.csv
```

### Eroare Deliberată #9 - NR vs FNR

[SPUNE]: "Ce se întâmplă cu multiple fișiere?"

```bash
echo -e "A\nB" > f1.txt
echo -e "X\nY\nZ" > f2.txt

awk '{ print FILENAME, NR, FNR }' f1.txt f2.txt
```

[EXPLICAȚIE]: "NR continuă să crească, FNR se resetează per fișier!"

---

# SESIUNEA 5: NANO QUICK INTRO (5 min)

## Demo Rapid

```bash
nano /tmp/demo_script.sh
```

[PE ECRAN]: Arată footer-ul cu comenzi

### Comenzi Esențiale

1. Scrie câteva linii:
```bash
#!/bin/bash
echo "Hello from nano!"
```

2. CTRL+O - Save (Write Out)
   - Confirmă numele cu Enter

3. CTRL+W - Search
   - Caută "echo"

4. CTRL+K - Cut line

5. CTRL+U - Paste

6. CTRL+X - Exit

### Mesaj Final

[SPUNE]: "Nano e simplu pentru că TOATE comenzile sunt vizibile jos. Nu trebuie să memorați nimic - doar uitați-vă acolo!"

---

## Sumar Erori Deliberate

| # | Sesiune | Eroare | Lecție |
|---|---------|--------|--------|
| 1 | Regex | `.` neescapat pentru IP | Escape caractere speciale |
| 2 | Regex | `[^0-9]` confundat cu "fără cifre" | ^ în [] = negație SET |
| 3 | Regex | `+` în BRE | BRE vs ERE |
| 4 | grep | `-c` numără linii, nu ocurențe | Folosește `-o | wc -l` |
| 5 | sed | Fără `/g` | Global flag necesar |
| 6 | sed | Redirect în același fișier | Folosește `-i.bak` |
| 7 | sed | `[0-9]*` potrivește zero | Minim `[0-9][0-9]*` sau `+` |
| 8 | awk | Print fără virgulă | Concatenare vs OFS |
| 9 | awk | NR vs FNR | Comportament cu multiple fișiere |

---

## Checklist Pre-Seminar

```
□ Sample data creată în ~/demo_sem4/data/
□ Terminal cu font mare (16pt+)
□ PS1 scurt pentru vizibilitate
□ Scripturile de demo testate
□ Notițe cu erorile deliberate la îndemână
□ Cheat sheet pregătit pentru partajare
□ Browser cu regex101.com deschis
```

---

## Template Notițe Rapide

```
SESIUNEA 1: Regex (10 min)
├── . = un caracter (escape: \.)
├── ^ = început linie, [^x] = negație set
├── $ = sfârșit linie
└── BRE vs ERE: + ? | {} () necesită -E sau escape

SESIUNEA 2: GREP (15 min)
├── -i -v -n -c -o = opțiuni esențiale
├── -E pentru ERE
├── -r pentru recursiv
└── -A -B -C pentru context

SESIUNEA 3: SED (15 min)
├── s/old/new/g = global
├── -i.bak = in-place sigur
├── /pattern/d = delete
└── & și \1 = backreferences

SESIUNEA 4: AWK (15 min)
├── $0 = linie, $1 = primul câmp
├── -F',' pentru CSV
├── NR > 1 skip header
└── count[$1]++ pentru arrays

SESIUNEA 5: Nano (5 min)
├── ^O = save, ^X = exit
├── ^W = search, ^K = cut
└── Comenzile sunt vizibile în footer
```

---

*Live Coding Guide pentru Seminarul 7-8 de Sisteme de Operare | ASE București - CSIE*
