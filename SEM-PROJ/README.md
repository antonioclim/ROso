# SEM-PROJ: Proiecte de Semestru - Sisteme de Operare

> Sisteme de Operare | ASE București - CSIE  
> Autor: ing. dr. Antonio Clim  
> Versiune: 1.0 | Ianuarie 2025

---

## Prezentare Generală

Proiectele de semestru reprezintă componenta practică majoră a cursului de Sisteme de Operare. Fiecare student trebuie să aleagă și să implementeze un proiect din cele 23 disponibile, organizate pe trei niveluri de dificultate.

### Obiective Pedagogice

- Aplicare practică a conceptelor teoretice din curs
- Dezvoltare competențe de scripting Bash avansat
- Înțelegere profundă a mecanismelor sistemului de operare
- Experiență practică cu tooling-ul de sistem Linux

---

## Statistici Proiecte

| Nivel | Număr | Timp Estimat | Complexitate | Componente |
|-------|-------|--------------|--------------|------------|
| EASY | 5 | 15-20 ore | ⭐⭐ | Bash only |
| MEDIUM | 15 | 25-35 ore | ⭐⭐⭐ | Bash + opțional Kubernetes |
| ADVANCED | 3 | 40-50 ore | ⭐⭐⭐⭐⭐ | Bash + integrare C |

---

## Structura Folderului

```
SEM-PROJ/
├── README.md                 # Acest document
├── EVALUARE_GENERALA.md      # Criterii și proces de evaluare
├── GHID_TEHNIC.md            # Ghid tehnic pentru implementare
├── KUBERNETES_INTRO.md       # Introducere Kubernetes (opțional)
├── RUBRICA_UNIVERSALA.md     # Rubrica de evaluare detaliată
│
├── EASY/                     # Proiecte nivel ușor (5)
│   ├── E01_File_System_Auditor.md
│   ├── E02_Log_Analyzer.md
│   ├── E03_Bulk_File_Organizer.md
│   ├── E04_System_Health_Reporter.md
│   └── E05_Config_File_Manager.md
│
├── MEDIUM/                   # Proiecte nivel mediu (15)
│   ├── M01_Incremental_Backup_System.md
│   ├── M02_Process_Lifecycle_Monitor.md
│   ├── M03_Service_Health_Watchdog.md
│   ├── M04_Network_Security_Scanner.md
│   ├── M05_Deployment_Pipeline.md
│   ├── M06_Resource_Usage_Historian.md
│   ├── M07_Security_Audit_Framework.md
│   ├── M08_Disk_Storage_Manager.md
│   ├── M09_Scheduled_Tasks_Manager.md
│   ├── M10_Process_Tree_Analyzer.md
│   ├── M11_Memory_Forensics_Tool.md
│   ├── M12_File_Integrity_Monitor.md
│   ├── M13_Log_Aggregator.md
│   ├── M14_Environment_Config_Manager.md
│   └── M15_Parallel_Execution_Engine.md
│
├── ADVANCED/                 # Proiecte nivel avansat (3)
│   ├── A01_Mini_Job_Scheduler.md
│   ├── A02_Interactive_Shell_Extension.md
│   └── A03_Distributed_File_Sync.md
│
├── helpers/                  # Script-uri utilitare
│   ├── project_validator.sh
│   ├── submission_packager.sh
│   └── test_runner.sh
│
└── templates/                # Template-uri pentru proiecte
    ├── project_structure.sh
    ├── README_template.md
    └── Makefile_template
```

---

## Alegerea Proiectului

> Sfatul meu #1: Alege un proiect care rezolvă o problemă REALĂ pe care o ai tu. Am avut un student care a făcut un sistem de backup pentru pozele de pe telefon pentru că chiar avea nevoie de așa ceva — motivația personală l-a făcut să livreze ceva excepțional. Altul a făcut un monitor de prețuri pentru plăcile video... ghici de ce 😄

### Criterii de Selecție

1. Evaluează-ți nivelul actual de cunoștințe Bash
2. Consultă prerequisitele din fiecare cerință
3. Estimează timpul disponibil până la deadline
4. Alege un subiect care te interesează - motivația contează!

### Recomandări pe Nivel

| Dacă... | Recomandare |
|---------|-------------|
| Ești la primul contact serios cu Bash | EASY (E01-E05) |
| Ai experiență moderată cu scripting | MEDIUM (M01-M15) |
| Vrei provocare maximă și ai timp | ADVANCED (A01-A03) |
| Vrei punctaj bonus | MEDIUM/ADVANCED cu extensii |

