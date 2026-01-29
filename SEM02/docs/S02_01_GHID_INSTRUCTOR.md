# Ghid Instructor: Seminarul 3-4
## Sisteme de Operare | Operatori, Redirecționare, Filtre, Bucle

Durată totală: 100 minute (2 × 50 min + pauză 10 min)  
**abordare**: Limbaj ca Vehicul (Bash pentru concepte SO)  
Nivel: Începător-Intermediar (presupune Seminar 1 completat)  
Versiune: 1.0 | Actualizat: Ianuarie 2025

---

## OBIECTIVE SESIUNE

La finalul acestui seminar, studenții vor putea:

1. Combina comenzi folosind operatorii de control (`;`, `&&`, `||`, `&`, `|`) cu înțelegerea semanticii fiecăruia
2. Redirecționa fluxuri I/O folosind `>`, `>>`, `<`, `<<`, `<<<` și să manipuleze file descriptors
3. Construi pipeline-uri eficiente înlănțuind filtre text pentru procesare de date

> 💡 Am avut studenți care au învățat Bash în două săptămâni pornind de la zero — deci se poate, cu practică consistentă.

4. Utiliza filtrele Unix (`sort`, `uniq`, `cut`, `paste`, `tr`, `wc`, `head`, `tail`, `tee`) în contexte practice
5. Scrie bucle (`for`, `while`, `until`) cu control flow (`break`, `continue`) pentru automatizare
6. Depana scripturi folosind tehnici de troubleshooting și înțelegerea erorilor comune

---

## PREGĂTIRE ÎNAINTE DE SEMINAR

### Verificări Tehnice (15 minute înainte)

```bash
# === VERIFICARE COMPLETĂ MEDIU ===

# 1. Verifică versiunea Bash (minim 4.0)
echo "Bash version: $BASH_VERSION"
[[ ${BASH_VERSION%%.*} -ge 4 ]] && echo "✓ OK" || echo "✗ Upgrade necesar!"

*(Bash-ul are o sintaxă urâtă, recunosc. Dar rulează peste tot, și asta contează enorm în practică.)*


> 💡 Experiența arată că debugging-ul e 80% citit cu atenție și 20% scris cod nou.


# 2. Verifică comenzile esențiale
for cmd in sort uniq cut paste tr wc head tail tee cat echo; do
    command -v $cmd &>/dev/null && echo "✓ $cmd" || echo "✗ $cmd LIPSEȘTE!"
done

# 3. Verifică tools opționale pentru demo-uri spectaculoase
echo -e "\n--- Tools opționale ---"
for cmd in figlet lolcat cowsay pv dialog tree; do
    command -v $cmd &>/dev/null && echo "✓ $cmd" || echo "○ $cmd (opțional)"
done

# 4. Crează director de lucru curat
rm -rf ~/demo_seminar34 2>/dev/null
mkdir -p ~/demo_seminar34
cd ~/demo_seminar34

# 5. Verifică spațiu disk
df -h ~ | awk 'NR==2 {print "Spațiu disponibil: " $4}'

# 6. Testează redirecționarea
echo "test" > /tmp/test_redirect && rm /tmp/test_redirect && echo "✓ Redirecționare OK"
```

### Materiale Necesare

| Material | Locație | Verificare |
|----------|---------|------------|
| Hook demo | `scripts/demo/S02_01_hook_demo.sh` | `bash -n script.sh` |
| Setup script | `scripts/bash/S02_01_setup_seminar.sh` | Rulează cu 5 min înainte |
| Slide-uri PI | `docs/S02_03_PEER_INSTRUCTION.md` | Deschis în browser |
| Cheat sheet | `docs/S02_09_CHEAT_SHEET_VIZUAL.md` | Proiectat pe ecran secundar |
| Timer | Telefon sau timer online | Setat pentru 5-min intervals |

### Setup Terminal Recomandat

```bash
# === CONFIGURARE TERMINAL PENTRU VIZIBILITATE ===

# PS1 scurt și clar (pentru demo)
export PS1='[\u@demo \W]\$ '

# Alias-uri utile pentru demo
alias cls='clear'
alias ll='ls -la'
alias demo='cd ~/demo_seminar34'

# Font: minim 18pt pentru vizibilitate
# Recomandare: Fira Code sau Ubuntu Mono

# Culori terminal: fundal întunecat, text luminos
# Contrast ridicat pentru proiecție

# Deschide 2 terminale side-by-side:
# - Stânga: pentru comenzi
# - Dreapta: pentru output/monitorizare
```

### Pregătire Fișiere de Test

