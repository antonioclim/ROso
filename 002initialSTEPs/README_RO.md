# Sistem Înregistrare Teme cu Asciinema

## Sisteme de Operare 2023-2027 - Revolvix/github.com

---

## Conținut pachet

| Fișier | Descriere | Destinație |
|--------|-----------|------------|
| `record_homework_tui_RO.py` | 🆕 **Python TUI (stil Matrix)** - recomandat! | Distribuit studenților |
| `record_homework.sh` | Script Bash pentru studenți | Distribuit studenților |
| `GHID_STUDENT_RO.html` | 📖 **Ghid interactiv HTML** pentru studenți | Distribuit studenților |
| `GHID_STUDENT_RO.md` | 📖 Ghid Markdown pentru studenți | Distribuit studenților |
| `verify_homework.sh` | Script verificare semnături | Server profesor |
| `homework_private.pem` | Cheie privată RSA 1024-bit | **DOAR PE SERVER - SECRET!** |
| `homework_public.pem` | Cheie publică RSA | Deja inclusă în scripturi |

---

## Versiunea Python TUI (RECOMANDAT)

Noua versiune Python în stil Matrix include:
- 🎨 **Temă Matrix frumoasă** (efect de ploaie digitală verde)
- ✨ **Spinnere și bare de progres animate**
- 🖥️ **Meniuri interactive** cu navigare prin săgeți
- 🔄 **Auto-instalare** a tuturor dependențelor
- 🎬 **Efecte de tastare și tranziții vizuale**

### Descărcare versiunea Python TUI:

**Link Google Drive:** https://drive.google.com/file/d/1YLqNamLCdz6OzF6hlcPr1hr738DIaSYz/view?usp=drive_link

### Rulare:

```bash
# Fă-l executabil
chmod +x record_homework_tui_RO.py

# Rulează
./record_homework_tui_RO.py
# sau
python3 record_homework_tui_RO.py
```

Scriptul instalează automat: `rich`, `questionary` (Python) + `asciinema`, `openssl`, `sshpass` (sistem)

---

## Pentru Studenți

### Descărcare (versiunea Bash - alternativă)

**Link Google Drive:** https://drive.google.com/file/d/1dLXPEtGjLo4f9G0Uojd-YXzY7c3ku1Ez/view?usp=drive_link

### Instalare

```bash
# Fă-l executabil
chmod +x record_homework.sh
```

### Utilizare

```bash
./record_homework.sh
```

Scriptul va:
1. ✅ Instala automat pachetele necesare (asciinema, openssl, sshpass)
2. 📝 Cere datele tale (nume, prenume, grupă, specializare, număr temă)
3. 🎬 Porni înregistrarea terminalului
4. 🛑 Opri când tastezi `STOP_tema`
5. 🔐 Genera o semnătură criptografică
6. 📤 Încărca automat pe server

### Format date solicitate

| Câmp | Format | Exemplu |
|------|--------|---------|
| Nume familie | Litere, cratimă (devine UPPERCASE) | `IONESCU-POPESCU` |
| Prenume | Litere, cratimă (devine Title Case) | `Andrei-Maria` |
| Grupă | Exact 4 cifre | `1029` |
| Specializare | 1=eninfo, 2=grupeid, 3=roinfo | `1` |
| Număr temă | 01-07 + literă | `03b` |

### Nume fișier generat

Format: `[Grupă]_[NUME]_[Prenume]_HW[Temă].cast`

Exemplu: `1029_IONESCU_Andrei_HW03b.cast`

---

## Pentru Profesor/Administrator

### Setup server

```bash
# Copiază cheia privată pe server (SECURIZAT!)
scp homework_private.pem user@server:/path/to/secure/location/

# Setează permisiuni restrictive
chmod 600 homework_private.pem

# Copiază scriptul de verificare
scp verify_homework.sh user@server:/path/to/tools/
chmod +x verify_homework.sh
```

### Verificare teme

#### Verifică un singur fișier:
```bash
./verify_homework.sh 1029_IONESCU_Andrei_HW03b.cast
```

#### Verifică toate temele dintr-un director:
```bash
./verify_homework.sh --batch /home/HOMEWORKS/eninfo/
```

#### Extrage doar datele raw (pentru scripting):
```bash
./verify_homework.sh --raw 1029_IONESCU_Andrei_HW03b.cast
```

### Ce verifică scriptul

1. ✅ Decriptează semnătura RSA cu cheia privată
2. ✅ Afișează metadatele: student, grupă, dată, oră, user sistem, cale originală
3. ✅ Verifică consistența între semnătură și numele fișierului
4. ⚠️ Alertează dacă există inconsistențe

---

## Securitate

### Ce protejează semnătura?

Semnătura criptografică garantează:
- **Identitatea** - Cine a creat înregistrarea
- **Momentul** - Când a fost creată (dată + oră)
- **Integritatea** - Fișierul nu a fost modificat după semnare
- **Originea** - De pe ce sistem/user a fost creată

### Format date semnate

```
NUME+PRENUME GRUPA DIMENSIUNE_BYTES DATA ORA USER_SISTEM CALE_ABSOLUTA
```

Exemplu:
```
IONESCU+Andrei 1029 15234 20-01-2025 14:35:22 ionescu /home/ionescu/1029_IONESCU_Andrei_HW03b.cast
```

### Chei RSA

- **Cheie publică** (în script): Poate cripta, NU poate decripta
- **Cheie privată** (pe server): Poate decripta și verifica

⚠️ IMPORTANT: Cheia privată trebuie păstrată SECRET! Dacă este compromisă, oricine poate genera semnături false.

---

## Configurare upload SCP

### Parametri server

| Parametru | Valoare |
|-----------|---------|
| Server | `sop.ase.ro` |
| Port | `1001` |
| User | `stud-id` |
| Parolă | `stud` |
| Destinație | `/home/HOMEWORKS/[specializare]/` |

### Specializări disponibile


Trei lucruri contează aici: `eninfo` - informatică economică (engleză), `grupeid` - grupă id, și `roinfo` - informatică economică (română).


---

## Troubleshooting

### "Permission denied" la instalare pachete

```bash
# Rulează cu sudo explicit
sudo apt update && sudo apt install -y asciinema openssl sshpass
```

### Upload eșuează

Verifică:
1. Conexiune internet
2. Grupa introdusă corect (4 cifre)
3. Serverul este online

Dacă upload-ul eșuează, fișierul este salvat local și numele este afișat pe ecran.

### Semnătura nu poate fi verificată

Posibile cauze:

Concret: Cheie privată incorectă. Fișierul a fost modificat după semnare. Și Fișierul este corupt.


---

## Changelog

### v1.0 (Ianuarie 2025)
- Release inițial
- Validare input completă, și totodată semnătură rsa 1024-bit
- Upload SCP cu retry
- Verificare batch

---

## Contact

Pentru probleme tehnice: [contact ASE-CSIE]
