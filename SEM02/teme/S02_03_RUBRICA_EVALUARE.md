# Rubrica de Evaluare - Tema Seminar 2

> **Document pentru instructor** | Nu se distribuie studenților înainte de evaluare

---

## Legendă Sistem de Punctare

| Simbol | Semnificație | Exemplu |
|--------|--------------|---------|
| **%** | Procent din nota finală a temei (100%) | PARTEA 1: 20% din total |
| **Pct (în tabele)** | Puncte relative în cadrul secțiunii | 3 pct din cele 7% ale exercițiului |
| **Ajustare ±X%** | Modificare procentuală aplicată notei finale | Calitate cod: ±5% |

> **Notă importantă**: Punctele din coloanele tabelelor (Pct) sunt **puncte relative** care se adună pentru a forma procentul secțiunii respective. Exemplu: în PARTEA 1 (20%), exercițiile de 7 + 7 + 6 = 20 puncte relative echivalează cu 20% din nota finală.

---

## Criterii Generale de Evaluare

### Scală de Notare

| Nivel | Punctaj | Descriere |
|-------|---------|-----------|
| **Excelent** | 100% | Depășește așteptările, soluție elegantă |
| **Foarte Bine** | 85% | Toate cerințele îndeplinite corect |
| **Bine** | 70% | Funcționalitate corectă cu mici probleme |
| **Satisfăcător** | 55% | Funcționează parțial |
| **Insuficient** | 30% | Încercare, nu funcționează |
| **Absent** | 0% | Nu a fost predat sau copiat |

---

## PARTEA 1: Operatori de Control (20%)

### Ex 1.1: Backup Safe (7%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| Verificare argument | 2 | Gestionează lipsa argument | Eroare generică | Crash |
| Operatori `&&` `||` | 3 | Logică corectă, fără if | Folosește if dar funcționează | Nu funcționează |
| Timestamp în nume | 2 | Format corect `date +%Y%m%d_%H%M%S` | Timestamp parțial | Lipsă timestamp |

**Soluție referință:**
```bash
[[ -z "$1" ]] && echo "Usage: $0 <file>" && exit 1
[[ -f "$1" ]] && mkdir -p backup && cp "$1" "backup/${1%.*}_$(date +%Y%m%d_%H%M%S).${1##*.}" && echo "✓ Backup creat" || echo "✗ Fișierul nu există"
```

### Ex 1.2: Multi-Command (7%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| One-liner valid | 3 | O singură linie completă | Mai multe linii | Nu funcționează |
| Toate fișierele create | 2 | README.md, main.sh, .gitignore | 2 din 3 | Sub 2 |
| Mesaj final | 2 | Afișează conținut director | Mesaj simplu | Lipsă |

### Ex 1.3: Parallel Demo (6%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| Procese paralele `&` | 3 | sleep-uri în paralel demonstrabile | Funcționează | Secvențial |
| Demonstrație timing | 2 | Măsurare cu `time` | Menționat | Lipsă |
| Wait corect | 1 | `wait` la final | Lipsă dar funcționează | Procese orfane |

---

## PARTEA 2: Redirecționare (20%)

### Ex 2.1: Log Separator (7%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| Redirect stdout | 3 | `> normal.log` corect | Funcționează | Incorect |
| Redirect stderr | 3 | `2> errors.log` corect | Funcționează | Incorect |
| Fișiere create | 1 | Ambele cu conținut corect | Unul corect | Lipsă |

### Ex 2.2: Config Generator (7%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| Here document | 4 | `<< EOF` corect | Funcționează | echo-uri multiple |
| Variabile în heredoc | 2 | `$USER`, `$HOME` expandate | Parțial | Toate literale |
| Structură config | 1 | Format corect INI/conf | Conținut corect | Neformatat |

### Ex 2.3: Silent Runner (6%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| Redirect la /dev/null | 3 | `&>/dev/null` sau `>/dev/null 2>&1` | Doar stdout | Afișează output |
| Cod return verificat | 2 | Folosește `$?` corect | Menționat | Lipsă |
| Mesaj succes/eroare | 1 | Mesaje clare | Mesaj generic | Lipsă |

---

## PARTEA 3: Filtre și Pipeline-uri (25%)

### Ex 3.1: Top Words (6%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| Pipeline corect | 3 | `tr \| sort \| uniq -c \| sort -rn \| head` | Funcționează altfel | Nu funcționează |
| Lowercase | 1 | `tr 'A-Z' 'a-z'` | Alt mod | Case-sensitive |
| Top N parametrizat | 2 | Acceptă argument pentru N | Hardcodat 10 | Lipsă |

