# M07: Security Audit Framework

> **Nivel:** MEDIUM | **Timp estimat:** 25-35 ore | **Bonus K8s:** +10%

---

## Descriere

Framework modular pentru audit de securitate Linux: verificare permisiuni fișiere, configurări nesigure, audit utilizatori, SSH hardening, firewall rules și compliance cu CIS Benchmarks. Generează rapoarte cu severitate și remedieri sugerate.

---

## Obiective de Învățare

- Concepte de securitate Linux (permisiuni, capabilități, SELinux/AppArmor)
- Audit utilizatori și grupuri
- Verificare configurări servicii critice
- Automatizare compliance checks
- Raportare cu remedieri actionabile

---

## Cerințe Funcționale

### Obligatorii (pentru notă de trecere)

1. **Audit utilizatori și autentificare**
   - Conturi fără parolă sau cu parolă expirată
   - Conturi cu UID 0 (alții decât root)
   - Shell-uri suspecte, home directories
   - Ultimele login-uri și failed attempts

2. **Audit permisiuni fișiere**
   - Fișiere world-writable
   - SUID/SGID binaries (comparație cu baseline)
   - Permisiuni pe fișiere critice (/etc/passwd, /etc/shadow)
   - Fișiere fără owner valid

3. **Audit configurări servicii**
   - SSH: PermitRootLogin, PasswordAuthentication, keys
   - Sudo: configurări riscante (NOPASSWD)
   - Cron: jobs suspecte

4. **Audit rețea**
   - Porturi deschise și serviciile asociate
   - Firewall rules (iptables/nftables/ufw)
   - Servicii care ascultă pe 0.0.0.0

5. **Raportare**
   - Severitate: CRITICAL, HIGH, MEDIUM, LOW, INFO
   - Remedieri sugerate pentru fiecare finding
   - Export: text, JSON, HTML

### Opționale (pentru punctaj complet)

6. **CIS Benchmark checks** - Subset de verificări CIS Level 1
7. **Baseline comparison** - Diff față de o stare cunoscută bună
8. **Auto-remediation** - Fix automat pentru issues simple
9. **Scheduled audits** - Cron integration cu alertare
10. **CVE checking** - Verificare pachete cu vulnerabilități cunoscute

---

## Interfață CLI

```bash
./security_audit.sh <command> [opțiuni]

Comenzi:
  full                  Audit complet (toate modulele)
  users                 Doar audit utilizatori
  files                 Doar audit permisiuni fișiere
  services              Doar audit servicii
  network               Doar audit rețea
  cis [level]          CIS Benchmark checks (level 1 sau 2)
  baseline create       Creează baseline din starea curentă
  baseline compare      Compară cu baseline-ul salvat
  fix [finding-id]      Aplică remediere (cu confirmare)

Opțiuni:
  -o, --output FILE     Salvează raport în fișier
  -f, --format FMT      Format: text|json|html|csv
  -s, --severity SEV    Minim severitate: critical|high|medium|low|info
  -q, --quiet           Doar finding-uri, fără detalii
  -v, --verbose         Detalii suplimentare
  --no-color            Fără culori
  --auto-fix            Aplică remedieri automate (PERICULOS)
  --exclude MODULE      Exclude modul din audit

Exemple:
  ./security_audit.sh full
  ./security_audit.sh full -o report.html -f html
  ./security_audit.sh users -s high
  ./security_audit.sh cis 1
  ./security_audit.sh baseline create
  ./security_audit.sh fix SUID-001
```

---

## Exemple Output

### Audit Complet

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    SECURITY AUDIT REPORT                                     ║
║                    Host: server01.example.com                               ║
║                    Date: 2025-01-20 16:00:00                                ║
╚══════════════════════════════════════════════════════════════════════════════╝

AUDIT SUMMARY
═══════════════════════════════════════════════════════════════════════════════
  🔴 CRITICAL:  2
  🟠 HIGH:      5
  🟡 MEDIUM:    8
  🔵 LOW:       12
  ⚪ INFO:      15
  ─────────────────
  Total findings: 42
  Score: 68/100 (NEEDS IMPROVEMENT)

