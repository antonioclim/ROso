# M04: Network Security Scanner

> **Nivel:** MEDIUM | **Timp estimat:** 25-35 ore | **Bonus K8s:** +10%

---

## Descriere

Scanner de securitate pentru rețele locale: detectare hosturi active, port scanning, identificare servicii, vulnerabilități cunoscute și generare rapoarte. Util pentru auditul periodic al infrastructurii.

---

## Obiective de Învățare

- Concepte de rețea: IP, TCP/UDP, ICMP
- Scanare porturi și detectare servicii
- Procesare paralelă în Bash (jobs, xargs)
- Parsare output `nmap` și alte tooluri
- Generare rapoarte structurate (HTML, JSON)

---

## Cerințe Funcționale

### Obligatorii (pentru notă de trecere)

1. **Descoperire hosturi**
   - Ping sweep pe subnet (ICMP echo)
   - ARP scan pentru rețea locală
   - Detectare hosturi fără ICMP (TCP SYN)

2. **Port scanning**
   - Scanare porturi comune (top 100/1000)
   - Scanare range specific de porturi
   - TCP connect scan și SYN scan (cu permisiuni)

3. **Identificare servicii**
   - Banner grabbing pentru porturi deschise
   - Detectare versiune serviciu
   - Fingerprinting OS (basic)

4. **Raportare**
   - Output text formatat
   - Export JSON pentru procesare
   - Export HTML pentru vizualizare

5. **Configurare și profile**
   - Profile predefinite (quick, normal, thorough)
   - Configurare porturi custom
   - Exclude list pentru hosturi/porturi

### Opționale (pentru punctaj complet)

6. **Verificare vulnerabilități** - Check CVE pentru versiuni detectate
7. **Comparație scan-uri** - Diff între două scan-uri (detectare schimbări)
8. **Scanare programată** - Integrare cron cu alertare
9. **Rate limiting** - Evită detectare/blocare
10. **TLS/SSL check** - Verificare certificate și configurație

---

## Interfață CLI

```bash
./netscan.sh <command> [opțiuni] <target>

Comenzi:
  discover              Descoperire hosturi în subnet
  scan                  Scanare porturi pe target
  service               Identificare servicii
  full                  Scan complet (discover + scan + service)
  compare               Compară două rapoarte
  report                Generează raport din date salvate

Target:
  192.168.1.0/24        Subnet CIDR
  192.168.1.1           Host individual
  192.168.1.1-50        Range de hosturi
  hosts.txt             Fișier cu lista de hosturi

Opțiuni:
  -p, --ports PORTS     Porturi de scanat (ex: 22,80,443 sau 1-1024)
  -P, --profile PROF    Profil: quick|normal|thorough|stealth
  -o, --output FILE     Fișier output (extensia determină formatul)
  -f, --format FMT      Format: text|json|html|csv
  -t, --timeout SEC     Timeout per port (default: 2)
  -T, --threads N       Număr thread-uri paralele (default: 10)
  -v, --verbose         Output detaliat
  --no-ping             Nu verifica cu ping înainte
  --tcp-only            Doar TCP, fără UDP
  --rate-limit N        Max N pachete/secundă

Exemple:
  ./netscan.sh discover 192.168.1.0/24
  ./netscan.sh scan -p 22,80,443 192.168.1.1
  ./netscan.sh full -P thorough -o report.html 10.0.0.0/24
  ./netscan.sh compare scan1.json scan2.json
```

---

## Exemple Output

### Discover Output

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    NETWORK DISCOVERY REPORT                                  ║
║                    Target: 192.168.1.0/24                                   ║
║                    Date: 2025-01-20 15:30:00                                ║
╚══════════════════════════════════════════════════════════════════════════════╝

Scanning 256 hosts...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 100%

┌─────────────────────────────────────────────────────────────────────────────┐
│ DISCOVERED HOSTS: 12                                                        │
├─────────────────┬───────────────────┬──────────────┬───────────────────────┤
│ IP Address      │ MAC Address       │ Hostname     │ Response Time         │
├─────────────────┼───────────────────┼──────────────┼───────────────────────┤
│ 192.168.1.1     │ aa:bb:cc:dd:ee:01 │ router.local │ 1ms                   │
│ 192.168.1.10    │ aa:bb:cc:dd:ee:10 │ server01     │ 2ms                   │
│ 192.168.1.11    │ aa:bb:cc:dd:ee:11 │ server02     │ 1ms                   │
│ 192.168.1.20    │ aa:bb:cc:dd:ee:20 │ desktop-ion  │ 3ms                   │
│ 192.168.1.21    │ aa:bb:cc:dd:ee:21 │ laptop-maria │ 5ms                   │
│ ...             │ ...               │ ...          │ ...                   │
└─────────────────┴───────────────────┴──────────────┴───────────────────────┘

