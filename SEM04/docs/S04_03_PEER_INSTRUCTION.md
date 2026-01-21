# Peer Instruction: Text Processing
## Întrebări pentru Învățare Activă - Regex, GREP, SED, AWK

> Sisteme de Operare | Academia de Studii Economice București - CSIE  
> Seminar 7-8 | Peer Instruction Questions  
> Total întrebări: 24 | Timp estimat: 3-5 min per întrebare

---

## Ghid de Utilizare

### Ce este Peer Instruction?

Peer Instruction este o metodă de învățare activă dezvoltată de Eric Mazur (Harvard). Procesul:

1. Prezentare întrebare (30 sec) - Instructorul afișează întrebarea
2. Vot individual (1 min) - Studenții votează FĂRĂ discuții
3. Discuție în perechi (2 min) - Studenții își explică reciproc alegerile
4. Re-vot (30 sec) - Studenții votează din nou
5. Explicație (1-2 min) - Instructorul explică răspunsul corect

### Când să folosești fiecare întrebare

| Cod | Moment | Topic |
|-----|--------|-------|
| PI-R1 - PI-R6 | După intro Regex | Expresii Regulate |
| PI-G1 - PI-G6 | După secțiunea GREP | GREP |
| PI-S1 - PI-S6 | După secțiunea SED | SED |
| PI-A1 - PI-A6 | După secțiunea AWK | AWK |

---

# SECȚIUNEA 1: EXPRESII REGULATE

## PI-R1: Globbing vs Regex

```
┌─────────────────────────────────────────────────────────────────────────┐
│  PEER INSTRUCTION R1: Globbing vs Regex                                │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  Care este diferența PRINCIPALĂ între aceste două comenzi?             │
│                                                                         │
│     A) ls *.txt                                                         │
│     B) grep '.*\.txt' filelist.txt                                     │
│                                                                         │
│  Opțiuni:                                                               │
│  ┌───┐                                                                  │
│  │ 1 │ Sunt echivalente funcțional                                     │
│  ├───┤                                                                  │
│  │ 2 │ A folosește globbing shell, B folosește regex                   │
│  ├───┤                                                                  │
│  │ 3 │ A caută în fișiere, B listează fișiere                          │
│  ├───┤                                                                  │
│  │ 4 │ B e greșit sintactic                                            │
│  └───┘                                                                  │
│                                                                         │
│  Dificultate: ⭐⭐ | Misconception: M1.1 (confuzie * în glob vs regex) │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

Răspuns corect: 2

Explicație detaliată:

```bash
# GLOBBING (shell pattern matching)
ls *.txt
# * = orice caractere (zero sau mai multe)
# Shell expandează ÎNAINTE de a trimite la comandă
# ls primește: file1.txt file2.txt file3.txt

# REGEX (grep, sed, awk)
grep '.*\.txt' filelist.txt
# . = orice caracter SINGULAR
# * = zero sau mai multe din PRECEDENT
# .* = combinația = orice caractere
# \. = punct LITERAL (escapat)

# CONFUZIA MAJORĂ:
# Glob: * singur = orice
# Regex: * singur = quantificator (are nevoie de ceva înainte)
```

De ce contează: Studenții care vin din shell scripting aplică automat regulile de globbing la regex, ceea ce duce la pattern-uri greșite.

---

## PI-R2: Ce potrivește acest pattern?

```
┌─────────────────────────────────────────────────────────────────────────┐
│  PEER INSTRUCTION R2: Interpretare Pattern                             │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  Fișierul conține:                                                     │
│     abc                                                                 │
│     ac                                                                  │
│     aXc                                                                 │
│     a1c                                                                 │
│     abbc                                                                │
│                                                                         │
│  Comanda: grep 'a.c' file.txt                                          │
│                                                                         │
│  Ce linii va afișa?                                                     │
│  ┌───┐                                                                  │
│  │ 1 │ abc, ac, aXc, a1c, abbc (toate)                                 │
│  ├───┤                                                                  │
│  │ 2 │ abc, aXc, a1c (dar NU ac și abbc)                               │
│  ├───┤                                                                  │
│  │ 3 │ abc, aXc, a1c, abbc (dar NU ac)                                 │
│  ├───┤                                                                  │
│  │ 4 │ Doar abc                                                         │
│  └───┘                                                                  │
│                                                                         │
│  Dificultate: ⭐⭐ | Misconception: M1.1 (. = orice, dar EXACT unul)   │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

Răspuns corect: 3

Explicație:

```bash
# Pattern: a.c
# . = EXACT un caracter (orice, dar trebuie să existe)

# abc (. = b)
# ac (lipsește caracterul dintre a și c)
# aXc (. = X)
# a1c (. = 1)
# abbc (pattern găsit în mijloc: a[b]bc conține "abc")

# SURPRIZA: abbc potrivește pentru că grep caută SUBȘIR
# Dacă voiam exact 3 caractere: grep '^a.c$'
```

---

## PI-R3: Negarea în clase de caractere

