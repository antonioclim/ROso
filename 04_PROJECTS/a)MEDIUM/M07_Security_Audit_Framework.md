# M07: Framework Audit Securitate

> **Nivel:** MEDIUM | **Timp estimat:** 25-35 ore | **Bonus K8s:** +10%

---

## Descriere

Framework modular pentru auditare securitate Linux: verificare permisiuni fișiere, configurații nesigure, audit utilizatori, hardening SSH, reguli firewall și conformitate CIS Benchmarks. Generează rapoarte cu nivele severitate și remedieri sugerate.

---

## Obiective de Învățare

- Concepte securitate Linux (permisiuni, capabilități, SELinux/AppArmor)
- Auditare utilizatori și grupuri
- Verificare configurație servicii critice
- Automatizare verificări conformitate
- Raportare cu remedieri acționabile

---

## Cerințe Funcționale

### Obligatorii (pentru nota de trecere)

1. **Audit utilizatori și autentificare**
   - Conturi fără parolă sau cu parolă expirată
   - Conturi cu UID 0 (altele decât root)
   - Shell-uri suspicioase, directoare home
   - Ultimele login-uri și încercări eșuate

2. **Audit permisiuni fișiere**
   - Fișiere world-writable
   - Binare SUID/SGID (comparație cu baseline)
   - Permisiuni pe fișiere critice (/etc/passwd, /etc/shadow)
   - Fișiere fără proprietar valid

3. **Audit configurație servicii**
   - SSH: PermitRootLogin, PasswordAuthentication, keys
   - Sudo: configurații riscante (NOPASSWD)
   - Cron: job-uri suspicioase

4. **Audit rețea**
   - Porturi deschise și servicii asociate
   - Reguli firewall (iptables/nftables/ufw)
   - Servicii care ascultă pe 0.0.0.0

5. **Raportare**
   - Severitate: CRITICAL, HIGH, MEDIUM, LOW, INFO
   - Remedieri sugerate pentru fiecare descoperire
   - Export: text, JSON, HTML

### Opționale (pentru punctaj complet)

6. **Verificări CIS Benchmark** - Subset verificări CIS Level 1
7. **Comparație baseline** - Diff față de stare cunoscută bună
8. **Auto-remediere** - Remediare automată pentru probleme simple
9. **Audituri programate** - Integrare cron cu alertare
10. **Verificare CVE** - Verificare pachete pentru vulnerabilități cunoscute

---

## Interfață CLI

