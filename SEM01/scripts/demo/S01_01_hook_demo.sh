#!/bin/bash
#
# HOOK DEMO - Seminar 1: Shell Bash
# Sisteme de Operare | ASE București - CSIE
# 
# Scop: Captarea atenției la începutul seminarului cu efecte vizuale
# Durată: ~3 minute
# Dependențe: figlet, lolcat, cmatrix, cowsay (opționale)
#

set -e

# Culori ANSI
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Funcție pentru pauză dramatică
dramatic_pause() {
    sleep "${1:-1}"
}

# Funcție pentru text centrat
center_text() {
    local text="$1"
    local width=$(tput cols)
    local padding=$(( (width - ${#text}) / 2 ))
    printf "%*s%s\n" $padding "" "$text"
}

# Funcție pentru banner ASCII (fallback dacă lipsește figlet)
ascii_banner() {
    echo ""
    echo -e "${CYAN}"
    echo "    ____    _    ____  _   _ "
    echo "   | __ )  / \\  / ___|| | | |"
    echo "   |  _ \\ / _ \\ \\___ \\| |_| |"
    echo "   | |_) / ___ \\ ___) |  _  |"
    echo "   |____/_/   \\_\\____/|_| |_|"
    echo ""
    echo -e "${NC}"
}

# Funcție pentru efectul Matrix (fallback)
matrix_effect() {
    local duration=${1:-3}
    local chars="ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜﾝ0123456789"
    local width=$(tput cols)
    local end_time=$((SECONDS + duration))
    
    echo -e "${GREEN}"
    while [ $SECONDS -lt $end_time ]; do
        for ((i=0; i<width; i++)); do
            if [ $((RANDOM % 3)) -eq 0 ]; then
                printf "%s" "${chars:RANDOM%${#chars}:1}"
            else
                printf " "
            fi
        done
        echo ""
        sleep 0.05
    done
    echo -e "${NC}"
}

# Funcție pentru cowsay fallback
tux_says() {
    local message="$1"
    echo ""
    echo -e "${YELLOW}"
    echo "  $message"
    echo "         \\"
    echo "          \\"
    echo "           .--."
    echo "          |o_o |"
    echo "          |:_/ |"
    echo "         //   \\ \\"
    echo "        (|     | )"
    echo "       /'\\_   _/\`\\"
    echo "       \\___)=(___/"
    echo -e "${NC}"
}

# Funcție pentru heartbeat one-liner
heartbeat_demo() {
    echo -e "\n${CYAN}═══ HEARTBEAT SYSTEM MONITOR ═══${NC}\n"
    for i in {1..5}; do
        local load=$(cat /proc/loadavg 2>/dev/null | cut -d' ' -f1 || echo "N/A")
        local mem=$(free -m 2>/dev/null | awk '/Mem:/ {printf "%.1f%%", $3/$2*100}' || echo "N/A")
        local disk=$(df -h / 2>/dev/null | awk 'NR==2 {print $5}' || echo "N/A")
        
        printf "\r${GREEN}♥${NC} [%s] Load: ${YELLOW}%s${NC} | Mem: ${CYAN}%s${NC} | Disk: ${MAGENTA}%s${NC}  " \
               "$(date +%H:%M:%S)" "$load" "$mem" "$disk"
        sleep 1
    done
    echo ""
}

#
# MAIN DEMO SEQUENCE
#

clear

echo -e "\n${WHITE}${BOLD}>>> Bine ați venit la Sisteme de Operare! <<<${NC}\n"
dramatic_pause 1

# Banner principal
echo -e "${BOLD}Înainte de orice teorie, hai să vedem ce poate face shell-ul...${NC}\n"
dramatic_pause 1

# Încearcă figlet + lolcat, fallback la ASCII
if command -v figlet &>/dev/null && command -v lolcat &>/dev/null; then
    figlet -f slant "BASH" | lolcat
elif command -v figlet &>/dev/null; then
    figlet -f slant "BASH"
else
    ascii_banner
fi

dramatic_pause 2

# Efectul Matrix
echo -e "\n${BOLD}Acesta este terminalul. Nu e doar pentru hackeri în filme...${NC}\n"
dramatic_pause 1

if command -v cmatrix &>/dev/null; then
    echo -e "${YELLOW}[Apasă Ctrl+C pentru a opri]${NC}"
    timeout 3 cmatrix -b -C green 2>/dev/null || true
else
    echo -e "${YELLOW}[Simulare efect Matrix]${NC}"
    matrix_effect 2
fi

dramatic_pause 1

# Cowsay
echo -e "\n${BOLD}Și da, putem face și asta...${NC}\n"

if command -v cowsay &>/dev/null && command -v lolcat &>/dev/null; then
    cowsay -f tux "Bine ați venit la SO!" | lolcat
elif command -v cowsay &>/dev/null; then
    cowsay -f tux "Bine ați venit la SO!"
else
    tux_says "Bine ați venit la SO!"
fi

dramatic_pause 2

# System info rapid
echo -e "\n${CYAN}═══ SISTEM CURENT ═══${NC}"
echo -e "  ${YELLOW}OS:${NC}     $(uname -s) $(uname -r)"
echo -e "  ${YELLOW}User:${NC}   $USER"
echo -e "  ${YELLOW}Shell:${NC}  $SHELL"
echo -e "  ${YELLOW}Home:${NC}   $HOME"
echo -e "  ${YELLOW}PWD:${NC}    $PWD"

dramatic_pause 2

# Heartbeat demo
heartbeat_demo

# Încheiere
echo -e "\n${WHITE}${BOLD}"
center_text "╔════════════════════════════════════════════════════════════╗"
center_text "║   În următoarele 2 ore, veți învăța să controlați          ║"
center_text "║   acest mediu puternic. Să începem!                        ║"
center_text "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}\n"

# Verificare tools disponibile
echo -e "${CYAN}[INFO] Tools disponibile pentru demo:${NC}"
for tool in figlet lolcat cmatrix cowsay tree ncdu pv dialog; do
    if command -v $tool &>/dev/null; then
        echo -e "  ${GREEN}✓${NC} $tool"
    else
        echo -e "  ${RED}✗${NC} $tool (opțional)"
    fi
done
echo ""
