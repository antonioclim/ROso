# CAPSTONE: Proiecte Integrate de Administrare Sisteme

> Observație din laborator: nu aștepta „finalul” ca să faci deploy. Un deployment urât, dar funcțional, în săptămâna 1–2 bate de obicei un deployment perfect încercat în ultima seară. Fă-l devreme și iterează.
## Sisteme de Operare - Seminarii 11-12

### Academia de Studii Economice București
### Facultatea CSIE - Cibernetică, Statistică și Informatică Economică

---

## 1. Contextul și Motivația Proiectului

Proiectul CAPSTONE reprezintă punctul culminant al disciplinei Sisteme de Operare, 
sintetizând competențele acumulate pe parcursul semestrului într-o experiență practică 
integrată. Spre deosebire de exercițiile izolate din seminariile anterioare, CAPSTONE 
solicită studenților să construiască sisteme software complete, funcționale în 
contexte reale de producție.

### 1.1 Problema Fundamentală

Administratorii de sisteme și inginerii DevOps se confruntă zilnic cu trei categorii 
esențiale de sarcini care, deși par distincte, partajează fundamente comune:

Monitorizarea resurselor - Înțelegerea stării curente a sistemului presupune 
interogarea continuă a subsistemelor kernel-ului Linux prin interfețele /proc și /sys, 
agregarea datelor într-o formă comprehensibilă și detectarea anomaliilor care necesită 
intervenție. Un sistem de monitorizare eficient trebuie să opereze cu overhead minim, 
să persiste date istorice pentru analiză și să declanșeze alerte când parametrii 
depășesc pragurile acceptabile.

Backup și recuperare - Protejarea datelor împotriva pierderii accidentale sau a 
corupției reprezintă o responsabilitate critică. Un sistem de backup solid trebuie 
să gestioneze compresie eficientă, verificare integritate prin sume de control, 
backup incremental pentru optimizarea spațiului și timpului, plus proceduri fiabile 
de restaurare testate regulat.

Deployment aplicații - Livrarea software-ului în producție solicită orchestrarea 
atentă a mai multor pași: oprirea serviciilor existente, copierea fișierelor noi, 
configurarea mediului, pornirea serviciilor și verificarea funcționalității. 
Strategiile moderne precum blue-green și canary deployment minimizează riscul 
downtime-ului și permit rollback rapid în caz de probleme.

### 1.2 De Ce Bash?

Alegerea Bash ca limbaj principal pentru CAPSTONE este deliberată și pedagogică:

Ubiquitate - Bash există pe virtual orice sistem Unix-like, de la servere 
enterprise la dispozitive embedded. Competențele dobândite sunt direct transferabile 
în orice mediu profesional.

Interacțiune directă cu sistemul - Spre deosebire de limbajele de nivel înalt 
care abstractizează sistemul de operare, Bash expune direct primitivele OS: procese, 
file descriptori, semnale, exit codes. Această transparență consolidează înțelegerea 
profundă a mecanismelor subiacente.

constrângeri instructive - Bash nu dispune de structuri de date sofisticate, 
management automat al memoriei sau biblioteci extensive. Aceste "lipsuri" forțează 
gândirea algoritmică explicită și aprecierea soluțiilor elegante în constrângeri.

Realism profesional - Scripturi Bash de complexitate similară există în producție 
la companii de toate dimensiunile. Experiența CAPSTONE pregătește studenții pentru 
cod real, nu doar exerciții academice.

---

## 2. Obiectivele de Învățare

Proiectul CAPSTONE vizează dezvoltarea competențelor pe multiple niveluri cognitive, 
urmărind progresia de la cunoaștere factuală la sinteză creativă.

### 2.1 Cunoaștere și Înțelegere

La finalizarea proiectului, studenții vor demonstra cunoașterea:

- Anatomiei sistemului de fișiere Linux - organizarea ierarhică, rolul 
  directoarelor standard (/proc, /sys, /etc, /var), distincția între fișiere 
  regulate, dispozitive și pseudo-fișiere
  
- Mecanismelor de comunicare inter-proces - pipe-uri, FIFO-uri, semnale 
  POSIX, variabile de mediu, file descriptori
  
