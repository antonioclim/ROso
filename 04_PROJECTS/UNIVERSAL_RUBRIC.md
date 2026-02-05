# Rubrică Universală de Evaluare - Proiecte de Semestru

> **Document pentru Evaluatori**  
> **Sisteme de Operare** | ASE București - CSIE

---

## Sistem de Punctare

> **Notă importantă**: Toate scorurile sunt exprimate în **procente (%)** din nota finală. Valoarea în puncte absolute va fi comunicată de instructor la începutul semestrului.

---

## Structură Evaluare

| Componentă | Pondere | Descriere |
|-----------|--------|-------------|
| Funcționalitate | 40% | Implementare cerințe |
| Calitate Cod | 20% | Structură, claritate, best practices |
| Documentație | 15% | README, comentarii, ghiduri |
| Teste | 15% | Acoperire și calitate teste |
| Prezentare | 10% | Demo și explicații |
| **TOTAL** | **100%** | |

---

## Detalii Criterii

### 1. FUNCȚIONALITATE (40%)

#### 1.1 Cerințe Obligatorii (30%)

| Criteriu | % | Excelent (100%) | Bun (70%) | Satisfăcător (50%) | Insuficient (20%) |
|-----------|---|------------------|------------|--------------------|--------------------|
| Funcționalitate de bază | 15% | Toate funcțiile corect implementate | Funcții principale OK, lacune minore | Funcțional parțial | Nu funcționează |
| Gestionare input | 8% | Validare completă, mesaje clare | Validare principală | Validare minimă | Fără validare |
| Output corect | 7% | Format corect, informativ | Format OK | Output de bază | Output incorect |

#### 1.2 Cerințe Opționale/Avansate (10%)

| Criteriu | % | Descriere |
|-----------|---|-------------|
| Funcționalități extra | 5% | Implementări peste cerințele minime |
| Optimizări | 3% | Performanță, eficiență |
| Integrări | 2% | Integrare cu alte instrumente |

### 2. CALITATE COD (20%)

#### 2.1 Structură și Organizare (8%)

| Criteriu | % | Excelent | Acceptabil | Insuficient |
|-----------|---|-----------|------------|--------------|
| Modularitate | 3% | Funcții bine definite, lib/ separat | Unele funcții | Cod monolitic |
| Organizare fișiere | 3% | Structură standard (src/, tests/, docs/) | Structură logică | Dezorganizat |
| Separare responsabilități | 2% | Config/logică/UI separate | Parțial separate | Tot amestecat |

#### 2.2 Claritate Cod (7%)

| Criteriu | % | Excelent | Acceptabil | Insuficient |
|-----------|---|-----------|------------|--------------|
| Denumire variabile | 3% | Descriptivă, consistentă | Majoritar clară | Ambiguă |
| Complexitate | 2% | Funcții scurte, logică clară | Acceptabil | Funcții lungi, confuze |
| Formatare | 2% | Indentare consistentă | Inconsistențe minore | Neformatat |

#### 2.3 Best Practices (5%)

| Criteriu | % | Excelent | Acceptabil | Insuficient |
|-----------|---|-----------|------------|--------------|
| ShellCheck curat | 2% | 0 avertismente | < 5 avertismente minore | Erori multiple |
| Gestionare erori | 2% | `set -euo pipefail`, trap | Parțial | Fără gestionare |
| Portabilitate | 1% | Funcționează pe orice Linux | Probleme minore | Path-uri hardcoded |

### 3. DOCUMENTAȚIE (15%)

#### 3.1 README.md (8%)

| Secțiune | % | Excelent | Acceptabil | Insuficient |
|---------|---|-----------|------------|--------------|
| Descriere proiect | 2% | Clară, completă | Prezentă | Lipsă/vagă |
| Instalare | 2% | Pași detalioați, dependențe | Instrucțiuni de bază | Lipsă |
| Utilizare | 2% | Exemple, opțiuni documentate | Utilizare de bază | Lipsă |
| Structură proiect | 2% | Arbore complet explicat | Listare fișiere | Lipsă |

#### 3.2 Documentație Tehnică (4%)

| Document | % | Excelent | Acceptabil | Insuficient |
|----------|---|-----------|------------|--------------|
| INSTALL.md | 2% | Dependențe, pași, troubleshooting | De bază | Lipsă |
| ARCHITECTURE.md | 2% | Diagrame, flux date | Descriere text | Lipsă |

#### 3.3 Comentarii Cod (3%)

| Criteriu | % | Excelent | Acceptabil | Insuficient |
|-----------|---|-----------|------------|--------------|
| Funcții documentate | 2% | Toate cu docstring | Principale documentate | Fără comentarii |
| Logică complexă | 1% | Explicații inline | Unele comentarii | Cod neexplicat |

### 4. TESTE AUTOMATE (15%)

#### 4.1 Acoperire (10%)

| Acoperire | % acordat |
|----------|-----------|
| > 80% funcționalități | 10% |
| 60-80% | 8% |
| 40-60% | 6% |
| 20-40% | 4% |
| < 20% | 2% |

#### 4.2 Calitate Teste (5%)

| Criteriu | % | Excelent | Acceptabil | Insuficient |
|-----------|---|-----------|------------|--------------|
| Teste cazuri limită | 2% | Cazuri limită testate | Unele cazuri | Doar happy path |
| Teste negative | 2% | Erori validate | Unele | Niciunul |
| Organizare | 1% | Structurate, refolosibile | Funcționale | Dezordonate |

### 5. PREZENTARE (10%)

