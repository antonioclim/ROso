#!/bin/bash
#
# S05_06_demo_debug.sh - Demonstrație Tehnici de Debugging
# 
# Sisteme de Operare | ASE București - CSIE
# Seminar 9-10: Advanced Bash Scripting
#
# SCOP: Demonstrează tehnici practice de debugging:
#       set -x, set -v, trap DEBUG, funcții debug, BASH_* variables.
#
# UTILIZARE:
#   ./S05_06_demo_debug.sh              # Toate demo-urile
#   ./S05_06_demo_debug.sh setx         # Doar set -x
#   ./S05_06_demo_debug.sh variables    # Variabile BASH_*
#   ./S05_06_demo_debug.sh trap         # Trap DEBUG
#   DEBUG=true ./S05_06_demo_debug.sh   # Cu debug mode
#

set -uo pipefail
# Observație: Nu activăm set -e pentru a putea demonstra debugging

# ============================================================
# CONSTANTE ȘI CULORI
# ============================================================
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly MAGENTA='\033[0;35m'
readonly BOLD='\033[1m'
readonly DIM='\033[2m'
readonly NC='\033[0m'

# ============================================================
# HELPER FUNCTIONS
# ============================================================

header() {
    echo ""
    echo -e "${BOLD}${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${BLUE}  $1${NC}"
    echo -e "${BOLD}${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo ""
}

subheader() {
    echo ""
    echo -e "${CYAN}▶ $1${NC}"
    echo -e "${CYAN}────────────────────────────────────────${NC}"
}

code() {
    echo -e "${YELLOW}$1${NC}"
}

info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

pause() {
    echo ""
    read -r -p "Apasă Enter pentru a continua..." </dev/tty 2>/dev/null || true
    echo ""
}

run_demo() {
    echo -e "${BOLD}Running:${NC}"
    echo -e "${DIM}$1${NC}"
    echo -e "${DIM}─── output ───${NC}"
    eval "$1" 2>&1 || true
    echo -e "${DIM}─── end ───${NC}"
}

# ============================================================
# DEMO 1: SET -X (XTRACE)
# ============================================================

demo_set_x() {
    header "SET -X (XTRACE) - Afișează Comenzile Executate"
    
    subheader "Activare Globală"
    
    code 'set -x        # Activează trace
# comenzi...
set +x        # Dezactivează trace'
    
    echo ""
    echo "Demonstrație:"
    echo ""
    
    set -x
    greeting="Hello"
    name="World"
    echo "$greeting, $name!"
    set +x
    
    pause
    
    subheader "Activare Selectivă (pentru o secțiune)"
    
    code 'echo "Before debug"
set -x
# doar această secțiune e urmărită
result=$((5 + 3))
echo "Result: $result"
set +x
echo "After debug - nu mai apar comenzile"'
    
    echo ""
    echo "Demonstrație:"
    echo ""
    
    echo "Before debug section"
    set -x
    result=$((5 + 3))
    echo "Result: $result"
    arr=(a b c)
    for item in "${arr[@]}"; do
        echo "Item: $item"
    done
    set +x
    echo "After debug section"
    
    pause
    
    subheader "Custom PS4 (Format Trace)"
    
    info "PS4 controlează prefixul liniilor de trace"
    echo ""
    
    code 'PS4='"'"'+ ${BASH_SOURCE}:${LINENO}: ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'"'"''
    
    echo ""
    echo "Default PS4 ('+'):"
    set -x
    x=10
    set +x
    
    echo ""
    echo "Custom PS4 (cu linie și funcție):"
    old_ps4="$PS4"
    PS4='+ Line ${LINENO}: '
    set -x
    y=20
    z=$((x + y))
    set +x
    PS4="$old_ps4"
    
    pause
    
    subheader "Debug Mode din Environment"
    
    code '#!/bin/bash
DEBUG="${DEBUG:-false}"

# Activează trace doar dacă DEBUG=true
[[ "$DEBUG" == "true" ]] && set -x

# Restul scriptului...'
    
    echo ""
    info "Utilizare: DEBUG=true ./script.sh"
}

# ============================================================
# DEMO 2: SET -V (VERBOSE)
# ============================================================

