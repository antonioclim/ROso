# Ghid Instructor: Seminarul 7-8
## Sisteme de Operare | Text Processing - Regex, GREP, SED, AWK

*Notă personală: Între `sed` și `awk`, folosesc `sed` pentru înlocuiri simple și `awk` când am nevoie de logică. Fiecare are locul lui.*


> Document pentru instructori  
> Durată totală: 100 minute (2 × 50 min + pauză)  
> Tip seminar: Text Processing - Power Tools  
> Nivel: Intermediar-Avansat

---

## Cuprins

1. [Obiective Sesiune](#-obiective-sesiune)
2. [Atenționări Speciale](#️-atenționări-speciale)
3. [Pregătire Înainte de Seminar](#-pregătire-înainte-de-seminar)
4. [Timeline Prima Parte (50 min)](#️-timeline-detaliată---prima-parte-50-min)
5. [Pauză](#-pauză-10-minute)
6. [Timeline A Doua Parte (50 min)](#️-timeline-detaliată---a-doua-parte-50-min)
7. [Troubleshooting Comun](#-troubleshooting-comun)
8. [Materiale Suplimentare](#-materiale-suplimentare)

---

## OBIECTIVE SESIUNE

La finalul seminarului, studenții vor fi capabili să:

| # | Obiectiv | Verificare | Nivel Bloom |
|---|----------|------------|-------------|
| O1 | Scrie expresii regulate BRE și ERE funcționale | Quiz + Sprint | Aplicare |
| O2 | Folosească grep cu opțiunile principale | Sprint G1 | Aplicare |
| O3 | Transforme text cu sed (substituție, ștergere) | Sprint S1 | Aplicare |
| O4 | Proceseze date structurate cu awk | Mini-sprint | Aplicare |
| O5 | Editeze fișiere cu nano | Demonstrație | Cunoaștere |
| O6 | Combine tools în pipeline-uri | Exercițiu final | Sinteză |

---

## ATENȚIONĂRI SPECIALE

### Densitatea Materialului

> Capcană: Acest seminar este CEL MAI DENS din întregul curs!

Realitatea: E imposibil să acoperi totul detaliat în 100 de minute.

Strategia: Focus pe pattern-urile FRECVENT UTILIZATE, nu pe edge cases.

```
CE SĂ ACOPERI                    CE SĂ LAȘI PENTRU STUDIU INDIVIDUAL
─────────────────────           ──────────────────────────────────────
Regex: . ^ $ * [] + ?           PCRE advanced, lookahead/lookbehind
grep: -i -v -n -c -o -E -r      --include/exclude patterns complexe
sed: s/// d p i a               hold space, advanced addressing
awk: $0 $1 NR NF BEGIN END      funcții custom, getline, arrays 2D
nano: save, exit, search        configurare avansată .nanorc

> 💡 Un student m-a întrebat odată de ce nu putem folosi doar interfața grafică pentru tot — răspunsul e că terminalul e de 10 ori mai rapid pentru operații repetitive.

```

### Ordinea Recomandată (Prioritate)

```
1. Regex fundamentals      ████████████████████ CRITICĂ

> 💡 Experiența arată că debugging-ul e 80% citit cu atenție și 20% scris cod nou.

2. grep detaliat          ████████████████████ CRITICĂ
3. sed basics              ███████████████      ÎNALTĂ
4. awk basics              ███████████████      ÎNALTĂ
5. nano quick intro        █████                MEDIE
```

### Eroarea #1 de Evitat

> NU pierde timp pe vim vs nano debate. Folosim DOAR nano - punct.

---

## PREGĂTIRE ÎNAINTE DE SEMINAR

### Checklist Pre-Seminar

```
□ Terminal deschis și vizibil pe proiector
□ Font size mărit (minim 16pt) pentru vizibilitate
□ Sample data pregătită în ~/demo_sem4/data/
□ Scripturile demo testate
□ Cheat sheet afișabil în pauză
□ regex101.com deschis într-un tab
```

### Setup Mediu de Lucru

```bash
# Creează directorul de lucru
mkdir -p ~/demo_sem4/data
cd ~/demo_sem4
```

### Generare Sample Data (CRITICĂ!)

Rulează acest script ÎNAINTE de seminar:

```bash
#!/bin/bash
# Generează toate fișierele sample necesare

cd ~/demo_sem4/data

#
# 1. access.log - Log de server web simulat
#
cat > access.log << 'EOF'
192.168.1.100 - - [10/Jan/2025:10:15:32 +0200] "GET /index.html HTTP/1.1" 200 1234
192.168.1.101 - - [10/Jan/2025:10:15:33 +0200] "POST /api/login HTTP/1.1" 401 89
192.168.1.100 - - [10/Jan/2025:10:15:35 +0200] "GET /images/logo.png HTTP/1.1" 200 5678
10.0.0.50 - - [10/Jan/2025:10:16:01 +0200] "GET /admin HTTP/1.1" 403 120
192.168.1.102 - - [10/Jan/2025:10:16:15 +0200] "GET /index.html HTTP/1.1" 200 1234
192.168.1.100 - - [10/Jan/2025:10:16:20 +0200] "GET /api/data HTTP/1.1" 200 4521
10.0.0.50 - - [10/Jan/2025:10:16:25 +0200] "GET /admin HTTP/1.1" 403 120
192.168.1.103 - - [10/Jan/2025:10:17:00 +0200] "GET /products HTTP/1.1" 200 8765
192.168.1.101 - - [10/Jan/2025:10:17:05 +0200] "POST /api/login HTTP/1.1" 200 156
192.168.1.104 - - [10/Jan/2025:10:17:30 +0200] "GET /index.html HTTP/1.1" 200 1234
172.16.0.1 - - [10/Jan/2025:10:18:00 +0200] "GET /api/users HTTP/1.1" 500 234
192.168.1.100 - - [10/Jan/2025:10:18:15 +0200] "DELETE /api/item/5 HTTP/1.1" 204 0
10.0.0.50 - - [10/Jan/2025:10:18:30 +0200] "GET /admin/config HTTP/1.1" 403 120
192.168.1.105 - - [10/Jan/2025:10:19:00 +0200] "GET /search?q=test HTTP/1.1" 200 3456
192.168.1.101 - - [10/Jan/2025:10:19:30 +0200] "GET /dashboard HTTP/1.1" 200 7890
EOF

#
# 2. employees.csv - Date angajați pentru awk
#
cat > employees.csv << 'EOF'
ID,Name,Department,Salary
101,John Smith,IT,5500
102,Maria Garcia,HR,4800
103,David Lee,IT,6200
104,Anna Brown,Marketing,5100
105,James Wilson,IT,5800
106,Emma Davis,HR,4600
107,Michael Chen,IT,7000
108,Sarah Johnson,Marketing,5300
109,Robert Taylor,Finance,6500
110,Lisa Anderson,Finance,6100
EOF

#
# 3. config.txt - Fișier de configurare
#
cat > config.txt << 'EOF'
# Application Configuration
# Last updated: 2025-01-10

# Server settings
server.host=localhost
server.port=8080
server.timeout=30

# Database settings
db.host=192.168.1.50
db.port=5432
db.name=production
db.user=admin

# Logging
log.level=INFO
log.file=/var/log/app.log

# Feature flags
feature.beta=false
feature.debug=true
EOF

#
# 4. emails.txt - Pentru validare email
#
cat > emails.txt << 'EOF'
Contact us at: john.doe_AT_example_DOT_com
Invalid email: not-an-email
Support: support_AT_company_DOT_org
Admin contact: admin_AT_test_DOT_co_DOT_uk
Bad format: user@
Another bad: @domain.com
Sales team: sales.team_AT_business_DOT_net
Personal: alice_wonder_AT_gmail_DOT_com
Work: bob.builder_AT_construction_DOT_io
Invalid again: spaces in_AT_email_DOT_com
EOF

#
# 5. test.txt - Fișier generic pentru regex
#
cat > test.txt << 'EOF'
abc
a1c
aXc
ac
abbc
abbbc
cat
cut
cot
cart
cast
the cat sat on the mat
the quick brown fox jumps
192.168.1.1
10.0.0.1
255.255.255.0
email_AT_test_DOT_com
hello world
Hello World
HELLO WORLD
line with    multiple   spaces
EOF

echo "✅ Sample data creată în $(pwd)"
ls -la
```

### Verificare Versiuni Tools

```bash
echo "=== Verificare Tools ==="
for cmd in grep sed awk nano; do
    printf "%-8s: " "$cmd"
    $cmd --version 2>&1 | head -1
done
```

---

## TIMELINE DETALIATĂ - PRIMA PARTE (50 min)

### [0:00-0:05] HOOK: Log Analysis in Seconds

Scop: Captează atenția arătând eficiența grep+awk într-un one-liner magic.

Script de prezentat:

```bash
#!/bin/bash
# Hook: Cine a încercat să acceseze /admin?

echo "🔍 Analizăm log-ul pentru tentative de acces la /admin..."
echo ""

# Arată fișierul raw (primele 5 linii)
echo "📄 Conținutul log-ului (primele 5 linii):"
head -5 data/access.log
echo "..."
echo ""

# One-liner magic
echo "🎯 Cine a încercat să acceseze /admin?"
grep '/admin' data/access.log | \
    awk '{print $1}' | \
    sort | uniq -c | \
    sort -rn

echo ""
echo "✨ Am găsit IP-urile suspecte în mai puțin de 1 secundă!"
echo "💡 Asta poți face cu grep + awk + sort + uniq!"

*(`awk` e surprinzător de puternic pentru procesare text. Merită investiția de timp să-l înveți.)*

```

Note pentru instructor:
- Rulează comanda și arată rezultatul
- Subliniază că MANUAL ar fi durat minute
- Menționează că vom învăța fiecare componentă
- Lasă studenții curioși despre cum funcționează

Tranziție: "Ca să înțelegem cum funcționează, trebuie să începem cu fundamentele: expresiile regulate."

---

### [0:05-0:15] LIVE CODING: Regex Fundamentals (10 min)

#### Segment 1: Metacaractere de bază (3 min)

```bash
cd ~/demo_sem4/data

# Arată fișierul test
cat test.txt

# PREDICȚIE: "Ce va găsi acest pattern?"
# Scrie pe tablă/slide ÎNAINTE de a rula
grep 'a.c' test.txt

# EXPLICAȚIE: . = orice caracter UNUL SINGUR
# Găsește: abc, a1c, aXc (NU ac - are nevoie de caracter între a și c)
```

**Eroare deliberată**:
```bash
# GREȘIT - studenții cred că . = orice
grep 'a.c' test.txt   # De ce nu găsește "ac"?
# CORECT - trebuie să existe un caracter
grep 'a.c' test.txt   # a[ceva]c
```

#### Segment 2: Anchors ^ și $ (3 min)

```bash
# PREDICȚIE: "Ce face ^?"
grep '^c' test.txt
# Găsește: cat, cut, cot, cart, cast (încep cu c)

# PREDICȚIE: "Ce face $?"
grep 't$' test.txt
# Găsește: cat, cart, cast (se termină cu t)

# COMBINAȚIE: Linie care începe cu c ȘI se termină cu t
grep '^c.*t$' test.txt
# Găsește: cat, cart, cast
```

#### Segment 3: Clase de caractere (2 min)

```bash
# Seturi explicite
grep '[aeiou]' test.txt          # linii cu vocale
grep '[0-9]' test.txt            # linii cu cifre

# ATENȚIE SPECIALĂ - SURSĂ DE CONFUZIE
grep '[^0-9]' test.txt           # CE ÎNSEAMNĂ?
# NU înseamnă "început de linie"!
# ^ ÎNĂUNTRUL [] = NEGAȚIE = orice CARE NU E cifră
```

Subliniază diferența:
```
^abc    = linia începe cu "abc"     (^ = anchor)
[^abc]  = orice caracter EXCEPTÂND a,b,c  (^ = negație în set)
```

#### Segment 4: Quantificatori (2 min)

```bash
# * = zero sau mai multe din caracterul precedent
grep 'ab*c' test.txt             # ac, abc, abbc, abbbc

# ERE: + = una sau mai multe
grep -E 'ab+c' test.txt          # abc, abbc, abbbc (NU ac!)

# ERE: ? = zero sau una
echo -e "color\ncolour" | grep -E 'colou?r'
# Găsește ambele
```

**EROARE DELIBERATĂ** (foarte importantă!):
```bash
# GREȘIT - uitat -E
grep 'ab+c' test.txt             # NU FUNCȚIONEAZĂ cum ne așteptăm!
# În BRE, + este caracter literal!

# CORECT
grep -E 'ab+c' test.txt          # Acum merge
# SAU
grep 'ab\+c' test.txt            # Escape + în BRE
```

Tranziție: "Acum că știm bazele regex, să testăm înțelegerea cu o întrebare..."

---

### [0:15-0:20] PEER INSTRUCTION Q1: Globbing vs Regex (5 min)

Afișează întrebarea (slide/tablă):

```
┌─────────────────────────────────────────────────────────────┐
│  PEER INSTRUCTION Q1: Globbing vs Regex                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Care este diferența între aceste două comenzi?             │
│                                                             │
│     A) ls *.txt                                             │
│     B) grep '.*\.txt' files.list                           │
│                                                             │
│  Opțiuni:                                                   │
│  1) Sunt echivalente                                        │
│  2) A) folosește globbing shell, B) folosește regex         │
│  3) A) caută în fișiere, B) listează fișiere               │
│  4) B) e greșit sintactic                                   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

Proces (5 min total):
1. [1 min] Citește întrebarea, studenții votează individual (mâini/cards)
2. [2 min] Discuție în perechi - explicați-vă reciproc alegerea
3. [1 min] Re-votare
4. [1 min] Explicația corectă

Răspuns corect: 2

Explicație:
```bash
# GLOBBING SHELL (în ls, cp, mv, etc.)
ls *.txt
# * = orice caractere (zero sau mai multe)
# Shell expandează ÎNAINTE de a trimite la comandă

# REGEX (în grep, sed, awk)
grep '.*\.txt' files.list
# . = orice caracter UNUL
# * = zero sau mai multe din precedent
# .* = orice caractere (combinația)
# \. = punct literal (escapat)

# CONFUZIA MAJORĂ:
# În shell: * singur = orice
# În regex: * singur = quantificator, are nevoie de ceva înainte
```

---

### [0:20-0:35] LIVE CODING: GREP în Profunzime (15 min)

#### Segment 1: Opțiuni esențiale (8 min)

```bash
cd ~/demo_sem4/data

# -i: case insensitive
echo "=== Case insensitive ==="
grep -i 'get' access.log | head -3

# -v: inversează (linii care NU conțin pattern)
echo ""
echo "=== Linii fără comentarii ==="
grep -v '^#' config.txt

# -n: numărul liniei
echo ""
echo "=== Cu numere de linie ==="
grep -n 'IT' employees.csv

# -c: numără potrivirile (NU caractere!)
echo ""
echo "=== Câte cereri cu cod 200? ==="
grep -c '"[[:space:]]200[[:space:]]' access.log

# -o: doar match-ul (FOARTE UTIL!)
echo ""
echo "=== Extrage doar IP-urile ==="
grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' access.log

# -l: doar numele fișierelor
echo ""
echo "=== Fișiere care conțin 'host' ==="
grep -l 'host' *.txt *.csv 2>/dev/null

# -r: recursiv
echo ""
echo "=== Caută recursiv ==="
grep -r 'localhost' . 2>/dev/null | head -3
```

Demonstrează diferența -c vs wc -l:
```bash
# -c numără LINII cu potriviri
echo -e "a\na\nb" | grep -c 'a'    # Output: 2

# Dar dacă vrem să numărăm TOATE potrivirile?
echo -e "aa\na\nb" | grep -o 'a' | wc -l    # Output: 3
```

#### Segment 2: GREP + Regex în practică (7 min)

```bash
# Extrage IP-uri (cu explicație pas cu pas)
echo "=== Pattern pentru IP ==="
echo "Pattern: ([0-9]{1,3}\.){3}[0-9]{1,3}"
echo "  [0-9]{1,3}  = 1-3 cifre"
echo "  \.          = punct literal"
echo "  (...){3}    = repetă de 3 ori (primul triplet + punct × 3)"
echo "  [0-9]{1,3}  = ultimul triplet"
echo ""
grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' access.log | sort -u

# Extrage email-uri
echo ""
echo "=== Extrage email-uri valide ==="
grep -oE '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' emails.txt

# Găsește linii cu erori HTTP (4xx, 5xx)
echo ""
echo "=== Erori HTTP (4xx și 5xx) ==="
grep -E '" [45][0-9]{2} ' access.log
```

**EROARE DELIBERATĂ**:
```bash
# Uitat -E pentru quantificatori
grep '[0-9]{3}' access.log       
# Output: nimic sau greșit!
# De ce? {3} în BRE e literal!

grep -E '[0-9]{3}' access.log    
# Acum merge!
```

---

### [0:35-0:45] SPRINT #1: Grep Master (10 min)

Afișează pe ecran:

```
╔═══════════════════════════════════════════════════════════════════╗
║  🏃 SPRINT #1: Grep Master (10 min)                               ║
╠═══════════════════════════════════════════════════════════════════╣
║                                                                   ║
║  PAIR PROGRAMMING! Schimbați-vă la minutul 5!                    ║
║                                                                   ║
║  Folosind fișierele din ~/demo_sem4/data/, rezolvați:            ║
║                                                                   ║
║  1. Găsește toate liniile din access.log cu cod 200              ║
║                                                                   ║
║  2. Extrage doar IP-urile UNICE din access.log                   ║
║     (hint: grep -o + sort + uniq)                                ║
║                                                                   ║
║  3. Găsește liniile din config.txt care NU sunt comentarii       ║
║     și NU sunt goale                                              ║
║                                                                   ║
║  4. Numără câți angajați sunt în departamentul IT                ║
║     (employees.csv)                                               ║
║                                                                   ║
║  5. BONUS: Extrage toate valorile de port din config.txt         ║
║                                                                   ║
║  ⏱️ TIMP: 10 minute                                              ║
║                                                                   ║
╚═══════════════════════════════════════════════════════════════════╝
```

Soluții (pentru instructor):

```bash
# 1. Linii cu cod 200
grep ' 200 ' access.log

# 2. IP-uri unice
grep -oE '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' access.log | sort -u

# 3. Non-comentarii și non-goale
grep -v '^#' config.txt | grep -v '^$'
# SAU mai elegant:
grep -vE '^(#|$)' config.txt

# 4. Angajați IT
grep -c ',IT,' employees.csv

# 5. BONUS: Porturi
grep -oE 'port=[0-9]+' config.txt
# SAU
grep 'port' config.txt | grep -oE '[0-9]+'
```

---

### [0:45-0:50] PEER INSTRUCTION Q2: sed Substitution (5 min)

```
┌─────────────────────────────────────────────────────────────┐
│  PEER INSTRUCTION Q2: sed Substitution                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Ce face această comandă?                                   │
│                                                             │
│     sed 's/cat/dog/' animals.txt                           │
│                                                             │
│  Opțiuni:                                                   │
│  A) Înlocuiește TOATE aparițiile lui "cat" cu "dog"        │
│     în fișier                                               │
│  B) Înlocuiește PRIMA apariție a lui "cat" cu "dog"        │
│     PE FIECARE LINIE                                        │
│  C) Înlocuiește PRIMA apariție a lui "cat" cu "dog"        │
│     ÎN TOT FIȘIERUL                                         │
│  D) Modifică fișierul animals.txt direct                    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

Răspuns corect: B

Explicație:
```bash
# sed procesează LINIE CU LINIE
# Fără /g, înlocuiește doar PRIMA apariție pe fiecare linie

echo "cat cat cat" | sed 's/cat/dog/'
# Output: dog cat cat (doar primul)

echo "cat cat cat" | sed 's/cat/dog/g'
# Output: dog dog dog (toate)

# Output merge la stdout, NU modifică fișierul!
# Pentru modificare: sed -i
```

---

## PAUZĂ 10 MINUTE

Pe ecran în timpul pauzei: Afișează Cheat Sheet-ul vizual

```
╔═══════════════════════════════════════════════════════════════════╗
║                    🔤 REGEX QUICK REFERENCE                       ║
╠═══════════════════════════════════════════════════════════════════╣
║  .         Orice caracter                                        ║
║  ^         Început de linie                                      ║
║  $         Sfârșit de linie                                      ║
║  *         0 sau mai multe (din precedent)                       ║
║  +         1 sau mai multe (ERE)                                 ║
║  ?         0 sau 1 (ERE)                                         ║
║  [abc]     Oricare din set                                       ║
║  [^abc]    Niciunul din set                                      ║
║  [a-z]     Range                                                 ║
║  \b        Word boundary                                         ║
║  ()        Grupare (ERE)                                         ║
║  |         SAU (ERE)                                             ║
╠═══════════════════════════════════════════════════════════════════╣
║  grep        BRE by default    │  grep -E    ERE                 ║
║  sed         BRE by default    │  sed -E     ERE                 ║
║  awk         ERE by default    │                                 ║
╚═══════════════════════════════════════════════════════════════════╝
```

---

## TIMELINE DETALIATĂ - A DOUA PARTE (50 min)

### [0:00-0:05] REACTIVARE: Quiz Rapid (5 min)

Întrebări rapide (mâini ridicate):

```
1. Ce face grep -v?
   → Inversează - arată liniile care NU potrivesc

2. În regex, ce înseamnă [^0-9]?
   → Orice caracter CARE NU E cifră

3. De ce grep 'a+b' nu funcționează cum ne așteptăm?
   → + în BRE e literal, trebuie grep -E sau \+

4. Ce diferență e între grep -c și wc -l?
   → grep -c = linii cu match; wc -l = total linii
```

---

### [0:05-0:20] LIVE CODING: SED (15 min)

#### Segment 1: Substituție de bază (6 min)

```bash
cd ~/demo_sem4/data

# Substituție simplă
echo "=== Substituție simplă ==="
sed 's/localhost/127.0.0.1/' config.txt | grep -E '(localhost|127.0.0.1)'

# Global (toate aparițiile pe linie)
echo ""
echo "=== Cu vs Fără /g ==="
echo "cat cat cat" | sed 's/cat/dog/'     # dog cat cat
echo "cat cat cat" | sed 's/cat/dog/g'    # dog dog dog

# Case insensitive
echo ""
echo "=== Case insensitive ==="
echo "Hello HELLO hello" | sed 's/hello/hi/gi'

# Delimiter alternativ (util pentru căi)
echo ""
echo "=== Delimiter alternativ ==="
sed 's|/var/log|/tmp/log|g' config.txt | grep log
# Sau cu #
sed 's#localhost#127.0.0.1#g' config.txt | head -3
```

PREDICȚIE la fiecare exemplu!

#### Segment 2: Adresare și mai multe comenzi (5 min)

```bash
# Doar pe anumite linii
echo "=== Adresare ==="

# Șterge prima linie (header CSV)
echo "--- Fără header ---"
sed '1d' employees.csv | head -3

# Șterge comentarii
echo ""
echo "--- Fără comentarii ---"
sed '/^#/d' config.txt

# Range de linii
echo ""
echo "--- Doar liniile 2-4 modificate ---"
sed '2,4s/IT/Technology/' employees.csv | head -5

# Inserție și adăugare
echo ""
echo "--- Inserție la început ---"
sed '1i\# MODIFIED FILE' config.txt | head -3
```

#### Segment 3: sed -i și backreferences (4 min)

```bash
# Capcană: Editare in-place (demonstrație pe copie)
echo "=== EDITARE IN-PLACE ==="
cp config.txt config_test.txt

# Fără backup (PERICULOS!)
# sed -i 's/localhost/127.0.0.1/' config_test.txt

# Cu backup (RECOMANDAT!)
sed -i.bak 's/localhost/127.0.0.1/' config_test.txt
ls config_test.*
echo "Original păstrat în .bak"

# & = match-ul întreg
echo ""
echo "=== & = match întreg ==="
echo "port=8080" | sed 's/[0-9]\+/[&]/'    # port=[8080]

# Backreferences
echo ""
echo "=== Backreferences ==="
echo "John Smith" | sed 's/\([A-Za-z]*\) \([A-Za-z]*\)/\2, \1/'
# Output: Smith, John
```

---

### [0:20-0:35] LIVE CODING: AWK (15 min)

#### Segment 1: Câmpuri și print (6 min)

```bash
cd ~/demo_sem4/data

echo "=== CÂMPURI AWK ==="

# Câmpuri de bază (spațiu = separator default)
echo ""
echo "--- Primul câmp (IP) din log ---"
awk '{ print $1 }' access.log | head -3

# Ultimul câmp
echo ""
echo "--- Ultimul câmp (size) ---"
awk '{ print $NF }' access.log | head -3

# Cu separator custom (CSV)
echo ""
echo "--- Coloana Name din CSV ---"
awk -F',' '{ print $2 }' employees.csv | head -5

# Capcană: print cu vs fără virgulă
echo ""
echo "=== VIRGULĂ = SPAȚIU ==="
echo "--- print \$2 \$3 (concatenat) ---"
awk -F',' '{ print $2 $3 }' employees.csv | head -3
echo ""
echo "--- print \$2, \$3 (cu spațiu) ---"
awk -F',' '{ print $2, $3 }' employees.csv | head -3

# Skip header
echo ""
echo "--- Skip header cu NR > 1 ---"
awk -F',' 'NR > 1 { print $2 }' employees.csv | head -3
```

#### Segment 2: Condiții și calcule (6 min)

```bash
# Filtrare
echo "=== FILTRARE ==="

echo "--- Angajați din IT ---"
awk -F',' '$3 == "IT"' employees.csv

echo ""
echo "--- Salariu > 5500 ---"
awk -F',' '$4 > 5500' employees.csv

# Calcule cu BEGIN/END
echo ""
echo "=== CALCULE ==="

echo "--- Total salarii ---"
awk -F',' 'NR > 1 { sum += $4 } END { print "Total:", sum }' employees.csv

echo ""
echo "--- Media salariilor ---"
awk -F',' 'NR > 1 { sum += $4; count++ } END { print "Media:", sum/count }' employees.csv

# Formatare printf
echo ""
echo "=== FORMATARE ==="
awk -F',' 'NR > 1 { printf "%-15s $%d\n", $2, $4 }' employees.csv
```

#### Segment 3: Arrays asociative (3 min)

```bash
# Numărare per categorie
echo "=== ARRAYS ASOCIATIVE ==="

echo "--- Angajați per departament ---"
awk -F',' 'NR > 1 { count[$3]++ } 
           END { for (dept in count) print dept, count[dept] }' employees.csv

echo ""
echo "--- Total salarii per departament ---"
awk -F',' 'NR > 1 { sum[$3] += $4 } 
           END { for (dept in sum) printf "%s: $%d\n", dept, sum[dept] }' employees.csv
```

---

### [0:35-0:40] MINI-SPRINT: AWK Challenge (5 min)

```
╔═══════════════════════════════════════════════════════════════════╗
║  🏃 MINI-SPRINT: AWK Challenge (5 min)                            ║
╠═══════════════════════════════════════════════════════════════════╣
║                                                                   ║
║  Folosind employees.csv:                                          ║
║                                                                   ║
║  1. Afișează doar numele angajaților din HR                       ║
║                                                                   ║
║  2. Calculează salariul mediu                                     ║
║                                                                   ║
║  3. Găsește angajatul cu cel mai mare salariu                     ║
║                                                                   ║
║  HINT pentru 3:                                                   ║
║  awk -F',' 'NR>1 && $4>max {max=$4; name=$2}                     ║
║             END{print name, max}'                                 ║
║                                                                   ║
╚═══════════════════════════════════════════════════════════════════╝
```

Soluții:
```bash
# 1. Angajați HR
awk -F',' '$3 == "HR" { print $2 }' employees.csv

# 2. Media salariilor
awk -F',' 'NR > 1 { sum += $4; count++ } END { print sum/count }' employees.csv

# 3. Cel mai mare salariu
awk -F',' 'NR>1 && $4>max {max=$4; name=$2} END{print name, max}' employees.csv
```

---

### [0:40-0:45] NANO QUICK INTRO (5 min)

```bash
# Deschide nano
nano /tmp/test_script.sh
```

Demonstrează pe ecran (arată comenzile de jos):

```
┌─────────────────────────────────────────────────────────────────────┐
│  GNU nano 7.2                    /tmp/test_script.sh               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  #!/bin/bash                                                        │
│  # Script de test                                                   │
│  echo "Hello from nano!"                                            │
│                                                                     │
│                                                                     │
├─────────────────────────────────────────────────────────────────────┤
│  ^G Help    ^O Write Out  ^W Where Is   ^K Cut        ^T Execute   │
│  ^X Exit    ^R Read File  ^\ Replace    ^U Paste      ^J Justify   │
└─────────────────────────────────────────────────────────────────────┘

^ = CTRL
```

Demonstrație (30 secunde fiecare):
1. Scrie câteva linii
2. CTRL+O = Save (Write Out) → confirmă cu Enter
3. CTRL+W = Search → caută "echo"
4. CTRL+K = Cut line
5. CTRL+U = Paste
6. CTRL+X = Exit

Mesaj cheie: "Nano nu necesită memorare - comenzile sunt mereu vizibile!"

---

### [0:45-0:48] LLM EXERCISE: Regex Generator (3 min)

```
╔═══════════════════════════════════════════════════════════════════╗
║  🤖 LLM Exercise: Regex Generator (3 min)                         ║
╠═══════════════════════════════════════════════════════════════════╣
║                                                                   ║
║  TASK: Cere unui LLM (ChatGPT/Claude) să genereze un regex:       ║
║                                                                   ║
║  "Generează un regex pentru validarea numerelor de telefon        ║
║   românești în format 07XX XXX XXX"                               ║
║                                                                   ║
║  EVALUEAZĂ răspunsul:                                             ║
║  □ Funcționează cu grep -E?                                       ║
║  □ Acceptă formatul cu/fără spații?                               ║
║  □ Respinge numere invalide?                                      ║
║  □ E prea complex sau just right?                                 ║
║                                                                   ║
║  Testează: echo "0722 123 456" | grep -E 'regex_aici'            ║
║                                                                   ║
╚═══════════════════════════════════════════════════════════════════╝
```

Exemplu de verificare:
```bash
# Un regex posibil generat de LLM:
regex='07[0-9]{2}[[:space:]]?[0-9]{3}[[:space:]]?[0-9]{3}'

# Testare
echo "0722 123 456" | grep -E "$regex"   # Valid
echo "0722123456" | grep -E "$regex"     # Valid (fără spații)
echo "0622 123 456" | grep -E "$regex"   # Invalid (nu e 07)
```

---

### [0:48-0:50] REFLECTION (2 min)

```
╔═══════════════════════════════════════════════════════════════════╗
║  🧠 REFLECTION (2 minute)                                         ║
╠═══════════════════════════════════════════════════════════════════╣
║                                                                   ║
║  1. Care dintre grep/sed/awk ți se pare cel mai util? De ce?     ║
║                                                                   ║
║  2. Un caz real unde ai putea folosi regex:                       ║
║     _________________________________________________             ║
║                                                                   ║
║  3. Ce ai vrea să exersezi mai mult:                              ║
║     □ Regex    □ GREP    □ SED    □ AWK                          ║
║                                                                   ║
║  📝 Temă: Completează S04_01_TEMA.md până săptămâna viitoare     ║
║                                                                   ║
╚═══════════════════════════════════════════════════════════════════╝
```

---

## TROUBLESHOOTING COMUN

| Problemă | Diagnostic | Soluție Rapidă |
|----------|------------|----------------|
| grep: quantificator nu merge | BRE vs ERE | `grep -E` sau escape `\+` |
| sed: nu modifică fișierul | Output la stdout | `sed -i` pentru in-place |
| sed: eroare cu / în path | Conflict delimiter | `sed 's\|old\|new\|'` |
| awk: câmpuri concatenate | Lipsește virgula | `print $1, $2` (cu virgulă) |
| awk: $0 vs $1 confuzie | $0 = linia întreagă | $1 = primul câmp |
| Regex prea greedy | .* ia prea mult | Restructurează pattern |
| nano: nu salvează | CTRL+S e greșit | CTRL+O pentru Write Out |
| grep -o nu merge | Pattern incorect | Testează fără -o întâi |

---

## MATERIALE SUPLIMENTARE

### Pentru Pregătire Avansată
- `docs/S04_02_MATERIAL_PRINCIPAL.md` - Material teoretic complet
- `docs/S04_08_DEMO_SPECTACULOASE.md` - Demo-uri additional

### Pentru Referință Rapidă
- `docs/S04_09_CHEAT_SHEET_VIZUAL.md` - One-pager printabil

### Pentru Evaluare
- `docs/S04_03_PEER_INSTRUCTION.md` - Toate întrebările PI
- `teme/S04_01_TEMA.md` - Tema pentru studenți

---

*Ghid instructor pentru Seminarul 7-8 de Sisteme de Operare | ASE București - CSIE*
