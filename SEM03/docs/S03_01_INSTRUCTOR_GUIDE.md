# Ghid Instructor: Seminarul 03
## Sisteme de Operare | Utilitare, Scripturi, Permisiuni, Automatizare

> Academia de Studii Economice București - CSIE  
> Durată totală: 100 minute (2 × 50 min + pauză)  
> Tip seminar: Limbaj ca Vehicul (Bash pentru administrare sistem)  
> Nivel: Intermediar (presupune SEM01-04 completate)

---

## Contents

1. [Session Objectives](#-session-objectives)
2. [Special Warnings](#️-special-warnings)
3. [Preparation Before Seminar](#-preparation-before-seminar)
4. [First Part Timeline](#️-detailed-timeline---first-part-50-min)
5. [Break](#-break-10-minutes)
6. [Second Part Timeline](#️-detailed-timeline---second-part-50-min)
7. [Common Troubleshooting](#-common-troubleshooting)
8. [Required Materials](#-required-materials)
9. [Post-Seminar Notes](#-post-seminar-notes)

---

## SESSION OBJECTIVES

At the end of the seminar, students va fi able to:

1. Build complex searches with `find` using multiple criteria and logical operators
2. Process files in bulk using `xargs` correctly (including with spaces in names)
3. scrie professional scripts that accept arguments and options with `getopts`
4. Understand and manage the Unix permissions system (octal and symbolic)
5. Configure special permissions correctly (SUID, SGID, Sticky Bit)
6. Schedule tasks with `cron` following best practices
7. Critically evaluate LLM-generated commands for correctness and security

---

## SPECIAL WARNINGS

### Securitate (CRITIC pentru acest seminar)

> Capcană: Acest seminar implică lucrul cu permisiuni și automatizare. Greșelile pot avea consecințe grave!

| Risc | Prevenire | Ce să spui |
|------|-----------|------------|
| `chmod 777` | NICIODATĂ nu demonstra ca soluție | "777 = oricine poate face orice - inacceptabil în producție" |
| `find -exec rm` | Testează cu `-print` înainte | "Rulăm întâi cu -print să vedem ce găsește" |
| `crontab -r` | Avertizează că șterge TOTUL | "⚠️ crontab -r = remove ALL, nu doar unul!" |
| SUID pe scripturi | Explică că nu funcționează | "SUID e ignorat pentru scripturi - măsură de securitate" |
| `/` în find | Limitează la directoare specifice | "Nu căutăm în /, ci în directoare dedicate" |

### Timing

| Subiect | Timp Alocat | Notă |
|---------|-------------|------|
| find & xargs | 25 min | Poate fi extins dacă studenții au dificultăți |
| Parametri script | 15 min | Template-ul ajută |
| Permisiuni | 20 min | Necesită mai mult timp - concepte multiple |
| Cron | 10 min | Demo + temă pentru acasă |

### Teaching Tips

1. Deliberate errors: Include errors in live coding - students learn from debugging
2. Predictions: Ask "What do you think it will display?" before execution
3. Pair programming: Sprints are done in pairs with switch at halfway
4. Visualisation: Use ASCII diagrams for permissions

---

## PREGĂTIRE ÎNAINTE DE SEMINAR

### 1-2 Days Before

```bash
# Check availability of materials
ls -la ~/seminarii/SEM03/

# Test all demo scripts
cd ~/seminarii/SEM03/scripts/demo/
for script in *.sh; do
    echo "=== Testing $script ==="
    bash -n "$script" && echo "✓ Syntax OK"
done

# Verify you have rights for demonstrațies
sudo -v  # only for preparation, not for seminar
```

### 30 Minutes Before

```bash
# Setup ecran și terminal
# - Font mărit: Ctrl+Shift+Plus (de 2-3 ori)
# - Dark background for visibility
# - Projector resoluție verified

# Deschide taburi în terminal:
# Tab 1: Director de lucru
cd ~/demo_sem3 && clear

# Tab 2: Script-uri demo
cd ~/seminarii/SEM03/scripts/demo/

# Tab 3: Documentație (pentru referință rapidă)
less ~/seminarii/SEM03/docs/S03_02_MAIN_MATERIAL.md
```

### 15 Minutes Before - Technical Checks

```bash
# 1. Create sandbox for permissions exercițius
mkdir -p ~/demo_sem3/permissions_lab
mkdir -p ~/demo_sem3/find_lab
cd ~/demo_sem3

# 2. Create test files
touch test_{1..10}.txt
mkdir -p dir_{1..3}
echo '#!/bin/bash' > script_test.sh
echo 'echo "Hello"' >> script_test.sh

# 3. Verify that cron is working
systemctl status cron --no-pager | head -5
# Ar trebui să vezi: Active: active (running)

# 4. Verifică locate database (opțional)
locate --version 2>/dev/null || echo "locate nu e instalat"
# If installed and you want a fresh demo:
# sudo updatedb

# 5. Basic find test
find /etc -maxdepth 1 -type f 2>/dev/null | head -5

# 6. Check current permissions
ls -la ~/demo_sem3/
```

### Room-Specific Setup Notes

**Lab 2031 (Calea Dorobanților building):**
- Projector has ~2 second lag after switching windows — pause before typing
- Morning sessions: first row monitors face windows, students squint after 10:00
- Power strips on the left wall (rows 3-4) cut out randomly — seat struggling students elsewhere
- AC remote is in the top drawer of the instructor desk (usually set too cold)

**Lab 1107 (Main building, Piața Romană):**
- Better projector, but no AC — summer sessions are brutal, keep water visible
- PCs are newer but still have 8GB RAM — Docker demos may lag
- Whiteboard markers are always dry — bring your own

**Lab 2016 (Dorobanți, ground floor):**
- Best room for this seminar — all PCs identical, reliable power
- But: echo problem, speak slower than usual
- bonus: coffee machine around the corner works 70% of the time

### Presentation Screen Setup

```
┌────────────────────────────────────────────────────────────┐
│  Tab 1: Main Terminal                                       │
│  - Font: 18-20pt                                            │
│  - Short prompt: PS1='$ '                                   │
│  - Visible history: set -o history                          │
├────────────────────────────────────────────────────────────┤
│  Tab 2: Browser with HTML presentation                      │
│  - presentations/S03_01_presentation.html                   │
├────────────────────────────────────────────────────────────┤
│  Tab 3: Editor with cheat sheet (for yourself)             │
│  - docs/S03_09_VISUAL_CHEAT_SHEET.md                       │
└────────────────────────────────────────────────────────────┘
```

---

## MID-SESSION CHECKPOINTS

These quick checks help you gauge whether to speed up or slow down. I learned the hard way that "any questions?" gets silence even when half the room is lost.

### Checkpunct 1: After find section (~25 min mark)

**Quick Poll** (90 seconds):
> "Thumbs up if you could scrie a find command with 3 criteria right now, without notes."

| Result | Interpretation | Action |
|--------|----------------|--------|
| >70% up | They're ready | Move to xargs quickly |
| 50-70% up | Normal | One more exemplu, then proceed |
| <50% up | Trouble | Add 5 min revizuire, use simpler exemplu |

**backup mini-EXERCIȚIU** (if needed):
```bash
# "Everyone type this and predict what it finds BEFORE pressing Enter"
find /etc -type f -name "*.conf" -size +1k 2>/dev/null | head -5
```

### Checkpunct 2: After getopts (~55 min mark)

**Pair Check** (3 minutes):
1. Students swap laptops with neighbour
2. Run partner's script with `-h` flag
3. Must see usage message
4. If not → debug together for 2 minutes

This catches the "it works on my machine" students who haven't actually tested the help opțiune.

### Checkpunct 3: Before cron section (~75 min mark)

**Exit Ticket Preview** (2 minutes):
Hand out sticky notes. Everyone writes:
> "The cron expression for 'every Sunday at 3 AM' is: ___________"

Collect silently, sort into correct/incorrect piles while they take a breath. Adjust cron explicație depth based on ratio.

**Correct răspuns:** `0 3 * * 0` (or `0 3 * * 7`)

Common wrong answers I see every semester:
- `3 0 * * 0` — hour/minute reversed (explain field order again)
- `0 3 * * SUN` — abbreviated days don't work everywhere
- `* 3 * * 0` — runs every minute of 3 AM hour

---

## TIMELINE DETALIATĂ - PRIMA PARTE (50 min)

### [0:00-0:05] HOOK: Power of Find

Scop: Captează atenția demonstrând puterea lui `find` într-un one-liner spectaculos.

Script de rulat:
```bash
#!/bin/bash
# S03_01_hook_demo.sh - rulează direct sau copiază comenzile

echo "🔍 Căutare: Cele mai mari 10 fișiere din /usr..."
echo "═══════════════════════════════════════════════════"

find /usr -type f -printf '%s %p\n' 2>/dev/null | \
    sort -rn | head -10 | \
    while read size path; do
        # Convertește în MB
        size_mb=$(echo "scale=2; $size/1048576" | bc)
        printf "📦 %8.2f MB  %s\n" "$size_mb" "$path"
    done

echo ""
echo "✨ Totul într-o singură comandă find + sort + head!"
echo "Azi învățăm să construim astfel de comenzi pas cu pas."
```

Note instructor:
- Arată că find e mult mai puternic decât ls
- Subliniază: "Vom învăța fiecare parte din această comandă"
- Dacă ia prea mult timp (sistemul e lent), oprește cu Ctrl+C și continuă

Tranziție: "Dar mai întâi, să vedem dacă știți deja diferența între find și locate..."

---

### [0:05-0:10] PEER INSTRUCTION Q1: find vs locate

Afișează pe ecran sau citește:

```
╔══════════════════════════════════════════════════════════════════╗
║  🗳️ PEER INSTRUCTION #1                                          ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  Tocmai ai creat un fișier: touch ~/proiect/config.txt           ║
║  Imediat după, rulezi: locate config.txt                         ║
║                                                                  ║
║  Ce se întâmplă?                                                 ║
║                                                                  ║
║  A) Găsește fișierul instant                                     ║
║  B) Nu găsește fișierul (database outdated)                      ║
║  C) Eroare - locate nu caută în home                             ║
║  D) Găsește toate fișierele config.txt din sistem,               ║
║     inclusiv cel nou                                             ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

Protocol PI:
1. [1 min] Studenții votează individual (mâini ridicate sau aplicație)
2. [2 min] Discuție în perechi dacă nu e consens
3. [1 min] Vot final
4. [1 min] Explicație cu demonstrație

Răspuns corect: B

Demonstrație:
```bash
# Create new file
touch ~/test_locate_demo_$(date +%s).txt

# Încearcă locate
locate test_locate_demo
# Output: (nothing or old files)

# Update the database
sudo updatedb

# Now it finds
locate test_locate_demo
# Output: /home/user/test_locate_demo_...

# Cleanup
rm ~/test_locate_demo_*.txt
```

Explicație: "locate folosește o bază de date pre-indexată care se actualizează periodic (de regulă noaptea). find caută în timp real dar e mai lent pentru căutări mari."

---

### [0:10-0:25] LIVE CODING: find și xargs (15 min)

STRUCTURĂ pentru fiecare segment: Anunț → Predicție → Execuție → Explicație

#### Segment 1: find de bază (4 min)

```bash
cd ~/demo_sem3

# Quick setup
mkdir -p src docs tests
touch src/{main,utils,config}.{c,h}
touch docs/{README.md,manual.txt,api.html}
touch tests/test_{1..5}.py

# COMMAND 1: Search by name
echo "📌 PREDICTION: What will this command find?"
# Lasă 3 secunde
find . -name "*.txt"

# EXPLANATION: Searches recursiv for files with .txt extension
```

```bash
# COMMAND 2: Search by type
echo "📌 PREDICTION: And this one?"
find . -type d

# EXPLICAȚIE: -type d = directoare, -type f = fișiere
```

```bash
# COMANDĂ 3: Limitare adâncime
echo "📌 PREDICȚIE: Ce face -maxdepth?"
find . -maxdepth 1 -name "*.txt"

# EXPLICAȚIE: maxdepth 1 = doar în directorul curent, fără recursivitate
```

#### Segment 2: find cu condiții multiple (5 min)

```bash
# AND implicit
echo "📌 Două condiții = AND implicit"
find . -type f -name "*.txt"

# OR explicit
echo "📌 Pentru OR folosim -o cu paranteze"
find . -type f \( -name "*.txt" -o -name "*.md" \)
# Trap: Spaces around parentheses!

# NOT
echo "📌 Negarea cu !"
find . -type f ! -name "*.txt"
```

**Eroare deliberată pentru învățare:**
```bash
# WRONG (without parentheses)
find . -type f -name "*.txt" -o -name "*.md"
# Găsește *.txt files SAU orice *.md (inclusiv directoare!)

# CORECT
find . -type f \( -name "*.txt" -o -name "*.md" \)
```

#### Segment 3: find cu acțiuni (4 min)

```bash
# -exec cu \; (per fișier)
echo "📌 -exec execută comanda pentru FIECARE fișier"
find . -name "*.txt" -exec echo "Găsit: {}" \;

# PREDICTION: "What does \; do?"
# ANSWER: Marks the end of the -exec command, executăs separately for each
```

```bash
# -exec cu + (batch)
echo "📌 Cu + trimite toate fișierele o singură dată"
find . -name "*.txt" -exec echo {} +

# Diferența: \; = mai multe procese, + = un singur proces (mai eficient)
```

#### Segment 4: xargs (5 min)

```bash
# Why xargs?
echo "📌 xargs transforms stdin into arguments"
find . -name "*.txt" | xargs wc -l

# DELIBERATE ERROR: files with spaces
touch "file with spaces.txt"
find . -name "*.txt" | xargs rm
# ERROR! "file" and "with" and "spaces.txt" treated separately
```

```bash
# SOLUȚIA: -print0 și -0
echo "📌 Soluția pentru spații: delimitator null"
find . -name "*.txt" -print0 | xargs -0 ls -la

# Alternativ: xargs -I pentru placeholder
find . -name "*.txt" | xargs -I{} echo "Procesez: {}"
```

Cleanup:
```bash
rm -f "fisier cu spatii.txt"
```

---

### [0:25-0:30] PARSONS PROBLEM #1: Construiește comanda find

Afișează pe ecran:

```
╔══════════════════════════════════════════════════════════════════╗
║  🧩 PARSONS PROBLEM: Construiește comanda find                    ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  CERINȚĂ: Găsește toate fișierele .log mai mari de 1MB           ║
║  modificate în ultimele 7 zile și șterge-le (cu confirmare)      ║
║                                                                  ║
║  LINII AMESTECATE (pune-le în ordine):                          ║
║  ─────────────────────────────────────────────────────────────   ║
║     -type f                                                      ║
║     -mtime -7                                                    ║
║     find /var/log                                                ║

*(`find` combinat cu `-exec` e extrem de util. Odată ce-l stăpânești, nu mai poți fără el.)*

║     -name "*.log"                                                ║
║     -exec rm -i {} \;                                            ║
║     -size +1M                                                    ║
║     -maxdepth 3         ← DISTRACTOR (util dar nu cerut)        ║
║  ─────────────────────────────────────────────────────────────   ║
║                                                                  ║
║  Timp: 3 minute | Lucrați în perechi                            ║
╚══════════════════════════════════════════════════════════════════╝
```

Soluție corectă:
```bash
find /var/log -type f -name "*.log" -size +1M -mtime -7 -exec rm -i {} \;
```

Soluție acceptabilă (ordine diferită a criteriilor):
```bash
find /var/log -name "*.log" -type f -mtime -7 -size +1M -exec rm -i {} \;
```

Discuție: "Ordinea criteriilor nu contează pentru rezultat, dar pune cele mai selective primele pentru performanță"

---

### [0:30-0:45] SPRINT #1: Find Master (15 min)

Afișează instrucțiunile:

```
╔══════════════════════════════════════════════════════════════════╗
║  🏃 SPRINT #1: Find Master (15 min)                              ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  PAIR PROGRAMMING! Switch la minutul 7!                          ║
║                                                                  ║
║  SETUP (rulează prima dată):                                     ║
║  mkdir -p ~/find_lab/{src,docs,tests,build}                      ║
║  touch ~/find_lab/src/{main,utils,config}.{c,h}                  ║
║  touch ~/find_lab/docs/{README.md,manual.txt,api.html}           ║
║  touch ~/find_lab/tests/test_{1..5}.py                           ║
║  dd if=/dev/zero of=~/find_lab/build/big.bin bs=1M count=5       ║
║                                                                  ║
║  TASK-URI:                                                       ║
║  1. Găsește toate fișierele .c                                   ║
║  2. Găsește toate fișierele mai mari de 1MB                      ║
║  3. Găsește toate fișierele modificate în ultima oră             ║
║  4. Găsește toate fișierele și afișează permisiunile lor         ║
║  5. BONUS: Arhivează toate fișierele .py într-un tar             ║
║                                                                  ║
║  VERIFICARE: Arată output-ul pentru fiecare task                 ║
╚══════════════════════════════════════════════════════════════════╝
```

Soluții (pentru instructor):
```bash
# 1
find ~/find_lab -name "*.c"

# 2
find ~/find_lab -size +1M

# 3
find ~/find_lab -mmin -60

# 4
find ~/find_lab -type f -exec ls -l {} \;
# or
find ~/find_lab -type f -printf "%m %p\n"

# 5 BONUS
find ~/find_lab -name "*.py" -exec tar -cvf tests.tar {} +
# or
find ~/find_lab -name "*.py" | xargs tar -cvf tests.tar
```

Circulate through the class and help pairs having difficulties.

---

### [0:45-0:50] PEER INSTRUCTION Q2: $@ vs $*

```
╔══════════════════════════════════════════════════════════════════╗
║  🗳️ PEER INSTRUCTION #2                                          ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  Dat script-ul:                                                  ║
║  #!/bin/bash                                                     ║
║  for arg in "$@"; do echo "[$arg]"; done                         ║
║  echo "---"                                                      ║
║  for arg in "$*"; do echo "[$arg]"; done                         ║
║                                                                  ║
║  Rulare: ./script.sh "hello world" test                          ║
║                                                                  ║
║  Ce afișează?                                                    ║
║                                                                  ║
║  A) [hello world] [test] --- [hello world test]                  ║
║  B) [hello] [world] [test] --- [hello] [world] [test]            ║
║  C) [hello world] [test] --- [hello world] [test]                ║
║  D) [hello world test] --- [hello world] [test]                  ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

Răspuns corect: A

Demonstrație live:
```bash
cat << 'EOF' > /tmp/test_args.sh
#!/bin/bash
echo '=== Cu $@ ==='
for arg in "$@"; do echo "[$arg]"; done
echo "---"
echo '=== Cu $* ==='
for arg in "$*"; do echo "[$arg]"; done
EOF

chmod +x /tmp/test_args.sh
/tmp/test_args.sh "hello world" test
```

Explicație: "$@" păstrează separarea argumentelor, "$*" le unește într-un singur string cu spații.

---

## PAUZĂ 10 MINUTE

Pe ecran în timpul pauzei - afișează cron cheat sheet:

```
╔══════════════════════════════════════════════════════════════════╗
║  ⏰ CRON CHEAT SHEET - Preview pentru Partea 2                   ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  ┌───────────── minut (0-59)                                     ║
║  │ ┌───────────── oră (0-23)                                     ║
║  │ │ ┌───────────── zi din lună (1-31)                           ║
║  │ │ │ ┌───────────── lună (1-12)                                ║
║  │ │ │ │ ┌───────────── zi din săptămână (0-7, 0,7=Dum)          ║
║  │ │ │ │ │                                                       ║
║  * * * * * comandă                                               ║
║                                                                  ║
║  EXEMPLE:                                                        ║
║  */5 * * * *     = la fiecare 5 minute                          ║
║  0 3 * * *       = zilnic la 3:00 AM                            ║
║  0 9 * * 1-5     = L-V la 9:00 AM                               ║
║  0 0 1 * *       = prima zi din lună la miezul nopții           ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

---

## TIMELINE DETALIATĂ - A DOUA PARTE (50 min)

### [0:00-0:05] REACTIVARE: Quiz Rapid Permisiuni

Întrebări rapide (mâini ridicate):

```
📌 ÎNTREBAREA 1:
Ce înseamnă permisiunea "x" pe un DIRECTOR?
   a) Pot executa fișierele din el
   b) Pot accesa (cd) directorul  ← CORECT
   c) Pot lista fișierele

📌 ÎNTREBAREA 2:
Ce face umask 077?
   a) Fișierele noi vor avea permisiunile 077
   b) Fișierele noi vor avea 600 (rw-------)  ← CORECT
   c) Fișierele noi vor avea 777

