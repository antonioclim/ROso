# Ghid de Utilizare - Înregistrare Teme

## Sisteme de Operare 2023-2027

**Versiunea:** 1.1.0 | **Ultima actualizare:** Ianuarie 2025

---

## 🎯 Înainte de a Începe

**Nu te panica!** Acest proces pare complicat la prima vedere, dar:
- Scriptul face aproape totul automat
- Eroarea cea mai frecventă (typo la STOP_tema) se rezolvă în 2 secunde
- Poți reînregistra oricâte ori ai nevoie

💪 **Studenții din anii trecuți au reușit din prima încercare în proporție de 85%.**

---

## 🔄 Diagrama Procesului de Înregistrare

```
┌─────────────────┐
│  🚀 Start       │
│    Script       │
└────────┬────────┘
         │
         ▼
┌─────────────────┐     Nu      ┌─────────────────┐
│  Dependențe     ├────────────►│ 📦 Instalare    │
│  instalate?     │             │ automată pip,   │
└────────┬────────┘             │ asciinema, etc. │
         │ Da                   └────────┬────────┘
         │◄──────────────────────────────┘
         ▼
┌─────────────────┐
│ 📝 Introducere  │◄───┐
│ date student    │    │ Date invalide
└────────┬────────┘    │
         │ Date OK     │
         ▼             │
┌─────────────────┐    │
│  Validare       ├────┘
│  format date    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ 💾 Salvare      │
│ config local    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ 🎬 START        │
│ Înregistrare    │
│ asciinema       │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ 👨‍💻 Execută      │◄───┐
│ comenzile temei │    │
└────────┬────────┘    │ Nu
         │             │
         ▼             │
┌─────────────────┐    │
│ STOP_tema?      ├────┘
└────────┬────────┘
         │ Da
         ▼
┌─────────────────┐
│ 🔐 Generare     │
│ semnătură RSA   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐     Eșuat    ┌─────────────────┐
│ 📤 Upload SCP   ├─────────────►│ Retry (max 3x)  │
│ pe server       │◄─────────────┤ sau salvat      │
└────────┬────────┘              │ LOCAL           │
         │ Succes                └─────────────────┘
         ▼
┌─────────────────┐
│ ✅ SUCCES!      │
│ Tema trimisă    │
└─────────────────┘
```

---

## Configurare Inițială (o singură dată)

### Pasul 1: Deschide terminalul

Pe Ubuntu/WSL, deschide un terminal.

*(WSL2 a schimbat complet modul în care predau — acum studenții pot exersa Linux fără dual boot.)*


> 🚨 **ATENȚIE!** Folosește terminalul TĂU, instalat și configurat așa cum v-a transmis instructorul!
>
> NU te conecta la sop.ase.ro!
>
> ⚠️ Erorile generate de nerespectarea acestei indicații vă sunt imputabile, iar temele care nu sunt postate și generate din serverul vostru personal NU vor fi luate în considerare!

---

### Pasul 2: Creează directorul pentru teme

```bash
mkdir -p ~/HOMEWORKS
```

**Ar trebui să vezi:** Nimic (comanda `mkdir -p` e silențioasă la succes). Asta e normal!

Verifică că s-a creat:

```bash
ls -la ~/HOMEWORKS
```

**Ar trebui să vezi ceva similar cu:**
```
total 8
drwxr-xr-x  2 stud stud 4096 ian 27 10:00 .
drwxr-xr-x 15 stud stud 4096 ian 27 09:55 ..
```

📝 **Notă:** Directorul e gol momentan (doar `.` și `..`). E perfect normal!

Observație: `~` reprezintă directorul tău home (`/home/{utilizator}/`).

---

### Pasul 3: Descarcă scriptul

**Opțiunea A: Descarcă din Google Drive (recomandat pentru începători)**

1. Deschide link-ul în browser:
   - Python TUI (recomandat): https://drive.google.com/file/d/1YLqNamLCdz6OzF6hlcPr1hr738DIaSYz/view?usp=drive_link
   - Bash (alternativă): https://drive.google.com/file/d/1dLXPEtGjLo4f9G0Uojd-YXzY7c3ku1Ez/view?usp=drive_link

