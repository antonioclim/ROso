# `heron_FOR.sh` — Explicații detaliate, linie cu linie

## Prezentare generală

Scriptul implementează **metoda lui Heron** (cunoscută și ca metoda babiloniană) pentru aproximarea rădăcinii pătrate a unui număr întreg pozitiv. Structura de control centrală este bucla `for`, care repetă formula de rafinare de exact **10 ori**, fără a verifica dacă rezultatul s-a stabilizat deja.

Ideea matematică este simplă: pornind de la o estimare inițială $x_0 = \frac{N}{2}$, fiecare pas aplică formula:

$$x_{k+1} = \frac{x_k + \frac{N}{x_k}}{2}$$

După câțiva pași, $x_k$ se apropie tot mai mult de $\sqrt{N}$.

---

## Secțiunea 0 — Antetul scriptului

```bash
#!/bin/bash
```

Aceasta este linia numită **shebang** (sau *hashbang*). Ea nu este un comentariu obișnuit, deși începe cu `#`. Caracterele `#!` formează o directivă pentru nucleul sistemului de operare: atunci când fișierul este lansat ca un program executabil, nucleul citește calea de după `#!` și folosește acel interpretor (în cazul de față `/bin/bash`) pentru a rula conținutul fișierului. Fără această linie, sistemul nu ar ști ce interpretor de comenzi să aleagă și ar recurge la cel implicit, care poate diferi de la o distribuție la alta.

---

```bash
# =============================================================================
# heron_FOR.sh
# Metoda Heron (Babiloniana) pentru calculul radacinii patrate
# Structura de control folosita: FOR
```

Bloc de comentarii descriptive. Orice text precedat de `#` este ignorat de interpretor. Aici autorul documentează numele fișierului, scopul scriptului și structura de control principală. Liniile de `=` nu au rol funcțional — servesc doar ca delimitatori vizuali, pentru a face codul mai ușor de parcurs.

---

```bash
# Algoritmul:
#   1. Pornim cu estimarea initiala:  x = N / 2
#   2. Rafinam de EXACT 10 ori cu:    x = ( x + N/x ) / 2
#   3. Dupa 10 pasi,                  x ≈ sqrt(N)
```

Rezumatul algoritmic în trei pași. Formularea este deliberat succintă: pasul 1 stabilește punctul de plecare, pasul 2 descrie regula de rafinare iterativă, iar pasul 3 afirmă rezultatul așteptat. Simbolul `≈` indică faptul că rezultatul este o aproximare, nu o valoare exactă.

---

```bash
# De ce FOR aici?
#   FOR repeta un bloc de cod de UN NUMAR FIX DE ORI, cunoscut dinainte.
#   Formula Heron e aceeasi la fiecare pas — scriem o singura data in bucla.
#   Diferenta fata de IF: nu mai copy-pastam aceeasi linie de N ori.
#   Diferenta fata de WHILE: nu verificam convergenta — facem fix 10 pasi.
```

Justificarea alegerii structurii `for` în locul alternativelor. Argumentul central: numărul de repetiții este **fix și cunoscut dinainte** (10 pași), ceea ce face `for` alegerea naturală. Se subliniază că `if` ar necesita copierea manuală a aceleiași formule de 10 ori (soluție ineficientă și predispusă la erori), iar `while` ar fi potrivit doar dacă am dori oprirea condiționată pe baza convergenței.

---

## Secțiunea 1 — Citirea datelor de intrare

```bash
read -p "Introdu un numar intreg pozitiv: " N
```

Comanda `read` oprește execuția scriptului și așteaptă introducerea datelor de la tastatură. Fanionul `-p` (de la *prompt*) permite atașarea unui mesaj-ghid care se afișează pe aceeași linie cu cursorul de introducere. Textul dintre ghilimele (`"Introdu un numar intreg pozitiv: "`) este mesajul respectiv. Identificatorul `N` de la sfârșit desemnează variabila în care se stochează ceea ce tastează utilizatorul. Din acest punct înainte, valoarea introdusă este accesibilă prin prefixarea cu `$` — adică `$N`.

