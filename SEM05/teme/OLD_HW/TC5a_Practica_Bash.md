# TC5a - Practică Bash Scripting

> **Sisteme de Operare** | ASE București - CSIE  
> Material de laborator - Seminar 5

---

## Obiective

La finalul acestui laborator, studentul va fi capabil să:
- Aplice cunoștințele de scripting în exerciții practice
- Folosească structuri condiționale și bucle
- Proceseze date și fișiere cu scripturi

---

## 1. Structuri Condiționale

### 1.1 Comanda test și [ ]

```bash
# Forme echivalente
test expresie
[ expresie ]
[[ expresie ]]    # Bash extended (recomandat)
```

### 1.2 Comparații Numerice

```bash
[ $a -eq $b ]     # egal (equal)
[ $a -ne $b ]     # diferit (not equal)
[ $a -lt $b ]     # mai mic (less than)
[ $a -gt $b ]     # mai mare (greater than)
[ $a -le $b ]     # mai mic sau egal
[ $a -ge $b ]     # mai mare sau egal

# Cu (( )) pentru aritmetică
(( a == b ))
(( a != b ))
(( a < b ))
(( a > b ))
```

### 1.3 Comparații String

```bash
[ "$a" = "$b" ]       # egal
[ "$a" != "$b" ]      # diferit
[ -z "$a" ]           # string gol (zero length)
[ -n "$a" ]           # string non-gol (non-zero)
[[ "$a" < "$b" ]]     # comparație lexicografică
[[ "$a" =~ regex ]]   # potrivire regex (Bash)
```

### 1.4 Teste Fișiere

```bash
[ -e file ]     # există (entry)
[ -f file ]     # fișier regulat
[ -d file ]     # director
[ -s file ]     # dimensiune > 0
[ -r file ]     # citibil (readable)
[ -w file ]     # scriibil (writable)
[ -x file ]     # executabil
[ -L file ]     # symlink
[ -h file ]     # symlink (alias)
[ file1 -nt file2 ]   # file1 mai nou (newer than)
[ file1 -ot file2 ]   # file1 mai vechi (older than)
```

### 1.5 Operatori Logici

```bash
[ ! expr ]            # negare
[ expr1 -a expr2 ]    # AND (în [ ])
[ expr1 -o expr2 ]    # OR (în [ ])
[[ expr1 && expr2 ]]  # AND (în [[ ]])
[[ expr1 || expr2 ]]  # OR (în [[ ]])
```

---

## 2. If-Then-Else

### 2.1 Sintaxă

```bash
if [ condiție ]; then
    comenzi
fi

if [ condiție ]; then
    comenzi
else
    alte_comenzi
fi

if [ condiție1 ]; then
    comenzi1
elif [ condiție2 ]; then
    comenzi2
else
    comenzi_default
fi
```

### 2.2 Exemple

```bash
#!/bin/bash

# Verifică dacă fișierul există
if [ -f "$1" ]; then
    echo "Fișierul există"
    cat "$1"
else
    echo "Fișierul nu există"
    exit 1
fi

# Verifică vârsta
read -p "Vârsta: " varsta
if [ "$varsta" -ge 18 ]; then
    echo "Adult"
elif [ "$varsta" -ge 13 ]; then
    echo "Adolescent"
else
    echo "Copil"
fi

# One-liner
[ -f "$file" ] && echo "Există" || echo "Nu există"
```

---

## 3. Case

### 3.1 Sintaxă

```bash
case "$variabila" in
    pattern1)
        comenzi1
        ;;
    pattern2|pattern3)
        comenzi2
        ;;
    *)
        comenzi_default
        ;;
esac
```

### 3.2 Exemple

```bash
#!/bin/bash

case "$1" in
    start)
        echo "Starting service..."
        ;;
    stop)
        echo "Stopping service..."
        ;;
    restart)
        echo "Restarting service..."
        ;;
    status)
        echo "Checking status..."
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status}"
        exit 1
        ;;
esac

# Pattern-uri avansate
case "$filename" in
    *.txt)
        echo "Text file"
        ;;
    *.jpg|*.png|*.gif)
        echo "Image file"
        ;;
    *.tar.gz|*.tgz)
        echo "Compressed archive"
        ;;
    *)
        echo "Unknown type"
        ;;
esac
```

---

## 4. Bucle

### 4.1 For Loop

```bash
# Lista explicită
for item in a b c d; do
    echo "$item"
done

# Brace expansion
for i in {1..10}; do
    echo "Number: $i"
done

# Fișiere
for file in *.txt; do
    echo "Processing: $file"
done

# Stil C
for ((i=0; i<10; i++)); do
    echo "i = $i"
done

# Iterare array
arr=(a b c d)
for item in "${arr[@]}"; do
    echo "$item"
done
```

### 4.2 While Loop

```bash
# Counter
count=1
while [ $count -le 5 ]; do
    echo "Count: $count"
    ((count++))
done

# Citire fișier
while IFS= read -r line; do
    echo "Line: $line"
done < file.txt

# Infinit
while true; do
    echo "Running..."
    sleep 1
done
```

