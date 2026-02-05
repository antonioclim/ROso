# Proiectul Deployer - Implementare Detaliată

## Cuprins

1. [Prezentare Generală](#1-prezentare-generală)
2. [Arhitectura Sistemului](#2-arhitectura-sistemului)
3. [Strategii de Deployment](#3-strategii-de-deployment)
4. [Modulul Core - deployer_core.sh](#4-modulul-core---deployer_coresh)
5. [Sistemul de Health Checks](#5-sistemul-de-health-checks)
6. [Sistemul de Hooks](#6-sistemul-de-hooks)
7. [Rollback și Recovery](#7-rollback-și-recovery)
8. [Manifest-based Deployment](#8-manifest-based-deployment)
9. [Exerciții de Implementare](#9-exerciții-de-implementare)

---

## 1. Prezentare Generală

### 1.1 Scopul Proiectului

Proiectul **Deployer** implementează un sistem automatizat de deployment pentru aplicații, oferind:

- **Strategii Multiple**: rolling, blue-green, canary deployment
- **Health Checks**: verificare stare aplicație (HTTP, TCP, process, command)
- **Rollback Automat**: revenire la versiunea anterioară în caz de eșec
- **Sistemul de Hooks**: pre_deploy, post_deploy, on_rollback, on_failure
- **Manifest Deployment**: deployment bazat pe fișiere YAML
- **Service Management**: integrare cu systemd, Docker

### 1.2 Structura Fișierelor

```
projects/deployer/
├── deployer.sh              # Script principal (~1000 linii)
├── lib/
│   ├── deployer_core.sh     # Funcții deployment (~800 linii)
│   ├── deployer_utils.sh    # Utilități comune (~400 linii)
│   └── deployer_config.sh   # Gestiune configurare (~300 linii)
└── config/
    └── deployer.conf        # Configurare default
```

### 1.3 Concepte Fundamentale

**Deployment** = Procesul de instalare și configurare a unei noi versiuni de aplicație

**Release** = O versiune specifică a aplicației pregătită pentru deployment

**Rollback** = Revenirea la o versiune anterioară funcțională

**Health Check** = Verificare că aplicația funcționează corect

---

## 2. Arhitectura Sistemului

### 2.1 Diagrama Componentelor

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        deployer.sh (Principal)                          │
├─────────────────────────────────────────────────────────────────────────┤
│  main() ─┬─ parse_arguments()                                           │
│          ├─ load_config()                                               │
│          ├─ validate_manifest()                                         │
│          └─ execute_deployment()                                        │
│                    │                                                     │
│         ┌─────────┴───────────┬────────────────┬──────────────┐        │
│         ▼                     ▼                ▼              ▼        │
│   deploy_rolling()    deploy_blue_green()  deploy_canary()  rollback() │
└─────────────────────────────────────────────────────────────────────────┘
                │                    │              │
                ▼                    ▼              ▼
┌──────────────────────────────────────────────────────────────────────────┐
│                         deployer_core.sh                                  │
├──────────────────────────────────────────────────────────────────────────┤
│  prepare_release()      activate_release()      health_check()           │
│  upload_files()         switch_symlink()        check_http()             │
│  run_hooks()            restart_service()       check_tcp()              │
│  create_rollback_point()  cleanup_old_releases()  check_process()        │
└──────────────────────────────────────────────────────────────────────────┘
                │                    │              │
                ▼                    ▼              ▼
┌──────────────────────────────────────────────────────────────────────────┐
│                         deployer_utils.sh                                 │
├──────────────────────────────────────────────────────────────────────────┤
│  log_message()          format_timestamp()       send_notification()     │
│  log_deployment()       generate_release_id()    parse_yaml()            │
│  create_lockfile()      archive_release()        validate_url()          │
└──────────────────────────────────────────────────────────────────────────┘
```

### 2.2 Structura Directorului de Deployment

```
/var/www/myapp/                     # Application root
├── releases/                       # Toate versiunile
│   ├── 20240115_143022/           # Release 1
│   │   ├── app/
│   │   ├── config/
│   │   └── .release_meta
│   ├── 20240116_093045/           # Release 2
│   └── 20240117_110530/           # Release 3 (current)
├── shared/                         # Fișiere partajate între release-uri
│   ├── config/                    # Configurări permanente
│   ├── uploads/                   # Fișiere uploadate de utilizatori
│   └── logs/                      # Log-uri aplicație
├── current -> releases/20240117_110530/  # Symlink către versiunea activă
└── .deploy_state/                  # Stare deployment
    ├── last_deploy.json           # Info ultimul deployment
    ├── rollback_point             # Versiune pentru rollback
    └── deploy.lock                # Lock pentru concurență
```

### 2.3 Ciclul de Viață al unui Deployment

```
┌────────────────────────────────────────────────────────────────────────┐
│                     DEPLOYMENT LIFECYCLE                                │
│                                                                        │
│   ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐            │
│   │ PREPARE │───▶│ UPLOAD  │───▶│  BUILD  │───▶│ VERIFY  │            │
│   └─────────┘    └─────────┘    └─────────┘    └─────────┘            │
│        │                                              │                │
│        │         ┌────────────────────────────────────┘                │
│        │         │                                                     │
│        │         ▼                                                     │
│        │    ┌─────────┐    ┌─────────┐    ┌─────────┐                 │
│        │    │ ACTIVATE│───▶│ HEALTH  │───▶│ CLEANUP │                 │
│        │    └─────────┘    │  CHECK  │    └─────────┘                 │
│        │         │         └─────────┘         │                       │
│        │         │              │              │                       │
│        │         │         FAIL │              │                       │
│        │         │              ▼              │                       │
│        │         │        ┌─────────┐          │                       │
│        │         │        │ROLLBACK │          │                       │
│        │         │        └─────────┘          │                       │
│        │         │              │              │                       │
│        └─────────┴──────────────┴──────────────┘                       │
│                           │                                            │
│                           ▼                                            │
│                     ┌─────────┐                                        │
│                     │ COMPLETE│                                        │
│                     └─────────┘                                        │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Strategii de Deployment

### 3.1 Rolling Deployment

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     ROLLING DEPLOYMENT                                   │
│                                                                          │
│   Stare Inițială:                                                       │
│   [Instance 1: v1.0] [Instance 2: v1.0] [Instance 3: v1.0]             │
│   ─────────────────────────────────────────────────────────             │
│   100% v1.0                                                             │
│                                                                          │
│   Pas 1: Actualizare Instance 1                                         │
│   [Instance 1: v2.0] [Instance 2: v1.0] [Instance 3: v1.0]             │
│   ─────────────────────────────────────────────────────────             │
│   33% v2.0, 67% v1.0                                                    │
│                                                                          │
│   Pas 2: Actualizare Instance 2                                         │
│   [Instance 1: v2.0] [Instance 2: v2.0] [Instance 3: v1.0]             │
│   ─────────────────────────────────────────────────────────             │
│   67% v2.0, 33% v1.0                                                    │
│                                                                          │
│   Pas 3: Actualizare Instance 3                                         │
│   [Instance 1: v2.0] [Instance 2: v2.0] [Instance 3: v2.0]             │
│   ─────────────────────────────────────────────────────────             │
│   100% v2.0                                                             │
│                                                                          │
│   Avantaje:              Dezavantaje:                                   │
│   + Zero downtime        - Versiuni mixte temporar                      │
│   + Rollback gradual     - Complexitate mai mare                        │
│   + Testare în producție - Necesită compatibilitate backward            │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### 3.2 Blue-Green Deployment

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    BLUE-GREEN DEPLOYMENT                                 │
│                                                                          │
│   Stare Inițială:                                                       │
│                                                                          │
│   ┌─────────────────┐         ┌─────────────────┐                       │
│   │   BLUE (v1.0)   │◀═══════▶│  Load Balancer  │◀═══▶ Users           │
│   │     ACTIVE      │         └─────────────────┘                       │
│   └─────────────────┘                 ╳                                 │
│                                       ║                                 │
│   ┌─────────────────┐                 ║                                 │
│   │  GREEN (idle)   │─ ─ ─ ─ ─ ─ ─ ─ ─                                  │
│   │    STANDBY      │                                                   │
│   └─────────────────┘                                                   │
│                                                                          │
│   După Deploy:                                                          │
│                                                                          │
│   ┌─────────────────┐                 ╳                                 │
│   │   BLUE (v1.0)   │─ ─ ─ ─ ─ ─ ─ ─ ─                                  │
│   │    STANDBY      │                                                   │
│   └─────────────────┘                 ║                                 │
│                                       ║                                 │
│   ┌─────────────────┐         ┌─────────────────┐                       │
│   │  GREEN (v2.0)   │◀═══════▶│  Load Balancer  │◀═══▶ Users           │
│   │     ACTIVE      │         └─────────────────┘                       │
│   └─────────────────┘                                                   │
│                                                                          │
│   Avantaje:              Dezavantaje:                                   │
│   + Rollback instant     - Dublare resurse                              │
│   + Zero downtime        - Cost mai mare                                │
│   + Testare înainte      - Sincronizare DB complexă                     │
│     de switch                                                           │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### 3.3 Canary Deployment

```
┌─────────────────────────────────────────────────────────────────────────┐
│                      CANARY DEPLOYMENT                                   │
│                                                                          │
│   Stare Inițială: 100% trafic → v1.0                                    │
│                                                                          │
│   ┌─────────────────────────────────────────────────────┐               │
│   │                 Producție (v1.0)                    │               │
│   │  █████████████████████████████████████████████████  │ 100%         │
│   └─────────────────────────────────────────────────────┘               │
│                                                                          │
│   Pas 1: Deploy canary (5% trafic)                                      │
│                                                                          │
│   ┌─────────────────────────────────────────────────────┐               │
│   │            Producție (v1.0)                         │               │
│   │  ███████████████████████████████████████████████    │ 95%          │
│   └─────────────────────────────────────────────────────┘               │
│   ┌────┐                                                                │
│   │v2.0│ Canary                                           5%            │
│   └────┘                                                                │
│                                                                          │
│   Pas 2: Monitorizare metrici (erori, latență, etc.)                    │
│   ┌──────────────────────────────────────────────────────────────┐      │
│   │  Erori: ✓ OK    Latență: ✓ OK    CPU: ✓ OK    Memory: ✓ OK  │      │
│   └──────────────────────────────────────────────────────────────┘      │
│                                                                          │
│   Pas 3: Creștere graduală (25% → 50% → 100%)                           │
│                                                                          │
│   ┌──────────────────────────────────────────┐                          │
│   │         Producție (v1.0)                 │ 50%                      │
│   └──────────────────────────────────────────┘                          │
│   ┌──────────────────────────────────────────┐                          │
│   │         Canary (v2.0)                    │ 50%                      │
│   └──────────────────────────────────────────┘                          │
│                                                                          │
│   Pas 4: Finalizare (100% v2.0)                                         │
│                                                                          │
│   ┌─────────────────────────────────────────────────────┐               │
│   │                 Producție (v2.0)                    │               │
│   │  █████████████████████████████████████████████████  │ 100%         │
│   └─────────────────────────────────────────────────────┘               │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 4. Modulul Core - deployer_core.sh

### 4.1 Funcția prepare_release()

```bash
prepare_release() {
    local source_path="$1"
    local app_root="$2"
    
    # Generăm ID unic pentru release
    local release_id
    release_id=$(generate_release_id)
    
    local release_dir="${app_root}/releases/${release_id}"
    
    log_info "Pregătire release: $release_id"
    
    # Creăm directorul release
    mkdir -p "$release_dir" || {
        log_error "Nu pot crea directorul release: $release_dir"
        return 1
    }
    
    # Copiem sau extragem fișierele
    if [[ -d "$source_path" ]]; then
        # Sursă = director
        log_info "Copiere fișiere din: $source_path"
        rsync -av --progress "$source_path/" "$release_dir/" || {
            log_error "Eroare la copierea fișierelor"
            rm -rf "$release_dir"
            return 1
        }
    elif [[ -f "$source_path" ]]; then
        # Sursă = arhivă
        log_info "Extragere arhivă: $source_path"
        
        case "$source_path" in
            *.tar.gz|*.tgz)
                tar -xzf "$source_path" -C "$release_dir" || return 1
                ;;
            *.tar.bz2)
                tar -xjf "$source_path" -C "$release_dir" || return 1
                ;;
            *.zip)
                unzip -q "$source_path" -d "$release_dir" || return 1
                ;;
            *)
                log_error "Format arhivă necunoscut: $source_path"
                return 1
                ;;
        esac
    else
        log_error "Sursa nu există: $source_path"
        return 1
    fi
    
    # Creăm symlink-uri către directoarele shared
    setup_shared_links "$release_dir" "$app_root"
    
    # Generăm metadata pentru release
    create_release_metadata "$release_dir" "$release_id" "$source_path"
    
    # Setăm permisiuni
    local app_user app_group
    app_user=$(get_config "app_user" "www-data")
    app_group=$(get_config "app_group" "www-data")
    
    chown -R "${app_user}:${app_group}" "$release_dir" 2>/dev/null || \
        log_warning "Nu pot schimba owner pentru release"
    
    echo "$release_id"
    return 0
}

generate_release_id() {
    date '+%Y%m%d_%H%M%S'
}

setup_shared_links() {
    local release_dir="$1"
    local app_root="$2"
    local shared_dir="${app_root}/shared"
    
    # Lista directoarelor și fișierelor shared
    local -a shared_dirs
    IFS=',' read -ra shared_dirs <<< "$(get_config 'shared_dirs' 'logs,uploads,cache')"
    
    local -a shared_files
    IFS=',' read -ra shared_files <<< "$(get_config 'shared_files' '')"
    
    # Creăm symlink-uri pentru directoare shared
    for dir in "${shared_dirs[@]}"; do
        [[ -z "$dir" ]] && continue
        
        local target="${shared_dir}/${dir}"
        local link="${release_dir}/${dir}"
        
        # Creăm directorul shared dacă nu există
        mkdir -p "$target"
        
        # Ștergem directorul din release dacă există
        [[ -d "$link" ]] && rm -rf "$link"
        
        # Creăm symlink
        ln -sf "$target" "$link"
        log_debug "Symlink: $link -> $target"
    done
    
    # Symlink-uri pentru fișiere
    for file in "${shared_files[@]}"; do
        [[ -z "$file" ]] && continue
        
        local target="${shared_dir}/${file}"
        local link="${release_dir}/${file}"
        
        if [[ -f "$target" ]]; then
            mkdir -p "$(dirname "$link")"
            ln -sf "$target" "$link"
        fi
    done
}

create_release_metadata() {
    local release_dir="$1"
    local release_id="$2"
    local source="$3"
    
    local meta_file="${release_dir}/.release_meta"
    
    cat > "$meta_file" <<EOF
{
    "release_id": "$release_id",
    "timestamp": "$(date -Iseconds)",
    "source": "$source",
    "deployed_by": "$(whoami)",
    "hostname": "$(hostname -f 2>/dev/null || hostname)",
    "git_commit": "$(get_git_commit "$source" 2>/dev/null || echo "N/A")",
    "git_branch": "$(get_git_branch "$source" 2>/dev/null || echo "N/A")"
}
EOF
}

get_git_commit() {
    local dir="$1"
    [[ -d "${dir}/.git" ]] && git -C "$dir" rev-parse --short HEAD
}

get_git_branch() {
    local dir="$1"
    [[ -d "${dir}/.git" ]] && git -C "$dir" rev-parse --abbrev-ref HEAD
}
```

### 4.2 Funcția activate_release()

```bash
activate_release() {
    local release_id="$1"
    local app_root="$2"
    
    local release_dir="${app_root}/releases/${release_id}"
    local current_link="${app_root}/current"
    
    # Verificăm că release-ul există
    if [[ ! -d "$release_dir" ]]; then
        log_error "Release-ul nu există: $release_id"
        return 1
    fi
    
    log_info "Activare release: $release_id"
    
    # Salvăm release-ul curent pentru rollback
    if [[ -L "$current_link" ]]; then
        local previous_release
        previous_release=$(readlink -f "$current_link")
        
        echo "$(basename "$previous_release")" > "${app_root}/.deploy_state/rollback_point"
        log_info "Punct rollback salvat: $(basename "$previous_release")"
    fi
    
    # Executăm pre_activate hook
    run_hook "pre_activate" "$release_dir" || {
        log_error "Pre-activate hook a eșuat!"
        return 1
    }
    
    # Facem switch-ul atomic folosind symlink temporar
    local temp_link="${current_link}.new"
    
    # Creăm symlink temporar
    ln -sf "$release_dir" "$temp_link" || {
        log_error "Nu pot crea symlink temporar"
        return 1
    }
    
    # Atomic rename (aceasta e operația critică)
    mv -Tf "$temp_link" "$current_link" || {
        log_error "Nu pot activa release-ul (atomic switch eșuat)"
        rm -f "$temp_link"
        return 1
    }
    
    log_info "Symlink actualizat: current -> $release_id"
    
    # Executăm post_activate hook
    run_hook "post_activate" "$release_dir"
    
    # Reîncărcăm/restartăm serviciul dacă e necesar
    local restart_service
    restart_service=$(get_config "restart_service" "")
    
    if [[ -n "$restart_service" ]]; then
        restart_application_service "$restart_service"
    fi
    
    # Actualizăm starea deployment-ului
    update_deploy_state "$app_root" "$release_id" "deployed"
    
    return 0
}

restart_application_service() {
    local service="$1"
    local method
    method=$(get_config "service_manager" "systemd")
    
    log_info "Restart serviciu: $service (via $method)"
    
    case "$method" in
        systemd)
            systemctl restart "$service" || {
                log_warning "Restart systemd eșuat, încerc reload"
                systemctl reload "$service" || return 1
            }
            ;;
        docker)
            local container
            container=$(get_config "docker_container" "$service")
            docker restart "$container" || return 1
            ;;
        supervisor)
            supervisorctl restart "$service" || return 1
            ;;
        script)
            local restart_script
            restart_script=$(get_config "restart_script" "")
            [[ -x "$restart_script" ]] && "$restart_script" || return 1
            ;;
        signal)
            local pid_file signal
            pid_file=$(get_config "pid_file" "")
            signal=$(get_config "reload_signal" "HUP")
            
            if [[ -f "$pid_file" ]]; then
                kill -"$signal" "$(cat "$pid_file")" || return 1
            fi
            ;;
        *)
            log_warning "Metodă restart necunoscută: $method"
            return 0
            ;;
    esac
    
    log_info "Serviciu restartat cu succes"
    return 0
}
```

### 4.3 Implementare Strategii de Deployment

```bash
deploy_rolling() {
    local source_path="$1"
    local app_root="$2"
    local -a instances=("${@:3}")
    
    local total="${#instances[@]}"
    local batch_size
    batch_size=$(get_config "rolling_batch_size" "1")
    
    log_info "Rolling deployment: $total instanțe, batch size: $batch_size"
    
    local deployed=0
    local failed=0
    
    for ((i=0; i<total; i+=batch_size)); do
        local batch=("${instances[@]:i:batch_size}")
        
        log_info "Procesare batch $((i/batch_size + 1)): ${batch[*]}"
        
        for instance in "${batch[@]}"; do
            log_info "Deploy pe instanța: $instance"
            
            # Deploy pe această instanță
            if deploy_to_instance "$source_path" "$instance"; then
                ((deployed++))
                
                # Health check
                if ! health_check_instance "$instance"; then
                    log_error "Health check eșuat pentru: $instance"
                    
                    # Rollback pe această instanță
                    rollback_instance "$instance"
                    ((failed++))
                    
                    # Verificăm dacă trebuie să oprim
                    local max_failures
                    max_failures=$(get_config "max_rolling_failures" "1")
                    
                    if [[ $failed -ge $max_failures ]]; then
                        log_error "Prea multe eșecuri ($failed), oprire deployment"
                        return 1
                    fi
                fi
            else
                log_error "Deploy eșuat pe: $instance"
                ((failed++))
            fi
        done
        
        # Pauză între batch-uri
        local batch_delay
        batch_delay=$(get_config "rolling_batch_delay" "5")
        
        if [[ $i + $batch_size -lt $total ]]; then
            log_info "Așteptare $batch_delay secunde înainte de următorul batch..."
            sleep "$batch_delay"
        fi
    done
    
    log_info "Rolling deployment complet: $deployed succes, $failed eșecuri"
    
    [[ $failed -eq 0 ]]
}

