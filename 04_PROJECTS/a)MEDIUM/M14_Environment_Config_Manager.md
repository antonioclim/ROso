# M14: Manager Configurații Environment

> **Nivel:** MEDIUM | **Timp estimat:** 25-35 ore | **Bonus K8s:** +10%

---

## Descriere

Manager pentru configurații și variabile environment: suport pentru medii multiple (dev/staging/prod), gestionare secrete, rendering template-uri și sincronizare configurații între mașini.

---

## Obiective de Învățare

- Gestionare variabile environment și dotfiles
- Rendering template-uri în Bash
- Gestionare secrete (criptare/decriptare)
- Versionare și diff configurații
- Deployment configurații pe mașini multiple

---

## Cerințe Funcționale

### Obligatorii (pentru nota de trecere)

1. **Gestionare medii**
   - Definire medii multiple (dev, staging, prod)
   - Variabile specifice mediu
   - Moștenire și override-uri

2. **Sistem template**
   - Fișiere template cu placeholder-e (`${VAR}`)
   - Rendering bazat pe mediu
   - Validare template-uri

3. **Gestionare secrete**
   - Criptare secrete (GPG sau openssl)
   - Decriptare la moment deploy
   - Fără stocare plain text secrete

4. **Apply/Sync**
   - Aplicare config pe mașina curentă
   - Backup înainte modificare
   - Rollback la probleme

5. **Diff și validare**
   - Comparație între medii
   - Validare configurație completă
   - Detectare variabile lipsă

### Opționale (pentru punctaj complet)

6. **Sync remote** - Sincronizare pe mașini remote via SSH
7. **Version control** - Integrare Git pentru istoric
8. **Hook-uri** - Hook-uri pre/post apply
9. **Validare schemă** - Validare tip și valoare
10. **UI** - Dashboard pentru vizualizare configurații

---

## Interfață CLI

```bash
./envman.sh <command> [options]

Commands:
  init                  Initialise project structure
  env list              List available environments
  env create <n>     Create new environment
  env show <n>       Display environment variables
  set <key> <value>     Set variable
  get <key>             Display variable value
  render <template>     Render template
  apply [env]           Apply configurations
  diff <env1> <env2>    Compare two environments
  export <env>          Export as .env file
  secret encrypt <key>  Encrypt value
  secret decrypt <key>  Decrypt value
  sync <target>         Synchronise to remote

Options:
  -e, --env ENV         Target environment (default: development)
  -f, --file FILE       Configuration file
  -o, --output FILE     Output file
  -d, --dry-run         Simulation without modifications
  -v, --verbose         Detailed output
  --no-backup           Don't create backup
  --force               Force operation

Examples:
  ./envman.sh env create production
  ./envman.sh set -e production DATABASE_URL "postgres://···"
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

VARIABILE
═══════════════════════════════════════════════════════════════════════════════

Aplicație:
  APP_NAME              myapp
  APP_ENV               production
  APP_DEBUG             false
  APP_URL               https://myapp.example.com

Bază Date:
  DATABASE_HOST         db.example.com
  DATABASE_PORT         5432
  DATABASE_NAME         myapp_prod
  DATABASE_USER         myapp
  DATABASE_PASSWORD     ******** (criptat)

Cache:
  REDIS_HOST            redis.example.com
  REDIS_PORT            6379
  REDIS_PASSWORD        ******** (criptat)

Servicii Externe:
  AWS_REGION            eu-west-1
  AWS_ACCESS_KEY        ******** (criptat)
  AWS_SECRET_KEY        ******** (criptat)
  SMTP_HOST             smtp.example.com

MOȘTENIRE
───────────────────────────────────────────────────────────────────────────────
  Bază: default → production
  Override-uri: 12 variabile
  Secrete: 5 valori criptate

FIȘIERE DE RENDERIZAT
───────────────────────────────────────────────────────────────────────────────
  templates/nginx.conf.tmpl      → /etc/nginx/sites-available/myapp
  templates/app.env.tmpl         → /opt/myapp/.env
  templates/systemd.service.tmpl → /etc/systemd/system/myapp.service
```

### Diff Între Medii

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    DIFF: staging ↔ production                                ║
╚══════════════════════════════════════════════════════════════════════════════╝

VALORI DIFERITE
═══════════════════════════════════════════════════════════════════════════════

Variabilă             staging                    production
─────────────────────────────────────────────────────────────────────────────
APP_ENV              staging                    production
APP_DEBUG            true                       false
APP_URL              https://staging.app.com   https://myapp.example.com
DATABASE_HOST        staging-db.local           db.example.com
DATABASE_NAME        myapp_staging              myapp_prod
REDIS_HOST           localhost                  redis.example.com
LOG_LEVEL            debug                      info

DOAR ÎN STAGING
═══════════════════════════════════════════════════════════════════════════════
  DEBUG_TOOLBAR       true
  MOCK_PAYMENTS       true

DOAR ÎN PRODUCTION
═══════════════════════════════════════════════════════════════════════════════
  CDN_URL             https://cdn.example.com
  SENTRY_DSN          https://[adresă eliminată]/123
  RATE_LIMIT          1000

