# Exerciții de verificare live — Seminar 04

> **Scop:** exerciții procedurale executate în timp real în laborator  
> **Durată:** 10–15 minute în total  
> **De ce:** AI poate genera soluții perfecte, dar nu le poate executa live pe date unice

---

## Filosofie

Problema temelor de acasă este simplă: studenții pot cere unui asistent AI să rezolve.
Chiar și cu date personalizate, pot descrie sarcina și pot obține cod funcțional.

Exercițiile live inversează situația: sarcina are loc ACUM, în ACEST terminal, cu date
care nu existau acum 30 de secunde. Nu există timp pentru consultarea AI. Ori stăpânești 
instrumentele, ori nu.

> *Pe șleau: anul trecut am văzut un student care a predat o temă impecabilă, 
> dar nu a putut rula `grep -c` în laborator. Conversația a fost... stânjenitoare.*

---

## Exercițiul L1: Provocarea „numărătoarea inversă”

**Timp:** 3 minute  
**Dificultate:** de bază  
**Testează:** `grep`, `wc` și pipeline‑uri simple

### Setup (instructorul rulează asta)
```bash
# Generate unique challenge file with timestamp
TIMESTAMP=$(date +%s)
mkdir -p /tmp/challenge_$$
cd /tmp/challenge_$$

# Create file with random content
for i in {1..50}; do
    echo "Line $i: $(shuf -n 1 /usr/share/dict/words 2>/dev/null || echo "word$i") status=$(shuf -e OK ERROR WARNING -n 1)"
done > challenge_${TIMESTAMP}.txt

echo "Challenge file: /tmp/challenge_$$/challenge_${TIMESTAMP}.txt"
echo "SECRET: $(grep -c ERROR challenge_${TIMESTAMP}.txt) errors"
```

### Sarcina (o dați studentului)
„Numără câte linii conțin `ERROR` în fișierul de provocare. Ai 60 de secunde.”

### Ce testezi, de fapt
- Poate construi `grep -c ERROR filename`?
- Intră în panică sau rămâne calm?
- Își verifică răspunsul?

### Notare
| Rezultat | Notă |
|--------|-------|
| Corect în 30s | Excelent |
| Corect în 60s | Bine |
| Corect cu indiciu („folosește -c”) | Trecut |
| Incorect sau depășire timp | Necesită practică |

---

## Exercițiul L2: Cursa transformărilor

**Timp:** 5 minute  
**Dificultate:** intermediar  
**Testează:** substituții `sed`

### Setup (instructorul rulează asta)
```bash
# Generate a config file with unique values
TIMESTAMP=$(date +%s)
mkdir -p /tmp/challenge_$$
cd /tmp/challenge_$$

cat > config_${TIMESTAMP}.txt << EOF
# Server configuration
server.host=localhost
server.port=$((8000 + RANDOM % 1000))
database.host=localhost
database.name=mydb_${TIMESTAMP}
debug.enabled=true
EOF

echo "File: /tmp/challenge_$$/config_${TIMESTAMP}.txt"
echo "SECRET port: $(grep server.port config_${TIMESTAMP}.txt | cut -d= -f2)"
```

### Sarcina (o dați studentului)
„Înlocuiește TOATE aparițiile lui `localhost` cu `127.0.0.1` și afișează rezultatul. 
Nu modifica fișierul original.”

### Soluție așteptată
```bash
sed 's/localhost/127.0.0.1/g' config_*.txt
```

### Greșeli frecvente de urmărit
- Uită `/g` (se înlocuiește doar prima apariție)
- Folosește `-i` (modifică fișierul, deși i s‑a cerut să nu)
- Complică inutil cu `awk`

---

## Exercițiul L3: Sprintul de agregare

**Timp:** 5 minute  
**Dificultate:** intermediar–avansat  
**Testează:** `awk`, tablouri asociative și calcule

### Setup (instructorul rulează asta)
```bash
TIMESTAMP=$(date +%s)
mkdir -p /tmp/challenge_$$
cd /tmp/challenge_$$

# Generate unique sales data
echo "product,quantity,price" > sales_${TIMESTAMP}.csv
for prod in Widget Gadget Gizmo; do
    for i in {1..5}; do
        qty=$((RANDOM % 20 + 1))
        price=$((RANDOM % 50 + 10))
        echo "$prod,$qty,$price"
    done
done >> sales_${TIMESTAMP}.csv

echo "File: /tmp/challenge_$$/sales_${TIMESTAMP}.csv"
echo "SECRET: $(awk -F, 'NR>1 {sum += $2 * $3} END {print sum}' sales_${TIMESTAMP}.csv) total revenue"
```

