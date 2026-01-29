# Ghid Live Coding - Seminar 1: Shell Bash

> **Sisteme de Operare** | ASE București - CSIE  
> Ghid pas-cu-pas pentru demonstrații interactive

---

## Principii Live Coding

### Reguli de Aur pentru Instructor

1. **ÎNTOTDEAUNA** cere predicție înainte de a rula comanda
2. **NICIODATĂ** nu copia/lipește - tastează tot
3. **GREȘEȘTE INTENȚIONAT** la momentele marcate cu ⚡
4. **VORBEȘTE** în timp ce tastezi - explică ce faci
5. **PAUZE** de 2-3 secunde după output important
6. **VERIFICĂ** înțelegerea cu "Ce credeți că va afișa?"

### Tempo și Ritm

| Situație | Tempo |
|----------|-------|
| Concept nou | LENT (3-5 sec între comenzi) |
| Repetare | NORMAL (1-2 sec) |
| Demo "magic" | RAPID (efect wow) |
| După eroare | PAUZĂ (lasă să observe) |

---

# SECȚIUNEA 1: HOOK DEMO (3 minute)

> **Notă pentru instructori**: Primele 3 minute decid dacă îi ai pe studenți sau nu. Din experiența mea, dacă nu captezi atenția cu ceva vizual în primele minute, jumătate din sală e pe telefon. Figlet + lolcat funcționează de fiecare dată — e cheesy, dar merge!

## Obiectiv: Captarea atenției cu "Bash Magic"

### Script Complet

```bash

*Notă personală: Bash-ul are o sintaxă urâtă, recunosc. Dar rulează peste tot, și asta contează enorm în practică.*

# [INSTRUCTOR]: "Bun venit! Înainte de orice teorie, hai să vedem
# ce poate face shell-ul..."

# [TASTEAZĂ ÎNCET, CU DRAMATISM]
figlet -f slant "BASH" | lolcat

# [PAUZĂ 2 SEC - lasă să admire]

# [INSTRUCTOR]: "Acesta este terminalul. Nu e doar pentru hackeri în filme."

# [EFECT MATRIX - doar 3 secunde]
# (știu, e cliché din 1999, dar studenților încă le place)
timeout 3 cmatrix -b -C green

# [CTRL+C dacă nu se oprește singur]

# [INSTRUCTOR]: "Și da, putem face și asta..."
cowsay -f tux "Bine ați venit la SO!" | lolcat

# [INSTRUCTOR]: "În următoarele 2 ore, veți învăța să controlați
# acest mediu. Să începem!"
```

### Fallback (dacă lipsesc tool-urile)

```bash
# Verificare prealabilă (în pauză sau înainte de seminar)
which figlet lolcat cmatrix cowsay 2>/dev/null || echo "Missing tools!"

# Alternativă simplă dacă lipsesc:
echo ""
echo "    ____    _    ____  _   _ "
echo "   | __ )  / \  / ___|| | | |"
echo "   |  _ \ / _ \ \___ \| |_| |"
echo "   | |_) / ___ \ ___) |  _  |"
echo "   |____/_/   \_\____/|_| |_|"
echo ""
echo ">>> Bine ați venit la Sisteme de Operare! <<<"
```

---

# SECȚIUNEA 2: LIVE CODING - NAVIGARE (15 minute)

## 2.1 Unde Sunt? (pwd)

### Script

```bash
# [INSTRUCTOR]: "Prima întrebare în Linux: UNDE SUNT?"
# [INSTRUCTOR]: "Ce comandă credeți că ne spune asta?"
# [AȘTEAPTĂ RĂSPUNSURI]

pwd

# [OUTPUT]: /home/student
# [INSTRUCTOR]: "pwd = Print Working Directory. Memorați: 'Password? Where's Directory?'"
```

### Punct de Predicție #1

```bash

*(Bash-ul are o sintaxă urâtă, recunosc. Dar rulează peste tot, și asta contează enorm în practică.)*

# [INSTRUCTOR]: "OK, acum merg în altă parte..."
cd /etc

# [INSTRUCTOR]: "Ce va afișa pwd acum? Scrieți pe hârtie!"
# [PAUZĂ 5 SEC]
# [INSTRUCTOR]: "Ridicați mâna cine a scris /etc"

pwd
# [OUTPUT]: /etc
```

