#!/bin/bash
#
#  S03_04_demo_permissions.sh
# Demonstrație interactivă: Sistemul de permisiuni Unix
#
#
# DESCRIERE:
#   Script de demonstrație pentru permisiuni Unix: chmod (octal și simbolic),
#   chown, chgrp, umask, și permisiuni speciale (SUID, SGID, Sticky).
#   Include vizualizări ASCII și exerciții interactive.
#
# UTILIZARE:
#   ./S03_04_demo_permissions.sh [opțiuni]
#
# OPȚIUNI:
#   -h, --help          Afișează acest ajutor
#   -i, --interactive   Mod interactiv cu pauze
#   -s, --section NUM   Rulează doar o secțiune (1-8)
#   -c, --cleanup       Șterge directoarele demo
#   -t, --tool NAME     Rulează un tool specific (calculator, visualizer, audit)
#
#  Capcană:
#   - Toate exercițiile se fac în ~/permissions_demo (sandbox)
#   - NU se folosește chmod 777 ca soluție acceptabilă!
#   - Demonstrațiile SUID/SGID sunt doar conceptuale
#
# AUTOR: Kit Seminar SO - ASE București
# VERSIUNE: 1.0
#

set -e

#
# CONFIGURARE
#

DEMO_DIR="$HOME/permissions_demo"
INTERACTIVE=false
RUN_SECTION=""
TOOL_NAME=""

# Culori
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'
BG_RED='\033[41m'
BG_GREEN='\033[42m'
BG_YELLOW='\033[43m'

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

print_warning() {
    local text="$1"
    echo -e "\n${RED}⚠️  Capcană:${NC} ${YELLOW}$text${NC}"
}

print_danger() {
    local text="$1"
    echo -e "\n${BG_RED}${WHITE} ☠️  PERICOL ${NC} ${RED}$text${NC}"
}

print_tip() {
    local text="$1"
    echo -e "\n${GREEN}💚 TIP:${NC} $text"
}

print_command() {
    local cmd="$1"
    echo -e "${GREEN}▶${NC} ${BOLD}${WHITE}$cmd${NC}"
}

run_demo() {
    local cmd="$1"
    local description="$2"
    
    print_command "$cmd"
    [[ -n "$description" ]] && echo -e "  ${GRAY}↳ $description${NC}"
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
 🔐 Demo Permisiuni Unix - Utilizare
═══════════════════════════════════════════════════════════════════════════════

SINTAXĂ:
  ./S03_04_demo_permissions.sh [opțiuni]

OPȚIUNI:
  -h, --help          Afișează acest ajutor
  -i, --interactive   Mod interactiv cu pauze între secțiuni
  -s, --section NUM   Rulează doar secțiunea specificată (1-8)
  -c, --cleanup       Șterge directoarele demo
  -t, --tool NAME     Rulează un tool specific

SECȚIUNI:
  1 - Fundamentele permisiunilor (rwx)
  2 - Vizualizare și interpretare
  3 - chmod octal
  4 - chmod simbolic
  5 - umask
  6 - Permisiuni speciale (SUID, SGID, Sticky)
  7 - chown și chgrp
  8 - Best practices și audit securitate

TOOL-URI:
  calculator  - Calculator permisiuni octal ↔ simbolic
  visualizer  - Vizualizare grafică permisiuni
  audit       - Audit securitate director

EXEMPLE:
  ./S03_04_demo_permissions.sh -i              # Demo interactiv complet
  ./S03_04_demo_permissions.sh -s 3            # Doar chmod octal
  ./S03_04_demo_permissions.sh -t calculator   # Calculator permisiuni

═══════════════════════════════════════════════════════════════════════════════
EOF
}

#
# SETUP
#

