# SUMAR EXECUTIV: Sistem Evaluare Automată Proiecte SO

## Document de Sinteză | Versiune Finală

---

## 1. Capacitate Evaluare Automată - Sinteză

### 1.1 Procentaje Globale

| Nivel | Proiecte | Auto Evaluabil | Necesită Manual | Timp Evaluare |
|-------|----------|----------------|-----------------|---------------|
| **EASY** | E01-E05 | **90-95%** | 5-10% | 3-5 min |
| **MEDIUM** | M01-M15 | **80-90%** | 10-20% | 8-12 min |
| **ADVANCED** | A01-A03 | **75-85%** | 15-25% | 12-15 min |

### 1.2 Breakdown per Categorie de Teste

```
╔═══════════════════════════════════════════════════════════════════════════╗
║                    EVALUABILITATE PE CATEGORII                            ║
╠═══════════════════════════════════════════════════════════════════════════╣
║                                                                           ║
║  COMPLET AUTOMAT (100%):                                                  ║
║  ├── ✓ Structura fișierelor (există src/, README.md, etc.)               ║
║  ├── ✓ Sintaxă (bash -n, ShellCheck)                                     ║
║  ├── ✓ Exit codes                                                         ║
║  ├── ✓ Output conține string-uri așteptate                               ║
║  ├── ✓ Fișiere create/modificate corect                                  ║
║  ├── ✓ Timeout-uri respectate                                            ║
║  ├── ✓ Compilare C (pentru ADVANCED)                                     ║
║  └── ✓ Memory leaks (Valgrind)                                           ║
║                                                                           ║
║  PARȚIAL AUTOMAT (50-80%):                                                ║
║  ├── ◐ Calitate cod (metrici, nu semantică)                              ║
║  ├── ◐ Error handling (cazuri comune, nu toate)                          ║
║  ├── ◐ Logging (prezență și format, nu utilitate)                        ║
║  ├── ◐ Configurare (parsare, nu validare completă)                       ║
║  └── ◐ Performance (relative, nu absolute)                               ║
║                                                                           ║
║  MANUAL NECESAR (0-30%):                                                  ║
║  ├── ✗ Calitatea documentației (conținut, nu lungime)                    ║
║  ├── ✗ UX / Claritate output                                             ║
║  ├── ✗ Eleganță cod / Stil                                               ║
║  ├── ✗ Creativitate soluție                                              ║
║  ├── ✗ Edge cases rare/neașteptate                                       ║
║  └── ✗ Integrare cu sisteme externe reale                                ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝
```

---

## 2. Lista Completă: Criterii NEEVALUABILE Automat

### 2.1 Categorii Generale

| Categorie | Criterii Specifice | Motiv | Soluție Parțială |
|-----------|-------------------|-------|------------------|
| **Documentație** | Claritate, completitudine, utilitate | Necesită înțelegere semantică | Verificare lungime minimă |
| **UX/Output** | Lizibilitate, formatare, culori | Subiectiv, preferințe | Verificare ANSI codes prezente |
| **Calitate Cod** | Eleganță, stil, naming | Subiectiv | Metrici (LOC/funcție, comentarii) |
| **Creativitate** | Soluții inovative, extras | Nu poate fi cuantificat | Bonus manual |
| **Robustețe** | Edge cases rare | Imposibil de anticipat toate | Teste pentru cazuri comune |
| **Integrări** | Servicii externe, API-uri | Necesită infrastructură | Mock-uri |
| **Security** | Vulnerabilități subtile | Necesită audit expert | Verificări de bază |

### 2.2 Per Proiect - Lista Detaliată

#### EASY Projects
```
E01 - File System Auditor
  ✗ Claritatea raportului (5%)
  ✗ Calitatea README (2%)
  ✗ Eleganța codului (3%)

E02 - Log Analyzer  
  ✗ Formatare human-readable (5%)
  ✗ Suport formate nestandardizate (5%)

E03 - Bulk File Organizer
  ✗ Strategie conflicte (3%)
  ✗ Intuitivitatea organizării (2%)

E04 - System Health Reporter
  ✗ Lizibilitate output (10%)
  ✗ Relevanța informațiilor (5%)

E05 - Config File Manager
  ✗ Organizare backup storage (5%)
```