---

## Secțiunea 2 — Validarea datelor de intrare

### Verificarea câmpului gol

```bash
if [ -z "$N" ]; then
```

Cuvântul-cheie `if` deschide o structură de decizie. Parantezele pătrate `[ ... ]` delimitează o expresie de test (echivalentă cu comanda `test`). Fanionul `-z` verifică dacă șirul de caractere care urmează are lungimea **zero** — altfel spus, dacă utilizatorul a apăsat doar tasta *Enter* fără a tasta nimic. Ghilimelele din jurul `$N` sunt esențiale: dacă `N` nu conține nimic, fără ghilimele expresia ar deveni `[ -z ]`, ceea ce ar genera o eroare de sintaxă. Punct-și-virgula `;` separă condiția de cuvântul `then`, care marchează începutul blocului de instrucțiuni executate dacă testul este adevărat.

---

```bash
    echo "Eroare: nu ai introdus nimic."
```

Comanda `echo` afișează pe ecran textul dintre ghilimele. Mesajul informează utilizatorul că nu a furnizat nicio valoare. Spațiile de la începutul liniei (indentarea) nu au efect funcțional — ele servesc doar pentru a face vizibilă apartenența la blocul `if`.

---

```bash
    exit 1
```

Comanda `exit` oprește imediat scriptul. Valoarea `1` este un **cod de retur** care semnalizează o terminare cu eroare. Prin convenție, în sistemele de tip Unix, codul `0` indică succes, iar orice valoare diferită de zero indică o problemă. Alte programe sau scripturi pot citi acest cod și pot lua decizii în funcție de el.

---

```bash
fi
```

Marchează închiderea blocului `if`. În Bash, fiecare `if` trebuie să aibă un `fi` corespunzător (este cuvântul `if` scris invers). Absența lui generează o eroare de sintaxă la execuție.

---

### Verificarea formatului numeric

```bash
if ! [[ "$N" =~ ^[0-9]+$ ]]; then
```

Această linie introduce o verificare mai sofisticată. Parantezele pătrate duble `[[ ... ]]` sunt o formă extinsă de test, specifică Bash, care permite utilizarea expresiilor regulate. Operatorul `=~` compară conținutul variabilei `$N` cu tiparul (expresia regulată) din dreapta. Tiparul `^[0-9]+$` se citește astfel:

- `^` — începutul șirului
- `[0-9]` — exact o cifră (oricare între 0 și 9)
- `+` — una sau mai multe apariții ale elementului anterior (deci una sau mai multe cifre)
- `$` — sfârșitul șirului

Împreună, tiparul descrie un șir format **exclusiv** din cifre, fără spații, litere sau caractere speciale. Operatorul `!` din fața parantezelor **neagă** rezultatul: dacă `$N` **nu** corespunde tiparului, condiția este adevărată și se execută blocul de eroare.

---

```bash
    echo "Eroare: '${N}' nu este un intreg pozitiv."
```

Mesajul de eroare include valoarea introdusă de utilizator, delimitată de apostroafe pentru claritate vizuală. Notația `${N}` este echivalentă cu `$N`, dar acoladele elimină orice ambiguitate atunci când variabila este plasată adiacent altor caractere.

---

```bash
    exit 1
fi
```

Același mecanism ca mai sus: terminare cu cod de eroare și închidere de bloc.

---

### Tratarea cazului special zero

```bash
if [ "$N" -eq 0 ]; then
```

Operatorul `-eq` (*equal*) compară două valori **numerice**. Dacă `N` este zero, formula Heron ar presupune o împărțire la zero ($N/x$, dar și estimarea inițială $N/2 = 0$, iar la pasul următor s-ar calcula $N/0$), ceea ce ar produce o eroare. De aceea, acest caz este tratat separat.

---

```bash
    echo "sqrt(0) = 0"
    exit 0
```

Răspunsul este trivial: rădăcina pătrată a lui zero este zero. Scriptul afișează rezultatul și se încheie cu codul `0` (succes), deoarece nu este vorba de o eroare, ci de un caz particular tratat corect.

