# Rubrica de Evaluare - CAPSTONE Projects

> **Document pentru instructor** | Seminar 6 + Prezentare Finală (SEM07)

---

## Legendă Sistem de Punctare

| Simbol | Semnificație | Exemplu |
|--------|--------------|---------|
| **%** | Procent din nota finală a proiectului (100%) | Cerințe Obligatorii: 60% |
| **Pct (în tabele)** | Puncte relative în cadrul secțiunii | 5 pct din cele 20% ale sub-secțiunii |
| **Bonus +X%** | Procente suplimentare peste baza de 100% | Bonus: +40% |
| **Ajustare ±X%** | Modificare procentuală aplicată notei finale | Calitate cod: ±10% |

> **Notă importantă**: Punctele din coloanele tabelelor (Pct) sunt **puncte relative** care se adună pentru a forma procentul secțiunii respective. Bonus-urile se adaugă peste nota de bază și pot depăși 100%.

---

## Structura CAPSTONE

Seminarul 06 este un **seminar integrator** unde studenții lucrează la unul din cele 3 proiecte CAPSTONE și îl prezintă în seminarul final (SEM07).

### Opțiunile de Proiect

| Proiect | Focus | Dificultate |
|---------|-------|-------------|
| **Monitor** | Monitorizare sistem și dashboard | ⭐⭐⭐ |
| **Backup** | Backup incremental și restaurare | ⭐⭐⭐ |
| **Deployer** | CI/CD pipeline simplificat | ⭐⭐⭐⭐ |
| **Integrat** | Combinație din toate 3 | ⭐⭐⭐⭐⭐ |

---

## TEMA 1: Monitor - Extindere Funcționalități

### Cerințe Obligatorii (60%)

#### 1.1 Network Monitoring (20%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| Citire /proc/net/dev | 5 | Parsare corectă toate câmpurile | Câmpuri principale | Erori parsare |
| Calcul rate (Mbps) | 5 | Diferență între citiri, conversie corectă | Funcționează | Calcul greșit |
| Multi-interfață | 5 | Toate interfețele detectate | eth0 hardcodat | Erori |
| Output structurat | 5 | Format key:value consistent | Funcțional | Neformatat |

#### 1.2 Service Monitoring (20%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| systemctl status | 5 | is-active + show corect | Doar is-active | Erori |
| Memory/CPU per serviciu | 5 | Citire din cgroups/systemctl | Aproximare | Lipsă |
| Lista servicii | 5 | Array procesare corectă | Funcționează | Hardcodat |
| Error handling | 5 | Serviciu inexistent gestionat | Mesaj generic | Crash |

#### 1.3 Dashboard Terminal (20%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| ANSI escape codes | 5 | Culori, poziționare, clear | Parțial | Doar text |
| Bare de progres | 5 | `[████████░░]` cu procent | Funcțional | Lipsă |
| Refresh live | 5 | Loop cu interval configurabil | Funcționează | Manual |
| Layout organizat | 5 | Secțiuni clare, aliniat | Funcțional | Dezordonat |

### Cerințe Bonus (40%)

| Cerință | Pct | Descriere |
|---------|-----|-----------|
| Process tree | +10 | Afișare ierarhică procese |
| Alert email | +10 | Notificare la threshold |
| Historical data | +10 | Salvare și grafice istorice |
| Config file | +10 | Setări externe YAML/JSON |

---

## TEMA 2: Backup - Sistem Complet

### Cerințe Obligatorii (60%)

#### 2.1 Backup Incremental (20%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| Detectare modificări | 7 | find -newer sau rsync | Parțial | Full backup |
| Snapshot management | 7 | Tracking versiuni | Funcționează | Manual |
| Compresie | 6 | tar.gz cu nivel configurabil | tar.gz fix | Necomprimat |

#### 2.2 Restaurare (20%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| List versions | 5 | Afișare toate snapshot-urile | Funcționează | Lipsă |
| Restore specific | 7 | Selectare versiune + fișiere | Tot sau nimic | Erori |
| Dry-run | 5 | Preview fără modificări | Menționat | Lipsă |
| Verificare integritate | 3 | Checksum sau tar -t | Parțial | Lipsă |

#### 2.3 Rotație și Cleanup (20%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| Politică retenție | 7 | Daily/weekly/monthly | Număr fix | Fără rotație |
| Spațiu disk check | 7 | Verificare înainte de backup | Mesaj | Lipsă |
| Logging | 6 | Timestamp, status, erori | Parțial | Lipsă |