## 2.2 Navigare cu cd

### Script Principal

```bash
# [INSTRUCTOR]: "cd = Change Directory. Să explorăm!"

# Înapoi acasă
cd ~
pwd
# [OUTPUT]: /home/student

# [INSTRUCTOR]: "Tilda ~ înseamnă HOME. Este o scurtătură."

# Director părinte
cd ..
pwd
# [OUTPUT]: /home

cd ..
pwd
# [OUTPUT]: /

# [INSTRUCTOR]: "Am ajuns la RĂDĂCINĂ. Totul în Linux pornește de aici."
```

### GREȘEALĂ INTENȚIONATĂ #1

```bash
# [INSTRUCTOR]: "Hai să mergem în Documents..."
cd documents
# [OUTPUT]: bash: cd: documents: No such file or directory

# [INSTRUCTOR]: "Oops! Ce s-a întâmplat?"
# [AȘTEAPTĂ RĂSPUNSURI]

# [INSTRUCTOR]: "Linux e CASE-SENSITIVE! documents ≠ Documents"
cd ~
cd Documents
pwd
# [OUTPUT]: /home/student/Documents
```

### Scurtătura cd -

```bash
# [INSTRUCTOR]: "Acum un truc foarte util..."
cd /var/log
pwd
# [OUTPUT]: /var/log

# [INSTRUCTOR]: "Cum mă întorc rapid acasă și înapoi?"
cd -
pwd
# [OUTPUT]: /home/student/Documents

cd -
pwd
# [OUTPUT]: /var/log

# [INSTRUCTOR]: "cd - face toggle între ultimele două locații!"
```

## 2.3 Listare cu ls

### Script

```bash
cd ~

# [INSTRUCTOR]: "ls = list. Să vedem ce avem acasă."
ls
# [OUTPUT]: Desktop Documents Downloads ...

# [INSTRUCTOR]: "Dar asta nu ne spune prea multe. Hai cu detalii!"
ls -l
# [EXPLICĂ fiecare coloană]

# [INSTRUCTOR]: "Observați că lipsesc unele fișiere. Unde e .bashrc?"
ls -la
# [INSTRUCTOR]: "Opțiunea -a arată fișierele ASCUNSE - cele cu punct la început"
```

### Punct de Predicție #2

```bash
# [INSTRUCTOR]: "Ce diferență credeți că e între acestea două?"
# [SCRIE PE TABLĂ]: ls -l vs ls -lh

ls -l /var/log
# [Arată dimensiuni în bytes]

ls -lh /var/log
# [Arată KB, MB]

# [INSTRUCTOR]: "h = human-readable. 1048576 vs 1M - ce preferați?"
```

---

# SECȚIUNEA 3: LIVE CODING - MANIPULARE FIȘIERE (10 minute)

## 3.1 Creare Fișiere și Directoare

### Script

```bash
# [INSTRUCTOR]: "Hai să creăm un proiect de la zero!"

# Creăm spațiu de lucru
cd ~
mkdir laborator
cd laborator

# [INSTRUCTOR]: "Ce credeți că face următoarea comandă?"
mkdir -p proiect/{src,docs,tests}

# [PAUZĂ - PREDICȚIE]

ls -R
# [OUTPUT]:
# proiect/
# proiect/docs
# proiect/src
# proiect/tests

# [INSTRUCTOR]: "Acoladele {} creează MULTIPLE directoare!"
```

### Touch și Echo

```bash
cd proiect

# [INSTRUCTOR]: "Creăm fișiere goale cu touch"
touch src/main.c
touch README.md

# [INSTRUCTOR]: "Și fișiere cu conținut folosind echo + redirect"
echo "# Proiect Laborator SO" > README.md

cat README.md
# [OUTPUT]: # Proiect Laborator SO

# [INSTRUCTOR]: "Un singur > suprascrie. Două >> adaugă."
echo "Autor: Student" >> README.md
cat README.md
```

## 3.2 Copiere și Mutare

### GREȘEALĂ INTENȚIONATĂ #2

