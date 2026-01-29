# Rubrica de Evaluare - Tema Seminar 3

> **Document pentru instructor** | Nu se distribuie studenților înainte de evaluare

---

## Legendă Sistem de Punctare

| Simbol | Semnificație | Exemplu |
|--------|--------------|---------|
| **%** | Procent din nota finală a temei (100%) | PARTEA 1: 20% din total |
| **Pct (în tabele)** | Puncte relative în cadrul secțiunii | 3 pct din cele 8% ale sub-secțiunii |
| **Ajustare ±X%** | Modificare procentuală aplicată notei finale | Calitate cod: ±5% |

> **Notă importantă**: Punctele din coloanele tabelelor (Pct) sunt **puncte relative** care se adună pentru a forma procentul secțiunii respective. Exemplu: în PARTEA 1 (20%), sub-secțiunile de 8 + 6 + 6 = 20 puncte relative echivalează cu 20% din nota finală.

---

## Criterii Generale de Evaluare

### Scală de Notare

| Nivel | Punctaj | Descriere |
|-------|---------|-----------|
| **Excelent** | 100% | Soluție elegantă, depășește cerințele |
| **Foarte Bine** | 85% | Toate cerințele îndeplinite corect |
| **Bine** | 70% | Funcționalitate corectă, mici probleme |
| **Satisfăcător** | 55% | Funcționează parțial |
| **Insuficient** | 30% | Încercare, nu funcționează |
| **Absent** | 0% | Nu a fost predat sau copiat |

---

## PARTEA 1: Find Master (20%)

### 1.1 Comenzi find cu Criterii Multiple (8%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| Criterii combinate | 3 | `-name AND -mtime AND -size` | 2 criterii | 1 criteriu |
| `-type f/d` corect | 2 | Distincție clară fișiere/directoare | Funcționează | Lipsă sau incorect |
| Operatori logici | 3 | `-a`, `-o`, `!` folosite corect | Parțial | Lipsă |

**Soluție referință:**
```bash
find /var/log -type f -name "*.log" -mtime -7 -size +1M
find . -type f \( -name "*.tmp" -o -name "*.bak" \) -mtime +30
```

### 1.2 Find cu Acțiuni (6%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| `-exec` corect | 3 | `{} \;` sau `{} +` | Funcționează | Erori sintaxă |
| `-delete` sigur | 2 | Precedat de `-print` pentru verificare | Direct delete | Periculos |
| `-printf` formatat | 1 | Custom output format | Funcționează | Lipsă |

### 1.3 Find cu xargs (6%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| `-print0 \| xargs -0` | 3 | Gestionare corectă spații în nume | `xargs` simplu | Lipsă xargs |
| Procesare eficientă | 2 | Batch processing demonstrat | Funcțional | One-by-one |
| `-I{}` placeholder | 1 | Utilizare corectă | Funcționează | Lipsă |

**Soluție referință:**
```bash
find . -name "*.txt" -print0 | xargs -0 -I{} cp {} backup/
```

---

## PARTEA 2: Script Profesional cu getopts (30%)

### 2.1 Structură Script (8%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| Header complet | 2 | Autor, dată, descriere, usage | Parțial | Lipsă |
| Shebang + set | 2 | `#!/bin/bash` + `set -euo pipefail` | Doar shebang | Lipsă |
| Funcție usage() | 2 | Help complet cu exemple | Help basic | Lipsă |
| Variabile declarate | 2 | Defaults și validare | Parțial | Hardcodate |

### 2.2 Implementare getopts (12%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| Opțiuni scurte | 4 | Minim `-h -v -f FILE -n NUM` | 3 opțiuni | Sub 3 |
| Opțiuni cu argument | 4 | `:` corect în optstring | Funcționează | Erori |
| Opțiuni invalide | 2 | Case `?` și `:` gestionate | Mesaj generic | Crash |
| shift OPTIND | 2 | Argumente poziționale accesibile | Parțial | Lipsă |

**Soluție referință:**
```bash
while getopts ":hvf:n:" opt; do
    case $opt in
        h) usage; exit 0 ;;
        v) VERBOSE=true ;;
        f) FILE="$OPTARG" ;;
        n) COUNT="$OPTARG" ;;
        :) echo "Option -$OPTARG requires argument" >&2; exit 1 ;;
        ?) echo "Invalid option -$OPTARG" >&2; usage; exit 1 ;;
    esac
done
shift $((OPTIND-1))
```

### 2.3 Funcționalitate (10%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| Logica implementată | 5 | Toate funcționalitățile cerute | 70%+ | Sub 50% |
| Mod verbose | 2 | Informații detaliate când `-v` | Parțial | Lipsă |
| Exit codes | 2 | 0 succes, 1 eroare utilizator, 2 eroare sistem | Parțial | Lipsă |
| Error handling | 1 | Mesaje clare la erori | Generic | Lipsă |

