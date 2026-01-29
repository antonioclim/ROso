# Evaluare Generală - Proiecte de Semestru

> **Document pentru Studenți și Instructori**  
> **Sisteme de Operare** | ASE București - CSIE

---

## Filozofia Evaluării

Evaluarea proiectelor urmărește să verifice **înțelegerea profundă** a conceptelor de sisteme de operare și capacitatea de a le **aplica în practică**. Nu căutăm cod perfect, ci demonstrarea competențelor dobândite.

---

## Criterii de Evaluare

### 1. Funcționalitate (40%)

| Nivel | Procent | Descriere |
|-------|---------|-----------|
| Excelent | 100% | Toate cerințele implementate, funcționează fără erori |
| Foarte Bine | 85% | Cerințele principale complete, erori minore |
| Bine | 70% | Majoritatea cerințelor, unele lipsuri |
| Satisfăcător | 55% | Cerințele de bază, funcționalitate limitată |
| Insuficient | 30% | Funcționează parțial |
| Neacceptabil | 0% | Nu rulează sau lipsește |

**Ce verificăm:**
- ✅ Scriptul principal rulează fără erori
- ✅ Toate cerințele obligatorii sunt implementate
- ✅ Edge cases sunt tratate corespunzător
- ✅ Comportament corect în condiții normale și de eroare

### 2. Calitate Cod (20%)

| Aspect | Pondere | Criterii |
|--------|---------|----------|
| Structură | 5% | Modularitate, organizare fișiere |
| Claritate | 5% | Cod lizibil, variabile descriptive |
| Best Practices | 5% | ShellCheck clean, `set -euo pipefail` |
| Eficiență | 5% | Fără redundanțe, algoritmi rezonabili |

**Checklist calitate:**
```bash
# Verificare ShellCheck
shellcheck -x src/*.sh

# Verificare sintaxă
bash -n src/main.sh

# Verificare structură
tree -L 2 .
```

### 3. Documentație (15%)

| Document | Pondere | Conținut Necesar |
|----------|---------|------------------|
| README.md | 8% | Descriere, instalare, utilizare, exemple |
| INSTALL.md | 3% | Dependențe, pași instalare |
| Comentarii cod | 4% | Funcții documentate, logică explicată |

**README.md minim:**
- Titlu și descriere proiect
- Cerințe sistem (dependențe)
- Instrucțiuni instalare
- Exemple de utilizare
- Structura proiectului
- Autor și licență

### 4. Teste Automatizate (15%)

| Acoperire | Procent |
|-----------|---------|
| > 80% funcționalități testate | 100% |
| 60-80% | 80% |
| 40-60% | 60% |
| 20-40% | 40% |
| < 20% | 20% |

**Structură teste recomandată:**
```bash
tests/
├── test_main.sh          # Teste funcționalitate principală
├── test_edge_cases.sh    # Teste cazuri limită
├── test_error_handling.sh # Teste gestionare erori
└── run_all.sh            # Runner pentru toate testele
```

### 5. Prezentare (10%)

| Aspect | Pondere |
|--------|---------|
| Demonstrație funcțională | 4% |
| Explicarea codului | 3% |
| Răspunsuri la întrebări | 3% |

---

## Bonusuri

### Extensie Kubernetes (+10%)

Disponibil pentru proiecte MEDIUM. Cerințe:
- Deployment funcțional în Kubernetes (minikube acceptat)
- Fișiere YAML pentru deployment, service, configmap
- Documentație deployment K8s

### Componentă C (+15%)

Pentru orice proiect. Cerințe:
- Modul C compilabil care extinde funcționalitatea
- Integrare corectă cu scripturile Bash
- Makefile pentru compilare

### CI/CD Pipeline (+5%)

- GitHub Actions sau GitLab CI funcțional
- Rulare automată teste la push
- Badge status în README

### Documentație Video (+5%)

- Video demonstrativ 3-5 minute
- Arată funcționalitatea principală
- Calitate audio/video acceptabilă

---

## Penalizări

### Întârzieri

