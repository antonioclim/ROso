# Teste - Seminar 06 (CAPSTONE)

> **⚠️ STRUCTURĂ SPECIALĂ:** SEM06 este seminar **CAPSTONE** cu proiecte integrate.  
> Testele sunt distribuite în directoarele proiectelor individuale.

---

## Locația Testelor

```
SEM06/
├── scripts/
│   ├── test_runner.sh          ← Runner global pentru toate proiectele
│   ├── test_helpers.sh         ← Funcții helper comune
│   └── projects/
│       ├── monitor/tests/
│       │   └── test_monitor.sh     ✅ Teste pentru System Monitor
│       ├── backup/tests/
│       │   └── test_backup.sh      ✅ Teste pentru Backup System
│       └── deployer/tests/
│           └── test_deployer.sh    ✅ Teste pentru Deployer
└── teste/
    └── README.md               ← Acest fișier (index)
```

---

## Rulare Teste

### Toate Testele (Recomandat)
```bash
cd SEM06/scripts
./test_runner.sh
```

### Per Proiect
```bash
# Monitor
cd SEM06/scripts/projects/monitor
./tests/test_monitor.sh

# Backup
cd SEM06/scripts/projects/backup
./tests/test_backup.sh

# Deployer
cd SEM06/scripts/projects/deployer
./tests/test_deployer.sh
```

---

## Ce Testează Fiecare Suită

### Monitor (`test_monitor.sh`)
| Test | Descriere |
|------|-----------|
| Colectare metrici | CPU, RAM, Disk, Network |
| Threshold alerting | Alerte la depășire praguri |
| Logging | Format și rotație |
| Daemon mode | Funcționare ca serviciu |

### Backup (`test_backup.sh`)
| Test | Descriere |
|------|-----------|
| Full backup | Backup complet |
| Incremental | Doar modificări |
| Compresie | gzip, tar |
| Restaurare | Recovery din arhivă |

### Deployer (`test_deployer.sh`)
| Test | Descriere |
|------|-----------|
| Deploy | Din repository/arhivă |
| Pre/Post hooks | Execuție scripts |
| Rollback | Revenire versiune anterioară |
| Health check | Validare deployment |

---

## Competențe Integrate Testate

| Proiect | Competențe SEM01-05 Aplicate |
|---------|------------------------------|
| Monitor | Variabile, Loops, Functions, Arrays |
| Backup | find/xargs, Compression, Error handling |
| Deployer | getopts, Processes, solid scripting |

---

## Notă Despre Structură

SEM06 nu are teste în acest director deoarece:
1. Este un seminar de **integrare** (CAPSTONE)
2. Testele sunt **colocate** cu codul proiectelor
3. Această abordare reflectă **practicile profesionale**

---

## Referințe

- `../docs/S06_05_Testing_Framework.md`
- `../scripts/test_helpers.sh`
- `../scripts/test_runner.sh`
