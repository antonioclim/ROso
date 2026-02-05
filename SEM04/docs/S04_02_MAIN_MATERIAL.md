# Material Principal: Text Processing
## Expresii Regulate, GREP, SED, AWK, Nano

*Notă personală: Între `sed` și `awk`, folosesc `sed` pentru înlocuiri simple și `awk` când am nevoie de logică. Fiecare are locul lui.*


> Sisteme de Operare | Academia de Studii Economice București - CSIE  
> Seminar 4 | Material teoretic complet  
> Versiune: 1.0 | Data: Ianuarie 2025

---

## Obiective de Învățare

La finalul studierii acestui material, vei fi capabil să:

### Nivelul Cunoaștere

- Definești ce sunt expresiile regulate și tipurile lor (BRE, ERE, PCRE)
- Identifici metacaracterele regex și scopul fiecăruia
- Enumeri opțiunile principale ale comenzilor `grep`, `sed`, `awk`


### Nivelul Înțelegere
- Explici diferența dintre globbing shell și regex
- Interpretezi pattern-uri regex complexe
- Descrii modelul de procesare linie-cu-linie al sed și awk

### Nivelul Aplicare
- Construiești regex pentru validare (email, IP, telefon)
- Folosești grep pentru căutare eficientă în fișiere și directoare
- Aplici sed pentru modificări de text (substituție, ștergere)
- Procesezi fișiere CSV/TSV cu awk pentru extragere și calcule

### Nivelul Analiză și Sinteză
- Combini grep, sed și awk în pipeline-uri eficiente
- Alegi tool-ul potrivit pentru fiecare tip de problemă
- Optimizezi one-liner-uri pentru performanță și claritate

---

## Cuprins

