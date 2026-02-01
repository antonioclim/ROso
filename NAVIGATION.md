# Kit Educațional ROso — Index de Navigare

> **Referință rapidă pentru găsirea materialelor în acest kit**  
> **Curs:** Sisteme de Operare | ASE București — CSIE  
> **Autor:** ing. dr. Antonio Clim  
> **Ultima Actualizare:** Ianuarie 2025

---

## 🚀 Pornire Rapidă

| Vreau să... | Mergi la |
|--------------|-------|
| Configurez mediul | [01_INIT_SETUP/](./01_INIT_SETUP/) |
| Predau tema | [02_INIT_HOMEWORKS/](./02_INIT_HOMEWORKS/) |
| Găsesc ghiduri student | [03_GUIDES/](./03_GUIDES/) |
| Explorez proiecte | [04_PROJECTS/](./04_PROJECTS/) |
| Citesc notițe curs | [05_LECTURES/](./05_LECTURES/) |
| Mă pregătesc pentru examen | [00_SUPPLEMENTARY/](./00_SUPPLEMENTARY/) |
| Înțeleg notarea | [SEM07/grade_aggregation/](./SEM07/grade_aggregation/) |

---

## 📚 Materiale Seminarii

| Săpt | Temă | Materiale | Scripturi Cheie |
|------|-------|-----------|-------------|
| 1 | Fundamentele Shell | [SEM01/](./SEM01/) | Quoting, variabile, FHS |
| 2 | Redirecționare I/O și Bucle | [SEM02/](./SEM02/) | Pipes, filtre, baze scripting |
| 3 | Find, Xargs, Permisiuni | [SEM03/](./SEM03/) | Operații fișiere, getopts, cron |
| 4 | Procesare Text (grep/sed/awk) | [SEM04/](./SEM04/) | Regex, potrivire paternuri |
| 5 | Funcții și Tablouri | [SEM05/](./SEM05/) | Scripting robust, trap, logging |
| 6 | Proiect de Sinteză | [SEM06/](./SEM06/) | Monitor, Backup, Deployer |
| 7 | Evaluare | [SEM07/](./SEM07/) | Evaluare, notare, susținere orală |

---

## 📁 Tipuri de Documente

Fiecare seminar conține documente standardizate:

### Pentru Instructori

| Document | Scop |
|----------|---------|
| `S0X_00_PEDAGOGICAL_ANALYSIS_PLAN.md` | Design învățare și obiective |
| `S0X_01_INSTRUCTOR_GUIDE.md` | Ghid facilitare sesiune |
| `S0X_05_LIVE_CODING_GUIDE.md` | Scripturi demo și parcurgeri |
| `S0X_08_SPECTACULAR_DEMOS.md` | Demonstrații captivante |

### Pentru Studenți

| Document | Scop |
|----------|---------|
| `S0X_02_MAIN_MATERIAL.md` | Conținut principal și explicații |
| `S0X_03_PEER_INSTRUCTION.md` | Întrebări pentru discuții |
| `S0X_04_PARSONS_PROBLEMS.md` | Exerciții ordonare cod |
| `S0X_06_SPRINT_EXERCISES.md` | Probleme practică cronometrată |
| `S0X_07_LLM_AWARE_EXERCISES.md` | Sarcini rezistente la AI |
| `S0X_09_VISUAL_CHEAT_SHEET.md` | Referință rapidă |
| `S0X_10_SELF_ASSESSMENT_REFLECTION.md` | Auto-evaluare |

### Teme

| Document | Locație |
|----------|----------|
| Specificație temă | `SEM0X/homework/S0X_01_HOMEWORK.md` |
| Grilă evaluare | `SEM0X/homework/S0X_03_EVALUATION_RUBRIC.md` |
| Ghid verificare orală | `SEM0X/homework/S0X_04_ORAL_VERIFICATION*.md` |

---

## 🛠️ Instrumente și Scripturi

### Instrumente Notare

| Instrument | Locație | Scop |
|------|----------|---------|
| Autograder | `SEM0X/scripts/python/S0X_01_autograder.py` | Notare automată lucrări |
| Generator Quiz | `SEM0X/scripts/python/S0X_02_quiz_generator.py` | Generare chestionare evaluare |
| Generator Rapoarte | `SEM0X/scripts/python/S0X_03_report_generator.py` | Creare rapoarte note |

### Instrumente Integritate Academică

