# Rubrica Universală de Evaluare - Proiecte Semestru

> **Document pentru Evaluatori**  
> **Sisteme de Operare** | ASE București - CSIE

---

## Sistem de Punctare

> **Notă importantă**: Toate punctajele sunt exprimate în **procente (%)** din nota finală. Valoarea în puncte absolute va fi comunicată de instructor la începutul semestrului.

---

## Structura Evaluării

| Componentă | Pondere | Descriere |
|------------|---------|-----------|
| Funcționalitate | 40% | Implementare cerințe |
| Calitate Cod | 20% | Structură, claritate, best practices |
| Documentație | 15% | README, comentarii, ghiduri |
| Teste | 15% | Acoperire și calitate teste |
| Prezentare | 10% | Demo și explicații |
| **TOTAL** | **100%** | |

---

## Detaliere Criterii

### 1. FUNCȚIONALITATE (40%)

#### 1.1 Cerințe Obligatorii (30%)

| Criteriu | % | Excelent (100%) | Bine (70%) | Satisfăcător (50%) | Insuficient (20%) |
|----------|---|-----------------|------------|-------------------|-------------------|
| Funcționalitate core | 15% | Toate funcțiile implementate corect | Funcții principale OK, minore lipsă | Funcționează parțial | Nu funcționează |
| Tratare input | 8% | Validare completă, mesaje clare | Validare principală | Validare minimă | Fără validare |
| Output corect | 7% | Format corect, informativ | Format OK | Output basic | Output incorect |

#### 1.2 Cerințe Opționale/Avansate (10%)

| Criteriu | % | Descriere |
|----------|---|-----------|
| Funcționalități extra | 5% | Implementări peste cerințele minime |
| Optimizări | 3% | Performanță, eficiență |
| Integrări | 2% | Integrare cu alte tool-uri |

### 2. CALITATE COD (20%)

#### 2.1 Structură și Organizare (8%)

| Criteriu | % | Excelent | Acceptabil | Insuficient |
|----------|---|----------|------------|-------------|
| Modularitate | 3% | Funcții bine definite, lib/ separat | Unele funcții | Cod monolitic |
| Organizare fișiere | 3% | Structură standard (src/, tests/, docs/) | Structură logică | Dezorganizat |
| Separare concerns | 2% | Config/logic/UI separate | Parțial separat | Totul amestecat |

#### 2.2 Claritate Cod (7%)

| Criteriu | % | Excelent | Acceptabil | Insuficient |
|----------|---|----------|------------|-------------|
| Denumiri variabile | 3% | Descriptive, consistente | Majoritar clare | Ambigue |
| Complexitate | 2% | Funcții scurte, logică clară | Acceptabil | Funcții lungi, confuze |
| Formatare | 2% | Indentare consistentă | Minor inconsistențe | Neformatat |

#### 2.3 Best Practices (5%)

| Criteriu | % | Excelent | Acceptabil | Insuficient |
|----------|---|----------|------------|-------------|
| ShellCheck clean | 2% | 0 warnings | < 5 warnings minore | Erori multiple |
| Error handling | 2% | `set -euo pipefail`, trap | Parțial | Fără handling |
| Portabilitate | 1% | Funcționează pe orice Linux | Minor issues | Hardcoded paths |

### 3. DOCUMENTAȚIE (15%)

#### 3.1 README.md (8%)

| Secțiune | % | Excelent | Acceptabil | Insuficient |
|----------|---|----------|------------|-------------|
| Descriere proiect | 2% | Clară, completă | Prezentă | Lipsă/vagă |
| Instalare | 2% | Pași detaliați, dependențe | Instrucțiuni basic | Lipsă |
| Utilizare | 2% | Exemple, opțiuni documentate | Utilizare basic | Lipsă |
| Structură proiect | 2% | Tree complet explicat | Listare fișiere | Lipsă |

#### 3.2 Documentație Tehnică (4%)

| Document | % | Excelent | Acceptabil | Insuficient |
|----------|---|----------|------------|-------------|
| INSTALL.md | 2% | Dependențe, pași, troubleshooting | Basic | Lipsă |
| ARCHITECTURE.md | 2% | Diagrame, flux date | Descriere text | Lipsă |

#### 3.3 Comentarii Cod (3%)

