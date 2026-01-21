# ROso — Sisteme de Operare: Kit Educațional Complet

```
┌─────────────────────────────────────────────────────────────────────────────────────────┐
│  🐧 LINUX    Ubuntu 24.04+    │  📋 BASH 5.0+   │  🐍 PYTHON 3.12+  │  📦 GIT 2.40+    │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│  LICENȚĂ         RESTRICTIVĂ    │  UNITĂȚI           14      │  ORE ESTIMATE       60+   │
│  VERSIUNE             4.0.0     │  SEMINARII          6      │  PROIECTE           23    │
│  STATUS               ACTIV     │  DIAGRAME PNG      27      │  SCRIPTURI        100+    │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

**by ing. dr. Antonio Clim** | Academia de Studii Economice București — CSIE  
Anul I, Semestrul 2 | 2024-2025

---

## Ce Găsești Aici

Kit-ul conține materialele pentru cursul de Sisteme de Operare: 14 unități de curs, 6 seminarii cu exerciții practice, și 23 de proiecte la trei niveluri de dificultate. Totul structurat pentru a putea lucra independent sau în laborator.

Bash-ul pare simplu la prima vedere — comenzi scurte, output instant — dar când încerci să automatizezi ceva real, brusc descoperi că `$?` nu face ce crezi, că pipe-urile pierd variabile, și că un spațiu greșit în `[ $var ]` îți strică tot scriptul. Am trecut prin asta cu fiecare generație de studenți, și kit-ul reflectă exact problemele pe care le-am văzut în practică.

O observație după câțiva ani de predat: studenții care-și notează comenzile și output-ul pe parcurs ajung mult mai repede la soluții funcționale. Nu pentru că ar fi mai deștepți, ci pentru că pot să revină la ce a funcționat și să compare cu ce nu merge. E o practică banală dar surprinzător de eficientă.

---

## Ce Vei Putea Face După Acest Curs

La final, vei avea o înțelegere solidă a modului în care funcționează un sistem de operare — nu doar ce butoane să apeși, ci de ce se întâmplă ce se întâmplă. Concret:

**Automatizare și scripting:** Vei scrie scripturi Bash care fac în 30 de secunde ce înainte făceai manual în 30 de minute. Backup-uri, procesare log-uri, deployment, rapoarte — lucruri care par plictisitoare devin satisfăcătoare când le automatizezi o dată și apoi funcționează singure.

**Debugging și diagnosticare:** Vei ști să folosești `strace`, `top`, `htop`, `lsof` pentru a înțelege de ce un program nu face ce trebuie. În loc să cauți orbește, vei putea urmări exact ce se întâmplă la nivel de sistem.

**Administrare sisteme:** Permisiuni, procese, servicii, cron jobs — vocabularul de bază al oricărui administrator de sistem. Chiar dacă nu vei lucra în sysadmin, vei înțelege ce fac colegii tăi devops când vorbesc despre "a da chmod 755" sau "a trimite SIGTERM".

**Fundament pentru specializări:** Cunoștințele de aici sunt punctul de plecare pentru mai multe direcții:

| Direcție | Ce folosești din acest curs |
|----------|----------------------------|
| DevOps / SRE | Scripting, procese, servicii, containere |
| Securitate informatică | Permisiuni, procese, audituri de sistem |
| Dezvoltare backend | IPC, threading, memorie virtuală |
| Embedded / IoT | Procese, scheduling, kernel |
| Cloud engineering | Virtualizare, containere, automatizare |
| Data engineering | Procesare text (grep/sed/awk), pipeline-uri |

Nu e nevoie să alegi acum — ideea e că fundamentele pe care le construiești aici te vor ajuta indiferent unde ajungi.

---

## De Ce Arată Cursul Așa Cum Arată

Câteva principii pe care le-am avut în minte când am structurat materialele:

**Nu există "gena programatorului."** Abilitatea de a scrie cod e dobândită prin practică deliberată, nu e un talent înnăscut cu care te naști sau nu. Patitsas și colegii au demonstrat în 2016 că doar 5.8% din distribuțiile de note în cursurile de informatică sunt bimodal — restul mitului "unii pot, alții nu" e profeție auto-împlinită.

**Începătorii nu sunt (neaparat) experți potențiali.** Au nevoie de abordări diferite, nu doar de mai mult timp. De aceea materialele includ Parsons Problems (reordonare cod), Peer Instruction (întrebări cu discuții în perechi), și Live Coding structurat — tehnici validate în cercetarea recentă din computing education.

**Erorile sunt oportunități, nu eșecuri.** Am normalizat greșeala în tot kit-ul. Fiecare programator a trecut prin aceleași bug-uri stupide — spațiul greșit în `[ $var ]`, uitatul de ghilimele, off-by-one în bucle. Când vezi că și instructorul greșește și repară în timp real, devine mai ușor să accepți că și tu vei greși.

**LLM-urile sunt tool-uri, nu adversari.** Studenții de azi au acces la ChatGPT, Claude, Gemini — n-are sens să facem cursuri care ignoră realitatea. Am inclus exerciții explicit "LLM-aware" unde trebuie să evaluezi ce generează AI-ul, nu doar să copiezi. Scopul e înțelegerea, nu finalizarea temei.

**Atenția funcționează în "sprints".** Cercetările din neuroștiință arată că atenția susținută pentru studenți e realistă în ferestre de 5-10 minute, nu 50. De aceea temele sunt structurate în micro-milestone-uri cu verificări imediate. Pauzele nu sunt pierdere de timp — incubația ajută la insight.

Dacă sună ciudat că un curs de Sisteme de Operare sunt referiri la neuroștiință și pedagogie: așa ar trebui să arate orice curs. Predatul tradițional — slide-uri citite monoton timp de două ore, cu studenții în rol pasiv — nu a funcționat niciodată bine, doar am acceptat colectiv că așa e normal. Nu e normal! E învățământ industrial, pe banda rulanta: eficient pentru a procesa oameni, ineficient pentru a-i învăța ceva.

Materialele de aici sunt rezultatul a ani de experimentare, testare, și iterare. Metodele de Peer Instruction, Productive Failure, Subgoal Labeling nu sunt găsite de mine — sunt validate în cercetare la SIGCSE, ICER, ITiCSE. Ce am făcut eu e să le aplic în contextul concret al cursului nostru și să văd ce funcționează cu studenții mei.

---

# PARTEA I: SETUP ȘI CONFIGURARE

Această secțiune acoperă tot ce trebuie să faci înainte de primul seminar. Fără un mediu funcțional, restul e (deocamdata) inutil.

---

## Pasul 0: Alege-ți Varianta de Instalare

Ai trei opțiuni principale. Recomandarea mea e WSL2 dacă ești pe Windows — e cel mai simplu și cel mai aproape de experiența Linux reală.

| Opțiune | Pentru cine | Avantaje | Dezavantaje |
|---------|-------------|----------|-------------|
| **WSL2** | Windows 10/11 | Rapid, integrat în Windows, fără reboot | Necesită Windows actualizat |
| **VirtualBox** | Orice OS | Izolare completă, snapshot-uri | Mai lent, consumă mai multe resurse |
| **Dual boot** | Utilizatori avansați | Performanță nativă | Risc la instalare, trebuie să repornești |

**Decizia rapidă:** Dacă ai Windows 10/11 recent, mergi pe WSL2. Dacă ai un Windows mai vechi sau vrei izolare completă, VirtualBox. Dual boot doar dacă știi ce faci.

---

## Pasul 1: Instalare WSL2 (Varianta Recomandată)

WSL2 a schimbat complet modul în care predau — acum studenții pot exersa Linux fără dual boot sau mașină virtuală separată.

### 1.1 Verifică Cerințele

**Windows 10:** Trebuie versiunea 2004 sau mai nouă (Build 19041+)  
**Windows 11:** Orice versiune merge

Verifică versiunea ta:

```powershell
# POWERSHELL (Windows) - rulează ca utilizator normal
winver
```

Se deschide o fereastră cu informații. Caută numărul de Build.

### 1.2 Verifică Virtualizarea

Deschide Task Manager (`Ctrl+Shift+Esc`), tab-ul Performance, click pe CPU. În dreapta jos trebuie să vezi:

```
Virtualization: Enabled
```

Dacă scrie "Disabled", trebuie să activezi virtualizarea din BIOS. Procedura diferă în funcție de producătorul plăcii de bază — caută "[marca laptop/PC] enable virtualization BIOS".

### 1.3 Activează WSL2

Deschide PowerShell **ca Administrator** (click dreapta pe Start → Terminal (Admin) sau Windows PowerShell (Admin)):

```powershell
# POWERSHELL (Administrator)
# Activează Windows Subsystem for Linux
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

