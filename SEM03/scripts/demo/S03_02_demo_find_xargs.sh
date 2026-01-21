#!/bin/bash
#
#  S03_02_demo_find_xargs.sh
# Demonstrație incrementală: find și xargs
#
#
# DESCRIERE:
#   Script de demonstrație pentru comanda find și xargs.
#   Prezintă conceptele incremental, de la simplu la complex.
#   Include exerciții interactive și predicții pentru studenți.
#
# UTILIZARE:
#   ./S03_02_demo_find_xargs.sh [opțiuni]
#
# OPȚIUNI:
#   -h, --help      Afișează acest ajutor
#   -i, --interactive   Mod interactiv cu pauze
#   -s, --section NUM   Rulează doar o secțiune (1-8)
#   -a, --all           Rulează toate secțiunile fără pauză
#   -c, --cleanup       Șterge directoarele demo
#
# AUTOR: Kit Seminar SO - ASE București
# VERSIUNE: 1.0
#

set -e  # Exit on error

#
# CONFIGURARE
#

DEMO_DIR="$HOME/find_demo_lab"
INTERACTIVE=false
RUN_SECTION=""
RUN_ALL=false

# Culori
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color
BOLD='\033[1m'
DIM='\033[2m'

#
# FUNCȚII UTILITARE
#

print_header() {
    local title="$1"
    local width=70
    echo ""
    echo -e "${CYAN}╔$(printf '═%.0s' $(seq 1 $((width-2))))╗${NC}"
    printf "${CYAN}║${NC} ${BOLD}${WHITE}%-$((width-4))s${NC} ${CYAN}║${NC}\n" "$title"
    echo -e "${CYAN}╚$(printf '═%.0s' $(seq 1 $((width-2))))╝${NC}"
    echo ""
}

print_subheader() {
    local title="$1"
    echo ""
    echo -e "${YELLOW}┌──────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${YELLOW}│${NC} ${BOLD}$title${NC}"
    echo -e "${YELLOW}└──────────────────────────────────────────────────────────────────┘${NC}"
}

print_concept() {
    local concept="$1"
    echo -e "\n${MAGENTA}💡 CONCEPT:${NC} ${WHITE}$concept${NC}\n"
}

print_command() {
    local cmd="$1"
    echo -e "${GREEN}▶${NC} ${BOLD}${WHITE}$cmd${NC}"
}

print_explanation() {
    local text="$1"
    echo -e "  ${GRAY}↳ $text${NC}"
}

print_prediction() {
    local question="$1"
    echo ""
    echo -e "${BLUE}┌─ 🤔 PREDICȚIE ─────────────────────────────────────────────────────┐${NC}"
    echo -e "${BLUE}│${NC} $question"
    echo -e "${BLUE}└────────────────────────────────────────────────────────────────────┘${NC}"
}

print_warning() {
    local text="$1"
    echo -e "\n${RED}⚠️  Capcană:${NC} ${YELLOW}$text${NC}"
}

print_tip() {
    local text="$1"
    echo -e "\n${GREEN}💚 TIP:${NC} $text"
}

run_demo() {
    local cmd="$1"
    local description="$2"
    
    print_command "$cmd"
    [[ -n "$description" ]] && print_explanation "$description"
    echo -e "${DIM}─────────── OUTPUT ───────────${NC}"
    eval "$cmd" 2>&1 || true
    echo -e "${DIM}──────────────────────────────${NC}"
}

pause_interactive() {
    if [[ "$INTERACTIVE" == true ]]; then
        echo ""
        echo -e "${CYAN}⏸  Apasă ENTER pentru a continua...${NC}"
        read -r
    fi
}

show_usage() {
    cat << 'EOF'
═══════════════════════════════════════════════════════════════════════════════
 📁 Demo find și xargs - Utilizare
═══════════════════════════════════════════════════════════════════════════════

SINTAXĂ:
  ./S03_02_demo_find_xargs.sh [opțiuni]

OPȚIUNI:
  -h, --help          Afișează acest ajutor
  -i, --interactive   Mod interactiv cu pauze între secțiuni
  -s, --section NUM   Rulează doar secțiunea specificată (1-8)
  -a, --all           Rulează toate secțiunile fără pauze
  -c, --cleanup       Șterge directoarele demo create

SECȚIUNI:
  1 - Introducere și setup
  2 - find: căutare după nume
  3 - find: căutare după tip și dimensiune
  4 - find: căutare după timp
  5 - find: operatori logici
  6 - find: acțiuni (-exec, -delete)
  7 - xargs: procesare batch
  8 - Combinații avansate find + xargs

EXEMPLE:
  ./S03_02_demo_find_xargs.sh -i              # Demo interactiv complet
  ./S03_02_demo_find_xargs.sh -s 3            # Doar secțiunea 3
  ./S03_02_demo_find_xargs.sh -a              # Totul fără pauze

═══════════════════════════════════════════════════════════════════════════════
EOF
}

