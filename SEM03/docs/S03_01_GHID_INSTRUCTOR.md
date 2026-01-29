# Ghid Instructor: Seminarul 03
## Sisteme de Operare | Utilitare, Scripturi, Permisiuni, Automatizare

> Academia de Studii Economice București - CSIE  
> Durată totală: 100 minute (2 × 50 min + pauză)  
> Tip seminar: Limbaj ca Vehicul (Bash pentru administrare sistem)  
> Nivel: Intermediar (presupune SEM01-04 completate)

---

## Cuprins

1. [Obiective Sesiune](#-obiective-sesiune)
2. [Atenționări Speciale](#️-atenționări-speciale)
3. [Pregătire Înainte de Seminar](#-pregătire-înainte-de-seminar)
4. [Timeline Prima Parte](#️-timeline-detaliată---prima-parte-50-min)
5. [Pauză](#-pauză-10-minute)
6. [Timeline A Doua Parte](#️-timeline-detaliată---a-doua-parte-50-min)
7. [Troubleshooting Comun](#-troubleshooting-comun)
8. [Materiale Necesare](#-materiale-necesare)
9. [Note Post-Seminar](#-note-post-seminar)

---

## OBIECTIVE SESIUNE

La finalul seminarului, studenții vor fi capabili să:

1. Construiască căutări complexe cu `find` folosind multiple criterii și operatori logici
2. Proceseze în masă fișiere folosind `xargs` corect (inclusiv cu spații în nume)
3. Scrie scripturi profesionale care acceptă argumente și opțiuni cu `getopts`
4. Înțeleagă și gestioneze sistemul de permisiuni Unix (octal și simbolic)
5. Configure corect permisiunile speciale (SUID, SGID, Sticky Bit)
6. Programeze task-uri cu `cron` urmând best practices
7. Evalueze critic comenzi generate de LLM pentru corectitudine și securitate

---

## ATENȚIONĂRI SPECIALE

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

### Sfaturi Didactice

1. Erori deliberate: Include erori în live coding - studenții învață din debugging
2. Predicții: Întreabă "Ce credeți că va afișa?" înainte de execuție
3. Pair programming: Sprint-urile se fac în perechi cu switch la jumătate
4. Vizualizare: Folosește diagrame ASCII pentru permisiuni

---

## PREGĂTIRE ÎNAINTE DE SEMINAR

### Cu 1-2 Zile Înainte

```bash
# Verifică disponibilitatea materialelor
ls -la ~/seminarii/SEM03/

# Testează toate scripturile demo
cd ~/seminarii/SEM03/scripts/demo/
for script in *.sh; do
    echo "=== Testing $script ==="
    bash -n "$script" && echo "✓ Syntax OK"
done

# Verifică că ai drepturi pentru demonstrații
sudo -v  # doar pentru pregătire, nu pentru seminar
```

### Cu 30 Minute Înainte

```bash
# Setup ecran și terminal
# - Font mărit: Ctrl+Shift+Plus (de 2-3 ori)
# - Fundal întunecat pentru vizibilitate
# - Rezoluție proiector verificată

# Deschide taburi în terminal:
# Tab 1: Director de lucru
cd ~/demo_sem3 && clear

# Tab 2: Script-uri demo
cd ~/seminarii/SEM03/scripts/demo/

# Tab 3: Documentație (pentru referință rapidă)
less ~/seminarii/SEM03/docs/S03_02_MATERIAL_PRINCIPAL.md
```

### Cu 15 Minute Înainte - Verificări Tehnice

```bash
# 1. Creează sandbox pentru exerciții permisiuni
mkdir -p ~/demo_sem3/permissions_lab
mkdir -p ~/demo_sem3/find_lab
cd ~/demo_sem3

# 2. Creează fișiere de test
touch test_{1..10}.txt
mkdir -p dir_{1..3}
echo '#!/bin/bash' > script_test.sh
echo 'echo "Hello"' >> script_test.sh

# 3. Verifică că cron funcționează
systemctl status cron --no-pager | head -5
# Ar trebui să vezi: Active: active (running)

# 4. Verifică locate database (opțional)
locate --version 2>/dev/null || echo "locate nu e instalat"
# Dacă e instalat și vrei demo fresh:
# sudo updatedb

# 5. Test find de bază
find /etc -maxdepth 1 -type f 2>/dev/null | head -5

# 6. Verifică permisiunile curente
ls -la ~/demo_sem3/
```

### Setup Ecran Prezentare

```
┌────────────────────────────────────────────────────────────┐
│  Tab 1: Terminal Principal                                  │
│  - Font: 18-20pt                                            │
│  - Prompt scurt: PS1='$ '                                   │
│  - History vizibil: set -o history                          │
├────────────────────────────────────────────────────────────┤
│  Tab 2: Browser cu prezentare HTML                          │
│  - prezentari/S03_01_prezentare.html                       │
├────────────────────────────────────────────────────────────┤
│  Tab 3: Editor cu cheat sheet (pentru tine)                │
│  - docs/S03_09_CHEAT_SHEET_VIZUAL.md                       │
└────────────────────────────────────────────────────────────┘
```

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
# Creează fișier nou
touch ~/test_locate_demo_$(date +%s).txt

# Încearcă locate
locate test_locate_demo
# Output: (nimic sau fișiere vechi)

# Actualizează baza de date
sudo updatedb

# Acum găsește
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

# Setup rapid
mkdir -p src docs tests
touch src/{main,utils,config}.{c,h}
touch docs/{README.md,manual.txt,api.html}
touch tests/test_{1..5}.py

# COMANDĂ 1: Căutare după nume
echo "📌 PREDICȚIE: Ce va găsi această comandă?"
# Lasă 3 secunde
find . -name "*.txt"

# EXPLICAȚIE: Caută recursiv fișiere cu extensia .txt
```

```bash
# COMANDĂ 2: Căutare după tip
echo "📌 PREDICȚIE: Dar aceasta?"
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
# Capcană: Spații în jurul parantezelor!

# NOT
echo "📌 Negarea cu !"
find . -type f ! -name "*.txt"
```

**Eroare deliberată pentru învățare:**
```bash
# GREȘIT (fără paranteze)
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

# PREDICȚIE: "Ce face \; ?"
# RĂSPUNS: Marchează sfârșitul comenzii -exec, execută separat pentru fiecare
```

```bash
# -exec cu + (batch)
echo "📌 Cu + trimite toate fișierele o singură dată"
find . -name "*.txt" -exec echo {} +

# Diferența: \; = mai multe procese, + = un singur proces (mai eficient)
```

#### Segment 4: xargs (5 min)

```bash
# De ce xargs?
echo "📌 xargs transformă stdin în argumente"
find . -name "*.txt" | xargs wc -l

# EROARE DELIBERATĂ: fișiere cu spații
touch "fisier cu spatii.txt"
find . -name "*.txt" | xargs rm
# EROARE! "fisier" și "cu" și "spatii.txt" tratate separat
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
# sau
find ~/find_lab -type f -printf "%m %p\n"

# 5 BONUS
find ~/find_lab -name "*.py" -exec tar -cvf tests.tar {} +
# sau
find ~/find_lab -name "*.py" | xargs tar -cvf tests.tar
```

Circulă prin clasă și ajută perechile care au dificultăți.

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

# Creează fișiere de test
touch public.txt private.txt
echo '#!/bin/bash' > script.sh
echo 'echo "Hello from script"' >> script.sh

# Vizualizare
ls -la

# PREDICȚIE: "Ce permisiuni are un fișier nou creat?"
# Default: 644 (rw-r--r--) cu umask 022
```

```bash
# chmod octal - explicație vizuală
echo "📌 chmod OCTAL: 3 cifre pentru owner-group-others"
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
# Da! Are x pentru owner

# Dar ce se întâmplă fără x?
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
# Verifică umask curent
umask
# Probabil 022

# PREDICȚIE: "Cu umask 022, ce permisiuni va avea un fișier nou?"
touch test_umask.txt
ls -l test_umask.txt
# 644 (666 - 022 = 644)

# Schimbă umask pentru fișiere private
umask 077
touch very_private.txt
ls -l very_private.txt
# 600 (666 - 077 = 600)

# Restaurează
umask 022
```

#### Segment 4: Permisiuni speciale (3 min)

```bash
# SGID pe director - foarte util pentru proiecte shared
mkdir shared_project
chmod g+s shared_project
ls -ld shared_project
# drwxr-sr-x - observă 's'

# EXPLICAȚIE: Fișierele noi în acest director vor moșteni grupul
```

```bash
# Sticky bit - ca în /tmp
ls -ld /tmp
# drwxrwxrwt - observă 't'

# EXPLICAȚIE: În /tmp, poți șterge doar fișierele TALE,
# chiar dacă directorul e world-writable
```

#### Segment 5: EROARE DELIBERATĂ (2 min)

```bash
# CE NU TREBUIE FĂCUT NICIODATĂ:
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

# Când rulezi passwd, procesul are temporar permisiunile lui root
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
# TODO: Procesează fișierele rămase

# Verificare: cel puțin un fișier
if [ $# -eq 0 ]; then
    usage
fi

for file in "$@"; do
    # TODO: Afișează informațiile
    echo "Procesez: $file"
done
```

Soluție completă (pentru instructor):
```bash
#!/bin/bash
VERBOSE=false
SHOW_SIZE=false

usage() {
    cat << EOF
Utilizare: $(basename "$0") [opțiuni] file...

Opțiuni:
  -h, --help     Afișează acest ajutor
  -v, --verbose  Mod detaliat
  -s, --size     Afișează dimensiunea
EOF
    exit 1
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help) usage ;;
        -v|--verbose) VERBOSE=true; shift ;;
        -s|--size) SHOW_SIZE=true; shift ;;
        --) shift; break ;;
        -*) echo "Opțiune necunoscută: $1"; exit 1 ;;
        *) break ;;
    esac
done

[ $# -eq 0 ] && usage

for file in "$@"; do
    [ ! -e "$file" ] && echo "Nu există: $file" && continue
    
    type="fișier"
    [ -d "$file" ] && type="director"
    [ -L "$file" ] && type="symlink"
    
    perm=$(stat -c "%A" "$file")
    
    output="$file: $type, $perm"
    $SHOW_SIZE && output+=", $(stat -c %s "$file") bytes"
    
    echo "$output"
    $VERBOSE && ls -la "$file"
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
# Adaugă:
# * * * * * echo "Test $(date)" >> /tmp/cron_test.log

# Verifică
crontab -l

# Monitorizează
tail -f /tmp/cron_test.log
# Așteaptă ~1 minut să vezi output

# Șterge după demo
crontab -e
# Elimină linia de test
```

Checklist pentru evaluare LLM:
- [ ] Sintaxă cron corectă (5 câmpuri)
- [ ] Căi absolute pentru script și log
- [ ] Redirecționare output: `>> log 2>&1`
- [ ] Variabile PATH setate sau căi complete
- [ ] (Bonus) Lock file pentru a preveni execuții simultane

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
║  📝 TEMĂ: Completați S03_01_TEMA.md până la seminarul următor    ║
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

## MATERIALE NECESARE

- [ ] Laptop cu Ubuntu 24.04 sau WSL
- [ ] Proiector funcțional
- [ ] Script-uri demo pregătite în `scripts/demo/`
- [ ] Prezentare HTML în `prezentari/`
- [ ] Cheat sheet printat (opțional, pentru referință)

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

*Ghid creat pentru Seminar 3 SO | ASE București - CSIE*  
*Actualizat: Ianuarie 2025*