```bash
# === CREARE FIȘIERE DEMO ===
cd ~/demo_seminar34

# Fișier pentru demonstrații sort/uniq
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

# Fișier CSV pentru cut/paste
cat > studenti.csv << 'EOF'
nume,grupa,nota
Popescu Ion,1234,9
Ionescu Maria,1234,10
Georgescu Ana,1235,8
Vasilescu Dan,1235,7
Marinescu Eva,1234,9
EOF

# Fișier log simulat pentru filtrare
cat > access.log << 'EOF'
192.168.1.1 - - [10/Jan/2025:10:00:01] "GET /index.html" 200
192.168.1.2 - - [10/Jan/2025:10:00:02] "GET /style.css" 200
192.168.1.1 - - [10/Jan/2025:10:00:03] "POST /login" 401
192.168.1.3 - - [10/Jan/2025:10:00:04] "GET /admin" 403
192.168.1.1 - - [10/Jan/2025:10:00:05] "POST /login" 200
192.168.1.2 - - [10/Jan/2025:10:00:06] "GET /dashboard" 200
192.168.1.4 - - [10/Jan/2025:10:00:07] "GET /api/data" 500
EOF

echo "✓ Fișiere de test create în ~/demo_seminar34"
ls -la
```

---

## TIMELINE DETALIATĂ - PRIMA PARTE (50 min)

### [0:00-0:05] HOOK: Demo Spectaculoasă cu Pipes

Scop: Captează atenția demonstrând puterea combinării comenzilor într-un pipeline vizual și impresionant.

Rulează:
```bash
cd ~/demo_seminar34
bash ../path/to/scripts/demo/S02_01_hook_demo.sh
# SAU demo manual dacă scriptul nu e disponibil:
```

Demo manual (backup):
```bash
# SPUNE: "Azi vom învăța să facem ASTA..."
clear
echo -e "\n\033[1;36m>>> PUTEREA LINUX: UN SINGUR RÂND DE COD <<<\033[0m\n"
sleep 1

# One-liner spectaculos
echo "Câte procese rulează fiecare user? Sortate descrescător?"
sleep 1
ps aux | awk '{print $1}' | sort | uniq -c | sort -rn | head -10

echo -e "\n\033[1;33mUn singur rând. Fără variabile. Fără bucle explicite.\033[0m"
echo -e "\033[1;32mASTA e puterea pipeline-urilor Unix!\033[0m\n"
```

Note instructor:
- Lasă output-ul pe ecran 10-15 secunde pentru impact
- ÎNTREABĂ: "Câți dintre voi ar fi putut scrie asta acum?"
- SPUNE: "La finalul seminarului, veți putea face asta și mai mult"
- Tranziție: "Dar să începem cu fundațiile..."

Fallback (dacă lipsesc tools):
```bash
# Versiune minimalistă fără dependențe
ps aux | awk '{print $1}' | sort | uniq -c | sort -rn | head -5
# Funcționează pe orice sistem
```

---

### [0:05-0:10] PEER INSTRUCTION Q1: Exit Codes și Operatori

Afișează pe ecran (slide sau terminal):

```
╔════════════════════════════════════════════════════════════════╗
║  🗳️ PEER INSTRUCTION Q1: Operatori de Control                 ║
╠════════════════════════════════════════════════════════════════╣
║                                                                ║
║  ls /home && echo "OK" || echo "FAIL"                         ║
║  ls /directorul_inexistent && echo "OK" || echo "FAIL"        ║
║                                                                ║
║  Ce se afișează pentru A DOUA comandă?                         ║
║                                                                ║
║  A) FAIL                                                       ║
║  B) OK                                                         ║
║  C) Nimic - comanda eșuează silențios                          ║
║  D) Mesajul de eroare ls + FAIL                                ║
║                                                                ║
║  ⏱️ VOT: 1 minut | DISCUȚIE: 2 minute | REVOT: 30 sec          ║
╚════════════════════════════════════════════════════════════════╝
```

Protocol detaliat:

| Timp | Acțiune | Ce faci |
|------|---------|---------|
| 0:00-1:00 | Vot individual | "Ridicați mâna pentru A... B... C... D..." |
| 1:00-1:30 | Notează distribuția | Scrie pe tablă procentele |
| 1:30-3:30 | Discuție perechi | "Convingeți vecinul!" |
| 3:30-4:00 | Revot | Compară cu primul vot |
| 4:00-5:00 | Explicație | Demo + clarificare |

Răspuns corect: D

| Distractor | Misconceptie vizată |
|------------|---------------------|
| A | Crede că eroarea stderr e suprimată automat |
| B | Nu înțelege că `ls` eșuează pentru directoare inexistente |
| C | Confuzie cu `2>/dev/null` sau comportament silențios |
| D ✓ | CORECT: stderr afișează eroarea, apoi || declanșează "FAIL" |

