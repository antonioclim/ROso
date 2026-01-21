# Exerciții Sprint - Seminarul 1-2
## Sisteme de Operare | Shell Basics & Configuration

**Format**: Sprint-uri de 10-15 minute cu micro-milestones verificabile  
**Stil de lucru**: Pair Programming (schimb roluri la jumătate)

---

## STRUCTURA SPRINT

Fiecare sprint are:
- ⏱️ **Timp total** fix
- 🎯 **Obiectiv clar**
- ✓ **Checkpoints** verificabile
- 🔄 **Switch point** pentru schimbare Driver/Navigator
- 🚀 **Extensie** pentru cei care termină devreme

---

## SPRINT 1: Exploratorul de Sistem
**Timp**: 12 minute | **Nivel**: Începător

```
══════════════════════════════════════════════════════════════
🎯 OBIECTIV: Explorează ierarhia de fișiere și documentează
══════════════════════════════════════════════════════════════

FORMEAZĂ PERECHI! 
├── Min 0-6:  Student A = Driver, Student B = Navigator
└── Min 6-12: SWITCH!

───────────────────────────────────────────────────────────────
📍 MILESTONE 1 (3 min): Verifică identitatea
───────────────────────────────────────────────────────────────
1. Afișează utilizatorul curent
2. Afișează directorul home
3. Afișează shell-ul folosit

✓ CHECKPOINT: Ai 3 informații: user, home path, shell name
───────────────────────────────────────────────────────────────

───────────────────────────────────────────────────────────────
📍 MILESTONE 2 (3 min): Explorează rădăcina
───────────────────────────────────────────────────────────────
4. Navighează în directorul rădăcină /
5. Listează conținutul cu detalii
6. Identifică 3 directoare importante și scopul lor

✓ CHECKPOINT: Poți numi scopul lui /etc, /home, /var
───────────────────────────────────────────────────────────────

🔄 SWITCH ROLURI ACUM!

───────────────────────────────────────────────────────────────
📍 MILESTONE 3 (3 min): Investigație /etc
───────────────────────────────────────────────────────────────
7. Intră în /etc
8. Găsește fișierul passwd și afișează primele 5 linii
9. Găsește fișierul hosts și afișează conținutul

✓ CHECKPOINT: Înțelegi formatul /etc/passwd (user:x:uid:gid:...)
───────────────────────────────────────────────────────────────

───────────────────────────────────────────────────────────────
📍 MILESTONE 4 (3 min): Documentare
───────────────────────────────────────────────────────────────
10. Revino în home
11. Creează fișier "explorare.txt"
12. Scrie în el ce ai descoperit (minim 3 observații)

✓ CHECKPOINT FINAL: cat explorare.txt arată observațiile tale
───────────────────────────────────────────────────────────────

🚀 EXTENSIE (dacă ai terminat devreme):
- Găsește câți utilizatori au shell bash în /etc/passwd
- Hint: grep bash /etc/passwd | wc -l

══════════════════════════════════════════════════════════════
```

### Soluții pentru instructor:
```bash
# M1
whoami
echo $HOME
echo $SHELL

# M2
cd /
ls -la
# /etc = configurări, /home = utilizatori, /var = date variabile

# M3
cd /etc
head -5 passwd
cat hosts

# M4
cd ~
touch explorare.txt
echo "1. /etc contine configurari sistem" > explorare.txt
echo "2. /home are directoarele utilizatorilor" >> explorare.txt
echo "3. passwd are informatii despre useri" >> explorare.txt

# Extensie
grep bash /etc/passwd | wc -l
```

---

## SPRINT 2: Arhitectul de Proiecte
**Timp**: 15 minute | **Nivel**: Începător-Intermediar