setup_demo_environment() {
    print_subheader "Setup mediu de demonstrație"
    
    echo -e "${CYAN}Creez structura în $DEMO_DIR...${NC}\n"
    
    # Creează directoare
    mkdir -p "$DEMO_DIR"/{public,private,scripts,shared,fix_me,audit_test}
    
    # Fișiere publice
    echo "Public document" > "$DEMO_DIR/public/readme.txt"
    echo "Another public file" > "$DEMO_DIR/public/info.txt"
    chmod 644 "$DEMO_DIR/public/"*
    
    # Fișiere private
    echo "Secret API key: xyz123" > "$DEMO_DIR/private/secrets.txt"
    echo "Password: hunter2" > "$DEMO_DIR/private/credentials.txt"
    chmod 600 "$DEMO_DIR/private/"*
    
    # Scripturi
    cat > "$DEMO_DIR/scripts/backup.sh" << 'SCRIPT'
#!/bin/bash
echo "Running backup..."
SCRIPT
    
    cat > "$DEMO_DIR/scripts/deploy.sh" << 'SCRIPT'
#!/bin/bash
echo "Deploying application..."
SCRIPT
    
    chmod 755 "$DEMO_DIR/scripts/"*.sh
    
    # Director shared (pentru demo SGID)
    chmod 770 "$DEMO_DIR/shared"
    
    # Fișiere cu permisiuni greșite (pentru exerciții)
    echo "Config file" > "$DEMO_DIR/fix_me/config.cfg"
    chmod 777 "$DEMO_DIR/fix_me/config.cfg"  # Prea permisiv!
    
    echo "Database backup" > "$DEMO_DIR/fix_me/backup.sql"
    chmod 666 "$DEMO_DIR/fix_me/backup.sql"  # Prea permisiv!
    
    cat > "$DEMO_DIR/fix_me/run.sh" << 'SCRIPT'
#!/bin/bash
echo "Running..."
SCRIPT
    chmod 644 "$DEMO_DIR/fix_me/run.sh"  # Nu e executabil!
    
    # Fișiere pentru audit
    touch "$DEMO_DIR/audit_test/normal.txt"
    chmod 644 "$DEMO_DIR/audit_test/normal.txt"
    
    touch "$DEMO_DIR/audit_test/world_writable.txt"
    chmod 666 "$DEMO_DIR/audit_test/world_writable.txt"
    
    echo -e "${GREEN}✓ Setup complet!${NC}"
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
# SECȚIUNEA 1: FUNDAMENTELE PERMISIUNILOR
#

section_1_fundamentals() {
    print_header "📚 SECȚIUNEA 1: Fundamentele Permisiunilor"
    
    print_concept "Fiecare fișier are 3 seturi de permisiuni: Owner, Group, Others"
    
    print_subheader "1.1 Structura permisiunilor"
    
    cat << 'DIAGRAM'
╔═══════════════════════════════════════════════════════════════════════════════╗
║                    STRUCTURA OUTPUT-ULUI ls -l                                ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║      -rwxr-xr--  1  user  group  1234  Jan 15 10:30  file.txt                 ║
║      │└┬┘└┬┘└┬┘                                                               ║
║      │ │  │  └── Others (alții): r-- (read only)                              ║
║      │ │  └───── Group (grup): r-x (read + execute)                           ║
║      │ └──────── Owner (proprietar): rwx (toate)                              ║
║      └────────── Tip: - (fișier), d (director), l (link)                      ║
║                                                                               ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║ SEMNIFICAȚIA BIȚILOR:                                                         ║
║                                                                               ║
║   r (read)    = Poate citi conținutul                                         ║
║   w (write)   = Poate modifica conținutul                                     ║
║   x (execute) = Poate executa (fișier) sau accesa (director)                  ║
║   - (absent)  = Permisiunea nu este acordată                                  ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
DIAGRAM
    
    print_subheader "1.2 ⚠️ DIFERENȚĂ CRITICĂ: Permisiuni pe Fișier vs Director"
    
    cat << 'DIFF'
╔═══════════════════════════════════════════════════════════════════════════════╗
║               PE FIȘIER                    PE DIRECTOR                        ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║  r (read)    = citești conținutul     r = listezi conținutul (ls)             ║
║                                                                               ║
║  w (write)   = modifici conținutul    w = creezi/ștergi fișiere înăuntru      ║
║                                                                               ║
║  x (execute) = rulezi ca program      x = poți accesa (cd) directorul         ║
║                                           și fișierele din el                 ║
║                                                                               ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║ ⚠️  x pe DIRECTOR nu înseamnă "execuți directorul"!                           ║
║     Înseamnă că poți INTRA și ACCESA conținutul.                              ║
║                                                                               ║
║ ⚠️  Pentru a ȘTERGE un fișier, ai nevoie de w pe DIRECTOR,                    ║
║     nu pe fișier! (w pe fișier = modifici conținutul)                         ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
DIFF
    
    print_warning "Cea mai comună confuzie: x pe director ≠ executare!"
    
    pause_interactive
}

#
# SECȚIUNEA 2: VIZUALIZARE
#

section_2_visualization() {
    print_header "📚 SECȚIUNEA 2: Vizualizare și Interpretare"
    
    setup_demo_environment
    cd "$DEMO_DIR"
    
    print_subheader "2.1 Vizualizare cu ls -l"
    
    run_demo "ls -la" "Listare completă cu permisiuni"
    
    print_subheader "2.2 Interpretare exemple"
    
    echo ""
    echo "  ${WHITE}Să analizăm câteva linii:${NC}"
    echo ""
    
    run_demo "ls -l scripts/backup.sh" ""
    echo ""
    echo "  -rwxr-xr-x"
    echo "  │└┬┘└┬┘└┬┘"
    echo "  │ │  │  └── others: r-x (citire + executare)"
    echo "  │ │  └───── group:  r-x (citire + executare)"
    echo "  │ └──────── owner:  rwx (toate permisiunile)"
    echo "  └────────── fișier regular"
    echo ""
    echo "  → Oricine poate rula scriptul, dar doar owner-ul îl poate modifica"
    
    run_demo "ls -l private/secrets.txt" ""
    echo ""
    echo "  -rw-------"
    echo "  │└┬┘└┬┘└┬┘"
    echo "  │ │  │  └── others: --- (nimic)"
    echo "  │ │  └───── group:  --- (nimic)"
    echo "  │ └──────── owner:  rw- (citire + scriere)"
    echo "  └────────── fișier regular"
    echo ""
    echo "  → Doar owner-ul poate vedea/modifica. Foarte privat!"
    
    print_subheader "2.3 Vizualizare cu stat"
    
    run_demo "stat scripts/backup.sh" "Informații detaliate inclusiv permisiuni octale"
    
    print_tip "stat arată permisiunile și în format octal (Access: 0755)"
    
    pause_interactive
}

#
# SECȚIUNEA 3: CHMOD OCTAL
#

section_3_chmod_octal() {
    print_header "📚 SECȚIUNEA 3: chmod - Mod Octal"
    
    cd "$DEMO_DIR"
    
    print_concept "chmod NNN - setează permisiunile folosind numere octale"
    
    print_subheader "3.1 Calculul octal"
    
    cat << 'CALC'
╔═══════════════════════════════════════════════════════════════════════════════╗
║                      CALCULUL PERMISIUNILOR OCTALE                            ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║   Fiecare permisiune are o valoare:                                           ║
║                                                                               ║
║       r (read)    = 4                                                         ║
║       w (write)   = 2                                                         ║
║       x (execute) = 1                                                         ║
║       - (nimic)   = 0                                                         ║
║                                                                               ║
║   Adunăm valorile pentru fiecare categorie:                                   ║
║                                                                               ║
║       rwx = 4+2+1 = 7                                                         ║
║       rw- = 4+2+0 = 6                                                         ║
║       r-x = 4+0+1 = 5                                                         ║
║       r-- = 4+0+0 = 4                                                         ║
║       --- = 0+0+0 = 0                                                         ║
║                                                                               ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║   EXEMPLE:                                                                    ║
║                                                                               ║
║   755 = rwxr-xr-x  (owner: tot, grup: citire+exec, others: citire+exec)       ║
║   644 = rw-r--r--  (owner: citire+scriere, restul: doar citire)               ║
║   600 = rw-------  (doar owner poate citi/scrie)                              ║
║   700 = rwx------  (doar owner, toate permisiunile)                           ║
║   750 = rwxr-x---  (owner: tot, grup: citire+exec, others: nimic)             ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
CALC
    
    print_subheader "3.2 Demonstrație practică"
    
    # Creează fișier de test
    touch "$DEMO_DIR/test_perm.txt"
    echo "Test content" > "$DEMO_DIR/test_perm.txt"
    
    echo -e "\n${WHITE}Fișier inițial:${NC}"
    run_demo "ls -l test_perm.txt" ""
    
    echo -e "\n${WHITE}chmod 644 (rw-r--r--):${NC}"
    run_demo "chmod 644 test_perm.txt && ls -l test_perm.txt" "Fișier normal, citibil de toți"
    
    echo -e "\n${WHITE}chmod 600 (rw-------):${NC}"
    run_demo "chmod 600 test_perm.txt && ls -l test_perm.txt" "Fișier privat"
    
    echo -e "\n${WHITE}chmod 755 (rwxr-xr-x):${NC}"
    run_demo "chmod 755 test_perm.txt && ls -l test_perm.txt" "Executabil de toți"
    
    # Tabel de referință
    print_subheader "3.3 Tabel de referință"
    
    cat << 'TABLE'
╔════════╦════════════╦════════════════════════════════════════════════════════╗
║ Octal  ║ Simbolic   ║ Utilizare tipică                                       ║
╠════════╬════════════╬════════════════════════════════════════════════════════╣
║  755   ║ rwxr-xr-x  ║ Directoare, scripturi executabile                      ║
║  644   ║ rw-r--r--  ║ Fișiere text, documente                                ║
║  600   ║ rw-------  ║ Fișiere private, chei SSH                              ║
║  700   ║ rwx------  ║ Directoare private                                     ║
║  750   ║ rwxr-x---  ║ Directoare partajate cu grupul                         ║
║  640   ║ rw-r-----  ║ Fișiere partajate cu grupul                            ║
║  444   ║ r--r--r--  ║ Fișiere read-only pentru toți                          ║
║  400   ║ r--------  ║ Fișiere foarte sensibile (chei private)                ║
╠════════╬════════════╬════════════════════════════════════════════════════════╣
║  777   ║ rwxrwxrwx  ║ ⚠️ NICIODATĂ! Vulnerabilitate de securitate!           ║
║  666   ║ rw-rw-rw-  ║ ⚠️ Foarte rar justificat!                              ║
╚════════╩════════════╩════════════════════════════════════════════════════════╝
TABLE
    
    print_danger "chmod 777 nu este o soluție! Întotdeauna găsește permisiunile MINIME necesare."
    
    pause_interactive
}

#
# SECȚIUNEA 4: CHMOD SIMBOLIC
#

section_4_chmod_symbolic() {
    print_header "📚 SECȚIUNEA 4: chmod - Mod Simbolic"
    
    cd "$DEMO_DIR"
    
    print_concept "chmod [who][op][perm] - modificare relativă a permisiunilor"
    
    print_subheader "4.1 Sintaxa simbolică"
    
    cat << 'SYNTAX'
╔═══════════════════════════════════════════════════════════════════════════════╗
║                          SINTAXA CHMOD SIMBOLIC                               ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║   chmod [WHO][OPERATOR][PERMISSION] file                                      ║
║                                                                               ║
║   WHO:                                                                        ║
║     u = user (owner)                                                          ║
║     g = group                                                                 ║
║     o = others                                                                ║
║     a = all (u+g+o)                                                           ║
║                                                                               ║
║   OPERATOR:                                                                   ║
║     + = adaugă permisiunea                                                    ║
║     - = elimină permisiunea                                                   ║
║     = = setează exact (elimină restul)                                        ║
║                                                                               ║
║   PERMISSION:                                                                 ║
║     r = read                                                                  ║
║     w = write                                                                 ║
║     x = execute                                                               ║
║     X = execute doar dacă e director sau deja executabil                      ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
SYNTAX
    
    print_subheader "4.2 Demonstrație"
    
    # Reset fișierul
    chmod 644 "$DEMO_DIR/test_perm.txt"
    
    echo -e "\n${WHITE}Fișier inițial (644):${NC}"
    run_demo "ls -l test_perm.txt" ""
    
    echo -e "\n${WHITE}u+x (adaugă execute pentru owner):${NC}"
    run_demo "chmod u+x test_perm.txt && ls -l test_perm.txt" ""
    
    echo -e "\n${WHITE}g+w (adaugă write pentru grup):${NC}"
    run_demo "chmod g+w test_perm.txt && ls -l test_perm.txt" ""
    
    echo -e "\n${WHITE}o-r (elimină read pentru others):${NC}"
    run_demo "chmod o-r test_perm.txt && ls -l test_perm.txt" ""
    
    echo -e "\n${WHITE}a=r (setează doar read pentru toți):${NC}"
    run_demo "chmod a=r test_perm.txt && ls -l test_perm.txt" ""
    
    echo -e "\n${WHITE}u=rwx,g=rx,o= (setare completă):${NC}"
    run_demo "chmod u=rwx,g=rx,o= test_perm.txt && ls -l test_perm.txt" ""
    
    # chmod recursiv
    print_subheader "4.3 chmod recursiv și X special"
    
    echo ""
    echo "  ${WHITE}Problema cu chmod recursiv:${NC}"
    echo ""
    echo "  chmod -R 755 director/"
    echo "  → Setează și FIȘIERELE ca executabile (nu e ce vrei!)"
    echo ""
    echo "  ${WHITE}Soluția: X (execute doar pentru directoare)${NC}"
    echo ""
    echo "  chmod -R u=rwX,g=rX,o=rX director/"
    echo "  → X = execute doar dacă e director sau deja executabil"
    
    mkdir -p "$DEMO_DIR/recursive_test"/{subdir1,subdir2}
    touch "$DEMO_DIR/recursive_test/file1.txt"
    touch "$DEMO_DIR/recursive_test/subdir1/file2.txt"
    
    run_demo "find recursive_test -exec ls -ld {} \\;" "Înainte"
    
    run_demo "chmod -R u=rwX,g=rX,o=rX recursive_test" ""
    
    run_demo "find recursive_test -exec ls -ld {} \\;" "După: directoare au x, fișierele nu"
    
    print_tip "Folosește X pentru recursivitate sigură!"
    
    pause_interactive
}

#
# SECȚIUNEA 5: UMASK
#

section_5_umask() {
    print_header "📚 SECȚIUNEA 5: umask - Permisiuni Default"
    
    cd "$DEMO_DIR"
    
    print_concept "umask ELIMINĂ permisiuni din default, NU le setează!"
    
    print_warning "Cea mai comună confuzie: umask NU setează permisiuni, le ELIMINĂ!"
    
    print_subheader "5.1 Cum funcționează umask"
    
    cat << 'UMASK'
╔═══════════════════════════════════════════════════════════════════════════════╗
║                           CUM FUNCȚIONEAZĂ UMASK                              ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║   Permisiuni DEFAULT:                                                         ║
║     Fișiere:   666 (rw-rw-rw-)  - fără execute implicit                       ║
║     Directoare: 777 (rwxrwxrwx) - cu execute (acces)                          ║
║                                                                               ║
║   umask ELIMINĂ biți din default:                                             ║
║                                                                               ║
║     Permisiuni finale = Default - umask                                       ║
║                                                                               ║
║   EXEMPLU cu umask 022:                                                       ║
║     Fișier:  666 - 022 = 644 (rw-r--r--)                                      ║
║     Director: 777 - 022 = 755 (rwxr-xr-x)                                     ║
║                                                                               ║
║   EXEMPLU cu umask 077:                                                       ║
║     Fișier:  666 - 077 = 600 (rw-------)                                      ║
║     Director: 777 - 077 = 700 (rwx------)                                     ║
║                                                                               ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║   umask 022  → Elimină w pentru grup și others (standard)                     ║
║   umask 077  → Elimină toate pentru grup și others (privat)                   ║
║   umask 002  → Elimină w doar pentru others (colaborare grup)                 ║
║   umask 000  → Nu elimină nimic (nesigur!)                                    ║
╚═══════════════════════════════════════════════════════════════════════════════╝
UMASK
    
    print_subheader "5.2 Demonstrație"
    
    echo -e "\n${WHITE}umask curent:${NC}"
    run_demo "umask" ""
    
    # Salvează umask original
    original_umask=$(umask)
    
    echo -e "\n${WHITE}Cu umask 022 (standard):${NC}"
    umask 022
    run_demo "touch umask_test_022.txt && ls -l umask_test_022.txt" "644 (666-022)"
    run_demo "mkdir umask_dir_022 && ls -ld umask_dir_022" "755 (777-022)"
    
    echo -e "\n${WHITE}Cu umask 077 (privat):${NC}"
    umask 077
    run_demo "touch umask_test_077.txt && ls -l umask_test_077.txt" "600 (666-077)"
    run_demo "mkdir umask_dir_077 && ls -ld umask_dir_077" "700 (777-077)"
    
    echo -e "\n${WHITE}Cu umask 002 (grup colaborativ):${NC}"
    umask 002
    run_demo "touch umask_test_002.txt && ls -l umask_test_002.txt" "664 (666-002)"
    run_demo "mkdir umask_dir_002 && ls -ld umask_dir_002" "775 (777-002)"
    
    # Restaurează
    umask $original_umask
    
    print_subheader "5.3 umask în practică"
    
    echo ""
    echo "  ${WHITE}Unde se setează umask:${NC}"
    echo ""
    echo "  ~/.bashrc      - pentru sesiuni interactive"
    echo "  ~/.profile     - pentru sesiuni login"
    echo "  /etc/profile   - pentru toți utilizatorii"
    echo ""
    echo "  ${WHITE}Verificare:${NC}"
    echo "  umask          - afișează valoarea curentă"
    echo "  umask -S       - afișează în format simbolic"
    
    run_demo "umask -S" "Format simbolic"
    
    print_tip "umask 077 pentru date sensibile, umask 022 pentru uz general"
    
    pause_interactive
}

#
# SECȚIUNEA 6: PERMISIUNI SPECIALE
#

section_6_special() {
    print_header "📚 SECȚIUNEA 6: Permisiuni Speciale"
    
    cd "$DEMO_DIR"
    
    print_concept "SUID, SGID, Sticky Bit - permisiuni avansate pentru cazuri speciale"
    
    print_subheader "6.1 SUID (Set User ID) - 4xxx"
    
    cat << 'SUID'
╔═══════════════════════════════════════════════════════════════════════════════╗
║                          SUID - SET USER ID                                   ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║   Când e setat pe un EXECUTABIL:                                              ║
║   → Programul rulează cu permisiunile OWNER-ului, nu ale celui care îl rulează║
║                                                                               ║
║   Exemplu clasic: /usr/bin/passwd                                             ║
║   -rwsr-xr-x 1 root root ... /usr/bin/passwd                                  ║
║      ^                                                                        ║
║      └── 's' în loc de 'x' = SUID activ                                       ║
║                                                                               ║
║   Utilizatorul normal poate rula passwd, dar programul rulează ca ROOT        ║
║   pentru a putea modifica /etc/shadow                                         ║
║                                                                               ║
║   ⚠️ SUID pe scripturi bash NU funcționează! (măsură de securitate)           ║
║   ⚠️ SUID e un risc de securitate - folosește cu extremă precauție!           ║
║                                                                               ║
║   Setare: chmod 4755 file  sau  chmod u+s file                                ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
SUID
    
    echo -e "\n${WHITE}Exemple din sistem:${NC}"
    run_demo "ls -l /usr/bin/passwd 2>/dev/null || ls -l /bin/passwd 2>/dev/null" "SUID pe passwd"
    
    print_subheader "6.2 SGID (Set Group ID) - 2xxx"
    
    cat << 'SGID'
╔═══════════════════════════════════════════════════════════════════════════════╗
║                          SGID - SET GROUP ID                                  ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║   Pe EXECUTABIL: rulează cu permisiunile grupului                             ║
║                                                                               ║
║   Pe DIRECTOR (mai util!):                                                    ║
║   → Fișierele noi create înăuntru MOȘTENESC grupul directorului               ║
║   → Perfect pentru directoare partajate!                                      ║
║                                                                               ║
║   Vizualizare: 's' în poziția group execute                                   ║
║   drwxrwsr-x  2 user team ... shared/                                         ║
║         ^                                                                     ║
║         └── SGID activ                                                        ║
║                                                                               ║
║   Setare: chmod 2775 dir  sau  chmod g+s dir                                  ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
SGID
    
    echo -e "\n${WHITE}Demonstrație SGID pe director:${NC}"
    
    mkdir -p "$DEMO_DIR/sgid_demo"
    chmod 2775 "$DEMO_DIR/sgid_demo"
    
    run_demo "ls -ld sgid_demo" "Observă 's' în poziția group execute"
    
    print_subheader "6.3 Sticky Bit - 1xxx"
    
    cat << 'STICKY'
╔═══════════════════════════════════════════════════════════════════════════════╗
║                          STICKY BIT                                           ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║   Pe DIRECTOR:                                                                ║
║   → Doar OWNER-ul unui fișier poate să-l șteargă/redenumească                 ║
║   → Chiar dacă directorul e writable de toți!                                 ║
║                                                                               ║
║   Exemplu clasic: /tmp                                                        ║
║   drwxrwxrwt  15 root root ... /tmp                                           ║
║            ^                                                                  ║
║            └── 't' = Sticky bit activ                                         ║
║                                                                               ║
║   Fără sticky: oricine poate șterge orice fișier din /tmp                     ║
║   Cu sticky: poți șterge doar fișierele TALE                                  ║
║                                                                               ║
║   Setare: chmod 1777 dir  sau  chmod +t dir                                   ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
STICKY
    
    run_demo "ls -ld /tmp" "Observă 't' la final"
    
    print_subheader "6.4 Tabel rezumat"
    
    cat << 'SPECIAL'
╔════════════════╦═══════╦══════════════════════════════════════════════════════╗
║ Permisiune     ║ Octal ║ Efect                                                ║
╠════════════════╬═══════╬══════════════════════════════════════════════════════╣
║ SUID           ║ 4xxx  ║ Executabil rulează ca owner                          ║
║ SGID pe fișier ║ 2xxx  ║ Executabil rulează ca grup                           ║
║ SGID pe dir    ║ 2xxx  ║ Fișiere noi moștenesc grupul directorului            ║
║ Sticky         ║ 1xxx  ║ Doar owner poate șterge fișierele din director       ║
╠════════════════╬═══════╬══════════════════════════════════════════════════════╣
║ SUID + SGID    ║ 6xxx  ║ Ambele (rar)                                         ║
║ SUID + Sticky  ║ 5xxx  ║ Ambele (rar)                                         ║
║ SGID + Sticky  ║ 3xxx  ║ Ambele (folder partajat protejat)                    ║
║ Toate          ║ 7xxx  ║ Toate trei (foarte rar)                              ║
╚════════════════╩═══════╩══════════════════════════════════════════════════════╝
SPECIAL
    
    print_warning "SUID/SGID pe executabile sunt potențiale vulnerabilități! Auditează-le regulat."
    
    pause_interactive
}

#
# SECȚIUNEA 7: CHOWN ȘI CHGRP
#

section_7_ownership() {
    print_header "📚 SECȚIUNEA 7: chown și chgrp"
    
    cd "$DEMO_DIR"
    
    print_concept "Schimbarea proprietarului și grupului fișierelor"
    
    print_subheader "7.1 Sintaxa chown"
    
    cat << 'CHOWN'
╔═══════════════════════════════════════════════════════════════════════════════╗
║                              SINTAXA CHOWN                                    ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║   chown USER file              # Schimbă doar owner                           ║
║   chown USER:GROUP file        # Schimbă owner și grup                        ║
║   chown :GROUP file            # Schimbă doar grupul                          ║
║   chown USER: file             # Schimbă owner, grup devine grupul primar     ║
║                                                                               ║
║   Opțiuni:                                                                    ║
║     -R        Recursiv                                                        ║
║     -v        Verbose                                                         ║
║     --from=   Schimbă doar dacă owner/grup curent match-uiește                ║
║                                                                               ║
║   ⚠️ De obicei necesită sudo (doar root poate schimba owner-ul)               ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
CHOWN
    
    echo ""
    echo "  ${WHITE}Exemple (necesită sudo):${NC}"
    echo ""
    print_command "sudo chown john file.txt"
    echo "  → Owner devine john"
    echo ""
    print_command "sudo chown john:developers file.txt"
    echo "  → Owner devine john, grupul devine developers"
    echo ""
    print_command "sudo chown -R www-data:www-data /var/www"
    echo "  → Schimbă recursiv pentru web server"
    
    print_subheader "7.2 chgrp - Schimbare grup"
    
    echo ""
    echo "  ${WHITE}Sintaxa:${NC}"
    echo ""
    print_command "chgrp GROUP file"
    echo ""
    echo "  ${WHITE}Observație:${NC} Poți schimba grupul la un grup din care faci parte,"
    echo "  fără sudo (dacă ești owner-ul fișierului)."
    
    run_demo "groups" "Grupurile tale"
    
    print_tip "Folosește chown user:group pentru a seta ambele într-o singură comandă"
    
    pause_interactive
}

#
# SECȚIUNEA 8: BEST PRACTICES ȘI AUDIT
#

section_8_security() {
    print_header "📚 SECȚIUNEA 8: Best Practices și Audit Securitate"
    
    cd "$DEMO_DIR"
    
    print_concept "Securitatea prin permisiuni corecte"
    
    print_subheader "8.1 Principii de bază"
    
    cat << 'PRINCIPLES'
╔═══════════════════════════════════════════════════════════════════════════════╗
║                    PRINCIPII DE SECURITATE PERMISIUNI                         ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║   1. LEAST PRIVILEGE                                                          ║
║      Acordă permisiunile MINIME necesare pentru funcționare.                  ║
║      Mai bine să adaugi permisiuni decât să le elimini după incident.         ║
║                                                                               ║
║   2. NU chmod 777!                                                            ║
║      Dacă ai nevoie de 777, reconsideră arhitectura.                          ║
║      Întreabă-te: "Cine exact are nevoie de acces?"                           ║
║                                                                               ║
║   3. GRUPURI PENTRU COLABORARE                                                ║
║      Folosește grupuri pentru acces partajat, nu world-writable.              ║
║      Creează grupuri specifice pentru proiecte.                               ║
║                                                                               ║
║   4. AUDIT REGULAT                                                            ║
║      Verifică periodic fișierele SUID/SGID și world-writable.                 ║
║      Logează modificările de permisiuni în producție.                         ║
║                                                                               ║
║   5. SEPARARE RESPONSABILITĂȚI                                                ║
║      Date și configurații: 600 sau 640                                        ║
║      Scripturi: 750 sau 755 (dar nu write pentru group/others)                ║
║      Directoare shared: 2775 (SGID)                                           ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
PRINCIPLES
    
    print_subheader "8.2 Audit: Găsește probleme de securitate"
    
    echo -e "\n${WHITE}Găsește fișiere world-writable:${NC}"
    run_demo "find . -type f -perm -o=w -ls 2>/dev/null" "Toată lumea poate scrie!"
    
    echo -e "\n${WHITE}Găsește directoare world-writable (fără sticky):${NC}"
    run_demo "find . -type d -perm -o=w ! -perm -1000 -ls 2>/dev/null" "Risc: oricine poate șterge orice"
    
    echo -e "\n${WHITE}Găsește fișiere SUID:${NC}"
    run_demo "find /usr/bin -type f -perm -4000 -ls 2>/dev/null | head -5" "Rulează ca owner"
    
    echo -e "\n${WHITE}Găsește fișiere SGID:${NC}"
    run_demo "find /usr/bin -type f -perm -2000 -ls 2>/dev/null | head -5" "Rulează ca grup"
    
    print_subheader "8.3 Exercițiu: Corectează fix_me/"
    
    echo -e "\n${WHITE}Permisiuni problematice în fix_me/:${NC}"
    run_demo "ls -la fix_me/" ""
    
    echo ""
    echo "  ${WHITE}Probleme identificate:${NC}"
    echo "  • config.cfg: 777 - mult prea permisiv pentru config!"
    echo "  • backup.sql: 666 - date sensibile world-writable!"
    echo "  • run.sh: 644 - script neexecutabil!"
    echo ""
    echo "  ${WHITE}Soluții:${NC}"
    
    print_command "chmod 640 fix_me/config.cfg   # Doar owner și grup"
    print_command "chmod 600 fix_me/backup.sql   # Doar owner"
    print_command "chmod 750 fix_me/run.sh       # Executabil pentru owner și grup"
    
    # Corectează efectiv
    chmod 640 "$DEMO_DIR/fix_me/config.cfg"
    chmod 600 "$DEMO_DIR/fix_me/backup.sql"
    chmod 750 "$DEMO_DIR/fix_me/run.sh"
    
    echo -e "\n${WHITE}După corecție:${NC}"
    run_demo "ls -la fix_me/" ""
    
    print_tip "Creează un script de audit și rulează-l periodic în producție!"
    
    pause_interactive
}

#
# TOOL: CALCULATOR PERMISIUNI
#

tool_calculator() {
    print_header "🧮 Calculator Permisiuni"
    
    echo ""
    echo "  ${WHITE}Introdu permisiuni octale sau simbolice pentru conversie${NC}"
    echo "  Exemple: 755, rw-r--r--, u=rwx,g=rx,o=rx"
    echo "  Tastează 'q' pentru a ieși"
    echo ""
    
    while true; do
        echo -n -e "${CYAN}Permisiuni> ${NC}"
        read -r input
        
        [[ "$input" == "q" || "$input" == "quit" ]] && break
        [[ -z "$input" ]] && continue
        
        # Verifică dacă e octal (3-4 cifre)
        if [[ "$input" =~ ^[0-7]{3,4}$ ]]; then
            # Octal la simbolic
            local octal="$input"
            [[ ${#octal} -eq 3 ]] && octal="0$octal"
            
            local special="${octal:0:1}"
            local owner="${octal:1:1}"
            local group="${octal:2:1}"
            local others="${octal:3:1}"
            
            octal_to_symbolic() {
                local n=$1
                local r='-' w='-' x='-'
                (( n & 4 )) && r='r'
                (( n & 2 )) && w='w'
                (( n & 1 )) && x='x'
                echo "$r$w$x"
            }
            
            local owner_sym=$(octal_to_symbolic $owner)
            local group_sym=$(octal_to_symbolic $group)
            local others_sym=$(octal_to_symbolic $others)
            
            # Handle special bits
            if (( special & 4 )); then
                [[ "${owner_sym:2:1}" == "x" ]] && owner_sym="${owner_sym:0:2}s" || owner_sym="${owner_sym:0:2}S"
            fi
            if (( special & 2 )); then
                [[ "${group_sym:2:1}" == "x" ]] && group_sym="${group_sym:0:2}s" || group_sym="${group_sym:0:2}S"
            fi
            if (( special & 1 )); then
                [[ "${others_sym:2:1}" == "x" ]] && others_sym="${others_sym:0:2}t" || others_sym="${others_sym:0:2}T"
            fi
            
            echo ""
            echo "  Octal:    $input"
            echo "  Simbolic: ${owner_sym}${group_sym}${others_sym}"
            echo ""
            echo "  Owner:  ${owner_sym} ($(octal_to_symbolic $owner))"
            echo "  Group:  ${group_sym} ($(octal_to_symbolic $group))"
            echo "  Others: ${others_sym} ($(octal_to_symbolic $others))"
            
            [[ "$special" != "0" ]] && echo "  Special bits: $special"
            
        elif [[ "$input" =~ ^[rwx-]{9}$ ]]; then
            # Simbolic simplu la octal
            symbolic_to_octal() {
                local sym="$1"
                local n=0
                [[ "${sym:0:1}" == "r" ]] && (( n += 4 ))
                [[ "${sym:1:1}" == "w" ]] && (( n += 2 ))
                [[ "${sym:2:1}" == "x" || "${sym:2:1}" == "s" || "${sym:2:1}" == "t" ]] && (( n += 1 ))
                echo $n
            }
            
            local o=$(symbolic_to_octal "${input:0:3}")
            local g=$(symbolic_to_octal "${input:3:3}")
            local t=$(symbolic_to_octal "${input:6:3}")
            
            local special=0
            [[ "${input:2:1}" =~ [sS] ]] && (( special += 4 ))
            [[ "${input:5:1}" =~ [sS] ]] && (( special += 2 ))
            [[ "${input:8:1}" =~ [tT] ]] && (( special += 1 ))
            
            echo ""
            echo "  Simbolic: $input"
            if [[ $special -eq 0 ]]; then
                echo "  Octal:    ${o}${g}${t}"
            else
                echo "  Octal:    ${special}${o}${g}${t}"
            fi
            
        else
            echo -e "  ${RED}Format nerecunoscut. Folosește: 755 sau rwxr-xr-x${NC}"
        fi
        
        echo ""
    done
}

#
# TOOL: VISUALIZER
#

tool_visualizer() {
    print_header "👁️ Vizualizator Permisiuni"
    
    echo ""
    echo "  ${WHITE}Introdu calea către un fișier sau director${NC}"
    echo "  Tastează 'q' pentru a ieși"
    echo ""
    
    while true; do
        echo -n -e "${CYAN}Cale> ${NC}"
        read -r path
        
        [[ "$path" == "q" || "$path" == "quit" ]] && break
        [[ -z "$path" ]] && continue
        
        if [[ ! -e "$path" ]]; then
            echo -e "  ${RED}Calea nu există: $path${NC}"
            continue
        fi
        
        local perms=$(stat -c '%a' "$path")
        local perms_symbolic=$(stat -c '%A' "$path")
        local owner=$(stat -c '%U' "$path")
        local group=$(stat -c '%G' "$path")
        local type=$(stat -c '%F' "$path")
        
        echo ""
        echo "╔════════════════════════════════════════════════════════════════════╗"
        printf "║ Cale: %-58s ║\n" "$path"
        echo "╠════════════════════════════════════════════════════════════════════╣"
        printf "║ Tip:        %-52s ║\n" "$type"
        printf "║ Owner:      %-52s ║\n" "$owner"
        printf "║ Group:      %-52s ║\n" "$group"
        printf "║ Permisiuni: %-4s (%s)                                       ║\n" "$perms" "$perms_symbolic"
        echo "╠════════════════════════════════════════════════════════════════════╣"
        
        # Vizualizare grafică
        echo "║                                                                    ║"
        echo "║  Owner     Group     Others                                        ║"
        echo "║  ┌───┐     ┌───┐     ┌───┐                                         ║"
        
        for i in 0 1 2; do
            case $i in
                0) perm="r"; pos=0 ;;
                1) perm="w"; pos=1 ;;
                2) perm="x"; pos=2 ;;
            esac
            
            o_perm="${perms_symbolic:$((pos+1)):1}"
            g_perm="${perms_symbolic:$((pos+4)):1}"
            t_perm="${perms_symbolic:$((pos+7)):1}"
            
            [[ "$o_perm" != "-" ]] && o_color="${GREEN}$o_perm${NC}" || o_color="${RED}-${NC}"
            [[ "$g_perm" != "-" ]] && g_color="${GREEN}$g_perm${NC}" || g_color="${RED}-${NC}"
            [[ "$t_perm" != "-" ]] && t_color="${GREEN}$t_perm${NC}" || t_color="${RED}-${NC}"
            
            echo -e "║  │ $o_color │     │ $g_color │     │ $t_color │                                         ║"
        done
        
        echo "║  └───┘     └───┘     └───┘                                         ║"
        echo "║                                                                    ║"
        echo "╚════════════════════════════════════════════════════════════════════╝"
        echo ""
    done
}

#
# TOOL: AUDIT
#

tool_audit() {
    local target="${1:-.}"
    
    print_header "🔍 Audit Securitate: $target"
    
    echo ""
    echo -e "${WHITE}Scanez pentru probleme de securitate...${NC}"
    echo ""
    
    local issues=0
    
    # World-writable files
    echo -e "${YELLOW}► Fișiere world-writable:${NC}"
    local ww_files=$(find "$target" -type f -perm -o=w 2>/dev/null)
    if [[ -n "$ww_files" ]]; then
        echo "$ww_files" | while read f; do
            echo -e "  ${RED}⚠${NC} $f"
            ((issues++))
        done
    else
        echo -e "  ${GREEN}✓ Niciuna găsită${NC}"
    fi
    
    echo ""
    
    # World-writable directories without sticky
    echo -e "${YELLOW}► Directoare world-writable fără sticky bit:${NC}"
    local ww_dirs=$(find "$target" -type d -perm -o=w ! -perm -1000 2>/dev/null)
    if [[ -n "$ww_dirs" ]]; then
        echo "$ww_dirs" | while read d; do
            echo -e "  ${RED}⚠${NC} $d"
            ((issues++))
        done
    else
        echo -e "  ${GREEN}✓ Niciuna găsită${NC}"
    fi
    
    echo ""
    
    # SUID files (outside standard locations)
    echo -e "${YELLOW}► Fișiere SUID:${NC}"
    local suid_files=$(find "$target" -type f -perm -4000 2>/dev/null | grep -v "^/usr\|^/bin\|^/sbin")
    if [[ -n "$suid_files" ]]; then
        echo "$suid_files" | while read f; do
            echo -e "  ${YELLOW}!${NC} $f (verifică dacă e necesar)"
            ((issues++))
        done
    else
        echo -e "  ${GREEN}✓ Niciuna în locații nestandard${NC}"
    fi
    
    echo ""
    
    # Files with 777
    echo -e "${YELLOW}► Fișiere cu permisiuni 777:${NC}"
    local full_perm=$(find "$target" -type f -perm 777 2>/dev/null)
    if [[ -n "$full_perm" ]]; then
        echo "$full_perm" | while read f; do
            echo -e "  ${RED}☠${NC} $f - CRITIC!"
            ((issues++))
        done
    else
        echo -e "  ${GREEN}✓ Niciuna găsită${NC}"
    fi
    
    echo ""
    echo "════════════════════════════════════════════════════════════════════════"
    
    if [[ $issues -eq 0 ]]; then
        echo -e "${GREEN}✓ Audit complet. Nicio problemă identificată.${NC}"
    else
        echo -e "${YELLOW}⚠ Audit complet. Probleme potențiale găsite.${NC}"
    fi
    
    echo ""
}

#
# REZUMAT
#

show_summary() {
    print_header "📋 REZUMAT: Permisiuni Unix"
    
    cat << 'SUMMARY'
╔═══════════════════════════════════════════════════════════════════════════════╗
║                          CHEAT SHEET RAPID                                    ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║ PERMISIUNI OCTALE:                                                            ║
║   r=4, w=2, x=1    755=rwxr-xr-x   644=rw-r--r--   600=rw-------              ║
║                                                                               ║
║ CHMOD:                                                                        ║
║   chmod 755 file         # Octal                                              ║
║   chmod u+x file         # Adaugă execute pentru owner                        ║
║   chmod g-w file         # Elimină write pentru grup                          ║
║   chmod a=r file         # Setează doar read pentru toți                      ║
║   chmod -R u=rwX dir/    # Recursiv, X=exec doar pentru dir                   ║
║                                                                               ║
║ UMASK:                                                                        ║
║   umask 022              # Standard: fișiere 644, dir 755                     ║
║   umask 077              # Privat: fișiere 600, dir 700                       ║
║                                                                               ║
║ OWNERSHIP:                                                                    ║
║   chown user file        # Schimbă owner                                      ║
║   chown user:group file  # Schimbă owner și grup                              ║
║   chgrp group file       # Schimbă doar grupul                                ║
║                                                                               ║
║ PERMISIUNI SPECIALE:                                                          ║
║   chmod 4755 file        # SUID (rulează ca owner)                            ║
║   chmod 2775 dir         # SGID (moștenire grup)                              ║
║   chmod 1777 dir         # Sticky (doar owner șterge)                         ║
║                                                                               ║
║ AUDIT:                                                                        ║
║   find . -perm -o=w      # World-writable                                     ║
║   find . -perm -4000     # SUID                                               ║
║   find . -perm 777       # Prea permisiv!                                     ║
║                                                                               ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║ ⚠️  NICIODATĂ chmod 777!  Găsește permisiunile MINIME necesare.               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
SUMMARY
    
    echo ""
    echo -e "${GREEN}✓ Demo complet!${NC}"
    echo ""
    echo -e "Tool-uri disponibile:"
    echo -e "  ${CYAN}./S03_04_demo_permissions.sh -t calculator${NC}  - Calculator permisiuni"
    echo -e "  ${CYAN}./S03_04_demo_permissions.sh -t visualizer${NC}  - Vizualizator"
    echo -e "  ${CYAN}./S03_04_demo_permissions.sh -t audit${NC}       - Audit securitate"
    echo ""
}

#
# MAIN
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
            -c|--cleanup)
                cleanup_demo
                exit 0
                ;;
            -t|--tool)
                TOOL_NAME="$2"
                shift 2
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
    
    # Rulează tool specific
    if [[ -n "$TOOL_NAME" ]]; then
        case "$TOOL_NAME" in
            calculator|calc) tool_calculator ;;
            visualizer|viz) tool_visualizer ;;
            audit) tool_audit "${DEMO_DIR:-.}" ;;
            *)
                echo -e "${RED}Tool necunoscut: $TOOL_NAME${NC}"
                exit 1
                ;;
        esac
        exit 0
    fi
    
    # Rulează secțiune specifică
    if [[ -n "$RUN_SECTION" ]]; then
        case "$RUN_SECTION" in
            1) section_1_fundamentals ;;
            2) section_2_visualization ;;
            3) section_3_chmod_octal ;;
            4) section_4_chmod_symbolic ;;
            5) section_5_umask ;;
            6) section_6_special ;;
            7) section_7_ownership ;;
            8) section_8_security ;;
            *)
                echo -e "${RED}Secțiune invalidă: $RUN_SECTION${NC}"
                exit 1
                ;;
        esac
    else
        # Rulează tot
        section_1_fundamentals
        section_2_visualization
        section_3_chmod_octal
        section_4_chmod_symbolic
        section_5_umask
        section_6_special
        section_7_ownership
        section_8_security
    fi
    
    show_summary
}

main "$@"
