# S01_TC05 - Introducere în Globbing

> **Sisteme de Operare** | ASE București - CSIE  
> Material de laborator - Seminar 1 (MUTAT din SEM02)

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
- Înțeleagă și folosească pattern-uri glob avansate
- Selecteze eficient multiple fișiere cu wildcards
- Combine diferite tipuri de pattern-uri

---


## 2. Wildcards Fundamentale

### 2.1 Asterisk (`*`)

Potrivește **zero sau mai multe** caractere.

```bash
# Exemple
ls *              # toate fișierele
ls *.txt          # fișiere ce se termină în .txt
ls doc*           # fișiere ce încep cu "doc"
ls *backup*       # fișiere ce conțin "backup"
ls *.tar.gz       # fișiere cu extensie dublă

# Pattern-uri complexe
ls pro*.txt       # începe cu "pro", se termină cu ".txt"
ls *2024*         # conține "2024" oriunde
```

### 2.2 Semnul Întrebării (`?`)

Potrivește **exact un** caracter.

```bash
# Exemple
ls file?.txt      # file1.txt, fileA.txt (NU file10.txt)
ls ???.txt        # exact 3 caractere înainte de .txt
ls data_??.csv    # data_01.csv, data_AB.csv

# Diferența * vs ?
ls file*          # file, file1, file12, fileABC, etc.
ls file?          # doar file + 1 caracter
ls file??         # doar file + 2 caractere
```

### 2.3 Paranteze Pătrate (`[]`)

Potrivește **un caracter** din setul specificat.

```bash
# Set explicit
ls file[123].txt       # file1.txt, file2.txt, file3.txt
ls file[abc].txt       # filea.txt, fileb.txt, filec.txt

# Range de caractere
ls file[0-9].txt       # file0.txt ... file9.txt
ls file[a-z].txt       # filea.txt ... filez.txt
ls file[A-Z].txt       # fileA.txt ... fileZ.txt
ls file[a-zA-Z].txt    # orice literă
ls file[0-9a-f].txt    # cifră sau hexadecimal mic

# Negare cu ! sau ^
ls file[!0-9].txt      # NOT cifră
ls file[^abc].txt      # NOT a, b sau c
ls file[!a-z].txt      # NOT literă mică
```

### 2.4 Clase de Caractere POSIX

```bash
# Sintaxă: [[:clasa:]]
ls file[[:digit:]].txt      # echivalent cu [0-9]
ls file[[:alpha:]].txt      # [a-zA-Z]
ls file[[:alnum:]].txt      # [a-zA-Z0-9]
ls file[[:lower:]].txt      # [a-z]
ls file[[:upper:]].txt      # [A-Z]
ls file[[:space:]].txt      # spații, tab-uri
ls file[[:punct:]].txt      # punctuație
```

---

## 3. Brace Expansion (`{}`)

> ⚠️ Notă: Brace expansion NU este glob! Este un mecanism diferit.

```bash
# Liste explicite
echo {a,b,c}              # a b c
echo file{1,2,3}.txt      # file1.txt file2.txt file3.txt

# Secvențe numerice
echo {1..5}               # 1 2 3 4 5
echo {01..10}             # 01 02 03 04 05 06 07 08 09 10
echo {5..1}               # 5 4 3 2 1 (descrescător)
echo {1..10..2}           # 1 3 5 7 9 (pas de 2)

# Secvențe alfabetice
echo {a..e}               # a b c d e
echo {A..Z}               # tot alfabetul mare

# Combinații
echo file{A,B}{1,2}       # fileA1 fileA2 fileB1 fileB2
mkdir -p proj/{src,doc,test}
touch log.{txt,bak,old}
```

**Diferența glob vs brace expansion:**

| Aspect | Glob (`*`) | Brace (`{}`) |
|--------|-----------|--------------|
| Potrivire | Fișiere existente | Generare stringuri |
| Când | După parsare | Înainte de glob |
| Rezultat | Doar fișiere găsite | Toate combinațiile |

---

## 4. Extended Globbing (extglob)

Pattern-uri avansate disponibile cu opțiunea `extglob`.

```bash
# Activare
shopt -s extglob

# Pattern-uri extinse
?(pattern)      # zero sau o potrivire
*(pattern)      # zero sau mai multe
+(pattern)      # una sau mai multe
@(pattern)      # exact una
!(pattern)      # negare (NOT)

# Exemple
ls !(*.txt)               # tot EXCEPTÂND .txt
ls *.@(jpg|png|gif)       # doar imagini
ls +([0-9]).txt           # fișiere cu doar cifre în nume
ls ?(.)bashrc             # .bashrc sau bashrc

# Combinații complexe
ls !(*.bak|*.tmp|*.log)   # exclude multiple extensii
ls @(data|info)_*.txt     # începe cu "data_" sau "info_"
```

---

## 5. Comportamente Speciale

### 5.1 Fișiere Ascunse (dotfiles)

```bash
# * NU potrivește fișiere care încep cu .
ls *              # nu include .bashrc, .profile etc.
ls .*             # DOAR fișierele ascunse
ls .* *           # toate (ascunse + normale)

# Cu dotglob activat
shopt -s dotglob
ls *              # include și fișierele ascunse
```

