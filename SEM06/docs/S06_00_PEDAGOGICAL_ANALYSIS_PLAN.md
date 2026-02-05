# Analiză pedagogică și plan — CAPSTONE SEM06

> **Sisteme de Operare** | ASE București - CSIE  
> Seminarul 6: Proiecte integrate (Monitor, Backup, Deployer)

---

## Scopul documentului

Acest document mapează strategia pedagogică pentru seminarul CAPSTONE. Spre deosebire de săptămânile anterioare, în care studenții au lucrat pe concepte izolate, SEM06 le combină pe toate — iar acesta este obiectivul.

> **Notă de laborator:** Studenții subestimează constant complexitatea integrării. Un script care funcționează izolat se poate defecta atunci când este combinat cu altele. Alocați timp pentru depanarea „codului de legătură”.

---

## 1. Analiza publicului

### 1.1 Prerechizite

Studenții care ajung la CAPSTONE ar trebui să aibă:

| Competență | Sursă | Verificare |
|-------|--------|--------------|
| Fundamente Bash (variabile, bucle, condiționale) | SEM01-02 | Quiz q01-03 |
| Operații pe fișiere și permisiuni | SEM02-03 | Quiz q04 |
| Elemente de bază despre managementul proceselor | SEM03-04 | Quiz q05 |
| Prelucrare text (grep, sed, awk) | SEM04 | Exerciții de tip sprint |
| Pattern‑uri de scripting de bază | SEM05 | Finalizarea temelor |

### 1.2 Lacune tipice

Din cohorte anterioare, urmăriți:

- **Disciplina ghilimelelor** — rămâne sursa principală de erori. Studenții cunosc regulile, dar le omit sub presiune.
- **Conștientizarea codurilor de ieșire** — mulți studenți ignoră în continuare `$?` și se întreabă de ce scripturile „eșuează aleator”.
- **Gestionarea căilor** — căile hardcodate funcționează pe sistemul lor și se defectează în alte medii.

> **Intervenție rapidă:** începeți sesiunea cu un exercițiu de 2 minute „identifică eroarea”, folosind variabile neîncadrate în ghilimele. Captează imediat atenția.

---

## 2. Alinierea obiectivelor de învățare

### 2.1 Distribuția pe taxonomia Bloom

CAPSTONE mută intenționat accentul spre procese cognitive de nivel superior:

```
Remember    ████░░░░░░░░░░░░░░░░  18%  (foundation recall)
Understand  █████░░░░░░░░░░░░░░░  25%  (concept explanation)
Apply       ███████░░░░░░░░░░░░░  35%  (implementation)
Analyse     ██░░░░░░░░░░░░░░░░░░  12%  (debugging, trade-offs)
Evaluate    ██░░░░░░░░░░░░░░░░░░   8%  (design decisions)
Create      █░░░░░░░░░░░░░░░░░░░   2%  (novel solutions)
```

Aceasta corespunde așteptărilor de tip capstone: studenții *aplică* ce au învățat, în timp ce încep să *analizeze* și să *evalueze* alegeri de proiectare.

### 2.2 Rezultate ale învățării

| ID | Rezultat | Nivel cognitiv | Verificabil |
|----|---------|-----------------|------------|
| LO6.1 | Proiectează o arhitectură modulară pentru scripturi Bash | Create | Da |
| LO6.2 | Implementează tratarea erorilor cu trap și coduri de ieșire | Apply | Da |
| LO6.3 | Construiește un sistem de jurnalizare cu niveluri de severitate | Apply | Da |
| LO6.4 | Citește și interpretează date din /proc | Understand | Da |
| LO6.5 | Implementează backup incremental cu find -newer | Apply | Da |
| LO6.6 | Verifică integritatea datelor cu checksums | Apply | Da |
| LO6.7 | Aplică strategii de deployment (rolling, blue-green) | Apply | Da |
| LO6.8 | Implementează health checks cu retry și backoff | Apply | Da |
| LO6.9 | Scrie teste unitare pentru funcții Bash | Create | Da |
| LO6.10 | Automatizează sarcini cu cron/systemd timers | Apply | Da |
| LO6.11 | Depanează scripturi folosind set -x și strace | Analyse | Da |
| LO6.12 | Evaluează trade-off‑uri în decizii de proiectare | Evaluate | Parțial |

---

## 3. Structura sesiunii

### 3.1 Alocarea timpului (100 minute)

