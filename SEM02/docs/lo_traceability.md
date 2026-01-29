# Matrice Trasabilitate Learning Outcomes - Seminarul 02
## Sisteme de Operare | Operatori, Redirecționare, Filtre, Bucle

**Document**: lo_traceability.md  
**Versiune**: 1.0 | **Data**: Ianuarie 2025  
**Scop**: Mapare Learning Outcomes → Activități → Evaluare

---

## 1. LEARNING OUTCOMES (LO)

### Nivel APPLY (Anderson-Bloom)

| ID | Learning Outcome | Verb Bloom |
|----|------------------|------------|
| LO1 | Combină comenzi folosind operatorii de control (`;`, `&&`, `\|\|`, `&`) | Apply |
| LO2 | Redirecționează input și output folosind `>`, `>>`, `<`, `<<`, `<<<` | Apply |
| LO3 | Construiește pipeline-uri cu `\|` și `tee` | Apply |
| LO4 | Folosește filtrele: `sort`, `uniq`, `cut`, `paste`, `tr`, `wc`, `head`, `tail` | Apply |
| LO5 | Scrie bucle `for`, `while`, `until` cu control flow (`break`, `continue`) | Apply |

### Nivel ANALYSE (Anderson-Bloom)

| ID | Learning Outcome | Verb Bloom |
|----|------------------|------------|
| LO6 | Diagnostichează erori folosind exit codes și PIPESTATUS | Analyse |
| LO7 | Compară eficiența diferitelor abordări pentru aceeași problemă | Analyse |
| LO8 | Evaluează cod generat de LLM-uri pentru corectitudine | Analyse |

### Nivel CREATE (Anderson-Bloom)

| ID | Learning Outcome | Verb Bloom |
|----|------------------|------------|
| LO9 | Proiectează pipeline-uri pentru procesarea datelor | Create |
| LO10 | Automatizează task-uri administrative cu scripturi | Create |

---

## 2. MATRICE TRASABILITATE: LO → ACTIVITĂȚI

| LO | Peer Instruction | Parsons Problems | Live Coding | Sprint | LLM-Aware | Demo |
|----|------------------|------------------|-------------|--------|-----------|------|
| LO1 | PI-01, PI-03, PI-04 | PP-01, PP-02, PP-03 | LC-01 | S-O1, S-O2 | - | D-01 |
| LO2 | PI-05, PI-06, PI-07 | PP-04, PP-05 | LC-02 | S-R1, S-R2 | - | D-02 |
| LO3 | PI-02 | PP-06 | LC-03 | S-P1, S-P2 | L1 | D-03 |
| LO4 | PI-08, PI-09, PI-10 | PP-07, PP-08 | LC-04 | S-F1, S-F2, S-F3 | - | D-04 |
| LO5 | PI-11, PI-12, PI-13, PI-14 | PP-09, PP-10, PP-11, PP-12 | LC-05 | S-B1, S-B2 | - | D-05 |
| LO6 | PI-02, PI-08 | PP-BONUS-1 | LC-06 | S-D1 | L2 | - |
| LO7 | PI-15 | PP-BONUS-2 | - | S-C1 | L1 | - |
| LO8 | - | - | - | - | L1, L2, L3 | - |
| LO9 | - | PP-BONUS-3, PP-BONUS-4 | LC-07 | S-I1 | - | D-06 |
| LO10 | - | PP-BONUS-5 | - | S-I2 | L3 | - |

---

## 3. MATRICE TRASABILITATE: LO → FIȘIERE

| LO | Fișier Principal | Fișiere Suport |
|----|------------------|----------------|
| LO1 | S02_02_MATERIAL_PRINCIPAL.md §1 | S02_03_PEER_INSTRUCTION.md, S02_04_PARSONS_PROBLEMS.md |
| LO2 | S02_02_MATERIAL_PRINCIPAL.md §2 | S02_05_LIVE_CODING_GUIDE.md |
| LO3 | S02_02_MATERIAL_PRINCIPAL.md §3 | S02_08_DEMO_SPECTACULOASE.md |
| LO4 | S02_02_MATERIAL_PRINCIPAL.md §4 | S02_06_EXERCITII_SPRINT.md |
| LO5 | S02_02_MATERIAL_PRINCIPAL.md §5 | S02_04_PARSONS_PROBLEMS.md |
| LO6 | S02_01_GHID_INSTRUCTOR.md | S02_10_AUTOEVALUARE_REFLEXIE.md |
| LO7 | S02_07_LLM_AWARE_EXERCISES.md | S02_09_CHEAT_SHEET_VIZUAL.md |
| LO8 | S02_07_LLM_AWARE_EXERCISES.md | - |
| LO9 | S02_06_EXERCITII_SPRINT.md | S02_08_DEMO_SPECTACULOASE.md |
| LO10 | S02_01_TEMA.md | S02_03_RUBRICA_EVALUARE.md |

