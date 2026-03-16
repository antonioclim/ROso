# Metoda Heron (Babiloniană) — Varianta cu `IF`

## Explicație linie cu linie a scriptului `heron_IF.sh`

> **Scopul scriptului:** calculează rădăcina pătrată a unui număr întreg pozitiv
> folosind metoda iterativă Heron (cunoscută și ca metoda babiloniană),
> cu exact 5 pași de rafinare scriși explicit, fără buclă.
>
> **Structura de control dominantă:** `if / elif / else / fi`

---

## Secțiunea 0 — Antetul scriptului

---

```bash
#!/bin/bash
```

**Linia shebang** (de la *sharp* `#` + *bang* `!`). Indică sistemului de operare
ce interpretor să folosească la execuția directă a fișierului.
Calea `/bin/bash` arată că scriptul va fi interpretat de **Bash**
(*Bourne-Again Shell*). Fără această linie, sistemul ar putea alege un alt
interpretor implicit (de exemplu `sh`), care nu suportă toate construcțiile
folosite mai jos (cum ar fi `[[ ... =~ ... ]]`).

---

## Secțiunea 1 — Citirea datei de intrare

---

```bash
read -p "Introdu un numar intreg pozitiv: " N
```

Comanda `read` oprește execuția și așteaptă ca utilizatorul să introducă text
de la tastatură.

| Element | Rol |
|---|---|
| `-p "..."` | Opțiunea *prompt* — afișează textul dintre ghilimele chiar înainte de cursor, pe aceeași linie, fără a fi nevoie de un `echo` separat. |
| `N` | Numele variabilei în care se stochează ceea ce tastează utilizatorul. Din acest moment, valoarea introdusă poate fi accesată cu `$N`. |

Fără opțiunea `-p`, ar fi trebuit să scriem două instrucțiuni:

```bash
echo "Introdu un numar intreg pozitiv: "
read N
```

---

## Secțiunea 2 — Validarea datei de intrare

---

### Testul 1 — câmpul este gol?

```bash
if [ -z "$N" ]; then
```

Deschide un **bloc condițional**. Operatorul `-z` verifică dacă șirul de
caractere are lungime **zero** (adică utilizatorul a apăsat Enter fără să scrie
nimic).

| Element | Rol |
|---|---|
| `if` | Cuvânt-cheie care începe o structură de decizie. |
| `[` … `]` | Comanda `test` scrisă prescurtat. Parantezele pătrate *trebuie* separate prin spațiu de conținut. |
| `-z "$N"` | Returnează *adevărat* dacă lungimea lui `$N` este zero. Ghilimelele duble sunt obligatorii — fără ele, pe un câmp gol, comanda `test` primește un număr greșit de argumente și semnalează eroare de sintaxă. |
| `; then` | Marchează începutul blocului de instrucțiuni ce se execută dacă testul este adevărat. Caracterul `;` separă două instrucțiuni pe aceeași linie. Alternativ, `then` poate fi scris pe linia următoare, caz în care `;` nu mai este necesar. |

---

```bash
    echo "Eroare: nu ai introdus nimic. Rulati din nou."
```

Afișează un mesaj de eroare pe ecran. Comanda `echo` trimite textul dintre
ghilimele către ieșirea standard (de regulă terminalul).

---

```bash
    exit 1
```

Termină imediat execuția scriptului și returnează **codul de ieșire 1**.
Convențional, codul 0 semnifică *succes*, iar orice valoare diferită de zero
semnifică *eroare*. Acest cod poate fi verificat ulterior de un alt script sau
de interpretor (prin variabila specială `$?`).

---

### Testul 2 — conține doar cifre?

```bash
elif ! [[ "$N" =~ ^[0-9]+$ ]]; then
```

Dacă primul test a eșuat (câmpul nu este gol), se trece la a doua ramură.

| Element | Rol |
|---|---|
| `elif` | Prescurtare de la *else if* — introduce o condiție suplimentară, evaluată doar dacă toate condițiile anterioare au fost *false*. |
| `!` | Operator de negare logică. Inversează rezultatul testului care urmează: dacă testul intern este adevărat, `!` îl face fals, și invers. |
| `[[ ... ]]` | Construcție extinsă de test, specifică interpretorului Bash. Spre deosebire de `[ ... ]`, suportă expresii regulate și nu necesită protejarea variabilelor prin ghilimele în toate situațiile (deși ghilimelele rămân o practică bună). |
| `=~` | Operator de potrivire cu **expresie regulată** (disponibil doar în `[[ ... ]]`). |
| `^[0-9]+$` | Expresia regulată propriu-zisă: |

Detaliu despre expresia regulată:

| Simbol | Semnificație |
|---|---|
| `^` | Ancorează potrivirea la **începutul** șirului. |
| `[0-9]` | O clasă de caractere — acceptă orice cifră de la 0 la 9. |
| `+` | Cuantificator — una sau mai multe apariții ale elementului anterior. |
| `$` | Ancorează potrivirea la **sfârșitul** șirului. |

