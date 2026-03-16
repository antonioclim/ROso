# Metoda Heron (Babiloniană) — Implementare cu `WHILE` în Bash

## Prezentare generală

Scriptul calculează rădăcina pătrată a unui număr întreg pozitiv folosind **metoda lui Heron** (cunoscută și drept metoda babiloniană). Structura de control aleasă este bucla `while`, care permite oprirea automată în momentul atingerii convergenței — fără a impune un număr fix de iterații.

Formula de rafinare succesivă este:

$$x_{\text{nou}} = \frac{x + \frac{N}{x}}{2}$$

Algoritmul pornește de la o estimare grosieră ($x = N/2$) și o îmbunătățește iterativ până când diferența dintre două valori consecutive devine neglijabilă.

---

## Linia 1 — Declarația interpretorului

```bash
#!/bin/bash
```

Aceasta este linia **shebang** (prescurtare de la *sharp* `#` + *bang* `!`). Sistemul de operare o citește pentru a stabili ce interpretor va executa scriptul. Calea `/bin/bash` indică interpretorul Bash. Fără această linie, sistemul ar putea încerca să ruleze scriptul cu un alt interpretor (de exemplu `sh`, care nu acceptă toate construcțiile Bash).

---

## Liniile 2–16 — Bloc de comentarii (antet descriptiv)

```bash
# =============================================================================
# heron_WHILE.sh
# Metoda Heron (Babiloniana) pentru calculul radacinii patrate
# Structura de control folosita: WHILE
#
# Algoritmul:
#   1. Pornim cu estimarea initiala:  x = N / 2
#   2. Rafinam cu:                    x = ( x + N/x ) / 2
#   3. Ne oprim AUTOMAT cand diferenta dintre doua iteratii consecutive
#      este mai mica decat un prag (0.0000001) — convergenta matematica
#
# De ce WHILE aici?
#   WHILE repeta CAT TIMP o conditie este adevarata.
#   Nu stim dinainte cate iteratii sunt necesare — depinde de N.
#   Pentru N=4 converge in ~4 pasi, pentru N=1000000 poate in 20+.
#   WHILE detecteaza convergenta si se opreste exact la momentul potrivit.
#   Aceasta este varianta cea mai corecta algoritmic dintre cele trei.
# =============================================================================
```

Caracterul `#` marchează un comentariu — tot ce urmează după el pe aceeași linie este ignorat de interpretor. Blocul de aici servește drept documentație internă: explică scopul scriptului, algoritmul folosit și motivația alegerii buclei `while` în locul lui `for`. Delimitatorii vizuali (`=====`) nu au efect funcțional; rolul lor este strict estetic, de separare vizuală.

---

## Secțiunea 1 — Citire intrare

### Linia 23

```bash
read -p "Introdu un numar intreg pozitiv: " N
```

Comanda `read` citește o linie de text de la intrarea standard (tastatură). Parametrul `-p` (de la *prompt*) afișează mesajul indicat înainte de a aștepta introducerea datelor. Valoarea tastată de utilizator este stocată în variabila `N`. Dacă utilizatorul apasă doar Enter fără a scrie nimic, variabila `N` rămâne vidă (șir gol).

---

## Secțiunea 2 — Validarea intrării

### Liniile 30–32 — Verificare câmp gol

```bash
if [ -z "$N" ]; then
    echo "Eroare: nu ai introdus nimic."
    exit 1
fi
```

- **`[ -z "$N" ]`** — Operatorul `-z` (de la *zero*) testează dacă șirul `$N` are lungime zero. Ghilimelele duble în jurul lui `$N` sunt obligatorii: fără ele, dacă `N` este gol, comanda `[` primește prea puține argumente și generează o eroare de sintaxă.
- **`echo`** — Afișează mesajul de eroare pe ecran.
- **`exit 1`** — Termină execuția scriptului cu codul de ieșire `1`. Prin convenție, codul `0` semnalează succes, iar orice valoare diferită de zero semnalează o eroare. Sistemul de operare și alte scripturi pot citi acest cod pentru a decide cum să procedeze.
- **`fi`** — Închide blocul `if` (cuvântul `if` scris invers).

### Liniile 34–37 — Verificare format numeric

```bash
if ! [[ "$N" =~ ^[0-9]+$ ]]; then
    echo "Eroare: '${N}' nu este un intreg pozitiv."
    exit 1
fi
```

- **`[[ ... ]]`** — Construcție Bash extinsă pentru teste condiționale (mai flexibilă decât `[ ... ]`). Acceptă operatorul `=~` pentru compararea cu expresii regulate.
- **`=~`** — Operator de potrivire cu expresie regulată (*regex*).
- **`^[0-9]+$`** — Expresia regulată care descrie „unul sau mai multe cifre, de la început (`^`) până la sfârșit (`$`)". Semnul `+` cere cel puțin o cifră. Dacă `N` conține litere, spații sau alte caractere, potrivirea eșuează.
- **`!`** — Neagă rezultatul testului. Deci întreaga condiție se citește: „dacă `N` **nu** este format exclusiv din cifre".
- **`${N}`** — Acoladele delimitează explicit numele variabilei în interiorul șirului. Aici sunt opționale (ar funcționa și `$N`), dar clarifică unde se termină numele variabilei.

