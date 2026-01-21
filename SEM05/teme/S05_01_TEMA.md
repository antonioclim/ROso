# S05_01 - Temă: Advanced Bash Scripting

> Observație din laborator: notează-ţi comenzi‑cheie şi output‑ul relevant (2–3 linii) pe măsură ce lucrezi. Te ajută la debug şi, sincer, la final îţi iese şi un README bun fără efort suplimentar.
> Sisteme de Operare | ASE București - CSIE  
> Seminar 9-10: Advanced Bash Scripting
> Deadline: [Completați conform calendarului]

---

## Obiective

Această temă verifică înțelegerea și aplicarea conceptelor de:
- Funcții cu variabile locale și return values
- Arrays indexate și asociative
- Scripturi solide (set -euo pipefail, trap, error handling)
- Template profesional de scripting

---

## Cerințe

### Cerința 1: Log Analyzer (40%)

Creați scriptul `log_analyzer.sh` care analizează fișiere de log și generează statistici.

Specificații:

```bash
./log_analyzer.sh [opțiuni] <log_file>

Opțiuni:
  -h, --help          Afișează usage
  -v, --verbose       Mod verbose
  -l, --level LEVEL   Filtrează după nivel (INFO, WARN, ERROR)
  -o, --output FILE   Salvează rezultatul în fișier
  --top N             Afișează top N mesaje (default: 5)
```

Funcționalități obligatorii:

1. Parsare fișier log (formatul: `[TIMESTAMP] [LEVEL] Message`)
   - Extrage timestamp, level, și message
   - Folosește arrays asociative pentru contorizare

2. Statistici generate:
   - Număr total de linii
   - Distribuție pe nivele (INFO, WARN, ERROR, DEBUG)
   - Top N cele mai frecvente mesaje
   - Prima și ultima intrare din log

3. Funcții obligatorii (cu `local`):
   ```bash
   parse_line()     # Parsează o linie de log
   count_levels()   # Numără entrările pe nivel
   get_top_messages()  # Returnează top N mesaje
   print_report()   # Afișează raportul final
   ```

4. Stabilitate:
   - `set -euo pipefail`
   - Validare argumente și fișier input
   - Trap EXIT pentru cleanup

Format log de test:
```
[2025-01-15 10:00:00] [INFO] Application started
[2025-01-15 10:00:05] [DEBUG] Loading config from /etc/app.conf
[2025-01-15 10:00:10] [WARN] Config file not found, using defaults
[2025-01-15 10:00:15] [INFO] Server listening on port 8080
[2025-01-15 10:00:20] [ERROR] Connection refused to database
[2025-01-15 10:00:25] [INFO] Retry connection (attempt 1/3)
[2025-01-15 10:00:30] [INFO] Database connected
[2025-01-15 10:00:35] [INFO] Application started
```

Output așteptat:
```
═══════════════════════════════════════════
Log Analysis Report: sample.log
═══════════════════════════════════════════

Summary:
  Total entries: 8
  Time range: 2025-01-15 10:00:00 - 2025-01-15 10:00:35

Level Distribution:
  INFO:  5 (62.5%)
  DEBUG: 1 (12.5%)
  WARN:  1 (12.5%)
  ERROR: 1 (12.5%)

Top 5 Messages:
  1. "Application started" (2 occurrences)
  2. "Server listening on port 8080" (1)
  ...

═══════════════════════════════════════════
```

---

### Cerința 2: Config Manager (30%)

Creați scriptul `config_manager.sh` care gestionează fișiere de configurare key=value.

Specificații:

```bash
./config_manager.sh <command> [args]

Commands:
  get <key>           Obține valoarea unei chei
  set <key> <value>   Setează o valoare
  delete <key>        Șterge o cheie
  list                Listează toate cheile
  validate            Verifică configurația
  export              Exportă ca environment variables
```

Funcționalități obligatorii:

1. Parsare fișier configurare:

- Ignoră comentarii (linii care încep cu `#`)
- Ignoră linii goale
- Suportă `key=value` și `key = value`


2. Array asociativ pentru stocare:
   ```bash
   declare -A CONFIG
   ```

3. Validare:
   - Verifică chei obligatorii (definite într-un array)
   - Verifică format valori (ex: PORT să fie număr)

4. Funcții obligatorii:
   ```bash
   load_config()    # Încarcă fișierul în array
   save_config()    # Salvează array-ul în fișier
   get_value()      # Returnează valoarea unei chei
   set_value()      # Setează o valoare
   validate_config() # Verifică configurația
   ```

Exemplu fișier configurare:
```bash
# Application Configuration
HOST=localhost
PORT=8080
DEBUG=false

# Database
DB_HOST=db.example.com
DB_PORT=5432
DB_NAME=production
```

---

### Cerința 3: Refactoring Challenge (30%)

Primiți scriptul `broken_script.sh` (vezi mai jos) care funcționează dar are multe probleme de stil și stabilitate. Trebuie să-l refactorizați complet.

Script original (`broken_script.sh`):

