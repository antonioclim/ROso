# 🤝 Ghid de Contribuție

## Pentru Instructori care Doresc să Adapteze Sistemul

Acest document explică cum să personalizați sistemul de înregistrare teme pentru propriul curs.

---

## Modificări Necesare pentru Adaptare

### 1. Generarea Cheilor RSA

Fiecare curs ar trebui să aibă propria pereche de chei pentru semnături:

```bash
# Generează cheia privată (păstrează SECRETĂ!)
openssl genrsa -out homework_private.pem 2048

# Extrage cheia publică (se pune în scripturi)
openssl rsa -in homework_private.pem -pubout -out homework_public.pem

# Verifică cheile
openssl rsa -in homework_private.pem -check
```

**IMPORTANT:**
- `homework_private.pem` — NICIODATĂ în repository public!
- `homework_public.pem` — Se include în scripturi (e sigur)

---

### 2. Configurare Server

Modificați constantele în ambele scripturi:

**Python (record_homework_tui_RO.py):**
```python
SCP_SERVER: str = "server.universitate.ro"
SCP_PORT: str = "22"  # sau alt port
SCP_PASSWORD: str = "parola_curs"  # sau folosiți SSH keys
SCP_BASE_PATH: str = "/path/to/homeworks"
```

**Bash (record_homework_RO.sh):**
```bash
readonly SCP_SERVER="server.universitate.ro"
readonly SCP_PORT="22"
readonly SCP_PASSWORD="parola_curs"
readonly SCP_BASE_PATH="/path/to/homeworks"
```

---

### 3. Specializări/Secțiuni

Modificați dicționarul de specializări pentru structura cursului vostru:

**Python:**
```python
SPECIALIZATIONS: Dict[str, Tuple[str, str]] = {
    "1": ("grupa_A", "Grupa A - Luni"),
    "2": ("grupa_B", "Grupa B - Marți"),
    "3": ("grupa_C", "Grupa C - Miercuri"),
}
```

**Bash:**
```bash
# În funcția collect_student_data(), modificați:
echo "   1) grupa_A  - Grupa A - Luni"
echo "   2) grupa_B  - Grupa B - Marți"
echo "   3) grupa_C  - Grupa C - Miercuri"
```

---

### 4. Formatare Nume Fișier

Dacă doriți alt format pentru numele fișierului:

**Python:**
```python
def generate_filename(data: Dict[str, str]) -> str:
    # Format original: GRUPA_NUME_Prenume_HWxx.cast
    # Personalizat: YYYYMMDD_GRUPA_NUME_tema.cast
    date_str = datetime.now().strftime("%Y%m%d")
    return f"{date_str}_{data['group']}_{data['surname']}_tema{data['homework']}.cast"
```

---

### 5. Cheia Publică în Scripturi

Înlocuiți variabila `PUBLIC_KEY` cu conținutul din `homework_public.pem`:

```python
PUBLIC_KEY: str = """-----BEGIN PUBLIC KEY-----
CONȚINUTUL_CHEII_VOASTRE_AICI
-----END PUBLIC KEY-----"""
```

---

## Script de Verificare Semnături

Pentru verificarea temelor primite, creați un script `verify_homework.sh`:

```bash
#!/bin/bash
# verify_homework.sh - Verifică semnătura unei teme
# Utilizare: ./verify_homework.sh tema.cast

set -euo pipefail

PRIVATE_KEY="homework_private.pem"
CAST_FILE="$1"

# Extrage semnătura (ultima linie care începe cu ##)
SIGNATURE=$(grep "^## " "$CAST_FILE" | tail -1 | cut -d' ' -f2)

if [[ -z "$SIGNATURE" ]]; then
    echo "❌ Semnătură lipsă în fișier!"
    exit 1
fi

# Decodează și decriptează
DECRYPTED=$(echo "$SIGNATURE" | base64 -d | openssl pkeyutl -decrypt -inkey "$PRIVATE_KEY")

echo "✅ Semnătură validă!"
echo "📋 Date semnate:"
echo "$DECRYPTED"

# Parsează componentele
IFS=' ' read -r STUDENT GROUP SIZE DATE TIME USER PATH <<< "$DECRYPTED"

echo ""
echo "   Student: $STUDENT"
echo "   Grupă: $GROUP"
echo "   Dimensiune: $SIZE bytes"
echo "   Data: $DATE $TIME"
echo "   Utilizator: $USER"

# Verifică dimensiunea fișierului
ACTUAL_SIZE=$(stat -c%s "$CAST_FILE")
# Nota: dimensiunea include semnătura adăugată, deci va fi puțin mai mare
echo ""
echo "   Dimensiune actuală: $ACTUAL_SIZE bytes"
```

---

## Testare Locală

### Fără upload real (dry-run)

Comentați secțiunea de upload pentru testare:

```python
# În main():
# upload_success = upload_homework(filepath, data)
upload_success = False  # Simulează eșec pentru testare locală
```

### Cu server SFTP local (Docker)

```bash
# Pornește un container SFTP pentru testare
docker run -d \
    --name sftp-test \
    -p 2222:22 \
    -v $(pwd)/test_uploads:/home/stud/HOMEWORKS \
    atmoz/sftp stud:stud:::HOMEWORKS

# Modifică temporar portul în script la 2222
# și serverul la localhost
```

---

## Structura Proiectului

```
02_INIT_TEME/
├── README_RO.md              # Documentație principală
├── GHID_STUDENT_RO.md        # Ghid detaliat studenți
├── GHID_STUDENT_RO.html      # Versiune HTML (generată)
├── FAQ.md                    # Întrebări frecvente
├── CHANGELOG.md              # Istoric versiuni
├── CONTRIBUTING.md           # Acest fișier
├── record_homework_tui_RO.py # Script principal Python
└── record_homework_RO.sh     # Script alternativ Bash
```

---

## Generare HTML din Markdown

Dacă modificați `GHID_STUDENT_RO.md`, regenerați HTML-ul:

```bash
# Cu pandoc
pandoc GHID_STUDENT_RO.md -o GHID_STUDENT_RO.html --standalone --toc

# Cu grip (preview GitHub style)
pip install grip
grip GHID_STUDENT_RO.md --export GHID_STUDENT_RO.html
```

---

## Raportare Probleme

Pentru buguri sau sugestii:
- Creați un Issue în repository
- Sau contactați echipa SO la adresa din syllabus

---

## Licență

Codul este proprietar și destinat exclusiv utilizării în cadrul cursului de Sisteme de Operare, ASE București.

Modificările pentru uz propriu sunt permise. Redistribuirea publică necesită aprobare.

---

*Sisteme de Operare 2023-2027 - ASE București*
