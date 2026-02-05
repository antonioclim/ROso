# S04_TC03 - SED - Stream Editor

> **Observație din laborator:** când lucrezi cu `sed`/`awk`, cele mai multe „bug-uri” sunt, de fapt, citare (`quotes`) și escapare. Testează pe un fișier mic, apoi scalează. Și da, aproape sigur o să uiți un backslash la prima încercare 🙂
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
- Editeze stream-uri de text cu sed
- Folosească substituția și ștergerea
- Aplice comenzi pe linii specifice
- Automatizeze modificări de text

---


## 2. Comanda de Substituție (s)

### 2.1 Sintaxă

```bash
s/pattern/replacement/flags

# Flags
# g - global (toate aparițiile pe linie)
# i - case-insensitive
# p - print linia modificată
# w file - scrie în fișier
# N - înlocuiește a N-a apariție
```

### 2.2 Exemple de Bază

```bash
# Prima apariție pe fiecare linie
sed 's/old/new/' file.txt

# Toate aparițiile (global)
sed 's/old/new/g' file.txt

# Case-insensitive
sed 's/old/new/gi' file.txt

# A doua apariție
sed 's/old/new/2' file.txt

# De la a doua apariție încolo
sed 's/old/new/2g' file.txt
```

### 2.3 Delimitatori Alternativi

```bash
# Când pattern-ul conține /
sed 's|/usr/local|/opt|g' paths.txt
sed 's#http://#https://#g' urls.txt
sed 's@old@new@g' file.txt
```

### 2.4 Backreferences

```bash
# \1, \2... referă grupurile capturate cu \( \)

# Swap cuvinte
sed 's/\([a-z]*\) \([a-z]*\)/\2 \1/' file.txt

# Adaugă prefix/sufix
sed 's/\(.*\)/[\1]/' file.txt           # [linie]
sed 's/^/PREFIX: /' file.txt            # PREFIX: linie
sed 's/$/ :SUFFIX/' file.txt            # linie :SUFFIX

# & = întregul match
sed 's/[0-9]*/(&)/' file.txt            # pune numerele în paranteze
```

---

## 3. Adresare (Selectare Linii)

### 3.1 Tipuri de Adrese

```bash
# Număr de linie
sed '5s/old/new/' file.txt              # doar linia 5
sed '1,10s/old/new/' file.txt           # liniile 1-10
sed '$s/old/new/' file.txt              # ultima linie

# Pattern
sed '/error/s/old/new/' file.txt        # linii cu "error"
sed '/^#/d' file.txt                    # șterge comentarii

# Range
sed '/start/,/end/s/old/new/' file.txt  # de la start la end
sed '1,/^$/d' file.txt                  # de la 1 până la prima linie goală

# Step
sed '1~2s/old/new/' file.txt            # linii impare (1,3,5...)
sed '0~2s/old/new/' file.txt            # linii pare (2,4,6...)

# Negare
sed '/pattern/!s/old/new/' file.txt     # linii FĂRĂ pattern
```

---

## 4. Alte Comenzi

### 4.1 Ștergere (d)

```bash
sed '5d' file.txt                       # șterge linia 5
sed '1,10d' file.txt                    # liniile 1-10
sed '/pattern/d' file.txt               # linii cu pattern
sed '/^$/d' file.txt                    # linii goale
sed '/^#/d' file.txt                    # comentarii
sed '1d;$d' file.txt                    # prima și ultima linie
```

### 4.2 Printare (p)

```bash
sed -n '5p' file.txt                    # doar linia 5
sed -n '1,10p' file.txt                 # liniile 1-10
sed -n '/pattern/p' file.txt            # linii cu pattern
sed -n '1p;$p' file.txt                 # prima și ultima
```

### 4.3 Inserare și Adăugare

```bash
# i = insert (înainte)
sed '3i\Text nou' file.txt              # inserează înainte de linia 3
sed '/pattern/i\Text' file.txt          # înainte de linii cu pattern

# a = append (după)
sed '3a\Text nou' file.txt              # adaugă după linia 3
sed '$a\Ultima linie' file.txt          # adaugă la final

# c = change (înlocuiește linia)
sed '3c\Linie nouă' file.txt            # înlocuiește linia 3
```

### 4.4 modificare (y)

```bash
# y/source/dest/ - transliterate (caracter cu caracter)
sed 'y/abc/ABC/' file.txt               # a→A, b→B, c→C
sed 'y/aeiou/12345/' file.txt           # vocale → cifre
```

---

## 5. Multiple Comenzi

```bash
# Cu -e
sed -e 's/a/A/g' -e 's/b/B/g' file.txt

# Cu ; (separator)
sed 's/a/A/g; s/b/B/g' file.txt

# Cu newline (în script sau quotes)
sed '
s/a/A/g
s/b/B/g
/pattern/d
' file.txt

# Din fișier
sed -f commands.sed file.txt
```

---

## 6. Opțiuni Importante

```bash
-n      # Suprimă output implicit (folosește cu p)
-i      # Editare in-place (modifică fișierul)
-i.bak  # In-place cu backup
-e      # Multiple expresii
-f      # Citește comenzi din fișier
-r/-E   # Extended regex (ERE)
```

---

## 7. Exemple Practice

### 7.1 Procesare Configurații

```bash
# Șterge comentarii și linii goale
sed '/^#/d; /^$/d' config.txt

# Schimbă valoarea unei setări
sed 's/^PORT=.*/PORT=8080/' config.txt

# Comentează o linie
sed '/DEBUG/s/^/#/' config.txt

# Decomentează
sed 's/^#\(DEBUG.*\)/\1/' config.txt
```

### 7.2 Curățare Text

```bash
# Șterge spații de la început
sed 's/^[ \t]*//' file.txt

# Șterge spații de la sfârșit
sed 's/[ \t]*$//' file.txt

# Șterge linii goale
sed '/^$/d' file.txt

# Comprimă linii goale multiple
sed '/^$/N;/^\n$/d' file.txt

# Elimină whitespace în exces
sed 's/  */ /g' file.txt
```

### 7.3 modificări

```bash
# DOS to Unix (remove CR)
sed 's/\r$//' file.txt

# Unix to DOS (add CR)
sed 's/$\r/' file.txt

# Lowercase to Uppercase (prima literă)
sed 's/^\(.\)/\U\1/' file.txt
```

---

## Cheat Sheet

```bash
# SUBSTITUȚIE
s/old/new/          prima apariție
s/old/new/g         toate
s/old/new/gi        case-insensitive
s|old|new|          delimitator alternativ

# ADRESARE
5                   linia 5
1,10                liniile 1-10
$                   ultima linie
/pattern/           linii cu pattern
/start/,/end/       range
!                   negare

# COMENZI
d                   șterge
p                   printează
i\text              inserează înainte
a\text              adaugă după
c\text              înlocuiește linia
y/abc/ABC/          transliterate

# OPȚIUNI
-n                  suprimă output
-i                  in-place
-i.bak              cu backup
-e                  multiple comenzi
-r/-E               extended regex

# BACKREFERENCES
\( \)               grupare
\1, \2...           referință
&                   întregul match
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
