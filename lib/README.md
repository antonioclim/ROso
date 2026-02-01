# Utilități Partajate ROso — lib/

> **Scop:** Module utilitare centralizate folosite în toate seminariile  
> **Autor:** ing. dr. Antonio Clim | ASE București — CSIE  
> **Versiune:** 1.0 | **Actualizat:** Ianuarie 2025

---

## Prezentare Generală

Directorul `lib/` conține module Python partajate care oferă funcționalitate consistentă în toate pachetele de seminarii. Aceste utilități asigură logging uniform, randomizare deterministă pentru măsuri anti-plagiat și alte aspecte transversale.

**De ce utilități centralizate?**

1. **Consistență** — Toate seminariile folosesc format de logging și algoritmi de randomizare identici
2. **Mentenabilitate** — Corecturile de erori se propagă automat în toate seminariile
3. **Testare** — Codul partajat este testat o singură dată, folosit peste tot
4. **Limba Engleză Britanică** — Aplicare centralizată a convențiilor de ortografie

---

## Module

### logging_utils.py

Oferă logging consistent, structurat cu suport pentru culori în terminal.

**Clase:**

| Clasă | Scop |
|-------|---------|
| `ColouredFormatter` | Nivele de log codificate cu culori ANSI pentru terminal |

**Funcții:**

| Funcție | Semnătură | Scop |
|----------|-----------|---------|
| `setup_logging` | `(name, level=INFO, log_file=None, use_colours=True) → Logger` | Configurează un logger cu valorile implicite ROso |
| `get_logger` | `(name) → Logger` | Wrapper convenabil pentru acces rapid la logger |

**Utilizare:**

```python
import sys
from pathlib import Path

# Adaugă lib/ în path (ajustează calea relativă după necesități)
sys.path.insert(0, str(Path(__file__).parent.parent.parent / 'lib'))
from logging_utils import setup_logging, get_logger

# Opțiunea 1: Configurare completă
logger = setup_logging(
    name=__name__,
    level=logging.DEBUG,
    log_file=Path('/tmp/scriptul_meu.log'),
    use_colours=True
)

# Opțiunea 2: Acces rapid cu valori implicite
logger = get_logger(__name__)

# Folosește logger-ul
logger.debug("Informații de debugging")
logger.info("Procesare începută")
logger.warning("Spațiu disc redus detectat")
logger.error("Fișier negăsit: config.yaml")
logger.critical("Conexiune bază de date eșuată!")
```

**Output (terminal cu culori):**
```
[2025-01-30 10:00:00] [DEBUG] modulul_meu: Informații de debugging
[2025-01-30 10:00:01] [INFO] modulul_meu: Procesare începută
[2025-01-30 10:00:02] [WARNING] modulul_meu: Spațiu disc redus detectat
[2025-01-30 10:00:03] [ERROR] modulul_meu: Fișier negăsit: config.yaml
[2025-01-30 10:00:04] [CRITICAL] modulul_meu: Conexiune bază de date eșuată!
```

**Schemă Culori:**

| Nivel | Culoare | Cod ANSI |
|-------|--------|-----------|
| DEBUG | Cyan | `\033[0;36m` |
| INFO | Verde | `\033[0;32m` |
| WARNING | Galben | `\033[0;33m` |
| ERROR | Roșu | `\033[0;31m` |
| CRITICAL | Roșu Îngroșat | `\033[1;31m` |

---

### randomisation_utils.py

Generează parametri de testare deterministici, specifici fiecărui student pentru scopuri anti-plagiat.

**Principiu Cheie:** Același student + aceeași temă = același seed = aceiași parametri de testare. Studenți diferiți primesc parametri diferiți. Acest lucru asigură că fiecare student are cazuri de test unice menținând în același timp reproductibilitatea pentru notare.

**Clase:**

| Clasă | Scop |
|-------|---------|
| `TestParameters` | Container dataclass pentru toate valorile randomizate |

**Funcții:**

| Funcție | Semnătură | Scop |
|----------|-----------|---------|
| `generate_student_seed` | `(student_id, assignment, include_week=True) → int` | Creează seed reproductibil din identitatea studentului |
| `randomise_test_parameters` | `(seed) → TestParameters` | Generează setul complet de parametri din seed |

**Câmpuri TestParameters:**

