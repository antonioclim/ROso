# Rubrica de Evaluare - Tema Seminar 01-02

> **Document pentru instructor** | Nu se distribuie studenților înainte de evaluare

---

## Legendă Sistem de Punctare

| Simbol | Semnificație | Exemplu |
|--------|--------------|---------|
| **%** | Procent din nota finală a temei (100%) | Secțiunea 1: 25% din total |
| **Pct (în tabele)** | Puncte relative în cadrul secțiunii | 4 pct din cele 10% ale sub-secțiunii |
| **Ajustare ±X%** | Modificare procentuală aplicată notei finale | Calitate cod: ±5% |

> **Notă importantă**: Punctele din coloanele tabelelor (Pct) sunt **puncte relative** care se adună pentru a forma procentul secțiunii respective. Exemplu: în Secțiunea 1 (25%), sub-criteriile de 10 + 8 + 7 = 25 puncte relative echivalează cu 25% din nota finală.

---

## Criterii Generale de Evaluare

### Scală de Notare per Criteriu

| Nivel | Punctaj | Descriere |
|-------|---------|-----------|
| **Excelent** | 100% | Depășește așteptările, soluție elegantă |
| **Foarte Bine** | 85% | Toate cerințele îndeplinite corect |
| **Bine** | 70% | Funcționalitate corectă cu mici probleme |
| **Satisfăcător** | 55% | Funcționează parțial, lipsesc elemente |
| **Insuficient** | 30% | Încercare de rezolvare, nu funcționează |
| **Absent** | 0% | Nu a fost predat sau copiat |

---

## Secțiunea 1: Variabile (25%)

### 1.1 Variabile Locale (10%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| Definire corectă | 4 | Minim 3 variabile, sintaxă corectă | 2 variabile corecte | Erori de sintaxă |
| Utilizare în echo | 3 | Interpolate corect în stringuri | Afișate individual | Neafișate |
| Tipuri variate | 3 | String, număr, path | Doar stringuri | Un singur tip |

### 1.2 Variabile de Mediu (8%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| Afișare standard | 4 | USER, HOME, SHELL, PATH | 3 din 4 | Sub 3 |
| Formatare output | 2 | Aliniat, etichetat | Funcțional | Neformatat |
| Explicații | 2 | Comentarii ce face fiecare | Comentarii minime | Fără comentarii |

### 1.3 Export și Subshell (7%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| Demo export | 4 | Diferența local/exportat demonstrată | Parțial demonstrat | Nu demonstrează |
| Subshell test | 3 | `bash -c` corect folosit | Funcționează | Erori |

---

## Secțiunea 2: Quoting și Exit Codes (20%)

### 2.1 Single vs Double Quotes (10%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| Demo single quotes | 3 | Variabilă neexpandată demonstrată | Funcționează | Incorect |
| Demo double quotes | 3 | Variabilă expandată demonstrată | Funcționează | Incorect |
| Escape characters | 2 | `\$`, `\"`, `\\` demonstrate | Unul demonstrat | Lipsă |
| Explicație | 2 | Comentarii clare | Comentarii minime | Fără |

### 2.2 Exit Codes (10%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| Capturare `$?` | 4 | După comandă reușită și eșuată | Doar una | Incorect |
| Demonstrație `ls` | 3 | Director valid și invalid | Una din două | Lipsă |
| Interpretare | 3 | Explicație 0 vs non-0 | Menționat | Lipsă |

---

## Secțiunea 3: Globbing și FHS (30%)

### 3.1 Crearea Fișierelor de Test (8%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| Brace expansion | 4 | `touch file{1..10}.txt` | Comenzi individuale | Manual |
| Varietate extensii | 2 | .txt, .pdf, .jpg minim | Două tipuri | Un tip |
| Fișier ascuns | 2 | `.hidden` creat și demonstrat | Creat fără demo | Lipsă |

### 3.2 Pattern Matching (12%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| Wildcard `*` | 3 | `*.txt` corect | Funcționează | Erori |
| Range `[1-5]` | 3 | `file[1-5].txt` corect | Funcționează | Incorect |
| Wildcard `?` | 3 | `?????.???` demonstrat | Parțial | Lipsă |
| Explicație | 3 | Documentație completă | Comentarii | Lipsă |

### 3.3 Fișiere Ascunse (10%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| Demo `ls *` vs `ls .*` | 5 | Diferență explicată | Demonstrat fără explicație | Lipsă |
| Explicație dotfiles | 5 | Înțelegere completă a comportamentului glob | Menționat | Lipsă |

---

## Secțiunea 4: .bashrc Personalizat (25%)

### 4.1 Alias-uri (10%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| `ll` pentru ls -la | 3 | Corect definit | Funcționează | Lipsă |
| `cls` pentru clear | 2 | Corect definit | Funcționează | Lipsă |
| `..` pentru cd .. | 2 | Corect definit | Funcționează | Lipsă |
| Alias personalizat | 3 | Util și funcțional | Definit | Lipsă sau trivial |

### 4.2 Funcții (10%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| `mkcd` implementat | 6 | `mkdir -p && cd` corect | Funcționează parțial | Nu funcționează |
| Funcție extract (bonus) | 4 | Case pentru tar.gz, zip, etc. | 2 formate | Lipsă |

### 4.3 Variabile și PATH (5%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| PATH modificat | 2 | $HOME/bin adăugat | Altceva adăugat | Lipsă |
| EDITOR setat | 1 | nano sau altul | Setat | Lipsă |
| HISTSIZE | 2 | Mărit rezonabil | Setat | Lipsă |

---

## Criterii Transversale

### Calitate Cod (ajustare: -5% până la +5% din nota finală)

| Aspect | Bonus | Penalizare |
|--------|-------|------------|
| Comentarii utile | +1 | -1 (lipsă totală) |
| Structură organizată | +1 | -1 (haotic) |
| Header cu autor/dată | +1 | -1 (lipsă) |
| Emoji-uri/formatare plăcută | +1 | 0 |
| Script executabil | 0 | -2 (trebuie `bash script.sh`) |

### Documentație README (ajustare: -3% până la +3% din nota finală)

| Aspect | Bonus | Penalizare |
|--------|-------|------------|
| README complet | +2 | -2 (lipsă) |
| Instrucțiuni rulare | +1 | -1 |

---

## Penalizări Speciale

| Situație | Penalizare |
|----------|------------|
| Plagiat detectat | **-100%** (0 puncte) |
| Predare întârziată (< 24h) | -10% |
| Predare întârziată (24-72h) | -25% |
| Fișiere lipsă | -5% per fișier |
| Nu funcționează pe Linux | -20% |

---

## Checklist Evaluare Rapidă

```
□ Arhiva corect denumită (NumePrenume_Seminar1.zip)
□ AUTOR.txt prezent cu informații complete
□ variabile.sh - rulează fără erori
□ info_sistem.sh - afișează informații corecte
□ test_globbing.sh - demonstrează pattern-uri
□ .bashrc - alias-uri și mkcd funcționale
□ README.md - documentație prezentă
□ Cod comentat și cu header
```

---

*Document intern pentru evaluatori | Seminar 01-02: Shell Basics*
