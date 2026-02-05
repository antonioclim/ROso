# Ghid pentru instructor — Seminarul 02
## Sisteme de Operare | Note practice de predare

**Document**: S02_01_INSTRUCTOR_GUIDE.md  
**Versiune**: 1.0 | **Dată**: ianuarie 2025  
**Destinat**: asistenți, doctoranzi, instructori de laborator  
**Autor**: ing. dr. Antonio Clim

---

## Înainte de seminar

### Checklist de pregătire (15 minute înainte de curs)

Știu că pare mult, dar crede-mă: este mai bine să verifici acum decât să pierzi 10 minute din seminar depănând probleme de proiecție sau configurare.

```
□ Proiector funcțional, terminal vizibil din ultimul rând
□ Font mărit în terminal (CTRL++ până la minimum 18pt)
□ Fișierele demo pregătite în /tmp/sem02_demo/
□ Runner‑ul de quiz testat rapid: cd SEM02 && make quiz (CTRL+C după prima întrebare)
□ Slide‑urile PDF ca backup pe un stick USB
□ Marker funcțional pentru tablă (pentru diagrame ad‑hoc)
□ Cafea/apă pentru tine (90 de minute este un interval lung)
```

### Setup rapid pentru demo

Rulează asta ÎNAINTE să intre studenții:

```bash
cd /path/to/SEM02
./scripts/bash/S02_01_setup_seminar.sh

# Verifică dacă s-a creat tot
ls -la /tmp/sem02_demo/
# Ar trebui să vezi: sample.txt, access.log, data.csv, users.txt, etc.
```

Dacă scriptul produce erori, creează manual fișierele esențiale:

```bash
mkdir -p /tmp/sem02_demo && cd /tmp/sem02_demo

# Fișier text simplu
echo -e "line one
line two
line three" > sample.txt

# Log fictiv pentru demonstrații cu filtre
cat > access.log << 'EOF'
192.168.1.100 - - [29/Jan/2025:10:15:32] "GET /index.html" 200
192.168.1.101 - - [29/Jan/2025:10:15:33] "GET /style.css" 200
192.168.1.100 - - [29/Jan/2025:10:15:34] "POST /login" 401
10.0.0.50 - - [29/Jan/2025:10:15:35] "GET /admin" 403
192.168.1.100 - - [29/Jan/2025:10:15:36] "GET /dashboard" 200
EOF

# CSV pentru exerciții
echo -e "name,age,city
Ana,22,Bucharest
Ion,25,Cluj
Maria,22,Iasi" > data.csv
```

---

## Lucruri care merg prost (în fiecare an. Fără excepție.)

Uite, am predat seminarul acesta de multe ori. Iată ce SE VA întâmpla, ca să fii pregătit(ă):

### Măcelul `>` versus `>>`
Demonstrează ambele variante una lângă alta. De două ori. De trei ori dacă este nevoie. Apoi arată ce se întâmplă când folosești din greșeală `>` pe un fișier important. Studenții încă întreabă despre asta la temă, dar măcar își amintesc că i-ai avertizat.

### Capcana variabilei în subshell
Cineva va scrie `cat file | while read line; do ((count++)); done` și se va mira de ce `$count` este 0 după aceea. Eu demonstrez acum bug‑ul ÎNTÂI, îi las să simtă confuzia, apoi arăt remedierea. „Aha‑ul” este mai memorabil decât dacă prezinți direct varianta corectă.

### „Dar la mine merge”
De obicei e vorba de line endings de Windows ascunse (`
` versus `
`). Ține `dos2unix` pregătit. Din 2023, verifică și dacă nu cumva unii studenți folosesc accidental sintaxă PowerShell în Bash.

### „Aruncarea AI” (problemă nouă din 2023)
Studenții trimit scripturi cu comentarii perfecte, nume elaborate de variabile și logică ruptă. Autograder‑ul include acum detecție de tipare AI. Dacă vezi cod suspect de „lustruit”, roagă studentul să explice o linie aleatorie. De regulă se vede rapid ruptura de înțelegere.

### Bug‑ul `{1..$n}`
În ciuda avertismentelor explicite, ~20% încearcă în continuare asta. Eu scriu acum pe tablă cu roșu: **EXPANDAREA ACOLADELOR ÎNAINTE DE EXPANDAREA VARIABILELOR**. Apoi arăt imediat `seq` și alternativele de tip C.

---

## Flux recomandat al sesiunii

### Minutele 0–10: HOOK (captarea atenției)

**Scop**: efectul „wow”. Arată ce vor putea face la finalul sesiunii.

**Scriptul meu tipic** (adaptează la stilul tău):

