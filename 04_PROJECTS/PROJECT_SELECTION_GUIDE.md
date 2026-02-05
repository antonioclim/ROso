# 🧭 Ghid de Selecție Proiect

> **Scop:** Te ajută să alegi proiectul potrivit pentru competențele și timpul tău disponibil  
> **Autor:** ing. dr. Antonio Clim  
> **Bazat pe:** 5 ani de notare a acestor proiecte

---

## Diagramă Rapidă de Decizie

```
                              PORNEȘTE DE AICI
                                  │
                                  ▼
                    ┌───────────────────────────┐
                    │ Câte ore poți realist    │
                    │ să dedici?                │
                    └───────────────────────────┘
                                  │
              ┌───────────────────┼───────────────────┐
              │                   │                   │
           <20 ore            20-35 ore             >35 ore
              │                   │                   │
              ▼                   ▼                   ▼
        ┌──────────┐        ┌──────────┐        ┌──────────┐
        │  EASY    │        │  Vezi    │        │  Vezi    │
        │  DOAR    │        │  mai jos │        │  mai jos │
        │ E01-E05  │        │    ↓     │        │    ↓     │
        └──────────┘        └──────────┘        └──────────┘
                                  │                   │
                                  ▼                   ▼
                    ┌───────────────────────────┐    │
                    │ Ai scris >500 linii de    │    │
                    │ Bash înainte?             │    │
                    └───────────────────────────┘    │
                                  │                   │
                           ┌──────┴──────┐           │
                           │             │           │
                          DA             NU          │
                           │             │           │
                           ▼             ▼           │
                      ┌─────────┐   ┌─────────┐     │
                      │ MEDIUM  │   │  EASY   │     │
                      │ M01-M15 │   │ E01-E05 │     │
                      └─────────┘   └─────────┘     │
                                                    │
                                                    ▼
                                  ┌───────────────────────────┐
                                  │ Ai experiență C?          │
                                  │ (malloc, pointeri, etc.)  │
                                  └───────────────────────────┘
                                                    │
                                             ┌──────┴──────┐
                                             │             │
                                            DA             NU
                                             │             │
                                             ▼             ▼
                                        ┌─────────┐   ┌─────────┐
                                        │ADVANCED │   │ MEDIUM  │
                                        │ A01-A03 │   │ M01-M15 │
                                        └─────────┘   └─────────┘
```

---

## Matrice Detaliată de Selecție

### După Situația Ta

| Situația Ta | Proiecte Recomandate | De Ce |
|----------------|---------------------|-----|
| Prima dată cu Linux/Bash | E01, E03 | Focus pe comenzi de bază (`find`, `mv`) |
| Știu Python, învăț Bash | E02, E04 | Modele familiare, procesare text |
| Confortabil cu scripting | M01, M03, M12 | Instrumente practice, din lumea reală |
| Interesat de securitate | M04, M07 | Competențe relevante în industrie |
| Interesat de DevOps | M05, M09 | Deployment și automatizare |
| Entuziast programare sisteme | A01, A02 | Concepte OS profunde, integrare C |
| Timp limitat (<20h disponibile) | Doar E01-E05 | Fii realist despre domeniul de aplicare |
| Vreau provocare maximă | A01 + bonus K8s | Experiență completă, CV impresionant |

### După Domeniul de Interes

| Interes | EASY | MEDIUM | ADVANCED |
|----------|------|--------|----------|
| **Sisteme de fișiere** | E01, E03 | M08, M12 | — |
| **Procese** | — | M02, M10 | A01 |
| **Rețele** | — | M04, M13 | A03 |
| **Securitate** | — | M07 | — |
| **Automatizare** | E05 | M05, M09, M15 | — |
| **Monitorizare** | E04 | M03, M06, M11 | — |
| **Interfețe utilizator** | — | M14 | A02 |

---

## 🏆 Recomandările Mele Personale

Bazat pe notarea a sute de predări, iată opiniile mele oneste:

### Cel Mai Bun Raport Calitate-Preț
**M01 (Sistem de Backup Incremental)**

De ce: Cerințe clare, output practic, îl vei folosi efectiv. Majoritatea studenților care aleg acesta termină la timp și învață foarte multe despre `tar`, `find` și programare.

### Cel Mai Interesant de Implementat
**M02 (Monitor Ciclu de Viață Procese)**