După vot, demonstrează LIVE:
```bash
# SPUNE: "Hai să vedem exact ce se întâmplă..."
ls /home && echo "OK" || echo "FAIL"
# Output: OK (listare + OK)

ls /directorul_care_nu_exista && echo "OK" || echo "FAIL"  
# Output: "ls: cannot access...": No such file..." + FAIL

# EXPLICAȚIE:
# 1. ls încearcă să listeze directorul
# 2. ls EȘUEAZĂ (exit code != 0)
# 3. stderr afișează mesajul de eroare (merge la terminal implicit)
# 4. && NU se execută (condiția falsă)
# 5. || SE execută (fallback la eroare)
# 6. "FAIL" apare pe stdout

echo "Exit code al ultimei comenzi: $?"
```

Observație: Dacă studenții sunt confuzi despre stderr vs stdout:
```bash
# Demonstrație clară
ls /inexistent > /dev/null        # eroarea APARE (stderr nu e redirecționat)
ls /inexistent 2> /dev/null       # eroarea DISPARE (stderr suprimat)
ls /inexistent &> /dev/null       # totul suprimat
```

---

### [0:10-0:25] LIVE CODING: Operatori de Control

PRINCIPIU: Anunț → Predicție → Execuție → Explicație

#### Segment 1: Secvențial vs Condiționat (5 min)

```bash

*Notă personală: Mulți preferă `zsh`, dar eu rămân la Bash pentru că e standardul pe servere. Consistența bate confortul.*

# === PREGĂTIRE ===
cd ~/demo_seminar34
rm -rf test_dir 2>/dev/null  # cleanup

# === OPERATORUL ; (SECVENȚIAL) ===
# SPUNE: "Cel mai simplu: punct și virgulă. Rulează tot, indiferent de rezultat."

# PREDICȚIE: "Ce credeți că se întâmplă?"
echo "Prima" ; echo "A doua" ; echo "A treia"
# Toate se execută

# DEMONSTRAȚIE: ; ignoră erorile
ls /inexistent ; echo "Merge mai departe"
# Eroarea apare DAR echo rulează oricum!

# === OPERATORUL && (AND) ===
# SPUNE: "AND logic: continuă DOAR dacă precedenta reușește"

# PREDICȚIE
mkdir proiect && echo "Director creat!"
# Output: Director creat!

# PREDICȚIE: dar dacă directorul există deja?
mkdir proiect && echo "Creat din nou!"
# Output: mkdir: cannot create... (echo NU rulează)

# === OPERATORUL || (OR) ===
# SPUNE: "OR logic: rulează DOAR dacă precedenta eșuează"

mkdir proiect || echo "Directorul există deja"
# Output: Directorul există deja

# CLEANUP
rm -rf proiect
```

#### Segment 2: Combinații Practice (4 min)

```bash
# === PATTERN-URI COMUNE ===

# Pattern 1: "Încearcă sau raportează eroare"
# SPUNE: "Cel mai util pattern pentru scripturi solide"
cd /inexistent || echo "Nu am putut schimba directorul"

# Pattern 2: "Fă ceva și confirmă"
mkdir backup && cp important.txt backup/ && echo "Backup complet"

# Pattern 3: "Încearcă și fallback"
# SPUNE: "Verifică și creează doar dacă nu există"
[ -d backup ] || mkdir backup
ls -d backup  # confirmă existența

# Pattern 4: Comanda completă cu succes/eroare
# SPUNE: "Acesta e pattern-ul ideal pentru scripturi:"
rm -rf temp_test
mkdir temp_test && echo "✓ Creat cu succes" || echo "✗ Eroare la creare"
# Prima dată:
mkdir temp_test && echo "✓ Creat cu succes" || echo "✗ Eroare la creare"  
# A doua oară: eroare (există deja)
```

#### Segment 3: Pipes - Fundament (4 min)

```bash
# === OPERATORUL | (PIPE) ===
# SPUNE: "Pipe-ul conectează stdout al unei comenzi la stdin alteia"

# Construcție INCREMENTALĂ:
# Pas 1: Output simplu
cat /etc/passwd

# Pas 2: Filtrăm cu head
cat /etc/passwd | head -5

# Pas 3: Extragem doar usernames
cat /etc/passwd | head -5 | cut -d':' -f1

# Pas 4: Sortăm
cat /etc/passwd | cut -d':' -f1 | sort

# Pas 5: Numărăm
cat /etc/passwd | cut -d':' -f1 | sort | wc -l

# SPUNE: "Fiecare | trimite output-ul mai departe. E ca o linie de asamblare."
```

#### Segment 4: Background Jobs (2 min)

```bash
# === OPERATORUL & (BACKGROUND) ===
# SPUNE: "Ampersand trimite comanda în fundal"

# Demo simplu
sleep 5 &
echo "Shell-ul e liber! Comanda rulează în fundal."
jobs  # arată job-urile active

# Așteptăm să termine
wait
echo "Acum sleep a terminat"

# Demo mai vizual
sleep 3 & echo "Job pornit cu PID: $!"
# $! = PID-ul ultimului proces din background
```