---

## 4. MATRICE EVALUARE: LO → ASSESSMENT

| LO | Quiz Formativ | Temă | Examen |
|----|---------------|------|--------|
| LO1 | q01, q02, q03, q05 | ex1_operatori.sh | Da |
| LO2 | q06, q07, q08, q09 | ex2_redirectare.sh | Da |
| LO3 | q04, q21 | ex2_redirectare.sh | Da |
| LO4 | q10, q11, q12, q13, q14, q15 | ex3_filtre.sh | Da |
| LO5 | q16, q17, q18, q19, q20 | ex4_bucle.sh | Da |
| LO6 | q04, q08 | ex5_integrat.sh | Da |
| LO7 | q22, q25 | ex5_integrat.sh | Parțial |
| LO8 | - | Bonus | Nu |
| LO9 | q21 | ex5_integrat.sh | Da |
| LO10 | q23, q24 | ex5_integrat.sh | Parțial |

---

## 5. PARSONS PROBLEMS BONUS — CU DISTRACTORI BASH-SPECIFICI

Aceste probleme vizează misconceptii frecvente în Bash scripting.
Distractorii exploatează erori de sintaxă comune.

---

### PP-BONUS-1: Verificare Fișier cu Backup
**Nivel**: Intermediar | **LO**: LO1, LO2, LO6 | **Timp**: 4 min

**Obiectiv**: Creează backup DOAR dacă fișierul sursă există.

```
╔══════════════════════════════════════════════════════════════════════════════╗
║  🎯 COMPORTAMENT:                                                            ║
║  - Dacă data.txt există → copiază în backup/ și afișează "OK"               ║
║  - Dacă data.txt NU există → afișează "Eroare"                              ║
╠══════════════════════════════════════════════════════════════════════════════╣
║  LINII AMESTECATE (2 sunt DISTRACTORI):                                     ║
║  ─────────────────────────────────────────────────────────────────────────  ║
║     [[ -f data.txt ]]                                                       ║
║     && cp data.txt backup/                                                  ║
║     && echo "OK"                                                            ║
║     || echo "Eroare"                                                        ║
║     [ -f data.txt ] =                           ← DISTRACTOR: spații la =   ║
║     [[ -f "data.txt"]] && cp                    ← DISTRACTOR: lipsă spațiu  ║
║  ─────────────────────────────────────────────────────────────────────────  ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

**Soluția corectă** (o singură linie sau pe linii separate cu `\`):
```bash
[[ -f data.txt ]] && cp data.txt backup/ && echo "OK" || echo "Eroare"
```

**Explicație distractori**:

| Distractor | Problema BASH-specifică |
|------------|-------------------------|
| `[ -f data.txt ] =` | Spații la `=` sunt eroare de sintaxă în atribuire, dar aici e plasat greșit complet |
| `[[ -f "data.txt"]]` | Lipsă spațiu înainte de `]]` - eroare de sintaxă în Bash |

**Misconceptie vizată**: Studenții uită că `[[ ]]` necesită spații obligatorii după `[[` și înainte de `]]`.

---

### PP-BONUS-2: Pipeline cu Numărare
**Nivel**: Intermediar | **LO**: LO3, LO4, LO7 | **Timp**: 5 min

**Obiectiv**: Numără IP-urile unice din access.log care au erori 404.

```
╔══════════════════════════════════════════════════════════════════════════════╗
║  🎯 COMPORTAMENT:                                                            ║
║  - Filtrează liniile cu "404"                                               ║
║  - Extrage primul câmp (IP-ul)                                              ║
║  - Numără IP-urile unice                                                    ║
╠══════════════════════════════════════════════════════════════════════════════╣
║  LINII AMESTECATE (2 sunt DISTRACTORI):                                     ║
║  ─────────────────────────────────────────────────────────────────────────  ║
║     grep "404" access.log                                                   ║
║     | cut -d' ' -f1                                                         ║
║     | sort                                                                  ║
║     | uniq                                                                  ║
║     | wc -l                                                                 ║
║     | uniq | sort                               ← DISTRACTOR: ordine greșită║
║     | cut -f1                                   ← DISTRACTOR: lipsă -d' '   ║
║  ─────────────────────────────────────────────────────────────────────────  ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

