# ❓ FAQ - Întrebări Frecvente

## Sistem Înregistrare Teme - Sisteme de Operare 2023-2027

---

## 📋 Cuprins

1. [Generale](#generale)
2. [Instalare și Setup](#instalare-și-setup)
3. [Rulare și Utilizare](#rulare-și-utilizare)
4. [Înregistrare](#înregistrare)
5. [Upload și Rețea](#upload-și-rețea)
6. [Semnătură Criptografică](#semnătură-criptografică)
7. [Erori Specifice](#erori-specifice)

---

## Generale

### Q: De ce trebuie să folosesc terminalul propriu și nu serverul sop.ase.ro?

**A:** Înregistrarea asciinema captează TOATĂ activitatea din terminal. Pe server, activitatea ta s-ar amesteca cu a altor studenți, iar fișierul rezultat ar fi inutilizabil. În plus, semnătura criptografică se bazează pe utilizatorul LOCAL.

---

### Q: Pot folosi alt terminal decât cel default?

**A:** Da, orice terminal care suportă secvențe ANSI funcționează:
- **Windows:** Windows Terminal (recomandat), PowerShell, CMD cu Windows Terminal
- **macOS:** iTerm2, Terminal.app
- **Linux:** GNOME Terminal, Konsole, Alacritty, Terminator

---

### Q: Care e diferența între versiunea Python TUI și Bash?

**A:** 

| Aspect | Python TUI | Bash |
|--------|------------|------|
| Interfață | Grafică (Matrix theme) | Text simplu |
| Dependențe | Python 3.8+, rich, questionary | Doar bash |
| Animații | Da (rain, spinners) | Nu |
| Meniuri | Interactive (săgeți) | Text input |
| Recomandare | Pentru majoritatea | Backup/sisteme minimale |

---

### Q: Cât durează procesul complet?

**A:** 
- **Prima dată:** 3-5 minute (instalare dependențe) + timpul tău de rezolvare
- **Ulterior:** ~30 secunde setup + timpul tău de rezolvare + ~30 secunde upload

---

## Instalare și Setup

### Q: Ce versiune de Python am nevoie?

**A:** Python 3.8 sau mai nou. Verifică cu:
```bash
python3 --version
```

---

### Q: Cum verific dacă toate dependențele sunt instalate?

**A:**
```bash
# Python packages
python3 -c "import rich; import questionary; print('OK')"

# System packages
which asciinema openssl sshpass
```

---

### Q: Pot instala manual dependențele?

**A:** Da:
```bash
# Python
pip3 install --user rich questionary

# Sistem
sudo apt install asciinema openssl sshpass
```

---

### Q: Ce fac dacă am Ubuntu 24.04 și pip refuză să instaleze?

**A:** Ubuntu 24.04 folosește PEP 668 (externally-managed-environment). Soluții:

```bash
# Opțiunea 1: --break-system-packages (recomandat pentru acest script)
pip3 install --user --break-system-packages rich questionary

# Opțiunea 2: pipx (pentru aplicații CLI)
pipx install rich questionary

# Opțiunea 3: venv (pentru proiecte)
python3 -m venv ~/.venvs/homework
source ~/.venvs/homework/bin/activate
pip install rich questionary
```

---

### Q: Funcționează pe macOS?

**A:** Parțial. Trebuie să instalezi manual cu Homebrew:
```bash
brew install asciinema openssl
# sshpass nu e în Homebrew oficial, folosește:
brew install hudochenkov/sshpass/sshpass
```

---

## Rulare și Utilizare

### Q: De ce efectul Matrix arată ciudat?

**A:** Terminalul nu suportă caracterele Katakana. Soluții:
1. Folosește un font cu suport Unicode complet (Cascadia Code, Fira Code)
2. Sau folosește versiunea Bash: `./record_homework_RO.sh`

---

### Q: Cum schimb datele salvate (nume, grupă)?

**A:** Două opțiuni:
1. Șterge config-ul: `rm ~/.homework_recorder_config.json`
2. Sau pur și simplu scrie peste când ți se cer datele

---

### Q: Pot rula scriptul din alt director decât HOMEWORKS?

**A:** Da, dar fișierul .cast va fi salvat în directorul curent. Recomandăm să rămâi în `~/HOMEWORKS/` pentru organizare.

---

### Q: Ce înseamnă erorile de validare?

**A:**

| Eroare | Cauză | Soluție |
|--------|-------|---------|
| "Folosește doar litere și cratimă" | Spații sau caractere speciale în nume | Elimină spațiile: `Ana Maria` → `Ana-Maria` |
| "Grupa trebuie să aibă exact 4 cifre" | Prea multe/puține cifre | Verifică numărul grupei |
| "Format: 01-07 urmat de o literă" | Număr temă invalid | Ex: `01a`, `03b`, `07c` |

---

## Înregistrare

### Q: Ce se întâmplă dacă închid terminalul accidental?

**A:** Înregistrarea se oprește și fișierul parțial e salvat. Verifică:
```bash
ls -la ~/HOMEWORKS/*.cast
```
Dacă e prea scurt, șterge-l și reîncepe.

---

### Q: STOP_tema nu funcționează!

**A:** Verifică:
1. Ești în terminalul CORECT (cel cu înregistrarea)
2. Ai scris exact `STOP_tema` (case-sensitive!)
3. Nu ai spații în plus

**Alternativă:** Apasă `Ctrl+D`

---

### Q: Pot face pauză în timpul înregistrării?

**A:** Da, dar asciinema înregistrează și timpul. Profesorul poate accelera playback-ul, deci nu e problemă. Pentru pauze foarte lungi (ore), mai bine oprește și reîncepe.

---

### Q: Greșelile se văd în înregistrare?

**A:** Da, și e OK! Greșelile arată procesul de învățare. NU folosi `clear` să le ascunzi.

---

### Q: Cât de lungă poate fi înregistrarea?

**A:** Tehnic nelimitat, dar:
- Recomandare: 5-30 minute
- Fișierele foarte mari (>100MB) pot fi greu de uploadat
- Profesorul nu va viziona ore întregi de înregistrare

---

## Upload și Rețea

### Q: De ce folosește portul 1001 și nu 22?

**A:** Serverul sop.ase.ro folosește portul 1001 pentru SCP/SSH din motive de securitate. Unele rețele corporative/universitare blochează portul 22.

---

### Q: Upload-ul eșuează mereu. Ce fac?

**A:** Verifică în ordine:
1. **Internet:** `ping google.com`
2. **Port deschis:** `nc -zv sop.ase.ro 1001`
3. **VPN:** Deconectează temporar
4. **Firewall:** Încearcă de pe hotspot mobil

Dacă nimic nu merge, trimite manual mai târziu cu comanda afișată.

---

### Q: Pot trimite manual fișierul?

**A:** Da:
```bash
scp -P 1001 FISIERUL.cast [utilizator]@[server]:/home/HOMEWORKS/SPECIALIZARE/
```
Înlocuiește FISIERUL și SPECIALIZARE cu valorile tale.

---

### Q: Serverul e down. Când va fi disponibil?

**A:** Contactează profesorul. Între timp, fișierul e salvat local și poți trimite mai târziu.

---

## Semnătură Criptografică

### Q: Ce date sunt incluse în semnătură?

**A:** String-ul semnat conține:
- Nume + Prenume
- Grupă
- Dimensiune fișier (bytes)
- Data și ora
- Username sistem
- Cale absolută fișier

---

### Q: Pot verifica semnătura?

**A:** Nu direct - doar profesorul are cheia privată. Poți verifica că există:
```bash
tail -3 FISIER.cast
# Ar trebui să vezi "## " urmat de Base64
```

---

### Q: Ce se întâmplă dacă modific fișierul .cast?

**A:** Semnătura devine invalidă și tema va fi respinsă. Dimensiunea fișierului e parte din semnătură, deci orice modificare se detectează.

---

### Q: Pot folosi semnătura altui student?

**A:** Nu. Semnătura include username-ul tău de sistem și calea fișierului. Orice inconsistență se detectează.

---

## Erori Specifice

### Q: "ModuleNotFoundError: No module named 'rich'"

**A:**
```bash
pip3 install --user rich
# Sau
python3 -m pip install rich
```

---

### Q: "bash: ./record_homework_tui_RO.py: Permission denied"

**A:**
```bash
chmod +x record_homework_tui_RO.py
# Sau rulează cu:
python3 record_homework_tui_RO.py
```

---

### Q: "asciinema: command not found"

**A:**
```bash
sudo apt update
sudo apt install asciinema
```

---

### Q: "sshpass: command not found"

**A:**
```bash
sudo apt install sshpass
```

---

### Q: "openssl: error: ... unable to load Public Key"

**A:** Cheia publică din script e coruptă. Re-descarcă scriptul din sursa oficială.

---

### Q: "Error: No such file or directory" la upload

**A:** Directorul destinație nu există pe server. Contactează profesorul pentru verificare.

---

## Nu ai găsit răspunsul?

1. Verifică secțiunea Troubleshooting din GHID_STUDENT_RO.md
2. Contactează profesorul de laborator
3. Descrie problema exact: ce ai făcut, ce ai văzut, ce te așteptai să vezi

---

*Sisteme de Operare 2023-2027 - ASE București*
*Ultima actualizare: Ianuarie 2025*