```bash
# [INSTRUCTOR]: "Să copiem directorul src..."
cp src backup_src
# [OUTPUT]: cp: -r not specified; omitting directory 'src'

# [INSTRUCTOR]: "Eroare! Ce lipsește?"
# [AȘTEAPTĂ]

cp -r src backup_src
ls
# [Funcționează!]

# [INSTRUCTOR]: "Pentru DIRECTOARE, cp are nevoie de -r (recursiv)"
```

### Redenumire vs Mutare

```bash
# [INSTRUCTOR]: "mv face două lucruri: mută ȘI redenumește"

# Redenumire (același director)
mv README.md CITESTE-MA.md
ls
# README.md a devenit CITESTE-MA.md

# Mutare (alt director)
mv CITESTE-MA.md docs/
ls docs/
# CITESTE-MA.md e acum în docs/
```

## 3.3 Ștergere (cu precauție!)

### Script

```bash
# [INSTRUCTOR]: "rm = remove. Capcană: nu există Recycle Bin!"

# Demonstrație sigură
touch fisier_test.txt
ls
rm fisier_test.txt
ls
# [A dispărut definitiv]

# [INSTRUCTOR]: "Pentru siguranță, folosiți -i"
touch alt_test.txt
rm -i alt_test.txt
# [Cere confirmare]
# y

# Director
mkdir dir_test
rm dir_test
# [Eroare: Is a directory]

rm -r dir_test
# [Funcționează]
```

### AVERTISMENT (NU EXECUTA!)

```bash
# [INSTRUCTOR]: "O comandă pe care NU o vom rula niciodată direct:"
# [SCRIE PE TABLĂ, NU ÎN TERMINAL]
# rm -rf /
# rm -rf $VARIABILA_GOALA/

# [INSTRUCTOR]: "Dacă variabila e goală, șterge tot de la rădăcină!"
# [INSTRUCTOR]: "ÎNTOTDEAUNA verificați cu echo înainte de rm -rf"
```

---

# SECȚIUNEA 4: LIVE CODING - VARIABILE (15 minute)

## 4.1 Variabile Locale

### Script

```bash
cd ~

# [INSTRUCTOR]: "Variabilele stochează valori. Sintaxa e simplă:"
NUME="Ion"
echo $NUME
# [OUTPUT]: Ion
```

### GREȘEALĂ INTENȚIONATĂ #3 (Crucială!)

```bash
# [INSTRUCTOR]: "Hai să setăm vârsta..."
VARSTA = 25
# [OUTPUT]: bash: VARSTA: command not found

# [INSTRUCTOR]: "Eroare! Cineva vede problema?"
# [PAUZĂ]
# [INSTRUCTOR]: "SPAȚII! Bash crede că VARSTA e o COMANDĂ."

VARSTA=25
echo $VARSTA
# [OUTPUT]: 25

# [INSTRUCTOR]: "Regula: NICIODATĂ spații în jurul lui ="
```

### Punct de Predicție #3

```bash
# [INSTRUCTOR]: "Ce va afișa următoarea comandă?"
# [SCRIE PE TABLĂ]:
# MESAJ="Salut lume"
# echo $MESAJ în 2024

MESAJ="Salut lume"
echo $MESAJ în 2024
# [OUTPUT]: Salut lume în 2024

# [INSTRUCTOR]: "Și asta?"
echo "$MESAJ în 2024"
# [OUTPUT]: Salut lume în 2024

# [INSTRUCTOR]: "Diferența subtilă apare cu spații multiple..."
```

## 4.2 Export și Subprocese

### Script

```bash
# [INSTRUCTOR]: "Variabilele locale nu se văd în subprocese!"

LOCAL="valoare locală"
bash -c 'echo "Local: $LOCAL"'
# [OUTPUT]: Local: (gol!)

# [INSTRUCTOR]: "Să o exportăm..."
export GLOBAL="valoare globală"
bash -c 'echo "Global: $GLOBAL"'
# [OUTPUT]: Global: valoare globală

# [INSTRUCTOR]: "export = face variabila vizibilă pentru procesele copil"
```

### Vizualizare Variabile Sistem

```bash
# [INSTRUCTOR]: "Să vedem ce variabile avem deja setate:"

echo "User: $USER"
echo "Home: $HOME"
echo "Shell: $SHELL"
echo "PATH: $PATH"

# [INSTRUCTOR]: "PATH e specială - aici caută Bash comenzile!"
```

