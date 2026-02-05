# M05: Pipeline Deployment

> **Nivel:** MEDIUM | **Timp estimat:** 25-35 ore | **Bonus K8s:** +10%

---

## Descriere

Pipeline complet de deployment pentru aplicații: build, test, package, deploy cu suport pentru medii multiple (dev/staging/prod), rollback automat și notificări. Simulează un mini CI/CD fără dependențe externe.

---

## Obiective de Învățare

- Concepte CI/CD și automatizare deployment
- Gestionare medii (dev/staging/prod)
- Versionare și gestionare release-uri
- Rollback și disaster recovery
- Integrare cu hook-uri Git

---

## Cerințe Funcționale

### Obligatorii (pentru nota de trecere)

1. **Etapă build**
   - Detectare automată tip proiect (Node, Python, Go, static)
   - Instalare dependențe
   - Compilare/bundling unde aplicabil
   - Generare artifact build

2. **Etapă test**
   - Rulare teste automate
   - Generare raport coverage (dacă disponibil)
   - Eșuare pipeline dacă teste eșuează

3. **Etapă package**
   - Creare arhivă deployment (tar.gz)
   - Versionare automată (semver sau timestamp)
   - Generare manifest cu metadata

4. **Etapă deploy**
   - Suport medii multiple (dev, staging, prod)
   - Backup înainte de deploy
   - Deploy atomic (symlink swap)
   - Health check post-deploy

5. **Rollback**
   - Rollback la versiune anterioară
   - Istoric deployment-uri
   - Rollback automat la eșec health check

### Opționale (pentru punctaj complet)

6. **Notificări** - Slack/email la succes/eșec
7. **Integrare Git** - Deploy la tag sau branch specific
8. **Blue-green deployment** - Zero downtime
9. **Canary releases** - Deploy gradual cu monitorizare
10. **Gestionare secrete** - Variabile environment criptate

---

## Interfață CLI

```bash
./deploy.sh <command> [options]

Commands:
  init                  Initialise pipeline configuration
  build                 Run build stage
  test                  Run tests
  package               Create deployment package
  deploy <env>          Deploy to environment (dev|staging|prod)
  rollback <env> [ver]  Rollback to previous version
  status <env>          Current deployment status
  history <env>         Deployment history
  promote <from> <to>   Promote version between environments
  cleanup <env>         Delete old deployments

Options:
  -c, --config FILE     Configuration file (default: deploy.yaml)
  -v, --version VER     Specific version for deploy
  -f, --force           Force deploy (skip confirmations)
  -n, --dry-run         Simulation without changes
  --no-backup           Skip backup before deploy
  --no-tests            Skip tests (ONLY for dev)
  --tag TAG             Deploy specific git tag
  --branch BRANCH       Deploy specific branch

Examples:
  ./deploy.sh init
  ./deploy.sh build && ./deploy.sh test && ./deploy.sh package
  ./deploy.sh deploy staging
  ./deploy.sh deploy prod -v 1.2.3
  ./deploy.sh rollback prod
  ./deploy.sh promote staging prod
```

---

## Exemple Output

### Output Build

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    PIPELINE DEPLOYMENT - ETAPĂ BUILD                         ║
║                    Proiect: myapp | Tip: nodejs                             ║
╚══════════════════════════════════════════════════════════════════════════════╝

[14:30:01] ▶ Începere build···
[14:30:01] ├─ Detectare tip proiect··· nodejs (package.json găsit)
[14:30:01] ├─ Versiune Node: 20.10.0 ✓
[14:30:01] ├─ Versiune NPM: 10.2.3 ✓
[14:30:02] ├─ Instalare dependențe···
[14:30:15] │  └─ 847 pachete instalate
[14:30:15] ├─ Rulare script build (npm run build)···
[14:30:28] │  └─ Output build: dist/ (2.3 MB)
[14:30:28] ├─ Generare source maps··· ✓
[14:30:29] └─ Build finalizat cu succes

┌─────────────────────────────────────────────────────────────────────────────┐
│ REZUMAT BUILD                                                               │
├─────────────────────────────────────────────────────────────────────────────┤
│ Durată:          28 secunde                                                 │
│ Mărime output:   2.3 MB (dist/)                                            │
│ Commit Git:      a1b2c3d "feat: add user dashboard"                        │
│ Branch Git:      main                                                       │
│ Număr build:     #142                                                       │
└─────────────────────────────────────────────────────────────────────────────┘

