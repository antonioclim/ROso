# TC3b - Bucle în Scripturi Bash

> **Sisteme de Operare** | ASE București - CSIE  
> Material de laborator - Seminar 2

---

## Obiective

La finalul acestui laborator, studentul va fi capabil să:
- Folosească buclele `for`, `while` și `until`
- Controleze fluxul cu `break` și `continue`
- Itereze peste fișiere, array-uri și output-ul comenzilor

---

## 1. Bucla for

### 1.1 Sintaxă de Bază

```bash
# Iterare peste listă explicită
for var in element1 element2 element3; do
    echo "$var"
done

# Exemple
for culoare in roșu verde albastru; do
    echo "Culoarea: $culoare"
done

for num in 1 2 3 4 5; do
    echo "Numărul: $num"
done
```

### 1.2 Iterare cu Brace Expansion

```bash
# Secvențe numerice
for i in {1..10}; do
    echo "i = $i"
done

# Cu pas
for i in {0..100..10}; do
    echo "i = $i"
done

# Secvențe alfabetice
for litera in {a..z}; do
    echo "$litera"
done
```

### 1.3 Iterare peste Fișiere

```bash
# Toate fișierele .txt
for file in *.txt; do
    echo "Procesez: $file"
done

# Cu glob recursiv
shopt -s globstar
for file in **/*.txt; do
    echo "Găsit: $file"
done

# Verificare existență
for file in *.xyz; do
    [ -f "$file" ] && echo "$file există"
done
```

### 1.4 Stilul C

```bash
# for (( init; condiție; increment ))
for (( i=0; i<10; i++ )); do
    echo "i = $i"
done

# Exemple
for (( i=1; i<=5; i++ )); do
    for (( j=1; j<=i; j++ )); do
        echo -n "*"
    done
    echo
done
```

### 1.5 Iterare peste Array

```bash
FRUCTE=("măr" "pară" "banană")

# Iterare valori
for fruct in "${FRUCTE[@]}"; do
    echo "$fruct"
done

# Cu index
for i in "${!FRUCTE[@]}"; do
    echo "[$i] = ${FRUCTE[$i]}"
done
```

---

## 2. Bucla while

Execută cât timp condiția este **adevărată**.

```bash
# Sintaxă
while [ condiție ]; do
    comenzi
done

# Exemplu: numărătoare
count=1
while [ $count -le 5 ]; do
    echo "Count: $count"
    ((count++))
done

# Buclă infinită
while true; do
    echo "Apasă Ctrl+C pentru a opri"
    sleep 1
done

# Citire fișier linie cu linie
while IFS= read -r line; do
    echo "Linia: $line"
done < fisier.txt

# Cu pipe (subshell!)
cat fisier.txt | while read line; do
    echo "$line"
done
```

---

## 3. Bucla until

Execută cât timp condiția este **falsă** (opusul lui while).

```bash
# Sintaxă
until [ condiție ]; do
    comenzi
done

# Exemplu
count=1
until [ $count -gt 5 ]; do
    echo "Count: $count"
    ((count++))
done

# Așteaptă un serviciu
until ping -c1 server &>/dev/null; do
    echo "Aștept serverul..."
    sleep 5
done
echo "Server disponibil!"
```

---

## 4. Control Flow

### 4.1 break

Ieșire din buclă.

```bash
for i in {1..100}; do
    if [ $i -eq 10 ]; then
        break
    fi
    echo $i
done

# break N - ieșire din N bucle
for i in {1..3}; do
    for j in {1..3}; do
        if [ $j -eq 2 ]; then
            break 2    # ieșire din ambele bucle
        fi
        echo "$i-$j"
    done
done
```

### 4.2 continue

Sari la următoarea iterație.

```bash
# Afișează doar numere impare
for i in {1..10}; do
    if [ $((i % 2)) -eq 0 ]; then
        continue
    fi
    echo $i
done

# continue N - continuă bucla N
for i in {1..3}; do
    for j in {1..3}; do
        if [ $j -eq 2 ]; then
            continue 2
        fi
        echo "$i-$j"
    done
done
```

---

## 5. Exemple Practice

### 5.1 Procesare Batch Fișiere

```bash
#!/bin/bash
# Convertește toate .jpeg în .jpg
for file in *.jpeg; do
    [ -f "$file" ] || continue
    newname="${file%.jpeg}.jpg"
    mv "$file" "$newname"
    echo "Redenumit: $file -> $newname"
done
```

### 5.2 Backup cu Numerotare

```bash
#!/bin/bash
for i in {1..5}; do
    backup_name="backup_$(date +%Y%m%d)_$i.tar.gz"
    echo "Creez: $backup_name"
    # tar czf "$backup_name" /data
done
```

### 5.3 Monitorizare Procese

```bash
#!/bin/bash
while true; do
    clear
    ps aux --sort=-%mem | head -10
    echo "---"
    date
    sleep 5
done
```

### 5.4 Procesare CSV

```bash
#!/bin/bash
while IFS=',' read -r nume varsta nota; do
    echo "Student: $nume, Vârsta: $varsta, Nota: $nota"
done < studenti.csv
```

---

## 6. Exerciții Practice

### Exercițiul 1: Numărătoare

```bash
#!/bin/bash
# Numără de la 1 la 10
for i in {1..10}; do
    echo $i
done

# Cu while
count=1
while [ $count -le 10 ]; do
    echo $count
    ((count++))
done
```

### Exercițiul 2: Suma Numerelor

```bash
#!/bin/bash
sum=0
for i in {1..100}; do
    ((sum += i))
done
echo "Suma: $sum"
```

### Exercițiul 3: Factorial

```bash
#!/bin/bash
n=5
factorial=1
for (( i=1; i<=n; i++ )); do
    ((factorial *= i))
done
echo "$n! = $factorial"
```

### Exercițiul 4: Citire Fișier

```bash
#!/bin/bash
line_num=0
while IFS= read -r line; do
    ((line_num++))
    echo "$line_num: $line"
done < "$1"
```

---

## Cheat Sheet

```bash
# FOR - LISTA
for var in lista; do cmd; done
for i in 1 2 3; do echo $i; done
for f in *.txt; do cat $f; done

# FOR - BRACE EXPANSION
for i in {1..10}; do echo $i; done
for i in {0..100..10}; do echo $i; done

# FOR - STIL C
for ((i=0; i<10; i++)); do
    echo $i
done

# WHILE
while [ condiție ]; do
    comenzi
done

# UNTIL
until [ condiție ]; do
    comenzi
done

# CITIRE FIȘIER
while IFS= read -r line; do
    echo "$line"
done < fisier.txt

# CONTROL
break           # ieșire din buclă
break N         # ieșire din N bucle
continue        # următoarea iterație
continue N      # continuă bucla N

# BUCLĂ INFINITĂ
while true; do cmd; done
while :; do cmd; done
for ((;;)); do cmd; done
```

---

*Material adaptat pentru cursul de Sisteme de Operare | ASE București - CSIE*
