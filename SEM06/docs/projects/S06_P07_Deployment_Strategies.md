# S06_07: Strategii de Deployment în Detaliu

## Introducere

Deployment-ul reprezintă momentul critic în care codul dezvoltat traversează granița dintre mediul de dezvoltare și producție, devenind accesibil utilizatorilor finali. Alegerea strategiei de deployment influențează direct disponibilitatea serviciului, experiența utilizatorilor în timpul actualizării și capacitatea de recovery în caz de probleme.

Acest capitol analizează comparativ principalele strategii de deployment, evidențiind trade-off-urile, scenariile de utilizare optimă și detaliile de implementare în contextul proiectelor CAPSTONE.

---

## Taxonomia Strategiilor de Deployment

### Clasificare după Impact și Risc

```
                        RISC DEPLOYMENT
                              │
         LOW ◄────────────────┼────────────────► HIGH
                              │
    ┌─────────────────────────┼─────────────────────────┐
    │                         │                         │
    │   CANARY               │        ROLLING          │
    │   ────────              │        ──────────       │
    │   • Risc minim         │        • Risc moderat   │
    │   • Feedback rapid     │        • Zero downtime  │
    │   • Rollback instant   │        • Gradual        │
    │                         │                         │
    │─────────────────────────┼─────────────────────────│
    │                         │                         │
    │   BLUE-GREEN           │       BIG BANG          │
    │   ────────────          │       ──────────        │
    │   • Risc controlat     │        • Risc maxim     │
    │   • Switch atomic      │        • Simplu         │
    │   • Resurse duble      │        • Downtime       │
    │                         │                         │
    └─────────────────────────┴─────────────────────────┘
              LOW                        HIGH
                    COMPLEXITATE INFRASTRUCTURĂ
```

---

## Strategia Rolling Deployment

### Concept

Rolling deployment actualizează instanțele aplicației în mod gradual, înlocuind versiunea veche cu cea nouă câte una (sau un batch) la un moment dat. Pe durata deployment-ului, ambele versiuni coexistă în producție.

### Diagrama de Flux

```
Timp ─────────────────────────────────────────────────────►

Instanța 1: [████ V1 ████][░░ Update ░░][████ V2 ████████]
Instanța 2: [████████ V1 ████████][░░ Update ░░][████ V2 ██]
Instanța 3: [████████████ V1 ████████████][░░ Update ░░][V2]
Instanța 4: [████████████████ V1 ████████████████][░░░░░░░░]

Load Balancer: ═══════════════════════════════════════════
              Direcționează trafic doar către instanțe sănătoase
```

### Implementare în Deployer

