# S01_TC06 - Comenzi Fundamentale pentru Fișiere și Directoare

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
- Folosească comenzile fundamentale pentru navigare și gestionare fișiere
- Obțină ajutor și documentație pentru comenzi
- Înțeleagă ierarhia sistemului de fișiere Linux

---


## 2. Comenzi de Navigare

### 2.1 pwd - Print Working Directory

```bash
# Afișează calea completă a directorului curent
pwd
# Output: /home/student/documents

# Opțiuni
pwd -L    # calea logică (cu symlinks)
pwd -P    # calea fizică (fără symlinks)
```

### 2.2 cd - Change Directory

```bash
# Navigare de bază
cd /home/student      # cale absolută
cd documents          # cale relativă
cd ..                 # director părinte
cd ../..              # două niveluri în sus
cd ~                  # home directory (echivalent cu $HOME)
cd                    # tot home directory
cd -                  # directorul anterior (toggle)

# Exemple practice
cd ~/Downloads        # în Downloads
cd /var/log           # în log-uri sistem
cd "Director cu spatii"  # director cu spații în nume
```

### 2.3 ls - List

```bash
# Utilizare de bază
ls                    # listează directorul curent
ls /etc               # listează /etc
ls -l                 # format lung (detalii)
ls -a                 # include fișierele ascunse (.)
ls -la                # combinație comună

# Opțiuni utile
ls -lh                # dimensiuni human-readable
ls -lt                # sortare după dată (recent primul)
ls -lS                # sortare după dimensiune
ls -lR                # recursiv
ls -ld directory/     # info despre director (nu conținut)
ls -1                 # un fișier pe linie
ls --color=auto       # cu culori

# Interpretare output ls -l
# drwxr-xr-x 2 user group 4096 Jan 10 12:00 dirname
# Nume
# Data modificare
# Dimensiune
# Grup
# Proprietar
# Număr linkuri
# Permisiuni others
# Permisiuni group
# Permisiuni owner
# Tip (d=dir, -=file, l=link)
```

---

## 3. Comenzi pentru Fișiere

### 3.1 cat - Concatenate

```bash
# Afișare conținut
cat fisier.txt
cat fisier1.txt fisier2.txt    # concatenează mai multe

# Opțiuni
cat -n fisier.txt              # cu numere de linie
cat -b fisier.txt              # numere doar pt linii non-empty
cat -A fisier.txt              # afișează caractere speciale
cat -s fisier.txt              # comprimă linii goale multiple

# Creare fișier (Ctrl+D pentru terminare)
cat > nou.txt
text aici
^D

# Append la fișier
cat >> existent.txt
text adăugat
^D
```

### 3.2 head și tail

```bash
# head - primele linii
head fisier.txt               # primele 10 linii (implicit)
head -n 5 fisier.txt          # primele 5 linii
head -c 100 fisier.txt        # primii 100 bytes

# tail - ultimele linii
tail fisier.txt               # ultimele 10 linii
tail -n 20 fisier.txt         # ultimele 20 linii
tail -f logfile.log           # follow (monitorizare live)
tail -F logfile.log           # follow + retry dacă rotește

# Combinații
head -n 20 fisier.txt | tail -n 5   # liniile 16-20
```

### 3.3 less și more

```bash
# less - vizualizare paginată (preferată)
less fisier.txt

# Navigare în less:
# Space/PgDown - pagină în jos
# b/PgUp - pagină în sus
# g - la început
# G - la sfârșit
# /pattern - caută înainte
# ?pattern - caută înapoi
# n - următoarea potrivire
# N - potrivirea anterioară
# q - ieșire
# h - ajutor

# Opțiuni utile
less -N fisier.txt            # cu numere de linie
less -S fisier.txt            # nu wrap linii lungi
less +G fisier.txt            # începe de la sfârșit
less +/pattern fisier.txt     # începe de la pattern

# more - mai simplu (doar înainte)
more fisier.txt
```

---

## 4. Comenzi pentru Directoare

### 4.1 mkdir - Make Directory

```bash
# Creare director
mkdir nume_director
mkdir dir1 dir2 dir3          # mai multe simultan

# Creare ierarhie
mkdir -p cale/adanca/director
mkdir -p proiect/{src,docs,tests,build}

# Cu permisiuni specifice
mkdir -m 700 director_privat

# Verbose
mkdir -v director             # afișează ce creează
```

### 4.2 rmdir - Remove Directory

```bash
# Șterge director GOL
rmdir director_gol
rmdir -p a/b/c                # șterge ierarhia (doar dacă goală)

# Pentru directoare cu conținut, folosește rm -r
```

### 4.3 Copiere Directoare

```bash
# cp cu opțiunea -r (recursiv)
cp -r sursa/ destinatie/

# Opțiuni importante
cp -a sursa/ dest/            # arhivă (păstrează tot)
cp -v sursa/ dest/            # verbose
cp -i sursa/ dest/            # interactiv
```

---

## 5. Obținerea Ajutorului

### 5.1 man - Manual Pages

```bash
# Sintaxă
man [secțiune] comandă

# Exemple
man ls
man 5 passwd                  # secțiunea 5 (fișiere config)
man -k keyword                # caută în descrieri
man -f comandă                # echivalent cu whatis

# Secțiuni manual
# 1 - Comenzi utilizator
# 2 - System calls
# 3 - Funcții bibliotecă
# 4 - Fișiere speciale
# 5 - Formate fișiere config
# 6 - Jocuri
# 7 - Diverse
# 8 - Comenzi administrator
```

### 5.2 help și --help

