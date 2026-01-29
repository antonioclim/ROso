# Ghid Live Coding - Seminarul 3-4
## Sisteme de Operare | Operatori, Redirecționare, Filtre, Bucle

Durată totală live coding: ~45-50 minute (distribuit pe parcursul seminarului)  
Stil: Incremental, cu predicții și erori deliberate

---

## PRINCIPIILE LIVE CODING

### Cele 5 Reguli de Aur

1. INCREMENTAL - Construiește pas cu pas, nu arăta codul final dintr-o dată
2. PREDICȚII - Întreabă "Ce credeți că se întâmplă?" ÎNAINTE de execuție
3. ERORI DELIBERATE - Fă greșeli intenționate pentru a demonstra probleme comune
4. NARARE - Verbalizează ce faci și de ce ("Acum adaug && pentru că...")
5. VITEZĂ REDUSĂ - Scrie mai lent decât normal, dă timp să proceseze

### Structura Fiecărui Segment

```
┌─────────────────────────────────────────────────────────────┐
│  1. ANUNȚ     - "Acum vom vedea cum funcționează..."       │
│  2. PREDICȚIE - "Ce credeți că se întâmplă dacă...?"       │
│  3. EXECUȚIE  - Rulează comanda                            │
│  4. EXPLICAȚIE - "Observați că... pentru că..."            │

> 💡 Am observat că studenții care desenează diagrama pe hârtie înainte de a scrie codul au rezultate mult mai bune.

│  5. VARIAȚIE  - "Dar dacă schimbăm X?"                     │
└─────────────────────────────────────────────────────────────┘
```

---

## SETUP INIȚIAL

### Pregătire Mediu (Rulează înainte de seminar!)

```bash
#!/bin/bash
# === SETUP COMPLET PENTRU DEMO ===

# Cleanup și creare director de lucru
rm -rf ~/demo_seminar34 2>/dev/null
mkdir -p ~/demo_seminar34
cd ~/demo_seminar34

# PS1 scurt pentru demo (mai vizibil)
export PS1='\[\e[1;32m\]demo\[\e[0m\]:\[\e[1;34m\]\W\[\e[0m\]$ '

# Creare fișiere de test
cat > colors.txt << 'EOF'
rosu
verde
rosu
albastru
verde
rosu
galben
albastru
EOF

cat > numere.txt << 'EOF'
42
7
99
15
3
88
23
EOF

cat > studenti.csv << 'EOF'
nume,grupa,nota
Popescu Ion,1234,9
Ionescu Maria,1234,10
Georgescu Ana,1235,8
Vasilescu Dan,1235,7
Marinescu Eva,1234,9
EOF

cat > access.log << 'EOF'
192.168.1.1 - - [10/Jan/2025:10:00:01] "GET /index.html" 200
192.168.1.2 - - [10/Jan/2025:10:00:02] "GET /style.css" 200
192.168.1.1 - - [10/Jan/2025:10:00:03] "POST /login" 401
192.168.1.3 - - [10/Jan/2025:10:00:04] "GET /admin" 403
192.168.1.1 - - [10/Jan/2025:10:00:05] "POST /login" 200
192.168.1.2 - - [10/Jan/2025:10:00:06] "GET /dashboard" 200
192.168.1.4 - - [10/Jan/2025:10:00:07] "GET /api/data" 500
EOF

cat > text.txt << 'EOF'
Linux este un sistem de operare open source.
Shell-ul Bash permite automatizarea task-urilor.
Pipe-urile conectează comenzile între ele.
Filtrele procesează text linie cu linie.
Linux este folosit pe servere și desktop-uri.
EOF

echo "✓ Setup complet! Fișiere create:"
ls -la
```

---

## SESIUNEA 1: OPERATORI DE CONTROL (15 min)

### Pas 1: Bun venit în Demo (1 min)

```bash
# SPUNE: "Să verificăm că avem totul pregătit..."
cd ~/demo_seminar34
pwd
ls
```

### Pas 2: Operatorul Secvențial `;` (2 min)

SPUNE: "Cel mai simplu mod de a combina comenzi: punct și virgulă."

```bash
# PREDICȚIE: "Ce credeți că se întâmplă?"
echo "Prima" ; echo "A doua" ; echo "A treia"
```

EXPLICAȚIE: "Toate trei se execută, una după alta. Simplu, nu?"

