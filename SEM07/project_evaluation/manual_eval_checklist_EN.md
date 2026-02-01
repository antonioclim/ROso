# Checklist pentru evaluare manuală

> **Sisteme de Operare** | ASE Bucharest - CSIE  
> Evaluarea proiectului - SEM07

---

## Prezentare generală

Evaluarea manuală reprezintă **15%** din scorul proiectului (1,5 puncte din 10).

Această listă de verificare ghidează cadrele didactice prin aspectele subiective ale evaluării proiectului, care nu pot fi automatizate.

---

## 1. Experiența utilizatorului (0,5 puncte)

### 1.1 Claritatea interfeței

| Criteriu | 0 | 0.1 | 0.2 |
|-----------|---|-----|-----|
| Mesaj de help | Absent | Minimal | Cuprinzător |
| Mesaje de eroare | Criptice | Acceptabile | Clare și acționabile |
| Indicație de progres | Absentă | Minimală | Detaliată |
| Formatarea output‑ului | Dezordonată | Lizibilă | Bine structurată |

**Întrebări de urmărit:**
- [ ] Este evident cum se utilizează instrumentul?
- [ ] Mesajele de eroare ajută utilizatorul să remedieze problema?
- [ ] Output‑ul este ușor de citit și înțeles?
- [ ] Instrumentul oferă feedback în timpul operațiilor lungi?

### 1.2 Uzabilitate

| Criteriu | 0 | 0.05 | 0.1 |
|-----------|---|------|-----|
| Valori implicite | Absente/slabe | Rezonabile | Optime |
| Confirmări | Lipsesc când sunt necesare | Prezente | Nivel adecvat |
| Shortcut‑uri tastatură | Absente | Unele | Cuprinzătoare |
| Configurare | Hard‑codată | Fișier de configurare | Multiple opțiuni |

**Note de punctare:**
- Acordați punctaj maxim dacă un utilizator la prima utilizare poate folosi instrumentul eficient.
- Depunctați dacă este necesară citirea extensivă a documentației pentru o utilizare de bază.

---

## 2. Eleganța codului (0,5 puncte)

### 2.1 Lizibilitate

| Criteriu | 0 | 0.1 | 0.2 |
|-----------|---|-----|-----|
| Nume variabile | O singură literă | Descriptive | Auto‑explicative |
| Nume funcții | Neclare | Acceptabile | Model verb–substantiv |
| Organizare cod | Monolitică | Structură parțială | Modularizare bună |
| Comentarii | Absente | De bază | Explică „de ce”, nu „ce” |

**Checklist pentru code review:**
- [ ] Puteți înțelege o funcție fără a-i citi implementarea?
- [ ] „Numerele magice” sunt explicate sau denumite?
- [ ] Logica complexă este împărțită în funcții mai mici?
- [ ] Comentariile adaugă valoare peste cod?

### 2.2 Bune practici

| Criteriu | 0 | 0.05 | 0.1 |
|-----------|---|------|-----|
| Quoting | Inconsecvent | În general corect | Întotdeauna corect |
| Tratarea erorilor | Lipsește | Minimală | Cuprinzătoare |
| Strict mode | Neutilizat | Parțial | Complet (set -euo pipefail) |
| Shellcheck | Multe avertismente | Puține avertismente | Curat |

### 2.3 Coerență

| Criteriu | 0 | 0.05 | 0.1 |
|-----------|---|------|-----|
| Convenție de denumire | Stiluri amestecate | În general consecvent | Complet consecvent |
| Indentare | Inconsecventă | Preponderent 4 spații | Consecventă |
| Stil acolade | Amestecat | Consecvent | Consecvent + documentat |
| Stil ghilimele | Amestecat | În general consecvent | Consecvent |

---

## 3. Inovație și elemente extra (0,5 puncte)

### 3.1 Dincolo de cerințe

| Funcționalitate extra | Puncte |
|---------------|--------|
| Output color‑codificat | +0.05 |
| Mod interactiv | +0.05 |
| Completare cu Tab | +0.1 |
| Man page | +0.1 |
| Script de completare Bash | +0.1 |
| Suită de teste cuprinzătoare | +0.1 |
| Optimizare de performanță | +0.1 |
| Întărire de securitate | +0.1 |

**Maximum din extra‑uri: 0,5 puncte**

### 3.2 Soluții creative

Acordați punctaj suplimentar pentru:
- abordări noi ale problemelor;
- algoritmi eleganți;
- decizii de arhitectură bine motivate;
- documentație excepțională.

**Notă:** punctajul pentru inovație este la latitudinea evaluatorului și trebuie justificat în comentarii.