De ce: Vei petrece ore explorând `/proc` și înțelegând cum Linux urmărește efectiv procesele. Studenții care aleg acesta spun adesea "În sfârșit înțeleg ce face de fapt `ps`."

### Cel Mai Ușor de Testat și Debugat
**E01 (Auditor Sistem de Fișiere)**

De ce: Output-uri deterministice. Creezi directoare de test, rulezi script-ul, verifici output-ul. Fără probleme de timing, fără probleme de rețea, fără race conditions.

### Cel Mai Greu de Debugat (Avertisment Corect)
**A03 (Sincronizare Fișiere Distribuită)**

De ce: Problemele de rețea sunt notoriu de greu de reprodus. "Funcționează pe mașina mea" este garantat. Alege acesta doar dacă îți place durerea. (Spun asta cu dragoste — este și cel mai impresionant pe un CV.)

### Bijuterie Ascunsă
**M14 (Manager Configurație Environment)**

De ce: Proiect subestimat. Înveți despre dotfiles, templating și management configurație — competențe de care orice dezvoltator are nevoie dar puține cursuri le predau.

---

## ⚠️ Semnale de Alarmă — Când să Reconsideri

### NU Alege ADVANCED Dacă···

- ❌ Nu ai compilat cod C în ultimele 6 luni
- ❌ Nu știi ce fac `malloc()` și `free()`
- ❌ Ai mai puțin de 40 ore de dedicat
- ❌ Nu ești confortabil cu segmentation faults

> **Poveste adevărată:** În 2023, un student a ales A01 pentru că "arăta cool." Au petrecut 30 de ore doar înțelegând memoria partajată înainte de a scrie orice logică de scheduler. Au terminat, dar abia au dormit două săptămâni.

### NU Alege MEDIUM cu Bonus K8s Dacă···

- ❌ Nu ai folosit niciodată Docker
- ❌ Nu ai scris niciodată un fișier YAML
- ❌ Ai mai puțin de 35 ore disponibile

Bonusul K8s este +10%, dar curba de învățare poate adăuga 10+ ore.

### NU Alege Bazat Pe···

- ❌ "Sună impresionant" — impresionează cu calitate, nu complexitate
- ❌ "Prietenul meu l-a ales" — prietenul tău are competențe diferite
- ❌ "Vreau să învăț X" — învățarea în timpul proiectului este OK, dar nu de la zero

---

## ✅ Semnale Pozitive — Motive Bune de Alegere

- ✅ "Am nevoie efectiv de acest instrument" — motivația este totul
- ✅ "Am făcut ceva similar înainte" — construiește pe cunoștințe existente
- ✅ "Cerințele sunt clare pentru mine" — înțelegi cum arată succesul
- ✅ "Am timp tampon dacă lucrurile merg prost" — planificare realistă

---

## Calibrare Dificultate Proiect

Iată cum aș clasa proiectele după dificultatea reală (nu nivelurile oficiale):

### Mai Ușoare Decât Par
- E01 File System Auditor (foarte direct)
- E03 Bulk File Organiser (majoritar `find` și `mv`)
- M09 Scheduled Tasks Manager (cron este bine documentat)

### Mai Grele Decât Par
- M02 Process Lifecycle Monitor (parsarea `/proc` este complicată)
- M04 Network Security Scanner (cazuri limită networking)
- A02 Interactive Shell Extension (gestionarea terminalului este arcanică)

### Exact Cât de Dificile Te Aștepți
- M01 Incremental Backup (provocare medie solidă)
- M12 File Integrity Monitor (domeniu clar)
- A01 Mini Job Scheduler (provocator dar bine definit)

---

## Sfat Final

1. **Citește specificația completă** înainte de a decide — nu doar titlul
2. **Verifică secțiunea "Implementation Hints"** — are sens pentru tine?
3. **Uită-te la "Evaluation Criteria"** — poți satisface cel puțin 70%?
4. **Întreabă-te:** "Dacă rămân blocat, pot să caut pe Google să ies?" (Pentru ADVANCED: adesea nu)

Când ai îndoieli, alege un nivel mai jos decât crezi că poți gestiona. Un proiect EASY bine executat primește notă mai mare decât un proiect MEDIUM grăbit.

---

*Mult succes la alegere! Și amintește-ți — cel mai bun proiect este cel pe care îl termini.*

*— Antonio*
