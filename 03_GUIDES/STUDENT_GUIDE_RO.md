# Ghid de utilizare – înregistrarea temelor

## Sisteme de Operare 2023-2027

**Versiune:** 1.1.1 | **Ultima actualizare:** ianuarie 2025

---

## 🎯 Înainte să începi

**Nu intra în panică.** La prima vedere, procesul poate părea complicat, însă:
- scriptul automatizează aproape totul;
- cea mai frecventă eroare (o greșeală de tastare la `STOP_homework`) se remediază în câteva secunde;
- poți reînregistra de câte ori este necesar.

💪 **85% dintre studenții din anii anteriori au reușit din prima încercare.**

---

## 🔄 Diagrama procesului de înregistrare

```
┌─────────────────┐
│  🚀 Start       │
│    Script       │
└────────┬────────┘
         │
         ▼
┌─────────────────┐     No       ┌─────────────────┐
│  Dependencies   ├─────────────►│ 📦 Automatic    │
│  installed?     │              │ install pip,    │
└────────┬────────┘              │ asciinema, etc. │
         │ Yes                   └────────┬────────┘
         │◄──────────────────────────────┘
         ▼
┌─────────────────┐
│ 📝 Enter        │◄───┐
│ student data    │    │ Invalid data
└────────┬────────┘    │
         │ Data OK     │
         ▼             │
┌─────────────────┐    │
│  Validate       ├────┘
│  data format    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ 💾 Save         │
│ local config    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ 🎬 START        │
│ Recording       │
│ asciinema       │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ 👨‍💻 Execute      │◄───┐
│ homework cmds   │    │ No
└────────┬────────┘    │
         │             │
         ▼             │
┌─────────────────┐    │
│ STOP_homework?  ├────┘
└────────┬────────┘
         │ Yes
         ▼
┌─────────────────┐
│ 🔐 Generate     │
│ RSA signature   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐     Failed   ┌─────────────────┐
│ 📤 SCP Upload   ├─────────────►│ Retry (max 3x)  │
│ to server       │◄─────────────┤ or saved        │
└────────┬────────┘              │ LOCALLY         │
         │ Success               └─────────────────┘
         ▼
┌─────────────────┐
│ ✅ SUCCESS!     │
│ Homework sent   │
└─────────────────┘
```

> 💡 **Din experiență:** în 2023, un student a tastat din greșeală `STOP-homework` (cu cratimă în loc de underscore) și a pierdut 20 de minute încercând să înțeleagă de ce înregistrarea nu se oprește. Soluția a fost să citească atent mesajul de pe ecran: este `STOP_homework`, cu **underscore**. De atunci, textul a fost făcut mai vizibil și a fost adăugat `Ctrl+D` ca alternativă. Este util să înveți din greșelile deja întâlnite.

---

## Configurare inițială (o singură dată)

### Pasul 1: Deschide terminalul

Pe Ubuntu/WSL, deschide un terminal.

*(WSL2 a schimbat semnificativ modul în care pot fi exersate competențele Linux, deoarece permite practică fără dual boot.)*


> 🚨 **AVERTISMENT!** Folosește propriul terminal, instalat și configurat conform indicațiilor cadrului didactic.
>
> NU te conecta la sop.ase.ro.
>
> ⚠️ Erorile cauzate de nerespectarea acestei instrucțiuni îți aparțin, iar temele care nu sunt înregistrate din mediul tău local și trimise corespunzător NU vor fi luate în considerare.

---

### Pasul 2: Creează directorul HOMEWORKS

```bash
mkdir -p ~/HOMEWORKS
```

**Ar trebui să vezi:** nimic (comanda `mkdir -p` nu afișează mesaj la succes). Este normal.

Verifică faptul că directorul a fost creat:

```bash
ls -la ~/HOMEWORKS
```

**Ar trebui să vezi ceva asemănător cu:**
```
total 8
drwxr-xr-x  2 stud stud 4096 Jan 27 10:00 .
drwxr-xr-x 15 stud stud 4096 Jan 27 09:55 ..
```

📝 **Notă:** directorul este gol pentru moment (doar `.` și `..`). Este normal.