| Criteriu | % | Excelent | Acceptabil | Insuficient |
|-----------|---|-----------|------------|--------------|
| Demonstrație live | 4% | Funcționează perfect | Probleme minore | Nu funcționează |
| Explicare arhitectură | 3% | Clară, completă | Acceptabilă | Confuză |
| Răspunsuri întrebări | 3% | Înțelege totul | Majoritatea | Nu poate explica |

---

## BONUSURI

| Bonus | Valoare | Cerințe |
|-------|-------|--------------|
| Extensie Kubernetes | +10% | Deployment funcțional, documentație K8s |
| Componentă C | +15% | Modul C compilabil și integrat |
| Pipeline CI/CD | +5% | GitHub Actions funcțional cu teste |
| Documentație video | +5% | Demo 3-5 min, calitate bună |

**Notă:** Bonusurile se adaugă peste 100% și sunt acordate integral sau deloc (nu parțial).

---

## PENALIZĂRI

### Întârzieri

| Întârziere | Penalizare |
|-------|---------|
| < 1 oră | -0% (avertisment) |
| 1-24 ore | -10% |
| 24-72 ore | -25% |
| 72h - 7 zile | -50% |
| > 7 zile | Nu se acceptă |

### Probleme Tehnice

| Problemă | Penalizare |
|-------|---------|
| Nu compilează/rulează | -30% |
| README.md lipsă | -15% |
| Teste lipsă complet | -10% |
| Erori ShellCheck severe | -5% |
| Path-uri hardcoded | -5% |
| Fișiere binare în repo | -5% |

### Plagiat și Integritate Academică

| Situație | Consecință |
|-----------|-------------|
| Cod identic cu colegul | -100% (ambii) + raport |
| Cod de pe internet necitat | -50% prima abatere |
| Abatere repetată | Propunere exmatriculare |

---

## FORMULAR DE EVALUARE

```
╔══════════════════════════════════════════════════════════════════╗
║      EVALUARE PROIECT DE SEMESTRU - SISTEME DE OPERARE          ║
╠══════════════════════════════════════════════════════════════════╣
║ Student:     ________________________________________________    ║
║ Proiect:     ________________________________________________    ║
║ Data:        ________________________________________________    ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║ 1. FUNCȚIONALITATE (40%)                                         ║
║    ├─ Cerințe obligatorii (30%):    _____ × 0.30 = _____       ║
║    └─ Cerințe opționale (10%):      _____ × 0.10 = _____       ║
║                                      Subtotal: _____%            ║
║                                                                  ║
║ 2. CALITATE COD (20%)                                            ║
║    ├─ Structură (8%):                _____ × 0.08 = _____       ║
║    ├─ Claritate (7%):                _____ × 0.07 = _____       ║
║    └─ Best practices (5%):           _____ × 0.05 = _____       ║
║                                      Subtotal: _____%            ║
║                                                                  ║
║ 3. DOCUMENTAȚIE (15%)                                            ║
║    ├─ README.md (8%):                _____ × 0.08 = _____       ║
║    ├─ Documentație tehnică (4%):     _____ × 0.04 = _____       ║
║    └─ Comentarii (3%):               _____ × 0.03 = _____       ║
║                                      Subtotal: _____%            ║
║                                                                  ║
║ 4. TESTE (15%)                                                   ║
║    ├─ Acoperire (10%):               _____ × 0.10 = _____       ║
║    └─ Calitate (5%):                 _____ × 0.05 = _____       ║
║                                      Subtotal: _____%            ║
║                                                                  ║
║ 5. PREZENTARE (10%)                                              ║
║    ├─ Demo (4%):                     _____ × 0.04 = _____       ║
║    ├─ Explicații (3%):               _____ × 0.03 = _____       ║
║    └─ Întrebări (3%):                _____ × 0.03 = _____       ║
║                                      Subtotal: _____%            ║
║                                                                  ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║ SUBTOTAL (max 100%):                           _____%            ║
║                                                                  ║
║ BONUSURI:                                                        ║
║    □ Kubernetes (+10%):                        +_____%           ║
║    □ Componentă C (+15%):                      +_____%           ║
║    □ CI/CD (+5%):                              +_____%           ║
║    □ Video (+5%):                              +_____%           ║
║                                                                  ║
║ PENALIZĂRI:                                                      ║
║    □ Întârziere:                               -_____%           ║
║    □ Probleme tehnice:                         -_____%           ║
║    □ Altele:                                   -_____%           ║
║                                                                  ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║ ══════════════════════════════════════════════════════════════   ║
║ TOTAL FINAL:                                   _____%            ║
║ ══════════════════════════════════════════════════════════════   ║
║                                                                  ║
║ Comentarii:                                                      ║
║ ________________________________________________________________ ║
║ ________________________________________________________________ ║
║ ________________________________________________________________ ║
║                                                                  ║
║ Evaluator: ________________________  Semnătură: _______________  ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

---

## CHECKLIST RAPID DE EVALUARE

```
Pre-evaluare (automată):
□ Arhivă denumită corect
□ Structură fișiere respectată
□ README.md prezent
□ Scripturi au shebang
□ bash -n trece fără erori
□ ShellCheck fără erori critice

Evaluare funcțională:
□ Instalare urmând INSTALL.md funcționează
□ Comanda help funcționează
□ Scenariul principal funcționează
□ Cazuri limită gestionate
□ Erori raportate clar

Evaluare calitativă:
□ Cod lizibil și comentat
□ Funcții modularizate
□ Variabile denumite descriptiv
□ Teste prezente și trecătoare
□ Documentație completă

Prezentare:
□ Studentul poate rula proiectul
□ Studentul explică arhitectura
□ Studentul răspunde la întrebări despre cod
```

---

*Rubrică Universală - Proiecte SO | Ianuarie 2025*
