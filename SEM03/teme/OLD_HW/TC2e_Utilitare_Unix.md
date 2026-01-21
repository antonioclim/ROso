# TC2e - Utilitare Unix de Bază

> **Sisteme de Operare** | ASE București - CSIE  
> Material de laborator - Seminar 3

---

## Obiective

La finalul acestui laborator, studentul va fi capabil să:
- Folosească comanda `find` pentru căutări complexe de fișiere
- Construiască comenzi eficiente cu `xargs`
- Folosească `locate` pentru căutări rapide în baza de date
- Combine utilitarele pentru sarcini complexe de administrare

---

## 1. Comanda find

### 1.1 Sintaxă și Concepte de Bază

```bash
find [cale_start] [expresii] [acțiuni]
```

`find` parcurge recursiv ierarhia de directoare și aplică teste/acțiuni pe fiecare fișier găsit.

```bash
# Căutare în directorul curent
find . -name "*.txt"

# Căutare în mai multe locații
find /home /var -name "*.log"

# Căutare în tot sistemul (suprimă erorile de permisiuni)
find / -name "config" 2>/dev/null
```

### 1.2 Căutare după Nume

```bash
# Potrivire exactă (case-sensitive)
find . -name "README.md"

# Case-insensitive
find . -iname "readme.md"

# Pattern cu wildcards
find . -name "*.txt"
find . -name "data_*"
find . -name "*backup*"

# Potrivire cale completă
find . -path "*src/*.c"
find . -path "*/test/*" -name "*.py"
```

### 1.3 Căutare după Tip

```bash
# Tipuri de fișiere
find . -type f          # fișiere obișnuite
find . -type d          # directoare
find . -type l          # link-uri simbolice
find . -type b          # dispozitive bloc
find . -type c          # dispozitive caracter

# Exemple practice
find . -type f -name "*.sh"     # doar fișiere .sh
find . -type d -name "test*"    # doar directoare test*
```

### 1.4 Căutare după Dimensiune

```bash
# Unități: c(bytes), k(KB), M(MB), G(GB)
find . -size 100c       # exact 100 bytes
find . -size +10M       # mai mare de 10 MB
find . -size -1k        # mai mic de 1 KB
find . -size +1G        # mai mare de 1 GB

# Range de dimensiuni
find . -size +10M -size -100M   # între 10 și 100 MB

# Fișiere goale
find . -empty
find . -type f -empty           # doar fișiere goale
find . -type d -empty           # doar directoare goale
```

### 1.5 Căutare după Timp

```bash
# Timp de modificare (mtime)
find . -mtime 0         # modificate în ultimele 24h
find . -mtime -7        # modificate în ultimele 7 zile
find . -mtime +30       # modificate acum mai mult de 30 zile

# În minute (mmin, amin, cmin)
find . -mmin -60        # modificate în ultima oră
find . -mmin +120       # modificate acum mai mult de 2 ore

# Comparație cu alt fișier
find . -newer reference.txt     # mai noi decât reference.txt
```

### 1.6 Căutare după Permisiuni și Proprietar

```bash
# După permisiuni
find . -perm 644                # exact 644
find . -perm -644               # cel puțin 644 (toți biții setați)
find . -perm /644               # oricare din biți

# După proprietar
find . -user student
find . -group developers
find . -nouser                  # fără proprietar valid
```

### 1.7 Operatori Logici

```bash
# AND (implicit)
find . -type f -name "*.txt"

# OR
find . -name "*.txt" -o -name "*.md"
find . \( -name "*.c" -o -name "*.h" \)

# NOT
find . ! -name "*.txt"
find . -type f ! -name "*.bak"

# Combinații complexe
find . -type f \( -name "*.txt" -o -name "*.md" \) ! -name "*backup*"
```

### 1.8 Acțiuni

```bash
# Ștergere directă
find . -name "*.tmp" -delete

# Execuție comandă pentru fiecare fișier
find . -name "*.txt" -exec cat {} \;
find . -name "*.sh" -exec chmod +x {} \;

# Execuție optimizată (mai puține procese)
find . -name "*.txt" -exec cat {} +

# Execuție cu confirmare interactivă
find . -name "*.log" -ok rm {} \;

# Output cu null delimiter (pentru xargs)
find . -name "*.txt" -print0
```

