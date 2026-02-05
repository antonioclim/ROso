# E01: Auditor Sistem de Fișiere

> **Nivel:** EASY | **Timp estimat:** 15-20 ore | **Componente:** Doar Bash

---

## Descriere

Dezvoltă un instrument care analizează și raportează starea unui sistem de fișiere. Script-ul va genera rapoarte detaliate despre utilizarea spațiului, tipurile de fișiere, permisiuni și probleme potențiale.

---

## Obiective de Învățare

- Folosirea comenzilor `find`, `du`, `stat`
- Procesare output cu `awk` și `sort`
- Generare rapoarte formatate
- Scripting Bash modular

---

## Cerințe Funcționale

### Obligatorii (pentru nota de trecere)

1. **Analiză spațiu disc**
   - Afișare utilizare pe director (top 10)
   - Identificare fișiere mari (> prag configurabil)
   - Spațiu total folosit vs disponibil

2. **Statistici tipuri fișiere**
   - Numărare fișiere pe extensie
   - Mărime totală pe tip
   - Fișiere fără extensie

3. **Audit permisiuni**
   - Identificare fișiere world-writable
   - Fișiere SUID/SGID
   - Directoare fără permisiuni citire

4. **Raport final**
   - Output text formatat
   - Opțiune export CSV
   - Timestamp și metadata

### Opționale (pentru punctaj complet)

5. **Fișiere duplicate** - identificare prin hash MD5/SHA
6. **Fișiere vechi** - neaccesate în ultimele N zile
7. **Link-uri simbolice rupte** - identificare și raportare
8. **Comparare în timp** - diff între două rulări

---

## Interfață

```bash
# Basic usage
./fs_auditor.sh /path/to/analyze

# With options
./fs_auditor.sh [OPTIONS] <directory>

Options:
  -h, --help           Display help
  -o, --output FILE    Save report to file
  -f, --format FORMAT  Output format: text|csv|json
  -t, --threshold SIZE Large files threshold (default: 100M)
  -d, --depth N        Maximum analysis depth (default: 5)
  -v, --verbose        Detailed output
  --no-color           Disable colours

Examples:
  ./fs_auditor.sh /home/user
  ./fs_auditor.sh -o report.txt -f csv /var/log
  ./fs_auditor.sh --threshold 50M --depth 3 /opt
```

---

## Exemple Output

### Output Text (implicit)

```
╔══════════════════════════════════════════════════════════════════╗
║              RAPORT AUDIT SISTEM FIȘIERE                         ║
║              Director: /home/student                             ║
║              Data: 2025-01-20 14:30:00                          ║
╚══════════════════════════════════════════════════════════════════╝

📊 REZUMAT UTILIZARE SPAȚIU
──────────────────────────────────────────────────────────────────
Total analizat:     15.2 GB
Număr fișiere:      12,453
Directoare:         1,234

📁 TOP 10 DIRECTOARE DUPĂ MĂRIME
──────────────────────────────────────────────────────────────────
  1.  4.2 GB   ./Downloads
  2.  3.1 GB   ./Documents/Projects
  3.  2.8 GB   ./.cache
  ···

📄 DISTRIBUȚIE TIPURI FIȘIERE
──────────────────────────────────────────────────────────────────
Extensie     Număr      Mărime     Procent
─────────────────────────────────────────────
.pdf         1,234      2.1 GB     13.8%
.jpg         3,456      1.8 GB     11.8%
.py          567        45 MB      0.3%
(fără ext)   234        123 MB     0.8%
···

⚠️  PROBLEME PERMISIUNI
──────────────────────────────────────────────────────────────────
Fișiere world-writable: 3
  - ./temp/shared.txt
  - ./public/upload.sh
  - ./data/config.ini

Fișiere SUID: 1
  - ./bin/special_tool

🔴 FIȘIERE MARI (>100MB)
──────────────────────────────────────────────────────────────────
  850 MB   ./Downloads/ubuntu-24.04.iso
  234 MB   ./Videos/presentation.mp4
  ···

══════════════════════════════════════════════════════════════════
Raport generat în 12.3 secunde
══════════════════════════════════════════════════════════════════
```

### Output CSV

```csv
type,path,size_bytes,permissions,modified
directory,/home/student/Downloads,4509715456,drwxr-xr-x,2025-01-15
file,/home/student/Downloads/ubuntu.iso,891289600,-rw-r--r--,2025-01-10
···
```

---

## Structură Recomandată

```
E01_File_System_Auditor/
├── README.md
├── Makefile
├── src/
│   ├── fs_auditor.sh          # Main script
│   └── lib/
│       ├── utils.sh           # Utility functions
│       ├── space_analyzer.sh  # Space analysis
│       ├── type_analyzer.sh   # Type analysis
│       ├── perm_checker.sh    # Permission checking
│       └── report_gen.sh      # Report generation
├── etc/
│   └── config.conf            # Default configuration
├── tests/
│   ├── test_space.sh
│   ├── test_types.sh
│   └── run_all_tests.sh
├── docs/
│   ├── INSTALL.md
│   └── USAGE.md
└── examples/
    └── sample_output.txt
```

---

## Indicii de Implementare

### Analiză spațiu

```bash
# Directory sizes
du -sh */ 2>/dev/null | sort -rh | head -10

# Large files
find . -type f -size +100M -exec ls -lh {} \;
```

### Statistici extensii

```bash
# Count per extension
find . -type f | sed 's/.*\.//' | sort | uniq -c | sort -rn
```

### Verificare permisiuni

```bash
# World-writable
find . -type f -perm -002

# SUID
find . -type f -perm -4000
```

---

## Criterii Specifice de Evaluare

| Criteriu | Pondere | Descriere |
|-----------|--------|-------------|
| Analiză spațiu corectă | 15% | Directoare top, fișiere mari |
| Statistici tipuri | 10% | Numărare și sumarizare |
| Audit permisiuni | 10% | Identificare probleme |
| Raport formatat | 5% | Output lizibil, profesional |
| Opțiuni CLI | 10% | getopts, validare input |
| Export CSV/JSON | 5% | Format corect |
| Funcționalități extra | 15% | Duplicate, fișiere vechi, symlinks |
| Calitate cod | 15% | Modularitate, comentarii |
| Teste | 10% | Acoperire funcționalitate |
| Documentație | 5% | README complet |

---

## Resurse

- `man find` - opțiuni avansate find
- `man du` - utilizare disc
- `man stat` - informații fișier
- Seminar 1-3 - comenzi de bază și scripting

---

*Proiect EASY | Sisteme de Operare | ASE-CSIE*
