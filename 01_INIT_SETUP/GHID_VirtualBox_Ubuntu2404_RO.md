# GHID COMPLET DE INSTALARE PENTRU ÎNCEPĂTORI
## Ubuntu Server 24.04 LTS în VirtualBox (Mașină Virtuală)

> *Notă personală: Mulți preferă `zsh`, dar eu rămân la Bash pentru că e standardul pe servere. Consistența bate confortul.*

### Academia de Studii Economice București - CSIE
### Sisteme de Operare - Anul universitar 2024-2025

---

# CITEȘTE ÎNAINTE DE A ÎNCEPE

**CÂND SĂ FOLOSEȘTI ACEST GHID?**

Acest ghid este o alternativă la WSL2. Folosește-l dacă:
- Ai Mac (macOS) sau Linux în loc de Windows
- Nu poți instala WSL2 pe Windows (versiune veche, restricții)
- Preferi o mașină virtuală completă

**CE VEI AVEA LA FINAL?**

Un server Ubuntu Linux complet, care rulează într-o fereastră pe calculatorul tău.

**CÂT DUREAZĂ?**

În jur de 60-90 de minute. Folosește checkpoint-urile de timp de mai jos pentru a-ți urmări progresul.

---

# ⏱️ CHECKPOINT-URI DE TIMP

Folosește-le pentru a-ți urmări progresul. A dura mai mult decât estimat e normal pentru prima instalare.

| Checkpoint | Secțiune | Timp estimat | Timpul tău |
|------------|----------|--------------|------------|
| 🚀 Start | — | 0 min | ⬜ |
| ✓ VirtualBox + Extension Pack instalat | Secțiunea 6 | 20 min | ⬜ |
| ✓ VM creat cu setările corecte | Secțiunea 8 | 30 min | ⬜ |
| ✓ Ubuntu instalat, cont creat | Secțiunea 9 | 50 min | ⬜ |
| ✓ Hostname configurat | Secțiunea 10 | 55 min | ⬜ |
| ✓ Tot software-ul instalat | Secțiunea 11 | 70 min | ⬜ |
| ✓ SSH funcțional, conectare remote reușită | Secțiunea 13/15 | 80 min | ⬜ |
| 🎉 Verificarea a trecut | Secțiunea 17 | 90 min | ⬜ |

---

# LEARNING OUTCOMES (Ce vei ști să faci după acest ghid)

La finalul acestui ghid, vei putea:

- [ ] **LO1:** Să instalezi VirtualBox + Extension Pack pe Windows, macOS sau Linux
- [ ] **LO2:** Să creezi o mașină virtuală cu parametrii corecți (4GB RAM, 2 CPU, 25GB disk, rețea Bridge)
- [ ] **LO3:** Să instalezi Ubuntu Server 24.04 și să configurezi user (numele de familie) și hostname (`INITIALA_GRUPA_SERIA`)
- [ ] **LO4:** Să te conectezi SSH la VM și să transferi fișiere cu PuTTY/WinSCP (Windows) sau ssh/scp (macOS/Linux)
- [ ] **LO5:** Să gestionezi VM-ul headless (pornire/oprire din linia de comandă cu `VBoxManage`)
- [ ] **LO6:** Să activezi virtualizarea din BIOS când e dezactivată și să rezolvi problema rețelei Bridge

---

# CUM SĂ CITEȘTI ACEST GHID

## Tipuri de comenzi

### Comenzi PowerShell (Windows)

```powershell
# POWERSHELL (Windows) - Fundal albastru
# Aceasta este o comandă pentru Windows PowerShell
Get-Process
```

### Comenzi Terminal macOS

```bash
# TERMINAL (macOS) - Fundal gri/negru
# Aceasta este o comandă pentru Mac
ls -la
```

### Comenzi Terminal Linux (pe calculatorul tău, nu în VM)

```bash
# TERMINAL LINUX (gazda) - Fundal negru
# Aceasta este o comandă pentru Linux-ul tău principal
sudo apt install virtualbox
```

### Comenzi în Ubuntu VM (mașina virtuală)

```bash
# UBUNTU VM - Fundal negru
# Aceasta este o comandă pentru Ubuntu-ul din VirtualBox
sudo apt update
```

## Cum să copiezi și lipești

1. Selectează comanda cu mouse-ul
2. Copiază cu `Ctrl+C` (Windows/Linux) sau `Cmd+C` (Mac)
3. Lipește:
   - Windows PowerShell: `Ctrl+V` sau click dreapta
   - macOS Terminal: `Cmd+V`
   - Linux Terminal: `Ctrl+Shift+V`
   - În VirtualBox (Ubuntu): Click dreapta sau `Ctrl+Shift+V`

---

# CUPRINS

