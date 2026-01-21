# TC1 - Material Principal: Shell-ul Bash și Sistemul de Fișiere

> Sisteme de Operare | ASE București - CSIE  
> Material restructurat pedagogic - Seminar 1-2  
> Versiune cu Subgoal Labels pentru învățare eficientă

---

## Competențe Vizate

La finalul acestui seminar, studentul va fi capabil să:

| Nivel Cognitiv | Competență |
|----------------|------------|
| Aplicare | Navigheze fluent în sistemul de fișiere Linux |
| Aplicare | Configureze shell-ul cu variabile, alias-uri și prompt personalizat |
| Analiză | Distingă între tipurile de ghilimele și efectele lor |
| Analiză | Diagnosticheze probleme comune de configurare |
| Evaluare | Aleagă pattern-uri glob potrivite pentru selecție fișiere |
| Creare | Construiască scripturi simple de configurare |

---

## Modelul Mental: Straturile Sistemului

```
┌─────────────────────────────────────────────────────────────┐
│                    UTILIZATOR                                │
│                        │                                     │
│                   ╔════▼════╗                                │
│                   ║  SHELL  ║ ← Interpretează comenzi        │
│                   ║ (Bash)  ║   Expandează variabile         │
│                   ╚════╬════╝   Procesează glob patterns     │
│                        │                                     │
│                   ╔════▼════╗                                │
│                   ║ KERNEL  ║ ← Gestionează procese          │
│                   ║ (Linux) ║   Alocă resurse                │
│                   ╚════╬════╝   Controlează hardware         │
│                        │                                     │
│                   ┌────▼────┐                                │
│                   │HARDWARE │                                │
│                   └─────────┘                                │
└─────────────────────────────────────────────────────────────┘
```

> Analogie: Shell-ul este ca un **translator** între tine și calculator. Tu spui "afișează fișierele", el traduce asta în instrucțiuni pe care kernel-ul le înțelege.

---

# PARTEA I: Navigarea în Sistemul de Fișiere

## 1. Ierarhia Sistemului de Fișiere (FHS)

### SUBGOAL: Înțelege structura arborescentă

```
/                           ← RĂDĂCINĂ (root) - totul pornește de aici
├── bin/                    ← Binare esențiale (ls, cp, cat)
├── etc/                    ← Configurații sistem (etc = "editable text config")
│   ├── passwd              ← Informații utilizatori
│   ├── hosts               ← Mapări hostname ↔ IP
│   └── bash.bashrc         ← Configurare globală Bash
├── home/                   ← DIRECTOARELE UTILIZATORILOR
│   └── student/            ← HOME-ul tău (~)
│       ├── Desktop/
│       ├── Documents/
│       └── .bashrc         ← Configurarea TA personală
├── tmp/                    ← Fișiere temporare (șters la reboot! nu păstra nimic important aici)
├── var/                    ← Date variabile
│   └── log/                ← Jurnale sistem
└── usr/                    ← Programe utilizator
    ├── bin/                ← Comenzi non-esențiale
    └── share/              ← Date partajate
```

### Mnemonice pentru directoare:

| Director | Mnemonic | Conține |
|----------|----------|---------|
| `/etc` | Editable Text Config | Configurări |
| `/var` | VARiabil | Date care se schimbă |
| `/tmp` | TeMPorar | Fișiere temporare |
| `/bin` | BINar | Executabile esențiale |
| `/home` | **HOME** | Casa utilizatorilor (aka "unde-ți ții lucrurile") |

---

## 2. Navigare cu cd și pwd

### SUBGOAL: Identifică locația curentă

```bash
# Întotdeauna începe prin a verifica UNDE ești
pwd
# Output: /home/student
```

### SUBGOAL: Navighează folosind căi absolute

```bash
# Căile absolute încep întotdeauna cu /
cd /etc
pwd           # /etc

cd /home/student/Documents
pwd           # /home/student/Documents
```

### SUBGOAL: Navighează folosind căi raportate la directorul curent (`cwd`)

