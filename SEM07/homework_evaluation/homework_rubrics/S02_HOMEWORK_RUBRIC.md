# Rubrică de evaluare — teme S02

> **Sisteme de Operare** | ASE Bucharest - CSIE  
> Seminar 02: flux de control și procesare de text

---

## Prezentarea temelor

| ID | Subiect | Durată | Dificultate |
|----|-------|----------|------------|
| S02b | Operatori de control | 40 min | ⭐⭐ |
| S02c | Redirecționare I/O | 45 min | ⭐⭐ |
| S02d | Pipe‑uri și tee | 40 min | ⭐⭐ |
| S02e | Filtre de text | 50 min | ⭐⭐⭐ |
| S02f | Bucle în scripting | 45 min | ⭐⭐⭐ |

---

## S02b - Operatori de control (10 puncte)

### Sarcini
1. Demonstrați execuția secvențială cu `;`
2. Utilizați `&&` pentru condiționare la succes
3. Utilizați `||` pentru condiționare la eșec
4. Combinați operatorii pentru logică mai complexă
5. Utilizați `&` pentru execuție în background

### Criterii de notare

| Criteriu | Puncte | Cerințe |
|-----------|--------|--------------|
| Punct și virgulă | 2.0 | Execuție secvențială corectă |
| Operator AND | 2.0 | && cu dependență de succes |
| Operator OR | 2.0 | \|\| ca fallback la eșec |
| Combinații | 2.0 | && și \|\| împreună |
| Background | 2.0 | & cu gestionarea jobs |

### Comenzi așteptate
```bash
echo "Start" ; ls ; echo "Done"
mkdir test && cd test && touch file.txt
[ -f config ] || echo "Config missing"
ping -c1 server && echo "OK" || echo "FAIL"
sleep 10 & jobs
```

### Depunctări uzuale
- `-1.0`: Confuzie între comportamentul && și ||
- `-0.5`: Neutilizarea corectă a codurilor de ieșire
- `-0.5`: Lipsa spațiilor în parantezele de test

---

## S02c - Redirecționare I/O (10 puncte)

### Sarcini
1. Redirecționați stdout cu `>` și `>>`
2. Redirecționați stderr cu `2>` și `2>>`
3. Combinați stdout și stderr
4. Utilizați redirecționare de input `<`
5. Utilizați here documents `<<` și here strings `<<<`

### Criterii de notare

| Criteriu | Puncte | Cerințe |
|-----------|--------|--------------|
| Redirecționare stdout | 2.0 | > și >> utilizate corect |
| Redirecționare stderr | 2.0 | 2> și 2>&1 |
| Combinat | 2.0 | &> și fișiere separate |
| Input | 2.0 | < și << și <<< |
| Utilizare practică | 2.0 | Rezolvarea unor probleme reale |

### Comenzi așteptate
```bash
ls > files.txt
ls >> files.txt
ls /nonexistent 2> errors.txt
command &> all.txt
wc -l < file.txt
cat << EOF
content
EOF
tr 'a-z' 'A-Z' <<< "hello"
```

---

## S02d - Pipe‑uri și tee (10 puncte)

### Sarcini
1. Construiți pipeline‑uri de bază
2. Utilizați `tee` pentru ramificarea output‑ului
3. Înțelegeți PIPESTATUS
4. Utilizați process substitution
5. Aplicați `set -o pipefail`

### Criterii de notare

| Criteriu | Puncte | Cerințe |
|-----------|--------|--------------|
| Pipe‑uri de bază | 2.5 | Pipeline‑uri cu mai multe etape |
| Comanda tee | 2.0 | Salvare și afișare |
| PIPESTATUS | 2.0 | Verificarea tuturor codurilor de ieșire |
| Process substitution | 2.0 | <() și >() |
| Tratarea erorilor | 1.5 | Utilizarea pipefail |

### Comenzi așteptate
```bash
cat data | sort | uniq -c | sort -rn | head -10
ls -la | tee listing.txt | wc -l
echo "${PIPESTATUS[@]}"
diff <(ls dir1) <(ls dir2)
set -o pipefail
```

---

## S02e - Filtre de text (10 puncte)

### Sarcini
1. Utilizați sort cu opțiuni variate
2. Identificați linii unice cu uniq
3. Extrageți coloane cu cut
4. Transformați caractere cu tr
5. Numărați cu wc
6. Utilizați head, tail, tee în mod eficient

### Criterii de notare

| Criteriu | Puncte | Cerințe |
|-----------|--------|--------------|
| sort | 2.0 | opțiunile -n, -r, -k, -t |
| uniq | 1.5 | opțiunile -c, -d, -u |
| cut | 1.5 | opțiunile -d, -f, -c |
| tr | 2.0 | înlocuire, ștergere, squeeze |
| wc/head/tail | 1.5 | utilizare adecvată |
| Combinații în pipeline | 1.5 | combinarea eficientă a filtrelor |

### Pipeline așteptat
```bash
# Top 10 IPs from log file
cat access.log | cut -d' ' -f1 | sort | uniq -c | sort -rn | head -10
```

### Depunctări uzuale
- `-1.0`: Neutilizarea sort înainte de uniq
- `-0.5`: Delimitator greșit în cut
- `-0.5`: Useless use of cat

---

## S02f - Bucle în scripting (10 puncte)

### Sarcini
1. Utilizați bucle `for` cu liste
2. Utilizați `for` cu brace expansion
3. Utilizați bucle `for` în stil C
4. Utilizați bucle `while` și `until`
5. Controlați fluxul cu `break` și `continue`
6. Citiți fișiere linie cu linie

### Criterii de notare

| Criteriu | Puncte | Cerințe |
|-----------|--------|--------------|
| Bucle for | 2.5 | forme cu listă și cu brace |
| for în stil C | 1.5 | sintaxă (( )) |
| while/until | 2.0 | bucle condiționale |
| break/continue | 2.0 | control de flux |
| Citire fișiere | 2.0 | tiparul while read |

### Comenzi așteptate
```bash
for i in {1..10}; do echo $i; done

for file in *.txt; do
    echo "Processing $file"
done

for ((i=0; i<5; i++)); do
    echo $i
done

while IFS= read -r line; do
    echo "Line: $line"
done < file.txt

count=0
while [ $count -lt 10 ]; do
    ((count++))
    [ $count -eq 5 ] && continue
    echo $count
done
```

### Depunctări uzuale
- `-1.0`: Pipe către while (problemă de subshell)
- `-0.5`: Neutilizarea IFS= la citire
- `-0.5`: Lipsa opțiunii -r în read

---

## Oportunități de bonus

| Bonus | Puncte | Descriere |
|-------|--------|-------------|
| Pipeline complex | +0.5 | 5+ etape, logică corectă |
| Tratarea erorilor | +0.5 | pipefail + PIPESTATUS complet |
| Soluție creativă | +0.5 | Abordare elegantă |

**Maximum total: 10.0 puncte**

---

*De Revolvix pentru disciplina OPERATING SYSTEMS | licență restricționată 2017-2030*