### Liniile 39–42 — Cazul special N = 0

```bash
if [ "$N" -eq 0 ]; then
    echo "sqrt(0) = 0"
    exit 0
fi
```

- **`-eq`** — Operator de comparare aritmetică (*equal*). Compară valori numerice întregi, nu șiruri de caractere (pentru șiruri s-ar folosi `=`).
- Rădăcina pătrată a lui zero este zero — rezultatul este trivial și nu necesită iterații. Scriptul afișează răspunsul și se termină cu `exit 0` (succes).

---

## Secțiunea 3 — Estimare inițială și inițializare contor

### Linia 50

```bash
x=$(echo "scale=8; $N / 2" | bc)
```

Această linie conține mai multe mecanisme Bash combinate:

- **`$( ... )`** — Substituție de comandă. Bash execută comanda din interior, captează textul pe care aceasta îl produce pe ieșirea standard, și înlocuiește întreaga construcție `$(...)` cu textul respectiv.
- **`echo "scale=8; $N / 2"`** — Construiește un șir de caractere care conține o instrucțiune pentru calculatorul `bc`. Variabila `$N` este înlocuită de Bash cu valoarea sa înainte ca `echo` să afișeze rezultatul.
- **`|`** — Operatorul *pipe* (conductă). Redirecționează ieșirea comenzii din stânga (`echo`) către intrarea comenzii din dreapta (`bc`).
- **`bc`** — Calculator aritmetic de linie de comandă, capabil să lucreze cu numere zecimale (spre deosebire de aritmetica nativă Bash, care acceptă doar numere întregi).
- **`scale=8`** — Directivă `bc` care fixează precizia la 8 cifre zecimale. Fără `scale`, împărțirea în `bc` este întreagă (trunchiată).

Rezultat: variabila `x` primește valoarea `N / 2` cu 8 zecimale — aceasta este estimarea inițială a rădăcinii.

### Linia 55

```bash
pas=0
```

Inițializare simplă a unui contor de iterații. În Bash, atribuirea nu folosește spații în jurul semnului `=` — dacă ai scrie `pas = 0`, Bash ar interpreta `pas` ca pe o comandă, iar `=` și `0` ca argumente ale ei.

### Liniile 57–60 — Afișare stare inițială

```bash
echo "--------------------------------------"
echo "Numar:  N = $N"
echo "Start:  x = $x   (estimare initiala = N/2)"
echo "--------------------------------------"
```

Patru apeluri `echo` care afișează o linie de separare, valoarea lui `N`, estimarea inițială `x` și o altă linie de separare. Variabilele `$N` și `$x` sunt expandate de Bash în interiorul ghilimelelor duble.

---

## Secțiunea 4 — Bucla `while` (nucleul algoritmului)

### Linia 82

```bash
while true; do
```

- **`while`** — Cuvânt cheie care începe o buclă. Bash evaluează condiția; dacă aceasta returnează „adevărat" (cod de ieșire 0), execută corpul buclei, apoi reevaluează condiția.
- **`true`** — Comandă internă Bash care returnează întotdeauna codul de ieșire 0 (succes = adevărat). Prin urmare, această buclă rulează la infinit — oprirea ei depinde exclusiv de instrucțiunea `break` din interior.
- **`do`** — Marchează începutul corpului buclei.
- **`;`** — Separatorul permite scrierea lui `while` și `do` pe aceeași linie. Alternativ, `do` ar putea apărea pe linia următoare, fără punct și virgulă.

### Linia 86

```bash
    x_nou=$(echo "scale=8; ($x + $N / $x) / 2" | bc)
```

Formula lui Heron. Structura este identică cu explicația de la estimarea inițială: `echo` construiește expresia, `|` o trimite la `bc`, iar `$(...)` captează rezultatul. Parantezele rotunde din expresie controlează ordinea operațiilor aritmetice în `bc`. Valoarea calculată este stocată într-o variabilă separată (`x_nou`) pentru a permite compararea cu valoarea anterioară (`x`).

### Liniile 90–91

```bash
    pas=$(( pas + 1 ))
```

- **`$(( ... ))`** — Expansiune aritmetică nativă Bash. Evaluează expresia cu numere întregi și returnează rezultatul. Spre deosebire de `bc`, aceasta nu necesită un proces extern, dar nu poate lucra cu zecimale.
- **`pas + 1`** — Incrementare simplă. În interiorul `$(( ))`, variabilele nu necesită prefixul `$` (deși îl acceptă).

### Linia 93

```bash
    echo "Pas $pas: x = $x_nou"
```

Afișează numărul iterației curente și valoarea calculată. Această linie nu influențează algoritmul; rolul ei este pur informativ, pentru a urmări evoluția convergenței.

### Linia 97