| Categorie | Câmpuri | Exemple Valori |
|----------|--------|----------------|
| **Rețea** | `ip_addresses`, `ports` | `['192.168.47.12']`, `[8080, 3306]` |
| **Sistem Fișiere** | `file_sizes`, `file_names`, `directory_names` | `[1024, 2048]`, `['data_alpha.txt']` |
| **Timp** | `timestamps`, `cron_hours`, `cron_days` | `[1706612400]`, `[9, 14]`, `[1, 15]` |
| **Procese** | `pids`, `signals` | `[1234, 5678]`, `[9, 15, 2]` |
| **Permisiuni** | `usernames`, `permissions_octal` | `['alice', 'bob']`, `['755', '644']` |
| **Text** | `search_patterns`, `line_numbers` | `['ERROR.*failed']`, `[10, 25, 100]` |
| **General** | `random_strings`, `random_numbers` | `['xK9mP2']`, `[42, 137]` |
| **Metadate** | `seed`, `student_id`, `assignment` | Urmărire identitate |

**Utilizare:**

```python
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent.parent / 'lib'))
from randomisation_utils import generate_student_seed, randomise_test_parameters

# Generează seed pentru un student și o temă specifice
seed = generate_student_seed(
    student_id="ion.popescu@stud.ase.ro",
    assignment="SEM03_HW",
    include_week=False  # Folosește True pentru variație săptămânală
)

# Generează toți parametrii de testare
params = randomise_test_parameters(seed)

# Folosește în autograder
print(f"Testare cu IP: {params.ip_addresses[0]}")
print(f"Port așteptat: {params.ports[0]}")
print(f"Fișier test: {params.file_names[0]}")
print(f"Verificare permisiuni: {params.permissions_octal[0]}")

# Verifică determinismul
seed2 = generate_student_seed("ion.popescu@stud.ase.ro", "SEM03_HW", include_week=False)
params2 = randomise_test_parameters(seed2)
assert params.ip_addresses == params2.ip_addresses  # Întotdeauna True!
```

**Aplicație Anti-Plagiat:**

```python
# În autograder.py
def noteaza_student(submission_path: Path, student_id: str) -> dict:
    """Notează cu cazuri de test personalizate."""
    seed = generate_student_seed(student_id, "SEM04_HW")
    params = randomise_test_parameters(seed)
    
    results = {
        'student': student_id,
        'seed': seed,
        'teste': []
    }
    
    # Test 1: Configurare rețea
    expected_ip = params.ip_addresses[0]
    actual_ip = extrage_ip_din_lucrare(submission_path)
    results['teste'].append({
        'nume': 'Configurare IP',
        'asteptat': expected_ip,
        'actual': actual_ip,
        'trecut': actual_ip == expected_ip
    })
    
    # ... mai multe teste folosind params
    
    return results
```

---

## Testare

Directorul `lib/` include teste complete:

```bash
# Rulează toate testele lib
cd lib/
pytest -v test_*.py

# Cu raport de acoperire
pytest -v --cov=. --cov-report=term-missing test_*.py

# Output așteptat:
# test_logging_utils.py::TestSetupLogging::test_returns_logger_instance PASSED
# test_logging_utils.py::TestSetupLogging::test_logger_has_correct_name PASSED
# test_logging_utils.py::TestSetupLogging::test_no_duplicate_handlers PASSED
# test_randomisation_utils.py::TestGenerateStudentSeed::test_same_student_same_seed PASSED
# test_randomisation_utils.py::TestGenerateStudentSeed::test_different_students_different_seeds PASSED
# ...
# Acoperire: 85%+
```

---

## Integrare cu Seminariile

Fiecare seminar importă aceste utilități cu o cale relativă:

```python
# În SEM01/scripts/python/S01_01_autograder.py
import sys
from pathlib import Path

# Navighează la lib/ din locația scriptului curent
LIB_PATH = Path(__file__).resolve().parent.parent.parent.parent / 'lib'
sys.path.insert(0, str(LIB_PATH))

from logging_utils import setup_logging
from randomisation_utils import generate_student_seed, randomise_test_parameters

logger = setup_logging(__name__)
```

---

## Convenții de Limbă

- **Limba Engleză Britanică** în toate comentariile, docstring-urile și documentația
  - `colour` (nu color)
  - `behaviour` (nu behavior)
  - `normalise` (nu normalize)
  - `organisation` (nu organization)
  
- **Limba Engleză Americană** păstrată în referințele stdlib Python
  - `logging.WARNING` (constantă stdlib)
  - `logging.Formatter` (clasă stdlib)

---

## Istoric Modificări

### Versiunea 1.0 (Ianuarie 2025)
- Lansare inițială cu `logging_utils.py` și `randomisation_utils.py`
- Adăugată suită de teste completă
- Documentație cu exemple de utilizare

---

*Parte din Kit-ul Educațional ROso | Sisteme de Operare | ASE București — CSIE*