Observație: `~` reprezintă directorul tău „home” (`/home/{username}/`).

---

### Pasul 3: Descarcă scriptul

**Opțiunea A: Descărcare din Google Drive (recomandată pentru începători)**

1. Deschide linkul în browser:
   - Python TUI (recomandat): https://drive.google.com/file/d/1YLqNamLCdz6OzF6hlcPr1hr738DIaSYz/view?usp=drive_link
   - Bash (alternativă): https://drive.google.com/file/d/1dLXPEtGjLo4f9G0Uojd-YXzY7c3ku1Ez/view?usp=drive_link

2. Apasă Download (sau pictograma ⬇️)

3. Salvează fișierul pe calculatorul tău (Windows)

---

**Opțiunea B: Descărcare directă cu wget în terminal**

```bash
cd ~/HOMEWORKS
wget -O record_homework_tui_RO.py "https://drive.google.com/uc?export=download&id=1YLqNamLCdz6OzF6hlcPr1hr738DIaSYz"
```

**Ar trebui să vezi:**
```
--2025-01-27 10:05:32--  https://drive.google.com/uc?...
Resolving drive.google.com (drive.google.com)... 142.250.185.78
Connecting to drive.google.com (drive.google.com)|142.250.185.78|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 34644 (34K) [application/octet-stream]
Saving to: `record_homework_tui_RO.py`

record_homework_tui_RO.py   100%[===================>]  33.83K  --.-KB/s    in 0.02s

2025-01-27 10:05:33 (1.65 MB/s) - `record_homework_tui_RO.py` saved [34644/34644]
```

⚠️ **Dacă vezi "ERROR 403: Forbidden":** linkul poate fi restricționat. Descarcă manual din browser.

> 💡 Metoda aceasta descarcă fișierul direct în directorul HOMEWORKS, fără pași intermediari.

---

**Opțiunea C: Copiază scriptul în Ubuntu folosind WinSCP**

1. Deschide WinSCP și conectează-te la sistemul tău Ubuntu/WSL
2. Navighează la `/home/{username}/HOMEWORKS/`
3. Copiază fișierul descărcat (`record_homework_tui_RO.py`) în acest director

---

**Opțiunea D: Copiere directă în WSL (dacă folosești WSL)**

```bash
cp /mnt/c/Users/{WindowsName}/Downloads/record_homework_tui_RO.py ~/HOMEWORKS/
```

**Ar trebui să vezi:** nimic (succes „tăcut”).

⚠️ Înlocuiește `{WindowsName}` cu numele tău de utilizator din Windows.

**Verifică faptul că a funcționat:**
```bash
ls -l ~/HOMEWORKS/
```

**Ar trebui să vezi fișierul listat.**

---

### Pasul 4: Fă scriptul executabil

```bash
cd ~/HOMEWORKS
chmod +x record_homework_tui_RO.py
```

**Ar trebui să vezi:** nimic (succes „tăcut”).

Verifică faptul că permisiunile s-au schimbat:

```bash
ls -l record_homework_tui_RO.py
```

**Ar trebui să vezi `x` în permisiuni:**
```
-rwxr-xr-x 1 stud stud 34644 Jan 27 10:05 record_homework_tui_RO.py
 ^^^
 These 'x' mean "executable"
```

❌ **Dacă vezi `-rw-r--r--`** (fără `x`): comanda chmod nu a funcționat.
Verifică faptul că ești în directorul corect cu `pwd` — ar trebui să afișeze `~/HOMEWORKS` sau `/home/{username}/HOMEWORKS`.

---

### Pasul 5: Verifică structura finală

```bash
ls -la ~/HOMEWORKS/
```

**Ar trebui să vezi:**
```
drwxr-xr-x  2 {username} {username} 4096 Jan 21 10:00 .
drwxr-xr-x 15 {username} {username} 4096 Jan 21 09:55 ..
-rwxr-xr-x  1 {username} {username} 38000 Jan 21 10:00 record_homework_tui_RO.py
```

✅ **Dacă vezi ceva asemănător, ești pregătit.**

---

## 🧪 Opțional: rulare de probă (recomandată)