═══════════════════════════════════════════════════════════════════════════════
🔴 CRITICAL FINDINGS
═══════════════════════════════════════════════════════════════════════════════

[CRIT-001] Root login via SSH is permitted
───────────────────────────────────────────────────────────────────────────────
  Location:   /etc/ssh/sshd_config
  Current:    PermitRootLogin yes
  Risk:       Direct root access increases attack surface
  
  REMEDIATION:
  1. Edit /etc/ssh/sshd_config
  2. Set: PermitRootLogin no
  3. Ensure you have another admin user with sudo
  4. Run: systemctl restart sshd
  
  AUTO-FIX: ./security_audit.sh fix CRIT-001

[CRIT-002] User 'backup' has empty password
───────────────────────────────────────────────────────────────────────────────
  Location:   /etc/shadow
  Risk:       Account can be accessed without authentication
  
  REMEDIATION:
  1. Set password: passwd backup
  2. Or lock account: usermod -L backup
  3. Or remove if unused: userdel backup

═══════════════════════════════════════════════════════════════════════════════
🟠 HIGH FINDINGS
═══════════════════════════════════════════════════════════════════════════════

[HIGH-001] World-writable directory in PATH: /usr/local/bin
───────────────────────────────────────────────────────────────────────────────
  Permissions: drwxrwxrwx
  Risk:        Any user can place malicious executables
  
  REMEDIATION:
  chmod 755 /usr/local/bin

[HIGH-002] SUID binary not in baseline: /opt/app/helper
───────────────────────────────────────────────────────────────────────────────
  Permissions: -rwsr-xr-x
  Owner:       root
  Risk:        Unknown SUID binary could be exploited
  
  REMEDIATION:
  1. Verify if binary is legitimate
  2. If not needed: chmod u-s /opt/app/helper
  3. If legitimate: add to baseline

[HIGH-003] SSH password authentication enabled
───────────────────────────────────────────────────────────────────────────────
  Location:    /etc/ssh/sshd_config
  Current:     PasswordAuthentication yes
  Risk:        Vulnerable to brute-force attacks
  
  REMEDIATION:
  1. Ensure SSH keys are configured for all users
  2. Set: PasswordAuthentication no
  3. Restart: systemctl restart sshd

... [continuat] ...

═══════════════════════════════════════════════════════════════════════════════
📊 DETAILED RESULTS BY MODULE
═══════════════════════════════════════════════════════════════════════════════

USER AUDIT
──────────────────────────────────────────────────────────────────────────────
✓ No duplicate UIDs found
✓ Root is the only UID 0 account  
✗ 1 account with empty password: backup
✗ 3 accounts with expired passwords: dev1, dev2, contractor
✓ No accounts with suspicious shells
⚠ 5 accounts haven't logged in for 90+ days

FILE PERMISSIONS AUDIT
──────────────────────────────────────────────────────────────────────────────
✗ 3 world-writable files found
✗ 2 SUID binaries not in baseline
✓ /etc/passwd permissions OK (644)
✓ /etc/shadow permissions OK (640)
✗ 12 files without valid owner

SERVICES AUDIT
──────────────────────────────────────────────────────────────────────────────
SSH Configuration:
  ✗ PermitRootLogin: yes (should be no)
  ✗ PasswordAuthentication: yes (should be no)
  ✓ Protocol: 2
  ✓ X11Forwarding: no
  ⚠ MaxAuthTries: 6 (recommend 3)

Sudo Configuration:
  ⚠ NOPASSWD found for user 'deploy'
  ✓ No dangerous wildcards in sudoers

NETWORK AUDIT
──────────────────────────────────────────────────────────────────────────────
Open Ports:
  22/tcp   sshd         ✓ Expected
  80/tcp   nginx        ✓ Expected
  443/tcp  nginx        ✓ Expected
  3306/tcp mysql        ⚠ Listening on 0.0.0.0 (should be 127.0.0.1)
  6379/tcp redis        ✗ No authentication, exposed to network

