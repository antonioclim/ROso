# S01_TC04 - File Globbing și Gestiunea Fișierelor

> **Sisteme de Operare** | ASE București - CSIE  
> Material de laborator - Seminar 1 (Redistribuit)

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
- Folosească pattern-uri glob pentru selectarea fișierelor
- Gestioneze eficient fișiere și directoare
- Înțeleagă și folosească wildcards în comenzi

---


## 2. Wildcards de Bază

### 2.1 Asterisk `*` - Zero sau Mai Multe Caractere

```bash
# Potrivește orice șir de caractere (inclusiv șir gol)

ls *.txt           # Toate fișierele .txt
ls doc*            # Toate fișierele care încep cu "doc"
ls *backup*        # Toate fișierele care conțin "backup"
ls *.tar.gz        # Toate arhivele .tar.gz

# Exemple practice
cp *.jpg ~/Pictures/
rm *.tmp
mv report* ~/Documents/
```

### 2.2 Semnul Întrebării `?` - Exact Un Caracter

```bash
# Potrivește exact un singur caracter (orice caracter)

ls file?.txt       # file1.txt, fileA.txt, dar NU file10.txt
ls ???.txt         # Fișiere cu exact 3 caractere înainte de .txt
ls data_??.csv     # data_01.csv, data_AB.csv etc.

# Combinații
ls file?.*         # file1.txt, fileA.doc etc.
```

### 2.3 Paranteze Pătrate `[]` - Set de Caractere

```bash
# Potrivește UN caracter din setul specificat

ls file[123].txt   # file1.txt, file2.txt, file3.txt
ls file[abc].txt   # filea.txt, fileb.txt, filec.txt

# Range de caractere
ls file[0-9].txt   # file0.txt până la file9.txt
ls file[a-z].txt   # filea.txt până la filez.txt
ls file[A-Z].txt   # fileA.txt până la fileZ.txt
ls file[a-zA-Z].txt # orice literă

# Negare cu ^ sau !
ls file[!0-9].txt  # fișiere care NU au cifră
ls file[^abc].txt  # fișiere care NU au a, b sau c
```

### 2.4 Acolade `{}` - Liste Explicite (Brace Expansion)

```bash
# NU este glob tehnic, ci brace expansion (diferit!)

echo {a,b,c}           # a b c
echo file{1,2,3}.txt   # file1.txt file2.txt file3.txt

# Secvențe
echo {1..5}            # 1 2 3 4 5
echo {a..e}            # a b c d e
echo {01..10}          # 01 02 03 ... 10 (cu zero-padding)
echo {1..10..2}        # 1 3 5 7 9 (pas de 2)

# Combinații
mkdir dir{1,2,3}       # Creează dir1, dir2, dir3
touch file{A..C}.txt   # Creează fileA.txt, fileB.txt, fileC.txt
```

---

## 3. Pattern-uri Extinse (extglob)

Pentru pattern-uri mai complexe, activează `extglob`:

```bash
# Activare
shopt -s extglob

# Pattern-uri extinse
# ?(pattern) - zero sau o potrivire
# *(pattern) - zero sau mai multe
# +(pattern) - una sau mai multe
# @(pattern) - exact una
# !(pattern) - negare (tot ce NU potrivește)

ls !(*.txt)           # Toate fișierele EXCEPTÂND .txt
ls *.@(jpg|png|gif)   # Doar imagini
ls +([0-9]).txt       # Fișiere cu doar cifre în nume
```

---

## 4. Gestiunea Fișierelor

### 4.1 Creare Fișiere și Directoare

```bash
# Creează fișier gol
touch fisier.txt
touch fisier1.txt fisier2.txt fisier3.txt

# Creează cu conținut
echo "text" > fisier.txt           # suprascrie
echo "text adăugat" >> fisier.txt  # adaugă

# Creează director
mkdir director
mkdir -p cale/adanca/director      # creează ierarhia completă
mkdir dir{1..5}                    # dir1, dir2, dir3, dir4, dir5

# Creează structură completă
mkdir -p proiect/{src,docs,tests}
```

### 4.2 Copiere

```bash
# Copiere fișier
cp sursa.txt destinatie.txt
cp sursa.txt /alta/cale/
cp sursa.txt /alta/cale/nou_nume.txt

# Copiere directoare (recursiv)
cp -r sursa_dir/ destinatie_dir/

# Opțiuni utile
cp -i sursa dest      # interactiv (confirmă suprascrierea)
cp -v sursa dest      # verbose (afișează ce face)
cp -p sursa dest      # păstrează atribute (permisiuni, timestamp)
cp -a sursa dest      # arhivă (păstrează tot: -dR --preserve=all)

# Copiere multiplă
cp *.txt backup/
cp file{1,2,3}.txt /destinatie/
```