Înainte să înregistrezi tema reală, fă o rulare de test cu date fictive. Durează aproximativ 2 minute și elimină surprizele în momentul predării.

```bash
cd ~/HOMEWORKS
./record_homework_tui_RO.py
```

Introdu date de test:
- Nume (familie): `TEST`
- Prenume: `Student`
- Grupă: `0000`
- Specializare: Economic Informatics (English)
- Temă: `01x`

Apoi:
1. Tastează câteva comenzi simple (`ls`, `pwd`, `echo "hello"`)
2. Tastează `STOP_homework` (cu **underscore**, nu cu cratimă)
3. Observă generarea semnăturii
4. Încărcarea va eșua (grupa 0000 nu există) — pentru probă este în regulă

Șterge fișierul de test după finalizare:

```bash
rm 0000_TEST_Student_HW01x.cast
```

**De ce este utilă rularea de probă?** Prima interacțiune cu interfața de înregistrare, procesul de semnare și încărcarea poate părea copleșitoare. O probă scurtă reduce stresul și crește încrederea pentru predarea reală.

---

## Pornire rapidă (de fiecare dată)

### Pasul 1: Intră în directorul HOMEWORKS

```bash
cd ~/HOMEWORKS
```

**Ar trebui să vezi:** nimic (succes „tăcut”). Promptul poate reflecta directorul curent.

---

### Pasul 2: Rulează scriptul

```bash
python3 record_homework_tui_RO.py
```

**Ar trebui să vezi:** efectul „Matrix rain”, urmat de bannerul programului.

---

### Pasul 3: Urmează instrucțiunile afișate

---

## Prima utilizare (durează mai mult)

La prima rulare, scriptul:

1. ✅ verifică și instalează `pip` (dacă lipsește)
2. ✅ instalează bibliotecile Python: `rich`, `questionary`
3. ✅ instalează utilitarele de sistem: `asciinema`, `openssl`, `sshpass`

Procesul poate dura 1-3 minute, în funcție de conexiunea la internet.

**Ar trebui să vezi mesaje asemănătoare cu:**
```
⚡ Installing pip...
✓ pip has been installed!

⚡ Installing Python packages: rich, questionary...
✓ Python packages have been installed!

⚡ Installing system packages: asciinema, openssl, sshpass...
✓ System packages have been installed!
```

Rulările ulterioare vor fi rapide: nu mai este nevoie de instalări suplimentare.

---

## Introducerea datelor

### Nume (familie)
- Format: doar litere și cratimă (fără spații)
- Exemple valide: `Smith`, `Jones-Williams`
- Conversie: MAJUSCULE (`SMITH`)
- Recomandare: testează cu date simple înainte de cazuri complexe

### Prenume
- Format: doar litere și cratimă (fără spații)
- Exemple valide: `John`, `Mary-Anne`
- Conversie: inițială mare (`John`)
- Dacă ai dubii, folosește `man` sau `--help` acolo unde este disponibil

### Grupă
- Format: exact 4 cifre
- Exemple valide: `1029`, `1035`, `1234`

### Specializare
- Folosește tastele săgeți sus/jos pentru navigare
- Apasă **ENTER** pentru selecție
- Opțiuni:
  - Economic Informatics (English)
  - Grup ID
  - Economic Informatics (Romanian)

### Număr temă
- Format: 01-07 urmat de o literă
- Exemple valide: `01a`, `03b`, `07c`

---

## Date precompletate

După prima utilizare, datele tale vor fi salvate automat:
- nume (familie)
- prenume
- grupă

La rularea următoare, aceste câmpuri vor fi **precompletate**. Poți:
- apăsa **ENTER** pentru a păstra valoarea anterioară;
- introduce altceva pentru a o înlocui.

Numărul temei nu este precompletat (se schimbă la fiecare predare).

---

## Înregistrare

### Când începe înregistrarea:

```
╔═══════════════════════════════════════════════════════════════════╗
║                     🔴 RECORDING IN PROGRESS                      ║
╠═══════════════════════════════════════════════════════════════════╣
║                                                                   ║
║   To STOP and SAVE the recording, type: STOP_homework             ║
║                                                                   ║
║   or press Ctrl+D                                                 ║
║                                                                   ║
╚═══════════════════════════════════════════════════════════════════╝
```