#
# SETUP ENVIRONMENT
#

setup_demo_environment() {
    print_header "📁 SETUP: Crearea Mediului Demo"
    
    echo -e "${CYAN}Creez structura de directoare pentru demonstrație...${NC}\n"
    
    # Crează structura
    mkdir -p "$DEMO_DIR"/{project/{src,include,docs,tests,build},logs,data,backup,temp}
    
    # Fișiere cod C
    cat > "$DEMO_DIR/project/src/main.c" << 'CCODE'
#include <stdio.h>
int main() {
    printf("Hello, World!\n");
    return 0;
}
CCODE
    
    cat > "$DEMO_DIR/project/src/utils.c" << 'CCODE'
#include "utils.h"
void helper_function() {
    // Implementation
}
CCODE
    
    cat > "$DEMO_DIR/project/src/config.c" << 'CCODE'
#include "config.h"
// Configuration handling
CCODE
    
    # Fișiere header
    echo '/* Main header */' > "$DEMO_DIR/project/include/main.h"
    echo '/* Utils header */' > "$DEMO_DIR/project/include/utils.h"
    echo '/* Config header */' > "$DEMO_DIR/project/include/config.h"
    
    # Fișiere documentație
    echo "# Project README" > "$DEMO_DIR/project/docs/README.md"
    echo "API Documentation" > "$DEMO_DIR/project/docs/api.txt"
    echo "<html><body>Manual</body></html>" > "$DEMO_DIR/project/docs/manual.html"
    
    # Fișiere test Python
    for i in 1 2 3 4 5; do
        cat > "$DEMO_DIR/project/tests/test_$i.py" << PYCODE
#!/usr/bin/env python3
# Test file $i
import unittest

class Test$i(unittest.TestCase):
    def test_basic(self):
        self.assertTrue(True)

if __name__ == '__main__':
    unittest.main()
PYCODE
    done
    
    # Fișiere build (binare și obiecte)
    dd if=/dev/zero of="$DEMO_DIR/project/build/program.o" bs=1K count=50 2>/dev/null
    dd if=/dev/zero of="$DEMO_DIR/project/build/main.exe" bs=1K count=200 2>/dev/null
    
    # Log files cu timestamp-uri diferite
    for i in {1..10}; do
        echo "Log entry $i - $(date -d "-$i days" '+%Y-%m-%d %H:%M:%S')" > "$DEMO_DIR/logs/app_$i.log"
        touch -d "-$i days" "$DEMO_DIR/logs/app_$i.log"
    done
    
    # Fișiere mari pentru demonstrație -size
    dd if=/dev/zero of="$DEMO_DIR/data/small.dat" bs=1K count=10 2>/dev/null
    dd if=/dev/zero of="$DEMO_DIR/data/medium.dat" bs=1K count=500 2>/dev/null
    dd if=/dev/zero of="$DEMO_DIR/data/large.dat" bs=1M count=2 2>/dev/null
    dd if=/dev/zero of="$DEMO_DIR/data/huge.dat" bs=1M count=5 2>/dev/null
    
    # Fișiere cu spații în nume (pentru demonstrație xargs)
    touch "$DEMO_DIR/data/file with spaces.txt"
    touch "$DEMO_DIR/data/another file.txt"
    touch "$DEMO_DIR/data/my document.txt"
    
    # Fișiere backup
    cp "$DEMO_DIR/project/src/main.c" "$DEMO_DIR/backup/main.c.bak"
    cp "$DEMO_DIR/project/src/utils.c" "$DEMO_DIR/backup/utils.c.old"
    touch "$DEMO_DIR/backup/config~"
    
    # Fișiere temporare
    touch "$DEMO_DIR/temp/temp_001.tmp"
    touch "$DEMO_DIR/temp/cache_abc.tmp"
    touch "$DEMO_DIR/temp/.hidden_temp"
    
    # Link simbolic
    ln -sf "$DEMO_DIR/project/src/main.c" "$DEMO_DIR/project/main_link.c"
    
    # Afișează structura
    echo -e "${GREEN}✓ Structură creată:${NC}"
    echo ""
    tree "$DEMO_DIR" 2>/dev/null || find "$DEMO_DIR" -type d | head -20
    
    echo ""
    echo -e "${GREEN}✓ Setup complet!${NC}"
    echo -e "${GRAY}Locație: $DEMO_DIR${NC}"
}

