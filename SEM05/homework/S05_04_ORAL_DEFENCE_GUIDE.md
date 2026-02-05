# S05_04 — Protocol pentru susținerea orală (Viva)

> Seminar 5: Scripting Bash avansat  
> Versiune: 1.0.0 | Data: ianuarie 2025

---

## Scop și rațiune

Susținerea orală pentru tema SEM05 este obligatorie și reprezintă **20%** din nota finală.

**De ce există această componentă:**

- verifică dacă studentul **înțelege** codul pe care l-a predat
- descurajează plagiatul și utilizarea neasumată a instrumentelor AI
- confirmă că studentul poate **modifica live** scripturile și poate gestiona cazuri-limită reale

---

## Prezentare generală a structurii

**Durată per student:** 5–10 minute  
**Format:** discuție ghidată + demonstrație live

**Trei faze:**

1. **Walkthrough cod (40%)** — studentul explică o funcție cheie
2. **Modificare live (40%)** — studentul implementează o schimbare mică
3. **Discuție edge cases (20%)** — studentul răspunde la întrebări despre robustețe

---

## Faza 1: Walkthrough cod (40%)

### Procedură

1. Alegeți **un script** (R1 / R2 / R3)
2. Alegeți **o funcție** din script (ideal: una critică, ex. `parse_line`, `load_config`, `save_config`)
3. Cereți studentului să explice:
   - input-uri și output-uri
   - fluxul logic
   - de ce anumite alegeri au fost făcute (ex. arrays asociative, quoting, `local`)

### Ce să urmăriți

Studentul ar trebui să:

- identifice rapid unde este implementată logica
- explice ce reprezintă variabilele
- poată urmări o ramură logică (if/for/case)
- înțeleagă tiparele Bash (quoting, arrays, `set -euo`, `trap`)

### Întrebări exemplu

```bash
- "Show me where you parse a log line. What fields do you extract?"
- "Why did you use an associative array here?"
- "What happens if the input file is missing?"
- "Explain the difference between $@ and $*."
- "Why do we need quotes around ${arr[@]}?"
```

### Semnale de alarmă

- studentul „citește” codul fără a-l explica
- nu poate descrie rolul variabilelor
- nu știe de ce există o funcție sau ce output produce
- răspunsuri generice („așa am văzut în exemplu”, „așa e standard”)

---

## Faza 2: Modificare live (40%)

### Procedură

1. Cereți o schimbare mică, dar care necesită înțelegere reală
2. Studentul modifică codul în timp real
3. Studentul rulează (sau descrie) un test minimal
4. Evaluați atât corectitudinea, cât și stilul (quoting, `local`, robustețe)

### Bancă de modificări

#### Tier 1 — Ușor (1–2 minute)

```
"Add a --version flag that prints '1.0.0'"
"Add a check that the input file is not empty"
"Change the default TOP_N from 5 to 10"
```


#### Tier 2 — Mediu (2–3 minute)

```
"Add a --quiet flag that suppresses all output except errors"
"Make the script accept multiple input files"
"Add a timestamp to each log message your script produces"
```


#### Tier 3 — Greu (3–5 minute)

```
"Add trap for SIGINT that asks 'Are you sure?' before exiting"
"Change LEVEL_COUNT to use a regular array with enum-style indices"
"Add a --dry-run flag that shows what would happen without doing it"
```


### Criterii de evaluare

Studentul:

- știe unde să modifice
- scrie corect sintactic
- nu introduce bug-uri noi evidente
- rulează un test simplu (sau poate justifica verificarea)

---

## Faza 3: Discuție despre cazuri-limită (20%)

### Procedură

1. Alegeți 1–2 întrebări bazate pe scriptul studentului
2. Cereți răspunsuri concise, dar tehnic corecte
3. Evaluați maturitatea abordării: validare, output clar, comportament determinist

### Bancă de întrebări

```bash
- "What happens if the log contains invalid lines?"
- "What if the message contains brackets [] or extra spaces?"
- "What if the config file has duplicate keys?"
- "How do you handle values with spaces around '='?"
- "Why doesn't set -e always stop the script?"
```

### Evaluare

Studentul ar trebui să:

- identifice problema
- propună o soluție rezonabilă
- arate că înțelege limitele Bash (ex. `set -e`)

---

## Protocol pentru examinare la distanță

### Configurație tehnică

- share screen + terminal
- audio clar
- (dacă se poate) cameră pornită

### Procedură adaptată

- cereți studentului să ruleze comenzi live (nu doar să arate fișiere)
- folosiți o modificare foarte mică, realizabilă în 2–3 minute
- puneți întrebări scurte, punctuale