#### [0:23] EROARE DELIBERATĂ

SPUNE: "Acum să vedem o greșeală pe care o fac TOȚI începătorii..."

```bash
# SCRIE GREȘIT INTENȚIONAT:
mkdir test_err || echo "Eroare" && echo "Succes"
# Prima rulare: creează directorul

# ÎNTREABĂ: "Ce credeți că se întâmplă dacă rulez din nou?"
mkdir test_err || echo "Eroare" && echo "Succes"
# Output: mkdir: cannot create... + "Eroare" + "Succes"
# WAT?! De ce apare și "Succes"?

# EXPLICAȚIE:
# Ordinea evaluării: stânga-dreapta, fără precedență specială!
# mkdir eșuează → || declanșează "Eroare" (succes!) → && declanșează "Succes"

# SOLUȚIA CORECTĂ - folosește grupare:
mkdir test_err && echo "Succes" || echo "Eroare"
# SAU cu {}:
mkdir test_err || { echo "Eroare"; false; }

rm -rf test_err
```

---

### [0:25-0:30] PARSONS PROBLEM #1: Pipeline Building

Afișează pe ecran:

```
╔════════════════════════════════════════════════════════════════════╗
║  🧩 PARSONS PROBLEM #1: Construiește Pipeline-ul                   ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  OBIECTIV: Găsește top 5 useri după număr de procese              ║
║                                                                    ║
║  ARANJEAZĂ LINIILE (una e distractor!):                           ║
║  ─────────────────────────────────────────────────                 ║
║     | sort -rn                                                     ║
║     | head -5                                                      ║
║     ps aux                                                         ║
║     | uniq -c                                                      ║
║     | sort                                                         ║
║     | awk '{print $1}'                                             ║
║     | grep -v USER                         ← DISTRACTOR            ║
║  ─────────────────────────────────────────────────                 ║
║                                                                    ║
║  ⏱️ TIMP: 3 minute | MOD: Perechi                                  ║
╚════════════════════════════════════════════════════════════════════╝
```

Soluția corectă:
```bash
ps aux | awk '{print $1}' | sort | uniq -c | sort -rn | head -5
```

Explicație pentru instructor:
1. `ps aux` - listează toate procesele
2. `awk '{print $1}'` - extrage doar coloana user
3. `sort` - sortează alfabetic (NECESAR pentru uniq!)
4. `uniq -c` - numără aparițiile consecutive
5. `sort -rn` - sortează numeric descrescător
6. `head -5` - primele 5 rezultate

Distractor `grep -v USER`: 
- Ar elimina header-ul, dar `awk` deja îl include în output
- Nu e greșit, dar e redundant și nu face parte din flow-ul optim

După rezolvare, demonstrează:
```bash
# Rulează soluția completă
ps aux | awk '{print $1}' | sort | uniq -c | sort -rn | head -5

# Arată de ce fiecare pas e necesar
ps aux | awk '{print $1}' | head  # fără sort - useri repetat
ps aux | awk '{print $1}' | uniq -c | head  # fără sort - count greșit!
ps aux | awk '{print $1}' | sort | uniq -c | head  # corect dar nesortat
```

---

### [0:30-0:45] SPRINT #1: Pipeline Master

Afișează pe ecran:

```
╔════════════════════════════════════════════════════════════════════╗
║  🏃 SPRINT #1: Pipeline Master                                     ║
║  ⏱️ DURATĂ: 15 minute | MOD: Pair Programming                      ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  📋 CERINȚE:                                                       ║
║                                                                    ║
║  1. [3 min] Creează un pipeline care găsește și numără            ║
║     extensiile unice de fișiere din /etc:                         ║
║     OUTPUT: "  15 .conf" (format: count extensie)                 ║
║                                                                    ║
║  2. [5 min] Din fișierul /etc/passwd, extrage și afișează:        ║
║     - Doar userii cu shell /bin/bash                              ║
║     - Sortați alfabetic                                           ║
║     - Doar primii 5                                               ║
║                                                                    ║
║  3. [5 min] Analizează access.log și găsește:                     ║
║     - Cele mai frecvente IP-uri                                   ║
║     - Top 3, cu număr de accese                                   ║
║                                                                    ║
║  🔄 SWITCH DRIVER/NAVIGATOR la minutul 7!                         ║
║                                                                    ║
║  ✓ VERIFICARE: Rulează comenzile și compară output                ║
╚════════════════════════════════════════════════════════════════════╝
```

Soluții pentru instructor:

```bash
# Exercițiul 1: Extensii din /etc
find /etc -type f 2>/dev/null | sed 's/.*\./\./' | grep '^\.' | sort | uniq -c | sort -rn | head
# SAU mai simplu:
ls /etc | grep '\.' | rev | cut -d'.' -f1 | rev | sort | uniq -c | sort -rn

# Exercițiul 2: Useri cu bash
grep '/bin/bash$' /etc/passwd | cut -d':' -f1 | sort | head -5

# Exercițiul 3: Top IP-uri din access.log
cut -d' ' -f1 access.log | sort | uniq -c | sort -rn | head -3
# SAU cu awk:
awk '{print $1}' access.log | sort | uniq -c | sort -rn | head -3
```

Management timp:
- 0:30 - Începe timer 15 min
- 0:37 - Anunță "SWITCH!" (7 min)
- 0:43 - "Mai sunt 2 minute!"
- 0:45 - "Stop! Să vedem soluțiile"

Variante acceptabile - studenții pot folosi diferite combinații care produc același rezultat.

---

### [0:45-0:50] PEER INSTRUCTION Q2: Redirecționare

Afișează pe ecran:

```
╔════════════════════════════════════════════════════════════════════╗
║  🗳️ PEER INSTRUCTION Q2: Ordinea Redirecționării                  ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  Care comandă trimite AMBELE (stdout ȘI stderr) în out.txt?       ║
║                                                                    ║
║  A) ls /home /inexistent > out.txt 2>&1                           ║
║  B) ls /home /inexistent 2>&1 > out.txt                           ║
║  C) Ambele fac același lucru                                       ║
║  D) Niciuna - trebuie folosit &>                                  ║
║                                                                    ║
║  ⏱️ VOT: 1 minut | DISCUȚIE: 2 minute | REVOT: 30 sec             ║
╚════════════════════════════════════════════════════════════════════╝
```

Răspuns corect: A

| Distractor | Misconceptie vizată |
|------------|---------------------|
| A ✓ | CORECT: stdout → fișier, apoi stderr → unde e stdout (fișier) |
| B | Stderr → stdout (terminal), apoi stdout → fișier. Stderr rămâne pe terminal! |
| C | Ordinea CONTEAZĂ în redirecționare |
| D | &> e valid, dar nu e singura soluție |

Demonstrație LIVE:
```bash
# Varianta A (CORECT)
ls /home /inexistent > out_a.txt 2>&1
cat out_a.txt
# Conține: listarea + eroarea

# Varianta B (PARȚIAL)
ls /home /inexistent 2>&1 > out_b.txt
# Eroarea apare pe ecran!
cat out_b.txt
# Conține: doar listarea

# EXPLICAȚIE cu diagrama:
echo "
Varianta A:
1. > out.txt  : stdout (fd1) → out.txt
2. 2>&1       : stderr (fd2) → unde e fd1 (out.txt)
Rezultat: ambele în fișier

Varianta B:
1. 2>&1       : stderr (fd2) → unde e fd1 (terminal!)
2. > out.txt  : stdout (fd1) → out.txt
Rezultat: stdout în fișier, stderr pe terminal
"

rm out_a.txt out_b.txt
```

---

## PAUZĂ 10 MINUTE

Pe ecran în timpul pauzei (lasă să ruleze):

```bash
# Screensaver educativ - rulează în loop
while true; do
    clear
    echo -e "\n\033[1;36m=== FUN FACTS DESPRE PIPES ===\033[0m\n"
    
    facts=(
        "Pipe-ul | a fost inventat de Doug McIlroy în 1973"
        "Filosofia Unix: 'Do one thing and do it well'"
        "Un pipeline poate avea teoretic oricâte comenzi"
        "Pipe-urile folosesc buffer de 64KB în Linux modern"
        "Simbolul | se numește 'vertical bar' sau 'pipe'"
        "Ken Thompson a implementat pipe-ul în Unix într-o noapte"
        "Named pipes (FIFO) persistă pe disk, spre deosebire de | "
    )
    
    echo "${facts[$RANDOM % ${#facts[@]}]}"
    
    echo -e "\n\033[1;33mPauză - revenim în câteva minute...\033[0m"
    
    sleep 15
done
```

Sau mai simplu:
```bash
# Ceva vizual interesant
watch -n 1 'echo "Procese: $(ps aux | wc -l) | Memorie: $(free -h | awk "/Mem:/ {print \$3}")"'
```

---

## TIMELINE DETALIATĂ - A DOUA PARTE (50 min)

### [0:00-0:05] REACTIVARE: Quiz Rapid

Format: Întrebări rapide cu răspuns verbal sau mâini ridicate

