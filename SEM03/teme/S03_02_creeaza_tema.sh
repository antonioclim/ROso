#!/bin/bash
#
# S03_02_creeaza_tema.sh - Generator Variante Temă Seminar 5-6
# Sisteme de Operare | ASE București - CSIE
#
# Generează variante personalizate ale temei pentru fiecare student
# Previne copierea prin scenarii și cerințe unice
#
# Autor: Echipa SO
# Versiune: 1.0
# Data: Ianuarie 2025
#

set -o nounset
set -o errexit

# 
# CONSTANTE ȘI CONFIGURARE
# 

readonly VERSION="1.0"
readonly SCRIPT_NAME=$(basename "$0")
readonly OUTPUT_DIR="${OUTPUT_DIR:-./variante_teme}"
readonly TEMPLATE_DIR="${TEMPLATE_DIR:-./templates}"

# Culori pentru output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Arrays pentru generare variante
declare -a EXTENSIONS=("txt" "log" "md" "c" "py" "sh" "cfg" "conf" "json" "xml" "html" "css" "js")
declare -a DIRECTORIES=("src" "docs" "tests" "build" "config" "data" "logs" "backup" "temp" "cache" "lib" "include" "bin" "scripts")
declare -a SIZE_UNITS=("k" "M" "G")
declare -a TIME_PERIODS=("7" "14" "30" "60" "90")
declare -a CRON_HOURS=("1" "2" "3" "4" "5" "6" "23" "0")
declare -a CRON_MINUTES=("0" "15" "30" "45")
declare -a PERMISSIONS_SCENARIOS=("web_server" "shared_project" "private_data" "public_docs" "development" "production")
declare -a SCRIPT_MODES=("count" "search" "transform" "analyze" "validate" "convert")

# 
# FUNCȚII HELPER
# 

log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[OK]${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $*" >&2
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

usage() {
    cat << EOF
${BLUE}═══════════════════════════════════════════════════════════════════${NC}
       Generator Variante Temă - Seminar 5-6 Sisteme de Operare
${BLUE}═══════════════════════════════════════════════════════════════════${NC}

${GREEN}UTILIZARE:${NC}
    $SCRIPT_NAME [OPȚIUNI] <fișier_studenți>

${GREEN}DESCRIERE:${NC}
    Generează variante personalizate ale temei pentru fiecare student
    din lista furnizată. Fiecare variantă are scenarii și cerințe unice.

${GREEN}OPȚIUNI:${NC}
    -h, --help          Afișează acest mesaj
    -o, --output DIR    Director pentru output (default: ./variante_teme)
    -s, --seed NUM      Seed pentru randomizare (pentru reproducibilitate)
    -v, --verbose       Mod detaliat
    -p, --preview       Previzualizare fără a genera fișiere
    -z, --zip           Creează arhive individuale pentru fiecare student
    -a, --all-in-one    Generează un singur PDF cu toate variantele

${GREEN}FORMAT FIȘIER STUDENȚI:${NC}
    Fiecare linie: NUME_PRENUME,GRUPA,EMAIL
    Exemplu:
        Popescu_Ion,1234,ion.popescu@student.ase.ro
        Ionescu_Maria,1235,maria.ionescu@student.ase.ro

${GREEN}EXEMPLE:${NC}
    $SCRIPT_NAME studenti.csv
    $SCRIPT_NAME -o ./teme_generate -z studenti.csv
    $SCRIPT_NAME -s 42 -v studenti.csv

${GREEN}OUTPUT:${NC}
    Pentru fiecare student se generează:
    - tema_sem56_NUME_PRENUME/
      ├── README.md           (instrucțiuni personalizate)
      ├── CERINTE.md          (cerințe unice)
      ├── setup_tema.sh       (script de setup)
      └── structura_test/     (structură de test pentru find)

VERSIUNE: $VERSION
EOF
}

# Generează număr random într-un interval
random_range() {
    local min=$1
    local max=$2
    echo $((RANDOM % (max - min + 1) + min))
}

# Selectează element random dintr-un array
random_element() {
    local -n arr=$1
    echo "${arr[RANDOM % ${#arr[@]}]}"
}

# Generează hash unic din nume
generate_student_hash() {
    local name=$1
    echo "$name" | md5sum | cut -c1-8
}

# 
# GENERATOARE DE SCENARII
# 

# Generează scenarii pentru find
generate_find_scenarios() {
    local hash=$1
    local num_tasks=$2
    
    local scenarios=()
    
    # Task tipuri
    local task_types=(
        "name_search"
        "type_filter"
        "size_filter"
        "time_filter"
        "permission_filter"
        "combined_search"
        "exec_action"
        "xargs_batch"
        "delete_safe"
        "archive_find"
    )
    
    for i in $(seq 1 $num_tasks); do
        local task_type=${task_types[$((i-1))]}
        local ext1=$(random_element EXTENSIONS)
        local ext2=$(random_element EXTENSIONS)
        local dir=$(random_element DIRECTORIES)
        local size=$(random_range 1 100)
        local size_unit=$(random_element SIZE_UNITS)
        local days=$(random_element TIME_PERIODS)
        
        case $task_type in
            "name_search")
                scenarios+=("Găsește toate fișierele .$ext1 din directorul $dir/")
                ;;
            "type_filter")
                scenarios+=("Găsește toate directoarele goale din proiect")
                ;;
            "size_filter")
                scenarios+=("Găsește fișierele mai mari de ${size}${size_unit}")
                ;;
            "time_filter")
                scenarios+=("Găsește fișierele modificate în ultimele $days zile")
                ;;
            "permission_filter")
                local perm=$(random_range 600 777)
                scenarios+=("Găsește fișierele cu permisiunile exact $perm")
                ;;
            "combined_search")
                scenarios+=("Găsește fișierele .$ext1 SAU .$ext2 mai mari de ${size}k")
                ;;
            "exec_action")
                scenarios+=("Găsește fișierele .$ext1 și afișează dimensiunea fiecăruia")
                ;;
            "xargs_batch")
                scenarios+=("Folosește xargs pentru a număra liniile din toate fișierele .$ext1")
                ;;
            "delete_safe")
                scenarios+=("Șterge fișierele .tmp mai vechi de $days zile (cu confirmare)")
                ;;
            "archive_find")
                scenarios+=("Arhivează toate fișierele .$ext1 din $dir/ într-un tar.gz")
                ;;
        esac
    done
    
    printf '%s\n' "${scenarios[@]}"
}