### 4.3 Mutare și Redenumire

```bash
# Redenumire
mv vechi.txt nou.txt

# Mutare
mv fisier.txt /alta/cale/
mv fisier.txt /alta/cale/alt_nume.txt

# Mutare multiplă
mv *.txt documents/
mv file{1..10}.txt archive/

# Opțiuni
mv -i sursa dest    # interactiv
mv -v sursa dest    # verbose
mv -n sursa dest    # nu suprascrie (no-clobber)
```

### 4.4 Ștergere

```bash
# Ștergere fișier
rm fisier.txt
rm -f fisier.txt     # forțat (fără eroare dacă nu există)

# Ștergere director
rmdir director_gol   # doar dacă e gol
rm -r director       # recursiv (cu conținut)
rm -rf director      # forțat + recursiv (PERICULOS!)

# Opțiuni de siguranță
rm -i fisier.txt     # confirmă înainte de ștergere
rm -v fisier.txt     # verbose

# Capcană: rm -rf nu are undo!
# Recomandare: alias rm='rm -i'
```

### 4.5 Vizualizare Conținut

```bash
# Afișare completă
cat fisier.txt
cat -n fisier.txt     # cu numere de linie

# Primele/ultimele linii
head fisier.txt       # primele 10 linii (implicit)
head -n 5 fisier.txt  # primele 5 linii
tail fisier.txt       # ultimele 10 linii
tail -n 20 fisier.txt # ultimele 20 linii
tail -f log.txt       # follow (monitorizare în timp real)

# Paginat
less fisier.txt       # navigare cu taste
more fisier.txt       # mai simplu (doar înainte)

# Navigare în less:
# Space/Page Down - pagină în jos
# b/Page Up - pagină în sus
# g - început fișier
# G - sfârșit fișier
# /text - caută
# n - următoarea potrivire
# q - ieșire
```

---

## 5. Informații despre Fișiere

### 5.1 Comanda `ls` Detaliată

```bash
ls -l    # format lung

# Interpretare output:
# -rw-r--r-- 1 user group 4096 Jan 10 12:00 fisier.txt
# Nume
# Data modificare
# Dimensiune (bytes)
# Grupul
# Proprietarul
# Număr de linkuri
# Permisiuni others (r--)
# Permisiuni group (r--)
# Permisiuni owner (rw-)
# Tip: - fișier, d director, l link

# Opțiuni utile
ls -la       # include fișierele ascunse
ls -lh       # dimensiuni human-readable (KB, MB, GB)
ls -lt       # sortare după dată (cele mai noi primele)
ls -lS       # sortare după dimensiune
ls -lR       # recursiv
ls -ld dir/  # informații despre director, nu conținut
```

### 5.2 Comenzi pentru Informații

```bash
# Tip fișier
file document.pdf     # PDF document...
file script.sh        # Bourne-Again shell script...
file image.jpg        # JPEG image data...

# Dimensiune
du -h fisier.txt      # dimensiune fișier
du -sh director/      # dimensiune totală director
du -ah director/      # toate fișierele din director

# Spațiu disk
df -h                 # spațiu pe toate partițiile
df -h /home           # spațiu pe partița specificată

# Statistici
stat fisier.txt       # informații complete
wc fisier.txt         # linii, cuvinte, caractere
wc -l fisier.txt      # doar linii
wc -w fisier.txt      # doar cuvinte
wc -c fisier.txt      # doar bytes
```

---

## 6. Căutare Fișiere

### 6.1 Comanda `find`

```bash
# Sintaxă: find [cale] [expresii]

# Căutare după nume
find . -name "*.txt"              # în directorul curent
find /home -name "*.log"          # în /home
find . -iname "*.TXT"             # case-insensitive

# Căutare după tip
find . -type f                    # doar fișiere
find . -type d                    # doar directoare
find . -type l                    # doar linkuri simbolice

# Căutare după dimensiune
find . -size +10M                 # mai mari de 10MB
find . -size -1k                  # mai mici de 1KB
find . -size 100c                 # exact 100 bytes

# Căutare după timp
find . -mtime -7                  # modificate în ultimele 7 zile
find . -mtime +30                 # modificate acum mai mult de 30 zile
find . -mmin -60                  # modificate în ultima oră

# Combinații
find . -name "*.log" -size +1M
find . -type f -name "*.tmp" -mtime +7

# Execuție acțiuni
find . -name "*.tmp" -delete                  # șterge
find . -name "*.txt" -exec cat {} \;          # execută comandă
find . -name "*.sh" -exec chmod +x {} \;      # face executabil
```