---

## PARTEA 3: Permission Manager (25%)

### 3.1 Înțelegere Permisiuni (8%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| Octal corect | 3 | 755, 644, 700 explicat și aplicat | Funcționează | Confuzie |
| Simbolic corect | 3 | u+x, g-w, o=r explicat și aplicat | Funcționează | Confuzie |
| Sticky, SUID, SGID | 2 | Demonstrație și explicație | Menționat | Lipsă |

### 3.2 Script de Audit (10%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| Detectare world-writable | 3 | `find -perm -002` corect | Funcționează | Incorect |
| Detectare SUID/SGID | 3 | `-perm -4000` și `-perm -2000` | Unul din două | Lipsă |
| Raport formatat | 2 | Categorii, counts, detalii | Listare simplă | Raw output |
| Recomandări | 2 | Sugestii remediere | Parțial | Lipsă |

**Soluție referință:**
```bash
echo "=== World-Writable Files ==="
find "$TARGET_DIR" -type f -perm -002 -ls 2>/dev/null | head -20

echo "=== SUID Files ==="
find "$TARGET_DIR" -type f -perm -4000 -ls 2>/dev/null
```

### 3.3 Remediere Automată (7%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| Dry-run mode | 3 | Afișează ce ar face fără a executa | Lipsă dry-run | Direct modificare |
| Confirmare | 2 | Întreabă înainte de modificări | Parțial | Fără confirmare |
| Logging | 2 | Înregistrează toate modificările | Parțial | Lipsă |

---

## PARTEA 4: Cron Jobs (15%)

### 4.1 Sintaxă Crontab (5%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| Format corect | 2 | Min Hour Day Month Weekday Cmd | Funcționează | Erori sintaxă |
| Schedule-uri variate | 2 | Daily, weekly, specific time | 2 tipuri | 1 tip |
| Path-uri absolute | 1 | Comenzi cu path complet | Parțial | Relative paths |

**Exemple corecte:**
```
0 2 * * * /home/user/backup.sh >> /var/log/backup.log 2>&1
30 4 * * 0 /usr/local/bin/weekly_cleanup.sh
*/15 * * * * /home/user/monitor.sh
```

### 4.2 Script de Backup (6%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| Backup complet | 2 | tar.gz cu timestamp | tar simplu | cp |
| Rotație | 2 | Păstrează N versiuni, șterge vechi | Menționat | Lipsă |
| Logging | 2 | Timestamp, status, erori | Parțial | Lipsă |

### 4.3 Error Handling în Cron (4%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| Redirect stderr | 2 | `2>&1` în crontab | Parțial | Lipsă |
| Lock file | 2 | Previne rulări simultane | Menționat | Lipsă |

---

## PARTEA 5: Integration Challenge (10%)

### Sysadmin Toolkit (10%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| Meniu interactiv | 2 | Case + loop | Funcționează | Lipsă |
| Integrare find | 2 | Funcție de căutare avansată | Basic | Lipsă |
| Integrare permisiuni | 2 | Audit + remediere | Doar audit | Lipsă |
| Getopts pentru CLI | 2 | Opțiuni pentru mod non-interactiv | Parțial | Lipsă |
| Stabilitate | 2 | Error handling complet | Parțial | Fragil |

---

## BONUS (până la +20% bonus)

| Exercițiu | Puncte | Cerință |
|-----------|--------|---------|
| find cu ACL | +5 | `getfacl`, `setfacl` integrat |
| inotifywait | +5 | Monitoring realtime cu acțiuni |
| Cron GUI | +5 | Script generare crontab interactiv |
| Backup incremental | +5 | rsync cu timestamps |

---

## Criterii Transversale

### Calitate Cod (ajustare: -5% până la +5% din nota finală)

| Aspect | Bonus | Penalizare |
|--------|-------|------------|
| Comentarii | +1 | -1 |
| ShellCheck clean | +2 | -2 |
| Variabile quoted | +1 | -2 |
| `set -euo pipefail` | +1 | 0 |

---

## Penalizări Speciale

| Situație | Penalizare |
|----------|------------|
| Plagiat | **-100%** |
| Întârziere < 24h | -10% |
| Structură greșită | -5% |
| Scripturi neexecutabile | -1% per script |
| Comenzi periculoase fără confirmare | -10% |

---

## Checklist Evaluare

```
□ Arhiva .tar.gz dezarhivabilă
□ parte1_find/comenzi_find.sh prezent
□ parte2_script/fileprocessor.sh cu getopts
□ parte3_permissions/permaudit.sh funcțional
□ parte4_cron/cron_entries.txt valid
□ parte5_integration/sysadmin_toolkit.sh complet
□ README.md cu documentație
□ Toate scripturile executabile
□ ShellCheck fără erori
```

---

*Document intern | Seminar 3: System Administrator Toolkit*
