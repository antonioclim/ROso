# M05: Deployment Pipeline

> **Nivel:** MEDIUM | **Timp estimat:** 25-35 ore | **Bonus K8s:** +10%

---

## Descriere

Pipeline complet de deployment pentru aplicații: build, test, package, deploy cu suport pentru multiple medii (dev/staging/prod), rollback automat și notificări. Simulează un mini CI/CD fără dependențe externe.

---

## Obiective de Învățare

- Concepte CI/CD și deployment automation
- Gestionarea mediilor (dev/staging/prod)
- Versionare și release management
- Rollback și disaster recovery
- Integrare cu Git hooks

---

## Cerințe Funcționale

### Obligatorii (pentru notă de trecere)

1. **Build stage**
   - Detectare automată tip proiect (Node, Python, Go, static)
   - Instalare dependențe
   - Compilare/bundling unde e cazul
   - Generare build artifacts

2. **Test stage**
   - Rulare teste automate
   - Generare raport coverage (dacă există)
   - Fail pipeline dacă testele pică

3. **Package stage**
   - Creare arhivă deployment (tar.gz)
   - Versionare automată (semver sau timestamp)
   - Generare manifest cu metadata

4. **Deploy stage**
   - Suport multiple medii (dev, staging, prod)
   - Backup înainte de deploy
   - Deploy atomic (symlink swap)
   - Health check post-deploy

5. **Rollback**
   - Rollback la versiunea anterioară
   - Istoric deployment-uri
   - Rollback automat la health check fail

### Opționale (pentru punctaj complet)

6. **Notificări** - Slack/email la succes/fail
7. **Git integration** - Deploy pe tag sau branch specific
8. **Blue-green deployment** - Zero downtime
9. **Canary releases** - Deploy gradual cu monitorizare
10. **Secrets management** - Variabile de mediu criptate

---

## Interfață CLI

```bash
./deploy.sh <command> [opțiuni]

Comenzi:
  init                  Inițializează configurarea pipeline
  build                 Rulează build stage
  test                  Rulează teste
  package               Creează deployment package
  deploy <env>          Deploy pe mediu (dev|staging|prod)
  rollback <env> [ver]  Rollback la versiune anterioară
  status <env>          Status deployment curent
  history <env>         Istoric deployment-uri
  promote <from> <to>   Promovează versiune între medii
  cleanup <env>         Șterge deployment-uri vechi

Opțiuni:
  -c, --config FILE     Fișier configurare (default: deploy.yaml)
  -v, --version VER     Versiune specifică pentru deploy
  -f, --force           Forțează deploy (skip confirmări)
  -n, --dry-run         Simulare fără modificări
  --no-backup           Skip backup înainte de deploy
  --no-tests            Skip teste (DOAR pentru dev)
  --tag TAG             Deploy git tag specific
  --branch BRANCH       Deploy branch specific

Exemple:
  ./deploy.sh init
  ./deploy.sh build && ./deploy.sh test && ./deploy.sh package
  ./deploy.sh deploy staging
  ./deploy.sh deploy prod -v 1.2.3
  ./deploy.sh rollback prod
  ./deploy.sh promote staging prod
```

---

## Exemple Output

### Build Output

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    DEPLOYMENT PIPELINE - BUILD STAGE                         ║
║                    Project: myapp | Type: nodejs                            ║
╚══════════════════════════════════════════════════════════════════════════════╝

[14:30:01] ▶ Starting build...
[14:30:01] ├─ Detecting project type... nodejs (package.json found)
[14:30:01] ├─ Node version: 20.10.0 ✓
[14:30:01] ├─ NPM version: 10.2.3 ✓
[14:30:02] ├─ Installing dependencies...
[14:30:15] │  └─ 847 packages installed
[14:30:15] ├─ Running build script (npm run build)...
[14:30:28] │  └─ Build output: dist/ (2.3 MB)
[14:30:28] ├─ Generating source maps... ✓
[14:30:29] └─ Build completed successfully

┌─────────────────────────────────────────────────────────────────────────────┐
│ BUILD SUMMARY                                                               │
├─────────────────────────────────────────────────────────────────────────────┤
│ Duration:        28 seconds                                                 │
│ Output size:     2.3 MB (dist/)                                            │
│ Git commit:      a1b2c3d "feat: add user dashboard"                        │
│ Git branch:      main                                                       │
│ Build number:    #142                                                       │
└─────────────────────────────────────────────────────────────────────────────┘

