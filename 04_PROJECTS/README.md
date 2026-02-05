# SEM-PROJ: Proiecte de semestru – Sisteme de Operare

> Sisteme de Operare | ASE București – CSIE  
> Autor: ing. dr. Antonio Clim  
> Versiune: 2.0 | ianuarie 2025

---

## 📋 Prezentare generală

Proiectele de semestru reprezintă componenta practică majoră a cursului de Sisteme de Operare. Fiecare student trebuie să aleagă și să implementeze un proiect dintre cele 23 disponibile, organizate pe trei niveluri de dificultate.

### Obiective pedagogice

- Aplicarea practică a conceptelor teoretice din curs
- Dezvoltarea competențelor avansate de scripting în Bash
- Înțelegerea aprofundată a mecanismelor unui sistem de operare
- Experiență aplicată cu instrumentele de sistem din Linux

---

## 📊 Statisticile proiectelor

| Nivel | Număr | Timp estimat | Complexitate | Componente |
|-------|------:|--------------|--------------|------------|
| EASY | 5 | 15–20 ore | ⭐⭐ | Doar Bash |
| MEDIUM | 15 | 25–35 ore | ⭐⭐⭐ | Bash + Kubernetes opțional |
| ADVANCED | 3 | 40–50 ore | ⭐⭐⭐⭐⭐ | Bash + integrare C |

---

## 📁 Structura folderelor

```
SEM-PROJ/
├── README.md                    # Acest document
├── GENERAL_EVALUATION.md        # Criterii și proces de evaluare
├── TECHNICAL_GUIDE.md           # Ghid tehnic pentru implementare
├── KUBERNETES_INTRO.md          # Introducere Kubernetes (opțional)
├── UNIVERSAL_RUBRIC.md          # Rubrică detaliată de evaluare
├── PROJECT_SELECTION_GUIDE.md   # Ghid pentru alegerea proiectului
│
├── b)EASY/                      # Proiecte nivel EASY (5)
│   ├── README.md                # Prezentare proiecte EASY
│   ├── E01_File_System_Auditor.md
│   ├── E02_Log_Analyzer.md
│   ├── E03_Bulk_File_Organizer.md
│   ├── E04_System_Health_Reporter.md
│   └── E05_Config_File_Manager.md
│
├── a)MEDIUM/                    # Proiecte nivel MEDIUM (15)
│   ├── README.md                # Prezentare proiecte MEDIUM
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
├── c)ADVANCED/                  # Proiecte nivel ADVANCED (3)
│   ├── README.md                # Prezentare proiecte ADVANCED
│   ├── A01_Mini_Job_Scheduler.md
│   ├── A02_Interactive_Shell_Extension.md
│   └── A03_Distributed_File_Sync.md
│
├── AUTOMATED_EVALUATION_SPEC/   # Specificații pentru evaluarea automată
│   ├── AUTOMATED_EVALUATION_SPEC.md
│   ├── AUTOMATED_EVALUATION_SUMMARY.md
│   ├── TEST_SPEC_EASY.md
│   ├── TEST_SPEC_MEDIUM.md
│   └── TEST_SPEC_ADVANCED.md
│
├── helpers/                     # Scripturi utilitare
│   ├── project_validator.sh
│   ├── submission_packager.sh
│   └── test_runner.sh
│
├── templates/                   # Șabloane de proiect
│   ├── project_structure.sh
│   ├── README_template.md
│   └── Makefile_template
│
└── formative/                   # Autoevaluare
    └── project_readiness_quiz.yaml
```

---

## 🎯 Alegerea proiectului

> 💡 **Recomandare practică:** alege un proiect care rezolvă o problemă reală pe care o ai. Motivația personală crește calitatea livrabilului și reduce riscul de abandon. Au existat proiecte excelente pornite din nevoi concrete (de exemplu, backup pentru fotografii, monitorizare de prețuri pentru componente hardware).

### Diagramă rapidă de decizie