REZUMAT
───────────────────────────────────────────────────────────────────────────────
  Variabile comune:     45
  Valori diferite:      7
  Doar în staging:      2
  Doar în production:   3
```

### Rendering Template

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    RENDERING TEMPLATE                                        ║
║                    Environment: production                                   ║
╚══════════════════════════════════════════════════════════════════════════════╝

Template: templates/nginx.conf.tmpl
───────────────────────────────────────────────────────────────────────────────

Variabile folosite:
  ✓ APP_URL              → https://myapp.example.com
  ✓ APP_PORT             → 3000
  ✓ SSL_CERT_PATH        → /etc/ssl/certs/myapp.crt
  ✓ SSL_KEY_PATH         → /etc/ssl/private/myapp.key
  ✓ UPSTREAM_SERVERS     → 10.0.0.1:3000,10.0.0.2:3000

Previzualizare (primele 20 linii):
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
Acțiune: Scrie fișier? [y/N]
```

---

## Structură Fișier Configurație

```
config/
├── default.env              # Variables common to all environments
├── development.env          # Overrides for dev
├── staging.env              # Overrides for staging
├── production.env           # Overrides for prod
├── secrets/
│   ├── development.enc      # Encrypted dev secrets
│   ├── staging.enc          # Encrypted staging secrets
│   └── production.enc       # Encrypted prod secrets
└── templates/
    ├── nginx.conf.tmpl
    ├── app.env.tmpl
    └── systemd.service.tmpl
```

### Exemplu default.env

```bash
# Common configurations
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
│   ├── envman.sh                # Main script
│   └── lib/
│       ├── env.sh               # Environment management
│       ├── template.sh          # Template rendering
│       ├── secrets.sh           # Encryption/decryption
│       ├── diff.sh              # Environment comparison
│       ├── apply.sh             # Configuration application
│       └── sync.sh              # Remote synchronisation
├── etc/
│   ├── envman.conf
│   └── schema.yaml              # Validation schema
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

## Indicii de Implementare

### Încărcare environment cu moștenire

```bash
load_environment() {
    local env_name="$1"
    local config_dir="$CONFIG_DIR"
    
    declare -gA ENV_VARS
    
    # Load default
    load_env_file "$config_dir/default.env"
    
    # Load environment-specific (override)
    local env_file="$config_dir/${env_name}.env"
    if [[ -f "$env_file" ]]; then
        load_env_file "$env_file"
    fi
    
    # Load decrypted secrets
    load_secrets "$env_name"
}

load_env_file() {
    local file="$1"
    
    while IFS='=' read -r key value; do
        # Skip comments and empty lines
        [[ "$key" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$key" ]] && continue
        
        # Remove quotes if present
        value="${value%\"}"
        value="${value#\"}"
        value="${value%\'}"
        value="${value#\'}"
        
        ENV_VARS[$key]="$value"
    done < "$file"
}
```

### Rendering template

```bash
render_template() {
    local template="$1"
    local output="$2"
    
    local content
    content=$(<"$template")
    
    # Replace all variables ${VAR} and $VAR
    for key in "${!ENV_VARS[@]}"; do
        local value="${ENV_VARS[$key]}"
        # Escape for sed
        value=$(printf '%s\n' "$value" | sed -e 's/[\/&]/\\&/g')
        
        content=$(echo "$content" | sed "s/\${$key}/$value/g")
        content=$(echo "$content" | sed "s/\$$key/$value/g")
    done
    
    # Check for unresolved variables
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

### Criptare secrete cu OpenSSL

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

# Save encrypted secrets
save_secret() {
    local env="$1"
    local key="$2"
    local value="$3"
    
    local secrets_file="$CONFIG_DIR/secrets/${env}.enc"
    local encrypted
    encrypted=$(encrypt_value "$value")
    
    # Add or update
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
    
    # Load both
    load_environment "$env1"
    for k in "${!ENV_VARS[@]}"; do vars1[$k]="${ENV_VARS[$k]}"; done
    
    unset ENV_VARS
    declare -gA ENV_VARS
    
    load_environment "$env2"
    for k in "${!ENV_VARS[@]}"; do vars2[$k]="${ENV_VARS[$k]}"; done
    
    # Compare
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

## Criterii Specifice de Evaluare

| Criteriu | Pondere | Descriere |
|-----------|--------|-------------|
| Gestionare medii | 20% | Multi-env, moștenire |
| Rendering template | 20% | Variabile, validare |
| Gestionare secrete | 20% | Encrypt/decrypt, securizat |
| Apply/sync | 15% | Apply local, backup |
| Diff & validare | 10% | Comparare, detectare lipsă |
| Sync remote | 5% | Sync SSH |
| Calitate cod + teste | 5% | ShellCheck, teste |
| Documentație | 5% | README, doc template |

---

## Resurse

- `man openssl enc` - Criptare simetrică
- `man gpg` - Criptare GPG
- 12 Factor App - Gestionare config
- Seminar 3-4 - Variabile, procesare text

---

*Proiect MEDIUM | Sisteme de Operare | ASE-CSIE*