✓ BUILD PASSED - Ready for test stage
```

### Deploy Output

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    DEPLOYMENT PIPELINE - DEPLOY STAGE                        ║
║                    Environment: production                                   ║
╚══════════════════════════════════════════════════════════════════════════════╝

[15:00:01] ▶ Starting deployment to PRODUCTION
[15:00:01] │
[15:00:01] ├─ Pre-flight checks
[15:00:01] │  ├─ Package exists: myapp-1.2.3.tar.gz ✓
[15:00:01] │  ├─ Target accessible: prod-server.local ✓
[15:00:02] │  ├─ Disk space: 45 GB available ✓
[15:00:02] │  └─ Tests passed: build #142 ✓
[15:00:02] │
[15:00:02] ├─ Creating backup
[15:00:02] │  ├─ Current version: 1.2.2
[15:00:05] │  └─ Backup created: /var/backups/myapp/1.2.2_20250120.tar.gz
[15:00:05] │
[15:00:05] ├─ Deploying version 1.2.3
[15:00:05] │  ├─ Uploading package... 2.3 MB
[15:00:08] │  ├─ Extracting to /opt/myapp/releases/1.2.3/
[15:00:10] │  ├─ Installing dependencies...
[15:00:25] │  ├─ Running migrations... (2 pending)
[15:00:28] │  ├─ Updating symlink: /opt/myapp/current → releases/1.2.3
[15:00:28] │  └─ Restarting service...
[15:00:30] │
[15:00:30] ├─ Health checks
[15:00:30] │  ├─ Service status: active ✓
[15:00:31] │  ├─ HTTP health: 200 OK (45ms) ✓
[15:00:32] │  ├─ Database connection: OK ✓
[15:00:32] │  └─ All checks passed ✓
[15:00:32] │
[15:00:32] └─ Deployment completed successfully!

┌─────────────────────────────────────────────────────────────────────────────┐
│ DEPLOYMENT SUMMARY                                                          │
├─────────────────────────────────────────────────────────────────────────────┤
│ Environment:     production                                                 │
│ Version:         1.2.2 → 1.2.3                                             │
│ Duration:        31 seconds                                                 │
│ Deployed by:     antonio                                                    │
│ Rollback:        ./deploy.sh rollback prod 1.2.2                           │
└─────────────────────────────────────────────────────────────────────────────┘

📧 Notification sent to #deployments channel
```

### Rollback Output

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    ⚠️  ROLLBACK INITIATED                                    ║
║                    Environment: production                                   ║
╚══════════════════════════════════════════════════════════════════════════════╝

Rolling back: 1.2.3 → 1.2.2

[15:05:01] ├─ Stopping current service...
[15:05:03] ├─ Updating symlink: current → releases/1.2.2
[15:05:03] ├─ Starting service...
[15:05:05] ├─ Health check... ✓
[15:05:05] └─ Rollback completed

⚠️  Version 1.2.3 marked as failed
    Review logs: /var/log/myapp/deploy_1.2.3.log
```

---

## Fișier Configurare

```yaml
# deploy.yaml
project:
  name: myapp
  type: nodejs           # nodejs|python|go|static
  build_cmd: "npm run build"
  test_cmd: "npm test"
  
versioning:
  strategy: semver       # semver|timestamp|git-sha
  auto_increment: patch  # major|minor|patch

environments:
  dev:
    host: localhost
    path: /opt/myapp
    user: deploy
    branch: develop
    auto_deploy: true
    
  staging:
    host: staging.local
    path: /opt/myapp
    user: deploy
    branch: main
    requires_tests: true
    
  prod:
    host: prod.local
    path: /opt/myapp
    user: deploy
    branch: main
    requires_tests: true
    requires_approval: true
    backup_retention: 10

deploy:
  strategy: symlink      # symlink|rsync|docker
  health_check:
    enabled: true
    url: "http://localhost:3000/health"
    timeout: 30
    retries: 3
  rollback_on_failure: true
  
notifications:
  slack:
    webhook: "${SLACK_WEBHOOK}"
    channel: "#deployments"
  email:
    to: "team@example.com"
    on: [failure, prod_deploy]

cleanup:
  keep_releases: 5
  keep_backups: 10
```

---

## Structură Proiect

```
M05_Deployment_Pipeline/
├── README.md
├── Makefile
├── src/
│   ├── deploy.sh                # Script principal
│   └── lib/
│       ├── build.sh             # Build stage
│       ├── test.sh              # Test stage
│       ├── package.sh           # Package stage
│       ├── deploy_stage.sh      # Deploy logic
│       ├── rollback.sh          # Rollback logic
│       ├── health.sh            # Health checks
│       ├── notify.sh            # Notificări
│       ├── config.sh            # Parser configurație
│       └── git.sh               # Git operations
├── etc/
│   ├── deploy.yaml.example
│   └── hooks/
│       ├── pre-deploy.sh.example
│       └── post-deploy.sh.example
├── templates/
│   ├── manifest.json.tmpl
│   └── notification.tmpl
├── tests/
│   ├── test_build.sh
│   ├── test_deploy.sh
│   └── mock_project/            # Proiect test
├── docs/
│   ├── INSTALL.md
│   ├── CONFIGURATION.md
│   └── STRATEGIES.md
└── examples/
    ├── nodejs/
    ├── python/
    └── static/