📌 ÎNTREBAREA 3:
Cine poate șterge un fișier?
   a) Cel cu permisiune w pe fișier
   b) Cel cu permisiune w pe DIRECTOR  ← CORECT
   c) Doar owner-ul fișierului
```

După fiecare întrebare, explică pe scurt dacă sunt confuzii.

---

### [0:05-0:20] LIVE CODING: Permisiuni (15 min)

#### Segment 1: Vizualizare și chmod octal (5 min)

```bash
cd ~/demo_sem3/permissions_lab

# Create test files
touch public.txt private.txt
echo '#!/bin/bash' > script.sh
echo 'echo "Hello from script"' >> script.sh

# Visualisation
ls -la

# PREDICTION: "What permissions does a newly creeazăd file have?"
# Default: 644 (rw-r--r--) cu umask 022
```

```bash
# octal chmod - visual explicație
echo "📌 chmod OCTAL: 3 digits for proprietar-grup-alții"
echo "   r=4, w=2, x=1"
echo "   rwx = 4+2+1 = 7"
echo "   rw- = 4+2+0 = 6"
echo "   r-x = 4+0+1 = 5"

chmod 755 script.sh    # rwxr-xr-x
ls -l script.sh

chmod 600 private.txt  # rw-------
ls -l private.txt
```

```bash
# PREDICȚIE: "Pot rula ./script.sh acum?"
./script.sh
# Yes! Has x for proprietar

