# 🤝 Ghid de contribuție

## Pentru cadre didactice care doresc să adapteze sistemul

Acest document explică modul în care poți personaliza sistemul de înregistrare a temelor pentru disciplina ta.

---

## Modificări necesare pentru adaptare

### 1. Generarea cheilor RSA

Fiecare disciplină ar trebui să aibă propria pereche de chei pentru semnături:

```bash
# Generate private key (keep SECRET!)
openssl genrsa -out homework_private.pem 2048

# Extract public key (goes into scripts)
openssl rsa -in homework_private.pem -pubout -out homework_public.pem

# Verify keys
openssl rsa -in homework_private.pem -check
```

**IMPORTANT:**
- `homework_private.pem` — NICIODATĂ într-un repository public!
- `homework_public.pem` — inclus în scripturi (sigur)

---

### 2. Configurare server

Modifică constantele din ambele scripturi:

**Python (record_homework_tui_RO.py):**
```python
SCP_SERVER: str = "server.university.ac.uk"
SCP_PORT: str = "22"  # or another port
SCP_PASSWORD: str = "course_password"  # or use SSH keys
SCP_BASE_PATH: str = "/path/to/homeworks"
```

**Bash (record_homework_RO.sh):**
```bash
readonly SCP_SERVER="server.university.ac.uk"
readonly SCP_PORT="22"
readonly SCP_PASSWORD="course_password"
readonly SCP_BASE_PATH="/path/to/homeworks"
```

---

### 3. Specializări / secțiuni

Modifică dicționarul de specializări în funcție de structura disciplinei:

**Python:**
```python
SPECIALIZATIONS: Dict[str, Tuple[str, str]] = {
    "1": ("group_A", "Group A - Monday"),
    "2": ("group_B", "Group B - Tuesday"),
    "3": ("group_C", "Group C - Wednesday"),
}
```

**Bash:**
```bash
# In the collect_student_data() function, modify:
echo "   1) group_A  - Group A - Monday"
echo "   2) group_B  - Group B - Tuesday"
echo "   3) group_C  - Group C - Wednesday"
```

---

### 4. Formatarea numelui de fișier

Dacă dorești un alt format pentru numele fișierului:

**Python:**
```python
def generate_filename(data: Dict[str, str]) -> str:
    # Original format: GROUP_SURNAME_FirstName_HWxx.cast
    # Customised: YYYYMMDD_GROUP_SURNAME_homework.cast
    date_str = datetime.now().strftime("%Y%m%d")
    return f"{date_str}_{data['group']}_{data['surname']}_homework{data['homework']}.cast"
```

---

### 5. Cheia publică în scripturi

Înlocuiește variabila `PUBLIC_KEY` cu conținutul fișierului `homework_public.pem`:

```python
PUBLIC_KEY: str = """-----BEGIN PUBLIC KEY-----
YOUR_KEY_CONTENTS_HERE
-----END PUBLIC KEY-----"""
```

---

## Script de verificare a semnăturii

Pentru verificarea temelor predate, creează un script `verify_homework.sh`:

```bash
#!/bin/bash
# verify_homework.sh - Verify homework signature
# Usage: ./verify_homework.sh homework.cast

set -euo pipefail

PRIVATE_KEY="homework_private.pem"
CAST_FILE="$1"

# Extract signature (last line starting with ##)
SIGNATURE=$(grep "^## " "$CAST_FILE" | tail -1 | cut -d' ' -f2)

if [[ -z "$SIGNATURE" ]]; then
    echo "❌ Missing signature in file!"
    exit 1
fi

# Decode and decrypt
DECRYPTED=$(echo "$SIGNATURE" | base64 -d | openssl pkeyutl -decrypt -inkey "$PRIVATE_KEY")

echo "✅ Valid signature!"
echo "📋 Signed data:"
echo "$DECRYPTED"

# Parse components
IFS=' ' read -r STUDENT GROUP SIZE DATE TIME USER PATH <<< "$DECRYPTED"

echo ""
echo "   Student: $STUDENT"
echo "   Group: $GROUP"
echo "   Size: $SIZE bytes"
echo "   Date: $DATE $TIME"
echo "   User: $USER"

# Verify file size
ACTUAL_SIZE=$(stat -c%s "$CAST_FILE")
# Note: size includes the added signature, so it will be slightly larger
echo ""
echo "   Actual size: $ACTUAL_SIZE bytes"
```

---

## Testare locală

### Fără încărcare reală (dry-run)

Comentează secțiunea de încărcare pentru testare:

```python
# In main():
# upload_success = upload_homework(filepath, data)
upload_success = False  # Simulate failure for local testing
```

### Cu server SFTP local (Docker)

```bash
# Start an SFTP container for testing
docker run -d     --name sftp-test     -p 2222:22     -v $(pwd)/test_uploads:/home/stud/HOMEWORKS     atmoz/sftp stud:stud:::HOMEWORKS

# Temporarily modify port in script to 2222
# and server to localhost
```

---

## Structura proiectului

```
02_INIT_TEME_EN/
├── README_RO.md              # Main documentation
├── STUDENT_GUIDE_RO.md       # Detailed student guide
├── STUDENT_GUIDE_RO.html     # HTML version (generated)
├── FAQ_RO.md                 # Frequently asked questions
├── CHANGELOG_RO.md           # Version history
├── CONTRIBUTING_RO.md        # This file
├── record_homework_tui_RO.py # Main Python script
└── record_homework_RO.sh     # Alternative Bash script
```

---

## Generarea HTML din Markdown

Dacă modifici `STUDENT_GUIDE_RO.md`, regenerează HTML-ul:

```bash
# With pandoc
pandoc STUDENT_GUIDE_RO.md -o STUDENT_GUIDE_RO.html --standalone --toc

# With grip (GitHub style preview)
pip install grip
grip STUDENT_GUIDE_RO.md --export STUDENT_GUIDE_RO.html
```

---

## Raportarea problemelor

Pentru erori sau sugestii:
- creează un Issue în repository
- sau contactează echipa disciplinei conform canalelor oficiale (de exemplu, cele din programă)

---

## Licență

Codul este proprietar și destinat exclusiv utilizării în cadrul disciplinei Sisteme de Operare.

Modificările pentru uz personal sunt permise. Redistribuirea publică necesită aprobare.

---

*Sisteme de Operare 2023-2027 - ASE București*