2. Click pe Download (sau iconița ⬇️)

3. Salvează fișierul pe calculatorul tău Windows

---

**Opțiunea B: Descarcă direct cu wget în terminal**

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
Saving to: 'record_homework_tui_RO.py'

record_homework_tui_RO.py   100%[===================>]  33.83K  --.-KB/s    in 0.02s

2025-01-27 10:05:33 (1.65 MB/s) - 'record_homework_tui_RO.py' saved [34644/34644]
```

⚠️ **Dacă vezi "ERROR 403: Forbidden":** Link-ul poate fi restricționat. Descarcă manual din browser.

> 💡 Această metodă descarcă fișierul direct în folderul HOMEWORKS, fără pași intermediari!

---

**Opțiunea C: Copiază scriptul în Ubuntu folosind WinSCP**

1. Deschide WinSCP și conectează-te la sistemul tău Ubuntu/WSL
2. Navighează la `/home/{utilizator}/HOMEWORKS/`
3. Copiază fișierul descărcat (`record_homework_tui_RO.py`) în acest director

---

**Opțiunea D: Copiază direct în WSL (dacă folosești WSL)**

```bash
cp /mnt/c/Users/{NumeWindows}/Downloads/record_homework_tui_RO.py ~/HOMEWORKS/
```

**Ar trebui să vezi:** Nimic (succes silențios).

⚠️ Înlocuiește `{NumeWindows}` cu numele tău de utilizator Windows!

**Verifică că a funcționat:**
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

**Ar trebui să vezi:** Nimic (succes silențios).

Verifică că permisiunile s-au schimbat:

```bash
ls -l record_homework_tui_RO.py
```

**Ar trebui să vezi `x` în permisiuni:**
```
-rwxr-xr-x 1 stud stud 34644 ian 27 10:05 record_homework_tui_RO.py
 ^^^
 Aceste 'x' înseamnă "executabil"
```

❌ **Dacă vezi `-rw-r--r--`** (fără `x`): Comanda chmod nu a funcționat. 
Verifică că ești în directorul corect cu `pwd` — ar trebui să arate `~/HOMEWORKS` sau `/home/{utilizator}/HOMEWORKS`.

---

### Pasul 5: Verifică structura finală

```bash
ls -la ~/HOMEWORKS/
```

**Ar trebui să vezi:**
```
drwxr-xr-x  2 {utilizator} {utilizator} 4096 ian 21 10:00 .
drwxr-xr-x 15 {utilizator} {utilizator} 4096 ian 21 09:55 ..
-rwxr-xr-x  1 {utilizator} {utilizator} 38000 ian 21 10:00 record_homework_tui_RO.py
```

✅ **Dacă vezi ceva similar, ești pregătit!**

---

## Pornire Rapidă (de fiecare dată)

### Pasul 1: Intră în directorul HOMEWORKS

```bash
cd ~/HOMEWORKS
```

**Ar trebui să vezi:** Nimic (succes silențios). Prompt-ul poate schimba directorul afișat.

---

### Pasul 2: Rulează scriptul

```bash
python3 record_homework_tui_RO.py
```

**Ar trebui să vezi:** Efectul "Matrix rain" urmat de bannerul programului.

---

### Pasul 3: Urmează instrucțiunile de pe ecran

---

## Prima Utilizare (Durează Mai Mult!)

La prima rulare, scriptul va:

1. ✅ Verifica și instala `pip` (dacă lipsește)
2. ✅ Instala bibliotecile Python: `rich`, `questionary`
3. ✅ Instala utilitarele de sistem: `asciinema`, `openssl`, `sshpass`

Acest proces poate dura 1-3 minute în funcție de conexiunea la internet.

**Ar trebui să vezi mesaje similare cu:**
```
⚡ Se instalează pip...
✓ pip a fost instalat!

⚡ Se instalează pachetele Python: rich, questionary...
✓ Pachetele Python au fost instalate!

