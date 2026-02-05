# S05_07 - Exerciții LLM-Aware: Evaluare în Era AI

> Sisteme de Operare | ASE București - CSIE  
> Seminar 5: Scripting Bash avansat
> Versiune: 2.1.0 | Data: 2025-01

---

## Filosofia LLM-Aware

În era ChatGPT/Claude/Copilot, evaluarea tradițională ("scrie un script care...") devine problematică. Studenții pot genera cod funcțional fără să înțeleagă ce face.

### Strategii de Evaluare Rezistente la LLM

| Strategie | Descriere | Eficacitate |
|-----------|-----------|-------------|
| Explain Code | Explică cod existent | ⭐⭐⭐⭐⭐ |
| Predict Output | Ce va afișa acest cod? | ⭐⭐⭐⭐⭐ |
| Debug & Fix | Găsește și repară bug-uri | ⭐⭐⭐⭐ |
| Code Review | Critică și îmbunătățește | ⭐⭐⭐⭐ |
| Trace Execution | Urmărește pas cu pas | ⭐⭐⭐⭐ |
| Transfer Knowledge | Aplică în context nou | ⭐⭐⭐ |

---

## Exercițiu Tip 1: EXPLAIN CODE

### E1.1: Explică Funcția

Cod de analizat:
```bash
process() {
    local -n ref=$1
    local count=0
    for item in "${ref[@]}"; do
        [[ "$item" =~ ^[0-9]+$ ]] && ((count++))
    done
    echo $count
}
```

Întrebări:
1. Ce face `local -n ref=$1`? (2p)
2. Ce verifică regex-ul `^[0-9]+$`? (2p)
3. Care e scopul variabilei `count`? (1p)
4. De ce folosim `local` pentru ambele variabile? (2p)
5. Ce returnează funcția și cum? (2p)
6. Scrie un exemplu de apel al funcției cu output. (1p)

<details>
<summary>📋 Răspunsuri Așteptate</summary>

1. `local -n ref=$1` - Creează o referință (nameref) la array-ul al cărui nume e pasat ca $1. Permite funcției să lucreze cu array-ul original prin alias.

2. `^[0-9]+$` - Verifică dacă string-ul conține DOAR cifre (de la început ^ la sfârșit $, una sau mai multe +).

3. `count` - Numără câte elemente din array sunt numere pure (doar cifre).

4. `local` - Previne modificarea variabilelor globale; `ref` și `count` există doar în scope-ul funcției.

5. Returnează numărul de elemente numerice prin `echo`. Capturare: `result=$(process arr_name)`

6. Exemplu:
```bash
arr=("hello" "42" "world" "123" "7")
process arr    # Output: 3
```

</details>

---

### E1.2: Explică Pattern-ul

Cod de analizat:
```bash
: "${API_KEY:?Error: API_KEY must be set}"
: "${DB_HOST:?Error: DB_HOST must be set}"
: "${OPTIONAL_VAR:=default_value}"
```

Întrebări:
1. Ce face comanda `:` (colon)? (1p)
2. Ce diferență e între `:?` și `:=`? (3p)
3. Ce se întâmplă dacă API_KEY nu e setat? (2p)
4. Ce se întâmplă dacă OPTIONAL_VAR nu e setat? (2p)
5. De ce acest pattern e util cu `set -u`? (2p)

<details>
<summary>📋 Răspunsuri Așteptate</summary>

1. `:` - Comandă null/no-op. Nu face nimic dar evaluează argumentele. Exit code întotdeauna 0.

2. `:?` - Dacă variabila e nesetată/goală, afișează mesajul de eroare și TERMINĂ scriptul.
   `:=` - Dacă variabila e nesetată/goală, o SETEAZĂ la valoarea dată și continuă.

3. API_KEY nesetat - Script se oprește cu mesajul "Error: API_KEY must be set"

4. OPTIONAL_VAR nesetat - Se setează automat la "default_value" și scriptul continuă

5. Cu `set -u` - Fără aceste pattern-uri, orice referință la variabile nesetate ar cauza eroare. Acest pattern permite verificare/setare ÎNAINTE de utilizare.

</details>

---