Summary:
  Total scanned:    256
  Hosts up:         12 (4.7%)
  Hosts down:       244
  Scan duration:    8.3 seconds
```

### Full Scan Output

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    FULL SECURITY SCAN REPORT                                 ║
║                    Target: 192.168.1.10                                     ║
╚══════════════════════════════════════════════════════════════════════════════╝

HOST: 192.168.1.10 (server01.local)
═══════════════════════════════════════════════════════════════════════════════

OS Detection: Linux 5.x (Ubuntu)
MAC: aa:bb:cc:dd:ee:10 (Dell Inc.)

┌─────────────────────────────────────────────────────────────────────────────┐
│ OPEN PORTS                                                                  │
├───────┬──────────┬─────────────────────────────────────────────────────────┤
│ Port  │ Protocol │ Service                                                 │
├───────┼──────────┼─────────────────────────────────────────────────────────┤
│ 22    │ tcp      │ OpenSSH 8.9p1 Ubuntu                                    │
│ 80    │ tcp      │ nginx/1.24.0                                            │
│ 443   │ tcp      │ nginx/1.24.0 (TLS 1.3)                                  │
│ 3306  │ tcp      │ MySQL 8.0.35                                            │
│ 5432  │ tcp      │ PostgreSQL 15.4                                         │
│ 6379  │ tcp      │ Redis 7.2.3                                             │
│ 8080  │ tcp      │ Apache Tomcat 10.1.x                                    │
└───────┴──────────┴─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│ ⚠️  SECURITY FINDINGS                                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│ [MEDIUM] Port 6379 (Redis) - No authentication detected                    │
│ [LOW]    Port 22 (SSH) - Password authentication enabled                   │
│ [INFO]   Port 3306 (MySQL) - Accessible from network                       │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│ TLS/SSL CHECK (port 443)                                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│ Certificate: CN=server01.example.com                                        │
│ Issuer: Let's Encrypt                                                       │
│ Valid until: 2025-04-20 (90 days)                                          │
│ Protocols: TLSv1.2, TLSv1.3 ✓                                              │
│ Cipher suites: Modern (AEAD) ✓                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### JSON Output

```json
{
  "scan_info": {
    "target": "192.168.1.10",
    "timestamp": "2025-01-20T15:30:00Z",
    "profile": "thorough",
    "duration_seconds": 45.2
  },
  "host": {
    "ip": "192.168.1.10",
    "mac": "aa:bb:cc:dd:ee:10",
    "hostname": "server01.local",
    "os_guess": "Linux 5.x",
    "status": "up"
  },
  "ports": [
    {
      "port": 22,
      "protocol": "tcp",
      "state": "open",
      "service": "ssh",
      "version": "OpenSSH 8.9p1"
    },
    {
      "port": 80,
      "protocol": "tcp",
      "state": "open",
      "service": "http",
      "version": "nginx/1.24.0"
    }
  ],
  "findings": [
    {
      "severity": "medium",
      "port": 6379,
      "title": "Redis without authentication",
      "description": "Redis server accepts connections without password"
    }
  ]
}
```

---

## Structură Proiect

```
M04_Network_Security_Scanner/
├── README.md
├── Makefile
├── src/
│   ├── netscan.sh               # Script principal
│   └── lib/
│       ├── discover.sh          # Descoperire hosturi
│       ├── portscan.sh          # Scanare porturi
│       ├── services.sh          # Identificare servicii
│       ├── checks.sh            # Verificări securitate
│       ├── report.sh            # Generare rapoarte
│       └── utils.sh             # Funcții utilitare
├── etc/
│   ├── ports.conf               # Porturi predefinite per profil
│   ├── services.conf            # Semnături servicii
│   └── profiles/
│       ├── quick.conf
│       ├── normal.conf
│       └── thorough.conf
├── templates/
│   └── report.html              # Template HTML raport
├── tests/
│   ├── test_discover.sh
│   ├── test_portscan.sh
│   └── test_network/            # Mock network pentru teste
├── docs/
│   ├── INSTALL.md
│   ├── PROFILES.md
│   └── LEGAL.md                 # Avertizări legale
└── examples/
    └── sample_reports/
```

---

## Hints Implementare

### Ping sweep paralel

```bash
ping_sweep() {
    local subnet="$1"  # ex: 192.168.1
    local max_parallel="${2:-20}"
    
    for i in {1..254}; do
        echo "$subnet.$i"
    done | xargs -P "$max_parallel" -I {} sh -c '
        ping -c 1 -W 1 {} >/dev/null 2>&1 && echo "{} up"
    '
}

