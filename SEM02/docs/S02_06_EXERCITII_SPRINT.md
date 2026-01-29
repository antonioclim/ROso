# Exerciții Sprint - Seminarul 3-4
## Sisteme de Operare | Operatori, Redirecționare, Filtre, Bucle

Versiune: 1.0 | Durată totală disponibilă: ~45 minute din seminar  
Filozofie: Învățare activă prin practică cronometrată și feedback imediat

---

## DESPRE EXERCIȚIILE SPRINT

### Ce Sunt Sprint-urile?

Sprint-urile sunt exerciții **cronometrate** (5-15 minute) care:
- Consolidează conceptele imediat după prezentare
- Creează urgență productivă (focalizare maximă)
- Oferă feedback imediat (verificare la final)
- Permit pair programming pentru învățare colaborativă

### Reguli Generale

```
╔════════════════════════════════════════════════════════════════════╗
║  ⏱️  REGULI SPRINT                                                 ║
╠════════════════════════════════════════════════════════════════════╣
║  1. Timer-ul pornește când instructorul spune "START"              ║
║  2. NU întrebi instructorul - folosești manualul/colegii           ║
║  3. Dacă termini devreme → ajută pe altcineva SAU fă bonus         ║
║  4. La "STOP" → oprești imediat și verifici                        ║
║  5. Pair Programming: switch driver/navigator la jumătatea timpului║
╚════════════════════════════════════════════════════════════════════╝
```

### Niveluri de Dificultate

| Simbol | Nivel | Timp Tipic | Descriere |
|--------|-------|------------|-----------|
| ⭐ | Începător | 5 min | Un singur concept, sintaxă de bază |
| ⭐⭐ | Intermediar | 8-10 min | Combinare 2-3 concepte |
| ⭐⭐⭐ | Avansat | 12-15 min | Integrare multiplă, edge cases |
| ⭐⭐⭐⭐ | Expert | 15+ min | Proiecte mini complete |

---

## SPRINT-URI OPERATORI DE CONTROL

### SPRINT O1: Comanda Sigură
Timp: 5 min | Mod: Individual | Puncte: 10

```
╔════════════════════════════════════════════════════════════════════╗
║  🏃 SPRINT O1: COMANDA SIGURĂ                                      ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  OBIECTIV: Scrie o comandă ONE-LINER care:                         ║
║                                                                    ║
║  1. Creează directorul "backup" (dacă nu există)                   ║
║  2. Copiază fișierul "data.txt" în backup/                         ║
║  3. Afișează "✓ Backup complet" DOAR dacă totul a reușit           ║
║  4. Afișează "✗ Eroare la backup" dacă ceva eșuează                ║
║                                                                    ║
║  ─────────────────────────────────────────────────────────────────  ║
║  SETUP (rulează întâi):                                            ║
║                                                                    ║
║    echo "date foarte importante" > data.txt                        ║
║                                                                    ║
║  ─────────────────────────────────────────────────────────────────  ║
║  VERIFICARE:                                                       ║
║                                                                    ║
║    1. Rulează comanda ta → trebuie să vezi "Backup complet"        ║
║    2. rm -rf backup && rulează din nou → "Backup complet"          ║
║    3. rm data.txt && rulează → "Eroare la backup"                  ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

💡 Soluție (pentru instructor):
```bash
mkdir -p backup && cp data.txt backup/ && echo "✓ Backup complet" || echo "✗ Eroare la backup"
```

🎯 Criterii evaluare:
- [3p] mkdir -p (sau mkdir cu verificare)
- [3p] && între comenzi (nu ;)
- [2p] || pentru eroare
- [2p] Mesaje corecte

---

### SPRINT O2: Proces Monitor
Timp: 10 min | Mod: Perechi | Puncte: 20

```
╔════════════════════════════════════════════════════════════════════╗
║  🏃 SPRINT O2: PROCES MONITOR                                      ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  PAIR PROGRAMMING! 🔄 Switch la minutul 5!                         ║
║                                                                    ║
║  OBIECTIV: Scrie un script "monitor.sh" care:                      ║
║                                                                    ║
║  1. Verifică dacă procesul "firefox" rulează                       ║
║  2. Dacă DA → afișează PID-ul și consumul de memorie               ║
║  3. Dacă NU → pornește firefox în background și confirmă           ║
║  4. La final, afișează numărul total de procese firefox            ║
║                                                                    ║
║  ─────────────────────────────────────────────────────────────────  ║
║  STRUCTURĂ SUGERATĂ:                                               ║
║                                                                    ║
║    #!/bin/bash                                                     ║
║    # Verificare proces                                             ║
║    if pgrep ... ; then                                             ║
║        # afișare info                                              ║
║    else                                                            ║
║        # pornire                                                   ║
║    fi                                                              ║
║    # Numărare totală                                               ║
║                                                                    ║
║  ─────────────────────────────────────────────────────────────────  ║
║  HINT: pgrep -c pentru numărare, pgrep -a pentru detalii           ║
║                                                                    ║
║  VERIFICARE: ./monitor.sh trebuie să funcționeze în ambele cazuri  ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