✓ BUILD REUȘIT - Pregătit pentru etapa test
```

### Output Deploy

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    PIPELINE DEPLOYMENT - ETAPĂ DEPLOY                        ║
║                    Mediu: production                                         ║
╚══════════════════════════════════════════════════════════════════════════════╝

[15:00:01] ▶ Începere deployment în PRODUCTION
[15:00:01] │
[15:00:01] ├─ Verificări pre-zbor
[15:00:01] │  ├─ Pachet există: myapp-1.2.3.tar.gz ✓
[15:00:01] │  ├─ Țintă accesibilă: prod-server.local ✓
[15:00:02] │  ├─ Spațiu disc: 45 GB disponibil ✓
[15:00:02] │  └─ Teste trecute: build #142 ✓
[15:00:02] │
[15:00:02] ├─ Creare backup
[15:00:02] │  ├─ Versiune curentă: 1.2.2
[15:00:05] │  └─ Backup creat: /var/backups/myapp/1.2.2_20250120.tar.gz
[15:00:05] │
[15:00:05] ├─ Deploy versiune 1.2.3
[15:00:05] │  ├─ Încărcare pachet··· 2.3 MB
[15:00:08] │  ├─ Extragere în /opt/myapp/releases/1.2.3/
[15:00:10] │  ├─ Instalare dependențe···
[15:00:25] │  ├─ Rulare migrări··· (2 în așteptare)
[15:00:28] │  ├─ Actualizare symlink: /opt/myapp/current → releases/1.2.3
[15:00:28] │  └─ Restart serviciu···
[15:00:30] │
[15:00:30] ├─ Verificări sănătate
[15:00:30] │  ├─ Status serviciu: active ✓
[15:00:31] │  ├─ Sănătate HTTP: 200 OK (45ms) ✓
[15:00:32] │  ├─ Conexiune bază date: OK ✓
[15:00:32] │  └─ Toate verificările trecute ✓
[15:00:32] │
[15:00:32] └─ Deployment finalizat cu succes!

┌─────────────────────────────────────────────────────────────────────────────┐
│ REZUMAT DEPLOYMENT                                                          │
├─────────────────────────────────────────────────────────────────────────────┤
│ Mediu:           production                                                 │
│ Versiune:        1.2.2 → 1.2.3                                             │
│ Durată:          31 secunde                                                 │
│ Deployer:        antonio                                                    │
│ Rollback:        ./deploy.sh rollback prod 1.2.2                           │
└─────────────────────────────────────────────────────────────────────────────┘

📧 Notificare trimisă la canal #deployments
```

### Output Rollback

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    ⚠️  ROLLBACK INIȚIAT                                      ║
║                    Mediu: production                                         ║
╚══════════════════════════════════════════════════════════════════════════════╝

Rollback: 1.2.3 → 1.2.2

[15:05:01] ├─ Oprire serviciu curent···
[15:05:03] ├─ Actualizare symlink: current → releases/1.2.2
[15:05:03] ├─ Pornire serviciu···
[15:05:05] ├─ Verificare sănătate··· ✓
[15:05:05] └─ Rollback finalizat

⚠️  Versiunea 1.2.3 marcată ca eșuată
    Revizuire log-uri: /var/log/myapp/deploy_1.2.3.log
```

---

## Fișier Configurație

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
    to: "[adresă eliminată]"
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
│   ├── deploy.sh                # Main script
│   └── lib/
│       ├── build.sh             # Build stage
│       ├── test.sh              # Test stage
│       ├── package.sh           # Package stage
│       ├── deploy_stage.sh      # Deploy logic
│       ├── rollback.sh          # Rollback logic
│       ├── health.sh            # Health checks
│       ├── notify.sh            # Notifications
│       ├── config.sh            # Configuration parser
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
│   └── mock_project/            # Test project
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

## Indicii de Implementare

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
    
    # Extract to releases/
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
        # Find previous version
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
        log_info "Health check attempt $attempt/$retries···"
        
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

### Curățare release-uri vechi

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

## Criterii Specifice de Evaluare

| Criteriu | Pondere | Descriere |
|-----------|--------|-------------|
| Etapă build | 15% | Detectare proiect, build corect |
| Etapă test | 10% | Integrare teste, eșec la eroare |
| Etapă package | 10% | Arhivare, versionare, manifest |
| Etapă deploy | 20% | Multi-mediu, atomic, backup |
| Rollback | 15% | Rollback corect, automat la eșec |
| Health checks | 10% | Verificare post-deploy |
| Funcționalități extra | 10% | Notificări, blue-green |
| Calitate cod + teste | 5% | ShellCheck, modular |
| Documentație | 5% | README, configurare |

---

## Resurse

- [12 Factor App](https://12factor.net/) - Best practices deployment
- Seminar 3-5 - Scripting avansat, procese
- Documentație hook-uri Git

---

*Proiect MEDIUM | Sisteme de Operare | ASE-CSIE*