Firewall:
  ✓ UFW active
  ⚠ Rule allows all from 10.0.0.0/8 (verify if intended)

═══════════════════════════════════════════════════════════════════════════════
Report generated in 12.3 seconds
Full report saved to: security_audit_20250120.html
```

---

## Structură Proiect

```
M07_Security_Audit_Framework/
├── README.md
├── Makefile
├── src/
│   ├── security_audit.sh        # Script principal
│   └── modules/
│       ├── users.sh             # Audit utilizatori
│       ├── files.sh             # Audit permisiuni
│       ├── services.sh          # Audit servicii
│       ├── network.sh           # Audit rețea
│       ├── cis.sh               # CIS Benchmark checks
│       └── remediate.sh         # Auto-remediation
├── lib/
│   ├── report.sh                # Generare rapoarte
│   ├── baseline.sh              # Gestionare baseline
│   └── utils.sh                 # Funcții comune
├── etc/
│   ├── audit.conf               # Configurare audit
│   ├── baseline/
│   │   └── suid_baseline.txt    # SUID binaries cunoscute
│   └── checks/
│       ├── cis_level1.conf
│       └── cis_level2.conf
├── templates/
│   └── report.html.tmpl
├── tests/
│   ├── test_users.sh
│   ├── test_files.sh
│   └── test_environment/
└── docs/
    ├── INSTALL.md
    ├── CHECKS.md
    └── CIS_MAPPING.md
```

---

## Hints Implementare

### Audit utilizatori

```bash
check_empty_passwords() {
    echo "Checking for empty passwords..."
    
    while IFS=: read -r user pass _; do
        if [[ "$pass" == "" || "$pass" == "!" || "$pass" == "*" ]]; then
            continue  # Locked or no password set (OK for system accounts)
        fi
        
        # Check if password field is empty in shadow
        shadow_pass=$(sudo grep "^${user}:" /etc/shadow | cut -d: -f2)
        
        if [[ -z "$shadow_pass" || "$shadow_pass" == "" ]]; then
            report_finding "CRIT" "USER-001" "User '$user' has empty password"
        fi
    done < /etc/passwd
}

check_uid_zero() {
    echo "Checking for UID 0 accounts..."
    
    while IFS=: read -r user _ uid _; do
        if [[ "$uid" == "0" && "$user" != "root" ]]; then
            report_finding "CRIT" "USER-002" "Non-root user '$user' has UID 0"
        fi
    done < /etc/passwd
}

check_password_expiry() {
    local max_days=90
    local today
    today=$(date +%s)
    
    while IFS=: read -r user _ _ _ _ _ expire _; do
        [[ -z "$expire" || "$expire" == "" ]] && continue
        
        local expire_date=$((expire * 86400))
        if ((expire_date < today)); then
            report_finding "HIGH" "USER-003" "User '$user' password expired"
        fi
    done < <(sudo cat /etc/shadow)
}
```

### Audit permisiuni

```bash
check_world_writable() {
    echo "Checking for world-writable files..."
    
    find / -xdev -type f -perm -0002 2>/dev/null | while read -r file; do
        report_finding "HIGH" "FILE-001" "World-writable file: $file"
    done
}

check_suid_sgid() {
    local baseline="$BASELINE_DIR/suid_baseline.txt"
    
    echo "Checking SUID/SGID binaries..."
    
    find / -xdev \( -perm -4000 -o -perm -2000 \) -type f 2>/dev/null | while read -r file; do
        if ! grep -qxF "$file" "$baseline" 2>/dev/null; then
            local perms
            perms=$(stat -c '%a' "$file")
            report_finding "HIGH" "FILE-002" "SUID/SGID binary not in baseline: $file ($perms)"
        fi
    done
}