deploy_blue_green() {
    local source_path="$1"
    local app_root="$2"
    
    local blue_dir="${app_root}/blue"
    local green_dir="${app_root}/green"
    local active_link="${app_root}/active"
    
    # Determinăm care e activ și care e standby
    local active standby
    if [[ -L "$active_link" ]]; then
        active=$(readlink -f "$active_link")
        if [[ "$active" == "$blue_dir" ]]; then
            standby="$green_dir"
        else
            standby="$blue_dir"
        fi
    else
        # Prima instalare
        active=""
        standby="$blue_dir"
    fi
    
    log_info "Blue-Green deployment"
    log_info "  Active: ${active:-none}"
    log_info "  Standby (target): $standby"
    
    # Pregătim noul release în standby
    log_info "Pregătire release în standby environment..."
    
    # Curățăm standby
    rm -rf "${standby:?}/"*
    
    # Copiem noul release
    if [[ -d "$source_path" ]]; then
        rsync -av "$source_path/" "$standby/"
    else
        tar -xzf "$source_path" -C "$standby/"
    fi
    
    # Setup shared links
    setup_shared_links "$standby" "$app_root"
    
    # Executăm hooks și build
    run_hook "pre_deploy" "$standby"
    
    # Health check pe standby (înainte de switch)
    log_info "Verificare health check pe standby..."
    
    local standby_port
    standby_port=$(get_config "standby_port" "8081")
    
    # Pornim temporar aplicația pe standby pentru test
    start_standby_instance "$standby" "$standby_port"
    
    if ! health_check "http://localhost:${standby_port}" "30"; then
        log_error "Health check eșuat pe standby!"
        stop_standby_instance "$standby"
        return 1
    fi
    
    stop_standby_instance "$standby"
    log_info "Health check OK pe standby"
    
    # Switch-ul propriu-zis
    log_info "Efectuare switch blue-green..."
    
    # Atomic symlink switch
    local temp_link="${active_link}.new"
    ln -sf "$standby" "$temp_link"
    mv -Tf "$temp_link" "$active_link"
    
    # Reload load balancer sau reverse proxy
    reload_load_balancer
    
    # Health check post-switch
    if ! health_check "$(get_config 'app_url' 'http://localhost')" "60"; then
        log_error "Health check post-switch eșuat! Rollback..."
        
        # Rollback rapid
        ln -sf "$active" "$temp_link"
        mv -Tf "$temp_link" "$active_link"
        reload_load_balancer
        
        return 1
    fi
    
    run_hook "post_deploy" "$standby"
    
    log_info "Blue-Green deployment complet!"
    log_info "Noul active: $standby"
    
    return 0
}