# Activează Virtual Machine Platform
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
```

**RESTARTEAZĂ calculatorul.** Serios, fără restart nu merge.

### 1.4 Instalează Ubuntu

După restart, deschide din nou PowerShell ca Administrator:

```powershell
# POWERSHELL (Administrator)
# Descarcă și instalează actualizarea pentru kernel-ul WSL2
wsl --update

# Setează WSL2 ca versiune implicită
wsl --set-default-version 2

# Instalează Ubuntu 24.04 LTS
wsl --install -d Ubuntu-24.04
```

Descărcarea durează 5-15 minute în funcție de internet. La final se deschide automat o fereastră nouă cu Ubuntu.

### 1.5 Creează-ți Contul Linux

Ubuntu îți cere să creezi un utilizator. 

**Username:** Numele tău de familie, cu litere mici, fără diacritice  
Exemple: `popescu`, `ionescu`, `stefanescu`

**Parolă:** `stud` (pentru consistență în laborator)

Când scrii parola, **nu vezi nimic pe ecran** — nici stele, nici puncte. E normal pentru Linux. Tastează și apasă Enter.

### 1.6 Actualizează Sistemul

Prima comandă pe care o rulezi în orice sistem Linux proaspăt instalat:

```bash
# BASH (Ubuntu) - fundal negru
sudo apt update && sudo apt upgrade -y
```

`sudo` = "superuser do" — rulează comanda cu privilegii de administrator  
`apt` = package manager-ul din Debian/Ubuntu  
`-y` = răspunde automat "yes" la întrebări

Durează câteva minute. Ia o cafea.

### 1.7 Instalează Pachetele Necesare

```bash
# BASH (Ubuntu)
# Pachete pentru seminarii
sudo apt install -y \
    git \
    vim nano \
    tree htop ncdu \
    shellcheck \
    python3 python3-pip python3-venv \
    build-essential \
    openssh-server \
    curl wget \
    figlet lolcat cowsay fortune \
    pv dialog \
    jq bc

# Verifică instalarea
echo "Verificare instalare..."
for cmd in git vim nano tree htop python3 shellcheck ssh curl wget; do
    command -v "$cmd" >/dev/null && echo "  [OK] $cmd" || echo "  [LIPSĂ] $cmd"
done
```

### 1.8 Configurează SSH (pentru PuTTY și WinSCP)

SSH îți permite să te conectezi la Ubuntu din Windows folosind PuTTY sau să transferi fișiere cu WinSCP.

```bash
# BASH (Ubuntu)
# Pornește serviciul SSH
sudo service ssh start

# Verifică că rulează
sudo service ssh status

# Află adresa IP
hostname -I
```

Notează adresa IP (probabil `172.x.x.x`) — o vei folosi în PuTTY.

### 1.9 Setează Hostname-ul

Pentru identificare în laborator, setează un hostname descriptiv:

```bash
# BASH (Ubuntu)
# Înlocuiește AP_1001_A cu grupa și poziția ta
# Format: [Specializare]_[Grupa]_[Litera PC-ului]
# Exemplu: AP_1029_B pentru Informatică Economică (Aplicată), grupa 1029, PC-ul B

sudo hostnamectl set-hostname AP_1029_A
```

Închide și redeschide terminalul pentru a vedea schimbarea.

---

## Pasul 2: Structura de Foldere Recomandată

O structură bună de foldere te scapă de haos pe parcursul semestrului. Am văzut studenți cu toate fișierele într-un singur folder — găseau `script.sh`, `script2.sh`, `script_final.sh`, `script_final_v2.sh` și nu mai știau care e care.

### 2.1 Creează Structura de Bază

```bash
# BASH (Ubuntu)
# Creează structura principală
mkdir -p ~/so-lab/{cursuri,seminarii,teme,proiecte,experimente,backup}

# Creează subdirectoare pentru fiecare seminar
for i in $(seq -w 1 6); do
    mkdir -p ~/so-lab/seminarii/SEM0$i/{exercitii,demo,notite}
done

# Creează subdirectoare pentru teme
for i in $(seq -w 1 7); do
    mkdir -p ~/so-lab/teme/TEMA0$i
done

# Creează subdirectoare pentru cursuri
for i in $(seq -w 1 14); do
    mkdir -p ~/so-lab/cursuri/CURS$i/{notite,scripturi}
done

# Vizualizează structura
tree -L 3 ~/so-lab/
```

Ar trebui să vezi:

```
/home/numeletau/so-lab/
├── backup/
├── cursuri/
│   ├── CURS01/
│   │   ├── notite/
│   │   └── scripturi/
│   ├── CURS02/
│   │   ├── notite/
│   │   └── scripturi/
│   └── ... (până la CURS14)
├── experimente/
├── proiecte/
├── seminarii/
│   ├── SEM01/
│   │   ├── demo/
│   │   ├── exercitii/
│   │   └── notite/
│   ├── SEM02/
│   │   └── ...
│   └── ... (până la SEM06)
└── teme/
    ├── TEMA01/
    ├── TEMA02/
    └── ... (până la TEMA07)
```

### 2.2 De Ce Această Structură

| Folder | Ce pui acolo | De ce separat |
|--------|--------------|---------------|
| `cursuri/` | Notițe și scripturi din cursuri | Teoria, separată de practică |
| `seminarii/` | Exerciții din laborator | Fiecare seminar e independent |
| `teme/` | Temele de casă | Le predai, nu le amesteci |
| `proiecte/` | Proiectul de semestru | Cod mai mare, structură diferită |
| `experimente/` | Teste, încercări | Loc pentru a "sparge lucruri" |
| `backup/` | Copii de siguranță | Înainte de modificări majore |

### 2.3 Creează Directorul pentru Înregistrări de Teme

Temele se înregistrează cu un script special (mai multe detalii în secțiunea despre teme):

```bash
# BASH (Ubuntu)
mkdir -p ~/HOMEWORKS
```

---

## Pasul 3: Configurare Git

Git e necesar pentru a clona kit-ul și pentru versionarea propriilor scripturi. Dacă nu ai folosit Git până acum, e momentul să înveți — e o abilitate pe care o vei folosi în orice job de programare.

### 3.1 Configurare Inițială

```bash
# BASH (Ubuntu)
# Setează identitatea ta (înlocuiește cu datele tale)
git config --global user.name "Popescu Ion"
git config --global user.email "ion.popescu@student.ase.ro"

# Setări utile
git config --global init.defaultBranch main
git config --global core.editor "nano"
git config --global pull.rebase false

# Verifică configurația
git config --list
```

### 3.2 Clonează Kit-ul ROso

```bash
# BASH (Ubuntu)
cd ~/so-lab

# Clonează repository-ul
git clone https://github.com/antonioclim/ROso.git

# Verifică conținutul
ls -la ROso/
```

Dacă repository-ul e privat sau ai primit materialele pe altă cale, copiază-le manual în `~/so-lab/ROso/`.

### 3.3 Creează Repository-uri pentru Teme

Fiecare temă ar trebui să aibă propriul repository (sau cel puțin propriul branch). Asta te ajută să:
- Revii la versiuni anterioare dacă strici ceva
- Vezi ce ai modificat și când
- Demonstrezi că ai lucrat progresiv (nu totul în ultima noapte)

```bash
# BASH (Ubuntu)
# Pentru fiecare temă, inițializează un repo Git
cd ~/so-lab/teme/TEMA01
git init
echo "# Tema 01 - SO" > README.md
git add README.md
git commit -m "Initial commit"

