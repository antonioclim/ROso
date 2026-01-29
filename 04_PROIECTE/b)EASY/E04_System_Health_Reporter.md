# E04: System Health Reporter

> **Nivel:** EASY | **Timp estimat:** 15-20 ore | **Componente:** Bash only

---

## Descriere

Dezvoltă un tool care generează rapoarte complete despre starea de sănătate a sistemului: CPU, memorie, disc, rețea, procese și servicii.

---

## Obiective de Învățare

- Utilizarea tool-urilor de sistem (`top`, `free`, `df`, `ps`, `netstat`)
- Parsare `/proc` și `/sys`
- Generare rapoarte HTML/text
- Threshold-uri și alerting

---

## Cerințe Funcționale

### Obligatorii

1. **Monitorizare CPU** - load average, utilizare per core, top procese
2. **Monitorizare memorie** - RAM, swap, cache/buffers
3. **Monitorizare disc** - spațiu per partiție, I/O stats
4. **Monitorizare rețea** - interfețe, trafic, conexiuni
5. Procese - număr, top consumers, zombie processes
6. **Servicii** - status servicii critice (configurabile)
7. Output - text formatat + opțional HTML

### Opționale

8. **Alerting** - evidențiere probleme (roșu/galben/verde)
9. **Istoric** - comparație cu rulări anterioare
10. **Export** - JSON pentru integrare cu alte tool-uri
11. **Mod watch** - refresh periodic în terminal

---

## Interfață

```bash
./health_reporter.sh [OPȚIUNI]

Opțiuni:
  -h, --help              Afișează ajutor
  -o, --output FILE       Salvează raport
  -f, --format FORMAT     Format: text|html|json
  -s, --services LIST     Lista servicii de verificat
  -w, --watch SECONDS     Mod refresh continuu
  --cpu-threshold N       Threshold alertă CPU (default: 80%)
  --mem-threshold N       Threshold alertă memorie (default: 90%)
  --disk-threshold N      Threshold alertă disc (default: 85%)

Exemple:
  ./health_reporter.sh
  ./health_reporter.sh -f html -o report.html
  ./health_reporter.sh -w 5 --cpu-threshold 70
  ./health_reporter.sh -s "nginx,mysql,ssh"
```

---

## Exemplu Output

```
╔══════════════════════════════════════════════════════════════════╗
║              SYSTEM HEALTH REPORT                                ║
║  Hostname: webserver01    Date: 2025-01-20 14:30:00             ║
║  Uptime: 45 days, 3:24    Kernel: 5.15.0-generic                ║
╚══════════════════════════════════════════════════════════════════╝

🖥️  CPU STATUS [🟢 OK]
──────────────────────────────────────────────────────────────────
Load Average:    0.45, 0.52, 0.48 (4 cores)
Usage:           12.3% user, 3.2% system, 84.5% idle

Top CPU Consumers:
  PID     USER      CPU%    COMMAND
  1234    www-data  5.2%    /usr/sbin/nginx
  5678    mysql     3.1%    /usr/sbin/mysqld

💾 MEMORY STATUS [🟡 WARNING - 78% used]
──────────────────────────────────────────────────────────────────
RAM:    12.4 GB / 16 GB (78%)  ████████████████░░░░
Swap:   0.2 GB / 4 GB (5%)     █░░░░░░░░░░░░░░░░░░░
Cache:  3.2 GB

💿 DISK STATUS [🟢 OK]
──────────────────────────────────────────────────────────────────
Filesystem      Size    Used    Avail   Use%    Mounted on
/dev/sda1       100G    45G     55G     45%     /
/dev/sdb1       500G    234G    266G    47%     /data

🌐 NETWORK STATUS [🟢 OK]
──────────────────────────────────────────────────────────────────
Interface   IP              RX          TX          Status
eth0        192.168.1.10    1.2 GB      890 MB      UP
lo          127.0.0.1       45 MB       45 MB       UP

Active connections: 234 (ESTABLISHED: 45, TIME_WAIT: 189)

⚙️  SERVICES STATUS
──────────────────────────────────────────────────────────────────
Service      Status      PID       Memory    CPU
nginx        🟢 running  1234      45 MB     2.1%
mysql        🟢 running  5678      512 MB    5.3%
ssh          🟢 running  890       12 MB     0.1%
redis        🔴 stopped  -         -         -

📊 OVERALL HEALTH: 🟡 WARNING
──────────────────────────────────────────────────────────────────
[!] Memory usage above 75% - consider optimization
[!] Service 'redis' is not running
```

---

## Structura Recomandată

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
│   ├── services.conf       # servicii de monitorizat
│   └── thresholds.conf     # praguri alertă
├── templates/
│   └── report.html         # template HTML
└── tests/
```

---

## Criterii Evaluare

| Criteriu | Pondere |
|----------|---------|
| Monitorizare CPU | 15% |
| Monitorizare memorie | 15% |
| Monitorizare disc | 10% |
| Monitorizare rețea | 10% |
| Status servicii | 10% |
| Alerting cu culori | 10% |
| Calitate cod | 15% |
| Teste | 10% |
| Documentație | 5% |

---

*Proiect EASY | Sisteme de Operare | ASE-CSIE*
