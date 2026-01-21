#!/bin/bash
#
# Script:      S05_02_demo_functions.sh
# Descriere:   Demo interactiv pentru funcții Bash
# Scop:        Demonstrare funcții, local, return values
#

set -euo pipefail

# Culori
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

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

# ============================================================
# DEMO 1: DEFINIRE ȘI APEL
# ============================================================
demo_basics() {
    banner "DEMO 1: DEFINIRE ȘI APEL FUNCȚII"
    
    echo -e "${YELLOW}Sintaxa 1: Cu keyword 'function'${NC}"
    echo ""
    
    function greet_v1() {
        echo "Hello from function keyword syntax!"
    }
    
    echo "Definire:"
    echo '  function greet_v1() {'
    echo '      echo "Hello from function keyword syntax!"'
    echo '  }'
    echo ""
    echo "Apel: greet_v1"
    echo -e "Rezultat: ${GREEN}"
    greet_v1
    echo -e "${NC}"
    
    pause
    
    echo -e "${YELLOW}Sintaxa 2: POSIX (preferată)${NC}"
    echo ""
    
    greet_v2() {
        echo "Hello from POSIX syntax!"
    }
    
    echo "Definire:"
    echo '  greet_v2() {'
    echo '      echo "Hello from POSIX syntax!"'
    echo '  }'
    echo ""
    echo "Apel: greet_v2"
    echo -e "Rezultat: ${GREEN}"
    greet_v2
    echo -e "${NC}"
    
    pause
    
    echo -e "${YELLOW}Cu argumente:${NC}"
    echo ""
    
    greet_name() {
        echo "Hello, $1! You are $2 years old."
    }
    
    echo "Definire:"
    echo '  greet_name() {'
    echo '      echo "Hello, $1! You are $2 years old."'
    echo '  }'
    echo ""
    echo 'Apel: greet_name "Alice" "25"'
    echo -e "Rezultat: ${GREEN}"
    greet_name "Alice" "25"
    echo -e "${NC}"
    
    echo ""
    echo -e "${RED}CE SE ÎNTÂMPLĂ FĂRĂ ARGUMENTE?${NC}"
    echo 'Apel: greet_name'
    echo -e "Rezultat: ${YELLOW}"
    greet_name || true
    echo -e "${NC}"
    echo -e "${RED}→ Argumentele lipsă devin string-uri goale!${NC}"
}

# ============================================================
# DEMO 2: VARIABILE LOCALE vs GLOBALE (CRITIC!)
# ============================================================
demo_scope() {
    banner "DEMO 2: VARIABILE LOCALE vs GLOBALE ⚠️"
    
    echo -e "${RED}Capcană: Aceasta este cea mai comună greșeală!${NC}"
    echo ""
    
    # Reset variabile pentru demo
    GLOBAL_VAR="initial value"
    unset CREATED_BY_FUNCTION 2>/dev/null || true
    
    echo -e "${YELLOW}Situația inițială:${NC}"
    echo "  GLOBAL_VAR = '$GLOBAL_VAR'"
    echo "  CREATED_BY_FUNCTION = (nu există)"
    echo ""
    
    pause
    
    # Funcție PROASTĂ (fără local)
    bad_function() {
        GLOBAL_VAR="modified by bad_function"     # Modifică globala!
        CREATED_BY_FUNCTION="created inside"       # Creează nouă globală!
    }
    
    echo -e "${RED}Funcția BAD (fără local):${NC}"
    echo '  bad_function() {'
    echo '      GLOBAL_VAR="modified by bad_function"'
    echo '      CREATED_BY_FUNCTION="created inside"'
    echo '  }'
    echo ""
    echo "Apelăm bad_function..."
    bad_function
    echo ""
    echo -e "${RED}După apel:${NC}"
    echo "  GLOBAL_VAR = '$GLOBAL_VAR'"
    echo "  CREATED_BY_FUNCTION = '$CREATED_BY_FUNCTION'"
    echo ""
    echo -e "${RED}→ Variabila globală a fost MODIFICATĂ!${NC}"
    echo -e "${RED}→ O nouă variabilă globală a fost CREATĂ!${NC}"
    
    pause
    
    # Reset
    GLOBAL_VAR="initial value"
    
    # Funcție BUNĂ (cu local)
    good_function() {
        local GLOBAL_VAR="local shadow"           # Shadowing - nu afectează globala
        local truly_local="exists only here"       # Variabilă pur locală
        echo "  Inside: GLOBAL_VAR = '$GLOBAL_VAR'"
        echo "  Inside: truly_local = '$truly_local'"
    }
    
    echo -e "${GREEN}Funcția GOOD (cu local):${NC}"
    echo '  good_function() {'
    echo '      local GLOBAL_VAR="local shadow"'
    echo '      local truly_local="exists only here"'
    echo '      echo "Inside: GLOBAL_VAR = $GLOBAL_VAR"'
    echo '  }'
    echo ""
    echo "GLOBAL_VAR înainte: '$GLOBAL_VAR'"
    echo ""
    echo "Apelăm good_function..."
    good_function
    echo ""
    echo -e "${GREEN}După apel:${NC}"
    echo "  GLOBAL_VAR = '$GLOBAL_VAR'"
    echo -e "  truly_local = '${truly_local:-}' (nu există în afară!)"
    echo ""
    echo -e "${GREEN}→ Variabila globală NU a fost afectată!${NC}"
    echo -e "${GREEN}→ truly_local a dispărut după ieșirea din funcție!${NC}"
    
    pause
    
    echo -e "${BOLD}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}║  REGULA DE AUR: ÎNTOTDEAUNA folosește 'local' în funcții!     ║${NC}"
    echo -e "${BOLD}╚════════════════════════════════════════════════════════════════╝${NC}"
}