**Soluție referință:**
```bash
tr -cs 'A-Za-z' '\n' < "$1" | tr 'A-Z' 'a-z' | sort | uniq -c | sort -rn | head -n "${2:-10}"
```

### Ex 3.2: CSV Analyzer (7%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| Parsare CSV | 3 | `cut -d,` sau `awk -F,` | Funcționează | Erori |
| Statistici corecte | 2 | Count, sum, avg | 2 din 3 | Sub 2 |
| Header skip | 2 | `NR>1` sau `tail -n+2` | Funcționează | Include header |

### Ex 3.3: Log Stats (6%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| Extragere pattern | 3 | grep/awk pentru IP, date, etc. | Parțial | Incorect |
| Agregare | 2 | `sort \| uniq -c` | Funcționează | Lipsă |
| Formatare output | 1 | Tabel aliniat | Listare | Raw |

### Ex 3.4: Frequency Counter (6%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| Numărare corectă | 3 | Frecvențe exacte | Aproximative | Erori |
| Sortare descrescător | 2 | `-rn` corect | Sortat diferit | Nesortat |
| Output formatat | 1 | printf aliniat | Funcțional | Brut |

---

## PARTEA 4: Bucle (20%)

### Ex 4.1: Batch Rename (5%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| For loop corect | 2 | `for f in *.txt` | Alt pattern | Hardcodat |
| Redenumire sigură | 2 | `mv "$f" "..."` cu ghilimele | Funcționează | Erori la spații |
| Logging | 1 | Afișează ce a redenumit | Mesaj final | Silențios |

### Ex 4.2: File Processor (5%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| While read corect | 3 | `while IFS= read -r line` | `while read line` | for cu cat |
| Procesare | 2 | Acțiune pe fiecare linie | Funcționează | Lipsă |

### Ex 4.3: Countdown (5%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| Until/while corect | 2 | Logică inversată corect | For descendent | Incorect |
| Argument validat | 2 | Verifică număr pozitiv | Funcționează | Crash la invalid |
| Sleep 1 | 1 | Pauză între numere | Pauză diferită | Fără pauză |

### Ex 4.4: Menu System (5%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| Case statement | 3 | Minimum 4 opțiuni | 3 opțiuni | Sub 3 |
| Loop pentru repetiție | 1 | Revine la meniu | One-shot | Lipsă |
| Quit option | 1 | Ieșire curată | Ctrl+C | Lipsă |

---

## PARTEA 5: Proiect Final (15%)

### System Report (15%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| Info sistem complet | 4 | hostname, uptime, kernel, CPU, RAM | 4 din 5 | Sub 4 |
| Disk usage | 3 | `df -h` parsat frumos | Raw df | Lipsă |
| Top procese | 3 | `ps aux` + sort + head | Funcționează | Lipsă |
| Rețea | 2 | IP-uri, interfețe | Parțial | Lipsă |
| Formatare raport | 3 | Secțiuni clare, borduri | Funcțional | Brut |

---

## BONUS (până la +20% bonus)

| Exercițiu | Puncte | Cerință |
|-----------|--------|---------|
| Parallel download | +5 | wget/curl în paralel cu & și wait |
| Log rotator | +5 | Compresie și numerotare automată |
| Backup incremental | +5 | Compară timestamps, copiază doar modified |
| Interactive installer | +5 | Menu + verificări + instalare |

---

## Criterii Transversale

### Calitate Cod (ajustare: -5% până la +5% din nota finală)

| Aspect | Bonus | Penalizare |
|--------|-------|------------|
| Comentarii | +1 | -1 |
| Shebang prezent | 0 | -2 |
| Permisiuni +x | 0 | -1 per script |
| Ghilimele la variabile | +1 | -2 |
| `set -e` folosit | +1 | 0 |

---

## Penalizări Speciale

| Situație | Penalizare |
|----------|------------|
| Plagiat | **-100%** |
| Întârziere < 24h | -10% |
| Întârziere 24-72h | -25% |
| Structură greșită | -5% |
| REFLECTION.md lipsă | -10% |

---

## Checklist Evaluare

```
□ Arhiva dezarhivabilă
□ Structura de directoare corectă
□ partea1_operatori/ - 3 scripturi
□ partea2_redirectare/ - 3 scripturi
□ partea3_filtre/ - 4 scripturi
□ partea4_bucle/ - 4 scripturi
□ partea5_proiect/ - system_report.sh
□ README.md completat
□ REFLECTION.md prezent
□ Toate scripturile executabile
```

---

*Document intern | Seminar 2: Pipeline Master*