```
╔═══════════════════════════════════════════════════════════════════╗
║  🔄 QUIZ RAPID DE REACTIVARE (răspundeți verbal!)                ║
╠═══════════════════════════════════════════════════════════════════╣
║                                                                   ║
║  Q1: Ce operator folosesc dacă vreau să execut o comandă         ║
║      DOAR dacă precedenta a EȘUAT?                                ║
║      → Răspuns: ||                                                ║
║                                                                   ║
║  Q2: Cum redirecționez DOAR mesajele de eroare într-un fișier?   ║
║      → Răspuns: 2> fisier.txt                                    ║
║                                                                   ║
║  Q3: Ce comandă folosesc pentru a număra liniile unui fișier?    ║
║      → Răspuns: wc -l                                            ║
║                                                                   ║
║  BONUS: Cum fac să adaug la un fișier fără să-l suprascriu?      ║
║      → Răspuns: >> (dublu mai mare)                              ║
║                                                                   ║
╚═══════════════════════════════════════════════════════════════════╝
```

---

### [0:05-0:15] LIVE CODING: Filtre de Text

#### Segment 1: sort și uniq - Capcana Clasică (4 min)

```bash
cd ~/demo_seminar34

# Demonstrație cu fișierul colors.txt
cat colors.txt

# PREDICȚIE: "Ce credeți că face uniq singur?"
cat colors.txt | uniq
# SURPRIZĂ! Încă apar duplicate!

# EXPLICAȚIE: uniq elimină doar CONSECUTIVE duplicates
# SPUNE: "Aceasta e greșeala #1 a începătorilor!"

# SOLUȚIA: sort ÎNAINTE de uniq
cat colors.txt | sort | uniq

# Cu numărare
cat colors.txt | sort | uniq -c

# Sortat după frecvență
cat colors.txt | sort | uniq -c | sort -rn
```

#### Segment 2: cut și câmpuri (3 min)

```bash
# Demonstrație cu CSV
cat studenti.csv

# Extrage doar numele (coloana 1)
cut -d',' -f1 studenti.csv

# Extrage nume și nota (coloanele 1 și 3)
cut -d',' -f1,3 studenti.csv

# Capcană: delimitatorul implicit e TAB, nu virgulă!
# Demonstrație eroare comună:
cut -f1 studenti.csv  # Nu funcționează cum ne așteptăm!
```

#### Segment 3: tr - modificări (3 min)

```bash
# tr lucrează cu CARACTERE, nu stringuri!

# Lowercase to uppercase
echo "hello world" | tr 'a-z' 'A-Z'

# Înlocuire caractere
echo "hello" | tr 'aeiou' '12345'  # h2ll4

# Ștergere caractere
echo "hello123world" | tr -d '0-9'  # helloworld

# Squeeze (comprimare repetări)
echo "heeellooo" | tr -s 'eo'  # helo

# Capcană: tr NU înlocuiește stringuri!
echo "hello" | tr 'hell' 'HELL'  # HELLo (fiecare caracter separat)
```

#### Segment 4: Pipeline Complex (2 min)

```bash
# Analiza log-ului - demonstrație completă
cat access.log

# Găsește cele mai frecvente coduri HTTP
awk '{print $9}' access.log | sort | uniq -c | sort -rn

# Găsește IP-urile cu erori (4xx, 5xx)
grep -E ' [45][0-9]{2}$' access.log | awk '{print $1}' | sort | uniq -c
```

---

### [0:15-0:25] LIVE CODING: Bucle

#### Segment 1: for cu listă (3 min)

```bash
# For simplu cu listă explicită
for culoare in rosu verde albastru; do
    echo "Culoarea: $culoare"
done

# For cu brace expansion
for i in {1..5}; do
    echo "Numărul: $i"
done

# For cu globbing (fișiere)
for fisier in *.txt; do
    echo "Fișier găsit: $fisier ($(wc -l < "$fisier") linii)"
done
```

#### Segment 2: Capcana Brace Expansion (3 min)

```bash
# EROARE DELIBERATĂ - cea mai comună greșeală cu bucle!

N=5
# PREDICȚIE: "Ce afișează asta?"
for i in {1..$N}; do
    echo $i
done
# Output: {1..5} ← NU funcționează!

# EXPLICAȚIE: Brace expansion se face la PARSE TIME, înainte de variable expansion
# Soluții:

# Soluția 1: seq
for i in $(seq 1 $N); do echo $i; done

# Soluția 2: C-style for
for ((i=1; i<=N; i++)); do echo $i; done

# Soluția 3: eval (nu recomandat)
# eval "for i in {1..$N}; do echo \$i; done"
```

#### Segment 3: while și problema subshell (4 min)

```bash
# While simplu
count=1
while [ $count -le 5 ]; do
    echo "Count: $count"
    ((count++))
done

# Citire fișier - metoda corectă
while IFS= read -r line; do
    echo "Linia: $line"
done < colors.txt

# CAPCANA SUBSHELL - demonstrație!
total=0
cat colors.txt | while read line; do
    ((total++))
    echo "În buclă: total=$total"
done
echo "După buclă: total=$total"  # 0! De ce?!

# EXPLICAȚIE: pipe creează SUBSHELL, variabilele nu persistă!

# SOLUȚIA: redirect în loc de pipe
total=0
while read line; do
    ((total++))
done < colors.txt
echo "Corect: total=$total"  # 8
```