cleanup_demo() {
    print_header "🧹 Cleanup"
    
    if [[ -d "$DEMO_DIR" ]]; then
        echo -e "${YELLOW}Șterg directorul demo: $DEMO_DIR${NC}"
        rm -rf "$DEMO_DIR"
        echo -e "${GREEN}✓ Cleanup complet!${NC}"
    else
        echo -e "${GRAY}Directorul demo nu există.${NC}"
    fi
}

#
# SECȚIUNEA 1: INTRODUCERE
#

section_1_intro() {
    print_header "📚 SECȚIUNEA 1: Introducere în find"
    
    print_concept "find - comanda de căutare recursivă în sistemul de fișiere"
    
    echo -e "${WHITE}SINTAXA GENERALĂ:${NC}"
    echo ""
    echo -e "  ${CYAN}find [CALE] [EXPRESII] [ACȚIUNI]${NC}"
    echo ""
    echo "  CALE      = unde să caute (. = curent, / = root, ~ = home)"
    echo "  EXPRESII  = criterii de filtrare (-name, -type, -size, etc.)"
    echo "  ACȚIUNI   = ce să facă cu rezultatele (-print, -exec, -delete)"
    
    echo ""
    echo -e "${WHITE}DE CE find în loc de ls?${NC}"
    echo ""
    echo "  • find caută RECURSIV (în toate subdirectoarele)"
    echo "  • find poate filtra după ORICE atribut"
    echo "  • find poate EXECUTA comenzi pe rezultate"
    echo "  • find poate combina condiții cu logică booleană"
    
    print_subheader "Setup mediu de lucru"
    
    setup_demo_environment
    
    pause_interactive
}

#
# SECȚIUNEA 2: CĂUTARE DUPĂ NUME
#

section_2_name() {
    print_header "📚 SECȚIUNEA 2: Căutare după Nume"
    
    cd "$DEMO_DIR"
    
    print_concept "-name și -iname: căutare după numele fișierului"
    
    # Demo 1: -name simplu
    print_subheader "2.1 Căutare exactă cu -name"
    
    print_prediction "Ce va găsi: find . -name 'main.c' ?"
    pause_interactive
    
    run_demo "find . -name 'main.c'" "Caută fișiere cu numele exact 'main.c'"
    
    # Demo 2: Wildcards
    print_subheader "2.2 Wildcards (globbing patterns)"
    
    print_warning "Pattern-urile trebuie să fie între ghilimele!"
    echo ""
    echo "  ✓ find . -name '*.c'     (corect)"
    echo "  ✗ find . -name *.c       (shell expandează înainte de find!)"
    
    print_prediction "Ce va găsi: find . -name '*.c' ?"
    pause_interactive
    
    run_demo "find . -name '*.c'" "Toate fișierele cu extensia .c"
    
    # Demo 3: -iname (case insensitive)
    print_subheader "2.3 Căutare case-insensitive cu -iname"
    
    # Creăm un fișier cu majuscule pentru demo
    touch "$DEMO_DIR/project/docs/README.TXT"
    
    run_demo "find . -name '*.txt'" "Case sensitive - nu găsește README.TXT"
    run_demo "find . -iname '*.txt'" "Case INsensitive - găsește și README.TXT"
    
    # Demo 4: Căutare în cale
    print_subheader "2.4 Căutare în calea completă cu -path"
    
    run_demo "find . -path '*/src/*'" "Fișiere care au 'src' în cale"
    run_demo "find . -path '*test*'" "Orice conține 'test' în cale"
    
    print_tip "Diferența: -name caută doar în NUMELE fișierului, -path în CALEA COMPLETĂ"
    
    pause_interactive
}

#
# SECȚIUNEA 3: CĂUTARE DUPĂ TIP ȘI DIMENSIUNE
#