```bash
# PREDICȚIE: "Dar dacă una din mijloc eșuează?"
echo "Start" ; ls /director_inexistent ; echo "Continuăm"
```

EXPLICAȚIE: "Observați! Chiar dacă ls eșuează, echo 'Continuăm' tot rulează. Punctul și virgulă NU verifică dacă comanda anterioară a reușit."

### Pas 3: Operatorul AND `&&` (3 min)

SPUNE: "Acum hai să vedem ce se întâmplă când ne pasă de rezultat..."

```bash
# PREDICȚIE: "Ce afișează asta?"
mkdir proiect && echo "Director creat!"
```

EXPLICAȚIE: "mkdir a reușit, deci && a permis echo să ruleze."

```bash

*(Bash-ul are o sintaxă urâtă, recunosc. Dar rulează peste tot, și asta contează enorm în practică.)*

# PREDICȚIE: "Dar dacă rulez din nou aceeași comandă?"
mkdir proiect && echo "Creat din nou!"
```

EXPLICAȚIE: "Ah-ha! De data asta mkdir EȘUEAZĂ (directorul există deja), deci echo NU mai rulează. Acesta e diferența față de punct și virgulă!"

```bash
# Demonstrație vizuală a diferenței
rm -rf proiect  # cleanup

# Cu ;
mkdir proiect ; mkdir proiect ; echo "După două mkdir-uri cu ;"
# Eroare, dar echo rulează

rm -rf proiect  # cleanup

# Cu &&
mkdir proiect && mkdir proiect && echo "După două mkdir-uri cu &&"
# Eroarea apare, echo NU rulează
```

### Pas 4: Operatorul OR `||` (3 min)

SPUNE: "OR e inversul lui AND - rulează doar dacă precedenta EȘUEAZĂ."

```bash
rm -rf proiect  # cleanup

# PREDICȚIE: "Ce se întâmplă aici?"
mkdir proiect || echo "Directorul deja există"
```

EXPLICAȚIE: "mkdir a reușit, deci || NU declanșează echo."

```bash
# PREDICȚIE: "Dar acum?"
mkdir proiect || echo "Directorul deja există"
```

EXPLICAȚIE: "A doua oară mkdir eșuează, deci || declanșează mesajul nostru de fallback."

### Pas 5: Combinație && și || (3 min)

SPUNE: "Acum vine partea interesantă - le combinăm!"

```bash
rm -rf proiect  # cleanup

# Pattern clasic: succes && mesaj_ok || mesaj_eroare
mkdir proiect && echo "✓ Creat!" || echo "✗ Eroare!"
```

```bash
# PREDICȚIE: "Dar dacă rulez din nou?"
mkdir proiect && echo "✓ Creat!" || echo "✗ Eroare!"
```

EXPLICAȚIE: "Acesta e pattern-ul pe care îl veți folosi cel mai des în scripturi - face ceva și raportează dacă a reușit sau nu."

> 💡 *Am observat că studenții care desenează diagrama pe hârtie înainte de a scrie codul au rezultate mult mai bune.*


### Pas 6: EROARE DELIBERATĂ - Ordinea Contează! (3 min)

SPUNE: "Acum vă arăt o greșeală pe care o fac TOȚI începătorii..."

```bash
rm -rf test_err  # cleanup

# SCRIE GREȘIT INTENȚIONAT:
mkdir test_err || echo "Eroare" && echo "Succes"
```

ÎNTREABĂ: "Funcționează corect. Dar ce se întâmplă dacă mkdir eșuează?"

```bash
# Nu șterge test_err, rulează din nou:
mkdir test_err || echo "Eroare" && echo "Succes"
```

SURPRIZĂ: Apare "Eroare" ȘI "Succes"!

EXPLICAȚIE: 
```
"Evaluarea e de la stânga la dreapta:
1. mkdir eșuează
2. || declanșează echo 'Eroare' (care REUȘEȘTE!)
3. && vede că echo a reușit, deci declanșează 'Succes'

ORDINEA CORECTĂ e: comandă && succes || eroare"
```

```bash
rm -rf test_err  # cleanup
mkdir test_err && echo "Succes" || echo "Eroare"  # Prima dată: 
mkdir test_err && echo "Succes" || echo "Eroare"  # A doua: Eroare

> 💡 La examenele din sesiunile trecute, această întrebare a picat în mod constant — deci merită atenție.

```

---

## SESIUNEA 2: REDIRECȚIONARE I/O (10 min)

