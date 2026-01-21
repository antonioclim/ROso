# S06_01 - Tema CAPSTONE: Proiecte Integrate

> **Sisteme de Operare** | ASE București - CSIE  
> **Seminarele 11-12** | Nivel: CAPSTONE  
> **Timp estimat**: 40-60 ore total  
> **Predare**: Repository GitHub/GitLab + Demonstrație

---

## Cuprins

1. [Tema 1: Monitor - Extindere Funcționalități](#tema-1-monitor)
2. [Tema 2: Backup - Sistem Complet](#tema-2-backup)
3. [Tema 3: Deployer - Pipeline CI/CD](#tema-3-deployer)
4. [Tema 4: Proiect Integrat](#tema-4-proiect-integrat)
5. [Criterii de Evaluare](#criterii-de-evaluare)

---

## Tema 1: Monitor - Extindere Funcționalități {#tema-1-monitor}

### Obiectiv
Extindeți proiectul Monitor cu funcționalități noi pentru monitorizare avansată.

### Cerințe Obligatorii (60%)

#### 1.1 Network Monitoring (20%)
Implementați monitorizarea traficului de rețea.

```bash
# Funcția trebuie să returneze:
# - Bytes received/transmitted per interfață
# - Pachete dropped
# - Erori de rețea

get_network_stats() {
    local interface="${1:-eth0}"
    
    # TODO: Citiți din /proc/net/dev sau /sys/class/net/
    # TODO: Calculați rate (bytes/sec) între două citiri
    # TODO: Returnați în format structurat
}

# Output așteptat:
# interface:eth0
# rx_bytes:1234567890
# tx_bytes:987654321
# rx_packets:12345
# tx_packets:9876
# rx_errors:0
# tx_errors:0
# rx_rate_mbps:45.2
# tx_rate_mbps:12.8
```

**Hints:**
- `/proc/net/dev` conține statistici per interfață
- Pentru rate, faceți două citiri la interval de 1 secundă
- Convertiți bytes în Mbps: `(bytes_diff * 8) / 1000000`

#### 1.2 Service Monitoring (20%)
Implementați monitorizarea serviciilor systemd.

```bash
check_service_status() {
    local service="$1"
    
    # TODO: Verificați dacă serviciul rulează
    # TODO: Obțineți memory/CPU usage al serviciului
    # TODO: Verificați uptime
    
    # Return: running|stopped|failed + metrici
}

monitor_services() {
    local services=("$@")
    
    # TODO: Iterați prin lista de servicii
    # TODO: Generați raport status
}

# Exemplu utilizare:
# monitor_services nginx mysql redis
```

**Hints:**
- `systemctl is-active servicename`
- `systemctl show servicename --property=MainPID,MemoryCurrent`
- Gestionați cazul când serviciul nu există

#### 1.3 Dashboard Terminal (20%)
Creați un dashboard live în terminal folosind ANSI escape codes.

```bash
render_dashboard() {
    # Clear screen și poziționare cursor
    clear
    tput cup 0 0
    
    # TODO: Afișați header cu hostname și timestamp
    # TODO: Secțiune CPU cu bară de progres
    # TODO: Secțiune Memory cu grafic
    # TODO: Secțiune Disk usage
    # TODO: Top 5 procese
    # TODO: Status servicii monitorizate
    
    # Refresh la fiecare 2 secunde
}

# Exemplu bară de progres:
# CPU: [] 62%
```

**Hints:**
- ANSI codes: `\033[32m` pentru verde, `\033[0m` pentru reset
- `printf` pentru formatare precisă
- `tput` pentru manipulare terminal

### Cerințe Opționale (40% bonus)

#### 1.4 Export Prometheus (15%)
Implementați endpoint HTTP pentru metrici în format Prometheus.

```bash
start_prometheus_exporter() {
    local port="${1:-9100}"
    
    # TODO: Server HTTP simplu cu netcat
    # TODO: Endpoint /metrics cu format Prometheus
}

# Format Prometheus:
# # HELP node_cpu_usage CPU usage percentage
# # TYPE node_cpu_usage gauge
# node_cpu_usage{core="0"} 23.5
# node_cpu_usage{core="1"} 45.2
```

#### 1.5 Historical Data & Graphs (15%)
Stocați metrici și generați grafice ASCII.

```bash
# Stocare în SQLite sau CSV
store_metric() {
    local metric="$1"
    local value="$2"
    local timestamp=$(date +%s)
    
    # TODO: Append la history file
}

# Grafic ASCII pentru ultimele N valori
draw_ascii_graph() {
    local metric="$1"
    local points="${2:-60}"  # ultimele 60 minute
    
    # TODO: Citiți date din history
    # TODO: Normalizați la înălțimea terminalului
    # TODO: Desenați grafic
}
```

#### 1.6 Alerting Email/Slack (10%)
Implementați notificări prin email sau Slack.

---

## Tema 2: Backup - Sistem Complet {#tema-2-backup}

### Obiectiv
Extindeți sistemul de backup cu funcționalități enterprise.

### Cerințe Obligatorii (60%)

#### 2.1 Backup Encriptat (20%)
Adăugați suport pentru encriptare GPG.

```bash
create_encrypted_backup() {
    local source="$1"
    local dest="$2"
    local gpg_recipient="$3"
    
    # TODO: Creare arhivă
    # TODO: Encriptare cu GPG
    # TODO: Semnare digitală (opțional)
    # TODO: Verificare integritate post-encriptare
}

restore_encrypted_backup() {
    local archive="$1"
    local dest="$2"
    
    # TODO: Verificare semnătură
    # TODO: Decriptare
    # TODO: Extragere
    # TODO: Verificare integritate fișiere
}
```

**Hints:**
- `gpg --encrypt --recipient user@email.com`
- `gpg --decrypt`
- Testați cu chei GPG generate local

#### 2.2 Backup Remote SSH/SFTP (20%)
Implementați backup pe server remote.

```bash
backup_to_remote() {
    local source="$1"
    local remote_host="$2"
    local remote_path="$3"
    
    # TODO: Verificare conectivitate SSH
    # TODO: Transfer cu rsync sau scp
    # TODO: Verificare transfer complet
    # TODO: Retry la erori de rețea
}

# Varianta rsync (recomandată)
rsync_backup() {
    rsync -avz --progress \
        --exclude-from="$EXCLUDE_FILE" \
        --partial \
        --bwlimit="${BANDWIDTH_LIMIT:-0}" \
        "$source" "${remote_host}:${remote_path}"
}
```

**Hints:**
- Configurați SSH keys pentru autentificare fără parolă
- `rsync --partial` pentru reluare transfer întrerupt
- `--bwlimit` pentru limitare bandwidth (KB/s)

#### 2.3 Rotație Avansată (20%)
Implementați politică de retenție configurabilă.

```bash
# Config: retention.conf
# daily=7
# weekly=4
# monthly=12
# yearly=2

apply_retention_policy() {
    local backup_dir="$1"
    local config_file="$2"
    
    # TODO: Parsare configurație
    # TODO: Identificare backup-uri pentru ștergere
    # TODO: Păstrare backup-uri conform policy
    # TODO: Logging și raportare spațiu eliberat
}

# Trebuie să păstreze:
# - Ultimele 7 daily
# - Câte un backup din fiecare din ultimele 4 săptămâni
# - Câte un backup din fiecare din ultimele 12 luni
# - Câte un backup din ultimii 2 ani
```

### Cerințe Opționale (40% bonus)

#### 2.4 Deduplicare (15%)
Implementați deduplicare la nivel de bloc.

```bash
# Concept: împărțiți fișierele în blocuri, stocați doar blocurile unice
# Folosiți hash (SHA256) pentru identificare blocuri

dedupe_backup() {
    local source="$1"
    local dedupe_store="$2"
    
    # TODO: Split fișiere în blocuri (ex: 1MB)
    # TODO: Hash fiecare bloc
    # TODO: Stocați doar blocurile noi
    # TODO: Creați manifest pentru reconstituire
}
```

#### 2.5 Backup Database (15%)
Adăugați suport pentru backup MySQL/PostgreSQL.

```bash
backup_mysql() {
    local host="$1"
    local database="$2"
    local output="$3"
    
    mysqldump -h "$host" "$database" | gzip > "$output"
    # TODO: Handle credentials secure
    # TODO: Verificare integritate dump
}

backup_postgresql() {
    local database="$1"
    local output="$2"
    
    pg_dump "$database" | gzip > "$output"
}
```

#### 2.6 Raport HTML (10%)
Generați raport HTML cu statistici backup.

---

## Tema 3: Deployer - Pipeline CI/CD {#tema-3-deployer}

### Obiectiv
Construiți un pipeline de deployment complet.

### Cerințe Obligatorii (60%)

#### 3.1 Docker Deployment (20%)
Implementați deployment pentru containere Docker.

```bash
deploy_docker_app() {
    local image="$1"
    local container_name="$2"
    local port="${3:-8080}"
    
    # TODO: Pull image nou
    # TODO: Stop container existent (graceful)
    # TODO: Backup container data (volumes)
    # TODO: Start container nou
    # TODO: Health check
    # TODO: Cleanup imagini vechi
}

docker_rolling_update() {
    local service="$1"
    local image="$2"
    
    # Pentru Docker Swarm sau multiple containere
    # TODO: Implementați rolling update
}
```

**Hints:**
- `docker pull`, `docker stop`, `docker run`
- `--stop-timeout` pentru graceful shutdown
- Health check: `docker inspect --format='{{.State.Health.Status}}'`

#### 3.2 Multi-Environment Pipeline (20%)
Implementați deployment în staging apoi production.

```bash
# environments.conf
# staging_hosts=staging1,staging2
# production_hosts=prod1,prod2,prod3,prod4
# require_approval=true

deploy_pipeline() {
    local app="$1"
    local version="$2"
    
    # 1. Build & Test
    log_info "Building $app v$version..."
    run_build "$app" "$version" || return 1
    run_unit_tests "$app" || return 1
    
    # 2. Deploy to Staging
    log_info "Deploying to STAGING..."
    ENVIRONMENT="staging" deploy_to_environment "$app" "$version"
    
    # 3. Integration Tests
    run_integration_tests "$app" "staging" || {
        rollback_environment "staging" "$app"
        return 1
    }
    
    # 4. Approval Gate
    if [[ "$REQUIRE_APPROVAL" == "true" ]]; then
        request_approval "Deploy $app v$version to production?"
        # Approval poate fi: manual input, webhook, sau ticket system
    fi
    
    # 5. Deploy to Production (canary)
    log_info "Deploying to PRODUCTION..."
    ENVIRONMENT="production" deploy_canary "$app" "$version"
}
```

#### 3.3 Monitoring Integration (20%)
Integrați deployment cu sistemul de monitoring.

```bash
deploy_with_monitoring() {
    local app="$1"
    local version="$2"
    
    # Capture metrici pre-deployment
    local baseline_error_rate=$(get_error_rate "$app")
    local baseline_latency=$(get_latency_p99 "$app")
    
    # Deploy
    deploy_canary "$app" "$version"
    
    # Monitor pentru anomalii
    local observe_minutes=10
    for ((i=0; i<observe_minutes; i++)); do
        sleep 60
        
        local current_error=$(get_error_rate "$app")
        local current_latency=$(get_latency_p99 "$app")
        
        # Check pentru degradare
        if is_degraded "$baseline_error_rate" "$current_error"; then
            log_error "Error rate degraded: $baseline_error_rate → $current_error"
            rollback "$app"
            return 1
        fi
    done
    
    log_info "Deployment healthy after $observe_minutes minutes"
}
```

### Cerințe Opționale (40% bonus)

#### 3.4 GitOps Integration (15%)
Implementați deployment declanșat de Git.

```bash
# Webhook handler pentru Git push
handle_git_webhook() {
    local payload="$1"
    
    # Parse payload (JSON)
    local repo=$(echo "$payload" | jq -r '.repository.name')
    local branch=$(echo "$payload" | jq -r '.ref' | sed 's|refs/heads/||')
    local commit=$(echo "$payload" | jq -r '.after')
    
    # Deploy based on branch
    case "$branch" in
        main|master)
            deploy_pipeline "$repo" "$commit"
            ;;
        staging)
            ENVIRONMENT="staging" deploy_to_environment "$repo" "$commit"
            ;;
        *)
            log_info "Ignoring push to branch: $branch"
            ;;
    esac
}
```

#### 3.5 Kubernetes Deployment (15%)
Adăugați suport pentru deployment Kubernetes.

```bash
deploy_kubernetes() {
    local app="$1"
    local version="$2"
    local namespace="${3:-default}"
    
    # Update image în deployment
    kubectl set image deployment/"$app" \
        "$app"="registry.example.com/$app:$version" \
        -n "$namespace"
    
    # Wait for rollout
    kubectl rollout status deployment/"$app" -n "$namespace" --timeout=300s
}
```

#### 3.6 Secrets Management (10%)
Implementați gestionare securizată a secretelor.

---

## Tema 4: Proiect Integrat {#tema-4-proiect-integrat}

### Obiectiv
Integrați toate cele trei proiecte într-un sistem coerent.

### Cerințe (100%)

#### 4.1 Unified CLI (30%)
Creați o interfață unificată pentru toate proiectele.

```bash
#!/bin/bash
# capstone.sh - Unified CLI

case "$1" in
    monitor)
        shift
        ./monitor/monitor.sh "$@"
        ;;
    backup)
        shift
        ./backup/backup.sh "$@"
        ;;
    deploy)
        shift
        ./deployer/deployer.sh "$@"
        ;;
    status)
        # Afișare status unified
        show_system_status
        ;;
    *)
        show_help
        ;;
esac

show_system_status() {
    echo "=== System Status ==="
    
    echo -e "\n📊 Monitoring:"
    ./monitor/monitor.sh --summary
    
    echo -e "\n💾 Last Backup:"
    ./backup/backup.sh list --last 1
    
    echo -e "\n🚀 Deployments:"
    ./deployer/deployer.sh status --all
}
```

#### 4.2 Automated Workflows (30%)
Implementați workflow-uri automate.

```bash
# Workflow: Backup înainte de deploy
pre_deploy_backup() {
    local app="$1"
    
    log_info "Creating pre-deployment backup..."
    ./backup/backup.sh create \
        --source="/var/www/$app" \
        --type=full \
        --tag="pre-deploy-$(date +%Y%m%d_%H%M%S)"
}

# Workflow: Monitor health după deploy
post_deploy_monitor() {
    local app="$1"
    local duration="${2:-300}"  # 5 minute
    
    log_info "Monitoring deployment health for ${duration}s..."
    ./monitor/monitor.sh --continuous \
        --interval=10 \
        --duration="$duration" \
        --alert \
        --app="$app"
}

# Workflow complet
full_deploy_workflow() {
    local app="$1"
    local version="$2"
    
    pre_deploy_backup "$app" || exit 1
    ./deployer/deployer.sh deploy --app="$app" --version="$version" || {
        log_error "Deploy failed, backup available for restore"
        exit 1
    }
    post_deploy_monitor "$app" || {
        log_warn "Health issues detected, consider rollback"
    }
}
```

#### 4.3 Web Dashboard (20%)
Creați un dashboard web simplu pentru vizualizare status.

```bash
# Server HTTP simplu pentru dashboard
start_dashboard_server() {
    local port="${1:-8080}"
    
    while true; do
        {
            echo "HTTP/1.1 200 OK"
            echo "Content-Type: text/html"
            echo ""
            generate_dashboard_html
        } | nc -l -p "$port" -q 1
    done
}

generate_dashboard_html() {
    local cpu=$(./monitor/monitor.sh --cpu --format=raw)
    local mem=$(./monitor/monitor.sh --memory --format=raw)
    local last_backup=$(./backup/backup.sh list --last 1 --format=json)
    
    cat <<HTML
<!DOCTYPE html>
<html>
<head><title>CAPSTONE Dashboard</title></head>
<body>
    <h1>System Status</h1>
    <div class="metric">
        <h2>CPU</h2>
        <div class="progress" style="width: ${cpu}%"></div>
        <span>${cpu}%</span>
    </div>
    <!-- ... mai mult HTML ... -->
</body>
</html>
HTML
}
```

#### 4.4 Documentation & Tests (20%)
- README complet cu instrucțiuni de instalare și utilizare
- Minimum 10 teste unitare pentru fiecare proiect
- Exemple de utilizare pentru fiecare funcționalitate
- Consultă `man` sau `--help` dacă ai dubii

---

## Criterii de Evaluare {#criterii-de-evaluare}

### Punctaj General

| Criteriu | Pondere | Descriere |
|----------|---------|-----------|
| Funcționalitate | 40% | Codul funcționează conform cerințelor |
| Calitate Cod | 25% | Clean code, modularizare, comentarii |
| Error Handling | 15% | Gestionare erori, edge cases |
| Testing | 10% | Teste unitare și integrare |
| Documentație | 10% | README, help, comentarii |

### Penalizări

| Penalizare | Puncte | Motiv |
|------------|--------|-------|
| Cod neformatat | -5 | Lipsă indentare, inconsistență stil |
| Fără validare input | -10 | Script crash la input invalid |
| Fără error handling | -10 | Erori netratate |
| Fără comentarii | -5 | Cod greu de înțeles |
| Plagiat | -100 | Copiere fără atribuire |

### Bonusuri

| Bonus | Puncte | Condiție |
|-------|--------|----------|
| Extra features | +10 | Funcționalități peste cerințe |
| Excellent docs | +5 | Documentație exemplară |
| CI/CD Pipeline | +10 | GitHub Actions funcțional |
| Tests >80% coverage | +10 | Test coverage ridicat |

---

## Termene

- **Tema 1 (Monitor)**: Săptămâna 12
- **Tema 2 (Backup)**: Săptămâna 13
- **Tema 3 (Deployer)**: Săptămâna 14
- **Tema 4 (Integrat)**: Sesiune

## Predare

1. Repository GitHub/GitLab
2. README cu instrucțiuni
3. Script de instalare funcțional
4. Demonstrație video (2-3 minute) - opțional pentru bonus

---

## Sfaturi

1. **Începeți devreme** - Temele necesită timp pentru testare
2. **Testați incremental** - Nu lăsați testarea pe final
3. **Folosiți Git** - Commit-uri frecvente, mesaje clare
4. **Citiți documentația** - `man bash`, `man rsync`, etc.
5. **Cereți ajutor** - Consultații, forum, colegi

---