# Generează specificații pentru script
generate_script_spec() {
    local hash=$1
    
    local mode=$(random_element SCRIPT_MODES)
    local options=()
    local required_options=("-h" "-v")
    local optional_options=("-o FILE" "-q" "-r" "-n NUM" "-p PATTERN" "-f FORMAT" "-e EXT")
    
    # Adaugă opțiuni random
    local num_opts=$(random_range 3 5)
    for i in $(seq 1 $num_opts); do
        local opt=${optional_options[$((RANDOM % ${#optional_options[@]}))]}
        [[ ! " ${options[*]} " =~ " ${opt} " ]] && options+=("$opt")
    done
    
    cat << EOF
SPECIFICAȚII SCRIPT fileprocessor.sh:

MOD PRINCIPAL: $mode

OPȚIUNI OBLIGATORII:
$(printf '  %s\n' "${required_options[@]}")
$(printf '  %s\n' "${options[@]}")

FUNCȚIONALITATE:
EOF
    
    case $mode in
        "count")
            echo "  - Numără linii, cuvinte și caractere în fișiere"
            echo "  - Suportă procesare multiplă fișiere"
            echo "  - Afișează totaluri la final"
            ;;
        "search")
            echo "  - Caută un pattern (regex) în fișiere"
            echo "  - Afișează linia și numărul liniei"
            echo "  - Suportă case-insensitive search"
            ;;
        "transform")
            echo "  - Transformă textul (uppercase/lowercase/capitalize)"
            echo "  - Poate salva în fișier sau stdout"
            echo "  - Suportă procesare în-place cu backup"
            ;;
        "analyze")
            echo "  - Analizează structura fișierului"
            echo "  - Raportează: encoding, line endings, longest line"
            echo "  - Detectează tipul conținutului"
            ;;
        "validate")
            echo "  - Validează format (JSON, XML, CSV)"
            echo "  - Raportează erori de sintaxă"
            echo "  - Oferă sugestii de corectare"
            ;;
        "convert")
            echo "  - Convertește între formate (csv<->json, tabs<->spaces)"
            echo "  - Păstrează structura datelor"
            echo "  - Suportă encoding diferite"
            ;;
    esac
}

