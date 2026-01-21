# TC4a - Redirecționare I/O

> **Sisteme de Operare** | ASE București - CSIE  
> Material de laborator - Seminar 2

---

## Obiective

La finalul acestui laborator, studentul va fi capabil să:

Trei lucruri contează aici: redirecționeze input și output al comenzilor, folosească pipe-uri pentru înlănțuirea comenzilor, și gestioneze stdin, stdout și stderr.


---

## 1. File Descriptors

Fiecare proces are 3 stream-uri standard:

| FD | Nume | Implicit | Descriere |
|----|------|----------|-----------|
| 0 | stdin | Tastatură | Input standard |
| 1 | stdout | Terminal | Output standard |
| 2 | stderr | Terminal | Output erori |

```
          ┌──────────────┐
stdin ──► │    PROCES    │ ──► stdout
  (0)     │              │  (1)
          │              │ ──► stderr
          └──────────────┘  (2)
```

---

## 2. Redirecționare Output

### 2.1 stdout (`>` și `>>`)

```bash
# Suprascrie fișier (creează dacă nu există)
echo "Hello" > output.txt

# Adaugă la fișier (append)
echo "World" >> output.txt

# Redirecționare explicită
echo "text" 1> output.txt      # echivalent cu >

# Exemplu
ls -la > lista.txt
date >> log.txt
```

### 2.2 stderr (`2>` și `2>>`)

```bash
# Redirecționare erori
ls /inexistent 2> errors.txt

# Append erori
ls /alt_inexistent 2>> errors.txt

# Exemplu: salvează doar erorile
find / -name "*.conf" 2> errors.log
```

### 2.3 Combinare stdout și stderr

```bash
# Ambele în același fișier
comanda > all.txt 2>&1         # clasic
comanda &> all.txt             # shortcut (Bash)
comanda &>> all.txt            # append

# În fișiere separate
comanda > output.txt 2> errors.txt

# stderr către stdout
comanda 2>&1 | less            # pipe include și erorile
comanda |& less                # shortcut Bash 4+
```

### 2.4 Suprimare Output

```bash
# Aruncă stdout
comanda > /dev/null

# Aruncă stderr
comanda 2> /dev/null

# Aruncă totul
comanda > /dev/null 2>&1
comanda &> /dev/null

# Exemplu: rulare silențioasă
if ping -c1 server &> /dev/null; then
    echo "Server online"
fi
```

---

## 3. Redirecționare Input

### 3.1 stdin (`<`)

```bash
# Citește din fișier
wc -l < fisier.txt
sort < numere.txt > sortate.txt

# Input pentru comandă
mail -s "Subiect" user@example.com < mesaj.txt
```

### 3.2 Here Document (`<<`)

```bash
# Citește input până la delimitator
cat << EOF
Linia 1
Linia 2
Variabila: $HOME
EOF

# Fără expansiune variabile
cat << 'EOF'
Literal: $HOME
EOF

# Cu indentare (<<-)
cat <<- EOF
	Linia indentată
	Altă linie
EOF
```

### 3.3 Here String (`<<<`)

```bash
# String ca input
wc -w <<< "Aceasta este o propoziție"
# Output: 4

tr 'a-z' 'A-Z' <<< "hello world"
# Output: HELLO WORLD

bc <<< "5 + 3"
# Output: 8
```

---

## 4. Pipe-uri

Conectează stdout unei comenzi la stdin alteia.

```bash
# Sintaxă
comanda1 | comanda2 | comanda3

# Exemple
ls -la | less
cat file.txt | grep "pattern" | wc -l
ps aux | sort -k4 -rn | head -10

# Pipeline complex
find . -name "*.log" | xargs grep "ERROR" | sort | uniq -c | sort -rn
```

### 4.1 Named Pipes (FIFO)

```bash
# Creare FIFO
mkfifo my_pipe

# Terminal 1: citește din pipe
cat my_pipe

# Terminal 2: scrie în pipe
echo "Hello from other terminal" > my_pipe

# Cleanup
rm my_pipe
```

---

## 5. Comenzi Utile

### 5.1 tee

Duplică stream-ul către fișier și stdout.

```bash
# Salvează și afișează
ls -la | tee lista.txt

# Append
ls -la | tee -a lista.txt

# Multiple fișiere
comanda | tee f1.txt f2.txt f3.txt

# În mijlocul pipeline-ului
cat data | sort | tee sorted.txt | uniq > unique.txt
```

### 5.2 xargs

Construiește argumente din stdin.

```bash
# De bază
find . -name "*.txt" | xargs cat

# Cu placeholder
find . -name "*.txt" | xargs -I{} cp {} backup/

# Limitare argumente
echo "1 2 3 4 5" | xargs -n 2 echo

# Execuție paralelă
find . -name "*.jpg" | xargs -P 4 -I{} convert {} {}.png
```

---

## 6. Exerciții Practice

### Exercițiul 1: Redirecționare de Bază

```bash
# Crează fișier
echo "Linia 1" > test.txt
echo "Linia 2" >> test.txt
cat test.txt

# Salvează erori separat
ls /existent /inexistent > output.txt 2> errors.txt
```

### Exercițiul 2: Pipeline

```bash
# Top 5 procese după memorie
ps aux --sort=-%mem | head -6

# Numără fișierele .txt
find . -name "*.txt" | wc -l

# IP-uri unice din log
cat access.log | cut -d' ' -f1 | sort | uniq -c | sort -rn
```

### Exercițiul 3: Here Document

```bash
# Script care creează fișier
cat > config.txt << EOF
# Configurație
SERVER=$HOSTNAME
DATE=$(date)
USER=$USER
EOF
```

### Exercițiul 4: tee

```bash
# Logging cu afișare
./script.sh 2>&1 | tee -a script.log
```

---

## Cheat Sheet

```bash
# OUTPUT
cmd > file          # stdout -> file (overwrite)
cmd >> file         # stdout -> file (append)
cmd 2> file         # stderr -> file
cmd 2>> file        # stderr -> file (append)
cmd &> file         # stdout+stderr -> file
cmd > f1 2> f2      # separate

# INPUT
cmd < file          # file -> stdin
cmd << DELIM        # here document
cmd <<< "string"    # here string

# COMBINARE
cmd 2>&1            # stderr -> stdout
cmd > /dev/null     # discard stdout
cmd &> /dev/null    # discard all

# PIPE
cmd1 | cmd2         # stdout -> stdin
cmd |& cmd2         # stdout+stderr -> stdin

# UTILITARE
cmd | tee file      # duplicate stream
cmd | xargs         # stdin -> args
mkfifo pipe         # named pipe
```

---

*Material adaptat pentru cursul de Sisteme de Operare | ASE București - CSIE*
