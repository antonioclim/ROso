# Autoevaluare și Reflexie: Text Processing
## Verifică-ți Înțelegerea - Regex, GREP, SED, AWK

> **Sisteme de Operare** | Academia de Studii Economice București - CSIE  
> **Seminar 7-8** | Self-Assessment Checklist  
> **Timp**: 10-15 minute | **Completează SINCER**

---

## Instrucțiuni

Această autoevaluare te ajută să identifici ce ai înțeles și unde mai ai nevoie de practică. 

**Reguli:**
1. Completează **SINCER** - nimeni altcineva nu vede răspunsurile
2. Nu folosi Google sau notițe
3. Dacă nu ești sigur, bifează "Nu sunt sigur"
4. La final, concentrează-te pe ariile cu ❌ sau ❓

**Legendă:**
- ✅ Pot explica altcuiva și da exemple
- ❓ Am o idee dar nu sunt sigur pe detalii
- ❌ Nu știu / Nu înțeleg

---

# SECȚIUNEA 1: EXPRESII REGULATE

## 1.1 Metacaractere de Bază

| # | Concept | ✅ | ❓ | ❌ |
|---|---------|:--:|:--:|:--:|
| 1 | Știu ce face `.` (punct) în regex | ☐ | ☐ | ☐ |
| 2 | Știu ce face `^` în afara `[]` | ☐ | ☐ | ☐ |
| 3 | Știu ce face `^` înăuntrul `[]` | ☐ | ☐ | ☐ |
| 4 | Știu ce face `$` | ☐ | ☐ | ☐ |
| 5 | Știu cum să escapez caractere speciale | ☐ | ☐ | ☐ |

## 1.2 Quantificatori

| # | Concept | ✅ | ❓ | ❌ |
|---|---------|:--:|:--:|:--:|
| 6 | Înțeleg diferența între `*` și `+` | ☐ | ☐ | ☐ |
| 7 | Știu ce face `?` | ☐ | ☐ | ☐ |
| 8 | Pot folosi `{n,m}` pentru interval | ☐ | ☐ | ☐ |
| 9 | Înțeleg că `*` poate potrivi zero caractere | ☐ | ☐ | ☐ |

## 1.3 BRE vs ERE - Diferența Critică

| # | Concept | ✅ | ❓ | ❌ |
|---|---------|:--:|:--:|:--:|
| 10 | Știu că grep implicit folosește BRE | ☐ | ☐ | ☐ |
| 11 | Știu când trebuie să folosesc `grep -E` | ☐ | ☐ | ☐ |
| 12 | Înțeleg de ce `grep 'ab+c'` nu funcționează | ☐ | ☐ | ☐ |

### Mini-Test: Poți răspunde?

> **Întrebare**: De ce `grep 'a+b'` nu găsește "aab" dar `grep -E 'a+b'` găsește?

Răspunsul tău (mental sau scris):
```

```

---

# SECȚIUNEA 2: GREP

## 2.1 Opțiuni de Bază

| # | Opțiune | Știu ce face | ✅ | ❓ | ❌ |
|---|---------|--------------|:--:|:--:|:--:|
| 13 | `-i` | | ☐ | ☐ | ☐ |
| 14 | `-v` | | ☐ | ☐ | ☐ |
| 15 | `-n` | | ☐ | ☐ | ☐ |
| 16 | `-c` | | ☐ | ☐ | ☐ |
| 17 | `-o` | | ☐ | ☐ | ☐ |
| 18 | `-E` | | ☐ | ☐ | ☐ |
| 19 | `-r` | | ☐ | ☐ | ☐ |

## 2.2 Comportament

| # | Concept | ✅ | ❓ | ❌ |
|---|---------|:--:|:--:|:--:|
| 20 | Știu că `-c` numără LINII, nu apariții | ☐ | ☐ | ☐ |
| 21 | Știu cum să număr toate aparițiile unui pattern | ☐ | ☐ | ☐ |
| 22 | Înțeleg diferența între `-l` și `-L` | ☐ | ☐ | ☐ |

### Mini-Test

> **Întrebare**: Cum numeri TOATE aparițiile cuvântului "error" într-un fișier (nu liniile)?

Răspunsul tău:
```

```

---

# SECȚIUNEA 3: SED

## 3.1 Substituție