---

### [0:25-0:30] PEER INSTRUCTION Q3: Subshell Problem

Afișează pe ecran:

```
╔════════════════════════════════════════════════════════════════════╗
║  🗳️ PEER INSTRUCTION Q3: Variabile și Pipe                        ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  count=0                                                           ║
║  echo -e "a\nb\nc" | while read x; do ((count++)); done           ║
║  echo $count                                                       ║
║                                                                    ║
║  Ce valoare afișează echo $count?                                  ║
║                                                                    ║
║  A) 3                                                              ║
║  B) 0                                                              ║
║  C) 1                                                              ║
║  D) Eroare de sintaxă                                              ║
║                                                                    ║
║  ⏱️ VOT: 1 minut | DISCUȚIE: 2.5 minute | REVOT: 30 sec           ║
╚════════════════════════════════════════════════════════════════════╝
```

Răspuns corect: B (0)

| Distractor | Misconceptie vizată |
|------------|---------------------|
| A | Nu înțelege subshell-ul creat de pipe |
| B ✓ | CORECT: while rulează în subshell, count se modifică acolo |
| C | Confuzie cu semantica buclei |
| D | Sintaxa e validă |

Demonstrație și soluție:
```bash
# Problema
count=0
echo -e "a\nb\nc" | while read x; do ((count++)); done
echo $count  # 0!

# Soluția 1: Process Substitution
count=0
while read x; do ((count++)); done < <(echo -e "a\nb\nc")
echo $count  # 3

# Soluția 2: Here String
count=0
while read x; do ((count++)); done <<< "$(echo -e 'a\nb\nc')"
echo $count  # 3
```

---

### [0:30-0:43] SPRINT #2: Filter & Loop Challenge

Afișează pe ecran:

```
╔════════════════════════════════════════════════════════════════════╗
║  🏃 SPRINT #2: Filter & Loop Challenge                             ║
║  ⏱️ DURATĂ: 13 minute | MOD: Pair Programming                      ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  📋 TASK: Creează scriptul file_stats.sh                          ║
║                                                                    ║
║  Scriptul trebuie să:                                              ║
║  1. Primească un director ca argument (default: directorul curent)║
║  2. Pentru fiecare fișier .txt din acel director:                 ║
║     - Afișează numele fișierului                                  ║
║     - Numărul de linii                                            ║
║     - Numărul de cuvinte                                          ║
║  3. La final, afișează totalul                                    ║
║                                                                    ║
║  FORMAT OUTPUT:                                                    ║
║  colors.txt: 8 linii, 8 cuvinte                                   ║
║  studenti.csv: 6 linii, 6 cuvinte                                 ║
║  ---                                                              ║
║  TOTAL: 14 linii, 14 cuvinte                                      ║
║                                                                    ║
║  🔄 SWITCH DRIVER/NAVIGATOR la minutul 6!                         ║
║                                                                    ║
║  💡 HINT: wc -l, wc -w, for/while, variabile pentru total        ║
╚════════════════════════════════════════════════════════════════════╝
```

Soluție pentru instructor:
```bash
#!/bin/bash
# file_stats.sh - Statistici fișiere text

dir="${1:-.}"  # default: directorul curent
total_lines=0
total_words=0

for file in "$dir"/*.txt; do
    [ -f "$file" ] || continue  # skip dacă nu există fișiere
    
    lines=$(wc -l < "$file")
    words=$(wc -w < "$file")
    
    echo "$(basename "$file"): $lines linii, $words cuvinte"
    
    ((total_lines += lines))
    ((total_words += words))
done

echo "---"
echo "TOTAL: $total_lines linii, $total_words cuvinte"
```

---

### [0:43-0:48] EXERCIȚIU LLM

Afișează pe ecran:

```
╔════════════════════════════════════════════════════════════════════╗
║  🤖 EXERCIȚIU LLM: Evaluatorul de Pipeline-uri (5 min)            ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  📋 INDIVIDUAL - folosește ChatGPT/Claude/Gemini                   ║
║                                                                    ║
║  PROMPT DE FOLOSIT:                                                ║
║  "Generează un pipeline Linux care analizează fișierul            ║
║   /var/log/syslog și găsește cele mai frecvente mesaje            ║
║   de eroare din ultima oră"                                       ║
║                                                                    ║
║  EVALUEAZĂ REZULTATUL:                                             ║
║  1. ✅ Funcționează? (testează pe mașina ta!)                      ║
║  2. 🤔 E eficient? (ar merge optimizat?)                          ║
║  3. ⚠️ Ce presupuneri face? (format log, existență fișier)        ║
║  4. 🔧 Cum l-ai îmbunătăți?                                        ║
║                                                                    ║
║  SCRIE observațiile în REFLECTION.txt                              ║
╚════════════════════════════════════════════════════════════════════╝
```