# Sau cu GNU parallel (mai eficient)
ping_sweep_parallel() {
    local subnet="$1"
    seq 1 254 | parallel -j 50 "ping -c 1 -W 1 ${subnet}.{} >/dev/null 2>&1 && echo '${subnet}.{} up'"
}
```

### Port scan TCP connect

```bash
scan_port() {
    local host="$1"
    local port="$2"
    local timeout="${3:-2}"
    
    # Bash built-in (cel mai rapid)
    timeout "$timeout" bash -c "echo >/dev/tcp/$host/$port" 2>/dev/null
    return $?
}

# Scan range de porturi
scan_ports() {
    local host="$1"
    local start_port="$2"
    local end_port="$3"
    
    for port in $(seq "$start_port" "$end_port"); do
        if scan_port "$host" "$port" 1; then
            echo "$port open"
        fi
    done
}

# Paralel cu xargs
scan_ports_parallel() {
    local host="$1"
    local ports="$2"  # ex: "22 80 443 8080"
    
    echo "$ports" | tr ' ' '\n' | xargs -P 20 -I {} bash -c "
        timeout 2 bash -c 'echo >/dev/tcp/$host/{}' 2>/dev/null && echo '{} open'
    "
}
```

### Banner grabbing

```bash
grab_banner() {
    local host="$1"
    local port="$2"
    local timeout="${3:-3}"
    
    # HTTP banner
    if [[ "$port" == "80" || "$port" == "8080" ]]; then
        curl -s -I --max-time "$timeout" "http://$host:$port" 2>/dev/null | head -5
        return
    fi
    
    # Generic banner (trimite newline, citește răspuns)
    echo "" | timeout "$timeout" nc -w "$timeout" "$host" "$port" 2>/dev/null | head -1
}

# SSH version
get_ssh_version() {
    local host="$1"
    timeout 3 nc -w 3 "$host" 22 2>/dev/null | head -1
    # Output: SSH-2.0-OpenSSH_8.9p1 Ubuntu-3ubuntu0.4
}
```

### ARP scan (rețea locală)

```bash
arp_scan() {
    local interface="${1:-eth0}"
    
    # Necesită privilegii root
    if command -v arp-scan &>/dev/null; then
        sudo arp-scan --interface="$interface" --localnet
    else
        # Fallback: citește tabela ARP după ping sweep
        ip neigh show | awk '/REACHABLE|STALE/ {print $1, $5}'
    fi
}
```

### Generare raport HTML

```bash
generate_html_report() {
    local data_file="$1"
    local output="$2"
    
    cat > "$output" << 'HTML_HEADER'
<!DOCTYPE html>
<html>
<head>
    <title>Network Scan Report</title>
    <style>
        body { font-family: 'Segoe UI', sans-serif; margin: 20px; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #4CAF50; color: white; }
        .open { color: green; font-weight: bold; }
        .finding-high { background-color: #ffcccc; }
        .finding-medium { background-color: #fff3cd; }
    </style>
</head>
<body>
HTML_HEADER

    # Procesează data_file și generează conținut
    # ...
    
    echo "</body></html>" >> "$output"
}
```

---

## Criterii Evaluare Specifice

| Criteriu | Pondere | Descriere |
|----------|---------|-----------|
| Descoperire hosturi | 15% | Ping sweep, ARP scan |
| Port scanning | 20% | TCP, paralel, range/list |
| Identificare servicii | 15% | Banner grabbing, versiuni |
| Raportare | 15% | Text + JSON + HTML |
| Profile și configurare | 10% | Quick/thorough, exclude lists |
| Funcționalități extra | 10% | SSL check, vuln check, diff |
| Calitate cod + teste | 10% | Modular, ShellCheck, teste |
| Documentație | 5% | README, LEGAL warnings |

---

## ⚠️ Avertizări Legale

**IMPORTANT:** Scanarea rețelelor fără autorizare este ilegală în majoritatea jurisdicțiilor.

- Folosește acest tool DOAR pe rețele pe care le deții sau ai autorizare explicită
- Pentru teste, folosește rețeaua locală sau mașini virtuale proprii
- Documentează întotdeauna autorizarea înainte de un scan de producție

---

## Resurse

- `man nmap` - Referință pentru tehnici de scanare
- `man nc` (netcat) - Swiss army knife pentru rețea
- `man ss` - Socket statistics
- RFC 793 (TCP), RFC 791 (IP) - Protocoale de bază

---

*Proiect MEDIUM | Sisteme de Operare | ASE-CSIE*