```
══════════════════════════════════════════════════════════════
🎯 OBIECTIV: Construiește o structură completă de proiect
══════════════════════════════════════════════════════════════

PAIR PROGRAMMING:
├── Min 0-7:  Student A = Driver
└── Min 7-15: Student B = Driver

STRUCTURA FINALĂ CERUTĂ:
    webapp/
    ├── backend/
    │   ├── src/
    │   │   ├── app.py
    │   │   └── config.py
    │   └── tests/
    │       └── test_app.py
    ├── frontend/
    │   ├── css/
    │   │   └── style.css
    │   ├── js/
    │   │   └── main.js
    │   └── index.html
    ├── docs/
    │   └── README.md
    └── .gitignore

───────────────────────────────────────────────────────────────
📍 MILESTONE 1 (4 min): Structură de bază
───────────────────────────────────────────────────────────────
Creează structura de directoare (fără fișiere încă).
HINT: mkdir -p poate crea ierarhii!

✓ CHECKPOINT: tree webapp arată toate directoarele
───────────────────────────────────────────────────────────────

───────────────────────────────────────────────────────────────
📍 MILESTONE 2 (3 min): Fișiere backend
───────────────────────────────────────────────────────────────
Creează fișierele Python cu conținut minimal.

app.py:
    # Main application
    print("Hello from Flask!")

config.py:
    # Configuration
    DEBUG = True

test_app.py:
    # Tests
    def test_hello():
        pass

✓ CHECKPOINT: cat backend/src/app.py funcționează
───────────────────────────────────────────────────────────────

🔄 SWITCH ROLURI ACUM!

───────────────────────────────────────────────────────────────
📍 MILESTONE 3 (4 min): Fișiere frontend
───────────────────────────────────────────────────────────────
index.html:
    <!DOCTYPE html>
    <html><head><title>WebApp</title></head>
    <body><h1>Welcome</h1></body></html>

style.css:
    body { font-family: sans-serif; }

main.js:
    console.log("App loaded");

✓ CHECKPOINT: Toate 3 fișierele frontend există și au conținut
───────────────────────────────────────────────────────────────

───────────────────────────────────────────────────────────────
📍 MILESTONE 4 (4 min): Documentație și finalizare
───────────────────────────────────────────────────────────────
README.md:
    # WebApp
    A simple web application.
    ## Structure
    - backend/ - Python Flask API
    - frontend/ - HTML/CSS/JS client

.gitignore:
    __pycache__/
    *.pyc
    .env

✓ CHECKPOINT FINAL: tree webapp arată EXACT structura cerută
───────────────────────────────────────────────────────────────

🚀 EXTENSIE:
- Adaugă requirements.txt în backend/ cu "flask==2.3.0"
- Creează un script setup.sh care face directorul executabil

══════════════════════════════════════════════════════════════
```

### Soluție eficientă:
```bash
# M1 - Structură
mkdir -p webapp/{backend/{src,tests},frontend/{css,js},docs}

# M2 - Backend
echo '# Main application
print("Hello from Flask!")' > webapp/backend/src/app.py

echo '# Configuration
DEBUG = True' > webapp/backend/src/config.py

echo '# Tests
def test_hello():
    pass' > webapp/backend/tests/test_app.py

# M3 - Frontend
echo '<!DOCTYPE html>
<html><head><title>WebApp</title></head>
<body><h1>Welcome</h1></body></html>' > webapp/frontend/index.html

echo 'body { font-family: sans-serif; }' > webapp/frontend/css/style.css

echo 'console.log("App loaded");' > webapp/frontend/js/main.js

# M4 - Docs
echo '# WebApp
A simple web application.
## Structure
- backend/ - Python Flask API
- frontend/ - HTML/CSS/JS client' > webapp/docs/README.md

echo '__pycache__/
*.pyc
.env' > webapp/.gitignore

# Verificare
tree webapp
```

---

## SPRINT 3: Configuratorul de Shell
**Timp**: 15 minute | **Nivel**: Intermediar

