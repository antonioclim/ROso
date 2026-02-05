# Evaluare Generală - Proiecte de Semestru

> **Document pentru Studenți și Instructori**  
> **Sisteme de Operare** | ASE București - CSIE

---

## Filosofia Evaluării

Evaluarea proiectului urmărește să verifice **înțelegerea profundă** a conceptelor de sisteme de operare și capacitatea de a **le aplica în practică**. Nu căutăm cod perfect, ci mai degrabă o demonstrație a competențelor dobândite.

> 💡 **Ce caut eu de fapt:** Poți explica ce face codul tău? Înțelegi *de ce* funcționează, nu doar *că* funcționează? Am văzut studenți cu cod imperfect primind note mai mari decât cei cu cod "perfect" pe care nu îl puteau explica.

---

## Criterii de Evaluare

### 1. Funcționalitate (40%)

| Nivel | Procent | Descriere |
|-------|------------|-------------|
| Excelent | 100% | Toate cerințele implementate, funcționează fără erori |
| Foarte Bun | 85% | Cerințe principale complete, erori minore |
| Bun | 70% | Majoritatea cerințelor îndeplinite, unele lacune |
| Satisfăcător | 55% | Cerințe de bază, funcționalitate limitată |
| Insuficient | 30% | Funcțional parțial |
| Inacceptabil | 0% | Nu rulează sau lipsește |

**Ce verificăm:**
- ✅ Script-ul principal rulează fără erori
- ✅ Toate cerințele obligatorii sunt implementate
- ✅ Cazurile limită sunt gestionate corespunzător
- ✅ Comportament corect în condiții normale și de eroare

### 2. Calitate Cod (20%)

| Aspect | Pondere | Criterii |
|--------|--------|----------|
| Structură | 5% | Modularitate, organizare fișiere |
| Claritate | 5% | Cod lizibil, variabile descriptive |
| Best Practices | 5% | ShellCheck curat, `set -euo pipefail` |
| Eficiență | 5% | Fără redundanțe, algoritmi rezonabili |

**Checklist calitate:**
```bash
# ShellCheck verification
shellcheck -x src/*.sh

# Syntax verification
bash -n src/main.sh

# Structure verification
tree -L 2 .
```

> ⚠️ **Greșeală comună:** Studenții care sar peste ShellCheck pierd adesea 5-10% pe probleme evitabile. Rulează-l devreme, rulează-l des.

### 3. Documentație (15%)

| Document | Pondere | Conținut Necesar |
|----------|--------|------------------|
| README.md | 8% | Descriere, instalare, utilizare, exemple |
| INSTALL.md | 3% | Dependențe, pași instalare |
| Comentarii cod | 4% | Funcții documentate, logică explicată |

**README.md minim:**
- Titlu proiect și descriere
- Cerințe sistem (dependențe)
- Instrucțiuni instalare
- Exemple de utilizare
- Structură proiect
- Autor și licență

### 4. Teste Automate (15%)

| Acoperire | Procent |
|----------|------------|
| > 80% funcționalități testate | 100% |
| 60-80% | 80% |
| 40-60% | 60% |
| 20-40% | 40% |
| < 20% | 20% |

**Structură recomandată teste:**
```bash
tests/
├── test_main.sh          # Main functionality tests
├── test_edge_cases.sh    # Edge case tests
├── test_error_handling.sh # Error handling tests
└── run_all.sh            # Runner for all tests
```

### 5. Prezentare (10%)

| Aspect | Pondere |
|--------|--------|
| Demonstrație funcțională | 4% |
| Explicație cod | 3% |
| Răspunsuri la întrebări | 3% |

> 💡 **Sfat prezentare:** Voi cere să explici cea mai dificilă parte din codul tău. Cunoaște-o bine. De asemenea, pregătește-te pentru "ce ai face diferit dacă ai reîncepe?"

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
- Integrare corectă cu scripturi Bash
- Makefile pentru compilare

### Pipeline CI/CD (+5%)

- GitHub Actions sau GitLab CI funcțional
- Execuție automată teste la push
- Badge status în README

### Documentație Video (+5%)

- Video demonstrație 3-5 minute
- Prezintă funcționalitatea principală
- Calitate audio/video acceptabilă

---

## Penalizări

### Întârzieri

| Întârziere | Penalizare |
|-------|---------|
| < 1 oră | Avertisment |
| 1-24 ore | -10% |
| 24-72 ore | -25% |
| 72h - 1 săptămână | -50% |
| > 1 săptămână | Nu se acceptă |