| Fază | Durată | Activitate | Scop |
|-------|----------|----------|---------|
| Hook | 8 min | Scenariul „Server crash la 3 AM” | Angajare, relevanță |
| Peer Instruction | 12 min | PI-01, PI-02 (variabile, ghilimele) | Evidențierea concepțiilor greșite |
| Live Coding | 20 min | Construirea scheletului Monitor | Exemplu lucrat |
| Sprint | 10 min | Curățare cu trap (în perechi) | Practică activă |
| Pauză | 5 min | — | Reset cognitiv |
| Demo | 15 min | Backup incremental | Demonstrație de concept |
| Parsons | 12 min | PP-01, PP-02 | Practică de ordonare a codului |
| Discuție | 10 min | Strategii de deployment | Gândire de nivel superior |
| Autoevaluare | 5 min | Checklist + exit ticket | Metacogniție |
| Încheiere | 3 min | Brief pentru temă | Închidere |

### 3.2 Note de ritm

- **Prima jumătate:** energie mai mare, structură mai rigidă. Studenții sunt proaspeți.
- **După pauză:** treceți la discuție și rezolvare de probleme. Atenția scade.
- **Ultimele 15 minute:** nu introduceți concepte noi. Consolidați.

> **Experiență:** am încercat cândva să explic blue-green deployment în ultimele 5 minute. Jumătate din clasă a plecat confuză. Acum este ferm în segmentul „înainte de pauză”.

---

## 4. Strategii de învățare activă

### 4.1 Protocol Peer Instruction

1. Prezentați un snippet de cod (1 min)
2. Vot individual — fără discuție (1 min)
3. Discuție în perechi — „convinge‑ți colegul” (3 min)
4. Re-vot (30 sec)
5. Explicația instructorului (2 min)

Țintă: 35–70% corect la primul vot. Sub 35%? Conceptul necesită re‑predare. Peste 70%? Accelerați.

### 4.2 Protocol pentru exerciții de tip sprint

- În perechi, nu individual (reduce frustrarea)
- Limită strictă de timp (5–7 min)
- Timer vizibil
- „Suficient de bine” este preferabil „perfect”
- Faceți publică analiza greșelilor frecvente

### 4.3 Probleme de tip Parsons

De ce funcționează pentru Bash:
- Sintaxa Bash este neiertătoare. Ordine greșită = eșec imediat.
- Distractorii scot la iveală greșeli comune (spații la atribuire, ghilimele lipsă).
- Încărcare cognitivă mai mică decât scrierea de la zero.

---

## 5. Strategia de evaluare

### 5.1 Formativ (în timpul sesiunii)

| Punct de control | Timp | Metodă | LO vizat |
|------------|------|--------|-------------|
| Atribuirea variabilelor | 0:15 | Întrebare directă | LO6.2 |
| Sintaxa trap | 0:35 | Thumbs up/down | LO6.2 |
| Utilizarea find -newer | 1:05 | Sondaj rapid | LO6.5 |
| Compararea strategiilor | 1:25 | Discuție | LO6.7, LO6.12 |

### 5.2 Sumativ (temă + prezentare)

- **Pondere temă:** 60% din nota seminarului
- **Pondere prezentare:** 40% din nota seminarului
- **Locație rubrică:** `homework/S06_02_EVALUATION_RUBRIC.md`

---

## 6. Diferențiere

### 6.1 Studenți cu dificultăți

- Concentrați-vă doar pe proiectul Monitor
- Oferiți cod-schelet pentru modificare
- Lucrați în pereche cu un student mai avansat
- Reduceți domeniul exercițiilor de tip sprint

### 6.2 Studenți avansați

- Provocare: combinați blue-green + canary
- Adăugați output JSON în Monitor
- Implementați exponential backoff
- Scrieți teste property‑based

---

## 7. Checklist de materiale

Înainte de sesiune:

- [ ] Terminal Ubuntu accesibil (WSL2 sau VM)
- [ ] `shellcheck` instalat
- [ ] Fișierele proiectului extrase în `/home/student/SEM06`
- [ ] `/proc/stat` lizibil (ar trebui să fie întotdeauna)
- [ ] Proiector pentru live coding
- [ ] Timer vizibil pentru Peer Instruction

---

## 8. Șablon de reflecție post-sesiune

### Ce a funcționat

(Completați după fiecare livrare a sesiunii)

### Ce trebuie îmbunătățit

(Completați după fiecare livrare a sesiunii)

### Întrebări ale studenților de adresat data viitoare

(Capturați întrebările la care nu ați putut răspunde complet)

---

## Referințe

- Anderson, L.W. & Krathwohl, D.R. (2001). *A Taxonomy for Learning, Teaching, and Assessing*
- Mazur, E. (1997). *Peer Instruction: A User's Manual*
- Brown & Wilson (2018). *Ten Quick Tips for Teaching Programming*
- Parsons, D. & Haden, P. (2006). *Parson's Programming Puzzles*

---

*Analiză pedagogică pentru SEM06 CAPSTONE — Sisteme de Operare*  
*ASE București - CSIE | 2024-2025*
