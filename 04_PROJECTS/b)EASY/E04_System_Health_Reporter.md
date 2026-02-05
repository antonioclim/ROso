# E04: Raportare Sănătate Sistem

> **Nivel:** EASY | **Timp estimat:** 15-20 ore | **Componente:** Doar Bash

---

## Descriere

Dezvoltă un instrument care generează rapoarte cuprinzătoare despre starea de sănătate a sistemului: CPU, memorie, disc, rețea, procese și servicii.

---

## Obiective de Învățare

- Folosirea instrumentelor de sistem (`top`, `free`, `df`, `ps`, `netstat`)
- Parsare `/proc` și `/sys`
- Generare rapoarte HTML/text
- Praguri și alertare

---

## Cerințe Funcționale

### Obligatorii (pentru nota de trecere)

1. **Monitorizare CPU** - load average, utilizare per-core, procese top
2. **Monitorizare memorie** - RAM, swap, cache/buffers
3. **Monitorizare disc** - spațiu pe partiție, statistici I/O
4. **Monitorizare rețea** - interfețe, trafic, conexiuni
5. Procese - număr, consumatori top, procese zombie
6. **Servicii** - status servicii critice (configurabil)
7. Output - text formatat + HTML opțional

### Opționale (pentru punctaj complet)

8. **Alertare** - evidențiere probleme (roșu/galben/verde)
9. **Istoric** - comparare cu rulări anterioare
10. **Export** - JSON pentru integrare cu alte instrumente
11. **Mod watch** - refresh periodic în terminal

---

## Interfață

```bash
./health_reporter.sh [OPTIONS]

Options:
  -h, --help              Display help
  -o, --output FILE       Save report
  -f, --format FORMAT     Format: text|html|json
  -s, --services LIST     List of services to check
  -w, --watch SECONDS     Continuous refresh mode
  --cpu-threshold N       CPU alert threshold (default: 80%)
  --mem-threshold N       Memory alert threshold (default: 90%)
  --disk-threshold N      Disk alert threshold (default: 85%)

Examples:
  ./health_reporter.sh
  ./health_reporter.sh -f html -o report.html
  ./health_reporter.sh -w 5 --cpu-threshold 70
  ./health_reporter.sh -s "nginx,mysql,ssh"
```

---

## Exemplu Output

```
╔══════════════════════════════════════════════════════════════════╗
║              RAPORT SĂNĂTATE SISTEM                              ║
║  Hostname: webserver01    Data: 2025-01-20 14:30:00             ║
║  Uptime: 45 zile, 3:24    Kernel: 5.15.0-generic                ║
╚══════════════════════════════════════════════════════════════════╝

🖥️  STATUS CPU [🟢 OK]
──────────────────────────────────────────────────────────────────
Load Average:    0.45, 0.52, 0.48 (4 cores)
Utilizare:       12.3% user, 3.2% system, 84.5% idle

Consumatori Top CPU:
  PID     USER      CPU%    COMANDĂ
  1234    www-data  5.2%    /usr/sbin/nginx
  5678    mysql     3.1%    /usr/sbin/mysqld

💾 STATUS MEMORIE [🟡 WARNING - 78% folosit]
──────────────────────────────────────────────────────────────────
RAM:    12.4 GB / 16 GB (78%)  ████████████████░░░░
Swap:   0.2 GB / 4 GB (5%)     █░░░░░░░░░░░░░░░░░░░
Cache:  3.2 GB

💿 STATUS DISC [🟢 OK]
──────────────────────────────────────────────────────────────────
Filesystem      Size    Used    Avail   Use%    Mounted on
/dev/sda1       100G    45G     55G     45%     /
/dev/sdb1       500G    234G    266G    47%     /data

🌐 STATUS REȚEA [🟢 OK]
──────────────────────────────────────────────────────────────────
Interfață   IP              RX          TX          Status
eth0        192.168.1.10    1.2 GB      890 MB      UP
lo          127.0.0.1       45 MB       45 MB       UP

Conexiuni active: 234 (ESTABLISHED: 45, TIME_WAIT: 189)

⚙️  STATUS SERVICII
──────────────────────────────────────────────────────────────────
Serviciu     Status      PID       Memorie   CPU
nginx        🟢 running  1234      45 MB     2.1%
mysql        🟢 running  5678      512 MB    5.3%
ssh          🟢 running  890       12 MB     0.1%
redis        🔴 stopped  -         -         -

📊 SĂNĂTATE GENERALĂ: 🟡 WARNING
──────────────────────────────────────────────────────────────────
[!] Utilizare memorie peste 75% - consideră optimizare
[!] Serviciul 'redis' nu rulează
```

---

## Structură Recomandată

```
E04_System_Health_Reporter/
├── src/
│   ├── health_reporter.sh
│   └── lib/
│       ├── cpu.sh
│       ├── memory.sh
│       ├── disk.sh
│       ├── network.sh
│       ├── services.sh
│       └── report.sh
├── etc/
│   ├── services.conf       # services to monitor
│   └── thresholds.conf     # alert thresholds
├── templates/
│   └── report.html         # HTML template
└── tests/
```

---

## Criterii de Evaluare

| Criteriu | Pondere |
|-----------|--------|
| Monitorizare CPU | 15% |
| Monitorizare memorie | 15% |
| Monitorizare disc | 10% |
| Monitorizare rețea | 10% |
| Status servicii | 10% |
| Alertare cu culori | 10% |
| Calitate cod | 15% |
| Teste | 10% |
| Documentație | 5% |

---

*Proiect EASY | Sisteme de Operare | ASE-CSIE*
