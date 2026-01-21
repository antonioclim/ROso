#!/bin/bash
#
# DEMO FHS EXPLORER - Explorare interactivă a sistemului de fișiere
# Sisteme de Operare | ASE București - CSIE
#

# Culori
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
MAGENTA='\033[0;35m'
NC='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'

clear

echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}           ${WHITE}${BOLD}FILESYSTEM HIERARCHY STANDARD (FHS) EXPLORER${NC}                      ${CYAN}║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

#
# Diagrama FHS
#

echo -e "${WHITE}${BOLD}Structura Ierarhică a Sistemului de Fișiere Linux:${NC}"
echo ""

echo -e "${YELLOW}/${NC} ${DIM}(rădăcina - totul pornește de aici)${NC}"
echo -e "├── ${GREEN}bin/${NC}      ${DIM}→ Binare esențiale (ls, cp, mv, cat...)${NC}"
echo -e "├── ${GREEN}sbin/${NC}     ${DIM}→ Binare sistem (pentru root: fdisk, mount...)${NC}"
echo -e "├── ${CYAN}etc/${NC}      ${DIM}→ ${BOLD}E${NC}${DIM}ditable ${BOLD}T${NC}${DIM}ext ${BOLD}C${NC}${DIM}onfig (configurări sistem)${NC}"
echo -e "│   ├── passwd     ${DIM}→ Informații utilizatori${NC}"
echo -e "│   ├── shadow     ${DIM}→ Parole criptate (doar root)${NC}"
echo -e "│   ├── hosts      ${DIM}→ Mapări DNS locale${NC}"
echo -e "│   └── bash.bashrc ${DIM}→ Configurare Bash globală${NC}"
echo -e "├── ${MAGENTA}home/${NC}     ${DIM}→ Directoarele utilizatorilor${NC}"
echo -e "│   └── ${YELLOW}$USER/${NC}  ${DIM}→ HOME-ul tău (~)${NC}"
echo -e "│       ├── Desktop/"
echo -e "│       ├── Documents/"
echo -e "│       ├── Downloads/"
echo -e "│       └── ${GREEN}.bashrc${NC}  ${DIM}→ Configurarea TA personală${NC}"
echo -e "├── ${RED}tmp/${NC}      ${DIM}→ Fișiere temporare (ȘTERS la reboot!)${NC}"
echo -e "├── ${BLUE}var/${NC}      ${DIM}→ Date variabile${NC}"
echo -e "│   ├── log/       ${DIM}→ Jurnale sistem${NC}"
echo -e "│   ├── cache/     ${DIM}→ Cache aplicații${NC}"
echo -e "│   └── www/       ${DIM}→ Fișiere web server${NC}"
echo -e "├── ${GREEN}usr/${NC}      ${DIM}→ Unix System Resources${NC}"
echo -e "│   ├── bin/       ${DIM}→ Programe utilizator${NC}"
echo -e "│   ├── lib/       ${DIM}→ Biblioteci${NC}"
echo -e "│   └── share/     ${DIM}→ Date partajate${NC}"
echo -e "├── ${YELLOW}opt/${NC}      ${DIM}→ Software opțional (aplicații third-party)${NC}"
echo -e "├── ${MAGENTA}dev/${NC}      ${DIM}→ Dispozitive hardware (ca fișiere!)${NC}"
echo -e "│   ├── null       ${DIM}→ \"Gaura neagră\" - înghite tot${NC}"
echo -e "│   ├── zero       ${DIM}→ Sursă infinită de zerouri${NC}"
echo -e "│   └── sda        ${DIM}→ Primul hard disk${NC}"
echo -e "├── ${CYAN}proc/${NC}     ${DIM}→ Procese (filesystem virtual)${NC}"
echo -e "│   ├── cpuinfo    ${DIM}→ Informații CPU${NC}"
echo -e "│   └── meminfo    ${DIM}→ Informații memorie${NC}"
echo -e "└── ${BLUE}root/${NC}     ${DIM}→ Home-ul utilizatorului root${NC}"
echo ""

#
# Mnemonici
#

echo -e "${WHITE}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${WHITE}${BOLD}MNEMONICI pentru memorare:${NC}"
echo ""

echo -e "${CYAN}/etc${NC}  = ${BOLD}E${NC}ditable ${BOLD}T${NC}ext ${BOLD}C${NC}onfiguration"
echo -e "${CYAN}/var${NC}  = ${BOLD}VAR${NC}iable data (se schimbă frecvent)"
echo -e "${CYAN}/tmp${NC}  = ${BOLD}T${NC}e${BOLD}MP${NC}orary (temporar - dispare!)"
echo -e "${CYAN}/opt${NC}  = ${BOLD}OPT${NC}ional software"
echo -e "${CYAN}/usr${NC}  = ${BOLD}U${NC}nix ${BOLD}S${NC}ystem ${BOLD}R${NC}esources (NU \"user\"!)"
echo -e "${CYAN}/bin${NC}  = ${BOLD}BIN${NC}aries (executabile)"
echo -e "${CYAN}/lib${NC}  = ${BOLD}LIB${NC}raries (biblioteci)"
echo -e "${CYAN}/dev${NC}  = ${BOLD}DEV${NC}ices (dispozitive)"
echo -e "${CYAN}/proc${NC} = ${BOLD}PROC${NC}esses (procese virtuale)"
echo ""