# But what happens without x?
chmod 644 script.sh
./script.sh
# Permission denied!

chmod 755 script.sh  # restaurare
```

#### Segment 2: chmod simbolic (4 min)

```bash
# chmod simbolic - mai descriptiv
echo "📌 chmod SIMBOLIC: u/g/o/a și +/-/="

touch test_simbolic.txt
ls -l test_simbolic.txt  # rw-r--r--

chmod u+x test_simbolic.txt   # +execute pentru owner
ls -l test_simbolic.txt       # rwxr--r--

chmod g-r test_simbolic.txt   # -read pentru group
ls -l test_simbolic.txt       # rwx---r--

chmod o=--- test_simbolic.txt # others = nimic
ls -l test_simbolic.txt       # rwx------

chmod a+r test_simbolic.txt   # all +read
ls -l test_simbolic.txt       # rwxr--r--
```

#### Segment 3: umask (4 min)

```bash
# Check current umask
umask
# Probabil 022

# PREDICTION: "With umask 022, what permissions will a new file have?"
touch test_umask.txt
ls -l test_umask.txt
# 644 (666 - 022 = 644)

# Change umask for private files
umask 077
touch very_private.txt
ls -l very_private.txt
# 600 (666 - 077 = 600)

# Restaurează
umask 022
```

#### Segment 4: Permisiuni speciale (3 min)

```bash
# SGID on directory - very useful for shared projects
mkdir shared_project
chmod g+s shared_project
ls -ld shared_project
# drwxr-sr-x - observă 's'