```
┌─────────────────────────────────────────────────────────────────────────┐
│  PEER INSTRUCTION R3: [^...] - Ce înseamnă?                            │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  Ce potrivește pattern-ul [^0-9]?                                      │
│                                                                         │
│  ┌───┐                                                                  │
│  │ 1 │ Linii care ÎNCEP cu o cifră                                     │
│  ├───┤                                                                  │
│  │ 2 │ Orice caracter care NU este cifră                               │
│  ├───┤                                                                  │
│  │ 3 │ Linii care NU conțin cifre                                      │
│  ├───┤                                                                  │
│  │ 4 │ Începutul liniei urmat de 0-9                                   │
│  └───┘                                                                  │
│                                                                         │
│  Dificultate: ⭐⭐⭐ | Misconception: M1.4 (confuzie ^ context)        │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

Răspuns corect: 2

Explicație:

```bash
# ^ are DOUĂ semnificații diferite în regex:

# 1. ANCHOR (în afara [])
^abc     # Linia ÎNCEPE cu "abc"

# 2. NEGAȚIE (ÎNĂUNTRUL [] la început)
[^abc]   # Orice caracter CARE NU E a, b sau c
[^0-9]   # Orice caracter CARE NU E cifră

# Capcană: [^0-9] potrivește UN CARACTER, nu o linie întreagă!
grep '[^0-9]' file.txt   # Linii cu CEL PUȚIN un non-digit

# Pentru linii FĂRĂ cifre deloc:
grep -v '[0-9]' file.txt
```

---

## PI-R4: BRE vs ERE - Quantificatori

```
┌─────────────────────────────────────────────────────────────────────────┐
│  PEER INSTRUCTION R4: De ce nu funcționează +?                         │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  Comanda: grep 'ab+c' file.txt                                         │
│                                                                         │
│  Fișierul conține: abc, abbc, abbbc, ac                                │
│                                                                         │
│  Output-ul este GOL. De ce?                                            │
│                                                                         │
│  ┌───┐                                                                  │
│  │ 1 │ Pattern-ul e greșit, + nu există în regex                       │
│  ├───┤                                                                  │
│  │ 2 │ În BRE, + este caracter LITERAL, nu quantificator               │
│  ├───┤                                                                  │
│  │ 3 │ + cere cel puțin 2 caractere, nu 1                              │
│  ├───┤                                                                  │
│  │ 4 │ Fișierul nu conține textul "ab+c"                               │
│  └───┘                                                                  │
│                                                                         │
│  Dificultate: ⭐⭐⭐ | Misconception: M1.3 (BRE vs ERE)                │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

Răspuns corect: 2

Explicație:

```bash
# grep implicit folosește BRE (Basic Regular Expression)
# În BRE, + este caracter LITERAL!

grep 'ab+c' file.txt
# Caută literalmente "ab+c" (cu semnul plus)

# Soluții:

# 1. Folosește ERE
grep -E 'ab+c' file.txt    # abc, abbc, abbbc

# 2. Escape în BRE
grep 'ab\+c' file.txt      # abc, abbc, abbbc

# TABEL BRE vs ERE:
#
# Quantificator BRE ERE
#
# 1 sau mai m. \+ +
# 0 sau 1 \? ?
# {n,m} \{n,m\} {n,m}
# grupare \(\) ()
# alternativă \| |
#
```

---

## PI-R5: Greedy Matching

```
┌─────────────────────────────────────────────────────────────────────────┐
│  PEER INSTRUCTION R5: Cât de mult potrivește .*?                       │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  Text: <div>Hello</div><div>World</div>                                │
│                                                                         │
│  Comanda: grep -oE '<div>.*</div>'                                     │
│                                                                         │
│  Ce va afișa?                                                           │
│                                                                         │
│  ┌───┐                                                                  │
│  │ 1 │ <div>Hello</div>                                                │
│  ├───┤                                                                  │
│  │ 2 │ <div>Hello</div><div>World</div>                                │
│  ├───┤                                                                  │
│  │ 3 │ <div>Hello</div>                                                │
│  │   │ <div>World</div>  (două linii)                                  │
│  ├───┤                                                                  │
│  │ 4 │ Hello                                                            │
│  │   │ World  (două linii)                                             │
│  └───┘                                                                  │
│                                                                         │
│  Dificultate: ⭐⭐⭐⭐ | Misconception: M1.5 (greedy implicit)         │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

Răspuns corect: 2

Explicație:

```bash
# .* este GREEDY - ia CÂT MAI MULT posibil

echo '<div>Hello</div><div>World</div>' | grep -oE '<div>.*</div>'
# Output: <div>Hello</div><div>World</div>

# De ce? .* se "întinde" până la ULTIMUL </div>

# Pentru a lua MINIMUL (lazy), ai nevoie de PCRE:
echo '<div>Hello</div><div>World</div>' | grep -oP '<div>.*?</div>'
# Output:
# <div>Hello</div>
# <div>World</div>

# Alternativ, fără PCRE - evită . pentru caracterul greșit:
echo '<div>Hello</div><div>World</div>' | grep -oE '<div>[^<]*</div>'
# [^<]* = orice exceptând <, deci se oprește la primul <
```

---

## PI-R6: Word Boundary

```
┌─────────────────────────────────────────────────────────────────────────┐
│  PEER INSTRUCTION R6: Când să folosești \b?                            │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  Fișierul conține:                                                     │
│     cat                                                                 │
│     category                                                            │
│     concatenate                                                         │
│     bobcat                                                              │
│                                                                         │
│  Vrei să găsești DOAR linia cu cuvântul exact "cat".                   │
│  Ce comandă folosești?                                                  │
│                                                                         │
│  ┌───┐                                                                  │
│  │ 1 │ grep 'cat' file.txt                                             │
│  ├───┤                                                                  │
│  │ 2 │ grep '^cat$' file.txt                                           │
│  ├───┤                                                                  │
│  │ 3 │ grep '\bcat\b' file.txt                                         │
│  ├───┤                                                                  │
│  │ 4 │ grep -w 'cat' file.txt                                          │
│  └───┘                                                                  │
│                                                                         │
│  BONUS: Care două opțiuni sunt echivalente?                            │
│                                                                         │
│  Dificultate: ⭐⭐ | Concept: Word boundaries                          │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

