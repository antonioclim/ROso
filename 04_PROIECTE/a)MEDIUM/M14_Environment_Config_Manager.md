# M14: Environment Config Manager

> **Nivel:** MEDIUM | **Timp estimat:** 25-35 ore | **Bonus K8s:** +10%

---

## Descriere

Manager pentru configurări și variabile de mediu: suport pentru multiple environment-uri (dev/staging/prod), secrets management, template rendering și sincronizare configurări între mașini.

---

## Obiective de Învățare

- Gestionare variabile de mediu și dotfiles
- Template rendering în Bash
- Secrets management (criptare/decriptare)
- Versionare și diff configurări
- Deployment configurări pe multiple mașini

---

## Cerințe Funcționale

### Obligatorii (pentru notă de trecere)

1. **Environment management**
   - Definire multiple medii (dev, staging, prod)
   - Variabile specifice per mediu
   - Moștenire și override-uri

2. **Template system**
   - Template files cu placeholders (`${VAR}`)
   - Rendering bazat pe environment
   - Validare template-uri

3. **Secrets handling**
   - Criptare secrets (GPG sau openssl)
   - Decriptare la deploy
   - Nu stoca secrets în plain text

4. **Apply/Sync**
   - Aplicare config pe mașina curentă
   - Backup înainte de modificare
   - Rollback la probleme

5. **Diff și validare**
   - Comparație între medii
   - Validare configurări complete
   - Detectare variabile lipsă

### Opționale (pentru punctaj complet)

6. **Remote sync** - Sincronizare pe mașini remote via SSH
7. **Version control** - Integrare Git pentru istoric
8. **Hooks** - Pre/post apply hooks
9. **Schema validation** - Validare tipuri și valori
10. **UI** - Dashboard pentru vizualizare configurări

---

## Interfață CLI

```bash
./envman.sh <command> [opțiuni]

Comenzi:
  init                  Inițializează structură proiect
  env list              Listează mediile disponibile
  env create <name>     Creează mediu nou
  env show <name>       Afișează variabilele unui mediu
  set <key> <value>     Setează variabilă
  get <key>             Afișează valoare variabilă
  render <template>     Renderizează template
  apply [env]           Aplică configurări
  diff <env1> <env2>    Compară două medii
  export <env>          Exportă ca .env file
  secret encrypt <key>  Criptează valoare
  secret decrypt <key>  Decriptează valoare
  sync <target>         Sincronizează pe remote

Opțiuni:
  -e, --env ENV         Mediu țintă (default: development)
  -f, --file FILE       Fișier configurare
  -o, --output FILE     Fișier output
  -d, --dry-run         Simulare fără modificări
  -v, --verbose         Output detaliat
  --no-backup           Nu crea backup
  --force               Forțează operația

Exemple:
  ./envman.sh env create production
  ./envman.sh set -e production DATABASE_URL "postgres://..."
  ./envman.sh secret encrypt -e production API_KEY
  ./envman.sh render nginx.conf.tmpl -o /etc/nginx/nginx.conf
  ./envman.sh apply production
  ./envman.sh diff staging production
```

---

## Exemple Output

### Environment Show

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    ENVIRONMENT: production                                   ║
╚══════════════════════════════════════════════════════════════════════════════╝

VARIABLES
═══════════════════════════════════════════════════════════════════════════════

Application:
  APP_NAME              myapp
  APP_ENV               production
  APP_DEBUG             false
  APP_URL               https://myapp.example.com

Database:
  DATABASE_HOST         db.example.com
  DATABASE_PORT         5432
  DATABASE_NAME         myapp_prod
  DATABASE_USER         myapp
  DATABASE_PASSWORD     ******** (encrypted)

Cache:
  REDIS_HOST            redis.example.com
  REDIS_PORT            6379
  REDIS_PASSWORD        ******** (encrypted)

External Services:
  AWS_REGION            eu-west-1
  AWS_ACCESS_KEY        ******** (encrypted)
  AWS_SECRET_KEY        ******** (encrypted)
  SMTP_HOST             smtp.example.com

INHERITANCE
───────────────────────────────────────────────────────────────────────────────
  Base: default → production
  Overrides: 12 variables
  Secrets: 5 encrypted values

FILES TO RENDER
───────────────────────────────────────────────────────────────────────────────
  templates/nginx.conf.tmpl      → /etc/nginx/sites-available/myapp
  templates/app.env.tmpl         → /opt/myapp/.env
  templates/systemd.service.tmpl → /etc/systemd/system/myapp.service