## Exercițiu Tip 2: PREDICT OUTPUT

### E2.1: Arrays și Iterare

```bash
#!/bin/bash
arr=("one two" "three")

echo "Test 1:"
for i in ${arr[@]}; do echo "- $i"; done

echo "Test 2:"
for i in "${arr[@]}"; do echo "- $i"; done

echo "Test 3:"
echo "Count: ${#arr[@]}"
```

Ce afișează acest script?

<details>
<summary>📋 Output Corect</summary>

```
Test 1:

Pe scurt: one; two; three.

Test 2:
- one two
- three
Test 3:
Count: 2
```

Explicație:
- Test 1: Fără ghilimele → word splitting → "one two" devine 2 elemente
- Test 2: Cu ghilimele → elementele rămân intacte
- Test 3: Array-ul are 2 elemente (nu 3!)

</details>

---

### E2.2: set -e și Condiții

```bash
#!/bin/bash
set -e

check() {
    false
    echo "In check"
}

echo "Start"

if check; then
    echo "Check passed"
else
    echo "Check failed"
fi

echo "End"
```

Predicții:
1. Ce linii se afișează?
2. De ce?

<details>
<summary>📋 Output Corect</summary>

```
Start
In check
Check failed
End
```

Explicație:
- `set -e` NU funcționează în context de test (if)
- `false` în funcție NU oprește scriptul
- `echo "In check"` SE execută
- Funcția returnează 0 (de la echo), dar... 
- Capcană: Funcția returnează ultimul exit code, care e 0 de la echo
- Deci check "trece"!

Corecție: Dacă vrem ca check să eșueze:
```bash
check() {
    false
    # fără echo după false
}
# SAU
check() {
    return 1
}
```

</details>

---

### E2.3: Variabile Locale și Globale

```bash
#!/bin/bash

x=10

modify() {
    x=20
    local y=30
    echo "In function: x=$x, y=$y"
}

echo "Before: x=$x"
modify
echo "After: x=$x, y=${y:-unset}"
```

Ce afișează?

<details>
<summary>📋 Output Corect</summary>

```
Before: x=10
In function: x=20, y=30
After: x=20, y=unset
```

Explicație:
- `x` e global → modificarea din funcție persistă
- `y` e local → nu există în afara funcției
- `${y:-unset}` → afișează "unset" pentru că y nu e definit

</details>

---

## Exercițiu Tip 3: DEBUG & FIX

### E3.1: Găsește 5 Bug-uri

```bash
#!/bin/bash

# Script pentru procesare fișiere
FILES=$(ls *.txt)

config[input]="data"
config[output]="results"

process() {
    count=0
    for file in $FILES; do
        count=$count+1
        echo "Processing $file"
    done
    return $count
}

result=process
echo "Processed $result files"
```

Identifică și corectează toate bug-urile:

<details>
<summary>📋 Bug-uri și Corecții</summary>

Bug 1: Lipsește `set -euo pipefail`
```bash
# Adaugă la început:
set -euo pipefail
```

Bug 2: `FILES=$(ls *.txt)` - Nu funcționează cu spații în nume
```bash
# Corect:
FILES=(*.txt)
# sau
mapfile -t FILES < <(find . -name "*.txt")
```

Bug 3: `config` fără `declare -A`
```bash
# Corect:
declare -A config
config[input]="data"
config[output]="results"
```

Bug 4: `count=$count+1` - concatenare string, nu aritmetică
```bash
# Corect:
((count++))
# sau
count=$((count + 1))
```

Bug 5: `result=process` - nu apelează funcția
```bash
# Corect:
result=$(process)
```

Bug 6 (bonus): `return $count` - count poate fi > 255
```bash
# Corect: folosește echo pentru valori mari
echo $count
# și capturează cu $(...)
```

Versiune corectată:
```bash
#!/bin/bash
set -euo pipefail

FILES=(*.txt)

declare -A config
config[input]="data"
config[output]="results"

process() {
    local count=0
    for file in "${FILES[@]}"; do
        ((count++))
        echo "Processing $file" >&2
    done
    echo $count
}

result=$(process)
echo "Processed $result files"
```

</details>

---