Răspuns corect: 3 și 4 (ambele funcționează, și sunt echivalente)

Explicație:

```bash
# 1. grep 'cat' - găsește TOATE (cat, category, concatenate, bobcat)

# 2. grep '^cat$' - doar dacă LINIA e exact "cat"
# Funcționează în acest caz, dar nu ar găsi "the cat sat"

# 3. grep '\bcat\b' - word boundary = cuvânt exact
# \b = granița între word char (\w) și non-word char

# 4. grep -w 'cat' - echivalent cu \b...\b
# -w = --word-regexp

# 3 și 4 sunt ECHIVALENTE și găsesc "cat" ca cuvânt independent
```

---

# SECȚIUNEA 2: GREP

## PI-G1: Output-ul lui grep -c

```
┌─────────────────────────────────────────────────────────────────────────┐
│  PEER INSTRUCTION G1: Ce numără grep -c?                               │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  Fișierul conține:                                                     │
│     error error error                                                   │
│     warning                                                             │
│     error                                                               │
│                                                                         │
│  Comanda: grep -c 'error' file.txt                                     │
│                                                                         │
│  Ce afișează?                                                           │
│                                                                         │
│  ┌───┐                                                                  │
│  │ 1 │ 4 (total apariții ale cuvântului "error")                       │
│  ├───┤                                                                  │
│  │ 2 │ 2 (linii care conțin "error")                                   │
│  ├───┤                                                                  │
│  │ 3 │ 3 (total linii în fișier)                                       │
│  ├───┤                                                                  │
│  │ 4 │ 17 (caractere în cuvântul "error" × apariții)                   │
│  └───┘                                                                  │
│                                                                         │
│  Dificultate: ⭐⭐ | Misconception: M2.5 (grep -c numără linii)        │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

Răspuns corect: 2

Explicație:

```bash
# grep -c numără LINII care conțin cel puțin o potrivire
# NU numără totalul de potriviri!

# Linia 1: "error error error" - 1 linie (cu 3 apariții)
# Linia 2: "warning" - 0 (nu conține error)
# Linia 3: "error" - 1 linie

# Total: 2 linii

# Pentru a număra TOATE aparițiile:
grep -o 'error' file.txt | wc -l
# Output: 4
```

---

## PI-G2: grep -o Behavior

```
┌─────────────────────────────────────────────────────────────────────────┐
│  PEER INSTRUCTION G2: Ce face -o?                                      │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  Fișierul conține:                                                     │
│     IP: 192.168.1.100 connected from 10.0.0.50                        │
│                                                                         │
│  Comanda: grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' file.txt          │
│                                                                         │
│  Ce afișează?                                                           │
│                                                                         │
│  ┌───┐                                                                  │
│  │ 1 │ IP: 192.168.1.100 connected from 10.0.0.50 (linia întreagă)    │
│  ├───┤                                                                  │
│  │ 2 │ 192.168.1.100                                                   │
│  │   │ 10.0.0.50  (pe linii separate)                                  │
│  ├───┤                                                                  │
│  │ 3 │ 192.168.1.100 10.0.0.50 (pe aceeași linie)                      │
│  ├───┤                                                                  │
│  │ 4 │ 192.168.1.100 (doar prima potrivire)                            │
│  └───┘                                                                  │
│                                                                         │
│  Dificultate: ⭐⭐ | Misconception: M2.3 (comportament -o)             │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

Răspuns corect: 2

Explicație:

```bash
# -o = only matching
# Afișează DOAR porțiunea care se potrivește
# Fiecare potrivire pe o linie separată!

# Fără -o:
grep -E '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' file.txt
# Output: IP: 192.168.1.100 connected from 10.0.0.50

# Cu -o:
grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' file.txt
# Output:
# 192.168.1.100
# 10.0.0.50

# Aceasta e foarte util pentru extragere!
```

---

## PI-G3: grep recursiv

```
┌─────────────────────────────────────────────────────────────────────────┐
│  PEER INSTRUCTION G3: Căutare în subdirectoare                         │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  Structura:                                                             │
│     project/                                                            │
│     ├── main.py (conține "TODO")                                       │
│     ├── lib/                                                            │
│     │   └── utils.py (conține "TODO")                                  │
│     └── tests/                                                          │
│         └── test_main.py (conține "TODO")                              │
│                                                                         │
│  Comanda: grep 'TODO' project/*.py                                     │
│                                                                         │
│  Câte fișiere găsește?                                                  │
│                                                                         │
│  ┌───┐                                                                  │
│  │ 1 │ 0 - pattern greșit                                              │
│  ├───┤                                                                  │
│  │ 2 │ 1 - doar main.py                                                │
│  ├───┤                                                                  │
│  │ 3 │ 3 - toate fișierele .py                                         │
│  ├───┤                                                                  │
│  │ 4 │ Eroare - nu poate accesa subdirectoare                          │
│  └───┘                                                                  │
│                                                                         │
│  Dificultate: ⭐⭐ | Misconception: M2.4 (recursiv automat)            │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

Răspuns corect: 2

Explicație:

```bash
# project/*.py se expandează DOAR la fișierele din project/
# NU intră în subdirectoare!