# ============================================================
# DEMO 3: RETURN VALUES
# ============================================================
demo_return() {
    banner "DEMO 3: RETURN VALUES"
    
    echo -e "${YELLOW}METODA 1: echo pentru a returna string/valoare${NC}"
    echo ""
    
    get_sum() {
        local a=$1 b=$2
        echo $((a + b))
    }
    
    echo "Funcție:"
    echo '  get_sum() {'
    echo '      local a=$1 b=$2'
    echo '      echo $((a + b))'
    echo '  }'
    echo ""
    echo 'Apel: result=$(get_sum 5 3)'
    result=$(get_sum 5 3)
    echo -e "Rezultat: ${GREEN}$result${NC}"
    
    pause
    
    echo -e "${YELLOW}METODA 2: return pentru exit code (doar 0-255!)${NC}"
    echo ""
    
    is_even() {
        local n=$1
        (( n % 2 == 0 ))
    }
    
    echo "Funcție:"
    echo '  is_even() {'
    echo '      local n=$1'
    echo '      (( n % 2 == 0 ))  # Returnează 0 (true) sau 1 (false)'
    echo '  }'
    echo ""
    echo 'Utilizare în if:'
    if is_even 4; then
        echo -e "  ${GREEN}4 is even${NC}"
    fi
    if ! is_even 7; then
        echo -e "  ${GREEN}7 is odd${NC}"
    fi
    
    pause
    
    echo -e "${RED}EROARE COMUNĂ: return cu număr mare${NC}"
    echo ""
    
    get_big_number() {
        return 1000
    }
    
    echo "Funcție:"
    echo '  get_big_number() {'
    echo '      return 1000'
    echo '  }'
    echo ""
    get_big_number || true
    echo "Exit code: $?"
    echo ""
    echo -e "${RED}1000 % 256 = 232 ← return trunchiază la 0-255!${NC}"
    echo -e "${RED}Pentru valori mari, folosește echo + command substitution${NC}"
    
    pause
    
    echo -e "${YELLOW}METODA 3: Nameref (Bash 4.3+)${NC}"
    echo ""
    
    calculate() {
        local -n result_ref=$1
        local a=$2 b=$3
        result_ref=$((a * b))
    }
    
    echo "Funcție:"
    echo '  calculate() {'
    echo '      local -n result_ref=$1  # Nameref!'
    echo '      local a=$2 b=$3'
    echo '      result_ref=$((a * b))'
    echo '  }'
    echo ""
    
    declare my_result
    calculate my_result 6 7
    echo "Apel: calculate my_result 6 7"
    echo -e "my_result = ${GREEN}$my_result${NC}"
    
    pause
    
    echo -e "${BOLD}SUMAR METODE RETURN:${NC}"
    echo ""
    echo "┌────────────────────┬──────────────────────────────────────────────┐"
    echo "│ Metodă             │ Când să folosești                            │"
    echo "├────────────────────┼──────────────────────────────────────────────┤"
    echo "│ echo + \$()         │ Pentru string-uri și numere                  │"
    echo "│ return             │ Doar pentru exit codes (0-255)               │"
    echo "│ global variable    │ Evită - poluează namespace-ul                │"
    echo "│ nameref            │ Multiple return values (Bash 4.3+)           │"
    echo "└────────────────────┴──────────────────────────────────────────────┘"
}