| # | Concept | ✅ | ❓ | ❌ |
|---|---------|:--:|:--:|:--:|
| 23 | Cunosc sintaxa `s/old/new/` | ☐ | ☐ | ☐ |
| 24 | Știu ce face flag-ul `g` | ☐ | ☐ | ☐ |
| 25 | Știu să folosesc delimitatori alternativi | ☐ | ☐ | ☐ |
| 26 | Înțeleg ce face `&` în replacement | ☐ | ☐ | ☐ |
| 27 | Pot folosi backreferences `\1`, `\2` | ☐ | ☐ | ☐ |

## 3.2 Edit In-Place

| # | Concept | ✅ | ❓ | ❌ |
|---|---------|:--:|:--:|:--:|
| 28 | Știu că sed implicit NU modifică fișierul | ☐ | ☐ | ☐ |
| 29 | Știu diferența între `-i` și `-i.bak` | ☐ | ☐ | ☐ |
| 30 | Înțeleg de ce `sed ... > file` e periculos | ☐ | ☐ | ☐ |

## 3.3 Alte Comenzi

| # | Comandă | Știu ce face | ✅ | ❓ | ❌ |
|---|---------|--------------|:--:|:--:|:--:|
| 31 | `d` | | ☐ | ☐ | ☐ |
| 32 | `/pattern/d` | | ☐ | ☐ | ☐ |
| 33 | `1,5d` | | ☐ | ☐ | ☐ |

### Mini-Test

> **Întrebare**: Ce comandă folosești pentru a înlocui TOATE aparițiile lui "localhost" cu "127.0.0.1" în config.txt, păstrând un backup?

Răspunsul tău:
```

```

---

# SECȚIUNEA 4: AWK

## 4.1 Concepte de Bază

| # | Concept | ✅ | ❓ | ❌ |
|---|---------|:--:|:--:|:--:|
| 34 | Știu ce conține `$0` | ☐ | ☐ | ☐ |
| 35 | Știu ce conține `$1`, `$2`, etc. | ☐ | ☐ | ☐ |
| 36 | Știu ce e `$NF` | ☐ | ☐ | ☐ |
| 37 | Înțeleg diferența dintre `NR` și `FNR` | ☐ | ☐ | ☐ |
| 38 | Știu cum să setez separatorul (`-F`) | ☐ | ☐ | ☐ |

## 4.2 Print și Printf

| # | Concept | ✅ | ❓ | ❌ |
|---|---------|:--:|:--:|:--:|
| 39 | Știu diferența între `print $1 $2` și `print $1, $2` | ☐ | ☐ | ☐ |
| 40 | Pot folosi `printf` pentru formatare | ☐ | ☐ | ☐ |

## 4.3 Structură și Control

| # | Concept | ✅ | ❓ | ❌ |
|---|---------|:--:|:--:|:--:|
| 41 | Știu ce face `BEGIN { }` | ☐ | ☐ | ☐ |
| 42 | Știu ce face `END { }` | ☐ | ☐ | ☐ |
| 43 | Pot scrie condiții simple (`$3 > 100`) | ☐ | ☐ | ☐ |
| 44 | Știu cum să fac calcule (sumă, medie) | ☐ | ☐ | ☐ |
| 45 | Înțeleg array-urile asociative | ☐ | ☐ | ☐ |

### Mini-Test

> **Întrebare**: Scrie o comandă awk care afișează suma coloanei 3 dintr-un CSV (skip header).

Răspunsul tău:
```

```

---

# SECȚIUNEA 5: NANO

| # | Concept | ✅ | ❓ | ❌ |
|---|---------|:--:|:--:|:--:|
| 46 | Știu cum să salvez (^O) | ☐ | ☐ | ☐ |
| 47 | Știu cum să ies (^X) | ☐ | ☐ | ☐ |
| 48 | Știu cum să caut (^W) | ☐ | ☐ | ☐ |
| 49 | Știu cum să tai/lipesc linii (^K, ^U) | ☐ | ☐ | ☐ |

---

# SECȚIUNEA 6: PIPELINE-URI

| # | Concept | ✅ | ❓ | ❌ |
|---|---------|:--:|:--:|:--:|
| 50 | Înțeleg cum funcționează `|` (pipe) | ☐ | ☐ | ☐ |
| 51 | Știu de ce `sort` trebuie înainte de `uniq` | ☐ | ☐ | ☐ |
| 52 | Pot combina grep, sed, awk într-un pipeline | ☐ | ☐ | ☐ |