# Glob *.py = fișiere .py în directorul CURENT (sau specificat)

# Pentru subdirectoare, ai nevoie de:
grep -r 'TODO' project/                    # Toate fișierele
grep -r --include='*.py' 'TODO' project/   # Doar .py, recursiv

# Sau cu find:
find project -name '*.py' -exec grep 'TODO' {} +
```

---

## PI-G4: Excluderea procesului grep

```
┌─────────────────────────────────────────────────────────────────────────┐
│  PEER INSTRUCTION G4: ps aux | grep                                    │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  Vrei să vezi dacă nginx rulează.                                      │
│  Comanda: ps aux | grep nginx                                          │
│                                                                         │
│  Output:                                                                │
│     root  1234 ... nginx: master process                               │
│     root  5678 ... grep nginx                                          │
│                                                                         │
│  Cum poți evita să apară linia cu "grep nginx"?                        │
│                                                                         │
│  ┌───┐                                                                  │
│  │ 1 │ ps aux | grep nginx | grep -v grep                              │
│  ├───┤                                                                  │
│  │ 2 │ ps aux | grep '[n]ginx'                                         │
│  ├───┤                                                                  │
│  │ 3 │ pgrep nginx                                                      │
│  ├───┤                                                                  │
│  │ 4 │ Toate cele de mai sus funcționează                              │
│  └───┘                                                                  │
│                                                                         │
│  BONUS: Care e cea mai elegantă?                                        │
│                                                                         │
│  Dificultate: ⭐⭐⭐ | Concept: Self-exclusion trick                    │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

Răspuns corect: 4

Explicație:

```bash
# 1. grep -v grep - funcționează, dar inelegant
ps aux | grep nginx | grep -v grep

# 2. [n]ginx - trucul clasic!
ps aux | grep '[n]ginx'
# Pattern-ul [n]ginx potrivește "nginx"
# Dar procesul grep are comanda "grep [n]ginx"
# [n]ginx NU potrivește "[n]ginx" - e diferit!

# 3. pgrep - cel mai curat
pgrep nginx        # Doar PID-uri
pgrep -a nginx     # Cu linia de comandă

# Cel mai elegant: pgrep sau trucul [n]ginx
```

---

## PI-G5: grep -l vs grep -L

```
┌─────────────────────────────────────────────────────────────────────────┐
│  PEER INSTRUCTION G5: Fișiere cu/fără potriviri                        │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  Fișiere:                                                               │
│     a.txt: "error occurred"                                            │
│     b.txt: "all good"                                                   │
│     c.txt: "error: fatal"                                              │
│                                                                         │
│  Ce afișează: grep -L 'error' *.txt                                    │
│                                                                         │
│  ┌───┐                                                                  │
│  │ 1 │ a.txt și c.txt (fișierele CU error)                             │
│  ├───┤                                                                  │
│  │ 2 │ b.txt (fișierul FĂRĂ error)                                     │
│  ├───┤                                                                  │
│  │ 3 │ Lista tuturor fișierelor cu număr de potriviri                  │
│  ├───┤                                                                  │
│  │ 4 │ Conținutul liniilor fără "error"                                │
│  └───┘                                                                  │
│                                                                         │
│  Dificultate: ⭐⭐ | Misconception: M2.7                                │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

Răspuns corect: 2

Explicație:

```bash
# -l = files-with-matches
# Afișează numele fișierelor CARE CONȚIN pattern

# -L = files-without-match (opus!)
# Afișează numele fișierelor FĂRĂ pattern

grep -l 'error' *.txt   # a.txt, c.txt
grep -L 'error' *.txt   # b.txt

# Util pentru a găsi fișiere care NU au ceva:
grep -L 'copyright' *.py   # Fișiere fără header copyright
```

---

## PI-G6: Context Lines

```
┌─────────────────────────────────────────────────────────────────────────┐
│  PEER INSTRUCTION G6: -A, -B, -C                                       │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  Log file:                                                              │
│     Line 1: Starting service                                            │
│     Line 2: Loading config                                              │
│     Line 3: ERROR: Connection failed                                    │
│     Line 4: Retrying in 5 seconds                                       │
│     Line 5: Connected successfully                                      │
│                                                                         │
│  Comanda: grep -B 1 -A 1 'ERROR' log.txt                               │
│                                                                         │
│  Ce afișează?                                                           │
│                                                                         │
│  ┌───┐                                                                  │
│  │ 1 │ Doar Line 3 (linia cu ERROR)                                    │
│  ├───┤                                                                  │
│  │ 2 │ Line 2, Line 3, Line 4                                          │
│  ├───┤                                                                  │
│  │ 3 │ Line 1-5 (tot fișierul)                                         │
│  ├───┤                                                                  │
│  │ 4 │ Line 3, Line 4                                                   │
│  └───┘                                                                  │
│                                                                         │
│  Dificultate: ⭐ | Concept: Context lines                              │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

Răspuns corect: 2

Explicație:

```bash
# -B N = Before context (N linii ÎNAINTE)
# -A N = After context (N linii DUPĂ)
# -C N = Context (N linii înainte ȘI după, echivalent cu -B N -A N)

grep -B 1 -A 1 'ERROR' log.txt
# Line 2: Loading config (1 linie înainte)
# Line 3: ERROR: Connection... (potrivirea)
# Line 4: Retrying... (1 linie după)

# Foarte util pentru debugging log-uri!
```

---

# SECȚIUNEA 3: SED

## PI-S1: sed Output Destination

```
┌─────────────────────────────────────────────────────────────────────────┐
│  PEER INSTRUCTION S1: Unde scrie sed?                                  │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  Fișierul config.txt conține: server=localhost                         │
│                                                                         │
│  Comanda: sed 's/localhost/127.0.0.1/' config.txt                      │
│                                                                         │
│  După execuție, config.txt conține:                                    │
│                                                                         │
│  ┌───┐                                                                  │
│  │ 1 │ server=127.0.0.1 (modificat)                                    │
│  ├───┤                                                                  │
│  │ 2 │ server=localhost (nemodificat)                                  │
│  ├───┤                                                                  │
│  │ 3 │ Ambele versiuni (append)                                        │
│  ├───┤                                                                  │
│  │ 4 │ Fișier gol                                                       │
│  └───┘                                                                  │
│                                                                         │
│  Dificultate: ⭐⭐⭐ | Misconception: M3.1 (sed modifică direct)       │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

Răspuns corect: 2

Explicație:

```bash
# sed implicit scrie la STDOUT, nu modifică fișierul!

sed 's/localhost/127.0.0.1/' config.txt
# Afișează "server=127.0.0.1" pe ecran
# config.txt rămâne NEMODIFICAT

# Pentru a modifica fișierul:
sed -i 's/localhost/127.0.0.1/' config.txt   # In-place (periculos!)
sed -i.bak 's/localhost/127.0.0.1/' config.txt   # Cu backup