| Criteriu | % | Excelent | Acceptabil | Insuficient |
|----------|---|----------|------------|-------------|
| Funcții documentate | 2% | Toate cu docstring | Principale documentate | Fără comentarii |
| Logică complexă | 1% | Explicații inline | Unele comentarii | Cod neexplicat |

### 4. TESTE AUTOMATIZATE (15%)

#### 4.1 Acoperire (10%)

| Acoperire | % acordat |
|-----------|-----------|
| > 80% funcționalități | 10% |
| 60-80% | 8% |
| 40-60% | 6% |
| 20-40% | 4% |
| < 20% | 2% |

#### 4.2 Calitate Teste (5%)

| Criteriu | % | Excelent | Acceptabil | Insuficient |
|----------|---|----------|------------|-------------|
| Teste edge cases | 2% | Cazuri limită testate | Unele cazuri | Doar happy path |
| Teste negative | 2% | Erori validate | Unele | Fără |
| Organizare | 1% | Structurate, reutilizabile | Funcționale | Dezordonate |

### 5. PREZENTARE (10%)

| Criteriu | % | Excelent | Acceptabil | Insuficient |
|----------|---|----------|------------|-------------|
| Demonstrație live | 4% | Funcționează perfect | Minor issues | Nu funcționează |
| Explicare arhitectură | 3% | Clară, completă | Acceptabilă | Confuză |
| Răspunsuri întrebări | 3% | Înțelege totul | Majoritatea | Nu poate explica |

---

## BONUSURI

| Bonus | Valoare | Cerințe |
|-------|---------|---------|
| Extensie Kubernetes | +10% | Deployment funcțional, documentație K8s |
| Componentă C | +15% | Modul C compilabil și integrat |
| CI/CD Pipeline | +5% | GitHub Actions funcțional cu teste |
| Documentație video | +5% | Demo 3-5 min, calitate bună |

**Observație:** Bonusurile se adaugă peste 100% și sunt acordate integral sau deloc (nu parțial).

---

## PENALIZĂRI

### Întârzieri

| Întârziere | Penalizare |
|------------|------------|
| < 1 oră | -0% (avertisment) |
| 1-24 ore | -10% |
| 24-72 ore | -25% |
| 72h - 7 zile | -50% |
| > 7 zile | Nu se primește |

### Probleme Tehnice

| Problemă | Penalizare |
|----------|------------|
| Nu compilează/rulează | -30% |
| Lipsă README.md | -15% |
| Lipsă teste complet | -10% |
| Erori ShellCheck severe | -5% |
| Hardcoded paths | -5% |
| Fișiere binare în repo | -5% |

### Plagiat și Integritate Academică

| Situație | Consecință |
|----------|------------|
| Cod identic cu coleg | -100% (ambii) + raport |
| Cod de pe internet necitat | -50% prima abatere |
| Recidivă | Exmatriculare propusă |

---

## FORMULAR EVALUARE

```
╔══════════════════════════════════════════════════════════════════╗
║           EVALUARE PROIECT SEMESTRU - SISTEME DE OPERARE         ║
╠══════════════════════════════════════════════════════════════════╣
║ Student:     ________________________________________________    ║
║ Proiect:     ________________________________________________    ║
║ Data:        ________________________________________________    ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║ 1. FUNCȚIONALITATE (40%)                                         ║
║    ├─ Cerințe obligatorii (30%):     _____ × 0.30 = _____       ║
║    └─ Cerințe opționale (10%):       _____ × 0.10 = _____       ║
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
║    ├─ Docs tehnice (4%):             _____ × 0.04 = _____       ║
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
║    □ Alte:                                     -_____%           ║
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

## CHECKLIST EVALUARE RAPIDĂ

```
Pre-evaluare (automată):
□ Arhiva corect denumită
□ Structura de fișiere respectată
□ README.md prezent
□ Scripturi au shebang
□ bash -n trece fără erori
□ ShellCheck fără erori critice

Evaluare funcțională:
□ Instalare după INSTALL.md funcționează
□ Comanda de help funcționează
□ Scenariul principal funcționează
□ Edge cases tratate
□ Erori raportate clar

Evaluare calitativă:
□ Cod lizibil și comentat
□ Funcții modularizate
□ Variabile denumite descriptiv
□ Teste prezente și trec
□ Documentație completă

Prezentare:
□ Student poate rula proiectul
□ Student explică arhitectura
□ Student răspunde la întrebări despre cod
```

---

*Rubrica Universală - Proiecte SO | Ianuarie 2025*