**Soluția corectă**:
```bash
grep "404" access.log | cut -d' ' -f1 | sort | uniq | wc -l
```

**Explicație distractori**:

| Distractor | Problema BASH-specifică |
|------------|-------------------------|
| `\| uniq \| sort` | Ordinea `uniq \| sort` e greșită - `uniq` elimină doar duplicate CONSECUTIVE |
| `\| cut -f1` | Fără `-d' '`, cut folosește TAB ca delimitator, nu spațiu |

**Misconceptie vizată**: 
1. `uniq` necesită input sortat pentru a funcționa corect
2. `cut -f` implicit folosește TAB, nu spațiu

---

### PP-BONUS-3: Buclă cu Variabilă
**Nivel**: Avansat | **LO**: LO5, LO9 | **Timp**: 5 min

**Obiectiv**: Iterează de la 1 la N (unde N e variabilă) și afișează fiecare număr.

```
╔══════════════════════════════════════════════════════════════════════════════╗
║  🎯 COMPORTAMENT:                                                            ║
║  - N=5                                                                       ║
║  - Afișează: 1, 2, 3, 4, 5 (pe linii separate)                              ║
╠══════════════════════════════════════════════════════════════════════════════╣
║  LINII AMESTECATE (2 sunt DISTRACTORI):                                     ║
║  ─────────────────────────────────────────────────────────────────────────  ║
║     #!/bin/bash                                                             ║
║     N=5                                                                     ║
║     for i in $(seq 1 $N); do                                                ║
║         echo $i                                                             ║
║     done                                                                    ║
║     for i in {1..$N}; do                        ← DISTRACTOR: brace + var   ║
║     N = 5                                       ← DISTRACTOR: spații la =   ║
║  ─────────────────────────────────────────────────────────────────────────  ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

**Soluția corectă**:
```bash
#!/bin/bash
N=5
for i in $(seq 1 $N); do
    echo $i
done
```

**Alternative corecte**:
```bash
for ((i=1; i<=N; i++)); do echo $i; done
```

**Explicație distractori**:

| Distractor | Problema BASH-specifică |
|------------|-------------------------|
| `for i in {1..$N}; do` | Brace expansion se face ÎNAINTE de variable expansion - `{1..$N}` rămâne literal |
| `N = 5` | Spațiile în jurul `=` la atribuire variabilă cauzează eroare în Bash |

**Misconceptie vizată**: 
1. Brace expansion `{1..5}` nu funcționează cu variabile
2. Atribuirea variabilelor în Bash NU permite spații: `VAR=value` corect, `VAR = value` GREȘIT

---

### PP-BONUS-4: While Read fără Subshell
**Nivel**: Avansat | **LO**: LO5, LO6, LO9 | **Timp**: 6 min

**Obiectiv**: Citește un fișier linie cu linie și numără liniile, păstrând valoarea counter-ului.

```
╔══════════════════════════════════════════════════════════════════════════════╗
║  🎯 COMPORTAMENT:                                                            ║
║  - Citește input.txt linie cu linie                                         ║
║  - Numără liniile într-o variabilă count                                    ║
║  - La final, afișează "Total: X" cu valoarea CORECTĂ                        ║
╠══════════════════════════════════════════════════════════════════════════════╣
║  LINII AMESTECATE (2 sunt DISTRACTORI):                                     ║
║  ─────────────────────────────────────────────────────────────────────────  ║
║     count=0                                                                  ║
║     while read line; do                                                      ║
║         ((count++))                                                          ║
║     done < input.txt                                                         ║
║     echo "Total: $count"                                                     ║
║     cat input.txt | while read line; do        ← DISTRACTOR: pipe=subshell  ║
║     done                                                                     ║
║     echo "Total: $count"                        ← parte din distractor       ║
║     while read $line; do                        ← DISTRACTOR: $ în read      ║
║  ─────────────────────────────────────────────────────────────────────────  ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

**Soluția corectă**:
```bash
count=0
while read line; do
    ((count++))
done < input.txt
echo "Total: $count"
```

**Explicație distractori**:

| Distractor | Problema BASH-specifică |
|------------|-------------------------|
| `cat input.txt \| while read line; do ... done` | Pipe-ul creează SUBSHELL - modificările la `count` se pierd! |
| `while read $line; do` | La `read`, variabila se scrie FĂRĂ `$`: `read line`, nu `read $line` |