> „Să vedem ceva interesant. Cine știe câte fișiere de configurare `.conf` există pe sistemul acesta?”

```bash
find /etc -name "*.conf" 2>/dev/null | wc -l
```

> „Și care sunt cele mai mari 5?”

```bash
find /etc -name "*.conf" -exec du -h {} \; 2>/dev/null | sort -rh | head -5
```

> „Sau și mai bine: câte linii de cod există în toate scripturile Bash din /usr?”

```bash
find /usr -name "*.sh" -exec cat {} \; 2>/dev/null | wc -l
```

> „Până la finalul seminarului de azi veți putea construi singuri comenzi de acest tip.”

**Notă**: dacă cineva întreabă despre `2>/dev/null`, răspunde scurt: „Ascunde mesajele de eroare — examinăm imediat în detaliu.” Nu te pierde acum în explicații.

---

### Minutele 10–25: Operatori de control

#### Parte teoretică (7 minute)

Desenează pe tablă sau afișează slide‑ul:

```
cmd1 ; cmd2     → cmd2 rulează ÎNTOTDEAUNA (secvențial)
cmd1 && cmd2    → cmd2 rulează DOAR dacă cmd1 întoarce 0 (succes)
cmd1 || cmd2    → cmd2 rulează DOAR dacă cmd1 întoarce ≠0 (eșec)
cmd1 & cmd2     → cmd1 trece în background, cmd2 începe imediat
```

**Eroare tipică #1**: confuzia dintre `&` (background) și `&&` (AND logic).

Demonstrație rapidă pentru clarificare:

```bash
sleep 3 & echo "Appears immediately"    # echo apare INSTANT
sleep 3 && echo "Appears after 3s"      # echo apare DUPĂ sleep
```

**Sugestie**: scrie pe tablă cu litere mari: `&` ≠ `&&`. Subliniat de două ori.

#### Peer Instruction (8 minute)

Folosește întrebarea PI‑03 (sau una similară):

```bash
false && echo "A" || echo "B" && echo "C"
```

**Procedură**:

1. **Vot inițial** (1 min): „Ridicați mâna — cine spune că se afișează doar A? Doar B? Doar C? B și C? Altceva?”
   - Notează mental distribuția. Tipic: 40% „doar B”, 30% „B și C”, restul alte răspunsuri.

2. **Discuție în perechi** (3 min): „Întoarceți-vă la vecin și convingeți-l de răspunsul vostru.”
   - Plimbă-te prin sală, ascultă argumente, nu corecta încă.

3. **Vot final** (1 min): de regulă se concentrează spre răspunsul corect.

4. **Explicație** (3 min): parcurge pas cu pas pe tablă:

```
false           → cod de ieșire 1 (eșec)
  && echo "A"   → NU se execută (predecesorul a eșuat)
  || echo "B"   → SE execută (lanțul anterior a eșuat) → afișează "B", cod 0
  && echo "C"   → SE execută (predecesorul a reușit) → afișează "C"

Rezultat: se afișează "B" și "C" (pe linii separate)
```

---

### Minutele 25–45: Redirecționare I/O

#### Diagrama fundamentală (deseneaz-o pe tablă!)

```
                    ┌──────────────────┐
    stdin (fd 0) ──►│                  │──► stdout (fd 1) ──► terminal/fișier
        ▲           │     COMANDĂ      │
        │           │                  │──► stderr (fd 2) ──► terminal/fișier
   tastatură        └──────────────────┘
   sau fișier
```

**Explică**: „Fiecare proces are implicit 3 canale deschise. Redirecționarea înseamnă să schimbi unde duc aceste canale.”

#### Codare live ghidată (15 minute)

Construiește progresiv, verificând înțelegerea:

```bash
# 1. Bază — stdout către fișier
echo "test" > out.txt
cat out.txt

# 2. Ce se întâmplă dacă repet?
echo "line 2" > out.txt
cat out.txt          # "line 2" — a SUPRASCRIS!

# 3. Cum facem APPEND?
echo "test" > out.txt
echo "line 2" >> out.txt
cat out.txt          # ambele linii!
```

**Pauză**: „Întrebări până aici? Este clară diferența dintre > și >>?”

```bash
# 4. Stderr este pe un canal separat
ls /nonexistent_directory              # eroare pe ecran
ls /nonexistent_directory > out.txt    # eroarea este TOT pe ecran!
cat out.txt                            # fișierul este GOL

# De ce? Stdout și stderr sunt SEPARATE
ls /nonexistent_directory 2> err.txt   # acum funcționează
cat err.txt
```

#### CAPCANA CLASICĂ (alocă 5 minute)

Aici se încurcă ~60% dintre studenți la examinări:

```bash
# CORECT: stdout în fișier, APOI stderr către unde este stdout acum (adică fișierul)
ls /home /nonexistent > all.txt 2>&1
cat all.txt      # conține output valid ȘI eroarea

# GREȘIT: stderr merge unde este stdout ACUM (terminal), apoi stdout în fișier
ls /home /nonexistent 2>&1 > all.txt
# Eroarea APARE pe ecran! De ce?
```

**Explicație cu diagramă**:

```
CORECT: > all.txt 2>&1
  Pas 1: stdout → all.txt
  Pas 2: stderr → unde este stdout ACUM → all.txt ✓

GREȘIT: 2>&1 > all.txt  
  Pas 1: stderr → unde este stdout ACUM → terminal
  Pas 2: stdout → all.txt
  Rezultat: stderr merge tot pe ecran! ✗
```

**Mnemotehnică**: „Mai întâi destinația, apoi copia” sau „Ordinea contează — redirecționează, apoi dublează”.

---

### Minutele 45–70: Filtre și pipeline‑uri

#### Demo vizual — construcție incrementală (10 minute)

Arată output‑ul la FIECARE pas:

```bash
cd /tmp/sem02_demo

# Pas 1: ce avem?
cat access.log

# Pas 2: extrage doar adresele IP
cat access.log | cut -d' ' -f1

# Pas 3: sortează-le
cat access.log | cut -d' ' -f1 | sort

# Pas 4: numără aparițiile unice
cat access.log | cut -d' ' -f1 | sort | uniq -c

# Pas 5: sortează descrescător după număr
cat access.log | cut -d' ' -f1 | sort | uniq -c | sort -rn

# Pas 6: ia top 3
cat access.log | cut -d' ' -f1 | sort | uniq -c | sort -rn | head -3
```

**Sugestie didactică**: construiește pipeline‑ul LIVE, pas cu pas. Nu arăta comanda finală direct — își pierde efectul.

#### Problemă Parsons în clasă (10 minute)

Proiectează PP‑08 sau o problemă similară.

> „Aveți 4 minute să aranjați liniile în ordinea corectă. Lucrați în perechi.”

Plimbă-te prin sală:
- Observă ce erori fac
- Nu corecta direct; pune întrebări: „Ce crezi că face sort aici?”
- Notează mental erorile frecvente pentru debriefing

După 4 minute:
> „Cine vrea să vină la tablă și să ne arate soluția?”

Lasă studentul să explice, completează unde este necesar.

#### Exerciții de sprint (10 minute)

> „Acum individual. Aveți 10 minute pentru exercițiile S‑F1 și S‑F2. Validatorul rulează local.”

```bash
# Studenții rulează pe stația lor
./scripts/bash/S02_03_validator.sh ./my_solution/
```

Tu: circulă, ajută unde este blocaj, dar nu oferi soluții — pune întrebări care ghidează.

---

### Minutele 70–85: Bucle

#### Modele esențiale (tablă)

```bash
# FOR — când cunoști lista de elemente
for item in list of elements; do
    echo "$item"
done

# FOR cu expandare de acolade — pentru secvențe numerice
for i in {1..5}; do
    echo "$i"
done

# WHILE — când citești input sau aștepți o condiție
while IFS= read -r line; do
    echo "Line: $line"
done < file.txt

# UNTIL — inversul lui while (mai rar folosit)
until [[ $count -ge 10 ]]; do
    ((count++))
done
```

#### CAPCANA SUBSHELL‑ULUI (foarte important!)

```bash
# PROBLEMĂ: variabila NU persistă
count=0
cat file.txt | while read line; do
    ((count++))
done
echo "Counted: $count"   # Afișează 0! De ce?!

# SOLUȚIE: redirecționează în loc de pipe
count=0
while read line; do
    ((count++))
done < file.txt
echo "Counted: $count"   # Afișează valoarea corectă!
```

**Explicație**: pipe‑ul creează un SUBSHELL. Variabilele modificate în subshell „mor” odată cu el. Redirecționarea (`< file`) rulează în shell‑ul curent.

Desenează:

```
GREȘIT (pipe):
┌─────────────┐      ┌─────────────┐
│  cat file   │ ───► │ while read  │  ← SUBSHELL SEPARAT
│             │      │ count++     │     count moare aici!
└─────────────┘      └─────────────┘

CORECT (redirecționare):
┌─────────────────────────────────┐
│  while read line; do            │  ← ACELAȘI SHELL
│      count++                    │     count supraviețuiește
│  done < file                    │
└─────────────────────────────────┘
```

---

### Minutele 85–90: Încheiere