#
# Explorare Live
#

echo -e "${WHITE}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${WHITE}${BOLD}EXPLORARE LIVE a sistemului tău:${NC}"
echo ""

echo -e "${YELLOW}► Conținutul lui / (rădăcină):${NC}"
ls -1 / | head -15 | while read dir; do
    echo -e "  ${GREEN}$dir${NC}"
done
echo -e "  ${DIM}...${NC}"
echo ""

echo -e "${YELLOW}► Câteva fișiere din /etc:${NC}"
ls /etc/*.conf 2>/dev/null | head -5 | while read f; do
    echo -e "  ${CYAN}$(basename "$f")${NC}"
done
echo ""

echo -e "${YELLOW}► HOME-ul tău ($HOME):${NC}"
ls -la "$HOME" | head -8
echo ""

echo -e "${YELLOW}► Informații sistem din /proc:${NC}"
echo -e "  CPU: $(grep 'model name' /proc/cpuinfo 2>/dev/null | head -1 | cut -d: -f2 | xargs || echo 'N/A')"
echo -e "  RAM: $(grep 'MemTotal' /proc/meminfo 2>/dev/null | awk '{printf "%.1f GB", $2/1024/1024}' || echo 'N/A')"
echo -e "  Kernel: $(cat /proc/version 2>/dev/null | cut -d' ' -f3 || echo 'N/A')"
echo ""

#
# Comparație Windows vs Linux
#

echo -e "${WHITE}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${WHITE}${BOLD}COMPARAȚIE: Windows vs Linux${NC}"
echo ""

echo -e "${CYAN}┌────────────────────────────┬────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}        ${BOLD}WINDOWS${NC}             ${CYAN}│${NC}                    ${BOLD}LINUX${NC}                      ${CYAN}│${NC}"
echo -e "${CYAN}├────────────────────────────┼────────────────────────────────────────────────┤${NC}"
echo -e "${CYAN}│${NC} C:\\                        ${CYAN}│${NC} /                                              ${CYAN}│${NC}"
echo -e "${CYAN}│${NC} C:\\Users\\Nume             ${CYAN}│${NC} /home/nume sau ~                               ${CYAN}│${NC}"
echo -e "${CYAN}│${NC} C:\\Program Files          ${CYAN}│${NC} /usr/bin, /opt                                 ${CYAN}│${NC}"
echo -e "${CYAN}│${NC} C:\\Windows\\System32       ${CYAN}│${NC} /bin, /sbin                                    ${CYAN}│${NC}"
echo -e "${CYAN}│${NC} C:\\Windows\\Temp           ${CYAN}│${NC} /tmp                                           ${CYAN}│${NC}"
echo -e "${CYAN}│${NC} Registry                  ${CYAN}│${NC} /etc (fișiere text!)                           ${CYAN}│${NC}"
echo -e "${CYAN}│${NC} Drive letters (C:, D:)    ${CYAN}│${NC} Mount points (/mnt, /media)                    ${CYAN}│${NC}"
echo -e "${CYAN}│${NC} \\ (backslash)             ${CYAN}│${NC} / (forward slash)                              ${CYAN}│${NC}"
echo -e "${CYAN}│${NC} Case insensitive          ${CYAN}│${NC} ${RED}CASE SENSITIVE!${NC}                              ${CYAN}│${NC}"
echo -e "${CYAN}└────────────────────────────┴────────────────────────────────────────────────┘${NC}"
echo ""

echo -e "${RED}⚠️  Capcană: Linux face diferența între Fisier.txt și fisier.txt!${NC}"
echo ""

#
# Reguli Importante
#

echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC}                         ${BOLD}REGULI IMPORTANTE${NC}                                      ${GREEN}║${NC}"
echo -e "${GREEN}╠═══════════════════════════════════════════════════════════════════════════════╣${NC}"
echo -e "${GREEN}║${NC}  1. Totul este un fișier în Linux (chiar și dispozitivele!)                 ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}  2. /tmp se șterge la reboot - NU stoca date importante acolo               ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}  3. ~ este scurtătură pentru \$HOME                                          ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}  4. Fișierele care încep cu . sunt ascunse (ex: .bashrc)                    ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}  5. Separator de cale este / (NU \\)                                         ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}  6. Nu există \"drive letters\" - totul e sub /                               ${GREEN}║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
