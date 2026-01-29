#!/bin/bash
#
# SETUP SEMINAR - Pregătire mediu laborator
# Sisteme de Operare | ASE București - CSIE
# 
# Scop: Pregătește mediul de lucru pentru seminar
# Utilizare: ./setup_seminar.sh [--full | --minimal | --clean]
#

set -e

# Culori
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Directoare
WORK_DIR="$HOME/laborator_so"
SEMINAR_DIR="$WORK_DIR/seminar01"

# Funcții utilitare
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Banner
show_banner() {
    echo ""
    echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}        ${GREEN}SETUP SEMINAR 1-2: Shell Bash${NC}                         ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}        Sisteme de Operare | ASE București - CSIE             ${BLUE}║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Verifică și instalează tools (dacă are permisiuni)
install_tools() {
    log_info "Verificare tools necesare..."
    
    local tools_to_install=""
    local optional_tools="figlet lolcat cmatrix cowsay tree ncdu pv dialog"
    
    for tool in $optional_tools; do
        if ! command -v $tool &>/dev/null; then
            tools_to_install="$tools_to_install $tool"
        else
            log_success "$tool este instalat"
        fi
    done
    
    if [ -n "$tools_to_install" ]; then
        log_warning "Tools lipsă:$tools_to_install"
        
        if [ "$EUID" -eq 0 ] || command -v sudo &>/dev/null; then
            read -p "Dorești să le instalez? (y/n): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                log_info "Instalare tools..."
                sudo apt-get update -qq
                sudo apt-get install -y $tools_to_install
                log_success "Tools instalate!"
            fi
        else
            log_warning "Nu am permisiuni pentru instalare. Continuăm fără ele."
        fi
    fi
}

# Creează structura de directoare
create_structure() {
    log_info "Creare structură directoare..."
    
    # Directoare principale
    mkdir -p "$SEMINAR_DIR"/{navigare,variabile,config,globbing,exercitii}
    
    # Structură proiect demonstrativ
    mkdir -p "$SEMINAR_DIR/demo_proiect"/{src,docs,tests,build,config}
    
    log_success "Structură creată în $SEMINAR_DIR"
}

# Creează fișiere de test
create_test_files() {
    log_info "Creare fișiere de test..."
    
    cd "$SEMINAR_DIR"
    
    # Fișiere pentru demo navigare
    echo "Acesta este un fișier de test." > navigare/test.txt
    echo "Linia 1
Linia 2
Linia 3
Linia 4
Linia 5
Linia 6
Linia 7
Linia 8
Linia 9
Linia 10" > navigare/multe_linii.txt
    
    # Fișiere pentru demo variabile
    cat > variabile/demo_vars.sh << 'SCRIPT'
#!/bin/bash
# Demonstrație variabile

# Variabilă locală
LOCAL_VAR="Aceasta este locală"

# Variabilă de mediu
export GLOBAL_VAR="Aceasta este globală"

echo "=== În shell-ul curent ==="
echo "LOCAL_VAR: $LOCAL_VAR"
echo "GLOBAL_VAR: $GLOBAL_VAR"

echo ""
echo "=== În subshell ==="
bash -c 'echo "LOCAL_VAR: $LOCAL_VAR"'
bash -c 'echo "GLOBAL_VAR: $GLOBAL_VAR"'
SCRIPT
    chmod +x variabile/demo_vars.sh
    
    # Fișiere pentru demo quoting
    cat > variabile/demo_quoting.sh << 'SCRIPT'
#!/bin/bash
# Demonstrație quoting

NUME="Student"
DATA=$(date +%Y)

echo "=== Comparație Quoting ==="
echo ""
echo "1. Single quotes (literal):"
echo '   echo '\''Salut $NUME în $DATA'\'''
echo '   Rezultat: Salut $NUME în $DATA'
echo ""
echo "2. Double quotes (expandează):"
echo '   echo "Salut $NUME în $DATA"'
echo "   Rezultat: Salut $NUME în $DATA"
echo ""
echo "3. Fără quotes (expandează + word splitting):"
echo '   echo Salut    $NUME    în    $DATA'
echo -n "   Rezultat: "
echo Salut    $NUME    în    $DATA
SCRIPT
    chmod +x variabile/demo_quoting.sh
    
    # Fișiere pentru demo globbing
    cd globbing
    touch file{1..10}.txt
    touch doc{A..E}.pdf
    touch image{01..05}.jpg
    touch .hidden_file
    touch "Document cu spatii.txt"
    cd ..
    
    # Fișiere pentru proiect demo
    echo '#include <stdio.h>

int main() {
    printf("Hello, World!\\n");
    return 0;
}' > demo_proiect/src/main.c
    
    echo '# Proiect Demo
    
Acest proiect demonstrează structura unui proiect C.

## Compilare
```bash
gcc -o build/main src/main.c
```

## Rulare
```bash
./build/main
```' > demo_proiect/docs/README.md
    
    echo 'CC=gcc
CFLAGS=-Wall -Wextra

all: main

main: src/main.c
	$(CC) $(CFLAGS) -o build/main src/main.c

clean:
	rm -f build/main

.PHONY: all clean' > demo_proiect/Makefile
    
    log_success "Fișiere de test create"
}