1. **Sinteză vizuală** (2 min):
   - Arată cheat sheet‑ul (S02_02_cheat_sheet.html sau print)
   - Evidențiază cele 5 lucruri de reținut:
     1. `>` suprascrie, `>>` adaugă
     2. `2>&1` DUPĂ redirecționarea stdout
     3. `&&` = succes, `||` = eșec
     4. Pipeline = stdout → stdin
     5. Pipe creează subshell, redirecționarea nu

2. **Preview temă** (2 min):
   > „Tema are 6 părți, deadline [date]. Partea 5 integrează tot ce am făcut azi. Partea 6 este scurtă, dar obligatorie — verifică faptul că înțelegeți, nu doar că ați copiat. Există și bonus pentru soluții avansate.”

3. **Întrebări** (1 min):
   > „Întrebări? Sunt și pe forum; răspund în maximum 24 de ore.”

---

## Situații comune și cum le gestionez

### „Comanda X nu funcționează”

Diagnostic rapid:

```bash
which X         # Există comanda?
type X          # Este alias/builtin/external?
echo $PATH      # PATH este configurat corect?
bash --version  # Versiunea Bash (unele funcții cer 4.0+)
```

### „Am șters/suprascris accidental fișierul”

**Prevenție**: demonstrează ÎNTOTDEAUNA pericolul lui `>` înainte de exerciții.

**Dacă s-a întâmplat**: „Din păcate, dacă era în /tmp, este pierdut. Îl refacem. Data viitoare, folosește `>|` doar când ești sigur(ă), sau fă un backup înainte.”

### „De ce output‑ul e diferit față de ce mă așteptam?”

Tehnică de depanare:

```bash
set -x    # Activează modul trace — vezi fiecare comandă
# ... comenzi problematice ...
set +x    # Dezactivează

# Sau pentru o singură comandă:
bash -x script.sh
```

### Student avansat care se plictisește

Opțiuni:
- „Încearcă exercițiul bonus din temă”
- „Poți optimiza pipeline‑ul să ruleze mai rapid?”
- „Ajută-ți vecinul — explică-i conceptul” (peer teaching)

### Student complet pierdut

- Nu îl ignora, dar nici nu bloca sesiunea pentru el
- „Rămâi 5 minute după curs; te ajut să recuperezi”
- Recomandă resurse suplimentare din S02_RESOURCES.md
- Sugerează tutorare între colegi

---

## După seminar

### Checklist post‑sesiune

```
□ Salvează notițe: ce a mers bine, ce trebuie ajustat
□ Verifică dacă a rulat scriptul de curățare (rm -rf /tmp/sem02_demo)
□ Răspunde pe forum în maximum 24 de ore
□ Dacă ai găsit erori în materiale, notează-le pentru corecție
```

### Șablon de notițe pentru îmbunătățire

```
Dată: ___________
Grupă: ___________

Ce a mers bine:
- 

Ce a durat prea mult:
-

Ce a durat prea puțin:
-

Întrebări neașteptate:
-

Misconcepții observate:
-

De modificat data viitoare:
-
```

---

## Anexa A: Răspunsuri rapide pentru Peer Instruction

| ID | Răspuns corect | Capcană frecventă |
|----|---------------|-------------------|
| PI-01 | Cod de ieșire 0 | Confuzie succes/eșec |
| PI-02 | „B” și „C” | Doar „B” |
| PI-03 | „B” și „C” | Doar „B” sau cred că apar pe aceeași linie |
| PI-04 | Variabila e goală | Cred că persistă din subshell |
| PI-05 | Fișierul e suprascris | Cred că se adaugă |

## Anexa B: Coduri de ieșire de memorat

| Cod | Semnificație | Când apare |
|------|---------|-----------------|
| 0 | Succes | Comanda a rulat corect |
| 1 | Eroare generală | Diverse erori nespecificate |
| 2 | Utilizare greșită | Argumente invalide |
| 126 | Permisiune refuzată | Fișier fără permisiune de execuție |
| 127 | Comandă inexistentă | Comanda nu există în PATH |
| 128+N | Oprit de semnalul N | De ex. 130 = SIGINT (Ctrl+C) |

## Anexa C: Comenzi de urgență

```bash
# Dacă ceva rulează și nu se oprește
Ctrl+C              # Întrerupe procesul curent
Ctrl+Z              # Suspendă (apoi `kill %1` sau `bg`)

# Dacă terminalul pare înghețat
Ctrl+Q              # Reactivează scroll (dacă ai apăsat Ctrl+S din greșeală)
reset               # Resetează terminalul

# Dacă a dispărut cursorul
echo -e "[?25h"  # Arată cursorul
```

---

*Ghid practic pentru instructori | Seminarul 02 — Sisteme de Operare*  
*ASE București - CSIE | Ultima actualizare: ianuarie 2025*
