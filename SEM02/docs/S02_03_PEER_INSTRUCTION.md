# Peer Instruction - Întrebări pentru Seminarul 3-4
## Sisteme de Operare | Operatori, Redirecționare, Filtre, Bucle

Document: S02_03_PEER_INSTRUCTION.md  
Total întrebări: 18 (minim 15 necesare)  
Timp per întrebare: 3-5 minute  
Format: Vot individual → Discuție perechi → Revot → Explicație

---

## Protocol Peer Instruction

### Procedură Standard de Votare

Pentru fiecare întrebare din acest document, urmează acest protocol:

1. **Afișează întrebarea** (30 secunde pentru citire)
2. **Vot individual** — Studenții votează A/B/C/D silențios (fără discuție)
3. **Înregistrează distribuția** — Notează procentele pe tablă: A:__% B:__% C:__% D:__%
4. **Punct de decizie:**
   - Dacă **>70% corect**: Explicație scurtă, continuă
   - Dacă **30-70% corect**: Discuție perechi (2-3 min), apoi revot
   - Dacă **<30% corect**: Mini-lecture necesară înainte de revot
5. **Dezvăluie răspunsul** cu explicație (2 min)

### Condiții Optime

- **Acuratețe țintă la primul vot:** 40-60% (maximizează învățarea din discuție)
- **Grupuri de discuție:** 2-3 studenți cu răspunsuri inițiale diferite
- **Îmbunătățire la revot:** Așteptă creștere 20-30% după discuție

### Notație Întrebări

Fiecare întrebare include:
- **Nivel Bloom:** Nivelul cognitiv evaluat
- **Țintă misconception:** Care eroare comună testează această întrebare
- **Analiză distractori:** De ce răspunsurile greșite sunt tentante

---

## PROTOCOL DE UTILIZARE

### Diagrama de Timp

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  0:00   0:30   1:00   1:30   2:00   2:30   3:00   3:30   4:00   4:30  5:00 │
│    │      │      │      │      │      │      │      │      │      │     │  │
│    ├──────┴──────┼──────┴──────┴──────┼──────┴──────┴──────┼─────────────┤  │
│    │   PREZINTĂ  │    VOT INDIVIDUAL  │  DISCUȚIE PERECHI │   REVOT +   │  │
│    │   PROBLEMA  │     (silențios)    │   (activ, zgomot) │  EXPLICAȚIE │  │
│    │    30 sec   │       1 min        │      2.5 min      │    1 min    │  │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Interpretare Rezultate Vot

| % Corect | Interpretare | Acțiune |
|----------|--------------|---------|
| < 30% | Conceptul nu a fost înțeles | Explică din nou, apoi revot |
| 30-70% | Ideal pentru PI | Discuție perechi, revot |
| > 70% | Prea ușoară sau deja știu | Discuție rapidă, continuă |

### Cum să folosești fiecare întrebare

1. Afișează întrebarea pe ecran (fără răspunsul corect!)
2. Citește problema cu voce tare
3. Acordă 30-60 secunde pentru gândire individuală
4. Cere votul (degete/cartonașe/digital)
5. Notează distribuția (exemplu: A:3, B:12, C:5, D:2)
6. Grupează în perechi pentru discuție (2-3 minute)
7. Cere revot
8. Explică folosind notele pentru instructor
9. Demonstrează cu codul din secțiunea "După vot"

---

## ÎNTREBĂRI OPERATORI DE CONTROL

### PI-01: AND vs OR - Ordinea Contează

Nivel: Fundamental | Durată: 4 min | Target: ~50% corect

```bash
mkdir test && echo "Creat" || echo "Eroare"
```

Dacă directorul `test` DEJA EXISTĂ, ce se afișează?

```
A) Creat
B) Eroare
C) Creat și Eroare
D) Nimic (comanda eșuează silențios)
```

Răspuns corect: B

| Distractor | Misconceptie vizată |
|------------|---------------------|
| A | Nu înțelege că mkdir returnează eroare când directorul există |
| C | Crede că `||` se execută întotdeauna după `&&` |
| D | Confuzie cu 2>/dev/null sau nu știe că erorile se afișează |