⚡ Se instalează pachetele de sistem: asciinema, openssl, sshpass...
✓ Pachetele de sistem au fost instalate!
```

Rulările următoare vor fi instantanee - nu se mai instalează nimic.

---

## Completarea Datelor

### Nume de familie
- Format: Doar litere și cratimă (fără spații)
- Exemple valide: `Ionescu`, `Popescu-Stan`
- Se modifică în: MAJUSCULE (`IONESCU`)
- Testează cu date simple înainte de cazuri complexe

### Prenume
- Format: Doar litere și cratimă (fără spații)
- Exemple valide: `Andrei`, `Ana-Maria`
- Se modifică în: Title Case (`Andrei`)
- Folosește `man` sau `--help` când ai dubii

### Grupă
- Format: Exact 4 cifre
- Exemple valide: `1029`, `1035`, `1234`

### Specializare
- Folosește săgețile sus/jos pentru a naviga
- Apasă **ENTER** pentru a selecta
- Opțiuni:
  - Informatică Economică (Română)
  - Grupă ID

### Număr temă
- Format: 01-07 urmat de o literă
- Exemple valide: `01a`, `03b`, `07c`

---

## Date Precompletate

După prima utilizare, datele tale vor fi salvate automat:
- Nume de familie
- Prenume
- Grupă

La următoarea rulare, aceste câmpuri vor fi **precompletate**. Poți:
- Apăsa **ENTER** pentru a păstra valoarea anterioară
- Scrie altceva pentru a o înlocui

Numărul temei nu se precompletează (este diferit de fiecare dată).

---

## Înregistrarea

### Când începe înregistrarea:

```
╔═══════════════════════════════════════════════════════════════════╗
║                     🔴 ÎNREGISTRARE ÎN CURS                       ║
╠═══════════════════════════════════════════════════════════════════╣
║                                                                   ║
║   Pentru a OPRI și SALVA înregistrarea, tastează: STOP_tema       ║
║                                                                   ║
║   sau apasă Ctrl+D                                                ║
║                                                                   ║
╚═══════════════════════════════════════════════════════════════════╝
```

### Ce să faci:

1. Execută comenzile necesare pentru tema ta
2. Arată clar ce faci și de ce
3. Când ai terminat, tastează:

```bash
STOP_tema
```

sau apasă `Ctrl+D`

### Sfaturi pentru o înregistrare bună:

- ✅ Scrie clar - nu te grăbi, și totodată ✅ Comentează ce faci (opțional, dar ajută)
- ✅ Verifică rezultatul comenzilor înainte de a opri
- ❌ NU șterge greșelile - arată că înveți din ele
- ❌ NU folosești clear/cls în exces

---

## Upload-ul

După oprirea înregistrării:

1. ✅ Scriptul generează semnătura criptografică
2. ✅ Încarcă automat pe server (3 încercări)
3. ✅ Afișează rezumatul final

### Dacă upload-ul reușește:

```
╔═══════════════════════════════════════════════════════════════════╗
║                     ✅ ÎNCĂRCARE REUȘITĂ!                         ║
╚═══════════════════════════════════════════════════════════════════╝
```

### Dacă upload-ul eșuează:

Fișierul este salvat local și vei vedea un mesaj cu comanda pentru trimitere manuală:

```
╔═════════════════════════════════════════════════════════════════════════╗
║                          Trimitere Eșuată                               ║
╠═════════════════════════════════════════════════════════════════════════╣
║                                                                         ║
║   ❌ NU AM PUTUT TRIMITE TEMA!                                          ║
║                                                                         ║
║   Fișierul a fost salvat local.                                         ║
║                                                                         ║
║   ╔═══════════════════════════════════════════════════════════════╗     ║
║   ║                                                               ║     ║
║   ║   📁  1029_IONESCU_Andrei_HW03b.cast                          ║     ║
║   ║                                                               ║     ║
║   ╚═══════════════════════════════════════════════════════════════╝     ║
║                                                                         ║
║   Încearcă mai târziu (când restabilești conexiunea) folosind:          ║
║                                                                         ║
║   scp -P 1002 1029_IONESCU_Andrei_HW03b.cast [utilizator]@[server]:/home...║
║                                                                         ║
║   ⚠️  NU modifica fișierul .cast înainte de trimitere!                  ║
║                                                                         ║
╚═════════════════════════════════════════════════════════════════════════╝
```

De reținut:
- ⚠️ NU modifica fișierul `.cast` - semnătura devine invalidă!
- 📋 Copiază comanda afișată și ruleaz-o când ai internet
- 🔄 Poți încerca oricâte ori e nevoie

---

## Fișierul Generat

### Locație:

Fișierul `.cast` este salvat în directorul curent (adică `~/HOMEWORKS/` dacă ai urmat pașii de configurare).

```
/home/{utilizator}/HOMEWORKS/1029_IONESCU_Andrei_HW03b.cast
```

### Nume fișier:

```
[GRUPA]_[NUME]_[Prenume]_HW[NrTema].cast
```

Exemplu: `1029_IONESCU_Andrei_HW03b.cast`

### Ce conține:

- Înregistrarea completă a sesiunii de terminal
- Semnătura criptografică (pentru verificare autenticitate)

---

## ❓ Întrebări Frecvente (FAQ)

### Generale

**Q: De ce trebuie să folosesc terminalul propriu și nu serverul sop.ase.ro?**

A: Înregistrarea asciinema captează TOATĂ activitatea din terminal. Pe server, activitatea ta s-ar amesteca cu a altor studenți, iar fișierul rezultat ar fi inutilizabil. În plus, semnătura criptografică se bazează pe utilizatorul LOCAL.

---

**Q: Pot folosi alt terminal decât cel default (Windows Terminal, iTerm2)?**

A: Da, orice terminal care suportă secvențe ANSI funcționează. Recomandări:
- Windows: Windows Terminal (pre-instalat pe Windows 11)
- macOS: iTerm2 sau Terminal.app
- Linux: GNOME Terminal, Konsole, Alacritty

---

**Q: Ce se întâmplă dacă am închis terminalul din greșeală în timpul înregistrării?**

A: Înregistrarea se oprește automat și fișierul parțial este salvat. Poți:
1. Verifica dacă fișierul .cast există: `ls -la ~/HOMEWORKS/*.cast`
2. Dacă e prea scurt, șterge-l și reîncepe: `rm ~/HOMEWORKS/...cast`
3. Rulează scriptul din nou

---

**Q: Pot edita fișierul .cast după înregistrare?**

A: **NU!** Orice modificare invalidează semnătura criptografică și tema va fi respinsă automat. Dacă ai greșit, șterge fișierul și reînregistrează.

---

**Q: Cum pot verifica că semnătura e validă?**

A: Nu poți verifica tu însuți - doar profesorul are cheia privată. Dar poți verifica că semnătura EXISTĂ:
```bash
tail -5 ~/HOMEWORKS/GRUPA_NUME_Prenume_HWxx.cast
# Ultima linie ar trebui să înceapă cu "## " urmat de Base64
```

---

## 🔧 Probleme Frecvente (Troubleshooting)

### Probleme la Instalare

#### 1. "Permission denied" la instalare

```bash
# Asigură-te că ești în directorul HOMEWORKS
cd ~/HOMEWORKS

# Rulează cu sudo prima dată (pentru instalare dependențe)
sudo python3 record_homework_tui_RO.py
```

**Ar trebui să vezi:** Procesul de instalare a dependențelor, urmat de interfața normală.

---

#### 2. "E: Unable to locate package asciinema"

Repository-urile apt nu sunt actualizate. Rulează:

```bash
sudo apt update
sudo apt install asciinema
```

**Ar trebui să vezi:** Lista de pachete actualizată, apoi instalarea asciinema.

Dacă tot nu merge, adaugă PPA-ul oficial:
```bash
sudo apt-add-repository ppa:zanchey/asciinema
sudo apt update
sudo apt install asciinema
```

---

#### 3. pip install eșuează cu "externally-managed-environment"

Pe Ubuntu 23.04+ și Debian 12+, sistemul protejează pachetele Python.
Scriptul nostru gestionează automat acest caz, dar dacă instalezi manual:

```bash
pip install --user --break-system-packages rich questionary
```

---

#### 4. "sudo: apt: command not found"

**Cauză:** Nu ești pe o distribuție Debian/Ubuntu.

**Soluție:** Dacă folosești Fedora/RHEL:
```bash
sudo dnf install asciinema openssl sshpass
```

Pentru Arch:
```bash
sudo pacman -S asciinema openssl sshpass
```

---

#### 5. "python3: command not found"

**Cauză:** Python nu e instalat sau nu e în PATH.

**Soluție:**
```bash
# Verifică dacă există sub alt nume:
python --version

# Dacă funcționează, creează symlink:
sudo ln -s $(which python) /usr/local/bin/python3

# Dacă nu există deloc:
sudo apt install python3
```

---

#### 6. WSL: "chmod: cannot access 'record_homework_tui_RO.py': No such file"

**Cauză:** Fișierul nu e în directorul curent.

**Soluție:**
```bash
# Verifică unde ești:
pwd
# Ar trebui să vezi: /home/NUMETAU/HOMEWORKS

# Dacă nu, navighează:
cd ~/HOMEWORKS

# Verifică conținutul:
ls -la
```

---

### Probleme la Rulare

#### 7. "rich" sau "questionary" import error după instalare

**Cauză:** pip a instalat în user site-packages, dar Python nu-l găsește.

**Soluție:**
```bash
# Verifică unde s-a instalat:
python3 -m pip show rich | grep Location

# Adaugă la PYTHONPATH (temporar):
export PYTHONPATH="$HOME/.local/lib/python3.11/site-packages:$PYTHONPATH"

# Sau reinstalează global (necesită sudo):
sudo pip3 install rich questionary
```

---

#### 8. Ecranul "Matrix rain" e stricat (caractere ciudate)

**Cauză:** Terminalul nu suportă caractere Unicode japoneze.

**Soluție:** Setează fontul terminalului la unul care suportă Unicode:
- Windows Terminal: "Cascadia Code" sau "Consolas"
- VS Code terminal: "Fira Code" sau "JetBrains Mono"

Alternativ, folosește versiunea Bash (fără efecte Matrix):
```bash
./record_homework_RO.sh
```

---

#### 9. Culorile nu apar (totul e alb/negru)

**Cauză:** Terminalul nu suportă 256 culori sau ANSI e dezactivat.

**Soluție:**
```bash
# Verifică suportul de culori:
echo $TERM
# Ar trebui să vezi: xterm-256color

# Dacă vezi altceva (ex: "dumb"):
export TERM=xterm-256color
# Adaugă în ~/.bashrc pentru permanență
```

---

### Probleme cu Înregistrarea

#### 10. Înregistrarea nu se oprește când tastez STOP_tema

**Cauză:** `STOP_tema` este un alias definit în sesiunea de înregistrare.

Cauze posibile:
1. Ai tastat în alt terminal (trebuie să fie CEL în care rulează înregistrarea)
2. Ai scris `stop_tema` (case-sensitive!)
3. Ai spații în plus

**Soluție alternativă:** Apasă `Ctrl+D` (end of file)

---

#### 11. Fișierul .cast este gol sau foarte mic (sub 1KB)

**Cauză:** Înregistrarea s-a oprit prematur.

Cauze:
1. Ai apăsat Ctrl+C în loc de Ctrl+D
2. Shell-ul a crash-uit
3. Eroare la inițializarea asciinema

**Soluție:** Verifică cu:
```bash
cat ~/HOMEWORKS/GRUPA_NUME_Prenume_HWxx.cast | head -20
# Ar trebui să vezi JSON valid
```

---

#### 12. Am greșit o comandă și vreau să o refac

**Soluție:** NU opri înregistrarea! Greșelile sunt OK și arată procesul de învățare. Pur și simplu:
1. Apasă săgeată sus pentru a edita comanda anterioară
2. Sau tastează comanda corectă

⚠️ **NU folosi `clear`** — șterge istoricul vizual care e necesar pentru evaluare.

---

#### 13. Vreau să fac pauză în timpul înregistrării

**Info:** Asciinema înregistrează și timpul de inactivitate.

**Soluție:** Poți face pauză, dar:
- La playback se va vedea o pauză lungă
- Profesorul poate accelera playback-ul, deci nu e problemă
- Dacă pauza e FOARTE lungă (ore), mai bine oprește și reîncepe

---

### Probleme cu Rețeaua / Upload

#### 14. "Connection refused" la upload

**Cauze posibile:**
- Nu ești conectat la internet
- Serverul este temporar indisponibil
- Ești într-o rețea restricționată

**Soluție:** Fișierul este salvat local. Încearcă mai târziu sau contactează profesorul.

---

#### 15. "Connection timed out"

**Cauză:** Serverul sop.ase.ro folosește portul 1002 (nu 22 standard). 

Cauze posibile:
1. Firewall-ul blochează portul 1002 (frecvent în rețele corporative)
2. VPN activ care nu routează corect
3. Serverul temporar indisponibil

**Soluție:**
```bash
# Testează conectivitatea:
nc -zv sop.ase.ro 1002

# Dacă ești pe VPN, deconectează-te temporar
# Dacă ești în rețea restricționată, folosește hotspot mobil
```

---

#### 16. "Host key verification failed"

**Cauză:** Cheia SSH a serverului s-a schimbat sau e prima conectare.

**Notă:** Scriptul folosește `-o StrictHostKeyChecking=no` deci NU ar trebui să vezi această eroare. Dacă totuși apare:

```bash
ssh-keygen -R sop.ase.ro
# Apoi rulează scriptul din nou
```

---

#### 17. "Permission denied" la upload (dar conexiunea merge)

**Cauză:** Directorul destinație nu există sau nu ai permisiuni.

**Soluție:** Aceasta e problemă de server. Contactează profesorul cu:
- Specializarea selectată: [roinfo/grupeid]
- Mesajul exact de eroare
- Output-ul comenzii: `sshpass -p stud ssh -p 1002 [utilizator]@[server] "ls -la /home/HOMEWORKS/"`

---

### Alte Probleme

#### 18. Scriptul nu pornește deloc

```bash
# Verifică versiunea Python
python3 --version
# Trebuie să fie Python 3.8 sau mai nou

# Verifică că scriptul există și e executabil
ls -l ~/HOMEWORKS/record_homework_tui_RO.py
```

---

#### 19. Am greșit datele introduse

Rulează scriptul din nou și introdu datele corecte. Fișierul anterior va fi suprascris.

---

#### 20. Înregistrarea include și promptul scriptului (nu doar comenzile mele)

**Notă:** Totul e intenționat! Profesorul vede contextul complet. Asciinema captează tot ce se întâmplă în terminal, inclusiv mesajele scriptului. Aceasta ajută la verificarea autenticității.

---

## Despre Semnătura Criptografică

Fiecare înregistrare este semnată digital cu RSA. Aceasta garantează:

- ✅ **Autenticitatea** - profesorul poate verifica că tu ai creat fișierul
- ✅ **Integritatea** - fișierul nu poate fi modificat după semnare
- ✅ **Non-repudierea** - nu poți nega că ai trimis tema
- Verifică întotdeauna rezultatul înainte de a continua

**NU poți falsifica semnătura altui student!**

---

## ✨ Sfaturi pentru Succes

1. **Citește ÎNTREGUL ghid** înainte de prima încercare (15 minute)
2. **Pregătește-ți comenzile** în alt document înainte de înregistrare
3. **Testează comenzile** individual înainte de înregistrarea finală
4. **Fă o "probă"** cu o temă fictivă dacă ești nesigur

---

## 🏆 Ai Reușit!

Dacă ai ajuns până aici și ai trimis tema cu succes — **felicitări**! 

Tocmai ai folosit:
- 🐧 **Shell scripting** în Linux
- 🔐 **Criptografie asimetrică** (RSA)
- 🌐 **Transfer securizat** de fișiere (SCP)
- 📹 **Înregistrare terminal** (asciinema)

Acestea sunt competențe reale folosite zilnic de administratori de sistem și ingineri DevOps. **Ești pe drumul cel bun!**

---

## Suport

Pentru probleme tehnice:
- Contactează profesorul de laborator
- Verifică dacă ai ultima versiune a scriptului
- Consultă secțiunea FAQ și Troubleshooting de mai sus

---

*Sisteme de Operare 2023-2027 - ASE București*
*Versiunea documentației: 1.1.0*