### Cerințe Bonus (40%)

| Cerință | Pct | Descriere |
|---------|-----|-----------|
| Deduplicare | +10 | Hash-based pentru fișiere identice |
| Remote backup | +10 | SCP/rsync la server remote |
| Encryption | +10 | GPG pentru arhive |
| Schedule wizard | +10 | Generator crontab interactiv |

---

## TEMA 3: Deployer - Pipeline CI/CD

### Cerințe Obligatorii (60%)

#### 3.1 Git Integration (20%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| Clone/pull | 5 | Detectare automată | Manual | Erori |
| Branch selection | 5 | Parametru sau config | Hardcodat main | Lipsă |
| Commit tracking | 5 | Salvare hash curent | Funcționează | Lipsă |
| Submodules | 5 | Gestionare --recursive | Ignorat | Erori |

#### 3.2 Build & Deploy (20%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| Hooks pre/post | 7 | Executare scripts custom | Unul din două | Lipsă |
| Environment config | 7 | .env sau export | Parțial | Hardcodat |
| Atomic deploy | 6 | Symlink switch | Funcționează | In-place |

#### 3.3 Rollback (20%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| Version history | 7 | N versiuni păstrate | Funcționează | Doar curent |
| Quick rollback | 7 | Un singur command | Funcționează | Manual |
| Validare post-rollback | 6 | Health check | Mesaj | Lipsă |

### Cerințe Bonus (40%)

| Cerință | Pct | Descriere |
|---------|-----|-----------|
| Zero-downtime | +10 | Blue-green deployment |
| Container support | +10 | Docker build/deploy |
| Slack notifications | +10 | Webhook la deploy |
| Multi-environment | +10 | Dev/staging/prod |

---

## TEMA 4: Proiect Integrat (BONUS MARE)

| Criteriu | Pct | Descriere |
|----------|-----|-----------|
| Monitor + Dashboard | 20 | Vizualizare metrici |
| Backup automation | 20 | Backup cu monitoring |
| Deploy pipeline | 20 | CI/CD complet |
| Orchestrare | 20 | Toate componentele comunică |
| Documentație | 20 | README complet, diagrame |

**Total posibil Proiect Integrat: +100% bonus** (se adaugă peste nota de bază din proiectul principal ales)

---

## PREZENTARE FINALĂ (SEM07) - 40% din nota finală

### Criterii Prezentare

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| Demo live | 15 | Funcționează perfect | Funcționează cu mici pb | Crash |
| Explicație cod | 10 | Arhitectură clară | Funcțional explicat | Confuz |
| Răspuns întrebări | 10 | Răspunsuri clare | Parțial | Nu știe |
| Timp (10-15 min) | 5 | În interval | ±3 minute | Peste/sub mult |

### Structură Prezentare Recomandată

1. **Introducere** (2 min)
   - Ce proiect ai ales și de ce
   - Obiectivele propuse

2. **Arhitectură** (3 min)
   - Structura fișierelor
   - Fluxul de date
   - Dependențe

3. **Demo Live** (5 min)
   - Funcționalități principale
   - Edge cases gestionate

4. **Cod Interesant** (3 min)
   - Snippet-uri relevante
   - Provocări rezolvate

5. **Concluzii** (2 min)
   - Ce ai învățat
   - Îmbunătățiri posibile

---

## Criterii Transversale

### Calitate Cod (ajustare: -10% până la +10% din nota finală)

| Aspect | Bonus | Penalizare |
|--------|-------|------------|
| ShellCheck clean | +3 | -3 |
| Modularizare funcții | +2 | -2 |
| Error handling complet | +2 | -2 |
| Documentație inline | +2 | -2 |
| Tests incluse | +3 | 0 |

---

## Penalizări

| Situație | Penalizare |
|----------|------------|
| Plagiat | **-100%** |
| Neprezentare în SEM07 | **-40%** |
| Demo nu funcționează | -20% |
| Fără documentație | -10% |
| Cod neorganizat | -5% |

---

## Checklist Final

```
□ Proiect complet și funcțional
□ README.md cu instrucțiuni
□ Toate scripturile executabile
□ ShellCheck fără erori
□ Tests (cel puțin smoke tests)
□ Prezentare pregătită (slides opțional)
□ Demo testat pe mașină curată
```

---

*Document intern | CAPSTONE Projects - Seminar 6 + SEM07 Prezentări*