### Ce ai de făcut:

1. Rulează comenzile cerute de temă
2. Arată clar ce faci și de ce
3. Când ai terminat, tastează:

```bash
STOP_homework
```

sau apasă `Ctrl+D`

### Sugestii pentru o înregistrare bună:

- ✅ Tastează clar — graba produce greșeli
- ✅ Poți explica succint ce faci (îl ajută pe evaluator să urmărească raționamentul)
- ✅ Verifică rezultatele comenzilor înainte să oprești
- ❌ NU șterge greșelile — ele arată progresul de învățare
- ❌ NU folosi excesiv `clear`/`cls`

---

## Încărcare

După oprirea înregistrării:

1. ✅ scriptul generează semnătura criptografică
2. ✅ încearcă încărcarea pe server (3 încercări)
3. ✅ afișează un rezumat final

### Dacă încărcarea reușește:

```
╔═══════════════════════════════════════════════════════════════════╗
║                     ✅ UPLOAD SUCCESSFUL!                         ║
╚═══════════════════════════════════════════════════════════════════╝
```

### Dacă încărcarea eșuează:

Fișierul este salvat local și vei vedea un mesaj cu comanda pentru trimitere manuală:

```
╔═════════════════════════════════════════════════════════════════════════╗
║                          Submission Failed                              ║
╠═════════════════════════════════════════════════════════════════════════╣
║                                                                         ║
║   ❌ COULD NOT SEND HOMEWORK!                                           ║
║                                                                         ║
║   The file has been saved locally.                                      ║
║                                                                         ║
║   ╔═══════════════════════════════════════════════════════════════╗     ║
║   ║                                                               ║     ║
║   ║   📁  1029_SMITH_John_HW03b.cast                              ║     ║
║   ║                                                               ║     ║
║   ╚═══════════════════════════════════════════════════════════════╝     ║
║                                                                         ║
║   Try later (when you restore connection) using:                        ║
║                                                                         ║
║   scp -P 1001 1029_SMITH_John_HW03b.cast stud-id[AT]sop.ase.ro:/home... ║
║                                                                         ║
║   ⚠️  DO NOT modify the .cast file before submission!                   ║
║                                                                         ║
╚═════════════════════════════════════════════════════════════════════════╝
```

Reține:
- ⚠️ NU modifica fișierul `.cast` — semnătura devine invalidă
- 📋 Copiază comanda afișată și ruleaz-o când ai acces la internet
- 🔄 Poți încerca de câte ori este necesar

---

## ✅ Verifică înainte de trimitere

Folosește scriptul de verificare pentru a valida tema înainte de încărcarea manuală:

```bash
./check_my_submission.sh 1029_SMITH_John_HW03b.cast
```

Acesta verifică dimensiunea fișierului, prezența semnăturii, formatul numelui de fișier și alte condiții. Remediază orice eroare înainte de a încerca trimiterea.

---

## Fișierul generat

### Locație:

Fișierul `.cast` este salvat în directorul curent (de exemplu `~/HOMEWORKS/` dacă ai urmat pașii de configurare).

```
/home/{username}/HOMEWORKS/1029_SMITH_John_HW03b.cast
```

### Nume de fișier:

```
[GROUP]_[SURNAME]_[FirstName]_HW[Number].cast
```

Exemplu: `1029_SMITH_John_HW03b.cast`

### Conținut:

- înregistrarea completă a sesiunii de terminal;
- semnătura criptografică (pentru verificarea autenticității).

---

## ❓ Întrebări frecvente (FAQ)

### General

**Î: De ce trebuie să folosesc propriul terminal și nu serverul sop.ase.ro?**

R: Înregistrarea asciinema captează TOATĂ activitatea din terminal. Pe server, activitatea ta s-ar amesteca cu a altor studenți, iar fișierul rezultat ar deveni inutilizabil. În plus, semnătura criptografică se bazează pe utilizatorul LOCAL.