Împreună: șirul trebuie să conțină exclusiv cifre, de la primul la ultimul caracter. Prin negarea cu `!`, condiția devine *adevărată* atunci când inputul **nu** este format doar din cifre.

---

```bash
    echo "Eroare: '${N}' nu este un intreg pozitiv."
```

Afișează valoarea introdusă chiar în mesajul de eroare, ca utilizatorul să vadă
exact ce a tastat.

| Element | Rol |
|---|---|
| `${N}` | Forma extinsă de referire la variabila `N`. Acoladele delimitează explicit numele variabilei. Sunt obligatorii atunci când variabila este lipită de alt text (de exemplu `${N}lei`), dar reprezintă o practică bună și în restul situațiilor. |

---

```bash
    exit 1
```

Idem — încheie scriptul cu cod de eroare.

---

### Testul 3 — cazul special N = 0

```bash
elif [ "$N" -eq 0 ]; then
```

Dacă inputul a trecut primele două verificări (nu este gol și conține doar cifre),
se testează dacă valoarea este zero.

| Element | Rol |
|---|---|
| `-eq` | Operator de comparație **numerică** (*equal*). Compară valorile ca numere întregi, nu ca șiruri de caractere. |

Alte operatoare de comparație numerică disponibile în Bash:

| Operator | Semnificație |
|---|---|
| `-ne` | diferit (*not equal*) |
| `-lt` | mai mic strict (*less than*) |
| `-le` | mai mic sau egal (*less or equal*) |
| `-gt` | mai mare strict (*greater than*) |
| `-ge` | mai mare sau egal (*greater or equal*) |

Pentru compararea **șirurilor de caractere**, se folosesc `=` sau `==`, nu `-eq`.

---

```bash
    echo "Radacina patrata a lui 0 este 0."
    exit 0
```

Cazul `N = 0` este tratat separat deoarece formula Heron presupune împărțirea la `x`,
iar estimarea inițială `x = N / 2 = 0` ar provoca o **împărțire la zero**.
Rădăcina lui 0 este trivial 0, deci se afișează direct și se iese cu cod de succes.

---

```bash
fi
```

Închide **întregul bloc** `if / elif / else`. Cuvântul `fi` este `if` scris
invers — aceeași convenție de închidere ca `done` pentru `for`/`while` sau
`esac` pentru `case`.

---

## Secțiunea 3 — Estimarea inițială

---

```bash
x=$(echo "scale=6; $N / 2" | bc)
```

Această linie calculează estimarea inițială `x = N / 2` cu precizie de 6 zecimale.

| Element | Rol |
|---|---|
| `$(...)` | **Substituție de comandă.** Execută comanda din interior și înlocuiește întreaga construcție cu textul pe care acea comandă l-a tipărit. |
| `echo "scale=6; $N / 2"` | Pregătește o expresie matematică sub formă de text. `scale=6` stabilește numărul de cifre zecimale. |
| `\|` | **Conductă** (*pipe*). Trimite ieșirea comenzii din stânga drept intrare pentru comanda din dreapta. |
| `bc` | **Calculator de precizie arbitrară** (*basic calculator*). Bash nativ lucrează doar cu numere întregi — `bc` permite aritmetică cu virgulă mobilă. |

Rezultatul (un număr zecimal cu 6 cifre după virgulă) este stocat în variabila `x`.

---

```bash
echo "--------------------------------------"
echo "Numar:  N = $N"
echo "Start:  x = $x   (estimare initiala = N/2)"
echo "--------------------------------------"
```

Bloc de afișare pur informativ. Tipărește un antet cu valoarea lui `N` și
estimarea inițială `x`, delimitat vizual prin linii de cratime.

---

## Secțiunea 4 — Cei 5 pași Heron (scriși explicit)

---

### Formula Heron

Formula de rafinare iterativă este:

$$
x_{\text{nou}} = \frac{x_{\text{vechi}} + \dfrac{N}{x_{\text{vechi}}}}{2}
$$

**Intuiție:** dacă `x` este mai mare decât `√N`, atunci `N/x` este mai mic
decât `√N`. Media aritmetică a celor două valori cade **între** ele, deci
mai aproape de rădăcina reală. La fiecare pas, eroarea scade dramatic
(convergență pătratică — numărul de cifre corecte se dublează aproximativ
la fiecare iterație).

---

### Pasul 1

```bash
x=$(echo "scale=6; ($x + $N / $x) / 2" | bc)
```

Aplică formula Heron o singură dată. Valoarea veche a lui `x` este folosită
în membrul drept, iar rezultatul suprascrie aceeași variabilă `x`.

Mecanismul este identic cu cel descris la estimarea inițială:
`echo` construiește expresia, `bc` o evaluează, `$(...)` captează rezultatul.

---

```bash
echo "Pas 1:  x = $x"
```

Afișează noua valoare după prima rafinare.

---

### Pașii 2–5

