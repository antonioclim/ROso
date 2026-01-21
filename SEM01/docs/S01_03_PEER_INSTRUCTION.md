# Peer Instruction - Întrebări pentru Seminarul 1-2
## Sisteme de Operare | Shell Basics & Configuration

Total întrebări: 15  
Timp per întrebare: 3-5 minute  
Format: Vot individual → Discuție perechi → Revot → Explicație

---

## PROTOCOL DE UTILIZARE

```
┌────────────────────────────────────────────────────────────────┐
│  CICLU PEER INSTRUCTION (5 minute per întrebare)              │
├────────────────────────────────────────────────────────────────┤
│  [0:00-0:30]  Citește întrebarea, gândire individuală         │
│  [0:30-1:30]  PRIMUL VOT (carduri A/B/C/D sau poll digital)   │
│  [1:30-3:30]  Discuție în perechi ("Convinge-ți vecinul!")    │
│  [3:30-4:00]  AL DOILEA VOT                                   │
│  [4:00-5:00]  Explicație instructor + demonstrație live       │
└────────────────────────────────────────────────────────────────┘
```

Interpretare rezultate primul vot:
- < 30% corect: Explică tu conceptul, nu trece la discuție
- 30-70% corect: IDEAL pentru peer instruction - continuă
- > 70% corect: Întrebarea e prea ușoară, treci rapid

---

## ÎNTREBĂRI SHELL & SISTEM

### PI-01: Rolul Shell-ului
Nivel: Fundamental | Durată: 4 min | Target: ~50% corect

```
Când tastezi "ls -la" în terminal și apeși Enter, 
care componentă INTERPRETEAZĂ PRIMA această comandă?

A) Kernel-ul Linux - controlează hardware-ul
B) Shell-ul Bash - interpretează comenzile
C) Procesorul (CPU) - execută instrucțiunile
D) Terminal - afișează textul
```

Răspuns corect: B

| Distractor | Misconceptie vizată |
|------------|---------------------|
| A | Confuzie între interpretare și execuție finală |
| C | Confuzie hardware/software - CPU execută, nu interpretează comenzi text |
| D | Confuzie terminal/shell - terminalul e doar interfața vizuală |

După discuție, demonstrează:
```bash
echo $SHELL          # Arată ce shell folosești
ps -p $$             # Arată procesul shell
cat /etc/shells      # Lista shell-urilor disponibile
```

---

### PI-02: Tipuri de Căi
Nivel: Fundamental | Durată: 3 min | Target: ~60% corect

```
Care dintre următoarele este o CALE ABSOLUTĂ?

A) ../Documents
B) ~/Downloads
C) /home/student/file.txt
D) ./script.sh
```

Răspuns corect: C

| Distractor | Misconceptie vizată |
|------------|---------------------|
| A | `..` e relativă la directorul curent |
| B | `~` pare absolută dar e expansiune shell (tot absolută devine, dar nu e "pură") |
| D | `./` e explicit relativă |

Observație: B poate fi discutabilă - acceptă și explică că ~ se expandează la cale absolută, dar tehnic e un shortcut.

---

### PI-03: Directorul Rădăcină
Nivel: Fundamental | Durată: 3 min | Target: ~65% corect

```
Rulezi următoarele comenzi. Care e output-ul final?

cd /
cd ..
pwd

A) / (rădăcina)
B) Eroare - nu poți merge mai sus de rădăcină
C) (nimic - comandă invalidă)
D) /home
```

Răspuns corect: A

Explicație: În Linux, `/..` = `/`. Nu poți "ieși" din rădăcină, rămâi în loc.

```bash
# Demonstrație
cd /
ls -la | grep "\..$"    # .. există și pointează tot la /
cd ..
pwd                      # Tot /
```

---

## ÎNTREBĂRI QUOTING & VARIABILE

### PI-04: Single vs Double Quotes
Nivel: Intermediar | Durată: 5 min | Target: ~45% corect

```
NAME="Student"
echo 'Hello $NAME'

Ce va afișa comanda echo?

A) Hello Student
B) Hello $NAME
C) Hello (doar atât)
D) Eroare - variabila nu există în single quotes
```

Răspuns corect: B

| Distractor | Misconceptie vizată |
|------------|---------------------|
| A | Crede că variabilele se expandează și în single quotes |
| C | Confuzie cu comportamentul altor limbaje |
| D | Crede că e eroare în loc de comportament literal |

Demonstrație comparativă:
```bash
NAME="Student"
echo 'Hello $NAME'    # Hello $NAME
echo "Hello $NAME"    # Hello Student
echo Hello $NAME      # Hello Student
```