# Generează scenarii permisiuni
generate_permission_scenarios() {
    local hash=$1
    local scenario=$(random_element PERMISSIONS_SCENARIOS)
    
    case $scenario in
        "web_server")
            cat << 'EOF'
SCENARIU: Server Web

Ai un director web_root/ cu structura:
- public/     (fișiere HTML, CSS, JS accesibile tuturor)
- private/    (configurări, date sensibile)
- uploads/    (fișiere încărcate de utilizatori)
- logs/       (log-uri aplicație)

CERINȚE:
1. public/* : readable de toți, writable doar de owner
2. private/* : accesibil doar owner (600/700)
3. uploads/ : writable de web server (group www-data)
4. logs/ : append-only (nu delete pentru alții)

Implementează auditul și corectarea.
EOF
            ;;
        "shared_project")
            cat << 'EOF'
SCENARIU: Proiect Partajat

Director project/ folosit de echipă:
- src/        (cod sursă)
- docs/       (documentație)
- build/      (artefacte compilare)
- shared/     (resurse comune)

CERINȚE:
1. Toți membrii grupului 'devteam' pot citi/scrie în src/ și docs/
2. build/ e recreat automat - poate fi șters de oricine din grup
3. shared/ are SGID - fișierele noi moștenesc grupul
4. Nimeni extern grupului nu are acces

Implementează auditul și corectarea.
EOF
            ;;
        "private_data")
            cat << 'EOF'
SCENARIU: Date Confidențiale

Director confidential/ cu:
- keys/       (chei SSH, API keys)
- passwords/  (fișiere cu parole)
- backups/    (backup-uri criptate)
- temp/       (fișiere temporare de procesare)

CERINȚE:
1. keys/ și passwords/: STRICT 600, owner doar
2. backups/: 640, owner și grup backup
3. temp/: poate avea permisiuni relaxate dar nu 777
4. Detectează și raportează orice fișier world-readable

Implementează auditul și corectarea.
EOF
            ;;
        "public_docs")
            cat << 'EOF'
SCENARIU: Documentație Publică

Director docs/ servit public:
- html/       (documentație generată)
- assets/     (imagini, CSS)
- downloads/  (fișiere descărcabile)
- admin/      (unelte de generare)

CERINȚE:
1. html/ și assets/: world-readable (644/755)
2. downloads/: world-readable, dar fișierele executabile sunt interzise
3. admin/: accesibil doar owner (nu public!)
4. Detectează fișiere cu permisiuni prea restrictive în public/

Implementează auditul și corectarea.
EOF
            ;;
        "development")
            cat << 'EOF'
SCENARIU: Mediu de Dezvoltare

Director ~/dev/ cu:
- projects/   (multiple proiecte)
- tools/      (scripturi utilitare)
- sandbox/    (experimente)
- .config/    (configurări IDE)

CERINȚE:
1. projects/: standard (644/755)
2. tools/*.sh: executabile (755)
3. sandbox/: permisiuni relaxate OK dar nu 777
4. .config/: privat (600/700)
5. Detectează scripturi fără +x

Implementează auditul și corectarea.
EOF
            ;;
        "production")
            cat << 'EOF'
SCENARIU: Mediu de Producție

Director /app/ cu aplicație în producție:
- bin/        (executabile)
- lib/        (biblioteci)
- config/     (configurări)
- data/       (date aplicație)
- run/        (PID files, sockets)

CERINȚE:
1. bin/*: owner root, executabil, nu writable de alții
2. lib/*: read-only pentru toți
3. config/: readable doar de owner și grup app
4. data/: writable de aplicație, citibil de monitoring
5. NO SUID/SGID pe nimic!

Implementează auditul și corectarea.
EOF
            ;;
    esac
}

# Generează cerințe cron
generate_cron_requirements() {
    local hash=$1
    
    local hour=$(random_element CRON_HOURS)
    local minute=$(random_element CRON_MINUTES)
    local interval=$(random_range 5 30)
    local day=$(random_range 1 28)
    local dow=$(random_range 0 6)
    
    cat << EOF
CERINȚE CRON JOBS:

JOB 1: Backup Zilnic
  - Oră: $hour:$minute
  - Acțiune: Rulează /home/user/scripts/backup.sh
  - Logging: Append la /var/log/backup.log
  - Cerințe: Redirect și stdout și stderr

JOB 2: Cleanup Periodic  
  - Interval: La fiecare $interval minute
  - Acțiune: Șterge fișierele .tmp mai vechi de 24h din /tmp
  - Cerințe: Folosește find, nu rm -rf

JOB 3: Monitorizare
  - Interval: La fiecare oră, la minutul $minute
  - Acțiune: Verifică spațiu disk, loghează dacă > 90%
  - Cerințe: Parsează output df

JOB 4: Sincronizare Săptămânală
  - Zi: $(echo "Duminică Luni Marți Miercuri Joi Vineri Sâmbătă" | cut -d' ' -f$((dow+1)))
  - Oră: 2:00 AM
  - Acțiune: rsync /home/user/important /backup/
  - Cerințe: Include --delete și logging

JOB 5: Raport Lunar
  - Zi: $day a fiecărei luni
  - Oră: Miezul nopții
  - Acțiune: Generează raport sistem și trimite pe email
  - Cerințe: Include du, df, uptime în raport
EOF
}

# 
# GENERARE VARIANTĂ COMPLETĂ
# 

generate_variant() {
    local name=$1
    local grupa=$2
    local email=$3
    local output_dir=$4
    
    local hash=$(generate_student_hash "$name")
    local student_dir="$output_dir/tema_sem56_$name"
    
    # Setează seed bazat pe hash pentru reproducibilitate
    RANDOM=$(printf "%d" "0x$hash")
    
    log_info "Generez variantă pentru: $name (hash: $hash)"
    
    # Creează structura
    mkdir -p "$student_dir"/{structura_test/{src,docs,build,tests},scripts}
    
    # Generează README personalizat
    cat > "$student_dir/README.md" << EOF
#  Tema Seminar 5-6: System Administrator Toolkit
## Variantă personalizată pentru: ${name//_/ }

**Grupa**: $grupa  
**Email**: $email  
**Cod variantă**: $hash  
**Data generării**: $(date '+%Y-%m-%d %H:%M:%S')

---

##  Instrucțiuni Importante

1. Această temă este **personalizată** pentru tine
2. Cerințele din CERINTE.md sunt **unice** pentru varianta ta
3. NU copia de la colegi - vor avea cerințe diferite
4. Folosește structura din \`structura_test/\` pentru a testa comenzile find

##  Conținut

- \`CERINTE.md\` - Cerințele tale specifice
- \`setup_tema.sh\` - Script pentru pregătirea mediului
- \`structura_test/\` - Structură de directoare pentru teste

##  Pași de Început

\`\`\`bash
# 1. Fă scriptul executabil
chmod +x setup_tema.sh

# 2. Rulează setup-ul
./setup_tema.sh

# 3. Citește cerințele
cat CERINTE.md

# 4. Începe lucrul!
\`\`\`

---

*Temă generată automat - Seminar 5-6 SO*
EOF

    # Generează CERINTE.md cu scenarii unice
    cat > "$student_dir/CERINTE.md" << EOF
#  Cerințe Specifice - Variantă $hash
## ${name//_/ } | Grupa $grupa

---

## Partea 1: Find Master (20%)

Creează scriptul \`comenzi_find.sh\` cu soluții pentru următoarele scenarii.
Lucrează în directorul \`structura_test/\`.

### Scenarii Find:

$(generate_find_scenarios "$hash" 10 | nl -w2 -s'. ')

### Cerințe:
- Fiecare comandă trebuie comentată
- Testează pe structura din \`structura_test/\`
- Folosește \`-print0 | xargs -0\` pentru nume cu spații

---

## Partea 2: Script Profesional (30%)

$(generate_script_spec "$hash")

### Cerințe tehnice:
- Shebang corect: \`#!/bin/bash\`
- Parsare cu \`getopts\`
- Funcție \`usage()\` completă
- Exit codes: 0=succes, 1=eroare utilizare, 2=eroare fișier
- Comentarii explicative

---

## Partea 3: Permission Manager (25%)

$(generate_permission_scenarios "$hash")

### Cerințe pentru permaudit.sh:
- Detectare automată a problemelor
- Raport cu severități (CRITIC/WARNING/INFO)
- Opțiune de corectare cu confirmare
- Output colorat în terminal

---

## Partea 4: Cron Jobs (15%)

$(generate_cron_requirements "$hash")

### Cerințe:
- Fișier \`cron_entries.txt\` cu toate liniile crontab
- Script \`backup.sh\` funcțional cu lock file
- Toate comenzile cu căi absolute
- Logging configurat corect

---

## Partea 5: Integration Challenge (10%)

Creează \`sysadmin_toolkit.sh\` - meniu interactiv care integrează:
1. Funcții find din Partea 1
2. Procesare fișiere din Partea 2
3. Audit permisiuni din Partea 3
4. Helper cron din Partea 4

---

##  Checklist Final

- [ ] Toate scripturile sunt executabile
- [ ] ShellCheck nu raportează erori
- [ ] Am testat pe structura din \`structura_test/\`
- [ ] README.md completat cu observații
- [ ] Arhiva: \`tema_sem56_${name}.tar.gz\`

---

**Cod variantă: $hash** - Folosește-l dacă ai întrebări despre cerințe.
EOF

    # Generează setup_tema.sh
    cat > "$student_dir/setup_tema.sh" << 'SETUP_EOF'
#!/bin/bash
#
# setup_tema.sh - Pregătire mediu pentru tema Sem 5-6
#

set -e

echo "🔧 Pregătire mediu pentru tema..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR="$SCRIPT_DIR/structura_test"

# Verifică că suntem în directorul corect
if [[ ! -f "$SCRIPT_DIR/CERINTE.md" ]]; then
    echo "❌ Eroare: Rulează din directorul temei!"
    exit 1
fi

# Creează structura de test
echo "📁 Creez structura de test..."

mkdir -p "$TEST_DIR"/{src/{core,utils,deprecated},docs/{api,guides,images},build/{debug,release},tests/{unit,integration,data},config,logs,temp,backup}

# Creează fișiere diverse
echo "📄 Creez fișiere de test..."

# Fișiere sursă
for f in main utils config helper; do
    echo "// $f.c - Source file" > "$TEST_DIR/src/core/$f.c"
    echo "// $f.h - Header file" > "$TEST_DIR/src/core/$f.h"
done

# Fișiere Python
for f in test_main test_utils test_integration; do
    echo "# $f.py - Test file" > "$TEST_DIR/tests/unit/$f.py"
done

# Documentație
echo "# README" > "$TEST_DIR/docs/README.md"
echo "# API Documentation" > "$TEST_DIR/docs/api/reference.md"
echo "User Guide" > "$TEST_DIR/docs/guides/guide.txt"

# Fișiere mari (pentru teste size)
dd if=/dev/zero of="$TEST_DIR/backup/large_backup.tar.gz" bs=1M count=5 2>/dev/null
dd if=/dev/zero of="$TEST_DIR/build/debug/core_dump.bin" bs=1M count=2 2>/dev/null

# Fișiere temporare
touch "$TEST_DIR/temp/session.tmp"
touch "$TEST_DIR/temp/cache.tmp"
touch "$TEST_DIR/logs/app.log"
touch "$TEST_DIR/logs/error.log"

# Setează timestamp-uri diferite pentru teste de timp
touch -d "60 days ago" "$TEST_DIR/src/deprecated/old_code.c"
touch -d "30 days ago" "$TEST_DIR/backup/old_backup.tar"
touch -d "7 days ago" "$TEST_DIR/logs/weekly.log"
touch -d "1 day ago" "$TEST_DIR/logs/daily.log"

# Fișiere cu spații în nume (pentru teste xargs)
touch "$TEST_DIR/docs/my document.txt"
touch "$TEST_DIR/docs/file with spaces.md"

# Setează permisiuni diverse pentru teste
chmod 777 "$TEST_DIR/temp/insecure.txt" 2>/dev/null || touch "$TEST_DIR/temp/insecure.txt"
chmod 600 "$TEST_DIR/config/secrets.cfg" 2>/dev/null || touch "$TEST_DIR/config/secrets.cfg"
chmod 755 "$TEST_DIR/src/core/main.c"

# Creează director gol pentru teste -empty
mkdir -p "$TEST_DIR/empty_dir"

echo ""
echo "✅ Setup complet!"
echo ""
echo "📊 Structură creată:"
find "$TEST_DIR" -maxdepth 2 | head -30
echo "   ... și mai multe"
echo ""
echo "🚀 Acum poți testa comenzile find în: $TEST_DIR"
SETUP_EOF

    chmod +x "$student_dir/setup_tema.sh"
    
    log_success "Variantă generată: $student_dir"
}

# 
# PROCESARE LISTĂ STUDENȚI
# 

process_students_file() {
    local file=$1
    local output_dir=$2
    local preview=${3:-0}
    local create_zip=${4:-0}
    
    if [[ ! -f "$file" ]]; then
        log_error "Fișierul nu există: $file"
        exit 1
    fi
    
    # Creează directorul output
    mkdir -p "$output_dir"
    
    local count=0
    local errors=0
    
    while IFS=',' read -r name grupa email || [[ -n "$name" ]]; do
        # Skip linii goale sau comentarii
        [[ -z "$name" || "$name" =~ ^# ]] && continue
        
        # Curăță whitespace
        name=$(echo "$name" | tr -d '[:space:]')
        grupa=$(echo "$grupa" | tr -d '[:space:]')
        email=$(echo "$email" | tr -d '[:space:]')
        
        # Validare
        if [[ -z "$name" || -z "$grupa" ]]; then
            log_warning "Linie invalidă ignorată: $name,$grupa,$email"
            ((errors++))
            continue
        fi
        
        if [[ $preview -eq 1 ]]; then
            echo "  📋 $name (grupa: $grupa) - hash: $(generate_student_hash "$name")"
        else
            generate_variant "$name" "$grupa" "${email:-N/A}" "$output_dir"
            
            if [[ $create_zip -eq 1 ]]; then
                local student_dir="$output_dir/tema_sem56_$name"
                (cd "$output_dir" && zip -rq "tema_sem56_$name.zip" "tema_sem56_$name")
                log_info "  Arhivă creată: tema_sem56_$name.zip"
            fi
        fi
        
        ((count++))
    done < "$file"
    
    echo ""
    log_success "Procesat: $count studenți"
    [[ $errors -gt 0 ]] && log_warning "Erori: $errors"
}

# 
# MAIN
# 

main() {
    local output_dir="$OUTPUT_DIR"
    local seed=""
    local verbose=0
    local preview=0
    local create_zip=0
    local input_file=""
    
    # Parsare argumente
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            -o|--output)
                output_dir="$2"
                shift 2
                ;;
            -s|--seed)
                seed="$2"
                shift 2
                ;;
            -v|--verbose)
                verbose=1
                shift
                ;;
            -p|--preview)
                preview=1
                shift
                ;;
            -z|--zip)
                create_zip=1
                shift
                ;;
            -*)
                log_error "Opțiune necunoscută: $1"
                usage
                exit 1
                ;;
            *)
                input_file="$1"
                shift
                ;;
        esac
    done
    
    # Verifică input
    if [[ -z "$input_file" ]]; then
        log_error "Lipsește fișierul cu studenți!"
        echo ""
        usage
        exit 1
    fi
    
    # Setează seed dacă specificat
    if [[ -n "$seed" ]]; then
        RANDOM=$seed
        log_info "Seed setat: $seed"
    fi
    
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════${NC}"
    echo -e "     ${GREEN}Generator Variante Temă - Seminar 5-6 SO${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    if [[ $preview -eq 1 ]]; then
        log_info "MOD PREVIEW - nu se generează fișiere"
        echo ""
    fi
    
    log_info "Fișier input: $input_file"
    log_info "Director output: $output_dir"
    echo ""
    
    process_students_file "$input_file" "$output_dir" "$preview" "$create_zip"
    
    echo ""
    if [[ $preview -eq 0 ]]; then
        log_success "Variante generate în: $output_dir"
        echo ""
        echo "📊 Conținut:"
        ls -la "$output_dir" | head -20
    fi
}

main "$@"