💡 Soluție:
```bash
#!/bin/bash
# monitor.sh - Monitor proces firefox

PROC="firefox"

if pgrep "$PROC" > /dev/null; then
    echo "✓ $PROC rulează:"
    pgrep -a "$PROC" | head -3
    echo ""
    echo "Consum memorie:"
    ps aux | grep "$PROC" | grep -v grep | awk '{print $2 " - " $4 "% MEM"}'
else
    echo "✗ $PROC nu rulează. Pornesc..."
    firefox &>/dev/null &
    sleep 1
    pgrep "$PROC" > /dev/null && echo "✓ Firefox pornit cu succes!" || echo "✗ Eroare la pornire"
fi

echo ""
echo "Total procese $PROC: $(pgrep -c "$PROC" 2>/dev/null || echo 0)"
```

---

### SPRINT O3: Build Pipeline
Timp: 12 min | Mod: Perechi | Puncte: 25

```
╔════════════════════════════════════════════════════════════════════╗
║  🏃 SPRINT O3: BUILD PIPELINE                                      ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  OBIECTIV: Creează un script "build.sh" care simulează un build:   ║
║                                                                    ║
║  ETAPE (toate trebuie să reușească pentru a continua):             ║
║                                                                    ║
║    1. "Verificare dependențe..." (verifică dacă există gcc)        ║
║    2. "Compilare..." (creează fișier temp, sleep 1)                ║
║    3. "Testare..." (verifică dacă temp există, sleep 1)            ║
║    4. "Împachetare..." (mută temp în build/, sleep 1)              ║
║    5. "✓ BUILD COMPLET!" sau "✗ BUILD EȘUAT la etapa X"            ║
║                                                                    ║
║  ─────────────────────────────────────────────────────────────────  ║
║  CERINȚE:                                                          ║
║                                                                    ║
║    • Fiecare etapă folosește && pentru a continua                  ║
║    • La eșec, se afișează exact unde a eșuat                       ║
║    • La final, cleanup (șterge fișierele temporare)                ║
║    • Afișează timpul total de execuție                             ║
║                                                                    ║
║  ─────────────────────────────────────────────────────────────────  ║
║  BONUS (+5p): Adaugă o opțiune --clean care șterge build/          ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

💡 Soluție:
```bash
#!/bin/bash
# build.sh - Simulator build pipeline

START=$(date +%s)
STEP=0

cleanup() {
    rm -f /tmp/build_temp_$$
}
trap cleanup EXIT

fail() {
    echo "✗ BUILD EȘUAT la etapa $STEP: $1"
    exit 1
}

# Opțiune clean
[[ "$1" == "--clean" ]] && { rm -rf build/; echo "✓ Clean complet"; exit 0; }

echo "=== BUILD PIPELINE ==="
echo ""

# Etapa 1
((STEP++))
echo -n "[$STEP/4] Verificare dependențe... "
command -v gcc &>/dev/null && echo "✓" || fail "gcc nu este instalat"

# Etapa 2
((STEP++))
echo -n "[$STEP/4] Compilare... "
touch /tmp/build_temp_$$ && sleep 1 && echo "✓" || fail "eroare compilare"

# Etapa 3
((STEP++))
echo -n "[$STEP/4] Testare... "
[[ -f /tmp/build_temp_$$ ]] && sleep 1 && echo "✓" || fail "fișier temp inexistent"

# Etapa 4
((STEP++))
echo -n "[$STEP/4] Împachetare... "
mkdir -p build && mv /tmp/build_temp_$$ build/output && sleep 1 && echo "✓" || fail "eroare împachetare"