```bash
#!/bin/bash
# Script cu multe probleme

files=()
for f in $*; do
    files+=($f)
done

count=0
process() {
    for file in ${files[@]}; do
        count=$((count + 1))
        result=$(cat $file | wc -l)
        echo "File $file has $result lines"
    done
}

config[name]="test"
config[value]="123"

process

echo "Processed $count files"
echo "Config: ${config[name]}"
```

Probleme de identificat și corectat:

| # | Problemă | Linie |
|---|----------|-------|
| 1 | Lipsește `set -euo pipefail` | - |
| 2 | `$*` în loc de `"$@"` | 5 |
| 3 | `${files[@]}` fără ghilimele | 11 |
| 4 | Variabilă globală în funcție (`count`) | 12 |
| 5 | `$file` fără ghilimele | 13 |
| 6 | UUOC (useless use of cat) | 13 |
| 7 | Array asociativ fără `declare -A` | 17-18 |
| 8 | Lipsește validare input | - |
| 9 | Lipsește usage/help | - |
| 10 | Lipsește cleanup/trap | - |

Cerințe pentru refactoring:

1. Aplicați template-ul profesional complet
2. Corectați TOATE problemele din tabel
3. Adăugați:
   - Funcție `usage()`
   - Parsare argumente (`-h`, `-v`, etc.)
   - Validare fișiere de input
   - Logging pentru operații
   - Trap EXIT pentru cleanup

---

## Punctaj

| Cerință | Puncte | Criterii |
|---------|--------|----------|
| Log Analyzer | 40 | Funcționalitate completă, stil corect |
| Config Manager | 30 | Toate comenzile implementate |
| Refactoring | 30 | Toate problemele corectate |
| TOTAL | 100 | |

### Criterii de evaluare:

Stil și stabilitate (penalizări):
- Lipsă `set -euo pipefail`: -5%
- Variabile non-locale în funcții: -3% per instanță
- Arrays fără ghilimele în for: -3% per instanță
- Lipsă `declare -A` pentru asociative: -5%
- Lipsă validare argumente: -3%
- Shellcheck warnings/errors: -1 punct per issue

Bonus (până la +10%):
- Cod foarte curat și documentat: +5
- Funcționalități extra utile: +5
- Unit tests pentru funcții: +5 (max +10 total)

---

## Structura Submisiei

```
tema_S05_NumePrenume/
├── README.md              # Explicații și instrucțiuni de rulare
├── log_analyzer.sh        # Cerința 1
├── config_manager.sh      # Cerința 2
├── refactored_script.sh   # Cerința 3
├── test_files/            # Fișiere de test (opțional)
│   ├── sample.log
│   └── app.conf
└── screenshots/           # Capturi cu output-ul (opțional)
```

---

## Cum să Testezi

### Test Log Analyzer:
```bash
# Creează fișier de test
cat > test.log << 'EOF'
[2025-01-15 10:00:00] [INFO] App started
[2025-01-15 10:00:01] [ERROR] Connection failed
[2025-01-15 10:00:02] [INFO] App started
[2025-01-15 10:00:03] [WARN] High memory
EOF

# Rulează analiza
./log_analyzer.sh test.log
./log_analyzer.sh -l ERROR test.log
./log_analyzer.sh --top 3 test.log
```

### Test Config Manager:
```bash
# Creează config de test
cat > test.conf << 'EOF'
HOST=localhost
PORT=8080
EOF

# Testează comenzile
./config_manager.sh list
./config_manager.sh get HOST
./config_manager.sh set DEBUG true
./config_manager.sh validate
```

### Validare cu Shellcheck:
```bash
shellcheck log_analyzer.sh
shellcheck config_manager.sh
shellcheck refactored_script.sh
```

---

## Resurse

- Material teoretic: `docs/S05_02_MATERIAL_PRINCIPAL.md`
- Template profesional: `scripts/templates/professional_script.sh`
- Demo arrays: `scripts/demo/S05_03_demo_arrays.sh`
- Demo stabilitate: `scripts/demo/S05_04_demo_robust.sh`
- Validator: `scripts/bash/S05_03_validator.sh`

---

## Reguli Importante

1. Plagiat: Codul trebuie să fie propriu. Copierea de la colegi = 0%.
2. AI Tools: Dacă folosiți ChatGPT/Claude/Copilot, menționați în README ce părți.
3. Deadline: Întârzierile se penalizează cu 10%/zi.
4. Shellcheck: Scripturile trebuie să treacă shellcheck fără erori.

---

## Întrebări Frecvente

Q: Pot folosi biblioteci externe (jq, yq)?
A: Da, dar menționează-le în README și verifică să fie disponibile.

Q: Ce versiune de Bash?
A: Bash 4.0+ (pentru arrays asociative și alte features moderne).

Q: Cum verific versiunea?
A: `bash --version` sau `echo $BASH_VERSION`

Q: Pot adăuga funcționalități extra?
A: Da! Funcționalitățile extra bine implementate pot primi bonus.

---

*Material pentru cursul de Sisteme de Operare | ASE București - CSIE*