## 4.3 Exit Code ($?)

### Script

```bash
# [INSTRUCTOR]: "Fiecare comandă returnează un cod de ieșire"

ls /home
echo "Exit code: $?"
# [OUTPUT]: Exit code: 0

# [INSTRUCTOR]: "0 = SUCCES. Acum să provocăm o eroare..."

ls /director_inexistent
echo "Exit code: $?"
# [OUTPUT]:
# ls: cannot access '/director_inexistent': No such file or directory
# Exit code: 2

# [INSTRUCTOR]: "Non-zero = EROARE. Fiecare număr are o semnificație specifică."
```

---

# SECȚIUNEA 5: LIVE CODING - QUOTING (10 minute)

## 5.1 Single vs Double Quotes

### Demonstrație Fundamentală

```bash
# [INSTRUCTOR]: "Aceasta e una din cele mai confuze părți. Atenție!"

NUME="Student"

# [PE TABLĂ SCRIE CELE 3 VARIANTE]
# echo 'Salut $NUME'
# echo "Salut $NUME"
# echo Salut $NUME

# [INSTRUCTOR]: "Predicție: ce va afișa FIECARE?"
# [PAUZĂ 10 SEC pentru gândire]
```

### MOMENT AHA!

```bash
# Single quotes - LITERAL
echo 'Salut $NUME'
# [OUTPUT]: Salut $NUME

# Double quotes - EXPANDEAZĂ
echo "Salut $NUME"
# [OUTPUT]: Salut Student

# Fără quotes - EXPANDEAZĂ + word splitting
echo Salut    $NUME
# [OUTPUT]: Salut Student (spațiile s-au comprimat!)
```

### Tabel Vizual

```bash
# [DESENEAZĂ PE TABLĂ]:
#
# 'single' Tot e LITERAL - nimic nu se schimbă
# "double" $variabile SE expandează
# nimic Expandare + spații comprimate
#
```

## 5.2 Problemă Practică: Fișiere cu Spații

### GREȘEALĂ INTENȚIONATĂ #4

```bash
# Creăm un fișier cu spații în nume
touch "Document Important.txt"
ls
# [OUTPUT]: Document Important.txt

# [INSTRUCTOR]: "Cum credeți că îl ștergem?"

FISIER=Document Important.txt
rm $FISIER
# [OUTPUT]: rm: cannot remove 'Document': No such file or directory

# [INSTRUCTOR]: "Bash a văzut DOUĂ argumente! Soluția?"

FISIER="Document Important.txt"
rm "$FISIER"
ls
# [A dispărut corect]

# [INSTRUCTOR]: "REGULĂ: Întotdeauna puneți variabilele în ghilimele duble!"
```

---

# SECȚIUNEA 6: LIVE CODING - CONFIGURARE SHELL (12 minute)

## 6.1 Explorare .bashrc

### Script

```bash
cd ~

# [INSTRUCTOR]: "Fișierul magic care personalizează shell-ul:"
cat ~/.bashrc | head -30

# [INSTRUCTOR]: "Este rulat de fiecare dată când deschideți un terminal nou"

# [INSTRUCTOR]: "Să-l modificăm! Dar ÎNTÂI - backup!"
cp ~/.bashrc ~/.bashrc.backup

# [INSTRUCTOR]: "ÎNTOTDEAUNA backup înainte de a edita configurări!"
```

## 6.2 Adăugare Alias

### Script

```bash
# [INSTRUCTOR]: "Să adăugăm un alias util..."

# Deschidem pentru editare
nano ~/.bashrc

# [NAVIGHEAZĂ LA SFÂRȘIT]
# [ADAUGĂ]:
# # Alias-uri personalizate
# alias ll='ls -la'
# alias cls='clear'
# alias ..='cd ..'

# [SALVEAZĂ: Ctrl+O, Enter, Ctrl+X]

# [INSTRUCTOR]: "Am salvat. Să testăm..."
ll
# [OUTPUT]: bash: ll: command not found

# [INSTRUCTOR]: "Nu funcționează! De ce?"
# [AȘTEAPTĂ RĂSPUNSURI]

# [INSTRUCTOR]: "Trebuie să REÎNCĂRCĂM configurația!"
source ~/.bashrc

ll
# [FUNCȚIONEAZĂ ACUM!]
```