### 5.2 Nullglob și Failglob

```bash
# Comportament implicit: pattern rămâne literal dacă nu potrivește
ls *.xyz          # dacă nu există, caută literal "*.xyz"

# nullglob: expandează la nimic dacă nu potrivește
shopt -s nullglob
ls *.xyz          # nu returnează nimic (fără eroare)

# failglob: eroare dacă nu potrivește
shopt -s failglob
ls *.xyz          # eroare: no match
```

### 5.3 Globstar (recursiv)

```bash
# Activare
shopt -s globstar

# ** potrivește recursiv toate subdirectoarele
ls **/*.txt       # toate .txt din orice subdirector
ls **/main.c      # main.c oriunde în ierarhie
cp **/*.log backup/
```

---

## 6. Exerciții Practice

### Exercițiul 1: Pregătire Fișiere Test

```bash
# Creează structură de test
mkdir -p ~/glob_lab
cd ~/glob_lab

# Creează fișiere diverse
touch file{1..5}.txt
touch data_{a..c}.csv
touch report_{01..10}.pdf
touch .hidden_{1..3}
touch image.{jpg,png,gif,bmp}
touch backup_{2023,2024}_{jan,feb,mar}.tar.gz
```

### Exercițiul 2: Pattern-uri de Bază

```bash
# Listează doar fișierele .txt
ls *.txt

# Listează fișierele cu un singur caracter înainte de .txt
ls ?????.txt

# Listează fișierele data_a.csv, data_b.csv, data_c.csv
ls data_[a-c].csv

# Listează rapoartele cu numere impare
ls report_0[13579].pdf
```

### Exercițiul 3: Brace Expansion

```bash
# Creează directoare pentru un proiect
mkdir -p proiect/{src,include,lib,bin,doc}

# Creează fișiere pentru mai multe luni
touch log_{jan,feb,mar,apr}_{2023,2024}.txt

# Secvență de backup-uri
touch backup_{001..100}.bak
```

### Exercițiul 4: Extended Glob

```bash
# Activează extglob
shopt -s extglob

# Listează tot EXCEPTÂND fișierele .txt
ls !(*.txt)

# Listează doar imaginile
ls *.@(jpg|png|gif)

# Listează fișierele cu doar cifre în nume
ls +([0-9]).*
```

---

## 7. Cazuri Practice

### 7.1 Backup Selectiv

```bash
# Copiază toate fișierele sursă
cp *.{c,h} backup/

# Copiază tot exceptând temporare
shopt -s extglob
cp !(*.tmp|*.bak) backup/
```

### 7.2 Ștergere Selectivă

```bash
# Șterge toate fișierele temporare
rm -f *.tmp *.bak *.swp

# Șterge totul EXCEPTÂND .txt
shopt -s extglob
rm !(*.txt)
```

### 7.3 Procesare Batch

```bash
# Redenumește extensii
for f in *.jpeg; do
    mv "$f" "${f%.jpeg}.jpg"
done

# Procesează toate imaginile
for img in *.{jpg,png,gif}; do
    echo "Procesez: $img"
done
```

---

## 8. Întrebări de Verificare

1. **Care este diferența dintre `*` și `?`?**
   > `*` potrivește zero sau mai multe caractere, `?` exact un caracter.

2. **Cum listezi toate fișierele care NU sunt .txt?**
   > Cu extglob: `ls !(*.txt)` sau `ls *.[!t][!x][!t]` (imprecis).

3. **Ce face `echo {1..5..2}`?**
   > Afișează: `1 3 5` (de la 1 la 5, pas 2).

4. **De ce `ls *` nu arată fișierele ascunse?**
   > `*` nu potrivește implicit fișierele ce încep cu `.` (dotfiles).

5. **Cum activezi glob recursiv cu `**`?**
   > `shopt -s globstar`.

---

## Cheat Sheet

```bash
# WILDCARDS
*               # zero sau mai multe caractere
?               # exact un caracter
[abc]           # unul din set
[a-z]           # range
[!abc]          # negare
[[:digit:]]     # clasă POSIX

# BRACE EXPANSION
{a,b,c}         # listă
{1..10}         # secvență
{01..10}        # cu padding
{1..10..2}      # cu pas

# EXTENDED GLOB (shopt -s extglob)
?(pattern)      # zero sau unu
*(pattern)      # zero sau mai multe
+(pattern)      # unu sau mai multe
@(pattern)      # exact unu
!(pattern)      # NOT

# OPȚIUNI SHELL
shopt -s extglob      # extended glob
shopt -s globstar     # ** recursiv
shopt -s dotglob      # include dotfiles
shopt -s nullglob     # expand la nimic
shopt -s failglob     # eroare dacă no match

# COMBINAȚII UTILE
*.{txt,log}           # .txt și .log
*.[ch]                # .c și .h
file[0-9][0-9]        # file00-file99
!(*.bak|*.tmp)        # exclude multiple
**/*.txt              # recursiv
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
