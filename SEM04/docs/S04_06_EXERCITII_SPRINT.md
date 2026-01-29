# Exerciții Sprint: Text Processing
## Provocări Cronometrate - Regex, GREP, SED, AWK

> *Observație din laborator: am văzut studenți care rezolvă exercițiile mai repede când își citesc comanda cu voce tare înainte să dea Enter. Sună ciudat, dar ajută la prinderea erorilor de sintaxă.*

> Sisteme de Operare | Academia de Studii Economice București - CSIE  
> Seminar 4 | Timed Sprints  
> Format: Pair Programming | Timp per sprint: 10-15 min

---

## Instrucțiuni pentru Sprint-uri

### Format de Lucru

```
┌─────────────────────────────────────────────────────────────────────────┐
│  🏃 REGULI SPRINT                                                       │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  1. PERECHI - Lucrați în perechi (pair programming)                    │
│                                                                         │
│  2. ROTAȚIE - Schimbați rolurile la jumătatea timpului                 │
│     • Driver = tastează                                                 │
│     • Navigator = ghidează și verifică                                  │
│                                                                         │
│  3. TIMP - Respectați strict limita de timp                            │
│                                                                         │
│  4. PROGRESIV - Exercițiile sunt în ordine de dificultate              │
│                                                                         │
│  5. BONUS - Încercați exercițiile bonus doar dacă ați terminat restul │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### Setup Inițial

```bash
# Asigură-te că ești în directorul corect
cd ~/demo_sem4/data

# Verifică fișierele disponibile
ls -la

# Dacă lipsesc, rulează setup-ul
# ./scripts/bash/S04_01_setup_seminar.sh
```

---

# SPRINT G1: GREP BASICS (10 min)

## Context
Ai primit un fișier `access.log` cu log-uri de server web. Trebuie să extragi informații pentru raportul de securitate.

## Exerciții

### G1.1 (2 min)
**Găsește toate cererile cu cod de eroare 404 (Not Found)**

```bash
# Scrie comanda ta aici:

# Output așteptat: liniile complete cu " 404 "
```

<details>
<summary>💡 Hint</summary>
Pattern-ul codului HTTP e " 404 " (cu spații pentru exactitate)
</details>

<details>
<summary>✅ Soluție</summary>

```bash
grep ' 404 ' access.log
```
</details>

---

### G1.2 (2 min)
Numără câte cereri au fost făcute cu metoda POST

```bash
# Scrie comanda ta aici:

# Output așteptat: un număr
```

<details>
<summary>💡 Hint</summary>
Folosește grep -c pentru numărare
</details>

<details>
<summary>✅ Soluție</summary>

```bash
grep -c '"POST' access.log
# sau
grep -c 'POST' access.log
```
</details>

---

### G1.3 (3 min)
Găsește toate cererile către /admin (posibil atac)

```bash
# Scrie comanda ta aici:

# Output așteptat: linii cu /admin în URL
```

<details>
<summary>💡 Hint</summary>
Pattern simplu: '/admin'
</details>

<details>
<summary>✅ Soluție</summary>

```bash
grep '/admin' access.log
```
</details>

---

### G1.4 (3 min)
Extrage DOAR IP-urile unice din log (fără duplicate)

```bash
# Scrie comanda ta aici:

# Output așteptat: listă de IP-uri, unul per linie, fără duplicate
```

<details>
<summary>💡 Hint</summary>
Combină: grep -oE pentru IP, apoi sort -u pentru unice
</details>

<details>
<summary>✅ Soluție</summary>

```bash
grep -oE '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' access.log | sort -u

# sau mai precis:
grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' access.log | sort -u
```
</details>

---

### G1.5 BONUS
Găsește IP-ul cu cele mai multe cereri și numără-le

```bash
# Scrie comanda ta aici:

# Output așteptat: "X IP_ADDRESS" (număr și IP)
```

<details>
<summary>✅ Soluție</summary>

```bash
grep -oE '^[0-9.]+' access.log | sort | uniq -c | sort -rn | head -1
```
</details>

---

# SPRINT G2: GREP ADVANCED (10 min)

## Context
Continuăm analiza de securitate. Acum trebuie să investigăm mai în profunzime.

## Exerciții

### G2.1 (2 min)
Găsește cererile eșuate (coduri 4xx SAU 5xx)

```bash
# Scrie comanda ta aici:

# Output așteptat: linii cu coduri 400-599
```

<details>
<summary>💡 Hint</summary>
Pattern ERE: " [45][0-9]{2} " cu grep -E
</details>

<details>
<summary>✅ Soluție</summary>

```bash
grep -E '" [45][0-9]{2} ' access.log
```
</details>

---

### G2.2 (2 min)
**Afișează liniile cu eroare plus 2 linii de context (înainte și după)**

```bash
# Scrie comanda ta aici:

# Output așteptat: erori cu context
```

<details>
<summary>💡 Hint</summary>
Folosește -C pentru context
</details>

<details>
<summary>✅ Soluție</summary>

```bash
grep -C 2 ' 500 ' access.log
# sau pentru toate erorile:
grep -E -C 2 '" [45][0-9]{2} ' access.log
```
</details>

---

### G2.3 (3 min)
Din employees.csv, găsește angajații din departamentul IT cu salariu > 5500
(Observație: Asta necesită combinație grep + awk sau alt approach)

```bash
# Scrie comanda ta aici:

# Output așteptat: angajați IT cu salariu mare
```

<details>
<summary>💡 Hint</summary>
grep pentru IT, apoi awk pentru a filtra salariul, sau direct awk
</details>

<details>
<summary>✅ Soluție</summary>

```bash
# Variantă cu awk (mai precisă):
awk -F',' '$3 == "IT" && $4 > 5500' employees.csv

# Variantă cu grep + awk:
grep ',IT,' employees.csv | awk -F',' '$4 > 5500'
```
</details>

---

### G2.4 (3 min)
Extrage toate email-urile valide din emails.txt

```bash
# Scrie comanda ta aici:

# Output așteptat: doar email-uri valide, unul per linie
```

<details>
<summary>💡 Hint</summary>
Pattern email: `[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}`
</details>

<details>
<summary>✅ Soluție</summary>

```bash
grep -oE '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' emails.txt
```
</details>

---

### G2.5 BONUS
Creează un raport: pentru fiecare cod HTTP (200, 403, etc.), afișează numărul de apariții

```bash
# Scrie comanda ta aici:

# Output așteptat:
# N 200
# M 403
# ...
```

<details>
<summary>✅ Soluție</summary>

```bash
grep -oE '" [0-9]{3} ' access.log | grep -oE '[0-9]{3}' | sort | uniq -c | sort -rn
```
</details>

---

# SPRINT S1: SED TRANSFORMATIONS (10 min)

## Context
Ai primit un fișier de configurare care trebuie actualizat pentru deployment în producție.

## Exerciții

### S1.1 (2 min)
Înlocuiește toate aparițiile lui "localhost" cu "192.168.1.100" în config.txt
(Afișează rezultatul, nu modifica fișierul)

```bash
# Scrie comanda ta aici:

# Output așteptat: config cu IP-ul nou
```

<details>
<summary>✅ Soluție</summary>

```bash
sed 's/localhost/192.168.1.100/g' config.txt
```
</details>

---

### S1.2 (2 min)
Șterge toate comentariile (linii care încep cu #) din config.txt

```bash
# Scrie comanda ta aici:

# Output așteptat: config fără comentarii
```

<details>
<summary>✅ Soluție</summary>

```bash
sed '/^#/d' config.txt
```
</details>

---

### S1.3 (2 min)
Șterge comentariile ȘI liniile goale

```bash
# Scrie comanda ta aici:

# Output așteptat: config curat
```

<details>
<summary>✅ Soluție</summary>

```bash
sed '/^#/d; /^$/d' config.txt
# sau
sed -E '/^(#|$)/d' config.txt
```
</details>

---

### S1.4 (2 min)
Schimbă formatul de la "key=value" la "key = value" (adaugă spații în jurul =)

```bash
# Scrie comanda ta aici:

# Output așteptat: key = value
```

<details>
<summary>💡 Hint</summary>
s/=/ = / dar doar pe linii care NU sunt comentarii
</details>

<details>
<summary>✅ Soluție</summary>

```bash
sed '/^#/!s/=/ = /' config.txt
```
</details>

---

### S1.5 (2 min)
Pune toate valorile între ghilimele: key=value → key="value"

```bash
# Scrie comanda ta aici:

# Output așteptat: key="value"
```

<details>
<summary>💡 Hint</summary>
Folosește backreference: `s/=\(.*\)/="\1"/`
</details>

<details>
<summary>✅ Soluție</summary>

```bash
sed 's/=\(.*\)/="\1"/' config.txt
# sau cu ERE:
sed -E 's/=(.*)/="\1"/' config.txt
```
</details>

---

### S1.6 BONUS
Creează un script pentru a genera export statements pentru bash:
`key=value` → `export KEY="value"`

```bash
# Scrie comanda ta aici:

# Output așteptat:
# export SERVER_HOST="localhost"
# export SERVER_PORT="8080"
# ...
```

<details>
<summary>✅ Soluție</summary>

```bash
sed '/^#/d; /^$/d' config.txt | \
sed 's/\([a-z.]*\)=\(.*\)/export \U\1\E="\2"/' | \
sed 's/\./_/g'
```
Observație: Această soluție e complexă și necesită GNU sed pentru \U (uppercase).
</details>

---

# SPRINT A1: AWK BASICS (10 min)

## Context
Ai primit un CSV cu date despre angajați. Trebuie să extragi rapoarte pentru HR.

## Fișier: employees.csv
```csv
ID,Name,Department,Salary
101,John Smith,IT,5500
102,Maria Garcia,HR,4800
...
```

## Exerciții

### A1.1 (2 min)
Afișează doar numele angajaților (coloana 2)

```bash
# Scrie comanda ta aici:

# Output așteptat: lista de nume
```

<details>
<summary>✅ Soluție</summary>

```bash
awk -F',' '{ print $2 }' employees.csv
# sau skip header:
awk -F',' 'NR > 1 { print $2 }' employees.csv
```
</details>

---

### A1.2 (2 min)
Afișează numele și salariul, separate de tab

```bash
# Scrie comanda ta aici:

# Output așteptat:
# Name Salary
# John Smith 5500
# ...
```

<details>
<summary>✅ Soluție</summary>

```bash
awk -F',' '{ print $2 "\t" $4 }' employees.csv
# sau cu OFS:
awk -F',' 'BEGIN{OFS="\t"} { print $2, $4 }' employees.csv
```
</details>

---

### A1.3 (2 min)
Afișează doar angajații din departamentul "IT"

```bash
# Scrie comanda ta aici:

# Output așteptat: doar rândurile cu IT
```

<details>
<summary>✅ Soluție</summary>

```bash
awk -F',' '$3 == "IT"' employees.csv
```
</details>

---

### A1.4 (2 min)
Calculează și afișează suma totală a salariilor

```bash
# Scrie comanda ta aici:

# Output așteptat: Total: XXXXX
```

<details>
<summary>✅ Soluție</summary>

```bash
awk -F',' 'NR > 1 { sum += $4 } END { print "Total:", sum }' employees.csv
```
</details>

---

### A1.5 (2 min)
Calculează salariul mediu

```bash
# Scrie comanda ta aici:

# Output așteptat: Media: XXXX.XX
```

<details>
<summary>✅ Soluție</summary>

```bash
awk -F',' 'NR > 1 { sum += $4; count++ } END { print "Media:", sum/count }' employees.csv
```
</details>

---

### A1.6 BONUS
Găsește angajatul cu cel mai mare salariu și afișează-i numele și salariul

```bash
# Scrie comanda ta aici:

# Output așteptat: Name: XXXXX, Salary: XXXXX
```

<details>
<summary>✅ Soluție</summary>

```bash
awk -F',' 'NR > 1 && $4 > max { max = $4; name = $2 } END { print "Name:", name, "Salary:", max }' employees.csv
```
</details>

---

# SPRINT A2: AWK ADVANCED (10 min)

## Context
HR-ul vrea rapoarte agregate pe departamente.

## Exerciții

### A2.1 (3 min)
Numără câți angajați sunt în fiecare departament

```bash
# Scrie comanda ta aici:

# Output așteptat:
# IT 4
# HR 2
# ...
```

<details>
<summary>✅ Soluție</summary>

```bash
awk -F',' 'NR > 1 { count[$3]++ } END { for (d in count) print d, count[d] }' employees.csv
```
</details>

---

### A2.2 (3 min)
Calculează salariul total per departament

```bash
# Scrie comanda ta aici:

# Output așteptat:
# IT: $XXXXX
# HR: $XXXXX
# ...
```

<details>
<summary>✅ Soluție</summary>

```bash
awk -F',' 'NR > 1 { sum[$3] += $4 } END { for (d in sum) printf "%s: $%d\n", d, sum[d] }' employees.csv
```
</details>

---

### A2.3 (4 min)
Creează un raport formatat cu header:
```
Department      Count    Total Salary
-----------     -----    ------------
IT                 4         $XXXXX
HR                 2         $XXXXX
```

```bash
# Scrie comanda ta aici:

```

<details>
<summary>✅ Soluție</summary>

```bash
awk -F',' '
BEGIN { printf "%-15s %5s %15s\n", "Department", "Count", "Total Salary" }
NR > 1 { count[$3]++; sum[$3] += $4 }
END { 
    for (d in count) 
        printf "%-15s %5d %15s\n", d, count[d], "$"sum[d]
}' employees.csv
```
</details>

---

### A2.4 BONUS
Afișează doar departamentele cu salariu mediu > 5000

```bash
# Scrie comanda ta aici:

# Output așteptat: departamentele cu medie mare
```

<details>
<summary>✅ Soluție</summary>

```bash
awk -F',' '
NR > 1 { count[$3]++; sum[$3] += $4 }
END { 
    for (d in count) 
        if (sum[d]/count[d] > 5000) 
            printf "%s: avg=$%.2f\n", d, sum[d]/count[d]
}' employees.csv
```
</details>

---

# SPRINT COMBO: PIPELINE MASTER (15 min)

## Context
Provocare finală! Combină tot ce ai învățat.

## Exerciții

### C1 (5 min)
Din access.log, creează un raport cu top 5 IP-uri și numărul lor de cereri, formatat frumos:

```
=== TOP 5 IP ADDRESSES ===
1. 192.168.1.100    45 requests
2. 10.0.0.50        32 requests
...
```

```bash
# Scrie comanda ta aici:

```

<details>
<summary>✅ Soluție</summary>

```bash
echo "=== TOP 5 IP ADDRESSES ===" && \
grep -oE '^[0-9.]+' access.log | sort | uniq -c | sort -rn | head -5 | \
awk '{ printf "%d. %-20s %d requests\n", NR, $2, $1 }'
```
</details>

---

### C2 (5 min)
Procesează config.txt pentru a genera un fișier .env valid:
- Elimină comentarii
- Elimină linii goale
- modifică în format: UPPER_CASE_KEY="value"

```bash
# Scrie comanda ta aici:

# Output așteptat:
# SERVER_HOST="localhost"
# SERVER_PORT="8080"
# ...
```

<details>
<summary>✅ Soluție</summary>

```bash
grep -v '^#' config.txt | grep -v '^$' | \
sed 's/\./_/g' | \
awk -F'=' '{ print toupper($1) "=\"" $2 "\"" }'
```
</details>

---

### C3 (5 min)
Analiză completă employees.csv:
1. Afișează totalul angajaților
2. Departamentul cu cei mai mulți angajați
3. Angajatul cu cel mai mare salariu
4. Salariul mediu global

```bash
# Scrie comanda ta aici:

# Output așteptat: raport structurat
```

<details>
<summary>✅ Soluție</summary>

```bash
awk -F',' '
NR > 1 {
    total++
    sum += $4
    dept[$3]++
    if ($4 > maxSal) { maxSal = $4; maxName = $2 }
}
END {
    print "=== EMPLOYEE REPORT ==="
    print "Total employees:", total
    print "Average salary: $" sum/total
    print "Highest paid:", maxName, "($" maxSal ")"
    
    maxDept = ""; maxCount = 0
    for (d in dept) if (dept[d] > maxCount) { maxCount = dept[d]; maxDept = d }
    print "Largest department:", maxDept, "(" maxCount " employees)"
}' employees.csv
```
</details>

---

## Grading Guide

| Sprint | Total Puncte | Timp | Trecere (60%) |
|--------|--------------|------|---------------|
| G1 | 10 | 10 min | 6 |
| G2 | 12 | 10 min | 7 |
| S1 | 12 | 10 min | 7 |
| A1 | 10 | 10 min | 6 |
| A2 | 10 | 10 min | 6 |
| COMBO | 15 | 15 min | 9 |

### Punctaj per exercițiu
- ⭐ = 1 punct
- ⭐⭐ = 2 puncte
- ⭐⭐⭐ = 3 puncte
- ⭐⭐⭐⭐ = 4 puncte
- BONUS = puncte extra (nu contează pentru trecere)

---

## Auto-Evaluare Post-Sprint

După fiecare sprint, marchează:

```
□ Am reușit toate exercițiile de bază (⭐, ⭐⭐)
□ Am reușit exercițiile intermediare (⭐⭐⭐)
□ Am încercat/reușit BONUS
□ Am lucrat bine în pereche
□ Am înțeles soluțiile pe care nu le-am găsit singur
```

---

*Exerciții Sprint pentru Seminarul 7-8 de Sisteme de Operare | ASE București - CSIE*
