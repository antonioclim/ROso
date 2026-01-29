#!/bin/bash
#
# Script:      S05_01_hook_demo.sh
# Descriere:   Demo HOOK: Script fragil vs solid
# Scop:        Demonstrație dramatică pentru început de seminar
#
# Capcană:     Acest script este DEMONSTRATIV - nu rula părțile
#              "fragile" pe sisteme de producție!
#

# ============================================================
# SETUP
# ============================================================
set -euo pipefail

readonly DEMO_DIR="/tmp/hook_demo_$$"
readonly FRAGILE_DIR="$DEMO_DIR/fragile"
readonly ROBUST_DIR="$DEMO_DIR/robust"

# Culori
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# ============================================================
# HELPERS
# ============================================================
banner() {
    echo ""
    echo -e "${BOLD}${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${BLUE}  $1${NC}"
    echo -e "${BOLD}${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo ""
}

pause() {
    echo ""
    read -p "Apasă Enter pentru a continua..."
    echo ""
}

cleanup() {
    rm -rf "$DEMO_DIR" 2>/dev/null || true
}
trap cleanup EXIT

# ============================================================
# SETUP DEMO
# ============================================================
setup_demo() {
    banner "SETUP: Creăm mediul de test"
    
    mkdir -p "$FRAGILE_DIR" "$ROBUST_DIR"
    
    # Creăm fișiere "importante"
    echo "Date importante - raport financiar" > "$FRAGILE_DIR/raport.txt"
    echo "Date importante - lista clienți" > "$FRAGILE_DIR/clienti.txt"
    echo "Backup - nu șterge!" > "$FRAGILE_DIR/backup.txt"
    
    echo "Date importante - raport financiar" > "$ROBUST_DIR/raport.txt"
    echo "Date importante - lista clienți" > "$ROBUST_DIR/clienti.txt"
    echo "Backup - nu șterge!" > "$ROBUST_DIR/backup.txt"
    
    echo -e "${GREEN}Fișiere create în directoarele de test:${NC}"
    echo ""
    echo "FRAGILE_DIR: $FRAGILE_DIR"
    ls -la "$FRAGILE_DIR"
    echo ""
    echo "ROBUST_DIR: $ROBUST_DIR"
    ls -la "$ROBUST_DIR"
}

# ============================================================
# DEMO 1: SCRIPT FRAGIL
# ============================================================
demo_fragile() {
    banner "DEMO 1: SCRIPTUL FRAGIL 💀"
    
    echo -e "${YELLOW}Acesta este un script FRAGIL (NU face asta în producție!):${NC}"
    echo ""
    cat << 'SCRIPT'
#!/bin/bash
# Script FRAGIL - EXEMPLU NEGATIV!

target_dir="$1"

cd "$target_dir"        # Ce dacă directorul nu există?
rm -rf *                 # DEZASTRU dacă cd a eșuat!
process_files           # Ce dacă funcția nu există?
echo "Gata!"
SCRIPT
    
    pause
    
    echo -e "${RED}Ce se întâmplă când rulăm cu un director INEXISTENT?${NC}"
    echo ""
    
    # Salvăm directorul curent
    local orig_dir="$PWD"
    
    # Creăm un script temporar pentru demonstrație
    local temp_script=$(mktemp)
    cat > "$temp_script" << 'ENDSCRIPT'
#!/bin/bash
# Încercăm să intrăm într-un director inexistent
cd /tmp/director_inexistent_12345
echo "cd a returnat: $?"
echo "Directorul curent este: $PWD"
ENDSCRIPT
    chmod +x "$temp_script"
    
    echo -e "${YELLOW}Executăm:${NC}"
    echo "  cd /tmp/director_inexistent_12345"
    echo ""
    
    # Rulăm într-un subshell pentru siguranță
    (
        cd /tmp/director_inexistent_12345 2>&1 || true
        echo -e "${RED}Comanda cd a EȘUAT, dar scriptul CONTINUĂ!${NC}"
        echo "Directorul curent rămâne: $PWD"
    )
    
    rm -f "$temp_script"
    
    echo ""
    echo -e "${RED}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║  PERICOL: Dacă urma 'rm -rf *', s-ar fi șters TOT             ║${NC}"
    echo -e "${RED}║           din directorul CURENT (poate fi / sau $HOME!)       ║${NC}"
    echo -e "${RED}╚═══════════════════════════════════════════════════════════════╝${NC}"
}