section_3_type_size() {
    print_header "📚 SECȚIUNEA 3: Căutare după Tip și Dimensiune"
    
    cd "$DEMO_DIR"
    
    print_concept "-type: filtrare după tipul fișierului"
    
    print_subheader "3.1 Tipuri de fișiere"
    
    echo ""
    echo "  ${WHITE}Tipuri disponibile:${NC}"
    echo "  -type f  = fișier regular"
    echo "  -type d  = director"
    echo "  -type l  = link simbolic"
    echo "  -type b  = block device"
    echo "  -type c  = character device"
    echo "  -type p  = named pipe (FIFO)"
    echo "  -type s  = socket"
    
    print_prediction "Câte directoare sunt în structura demo?"
    pause_interactive
    
    run_demo "find . -type d" "Toate directoarele"
    run_demo "find . -type d | wc -l" "Numărare directoare"
    
    run_demo "find . -type f -name '*.c'" "Combină: fișiere regular cu extensia .c"
    
    run_demo "find . -type l" "Link-uri simbolice"
    
    # Dimensiune
    print_subheader "3.2 Căutare după dimensiune cu -size"
    
    echo ""
    echo "  ${WHITE}Sufixe pentru dimensiune:${NC}"
    echo "  c  = bytes"
    echo "  k  = kilobytes"
    echo "  M  = megabytes"
    echo "  G  = gigabytes"
    echo ""
    echo "  ${WHITE}Modificatori:${NC}"
    echo "  +N  = mai mare decât N"
    echo "  -N  = mai mic decât N"
    echo "  N   = exact N"
    
    print_prediction "Ce va găsi: find . -size +1M ?"
    pause_interactive
    
    run_demo "find . -type f -size +1M" "Fișiere mai mari de 1MB"
    
    run_demo "find . -type f -size +100k -size -1M" "Între 100KB și 1MB"
    
    # Afișare cu dimensiunea
    run_demo "find . -type f -size +100k -exec ls -lh {} \\;" "Cu dimensiuni afișate"
    
    print_tip "Folosește -ls în loc de -exec ls pentru format mai compact"
    
    run_demo "find . -type f -size +1M -ls" "Format compact cu -ls"
    
    pause_interactive
}

#
# SECȚIUNEA 4: CĂUTARE DUPĂ TIMP
#

section_4_time() {
    print_header "📚 SECȚIUNEA 4: Căutare după Timp"
    
    cd "$DEMO_DIR"
    
    print_concept "Opțiuni de timp: -mtime, -atime, -ctime, -mmin, -amin, -cmin"
    
    print_subheader "4.1 Timpii fișierelor Unix"
    
    echo ""
    echo "  ${WHITE}Trei timpi pentru fiecare fișier:${NC}"
    echo ""
    echo "  mtime (modification) = când s-a modificat CONȚINUTUL"
    echo "  atime (access)       = când s-a ACCESAT (citit)"
    echo "  ctime (change)       = când s-au modificat METADATELE (permisiuni, owner)"
    
    echo ""
    echo "  ${WHITE}Unități:${NC}"
    echo "  -mtime N  = N zile în urmă"
    echo "  -mmin N   = N minute în urmă"
    
    echo ""
    echo "  ${WHITE}Modificatori:${NC}"
    echo "  +N  = mai vechi de N"
    echo "  -N  = mai recent de N"
    echo "  N   = exact N"
    
    print_subheader "4.2 Exemple practice"
    
    print_prediction "Ce înseamnă -mtime -7? (fișiere modificate în ultimele 7 zile)"
    pause_interactive
    
    run_demo "find ./logs -type f -mtime -7" "Modificate în ultimele 7 zile"
    
    run_demo "find ./logs -type f -mtime +3" "Mai vechi de 3 zile"
    
    run_demo "find ./logs -type f -mtime 5" "Exact acum 5 zile"
    
    # Minute
    print_subheader "4.3 Precizie în minute"
    
    # Creăm un fișier recent pentru demo
    touch "$DEMO_DIR/temp/just_created.txt"
    
    run_demo "find . -type f -mmin -5" "Modificate în ultimele 5 minute"
    
    # Comparație cu alt fișier
    print_subheader "4.4 Comparație cu -newer"
    
    run_demo "find . -type f -newer ./project/src/main.c" "Mai noi decât main.c"
    
    print_warning "Atenție la -atime: poate fi afectat de backup-uri și antivirus!"
    
    print_tip "Pentru scripturi de cleanup, testează întâi cu -print, apoi cu -delete"
    
    pause_interactive
}

#
# SECȚIUNEA 5: OPERATORI LOGICI
#