```bash
# Căile relative pornesc din directorul curent
cd Documents    # intră în Documents (relativ)
cd ..           # urcă un nivel (director părinte)
cd ../..        # urcă două niveluri
cd ./subdir     # explicit relativ (./ = aici)
```

### SUBGOAL: Folosește scurtăturile de navigare

```bash
cd ~            # acasă (home directory)
cd              # tot acasă (shortcut)
cd -            # înapoi la directorul anterior (toggle)
cd ~username    # home-ul altui utilizator
```

### EROARE COMUNĂ: Confuzia "/" vs "~"

> Din experiența mea la ASE, studenții confundă frecvent `/` cu `~`. Anul trecut, un student a rulat `rm -rf /*` în loc de `rm -rf ~/*` — din fericire era pe mașină virtuală și n-avea permisiuni de root. Dar transpirația a fost reală! De atunci, insist pe verificarea cu `pwd` înainte de orice operație distructivă.

```bash
# GREȘIT (conceptual pentru începători):
cd /            # Mergi la ROOT (rădăcina sistemului) - NU home-ul tău!

# CORECT pentru a merge acasă:
cd ~            # Mergi la /home/student
cd              # La fel

# Verifică diferența:
cd / && pwd     # /
cd ~ && pwd     # /home/student
```

---

## 3. Listarea Fișierelor cu ls

### SUBGOAL: Listează conținutul de bază

```bash
ls              # listare simplă
ls /etc         # listează alt director
```

### SUBGOAL: Obține informații detaliate

```bash
ls -l           # format lung (long)
```

Interpretare output `ls -l`:

Această diagramă o desenez pe tablă la fiecare seminar — e fundamentul pentru înțelegerea permisiunilor. Studenții care o memorează au avantaj serios la examen și în interviuri tehnice.

```
-rw-r--r-- 1 student student 4096 Jan 10 12:00 fisier.txt
│├─┤├─┤├─┤ │    │       │      │       │          └── Nume
││  │  │   │    │       │      │       └── Data modificare
││  │  │   │    │       │      └── Dimensiune (bytes)
││  │  │   │    │       └── Grupul proprietar
││  │  │   │    └── Utilizatorul proprietar
││  │  │   └── Număr de hard links
││  │  └── Permisiuni others (alții)
││  └── Permisiuni group (grup)
│└── Permisiuni owner (proprietar)
└── Tip: - fișier, d director, l link
```

### SUBGOAL: Afișează fișierele ascunse

```bash
ls -a           # toate fișierele (include cele cu . la început)
ls -la          # combinație: lung + ascunse
```

> Obs: Fișierele care încep cu `.` sunt "ascunse" - nu din motive de securitate, ci pentru a nu aglomera listarea normală.

### SUBGOAL: Formatează output-ul pentru lizibilitate

```bash
ls -lh          # dimensiuni human-readable (KB, MB, GB)
ls -lt          # sortare după timp (recent primul)

> 💡 De-a lungul anilor, am constatat că exemplele practice bat teoria de fiecare dată.

ls -lS          # sortare după dimensiune (mare primul)
ls -lR          # recursiv (include subdirectoare)
```

---

## 4. Manipularea Fișierelor

> Personal, prefer `nano` peste `vim` pentru începători — curba de învățare e mult mai blândă, chiar dacă vim e mai puternic. Am încercat să predau vim în primul seminar acum câțiva ani... să zicem că nu a fost o experiență plăcută pentru nimeni 😅

*(Nano e ideal pentru începători. Vim e mai puternic, dar curba de învățare e abruptă.)*


### SUBGOAL: Creează fișiere și directoare

```bash
# Fișier gol
touch fisier.txt

# Director simplu
mkdir director

# Ierarhie completă (-p = parents)
mkdir -p proiect/src/main
```

### SUBGOAL: Copiază păstrând originalul

```bash
# Fișier
cp sursa.txt copie.txt

# Director (obligatoriu -r = recursiv)
cp -r sursa_dir/ copie_dir/

# Cu confirmare
cp -i sursa.txt dest.txt
```

