# Matrice Trasabilitate Learning Outcomes
## Seminarul 04: Text Processing — Regex, GREP, SED, AWK

> Sisteme de Operare | ASE București - CSIE  
> Document de trasabilitate pedagogică  
> Versiune: 1.0 | Ianuarie 2025

---

## 1. Learning Outcomes (LO)

| ID | Learning Outcome | Nivel Bloom | Verificare |
|----|------------------|-------------|------------|
| **LO1** | Scrie expresii regulate BRE și ERE funcționale | APPLY | Quiz R1, U1, U2, A1, AN1 |
| **LO2** | Folosește grep cu opțiunile principale pentru căutare text | APPLY | Quiz R2, U3, A1, A4, Sprint G1 |
| **LO3** | Transformă text cu sed (substituție, ștergere, inserare) | APPLY | Quiz R3, U4, A2, A5, Sprint S1 |
| **LO4** | Procesează date structurate cu awk (câmpuri, calcule) | APPLY | Quiz U5, A3, Sprint A1 |
| **LO5** | Combină tools în pipeline-uri eficiente | ANALYSE | Quiz A4, AN1, AN2, Parsons PP-C1-5 |

---

## 2. Matrice LO × Activități

```
                        │ Material │ Peer    │ Live   │ Sprint │ Parsons │ Quiz │ Temă │
                        │ Principal│ Instr.  │ Coding │        │         │      │      │
────────────────────────┼──────────┼─────────┼────────┼────────┼─────────┼──────┼──────┤
LO1: Regex BRE/ERE      │    ✓     │  PI-R1-6│   LC1  │   —    │  PP-C1  │ R1,U1│  Ex1 │
LO2: grep opțiuni       │    ✓     │  PI-G1-6│   LC2  │  G1-G4 │  PP-C2  │ R2,A1│  Ex1 │
LO3: sed transformări   │    ✓     │  PI-S1-6│   LC3  │  S1-S4 │  PP-C3  │ R3,A2│  Ex2 │
LO4: awk procesare      │    ✓     │  PI-A1-6│   LC4  │  A1-A2 │  PP-C4  │ U5,A3│  Ex3 │
LO5: Pipeline-uri       │    ✓     │    —    │   LC5  │ Bonus  │  PP-C5  │ A4,AN│  Ex4 │
────────────────────────┴──────────┴─────────┴────────┴────────┴─────────┴──────┴──────┘

Legendă:
  ✓ = acoperit complet
  PI-X = Peer Instruction questions
  LC = Live Coding session
  PP-C = Parsons Problem Combo
```

---

## 3. Distribuție Bloom în Quiz

| Nivel | Țintă | Actual | Întrebări |
|-------|-------|--------|-----------|
| REMEMBER | 15-20% | 18% | R1, R2, R3 |
| UNDERSTAND | 25-30% | 33% | U1, U2, U3, U4, U5 |
| APPLY | 30-35% | 33% | A1, A2, A3, A4, A5 |
| ANALYSE | 10-15% | 14% | AN1, AN2 |
| EVALUATE | 3-5% | 0% | — |
| CREATE | 3-5% | 0% | — |

**Notă:** EVALUATE și CREATE sunt acoperite în Temă și Proiecte, nu în quiz-ul formativ.

---

## 4. Mapping Misconceptii → Întrebări

| Misconceptie | ID | Întrebare care o testează |
|--------------|----|---------------------------|
| M1.1: Confuzie `*` glob vs regex | U1, A1 | "În BRE, * este literal?" |
| M1.2: Confuzie `^` anchor vs negație | U2 | "Ce potrivește ^[^#]?" |
| M2.1: Confuzie `-v` verbose vs invert | R2 | "Ce face -v în grep?" |
| M2.2: `uniq` fără `sort` | A4 | "De ce trebuie sort înainte?" |
| M3.1: sed înlocuiește toate implicit | U4 | "Fără /g, câte înlocuiește?" |
| M3.2: Substituție vs ștergere | A2 | "s/^$// vs /^$/d" |
| M4.1: Indexare câmpuri de la 0 | U5 | "$1 sau $0 pentru primul?" |
| M4.2: sum=$3 vs sum+=$3 | A3 | "Care adună corect?" |

---

## 5. Parsons Problems — Pipeline Combinations

Aceste probleme testează **LO5: Combinarea tools în pipeline-uri** și includ distractori specifici Bash.

---

### PP-C1: Extragere și Numărare IP-uri Unice

**Obiectiv:** Extrage IP-urile unice din access.log, sortate după frecvență.

**Linii amestecate:**
```
A) | head -10
B) grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' access.log
C) | sort -rn
D) | sort
E) | uniq -c
```