END=$(date +%s)
echo ""
echo "═══════════════════════════════════════"
echo "✓ BUILD COMPLET în $((END-START)) secunde!"
echo "═══════════════════════════════════════"
```

---

## SPRINT-URI REDIRECȚIONARE I/O

### SPRINT R1: Log Separator
Timp: 10 min | Mod: Perechi | Puncte: 20

```
╔════════════════════════════════════════════════════════════════════╗
║  🏃 SPRINT R1: LOG SEPARATOR                                       ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  OBIECTIV: Separă stdout și stderr în fișiere diferite             ║
║                                                                    ║
║  COMANDĂ DE TESTAT:                                                ║
║                                                                    ║
║    find /etc -name "*.conf" -type f 2>/dev/null                    ║
║    ls /directorul_inexistent                                       ║
║                                                                    ║
║  CERINȚE pentru find + ls (o singură linie de comandă):            ║
║                                                                    ║
║    1. stdout → success.log                                         ║
║    2. stderr → errors.log                                          ║
║    3. AMBELE → combined.log (și stdout și stderr)                  ║
║                                                                    ║
║  ─────────────────────────────────────────────────────────────────  ║
║  VERIFICARE:                                                       ║
║                                                                    ║
║    • success.log conține căile .conf găsite                        ║
║    • errors.log conține "No such file or directory"                ║
║    • combined.log conține AMBELE                                   ║
║                                                                    ║
║  ─────────────────────────────────────────────────────────────────  ║
║  HINT: Poți folosi tee și redirecționare combinată                 ║
║        sau subshell cu redirecționare multiplă                     ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

💡 Soluție (varianta cu tee):
```bash
{ find /etc -name "*.conf" -type f; ls /directorul_inexistent; } 2>&1 | tee combined.log | grep -v "No such" > success.log; grep "No such" combined.log > errors.log
```

💡 Soluție alternativă (mai elegantă):
```bash
{
    find /etc -name "*.conf" -type f
    ls /directorul_inexistent
} > >(tee -a success.log combined.log) 2> >(tee -a errors.log combined.log >&2)
```

---

### SPRINT R2: Config Generator
Timp: 10 min | Mod: Individual | Puncte: 20

```
╔════════════════════════════════════════════════════════════════════╗
║  🏃 SPRINT R2: CONFIG GENERATOR                                    ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  OBIECTIV: Folosește HERE DOCUMENT pentru a genera un fișier       ║
║            de configurare app.conf cu valori din variabile         ║
║                                                                    ║
║  VARIABILE DE DEFINIT:                                             ║
║                                                                    ║
║    APP_NAME="MyApp"                                                ║
║    APP_PORT=8080                                                   ║
║    APP_ENV="production"                                            ║
║    DB_HOST="localhost"                                             ║
║    DB_PORT=5432                                                    ║
║                                                                    ║
║  OUTPUT CERUT (app.conf):                                          ║
║                                                                    ║
║    # Configuration for MyApp                                       ║
║    # Generated on: [data curentă]                                  ║
║                                                                    ║
║    [application]                                                   ║
║    name = MyApp                                                    ║
║    port = 8080                                                     ║
║    environment = production                                        ║
║                                                                    ║
║    [database]                                                      ║
║    host = localhost                                                ║
║    port = 5432                                                     ║
║                                                                    ║
║  ─────────────────────────────────────────────────────────────────  ║
║  VERIFICARE: cat app.conf și compară cu output-ul cerut            ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

💡 Soluție:
```bash
#!/bin/bash
APP_NAME="MyApp"
APP_PORT=8080
APP_ENV="production"
DB_HOST="localhost"
DB_PORT=5432

cat > app.conf << EOF
# Configuration for $APP_NAME
# Generated on: $(date '+%Y-%m-%d %H:%M:%S')

[application]
name = $APP_NAME
port = $APP_PORT
environment = $APP_ENV

[database]
host = $DB_HOST
port = $DB_PORT
EOF

echo "✓ Fișier app.conf generat:"
cat app.conf
```

---

### SPRINT R3: Stream Multiplexer
Timp: 12 min | Mod: Perechi | Puncte: 25

```
╔════════════════════════════════════════════════════════════════════╗
║  🏃 SPRINT R3: STREAM MULTIPLEXER                                  ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  OBIECTIV: Creează un script care procesează input de la stdin     ║
║            și îl trimite în 3 direcții diferite simultan           ║
║                                                                    ║
║  CERINȚE pentru script "multiplex.sh":                             ║
║                                                                    ║
║    1. Citește linii de la stdin                                    ║
║    2. Liniile cu "ERROR" → errors.log                              ║
║    3. Liniile cu "WARN" → warnings.log                             ║
║    4. TOATE liniile → all.log                                      ║
║    5. Afișează și pe ecran numărul de linii procesate              ║
║                                                                    ║
║  ─────────────────────────────────────────────────────────────────  ║
║  TEST INPUT (creează test_input.txt):                              ║
║                                                                    ║
║    INFO Starting application                                       ║
║    WARN Low memory                                                 ║
║    INFO Processing request                                         ║
║    ERROR Connection failed                                         ║
║    WARN High CPU usage                                             ║
║    ERROR Timeout                                                   ║
║    INFO Finished                                                   ║
║                                                                    ║
║  ─────────────────────────────────────────────────────────────────  ║
║  UTILIZARE: cat test_input.txt | ./multiplex.sh                    ║
║                                                                    ║
║  VERIFICARE:                                                       ║
║    • all.log: 7 linii                                              ║
║    • errors.log: 2 linii (cele cu ERROR)                           ║
║    • warnings.log: 2 linii (cele cu WARN)                          ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