```bash
#!/bin/bash
#===============================================================================
# rolling_deploy.sh - Implementare Rolling Deployment
#===============================================================================

source "$(dirname "$0")/../lib/deployer_core.sh"
source "$(dirname "$0")/../lib/deployer_utils.sh"

#-------------------------------------------------------------------------------
# Configurare
#-------------------------------------------------------------------------------
declare -g BATCH_SIZE=1
declare -g MAX_UNAVAILABLE=1
declare -g HEALTH_CHECK_RETRIES=3
declare -g HEALTH_CHECK_INTERVAL=10
declare -g DRAIN_TIMEOUT=30

#-------------------------------------------------------------------------------
# Rolling Deployment Core
#-------------------------------------------------------------------------------
deploy_rolling() {
    local release_path="$1"
    local -a instances=("${@:2}")
    
    local total_instances=${#instances[@]}
    local successful=0
    local failed=0
    
    log_info "Starting rolling deployment to $total_instances instances"
    log_info "Batch size: $BATCH_SIZE, Max unavailable: $MAX_UNAVAILABLE"
    
    # Procesare în batch-uri
    local batch_num=0
    for ((i=0; i<total_instances; i+=BATCH_SIZE)); do
        ((batch_num++))
        local batch_end=$((i + BATCH_SIZE - 1))
        [[ $batch_end -ge $total_instances ]] && batch_end=$((total_instances - 1))
        
        log_info "Processing batch $batch_num: instances $((i+1)) to $((batch_end+1))"
        
        # Procesare instanțe din batch
        local batch_success=0
        for ((j=i; j<=batch_end; j++)); do
            local instance="${instances[$j]}"
            
            if deploy_to_instance "$instance" "$release_path"; then
                ((successful++))
                ((batch_success++))
                log_info "Instance $instance updated successfully ($successful/$total_instances)"
            else
                ((failed++))
                log_error "Instance $instance failed to update"
                
                # Verificare threshold de eșec
                if [[ $failed -gt $MAX_UNAVAILABLE ]]; then
                    log_fatal "Too many failures ($failed > $MAX_UNAVAILABLE). Aborting deployment."
                    return 1
                fi
            fi
        done
        
        # Așteptare stabilizare înainte de următorul batch
        if [[ $i + $BATCH_SIZE -lt $total_instances ]]; then
            log_info "Waiting for stabilization before next batch..."
            sleep "$HEALTH_CHECK_INTERVAL"
        fi
    done
    
    # Sumar final
    log_info "Rolling deployment completed: $successful successful, $failed failed"
    
    [[ $failed -eq 0 ]] && return 0 || return 1
}

#-------------------------------------------------------------------------------
# Deployment per instanță
#-------------------------------------------------------------------------------
deploy_to_instance() {
    local instance="$1"
    local release_path="$2"
    
    log_debug "Deploying to instance: $instance"
    
    # Pas 1: Drain - elimină instanța din load balancer
    log_debug "Draining instance from load balancer..."
    if ! drain_instance "$instance"; then
        log_error "Failed to drain instance $instance"
        return 1
    fi
    
    # Pas 2: Așteptare finalizare request-uri in-flight
    log_debug "Waiting for in-flight requests..."
    wait_for_drain "$instance" "$DRAIN_TIMEOUT"
    
    # Pas 3: Stop aplicație
    log_debug "Stopping application..."
    if ! stop_application "$instance"; then
        log_warn "Failed to stop gracefully, forcing..."
        force_stop_application "$instance"
    fi
    
    # Pas 4: Deploy noua versiune
    log_debug "Deploying new release..."
    if ! sync_release "$instance" "$release_path"; then
        log_error "Failed to sync release to $instance"
        # Rollback la versiunea anterioară
        restore_previous_version "$instance"
        enable_instance "$instance"
        return 1
    fi
    
    # Pas 5: Start aplicație
    log_debug "Starting application..."
    if ! start_application "$instance"; then
        log_error "Failed to start application on $instance"
        restore_previous_version "$instance"
        enable_instance "$instance"
        return 1
    fi
    
    # Pas 6: Health check
    log_debug "Performing health checks..."
    if ! wait_for_healthy "$instance" "$HEALTH_CHECK_RETRIES" "$HEALTH_CHECK_INTERVAL"; then
        log_error "Health check failed for $instance"
        restore_previous_version "$instance"
        start_application "$instance"
        enable_instance "$instance"
        return 1
    fi
    
    # Pas 7: Re-enable în load balancer
    log_debug "Re-enabling instance in load balancer..."
    if ! enable_instance "$instance"; then
        log_error "Failed to re-enable $instance"
        return 1
    fi
    
    log_info "Instance $instance successfully updated"
    return 0
}

#-------------------------------------------------------------------------------
# Funcții helper pentru Load Balancer
#-------------------------------------------------------------------------------
drain_instance() {
    local instance="$1"
    
    # Exemplu pentru HAProxy via socket
    if [[ -S "/var/run/haproxy/admin.sock" ]]; then
        echo "set server backend/$instance state drain" | \
            socat stdio /var/run/haproxy/admin.sock
        return $?
    fi
    
    # Exemplu pentru nginx upstream
    if [[ -f "/etc/nginx/conf.d/upstream.conf" ]]; then
        sed -i "s/server ${instance}/server ${instance} down/" \
            /etc/nginx/conf.d/upstream.conf
        nginx -s reload
        return $?
    fi
    
    log_warn "No load balancer detected, skipping drain"
    return 0
}

enable_instance() {
    local instance="$1"
    
    if [[ -S "/var/run/haproxy/admin.sock" ]]; then
        echo "set server backend/$instance state ready" | \
            socat stdio /var/run/haproxy/admin.sock
        return $?
    fi
    
    if [[ -f "/etc/nginx/conf.d/upstream.conf" ]]; then
        sed -i "s/server ${instance} down/server ${instance}/" \
            /etc/nginx/conf.d/upstream.conf
        nginx -s reload
        return $?
    fi
    
    return 0
}

wait_for_drain() {
    local instance="$1"
    local timeout="$2"
    
    local elapsed=0
    while [[ $elapsed -lt $timeout ]]; do
        local connections
        connections=$(get_active_connections "$instance")
        
        if [[ $connections -eq 0 ]]; then
            log_debug "Instance $instance fully drained"
            return 0
        fi
        
        log_debug "Waiting for $connections connections to close..."
        sleep 2
        ((elapsed += 2))
    done
    
    log_warn "Drain timeout reached, proceeding anyway"
    return 0
}

#-------------------------------------------------------------------------------
# Sync și Application Control
#-------------------------------------------------------------------------------
sync_release() {
    local instance="$1"
    local release_path="$2"
    
    # Pentru deploy local
    if [[ "$instance" == "localhost" || "$instance" == "127.0.0.1" ]]; then
        cp -r "$release_path"/* "$DEPLOY_PATH/"
        return $?
    fi
    
    # Pentru deploy remote via rsync
    rsync -avz --delete \
        --exclude='.git' \
        --exclude='*.log' \
        --exclude='tmp/*' \
        "$release_path/" \
        "${DEPLOY_USER}@${instance}:${DEPLOY_PATH}/"
    
    return $?
}

stop_application() {
    local instance="$1"
    
    run_on_instance "$instance" "systemctl stop ${APP_SERVICE}"
}

start_application() {
    local instance="$1"
    
    run_on_instance "$instance" "systemctl start ${APP_SERVICE}"
}

force_stop_application() {
    local instance="$1"
    
    run_on_instance "$instance" "systemctl kill -s KILL ${APP_SERVICE}"
}

run_on_instance() {
    local instance="$1"
    shift
    local command="$*"
    
    if [[ "$instance" == "localhost" || "$instance" == "127.0.0.1" ]]; then
        eval "$command"
    else
        ssh "${DEPLOY_USER}@${instance}" "$command"
    fi
}
```