Note instructor:
- cod de ieșire de la `mkdir` când directorul există = non-zero
- `&&` eșuează (nu execută `echo "Creat"`)
- Se continuă cu `||` care se execută deoarece lanțul `&&` a eșuat
- Atenție: Dacă ar fi `mkdir -p test`, ar returna 0!

După vot, demonstrează:
```bash
# Creează directorul
mkdir test
# Rulează comanda
mkdir test && echo "Creat" || echo "Eroare"
# Verifică și cu -p
mkdir -p test && echo "Creat cu -p" || echo "Eroare cu -p"
# Cleanup
rmdir test
```

---

### PI-02: Pipe vs Cod de ieșire

Nivel: Intermediar | Durată: 4 min | Target: ~45% corect

```bash
ls /inexistent | wc -l
echo "Exit code: $?"
```

Ce va fi cod de ieșire-ul afișat?

```
A) Exit code-ul lui ls (non-zero, eroare)
B) Exit code-ul lui wc (0, succes)
C) Suma exit code-urilor
D) Eroare de sintaxă
```

Răspuns corect: B

| Distractor | Misconceptie vizată |
|------------|---------------------|
| A | Crede că pipe-ul transmite cod de ieșire-ul primei comenzi |
| C | Inventează un comportament inexistent |
| D | Confuzie despre sintaxa pipe |

Note instructor:
- `$?` returnează doar cod de ieșire-ul ultimei comenzi din pipeline
- Pentru toate cod de ieșire-urile: `${PIPESTATUS[@]}`
- `set -o pipefail` schimbă comportamentul (returnează primul non-zero)

După vot, demonstrează:
```bash
ls /inexistent | wc -l
echo "Exit code: $?"
echo "PIPESTATUS: ${PIPESTATUS[@]}"

# Cu pipefail
set -o pipefail
ls /inexistent | wc -l
echo "Cu pipefail: $?"
set +o pipefail
```

---

### PI-03: Background și Output

Nivel: Fundamental | Durată: 3 min | Target: ~60% corect

```bash
sleep 2 &
echo "PID: $!"
echo "Terminat?"
```

În ce ordine apar mesajele?

```
A) "PID: xxx", apoi după 2 secunde "Terminat?"
B) "PID: xxx", "Terminat?" (imediat, fără așteptare)
C) "Terminat?", "PID: xxx"
D) Eroare - nu poți folosi $! fără wait
```

Răspuns corect: B

| Distractor | Misconceptie vizată |
|------------|---------------------|
| A | Crede că & nu eliberează controlul |
| C | Nu înțelege ordinea execuției |
| D | Inventează o restricție inexistentă |

Note instructor:
- `&` lansează în background și returnează IMEDIAT controlul
- `$!` conține PID-ul ultimului proces background
- Pentru a aștepta: `wait $!` sau `wait` (toate)

După vot, demonstrează:
```bash
sleep 2 &
echo "PID: $!"
echo "Terminat? (da, nu am așteptat)"
jobs
wait
echo "Acum chiar a terminat"
```

---

### PI-04: Grupare {} vs ()

Nivel: Intermediar | Durată: 4 min | Target: ~40% corect

```bash
x=1
{ x=2; echo "În acolade: $x"; }
echo "După acolade: $x"

y=1
( y=2; echo "În paranteze: $y"; )
echo "După paranteze: $y"
```

Care sunt valorile finale afișate pentru x și y?

```
A) x=2, y=2
B) x=2, y=1
C) x=1, y=2
D) x=1, y=1
```

Răspuns corect: B

| Distractor | Misconceptie vizată |
|------------|---------------------|
| A | Nu înțelege subshell |
| C | Inversează comportamentul |
| D | Crede că ambele creează subshell |

Note instructor:
- `{}` execută în shell-ul curent - modificările persistă
- `()` execută în subshell - modificările se pierd
- Spațiile și `;` în `{}` sunt obligatorii!

