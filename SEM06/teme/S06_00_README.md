# Teme - Seminar 6 (CAPSTONE)

> **⚠️ STRUCTURĂ SPECIALĂ:** SEM06 este seminar **CAPSTONE** de integrare.

---

## Conținut Folder teme/

| Fișier | Descriere | Audiență |
|--------|-----------|----------|
| `S06_00_README.md` | Acest document explicativ | Instructori |
| `S06_01_TEMA_CAPSTONE.md` | Cerințe complete pentru proiectele CAPSTONE | Studenți |
| `S06_02_RUBRICA_EVALUARE.md` | Criterii detaliate de evaluare | Instructori |
| `OLD_HW/` | Materiale arhivate | - |

---

## Despre Structura CAPSTONE

### Diferențe față de SEM01-05

| Aspect | Seminarii Standard (SEM01-05) | SEM06 CAPSTONE |
|--------|-------------------------------|----------------|
| Tipul temelor | Exerciții punctuale per săptămână | Proiecte de amploare pe semestru |
| Structură fișiere | `S0X_01_TEMA.md` + script generare | `S06_01_TEMA_CAPSTONE.md` (fișier unic mare) |
| Evaluare | Per exercițiu | Portfolio + Proiect Integrat |
| Timp alocat | 1-2 săptămâni | 4 săptămâni + sesiune |

### Componente CAPSTONE

Spre deosebire de seminariile 01-05 care au teme punctuale, **SEM06** propune:

1. **Extinderi la proiectele existente** (Monitor, Backup, Deployer)
2. **Proiect Integrat** - combinarea tuturor componentelor într-un sistem coerent
3. **Evaluare de tip portfolio** - întregul cod dezvoltat în semestru

---

## Structura Temelor CAPSTONE

```
S06_01_TEMA_CAPSTONE.md conține:
│
├── Tema 1: Monitor Extensions (60p + 40p bonus)
│   ├── 1.1 Network Monitoring (20p)
│   ├── 1.2 Service Monitoring (20p)
│   ├── 1.3 Dashboard Terminal (20p)
│   ├── 1.4 Export Prometheus (+15p bonus)
│   ├── 1.5 Historical Data & Graphs (+15p bonus)
│   └── 1.6 Alerting Email/Slack (+10p bonus)
│
├── Tema 2: Backup Extensions (60p + 40p bonus)
│   ├── 2.1 Backup Encriptat (20p)
│   ├── 2.2 Backup Remote SSH/SFTP (20p)
│   ├── 2.3 Rotație Avansată (20p)
│   ├── 2.4 Deduplicare (+15p bonus)
│   ├── 2.5 Backup Database (+15p bonus)
│   └── 2.6 Raport HTML (+10p bonus)
│
├── Tema 3: Deployer Extensions (60p + 40p bonus)
│   ├── 3.1 Docker Deployment (20p)
│   ├── 3.2 Multi-Environment Pipeline (20p)
│   ├── 3.3 Monitoring Integration (20p)
│   ├── 3.4 GitOps Integration (+15p bonus)
│   ├── 3.5 Kubernetes Deployment (+15p bonus)
│   └── 3.6 Secrets Management (+10p bonus)
│
└── Tema 4: Proiect Integrat (100p)
    ├── 4.1 Unified CLI (30p)
    ├── 4.2 Automated Workflows (30p)
    ├── 4.3 Web Dashboard (20p)
    └── 4.4 Documentation & Tests (20p)
```

---

## Termene Predare

| Temă | Deadline | Punctaj |
|------|----------|---------|
| Tema 1: Monitor Extensions | Săptămâna 12 | 60p + 40p bonus |
| Tema 2: Backup Extensions | Săptămâna 13 | 60p + 40p bonus |
| Tema 3: Deployer Extensions | Săptămâna 14 | 60p + 40p bonus |
| Tema 4: Proiect Integrat | Sesiune | 100p |

---

## Format Predare

```
CAPSTONE_NumePrenume/
├── README.md               # Instrucțiuni instalare și utilizare
├── monitor/                # Proiect Monitor extins
│   ├── monitor.sh
│   ├── tests/
│   └── docs/
├── backup/                 # Proiect Backup extins
│   ├── backup.sh
│   ├── tests/
│   └── docs/
├── deployer/               # Proiect Deployer extins
│   ├── deployer.sh
│   ├── tests/
│   └── docs/
├── integrated/             # Proiect Integrat
│   ├── capstone.sh         # CLI unificat
│   ├── workflows/          # Workflow-uri automate
│   └── dashboard/          # Dashboard web (opțional)
└── screenshots/            # Demonstrații
```

---

## Fișiere Asociate în Alte Foldere

- **Documentație**: `../docs/S06_*`
- **Cod de bază**: `../scripts/projects/`
- **Framework testare**: `../scripts/test_helpers.sh`
- **Prezentări**: `../prezentari/S06_*`

---

## Note pentru Instructori

1. **Evaluare continuă**: Se recomandă milestones intermediare
2. **Flexibilitate bonus**: Studenții pot alege ce features bonus implementează
3. **Demonstrații live**: Rezervați timp în sesiune pentru prezentări
4. **Complexitate ridicată**: Estimați 40-60 ore de lucru per student

---

## Tranziție de la Fișierele Vechi

### Înainte (structură inconsistentă):
- `README.md`
- `TEME_PRACTICE.md`
- `S06_02_RUBRICA_EVALUARE.md`

### După (structură standardizată):
- `S06_00_README.md` (acest fișier)
- `S06_01_TEMA_CAPSTONE.md` (redenumit din TEME_PRACTICE.md)
- `S06_02_RUBRICA_EVALUARE.md` (nemodificat)

**Acțiune**: Ștergeți `README.md` și `TEME_PRACTICE.md` după aplicarea patch-ului.

---

*Material pentru cursul de Sisteme de Operare | ASE București - CSIE*