### E3.2: De Ce Nu Funcționează?

Situație: Studentul raportează că script-ul "nu face nimic":

```bash
#!/bin/bash
set -euo pipefail

echo "Starting backup..."
cd /backup/location
tar -czf backup.tar.gz /home/user/documents
echo "Backup complete!"
```

Rulare:
```bash
$ ./backup.sh
Starting backup...
$
```

Întrebări:
1. De ce nu apare "Backup complete!"? (2p)
2. De ce nu apare nicio eroare? (2p)
3. Cum ai diagnostica problema? (3p)
4. Cum ai repara scriptul? (3p)

<details>
<summary>📋 Răspunsuri</summary>

1. De ce nu apare: `cd /backup/location` probabil eșuează (directorul nu există), și cu `set -e` scriptul se oprește.

2. **De ce nu apare eroare:** `cd` eșuează SILENȚIOS (doar returnează exit code ≠ 0). `set -e` oprește scriptul dar nu afișează de ce.

3. Diagnosticare:
   ```bash
   # Adaugă debug
   set -x
   
   # Sau verifică explicit
   cd /backup/location || echo "cd failed!"
   
   # Sau verifică existență
   ls -la /backup/location
   ```

4. Reparare:
   ```bash
   #!/bin/bash
   set -euo pipefail
   
   BACKUP_DIR="/backup/location"
   
   echo "Starting backup..."
   
   [[ -d "$BACKUP_DIR" ]] || {
       echo "Error: $BACKUP_DIR does not exist" >&2
       exit 1
   }
   
   cd "$BACKUP_DIR"
   tar -czf backup.tar.gz /home/user/documents
   echo "Backup complete!"
   ```

</details>

---

## Exercițiu Tip 4: CODE REVIEW

### E4.1: Critică Acest Script