#### MEDIUM Projects
```
M01 - Incremental Backup
  ✗ Eficiență algoritm incremental (5%)
  ✗ Robustețe la întreruperi (3%)
  ✗ Calitate logging (2%)

M02 - Process Monitor
  ✗ Calitate dashboard UI (10%)
  ✗ Acuratețe măsurători (5%)

M03 - Service Watchdog
  ✗ Alertare email/Slack real (5%)
  ✗ Escalare inteligentă (3%)

M04 - Network Scanner
  ✗ Identificare servicii acurată (5%)
  ✗ Corelație vulnerabilități (5%)

M05 - Deployment Pipeline
  ✗ Integrare CI/CD real (5%)
  ✗ Blue-green complet (5%)

M06 - Resource Historian
  ✗ Calitate vizualizări (8%)
  ✗ Acuratețe predicții (5%)

M07 - Security Audit
  ✗ Relevanță recomandări (10%)
  ✗ False positive rate (5%)

M08 - Disk Manager
  ✗ Siguranță operații ștergere (5%)
  ✗ Predicție spațiu (5%)

M09 - Task Scheduler
  ✗ Validare cron complexe (3%)
  ✗ Integrare systemd real (5%)

M10 - Process Tree
  ✗ Detecție anomalii context real (5%)

M11 - Memory Forensics
  ✗ Detecție leak-uri reale (10%)
  ✗ Diferențiere leak vs normal (5%)

M12 - File Integrity
  ✗ False positives rate (5%)
  ✗ Performance la scală (5%)

M13 - Log Aggregator
  ✗ Parsare formate custom (5%)
  ✗ Corelări inteligente (5%)

M14 - Config Manager
  ✗ Securitate criptare (8%)
  ✗ Validare business logic (5%)

M15 - Parallel Engine
  ✗ Race conditions (5%)
  ✗ Corectitudine sincronizare (5%)
```

#### ADVANCED Projects
```
A01 - Job Scheduler
  ✗ Corectitudine scheduling fair-share (10%)
  ✗ Calitate cod C (5%)
  ✗ Robustețe la crash (5%)

A02 - Shell Extension
  ✗ UX terminal real (15%)
  ✗ Estetică culori/temă (5%)
  ✗ Performance perceptibilă (5%)

A03 - File Sync
  ✗ Eficiență algoritm rsync (10%)
  ✗ Protocol network real (5%)
  ✗ Strategie conflicte (5%)
```

---

## 3. Arhitectura Recomandată

### 3.1 Componente Sistem

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         EVALUATOR AUTOMAT SO                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌───────────────┐     ┌───────────────┐     ┌───────────────┐             │
│  │   FRONTEND    │     │   BACKEND     │     │   WORKERS     │             │
│  │               │     │               │     │               │             │
│  │ • Upload ZIP  │────▶│ • Queue Jobs  │────▶│ • Docker      │             │
│  │ • View Report │◀────│ • Store       │◀────│   Sandbox     │             │
│  │ • Feedback    │     │   Results     │     │ • Run Tests   │             │
│  └───────────────┘     └───────────────┘     └───────────────┘             │
│         │                     │                     │                       │
│         │              ┌──────┴──────┐              │                       │
│         │              │  DATABASE   │              │                       │
│         │              │ • Students  │              │                       │
│         │              │ • Results   │              │                       │
│         │              │ • Metrics   │              │                       │
│         │              └─────────────┘              │                       │
│         │                                           │                       │
│  ┌──────┴───────────────────────────────────────────┴──────┐               │
│  │                    TEST DEFINITIONS                      │               │
│  │  • YAML configs per project                             │               │
│  │  • Expected outputs                                     │               │
│  │  • Scoring rules                                        │               │
│  └─────────────────────────────────────────────────────────┘               │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 3.2 Flow Evaluare

```
1. SUBMISSION (Student)
   │
   ├── Upload ZIP via web interface
   ├── Validare format (< 50MB, structură corectă)
   └── Assign to queue
   
2. INTAKE (Worker)
   │
   ├── Dezarhivare în container izolat
   ├── Detectare automată proiect (din README sau filename pattern)
   ├── Validare structură minimală
   └── Încărcare test suite corespunzător
   
3. STATIC ANALYSIS (2-3 min)
   │
   ├── ShellCheck (toate fișierele .sh)
   ├── bash -n (syntax check)
   ├── Metrici cod (LOC, funcții, comentarii)
   └── Structură directoare
   
4. RUNTIME TESTS (5-15 min)
   │
   ├── Build (pentru ADVANCED)
   ├── Unit tests (funcționalități izolate)
   ├── Integration tests (flow complet)
   ├── Error handling tests
   └── Performance tests (cu timeout)
   
5. SCORING (1 min)
   │
   ├── Agregare rezultate
   ├── Aplicare ponderi per categorie
   ├── Calcul penalizări/bonusuri
   └── Generare scor final
   
6. REPORT (instant)
   │
   ├── Generare raport detaliat (JSON + HTML)
   ├── Highlighting probleme
   ├── Sugestii îmbunătățire
   └── Comparație cu media clasei (opțional)
```

### 3.3 Docker Sandbox Specification

