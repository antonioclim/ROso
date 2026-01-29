# SysDeployer - Sistem Avansat de Deployment

Proiect CAPSTONE - Seminar 6 Sisteme de Operare

SysDeployer este un sistem complet de deployment pentru aplicații și servicii, implementat în Bash. Suportă multiple strategii de deployment, management servicii systemd, containere Docker, health checks avansate, și rollback automat.

## Cuprins

- [Caracteristici](#-caracteristici)
- [Cerințe Sistem](#-cerințe-sistem)
- [Instalare](#-instalare)
- [Utilizare Rapidă](#-utilizare-rapidă)
- [Acțiuni Disponibile](#-acțiuni-disponibile)
- [Configurare](#-configurare)
- [Strategii de Deployment](#-strategii-de-deployment)
- [Health Checks](#-health-checks)
- [Hooks System](#-hooks-system)
- [Manifest-Based Deployment](#-manifest-based-deployment)
- [Rollback](#-rollback)
- [Exemple Avansate](#-exemple-avansate)
- [Arhitectură](#-arhitectură)
- [Testare](#-testare)
- [Troubleshooting](#-troubleshooting)

## Caracteristici

### Core Features
- Multiple Deployment Strategies: Rolling, Blue-Green, Canary
- Service Management: Suport nativ systemd (start, stop, restart, enable)
- Container Support: Docker containers cu build, pull, run, stop
- Health Checks: HTTP, TCP, Process, Custom Command
- Automatic Rollback: Revenire automată la versiunea anterioară la eșec
- Version Management: Tracking și management versiuni deployments

### Advanced Features
- Hooks System: Pre/post hooks pentru fiecare fază de deployment
- Manifest Deployment: Deployment declarativ din fișiere YAML
- Parallel Execution: Suport pentru deployment paralel (configurable)
- Notifications: Email și Slack pentru status deployment
- Logging complet: Multi-nivel cu rotație automată
- Lock Management: Prevenire deployments concurente pe același serviciu

## Cerințe Sistem

### Obligatorii
- **Bash** >= 4.0
- **coreutils**: date, mkdir, cp, mv, rm, cat, etc.
- **systemd** (pentru management servicii) sau alternativ
- **curl** (pentru health checks HTTP și notificări)

### Opționale
- Docker >= 20.0 (pentru containere)
- **jq** (pentru procesare JSON)
- **yq** sau **python3-yaml** (pentru manifest YAML)
- nc/netcat (pentru health checks TCP)
- mail/sendmail (pentru notificări email)

### Verificare Cerințe
```bash
# Verificare completă
./deployer.sh --check-deps

# Verificare specifică
command -v systemctl && echo "systemd: OK"
command -v docker && echo "docker: OK"
command -v curl && echo "curl: OK"
```

## Instalare

### Instalare Locală (Dezvoltare)
```bash
# Clonare sau copiere
cd deployer/

# Creare directoare necesare
mkdir -p var/{log,run,backups,deployments}
chmod +x deployer.sh bin/sysdeploy

# Testare
./deployer.sh --help
```

### Instalare Sistem
```bash
# Copiere în /opt
sudo mkdir -p /opt/deployer
sudo cp -r . /opt/deployer/
sudo chmod +x /opt/deployer/deployer.sh

# Creare symlink
sudo ln -sf /opt/deployer/bin/sysdeploy /usr/local/bin/sysdeploy

# Creare directoare runtime
sudo mkdir -p /var/log/deployer /var/run/deployer
sudo chown $USER:$USER /var/log/deployer /var/run/deployer
```

### Configurare Inițială
```bash
# Copiere configurare
sudo cp etc/deployer.conf /etc/deployer/deployer.conf

# Editare configurare
sudo nano /etc/deployer/deployer.conf
```

## Utilizare Rapidă

### Deploy Serviciu
```bash
# Deploy aplicație web simplă
./deployer.sh deploy --service myapp \
    --source /path/to/myapp \
    --target /opt/myapp \
    --health-check http://localhost:8080/health

# Deploy cu strategie rolling
./deployer.sh deploy --service api \
    --source ./api-v2.0 \
    --strategy rolling \
    --instances 3
```

### Deploy Container
```bash
# Deploy container din image
./deployer.sh deploy --container webapp \
    --image nginx:latest \
    --port 8080:80 \
    --health-check http://localhost:8080/

# Deploy container cu build local
./deployer.sh deploy --container myapi \
    --build ./Dockerfile \
    --port 3000:3000 \
    --env NODE_ENV=production
```

### Status și Monitorizare
```bash
# Status serviciu specific
./deployer.sh status myapp

# Lista toate deployments
./deployer.sh list

# Health check global
./deployer.sh health
```

### Rollback
```bash
# Rollback la versiunea anterioară
./deployer.sh rollback myapp

# Rollback la versiune specifică
./deployer.sh rollback myapp --version 1.2.0
```

## Acțiuni Disponibile

| Acțiune | Descriere | Exemplu |
|---------|-----------|---------|
| `deploy` | Deploy nou serviciu/container | `deploy --service myapp --source ./app` |
| `rollback` | Revenire la versiune anterioară | `rollback myapp` |
| `status` | Status serviciu specific | `status myapp` |
| `list` | Lista toate deployments | `list [--format json]` |
| `health` | Verificare health toate serviciile | `health [--service myapp]` |
| `stop` | Oprire serviciu | `stop myapp` |
| `start` | Pornire serviciu | `start myapp` |
| `restart` | Restart serviciu | `restart myapp` |
| `logs` | Afișare logs deployment | `logs myapp [--lines 100]` |
| `cleanup` | Curățare deployments vechi | `cleanup [--keep 5]` |

## Configurare

### Fișier Configurare Principal
```bash
# /etc/deployer/deployer.conf

#---------------------------------------
# Directoare
#---------------------------------------
DEPLOY_BASE_DIR="/opt/deployments"
BACKUP_DIR="/var/backups/deployer"
LOG_DIR="/var/log/deployer"
RUN_DIR="/var/run/deployer"

#---------------------------------------
# Deployment Settings
#---------------------------------------
DEFAULT_STRATEGY="rolling"          # rolling, blue-green, canary
KEEP_VERSIONS=5                     # Versiuni păstrate pentru rollback
DEPLOYMENT_TIMEOUT=300              # Timeout deployment (secunde)
PARALLEL_DEPLOYMENTS=false          # Activare deployment paralel
MAX_PARALLEL=3                      # Max deployments simultane

#---------------------------------------
# Health Checks
#---------------------------------------
HEALTH_CHECK_ENABLED=true
HEALTH_CHECK_RETRIES=3
HEALTH_CHECK_INTERVAL=10            # Secunde între încercări
HEALTH_CHECK_TIMEOUT=30             # Timeout per check
AUTO_ROLLBACK_ON_FAILURE=true

#---------------------------------------
# Docker Settings
#---------------------------------------
DOCKER_REGISTRY=""                  # Registry privat (opțional)
DOCKER_NETWORK="bridge"
DOCKER_RESTART_POLICY="unless-stopped"
DOCKER_PULL_ALWAYS=false

#---------------------------------------
# Notificări
#---------------------------------------
NOTIFY_EMAIL=""                     # admin@example.com
NOTIFY_SLACK_WEBHOOK=""             # https://hooks.slack.com/...
NOTIFY_ON_SUCCESS=true
NOTIFY_ON_FAILURE=true

#---------------------------------------
# Logging
#---------------------------------------
LOG_LEVEL="INFO"                    # DEBUG, INFO, WARN, ERROR
LOG_MAX_SIZE=10485760               # 10MB
LOG_RETENTION_DAYS=30
```

### Variabile de Mediu
```bash
# Override configurare via environment
export DEPLOYER_CONFIG="/custom/path/deployer.conf"
export DEPLOYER_LOG_LEVEL="DEBUG"
export DEPLOYER_DRY_RUN="true"

./deployer.sh deploy --service myapp --source ./app
```

## Strategii de Deployment

### Rolling Deployment
Deployment gradual, înlocuind instanțe una câte una.

```bash
./deployer.sh deploy --service api \
    --strategy rolling \
    --instances 4 \
    --batch-size 1 \
    --batch-delay 30
```

Flux:
1. Oprire instanță 1 → Deploy v2 → Health check → OK
2. Oprire instanță 2 → Deploy v2 → Health check → OK
3. ... continuă până toate instanțele sunt actualizate

### Blue-Green Deployment
Două medii identice, switch instant între ele.

```bash
./deployer.sh deploy --service webapp \
    --strategy blue-green \
    --port 8080
```

Flux:
1. Deploy v2 în mediul "green" (inactiv)
2. Health checks pe green
3. Switch traffic de la "blue" la "green"
4. Blue devine backup pentru rollback

### Canary Deployment
Deployment gradual către un subset de utilizatori.

```bash
./deployer.sh deploy --service api \
    --strategy canary \
    --canary-percent 10 \
    --canary-duration 300
```

Flux:
1. Deploy v2 pe 10% din instanțe
2. Monitorizare 5 minute
3. Dacă OK → deploy complet
4. Dacă erori → rollback automat

## Health Checks

### HTTP Health Check
```bash
# GET request simplu
./deployer.sh deploy --service api \
    --health-check http://localhost:8080/health

# Cu parametri custom
./deployer.sh deploy --service api \
    --health-check http://localhost:8080/api/status \
    --health-expected-code 200 \
    --health-expected-body '"status":"ok"'
```

### TCP Health Check
```bash
# Verificare port deschis
./deployer.sh deploy --service db \
    --health-check tcp://localhost:5432 \
    --health-timeout 10
```

### Process Health Check
```bash
# Verificare proces rulează
./deployer.sh deploy --service worker \
    --health-check process://worker.py \
    --health-check-user www-data
```

### Custom Command Health Check
```bash
# Comandă custom
./deployer.sh deploy --service cache \
    --health-check 'command://redis-cli ping | grep PONG'
```

### Configurare Avansată Health Checks
```bash
# Multiple health checks
./deployer.sh deploy --service api \
    --health-check http://localhost:8080/health \
    --health-check tcp://localhost:8080 \
    --health-retries 5 \
    --health-interval 15 \
    --health-timeout 60
```

## Hooks System

Hooks permit executarea de scripturi custom în diferite faze ale deployment-ului.

### Hooks Disponibile
| Hook | Moment Execuție |
|------|-----------------|
| `pre-deploy` | Înainte de începerea deployment |
| `post-deploy` | După deployment reușit |
| `pre-start` | Înainte de pornirea serviciului |
| `post-start` | După pornirea serviciului |
| `pre-stop` | Înainte de oprirea serviciului |
| `post-stop` | După oprirea serviciului |
| `pre-rollback` | Înainte de rollback |
| `post-rollback` | După rollback |
| `on-failure` | La orice eroare |

### Creare Hook
```bash
# hooks/pre-deploy.sh
#!/bin/bash
SERVICE_NAME="$1"
VERSION="$2"
SOURCE_DIR="$3"

echo "Pregătire deployment pentru $SERVICE_NAME v$VERSION"

# Validare pre-deployment
if [[ ! -f "$SOURCE_DIR/package.json" ]]; then
    echo "EROARE: package.json lipsește!"
    exit 1
fi

# Notificare echipă
curl -X POST "$SLACK_WEBHOOK" \
    -d "{\"text\": \"🚀 Starting deployment: $SERVICE_NAME v$VERSION\"}"

exit 0
```

### Activare Hooks
```bash
# Hooks din director standard
./deployer.sh deploy --service api \
    --hooks-dir ./hooks

# Hook individual
./deployer.sh deploy --service api \
    --pre-deploy "./scripts/validate.sh" \
    --post-deploy "./scripts/notify.sh"
```

## Manifest-Based Deployment

Deploy complex folosind fișier manifest YAML.

### Exemplu Manifest
```yaml
# deploy-manifest.yaml
name: production-stack
version: "2.0.0"

services:
  api:
    type: service
    source: ./api
    target: /opt/api
    strategy: rolling
    instances: 3
    health_check:
      type: http
      url: http://localhost:3000/health
      interval: 10
      retries: 3
    hooks:
      pre_deploy: ./hooks/api-pre.sh
      post_deploy: ./hooks/api-post.sh
    env:
      NODE_ENV: production
      DB_HOST: localhost

  frontend:
    type: container
    image: myregistry/frontend:2.0.0
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /data/static:/usr/share/nginx/html
    health_check:
      type: http
      url: http://localhost:80/
    depends_on:
      - api

  worker:
    type: container
    build: ./worker/Dockerfile
    environment:
      - QUEUE_URL=redis://localhost:6379
    restart: always

settings:
  parallel: true
  max_parallel: 2
  notify:
    slack: https://hooks.slack.com/...
    on_success: true
    on_failure: true
```

### Utilizare Manifest
```bash
# Deploy din manifest
./deployer.sh deploy --manifest deploy-manifest.yaml

# Dry-run pentru validare
./deployer.sh deploy --manifest deploy-manifest.yaml --dry-run

# Deploy serviciu specific din manifest
./deployer.sh deploy --manifest deploy-manifest.yaml --only api
```

## ↩ Rollback

### Rollback Automat
Activat implicit când health check eșuează.

```bash
# Configurare
AUTO_ROLLBACK_ON_FAILURE=true

# La deployment, dacă health check eșuează:
# 1. Se detectează eșecul
# 2. Se restaurează versiunea anterioară
# 3. Se repornește serviciul
# 4. Se verifică health
# 5. Se notifică (dacă configurat)
```

### Rollback Manual
```bash
# Rollback la versiunea imediat anterioară
./deployer.sh rollback myapp

# Rollback la versiune specifică
./deployer.sh rollback myapp --version 1.5.2

# Lista versiuni disponibile pentru rollback
./deployer.sh list --service myapp --versions

# Rollback forțat (fără confirmare)
./deployer.sh rollback myapp --force
```

### Protecție Rollback
```bash
# Setare versiune ca "protejată" (nu poate fi ștearsă)
./deployer.sh protect myapp --version 1.0.0

# Dezactivare protecție
./deployer.sh unprotect myapp --version 1.0.0
```

## Exemple Avansate

### Deploy Complet Stack Web
```bash
#!/bin/bash
# deploy-stack.sh

# 1. Deploy database (fără health check inițial)
./deployer.sh deploy --service postgres \
    --container \
    --image postgres:15 \
    --port 5432:5432 \
    --env POSTGRES_PASSWORD=secret \
    --volume /data/postgres:/var/lib/postgresql/data \
    --health-check tcp://localhost:5432

# 2. Deploy Redis cache
./deployer.sh deploy --service redis \
    --container \
    --image redis:7-alpine \
    --port 6379:6379 \
    --health-check 'command://docker exec redis redis-cli ping'

# 3. Deploy API (depinde de DB și Redis)
./deployer.sh deploy --service api \
    --source ./api \
    --target /opt/api \
    --strategy rolling \
    --pre-deploy "./scripts/wait-for-deps.sh" \
    --health-check http://localhost:3000/health \
    --env DB_HOST=localhost \
    --env REDIS_URL=redis://localhost:6379

# 4. Deploy Frontend
./deployer.sh deploy --service frontend \
    --container \
    --build ./frontend/Dockerfile \
    --port 80:80 \
    --port 443:443 \
    --health-check http://localhost:80/
```

### CI/CD Integration
```bash
# .gitlab-ci.yml sau GitHub Actions
deploy_production:
  script:
    - |
      ./deployer.sh deploy \
        --service $SERVICE_NAME \
        --source ./dist \
        --strategy canary \
        --canary-percent 5 \
        --canary-duration 600 \
        --health-check $HEALTH_URL \
        --notify-slack $SLACK_WEBHOOK \
        --tag "build-$CI_PIPELINE_ID"
```

### Blue-Green cu Load Balancer
```bash
#!/bin/bash
# blue-green-deploy.sh

SERVICE="webapp"
NEW_VERSION="2.0.0"

# Deploy pe green
./deployer.sh deploy --service ${SERVICE}-green \
    --source ./app-${NEW_VERSION} \
    --health-check http://localhost:8081/health

# Verificare suplimentară
sleep 30
curl -f http://localhost:8081/health || exit 1

# Switch în load balancer (nginx)
sudo sed -i 's/upstream_blue/upstream_green/' /etc/nginx/sites-enabled/webapp
sudo nginx -t && sudo nginx -s reload

# Marcare blue ca backup
./deployer.sh tag ${SERVICE}-blue --role backup
./deployer.sh tag ${SERVICE}-green --role active

echo "Deployment complet. Green este activ."
```

## Arhitectură

### Structura Directoare
```
deployer/
├── deployer.sh           # Script principal (entry point)
├── bin/
│   └── sysdeploy         # Wrapper pentru instalare sistem
├── lib/
│   ├── core.sh           # Funcții core (logging, errors, locks)
│   ├── utils.sh          # Utilități (services, containers, health)
│   └── config.sh         # Parsare configurare și CLI
├── etc/
│   └── deployer.conf     # Configurare implicită
├── hooks/                # Hook scripts (opțional)
│   ├── pre-deploy.sh
│   └── post-deploy.sh
├── tests/
│   └── test_deployer.sh  # Suite teste
└── var/
    ├── log/              # Logs deployment
    ├── run/              # PID files, locks
    ├── backups/          # Backup-uri pentru rollback
    └── deployments/      # Metadata deployments
```

### Flux Deployment
```
┌─────────────────────────────────────────────────────────────┐
│                     DEPLOYMENT FLOW                          │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  [Start] ──► [Validate Config] ──► [Acquire Lock]           │
│                                          │                   │
│                                          ▼                   │
│  [Pre-Deploy Hook] ◄──────────── [Create Backup]            │
│         │                                                    │
│         ▼                                                    │
│  [Deploy Files/Container] ──► [Configure Service]           │
│                                          │                   │
│                                          ▼                   │
│  [Post-Deploy Hook] ◄──────────── [Start Service]           │
│         │                                                    │
│         ▼                                                    │
│  [Health Check] ──► [Success?] ──► YES ──► [Notify] ──► [End]│
│                          │                                   │
│                          NO                                  │
│                          │                                   │
│                          ▼                                   │
│  [Rollback] ◄───── [On-Failure Hook]                        │
│         │                                                    │
│         ▼                                                    │
│  [Restore Backup] ──► [Restart Service] ──► [Notify Failure]│
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Exit Codes
| Code | Semnificație |
|------|--------------|
| 0 | Succes |
| 1 | Eroare configurare/parametri |
| 2 | Deployment parțial (unele servicii eșuate) |
| 3 | Eroare fatală (deployment eșuat complet) |
| 4 | Health check eșuat |
| 5 | Lock existent (deployment în curs) |
| 6 | Rollback eșuat |
| 10 | Timeout depășit |

## Testare

### Rulare Teste Complete
```bash
cd deployer/
./tests/test_deployer.sh
```

### Teste Specifice
```bash
# Doar teste core
./tests/test_deployer.sh --filter core

# Doar teste integrare
./tests/test_deployer.sh --filter integration

# Mod verbose
./tests/test_deployer.sh --verbose
```

### Coverage
```bash
# Generare raport coverage
./tests/test_deployer.sh --coverage

# Output:
# Core Functions: 45/45 (100%)
# Utils Functions: 38/40 (95%)
# Config Functions: 22/22 (100%)
# Integration Tests: 15/15 (100%)
```

## Troubleshooting

### Probleme Comune

Deployment blocat
```bash
# Verificare lock
ls -la var/run/*.lock

# Eliberare lock manual (doar dacă sigur nu rulează)
./deployer.sh --force-unlock myapp

# Sau ștergere directă
rm var/run/myapp.lock
```

Health check timeout
```bash
# Creștere timeout
./deployer.sh deploy --service api \
    --health-timeout 120 \
    --health-retries 10

# Debug health check
curl -v http://localhost:8080/health
```

Permission denied
```bash
# Verificare permisiuni
ls -la /opt/deployments/
ls -la /var/log/deployer/

# Fixare
sudo chown -R $USER:$USER /opt/deployments
```

Container nu pornește
```bash
# Logs container
docker logs myapp 2>&1 | tail -50

# Verificare imagine
docker images | grep myapp

# Rebuild forțat
./deployer.sh deploy --container myapp \
    --build ./Dockerfile \
    --no-cache
```

### Debug Mode
```bash
# Activare debug complet
./deployer.sh --debug deploy --service api --source ./app

# Sau via environment
DEPLOYER_LOG_LEVEL=DEBUG ./deployer.sh deploy ...
```

### Logs
```bash
# Logs deployment curent
tail -f var/log/deployer.log

# Logs serviciu specific
./deployer.sh logs myapp --lines 200

# Logs cu filtru
grep "ERROR\|WARN" var/log/deployer.log
```

## Licență

Copyright (c) 2024 - Proiect Educațional  
Seminar 6 Sisteme de Operare  
Facultatea de Cibernetică, Statistică și Informatică Economică  
Academia de Studii Economice București

Acest proiect este destinat exclusiv scopurilor educaționale.

---

Versiune: 1.0.0  
Autor: Student CSIE  
Profesor: Ing. Dr. Antonio Clim