💡 Soluție:
```bash
#!/bin/bash
# multiplex.sh - Stream multiplexer

# Inițializare contoare
total=0
errors=0
warnings=0

# Golire fișiere anterioare
> all.log
> errors.log  
> warnings.log

# Procesare stdin
while IFS= read -r line; do
    ((total++))
    
    # Toate liniile în all.log
    echo "$line" >> all.log
    
    # Filtrare pe tip
    if [[ "$line" == *"ERROR"* ]]; then
        echo "$line" >> errors.log
        ((errors++))
    elif [[ "$line" == *"WARN"* ]]; then
        echo "$line" >> warnings.log
        ((warnings++))
    fi
done

# Raport final
echo "═══════════════════════════════════════"
echo "📊 RAPORT PROCESARE"
echo "═══════════════════════════════════════"
echo "Total linii:    $total"
echo "Erori:          $errors"
echo "Avertismente:   $warnings"
echo "═══════════════════════════════════════"
```

---

## SPRINT-URI FILTRE DE TEXT

### SPRINT F1: Top 5 Useri
Timp: 5 min | Mod: Individual | Puncte: 10

```
╔════════════════════════════════════════════════════════════════════╗
║  🏃 SPRINT F1: TOP 5 USERI                                         ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  OBIECTIV: Găsește primii 5 utilizatori din /etc/passwd            ║
║            după ordinea ALFABETICĂ a username-urilor               ║
║                                                                    ║
║  CERINȚĂ: Un singur pipeline (one-liner)                           ║
║                                                                    ║
║  HINT: cut pentru a extrage username, sort, head                   ║
║                                                                    ║
║  ─────────────────────────────────────────────────────────────────  ║
║  OUTPUT EXEMPLU (poate varia):                                     ║
║                                                                    ║
║    _apt                                                            ║
║    backup                                                          ║
║    bin                                                             ║
║    daemon                                                          ║
║    games                                                           ║
║                                                                    ║
║  ─────────────────────────────────────────────────────────────────  ║
║  VERIFICARE: Compară cu output-ul colegului - trebuie să fie       ║
║              identic dacă aveți același /etc/passwd                ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

💡 Soluție:
```bash
cut -d':' -f1 /etc/passwd | sort | head -5
```

---

### SPRINT F2: Word Frequency
Timp: 10 min | Mod: Perechi | Puncte: 20

```
╔════════════════════════════════════════════════════════════════════╗
║  🏃 SPRINT F2: WORD FREQUENCY                                      ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  OBIECTIV: Găsește cele mai frecvente 10 cuvinte dintr-un text     ║
║                                                                    ║
║  SETUP - creează text.txt:                                         ║
║                                                                    ║
║    echo "the quick brown fox jumps over the lazy dog              ║
║    the fox is quick and the dog is lazy                            ║
║    quick quick fox fox dog" > text.txt                             ║
║                                                                    ║
║  CERINȚE:                                                          ║
║                                                                    ║
║    1. Un singur pipeline                                           ║
║    2. Cuvinte convertite la lowercase                              ║
║    3. Afișare: frecvență + cuvânt, sortat descrescător             ║
║                                                                    ║
║  ─────────────────────────────────────────────────────────────────  ║
║  OUTPUT AȘTEPTAT:                                                  ║
║                                                                    ║
║    5 the                                                           ║
║    4 quick                                                         ║
║    4 fox                                                           ║
║    3 dog                                                           ║
║    2 lazy                                                          ║
║    2 is                                                            ║
║    1 over                                                          ║
║    1 jumps                                                         ║
║    1 brown                                                         ║
║    1 and                                                           ║
║                                                                    ║
║  ─────────────────────────────────────────────────────────────────  ║
║  HINT: tr pentru lowercase și spații, sort | uniq -c | sort -rn   ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

💡 Soluție:
```bash
cat text.txt | tr 'A-Z' 'a-z' | tr -cs 'a-z' '\n' | sort | uniq -c | sort -rn | head -10
```

---

### SPRINT F3: Log Analyzer
Timp: 15 min | Mod: Perechi | Puncte: 30

