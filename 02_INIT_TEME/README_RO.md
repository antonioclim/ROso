# Sistem Înregistrare Teme cu Asciinema

## Sisteme de Operare 2023-2027 - Revolvix/github.com

**Versiunea:** 1.1.0 | **Data:** Ianuarie 2025

---

## 📚 Documentație

| Document | Descriere |
|----------|-----------|
| [GHID_STUDENT_RO.md](GHID_STUDENT_RO.md) | 📖 **Ghid complet** pentru studenți (CITEȘTE PRIMUL!) |
| [FAQ.md](FAQ.md) | ❓ Întrebări frecvente și răspunsuri rapide |
| [CHANGELOG.md](CHANGELOG.md) | 📜 Istoricul modificărilor |

---

## Conținut pachet

| Fișier | Descriere | Destinație |
|--------|-----------|------------|
| `record_homework_tui_RO.py` | 🆕 **Python TUI (stil Matrix)** - recomandat! | Distribuit studenților |
| `record_homework_RO.sh` | Script Bash pentru studenți (alternativă) | Distribuit studenților |
| `GHID_STUDENT_RO.html` | 📖 **Ghid interactiv HTML** pentru studenți | Distribuit studenților |
| `GHID_STUDENT_RO.md` | 📖 Ghid Markdown pentru studenți | Distribuit studenților |
| `FAQ.md` | ❓ Întrebări frecvente | Distribuit studenților |
| `CHANGELOG.md` | 📜 Istoricul versiunilor | Referință |

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
chmod +x record_homework_RO.sh
```

### Utilizare

```bash
./record_homework_RO.sh
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

## 🆕 Noutăți în versiunea 1.1.0

- ✅ **Strict mode complet** în Bash (`set -euo pipefail`)
- ✅ **Type hints** în tot codul Python
- ✅ **FAQ extins** cu 40+ întrebări frecvente
- ✅ **Troubleshooting** cu 20+ scenarii de probleme
- ✅ **Output așteptat** după fiecare comandă din ghid
- ✅ **Diagrama procesului** de înregistrare
- ✅ **Documentație îmbunătățită** cu limbaj încurajator

Vezi [CHANGELOG.md](CHANGELOG.md) pentru lista completă de modificări.

---

## Pentru Instructori

> **Notă:** Scripturile de verificare (`verify_homework.sh`) și cheile RSA 
> (`homework_private.pem`, `homework_public.pem`) sunt distribuite separat prin canalul securizat.

### Cerințe sistem

- Ubuntu 22.04+ sau WSL2 cu Ubuntu
- Python 3.8+
- Pachete: asciinema, openssl, sshpass (instalate automat)

### Configurare server

Serverul destinație trebuie să aibă:
- SSH pe portul 1001
- Directoare: `/home/HOMEWORKS/{eninfo,grupeid,roinfo}/`
- Utilizator: `stud-id` cu parola `stud`

---

## Suport

Pentru probleme:
1. Consultă [FAQ.md](FAQ.md) și [GHID_STUDENT_RO.md](GHID_STUDENT_RO.md)
2. Contactează profesorul de laborator
3. Verifică că ai ultima versiune a scripturilor

---

*By Revolvix for OPERATING SYSTEMS class | restricted licence 2017-2030*