```bash
# Pentru comenzi built-in
help cd
help echo

# Pentru comenzi externe
ls --help
cp --help

# Diferența: type arată dacă e built-in sau extern
type cd                       # cd is a shell builtin
type ls                       # ls is /usr/bin/ls
```

### 5.3 info și apropos

```bash
# info - documentație detaliată (format GNU)
info coreutils
info ls

# apropos - caută în descrierile manualelor
apropos "copy files"
apropos network
# echivalent cu: man -k "pattern"

# whatis - descriere scurtă
whatis ls
whatis cat cp mv
```

---

## 6. Comenzi Informative

### 6.1 file - Tip Fișier

```bash
file document.pdf             # PDF document
file script.sh                # Bourne-Again shell script
file image.jpg                # JPEG image data
file /bin/ls                  # ELF 64-bit executable
file director/                # directory
```

### 6.2 stat - Statistici Fișier

```bash
stat fisier.txt

# Output include:
# - Dimensiune
# - Blocuri alocate
# - Device
# - Inode
# - Linkuri
# - Permisiuni (octal și simbolic)
# - UID/GID
# - Timestamps: Access, Modify, Change, Birth
```

### 6.3 du - Disk Usage

```bash
du fisier.txt                 # dimensiune fișier
du -h fisier.txt              # human-readable
du -s director/               # doar total (summary)
du -sh director/              # total human-readable
du -ah director/              # toate fișierele
du -sh */ | sort -h           # directoare sortate după dimensiune
```

### 6.4 df - Disk Free

```bash
df                            # spațiu pe toate partițiile
df -h                         # human-readable
df -h /home                   # doar pentru /home
df -i                         # inodes (nu bytes)
df -T                         # include tipul filesystem
```

---

## 7. Alte Comenzi Utile

### 7.1 touch

```bash
# Creează fișier gol
touch fisier.txt

# Actualizează timestamp
touch -a fisier.txt           # doar access time
touch -m fisier.txt           # doar modification time
touch -t 202401151200 f.txt   # setează timestamp specific
```

### 7.2 echo

```bash
echo "text simplu"
echo -n "fără newline la sfârșit"
echo -e "cu\ttab\și\nnewline"
echo $VARIABILA
echo "Salut $USER"
echo 'Literal $USER'          # nu expandează
```

### 7.3 wc - Word Count

```bash
wc fisier.txt                 # linii cuvinte bytes
wc -l fisier.txt              # doar linii
wc -w fisier.txt              # doar cuvinte
wc -c fisier.txt              # doar bytes
wc -m fisier.txt              # doar caractere
wc -L fisier.txt              # lungimea liniei celei mai lungi

# Pentru mai multe fișiere
wc -l *.txt                   # linii în fiecare + total
```

---

## 8. Exerciții Practice

### Exercițiul 1: Navigare Sistem

```bash
# 1. Explorează ierarhia
cd /
ls -la
cd etc
pwd

# 2. Explorează home
cd ~
ls -la
cd ..
pwd
```

### Exercițiul 2: Informații Fișiere

```bash
# 1. Creează fișiere test
echo "Linia 1" > test.txt
echo "Linia 2" >> test.txt
echo "Linia 3" >> test.txt

# 2. Analizează
cat test.txt
wc test.txt
stat test.txt
file test.txt
```

### Exercițiul 3: Documentație

```bash
# 1. Învață despre ls
man ls
# Găsește opțiunea pentru sortare după dimensiune

# 2. Caută comenzi pentru "network"
apropos network

# 3. Verifică tipul comenzii
type cd
type ls
type echo
```

### Exercițiul 4: Creare Structură Proiect

```bash
# Creează structură completă
mkdir -p ~/proiect/{src,include,docs,tests,build}
touch ~/proiect/src/main.c
touch ~/proiect/include/header.h
touch ~/proiect/docs/README.md
touch ~/proiect/Makefile

# Verifică
ls -R ~/proiect
du -sh ~/proiect
```

---

## 9. Întrebări de Verificare

1. **Ce conține directorul `/etc`?**
   > Fișierele de configurare ale sistemului.

2. **Care este diferența între `cat` și `less`?**
   > `cat` afișează tot conținutul direct, `less` oferă navigare paginată.

3. **Cum afli tipul unui fișier?**
   > Cu comanda `file nume_fisier`.

4. **Ce face `man -k pattern`?**
   > Caută pattern în descrierile manualelor (echivalent cu `apropos`).

5. **Cum creezi o ierarhie de directoare într-o singură comandă?**
   > `mkdir -p cale/adanca/director`

---

## Cheat Sheet

```bash
# NAVIGARE
pwd                 # director curent
cd DIR              # schimbă director
cd ~                # home
cd -                # anterior
ls -la              # listare detaliată

# VIZUALIZARE
cat file            # conținut complet
head -n N file      # primele N linii
tail -n N file      # ultimele N linii
tail -f file        # monitorizare live
less file           # paginat

# INFORMAȚII
file name           # tip fișier
stat name           # statistici complete
du -sh dir/         # dimensiune director
df -h               # spațiu disk
wc file             # linii/cuvinte/chars

# AJUTOR
man CMD             # manual
CMD --help          # ajutor rapid
type CMD            # tip comandă
apropos pattern     # caută în manuale
whatis CMD          # descriere scurtă

# DIRECTOARE
mkdir dir           # creează
mkdir -p a/b/c      # creează ierarhie
rmdir dir           # șterge (gol)

# DIVERSE
touch file          # creează/actualizează
echo "text"         # afișează text
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