# Creează .gitignore
cat > .gitignore << 'EOF'
# Fișiere temporare
*.tmp
*.bak
*~
*.swp

# Output-uri
*.log
*.out

# Cache Python
__pycache__/
*.pyc

# Fișiere de sistem
.DS_Store
Thumbs.db
EOF

git add .gitignore
git commit -m "Add .gitignore"
```

### 3.4 Workflow Git Recomandat pentru Teme

```bash
# BASH (Ubuntu)
# 1. Înainte să începi lucrul
cd ~/so-lab/teme/TEMA01
git status

# 2. După fiecare milestone important
git add script.sh
git commit -m "Implementare funcție de backup"

# 3. La final
git add .
git commit -m "Temă completă - toate cerințele implementate"

# 4. Vezi istoricul
git log --oneline
```

**Mesaje de commit bune:**
- `"Adaugă funcția de validare input"`
- `"Repară bug în procesarea fișierelor cu spații"`
- `"Optimizează bucla principală"`

**Mesaje de commit proaste:**
- `"update"`
- `"asdfasdf"`
- `"final final FINAL"`

---

## Pasul 4: Verifică Instalarea

Rulează acest script de verificare pentru a te asigura că totul e în regulă:

```bash
# BASH (Ubuntu)
cat << 'EOF' > ~/verify_setup.sh
#!/usr/bin/env bash
# Script de verificare pentru kit-ul SO

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║          VERIFICARE MEDIU DE LUCRU - SO ASE                    ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Informații sistem
echo "▶ SISTEM"
echo "  Hostname: $(hostname)"
echo "  User: $(whoami)"
echo "  Ubuntu: $(lsb_release -ds 2>/dev/null || echo 'N/A')"
echo "  Kernel: $(uname -r)"
echo "  Bash: $(bash --version | head -1 | cut -d' ' -f4)"
echo ""

# Rețea
echo "▶ REȚEA"
echo "  IP: $(hostname -I 2>/dev/null | awk '{print $1}' || echo 'N/A')"
if ping -c 1 -W 2 google.com >/dev/null 2>&1; then
    echo "  Internet: OK"
else
    echo "  Internet: FĂRĂ CONEXIUNE"
fi
echo ""

# Comenzi necesare
echo "▶ COMENZI NECESARE"
CMDS="bash git nano vim python3 gcc shellcheck ssh tree htop awk sed grep find tar curl wget"
for cmd in $CMDS; do
    if command -v "$cmd" >/dev/null 2>&1; then
        printf "  [OK]    %s\n" "$cmd"
    else
        printf "  [LIPSĂ] %s\n" "$cmd"
    fi
done
echo ""

# Comenzi opționale
echo "▶ COMENZI OPȚIONALE (pentru demo-uri)"
OPT_CMDS="figlet lolcat cowsay fortune pv dialog jq"
for cmd in $OPT_CMDS; do
    if command -v "$cmd" >/dev/null 2>&1; then
        printf "  [OK]    %s\n" "$cmd"
    else
        printf "  [--]    %s (opțional)\n" "$cmd"
    fi
done
echo ""

# Structura de foldere
echo "▶ STRUCTURA DE FOLDERE"
DIRS="so-lab so-lab/cursuri so-lab/seminarii so-lab/teme so-lab/proiecte HOMEWORKS"
for dir in $DIRS; do
    if [ -d ~/"$dir" ]; then
        printf "  [OK]    ~/%s\n" "$dir"
    else
        printf "  [LIPSĂ] ~/%s\n" "$dir"
    fi
done
echo ""

# Git
echo "▶ GIT"
if git config user.name >/dev/null 2>&1; then
    echo "  User: $(git config user.name)"
    echo "  Email: $(git config user.email)"
else
    echo "  [!] Git nu e configurat (rulează git config)"
fi
echo ""

# SSH
echo "▶ SSH"
if systemctl is-active --quiet ssh 2>/dev/null || service ssh status 2>/dev/null | grep -q running; then
    echo "  Server SSH: ACTIV"
else
    echo "  Server SSH: INACTIV (rulează: sudo service ssh start)"
fi
echo ""

echo "════════════════════════════════════════════════════════════════"
echo "Verificare completă!"
echo "════════════════════════════════════════════════════════════════"
EOF

chmod +x ~/verify_setup.sh
~/verify_setup.sh
```

---

## Pasul 5: Instalare VirtualBox (Alternativă)

Dacă WSL2 nu funcționează sau preferi izolare completă, folosește VirtualBox.

### 5.1 Descarcă și Instalează VirtualBox

1. Descarcă de la https://www.virtualbox.org/wiki/Downloads
2. Alege "Windows hosts" (sau varianta pentru OS-ul tău)
3. Rulează installer-ul cu setările implicite

### 5.2 Descarcă Ubuntu 24.04 LTS

1. Descarcă ISO-ul de la https://ubuntu.com/download/desktop
2. Alege "Ubuntu 24.04 LTS"
3. Salvează fișierul `.iso` (circa 5 GB)

### 5.3 Creează Mașina Virtuală

1. Deschide VirtualBox → New
2. Name: `Ubuntu-SO`
3. Type: Linux, Version: Ubuntu (64-bit)
4. Memory: minim 4096 MB (4 GB), recomandat 8192 MB
5. Hard disk: Create a virtual hard disk now
   - VDI, Dynamically allocated
   - Minim 25 GB, recomandat 50 GB

### 5.4 Configurează Mașina

Înainte de a porni, ajustează setările (Settings):

**System → Processor:**
- Processors: 2-4 (în funcție de câte core-uri ai)

**Display → Screen:**
- Video Memory: 128 MB
- Enable 3D Acceleration: bifat (dacă merge)

**Storage:**
- Controller: IDE → Empty → click pe iconița de disc → Choose a disk file
- Selectează ISO-ul Ubuntu descărcat

### 5.5 Instalează Ubuntu

1. Start → urmează wizard-ul de instalare
2. Install Ubuntu → Normal installation
3. Username și parolă: la fel ca la WSL2

După instalare, instalează Guest Additions pentru rezoluție și clipboard partajat:

```bash
# BASH (Ubuntu în VirtualBox)
sudo apt update
sudo apt install -y virtualbox-guest-utils virtualbox-guest-x11
sudo reboot
```

### 5.6 Snapshot înainte de Laborator

VirtualBox are o funcție excelentă: snapshot-uri. Înainte de fiecare laborator, fă un snapshot:

1. Machine → Take Snapshot
2. Name: "Înainte de SEM03" (sau ce seminar urmează)

Dacă strici ceva, poți reveni instant la starea anterioară.

---

# PARTEA II: STRUCTURA KIT-ULUI

---

## Vedere de Ansamblu

```
ROso/
├── 001initialSTEPs/          # ← PASUL 1: Instalare și configurare
├── 002initialSTEPs/          # ← PASUL 2: Ghiduri pentru studenți  
├── 003initialSTEPs/          # ← PASUL 3: Ghiduri tehnice
│
├── SO_curs/                  # Materialele de curs (teorie)
│   └── SO_curs01..14/        #   14 unități tematice
│
├── SEM01..06/                # Materialele de seminar (practică)
│   └── [structură detaliată mai jos]
│
├── SEM-PROJ/                 # Proiecte de semestru
│   ├── EASY/                 #   5 proiecte, 15-20 ore
│   ├── MEDIUM/               #   15 proiecte, 25-35 ore
│   └── ADVANCED/             #   3 proiecte, 40-50 ore
│
└── 000SUPPL/                 # Materiale suplimentare
    ├── diagrame_png/         #   Diagrame pre-renderizate
    └── Exercitii_Examene_*.md
