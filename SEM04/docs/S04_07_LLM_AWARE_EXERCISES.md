# LLM-Aware Exercises: Text Processing
## Exerciții de Evaluare Critică a Rezultatelor AI

> Observație din laborator: dacă folosești un LLM, tratează-l ca pe un coleg care îți explică, nu ca pe un autopilot. Cere-i să justifice pașii, apoi validează cu o comandă minimă (`--help`, `man`, un test mic). În laborator se vede imediat diferența între „am înțeles” și „am lipit”.
> Sisteme de Operare | Academia de Studii Economice București - CSIE  
> Seminar 4 | LLM-Integrated Learning  
> Scop: Dezvoltarea gândirii critice în era AI

---

## De Ce Exerciții LLM-Aware?

### Contextul Actual

În 2025, studenții au acces la LLM-uri (ChatGPT, Claude, Gemini) care pot genera cod. Aceasta este o realitate pe care educația trebuie să o îmbrățișeze, nu să o ignore.

### Obiective

```
┌─────────────────────────────────────────────────────────────────────────┐
│  🎯 OBIECTIVE LLM-AWARE                                                │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  1. EVALUARE CRITICĂ                                                    │
│     Studenții învață să verifice, nu să accepte orbește                │
│                                                                         │
│  2. DEBUGGING AI OUTPUT                                                 │
│     Identificarea și corectarea erorilor în cod generat                │
│                                                                         │
│  3. OPTIMIZARE                                                          │
│     Îmbunătățirea soluțiilor generate                                  │
│                                                                         │
│  4. ÎNȚELEGERE PROFUNDĂ                                                 │
│     Nu poți evalua ce nu înțelegi                                      │
│                                                                         │
│  5. PROMPT ENGINEERING                                                  │
│     Formularea cerințelor clare pentru rezultate mai bune              │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### Filozofie

> "LLM-ul este un instrument, nu un înlocuitor. Un mecanic prost cu scule bune tot un mecanic prost rămâne."

---

## Instrucțiuni Generale

Pentru fiecare exercițiu:

1. Primești un output generat de un LLM (real sau simulat)
2. Analizezi corectitudinea și calitatea
3. Testezi pe datele furnizate
4. Identifici problemele (dacă există)
5. Îmbunătățești soluția

---

# EXERCIȚIUL 1: REGEX VALIDATION

> *Observație din experiență: studenții care testează regex-ul în regex101.com înainte să-l pună în script au de 3-4 ori mai puține erori. Ia-ți 30 de secunde extra pentru verificare — merită.*

## Context
Un student a cerut unui LLM: "Generează un regex pentru validarea email-urilor în bash cu grep"

## Output LLM (Simulat)

```bash
# Regex pentru email generat de AI:
grep -E "^[a-zA-Z0-9]+@[a-zA-Z]+\.[a-zA-Z]+$" emails.txt
```

## Date de Test

```bash
# Creează fișierul de test
cat > test_emails.txt << 'EOF'
john.doe_AT_example_DOT_com
invalid-email
user_AT_domain_DOT_co_DOT_uk
alice_wonder_AT_gmail_DOT_com
test@test
user.name+tag_AT_domain_DOT_org
@nodomain.com
noat.com
simple_AT_test_DOT_io
123_AT_numbers_DOT_com
EOF
```

## Sarcini

### L1.1: Testează Soluția AI (3 min)

```bash
# Rulează comanda AI pe datele de test
grep -E "^[a-zA-Z0-9]+@[a-zA-Z]+\.[a-zA-Z]+$" test_emails.txt
```

Întrebări:
1. Ce email-uri valide sunt OMISE?
2. Ce email-uri invalide sunt ACCEPTATE?

<details>
<summary>📝 Răspunsuri</summary>

OMISE (false negatives):
- `john.doe_AT_example_DOT_com` - are punct în local part
- `user_AT_domain_DOT_co_DOT_uk` - are două puncte în domeniu
- `alice_wonder_AT_gmail_DOT_com` - are `_`
- `user.name+tag_AT_domain_DOT_org` - are punct și plus

ACCEPTATE CORECT:
- `simple_AT_test_DOT_io`
- `123_AT_numbers_DOT_com` (parțial - depinde de interpretare)

Probleme majore ale regex-ului AI:
- Nu acceptă `.` în partea locală
- Nu acceptă `_` sau `+`
- Nu acceptă subdomenii (domain.co.uk)
</details>

### L1.2: Îmbunătățește Soluția (5 min)

Rescrie regex-ul pentru a accepta corect mai multe formate de email:

```bash
# Soluția ta îmbunătățită:

```

<details>
<summary>✅ Soluție Îmbunătățită</summary>

```bash
# Versiune îmbunătățită
grep -E "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$" test_emails.txt
```

Explicație îmbunătățiri:
- `[a-zA-Z0-9._%+-]+` - acceptă puncte, `_`, procent, plus, minus în local part
- `[a-zA-Z0-9.-]+` - acceptă puncte și minusuri în domeniu (pentru subdomenii)
- `[a-zA-Z]{2,}` - TLD de minim 2 caractere
</details>

### L1.3: Reflecție (2 min)

De ce a greșit LLM-ul?

<details>
<summary>💡 Analiză</summary>

LLM-urile tind să genereze soluții "simple" care funcționează pentru cazurile de bază dar nu acoperă edge cases. Motivele:
1. Prompt-ul nu a specificat cerințe detaliate
2. LLM-ul a preferat simplitatea
3. Nu a testat pe date diverse

Lecție: Mereu testează output-ul AI pe date variate!
</details>

---

# EXERCIȚIUL 2: SED TRANSFORMATION

## Context
Un student a cerut: "Folosește sed pentru a transforma un fișier de config din format key=value în format JSON"

## Output LLM (Simulat)

```bash
# Generat de AI:
sed 's/\(.*\)=\(.*\)/  "\1": "\2",/' config.txt
```

## Date de Test

```bash
cat > test_config.txt << 'EOF'
# Database configuration
db.host=localhost
db.port=5432

# App settings
app.name=MyApp
app.debug=true
app.timeout=30
EOF
```

## Sarcini

### L2.1: Identifică Problemele (3 min)

Rulează și observă output-ul:

```bash
sed 's/\(.*\)=\(.*\)/  "\1": "\2",/' test_config.txt
```

Ce probleme observi?

<details>
<summary>📝 Probleme Identificate</summary>

1. Comentariile sunt procesate - liniile cu # generează output invalid
2. Liniile goale - generează linii cu doar `,`
3. Ultima linie - are virgulă în plus (invalid JSON)
4. Lipsește structura JSON - nu are `{` și `}`
5. Valori numerice/boolean - sunt tratate ca stringuri
</details>

### L2.2: Corectează Soluția (7 min)

Creează o soluție completă care:
- Ignoră comentarii și linii goale
- Generează JSON valid
- Tratează ultima virgulă

```bash
# Soluția ta:

```

<details>
<summary>✅ Soluție Corectă</summary>

```bash
echo "{"
sed '/^#/d; /^$/d' test_config.txt | \
sed 's/\(.*\)=\(.*\)/  "\1": "\2",/' | \
sed '$ s/,$//'
echo "}"
```

Sau mai elegant cu awk:

```bash
awk -F'=' '
BEGIN { print "{" }
/^#/ || /^$/ { next }
{ 
    if (NR > 1 && prev) print prev ","
    prev = sprintf("  \"%s\": \"%s\"", $1, $2)
}
END { 
    if (prev) print prev
    print "}"
}' test_config.txt
```
</details>

### L2.3: Prompt Engineering (2 min)

Rescrie prompt-ul pentru a obține o soluție mai bună de la LLM:

<details>
<summary>💡 Prompt Îmbunătățit</summary>

```
Generează o comandă sed sau awk care transformă un fișier de configurare 
(format key=value) în JSON valid. Cerințe:
1. Ignoră liniile care încep cu # (comentarii)
2. Ignoră liniile goale
3. Output-ul trebuie să fie JSON valid (fără virgulă după ultima pereche)
4. Structura: { "key1": "value1", "key2": "value2" }
5. Folosește doar utilitare standard Unix (sed, awk, etc.)

Exemplu input:
# comment
key1=value1
key2=value2

Exemplu output:
{
  "key1": "value1",
  "key2": "value2"
}
```
</details>

---

# EXERCIȚIUL 3: AWK AGGREGATION

## Context
Un student a cerut: "Scrie o comandă awk care calculează statistici din un CSV de vânzări"

## Output LLM (Simulat)

```bash
# Generat de AI:
awk -F',' '{sum+=$3} END{print "Total: " sum}' sales.csv
```

## Date de Test

```bash
cat > test_sales.csv << 'EOF'
Date,Product,Quantity,Price
2025-01-01,Widget,10,25.50
2025-01-01,Gadget,5,45.00
2025-01-02,Widget,8,25.50
2025-01-02,Gadget,12,45.00
2025-01-03,Widget,15,25.50
EOF
```

## Sarcini

### L3.1: Evaluează Corectitudinea (3 min)

```bash
awk -F',' '{sum+=$3} END{print "Total: " sum}' test_sales.csv
```

Ce probleme are această soluție?

<details>
<summary>📝 Probleme</summary>

1. Include header-ul în calcul (Quantity e tratat ca 0, dar nu e curat)
2. Calculează doar suma cantităților - poate utilizatorul voia revenue
3. Nu validează datele - ce se întâmplă cu valori non-numerice?
4. Output minimal - doar un număr, fără context
</details>

### L3.2: Cerințe Neclare (2 min)

Ce statistici ar fi de fapt utile pentru date de vânzări?

Lista ta:
1. 
2. 
3. 
4. 
5. 

<details>
<summary>💡 Statistici Utile</summary>

1. Total revenue (Quantity × Price)
2. Cantitate totală vândută
3. Produs cu cele mai multe vânzări
4. Vânzări per zi
5. Medie revenue per tranzacție
6. Cel mai profitabil produs
</details>

### L3.3: Soluție Completă (7 min)

Creează un raport complet de vânzări:

```bash
# Soluția ta:

```

<details>
<summary>✅ Soluție Completă</summary>

```bash
awk -F',' '
NR == 1 { next }  # Skip header
{
    qty += $3
    revenue += $3 * $4
    product_qty[$2] += $3
    product_rev[$2] += $3 * $4
    daily[$1] += $3 * $4
    count++
}
END {
    print "=== SALES REPORT ==="
    print ""
    print "Overall Statistics:"
    printf "  Total Transactions: %d\n", count
    printf "  Total Quantity: %d units\n", qty
    printf "  Total Revenue: $%.2f\n", revenue
    printf "  Avg per Transaction: $%.2f\n", revenue/count
    print ""
    print "By Product:"
    for (p in product_qty)
        printf "  %s: %d units, $%.2f\n", p, product_qty[p], product_rev[p]
    print ""
    print "By Day:"
    for (d in daily)
        printf "  %s: $%.2f\n", d, daily[d]
}' test_sales.csv
```
</details>

---

# EXERCIȚIUL 4: PIPELINE DEBUGGING

## Context
Un student a generat cu AI un pipeline pentru analiza log-urilor dar nu funcționează.

## Output LLM (Cu Erori)

```bash
# "Găsește top 10 IP-uri cu erori 404 din access.log"
cat access.log | grep 404 | cut -d' ' -f1 | sort | unique -c | sort -n | head
```

## Sarcini

### L4.1: Găsește Toate Erorile (5 min)

Rulează comanda și identifică TOATE problemele:

```bash
cat access.log | grep 404 | cut -d' ' -f1 | sort | unique -c | sort -n | head
```

Erori găsite:
1. 
2. 
3. 
4. 
5. 

<details>
<summary>📝 Lista Erorilor</summary>

1. `UUOC` - Useless Use of Cat (`cat | grep` → `grep file`)
2. `unique` - Nu există! Comanda corectă e `uniq`
3. `grep 404` - Poate potrivi IP-uri care conțin 404
4. `sort -n` - Sortează crescător, dar vrem descrescător pentru "top"
5. `head` - OK, dar fără număr ia 10 (e OK pentru "top 10")
6. Ordine greșită - `uniq` trebuie să fie DUPĂ `sort`
</details>

### L4.2: Corectează Pipeline-ul (3 min)

```bash
# Pipeline corectat:

```

<details>
<summary>✅ Soluție Corectă</summary>

```bash
grep ' 404 ' access.log | awk '{print $1}' | sort | uniq -c | sort -rn | head -10
```

Sau:

```bash
awk '/ 404 / {print $1}' access.log | sort | uniq -c | sort -rn | head -10
```
</details>

---

# EXERCIȚIUL 5: PROMPT VS OUTPUT

## Context
Trei studenți au cerut LLM-ului aceeași sarcină cu prompt-uri diferite. Evaluează rezultatele.

## Sarcina
"Extrage toate URL-urile dintr-un fișier HTML"

### Prompt A (Vag)
"regex for urls"

Output A:
```bash
grep 'http' file.html
```

### Prompt B (Specific)
"Write a grep command to extract all URLs (http and https) from an HTML file"

Output B:
```bash
grep -oE 'https?://[^"]+' file.html
```

### Prompt C (Detaliat)
```
Write a grep command to extract all URLs from an HTML file.
Requirements:
- Match both http and https
- Extract only the URL, not surrounding text
- Handle URLs in href and src attributes
- Avoid matching partial URLs or false positives
Example input: <a href="https://example.com/page">Link</a>
Expected output: https://example.com/page
```

Output C:
```bash
grep -oE '(href|src)="https?://[^"]*"' file.html | grep -oE 'https?://[^"]*'
```

## Sarcini

### L5.1: Evaluează Fiecare (5 min)

| Output | Funcționează? | Probleme | Scor (1-10) |
|--------|---------------|----------|-------------|
| A | | | |
| B | | | |
| C | | | |

<details>
<summary>📝 Evaluare</summary>

| Output | Funcționează? | Probleme | Scor |
|--------|---------------|----------|------|
| A | Parțial | Nu extrage, doar afișează liniile; prinde și text cu "http" | 2/10 |
| B | Da | Poate include caractere nedorite; nu filtrează după context | 6/10 |
| C | Da | Bun, dar exclude URL-uri din JavaScript, CSS inline | 8/10 |
</details>

### L5.2: Prompt Perfect (3 min)

Scrie prompt-ul ideal pentru această sarcină:

```
[Prompt-ul tău aici]
```

<details>
<summary>💡 Prompt Exemplar</summary>

```
Create a bash one-liner using grep or sed to extract all valid URLs from an HTML file.