```
ÎNCEPE AICI
    │
    ▼
┌─────────────────────────────────────┐
│ Ai scris anterior >500 de linii de  │
│ cod Bash?                           │
└─────────────────────────────────────┘
              │
       ┌──────┴──────┐
       │             │
      DA             NU
       │             │
       ▼             ▼
┌────────────┐   ┌────────────────────┐
│ Cunoști C? │   │ 👉 ÎNCEPE CU EASY  │
└────────────┘   │    E01–E05         │
       │         │    (15–20 ore)     │
  ┌────┴────┐    └────────────────────┘
  │         │
 DA         NU
  │         │
  ▼         ▼
┌──────────────────┐  ┌──────────────────┐
│ 👉 ADVANCED OK   │  │ 👉 MEDIUM        │
│    A01–A03       │  │    M01–M15       │
│    (40–50 ore)   │  │    (25–35 ore)   │
└──────────────────┘  └──────────────────┘
```

Pentru un ghid de selecție mai detaliat, cu recomandări specifice, consultă `PROJECT_SELECTION_GUIDE.md`.

### Criterii de selecție

1. Evaluează nivelul actual de cunoaștere Bash
2. Consultă cerințele preliminare din specificația fiecărui proiect
3. Estimează timpul disponibil până la termenul final
4. Alege un subiect care te interesează: motivația contează în mod direct

### Recomandări pe nivel

| Dacă· | Recomandare |
|------|-------------|
| Este primul contact serios cu Bash | EASY (E01–E05) |
| Ai experiență moderată în scripting | MEDIUM (M01–M15) |
| Vrei provocare maximă și ai timp | ADVANCED (A01–A03) |
| Vizezi punctaj suplimentar | MEDIUM/ADVANCED cu extensii |

---

## 📅 Calendar și termene

| Etapă | Termen | Descriere |
|------|--------|----------|
| Alegerea proiectului | Săptămâna 8 | Comunicarea opțiunii către instructor |
| Milestone 1 | Săptămâna 10 | Structură funcțională de bază |
| Milestone 2 | Săptămâna 12 | Funcționalitate completă |
| Predare finală | Săptămâna 14 | Cod + documentație + prezentare |
| Prezentări | Sesiune | Demonstrație și întrebări |

### Linia temporală (vizual)

```
Săpt. 8        Săpt. 10       Săpt. 12       Săpt. 14       Sesiune
  │              │              │              │              │
  ▼              ▼              ▼              ▼              ▼
┌────────┐    ┌────────┐    ┌────────┐    ┌────────┐    ┌────────┐
│ ALEG   │───►│   M1   │───►│   M2   │───►│ PREDA  │───►│ PREZ   │
│ PROJ   │    │ CHECK  │    │ CHECK  │    │ FINAL  │    │ DEMO   │
└────────┘    └────────┘    └────────┘    └────────┘    └────────┘
     │              │              │              │
     │              │              │              │
     └── 2 săpt. ───┴── 2 săpt. ───┴── 2 săpt. ──┘

Legendă:
  M1 = funcționalitatea de bază este operațională (se poate demonstra funcția principală)
  M2 = toate cerințele obligatorii sunt implementate
```

> ⚠️ **Observație din practică:** eșecurile apar frecvent din cauza începerii târzii. Dacă începi în săptămâna 10, ești deja în întârziere. Proiectele par simple în specificație, însă depanarea consumă timp.

---

## 📦 Livrabile obligatorii

Fiecare proiect trebuie să conțină:

```
NameSurname_ProjectXX/
├── README.md              # Documentație completă
├── src/                   # Cod sursă
│   ├── main.sh            # Script principal
│   └── lib/               # Module/funcții auxiliare
├── tests/                 # Teste automate
│   └── test_*.sh
├── docs/                  # Documentație tehnică
│   ├── INSTALL.md         # Instrucțiuni de instalare
│   └── USAGE.md           # Manual de utilizare
├── examples/              # Exemple de utilizare
└── Makefile               # Automatizare build/test
```

