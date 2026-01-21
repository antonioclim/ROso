# Rubrica de Evaluare - Tema Seminar 09-10

> **Document pentru instructor** | Nu se distribuie studenților înainte de evaluare

---

## Legendă Sistem de Punctare

| Simbol | Semnificație | Exemplu |
|--------|--------------|---------|
| **%** | Procent din nota finală a temei (100%) | CERINȚA 1: 40% din total |
| **Pct (în tabele)** | Puncte relative în cadrul secțiunii | 4 pct din cele 12% ale sub-secțiunii |
| **Ajustare ±X%** | Modificare procentuală aplicată notei finale | Calitate cod: ±10% |

> **Notă importantă**: Punctele din coloanele tabelelor (Pct) sunt **puncte relative** care se adună pentru a forma procentul secțiunii respective. Exemplu: în CERINȚA 1 (40%), sub-secțiunile de 12 + 12 + 8 + 8 = 40 puncte relative echivalează cu 40% din nota finală.

---

## Criterii Generale de Evaluare

### Scală de Notare

| Nivel | Punctaj | Descriere |
|-------|---------|-----------|
| **Excelent** | 100% | Cod profesional, depășește cerințele |
| **Foarte Bine** | 85% | Toate cerințele îndeplinite corect |
| **Bine** | 70% | Funcționalitate corectă, mici probleme |
| **Satisfăcător** | 55% | Funcționează parțial |
| **Insuficient** | 30% | Încercare, nu funcționează |
| **Absent** | 0% | Nu a fost predat sau copiat |

---

## CERINȚA 1: Log Analyzer (40%)

### 1.1 Parsare și Structură (12%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| `set -euo pipefail` | 2 | Prezent în header | Lipsă dar funcționează | Lipsă + erori |
| Parsare argumente | 4 | getopts cu -h, -v, -l, -o, --top | 3-4 opțiuni | Sub 3 |
| Parsare linie log | 4 | Regex/BASH_REMATCH corect | Funcționează | Erori |
| Validare input | 2 | Verifică existența fișierului | Mesaj generic | Crash |

**Soluție parsare:**
```bash
if [[ "$line" =~ ^\[([^\]]+)\]\ \[([A-Z]+)\]\ (.*)$ ]]; then
    local timestamp="${BASH_REMATCH[1]}"
    local level="${BASH_REMATCH[2]}"
    local message="${BASH_REMATCH[3]}"
fi
```

### 1.2 Arrays și Statistici (12%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| `declare -A LEVEL_COUNT` | 3 | Corect declarat și utilizat | Funcționează | Array indexat |
| `declare -A MESSAGE_COUNT` | 3 | Numărare mesaje pentru top N | Funcționează | Lipsă |
| Procente calculate | 3 | `printf "%.1f%%"` corect | Aproximative | Lipsă |
| Time range | 3 | Prima/ultima timestamp extrase | Parțial | Lipsă |

### 1.3 Funcții cu `local` (10%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| `parse_line()` cu local | 2.5 | Toate variabilele locale | Parțial locale | Globale |
| `count_levels()` cu local | 2.5 | Iterator local | Parțial | Globale |
| `get_top_messages()` cu local | 2.5 | Sortare și limitare local | Parțial | Globale |
| `print_report()` cu local | 2.5 | Formatare locală | Parțial | Globale |

### 1.4 Output și Stabilitate (6%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| Raport formatat | 3 | Box chars, aliniere, culori | Funcțional | Brut |
| trap EXIT | 2 | Cleanup implementat | Menționat | Lipsă |
| Output la fișier -o | 1 | Redirect funcțional | Lipsă | Erori |

---

## CERINȚA 2: Config Manager (30%)

### 2.1 Parsare Config (10%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| Ignoră comentarii | 2 | `^[[:space:]]*#` filtrat | Funcționează | Include comentarii |
| Ignoră linii goale | 2 | Filtrate corect | Funcționează | Include |
| Parsare key=value | 3 | Regex sau IFS= corect | Funcționează | Erori la spații |
| `declare -A CONFIG` | 3 | Stocare corectă | Funcționează | Array indexat |

**Soluție parsare:**
```bash
while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
    if [[ "$line" =~ ^([^=]+)=(.*)$ ]]; then
        local key="${BASH_REMATCH[1]// /}"
        local value="${BASH_REMATCH[2]}"
        CONFIG["$key"]="$value"
    fi
done < "$CONFIG_FILE"
```

### 2.2 Comenzi CRUD (12%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| `get <key>` | 3 | Returnează valoare sau eroare | Funcționează | Crash la lipsă |
| `set <key> <value>` | 3 | Adaugă/actualizează + save | Funcționează | Nu salvează |
| `delete <key>` | 3 | Șterge + save | Funcționează | Nu salvează |
| `list` | 3 | Formatat frumos | Listare simplă | Brut |

