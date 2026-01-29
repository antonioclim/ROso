# S04_TC01 - Expresii Regulate (Regular Expressions)

> **Sisteme de Operare** | ASE București - CSIE  
> Material de laborator - Seminar 4 (Redistribuit)

---

> 🚨 **ÎNAINTE DE A ÎNCEPE TEMA**
>
> 1. Descarcă și configurează pachetul `002HWinit` (vezi GHID_STUDENT_RO.md)
> 2. Deschide un terminal și navighează în `~/HOMEWORKS`
> 3. Pornește înregistrarea cu:
>    ```bash
>    python3 record_homework_tui_RO.py
>    ```
>    sau varianta Bash:
>    ```bash
>    ./record_homework_RO.sh
>    ```
> 4. Completează datele cerute (nume, grupă, nr. temă)
> 5. **ABIA APOI** începe să rezolvi cerințele de mai jos

---

## Obiective

La finalul acestui laborator, studentul va fi capabil să:
- Înțeleagă sintaxa expresiilor regulate
- Folosească regex în grep, sed, awk
- Distingă între BRE și ERE
- Construiască pattern-uri complexe

---


## 2. Metacaractere de Bază

### 2.1 Caractere Speciale

| Simbol | Semnificație | Exemplu | Potrivește |
|--------|--------------|---------|------------|
| `.` | Orice caracter (exceptând newline) | `a.c` | abc, aXc, a1c |
| `^` | Început de linie | `^Start` | "Start" la început |
| `$` | Sfârșit de linie | `end$` | "end" la sfârșit |
| `\` | Escape | `\.` | punct literal |

### 2.2 Exemple de Bază

```bash
# Orice caracter
grep 'a.c' file.txt         # abc, aXc, a9c

# Început de linie
grep '^#' config.txt        # linii care încep cu #

# Sfârșit de linie
grep 'end$' file.txt        # linii care se termină cu "end"

# Linie goală
grep '^$' file.txt          # linii goale

# Escape caractere speciale
grep '192\.168\.1\.1' log   # IP literal (. escapate)
```

---

## 3. Clase de Caractere

### 3.1 Seturi Explicite

```bash
[abc]       # unul din: a, b, sau c
[a-z]       # orice literă mică
[A-Z]       # orice literă mare
[0-9]       # orice cifră
[a-zA-Z]    # orice literă
[a-zA-Z0-9] # alfanumeric
[^abc]      # orice EXCEPTÂND a, b, c
[^0-9]      # orice EXCEPTÂND cifre
```

### 3.2 Clase POSIX

```bash
[[:alpha:]]     # litere [a-zA-Z]
[[:digit:]]     # cifre [0-9]
[[:alnum:]]     # alfanumeric [a-zA-Z0-9]
[[:space:]]     # whitespace (spațiu, tab, newline)
[[:lower:]]     # litere mici [a-z]
[[:upper:]]     # litere mari [A-Z]
[[:punct:]]     # punctuație
[[:blank:]]     # spațiu și tab
[[:print:]]     # caractere printabile
[[:xdigit:]]    # hexadecimal [0-9A-Fa-f]
```

### 3.3 Exemple

```bash
# Doar linii cu cifre
grep '[0-9]' file.txt

# Cuvinte care încep cu majusculă
grep '\b[A-Z][a-z]*\b' file.txt

# Caractere non-alfanumerice
grep '[^[:alnum:]]' file.txt
```

---

## 4. Quantificatori

### 4.1 Quantificatori de Bază

| BRE | ERE | Semnificație |
|-----|-----|--------------|
| `*` | `*` | 0 sau mai multe |
| `\+` | `+` | 1 sau mai multe |
| `\?` | `?` | 0 sau 1 |
| `\{n\}` | `{n}` | exact n |
| `\{n,\}` | `{n,}` | n sau mai multe |
| `\{n,m\}` | `{n,m}` | între n și m |

### 4.2 Exemple

```bash
# Zero sau mai multe
grep 'ab*c' file.txt        # ac, abc, abbc, abbbc...

# Una sau mai multe (ERE)
grep -E 'ab+c' file.txt     # abc, abbc, abbbc... (NU ac)

# Zero sau una (ERE)
grep -E 'colou?r' file.txt  # color, colour

# Exact n
grep -E '[0-9]{4}' file.txt # secvențe de 4 cifre

# Range
grep -E '[0-9]{2,4}' file.txt # 2-4 cifre
```

---

## 5. Grupare și Alternative

### 5.1 Grupare

```bash
# BRE - cu escape
grep '\(abc\)' file.txt

# ERE - fără escape
grep -E '(abc)' file.txt
grep -E '(ab)+' file.txt    # ab, abab, ababab...
```

### 5.2 Alternative (OR)

```bash
# ERE
grep -E 'cat|dog' file.txt          # cat SAU dog
grep -E '(error|warning|fatal)' log # oricare din cele 3
grep -E '^(yes|no)$' file.txt       # linii cu doar "yes" sau "no"
```

### 5.3 Backreferences

```bash
# Referință la grup capturat
# \1 = primul grup, \2 = al doilea, etc.

