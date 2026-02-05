# E02: Analizator Log-uri

> **Nivel:** EASY | **Timp estimat:** 15-20 ore | **Componente:** Doar Bash

---

## Descriere

> 💡 **Nota instructorului:** Acest proiect te învață procesarea textului — pâinea și untul administrării de sisteme. Competențele pe care le înveți aici (grep, sed, awk) sunt aceleași pe care inginerii seniori le folosesc zilnic. Am văzut studenți obținând internship-uri specific pentru că puteau demonstra competențe de analiză log-uri din acest proiect.

Dezvoltă un instrument pentru analiza fișierelor de log. Script-ul va parsa, filtra și genera statistici din diverse formate de log (syslog, Apache, nginx, aplicații custom).

---

## Obiective de Învățare

- Procesare text cu `grep`, `sed`, `awk`
- Expresii regulate avansate
- Agregare și statistici
- Parsare formate structurate

---

## Cerințe Funcționale

### Obligatorii (pentru nota de trecere)

1. **Parsare formate standard**

Trei lucruri contează aici: syslog (`/var/log/syslog`), log-uri access apache/nginx și log-uri auth (`/var/log/auth.log`).

2. **Filtrare**
   - După nivel (ERROR, WARN, INFO, DEBUG)
   - După interval de timp
   - După pattern/cuvânt cheie
   - După sursă/serviciu

3. **Statistici**
   - Numărare pe nivel de severitate
   - Top 10 mesaje frecvente
   - Distribuție pe ore/zile
   - Erori pe serviciu

4. Output
   - Raport text formatat
   - Export CSV pentru analiză ulterioară

### Opționale (pentru punctaj complet)

5. **Detectare anomalii** - vârfuri de erori
6. **Alertare** - notificare la prag
7. **Mod tail** - monitorizare în timp real
8. **Agregare fișiere multiple**

---

## Interfață

```bash
./log_analyzer.sh [OPTIONS] <log_file|log_dir>

Options:
  -h, --help              Display help
  -l, --level LEVEL       Filter by level (ERROR|WARN|INFO|DEBUG)
  -s, --start DATETIME    Start timestamp (YYYY-MM-DD HH:MM)
  -e, --end DATETIME      End timestamp
  -p, --pattern REGEX     Filter by pattern
  -f, --format FORMAT     Log format: auto|syslog|apache|nginx|custom
  -o, --output FILE       Save report
  --top N                 Top N frequent messages (default: 10)
  --stats-only            Statistics only, no details
  -t, --tail              Continuous monitoring mode

Examples:
  ./log_analyzer.sh /var/log/syslog
  ./log_analyzer.sh -l ERROR --start "2025-01-20 00:00" /var/log/
  ./log_analyzer.sh -p "failed|error" -f apache access.log
  ./log_analyzer.sh -t --level ERROR /var/log/syslog
```

---

## Exemplu Output

```
╔══════════════════════════════════════════════════════════════════╗
║                    RAPORT ANALIZĂ LOG-URI                        ║
║  Fișier: /var/log/syslog                                        ║
║  Perioadă: 2025-01-20 00:00 - 2025-01-20 23:59                 ║
╚══════════════════════════════════════════════════════════════════╝

📊 DISTRIBUȚIE SEVERITATE
──────────────────────────────────────────────────────────────────
Nivel      Număr     Procent       Vizual
─────────────────────────────────────────────────────────────────
ERROR      234       2.3%          ██
WARN       1,456     14.5%         ██████████████
INFO       7,890     78.7%         ██████████████████████████████████████████████████████
DEBUG      450       4.5%          ████

Total intrări: 10,030

⏰ DISTRIBUȚIE ORARĂ
──────────────────────────────────────────────────────────────────
00:00 ████████████ 456
01:00 ████████ 312
02:00 ██████ 234
···
14:00 ████████████████████████ 892  <- Oră de vârf
15:00 ██████████████████████ 823
···

🔴 TOP 10 MESAJE EROARE
──────────────────────────────────────────────────────────────────
Număr  Mesaj
───────────────────────────────────────
  45   Connection refused to database server
  34   Failed to authenticate user
  23   Disk space warning on /var
  ···

🔧 ERORI PE SERVICIU
──────────────────────────────────────────────────────────────────
Serviciu         Erori     Procent
───────────────────────────────────────
mysql            89        38.0%
nginx            45        19.2%
cron             34        14.5%
systemd          28        12.0%
altele           38        16.3%

⚠️  ANOMALII DETECTATE
──────────────────────────────────────────────────────────────────
[!] Vârf erori la 14:23 - 47 erori în 5 minute (normal: 2-5)
[!] Serviciul 'mysql' are rată erori de 3x față de normal

══════════════════════════════════════════════════════════════════
Analiză completată în 3.2 secunde
══════════════════════════════════════════════════════════════════
```