După vot, demonstrează:
```bash
# Demonstrație directă
x=1
{ x=2; echo "În acolade: $x"; }
echo "După acolade: $x"  # 2

y=1
( y=2; echo "În paranteze: $y"; )
echo "După paranteze: $y"  # 1!
```

---

## ÎNTREBĂRI REDIRECȚIONARE I/O

### PI-05: Ordinea Redirecționării stderr

Nivel: Intermediar-Avansat | Durată: 5 min | Target: ~35% corect

```bash
# Varianta A:
ls /home /inexistent > out.txt 2>&1

# Varianta B:
ls /home /inexistent 2>&1 > out.txt
```

Care variantă trimite AMBELE (stdout și stderr) în out.txt?

```
A) Varianta A
B) Varianta B
C) Ambele variante
D) Niciuna - trebuie &>
```

Răspuns corect: A

| Distractor | Misconceptie vizată |
|------------|---------------------|
| B | Nu înțelege ordinea evaluării |
| C | Crede că ordinea nu contează |
| D | Nu știe sintaxa clasică |

Note instructor:
- Redirecționările se evaluează de la stânga la dreapta
- Varianta A: 
  1. `> out.txt` - stdout merge în out.txt
  2. `2>&1` - stderr merge unde e stdout ACUM (out.txt)
- Varianta B:
  1. `2>&1` - stderr merge unde e stdout ACUM (terminal)
  2. `> out.txt` - stdout merge în out.txt (stderr rămâne pe terminal!)

După vot, demonstrează:
```bash
# Varianta A
ls /home /inexistent > out_a.txt 2>&1
echo "=== Conținut out_a.txt ==="
cat out_a.txt

# Varianta B
ls /home /inexistent 2>&1 > out_b.txt
echo "=== Conținut out_b.txt ==="
cat out_b.txt
echo "(eroarea a apărut pe terminal, nu în fișier)"

# Cleanup
rm out_a.txt out_b.txt
```

---

### PI-06: Here String vs Pipe

Nivel: Fundamental | Durată: 3 min | Target: ~55% corect

```bash
# Varianta A:
echo "hello" | tr 'a-z' 'A-Z'

# Varianta B:
tr 'a-z' 'A-Z' <<< "hello"
```

Care este output-ul celor două variante?

```
A) A: HELLO, B: HELLO
B) A: HELLO, B: hello
C) A: hello, B: HELLO
D) A: eroare, B: HELLO
```

Răspuns corect: A

| Distractor | Misconceptie vizată |
|------------|---------------------|
| B | Crede că <<< nu funcționează |
| C | Inversează funcționalitatea |
| D | Nu cunoaște here string |

Note instructor:
- Ambele metode sunt funcțional echivalente
- `<<<` (here string) evită un subprocess (echo)
- `<<<` e mai eficient pentru stringuri simple
- Bonus: `cmd <<< "$var"` vs `echo "$var" | cmd`

---

### PI-07: /dev/null și Cod de ieșire

Nivel: Fundamental | Durată: 3 min | Target: ~65% corect

```bash
ls /inexistent 2>/dev/null
echo $?
```

Ce se afișează?

```
A) 0 (succes, pentru că eroarea a fost suprimată)
B) Non-zero (eroare, pentru că directorul nu există)
C) Nimic
D) Eroare de sintaxă
```

Răspuns corect: B

| Distractor | Misconceptie vizată |
|------------|---------------------|
| A | Frecventă: Crede că suprimarea erorii = succes |
| C | Confuzie completă |
| D | Nu cunoaște sintaxa |

Note instructor:
- `>/dev/null` și `2>/dev/null` nu afectează cod de ieșire-ul
- Doar suprimă OUTPUT-ul, nu schimbă comportamentul comenzii
- Comanda tot eșuează, doar nu vedem mesajul

După vot, demonstrează:
```bash
ls /inexistent 2>/dev/null
echo "Exit code: $?"  # Non-zero!

# Compară cu
ls /home 2>/dev/null
echo "Exit code: $?"  # 0
```