---

## 4. Calitatea documentației

### 4.1 Evaluarea README.md

| Secțiune | Obligatoriu | Puncte |
|---------|----------|--------|
| Titlul și descrierea proiectului | Da | Inclus în auto‑eval |
| Instrucțiuni de instalare | Da | Inclus în auto‑eval |
| Exemple de utilizare | Da | +0.05 dacă este excepțional |
| Capturi/demonstrații | Recomandat | +0.05 |
| Prezentare arhitectură | Opțional | +0.05 |
| Ghid de contribuție | Opțional | +0.025 |
| Licență | Obligatoriu | Inclus în auto‑eval |

### 4.2 Documentația codului

| Aspect | Slab | Acceptabil | Bun |
|--------|------|----------|------|
| Headere de funcții | Absente | Parametri listați | Docstring complet |
| Logică complexă | Fără explicație | Comentariu scurt | Explicație detaliată |
| Configurare | Nedocumentată | Comentarii inline | Document separat |

---

## 5. Șablon de formular de evaluare

```markdown
# Manual Evaluation: [Project Name]
**Student/Team:** [Name(s)]
**Evaluator:** [Instructor Name]
**Date:** [Date]

## 1. User Experience (0.5 max)
- Interface clarity: ___ / 0.2
- Usability: ___ / 0.1
- Error handling UX: ___ / 0.1
- Overall polish: ___ / 0.1

**Comments:**
[Write observations here]

**Subtotal:** ___ / 0.5

## 2. Code Elegance (0.5 max)
- Readability: ___ / 0.2
- Best practices: ___ / 0.1
- Consistency: ___ / 0.1
- Architecture: ___ / 0.1

**Comments:**
[Write observations here]

**Subtotal:** ___ / 0.5

## 3. Innovation (0.5 max)
- Extra features: ___ / 0.3
- Creative solutions: ___ / 0.2

**Features noted:**
- [ ] Feature 1
- [ ] Feature 2

**Subtotal:** ___ / 0.5

## Summary
| Component | Score |
|-----------|-------|
| User Experience | ___ / 0.5 |
| Code Elegance | ___ / 0.5 |
| Innovation | ___ / 0.5 |
| **TOTAL** | ___ / 1.5 |

## Overall Comments
[Final remarks, suggestions for improvement]

## Red Flags
- [ ] None
- [ ] Potential plagiarism indicators
- [ ] Mismatched code style suggesting multiple authors
- [ ] Other: _______________
```

---

## 6. Ghid de calibrare

### 6.1 Proiecte de referință

Înainte de evaluare, revedeți aceste implementări de referință:
- **Exemplară (1.4-1.5):** curată, bine documentată, extra‑uri utile
- **Bună (1.0-1.3):** implementare solidă, probleme minore
- **Acceptabilă (0.7-0.9):** funcțională, dar cu muchii aspre
- **Slabă (0.3-0.6):** rulează, dar cu probleme semnificative
- **Nepromovabilă (0-0.2):** probleme majore

### 6.2 Capcane uzuale

**Supra‑evaluare:**
- funcționalități impresionante, dar calitate slabă a codului;
- README bun, dar cod dezordonat;
- soluție excesiv de complexă atunci când una simplă ar fi suficientă.

**Sub‑evaluare:**
- soluție simplă, dar elegantă;
- interfață minimalistă care funcționează bine;
- cod care „pur și simplu funcționează”, fără elemente spectaculoase.

---

## 7. Indicatori de plagiat

### 7.1 Similaritate de cod

Urmăriți:
- nume identice de variabile între studenți fără legătură;
- aceleași abordări neobișnuite sau aceleași bug‑uri;
- comentarii care nu corespund nivelului de engleză al studentului;
- inconsecvențe de stil în același proiect.

### 7.2 Acțiuni

| Constatare | Acțiune |
|---------|--------|
| Similaritate minoră | Notați pentru susținerea orală |
| Similaritate semnificativă | Comparați cu sursa, întrebați ambii |
| Plagiat clar | Aplicați procedura de integritate academică |

---

## 8. Checklist final

Înainte de a salva evaluarea manuală:

- [ ] Toate cele trei secțiuni sunt punctate
- [ ] Comentarii pentru fiecare secțiune
- [ ] Total calculat corect
- [ ] Orice „red flags” sunt documentate
- [ ] Formularul este salvat în evidențe
- [ ] Dacă există îngrijorări, sunt notate pentru follow‑up la susținerea orală

---

*De Revolvix pentru disciplina OPERATING SYSTEMS | licență restricționată 2017-2030*
