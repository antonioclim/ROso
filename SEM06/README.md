# Seminar 6: CAPSTONE - Proiecte Integrate Bash

> **⚠️ NOTĂ IMPORTANTĂ**: Acest seminar are o structură diferită față de SEM01-SEM05!  
> SEM06 este un CAPSTONE - proiect integrator care sintetizează toate cunoștințele acumulate.

## Sisteme de Operare | Seminar 6 (Finalizare)
### ASE București - CSIE | 2025-2026

---

## De Ce Este Diferit SEM06?

| Aspect | SEM01-SEM05 | SEM06 (CAPSTONE) |
|--------|-------------|------------------|
| Focus | Concepte individuale | Integrare completă |
| Structură | docs/ cu 11 fișiere standard | docs/ cu 11 fișiere specializate |
| Scripturi | Demo-uri simple | 3 Proiecte Complete (~7500 linii) |
| Evaluare | Exerciții punctuale | Proiect de semestru |
| Complexitate | Progresivă | Profesională |

### Ce Vei Învăța

Acest CAPSTONE consolidează TOATE conceptele din seminariile anterioare:

```
SEM01: Shell basics     ─┐
SEM02: Pipes, Bucle     ─┤
SEM03: Find, Permisiuni ─┼──► SEM06: CAPSTONE
SEM04: Regex, AWK, SED  ─┤    3 Proiecte Profesionale
SEM05: Funcții, Arrays  ─┘
```

---

## Cuprins