**PARTEA 1: PREGĂTIRE**
1. [Verifică cerințele sistemului](#1-verifică-cerințele-sistemului)
2. [Descarcă tot ce ai nevoie](#2-descarcă-tot-ce-ai-nevoie)

**PARTEA 2: INSTALARE VIRTUALBOX**
3. [Instalare pe Windows](#3-instalare-virtualbox-pe-windows)
4. [Instalare pe macOS](#4-instalare-virtualbox-pe-macos)
5. [Instalare pe Linux](#5-instalare-virtualbox-pe-linux)
6. [Instalare Extension Pack (toți)](#6-instalare-extension-pack)

**PARTEA 3: CREARE MAȘINĂ VIRTUALĂ**
7. [Creează mașina virtuală](#7-creează-mașina-virtuală)
8. [Configurează rețeaua Bridge](#8-configurează-rețeaua-bridge)

**PARTEA 4: INSTALARE UBUNTU**
9. [Instalează Ubuntu Server](#9-instalează-ubuntu-server)
10. [Configurare după instalare](#10-configurare-după-instalare)
11. [Instalează programele necesare](#11-instalează-programele-necesare)

**PARTEA 5: ACCES REMOTE**
12. [Configurează SSH](#12-configurează-ssh)
13. [Conectare cu PuTTY (Windows)](#13-conectare-cu-putty-windows)
14. [Conectare cu WinSCP (Windows)](#14-conectare-cu-winscp-windows)
15. [Conectare de pe macOS sau Linux](#15-conectare-de-pe-macos-sau-linux)

**PARTEA 6: VERIFICARE & FINALIZARE**
16. [Verifică shell-ul implicit Bash](#16-verifică-shell-ul-implicit-bash)
17. [Test practic de transfer bidirectional](#17-test-practic-de-transfer-bidirectional)
18. [Creează folderele de lucru](#18-creează-folderele-de-lucru)
19. [Verifică instalarea](#19-verifică-instalarea)
20. [Probleme frecvente și soluții](#20-probleme-frecvente-și-soluții)
21. [Greșeli frecvente pe care le văd în fiecare an](#21-greșeli-frecvente-pe-care-le-văd-în-fiecare-an)
22. [Cum să folosești asistenții AI](#22-cum-să-folosești-asistenții-ai)

---

# PARTEA 1: PREGĂTIRE

---

# 1. Verifică cerințele sistemului

## Ce ai nevoie

| Componentă | Minim necesar | Recomandat |
|------------|---------------|------------|
| RAM total | 8 GB | 16 GB |
| Spațiu liber | 30 GB | 50 GB |
| Procesor | 64-bit cu virtualizare | Intel Core i5+ sau AMD Ryzen 5+ |

## Verifică virtualizarea (IMPORTANT!)

Virtualizarea hardware trebuie să fie activată. Iată cum verifici pe fiecare sistem:

### Pe Windows

**Pas 1:** Apasă `Ctrl + Shift + Esc` pentru a deschide Task Manager

**Pas 2:** Click pe tab-ul Performance

**Pas 3:** Click pe CPU în stânga

**Pas 4:** Caută în dreapta jos: "Virtualization: Enabled"

Dacă scrie "Disabled", trebuie să activezi virtualizarea din BIOS (vezi Secțiunea 18).

> **Poveste adevărată din 2022:** Un student cu un laptop gaming nou-nouț nu putea porni niciun VM. După o oră de debugging, am descoperit că producătorul dezactivase virtualizarea implicit pentru „a îmbunătăți durata bateriei". O singură setare BIOS mai târziu, totul funcționa. Verifică întotdeauna asta mai întâi.

### Pe macOS

**Pas 1:** Deschide Terminal (Finder → Applications → Utilities → Terminal)

**Pas 2:** Scrie această comandă și apasă Enter:

```bash
sysctl -a | grep machdep.cpu.features | grep VMX
```

Dacă apare text care conține "VMX", virtualizarea este activată. Mac-urile moderne au virtualizarea activată implicit.

**Pas 3:** Verifică tipul procesorului:

```bash
uname -m
```

- Dacă apare `x86_64` = ai Mac cu procesor Intel
- Dacă apare `arm64` = ai Mac cu procesor Apple Silicon (M1/M2/M3/M4)

**⚠️ ATENȚIE pentru Mac cu Apple Silicon:** VirtualBox funcționează, dar cu performanță limitată. O alternativă mai bună este UTM (https://mac.getutm.app/).

### Pe Linux

**Pas 1:** Deschide terminalul

**Pas 2:** Rulează:

```bash
egrep -c '(vmx|svm)' /proc/cpuinfo
```

Dacă rezultatul este un număr mai mare decât 0, virtualizarea este suportată.

---

# 2. Descarcă tot ce ai nevoie

## Creează un folder pentru download-uri

### Pe Windows

Deschide File Explorer și creează folderul: `C:\VirtualBox_Kits`

### Pe macOS sau Linux

Deschide terminalul și rulează:

```bash
mkdir -p ~/VirtualBox_Kits
```

## Descarcă VirtualBox

**Pas 1:** Deschide browser-ul și mergi la: https://www.virtualbox.org/wiki/Downloads

**Pas 2:** Descarcă versiunea pentru sistemul tău:

| Sistemul tău | Ce să descarci |
|--------------|----------------|
| Windows | Click pe "Windows hosts" |
| macOS cu Intel | Click pe "macOS / Intel hosts" |
| macOS cu Apple Silicon | Click pe "macOS / Arm64 hosts" |
| Linux | Click pe "Linux distributions" și alege distribuția ta |

**Pas 3:** Salvează fișierul în folderul creat mai devreme

## Descarcă Extension Pack

**Pas 1:** Pe aceeași pagină, la secțiunea "VirtualBox Extension Pack"

**Pas 2:** Click pe "All supported platforms"

**Pas 3:** Salvează fișierul (se numește ceva de genul `Oracle_VM_VirtualBox_Extension_Pack-7.x.x.vbox-extpack`)

**De reținut:** Versiunea Extension Pack TREBUIE să fie aceeași cu versiunea VirtualBox!

## Descarcă Ubuntu Server

**Pas 1:** Mergi la: https://ubuntu.com/download/server

**Pas 2:** Click pe "Download Ubuntu Server 24.04 LTS"

**Pas 3:** Salvează fișierul ISO (în jur de 2.5 GB, poate dura 10-30 minute)

## Ce ar trebui să ai acum

În folderul tău ar trebui să ai 3 fișiere:
1. Installerul VirtualBox (`.exe` pentru Windows, `.dmg` pentru Mac)
2. Extension Pack (`.vbox-extpack`)
3. Ubuntu Server ISO (`ubuntu-24.04-live-server-amd64.iso`)

---

# PARTEA 2: INSTALARE VIRTUALBOX

---

# 3. Instalare VirtualBox pe Windows

*Sari acest pas dacă ai macOS sau Linux!*

## Rulează installerul

**Pas 1:** Du-te în folderul `C:\VirtualBox_Kits`

**Pas 2:** Dublu-click pe fișierul VirtualBox (ex: `VirtualBox-7.x.x-xxxxx-Win.exe`)

**Pas 3:** Dacă apare "User Account Control" cu întrebarea "Do you want to allow this app to make changes?", click Yes

## Parcurge wizard-ul de instalare

**Ecran 1 — Welcome:**
- Click Next

**Ecran 2 — Custom Setup:**
- Lasă totul bifat (toate componentele)
- Click Next

**Ecran 3 — Warning: Network Interfaces:**
- Apare un mesaj că rețeaua va fi deconectată temporar
- Click Yes

**Ecran 4 — Missing Dependencies (dacă apare):**
- Click Yes pentru a instala dependențele lipsă

**Ecran 5 — Ready to Install:**
- Click Install

**Ecran 6 — Instalare drivere:**
- Windows poate întreba de 2-3 ori dacă vrei să instalezi drivere de la Oracle
- Click Install de fiecare dată

**Ecran 7 — Finish:**
- Bifează "Start Oracle VM VirtualBox after installation"
- Click Finish

VirtualBox ar trebui să se deschidă automat acum.

---

# 4. Instalare VirtualBox pe macOS

*Sari acest pas dacă ai Windows sau Linux!*

## Rulează installerul

**Pas 1:** Du-te în folderul `~/VirtualBox_Kits` (în Finder)

**Pas 2:** Dublu-click pe fișierul `.dmg`

**Pas 3:** Se deschide o fereastră cu iconița VirtualBox. Dublu-click pe `VirtualBox.pkg`

## Parcurge instalarea

**Pas 1:** La ecranul de bun venit, click Continue

**Pas 2:** La locația instalării, click Install

**Pas 3:** macOS va cere parola ta. Tastează-o și click "Install Software"

**Pas 4:** Poate apărea un mesaj de securitate: "System Extension Blocked"
- Click "Open Security Preferences"
- În fereastra Security, click "Allow" lângă mesajul Oracle
- Poate fi nevoie să repornești Mac-ul

**Pas 5:** Click Close când instalarea se termină

## Deschide VirtualBox

Mergi la Applications → VirtualBox, sau folosește Spotlight (`Cmd + Space`, tastează "VirtualBox")

---

# 5. Instalare VirtualBox pe Linux

*Sari acest pas dacă ai Windows sau macOS!*

## Pe Ubuntu/Debian

```bash
sudo apt update
sudo apt install virtualbox virtualbox-ext-pack
```

La întrebarea despre licență, folosește Tab pentru a selecta "Ok" și apasă Enter, apoi selectează "Yes".

## Pe Fedora

```bash
sudo dnf install VirtualBox
```

## Pe Arch Linux

```bash
sudo pacman -S virtualbox virtualbox-host-modules-arch
```

## După instalare

Adaugă userul tău la grupul vboxusers:

```bash
sudo usermod -aG vboxusers $USER
```

**Deloghează-te și loghează-te din nou** pentru ca modificarea de grup să aibă efect.

---

# 6. Instalare Extension Pack

*Acest pas este pentru TOȚI, indiferent de sistemul de operare!*

## De ce ai nevoie de Extension Pack?

Extension Pack adaugă funcții precum suportul pentru USB 2.0/3.0, care sunt utile pentru curs.

## Instalare

**Pas 1:** Deschide VirtualBox (dacă nu e deja deschis)

**Pas 2:** Din meniu: File → Tools → Extension Pack Manager (sau Preferences → Extensions pe versiuni mai vechi)

**Pas 3:** Click pe butonul "Install" (iconița cu semnul +)

**Pas 4:** Navighează la folderul de descărcări și selectează fișierul Extension Pack (`Oracle_VM_VirtualBox_Extension_Pack-7.x.x.vbox-extpack`)

**Pas 5:** Apare o fereastră cu licența. Scrollează în jos și click "I Agree"

**Pas 6:** Dacă cere parola de administrator, tasteaz-o

**Gata!** Extension Pack apare în listă ca "Oracle VM VirtualBox Extension Pack" cu statusul "Active".

---

# PARTEA 3: CREARE MAȘINĂ VIRTUALĂ

---

# 7. Creează mașina virtuală

## Pornește wizard-ul

**Pas 1:** În VirtualBox, click pe butonul New (sau din meniu: Machine → New)

## Configurare — Pasul 1: Nume și sistem de operare

- **Name:** `Ubuntu-Server-2404-SO`
- **Folder:** lasă implicit sau alege un folder cu spațiu suficient
- **ISO Image:** Click pe săgeata dropdown și selectează Other...
  - Navighează la folderul de descărcări
  - Selectează fișierul `ubuntu-24.04-live-server-amd64.iso`
- **Type:** `Linux`
- **Version:** `Ubuntu (64-bit)`

**De reținut:** Bifează "Skip Unattended Installation" — vrem să instalăm manual!

Click Next

## Configurare — Pasul 2: Hardware

- **Base Memory:** Trage sliderul sau tastează `4096` MB (adică 4 GB)
  - Dacă ai doar 8 GB RAM total, poți seta 2048 MB (2 GB)
- **Processors:** `2`
  - Dacă ai un procesor slab, lasă 1
- Bifează "Enable EFI" (opțional dar recomandat)

Click Next

## Configurare — Pasul 3: Hard Disk

- Selectează "Create a Virtual Hard Disk Now"
- **Disk Size:** `25 GB` (minim) sau `50 GB` (dacă ai spațiu)
- **NU bifa** "Pre-allocate Full Size" — lasă nebifat

Click Next

## Configurare — Pasul 4: Sumar

Verifică setările:
- Name: Ubuntu-Server-2404-SO
- Memory: 4096 MB
- Processors: 2
- Disk: 25 GB

Click Finish

Mașina virtuală este creată! O poți vedea acum în lista din stânga.

---

# 8. Configurează rețeaua Bridge

## Ce este rețeaua Bridge?

Bridge face ca Ubuntu din VirtualBox să apară ca un calculator separat în rețeaua ta. Va primi o adresă IP de la router, ca orice alt dispozitiv din casa ta.

> **Observație din laborator:** Aproximativ 30% din problemele „SSH nu funcționează" provin din folosirea NAT în loc de Bridge. NAT izolează VM-ul — poți ajunge la internet, dar nimic nu poate ajunge la tine. Bridge îți oferă un IP real în rețeaua locală.

## Configurare

**Pas 1:** În VirtualBox, selectează mașina `Ubuntu-Server-2404-SO` (click pe ea)

**Pas 2:** Click pe Settings (sau click dreapta → Settings)

**Pas 3:** În meniul din stânga, click pe Network

**Pas 4:** În tab-ul Adapter 1:
- **Enable Network Adapter:** trebuie să fie bifat ✓
- **Attached to:** selectează "Bridged Adapter" din dropdown
- **Name:** selectează interfața de rețea a calculatorului tău

### Cum știi ce interfață să selectezi?

**Pe Windows:**
- Dacă ești conectat prin cablu: alege ceva cu "Ethernet" în nume
- Dacă ești pe Wi-Fi: alege ceva cu "Wi-Fi" sau "Wireless" în nume

**Pe macOS:**
- Wi-Fi pe MacBook: de obicei `en0`
- Ethernet (dacă ai): de obicei `en1`

**Pe Linux:**
- Ethernet: `eth0`, `enp3s0`, sau similar
- Wi-Fi: `wlan0`, `wlp2s0`, sau similar

Dacă nu ești sigur, încearcă prima opțiune. Poți schimba mai târziu.

**Pas 5:** Click OK pentru a salva

---

# PARTEA 4: INSTALARE UBUNTU

---

# 9. Instalează Ubuntu Server

## Pornește mașina virtuală

**Pas 1:** Selectează `Ubuntu-Server-2404-SO` în VirtualBox

**Pas 2:** Click pe Start (butonul verde cu săgeată)

Se deschide o fereastră nouă și începe boot-ul de pe ISO.

## Ecranul de boot

Când apare meniul, selectează:

**Try or Install Ubuntu Server**

Apasă Enter

Așteaptă 1-2 minute pentru ca installerul să se încarce.

## Instalare — Pasul 1: Limbă

Folosește săgețile sus/jos pentru a selecta. Selectează:

**English**

Apasă Enter

## Instalare — Pasul 2: Tastatură

- Layout: English (US) sau Romanian
- Variant: English (US) sau Romanian (Standard)

**Recomandare:** Lasă English (US) pentru compatibilitate.

Navighează cu Tab la [ Done ] și apasă Enter

## Instalare — Pasul 3: Tip instalare

Selectează:

**(X) Ubuntu Server**

Navighează la [ Done ] și apasă Enter

## Instalare — Pasul 4: Rețea

Installerul ar trebui să detecteze rețeaua automat. Ar trebui să vezi o adresă IP (ex: `192.168.1.105`).

Dacă vezi "DHCPv4" cu o adresă IP — ești OK.

Dacă vezi "not configured" — verifică setările rețelei Bridge (Secțiunea 8).

Navighează la [ Done ] și apasă Enter

## Instalare — Pasul 5: Proxy

Lasă gol (dacă nu știi că ai nevoie de proxy).

Navighează la [ Done ] și apasă Enter

## Instalare — Pasul 6: Ubuntu archive mirror

Lasă implicit.

Navighează la [ Done ] și apasă Enter

## Instalare — Pasul 7: Configurare stocare

Selectează:

**(X) Use an entire disk**

Asigură-te că "Set up this disk as an LVM group" este bifat.

Navighează la [ Done ] și apasă Enter

Apare un sumar. Navighează la [ Done ] și apasă Enter din nou.

Apare un mesaj de confirmare: "Confirm destructive action". Navighează la [ Continue ] și apasă Enter.

## Instalare — Pasul 8: Configurare profil

Aici îți creezi contul.

- **Your name:** Numele tău complet (ex: `Ion Popescu`)
- **Your server's name:** Hostname-ul tău în formatul `INITIALA_GRUPA_SERIA` (ex: `IP_1001_A`)
- **Pick a username:** Numele tău de familie cu litere mici (ex: `popescu`)
- **Choose a password:** `stud`
- **Confirm your password:** `stud`

Navighează la [ Done ] și apasă Enter

## Instalare — Pasul 9: Ubuntu Pro

Selectează:

**Skip for now**

Navighează la [ Continue ] și apasă Enter

## Instalare — Pasul 10: Configurare SSH

**IMPORTANT:** Bifează această opțiune!

**[X] Install OpenSSH server**

Navighează la [ Done ] și apasă Enter

## Instalare — Pasul 11: Featured Server Snaps

Nu selecta nimic aici. Vom instala ce avem nevoie manual.

Navighează la [ Done ] și apasă Enter

## Instalare în progres

Acum așteaptă să se finalizeze instalarea. Poate dura 5-15 minute.

Când vezi "Install complete!" în partea de sus, navighează la [ Reboot Now ] și apasă Enter.

## După reboot

VM-ul va reporni. Poate apărea un mesaj "Please remove the installation medium". Doar apasă Enter.

Așteaptă ca Ubuntu să pornească. Vei vedea un prompt de login:

```
Ubuntu-Server-2404-SO login:
```

Tastează numele tău de utilizator (ex: `popescu`) și apasă Enter.

Tastează parola (`stud`) și apasă Enter.

**Reține:** Nu vei vedea parola pe măsură ce o tastezi — asta e normal.

Dacă vezi un prompt de genul `popescu@IP_1001_A:~$`, felicitări! Ubuntu este instalat.

---

# 10. Configurare după instalare

## Verifică hostname-ul

```bash
hostname
```

Ar trebui să vezi hostname-ul tău (ex: `IP_1001_A`). Dacă vezi altceva sau trebuie să îl schimbi:

```bash
sudo hostnamectl set-hostname INITIALA_GRUPA_SERIA
```

Înlocuiește `INITIALA_GRUPA_SERIA` cu hostname-ul tău real (ex: `IP_1001_A`).

## Actualizează sistemul

```bash
sudo apt update && sudo apt -y upgrade
```

Poate dura 5-10 minute. Așteaptă să se finalizeze.

---

# 11. Instalează programele necesare

## Instalează tot ce ai nevoie

Copiază și lipește această comandă:

```bash
sudo apt update && sudo apt install -y build-essential git curl wget nano vim tree htop net-tools openssh-server man-db manpages-posix gawk sed grep coreutils findutils diffutils procps sysstat lsof tar gzip bzip2 xz-utils zstd zip unzip p7zip-full iproute2 iputils-ping dnsutils netcat-openbsd traceroute nmap tcpdump gcc g++ make cmake gdb valgrind python3 python3-pip python3-venv shellcheck jq bc figlet cowsay ncdu pv dialog
```

Așteaptă să se finalizeze (5-15 minute).

## Instalează bibliotecile Python necesare

```bash
pip3 install --break-system-packages rich tabulate psutil
```

---

# PARTEA 5: ACCES REMOTE

---

# 12. Configurează SSH

SSH ar trebui să fie deja instalat și să ruleze (l-am selectat în timpul instalării).

## Verifică statusul SSH

```bash
sudo systemctl status ssh
```

Ar trebui să vezi "active (running)". Apasă `q` pentru a ieși.

## Activează SSH la boot

```bash
sudo systemctl enable ssh
```

## Găsește adresa IP

```bash
hostname -I
```

**Notează această adresă IP** — vei avea nevoie de ea pentru a te conecta de pe calculatorul principal.

---

# 13. Conectare cu PuTTY (Windows)

*Sari acest pas dacă folosești macOS sau Linux!*

## Descarcă PuTTY

**Pas 1:** Mergi la: https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html

**Pas 2:** Descarcă installerul MSI pentru 64-bit

**Pas 3:** Instalează-l (Next, Next, Install, Finish)

## Configurează conexiunea

**Pas 1:** Deschide PuTTY

**Pas 2:** În "Host Name (or IP address)": tastează IP-ul VM-ului (ex: `192.168.1.105`)

**Pas 3:** Port: `22` (implicit)

**Pas 4:** Connection type: SSH (implicit)

**Pas 5:** În stânga, mergi la Connection → Data

**Pas 6:** În "Auto-login username": tastează numele tău de utilizator (ex: `popescu`)

**Pas 7:** Revino la Session (click pe Session în stânga)

**Pas 8:** În "Saved Sessions": tastează un nume (ex: `Ubuntu-VM-SO`)

**Pas 9:** Click Save

## Conectare

**Pas 1:** Selectează sesiunea salvată

**Pas 2:** Click Open

**Pas 3:** Prima dată va apărea o avertizare de securitate — click Accept

**Pas 4:** Tastează parola (`stud`) și apasă Enter

Dacă vezi promptul `popescu@IP_1001_A:~$`, ești conectat!

---

# 14. Conectare cu WinSCP (Windows)

*Sari acest pas dacă folosești macOS sau Linux!*

## Descarcă WinSCP

**Pas 1:** Mergi la: https://winscp.net/eng/download.php

**Pas 2:** Descarcă versiunea de instalare

**Pas 3:** Instalează-l (Next, Next, Install, Finish)

## Configurează conexiunea

**Pas 1:** Deschide WinSCP

**Pas 2:** În fereastra de login:
- File protocol: SFTP
- Host name: IP-ul VM-ului (ex: `192.168.1.105`)
- Port number: 22
- User name: numele tău de utilizator (ex: `popescu`)
- Password: `stud`

**Pas 3:** Click Save și dă un nume (ex: `Ubuntu-VM-SO`)

**Pas 4:** Click Login

## Cum să transferi fișiere

În stânga vezi fișierele de pe Windows, în dreapta fișierele din Ubuntu.

Pentru a transfera fișiere:
- Trage și plasează între cele două panouri
- Sau selectează fișierul și click pe săgeata de transfer

---

# 15. Conectare de pe macOS sau Linux

*Sari acest pas dacă folosești Windows!*

## Conectare simplă

Deschide Terminal și rulează:

```bash
ssh numeletau@ADRESA_IP
```

De exemplu:

```bash
ssh popescu@192.168.1.105
```

La întrebarea despre fingerprint, tastează `yes` și apasă Enter.

Tastează parola (`stud`) și apasă Enter.

## Configurare pentru conectare rapidă

**Pas 1:** Editează fișierul de configurare SSH:

```bash
nano ~/.ssh/config
```

**Pas 2:** Adaugă (înlocuiește cu datele tale):

```
Host ubuntu-vm
    HostName 192.168.1.105
    User popescu
    Port 22
```

**Pas 3:** Salvează: apasă `Ctrl+O`, apoi `Enter`, apoi `Ctrl+X`

**Pas 4:** Acum te poți conecta simplu cu:

```bash
ssh ubuntu-vm
```

## Transfer fișiere

### Cu comanda scp

```bash
scp fisier.txt popescu@192.168.1.105:/home/popescu/
```

### Cu comanda sftp (interactiv)

```bash
sftp popescu@192.168.1.105
```

În modul SFTP:
- `put fisier.txt` — trimite fișier
- `get fisier.txt` — primește fișier
- `ls` — listează fișiere
- `exit` — ieși

### Aplicații grafice

- macOS: Cyberduck (gratuit) — https://cyberduck.io/
- Linux: FileZilla — `sudo apt install filezilla`

---

# PARTEA 6: FINALIZARE

---

# 16. Verifică shell-ul implicit Bash

> **De ce contează:** Folosim **Bash** (Bourne Again Shell) — standardul industrial pe serverele de producție. Dacă shell-ul implicit al VM-ului este altceva, scripturile noastre s-ar putea să nu funcționeze corect.

## Verifică shell-ul implicit în VM

```bash
# BASH (Ubuntu VM) - Verifică shell-ul implicit
echo $SHELL
```

**Rezultat așteptat:** `/bin/bash`

Verifică și:

```bash
# BASH (Ubuntu VM) - Verifică ce rulează efectiv
echo $0
```

**Rezultat așteptat:** `-bash` sau `bash`

## Schimbă la Bash dacă e necesar

Dacă `$SHELL` a arătat altceva decât `/bin/bash`:

```bash
# BASH (Ubuntu VM) - Schimbă shell-ul implicit la Bash
chsh -s /bin/bash
```

Apoi deloghează-te și reloghează-te pentru ca schimbarea să aibă efect.

## Notă pentru utilizatorii macOS și Linux

Calculatorul tău **gazdă** (calculatorul fizic) ar putea folosi Zsh ca shell implicit (acest lucru este normal pe macOS de la Catalina). **Este perfect în regulă** — doar **VM-ul** trebuie să folosească Bash pentru acest curs.

Dacă ai nevoie să folosești temporar Bash pe gazda ta pentru unele comenzi, scrie doar `bash` în terminalul tău — te vei întoarce la shell-ul implicit când scrii `exit`.

## Verificare rapidă

```bash
# BASH (Ubuntu VM) - Verificare completă shell
echo "Implicit: $SHELL | Rulează: $0 | Versiune: $BASH_VERSION"
```

> ✅ **Punct de control:** Shell-ul implicit este `/bin/bash` și versiunea începe cu `5.x`.

# 17. Test practic de transfer bidirectional

> **De ce contează:** La seminarii vei transfera constant scripturi în VM și vei recupera rezultate înapoi. Acest test verifică că transferul de fișiere funcționează **în ambele direcții** înainte să ai nevoie de el sub presiune.

## Pregătire (în VM)

Asigură-te că SSH rulează și creează un fișier test:

```bash
# BASH (Ubuntu VM) - Pregătire pentru testul de transfer
mkdir -p ~/test
echo "Acest fisier a fost creat in VM la $(date)" > ~/test/transfer_test_din_vm.txt
cat ~/test/transfer_test_din_vm.txt
hostname -I
```

Notează adresa IP a VM-ului.

## PENTRU UTILIZATORII WINDOWS: Test cu WinSCP

### Upload (Windows → VM)

1. Pe Desktop, creează `transfer_test_din_windows.txt` cu conținutul: `Salut din Windows!`
2. Deschide WinSCP, conectează-te la VM folosind IP-ul lui
3. Panoul stâng → Desktop, Panoul drept → `~/test/`
4. Trage fișierul din stânga în dreapta
5. Verifică în VM:

```bash
# BASH (Ubuntu VM) - Verifică upload-ul
cat ~/test/transfer_test_din_windows.txt
```

### Download (VM → Windows)

1. În WinSCP, trage `transfer_test_din_vm.txt` din dreapta în stânga (pe Desktop)
2. Deschide pe Desktop — verifică mesajul cu data

## PENTRU UTILIZATORII macOS/Linux: Test cu scp

### Upload (Gazdă → VM)

```bash
# TERMINAL GAZDĂ (macOS/Linux) - Încarcă fișier test în VM
echo "Salut din gazda $(hostname)!" > /tmp/test_din_host.txt
scp /tmp/test_din_host.txt numeletau@IP_VM:~/test/
```

Înlocuiește `numeletau` cu numele tău de utilizator Ubuntu și `IP_VM` cu adresa IP a VM-ului.

Verifică în VM:

```bash
# BASH (Ubuntu VM) - Verifică upload-ul
cat ~/test/test_din_host.txt
```

### Download (VM → Gazdă)

```bash
# TERMINAL GAZDĂ (macOS/Linux) - Descarcă fișier test din VM
scp numeletau@IP_VM:~/test/transfer_test_din_vm.txt /tmp/
cat /tmp/transfer_test_din_vm.txt
```

### Alternativă: modul interactiv sftp

```bash
# TERMINAL GAZDĂ (macOS/Linux) - Sesiune SFTP interactivă
sftp numeletau@IP_VM
# Odată conectat:
#   cd test
#   ls
#   get transfer_test_din_vm.txt /tmp/
#   put /tmp/test_din_host.txt
#   bye
```

## Verificare cu checksums (opțional)

```bash
# BASH (Ubuntu VM) - Generează checksum
sha256sum ~/test/transfer_test_din_windows.txt    # utilizatori Windows
sha256sum ~/test/test_din_host.txt                 # utilizatori macOS/Linux
```

**Windows (compară în PowerShell):**
```powershell
# POWERSHELL (Windows) - Compară checksum
Get-FileHash "$env:USERPROFILE\Desktop\transfer_test_din_windows.txt" -Algorithm SHA256
```

**macOS/Linux (compară pe gazdă):**
```bash
# TERMINAL GAZDĂ - Compară checksum
sha256sum /tmp/test_din_host.txt
```

## Curățare

```bash
# BASH (Ubuntu VM) - Șterge fișierele de test
rm -f ~/test/transfer_test_din_vm.txt ~/test/transfer_test_din_windows.txt ~/test/test_din_host.txt
```

> ✅ **Punct de control:** Fișierele călătoresc în ambele direcții între gazdă și VM. Ești pregătit pentru seminarii.

# 18. Creează folderele de lucru

În Ubuntu (prin SSH sau direct în VM), rulează:

```bash
mkdir -p ~/Books ~/HomeworksOLD ~/Projects ~/ScriptsSTUD ~/test ~/TXT
```

Verifică:

```bash
ls -la ~
```

| Folder | Pentru ce |
|--------|-----------|
| `Books` | Cărți, PDF-uri |
| `HomeworksOLD` | Teme vechi |
| `Projects` | Proiecte active |
| `ScriptsSTUD` | Scripturi de la seminarii |
| `test` | Teste și experimente |
| `TXT` | Notițe text |

---

# 19. Verifică instalarea

## Opțiunea 1 — Script complet de verificare

Rulează scriptul de verificare din folderul kit-ului:

```bash
bash ~/verify_installation.sh
```

## Opțiunea 2 — Verificare rapidă într-o linie

```bash
hostname && whoami && lsb_release -d && hostname -I && echo "---" && ls ~/Books ~/Projects ~/ScriptsSTUD 2>/dev/null && echo "Folders OK"
```

## Ce ar trebui să vezi

- Hostname-ul tău (ex: `IP_1001_A`)
- Numele tău de utilizator (ex: `popescu`)
- Ubuntu 24.04
- O adresă IP
- "Folders OK"

---

# 20. Probleme frecvente și soluții

## VirtualBox nu pornește — eroare virtualizare

**Mesaj:** "VT-x is not available" sau "AMD-V is disabled"

**Soluție:** Trebuie să activezi virtualizarea în BIOS:
1. Restartează calculatorul
2. Apasă rapid tasta pentru BIOS (de regulă Del, F2, F10 sau F12)
3. Caută "Virtualization Technology", "VT-x", "AMD-V" sau "SVM"
4. Schimbă din "Disabled" în "Enabled"
5. Salvează și ieși (de regulă F10)

## Ubuntu nu primește IP (bridge nu funcționează)

Verifică:
1. Ești conectat la internet pe calculatorul principal?
2. În VirtualBox Settings → Network, ai selectat interfața corectă?
3. Încearcă să selectezi o altă interfață de rețea

În Ubuntu, încearcă:

```bash
sudo dhclient -v enp0s3
```

## Nu mă pot conecta SSH

Verifică în Ubuntu:

```bash
sudo systemctl status ssh
```

Dacă nu rulează:

```bash
sudo systemctl start ssh
```

Verifică adresa IP:

```bash
hostname -I
```

Din calculatorul principal, testează:
- Windows: `ping 192.168.1.105` (înlocuiește cu IP-ul tău)
- Mac/Linux: `ping -c 3 192.168.1.105`

## Ecran negru la boot

- Așteaptă 1-2 minute (poate fi încărcare lentă)
- Apasă Enter (poate prompt-ul nu e vizibil)
- Verifică Settings → Display → Video Memory: pune 16 MB

## VM-ul este foarte lent

- Mărește RAM: Settings → System → Base Memory (pune 4096 MB dacă ai destul RAM)
- Mărește CPU: Settings → System → Processor (pune 2)
- Închide aplicații pe calculatorul principal

## Am uitat parola

Oprește VM-ul. În VirtualBox, pornește VM-ul în recovery mode:

1. La boot, ține apăsat Shift pentru meniul GRUB
2. Selectează "Advanced options for Ubuntu"
3. Selectează o intrare cu "(recovery mode)"
4. Selectează "root — Drop to root shell"
5. Scrie: `passwd numeletau` (înlocuiește cu username-ul tău)
6. Scrie noua parolă de două ori
7. Scrie: `reboot`

---

# 21. Greșeli frecvente pe care le văd în fiecare an

Acestea sunt greșelile pe care le văd cel mai des la studenți. Învață din experiența lor.

## Greșeala 1: Folosirea NAT în loc de Bridge network

**Simptom:** Poți accesa internetul din VM, dar nu te poți conecta SSH din gazdă

**Rezolvare:** Schimbă Adapter 1 din "NAT" în "Bridged Adapter" în setările VM. Apoi repornește VM-ul.

## Greșeala 2: Interfață de rețea greșită pentru Bridge

**Simptom:** VM-ul nu primește adresă IP sau primește un IP ciudat de genul 169.254.x.x

**Rezolvare:** În VM settings → Network → Bridged Adapter → Name, selectează interfața pe care gazda o folosește efectiv. Dacă ești pe Wi-Fi, selectează adaptorul Wi-Fi. Dacă ești pe cablu, selectează Ethernet.

## Greșeala 3: Uitarea de a bifa "Install OpenSSH server" în timpul instalării

**Simptom:** Nu te poți conecta prin SSH

**Rezolvare:** Instalează-l manual:
```bash
sudo apt install openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh
```

## Greșeala 4: Format hostname greșit

**Simptom:** Verificarea eșuează sau cadrul didactic nu poate identifica lucrările tale

**Formate greșite:**
- ❌ `ion popescu 1001 A` (spațiile nu sunt permise)
- ❌ `IonPopescu_1001_A` (numele complet, nu inițialele)

**Format corect:**
- ✅ `IP_1001_A`

## Greșeala 5: VM-ul nu rulează când încerci să te conectezi SSH

**Simptom:** "Connection refused" sau "Connection timed out"

**Rezolvare:** Asigură-te că VM-ul rulează efectiv în VirtualBox. Fereastra ar trebui să fie deschisă, sau ar trebui să apară în listă ca "Running".

---

# 22. Cum să folosești asistenții AI

## Asistenți recomandați

- **Claude**: https://claude.ai
- **ChatGPT**: https://chat.openai.com

## Reguli de utilizare

✅ **Permis:**
- Explicații pentru concepte
- Ajutor la debugging
- Exemple de cod pentru învățare
- Verificare sintaxă

❌ **Nepermis:**
- Copiere soluții pentru teme
- Generare proiecte complete
- Utilizare la examene

## Exemple de întrebări bune (specifice VirtualBox)

```
"VM-ul meu Ubuntu nu primește IP cu Bridge Adapter. Cum diagnostichez problema?"

"Care e diferența dintre NAT și Bridge networking în VirtualBox? Când folosesc fiecare?"

"Cum pot mări disk-ul VM-ului după ce l-am creat cu 25GB? E posibil fără reinstalare?"

"VBoxManage îmi dă eroare când încerc să pornesc headless. Ce verificări fac?"

"Cum pot face un snapshot înainte de a instala ceva riscant pe VM?"

"De ce VM-ul meu e foarte lent? Am 16GB RAM dar i-am dat doar 2GB."
```

---

# COMENZI RAPIDE

## Gestiune VM (din VirtualBox sau terminal)

| Ce vrei | Cum faci |
|---------|----------|
| Pornește VM headless | `VBoxManage startvm "Ubuntu-Server-2404-SO" --type headless` |
| Oprește VM | `VBoxManage controlvm "Ubuntu-Server-2404-SO" poweroff` |
| Status VM | `VBoxManage showvminfo "Ubuntu-Server-2404-SO" \| grep State` |

## În Ubuntu

| Ce vrei | Comandă |
|---------|---------|
| Actualizare sistem | `sudo apt update && sudo apt -y upgrade` |
| Pornește SSH | `sudo systemctl start ssh` |
| Verifică IP | `hostname -I` |
| Spațiu disk | `df -h` |
| Memorie | `free -h` |
| Salvează istoric | `history > fisier.txt` |
| Ieși | `exit` |

---

# CHECKLIST FINAL

- [ ] VirtualBox instalat și funcțional
- [ ] Extension Pack instalat
- [ ] VM creat (4GB RAM, 2 CPU, 25GB disk)
- [ ] Rețea Bridge configurată și funcțională
- [ ] Ubuntu Server 24.04 instalat
- [ ] Username = numele de familie (ex: popescu)
- [ ] Parola = stud
- [ ] Hostname = INITIALA_GRUPA_SERIA (ex: IP_1001_A)
- [ ] Sistem actualizat
- [ ] Pachete software instalate
- [ ] SSH funcțional
- [ ] PuTTY/Terminal configurat și testat
- [ ] WinSCP/scp funcțional
- [ ] Foldere create
- [ ] Verificare a arătat totul OK

---

# SELF-CHECK: Verifică-ți competențele

Răspunde sincer la următoarele întrebări. Dacă nu poți bifa toate, revizitează secțiunea relevantă.

## Poți face următoarele FĂRĂ să te uiți în ghid?

- [ ] Am rulat cu succes scriptul de verificare (toate cu [OK])
- [ ] M-am conectat SSH din PuTTY/Terminal fără ajutor
- [ ] Am transferat un fișier test cu WinSCP (sau scp pe macOS/Linux)
- [ ] Am transferat un fișier din VM înapoi pe gazda mea (test bidirectional)
- [ ] Am verificat că shell-ul implicit al VM-ului este Bash (`echo $SHELL` → `/bin/bash`)/scp (din host în VM)
- [ ] Știu ce să fac dacă VM-ul nu primește IP (rețea Bridge)
- [ ] Pot porni/opri VM-ul headless din linia de comandă

## Întrebări de verificare rapidă

1. **Ce faci dacă VirtualBox dă eroare "VT-x not available"?**
   → Activezi virtualizarea din BIOS/UEFI (VT-x, AMD-V sau SVM)

2. **Cum verifici IP-ul VM-ului din Ubuntu?**
   → `hostname -I`

3. **Ce comandă oprește VM-ul din terminal?**
   → `VBoxManage controlvm "Ubuntu-Server-2404-SO" poweroff`

4. **De ce ai alege Bridge în loc de NAT pentru rețea?**
   → Bridge dă IP propriu din rețea, accesibil din afară; NAT izolează VM-ul

---

# CE URMEAZĂ?

✅ Ai finalizat **01_INIT_SETUP**

**Pași următori:**
1. Descarcă uneltele pentru înregistrarea temelor → vedeți `02_INIT_HOMEWORKS/`
2. Parcurgeți referința Bash → vedeți `03_GUIDES/01_Bash_Scripting_Guide.md`
3. Veniți la SEM01 cu mediul pregătit

**Dacă se strică ceva mai târziu:**
- Verifică `03_GUIDES/03_Observability_and_Debugging_Guide.md`
- Sau întreabă un asistent AI (Secțiunea 20)

---

**Dacă ai toate bifate:** Ești pregătit pentru SEM01! 🎉

**Dacă îți lipsesc:** Revizitează secțiunea relevantă sau întreabă la seminar.

---

Document pentru:
Academia de Studii Economice București - CSIE
Sisteme de Operare - Anul universitar 2024-2025

**Versiune:** 3.0 | **Ultima actualizare:** Februarie 2025

---

*Pentru probleme, consultă secțiunea „Probleme frecvente" sau întreabă un asistent AI înainte de a contacta cadrul didactic.*