---

## Calendar și Deadline-uri

| Etapă | Deadline | Descriere |
|-------|----------|-----------|
| Alegere proiect | Săptămâna 8 | Comunicare alegere instructor |
| Milestone 1 | Săptămâna 10 | Structură de bază funcțională |
| Milestone 2 | Săptămâna 12 | Funcționalitate completă |
| Predare finală | Săptămâna 14 | Cod + documentație + prezentare |
| Prezentări | Sesiune | Demonstrație și întrebări |

---

## Livrabile Obligatorii

Fiecare proiect trebuie să conțină:

```
NumePrenume_ProiectXX/
├── README.md              # Documentație completă
├── src/                   # Cod sursă
│   ├── main.sh            # Script principal
│   └── lib/               # Module/funcții auxiliare
├── tests/                 # Teste automatizate
│   └── test_*.sh
├── docs/                  # Documentație tehnică
│   ├── INSTALL.md         # Instrucțiuni instalare
│   └── USAGE.md           # Manual utilizare
├── examples/              # Exemple de utilizare
└── Makefile               # Build/test automation
```

---

## Sistem de Evaluare

### Distribuție Punctaj

| Componentă | Pondere |
|------------|---------|
| Funcționalitate corectă | 40% |
| Calitate cod | 20% |
| Documentație | 15% |
| Teste automatizate | 15% |
| Prezentare | 10% |

### Bonusuri Disponibile

| Bonus | Valoare | Condiție |
|-------|---------|----------|
| Extensie Kubernetes | +10% | Proiecte MEDIUM cu deployment K8s |
| Componentă C | +15% | Integrare modul C funcțional |
| CI/CD Pipeline | +5% | GitHub Actions sau similar |
| Documentație video | +5% | Demo înregistrat 3-5 min |

### Penalizări

| Situație | Penalizare |
|----------|------------|
| Predare întârziată (< 24h) | -10% |
| Predare întârziată (24-72h) | -25% |
| Predare întârziată (> 72h) | -50% |
| Plagiat detectat | -100% (0 și raport disciplinar) |
| Nu compilează/rulează | -30% |
| Lipsă documentație | -20% |

---

## Resurse Necesare

### Mediu de Dezvoltare

- OS: Ubuntu 24.04 (nativ, VM sau WSL2)
- Shell: Bash 5.0+
- Editor: vim, nano sau VS Code cu Remote-SSH
- Version control: Git

### Tooling Recomandat

```bash
# Verificare versiuni
bash --version      # >= 5.0
git --version       # >= 2.30
shellcheck --version # pentru linting

# Instalare shellcheck (dacă lipsește)
sudo apt install shellcheck
```

### Materiale de Studiu

- `003initialSTEPs/01_Ghid_Scripting_Bash.md`
- `003initialSTEPs/03_Ghid_Observabilitate_si_Debugging.md`
- Materialele din SEM01-SEM06

---

## Întrebări Frecvente

Q: Pot lucra în echipă?  
A: Nu. Proiectele sunt individuale. Colaborarea pentru învățare e OK, dar codul trebuie să fie propriu.

Q: Pot schimba proiectul după ce l-am ales?  
A: Da, până la Milestone 1, cu aprobare de la instructor.

Q: Ce se întâmplă dacă nu termin toate cerințele?  
A: Se evaluează ce ai implementat. Funcționalitate parțială primește punctaj parțial.

Q: Pot folosi biblioteci externe?  
A: Da, pentru componente ajutătoare (ex: `jq` pentru JSON). Nucleul trebuie să fie cod propriu.

Q: Cum demonstrez că nu am plagiat?  
A: Vei putea explica orice linie de cod în prezentare. Comentariile ajută.

---

## Contact și Suport

- Consultații: După orele de seminar sau prin programare
- Forum întrebări: Platforma de curs
- Email: [adresa instructor]

---

## Pași Următori

1. ✅ Citește `EVALUARE_GENERALA.md` pentru detalii evaluare
2. ✅ Parcurge `GHID_TEHNIC.md` pentru best practices
3. ✅ Alege un proiect din `EASY/`, `MEDIUM/` sau `ADVANCED/`
4. ✅ Comunică alegerea instructorului
5. ✅ Începe implementarea folosind `templates/`

---

*Kit SO - Proiecte Semestru | Ianuarie 2025*