Note instructor:
- Dacă studenții nu au acces la LLM, oferă un exemplu generat
- Discuție scurtă: ce a funcționat, ce nu
- Subliniază: AI-ul nu înlocuiește înțelegerea, dar accelerează

---

### [0:48-0:50] REFLECTION CHECKPOINT

Afișează pe ecran:

```
╔════════════════════════════════════════════════════════════════════╗
║  🧠 REFLECTION CHECKPOINT (2 min)                                  ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  Deschide un fișier text și răspunde:                             ║
║                                                                    ║
║  1. CE AM ÎNVĂȚAT AZI:                                             ║
║     (scrie 2-3 concepte noi)                                       ║
║                                                                    ║
║  2. CE NU AM ÎNȚELES COMPLET:                                      ║
║     (scrie 1-2 întrebări rămase)                                   ║
║                                                                    ║
║  3. CUM VOI FOLOSI ASTA:                                           ║
║     (scrie 1 exemplu practic din viața ta)                        ║
║                                                                    ║
║  📝 Salvează ca REFLECTION.txt - va fi parte din temă!            ║
╚════════════════════════════════════════════════════════════════════╝
```

---

## TROUBLESHOOTING COMUN

| Problemă | Simptom | Soluție Rapidă |
|----------|---------|----------------|
| `command not found` | Comanda nu există | `which cmd` sau `apt install` |
| Pipe nu funcționează | Output gol | Verifică fiecare segment separat |
| `uniq` nu elimină duplicatele | Duplicate rămân | Adaugă `sort` înainte |
| Variabila e goală după pipe | `$var` = "" | Folosește `< <()` în loc de `\|` |
| `{1..$N}` nu expandează | Output literal | Folosește `seq` sau for C-style |
| Redirecționare nu funcționează | Fișier gol | Verifică permisiuni și cale |
| Script nu rulează | Permission denied | `chmod +x script.sh` |
| Eroare "bad substitution" | Sintaxă invalidă | Verifică ghilimelele și $ |

### Debugging Rapid

```bash
# Activează debug mode în script
set -x  # afișează fiecare comandă
set -e  # oprește la prima eroare

# Testează pipeline segment cu segment
cmd1 | head  # verifică primul output
cmd1 | cmd2 | head  # adaugă progresiv

# Verifică exit codes
echo $?  # după fiecare comandă
echo ${PIPESTATUS[@]}  # pentru întreg pipeline-ul
```

---

## DUPĂ SEMINAR

### Teme de Dat

1. Tema principală: `teme/S02_01_TEMA.md` - deadline 1 săptămână
2. Reflecție obligatorie: `REFLECTION.txt` - parte din notare

### Feedback de Cerut

- "Ce a fost cel mai util azi?"
- "Ce a fost confuz?"
- "Ce ați vrea să aprofundăm?"

### Auto-evaluare Instructor

După fiecare seminar, notează:
- [ ] Hook-ul a captat atenția?
- [ ] Distribuția voturilor la PI a fost în zona 30-70%?
- [ ] Studenții au terminat sprint-urile la timp?
- [ ] Au existat probleme tehnice?
- [ ] Ce să ajustez pentru data viitoare?

---

## ANEXE

### A1: Script Complet pentru Pregătire

```bash
#!/bin/bash
# prep_seminar34.sh - Rulează cu 10 min înainte de seminar

echo "=== Pregătire Seminar 2 ==="

# Verificări
echo -n "Bash version: "
echo $BASH_VERSION

echo -n "Comenzi esențiale: "
for cmd in sort uniq cut tr wc head tail tee; do
    command -v $cmd &>/dev/null || echo -n "LIPSĂ:$cmd "
done
echo "OK"

# Setup director
rm -rf ~/demo_seminar34
mkdir -p ~/demo_seminar34
cd ~/demo_seminar34

# Creare fișiere test
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
EOF

echo "✓ Setup complet în ~/demo_seminar34"
ls -la
```

### A2: Comenzi Rapide pentru Demo

```bash
# Alias-uri pentru demo rapid
alias showpipe='ps aux | awk "{print \$1}" | sort | uniq -c | sort -rn | head -5'

> 💡 *Un truc pe care l-am descoperit predând: dacă explici altcuiva, înțelegi și tu mai bine.*

alias showmem='free -h | awk "/Mem:/ {print \"Folosit: \" \$3 \"/\" \$2}"'
alias showdisk='df -h / | awk "NR==2 {print \"Disk: \" \$5 \" folosit\"}"'
```

---

*Ghid Instructor generat pentru ASE București - CSIE | Sisteme de Operare*
*Seminar 2: Operatori, Redirecționare, Filtre, Bucle*