section_5_logic() {
    print_header "📚 SECȚIUNEA 5: Operatori Logici"
    
    cd "$DEMO_DIR"
    
    print_concept "Combinarea condițiilor: AND, OR, NOT"
    
    print_subheader "5.1 AND implicit"
    
    echo ""
    echo "  ${WHITE}Când pui mai multe expresii, find le combină cu AND implicit:${NC}"
    echo ""
    echo "  find . -type f -name '*.c'  =  find . -type f AND -name '*.c'"
    
    run_demo "find . -type f -name '*.c'" "Fișiere regular ȘI cu extensia .c"
    
    # OR
    print_subheader "5.2 OR explicit cu -o"
    
    print_prediction "Cum găsești fișiere .c SAU .h ?"
    pause_interactive
    
    run_demo "find . -type f \\( -name '*.c' -o -name '*.h' \\)" "Fișiere .c SAU .h"
    
    print_warning "Parantezele trebuie escape-uite: \\( și \\)"
    
    # NOT
    print_subheader "5.3 NOT cu !"
    
    run_demo "find . -type f ! -name '*.c'" "Fișiere care NU sunt .c"
    
    run_demo "find . -type f ! -path '*/build/*'" "Excludem directorul build"
    
    # Combinații complexe
    print_subheader "5.4 Combinații complexe"
    
    echo ""
    echo "  ${WHITE}Găsește: fișiere mari care NU sunt în build și sunt .c sau .py${NC}"
    
    run_demo "find . -type f -size +10k ! -path '*/build/*' \\( -name '*.c' -o -name '*.py' \\)" \
             "Expresie complexă cu AND, OR, NOT"
    
    print_tip "Construiește expresiile incremental și testează la fiecare pas!"
    
    pause_interactive
}

#
# SECȚIUNEA 6: ACȚIUNI
#

section_6_actions() {
    print_header "📚 SECȚIUNEA 6: Acțiuni"
    
    cd "$DEMO_DIR"
    
    print_concept "Ce facem cu rezultatele: -print, -exec, -delete"
    
    print_subheader "6.1 Variante de print"
    
    echo ""
    echo "  ${WHITE}Opțiuni de afișare:${NC}"
    echo "  -print     = output standard (implicit)"
    echo "  -print0    = separă cu NULL (pentru xargs -0)"
    echo "  -printf    = format personalizat"
    echo "  -ls        = format similar cu ls -l"
    
    run_demo "find ./project/src -name '*.c' -ls" "Format ls pentru fișiere .c"
    
    run_demo "find ./project/src -name '*.c' -printf '%s bytes: %p\\n'" "Format personalizat"
    
    # -exec
    print_subheader "6.2 Execuție cu -exec"
    
    echo ""
    echo "  ${WHITE}Sintaxa -exec:${NC}"
    echo ""
    echo "  -exec command {} \\;   = execută pentru FIECARE fișier"
    echo "  -exec command {} +    = execută o singură dată cu TOATE fișierele"
    
    print_prediction "Care e diferența dintre \\; și + ?"
    pause_interactive
    
    echo ""
    echo "  Cu \\;  :  wc -l file1.c; wc -l file2.c; wc -l file3.c"
    echo "  Cu +   :  wc -l file1.c file2.c file3.c"
    echo ""
    echo "  + este mult mai EFICIENT (un singur proces)!"
    
    run_demo "find ./project/src -name '*.c' -exec wc -l {} \\;" "Cu \\; (separat)"
    run_demo "find ./project/src -name '*.c' -exec wc -l {} +" "Cu + (batch)"
    
    # -ok pentru confirmare
    print_subheader "6.3 Confirmare cu -ok"
    
    echo ""
    echo "  ${WHITE}-ok este ca -exec, dar cere confirmare pentru fiecare:${NC}"
    echo ""
    echo "  (Nu rulăm efectiv pentru că ar cere input interactiv)"
    echo ""
    print_command "find . -name '*.tmp' -ok rm {} \\;"
    print_explanation "Va întreba: < rm ... ./temp/temp_001.tmp > ?"
    
    # -delete
    print_subheader "6.4 Ștergere cu -delete"
    
    print_warning "-delete ȘTERGE FĂRĂ CONFIRMARE! Testează întâi cu -print!"
    
    echo ""
    echo "  ${WHITE}Pattern SIGUR pentru ștergere:${NC}"
    echo ""
    echo "  1. Testează:  find . -name '*.tmp' -print"
    echo "  2. Verifică output-ul cu atenție"
    echo "  3. Șterge:    find . -name '*.tmp' -delete"
    
    # Demo safe: creăm și ștergem fișiere temporare
    touch "$DEMO_DIR/temp/deleteme_{1..3}.test"
    
    run_demo "find ./temp -name '*.test' -print" "PASUL 1: Verifică ce va șterge"
    
    echo ""
    echo -e "${YELLOW}Acum putem șterge în siguranță:${NC}"
    run_demo "find ./temp -name '*.test' -delete" "PASUL 2: Șterge"
    run_demo "find ./temp -name '*.test' -print" "VERIFICARE: Nu mai există"
    
    print_tip "-delete implică -depth (procesează fișierele înaintea directoarelor)"
    
    pause_interactive
}