---

```bash
fi
```

Închide blocul `if` pentru cazul special zero.

---

## Secțiunea 3 — Estimarea inițială

```bash
x=$(echo "scale=8; $N / 2" | bc)
```

Aceasta este una dintre cele mai dense linii din script și merită desfăcută în componente:

- **`$(...)`** — substituția de comandă: Bash execută comanda din interior și înlocuiește întreaga construcție cu textul produs de acea comandă.
- **`echo "scale=8; $N / 2"`** — construiește un șir de caractere care conține o instrucțiune pentru calculatorul `bc`. De exemplu, dacă `N` este `50`, șirul devine `scale=8; 50 / 2`.
- **`|`** — operatorul „țeavă" (*pipe*): redirecționează textul produs de `echo` către intrarea programului care urmează.
- **`bc`** — un calculator aritmetic de precizie arbitrară, disponibil pe aproape orice sistem de tip Unix. Bash nu poate efectua calcule cu numere zecimale nativ — operatorul `/` din Bash realizează doar împărțire întreagă.
- **`scale=8`** — setează numărul de cifre zecimale la 8, ceea ce permite observarea detaliată a convergenței de la un pas la altul.

Rezultatul este stocat în variabila `x`, care devine estimarea inițială: $x_0 = N / 2$.

---

```bash
echo "--------------------------------------"
```

Afișează o linie de separare vizuală formată din cratime. Nu are nicio funcție logică — îmbunătățește doar lizibilitatea rezultatelor în terminal.

---

```bash
echo "Numar:  N = $N"
```

Afișează valoarea introdusă de utilizator. Construcția `$N` este expandată (înlocuită) automat de Bash cu valoarea variabilei `N`.

---

```bash
echo "Start:  x = $x   (estimare initiala = N/2)"
```

Afișează estimarea inițială calculată la pasul anterior. Textul dintre paranteze rotunde servește drept adnotare explicativă.

---

```bash
echo "--------------------------------------"
```

O a doua linie de separare, pentru a delimita vizual secțiunea de inițializare de iterațiile care urmează.

---

## Secțiunea 4 — Bucla `for` (10 iterații Heron)

```bash
for pas in {1..10}; do
```

Aceasta este linia care deschide bucla `for`. Să o analizăm element cu element:

- **`for`** — cuvânt-cheie care declară o buclă de iterare.
- **`pas`** — numele variabilei de contor (ales de autorul scriptului; poate fi oricare alt nume valid). La fiecare trecere prin buclă, `pas` primește pe rând câte o valoare din lista furnizată.
- **`in`** — separă variabila de contor de lista de valori.
- **`{1..10}`** — expansiune cu acolade (*brace expansion*): Bash generează automat lista `1 2 3 4 5 6 7 8 9 10`. Aceasta este o facilitate a interpretorului — nu implică niciun program extern.
- **`;`** — separă declarația buclei de cuvântul `do`.
- **`do`** — marchează începutul corpului buclei (instrucțiunile care se repetă).

Prin urmare, corpul buclei se va executa de **exact 10 ori**, cu `pas` luând valorile 1, 2, 3, ..., 10, în ordine.

---

```bash
    x=$(echo "scale=8; ($x + $N / $x) / 2" | bc)
```

Aceasta este **inima algoritmului** — formula de rafinare a lui Heron, scrisă o singură dată dar executată de 10 ori grație buclei. Mecanismul este identic cu cel de la estimarea inițială:

- Se construiește expresia matematică sub formă de text: `($x + $N / $x) / 2`
- Textul este trimis către `bc` prin operatorul-țeavă
- Rezultatul cu 8 cifre zecimale este capturat prin substituție de comandă
- Variabila `x` este **suprascrisă** cu noua valoare

Observație importantă: `x` apare atât în partea stângă (primește noua valoare), cât și în partea dreaptă (furnizează valoarea veche pentru calcul). Bash evaluează mai întâi partea dreaptă, obține rezultatul numeric de la `bc` și abia apoi atribuie noua valoare variabilei `x`. Astfel, la fiecare pas, estimarea se rafinează: $x_{k+1} = \frac{x_k + N / x_k}{2}$.

