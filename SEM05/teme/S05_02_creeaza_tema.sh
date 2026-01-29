#!/bin/bash
#
# TEMPLATE TEMĂ - Seminar 05: Advanced Bash Scripting
# 
# Acest script creează structura de bază pentru tema ta.
# Rulează-l o singură dată, apoi completează fișierele create.
#
# Utilizare: ./S05_02_creeaza_tema.sh "NumeleTau" "Grupa"
#

set -euo pipefail

# Verifică argumentele
if [[ $# -lt 2 ]]; then
    echo "Utilizare: $0 \"Numele Tău\" \"Grupa\""
    echo "Exemplu: $0 \"Popescu Ion\" \"1234\""
    exit 1
fi

NUME="$1"
GRUPA="$2"
DATA=$(date +%Y-%m-%d)
TEMA_DIR="$HOME/tema_S05_${NUME// /_}"

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║     CREARE STRUCTURĂ TEMĂ - Advanced Bash Scripting          ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo "Student: $NUME"
echo "Grupa:   $GRUPA"
echo "Data:    $DATA"
echo ""

# Verifică dacă directorul există deja
if [[ -d "$TEMA_DIR" ]]; then
    echo "⚠️  Directorul $TEMA_DIR există deja!"
    read -p "Dorești să-l ștergi și să creezi unul nou? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$TEMA_DIR"
    else
        echo "Operație anulată."
        exit 1
    fi
fi

# Creează structura
echo "📁 Creare structură directoare..."
mkdir -p "$TEMA_DIR"/{test_files,screenshots}

# Creează README.md
echo "📝 Creare README.md..."
cat > "$TEMA_DIR/README.md" << EOF
# Temă Seminar 05: Advanced Bash Scripting

**Autor:** $NUME  
**Grupa:** $GRUPA  
**Data:** $DATA

---

##  Structura Proiectului

\`\`\`
tema_S05_${NUME// /_}/
├── README.md              # Acest fișier
├── log_analyzer.sh        # Cerința 1 - Analiză log-uri
├── config_manager.sh      # Cerința 2 - Manager configurație
├── refactored_script.sh   # Cerința 3 - Script refactorizat
├── test_files/
│   ├── sample.log         # Fișier log de test
│   └── app.conf           # Fișier config de test
└── screenshots/           # Capturi cu output
\`\`\`

---

##  Cum se Rulează

### Log Analyzer
\`\`\`bash
./log_analyzer.sh test_files/sample.log
./log_analyzer.sh -l ERROR test_files/sample.log
./log_analyzer.sh --top 3 -v test_files/sample.log
\`\`\`

### Config Manager
\`\`\`bash
./config_manager.sh list
./config_manager.sh get HOST
./config_manager.sh set DEBUG true
./config_manager.sh validate
\`\`\`

### Refactored Script
\`\`\`bash
./refactored_script.sh file1.txt file2.txt
\`\`\`

---

##  Checklist Pre-Predare

- [ ] \`shellcheck log_analyzer.sh\` - fără erori
- [ ] \`shellcheck config_manager.sh\` - fără erori
- [ ] \`shellcheck refactored_script.sh\` - fără erori
- [ ] Toate scripturile au \`set -euo pipefail\`
- [ ] Toate funcțiile folosesc \`local\`
- [ ] Arrays asociative declarate cu \`declare -A\`
- [ ] Validare argumente implementată
- [ ] Trap EXIT pentru cleanup

---

##  Note și Observații

[Adaugă aici dificultăți întâmpinate sau observații]

---

##  AI Tools (dacă e cazul)

[Dacă ai folosit ChatGPT/Claude/Copilot, menționează aici ce părți]

---

*Tema pentru cursul de Sisteme de Operare | ASE București - CSIE*
EOF

# Creează log_analyzer.sh (template)
echo "📝 Creare log_analyzer.sh (template)..."
cat > "$TEMA_DIR/log_analyzer.sh" << 'SCRIPT'
#!/bin/bash
#
# log_analyzer.sh - Analizator de fișiere log
# Autor: [COMPLETEAZĂ]
# Data: [COMPLETEAZĂ]
#
# Utilizare: ./log_analyzer.sh [opțiuni] <log_file>
#

set -euo pipefail

#
# VARIABILE GLOBALE
#
readonly SCRIPT_NAME="${0##*/}"
readonly VERSION="1.0.0"

# Opțiuni
VERBOSE=false
LEVEL_FILTER=""
OUTPUT_FILE=""
TOP_N=5

# Arrays pentru statistici
declare -A LEVEL_COUNT
declare -A MESSAGE_COUNT

#
# FUNCȚII
#

usage() {
    cat << EOF
Utilizare: $SCRIPT_NAME [opțiuni] <log_file>

Analizează fișiere de log și generează statistici.

Opțiuni:
  -h, --help          Afișează acest mesaj
  -v, --verbose       Mod verbose
  -l, --level LEVEL   Filtrează după nivel (INFO, WARN, ERROR, DEBUG)
  -o, --output FILE   Salvează rezultatul în fișier
  --top N             Afișează top N mesaje (default: $TOP_N)
  --version           Afișează versiunea

Exemplu:
  $SCRIPT_NAME access.log
  $SCRIPT_NAME -l ERROR --top 10 server.log
EOF
}

log_verbose() {
    # TODO: Implementează logging verbose
    # Hint: if $VERBOSE; then echo "[VERBOSE] $*" >&2; fi
    :
}

parse_line() {
    # TODO: Parsează o linie de log
    # Format: [TIMESTAMP] [LEVEL] Message
    # Parametri: $1 = linia de log
    # Return: setează variabile TIMESTAMP, LEVEL, MESSAGE
    local line="$1"
    
    # Exemplu regex pentru extragere:
    # if [[ "$line" =~ ^\[([^\]]+)\]\ \[([^\]]+)\]\ (.*)$ ]]; then
    #     TIMESTAMP="${BASH_REMATCH[1]}"
    #     LEVEL="${BASH_REMATCH[2]}"
    #     MESSAGE="${BASH_REMATCH[3]}"
    # fi
    
    echo "TODO: Implementează parse_line"
}

count_levels() {
    # TODO: Numără entrările pe nivel
    # Folosește array-ul asociativ LEVEL_COUNT
    
    echo "TODO: Implementează count_levels"
}

get_top_messages() {
    # TODO: Returnează top N cele mai frecvente mesaje
    # Parametri: $1 = N (numărul de mesaje)
    local n="${1:-$TOP_N}"
    
    echo "TODO: Implementează get_top_messages"
}

print_report() {
    # TODO: Afișează raportul final
    # Include: statistici generale, distribuție nivele, top mesaje
    local log_file="$1"
    
    echo "═══════════════════════════════════════════"
    echo "Log Analysis Report: $log_file"
    echo "═══════════════════════════════════════════"
    echo ""
    echo "TODO: Completează raportul"
}

cleanup() {
    # TODO: Cleanup la exit
    # Șterge fișiere temporare dacă există
    log_verbose "Cleanup..."
}

#
# MAIN
#

main() {
    # Trap pentru cleanup
    trap cleanup EXIT
    
    # Parsare argumente
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                usage
                exit 0
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -l|--level)
                LEVEL_FILTER="$2"
                shift 2
                ;;
            -o|--output)
                OUTPUT_FILE="$2"
                shift 2
                ;;
            --top)
                TOP_N="$2"
                shift 2
                ;;
            --version)
                echo "$SCRIPT_NAME versiunea $VERSION"
                exit 0
                ;;
            -*)
                echo "Opțiune necunoscută: $1" >&2
                usage
                exit 1
                ;;
            *)
                break
                ;;
        esac
    done
    
    # Verifică argumentul obligatoriu (log file)
    if [[ $# -lt 1 ]]; then
        echo "Eroare: Lipsește fișierul de log" >&2
        usage
        exit 1
    fi
    
    local log_file="$1"
    
    # Verifică dacă fișierul există
    if [[ ! -f "$log_file" ]]; then
        echo "Eroare: Fișierul '$log_file' nu există" >&2
        exit 1
    fi
    
    log_verbose "Analizez: $log_file"
    
    # TODO: Procesează fișierul
    # 1. Citește fiecare linie
    # 2. Parsează cu parse_line
    # 3. Actualizează contoarele
    
    # Afișează raportul
    print_report "$log_file"
}

# Rulează main
main "$@"
SCRIPT
chmod +x "$TEMA_DIR/log_analyzer.sh"

# Creează config_manager.sh (template)
echo "📝 Creare config_manager.sh (template)..."
cat > "$TEMA_DIR/config_manager.sh" << 'SCRIPT'
#!/bin/bash
#
# config_manager.sh - Manager pentru fișiere de configurare
# Autor: [COMPLETEAZĂ]
# Data: [COMPLETEAZĂ]
#
# Utilizare: ./config_manager.sh <command> [args]
#

set -euo pipefail

#
# VARIABILE GLOBALE
#
readonly SCRIPT_NAME="${0##*/}"
readonly CONFIG_FILE="${CONFIG_FILE:-./app.conf}"

# Array asociativ pentru configurație
declare -A CONFIG

# Chei obligatorii
readonly REQUIRED_KEYS=("HOST" "PORT")

#
# FUNCȚII
#

usage() {
    cat << EOF
Utilizare: $SCRIPT_NAME <command> [args]

Gestionează fișiere de configurare key=value.

Commands:
  get <key>           Obține valoarea unei chei
  set <key> <value>   Setează o valoare
  delete <key>        Șterge o cheie
  list                Listează toate cheile
  validate            Verifică configurația
  export              Exportă ca environment variables

Environment:
  CONFIG_FILE         Calea către fișierul de config (default: ./app.conf)

Exemplu:
  $SCRIPT_NAME list
  $SCRIPT_NAME get HOST
  $SCRIPT_NAME set PORT 9090
EOF
}

load_config() {
    # TODO: Încarcă fișierul de configurare în array-ul CONFIG
    # - Ignoră linii goale
    # - Ignoră comentarii (linii care încep cu #)
    # - Parsează key=value și key = value
    
    if [[ ! -f "$CONFIG_FILE" ]]; then
        return 1
    fi
    
    # Exemplu:
    # while IFS= read -r line || [[ -n "$line" ]]; do
    #     # Ignoră linii goale și comentarii
    #     [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
    #     # Parsează key=value
    #     if [[ "$line" =~ ^([^=]+)=(.*)$ ]]; then
    #         local key="${BASH_REMATCH[1]}"
    #         local value="${BASH_REMATCH[2]}"
    #         # Trim whitespace
    #         key="${key%% }"
    #         value="${value## }"
    #         CONFIG["$key"]="$value"
    #     fi
    # done < "$CONFIG_FILE"
    
    echo "TODO: Implementează load_config"
}

save_config() {
    # TODO: Salvează array-ul CONFIG în fișier
    
    echo "TODO: Implementează save_config"
}

get_value() {
    # TODO: Returnează valoarea unei chei
    local key="$1"
    
    echo "TODO: Implementează get_value pentru '$key'"
}

set_value() {
    # TODO: Setează o valoare
    local key="$1"
    local value="$2"
    
    echo "TODO: Implementează set_value pentru '$key'='$value'"
}

delete_key() {
    # TODO: Șterge o cheie
    local key="$1"
    
    echo "TODO: Implementează delete_key pentru '$key'"
}

list_config() {
    # TODO: Listează toate cheile și valorile
    
    echo "TODO: Implementează list_config"
}

validate_config() {
    # TODO: Verifică configurația
    # - Verifică chei obligatorii
    # - Verifică format valori (ex: PORT să fie număr)
    
    echo "TODO: Implementează validate_config"
}

export_config() {
    # TODO: Exportă ca environment variables
    
    echo "TODO: Implementează export_config"
}

#
# MAIN
#

main() {
    if [[ $# -lt 1 ]]; then
        usage
        exit 1
    fi
    
    local command="$1"
    shift
    
    # Încarcă configurația
    load_config || true
    
    case "$command" in
        get)
            [[ $# -lt 1 ]] && { echo "Eroare: lipsește key" >&2; exit 1; }
            get_value "$1"
            ;;
        set)
            [[ $# -lt 2 ]] && { echo "Eroare: lipsesc key/value" >&2; exit 1; }
            set_value "$1" "$2"
            save_config
            ;;
        delete)
            [[ $# -lt 1 ]] && { echo "Eroare: lipsește key" >&2; exit 1; }
            delete_key "$1"
            save_config
            ;;
        list)
            list_config
            ;;
        validate)
            validate_config
            ;;
        export)
            export_config
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Comandă necunoscută: $command" >&2
            usage
            exit 1
            ;;
    esac
}

main "$@"
SCRIPT
chmod +x "$TEMA_DIR/config_manager.sh"

# Creează refactored_script.sh (template)
echo "📝 Creare refactored_script.sh (template)..."
cat > "$TEMA_DIR/refactored_script.sh" << 'SCRIPT'
#!/bin/bash
#
# refactored_script.sh - Script refactorizat
# Autor: [COMPLETEAZĂ]
# Data: [COMPLETEAZĂ]
#
# Original: broken_script.sh (cu probleme)
# Versiune: Refactorizată și îmbunătățită
#
# Utilizare: ./refactored_script.sh [opțiuni] <fișiere...>
#

# TODO: Adaugă set -euo pipefail
# set -euo pipefail

#
# VARIABILE GLOBALE
#
readonly SCRIPT_NAME="${0##*/}"

# TODO: Declară array-ul asociativ corect
# declare -A config

#
# FUNCȚII
#

usage() {
    # TODO: Implementează funcția usage
    cat << EOF
Utilizare: $SCRIPT_NAME [opțiuni] <fișiere...>

Procesează fișiere și numără liniile.

Opțiuni:
  -h, --help    Afișează acest mesaj
  -v, --verbose Mod verbose

Exemplu:
  $SCRIPT_NAME file1.txt file2.txt
EOF
}

cleanup() {
    # TODO: Implementează cleanup
    :
}

process_files() {
    # TODO: Refactorizează funcția process
    # - Folosește variabile locale
    # - Evită UUOC (useless use of cat)
    # - Pune ghilimele la variabile și arrays
    
    # ORIGINAL (problematic):
    # for file in ${files[@]}; do
    #     count=$((count + 1))
    #     result=$(cat $file | wc -l)
    #     echo "File $file has $result lines"
    # done
    
    # REFACTORIZAT:
    # local count=0
    # for file in "${files[@]}"; do
    #     ((count++))
    #     local result
    #     result=$(wc -l < "$file")
    #     echo "File $file has $result lines"
    # done
    
    echo "TODO: Implementează process_files refactorizat"
}

#
# MAIN
#

main() {
    # TODO: Adaugă trap pentru cleanup
    # trap cleanup EXIT
    
    # TODO: Parsare argumente cu "$@" (nu $*)
    local -a files=()
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                usage
                exit 0
                ;;
            -v|--verbose)
                # TODO: Implementează verbose
                shift
                ;;
            -*)
                echo "Opțiune necunoscută: $1" >&2
                exit 1
                ;;
            *)
                # TODO: Validează că fișierul există
                if [[ -f "$1" ]]; then
                    files+=("$1")
                else
                    echo "Avertisment: '$1' nu este un fișier valid" >&2
                fi
                shift
                ;;
        esac
    done
    
    # TODO: Verifică dacă avem fișiere de procesat
    if [[ ${#files[@]} -eq 0 ]]; then
        echo "Eroare: Nu au fost specificate fișiere" >&2
        usage
        exit 1
    fi
    
    # TODO: Inițializează config corect
    # declare -A config
    # config[name]="test"
    # config[value]="123"
    
    # Procesează fișierele
    process_files "${files[@]}"
    
    echo "Processed ${#files[@]} files"
    # echo "Config: ${config[name]}"
}

main "$@"
SCRIPT
chmod +x "$TEMA_DIR/refactored_script.sh"

# Creează fișiere de test
echo "📝 Creare fișiere de test..."

cat > "$TEMA_DIR/test_files/sample.log" << 'EOF'
[2025-01-15 10:00:00] [INFO] Application started
[2025-01-15 10:00:05] [DEBUG] Loading config from /etc/app.conf
[2025-01-15 10:00:10] [WARN] Config file not found, using defaults
[2025-01-15 10:00:15] [INFO] Server listening on port 8080
[2025-01-15 10:00:20] [ERROR] Connection refused to database
[2025-01-15 10:00:25] [INFO] Retry connection (attempt 1/3)
[2025-01-15 10:00:30] [INFO] Database connected
[2025-01-15 10:00:35] [INFO] Application started
[2025-01-15 10:01:00] [DEBUG] Processing request from 192.168.1.1
[2025-01-15 10:01:05] [INFO] Request completed in 45ms
[2025-01-15 10:01:10] [WARN] High memory usage: 85%
[2025-01-15 10:01:15] [ERROR] Out of memory
EOF

cat > "$TEMA_DIR/test_files/app.conf" << 'EOF'
# Application Configuration
# Environment: Development

HOST=localhost
PORT=8080
DEBUG=true

# Database Settings
DB_HOST=db.example.com
DB_PORT=5432
DB_NAME=development
DB_USER=admin

# Logging
LOG_LEVEL=DEBUG
LOG_FILE=/var/log/app.log
EOF

# Afișare finală
echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║              STRUCTURĂ CREATĂ CU SUCCES!                      ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo "Director: $TEMA_DIR"
echo ""
echo "Structură creată:"
if command -v tree &>/dev/null; then
    tree "$TEMA_DIR"
else
    find "$TEMA_DIR" -type f | sed "s|$TEMA_DIR/||" | sort
fi

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "PAȘI URMĂTORI:"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "1. Navighează în directorul temei:"
echo "   cd $TEMA_DIR"
echo ""
echo "2. Completează scripturile (caută TODO-urile):"
echo "   nano log_analyzer.sh"
echo "   nano config_manager.sh"
echo "   nano refactored_script.sh"
echo ""
echo "3. Verifică cu shellcheck:"
echo "   shellcheck *.sh"
echo ""
echo "4. Testează scripturile:"
echo "   ./log_analyzer.sh test_files/sample.log"
echo "   ./config_manager.sh list"
echo ""
echo "5. Creează arhiva pentru predare:"
echo "   cd ~ && zip -r tema_S05_${NUME// /_}.zip tema_S05_${NUME// /_}/"
echo ""
echo "Gata!"