---

## Structură Recomandată

```
E02_Log_Analyzer/
├── README.md
├── Makefile
├── src/
│   ├── log_analyzer.sh
│   └── lib/
│       ├── parsers/
│       │   ├── syslog.sh
│       │   ├── apache.sh
│       │   └── nginx.sh
│       ├── filters.sh
│       ├── stats.sh
│       └── report.sh
├── etc/
│   └── patterns.conf         # Regex patterns for formats
├── tests/
│   ├── sample_logs/
│   │   ├── sample_syslog.log
│   │   └── sample_apache.log
│   └── test_*.sh
└── docs/
    └── USAGE.md
```

---

## Indicii de Implementare

### Parsare syslog

```bash
# Format: Jan 20 14:30:45 hostname service[pid]: message
parse_syslog() {
    awk '{
        timestamp = $1" "$2" "$3
        host = $4
        match($5, /([^[]+)/, service)
        message = substr($0, index($0,$6))
        print timestamp"|"host"|"service[1]"|"message
    }' "$1"
}
```

### Filtrare timp

```bash
# Timestamp conversion for comparison
date_to_epoch() {
    date -d "$1" +%s 2>/dev/null
}
```

### Numărare niveluri

```bash
grep -cE "(ERROR|WARN|INFO|DEBUG)" "$logfile" | sort | uniq -c
```

---

## ⚠️ Capcane Comune

> Bazat pe predările din anii anteriori, acestea sunt greșelile pe care studenții le fac cel mai des:

### 1. Parsare cu Poziții Coloane Fixe
**Problemă:** Presupunere că syslog are întotdeauna timestamp-ul în coloanele 1-3. Unele sisteme folosesc formate diferite.
**Soluție:** Folosește regex matching flexibil, nu poziții fixe.

### 2. Negestionarea Fișierelor Mari
**Problemă:** Încărcarea întregului fișier log în memorie se blochează la log-uri de producție (500MB+).
**Soluție:** Procesează linie cu linie cu `while read` sau folosește `awk` streaming.

### 3. Ignorarea Fusurilor Orare
**Problemă:** Timestamp-urile nu se potrivesc corect când filtrezi după timp.
**Soluție:** Normalizează toate timestamp-urile la UTC înainte de comparare.

### 4. Path-uri Log Hardcoded
**Problemă:** Folosirea `/var/log/syslog` direct în loc să fie parametru.
**Soluție:** Acceptă întotdeauna path-ul log ca argument.

---

## Criterii Specifice de Evaluare

| Criteriu | Pondere |
|-----------|--------|
| Parsare format corectă | 20% |
| Filtrare funcțională | 15% |
| Statistici corecte | 15% |
| Output formatat | 10% |
| Funcționalități extra | 10% |
| Calitate cod | 15% |
| Teste | 10% |
| Documentație | 5% |

---

*Proiect EASY | Sisteme de Operare | ASE-CSIE*