deploy_canary() {
    local source_path="$1"
    local app_root="$2"
    
    log_info "Canary deployment"
    
    # Configurare canary
    local canary_percent_start canary_percent_end canary_step canary_interval
    canary_percent_start=$(get_config "canary_initial_percent" "5")
    canary_percent_end=$(get_config "canary_final_percent" "100")
    canary_step=$(get_config "canary_step_percent" "10")
    canary_interval=$(get_config "canary_step_interval" "60")
    
    # Pregătim canary release
    local release_id
    release_id=$(prepare_release "$source_path" "$app_root")
    
    if [[ -z "$release_id" ]]; then
        log_error "Pregătire release eșuată"
        return 1
    fi
    
    local release_dir="${app_root}/releases/${release_id}"
    
    # Pornim canary instance
    log_info "Pornire canary instance..."
    start_canary_instance "$release_dir"
    
    # Configurăm trafic inițial
    set_canary_weight "$canary_percent_start"
    
    log_info "Canary deployment început cu ${canary_percent_start}% trafic"
    
    local current_percent=$canary_percent_start
    
    while [[ $current_percent -lt $canary_percent_end ]]; do
        log_info "Canary la ${current_percent}%, monitorizare..."
        
        # Monitorizare pentru canary_interval secunde
        if ! monitor_canary "$canary_interval"; then
            log_error "Anomalii detectate în canary! Rollback..."
            
            set_canary_weight 0
            stop_canary_instance
            cleanup_failed_release "$release_dir"
            
            return 1
        fi
        
        # Creștem procentul
        current_percent=$((current_percent + canary_step))
        if [[ $current_percent -gt $canary_percent_end ]]; then
            current_percent=$canary_percent_end
        fi
        
        log_info "Creștere canary la ${current_percent}%"
        set_canary_weight "$current_percent"
    done
    
    # Finalizare - canary devine producție
    log_info "Canary promovat la producție"
    
    promote_canary_to_production "$release_id" "$app_root"
    
    run_hook "post_deploy" "$release_dir"
    
    log_info "Canary deployment complet!"
    return 0
}

