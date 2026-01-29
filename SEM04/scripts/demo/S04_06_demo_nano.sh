#!/bin/bash
#===============================================================================
#          FILE: S04_06_demo_nano.sh
#   DESCRIPTION: Demo pentru editorul nano - afișează comenzile cheie
#===============================================================================

set -euo pipefail

readonly CYAN='\033[0;36m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

clear
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                    DEMO: NANO EDITOR                         ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${YELLOW}═══ De ce Nano? ═══${NC}"
echo ""
echo "• Simplu și intuitiv"
echo "• Toate comenzile sunt afișate în footer"
echo "• Nu necesită memorizare moduri (ca vim)"
echo "• Disponibil pe aproape orice sistem Linux"
echo ""

echo -e "${YELLOW}═══ Comenzi Esențiale (^ = CTRL) ═══${NC}"
echo ""
echo -e "${GREEN}Salvare și Ieșire:${NC}"
echo "  ^O = Write Out (Save)"
echo "  ^X = Exit"
echo ""
echo -e "${GREEN}Căutare:${NC}"
echo "  ^W = Where Is (Search)"
echo "  ^Q = Where Was (Search backwards)"
echo ""
echo -e "${GREEN}Editare:${NC}"
echo "  ^K = Cut line"
echo "  ^U = Uncut (Paste)"
echo "  ^6 = Mark set (pentru selecție)"
echo ""
echo -e "${GREEN}Navigare:${NC}"
echo "  ^A = Beginning of line"
echo "  ^E = End of line"
echo "  ^Y = Page Up"
echo "  ^V = Page Down"
echo ""
echo -e "${GREEN}Ajutor:${NC}"
echo "  ^G = Get Help"
echo ""

echo -e "${YELLOW}═══ Workflow Tipic ═══${NC}"
echo ""
echo "1. Deschide: nano filename.txt"
echo "2. Editează conținutul"
echo "3. Salvează: ^O → Enter"
echo "4. Ieși: ^X"
echo ""

read -rp "Apasă Enter pentru a deschide nano cu un fișier demo..."

# Creează un fișier demo
cat > /tmp/nano_demo.txt << 'EOF'
# Aceasta este o demonstrație nano
# ==================================

Încearcă aceste acțiuni:

1. Navighează cu săgețile
2. Caută "demo" cu ^W
3. Taie această linie cu ^K
4. Lipește-o mai jos cu ^U
5. Salvează cu ^O
6. Ieși cu ^X

# Observație: Toate comenzile sunt afișate în bara de jos!
EOF

nano /tmp/nano_demo.txt

echo ""
echo -e "${GREEN}✓ Demo nano complet!${NC}"
rm -f /tmp/nano_demo.txt