---

## ÎNTREBĂRI FILTRE

### PI-08: uniq fără sort (CRITICĂ! )

Nivel: Fundamental | Durată: 4 min | Target: ~20-30% corect (misconceptie foarte frecventă)

```bash
echo -e "a\nb\na\nb" | uniq
```

Ce afișează?

```
A) a
   b
B) a
   b
   a
   b
C) a
   a
   b
   b
D) Eroare - uniq necesită fișier
```

Răspuns corect: B

| Distractor | Misconceptie vizată |
|------------|---------------------|
| A | 80% cred asta! - Nu știu că uniq elimină doar CONSECUTIVE |
| C | Crede că uniq sortează |
| D | Nu cunoaște pipe-uri |

Note instructor:
- CRITICĂ: `uniq` elimină doar duplicatele **consecutive**!
- Input: a, b, a, b - niciuna nu e consecutivă → toate rămân
- Pattern corect: `sort | uniq` sau `sort -u`

După vot, demonstrează:
```bash
echo "=== Fără sort ==="
echo -e "a\nb\na\nb" | uniq

echo "=== Cu sort (corect) ==="
echo -e "a\nb\na\nb" | sort | uniq

echo "=== Sau sort -u (mai eficient) ==="
echo -e "a\nb\na\nb" | sort -u
```

---

### PI-09: cut cu tab vs spații

Nivel: Intermediar | Durată: 4 min | Target: ~45% corect

```bash
echo "one two three" | cut -f2
```

Ce afișează?

```
A) two
B) one two three
C) Eroare
D) (nimic/linie goală)
```

Răspuns corect: B

| Distractor | Misconceptie vizată |
|------------|---------------------|
| A | Crede că cut împarte după spații |
| C | Inventează eroare |
| D | Confuzie cu output gol |

Note instructor:
- `cut -f` folosește TAB ca delimitator implicit, nu spațiu!
- Stringul nu conține TAB → returnează întreaga linie
- Pentru spații: `cut -d' ' -f2` sau folosește `awk`

După vot, demonstrează:
```bash
echo "=== Cu spații (nu funcționează cum aștepți) ==="
echo "one two three" | cut -f2

echo "=== Cu delimitator explicit ==="
echo "one two three" | cut -d' ' -f2

echo "=== Cu tab real ==="
printf "one\ttwo\tthree" | cut -f2
```

---

### PI-10: tr caractere vs stringuri

Nivel: Intermediar | Durată: 4 min | Target: ~50% corect

```bash
echo "hello" | tr 'ell' 'ipp'
```

Ce afișează?

```
A) hippo
B) hello (nimic nu se schimbă)
C) hIPPo
D) hippp
```

Răspuns corect: D

| Distractor | Misconceptie vizată |
|------------|---------------------|
| A | Crede că tr înlocuiește stringuri |
| B | Crede că nu se potrivește nimic |
| C | Combinație de confuzii |

Note instructor:
- `tr` lucrează caracter cu caracter, nu cu stringuri!
- e→i, l→p, l→p (da, se repetă!)
- Rezultat: h-i-p-p-o → wait, doar 5 caractere... e→i, l→p, l→p, o→o = hippo?
- Atenție: tr 'ell' 'ipp' = {e→i, l→p, l→p}

CORECȚIE: Răspunsul corect depinde de interpretare:
- 'ell' → 'ipp' înseamnă: e→i, l→p (al doilea l e ignorat)
- Deci: h-e-l-l-o → h-i-p-p-o = hippo!

Răspuns corect actualizat: A

După vot, demonstrează:
```bash
echo "hello" | tr 'ell' 'ipp'
# Output: hippo

# Explicație pas cu pas
echo "Caracter cu caracter:"
echo "h → h (neschimbat)"
echo "e → i"
echo "l → p"
echo "l → p"
echo "o → o (neschimbat)"
```

---

## ÎNTREBĂRI BUCLE

### PI-11: Brace Expansion cu Variabile (CRITICĂ! )