- [Structura CAPSTONE](#-structura-capstone)
- [Proiecte Principale](#-proiecte-principale)
- [Documentație](#-documentație)
- [Prezentări](#-prezentări)
- [Instalare și Utilizare](#-instalare-și-utilizare)
- [Teme Practice](#-teme-practice)
- [Resurse](#-resurse)

---

## Structura CAPSTONE

```
SEM06/
├── 📄 README.md                    # Acest fișier
│
├── 📂 docs/                        # Documentație completă (~420K)
│   ├── S06_P00_Introduction_CAPSTONE.md    # Overview și obiective
│   ├── S06_P01_Project_Architecture.md # Design patterns, modularizare
│   ├── S06_P02_Monitor_Implementation.md    # Proiect Monitor detaliat
│   ├── S06_P03_Backup_Implementation.md     # Proiect Backup detaliat
│   ├── S06_P04_Deployer_Implementation.md   # Proiect Deployer detaliat
│   ├── S06_P05_Testing_Framework.md       # Framework testare Bash
│   ├── S06_P06_Error_Handling.md          # Trap, logging, exit codes
│   ├── S06_P07_Deployment_Strategies.md   # Rolling, Blue-Green, Canary
│   ├── S06_P08_Cron_Automation.md       # Cron și systemd timers
│   ├── S06_09_VISUAL_CHEAT_SHEET.md         # Quick reference
│   └── S06_10_SELF_ASSESSMENT_REFLECTION.md            # Checklist și reflecție
│
├── 📂 presentations/                  # Prezentări HTML (Reveal.js)
│   ├── S06_00_Introduction.html
│   ├── S06_02_Monitor.html
│   ├── S06_03_Backup.html
│   ├── S06_04_Deployer.html
│   └── S06_05_Testing_ErrorHandling.html
│
├── 📂 scripts/                     # Cod sursă (~680K)
│   │
│   ├── 📂 projects/                # ⭐ CELE 3 PROIECTE CAPSTONE
│   │   ├── monitor/                # 🖥️ System Monitor
│   │   │   ├── monitor.sh          #    Entry point
│   │   │   ├── bin/sysmonitor      #    Symlink executabil
│   │   │   ├── etc/monitor.conf    #    Configurare
│   │   │   ├── lib/                #    Biblioteci (core, config, utils)
│   │   │   ├── tests/              #    Suite de teste
│   │   │   └── var/log/, var/run/  #    Runtime dirs
│   │   │
│   │   ├── backup/                 # 💾 Backup System
│   │   │   ├── backup.sh           #    Entry point
│   │   │   ├── bin/sysbackup       #    Symlink executabil
│   │   │   ├── etc/backup.conf     #    Configurare
│   │   │   ├── lib/                #    Biblioteci
│   │   │   ├── tests/              #    Suite de teste
│   │   │   └── var/                #    Runtime dirs
│   │   │
│   │   └── deployer/               # 🚀 Deployment Pipeline
│   │       ├── deployer.sh         #    Entry point
│   │       ├── bin/sysdeploy       #    Symlink executabil
│   │       ├── etc/deployer.conf   #    Configurare
│   │       ├── hooks/              #    Pre/post deploy hooks
│   │       ├── lib/                #    Biblioteci
│   │       ├── tests/              #    Suite de teste
│   │       └── var/                #    Runtime dirs
│   │
│   ├── demo_monitor.sh             # Demo interactiv Monitor
│   ├── demo_backup.sh              # Demo interactiv Backup
│   ├── demo_deployer.sh            # Demo interactiv Deployer
│   │
│   ├── install.sh                  # Instalare kit
│   ├── uninstall.sh                # Dezinstalare kit
│   ├── check_dependencies.sh       # Verificare dependențe
│   ├── generate_configs.sh         # Generator configurații
│   ├── test_runner.sh              # Framework testare
│   └── test_helpers.sh             # Funcții helper teste
│
├── 📂 homework/                        # Teme practice
│   ├── TEME_PRACTICE.md            # 4 teme cu cerințe complete
│   └── OLD_HW/                     # Exerciții anterioare (referință)
│
└── 📂 resources/                     # Resurse suplimentare
    ├── README.md                   # Index resurse
    ├── examples/                   # Exemple cron
    ├── systemd/                    # Fișiere service/timer
    └── templates/                  # Template-uri script
```

### Statistici

| Component | Dimensiune | Fișiere |
|-----------|------------|---------|
| Proiecte CAPSTONE | ~456K | 15+ scripturi |
| Demo Scripts | ~77K | 3 scripturi |
| Utilitare | ~100K | 6 scripturi |
| Documentație | ~420K | 11 documente |
| Prezentări HTML | ~125K | 5 prezentări |
| Resurse | ~37K | 10+ fișiere |
| TOTAL | ~1.4MB | 50+ |

---

## Proiecte Principale

### 1. Monitor - System Monitoring

Monitorizare în timp real a resurselor sistem cu alerting.

Concepte Integrate:
- Parsing `/proc` (SEM02-03: pipes, awk)
- Funcții și arrays (SEM05)
- Error handling (SEM05)
- Output formatting (SEM04: printf, sed)

Capabilități:
- CPU usage (total și per-core) din `/proc/stat`
- Memory monitoring din `/proc/meminfo`
- Disk usage și I/O stats
- Process monitoring (top consumers)
- Alerting cu threshold-uri configurabile
- Output: text, JSON, CSV, Prometheus

```bash
# Exemple utilizare
./scripts/projects/monitor/monitor.sh --all
./scripts/projects/monitor/monitor.sh --cpu --format=json
./scripts/projects/monitor/monitor.sh --continuous --interval=5
```

---

### 2. Backup - Automated Backup System

Sistem complet de backup cu suport incremental și compresie.

Concepte Integrate:
- Find și xargs (SEM03)
- Compresie și arhivare (tar, gzip)
- Verificare integritate (checksums)
- Cron scheduling (SEM03)
- Logging profesional (SEM05)

Capabilități:
- Backup full și incremental
- Compresie: gzip, bzip2, xz, zstd
- Verificare integritate cu checksums
- Rotație automată (daily, weekly, monthly)
- Restore cu verificare
- Logging detaliat

```bash
# Exemple utilizare
./scripts/projects/backup/backup.sh create --source=/var/www --type=full
./scripts/projects/backup/backup.sh create --source=/var/www --type=incremental
./scripts/projects/backup/backup.sh list
./scripts/projects/backup/backup.sh restore --id=backup_20240115_143022
```

---

### 3. Deployer - Automated Deployment

Deployment automatizat cu multiple strategii și rollback.

Concepte Integrate:
- Toate conceptele anterioare
- Pattern-uri de deployment profesionale
- Health checks și monitoring
- Rollback și recovery

Capabilități:
- Strategii: Rolling, Blue-Green, Canary
- Health checks: HTTP, TCP, Process
- Hooks system: pre/post deploy, on failure
- Rollback automat sau manual
- Release management cu manifest

```bash
# Exemple utilizare
./scripts/projects/deployer/deployer.sh deploy --app=myapp --version=2.1.0 --strategy=rolling
./scripts/projects/deployer/deployer.sh deploy --app=api --strategy=blue-green
./scripts/projects/deployer/deployer.sh rollback --app=myapp
./scripts/projects/deployer/deployer.sh status --app=myapp
```

---

## Documentație

### Documente Disponibile

| # | Document | Descriere | Focus |
|---|----------|-----------|-------|
| 00 | `S06_P00_Introduction_CAPSTONE.md` | Overview, obiective, arhitectură | Conceptual |
| 01 | `S06_P01_Project_Architecture.md` | Design patterns, modularizare | Arhitectură |
| 02 | `S06_P02_Monitor_Implementation.md` | Parsing /proc, metrici, alerting | Implementare |
| 03 | `S06_P03_Backup_Implementation.md` | Full/incremental, compresie | Implementare |
| 04 | `S06_P04_Deployer_Implementation.md` | Strategii deployment, health checks | Implementare |
| 05 | `S06_P05_Testing_Framework.md` | Assertions, mocking, TDD | Testing |
| 06 | `S06_P06_Error_Handling.md` | Exit codes, traps, logging | Stabilitate |
| 07 | `S06_P07_Deployment_Strategies.md` | Rolling vs Blue-Green vs Canary | Teorie |
| 08 | `S06_P08_Cron_Automation.md` | Cron, systemd timers | Automatizare |
| 09 | `S06_09_VISUAL_CHEAT_SHEET.md` | Quick reference complet | Referință |
| 10 | `S06_10_SELF_ASSESSMENT_REFLECTION.md` | Checklist și reflecție | Evaluare |

---

## Prezentări

Prezentări HTML interactive folosind Reveal.js.

### Deschidere

```bash
# Direct în browser
firefox presentations/S06_00_Introduction.html

# Sau cu server local
cd prezentari && python3 -m http.server 8000
# Apoi http://localhost:8000
```

### Navigare Reveal.js

| Tastă | Acțiune |
|-------|---------|
| `→` / `Space` | Slide următor |
| `←` | Slide anterior |
| `Esc` | Overview toate slides |
| `F` | Fullscreen |
| `S` | Speaker notes |
| `?` | Help shortcuts |

---

## Instalare și Utilizare

### Cerințe Sistem

- OS: Linux (Ubuntu 20.04+, Debian 11+, sau compatibil)
- **Bash**: versiunea 4.0+
- Dependențe: `tar`, `gzip`, `curl`, `nc` (netcat)

### Instalare

```bash
# 1. Verificare dependențe
./scripts/check_dependencies.sh

# 2. Instalare (creează symlink-uri și configurații)
./scripts/install.sh

# 3. Generare configurații exemple
./scripts/generate_configs.sh
```

### Demo-uri Interactive

```bash
# Demo Monitor - monitorizare sistem live
./scripts/demo_monitor.sh

# Demo Backup - creare/restore backup-uri
./scripts/demo_backup.sh

# Demo Deployer - simulare deployment
./scripts/demo_deployer.sh
```

### Verificare Instalare

```bash
./scripts/projects/monitor/monitor.sh --help
./scripts/projects/backup/backup.sh --help
./scripts/projects/deployer/deployer.sh --help
```

---

## Teme Practice

Vezi `homework/TEME_PRACTICE.md` pentru detalii complete.

### Sumar

| Tema | Puncte | Termen | Complexitate |
|------|--------|--------|--------------|
| Tema 1: Monitor Extensions | 60p + 40p bonus | Săpt. 12 | ⭐⭐ |
| Tema 2: Backup Complet | 60p + 40p bonus | Săpt. 13 | ⭐⭐⭐ |
| Tema 3: Deployer Pipeline | 60p + 40p bonus | Săpt. 14 | ⭐⭐⭐⭐ |
| Tema 4: Proiect Integrat | 100p | Sesiune | ⭐⭐⭐⭐⭐ |

### Criterii Evaluare

- Funcționalitate: 40%
- Calitate cod: 25% (modularizare, naming, comments)
- Error handling: 15% (trap, validări, exit codes)
- Testing: 10% (unit tests, edge cases)
- Documentație: 10% (README, usage, examples)

---

## Testare

### Rulare Teste

```bash
# Toate testele
./scripts/test_runner.sh

# Doar teste pentru un proiect
./scripts/test_runner.sh scripts/projects/monitor/tests/
./scripts/test_runner.sh scripts/projects/backup/tests/

# Cu verbose logging
LOG_LEVEL=DEBUG ./scripts/test_runner.sh
```

### Framework Test (test_helpers.sh)

```bash
# Assertions disponibile
assert_equals "expected" "$actual" "message"
assert_not_equals "unexpected" "$actual" "message"
assert_true "$condition" "message"
assert_false "$condition" "message"
assert_file_exists "$path" "message"
assert_contains "$haystack" "$needle" "message"
```

---

## Resurse Suplimentare

### Fișiere Systemd

```bash
# Service pentru Monitor
resources/systemd/monitor.service

# Timer pentru Backup automatizat
resources/systemd/backup.timer
resources/systemd/backup.service
```

### Template-uri

```bash
# Template script profesional
resources/templates/bash_script_template.sh
```

### Exemple

```bash
# Exemple configurări cron
resources/examples/cron_examples.txt
```

---

## Note Tehnice

### Structură Diferită față de SEM01-05

Acest seminar NU urmează structura standard deoarece:

1. Focus pe proiecte complete - nu exerciții individuale
2. Cod de producție - nu demo-uri simple
3. Arhitectură modulară - lib/, etc/, var/, tests/
4. Testing integrat - fiecare proiect are suite de teste

### Directoare Nefolosite

Următoarele directoare există pentru compatibilitate dar sunt goale:
- `scripts/bash/` - logica e în `scripts/projects/*/lib/`
- `scripts/python/` - CAPSTONE e 100% Bash
- `scripts/demo/` - demo-urile sunt în `scripts/` root
- Documentează ce ai făcut pentru viitor

---

## Contact & Suport

- Consultații: După seminar sau prin email
- Forum: Platforma e-learning a facultății
- Issues: Raportați probleme pe repository

---

## Licență

Material educațional pentru uz didactic.  
© 2025-2026 ASE București - CSIE

---

*CAPSTONE = Culminating Academic Project with Synthesis, Testing, and Original New Engineering* 🎓

