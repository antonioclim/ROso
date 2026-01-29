#!/usr/bin/env bash
# ==============================================================================
# DEPLOYER - Main Entry Point
# ==============================================================================
# Sistem profesional de deployment pentru servicii și containere
# Suport pentru: systemd services, Docker containers, file deployment
# Parte din proiectul CAPSTONE pentru Sisteme de Operare
# ==============================================================================

# Strict mode
set -o errexit
set -o nounset
set -o pipefail

# ==============================================================================
# SCRIPT LOCATION
# ==============================================================================

# Determină locația scriptului (rezolvă symlinks)
get_script_dir() {
    local source="${BASH_SOURCE[0]}"
    while [[ -L "$source" ]]; do
        local dir
        dir=$(cd -P "$(dirname "$source")" && pwd)
        source=$(readlink "$source")
        [[ $source != /* ]] && source="$dir/$source"
    done
    cd -P "$(dirname "$source")" && pwd
}

readonly SCRIPT_DIR=$(get_script_dir)
readonly SCRIPT_NAME=$(basename "$0")

# ==============================================================================
# LOAD LIBRARIES
# ==============================================================================

# Verifică și încarcă bibliotecile
load_library() {
    local lib="$1"
    local lib_path="$SCRIPT_DIR/lib/$lib"
    
    if [[ ! -f "$lib_path" ]]; then
        echo "ERROR: Library not found: $lib_path" >&2
        exit 3
    fi
    
    # shellcheck source=/dev/null
    source "$lib_path"
}

# Încarcă în ordine
load_library "core.sh"
load_library "utils.sh"
load_library "config.sh"

# ==============================================================================
# DEPLOYMENT ACTIONS
# ==============================================================================

# Deploy un serviciu systemd
# Args: $1 = service name, $2 = source path (opțional)
deploy_service() {
    local service=$1
    local source_path=${2:-""}
    
    ((DEPLOY_SERVICES_TOTAL++))
    
    log_subheader "Deploying service: $service"
    
    # Hook pre-service
    run_hook "pre-service" "$service" "deploy" || {
        log_error "Pre-service hook failed for: $service"
        ((DEPLOY_SERVICES_FAILED++))
        return 1
    }
    
    # Verifică dacă serviciul există
    if ! has_systemd; then
        log_warn "Systemd not available, skipping service: $service"
        return 0
    fi
    
    local service_status
    service_status=$(get_service_status "$service")
    
    # Backup configurație curentă dacă există
    if [[ "$NO_BACKUP" != "true" && -f "/etc/systemd/system/${service}.service" ]]; then
        local backup_file="$BACKUP_DIR/services/${service}.service.$(get_short_timestamp)"
        mkdir -p "$BACKUP_DIR/services"
        
        if [[ "$DRY_RUN" == "true" ]]; then
            log_info "[DRY RUN] Would backup: ${service}.service -> $backup_file"
        else
            cp "/etc/systemd/system/${service}.service" "$backup_file"
            register_rollback "service_${service}_backup" "$backup_file"
            log_debug "Backup created: $backup_file"
        fi
    fi
    
    # Copiază fișier service dacă e furnizat
    if [[ -n "$source_path" && -f "$source_path" ]]; then
        if [[ "$DRY_RUN" == "true" ]]; then
            log_info "[DRY RUN] Would copy: $source_path -> /etc/systemd/system/${service}.service"
        else
            cp "$source_path" "/etc/systemd/system/${service}.service"
            systemctl daemon-reload
        fi
    fi
    
    # Restart serviciul
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY RUN] Would restart service: $service"
    else
        if [[ "$service_status" == "active" ]]; then
            restart_service "$service" || {
                log_error "Failed to restart service: $service"
                ((DEPLOY_SERVICES_FAILED++))
                run_hook "post-service" "$service" "failed"
                return 1
            }
        else
            start_service "$service" || {
                log_error "Failed to start service: $service"
                ((DEPLOY_SERVICES_FAILED++))
                run_hook "post-service" "$service" "failed"
                return 1
            }
        fi
        
        # Așteaptă stabilizare
        sleep "$SERVICE_RESTART_DELAY"
    fi
    
    # Health check
    if [[ "$HEALTH_CHECK_ENABLED" == "true" && "$DRY_RUN" != "true" ]]; then
        log_info "Running health check for: $service"
        
        local new_status
        new_status=$(get_service_status "$service")
        
        if [[ "$new_status" != "active" ]]; then
            log_error "Service not active after deploy: $service (status: $new_status)"
            ((DEPLOY_SERVICES_FAILED++))
            run_hook "post-service" "$service" "failed"
            return 1
        fi
        
        log_info "Service healthy: $service"
    fi
    
    # Success
    register_deployed_service "$service" "latest" ""
    run_hook "post-service" "$service" "success"
    log_info "${SYMBOL_SUCCESS} Service deployed: $service"
    
    return 0
}

# Deploy un container Docker
# Args: $1 = container/image, $2 = version/tag (opțional)
deploy_container() {
    local container=$1
    local version=${2:-"latest"}
    
    ((DEPLOY_SERVICES_TOTAL++))
    
    # Separăm container name de image
    local container_name
    local image
    
    if [[ "$container" =~ : ]]; then
        # Format: image:tag
        image="$container"
        container_name=$(echo "$container" | cut -d: -f1 | tr '/:' '_')
        version=$(echo "$container" | cut -d: -f2)
    else
        container_name="$container"
        image="$container:$version"
    fi
    
    # Adaugă registry dacă e configurat
    if [[ -n "$DOCKER_REGISTRY" && ! "$image" =~ / ]]; then
        image="${DOCKER_REGISTRY}/${image}"
    fi
    
    log_subheader "Deploying container: $container_name (image: $image)"
    
    # Hook pre-service
    run_hook "pre-service" "$container_name" "deploy" || {
        log_error "Pre-service hook failed for: $container_name"
        ((DEPLOY_SERVICES_FAILED++))
        return 1
    }
    
    # Verifică Docker
    if ! docker_available; then
        log_error "Docker not available"
        ((DEPLOY_SERVICES_FAILED++))
        return 1
    fi
    
    # Backup container curent (salvăm ID-ul imaginii)
    if [[ "$NO_BACKUP" != "true" ]]; then
        local current_image
        current_image=$(docker inspect --format='{{.Config.Image}}' "$container_name" 2>/dev/null || echo "")
        if [[ -n "$current_image" ]]; then
            register_rollback "container_${container_name}_image" "$current_image"
            log_debug "Registered rollback image: $current_image"
        fi
    fi
    
    # Pull image dacă e cerut
    if [[ "${DOCKER_PULL:-true}" == "true" ]]; then
        if [[ "$DRY_RUN" == "true" ]]; then
            log_info "[DRY RUN] Would pull image: $image"
        else
            log_info "Pulling image: $image"
            if ! run_with_timeout "$DOCKER_PULL_TIMEOUT" docker pull "$image"; then
                log_error "Failed to pull image: $image"
                ((DEPLOY_SERVICES_FAILED++))
                run_hook "post-service" "$container_name" "failed"
                return 1
            fi
        fi
    fi
    
    # Stop și remove container vechi
    if container_exists "$container_name"; then
        if [[ "$DRY_RUN" == "true" ]]; then
            log_info "[DRY RUN] Would stop container: $container_name"
        else
            stop_container "$container_name" "$CONTAINER_STOP_TIMEOUT"
            remove_container "$container_name"
        fi
    fi
    
    # Start container nou
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY RUN] Would start container: $container_name from $image"
    else
        log_info "Starting container: $container_name"
        
        # Citim opțiunile din environment sau folosim defaults
        local container_opts=()
        
        # Verificăm dacă avem un fișier de configurare pentru container
        local container_config="$DEPLOY_ROOT/containers/${container_name}.conf"
        if [[ -f "$container_config" ]]; then
            # shellcheck source=/dev/null
            source "$container_config"
            # Container config poate seta: CONTAINER_PORTS, CONTAINER_VOLUMES, CONTAINER_ENV, etc.
            
            [[ -n "${CONTAINER_PORTS:-}" ]] && container_opts+=(-p "$CONTAINER_PORTS")
            [[ -n "${CONTAINER_VOLUMES:-}" ]] && container_opts+=(-v "$CONTAINER_VOLUMES")
            [[ -n "${CONTAINER_RESTART:-}" ]] && container_opts+=(--restart "$CONTAINER_RESTART")
        else
            # Defaults sensibile
            container_opts+=(--restart unless-stopped)
        fi
        
        if ! docker run -d --name "$container_name" "${container_opts[@]}" "$image" &>/dev/null; then
            log_error "Failed to start container: $container_name"
            ((DEPLOY_SERVICES_FAILED++))
            run_hook "post-service" "$container_name" "failed"
            return 1
        fi
        
        # Așteaptă să pornească
        sleep 3
    fi
    
    # Health check
    if [[ "$HEALTH_CHECK_ENABLED" == "true" && "$DRY_RUN" != "true" ]]; then
        log_info "Running health check for container: $container_name"
        
        if ! container_running "$container_name"; then
            log_error "Container not running after deploy: $container_name"
            
            # Afișează logs pentru debugging
            log_debug "Container logs:"
            docker logs --tail 20 "$container_name" 2>&1 | while read -r line; do
                log_debug "  $line"
            done
            
            ((DEPLOY_SERVICES_FAILED++))
            run_hook "post-service" "$container_name" "failed"
            return 1
        fi
        
        # Health check avansat dacă containerul expune un port
        local container_port
        container_port=$(docker port "$container_name" 2>/dev/null | head -1 | cut -d: -f2 || echo "")
        
        if [[ -n "$container_port" ]]; then
            if ! health_check_with_retry tcp "$HEALTH_CHECK_RETRIES" "$HEALTH_CHECK_INTERVAL" \
                    "localhost" "$container_port"; then
                log_warn "Container port not responding, but container is running"
            fi
        fi
        
        log_info "Container healthy: $container_name"
    fi
    
    # Success
    register_deployed_service "$container_name" "$version" "$image"
    run_hook "post-service" "$container_name" "success"
    log_info "${SYMBOL_SUCCESS} Container deployed: $container_name"
    
    return 0
}

# Deploy din manifest
# Args: $1 = manifest file
deploy_from_manifest() {
    local manifest=$1
    
    log_subheader "Processing manifest: $manifest"
    
    # Parsează manifest
    if ! validate_manifest "$manifest"; then
        log_error "Invalid manifest: $manifest"
        return 1
    fi
    
    local name="${MANIFEST_NAME:-unknown}"
    local version="${MANIFEST_VERSION:-latest}"
    local type="${MANIFEST_TYPE:-service}"
    
    log_info "Manifest: $name v$version (type: $type)"
    
    case "$type" in
        service)
            # Caut fișierul service
            local service_file="${MANIFEST_SERVICE_FILE:-}"
            if [[ -z "$service_file" ]]; then
                service_file="$(dirname "$manifest")/${name}.service"
            fi
            deploy_service "$name" "$service_file"
            ;;
            
        container)
            local image="${MANIFEST_IMAGE:-$name}"
            deploy_container "$image" "$version"
            ;;
            
        files)
            # Deploy fișiere
            local source_dir="${MANIFEST_SOURCE:-}"
            local dest_dir="${MANIFEST_DESTINATION:-}"
            
            if [[ -n "$source_dir" && -n "$dest_dir" ]]; then
                deploy_directory "$source_dir" "$dest_dir" "$BACKUP_DIR/files"
            fi
            ;;
            
        *)
            log_warn "Unknown manifest type: $type"
            ;;
    esac
}

# ==============================================================================
# ROLLBACK
# ==============================================================================

# Rollback serviciu
# Args: $1 = service name
rollback_service() {
    local service=$1
    
    log_subheader "Rolling back service: $service"
    
    run_hook "pre-rollback" "$service"
    
    # Obține backup-ul
    local backup_file
    backup_file=$(get_rollback_data "service_${service}_backup")
    
    if [[ -n "$backup_file" && -f "$backup_file" ]]; then
        log_info "Restoring from backup: $backup_file"
        
        if [[ "$DRY_RUN" != "true" ]]; then
            cp "$backup_file" "/etc/systemd/system/${service}.service"
            systemctl daemon-reload
            restart_service "$service"
        else
            log_info "[DRY RUN] Would restore: $backup_file"
        fi
    else
        log_warn "No backup found for service: $service"
    fi
    
    run_hook "post-rollback" "$service"
}

# Rollback container
# Args: $1 = container name
rollback_container() {
    local container=$1
    
    log_subheader "Rolling back container: $container"
    
    run_hook "pre-rollback" "$container"
    
    # Obține imaginea anterioară
    local previous_image
    previous_image=$(get_rollback_data "container_${container}_image")
    
    if [[ -n "$previous_image" ]]; then
        log_info "Restoring to image: $previous_image"
        
        if [[ "$DRY_RUN" != "true" ]]; then
            stop_container "$container" 10
            remove_container "$container" true
            
            # Repornește cu imaginea veche
            docker run -d --name "$container" --restart unless-stopped "$previous_image" &>/dev/null
        else
            log_info "[DRY RUN] Would restore to: $previous_image"
        fi
    else
        log_warn "No previous image found for container: $container"
    fi
    
    run_hook "post-rollback" "$container"
}

# Execută rollback complet
do_rollback() {
    log_header "ROLLBACK"
    DEPLOYMENT_STATE=$STATE_ROLLED_BACK
    
    run_hook "pre-rollback"
    
    # Rollback services
    for service in "${SERVICES[@]}"; do
        rollback_service "$service"
    done
    
    # Rollback containers
    for container in "${CONTAINERS[@]}"; do
        rollback_container "$container"
    done
    
    run_hook "post-rollback"
    
    log_info "Rollback completed"
}

# ==============================================================================
# STATUS AND LIST
# ==============================================================================

# Afișează status servicii
show_status() {
    log_header "DEPLOYMENT STATUS"
    
    if [[ ${#SERVICES[@]} -gt 0 ]]; then
        echo ""
        echo -e "${CYAN}Services:${NC}"
        for service in "${SERVICES[@]}"; do
            local status
            status=$(get_service_status "$service")
            
            case "$status" in
                active)   echo -e "  ${GREEN}●${NC} $service (active)" ;;
                inactive) echo -e "  ${YELLOW}●${NC} $service (inactive)" ;;
                failed)   echo -e "  ${RED}●${NC} $service (failed)" ;;
                *)        echo -e "  ${GRAY}●${NC} $service ($status)" ;;
            esac
        done
    fi
    
    if [[ ${#CONTAINERS[@]} -gt 0 ]]; then
        echo ""
        echo -e "${CYAN}Containers:${NC}"
        for container in "${CONTAINERS[@]}"; do
            local status
            status=$(get_container_status "$container")
            
            case "$status" in
                running)   echo -e "  ${GREEN}●${NC} $container (running)" ;;
                stopped)   echo -e "  ${YELLOW}●${NC} $container (stopped)" ;;
                not-found) echo -e "  ${RED}●${NC} $container (not found)" ;;
                *)         echo -e "  ${GRAY}●${NC} $container ($status)" ;;
            esac
        done
    fi
    
    echo ""
}

# Listează servicii disponibile
list_services() {
    log_header "AVAILABLE TARGETS"
    
    if has_systemd; then
        echo ""
        echo -e "${CYAN}Systemd Services:${NC}"
        systemctl list-unit-files --type=service --state=enabled 2>/dev/null | \
            grep -v '@' | head -20 | while read -r line; do
            echo "  $line"
        done
        echo "  ..."
    fi
    
    if docker_available; then
        echo ""
        echo -e "${CYAN}Docker Containers:${NC}"
        docker ps -a --format '  {{.Names}}\t{{.Status}}\t{{.Image}}' 2>/dev/null || echo "  (none)"
        
        echo ""
        echo -e "${CYAN}Docker Images:${NC}"
        docker images --format '  {{.Repository}}:{{.Tag}}' 2>/dev/null | head -10
    fi
    
    if [[ -d "$DEPLOY_ROOT" ]]; then
        echo ""
        echo -e "${CYAN}Manifests in $DEPLOY_ROOT:${NC}"
        find "$DEPLOY_ROOT" -name "*.yaml" -o -name "*.yml" 2>/dev/null | head -10 | while read -r f; do
            echo "  $f"
        done
    fi
    
    echo ""
}

# Execută health checks
do_health_checks() {
    log_header "HEALTH CHECKS"
    
    local all_healthy=true
    
    for service in "${SERVICES[@]}"; do
        local status
        status=$(get_service_status "$service")
        
        if [[ "$status" == "active" ]]; then
            echo -e "${GREEN}${SYMBOL_SUCCESS}${NC} $service: healthy"
        else
            echo -e "${RED}${SYMBOL_FAILURE}${NC} $service: $status"
            all_healthy=false
        fi
    done
    
    for container in "${CONTAINERS[@]}"; do
        if container_running "$container"; then
            echo -e "${GREEN}${SYMBOL_SUCCESS}${NC} $container: healthy"
        else
            echo -e "${RED}${SYMBOL_FAILURE}${NC} $container: not running"
            all_healthy=false
        fi
    done
    
    echo ""
    
    if [[ "$all_healthy" == "true" ]]; then
        log_info "All health checks passed"
        return 0
    else
        log_error "Some health checks failed"
        return 4
    fi
}

# ==============================================================================
# NOTIFICATIONS
# ==============================================================================

# Trimite notificare email
send_email_notification() {
    local subject=$1
    local body=$2
    
    if [[ -z "$NOTIFY_EMAIL" ]]; then
        return 0
    fi
    
    log_debug "Sending email notification to: $NOTIFY_EMAIL"
    
    if command_exists mail; then
        echo "$body" | mail -s "$subject" "$NOTIFY_EMAIL" 2>/dev/null || true
    elif command_exists sendmail; then
        {
            echo "Subject: $subject"
            echo ""
            echo "$body"
        } | sendmail "$NOTIFY_EMAIL" 2>/dev/null || true
    else
        log_warn "No mail command available"
    fi
}

# Trimite notificare Slack
send_slack_notification() {
    local message=$1
    local color=${2:-"good"}
    
    if [[ -z "$SLACK_WEBHOOK" ]]; then
        return 0
    fi
    
    log_debug "Sending Slack notification"
    
    local payload
    payload=$(cat <<EOF
{
    "attachments": [{
        "color": "$color",
        "text": "$message",
        "footer": "SysDeployer | $(get_hostname)",
        "ts": $(date +%s)
    }]
}
EOF
)
    
    curl -s -X POST -H 'Content-type: application/json' \
        --data "$payload" "$SLACK_WEBHOOK" &>/dev/null || true
}

# Notifică rezultatul deployment-ului
notify_deployment_result() {
    local status=$1
    
    local subject="[Deployment] $DEPLOYMENT_ID - $status"
    local message="Deployment $DEPLOYMENT_ID completed with status: $status"
    message+="\nEnvironment: $ENVIRONMENT"
    message+="\nServices: ${SERVICES[*]:-none}"
    message+="\nContainers: ${CONTAINERS[*]:-none}"
    message+="\nDuration: $(format_duration "$(get_deployment_duration)")"
    
    if [[ "$status" == "success" && "$NOTIFY_ON_SUCCESS" == "true" ]]; then
        send_email_notification "$subject" "$message"
        send_slack_notification "$message" "good"
    elif [[ "$status" == "failed" && "$NOTIFY_ON_FAILURE" == "true" ]]; then
        send_email_notification "$subject" "$message"
        send_slack_notification "$message" "danger"
    fi
}

# ==============================================================================
# DEPLOYMENT STRATEGIES
# ==============================================================================

# Rolling Deployment - update gradual, câte o instanță la un moment dat
# Puncte forte: zero downtime, rollback per instanță
# Puncte slabe: timp mai lung, versiuni mixte temporar
deploy_rolling() {
    local services=("$@")
    local batch_size="${ROLLING_BATCH_SIZE:-1}"
    local delay="${ROLLING_DELAY:-10}"
    local total=${#services[@]}
    local deployed=0
    
    log_info "Rolling deployment: ${total} services, batch size: ${batch_size}"
    
    for ((i=0; i<total; i+=batch_size)); do
        local batch=("${services[@]:i:batch_size}")
        log_info "Deploying batch $((i/batch_size + 1)): ${batch[*]}"
        
        for service in "${batch[@]}"; do
            if ! deploy_service "$service"; then
                log_error "Failed to deploy: $service"
                if [[ "$ROLLBACK_ON_FAILURE" == "true" ]]; then
                    log_warn "Rolling back deployed services..."
                    do_rollback
                    return 1
                fi
            fi
            ((deployed++))
            log_info "Progress: ${deployed}/${total}"
        done
        
        # Delay între batches pentru stabilizare
        if ((i + batch_size < total)); then
            log_info "Waiting ${delay}s before next batch..."
            sleep "$delay"
        fi
    done
    
    log_info "Rolling deployment complete: ${deployed}/${total} services"
    return 0
}

# Blue-Green Deployment - două medii identice, switch instant
# Puncte forte: rollback instant, testare completă înainte de switch
# Puncte slabe: 2x resurse necesare
deploy_blue_green() {
    local services=("$@")
    
    # Determinăm mediul activ și țintă
    local active_env="${ACTIVE_ENVIRONMENT:-blue}"
    local target_env
    [[ "$active_env" == "blue" ]] && target_env="green" || target_env="blue"
    
    log_info "Blue-Green deployment: $active_env → $target_env"
    
    # 1. Deploy pe mediul inactiv
    log_info "Deploying to $target_env environment..."
    ENVIRONMENT="$target_env"
    
    for service in "${services[@]}"; do
        local service_target="${service}-${target_env}"
        if ! deploy_service "$service_target"; then
            log_error "Failed to deploy $service to $target_env"
            return 1
        fi
    done
    
    # 2. Smoke tests pe mediul nou
    log_info "Running smoke tests on $target_env..."
    if ! run_smoke_tests "$target_env"; then
        log_error "Smoke tests failed on $target_env"
        return 1
    fi
    
    # 3. Switch traffic
    log_info "Switching traffic from $active_env to $target_env..."
    if ! switch_traffic "$target_env"; then
        log_error "Failed to switch traffic"
        return 1
    fi
    
    # 4. Update active environment
    ACTIVE_ENVIRONMENT="$target_env"
    log_info "Blue-Green deployment complete. Active: $target_env"
    
    # Fostul mediu rămâne ca rollback instant
    log_info "Rollback available: switch back to $active_env"
    
    return 0
}

# Canary Deployment - lansare graduală bazată pe procent de trafic
# Puncte forte: risc minim, metrics-driven, control fin
# Puncte slabe: complexitate, necesită monitoring avansat
deploy_canary() {
    local services=("$@")
    local stages="${CANARY_STAGES:-5 25 50 75 100}"
    local observe_time="${CANARY_OBSERVE_TIME:-60}"
    local error_threshold="${CANARY_ERROR_THRESHOLD:-5}"
    
    log_info "Canary deployment: stages: $stages, observe: ${observe_time}s"
    
    # Deploy canary instances
    log_info "Deploying canary instances..."
    for service in "${services[@]}"; do
        local canary_service="${service}-canary"
        if ! deploy_service "$canary_service"; then
            log_error "Failed to deploy canary: $service"
            return 1
        fi
    done
    
    # Gradual traffic increase
    for percentage in $stages; do
        log_info "Setting canary weight: ${percentage}%"
        
        if ! set_canary_weight "$percentage"; then
            log_error "Failed to set canary weight"
            rollback_canary
            return 1
        fi
        
        if [[ "$percentage" -lt 100 ]]; then
            log_info "Observing for ${observe_time}s..."
            sleep "$observe_time"
            
            # Check metrics
            local error_rate
            error_rate=$(get_canary_error_rate 2>/dev/null || echo "0")
            
            if (( $(echo "$error_rate > $error_threshold" | bc -l 2>/dev/null || echo 0) )); then
                log_error "Error rate too high: ${error_rate}% > ${error_threshold}%"
                log_warn "Rolling back canary..."
                rollback_canary
                return 1
            fi
            
            log_info "Stage ${percentage}% healthy (error rate: ${error_rate}%)"
        fi
    done
    
    # Promote canary to stable
    log_info "Promoting canary to stable..."
    promote_canary
    
    log_info "Canary deployment complete"
    return 0
}

# Helper functions for strategies
switch_traffic() {
    local target_env="$1"
    # Implementare: update load balancer, DNS, sau routing rules
    log_debug "Switching traffic to: $target_env"
    # În producție: nginx reload, HAProxy update, etc.
    return 0
}

run_smoke_tests() {
    local env="$1"
    log_debug "Running smoke tests on: $env"
    # Rulează teste de bază: health check, endpoint-uri critice
    run_hook "smoke-test" "$env"
    return $?
}

set_canary_weight() {
    local weight="$1"
    log_debug "Setting canary weight: ${weight}%"
    # Implementare: update load balancer weights
    return 0
}

get_canary_error_rate() {
    # Citește error rate din monitoring system
    # În producție: Prometheus query, CloudWatch, etc.
    echo "0"
}

rollback_canary() {
    log_warn "Rolling back canary deployment..."
    set_canary_weight 0
    # Cleanup canary instances
}

promote_canary() {
    log_info "Promoting canary to stable..."
    # Replace stable instances with canary
    set_canary_weight 100
}

# ==============================================================================
# MAIN DEPLOYMENT LOGIC
# ==============================================================================

# Execută deployment principal
do_deploy() {
    log_header "DEPLOYMENT STARTED"
    
    # Generează deployment ID
    set_deployment_id
    
    log_deploy "Environment: $ENVIRONMENT"
    log_deploy "Strategy: $STRATEGY"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_warn "DRY RUN MODE - No changes will be made"
    fi
    
    # Hook pre-deploy
    run_hook "pre-deploy" || {
        log_error "Pre-deploy hook failed"
        DEPLOYMENT_STATE=$STATE_FAILED
        return 1
    }
    
    local deploy_failed=false
    
    # Deploy services bazat pe strategie
    if [[ ${#SERVICES[@]} -gt 0 ]]; then
        log_info "Deploying ${#SERVICES[@]} services using strategy: $STRATEGY"
        
        case "$STRATEGY" in
            rolling)
                if ! deploy_rolling "${SERVICES[@]}"; then
                    deploy_failed=true
                fi
                ;;
            blue-green)
                if ! deploy_blue_green "${SERVICES[@]}"; then
                    deploy_failed=true
                fi
                ;;
            canary)
                if ! deploy_canary "${SERVICES[@]}"; then
                    deploy_failed=true
                fi
                ;;
            in-place|*)
                # Default: deploy direct, unul câte unul
                for service in "${SERVICES[@]}"; do
                    if ! deploy_service "$service"; then
                        deploy_failed=true
                        
                        if [[ "$ROLLBACK_ON_FAILURE" == "true" ]]; then
                            log_warn "Service deployment failed, initiating rollback"
                            do_rollback
                            DEPLOYMENT_STATE=$STATE_ROLLED_BACK
                            run_hook "post-deploy"
                            notify_deployment_result "rolled_back"
                            return 2
                        fi
                    fi
                done
                ;;
        esac
    fi
    
    # Deploy containers
    for container in "${CONTAINERS[@]}"; do
        if ! deploy_container "$container"; then
            deploy_failed=true
            
            if [[ "$ROLLBACK_ON_FAILURE" == "true" ]]; then
                log_warn "Container deployment failed, initiating rollback"
                do_rollback
                DEPLOYMENT_STATE=$STATE_ROLLED_BACK
                run_hook "post-deploy"
                notify_deployment_result "rolled_back"
                return 2
            fi
        fi
    done
    
    # Deploy from manifests
    for manifest in "${MANIFESTS[@]}"; do
        if ! deploy_from_manifest "$manifest"; then
            deploy_failed=true
        fi
    done
    
    # Hook post-deploy
    run_hook "post-deploy"
    
    # Set final state
    if [[ "$deploy_failed" == "true" ]]; then
        DEPLOYMENT_STATE=$STATE_FAILED
        log_error "Deployment completed with errors"
        notify_deployment_result "failed"
        return 2
    else
        DEPLOYMENT_STATE=$STATE_SUCCESS
        log_info "${SYMBOL_SUCCESS} Deployment completed successfully"
        notify_deployment_result "success"
        return 0
    fi
}

# ==============================================================================
# MAIN
# ==============================================================================

main() {
    # Setup
    setup_traps
    
    # Inițializare configurare
    init_config "$@" || exit 1
    
    # Acquire lock (exceptând status și list)
    if [[ "$ACTION" != "status" && "$ACTION" != "list" ]]; then
        if ! acquire_lock; then
            die "Another deployment is in progress. Use 'status' to check." 5
        fi
    fi
    
    # Confirmă dacă nu e forțat
    if [[ "$ACTION" == "deploy" && "$FORCE" != "true" && "$DRY_RUN" != "true" ]]; then
        echo ""
        echo "About to deploy to: $ENVIRONMENT"
        echo "Services:   ${SERVICES[*]:-none}"
        echo "Containers: ${CONTAINERS[*]:-none}"
        echo "Manifests:  ${MANIFESTS[*]:-none}"
        echo ""
        
        if ! confirm "Proceed with deployment?"; then
            log_info "Deployment cancelled"
            exit 0
        fi
    fi
    
    # Execută acțiunea
    local exit_code=0
    
    case "$ACTION" in
        deploy)
            do_deploy
            exit_code=$?
            ;;
        rollback)
            do_rollback
            exit_code=$?
            ;;
        status)
            show_status
            ;;
        list)
            list_services
            ;;
        health)
            do_health_checks
            exit_code=$?
            ;;
        *)
            log_error "Unknown action: $ACTION"
            exit_code=1
            ;;
    esac
    
    # Generează raport final
    if [[ "$ACTION" == "deploy" || "$ACTION" == "rollback" ]]; then
        generate_deployment_report "${OUTPUT_FORMAT:-text}"
    fi
    
    exit $exit_code
}

# Run main
main "$@"
