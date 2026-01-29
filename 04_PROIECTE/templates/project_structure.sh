#!/bin/bash
#===============================================================================
# NUME:        project_structure.sh
# DESCRIERE:   Generează structura de bază pentru un proiect SO
# AUTOR:       Kit SO - ASE CSIE
# VERSIUNE:    1.0.1
# MODIFICAT:   Rezolvat conflict heredoc delimiters (EOF nested)
#===============================================================================

set -euo pipefail

usage() {
    cat << EOF
Utilizare: $(basename "$0") <project_name> [project_id]

Generează structura de directoare standard pentru un proiect SO.

Argumente:
  project_name  Numele proiectului (va fi numele directorului)
  project_id    ID opțional (ex: E01, M05) - adăugat în README

Exemple:
  $(basename "$0") my_project
  $(basename "$0") file_auditor E01

Structura generată:
  project_name/
  ├── README.md
  ├── Makefile
  ├── .gitignore
  ├── src/
  │   ├── main.sh
  │   └── lib/
  │       └── utils.sh
  ├── etc/
  │   └── config.conf
  ├── tests/
  │   └── test_main.sh
  ├── docs/
  │   ├── INSTALL.md
  │   └── USAGE.md
  └── examples/
      └── example_basic.sh
EOF
}

[[ $# -lt 1 ]] && { usage; exit 1; }

PROJECT_NAME="$1"
PROJECT_ID="${2:-}"

[[ -e "$PROJECT_NAME" ]] && { echo "Eroare: '$PROJECT_NAME' deja există"; exit 1; }

echo "Creare structură proiect: $PROJECT_NAME"
echo ""

# Creare directoare
mkdir -p "$PROJECT_NAME"/{src/lib,etc,tests,docs,examples}

# README.md
cat > "$PROJECT_NAME/README.md" << EOF
# $PROJECT_NAME ${PROJECT_ID:+($PROJECT_ID)}

> **Sisteme de Operare** | ASE București - CSIE

##  Descriere

[Descriere scurtă a proiectului]

##  Instalare

\`\`\`bash
git clone [url]
cd $PROJECT_NAME
make install
\`\`\`

### Dependențe

- Bash 5.0+
- [Alte dependențe]

##  Utilizare

\`\`\`bash
./$PROJECT_NAME [opțiuni] <argumente>
\`\`\`

### Opțiuni

| Opțiune | Descriere |
|---------|-----------|
| -h, --help | Afișează ajutor |
| -v, --verbose | Mod verbose |

##  Structură Proiect

\`\`\`
$PROJECT_NAME/
├── src/           # Cod sursă
├── etc/           # Configurări
├── tests/         # Teste
├── docs/          # Documentație
└── examples/      # Exemple
\`\`\`

##  Testare

\`\`\`bash
make test
\`\`\`

##  Documentație

- [INSTALL.md](docs/INSTALL.md) - Instrucțiuni instalare
- [USAGE.md](docs/USAGE.md) - Manual utilizare

##  Autor

[Nume Prenume] - [Grupă]

##  Licență

Proiect educațional - ASE CSIE SO
EOF

# Makefile
cat > "$PROJECT_NAME/Makefile" << 'MAKEFILE_CONTENT'
.PHONY: all test lint install clean help

SHELL := /bin/bash
NAME := $(shell basename $(CURDIR))

all: lint test

test:
	@echo "═══ Rulare teste ═══"
	@./tests/test_main.sh

lint:
	@echo "═══ Verificare ShellCheck ═══"
	@shellcheck -x src/*.sh src/lib/*.sh 2>/dev/null || true

install:
	@echo "═══ Instalare ═══"
	@mkdir -p ~/.local/bin
	@cp src/main.sh ~/.local/bin/$(NAME)
	@chmod +x ~/.local/bin/$(NAME)
	@echo "Instalat în ~/.local/bin/$(NAME)"

clean:
	@echo "═══ Curățare ═══"
	@rm -rf /tmp/$(NAME)_*
	@find . -name "*.tmp" -delete

help:
	@echo "Comenzi disponibile:"
	@echo "  make test    - Rulează testele"
	@echo "  make lint    - Verifică ShellCheck"
	@echo "  make install - Instalează local"
	@echo "  make clean   - Curăță temporare"
MAKEFILE_CONTENT

# .gitignore
cat > "$PROJECT_NAME/.gitignore" << 'GITIGNORE_CONTENT'
# Python
__pycache__/
*.pyc
*.pyo

# Editor
.vscode/
.idea/
*.swp
*~

# OS
.DS_Store
Thumbs.db

# Temporare
*.tmp
*.bak
*.log

# Build
/build/
/dist/
GITIGNORE_CONTENT

# src/main.sh - ATENȚIE: folosim delimiter unic '__MAIN_SH__' 
# pentru a evita conflictul cu EOF-ul din interior (usage function)
cat > "$PROJECT_NAME/src/main.sh" << '__MAIN_SH__'
#!/bin/bash
#===============================================================================
# NUME:        main.sh
# DESCRIERE:   Script principal
# VERSIUNE:    1.0.0
#===============================================================================

set -euo pipefail
IFS=$'\n\t'

readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly VERSION="1.0.0"

# Source biblioteci
source "${SCRIPT_DIR}/lib/utils.sh"

#---------------------------------------
# Funcții
#---------------------------------------

usage() {
    cat << EOF
Utilizare: ${SCRIPT_NAME} [OPȚIUNI] <argument>

Descriere scurtă.

Opțiuni:
    -h, --help      Afișează acest mesaj
    -v, --verbose   Mod verbose
    -V, --version   Afișează versiunea

Exemple:
    ${SCRIPT_NAME} input.txt
    ${SCRIPT_NAME} -v --option value
EOF
}

version() {
    echo "${SCRIPT_NAME} versiunea ${VERSION}"
}

#---------------------------------------
# Parsare argumente
#---------------------------------------

VERBOSE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help) usage; exit 0 ;;
        -V|--version) version; exit 0 ;;
        -v|--verbose) VERBOSE=true; shift ;;
        -*) die "Opțiune necunoscută: $1" ;;
        *) break ;;
    esac
done

#---------------------------------------
# Main
#---------------------------------------

main() {
    log_info "Start ${SCRIPT_NAME}"
    
    # Implementare aici
    
    log_info "Done"
}

main "$@"
__MAIN_SH__
chmod +x "$PROJECT_NAME/src/main.sh"

# src/lib/utils.sh
cat > "$PROJECT_NAME/src/lib/utils.sh" << 'UTILS_CONTENT'
#!/bin/bash
# Funcții utilitare

# Culori
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*" >&2
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

die() {
    log_error "$1"
    exit "${2:-1}"
}
UTILS_CONTENT

# etc/config.conf
cat > "$PROJECT_NAME/etc/config.conf" << 'CONFIG_CONTENT'
# Configurare implicită
# Editează după necesități

# Setări generale
VERBOSE=false
LOG_LEVEL=INFO

# Setări specifice
# OPTION1=value1
# OPTION2=value2
CONFIG_CONTENT

# tests/test_main.sh - delimiter unic pentru că conține [[ ]]
cat > "$PROJECT_NAME/tests/test_main.sh" << '__TEST_SH__'
#!/bin/bash
# Teste pentru main.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MAIN="${SCRIPT_DIR}/../src/main.sh"

TESTS=0
PASSED=0

assert_exit_code() {
    local expected=$1
    shift
    "$@" >/dev/null 2>&1
    local actual=$?
    ((TESTS++))
    if [[ $actual -eq $expected ]]; then
        echo "✓ PASS: exit code $expected"
        ((PASSED++))
    else
        echo "✗ FAIL: expected $expected, got $actual"
    fi
}

echo "═══ Teste main.sh ═══"

# Test help
assert_exit_code 0 "$MAIN" --help

# Test version
assert_exit_code 0 "$MAIN" --version

# Adaugă mai multe teste

echo ""
echo "Rezultat: $PASSED/$TESTS teste passed"
[[ $PASSED -eq $TESTS ]]
__TEST_SH__
chmod +x "$PROJECT_NAME/tests/test_main.sh"

# docs/INSTALL.md
cat > "$PROJECT_NAME/docs/INSTALL.md" << EOF
# Instalare $PROJECT_NAME

## Cerințe Sistem

- Linux (Ubuntu 24.04 recomandat) sau WSL2
- Bash 5.0+
- [Alte dependențe]

## Pași Instalare

1. Clonează repository-ul:
   \`\`\`bash
   git clone [url]
   cd $PROJECT_NAME
   \`\`\`

2. Verifică dependențele:
   \`\`\`bash
   bash --version  # >= 5.0
   \`\`\`

3. Instalează:
   \`\`\`bash
   make install
   \`\`\`

## Verificare Instalare

\`\`\`bash
$PROJECT_NAME --version
\`\`\`

## Troubleshooting

### Eroare: Command not found

Adaugă \`~/.local/bin\` în PATH:
\`\`\`bash
export PATH="\$HOME/.local/bin:\$PATH"
\`\`\`
EOF

# docs/USAGE.md
cat > "$PROJECT_NAME/docs/USAGE.md" << EOF
# Manual Utilizare - $PROJECT_NAME

## Utilizare de Bază

\`\`\`bash
$PROJECT_NAME [opțiuni] <argument>
\`\`\`

## Opțiuni

| Opțiune | Descriere |
|---------|-----------|
| -h, --help | Afișează ajutor |
| -v, --verbose | Output detaliat |

## Exemple

### Exemplu 1: Utilizare simplă

\`\`\`bash
$PROJECT_NAME input.txt
\`\`\`

### Exemplu 2: Mod verbose

\`\`\`bash
$PROJECT_NAME -v input.txt
\`\`\`

## Configurare

Editează \`etc/config.conf\` pentru setări personalizate.
EOF

# examples/example_basic.sh
cat > "$PROJECT_NAME/examples/example_basic.sh" << EOF
#!/bin/bash
# Exemplu de utilizare de bază

SCRIPT_DIR="\$(cd "\$(dirname "\$0")" && pwd)"
MAIN="\${SCRIPT_DIR}/../src/main.sh"

echo "Exemplu de utilizare $PROJECT_NAME"
echo ""

# Rulare cu help
"\$MAIN" --help
EOF
chmod +x "$PROJECT_NAME/examples/example_basic.sh"

# Sumar
echo "✓ Structură creată cu succes!"
echo ""
echo "Structură generată:"
find "$PROJECT_NAME" -type f | sed 's/^/  /'
echo ""
echo "Pași următori:"
echo "  1. cd $PROJECT_NAME"
echo "  2. Editează src/main.sh cu logica proiectului"
echo "  3. Adaugă teste în tests/"
echo "  4. Completează README.md"
echo "  5. make test pentru verificare"