### Puncte forte și puncte slabe

| Puncte forte | Puncte slabe |
|----------|-------------|
| Zero downtime | Versiuni mixte în producție |
| Rollback parțial posibil | Deployment mai lent |
| Resurse eficiente | Complexitate în tracking |
| Validare progresivă | Necesită compatibilitate backward |

---

## Strategia Blue-Green Deployment

### Concept

Blue-Green menține două medii de producție identice (Blue și Green). Într-un moment dat, unul servește traficul live (ex: Blue) în timp ce celălalt (Green) este inactiv sau folosit pentru pregătirea noii versiuni. Deployment-ul constă în switch-ul atomic al traficului.

### Diagrama de Flux

```
                    ÎNAINTE DE DEPLOYMENT
    ┌─────────────────────────────────────────────────────┐
    │                                                     │
    │    ┌─────────────┐         ┌─────────────┐         │
    │    │   BLUE      │         │   GREEN     │         │
    │    │   (V1)      │         │   (V1)      │         │
    │    │  [ACTIVE]   │         │  [STANDBY]  │         │
    │    └──────┬──────┘         └─────────────┘         │
    │           │                                         │
    │           │ 100% Traffic                           │
    │           ▼                                         │
    │    ┌─────────────┐                                 │
    │    │    USERS    │                                 │
    │    └─────────────┘                                 │
    └─────────────────────────────────────────────────────┘

                    PREGĂTIRE DEPLOYMENT
    ┌─────────────────────────────────────────────────────┐
    │                                                     │
    │    ┌─────────────┐         ┌─────────────┐         │
    │    │   BLUE      │         │   GREEN     │         │
    │    │   (V1)      │         │   (V2)      │         │
    │    │  [ACTIVE]   │    ◄──  │  [TESTING]  │         │
    │    └──────┬──────┘  smoke  └─────────────┘         │
    │           │         tests                          │
    │           │ 100% Traffic                           │
    │           ▼                                         │
    │    ┌─────────────┐                                 │
    │    │    USERS    │                                 │
    │    └─────────────┘                                 │
    └─────────────────────────────────────────────────────┘

                    DUPĂ SWITCH
    ┌─────────────────────────────────────────────────────┐
    │                                                     │
    │    ┌─────────────┐         ┌─────────────┐         │
    │    │   BLUE      │         │   GREEN     │         │
    │    │   (V1)      │         │   (V2)      │         │
    │    │  [STANDBY]  │         │  [ACTIVE]   │         │
    │    └─────────────┘         └──────┬──────┘         │
    │                                    │               │
    │                        100% Traffic│               │
    │                                    ▼               │
    │                           ┌─────────────┐          │
    │                           │    USERS    │          │
    │                           └─────────────┘          │
    └─────────────────────────────────────────────────────┘
```

### Implementare în Deployer

