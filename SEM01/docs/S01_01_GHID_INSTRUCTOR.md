# Ghid Instructor: Seminarul 1-2
## Sisteme de Operare | Shell Basics & Configuration

Durată totală: 100 minute (2 × 50 min + pauză)  
Tip seminar: Limbaj ca Vehicul (Bash pentru concepte SO)  
Nivel: Începător (presupunem experiență minimă cu terminal)

---

## OBIECTIVE SESIUNE

La final, studenții vor fi capabili să:
1. Navigheze eficient în sistemul de fișiere Linux
2. Distingă conceptual între kernel, shell și terminal
3. Creeze și manipuleze fișiere și directoare
4. Configureze mediul shell cu variabile și alias-uri
5. Prezică comportamentul comenzilor cu quoting diferit

---

## PREGĂTIRE ÎNAINTE DE SEMINAR

### Verificări Tehnice (10 min înainte)

```bash
# Verifică că toate tool-urile sunt instalate
which figlet lolcat cmatrix cowsay dialog tree pv >/dev/null 2>&1 && \
    echo "✅ Tools OK" || echo "❌ Instalează: apt install figlet lolcat cmatrix cowsay dialog tree pv"

# Verifică versiunea bash
bash --version | head -1

# Pregătește un director curat de lucru
rm -rf ~/demo_seminar
mkdir -p ~/demo_seminar
cd ~/demo_seminar
```

### Materiale Necesare
- [ ] Proiector funcțional
- [ ] Terminal cu font mare (min 16pt)
- [ ] Câte un fișier text pentru fiecare exercițiu (pre-creat)
- [ ] Carduri A/B/C/D pentru Peer Instruction (sau Mentimeter/Kahoot setup)
- [ ] Timer vizibil pentru activități

### Setup Terminal Recomandat
```bash
# Font mare și vizibil
export PS1='\n\[\033[01;32m\]DEMO\[\033[00m\] \[\033[01;34m\]\w\[\033[00m\]\n\$ '

# Culori pentru claritate
alias ls='ls --color=auto'
alias grep='grep --color=auto'
```

---

## TIMELINE DETALIATĂ - PRIMA PARTE (50 min)

### [0:00-0:05] HOOK: Demo Spectaculoasă

Scop: Captează atenția, stabilește tonul interactiv

```bash
# Rulează EXACT aceste comenzi (testate)
clear
figlet -f slant "BASH" | lolcat
sleep 2
echo ""
cowsay -f tux "Bine ați venit la SO!" | lolcat
sleep 2
clear
echo "În următoarele 100 de minute vom descoperi magia terminalului..."
```

Note instructor:
- NU explica comenzile încă - lasă misterul
- Spune: "Până la final, veți înțelege fiecare parte din ce ați văzut"
- Dacă tech fail: treci direct la intro, nu pierde timp debugging
- Folosește `man` sau `--help` când ai dubii

---

### [0:05-0:10] PEER INSTRUCTION Q1: Ce este Shell-ul?

Afișează pe ecran:
```
Când tastezi o comandă în terminal și apeși Enter, 
ce componentă interpretează prima dată textul?

A) Kernel-ul Linux
B) Shell-ul (bash)
C) Sistemul de operare
D) Procesorul (CPU)
```

Protocol:
1. [0:05-0:06] Citește întrebarea, 30 sec gândire individuală
2. [0:06-0:07] Primul vot - ridică carduri/votează
3. [0:07-0:09] Discuție în perechi (2 min) - "Convinge-ți vecinul"
4. [0:09-0:10] Al doilea vot + explicație

Note instructor:
- Răspuns corect: B) Shell-ul
- Distractor A (kernel): Studenții care confundă nivelurile
- Distractor C (SO): Prea vag, confuzie terminologică
- Distractor D (CPU): Confuzie hardware/software

După vot, explică cu diagrama:
```
┌─────────────────────────────────────┐
│         Utilizator (TU)             │
├─────────────────────────────────────┤
│  Terminal (fereastra/interfața)     │
├─────────────────────────────────────┤
│  Shell (BASH) ← AICI interpretează  │
├─────────────────────────────────────┤
│  Kernel (Linux) ← execuția reală    │
├─────────────────────────────────────┤
│  Hardware (CPU, RAM, Disk)          │
└─────────────────────────────────────┘
```

---

### [0:10-0:25] LIVE CODING: Navigare și Comenzi de Bază

STRUCTURA: Fiecare comandă urmează ciclul Anunț → Predicție → Execuție → Explicație

#### Segment 1: Unde sunt? (2 min)

