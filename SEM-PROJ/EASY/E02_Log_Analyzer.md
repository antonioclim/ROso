# E02: Log Analyzer

> **Nivel:** EASY | **Timp estimat:** 15-20 ore | **Componente:** Bash only

---

## Descriere

Dezvoltă un tool pentru analiza fișierelor de log. Scriptul va parsa, filtra și genera statistici din diverse formate de log (syslog, Apache, nginx, aplicații custom).

---

## Obiective de Învățare

- Procesare text cu `grep`, `sed`, `awk`
- Expresii regulate avansate
- Agregare și statistici
- Parsare formate structurate

---

## Cerințe Funcționale

### Obligatorii

1. **Parsare formate standard**

Trei lucruri contează aici: syslog (`/var/log/syslog`), apache/nginx access logs, și auth logs (`/var/log/auth.log`).


2. **Filtrare**
   - După nivel (ERROR, WARN, INFO, DEBUG)
   - După interval de timp
   - După pattern/keyword
   - După sursă/serviciu

3. **Statistici**
   - Contorizare per nivel de severitate
   - Top 10 mesaje frecvente
   - Distribuție pe ore/zile
   - Erori per serviciu

4. Output
   - Raport text formatat
   - Export CSV pentru analiză ulterioară

### Opționale

5. **Detecție anomalii** - spike-uri de erori
6. **Alerting** - notificare la threshold
7. **Tail mode** - monitorizare în timp real
8. **Agregare multiple fișiere**

---

## Interfață

```bash
./log_analyzer.sh [OPȚIUNI] <log_file|log_dir>

Opțiuni:
  -h, --help              Afișează ajutor
  -l, --level LEVEL       Filtrare după nivel (ERROR|WARN|INFO|DEBUG)
  -s, --start DATETIME    Timestamp start (YYYY-MM-DD HH:MM)
  -e, --end DATETIME      Timestamp end
  -p, --pattern REGEX     Filtrare după pattern
  -f, --format FORMAT     Format log: auto|syslog|apache|nginx|custom
  -o, --output FILE       Salvează raport
  --top N                 Top N mesaje frecvente (default: 10)
  --stats-only            Doar statistici, fără detalii
  -t, --tail              Mod monitorizare continuă

Exemple:
  ./log_analyzer.sh /var/log/syslog
  ./log_analyzer.sh -l ERROR --start "2025-01-20 00:00" /var/log/
  ./log_analyzer.sh -p "failed|error" -f apache access.log
  ./log_analyzer.sh -t --level ERROR /var/log/syslog
```

---

## Exemplu Output

```
╔══════════════════════════════════════════════════════════════════╗
║                    LOG ANALYSIS REPORT                           ║
║  File: /var/log/syslog                                          ║
║  Period: 2025-01-20 00:00 - 2025-01-20 23:59                   ║
╚══════════════════════════════════════════════════════════════════╝

📊 SEVERITY DISTRIBUTION
──────────────────────────────────────────────────────────────────
Level      Count     Percentage    Visual
─────────────────────────────────────────────────────────────────
ERROR      234       2.3%          ██
WARN       1,456     14.5%         ██████████████
INFO       7,890     78.7%         ██████████████████████████████████████████████████████
DEBUG      450       4.5%          ████

Total entries: 10,030

⏰ HOURLY DISTRIBUTION
──────────────────────────────────────────────────────────────────
00:00 ████████████ 456
01:00 ████████ 312
02:00 ██████ 234
...
14:00 ████████████████████████ 892  <- Peak hour
15:00 ██████████████████████ 823
...

🔴 TOP 10 ERROR MESSAGES
──────────────────────────────────────────────────────────────────
Count  Message
───────────────────────────────────────
  45   Connection refused to database server
  34   Failed to authenticate user
  23   Disk space warning on /var
  ...

🔧 ERRORS BY SERVICE
──────────────────────────────────────────────────────────────────
Service          Errors    Percentage
───────────────────────────────────────
mysql            89        38.0%
nginx            45        19.2%
cron             34        14.5%
systemd          28        12.0%
other            38        16.3%

⚠️  ANOMALIES DETECTED
──────────────────────────────────────────────────────────────────
[!] Error spike at 14:23 - 47 errors in 5 minutes (normal: 2-5)
[!] Service 'mysql' has 3x normal error rate

══════════════════════════════════════════════════════════════════
Analysis completed in 3.2 seconds
══════════════════════════════════════════════════════════════════
```

---

## Structura Recomandată

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
│   └── patterns.conf         # Regex patterns pentru formate
├── tests/
│   ├── sample_logs/
│   │   ├── sample_syslog.log
│   │   └── sample_apache.log
│   └── test_*.sh
└── docs/
    └── USAGE.md
```

---

## Hints Implementare

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

### Filtrare după timp

```bash
# Convertire timestamp pentru comparație
date_to_epoch() {
    date -d "$1" +%s 2>/dev/null
}
```

### Contorizare niveluri

```bash
grep -cE "(ERROR|WARN|INFO|DEBUG)" "$logfile" | sort | uniq -c
```

---

## Criterii Evaluare Specifice

| Criteriu | Pondere |
|----------|---------|
| Parsare corectă formate | 20% |
| Filtrare funcțională | 15% |
| Statistici corecte | 15% |
| Output formatat | 10% |
| Funcționalități extra | 10% |
| Calitate cod | 15% |
| Teste | 10% |
| Documentație | 5% |

---

*Proiect EASY | Sisteme de Operare | ASE-CSIE*
