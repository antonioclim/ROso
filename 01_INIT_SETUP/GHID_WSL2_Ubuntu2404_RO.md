# GHID COMPLET DE INSTALARE PENTRU ÎNCEPĂTORI
## Ubuntu 24.04 LTS pe WSL2 (Windows Subsystem for Linux)

*(WSL2 a schimbat complet modul în care predau — acum studenții pot exersa Linux fără dual boot.)*

### Academia de Studii Economice București - CSIE
### Sisteme de Operare - Anul universitar 2024-2025

> **Observație din laborator:** În practică, cele mai multe probleme la WSL2 vin din două locuri: (1) feature-urile de virtualizare dezactivate în BIOS/UEFI sau în Windows, și (2) un reboot „sărit" după instalare. Verifică rapid cu `wsl --status` și `wsl --list --verbose` înainte să reinventezi roata.

---

# CITEȘTE ÎNAINTE DE A ÎNCEPE

**CE ESTE ACEST GHID?**

Acest ghid te va învăța pas cu pas cum să instalezi Linux pe calculatorul tău cu Windows. Nu ai nevoie de cunoștințe anterioare — totul este explicat de la zero.

**CE VEI AVEA LA FINAL?**

Un sistem Linux (Ubuntu) care rulează direct în Windows, pe care îl vei folosi la seminarii pentru a învăța comenzi și scripting.

**CÂT DUREAZĂ?**

În jur de 45-70 de minute, în funcție de viteza internetului. Folosește checkpoint-urile de timp de mai jos pentru a-ți urmări progresul.

**CE AI NEVOIE?**

- Calculator cu Windows 10 sau Windows 11
- Conexiune la internet
- Minim 10 GB spațiu liber pe disk
- O ceașcă de cafea (opțional dar recomandat)

---

# ⏱️ CHECKPOINT-URI DE TIMP

Folosește-le pentru a-ți urmări progresul. A dura mai mult decât estimat e normal pentru prima instalare.

| Checkpoint | Secțiune | Timp estimat | Timpul tău |
|------------|----------|--------------|------------|
| 🚀 Start | — | 0 min | ⬜ |
| ✓ WSL2 activat, calculator restartat | Secțiunea 2 | 15 min | ⬜ |
| ✓ Ubuntu instalat, cont creat | Secțiunea 4 | 30 min | ⬜ |
| ✓ Sistem actualizat | Secțiunea 5 | 40 min | ⬜ |
| ✓ Hostname configurat | Secțiunea 6 | 45 min | ⬜ |
| ✓ Tot software-ul instalat | Secțiunea 7 | 55 min | ⬜ |
| ✓ SSH + PuTTY funcțional | Secțiunea 9 | 65 min | ⬜ |
| 🎉 Verificarea a trecut | Secțiunea 12 | 70 min | ⬜ |

---

# LEARNING OUTCOMES (Ce vei ști să faci după acest ghid)

La finalul acestui ghid, vei putea:

- [ ] **LO1:** Să verifici dacă sistemul tău Windows suportă WSL2 (virtualizare activă, versiune Windows compatibilă)
- [ ] **LO2:** Să activezi și configurezi WSL2 din PowerShell ca Administrator
- [ ] **LO3:** Să instalezi și configurezi Ubuntu 24.04 LTS cu user corect (numele de familie) și hostname în format `INITIALA_GRUPA_SERIA`
- [ ] **LO4:** Să pornești/oprești serviciul SSH și să te conectezi remote cu PuTTY
- [ ] **LO5:** Să transferi fișiere între Windows și Ubuntu folosind WinSCP sau drag & drop
- [ ] **LO6:** Să diagnostichezi și rezolvi cele mai frecvente 3 probleme: virtualizare dezactivată, SSH care nu pornește, parolă uitată

---

# CUPRINS