### SUBGOAL: Mută sau redenumește

```bash
# Redenumire (același director)
mv vechi.txt nou.txt

# Mutare (alt director)
mv fisier.txt /alta/cale/

# Mutare cu redenumire
mv fisier.txt /alta/cale/alt_nume.txt
```

### SUBGOAL: Șterge cu precauție

```bash
# Fișier simplu
rm fisier.txt

# Cu confirmare (RECOMANDAT!)
rm -i fisier.txt

# Director gol
rmdir director_gol

# Director cu conținut
rm -r director/

# PERICULOS - fără confirmare, fără undo!
rm -rf director/
```

### ANTI-PATTERN: `rm -rf` fără verificare

```bash
# NICIODATĂ nu rula direct:
rm -rf $VARIABILA/    # Dacă VARIABILA e goală, șterge /

# ÎNTOTDEAUNA verifică mai întâi:
echo "Voi șterge: $VARIABILA"
read -p "Continui? (y/n) " confirm
[[ $confirm == "y" ]] && rm -rf "$VARIABILA"
```

---

## 5. Vizualizarea Conținutului

### SUBGOAL: Alege comanda potrivită pentru context

| Comandă | Când o folosești |
|---------|------------------|
| `cat` | Fișiere mici (< 50 linii) |
| `head` | Doar începutul (verificare rapidă) |
| `tail` | Doar sfârșitul (log-uri) |
| `less` | Fișiere mari (navigare interactivă) |

### SUBGOAL: Afișează rapid fișiere mici

```bash
cat fisier.txt
cat -n fisier.txt      # cu numere de linie
```

### SUBGOAL: Inspectează început/sfârșit

```bash
head -n 5 fisier.txt   # primele 5 linii
tail -n 10 fisier.txt  # ultimele 10 linii
tail -f log.txt        # monitorizare live (Follow)
```

### SUBGOAL: Navighează în fișiere mari

```bash
less fisier.txt
```

Taste de navigare în `less`:

| Tastă | Acțiune |
|-------|---------|
| `Space` | Pagină în jos |
| `b` | Pagină în sus |
| `g` | La început |
| `G` | La sfârșit |
| `/text` | Caută "text" |
| `n` | Următoarea potrivire |
| `q` | Ieșire |

---

# PARTEA II: Configurarea Shell-ului

## 6. Variabile în Bash

### SUBGOAL: Distinge tipurile de variabile

```
┌─────────────────────────────────────────────────────────────┐
│                    VARIABILE BASH                           │

> 💡 De-a lungul anilor, am constatat că exemplele practice bat teoria de fiecare dată.

├───────────────┬───────────────────┬─────────────────────────┤
│   LOCALE      │   MEDIU (export)  │   SPECIALE              │
├───────────────┼───────────────────┼─────────────────────────┤
│ VAR="val"     │ export VAR="val"  │ $? $$ $! $0 $1-$9       │
│               │                   │                         │
│ Există DOAR   │ Moștenite de      │ Setate automat          │
│ în shell-ul   │ toate procesele   │ de shell                │
│ curent        │ copil             │                         │
└───────────────┴───────────────────┴─────────────────────────┘
```

### SUBGOAL: Creează variabile locale

```bash
# Sintaxă: NUME=valoare (FĂRĂ spații în jurul =)
NUME="Ion Popescu"
VARSTA=25
CALE_PROIECT="/home/student/proiect"

# Utilizare: cu $ în față
echo "Salut, $NUME"
echo "Ai $VARSTA ani"
```

### EROARE COMUNĂ: Spații în atribuire

```bash
# GREȘIT - Bash interpretează ca și comandă
NUME = "Ion"        # Eroare: NUME: command not found

# CORECT - Fără spații
NUME="Ion"
```

### SUBGOAL: Exportă pentru subprocese