### 4.3 Until Loop

```bash
# Execută până când condiția devine adevărată
count=1
until [ $count -gt 5 ]; do
    echo "Count: $count"
    ((count++))
done
```

### 4.4 Control Flow

```bash
break       # ieșire din buclă
break N     # ieșire din N bucle
continue    # sari la următoarea iterație
continue N  # continuă bucla exterioară N
```

---

## 5. Funcții

### 5.1 Definire și Apelare

```bash
# Definire
function nume_functie() {
    comenzi
}

# Sau (stil POSIX)
nume_functie() {
    comenzi
}

# Apelare
nume_functie
nume_functie arg1 arg2
```

### 5.2 Parametri și Return

```bash
greet() {
    local name="$1"      # Variabilă locală
    echo "Hello, $name!"
    return 0             # Exit status (0-255)
}

greet "World"
status=$?                # Capturează return value

# Returnare valori complexe (prin echo)
get_sum() {
    local a=$1 b=$2
    echo $((a + b))
}

result=$(get_sum 5 3)
echo "Sum: $result"
```

### 5.3 Variabile Locale

```bash
#!/bin/bash

global_var="global"

test_scope() {
    local local_var="local"
    global_var="modified"
    
    echo "Inside: $local_var, $global_var"
}

test_scope
echo "Outside: $global_var"  # "modified"
echo "Outside: $local_var"   # gol (nu există)
```

---

## 6. Exerciții Practice Complete

### Exercițiul 1: Verificare Fișiere

```bash
#!/bin/bash
# Verifică tipul argumentului

if [ $# -eq 0 ]; then
    echo "Usage: $0 <file/dir>"
    exit 1
fi

if [ ! -e "$1" ]; then
    echo "Nu există: $1"
    exit 1
fi

if [ -f "$1" ]; then
    echo "Fișier: $1"
    echo "Dimensiune: $(stat -c %s "$1") bytes"
    echo "Linii: $(wc -l < "$1")"
elif [ -d "$1" ]; then
    echo "Director: $1"
    echo "Conține: $(ls -1 "$1" | wc -l) elemente"
elif [ -L "$1" ]; then
    echo "Symlink: $1 -> $(readlink "$1")"
fi
```

### Exercițiul 2: Calculator

```bash
#!/bin/bash
# Calculator simplu

usage() {
    echo "Usage: $0 num1 operator num2"
    echo "Operators: + - * / %"
    exit 1
}

[ $# -ne 3 ] && usage

a=$1
op=$2
b=$3

case $op in
    +) result=$((a + b)) ;;
    -) result=$((a - b)) ;;
    '*') result=$((a * b)) ;;
    /) 
        [ $b -eq 0 ] && { echo "Eroare: împărțire la 0"; exit 1; }
        result=$((a / b)) 
        ;;
    %) result=$((a % b)) ;;
    *) usage ;;
esac

echo "$a $op $b = $result"
```

### Exercițiul 3: Procesare Fișiere

```bash
#!/bin/bash
# Procesează toate fișierele .txt

count=0
total_lines=0

for file in *.txt; do
    [ -f "$file" ] || continue
    
    lines=$(wc -l < "$file")
    ((count++))
    ((total_lines += lines))
    
    echo "$file: $lines linii"
done

echo "---"
echo "Total: $count fișiere, $total_lines linii"
echo "Media: $((total_lines / count)) linii/fișier"
```

### Exercițiul 4: Menu Interactiv

```bash
#!/bin/bash

show_menu() {
    echo "=== MENU ==="
    echo "1. Afișează data"
    echo "2. Listează fișiere"
    echo "3. Spațiu disk"
    echo "4. Ieșire"
    echo "============"
}

while true; do
    show_menu
    read -p "Opțiune: " choice
    
    case $choice in
        1) date ;;
        2) ls -la ;;
        3) df -h ;;
        4) echo "La revedere!"; exit 0 ;;
        *) echo "Opțiune invalidă" ;;
    esac
    
    echo
    read -p "Apasă Enter pentru a continua..."
done
```

---

## Cheat Sheet

```bash
# TESTE
[ -f file ]     fișier există
[ -d dir ]      director există
[ -z "$s" ]     string gol
[ -n "$s" ]     string non-gol
[ $a -eq $b ]   numeric egal
[ "$a" = "$b" ] string egal

# IF
if [ cond ]; then ... fi
if [ cond ]; then ... else ... fi
if [ cond ]; then ... elif ... fi

# CASE
case $var in
    pattern) cmd ;;
    *) default ;;
esac

# BUCLE
for i in {1..10}; do ... done
for f in *.txt; do ... done
while [ cond ]; do ... done
until [ cond ]; do ... done

# FUNCȚII
func() { local v="..."; echo $1; return 0; }
result=$(func arg)

# CONTROL
break       ieșire buclă
continue    următoarea iterație
exit N      ieșire script
return N    ieșire funcție
```

---
*Material adaptat pentru cursul de Sisteme de Operare | ASE București - CSIE*