1. [Verifică dacă poți instala WSL2](#1-verifică-dacă-poți-instala-wsl2)
2. [Activează funcțiile necesare în Windows](#2-activează-funcțiile-necesare-în-windows)
3. [Instalează Ubuntu](#3-instalează-ubuntu)
4. [Configurează-ți contul Linux](#4-configurează-ți-contul-linux)
5. [Actualizează sistemul](#5-actualizează-sistemul)
6. [Configurează numele calculatorului](#6-configurează-numele-calculatorului)
7. [Instalează programele necesare](#7-instalează-programele-necesare)
8. [Configurează accesul SSH](#8-configurează-accesul-ssh)
9. [Instalează și configurează PuTTY](#9-instalează-și-configurează-putty)
10. [Instalează și configurează WinSCP](#10-instalează-și-configurează-winscp)
11. [Creează folderele de lucru](#11-creează-folderele-de-lucru)
12. [Verifică instalarea](#12-verifică-instalarea)
13. [Probleme frecvente și soluții](#13-probleme-frecvente-și-soluții)
14. [Greșeli frecvente pe care le văd în fiecare an](#14-greșeli-frecvente-pe-care-le-văd-în-fiecare-an)
15. [Cum să folosești asistenții AI](#15-cum-să-folosești-asistenții-ai)

---

# CUM SĂ CITEȘTI ACEST GHID

## Tipuri de comenzi

În acest ghid vei vedea două tipuri de comenzi:

### Comenzi PowerShell (Windows)

Acestea se rulează în Windows și au fundal albastru:

```powershell
# POWERSHELL (Windows) - Fundal albastru
# Aceasta este o comandă PowerShell
wsl --version
```

### Comenzi Bash (Linux/Ubuntu)

Acestea se rulează în Ubuntu și au fundal negru:

```bash
# BASH (Ubuntu/Linux) - Fundal negru
# Aceasta este o comandă Linux
ls -la
```

## Cum să copiezi și lipești comenzile

1. Selectează comanda cu mouse-ul (textul din chenarul gri)
2. Copiază cu `Ctrl+C`
3. Lipește în terminal:
   - În PowerShell: `Ctrl+V` sau click dreapta
   - În Ubuntu/Bash: `Ctrl+Shift+V` sau click dreapta

**De reținut:** Copiază EXACT comanda afișată, fără să modifici nimic (decât unde scrie explicit să înlocuiești ceva).

---

# 1. Verifică dacă poți instala WSL2

## Ce este WSL2?

> **Recomandare personală:** WSL2 e soluția pe care o recomand studenților. Am testat VirtualBox, dual-boot, containere Docker — WSL2 oferă cel mai bun echilibru între simplitate și funcționalitate. Plus că nu trebuie să reporniți calculatorul de 5 ori pe seminar, ceea ce e un mare plus.

WSL2 (Windows Subsystem for Linux 2) este o funcție Windows care îți permite să rulezi Linux direct în Windows, fără să instalezi un alt sistem de operare separat.

## Verifică versiunea Windows

**Pas 1:** Apasă tastele `Windows + R` în același timp

**Pas 2:** Se deschide o fereastră mică numită "Run". Scrie în ea:
```
winver
```

**Pas 3:** Apasă `Enter` sau click pe `OK`

**Pas 4:** Se deschide o fereastră cu informații despre Windows. Caută:
- Windows 10: Trebuie să ai versiunea 2004 sau mai nouă (Build 19041 sau mai mare)
- Windows 11: Orice versiune funcționează

Dacă ai o versiune mai veche, trebuie să actualizezi Windows înainte să mergi mai departe.

## Verifică dacă virtualizarea este activată

**Pas 1:** Apasă tastele `Ctrl + Shift + Esc` în același timp

**Pas 2:** Se deschide Task Manager. Dacă vezi o fereastră simplă, click pe "More details" în stânga jos.

**Pas 3:** Click pe tab-ul "Performance" (sau "Performanță")

**Pas 4:** Click pe "CPU" în stânga

**Pas 5:** Caută în dreapta jos textul "Virtualization:"
- Dacă scrie "Enabled" sau "Activat" — ești OK, continuă la pasul următor
- Dacă scrie "Disabled" sau "Dezactivat" — trebuie să activezi virtualizarea din BIOS (vezi Secțiunea 13)

> **Poveste adevărată din 2023:** Un student a petrecut 3 ore încercând să repare „WSL nu pornește" — s-a dovedit că laptopul lui gaming avea virtualizarea dezactivată de producător. O singură setare BIOS, problema rezolvată. Verifică întotdeauna virtualizarea mai întâi.

---

# 2. Activează funcțiile necesare în Windows

## Deschide PowerShell ca Administrator

**FOARTE IMPORTANT:** Trebuie să deschizi PowerShell ca Administrator, altfel comenzile nu vor funcționa!

**Metoda 1 (Recomandată):**
1. Click pe butonul `Start` (colțul stânga jos)
2. Scrie: `powershell`
3. În rezultate apare "Windows PowerShell"
4. Click **DREAPTA** pe el (nu click stânga!)
5. Selectează "Run as administrator" sau "Executare ca administrator"
6. Apare o fereastră care întreabă "Permiteți acestei aplicații să facă modificări?" — click "Yes" sau "Da"

**Metoda 2:**
1. Apasă tastele `Windows + X` în același timp
2. Din meniul care apare, selectează "Windows PowerShell (Admin)" sau "Terminal (Admin)"
3. Click "Yes" sau "Da" la întrebarea despre permisiuni

**Cum știi că ești Administrator?** Titlul ferestrei trebuie să conțină cuvântul "Administrator". Exemplu: "Administrator: Windows PowerShell"

## Activează WSL și Virtual Machine Platform

Acum vei rula câteva comenzi. Copiază fiecare comandă și lipește-o în PowerShell, apoi apasă Enter.

**Comanda 1 — Activează WSL:**

```powershell
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
```

Așteaptă să se termine (poate dura 1-2 minute). Vei vedea mesajul "The operation completed successfully."

**Comanda 2 — Activează Virtual Machine Platform:**

```powershell
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
```

Așteaptă să se termine. Din nou vei vedea "The operation completed successfully."

## RESTARTEAZĂ CALCULATORUL

**⚠️ OBLIGATORIU:** Trebuie să restartezi calculatorul acum!

1. Salvează orice lucru deschis
2. Click Start → Power → Restart (sau Repornire)
3. Așteaptă să repornească complet

> **Observație din laborator:** Aproximativ 20% din studenți uită să restarteze după activarea funcțiilor WSL2. Comenzile reușesc, dar nimic nu funcționează până nu repornești. Acum îi fac pe toți să restarteze înainte de a continua — economisește ore de confuzie.

---

# 3. Instalează Ubuntu

## Deschide din nou PowerShell ca Administrator

După restart, deschide din nou PowerShell ca Administrator (vezi instrucțiunile de la pasul anterior).

## Instalează actualizarea pentru kernel-ul WSL2

**Comanda 1 — Descarcă actualizarea:**

```powershell
Invoke-WebRequest -Uri https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi -OutFile wsl_update_x64.msi -UseBasicParsing
```

Așteaptă să se descarce (poate dura 1-2 minute în funcție de internet).

**Comanda 2 — Instalează actualizarea:**

```powershell
msiexec /i wsl_update_x64.msi /quiet
```

Așteaptă câteva secunde.

**Comanda 3 — Setează WSL2 ca versiune implicită:**

```powershell
wsl --set-default-version 2
```

**Comanda 4 — Actualizează WSL la ultima versiune:**

```powershell
wsl --update
```

## Instalează Ubuntu 24.04 LTS

**Comanda 5 — Instalează Ubuntu:**

```powershell
wsl --install -d Ubuntu-24.04
```

Ce se întâmplă acum: Windows descarcă Ubuntu (în jur de 2 GB). Poate dura 5-15 minute în funcție de viteza internetului. La final, se va deschide automat o fereastră nouă cu Ubuntu.

Ia-ți cafeaua acum — e un moment bun.

---

# 4. Configurează-ți contul Linux

## Fereastra Ubuntu

După instalare, se deschide automat o fereastră neagră (terminalul Ubuntu). Dacă nu s-a deschis, caută "Ubuntu" în Start și deschide-l.

## Creează-ți utilizatorul

Ubuntu îți va cere să creezi un cont. Vei vedea mesajul:

```
Enter new UNIX username:
```

**CE SĂ TASTEZI:** Numele tău de familie, cu litere mici, fără diacritice.

Exemple:
- Dacă te numești `Popescu Ion` → tastează: `popescu`
- Dacă te numești `Ionescu Maria` → tastează: `ionescu`
- Dacă te numești Ștefănescu Dan → tastează: `stefanescu`
- Dacă te numești Bălan Ana → tastează: `balan`

Tastează numele și apasă Enter.

## Creează parola

Vei vedea:
```
New password:
```

**CE SĂ TASTEZI:** `stud`

**⚠️ FOARTE IMPORTANT:** Când tastezi parola, NU VEI VEDEA NIMIC PE ECRAN — nicio steluță, niciun punct, nimic! Asta e normal pentru Linux. Tastează parola și apasă Enter.

Da, parola este literalmente "stud". Nu, nu e cea mai sigură parolă din lume. Da, e OK pentru un mediu de învățare. Te rog nu folosi "stud" pentru contul tău de bancă.

Vei vedea:
```
Retype new password:
```

Tastează `stud` din nou și apasă Enter.

## Gata!

Dacă totul a mers bine, vei vedea un mesaj de bun venit și un prompt care arată cam așa:

```
popescu@DESKTOP-XXXXX:~$
```

(În loc de "popescu" va fi numele tău de familie, iar în loc de "DESKTOP-XXXXX" va fi numele calculatorului tău)

Felicitări! Ai instalat Ubuntu! Acum ești în Linux și poți rula comenzi.

---

# 5. Actualizează sistemul

## Ce înseamnă asta?

La fel cum Windows are Windows Update, Linux are propriul sistem de actualizări. Trebuie să actualizezi sistemul pentru a avea ultimele versiuni de programe și patch-uri de securitate.

## Rulează actualizarea

În fereastra Ubuntu (cea neagră), copiază și lipește următoarea comandă, apoi apasă Enter:

```bash
sudo apt update && sudo apt -y upgrade
```

Ce se întâmplă:
- `sudo` = rulează comanda cu drepturi de administrator
- Sistemul va cere parola ta (`stud`)
- Din nou, nu vei vedea parola când o tastezi — tasteaz-o și apasă Enter
- `apt update` = verifică ce actualizări sunt disponibile
- `apt upgrade` = instalează actualizările
- `-y` = răspunde automat "da" la întrebări

**Cât durează:** 2-10 minute, în funcție de câte actualizări sunt.

Vei vedea mult text pe ecran — asta e normal. Așteaptă până când reapare promptul (linia care se termină cu `$`).

---

# 6. Configurează numele calculatorului

## De ce e important?

În curs, fiecare student trebuie să aibă un "hostname" (nume de calculator) unic care te identifică. Formatul este:

**Format:** `INITIALA_GRUPA_SERIA`

Exemple:
- Ana Popescu, grupa 1001, seria A → `AP_1001_A`
- Ion Marin Ionescu, grupa 2034, seria B → `IMI_2034_B`
- Maria Stan, grupa 1502, seria C → `MS_1502_C`

## Găsește-ți datele

Înainte de a merge mai departe, notează-ți:
- Inițialele tale: Prima literă din prenume + prima literă din numele de familie (sau mai multe dacă ai nume compus)
- Grupa ta: Numărul grupei (ex: 1001, 2034)
- Seria ta: A, B, C, etc.

## Creează fișierul de configurare

Următoarea comandă va crea fișierul de configurare. **ÎNLOCUIEȘTE** `INITIALA_GRUPA_SERIA` cu hostname-ul tău (ex: `AP_1001_A`).

```bash
sudo tee /etc/wsl.conf << 'EOF'
[network]
hostname = INITIALA_GRUPA_SERIA
generateHosts = false

[boot]
systemd = true
EOF
```

**Exemplu concret** pentru Ana Popescu, grupa 1001, seria A:

```bash
sudo tee /etc/wsl.conf << 'EOF'
[network]
hostname = AP_1001_A
generateHosts = false

[boot]
systemd = true
EOF
```

Dacă cere parola, tastează `stud` și apasă Enter.

## Adaugă hostname-ul în fișierul hosts

Din nou, **ÎNLOCUIEȘTE** `INITIALA_GRUPA_SERIA` cu hostname-ul tău:

```bash
echo "127.0.0.1    INITIALA_GRUPA_SERIA" | sudo tee -a /etc/hosts
```

**Exemplu concret** pentru Ana Popescu, grupa 1001, seria A:

```bash
echo "127.0.0.1    AP_1001_A" | sudo tee -a /etc/hosts
```

## Aplică modificările

Pentru ca modificările să aibă efect, trebuie să repornești Ubuntu.

**Pas 1:** Închide fereastra Ubuntu (tastează `exit` și apasă Enter, sau închide fereastra)

**Pas 2:** Deschide PowerShell (nu trebuie să fie Administrator de data asta) și rulează:

```powershell
wsl --shutdown
```

**Pas 3:** Deschide Ubuntu din nou din Start

## Verifică hostname-ul

În Ubuntu, rulează:

```bash
hostname
```

Ar trebui să vezi hostname-ul tău (ex: `AP_1001_A`). Dacă vezi altceva, repetă pașii de mai sus.

---

# 7. Instalează programele necesare

## Ce sunt aceste programe?

Pentru seminarii și proiecte, vei avea nevoie de diverse unelte Linux. Această comandă le instalează pe toate deodată.

## Instalează tot ce ai nevoie

Copiază și lipește această comandă în Ubuntu:

```bash
sudo apt update && sudo apt install -y build-essential git curl wget nano vim tree htop net-tools openssh-server man-db manpages-posix gawk sed grep coreutils findutils diffutils procps sysstat lsof tar gzip bzip2 xz-utils zstd zip unzip p7zip-full iproute2 iputils-ping dnsutils netcat-openbsd traceroute nmap tcpdump gcc g++ make cmake gdb valgrind python3 python3-pip python3-venv shellcheck jq bc figlet cowsay ncdu pv dialog
```

Ce se întâmplă:
- Sistemul descarcă și instalează toate programele necesare
- Poate dura 5-15 minute
- Vei vedea mult text pe ecran — asta e normal
- Așteaptă până când reapare promptul `$`

## Instalează bibliotecile Python necesare

```bash
pip3 install --break-system-packages rich tabulate psutil
```

---

# 8. Configurează accesul SSH

## Ce este SSH?

SSH (Secure Shell) este un protocol care îți permite să te conectezi la un calculator Linux de la distanță. Vom instala serverul SSH pentru a putea folosi PuTTY mai târziu.

## Pornește serviciul SSH

```bash
sudo service ssh start
```

## Verifică că funcționează

```bash
sudo service ssh status
```

Ar trebui să vezi ceva de genul "Active: active (running)". Apasă tasta `q` pentru a ieși din acest ecran.

## Află adresa IP

Pentru a te conecta cu PuTTY, ai nevoie de adresa IP a Ubuntu. Rulează:

```bash
hostname -I
```

Vei vedea o adresă de genul `172.XX.XX.XX`. **NOTEAZ-O** — o vei folosi la pasul următor.

---

# 9. Instalează și configurează PuTTY

## Ce este PuTTY?

PuTTY este un program Windows care îți permite să te conectezi la Linux prin SSH. E ca un alt tip de fereastră pentru a lucra în Ubuntu.

## Descarcă PuTTY

**Pas 1:** Deschide browser-ul (Chrome, Firefox, Edge)

**Pas 2:** Mergi la adresa: https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html

**Pas 3:** La secțiunea "MSI (Windows Installer)", descarcă versiunea 64-bit x86. Fișierul se numește ceva de genul `putty-64bit-0.XX-installer.msi`

**Pas 4:** Deschide fișierul descărcat și instalează PuTTY:
- Click Next, apoi Next din nou
- Click Install
- Click Yes dacă întreabă despre permisiuni
- Click Finish

## Deschide PuTTY

**Pas 1:** Click pe Start și tastează "PuTTY"

**Pas 2:** Deschide aplicația "PuTTY"

## Configurează conexiunea

Se deschide fereastra "PuTTY Configuration". În stânga vezi un meniu cu categorii.

În ecranul principal (Session):
- Host Name (or IP address): tastează adresa IP pe care ai notat-o mai devreme (ex: `172.24.123.45`)
- Port: `22` (ar trebui să fie deja)
- Connection type: selectează `SSH`

## Configurează aspectul — Culori (fundal negru, text alb)

**Pas 1:** În meniul din stânga, click pe `Window` (pentru a-l extinde), apoi click pe `Colours`

**Pas 2:** În lista "Select a colour to adjust", selectează "Default Background"

**Pas 3:** Click pe butonul "Modify..."

**Pas 4:** În fereastra de culori:
- Red: `0`
- Green: `0`
- Blue: `0`
- Click `OK`

**Pas 5:** Acum selectează "Default Foreground" din listă

**Pas 6:** Click "Modify..."

**Pas 7:** În fereastra de culori:
- Red: `255`
- Green: `255`
- Blue: `255`
- Click `OK`

## Configurează fontul

**Pas 1:** În meniul din stânga, click pe `Window`, apoi pe `Appearance`

**Pas 2:** La "Font settings", click pe Change...

**Pas 3:** Selectează:
- Font: `Consolas` sau `Lucida Console`
- Style: `Regular`
- Size: `12`
- Click `OK`

## Configurează utilizatorul automat

**Pas 1:** În meniul din stânga, click pe `Connection`, apoi pe `Data`

**Pas 2:** La "Auto-login username" tastează numele tău de utilizator (numele de familie cu litere mici, ex: `popescu`)

## Salvează configurația

**Pas 1:** În meniul din stânga, click pe `Session` (primul din listă)

**Pas 2:** La "Saved Sessions" tastează: `Ubuntu-WSL2`

**Pas 3:** Click pe butonul `Save`

## Conectează-te!

**Pas 1:** Asigură-te că Ubuntu rulează (deschide fereastra Ubuntu dacă nu e deschisă)

**Pas 2:** În PuTTY, selectează sesiunea `Ubuntu-WSL2` din listă

**Pas 3:** Click pe `Open`

**Pas 4:** La prima conectare, apare un mesaj de securitate despre "host key". Click `Accept` sau `Yes`.

**Pas 5:** Dacă cere parola, tastează `stud` și apasă Enter

Gata! Acum ai o fereastră PuTTY conectată la Ubuntu-ul tău.

---

# 10. Instalează și configurează WinSCP

## Ce este WinSCP?

WinSCP este un program care îți permite să transferi fișiere între Windows și Linux. E ca un Explorer pentru fișierele Linux.

## Descarcă WinSCP

**Pas 1:** Mergi la: https://winscp.net/eng/download.php

**Pas 2:** Click pe butonul verde "Download WinSCP"

**Pas 3:** Deschide fișierul descărcat și instalează:
- Selectează "Typical installation"
- Click Next, Next, Install
- Click Finish

## Configurează conexiunea

**Pas 1:** Deschide WinSCP din Start

**Pas 2:** În fereastra "Login" care apare:
- File protocol: `SFTP` (ar trebui să fie deja)
- Host name: adresa IP a Ubuntu (ex: `172.24.123.45`)
- Port number: `22`
- User name: numele tău de utilizator (ex: `popescu`)
- Password: `stud`

**Pas 3:** Click pe `Save`

**Pas 4:** Dă sesiunii un nume: `Ubuntu-WSL2-Files`

**Pas 5:** Bifează "Save password" dacă nu vrei să introduci parola de fiecare dată

**Pas 6:** Click `OK`

## Conectează-te și transferă fișiere

**Pas 1:** Asigură-te că Ubuntu rulează

**Pas 2:** Selectează sesiunea salvată și click `Login`

**Pas 3:** La prima conectare, click `Yes` la mesajul de securitate

**Pas 4:** Acum vezi două panouri:
- Stânga: Fișierele tale din Windows
- Dreapta: Fișierele din Ubuntu

**Pas 5:** Pentru a transfera fișiere, pur și simplu trage (drag & drop) din stânga în dreapta sau invers

---

# 11. Creează folderele de lucru

## De ce ai nevoie de o structură de foldere?

La seminarii vei crea multe fișiere. Organizarea lor îți economisește timp mai târziu când trebuie să găsești ceva.

## Creează folderele

În Ubuntu (fie în fereastra neagră, fie prin PuTTY), rulează:

```bash
mkdir -p ~/Books ~/HomeworksOLD ~/Projects ~/ScriptsSTUD ~/test ~/TXT
```

## Ce face fiecare folder

| Folder | Pentru ce îl folosești |
|--------|------------------------|
| `Books` | Cărți, PDF-uri, materiale de studiu |
| `HomeworksOLD` | Teme vechi, pentru referință |
| `Projects` | Proiectul de semestru și alte proiecte |
| `ScriptsSTUD` | Scripturile pe care le faci la seminarii |
| `test` | Folder pentru teste și experimente |
| `TXT` | Fișiere text diverse, notițe |

## Verifică că s-au creat

```bash
ls -la ~
```

Ar trebui să vezi toate folderele listate.

---

# 12. Verifică instalarea

## Rulează scriptul de verificare

Am pregătit un script de verificare care verifică totul automat.

**Opțiunea 1 — Folosește scriptul furnizat (recomandat):**

Dacă ai fișierul `verify_installation.sh`, copiază-l în directorul home și rulează:

```bash
bash ~/verify_installation.sh
```

**Opțiunea 2 — Verificare rapidă într-o linie:**

Dacă nu ai scriptul, rulează această comandă pentru o verificare rapidă:

```bash
hostname && whoami && lsb_release -d && hostname -I && echo "---" && ls ~/Books ~/Projects ~/ScriptsSTUD 2>/dev/null && echo "Folders OK"
```

## Ce ar trebui să vezi

Dacă totul este OK, ar trebui să vezi:
- Hostname-ul tău (ex: `AP_1001_A`)
- Username-ul tău (ex: `popescu`)
- Ubuntu 24.04
- O adresă IP
- "Folders OK"

Dacă vezi erori sau elemente cu [LIPSĂ], verifică pașii anteriori.

---

# 13. Probleme frecvente și soluții

## Problema: "WSL 2 requires an update to its kernel component"

**Soluție:** Deschide PowerShell ca Administrator și rulează:

```powershell
wsl --update
```

Apoi restartează calculatorul.

## Problema: Virtualizarea nu este activată

**Soluție:**

1. Restartează calculatorul
2. Când pornește, apasă rapid tasta pentru BIOS (de regulă `Del`, `F2`, `F10` sau `F12` — depinde de producător)
3. Caută în meniuri opțiunea "Virtualization Technology", "VT-x", "AMD-V" sau "SVM"
4. Activează opțiunea (schimbă din "Disabled" în "Enabled")
5. Salvează și ieși (de regulă tasta `F10`)
6. Calculatorul va reporni

## Problema: Nu pot lipi comenzi în Ubuntu

**Soluție:** În fereastra Ubuntu, folosește click dreapta pentru a lipi, sau `Ctrl+Shift+V` (nu doar `Ctrl+V`).

## Problema: Am uitat parola

**Soluție:** Deschide PowerShell și rulează:

```powershell
wsl -u root
```

Acum ești root (administrator). Schimbă parola utilizatorului tău (înlocuiește `numeletau` cu username-ul tău):

```bash
passwd numeletau
```

Scrie noua parolă de două ori, apoi scrie `exit` pentru a ieși.

## Problema: SSH nu pornește

**Soluție:** Rulează în Ubuntu:

```bash
sudo apt install --reinstall openssh-server
```

Apoi:

```bash
sudo service ssh start
```

## Problema: Nu mă pot conecta cu PuTTY

Verifică:

1. Ubuntu rulează? (fereastra neagră trebuie să fie deschisă)
2. SSH-ul este pornit? Rulează în Ubuntu: `sudo service ssh status`
3. Adresa IP este corectă? Rulează în Ubuntu: `hostname -I`
4. Firewall-ul Windows nu blochează? Încearcă să dezactivezi temporar firewall-ul

## Problema: Mesaj "Error: 0x80370102"

**Cauză:** Virtualizarea nu este activată în BIOS.

**Soluție:** Vezi mai sus la "Virtualizarea nu este activată".

---

# 14. Greșeli frecvente pe care le văd în fiecare an

Acestea sunt greșelile pe care le văd cel mai des la studenți. Învață din experiența lor.

## Greșeala 1: Nu rulează PowerShell ca Administrator

**Simptom:** "Access denied" sau comanda nu face nimic

**Rezolvare:** Click dreapta → Run as administrator. Titlul ferestrei trebuie să conțină "Administrator".

## Greșeala 2: Tastează parola și se așteaptă să o vadă

**Simptom:** "Am tastat parola dar nu s-a întâmplat nimic"

**Realitatea:** Linux NICIODATĂ nu arată caracterele parolei — nici măcar puncte sau steluțe. Pur și simplu tastează orb și apasă Enter. Aceasta este o funcție de securitate, nu un bug.

## Greșeala 3: Sar peste restart după activarea WSL2

**Simptom:** `wsl --install` eșuează cu erori ciudate

**Rezolvare:** Nu există scurtătură aici. După activarea WSL și Virtual Machine Platform, trebuie să restartezi. Închide totul, restartează, apoi continuă.

## Greșeala 4: Format hostname greșit

**Simptom:** Verificarea eșuează sau cadrul didactic nu poate identifica lucrările tale

**Formate greșite:**
- ❌ `ana popescu 1001 A` (spațiile nu sunt permise)
- ❌ `AnaPopescu_1001_A` (numele complet, nu inițialele)
- ❌ `ap_1001_a` (litere mici — ar trebui să fie majuscule)

**Format corect:**
- ✅ `AP_1001_A`

## Greșeala 5: Închide fereastra Ubuntu crezând că oprește WSL

**Simptom:** Procese WSL încă rulează în fundal, IP-ul se schimbă

**Rezolvare:** Pentru a opri complet WSL, rulează `wsl --shutdown` din PowerShell. Închiderea ferestrei doar o ascunde.

---

# 15. Cum să folosești asistenții AI

## Asistenți recomandați

- **Claude**: https://claude.ai
- **ChatGPT**: https://chat.openai.com

## Reguli de utilizare

✅ **Permis:**
- Să ceri explicații pentru concepte pe care nu le înțelegi
- Să întrebi de ce primești o eroare și cum să o rezolvi
- Să ceri exemple de cod pentru a învăța
- Să verifici dacă o comandă este corectă

❌ **Nepermis:**
- Să copiezi direct soluțiile pentru teme
- Să ceri AI-ului să-ți facă proiectul
- Să folosești AI în timpul examenelor

## Exemple de întrebări bune (specifice WSL2)

```
"Primesc 'Error: 0x80370102' la wsl --install. Ce înseamnă și cum verific virtualizarea?"

"Cum pot accesa fișierele din Windows în Ubuntu WSL? Unde e montată partiția C:?"

"De ce hostname -I nu îmi arată IP în WSL2? E diferit față de o mașină virtuală?"

"Cum fac ca SSH să pornească automat când deschid Ubuntu în WSL?"

"Care e diferența dintre wsl --shutdown și wsl --terminate Ubuntu-24.04?"

"Am schimbat hostname-ul dar tot văd numele vechi. Trebuie să fac wsl --shutdown?"
```

---

# SUMAR COMENZI IMPORTANTE

## PowerShell (Windows)

```powershell
wsl --shutdown
```
Oprește Ubuntu complet (util când vrei să repornești)

```powershell
wsl --status
```
Verifică starea WSL

```powershell
wsl --list --verbose
```
Arată toate distribuțiile instalate

## Bash (Ubuntu)

```bash
sudo apt update && sudo apt -y upgrade
```
Actualizează sistemul

```bash
sudo service ssh start
```
Pornește SSH server

```bash
hostname -I
```
Arată adresa IP

```bash
history > fisier.txt
```
Salvează istoricul comenzilor într-un fișier

```bash
exit
```
Închide sesiunea curentă

---

# CHECKLIST FINAL

Înainte de primul seminar, verifică că ai:

- [ ] Windows 10/11 cu virtualizare activată
- [ ] WSL2 instalat și actualizat
- [ ] Ubuntu 24.04 LTS instalat
- [ ] Cont creat cu numele tău de familie (ex: popescu)
- [ ] Parolă setată (stud)
- [ ] Hostname configurat (ex: AP_1001_A)
- [ ] Sistem actualizat (apt update && apt upgrade)
- [ ] Pachete software instalate
- [ ] SSH funcțional
- [ ] PuTTY instalat și configurat
- [ ] WinSCP instalat și configurat
- [ ] Foldere create (Books, Projects, etc.)
- [ ] Verificarea a arătat totul OK

---

# SELF-CHECK: Verifică-ți competențele

Răspunde sincer la următoarele întrebări. Dacă nu poți bifa toate, revizitează secțiunea relevantă.

## Poți face următoarele FĂRĂ să te uiți în ghid?

- [ ] Am rulat cu succes scriptul de verificare (toate cu [OK])
- [ ] M-am conectat SSH din PuTTY fără ajutor
- [ ] Am transferat un fișier test cu WinSCP (din Windows în Ubuntu)
- [ ] Știu ce să fac dacă SSH nu pornește (comanda exactă)
- [ ] Pot explica unui coleg ce face `wsl --shutdown` vs închiderea ferestrei Ubuntu

## Întrebări de verificare rapidă

1. **Cum verifici dacă virtualizarea e activată în Windows?**
   → Task Manager → Performance → CPU → Virtualization: Enabled

2. **Ce faci dacă ai eroarea 0x80370102?**
   → Activezi virtualizarea din BIOS/UEFI

3. **Unde sunt montate fișierele din Windows în WSL?**
   → În `/mnt/c/`, `/mnt/d/`, etc.

4. **Cum repornești complet WSL-ul?**
   → `wsl --shutdown` din PowerShell

---

# CE URMEAZĂ?

✅ Ai finalizat **01_INIT_SETUP**

**Pași următori:**
1. Descarcă uneltele pentru înregistrarea temelor → vedeți `02_INIT_HOMEWORKS/`
2. Parcurgeți referința Bash → vedeți `03_GUIDES/01_Bash_Scripting_Guide.md`
3. Veniți la SEM01 cu mediul pregătit

**Dacă se strică ceva mai târziu:**
- Verifică `03_GUIDES/03_Observability_and_Debugging_Guide.md`
- Sau întreabă un asistent AI (Secțiunea 15)

---

**Dacă ai toate bifate:** Ești pregătit pentru SEM01! 🎉

**Dacă îți lipsesc:** Revizitează secțiunea relevantă sau întreabă la seminar.

---

Document pentru:
Academia de Studii Economice București - CSIE
Sisteme de Operare - Anul universitar 2024-2025

**Versiune:** 2.1 | **Ultima actualizare:** Ianuarie 2025

---

*Pentru probleme, consultă secțiunea „Probleme frecvente" sau întreabă un asistent AI înainte de a contacta cadrul didactic.*
