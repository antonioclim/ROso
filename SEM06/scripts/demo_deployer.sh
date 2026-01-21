#!/bin/bash
#===============================================================================
# DEMO DEPLOYER - Demonstrație Interactivă Sistem Deployment
#===============================================================================
# Scop: Demonstrează funcționalitățile complete ale sistemului de deployment
# Utilizare: ./demo_deployer.sh [--auto|--interactive|--quick]
# Autor: Seminarul 11-12 CAPSTONE - Sisteme de Operare ASE București
#===============================================================================

set -euo pipefail

#-------------------------------------------------------------------------------
# CONSTANTE ȘI CONFIGURARE
#-------------------------------------------------------------------------------
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_DIR="${SCRIPT_DIR}/projects/deployer"
readonly DEMO_BASE="/tmp/deployer_demo_$$"
readonly DEMO_APPS="${DEMO_BASE}/applications"
readonly DEMO_DEPLOY="${DEMO_BASE}/deployed"
readonly DEMO_RELEASES="${DEMO_BASE}/releases"
readonly DEMO_LOGS="${DEMO_BASE}/logs"

# Culori ANSI
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly BOLD='\033[1m'
readonly DIM='\033[2m'
readonly NC='\033[0m'

# Variabile globale
DEMO_MODE="interactive"
DEMO_STEP=0
PAUSE_ENABLED=true

#-------------------------------------------------------------------------------
# FUNCȚII UTILITATE
#-------------------------------------------------------------------------------

print_banner() {
    clear
    echo -e "${MAGENTA}"
    cat << 'EOF'
    ╔══════════════════════════════════════════════════════════════════════╗
    ║                                                                      ║
    ║   ██████╗ ███████╗██████╗ ██╗      ██████╗ ██╗   ██╗███████╗██████╗  ║
    ║   ██╔══██╗██╔════╝██╔══██╗██║     ██╔═══██╗╚██╗ ██╔╝██╔════╝██╔══██╗ ║
    ║   ██║  ██║█████╗  ██████╔╝██║     ██║   ██║ ╚████╔╝ █████╗  ██████╔╝ ║
    ║   ██║  ██║██╔══╝  ██╔═══╝ ██║     ██║   ██║  ╚██╔╝  ██╔══╝  ██╔══██╗ ║
    ║   ██████╔╝███████╗██║     ███████╗╚██████╔╝   ██║   ███████╗██║  ██║ ║
    ║   ╚═════╝ ╚══════╝╚═╝     ╚══════╝ ╚═════╝    ╚═╝   ╚══════╝╚═╝  ╚═╝ ║
    ║                                                                      ║
    ║             SISTEM DE DEPLOYMENT AUTOMAT - DEMONSTRAȚIE              ║
    ║                    Seminarul 11-12 CAPSTONE                          ║
    ╚══════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

print_section() {
    local title="$1"
    local width=70
    
    echo ""
    echo -e "${MAGENTA}$(printf '═%.0s' $(seq 1 $width))${NC}"
    echo -e "${BOLD}${WHITE}  $title${NC}"
    echo -e "${MAGENTA}$(printf '═%.0s' $(seq 1 $width))${NC}"
    echo ""
}

print_step() {
    ((DEMO_STEP++))
    echo -e "\n${CYAN}[Pasul $DEMO_STEP]${NC} ${BOLD}$1${NC}\n"
}

print_info() {
    echo -e "${CYAN}ℹ${NC}  $1"
}

print_success() {
    echo -e "${GREEN}✓${NC}  $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC}  $1"
}

print_error() {
    echo -e "${RED}✗${NC}  $1"
}

print_command() {
    echo -e "${DIM}${WHITE}\$ $1${NC}"
}

print_progress() {
    local current=$1
    local total=$2
    local width=40
    local percent=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))
    
    printf "\r${CYAN}["
    printf "%${filled}s" '' | tr ' ' '█'
    printf "%${empty}s" '' | tr ' ' '░'
    printf "] ${percent}%%${NC}"
}

run_command() {
    local cmd="$1"
    local description="${2:-}"
    
    [[ -n "$description" ]] && print_info "$description"
    print_command "$cmd"
    echo ""
    
    eval "$cmd" 2>&1 | while IFS= read -r line; do
        echo -e "   ${DIM}$line${NC}"
    done
    
    local exit_code=${PIPESTATUS[0]}
    echo ""
    
    if [[ $exit_code -eq 0 ]]; then
        print_success "Comandă executată cu succes"
    else
        print_warning "Comandă terminată cu cod: $exit_code"
    fi
    
    return $exit_code
}

pause_demo() {
    if [[ "$PAUSE_ENABLED" == "true" ]]; then
        echo ""
        echo -e "${YELLOW}Apasă ENTER pentru a continua...${NC}"
        read -r
    else
        sleep 1
    fi
}