**Misconceptie vizată**: 
1. Subshell problem - partea dreaptă a pipe-ului rulează în subshell
2. Sintaxa `read` - variabila destinație se scrie fără prefix `$`

---

### PP-BONUS-5: Script cu Redirecționare stderr
**Nivel**: Avansat | **LO**: LO2, LO6, LO10 | **Timp**: 5 min

**Obiectiv**: Rulează o comandă și salvează ATÂT stdout CÂT și stderr în log.txt.

```
╔══════════════════════════════════════════════════════════════════════════════╗
║  🎯 COMPORTAMENT:                                                            ║
║  - Rulează: ls /home /inexistent                                            ║
║  - Salvează AMBELE output-uri (normal + erori) în log.txt                   ║
╠══════════════════════════════════════════════════════════════════════════════╣
║  LINII AMESTECATE (2 sunt DISTRACTORI):                                     ║
║  ─────────────────────────────────────────────────────────────────────────  ║
║     #!/bin/bash                                                             ║
║     ls /home /inexistent > log.txt 2>&1                                     ║
║     echo "Log salvat"                                                        ║
║     ls /home /inexistent 2>&1 > log.txt        ← DISTRACTOR: ordine greșită ║
║     ls /home /inexistent > log.txt 2>log.txt   ← DISTRACTOR: fără &1        ║
║  ─────────────────────────────────────────────────────────────────────────  ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

**Soluția corectă**:
```bash
#!/bin/bash
ls /home /inexistent > log.txt 2>&1
echo "Log salvat"
```

**Alternativă corectă** (Bash-specific):
```bash
ls /home /inexistent &> log.txt
```

**Explicație distractori**:

| Distractor | Problema BASH-specifică |
|------------|-------------------------|
| `ls ... 2>&1 > log.txt` | Ordinea contează! 2>&1 redirecționează stderr unde e stdout ACUM (terminal), apoi stdout merge în fișier |
| `ls ... > log.txt 2>log.txt` | Două redirecționări separate pot cauza race condition și date amestecate |

**Misconceptie vizată**: 
1. Ordinea redirecționărilor se evaluează stânga→dreapta
2. `2>&1` înseamnă "stderr merge unde e stdout în acest moment"

---

## 6. SUMAR DISTRACTORI BASH-SPECIFICI FOLOSIȚI

| ID | Distractor | Eroare Bash | Frecvență |
|----|------------|-------------|-----------|
| D1 | `VAR = value` | Spații la atribuire | 85% |
| D2 | `[[ -f file]]` | Lipsă spațiu înainte de `]]` | 60% |
| D3 | `{1..$N}` | Brace expansion cu variabile | 70% |
| D4 | `$()` vs backticks | Diferențe de nesting | 40% |
| D5 | `uniq` fără `sort` | Elimină doar consecutive | 80% |
| D6 | `cut -f` fără `-d` | TAB implicit vs spațiu | 65% |
| D7 | `read $var` | $ în loc de nume simplu | 45% |
| D8 | `2>&1 >` vs `> 2>&1` | Ordinea redirecționării | 55% |
| D9 | `pipe \| while` | Subshell problem | 65% |
| D10 | `[ ]` vs `[[ ]]` | Diferențe de comportament | 50% |

---

## 7. VERIFICARE ACOPERIRE

### Checklist per LO

| LO | Peer Instr. | Parsons | Quiz | Temă | Total Activități |
|----|-------------|---------|------|------|------------------|
| LO1 | ✓ (3) | ✓ (3) | ✓ (4) | ✓ | 11 |
| LO2 | ✓ (3) | ✓ (2) | ✓ (4) | ✓ | 10 |
| LO3 | ✓ (1) | ✓ (1) | ✓ (2) | ✓ | 5 |
| LO4 | ✓ (3) | ✓ (2) | ✓ (6) | ✓ | 12 |
| LO5 | ✓ (4) | ✓ (4) | ✓ (5) | ✓ | 14 |
| LO6 | ✓ (2) | ✓ (1) | ✓ (2) | ✓ | 6 |
| LO7 | ✓ (1) | ✓ (1) | ✓ (2) | ✓ | 5 |
| LO8 | - | - | - | Bonus | 1 |
| LO9 | - | ✓ (2) | ✓ (1) | ✓ | 4 |
| LO10 | - | ✓ (1) | ✓ (2) | ✓ | 4 |

**Concluzie**: Toate LO-urile au acoperire adecvată prin multiple tipuri de activități.

---

*Material pentru Seminarul 02 SO | ASE București - CSIE*  
*Bazat pe principiile Backward Design (Wiggins & McTighe)*
