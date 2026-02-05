# 📁 Scripturi Bash — SEM06

> **Locație:** `SEM06/scripts/bash/`  
> **Scop:** scripturi pentru auto‑setup, rulare quiz, scaffolding și lansator de demo‑uri

---

## Conținut

| Script | Scop | CLI |
|--------|---------|-----|
| `S06_01_setup_seminar.sh` | configurează mediul și verifică precondiții | `--check`, `--install` |
| `S06_02_quiz_runner.sh` | rulează quiz‑ul formativ în terminal | `--random`, `--limit` |
| `S06_03_project_scaffold.sh` | generează structura de bază a proiectului | `monitor`, `backup`, `deployer` |
| `S06_04_demo_launcher.sh` | pornește demo‑uri spectaculoase | `--demo` |
| `RUNhere.md` | instrucțiuni | — |

---

## 1) Setup rapid pentru seminar

### Script
`S06_01_setup_seminar.sh`

### Ce verifică
- Bash ≥ 4.0
- Comenzi: `curl`, `tar`, `sha256sum`, `systemctl`
- Spațiu liber pe disc
- Permisiuni corecte

### Rulare (doar verificare)

```bash
bash S06_01_setup_seminar.sh --check
```

### Rulare (instalare dependențe)

```bash
sudo bash S06_01_setup_seminar.sh --install
```

### Output așteptat

```
[OK] Bash version: 5.1
[OK] curl installed
[OK] tar installed
[OK] sha256sum installed
[WARN] systemctl not available (WSL detected)
[OK] Disk space: 12GB free
Setup completed.
```

---

## 2) Rulare quiz formativ în terminal

### Script
`S06_02_quiz_runner.sh`

### Rulare normală

```bash
bash S06_02_quiz_runner.sh formative/quiz.yaml
```

### Rulare aleatorie (10 întrebări)

```bash
bash S06_02_quiz_runner.sh formative/quiz.yaml --random --limit 10
```

### Funcționalități
- suport pentru multiple-choice
- scor automat
- feedback per întrebare
- mapare la LO pentru auto‑învățare

---

## 3) Scaffold pentru proiect

### Script
`S06_03_project_scaffold.sh`

### Exemplu: generare Monitor

```bash
bash S06_03_project_scaffold.sh monitor
```

### Structură generată

```
monitor/
├── monitor.sh
├── lib/
│   ├── core.sh
│   └── utils.sh
├── tests/
│   └── test_monitor.sh
└── README.md
```

---

## 4) Lansator de demo‑uri

### Script
`S06_04_demo_launcher.sh`

### Rulare demo backup

```bash
bash S06_04_demo_launcher.sh --demo backup
```

### Demo‑uri disponibile
- `monitor` — crash simulat + alertă
- `backup` — backup incremental + verificare
- `deployer` — deploy + rollback

---

## Loguri

Scripturile scriu loguri în:

- `setup.log`
- `quiz.log`
- `scaffold.log`
- `demo.log`

Puteți seta `LOGFILE` manual:

```bash
LOGFILE=custom.log bash S06_01_setup_seminar.sh --check
```

---

## Depanare

| Simptom | Cauză probabilă | Fix |
|--------|------------------|-----|
| `Permission denied` | script fără exec bit | `chmod +x script.sh` |
| `command not found` | PATH incomplet | rulați cu `bash script.sh` |
| output lipsă | redirect către log | verificați `.log` |

---

*Scripturi Bash pentru SEM06 CAPSTONE — Sisteme de Operare*  
*ASE București - CSIE | 2024-2025*