```bash
#!/bin/bash
#===============================================================================
# blue_green_deploy.sh - Implementare Blue-Green Deployment
#===============================================================================

source "$(dirname "$0")/../lib/deployer_core.sh"
source "$(dirname "$0")/../lib/deployer_utils.sh"

#-------------------------------------------------------------------------------
# Configurare
#-------------------------------------------------------------------------------
declare -g BLUE_ENV="blue"
declare -g GREEN_ENV="green"
declare -g ACTIVE_ENV_FILE="/var/run/deployer/active_env"
declare -g SMOKE_TEST_TIMEOUT=60
declare -g WARMUP_REQUESTS=100

#-------------------------------------------------------------------------------
# Determinare environment activ/inactiv
#-------------------------------------------------------------------------------
get_active_env() {
    if [[ -f "$ACTIVE_ENV_FILE" ]]; then
        cat "$ACTIVE_ENV_FILE"
    else
        echo "$BLUE_ENV"  # Default la blue
    fi
}

get_inactive_env() {
    local active
    active=$(get_active_env)
    
    if [[ "$active" == "$BLUE_ENV" ]]; then
        echo "$GREEN_ENV"
    else
        echo "$BLUE_ENV"
    fi
}

set_active_env() {
    local env="$1"
    echo "$env" > "$ACTIVE_ENV_FILE"
}

get_env_path() {
    local env="$1"
    echo "${DEPLOY_BASE_PATH}/${env}"
}

get_env_port() {
    local env="$1"
    
    case "$env" in
        blue)  echo "8001" ;;
        green) echo "8002" ;;
    esac
}

#-------------------------------------------------------------------------------
# Blue-Green Deployment Core
#-------------------------------------------------------------------------------
deploy_blue_green() {
    local release_path="$1"
    
    local active_env
    local target_env
    local target_path
    local target_port
    
    active_env=$(get_active_env)
    target_env=$(get_inactive_env)
    target_path=$(get_env_path "$target_env")
    target_port=$(get_env_port "$target_env")
    
    log_info "═══════════════════════════════════════════════════════════"
    log_info "  BLUE-GREEN DEPLOYMENT"
    log_info "═══════════════════════════════════════════════════════════"
    log_info "  Active environment:  $active_env"
    log_info "  Target environment:  $target_env"
    log_info "  Target path:         $target_path"
    log_info "  Target port:         $target_port"
    log_info "═══════════════════════════════════════════════════════════"
    
    # Pas 1: Pregătire target environment
    log_info "[1/6] Preparing target environment..."
    prepare_environment "$target_env" "$target_path" || {
        log_error "Failed to prepare environment"
        return 1
    }
    
    # Pas 2: Deploy în target environment
    log_info "[2/6] Deploying release to $target_env..."
    deploy_release "$release_path" "$target_path" || {
        log_error "Failed to deploy release"
        return 1
    }
    
    # Pas 3: Start aplicație în target
    log_info "[3/6] Starting application in $target_env..."
    start_environment "$target_env" || {
        log_error "Failed to start $target_env environment"
        return 1
    }
    
    # Pas 4: Smoke tests
    log_info "[4/6] Running smoke tests..."
    if ! run_smoke_tests "localhost:${target_port}"; then
        log_error "Smoke tests failed!"
        stop_environment "$target_env"
        return 1
    fi
    
    # Pas 5: Warmup (opțional)
    log_info "[5/6] Warming up application..."
    warmup_application "localhost:${target_port}" "$WARMUP_REQUESTS"
    
    # Pas 6: Switch traffic
    log_info "[6/6] Switching traffic to $target_env..."
    if ! switch_traffic "$target_env"; then
        log_error "Failed to switch traffic!"
        # Rollback
        stop_environment "$target_env"
        return 1
    fi
    
    # Update state
    set_active_env "$target_env"
    
    # Stop old environment (opțional - poate fi păstrat pentru rollback rapid)
    log_info "Stopping old environment ($active_env)..."
    stop_environment "$active_env"
    
    log_info "═══════════════════════════════════════════════════════════"
    log_info "  DEPLOYMENT SUCCESSFUL"
    log_info "  New active environment: $target_env"
    log_info "═══════════════════════════════════════════════════════════"
    
    return 0
}

#-------------------------------------------------------------------------------
# Environment Management
#-------------------------------------------------------------------------------
prepare_environment() {
    local env="$1"
    local path="$2"
    
    # Cleanup versiune anterioară
    if [[ -d "$path" ]]; then
        log_debug "Cleaning up previous deployment in $path"
        rm -rf "${path:?}/"*
    fi
    
    mkdir -p "$path"/{releases,shared,current}
    
    return 0
}

deploy_release() {
    local source="$1"
    local target="$2"
    
    log_debug "Copying release from $source to $target/releases/current"
    cp -r "$source"/* "$target/releases/current/" || return 1
    
    # Symlink la current
    rm -f "$target/current"
    ln -sfn "$target/releases/current" "$target/current"
    
    return 0
}

start_environment() {
    local env="$1"
    local service_name="app-${env}"
    
    systemctl start "$service_name" || return 1
    
    # Așteptare până aplicația e ready
    local retries=30
    while [[ $retries -gt 0 ]]; do
        if systemctl is-active --quiet "$service_name"; then
            return 0
        fi
        sleep 1
        ((retries--))
    done
    
    return 1
}

stop_environment() {
    local env="$1"
    local service_name="app-${env}"
    
    systemctl stop "$service_name" 2>/dev/null || true
}

#-------------------------------------------------------------------------------
# Testing
#-------------------------------------------------------------------------------
run_smoke_tests() {
    local endpoint="$1"
    local start_time=$SECONDS
    
    log_debug "Running smoke tests against $endpoint"
    
    # Test 1: Health endpoint
    if ! curl -sf "http://${endpoint}/health" > /dev/null; then
        log_error "Health check failed"
        return 1
    fi
    log_debug "  ✓ Health check passed"
    
    # Test 2: Basic functionality
    if ! curl -sf "http://${endpoint}/api/status" > /dev/null; then
        log_error "API status check failed"
        return 1
    fi
    log_debug "  ✓ API status check passed"
    
    # Test 3: Database connectivity (via app)
    local db_status
    db_status=$(curl -sf "http://${endpoint}/api/db/ping" 2>/dev/null || echo "error")
    if [[ "$db_status" != *"ok"* ]]; then
        log_error "Database connectivity check failed"
        return 1
    fi
    log_debug "  ✓ Database connectivity check passed"
    
    local duration=$((SECONDS - start_time))
    log_info "All smoke tests passed in ${duration}s"
    
    return 0
}

warmup_application() {
    local endpoint="$1"
    local requests="$2"
    
    log_debug "Sending $requests warmup requests to $endpoint"
    
    for ((i=1; i<=requests; i++)); do
        curl -sf "http://${endpoint}/" > /dev/null 2>&1 || true
        
        if (( i % 20 == 0 )); then
            log_debug "  Warmup progress: $i/$requests"
        fi
    done
    
    log_debug "Warmup completed"
}

#-------------------------------------------------------------------------------
# Traffic Switching
#-------------------------------------------------------------------------------
switch_traffic() {
    local target_env="$1"
    local target_port
    target_port=$(get_env_port "$target_env")
    
    # Metoda 1: Nginx upstream
    if [[ -f "/etc/nginx/conf.d/app-upstream.conf" ]]; then
        cat > "/etc/nginx/conf.d/app-upstream.conf" <<EOF
upstream app_backend {
    server 127.0.0.1:${target_port};
}
EOF
        nginx -t && nginx -s reload
        return $?
    fi
    
    # Metoda 2: HAProxy
    if [[ -S "/var/run/haproxy/admin.sock" ]]; then
        local old_env
        old_env=$(get_active_env)
        
        # Disable old, enable new
        echo "set server app_backend/${old_env} state maint" | \
            socat stdio /var/run/haproxy/admin.sock
        echo "set server app_backend/${target_env} state ready" | \
            socat stdio /var/run/haproxy/admin.sock
        return $?
    fi
    
    # Metoda 3: Symlink switch
    local live_path="${DEPLOY_BASE_PATH}/live"
    local target_path
    target_path=$(get_env_path "$target_env")
    
    rm -f "$live_path"
    ln -sfn "$target_path/current" "$live_path"
    
    return 0
}

#-------------------------------------------------------------------------------
# Rollback
#-------------------------------------------------------------------------------
rollback_blue_green() {
    local current_active
    local previous_env
    
    current_active=$(get_active_env)
    previous_env=$(get_inactive_env)
    
    log_warn "Initiating rollback from $current_active to $previous_env"
    
    # Verificare că previous environment există și e funcțional
    if ! is_environment_healthy "$previous_env"; then
        log_error "Previous environment $previous_env is not healthy!"
        return 1
    fi
    
    # Start previous environment dacă e oprit
    start_environment "$previous_env"
    
    # Switch traffic
    switch_traffic "$previous_env" || {
        log_error "Failed to switch traffic during rollback"
        return 1
    }
    
    # Update state
    set_active_env "$previous_env"
    
    # Stop failed environment
    stop_environment "$current_active"
    
    log_info "Rollback completed. Active environment: $previous_env"
    return 0
}

is_environment_healthy() {
    local env="$1"
    local port
    port=$(get_env_port "$env")
    
    curl -sf "http://localhost:${port}/health" > /dev/null 2>&1
}
```