# Cuvinte duplicate
grep -E '\b(\w+)\s+\1\b' file.txt   # "the the", "is is"

# Tag-uri HTML matching
grep -E '<([a-z]+)>.*</\1>' file.html
```

---

## 6. Anchors și Word Boundaries

### 6.1 Anchors

```bash
^       # început de linie
$       # sfârșit de linie
\A      # început de string (PCRE)
\Z      # sfârșit de string (PCRE)
```

### 6.2 Word Boundaries

```bash
\b      # word boundary (început sau sfârșit de cuvânt)
\B      # non-word boundary
\<      # început de cuvânt (GNU)
\>      # sfârșit de cuvânt (GNU)
```

### 6.3 Exemple

```bash
# Cuvânt exact
grep '\bword\b' file.txt        # "word" dar nu "password"
grep '\<word\>' file.txt        # echivalent GNU

# La începutul cuvântului
grep '\bpre' file.txt           # prefix, prepare...

# La sfârșitul cuvântului
grep 'ing\b' file.txt           # running, jumping...
```

---

## 7. BRE vs ERE - Comparație

| Feature | BRE | ERE |
|---------|-----|-----|
| Quantificator + | `\+` | `+` |
| Quantificator ? | `\?` | `?` |
| Interval {} | `\{n,m\}` | `{n,m}` |
| Grupare () | `\(\)` | `()` |
| Alternativă \| | `\|` | `|` |
| Utilizare | grep, sed | grep -E, awk |

```bash
# Aceeași expresie în BRE vs ERE

# BRE
grep 'ab\+c' file.txt
grep '\(abc\)\+' file.txt

# ERE
grep -E 'ab+c' file.txt
grep -E '(abc)+' file.txt
```

---

## 8. Exemple Practice Complexe

### 8.1 Validare Email (simplificat)

```bash
grep -E '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$' emails.txt
```

### 8.2 Validare IP Address

```bash
grep -E '^([0-9]{1,3}\.){3}[0-9]{1,3}$' ips.txt

# Mai strict (0-255)
grep -E '^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$' ips.txt
```

### 8.3 Numere de Telefon

```bash
# Format: 07XX-XXX-XXX sau 07XXXXXXXX
grep -E '07[0-9]{2}(-?[0-9]{3}){2}' phones.txt
```

### 8.4 Date

```bash
# Format: DD/MM/YYYY sau DD-MM-YYYY
grep -E '[0-3][0-9][/-][0-1][0-9][/-][0-9]{4}' dates.txt
```

### 8.5 URL-uri

```bash
grep -E 'https?://[a-zA-Z0-9.-]+(/[a-zA-Z0-9./_-]*)?' urls.txt
```

---

## 9. Exerciții Practice

### Exercițiul 1: Pattern-uri de Bază
```bash
# Găsește liniile care încep cu vocală
grep -E '^[aeiouAEIOU]' file.txt

# Găsește cuvinte de exact 5 litere
grep -E '\b[a-zA-Z]{5}\b' file.txt

# Găsește liniile cu cel puțin 3 cifre consecutive
grep -E '[0-9]{3,}' file.txt
```

### Exercițiul 2: Extragere Date
```bash
# Extrage toate email-urile
grep -oE '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' document.txt

# Extrage toate IP-urile
grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' log.txt
```

---

## Cheat Sheet

```bash
# METACARACTERE
.           orice caracter
^           început linie
$           sfârșit linie
\           escape

# CLASE
[abc]       unul din set
[^abc]      niciunul din set
[a-z]       range
[[:alpha:]] literă POSIX

# QUANTIFICATORI (ERE)
*           0 sau mai multe
+           1 sau mai multe
?           0 sau 1
{n}         exact n
{n,m}       între n și m

# GRUPARE (ERE)
(abc)       grup
|           sau
\1          backreference

# ANCHORS
^           început linie
$           sfârșit linie
\b          word boundary
\<  \>      word boundaries GNU

# UTILIZARE
grep 'pattern' file           # BRE
grep -E 'pattern' file        # ERE
grep -P 'pattern' file        # PCRE
grep -o 'pattern' file        # doar match
grep -i 'pattern' file        # case-insensitive
```

---

## 📤 Finalizare și Trimitere

După ce ai terminat toate cerințele:

1. **Oprește înregistrarea** tastând:
   ```bash
   STOP_tema
   ```
   sau apasă `Ctrl+D`

2. **Așteaptă** - scriptul va:
   - Genera semnătura criptografică
   - Încărca automat fișierul pe server

3. **Verifică mesajul final**:
   - ✅ `ÎNCĂRCARE REUȘITĂ!` - tema a fost trimisă
   - ❌ Dacă upload-ul eșuează, fișierul `.cast` este salvat local - trimite-l manual mai târziu cu comanda afișată

> ⚠️ **NU modifica fișierul `.cast`** după generare - semnătura devine invalidă!

---

*By Revolvix for OPERATING SYSTEMS class | restricted licence 2017-2030*
