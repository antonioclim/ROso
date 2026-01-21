# Seminar 9-10: Advanced Bash Scripting

> Observație din laborator: notează-ţi comenzi‑cheie şi output‑ul relevant (2–3 linii) pe măsură ce lucrezi. Te ajută la debug şi, sincer, la final îţi iese şi un README bun fără efort suplimentar.
> Sisteme de Operare | Academia de Studii Economice București - CSIE  
> Versiune: 1.0 | Data: Ianuarie 2025

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
9. [Probleme Frecvente](#-probleme-frecvente)
10. [Resurse Suplimentare](#-resurse-suplimentare)

---

## Descriere

Acest seminar reprezintă PUNCTUL DE COTITURĂ al cursului de Sisteme de Operare. Până acum, studenții au învățat comenzi individuale și scripturi simple. De acum înainte, vor scrie cod profesional care poate fi folosit în producție.

### Context și Precondiții

Acest seminar presupune completarea seminarelor anterioare:

| Seminar | Conținut |
|---------|----------|
| SEM01-02 | Navigare în sistem de fișiere, variabile, globbing |
| SEM03-04 | Operatori, redirecționare, pipe-uri, filtre, bucle de bază |
| SEM05-06 | `find`, `xargs`, scripturi cu argumente, permisiuni, cron |
| SEM07-08 | Expresii regulate, `grep`, `sed`, `awk`, editorul nano |

Ce introduce acest seminar:

- Funcții avansate: variabile locale cu `local`, return values, nameref, recursivitate
- Arrays: indexate (0-based) și asociative (hash maps cu `declare -A`)
- Stabilitate: `set -euo pipefail`, IFS sigur, verificări defensive
- Error handling: trap EXIT/ERR/INT/TERM, cleanup patterns
- Logging și Debug: sistem profesional de logging cu nivele, tehnici de debug
- Template profesional: structură standard pentru scripturi de producție

### Tranziția

```
┌─────────────────────────┐         ┌─────────────────────────┐
│    ÎNAINTE (SEM01-08)   │   ──►   │   DUPĂ (SEM09-10)       │
├─────────────────────────┤         ├─────────────────────────┤
│ Scripturi simple        │         │ Scripturi de producție  │
│ "Funcționează"          │         │ "Funcționează ROBUST"   │
│ Cod aruncat             │         │ Cod mentenabil          │
│ Happy path only         │         │ Error handling complet  │
│ echo pentru debug       │         │ Sistem de logging       │
│ Variabile globale       │         │ Funcții modulare        │
└─────────────────────────┘         └─────────────────────────┘
```

---

## Obiective de Învățare

La finalul acestui seminar, studenții vor fi capabili să:

### Nivel Fundamental (Remember & Understand)
- Definească sintaxa pentru funcții, arrays indexate și asociative în Bash
- Explice diferența dintre variabile locale și globale în contextul funcțiilor
- Descrie comportamentul `set -e`, `set -u`, `set -o pipefail`
- Identifice semnalele Unix standard și utilizarea `trap`

### Nivel Aplicativ (Apply & Analyze)
- Creeze funcții cu variabile locale și mecanisme de return values
- Implementeze arrays indexate și asociative pentru diverse scenarii
- Aplice `set -euo pipefail` și verificări defensive în scripturi
- Configureze trap-uri pentru cleanup automat și error handling
- Integreze un sistem de logging cu nivele în scripturi

### Nivel Avansat (Evaluate & Create)
- Evalueze critic solidețea unui script existent și propună îmbunătățiri
- Proiecteze și implementeze scripturi complete folosind template-ul profesional
- Aleagă strategia potrivită pentru error handling în diverse scenarii
- Creeze biblioteci de funcții reutilizabile pentru proiecte viitoare

---

## De Ce Contează Acest Seminar

### Diferența între Amateur și Profesionist

```bash
# Script de AMATEUR
cd /tmp/data
rm -rf *
process_file $1
echo "Done"

# Script de PROFESIONIST
#!/bin/bash
set -euo pipefail

cd /tmp/data || die "Cannot cd to /tmp/data"
[[ -n "${1:-}" ]] || { usage; exit 1; }
rm -rf ./*  # ./* nu șterge tot / dacă cd eșuează
process_file "$1"
log_info "Processing completed successfully"
```

Ce se întâmplă când `cd` eșuează în versiunea amator?
- `rm -rf *` se execută în directorul CURENT (poate fi `/` sau `$HOME`)
- DEZASTRU TOTAL - pierdere de date

### Aceste Tehnici Sunt Standard în Industrie

- Error handling - Script-urile nu mai "mor" silențios
- Logging - Poți depana probleme fără să fii prezent
- Arrays - Structuri de date reale în Bash
- Funcții - Cod modular, testabil, reutilizabil

### Ce Câștigi

| Abilitate | Beneficiu Imediat | Beneficiu pe Termen Lung |
|-----------|-------------------|--------------------------|
| `set -euo pipefail` | Erori detectate instant | Scripturi fiabile în producție |
| trap cleanup | Fără fișiere temporare orfane | Sistem curat, debugging ușor |
| Logging | Vezi ce face scriptul | Debugging post-mortem |
| Funcții | Cod organizat | Biblioteci reutilizabile |
| Arrays | Procesare liste corectă | Algoritmi complecși în Bash |

---

## Structura Pachetului

```
SEM09-10_COMPLET/
│
├── README.md                              # Acest fișier
│
├── docs/                                  # Documentație completă
│   ├── S05_00_ANALIZA_SI_PLAN_PEDAGOGIC.md   # Analiză materiale & plan
│   ├── S05_01_GHID_INSTRUCTOR.md             # Ghid pas-cu-pas instructor
│   ├── S05_02_MATERIAL_PRINCIPAL.md          # Teorie completă
│   ├── S05_03_PEER_INSTRUCTION.md            # Întrebări MCQ pentru PI
│   ├── S05_04_PARSONS_PROBLEMS.md            # Probleme de reordonare cod
│   ├── S05_05_LIVE_CODING_GUIDE.md           # Script pentru live coding
│   ├── S05_06_EXERCITII_SPRINT.md            # Exerciții cronometrate
│   ├── S05_07_LLM_AWARE_EXERCISES.md         # Exerciții cu evaluare LLM
│   ├── S05_08_DEMO_SPECTACULOASE.md          # Demo-uri vizuale
│   ├── S05_09_CHEAT_SHEET_VIZUAL.md          # One-pager referință
│   └── S05_10_AUTOEVALUARE_REFLEXIE.md       # Instrumente autoevaluare
│
├── scripts/                               # Scripturi funcționale
│   ├── bash/                              # Utilitare Bash
│   │   ├── S05_01_setup_seminar.sh           # Setup mediu demo
│   │   ├── S05_02_quiz_interactiv.sh         # Quiz interactiv
│   │   └── S05_03_validator.sh               # Validator teme
│   │
│   ├── demo/                              # Demo-uri pentru fiecare concept
│   │   ├── S05_01_hook_demo.sh               # Hook: fragil vs robust

> 💡 Am avut studenți care au învățat Bash în două săptămâni pornind de la zero — deci se poate, cu practică consistentă.

│   │   ├── S05_02_demo_functions.sh          # Demo funcții
│   │   ├── S05_03_demo_arrays.sh             # Demo arrays

> 💡 În laboratoarele anterioare, am văzut că cea mai frecventă greșeală e uitarea ghilimelelor la variabile cu spații.

│   │   ├── S05_04_demo_robust.sh             # Demo set -euo pipefail
│   │   ├── S05_05_demo_logging.sh            # Demo logging system
│   │   └── S05_06_demo_debug.sh              # Demo debugging
│   │
│   ├── templates/                         # Template-uri reutilizabile
│   │   ├── professional_script.sh            # Template complet comentat
│   │   ├── simple_script.sh                  # Template minimalist
│   │   └── library.sh                        # Funcții comune
│   │
│   └── python/                            # Tooling Python
│       ├── S05_01_autograder.py              # Evaluator automat teme
│       ├── S05_02_quiz_generator.py          # Generator quiz-uri
│       └── S05_03_report_generator.py        # Generator rapoarte
│
├── prezentari/                            # Materiale vizuale
│   ├── S05_01_prezentare.html                # Prezentare interactivă
│   └── S05_02_cheat_sheet.html               # Cheat sheet vizual
│
├── teme/                                  # Materiale pentru temă
│   ├── OLD_HW/                               # Materialele originale
│   │   ├── TC5a_Practica_Bash.md
│   │   ├── TC6a_Scripting_Avansat_3.md
│   │   ├── TC6b_Scripting_Avansat_4.md
│   │   └── ANEXA_Referinte_Seminar5.md
│   ├── S05_01_TEMA.md                        # Specificații temă
│   └── S05_02_creeaza_tema.sh                # Script generare template
│
├── resurse/                               # Materiale suplimentare
│   └── S05_RESURSE.md                        # Link-uri și referințe
│
└── teste/                                 # Testing
    └── TODO.txt                              # Placeholder
```

---

## Ghid de Utilizare

### Dezarhivare și Setup Inițial

```bash
# 1. Dezarhivează pachetul
unzip SEM09-10_COMPLET.zip
cd SEM09-10_COMPLET

# 2. Verifică versiunea Bash (trebuie >= 4.0)
bash --version

# 3. Rulează setup-ul
chmod +x scripts/bash/*.sh scripts/demo/*.sh scripts/templates/*.sh
./scripts/bash/S05_01_setup_seminar.sh

# 4. Verifică instalarea shellcheck (opțional dar recomandat)
shellcheck --version || sudo apt install shellcheck
```

### Pentru Instructor - Pregătire Seminar

```bash
# 1. Citește ghidul instructor (OBLIGATORIU)
cat docs/S05_01_GHID_INSTRUCTOR.md | less

# 2. Testează demo-urile
for demo in scripts/demo/*.sh; do
    echo "=== Testing: $demo ==="
    bash -n "$demo"  # Verifică sintaxa
done

# 3. Pregătește prezentarea
firefox prezentari/S05_01_prezentare.html &

# 4. Deschide cheat sheet-ul pentru referință rapidă
firefox prezentari/S05_02_cheat_sheet.html &
```

### Pentru Student - Învățare Independentă

```bash
# 1. Citește materialul teoretic
cat docs/S05_02_MATERIAL_PRINCIPAL.md | less

# 2. Studiază template-ul profesional
cat scripts/templates/professional_script.sh | less

# 3. Execută demo-urile pas cu pas
./scripts/demo/S05_02_demo_functions.sh
./scripts/demo/S05_03_demo_arrays.sh

# 4. Rezolvă exercițiile sprint
cat docs/S05_06_EXERCITII_SPRINT.md | less

# 5. Auto-evaluare
cat docs/S05_10_AUTOEVALUARE_REFLEXIE.md | less
```

---

## ‍ Pentru Instructori

### Principii de Predare

1. Focus pe PATTERN-uri, nu pe memorare
   - Studenții trebuie să înțeleagă DE CE, nu doar CUM
   - Template-ul profesional e ESENȚIAL - începe cu el

2. Demo-uri: arată scriptul fragil vs solid
   - Impact vizual și memorabil
   - Demonstrează consecințele reale ale lipsei error handling

3. Exercițiile practice > teoria
   - Minimum 50% din timp pe coding hands-on
   - Sprint-uri scurte (5-10 min) cu feedback imediat

4. Normalizează greșelile
   - Introduce erori deliberate în live coding
   - Arată procesul de debugging

### Timeline Recomandat (100 minute)

| Timp | Activitate | Documente |
|------|------------|-----------|
| 0:00-0:05 | Hook: Script fragil vs solid | `S05_01_hook_demo.sh` |
| 0:05-0:25 | Funcții (live coding + PI) | `S05_05_LIVE_CODING_GUIDE.md` |
| 0:25-0:45 | Arrays (live coding + sprint) | `S05_02_demo_arrays.sh` |
| 0:45-0:50 | PAUZĂ | - |
| 0:50-0:70 | Stabilitate + trap | `S05_04_demo_robust.sh` |
| 0:70-0:85 | Template profesional walkthrough | `professional_script.sh` |
| 0:85-0:95 | Sprint final + LLM exercise | `S05_07_LLM_AWARE_EXERCISES.md` |
| 0:95-1:40 | Reflection + Temă | `S05_10_AUTOEVALUARE_REFLEXIE.md` |

### Atenționări Speciale

⚠️ Variabile locale vs globale: Demonstrează DIFERENȚA cu un exemplu concret  
⚠️ `declare -A` e OBLIGATORIU: Pentru orice array asociativ  
⚠️ `set -e` nu e magic: Nu funcționează în subshells, pipes fără pipefail  
⚠️ trap nu se moștenește: În subshells trebuie resetat

---

## ‍ Pentru Studenți

### Principii Fundamentale

1. NU memora - ÎNȚELEGE de ce
   - Fiecare linie din template există cu un motiv
   - Întreabă "Ce problemă rezolvă asta?"

2. Începe TOATE scripturile cu template-ul
   - Copiază `scripts/templates/professional_script.sh`
   - Adaptează pentru nevoile tale

3. `set -euo pipefail` ÎNTOTDEAUNA
   - Prima linie după shebang
   - Fără excepții pentru scripturi noi

4. **Testează pe cazuri de EROARE, nu doar happy path**

Principalele aspecte: ce se întâmplă dacă fișierul nu există?, ce se întâmplă dacă argumentul lipsește? și ce se întâmplă dacă disk-ul e plin?.


### Workflow Recomandat pentru Scripturi Noi

```bash
# 1. Pornește de la template
cp scripts/templates/professional_script.sh ~/my_script.sh

# 2. Editează cu nano (NU vim!)
nano ~/my_script.sh

# 3. Verifică cu shellcheck
shellcheck ~/my_script.sh

# 4. Testează happy path
./my_script.sh test_input.txt

# 5. Testează error cases
./my_script.sh                    # Fără argumente
./my_script.sh nonexistent.txt    # Fișier inexistent
./my_script.sh /etc/shadow        # Fișier fără permisiuni
```

### Greșeli Comune de Evitat

| Greșeală | Consecință | Soluție |
|----------|------------|---------|
| `${arr[@]}` fără ghilimele | Word splitting pe spații | `"${arr[@]}"` ÎNTOTDEAUNA |
| Array asociativ fără `declare -A` | Se tratează ca indexat | `declare -A hash` OBLIGATORIU |
| `return "string"` | Nu funcționează (doar 0-255) | Folosește `echo` pentru string |
| `local` în afara funcției | Eroare de sintaxă | Doar în interiorul funcțiilor |
| trap în subshell | Nu se moștenește | Resetează în subshell |

---

## Cerințe Tehnice

### Sistem de Operare

Concret: Ubuntu 24.04 LTS (recomandat). WSL2 pe Windows 10/11. Și Orice distribuție Linux cu Bash 4.0+.


### Versiune Bash
```bash
# Verifică versiunea
bash --version
# Trebuie: GNU bash, version 4.0+ (pentru arrays asociative)

# Pe macOS, instalează bash nou:
brew install bash
```

### Instrumente Recomandate

| Tool | Scop | Instalare |
|------|------|-----------|
| `shellcheck` | Linting scripturi Bash | `sudo apt install shellcheck` |
| `nano` | Editor de text | Pre-instalat |
| `dialog` | Interfețe TUI | `sudo apt install dialog` |
| `jq` | Procesare JSON | `sudo apt install jq` |

### Structura Directoarelor de Lucru

```bash
# Recomandare: creează un director dedicat
mkdir -p ~/SO/SEM09-10
cd ~/SO/SEM09-10

# Copiază template-ul pentru fiecare script nou
cp /path/to/SEM09-10_COMPLET/scripts/templates/professional_script.sh ./
```

---

## Probleme Frecvente

### 1. "bad array subscript" la arrays asociative

Cauză: Nu ai declarat array-ul cu `declare -A`

```bash
# GREȘIT
config[host]="localhost"

# CORECT
declare -A config
config[host]="localhost"
```

### 2. "unbound variable" pentru variabile opționale

Cauză: `set -u` e activ și variabila nu există

```bash
# GREȘIT
echo $OPTIONAL_VAR

# CORECT - cu default value
echo "${OPTIONAL_VAR:-default_value}"

# CORECT - verificare explicită
if [[ -v OPTIONAL_VAR ]]; then
    echo "$OPTIONAL_VAR"
fi
```

### 3. Script-ul nu se oprește la eroare

Cauză: Eroarea e într-un context unde `set -e` nu funcționează

```bash
# Contexte unde set -e NU funcționează:
cmd1 || cmd2         # cmd1 poate eșua
cmd1 && cmd2         # cmd1 poate eșua
if cmd; then ...     # cmd poate eșua
while cmd; do ...    # cmd poate eșua
cmd | cmd2           # fără pipefail, doar ultima comandă
$(cmd)               # în command substitution
```

### 4. trap cleanup nu se execută

Cauză: `exit` înainte de setup-ul trap

```bash
# GREȘIT
exit 1              # cleanup nu se execută
trap cleanup EXIT   # prea târziu!

# CORECT
trap cleanup EXIT   # setup ÎNAINTE de orice exit
# ... cod ...
exit 1              # acum cleanup se execută
```

### 5. Funcția nu returnează string-ul așteptat

Cauză: Confuzie între `return` și `echo`

```bash
# return e DOAR pentru exit code (0-255)
get_value() {
    return "hello"  # ❌ Nu funcționează!
}

# Folosește echo pentru a returna string
get_value() {
    echo "hello"    # ✅ Corect
}
result=$(get_value)
```

### 6. Array-ul pare gol după iterare

Cauză: Iterezi fără ghilimele - word splitting

```bash
arr=("one two" "three")

# GREȘIT - "one two" devine două elemente
for item in ${arr[@]}; do
    echo "$item"
done

# CORECT
for item in "${arr[@]}"; do
    echo "$item"
done
```

### 7. shellcheck dă warning despre variabilă nefolsită

Cauză: shellcheck nu vede utilizarea în alt context

```bash
# Adaugă directivă pentru a ignora
# shellcheck disable=SC2034
UNUSED_BUT_NEEDED="value"
```

### 8. local nu funcționează

Cauză: `local` e valid DOAR în interiorul funcțiilor

```bash
# GREȘIT - la nivel global
local var="value"

# CORECT - în funcție
my_func() {
    local var="value"
}
```

---

## Resurse Suplimentare

### Documentație Oficială
- [GNU Bash Manual](https://www.gnu.org/software/bash/manual/)
- [Advanced Bash-Scripting Guide](https://tldp.org/LDP/abs/html/)
- [ShellCheck Wiki](https://github.com/koalaman/shellcheck/wiki)

### Cărți Recomandate

Pe scurt: "The Linux Command Line" - William Shotts; "Learning the bash Shell" - O'Reilly; "Bash Cookbook" - O'Reilly.


### Practică Online
- [Exercism - Bash Track](https://exercism.org/tracks/bash)
- [HackerRank - Linux Shell](https://www.hackerrank.com/domains/shell)
- [OverTheWire - Bandit](https://overthewire.org/wargames/bandit/)
- Documentează ce ai făcut pentru referință ulterioară

### Video Tutorials
- MIT Missing Semester - Shell Tools
- Linux Foundation - Bash Scripting

---

## Licență și Atribuire

Acest material a fost dezvoltat pentru cursul de Sisteme de Operare în cadrul Academia de Studii Economice București - CSIE.

Materialele pot fi folosite și adaptate în scopuri educaționale cu atribuire corespunzătoare.

---

*Ultima actualizare: Ianuarie 2025*  
*Versiune: 1.0*