demo_set_v() {
    header "SET -V (VERBOSE) - Afișează Liniile Citite"
    
    subheader "Diferența între -x și -v"
    
    echo "-x: Afișează comenzile DUPĂ expansiune (valori finale)"
    echo "-v: Afișează liniile ÎNAINTE de expansiune (cod sursă)"
    echo ""
    
    code 'name="Alice"
echo "Hello, $name"'
    
    echo ""
    echo "Cu set -x (vede valori):"
    set -x
    name="Alice"
    echo "Hello, $name"
    set +x
    
    echo ""
    echo "Cu set -v (vede cod):"
    set -v
name="Bob"
echo "Hello, $name"
    set +v
    
    pause
    
    subheader "Combinație -xv"
    
    code 'set -xv    # Ambele'
    
    echo ""
    echo "Cu set -xv (vede ambele):"
    set -xv
count=3
for ((i=1; i<=count; i++)); do
    echo "Iteration $i"
done
    set +xv
}

# ============================================================
# DEMO 3: VARIABILE BASH_* PENTRU DEBUGGING
# ============================================================

demo_bash_variables() {
    header "VARIABILE BASH_* - Context de Debugging"
    
    subheader "LINENO - Numărul Liniei Curente"
    
    code 'echo "Suntem la linia: $LINENO"'
    
    echo ""
    echo "Demonstrație:"
    echo "Aceasta e linia: $LINENO"
    echo "Iar aceasta e linia: $LINENO"
    echo "Și aceasta: $LINENO"
    
    pause
    
    subheader "BASH_SOURCE și BASH_LINENO - Stack Trace"
    
    code 'inner() {
    echo "BASH_SOURCE: ${BASH_SOURCE[@]}"
    echo "BASH_LINENO: ${BASH_LINENO[@]}"
}
outer() {
    inner
}
outer'
    
    echo ""
    echo "Demonstrație call stack:"
    
    inner_func() {
        echo "  BASH_SOURCE[0]: ${BASH_SOURCE[0]}"
        echo "  BASH_SOURCE[@]: ${BASH_SOURCE[*]}"
        echo "  BASH_LINENO[@]: ${BASH_LINENO[*]}"
    }
    
    outer_func() {
        echo "În outer_func, apelăm inner_func:"
        inner_func
    }
    
    outer_func
    
    pause
    
    subheader "FUNCNAME - Stack de Funcții"
    
    code 'func1() {
    func2
}
func2() {
    func3
}
func3() {
    echo "Call stack: ${FUNCNAME[@]}"
}'
    
    echo ""
    echo "Demonstrație:"
    
    level1() {
        level2
    }
    level2() {
        level3
    }
    level3() {
        echo "FUNCNAME stack: ${FUNCNAME[*]}"
        echo "Suntem în: ${FUNCNAME[0]}"
        echo "Apelat din: ${FUNCNAME[1]}"
        echo "Care e apelat din: ${FUNCNAME[2]}"
    }
    
    level1
    
    pause
    
    subheader "BASH_COMMAND - Comanda Curentă"
    
    code 'trap '"'"'echo "Executing: $BASH_COMMAND"'"'"' DEBUG'
    
    echo ""
    echo "Demonstrație (cu trap DEBUG):"
    
    trap 'echo -e "${DIM}  -> $BASH_COMMAND${NC}"' DEBUG
    x=5
    y=10
    z=$((x + y))
    echo "Result: $z"
    trap - DEBUG  # Remove trap
    
    pause
    
    subheader "Funcție Completă de Stack Trace"
    
    code 'print_stack_trace() {
    local frame=0
    echo "Stack trace:"
    while caller $frame; do
        ((frame++))
    done | while read line func file; do
        echo "  at $func() in $file:$line"
    done
}'
    
    print_stack_trace() {
        local frame=0
        echo "Stack trace:"
        while caller $frame; do
            ((frame++))
        done 2>/dev/null | while read -r line func file; do
            echo "  at $func() in $file:$line"
        done
    }
    
    echo ""
    echo "Demonstrație:"
    
    deep_function() {
        print_stack_trace
    }
    middle_function() {
        deep_function
    }
    top_function() {
        middle_function
    }
    
    top_function
}

# ============================================================
# DEMO 4: TRAP DEBUG
# ============================================================