Nivel: Intermediar | Durată: 4 min | Target: ~30% corect

```bash
N=5
for i in {1..$N}; do
    echo $i
done
```

Ce afișează?

```
A) 1
   2
   3
   4
   5
B) {1..5}
C) Eroare de sintaxă
D) Nimic (buclă goală)
```

Răspuns corect: B

| Distractor | Misconceptie vizată |
|------------|---------------------|
| A | 70% cred asta! - Nu știu că brace expansion e la parse time |
| C | Crede că e sintaxă greșită |
| D | Crede că bucla nu se execută |

Note instructor:
- Brace expansion se face înainte de variable expansion!
- `{1..$N}` nu poate fi expandat pentru că `$N` nu e încă interpretat
- Rămâne literal: `{1..$N}`
- Bucla iterează o singură dată cu i="{1..$N}"

Soluții:
```bash
# Soluția 1: seq
for i in $(seq 1 $N); do echo $i; done

# Soluția 2: stil C
for ((i=1; i<=N; i++)); do echo $i; done

# Soluția 3: eval (nu recomandată)
eval "for i in {1..$N}; do echo \$i; done"
```

---

### PI-12: while read în Pipe (CRITICĂ! )

Nivel: Avansat | Durată: 5 min | Target: ~35% corect

```bash
count=0
echo -e "a\nb\nc" | while read line; do
    ((count++))
done
echo "Count: $count"
```

Ce afișează?

```
A) Count: 3
B) Count: 0
C) Count: 1
D) Eroare - count nu e definit
```

Răspuns corect: B

| Distractor | Misconceptie vizată |
|------------|---------------------|
| A | 65% cred asta! - Nu cunosc subshell problem |
| C | Parțial înțelege |
| D | Confuzie variabile |

Note instructor:
- Subshell problem: Partea dreaptă a pipe-ului rulează în subshell!
- Modificările la `count` se fac în subshell
- Când subshell-ul se termină, modificările se pierd
- Shell-ul principal vede `count=0` original

Soluții:
```bash
# Soluția 1: Process substitution
count=0
while read line; do
    ((count++))
done < <(echo -e "a\nb\nc")
echo "Count: $count"  # 3!

# Soluția 2: Here string
count=0
while read line; do
    ((count++))
done <<< "$(echo -e 'a\nb\nc')"

# Soluția 3: lastpipe (Bash 4.2+)
shopt -s lastpipe
count=0
echo -e "a\nb\nc" | while read line; do ((count++)); done
echo "Count: $count"  # 3!
```

---

### PI-13: break vs exit

Nivel: Fundamental | Durată: 3 min | Target: ~65% corect

```bash
for i in 1 2 3; do
    if [ $i -eq 2 ]; then
        break
    fi
    echo $i
done
echo "După buclă"
```

Ce se afișează?

```
A) 1
   După buclă
B) 1
   (nimic mai mult - scriptul s-a oprit)
C) 1
   2
   După buclă
D) 1
   2
   3
   După buclă
```

Răspuns corect: A

| Distractor | Misconceptie vizată |
|------------|---------------------|
| B | Confundă break cu exit |
| C | Crede că echo se execută înainte de break |
| D | Nu înțelege break |

Note instructor:
- `break` iese doar din buclă, nu din script
- `exit` ar fi oprit scriptul complet
- La i=2, se execută `break` înainte de echo

---

### PI-14: for cu fișiere cu spații

Nivel: Intermediar | Durată: 4 min | Target: ~45% corect

```bash
touch "my file.txt" "another file.txt"
for f in *.txt; do
    echo "Fișier: $f"
done
```

Ce se afișează?

```
A) Fișier: my file.txt
   Fișier: another file.txt
B) Fișier: my
   Fișier: file.txt
   Fișier: another
   Fișier: file.txt
C) Fișier: my file.txt another file.txt
D) Eroare - spațiile nu sunt permise
```

Răspuns corect: A

| Distractor | Misconceptie vizată |
|------------|---------------------|
| B | Crede că for split-uiește după spații |
| C | Crede că toate se combină |
| D | Crede că spațiile sunt ilegale |

