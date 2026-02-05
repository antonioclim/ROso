# Material principal — CAPSTONE SEM06

> **Sisteme de Operare** | ASE București - CSIE  
> Seminarul 6: Proiecte integrate (Monitor, Backup, Deployer)

---

## Despre acest document

CAPSTONE diferă de seminarele anterioare. În locul unui subiect liniar unic, construiți *sisteme*. Acest document este punctul principal de orientare.

> **Notă de laborator:** nu citiți totul înainte de a începe. Parcurgeți pe diagonală prezentarea arhitecturii, alegeți proiectul, apoi intrați în documentația specifică. Puteți reveni ulterior.

---

## 1. Prezentare generală a proiectelor

### 1.1 Cele trei proiecte

| Proiect | Ce face | Dificultate | Începeți aici |
|---------|--------------|------------|------------|
| **Monitor** | Metrici de sistem în timp real (CPU, memorie, disc) cu alerte | ⭐⭐⭐ | [Implementarea Monitor](projects/S06_P02_Monitor_Implementation.md) |
| **Backup** | Backup incremental cu compresie, verificare, rotație | ⭐⭐⭐ | [Implementarea Backup](projects/S06_P03_Backup_Implementation.md) |
| **Deployer** | Deployment automat cu rollback și health checks | ⭐⭐⭐⭐ | [Implementarea Deployer](projects/S06_P04_Deployer_Implementation.md) |
| **Integrat** | Toate trei funcționând împreună | ⭐⭐⭐⭐⭐ | Finalizați întâi proiectele individuale |

### 1.2 Ce proiect ar trebui să aleg?

**Alegeți Monitor dacă:**
- vreți să înțelegeți cum expune Linux informații despre sistem
- sunteți confortabil(ă) cu aritmetica în Bash
- vă atrage ideea de a construi un dashboard

**Alegeți Backup dacă:**
- vă interesează integritatea datelor
- vreți să învățați tar, compresie, checksums
- apreciați infrastructura „lipsită de glamour, dar critică”

**Alegeți Deployer dacă:**
- vă interesează DevOps/CI-CD
- vreți provocarea cea mai dificilă
- sunteți confortabil(ă) cu concepte de administrare a serviciilor

> **Intervenție rapidă:** dacă nu sunteți sigur(ă), începeți cu Monitor. Are cel mai rapid ciclu de feedback — vedeți imediat rezultatele.

---

## 2. Arhitectură comună

Toate cele trei proiecte folosesc o structură comună. O învățați o singură dată și o aplicați peste tot.

### 2.1 Structura directoarelor

```
project/
├── project.sh              # Entry point — this is what you run
├── lib/
│   ├── core.sh             # Logging, error handling, fundamentals
│   ├── config.sh           # Configuration loading and validation
│   └── utils.sh            # Project-specific helper functions
├── etc/
│   └── project.conf        # Configuration file
├── var/
│   ├── log/                # Log output goes here
│   └── run/                # PID files, lock files
└── tests/
    └── test_project.sh     # Your tests
```

### 2.2 De ce această structură?

Aceasta reflectă convenții Unix reale:
- `/etc` pentru configurație
- `/var` pentru date de rulare (runtime)
- `/lib` pentru cod partajat

Când veți deploya într-o zi pe un server real, această structură va fi familiară.

**Detalii complete de arhitectură:** [Arhitectura proiectelor](projects/S06_P01_Project_Architecture.md)

---

## 3. Concepte de bază

Acestea se aplică *tuturor* proiectelor. Stăpâniți-le înainte de a intra în detalii.

### 3.1 Tratarea erorilor

Scripturile voastre *vor* eșua. Întrebarea este: eșuează controlat?

> ⚠️ *Confesiune: la începutul perioadei mele de sysadmin, am scris un script de curățare fără `set -e` care a eșuat în tăcere la jumătate și a șters directorul greșit. Mi-a consumat un weekend. „Sfânta treime” de mai jos nu este negociabilă în scripturi de producție.*

```bash
set -euo pipefail  # The holy trinity

cleanup() {
    # Always runs, even on Ctrl+C
    rm -f "$TEMP_FILE"
}
trap cleanup EXIT
```

**Aprofundare:** [Tratarea erorilor](projects/S06_P06_Error_Handling.md)

### 3.2 Jurnalizare

`echo` nu este jurnalizare. Jurnalizarea are timestamp‑uri, niveluri și destinații.

```bash
log_info "Starting backup"
log_warn "Disk space below 10%"
log_error "Cannot connect to server"
```