```

---

## Hints Implementare

### Detectare tip proiect

```bash
detect_project_type() {
    local project_dir="$1"
    
    if [[ -f "$project_dir/package.json" ]]; then
        echo "nodejs"
    elif [[ -f "$project_dir/requirements.txt" ]] || [[ -f "$project_dir/pyproject.toml" ]]; then
        echo "python"
    elif [[ -f "$project_dir/go.mod" ]]; then
        echo "go"
    elif [[ -f "$project_dir/Makefile" ]]; then
        echo "make"
    else
        echo "static"
    fi
}
```

### Deploy atomic cu symlink

```bash
deploy_symlink() {
    local package="$1"
    local env="$2"
    local version="$3"
    
    local releases_dir="/opt/${PROJECT}/releases"
    local current_link="/opt/${PROJECT}/current"
    local target_dir="${releases_dir}/${version}"
    
    # Extrage în releases/
    mkdir -p "$target_dir"
    tar -xzf "$package" -C "$target_dir"
    
    # Atomic symlink swap
    ln -sfn "$target_dir" "${current_link}.new"
    mv -Tf "${current_link}.new" "$current_link"
    
    echo "Deployed $version"
}

rollback_symlink() {
    local env="$1"
    local version="$2"
    
    local releases_dir="/opt/${PROJECT}/releases"
    local current_link="/opt/${PROJECT}/current"
    
    if [[ -z "$version" ]]; then
        # Găsește versiunea anterioară
        version=$(ls -t "$releases_dir" | sed -n '2p')
    fi
    
    [[ -d "${releases_dir}/${version}" ]] || die "Version $version not found"
    
    ln -sfn "${releases_dir}/${version}" "${current_link}.new"
    mv -Tf "${current_link}.new" "$current_link"
    
    echo "Rolled back to $version"
}
```

### Health check cu retry

```bash
health_check() {
    local url="$1"
    local timeout="${2:-30}"
    local retries="${3:-3}"
    local delay="${4:-5}"
    
    local attempt=1
    while [[ $attempt -le $retries ]]; do
        log_info "Health check attempt $attempt/$retries..."
        
        local status
        status=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "$url")
        
        if [[ "$status" == "200" ]]; then
            log_info "Health check passed (HTTP $status)"
            return 0
        fi
        
        log_warn "Health check failed (HTTP $status)"
        
        ((attempt++))
        [[ $attempt -le $retries ]] && sleep "$delay"
    done
    
    return 1
}
```

### Generare versiune

```bash
get_next_version() {
    local strategy="$1"  # semver|timestamp|git-sha
    local increment="${2:-patch}"
    
    case "$strategy" in
        semver)
            local current
            current=$(cat VERSION 2>/dev/null || echo "0.0.0")
            
            IFS='.' read -r major minor patch <<< "$current"
            
            case "$increment" in
                major) echo "$((major + 1)).0.0" ;;
                minor) echo "${major}.$((minor + 1)).0" ;;
                patch) echo "${major}.${minor}.$((patch + 1))" ;;
            esac
            ;;
        timestamp)
            date +"%Y%m%d.%H%M%S"
            ;;
        git-sha)
            git rev-parse --short HEAD
            ;;
    esac
}
```

### Cleanup releases vechi

```bash
cleanup_old_releases() {
    local releases_dir="$1"
    local keep="$2"
    local current
    
    current=$(readlink /opt/${PROJECT}/current | xargs basename)
    
    ls -t "$releases_dir" | tail -n +$((keep + 1)) | while read -r release; do
        [[ "$release" == "$current" ]] && continue
        
        log_info "Removing old release: $release"
        rm -rf "${releases_dir}/${release}"
    done
}
```

---

## Criterii Evaluare Specifice

| Criteriu | Pondere | Descriere |
|----------|---------|-----------|
| Build stage | 15% | Detectare proiect, build corect |
| Test stage | 10% | Integrare teste, fail on error |
| Package stage | 10% | Arhivare, versionare, manifest |
| Deploy stage | 20% | Multi-env, atomic, backup |
| Rollback | 15% | Rollback corect, automat la fail |
| Health checks | 10% | Verificare post-deploy |
| Funcționalități extra | 10% | Notificări, blue-green |
| Calitate cod + teste | 5% | ShellCheck, modular |
| Documentație | 5% | README, configurare |

---

## Resurse

- [12 Factor App](https://12factor.net/) - Best practices deployment
- Seminar 3-5 - Scripting avansat, procese
- Git hooks documentation

---

*Proiect MEDIUM | Sisteme de Operare | ASE-CSIE*