```

---

## Folder-ul 001initialSTEPs — Instalare

Aici găsești ghidurile detaliate de instalare:

| Fișier | Conținut |
|--------|----------|
| `GHID_WSL2_Ubuntu2404_INCEPATORI_SO_ASE.md` | Ghid pas-cu-pas pentru WSL2 |
| `GHID_WSL2_Ubuntu2404_INTERACTIV.html` | Versiune interactivă (deschide în browser) |
| `GHID_VirtualBox_Ubuntu2404_INCEPATORI_SO_ASE.md` | Ghid pentru VirtualBox |
| `GHID_VirtualBox_Ubuntu2404_INTERACTIV.html` | Versiune interactivă |
| `TC0.A_RO-TC laborator 0C_*.pdf` | Fișa de laborator 0 (prerequisite) |

Dacă ai urmat pașii din secțiunea anterioară, ai parcurs deja mare parte din conținutul acestor ghiduri.

---

## Folder-ul 002initialSTEPs — Ghiduri pentru Studenți

Conține instrucțiuni pentru predarea și înregistrarea temelor:

| Fișier | Conținut |
|--------|----------|
| `GHID_STUDENT_RO.md` | Cum să folosești scriptul de înregistrare |
| `record_homework_tui_RO.py` | Script Python cu interfață text pentru teme |
| `record_homework_RO.sh` | Versiune Bash (alternativă) |

### Cum Funcționează Înregistrarea Temelor

Temele nu se predau ca fișiere — se înregistrează sesiuni de terminal. Asta înseamnă că profesorul vede exact ce comenzi ai dat și în ce ordine.

```bash
# BASH (Ubuntu)
# Descarcă scriptul
cd ~/HOMEWORKS
wget -O record_homework_tui_RO.py "https://drive.google.com/uc?export=download&id=1YLqNamLCdz6OzF6hlcPr1hr738DIaSYz"
chmod +x record_homework_tui_RO.py

# Rulează
python3 record_homework_tui_RO.py
```

La prima rulare, scriptul instalează dependențele necesare (`rich`, `questionary`, `asciinema`). Apoi îți cere:
- Nume, prenume, grupă
- Numărul temei (ex: `03a`)

Începe înregistrarea. Faci tema. Când termini, tastezi `STOP_tema` sau `Ctrl+D`. Scriptul generează un fișier `.cast` semnat criptografic și îl încarcă pe server.

De ce înregistrare, nu fișiere?
- Nu poți copia de la colegi (semnătura e unică)
- Se vede procesul de gândire, nu doar rezultatul
- Greșelile și corecțiile sunt vizibile (și ok!)

---

## Folder-ul 003initialSTEPs — Ghiduri Tehnice

Conține ghiduri pentru scripting și debugging:

| Fișier | Conținut |
|--------|----------|
| `00_Cum_se_utilizeaza_kitul.md` | Prezentare generală a kit-ului |
| `01_Ghid_Scripting_Bash.md` | Best practices pentru scripturi Bash |
| `02_Ghid_Scripting_Python_pentru_SO.md` | Python în context OS |
| `03_Ghid_Observabilitate_si_Debugging.md` | Cum să înțelegi ce face sistemul |
| `04_Idei_de_proiecte.md` | Inspirație pentru proiecte |
| `05_Ghid_PlantUML.md` | Cum să generezi diagrame |

### Extras din Ghidul de Scripting Bash

Cele mai importante reguli:

**1. Shebang și mod strict**
```bash
#!/usr/bin/env bash
set -euo pipefail
```

**2. Ghilimele peste tot**
```bash
# GREȘIT
for f in *.txt; do
    echo $f        # Bug dacă numele are spații
done

