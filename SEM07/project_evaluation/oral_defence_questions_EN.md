# Întrebări pentru susținerea orală — evaluarea proiectului

> **Sisteme de Operare** | ASE Bucharest - CSIE  
> SEM07 - susținere orală și verificarea autenticității

---

## Prezentare generală

Aceste întrebări sunt concepute pentru:
1. verificarea faptului că studentul înțelege propria implementare;
2. detectarea plagiatului sau a utilizării neautorizate a AI;
3. evaluarea competenței de comunicare tehnică.

**Instrucțiuni de utilizare:**
- Selectați 5–8 întrebări per student
- Amestecați întrebări generale cu întrebări specifice codului
- Solicitați demonstrații în timp real atunci când este necesar
- Notați răspunsurile pentru consistență (proiecte de echipă)

---

## 1. Întrebări de tip general (înțelegerea proiectului)

### 1.1 Arhitectură și design
1. Care este scopul principal al proiectului dumneavoastră?
2. Puteți descrie arhitectura de nivel înalt a soluției?
3. Cum ați împărțit proiectul în module/componente?
4. Care este fluxul de date prin aplicație?
5. De ce ați ales această arhitectură în locul unei alternative?

### 1.2 Alegeri de implementare
1. De ce ați ales Bash/Python/C pentru această componentă?
2. Care a fost cea mai dificilă parte de implementat și de ce?
3. Care compromisuri ați făcut între simplitate și funcționalitate?
4. Cum v-ați structurat directoarele și fișierele?
5. Ați urmat vreo convenție de stil? De ce?

---

## 2. Întrebări specifice pe cod

### 2.1 Funcții și logică
1. Explicați această funcție pas cu pas: `[point to function]`
2. Ce face această linie de cod: `[point to line]`?
3. De ce ați utilizat această comandă/flag în locul alteia?
4. Ce se întâmplă dacă acest input este gol sau invalid?
5. Unde este tratată eroarea dacă această comandă eșuează?

### 2.2 Tratarea erorilor
1. Cum gestionați codurile de ieșire în scripturile dumneavoastră?
2. Unde validați input‑ul utilizatorului?
3. Cum preveniți ștergerea accidentală a fișierelor importante?
4. Ce se întâmplă dacă resursele sunt indisponibile (disc plin, permisiuni etc.)?
5. Cum vă asigurați că scriptul se oprește în siguranță?

### 2.3 Performanță și optimizare
1. Care este complexitatea componentei `[specific component]`?
2. Cum ați optimizat operațiile pe fișiere pentru volume mari?
3. Care este cel mai costisitor pas și cum l-ați putea îmbunătăți?
4. Cum ați evita execuția de comenzi redundantă?
5. Există o limită practică pentru input? Care ar fi?

---

## 3. Întrebări de modificare în timp real (red flags)

### 3.1 Modificări simple
1. Puteți schimba output‑ul astfel încât să afișeze și timestamp‑ul?
2. Puteți adăuga un nou argument CLI (de ex.: `--verbose`)?
3. Puteți modifica scriptul să scrie logurile într‑un fișier?
4. Puteți schimba ordinea operațiilor pentru a evita o condiție de cursă?
5. Puteți adăuga o verificare pentru fișiere inexistente?

### 3.2 Modificări moderate
1. Puteți adăuga suport pentru procesarea mai multor fișiere (batch)?
2. Puteți refactoriza codul pentru a utiliza o funcție reutilizabilă?
3. Puteți adăuga opțiunea de dry-run (fără modificări reale)?
4. Puteți implementa un mod de configurare prin fișier config?
5. Puteți adăuga suport pentru un format nou de output?

### 3.3 Modificări avansate
1. Puteți face scriptul să ruleze în paralel anumite operații?
2. Puteți adăuga o bară de progres sau indicator de status?
3. Puteți implementa mecanism de rollback în caz de eșec?
4. Puteți adăuga o suită de teste automate pentru acest modul?
5. Puteți containeriza aplicația pentru rulare izolată?

---

## 4. Întrebări pentru detectarea AI/plagiat

### 4.1 Consistența stilului
1. De ce folosiți aceste nume de variabile? Par a fi alese intenționat?
2. De ce unele părți sunt comentate foarte detaliat și altele deloc?
3. De ce stilul de quoting diferă între funcții?
4. Puteți explica ce înseamnă această expresie regex?
5. De unde provine această abordare?

### 4.2 Procesul de dezvoltare
1. Cum ați început proiectul? Care a fost primul pas?
2. Ce resurse ați folosit (documentație, man pages, articole)?
3. Care bug v-a consumat cel mai mult timp? Cum l-ați rezolvat?
4. Cum ați testat? Ce cazuri ați considerat?
5. Puteți arăta istoricul commit‑urilor și explica evoluția?

### 4.3 Întrebări de înțelegere aprofundată
1. Ce s-ar întâmpla dacă această comandă rulează într‑un subshell?
2. De ce ați ales această opțiune de regex? Ce alternative există?
3. Cum se comportă scriptul dacă numele fișierului conține spații?
4. De ce folosiți `"$@"` în loc de `$*`?
5. Care este diferența dintre `[[ ]]` și `[ ]` în Bash?

---

## 5. Rubrică de punctare a susținerii orale

### 5.1 Scorarea răspunsurilor

| Nivel | Scor | Descriere |
|-------|------|-------------|
| **Inacceptabil** | 0 | Nu poate răspunde, răspunsuri greșite |
| **Slab** | 1 | Răspunsuri vagi, înțelegere limitată |
| **Acceptabil** | 2 | Înțelegere de bază, unele lacune |
| **Bun** | 3 | Înțelegere solidă, poate explica clar |
| **Excelent** | 4 | Înțelegere profundă, poate adapta și optimiza |

### 5.2 Indicatori de autenticitate

| Indicator | Inacceptabil | Acceptabil | Excelent |
|----------|------------|------------|-----------|
| Explicarea codului | Nu poate explica | Explică parțial | Explică complet |
| Înțelegerea conceptelor | Fără înțelegere | Înțelegere de bază | Înțelegere profundă |
| Rezolvarea problemelor | Nu se poate adapta | Se adaptează cu ajutor | Se adaptează independent |
| Comunicarea | Neclară | Adecvată | Clară și precisă |

---

## 6. Documentare pentru examinatori

### 6.1 Înainte de susținere
- Revedeți sumar codul studentului
- Notați întrebări specifice implementării sale
- Verificați istoricul commit‑urilor pentru tipare de contribuție
- Pregătiți IDE/terminal pentru demonstrație live

### 6.2 În timpul susținerii
- Începeți cu întrebări generale pentru a reduce emoțiile
- Progresati către întrebări specifice codului
- Solicitați modificări live când este potrivit
- Notați răspunsurile pentru comparații ulterioare (proiecte de echipă)

### 6.3 După susținere
- Completați rubrica de punctare imediat
- Notați orice îngrijorări pentru follow‑up
- Comparați răspunsurile membrilor echipei, dacă este cazul
- Documentați orice preocupări privind integritatea academică

---

*De Revolvix pentru disciplina OPERATING SYSTEMS | licență restricționată 2017-2030*
