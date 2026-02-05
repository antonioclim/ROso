# Sistem de înregistrare a temelor cu Asciinema

## Sisteme de Operare 2023-2027 - Revolvix/github.com

**Versiune:** 1.1.1 | **Data:** ianuarie 2025

---

## 📚 Documentație

| Document | Descriere |
|----------|-----------|
| [STUDENT_GUIDE_RO.md](STUDENT_GUIDE_RO.md) | 📖 **Ghid complet** pentru studenți (CITEȘTE ÎNAINTE DE ORICE!) |
| [FAQ_RO.md](FAQ_RO.md) | ❓ Întrebări frecvente și răspunsuri rapide |
| [CHANGELOG_RO.md](CHANGELOG_RO.md) | 📜 Istoricul modificărilor |

---

## Conținutul pachetului

| Fișier | Descriere | Destinație |
|------|-------------|--------|
| `record_homework_tui_RO.py` | 🆕 **Interfață TUI în Python (stil Matrix)** — recomandat! | Distribuit studenților |
| `record_homework_RO.sh` | Script Bash pentru studenți (alternativă) | Distribuit studenților |
| `check_my_submission.sh` | 🆕 **Verifică predarea** înainte de trimitere | Distribuit studenților |
| `STUDENT_GUIDE_RO.html` | 📖 **Ghid HTML** pentru studenți | Distribuit studenților |
| `STUDENT_GUIDE_RO.md` | 📖 Ghid Markdown pentru studenți | Distribuit studenților |
| `FAQ_RO.md` | ❓ Întrebări frecvente | Distribuit studenților |
| `CHANGELOG_RO.md` | 📜 Istoric versiuni | Referință |
| `examples/` | 📁 Înregistrări exemplu pentru previzualizare | Referință |

---

## 🎬 Tutorial video

*În curând: un walkthrough de aproximativ 3 minute care prezintă întregul proces de înregistrare.*

Până atunci, diagrama ASCII din [STUDENT_GUIDE_RO.md](STUDENT_GUIDE_RO.md) oferă o privire de ansamblu. Poți previzualiza și o înregistrare exemplu:

```bash
# Preview the sample recording (requires asciinema)
asciinema play examples/sample_submission_demo.cast
```

---

## ✅ Verificare înainte de trimitere

Înainte să trimiți tema, verific-o local cu scriptul de verificare:

```bash
chmod +x check_my_submission.sh
./check_my_submission.sh 1029_SMITH_John_HW03b.cast
```

Acesta verifică:
- ✓ Fișierul există și are extensia corectă
- ✓ Dimensiunea fișierului este rezonabilă (nu este trunchiat)
- ✓ Semnătura criptografică este prezentă
- ✓ Numele fișierului respectă formatul cerut
- ✓ Conținutul este în format asciinema valid

---

## Înregistrare exemplu

Vrei să vezi cum arată o înregistrare completă? Consultă `examples/sample_submission_demo.cast`:

```bash
# Preview in terminal (requires asciinema installed)
asciinema play examples/sample_submission_demo.cast

# Or view the raw file structure
head -20 examples/sample_submission_demo.cast
```

---

## Varianta Python TUI (RECOMANDAT)

Noua versiune în stil Matrix include:
- 🎨 **Tematică Matrix** (efect de „ploaie” digitală)
- ✨ **Indicatoare animate** (spinners) și bare de progres
- 🖥️ **Meniuri interactive** cu navigare din tastele săgeți
- 🔄 **Instalare automată** a dependențelor
- 🎬 Efecte vizuale (tranziții, efect de tastare)

### Descărcare (varianta Python TUI):

**Link Google Drive:** https://drive.google.com/file/d/1YLqNamLCdz6OzF6hlcPr1hr738DIaSYz/view?usp=drive_link

### Rulare:

```bash
# Make it executable
chmod +x record_homework_tui_RO.py

# Run
./record_homework_tui_RO.py
# or
python3 record_homework_tui_RO.py
```

Scriptul instalează automat: `rich`, `questionary` (Python) și `asciinema`, `openssl`, `sshpass` (sistem)

---

## Pentru studenți

### Descărcare (varianta Bash — alternativă)

**Link Google Drive:** https://drive.google.com/file/d/1dLXPEtGjLo4f9G0Uojd-YXzY7c3ku1Ez/view?usp=drive_link

### Instalare

```bash
# Make it executable
chmod +x record_homework_RO.sh
```

### Utilizare

```bash
./record_homework_RO.sh
```

Scriptul:
1. ✅ Instalează automat pachetele necesare (asciinema, openssl, sshpass)
2. 📝 Solicită datele tale (nume, prenume, grupă, specializare, număr temă)
3. 🎬 Pornește înregistrarea terminalului
4. 🛑 Oprește când tastezi `STOP_homework`
5. 🔐 Generează o semnătură criptografică
6. 📤 Încarcă automat pe server

### Formatul datelor solicitate

| Câmp | Format | Exemplu |
|-------|--------|---------|
| Nume (familie) | Litere, cratimă (devine MAJUSCULE) | `SMITH-JONES` |
| Prenume | Litere, cratimă (devine scriere cu inițială mare) | `John-Paul` |
| Grupă | Exact 4 cifre | `1029` |
| Specializare | 1=eninfo, 2=grupeid, 3=roinfo | `1` |
| Număr temă | 01-07 + literă | `03b` |

### Numele fișierului generat

Format: `[Grupă]_[NUME]_[Prenume]_HW[Număr].cast`

Exemplu: `1029_SMITH_John_HW03b.cast`

---

## 🆕 Noutăți în versiunea 1.1.1

- ✅ **Mod strict complet** în Bash (`set -euo pipefail` cu `IFS`)
- ✅ **Instalare pachete pe bază de array** (mai sigură, fără word splitting)
- ✅ **Script nou de verificare** (`check_my_submission.sh`)
- ✅ **Înregistrare exemplu** în directorul `examples/`
- ✅ **Documentație îmbunătățită** cu ghid de rulare de probă
- ✅ **Depanare extinsă** cu situații reale întâlnite în semestre anterioare

Consultă [CHANGELOG_RO.md](CHANGELOG_RO.md) pentru lista completă a modificărilor.

---

## Pentru cadre didactice

> **Notă:** Scripturile de verificare (`verify_homework.sh`) și cheile RSA
> (`homework_private.pem`, `homework_public.pem`) sunt distribuite separat prin canalul securizat.

### Cerințe de sistem

- Ubuntu 22.04+ sau WSL2 cu Ubuntu
- Python 3.8+
- Pachete: asciinema, openssl, sshpass (instalate automat)

### Configurare server

Serverul de destinație trebuie să aibă:
- SSH pe portul 1001
- Directoare: `/home/HOMEWORKS/{eninfo,grupeid,roinfo}/`
- Utilizator: `stud-id` cu parola `stud`

---

## Suport

În caz de probleme:
1. Rulează `./check_my_submission.sh` pentru diagnosticarea erorilor
2. Consultă [FAQ_RO.md](FAQ_RO.md) și [STUDENT_GUIDE_RO.md](STUDENT_GUIDE_RO.md)
3. Discută cu cadrul didactic (laborator/seminar)
4. Verifică dacă ai cea mai recentă versiune a scripturilor

---

*Realizat de Revolvix pentru disciplina SISTEME DE OPERARE | licență restrictivă 2017-2030*
