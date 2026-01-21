#!/bin/bash
#
#  HOOK DEMO: File System Explorer & Power of Find
#
# Sisteme de Operare | ASE București - CSIE
# Seminar 5-6: Demonstrație spectaculoasă pentru captarea atenției
#
# SCOP: Arată puterea comenzii find și utilităților Unix într-un mod vizual
#       și captivant pentru a "prinde" studenții de la început
#
# UTILIZARE:
#   ./S03_01_hook_demo.sh           # Demo complet
#   ./S03_01_hook_demo.sh -q        # Quick demo (30 secunde)
#   ./S03_01_hook_demo.sh -s        # Silent (fără pauze)
#   ./S03_01_hook_demo.sh -d DIR    # Analizează director specific
#
# CERINȚE: find, du, wc, bc, file (standard pe Ubuntu)
#

set -euo pipefail

#
# CONFIGURAȚIE ȘI CULORI
#

# Culori ANSI
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly BOLD='\033[1m'
readonly DIM='\033[2m'
readonly NC='\033[0m'

# Emoji pentru vizualizare
readonly EMOJI_FOLDER="📁"
readonly EMOJI_FILE="📄"
readonly EMOJI_CODE="💻"
readonly EMOJI_IMAGE="🖼️"
readonly EMOJI_MUSIC="🎵"
readonly EMOJI_VIDEO="🎬"
readonly EMOJI_ARCHIVE="📦"
readonly EMOJI_SEARCH="🔍"
readonly EMOJI_ROCKET="🚀"
readonly EMOJI_CHECK="✅"
readonly EMOJI_WARN="⚠️"
readonly EMOJI_LOCK="🔒"
readonly EMOJI_TIME="⏱️"
readonly EMOJI_STATS="📊"

# Configurație
DEMO_DIR="${1:-/usr}"
QUICK_MODE=false
SILENT_MODE=false
PAUSE_TIME=2

#
# FUNCȚII UTILITARE
#