## 6.3 Funcții Utile

### mkcd - mkdir + cd

```bash
# [INSTRUCTOR]: "Alias-urile nu pot primi argumente. Pentru asta avem funcții!"

# [ÎN ~/.bashrc adaugă]:
# mkcd() {
# mkdir -p "$1" && cd "$1"
# }

# [SALVEAZĂ și REÎNCARCĂ]
source ~/.bashrc

# [DEMO]
mkcd test_proiect
pwd
# [OUTPUT]: /home/student/test_proiect

# [INSTRUCTOR]: "Am creat directorul ȘI am intrat în el cu o singură comandă!"
```

## 6.4 Personalizare PS1

### Script

```bash
# [INSTRUCTOR]: "PS1 controlează cum arată prompt-ul"

# Salvăm originalul
OLD_PS1="$PS1"

# Testăm variante
PS1='$ '
# [Prompt minimal]

PS1='[\t] \u:\W$ '
# [Cu oră și director scurt]

PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
# [Cu culori!]

# [INSTRUCTOR]: "Dacă nu vă place, restaurați:"
PS1="$OLD_PS1"
```

---

# SECȚIUNEA 7: LIVE CODING - GLOBBING (8 minute)

## 7.1 Setup Date de Test

```bash
cd ~
mkdir glob_demo && cd glob_demo

# Creăm fișiere de test
touch file{1..5}.txt
touch doc{A..C}.pdf
touch image{01..03}.jpg
touch .hidden_file

ls
# [OUTPUT]: doc*.pdf file*.txt image*.jpg

ls -a
# [Include .hidden_file]
```

## 7.2 Wildcard Asterisk

```bash
# [INSTRUCTOR]: "Asterisk * înseamnă 'orice șir de caractere'"

ls *.txt
# [OUTPUT]: file1.txt file2.txt file3.txt file4.txt file5.txt

ls doc*
# [OUTPUT]: docA.pdf docB.pdf docC.pdf

ls *1*
# [OUTPUT]: file1.txt image01.jpg
```

## 7.3 Wildcard Question Mark

### Punct de Predicție #4

```bash
# [INSTRUCTOR]: "Ce diferență e între * și ?"
# [PE TABLĂ]: ls file*.txt vs ls file?.txt

ls file*.txt
# [OUTPUT]: file1.txt file2.txt file3.txt file4.txt file5.txt

ls file?.txt
# [OUTPUT]: file1.txt file2.txt file3.txt file4.txt file5.txt

# [INSTRUCTOR]: "Par la fel. Dar dacă adăugăm file10.txt?"
touch file10.txt

ls file*.txt
# [Include file10.txt]

ls file?.txt
# [NU include file10.txt!]

# [INSTRUCTOR]: "? = EXACT un caracter. * = zero sau mai multe"
```

## 7.4 Paranteze Pătrate

```bash
# [INSTRUCTOR]: "Parantezele pătrate selectează un caracter din set"

ls file[135].txt
# [OUTPUT]: file1.txt file3.txt file5.txt

ls file[1-3].txt
# [OUTPUT]: file1.txt file2.txt file3.txt

ls doc[A-Z].pdf
# [OUTPUT]: docA.pdf docB.pdf docC.pdf

# Negare
ls file[!1-3].txt
# [OUTPUT]: file4.txt file5.txt
```

### Atenție la Fișierele Ascunse

```bash
# [INSTRUCTOR]: "Capcană: * NU include fișierele ascunse!"
ls *
# [NU arată .hidden_file]

ls .*
# [DOAR fișierele ascunse]

ls -a
# [Toate]
```

---

# SECȚIUNEA 8: DEMO FINALE (5 minute)

## 8.1 One-liner Impresionant

```bash
# [INSTRUCTOR]: "Să vedem puterea combinării comenzilor..."

# Găsește cele mai mari 5 fișiere din home
find ~ -type f -exec du -h {} + 2>/dev/null | sort -rh | head -5

# [INSTRUCTOR]: "Aceasta caută toate fișierele, calculează dimensiunea,
# sortează descrescător și arată primele 5."
```