```bash
./security_audit.sh <command> [options]

Commands:
  full                  Full audit (all modules)
  users                 User audit only
  files                 File permissions audit only
  services              Service audit only
  network               Network audit only
  cis [level]          CIS Benchmark checks (level 1 or 2)
  baseline create       Create baseline from current state
  baseline compare      Compare with saved baseline
  fix [finding-id]      Apply remediation (with confirmation)

Options:
  -o, --output FILE     Save report to file
  -f, --format FMT      Format: text|json|html|csv
  -s, --severity SEV    Minimum severity: critical|high|medium|low|info
  -q, --quiet           Findings only, no details
  -v, --verbose         Additional details
  --no-color            No colours
  --auto-fix            Apply automatic remediations (DANGEROUS)
  --exclude MODULE      Exclude module from audit

Examples:
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
║                    RAPORT AUDIT SECURITATE                                   ║
║                    Host: server01.example.com                               ║
║                    Dată: 2025-01-20 16:00:00                                ║
╚══════════════════════════════════════════════════════════════════════════════╝

REZUMAT AUDIT
═══════════════════════════════════════════════════════════════════════════════
  🔴 CRITICAL:  2
  🟠 HIGH:      5
  🟡 MEDIUM:    8
  🔵 LOW:       12
  ⚪ INFO:      15
  ─────────────────
  Total descoperiri: 42
  Scor: 68/100 (NECESITĂ ÎMBUNĂTĂȚIRI)

═══════════════════════════════════════════════════════════════════════════════
🔴 DESCOPERIRI CRITICE
═══════════════════════════════════════════════════════════════════════════════

[CRIT-001] Login root via SSH este permis
───────────────────────────────────────────────────────────────────────────────
  Locație:    /etc/ssh/sshd_config
  Curent:     PermitRootLogin yes
  Risc:       Acces direct root mărește suprafața de atac
  
  REMEDIERE:
  1. Editează /etc/ssh/sshd_config
  2. Setează: PermitRootLogin no
  3. Asigură-te că ai alt utilizator admin cu sudo
  4. Rulează: systemctl restart sshd
  
  AUTO-FIX: ./security_audit.sh fix CRIT-001

[CRIT-002] Utilizatorul 'backup' are parolă goală
───────────────────────────────────────────────────────────────────────────────
  Locație:    /etc/shadow
  Risc:       Contul poate fi accesat fără autentificare
  
  REMEDIERE:
  1. Setează parolă: passwd backup
  2. Sau blochează contul: usermod -L backup
  3. Sau elimină dacă nefolosit: userdel backup

═══════════════════════════════════════════════════════════════════════════════
🟠 DESCOPERIRI HIGH
═══════════════════════════════════════════════════════════════════════════════

[HIGH-001] Director world-writable în PATH: /usr/local/bin
───────────────────────────────────────────────────────────────────────────────
  Permisiuni: drwxrwxrwx
  Risc:       Orice utilizator poate plasa executabile malițioase
  
  REMEDIERE:
  chmod 755 /usr/local/bin

[HIGH-002] Binar SUID nu este în baseline: /opt/app/helper
───────────────────────────────────────────────────────────────────────────────
  Permisiuni: -rwsr-xr-x
  Proprietar: root
  Risc:       Binar SUID necunoscut poate fi exploatat
  
  REMEDIERE:
  1. Verifică dacă binarul este legitim
  2. Dacă nu este necesar: chmod u-s /opt/app/helper
  3. Dacă este legitim: adaugă la baseline

[HIGH-003] Autentificare SSH cu parolă activată
───────────────────────────────────────────────────────────────────────────────
  Locație:     /etc/ssh/sshd_config
  Curent:      PasswordAuthentication yes
  Risc:        Vulnerabil la atacuri brute-force
  
  REMEDIERE:
  1. Asigură-te că cheile SSH sunt configurate pentru toți utilizatorii
  2. Setează: PasswordAuthentication no
  3. Restart: systemctl restart sshd

··· [continuare] ···

═══════════════════════════════════════════════════════════════════════════════
📊 REZULTATE DETALIATE PE MODULE
═══════════════════════════════════════════════════════════════════════════════

AUDIT UTILIZATORI
──────────────────────────────────────────────────────────────────────────────
✓ Nu s-au găsit UID-uri duplicate
✓ Root este singurul cont UID 0  
✗ 1 cont cu parolă goală: backup
✗ 3 conturi cu parole expirate: dev1, dev2, contractor
✓ Nu există conturi cu shell-uri suspicioase
⚠ 5 conturi nu s-au autentificat de 90+ zile

AUDIT PERMISIUNI FIȘIERE
──────────────────────────────────────────────────────────────────────────────
✗ 3 fișiere world-writable găsite
✗ 2 binare SUID nu sunt în baseline
✓ Permisiuni /etc/passwd OK (644)
✓ Permisiuni /etc/shadow OK (640)
✗ 12 fișiere fără proprietar valid

AUDIT SERVICII
──────────────────────────────────────────────────────────────────────────────
Configurare SSH:
  ✗ PermitRootLogin: yes (ar trebui no)
  ✗ PasswordAuthentication: yes (ar trebui no)
  ✓ Protocol: 2
  ✓ X11Forwarding: no
  ⚠ MaxAuthTries: 6 (se recomandă 3)

Configurare Sudo:
  ⚠ NOPASSWD găsit pentru utilizatorul 'deploy'
  ✓ Nu există wildcard-uri periculoase în sudoers

AUDIT REȚEA
──────────────────────────────────────────────────────────────────────────────
Porturi Deschise:
  22/tcp   sshd         ✓ Așteptat
  80/tcp   nginx        ✓ Așteptat
  443/tcp  nginx        ✓ Așteptat
  3306/tcp mysql        ⚠ Ascultă pe 0.0.0.0 (ar trebui 127.0.0.1)
  6379/tcp redis        ✗ Fără autentificare, expus la rețea

Firewall:
  ✓ UFW activ
  ⚠ Regulă permite tot de la 10.0.0.0/8 (verifică dacă e intenționat)

═══════════════════════════════════════════════════════════════════════════════
Raport generat în 12.3 secunde
Raport complet salvat în: security_audit_20250120.html
```

---

## Structură Proiect

```
M07_Security_Audit_Framework/
├── README.md
├── Makefile
├── src/
│   ├── security_audit.sh        # Main script
│   └── modules/
│       ├── users.sh             # User audit
│       ├── files.sh             # Permissions audit
│       ├── services.sh          # Service audit
│       ├── network.sh           # Network audit
│       ├── cis.sh               # CIS Benchmark checks
│       └── remediate.sh         # Auto-remediation
├── lib/
│   ├── report.sh                # Report generation
│   ├── baseline.sh              # Baseline management
│   └── utils.sh                 # Common functions
├── etc/
│   ├── audit.conf               # Audit configuration
│   ├── baseline/
│   │   └── suid_baseline.txt    # Known SUID binaries
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

## Indicii de Implementare

### Audit utilizatori

```bash
check_empty_passwords() {
    echo "Checking for empty passwords···"
    
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
    echo "Checking for UID 0 accounts···"
    
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
    echo "Checking for world-writable files···"
    
    find / -xdev -type f -perm -0002 2>/dev/null | while read -r file; do
        report_finding "HIGH" "FILE-001" "World-writable file: $file"
    done
}

check_suid_sgid() {
    local baseline="$BASELINE_DIR/suid_baseline.txt"
    
    echo "Checking SUID/SGID binaries···"
    
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

### Funcție raportare

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

## Criterii Specifice de Evaluare

| Criteriu | Pondere | Descriere |
|-----------|--------|-------------|
| Audit utilizatori | 15% | Parole goale, UID 0, expirare |
| Audit fișiere | 20% | World-writable, SUID, fișiere critice |
| Audit servicii | 20% | SSH, sudo, cron |
| Audit rețea | 15% | Porturi, firewall |
| Raportare | 10% | Severitate, remedieri, export |
| Baseline/CIS | 10% | Comparație, conformitate |
| Calitate cod + teste | 5% | Modular, teste |
| Documentație | 5% | README, doc verificări |

---

## Resurse

- CIS Benchmarks for Linux (PDF gratuit)
- `man sudoers`, `man sshd_config`
- Ghiduri Linux Security Hardening
- Seminar 3 - Permisiuni și administrare

---

*Proiect MEDIUM | Sisteme de Operare | ASE-CSIE*
