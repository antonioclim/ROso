# S04_ANEXA - Referințe Seminar 4 (Redistribuit)

> **Sisteme de Operare** | ASE București - CSIE  
> Material suplimentar - Text Processing

---

## Diagrame ASCII - Expresii Regulate

### Engine-ul Regex

```
┌──────────────────────────────────────────────────────────────────────┐
│                    REGEX ENGINE - Cum Funcționează                   │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  INPUT: "The quick brown fox jumps over the lazy dog"               │
│  PATTERN: /\b\w+o\w+\b/g  (cuvinte cu 'o' în interior)              │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │ PASUL 1: TOKENIZARE PATTERN                                    │ │
│  │                                                                │ │
│  │   \b    WORD BOUNDARY                                         │ │
│  │   \w+   ONE OR MORE WORD CHARS                                │ │
│  │   o     LITERAL 'o'                                           │ │
│  │   \w+   ONE OR MORE WORD CHARS                                │ │
│  │   \b    WORD BOUNDARY                                         │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                              │                                       │
│                              ▼                                       │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │ PASUL 2: MATCHING (pentru fiecare poziție în text)            │ │
│  │                                                                │ │
│  │   Poziția 0: "The" → \b✓ \w+="Th" o=✗ → FAIL, next            │ │
│  │   Poziția 4: "quick" → \b✓ \w+="quick" (no 'o') → FAIL       │ │
│  │   Poziția 10: "brown" → \b✓ \w+="br" o✓ \w+="wn" \b✓ → MATCH │ │
│  │   Poziția 16: "fox" → \b✓ \w+="f" o✓ \w+="x" \b✓ → MATCH     │ │
│  │   ...                                                          │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                              │                                       │
│                              ▼                                       │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │ REZULTAT: ["brown", "fox", "over", "dog"]                      │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

### Quantificatori - Comportament Greedy vs Lazy

```
┌──────────────────────────────────────────────────────────────────────┐
│                    GREEDY vs LAZY MATCHING                           │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Text: <div>Hello</div><div>World</div>                             │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │ GREEDY: /<div>.*<\/div>/                                       │ │
│  │                                                                │ │
│  │ <div>Hello</div><div>World</div>                               │ │
│  │ ├────────────────────────────────┤                              │ │
│  │ └─ Potrivește TOT (de la primul <div> la ULTIMUL </div>)       │ │
│  │                                                                │ │
│  │ Rezultat: "<div>Hello</div><div>World</div>"                   │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │ LAZY: /<div>.*?<\/div>/                                        │ │
│  │                         ^                                       │ │
│  │                         ? face quantificatorul lazy             │ │
│  │                                                                │ │
│  │ <div>Hello</div><div>World</div>                               │ │
│  │ ├──────────────┤                                                │ │
│  │ └─ Potrivește MINIM (oprește la primul </div>)                 │ │
│  │                                                                │ │
│  │ Rezultat: "<div>Hello</div>"                                   │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                      │
│  QUANTIFICATORI:                                                     │
│  ┌─────────┬─────────┬────────────────────────────────────────────┐ │
│  │ Greedy  │ Lazy    │ Semnificație                               │ │
│  ├─────────┼─────────┼────────────────────────────────────────────┤ │
│  │ *       │ *?      │ 0 sau mai multe                            │ │
│  │ +       │ +?      │ 1 sau mai multe                            │ │
│  │ ?       │ ??      │ 0 sau 1                                    │ │
│  │ {n,m}   │ {n,m}?  │ între n și m                               │ │
│  └─────────┴─────────┴────────────────────────────────────────────┘ │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

### AWK - Flux de Procesare