```bash
# ANUNȚ: "Să vedem unde ne aflăm în sistem"
# PREDICȚIE: "Ce credeți că va afișa?"
pwd
# EXPLICAȚIE: "Print Working Directory - calea completă"

# PREDICȚIE: "Ce vedem dacă listăm?"
ls
# EXPLICAȚIE: Conținutul directorului curent
```

#### Segment 2: Navigare (4 min)

```bash
# ANUNȚ: "Hai să ne plimbăm prin sistem"
cd /
# PREDICȚIE: "Unde suntem acum?"
pwd

ls
# EXPLICAȚIE: "Aceasta e RĂDĂCINA sistemului de fișiere"

cd /home
ls
# EXPLICAȚIE: "Aici sunt directoarele utilizatorilor"

cd ~
# PREDICȚIE: "Ce înseamnă ~?"
pwd
# EXPLICAȚIE: "Tilde = home directory"
```

#### Segment 3: Shortcut-uri (3 min)

```bash
cd /var/log
pwd
cd -
# PREDICȚIE: "Ce face minus?"
pwd
# EXPLICAȚIE: "Toggle între ultimele două directoare"

cd ..
# PREDICȚIE: "Unde ajungem?"
pwd
# EXPLICAȚIE: "Două puncte = directorul părinte"
```

#### Segment 4: Listare detaliată (3 min)

```bash
cd ~
ls -la
# EXPLICAȚIE (cu pointer):
# drwxr-xr-x 5 stud stud 4096 Jan 15 10:30 Documents
# Nume
# Data
# Dimensiune
# Grup
# Owner
# Număr linkuri
# Permisiuni others
# Permisiuni group
# Permisiuni owner
# d=directory, -=file, l=link
```

#### Segment 5: Creare și manipulare (3 min)

```bash
mkdir proiect
cd proiect
touch fisier.txt
echo "Hello World" > fisier.txt
cat fisier.txt
```

**⚠️ EROARE DELIBERATĂ** (minut 23):

```bash
# SPUNE: "Acum să creăm o structură mai complexă..."
# SCRIE GREȘIT INTENȚIONAT:
mkdir src docs tests      # Corect, dar apoi:
touch main .c             # GREȘIT! Spațiu în plus

# REACȚIE: "Hmm, ce s-a întâmplat?"
ls -la
# Vor vedea două fișiere: "main" și ".c" (ascuns)

# ÎNTREABĂ: "Ce a mers prost? Cineva vede?"
# EXPLICĂ: Spațiul a separat argumentele

# CORECTEAZĂ:
rm main .c
touch main.c
ls
```

---

### [0:25-0:30] PARSONS PROBLEM #1

Afișează pe ecran sau distribui pe hârtie:

```
══════════════════════════════════════════════════════════════
🧩 PARSONS PROBLEM: Creează și navighează într-o structură

Aranjează comenzile în ordinea corectă pentru a:
1. Crea un director "proiect"
2. Intra în el
3. Crea subdirectoarele "src" și "docs"
4. Verifica structura

LINII (ordine amestecată):
─────────────────────────────────────────────────────────────
   ls -R
   mkdir proiect
   mkdir src docs  
   cd proiect
   cd src          ← DISTRACTOR (nu e necesar)
─────────────────────────────────────────────────────────────

Timp: 3 minute | Lucrați în perechi
══════════════════════════════════════════════════════════════
```

Soluție:
1. `mkdir proiect`
2. `cd proiect`
3. `mkdir src docs`
4. `ls -R`

Note instructor: Distractorul `cd src` testează dacă înțeleg că mkdir poate crea din directorul curent.

---

### [0:30-0:45] SPRINT #1: Creează Structura de Proiect

PAIR PROGRAMMING MODE

```
══════════════════════════════════════════════════════════════
🏃 SPRINT #1: Arhitectul de Proiecte (15 min)

FORMAȚI PERECHI! 
├── Minutul 0-7: Student A = Driver, Student B = Navigator
└── Minutul 7-14: SWITCH roles!

CERINȚĂ:
Creați structura completă pentru un proiect software:

    my_project/
    ├── src/
    │   ├── main.c
    │   └── utils.c
    ├── include/
    │   └── header.h
    ├── docs/
    │   └── README.md
    ├── tests/
    │   └── test_main.c
    └── Makefile

HINT: Folosiți mkdir -p și touch eficient!

✓ VERIFICARE: Rulați "tree my_project" - trebuie să arate exact ca mai sus
══════════════════════════════════════════════════════════════
```