# EXPLANATION: New files in this directory will inherit the grup
```

```bash
# Sticky bit - ca în /tmp
ls -ld /tmp
# drwxrwxrwt - observă 't'

# EXPLANATION: In /tmp, you can only șterge YOUR files,
# chiar dacă directorul e world-writable
```

#### Segment 5: EROARE DELIBERATĂ (2 min)

```bash
# WHAT SHOULD NEVER BE DONE:
# chmod -R 777 / # DEZASTRU!

# CORECT: Diferențiază fișiere de directoare
echo "📌 Pattern corect pentru chmod recursiv:"
# find ~/demo -type f -exec chmod 644 {} \;
# find ~/demo -type d -exec chmod 755 {} \;

# Sau cu X (execute doar pentru directoare)
# chmod -R u=rwX,g=rX,o=rX ~/demo
```

---

### [0:20-0:25] PEER INSTRUCTION Q3: SUID

```
╔══════════════════════════════════════════════════════════════════╗
║  🗳️ PEER INSTRUCTION #3                                          ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  Fișierul /usr/bin/passwd are permisiunile: -rwsr-xr-x           ║
║                                                                  ║
║  Ce înseamnă 's' în poziția owner execute?                       ║
║                                                                  ║
║  A) Fișierul este un symlink                                     ║
║  B) Fișierul rulează cu permisiunile owner-ului (root)  ← CORECT ║
║  C) Fișierul este sticky (nu poate fi șters)                     ║
║  D) Fișierul este shared între useri                             ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