---

```bash
    echo "Pas $pas: x = $x"
```

Afișează numărul pasului curent (prin expandarea variabilei `$pas`) și valoarea aproximării obținute la acest pas. Urmărind aceste linii în terminal, se poate observa concret cum estimarea converge: diferențele dintre valori succesive devin tot mai mici, până dispar complet (în limita celor 8 cifre zecimale).

---

```bash
done
```

Marchează sfârșitul corpului buclei `for`. Este perechea cuvântului `do` — la fel cum `fi` este perechea lui `if`. Când Bash întâlnește `done`, se întoarce la începutul buclei, incrementează contorul (trece la următoarea valoare din listă) și reia execuția corpului. Când lista de valori se epuizează (după `pas=10`), execuția continuă cu prima instrucțiune de după `done`.

---

## Secțiunea 5 — Afișarea rezultatului final

```bash
echo "--------------------------------------"
```

Linie de separare vizuală, identică cu cele anterioare.

---

```bash
echo "sqrt($N) ≈ $x   (dupa 10 iteratii)"
```

Afișează rezultatul final: aproximarea rădăcinii pătrate a lui `N` obținută după cele 10 iterații. Simbolul `≈` subliniază că valoarea este o aproximare, nu un rezultat exact. Variabilele `$N` și `$x` sunt expandate automat la valorile lor curente.

---

```bash
echo "--------------------------------------"
```

Ultima linie de separare vizuală, care închide blocul de rezultate.

---

## Observații finale (din comentariile scriptului)

Comentariile din secțiunea 5 a scriptului ridică o problemă importantă de eficiență: dacă rulăm scriptul cu `N=9`, rădăcina pătrată exactă este `3`. Din pasul 4, valoarea nu se mai modifică — dar bucla `for` continuă oricum până la pasul 10, efectuând 6 calcule inutile.

Aceasta este **limitarea structurală** a buclei `for` cu număr fix de iterații: ea nu poate evalua o condiție de oprire anticipată. Dacă se dorește oprirea automată la convergență, se recurge la bucla `while`, eventual combinată cu instrucțiunea `break` (a se vedea scriptul `heron_WHILE.sh`).

---

## Anexă — Variante echivalente ale buclei `for` în Bash

Scriptul menționează în comentarii patru sintaxe. Toate produc același rezultat (10 treceri prin buclă), dar diferă prin claritate și flexibilitate:

| Sintaxă | Formă | Observații |
|---|---|---|
| Lista explicită | `for pas in 1 2 3 4 5 6 7 8 9 10; do` | Clar dar verbos; nepractică pentru intervale mari |
| Expansiune cu acolade | `for pas in {1..10}; do` | Concisă și ușor de citit; nu acceptă variabile în locul limitelor |
| Comandă `seq` | `for pas in $(seq 1 $MAX); do` | Flexibilă — limitele pot fi variabile; apelează un program extern |
| Sintaxă tip C | `for (( pas=1; pas<=10; pas++ )); do` | Familiară celor care cunosc C sau Java; permite expresii complexe |

---

## Flux de execuție — Sinteză

```
┌─────────────────────────────────────┐
│  Citire N de la tastatură (read)    │
└────────────────┬────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────┐
│  N este gol?  → Eroare + ieșire    │
│  N nu e cifre?→ Eroare + ieșire    │
│  N este 0?   → Afișare 0 + ieșire │
└────────────────┬────────────────────┘
                 │  (validare trecută)
                 ▼
┌─────────────────────────────────────┐
│  Estimare inițială: x = N / 2      │
└────────────────┬────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────┐
│  FOR pas = 1 până la 10:           │
│    x = ( x + N/x ) / 2            │
│    Afișare pas curent              │
└────────────────┬────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────┐
│  Afișare rezultat: sqrt(N) ≈ x     │
└─────────────────────────────────────┘
```