### Sarcina (o dați studentului)
„Calculează venitul TOTAL (cantitate × preț) din CSV. Sari peste antet.”

### Abordare așteptată
```bash
awk -F, 'NR > 1 { sum += $2 * $3 } END { print sum }' sales_*.csv
```

### Ce testezi, de fapt
- separator de câmp pentru CSV (`-F,`)
- omiterea antetului (`NR > 1`)
- aritmetică în `awk` (`$2 * $3`)
- bloc `END` pentru output final

---

## Exercițiul L4: Constructorul de pipeline‑uri

**Timp:** 7 minute  
**Dificultate:** avansat  
**Testează:** pipeline‑uri multi‑etapă și gândire critică

### Setup (instructorul rulează asta)
```bash
TIMESTAMP=$(date +%s)
mkdir -p /tmp/challenge_$$
cd /tmp/challenge_$$

# Generate fake access log
for i in {1..100}; do
    ip="192.168.$((RANDOM % 5 + 1)).$((RANDOM % 254 + 1))"
    echo "$ip - - [$(date)] "GET /page$((RANDOM % 10))" 200 $((RANDOM % 5000))"
done > access_${TIMESTAMP}.log

# Find the actual top IP for verification
TOP_IP=$(grep -oE '^[0-9.]+' access_${TIMESTAMP}.log | sort | uniq -c | sort -rn | head -1)
echo "File: /tmp/challenge_$$/access_${TIMESTAMP}.log"
echo "SECRET top IP: $TOP_IP"
```

### Sarcina (o dați studentului)
„Găsește adresa IP care apare CEL MAI FRECVENȚ în logul de acces. 
Afișează numărul de apariții și IP‑ul.”

### Abordare așteptată
```bash
grep -oE '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' access_*.log | sort | uniq -c | sort -rn | head -1
```

### Criterii de evaluare
1. Extragerea corectă a IP‑ului: +30%
2. `sort | uniq -c` corect: +30%
3. sortare descrescătoare pentru „cel mai frecvent”: +20%
4. output curat: +20%

---

## Exercițiul L5: Detectivul de bug‑uri

**Timp:** 5 minute  
**Dificultate:** variabilă (depinde de bug)  
**Testează:** înțelegere, nu doar memorare

### Setup
Luați ORICE soluție funcțională a unui student și introduceți un bug subtil:

**Exemple de bug:**
```bash
# Original (correct)
awk -F, 'NR > 1 {sum += $4} END {print sum}' file.csv

# Bugged versions:
awk -F, 'NR > 1 {sum += $3} END {print sum}' file.csv  # Wrong column
awk -F, 'NR >= 1 {sum += $4} END {print sum}' file.csv # Includes header  
awk -F, 'NR > 1 {sum = $4} END {print sum}' file.csv   # Assignment, not addition
awk -F: 'NR > 1 {sum += $4} END {print sum}' file.csv  # Wrong separator
```

### Sarcina
„Comanda aceasta ar trebui să calculeze salariul total, dar dă un rezultat greșit. 
Găsește și repară bug‑ul.”

### Ce testezi, de fapt
- poate citi cod critic?
- testează incremental?
- înțelege fiecare componentă?

---

## Rularea exercițiilor live

### Înainte de laborator
1. Pregătiți 2–3 exerciții din cele de mai sus
2. Testați scripturile de setup pe mașina dumneavoastră
3. Aveți cheile de răspuns pregătite, dar ascunse

### În timpul laboratorului
1. Proiectați terminalul (studenții văd cum generați datele)
2. Dați instrucțiuni verbale clare
3. Mergeți printre studenți — fără telefoane, fără alte tab‑uri
4. Cronometrați strict, dar corect

### După
- feedback verbal rapid: „Ai stăpânit grep, dar ai avut dificultăți la `NR` din awk”
- notați observații pentru ajustarea notei

---

## Acomodări

- **Timp suplimentar:** +50% pentru nevoi documentate
- **Exercițiu în perechi:** pentru studenți cu dificultăți, permiteți colaborarea la UN exercițiu
- **Mod de practică:** oferiți exerciții similare (date diferite) înainte de încercarea evaluată

---

## Opțiunea nucleară

Dacă suspectați copiere sistematică:

1. Deschideți codul predat la temă
2. Schimbați UN lucru (nume de variabilă sau numărul unei coloane)
3. „Fă să meargă cu această modificare”

Cine a scris codul poate face asta într‑un minut.
Cine a copiat are nevoie să înțeleagă mai întâi întregul program.

---

*Aceste exerciții au evoluat din 3 ani de depistare a copierilor. 
Componenta live este esențială — este singurul lucru pe care AI nu îl poate face în locul lor.*

*Ultima actualizare: ianuarie 2025*