| Instrument | Locație | Scop |
|------|----------|---------|
| Detector Plagiat | `SEM01/scripts/python/S01_05_plagiarism_detector.py` | Verificare similaritate cod |
| Scanner AI | `SEM01/scripts/python/S01_06_ai_fingerprint_scanner.py` | Detectare text generat de AI |
| Ghid MOSS/JPlag | `SEM07/external_tools/MOSS_JPLAG_GUIDE.md` | Integrare instrumente externe |
| Pipeline Combinat | `SEM07/external_tools/run_plagiarism_check.sh` | Verificare integritate completă |

### Biblioteci Partajate

| Bibliotecă | Locație | Scop |
|---------|----------|---------|
| Utilități Logging | `lib/logging_utils.py` | Logging standardizat |
| Randomizare | `lib/randomisation_utils.py` | Parametri test specifici student |

### Scripturi Demonstrative

| Locație | Conținut |
|----------|----------|
| `SEM0X/scripts/demo/` | Demonstrații live coding |
| `SEM0X/scripts/bash/` | Scripturi configurare și validare |

---

## 📊 Evaluare

### Ponderi Componente

| Componentă | Pondere | Detalii |
|-----------|--------|---------|
| Teme | 25% | [SEM07/homework_evaluation/](./SEM07/homework_evaluation/) |
| Proiect | 50% | [SEM07/project_evaluation/](./SEM07/project_evaluation/) |
| Test | 25% | [SEM07/final_test/](./SEM07/final_test/) |

### Documente Cheie

| Document | Locație |
|----------|----------|
| Politică Notare | [SEM07/grade_aggregation/GRADING_POLICY.md](./SEM07/grade_aggregation/GRADING_POLICY.md) |
| Calculator Notă Finală | [SEM07/grade_aggregation/final_grade_calculator_RO.py](./SEM07/grade_aggregation/final_grade_calculator_RO.py) |
| Întrebări Susținere Orală | [SEM07/project_evaluation/oral_defence_questions_RO.md](./SEM07/project_evaluation/oral_defence_questions_RO.md) |
| Listă Verificare Evaluare Manuală | [SEM07/project_evaluation/manual_eval_checklist_RO.md](./SEM07/project_evaluation/manual_eval_checklist_RO.md) |

---

## 📖 Materiale Curs

### Teme Curs

| Capitol | Temă | Locație |
|---------|-------|----------|
| 01 | Introducere în SO | [05_LECTURES/01-Introduction_to_Operating_Systems/](./05_LECTURES/01-Introduction_to_Operating_Systems/) |
| 02 | Concepte de Bază SO | [05_LECTURES/02-Basic_OS_Concepts/](./05_LECTURES/02-Basic_OS_Concepts/) |
| 03 | Procese (PCB, fork) | [05_LECTURES/03-Processes_(PCB+fork)/](./05_LECTURES/03-Processes_%28PCB+fork%29/) |
| 04 | Planificare Procese | [05_LECTURES/04-Process_Scheduling/](./05_LECTURES/04-Process_Scheduling/) |
| 05 | Fire de Execuție | [05_LECTURES/05-Execution_Threads/](./05_LECTURES/05-Execution_Threads/) |
| 06 | Sincronizare Partea 1 | [05_LECTURES/06-Synchronisation_(Part1_Peterson+locks+mutex)/](./05_LECTURES/06-Synchronisation_%28Part1_Peterson+locks+mutex%29/) |
| 07 | Sincronizare Partea 2 | [05_LECTURES/07-Synchronisation_(Part2_semaphore_buffer)/](./05_LECTURES/07-Synchronisation_%28Part2_semaphore_buffer%29/) |
| 08 | Interblocare | [05_LECTURES/08-Deadlock_(Coffman)/](./05_LECTURES/08-Deadlock_%28Coffman%29/) |
| 09 | Gestiune Memorie Partea 1 | [05_LECTURES/09-Memory_Management_Part1_paging_segmentation/](./05_LECTURES/09-Memory_Management_Part1_paging_segmentation/) |
| 10 | Memorie Virtuală | [05_LECTURES/10-Virtual_Memory_(TLB_Belady)/](./05_LECTURES/10-Virtual_Memory_%28TLB_Belady%29/) |
| 11 | Sistem Fișiere Partea 1 | [05_LECTURES/11-File_System_(Part1_inode_pointers)/](./05_LECTURES/11-File_System_%28Part1_inode_pointers%29/) |
| 12 | Sistem Fișiere Partea 2 | [05_LECTURES/12-File_System_Part2_alloc_extent_struct/](./05_LECTURES/12-File_System_Part2_alloc_extent_struct/) |
| 13 | Securitate | [05_LECTURES/13-Security_in_Operating_Systems/](./05_LECTURES/13-Security_in_Operating_Systems/) |
| 14 | Virtualizare | [05_LECTURES/14-Virtualization+Recap/](./05_LECTURES/14-Virtualization+Recap/) |

