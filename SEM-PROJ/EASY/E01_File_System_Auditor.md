# E01: File System Auditor

> **Nivel:** EASY | **Timp estimat:** 15-20 ore | **Componente:** Bash only

---

## Descriere

Dezvoltă un tool care analizează și raportează starea unui sistem de fișiere. Scriptul va genera rapoarte detaliate despre utilizarea spațiului, tipuri de fișiere, permisiuni și potențiale probleme.

---

## Obiective de Învățare

- Utilizarea comenzilor `find`, `du`, `stat`
- Procesare output cu `awk` și `sort`
- Generare rapoarte formatate
- Scripting Bash modular

---

## Cerințe Funcționale

### Obligatorii (pentru notă de trecere)

1. **Analiză spațiu disc**
   - Afișare utilizare per director (top 10)
   - Identificare fișiere mari (> threshold configurabil)
   - Total spațiu utilizat vs disponibil

2. **Statistici tipuri fișiere**

- Numărare fișiere per extensie
- Dimensiune totală per tip
- Fișiere fără extensie


3. **Audit permisiuni**
   - Identificare fișiere world-writable
   - Fișiere SUID/SGID
   - Directoare fără permisiuni de citire

4. **Raport final**
   - Output text formatat
   - Opțiune export CSV
   - Timestamp și metadata

### Opționale (pentru punctaj complet)

5. **Fișiere duplicate** - identificare după hash MD5/SHA
6. **Fișiere vechi** - neaccesate în ultimele N zile
7. **Simbolic links rupte** - identificare și raportare
8. **Comparație în timp** - diff între două rulări

---

## Interfață

```bash
# Utilizare de bază
./fs_auditor.sh /path/to/analyze

# Cu opțiuni
./fs_auditor.sh [OPȚIUNI] <director>

Opțiuni:
  -h, --help           Afișează ajutor
  -o, --output FILE    Salvează raport în fișier
  -f, --format FORMAT  Format output: text|csv|json
  -t, --threshold SIZE Threshold fișiere mari (default: 100M)
  -d, --depth N        Adâncime maximă analiză (default: 5)
  -v, --verbose        Output detaliat
  --no-color           Dezactivează culori

Exemple:
  ./fs_auditor.sh /home/user
  ./fs_auditor.sh -o raport.txt -f csv /var/log
  ./fs_auditor.sh --threshold 50M --depth 3 /opt
```

---

## Exemple Output

### Output Text (default)

```
╔══════════════════════════════════════════════════════════════════╗
║              FILE SYSTEM AUDIT REPORT                            ║
║              Directory: /home/student                            ║
║              Date: 2025-01-20 14:30:00                          ║
╚══════════════════════════════════════════════════════════════════╝

📊 SPACE USAGE SUMMARY
──────────────────────────────────────────────────────────────────
Total analyzed:     15.2 GB
Files count:        12,453
Directories:        1,234

📁 TOP 10 DIRECTORIES BY SIZE
──────────────────────────────────────────────────────────────────
  1.  4.2 GB   ./Downloads
  2.  3.1 GB   ./Documents/Projects
  3.  2.8 GB   ./.cache
  ...

📄 FILE TYPES DISTRIBUTION
──────────────────────────────────────────────────────────────────
Extension    Count      Size       Percentage
─────────────────────────────────────────────
.pdf         1,234      2.1 GB     13.8%
.jpg         3,456      1.8 GB     11.8%
.py          567        45 MB      0.3%
(no ext)     234        123 MB     0.8%
...

⚠️  PERMISSION ISSUES
──────────────────────────────────────────────────────────────────
World-writable files: 3
  - ./temp/shared.txt
  - ./public/upload.sh
  - ./data/config.ini

SUID files: 1
  - ./bin/special_tool

🔴 LARGE FILES (>100MB)
──────────────────────────────────────────────────────────────────
  850 MB   ./Downloads/ubuntu-24.04.iso
  234 MB   ./Videos/presentation.mp4
  ...

══════════════════════════════════════════════════════════════════
Report generated in 12.3 seconds
══════════════════════════════════════════════════════════════════
```

### Output CSV

```csv
type,path,size_bytes,permissions,modified
directory,/home/student/Downloads,4509715456,drwxr-xr-x,2025-01-15
file,/home/student/Downloads/ubuntu.iso,891289600,-rw-r--r--,2025-01-10
...
```

---

## Structura Recomandată

```
E01_File_System_Auditor/
├── README.md
├── Makefile
├── src/
│   ├── fs_auditor.sh          # Script principal
│   └── lib/
│       ├── utils.sh           # Funcții utilitare
│       ├── space_analyzer.sh  # Analiză spațiu
│       ├── type_analyzer.sh   # Analiză tipuri
│       ├── perm_checker.sh    # Verificare permisiuni
│       └── report_gen.sh      # Generare rapoarte
├── etc/
│   └── config.conf            # Configurare default
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

## Hints Implementare

### Analiză spațiu

```bash
# Dimensiune directoare
du -sh */ 2>/dev/null | sort -rh | head -10

# Fișiere mari
find . -type f -size +100M -exec ls -lh {} \;
```

### Statistici extensii

```bash
# Numărare per extensie
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

## Criterii Evaluare Specifice

| Criteriu | Pondere | Descriere |
|----------|---------|-----------|
| Analiză spațiu corectă | 15% | Top directoare, fișiere mari |
| Statistici tipuri | 10% | Contorizare și sumarizare |
| Audit permisiuni | 10% | Identificare probleme |
| Raport formatat | 5% | Output lizibil, profesional |
| Opțiuni CLI | 10% | getopts, validare input |
| Export CSV/JSON | 5% | Format corect |
| Funcționalități extra | 15% | Duplicate, vechi, symlinks |
| Calitate cod | 15% | Modularitate, comentarii |
| Teste | 10% | Acoperire funcționalități |
| Documentație | 5% | README complet |

---

## Resurse

- `man find` - opțiuni avansate find
- `man du` - disk usage
- `man stat` - informații fișiere
- SEM01-SEM03 - comenzi și scripting de bază

---

*Proiect EASY | Sisteme de Operare | ASE-CSIE*