# Sau redirect:
sed 's/localhost/127.0.0.1/' config.txt > config_new.txt
```

---

## PI-S2: Global Flag

```
┌─────────────────────────────────────────────────────────────────────────┐
│  PEER INSTRUCTION S2: Câte înlocuiește fără /g?                        │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  Input: echo "cat cat cat" | sed 's/cat/dog/'                          │
│                                                                         │
│  Output?                                                                │
│                                                                         │
│  ┌───┐                                                                  │
│  │ 1 │ dog dog dog                                                      │
│  ├───┤                                                                  │
│  │ 2 │ dog cat cat                                                      │
│  ├───┤                                                                  │
│  │ 3 │ cat cat dog                                                      │
│  ├───┤                                                                  │
│  │ 4 │ cat dog cat                                                      │
│  └───┘                                                                  │
│                                                                         │
│  Dificultate: ⭐⭐⭐ | Misconception: M3.2 (s/// înlocuiește toate)    │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

Răspuns corect: 2

Explicație:

```bash
# Fără flag /g, sed înlocuiește doar PRIMA apariție pe linie

echo "cat cat cat" | sed 's/cat/dog/'
# Output: dog cat cat

echo "cat cat cat" | sed 's/cat/dog/g'
# Output: dog dog dog

# Alte flags utile:
# /2 = a doua apariție
# /3g = de la a treia apariție încolo

echo "cat cat cat cat" | sed 's/cat/dog/2'
# Output: cat dog cat cat

echo "cat cat cat cat" | sed 's/cat/dog/2g'
# Output: cat dog dog dog
```

---

## PI-S3: Delimitator Alternativ

```
┌─────────────────────────────────────────────────────────────────────────┐
│  PEER INSTRUCTION S3: Înlocuire path                                   │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  Vrei să înlocuiești /usr/local cu /opt                                │
│                                                                         │
│  Care comandă e CORECTĂ?                                               │
│                                                                         │
│  ┌───┐                                                                  │
│  │ 1 │ sed 's//usr/local//opt/' file.txt                               │
│  ├───┤                                                                  │
│  │ 2 │ sed 's|/usr/local|/opt|' file.txt                               │
│  ├───┤                                                                  │
│  │ 3 │ sed 's/\/usr\/local/\/opt/' file.txt                            │
│  ├───┤                                                                  │
│  │ 4 │ Opțiunile 2 și 3 sunt ambele corecte                            │
│  └───┘                                                                  │
│                                                                         │
│  Dificultate: ⭐⭐ | Misconception: M3.4 (delimiter fix)               │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

Răspuns corect: 4

Explicație:

```bash
# 1. GREȘIT - prea multe /
sed 's//usr/local//opt/' file.txt  # Eroare de sintaxă

# 2. CORECT - delimiter alternativ |
sed 's|/usr/local|/opt|' file.txt

# 3. CORECT - escape pentru /
sed 's/\/usr\/local/\/opt/' file.txt

# Alte delimitatori acceptați: # @ : ! etc.
sed 's#/usr/local#/opt#' file.txt
sed 's@/usr/local@/opt@' file.txt

# Recomandare: Folosește | sau # când ai / în pattern
```

---

## PI-S4: & în Replacement

```
┌─────────────────────────────────────────────────────────────────────────┐
│  PEER INSTRUCTION S4: Ce face &?                                       │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  Input: echo "port=8080" | sed 's/[0-9]*/[&]/'                         │
│                                                                         │
│  Output?                                                                │
│                                                                         │
│  ┌───┐                                                                  │
│  │ 1 │ port=[8080]                                                      │
│  ├───┤                                                                  │
│  │ 2 │ [port=8080]                                                      │
│  ├───┤                                                                  │
│  │ 3 │ port=8080 (nemodificat, & e literal)                            │
│  ├───┤                                                                  │
│  │ 4 │ []port=8080                                                      │
│  └───┘                                                                  │
│                                                                         │
│  Dificultate: ⭐⭐⭐ | Misconception: M3.5 (& ca literal)              │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

Răspuns corect: 4

Explicație:

```bash
# & în replacement = ÎNTREGUL MATCH

echo "port=8080" | sed 's/[0-9]*/[&]/'

# [0-9]* = zero sau mai multe cifre
# Prima potrivire este la începutul string-ului: ZERO cifre (string gol!)
# & = "" (string gol)
# Output: []port=8080

# Pentru a potrivi numărul:
echo "port=8080" | sed 's/[0-9][0-9]*/[&]/'   # Minim 1 cifră
# Output: port=[8080]

# Sau cu ERE:
echo "port=8080" | sed -E 's/[0-9]+/[&]/'
# Output: port=[8080]

# LECȚIE: * permite zero repetări! + cere minim una.
```

---

## PI-S5: Adresare cu Pattern

```
┌─────────────────────────────────────────────────────────────────────────┐
│  PEER INSTRUCTION S5: Substituție selectivă                            │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  Fișierul conține:                                                     │
│     # Comment line                                                      │
│     server=localhost                                                    │
│     # Another comment                                                   │
│     port=8080                                                           │
│                                                                         │
│  Comanda: sed '/^#/!s/=/ = /' file.txt                                 │
│                                                                         │
│  Ce face?                                                               │
│                                                                         │
│  ┌───┐                                                                  │
│  │ 1 │ Adaugă spații în jurul = pe liniile cu #                        │
│  ├───┤                                                                  │
│  │ 2 │ Adaugă spații în jurul = pe liniile FĂRĂ #                      │
│  ├───┤                                                                  │
│  │ 3 │ Șterge liniile cu #                                              │
│  ├───┤                                                                  │
│  │ 4 │ Eroare de sintaxă                                               │
│  └───┘                                                                  │
│                                                                         │
│  Dificultate: ⭐⭐ | Concept: Address negation                          │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

Răspuns corect: 2

Explicație:

```bash
# /pattern/! = negare = liniile care NU potrivesc pattern-ul

sed '/^#/!s/=/ = /' file.txt
# /^#/ = linii care încep cu #
# ! = NEGARE - linii care NU încep cu #
# s/=/ = / = înlocuiește = cu " = "

# Output:
# # Comment line (nemodificat - e comentariu)
# server = localhost (modificat)
# # Another comment (nemodificat - e comentariu)
# port = 8080 (modificat)

# Echivalent:
sed '/^[^#]/s/=/ = /' file.txt   # Linii care NU încep cu #
```

---

## PI-S6: sed -i Safety

```
┌─────────────────────────────────────────────────────────────────────────┐
│  PEER INSTRUCTION S6: Backup cu -i                                     │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  Ai fișierul important.conf și vrei să faci o modificare.             │
│                                                                         │
│  Care comandă e CEA MAI SIGURĂ?                                        │
│                                                                         │
│  ┌───┐                                                                  │
│  │ 1 │ sed -i 's/old/new/' important.conf                              │
│  ├───┤                                                                  │
│  │ 2 │ sed 's/old/new/' important.conf > important.conf                │
│  ├───┤                                                                  │
│  │ 3 │ sed -i.bak 's/old/new/' important.conf                          │
│  ├───┤                                                                  │
│  │ 4 │ sed 's/old/new/' important.conf > temp && mv temp important.conf│
│  └───┘                                                                  │
│                                                                         │
│  Dificultate: ⭐⭐⭐ | Misconception: M3.3 (sed -i safe)               │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

Răspuns corect: 3

Explicație:

```bash
# 1. PERICULOS - fără backup
sed -i 's/old/new/' important.conf
# Dacă comanda e greșită, ai pierdut originalul!

# 2. DEZASTRU - redirect în același fișier
sed 's/old/new/' important.conf > important.conf
# Shell golește fișierul ÎNAINTE de a rula sed!
# Rezultat: fișier GOL!

# 3. SIGUR - cu backup automat
sed -i.bak 's/old/new/' important.conf
# Creează important.conf.bak cu originalul

# 4. SIGUR - manual cu temp file
sed 's/old/new/' important.conf > temp && mv temp important.conf
# Funcționează, dar mai complicat

# RECOMANDARE: Mereu folosește -i.bak sau testează fără -i întâi
```

---

# SECȚIUNEA 4: AWK

## PI-A1: $0 vs $1

```
┌─────────────────────────────────────────────────────────────────────────┐
│  PEER INSTRUCTION A1: Ce conține $0?                                   │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  Input: echo "John Smith 30" | awk '{print $0}'                        │
│                                                                         │
│  Output?                                                                │
│                                                                         │
│  ┌───┐                                                                  │
│  │ 1 │ (nimic - $0 e undefined)                                        │
│  ├───┤                                                                  │
│  │ 2 │ John (primul câmp)                                              │
│  ├───┤                                                                  │
│  │ 3 │ John Smith 30 (linia întreagă)                                  │
│  ├───┤                                                                  │
│  │ 4 │ 0 (valoarea numerică)                                           │
│  └───┘                                                                  │
│                                                                         │
│  Dificultate: ⭐⭐⭐ | Misconception: M4.1 ($0 = primul câmp)          │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

Răspuns corect: 3

Explicație:

```bash
# $0 = LINIA ÎNTREAGĂ (record complet)
# $1 = Primul câmp
# $2 = Al doilea câmp
# $NF = Ultimul câmp

echo "John Smith 30" | awk '{print $0}'   # John Smith 30
echo "John Smith 30" | awk '{print $1}'   # John
echo "John Smith 30" | awk '{print $2}'   # Smith
echo "John Smith 30" | awk '{print $3}'   # 30
echo "John Smith 30" | awk '{print $NF}'  # 30 (ultimul)

# Numerotarea începe de la 1, nu de la 0!
```

---

## PI-A2: Print cu/fără virgulă

```
┌─────────────────────────────────────────────────────────────────────────┐
│  PEER INSTRUCTION A2: Spațiu sau nu?                                   │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  Comenzi:                                                               │
│     A) echo "a b" | awk '{print $1 $2}'                                │
│     B) echo "a b" | awk '{print $1, $2}'                               │
│                                                                         │
│  Care afișează "a b" (cu spațiu între)?                                │
│                                                                         │
│  ┌───┐                                                                  │
│  │ 1 │ Doar A                                                           │
│  ├───┤                                                                  │
│  │ 2 │ Doar B                                                           │
│  ├───┤                                                                  │
│  │ 3 │ Ambele                                                           │
│  ├───┤                                                                  │
│  │ 4 │ Niciuna                                                          │
│  └───┘                                                                  │
│                                                                         │
│  Dificultate: ⭐⭐⭐ | Misconception: M4.3 (print concatenare)         │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