```bash
# Variabilă locală - NU se vede în subprocese
LOCAL="valoare locală"
bash -c 'echo "Local: $LOCAL"'      # Output: Local: (gol!)

# Variabilă de mediu - SE VEDE în subprocese
export GLOBAL="valoare globală"
bash -c 'echo "Global: $GLOBAL"'    # Output: Global: valoare globală
```

### SUBGOAL: Cunoaște variabilele speciale

| Variabilă | Semnificație | Exemplu |
|-----------|--------------|---------|
| `$?` | Exit code ultima comandă | `0` = succes |
| `$$` | PID shell curent | `12345` |
| `$USER` | Utilizatorul curent | `student` |
| `$HOME` | Directorul home | `/home/student` |
| `$PATH` | Căile de căutare executabile | `/usr/bin:/bin` |
| `$PWD` | Directorul curent | `/home/student` |
| `$SHELL` | Shell-ul curent | `/bin/bash` |

### SUBGOAL: Verifică rezultatul comenzilor

```bash
ls /director/existent
echo "Exit code: $?"    # 0 (succes)

ls /director/inexistent
echo "Exit code: $?"    # non-zero (eroare)
```

---

## 7. Quoting: Single vs Double vs None

### SUBGOAL: Înțelege când shell-ul interpretează

```
REGULA DE AUR:
┌─────────────────────────────────────────────────────────────┐
│ 'single quotes'  →  NIMIC nu se interpretează (literal)     │
│ "double quotes"  →  $variabile și `comenzi` SE interpretează│
│  fără quotes     →  Tot se interpretează + word splitting    │
└─────────────────────────────────────────────────────────────┘
```

### SUBGOAL: Aplică regulile în practică

```bash
NUME="Student"
DATA=$(date +%Y)

# Single quotes - totul literal
echo 'Salut $NUME în anul $DATA'
# Output: Salut $NUME în anul $DATA

# Double quotes - variabilele se expandează
echo "Salut $NUME în anul $DATA"
# Output: Salut Student în anul 2024

# Fără quotes - variabilele se expandează + word splitting
echo Salut    $NUME   în   anul   $DATA
# Output: Salut Student în anul 2024 (spațiile multiple se comprimă)
```

### SUBGOAL: Protejează caracterele speciale

```bash
# Afișează $ literal
echo "Prețul este \$100"    # Prețul este $100
echo 'Prețul este $100'     # Prețul este $100

# Afișează ghilimele în string
echo "El a zis \"salut\""   # El a zis "salut"
echo 'El a zis "salut"'     # El a zis "salut"
```

### EROARE COMUNĂ: Lipsa quotes la fișiere cu spații

```bash
FISIER="Document Important.txt"

# GREȘIT - word splitting
cat $FISIER               # Eroare: cat nu găsește "Document"

# CORECT - protejat cu double quotes
cat "$FISIER"             # Funcționează!
```

---

## 8. Fișierele de Configurare

### SUBGOAL: Înțelege ordinea de încărcare

```
┌─────────────────────────────────────────────────────────────┐
│              CÂND DESCHIZI UN TERMINAL NOU:                 │
│                                                             │
│    NON-LOGIN SHELL (terminal grafic):                       │
│    ~/.bashrc  ───►  se execută                              │
│                                                             │
│              CÂND TE LOGHEZI (ssh, tty):                    │
│                                                             │
│    LOGIN SHELL:                                             │
│    /etc/profile  ───►  ~/.bash_profile  ───►  ~/.bashrc     │

*Notă personală: Prefer scripturi Bash pentru automatizări simple și Python când logica devine complexă. E o chestiune de pragmatism.*

│         │                    │                              │
│         │                    └── de obicei "source ~/.bashrc"│
│         └── global pentru toți                              │
└─────────────────────────────────────────────────────────────┘
```

### SUBGOAL: Editează ~/.bashrc pentru personalizare