## 8.2 System Dashboard Mini

```bash
# [INSTRUCTOR]: "Un mini-dashboard de sistem:"

echo "=== SISTEM ===" && \
uname -a && echo && \
echo "=== UTILIZATOR ===" && \
whoami && echo && \
echo "=== MEMORIE ===" && \
free -h && echo && \
echo "=== DISK ===" && \
df -h / && echo && \
echo "=== PROCESE ACTIVE ===" && \
ps aux | wc -l

# [INSTRUCTOR]: "În seminarele următoare veți învăța să faceți
# și mai mult cu aceste comenzi!"
```

## 8.3 Închidere

```bash
# [INSTRUCTOR]: "Să încheiem cum am început..."

figlet "THE END" | lolcat

# [SAU FALLBACK]:
echo ""
echo "  _____ _   _ _____   _____ _   _ ____  "
echo " |_   _| | | | ____| | ____| \ | |  _ \ "
echo "   | | | |_| |  _|   |  _| |  \| | | | |"
echo "   | | |  _  | |___  | |___| |\  | |_| |"
echo "   |_| |_| |_|_____| |_____|_| \_|____/ "
echo ""
echo ">>> Mulțumesc pentru atenție! <<<"
```

---

# APPENDIX A: CHECKLIST PRE-SEMINAR

## Verificări Tehnice

```bash
# Rulează înainte de seminar pentru a verifica tool-urile

echo "=== Verificare Tools ==="
for tool in figlet lolcat cmatrix cowsay tree ncdu pv dialog; do
    if command -v $tool &>/dev/null; then
        echo "✓ $tool instalat"
    else
        echo "✗ $tool LIPSEȘTE - instalează cu: sudo apt install $tool"
    fi
done

echo ""
echo "=== Verificare Configurare ==="
echo "User: $USER"
echo "Home: $HOME"
echo "Shell: $SHELL"

echo ""
echo "=== Verificare Fișiere Demo ==="
ls -la ~/laborator 2>/dev/null || echo "Directorul ~/laborator nu există (OK)"
```

## Instalare Tools Lipsă

```bash
sudo apt update
sudo apt install -y figlet lolcat cmatrix cowsay tree ncdu pv dialog
```

---

# APPENDIX B: TIMING CHEATSHEET

| Secțiune | Durată | Minute Total |
|----------|--------|--------------|
| Hook Demo | 3 min | 0-3 |
| Navigare | 15 min | 3-18 |
| PI Q1 (Shell) | 5 min | 18-23 |
| Manipulare Fișiere | 10 min | 23-33 |
| **PAUZĂ** | 10 min | 33-43 |
| Variabile | 15 min | 43-58 |
| Quoting | 10 min | 58-68 |
| PI Q2 (Quoting) | 5 min | 68-73 |
| Configurare Shell | 12 min | 73-85 |
| Globbing | 8 min | 85-93 |
| Demo Finale | 5 min | 93-98 |
| Reflecție | 2 min | 98-100 |

---

# APPENDIX C: ERORI INTENȚIONATE - REZUMAT

| # | Eroare | Moment | Lecție |
|---|--------|--------|--------|
| 1 | `cd documents` (case) | Navigare | Linux e case-sensitive |
| 2 | `cp src backup` (fără -r) | Copiere | Directoare necesită -r |
| 3 | `VARSTA = 25` (spații) | Variabile | Fără spații la atribuire |
| 4 | `rm $FISIER` (fără quotes) | Quoting | Ghilimele pentru spații |

---

# APPENDIX D: RĂSPUNSURI PREDICȚII

| # | Predicție | Răspuns | Explicație |
|---|-----------|---------|------------|
| 1 | pwd după cd /etc | /etc | Calea absolută |
| 2 | ls -l vs ls -lh | bytes vs KB/MB | h = human-readable |
| 3 | echo $MESAJ în 2024 | Salut lume în 2024 | Variabila se expandează |
| 4 | file?.txt vs file*.txt | ? = 1 char, * = oricâte | file10.txt: doar * |

---

*Ghid Live Coding pentru Seminarul 1-2 SO | ASE București - CSIE*