### Puncte forte și puncte slabe

| Puncte forte | Puncte slabe |
|----------|-------------|
| Rollback instant | Dublare resurse |
| Zero downtime | Cost infrastructură |
| Testare în izolare | Sincronizare date complexă |
| Switch atomic | Nu detectează probleme graduale |

---

## Strategia Canary Deployment

### Concept

Canary deployment expune noua versiune doar unui subset mic de utilizatori inițial (ex: 5%), monitorizând intensiv pentru erori. Dacă metricile sunt acceptabile, procentajul crește gradual până la 100%.

### Diagrama de Flux

```
    Fază 1: 5% trafic           Fază 2: 25% trafic
    ┌────────────────────┐      ┌────────────────────┐
    │ V1 ████████████95% │      │ V1 ██████████ 75%  │
    │ V2 █           5%  │  ──► │ V2 ████      25%  │
    └────────────────────┘      └────────────────────┘
              │                           │
              ▼                           ▼
         Monitorizare                Monitorizare
         • Error rate                • Error rate
         • Latency                   • Latency
         • Business metrics          • Business metrics
              │                           │
         OK? ─┴─ NO ──► Rollback         OK?
              │                           │
             YES                         YES
              │                           │
              ▼                           ▼
    
    Fază 3: 50% trafic          Fază 4: 100% trafic
    ┌────────────────────┐      ┌────────────────────┐
    │ V1 ██████    50%   │      │ V2 ████████████100%│
    │ V2 ██████    50%   │  ──► │                    │
    └────────────────────┘      └────────────────────┘
```