```
┌──────────────────────────────────────────────────────────────────────┐
│                        AWK PROCESSING MODEL                          │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  INPUT FILE                                                          │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │ alice 25 developer                                              │ │
│  │ bob 30 manager                                                  │ │
│  │ carol 28 developer                                              │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                              │                                       │
│                              ▼                                       │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │                    BEGIN BLOCK                                  │ │
│  │  Execută O SINGURĂ DATĂ înainte de prima linie                 │ │
│  │  BEGIN { print "Name\tAge\tRole"; count = 0 }                  │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                              │                                       │
│                              ▼                                       │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │              MAIN BLOCK (pentru fiecare linie)                  │ │
│  │                                                                │ │
│  │  Linia 1: "alice 25 developer"                                 │ │
│  │           ┌─────┬─────┬───────────┐                            │ │
│  │    $0 =   │alice│ 25  │ developer │                            │ │
│  │           └──┬──┴──┬──┴─────┬─────┘                            │ │
│  │              $1    $2       $3        NF=3, NR=1               │ │
│  │                                                                │ │
│  │  Pattern { Action }                                            │ │
│  │  $3 == "developer" { print $1, $2; count++ }                   │ │
│  │  → Pattern TRUE → execută action                               │ │
│  │                                                                │ │
│  │  Linia 2: "bob 30 manager"                                     │ │
│  │  → Pattern FALSE → skip                                        │ │
│  │                                                                │ │
│  │  Linia 3: "carol 28 developer"                                 │ │
│  │  → Pattern TRUE → execută action                               │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                              │                                       │
│                              ▼                                       │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │                      END BLOCK                                  │ │
│  │  Execută O SINGURĂ DATĂ după ultima linie                      │ │
│  │  END { print "Total developers:", count }                      │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                              │                                       │
│                              ▼                                       │
│  OUTPUT:                                                             │
│  Name    Age    Role                                                │
│  alice 25                                                           │
│  carol 28                                                           │
│  Total developers: 2                                                │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

### SED - Address Ranges

```
┌──────────────────────────────────────────────────────────────────────┐
│                       SED ADDRESS TYPES                              │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  INPUT (linii numerotate):                                           │
│  1: # Configuration file                                             │
│  2: host = localhost                                                 │
│  3: port = 8080                                                      │
│  4: # Database settings                                              │
│  5: db_host = 127.0.0.1                                             │
│  6: db_port = 5432                                                   │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │ ADRESĂ NUMĂR: sed '3d'  (șterge linia 3)                       │ │
│  │                                                                │ │
│  │   1: # Configuration file    ✓ păstrată                        │ │
│  │   2: host = localhost        ✓ păstrată                        │ │
│  │   3: port = 8080            ✗ ȘTEARSĂ                          │ │
│  │   4: # Database settings     ✓ păstrată                        │ │
│  │   ...                                                          │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │ RANGE NUMĂR: sed '2,4d'  (șterge liniile 2-4)                  │ │
│  │                                                                │ │
│  │   1: # Configuration file    ✓ păstrată                        │ │
│  │   2: host = localhost       ✗ │                                │ │
│  │   3: port = 8080            ✗ ├── ȘTERSE                       │ │
│  │   4: # Database settings    ✗ │                                │ │
│  │   5: db_host = 127.0.0.1     ✓ păstrată                        │ │
│  │   6: db_port = 5432          ✓ păstrată                        │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │ REGEX: sed '/^#/d'  (șterge liniile care încep cu #)           │ │
│  │                                                                │ │
│  │   1: # Configuration file   ✗ ȘTEARSĂ (^# match)               │ │
│  │   2: host = localhost        ✓ păstrată                        │ │
│  │   3: port = 8080             ✓ păstrată                        │ │
│  │   4: # Database settings    ✗ ȘTEARSĂ (^# match)               │ │
│  │   5: db_host = 127.0.0.1     ✓ păstrată                        │ │
│  │   6: db_port = 5432          ✓ păstrată                        │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │ RANGE REGEX: sed '/^#/,/^db/d'  (de la # până la db)           │ │
│  │                                                                │ │
│  │   1: # Configuration file   ✗ │ start range                    │ │
│  │   2: host = localhost       ✗ │                                │ │
│  │   3: port = 8080            ✗ │                                │ │
│  │   4: # Database settings    ✗ │ start new range                │ │
│  │   5: db_host = 127.0.0.1    ✗ │ end range (^db match)          │ │
│  │   6: db_port = 5432          ✓ păstrată (după range)           │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │ NEGARE: sed '/^#/!d'  (șterge tot CE NU e comentariu)          │ │
│  │                       ^                                         │ │
│  │                       ! inversează selecția                     │ │
│  │                                                                │ │
│  │   1: # Configuration file    ✓ păstrată (e comentariu)         │ │
│  │   2: host = localhost       ✗ ȘTEARSĂ                          │ │
│  │   3: port = 8080            ✗ ȘTEARSĂ                          │ │
│  │   4: # Database settings     ✓ păstrată (e comentariu)         │ │
│  │   5: db_host = 127.0.0.1    ✗ ȘTEARSĂ                          │ │
│  │   6: db_port = 5432         ✗ ȘTEARSĂ                          │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

---

## Exerciții Rezolvate Complet

### Exercițiul 1: Extragere Date din Log Apache

```bash
# Creează log de test
cat > /tmp/access.log << 'EOF'
192.168.1.100 - - [10/Jan/2025:10:15:32 +0200] "GET /index.html HTTP/1.1" 200 1234
192.168.1.101 - - [10/Jan/2025:10:15:33 +0200] "POST /api/users HTTP/1.1" 201 567
10.0.0.50 - - [10/Jan/2025:10:15:34 +0200] "GET /images/logo.png HTTP/1.1" 200 45678
192.168.1.100 - - [10/Jan/2025:10:15:35 +0200] "GET /css/style.css HTTP/1.1" 200 2345
192.168.1.102 - - [10/Jan/2025:10:15:36 +0200] "GET /nonexistent HTTP/1.1" 404 123
192.168.1.100 - - [10/Jan/2025:10:15:37 +0200] "GET /api/data HTTP/1.1" 500 0
10.0.0.51 - - [10/Jan/2025:10:15:38 +0200] "GET /index.html HTTP/1.1" 200 1234
EOF

# === EXERCIȚIU A: Top IP-uri ===
echo "=== Top IP-uri ==="
awk '{ count[$1]++ } END { for (ip in count) print count[ip], ip }' /tmp/access.log | sort -rn
# Output:
# 3 192.168.1.100
# 1 192.168.1.102
# 1 192.168.1.101
# 1 10.0.0.51
# 1 10.0.0.50

# === EXERCIȚIU B: Distribuție Status Codes ===
echo ""
echo "=== Status Codes ==="
awk '{ 
    match($0, /" [0-9]{3} /)
    status = substr($0, RSTART+2, 3)
    codes[status]++ 
} 
END { 
    for (code in codes) 
        printf "%s: %d (%.1f%%)\n", code, codes[code], codes[code]*100/NR 
}' /tmp/access.log
# Output:
# 200: 5 (71.4%)
# 201: 1 (14.3%)
# 404: 1 (14.3%)
# 500: 1 (14.3%)

# === EXERCIȚIU C: Bytes transferați per resursă ===
echo ""
echo "=== Bytes per resursă ==="
awk '{
    # Extrage URL și bytes
    match($0, /"[A-Z]+ ([^ ]+)/, arr)
    url = arr[1]
    bytes = $(NF)
    total[url] += bytes
}
END {
    for (url in total)
        printf "%-30s %d bytes\n", url, total[url]
}' /tmp/access.log | sort -t$'\t' -k2 -rn
# /images/logo.png 45678 bytes
# /css/style.css 2345 bytes
# /index.html 2468 bytes
# ...

# === EXERCIȚIU D: Request-uri per oră ===
echo ""
echo "=== Request-uri per oră ==="
awk -F'[\\[:]' '{ hours[$3]++ } END { for (h in hours) print h":00 -", hours[h], "requests" }' /tmp/access.log

# === EXERCIȚIU E: Doar erorile (4xx, 5xx) cu detalii ===
echo ""
echo "=== Erori ==="
awk '/ (4[0-9]{2}|5[0-9]{2}) / {
    # Extrage componente
    ip = $1
    match($0, /\[([^\]]+)\]/, dt)
    date = dt[1]
    match($0, /"([^"]+)"/, req)
    request = req[1]
    match($0, /" ([0-9]{3}) /, st)
    status = st[1]
    
    printf "[%s] %s - %s - %s\n", status, ip, date, request
}' /tmp/access.log

# Cleanup
rm /tmp/access.log
```

### Exercițiul 2: Procesare CSV cu AWK

```bash
# Creează CSV de test
cat > /tmp/sales.csv << 'EOF'
Date,Product,Quantity,Price,Region
2025-01-01,Laptop,5,1200,North
2025-01-01,Phone,10,800,South
2025-01-02,Laptop,3,1200,East
2025-01-02,Tablet,8,500,North
2025-01-03,Phone,15,800,West
2025-01-03,Laptop,2,1200,South
2025-01-03,Tablet,12,500,East
EOF

# === A: Total vânzări per produs ===
echo "=== Vânzări per produs ==="
awk -F',' 'NR>1 { 
    qty[$2] += $3
    revenue[$2] += $3 * $4 
} 
END { 
    printf "%-10s %8s %12s\n", "Product", "Qty", "Revenue"
    printf "%-10s %8s %12s\n", "-------", "---", "-------"
    for (p in qty) 
        printf "%-10s %8d $%11.2f\n", p, qty[p], revenue[p]
}' /tmp/sales.csv

# === B: Total per regiune ===
echo ""
echo "=== Vânzări per regiune ==="
awk -F',' 'NR>1 { 
    region[$5] += $3 * $4 
} 
END { 
    for (r in region) 
        printf "%s: $%.2f\n", r, region[r]
}' /tmp/sales.csv | sort -t'$' -k2 -rn

# === C: Medie zilnică ===
echo ""
echo "=== Media zilnică ==="
awk -F',' 'NR>1 { 
    daily[$1] += $3 * $4
    days[$1] = 1
} 
END { 
    total = 0
    for (d in daily) total += daily[d]
    print "Total:", total
    print "Zile:", length(days)
    print "Media/zi:", total/length(days)
}' /tmp/sales.csv

# === D: Pivot table - Produs x Regiune ===
echo ""
echo "=== Pivot: Produs x Regiune ==="
awk -F',' 'NR>1 { 
    pivot[$2][$5] += $3 * $4
    products[$2] = 1
    regions[$5] = 1
}
END {
    # Header
    printf "%-10s", ""
    for (r in regions) printf "%10s", r
    print ""
    
    # Rows
    for (p in products) {
        printf "%-10s", p
        for (r in regions) {
            if ((p,r) in pivot)
                printf "%10.0f", pivot[p][r]
            else
                printf "%10s", "-"
        }
        print ""
    }
}' /tmp/sales.csv

rm /tmp/sales.csv
```

### Exercițiul 3: Script Complet de Analiză Text

```bash
#!/bin/bash
# text_analyzer.sh - Analizează un fișier text

set -euo pipefail

usage() {
    echo "Utilizare: $0 <fișier>"
    exit 1
}

[ $# -eq 1 ] || usage
[ -f "$1" ] || { echo "Fișierul nu există: $1"; exit 1; }

FILE="$1"

echo "=== Analiză: $FILE ==="
echo ""

# Statistici de bază
echo "--- Statistici de bază ---"
wc "$FILE" | awk '{ printf "Linii: %d\nCuvinte: %d\nCaractere: %d\n", $1, $2, $3 }'

# Linii non-goale
echo "Linii non-goale: $(grep -c '.' "$FILE")"

# Cea mai lungă linie
echo "Cea mai lungă linie: $(wc -L < "$FILE") caractere"

echo ""
echo "--- Top 10 cuvinte ---"
tr -cs 'A-Za-z' '\n' < "$FILE" | tr 'A-Z' 'a-z' | sort | uniq -c | sort -rn | head -10

echo ""
echo "--- Distribuție lungime cuvinte ---"
tr -cs 'A-Za-z' '\n' < "$FILE" | awk '
length > 0 {
    len = length($0)
    if (len <= 3) short++
    else if (len <= 6) medium++
    else long++
}
END {
    total = short + medium + long
    printf "Scurte (1-3):  %5d (%.1f%%)\n", short, short*100/total
    printf "Medii (4-6):   %5d (%.1f%%)\n", medium, medium*100/total
    printf "Lungi (7+):    %5d (%.1f%%)\n", long, long*100/total
}'

echo ""
echo "--- Pattern-uri găsite ---"
echo "Email-uri: $(grep -oE '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' "$FILE" 2>/dev/null | wc -l)"
echo "URL-uri: $(grep -oE 'https?://[^ ]+' "$FILE" 2>/dev/null | wc -l)"
echo "Numere: $(grep -oE '\b[0-9]+\b' "$FILE" 2>/dev/null | wc -l)"
```

---

## Referințe Rapide

### Regex Cheat Sheet

| Pattern | Descriere | Exemplu |
|---------|-----------|---------|
| `.` | Orice caracter | `a.c` → abc |
| `^` | Început linie | `^Start` |
| `$` | Sfârșit linie | `end$` |
| `*` | 0 sau mai multe | `ab*c` |
| `+` | 1 sau mai multe | `ab+c` (ERE) |
| `?` | 0 sau 1 | `colou?r` (ERE) |
| `[abc]` | Oricare din set | `[aeiou]` |
| `[^abc]` | Niciunul din set | `[^0-9]` |
| `\b` | Word boundary | `\bword\b` |
| `()` | Grup | `(ab)+` (ERE) |
| `\|` | SAU | `cat\|dog` (ERE) |

### AWK Quick Reference

```bash
# Câmpuri
$0, $1, $NF, NR, NF, FS, OFS

# Pattern-uri
/regex/          # match regex
$1 == "val"      # comparație
NR > 1           # skip header
BEGIN {}         # înainte de input
END {}           # după input

# Funcții
length(s), substr(s,i,n), split(s,a,sep)
tolower(s), toupper(s), gsub(r,s,t)
```

### SED Quick Reference

```bash
# Substituție
s/old/new/       # prima
s/old/new/g      # toate
s/old/new/gi     # case-insensitive

# Adrese
5                # linia 5
1,10             # liniile 1-10
/pattern/        # linii cu pattern
/start/,/end/    # range

# Comenzi
d                # delete
p                # print
i\text           # insert
a\text           # append
```

---
*Material suplimentar pentru cursul de Sisteme de Operare | ASE București - CSIE*
-e 

---

*By Revolvix for OPERATING SYSTEMS class | restricted licence 2017-2030*