---

### PI-05: Escape Character
Nivel: Intermediar | Durată: 4 min | Target: ~50% corect

```
Ce afișează această comandă?

echo "Costul este \$100"

A) Costul este \$100
B) Costul este $100
C) Costul este 100
D) Eroare - $ invalid
```

Răspuns corect: B

Explicație: `\$` în double quotes = caracter literal `$`, nu expansiune.

---

### PI-06: Variabile - Asignare Greșită
Nivel: Intermediar | Durată: 4 min | Target: ~40% corect

```
Ce se întâmplă când rulezi?

VAR = "valoare"
echo $VAR

A) Afișează "valoare"
B) Afișează "" (șir gol)
C) Eroare: VAR: command not found
D) Eroare: syntax error
```

Răspuns corect: C

Explicație: Spațiul face ca bash să interpreteze `VAR` ca o comandă!

```bash
# Greșit
VAR = "valoare"    # bash: VAR: command not found

# Corect
VAR="valoare"      # Fără spații!
echo $VAR
```

---

### PI-07: Locale vs Export
Nivel: Avansat | Durată: 5 min | Target: ~35% corect

```
LOCAL="local"
export EXPORTED="exported"
bash -c 'echo "[$LOCAL] [$EXPORTED]"'

Ce va afișa?

A) [local] [exported]
B) [] [exported]
C) [local] []
D) [] []
```

Răspuns corect: B

| Distractor | Misconceptie vizată |
|------------|---------------------|
| A | Crede că toate variabilele sunt vizibile în subshell |
| C | Confuzie inversă despre export |
| D | Crede că subshell-ul nu moștenește nimic |

Demonstrație:
```bash
LOCAL="local"
export EXPORTED="exported"
bash -c 'echo "LOCAL=$LOCAL, EXPORTED=$EXPORTED"'
# Output: LOCAL=, EXPORTED=exported
```

---

### PI-08: Exit Code
Nivel: Intermediar | Durată: 4 min | Target: ~55% corect

```
ls /nonexistent 2>/dev/null
echo $?
ls /home 2>/dev/null
echo $?

Ce afișează cele două echo-uri (în ordine)?

A) 0, 0
B) 1, 0
C) 2, 0
D) 0, 1
```

Răspuns corect: C (sau B, depinde de sistem - acceptă ambele)

Explicație:
- Prima comandă: director inexistent → exit code non-zero (2 pentru ls)
- A doua comandă: succes → exit code 0
- `2>/dev/null` doar ascunde mesajele de eroare, nu schimbă exit code

---

## ÎNTREBĂRI GLOBBING & FIȘIERE

### PI-09: Wildcard *
Nivel: Fundamental | Durată: 4 min | Target: ~60% corect

```
În directorul curent ai: file1.txt, file2.txt, file10.txt, notes.txt

Ce fișiere listează comanda: ls file?.txt

A) file1.txt file2.txt file10.txt
B) file1.txt file2.txt
C) file1.txt file2.txt notes.txt
D) Toate cele patru fișiere
```

Răspuns corect: B

Explicație: `?` potrivește EXACT UN caracter, nu mai multe.
- `file1.txt` ✓ (? = 1)
- `file2.txt` ✓ (? = 2)
- `file10.txt` ✗ (10 = două caractere!)
- `notes.txt` ✗ (nu începe cu "file")

---

### PI-10: Fișiere Ascunse
Nivel: Intermediar | Durată: 4 min | Target: ~45% corect

```
Ai aceste fișiere: file.txt, .hidden, .bashrc, data.csv

Ce listează: ls *

A) file.txt, .hidden, .bashrc, data.csv
B) file.txt, data.csv
C) file.txt, .hidden, data.csv
D) Toate fișierele care nu încep cu punct
```

Răspuns corect: B (și D e corect conceptual)

Explicație: Glob `*` NU include fișierele care încep cu `.` (ascunse)!

```bash
# Trebuie explicit:
ls .*           # Doar ascunse
ls * .*         # Toate
ls -a           # Toate (mai simplu)
```

---

### PI-11: rm -r
Nivel: Intermediar | Durată: 3 min | Target: ~70% corect

```
Ai structura:
project/
├── src/
│   └── main.c
└── README.md

Rulezi: rm project

Ce se întâmplă?

A) Șterge tot directorul project cu conținut
B) Eroare: project is a directory
C) Șterge doar fișierele, lasă directoarele
D) Mută project în Trash/Coș de gunoi
```

Răspuns corect: B

Explicație: `rm` fără `-r` nu șterge directoare!