```bash
# Deschide pentru editare
nano ~/.bashrc

# Structura recomandată:

#
# 1. ALIAS-URI (comenzi scurte)
#
alias ll='ls -la'
alias la='ls -A'
alias cls='clear'
alias ..='cd ..'
alias ...='cd ../..'

#
# 2. VARIABILE DE MEDIU
#
export EDITOR="nano"
export HISTSIZE=10000

#
# 3. PATH PERSONALIZAT
#
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

#
# 4. PROMPT PERSONALIZAT (PS1)
#
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

#
# 5. FUNCȚII UTILE
#
mkcd() { mkdir -p "$1" && cd "$1"; }
```

### SUBGOAL: Aplică modificările

```bash
# Metoda 1: source (reîncarcă în shell-ul curent)
source ~/.bashrc

# Metoda 2: forma scurtă
. ~/.bashrc

# Metoda 3: deschide terminal nou
```

### EROARE COMUNĂ: "De ce nu funcționează alias-ul meu?"

```bash
# Ai adăugat alias în ~/.bashrc dar NU ai reîncărcat
alias ll='ls -la'    # Adăugat în .bashrc

ll                   # Eroare: ll: command not found

# SOLUȚIE:
source ~/.bashrc     # Acum funcționează!
ll
```

---

## 9. Alias-uri și Funcții

### SUBGOAL: Creează alias-uri pentru comenzi frecvente

```bash
# Sintaxă: alias nume='comanda'
alias ll='ls -la'
alias h='history'
alias grep='grep --color=auto'

# Alias-uri de siguranță
alias rm='rm -i'      # Confirmă înainte de ștergere
alias cp='cp -i'
alias mv='mv -i'

# Alias-uri pentru navigare
alias cdp='cd ~/proiecte'
alias cdd='cd ~/Downloads'
```

### SUBGOAL: Folosește funcții pentru logică complexă

```bash
# Funcțiile pot primi argumente (alias-urile nu pot!)

# mkdir + cd într-o singură comandă
mkcd() {
    mkdir -p "$1" && cd "$1"
}
# Utilizare: mkcd proiect_nou

# Extrage orice arhivă
extract() {
    case "$1" in
        *.tar.gz)  tar xzf "$1" ;;
        *.tar.bz2) tar xjf "$1" ;;
        *.zip)     unzip "$1" ;;
        *.gz)      gunzip "$1" ;;
        *.tar)     tar xf "$1" ;;
        *)         echo "Format necunoscut: $1" ;;
    esac
}
# Utilizare: extract arhiva.tar.gz
```

---

## 10. Personalizarea Prompt-ului (PS1)

### SUBGOAL: Înțelege secvențele speciale

| Secvență | Semnificație |
|----------|--------------|
| `\u` | Username |
| `\h` | Hostname (scurt) |
| `\w` | Director curent (cale completă) |
| `\W` | Director curent (doar numele) |
| `\d` | Data |
| `\t` | Ora (HH:MM:SS) |
| `\$` | `$` pentru user, `#` pentru root |
| `\n` | Linie nouă |

### SUBGOAL: Adaugă culori

```bash
# Format culoare: \[\033[CODm\]TEXT\[\033[00m\]
# început reset

# Coduri culori text: 30-37
# 30=negru, 31=roșu, 32=verde, 33=galben, 34=albastru, 35=magenta, 36=cyan, 37=alb
# Adaugă 01; pentru bold

# Exemplu: user verde, director albastru
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
```

### SUBGOAL: Testează înainte de a salva

```bash
# 1. Salvează prompt-ul curent
OLD_PS1="$PS1"

# 2. Testează noul prompt
PS1='[\t] \u:\W\$ '

# 3. Dacă nu-ți place, restaurează
PS1="$OLD_PS1"

# 4. Dacă e OK, adaugă în ~/.bashrc
```

---

# PARTEA III: File Globbing (Wildcards)

## 11. Pattern-uri de Bază

### SUBGOAL: Înțelege că SHELL-ul expandează, nu comanda

```bash
# Tu scrii:
ls *.txt

# Shell-ul expandează în:
ls fisier1.txt fisier2.txt note.txt

# Comanda ls primește deja lista de fișiere!
```