demo_trap_debug() {
    header "TRAP DEBUG - Execuție Înainte de Fiecare Comandă"
    
    subheader "Trap Simplu"
    
    code 'trap '"'"'echo "[DEBUG] Line $LINENO: $BASH_COMMAND"'"'"' DEBUG
# comenzi...
trap - DEBUG  # Dezactivează'
    
    echo ""
    echo "Demonstrație:"
    
    trap 'echo -e "${DIM}[Line $LINENO] $BASH_COMMAND${NC}"' DEBUG
    
    a=5
    b=10
    c=$((a + b))
    echo "Sum: $c"
    
    trap - DEBUG
    
    pause
    
    subheader "Debugging Condiționat"
    
    code 'DEBUG_ENABLED="${DEBUG:-false}"

trap '"'"'
    [[ "$DEBUG_ENABLED" == "true" ]] && \
        echo "[DEBUG $LINENO] $BASH_COMMAND"
'"'"' DEBUG'
    
    echo ""
    echo "Cu DEBUG=true:"
    
    DEBUG_ENABLED="true"
    trap '[[ "$DEBUG_ENABLED" == "true" ]] && echo -e "${DIM}[D:$LINENO] $BASH_COMMAND${NC}"' DEBUG
    
    x=1
    y=2
    result=$((x + y))
    
    trap - DEBUG
    DEBUG_ENABLED="false"
    
    pause
    
    subheader "Step-by-Step Debugging"
    
    code 'trap '"'"'
    echo "Line $LINENO: $BASH_COMMAND"
    read -p "Press Enter to continue..." </dev/tty
'"'"' DEBUG'
    
    info "Similar cu un debugger interactiv!"
    echo ""
    echo "Simulare (fără interactivitate în demo):"
    
    step=0
    trap '((step++)); echo -e "${CYAN}[Step $step] Line $LINENO: $BASH_COMMAND${NC}"' DEBUG
    
    count=0
    for i in 1 2 3; do
        ((count += i))
    done
    echo "Total: $count"
    
    trap - DEBUG
}

# ============================================================
# DEMO 5: FUNCȚII DEBUG PRACTICE
# ============================================================

demo_debug_functions() {
    header "FUNCȚII DEBUG PRACTICE"
    
    subheader "Debug Function Pattern"
    
    code 'DEBUG="${DEBUG:-false}"
VERBOSE="${VERBOSE:-0}"

debug() {
    [[ "$DEBUG" == "true" ]] && echo "[DEBUG] $*" >&2
}

verbose() {
    [ "$VERBOSE" -ge 1 ] && echo "$*" >&2
}

very_verbose() {
    [ "$VERBOSE" -ge 2 ] && echo "[VERBOSE] $*" >&2
}'
    
    DEBUG_MODE="${DEBUG:-false}"
    VERBOSE_LEVEL="${VERBOSE:-0}"
    
    dbg() {
        [[ "$DEBUG_MODE" == "true" ]] && echo -e "${DIM}[DEBUG] $*${NC}" >&2
        return 0
    }
    
    vrb() {
        [ "$VERBOSE_LEVEL" -ge 1 ] && echo -e "${CYAN}$*${NC}" >&2
        return 0
    }
    
    vvrb() {
        [ "$VERBOSE_LEVEL" -ge 2 ] && echo -e "${DIM}[VERBOSE] $*${NC}" >&2
        return 0
    }
    
    echo ""
    echo "Cu DEBUG=false, VERBOSE=0:"
    dbg "Aceasta nu apare"
    vrb "Nici aceasta"
    echo "Normal output"
    
    echo ""
    echo "Cu DEBUG=true, VERBOSE=2:"
    DEBUG_MODE="true"
    VERBOSE_LEVEL=2
    
    dbg "Variabile: x=$((5+3)), y=$((10-2))"
    vrb "Procesăm datele..."
    vvrb "Detalii interne de procesare"
    echo "Normal output"
    
    DEBUG_MODE="false"
    VERBOSE_LEVEL=0
    
    pause
    
    subheader "Dump Variables"
    
    code 'dump_vars() {
    echo "=== Variable Dump ===" >&2
    for var in "$@"; do
        echo "$var=${!var}" >&2
    done
    echo "===================" >&2
}'
    
    dump_vars() {
        echo -e "${MAGENTA}=== Variable Dump ===${NC}" >&2
        for var in "$@"; do
            echo -e "${MAGENTA}  $var = ${!var:-<unset>}${NC}" >&2
        done
        echo -e "${MAGENTA}===================${NC}" >&2
    }
    
    echo ""
    echo "Demonstrație:"
    
    name="Alice"
    age=30
    city="București"
    
    dump_vars name age city undefined_var
    
    pause
    
    subheader "Assert Function"
    
    code 'assert() {
    local condition="$1"
    local message="${2:-Assertion failed}"
    
    if ! eval "$condition"; then
        echo "ASSERT FAILED: $message" >&2
        echo "  Condition: $condition" >&2
        echo "  Location: ${BASH_SOURCE[1]}:${BASH_LINENO[0]}" >&2
        return 1
    fi
}'
    
    assert() {
        local condition="$1"
        local message="${2:-Assertion failed}"
        
        if ! eval "$condition"; then
            echo -e "${RED}ASSERT FAILED: $message${NC}" >&2
            echo -e "${RED}  Condition: $condition${NC}" >&2
            echo -e "${RED}  Location: ${BASH_SOURCE[1]:-<main>}:${BASH_LINENO[0]}${NC}" >&2
            return 1
        fi
        echo -e "${GREEN}ASSERT OK: $condition${NC}"
        return 0
    }
    
    echo ""
    echo "Demonstrație:"
    
    x=10
    assert '[ $x -eq 10 ]' "x should be 10"
    assert '[ $x -gt 5 ]' "x should be greater than 5"
    assert '[ $x -eq 99 ]' "x should be 99" || true
}