| Întârziere | Penalizare |
|------------|------------|
| < 1 oră | Avertisment |
| 1-24 ore | -10% |
| 24-72 ore | -25% |
| 72h - 1 săptămână | -50% |
| > 1 săptămână | Neprimit |

### Probleme Tehnice

| Problemă | Penalizare |
|----------|------------|
| Nu compilează/rulează | -30% |
| Lipsă README | -15% |
| Lipsă teste | -10% |
| ShellCheck errors severe | -5% |
| Hardcoded paths | -5% |

### Plagiat

| Situație | Consecință |
|----------|------------|
| Cod copiat de la colegi | -100% (ambii studenți) |
| Cod copiat de pe internet fără citare | -50% prima abatere |
| Recidivă plagiat | Raport disciplinar |

**Observație:** Folosirea AI (ChatGPT, Claude, etc.) este permisă pentru **învățare și debugging**, dar codul final trebuie înțeles complet și explicat la prezentare.

---

## Proces de Evaluare

### Etapa 1: Verificare Automată

```bash
# Script de validare rulat automat
./helpers/project_validator.sh student_project/

# Verifică:
# - Structura de fișiere
# - Sintaxă scripturi
# - ShellCheck
# - Prezența documentației
```

### Etapa 2: Evaluare Funcțională

Instructorul rulează proiectul pe un sistem curat:
1. Clonare repository
2. Urmărire INSTALL.md
3. Rulare teste automate
4. Testare manuală scenarii

### Etapa 3: Code Review

- Verificare calitate cod
- Verificare originalitate
- Verificare comentarii și documentație

### Etapa 4: Prezentare

- Demonstrație live (5-10 min)
- Explicarea arhitecturii (3-5 min)
- Întrebări (5 min)

---

## Formular Evaluare

```
EVALUARE PROIECT SO
==================

Student: ___________________
Proiect: ___________________
Data: ___________________

FUNCȚIONALITATE (40%)
---------------------
□ Cerințe obligatorii:    ___/100 × 0.30 = ___
□ Cerințe opționale:      ___/100 × 0.10 = ___
Subtotal: ___

CALITATE COD (20%)
------------------
□ Structură:              ___/100 × 0.05 = ___
□ Claritate:              ___/100 × 0.05 = ___
□ Best practices:         ___/100 × 0.05 = ___
□ Eficiență:              ___/100 × 0.05 = ___
Subtotal: ___

DOCUMENTAȚIE (15%)
------------------
□ README.md:              ___/100 × 0.08 = ___
□ Instalare:              ___/100 × 0.03 = ___
□ Comentarii:             ___/100 × 0.04 = ___
Subtotal: ___

TESTE (15%)
-----------
□ Acoperire:              ___/100 × 0.15 = ___
Subtotal: ___

PREZENTARE (10%)
----------------
□ Demo:                   ___/100 × 0.04 = ___
□ Explicații:             ___/100 × 0.03 = ___
□ Întrebări:              ___/100 × 0.03 = ___
Subtotal: ___

BONUSURI
--------
□ Kubernetes:             +___
□ Componentă C:           +___
□ CI/CD:                  +___
□ Video:                  +___
Total bonusuri: +___

PENALIZĂRI
----------
□ Întârziere:             -___
□ Probleme tehnice:       -___
□ Alte:                   -___
Total penalizări: -___

================================
TOTAL FINAL: ___/100 (+ bonusuri - penalizări)
================================

Comentarii:
___________________________________________
___________________________________________

Semnătură evaluator: ___________________
```

---

## Sfaturi pentru Nota Maximă

1. **Începe devreme** - timpul trece repede
2. **Testează constant** - nu lăsa testele pe final
3. **Documentează pe parcurs** - e mai ușor decât la final
4. **Folosește version control** - commit-uri frecvente și descriptive
5. **Cere feedback** - la consultații, înainte de deadline
6. **Citește cerințele atent** - de mai multe ori
7. **Fă mai mult decât minimul** - diferențiază-te

---

*Document actualizat: Ianuarie 2025*
