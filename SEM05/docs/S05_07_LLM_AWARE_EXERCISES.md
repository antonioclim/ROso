# S05_07 - Exerciții LLM-Aware: Evaluare în Era AI

> Sisteme de Operare | ASE București - CSIE  
> Seminar 9-10: Advanced Bash Scripting
> Versiune: 2.0.0 | Data: 2025-01

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

## Ghid pentru Instructor

### Integrare în Evaluare

| Tip Exercițiu | Pondere Recomandată | Mod Evaluare |
|---------------|---------------------|--------------|
| Explain Code | 25% | Oral sau scris |
| Predict Output | 20% | Quiz, examen |
| Debug & Fix | 20% | Practic |
| Code Review | 15% | Peer review |
| Trace Execution | 10% | Scris |
| Transfer | 10% | Proiect |

### Detectare Utilizare AI

Semnale de alarmă:
- Cod perfect dar nu poate explica
- Stiluri inconsistente (varname vs variableName)
- Folosește features pe care nu le-am predat
- Comentarii "too perfect"
- Nu poate face modificări minore live

---

*Material de laborator pentru cursul de Sisteme de Operare | ASE București - CSIE*