# ============================================================
# DEMO 6: DEBUGGING COMUN ERRORS
# ============================================================

demo_common_errors() {
    header "DEBUGGING ERORI COMUNE"
    
    subheader "1. Word Splitting"
    
    echo "Problemă: variabilă cu spații"
    code 'file="my file.txt"
cat $file        # GREȘIT: devine cat my file.txt'
    
    echo ""
    echo "Debugging cu set -x:"
    set -x
    file="my file.txt"
    # Arată ce se întâmplă (nu executăm cat pentru că fișierul nu există)
    echo "Would run: cat" $file
    echo 'Should run: cat "$file"'
    set +x
    
    pause
    
    subheader "2. Empty Variable"
    
    echo "Problemă: variabilă goală în rm"
    code 'DIR=""
rm -rf $DIR/*    # PERICOL: devine rm -rf /*'
    
    echo ""
    warning "Întotdeauna verifică variabilele înainte de rm!"
    echo ""
    
    code '# Safe pattern:
DIR=""
if [[ -n "$DIR" && -d "$DIR" ]]; then
    rm -rf "$DIR"/*
else
    echo "DIR is empty or not a directory!" >&2
fi'
    
    pause
    
    subheader "3. Exit Code Capture"
    
    echo "Problemă: capturare exit code după pipe"
    code 'cat file.txt | grep pattern
echo $?    # Exit code de la grep, nu de la cat!'
    
    echo ""
    echo "Soluție: PIPESTATUS"
    code 'cat file.txt | grep pattern
echo "cat exit: ${PIPESTATUS[0]}, grep exit: ${PIPESTATUS[1]}"'
    
    echo ""
    echo "Demonstrație:"
    echo "test line" | grep "nonexistent"
    echo "PIPESTATUS: ${PIPESTATUS[*]}"
    
    pause
    
    subheader "4. Subshell Variables"
    
    echo "Problemă: variabilă modificată în subshell"
    code 'count=0
echo "a b c" | while read word; do
    ((count++))
done
echo $count    # Tot 0! while e în subshell'
    
    echo ""
    echo "Demonstrație:"
    count=0
    echo "a b c" | while read -r word; do
        ((count++))
        echo "  In loop: count=$count"
    done
    echo "After loop: count=$count"
    
    warning "Pipe creează subshell, variabilele nu se propagă înapoi!"
    
    echo ""
    echo "Soluție: Process Substitution"
    code 'count=0
while read word; do
    ((count++))
done < <(echo "a b c")
echo $count    # Corect!'
    
    count=0
    while read -r word; do
        ((count++))
    done < <(echo "a b c" | tr ' ' '\n')
    echo "With process substitution: count=$count"
}

# ============================================================
# MAIN
# ============================================================

main() {
    case "${1:-all}" in
        setx|-x)
            demo_set_x
            ;;
        setv|-v)
            demo_set_v
            ;;
        variables|vars)
            demo_bash_variables
            ;;
        trap)
            demo_trap_debug
            ;;
        functions|funcs)
            demo_debug_functions
            ;;
        errors)
            demo_common_errors
            ;;
        all)
            demo_set_x
            pause
            demo_set_v
            pause
            demo_bash_variables
            pause
            demo_trap_debug
            pause
            demo_debug_functions
            pause
            demo_common_errors
            ;;
        *)
            echo "Usage: $0 [setx|setv|variables|trap|functions|errors|all]"
            echo ""
            echo "Environment:"
            echo "  DEBUG=true    Activează debug output"
            echo "  VERBOSE=1|2   Nivel de verbose"
            exit 1
            ;;
    esac
    
    echo ""
    echo -e "${BOLD}${GREEN}═══ Demo Debugging Completat! ═══${NC}"
}

main "$@"