# ============================================================
# DEMO 2: SCRIPT solid
# ============================================================
demo_robust() {
    banner "DEMO 2: SCRIPTUL ROBUST ✅"
    
    echo -e "${GREEN}Acesta este un script ROBUST:${NC}"
    echo ""
    cat << 'SCRIPT'
#!/bin/bash
set -euo pipefail

target_dir="${1:?Error: target directory required}"

# Verificăm ÎNAINTE de a acționa
[[ -d "$target_dir" ]] || { echo "Error: Not a directory: $target_dir" >&2; exit 1; }

cd "$target_dir" || { echo "Error: Cannot cd to $target_dir" >&2; exit 1; }

# ./* în loc de * - previne disaster dacă $PWD e altceva
rm -rf ./*

echo "Cleanup completed in: $target_dir"
SCRIPT
    
    pause
    
    echo -e "${GREEN}Ce se întâmplă cu scriptul robust?${NC}"
    echo ""
    
    # Demonstrăm comportamentul solid
    echo "1. Încercăm fără argument:"
    echo -e "${YELLOW}   \${1:?Error: target directory required}${NC}"
    echo ""
    (
        set +e
        dir="${1:?Error: target directory required}" 2>&1 || true
    ) 2>&1 | head -1
    echo -e "${GREEN}   → Script-ul se oprește imediat cu eroare clară${NC}"
    
    echo ""
    echo "2. Încercăm cu director inexistent:"
    echo -e "${YELLOW}   [[ -d \"\$target_dir\" ]] || { echo \"Error\"; exit 1; }${NC}"
    echo ""
    (
        set -e
        target_dir="/tmp/inexistent_xyz_123"
        if [[ -d "$target_dir" ]]; then
            echo "Directory exists"
        else
            echo -e "${GREEN}   → Verificarea a detectat că directorul nu există${NC}"
            echo -e "${GREEN}   → Script-ul se oprește ÎNAINTE de rm${NC}"
        fi
    )
    
    echo ""
    echo "3. Folosim ./* în loc de *:"
    echo -e "${YELLOW}   rm -rf ./*${NC}"
    echo -e "${GREEN}   → Chiar dacă cd ar eșua cumva, ./* nu poate afecta /${NC}"
}

# ============================================================
# DEMO 3: COMPARAȚIE SIDE-BY-SIDE
# ============================================================
demo_comparison() {
    banner "DEMO 3: COMPARAȚIE SIDE-BY-SIDE"
    
    cat << 'EOF'
┌─────────────────────────────────────┬─────────────────────────────────────┐
│         ❌ SCRIPT FRAGIL             │         ✅ SCRIPT ROBUST             │
├─────────────────────────────────────┼─────────────────────────────────────┤
│ #!/bin/bash                         │ #!/bin/bash                         │
│                                     │ set -euo pipefail                   │
│                                     │                                     │
│ cd "$1"                             │ dir="${1:?Error: dir required}"     │
│                                     │ [[ -d "$dir" ]] || exit 1           │
│                                     │ cd "$dir" || exit 1                 │
│                                     │                                     │
│ rm -rf *                            │ rm -rf ./*                          │
│                                     │                                     │
│ process $file                       │ process "$file"                     │
│                                     │                                     │
│ echo "Done"                         │ echo "Done: $dir cleaned"           │
├─────────────────────────────────────┼─────────────────────────────────────┤
│ • Ignoră erori                      │ • Se oprește la erori               │
│ • Variabile fără ghilimele          │ • Variabile cu ghilimele            │
│ • rm -rf * periculos               │ • rm -rf ./* sigur                  │
│ • Mesaje vagi                       │ • Mesaje clare                      │
│ • Poate distruge sistemul!          │ • Fail-safe                         │
└─────────────────────────────────────┴─────────────────────────────────────┘
EOF
    
    pause
    
    echo -e "${BOLD}ÎNTREBARE PENTRU CLASĂ:${NC}"
    echo ""
    echo "Este ora 3 dimineața. Trebuie să rulezi un script de cleanup"
    echo "pe serverul de producție care conține datele clienților."
    echo ""
    echo -e "${YELLOW}Care script rulezi?${NC}"
    echo ""
    echo "  A) Scriptul fragil - e mai scurt și probabil funcționează"
    echo "  B) Scriptul robust - durează mai mult să-l scriu dar e sigur"
    echo ""
}

# ============================================================
# DEMO 4: LIVE - set -euo pipefail în acțiune
# ============================================================
demo_set_options() {
    banner "DEMO 4: set -euo pipefail ÎN ACȚIUNE"
    
    echo -e "${BOLD}Ce face fiecare opțiune:${NC}"
    echo ""
    
    echo -e "${YELLOW}1. set -e (errexit)${NC}"
    echo "   Script-ul se oprește când o comandă returnează non-zero"
    echo ""
    echo "   Fără set -e:"
    (
        false
        echo "   Script-ul continuă după 'false' ← PERICULOS!"
    )
    echo ""
    echo "   Cu set -e:"
    (
        set +e  # dezactivăm pentru demo în subshell
        set -e
        false || echo "   Script-ul s-ar fi oprit aici (demo în subshell)"
    )
    
    pause
    
    echo -e "${YELLOW}2. set -u (nounset)${NC}"
    echo "   Eroare la variabile nedefinite"
    echo ""
    echo "   Fără set -u:"
    (
        set +u
        echo "   UNDEFINED=[$UNDEFINED_VAR] ← String gol, fără eroare!"
    )
    echo ""
    echo "   Cu set -u:"
    echo "   bash: UNDEFINED_VAR: unbound variable"
    echo "   → Script-ul se oprește!"
    
    pause
    
    echo -e "${YELLOW}3. set -o pipefail${NC}"
    echo "   Pipe returnează eroarea oricărei comenzi, nu doar ultima"
    echo ""
    echo "   Fără pipefail:"
    (
        set +o pipefail
        false | true
        echo "   Exit code: $? ← 0 (de la 'true'), eroarea de la 'false' e ascunsă!"
    )
    echo ""
    echo "   Cu pipefail:"
    (
        set -o pipefail
        false | true || echo "   Exit code: 1 ← Eroarea de la 'false' e detectată!"
    )
}

# ============================================================
# MAIN
# ============================================================
main() {
    banner "🎬 HOOK: SCRIPT FRAGIL vs ROBUST"
    
    echo -e "${BOLD}Acest demo arată de ce contează scripturile robuste.${NC}"
    echo "Vei vedea diferența dintre cod amator și cod profesional."
    echo ""
    echo "Capcană: Exemplele 'fragile' sunt doar pentru demonstrație!"
    echo "         NU rula cod fragil pe sisteme reale."
    
    pause
    
    setup_demo
    pause
    
    demo_fragile
    pause
    
    demo_robust
    pause
    
    demo_comparison
    pause
    
    demo_set_options
    
    banner "CONCLUZII"
    
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════╗
║                                                                          ║
║  🎯 LECȚII CHEIE:                                                        ║
║                                                                          ║
║  1. ÎNTOTDEAUNA începe cu: set -euo pipefail                            ║
║                                                                          ║
║  2. VERIFICĂ înainte de a acționa:                                       ║
║     • Directorul există?                                                 ║
║     • Fișierul e citibil?                                               ║
║     • Am permisiuni?                                                    ║
║                                                                          ║
║  3. FOLOSEȘTE ghilimele la variabile: "$var" nu $var                    ║
║                                                                          ║
║  4. MESAJE DE EROARE clare când ceva nu merge                            ║
║                                                                          ║
║  5. FAIL EARLY - e mai bine să te oprești devreme decât să continui     ║
║     și să cauzezi daune mai mari                                        ║
║                                                                          ║
╚══════════════════════════════════════════════════════════════════════════╝
EOF
    
    echo ""
    echo -e "${GREEN}Demo complet! Template-ul profesional aplică toate aceste principii.${NC}"
    echo ""
}

# Rulează doar dacă scriptul e executat direct
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
