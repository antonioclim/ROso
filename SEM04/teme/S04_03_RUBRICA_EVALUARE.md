# Rubrica de Evaluare - Tema Seminar 07-08

> **Document pentru instructor** | Nu se distribuie studenților înainte de evaluare

---

## Legendă Sistem de Punctare

| Simbol | Semnificație | Exemplu |
|--------|--------------|---------|
| **%** | Procent din nota finală a temei (100%) | Exercițiul 1: 25% din total |
| **Pct (în tabele)** | Puncte relative în cadrul secțiunii | 4 pct din cele 10% ale sub-secțiunii |
| **Ajustare ±X%** | Modificare procentuală aplicată notei finale | Calitate cod: ±5% |

> **Notă importantă**: Punctele din coloanele tabelelor (Pct) sunt **puncte relative** care se adună pentru a forma procentul secțiunii respective. Exemplu: în Exercițiul 1 (25%), sub-secțiunile de 10 + 8 + 7 = 25 puncte relative echivalează cu 25% din nota finală.

---

## Criterii Generale de Evaluare

### Scală de Notare per Criteriu

| Nivel | Punctaj | Descriere |
|-------|---------|-----------|
| **Excelent** | 100% | Depășește așteptările, soluție elegantă și completă |
| **Foarte Bine** | 85% | Toate cerințele îndeplinite corect |
| **Bine** | 70% | Funcționalitate corectă cu mici probleme |
| **Satisfăcător** | 55% | Funcționează parțial, lipsesc elemente |
| **Insuficient** | 30% | Încercare de rezolvare, nu funcționează |
| **Absent** | 0% | Nu a fost predat sau copiat |

---

## Exercițiul 1: Validare și Extragere Date (25%)

### 1.1 Validare Email (10%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| Regex corect | 4 | Detectează toate formatele valide, respinge invalide | Detectează majoritatea, câteva false positive/negative | Pattern simplist, multe erori |
| Separare valid/invalid | 3 | Listare corectă cu explicații | Listare corectă fără detalii | Output confuz |
| Numărare | 2 | Statistici complete | Doar total | Lipsă sau incorect |
| Edge cases | 1 | Gestionează `.co.uk`, `+alias`, etc. | Gestionează cazuri simple | Crash la input neașteptat |

**Regex minim acceptabil:**
```bash
[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}
```

**Regex excelent (bonus):**
```bash
^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z]{2,})+$
```

### 1.2 Extragere IP (8%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| Pattern IP | 3 | Validare strictă (0-255 per octet) | Pattern simplu `[0-9.]+` | Nu funcționează |
| Unicitate | 2 | `sort -u` sau echivalent | Unele duplicate | Liste cu duplicate |
| Sortare numerică | 2 | `sort -t. -k1,1n -k2,2n...` | Sortare alfabetică | Nesortat |
| Output | 1 | Format curat, una per linie | Acceptabil | Confuz |

**Validare strictă IP (bonus +1%):**
```bash
grep -oE '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}'
```

### 1.3 Numere Telefon RO (7%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| Formate multiple | 4 | 07XX-XXX-XXX, 07XX.XXX.XXX, 07XX XXX XXX, 07XXXXXXXX | 2-3 formate | Un singur format |
| Prefix corect | 2 | Validează 07[2-9]X | Acceptă orice 07XX | Acceptă orice număr |
| Output | 1 | Normalizat sau original | Original | Parțial/corupt |

---

## Exercițiul 2: Procesare Log-uri (25%)

### 2.1 Raport Severitate (8%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| Numărare corectă | 4 | Toate nivelurile, exact | Majoritatea corecte | Erori semnificative |
| Procente | 2 | Calculate corect, formatate | Corecte dar neformatate | Lipsă sau greșite |
| Vizualizare | 2 | Grafic ASCII/bare | Tabel simplu | Doar text |

**Soluție referință:**
```bash
awk -F'[][]' '{count[$2]++} END {for(l in count) printf "%-10s %d\n", l, count[l]}'
```

### 2.2 Autentificare Eșuată (9%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| Detectare | 4 | Toate cazurile "failed", "denied", etc. | Doar "failed" explicit | Lipsește sau incomplet |
| Extragere date | 3 | User, IP, timestamp corect | 2 din 3 corecte | Sub 2 corecte |
| Format output | 2 | Tabel organizat | Listare simplă | Raw output |

### 2.3 Statistici Generale (8%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| Perioadă | 3 | Prima/ultima timestamp corect | În jur de | Incorect |
| Total evenimente | 2 | Exact | Corect | Incorect |
| Rata erori | 3 | Calculată și formatată % | Doar număr | Lipsă |

---

## Exercițiul 3: modificare Date (25%)

