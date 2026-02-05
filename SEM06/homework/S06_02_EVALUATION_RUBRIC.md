# Rubrică de evaluare — Proiecte CAPSTONE

> **Document intern (instructor)** | Seminarul 6 + Prezentarea finală (SEM07)

---

## Legendă pentru sistemul de punctaj

| Simbol | Semnificație | Exemplu |
|--------|--------------|---------|
| **%** | procent din nota finală a proiectului (100%) | Cerințe obligatorii: 60% |
| **Pct (în tabele)** | puncte relative în cadrul secțiunii | 5 pct din cei 20% ai secțiunii |
| **Bonus +X%** | procent suplimentar peste baza 100% | Bonus: +40% |
| **Ajustare ±X%** | modificare procentuală aplicată notei finale | Calitatea codului: ±10% |

> **Notă importantă:** punctele din coloanele Pct sunt **puncte relative** care se cumulează pentru a forma procentul secțiunii. Bonusurile se adaugă peste nota de bază și pot depăși 100%.

---

## Structura CAPSTONE

Seminarul 06 este un seminar **integrator**, în care studenții lucrează la unul dintre cele 3 proiecte CAPSTONE și îl prezintă în seminarul final (SEM07).

### Opțiuni de proiect

| Proiect | Focus | Dificultate |
|---------|-------|------------|
| **Monitor** | monitorizare de sistem și dashboard | ⭐⭐⭐ |
| **Backup** | backup incremental și restaurare | ⭐⭐⭐ |
| **Deployer** | pipeline CI/CD simplificat | ⭐⭐⭐⭐ |
| **Integrat** | combinația tuturor celor 3 | ⭐⭐⭐⭐⭐ |

---

## SARCINA 1: Monitor — Extindere de funcționalități

### Cerințe obligatorii (60%)

#### 1.1 Monitorizare rețea (20%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|-----------|-----|-----------|--------------|--------------|
| Citire /proc/net/dev | 5 | parsare corectă a tuturor câmpurilor | câmpuri principale | erori de parsare |
| Calcul de rată (Mbps) | 5 | diferență între citiri, conversie corectă | funcționează | calcul greșit |
| Multi‑interfață | 5 | toate interfețele detectate | eth0 hardcodat | erori |
| Output structurat | 5 | format consecvent cheie:valoare | funcțional | neformatat |

#### 1.2 Monitorizare servicii (20%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|-----------|-----|-----------|--------------|--------------|
| systemctl status | 5 | is-active + show corect | doar is-active | erori |
| Memorie/CPU per serviciu | 5 | citire din cgroups/systemctl | aproximație | lipsă |
| Listă servicii | 5 | procesare corectă a array‑ului | funcționează | hardcodat |
| Tratare erori | 5 | serviciu inexistent tratat | mesaj generic | crash |

#### 1.3 Dashboard în terminal (20%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|-----------|-----|-----------|--------------|--------------|
| Coduri ANSI | 5 | culori, poziționare, ștergere ecran | parțial | doar text |
| Bare de progres | 5 | `[████████░░]` cu procent | funcțional | lipsă |
| Refresh live | 5 | buclă cu interval configurabil | funcționează | manual |
| Layout organizat | 5 | secțiuni clare, aliniere | funcțional | dezorganizat |

### Cerințe bonus (40%)

| Cerință | Pct | Descriere |
|-------------|-----|-------------|
| Arbore de procese | +10 | afișare ierarhică a proceselor |
| Alertă email | +10 | notificare la depășirea pragului |
| Date istorice | +10 | salvare și grafice istorice |
| Fișier de configurare | +10 | setări externe YAML/JSON |

---

## SARCINA 2: Backup — Sistem complet

### Cerințe obligatorii (60%)

#### 2.1 Backup incremental (20%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|-----------|-----|-----------|--------------|--------------|
| Detectare modificări | 7 | find -newer sau rsync | parțial | backup complet |
| Management snapshot‑uri | 7 | urmărire versiuni | funcționează | manual |
| Compresie | 6 | tar.gz cu nivel configurabil | tar.gz fix | necomprimat |

#### 2.2 Restore (20%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|-----------|-----|-----------|--------------|--------------|
| Listare versiuni | 5 | afișează toate snapshot‑urile | funcționează | lipsă |
| Restore specific | 7 | versiune + selecție fișier | totul sau nimic | erori |
| Dry-run | 5 | previzualizare fără modificări | menționat | lipsă |
| Verificare integritate | 3 | checksum sau tar -t | parțial | lipsă |

#### 2.3 Rotație și curățare (20%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|-----------|-----|-----------|--------------|--------------|
| Politică de retenție | 7 | zilnic/săptămânal/lunar | număr fix | fără rotație |
| Verificare spațiu disc | 7 | verificare înainte de backup | mesaj | lipsă |
| Jurnalizare | 6 | timestamp, status, erori | parțial | lipsă |