# CORECT
for f in ./*.txt; do
    [[ -e "$f" ]] || continue
    echo "$f"
done
```

**3. Funcții mici, testabile**
```bash
ensure_cmd() {
    command -v "$1" >/dev/null 2>&1 || {
        echo "Eroare: lipsește comanda $1" >&2
        exit 1
    }
}

ensure_cmd git
ensure_cmd python3
```

**4. Cleanup automat**
```bash
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
```

---

## Structura Unui Seminar (SEM01-06)

Toate seminariile au aceeași organizare:

```
SEM0X/
├── README.md                    # Prezentare generală
│
├── docs/                        # Documentație
│   ├── S0X_00_ANALIZA_*.md      #   Plan pedagogic
│   ├── S0X_01_GHID_INSTRUCTOR   #   Pentru instructor
│   ├── S0X_02_MATERIAL_PRINCIPAL #   Materialul central
│   ├── S0X_03_PEER_INSTRUCTION  #   Întrebări MCQ
│   ├── S0X_04_PARSONS_PROBLEMS  #   Reordonare cod
│   ├── S0X_05_LIVE_CODING_*     #   Script live coding
│   ├── S0X_06_EXERCITII_SPRINT  #   Exerciții scurte
│   ├── S0X_07_LLM_AWARE_*       #   Exerciții cu AI
│   ├── S0X_08_DEMO_*            #   Demo-uri spectaculoase
│   ├── S0X_09_CHEAT_SHEET_*     #   Rezumat 1 pagină
│   └── S0X_10_AUTOEVALUARE_*    #   Reflecție
│
├── scripts/
│   ├── bash/                    #   Setup, quiz, validare
│   ├── demo/                    #   Scripturi demonstrative
│   └── python/                  #   Autograder, generatoare
│
├── prezentari/                  #   Slide-uri HTML
├── resurse/                     #   Fișiere de test
├── teme/                        #   Cerințe și rubrici
└── teste/                       #   Teste automatizate
```

### Cum Să Parcurgi Un Seminar

```bash
# BASH (Ubuntu)
cd ~/so-lab/ROso/SEM02

# 1. Citește prezentarea generală
less README.md

# 2. Parcurge materialul principal
less docs/S02_02_MATERIAL_PRINCIPAL.md

# 3. Rulează demo-urile
chmod +x scripts/demo/*.sh
./scripts/demo/S02_01_hook_demo.sh

# 4. Testează-ți cunoștințele
./scripts/bash/S02_02_quiz_interactiv.sh

# 5. Fă exercițiile
less docs/S02_06_EXERCITII_SPRINT.md

# 6. Citește cerințele temei
less teme/S02_01_TEMA.md
```

---

# PARTEA III: CONȚINUT DETALIAT

---

## Cursurile (SO_curs01-14)

Am structurat cursurile urmând ordinea clasică din Silberschatz și Tanenbaum, cu ajustări bazate pe ce funcționează practic.

| Curs | Temă | Concepte Cheie | Hook |
|------|------|----------------|------|
| 01 | Introducere în SO | Rol OS, arhitecturi kernel, evoluție | De ce calculatorul nu e doar hardware? |
| 02 | System Calls | Mecanismul syscall, strace, API vs ABI | Ce se întâmplă când tastezi `ls`? |
| 03 | Procese | Stări, fork(), exec(), Copy-on-Write | Cum face Unix copii fără să copieze? |
| 04 | Scheduling | FCFS, SJF, RR, MLFQ, CFS | De ce unele programe "sar rândul"? |
| 05 | Thread-uri | Modele, pthread, race conditions | De ce e greu să faci 2 lucruri simultan? |
| 06 | Sincronizare | Mutex, semafoare, monitoare | Cum împiedici haosul când toți vor aceeași resursă? |
| 07 | IPC | Pipes, sockets, shared memory | Cum vorbesc procesele între ele? |
| 08 | Deadlock | Condiții Coffman, Banker's algorithm | De ce se blochează uneori totul? |
| 09 | Memorie Virtuală | Spațiu adrese, paginare | Cum poate un proces folosi "mai multă" memorie decât ai? |
| 10 | Paginare | TLB, algoritmi de înlocuire | De ce contează cache-ul atât de mult? |
| 11 | File Systems I | Inode, hard/soft links | Ce sunt acele numere din `ls -i`? |
| 12 | File Systems II | Journaling, ext4, RAID | De ce nu pierzi date când se oprește curentul? |
| 13 | Securitate | Permisiuni, ACL, capabilities | De ce nu poți șterge orice fișier? |
| 14 | Virtualizare | VM vs containere, namespaces | Cum rulează Docker într-un kernel partajat? |

---

## Seminariile (SEM01-06)

### SEM01-02: Shell Basics

Pornim de la zero: navigare, variabile, globbing. Pare banal, dar diferența dintre `$var` și `"$var"` produce bug-uri și în scripturi scrise de oameni cu experiență.

**Ce vei învăța:**
- Navigare (`cd`, `ls`, `pwd`, `tree`)
- Variabile locale și de mediu
- Quoting și escape sequences
- File globbing (`*`, `?`, `[abc]`, `{a,b,c}`)
- Configurare `.bashrc`

**Provocare de gândire:** De ce există atâtea modalități de a face quoting în Bash (`'...'`, `"..."`, `$'...'`, `$"..."`)?

Răspunsul scurt: compatibilitate istorică. Shell-ul lui Thompson din 1971 nu avea variabile. Bourne Shell din 1979 a adăugat variabile, iar ghilimelele simple și duble au căpătat sensuri diferite. Apoi au venit extensiile ANSI-C (`$'...'`) în Bash pentru escape sequences ca `\n`. Fiecare adăugare a trebuit să fie compatibilă cu scripturile existente. Rezultatul e haotic, dar funcționează.

---

### SEM03-04: Pipeline Master

Ken Thompson a implementat pipe-urile într-o singură noapte în 1973, la insistențele lui Doug McIlroy. McIlroy voia ca programele să se poată conecta "ca un furtun de grădină". Ideea a definit Unix.

**Ce vei învăța:**
- Operatori de control (`;`, `&&`, `||`, `&`)
- Redirecționare I/O (`>`, `>>`, `<`, `2>`, `&>`)
- Pipes și tee
- Filtre (`sort`, `uniq`, `cut`, `paste`, `tr`, `wc`)
- Bucle (`for`, `while`, `until`)

**Provocare de gândire:** De ce `cat file | grep pattern` e considerat un "anti-pattern" (Useless Use of Cat)?

Comanda `grep pattern file` face același lucru fără procesul extra. Dar nu e întotdeauna rău — câteodată `cat` face codul mai clar, mai ales în pipeline-uri lungi. Regula practică: dacă viteza contează, evită; dacă citibilitatea contează, poate păstra.

---

### SEM05-06: Find & Permissions

`find` e probabil comanda cu cele mai multe opțiuni din Unix. Prima versiune avea o sintaxă complet diferită de ce folosim azi — au schimbat-o pentru că era prea complicată. Și tot a rămas complicată.

**Ce vei învăța:**
- `find` cu criterii multiple și acțiuni
- `xargs` pentru procesare în paralel
- Permisiuni: `chmod`, `chown`, `umask`
- Permisiuni speciale: SUID, SGID, Sticky bit
- `cron` pentru automatizare

**Provocare de gândire:** De ce există Sticky bit pe `/tmp`?

Fără Sticky bit, oricine poate șterge fișierele altora dintr-un director cu permisiuni de scriere pentru toți. Sticky bit (notația `t` în `drwxrwxrwt`) permite doar proprietarului fișierului să-l șteargă. A fost inventat pentru directoare partajate ca `/tmp`. Ironia: inițial "Sticky" însemna că programul rămânea în memorie după execuție (pentru performanță). Sensul s-a schimbat complet.

---

### SEM07-08: Text Processing

Expresiile regulate au fost inventate de Stephen Kleene în 1951 pentru a descrie limbaje formale. Ken Thompson le-a adus în informatică în 1968 când a implementat un editor de text (precursorul `ed`). `grep` înseamnă literalmente "**g**lobal **r**egular **e**xpression **p**rint" — o comandă din `ed`.

**Ce vei învăța:**
- Expresii regulate: BRE și ERE
- `grep` pentru căutare
- `sed` pentru transformări
- `awk` pentru procesare coloane

**Provocare de gândire:** De ce `awk` se numește așa?

Aho, Weinberger, Kernighan — inițialele creatorilor. Da, același Kernighan de la "The C Programming Language". Awk a fost creat în 1977 la Bell Labs, contemporan cu primul manual de C.

---

### SEM09-10: Advanced Scripting

După ce știi comenzile de bază, e timpul să le combini în scripturi care se comportă decent și când lucrurile merg prost.

**Ce vei învăța:**
- Funcții și biblioteci
- Arrays indexate și asociative
- Signal handling cu `trap`
- Debugging și profiling
- Best practices

**Provocare de gândire:** De ce Bash arrays sunt indexate de la 0, dar `$@` e indexat de la 1?

Parametrii poziționali (`$1`, `$2`, etc.) existau înainte de arrays. Când au adăugat arrays în Bash 2.0 (1996), au ales indexare de la 0 pentru compatibilitate cu C. Dar n-au putut schimba `$1` în `$0` (care înseamnă deja numele scriptului). Rezultatul: inconsistență pe care trebuie s-o memorezi.

---

### SEM11-12: CAPSTONE Projects

Integrare. Proiecte care combină tot: Monitor, Backup, Deployer.

**Ce vei construi:**
- System Monitor cu dashboard în terminal
- Sistem de backup incremental
- Tool de deployment automat

---

# PARTEA IV: PROIECTE DE SEMESTRU

---

## Alegerea Proiectului

Ai 23 de proiecte la trei niveluri. Sfatul meu: nu alege cel mai ușor doar să termini — alege ceva care te interesează sau care te-ar ajuta în viitor.

### Nivel EASY (5 proiecte, 15-20 ore)

Doar Bash, fără dependențe externe. Bune pentru consolidare.

| Cod | Proiect | Descriere |
|-----|---------|-----------|
| E01 | File System Auditor | Scanează și raportează structura directoarelor |
| E02 | Log Analyzer | Parsează și rezumă fișiere de log |
| E03 | Bulk File Organizer | Sortează fișiere după extensie/dată/dimensiune |
| E04 | System Health Reporter | Generează rapoarte despre starea sistemului |
| E05 | Config File Manager | Backup și versionare pentru configurări |

### Nivel MEDIUM (15 proiecte, 25-35 ore)

Bash cu opțiune de integrare Kubernetes pentru bonus.

| Cod | Proiect | Descriere |
|-----|---------|-----------|
| M01 | Incremental Backup | Backup-uri care salvează doar ce s-a schimbat |
| M02 | Process Monitor | Monitorizează ciclul de viață al proceselor |
| M03 | Service Watchdog | Repornește automat servicii căzute |
| M04 | Network Scanner | Detectează porturi deschise și servicii |
| M05 | Deployment Pipeline | Automatizează deploy-ul aplicațiilor |
| M06 | Resource Historian | Istoricul utilizării resurselor |
| M07 | Security Audit | Framework pentru audituri de securitate |
| M08 | Disk Manager | Gestionare spațiu pe disk |
| M09 | Task Scheduler | Manager pentru task-uri programate |
| M10 | Process Tree Analyzer | Analizează ierarhia proceselor |
| M11 | Memory Forensics | Tool pentru analiză memorie |
| M12 | File Integrity Monitor | Detectează modificări neautorizate |
| M13 | Log Aggregator | Centralizează log-uri din mai multe surse |
| M14 | Config Manager | Gestionare configurări multiple medii |
| M15 | Parallel Executor | Execuție paralelă de task-uri |

### Nivel ADVANCED (3 proiecte, 40-50 ore)

Bash + componente în C.

| Cod | Proiect | Descriere |
|-----|---------|-----------|
| A01 | Mini Job Scheduler | Scheduler simplificat în stil cron |
| A02 | Shell Extension | Extensii pentru bash |
| A03 | Distributed File Sync | Sincronizare fișiere între mașini |

---

## Structura Recomandată pentru Proiecte

```bash
# BASH (Ubuntu)
mkdir -p ~/so-lab/proiecte/M05_Deployment_Pipeline/{src,tests,docs,config}
cd ~/so-lab/proiecte/M05_Deployment_Pipeline

# Inițializează git
git init

# Creează structura
cat > README.md << 'EOF'
# M05 - Deployment Pipeline

## Descriere
[Ce face proiectul]

## Cerințe
- Bash 5.0+
- Git
- [alte dependențe]

## Instalare
```bash
chmod +x src/deploy.sh
```

## Utilizare
```bash
./src/deploy.sh --help
```

## Structura
```
├── src/           # Cod sursă
├── tests/         # Teste
├── docs/          # Documentație
├── config/        # Fișiere de configurare
└── README.md
```

## Autor
[Numele tău] - [grupa]
EOF

# Creează .gitignore
cat > .gitignore << 'EOF'
*.log
*.tmp
*.bak
__pycache__/
.env
EOF

git add .
git commit -m "Initial project structure"
```

---

# PARTEA V: PROVOCĂRI ȘI ÎNTREBĂRI DESCHISE

---

## Lucruri pe Care Încă Nu Le-am Rezolvat Complet

Predarea sistemelor de operare are câteva probleme pentru care nu există soluții perfect satisfăcătoare. Le menționez pentru că onestitatea e mai valoroasă decât iluzia că totul e rezolvat.

### Problema Abstractizării vs. Detaliului

Studenții trebuie să înțeleagă cum funcționează un sistem de operare, dar:
- Dacă intrăm în prea multe detalii, se pierd în complexitate
- Dacă rămânem la nivel înalt, nu înțeleg cu adevărat ce se întâmplă

Nu am găsit echilibrul perfect. Încerc să alternez: o sesiune de "big picture", o sesiune de "deep dive" pe un concept specific.

### Problema LLM-urilor

Studenții pot genera cod Bash cu ChatGPT. Cum evaluezi dacă au înțeles sau doar au copiat?

Soluția actuală: exerciții LLM-aware unde trebuie să evaluezi codul generat, să identifici bug-uri, să explici ce face. Funcționează parțial — unii tot copiază explicațiile. E un arms race pe care nu-l vom câștiga complet. Cel puțin însă putem pune întrebări mai bune.

### Problema Mediilor de Lucru Diferite

Unii studenți au laptopuri noi, alții au calculatoare din 2015. Unii au Windows, alții macOS, câțiva Linux. WSL2 a ajutat enorm, dar tot apar cazuri ciudate.

Soluția parțială: ghiduri detaliate, scripturi de verificare, VirtualBox ca plan B. Nu e perfect.

---

## Întrebări la Care Nu Avem Răspuns Complet

Acestea sunt întrebări legitime din computing education research pe care cercetătorii încă le dezbat:

**1. Cât cod trebuie să scrie un student pentru a înțelege un concept?**

Nu există un număr magic. Unii înțeleg din 10 linii, alții au nevoie de 100. Cercetările sugerează că "productive struggle" (efortul productiv) contează mai mult decât cantitatea, dar e greu de cuantificat.

**2. Feedback-ul imediat ajută sau dăunează pe termen lung?**

Paradoxul lui Bjork: feedback-ul întârziat poate duce la învățare mai bună pe termen lung, deși se simte mai greu pe moment. Dar cât de întârziat? Cercetările nu dau un răspuns clar.

**3. Cum predai debugging?**

E o abilitate diferită de scrierea codului, dar rareori e predată explicit. Am încercat să includ erori deliberate în live coding, dar nu știu dacă e suficient.

---

## Exerciții de Gândire Critică

Pentru fiecare seminar, câteva întrebări la care să te gândești:

**SEM01-02:**
- De ce a ales Unix să trateze totul ca fișier (inclusiv dispozitive)?
- Ce s-ar fi întâmplat dacă variabilele de mediu nu ar exista?

**SEM03-04:**
- De ce a fost filozofia Unix "do one thing well" atât de influentă?
- Ce dezavantaje are această abordare?

**SEM05-06:**
- Permisiunile Unix au 50+ ani. Ce le-ar înlocui dacă am proiecta azi de la zero?
- De ce SUID e considerat un risc de securitate, dar tot există?

**SEM07-08:**
- De ce expresiile regulate au o sintaxă atât de criptică?
- Ar fi fost mai bine dacă `grep`, `sed`, `awk` ar fi fost un singur tool?

**SEM09-10:**
- De ce Bash nu are typing static? Ar fi mai bun dacă ar avea?
- Shell scripting ar trebui înlocuit cu Python pentru automatizare?

---

# PARTEA VI: TROUBLESHOOTING DETALIAT

---

## Probleme la Instalare WSL2

### "WSL 2 requires an update to its kernel component"

```powershell
# POWERSHELL (Administrator)
wsl --update
# Restartează după actualizare
```

### "Error: 0x80370102" sau "Please enable the Virtual Machine Platform"

Virtualizarea nu e activată în BIOS. Procedura:

1. Restartează calculatorul
2. Când pornește, apasă rapid tasta pentru BIOS:
   - **Dell:** F2 sau F12
   - **HP:** F10 sau Esc
   - **Lenovo:** F1 sau F2
   - **ASUS:** F2 sau Del
   - **Acer:** F2 sau Del
3. Caută "Virtualization Technology", "VT-x", "AMD-V" sau "SVM"
4. Schimbă din Disabled în Enabled
5. Salvează (de regulă F10) și ieși

### "Error: 0x80370114" — nu se poate porni mașina virtuală

Hyper-V sau altă tehnologie de virtualizare poate fi în conflict. Verifică:

```powershell
# POWERSHELL (Administrator)
# Dezactivează Hyper-V dacă e activat și nu-l folosești
dism.exe /Online /Disable-Feature:Microsoft-Hyper-V

# SAU activează-l complet pentru WSL2
dism.exe /Online /Enable-Feature /All /FeatureName:Microsoft-Hyper-V
```

### WSL se deschide dar nu răspunde

```powershell
# POWERSHELL
# Oprește complet WSL
wsl --shutdown

# Verifică starea
wsl --status

# Repornește
wsl
```

---

## Probleme în Terminal

### "Permission denied" la rularea scripturilor

```bash
# BASH (Ubuntu)
# Cauza 1: Scriptul nu are permisiunea de execuție
chmod +x script.sh
./script.sh

# Cauza 2: Fișierul e pe partiție Windows montată fără exec
# Soluție: mută fișierul în home Linux
cp /mnt/c/Users/.../script.sh ~/
chmod +x ~/script.sh
~/script.sh

# Cauza 3: Shebang greșit sau lipsă
# Verifică prima linie:
head -1 script.sh
# Trebuie să fie: #!/usr/bin/env bash sau #!/bin/bash
```

### Caractere românești afișate greșit

```bash
# BASH (Ubuntu)
# Verifică locale-ul curent
locale

# Setează locale-ul corect
export LANG=ro_RO.UTF-8
export LC_ALL=ro_RO.UTF-8

# Dacă locale-ul nu e instalat
sudo locale-gen ro_RO.UTF-8
sudo update-locale LANG=ro_RO.UTF-8

# Permanent - adaugă în ~/.bashrc
echo 'export LANG=ro_RO.UTF-8' >> ~/.bashrc
echo 'export LC_ALL=ro_RO.UTF-8' >> ~/.bashrc
source ~/.bashrc
```

### Variabilele din `while | read` nu persistă

Aceasta e o capcană clasică. Când folosești pipe, partea dreaptă rulează într-un subshell, iar modificările nu se propagă înapoi.

```bash
# GREȘIT - subshell problem
count=0
cat file.txt | while read line; do
    ((count++))
done
echo $count    # Afișează 0!

# CORECT - folosește redirect în loc de pipe
count=0
while read line; do
    ((count++))
done < file.txt
echo $count    # Afișează valoarea corectă

# ALTERNATIV - folosește process substitution
count=0
while read line; do
    ((count++))
done < <(cat file.txt)
echo $count    # Funcționează
```

### Scriptul funcționează manual dar nu din cron

Cron rulează cu un PATH minimal și fără variabilele tale de mediu.

```bash
# BASH (Ubuntu)
# Soluția 1: Adaugă PATH în crontab
crontab -e
# Adaugă la început:
# PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Soluția 2: Folosește căi absolute în script
# În loc de:
grep pattern file.txt
# Scrie:
/usr/bin/grep pattern /home/user/file.txt

# Soluția 3: Source-uiește .bashrc la început
#!/usr/bin/env bash
source ~/.bashrc
# ... restul scriptului
```

### Line endings Windows vs Linux (CRLF vs LF)

Fișierele editate în Windows au `\r\n` la sfârșitul liniilor. Linux așteaptă doar `\n`. Simptomele: comportament ciudat, mesaje de eroare cu `^M`.

```bash
# BASH (Ubuntu)
# Verifică tipul fișierului
file script.sh
# Dacă zice "with CRLF line terminators" - e problema

# Convertește cu sed
sed -i 's/\r$//' script.sh

# SAU cu dos2unix
sudo apt install dos2unix
dos2unix script.sh

# Verificare
cat -A script.sh | head -5
# Liniile OK se termină în $ 
# Liniile cu CRLF se termină în ^M$
```

---

## Probleme cu Git

### "fatal: not a git repository"

```bash
# BASH (Ubuntu)
# Ești în directorul greșit
pwd
# Navighează la directorul cu repository-ul
cd ~/so-lab/proiecte/M05_Deployment_Pipeline

# SAU inițializează un repo nou
git init
```

### "error: failed to push some refs"

```bash
# BASH (Ubuntu)
# Cineva a modificat repository-ul remote
# Pull înainte de push
git pull origin main
# Rezolvă eventuale conflicte
git push origin main

# SAU forțează push-ul (ATENȚIE: suprascrie modificările altora)
git push -f origin main
```

### Cum anulez ultimul commit

```bash
# BASH (Ubuntu)
# Păstrează modificările, anulează doar commit-ul
git reset --soft HEAD~1

# Anulează commit-ul ȘI modificările (ATENȚIE: pierdere date)
git reset --hard HEAD~1
```

---

## Probleme cu SSH

### "Connection refused" la conectare PuTTY

1. Verifică că Ubuntu rulează (fereastra WSL trebuie să fie deschisă)
2. Verifică că SSH e pornit:
   ```bash
   # BASH (Ubuntu)
   sudo service ssh status
   # Dacă e oprit:
   sudo service ssh start
   ```
3. Verifică adresa IP:
   ```bash
   hostname -I
   # Folosește prima adresă afișată
   ```
4. Verifică că firewall-ul Windows nu blochează portul 22

### "Host key verification failed"

```bash
# BASH (Ubuntu)
# Șterge cheia veche
ssh-keygen -R hostname_sau_ip

# Reconectează-te (va cere să accepți noua cheie)
ssh user@hostname
```

---

# PARTEA VII: POVEȘTI ȘI CONTEXT ISTORIC

---

## De Unde Vin Lucrurile Pe Care Le Folosim

Fiecare comandă și concept din Unix are o istorie. Iată câteva care merită cunoscute.

### Thompson și Ritchie la Bell Labs (1969-1973)

Unix a început ca proiect personal. Ken Thompson voia să porteze un joc (Space Travel) pe un PDP-7 nefolosit. În proces, a creat un sistem de operare. Dennis Ritchie s-a alăturat și a creat limbajul C pentru a putea rescrie Unix portabil.

PDP-7 avea 18 KB de memorie. Întregul sistem de operare, cu shell și utilitare, încăpea acolo. Azi, un favicon de pe web ocupă mai mult.

În 1983, Thompson și Ritchie au primit Premiul Turing — cel mai prestigios premiu în informatică. Ritchie a murit în octombrie 2011, o săptămână după Steve Jobs. Jobs a primit atenția presei; Ritchie a trecut aproape neobservat. Ironic, iPhone-ul lui Jobs rulează pe un kernel derivat din Unix.

### Pipes — O Noapte de Muncă (1973)

Doug McIlroy, șeful departamentului lui Thompson, tot insista că programele ar trebui să se poată conecta "ca un furtun de grădină" — output-ul unuia să fie input-ul altuia.

Thompson a implementat pipe-urile într-o singură noapte. A doua zi, echipa a rescris toate utilitarele pentru a le suporta. Ideea a definit Unix și a influențat tot ce a venit după.

Notația `|` pentru pipe vine de la convenția folosită în logica matematică pentru "sau". A fost aleasă pentru că arată ca un tub.

### De Ce Comenzile Au Nume Ciudate

- `ls` = "list" (scurtat pentru a tasta mai repede)
- `cd` = "change directory"
- `pwd` = "print working directory"
- `cat` = "concatenate" (inițial pentru a concatena fișiere, acum folosit și pentru a le afișa)
- `grep` = "**g**lobal **r**egular **e**xpression **p**rint" — o comandă din editorul `ed`
- `awk` = Aho, Weinberger, Kernighan — inițialele creatorilor
- `sed` = "**s**tream **ed**itor"
- `cron` = Chronos, zeul grec al timpului

Teletype-urile din anii '70 erau lente. Cu cât numele comenzii era mai scurt, cu atât mai repede puteai tasta. De aceea `cp` în loc de `copy`, `mv` în loc de `move`, `rm` în loc de `remove`.

### Expresiile Regulate — De la Matematică la grep

Stephen Kleene a inventat expresiile regulate în 1951 pentru teoria limbajelor formale. Ken Thompson le-a implementat în software pentru prima dată în 1968, într-un editor de text.

Când Thompson a creat `grep` în 1973, a luat implementarea din editor și a făcut-o comandă standalone. `grep` vine din `ed`, editorul de linie al Unix: comanda `g/re/p` însemna "**g**lobal search for **r**egular **e**xpression and **p**rint".

### Creatorul lui Bash

Bash a fost creat de Brian Fox în 1989 pentru proiectul GNU. Scopul era să înlocuiască Bourne Shell (sh) cu ceva compatibil dar îmbunătățit. Numele e un acronim și un joc de cuvinte: **B**ourne **A**gain **SH**ell ("shell-ul Bourne reînviat").

Fox a lucrat singur la prima versiune. A părăsit proiectul în 1994, iar Chet Ramey a preluat mentenanța. Ramey încă menține Bash azi, după 30 de ani.

### De Ce Linux se Numește Linux

Linus Torvalds a creat kernelul în 1991, ca student la Universitatea din Helsinki. Inițial voia să-l numească "Freax" (free + freak + x de la Unix), dar administratorul serverului FTP unde l-a publicat nu a fost de acord și l-a pus într-un folder numit "Linux" (Linus + Unix).

Torvalds a acceptat numele cu reticență. A scris pe lista de mail: "e prea egocentric, nu pot să numesc ceva după mine".

---

## De Ce Unele Lucruri Sunt Așa Cum Sunt

### De ce 755 și 644?

Permisiunile Unix sunt stocate ca un număr octal. Fiecare cifră reprezintă permisiunile pentru owner, group, others:
- 7 = rwx (read + write + execute) = 4 + 2 + 1
- 5 = r-x (read + execute) = 4 + 0 + 1
- 4 = r-- (read only) = 4 + 0 + 0

755 pentru directoare și scripturi (executabile de toți, modificabile doar de owner).
644 pentru fișiere normale (citibile de toți, modificabile doar de owner).

Ar fi putut fi altfel? Da. Dar când ai miliarde de scripturi care setează `chmod 755`, nu mai poți schimba.

### De ce $HOME și nu altceva?

Variabilele de mediu au fost inventate în Version 7 Unix (1979). Convenția `$VARIABILA` vine din Bourne Shell. Semnul `$` a fost ales pentru că nu era folosit pentru altceva în sintaxă.

De ce majuscule? Pentru a le distinge de variabilele locale ale shell-ului. Convenția e doar asta — convenție. Nu e impusă de sistem.

### De ce shebang-ul e `#!`?

Prima linie `#!/bin/bash` se numește "shebang" (sau "hashbang"). Când Unix vede un fișier executabil care începe cu `#!`, folosește programul specificat ca interpretor.

De ce `#!`? `#` era deja folosit pentru comentarii în shell. `!` e caracteru care în unele contexte însemna "execută". Combinația era nefolosită și distinctivă.

Termenul "shebang" vine din argou. Poate de la "sharp bang" (#!), poate de la expresia irlandeză "shebeen" (bar ilegal). Nimeni nu știe sigur.

---

# PARTEA VIII: REFERINȚE ȘI RESURSE

---

## Documentație Oficială

- [GNU Bash Reference Manual](https://www.gnu.org/software/bash/manual/) — Referința completă
- [POSIX Shell Specification](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html) — Standard portabil
- [Linux man pages](https://man7.org/linux/man-pages/) — Documentația fiecărei comenzi

## Cărți Recomandate

- **"The Linux Command Line"** - William Shotts — Gratuit online, excelent pentru începători
- **"Learning the bash Shell"** - O'Reilly — Clasic pentru Bash
- **"Operating Systems: Three Easy Pieces"** - Arpaci-Dusseau — Teorie OS, disponibil gratuit

## Tutoriale Interactive

- [Exercism Bash Track](https://exercism.org/tracks/bash) — Exerciții cu feedback
- [OverTheWire Bandit](https://overthewire.org/wargames/bandit/) — Wargame pentru shell
- [ShellCheck](https://www.shellcheck.net/) — Linter online pentru scripturi

## Cercetare în Computing Education

- [SIGCSE](https://sigcse.org/) — Comunitatea principală
- [ACM TOCE](https://dl.acm.org/journal/toce) — Jurnal de referință
- [Computing Education Research Blog](https://computinged.wordpress.com/) — Blog al lui Mark Guzdial

---

# PARTEA IX: LICENȚĂ

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                           LICENȚĂ RESTRICTIVĂ                                ║
║                    Versiune 4.0.0 · Ianuarie 2025                            ║
║              © 2025 Antonio Clim. Toate drepturile rezervate.                ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

### Utilizări Permise

✓ **Studiu personal** — descarcă și folosește materialele pentru învățare individuală  
✓ **Execuție cod** — rulează exemplele pe dispozitivele tale  
✓ **Modificare locală** — adaptează codul pentru experimente personale  
✓ **Note personale** — creează note derivate pentru uz propriu

### Utilizări Interzise (fără acord scris prealabil)

✗ **Publicare** — încărcarea sau distribuirea materialelor pe orice platformă  
✗ **Predare** — utilizarea în cursuri, workshop-uri sau sesiuni de training  
✗ **Prezentare** — predarea sau prezentarea materialelor către terți  
✗ **Redistribuire** — redistribuirea în orice formă  
✗ **Lucrări derivate** — crearea de lucrări derivate pentru uz public  
✗ **Uz comercial** — exploatarea comercială de orice fel

### Prevederi Legale

**Fără garanție** — Materialele sunt furnizate "ca atare" fără nicio garanție, expresă sau implicită, incluzând, dar fără a se limita la, garanțiile de vandabilitate, potrivire pentru un anumit scop și neîncălcare.

**Limitarea răspunderii** — În nicio circumstanță autorul nu va fi răspunzător pentru nicio pretenție, daune sau altă răspundere, fie într-o acțiune contractuală, delictuală sau de altă natură, care decurge din sau în legătură cu materialele.

**Legea aplicabilă** — Acești termeni sunt guvernați de legile României. Disputele vor fi supuse jurisdicției exclusive a instanțelor din București.

**Contact pentru permisiuni** — Pentru solicitări privind utilizarea educațională, publicarea sau alte permisiuni, contactați autorul prin canalele academice oficiale sau prin issue tracker-ul repository-ului.

### Cerințe de Atribuire

Când citezi aceste materiale în lucrări academice (unde este permis):

```
Clim, A. (2025). ROso — Kit Educațional pentru Sisteme de Operare (Ediție Extinsă).  
Academia de Studii Economice București — CSIE.
```

---

# ANEXE

---

## Anexa A: Credențiale Standard Laborator

Pentru consistență în laborator, folosim aceste credențiale:

**Ubuntu/WSL:**
```
User: stud (sau numele tău de familie)
Pass: stud
```

**Portainer (Docker management):**
```
URL:  http://localhost:9000
User: stud
Pass: studstudstud
```

---

## Anexa B: Comenzi de Urgență

Când ceva nu merge și nu știi de ce:

```bash
# BASH (Ubuntu)
# Verifică versiunea sistemului
lsb_release -a
uname -a

# Verifică spațiul pe disk
df -h

# Verifică memoria
free -h

# Verifică procesele
top -bn1 | head -20

# Verifică log-urile recente
journalctl -xe --no-pager | tail -50

# Repornește WSL (din PowerShell)
# wsl --shutdown
# wsl
```

---

## Anexa C: Template .gitignore Complet

```gitignore
# =============================================================================
# .gitignore pentru Teme/Proiecte SO
# =============================================================================

# Fișiere temporare
*.tmp
*.temp
*.bak
*.backup
*~
*.swp
*.swo

# Log-uri și output
*.log
*.out
*.err

# Python
__pycache__/
*.py[cod]
*.pyo
venv/
env/
.env

# Build
*.o
*.a
*.so
*.exe

# IDE
.idea/
.vscode/
*.sublime-*

# OS
.DS_Store
Thumbs.db
Desktop.ini

# Arhive (nu le commit-ezi)
*.zip
*.tar.gz
*.rar
*.7z

# Directoare generate
output/
results/
build/
dist/

# Fișiere cu date sensibile
*.key
*.pem
passwords.txt
secrets.*
```

---

## Anexa D: Flux de Lucru Săptămânal

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         SĂPTĂMÂNA DE CURS                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│    ┌──────────────┐     ┌──────────────┐     ┌──────────────┐              │
│    │ ÎNAINTE DE   │     │   ÎN TIMPUL  │     │  DUPĂ        │              │
│    │   SEMINAR    │────▶│  SEMINARULUI │────▶│  SEMINAR     │              │
│    └──────────────┘     └──────────────┘     └──────────────┘              │
│           │                    │                    │                       │
│           ▼                    ▼                    ▼                       │
│    ┌──────────────┐     ┌──────────────┐     ┌──────────────┐              │
│    │ 1. Citește   │     │ 1. Participă │     │ 1. Revizuiește │            │
│    │    README    │     │    activ     │     │    notițele   │             │
│    │              │     │              │     │               │              │
│    │ 2. Parcurge  │     │ 2. Notează   │     │ 2. Completează│             │
│    │    MATERIAL_ │     │    comenzile │     │    tema       │              │
│    │    PRINCIPAL │     │              │     │               │              │
│    │              │     │ 3. Întreabă  │     │ 3. Rulează    │              │
│    │ 3. Pregătește│     │    când nu   │     │    validatorul│             │
│    │    mediul    │     │    înțelegi  │     │               │              │
│    └──────────────┘     └──────────────┘     └──────────────┘              │
│                                                                             │
│    Timp: 30 min         Timp: 100 min        Timp: 60-90 min               │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Anexa E: Statistici Kit

| Categorie | Cantitate | Detalii |
|-----------|-----------|---------|
| Cursuri teoretice | 14 | SO_curs01 până la SO_curs14 |
| Seminarii practice | 6 | SEM01 până la SEM06 |
| Proiecte de semestru | 23 | 5 EASY + 15 MEDIUM + 3 ADVANCED |
| Diagrame PNG | 27 | În 000SUPPL/diagrame_png/ |
| Ore estimate (total) | 60+ | Pentru parcurgere completă |
| Scripturi demonstrative | 100+ | Bash și Python |
| Exerciții examen | 3 seturi | În 000SUPPL/ |

---

*Kit actualizat: Ianuarie 2025*  
*Testat pe: Ubuntu 24.04 LTS, WSL2 cu Ubuntu 22.04/24.04*  
*Feedback și erori: prin canalele oficiale ASE-CSIE sau issue tracker*

---

**ing. dr. Antonio Clim**  
Lector universitar | Academia de Studii Economice București — CSIE