#
# SECȚIUNEA 7: XARGS
#

section_7_xargs() {
    print_header "📚 SECȚIUNEA 7: xargs - Procesare Batch"
    
    cd "$DEMO_DIR"
    
    print_concept "xargs: construiește și execută comenzi din input standard"
    
    print_subheader "7.1 De ce xargs?"
    
    echo ""
    echo "  ${WHITE}Problema cu pipe simplu:${NC}"
    echo ""
    echo "  find . -name '*.c' | rm    ← NU FUNCȚIONEAZĂ!"
    echo "  rm nu citește din stdin"
    echo ""
    echo "  ${WHITE}Soluția: xargs${NC}"
    echo ""
    echo "  find . -name '*.c' | xargs rm    ← FUNCȚIONEAZĂ"
    echo "  xargs ia input și construiește argumente pentru rm"
    
    print_subheader "7.2 Exemplu de bază"
    
    run_demo "find ./project -name '*.c' | xargs wc -l" "Numără linii în toate fișierele .c"
    
    # Problema cu spațiile
    print_subheader "7.3 ⚠️ PROBLEMA CU SPAȚIILE"
    
    print_warning "xargs implicit separă pe spații și newlines!"
    
    echo ""
    echo "  Avem fișiere cu spații în nume în ./data:"
    run_demo "ls -la ./data/*.txt 2>/dev/null || echo 'vezi cu find'" ""
    run_demo "find ./data -name '*.txt' -type f" "Fișiere .txt în data"
    
    print_prediction "Ce se întâmplă cu: find ./data -name '*.txt' | xargs echo ?"
    pause_interactive
    
    run_demo "find ./data -name '*.txt' | xargs echo 'Procesez:'" \
             "xargs tratează 'file with spaces.txt' ca 3 argumente!"
    
    # Soluția
    print_subheader "7.4 Soluția: -print0 și -0"
    
    echo ""
    echo "  ${WHITE}Pattern-ul CORECT:${NC}"
    echo ""
    echo "  find ... -print0 | xargs -0 command"
    echo ""
    echo "  -print0  = separă cu NULL (\\0) în loc de newline"
    echo "  xargs -0 = așteaptă NULL ca separator"
    
    run_demo "find ./data -name '*.txt' -print0 | xargs -0 echo 'Procesez:'" \
             "Acum fiecare fișier e tratat corect!"
    
    # Opțiuni xargs
    print_subheader "7.5 Opțiuni utile xargs"
    
    echo ""
    echo "  ${WHITE}Opțiuni importante:${NC}"
    echo "  -0       = separator NULL"
    echo "  -n NUM   = maximum NUM argumente per comandă"
    echo "  -I{}     = înlocuiește {} cu fiecare argument"
    echo "  -P NUM   = rulează NUM procese în paralel"
    echo "  -t       = afișează comanda înainte de execuție"
    echo "  -p       = cere confirmare"
    
    run_demo "find ./project/src -name '*.c' | xargs -t wc -l" "Cu -t: afișează comanda"
    
    run_demo "find ./project/src -name '*.c' | xargs -n1 wc -l" "Cu -n1: câte unul"
    
    # -I pentru placeholder
    print_subheader "7.6 Placeholder cu -I"
    
    run_demo "find ./project/src -name '*.c' | xargs -I{} echo 'Fișier găsit: {}'" \
             "-I{} permite poziționare flexibilă"
    
    # Paralel
    print_subheader "7.7 Procesare paralelă cu -P"
    
    echo ""
    echo "  ${WHITE}Pentru task-uri CPU-intensive:${NC}"
    print_command "find . -name '*.jpg' | xargs -P4 -I{} convert {} -resize 50% small_{}"
    print_explanation "Procesează 4 imagini simultan"
    
    print_tip "Combină -P cu -n pentru control mai fin"
    
    pause_interactive
}