### Implementare în Deployer

```bash
#!/bin/bash
#===============================================================================
# canary_deploy.sh - Implementare Canary Deployment
#===============================================================================

source "$(dirname "$0")/../lib/deployer_core.sh"
source "$(dirname "$0")/../lib/deployer_utils.sh"

#-------------------------------------------------------------------------------
# Configurare
#-------------------------------------------------------------------------------
declare -ga CANARY_STAGES=(5 25 50 75 100)
declare -g STAGE_DURATION=300  # 5 minute per stage
declare -g ERROR_THRESHOLD=1.0  # 1% error rate
declare -g LATENCY_THRESHOLD=500  # 500ms p99
declare -g METRICS_ENDPOINT="http://localhost:9090"
declare -g AUTO_PROMOTE=true

#-------------------------------------------------------------------------------
# Canary Deployment Core
#-------------------------------------------------------------------------------
deploy_canary() {
    local release_path="$1"
    
    log_info "═══════════════════════════════════════════════════════════"
    log_info "  CANARY DEPLOYMENT"
    log_info "═══════════════════════════════════════════════════════════"
    log_info "  Stages: ${CANARY_STAGES[*]}%"
    log_info "  Stage duration: ${STAGE_DURATION}s"
    log_info "  Error threshold: ${ERROR_THRESHOLD}%"
    log_info "  Latency threshold: ${LATENCY_THRESHOLD}ms"
    log_info "═══════════════════════════════════════════════════════════"
    
    # Pas 1: Deploy canary instances
    log_info "[1/3] Deploying canary instances..."
    if ! deploy_canary_instances "$release_path"; then
        log_error "Failed to deploy canary instances"
        return 1
    fi
    
    # Pas 2: Progresie prin stages
    log_info "[2/3] Starting canary progression..."
    for percentage in "${CANARY_STAGES[@]}"; do
        log_info "────────────────────────────────────────────────"
        log_info "  STAGE: ${percentage}% traffic to canary"
        log_info "────────────────────────────────────────────────"
        
        # Ajustare traffic split
        if ! set_canary_weight "$percentage"; then
            log_error "Failed to set canary weight to $percentage%"
            rollback_canary
            return 1
        fi
        
        # Monitorizare stage
        if ! monitor_canary_stage "$percentage" "$STAGE_DURATION"; then
            log_error "Canary failed at ${percentage}% stage"
            rollback_canary
            return 1
        fi
        
        log_info "Stage ${percentage}% completed successfully"
        
        # La 100%, ieșim din loop
        [[ "$percentage" -eq 100 ]] && break
        
        # Pauză între stages (pentru auto-promote)
        if [[ "$AUTO_PROMOTE" == "true" ]]; then
            log_info "Auto-promoting to next stage..."
        else
            log_info "Waiting for manual promotion..."
            wait_for_promotion || {
                log_warn "Promotion cancelled, initiating rollback"
                rollback_canary
                return 1
            }
        fi
    done
    
    # Pas 3: Finalizare
    log_info "[3/3] Finalizing deployment..."
    finalize_canary_deployment || {
        log_error "Failed to finalize deployment"
        return 1
    }
    
    log_info "═══════════════════════════════════════════════════════════"
    log_info "  CANARY DEPLOYMENT SUCCESSFUL"
    log_info "═══════════════════════════════════════════════════════════"
    
    return 0
}

#-------------------------------------------------------------------------------
# Canary Instance Management
#-------------------------------------------------------------------------------
deploy_canary_instances() {
    local release_path="$1"
    local canary_path="${DEPLOY_BASE_PATH}/canary"
    
    # Cleanup previous canary
    rm -rf "$canary_path"
    mkdir -p "$canary_path"
    
    # Copy release
    cp -r "$release_path"/* "$canary_path/"
    
    # Start canary instances
    for i in $(seq 1 "$CANARY_INSTANCE_COUNT"); do
        local service="app-canary-${i}"
        
        systemctl start "$service" || {
            log_error "Failed to start $service"
            return 1
        }
    done
    
    # Wait for healthy
    sleep 10
    
    return 0
}

#-------------------------------------------------------------------------------
# Traffic Management
#-------------------------------------------------------------------------------
set_canary_weight() {
    local percentage="$1"
    local stable_weight=$((100 - percentage))
    
    log_debug "Setting traffic: stable=${stable_weight}%, canary=${percentage}%"
    
    # Nginx upstream cu weighted round-robin
    if [[ -f "/etc/nginx/conf.d/app-upstream.conf" ]]; then
        cat > "/etc/nginx/conf.d/app-upstream.conf" <<EOF
upstream app_backend {
    # Stable instances
    server 127.0.0.1:8001 weight=${stable_weight};
    
    # Canary instances
    server 127.0.0.1:8002 weight=${percentage};
}
EOF
        nginx -t && nginx -s reload
        return $?
    fi
    
    # Istio VirtualService (pentru Kubernetes)
    if command -v kubectl &>/dev/null; then
        kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: app-vs
spec:
  http:
  - route:
    - destination:
        host: app-stable
      weight: ${stable_weight}
    - destination:
        host: app-canary
      weight: ${percentage}
EOF
        return $?
    fi
    
    return 0
}

#-------------------------------------------------------------------------------
# Monitoring și Analysis
#-------------------------------------------------------------------------------
monitor_canary_stage() {
    local percentage="$1"
    local duration="$2"
    local check_interval=30
    local elapsed=0
    
    while [[ $elapsed -lt $duration ]]; do
        # Collect metrics
        local canary_error_rate
        local canary_latency
        local stable_error_rate
        local stable_latency
        
        canary_error_rate=$(get_error_rate "canary")
        canary_latency=$(get_p99_latency "canary")
        stable_error_rate=$(get_error_rate "stable")
        stable_latency=$(get_p99_latency "stable")
        
        log_debug "Metrics at ${elapsed}s:"
        log_debug "  Canary - Error: ${canary_error_rate}%, Latency: ${canary_latency}ms"
        log_debug "  Stable - Error: ${stable_error_rate}%, Latency: ${stable_latency}ms"
        
        # Compare cu thresholds
        if ! check_canary_health "$canary_error_rate" "$canary_latency" \
                                  "$stable_error_rate" "$stable_latency"; then
            log_error "Canary health check failed!"
            return 1
        fi
        
        sleep "$check_interval"
        ((elapsed += check_interval))
        
        # Progress indicator
        local progress=$((elapsed * 100 / duration))
        echo -ne "\r  Stage progress: ${progress}% (${elapsed}s/${duration}s)"
    done
    
    echo ""
    return 0
}

get_error_rate() {
    local version="$1"
    
    # Query Prometheus
    local query="sum(rate(http_requests_total{status=~'5..',version='${version}'}[5m])) / sum(rate(http_requests_total{version='${version}'}[5m])) * 100"
    
    local result
    result=$(curl -s "${METRICS_ENDPOINT}/api/v1/query" \
        --data-urlencode "query=$query" \
        | jq -r '.data.result[0].value[1] // "0"')
    
    echo "${result:-0}"
}

get_p99_latency() {
    local version="$1"
    
    local query="histogram_quantile(0.99, sum(rate(http_request_duration_seconds_bucket{version='${version}'}[5m])) by (le)) * 1000"
    
    local result
    result=$(curl -s "${METRICS_ENDPOINT}/api/v1/query" \
        --data-urlencode "query=$query" \
        | jq -r '.data.result[0].value[1] // "0"')
    
    echo "${result:-0}"
}

check_canary_health() {
    local canary_error="$1"
    local canary_latency="$2"
    local stable_error="$3"
    local stable_latency="$4"
    
    # Check absolute thresholds
    if (( $(echo "$canary_error > $ERROR_THRESHOLD" | bc -l) )); then
        log_error "Canary error rate ${canary_error}% exceeds threshold ${ERROR_THRESHOLD}%"
        return 1
    fi
    
    if (( $(echo "$canary_latency > $LATENCY_THRESHOLD" | bc -l) )); then
        log_error "Canary latency ${canary_latency}ms exceeds threshold ${LATENCY_THRESHOLD}ms"
        return 1
    fi
    
    # Check relative (canary vs stable)
    local error_ratio
    error_ratio=$(echo "scale=2; $canary_error / ($stable_error + 0.001)" | bc -l)
    
    if (( $(echo "$error_ratio > 2.0" | bc -l) )); then
        log_error "Canary error rate is ${error_ratio}x higher than stable"
        return 1
    fi
    
    return 0
}

#-------------------------------------------------------------------------------
# Rollback și Finalizare
#-------------------------------------------------------------------------------
rollback_canary() {
    log_warn "Initiating canary rollback..."
    
    # Redirect tot traficul la stable
    set_canary_weight 0
    
    # Stop canary instances
    for i in $(seq 1 "$CANARY_INSTANCE_COUNT"); do
        systemctl stop "app-canary-${i}" 2>/dev/null || true
    done
    
    # Cleanup
    rm -rf "${DEPLOY_BASE_PATH}/canary"
    
    log_info "Canary rollback completed"
}

finalize_canary_deployment() {
    log_info "Promoting canary to stable..."
    
    # Copy canary to stable
    local stable_path="${DEPLOY_BASE_PATH}/stable"
    local canary_path="${DEPLOY_BASE_PATH}/canary"
    
    # Backup current stable
    if [[ -d "$stable_path" ]]; then
        mv "$stable_path" "${stable_path}.backup.$(date +%s)"
    fi
    
    # Promote canary
    mv "$canary_path" "$stable_path"
    
    # Restart stable instances with new version
    for i in $(seq 1 "$STABLE_INSTANCE_COUNT"); do
        systemctl restart "app-stable-${i}"
    done
    
    # Redirect tot traficul la stable
    set_canary_weight 0
    
    # Stop canary-specific instances
    for i in $(seq 1 "$CANARY_INSTANCE_COUNT"); do
        systemctl stop "app-canary-${i}" 2>/dev/null || true
    done
    
    return 0
}
```