```bash
#!/bin/bash

# Process all log files
for f in `ls /var/log/*.log`
do
cat $f | grep ERROR | wc -l > /tmp/count
count=`cat /tmp/count`
echo "$f: $count errors"
rm /tmp/count
done
```

Cerință: 
Identifică cel puțin 7 probleme de stil/stabilitate și rescrie scriptul conform best practices.

<details>
<summary>📋 Review Complet</summary>

Probleme identificate:

1. ❌ Lipsește `set -euo pipefail`
2. ❌ Backticks în loc de `$(...)` (deprecated)
3. ❌ `ls` în loop - probleme cu spații
4. ❌ `$f` fără ghilimele
5. ❌ UUOC (Useless Use of Cat)
6. ❌ Fișier temporar hardcodat - race condition
7. ❌ Nu folosește `local` (dacă ar fi în funcție)
8. ❌ Nu curăță dacă script eșuează
9. ❌ Nu verifică dacă există fișiere .log

Versiune refactorizată:

```bash
#!/bin/bash
set -euo pipefail

readonly LOG_DIR="/var/log"

# Verifică că există fișiere
shopt -s nullglob
log_files=("$LOG_DIR"/*.log)
shopt -u nullglob

if [[ ${#log_files[@]} -eq 0 ]]; then
    echo "No log files found in $LOG_DIR" >&2
    exit 0
fi

for log_file in "${log_files[@]}"; do
    count=$(grep -c "ERROR" "$log_file" 2>/dev/null || echo 0)
    echo "$log_file: $count errors"
done
```

Îmbunătățiri:
- Strict mode
- Glob expansion în loc de ls
- Ghilimele corecte
- grep -c în loc de wc -l
- Handle pentru 0 matches
- Fără fișiere temporare
- Verificare existență fișiere

</details>

---

## Exercițiu Tip 5: TRACE EXECUTION

### E5.1: Urmărește Execuția

```bash
#!/bin/bash
set -euo pipefail

arr=(10 20 30)
sum=0

for ((i=0; i<${#arr[@]}; i++)); do
    sum=$((sum + arr[i]))
done

echo "Sum: $sum"
```

Completează tabelul de trace:

| Pas | i | arr[i] | sum (înainte) | sum (după) |
|-----|---|--------|---------------|------------|
| Init | - | - | - | 0 |
| 1 | | | | |
| 2 | | | | |
| 3 | | | | |
| End | | | | |

<details>
<summary>📋 Trace Complet</summary>

| Pas | i | arr[i] | sum (înainte) | sum (după) |
|-----|---|--------|---------------|------------|
| Init | - | - | - | 0 |
| 1 | 0 | 10 | 0 | 10 |
| 2 | 1 | 20 | 10 | 30 |
| 3 | 2 | 30 | 30 | 60 |
| End | 3 | - | 60 | 60 |

Output: `Sum: 60`

</details>

---

### E5.2: Trace cu Funcții

```bash
#!/bin/bash

outer() {
    local x=1
    echo "outer start: x=$x"
    inner
    echo "outer end: x=$x"
}

inner() {
    local x=2
    echo "inner: x=$x"
}

x=0
echo "main start: x=$x"
outer
echo "main end: x=$x"
```

Întrebări:
1. Desenează call stack-ul în momentul când suntem în `inner`
2. Ce valoare are `x` la fiecare `echo`?

<details>
<summary>📋 Soluție</summary>

Call Stack (în inner):
```
┌─────────────┐
│   inner     │  x=2 (local)
├─────────────┤
│   outer     │  x=1 (local)
├─────────────┤
│   main      │  x=0 (global)
└─────────────┘
```

Output complet:
```
main start: x=0
outer start: x=1
inner: x=2
outer end: x=1
main end: x=0
```

Explicație: Fiecare funcție are propriul `x` local, care "umbrește" pe cel din scope-ul superior.

</details>

---

## Exercițiu Tip 6: APLICARE ÎN CONTEXT NOU

### E6.1: Adaptare Template

Dat: Template-ul profesional standard (din kit).

Cerință: Adaptează template-ul pentru un script care:
- Primește o listă de URL-uri (din fișier sau stdin)
- Verifică fiecare URL cu `curl --head`
- Raportează status-ul (UP/DOWN)
- Salvează rezultatele într-un fișier

Evaluare:
- Folosire corectă a structurii template (3p)
- Argument parsing pentru fișier input (2p)
- Handling stdin vs fișier (2p)
- Cleanup resurse temporare (1p)
- Error handling pentru curl (2p)

---

## Exercițiu pentru Acasă cu LLM

### E7.1: Colaborare cu AI (Assignment)

Instrucțiuni:
1. Folosește ChatGPT/Claude pentru a genera un script care procesează CSV
2. Documentează EXACT ce prompts ai folosit
3. Analizează codul generat - identifică:

Trei lucruri contează aici: ce a făcut bine ai-ul?, ce a făcut greșit sau suboptimal?, și ce ai modificat și de ce?.

4. Scrie versiunea ta finală cu comentarii explicative

Criterii evaluare:
- Transparența procesului (3p)
- Calitatea analizei critice (4p)
- Îmbunătățirile aduse (3p)

Format submisie:
```
## Prompt-uri folosite
[...]

## Cod generat de AI
[...]

## Analiza mea
### Ce a făcut bine:
### Ce a făcut greșit:
### Ce am modificat:

## Versiunea mea finală
[cod cu comentarii]
```

---

### E7.3: Lanțul tău unic de hash-uri (avansat)

> ⚠️ **Rezistență maximă la AI:** acest exercițiu creează un lanț de verificare care este matematic unic pentru tine.

Creați un script care generează un cod de verificare personalizat:

```bash
#!/bin/bash
set -euo pipefail

# ═══════════════════════════════════════════════════════════════════
# PERSONALISATION REQUIRED — Use YOUR actual data
# ═══════════════════════════════════════════════════════════════════

STUDENT_ID="[YOUR_8_DIGIT_ID]"           # e.g., "12345678"
BIRTH_MONTH="[YOUR_BIRTH_MONTH_01-12]"   # e.g., "03"
YOUR_INITIALS="[FIRST_LAST]"             # e.g., "AC" for Antonio Clim

# ═══════════════════════════════════════════════════════════════════
# HASH CHAIN GENERATION — Do not modify this section
# ═══════════════════════════════════════════════════════════════════

echo "=== Personalised Verification Chain ==="
echo "Student: $YOUR_INITIALS ($STUDENT_ID)"
echo ""

# Step 1: Hash your student ID
STEP1=$(echo -n "$STUDENT_ID" | md5sum | cut -c1-8)
echo "Step 1 (ID hash):        $STEP1"

# Step 2: Combine with birth month and hash again
STEP2=$(echo -n "${STEP1}${BIRTH_MONTH}" | sha256sum | cut -c1-8)
echo "Step 2 (+ month hash):   $STEP2"

# Step 3: Add initials and encode
STEP3=$(echo -n "${STEP2}${YOUR_INITIALS}" | base64 | head -c12)
echo "Step 3 (+ initials b64): $STEP3"

# Final verification code
FINAL_CODE="${YOUR_INITIALS}-${STEP3}-$(echo -n "$STEP1$STEP2" | md5sum | cut -c1-4)"
echo ""
echo "════════════════════════════════════════"
echo "YOUR VERIFICATION CODE: $FINAL_CODE"
echo "════════════════════════════════════════"
echo ""
echo "This code MUST appear in your submission."
echo "Instructor can verify by re-running with your data."
```

**De ce „blochează” AI-ul:**
- lanțul de hash-uri depinde de date personale specifice (ale tale)
- valorile intermediare sunt criptografic imprevizibile
- un model nu poate ghici codul tău de verificare
- instructorul poate verifica autenticitatea prin re‑rulare cu ID-ul tău de student
- schimbarea oricărei intrări produce un cod complet diferit

**Cerință de predare:**
README-ul temei trebuie să includă:
```
## Verification Code
FINAL_CODE: [lipiți codul aici]
Generated on: [data și ora]
```

---


## Analiza unei lucrări reale de student (anonimizată)

> ⚠️ **Doar pentru instructori:** folosiți aceste studii de caz pentru a calibra „mirosul” de AI, fără a porni de la prezumția de vinovăție. Scopul este să separăm înțelegerea de copy‑paste.

### Cazul A: Cod perfect, explicație imposibilă

**Depunere:** Script impecabil, folosește `trap`, `set -euo pipefail`, funcții curate, fără bug-uri evidente.

**Oral:** studentul nu poate explica diferența dintre `"${arr[@]}"` și `"${arr[*]}"`.

**Întrebări de follow‑up pe care le puteți folosi:**
- „Arată-mi pe acest script unde ai folosit array asociativ și de ce.”
- „Ce se întâmplă dacă fișierul de input are spații în nume?”
- „De ce folosești `local` aici? Ce se întâmplă dacă îl scoți?”

**Dialog tipic:**
```
Instructor: Explain what this line does: for item in "${arr[@]}"; do
Student: It loops through the array.
Instructor: Okay, what is the difference if I write: for item in "${arr[*]}"; do ?
Student: ... (silence)
Instructor: What would happen if one element contains spaces?
Student: It should still work.
Instructor: (it won't)
```

**Semnal puternic:** codul e „mai bun” decât nivelul de conversație al studentului.

---

### Cazul B: Stil neconcordant (variabile în română, comentarii în engleză)

**Depunere:** variabile de tip `numar_linii`, `fisier_intrare`, dar comentarii de forma `# parse the file` și mesaje de output impecabil în engleză.

**Probabilitate:** studentul a generat cu AI și a făcut editări minimale (de obicei numele variabilelor).

**Test rapid:**
1. Cereți să schimbe un mesaj de output și să explice unde îl găsește.
2. Cereți să introducă intenționat o eroare și apoi să o repare.
3. Cereți să adauge un `echo` de debug într-o zonă specifică.

**Dialog tipic:**
```
Instructor: Add a debug echo before the loop that prints the array size.
Student: (scrolling, confused) Where is the loop?
Instructor: It's here: for ((i=0; i<...; i++))
Student: Oh... I didn't write this part.
```

---

### Diferențiatori cheie (în practică)

**Semnale de comportament:**
- nu poate explica pattern-uri regex pe care „le-a scris”
- folosește termeni tehnici incorect
- devine defensiv când este întrebat despre linii specifice
- „am găsit online” pentru logica principală

**Semnale structurale:**
- structură perfect paralelă a funcțiilor
- formatare identică a mesajelor de eroare peste tot
- lipsesc experimentele (cod mort, comentarii de tip „încercare”)
- README-ul are exact același stil ca și codul

---

## Ghid pentru Instructor

### Integrare în evaluare

Aceste exerciții sunt proiectate să fie compatibile cu orice rubrică orientată pe înțelegere. Recomandări:

- Folosiți întrebările de tip „Explain / Predict / Trace” în timpul seminarului (evaluare formativă).
- Folosiți E7.* (personalizate) pentru autenticitate în temă.
- Pentru suspiciuni: începeți cu întrebări tehnice punctuale, nu cu acuzații.

### Detectare utilizare AI — listă extinsă

**Semnale de conținut:**
- folosește termeni prea „perfecți” pentru nivel (de ex. „idempotent”, „orthogonal”), fără să îi poată explica
- include funcționalități pe care nu le-a cerut nimeni („overengineering”)
- cod fără urme de explorare (0 print-uri, 0 comentarii de lucru, 0 încercări)

**Semnale de coerență:**
- variabile în română, dar comentarii și mesaje de eroare în engleză, extrem de consistente
- stilul README-ului nu seamănă cu stilul codului (ex. README impecabil, cod haotic — sau invers)

**Semnale de proces:**
- nu poate explica *de ce* a ales un anumit pattern (`trap`, arrays asociative etc.)
- nu poate modifica live o secțiune mică fără să „înghețe”
- există diferență majoră între performanța din clasă și tema predată

### Protocol recomandat de răspuns

1. **Documentați observațiile** — linii concrete, comportamente concrete
2. **Puneți întrebări din ce în ce mai specifice** — fără acuzații
3. **Cereți modificare live** — studenții autentici se adaptează; cei care copiază se blochează
4. **Comparați cu munca din clasă** — diferențe dramatice sunt un semnal
5. **Consultați colegi** — cereți o a doua opinie înainte de escaladare

---

## Istoric document

| Versiune | Dată | Modificări |
|---------|------|------------|
| 2.1.0 | Ian 2025 | Adăugat E7.3 (lanț de hash-uri), studii de caz reale |
| 2.0.0 | Ian 2025 | Rescriere completă pentru era AI |
| 1.0.0 | Sep 2023 | Versiune inițială |

---

## Suport

Întrebări: forumul disciplinei sau orele de consultații  
Probleme legate de materiale: folosiți canalul oficial al disciplinei (forum/issue tracker intern)

---

*Material de laborator pentru cursul de Sisteme de Operare | ASE București - CSIE*

## Tip de exercițiu 7: DEPANARE PERSONALIZATĂ (NOU)

> ⚠️ **Strategie anti‑AI:** aceste exerciții folosesc datele VOASTRE unice. Un model nu poate genera „ID-ul tău” sau data ta de naștere.

### E7.1: Vânătoarea de bug-uri de ziua ta

Folosind ID-ul vostru de student și data voastră de naștere, creați și depanați un script:

```bash
#!/bin/bash
set -euo pipefail

# ═══════════════════════════════════════════════════════════════════
# PERSONALISATION REQUIRED
# Replace the placeholders with YOUR actual data
# ═══════════════════════════════════════════════════════════════════

STUDENT_ID="[YOUR_FULL_STUDENT_ID]"         # e.g., "12345678"
BIRTH_DAY="[YOUR_BIRTH_DAY_01-31]"          # e.g., "15"
BIRTH_MONTH="[YOUR_BIRTH_MONTH_01-12]"      # e.g., "03"

# Extract last 2 digits of student ID for array size
ARRAY_SIZE="${STUDENT_ID: -2}"

# Create array with that many elements
declare -a items
for ((i=0; i<ARRAY_SIZE; i++)); do
    items+=("item_$i")
done

# ═══════════════════════════════════════════════════════════════════
# BUG ZONE: There are 3 bugs below. Find and fix them.
# ═══════════════════════════════════════════════════════════════════

# Bug 1: Something wrong with this index calculation
target_index=$((BIRTH_MONTH + BIRTH_DAY))

# Bug 2: This access might fail
echo "Element at combined index: ${items[$target_index]}"

# Bug 3: This loop has a quoting issue
for item in ${items[@]}; do
    if [[ $item == item_${BIRTH_DAY} ]]; then
        echo "Found your birthday item!"
    fi
done

echo "Total items: ${#items[@]}"
echo "Your personalised checksum: $((STUDENT_ID % 97))"
```

**Sarcini:**
1. Completați ID-ul vostru real de student și data de naștere
2. Identificați cele 3 bug-uri
3. Explicați DE CE fiecare este un bug
4. Corectați fiecare bug
5. Rulați scriptul și atașați output-ul vostru personalizat

**Format de predare așteptat:**
```
Student ID: [ID-ul vostru]
Birthdate: [ZZ/LL]

Bug 1: [descriere]
  - De ce e greșit: [explicație]
  - Fix: [linia corectată]

Bug 2: [descriere]
  - De ce e greșit: [explicație]  
  - Fix: [linia corectată]

Bug 3: [descriere]
  - De ce e greșit: [explicație]
  - Fix: [linia corectată]

My output:
[lipiți aici output-ul terminalului]
```

**De ce funcționează împotriva AI:**
- fiecare student are parametri unici → dimensiuni de array unice, indecși unici
- un model nu poate prezice „output-ul tău” fără să cunoască ID-ul tău de student
- bug-urile interacționează cu date personale, deci fix-urile trebuie să fie dependente de context
- checksum-ul de la final verifică faptul că ați rulat efectiv codul

---

### E7.2: Fișier de configurare cu inițialele tale

Creați un manager de configurație care folosește inițialele voastre și ID-ul de student:

```bash
#!/bin/bash
set -euo pipefail

# ═══════════════════════════════════════════════════════════════════
# PERSONALISATION REQUIRED
# ═══════════════════════════════════════════════════════════════════

YOUR_INITIALS="[FIRST_LAST_INITIALS]"    # e.g., "AC" for Antonio Clim
STUDENT_ID="[YOUR_STUDENT_ID]"

# Config file path uses your initials
CONFIG_FILE="/tmp/${YOUR_INITIALS}_${STUDENT_ID}.conf"

# ═══════════════════════════════════════════════════════════════════
# IMPLEMENT THESE FUNCTIONS
# ═══════════════════════════════════════════════════════════════════

# Function 1: Create config with YOUR data as defaults
init_config() {
    # TODO: Create CONFIG_FILE with these keys:
    # OWNER=[your initials]
    # ID=[your student ID]
    # CREATED=[current timestamp]
    # CUSTOM_PORT=[last 4 digits of student ID]
    :  # Replace with your implementation
}

# Function 2: Get a value (return via echo)
get_config() {
    local key="$1"
    # TODO: Return value for given key from CONFIG_FILE
    :  # Replace with your implementation
}

# Function 3: Set a value
set_config() {
    local key="$1"
    local value="$2"
    # TODO: Update or add key=value in CONFIG_FILE
    :  # Replace with your implementation
}

# ═══════════════════════════════════════════════════════════════════
# TEST SEQUENCE (do not modify)
# ═══════════════════════════════════════════════════════════════════

echo "=== Personalised Config Manager Test ==="
echo "Student: ${YOUR_INITIALS} (${STUDENT_ID})"
echo ""

init_config
echo "1. Config created at: $CONFIG_FILE"

echo "2. Owner is: $(get_config OWNER)"
echo "3. Custom port is: $(get_config CUSTOM_PORT)"

set_config "MODIFIED_BY" "${YOUR_INITIALS}"
set_config "TIMESTAMP" "$(date +%s)"

echo "4. Full config contents:"
cat "$CONFIG_FILE"

echo ""
echo "5. Verification hash: $(md5sum "$CONFIG_FILE" | cut -d' ' -f1)"
```

**De ce funcționează împotriva AI:**
- calea fișierului de configurare este unică pentru fiecare student
- output-ul include inițialele și ID-ul — ușor de verificat autenticitatea
- hash-ul MD5 de la final dovedește că scriptul a rulat cu datele VOASTRE specifice
- funcțiile trebuie să gestioneze structura voastră concretă de date

---