---

# CALCULEAZĂ SCORUL

## Numără răspunsurile

```
Total ✅: _____ / 52
Total ❓: _____ / 52  
Total ❌: _____ / 52
```

## Interpretare

| Scor ✅ | Nivel | Recomandare |
|---------|-------|-------------|
| 45-52 | Expert | Excelent! Ajută-ți colegii |
| 35-44 | Avansat | Bine! Revizuiește zonele cu ❓ |
| 25-34 | Intermediar | OK. Practică mai mult |
| 15-24 | Începător | Recitește materialul |
| 0-14 | Necesită atenție | Vorbește cu instructorul |

---

# IDENTIFICĂ PRIORITĂȚILE

## Unde am cel mai mult sau ?

```
☐ Regex basics (1-5)
☐ Quantificatori (6-9)
☐ BRE vs ERE (10-12)
☐ Grep opțiuni (13-22)
☐ Sed substituție (23-27)
☐ Sed in-place (28-30)
☐ Awk basics (34-38)
☐ Awk print/printf (39-40)
☐ Awk structură (41-45)
☐ Nano (46-49)
☐ Pipeline (50-52)
```

**Top 3 arii de îmbunătățit:**
1. ________________________________
2. ________________________________
3. ________________________________

---

# REFLECȚIE

## Întrebări pentru auto-reflecție

### 1. Ce a fost cel mai surprinzător lucru pe care l-am învățat azi?

```

```

### 2. Ce concept mi s-a părut cel mai greu?

```

```

### 3. Cum aș putea folosi aceste comenzi în proiectele mele?

```

```

### 4. Ce întrebare aș pune dacă aș avea 2 minute cu instructorul?

```

```

---

# PLAN DE ACȚIUNE

## Pentru săptămâna viitoare, mă angajez să:

```
☐ Recitesc secțiunea despre: _________________________

☐ Practic exercițiile de la: _________________________

☐ Încerc să folosesc grep/sed/awk pentru: _________________________

☐ Întreb pe cineva (instructor/coleg) despre: _________________________
```

---

# RĂSPUNSURI LA MINI-TESTE

<details>
<summary>Răspuns Mini-Test 1 (BRE vs ERE)</summary>

În BRE (Basic Regular Expression), `+` este caracter LITERAL. 
`grep 'a+b'` caută textul "a+b" exact.
Cu `grep -E` (Extended RE), `+` devine quantificator = "1 sau mai multe".

</details>

<details>
<summary>Răspuns Mini-Test 2 (Numără toate aparițiile)</summary>

```bash
grep -o 'error' file.txt | wc -l
```

`-o` afișează fiecare potrivire pe linie separată, `wc -l` numără liniile.

</details>

<details>
<summary>Răspuns Mini-Test 3 (sed cu backup)</summary>

```bash
sed -i.bak 's/localhost/127.0.0.1/g' config.txt
```

`-i.bak` = editare in-place cu backup în config.txt.bak
`/g` = global, toate aparițiile

</details>

<details>
<summary>Răspuns Mini-Test 4 (awk suma)</summary>

```bash
awk -F',' 'NR > 1 { sum += $3 } END { print sum }' file.csv
```

`-F','` = separator virgulă
`NR > 1` = skip header
`sum += $3` = adună coloana 3
`END { print sum }` = afișează la final

</details>

---

# RESURSE PENTRU STUDIU SUPLIMENTAR

## Online
- [regex101.com](https://regex101.com) - Tester regex interactiv
- [awk.js.org](https://awk.js.org) - Awk online
- [sed.js.org](https://sed.js.org) - Sed online

## Cărți
- "Sed & Awk" by Dale Dougherty
- "The AWK Programming Language" by Aho, Kernighan, Weinberger

## Practică
- Exercițiile din acest seminar
- Procesează propriile log-uri sau date

---

```
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                         │
│   "Cel mai bun mod de a învăța este să faci."                          │
│                                                                         │
│   Practică 15 minute pe zi cu grep/sed/awk și în 2 săptămâni          │
│   vei fi mai eficient decât 90% dintre utilizatorii Linux.             │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

*Autoevaluare pentru Seminarul 7-8 de Sisteme de Operare | ASE București - CSIE*