Răspuns corect: 2

Explicație:

```bash
# FĂRĂ virgulă = concatenare directă
echo "a b" | awk '{print $1 $2}'
# Output: ab (LIPITE!)

# CU virgulă = separate prin OFS (default: spațiu)
echo "a b" | awk '{print $1, $2}'
# Output: a b (cu spațiu)

# Poți schimba OFS:
echo "a b" | awk 'BEGIN{OFS=":"} {print $1, $2}'
# Output: a:b

# REGULA: Virgula în print = inserează OFS
```

---

## PI-A3: NR vs FNR

```
┌─────────────────────────────────────────────────────────────────────────┐
│  PEER INSTRUCTION A3: Multiple Files                                   │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  file1.txt: line1                                                       │
│  file2.txt: lineA                                                       │
│             lineB                                                       │
│                                                                         │
│  Comanda: awk '{print NR, FNR}' file1.txt file2.txt                    │
│                                                                         │
│  Output?                                                                │
│                                                                         │
│  ┌───┐                                                                  │
│  │ 1 │ 1 1                                                              │
│  │   │ 1 1                                                              │
│  │   │ 2 2                                                              │
│  ├───┤                                                                  │
│  │ 2 │ 1 1                                                              │
│  │   │ 2 1                                                              │
│  │   │ 3 2                                                              │
│  ├───┤                                                                  │
│  │ 3 │ 1 1                                                              │
│  │   │ 2 2                                                              │
│  │   │ 3 3                                                              │
│  ├───┤                                                                  │
│  │ 4 │ Eroare - awk nu acceptă multiple fișiere                        │
│  └───┘                                                                  │
│                                                                         │
│  Dificultate: ⭐⭐⭐⭐ | Misconception: M4.4 (NR = FNR)                │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

Răspuns corect: 2

Explicație:

```bash
# NR = Number of Records (GLOBAL, crește continuu)
# FNR = File Number of Records (se resetează pentru fiecare fișier)

awk '{print NR, FNR}' file1.txt file2.txt
# Output:
# 1 1 (file1.txt, linia 1)
# 2 1 (file2.txt, linia 1 - FNR resetat!)
# 3 2 (file2.txt, linia 2)

# Util pentru a detecta primul fișier:
awk 'NR==FNR { ... }' file1.txt file2.txt
# Condiția NR==FNR e TRUE doar pentru primul fișier
```

---

## PI-A4: Skip Header

```
┌─────────────────────────────────────────────────────────────────────────┐
│  PEER INSTRUCTION A4: Procesare CSV fără header                        │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  employees.csv:                                                         │
│     Name,Salary                                                         │
│     John,5000                                                           │
│     Maria,6000                                                          │
│                                                                         │
│  Vrei suma salariilor (fără header). Care e CORECTĂ?                   │
│                                                                         │
│  ┌───┐                                                                  │
│  │ 1 │ awk -F',' '{sum+=$2} END{print sum}'                            │
│  ├───┤                                                                  │
│  │ 2 │ awk -F',' 'NR>1 {sum+=$2} END{print sum}'                       │
│  ├───┤                                                                  │
│  │ 3 │ awk -F',' 'NR!=1 {sum+=$2} END{print sum}'                      │
│  ├───┤                                                                  │
│  │ 4 │ Opțiunile 2 și 3 sunt corecte                                   │
│  └───┘                                                                  │
│                                                                         │
│  Dificultate: ⭐⭐ | Concept: Skipping header                          │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

