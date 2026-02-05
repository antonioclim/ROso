# Demo-uri Spectaculoase: Text Processing Magic
## One-Liners și Trucuri Impresionante

> **Observație din laborator:** notează-ți comenzi‑cheie și output‑ul relevant (2–3 linii) pe măsură ce lucrezi. Te ajută la debug și, sincer, la final îți iese și un README bun fără efort suplimentar.
> **Sisteme de Operare** | Academia de Studii Economice București - CSIE  
> **Seminar 4** | Wow Factor Demonstrations  
> **Scop**: Captarea atenției și demonstrarea puterii text processing

---

## Filozofia Demo-urilor

### De ce "Wow Factor"?

Demo-urile spectaculoase servesc mai multe scopuri pedagogice:

```
┌─────────────────────────────────────────────────────────────────────────┐
│  🎯 SCOPURI DEMO SPECTACULOASE                                         │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  1. HOOK - Captează atenția la începutul seminarului                   │
│                                                                         │
│  2. MOTIVAȚIE - "Vreau să pot face și eu asta!"                        │
│                                                                         │
│  3. CONTEXT REAL - Arată utilitatea practică                           │
│                                                                         │
│  4. MEMORIE - Momentele "wow" se rețin mai bine                        │
│                                                                         │
│  5. ASPIRAȚIE - Setează ștacheta pentru ce e posibil                   │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### Când să folosești

- **La început** - Hook pentru a capta atenția
- **După concepte grele** - Recompensă și pauză mentală
- **La final** - Rezumat și motivație pentru studiu individual

---

# DEMO 1: LOG ANALYSIS IN SECONDS (Hook Demo)

## Povestea
> "Șeful vine la tine: 'Site-ul a fost atacat ieri noapte. Am nevoie de un raport în 5 minute: cine, de unde, și ce au încercat să acceseze.'"

## Setup (pre-seminar)

```bash
# Generează un access.log realist (2000+ linii)
cd ~/demo_sem4/data

# Script pentru generare (rulează ÎNAINTE de seminar)
cat > generate_realistic_log.sh << 'SCRIPT'
#!/bin/bash
# Generează access.log realist cu atacuri simulate

ips=("192.168.1.100" "192.168.1.101" "10.0.0.50" "10.0.0.51" 
     "45.33.32.156" "185.220.101.1" "23.129.64.100")
methods=("GET" "POST" "PUT" "DELETE")
paths=("/index.html" "/api/users" "/login" "/admin" "/wp-admin" 
       "/.env" "/config.php" "/admin/login" "/phpmyadmin")
codes=("200" "200" "200" "200" "200" "301" "403" "404" "404" "500")
sizes=("1234" "5678" "2048" "4096" "512" "256" "0" "128")

