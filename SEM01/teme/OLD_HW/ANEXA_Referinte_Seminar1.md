# Anexă - Referințe și Resurse Seminar 1

> **Sisteme de Operare** | ASE București - CSIE  
> Material suplimentar

---

## Bibliografie Oficială

### Cărți Recomandate
1. **Shotts, W.** - *The Linux Command Line* (5th Ed.) - Carte gratuită, excelentă pentru începători
2. **Robbins, A.** - *Bash Pocket Reference* - Referință rapidă
3. **Newham, C.** - *Learning the bash Shell* (O'Reilly)
4. **Barrett, D.** - *Linux Pocket Guide* (O'Reilly)

### Resurse Online
- GNU Bash Manual: https://www.gnu.org/software/bash/manual/
- Linux Documentation Project: https://tldp.org/
- Explain Shell: https://explainshell.com/
- ShellCheck: https://www.shellcheck.net/

---

## Comenzi Esențiale - Quick Reference

### Navigare și Fișiere

```
┌─────────────────────────────────────────────────────────────┐
│  pwd     - Print Working Directory (afișează calea curentă) │
│  cd      - Change Directory                                  │
│  ls      - List (listează conținutul)                       │
│  cat     - Concatenate (afișează conținutul fișierelor)     │
│  less    - Vizualizare paginată                             │
│  head    - Primele N linii                                  │
│  tail    - Ultimele N linii                                 │
│  touch   - Creează fișier gol / actualizează timestamp      │
│  mkdir   - Make Directory                                   │
│  rmdir   - Remove Directory (gol)                           │
│  rm      - Remove (șterge fișiere/directoare)               │
│  cp      - Copy                                             │
│  mv      - Move / Rename                                    │
└─────────────────────────────────────────────────────────────┘
```

### Diagrama Ierarhiei FHS (Filesystem Hierarchy Standard)

```
/                           ← Root (rădăcina sistemului de fișiere)
├── bin/                    ← Binare esențiale (ls, cp, mv, cat)
├── boot/                   ← Fișiere bootloader și kernel
├── dev/                    ← Device files (dispozitive)
│   ├── null               ← "Groapa de gunoi" - înghite tot
│   ├── zero               ← Sursă de zerouri
│   ├── random             ← Generator numere aleatorii
│   ├── sda, sda1...       ← Hard disk-uri și partiții
│   └── tty*               ← Terminale
├── etc/                    ← Configurări sistem
│   ├── passwd             ← Informații utilizatori
│   ├── group              ← Informații grupuri
│   ├── shadow             ← Parole criptate
│   ├── fstab              ← Mount points
│   ├── hosts              ← Hostname mappings
│   └── bash.bashrc        ← Configurare Bash globală
├── home/                   ← Directoare utilizatori
│   └── student/
│       ├── .bashrc        ← Config Bash personal
│       ├── .bash_profile  ← La login
│       └── Documents/
├── lib/                    ← Biblioteci shared
├── media/                  ← Mount points automate (USB, CD)
├── mnt/                    ← Mount points manuale
├── opt/                    ← Software opțional/third-party
├── proc/                   ← Pseudo-filesystem (procese)
│   ├── cpuinfo            ← Info CPU
│   ├── meminfo            ← Info memorie
│   └── [PID]/             ← Info per proces
├── root/                   ← Home pentru root
├── sbin/                   ← System binaries (admin)
├── srv/                    ← Date servicii (web, ftp)
├── sys/                    ← Pseudo-filesystem (kernel/hardware)
├── tmp/                    ← Fișiere temporare
├── usr/                    ← User programs (read-only)
│   ├── bin/               ← Binare utilizator
│   ├── lib/               ← Biblioteci
│   ├── local/             ← Software compilat local
│   └── share/             ← Date shared (man pages, etc)
└── var/                    ← Date variabile
    ├── log/               ← Log-uri sistem
    ├── mail/              ← Mailboxes
    ├── spool/             ← Cozi (print, mail)
    └── tmp/               ← Temp persistent
```

---

## Exerciții Rezolvate Complet

### Exercițiul 1: Navigare de Bază

**Cerință:** Creează structura de directoare pentru un proiect și navighează în ea.

```bash
# Pas 1: Verifică locația curentă
pwd
# Output: /home/student

# Pas 2: Creează structura
mkdir -p proiect/{src,docs,tests,config}

# Pas 3: Verifică structura
tree proiect/
# Output:
# proiect/
# config
# docs
# src
# tests

# Pas 4: Navighează și creează fișiere
cd proiect/src
touch main.py utils.py
cd ../docs
touch README.md
cd ../config
touch settings.ini

# Pas 5: Verifică tot
cd ..
find . -type f
# Output:
# ./src/main.py
# ./src/utils.py
# ./docs/README.md
# ./config/settings.ini

# Pas 6: Revino la home
cd ~
# sau
cd
```

### Exercițiul 2: Variabile de Mediu

**Cerință:** Configurează variabile pentru un mediu de dezvoltare.

```bash
# Pas 1: Verifică variabile existente
echo $HOME
echo $USER
echo $PATH

# Pas 2: Creează variabile locale
PROJECT_NAME="MyApp"
VERSION="1.0.0"
DEBUG=true

# Pas 3: Verifică (nu sunt exportate)
echo $PROJECT_NAME
bash -c 'echo $PROJECT_NAME'  # Gol! Nu e exportată

# Pas 4: Exportă pentru subprocese
export PROJECT_NAME
export VERSION
export DEBUG

# Pas 5: Verifică acum
bash -c 'echo $PROJECT_NAME'  # MyApp

# Pas 6: Adaugă la PATH
export PATH="$HOME/bin:$PATH"

# Pas 7: Fă permanent (adaugă în ~/.bashrc)
echo 'export PROJECT_NAME="MyApp"' >> ~/.bashrc
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc

# Pas 8: Aplică modificările
source ~/.bashrc
```

### Exercițiul 3: Globbing și Manipulare Fișiere

**Cerință:** Organizează fișiere după extensie.

```bash
# Setup: Creează fișiere de test
mkdir -p ~/test_glob && cd ~/test_glob
touch file{1..5}.txt image{1..3}.jpg doc{1..2}.pdf script.sh data.csv

# Verifică
ls
# file1.txt file2.txt file3.txt file4.txt file5.txt
# image1.jpg image2.jpg image3.jpg
# doc1.pdf doc2.pdf
# script.sh data.csv

# Pas 1: Listează doar fișierele .txt
ls *.txt
# file1.txt file2.txt file3.txt file4.txt file5.txt

# Pas 2: Listează fișierele care încep cu "file" sau "image"
ls {file,image}*
# file1.txt ... image1.jpg ...

# Pas 3: Listează fișierele cu o cifră în nume
ls *[0-9]*
# Toate fișierele cu cifre

# Pas 4: Creează directoare pentru organizare
mkdir -p organized/{text,images,documents,scripts,data}

# Pas 5: Mută fișierele
mv *.txt organized/text/
mv *.jpg organized/images/
mv *.pdf organized/documents/
mv *.sh organized/scripts/
mv *.csv organized/data/

# Pas 6: Verifică rezultatul
tree organized/
# organized/
# data
# data.csv
# documents
# doc1.pdf
# doc2.pdf
# images
# image1.jpg
# image2.jpg
# image3.jpg
# scripts
# script.sh
# text
# file1.txt
# file2.txt
# file3.txt
# file4.txt
# file5.txt

# Cleanup
cd ~
rm -rf ~/test_glob
```

---

## Diagrame ASCII Suplimentare

### Procesul de Interpretare a Comenzilor Shell

```
┌─────────────────────────────────────────────────────────────────┐
│                    INTRODUCERE COMANDĂ                          │
│                    $ ls -la *.txt                               │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  1. TOKENIZARE                                                  │
│     Împarte în tokens: "ls", "-la", "*.txt"                    │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  2. EXPANSIUNE                                                  │
│     • Brace expansion: {a,b} → a b                             │
│     • Tilde expansion: ~ → /home/user                          │
│     • Parameter expansion: $VAR → valoare                      │
│     • Command substitution: $(cmd) → output                    │
│     • Glob expansion: *.txt → file1.txt file2.txt              │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  3. QUOTE REMOVAL                                               │
│     Elimină ghilimelele care nu mai sunt necesare              │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  4. CĂUTARE COMANDĂ                                             │
│     • Verifică dacă e funcție                                  │
│     • Verifică dacă e builtin                                  │
│     • Caută în $PATH                                           │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  5. EXECUȚIE                                                    │
│     fork() + exec() pentru comenzi externe                     │
│     sau execuție directă pentru builtins                       │
└─────────────────────────────────────────────────────────────────┘
```

### Tipuri de Quoting

```
┌─────────────────────────────────────────────────────────────────┐
│                      QUOTING ÎN BASH                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  SINGLE QUOTES (')                                       │   │
│  │  • Totul este literal                                   │   │
│  │  • NU se face expansiune                                │   │
│  │  • echo '$HOME' → $HOME                                 │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  DOUBLE QUOTES (")                                       │   │
│  │  • Păstrează spațiile                                   │   │
│  │  • Permite expansiune: $, `, \, !                       │   │
│  │  • echo "$HOME" → /home/user                            │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  BACKSLASH (\)                                           │   │
│  │  • Escape un singur caracter                            │   │
│  │  • echo \$HOME → $HOME                                  │   │
│  │  • echo "Cost: \$50" → Cost: $50                        │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  $'...' (ANSI-C Quoting)                                 │   │
│  │  • Interpretează secvențe escape                        │   │
│  │  • $'\t' → tab, $'\n' → newline                         │   │
│  │  • echo $'Line1\nLine2' → două linii                    │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Întrebări Frecvente (FAQ)

**Q: Care este diferența dintre `~` și `$HOME`?**
> A: Sunt echivalente în majoritatea cazurilor. `~` este expandat de shell, `$HOME` este o variabilă de mediu. În scripturi, `$HOME` este preferat pentru claritate.

**Q: De ce `rm -rf /` nu funcționează direct?**
> A: Majoritatea sistemelor moderne au protecție. Trebuie `--no-preserve-root`. NU ÎNCERCA NICIODATĂ!

**Q: Cum văd fișierele ascunse?**
> A: `ls -a` sau `ls -la`. Fișierele ascunse încep cu `.`

**Q: Ce face `cd -`?**
> A: Revine la directorul anterior (toggle între ultimele două locații).

**Q: Cum anulez o comandă în execuție?**
> A: `Ctrl+C` (SIGINT). Pentru procese în background: `kill %1` sau `kill PID`.

---
*Material suplimentar pentru cursul de Sisteme de Operare | ASE București - CSIE*