### Puncte forte și puncte slabe

| Puncte forte | Puncte slabe |
|----------|-------------|
| Risc minim | Complexitate setup |
| Feedback real de la users | Necesită monitoring avansat |
| Detectare probleme subtile | Deployment mai lent |
| Rollback instant parțial | A/B testing side effects |

---

## Comparație Sintetică

### Tabel Comparativ

| Criteriu | Rolling | Blue-Green | Canary |
|----------|---------|------------|--------|
| **Downtime** | Zero | Zero | Zero |
| **Resurse suplimentare** | Minime | 2x | ~10-20% |
| **Complexitate** | Medie | Medie | Ridicată |
| **Timp deployment** | Mediu | Rapid | Lung |
| **Rollback speed** | Mediu | Instant | Gradual |
| **Risc** | Moderat | Scăzut | Foarte scăzut |
| **Versiuni simultane** | Da | Nu (momentan) | Da |
| **Necesită LB avansat** | Nu | Nu | Da |
| **Testing pre-live** | Parțial | Complet | Parțial |

### Arbore de Decizie

```
                    START
                      │
                      ▼
              ┌───────────────┐
              │ Ai monitoring │
              │    avansat?   │
              └───────┬───────┘
                      │
           NO ◄───────┴───────► YES
            │                    │
            ▼                    ▼
    ┌───────────────┐    ┌───────────────┐
    │ Poți dubla    │    │ Trafic mare   │
    │  resursele?   │    │   (>1M/zi)?   │
    └───────┬───────┘    └───────┬───────┘
            │                    │
     YES ◄──┴──► NO      YES ◄──┴──► NO
      │          │         │          │
      ▼          ▼         ▼          ▼
  BLUE-GREEN  ROLLING   CANARY    ROLLING
```