> *Un student a rulat scriptul pe serverul partajat. Înregistrarea de 47 de minute a inclus munca altor trei studenți, o discuție din pauza de cafea și lista de redare Spotify a cuiva, auzită „pe fundal”. Evită această situație.*

---

**Î: Pot folosi un alt terminal decât cel implicit (Windows Terminal, iTerm2)?**

R: Da, orice terminal care suportă secvențe ANSI este potrivit. Recomandări:
- Windows: Windows Terminal (preinstalat pe Windows 11)
- macOS: iTerm2 sau Terminal.app
- Linux: GNOME Terminal, Konsole, Alacritty

---

**Î: Ce se întâmplă dacă închid accidental terminalul în timpul înregistrării?**

R: Înregistrarea se oprește automat și fișierul parțial este salvat. Poți:
1. verifica dacă fișierul `.cast` există: `ls -la ~/HOMEWORKS/*.cast`
2. dacă este prea scurt, șterge-l și reîncepe: `rm ~/HOMEWORKS/...cast`
3. rulează din nou scriptul

---

**Î: Pot edita fișierul `.cast` după înregistrare?**

R: **Nu.** Orice modificare invalidează semnătura criptografică și tema va fi respinsă automat. Dacă ai greșit, șterge fișierul și reînregistrează.

---

**Î: Cum verific că semnătura este validă?**

R: Nu o poți valida singur — doar cadrul didactic are cheia privată. Totuși, poți verifica dacă semnătura EXISTĂ:
```bash
tail -5 ~/HOMEWORKS/GROUP_SURNAME_FirstName_HWxx.cast
# The last line should start with "## " followed by Base64
```

Sau folosește scriptul de verificare:
```bash
./check_my_submission.sh your_homework.cast
```

---

## 🔧 Probleme uzuale (depanare)

### Probleme de instalare

#### 1. "Permission denied" în timpul instalării

```bash
# Make sure you are in the HOMEWORKS directory
cd ~/HOMEWORKS

# Run with sudo the first time (for installing dependencies)
sudo python3 record_homework_tui_RO.py
```

**Ar trebui să vezi:** instalarea dependențelor, urmată de interfața normală.

---

#### 2. "E: Unable to locate package asciinema"

Repository-urile apt nu sunt actualizate. Rulează:

```bash
sudo apt update
sudo apt install asciinema
```

**Ar trebui să vezi:** lista de pachete actualizată, apoi instalarea asciinema.

Dacă tot nu funcționează, adaugă PPA-ul oficial:
```bash
sudo apt-add-repository ppa:zanchey/asciinema
sudo apt update
sudo apt install asciinema
```

---

#### 3. Instalarea pip eșuează cu "externally-managed-environment"

Pe Ubuntu 23.04+ și Debian 12+, sistemul protejează pachetele Python.
Scriptul gestionează automat acest caz, însă pentru instalare manuală:

```bash
pip install --user --break-system-packages rich questionary
```

---

#### 4. "sudo: apt: command not found"

**Cauză:** nu ești pe o distribuție Debian/Ubuntu.

**Soluție:** dacă folosești Fedora/RHEL:
```bash
sudo dnf install asciinema openssl sshpass
```

Pentru Arch:
```bash
sudo pacman -S asciinema openssl sshpass
```

---

#### 5. "python3: command not found"

**Cauză:** Python nu este instalat sau nu se află în PATH.

**Soluție:**
```bash
# Verifică dacă există sub alt nume:
python --version

# Dacă funcționează, create a symlink:
sudo ln -s $(which python) /usr/local/bin/python3

# Dacă nu există deloc:
sudo apt install python3
```

---

#### 6. WSL: "chmod: cannot access `record_homework_tui_RO.py`: No such file"

**Cauză:** fișierul nu se află în directorul curent.

**Soluție:**
```bash
# Verifică unde ești:
pwd
# Ar trebui să vezi: /home/YOURNAME/HOMEWORKS

# Dacă nu, navighează:
cd ~/HOMEWORKS

# Verifică conținutul:
ls -la
```

---

### Probleme la rulare

#### 7. Eroare de import "rich" sau "questionary" după instalare

**Cauză:** pip a instalat în `site-packages` la nivel de utilizator, însă Python nu găsește pachetul.