### Pas 1: Output către Fișier `>` (2 min)

```bash
cd ~/demo_seminar34

# SPUNE: "Să vedem cum salvăm output-ul într-un fișier..."
echo "Prima linie" > output.txt
cat output.txt
```

```bash
# PREDICȚIE: "Ce se întâmplă dacă scriu din nou?"
echo "A doua linie" > output.txt
cat output.txt
```

EXPLICAȚIE: "Prima linie a dispărut! `>` SUPRASCRIE fișierul complet."

### Pas 2: Append `>>` (2 min)

```bash
# SPUNE: "Dacă vrem să ADĂUGĂM, folosim >>"
echo "Prima linie" > output.txt
echo "A doua linie" >> output.txt
echo "A treia linie" >> output.txt
cat output.txt
```

EXPLICAȚIE: "Acum avem toate trei liniile. `>>` adaugă la final."

### Pas 3: stderr vs stdout (3 min)

```bash

*Notă personală: Mulți preferă `zsh`, dar eu rămân la Bash pentru că e standardul pe servere. Consistența bate confortul.*

# SPUNE: "Acum partea mai complicată - erorile au propriul canal."

# PREDICȚIE: "Ce vedem aici?"
ls /home /director_inexistent
```

EXPLICAȚIE: "Vedem două lucruri DIFERITE: listarea lui /home (stdout) și eroarea (stderr). Ambele merg pe ecran, dar sunt canale separate."

```bash
# Redirecționăm doar stdout
ls /home /director_inexistent > doar_output.txt
cat doar_output.txt
# Eroarea TOT apare pe ecran!
```

```bash
# Redirecționăm doar stderr
ls /home /director_inexistent 2> doar_erori.txt
cat doar_erori.txt
# Output-ul apare pe ecran, eroarea e în fișier
```

```bash
# Redirecționăm ambele în fișiere DIFERITE
ls /home /director_inexistent > output.txt 2> erori.txt
cat output.txt
cat erori.txt
```

### Pas 4: Combinare stdout și stderr (3 min)

SPUNE: "Acum partea tricky - cum le punem pe ambele în același fișier?"

```bash
# PREDICȚIE: "Funcționează asta?"
ls /home /director_inexistent > totul.txt 2>&1
cat totul.txt
```

EXPLICAȚIE: "Da! `2>&1` înseamnă 'trimite stderr (2) unde merge stdout (1)'."

```bash
# GREȘEALĂ COMUNĂ - ordinea inversă:
ls /home /director_inexistent 2>&1 > totul2.txt
cat totul2.txt
# Eroarea a apărut pe ecran!
```

EXPLICAȚIE: 
```
"Ordinea contează!
CORECT:  > file 2>&1   (stdout→file, apoi stderr→unde e stdout)
GREȘIT:  2>&1 > file   (stderr→stdout(ecran), apoi stdout→file)

Sau folosiți shortcut-ul: &> file"
```

```bash
ls /home /director_inexistent &> totul3.txt
cat totul3.txt
```

---

## SESIUNEA 3: PIPELINE-URI ȘI FILTRE (15 min)

### Pas 1: Primul Pipe (2 min)

```bash
cd ~/demo_seminar34

# SPUNE: "Pipe-ul conectează output-ul unei comenzi la input-ul alteia."

# Simplu: câte linii are /etc/passwd?
cat /etc/passwd | wc -l
```

```bash
# Echivalent dar MAI EFICIENT:
wc -l < /etc/passwd
# De ce? Nu creăm proces suplimentar pentru cat.
```

### Pas 2: Construcție Incrementală (4 min)

SPUNE: "Hai să construim un pipeline complex, pas cu pas."

```bash
# OBIECTIV: Top 5 useri după număr de procese

# Pas 1: Listează procesele
ps aux

# Pas 2: Extrage doar coloana user (prima)
ps aux | awk '{print $1}'

# Pas 3: Sortează (NECESAR pentru uniq!)
ps aux | awk '{print $1}' | sort

# Pas 4: Numără duplicatele
ps aux | awk '{print $1}' | sort | uniq -c

# Pas 5: Sortează după număr (descrescător)
ps aux | awk '{print $1}' | sort | uniq -c | sort -rn

# Pas 6: Ia primele 5
ps aux | awk '{print $1}' | sort | uniq -c | sort -rn | head -5
```

EXPLICAȚIE: "Fiecare pas adaugă o modificare. E ca o linie de asamblare!"