```
╔════════════════════════════════════════════════════════════════════╗
║  🏃 SPRINT F3: LOG ANALYZER                                        ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  OBIECTIV: Analizează un fișier de log Apache și extrage           ║
║            statistici relevante                                    ║
║                                                                    ║
║  SETUP - creează access.log:                                       ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  cat > access.log << 'EOF'                                         ║
║  192.168.1.1 - - [10/Jan/2025:10:00:00] "GET /index.html" 200 1024 ║
║  192.168.1.2 - - [10/Jan/2025:10:00:01] "GET /about.html" 200 2048 ║
║  192.168.1.1 - - [10/Jan/2025:10:00:02] "GET /contact.html" 404 512║
║  192.168.1.3 - - [10/Jan/2025:10:00:03] "POST /login" 200 128      ║
║  192.168.1.1 - - [10/Jan/2025:10:00:04] "GET /index.html" 200 1024 ║
║  192.168.1.2 - - [10/Jan/2025:10:00:05] "GET /products" 500 0      ║
║  192.168.1.4 - - [10/Jan/2025:10:00:06] "GET /index.html" 200 1024 ║
║  192.168.1.1 - - [10/Jan/2025:10:00:07] "GET /api/data" 200 4096   ║
║  192.168.1.2 - - [10/Jan/2025:10:00:08] "GET /index.html" 200 1024 ║
║  192.168.1.5 - - [10/Jan/2025:10:00:09] "GET /about.html" 200 2048 ║
║  EOF                                                               ║
║                                                                    ║
╠════════════════════════════════════════════════════════════════════╣
║  RAPORT CERUT (scrie comenzi pentru fiecare):                      ║
║                                                                    ║
║    1. Total cereri: [număr]                                        ║
║    2. Cereri unice pe IP (top 3 IP-uri după activitate)            ║
║    3. Pagini accesate (top 3 după frecvență)                       ║
║    4. Coduri HTTP (distribuție: 200, 404, 500)                     ║
║    5. Total bytes transferați                                      ║
║                                                                    ║
║  ─────────────────────────────────────────────────────────────────  ║
║  BONUS (+5p): Creează un script care generează tot raportul        ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

💡 Soluții individuale:
```bash
# 1. Total cereri
wc -l < access.log

# 2. Top 3 IP-uri
cut -d' ' -f1 access.log | sort | uniq -c | sort -rn | head -3

# 3. Top 3 pagini
awk '{print $7}' access.log | sort | uniq -c | sort -rn | head -3

# 4. Distribuție coduri HTTP
awk '{print $9}' access.log | sort | uniq -c | sort -rn

# 5. Total bytes
awk '{sum += $10} END {print sum}' access.log
```

💡 Script bonus:
```bash
#!/bin/bash
# log_report.sh - Analiză completă log

LOG="access.log"

echo "═══════════════════════════════════════════════════"
echo "📊 RAPORT ANALIZĂ LOG: $LOG"
echo "═══════════════════════════════════════════════════"
echo ""
echo "1. Total cereri: $(wc -l < "$LOG")"
echo ""
echo "2. Top 3 IP-uri:"
cut -d' ' -f1 "$LOG" | sort | uniq -c | sort -rn | head -3 | awk '{print "   " $2 ": " $1 " cereri"}'
echo ""
echo "3. Top 3 pagini:"
awk '{print $7}' "$LOG" | sort | uniq -c | sort -rn | head -3 | awk '{print "   " $2 ": " $1 " accesări"}'
echo ""
echo "4. Coduri HTTP:"
awk '{print $9}' "$LOG" | sort | uniq -c | sort -rn | awk '{print "   HTTP " $2 ": " $1}'
echo ""
echo "5. Total bytes: $(awk '{sum += $10} END {print sum}' "$LOG")"
echo ""
echo "═══════════════════════════════════════════════════"
```

---

## SPRINT-URI BUCLE

### SPRINT B1: Batch Rename
Timp: 10 min | Mod: Individual | Puncte: 20

```
╔════════════════════════════════════════════════════════════════════╗
║  🏃 SPRINT B1: BATCH RENAME                                        ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  OBIECTIV: Scrie un script care:                                   ║
║                                                                    ║
║  1. Creează 5 fișiere: file1.txt, file2.txt, ..., file5.txt        ║
║  2. În fiecare fișier pune "Content of fileN"                      ║
║  3. Redenumește toate în: document_1.txt, document_2.txt, ...      ║
║  4. Afișează lista ÎNAINTE și DUPĂ                                 ║
║                                                                    ║
║  ─────────────────────────────────────────────────────────────────  ║
║  OUTPUT AȘTEPTAT:                                                  ║
║                                                                    ║
║    === ÎNAINTE ===                                                 ║
║    file1.txt  file2.txt  file3.txt  file4.txt  file5.txt           ║
║                                                                    ║
║    === DUPĂ ===                                                    ║
║    document_1.txt  document_2.txt  document_3.txt  ...             ║
║                                                                    ║
║  ─────────────────────────────────────────────────────────────────  ║
║  VERIFICARE: cat document_3.txt → "Content of file3"               ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