```bash
    diff=$(echo "scale=8; $x_nou - $x" | bc)
```

Calculează diferența dintre noua estimare și cea anterioară. Dacă algoritmul a convergit, această diferență se apropie de zero. Valorea poate fi negativă (dacă noua estimare este mai mică decât cea anterioară), motiv pentru care următorul bloc calculează valoarea absolută.

### Liniile 101–103 — Valoare absolută

```bash
    if [ $(echo "$diff < 0" | bc) -eq 1 ]; then
        diff=$(echo "scale=8; -1 * $diff" | bc)
    fi
```

- **`echo "$diff < 0" | bc`** — Trimite o comparație logică la `bc`. Calculatorul `bc` returnează `1` dacă expresia este adevărată și `0` dacă este falsă.
- **`[ ... -eq 1 ]`** — Testul Bash verifică dacă rezultatul lui `bc` este egal cu 1 (adică diferența este negativă).
- **`-1 * $diff`** — Înmulțire cu -1 pentru a obține valoarea absolută. Nu există o funcție `abs()` în `bc` de bază; aceasta este metoda clasică.

### Linia 107

```bash
    x=$x_nou
```

Actualizează estimarea curentă. De acum, variabila `x` conține valoarea cea mai recentă, iar `x_nou` va fi suprascrisă la următoarea iterație. Această linie trebuie să apară **înainte** de testul de convergență, dar **după** calculul diferenței, altfel s-ar pierde informația de comparare.

### Liniile 115–117 — Condiția de oprire

```bash
    if [ $(echo "$diff < 0.0000001" | bc) -eq 1 ]; then
        break
    fi
```

- Mecanismul este identic cu cel de la valoarea absolută: `bc` evaluează expresia logică și returnează 1 sau 0.
- **`0.0000001`** — Pragul de convergență ($10^{-7}$). Când diferența dintre două iterații consecutive scade sub această valoare, algoritmul consideră că a atins o precizie suficientă.
- **`break`** — Comandă Bash care iese imediat din bucla în care se află (în cazul nostru, `while`). Execuția continuă cu prima instrucțiune de după `done`.

### Linia 119

```bash
done
```

Marchează sfârșitul corpului buclei `while`. Dacă `break` nu a fost executat, Bash se întoarce la evaluarea condiției (care este `true`, deci bucla continuă).

---

## Secțiunea 5 — Afișare rezultat final

```bash
echo "--------------------------------------"
echo "Convergenta atinsa in $pas iteratii."
echo "sqrt($N) ≈ $x"
echo "--------------------------------------"
```

Afișează pragul de convergență atins, numărul total de iterații și valoarea finală a rădăcinii pătrate. Simbolul `≈` (aproximativ egal) este un caracter UTF-8 valid în Bash — nu necesită secvențe de protejare speciale atât timp cât terminalul acceptă UTF-8 (ceea ce este cazul standard pe sisteme moderne).

---

## Observații finale — Comparație cu `for`

Blocul final de comentarii din script subliniază diferența fundamentală dintre cele două abordări:

| Criteriu | `for` (iterații fixe) | `while` (convergență) |
|---|---|---|
| Număr de iterații | Stabilit dinainte (de exemplu 10) | Determinat automat de algoritm |
| Risc de prea puține iterații | Da, dacă N este foarte mare | Nu — continuă până la prag |
| Risc de iterații inutile | Da, dacă converge rapid | Nu — se oprește imediat |
| Complexitate cod | Mai simplă | Necesită calcul de diferență și `break` |

Provocarea adresată studenților — „ce se întâmplă dacă înlocuiți `while true` cu `while [ $pas -lt 3 ]`?" — vizează înțelegerea faptului că un număr fix de iterații poate fi insuficient pentru valori mari ale lui `N`, pierzând precizia, sau excesiv pentru valori mici, irosind timp de calcul.

---

## Diagrama fluxului de execuție

```
┌─────────────────────────┐
│  Citire N de la tastatură │
└────────────┬────────────┘
             ▼
     ┌───────────────┐
     │  N valid?      │──── Nu ──▶ Afișare eroare → Ieșire
     └───────┬───────┘
             │ Da
             ▼
     ┌───────────────┐
     │  N == 0?       │──── Da ──▶ Afișare "sqrt(0) = 0" → Ieșire
     └───────┬───────┘
             │ Nu
             ▼
     ┌───────────────┐
     │  x = N / 2     │
     │  pas = 0       │
     └───────┬───────┘
             ▼
     ┌───────────────────────────┐
     │  x_nou = (x + N/x) / 2   │◀──────────────┐
     │  pas = pas + 1            │               │
     │  diff = |x_nou − x|      │               │
     │  x = x_nou               │               │
     └───────────┬───────────────┘               │
                 ▼                               │
        ┌────────────────┐                       │
        │ diff < 10⁻⁷?   │──── Nu ──────────────┘
        └───────┬────────┘
                │ Da
                ▼
     ┌────────────────────┐
     │  Afișare rezultat   │
     └────────────────────┘
```