```
══════════════════════════════════════════════════════════════
🎯 OBIECTIV: Personalizează complet mediul shell
══════════════════════════════════════════════════════════════

⚠️ De reținut: Fă backup ÎNAINTE de orice modificare!

PAIR PROGRAMMING:
├── Min 0-7:  Driver A
└── Min 7-15: Driver B

───────────────────────────────────────────────────────────────
📍 MILESTONE 1 (3 min): Backup și variabile
───────────────────────────────────────────────────────────────
1. Creează backup: cp ~/.bashrc ~/.bashrc.backup
2. Verifică că există: ls -la ~/.bashrc*
3. Setează variabile în sesiune:
   - PROIECT="SO_Seminar"
   - EDITOR="nano"
   - DEBUG_MODE="true"

✓ CHECKPOINT: echo $PROIECT afișează "SO_Seminar"
───────────────────────────────────────────────────────────────

───────────────────────────────────────────────────────────────
📍 MILESTONE 2 (4 min): Alias-uri esențiale
───────────────────────────────────────────────────────────────
Adaugă în ~/.bashrc:

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias cls='clear'
alias h='history'
alias grep='grep --color=auto'

✓ CHECKPOINT: grep "alias ll" ~/.bashrc găsește linia
───────────────────────────────────────────────────────────────

🔄 SWITCH ROLURI!

───────────────────────────────────────────────────────────────
📍 MILESTONE 3 (4 min): Funcții utile
───────────────────────────────────────────────────────────────
Adaugă în ~/.bashrc:

# Creează director și intră în el
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extrage orice arhivă
extract() {
    case "$1" in
        *.tar.gz)  tar xzf "$1" ;;
        *.zip)     unzip "$1" ;;
        *.tar)     tar xf "$1" ;;
        *)         echo "Format necunoscut: $1" ;;
    esac
}

✓ CHECKPOINT: type mkcd arată definiția funcției
───────────────────────────────────────────────────────────────

───────────────────────────────────────────────────────────────
📍 MILESTONE 4 (4 min): Prompt și testare
───────────────────────────────────────────────────────────────
Adaugă prompt personalizat:

PS1='\[\033[01;32m\]\u\[\033[00m\]@\[\033[01;33m\]\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

Testează totul:
1. source ~/.bashrc
2. Testează fiecare alias
3. Testează mkcd test_folder
4. Verifică că prompt-ul e colorat

✓ CHECKPOINT FINAL: Toate funcționează, prompt-ul e verde/galben/albastru
───────────────────────────────────────────────────────────────

🚀 EXTENSIE:
- Adaugă un mesaj de bun venit cu data și ora
- Adaugă un alias pentru a vedea spațiul pe disk colorat

══════════════════════════════════════════════════════════════
```

---

## SPRINT 4: Detectivul de Fișiere
**Timp**: 12 minute | **Nivel**: Intermediar

```
══════════════════════════════════════════════════════════════
🎯 OBIECTIV: Găsește și organizează fișiere după criterii
══════════════════════════════════════════════════════════════

SETUP (rulează ÎNAINTE de sprint):
───────────────────────────────────────────────────────────────
mkdir -p ~/detective_test
cd ~/detective_test
touch file{1..5}.txt image{1..3}.jpg doc{1..2}.pdf
touch .hidden_config .secret_key
echo "Important data" > important.txt
echo "Old data" > old_file.txt
touch -d "30 days ago" old_file.txt
mkdir archive
───────────────────────────────────────────────────────────────

PAIR PROGRAMMING: Switch la 6 minute!

───────────────────────────────────────────────────────────────
📍 MILESTONE 1 (3 min): Investigare inițială
───────────────────────────────────────────────────────────────
1. Câte fișiere .txt există?
2. Care sunt fișierele ascunse?
3. Care e cel mai vechi fișier?

✓ CHECKPOINT: Răspunsuri: 6 txt, 2 hidden, old_file.txt
───────────────────────────────────────────────────────────────

───────────────────────────────────────────────────────────────
📍 MILESTONE 2 (3 min): Căutare avansată
───────────────────────────────────────────────────────────────
4. Găsește TOATE fișierele (inclusiv ascunse) cu find
5. Găsește fișierele mai vechi de 7 zile
6. Găsește fișierele care conțin "data" în conținut

✓ CHECKPOINT: find găsește 13 elemente, grep găsește 2 fișiere
───────────────────────────────────────────────────────────────

🔄 SWITCH!

───────────────────────────────────────────────────────────────
📍 MILESTONE 3 (3 min): Organizare
───────────────────────────────────────────────────────────────
7. Mută toate .jpg în archive/
8. Mută toate .pdf în archive/
9. Verifică structura cu tree

✓ CHECKPOINT: archive/ conține 3 jpg + 2 pdf
───────────────────────────────────────────────────────────────

───────────────────────────────────────────────────────────────
📍 MILESTONE 4 (3 min): Raport final
───────────────────────────────────────────────────────────────
10. Creează un fișier raport.txt cu:
    - Numărul total de fișiere rămase în director
    - Lista fișierelor din archive/
    - Spațiul total ocupat

✓ CHECKPOINT FINAL: cat raport.txt arată statisticile
───────────────────────────────────────────────────────────────

🚀 EXTENSIE:
- Șterge fișierele mai vechi de 7 zile (cu confirmare!)
- Creează o arhivă .tar.gz din archive/

══════════════════════════════════════════════════════════════
```

### Soluții:
```bash
# M1
ls *.txt | wc -l           # 6
ls -la .* 2>/dev/null      # .hidden_config, .secret_key
ls -lt | tail -1           # old_file.txt

# M2
find . -type f             # toate fișierele
find . -type f -mtime +7   # mai vechi de 7 zile
grep -r "data" .           # conține "data"

# M3
mv *.jpg archive/
mv *.pdf archive/
tree

# M4
echo "Fișiere rămase: $(find . -maxdepth 1 -type f | wc -l)" > raport.txt
echo "În archive: $(ls archive/)" >> raport.txt
echo "Spațiu: $(du -sh .)" >> raport.txt
```