**Aprofundare:** [Tratarea erorilor](projects/S06_P06_Error_Handling.md) (secțiunea de logging)

### 3.3 Testare

Dacă nu puteți testa, nu puteți avea încredere.

```bash
test_cpu_usage_returns_number() {
    local result
    result=$(get_cpu_usage)
    [[ "$result" =~ ^[0-9]+$ ]] || fail "Expected number, got: $result"
}
```

**Aprofundare:** [Cadrul de testare](projects/S06_P05_Testing_Framework.md)

---

## 4. Documentație specifică proiectelor

### 4.1 Introducere și context

- [Introducere CAPSTONE](projects/S06_P00_Introduction_CAPSTONE.md) — de ce facem acest lucru, ce veți învăța

### 4.2 Arhitectură

- [Arhitectura proiectelor](projects/S06_P01_Project_Architecture.md) — pattern‑uri comune, structură directoare, flux de execuție

### 4.3 Ghiduri de implementare

| Document | Acoperă |
|----------|--------|
| [Implementarea Monitor](projects/S06_P02_Monitor_Implementation.md) | parsare /proc, colectare metrici, alertare |
| [Implementarea Backup](projects/S06_P03_Backup_Implementation.md) | tar, find -newer, checksums, rotație |
| [Implementarea Deployer](projects/S06_P04_Deployer_Implementation.md) | strategii de deployment, health checks, rollback |

### 4.4 Aspecte transversale

| Document | Acoperă |
|----------|--------|
| [Cadrul de testare](projects/S06_P05_Testing_Framework.md) | teste unitare, teste de integrare, test runner |
| [Tratarea erorilor](projects/S06_P06_Error_Handling.md) | coduri de ieșire, traps, sistem de logging |
| [Strategii de deployment](projects/S06_P07_Deployment_Strategies.md) | pattern‑uri rolling, blue-green, canary |
| [Cron și automatizare](projects/S06_P08_Cron_Automation.md) | planificare cu cron, systemd timers |

---

## 5. Referință rapidă

### 5.1 Cheat Sheet

Referință de o pagină pentru pattern‑uri uzuale: [Bash Cheat Sheet](S06_09_VISUAL_CHEAT_SHEET.md)

### 5.2 Autoevaluare

Verificați înțelegerea: [Autoevaluare](S06_10_SELF_ASSESSMENT_REFLECTION.md)

---

## 6. Cod funcțional

Directorul `scripts/projects/` conține implementări funcționale:

```
scripts/projects/
├── monitor/
│   ├── monitor.sh
│   ├── lib/
│   └── tests/
├── backup/
│   ├── backup.sh
│   ├── lib/
│   └── tests/
└── deployer/
    ├── deployer.sh
    ├── lib/
    └── tests/
```

> **Avertisment:** nu copiați pur și simplu acest cod pentru temă. Scopul este să îl *înțelegeți*. Rubrica punctează explicația, nu doar execuția.

---

## 7. Parcurs de învățare sugerat

### Săptămâna 1: Fundament

1. Citiți [Arhitectura proiectelor](projects/S06_P01_Project_Architecture.md)
2. Rulați codul existent, stricați-l, reparați-l
3. Finalizați exercițiile de tip sprint 1–3
4. Porniți scheletul proiectului ales

### Săptămâna 2: Implementare

1. Citiți ghidul de implementare al proiectului
2. Implementați funcționalitatea de bază
3. Adăugați tratarea erorilor și jurnalizarea
4. Scrieți teste de bază

### Săptămâna 3: Finisare (individual)

1. Finalizați funcționalitățile bonus
2. Scrieți documentația
3. Pregătiți demo-ul pentru prezentare
4. Testați pe o mașină „curată”

---

## 8. Cum obțineți ajutor

**Blocaj?** Încercați în această ordine:

1. Re-citiți mesajul de eroare. Erorile Bash sunt criptice, dar informative.
2. Adăugați `set -x` pentru a vedea ce se execută.
3. Verificați cu ShellCheck: `shellcheck your_script.sh`
4. Căutați în man pages: `man bash`, `man find`, `man tar`
5. Întrebați un coleg (depanarea în perechi funcționează)
6. Întrebați instructorul (cu mesajul de eroare și ce ați încercat)

> **Notă de laborator:** „Nu merge” nu este o întrebare. „Mă așteptam la X, am obținut Y, iată codul” este o întrebare la care se poate răspunde.

---

*Index material principal pentru SEM06 CAPSTONE — Sisteme de Operare*  
*ASE București - CSIE | 2024-2025*