print_banner() {
    clear
    echo -e "${CYAN}"
    cat << 'EOF'
    ╔═══════════════════════════════════════════════════════════════════════╗
    ║                                                                       ║
    ║   🔍 FILE SYSTEM EXPLORER - The Power of find                        ║
    ║                                                                       ║
    ║   Sisteme de Operare | ASE București - CSIE                          ║
    ║                                                                       ║
    ╚═══════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

print_section() {
    local title="$1"
    local emoji="${2:-📌}"
    
    echo ""
    echo -e "${YELLOW}╔══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║ ${emoji} ${BOLD}${title}${NC}${YELLOW}$(printf '%*s' $((58 - ${#title})) '')║${NC}"
    echo -e "${YELLOW}╚══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

pause_for_effect() {
    if [[ "$SILENT_MODE" == "false" ]]; then
        sleep "$PAUSE_TIME"
    fi
}

typing_effect() {
    local text="$1"
    local delay="${2:-0.03}"
    
    if [[ "$SILENT_MODE" == "true" ]]; then
        echo -e "$text"
        return
    fi
    
    for (( i=0; i<${#text}; i++ )); do
        echo -n "${text:$i:1}"
        sleep "$delay"
    done
    echo ""
}

show_command() {
    local cmd="$1"
    echo -e "${DIM}┌─────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${GREEN}│ \$ ${WHITE}${cmd}${NC}"
    echo -e "${DIM}└─────────────────────────────────────────────────────────────────┘${NC}"
    pause_for_effect
}

format_size() {
    local bytes=$1
    if (( bytes >= 1073741824 )); then
        echo "$(echo "scale=2; $bytes/1073741824" | bc) GB"
    elif (( bytes >= 1048576 )); then
        echo "$(echo "scale=2; $bytes/1048576" | bc) MB"
    elif (( bytes >= 1024 )); then
        echo "$(echo "scale=2; $bytes/1024" | bc) KB"
    else
        echo "$bytes B"
    fi
}

progress_bar() {
    local current=$1
    local total=$2
    local width=50
    local percent=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))
    
    printf "\r${CYAN}["
    printf "%${filled}s" '' | tr ' ' '█'
    printf "%${empty}s" '' | tr ' ' '░'
    printf "] ${percent}%%${NC}"
}

#
# DEMO 1: CĂUTARE SPECTACULOASĂ
#

demo_spectacular_search() {
    print_section "CĂUTARE SPECTACULOASĂ" "🔍"
    
    typing_effect "${WHITE}Imaginați-vă că trebuie să găsiți cele mai mari 10 fișiere din sistem...${NC}"
    echo ""
    typing_effect "${DIM}Cu ls? Imposibil. Cu GUI? Minute întregi de click-uri.${NC}"
    typing_effect "${BOLD}${GREEN}Cu find? O SINGURĂ comandă!${NC}"
    echo ""
    
    show_command "find /usr -type f -printf '%s %p\\n' 2>/dev/null | sort -rn | head -10"
    
    echo -e "${MAGENTA}${EMOJI_ROCKET} Executare...${NC}"
    echo ""
    
    # Execută și formatează frumos
    echo -e "${WHITE}┌────────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${WHITE}│  ${BOLD}RANK    DIMENSIUNE          FIȘIER${NC}                               ${WHITE}│${NC}"
    echo -e "${WHITE}├────────────────────────────────────────────────────────────────────┤${NC}"
    
    local rank=1
    while read -r size path; do
        local formatted_size=$(format_size "$size")
        printf "${WHITE}│  ${CYAN}#%-3d${NC}   ${YELLOW}%12s${NC}    ${GREEN}%-40s${NC} ${WHITE}│${NC}\n" \
            "$rank" "$formatted_size" "${path:0:40}"
        ((rank++))
    done < <(find /usr -type f -printf '%s %p\n' 2>/dev/null | sort -rn | head -10)
    
    echo -e "${WHITE}└────────────────────────────────────────────────────────────────────┘${NC}"
    echo ""
    
    typing_effect "${GREEN}${EMOJI_CHECK} Totul într-o singură comandă! Asta e puterea lui find!${NC}"
    pause_for_effect
}

#
# DEMO 2: STATISTICI SISTEM ÎN TIMP REAL
#

demo_system_stats() {
    print_section "STATISTICI SISTEM ÎN TIMP REAL" "📊"
    
    typing_effect "${WHITE}Câte fișiere sunt în ${DEMO_DIR}? Ce tipuri? Cât spațiu?${NC}"
    echo ""
    
    # Pregătire contoare
    local total_files=0
    local total_dirs=0
    local total_links=0
    local total_size=0
    
    # Numărare cu animație
    echo -e "${CYAN}${EMOJI_SEARCH} Scanare în progres...${NC}"
    echo ""
    
    # Numără fișiere
    show_command "find ${DEMO_DIR} -type f 2>/dev/null | wc -l"
    total_files=$(find "${DEMO_DIR}" -type f 2>/dev/null | wc -l)
    echo -e "${GREEN}   ${EMOJI_FILE} Fișiere: ${BOLD}${total_files}${NC}"
    
    # Numără directoare
    show_command "find ${DEMO_DIR} -type d 2>/dev/null | wc -l"
    total_dirs=$(find "${DEMO_DIR}" -type d 2>/dev/null | wc -l)
    echo -e "${BLUE}   ${EMOJI_FOLDER} Directoare: ${BOLD}${total_dirs}${NC}"
    
    # Numără symlink-uri
    show_command "find ${DEMO_DIR} -type l 2>/dev/null | wc -l"
    total_links=$(find "${DEMO_DIR}" -type l 2>/dev/null | wc -l)
    echo -e "${MAGENTA}   🔗 Link-uri simbolice: ${BOLD}${total_links}${NC}"
    
    # Dimensiune totală
    show_command "du -sb ${DEMO_DIR} 2>/dev/null"
    total_size=$(du -sb "${DEMO_DIR}" 2>/dev/null | cut -f1 || echo "0")
    echo -e "${YELLOW}   💾 Dimensiune totală: ${BOLD}$(format_size ${total_size})${NC}"
    
    echo ""
    
    # Grafic ASCII pentru distribuție
    echo -e "${WHITE}┌─────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${WHITE}│                    ${BOLD}DISTRIBUȚIE TIPURI${NC}                          ${WHITE}│${NC}"
    echo -e "${WHITE}├─────────────────────────────────────────────────────────────────┤${NC}"
    
    local total=$((total_files + total_dirs + total_links))
    if (( total > 0 )); then
        local file_pct=$((total_files * 50 / total))
        local dir_pct=$((total_dirs * 50 / total))
        local link_pct=$((total_links * 50 / total))
        
        printf "${WHITE}│ ${NC}${EMOJI_FILE} Fișiere  ${GREEN}"
        printf "%${file_pct}s" '' | tr ' ' '█'
        printf "${NC} %d%%\n" $((total_files * 100 / total))
        
        printf "${WHITE}│ ${NC}${EMOJI_FOLDER} Directoare ${BLUE}"
        printf "%${dir_pct}s" '' | tr ' ' '█'
        printf "${NC} %d%%\n" $((total_dirs * 100 / total))
        
        printf "${WHITE}│ ${NC}🔗 Link-uri   ${MAGENTA}"
        printf "%${link_pct}s" '' | tr ' ' '█'
        printf "${NC} %d%%\n" $((total_links * 100 / total))
    fi
    
    echo -e "${WHITE}└─────────────────────────────────────────────────────────────────┘${NC}"
    pause_for_effect
}

#
# DEMO 3: DETECTARE TIPURI DE FIȘIERE
#

demo_file_types() {
    print_section "DETECTARE AUTOMATĂ TIPURI FIȘIERE" "🎨"
    
    typing_effect "${WHITE}find poate găsi orice tip de fișier după extensie sau conținut!${NC}"
    echo ""
    
    # Creează director temporar pentru demo
    local demo_temp="/tmp/hook_demo_$$"
    mkdir -p "$demo_temp"
    
    # Simulează structură de proiect
    mkdir -p "$demo_temp"/{src,docs,images,data}
    touch "$demo_temp"/src/{main.c,utils.c,config.h,Makefile}
    touch "$demo_temp"/docs/{README.md,manual.txt,api.html}
    touch "$demo_temp"/images/{logo.png,banner.jpg,icon.svg}
    touch "$demo_temp"/data/{config.json,users.csv,log.xml}
    
    echo -e "${DIM}Am creat o structură de proiect demonstrativă...${NC}"
    echo ""
    
    # Demonstrează căutare per extensie
    declare -A file_types=(
        ["*.c"]="${EMOJI_CODE} Cod C"
        ["*.h"]="${EMOJI_CODE} Header C"
        ["*.md"]="${EMOJI_FILE} Markdown"
        ["*.html"]="🌐 HTML"
        ["*.png"]="${EMOJI_IMAGE} PNG"
        ["*.jpg"]="${EMOJI_IMAGE} JPEG"
        ["*.json"]="📋 JSON"
        ["*.csv"]="📊 CSV"
    )
    
    echo -e "${WHITE}┌────────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${WHITE}│  ${BOLD}TIP               GĂSITE    COMANDĂ FIND${NC}                         ${WHITE}│${NC}"
    echo -e "${WHITE}├────────────────────────────────────────────────────────────────────┤${NC}"
    
    for pattern in "${!file_types[@]}"; do
        local count=$(find "$demo_temp" -name "$pattern" 2>/dev/null | wc -l)
        local desc="${file_types[$pattern]}"
        printf "${WHITE}│  ${NC}%-17s ${CYAN}%3d${NC}       ${DIM}find . -name \"%-8s\"${NC}   ${WHITE}│${NC}\n" \
            "$desc" "$count" "$pattern"
    done
    
    echo -e "${WHITE}└────────────────────────────────────────────────────────────────────┘${NC}"
    
    # Cleanup
    rm -rf "$demo_temp"
    
    pause_for_effect
}

#
# DEMO 4: PUTEREA COMBINĂRII CU XARGS
#

demo_find_xargs_power() {
    print_section "find + xargs = SUPERPOWERS!" "⚡"
    
    typing_effect "${WHITE}find găsește, xargs procesează. Împreună sunt invincibili!${NC}"
    echo ""
    
    # Demo 1: Numără linii în toate fișierele C din /usr/include
    echo -e "${CYAN}${EMOJI_SEARCH} Câte linii de cod C sunt în /usr/include?${NC}"
    show_command "find /usr/include -name '*.h' -type f 2>/dev/null | head -100 | xargs wc -l | tail -1"
    
    local line_count=$(find /usr/include -name '*.h' -type f 2>/dev/null | head -100 | xargs wc -l 2>/dev/null | tail -1 | awk '{print $1}')
    echo -e "${GREEN}${EMOJI_CHECK} Total: ${BOLD}${line_count}${NC} ${GREEN}linii (în primele 100 header-uri)${NC}"
    echo ""
    
    # Demo 2: Găsește fișiere modificate recent
    echo -e "${CYAN}${EMOJI_TIME} Fișiere modificate în ultimele 24 de ore în /var/log:${NC}"
    show_command "find /var/log -type f -mtime -1 -name '*.log' 2>/dev/null | head -5"
    
    echo -e "${WHITE}Rezultate:${NC}"
    find /var/log -type f -mtime -1 -name '*.log' 2>/dev/null | head -5 | while read -r f; do
        echo -e "   ${GREEN}→${NC} $f"
    done
    echo ""
    
    # Demo 3: Showcase batch processing
    echo -e "${CYAN}⚡ Diferența între \\; și + în -exec:${NC}"
    echo ""
    echo -e "${DIM}Cu \\; (câte o execuție per fișier - LENT):${NC}"
    echo -e "${YELLOW}find . -name '*.txt' -exec echo {} \\;${NC}"
    echo -e "${DIM}    → echo file1.txt${NC}"
    echo -e "${DIM}    → echo file2.txt${NC}"
    echo -e "${DIM}    → echo file3.txt${NC}"
    echo ""
    echo -e "${DIM}Cu + (batch - RAPID):${NC}"
    echo -e "${GREEN}find . -name '*.txt' -exec echo {} +${NC}"
    echo -e "${DIM}    → echo file1.txt file2.txt file3.txt${NC}"
    echo ""
    
    typing_effect "${GREEN}${EMOJI_ROCKET} Batch processing poate fi de 10-100x mai rapid!${NC}"
    pause_for_effect
}

#
# DEMO 5: SECURITY SCAN RAPID
#

demo_security_scan() {
    print_section "MINI SECURITY AUDIT" "🛡️"
    
    typing_effect "${WHITE}find poate identifica probleme de securitate într-o clipă!${NC}"
    echo ""
    
    # Caută fișiere SUID
    echo -e "${CYAN}${EMOJI_LOCK} Fișiere SUID în sistem (rulează cu permisiuni root):${NC}"
    show_command "find /usr/bin -perm -4000 -type f 2>/dev/null | head -5"
    
    find /usr/bin -perm -4000 -type f 2>/dev/null | head -5 | while read -r f; do
        local perms=$(ls -l "$f" 2>/dev/null | awk '{print $1}')
        echo -e "   ${YELLOW}${EMOJI_WARN}${NC} $perms ${RED}$f${NC}"
    done
    echo ""
    
    # Caută fișiere world-writable
    echo -e "${CYAN}${EMOJI_WARN} Directoare world-writable (sticky bit):${NC}"
    show_command "find /tmp /var/tmp -type d -perm -1000 2>/dev/null | head -3"
    
    find /tmp /var/tmp -type d -perm -1000 2>/dev/null 2>/dev/null | head -3 | while read -r d; do
        local perms=$(ls -ld "$d" 2>/dev/null | awk '{print $1}')
        echo -e "   ${GREEN}${EMOJI_CHECK}${NC} $perms ${BLUE}$d${NC} (sticky bit protejează)"
    done
    echo ""
    
    typing_effect "${WHITE}Aceste comenzi find sunt esențiale pentru orice administrator de sistem!${NC}"
    pause_for_effect
}

#
# DEMO FINAL: TEASER PENTRU SEMINAR
#

demo_teaser() {
    print_section "CE VOM ÎNVĂȚA ASTĂZI" "🎯"
    
    echo -e "${WHITE}În acest seminar, veți stăpâni:${NC}"
    echo ""
    
    local topics=(
        "${EMOJI_SEARCH}|find|Căutări complexe cu multiple criterii"
        "⚡|xargs|Procesare batch eficientă"
        "${EMOJI_CODE}|Parametri|Scripturi profesionale cu argumente"
        "🔧|getopts|Parsare opțiuni ca un pro"
        "${EMOJI_LOCK}|Permisiuni|chmod, chown, umask - controlul total"
        "👥|SUID/SGID|Permisiuni speciale pentru acces avansat"
        "${EMOJI_TIME}|cron|Automatizare - sistemul lucrează pentru voi"
    )
    
    echo -e "${WHITE}┌────────────────────────────────────────────────────────────────────┐${NC}"
    
    for topic in "${topics[@]}"; do
        IFS='|' read -r emoji name desc <<< "$topic"
        printf "${WHITE}│  ${NC}%s  ${CYAN}%-12s${NC} ${DIM}%-45s${NC} ${WHITE}│${NC}\n" \
            "$emoji" "$name" "$desc"
        sleep 0.3
    done
    
    echo -e "${WHITE}└────────────────────────────────────────────────────────────────────┘${NC}"
    echo ""
    
    echo -e "${GREEN}${BOLD}"
    cat << 'EOF'
    ╔═══════════════════════════════════════════════════════════════════╗
    ║                                                                   ║
    ║   🚀 Pregătiți-vă să deveniți POWER USERS!                       ║
    ║                                                                   ║
    ║   După acest seminar, comenzile Unix vă vor asculta!             ║
    ║                                                                   ║
    ╚═══════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

#
# MAIN - PARSARE ARGUMENTE ȘI EXECUȚIE
#

usage() {
    cat << EOF
${BOLD}UTILIZARE:${NC}
    $(basename "$0") [OPȚIUNI] [DIRECTOR]

${BOLD}OPȚIUNI:${NC}
    -q, --quick     Demo rapid (sare peste pauze)
    -s, --silent    Mod silențios (fără animații)
    -d, --dir DIR   Analizează director specific (default: /usr)
    -h, --help      Afișează acest ajutor

${BOLD}EXEMPLE:${NC}
    $(basename "$0")              # Demo complet în /usr
    $(basename "$0") -q           # Demo rapid
    $(basename "$0") -d /home     # Analizează /home

${BOLD}DESCRIERE:${NC}
    Script demonstrativ pentru captarea atenției studenților.
    Arată puterea comenzii find și a utilităților Unix.
EOF
}

main() {
    # Parsare argumente
    while [[ $# -gt 0 ]]; do
        case $1 in
            -q|--quick)
                QUICK_MODE=true
                PAUSE_TIME=0.5
                shift
                ;;
            -s|--silent)
                SILENT_MODE=true
                shift
                ;;
            -d|--dir)
                DEMO_DIR="${2:-/usr}"
                shift 2
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                if [[ -d "$1" ]]; then
                    DEMO_DIR="$1"
                fi
                shift
                ;;
        esac
    done
    
    # Verifică că directorul există
    if [[ ! -d "$DEMO_DIR" ]]; then
        echo -e "${RED}Eroare: Directorul '$DEMO_DIR' nu există!${NC}" >&2
        exit 1
    fi
    
    # Rulează demo-urile
    print_banner
    sleep 1
    
    demo_spectacular_search
    demo_system_stats
    demo_file_types
    demo_find_xargs_power
    
    if [[ "$QUICK_MODE" == "false" ]]; then
        demo_security_scan
    fi
    
    demo_teaser
    
    echo ""
    echo -e "${DIM}Demo generat pentru Sisteme de Operare | ASE București - CSIE${NC}"
    echo -e "${DIM}Seminar 5-6: Utilitare Avansate, Scripturi, Permisiuni, Automatizare${NC}"
}

# Rulează main cu toate argumentele
main "$@"