Technical requirements:
1. Match http:// and https:// protocols
2. Extract ONLY the URL (use -o flag or equivalent)
3. Handle URLs in:
   - href attributes: href="https://..."
   - src attributes: src="https://..."
   - Plain text URLs
4. Stop URL extraction at first whitespace, quote, or >
5. Output one URL per line
6. Eliminate duplicates

Input example:
<html>
<a href="https://example.com/page">Link</a>
<img src="https://cdn.example.com/image.png">
Visit https://another.com for more info.
</html>

Expected output:
https://another.com
https://cdn.example.com/image.png
https://example.com/page

Show the command and explain each part.
```
</details>

---

# EXERCIȚIUL 6: EVALUARE COMPLETĂ

## Context Final
Primești acest script generat de AI pentru "procesarea unui CSV cu date de studenți".

```bash
#!/bin/bash
# Student grades processor (AI Generated)

cat students.csv | grep -v "^Name" | awk -F',' '{
    sum += $3
    if ($3 > 90) print $1 " - Excellent"
    if ($3 > 70) print $1 " - Good"  
    if ($3 > 50) print $1 " - Pass"
    else print $1 " - Fail"
} END {
    print "Average: " sum/NR
}'
```

## Date de Test

```bash
cat > students.csv << 'EOF'
Name,ID,Grade
Alice,101,95
Bob,102,72
Carol,103,45
David,104,88
Eve,105,65
EOF
```

## Sarcini Finale

### L6.1: Code Review Complet (5 min)

Găsește TOATE problemele (minim 5):

1. 
2. 
3. 
4. 
5. 
6. 

<details>
<summary>📝 Toate Problemele</summary>

1. UUOC - `cat file | grep` ineficient
2. Logic greșită - if-urile nu sunt else-if, Alice apare de 3 ori!
3. Header processing - `grep -v "^Name"` funcționează, dar e fragil
4. NR în END - NR include toate liniile, nu doar cele procesate
5. Nicio validare - ce dacă Grade nu e număr?
6. Shebang - OK, dar lipsește `set -euo pipefail`
7. Nu e portabil - presupune GNU awk
</details>

### L6.2: Rescrie Corect (10 min)

```bash
#!/bin/bash
# Versiunea ta corectă:

```

<details>
<summary>✅ Soluție Corectă</summary>

```bash
#!/bin/bash
set -euo pipefail

awk -F',' '
NR == 1 { next }  # Skip header
{
    name = $1
    grade = $3
    sum += grade
    count++
    
    if (grade > 90) status = "Excellent"
    else if (grade > 70) status = "Good"
    else if (grade > 50) status = "Pass"
    else status = "Fail"
    
    printf "%s (ID: %s) - %d - %s\n", name, $2, grade, status
}
END {
    if (count > 0)
        printf "\nAverage Grade: %.2f\n", sum/count
    else
        print "No students found"
}' students.csv
```
</details>

---

## Rubrica de Evaluare LLM-Aware

| Criteriu | Puncte | Descriere |
|----------|--------|-----------|
| Identificare erori | 30% | Găsirea problemelor în output-ul AI |
| Corectare | 30% | Fixarea erorilor identificate |
| Îmbunătățire | 20% | Optimizare dincolo de corectare |
| Prompt engineering | 10% | Reformularea cerințelor |
| Explicație | 10% | Înțelegerea motivelor erorilor |

---

## Takeaways

```
┌─────────────────────────────────────────────────────────────────────────┐
│  💡 LECȚII CHEIE                                                        │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  1. LLM-urile generează cod PLAUZIBIL, nu neapărat CORECT              │
│                                                                         │
│  2. MEREU testează pe date diverse, inclusiv edge cases                │
│                                                                         │
│  3. Un prompt mai bun = un output mai bun                              │
│                                                                         │
│  4. Înțelegerea conceptelor e esențială pentru evaluare                │
│                                                                         │
│  5. LLM = asistent, nu înlocuitor pentru gândire critică               │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

*LLM-Aware Exercises pentru Seminarul 7-8 de Sisteme de Operare | ASE București - CSIE*
