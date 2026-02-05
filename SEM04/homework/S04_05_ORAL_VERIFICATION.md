# Întrebări pentru verificare orală — Seminar 04

> **Document doar pentru instructori** — nu se distribuie studenților  
> **Scop:** verifică faptul că studenții chiar au scris și înțeleg propriul cod  
> **Durată:** 3–5 minute / student  
> **Când:** în timpul laboratoarelor sau la consultații, după predare

---

## Procedură

1. Studentul își deschide predarea pe propriul laptop
2. Instructorul selectează aleator 2–3 întrebări (zaruri, random.org sau pur și simplu alegeți)
3. Studentul trebuie să răspundă FĂRĂ a consulta resurse externe
4. Se acordă punctaj parțial pentru indicii; zero dacă este clar că nu își înțelege propriul cod

> *Din experiență: studenții care copiază pot, de regulă, explica CE face codul,
> dar se blochează la DE CE au ales o anumită abordare. Concentrați-vă pe „de ce”.*

---

## Ghid de notare

| Calitatea răspunsului | Ajustare scor |
|------------------|------------------|
| Imediat, sigur pe sine și corect | 100% din nota temei |
| Corect după o scurtă gândire | 100% |
| Corect după un indiciu | 80% |
| Parțial corect | 50% |
| Clar nu înțelege | → investigație pentru plagiat |

---

## Banca de întrebări

### Categoria A: Înțelegere de bază (întrebați cel puțin 1)

#### A1. opțiuni `grep`
- „Ce face `-o` în comanda ta `grep`?”
- Așteptat: „Afișează doar partea care se potrivește, nu întreaga linie”
- Întrebare de urmărire: „De ce ai avut nevoie de asta aici?”

#### A2. `sort` înainte de `uniq`
- „De ce este `sort` înainte de `uniq` în pipeline‑ul tău?”
- Așteptat: „`uniq` elimină doar duplicatele adiacente, deci datele trebuie sortate înainte”
- Dacă greșește: semnal de alarmă imediat — este fundamental

#### A3. separator de câmp
- „Ce face `-F','` în `awk`?”
- Așteptat: „Setează separatorul de câmp la virgulă pentru parsarea CSV”
- Întrebare de urmărire: „Ce ar fi `$3` fără asta?”

#### A4. flag global
- „Ce se întâmplă dacă elimini `/g` din substituția `sed`?”
- Așteptat: „Se înlocuiește doar prima apariție de pe fiecare linie”

#### A5. `NR` în `awk`
- „Ce este `NR` și de ce ai folosit `NR > 1`?”
- Așteptat: „`NR` este numărul înregistrării/liniei; `NR > 1` sare peste antet”

---

### Categoria B: Alegeri de implementare (întrebați cel puțin 1)

#### B1. conștientizarea UUOC
- „Văd `cat file | grep`. Poți rescrie asta?”
- Așteptat: `grep pattern file` (argument direct de fișier)
- Testează: conștientizarea „useless use of cat”

#### B2. proiectarea regex‑ului
- „Regex‑ul tău pentru e‑mail este `[pattern]`. Ce formate acceptă?”
- Întrebare de urmărire: „Dar `user+tag_AT_domain_DOT_co_DOT_uk`? Regex‑ul tău se potrivește?”

#### B3. abordare alternativă
- „Ai folosit grep+sort+uniq. Ai putea face asta într‑un singur `awk`?”
- Așteptat: studentul explică abordarea cu tablou asociativ
- Nu se așteaptă: sintaxă `awk` perfectă din memorie

#### B4. tratarea erorilor
- „Ce se întâmplă dacă rulez scriptul tău fără argumente?”
- Bine: „Afișează usage și iese cu eroare”
- Rău: „Nu știu” sau „se prăbușește”

#### B5. formatarea output‑ului
- „De ce ai folosit `printf` în loc de `print` aici?”
- Așteptat: „Pentru a controla formatarea, numărul de zecimale și lățimea coloanelor”

---

### Categoria C: Cazuri limită (pentru note > 8)

#### C1. intrare goală
- „Ce afișează scriptul tău pentru un fișier gol?”
- Testează: dacă au testat cazuri limită

#### C2. caractere speciale
- „Ce se întâmplă dacă un câmp CSV conține o virgulă între ghilimele?”
- Avansat: cele mai multe soluții ale studenților nu vor gestiona asta — este OK
- Bine: studentul recunoaște limita

#### C3. fișiere foarte mari
- „Dacă ți‑aș da un log de 10GB, ce ai schimba?”
- Idei așteptate: 
  - procesare în flux (stream), fără încărcare completă
  - `awk` într‑o singură trecere, în loc de mai multe pipe‑uri
  - evitarea `sort` pe date uriașe

#### C4. portabilitate
- „Ar funcționa pe macOS? Într‑un container Docker minimal?”
- Testează: conștientizarea diferențelor GNU vs BSD
- Indiciu dacă se blochează: „Dar `sed -i`?”

---

### Categoria D: Modificare live (standardul de aur)

Acestea cer studentului să modifice codul pe loc:

#### D1. Adaugă o funcționalitate
- „Adaugă o coloană cu procente în output”
- Observă: cum gândește, unde se uită, viteza de tastare

#### D2. Repară un bug
*Introduceți un bug subtil în codul lor înainte de a cere:*
- „Am schimbat un caracter și acum nu mai funcționează. Găsește și repară.”
- Exemple: 
  - `$3` → `$2`
  - `sort -rn` → `sort -n`
  - `/g` → (eliminat)

#### D3. Explică apoi modifică
- „Explică această linie, apoi schimb‑o astfel încât să gestioneze și litere mici”
- Forțează înțelegere autentică, nu doar pattern‑matching

---

## Semnale de alarmă (investigați mai departe)

- Nu poate naviga rapid prin propriul cod
- Folosește nume de variabile pe care nu le poate explica („ce este `x` aici?”)
- Cod perfect, dar se blochează la întrebări de bază
- Structură de cod identică cu alt student (chiar dacă datele diferă)
- Explică „ce”, dar niciodată „de ce”
- Reacție excesiv defensivă când este întrebat

---

## Dialog exemplu

**Instructor:** „Explică‑mi Exercițiul 2. Ce face această comandă `awk`?”

**Student (bun):** „Mai întâi setez separatorul de câmp la virgulă pentru că e CSV.
Apoi, pentru fiecare linie după antet — asta e partea `NR > 1` — adun salariul,
care e coloana 4, într‑o sumă cumulativă. La `END` afișez media.”

**Student (suspect):** „Calculează... salariul. `awk` procesează fișierul
și apoi afișează rezultatul.”

**Instructor:** „De ce coloana 4, mai exact?”

**Student (bun):** „Pentru că în CSV coloanele sunt ID, Nume, Departament și Salariu,
deci salariul este câmpul 4.”

**Student (suspect):** „Acolo este... numărul?”

---

## Documentare

După verificare, notați în tabelul de notare:

```
MATRICOL | Q1 | Q2 | Q3 | VERDICT | NOTES
123456   | A2 | B3 | -  | PASS    | solid understanding
234567   | A1 | B1 | D1 | PASS-   | needed hints for B1
345678   | A3 | B2 | -  | INVEST  | could not explain own regex
```

---

*Mențineți acest document actualizat cu întrebări noi, în funcție de problemele recurente observate.*
*Ultima actualizare: ianuarie 2025 (ing. dr. Antonio Clim)*