**Soluție:**
```bash
# Verifică unde a fost instalat:
python3 -m pip show rich | grep Location

# Adaugă la PYTHONPATH (temporar):
export PYTHONPATH="$HOME/.local/lib/python3.11/site-packages:$PYTHONPATH"

# Sau reinstalează global (necesită sudo):
sudo pip3 install rich questionary
```

---

#### 8. Ecranul „Matrix rain” este deteriorat (caractere ciudate)

**Cauză:** terminalul nu suportă caractere Unicode japoneze.

**Soluție:** setează fontul terminalului la unul cu suport Unicode:
- Windows Terminal: "Cascadia Code" sau "Consolas"
- Terminal VS Code: "Fira Code" sau "JetBrains Mono"

Alternativ, folosește varianta Bash (fără efecte Matrix):
```bash
./record_homework_RO.sh
```

---

#### 9. Culorile nu apar (totul este alb/negru)

**Cauză:** terminalul nu suportă 256 de culori sau ANSI este dezactivat.

**Soluție:**
```bash
# Verifică suportul pentru culori:
echo $TERM
# Ar trebui să vezi: xterm-256color

# Dacă vezi altceva (e.g.: "dumb"):
export TERM=xterm-256color
# Adaugă la ~/.bashrc pentru permanență
```

---

### Probleme de înregistrare

#### 10. Înregistrarea nu se oprește când tastez `STOP_homework`

**Cauză:** `STOP_homework` este interpretat în sesiunea de înregistrare.

Cauze posibile:
1. tastezi în alt terminal (trebuie să fie cel în care rulează înregistrarea)
2. ai scris `stop_homework` (sensibil la litere mari/mici)
3. ai scris `STOP-homework` (cu cratimă în loc de underscore)
4. ai spații în plus

**Soluție alternativă:** apasă `Ctrl+D` (end of file)

> În practică, această situație prinde pe cineva în fiecare semestru. Nu ești singur.

---

#### 11. Fișierul `.cast` este gol sau foarte mic (sub 1KB)

**Cauză:** înregistrarea s-a oprit prematur.

Cauze:
1. ai apăsat Ctrl+C în loc de Ctrl+D
2. shell-ul s-a închis neașteptat
3. eroare la inițializarea asciinema

**Soluție:** verifică astfel:
```bash
cat ~/HOMEWORKS/GROUP_SURNAME_FirstName_HWxx.cast | head -20
# Ar trebui să vezi JSON valid
```

---

#### 12. Am greșit o comandă și vreau să o refac

**Soluție:** NU opri înregistrarea. Greșelile sunt acceptabile și arată procesul de învățare. Poți:
1. să folosești săgeata sus pentru a edita comanda anterioară
2. să tastezi comanda corectă

⚠️ **NU folosi `clear`** — șterge istoricul vizual necesar evaluării.

---

#### 13. Vreau să fac pauză în timpul înregistrării

**Informație:** asciinema înregistrează și timpul de inactivitate.

**Soluție:** poți face pauză, însă:
- la redare, pauzele lungi sunt vizibile;
- evaluatorul poate accelera redarea, deci nu este o problemă;
- pentru pauze foarte lungi (ore), este preferabil să oprești și să reîncepi.

---

### Probleme de rețea / încărcare

#### 14. "Connection refused" în timpul încărcării

**Cauze posibile:**
- nu ești conectat la internet;
- serverul este temporar indisponibil;
- ești pe o rețea restricționată.

**Soluție:** fișierul este salvat local. Încearcă mai târziu sau contactează cadrul didactic.

---

#### 15. "Connection timed out"

**Cauză:** serverul sop.ase.ro folosește portul 1001 (nu portul standard 22).

Cauze posibile:
1. firewall-ul blochează portul 1001 (frecvent în rețele corporative)
2. VPN activ care nu rutează corect
3. server temporar indisponibil

**Soluție:**
```bash
# Testează conectivitatea:
nc -zv sop.ase.ro 1001

# Dacă ești pe VPN, deconectează-te temporar
# Dacă ești pe o rețea restricționată, folosește hotspot mobil
```

---