### Verificare „low-tech”

Când nu există proctoring:

- cereți o modificare mică fără copy/paste
- cereți explicația unui bloc ales aleator
- (opțional, dacă politica locală permite) cereți un fragment de istoric al terminalului

---

## Matrice de scorare

### Rubrică holistică

| Notă | Walkthrough cod | Modificare live | Edge cases | Impresie generală |
|-------|------------------|-------------------|------------|-------------------|
| **A (90-100%)** | Fluent, cu insight | Reușește independent | Anticipează probleme | Deține clar lucrarea |
| **B (75-89%)** | Competent | Reușește cu mici indicații | Identifică probleme | Autentic, cu mici lacune |
| **C (60-74%)** | Ezitant dar corect | Implementare parțială | Are nevoie de prompting | Înțelege baza |
| **D (50-59%)** | Se chinuie semnificativ | Nu poate finaliza | Conștientizare limitată | Lacune îngrijorătoare |
| **F (<50%)** | Nu își poate explica codul | Nicio încercare relevantă | Fără implicare | Suspect non-autentic |

### Calcul scor

```
Oral Defence Score = (Walkthrough × 0.4) + (Modification × 0.4) + (EdgeCases × 0.2)

Final Assignment Score = (Written Submission × 0.8) + (Oral Defence × 0.2)
```

---

## Gestionarea predărilor suspecte de AI

### În timpul susținerii

**Nu acuzați direct.** În schimb:

1. puneți întrebări din ce în ce mai specifice despre alegerile de implementare
2. cereți o modificare care necesită înțelegerea logicii existente
3. notați observațiile factual: „Studentul nu a putut explica regex-ul de la linia 34”

### După susținere

1. documentați instanțe concrete de incapacitate de a explica
2. comparați calitatea explicației verbale cu calitatea comentariilor din cod
3. verificați „anachronisms” (construcții nepredate încă)
4. consultați colegi dacă există incertitudine

### Prag de evidență pentru sesizare pe integritate academică

Sesizați către comisie dacă **TREI SAU MAI MULTE** dintre următoarele sunt adevărate:
- nu poate explica algoritmul de bază
- folosește terminologie inconsistentă cu vocabularul său verbal
- stilul codului diferă dramatic de exercițiile din clasă
- încercarea de modificare arată necunoașterea structurii propriului cod
- comentariile fac referire la concepte neacoperite în curs

---

## Programare și logistică

### Alocare de timp

| Dimensiune grupă | Timp total necesar | Recomandare |
|------------|-------------------|----------------|
| 15 studenți | ~2 ore | O singură sesiune |
| 25 studenți | ~3.5 ore | Împărțiți în 2 sesiuni |
| 30+ studenți | ~4+ ore | Folosiți asistenți pentru susțineri paralele |

### Checklist de pregătire

- [ ] randomizați ordinea studenților (evitați alfabeticul — cei de la final învață din susținerile de dinainte)
- [ ] pregătiți întrebări de modificare (minim 3 pe nivel)
- [ ] testați că lucrările rulează efectiv
- [ ] aveți întrebări de rezervă pentru cod care nu rulează
- [ ] configurați înregistrare dacă e online
- [ ] aliniați asistenții cu criteriile de evaluare

---

## Anexă: Card rapid de referință

Tipăriți aceasta pentru utilizare în susțineri:

```
┌─────────────────────────────────────────────────────────────────┐
│                    ORAL DEFENCE QUICK REFERENCE                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  PHASE 1 (2-3 min): "Walk me through [function]"                │
│    ✓ Explains variable names                                    │
│    ✓ Describes logic flow                                       │
│    ✓ Justifies error handling                                   │
│                                                                 │
│  PHASE 2 (2-3 min): "Add [feature] now"                         │
│    ✓ Knows where to modify                                      │
│    ✓ Correct syntax                                             │
│    ✓ Tests the change                                           │
│                                                                 │
│  PHASE 3 (1-2 min): "What if [edge case]?"                      │
│    ✓ Identifies the problem                                     │
│    ✓ Suggests mitigation                                        │
│                                                                 │
│  RED FLAGS:                                                     │
│    ✗ Reads code without understanding                           │
│    ✗ "I found this online"                                      │
│    ✗ Cannot make trivial changes                                │
│    ✗ Style mismatch: perfect code, broken explanations          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Istoric document

| Versiune | Dată | Modificări |
|---------|------|---------|
| 1.0.0 | Ian 2025 | Versiune inițială, bazată pe experiența 2023–2024 |

---

*Instructor: ing. dr. Antonio Clim | ASE București — CSIE*