**Distractori (linii cu erori comune Bash):**
```
X1) grep -oE '[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}' access.log
    # EROARE: . neescapat potrivește ORICE caracter

X2) | uniq -c | sort
    # EROARE: uniq ÎNAINTE de sort nu funcționează corect

X3) grep -o '([0-9]{1,3}\.){3}[0-9]{1,3}' access.log
    # EROARE: lipsește -E, parantezele sunt literale în BRE
```

**Soluție corectă:** B → D → E → C → A
```bash
grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' access.log | sort | uniq -c | sort -rn | head -10
```

**Explicație:**
1. B: Extrage IP-uri cu regex ERE (-E pentru {})
2. D: Sortează alfabetic (OBLIGATORIU înainte de uniq)
3. E: Numără aparițiile consecutive
4. C: Sortează numeric descrescător
5. A: Afișează top 10

---

### PP-C2: Filtrare Log-uri cu Excluderi Multiple

**Obiectiv:** Găsește erorile din server.log, excluzând liniile de debug și comentariile.

**Linii amestecate:**
```
A) grep -i 'error' server.log
B) | grep -v '^#'
C) | grep -v 'DEBUG'
D) | wc -l
```

**Distractori:**
```
X1) grep -i error server.log
    # EROARE: 'error' fără ghilimele poate fi interpretat greșit cu caractere speciale

X2) | grep -v ^#
    # EROARE: ^ fără ghilimele poate fi interpretat de shell

X3) grep -i 'error' | grep -v '^#' server.log
    # EROARE: fișierul specificat la al doilea grep, nu primul
```

**Soluție corectă:** A → B → C → D
```bash
grep -i 'error' server.log | grep -v '^#' | grep -v 'DEBUG' | wc -l
```