Soluție eficientă (pentru instructor):
```bash
mkdir -p my_project/{src,include,docs,tests}
touch my_project/src/{main.c,utils.c}
touch my_project/include/header.h
touch my_project/docs/README.md
touch my_project/tests/test_main.c
touch my_project/Makefile
tree my_project
```

Timer:
- [0:30] Start, formează perechi
- [0:37] "SWITCH!" - schimbă Driver/Navigator
- [0:43] "2 minute rămase!"
- [0:45] Stop, verificare

---

### [0:45-0:50] PEER INSTRUCTION Q2: Quoting

Afișează:
```
Ce va afișa următoarea comandă?

NAME="Student"
echo 'Salut $NAME'

A) Salut Student
B) Salut $NAME
C) Eroare: variabila nu există
D) Salut (doar atât, fără rest)
```

Protocol: Vot → Discuție 2min → Revot → Explicație

Răspuns corect: B) Salut $NAME

Explicație:
```bash

*(Bash-ul are o sintaxă urâtă, recunosc. Dar rulează peste tot, și asta contează enorm în practică.)*

# Single quotes = LITERAL (nu expandează nimic)
echo 'Salut $NAME'    # Output: Salut $NAME

# Double quotes = Permite expansiune
echo "Salut $NAME"    # Output: Salut Student

# Fără quotes = Word splitting + expansiune
echo Salut $NAME      # Output: Salut Student
```

---

## PAUZĂ 10 MINUTE

Sugestie: Lasă pe ecran o demonstrație pasivă:
```bash
while true; do fortune | cowsay -f $(ls /usr/share/cowsay/cows | shuf -n1) | lolcat; sleep 10; clear; done
```

---

## TIMELINE DETALIATĂ - A DOUA PARTE (50 min)

### [0:00-0:05] REACTIVARE: Quiz Rapid

3 întrebări rapide, mâini ridicate:

1. "Ce face `cd -`?" → Toggle directoare
2. "Ce literă vezi la început pentru un director în `ls -l`?" → `d`

> 💡 De-a lungul anilor, am constatat că exemplele practice bat teoria de fiecare dată.

3. "Cum ștergi un director cu conținut?" → `rm -r`

---

### [0:05-0:20] LIVE CODING: Variabile și .bashrc

#### Segment 1: Variabile locale (4 min)

```bash
# ANUNȚ: "Să creăm variabile"
MESAJ="Salut din bash"
echo $MESAJ

# PREDICȚIE: "Ce se întâmplă dacă deschid un nou terminal?"
bash -c 'echo $MESAJ'
# Output: (nimic)

# EXPLICAȚIE: Variabila e LOCALĂ, nu se moștenește
```

#### Segment 2: Export (4 min)

```bash
export MESAJ="Salut din bash"
bash -c 'echo $MESAJ'
# Output: Salut din bash

# EXPLICAȚIE: export = vizibilă pentru subprocese
```

#### Segment 3: Variabile speciale (3 min)

```bash
echo "Home: $HOME"
echo "User: $USER"  
echo "Path: $PATH"
echo "Shell: $SHELL"

# PREDICȚIE: "Ce va afișa $? după o comandă reușită?"
ls
echo $?
# Output: 0

# PREDICȚIE: "Dar după o eroare?"
ls /inexistent 2>/dev/null
echo $?
# Output: 2 (sau altă valoare non-zero)
```

#### Segment 4: Configurare .bashrc (4 min)

```bash

*Notă personală: Bash-ul are o sintaxă urâtă, recunosc. Dar rulează peste tot, și asta contează enorm în practică.*

# ANUNȚ: "Să vedem fișierul de configurare"
cat ~/.bashrc | head -30

# ANUNȚ: "Să adăugăm un alias"
echo "alias ll='ls -la'" >> ~/.bashrc

# PREDICȚIE: "Funcționează imediat?"
ll
# Output: command not found

# EXPLICAȚIE: Trebuie reîncărcat!
source ~/.bashrc
ll
# Acum funcționează!
```

**⚠️ EROARE DELIBERATĂ** (minut 18):

```bash
# SCRIE GREȘIT INTENȚIONAT:
VARIABILA = "valoare"    # Spații în jurul =

# Output: VARIABILA: command not found

# ÎNTREABĂ: "Ce s-a întâmplat?"
# EXPLICĂ: În bash, NU sunt permise spații în jurul =
# CORECT:
VARIABILA="valoare"
echo $VARIABILA
```

---

### [0:20-0:25] PEER INSTRUCTION Q3: Locale vs Export

Afișează:
```
Care este output-ul final?

VAR1="local"
export VAR2="exported"
bash -c 'echo "$VAR1 $VAR2"'

A) local exported
B) exported
C)  exported       (spațiu la început, apoi "exported")
D) local
```