monitor_canary() {
    local duration="${1:-60}"
    local check_interval="${2:-10}"
    local error_threshold
    error_threshold=$(get_config "canary_error_threshold" "5")
    
    local start_time end_time errors=0
    start_time=$(date +%s)
    end_time=$((start_time + duration))
    
    while [[ $(date +%s) -lt $end_time ]]; do
        # Colectăm metrici
        local error_rate latency_p99
        
        error_rate=$(get_canary_error_rate)
        latency_p99=$(get_canary_latency)
        
        log_debug "Canary metrici: errors=${error_rate}%, latency_p99=${latency_p99}ms"
        
        # Verificăm threshold-uri
        if (( $(echo "$error_rate > $error_threshold" | bc -l) )); then
            log_warning "Error rate ridicat: ${error_rate}%"
            ((errors++))
        fi
        
        local latency_threshold
        latency_threshold=$(get_config "canary_latency_threshold" "500")
        
        if [[ $latency_p99 -gt $latency_threshold ]]; then
            log_warning "Latență ridicată: ${latency_p99}ms"
            ((errors++))
        fi
        
        # Dacă avem erori consecutive, abort
        if [[ $errors -ge 3 ]]; then
            log_error "Prea multe erori consecutive în canary"
            return 1
        fi
        
        sleep "$check_interval"
    done
    
    return 0
}
```

---

## 5. Sistemul de Health Checks

### 5.1 Implementare Health Checks

```bash
health_check() {
    local target="$1"
    local timeout="${2:-30}"
    local method="${3:-auto}"
    
    log_info "Health check: $target (timeout: ${timeout}s)"
    
    # Auto-detectăm metoda
    if [[ "$method" == "auto" ]]; then
        case "$target" in
            http://*|https://*)  method="http" ;;
            tcp://*)             method="tcp" ;;
            pid://*)             method="process" ;;
            cmd://*)             method="command" ;;
            *)                   method="http" ;;
        esac
    fi
    
    local start_time elapsed result=1
    start_time=$(date +%s)
    
    while [[ $(($(date +%s) - start_time)) -lt $timeout ]]; do
        case "$method" in
            http)
                check_http "$target" && result=0 && break
                ;;
            tcp)
                check_tcp "$target" && result=0 && break
                ;;
            process)
                check_process "$target" && result=0 && break
                ;;
            command)
                check_command "$target" && result=0 && break
                ;;
        esac
        
        elapsed=$(($(date +%s) - start_time))
        log_debug "Health check încercare eșuată, elapsed: ${elapsed}s"
        
        sleep 2
    done
    
    if [[ $result -eq 0 ]]; then
        log_info "Health check OK (${elapsed}s)"
    else
        log_error "Health check EȘUAT (timeout: ${timeout}s)"
    fi
    
    return $result
}