#### 16. "Host key verification failed"

**Cauză:** cheia SSH a serverului s-a schimbat sau este prima conexiune.

**Notă:** scriptul folosește `-o StrictHostKeyChecking=no`, deci nu ar trebui să vezi această eroare. Dacă apare totuși:

```bash
ssh-keygen -R sop.ase.ro
# Apoi rulează scriptul din nou
```

---

#### 17. "Permission denied" în timpul încărcării (dar conexiunea funcționează)

**Cauză:** directorul de destinație nu există sau nu ai permisiuni.

**Soluție:** este o problemă pe server. Contactează cadrul didactic cu:
- specializarea selectată: [eninfo/grupeid/roinfo]
- mesajul exact de eroare
- output-ul comenzii: `sshpass -p stud ssh -p 1001 stud-id[AT]sop.ase.ro "ls -la /home/HOMEWORKS/"`

---

### Alte probleme

#### 18. Scriptul nu pornește deloc

```bash
# Verifică versiunea Python
python3 --version
# Trebuie să fie Python 3.8 sau mai nou

# Verifică că scriptul există și este executabil
ls -l ~/HOMEWORKS/record_homework_tui_RO.py
```

---

#### 19. Am introdus date greșite

Rulează din nou scriptul și introdu datele corecte. Fișierul anterior va fi suprascris.

---

#### 20. Înregistrarea include și promptul scriptului (nu doar comenzile mele)

**Notă:** aceasta este intenționat. Evaluatorul vede contextul complet. Asciinema captează tot ce se întâmplă în terminal, inclusiv mesajele scriptului, ceea ce ajută la verificarea autenticității.

---

## Despre semnătura criptografică

Fiecare înregistrare este semnată digital cu RSA. Acest lucru garantează:

- ✅ **Autenticitate** — evaluatorul poate verifica faptul că ai creat fișierul
- ✅ **Integritate** — fișierul nu poate fi modificat după semnare
- ✅ **Non-repudiere** — nu poți nega că ai trimis tema
- Verifică întotdeauna rezultatul înainte de a continua

**Nu poți falsifica semnătura altui student.**

---

## ✨ Sfaturi pentru reușită

1. **Citește întregul ghid** înainte de prima încercare (aproximativ 15 minute)
2. **Fă o rulare de probă** cu date fictive (secțiunea de mai sus)
3. **Pregătește comenzile** într-un document separat înainte de înregistrare
4. **Testează comenzile** individual înainte de înregistrarea finală
5. **Verifică predarea** cu `check_my_submission.sh` înainte de încărcarea manuală

---

## 🏆 Ai reușit

Dacă ai ajuns aici și ai trimis tema cu succes — felicitări.

Ai utilizat:
- 🐧 scripting în shell pe Linux
- 🔐 criptografie asimetrică (RSA)
- 🌐 transfer securizat de fișiere (SCP)
- 📹 înregistrare de terminal (asciinema)

Acestea sunt competențe utilizate frecvent în administrarea sistemelor și în activități DevOps. **Ești pe direcția potrivită.**

---

## Suport

Pentru probleme tehnice, urmează această escaladare:

1. **Auto-ajutor:**
   - rulează `./check_my_submission.sh` pentru diagnostic;
   - consultă secțiunea FAQ de mai sus;
   - consultă secțiunea de depanare;
   - verifică faptul că ai cea mai recentă versiune a scriptului.

2. **Sprijin din partea colegilor:**
   - întreabă un coleg care a trimis deja cu succes;
   - consultă forumul disciplinei / canalul Teams (dacă este disponibil).

3. **Contactarea cadrului didactic:**
   - discută cu cadrul didactic în timpul orelor de consultanță;
   - trimite un mesaj cu subiectul: `[OS Homework] Scurtă descriere a problemei`
   - include: grupa, mesajul exact de eroare, ce ai încercat.

**Timp de răspuns:** cadrele didactice răspund, de regulă, în 24-48 ore în timpul semestrului. Pentru situații urgente înainte de termen, folosește orele de consultanță.

---

*Sisteme de Operare 2023-2027 - ASE București*
*Versiune documentație: 1.1.1*