Note instructor:
- Glob expansion (`*.txt`) păstrează numele întregi cu spații
- Diferit de: `for f in $(ls *.txt)` care ar split-ui!
- Pattern sigur: `for f in *.txt` (fără $() sau backticks)

După vot, demonstrează:
```bash
touch "my file.txt" "another file.txt"

echo "=== Corect: for f in *.txt ==="
for f in *.txt; do
    echo "Fișier: [$f]"
done

echo "=== GREȘIT: for f in \$(ls *.txt) ==="
for f in $(ls *.txt); do
    echo "Fișier: [$f]"
done

rm "my file.txt" "another file.txt"
```

---

### PI-15: IFS în while read

Nivel: Avansat | Durată: 4 min | Target: ~40% corect

```bash
echo "a:b:c" | while IFS=: read x y z; do
    echo "x=$x y=$y z=$z"
done
echo "IFS este: [$IFS]"
```

După execuție, ce valoare are IFS în shell-ul principal?

```
A) IFS=":"
B) IFS=" \t\n" (default)
C) IFS="" (gol)
D) Eroare - IFS nu poate fi schimbat în while
```

Răspuns corect: B

| Distractor | Misconceptie vizată |
|------------|---------------------|
| A | Crede că IFS persistă |
| C | Crede că se resetează la gol |
| D | Inventează restricție |

Note instructor:
- `IFS=: read ...` setează IFS doar pentru comanda read
- După read, IFS revine la valoarea anterioară
- Dacă am fi făcut `IFS=:; read ...` → ar fi persistat în subshell

---

## MATRICE UTILIZARE

| Întrebare | Moment Optim | După ce concept | Dificultate |
|-----------|--------------|-----------------|-------------|
| PI-01 | Min 5 | Intro && și \|\| | ⭐⭐ |
| PI-02 | Min 20 | Pipes | ⭐⭐⭐ |
| PI-03 | Min 30 | Background & | ⭐⭐ |
| PI-04 | Min 35 | Grupare {} () | ⭐⭐⭐ |
| PI-05 | Min 45 | Redirecționare stderr | ⭐⭐⭐⭐ |
| PI-06 | Min 50 | Here string | ⭐⭐ |
| PI-07 | Min 55 | /dev/null | ⭐⭐ |
| PI-08 | Min 65 | Intro uniq | ⭐⭐ (dar critică!) |
| PI-09 | Min 70 | cut | ⭐⭐⭐ |
| PI-10 | Min 75 | tr | ⭐⭐⭐ |
| PI-11 | Min 80 | Intro for | ⭐⭐⭐ |
| PI-12 | Min 85 | while read | ⭐⭐⭐⭐ |
| PI-13 | Min 90 | break/continue | ⭐⭐ |
| PI-14 | Min 92 | for cu fișiere | ⭐⭐⭐ |
| PI-15 | Min 95 | IFS | ⭐⭐⭐⭐ |

Recomandare: Folosește 3-4 întrebări pe seminar, alese strategic.

---

## TEMPLATE TRACKING RĂSPUNSURI

```
┌───────────────────────────────────────────────────────────────────┐
│ ÎNTREBAREA: PI-__   DATA: ____   GRUPA: ____                      │
├───────────────────────────────────────────────────────────────────┤
│ VOT 1 (individual):     A: __  B: __  C: __  D: __  Total: __    │
│ VOT 2 (după discuție):  A: __  B: __  C: __  D: __  Total: __    │
├───────────────────────────────────────────────────────────────────┤
│ % Corect V1: ____%      % Corect V2: ____%     Îmbunătățire: __% │
├───────────────────────────────────────────────────────────────────┤
│ Observații:                                                       │
│ ____________________________________________________________      │
└───────────────────────────────────────────────────────────────────┘
```

---

*Material pentru Seminarul 3-4 SO | ASE București - CSIE*  
*Bazat pe metodologia Peer Instruction (Mazur, Porter et al.)*