### 3.1 Conversie Tabel (10%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| Parsare CSV | 3 | Corect cu header skip | Funcționează | Erori la virgule |
| Aliniere coloane | 3 | `printf` cu width fix | Parțial aliniat | Nealiniat |
| Format salariu | 2 | $XX,XXX cu separator mii | Doar $ | Număr brut |
| Header/border | 2 | Box drawing characters | Linii simple | Fără |

**Soluție formatare salariu:**
```bash
awk '{printf "$%\047d\n", $5}'  # sau
printf "%'d" $salary
```

### 3.2 Statistici Departament (8%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| Agregare | 4 | Array-uri asociative AWK | Soluție alternativă funcțională | Nu agregă |
| Calcule | 3 | Mediu, min, max corecte | Doar medie | Erori de calcul |
| Output | 1 | Tabel formatat | Listare | Text neformatat |

**Soluție referință:**
```bash
awk -F',' 'NR>1 {
    dept=$4; sal=$5
    count[dept]++; sum[dept]+=sal
    if(!min[dept] || sal<min[dept]) min[dept]=sal
    if(sal>max[dept]) max[dept]=sal
} END {
    for(d in count) printf "%-12s %3d %8.0f %8d %8d\n", 
        d, count[d], sum[d]/count[d], min[d], max[d]
}'
```

### 3.3 Fișier Actualizat (7%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| Lowercase email | 2 | `tolower()` sau `tr` | Funcționează | Nu modifică |
| Status change | 2 | sed sau awk corect | Funcționează | Erori |
| Coloană nouă | 3 | Calcul ani corect | Aproximare acceptabilă | Lipsă sau greșit |

---

## Exercițiul 4: Pipeline Combinat (25%)

### 4.1 Raport Vânzări (10%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| Top produse | 4 | Revenue calculat corect, sortat | Corect dar top 1 | Incorect |
| Top regiuni | 3 | Agregare corectă | Funcționează | Erori |
| Top vânzător/regiune | 3 | Grupare + max | Parțial | Nu funcționează |

### 4.2 Detectare Anomalii (8%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| Gap-uri date | 3 | Detectare automată | Hardcodat | Lipsă |
| Outliers | 4 | mean + 2*stddev | Threshold fix rezonabil | Nu detectează |
| Raportare | 1 | Clar și specific | Funcțional | Confuz |

### 4.3 Export (7%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| Fișier creat | 3 | Redirect corect | Funcționează | Erori |
| Format | 2 | Professional, lizibil | Acceptabil | Neformatat |
| Completitudine | 2 | Toate datele | Majoritatea | Parțial |

---

## Criterii Transversale (aplicate la toate exercițiile)

### Calitate Cod (ajustare: -5% până la +5% din nota finală)

| Aspect | Bonus | Penalizare |
|--------|-------|------------|
| Comentarii utile | +1 | -1 (lipsă totală) |
| Denumiri clare variabile | +1 | -1 (x, y, tmp) |
| `set -euo pipefail` | +1 | -1 (script fragil) |
| Verificare argumente | +1 | -2 (crash fără args) |
| Funcții modulare | +1 | 0 |

### Error Handling (ajustare: -3% până la +2% din nota finală)

| Aspect | Bonus | Penalizare |
|--------|-------|------------|
| Verifică existența fișierelor | +1 | -1 |
| Mesaje de eroare clare | +1 | -1 |
| Exit codes corecte | 0 | -1 |

---

## Penalizări Speciale

| Situație | Penalizare |
|----------|------------|
| Plagiat detectat | **-100%** (0 puncte) |
| Predare întârziată (< 24h) | -10% |
| Predare întârziată (24-72h) | -25% |
| Predare întârziată (> 72h) | -50% sau refuz |
| Fișiere lipsă din arhivă | -5% per fișier |
| Script neexecutabil | -5% per script |
| Nu funcționează pe Linux standard | -20% |

---

## Checklist Evaluare Rapidă

```
□ Arhiva dezarhivabilă și structură corectă
□ Toate scripturile prezente și executabile
□ Ex1: validator.sh - rulează pe contacts.txt
□ Ex2: log_analyzer.sh - rulează pe server.log  
□ Ex3: data_transform.sh - rulează pe employees.csv
□ Ex4: sales_report.sh - rulează pe sales.csv
□ Output-uri generate în folder-ul output/
□ Cod comentat și cu header
□ Verificat pentru plagiat (diff cu alte submisii)
```

---

## Distribuție Așteptată Note

| Notă | Interval Puncte | Descriere |
|------|-----------------|-----------|
| 10 | 95-100 + bonus | Excelent, depășește cerințele |
| 9 | 85-94 | Foarte bine, toate cerințele |
| 8 | 75-84 | Bine, mici probleme |
| 7 | 65-74 | Satisfăcător, funcționează |
| 6 | 55-64 | Acceptabil, probleme multiple |
| 5 | 45-54 | Minim acceptabil |
| 4 | 30-44 | Insuficient |
| 1-3 | <30 | Nepromovat |

---

*Document intern pentru evaluatori | Seminar 07-08: Text Processing*
