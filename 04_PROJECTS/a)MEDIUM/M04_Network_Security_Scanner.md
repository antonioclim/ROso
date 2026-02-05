# M04: Scanner Securitate Rețea

> **Nivel:** MEDIUM | **Timp estimat:** 25-35 ore | **Bonus K8s:** +10%

---

## Descriere

Scanner de securitate pentru rețele locale: detectare host-uri active, scanare porturi, identificare servicii, vulnerabilități cunoscute și generare rapoarte. Util pentru auditare periodică a infrastructurii.

---

## Obiective de Învățare

- Concepte rețea: IP, TCP/UDP, ICMP
- Scanare porturi și detectare servicii
- Procesare paralelă în Bash (jobs, xargs)
- Parsare output `nmap` și alte instrumente
- Generare rapoarte structurate (HTML, JSON)

---

## Cerințe Funcționale

### Obligatorii (pentru nota de trecere)

1. **Descoperire host-uri**
   - Ping sweep pe subrețea (ICMP echo)
   - Scanare ARP pentru rețea locală
   - Detectare host-uri fără ICMP (TCP SYN)

2. **Scanare porturi**
   - Scanare porturi comune (top 100/1000)
   - Scanare interval porturi specific
   - TCP connect scan și SYN scan (cu permisiuni)

3. **Identificare servicii**
   - Banner grabbing pentru porturi deschise
   - Detectare versiune servicii
   - OS fingerprinting (de bază)

4. **Raportare**
   - Output text formatat
   - Export JSON pentru procesare
   - Export HTML pentru vizualizare

5. **Configurare și profile**
   - Profile predefinite (quick, normal, thorough)
   - Configurare porturi custom
   - Listă excludere pentru host-uri/porturi

### Opționale (pentru punctaj complet)

6. **Verificare vulnerabilități** - Verificare CVE pentru versiuni detectate
7. **Comparare scanări** - Diff între două scanări (detectare modificări)
8. **Scanare programată** - Integrare cron cu alertare
9. **Rate limiting** - Evitare detectare/blocare
10. **Verificare TLS/SSL** - Verificare certificat și configurație

---

## Interfață CLI

```bash
./netscan.sh <command> [options] <target>

Commands:
  discover              Discover hosts in subnet
  scan                  Port scan on target
  service               Service identification
  full                  Full scan (discover + scan + service)
  compare               Compare two reports
  report                Generate report from saved data

Target:
  192.168.1.0/24        CIDR subnet
  192.168.1.1           Individual host
  192.168.1.1-50        Host range
  hosts.txt             File with host list

Options:
  -p, --ports PORTS     Ports to scan (e.g.: 22,80,443 or 1-1024)
  -P, --profile PROF    Profile: quick|normal|thorough|stealth
  -o, --output FILE     Output file (extension determines format)
  -f, --format FMT      Format: text|json|html|csv
  -t, --timeout SEC     Timeout per port (default: 2)
  -T, --threads N       Number of parallel threads (default: 10)
  -v, --verbose         Detailed output
  --no-ping             Don't check with ping first
  --tcp-only            TCP only, no UDP
  --rate-limit N        Max N packets/second

Examples:
  ./netscan.sh discover 192.168.1.0/24
  ./netscan.sh scan -p 22,80,443 192.168.1.1
  ./netscan.sh full -P thorough -o report.html 10.0.0.0/24
  ./netscan.sh compare scan1.json scan2.json
```

---

## Exemple Output

### Output Discover

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    RAPORT DESCOPERIRE REȚEA                                  ║
║                    Țintă: 192.168.1.0/24                                    ║
║                    Dată: 2025-01-20 15:30:00                                ║
╚══════════════════════════════════════════════════════════════════════════════╝

Scanare 256 host-uri···
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 100%

┌─────────────────────────────────────────────────────────────────────────────┐
│ HOST-URI DESCOPERITE: 12                                                    │
├─────────────────┬───────────────────┬──────────────┬───────────────────────┤
│ Adresă IP       │ Adresă MAC        │ Hostname     │ Timp Răspuns          │
├─────────────────┼───────────────────┼──────────────┼───────────────────────┤
│ 192.168.1.1     │ aa:bb:cc:dd:ee:01 │ router.local │ 1ms                   │
│ 192.168.1.10    │ aa:bb:cc:dd:ee:10 │ server01     │ 2ms                   │
│ 192.168.1.11    │ aa:bb:cc:dd:ee:11 │ server02     │ 1ms                   │
│ 192.168.1.20    │ aa:bb:cc:dd:ee:20 │ desktop-ion  │ 3ms                   │
│ 192.168.1.21    │ aa:bb:cc:dd:ee:21 │ laptop-maria │ 5ms                   │
│ ···             │ ···               │ ···          │ ···                   │
└─────────────────┴───────────────────┴──────────────┴───────────────────────┘

Rezumat:
  Total scanate:    256
  Host-uri up:      12 (4.7%)
  Host-uri down:    244
  Durată scanare:   8.3 secunde