### Cerințe bonus (40%)

| Cerință | Pct | Descriere |
|-------------|-----|-------------|
| Deduplicare | +10 | pe bază de hash pentru fișiere identice |
| Backup remote | +10 | SCP/rsync către server remote |
| Criptare | +10 | GPG pentru arhive |
| Wizard de programare | +10 | generator interactiv de crontab |

---

## SARCINA 3: Deployer — Pipeline CI/CD

### Cerințe obligatorii (60%)

#### 3.1 Integrare Git (20%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|-----------|-----|-----------|--------------|--------------|
| Clone/pull | 5 | detectare automată | manual | erori |
| Selecție branch | 5 | parametru sau config | main hardcodat | lipsă |
| Urmărire commit | 5 | salvează hash‑ul curent | funcționează | lipsă |
| Submodule | 5 | gestionare --recursive | ignorat | erori |

#### 3.2 Build & Deploy (20%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|-----------|-----|-----------|--------------|--------------|
| Hook‑uri pre/post | 7 | execuție script personalizat | unul din două | lipsă |
| Config de mediu | 7 | .env sau export | parțial | hardcodat |
| Deploy atomic | 6 | comutare symlink | funcționează | în‑loc |

#### 3.3 Rollback (20%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|-----------|-----|-----------|--------------|--------------|
| Istoric versiuni | 7 | păstrează N versiuni | funcționează | doar curenta |
| Rollback rapid | 7 | o singură comandă | funcționează | manual |
| Validare post‑rollback | 6 | health check | mesaj | lipsă |

### Cerințe bonus (40%)

| Cerință | Pct | Descriere |
|-------------|-----|-------------|
| Zero‑downtime | +10 | blue-green deployment |
| Suport containere | +10 | build/deploy Docker |
| Notificări Slack | +10 | webhook la deploy |
| Multi‑environment | +10 | dev/staging/prod |

---

## SARCINA 4: Proiect integrat (BONUS MAJOR)

| Criteriu | Pct | Descriere |
|-----------|-----|-------------|
| Monitor + Dashboard | 20 | vizualizare metrici |
| Automatizare backup | 20 | backup cu monitorizare |
| Pipeline de deploy | 20 | CI/CD complet |
| Orchestrare | 20 | componentele comunică între ele |
| Documentație | 20 | README complet, diagrame |

**Total posibil proiect integrat: +100% bonus** (adăugat peste nota de bază a proiectului principal ales)

---

## PREZENTAREA FINALĂ (SEM07) — 40% din nota finală

### Criterii de prezentare

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|-----------|-----|-----------|--------------|--------------|
| Demo live | 15 | funcționează perfect | funcționează cu mici probleme | crash |
| Explicarea codului | 10 | arhitectură clară | explicat funcțional | confuz |
| Răspunsuri la întrebări | 10 | răspunsuri clare | parțial | nu știe |
| Timp (10–15 min) | 5 | în interval | ±3 minute | mult peste/sub |

### Structură recomandată a prezentării

1. **Introducere** (2 min)
   - ce proiect ați ales și de ce;
   - obiective propuse.

2. **Arhitectură** (3 min)
   - structură fișiere;
   - flux de date;
   - dependențe.

3. **Demo live** (5 min)
   - funcționalități principale;
   - cazuri-limită tratate.

4. **Cod interesant** (3 min)
   - fragmente relevante;
   - provocări rezolvate.

5. **Concluzii** (2 min)
   - ce ați învățat;
   - îmbunătățiri posibile.

---

## Criterii transversale

### Calitatea codului (ajustare: -10% până la +10% din nota finală)

| Aspect | Bonus | Penalizare |
|--------|-------|---------|
| Fără probleme ShellCheck | +3 | -3 |
| Modularizare prin funcții | +2 | -2 |
| Tratare completă a erorilor | +2 | -2 |
| Documentație inline | +2 | -2 |
| Teste incluse | +3 | 0 |

---

## Penalizări

| Situație | Penalizare |
|-----------|---------|
| Plagiat | **-100%** |
| Fără prezentare în SEM07 | **-40%** |
| Demo-ul nu funcționează | -20% |
| Fără documentație | -10% |
| Cod dezorganizat | -5% |

---

## Checklist final

```
□ Proiect complet și funcțional
□ README.md cu instrucțiuni
□ Toate scripturile executabile
□ ShellCheck fără erori
□ Teste (cel puțin smoke tests)
□ Prezentare pregătită (slide‑uri opționale)
□ Demo testat pe o mașină „curată”
```

---

*Document intern | Proiecte CAPSTONE — Seminarul 6 + prezentări SEM07*