> ⚠️ **Reality check:** În fiecare semestru, 2-3 studenți îmi scriu la 23:55 spunând "upload-ul nu funcționează." Începeți upload-ul cel târziu la 22:00.

### Probleme Tehnice

| Problemă | Penalizare |
|-------|---------|
| Nu compilează/rulează | -30% |
| README lipsă | -15% |
| Teste lipsă | -10% |
| Erori ShellCheck severe | -5% |
| Path-uri hardcoded | -5% |

### Plagiat

| Situație | Consecință |
|-----------|-------------|
| Cod copiat de la colegi | -100% (ambii studenți) |
| Cod copiat de pe internet fără citare | -50% prima abatere |
| Plagiat repetat | Raport disciplinar |

**Notă:** Folosirea AI (instrumente de asistență bazate pe inteligență artificială, instrumente de asistență bazate pe inteligență artificială, etc.) este permisă pentru **învățare și debugging**, dar codul final trebuie înțeles complet și explicat în timpul prezentării.

---

## Procesul de Evaluare

### Etapa 1: Verificare Automată

```bash
# Validation script run automatically
./helpers/project_validator.sh student_project/

# Verifies:
# - File structure
# - Script syntax
# - ShellCheck
# - Documentation presence
```

### Etapa 2: Evaluare Funcțională

Instructorul rulează proiectul pe un sistem curat:
1. Clone repository
2. Urmează INSTALL.md
3. Rulează teste automate
4. Testare manuală a scenariilor

### Etapa 3: Revizuire Cod

- Verificare calitate cod
- Verificare originalitate
- Verificare comentarii și documentație

### Etapa 4: Prezentare

- Demonstrație live (5-10 min)
- Explicare arhitectură (3-5 min)
- Întrebări (5 min)

---

## Formular de Evaluare

```
EVALUARE PROIECT SO
=====================

Student: ___________________
Proiect: ___________________
Data: ___________________

FUNCȚIONALITATE (40%)
-------------------
□ Cerințe obligatorii:    ___/100 × 0.30 = ___
□ Cerințe opționale:      ___/100 × 0.10 = ___
Subtotal: ___

CALITATE COD (20%)
------------------
□ Structură:               ___/100 × 0.05 = ___
□ Claritate:               ___/100 × 0.05 = ___
□ Best practices:          ___/100 × 0.05 = ___
□ Eficiență:               ___/100 × 0.05 = ___
Subtotal: ___

DOCUMENTAȚIE (15%)
-------------------
□ README.md:               ___/100 × 0.08 = ___
□ Instalare:               ___/100 × 0.03 = ___
□ Comentarii:              ___/100 × 0.04 = ___
Subtotal: ___

TESTE (15%)
-----------
□ Acoperire:               ___/100 × 0.15 = ___
Subtotal: ___

PREZENTARE (10%)
------------------
□ Demo:                    ___/100 × 0.04 = ___
□ Explicații:              ___/100 × 0.03 = ___
□ Întrebări:               ___/100 × 0.03 = ___
Subtotal: ___

BONUSURI
-------
□ Kubernetes:              +___
□ Componentă C:            +___
□ CI/CD:                   +___
□ Video:                   +___
Total bonusuri: +___

PENALIZĂRI
---------
□ Întârziere:              -___
□ Probleme tehnice:        -___
□ Altele:                  -___
Total penalizări: -___

================================
TOTAL FINAL: ___/100 (+ bonusuri - penalizări)
================================

Comentarii:
___________________________________________
___________________________________________

Semnătura evaluator: ___________________
```

---

## Sfaturi pentru Notă Maximă

1. **Începe devreme** — timpul trece repede
2. **Testează constant** — nu lăsa testele pentru final
3. **Documentează pe parcurs** — este mai ușor decât la final
4. **Folosește control versiuni** — commit-uri frecvente și descriptive
5. **Cere feedback** — la consultații, înainte de deadline
6. **Citește cerințele cu atenție** — de mai multe ori
7. **Fă mai mult decât minimul** — diferențiază-te

> 💡 **Sfat final:** Studenții care primesc cele mai mari note nu sunt întotdeauna cei mai buni programatori. Sunt cei care livrează proiecte complete, bine documentate, la timp. Consistența învinge strălucirea.

---

*Document actualizat: Ianuarie 2025*