💡 Soluție:
```bash
#!/bin/bash
# batch_rename.sh

# Cleanup
rm -f file*.txt document_*.txt

# 1. Creează fișierele
for i in {1..5}; do
    echo "Content of file$i" > "file$i.txt"
done

# 2. Afișează înainte
echo "=== ÎNAINTE ==="
ls file*.txt 2>/dev/null || echo "(niciun fișier)"
echo ""

# 3. Redenumește
for file in file*.txt; do
    # Extrage numărul
    num=${file//[^0-9]/}
    mv "$file" "document_$num.txt"
done

# 4. Afișează după
echo "=== DUPĂ ==="
ls document_*.txt 2>/dev/null || echo "(niciun fișier)"

echo ""
echo "Verificare document_3.txt:"
cat document_3.txt
```

---

### SPRINT B2: Directory Stats
Timp: 10 min | Mod: Perechi | Puncte: 20

```
╔════════════════════════════════════════════════════════════════════╗
║  🏃 SPRINT B2: DIRECTORY STATS                                     ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  OBIECTIV: Scrie un script "dir_stats.sh" care primește un         ║
║            director ca argument și afișează statistici             ║
║                                                                    ║
║  CERINȚE:                                                          ║
║                                                                    ║
║    1. Verifică dacă argumentul este un director valid              ║
║    2. Pentru fiecare subdirector din primul nivel:                 ║
║       - Afișează numele                                            ║
║       - Număr fișiere (nu directoare)                              ║
║       - Dimensiune totală                                          ║
║    3. La final: total global                                       ║
║                                                                    ║
║  ─────────────────────────────────────────────────────────────────  ║
║  UTILIZARE: ./dir_stats.sh /etc                                    ║
║                                                                    ║
║  OUTPUT EXEMPLU:                                                   ║
║                                                                    ║
║    📁 Statistici pentru: /etc                                      ║
║    ─────────────────────────────────────────                       ║
║    apt/           : 12 fișiere, 45KB                               ║
║    default/       : 8 fișiere, 12KB                                ║
║    ...                                                             ║
║    ─────────────────────────────────────────                       ║
║    TOTAL: 156 fișiere, 2.3MB                                       ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

💡 Soluție:
```bash
#!/bin/bash
# dir_stats.sh - Statistici directoare

DIR="${1:-.}"

# Verificare
[[ ! -d "$DIR" ]] && { echo "✗ '$DIR' nu este un director valid"; exit 1; }

echo "📁 Statistici pentru: $DIR"
echo "─────────────────────────────────────────"

total_files=0
total_size=0

