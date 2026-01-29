# Seminar 4: Text Processing - Regex, GREP, SED, AWK

> Sisteme de Operare | Academia de Studii Economice București - CSIE  
> Versiune: 1.0 | Data: Ianuarie 2025  
> Autor: Materiale Educaționale SO

---

## Cuprins

1. [Descriere](#-descriere)
2. [Obiective de Învățare](#-obiective-de-învățare)
3. [De Ce Contează Acest Seminar](#-de-ce-contează-acest-seminar)
4. [Structura Pachetului](#-structura-pachetului)
5. [Ghid de Utilizare](#-ghid-de-utilizare)
6. [Pentru Instructori](#-pentru-instructori)
7. [Pentru Studenți](#-pentru-studenți)
8. [Cerințe Tehnice](#️-cerințe-tehnice)
9. [Instalare și Configurare](#-instalare-și-configurare)
10. [Probleme Frecvente](#-probleme-frecvente)
11. [Resurse Suplimentare](#-resurse-suplimentare)

---

## Descriere

### Contextul Seminarului

Acest seminar reprezintă continuarea directă a SEM05-06 și face parte din seria de procesare avansată a datelor în linia de comandă. Presupune că studenții au deja cunoștințe solide despre:

- Navigare în sistemul de fișiere și variabile de mediu
- Operatori, redirecționare I/O și filtre de bază (cat, head, tail, sort, uniq, wc)
- Comanda `find` și `xargs` pentru procesare batch
- Scripting Bash cu argumente și structuri de control
- Permisiuni și job scheduling cu `cron`

### Ce Introduce Acest Seminar

Seminarul 7-8 introduce "Triada Magică" a procesării de text în Unix/Linux:

| Tool | Rol Principal | Analogie |
|------|---------------|----------|
| **grep** | Căutare și filtrare | "Detectivul" - găsește pattern-uri |
| **sed** | modificare stream | "Chirurgul" - modifică text on-the-fly |
| **awk** | Procesare structurată | "Analistul" - rapoarte și calcule |

În completare, seminarul acoperă:

- Expresii Regulate (Regex): Limbajul universal pentru descrierea pattern-urilor de text
- Editorul nano: Un editor de text simplu și accesibil pentru editare rapidă

### Tranziția Conceptuală

```
SEM01-06                          SEM07-08
═══════════════════              ═══════════════════════════
Comenzi simple        →          Pattern-uri complexe
Filtre individuale    →          Pipeline-uri puternice
echo/cat pentru edit  →          nano pentru editare reală
Procesare manuală     →          Automatizare cu regex
```

---

## Obiective de Învățare

La finalul acestui seminar, studenții vor fi capabili să:

### Nivelul 1: Cunoaștere și Înțelegere
- [ ] Explice diferența între BRE (Basic Regular Expression) și ERE (Extended Regular Expression)
- [ ] Identifice metacaracterele regex și scopul lor
- [ ] Descrie modelul de procesare al grep, sed și awk

### Nivelul 2: Aplicare
- [ ] Construiască expresii regulate pentru validare (email, IP, telefon)
- [ ] Folosească grep cu opțiunile -i, -v, -n, -c, -o, -E pentru căutare eficientă
- [ ] Aplice sed pentru substituții, ștergeri și modificări de text
- [ ] Proceseze fișiere CSV/TSV cu awk pentru extragere și calcule

### Nivelul 3: Analiză și Sinteză
- [ ] Combine grep, sed și awk în pipeline-uri pentru sarcini complexe
- [ ] Analizeze log-uri de server pentru extragerea statisticilor
- [ ] Creeze rapoarte formatate din date structurate
- [ ] Evalueze eficiența diferitelor abordări de procesare

### Nivelul 4: Evaluare
- [ ] Aleagă tool-ul potrivit pentru fiecare tip de problemă
- [ ] Depaneze expresii regulate care nu funcționează conform așteptărilor
- [ ] Optimizeze one-liner-uri pentru performanță și claritate

---

## De Ce Contează Acest Seminar

### Relevanță Practică Imediată

grep, sed și awk sunt folosite ZILNIC de:
- Administratori de sistem pentru analiza log-urilor
- Dezvoltatori pentru procesarea codului și datelor
- DevOps engineers pentru automatizare
- Data scientists pentru pre-procesarea datelor

### Transferabilitate

Expresiile regulate apar în TOATE limbajele de programare moderne:

```
Python:     import re; re.search(r'\d+', text)
JavaScript: text.match(/\d+/g)
Java:       Pattern.compile("\\d+")
C#:         Regex.Match(text, @"\d+")
SQL:        WHERE column REGEXP '^[A-Z]'
```

### Multiplicarea Productivității

| Abordare | Timp pentru 10,000 fișiere |
|----------|----------------------------|
| Manual (GUI) | ~10 ore |
| Scripturi simple | ~30 minute |
| grep + sed + awk | ~30 secunde |

> "Diferența între un junior și un senior este adesea măsurată în one-liner-uri."

---

## Structura Pachetului

```
SEM07-08_COMPLET/
│
├── 📄 README.md                    ← EȘTI AICI
│
├── 📂 docs/                        # Documentație completă
│   ├── S04_00_ANALIZA_SI_PLAN_PEDAGOGIC.md
│   ├── S04_01_GHID_INSTRUCTOR.md
│   ├── S04_02_MATERIAL_PRINCIPAL.md
│   ├── S04_03_PEER_INSTRUCTION.md
│   ├── S04_04_PARSONS_PROBLEMS.md
│   ├── S04_05_LIVE_CODING_GUIDE.md
│   ├── S04_06_EXERCITII_SPRINT.md
│   ├── S04_07_LLM_AWARE_EXERCISES.md
│   ├── S04_08_DEMO_SPECTACULOASE.md
│   ├── S04_09_CHEAT_SHEET_VIZUAL.md
│   └── S04_10_AUTOEVALUARE_REFLEXIE.md
│
├── 📂 scripts/                     # Scripturi funcționale
│   ├── bash/
│   │   ├── S04_01_setup_seminar.sh
│   │   ├── S04_02_quiz_interactiv.sh
│   │   └── S04_03_validator.sh
│   ├── demo/
│   │   ├── S04_01_hook_demo.sh
│   │   ├── S04_02_demo_regex.sh
│   │   ├── S04_03_demo_grep.sh
│   │   ├── S04_04_demo_sed.sh
│   │   ├── S04_05_demo_awk.sh
│   │   └── S04_06_demo_nano.sh
│   └── python/
│       ├── S04_01_autograder.py
│       ├── S04_02_quiz_generator.py
│       └── S04_03_report_generator.py
│
├── 📂 prezentari/                  # Slide-uri HTML interactive
│   ├── S04_01_prezentare.html
│   └── S04_02_cheat_sheet.html
│
├── 📂 teme/                        # Teme și materiale originale
│   ├── OLD_HW/                     # Fișierele sursă originale
│   │   ├── TC2f_Expresii_Regulate.md
│   │   ├── TC4c_AWK.md
│   │   ├── TC4d_SED.md
│   │   ├── TC4e_GREP.md
│   │   ├── TC4f_VI_VIM.md         # Păstrat pentru referință (nu se folosește)
│   │   └── ANEXA_Referinte_Seminar4.md
│   ├── S04_01_TEMA.md
│   └── S04_02_creeaza_tema.sh
│
├── 📂 resurse/                     # Materiale auxiliare
│   ├── S04_RESURSE.md
│   ├── sample_data/               # Date de test pentru exerciții
│   │   ├── access.log
│   │   ├── employees.csv
│   │   ├── config.txt
│   │   └── emails.txt
│   └── regex_tester.sh
│
└── 📂 teste/                       # Teste și validări
    └── TODO.txt
```

---

## Ghid de Utilizare

### Pasul 1: Dezarhivare și Pregătire

```bash
# Dezarhivează pachetul
unzip SEM07-08_COMPLET.zip
cd SEM07-08_COMPLET

# Verifică structura
ls -la
```

### Pasul 2: Setează Permisiunile de Execuție

```bash
# Acordă permisiuni de execuție pentru toate scripturile
chmod +x scripts/bash/*.sh
chmod +x scripts/demo/*.sh
chmod +x scripts/python/*.py
```

### Pasul 3: Rulează Setup-ul Inițial

```bash
# Acest script verifică și instalează dependențele necesare
./scripts/bash/S04_01_setup_seminar.sh
```

### Pasul 4: Verifică Sample Data

```bash
# Confirmă că datele de test sunt disponibile
ls -la resurse/sample_data/
head resurse/sample_data/access.log
```

### Pasul 5: Începe Explorarea

```bash
# Pentru instructori: începe cu ghidul
less docs/S04_01_GHID_INSTRUCTOR.md

# Pentru studenți: începe cu materialul principal
less docs/S04_02_MATERIAL_PRINCIPAL.md
```

---

## ‍ Pentru Instructori

### Recomandări de Timp

Acest seminar este CEL MAI DENS din curs. Nu încerca să acoperi totul într-o singură sesiune.

| Componentă | Timp Recomandat | Prioritate |
|------------|-----------------|------------|
| Regex fundamentals | 15 min | CRITICĂ |
| GREP în profunzime | 20 min | CRITICĂ |
| SED basics | 15 min | ÎNALTĂ |
| AWK basics | 15 min | ÎNALTĂ |
| nano intro | 5 min | MEDIE |
| Exerciții practice | 30 min | CRITICĂ |

### Proporția Recomandată

```
GREP: ████████████████████ 40%
SED:  ███████████████      30%
AWK:  ██████████           20%
nano: █████                10%
```

### Ce Să Accentuezi

1. Pattern-urile frecvente, nu edge cases-urile obscure
2. Demo-urile live sunt esențiale - studenții învață văzând
3. Greșelile tipice - arată și explică de ce nu funcționează
4. Diferența BRE/ERE - sursă majoră de confuzie

### Ce Să Eviți

- Nu încerca să acoperi PCRE în detaliu (menționează doar)
- Nu te pierde în opțiunile avansate ale sed (hold space etc.)
- Nu insista pe awk complex (funcții custom, getline)
- Nu compara vim cu nano - folosim doar nano

---

## ‍ Pentru Studenți

### Filosofie de Învățare

> NU MEMORA - ÎNȚELEGE CONCEPTELE!

Regex și tool-urile de text processing sunt abilități practice. Cel mai bun mod de a învăța:

1. Experimentează - deschide terminalul și testează
2. Greșește - înțelegi mai bine când vezi ce NU merge
3. Combină - puterea vine din pipeline-uri
4. Folosește resurse - cheat sheet-ul este prietenul tău

### Resurse Esențiale

| Resursă | Pentru Ce | Link |
|---------|-----------|------|
| regex101.com | Testare și debugging regex | https://regex101.com |
| explainshell.com | Explicații comenzi | https://explainshell.com |
| Cheat Sheet | Referință rapidă | `docs/S04_09_CHEAT_SHEET_VIZUAL.md` |

### Ordinea Recomandată de Studiu

```
1. Regex basics     → docs/S04_02_MATERIAL_PRINCIPAL.md (Modulul 1)
2. GREP            → docs/S04_02_MATERIAL_PRINCIPAL.md (Modulul 2)
3. Practică GREP   → docs/S04_06_EXERCITII_SPRINT.md (Sprint-uri G1-G2)
4. SED             → docs/S04_02_MATERIAL_PRINCIPAL.md (Modulul 3)
5. AWK             → docs/S04_02_MATERIAL_PRINCIPAL.md (Modulul 4)
6. nano            → docs/S04_02_MATERIAL_PRINCIPAL.md (Modulul 5)
7. Combinații      → docs/S04_08_DEMO_SPECTACULOASE.md
8. Auto-evaluare   → docs/S04_10_AUTOEVALUARE_REFLEXIE.md
```

### Sfaturi Practice

```bash
# Testează MEREU pe date mici înainte de producție
echo "test data" | grep 'pattern'

# Folosește -n cu sed pentru a vedea ce ar face
sed -n 's/old/new/p' file.txt

# Verifică cu awk pe câteva linii
head -5 file.csv | awk -F',' '{print $2}'
```

---

## Cerințe Tehnice

### Sistem de Operare

- Recomandat: Ubuntu 24.04 LTS
- Acceptat: Orice distribuție Linux modernă, WSL2 pe Windows
- macOS: Funcționează, dar unele opțiuni GNU pot diferi

### Software Necesar

| Package | Verificare | Notă |
|---------|------------|------|
| grep | `grep --version` | GNU grep 3.x |
| sed | `sed --version` | GNU sed 4.x |
| gawk | `awk --version` | GNU Awk 5.x |
| nano | `nano --version` | nano 7.x |
| bash | `bash --version` | Bash 5.x |

### Verificare Rapidă

```bash
# Rulează această comandă pentru verificare completă
for cmd in grep sed awk nano bash; do
    printf "%-10s" "$cmd:"
    $cmd --version 2>&1 | head -1
done
```

---

## Instalare și Configurare

### Metoda 1: Script Automat (Recomandat)

```bash
cd SEM07-08_COMPLET
chmod +x scripts/bash/S04_01_setup_seminar.sh
./scripts/bash/S04_01_setup_seminar.sh
```

### Metoda 2: Instalare Manuală

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install -y grep sed gawk nano coreutils

# Verifică instalarea
grep --version && sed --version && awk --version && nano --version
```

### Metoda 3: WSL2 pe Windows

```powershell
# În PowerShell (Admin)
wsl --install -d Ubuntu-24.04
```

Apoi urmează instrucțiunile pentru Ubuntu.

### Configurare Nano (Opțional)

```bash
# Creează ~/.nanorc pentru configurări personalizate
cat > ~/.nanorc << 'EOF'
set tabsize 4
set autoindent
set linenumbers
set mouse
set softwrap
EOF
```

---

## Probleme Frecvente

### Problema 1: "grep: quantificator nu funcționează"

Simptom: `grep 'ab+c' file` nu găsește "abc" sau "abbc"

Cauza: În BRE (Basic Regular Expression), `+` este un caracter literal.

Soluție:
```bash
# Opțiunea 1: Folosește ERE
grep -E 'ab+c' file.txt

# Opțiunea 2: Escape în BRE
grep 'ab\+c' file.txt
```

### Problema 2: "sed nu modifică fișierul"

Simptom: `sed 's/old/new/' file` nu schimbă nimic în fișier

Cauza: sed implicit scrie la stdout, nu modifică fișierul.

Soluție:
```bash
# Editare in-place
sed -i 's/old/new/' file.txt

# Cu backup (recomandat)
sed -i.bak 's/old/new/' file.txt
```

### Problema 3: "awk print concatenează câmpurile"

Simptom: `awk '{print $1 $2}'` produce "JohnSmith" în loc de "John Smith"

Cauza: Fără virgulă, awk concatenează direct.

Soluție:
```bash
# Cu virgulă - folosește OFS (default: spațiu)
awk '{print $1, $2}' file.txt

# Sau explicit
awk '{print $1 " " $2}' file.txt
```

### Problema 4: "regex cu / în sed nu funcționează"

Simptom: `sed 's//usr/local//opt/' file` dă erori

Cauza: / este și delimiter și parte din pattern.

Soluție:
```bash
# Folosește alt delimiter
sed 's|/usr/local|/opt|g' file.txt
sed 's#/usr/local#/opt#g' file.txt
```

### Problema 5: "BRE vs ERE - când să folosesc ce?"

Ghid rapid:
```bash
# BRE (grep, sed implicit)
# - Caractere speciale: . ^ $ * [ ] \
# - Trebuie escape: + ? { } | ( )

# ERE (grep -E, awk, sed -E)
# - Toate caracterele speciale funcționează direct
# - Nu trebuie escape pentru: + ? { } | ( )

# RECOMANDARE: Folosește MEREU grep -E și sed -E pentru consistență
```

### Problema 6: "nano nu salvează fișierul"

Simptom: Apăs CTRL+S dar nu se întâmplă nimic

Cauza: În nano, shortcut-ul pentru salvare este CTRL+O (Write Out).

Soluție:
```
CTRL+O → confirmă numele → Enter → CTRL+X pentru ieșire
```

### Problema 7: "$0 vs $1 în awk"

Simptom: Confuzie despre ce conține fiecare variabilă

Clarificare:
```bash
echo "John Smith 30" | awk '{
    print "$0 =", $0    # Linia întreagă: "John Smith 30"
    print "$1 =", $1    # Primul câmp: "John"
    print "$NF =", $NF  # Ultimul câmp: "30"
}'
```

### Problema 8: "Regex greedy vs lazy"

Simptom: `grep -oE '<.*>'` returnează prea mult text

Cauza: `*` este greedy (ia cât mai mult posibil).

Soluție:
```bash
# În PCRE (grep -P), folosește *?
grep -oP '<.*?>' file.html

# În ERE, restructurează pattern-ul
grep -oE '<[^>]+>' file.html
```

---

## Resurse Suplimentare

### Documentație Oficială
- GNU Grep Manual: https://www.gnu.org/software/grep/manual/
- GNU Sed Manual: https://www.gnu.org/software/sed/manual/
- GNU Awk Manual: https://www.gnu.org/software/gawk/manual/
- Nano Editor: https://www.nano-editor.org/docs.php

### Tutoriale Interactive
- RegexOne: https://regexone.com
- Regex Crossword: https://regexcrossword.com

### Referințe Rapide
- DevHints Awk: https://devhints.io/awk
- DevHints Sed: https://devhints.io/sed
- Regex Cheatsheet: https://quickref.me/regex

### Cărți Recomandate
- "sed & awk" - Dale Dougherty & Arnold Robbins (O'Reilly)
- "Mastering Regular Expressions" - Jeffrey Friedl (O'Reilly)
- "The AWK Programming Language" - Aho, Kernighan, Weinberger

---

## Contact și Suport

Pentru întrebări sau probleme legate de materialele acestui seminar:

- Întrebări tehnice: Folosiți forumul cursului sau orele de consultații
- Erori în materiale: Raportați printr-un Issue pe repository
- Sugestii de îmbunătățire: Pull requests sunt binevenite

---

## Licență și Atribuire

Aceste materiale sunt create pentru scopuri educaționale în cadrul cursului de Sisteme de Operare, ASE București - CSIE.

Utilizare permisă:
- Studiu personal
- Activități în cadrul cursului
- Modificări pentru uz propriu

Se cere atribuire pentru:
- Redistribuire
- Utilizare în alte cursuri

---

*Material generat pentru Seminarul 7-8 de Sisteme de Operare | ASE București - CSIE*  
*Ultima actualizare: Ianuarie 2025*