Demonstrație:
```bash
ls -l /usr/bin/passwd
# -rwsr-xr-x 1 root root ... /usr/bin/passwd

# When you run passwd, the process temporarily has root permissions
# Astfel poate modifica /etc/shadow (care e owned de root)

ls -l /etc/shadow
# -rw-r----- 1 root shadow ...
```

---

### [0:25-0:40] SPRINT #2: Script Profesional (15 min)

```
╔══════════════════════════════════════════════════════════════════╗
║  🏃 SPRINT #2: Script cu Opțiuni (15 min)                        ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  PAIR PROGRAMMING! Switch la minutul 7!                          ║
║                                                                  ║
║  CERINȚĂ: Creează un script "fileinfo.sh" care:                  ║
║                                                                  ║
║  1. Acceptă opțiunile:                                           ║
║     -h / --help     : Afișează ajutor                           ║
║     -v / --verbose  : Mod detaliat                              ║
║     -s / --size     : Afișează și dimensiunea                   ║
║                                                                  ║
║  2. Acceptă unul sau mai multe fișiere ca argumente              ║
║                                                                  ║
║  3. Pentru fiecare fișier, afișează:                            ║
║     - Numele                                                     ║
║     - Tipul (fișier/director/link)                              ║
║     - Permisiunile                                               ║
║     - (cu -s) Dimensiunea                                        ║
║                                                                  ║
║  EXEMPLU UTILIZARE:                                              ║
║  ./fileinfo.sh -v -s file1.txt file2.txt                        ║
║                                                                  ║
║  TEMPLATE pe ecranul 2 (sau în docs/S03_05_LIVE_CODING.md)       ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

Template de oferit:
```bash
#!/bin/bash
# fileinfo.sh - afișează informații despre fișiere