for subdir in "$DIR"/*/; do
    [[ ! -d "$subdir" ]] && continue
    
    name=$(basename "$subdir")
    files=$(find "$subdir" -maxdepth 1 -type f | wc -l)
    size=$(du -sh "$subdir" 2>/dev/null | cut -f1)
    
    printf "%-20s: %3d fișiere, %s\n" "$name/" "$files" "$size"
    
    ((total_files += files))
done

echo "─────────────────────────────────────────"
total_size=$(du -sh "$DIR" 2>/dev/null | cut -f1)
echo "TOTAL: $total_files fișiere în subdirectoare, $total_size total"
```

---

### SPRINT B3: CSV Processor
Timp: 15 min | Mod: Perechi | Puncte: 30

```
╔════════════════════════════════════════════════════════════════════╗
║  🏃 SPRINT B3: CSV PROCESSOR                                       ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  OBIECTIV: Procesează un CSV cu date despre studenți               ║
║                                                                    ║
║  SETUP - creează students.csv:                                     ║
║                                                                    ║
║    cat > students.csv << 'EOF'                                     ║
║    nume,grupa,nota1,nota2,nota3                                    ║
║    Popescu Ion,A1,8,9,7                                            ║
║    Ionescu Maria,A2,10,9,10                                        ║
║    Georgescu Ana,A1,6,7,8                                          ║
║    Vasilescu Dan,A2,9,8,9                                          ║
║    Marinescu Elena,A1,7,8,7                                        ║
║    EOF                                                             ║
║                                                                    ║
║  CERINȚE pentru script "process_csv.sh":                           ║
║                                                                    ║
║    1. Citește CSV-ul (skip header)                                 ║
║    2. Pentru fiecare student calculează media                      ║
║    3. Afișează: nume, grupa, media, status (Admis>=5/Respins)      ║
║    4. La final: media pe grupe și media generală                   ║
║                                                                    ║
║  ─────────────────────────────────────────────────────────────────  ║
║  OUTPUT AȘTEPTAT:                                                  ║
║                                                                    ║
║    📊 RAPORT STUDENȚI                                              ║
║    ─────────────────────────────────────────                       ║
║    Popescu Ion      | A1 | Media: 8.00 | ✓ Admis                   ║
║    Ionescu Maria    | A2 | Media: 9.67 | ✓ Admis                   ║
║    ...                                                             ║
║    ─────────────────────────────────────────                       ║
║    Media grupa A1: 7.33                                            ║
║    Media grupa A2: 9.17                                            ║
║    Media generală: 8.07                                            ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

💡 Soluție:
```bash
#!/bin/bash
# process_csv.sh - Procesor CSV studenți

CSV="${1:-students.csv}"

[[ ! -f "$CSV" ]] && { echo "✗ Fișier '$CSV' nu există"; exit 1; }

echo "📊 RAPORT STUDENȚI"
echo "═══════════════════════════════════════════════════════"

declare -A grup_sum grup_count
total_sum=0
total_count=0

# Skip header, procesare
tail -n +2 "$CSV" | while IFS=',' read -r nume grupa n1 n2 n3; do
    # Calcul medie (folosind bc pentru precizie)
    media=$(echo "scale=2; ($n1 + $n2 + $n3) / 3" | bc)
    
    # Status
    status="✓ Admis"
    [[ $(echo "$media < 5" | bc) -eq 1 ]] && status="✗ Respins"
    
    printf "%-18s | %s | Media: %5.2f | %s\n" "$nume" "$grupa" "$media" "$status"
done

echo "═══════════════════════════════════════════════════════"

# Statistici pe grupe (cu awk pentru simplitate)
echo ""
echo "📈 STATISTICI PE GRUPE:"
awk -F',' 'NR>1 {
    media = ($3 + $4 + $5) / 3
    grup[$2] += media
    count[$2]++
    total += media
    n++
}
END {
    for (g in grup) {
        printf "   Media %s: %.2f\n", g, grup[g]/count[g]
    }
    printf "\n   Media generală: %.2f\n", total/n
}' "$CSV"
```

---

## SPRINT-URI INTEGRATE

### SPRINT I1: System Report
Timp: 15 min | Mod: Perechi | Puncte: 35

```
╔════════════════════════════════════════════════════════════════════╗
║  🏃 SPRINT I1: SYSTEM REPORT                                       ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  OBIECTIV: Creează un script complet "system_report.sh"            ║
║                                                                    ║
║  CERINȚE:                                                          ║
║                                                                    ║
║    1. Header cu data, ora, hostname                                ║
║    2. Secțiune CPU: model, nuclee, load average                    ║
║    3. Secțiune Memorie: total, folosită, liberă, %                 ║
║    4. Secțiune Disk: top 3 partiții după utilizare                 ║
║    5. Secțiune Procese: top 5 după memorie                         ║
║    6. Secțiune Rețea: IP-uri active, conexiuni                     ║
║    7. Salvare în report_YYYYMMDD_HHMMSS.txt                        ║
║    8. Afișare mesaj de confirmare cu calea fișierului              ║
║                                                                    ║
║  ─────────────────────────────────────────────────────────────────  ║
║  BONUS (+5p): Adaugă flag --html pentru output HTML                ║
║  BONUS (+5p): Adaugă comparație cu raportul anterior               ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

💡 Soluție (versiune scurtă):
```bash
#!/bin/bash
# system_report.sh - Raport sistem complet

REPORT="report_$(date '+%Y%m%d_%H%M%S').txt"

{
    echo "════════════════════════════════════════════════════════════"
    echo "                    SYSTEM REPORT                           "
    echo "════════════════════════════════════════════════════════════"
    echo "Generated: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "Hostname:  $(hostname)"
    echo ""
    
    echo "━━━ CPU ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2
    echo "Cores: $(nproc)"
    echo "Load:  $(cat /proc/loadavg | cut -d' ' -f1-3)"
    echo ""
    
    echo "━━━ MEMORY ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    free -h | grep -E "Mem:|Swap:"
    echo ""
    
    echo "━━━ DISK (top 3) ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    df -h | head -1
    df -h | tail -n +2 | sort -k5 -rn | head -3
    echo ""
    
    echo "━━━ TOP 5 PROCESE (MEM) ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    ps aux --sort=-%mem | head -6
    echo ""
    
    echo "━━━ NETWORK ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "IP-uri:"
    ip -4 addr show | grep inet | awk '{print "  " $2}'
    echo "Conexiuni active: $(ss -tuln | wc -l)"
    echo ""
    
    echo "════════════════════════════════════════════════════════════"
} | tee "$REPORT"

echo ""
echo "✓ Raport salvat în: $REPORT"
```

---

### SPRINT I2: Backup Rotativ
Timp: 15 min | Mod: Perechi | Puncte: 40

```
╔════════════════════════════════════════════════════════════════════╗
║  🏃 SPRINT I2: BACKUP ROTATIV                                      ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  OBIECTIV: Script "backup_rotate.sh" cu rotație automată           ║
║                                                                    ║
║  CERINȚE:                                                          ║
║                                                                    ║
║    1. Primește: director_sursa, director_backup, max_backups       ║
║    2. Creează backup cu timestamp: backup_YYYYMMDD_HHMMSS.tar.gz   ║
║    3. Dacă există mai mult de max_backups, șterge cele vechi       ║
║    4. Logging în backup.log (append)                               ║
║    5. Exit codes: 0=succes, 1=eroare argumente, 2=eroare backup    ║
║                                                                    ║
║  ─────────────────────────────────────────────────────────────────  ║
║  UTILIZARE:                                                        ║
║    ./backup_rotate.sh /home/user/data /backup 5                    ║
║                                                                    ║
║  VERIFICARE:                                                       ║
║    • Rulează de 7 ori → doar 5 backups rămân                       ║
║    • backup.log conține toate operațiile                           ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

---

## MATRICE UTILIZARE SPRINT-URI

| Sprint | Concept Principal | Durată | Nivel | Moment Optim |
|--------|-------------------|--------|-------|--------------|
| O1 | && și \|\| | 5 min | ⭐ | După live coding operatori |
| O2 | if, pgrep, & | 10 min | ⭐⭐ | După background |
| O3 | pipeline build | 12 min | ⭐⭐⭐ | Exercițiu final operatori |
| R1 | Redirecționare 2>&1 | 10 min | ⭐⭐ | După live coding redirect |
| R2 | Here document | 10 min | ⭐⭐ | După << explicat |
| R3 | tee, while read | 12 min | ⭐⭐⭐ | Exercițiu final redirect |
| F1 | cut, sort, head | 5 min | ⭐ | După live coding filtre |
| F2 | tr, uniq -c | 10 min | ⭐⭐ | După demo frecvențe |
| F3 | awk, pipeline | 15 min | ⭐⭐⭐ | Exercițiu final filtre |
| B1 | for, mv | 10 min | ⭐⭐ | După live coding for |
| B2 | for, find, du | 10 min | ⭐⭐ | După iterare directoare |
| B3 | while IFS read | 15 min | ⭐⭐⭐ | După citire CSV |
| I1 | Tot semestrul | 15 min | ⭐⭐⭐ | Final seminar |
| I2 | Advanced | 15 min | ⭐⭐⭐⭐ | Temă/Bonus |

---

## TRACKING PROGRES

```
╔════════════════════════════════════════════════════════════════════╗
║  TRACKING SPRINT-URI - Seminar [DATA]                              ║
╠════════════════════════════════════════════════════════════════════╣
║  Student: ___________________ Grupa: ______                        ║
╠════════════════════════════════════════════════════════════════════╣
║  Sprint    │ Completat │ Timp Real │ Puncte │ Observații           ║
║  ──────────┼───────────┼───────────┼────────┼────────────────────  ║
║  O1        │ □ Da □ Nu │ ___ min   │ __/10  │                      ║
║  O2        │ □ Da □ Nu │ ___ min   │ __/20  │                      ║
║  R1        │ □ Da □ Nu │ ___ min   │ __/20  │                      ║
║  F1        │ □ Da □ Nu │ ___ min   │ __/10  │                      ║
║  F2        │ □ Da □ Nu │ ___ min   │ __/20  │                      ║
║  B1        │ □ Da □ Nu │ ___ min   │ __/20  │                      ║
║  I1        │ □ Da □ Nu │ ___ min   │ __/35  │                      ║
║  ──────────┼───────────┼───────────┼────────┼────────────────────  ║
║  TOTAL     │           │           │ __/135 │                      ║
╚════════════════════════════════════════════════════════════════════╝
```

---

*Document generat pentru Seminarul 3-4 SO | ASE București - CSIE*  
*Exerciții cronometrate pentru învățare activă și consolidare*