### 6.2 Comanda `locate`

```bash
# Căutare rapidă în baza de date (trebuie actualizată)
locate fisier.txt
locate "*.pdf"

# Actualizare baza de date
sudo updatedb

# Opțiuni
locate -i pattern     # case-insensitive
locate -n 10 pattern  # doar primele 10 rezultate
```

### 6.3 Comanda `which` și `whereis`

```bash
# Găsește executabile în PATH
which python
which ls

# Găsește binare, surse, manuale
whereis python
whereis ls
```

---

## 7. Exerciții Practice

### Exercițiul 1: Wildcards de Bază

```bash
# Pregătire
mkdir ~/glob_test && cd ~/glob_test
touch file{1..5}.txt file{A..C}.log data_{01..10}.csv

# Exerciții
ls *.txt              # toate .txt
ls file?.txt          # file1.txt - file5.txt (un caracter)
ls file[1-3].txt      # file1.txt, file2.txt, file3.txt
ls data_0[1-5].csv    # data_01.csv - data_05.csv
ls *.{txt,log}        # toate .txt și .log
```

### Exercițiul 2: Gestiune Fișiere

```bash
# Creare structură proiect
mkdir -p proiect/{src,docs,tests,build}
touch proiect/src/main.c
touch proiect/docs/README.md
touch proiect/tests/test_{1..3}.c

# Copiere și mutare
cp proiect/src/main.c proiect/build/
cp -r proiect/ proiect_backup/
mv proiect/docs/README.md proiect/

# Verificare
ls -R proiect/
```

### Exercițiul 3: Căutare

```bash
# Găsește toate fișierele .txt din home
find ~ -name "*.txt" -type f

# Găsește fișierele mari (>100MB)
find /var -size +100M 2>/dev/null

# Găsește fișierele modificate azi
find . -mtime 0 -type f
```

### Exercițiul 4: Informații

```bash
# Creează fișier de test
echo "Linia 1" > test.txt
echo "Linia 2" >> test.txt
echo "Linia 3" >> test.txt

# Analizează
wc test.txt           # linii, cuvinte, caractere
stat test.txt         # informații complete
file test.txt         # tip fișier
ls -lh test.txt       # dimensiune human-readable
```

---

## 8. Întrebări de Verificare

1. **Care este diferența între `*` și `?`?**
   > `*` potrivește zero sau mai multe caractere, `?` potrivește exact un caracter.

2. **Cum listezi doar fișierele .txt și .log?**
   > `ls *.{txt,log}` sau `ls *.txt *.log`

3. **Cum găsești fișierele mai mari de 10MB?**
   > `find . -size +10M`

4. **Ce face `rm -rf`?**
   > Șterge recursiv și forțat (fără confirmare). FOARTE periculos!

5. **Cum copiezi un director cu tot conținutul?**
   > `cp -r sursa/ destinatie/`

---

## Cheat Sheet

```bash
# WILDCARDS
*           # zero sau mai multe caractere
?           # exact un caracter
[abc]       # un caracter din set
[a-z]       # un caracter din range
[!abc]      # un caracter care NU e în set
{a,b,c}     # expansiune explicită
{1..10}     # secvență numerică

# CREARE
touch file              # fișier gol
mkdir dir               # director
mkdir -p a/b/c          # ierarhie

# COPIERE/MUTARE
cp src dst              # copiere fișier
cp -r src/ dst/         # copiere director
mv old new              # mutare/redenumire

# ȘTERGERE
rm file                 # șterge fișier
rm -r dir               # șterge director
rmdir dir               # șterge director gol

# VIZUALIZARE
cat file                # tot conținutul
head -n N file          # primele N linii
tail -n N file          # ultimele N linii
less file               # paginat

# INFORMAȚII
ls -la                  # listare detaliată
file nume               # tip fișier
stat nume               # statistici
wc file                 # linii/cuvinte/chars
du -sh dir/             # dimensiune director

# CĂUTARE
find . -name "*.txt"    # după nume
find . -type f          # doar fișiere
find . -size +10M       # după dimensiune
locate pattern          # căutare rapidă
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