check_http() {
    local url="$1"
    local expected_code="${2:-200}"
    local timeout="${3:-5}"
    
    # Eliminăm prefixul http:// pentru logging
    local display_url="${url#http://}"
    display_url="${display_url#https://}"
    
    log_debug "HTTP check: $display_url"
    
    local response_code
    response_code=$(curl -s -o /dev/null -w "%{http_code}" \
        --connect-timeout "$timeout" \
        --max-time "$((timeout * 2))" \
        "$url" 2>/dev/null)
    
    log_debug "HTTP response: $response_code (expected: $expected_code)"
    
    # Verificăm codul de răspuns
    if [[ "$response_code" == "$expected_code" ]]; then
        return 0
    fi
    
    # Acceptăm și alte coduri de 
    case "$response_code" in
        200|201|202|204|301|302)
            return 0
            ;;
    esac
    
    return 1
}

check_tcp() {
    local target="$1"
    local timeout="${2:-5}"
    
    # Parsăm target: tcp://host:port sau doar host:port
    target="${target#tcp://}"
    
    local host port
    host="${target%:*}"
    port="${target#*:}"
    
    log_debug "TCP check: $host:$port"
    
    # Folosim nc sau /dev/tcp
    if command -v nc &>/dev/null; then
        nc -z -w "$timeout" "$host" "$port" 2>/dev/null
    else
        # Fallback la /dev/tcp (bash built-in)
        timeout "$timeout" bash -c "echo >/dev/tcp/$host/$port" 2>/dev/null
    fi
}

check_process() {
    local target="$1"
    
    # Parsăm target: pid://1234 sau pid://name:nginx
    target="${target#pid://}"
    
    if [[ "$target" =~ ^[0-9]+$ ]]; then
        # PID numeric
        log_debug "Process check: PID $target"
        kill -0 "$target" 2>/dev/null
    else
        # Nume proces
        local process_name="${target#name:}"
        log_debug "Process check: name=$process_name"
        pgrep -x "$process_name" >/dev/null 2>&1
    fi
}

check_command() {
    local target="$1"
    local timeout="${2:-10}"
    
    # Parsăm target: cmd://command args
    local command="${target#cmd://}"
    
    log_debug "Command check: $command"
    
    timeout "$timeout" bash -c "$command" >/dev/null 2>&1
}

# Health check complex cu retry și logging
advanced_health_check() {
    local -a checks=("$@")
    local all_passed=true
    
    log_info "Executare ${#checks[@]} health check(s)"
    
    for check in "${checks[@]}"; do
        # Format: type:target:timeout
        IFS=':' read -r type target check_timeout <<< "$check"
        
        check_timeout="${check_timeout:-30}"
        
        case "$type" in
            http)
                if check_http "$target" 200 "$check_timeout"; then
                    log_info "  ✓ HTTP $target"
                else
                    log_error "  ✗ HTTP $target"
                    all_passed=false
                fi
                ;;
            tcp)
                if check_tcp "$target" "$check_timeout"; then
                    log_info "  ✓ TCP $target"
                else
                    log_error "  ✗ TCP $target"
                    all_passed=false
                fi
                ;;
            process)
                if check_process "pid://$target"; then
                    log_info "  ✓ Process $target"
                else
                    log_error "  ✗ Process $target"
                    all_passed=false
                fi
                ;;
            command)
                if check_command "cmd://$target" "$check_timeout"; then
                    log_info "  ✓ Command: $target"
                else
                    log_error "  ✗ Command: $target"
                    all_passed=false
                fi
                ;;
        esac
    done
    
    $all_passed
}
```

---

## 6. Sistemul de Hooks

### 6.1 Implementare Hooks

```bash
# Variabilă pentru tracking hooks
declare -A HOOK_RESULTS

run_hook() {
    local hook_name="$1"
    local release_dir="$2"
    shift 2
    local -a hook_args=("$@")
    
    log_debug "Căutare hook: $hook_name"
    
    # Căutăm hook-ul în mai multe locații
    local -a hook_locations=(
        "${release_dir}/deploy/hooks/${hook_name}"
        "${release_dir}/deploy/hooks/${hook_name}.sh"
        "${release_dir}/.deploy/${hook_name}"
        "$(get_config "${hook_name}_hook" "")"
    )
    
    local hook_script=""
    for location in "${hook_locations[@]}"; do
        [[ -z "$location" ]] && continue
        
        if [[ -f "$location" && -x "$location" ]]; then
            hook_script="$location"
            break
        fi
    done
    
    if [[ -z "$hook_script" ]]; then
        log_debug "Hook '$hook_name' nu a fost găsit"
        return 0
    fi
    
    log_info "Executare hook: $hook_name"
    log_debug "  Script: $hook_script"
    
    # Pregătim environment-ul pentru hook
    export DEPLOY_HOOK_NAME="$hook_name"
    export DEPLOY_RELEASE_DIR="$release_dir"
    export DEPLOY_APP_ROOT="$(dirname "$(dirname "$release_dir")")"
    export DEPLOY_TIMESTAMP="$(date -Iseconds)"
    export DEPLOY_RELEASE_ID="$(basename "$release_dir")"
    
    # Executăm hook-ul cu timeout
    local hook_timeout
    hook_timeout=$(get_config "hook_timeout" "300")
    
    local start_time exit_code output
    start_time=$(date +%s)
    
    output=$(timeout "$hook_timeout" "$hook_script" "${hook_args[@]}" 2>&1)
    exit_code=$?
    
    local duration=$(($(date +%s) - start_time))
    
    # Salvăm rezultatul
    HOOK_RESULTS["$hook_name"]="$exit_code"
    
    if [[ $exit_code -eq 0 ]]; then
        log_info "Hook '$hook_name' completat în ${duration}s"
        log_debug "Output: $output"
        return 0
    elif [[ $exit_code -eq 124 ]]; then
        log_error "Hook '$hook_name' timeout după ${hook_timeout}s"
        return 1
    else
        log_error "Hook '$hook_name' eșuat (exit code: $exit_code)"
        log_error "Output: $output"
        return 1
    fi
}