check_critical_files() {
    declare -A expected_perms=(
        ["/etc/passwd"]="644"
        ["/etc/shadow"]="640"
        ["/etc/group"]="644"
        ["/etc/gshadow"]="640"
        ["/etc/ssh/sshd_config"]="600"
    )
    
    for file in "${!expected_perms[@]}"; do
        local expected="${expected_perms[$file]}"
        local actual
        actual=$(stat -c '%a' "$file" 2>/dev/null)
        
        if [[ "$actual" != "$expected" ]]; then
            report_finding "MEDIUM" "FILE-003" \
                "Incorrect permissions on $file: $actual (expected $expected)"
        fi
    done
}
```

### Audit SSH

```bash
check_ssh_config() {
    local config="/etc/ssh/sshd_config"
    
    [[ ! -f "$config" ]] && return
    
    # PermitRootLogin
    local root_login
    root_login=$(grep -E "^PermitRootLogin" "$config" | awk '{print $2}')
    
    if [[ "$root_login" == "yes" ]]; then
        report_finding "CRIT" "SSH-001" "SSH permits root login" \
            "Set PermitRootLogin no in $config"
    fi
    
    # PasswordAuthentication
    local pass_auth
    pass_auth=$(grep -E "^PasswordAuthentication" "$config" | awk '{print $2}')
    
    if [[ "$pass_auth" != "no" ]]; then
        report_finding "HIGH" "SSH-002" "SSH password authentication enabled" \
            "Set PasswordAuthentication no after configuring key-based auth"
    fi
    
    # Protocol (SSH 1 is insecure)
    if grep -qE "^Protocol.*1" "$config"; then
        report_finding "CRIT" "SSH-003" "SSH Protocol 1 enabled (insecure)"
    fi
}
```

### Funcție de raportare

```bash
declare -a FINDINGS=()

report_finding() {
    local severity="$1"
    local id="$2"
    local message="$3"
    local remediation="${4:-}"
    
    local color
    case "$severity" in
        CRIT)   color="${RED}" ;;
        HIGH)   color="${ORANGE}" ;;
        MEDIUM) color="${YELLOW}" ;;
        LOW)    color="${BLUE}" ;;
        INFO)   color="${WHITE}" ;;
    esac
    
    FINDINGS+=("${severity}|${id}|${message}|${remediation}")
    
    if [[ "$QUIET" != "true" ]]; then
        echo -e "${color}[$severity]${NC} [$id] $message"
    fi
}

generate_report() {
    local format="${1:-text}"
    
    case "$format" in
        json)
            echo "["
            local first=true
            for finding in "${FINDINGS[@]}"; do
                IFS='|' read -r sev id msg rem <<< "$finding"
                $first || echo ","
                first=false
                printf '  {"severity":"%s","id":"%s","message":"%s","remediation":"%s"}' \
                    "$sev" "$id" "$msg" "$rem"
            done
            echo "]"
            ;;
        text)
            for finding in "${FINDINGS[@]}"; do
                IFS='|' read -r sev id msg rem <<< "$finding"
                echo "[$sev] $id: $msg"
                [[ -n "$rem" ]] && echo "  Remediation: $rem"
            done
            ;;
    esac
}
```

---

## Criterii Evaluare Specifice

| Criteriu | Pondere | Descriere |
|----------|---------|-----------|
| Audit utilizatori | 15% | Empty pass, UID 0, expiry |
| Audit fișiere | 20% | World-writable, SUID, critical files |
| Audit servicii | 20% | SSH, sudo, cron |
| Audit rețea | 15% | Ports, firewall |
| Raportare | 10% | Severitate, remedieri, export |
| Baseline/CIS | 10% | Comparație, compliance |
| Calitate cod + teste | 5% | Modular, teste |
| Documentație | 5% | README, checks doc |

---

## Resurse

- CIS Benchmarks for Linux (free PDF)
- `man sudoers`, `man sshd_config`
- Linux Security Hardening guides
- Seminar 3 - Permisiuni și administrare

---

*Proiect MEDIUM | Sisteme de Operare | ASE-CSIE*