Răspuns corect: 4

Explicație:

```bash
# 1. GREȘIT - include header-ul
awk -F',' '{sum+=$2} END{print sum}' employees.csv
# $2 pe linia 1 = "Salary" (text), awk convertește la 0
# Dar adună 0, deci rezultatul e corect... ACCIDENTAL!
# Pe date reale, poate cauza warning sau erori.

# 2. CORECT - NR>1 sare peste prima linie
awk -F',' 'NR>1 {sum+=$2} END{print sum}' employees.csv
# Output: 11000

# 3. CORECT - NR!=1 e echivalent cu NR>1 (pentru prima linie)
awk -F',' 'NR!=1 {sum+=$2} END{print sum}' employees.csv
# Output: 11000

# BONUS: FNR==1 pentru header în fiecare fișier (multiple)
```

---

## PI-A5: Arrays în AWK

```
┌─────────────────────────────────────────────────────────────────────────┐
│  PEER INSTRUCTION A5: Numărare categorii                               │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  data.txt:                                                              │
│     IT                                                                  │
│     HR                                                                  │
│     IT                                                                  │
│     IT                                                                  │
│                                                                         │
│  Comanda: awk '{count[$1]++} END{print count["IT"]}'                   │
│                                                                         │
│  Output?                                                                │
│                                                                         │
│  ┌───┐                                                                  │
│  │ 1 │ 3                                                                │
│  ├───┤                                                                  │
│  │ 2 │ IT IT IT                                                         │
│  ├───┤                                                                  │
│  │ 3 │ 0 (arrays trebuie declarate)                                    │
│  ├───┤                                                                  │
│  │ 4 │ Eroare - syntax invalid                                         │
│  └───┘                                                                  │
│                                                                         │
│  Dificultate: ⭐⭐⭐ | Misconception: M4.7 (declarare variabile)       │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

Răspuns corect: 1

Explicație:

```bash
# În AWK, variabilele NU trebuie declarate
# Se inițializează automat: numere la 0, stringuri la ""

# count[$1]++ :
# - count este un array asociativ (hash)
# - $1 este cheia
# - ++ incrementează valoarea

# La prima apariție a "IT": count["IT"] = 0, apoi devine 1
# La a doua: count["IT"] = 1, apoi devine 2
# La a treia: count["IT"] = 2, apoi devine 3

# END{print count["IT"]} afișează 3

# Pentru a vedea toate categoriile:
awk '{count[$1]++} END{for(k in count) print k, count[k]}' data.txt
# Output:
# IT 3
# HR 1
```

---

## PI-A6: printf Formatting

```
┌─────────────────────────────────────────────────────────────────────────┐
│  PEER INSTRUCTION A6: Formatare output                                 │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  Comanda: awk 'BEGIN{printf "%-10s %5d\n", "Test", 42}'                │
│                                                                         │
│  Output? (. = spațiu)                                                   │
│                                                                         │
│  ┌───┐                                                                  │
│  │ 1 │ Test......42                                                     │
│  ├───┤                                                                  │
│  │ 2 │ Test.........42                                                  │
│  ├───┤                                                                  │
│  │ 3 │ ......Test...42                                                  │
│  ├───┤                                                                  │
│  │ 4 │ Test           42 (14 spații între)                             │
│  └───┘                                                                  │
│                                                                         │
│  Dificultate: ⭐⭐ | Concept: printf alignment                         │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

Răspuns corect: 1

Explicație:

```bash
# printf formatters:
# %-10s = string, 10 caractere, aliniat STÂNGA (din cauza -)
# %5d = integer, 5 caractere, aliniat DREAPTA (default)

# "Test" are 4 caractere, %-10s adaugă 6 spații după
# 42 are 2 caractere, %5d adaugă 3 spații înainte

# Rezultat: "Test " + " 42" = "Test 42"
# (6 spații după Test, 3 înainte de 42)

# Vizualizare:
# T e s t . . . . . . . . 4 2
# |___10 chars_____| |_5_|

# Output real:
awk 'BEGIN{printf "%-10s %5d\n", "Test", 42}'
# Test 42
```

---

## Statistici și Utilizare

### Distribuție pe Dificultate

| Nivel | Număr | Procent |
|-------|-------|---------|
| ⭐ | 1 | 4% |
| ⭐⭐ | 10 | 42% |
| ⭐⭐⭐ | 11 | 46% |
| ⭐⭐⭐⭐ | 2 | 8% |

### Mapping pe Misconcepții

| Misconcepție | Întrebări Țintite |
|--------------|-------------------|
| M1.1 - * în glob vs regex | PI-R1, PI-R2 |
| M1.3 - BRE vs ERE | PI-R4 |
| M1.4 - ^ context | PI-R3 |
| M1.5 - greedy matching | PI-R5 |
| M2.3 - grep -o | PI-G2 |
| M2.4 - recursiv automat | PI-G3 |
| M2.5 - grep -c | PI-G1 |
| M3.1 - sed modifică direct | PI-S1 |
| M3.2 - s/// all | PI-S2 |
| M3.5 - & literal | PI-S4 |
| M4.1 - $0 vs $1 | PI-A1 |
| M4.3 - print concat | PI-A2 |
| M4.4 - NR vs FNR | PI-A3 |

---

*Peer Instruction pentru Seminarul 7-8 de Sisteme de Operare | ASE București - CSIE*