```dockerfile
# Dockerfile pentru evaluare
FROM ubuntu:24.04

# Tools pentru toate proiectele
RUN apt-get update && apt-get install -y \
    # Bash & Core
    bash coreutils findutils grep sed gawk \
    # Analysis
    shellcheck \
    # Networking (pentru M04)
    netcat-openbsd nmap iproute2 \
    # Database (pentru M06, M12)
    sqlite3 \
    # Filesystem monitoring (pentru M12)
    inotify-tools \
    # Compression (pentru M01)
    gzip bzip2 xz-utils \
    # JSON processing
    jq \
    # C Development (pentru ADVANCED)
    gcc make valgrind gdb \
    libreadline-dev libssl-dev \
    # Python (pentru teste helper)
    python3 python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Security: user neprivilegiat
RUN useradd -m -s /bin/bash evaluator
USER evaluator
WORKDIR /home/evaluator

# Limits
ENV TIMEOUT_DEFAULT=60
ENV TIMEOUT_MAX=300
ENV MAX_MEMORY="512m"
ENV MAX_PIDS=100
```

---

## 4. Recomandări Implementare

### 4.1 Prioritizare Development

```
FAZA 1 (MVP - 2-3 săptămâni):
├── Infrastructure: Docker sandbox, job queue
├── Static analysis: ShellCheck, structură
├── Basic functional tests: EASY projects
└── Simple reporting: pass/fail + scor

FAZA 2 (Complete - 2-3 săptămâni):
├── Full test suites: MEDIUM projects
├── Advanced tests: C compilation, Valgrind
├── Detailed reporting: per-category breakdown
└── Web interface basic

FAZA 3 (Polish - 1-2 săptămâni):
├── Performance optimization
├── Plagiarism detection (MOSS integration)
├── Statistics & analytics
└── Manual review interface
```

### 4.2 Test Maintenance

```yaml
test_maintenance_guidelines:
  versioning:
    - Fiecare test suite versionat
    - Changelog pentru modificări
    - Backward compatibility 2 versiuni
    
  updates:
    trigger_new_tests:
      - Bug în test existent
      - Cerință nouă în proiect
      - Edge case descoperit
      
  deprecation:
    - Anunț 2 săptămâni înainte
    - Grace period pentru resubmit
```

### 4.3 Handling Edge Cases

```
PROBLEME COMUNE ȘI SOLUȚII:

1. Script-ul are shebang diferit (#!/usr/bin/env bash)
   → Acceptăm ambele variante
   
2. Nume fișier principal diferit
   → Detectare automată sau fail cu mesaj clar
   
3. Dependențe externe neinstalate
   → Pre-instalare în container SAU skip test cu notificare
   
4. Infinite loop în script student
   → Timeout strict per test (60s default)
   
5. Fork bomb
   → PID limit în container (--pids-limit=100)
   
6. Disk fill
   → Quota per container (1GB)
   
7. Network abuse
   → Network isolation (doar localhost)
```

---

## 5. Model de Scoring Recomandat

### 5.1 Formula

```
SCOR_FINAL = (SCOR_AUTO × 0.85) + (SCOR_MANUAL × 0.15)

Unde:
SCOR_AUTO = Σ(categorie_i × pondere_i) - penalizări + bonusuri

Categorii și ponderi default:
├── Structural:        10%
├── Static Analysis:   10%
├── Functional Core:   40%
├── Functional Opt:    15%
├── Error Handling:    10%
├── Performance:        5%
├── Code Quality:       5%
└── Documentation:      5%

Penalizări:
├── ShellCheck errors:     -2% per eroare (max -15%)
├── Timeout exceeded:      -50% pentru acel test
├── Crash/Segfault:        -100% pentru acel test

Bonusuri:
├── All tests pass:        +3%
├── Zero warnings:         +2%
├── Kubernetes extension:  +10%
```

### 5.2 Mapping la Note

```
Score    Notă    Descriere
─────────────────────────────────────
95-100   10      Excepțional
90-94    9       Foarte bine
80-89    8       Bine
70-79    7       Satisfăcător
60-69    6       Suficient
50-59    5       Minim acceptabil
< 50     4       Insuficient
```

---

## 6. Concluzii

### Ce funcționează bine automat:
- Verificări de structură și sintaxă
- Teste funcționale cu input/output definit
- Compilare și link (C)
- Memory safety (Valgrind)
- Performance (timeout-uri)

### Ce necesită evaluare umană:
- Calitatea documentației
- UX și claritate output
- Creativitate și eleganță
- Edge cases neașteptate
- Integrări cu sisteme reale

### Recomandare finală:
**Model hibrid 85% automat + 15% manual** oferă:
- Feedback rapid (sub 15 minute)
- Consistență în evaluare
- Scalabilitate pentru clase mari
- Flexibilitate pentru aspecte subiective

---

*Document generat pentru cursul Sisteme de Operare | ASE-CSIE | 2024-2025*
