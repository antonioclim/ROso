# Ghid de Utilizare - Înregistrare Teme

## Sisteme de Operare 2023-2027

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

### Pasul 2: Creează directorul pentru teme

```bash
# Creează directorul HOMEWORKS în home-ul tău
mkdir -p ~/HOMEWORKS

# Verifică că s-a creat
ls -la ~/HOMEWORKS
```

Observație: `~` reprezintă directorul tău home (`/home/{utilizator}/`).

### Pasul 3: Descarcă scriptul folosind WinSCP (sau browser)

Opțiunea A: Descarcă din Google Drive (recomandat)

1. Deschide link-ul în browser:
   - Python TUI (recomandat): https://drive.google.com/file/d/1YLqNamLCdz6OzF6hlcPr1hr738DIaSYz/view?usp=drive_link
   - Bash (alternativă): https://drive.google.com/file/d/1dLXPEtGjLo4f9G0Uojd-YXzY7c3ku1Ez/view?usp=drive_link

2. Click pe Download (sau iconița ⬇️)

3. Salvează fișierul pe calculatorul tău Windows

Opțiunea B: Descarcă direct cu wget în terminal

```bash
# Intră în directorul HOMEWORKS
cd ~/HOMEWORKS

# Descarcă scriptul Python TUI direct din Google Drive
wget -O record_homework_tui_RO.py "https://drive.google.com/uc?export=download&id=1YLqNamLCdz6OzF6hlcPr1hr738DIaSYz"
```

> 💡 Această metodă descarcă fișierul direct în folderul HOMEWORKS, fără pași intermediari!

Opțiunea C: Copiază scriptul în Ubuntu folosind WinSCP

1. Deschide WinSCP și conectează-te la sistemul tău Ubuntu/WSL
2. Navighează la `/home/{utilizator}/HOMEWORKS/`
3. Copiază fișierul descărcat (`record_homework_tui_RO.py`) în acest director

Opțiunea D: Copiază direct în WSL (dacă folosești WSL)

```bash
# Fișierele descărcate în Windows sunt accesibile din WSL la:
# /mnt/c/Users/{NumeWindows}/Downloads/

# Copiază scriptul în directorul HOMEWORKS
cp /mnt/c/Users/{NumeWindows}/Downloads/record_homework_tui_RO.py ~/HOMEWORKS/
```

### Pasul 4: Fă scriptul executabil

```bash
cd ~/HOMEWORKS
chmod +x record_homework_tui_RO.py
```

### Pasul 5: Verifică structura

```bash
# Verifică că fișierul există
ls -la ~/HOMEWORKS/
```

Ar trebui să vezi:
```
drwxr-xr-x  2 {utilizator} {utilizator} 4096 ian 21 10:00 .
drwxr-xr-x 15 {utilizator} {utilizator} 4096 ian 21 09:55 ..
-rwxr-xr-x  1 {utilizator} {utilizator} 38000 ian 21 10:00 record_homework_tui_RO.py
```

---

## Pornire Rapidă (de fiecare dată)

### Pasul 1: Intră în directorul HOMEWORKS

```bash
cd ~/HOMEWORKS
```

### Pasul 2: Rulează scriptul

```bash
python3 record_homework_tui_RO.py
```

### Pasul 3: Urmează instrucțiunile de pe ecran

---

## Prima Utilizare (Durează Mai Mult!)

La prima rulare, scriptul va:

1. ✅ Verifica și instala `pip` (dacă lipsește)
2. ✅ Instala bibliotecile Python: `rich`, `questionary`
3. ✅ Instala utilitarele de sistem: `asciinema`, `openssl`, `sshpass`

Acest proces poate dura 1-3 minute în funcție de conexiunea la internet.

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
  - Informatică Economică (Engleză)
  - Grupă ID
  - Informatică Economică (Română)

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
╔═══════════════════════════════════════════════════════════════════════╗
║                     🔴 ÎNREGISTRARE ÎN CURS                           ║
╠═══════════════════════════════════════════════════════════════════════╣
║                                                                       ║
║   Pentru a OPRI și SALVA înregistrarea, tastează: STOP_tema           ║
║                                                                       ║
║   sau apasă Ctrl+D                                                    ║
║                                                                       ║
╚═══════════════════════════════════════════════════════════════════════╝
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
╔═══════════════════════════════════════════════════════════════════════╗
║                     ✅ ÎNCĂRCARE REUȘITĂ!                             ║
╚═══════════════════════════════════════════════════════════════════════╝
```

### Dacă upload-ul eșuează:

Fișierul este salvat local și vei vedea un mesaj cu comanda pentru trimitere manuală:

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                          Trimitere Eșuată                                    ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                                                                              ║
║   ❌ NU AM PUTUT TRIMITE TEMA!                                               ║
║                                                                              ║
║   Fișierul a fost salvat local.                                              ║
║                                                                              ║
║   ╔════════════════════════════════════════════════════════════════════╗     ║
║   ║                                                                    ║     ║
║   ║   📁  1029_IONESCU_Andrei_HW03b.cast                               ║     ║
║   ║                                                                    ║     ║
║   ╚════════════════════════════════════════════════════════════════════╝     ║
║                                                                              ║
║   Încearcă mai târziu (când restabilești conexiunea la internet) folosind:   ║
║                                                                              ║
║   scp -P 1001 1029_IONESCU_Andrei_HW03b.cast stud-id@sop.ase.ro:/home/...    ║
║                                                                              ║
║   ⚠️  NU modifica fișierul .cast înainte de trimitere!                       ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
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

## Probleme Frecvente

### "Permission denied" la instalare

```bash
# Asigură-te că ești în directorul HOMEWORKS
cd ~/HOMEWORKS

# Rulează cu sudo prima dată (pentru instalare dependențe)
sudo python3 record_homework_tui_RO.py
```

### "Connection refused" la upload

Cauze posibile:
- Nu ești conectat la internet
- Serverul este temporar indisponibil
- Ești într-o rețea restricționată

Soluție: Fișierul este salvat local. Încearcă mai târziu sau contactează profesorul.

### Scriptul nu pornește

```bash
# Verifică versiunea Python
python3 --version

# Trebuie să fie Python 3.8 sau mai nou
```

### Am greșit datele introduse

Rulează scriptul din nou și introdu datele corecte. Fișierul anterior va fi suprascris.

---

## Despre Semnătura Criptografică

Fiecare înregistrare este semnată digital cu RSA. Aceasta garantează:

- ✅ Autenticitatea - profesorul poate verifica că tu ai creat fișierul
- ✅ Integritatea - fișierul nu poate fi modificat după semnare
- ✅ Non-repudierea - nu poți nega că ai trimis tema
- Verifică întotdeauna rezultatul înainte de a continua

NU poți falsifica semnătura altui student!

---

## Suport

Pentru probleme tehnice:
- Contactează profesorul de laborator
- Verifică dacă ai ultima versiune a scriptului

---

*Sisteme de Operare 2023-2027 - ASE București*