for i in $(seq 1 2000); do
    ip=${ips[$RANDOM % ${#ips[@]}]}
    method=${methods[$RANDOM % ${#methods[@]}]}
    path=${paths[$RANDOM % ${#paths[@]}]}
    code=${codes[$RANDOM % ${#codes[@]}]}
    size=${sizes[$RANDOM % ${#sizes[@]}]}
    date=$(date -d "-$((RANDOM % 1440)) minutes" '+%d/%b/%Y:%H:%M:%S +0000')
    
    echo "$ip - - [$date] \"$method $path HTTP/1.1\" $code $size"
done
SCRIPT
chmod +x generate_realistic_log.sh
./generate_realistic_log.sh > access.log
```

## Demo Live (5 minute)

### Pasul 1: Arată volumul (30 sec)

```bash
wc -l access.log
# Output: 2000 access.log

head access.log
# Arată structura
```

**[SPUNE]**: "2000 de linii de log. Manual ar dura ore. Să vedem în câteva secunde..."

### Pasul 2: Top Atacatori (1 min)

```bash

*(Bash-ul are o sintaxă urâtă, recunosc. Dar rulează peste tot, și asta contează enorm în practică.)*

# One-liner magic
awk '{print $1}' access.log | sort | uniq -c | sort -rn | head -5
```

**[SPUNE]**: "Instant! Cele mai active IP-uri. Acesta ar putea fi atacatorul."

### Pasul 3: Ce au încercat să acceseze? (1 min)

```bash
# Căutări suspecte
grep -E '(admin|config|\.env|phpmyadmin)' access.log | awk '{print $7}' | sort | uniq -c | sort -rn
```

**[SPUNE]**: "Scanare de vulnerabilități! Caută admin panels și fișiere de config."

### Pasul 4: Timeline atac (1 min)

```bash
# Grupare pe oră
awk '{print $4}' access.log | cut -d: -f1-2 | sort | uniq -c | sort -k2
```

**[SPUNE]**: "Putem vedea CÂND s-a intensificat atacul."

### Pasul 5: Raport complet (1.5 min)

```bash

*Notă personală: Prefer scripturi Bash pentru automatizări simple și Python când logica devine complexă. E o chestiune de pragmatism.*

# One-liner EPIC
echo "=== SECURITY INCIDENT REPORT ===" && \
echo -e "\n📊 Top 5 Source IPs:" && \
awk '{print $1}' access.log | sort | uniq -c | sort -rn | head -5 && \
echo -e "\n🚨 Suspicious Requests:" && \
grep -cE '(admin|config|\.env|wp-)' access.log && \

> 💡 În laboratoarele anterioare, am văzut că cea mai frecventă greșeală e uitarea ghilimelelor la variabile cu spații.

echo -e "\n❌ Failed Requests (4xx/5xx):" && \
grep -cE '" [45][0-9]{2} ' access.log && \
echo -e "\n⏰ Peak Hour:" && \
awk '{print $4}' access.log | cut -d: -f2 | sort | uniq -c | sort -rn | head -1
```

**[PAUZĂ DRAMATICĂ]**

**[SPUNE]**: "Asta înseamnă text processing în Linux. Astăzi învățați să faceți asta."

---

# DEMO 2: CSV TO HTML TABLE

## Povestea
> "Ai un CSV cu date și trebuie să-l transformi într-o pagină HTML pentru prezentare. Fără Excel, fără Python - doar terminalul."

## Demo

```bash
# Input
cat employees.csv

# Magic transformation
awk -F',' '
BEGIN {
    print "<!DOCTYPE html><html><head><style>"
    print "table {border-collapse: collapse; width: 100%;}"
    print "th, td {border: 1px solid black; padding: 8px; text-align: left;}"
    print "th {background-color: #4CAF50; color: white;}"
    print "tr:nth-child(even) {background-color: #f2f2f2;}"
    print "</style></head><body><h1>Employee Report</h1><table>"
}
NR == 1 {
    print "<tr>"
    for (i=1; i<=NF; i++) print "<th>" $i "</th>"
    print "</tr>"
    next
}
{
    print "<tr>"
    for (i=1; i<=NF; i++) print "<td>" $i "</td>"
    print "</tr>"
}
END {
    print "</table></body></html>"
}' employees.csv > report.html

# Arată rezultatul
echo "Generated report.html"
ls -la report.html

# Deschide în browser (dacă e disponibil)
# firefox report.html &
```

**[SPUNE]**: "Un singur awk și avem o pagină web profesională. Asta e automatable pentru rapoarte zilnice!"

---

# DEMO 3: REAL-TIME LOG MONITORING

## Povestea
> "Vrei să monitorizezi în timp real ce se întâmplă pe server, cu highlighting pentru erori."

## Demo

### Terminal 1: Generează log-uri simulate

```bash
# Într-un terminal separat
while true; do
    echo "$(date '+%Y-%m-%d %H:%M:%S') INFO: Request processed successfully"
    sleep 1
    if [ $((RANDOM % 5)) -eq 0 ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') ERROR: Database connection failed"
    fi
    if [ $((RANDOM % 10)) -eq 0 ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') WARNING: High memory usage detected"

> 💡 Am observat că studenții care desenează diagrama pe hârtie înainte de a scrie codul au rezultate mult mai bune.

    fi
done >> live.log
```

### Terminal 2: Monitorizare cu highlighting

```bash
# Watch pentru erori cu color
tail -f live.log | grep --color=always -E 'ERROR|WARNING|$'
```

### Versiune avansată cu awk

```bash
tail -f live.log | awk '
/ERROR/   { print "\033[31m" $0 "\033[0m"; next }
/WARNING/ { print "\033[33m" $0 "\033[0m"; next }
/INFO/    { print "\033[32m" $0 "\033[0m"; next }
          { print }
'
```

**[SPUNE]**: "Monitorizare în timp real cu color coding. Asta rulează pe orice server Linux!"

---

# DEMO 4: DATA EXTRACTION MAGIC

## Povestea
> "Ai un document HTML lung și trebuie să extragi toate link-urile și email-urile."

## Setup

```bash
cat > webpage.html << 'EOF'
<!DOCTYPE html>
<html>
<head><title>Company Page</title></head>
<body>
    <h1>Contact Us</h1>
    <p>Email us at <a href="mailto:info_AT_company_DOT_com">info_AT_company_DOT_com</a></p>
    <p>Sales: sales_AT_company_DOT_com | Support: support_AT_company_DOT_com</p>
    <h2>Useful Links</h2>
    <ul>
        <li><a href="https://docs.company.com/guide">Documentation</a></li>
        <li><a href="https://api.company.com/v2">API Reference</a></li>
        <li><a href="https://github.com/company/repo">GitHub</a></li>
    </ul>
    <footer>
        <p>Visit our <a href="https://blog.company.com">blog</a></p>
        <p>Contact John at john.doe_AT_company_DOT_com or Jane at jane_AT_external_DOT_org</p>
    </footer>
</body>
</html>
EOF
```

## Demo

### Extrage toate URL-urile

```bash
grep -oE 'https?://[^"<>]+' webpage.html | sort -u
```

**Output:**
```
https://api.company.com/v2
https://blog.company.com
https://docs.company.com/guide
https://github.com/company/repo
```

### Extrage toate email-urile

```bash
grep -oE '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' webpage.html | sort -u
```

**Output:**
```
info_AT_company_DOT_com
jane_AT_external_DOT_org
john.doe_AT_company_DOT_com
sales_AT_company_DOT_com
support_AT_company_DOT_com
```

### Combo: Raport complet

```bash
echo "=== WEBPAGE ANALYSIS ===" && \
echo -e "\n🔗 URLs Found:" && \
grep -oE 'https?://[^"<>]+' webpage.html | sort -u && \
echo -e "\n📧 Emails Found:" && \
grep -oE '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' webpage.html | sort -u
```

---

# DEMO 5: INSTANT FILE RENAMING

## Povestea
> "Ai 50 de fișiere cu nume urâte și vrei să le redenumești după un pattern."

## Setup

```bash
# Creează fișiere de test
mkdir -p rename_demo && cd rename_demo
for i in {1..10}; do
    touch "Document $(date -d "-$i days" +%Y%m%d) - Copy ($i).txt"
done
ls
```

## Demo

### Problema: Nume complexe

```
Document 20250119 - Copy (1).txt
Document 20250118 - Copy (2).txt
...
```

### Soluția: Rename cu regex

```bash
# Preview (dry run)
for f in *.txt; do
    new=$(echo "$f" | sed -E 's/Document ([0-9]+) - Copy \(([0-9]+)\)/doc_\1_v\2/')
    echo "$f -> $new"
done

# Executare reală
for f in *.txt; do
    new=$(echo "$f" | sed -E 's/Document ([0-9]+) - Copy \(([0-9]+)\)/doc_\1_v\2/')
    mv "$f" "$new"
done
ls
```

**Output:**
```
doc_20250119_v1.txt
doc_20250118_v2.txt
...
```

**[SPUNE]**: "50 de fișiere redenumite în secunde. Imaginați-vă să faceți asta manual!"

---

# DEMO 6: CONFIG FILE TRANSFORMER

## Povestea
> "Ai un format de config și trebuie să-l transformi în alt format pentru o altă aplicație."

## Demo: INI to JSON

```bash
cat > app.ini << 'EOF'
[database]
host=localhost
port=5432
name=myapp

[server]
host=0.0.0.0
port=8080
debug=true

[logging]
level=info
file=/var/log/app.log
EOF

# modificare în JSON
awk '
BEGIN { print "{"; first_section=1 }
/^\[.*\]$/ {
    if (!first_section) print "  },"
    first_section=0
    section=$0
    gsub(/[\[\]]/, "", section)
    printf "  \"%s\": {\n", section
    first_item=1
    next
}
/=/ {
    if (!first_item) print ","
    first_item=0
    split($0, arr, "=")
    key=arr[1]; value=arr[2]
    if (value ~ /^[0-9]+$/ || value == "true" || value == "false")
        printf "    \"%s\": %s", key, value
    else
        printf "    \"%s\": \"%s\"", key, value
}
END { print "\n  }\n}" }
' app.ini
```

---

# DEMO 7: MARKDOWN TO HTML (Mini Compiler)

## Demo

```bash
cat > sample.md << 'EOF'
# Main Title

This is a paragraph with **bold** and *italic* text.

## Section One

- Item 1
- Item 2
- Item 3

## Section Two

Here is some `inline code` and a [link](https://example.com).
EOF

# Mini Markdown compiler
sed -E '
    s/^# (.*)/<h1>\1<\/h1>/
    s/^## (.*)/<h2>\1<\/h2>/
    s/^### (.*)/<h3>\1<\/h3>/
    s/\*\*([^*]+)\*\*/<strong>\1<\/strong>/g
    s/\*([^*]+)\*/<em>\1<\/em>/g
    s/`([^`]+)`/<code>\1<\/code>/g
    s/\[([^]]+)\]\(([^)]+)\)/<a href="\2">\1<\/a>/g
    s/^- (.*)/<li>\1<\/li>/
' sample.md
```

**[SPUNE]**: "Un mini-compiler Markdown în câteva linii de sed. Asta face regex-ul!"

---

# DEMO 8: PROCESS MONITOR ONE-LINER

## Demo

```bash
# Top 5 procese după memorie, refresh la 2 secunde
watch -n 2 'ps aux --sort=-%mem | head -6 | awk "{printf \"%-10s %5s %5s %s\n\", \$1, \$3, \$4, \$11}"'
```

## Versiune avansată

```bash
# Dashboard simplu
watch -n 1 '
echo "=== SYSTEM DASHBOARD $(date "+%H:%M:%S") ==="
echo ""
echo "📊 Top CPU:"
ps aux --sort=-%cpu | head -4 | awk "NR>1 {printf \"  %-15s %5s%%\n\", \$11, \$3}"
echo ""
echo "💾 Top Memory:"
ps aux --sort=-%mem | head -4 | awk "NR>1 {printf \"  %-15s %5s%%\n\", \$11, \$4}"
echo ""
echo "🌐 Network Connections:"
ss -tuln 2>/dev/null | grep LISTEN | wc -l | xargs echo "  Listening ports:"
'
```

---

# DEMO 9: ASCII ART GENERATOR

## Demo Distractiv

```bash
# Banner text
echo "LINUX RULES" | sed 's/./& /g' | figlet -f small 2>/dev/null || \
awk 'BEGIN {
    split("LINUX", chars, "")
    for (i=1; i<=length("LINUX"); i++) printf " %s ", chars[i]
    print ""
}'

# Sau pattern simplu
cat << 'EOF'
  _     ___ _   _ _   ___  __
 | |   |_ _| \ | | | | \ \/ /
 | |    | ||  \| | | | |\  / 
 | |___ | || |\  | |_| |/  \ 
 |_____|___|_| \_|\___//_/\_\
                              
     Powered by grep/sed/awk!
EOF
```

---

## Ghid de Utilizare Demo-uri

| Demo | Când | Durată | Impact |
|------|------|--------|--------|
| Log Analysis | Hook (început) | 5 min | ⭐⭐⭐⭐⭐ |
| CSV to HTML | După awk basics | 3 min | ⭐⭐⭐⭐ |
| Real-time Monitor | După grep | 2 min | ⭐⭐⭐⭐ |
| Data Extraction | După regex | 3 min | ⭐⭐⭐⭐⭐ |
| File Renaming | După sed | 3 min | ⭐⭐⭐⭐ |
| Config Transformer | După awk | 4 min | ⭐⭐⭐ |
| Markdown Compiler | Final/Bonus | 3 min | ⭐⭐⭐⭐ |
| Process Monitor | Final | 2 min | ⭐⭐⭐ |
| ASCII Art | Fun break | 1 min | ⭐⭐ |

---

## Checklist Demo-uri

```
□ Sample data pregătită
□ Scripturi testate
□ Terminal cu font mare
□ Culorile funcționează
□ Backup plan dacă ceva nu merge
□ Timing practicat
□ Comentarii pregătite pentru fiecare pas
```

---

*Demo-uri Spectaculoase pentru Seminarul 7-8 de Sisteme de Operare | ASE București - CSIE*