---

## 2. Comanda xargs

### 2.1 Conceptul xargs

`xargs` construiește și execută comenzi din stdin, transformând input-ul în argumente.

```bash
# Diferența
echo "file1 file2" | cat    # cat citește stdin
echo "file1 file2" | xargs cat    # cat file1 file2
```

### 2.2 Utilizare de Bază

```bash
# Cu find
find . -name "*.txt" | xargs wc -l
find . -name "*.log" | xargs rm

# Cu alte comenzi
cat files.txt | xargs rm
echo "pkg1 pkg2 pkg3" | xargs apt install
```

### 2.3 Opțiuni Importante

```bash
# Limitare argumente per execuție
echo "1 2 3 4 5" | xargs -n 2 echo
# 1 2
# 3 4
# 5

# Placeholder personalizat
find . -name "*.txt" | xargs -I{} cp {} backup/
find . -name "*.jpg" | xargs -I FILE convert FILE FILE.png

# Delimitator null (pentru fișiere cu spații)
find . -name "*.txt" -print0 | xargs -0 cat

# Execuție paralelă
find . -name "*.jpg" | xargs -P 4 -I{} convert {} {}.png
cat urls.txt | xargs -P 10 -n 1 wget

# Afișare comandă
find . -name "*.tmp" | xargs -t rm

# Confirmare interactivă
find . -name "*.bak" | xargs -p rm
```

---

## 3. Comanda locate

### 3.1 Utilizare de Bază

```bash
# Căutare rapidă în baza de date
locate filename
locate "*.pdf"

# Case-insensitive
locate -i README

# Limitare rezultate
locate -n 10 "*.log"

# Numărare potriviri
locate -c "*.txt"
```

### 3.2 Actualizarea Bazei de Date

```bash
# Actualizare manuală (necesită root)
sudo updatedb
```

### 3.3 Comparație locate vs find

| Aspect | locate | find |
|--------|--------|------|
| Viteză | Foarte rapid | Mai lent |
| Actualizare | Necesită updatedb | Timp real |
| Criterii | Doar nume | Multe criterii |
| Acțiuni | Doar afișare | Multiple acțiuni |

---

## 4. Alte Utilitare

### 4.1 which și whereis

```bash
which python            # calea executabilului
which -a python         # toate versiunile din PATH

whereis ls              # binare, surse, manuale
whereis -b python       # doar binare
```

### 4.2 type și file

```bash
type cd                 # shell builtin
type ls                 # /usr/bin/ls
type ll                 # alias

file document.pdf       # PDF document
file script.sh          # shell script
file /bin/ls            # ELF executable
```

---

## 5. Exerciții Practice

### Exercițiul 1: Căutări cu find

```bash
# Fișiere .log mai mari de 10MB
find /var/log -type f -name "*.log" -size +10M

# Fișiere modificate în ultimele 24h
find ~ -type f -mtime 0

# Șterge fișiere temporare vechi
find /tmp -type f -name "*.tmp" -mtime +7 -delete
```

### Exercițiul 2: Pipeline-uri cu xargs

```bash
# Numără linii în fișiere .py
find . -name "*.py" | xargs wc -l

# Comprimă log-uri vechi
find /var/log -name "*.log" -mtime +30 | xargs -I{} gzip {}

# Caută pattern în cod sursă
find . -name "*.c" -print0 | xargs -0 grep "main"
```

---

## Cheat Sheet

```bash
# FIND
find . -name "*.txt"
find . -type f -size +10M
find . -mtime -7
find . -exec cmd {} \;
find . -print0 | xargs -0

# XARGS
cmd | xargs
cmd | xargs -n 1
cmd | xargs -I{} action {}
cmd | xargs -P 4
find . -print0 | xargs -0

# LOCATE
locate pattern
sudo updatedb

# DIVERSE
which cmd
whereis cmd
type cmd
file nume
```

---

*Material adaptat pentru cursul de Sisteme de Operare | ASE București - CSIE*