Răspuns corect: C)

Explicație:
- `$VAR1` nu e exportată → în subshell e vidă → produce spațiu
- `$VAR2` e exportată → vizibilă în subshell → "exported"
- Rezultat: " exported" (spațiu + exported)
- Testează mai întâi cu date simple

---

### [0:25-0:40] SPRINT #2: Configurare Mediu Personalizat

```
══════════════════════════════════════════════════════════════
🏃 SPRINT #2: Personalizează-ți Shell-ul (15 min)

PAIR PROGRAMMING - schimbați rolurile la jumătate!

TASK-URI:
1. Creează un backup al .bashrc
2. Adaugă aceste alias-uri:
   - ll pentru ls -la
   - cls pentru clear
   - cdp pentru cd ~/proiecte (creează directorul mai întâi)
   
3. Adaugă un mesaj de bun venit în .bashrc:
   echo "Welcome back, $USER! Today is $(date +%A)"
   
4. Modifică PS1 pentru un prompt colorat simplu

5. Testează deschizând un nou terminal sau cu source

✓ VERIFICARE: 
   - ll funcționează
   - cdp te duce în ~/proiecte
   - La deschidere terminal vezi mesajul
══════════════════════════════════════════════════════════════
```

Soluție (pentru instructor):
```bash
# 1. Backup
cp ~/.bashrc ~/.bashrc.backup

# 2. Alias-uri
mkdir -p ~/proiecte
cat >> ~/.bashrc << 'EOF'

# === Alias-uri personalizate ===
alias ll='ls -la'
alias cls='clear'
alias cdp='cd ~/proiecte'

# === Mesaj bun venit ===
echo "Welcome back, $USER! Today is $(date +%A)"

# === Prompt colorat ===
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
EOF

# 5. Activare
source ~/.bashrc
```

---

### [0:40-0:48] LLM EXERCISE: Generează și Critică

```
══════════════════════════════════════════════════════════════
🤖 EXERCIȚIU LLM: Evaluatorul de Alias-uri (8 min)

INDIVIDUAL - folosește ChatGPT/Claude/Gemini

PARTEA 1 (3 min): Promptul
"Generează 5 alias-uri utile pentru un student 
care lucrează cu Python și face backup-uri frecvente"

PARTEA 2 (5 min): Evaluează output-ul
Pentru FIECARE alias generat, răspunde:
1. ✅ E corect sintactic? (testat în terminal)
2. 🤔 E util pentru mine personal?
3. ⚠️ Are efecte secundare periculoase?

SCRIE în REFLECTION.txt:
- Care alias l-ai folosi și de ce
- Care alias e periculos și de ce
══════════════════════════════════════════════════════════════
```

Note instructor:
- Circulă prin clasă, verifică că studenții TESTEAZĂ codul
- LLM-urile pot genera `alias rm='rm -rf'` - discută pericolul!
- Discuție finală: "Ce surprize ați avut?"

---

### [0:48-0:50] REFLECTION CHECKPOINT

Afișează și citește:

```
══════════════════════════════════════════════════════════════
🧠 REFLECTION (2 minute de gândire tăcută)

1. Care a fost cel mai surprinzător lucru 
   pe care l-ai învățat azi?

2. Ce încă nu înțelegi complet?

3. Un lucru pe care vrei să-l explorezi singur:
   ___________________________________________

Scrie pe hârtie sau în notes - e pentru TINE, nu pentru notă.
══════════════════════════════════════════════════════════════
```

---

## TROUBLESHOOTING COMUN

| Problemă | Soluție Rapidă |
|----------|----------------|
| figlet/lolcat nu e instalat | `sudo apt install figlet lolcat -y` |
| Terminal prea mic | Ctrl+Shift++ pentru zoom |
| Student blocat în vim | Apasă `Esc`, apoi scrie `:q!` și Enter |
| .bashrc corupt | `cp ~/.bashrc.backup ~/.bashrc` |
| Permisiuni denied | Lucrează în `~`, nu în `/` |

---

## DUPĂ SEMINAR

### Notează pentru data viitoare:
- Ce întrebări PI au avut distribuție neașteptată?
- Ce misconceptii noi au apărut?
- Ce exerciții au luat mai mult/puțin decât estimat?
- Feedback-uri spontane de la studenți?

### Teme pentru studenți:
1. Creează 3 alias-uri proprii în .bashrc
2. Completează exercițiile din `06_EXERCITII_SPRINT.md`
3. Citește `man bash` secțiunea despre quoting

---

*Ghid Instructor | SO Seminarul 1-2 | ASE-CSIE*
