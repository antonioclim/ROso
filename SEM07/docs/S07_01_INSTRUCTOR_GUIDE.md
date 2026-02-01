# S07 Ghid pentru cadre didactice — sesiunea de evaluare finală

## Pregătire înainte de evaluare

### Cu o săptămână înainte

- [ ] Verificați că toate predările temelor au fost colectate
- [ ] Rulați detecția de plagiat pe predări
- [ ] Pregătiți întrebările pentru verificarea orală
- [ ] Configurați mediul de evaluare
- [ ] Distribuiți programul prezentărilor de proiect

### Cu o zi înainte

- [ ] Testați autograder‑ul pe predări‑eșantion
- [ ] Pregătiți materiale de rezervă pentru evaluare
- [ ] Revedeți cazurile limită din anii anteriori
- [ ] Confirmați sala și echipamentele

## Cronologia zilei de evaluare

### Prezentări de proiect (dacă este cazul)

| Timp | Activitate | Observații |
|------|------------|------------|
| 0:00–0:10 | Setup, prezență | Verificare identitate |
| 0:10–0:25 | Prezentarea studentului 1 (10 min) + întrebări (5 min) | Utilizați întrebările pentru susținere orală |
| 0:25–0:40 | Prezentarea studentului 2 + întrebări | |
| ... | Continuați același tipar | 15 min per student |

### Test scris (dacă este cazul)

| Timp | Activitate |
|------|------------|
| 0:00–0:05 | Distribuire, instrucțiuni |
| 0:05–0:50 | Timp de lucru (45 min) |
| 0:50–0:55 | Colectare, verificare |

## Protocol de verificare orală

### Scop
Verificarea faptului că studenții înțeleg propriile predări și nu au utilizat AI/plagiat.

### Procedură

1. **Selectați 2–3 întrebări** din `oral_defence_questions_EN.md`
2. **Întrebați despre cod specific** din predare:
   - „Explicați-mi pas cu pas această funcție”
   - „De ce ați ales această abordare?”
   - „Ce se întâmplă dacă acest input este invalid?”
3. **Evaluați înțelegerea**, nu memorarea
4. **Documentați răspunsurile** în jurnalul de evaluare

### Semnale de alarmă

- Nu poate explica propriul cod
- Utilizează terminologie inconsecventă cu stilul codului
- Nu poate modifica codul la cerere
- Predări suspect de uniforme

## Flux de notare

```
1. Notare automată (autograder) → scor de bază
2. Review manual (cazuri limită) → ajustări
3. Verificare orală → verificare de autenticitate
4. Calculul notei finale → formula din GRADING_POLICY.md
5. Introducerea notelor → sistemul universității
```

## Probleme frecvente și soluții

| Problemă | Soluție |
|----------|---------|
| Studentul invocă o eroare a autograder‑ului | Revedeți manual, documentați |
| Suspiciune de plagiat | Verificare orală, comparație cu MOSS |
| Defecțiune tehnică în timpul demo‑ului | Permiteți reîncercare, documentați circumstanțele |
| Contestarea notei | Raportați la rubrică, explicați punctajul |

## După evaluare

- [ ] Introduceți notele în sistem
- [ ] Arhivați predările
- [ ] Documentați orice probleme pentru anul următor
- [ ] Colectați feedback de la studenți (opțional)