### Teme Suplimentare

| Temă | Locație |
|-------|----------|
| Conexiuni Rețea | [05_LECTURES/15supp-Network_Connection/](./05_LECTURES/15supp-Network_Connection/) |
| Containerizare Avansată | [05_LECTURES/16supp-Advanced_Containerisation/](./05_LECTURES/16supp-Advanced_Containerisation/) |
| Programare Kernel | [05_LECTURES/17supp-Kernel_Level_OS_Programming/](./05_LECTURES/17supp-Kernel_Level_OS_Programming/) |
| Integrare NPU | [05_LECTURES/18supp-NPU_Integration_in_Operating_Systems/](./05_LECTURES/18supp-NPU_Integration_in_Operating_Systems/) |

---

## 🔍 Sfaturi Căutare

```bash
# Găsește toate fișierele despre o temă
grep -rn "tema ta" --include="*.md" .

# Listează toate scripturile Python
find . -name "*.py" -type f | head -20

# Listează toate scripturile Bash  
find . -name "*.sh" -type f | head -20

# Găsește fișierele de temă
find . -name "*HOMEWORK*.md" -type f

# Găsește grilele de evaluare
find . -name "*RUBRIC*.md" -type f

# Caută exemple specifice de comenzi
grep -rn "find.*-exec" --include="*.md" .
```

---

## 📋 Proiecte

### Categorii Proiecte

| Dificultate | Locație | Descriere |
|------------|----------|-------------|
| Ușor | [04_PROJECTS/b)EASY/](./04_PROJECTS/b%29EASY/) | 5 proiecte pentru începători |
| Mediu | [04_PROJECTS/a)MEDIUM/](./04_PROJECTS/a%29MEDIUM/) | 15 proiecte intermediare |
| Avansat | [04_PROJECTS/c)ADVANCED/](./04_PROJECTS/c%29ADVANCED/) | 3 proiecte provocatoare |

### Resurse Proiecte

| Resursă | Locație |
|----------|----------|
| Ghid Selecție | [04_PROJECTS/PROJECT_SELECTION_GUIDE.md](./04_PROJECTS/PROJECT_SELECTION_GUIDE.md) |
| Ghid Tehnic | [04_PROJECTS/TECHNICAL_GUIDE.md](./04_PROJECTS/TECHNICAL_GUIDE.md) |
| Grilă Universală | [04_PROJECTS/UNIVERSAL_RUBRIC.md](./04_PROJECTS/UNIVERSAL_RUBRIC.md) |
| Evaluare Automatizată | [04_PROJECTS/AUTOMATED_EVALUATION_SPEC/](./04_PROJECTS/AUTOMATED_EVALUATION_SPEC/) |

---

## 🔧 Fișiere Configurare

| Fișier | Scop |
|------|---------|
| `pyproject.toml` | Configurare proiect Python |
| `.markdownlint.json` | Reguli verificare Markdown |
| `.shellcheckrc` | Reguli verificare scripturi shell |
| `SEM0X/requirements.txt` | Dependențe Python per seminar |

---

## 📞 Suport

- **Autor:** ing. dr. Antonio Clim
- **Instituție:** ASE București — Facultatea de Cibernetică, Statistică și Informatică Economică
- **Curs:** Sisteme de Operare
- **LICENȚĂ:** RESTRICTIVĂ (doar pentru predare/învățare din acest depozit!)

---

## 📝 Istoric Versiuni

| Versiune | Dată | Modificări |
|---------|------|---------|
| 5.0.0 | Ian 2025 | Lansare inițială FAZA 1-5 |
| 5.2.1 | Ian 2026 | FAZA 5-6: Instrumente risc AI, îmbunătățiri documentație |

---

*Acest index de navigare este verificat automat de CI/CD. Vezi `.github/workflows/quality.yml` pentru detalii.*