```bash
rm project           # rm: cannot remove 'project': Is a directory
rm -r project        # Șterge recursiv (ATENȚIE!)
rm -rf project       # Forțat, fără confirmare (FOARTE PERICULOS!)
```

---

## ÎNTREBĂRI CONFIGURARE

### PI-12: .bashrc Timing
Nivel: Intermediar | Durată: 4 min | Target: ~40% corect

```
Adaugi în ~/.bashrc:
alias ll='ls -la'

Apoi rulezi imediat în ACELAȘI terminal:
ll

Ce se întâmplă?

A) Funcționează - afișează lista detaliată
B) Eroare: ll: command not found
C) Afișează "ls -la" ca text
D) Deschide editorul pentru a configura alias-ul
```

Răspuns corect: B

Explicație: `.bashrc` se încarcă doar la deschiderea unui shell nou!

```bash
# Soluții:
source ~/.bashrc    # Reîncarcă în shell-ul curent
. ~/.bashrc         # Echivalent
# SAU deschide terminal nou
```

---

### PI-13: PATH
Nivel: Avansat | Durată: 5 min | Target: ~35% corect

```
PATH="/custom/bin"
echo $PATH
ls

Ce se întâmplă la comanda ls?

A) Listează directorul curent normal
B) Eroare: ls: command not found
C) Caută ls în /custom/bin
D) Folosește ls din locația memorată (cache)
```

Răspuns corect: B

Explicație: Am ÎNLOCUIT PATH-ul complet! `ls` nu mai e găsit.

```bash
# GREȘIT - înlocuiește tot:
PATH="/custom/bin"

# CORECT - adaugă:
PATH="/custom/bin:$PATH"    # La început (prioritate)
PATH="$PATH:/custom/bin"    # La sfârșit
```

---

### PI-14: PS1 Prompt
Nivel: Intermediar | Durată: 4 min | Target: ~50% corect

```
Setezi: PS1='\u@\h:\w\$ '

Ce reprezintă \w?

A) Numele utilizatorului (whoami)
B) Directorul de lucru curent (working directory)
C) Numele calculatorului (hostname)
D) Ziua săptămânii (weekday)
```

Răspuns corect: B

| Secvență | Semnificație |
|----------|--------------|
| `\u` | Username |
| `\h` | Hostname (scurt) |
| `\w` | Working directory (cale completă) |
| `\W` | Working directory (doar numele) |

---

### PI-15: Command Substitution
Nivel: Avansat | Durată: 5 min | Target: ~40% corect

```
FILES=$(ls)
echo "Am găsit: $FILES"

Ce face $( ) în prima linie?

A) Creează un subshell și salvează output-ul în variabilă
B) Execută ls ca proces background
C) Declară FILES ca array
D) E echivalent cu FILES="ls" (textul literal)
```

Răspuns corect: A

Explicație: `$(comandă)` execută comanda și înlocuiește cu output-ul.

```bash
# Command substitution
FILES=$(ls)         # Execută ls, salvează output
COUNT=$(wc -l < file.txt)   # Numără linii

# Formă veche (evită):
FILES=`ls`          # Backticks - mai greu de citit
```

---

## MATRICE UTILIZARE

| Întrebare | Moment Optim | După ce concept? |
|-----------|--------------|------------------|
| PI-01 | Deschidere | Înainte de orice |
| PI-02 | După navigare | cd, pwd |
| PI-03 | După navigare | cd .. |
| PI-04 | După quoting | echo, variabile |
| PI-05 | După escape | Backslash |
| PI-06 | După variabile | Asignare |
| PI-07 | După export | Subshell |
| PI-08 | După erori | Debugging |
| PI-09 | După globbing | Wildcards |
| PI-10 | După ls -a | Fișiere ascunse |
| PI-11 | După rm | Ștergere |
| PI-12 | După .bashrc | Configurare |
| PI-13 | După PATH | Environment |
| PI-14 | După PS1 | Prompt |
| PI-15 | După $() | Scripting intro |

---

## TRACKING RĂSPUNSURI

Folosește acest tabel pentru a nota distribuțiile:

| PI# | V1-A | V1-B | V1-C | V1-D | V2-A | V2-B | V2-C | V2-D | Notă |
|-----|------|------|------|------|------|------|------|------|------|
| 01  |      |      |      |      |      |      |      |      |      |
| 02  |      |      |      |      |      |      |      |      |      |
| ... |      |      |      |      |      |      |      |      |      |

V1 = Primul vot, V2 = Al doilea vot (după discuție)

---

*Întrebări Peer Instruction | SO Seminarul 1-2 | ASE-CSIE*
