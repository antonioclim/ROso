# System Monitor

**Aplicație completă de monitorizare resurse sistem în Bash**

## Descriere

System Monitor este o aplicație profesională pentru monitorizarea resurselor sistemului: CPU, memorie, disk, swap și load average. Suportă alerting configurabil, notificări prin email și Slack, mod daemon pentru monitorizare continuă și multiple formate de output.

## Arhitectură

```
monitor/
├── monitor.sh          # Script principal (entry point)
├── bin/
│   └── sysmonitor      # Wrapper pentru instalare
├── lib/
│   ├── core.sh         # Funcții fundamentale (logging, error handling)
│   ├── utils.sh        # Funcții de colectare metrici sistem
│   └── config.sh       # Gestiunea configurării
├── etc/
│   └── monitor.conf    # Configurare default
├── var/
│   ├── log/            # Fișiere log
│   └── run/            # PID files (pentru daemon mode)
└── tests/
    └── test_monitor.sh # Suite de teste
```

## Instalare

```bash
# Clonează/copiază proiectul
cd /path/to/monitor

# Setează permisiuni execuție
chmod +x monitor.sh bin/sysmonitor tests/test_monitor.sh

# Opțional: creează symlink pentru acces global
sudo ln -sf "$(pwd)/monitor.sh" /usr/local/bin/sysmonitor
```

## Utilizare

### Verificare Single-Shot

```bash
# Verificare rapidă (ieșire imediată)
./monitor.sh

# Cu output JSON
./monitor.sh -o json

# Verbose mode
./monitor.sh -v
```

### Mod Daemon

```bash
# Pornește monitorizarea continuă
./monitor.sh -d

# Cu interval personalizat (30 secunde)
./monitor.sh -d -i 30

# Cu notificări email
./monitor.sh -d -e contact_eliminat
```

### Thresholds Personalizate

```bash
# Setează thresholds specifice
./monitor.sh --cpu-threshold 90 --mem-threshold 95 --disk-threshold 80

# Sau prin variabile de mediu
THRESHOLD_CPU=90 THRESHOLD_MEM=95 ./monitor.sh
```

### Formate Output

```bash
# Text (default)
./monitor.sh -o text

# JSON (pentru parsing automatizat)
./monitor.sh -o json

# CSV (pentru logging/grafice)
./monitor.sh -o csv
```

## Configurare

### Fișier de Configurare

Editează `etc/monitor.conf`:

```bash
# Thresholds pentru alerte (procente)
THRESHOLD_CPU=80
THRESHOLD_MEM=90
THRESHOLD_DISK=85
THRESHOLD_SWAP=50

# Interval monitorizare (secunde)
MONITOR_INTERVAL=60

# Notificări
NOTIFY_EMAIL=contact_eliminat
NOTIFY_ON_RECOVERY=true

# Logging
LOG_LEVEL=INFO
LOG_FILE=/var/log/sysmonitor.log
```

### Environment Variables

Toate setările pot fi suprascrise prin variabile de mediu:

```bash
export THRESHOLD_CPU=95
export NOTIFY_EMAIL=contact_eliminat
export LOG_LEVEL=DEBUG
./monitor.sh
```

### Opțiuni Command Line

```
Utilizare: monitor.sh [opțiuni]

Opțiuni:
    -c, --config FILE       Fișier de configurare
    --cpu-threshold N       Threshold alertă CPU (default: 80%)
    --mem-threshold N       Threshold alertă memorie (default: 90%)
    --disk-threshold N      Threshold alertă disk (default: 85%)
    -i, --interval N        Interval monitorizare în secunde (default: 60)
    -l, --log-file FILE     Fișier pentru loguri
    --log-level LEVEL       Nivel logging: DEBUG, INFO, WARN, ERROR
    -e, --email ADDRESS     Adresă email pentru notificări
    -d, --daemon            Rulează în mod daemon
    -n, --dry-run           Doar afișează, nu trimite notificări
    -v, --verbose           Output detaliat (activează DEBUG)
    -o, --output FORMAT     Format output: text, json, csv
    --exclude-mount PATH    Exclude mount point din monitorizare
    -h, --help              Afișează acest mesaj
    --version               Afișează versiunea
```

## Integrare Sistem

### Systemd Service

Creează `/etc/systemd/system/sysmonitor.service`:

```ini
[Unit]
Description=System Monitor Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/sysmonitor -d
Restart=always
RestartSec=60
User=root

[Install]
WantedBy=multi-user.target
```

Activare:

```bash
sudo systemctl daemon-reload
sudo systemctl enable sysmonitor
sudo systemctl start sysmonitor
```

### Cron Job

Pentru monitorizare periodică fără daemon:

```bash
# Editează crontab
crontab -e

# Adaugă: verificare la fiecare 5 minute
*/5 * * * * /usr/local/bin/sysmonitor >> /var/log/sysmonitor.log 2>&1
```

## Testare

```bash
# Rulează toate testele
./tests/test_monitor.sh

# Doar teste pentru core.sh
./tests/test_monitor.sh core

# Verbose
./tests/test_monitor.sh -v
```

## Exit Codes

| Cod | Semnificație |
|-----|--------------|
| 0   | Succes, toate resursele OK |
| 1   | Eroare de configurare |
| 2   | Cel puțin o alertă activă |
| 3   | Eroare fatală |

## Structura Codului

### core.sh
- Funcții de logging (`log`, `log_info`, `log_error`, etc.)
- Error handling (`die`, `check_error`)
- Validare (`require_cmd`, `require_file`, `is_integer`)
- Lock files (`acquire_lock`, `release_lock`)

### utils.sh
- Metrici CPU (`get_cpu_usage`, `get_cpu_cores`, `get_load_average`)
- Metrici memorie (`get_memory_usage`, `get_swap_usage`)
- Metrici disk (`get_disk_usage`, `get_all_disk_info`)
- Informații procese (`get_process_count`, `get_top_cpu_processes`)
- Informații sistem (`get_hostname`, `get_uptime_seconds`)

### config.sh
- Încărcare configurare din fișier
- Parsare argumente command line
- Validare configurare
- Help și versiune

## Licență

Material educațional - ASE București, CSIE - Sisteme de Operare
