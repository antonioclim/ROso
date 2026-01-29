# GHID COMPLET DE INSTALARE PENTRU ÎNCEPĂTORI
## Ubuntu Server 24.04 LTS în VirtualBox (Mașină Virtuală)
### Academia de Studii Economice București - CSIE
### Sisteme de Operare - Anul universitar 2024-2025

---

# CITEȘTE ÎNAINTE DE A ÎNCEPE

CÂND SĂ FOLOSEȘTI ACEST GHID?

Acest ghid este o alternativă la WSL2. Folosește-l dacă:
- Ai Mac (macOS) sau Linux în loc de Windows
- Nu poți instala WSL2 pe Windows (versiune veche, restricții)
- Preferi o mașină virtuală completă

CE VEI AVEA LA FINAL?

Un server Ubuntu Linux complet, care rulează într-o fereastră pe calculatorul tău.

CÂT DUREAZĂ?

În jur de 60-90 de minute.

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

*Notă personală: Mulți preferă `zsh`, dar eu rămân la Bash pentru că e standardul pe servere. Consistența bate confortul.*

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

PARTEA 1: PREGĂTIRE
1. [Verifică cerințele sistemului](#1-verifică-cerințele-sistemului)
2. [Descarcă tot ce ai nevoie](#2-descarcă-tot-ce-ai-nevoie)

PARTEA 2: INSTALARE VIRTUALBOX
3. [Instalare pe Windows](#3-instalare-virtualbox-pe-windows)
4. [Instalare pe macOS](#4-instalare-virtualbox-pe-macos)
5. [Instalare pe Linux](#5-instalare-virtualbox-pe-linux)
6. [Instalare Extension Pack (toți)](#6-instalare-extension-pack)

PARTEA 3: CREARE MAȘINĂ VIRTUALĂ
7. [Creează mașina virtuală](#7-creează-mașina-virtuală)
8. [Configurează rețeaua Bridge](#8-configurează-rețeaua-bridge)

PARTEA 4: INSTALARE UBUNTU
9. [Instalează Ubuntu Server](#9-instalează-ubuntu-server)
10. [Configurare după instalare](#10-configurare-după-instalare)
11. [Instalează programele necesare](#11-instalează-programele-necesare)

PARTEA 5: ACCES REMOTE
12. [Configurează SSH](#12-configurează-ssh)
13. [Conectare cu PuTTY (Windows)](#13-conectare-cu-putty-windows)
14. [Conectare cu WinSCP (Windows)](#14-conectare-cu-winscp-windows)
15. [Conectare de pe macOS sau Linux](#15-conectare-de-pe-macos-sau-linux)

PARTEA 6: FINALIZARE
16. [Creează folderele de lucru](#16-creează-folderele-de-lucru)
17. [Verifică instalarea](#17-verifică-instalarea)
18. [Probleme frecvente și soluții](#18-probleme-frecvente-și-soluții)
19. [Cum să folosești asistenții AI](#19-cum-să-folosești-asistenții-ai)

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

Pas 1: Apasă `Ctrl + Shift + Esc` pentru a deschide Task Manager

Pas 2: Click pe tab-ul Performance

Pas 3: Click pe CPU în stânga

Pas 4: Caută în dreapta jos: "Virtualization: Enabled"

Dacă scrie "Disabled", trebuie să activezi virtualizarea din BIOS (vezi secțiunea Probleme frecvente).

### Pe macOS

Pas 1: Deschide Terminal (Finder → Applications → Utilities → Terminal)

*(`find` combinat cu `-exec` e extrem de util. Odată ce-l stăpânești, nu mai poți fără el.)*


Pas 2: Scrie această comandă și apasă Enter:

```bash
sysctl -a | grep machdep.cpu.features | grep VMX
```

Dacă apare text care conține "VMX", virtualizarea este activată. Mac-urile moderne au virtualizarea activată implicit.

Pas 3: Verifică tipul procesorului:

```bash
uname -m
```

- Dacă apare `x86_64` = ai Mac cu procesor Intel
- Dacă apare `arm64` = ai Mac cu procesor Apple Silicon (M1/M2/M3/M4)

**ATENȚIE pentru Mac cu Apple Silicon:** VirtualBox funcționează, dar cu performanță limitată. O alternativă mai bună este UTM (https://mac.getutm.app/).

### Pe Linux

Pas 1: Deschide terminalul

Pas 2: Rulează:

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

Pas 1: Deschide browser-ul și mergi la: https://www.virtualbox.org/wiki/Downloads

Pas 2: Descarcă versiunea pentru sistemul tău:

| Sistemul tău | Ce să descarci |
|--------------|----------------|
| Windows | Click pe "Windows hosts" |
| macOS cu Intel | Click pe "macOS / Intel hosts" |
| macOS cu Apple Silicon | Click pe "macOS / Arm64 hosts" |
| Linux | Click pe "Linux distributions" și alege distribuția ta |

Pas 3: Salvează fișierul în folderul creat mai devreme

## Descarcă Extension Pack

Pas 1: Pe aceeași pagină, la secțiunea "VirtualBox Extension Pack"

Pas 2: Click pe "All supported platforms"

Pas 3: Salvează fișierul (se numește ceva de genul `Oracle_VM_VirtualBox_Extension_Pack-7.x.x.vbox-extpack`)

De reținut: Versiunea Extension Pack TREBUIE să fie aceeași cu versiunea VirtualBox!

## Descarcă Ubuntu Server

Pas 1: Mergi la: https://ubuntu.com/download/server

Pas 2: Click pe "Download Ubuntu Server 24.04 LTS"

Pas 3: Salvează fișierul ISO (în jur de 2.5 GB, poate dura 10-30 minute)

## Ce ar trebui să ai acum

În folderul tău ar trebui să ai 3 fișiere:
1. Installerul VirtualBox (`.exe` pentru Windows, `.dmg` pentru Mac)
2. Extension Pack (`.vbox-extpack`)
3. Ubuntu Server ISO (`ubuntu-24.04-live-server-amd64.iso`)

---

# PARTEA 2: INSTALARE VIRTUALBOX

---

# 3. Instalare VirtualBox pe Windows

Sari acest pas dacă ai macOS sau Linux!

## Rulează installerul

Pas 1: Du-te în folderul `C:\VirtualBox_Kits`

Pas 2: Dublu-click pe fișierul VirtualBox (ex: `VirtualBox-7.x.x-xxxxx-Win.exe`)

Pas 3: Dacă apare "User Account Control" cu întrebarea "Do you want to allow this app to make changes?", click Yes

## Parcurge wizard-ul de instalare

Ecran 1 - Welcome:
- Click Next

Ecran 2 - Custom Setup:
- Lasă totul bifat (toate componentele)
- Click Next

**Ecran 3 - Warning: Network Interfaces:**
- Apare un mesaj că rețeaua va fi deconectată temporar
- Click Yes

Ecran 4 - Missing Dependencies (dacă apare):
- Click Yes pentru a instala dependențele lipsă

Ecran 5 - Ready to Install:
- Click Install

Ecran 6 - Instalare drivere:
- Windows poate întreba de 2-3 ori dacă vrei să instalezi drivere de la Oracle
- Click Install de fiecare dată

Ecran 7 - Finalizare:
- Lasă bifat "Start Oracle VM VirtualBox after installation"
- Click Finish

## Verifică instalarea

VirtualBox ar trebui să se deschidă automat. Dacă nu, caută "VirtualBox" în Start și deschide-l.

---

# 4. Instalare VirtualBox pe macOS

Sari acest pas dacă ai Windows sau Linux!

## Pregătire - Permite aplicații de la Oracle

macOS blochează implicit aplicații de la dezvoltatori "necunoscuți". Trebuie să permiți Oracle:

Pas 1: Deschide System Preferences (sau System Settings pe macOS Ventura și mai nou)

Pas 2: Click pe Security & Privacy (sau Privacy & Security)

Pas 3: Ține minte această fereastră - vei reveni aici

## Instalează VirtualBox

Pas 1: Du-te în folderul `~/VirtualBox_Kits` (în Finder)

Pas 2: Dublu-click pe fișierul `.dmg` (ex: `VirtualBox-7.x.x-xxxxx-macOSIntel.dmg`)

Pas 3: Se deschide o fereastră cu un pachet `.pkg`. Dublu-click pe el.

Pas 4: În wizard-ul de instalare:
- Click Continue la fiecare pas
- Click Install
- Introdu parola Mac-ului tău
- Click Install Software

Pas 5: Dacă apare mesajul "System Extension Blocked":
- Deschide System Preferences → Security & Privacy
- În partea de jos vezi un mesaj despre "Oracle America, Inc."
- Click pe lacătul din stânga jos și introdu parola
- Click Allow

Pas 6: RESTARTEAZĂ Mac-ul! (obligatoriu)

## După restart

Pas 1: Deschide VirtualBox din Applications

Pas 2: Dacă cere permisiuni suplimentare, mergi în System Preferences → Security & Privacy și permite-le

---

# 5. Instalare VirtualBox pe Linux

Sari acest pas dacă ai Windows sau macOS!

## Pe Ubuntu sau Linux Mint sau Debian

Deschide terminalul și rulează aceste comenzi pe rând:

Comanda 1 - Descarcă cheia de semnătură:

```bash
wget -O- https://www.virtualbox.org/download/oracle_vbox_2016.asc | sudo gpg --dearmor --yes --output /usr/share/keyrings/oracle-virtualbox-2016.gpg
```

Când cere parola, scrie parola contului tău și apasă Enter.

Comanda 2 - Adaugă repository-ul VirtualBox:

```bash
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/oracle-virtualbox-2016.gpg] https://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list
```

Comanda 3 - Actualizează lista de pachete:

```bash
sudo apt update
```

Comanda 4 - Instalează VirtualBox:

```bash
sudo apt install -y virtualbox-7.0
```

Comanda 5 - Adaugă utilizatorul tău la grupul vboxusers:

```bash
sudo usermod -aG vboxusers $USER
```

De reținut: Trebuie să te deloghezi și să te loghezi din nou (sau să restartezi) pentru ca grupul să se aplice!

## Pe Fedora

```bash
sudo dnf install -y VirtualBox
```

```bash
sudo usermod -aG vboxusers $USER
```

Deloghează-te și loghează-te din nou.

## Pe Arch Linux sau Manjaro

```bash
sudo pacman -S virtualbox virtualbox-host-modules-arch
```

```bash
sudo modprobe vboxdrv vboxnetadp vboxnetflt
```

```bash
sudo usermod -aG vboxusers $USER
```

Deloghează-te și loghează-te din nou.

## Verifică instalarea

După relogare, deschide VirtualBox din meniul de aplicații.

---

# 6. Instalare Extension Pack

Acest pas este pentru toți: Windows, macOS, și Linux!

Extension Pack adaugă funcționalități importante (USB 3.0, acces remote, etc.).

## Instalare din VirtualBox

Pas 1: Deschide VirtualBox

Pas 2: Din meniu, click pe File → Tools → Extension Pack Manager

(Pe versiuni mai vechi: File → Preferences → Extensions)

Pas 3: Click pe iconița "+" (Install) sau "Install"

Pas 4: Navighează la folderul cu download-uri și selectează fișierul Extension Pack (`Oracle_VM_VirtualBox_Extension_Pack-7.x.x.vbox-extpack`)

Pas 5: Apare licența. Scroll până jos și click I Agree

Pas 6: Dacă cere parola (pe Mac/Linux), introdu-o

Pas 7: Ar trebui să vezi Extension Pack-ul în listă

---

# PARTEA 3: CREARE MAȘINĂ VIRTUALĂ

---

# 7. Creează mașina virtuală

## Pornește wizard-ul

Pas 1: În VirtualBox, click pe butonul New (sau din meniu: Machine → New)

## Configurează - Pas 1: Nume și sistem de operare

Name: `Ubuntu-Server-2404-SO`

Folder: lasă default sau alege un folder cu spațiu

ISO Image: Click pe săgeata dropdown și selectează Other...
- Navighează la folderul cu download-uri
- Selectează fișierul `ubuntu-24.04-live-server-amd64.iso`

Type: `Linux`

Version: `Ubuntu (64-bit)`

De reținut: Bifează "Skip Unattended Installation" - vrem să instalăm manual!

Click Next

## Configurează - Pas 2: Hardware

Base Memory: Trage slider-ul sau scrie `4096` MB (adică 4 GB)
- Dacă ai doar 8 GB RAM total, poți pune 2048 MB (2 GB)

Processors: `2`
- Dacă ai procesor slab, lasă 1

Bifează "Enable EFI" (opțional dar recomandat)

Click Next

## Configurează - Pas 3: Hard Disk

Selectează "Create a Virtual Hard Disk Now"

Disk Size: `25 GB` (minim) sau `50 GB` (dacă ai spațiu)

NU bifa "Pre-allocate Full Size" - lasă-l nebifat

Click Next

## Configurează - Pas 4: Sumar

Verifică setările:
- Name: Ubuntu-Server-2404-SO
- Memory: 4096 MB
- Processors: 2
- Disk: 25 GB

Click Finish

Mașina virtuală este creată! O vezi acum în lista din stânga.

---

# 8. Configurează rețeaua Bridge

## Ce este rețeaua Bridge?

Bridge face ca Ubuntu-ul din VirtualBox să apară ca un calculator separat în rețeaua ta. Va primi o adresă IP de la routerul tău, ca orice alt dispozitiv din casă.

## Configurare

Pas 1: În VirtualBox, selectează mașina `Ubuntu-Server-2404-SO` (click pe ea)

Pas 2: Click pe Settings (sau click dreapta → Settings)

Pas 3: În meniul din stânga, click pe Network

Pas 4: În tab-ul Adapter 1:


Concret: Enable Network Adapter: trebuie să fie bifat ✓. Attached to: selectează "Bridged Adapter" din dropdown. Și Name: selectează interfața de rețea a calculatorului tău:.


### Cum știi ce interfață să selectezi?

Pe Windows:
- Dacă ești conectat prin cablu: alege ceva cu "Ethernet" în nume
- Dacă ești pe Wi-Fi: alege ceva cu "Wi-Fi" sau "Wireless" în nume

Pe macOS:
- Wi-Fi pe MacBook: de regulă `en0`
- Ethernet (dacă ai): de regulă `en1`

Pe Linux:
- Ethernet: `eth0`, `enp3s0`, sau similar
- Wi-Fi: `wlan0`, `wlp2s0`, sau similar

Dacă nu ești sigur, încearcă prima opțiune. Poți schimba mai târziu.

Pas 5: Click OK pentru a salva

---

# PARTEA 4: INSTALARE UBUNTU

---

# 9. Instalează Ubuntu Server

## Pornește mașina virtuală

Pas 1: Selectează `Ubuntu-Server-2404-SO` în VirtualBox

Pas 2: Click pe Start (butonul verde cu săgeată)

Se deschide o fereastră nouă și începe boot-ul de pe ISO.

## Ecranul de boot

Când apare meniul, selectează:

Try or Install Ubuntu Server

Apasă Enter

Așteaptă 1-2 minute să se încarce installerul.

## Instalare - Pas 1: Limba

Folosește săgețile sus/jos pentru a selecta. Selectează:

English

Apasă Enter

## Instalare - Pas 2: Tastatura

Layout: English (US) sau Romanian
Variant: English (US) sau Romanian (Standard)

Recomandare: Lasă English (US) pentru compatibilitate.

Navighează cu Tab până la [ Done ] și apasă Enter

## Instalare - Pas 3: Tipul instalării

Selectează:

(X) Ubuntu Server

Navighează la [ Done ] și apasă Enter

## Instalare - Pas 4: Rețea

Ar trebui să vezi ceva de genul:

```
enp0s3  eth  DHCPv4  192.168.1.xxx/24
```

Aceasta înseamnă că a primit IP automat. Bine!

Dacă vezi `---` în loc de IP, rețeaua nu funcționează. Verifică setările Bridge la pasul 8.

Navighează la [ Done ] și apasă Enter

## Instalare - Pas 5: Proxy

Lasă gol (nu scrie nimic).

Navighează la [ Done ] și apasă Enter

## Instalare - Pas 6: Mirror

Lasă default (sau schimbă la un mirror din România dacă vrei, dar nu e necesar).

Navighează la [ Done ] și apasă Enter

## Instalare - Pas 7: Disk

Selectează:

(X) Use an entire disk

DEBIFEAZĂ (să nu fie X): "Set up this disk as an LVM group"

Navighează la [ Done ] și apasă Enter

## Instalare - Pas 8: Confirmare disk

Vezi un rezumat al partițiilor. Verifică că totul arată OK.

Navighează la [ Done ] și apasă Enter

## Instalare - Pas 9: Confirmare destructivă

Apare un mesaj de avertizare că datele vor fi șterse.

Navighează la [ Continue ] și apasă Enter

## Instalare - Pas 10: Profil utilizator

Aici completezi informațiile tale. Folosește Tab pentru a naviga între câmpuri.

Your name: Prenumele și numele tău (ex: `Ion Popescu`)

Your server's name: Hostname-ul în format INITIALA_GRUPA_SERIA

Exemple:
- Ana Popescu, grupa 1001, seria A → `AP_1001_A`
- Ion Marin Ionescu, grupa 2034, seria B → `IMI_2034_B`

Pick a username: Numele tău de familie, litere mici, fără diacritice

Exemple:

Trei lucruri contează aici: popescu → `popescu`, ștefănescu → `stefanescu`, și bălan → `balan`.


Choose a password: `stud`

Confirm your password: `stud`

Navighează la [ Done ] și apasă Enter

## Instalare - Pas 11: Ubuntu Pro

Selectează:

( ) Skip for now

Navighează la [ Continue ] și apasă Enter

## Instalare - Pas 12: SSH Server

**FOARTE IMPORTANT!**

Bifează:

[X] Install OpenSSH server

Aceasta îți permite să te conectezi de la distanță.

La "Import SSH identity" selectează ( ) No

Navighează la [ Done ] și apasă Enter

## Instalare - Pas 13: Featured Snaps

NU selecta nimic! Lasă totul nebifat.

Navighează la [ Done ] și apasă Enter

## Instalarea propriu-zisă

Acum sistemul se instalează. Vei vedea o bară de progres.

Durează: 5-15 minute

Când se termină, vezi mesajul "Install complete!"

## Finalizare și repornire

Navighează la [ Reboot Now ] și apasă Enter

Dacă vezi un mesaj "Please remove the installation medium", apasă doar Enter.

## Scoate ISO-ul (dacă e necesar)

Dacă după repornire sistemul încearcă să booteze iar de pe ISO:

Pas 1: Închide fereastra VM-ului

Pas 2: Dacă întreabă, selectează "Power off the machine" și click OK

Pas 3: În VirtualBox, selectează mașina → Settings → Storage

Pas 4: Sub "Controller: IDE" sau "Controller: SATA", click pe fișierul ISO

Pas 5: În dreapta, la "Optical Drive", click pe iconița disc și selectează "Remove Disk from Virtual Drive"

Pas 6: Click OK

Pas 7: Pornește din nou mașina virtuală

## Primul login

Când vezi:

```
Ubuntu 24.04 LTS AP_1001_A tty1

AP_1001_A login:
```

Scrie: numele tău de utilizator (ex: `popescu`) și apasă Enter

Password: scrie `stud` și apasă Enter

Observație: Când scrii parola, nu vezi nimic pe ecran - este normal!

🎉 Felicitări! Ai instalat Ubuntu Server!

---

# 10. Configurare după instalare

## Actualizează sistemul

Prima comandă de rulat după instalare:

```bash
sudo apt update && sudo apt -y upgrade
```

Când cere parola, scrie `stud` și apasă Enter.

Așteaptă să se termine (2-10 minute).

## Verifică hostname-ul

```bash
hostname
```

Ar trebui să vezi hostname-ul tău (ex: `AP_1001_A`).

## Configurează timezone-ul

```bash
sudo timedatectl set-timezone Europe/Bucharest
```

Verifică:

```bash
date
```

Ar trebui să vezi data și ora din România.

## Află adresa IP

```bash
hostname -I
```

NOTEAZĂ această adresă IP! (ex: `192.168.1.105`)

O vei folosi pentru a te conecta cu PuTTY sau SSH.

---

# 11. Instalează programele necesare

## Instalează toate pachetele necesare

Copiază și rulează această comandă (este lungă, dar copiaz-o toată):

```bash
sudo apt update && sudo apt install -y build-essential git curl wget nano vim tree htop net-tools man-db manpages-posix software-properties-common gawk sed grep coreutils findutils diffutils moreutils procps sysstat iotop nmon lsof strace dstat tar gzip bzip2 xz-utils zstd zip unzip p7zip-full iproute2 iputils-ping dnsutils netcat-openbsd traceroute nmap tcpdump iftop nethogs gcc g++ make cmake gdb valgrind python3 python3-pip python3-venv shellcheck jq bc expect figlet toilet cowsay tree ncdu pv dialog tmux screen
```

Așteaptă să se termine (5-15 minute).

## Instalează bibliotecile Python

```bash
pip3 install --break-system-packages rich tabulate psutil
```

---

# PARTEA 5: ACCES REMOTE

---

# 12. Configurează SSH

## Verifică că SSH rulează

```bash
sudo systemctl status ssh
```

Ar trebui să vezi "Active: active (running)".

Apasă `q` pentru a ieși din acest ecran.

## Dacă SSH nu rulează

```bash
sudo systemctl start ssh
```

```bash
sudo systemctl enable ssh
```

## Notează adresa IP

```bash
hostname -I
```

Scrie undeva această adresă (ex: `192.168.1.105`).

---

# 13. Conectare cu PuTTY (Windows)

Sari acest pas dacă ai macOS sau Linux!

## Descarcă și instalează PuTTY

Pas 1: Mergi la: https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html

Pas 2: La "MSI (Windows Installer)", descarcă 64-bit x86

Pas 3: Rulează fișierul descărcat și instalează (Next, Next, Install, Finish)

## Deschide PuTTY

Din Start, caută "PuTTY" și deschide-l.

## Configurează conexiunea

În fereastra "PuTTY Configuration":

Host Name (or IP address): scrie adresa IP a VM-ului (ex: `192.168.1.105`)

Port: `22`

Connection type: `SSH` (ar trebui să fie deja selectat)

## Configurează culorile (fundal negru, text alb)

Pas 1: În meniul din stânga, click pe Window → Colours

Pas 2: În lista "Select a colour to adjust":
- Selectează "Default Background"
- Click Modify...
- Setează Red: `0`, Green: `0`, Blue: `0`
- Click OK

Pas 3: Selectează "Default Foreground"
- Click Modify...
- Setează Red: `255`, Green: `255`, Blue: `255`
- Click OK

## Configurează fontul

Pas 1: În meniul din stânga, click pe Window → Appearance

Pas 2: La "Font settings", click Change...

Pas 3: Selectează:
- Font: `Consolas`
- Size: `12`
- Click OK

## Configurează login automat

Pas 1: În meniul din stânga, click pe Connection → Data

Pas 2: La "Auto-login username", scrie numele tău de utilizator (ex: `popescu`)

## Salvează sesiunea

Pas 1: În meniul din stânga, click pe Session (primul)

Pas 2: La "Saved Sessions", scrie: `Ubuntu-VM-SO`

Pas 3: Click Save

## Conectează-te

Pas 1: Asigură-te că VM-ul Ubuntu este pornit în VirtualBox

Pas 2: În PuTTY, selectează sesiunea `Ubuntu-VM-SO`

Pas 3: Click Open

Pas 4: La prima conectare, apare un avertisment de securitate. Click Accept sau Yes.

Pas 5: Dacă cere parola, scrie `stud` și apasă Enter

Acum ai o fereastră PuTTY conectată la Ubuntu!

---

# 14. Conectare cu WinSCP (Windows)

Sari acest pas dacă ai macOS sau Linux!

## Descarcă și instalează WinSCP

Pas 1: Mergi la: https://winscp.net/eng/download.php

Pas 2: Click pe butonul verde "Download WinSCP"

Pas 3: Instalează (Typical installation, Next, Next, Install, Finish)

## Configurează WinSCP

Pas 1: Deschide WinSCP

Pas 2: În fereastra "Login":
- File protocol: `SFTP`
- Host name: adresa IP a VM-ului (ex: `192.168.1.105`)
- Port number: `22`
- User name: numele tău (ex: `popescu`)
- Password: `stud`

Pas 3: Click Save
- Site name: `Ubuntu-VM-SO-Files`
- Bifează "Save password" dacă vrei
- Click OK
- Documentează ce ai făcut pentru referință ulterioară

## Conectează-te

Pas 1: Selectează site-ul salvat

Pas 2: Click Login

Pas 3: La prima conectare, click Yes la avertismentul de securitate

Acum vezi două panouri:
- Stânga: Fișierele din Windows
- Dreapta: Fișierele din Ubuntu

Pentru a transfera fișiere, trage cu mouse-ul dintr-o parte în alta.

---

# 15. Conectare de pe macOS sau Linux

Sari acest pas dacă ai Windows!

## Conectare SSH din Terminal

Pas 1: Deschide Terminal:
- macOS: Finder → Applications → Utilities → Terminal
- Linux: Caută "Terminal" în aplicații

Pas 2: Scrie comanda (înlocuiește cu adresa ta IP și username-ul tău):

```bash
ssh popescu@192.168.1.105
```

Pas 3: La prima conectare, întreabă dacă vrei să continui. Scrie `yes` și apasă Enter.

Pas 4: Scrie parola `stud` și apasă Enter

## Salvează configurația (opțional)

Pentru a nu mai scrie adresa IP de fiecare dată:

Pas 1: Deschide sau creează fișierul de configurare:

```bash
nano ~/.ssh/config
```

Pas 2: Adaugă (înlocuiește cu datele tale):

```
Host ubuntu-vm
    HostName 192.168.1.105
    User popescu
    Port 22
```

Pas 3: Salvează: apasă `Ctrl+O`, apoi `Enter`, apoi `Ctrl+X`

Pas 4: Acum te poți conecta simplu cu:

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
- `put fisier.txt` - trimite fișier
- `get fisier.txt` - primește fișier
- `ls` - listează fișiere
- `exit` - ieși

### Aplicații grafice

- macOS: Cyberduck (gratuit) - https://cyberduck.io/
- Linux: FileZilla - `sudo apt install filezilla`

---

# PARTEA 6: FINALIZARE

---

# 16. Creează folderele de lucru

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

# 17. Verifică instalarea

Rulează această comandă pentru a verifica că totul e OK:

```bash
echo "" && echo "========================================" && echo "   VERIFICARE INSTALARE - SO ASE" && echo "   Ubuntu Server in VirtualBox" && echo "========================================" && echo "" && echo ">>> Informatii sistem:" && echo "Hostname: $(hostname)" && echo "User: $(whoami)" && echo "Ubuntu: $(lsb_release -d 2>/dev/null | cut -f2)" && echo "Kernel: $(uname -r)" && echo "" && echo ">>> Retea:" && echo "IP: $(hostname -I | awk '{print $1}')" && ping -c 1 google.com > /dev/null 2>&1 && echo "Internet: OK" || echo "Internet: FARA CONEXIUNE" && echo "" && echo ">>> Comenzi esentiale:" && for cmd in bash git nano vim gcc python3 ssh tree htop awk sed grep find tar gzip nmap; do command -v $cmd > /dev/null 2>&1 && echo "  [OK] $cmd" || echo "  [LIPSA] $cmd"; done && echo "" && echo ">>> SSH:" && systemctl is-active ssh > /dev/null 2>&1 && echo "  SSH server: ACTIV" || echo "  SSH server: INACTIV" && echo "" && echo ">>> Foldere:" && for dir in Books HomeworksOLD Projects ScriptsSTUD test TXT; do [ -d ~/$dir ] && echo "  [OK] ~/$dir" || echo "  [LIPSA] ~/$dir"; done && echo "" && echo "========================================" && echo "   VERIFICARE COMPLETA!" && echo "   Conecteaza-te cu: ssh $(whoami)@$(hostname -I | awk '{print $1}')" && echo "========================================"
```

---

# 18. Probleme frecvente și soluții

## VirtualBox nu pornește - eroare virtualizare

Mesaj: "VT-x is not available" sau "AMD-V is disabled"

Soluție: Trebuie să activezi virtualizarea în BIOS:
1. Restartează calculatorul
2. Apasă rapid tasta pentru BIOS (de regulă Del, F2, F10, sau F12)
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
- Documentează ce ai făcut pentru referință ulterioară

## Am uitat parola

Oprește VM-ul. În VirtualBox, pornește VM-ul în recovery mode:

1. La boot, ține apăsat Shift pentru meniul GRUB
2. Selectează "Advanced options for Ubuntu"
3. Selectează o intrare cu "(recovery mode)"
4. Selectează "root - Drop to root shell"
5. Scrie: `passwd numeletau` (înlocuiește cu username-ul tău)
6. Scrie noua parolă de două ori
7. Scrie: `reboot`

---

# 19. Cum să folosești asistenții AI

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
- [ ] Hostname = INITIALA_GRUPA_SERIA (ex: AP_1001_A)
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

- [ ] ✅ Am rulat cu succes scriptul de verificare (toate cu [OK])
- [ ] ✅ M-am conectat SSH din PuTTY/Terminal fără ajutor
- [ ] ✅ Am transferat un fișier test cu WinSCP/scp (din host în VM)
- [ ] ✅ Știu ce să fac dacă VM-ul nu primește IP (rețea Bridge)
- [ ] ✅ Pot porni/opri VM-ul headless din linia de comandă

## Întrebări de verificare rapidă

1. **Ce faci dacă VirtualBox dă eroare "VT-x not available"?**
   → Activezi virtualizarea din BIOS/UEFI (VT-x, AMD-V, sau SVM)

2. **Cum verifici IP-ul VM-ului din Ubuntu?**
   → `hostname -I`

3. **Ce comandă oprește VM-ul din terminal?**
   → `VBoxManage controlvm "Ubuntu-Server-2404-SO" poweroff`

4. **De ce ai alege Bridge în loc de NAT pentru rețea?**
   → Bridge dă IP propriu din rețea, accesibil din afară; NAT izolează VM-ul

---

**Dacă ai toate bifate:** Ești pregătit pentru SEM01! 🎉

**Dacă îți lipsesc:** Revizitează secțiunea relevantă sau întreabă la seminar.

---

Document pentru:
Academia de Studii Economice București - CSIE
Sisteme de Operare - 2024-2025

Versiune: 2.1 - Ghid pentru începători (cu Learning Outcomes)
Ultima actualizare: Ianuarie 2025

---

*Pentru probleme, consultă secțiunea "Probleme frecvente" sau întreabă un asistent AI.*