# ============================================================
# DEMO 4: ARGUMENTE DEFENSIVE
# ============================================================
demo_defensive() {
    banner "DEMO 4: ARGUMENTE DEFENSIVE"
    
    echo -e "${YELLOW}Verificarea argumentelor obligatorii:${NC}"
    echo ""
    
    unsafe_greet() {
        echo "Hello, $1!"
    }
    
    safe_greet() {
        local name="${1:?Error: name argument required}"
        echo "Hello, $name!"
    }
    
    echo "Funcție UNSAFE:"
    echo '  unsafe_greet() {'
    echo '      echo "Hello, $1!"'
    echo '  }'
    echo ""
    echo "Apel fără argument:"
    echo -e "  Rezultat: ${YELLOW}$(unsafe_greet)${NC}"
    echo -e "  ${RED}→ String gol, fără eroare!${NC}"
    
    echo ""
    echo "Funcție SAFE:"
    echo '  safe_greet() {'
    echo '      local name="${1:?Error: name argument required}"'
    echo '      echo "Hello, $name!"'
    echo '  }'
    echo ""
    echo "Apel fără argument:"
    (safe_greet 2>&1) || true
    echo -e "  ${GREEN}→ Eroare clară!${NC}"
    
    pause
    
    echo -e "${YELLOW}Valori default pentru argumente opționale:${NC}"
    echo ""
    
    greet_with_default() {
        local name="${1:-World}"
        local greeting="${2:-Hello}"
        echo "$greeting, $name!"
    }
    
    echo "Funcție:"
    echo '  greet_with_default() {'
    echo '      local name="${1:-World}"'
    echo '      local greeting="${2:-Hello}"'
    echo '      echo "$greeting, $name!"'
    echo '  }'
    echo ""
    echo "greet_with_default"
    echo -e "  → ${GREEN}$(greet_with_default)${NC}"
    echo ""
    echo 'greet_with_default "Alice"'
    echo -e "  → ${GREEN}$(greet_with_default "Alice")${NC}"
    echo ""
    echo 'greet_with_default "Alice" "Salut"'
    echo -e "  → ${GREEN}$(greet_with_default "Alice" "Salut")${NC}"
    
    pause
    
    echo -e "${BOLD}PATTERN-URI COMUNE:${NC}"
    echo ""
    echo '${var:-default}    # Folosește default dacă var e neset sau gol'
    echo '${var:=default}    # Setează var la default dacă e neset sau gol'
    echo '${var:?error}      # Eroare dacă var e neset sau gol'
    echo '${var:+value}      # Folosește value dacă var E setat'
}

# ============================================================
# DEMO 5: FUNCȚII RECURSIVE
# ============================================================
demo_recursive() {
    banner "DEMO 5: FUNCȚII RECURSIVE"
    
    echo -e "${YELLOW}Exemplu clasic: Factorial${NC}"
    echo ""
    
    factorial() {
        local n=$1
        if (( n <= 1 )); then
            echo 1
        else
            local prev
            prev=$(factorial $((n - 1)))
            echo $((n * prev))
        fi
    }
    
    echo "Funcție:"
    echo '  factorial() {'
    echo '      local n=$1'
    echo '      if (( n <= 1 )); then'
    echo '          echo 1'
    echo '      else'
    echo '          local prev=$(factorial $((n - 1)))'
    echo '          echo $((n * prev))'
    echo '      fi'
    echo '  }'
    echo ""
    
    for i in 1 3 5 7; do
        echo "factorial($i) = $(factorial $i)"
    done
    
    pause
    
    echo -e "${RED}⚠️ Capcană: Recursivitatea în Bash este LENTĂ!${NC}"
    echo ""
    echo "Fiecare apel recursiv creează un subshell."
    echo "Pentru calcule intensive, folosește bucle sau alt limbaj."
    echo ""
    echo "Exemplu timp:"
    echo -n "  factorial(10) = "
    time_start=$(date +%s.%N)
    result=$(factorial 10)
    time_end=$(date +%s.%N)
    echo "$result (timp: $(echo "$time_end - $time_start" | bc)s)"
}

# ============================================================
# MAIN
# ============================================================
main() {
    banner "DEMO FUNCȚII BASH"
    
    echo "Acest demo acoperă:"
    echo "  1. Definire și apel"
    echo "  2. Variabile locale vs globale (CRITIC!)"
    echo "  3. Return values"
    echo "  4. Argumente defensive"
    echo "  5. Funcții recursive"
    
    pause
    
    demo_basics
    pause
    
    demo_scope
    pause
    
    demo_return
    pause
    
    demo_defensive
    pause
    
    demo_recursive
    
    banner "SUMAR"
    
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════╗
║  LECȚII CHEIE FUNCȚII:                                                   ║
║                                                                          ║
║  ✓ Folosește sintaxa POSIX: func() { ... }                              ║
║  ✓ ÎNTOTDEAUNA folosește 'local' pentru variabile în funcții            ║
║  ✓ Returnează string-uri cu echo, exit codes cu return                  ║
║  ✓ Verifică argumentele: ${1:?Error message}                            ║
║  ✓ Oferă defaults: ${1:-default_value}                                  ║
║  ✓ Evită recursivitatea pentru operații intensive                       ║
║                                                                          ║
╚══════════════════════════════════════════════════════════════════════════╝
EOF
    
    echo ""
    echo -e "${GREEN}Demo complet!${NC}"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
