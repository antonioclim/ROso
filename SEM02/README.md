# Seminar 2: Operatori de Control, Redirecționare I/O, Filtre și Bucle

> Observație din laborator: notează-ţi comenzi‑cheie şi output‑ul relevant (2–3 linii) pe măsură ce lucrezi. Te ajută la debug şi, sincer, la final îţi iese şi un README bun fără efort suplimentar.
> Sisteme de Operare | Academia de Studii Economice București - CSIE  
> Versiune: 1.0 | Data: Ianuarie 2025  
> Autor: Materiale Suport Seminarii SO

---

## Cuprins

1. [Descriere](#-descriere)
2. [Obiective de Învățare](#-obiective-de-învățare)
3. [Structura Pachetului](#-structura-pachetului)
4. [Ghid de Utilizare](#-ghid-de-utilizare)
5. [Pentru Instructori](#-pentru-instructori)
6. [Pentru Studenți](#-pentru-studenți)
7. [Cerințe Tehnice](#%EF%B8%8F-cerințe-tehnice)
8. [Instalare și Configurare](#-instalare-și-configurare)
9. [Probleme Frecvente](#-probleme-frecvente)
10. [Resurse Adiționale](#-resurse-adiționale)

---

## Descriere

### Context

Acest seminar este continuarea naturală a Seminar 1 (Introducere în Bash, Navigare, Variabile, Globbing de bază). Presupunem că studenții au deja familiaritate cu:
- Navigarea în sistemul de fișiere (`cd`, `ls`, `pwd`)
- Variabile de mediu și shell (`$HOME`, `$USER`, `$PATH`)
- Globbing de bază (`*`, `?`, `[abc]`)
- Comenzi fundamentale (`echo`, `cat`, `touch`, `mkdir`, `rm`)

### Ce Introduce Acest Seminar

Seminarul 3-4 introduce concepte esențiale pentru scripting și automatizare:

| Modul | Concepte Cheie | Aplicații Practice |
|-------|----------------|-------------------|
| Operatori de Control | `;`, `&&`, `\|\|`, `&`, `\|` | Lanțuri de comenzi, error handling |
| Redirecționare I/O | `>`, `>>`, `<`, `<<`, `<<<`, `2>&1` | Logging, procesare batch |
| Filtre de Text | `sort`, `uniq`, `cut`, `paste`, `tr`, `wc`, `head`, `tail`, `tee` | Procesare date, analiză log-uri |
| Bucle | `for`, `while`, `until`, `break`, `continue` | Automatizare, batch processing |

### Filosofia Seminarului

> Din sală: Pipes și redirecționarea sunt momentul "aha!" pentru majoritatea studenților. Când văd că pot face în 3 comenzi înlănțuite ce ar lua 50 de linii de Python, percepția lor despre terminal se schimbă complet. E unul din cele mai satisfăcătoare momente din semestru.

Acest seminar urmează paradigma "Limbaj ca Vehicul" - folosim Bash nu ca scop în sine, ci ca instrument pentru a înțelege concepte fundamentale ale sistemelor de operare:
- Procese și exit codes - cum comunică programele între ele
- File descriptors - modelul Unix de I/O
- Pipes și filozofia Unix - "do one thing and do it well"
- Automatizare - transformarea taskurilor repetitive în scripturi

---

## Obiective de Învățare

La finalul acestui seminar, studenții vor fi capabili să:

### Nivel Aplicare (Anderson-Bloom)
1. Combină comenzi folosind operatorii de control (`;`, `&&`, `||`, `&`)
2. Redirecționează input și output folosind `>`, `>>`, `<`, `<<`, `<<<`
3. Construiască pipeline-uri eficiente cu `|` și `tee`
4. Folosească filtrele de text: `sort`, `uniq`, `cut`, `paste`, `tr`, `wc`, `head`, `tail`
5. Scrie bucle `for`, `while`, `until` cu control flow (`break`, `continue`)

### Nivel Analiză (Anderson-Bloom)
6. Diagnosticheze erori în scripturi folosind exit codes și PIPESTATUS
7. Compare eficiența diferitelor abordări pentru aceeași problemă
8. Evalueze cod generat de LLM-uri pentru corectitudine și eficiență

### Nivel Creare (Anderson-Bloom)
9. Proiecteze pipeline-uri complexe pentru procesarea datelor
10. Automatizeze task-uri administrative cu scripturi solide

---

## Structura Pachetului

```
Seminar 2_COMPLET/
│
├── README.md                           # 📖 Acest fișier - ghidul principal
│
├── docs/                               # 📚 Documentație și materiale didactice
│   ├── S02_00_ANALIZA_SI_PLAN_PEDAGOGIC.md   # Analiză materiale + plan
│   ├── S02_01_GHID_INSTRUCTOR.md             # Ghid pas-cu-pas pentru instructor
│   ├── S02_02_MATERIAL_PRINCIPAL.md          # Material teoretic complet
│   ├── S02_03_PEER_INSTRUCTION.md            # 15+ întrebări MCQ
│   ├── S02_04_PARSONS_PROBLEMS.md            # 10+ probleme de reordonare
│   ├── S02_05_LIVE_CODING_GUIDE.md           # Script pentru live coding
│   ├── S02_06_EXERCITII_SPRINT.md            # Exerciții cronometrate
│   ├── S02_07_LLM_AWARE_EXERCISES.md         # Exerciții cu evaluare LLM
│   ├── S02_08_DEMO_SPECTACULOASE.md          # Demo-uri vizuale
│   ├── S02_09_CHEAT_SHEET_VIZUAL.md          # One-pager cu comenzi
│   └── S02_10_AUTOEVALUARE_REFLEXIE.md       # Checkpoint-uri metacognitive
│
├── scripts/                            # 🔧 Scripturi funcționale
│   ├── bash/                           # Utilitare Bash
│   │   ├── S02_01_setup_seminar.sh          # Setup mediu de lucru
│   │   ├── S02_02_quiz_interactiv.sh        # Quiz cu dialog/text
│   │   └── S02_03_validator.sh              # Validare teme
│   │
│   ├── demo/                           # Demo-uri spectaculoase
│   │   ├── S02_01_hook_demo.sh              # Hook de deschidere
│   │   ├── S02_02_demo_pipes.sh             # Demonstrație pipeline-uri
│   │   ├── S02_03_demo_redirectare.sh       # Demonstrație I/O
│   │   ├── S02_04_demo_filtre.sh            # Showcase filtre
│   │   └── S02_05_demo_bucle.sh             # Exemple bucle
│   │
│   └── python/                         # Utilitare Python
│       ├── S02_01_autograder.py             # Evaluare automată
│       ├── S02_02_quiz_generator.py         # Generator quiz-uri
│       └── S02_03_report_generator.py       # Statistici și rapoarte
│
├── prezentari/                         # 📊 Prezentări HTML
│   ├── S02_01_prezentare.html              # Prezentare principală (reveal.js)
│   └── S02_02_cheat_sheet.html             # Cheat sheet printabil
│
├── teme/                               # 📝 Teme și exerciții
│   ├── OLD_HW/                             # Materialele originale (referință)
│   │   ├── TC2c_Operatori_Control.md
│   │   ├── TC4a_Redirectionare_IO.md
│   │   ├── TC2d_Filtre.md
│   │   ├── TC3b_Bucle_Scripting.md
│   │   ├── TC2a_Introducere_Globbing.md
│   │   ├── TC3a_Variabile_Shell.md
│   │   └── ANEXA_Referinte_Seminar2.md
│   │
│   ├── S02_01_TEMA.md                      # Specificații temă
│   └── S02_02_creeaza_tema.sh              # Generator structură temă
│
├── resurse/                            # 📚 Resurse adiționale
│   └── S02_RESURSE.md                      # Linkuri și bibliografie
│
└── teste/                              # ✅ Teste și validare
    └── TODO.txt                            # Placeholder pentru teste
```

---

## Ghid de Utilizare

### Pasul 1: Dezarhivare

```bash
# Dacă ai primit arhiva .zip
unzip Seminar 2_COMPLET.zip
cd Seminar 2_COMPLET

# Sau dacă ai primit .tar.gz
tar xzf Seminar 2_COMPLET.tar.gz
cd Seminar 2_COMPLET
```

### Pasul 2: Setare Permisiuni

```bash
# Face toate scripturile executabile
chmod +x scripts/bash/*.sh
chmod +x scripts/demo/*.sh
chmod +x scripts/python/*.py
chmod +x teme/*.sh

# Verifică
ls -la scripts/bash/
```

### Pasul 3: Setup Mediu

```bash
# Rulează scriptul de setup (verifică dependențe, creează directoare)
./scripts/bash/S02_01_setup_seminar.sh

# Sau manual:
mkdir -p ~/seminar_so/demo
cd ~/seminar_so/demo
```

### Pasul 4: Verificare Funcționalitate

```bash
# Testează un demo rapid
./scripts/demo/S02_01_hook_demo.sh

# Dacă vezi output colorat și formatat = totul funcționează!
```

---

## ‍ Pentru Instructori

### Checklist Pregătire Seminar (15 min înainte)

```bash
# 1. Verifică versiunea Bash (minim 4.0)
bash --version

# 2. Verifică tool-uri opționale
for cmd in figlet lolcat dialog pv cowsay; do
    which $cmd &>/dev/null && echo "✓ $cmd instalat" || echo "✗ $cmd lipsește"
done

# 3. Creează director curat pentru demo
rm -rf ~/demo_sem2 && mkdir ~/demo_sem2 && cd ~/demo_sem2

# 4. Setează terminal cu font mare, vizibil
# (manual: Preferences → Font Size 14+)

# 5. Testează proiectorul/sharing-ul de ecran
```

### Structura Seminarului (100 minute)

| Timp | Activitate | Material |
|------|------------|----------|
| 0:00-0:05 | 🎬 Hook Demo | `S02_01_hook_demo.sh` |
| 0:05-0:10 | 🗳️ Peer Instruction Q1 | `S02_03_PEER_INSTRUCTION.md` |
| 0:10-0:25 | 💻 Live Coding: Operatori | `S02_05_LIVE_CODING_GUIDE.md` |
| 0:25-0:30 | 🧩 Parsons Problem #1 | `S02_04_PARSONS_PROBLEMS.md` |
| 0:30-0:45 | 🏃 Sprint #1: Pipes | `S02_06_EXERCITII_SPRINT.md` |
| 0:45-0:50 | 🗳️ Peer Instruction Q2 | `S02_03_PEER_INSTRUCTION.md` |
| 0:50-1:00 | ☕ PAUZĂ | Demo pasiv pe ecran |
| 1:00-1:05 | 🔄 Reactivare Quiz | `S02_02_quiz_interactiv.sh` |
| 1:05-1:20 | 💻 Live Coding: Filtre + Bucle | `S02_05_LIVE_CODING_GUIDE.md` |
| 1:20-1:25 | 🗳️ Peer Instruction Q3 | `S02_03_PEER_INSTRUCTION.md` |
| 1:25-1:40 | 🏃 Sprint #2: Filtre | `S02_06_EXERCITII_SPRINT.md` |
| 1:40-1:48 | 🤖 Exercițiu LLM | `S02_07_LLM_AWARE_EXERCISES.md` |
| 1:48-1:50 | 🧠 Reflection + Wrap-up | `S02_10_AUTOEVALUARE_REFLEXIE.md` |

### Evaluare Teme cu Autograder

```bash
# Evaluare singur student
python3 scripts/python/S02_01_autograder.py ~/teme_studenti/PopescuIon/

# Evaluare batch toată grupa
for d in ~/teme_studenti/*/; do
    python3 scripts/python/S02_01_autograder.py "$d" >> rezultate.csv
done

# Generare raport
python3 scripts/python/S02_03_report_generator.py rezultate.csv > raport_grupa.html
```

---

## ‍ Pentru Studenți

### Pași de Început

1. Parcurge materialul principal: `docs/S02_02_MATERIAL_PRINCIPAL.md`
2. Fă exercițiile din sprint-uri: `docs/S02_06_EXERCITII_SPRINT.md`
3. Testează-ți înțelegerea: `./scripts/bash/S02_02_quiz_interactiv.sh`
4. Completează tema: `teme/S02_01_TEMA.md`

### Resurse de Studiu Recomandate

| Prioritate | Resursă | Timp Estimat |
|------------|---------|--------------|
| 🔴 Obligatoriu | Material Principal | 45 min citire |
| 🔴 Obligatoriu | Exerciții Sprint (minim 3) | 30 min practică |
| 🟡 Recomandat | Cheat Sheet Vizual | 10 min memorare |
| 🟡 Recomandat | Demo-uri Spectaculoase | 15 min explorare |
| 🟢 Opțional | Peer Instruction (self-test) | 20 min |
| 🟢 Opțional | LLM-Aware Exercises | 30 min |

### Cum Să Testezi Tema Înainte de Predare

```bash
# 1. Creează structura temei
./teme/S02_02_creeaza_tema.sh "NumeTau" "GrupaXX"

# 2. Completează exercițiile în directorul creat

# 3. Rulează validatorul
./scripts/bash/S02_03_validator.sh ~/tema_NumeTau_GrupaXX/

# 4. Verifică output-ul - trebuie să vezi la toate testele
```

---

## Cerințe Tehnice

### Obligatoriu

| Component | Versiune Minimă | Verificare |
|-----------|-----------------|------------|
| **Ubuntu** | 22.04 LTS+ | `lsb_release -a` |
| **Bash** | 4.0+ | `bash --version` |
| Python | 3.8+ | `python3 --version` |
| **coreutils** | standard | `sort --version` |

### Opțional (pentru demo-uri spectaculoase)

```bash
# Instalare toate tool-urile opționale
sudo apt update && sudo apt install -y \
    figlet lolcat cowsay fortune \
    pv dialog tree ncdu \
    htop bc jq

# Verificare
which figlet lolcat dialog pv
```

### Verificare Rapidă Compatibilitate

```bash
# Rulează acest one-liner pentru verificare completă
echo "Bash: $(bash --version | head -1)" && \
echo "Python: $(python3 --version)" && \
echo "Sort: $(sort --version | head -1)" && \
for cmd in figlet lolcat pv dialog; do \
    which $cmd &>/dev/null && echo "✓ $cmd" || echo "✗ $cmd (opțional)"; \
done
```

---

## Instalare și Configurare

### Metoda 1: Descărcare Directă (Studenți)

```bash
# Dacă materialele sunt pe un server
wget https://materiale.ase.ro/so/Seminar 2_COMPLET.zip
unzip Seminar 2_COMPLET.zip
cd Seminar 2_COMPLET
./scripts/bash/S02_01_setup_seminar.sh
```

### Metoda 2: USB Stick (Laborator)

```bash
# Montare USB (dacă nu e automount)
sudo mount /dev/sdb1 /mnt/usb

# Copiere locală
cp -r /mnt/usb/Seminar 2_COMPLET ~/
cd ~/Seminar 2_COMPLET
chmod +x scripts/**/*.sh
```

### Configurare Laborator WSL (Windows)

Credențiale standard laborator ASE:
- User: `stud`
- Password: `stud`
- Portainer (Docker management): `http://localhost:9000`
  - User: `stud`
  - Password: `studstudstud`

```bash
# În WSL Ubuntu
cd /mnt/c/Users/stud/Desktop
# Sau orice director partajat

# Setup
./scripts/bash/S02_01_setup_seminar.sh --wsl
```

---

## Probleme Frecvente

### 1. "Permission denied" la rulare scripturi

```bash
# Problemă
./script.sh
# bash: ./script.sh: Permission denied

# Soluție
chmod +x script.sh
./script.sh

# Sau rulează cu bash explicit
bash script.sh
```

### 2. Scripturile nu găsesc comenzile (figlet, lolcat, etc.)

```bash
# Problemă: Command not found

# Soluție - instalează dependențele
sudo apt update
sudo apt install figlet lolcat pv dialog -y

# Sau rulează scripturile în modul fallback (fără efecte vizuale)
SIMPLE_MODE=1 ./scripts/demo/S02_01_hook_demo.sh
```

### 3. Erori de encoding cu caractere românești

```bash
# Problemă: Caractere ciudate în loc de ă, î, ș

# Soluție - setează locale-ul corect
export LANG=ro_RO.UTF-8
export LC_ALL=ro_RO.UTF-8

# Verifică
locale
```

### 4. Quiz-ul interactiv nu funcționează (dialog)

```bash
# Problemă: dialog: command not found

# Soluție 1: Instalează dialog
sudo apt install dialog -y

# Soluție 2: Folosește modul text
./scripts/bash/S02_02_quiz_interactiv.sh --text-mode
```

### 5. Python scripts dau erori de import

```bash
# Problemă: ModuleNotFoundError

# Soluție - instalează dependențele Python
pip3 install --user rich tabulate

# Sau cu requirements.txt
pip3 install -r requirements.txt --break-system-packages
```

### 6. Fișierele nu se salvează în WSL

```bash
# Problemă: Read-only file system în WSL

# Soluție - lucrează în home directory
cd ~
mkdir -p seminar_so
cd seminar_so

# NU lucra direct în /mnt/c/... pentru scripturi
```

### 7. Exit codes ciudate în pipeline-uri

```bash
# Problemă: $? returnează doar exit code-ul ultimei comenzi

# Soluție - folosește PIPESTATUS
cmd1 | cmd2 | cmd3
echo "Exit codes: ${PIPESTATUS[@]}"
# Afișează: Exit codes: 0 1 0 (exemplu)

# Sau setează pipefail
set -o pipefail
cmd1 | cmd2 | cmd3
echo $?  # Acum returnează primul non-zero
```

### 8. Bucla while read nu modifică variabilele

```bash
# Problemă: Variabilele modificate în while | nu persistă

count=0
cat file.txt | while read line; do
    ((count++))
done
echo $count  # Afișează 0! (subshell problem)

# Soluție - folosește process substitution sau redirect
count=0
while read line; do
    ((count++))
done < file.txt
echo $count  # Afișează valoarea corectă
```

---

## Resurse Adiționale

### Documentație Oficială
- [Bash Reference Manual](https://www.gnu.org/software/bash/manual/)
- [POSIX Shell Specification](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html)
- [Linux man pages](https://man7.org/linux/man-pages/)

### Tutoriale Interactive
- [Exercism Bash Track](https://exercism.org/tracks/bash)
- [HackerRank Shell Challenges](https://www.hackerrank.com/domains/shell)
- [OverTheWire Bandit](https://overthewire.org/wargames/bandit/)

### Cărți Recomandate
- "The Linux Command Line" - William Shotts (gratuit online)
- "Learning the bash Shell" - O'Reilly
- "Shell Scripting" - Steve Parker

### Comunitate
- r/bash, r/linux, r/commandline pe Reddit
- Unix & Linux Stack Exchange
- #bash pe IRC (Libera.Chat)

---

## Licență și Atribuire

Acest pachet educațional este creat pentru ASE București - CSIE, cursul de Sisteme de Operare.

Licență: CC BY-SA 4.0 - Utilizare liberă cu atribuire

Contribuții: 
- Materiale originale: Echipa SO ASE-CSIE
- Adaptare pedagogică: Framework Brown & Wilson, Anderson-Bloom
- Colecție demo-uri: BASH_MAGIC_COLLECTION

---

## Contact și Suport

- Probleme tehnice: Deschide un issue sau contactează instructorul
- Feedback: Folosește formularul de feedback de la final de seminar
- Îmbunătățiri: Pull requests sunt binevenite!

---

*Ultimă actualizare: Ianuarie 2025*  
*Testat pe: Ubuntu 24.04 LTS, WSL2 Ubuntu 22.04*