```

### Diff Between Environments

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    DIFF: staging ↔ production                                ║
╚══════════════════════════════════════════════════════════════════════════════╝

DIFFERENT VALUES
═══════════════════════════════════════════════════════════════════════════════

Variable             staging                    production
─────────────────────────────────────────────────────────────────────────────
APP_ENV              staging                    production
APP_DEBUG            true                       false
APP_URL              https://staging.app.com   https://myapp.example.com
DATABASE_HOST        staging-db.local           db.example.com
DATABASE_NAME        myapp_staging              myapp_prod
REDIS_HOST           localhost                  redis.example.com
LOG_LEVEL            debug                      info

ONLY IN STAGING
═══════════════════════════════════════════════════════════════════════════════
  DEBUG_TOOLBAR       true
  MOCK_PAYMENTS       true

ONLY IN PRODUCTION
═══════════════════════════════════════════════════════════════════════════════
  CDN_URL             https://cdn.example.com
  SENTRY_DSN          https://xxx@sentry.io/123
  RATE_LIMIT          1000

SUMMARY
───────────────────────────────────────────────────────────────────────────────
  Common variables:     45
  Different values:     7
  Only in staging:      2
  Only in production:   3
```

### Template Rendering

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    TEMPLATE RENDERING                                        ║
║                    Environment: production                                   ║
╚══════════════════════════════════════════════════════════════════════════════╝

Template: templates/nginx.conf.tmpl
───────────────────────────────────────────────────────────────────────────────

Variables used:
  ✓ APP_URL              → https://myapp.example.com
  ✓ APP_PORT             → 3000
  ✓ SSL_CERT_PATH        → /etc/ssl/certs/myapp.crt
  ✓ SSL_KEY_PATH         → /etc/ssl/private/myapp.key
  ✓ UPSTREAM_SERVERS     → 10.0.0.1:3000,10.0.0.2:3000

Preview (first 20 lines):
───────────────────────────────────────────────────────────────────────────────
  upstream myapp {
      server 10.0.0.1:3000;
      server 10.0.0.2:3000;
  }
  
  server {
      listen 443 ssl http2;
      server_name myapp.example.com;
      
      ssl_certificate /etc/ssl/certs/myapp.crt;
      ssl_certificate_key /etc/ssl/private/myapp.key;
      
      location / {
          proxy_pass http://myapp;
      }
  }

Output: /etc/nginx/sites-available/myapp
Action: Write file? [y/N]
```

---

## Structură Fișiere Configurare

```
config/
├── default.env              # Variabile comune toate mediile
├── development.env          # Overrides pentru dev
├── staging.env              # Overrides pentru staging
├── production.env           # Overrides pentru prod
├── secrets/
│   ├── development.enc      # Secrets criptate dev
│   ├── staging.enc          # Secrets criptate staging
│   └── production.enc       # Secrets criptate prod
└── templates/
    ├── nginx.conf.tmpl
    ├── app.env.tmpl
    └── systemd.service.tmpl
```

### Exemplu default.env

```bash
# Configurări comune
APP_NAME=myapp
APP_PORT=3000
LOG_FORMAT=json

# Database defaults
DATABASE_PORT=5432

# Cache defaults  
REDIS_PORT=6379
REDIS_DB=0

# Paths
APP_PATH=/opt/myapp
LOG_PATH=/var/log/myapp
```

### Exemplu production.env

```bash
# Extends: default

APP_ENV=production
APP_DEBUG=false
APP_URL=https://myapp.example.com

# Database
DATABASE_HOST=db.example.com
DATABASE_NAME=myapp_prod
DATABASE_USER=myapp

# Cache
REDIS_HOST=redis.example.com

# Logging
LOG_LEVEL=info
```

---

## Structură Proiect

```
M14_Environment_Config_Manager/
├── README.md
├── Makefile
├── src/
│   ├── envman.sh                # Script principal
│   └── lib/
│       ├── env.sh               # Gestionare environments
│       ├── template.sh          # Template rendering
│       ├── secrets.sh           # Criptare/decriptare
│       ├── diff.sh              # Comparație medii
│       ├── apply.sh             # Aplicare configurări
│       └── sync.sh              # Sincronizare remote
├── etc/
│   ├── envman.conf
│   └── schema.yaml              # Schema validare
├── tests/
│   ├── test_template.sh
│   ├── test_secrets.sh
│   └── fixtures/
└── docs/
    ├── INSTALL.md
    ├── TEMPLATES.md
    └── SECRETS.md
```

---

## Hints Implementare

### Încărcare environment cu moștenire

```bash
load_environment() {
    local env_name="$1"
    local config_dir="$CONFIG_DIR"
    
    declare -gA ENV_VARS
    
    # Încarcă default
    load_env_file "$config_dir/default.env"
    
    # Încarcă environment-specific (override)
    local env_file="$config_dir/${env_name}.env"
    if [[ -f "$env_file" ]]; then
        load_env_file "$env_file"
    fi
    
    # Încarcă secrets decriptate
    load_secrets "$env_name"
}