- Ciclului de viață al proceselor - fork/exec, zombies, orphans, grupuri 
  de procese, sesiuni, demonizare
  
- Subsistemelor de monitorizare kernel - /proc/stat, /proc/meminfo, 
  /proc/diskstats, /sys/class, precum și utilitarele userspace asociate

### 2.2 Aplicare și Analiză

Studenții vor demonstra capacitatea de a:

- Proiecta arhitecturi modulare - descompunerea problemelor complexe în 
  componente reutilizabile cu interfețe clar definite
  
- Implementa error handling solid - anticiparea modurilor de eșec, 
  propagarea erorilor prin exit codes, logging structurat, cleanup la terminare
  
- Aplica principii DRY (Don't Repeat Yourself) - abstractizarea codului 
  comun în funcții și biblioteci partajate
  
- Analiza trade-off-uri - evaluarea compromisurilor între performanță, 
  complexitate, mentenabilitate și portabilitate

### 2.3 Sinteză și Evaluare

Nivelul avansat presupune:

- Integrarea componentelor - combinarea modulelor într-un sistem coerent 
  unde părțile colaborează fără fricțiuni
  
- Testarea sistematică - scrierea testelor unitare și de integrare, 
  automatizarea validării, interpretarea rezultatelor
  
- Evaluarea calității codului - aplicarea standardelor de stil, 
  identificarea code smells, refactorizarea pentru claritate
  
- Documentarea profesională - redactarea documentației tehnice care 
  servește atât utilizatorii cât și dezvoltatorii viitori

---

## 3. Arhitectura Generală

Cele trei proiecte CAPSTONE partajează o arhitectură comună care promovează 
consistența, reutilizarea codului și mentenabilitatea pe termen lung.

### 3.1 Structura de Directoare

```
project/
├── project.sh              # Script principal - punct de intrare
├── bin/
│   └── sysproject          # Wrapper pentru instalare în sistem
├── etc/
│   ├── project.conf        # Configurație principală
│   └── project.conf.example
├── lib/
│   ├── core/               # Funcționalitate centrală
│   │   ├── config.sh       # Încărcare și validare configurație
│   │   ├── engine.sh       # Logica principală de business
│   │   └── parser.sh       # Parsare argumente linie comandă
│   └── utils/              # Utilitare generale
│       ├── common.sh       # Funcții helper generale
│       ├── logging.sh      # Sistem de logging
│       └── validation.sh   # Validare input
├── var/
│   ├── log/                # Fișiere jurnal
│   ├── run/                # PID files, sockets
│   └── lib/                # Date persistente
└── tests/
    ├── unit/               # Teste unitare per modul
    ├── integration/        # Teste integrare componente
    └── fixtures/           # Date test
```

### 3.2 Principii Arhitecturale

Separarea responsabilităților - Fiecare modul are o singură responsabilitate 
clar definită. `logging.sh` gestionează exclusiv jurnalizarea, `config.sh` 
exclusiv configurația. Această separare facilitează testarea izolată și 
modificarea independentă.

Inversarea dependențelor - Modulele de nivel înalt nu depind de implementări 
concrete ci de abstracții. Scriptul principal apelează funcții cu nume 
semantice (`log_info`, `load_config`) fără a cunoaște detaliile implementării.

Configurație externalizată - Parametrii variabili sunt extrași în fișiere 
de configurație, nu hardcodați în scripturi. Aceasta permite ajustarea 
comportamentului fără modificarea codului sursă.

Fail-fast cu cleanup - Erorile sunt detectate cât mai devreme posibil, 
iar resursele alocate sunt eliberate garantat prin trap-uri EXIT.

### 3.3 Fluxul de Execuție Standard

```
┌─────────────────────────────────────────────────────────────┐
│                    INIȚIALIZARE                             │
├─────────────────────────────────────────────────────────────┤
│  1. Determinare cale absolută script                        │
│  2. Source biblioteci din lib/                              │
│  3. Setup trap-uri pentru cleanup                           │
│  4. Parsare argumente linie comandă                         │
│  5. Încărcare și validare configurație                      │
│  6. Inițializare logging                                    │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    VALIDARE                                 │
├─────────────────────────────────────────────────────────────┤
│  1. Verificare dependențe (comenzi externe)                 │
│  2. Verificare permisiuni (fișiere, directoare)             │
│  3. Validare parametri                                      │
│  4. Verificare condiții precursor                           │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    EXECUȚIE                                 │
├─────────────────────────────────────────────────────────────┤
│  1. Executare operație principală                           │
│  2. Logging progres și rezultate                            │
│  3. Gestionare erori intermediare                           │
│  4. Actualizare stare persistentă                           │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    FINALIZARE                               │
├─────────────────────────────────────────────────────────────┤
│  1. Sumarizare rezultate                                    │
│  2. Cleanup resurse temporare                               │
│  3. Exit cu cod corespunzător                               │
└─────────────────────────────────────────────────────────────┘
```

---

## 4. Prezentarea Proiectelor

### 4.1 System Monitor

Scopul: Colectarea și raportarea metricilor de performanță sistem în timp 
real, cu suport pentru alertare bazată pe praguri configurabile.

Funcționalități principale:
- Monitorizare CPU (utilizare per core, load average, procese)
- Monitorizare memorie (RAM, swap, cache, buffere)
- Monitorizare disk (spațiu, I/O, latențe)
- Monitorizare rețea (throughput, conexiuni, erori)
- Mod daemon cu interval configurabil
- Alertare prin diverse canale (log, email, webhook)
- Export date în formate multiple (text, JSON, CSV)

Concepte cheie: parsing /proc, arithmetic floating-point în Bash, 
threshold detection, daemon mode, signal handling.

### 4.2 Backup System

Scopul: Automatizarea backup-urilor cu suport pentru compresie, 
verificare integritate, backup incremental și restaurare selectivă.

Funcționalități principale:
- Backup complet și incremental
- Compresie multiplă (gzip, bzip2, xz, zstd)
- Verificare integritate (MD5, SHA-1, SHA-256)
- Excludere pattern-uri configurabile
- Rotație automată (păstrare N backup-uri)
- Restaurare completă sau selectivă
- Raportare statistici (dimensiune, durată, rate)

Concepte cheie: tar archives, compression algorithms, checksums, 
incremental backup via find, file pattern matching, rotation policies.

### 4.3 Application Deployer

Scopul: Orchestrarea deployment-ului aplicațiilor cu suport pentru 
strategii avansate și rollback automat.

Funcționalități principale:
- Deployment simplu și scripted
- Strategii avansate (blue-green, canary, rolling)
- Health checks configurabile (HTTP, TCP, process, command)
- Rollback automat la eșec
- Sistem de hooks (pre/post deploy, on error)
- Manifest YAML pentru configurare declarativă
- Gestionare versiuni și istoric

Concepte cheie: deployment strategies, health checking, service 
management, process signals, atomic operations, state management.

---

## 5. Relația dintre Proiecte

Cele trei proiecte nu sunt izolate ci formează un ecosistem integrat:

```
┌─────────────────────────────────────────────────────────────────────┐
│                         INFRASTRUCTURĂ                              │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐             │
│  │   MONITOR   │    │   BACKUP    │    │  DEPLOYER   │             │
│  └──────┬──────┘    └──────┬──────┘    └──────┬──────┘             │
│         │                  │                  │                     │
│         └──────────────────┼──────────────────┘                     │
│                            │                                        │
│                   ┌────────┴────────┐                               │
│                   │  BIBLIOTECI     │                               │
│                   │   PARTAJATE     │                               │
│                   │                 │                               │
│                   │  • logging.sh   │                               │
│                   │  • common.sh    │                               │
│                   │  • validation.sh│                               │
│                   └─────────────────┘                               │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    FRAMEWORK TESTARE                         │   │
│  │         test_runner.sh  •  test_helpers.sh                   │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    UTILITARE SISTEM                          │   │
│  │  install.sh • uninstall.sh • check_dependencies.sh           │   │
│  │  generate_configs.sh                                         │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

Scenarii de integrare:

1. Monitor + Deployer: Monitorul verifică sănătatea sistemului înainte și 
   după deployment, declanșând rollback dacă metricile degradează.

2. Backup + Deployer: Backup automat al configurației înainte de deploy, 
   cu restaurare la rollback.

3. Monitor + Backup: Alertare când spațiul de backup scade, monitorizare 
   durată și succes backup-uri.

---

## 6. Metodologia de Lucru

### 6.1 Abordare Incrementală

Proiectele sunt concepute pentru dezvoltare incrementală:

Faza 1 - Prototip funcțional (săptămâna 11)
- Implementare funcționalitate de bază
- Structură de directoare și fișiere
- Primele teste

Faza 2 - Consolidare (săptămâna 12)  
- Error handling complet
- Logging și configurație
- teste complete

Faza 3 - Rafinare (individual)
- Optimizări performanță
- Documentație
- Funcționalități avansate

### 6.2 Testare Continuă

Framework-ul de testare integrat permite verificarea progresului:

```bash
# Rulare toate testele pentru un proiect
./test_runner.sh --project monitor

# Rulare doar teste unitare
./test_runner.sh --project backup --type unit

# Rulare cu output verbose
./test_runner.sh --project deployer --verbose
```

### 6.3 Versionare și Colaborare

Deși nu este obligatoriu pentru seminar, se recomandă utilizarea Git:

```bash
# Inițializare repository
cd SEM11-12_COMPLET
git init
git add .
git commit -m "Initial CAPSTONE structure"

# După fiecare funcționalitate completă
git add -p  # review changes
git commit -m "feat(monitor): add CPU monitoring"
```

---

## 7. Evaluare

### 7.1 Criterii de Evaluare

| Criteriu                  | Pondere | Descriere                                    |
|---------------------------|---------|----------------------------------------------|
| Funcționalitate           | 40%     | Implementare corectă a cerințelor            |
| Calitate cod              | 25%     | Structură, lizibilitate, best practices      |
| Error handling            | 15%     | Gestionare solidă a erorilor                |
| Testare                   | 10%     | Teste relevante și complet             |
| Documentație              | 10%     | README, comentarii, help text                |

### 7.2 Niveluri de Realizare

Nivel Bază (punctaj 50-69%):

Trei lucruri contează aici: funcționalitate principală implementată, script rulează fără erori critice, și configurație de bază funcțională.


Nivel Intermediar (punctaj 70-84%):
- Toate funcționalitățile implementate
- Error handling pentru cazuri comune
- Logging funcțional
- Teste de bază

Nivel Avansat (punctaj 85-100%):
- Funcționalități extra (opționale)
- Error handling complet
- Teste extensive
- Documentație completă
- Cod optimizat și elegant

---

## 8. Resurse și Referințe

### 8.1 Documentație Oficială

- Bash Reference Manual: https://www.gnu.org/software/bash/manual/
- Linux man pages: `man bash`, `man test`, `man find`, `man tar`
- Filesystem Hierarchy Standard: https://refspecs.linuxfoundation.org/FHS_3.0/

### 8.2 Cărți Recomandate

- Shotts, William E. "The Linux Command Line" (disponibil gratuit online)
- Robbins, Arnold & Beebe, Nelson. "Classic Shell Scripting", O'Reilly
- Cooper, Mendel. "Advanced Bash-Scripting Guide" (TLDP)

### 8.3 Articole și Tutoriale

- Greg's Wiki (mywiki.wooledge.org) - best practices Bash
- ShellCheck (shellcheck.net) - analiză statică scripturi shell
- Explain Shell (explainshell.com) - explicații comenzi

---

## 9. Concluzie

Proiectul CAPSTONE modifică cunoștințele teoretice în competențe practice 
aplicabile imediat în industrie. Prin construirea acestor sisteme de la zero, 
studenții experimentează direct provocările dezvoltării software reale: 
gestionarea complexității, compromisurile arhitecturale, testarea sistematică 
și documentarea clară.

Mai mult decât simple exerciții de programare, aceste proiecte cultivă 
mentalitatea inginerească - capacitatea de a analiza probleme, descompune 
soluții, anticipa moduri de eșec și construi sisteme solide care funcționează 
în condiții reale, nu doar în scenarii ideale de laborator.

Succes în implementare!

---

*Document actualizat: Ianuarie 2026*
*Versiune: 1.0*
*Autor: Echipa Sisteme de Operare, ASE-CSIE*