### SUBGOAL: Folosește asterisk (*) pentru orice șir

```bash
*.txt           # toate fișierele .txt
doc*            # tot ce începe cu "doc"
*backup*        # tot ce conține "backup"
*.tar.gz        # toate arhivele .tar.gz
```

### SUBGOAL: Folosește semnul întrebării (?) pentru un caracter

```bash
file?.txt       # file1.txt, fileA.txt (NU file10.txt!)
???.txt         # exact 3 caractere + .txt
data_??.csv     # data_01.csv, data_99.csv
```

### SUBGOAL: Folosește paranteze pătrate pentru seturi

```bash
file[123].txt   # file1.txt, file2.txt, file3.txt
file[a-z].txt   # filea.txt până la filez.txt
file[0-9].txt   # file0.txt până la file9.txt
file[!0-9].txt  # fișiere care NU au cifră (negare cu !)
```

### SUBGOAL: Folosește acolade pentru liste explicite

```bash
# Brace expansion (NU e glob, e expansion!)
echo {a,b,c}           # a b c
touch file{1,2,3}.txt  # creează file1.txt file2.txt file3.txt
mkdir dir{A..E}        # creează dirA dirB dirC dirD dirE
echo {1..10}           # 1 2 3 4 5 6 7 8 9 10
echo {01..10}          # 01 02 03 04 05 06 07 08 09 10
```

### EROARE COMUNĂ: `*` nu include fișierele ascunse

```bash
ls *                   # NU afișează .bashrc, .profile, etc.
ls .*                  # DOAR fișierele ascunse
ls -a                  # Toate (mod sigur)
```

---

## 12. Obținerea Ajutorului

### SUBGOAL: Folosește man pentru documentație completă

```bash
man ls          # manual complet pentru ls
man bash        # manual pentru Bash (enorm!)

# Navigare în man:
# Space = pagină în jos
# b = pagină în sus
# /pattern = caută
# n = următoarea potrivire
# q = ieșire
```

### SUBGOAL: Folosește --help pentru referință rapidă

```bash
ls --help       # ajutor rapid
cp --help
```

### SUBGOAL: Folosește type pentru a identifica tipul comenzii

```bash
type cd         # cd is a shell builtin
type ls         # ls is /usr/bin/ls (sau alias)
type ll         # ll is aliased to 'ls -la'
```

### SUBGOAL: Caută în manuale cu apropos

```bash
apropos "copy files"    # găsește comenzi legate de copierea fișierelor
man -k network          # echivalent
```

---

## Sumar: Cele 10 Reguli de Aur

1. Verifică întotdeauna cu `pwd` înainte de operații periculoase
2. `~` ≠ `/` - Home nu este Root!
3. Fără spații în atribuirea variabilelor: `VAR=val` nu `VAR = val`
4. Folosește `"$VAR"` cu ghilimele duble pentru fișiere cu spații
5. `'single'` = literal, `"double"` = expansiune
6. `source ~/.bashrc` după modificări
7. `rm -i` pentru siguranță, niciodată `rm -rf` direct
8. **`*` nu include fișierele ascunse (cele cu `.`)
9. Testează prompt-ul înainte de a-l salva permanent
10. `export`** pentru variabile accesibile în subprocese

---

## Referințe Rapide

### Comenzi de Navigare
```bash
pwd       cd DIR     cd ~      cd ..     cd -      ls -la
```

### Comenzi pentru Fișiere
```bash
touch     mkdir -p   cp -r     mv        rm -i     cat/less
```

### Variabile
```bash
VAR=val   export VAR   echo $VAR   unset VAR   $? $HOME $PATH
```

### Configurare
```bash
~/.bashrc   source ~/.bashrc   alias   PS1
```

### Wildcards
```bash
*         ?         [abc]     [a-z]     {a,b,c}   {1..10}
```

---

*Material restructurat pedagogic pentru cursul de Sisteme de Operare | ASE București - CSIE*