# Hook-uri standard pentru deployment
run_deploy_hooks_sequence() {
    local release_dir="$1"
    local phase="${2:-full}"  # full, pre_only, post_only
    
    local hooks_failed=0
    
    # Pre-deployment hooks
    if [[ "$phase" == "full" || "$phase" == "pre_only" ]]; then
        local -a pre_hooks=(
            "pre_deploy"
            "check_dependencies"
            "pre_build"
        )
        
        for hook in "${pre_hooks[@]}"; do
            if ! run_hook "$hook" "$release_dir"; then
                log_error "Pre-deployment hook eșuat: $hook"
                ((hooks_failed++))
                
                # Abort dacă hook-ul critic eșuează
                if [[ "$hook" == "pre_deploy" ]]; then
                    return 1
                fi
            fi
        done
    fi
    
    # Build hooks
    if [[ "$phase" == "full" ]]; then
        run_hook "build" "$release_dir" || {
            log_error "Build eșuat!"
            return 1
        }
    fi
    
    # Post-deployment hooks
    if [[ "$phase" == "full" || "$phase" == "post_only" ]]; then
        local -a post_hooks=(
            "post_deploy"
            "post_activate"
            "notify"
        )
        
        for hook in "${post_hooks[@]}"; do
            run_hook "$hook" "$release_dir" || {
                log_warning "Post-deployment hook eșuat: $hook"
                ((hooks_failed++))
            }
        done
    fi
    
    [[ $hooks_failed -eq 0 ]]
}
```

### 6.2 Exemple de Hook Scripts

```bash
# hooks/pre_deploy.sh - Verificări înainte de deployment
#!/usr/bin/env bash
set -e

echo "=== Pre-Deploy Hook ==="
echo "Release: $DEPLOY_RELEASE_ID"
echo "Directory: $DEPLOY_RELEASE_DIR"

# Verificăm că avem toate fișierele necesare
required_files=("index.php" "config/app.php" "composer.json")

for file in "${required_files[@]}"; do
    if [[ ! -f "${DEPLOY_RELEASE_DIR}/${file}" ]]; then
        echo "ERROR: Fișier lipsă: $file"
        exit 1
    fi
done

# Verificăm permisiuni
echo "Verificare permisiuni..."
chmod -R 755 "${DEPLOY_RELEASE_DIR}"
chmod -R 777 "${DEPLOY_RELEASE_DIR}/storage" 2>/dev/null || true
chmod -R 777 "${DEPLOY_RELEASE_DIR}/cache" 2>/dev/null || true

echo "Pre-deploy OK"
exit 0
```

```bash
# hooks/build.sh - Build și instalare dependențe
#!/usr/bin/env bash
set -e

cd "$DEPLOY_RELEASE_DIR"

echo "=== Build Hook ==="

# Composer pentru PHP
if [[ -f "composer.json" ]]; then
    echo "Instalare dependențe Composer..."
    composer install --no-dev --optimize-autoloader --no-interaction
fi

# NPM pentru JavaScript
if [[ -f "package.json" ]]; then
    echo "Instalare dependențe NPM..."
    npm ci --production
    
    if [[ -f "webpack.config.js" ]]; then
        echo "Build assets..."
        npm run build
    fi
fi

# Python
if [[ -f "requirements.txt" ]]; then
    echo "Instalare dependențe Python..."
    pip install -r requirements.txt --quiet
fi

echo "Build completat"
exit 0
```

```bash
# hooks/post_deploy.sh - Acțiuni după deployment
#!/usr/bin/env bash
set -e

cd "$DEPLOY_RELEASE_DIR"

echo "=== Post-Deploy Hook ==="

# Migrări bază de date
if [[ -f "artisan" ]]; then
    echo "Executare migrări Laravel..."
    php artisan migrate --force
    php artisan config:cache
    php artisan route:cache
    php artisan view:cache
fi