#
# SECȚIUNEA 8: COMBINAȚII AVANSATE
#

section_8_advanced() {
    print_header "📚 SECȚIUNEA 8: Combinații Avansate"
    
    cd "$DEMO_DIR"
    
    print_concept "Scenarii reale și pattern-uri avansate"
    
    print_subheader "8.1 🧹 Cleanup: Șterge fișiere vechi de backup"
    
    echo ""
    echo "  ${WHITE}Scenariu: Șterge fișierele .bak mai vechi de 30 zile${NC}"
    
    run_demo "find ./backup -name '*.bak' -mtime +30 -type f -print" \
             "Pasul 1: Verifică"
    
    echo ""
    print_command "find ./backup -name '*.bak' -mtime +30 -type f -delete"
    print_explanation "Pasul 2: Șterge (nu rulăm efectiv)"
    
    print_subheader "8.2 📊 Raport: Top 10 cele mai mari fișiere"
    
    run_demo "find . -type f -printf '%s %p\\n' | sort -rn | head -10" \
             "Sortare descrescătoare după dimensiune"
    
    # Cu format mai frumos
    echo ""
    echo "  ${WHITE}Versiune formatată:${NC}"
    run_demo "find . -type f -printf '%s %p\\n' | sort -rn | head -10 | while read size path; do echo \"\$((\$size/1024)) KB: \$path\"; done" \
             "Cu conversie în KB"
    
    print_subheader "8.3 🔐 Securitate: Găsește fișiere cu permisiuni periculoase"
    
    run_demo "find . -type f -perm -o=w -ls 2>/dev/null" \
             "Fișiere writable de oricine (world-writable)"
    
    echo ""
    echo "  ${WHITE}În sistemul real, pentru audit de securitate:${NC}"
    print_command "find /home -type f -perm -4000 -ls 2>/dev/null"
    print_explanation "Găsește fișiere cu SUID (run as owner)"
    
    print_subheader "8.4 📁 Sincronizare: Copiază doar fișierele noi"
    
    echo ""
    echo "  ${WHITE}Copiază fișiere .c modificate azi într-un director de backup:${NC}"
    
    mkdir -p "$DEMO_DIR/daily_backup"
    
    run_demo "find ./project -name '*.c' -mtime 0 -exec cp {} ./daily_backup/ \\;" \
             "Copiază fișiere modificate azi"
    
    run_demo "ls -la ./daily_backup/" "Verifică backup-ul"
    
    print_subheader "8.5 🔄 Procesare batch cu feedback"
    
    echo ""
    echo "  ${WHITE}Procesează fișiere și arată progresul:${NC}"
    
    run_demo "find ./project -name '*.py' | xargs -I{} sh -c 'echo \"Procesez: {}\" && wc -l {} | tail -1'" \
             "Feedback pentru fiecare fișier"
    
    print_subheader "8.6 📋 Pattern final: Script de cleanup complet"
    
    echo ""
    cat << 'SCRIPT'
╔═══════════════════════════════════════════════════════════════════════════════╗
║ Pattern de CLEANUP SIGUR:                                                     ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║  #!/bin/bash                                                                  ║
║  # Cleanup script sigur                                                       ║
║                                                                               ║
║  TARGET="/var/log"                                                            ║
║  DAYS=30                                                                      ║
║  PATTERN="*.log"                                                              ║
║                                                                               ║
║  # PASUL 1: Listează ce va fi șters                                           ║
║  echo "Fișiere care vor fi șterse:"                                           ║
║  find "$TARGET" -name "$PATTERN" -mtime +$DAYS -type f -print                 ║
║                                                                               ║
║  # PASUL 2: Confirmă                                                          ║
║  read -p "Continui cu ștergerea? (y/N): " confirm                             ║
║  [[ "$confirm" != "y" ]] && exit 0                                            ║
║                                                                               ║
║  # PASUL 3: Șterge cu logging                                                 ║
║  find "$TARGET" -name "$PATTERN" -mtime +$DAYS -type f \                      ║
║       -print -delete >> /var/log/cleanup.log 2>&1                             ║
║                                                                               ║
║  echo "Cleanup complet. Vezi /var/log/cleanup.log"                            ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
SCRIPT
    
    print_tip "Întotdeauna: PRINT → VERIFY → DELETE!"
    
    pause_interactive
}