VERBOSE=false
SHOW_SIZE=false

usage() {
    echo "Utilizare: $0 [-h] [-v] [-s] file..."
    echo "  -h, --help     Afișează acest ajutor"
    echo "  -v, --verbose  Mod detaliat"
    echo "  -s, --size     Afișează dimensiunea"
    exit 1
}

# TODO: Implementează parsarea opțiunilor cu getopts sau while/case
# TODO: Process remaining files

# Check: at least one file
if [ $# -eq 0 ]; then
    usage
fi

for file in "$@"; do
    # TODO: Display information
    echo "Processing: $file"
done
```

Complete solution (for instructor):
```bash
#!/bin/bash
verbose=false
SHOW_SIZE=false

usage() {
    cat << EOF
Usage: $(basename "$0") [options] file...

Options:
  -h, --help     Display this help
  -v, --verbose  Detailed mode
  -s, --size     Display size
EOF
    exit 1
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help) usage ;;
        -v|--verbose) verbose=true; shift ;;
        -s|--size) SHOW_SIZE=true; shift ;;
        --) shift; break ;;
        -*) echo "Unknown opțiune: $1"; exit 1 ;;
        *) break ;;
    esac
done

[ $# -eq 0 ] && usage

for file in "$@"; do
    [ ! -e "$file" ] && echo "Does not exist: $file" && continue
    
    type="file"
    [ -d "$file" ] && type="directory"
    [ -L "$file" ] && type="symlink"
    
    perm=$(stat -c "%A" "$file")
    
    output="$file: $type, $perm"
    $SHOW_SIZE && output+=", $(stat -c %s "$file") bytes"
    
    echo "$output"
    $verbose && ls -la "$file"
done
```

---

### [0:40-0:48] LLM + CRON DEMO (8 min)

```
╔══════════════════════════════════════════════════════════════════╗
║  🤖 DEMO: Cron + LLM Evaluation (8 min)                          ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  1. [2 min] INSTRUCTOR demonstrează un cron job simplu           ║
║                                                                  ║
║  2. [3 min] STUDENȚI: Cereți unui LLM să genereze un cron job    ║
║     pentru "backup zilnic la 3 AM cu logging"                    ║
║                                                                  ║
║  3. [3 min] EVALUAȚI răspunsul LLM:                             ║
║     - E corect sintactic?                                        ║
║     - Include logging?                                           ║
║     - Are căi absolute?                                          ║
║     - Gestionează erori?                                         ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

Demonstrație instructor:
```bash
# Editează crontab
crontab -e
# Add:
# * * * * * echo "Test $(date)" >> /tmp/cron_test.log

# Verifică
crontab -l

# Monitorizează
tail -f /tmp/cron_test.log
# Așteaptă ~1 minut să vezi output

# Delete after demo
crontab -e
# Remove the test line
```

Checklist for LLM evaluation:
- [ ] Correct cron syntax (5 fields)
- [ ] Absolute paths for script and log
- [ ] Output redirection: `>> log 2>&1`
- [ ] PATH variables set or complete paths
- [ ] (Bonus) Lock file to prevent simultaneous executions

---

### [0:48-0:50] REFLECTION

```
╔══════════════════════════════════════════════════════════════════╗
║  🧠 REFLECTION (2 minute)                                        ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  Răspundeți pe foaie sau mental:                                 ║
║                                                                  ║
║  1. Ce concept din azi vei folosi IMEDIAT în proiectele tale?    ║
║                                                                  ║
║  2. Ce ți se pare cel mai PERICULOS din ce am învățat azi?       ║
║     (și de ce e important să fim atenți)                         ║
║                                                                  ║
║  3. UN lucru pe care vrei să-l exersezi acasă:                   ║
║     _______________________________________________              ║
║                                                                  ║
║  📝 TEMĂ: Completați S03_01_HOMEWORK.md până la seminarul următor    ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

---

## TROUBLESHOOTING COMUN

| Problemă | Simptom | Soluție Rapidă |
|----------|---------|----------------|
| Permission denied la script | `bash: ./script.sh: Permission denied` | `chmod +x script.sh` |
| find: permission denied | Multe erori pe /proc, /sys | Adaugă `2>/dev/null` |
| getopts nu parsează --help | Ignoră opțiunile lungi | getopts e doar pentru opțiuni scurte, folosește `case` |
| Cron job nu rulează | Nimic în log | Verifică căi absolute, PATH, permisiuni, `systemctl status cron` |
| umask nu persistă | Revine după logout | Adaugă în `~/.bashrc` |
| SUID nu funcționează | Script nu rulează ca root | SUID e ignorat pentru scripturi interpretate |
| xargs: argument too long | Eroare cu multe fișiere | Folosește `xargs -n 100` |
| locate nu găsește fișiere noi | Fișier creat recent absent | Rulează `sudo updatedb` |

---

## REQUIRED MATERIALS

- [ ] Laptop with Ubuntu 24.04 or WSL
- [ ] Working projector
- [ ] Demo scripts prepared in `scripts/demo/`
- [ ] HTML presentation in `prezentari/`
- [ ] Printed cheat sheet (optional, for reference)

---

## NOTE POST-SEMINAR

După fiecare seminar, notează:

1. Ce a funcționat bine?
   - ...

2. Ce ar trebui ajustat pentru data viitoare?
   - ...

3. Întrebări frecvente de la studenți:
   - ...

4. Concepte care au necesitat explicații suplimentare:
   - ...

5. Timing real vs planificat:
   - Hook: ___ min (plan: 5)
   - Live Coding 1: ___ min (plan: 15)
   - Sprint 1: ___ min (plan: 15)
   - Live Coding 2: ___ min (plan: 15)
   - Sprint 2: ___ min (plan: 15)

---

*Ghid creat pentru Seminar 03 SO | ASE București - CSIE*  
*Actualizat: Ianuarie 2025*

## 📝 MY NOTES FROM THE CLASSROOM (from real experience)

### Minute 15-20: Watch the Group Energy
This is usually when attention drops. I have two strategies that work:
1. **Quick "pop quiz"**: "Who can tell me what -type f does?" — pick someone directly
2. **Abrupt switch to live demo** if I see heads in phones

### When the Inevitable "but on Mac?" Question Comes Up
- **Short răspuns**: "Install GNU coreutils with brew"
- **Long răspuns**: We do not give it. macOS is out of scope and we lose precious time
- **If they insist**: "We test on Ubuntu and that is the reference environment for this course"

### My Mistake from 2023
I forgot to demonstrate that `locate` does not find new files. A student remained 
convinced it was a bug in Ubuntu and sent me an email about it. Since then I ALWAYS 
do the demo in strict order:
1. `touch newfile.txt`
2. `locate newfile.txt` (does not find it - "aha!" moment)
3. "Why?" → explain database → `sudo updatedb` → now it finds it

### Frequently Asked Questions and Prepared Answers

> **"Why does SUID not work on my bash script?"**

Short răspuns: Security. Linux ignores SUID on interpreted scripts.
Technical reason: Between exec() and interpretation an attacker could modifică scriptul.
Quick demo: Show that `/usr/bin/passwd` has SUID and is a BINARY not a script.

> **"Can I put spaces in crontab?"**

Yes but not where you think. Fields are separated by whitespace but comanda 
can have spaces. Demonstrate:
```
* * * * * echo "works with spaces" >> /tmp/test.log
```

> **"Is chmod 777 not simpler?"**

[Dramatic pause] "Let us see what happens if you do that on a web server..."
→ Quick demo with world-writable directory → "see why not?"

### What I Have Learnt About Timing

| Activity | Initial Plan | Reality | Adjustment |
|----------|--------------|---------|------------|
| Hook find | 5 min | 5-7 min | OK but prepare Ctrl+C |
| PI find vs locate | 5 min | 7-8 min | Discussions take longer |
| Live coding find | 15 min | 18-20 min | Reduce to essentials if running late |
| Sprint #1 | 15 min | 12-15 min | Some finish quickly, alții... |
| Permissions | 20 min | 25 min | Most unpredictable |
| Cron + LLM | 10 min | 8-10 min | Works well |

**Conclusion**: Plan 90 min of content for a 100 min slot. The rest is buffer.

### Signs That I Need to Change Pace

🚨 **Speed up if:**
- Everyone answers the PI correctly (they are more prepared than I thought)
- They finish the sprint in 5 minutes (exercises are too easy)
- Nobody asks questions (either they understand perfectly or they are completely lost)

🛑 **Slow down if:**
- More than 30% răspuns the PI incorrectly
- Confused expressions during live coding
- Same errors from multiple students in the sprint

### Specific Setup for Dorobanti Lab

- PCs have Ubuntu 24.04 since autumn 2024 (finally!)
- Portainer works on 9000 but sometimes you need to refresh
- Cron service does NOT start automatically — check with `systemctl status cron`
- If `locate` does not work: `sudo apt install mlocate && sudo updatedb`

### Backup Plan If Everything Goes Wrong

If you lose a lot of time at the beginning cut directly:
1. Skip PI #2 ($@ vs $*)
2. Reduce sprint #1 to 8 minutes
3. Cron becomes "temă preview" (2 minute demo, rest at home)
4. Reflection becomes "one sentence each" verbal

---

## 📚 QUICK REFERENCES FOR MYSELF

### Commands I Always Forget

```bash
# How pentru a afișa permissions in octal
stat -c "%a %n" file

# How pentru a verifica what a job cron does WITHOUT running it
EDITOR=cat crontab -e

# How pentru a găsi files modified in the last hour
find . -mmin -60 -type f

# Escape for parentheses in find
find . \( -name "*.txt" -o -name "*.md" \)
#      ^-- space after backslash-parenthesis!
```

### Magic Numbers for Permissions

| Octal | Symbolic | Description |
|-------|----------|-------------|
| 755 | rwxr-xr-x | Executable script |
| 644 | rw-r--r-- | Normal text file |
| 700 | rwx------ | Private script |
| 600 | rw------- | SSH key, private config |
| 777 | rwxrwxrwx | **NEVER IN PRODUCTION** |

### Crontab Field Order (always slips my mind)

```
MIN  HOUR  DOM  MON  DOW  COMMAND
 │    │     │    │    │
 │    │     │    │    └─ 0-7 (0,7=Sunday)
 │    │     │    └────── 1-12
 │    │     └─────────── 1-31
 │    └───────────────── 0-23
 └────────────────────── 0-59
```

---

*Guide created for Seminar 3 OS | Bucharest UES - CSIE*  
*Maintained by ing. dr. Antonio Clim*  
*Updated: January 2025 (v1.3 — added checkpoints, room notes, presentation path fix)*