---

## SPRINT 5: Maestrul Variabilelor
**Timp**: 10 minute | **Nivel**: Intermediar-Avansat

```
══════════════════════════════════════════════════════════════
🎯 OBIECTIV: Demonstrează înțelegerea profundă a variabilelor
══════════════════════════════════════════════════════════════

INDIVIDUAL (fără pereche pentru acest sprint)

───────────────────────────────────────────────────────────────
📍 MILESTONE 1 (3 min): Predicții
───────────────────────────────────────────────────────────────
SCRIE pe hârtie ce crezi că va afișa FIECARE comandă:

A="text"
B='$A plus'
C="$A plus"

echo $B
echo $C
echo "$B"
echo '$C'

Apoi rulează și compară cu predicțiile!

✓ CHECKPOINT: Ai predicții ÎNAINTE de rulare, înțelegi diferențele
───────────────────────────────────────────────────────────────

───────────────────────────────────────────────────────────────
📍 MILESTONE 2 (3 min): Manipulare stringuri
───────────────────────────────────────────────────────────────
FILENAME="/home/student/documents/report_final.pdf"

Extrage:
1. Doar numele fișierului (report_final.pdf)
2. Doar extensia (pdf)
3. Calea fără fișier (/home/student/documents)
4. Numele fără extensie (report_final)

HINT: Folosește ${VAR%pattern}, ${VAR##pattern}, etc.

✓ CHECKPOINT: Ai 4 răspunsuri corecte folosind parameter expansion
───────────────────────────────────────────────────────────────

───────────────────────────────────────────────────────────────
📍 MILESTONE 3 (4 min): Script cu verificări
───────────────────────────────────────────────────────────────
Creează var_demo.sh care:
1. Primește un argument sau folosește "default"
2. Verifică dacă o variabilă de mediu DEMO_VAR există
3. Afișează lungimea unui string dat

Structură:
    #!/bin/bash
    NAME=${1:-"default_name"}
    echo "Nume: $NAME (lungime: ${#NAME})"
    
    if [ -z "$DEMO_VAR" ]; then
        echo "DEMO_VAR nu e setată"
    else
        echo "DEMO_VAR = $DEMO_VAR"
    fi

✓ CHECKPOINT FINAL: ./var_demo.sh și ./var_demo.sh test ambele funcționează
───────────────────────────────────────────────────────────────

🚀 EXTENSIE:
- Adaugă ${VAR:?error} pentru a forța existența unei variabile
- Creează un array și iterează prin el

══════════════════════════════════════════════════════════════
```

### Soluții M2:
```bash
FILENAME="/home/student/documents/report_final.pdf"

# 1. Doar numele fișierului
echo ${FILENAME##*/}         # report_final.pdf

# 2. Doar extensia
echo ${FILENAME##*.}         # pdf

# 3. Calea fără fișier
echo ${FILENAME%/*}          # /home/student/documents

# 4. Numele fără extensie
BASENAME=${FILENAME##*/}     # report_final.pdf
echo ${BASENAME%.*}          # report_final
```

---

## TRACKER SPRINT-URI

Folosește acest tabel pentru tracking în clasă:

| Sprint | Pereche | M1 | M2 | M3 | M4 | Extensie | Note |
|--------|---------|----|----|----|----|----------|------|
| S1 |  |  |  |  |  |  |  |
| S2 |  |  |  |  |  |  |  |
| S3 |  |  |  |  |  |  |  |
| S4 |  |  |  |  |  |  |  |
| S5 |  |  |  |  |  |  |  |

Marchează: ✓ completat, ~ parțial, ✗ neterminat

---

## OBIECTIVE DE ÎNVĂȚARE (mapare pe sprint-uri)

| Obiectiv | Sprint | Milestone |
|----------|--------|-----------|
| Navigare sistem fișiere | S1 | M1-M3 |
| Creare structuri | S2 | M1-M2 |
| Configurare .bashrc | S3 | M2-M4 |
| Find și globbing | S4 | M2-M3 |
| Variabile avansate | S5 | M1-M3 |
| Pair programming | S1-S4 | toate |

---

*Exerciții Sprint | SO Seminarul 1-2 | ASE-CSIE*