```

### Output Scanare Completă

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    RAPORT SCANARE SECURITATE COMPLETĂ                        ║
║                    Țintă: 192.168.1.10                                      ║
╚══════════════════════════════════════════════════════════════════════════════╝

HOST: 192.168.1.10 (server01.local)
═══════════════════════════════════════════════════════════════════════════════

Detectare OS: Linux 5.x (Ubuntu)
MAC: aa:bb:cc:dd:ee:10 (Dell Inc.)

┌─────────────────────────────────────────────────────────────────────────────┐
│ PORTURI DESCHISE                                                            │
├───────┬──────────┬─────────────────────────────────────────────────────────┤
│ Port  │ Protocol │ Serviciu                                                │
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
│ ⚠️  DESCOPERIRI SECURITATE                                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│ [MEDIUM] Port 6379 (Redis) - Fără autentificare detectată                  │
│ [LOW]    Port 22 (SSH) - Autentificare parolă activată                     │
│ [INFO]   Port 3306 (MySQL) - Accesibil din rețea                           │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│ VERIFICARE TLS/SSL (port 443)                                              │
├─────────────────────────────────────────────────────────────────────────────┤
│ Certificat: CN=server01.example.com                                         │
│ Emitent: Let's Encrypt                                                      │
│ Valid până: 2025-04-20 (90 zile)                                           │
│ Protocoale: TLSv1.2, TLSv1.3 ✓                                             │
│ Cipher suites: Modern (AEAD) ✓                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Output JSON

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
│   ├── netscan.sh               # Main script
│   └── lib/
│       ├── discover.sh          # Host discovery
│       ├── portscan.sh          # Port scanning
│       ├── services.sh          # Service identification
│       ├── checks.sh            # Security checks
│       ├── report.sh            # Report generation
│       └── utils.sh             # Utility functions
├── etc/
│   ├── ports.conf               # Predefined ports per profile
│   ├── services.conf            # Service signatures
│   └── profiles/
│       ├── quick.conf
│       ├── normal.conf
│       └── thorough.conf
├── templates/
│   └── report.html              # HTML report template
├── tests/
│   ├── test_discover.sh
│   ├── test_portscan.sh
│   └── test_network/            # Mock network for tests
├── docs/
│   ├── INSTALL.md
│   ├── PROFILES.md
│   └── LEGAL.md                 # Legal warnings
└── examples/
    └── sample_reports/
```

---

## Indicii de Implementare

### Ping sweep paralel

```bash
ping_sweep() {
    local subnet="$1"  # e.g.: 192.168.1
    local max_parallel="${2:-20}"
    
    for i in {1..254}; do
        echo "$subnet.$i"
    done | xargs -P "$max_parallel" -I {} sh -c '
        ping -c 1 -W 1 {} >/dev/null 2>&1 && echo "{} up"
    '
}

# Or with GNU parallel (more efficient)
ping_sweep_parallel() {
    local subnet="$1"
    seq 1 254 | parallel -j 50 "ping -c 1 -W 1 ${subnet}.{} >/dev/null 2>&1 && echo '${subnet}.{} up'"
}
```

### TCP connect port scan

```bash
scan_port() {
    local host="$1"
    local port="$2"
    local timeout="${3:-2}"
    
    # Bash built-in (fastest)
    timeout "$timeout" bash -c "echo >/dev/tcp/$host/$port" 2>/dev/null
    return $?
}

# Scan port range
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

# Parallel with xargs
scan_ports_parallel() {
    local host="$1"
    local ports="$2"  # e.g.: "22 80 443 8080"
    
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
    
    # Generic banner (send newline, read response)
    echo "" | timeout "$timeout" nc -w "$timeout" "$host" "$port" 2>/dev/null | head -1
}

# SSH version
get_ssh_version() {
    local host="$1"
    timeout 3 nc -w 3 "$host" 22 2>/dev/null | head -1
    # Output: SSH-2.0-OpenSSH_8.9p1 Ubuntu-3ubuntu0.4
}
```

### Scanare ARP (rețea locală)

```bash
arp_scan() {
    local interface="${1:-eth0}"
    
    # Requires root privileges
    if command -v arp-scan &>/dev/null; then
        sudo arp-scan --interface="$interface" --localnet
    else
        # Fallback: read ARP table after ping sweep
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

    # Process data_file and generate content
    # ···
    
    echo "</body></html>" >> "$output"
}
```

---

## Criterii Specifice de Evaluare

| Criteriu | Pondere | Descriere |
|-----------|--------|-------------|
| Descoperire host-uri | 15% | Ping sweep, scanare ARP |
| Scanare porturi | 20% | TCP, paralel, interval/listă |
| Identificare servicii | 15% | Banner grabbing, versiuni |
| Raportare | 15% | Text + JSON + HTML |
| Profile și configurare | 10% | Quick/thorough, liste excludere |
| Funcționalități extra | 10% | Verificare SSL, vuln, diff |
| Calitate cod + teste | 10% | Modular, ShellCheck, teste |
| Documentație | 5% | README, avertismente LEGAL |

---

## ⚠️ Avertismente Legale

**IMPORTANT:** Scanarea rețelelor fără autorizare este ilegală în majoritatea jurisdicțiilor.

- Folosește acest instrument DOAR pe rețele pe care le deții sau pentru care ai autorizare explicită
- Pentru testare, folosește rețeaua locală sau propriile mașini virtuale
- Documentează întotdeauna autorizarea înainte de o scanare de producție

---

## Resurse

- `man nmap` - Referință pentru tehnici de scanare
- `man nc` (netcat) - Cuțitul elvețian pentru rețelistică
- `man ss` - Statistici socket-uri
- RFC 793 (TCP), RFC 791 (IP) - Protocoale de bază

---

*Proiect MEDIUM | Sisteme de Operare | ASE-CSIE*