#-------------------------------------------------------------------------------
# SETUP ȘI CLEANUP
#-------------------------------------------------------------------------------

setup_demo_environment() {
    print_section "PREGĂTIRE MEDIU DEMONSTRAȚIE"
    
    print_step "Creare structură directoare demo"
    
    # Cleanup dacă există
    rm -rf "$DEMO_BASE"
    
    # Creare structură
    mkdir -p "$DEMO_APPS"/{webapp,api,worker}
    mkdir -p "$DEMO_DEPLOY"/{current,previous,shared}
    mkdir -p "$DEMO_RELEASES"
    mkdir -p "$DEMO_LOGS"
    
    print_success "Directoare create: $DEMO_BASE"
    
    # Creare aplicații demo
    print_step "Generare aplicații demonstrative"
    
    # WebApp - aplicație web simplă
    create_webapp_demo
    
    # API - serviciu REST
    create_api_demo
    
    # Worker - serviciu background
    create_worker_demo
    
    # Afișare structură
    print_step "Structura aplicațiilor demo"
    if command -v tree &>/dev/null; then
        tree -L 2 --dirsfirst "$DEMO_APPS"
    else
        find "$DEMO_APPS" -type f | head -20
    fi
    
    pause_demo
}

create_webapp_demo() {
    local app_dir="$DEMO_APPS/webapp"
    
    # index.html
    cat > "$app_dir/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="ro">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Demo WebApp - Deployment Test</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background: #f5f5f5; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #333; border-bottom: 2px solid #007bff; padding-bottom: 10px; }
        .info { background: #e7f3ff; padding: 15px; border-radius: 5px; margin: 20px 0; }
        .version { font-size: 24px; color: #28a745; font-weight: bold; }
        .timestamp { color: #666; font-size: 14px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Demo WebApp</h1>
        <div class="info">
            <p>Versiune: <span class="version">1.0.0</span></p>
            <p class="timestamp">Deployed: __DEPLOY_TIMESTAMP__</p>
            <p>Environment: __ENVIRONMENT__</p>
        </div>
        <h2>Funcționalități</h2>
        <ul>
            <li>Deployment automat</li>
            <li>Health checks</li>
            <li>Rollback support</li>
            <li>Blue-green deployment</li>
        </ul>
    </div>
</body>
</html>
EOF
    
    # config.json
    cat > "$app_dir/config.json" << 'EOF'
{
    "app": {
        "name": "demo-webapp",
        "version": "1.0.0",
        "port": 8080,
        "host": "0.0.0.0"
    },
    "database": {
        "host": "localhost",
        "port": 5432,
        "name": "webapp_db"
    },
    "features": {
        "cache": true,
        "compression": true,
        "logging": "info"
    }
}
EOF
    
    # server.py - simplu HTTP server
    cat > "$app_dir/server.py" << 'EOF'
#!/usr/bin/env python3
"""
Simple HTTP server for demo webapp
"""
import http.server
import socketserver
import json
import os
from datetime import datetime

PORT = int(os.environ.get('PORT', 8080))
VERSION = os.environ.get('APP_VERSION', '1.0.0')

class DemoHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/health':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            response = {
                'status': 'healthy',
                'version': VERSION,
                'timestamp': datetime.now().isoformat()
            }
            self.wfile.write(json.dumps(response).encode())
        elif self.path == '/version':
            self.send_response(200)
            self.send_header('Content-type', 'text/plain')
            self.end_headers()
            self.wfile.write(VERSION.encode())
        else:
            super().do_GET()

if __name__ == '__main__':
    with socketserver.TCPServer(("", PORT), DemoHandler) as httpd:
        print(f"Serving at port {PORT}")
        httpd.serve_forever()
EOF
    chmod +x "$app_dir/server.py"
    
    # Manifest deployment
    cat > "$app_dir/deploy.yaml" << 'EOF'
# Deployment manifest for webapp
name: demo-webapp
version: 1.0.0
type: web

deployment:
  strategy: rolling
  replicas: 2
  
health_check:
  type: http
  path: /health
  port: 8080
  interval: 30
  timeout: 10
  retries: 3

hooks:
  pre_deploy:
    - echo "Starting webapp deployment"
  post_deploy:
    - echo "Webapp deployed successfully"
  
files:
  - src: index.html
    dest: /var/www/webapp/
  - src: config.json
    dest: /etc/webapp/
  - src: server.py
    dest: /opt/webapp/

env:
  APP_VERSION: "1.0.0"
  NODE_ENV: production
  PORT: 8080
EOF
    
    print_success "WebApp creat: $app_dir"
}

create_api_demo() {
    local app_dir="$DEMO_APPS/api"
    
    # api.py
    cat > "$app_dir/api.py" << 'EOF'
#!/usr/bin/env python3
"""
Demo REST API for deployment testing
"""
import json
import os
from http.server import HTTPServer, BaseHTTPRequestHandler
from datetime import datetime

VERSION = os.environ.get('API_VERSION', '1.0.0')
PORT = int(os.environ.get('PORT', 3000))

# In-memory data store
DATA = {
    'items': [
        {'id': 1, 'name': 'Item 1', 'value': 100},
        {'id': 2, 'name': 'Item 2', 'value': 200},
    ]
}

class APIHandler(BaseHTTPRequestHandler):
    def _send_json(self, data, status=200):
        self.send_response(status)
        self.send_header('Content-Type', 'application/json')
        self.send_header('X-API-Version', VERSION)
        self.end_headers()
        self.wfile.write(json.dumps(data, indent=2).encode())
    
    def do_GET(self):
        if self.path == '/health':
            self._send_json({'status': 'healthy', 'version': VERSION})
        elif self.path == '/api/items':
            self._send_json(DATA['items'])
        elif self.path == '/api/status':
            self._send_json({
                'version': VERSION,
                'uptime': 'demo',
                'timestamp': datetime.now().isoformat()
            })
        else:
            self._send_json({'error': 'Not found'}, 404)
    
    def log_message(self, format, *args):
        print(f"[{datetime.now().isoformat()}] {args[0]}")

if __name__ == '__main__':
    server = HTTPServer(('0.0.0.0', PORT), APIHandler)
    print(f"API server running on port {PORT}")
    server.serve_forever()
EOF
    chmod +x "$app_dir/api.py"
    
    # config
    cat > "$app_dir/config.yaml" << 'EOF'
api:
  name: demo-api
  version: 1.0.0
  port: 3000
  
database:
  connection_string: "postgresql://localhost:5432/api_db"
  pool_size: 10
  
rate_limiting:
  enabled: true
  requests_per_minute: 100
  
cors:
  enabled: true
  origins:
    - http://localhost:8080
    - https://example.com
EOF
    
    # Manifest
    cat > "$app_dir/deploy.yaml" << 'EOF'
name: demo-api
version: 1.0.0
type: service

deployment:
  strategy: blue-green
  
health_check:
  type: http
  path: /health
  port: 3000
  interval: 15
  timeout: 5
  retries: 5

service:
  type: systemd
  name: demo-api
  user: api
  group: api

files:
  - src: api.py
    dest: /opt/api/
    mode: "0755"
  - src: config.yaml
    dest: /etc/api/
    mode: "0644"

env:
  API_VERSION: "1.0.0"
  PORT: 3000
  LOG_LEVEL: info
EOF
    
    print_success "API creat: $app_dir"
}

create_worker_demo() {
    local app_dir="$DEMO_APPS/worker"
    
    # worker.sh
    cat > "$app_dir/worker.sh" << 'EOF'
#!/bin/bash
# Demo background worker
# Procesează joburi dintr-o coadă simulată

VERSION="${WORKER_VERSION:-1.0.0}"
QUEUE_DIR="${QUEUE_DIR:-/tmp/worker_queue}"
LOG_FILE="${LOG_FILE:-/var/log/worker.log}"
PID_FILE="${PID_FILE:-/var/run/worker.pid}"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

process_job() {
    local job_file="$1"
    local job_id=$(basename "$job_file" .job)
    
    log "Processing job: $job_id"
    
    # Simulare procesare
    sleep 1
    
    # Marcare completă
    mv "$job_file" "${job_file}.done" 2>/dev/null || true
    log "Completed job: $job_id"
}

main() {
    log "Worker v$VERSION starting..."
    echo $$ > "$PID_FILE"
    
    mkdir -p "$QUEUE_DIR"
    
    while true; do
        # Procesare joburi disponibile
        for job in "$QUEUE_DIR"/*.job; do
            [[ -f "$job" ]] && process_job "$job"
        done
        
        # Așteptare înainte de următoarea verificare
        sleep 5
    done
}

# Cleanup la exit
trap 'log "Worker stopping..."; rm -f "$PID_FILE"' EXIT

main
EOF
    chmod +x "$app_dir/worker.sh"
    
    # Systemd unit file
    cat > "$app_dir/worker.service" << 'EOF'
[Unit]
Description=Demo Background Worker
After=network.target

[Service]
Type=simple
User=worker
Group=worker
WorkingDirectory=/opt/worker
ExecStart=/opt/worker/worker.sh
Restart=always
RestartSec=10
Environment=WORKER_VERSION=1.0.0
Environment=QUEUE_DIR=/var/spool/worker
Environment=LOG_FILE=/var/log/worker/worker.log

[Install]
WantedBy=multi-user.target
EOF
    
    # Manifest
    cat > "$app_dir/deploy.yaml" << 'EOF'
name: demo-worker
version: 1.0.0
type: worker

deployment:
  strategy: rolling
  stop_timeout: 30
  
health_check:
  type: process
  name: worker.sh
  interval: 60

service:
  type: systemd
  name: demo-worker
  user: worker
  group: worker

files:
  - src: worker.sh
    dest: /opt/worker/
    mode: "0755"
  - src: worker.service
    dest: /etc/systemd/system/
    mode: "0644"

directories:
  - path: /var/spool/worker
    mode: "0755"
    owner: worker
  - path: /var/log/worker
    mode: "0755"
    owner: worker

env:
  WORKER_VERSION: "1.0.0"
  LOG_LEVEL: info
EOF
    
    print_success "Worker creat: $app_dir"
}

cleanup_demo() {
    print_section "CURĂȚARE MEDIU DEMO"
    
    if [[ -d "$DEMO_BASE" ]]; then
        rm -rf "$DEMO_BASE"
        print_success "Director demo șters: $DEMO_BASE"
    fi
}

#-------------------------------------------------------------------------------
# DEMONSTRAȚII FUNCȚIONALITĂȚI
#-------------------------------------------------------------------------------

demo_basic_deployment() {
    print_section "DEMONSTRAȚIE 1: DEPLOYMENT SIMPLU"
    
    print_info "Deployment simplu al unei aplicații web"
    print_info "Pași: prepare → deploy → verify"
    
    pause_demo
    
    local app_src="$DEMO_APPS/webapp"
    local app_dest="$DEMO_DEPLOY/current/webapp"
    local release_dir="$DEMO_RELEASES/webapp_v1.0.0_$(date +%Y%m%d_%H%M%S)"
    
    # Prepare
    print_step "Pregătire deployment"
    
    mkdir -p "$release_dir"
    mkdir -p "$app_dest"
    
    print_info "Creare release: $release_dir"
    cp -r "$app_src"/* "$release_dir/"
    
    # Înlocuire placeholders
    sed -i "s/__DEPLOY_TIMESTAMP__/$(date)/g" "$release_dir/index.html"
    sed -i "s/__ENVIRONMENT__/production/g" "$release_dir/index.html"
    
    print_success "Fișiere pregătite pentru deployment"
    
    # Deploy
    print_step "Executare deployment"
    
    for i in {1..5}; do
        print_progress $i 5
        sleep 0.3
    done
    echo ""
    
    # Copiere fișiere
    cp -r "$release_dir"/* "$app_dest/"
    
    print_success "Aplicație deployed în: $app_dest"
    
    # Verify
    print_step "Verificare deployment"
    
    echo "Fișiere deployate:"
    ls -la "$app_dest/"
    
    echo ""
    print_info "Conținut index.html (primele 10 linii):"
    head -10 "$app_dest/index.html"
    
    pause_demo
}

demo_health_checks() {
    print_section "DEMONSTRAȚIE 2: HEALTH CHECKS"
    
    print_info "Tipuri de health checks suportate:"
    print_info "  • HTTP - verificare endpoint /health"
    print_info "  • TCP - verificare port deschis"
    print_info "  • Process - verificare proces activ"
    print_info "  • Command - executare comandă personalizată"
    
    pause_demo
    
    # Simulare health checks
    print_step "Simulare HTTP Health Check"
    
    cat << 'EOF'
Configurare health check:
  type: http
  path: /health
  port: 8080
  interval: 30
  timeout: 10
  retries: 3
EOF
    
    echo ""
    print_info "Simulare request către /health..."
    
    # Simulare răspuns
    local health_response='{
  "status": "healthy",
  "version": "1.0.0",
  "checks": {
    "database": "ok",
    "cache": "ok",
    "disk": "ok"
  },
  "timestamp": "'$(date -Iseconds)'"
}'
    
    echo -e "${GREEN}$health_response${NC}"
    print_success "Health check passed"
    
    # TCP check
    print_step "Simulare TCP Health Check"
    
    cat << 'EOF'
Configurare:
  type: tcp
  port: 3000
  timeout: 5
EOF
    
    echo ""
    print_info "Verificare port 3000..."
    print_success "Port 3000 - OPEN (simulat)"
    
    # Process check
    print_step "Simulare Process Health Check"
    
    cat << 'EOF'
Configurare:
  type: process
  name: worker.sh
  interval: 60
EOF
    
    echo ""
    print_info "Căutare proces worker.sh..."
    
    # Simulare output ps
    echo "  PID TTY      TIME CMD"
    echo "12345 ?    00:00:01 /bin/bash /opt/worker/worker.sh"
    print_success "Proces găsit: PID 12345"
    
    # Health check cu retry
    print_step "Demonstrație retry logic"
    
    print_info "Simulare health check cu eșec temporar..."
    echo ""
    
    for attempt in {1..3}; do
        if [[ $attempt -lt 3 ]]; then
            print_warning "Attempt $attempt/3: Connection timeout"
            sleep 0.5
        else
            print_success "Attempt $attempt/3: Health check passed"
        fi
    done
    
    print_info "Health check reușit după 3 încercări"
    
    pause_demo
}

demo_rollback() {
    print_section "DEMONSTRAȚIE 3: ROLLBACK"
    
    print_info "Rollback permite revenirea la o versiune anterioară"
    print_info "Scenarii: deployment eșuat, bug în producție, etc."
    
    pause_demo
    
    # Setup versiuni
    print_step "Pregătire scenariului rollback"
    
    local v1_dir="$DEMO_RELEASES/webapp_v1.0.0"
    local v2_dir="$DEMO_RELEASES/webapp_v2.0.0"
    local current_link="$DEMO_DEPLOY/current"
    
    mkdir -p "$v1_dir" "$v2_dir"
    
    echo "Version 1.0.0 - Stable" > "$v1_dir/version.txt"
    echo "Version 2.0.0 - Buggy" > "$v2_dir/version.txt"
    
    # Deploy v1
    print_step "Deploy versiune 1.0.0 (stabilă)"
    rm -rf "$current_link"
    ln -sf "$v1_dir" "$current_link"
    
    print_success "v1.0.0 deployed"
    echo "Current: $(readlink -f "$current_link")"
    cat "$current_link/version.txt"
    
    # Deploy v2
    print_step "Deploy versiune 2.0.0 (cu bug)"
    rm -rf "$current_link"
    ln -sf "$v2_dir" "$current_link"
    
    print_success "v2.0.0 deployed"
    cat "$current_link/version.txt"
    
    # Simulare health check fail
    print_step "Health check detectează problemă"
    
    print_warning "Health check FAILED!"
    print_warning "Response: HTTP 500 Internal Server Error"
    print_warning "Deployment marcat ca FAILED"
    
    # Rollback
    print_step "Executare ROLLBACK la v1.0.0"
    
    for i in {1..3}; do
        print_progress $i 3
        sleep 0.3
    done
    echo ""
    
    rm -rf "$current_link"
    ln -sf "$v1_dir" "$current_link"
    
    print_success "Rollback completat!"
    echo "Current: $(readlink -f "$current_link")"
    cat "$current_link/version.txt"
    
    # Verificare post-rollback
    print_step "Verificare post-rollback"
    print_success "Health check: PASSED"
    print_success "Aplicația funcționează corect pe v1.0.0"
    
    pause_demo
}

demo_blue_green() {
    print_section "DEMONSTRAȚIE 4: BLUE-GREEN DEPLOYMENT"
    
    print_info "Blue-Green: două medii identice pentru zero-downtime"
    print_info "  • Blue = mediu curent activ"
    print_info "  • Green = mediu pentru noua versiune"
    print_info "  • Switch instant între medii"
    
    pause_demo
    
    # Setup blue-green
    print_step "Setup medii Blue și Green"
    
    local blue_dir="$DEMO_DEPLOY/blue"
    local green_dir="$DEMO_DEPLOY/green"
    local live_link="$DEMO_DEPLOY/live"
    
    mkdir -p "$blue_dir" "$green_dir"
    
    echo "Blue Environment - v1.0.0" > "$blue_dir/app.txt"
    echo "Green Environment - v2.0.0" > "$green_dir/app.txt"
    
    # Initial: Blue este live
    ln -sf "$blue_dir" "$live_link"
    
    echo ""
    echo -e "${BLUE}┌─────────────────────────────────────────────────────┐${NC}"
    echo -e "${BLUE}│              STARE INIȚIALĂ                         │${NC}"
    echo -e "${BLUE}├─────────────────────────────────────────────────────┤${NC}"
    echo -e "${BLUE}│  ${NC}${GREEN}[BLUE - v1.0.0]${NC} ◄── LIVE                          ${BLUE}│${NC}"
    echo -e "${BLUE}│  ${NC}${DIM}[GREEN - idle]${NC}                                     ${BLUE}│${NC}"
    echo -e "${BLUE}└─────────────────────────────────────────────────────┘${NC}"
    
    # Deploy to green
    print_step "Deploy v2.0.0 în mediul Green"
    
    print_info "Deployment în curs..."
    for i in {1..5}; do
        print_progress $i 5
        sleep 0.2
    done
    echo ""
    
    echo "Green Environment - v2.0.0 DEPLOYED" > "$green_dir/app.txt"
    print_success "v2.0.0 deployed în Green (Blue încă activ)"
    
    echo ""
    echo -e "${BLUE}┌─────────────────────────────────────────────────────┐${NC}"
    echo -e "${BLUE}│              DUPĂ DEPLOY ÎN GREEN                   │${NC}"
    echo -e "${BLUE}├─────────────────────────────────────────────────────┤${NC}"
    echo -e "${BLUE}│  ${NC}${GREEN}[BLUE - v1.0.0]${NC} ◄── LIVE                          ${BLUE}│${NC}"
    echo -e "${BLUE}│  ${NC}${YELLOW}[GREEN - v2.0.0 ready]${NC}                            ${BLUE}│${NC}"
    echo -e "${BLUE}└─────────────────────────────────────────────────────┘${NC}"
    
    # Health check on green
    print_step "Health check pe Green"
    print_success "Green environment: healthy"
    
    # Switch to green
    print_step "SWITCH: Blue → Green"
    
    print_info "Switching traffic..."
    sleep 0.5
    
    rm -f "$live_link"
    ln -sf "$green_dir" "$live_link"
    
    echo ""
    echo -e "${BLUE}┌─────────────────────────────────────────────────────┐${NC}"
    echo -e "${BLUE}│              DUPĂ SWITCH                            │${NC}"
    echo -e "${BLUE}├─────────────────────────────────────────────────────┤${NC}"
    echo -e "${BLUE}│  ${NC}${DIM}[BLUE - v1.0.0 standby]${NC}                           ${BLUE}│${NC}"
    echo -e "${BLUE}│  ${NC}${GREEN}[GREEN - v2.0.0]${NC} ◄── LIVE                         ${BLUE}│${NC}"
    echo -e "${BLUE}└─────────────────────────────────────────────────────┘${NC}"
    
    print_success "Switch completat! Zero downtime."
    print_info "Blue păstrat pentru rollback instant dacă e necesar"
    
    pause_demo
}

demo_canary_deployment() {
    print_section "DEMONSTRAȚIE 5: CANARY DEPLOYMENT"
    
    print_info "Canary: deployment gradual cu monitorizare"
    print_info "  • 10% traffic → noua versiune"
    print_info "  • Monitorizare erori"
    print_info "  • Creștere graduală sau rollback"
    
    pause_demo
    
    print_step "Deployment canary: 10% traffic"
    
    echo ""
    echo -e "Traffic distribution:"
    echo -e "  v1.0.0: ${GREEN}██████████████████████████████████████${NC} 90%"
    echo -e "  v2.0.0: ${YELLOW}████${NC}                                   10%"
    
    print_info "Monitorizare metrici pentru 5 minute..."
    
    for i in {1..5}; do
        sleep 0.5
        echo -e "  Minute $i: Error rate 0.1%, Latency p99: 45ms ${GREEN}✓${NC}"
    done
    
    # Increase to 50%
    print_step "Creștere la 50% traffic"
    
    echo ""
    echo -e "Traffic distribution:"
    echo -e "  v1.0.0: ${GREEN}████████████████████${NC}                   50%"
    echo -e "  v2.0.0: ${YELLOW}████████████████████${NC}                   50%"
    
    for i in {1..3}; do
        sleep 0.5
        echo -e "  Minute $i: Error rate 0.2%, Latency p99: 48ms ${GREEN}✓${NC}"
    done
    
    # Full rollout
    print_step "Rollout complet: 100%"
    
    echo ""
    echo -e "Traffic distribution:"
    echo -e "  v1.0.0:                                        0%"
    echo -e "  v2.0.0: ${GREEN}████████████████████████████████████████${NC} 100%"
    
    print_success "Canary deployment completat cu succes!"
    
    pause_demo
}

demo_hooks_system() {
    print_section "DEMONSTRAȚIE 6: SISTEM DE HOOKS"
    
    print_info "Hooks permit executarea de acțiuni la momente cheie:"
    print_info "  • pre_deploy - înainte de deployment"
    print_info "  • post_deploy - după deployment reușit"
    print_info "  • on_rollback - la rollback"
    print_info "  • on_failure - la eșec"
    
    pause_demo
    
    # Creare hooks demo
    local hooks_dir="$DEMO_BASE/hooks"
    mkdir -p "$hooks_dir"
    
    print_step "Creare hooks demonstrative"
    
    # Pre-deploy hook
    cat > "$hooks_dir/pre_deploy.sh" << 'EOF'
#!/bin/bash
echo "🔧 Pre-deploy: Running database migrations..."
sleep 1
echo "   Migration 001_create_users.sql - OK"
echo "   Migration 002_add_indexes.sql - OK"
echo "🔧 Pre-deploy: Clearing cache..."
sleep 0.5
echo "   Cache cleared successfully"
exit 0
EOF
    chmod +x "$hooks_dir/pre_deploy.sh"
    
    # Post-deploy hook
    cat > "$hooks_dir/post_deploy.sh" << 'EOF'
#!/bin/bash
echo "📧 Post-deploy: Sending notification..."
sleep 0.5
echo "   Slack notification sent to #deployments"
echo "📊 Post-deploy: Updating monitoring..."
sleep 0.5
echo "   Datadog deployment marker created"
exit 0
EOF
    chmod +x "$hooks_dir/post_deploy.sh"
    
    print_success "Hooks create în: $hooks_dir"
    
    # Simulare deployment cu hooks
    print_step "Simulare deployment cu hooks"
    
    echo ""
    echo -e "${YELLOW}▶ Executare pre_deploy hook${NC}"
    bash "$hooks_dir/pre_deploy.sh"
    
    echo ""
    echo -e "${CYAN}▶ Deployment în curs...${NC}"
    for i in {1..3}; do
        print_progress $i 3
        sleep 0.3
    done
    echo ""
    print_success "Deployment completat"
    
    echo ""
    echo -e "${YELLOW}▶ Executare post_deploy hook${NC}"
    bash "$hooks_dir/post_deploy.sh"
    
    print_success "Toate hooks executate cu succes"
    
    pause_demo
}

demo_manifest_deployment() {
    print_section "DEMONSTRAȚIE 7: DEPLOYMENT DIN MANIFEST"
    
    print_info "Manifest YAML definește complet deployment-ul"
    print_info "Automatizare completă bazată pe configurare"
    
    pause_demo
    
    print_step "Exemplu manifest deployment"
    
    cat << 'EOF'
# deployment.yaml
name: myapp
version: 2.1.0
type: web

deployment:
  strategy: rolling
  replicas: 3
  max_unavailable: 1
  
health_check:
  type: http
  path: /health
  port: 8080
  initial_delay: 30
  interval: 10
  timeout: 5
  success_threshold: 1
  failure_threshold: 3

resources:
  cpu: 500m
  memory: 512Mi

files:
  - src: app/
    dest: /opt/myapp/
    mode: "0755"
  - src: config/app.yaml
    dest: /etc/myapp/config.yaml
    mode: "0644"

env:
  NODE_ENV: production
  LOG_LEVEL: info
  
secrets:
  - name: DATABASE_URL
    source: vault
    path: secret/myapp/db

hooks:
  pre_deploy:
    - name: backup-db
      command: /scripts/backup-db.sh
    - name: migrate
      command: /scripts/migrate.sh
  post_deploy:
    - name: warm-cache
      command: /scripts/warm-cache.sh
  on_rollback:
    - name: restore-db
      command: /scripts/restore-db.sh
EOF
    
    # Parsare simulată
    print_step "Parsare și validare manifest"
    
    echo ""
    print_info "Validare structură... OK"
    print_info "Verificare fișiere sursă... OK"
    print_info "Validare health check config... OK"
    print_info "Rezolvare secrets din Vault... OK"
    
    print_success "Manifest valid și pregătit pentru deployment"
    
    # Executare
    print_step "Executare deployment din manifest"
    
    echo ""
    echo "  [1/6] Running pre_deploy hooks..."
    sleep 0.3
    echo "  [2/6] Deploying files..."
    sleep 0.3
    echo "  [3/6] Setting permissions..."
    sleep 0.3
    echo "  [4/6] Configuring environment..."
    sleep 0.3
    echo "  [5/6] Starting service..."
    sleep 0.3
    echo "  [6/6] Running health checks..."
    sleep 0.5
    
    print_success "Deployment din manifest completat!"
    
    pause_demo
}

demo_status_reporting() {
    print_section "DEMONSTRAȚIE 8: RAPORTARE STATUS"
    
    print_info "Sistem de raportare pentru vizibilitate deployment-uri"
    
    pause_demo
    
    print_step "Status deployment-uri active"
    
    echo ""
    printf "%-15s %-10s %-12s %-20s %s\n" "APPLICATION" "VERSION" "STATUS" "DEPLOYED" "HEALTH"
    printf "%-15s %-10s %-12s %-20s %s\n" "-----------" "-------" "------" "--------" "------"
    printf "%-15s %-10s ${GREEN}%-12s${NC} %-20s ${GREEN}%s${NC}\n" "webapp" "2.1.0" "deployed" "2024-01-15 10:30" "healthy"
    printf "%-15s %-10s ${GREEN}%-12s${NC} %-20s ${GREEN}%s${NC}\n" "api" "3.0.0" "deployed" "2024-01-15 09:15" "healthy"
    printf "%-15s %-10s ${YELLOW}%-12s${NC} %-20s ${YELLOW}%s${NC}\n" "worker" "1.5.0" "deploying" "2024-01-15 11:00" "pending"
    printf "%-15s %-10s ${RED}%-12s${NC} %-20s ${RED}%s${NC}\n" "scheduler" "2.0.0" "failed" "2024-01-15 08:00" "unhealthy"
    
    # Deployment history
    print_step "Istoric deployment-uri"
    
    echo ""
    printf "%-5s %-15s %-10s %-12s %-20s %s\n" "ID" "APPLICATION" "VERSION" "RESULT" "TIMESTAMP" "DURATION"
    printf "%-5s %-15s %-10s %-12s %-20s %s\n" "--" "-----------" "-------" "------" "---------" "--------"
    printf "%-5s %-15s %-10s ${GREEN}%-12s${NC} %-20s %s\n" "125" "webapp" "2.1.0" "success" "2024-01-15 10:30" "45s"
    printf "%-5s %-15s %-10s ${GREEN}%-12s${NC} %-20s %s\n" "124" "api" "3.0.0" "success" "2024-01-15 09:15" "1m 12s"
    printf "%-5s %-15s %-10s ${RED}%-12s${NC} %-20s %s\n" "123" "scheduler" "2.0.0" "failed" "2024-01-15 08:00" "2m 30s"
    printf "%-5s %-15s %-10s ${YELLOW}%-12s${NC} %-20s %s\n" "122" "webapp" "2.0.0" "rollback" "2024-01-14 15:00" "30s"
    
    # JSON output
    print_step "Output JSON (pentru integrare)"
    
    cat << 'EOF'
{
  "deployments": [
    {
      "id": 125,
      "application": "webapp",
      "version": "2.1.0",
      "status": "success",
      "timestamp": "2024-01-15T10:30:00Z",
      "duration_seconds": 45,
      "health": "healthy"
    }
  ],
  "summary": {
    "total": 4,
    "successful": 2,
    "failed": 1,
    "in_progress": 1
  }
}
EOF
    
    pause_demo
}

#-------------------------------------------------------------------------------
# MAIN
#-------------------------------------------------------------------------------

show_summary() {
    print_section "SUMAR DEMONSTRAȚIE"
    
    echo -e "${GREEN}Funcționalități demonstrate:${NC}"
    echo ""
    echo "  1. ✓ Deployment simplu - copiere fișiere și configurare"
    echo "  2. ✓ Health checks - HTTP, TCP, Process, Command"
    echo "  3. ✓ Rollback - revenire la versiuni anterioare"
    echo "  4. ✓ Blue-Green - zero-downtime deployment"
    echo "  5. ✓ Canary - deployment gradual cu monitorizare"
    echo "  6. ✓ Hooks - acțiuni pre/post deployment"
    echo "  7. ✓ Manifest - deployment declarativ YAML"
    echo "  8. ✓ Status reporting - vizibilitate și istoric"
    echo ""
    
    print_info "Director demo: $DEMO_BASE"
    print_info "Aplicații în: $DEMO_APPS"
}

show_help() {
    echo "Utilizare: $(basename "$0") [OPȚIUNI]"
    echo ""
    echo "Opțiuni:"
    echo "  --auto        Mod automat fără pauze"
    echo "  --interactive Mod interactiv cu pauze (implicit)"
    echo "  --quick       Demonstrație rapidă"
    echo "  --demo N      Execută doar demonstrația N (1-8)"
    echo "  --help        Afișează acest ajutor"
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --auto)
                PAUSE_ENABLED=false
                shift
                ;;
            --interactive)
                PAUSE_ENABLED=true
                shift
                ;;
            --quick)
                DEMO_MODE="quick"
                PAUSE_ENABLED=false
                shift
                ;;
            --demo)
                DEMO_MODE="single"
                SINGLE_DEMO="${2:-1}"
                shift 2
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                print_error "Opțiune necunoscută: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

run_single_demo() {
    local demo_num="$1"
    
    case "$demo_num" in
        1) demo_basic_deployment ;;
        2) demo_health_checks ;;
        3) demo_rollback ;;
        4) demo_blue_green ;;
        5) demo_canary_deployment ;;
        6) demo_hooks_system ;;
        7) demo_manifest_deployment ;;
        8) demo_status_reporting ;;
        *)
            print_error "Demonstrație invalidă: $demo_num (1-8)"
            exit 1
            ;;
    esac
}

main() {
    parse_args "$@"
    
    print_banner
    
    # Trap pentru cleanup
    trap cleanup_demo EXIT
    
    setup_demo_environment
    
    if [[ "$DEMO_MODE" == "single" ]]; then
        run_single_demo "$SINGLE_DEMO"
    elif [[ "$DEMO_MODE" == "quick" ]]; then
        demo_basic_deployment
        demo_health_checks
        demo_blue_green
    else
        # Toate demonstrațiile
        demo_basic_deployment
        demo_health_checks
        demo_rollback
        demo_blue_green
        demo_canary_deployment
        demo_hooks_system
        demo_manifest_deployment
        demo_status_reporting
    fi
    
    show_summary
    
    echo ""
    print_success "Demonstrație completă!"
    echo ""
}

main "$@"