```bash
x=$(echo "scale=6; ($x + $N / $x) / 2" | bc)
echo "Pas 2:  x = $x"
```

```bash
x=$(echo "scale=6; ($x + $N / $x) / 2" | bc)
echo "Pas 3:  x = $x"
```

```bash
x=$(echo "scale=6; ($x + $N / $x) / 2" | bc)
echo "Pas 4:  x = $x"
```

```bash
x=$(echo "scale=6; ($x + $N / $x) / 2" | bc)
echo "Pas 5:  x = $x"
```

Linii identice cu pasul 1, repetate manual de încă patru ori.

**Aceasta este limitarea pedagogică intenționată** a variantei cu `IF`:
pentru 5 pași, avem 5 copii ale aceleiași instrucțiuni. Dacă am vrea
100 de pași, am avea 100 de linii identice — ceea ce face codul imposibil de
întreținut. Variantele cu `FOR` sau `WHILE` rezolvă această problemă prin
intermediul **buclelor**.

---

```bash
echo "--------------------------------------"
```

Separator vizual înainte de secțiunea de evaluare.

---

## Secțiunea 5 — Evaluarea preciziei rezultatului

---

### Calculul erorii

```bash
eroare=$(echo "scale=6; $x * $x - $N" | bc)
```

Calculează diferența `x² − N`. Dacă `x` ar fi exact `√N`, acest rezultat
ar fi 0. În practică, cu aritmetică în virgulă mobilă, obținem o valoare
foarte mică, pozitivă sau negativă.

---

### Valoarea absolută a erorii

```bash
if [ $(echo "$eroare < 0" | bc) -eq 1 ]; then
```

Verifică dacă eroarea este negativă.

| Element | Rol |
|---|---|
| `echo "$eroare < 0" \| bc` | Trimite o comparație logică către `bc`. Calculatorul returnează `1` dacă condiția este adevărată, `0` dacă este falsă. |
| `$(...)` | Captează acel `1` sau `0`. |
| `-eq 1` | Compară numeric — dacă `bc` a răspuns `1`, înseamnă că eroarea este negativă. |

---

```bash
    eroare=$(echo "scale=6; -1 * $eroare" | bc)
```

Dacă eroarea era negativă, o înmulțim cu `−1` pentru a obține **valoarea
absolută**. Astfel, variabila `eroare` va conține întotdeauna o valoare
pozitivă (sau zero), reprezentând `|x² − N|`.

---

```bash
fi
```

Închide blocul `if` al valorii absolute.

---

### Clasificarea preciziei

```bash
if [ $(echo "$eroare < 0.001" | bc) -eq 1 ]; then
```

Prima ramură: testează dacă eroarea absolută este mai mică decât 0,001.
Mecanismul este identic — `bc` evaluează comparația și returnează `1` sau `0`.

---

```bash
    echo "Rezultat: EXCELENT — sqrt($N) ≈ $x"
    echo "          Eroarea |x^2 - N| = $eroare  (< 0.001)"
```

Dacă eroarea este sub 0,001, rezultatul este clasificat drept **excelent**.
Se afișează atât aproximarea, cât și eroarea numerică.

---

```bash
elif [ $(echo "$eroare < 0.01" | bc) -eq 1 ]; then
```

A doua ramură: dacă eroarea nu este sub 0,001, se verifică dacă este sub 0,01.

---

```bash
    echo "Rezultat: BUN      — sqrt($N) ≈ $x"
    echo "          Eroarea |x^2 - N| = $eroare  (< 0.01)"
```

Rezultat clasificat drept **bun** — precizie acceptabilă, dar nu ideală.

---

```bash
else
```

Ramura implicită: dacă niciuna dintre condițiile anterioare nu a fost
îndeplinită, eroarea este ≥ 0,01.

---

```bash
    echo "Rezultat: SLAB     — sqrt($N) ≈ $x"
    echo "          Eroarea |x^2 - N| = $eroare  (>= 0.01)"
```

Rezultat clasificat drept **slab**. Aceasta se poate întâmpla pentru valori
foarte mari ale lui `N`, unde 5 pași nu sunt suficienți pentru convergență.

---

```bash
fi
```

Închide blocul `if / elif / else` al clasificării.

---

```bash
echo "--------------------------------------"
```

Separator vizual final — marchează sfârșitul ieșirii scriptului.

---

## Sinteză — structura de control `IF`

| Unde este folosit `IF` | Ce decide |
|---|---|
| Secțiunea 2 — validare | Input gol? Nu e cifră? Este zero? |
| Secțiunea 5 — valoare absolută | Eroarea este negativă? |
| Secțiunea 5 — clasificare | Eroare < 0,001? < 0,01? altfel? |

`IF` alege **o singură ramură** dintre mai multe posibile și o execută.
Nu repetă nimic — pentru repetiție se folosesc buclele `FOR` și `WHILE`,
prezentate în variantele ulterioare ale aceluiași algoritm.