### 2.3 Validare și Export (8%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| Chei obligatorii | 3 | REQUIRED_KEYS verificate | Parțial | Lipsă |
| Validare format | 3 | PORT numeric, etc. | Un tip validat | Lipsă |
| `export` funcțional | 2 | `export KEY=VALUE` corect | Funcționează | Erori |

---

## CERINȚA 3: Refactoring Challenge (30%)

### 3.1 Identificare Probleme (10%)

| Problemă | Pct | Corect | Parțial | Incorect |
|----------|-----|--------|---------|----------|
| Lipsă `set -euo pipefail` | 1 | Adăugat | - | Lipsă |
| `$*` → `"$@"` | 1 | Corectat | - | Neschimbat |
| `${files[@]}` → `"${files[@]}"` | 1 | Corectat | - | Neschimbat |
| Variabilă globală în funcție | 1 | `local count=0` | - | Global |
| `$file` → `"$file"` | 1 | Corectat | - | Neschimbat |
| UUOC `cat \| wc` → `wc < file` | 1 | Corectat | - | cat păstrat |
| `declare -A config` | 1 | Adăugat | - | Lipsă |
| Validare input | 1 | Implementat | Parțial | Lipsă |
| usage() | 1 | Complet | Minimal | Lipsă |
| trap cleanup | 1 | Implementat | Parțial | Lipsă |

### 3.2 Aplicare Template Profesional (12%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| Header complet | 2 | Autor, descriere, versiune | Parțial | Lipsă |
| Secțiuni clare | 2 | VARIABILE, FUNCȚII, MAIN | 2 secțiuni | Neorganizat |
| Parsare argumente | 3 | case + shift corect | Funcționează | Lipsă |
| Error handling | 3 | Exit codes, mesaje | Parțial | Lipsă |
| Logging/verbose | 2 | -v implementat | Parțial | Lipsă |

### 3.3 Funcționalitate Corectă (8%)

| Criteriu | Pct | Excelent | Satisfăcător | Insuficient |
|----------|-----|----------|--------------|-------------|
| Procesare fișiere | 4 | Toate fișierele procesate corect | Majoritatea | Erori |
| Output identic | 2 | Același rezultat ca original (când funcționează) | În jur de | Diferit |
| Config utilizat | 2 | Array asociativ funcțional | Parțial | Neutilizat |

---

## Criterii Transversale

### Stil Cod (ajustare: -10% până la +10% din nota finală)

| Aspect | Bonus | Penalizare |
|--------|-------|------------|
| ShellCheck 0 warnings | +3 | -1 per warning |
| Comentarii utile | +2 | -2 |
| Variabile UPPERCASE pentru globale | +1 | -1 |
| Variabile lowercase pentru locale | +1 | -1 |
| Funcții documentate | +2 | 0 |
| Unit tests pentru funcții | +5 | 0 |

### Stabilitate

| Aspect | Bonus | Penalizare |
|--------|-------|------------|
| Toate variabilele quoted | +2 | -3 |
| Exit codes corecte | +1 | -2 |
| Cleanup în trap | +1 | 0 |

---

## Penalizări Speciale

| Situație | Penalizare |
|----------|------------|
| Plagiat | **-100%** |
| Întârziere < 24h | -10% |
| Întârziere 24-72h | -25% |
| Întârziere > 72h | -50% |
| ShellCheck errors (nu warnings) | -5% per eroare |
| Lipsă `set -euo pipefail` | -5% per script |
| Variabile non-locale în funcții | -3% per instanță |
| Arrays fără ghilimele în for | -3% per instanță |
| Lipsă `declare -A` pentru asociative | -5% per array |

---

## BONUS (până la +10% bonus)

| Criteriu | Puncte |
|----------|--------|
| Cod foarte curat | +5 |
| Funcționalități extra utile | +5 |
| Unit tests complete | +5 |
| **Maxim bonus** | **+10** |

---

## Checklist Evaluare Rapidă

```
□ Arhiva cu structură corectă
□ log_analyzer.sh
  □ shellcheck clean
  □ set -euo pipefail
  □ declare -A pentru arrays
  □ Funcții cu local
  □ Parsare argumente completă
□ config_manager.sh
  □ shellcheck clean
  □ Toate comenzile funcționale
  □ declare -A CONFIG
  □ Validare implementată
□ refactored_script.sh
  □ Toate 10 problemele corectate
  □ Template profesional aplicat
  □ shellcheck clean
□ README.md prezent
□ Test files incluse
```

---

## Distribuție Așteptată Note

| Notă | Interval | Descriere |
|------|----------|-----------|
| 10 | 95-100 + bonus | Cod profesional, toate cerințele + extra |
| 9 | 85-94 | Toate cerințele, stil foarte bun |
| 8 | 75-84 | Funcționează, mici probleme stil |
| 7 | 65-74 | Funcționează, probleme moderate |
| 6 | 55-64 | Parțial funcțional |
| 5 | 45-54 | Minim acceptabil |

---

*Document intern | Seminar 09-10: Advanced Bash Scripting*