#
# REZUMAT FINAL
#

show_summary() {
    print_header "📋 REZUMAT: find și xargs"
    
    cat << 'SUMMARY'
╔═══════════════════════════════════════════════════════════════════════════════╗
║                          CHEAT SHEET RAPID                                    ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║ CĂUTARE DUPĂ NUME:                                                            ║
║   find . -name "*.txt"              # După nume (case-sensitive)              ║
║   find . -iname "*.txt"             # Case-insensitive                        ║
║   find . -path "*test*"             # În calea completă                       ║
║                                                                               ║
║ CĂUTARE DUPĂ TIP:                                                             ║
║   find . -type f                    # Fișiere                                 ║
║   find . -type d                    # Directoare                              ║
║   find . -type l                    # Symlinks                                ║
║                                                                               ║
║ CĂUTARE DUPĂ DIMENSIUNE:                                                      ║
║   find . -size +1M                  # Mai mare de 1MB                         ║
║   find . -size -100k                # Mai mic de 100KB                        ║
║                                                                               ║
║ CĂUTARE DUPĂ TIMP:                                                            ║
║   find . -mtime -7                  # Modificat în ultimele 7 zile            ║
║   find . -mmin -30                  # Modificat în ultimele 30 min            ║
║                                                                               ║
║ OPERATORI LOGICI:                                                             ║
║   find . -type f -name "*.c"        # AND implicit                            ║
║   find . \( -name "*.c" -o -name "*.h" \)   # OR                              ║
║   find . ! -name "*.o"              # NOT                                     ║
║                                                                               ║
║ ACȚIUNI:                                                                      ║
║   find . -name "*.c" -exec wc -l {} \;      # Câte unul                       ║
║   find . -name "*.c" -exec wc -l {} +       # Toate odată (eficient)          ║
║   find . -name "*.tmp" -delete              # Șterge (ATENȚIE!)               ║
║                                                                               ║
║ XARGS:                                                                        ║
║   find . -name "*.c" | xargs wc -l          # Procesare batch                 ║
║   find . -print0 | xargs -0 cmd             # Gestionare spații              ║
║   find . | xargs -I{} cp {} /backup/        # Cu placeholder                  ║
║   find . | xargs -P4 -n1 process            # Paralel                         ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
SUMMARY

    echo ""
    echo -e "${GREEN}✓ Demo complet!${NC}"
    echo ""
    echo -e "Pentru cleanup: ${CYAN}./S03_02_demo_find_xargs.sh -c${NC}"
    echo ""
}

#
# PARSARE ARGUMENTE ȘI MAIN
#

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_usage
                exit 0
                ;;
            -i|--interactive)
                INTERACTIVE=true
                shift
                ;;
            -s|--section)
                RUN_SECTION="$2"
                shift 2
                ;;
            -a|--all)
                RUN_ALL=true
                shift
                ;;
            -c|--cleanup)
                cleanup_demo
                exit 0
                ;;
            *)
                echo -e "${RED}Opțiune necunoscută: $1${NC}"
                show_usage
                exit 1
                ;;
        esac
    done
}

main() {
    parse_args "$@"
    
    # Verifică dacă demo environment există
    if [[ ! -d "$DEMO_DIR" ]] && [[ "$RUN_SECTION" != "1" ]] && [[ -z "$RUN_SECTION" ]]; then
        echo -e "${YELLOW}Setup inițial necesar. Rulez secțiunea 1...${NC}"
        section_1_intro
    fi
    
    # Rulează secțiune specifică sau toate
    if [[ -n "$RUN_SECTION" ]]; then
        case "$RUN_SECTION" in
            1) section_1_intro ;;
            2) section_2_name ;;
            3) section_3_type_size ;;
            4) section_4_time ;;
            5) section_5_logic ;;
            6) section_6_actions ;;
            7) section_7_xargs ;;
            8) section_8_advanced ;;
            *)
                echo -e "${RED}Secțiune invalidă: $RUN_SECTION (trebuie 1-8)${NC}"
                exit 1
                ;;
        esac
    else
        # Rulează tot
        section_1_intro
        section_2_name
        section_3_type_size
        section_4_time
        section_5_logic
        section_6_actions
        section_7_xargs
        section_8_advanced
    fi
    
    show_summary
}

# Rulează
main "$@"