# Clear cache
if [[ -d "cache" ]]; then
    echo "Curățare cache..."
    rm -rf cache/*
fi

# Notify external services
if [[ -n "$SLACK_WEBHOOK" ]]; then
    curl -s -X POST "$SLACK_WEBHOOK" \
        -H "Content-Type: application/json" \
        -d "{\"text\": \"Deployment complet: $DEPLOY_RELEASE_ID\"}"
fi

echo "Post-deploy completat"
exit 0
```

---

## 7. Rollback și Recovery

### 7.1 Implementare Rollback

```bash
rollback() {
    local app_root="$1"
    local target="${2:-}"  # Release ID specific sau gol pentru ultimul
    
    log_info "Inițiere rollback..."
    
    local current_link="${app_root}/current"
    local state_dir="${app_root}/.deploy_state"
    
    # Determinăm release-ul pentru rollback
    local rollback_release
    
    if [[ -n "$target" ]]; then
        # Target specific
        rollback_release="$target"
        
        if [[ ! -d "${app_root}/releases/${rollback_release}" ]]; then
            log_error "Release-ul pentru rollback nu există: $rollback_release"
            return 1
        fi
    else
        # Folosim punctul de rollback salvat
        if [[ -f "${state_dir}/rollback_point" ]]; then
            rollback_release=$(cat "${state_dir}/rollback_point")
        else
            # Găsim penultimul release
            rollback_release=$(ls -1 "${app_root}/releases" | sort -r | sed -n '2p')
        fi
    fi
    
    if [[ -z "$rollback_release" ]]; then
        log_error "Nu există release pentru rollback!"
        return 1
    fi
    
    local rollback_dir="${app_root}/releases/${rollback_release}"
    
    if [[ ! -d "$rollback_dir" ]]; then
        log_error "Directorul pentru rollback nu există: $rollback_dir"
        return 1
    fi
    
    log_info "Rollback la: $rollback_release"
    
    # Executăm hook pre_rollback
    run_hook "pre_rollback" "$rollback_dir" || {
        log_warning "Pre-rollback hook eșuat, continuăm..."
    }
    
    # Salvăm release-ul curent (pentru un posibil roll-forward)
    local current_release
    if [[ -L "$current_link" ]]; then
        current_release=$(basename "$(readlink -f "$current_link")")
        echo "$current_release" > "${state_dir}/pre_rollback_release"
    fi
    
    # Efectuăm switch-ul
    local temp_link="${current_link}.rollback"
    ln -sf "$rollback_dir" "$temp_link"
    mv -Tf "$temp_link" "$current_link"
    
    log_info "Symlink actualizat pentru rollback"
    
    # Restart serviciu
    local restart_service
    restart_service=$(get_config "restart_service" "")
    
    if [[ -n "$restart_service" ]]; then
        restart_application_service "$restart_service" || {
            log_error "Restart serviciu eșuat după rollback!"
        }
    fi
    
    # Health check post-rollback
    local app_url
    app_url=$(get_config "app_url" "http://localhost")
    
    if ! health_check "$app_url" "60"; then
        log_critical "Health check eșuat după rollback!"
        log_critical "Intervenție manuală necesară!"
        
        run_hook "on_failure" "$rollback_dir"
        
        return 1
    fi
    
    # Executăm hook post_rollback
    run_hook "post_rollback" "$rollback_dir"
    run_hook "on_rollback" "$rollback_dir" "$current_release" "$rollback_release"
    
    # Actualizăm starea
    update_deploy_state "$app_root" "$rollback_release" "rolled_back"
    
    log_info "Rollback complet la: $rollback_release"
    
    return 0
}

# Rollback automat în caz de eșec
auto_rollback_on_failure() {
    local app_root="$1"
    local failed_release="$2"
    
    log_warning "Rollback automat activat pentru: $failed_release"
    
    # Verificăm dacă auto-rollback e activat
    if [[ "$(get_config 'auto_rollback' 'true')" != "true" ]]; then
        log_info "Auto-rollback dezactivat, ignorăm"
        return 0
    fi
    
    # Executăm rollback
    if rollback "$app_root"; then
        log_info "Auto-rollback reușit"
        
        # Notificare
        send_notification "warning" "Auto-rollback executat pentru $failed_release"
        
        return 0
    else
        log_critical "Auto-rollback EȘUAT!"
        
        send_notification "critical" "Auto-rollback eșuat! Intervenție necesară!"
        
        return 1
    fi
}

# Cleanup release eșuat
cleanup_failed_release() {
    local release_dir="$1"
    local keep_for_debug="${2:-false}"
    
    if [[ "$keep_for_debug" == "true" ]]; then
        local failed_dir="${release_dir}.failed"
        mv "$release_dir" "$failed_dir"
        log_info "Release eșuat salvat pentru debug: $failed_dir"
    else
        rm -rf "$release_dir"
        log_info "Release eșuat șters: $release_dir"
    fi
}
```

### 7.2 Cleanup și Maintenance

```bash
cleanup_old_releases() {
    local app_root="$1"
    local keep="${2:-5}"
    
    local releases_dir="${app_root}/releases"
    
    [[ ! -d "$releases_dir" ]] && return 0
    
    log_info "Cleanup: păstrez ultimele $keep release-uri"
    
    # Obținem release-ul curent
    local current_release=""
    if [[ -L "${app_root}/current" ]]; then
        current_release=$(basename "$(readlink -f "${app_root}/current")")
    fi
    
    # Listăm și sortăm release-urile (cele mai vechi primele)
    local -a all_releases
    mapfile -t all_releases < <(ls -1 "$releases_dir" | sort)
    
    local total="${#all_releases[@]}"
    
    if [[ $total -le $keep ]]; then
        log_info "Doar $total release-uri, nimic de șters"
        return 0
    fi
    
    local to_delete=$((total - keep))
    local deleted=0
    
    for release in "${all_releases[@]}"; do
        [[ $deleted -ge $to_delete ]] && break
        
        # Nu ștergem release-ul curent
        if [[ "$release" == "$current_release" ]]; then
            log_debug "Păstrez release-ul curent: $release"
            continue
        fi
        
        # Nu ștergem dacă e marcat ca protejat
        if [[ -f "${releases_dir}/${release}/.protected" ]]; then
            log_debug "Păstrez release-ul protejat: $release"
            continue
        fi
        
        log_info "Șterg release vechi: $release"
        rm -rf "${releases_dir:?}/${release}"
        ((deleted++))
    done
    
    log_info "Cleanup complet: $deleted release-uri șterse"
}

# Verificare și reparare stare
verify_deployment_state() {
    local app_root="$1"
    
    local issues=0
    
    # Verificăm symlink-ul current
    if [[ ! -L "${app_root}/current" ]]; then
        log_error "Symlink 'current' lipsește!"
        ((issues++))
    elif [[ ! -d "$(readlink -f "${app_root}/current")" ]]; then
        log_error "Symlink 'current' pointează către un director inexistent!"
        ((issues++))
    fi
    
    # Verificăm directorul releases
    if [[ ! -d "${app_root}/releases" ]]; then
        log_error "Directorul 'releases' lipsește!"
        ((issues++))
    fi
    
    # Verificăm directorul shared
    if [[ ! -d "${app_root}/shared" ]]; then
        log_warning "Directorul 'shared' lipsește"
        mkdir -p "${app_root}/shared"
    fi
    
    # Verificăm permisiuni
    local app_user
    app_user=$(get_config "app_user" "www-data")
    
    if ! stat -c %U "${app_root}/current" 2>/dev/null | grep -q "$app_user"; then
        log_warning "Permisiuni incorecte pentru directorul current"
    fi
    
    echo "$issues"
}
```

---

## 8. Manifest-based Deployment

### 8.1 Structura Manifest YAML

```yaml
# deploy.yml - Manifest pentru deployment
name: my-application
version: "1.2.3"

# Sursa codului
source:
  type: git
  url: contact_eliminat:org/repo.git
  branch: main
  # sau pentru arhivă:
  # type: archive
  # url: https://releases.example.com/app-1.2.3.tar.gz

# Configurare deployment
deployment:
  strategy: rolling  # rolling, blue-green, canary
  app_root: /var/www/myapp
  keep_releases: 5
  
  # Pentru rolling
  rolling:
    batch_size: 1
    batch_delay: 10
    
  # Pentru canary
  canary:
    initial_percent: 5
    step_percent: 10
    step_interval: 60

# Health checks
health_checks:

- `type: http`
- `type: tcp`
- `type: command`


# Hooks
hooks:
  pre_deploy:
    - chmod -R 755 $RELEASE_DIR
    - composer install --no-dev
  build:
    - npm ci
    - npm run build
  post_deploy:
    - php artisan migrate --force
    - php artisan config:cache

# Servicii
service:
  manager: systemd
  name: myapp
  reload_command: "systemctl reload nginx"

# Notificări
notifications:
  slack:
    webhook: ${SLACK_WEBHOOK}
    channel: "#deployments"
  email:
    recipients:
      - contact_eliminat

# Environment
environment:
  APP_ENV: production
  LOG_LEVEL: warning
```

### 8.2 Parser și Executor Manifest

```bash
parse_manifest() {
    local manifest_file="$1"
    
    if [[ ! -f "$manifest_file" ]]; then
        log_error "Manifest nu există: $manifest_file"
        return 1
    fi
    
    log_info "Parsare manifest: $manifest_file"
    
    # Verificăm că avem parser YAML
    local yaml_parser=""
    if command -v yq &>/dev/null; then
        yaml_parser="yq"
    elif command -v python3 &>/dev/null; then
        yaml_parser="python"
    else
        log_error "Nu am găsit parser YAML (yq sau python)"
        return 1
    fi
    
    # Extragem configurația în variabile
    case "$yaml_parser" in
        yq)
            MANIFEST_NAME=$(yq -r '.name // "app"' "$manifest_file")
            MANIFEST_VERSION=$(yq -r '.version // "0.0.0"' "$manifest_file")
            MANIFEST_STRATEGY=$(yq -r '.deployment.strategy // "rolling"' "$manifest_file")
            MANIFEST_APP_ROOT=$(yq -r '.deployment.app_root // "/var/www/app"' "$manifest_file")
            MANIFEST_KEEP_RELEASES=$(yq -r '.deployment.keep_releases // 5' "$manifest_file")
            
            # Source
            MANIFEST_SOURCE_TYPE=$(yq -r '.source.type // "git"' "$manifest_file")
            MANIFEST_SOURCE_URL=$(yq -r '.source.url // ""' "$manifest_file")
            MANIFEST_SOURCE_BRANCH=$(yq -r '.source.branch // "main"' "$manifest_file")
            
            # Health checks (array)
            MANIFEST_HEALTH_CHECKS=$(yq -r '.health_checks | length' "$manifest_file")
            ;;
            
        python)
            eval "$(python3 - "$manifest_file" <<'PYTHON'
import sys
import yaml

with open(sys.argv[1]) as f:
    m = yaml.safe_load(f)

print(f"MANIFEST_NAME='{m.get('name', 'app')}'")
print(f"MANIFEST_VERSION='{m.get('version', '0.0.0')}'")
print(f"MANIFEST_STRATEGY='{m.get('deployment', {}).get('strategy', 'rolling')}'")
print(f"MANIFEST_APP_ROOT='{m.get('deployment', {}).get('app_root', '/var/www/app')}'")
print(f"MANIFEST_KEEP_RELEASES={m.get('deployment', {}).get('keep_releases', 5)}")
print(f"MANIFEST_SOURCE_TYPE='{m.get('source', {}).get('type', 'git')}'")
print(f"MANIFEST_SOURCE_URL='{m.get('source', {}).get('url', '')}'")
print(f"MANIFEST_SOURCE_BRANCH='{m.get('source', {}).get('branch', 'main')}'")
PYTHON
            )"
            ;;
    esac
    
    log_info "Manifest parsat:"
    log_info "  Name: $MANIFEST_NAME"
    log_info "  Version: $MANIFEST_VERSION"
    log_info "  Strategy: $MANIFEST_STRATEGY"
    log_info "  App Root: $MANIFEST_APP_ROOT"
    
    return 0
}

execute_manifest_deployment() {
    local manifest_file="$1"
    
    # Parsăm manifest-ul
    parse_manifest "$manifest_file" || return 1
    
    # Obținem sursa
    local source_path
    source_path=$(fetch_source) || return 1
    
    # Executăm deployment-ul bazat pe strategie
    case "$MANIFEST_STRATEGY" in
        rolling)
            deploy_rolling "$source_path" "$MANIFEST_APP_ROOT"
            ;;
        blue-green)
            deploy_blue_green "$source_path" "$MANIFEST_APP_ROOT"
            ;;
        canary)
            deploy_canary "$source_path" "$MANIFEST_APP_ROOT"
            ;;
        *)
            log_error "Strategie necunoscută: $MANIFEST_STRATEGY"
            return 1
            ;;
    esac
    
    local result=$?
    
    # Cleanup sursa temporară
    [[ -d "$source_path" && "$source_path" == /tmp/* ]] && rm -rf "$source_path"
    
    return $result
}

fetch_source() {
    local temp_dir
    temp_dir=$(mktemp -d)
    
    case "$MANIFEST_SOURCE_TYPE" in
        git)
            log_info "Clonare repository Git..."
            git clone --depth 1 --branch "$MANIFEST_SOURCE_BRANCH" \
                "$MANIFEST_SOURCE_URL" "$temp_dir" || {
                log_error "Clonare Git eșuată"
                rm -rf "$temp_dir"
                return 1
            }
            ;;
            
        archive)
            log_info "Descărcare arhivă..."
            local archive_file="${temp_dir}/source.tar.gz"
            
            curl -sL "$MANIFEST_SOURCE_URL" -o "$archive_file" || {
                log_error "Descărcare arhivă eșuată"
                rm -rf "$temp_dir"
                return 1
            }
            
            tar -xzf "$archive_file" -C "$temp_dir"
            rm "$archive_file"
            ;;
            
        local)
            log_info "Copiere din path local..."
            cp -r "$MANIFEST_SOURCE_URL"/* "$temp_dir/"
            ;;
            
        *)
            log_error "Tip sursă necunoscut: $MANIFEST_SOURCE_TYPE"
            rm -rf "$temp_dir"
            return 1
            ;;
    esac
    
    echo "$temp_dir"
}
```

---

## 9. Exerciții de Implementare

### Exercițiul 1: Deployment Docker

```bash
# Implementați deployment pentru containere Docker
deploy_docker_container() {
    local image="$1"
    local container_name="$2"
    local port_mapping="$3"
    
    # TODO: Implementați:
    # 1. Pull imagine nouă
    # 2. Stop container vechi
    # 3. Rename pentru rollback
    # 4. Start container nou
    # 5. Health check
    # 6. Cleanup container vechi dacă OK
    :
}
```

### Exercițiul 2: Multi-Environment

```bash
# Implementați suport pentru multiple environments
deploy_to_environment() {
    local env="$1"  # dev, staging, production
    local source="$2"
    
    # TODO: Implementați:
    # 1. Încărcare config specific pentru environment
    # 2. Validare că sursa e compatibilă
    # 3. Deployment cu setări specifice
    # 4. Notificări diferențiate
    :
}
```

### Exercițiul 3: A/B Testing Deployment

```bash
# Implementați deployment pentru A/B testing
deploy_ab_test() {
    local variant_a="$1"
    local variant_b="$2"
    local traffic_split="$3"  # ex: "50:50"
    
    # TODO: Implementați:
    # 1. Deploy ambele variante
    # 2. Configurare load balancer pentru split
    # 3. Monitorizare metrici per variantă
    # 4. Dashboard pentru comparație
    :
}
```

### Exercițiul 4: GitOps Integration

```bash
# Implementați trigger de deployment din Git webhook
handle_git_webhook() {
    local payload="$1"
    
    # TODO: Implementați:
    # 1. Parsare payload (GitHub/GitLab)
    # 2. Verificare branch/tag
    # 3. Trigger deployment automat
    # 4. Update status în Git
    :
}
```

### Exercițiul 5: Deployment Metrics

```bash
# Implementați colectare și raportare metrici
collect_deployment_metrics() {
    local release_id="$1"
    
    # TODO: Implementați:
    # 1. Durată deployment
    # 2. Număr erori în primele 5 minute
    # 3. Latență medie post-deploy
    # 4. Export către Prometheus/Grafana
    :
}
```

---

## Concluzii

Proiectul Deployer demonstrează implementarea unui sistem complet de deployment automatizat. Punctele cheie:

1. **Strategii Multiple** - suport pentru diferite scenarii de deployment
2. **Siguranță** - health checks și rollback automat
3. **Flexibilitate** - hooks pentru personalizare
4. **Automatizare** - manifest-based deployment
5. **Observabilitate** - logging și metrici

Sistemul poate fi extins pentru:
- Integrare cu Kubernetes
- Pipeline-uri CI/CD complete
- Deployment multi-cloud
- Canary analysis avansat cu ML
- GitOps și Infrastructure as Code