### Pas 3: Capcana uniq (3 min)

SPUNE: "Acum o capcană în care cad 80% din începători..."

```bash
# PREDICȚIE: "Câte culori unice avem?"
cat colors.txt

# GREȘIT:
cat colors.txt | uniq
```

SURPRIZĂ: Încă apar duplicate!

EXPLICAȚIE: "uniq elimină doar duplicate CONSECUTIVE. Fără sort, nu funcționează!"

```bash
# CORECT:
cat colors.txt | sort | uniq
```

```bash
# Cu numărare și sortare după frecvență:
cat colors.txt | sort | uniq -c | sort -rn
```

### Pas 4: cut pentru CSV (3 min)

```bash
# SPUNE: "Să lucrăm cu date structurate..."
cat studenti.csv

# Extrage doar numele (coloana 1)
cut -d',' -f1 studenti.csv

# Extrage nume și nota
cut -d',' -f1,3 studenti.csv

# Fără header
tail -n +2 studenti.csv | cut -d',' -f1
```

Capcană:
```bash
# GREȘEALĂ COMUNĂ: delimitatorul default e TAB!
cut -f1 studenti.csv  # Nu funcționează cum ne așteptăm
# Trebuie ÎNTOTDEAUNA specificat: -d','
```

### Pas 5: tr pentru modificări (3 min)

```bash
# SPUNE: "tr lucrează cu CARACTERE, nu stringuri!"

# Lowercase → uppercase
echo "hello world" | tr 'a-z' 'A-Z'

# PREDICȚIE: "Ce face asta?"
echo "hello" | tr 'aeiou' '12345'
```

```bash
# GREȘEALĂ COMUNĂ: crede că înlocuiește stringuri
echo "hello" | tr 'he' 'HE'
# Output: HEllo (fiecare caracter separat!)
# Pentru stringuri, folosește sed: sed 's/he/HE/g'
```

---

## SESIUNEA 4: BUCLE (15 min)

### Pas 1: for cu Listă (3 min)

```bash
cd ~/demo_seminar34

# SPUNE: "Bucla for iterează prin elemente..."

# Lista explicită
for culoare in rosu verde albastru; do
    echo "Culoarea: $culoare"
done
```

```bash
# Cu brace expansion
for i in {1..5}; do
    echo "Numărul: $i"
done
```

```bash
# Cu fișiere (globbing)
for file in *.txt; do
    echo "Fișier: $file ($(wc -l < "$file") linii)"
done
```

### Pas 2: EROARE DELIBERATĂ - Brace Expansion cu Variabile (4 min)

SPUNE: "Acum vă arăt cea mai frecventă greșeală cu bucle..."

```bash
# PREDICȚIE: "Ce afișează asta?"
N=5
for i in {1..$N}; do
    echo $i
done
```

SURPRIZĂ: Output: `{1..5}` - literalmente!

EXPLICAȚIE: 
```
"Brace expansion se face la PARSE TIME, ÎNAINTE ca variabilele să fie evaluate!
Shell-ul vede {1..$N}, dar $N încă nu e expandat, deci nu știe să facă 1,2,3,4,5."
```

```bash
# SOLUȚIA 1: seq
for i in $(seq 1 $N); do
    echo $i
done

# SOLUȚIA 2: C-style for (RECOMANDAT)
for ((i=1; i<=N; i++)); do
    echo $i
done
```

### Pas 3: while (2 min)

```bash
# Counter simplu
count=1
while [ $count -le 5 ]; do
    echo "Count: $count"
    ((count++))
done
```

### Pas 4: Citire Fișier (3 min)

```bash
# SPUNE: "Metoda corectă de a citi un fișier linie cu linie..."

# Metoda CORECTĂ
while IFS= read -r line; do
    echo "Linia: $line"
done < colors.txt
```

```bash
# IFS= : păstrează spațiile
# -r : nu interpretează backslash
```

### Pas 5: EROARE DELIBERATĂ - Problema Subshell (3 min)

SPUNE: "Acum cea mai FRUSTRANTĂ problemă pentru începători..."

```bash
# PREDICȚIE: "Ce valoare va avea total la final?"
total=0
cat colors.txt | while read line; do
    ((total++))
    echo "În buclă: total=$total"
done
echo "După buclă: total=$total"
```

SURPRIZĂ: După buclă: total=0!