Folosește `templates/project_structure.sh` pentru a genera această structură automat.

---

## 📝 Sistemul de evaluare

### Distribuția punctajului

| Componentă | Pondere |
|-----------|--------:|
| Funcționalitate corectă | 40% |
| Calitatea codului | 20% |
| Documentație | 15% |
| Teste automate | 15% |
| Prezentare | 10% |

### Bonusuri disponibile

| Bonus | Valoare | Condiție |
|------|--------:|----------|
| Extensie Kubernetes | +10% | Proiecte MEDIUM cu deployment K8s |
| Componentă C | +15% | Modul C integrat și funcțional |
| Pipeline CI/CD | +5% | GitHub Actions sau echivalent |
| Documentație video | +5% | Demo înregistrat 3–5 minute |

### Penalizări

| Situație | Penalizare |
|----------|-----------:|
| Predare întârziată (< 24h) | -10% |
| Predare întârziată (24–72h) | -25% |
| Predare întârziată (> 72h) | -50% |
| Plagiat detectat | -100% (0 și raport disciplinar) |
| Nu compilează / nu rulează | -30% |
| Documentație lipsă | -20% |

---

## 🔧 Resurse necesare

### Mediu de dezvoltare

- OS: Ubuntu 24.04 (nativ, VM sau WSL2)
- Shell: Bash 5.0+
- Editor: vim, nano sau VS Code cu Remote-SSH
- Control versiuni: Git

### Instrumente recomandate

```bash
# Verificare versiuni
bash --version       # >= 5.0
git --version        # >= 2.30
shellcheck --version # pentru analiză statică

# Instalare shellcheck (dacă lipsește)
sudo apt install shellcheck
```

### Materiale de studiu

- `../03_GUIDES/01_Bash_Scripting_Guide.md` — referință Bash
- `../03_GUIDES/03_Observability_and_Debugging_Guide.md` — instrumente de depanare
- `TECHNICAL_GUIDE.md` — bune practici specifice proiectelor
- Materialele din Seminarul 1 până la Seminarul 6

---

## ❓ Întrebări frecvente

**Î: Pot lucra în echipă?**  
R: Nu. Proiectele sunt individuale. Colaborarea pentru învățare este acceptată, însă codul trebuie să fie propriu.

**Î: Pot schimba proiectul după ce l-am ales?**  
R: Da, până la Milestone 1, cu aprobarea instructorului.

**Î: Ce se întâmplă dacă nu finalizez toate cerințele?**  
R: Se evaluează ceea ce este implementat. Funcționalitatea parțială primește punctaj proporțional.

**Î: Pot folosi biblioteci externe?**  
R: Da, pentru componente auxiliare (de exemplu, `jq` pentru JSON). Componenta de bază trebuie să fie cod propriu.

**Î: Cum demonstrez că nu am plagiat?**  
R: În prezentare vei putea explica orice linie de cod. Comentariile bine plasate ajută.

**Î: Pot folosi instrumente de asistență bazate pe inteligență artificială?**  
R: Da, pentru învățare și depanare. Totuși, codul final trebuie să fie înțeles integral, deoarece îl vei explica în timpul prezentării.

---

## 📞 Contact și suport

- Consultații: după seminar sau cu programare
- Forum întrebări: platforma cursului
- E-mail: [adresă instructor]

---

## ✅ Pașii următori

1. ✅ Citește `GENERAL_EVALUATION.md` pentru detalii de evaluare
2. ✅ Parcurge `TECHNICAL_GUIDE.md` pentru bune practici
3. ✅ Folosește `PROJECT_SELECTION_GUIDE.md` pentru o alegere informată
4. ✅ Alege un proiect din `a)MEDIUM/`, `b)EASY/` sau `c)ADVANCED/`
5. ✅ Comunică opțiunea către instructor
6. ✅ Începe implementarea folosind `templates/project_structure.sh`

---

*Kit SO – Proiecte de semestru | Versiunea 2.0 | ianuarie 2025*