load_env_file() {
    local file="$1"
    
    while IFS='=' read -r key value; do
        # Skip comments și linii goale
        [[ "$key" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$key" ]] && continue
        
        # Elimină quotes dacă există
        value="${value%\"}"
        value="${value#\"}"
        value="${value%\'}"
        value="${value#\'}"
        
        ENV_VARS[$key]="$value"
    done < "$file"
}
```

### Template rendering

```bash
render_template() {
    local template="$1"
    local output="$2"
    
    local content
    content=$(<"$template")
    
    # Înlocuiește toate variabilele ${VAR} și $VAR
    for key in "${!ENV_VARS[@]}"; do
        local value="${ENV_VARS[$key]}"
        # Escape pentru sed
        value=$(printf '%s\n' "$value" | sed -e 's/[\/&]/\\&/g')
        
        content=$(echo "$content" | sed "s/\${$key}/$value/g")
        content=$(echo "$content" | sed "s/\$$key/$value/g")
    done
    
    # Verifică variabile nerezolvate
    local missing
    missing=$(echo "$content" | grep -oE '\$\{?[A-Z_][A-Z0-9_]*\}?' | sort -u)
    
    if [[ -n "$missing" ]]; then
        echo "Warning: Unresolved variables:"
        echo "$missing"
    fi
    
    if [[ -n "$output" ]]; then
        echo "$content" > "$output"
    else
        echo "$content"
    fi
}
```

### Criptare secrets cu OpenSSL

```bash
encrypt_value() {
    local value="$1"
    local password="$ENVMAN_PASSWORD"
    
    echo "$value" | openssl enc -aes-256-cbc -pbkdf2 -base64 -pass pass:"$password"
}

decrypt_value() {
    local encrypted="$1"
    local password="$ENVMAN_PASSWORD"
    
    echo "$encrypted" | openssl enc -aes-256-cbc -pbkdf2 -d -base64 -pass pass:"$password"
}

# Salvare secrets criptate
save_secret() {
    local env="$1"
    local key="$2"
    local value="$3"
    
    local secrets_file="$CONFIG_DIR/secrets/${env}.enc"
    local encrypted
    encrypted=$(encrypt_value "$value")
    
    # Adaugă sau actualizează
    if grep -q "^${key}=" "$secrets_file" 2>/dev/null; then
        sed -i "s|^${key}=.*|${key}=${encrypted}|" "$secrets_file"
    else
        echo "${key}=${encrypted}" >> "$secrets_file"
    fi
}

load_secrets() {
    local env="$1"
    local secrets_file="$CONFIG_DIR/secrets/${env}.enc"
    
    [[ -f "$secrets_file" ]] || return 0
    
    while IFS='=' read -r key encrypted; do
        [[ -z "$key" ]] && continue
        local value
        value=$(decrypt_value "$encrypted")
        ENV_VARS[$key]="$value"
    done < "$secrets_file"
}
```

### Diff între medii

```bash
diff_environments() {
    local env1="$1"
    local env2="$2"
    
    declare -A vars1 vars2
    
    # Încarcă ambele
    load_environment "$env1"
    for k in "${!ENV_VARS[@]}"; do vars1[$k]="${ENV_VARS[$k]}"; done
    
    unset ENV_VARS
    declare -gA ENV_VARS
    
    load_environment "$env2"
    for k in "${!ENV_VARS[@]}"; do vars2[$k]="${ENV_VARS[$k]}"; done
    
    # Compară
    echo "Different values:"
    for key in "${!vars1[@]}"; do
        if [[ -v vars2[$key] ]]; then
            if [[ "${vars1[$key]}" != "${vars2[$key]}" ]]; then
                echo "  $key: '${vars1[$key]}' → '${vars2[$key]}'"
            fi
        fi
    done
    
    echo "Only in $env1:"
    for key in "${!vars1[@]}"; do
        [[ ! -v vars2[$key] ]] && echo "  $key"
    done
    
    echo "Only in $env2:"
    for key in "${!vars2[@]}"; do
        [[ ! -v vars1[$key] ]] && echo "  $key"
    done
}
```

---

## Criterii Evaluare Specifice

| Criteriu | Pondere | Descriere |
|----------|---------|-----------|
| Environment management | 20% | Multi-env, moștenire |
| Template rendering | 20% | Variables, validation |
| Secrets management | 20% | Encrypt/decrypt, secure |
| Apply/sync | 15% | Local apply, backup |
| Diff & validation | 10% | Compare, detect missing |
| Remote sync | 5% | SSH sync |
| Calitate cod + teste | 5% | ShellCheck, teste |
| Documentație | 5% | README, template doc |

---

## Resurse

- `man openssl enc` - Criptare simetrică
- `man gpg` - GPG encryption
- 12 Factor App - Config management
- Seminar 3-4 - Variabile, text processing

---

*Proiect MEDIUM | Sisteme de Operare | ASE-CSIE*