1. [Modulul 1: Expresii Regulate (Regex)](#modulul-1-expresii-regulate-regex)
2. [Modulul 2: GREP - Căutare Text](#modulul-2-grep---căutare-text)

*(`grep` e probabil comanda pe care o folosesc cel mai des. Simplu, rapid, eficient.)*

3. [Modulul 3: SED - Stream Editor](#modulul-3-sed---stream-editor)
4. [Modulul 4: AWK - Procesare Structurată](#modulul-4-awk---procesare-structurată)
5. [Modulul 5: NANO - Editor Text Simplu](#modulul-5-nano---editor-text-simplu)
6. [Cheat Sheet Extins](#-cheat-sheet-extins)
7. [Combinații Frecvente](#-combinații-frecvente)

---

# MODULUL 1: EXPRESII REGULATE (REGEX)

## 1.1 Introducere și Tipuri

> Confesiune: Am lucrat 3 ani cu grep înainte să înțeleg cu adevărat diferența dintre BRE și ERE. Acum folosesc mereu `grep -E` (sau `egrep`) — e mai intuitiv și nu trebuie să îmi amintesc când să pun backslash și când nu.

### SUBGOAL 1.1.1: Înțelege ce sunt expresiile regulate

Expresiile regulate (regular expressions sau regex) sunt pattern-uri care descriu seturi de șiruri de caractere. Sunt un limbaj formal pentru specificarea regulilor de potrivire text.

Utilizări principale:
- Căutare: Găsirea textului care se potrivește unui pattern
- Validare: Verificarea formatului datelor de intrare
- Extragere: Izolarea porțiunilor relevante dintr-un text
- Înlocuire: Substituția textului pe bază de pattern-uri

### Tipurile de Expresii Regulate

| Tip | Nume Complet | Utilizare | Caracteristici |
|-----|--------------|-----------|----------------|
| BRE | Basic Regular Expression | grep, sed (implicit) | Metacaractere limitate, escape necesar pentru +, ?, {}, (), \| |
| ERE | Extended Regular Expression | grep -E, awk, sed -E | Metacaractere extinse fără escape |
| PCRE | Perl Compatible RE | grep -P, limbaje moderne | Features avansate: lookahead, lookbehind, \d, \w, etc. |

Regula de aur: Când ai dubii, folosește ERE (grep -E, sed -E) - e mai intuitiv și consistent.

---

## 1.2 Metacaractere

### SUBGOAL 1.2.1: Stăpânește metacaracterele de bază

Metacaracterele sunt caractere cu semnificație specială în regex.

### Caracterul `.` (punct)

Semnificație: Potrivește orice caracter singur (exceptând newline implicit).

```bash
# Pattern: a.c
# Potrivește: abc, a1c, aXc, a c
# NU potrivește: ac (lipsește caracterul din mijloc)

echo -e "abc\na1c\naXc\nac" | grep 'a.c'
# Output: abc, a1c, aXc
```

> 🔮 **PREDICȚIE:** Înainte să rulezi, gândește-te: de ce `ac` nu apare în output?

### Caracterul `^` (caret)

Semnificație: Potrivește începutul liniei (anchor).

```bash
# Pattern: ^Start
# Potrivește liniile care ÎNCEP cu "Start"

echo -e "Start here\nNot Start\nStarting" | grep '^Start'
# Output: Start here, Starting
```

> 🔮 **PREDICȚIE:** De ce "Not Start" nu apare, deși conține cuvântul "Start"?

### Caracterul `$` (dollar)

Semnificație: Potrivește sfârșitul liniei (anchor).

```bash
# Pattern: end$
# Potrivește liniile care SE TERMINĂ cu "end"

echo -e "The end\nendless\nFriend" | grep 'end$'
# Output: The end
```

### Caracterul `\` (backslash)

Semnificație: Escape - face ca următorul caracter să fie tratat literal.

```bash
# Pentru a căuta un punct literal
grep '192\.168\.1\.1' file.txt    # Caută IP-ul exact

# Fără escape, . ar potrivi orice caracter
grep '192.168.1.1' file.txt       # Ar potrivi și "192X168Y1Z1"
```

### Tabel rezumat metacaractere de bază

| Simbol | Semnificație | Exemplu | Potrivește |
|--------|--------------|---------|------------|
| `.` | Orice caracter (unul) | `a.c` | abc, aXc, a1c |
| `^` | Început de linie | `^Start` | "Start..." la început |
| `$` | Sfârșit de linie | `end$` | "...end" la final |
| `\` | Escape | `\.` | punct literal |

---

## 1.3 Clase de Caractere

### SUBGOAL 1.3.1: Folosește seturi de caractere

Clasele de caractere permit specificarea unui set de caractere posibile.

### Seturi Explicite cu `[...]`

```bash
[abc]       # Potrivește UN caracter: a SAU b SAU c
[a-z]       # Potrivește orice literă mică (range)
[A-Z]       # Potrivește orice literă mare
[0-9]       # Potrivește orice cifră
[a-zA-Z]    # Potrivește orice literă
[a-zA-Z0-9] # Potrivește alfanumeric
```

### Negarea cu `[^...]`

```bash
[^abc]      # Potrivește orice caracter EXCEPTÂND a, b, c
[^0-9]      # Potrivește orice caracter care NU E cifră
[^a-z]      # Potrivește orice care NU E literă mică
```

> ⚠️ ATENȚIE: `^` are semnificații diferite în funcție de context:
> - `^abc` = linia începe cu "abc" (anchor)
> - `[^abc]` = orice caracter EXCEPTÂND a, b, c (negație în set)

### Clase POSIX

Clasele POSIX sunt independente de locale și mai expresive:

```bash
[[:alpha:]]     # Litere [a-zA-Z]
[[:digit:]]     # Cifre [0-9]
[[:alnum:]]     # Alfanumeric [a-zA-Z0-9]
[[:space:]]     # Whitespace (spațiu, tab, newline)
[[:lower:]]     # Litere mici [a-z]
[[:upper:]]     # Litere mari [A-Z]
[[:punct:]]     # Punctuație
[[:blank:]]     # Spațiu și tab (nu newline)
[[:print:]]     # Caractere printabile
[[:xdigit:]]    # Hexadecimal [0-9A-Fa-f]
```

### Exemple practice

```bash
# Găsește linii care conțin cifre
grep '[0-9]' file.txt

# Găsește linii care încep cu literă mare
grep '^[A-Z]' file.txt

# Găsește linii cu caractere non-alfanumerice
grep '[^[:alnum:]]' file.txt

# Găsește cuvinte care încep cu majusculă
grep '\b[A-Z][a-z]*\b' file.txt
```

---

## 1.4 Quantificatori

### SUBGOAL 1.4.1: Controlează repetițiile

Quantificatorii specifică DE CÂTE ORI se poate repeta un element.

### Diferențe BRE vs ERE

| Quantificator | BRE | ERE | Semnificație |
|--------------|-----|-----|--------------|
| Zero sau mai multe | `*` | `*` | Precedentul de 0+ ori |
| Una sau mai multe | `\+` | `+` | Precedentul de 1+ ori |
| Zero sau una | `\?` | `?` | Precedentul de 0 sau 1 ori |
| Exact n | `\{n\}` | `{n}` | Precedentul de exact n ori |
| Minim n | `\{n,\}` | `{n,}` | Precedentul de n+ ori |
| Între n și m | `\{n,m\}` | `{n,m}` | Precedentul de n-m ori |

### Exemple detaliate

```bash
# * = zero sau mai multe
echo -e "ac\nabc\nabbc\nabbbc" | grep 'ab*c'
# Output: ac, abc, abbc, abbbc (toate!)

# + = una sau mai multe (necesită ERE)
echo -e "ac\nabc\nabbc\nabbbc" | grep -E 'ab+c'
# Output: abc, abbc, abbbc (NU ac - trebuie minim un b)

# ? = zero sau una
echo -e "color\ncolour" | grep -E 'colou?r'
# Output: color, colour (u-ul e opțional)

# {n} = exact n repetări
echo -e "12\n123\n1234\n12345" | grep -E '[0-9]{4}'
# Output: 1234, 12345 (minim 4 cifre consecutive)

# {n,m} = între n și m repetări
echo -e "ab\nabb\nabbb\nabbbb" | grep -E 'ab{2,3}'
# Output: abb, abbb (2 sau 3 de b)
```

### Greedy vs Lazy (Avansat - PCRE)

Implicit, quantificatorii sunt **greedy** (iau cât mai mult posibil):

```bash
# Text: <div>Hello</div><div>World</div>

# Greedy: .*
grep -oP '<div>.*</div>' <<< '<div>Hello</div><div>World</div>'
# Output: <div>Hello</div><div>World</div> (tot!)

# Lazy: .*?
grep -oP '<div>.*?</div>' <<< '<div>Hello</div><div>World</div>'
# Output: <div>Hello</div> (minim necesar)
```

> 🔮 **PREDICȚIE:** Ce s-ar întâmpla dacă ai folosi `grep -oE` în loc de `grep -oP`? (Hint: ERE nu suportă `?` pentru lazy matching)

> Observație: `*?` și `+?` (lazy) sunt disponibile doar în PCRE (grep -P).

---

## 1.5 Grupare și Alternative

### Gruparea cu `()`

În ERE, parantezele grupează elemente pentru a aplica quantificatori:

```bash
# Repetarea unui grup
echo -e "ab\nabab\nababab" | grep -E '(ab)+'
# Output: toate (au minim un "ab")

# Grupare pentru alternative
echo -e "cat\ndog\ncat and dog" | grep -E '(cat|dog)'
# Output: toate liniile cu cat SAU dog
```

### Alternativa cu `|`

Operatorul `|` funcționează ca OR logic:

```bash
# Caută error SAU warning SAU fatal
grep -E 'error|warning|fatal' log.txt

# Cu grupare pentru context
grep -E '^(yes|no)$' file.txt    # Linii cu DOAR "yes" sau "no"
```

### Backreferences

Referințele înapoi permit refolosirea grupurilor capturate:

```bash
# \1 = primul grup capturat, \2 = al doilea, etc.

# Găsește cuvinte duplicate
echo "the the quick fox" | grep -E '\b(\w+)\s+\1\b'
# Output: the the

# Inversează ordine (prenume nume → nume, prenume)
echo "John Smith" | sed 's/\([A-Za-z]*\) \([A-Za-z]*\)/\2, \1/'
# Output: Smith, John

# Tag-uri HTML corespunzătoare
grep -E '<([a-z]+)>.*</\1>' file.html
# Potrivește <div>text</div> dar nu <div>text</span>
```

---

## 1.6 Anchors și Word Boundaries

### Anchors de linie

```bash
^       # Început de linie
$       # Sfârșit de linie

# Linie goală
grep '^$' file.txt

# Linie care conține DOAR un număr
grep -E '^[0-9]+$' file.txt
```

### Word Boundaries

```bash
\b      # Word boundary (început SAU sfârșit de cuvânt)
\B      # NON-word boundary
\<      # Început de cuvânt (GNU extension)
\>      # Sfârșit de cuvânt (GNU extension)
```

### Exemple practice

```bash
# Cuvânt exact "word" (nu "password" sau "wording")
grep '\bword\b' file.txt
grep '\<word\>' file.txt    # Echivalent GNU

# Cuvinte care încep cu "pre"
grep '\bpre' file.txt       # prefix, prepare, etc.

# Cuvinte care se termină cu "ing"
grep 'ing\b' file.txt       # running, jumping, etc.

# Cuvinte de exact 5 litere
grep -E '\b[a-zA-Z]{5}\b' file.txt
```

---

## 1.7 BRE vs ERE - Tabel Comparativ Complet

| Feature | BRE (Basic) | ERE (Extended) | Notă |
|---------|-------------|----------------|------|
| Metacaractere de bază | `.` `^` `$` `*` `[` `]` `\` | Toate din BRE | Identice |
| Quantificator + | `\+` | `+` | ERE mai simplu |
| Quantificator ? | `\?` | `?` | ERE mai simplu |
| Interval {n,m} | `\{n,m\}` | `{n,m}` | ERE mai simplu |
| Grupare | `\(\)` | `()` | ERE mai simplu |
| Alternativă | `\|` | `|` | ERE mai simplu |
| Utilizare grep | `grep` | `grep -E` sau `egrep` | |
| Utilizare sed | `sed` | `sed -E` sau `sed -r` | |
| Utilizare awk | - | Default | awk folosește ERE |

Recomandare practică: Folosește mereu grep -E și sed -E pentru consistență și simplitate.

---

# MODULUL 2: GREP - CĂUTARE TEXT

## 2.1 Sintaxă și Variante

### SUBGOAL 2.1.1: Alege varianta corectă de grep

GREP = Global Regular Expression Print

Caută linii care se potrivesc cu un pattern și le afișează.

### Variante principale

| Comandă | Echivalent | Tip Regex | Când să folosești |
|---------|------------|-----------|-------------------|
| `grep` | - | BRE | Căutări simple |
| `grep -E` | `egrep` | ERE | Pattern-uri cu +, ?, \|, {} |
| `grep -F` | `fgrep` | Fixed | Căutare text literal (rapid) |
| `grep -P` | - | PCRE | Features avansate (\d, lookahead) |

### Sintaxa de bază

```bash
grep [opțiuni] 'pattern' [fișiere]
grep [opțiuni] -e 'pattern1' -e 'pattern2' [fișiere]
grep [opțiuni] -f pattern_file [fișiere]
```

---

## 2.2 Opțiuni Esențiale

### SUBGOAL 2.2.1: Stăpânește opțiunile frecvente

### Opțiuni de Matching

```bash
-i, --ignore-case       # Case-insensitive
-w, --word-regexp       # Cuvânt întreg (echivalent cu \b...\b)
-x, --line-regexp       # Linie întreagă (echivalent cu ^...$)
-v, --invert-match      # Inversează - linii care NU conțin pattern
-e PATTERN              # Specifică pattern (pentru multiple)
-f FILE                 # Citește pattern-uri din fișier
```

### Opțiuni de Output

```bash
-n, --line-number       # Afișează numerele de linie
-c, --count             # Numără liniile cu potriviri (nu caracterele!)
-l, --files-with-matches    # Afișează doar numele fișierelor cu potriviri
-L, --files-without-match   # Fișiere FĂRĂ potriviri
-o, --only-matching     # Afișează DOAR partea care se potrivește
-m NUM                  # Oprește după NUM potriviri
-q, --quiet             # Silent - doar exit code (pentru scripturi)
-H, --with-filename     # Afișează numele fișierului (implicit pentru multiple fișiere)
-h, --no-filename       # NU afișa numele fișierului
```

### Opțiuni de Context

```bash
-A NUM, --after-context=NUM     # NUM linii DUPĂ match
-B NUM, --before-context=NUM    # NUM linii ÎNAINTE de match
-C NUM, --context=NUM           # NUM linii înainte ȘI după
```

### Opțiuni pentru Fișiere și Directoare

```bash
-r, --recursive         # Caută recursiv în directoare
-R, --dereference-recursive  # Recursiv, urmărește symlinks
--include=GLOB          # Doar fișierele care se potrivesc cu glob
--exclude=GLOB          # Exclude fișierele care se potrivesc
--exclude-dir=DIR       # Exclude directoare
```

---

## 2.3 Pattern-uri Practice

### Validare și Extragere Email

```bash
# Pattern pentru email (simplificat)
EMAIL='[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'

# Găsește linii cu email-uri
grep -E "$EMAIL" contacts.txt

# Extrage DOAR email-urile
grep -oE "$EMAIL" document.txt
```

### Validare și Extragere IP

```bash
# Pattern pentru IPv4 (basic)
IP='([0-9]{1,3}\.){3}[0-9]{1,3}'

# Extrage IP-uri din log
grep -oE "$IP" access.log

# Pattern mai strict (0-255)
IP_STRICT='((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)'
```

### Pattern-uri pentru Log-uri

```bash
# Erori HTTP (4xx, 5xx)
grep -E '" [45][0-9]{2} ' access.log

# Timestamp în format standard
grep -E '[0-9]{2}/[A-Za-z]{3}/[0-9]{4}:[0-9]{2}:[0-9]{2}:[0-9]{2}' access.log

# Linii cu ERROR sau WARN
grep -Ei '(error|warn|critical)' application.log
```

---

## 2.4 GREP în Pipeline-uri

### Combinații frecvente

```bash
# Filtrare output de procese (evită să găsească propria comandă grep)
ps aux | grep '[n]ginx'
# Trucul [n]ginx: pattern-ul se potrivește cu "nginx" dar NU cu "[n]ginx"

# Top 10 IP-uri din access.log
grep -oE '^[0-9.]+' access.log | sort | uniq -c | sort -rn | head -10

# Căutare în cod sursă, excluzând directoare
grep -rn --include='*.py' --exclude-dir='.git' 'def ' ~/projects/

# Numără erorile pe zi
grep 'ERROR' app.log | cut -d' ' -f1 | uniq -c
```

### Exit Codes în Scripturi

```bash
# Exit codes:
# 0 - găsit potriviri
# 1 - nu a găsit potriviri
# 2 - eroare (fișier inexistent, etc.)

# Utilizare în if
if grep -q 'error' log.txt; then
    echo "Erori găsite!"
    exit 1
fi

# Utilizare cu &&
grep -q 'pattern' file.txt && echo "Găsit"
```

---

# MODULUL 3: SED - STREAM EDITOR

## 3.1 Model de Funcționare

### SUBGOAL 3.1.1: Înțelege cum procesează sed

SED (Stream EDitor) este un editor de text non-interactiv care procesează textul linie cu linie.

### Modelul de execuție

```
┌─────────────────────────────────────────────────────────────┐
│                     SED PROCESSING MODEL                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  INPUT FILE                                                 │
│       │                                                     │
│       ▼                                                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Pentru fiecare linie:                               │   │
│  │   1. Citește linia în "pattern space"               │   │
│  │   2. Aplică TOATE comenzile în ordine               │   │
│  │   3. Printează pattern space (dacă nu e -n)         │   │
│  │   4. Golește pattern space                          │   │
│  │   5. Treci la următoarea linie                      │   │
│  └─────────────────────────────────────────────────────┘   │
│       │                                                     │
│       ▼                                                     │
│  OUTPUT (stdout sau fișier cu -i)                          │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Sintaxa de bază

```bash
sed 'comandă' file
sed -e 'cmd1' -e 'cmd2' file    # Multiple comenzi
sed -f script.sed file          # Comenzi din fișier
sed -i 'comandă' file           # Editare in-place (modifică fișierul!)

> 💡 Am avut studenți care au învățat Bash în două săptămâni pornind de la zero — deci se poate, cu practică consistentă.

sed -i.bak 'comandă' file       # In-place cu backup
```

---

## 3.2 Comanda de Substituție (s)

### SUBGOAL 3.2.1: Stăpânește substituția

Substituția este cea mai folosită comandă sed.

### Sintaxa

```bash
s/pattern/replacement/flags

# Flags comune:
# g - global (toate aparițiile pe linie)
# i - case-insensitive
# p - print linia modificată (util cu -n)
# w file - scrie liniile modificate în fișier
# N - înlocuiește a N-a apariție
```

### Exemple de bază

```bash
# Prima apariție pe fiecare linie
echo "cat cat cat" | sed 's/cat/dog/'
# Output: dog cat cat
```

> 🔮 **PREDICȚIE:** Ce obții dacă adaugi flag-ul `g`? Dar dacă folosești `s/cat/dog/2`?

```bash
# Toate aparițiile (global)
echo "cat cat cat" | sed 's/cat/dog/g'
# Output: dog dog dog

# Case-insensitive
echo "Cat CAT cat" | sed 's/cat/dog/gi'
# Output: dog dog dog

# A doua apariție
echo "cat cat cat" | sed 's/cat/dog/2'
# Output: cat dog cat

# De la a doua apariție încolo
echo "cat cat cat cat" | sed 's/cat/dog/2g'
# Output: cat dog dog dog
```

### Delimitatori Alternativi

Când pattern-ul conține `/`, folosește alt delimiter:

```bash
# Problema: / în path
sed 's//usr/local//opt/' file.txt    # EROARE!

# Soluție: alt delimiter
sed 's|/usr/local|/opt|g' file.txt   # OK
sed 's#/usr/local#/opt#g' file.txt   # OK
sed 's@/usr/local@/opt@g' file.txt   # OK
```

---

## 3.3 Adresare

### SUBGOAL 3.3.1: Țintește linii specifice

Adresele specifică PE CE LINII să se aplice comanda.

### Tipuri de adrese

```bash
# Număr de linie
sed '5d' file.txt              # Șterge linia 5
sed '1,10s/old/new/' file.txt  # Substituție pe liniile 1-10
sed '$d' file.txt              # Șterge ultima linie

# Pattern (regex)
sed '/error/d' file.txt        # Șterge linii cu "error"
sed '/^#/s/^/COMMENT: /' file  # Prefixează comentarii

# Range cu pattern
sed '/start/,/end/d' file.txt  # Șterge de la "start" la "end"
sed '1,/^$/d' file.txt         # De la 1 la prima linie goală

# Step (GNU extension)
sed '1~2d' file.txt            # Șterge linii impare (1,3,5...)
sed '0~2d' file.txt            # Șterge linii pare (2,4,6...)

# Negare
sed '/pattern/!d' file.txt     # Șterge linii FĂRĂ pattern
                               # (echivalent cu grep 'pattern')
```

---

## 3.4 Alte Comenzi

### Ștergere (d)

```bash
sed '5d' file.txt              # Șterge linia 5
sed '1,10d' file.txt           # Liniile 1-10
sed '/pattern/d' file.txt      # Linii cu pattern
sed '/^$/d' file.txt           # Linii goale
sed '/^#/d' file.txt           # Comentarii (încep cu #)
sed '1d;$d' file.txt           # Prima și ultima linie

> 💡 De-a lungul anilor, am constatat că exemplele practice bat teoria de fiecare dată.

```

### Printare (p)

```bash
# -n suprimă output implicit
sed -n '5p' file.txt           # Doar linia 5
sed -n '1,10p' file.txt        # Liniile 1-10
sed -n '/pattern/p' file.txt   # Echivalent cu grep 'pattern'
sed -n '1p;$p' file.txt        # Prima și ultima
```

### Inserare și Adăugare

```bash
# i = insert (înainte)
sed '3i\Text nou' file.txt     # Inserează înainte de linia 3
sed '/pattern/i\TEXT' file     # Înainte de linii cu pattern
sed '1i\#!/bin/bash' script    # Adaugă shebang

# a = append (după)
sed '3a\Text nou' file.txt     # Adaugă după linia 3
sed '$a\END' file.txt          # Adaugă la final

# c = change (înlocuiește linia)
sed '3c\Linie nouă' file.txt   # Înlocuiește linia 3
```

### modificare (y)

```bash
# y/source/dest/ - înlocuire caracter-cu-caracter (transliterate)
sed 'y/abc/ABC/' file.txt      # a→A, b→B, c→C
sed 'y/aeiou/12345/' file.txt  # vocale → cifre
```

---

## 3.5 Editare In-Place

### SUBGOAL 3.5.1: Modifică fișiere în siguranță

```bash
# PERICULOS - fără backup
sed -i 's/old/new/g' file.txt

# SIGUR - cu backup automat
sed -i.bak 's/old/new/g' file.txt
# Creează file.txt.bak cu originalul

# Verifică întâi ce ar face
sed 's/old/new/g' file.txt | head  # Preview
sed -n 's/old/new/gp' file.txt     # Doar liniile modificate
```

> ⚠️ REGULA DE AUR: Întotdeauna folosește `-i.bak` până ești sigur că comanda e corectă!

---

## 3.6 Backreferences și &

### & = Match-ul întreg

```bash
# & în replacement reprezintă ÎNTREGUL MATCH
sed 's/[0-9]\+/[&]/' file.txt     # pune numere în []
# "Port 8080" → "Port [8080]"

sed 's/.*/(&)/' file.txt          # pune fiecare linie în ()
```

### Backreferences cu grupuri

```bash
# \1, \2, etc. = grupuri capturate cu \( \)

# Inversează ordine
echo "John Smith" | sed 's/\([A-Za-z]*\) \([A-Za-z]*\)/\2, \1/'
# Output: Smith, John

# Duplică un cuvânt
echo "hello" | sed 's/\(.*\)/\1 \1/'
# Output: hello hello

# Extrage domeniu din email
echo "user_AT_example_DOT_com" | sed 's/.*@\(.*\)/\1/'
# Output: example.com
```

---

# MODULUL 4: AWK - PROCESARE STRUCTURATĂ

## 4.1 Model de Execuție

### SUBGOAL 4.1.1: Înțelege pattern { action }

AWK este un limbaj de programare pentru procesarea textului structurat.

### Sintaxa de bază

```bash
awk 'pattern { action }' file
awk -F'delimiter' 'program' file
awk -f script.awk file
```

### Modelul de execuție

```
┌─────────────────────────────────────────────────────────────┐
│                     AWK EXECUTION MODEL                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Execută BEGIN { ... } o singură dată                   │
│                                                             │
│  2. Pentru FIECARE linie din input:                        │
│     a) Împarte linia în câmpuri ($1, $2, ..., $NF)         │
│     b) Pentru fiecare regulă 'pattern { action }':         │
│        - Evaluează pattern                                  │
│        - Dacă TRUE, execută action                         │
│                                                             │
│  3. Execută END { ... } o singură dată                     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 4.2 Câmpuri și Variabile Built-in

### SUBGOAL 4.2.1: Accesează datele structurate

### Câmpuri

```bash
$0      # ÎNTREAGA linie
$1      # Primul câmp
$2      # Al doilea câmp
...
$NF     # Ultimul câmp
$(NF-1) # Penultimul câmp
```

### Variabile Built-in

| Variabilă | Descriere | Valoare Default |
|-----------|-----------|-----------------|
| `NR` | Number of Record - numărul liniei curente (global) | - |
| `NF` | Number of Fields - câmpuri pe linia curentă | - |
| `FS` | Field Separator - separator input | spațiu/tab |
| `OFS` | Output Field Separator | spațiu |
| `RS` | Record Separator - separator linii | newline |
| `ORS` | Output Record Separator | newline |
| `FILENAME` | Numele fișierului curent | - |
| `FNR` | File Number of Record - nr. linie în fișierul curent | - |

### Exemple

```bash
# Afișează prima coloană
awk '{ print $1 }' file.txt

# Afișează ultima coloană
awk '{ print $NF }' file.txt
```

> 🔮 **PREDICȚIE:** Dacă o linie are 5 câmpuri, ce valoare are `$NF`? Dar dacă vrei penultimul câmp, ce folosești?

```bash
# CSV cu separator virgulă
awk -F',' '{ print $2 }' data.csv

# Multiple separatori
awk -F'[,;:]' '{ print $1 }' file.txt

# Setare FS în BEGIN
awk 'BEGIN { FS="," } { print $2 }' data.csv
```

---

## 4.3 Pattern-uri și Condiții

### Tipuri de pattern-uri

```bash
# Regex
awk '/error/' log.txt           # Linii cu "error"
awk '/^#/' config.txt           # Linii care încep cu #
awk '!/^#/' config.txt          # Linii care NU încep cu #

# Comparație
awk '$3 > 100' file.txt         # Coloana 3 > 100
awk '$1 == "John"' file.txt     # Coloana 1 este "John"
awk 'NR > 1' file.txt           # Skip header (linia 1)
```

> 🔮 **PREDICȚIE:** Pentru un CSV cu header, dacă vrei să numeri totalul de înregistrări (fără header), ce diferență este între `NR-1` în `END` și `wc -l | ... - 1`?

```bash
# Range
awk '/start/,/end/' file.txt    # De la "start" până la "end"
awk 'NR==5,NR==10' file.txt     # Liniile 5-10

# Combinații logice
awk '$3 > 100 && $4 < 50' file.txt
awk '$1 == "A" || $1 == "B"' file.txt
awk '!/^#/ && !/^$/' file.txt   # Non-comentarii și non-goale
```

### BEGIN și END

```bash
# BEGIN - execută ÎNAINTE de prima linie
# END - execută DUPĂ ultima linie

awk 'BEGIN { print "=== RAPORT ===" } 
     { print $0 } 
     END { print "=== SFÂRȘIT ===" }' file.txt

# Numără linii (mai mult decât wc -l pentru că vedem procesul)
awk 'END { print "Total:", NR, "linii" }' file.txt

# Calculează medie
awk '{ sum += $1 } END { print "Media:", sum/NR }' numbers.txt
```

---

## 4.4 Print și Printf

### SUBGOAL 4.4.1: Formatează output-ul

### print - simplu

```bash
# Cu virgulă - folosește OFS (default: spațiu)
awk '{ print $1, $2 }' file.txt

# Fără virgulă - concatenare directă!
awk '{ print $1 $2 }' file.txt    # Capcană: lipite!

# Cu separator custom
awk '{ print $1 " - " $2 }' file.txt
```

> ⚠️ **ATENȚIE MAJORĂ**: `print $1 $2` și `print $1, $2` sunt DIFERITE!

### printf - formatat

```bash
awk '{ printf "%-10s %5d\n", $1, $2 }' file.txt

# Formate printf:
# %s - string
# %d - integer
# %f - float
# %e - scientific notation
# %-10s - string aliniat stânga, 10 caractere
# %5d - integer, 5 caractere (aliniat dreapta)
# %.2f - float cu 2 zecimale
# %05d - integer cu zero padding (00042)
```

### Exemple printf

```bash
# Tabel formatat
awk -F',' 'BEGIN { printf "%-15s %10s\n", "Name", "Salary" }
           NR>1  { printf "%-15s $%9d\n", $2, $4 }' employees.csv

# Procente
awk '{ printf "%s: %.1f%%\n", $1, $2*100 }' ratios.txt
```

---

## 4.5 Variabile și Operatori

### Variabile definite de utilizator

```bash
# Declarare implicită (nu trebuie declarate)
awk '{ count++ } END { print count }' file.txt

# Din command line cu -v
awk -v threshold=100 '$3 > threshold' file.txt
awk -v name="John" '$1 == name' file.txt
```

### Operatori

```bash
# Aritmetici
+  -  *  /  %  ^

# Comparație
==  !=  <  >  <=  >=

# Regex match
~     # potrivește regex
!~    # NU potrivește regex

# Logici
&&  ||  !

# Increment/Decrement
++  --  +=  -=  *=  /=
```

### Exemple

```bash
# Filtrare cu regex
awk '$1 ~ /^192\.168/' log.txt     # IP-uri din 192.168.*
awk '$2 !~ /error/' log.txt        # Fără "error" în coloana 2

# Operații aritmetice
awk '{ total += $3 * $4 } END { print total }' sales.txt
```

---

## 4.6 Structuri de Control

### If-Else

```bash
awk '{ 
    if ($3 > 100) 
        print "High:", $1
    else if ($3 > 50) 
        print "Medium:", $1
    else 
        print "Low:", $1 
}' file.txt
```

### Bucle

```bash
# For clasic
awk '{ for (i=1; i<=NF; i++) print $i }' file.txt

# While
awk '{ 
    i = 1
    while (i <= NF) { 
        print $i
        i++ 
    } 
}' file.txt

# For-in (pentru arrays)
awk '{ count[$1]++ } 
     END { for (key in count) print key, count[key] }' file.txt
```

---

## 4.7 Arrays Asociative

### SUBGOAL 4.7.1: Agregă și numără date

AWK suportă arrays asociative (hash maps).

```bash
# Numărare frecvență
awk '{ count[$1]++ } 
     END { for (k in count) print k, count[k] }' file.txt

# Sume pe categorii
awk -F',' 'NR>1 { sum[$3] += $4 } 
           END { for (dept in sum) print dept, sum[dept] }' employees.csv

# Sortare output (cu sort extern)
awk '{ count[$1]++ } 
     END { for (k in count) print count[k], k }' file.txt | sort -rn
```

---

## 4.8 Funcții Built-in

### Funcții String

```bash
length(s)              # Lungimea stringului
substr(s, start, len)  # Substring (1-indexed!)
index(s, target)       # Poziția target în s (0 dacă nu e)
split(s, arr, sep)     # Împarte string în array
gsub(regex, repl, s)   # Înlocuire globală, returnează nr. înlocuiri
sub(regex, repl, s)    # Înlocuire prima apariție
tolower(s)             # Lowercase
toupper(s)             # Uppercase
sprintf(fmt, ...)      # Formatare în string
```

### Funcții Matematice

```bash
int(x)                 # Partea întreagă
sqrt(x)                # Radical
sin(x), cos(x)         # Trigonometrie
exp(x)                 # e^x
log(x)                 # Logaritm natural
rand()                 # Random 0-1
srand(seed)            # Setează seed pentru rand
```

### Exemple

```bash
# Uppercase coloana 1
awk '{ print toupper($1), $2 }' file.txt

# Extrage primele 3 caractere
awk '{ print substr($1, 1, 3) }' file.txt

# Înlocuire în awk
awk '{ gsub(/old/, "new"); print }' file.txt

# Split string
awk '{ n = split($0, arr, ":"); print arr[1], arr[n] }' /etc/passwd
```

---

# MODULUL 5: NANO - EDITOR TEXT SIMPLU

## 5.1 De Ce Nano?

### Puncte forte pentru începători

| Caracteristică | Nano | Vim |
|----------------|------|-----|
| Curba de învățare | Zero | Abruptă |
| Comenzi vizibile | Da, în footer | Nu, trebuie memorate |
| Moduri | Nu | Da (normal, insert, visual) |
| Timp până la productivitate | < 1 minut | > 1 oră |

Nano este ideal pentru:

Concret: Editare rapidă de configurări. Modificări mici în scripturi. Și Utilizatori care nu au nevoie de editor avansat.


---

## 5.2 Comenzi Esențiale

### SUBGOAL 5.2.1: Navighează și editează eficient

> Observație: `^` înseamnă tasta **CTRL**

### Comenzi de bază

| Comandă | Acțiune |
|---------|---------|
| `^O` | Write Out (Salvează) |
| `^X` | Exit (Ieșire) |
| `^W` | Where Is (Căutare) |
| `^K` | Cut (Taie linia curentă) |
| `^U` | Uncut/Paste (Lipește) |
| `^G` | Get Help (Ajutor) |

### Navigare

| Comandă | Acțiune |
|---------|---------|
| `^A` | Început de linie |
| `^E` | Sfârșit de linie |
| `^Y` | Pagină sus |
| `^V` | Pagină jos |
| `^_` | Go to line (salt la linie) |

### Editare

| Comandă | Acțiune |
|---------|---------|
| `^K` | Cut (taie linia) |
| `^U` | Paste (lipește) |
| `^\` | Replace (înlocuire) |
| `^J` | Justify (aliniere paragraf) |
| `^T` | Spell check (dacă e instalat) |

---

## 5.3 Configurare ~/.nanorc

```bash
# Creează sau editează ~/.nanorc
nano ~/.nanorc
```

Configurări utile:

```
# Dimensiune tab
set tabsize 4

# Auto-indent
set autoindent

# Afișează numerele de linie
set linenumbers

# Suport mouse
set mouse

# Soft wrap (nu taie liniile)
set softwrap

# Syntax highlighting (dacă există)
include /usr/share/nano/*.nanorc
```

---

## 5.4 Flux de Lucru Tipic

```bash
# 1. Deschide fișierul
nano script.sh

# 2. Editează conținutul
# - Scrie direct (nu are mod insert separat)
# - ^W pentru căutare
# - ^\ pentru înlocuire

# 3. Salvează
# - ^O (Write Out)
# - Confirmă numele (Enter)

# 4. Ieși
# - ^X (Exit)
# - Dacă ai modificări nesalvate, întreabă
```

---

# CHEAT SHEET EXTINS

## Regex Quick Reference

```
METACARACTERE
─────────────────────────────────────────
.           Orice caracter (unul)
^           Început de linie
$           Sfârșit de linie
\           Escape
\b          Word boundary
\d          Cifră (PCRE only)
\w          Word char (PCRE only)
\s          Whitespace (PCRE only)

CLASE DE CARACTERE
─────────────────────────────────────────
[abc]       Unul din: a, b, c
[^abc]      Orice EXCEPTÂND a, b, c
[a-z]       Range: a până la z
[[:alpha:]] Clase POSIX: litere
[[:digit:]] Clase POSIX: cifre

QUANTIFICATORI (ERE)
─────────────────────────────────────────
*           0 sau mai multe
+           1 sau mai multe
?           0 sau 1
{n}         Exact n
{n,}        n sau mai multe
{n,m}       Între n și m

GRUPARE (ERE)
─────────────────────────────────────────
(abc)       Grup
|           SAU (alternativă)
\1 \2       Backreference
```

## GREP Quick Reference

```
OPȚIUNI PRINCIPALE
─────────────────────────────────────────
-i          Case insensitive
-v          Inversează (NU conține)
-n          Afișează numere de linie
-c          Numără linii cu potriviri
-o          Doar match-ul
-l          Doar numele fișierelor
-r          Recursiv
-E          Extended regex (ERE)
-F          Fixed string (literal)
-w          Cuvânt întreg
-A N        N linii după
-B N        N linii înainte
-C N        N linii context
--include=  Doar fișierele specificate
--exclude=  Exclude fișiere
```

## SED Quick Reference

```
SUBSTITUȚIE
─────────────────────────────────────────
s/old/new/      Prima apariție pe linie
s/old/new/g     Toate aparițiile
s/old/new/gi    Case-insensitive
s|old|new|g     Alt delimiter

ADRESARE
─────────────────────────────────────────
5               Linia 5
1,10            Liniile 1-10
$               Ultima linie
/pattern/       Linii cu pattern
/start/,/end/   Range
!               Negare

COMENZI
─────────────────────────────────────────
d               Șterge
p               Printează
i\text          Insert înainte
a\text          Append după
c\text          Change (înlocuiește)

OPȚIUNI
─────────────────────────────────────────
-n              Suprimă output implicit
-i              In-place (ATENȚIE!)
-i.bak          In-place cu backup
-E              Extended regex
```

## AWK Quick Reference

```
SINTAXĂ
─────────────────────────────────────────
awk 'pattern { action }' file
awk -F',' '{ print $2 }' file.csv

CÂMPURI
─────────────────────────────────────────
$0              Linia întreagă
$1, $2, ...     Câmpuri
$NF             Ultimul câmp
NR              Nr. linie (global)
NF              Nr. câmpuri
FNR             Nr. linie în fișier

PATTERN-URI
─────────────────────────────────────────
/regex/         Match regex
$1 == "val"     Comparație
$1 > 10         Numeric
NR > 1          Skip header
BEGIN { }       Înainte de input
END { }         După input

PRINT
─────────────────────────────────────────
print $1, $2    Cu spațiu (OFS)
print $1 $2     Concatenat!
printf "%s %d"  Formatat

FUNCȚII
─────────────────────────────────────────
length(s)       Lungime
substr(s,i,n)   Substring
tolower(s)      Lowercase
gsub(r,s,t)     Replace all
split(s,a,sep)  Împarte în array
```

---

# COMBINAȚII FRECVENTE

## Pipeline-uri Utile

```bash
# Top 10 IP-uri din access log
grep -oE '^[0-9.]+' access.log | sort | uniq -c | sort -rn | head -10

# Curăță fișier config (elimină comentarii și linii goale)
sed '/^#/d; /^$/d' config.txt

# Calculează total din CSV
awk -F',' 'NR>1 { sum += $4 } END { print sum }' data.csv

# Găsește și înlocuiește în toate fișierele
grep -rl 'old' . | xargs sed -i 's/old/new/g'

# Raport angajați per departament
awk -F',' 'NR>1 { dept[$3]++; sal[$3]+=$4 } 
    END { for(d in dept) printf "%s: %d angajați, media $%.0f\n", d, dept[d], sal[d]/dept[d] }' employees.csv

# Extrage email-uri unice din fișier
grep -oE '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' doc.txt | sort -u

# Statistici cod sursă
find . -name '*.py' -exec wc -l {} + | sort -n

# Monitorizare log în timp real cu filtrare
tail -f /var/log/syslog | grep --line-buffered -i error
```

---

*Material teoretic pentru Seminarul 7-8 de Sisteme de Operare | ASE București - CSIE*