**Explicație:**
1. A: Găsește linii cu "error" (case-insensitive)
2. B: Exclude comentariile (linii care încep cu #)
3. C: Exclude mesajele de debug
4. D: Numără rezultatul

---

### PP-C3: Transformare Format Date cu sed

**Obiectiv:** Convertește datele din format US (MM/DD/YYYY) în format RO (DD.MM.YYYY).

**Linii amestecate:**
```
A) sed -E
B) 's/([0-9]{2})\/([0-9]{2})\/([0-9]{4})/\2.\1.\3/g'
C) date.txt
D) > date_ro.txt
```

**Distractori:**
```
X1) sed 's/([0-9]{2})\/([0-9]{2})\/([0-9]{4})/\2.\1.\3/g' date.txt
    # EROARE: BRE necesită \( \) pentru grupare, sau folosește -E

X2) sed -E 's/[0-9]{2}/[0-9]{2}/[0-9]{4}/\2.\1.\3/g' date.txt
    # EROARE: lipsesc parantezele de captură ()

X3) sed -E "s/([0-9]{2})\/([0-9]{2})\/([0-9]{4})/$2.$1.$3/g" date.txt
    # EROARE: $1, $2 în loc de \1, \2 ($ e pentru shell, nu sed)
```

**Soluție corectă:** A B C D (pe o singură linie)
```bash
sed -E 's/([0-9]{2})\/([0-9]{2})\/([0-9]{4})/\2.\1.\3/g' date.txt > date_ro.txt
```

**Explicație:**
1. A: sed cu Extended regex (-E)
2. B: Pattern cu 3 grupuri de captură, reordonate în output
3. C: Fișierul de intrare
4. D: Redirecționare către fișierul de ieșire

---

### PP-C4: Raport CSV cu awk

**Obiectiv:** Din employees.csv, calculează salariul mediu pe departament.

**Linii amestecate:**
```
A) awk -F,
B) 'NR>1 {dept[$3]+=$4; count[$3]++}
C) END {for (d in dept) printf "%s: %.2f\n", d, dept[d]/count[d]}'
D) employees.csv
E) | sort
```

**Distractori:**
```
X1) awk -F ','
    # EROARE: spațiu între -F și ',' cauzează probleme

X2) 'NR>=1 {dept[$3]+=$4; count[$3]++}
    # EROARE: NR>=1 include header-ul (trebuie NR>1)

X3) END {for (d in dept) print d, dept[d]/count[d]}'
    # EROARE: print fără printf nu formatează zecimalele

X4) awk -F, '{dept[$3]+=$4; count[$3]++} END {...}' employees.csv
    # EROARE: lipsește NR>1, procesează și header-ul
```

**Soluție corectă:** A B C D E
```bash
awk -F, 'NR>1 {dept[$3]+=$4; count[$3]++} END {for (d in dept) printf "%s: %.2f\n", d, dept[d]/count[d]}' employees.csv | sort
```

**Explicație:**
1. A: Setează delimitatorul CSV
2. B: Pentru fiecare linie (exceptând header), adună salariu și numără
3. C: La final, calculează și afișează media formatată
4. D: Fișierul de intrare
5. E: Sortează rezultatul alfabetic

---

### PP-C5: Script Validare cu Funcții

**Obiectiv:** Creează un script care validează un fișier de configurare.

**Linii amestecate:**
```
A) #!/bin/bash
B) set -euo pipefail
C) CONFIG_FILE="${1:?Utilizare: $0 <config_file>}"
D) validate_format() {
E)     grep -qE '^[A-Z_]+=' "$1" || return 1
F) }
G) if validate_format "$CONFIG_FILE"; then
H)     echo "Format valid"
I) else
J)     echo "Format INVALID" >&2
K)     exit 1
L) fi
```

**Distractori:**
```
X1) CONFIG_FILE=$1
    # EROARE: nu verifică dacă argumentul există

X2) CONFIG_FILE = "${1:?...}"
    # EROARE: spații în jurul = la atribuire variabilă

X3) validate_format() {
        grep -qE "^[A-Z_]+=" $1 || return 1
    }
    # EROARE: $1 fără ghilimele — probleme cu spații în filename

X4) if [ validate_format "$CONFIG_FILE" ]; then
    # EROARE: [ ] pentru test, nu pentru rulare comandă

X5) CONFIG_FILE="${1?"Utilizare: $0 <config_file>"}"
    # EROARE: :? vs ? — :? verifică și șirul gol
```

**Soluție corectă:** A → B → C → D → E → F → G → H → I → J → K → L
```bash
#!/bin/bash
set -euo pipefail
CONFIG_FILE="${1:?Utilizare: $0 <config_file>}"
validate_format() {
    grep -qE '^[A-Z_]+=' "$1" || return 1
}
if validate_format "$CONFIG_FILE"; then
    echo "Format valid"
else
    echo "Format INVALID" >&2
    exit 1
fi
```

**Explicație:**
1. A: Shebang pentru bash
2. B: Modul strict (oprește la erori)
3. C: Verifică argument cu mesaj de eroare
4. D-F: Funcție de validare (grep quiet cu regex)
5. G-L: Logică condițională cu mesaje corespunzătoare

---

## 6. Checklist Acoperire LO

### LO1: Regex BRE/ERE ✅
- [x] Material Principal: Modulul 1 complet
- [x] Peer Instruction: PI-R1 până la PI-R6
- [x] Quiz: R1, U1, U2, A1, AN1
- [x] Parsons: PP-C1 (escape puncte), PP-C3 (grupuri captură)

### LO2: grep opțiuni ✅
- [x] Material Principal: Modulul 2 complet
- [x] Peer Instruction: PI-G1 până la PI-G6
- [x] Live Coding: LC2
- [x] Sprint: G1-G4
- [x] Quiz: R2, U3, A1, A4
- [x] Parsons: PP-C1, PP-C2

### LO3: sed transformări ✅
- [x] Material Principal: Modulul 3 complet
- [x] Peer Instruction: PI-S1 până la PI-S6
- [x] Live Coding: LC3
- [x] Sprint: S1-S4
- [x] Quiz: R3, U4, A2, A5
- [x] Parsons: PP-C3

### LO4: awk procesare ✅
- [x] Material Principal: Modulul 4 complet
- [x] Peer Instruction: PI-A1 până la PI-A6
- [x] Live Coding: LC4
- [x] Sprint: A1-A2
- [x] Quiz: U5, A3
- [x] Parsons: PP-C4

### LO5: Pipeline-uri ✅
- [x] Material Principal: Combinații Frecvente
- [x] Live Coding: LC5
- [x] Sprint: Exerciții Bonus
- [x] Quiz: A4, AN1, AN2
- [x] Parsons: PP-C1 până la PP-C5 (toate)

---

## 7. Referințe Încrucișate

| Fișier | LO Acoperite | Bloom Predominant |
|--------|--------------|-------------------|
| S04_02_MATERIAL_PRINCIPAL.md | LO1-5 | UNDERSTAND |
| S04_03_PEER_INSTRUCTION.md | LO1-4 | UNDERSTAND |
| S04_04_PARSONS_PROBLEMS.md | LO1-5 | APPLY |
| S04_05_LIVE_CODING_GUIDE.md | LO1-5 | APPLY |
| S04_06_EXERCITII_SPRINT.md | LO2-4 | APPLY |
| formative/quiz.yaml | LO1-5 | MIXED |
| S04_01_TEMA_OBLIGATORIE.md | LO1-5 | APPLY/CREATE |

---

*Document generat pentru trasabilitatea pedagogică — Seminarul 04*
