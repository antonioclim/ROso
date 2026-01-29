# S04_TC04 - AWK - Procesare Text Structurat

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

> **Preferință personală**: AWK e tool-ul meu preferat pentru procesare CSV rapidă. Știu că există pandas în Python, dar când ai 3 linii de awk vs 15 linii de Python pentru același rezultat... time is money!

La finalul acestui laborator, studentul va fi capabil să:
- Proceseze fișiere text structurate cu AWK
- Folosească variabile built-in și definite de utilizator
- Implementeze logică condițională și bucle
- Creeze rapoarte și modificări de date

---


## 2. Câmpuri și Variabile Built-in

### 2.1 Câmpuri

```bash
$0      # Întreaga linie
$1      # Primul câmp
$2      # Al doilea câmp
...
$NF     # Ultimul câmp
$(NF-1) # Penultimul câmp
```

### 2.2 Variabile Built-in

| Variabilă | Descriere |
|-----------|-----------|
| `NR` | Numărul liniei curente (Number of Record) |
| `NF` | Numărul de câmpuri pe linia curentă |
| `FS` | Field Separator (input), default: spațiu/tab |
| `OFS` | Output Field Separator, default: spațiu |
| `RS` | Record Separator (input), default: newline |
| `ORS` | Output Record Separator, default: newline |
| `FILENAME` | Numele fișierului curent |
| `FNR` | Numărul liniei în fișierul curent |

### 2.3 Exemple

```bash
# Afișează prima coloană
awk '{ print $1 }' file.txt

# Afișează ultima coloană
awk '{ print $NF }' file.txt

# Afișează coloanele 1 și 3
awk '{ print $1, $3 }' file.txt

# Cu separator custom (CSV)
awk -F',' '{ print $2 }' data.csv

# Multiple separatori
awk -F'[,;:]' '{ print $1 }' file.txt
```

---

## 3. Pattern-uri

### 3.1 Tipuri de Pattern-uri

```bash
# Regex
awk '/error/' log.txt           # linii cu "error"
awk '/^#/' config.txt           # linii care încep cu #
awk '!/^#/' config.txt          # linii care NU încep cu #

# Comparație
awk '$3 > 100' file.txt         # coloana 3 > 100
awk '$1 == "John"' file.txt     # coloana 1 este "John"
awk 'NR > 1' file.txt           # skip header (linia 1)

# Range
awk '/start/,/end/' file.txt    # de la "start" până la "end"
awk 'NR==5,NR==10' file.txt     # liniile 5-10

# Combinații logice
awk '$3 > 100 && $4 < 50' file.txt
awk '$1 == "A" || $1 == "B"' file.txt
```

### 3.2 BEGIN și END

```bash
# BEGIN - execută înainte de procesare
# END - execută după procesare

awk 'BEGIN { print "Header" } 
     { print $0 } 
     END { print "Footer" }' file.txt

# Exemplu: numără linii
awk 'END { print NR " linii" }' file.txt

# Calculare medie
awk '{ sum += $1 } END { print "Media:", sum/NR }' numbers.txt
```

---

## 4. Acțiuni și Printf

### 4.1 Print vs Printf

```bash
# print - simplu
awk '{ print $1, $2 }' file.txt           # separat de OFS
awk '{ print $1 " - " $2 }' file.txt      # cu separator custom

# printf - formatat (ca în C)
awk '{ printf "%-10s %5d\n", $1, $2 }' file.txt

# Formate printf
# %s string
# %d integer
# %f float
# %e scientific
# %-10s string aliniat stânga, 10 caractere
# %5d integer, 5 caractere
# %.2f float cu 2 zecimale
```

### 4.2 Exemple Printf

```bash
# Tabel formatat
awk 'BEGIN { printf "%-15s %10s\n", "Name", "Score" }
     { printf "%-15s %10d\n", $1, $2 }' scores.txt

# Procente
awk '{ printf "%s: %.1f%%\n", $1, $2*100 }' ratios.txt
```

