# ❓ FAQ - Întrebări frecvente

## Sistem de înregistrare a temelor - Sisteme de Operare 2023-2027

**Versiune:** 1.1.1 | **Ultima actualizare:** ianuarie 2025

---

## 📋 Cuprins

1. [General](#general)
2. [Instalare și configurare](#installation-and-setup)
3. [Rulare și utilizare](#running-and-usage)
4. [Înregistrare](#recording)
5. [Încărcare și rețea](#upload-and-network)
6. [Semnătură criptografică](#cryptographic-signature)
7. [Erori specifice](#specific-errors)
8. [Verificare](#verification)

---

## General <a id="general"></a>

### Î: De ce trebuie să folosesc propriul terminal și nu serverul sop.ase.ro?

**R:** Înregistrarea asciinema captează TOATĂ activitatea din terminal. Pe server, activitatea ta s-ar amesteca cu a altor studenți, iar fișierul rezultat ar deveni inutilizabil. În plus, semnătura criptografică se bazează pe utilizatorul LOCAL.

> *Un student a rulat scriptul pe serverul partajat. Înregistrarea de 47 de minute a inclus munca altor trei studenți, o discuție din pauza de cafea și lista de redare Spotify a cuiva, auzită „pe fundal”. Evită această situație.*

---

### Î: Pot folosi un alt terminal decât cel implicit?

**R:** Da, orice terminal care suportă secvențe ANSI este potrivit:
- **Windows:** Windows Terminal (recomandat), PowerShell, CMD în Windows Terminal
- **macOS:** iTerm2, Terminal.app
- **Linux:** GNOME Terminal, Konsole, Alacritty, Terminator

---

### Î: Care este diferența dintre varianta Python TUI și varianta Bash?

**R:** 

| Aspect | Python TUI | Bash |
|--------|------------|------|
| Interfață | Grafică (tematică Matrix) | Text simplu |
| Dependențe | Python 3.8+, rich, questionary | Doar Bash |
| Animații | Da (ploaie, spinners) | Nu |
| Meniuri | Interactive (tastele săgeți) | Input text |
| Recomandare | Pentru majoritatea utilizatorilor | Sistem minimal / rezervă |

Varianta Bash este o alternativă dacă întâmpini dificultăți cu dependențele Python. Ambele generează fișiere de output identice.

---

### Î: Cât durează întregul proces?

**R:** 
- **Prima dată:** 3-5 minute (instalarea dependențelor) + timpul de rezolvare
- **Ulterior:** ~30 secunde configurare + timpul de rezolvare + ~30 secunde încărcare

Majoritatea studenților finalizează întregul proces în mai puțin de 15 minute după ce s-au familiarizat cu pașii.

---

### Î: Este recomandat să fac mai întâi o rulare de probă?

**R:** Da. Alocă 2 minute pentru o rulare de test cu date fictive (grupa `0000`, nume `TEST`). Aceasta reduce surprizele când contează. Consultă secțiunea „Rulare de probă” din ghidul pentru studenți.

---

## Instalare și configurare <a id="installation-and-setup"></a>

### Î: De ce versiune de Python am nevoie?

**R:** Python 3.8 sau mai nou. Verifică astfel:
```bash
python3 --version
```

---

### Î: Cum verific dacă toate dependențele sunt instalate?

**R:**
```bash
# Python packages
python3 -c "import rich; import questionary; print('OK')"

# System packages
which asciinema openssl sshpass
```

---

### Î: Pot instala dependențele manual?

**R:** Da:
```bash
# Python
pip3 install --user rich questionary

# System
sudo apt install asciinema openssl sshpass
```

---

### Î: Ce fac dacă am Ubuntu 24.04 și pip refuză instalarea?

**R:** Ubuntu 24.04 folosește PEP 668 (*externally-managed-environment*). Soluții:

```bash
# Option 1: --break-system-packages (recommended for this script)
pip3 install --user --break-system-packages rich questionary

# Option 2: pipx (for CLI applications)
pipx install rich questionary

# Option 3: venv (for projects)
python3 -m venv ~/.venvs/homework
source ~/.venvs/homework/bin/activate
pip install rich questionary
```

Scriptul gestionează automat această situație, dar este util să cunoști opțiunile dacă instalezi manual.

---

### Î: Funcționează pe macOS?

**R:** Parțial. Este necesară instalarea manuală cu Homebrew:
```bash
brew install asciinema openssl
# sshpass is not in official Homebrew, use:
brew install hudochenkov/sshpass/sshpass
```

---

## Rulare și utilizare <a id="running-and-usage"></a>

### Î: De ce efectul Matrix arată ciudat?

**R:** Terminalul nu suportă caractere Katakana. Soluții:
1. Folosește un font cu suport Unicode complet (Cascadia Code, Fira Code)
2. Sau folosește varianta Bash: `./record_homework_RO.sh`

Este un aspect vizual; funcționalitatea este identică.

---

### Î: Cum schimb datele salvate (nume, grupă)?

**R:** Două opțiuni:
1. Șterge configurația: `rm ~/.homework_recorder_config.json`
2. Sau suprascrie atunci când ești întrebat de date

---

### Î: Pot rula scriptul dintr-un alt director decât HOMEWORKS?

**R:** Da, dar fișierul `.cast` va fi salvat în directorul curent. Recomandăm utilizarea `~/HOMEWORKS/` pentru organizare.

---

### Î: Ce înseamnă erorile de validare?

**R:**

| Eroare | Cauză | Soluție |
|-------|-------|----------|
| `Use only letters and hyphen` | Spații sau caractere speciale în nume | Elimină spațiile: `John Paul` → `John-Paul` |
| `Group must have exactly 4 digits` | Prea multe / prea puține cifre | Verifică numărul grupei |
| `Format: 01-07 followed by a letter` | Număr temă invalid | Exemplu: `01a`, `03b`, `07c` |

---

## Înregistrare <a id="recording"></a>

### Î: Ce se întâmplă dacă închid accidental terminalul?

**R:** Înregistrarea se oprește și fișierul parțial este salvat. Verifică:
```bash
ls -la ~/HOMEWORKS/*.cast
```
Dacă este prea scurt, șterge-l și începe din nou.

---

### Î: STOP_homework nu funcționează!

**R:** Verifică:
1. Ești în terminalul CORECT (cel în care rulează înregistrarea)
2. Ai tastat exact `STOP_homework` (sensibil la litere mari/mici!)
3. Ai folosit **underscore** `_`, nu cratimă `-`
4. Nu ai spații în plus

**Alternativ:** apasă `Ctrl+D`

> Această situație afectează, de regulă, cel puțin o persoană în fiecare semestru. Confuzia underscore vs cratimă este cea mai frecventă cauză.

---

### Î: Pot face pauză în timpul înregistrării?

**R:** Da, însă asciinema înregistrează și timpul. Cadrul didactic poate accelera redarea, deci nu este o problemă. Pentru pauze foarte lungi (ore), este mai bine să oprești și să reîncepi.

---

### Î: Greșelile sunt vizibile în înregistrare?

**R:** Da, și este acceptabil. Greșelile arată procesul de învățare. NU folosi `clear` pentru a le ascunde. În general, cadrele didactice preferă să vadă cum ai recuperat după erori, deoarece asta indică înțelegere.

---

### Î: Cât de lungă poate fi înregistrarea?

**R:** Tehnic, nu există o limită strictă, însă:
- Recomandare: 5-30 minute
- Fișiere foarte mari (>100MB) pot fi dificil de încărcat
- Nu se vor urmări ore întregi de înregistrare

Păstrează înregistrarea concentrată pe sarcinile temei.

---

## Încărcare și rețea <a id="upload-and-network"></a>

### Î: De ce se folosește portul 1001 și nu 22?

**R:** Serverul sop.ase.ro folosește portul 1001 pentru SCP/SSH din motive de securitate. Unele rețele instituționale sau corporative blochează portul 22.

---

### Î: Încărcarea eșuează mereu. Ce fac?

**R:** Verifică, în ordine:
1. **Internet:** `ping google.com`
2. **Port deschis:** `nc -zv sop.ase.ro 1001`
3. **VPN:** deconectează temporar
4. **Firewall:** încearcă prin hotspot de pe telefon

Dacă nu funcționează, trimite ulterior manual cu comanda afișată de script.

---

### Î: Pot trimite fișierul manual?

**R:** Da:
```bash
scp -P 1001 FILENAME.cast stud-id[AT]sop.ase.ro:/home/HOMEWORKS/SPECIALIZARE/
```
Înlocuiește FILENAME și SPECIALIZARE cu valorile tale.

---

### Î: Serverul este indisponibil. Când va fi disponibil?

**R:** Contactează cadrul didactic. Între timp, fișierul este salvat local și poate fi trimis mai târziu.

---

## Semnătură criptografică <a id="cryptographic-signature"></a>

### Î: Ce date sunt incluse în semnătură?

**R:** Șirul semnat conține:
- Nume + prenume
- Grupă
- Dimensiunea fișierului (bytes)
- Data și ora
- Utilizatorul de sistem
- Calea absolută a fișierului

---

### Î: Pot verifica semnătura?

**R:** Nu direct — doar cadrul didactic are cheia privată. Poți verifica existența ei:
```bash
tail -3 FILENAME.cast
# You should see "## " followed by Base64
```

Sau folosește scriptul de verificare:
```bash
./check_my_submission.sh FILENAME.cast
```

---

### Î: Ce se întâmplă dacă modific fișierul .cast?

**R:** Semnătura devine invalidă și tema va fi respinsă. Dimensiunea fișierului face parte din semnătură, deci orice modificare este detectată.

---

### Î: Pot folosi semnătura altui student?

**R:** Nu. Semnătura include utilizatorul de sistem și calea fișierului. Orice inconsistență este detectată. Evită astfel de încercări.

---

## Verificare <a id="verification"></a>

### Î: Cum îmi verific tema înainte de trimitere?

**R:** Folosește scriptul de verificare:
```bash
./check_my_submission.sh 1029_SMITH_John_HW03b.cast
```

Acesta verifică:
- Fișierul există și are extensia corectă
- Dimensiunea fișierului este rezonabilă
- Semnătura criptografică este prezentă
- Formatul numelui de fișier este corect

---

### Î: Scriptul de verificare spune "signature missing", dar am tastat STOP_homework!

**R:** Semnătura este adăugată DUPĂ oprirea înregistrării, nu în timpul ei. Cauze posibile:
1. Ai apăsat Ctrl+C în loc de STOP_homework sau Ctrl+D
2. Scriptul s-a oprit înainte să genereze semnătura
3. Te uiți la un alt fișier

Reînregistrează dacă este necesar.

---

## Erori specifice <a id="specific-errors"></a>

### Î: "ModuleNotFoundError: No module named 'rich'"

**R:**
```bash
pip3 install --user rich
# Or
python3 -m pip install rich
```

---

### Î: "bash: ./record_homework_tui_RO.py: Permission denied"

**R:**
```bash
chmod +x record_homework_tui_RO.py
# Or run with:
python3 record_homework_tui_RO.py
```

---

### Î: "asciinema: command not found"

**R:**
```bash
sudo apt update
sudo apt install asciinema
```

---

### Î: "sshpass: command not found"

**R:**
```bash
sudo apt install sshpass
```

---

### Î: "openssl: error: ... unable to load Public Key"

**R:** Cheia publică din script este coruptă. Descarcă din nou scriptul din sursa oficială.

---

### Î: "Error: No such file or directory" în timpul încărcării

**R:** Directorul de destinație nu există pe server. Contactează cadrul didactic pentru verificare.

---

## Nu ai găsit răspunsul?

1. Consultă secțiunea de depanare din STUDENT_GUIDE_RO.md
2. Rulează `./check_my_submission.sh` pentru diagnosticarea fișierului
3. Contactează cadrul didactic de laborator cu:
   - Numărul grupei
   - Mesajul exact de eroare
   - Ce ai încercat deja

---

*Sisteme de Operare 2023-2027 - ASE București*
*Ultima actualizare: ianuarie 2025*