EXPLICAȚIE:
```
"Pipe-ul | creează un SUBSHELL - un proces copil separat!
Variabilele modificate în subshell NU se văd în shell-ul părinte.

while read ... done RULEAZĂ ÎN SUBSHELL ← aici e problema!"
```

```bash
# SOLUȚIA: redirecționare în loc de pipe
total=0
while read line; do
    ((total++))
done < colors.txt
echo "Corect: total=$total"
```

```bash
# SAU: Process Substitution (Bash 4+)
total=0
while read line; do
    ((total++))
done < <(cat colors.txt)
echo "Și asta funcționează: total=$total"
```

---

## DEMO-URI SPECTACULOASE (Pentru Hook/Pauze)

### Demo 1: Countdown Vizual

```bash
# Countdown cu clear
for i in {5..1}; do
    clear
    echo ""
    echo "    ╔═══════════════╗"
    echo "    ║               ║"
    echo "    ║       $i       ║"
    echo "    ║               ║"
    echo "    ╚═══════════════╝"
    sleep 1
done
clear
echo ""
echo "    ╔═══════════════╗"
echo "    ║               ║"
echo "    ║    START!     ║"
echo "    ║               ║"
echo "    ╚═══════════════╝"
```

### Demo 2: Spinner de Încărcare

```bash
# Loading spinner
echo -n "Se procesează: "
chars="/-\\|"
for i in {1..20}; do
    echo -ne "\b${chars:i%4:1}"
    sleep 0.1
done
echo -e "\b✓ Complet!"
```

### Demo 3: Analiza Live a Sistemului

```bash
# One-liner spectaculos
echo "=== TOP 5 PROCESE BY MEMORY ===" && \
ps aux --sort=-%mem | head -6 | \
awk 'NR==1 {printf "%-10s %5s %s\n", "USER", "MEM%", "COMMAND"} 
     NR>1  {printf "%-10s %5s %s\n", $1, $4, $11}'
```

### Demo 4: Pipeline Power

```bash
# Găsește cele mai mari 5 fișiere din /usr
echo "=== TOP 5 FIȘIERE DIN /usr ===" && \
find /usr -type f -printf '%s %p\n' 2>/dev/null | \
sort -rn | head -5 | \
while read size path; do
    printf "%'15d bytes → %s\n" "$size" "$path"
done
```

---

## CHEAT SHEET PENTRU INSTRUCTOR

### Comenzi Frecvente în Demo

```bash
# Cleanup rapid
rm -rf ~/demo_seminar34/* 2>/dev/null

# Reset fișiere test
# (rulează scriptul de setup din nou)

# Verificare rapidă ce există
ls -la ~/demo_seminar34/

# Clear cu header
clear; echo "=== DEMO: [NUME] ===" 
```

### Când Lucrurile Merg Prost

| Problemă | Soluție Rapidă |
|----------|----------------|
| Fișierul nu există | `ls -la` și recreează |
| Comanda nu se găsește | `which cmd` sau `type cmd` |
| Permisiuni | `chmod +x script.sh` |
| Sintaxă greșită | Verifică spații în `[ ]`, `;` înainte de `do` |
| Variabilă goală | `echo "VAR=[$VAR]"` pentru debug |

### Tranziții Între Secțiuni

```
"Acum că am văzut X, hai să trecem la Y care construiește pe ce tocmai am învățat..."

"Înainte să continuăm, are cineva întrebări despre X?"

"Observați cum Y e de fapt similar cu X, doar că..."
```

---

## TROUBLESHOOTING LIVE CODING

### Dacă Comanda Nu Funcționează

1. Nu te panica - studenții învață din erori
2. Verbalizează: "Hmm, să vedem ce s-a întâmplat..."
3. Debug live: `echo $?`, `echo "$variabila"`
4. Învață din greșeală: "Ah, am uitat să... Asta e o greșeală frecventă!"

### Dacă Pierzi Firul

1. Recapitulează: "Deci, ce am făcut până acum..."
2. Verifică fișierele: `ls`, `cat fisier`
3. Reporrnește de la un punct cunoscut

### Dacă Studenții Sunt Confuzi

1. Oprește-te: "Să clarificăm..."
2. Desenează: Schema pe tablă
3. Simplifică: Exemplu mai mic
4. Repetă: Cu alte cuvinte

---

*Ghid Live Coding generat pentru ASE București - CSIE*  
*Seminar 2: Operatori, Redirecționare, Filtre, Bucle*