---

## Exerciții Practice

### Exercițiul 1: Implementare Feature Flags

Extindeți deployment-ul canary cu feature flags:

```bash
# Cerințe:
# - Toggle features per user/segment
# - Integrare cu deployment canary
# - Dashboard pentru management flags
```

### Exercițiul 2: Multi-Region Deployment

Implementați deployment cross-region:

```bash
# Cerințe:
# - Deploy în regiuni multiple secvențial
# - Health checks per regiune
# - Rollback selectiv per regiune
```

### Exercițiul 3: GitOps Pipeline

Creați pipeline GitOps complet:

```bash
# Cerințe:
# - Trigger deployment la push
# - Selecție strategie bazată pe branch
# - Integration tests automate
```

### Exercițiul 4: Chaos Engineering Integration

Integrați chaos testing în deployment:

```bash
# Cerințe:
# - Injectare failure în canary stage
# - Verificare resilience
# - Auto-rollback la failure
```

### Exercițiul 5: Deployment Metrics Dashboard

Creați sistem de vizualizare metrici:

```bash
# Cerințe:
# - Colectare metrici deployment
# - Vizualizare în terminal
# - Export pentru Grafana/Prometheus
```

---

## Resurse Adiționale

### Pattern-uri Avansate

1. **Shadow Deployment**: Trafic duplicat către versiunea nouă fără a servi răspunsuri
2. **A/B Testing**: Deployment bazat pe experimente și metrici business
3. **Dark Launching**: Features ascunse activate selectiv
4. **Ramped Deployment**: Creștere liniară a traficului (vs. stages discrete)

### Best Practices

1. **Automatizare completă**: Niciun pas manual în deployment
2. **Monitoring before deploy**: Setup alerting înainte de orice schimbare
3. **Rollback testat**: Verificați că rollback funcționează înainte de deploy
4. **Comunicare**: Notificați echipa despre deployment-uri planificate
5. **Post-mortems**: Analizați fiecare deployment eșuat