# Backup .bashrc
backup_bashrc() {
    log_info "Backup .bashrc..."
    
    if [ -f "$HOME/.bashrc" ]; then
        cp "$HOME/.bashrc" "$HOME/.bashrc.backup.$(date +%Y%m%d_%H%M%S)"
        log_success "Backup salvat: ~/.bashrc.backup.*"
    else
        log_warning "~/.bashrc nu există"
    fi
}

# Creează fișier de exerciții rezolvate
create_solutions() {
    log_info "Creare soluții exerciții..."
    
    cat > "$SEMINAR_DIR/exercitii/solutii.sh" << 'SOLUTIONS'
#!/bin/bash
#
# SOLUȚII EXERCIȚII - Seminar 1
# NU DISTRIBUI STUDENȚILOR ÎNAINTE DE REZOLVARE!
#

echo "=== EXERCIȚIU 1: Navigare ==="
echo "# Afișează directorul curent"
echo "pwd"
echo ""
echo "# Mergi în /etc și listează fișierele"
echo "cd /etc && ls -la"
echo ""
echo "# Revino acasă"
echo "cd ~"
echo ""

echo "=== EXERCIȚIU 2: Creare structură ==="
echo "mkdir -p proiect/{src,docs,tests}"
echo "touch proiect/src/main.py"
echo "touch proiect/docs/README.md"
echo "tree proiect"
echo ""

echo "=== EXERCIȚIU 3: Variabile ==="
echo "# Variabilă locală"
echo 'NUME="Ion Popescu"'
echo 'echo "Salut, $NUME"'
echo ""
echo "# Variabilă de mediu"
echo 'export PROIECT="Laborator SO"'
echo 'bash -c '\''echo "Proiect: $PROIECT"'\'''
echo ""

echo "=== EXERCIȚIU 4: Globbing ==="
echo "# Listează toate fișierele .txt"
echo "ls *.txt"
echo ""
echo "# Listează file1.txt până la file5.txt"
echo "ls file[1-5].txt"
echo ""
echo "# Listează tot EXCEPTÂND .pdf"
echo "ls !(*.pdf)  # necesită shopt -s extglob"
echo ""
SOLUTIONS
    chmod +x "$SEMINAR_DIR/exercitii/solutii.sh"
    
    log_success "Soluții create (NU distribui studenților!)"
}

# Curățare
clean_environment() {
    log_info "Curățare mediu..."
    
    if [ -d "$WORK_DIR" ]; then
        read -p "Sigur dorești să ștergi $WORK_DIR? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$WORK_DIR"
            log_success "Mediu curățat"
        else
            log_warning "Curățare anulată"
        fi
    else
        log_warning "Directorul $WORK_DIR nu există"
    fi
}

# Verificare finală
verify_setup() {
    log_info "Verificare setup..."
    
    echo ""
    echo -e "${BLUE}Structură creată:${NC}"
    if command -v tree &>/dev/null; then
        tree -L 3 "$SEMINAR_DIR"
    else
        find "$SEMINAR_DIR" -type d | head -20
    fi
    
    echo ""
    echo -e "${BLUE}Fișiere de test:${NC}"
    ls -la "$SEMINAR_DIR/globbing/"
    
    echo ""
    echo -e "${GREEN}Setup complet!${NC}"
    echo -e "Directorul de lucru: ${YELLOW}$SEMINAR_DIR${NC}"
    echo ""
}

# Help
show_help() {
    echo "Utilizare: $0 [OPȚIUNE]"
    echo ""
    echo "Opțiuni:"
    echo "  --full      Setup complet (tools + structură + fișiere)"
    echo "  --minimal   Doar structură și fișiere (fără tools)"
    echo "  --clean     Șterge mediul de laborator"
    echo "  --help      Afișează acest ajutor"
    echo ""
}

#
# MAIN
#

show_banner

case "${1:-}" in
    --full)
        install_tools
        backup_bashrc
        create_structure
        create_test_files
        create_solutions
        verify_setup
        ;;
    --minimal)
        backup_bashrc
        create_structure
        create_test_files
        create_solutions
        verify_setup
        ;;
    --clean)
        clean_environment
        ;;
    --help|-h)
        show_help
        ;;
    *)
        # Default: minimal
        backup_bashrc
        create_structure
        create_test_files
        create_solutions
        verify_setup
        ;;
esac