---

## 5. Variabile și Operatori

### 5.1 Variabile User-defined

```bash
# Inițializare
awk 'BEGIN { count = 0 } /error/ { count++ } END { print count }' log.txt

# Variabile din command line
awk -v threshold=100 '$3 > threshold' file.txt

# Multiple variabile
awk -v min=10 -v max=100 '$1 >= min && $1 <= max' numbers.txt
```

### 5.2 Operatori

```bash
# Aritmetici
+  -  *  /  %  ^

# Comparație
==  !=  <  >  <=  >=

# Regex
~     # potrivește regex
!~    # nu potrivește regex

# Logici
&&  ||  !

# Increment/Decrement
++  --  +=  -=
```

---

## 6. Structuri de Control

### 6.1 If-Else

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

### 6.2 Bucle

```bash
# For loop
awk '{ for (i=1; i<=NF; i++) print $i }' file.txt

# While loop
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

## 7. Arrays Asociative

```bash
# Numărare frecvență
awk '{ count[$1]++ } END { for (k in count) print k, count[k] }' file.txt

# Sume pe categorii
awk '{ sum[$1] += $2 } END { for (k in sum) print k, sum[k] }' sales.txt

# Sortare output
awk '{ count[$1]++ } END { for (k in count) print k, count[k] }' file.txt | sort -k2 -rn
```

---

## 8. Funcții Built-in

### 8.1 Funcții String

```bash
length(s)           # lungimea string-ului
substr(s, start, len)   # substring
index(s, target)    # poziția target în s
split(s, arr, sep)  # împarte string în array
gsub(regex, repl, s)    # înlocuire globală
sub(regex, repl, s)     # înlocuire prima
tolower(s)          # lowercase
toupper(s)          # uppercase
```

### 8.2 Funcții Matematice

```bash
int(x)      # partea întreagă
sqrt(x)     # radical
sin(x), cos(x), atan2(y,x)
exp(x)      # e^x
log(x)      # logaritm natural
rand()      # random 0-1
srand(seed) # seed pentru rand
```

### 8.3 Exemple

```bash
# Uppercase coloana 1
awk '{ print toupper($1), $2 }' file.txt

# Extrage substring
awk '{ print substr($1, 1, 3) }' file.txt

# Înlocuire
awk '{ gsub(/old/, "new"); print }' file.txt
```

---

## 9. Exemple Complete

### 9.1 Procesare Log
```bash
# Top 10 IP-uri din access log
awk '{ count[$1]++ } 
     END { for (ip in count) print count[ip], ip }' access.log | sort -rn | head -10
```

### 9.2 Raport CSV
```bash
# Calculează total per categorie din CSV
awk -F',' 'NR>1 { sum[$1] += $3 } 
           END { for (cat in sum) printf "%s: $%.2f\n", cat, sum[cat] }' sales.csv
```

### 9.3 Transpunere Coloane
```bash
# Schimbă coloane
awk '{ print $2, $1, $3 }' file.txt

# Inversează ordinea coloanelor
awk '{ for (i=NF; i>0; i--) printf "%s ", $i; print "" }' file.txt
```

---

## Cheat Sheet

```bash
# SINTAXĂ
awk 'pattern { action }' file
awk -F',' '{ print $2 }' file

# CÂMPURI
$0          întreaga linie
$1, $2...   câmpuri
$NF         ultimul
NR          nr. linie
NF          nr. câmpuri

# PATTERN-URI
/regex/     potrivire regex
$1 > 10     comparație
NR > 1      skip header
BEGIN {}    înainte
END {}      după

# PRINT
print $1, $2
printf "%s %d", $1, $2

# CONTROL
if () {} else {}
for (i=1; i<=NF; i++) {}
for (k in arr) {}

# FUNCȚII
length(), substr(), split()
tolower(), toupper()
gsub(), sub()

# ARRAYS
arr[$1]++
for (k in arr) print k, arr[k]
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
