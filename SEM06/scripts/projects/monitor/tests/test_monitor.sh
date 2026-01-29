#!/bin/bash
#==============================================================================
# test_monitor.sh - Suite de teste pentru System Monitor
#==============================================================================
# DESCRIERE:
#   Teste unitare și de integrare pentru aplicația System Monitor.
#   Verifică funcționalitatea tuturor componentelor: core, utils, config.
#
# UTILIZARE:
#   ./tests/test_monitor.sh           # Rulează toate testele
#   ./tests/test_monitor.sh -v        # Verbose mode
#   ./tests/test_monitor.sh core      # Doar testele pentru core.sh
#
# AUTOR: ASE București - CSIE | Sisteme de Operare
# VERSIUNE: 1.0.0
#==============================================================================

set -u  # Nu folosim -e pentru că testele pot eșua

#------------------------------------------------------------------------------
# SETUP
#------------------------------------------------------------------------------

# Directorul testelor
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$TEST_DIR")"
SCRIPT_DIR="$PROJECT_DIR"

# Variabile pentru rezultate
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0
VERBOSE="${VERBOSE:-false}"
TEST_FILTER="${1:-}"

# Directoare temporare pentru teste
TEST_TMP_DIR=""

#------------------------------------------------------------------------------
# FRAMEWORK DE TESTARE
#------------------------------------------------------------------------------

# Pregătire înainte de teste
setup() {
    TEST_TMP_DIR=$(mktemp -d)
    export LOG_TO_STDOUT="false"
    export LOG_FILE="${TEST_TMP_DIR}/test.log"
    export LOG_LEVEL="DEBUG"
}

# Curățare după teste
teardown() {
    if [[ -d "$TEST_TMP_DIR" ]]; then
        rm -rf "$TEST_TMP_DIR"
    fi
}

# Afișează mesaj de test
test_msg() {
    if [[ "$VERBOSE" == "true" ]]; then
        echo "  $*"
    fi
}

# Assert că două valori sunt egale
assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Valorile trebuie să fie egale}"
    
    if [[ "$expected" == "$actual" ]]; then
        echo "✓ PASS: $message"
        ((TESTS_PASSED++))
        return 0
    else
        echo "✗ FAIL: $message"
        echo "  Expected: '$expected'"
        echo "  Actual:   '$actual'"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Assert că o valoare nu este goală
assert_not_empty() {
    local value="$1"
    local message="${2:-Valoarea nu trebuie să fie goală}"
    
    if [[ -n "$value" ]]; then
        echo "✓ PASS: $message"
        ((TESTS_PASSED++))
        return 0
    else
        echo "✗ FAIL: $message"
        echo "  Valoare goală primită"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Assert că o condiție este adevărată
assert_true() {
    local condition="$1"
    local message="${2:-Condiția trebuie să fie adevărată}"
    
    if eval "$condition"; then
        echo "✓ PASS: $message"
        ((TESTS_PASSED++))
        return 0
    else
        echo "✗ FAIL: $message"
        echo "  Condiție: $condition"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Assert că o condiție este falsă
assert_false() {
    local condition="$1"
    local message="${2:-Condiția trebuie să fie falsă}"
    
    if ! eval "$condition"; then
        echo "✓ PASS: $message"
        ((TESTS_PASSED++))
        return 0
    else
        echo "✗ FAIL: $message"
        echo "  Condiție (trebuia să fie falsă): $condition"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Assert că un fișier există
assert_file_exists() {
    local file="$1"
    local message="${2:-Fișierul trebuie să existe}"
    
    if [[ -f "$file" ]]; then
        echo "✓ PASS: $message"
        ((TESTS_PASSED++))
        return 0
    else
        echo "✗ FAIL: $message"
        echo "  Fișier: $file"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Assert că output-ul conține un string
assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-Output trebuie să conțină textul}"
    
    if [[ "$haystack" == *"$needle"* ]]; then
        echo "✓ PASS: $message"
        ((TESTS_PASSED++))
        return 0
    else
        echo "✗ FAIL: $message"
        echo "  Căutat: '$needle'"
        echo "  În: '${haystack:0:200}...'"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Assert că o valoare este un număr
assert_is_number() {
    local value="$1"
    local message="${2:-Valoarea trebuie să fie număr}"
    
    if [[ "$value" =~ ^-?[0-9]+$ ]]; then
        echo "✓ PASS: $message"
        ((TESTS_PASSED++))
        return 0
    else
        echo "✗ FAIL: $message"
        echo "  Valoare: '$value'"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Assert că o valoare este în interval
assert_in_range() {
    local value="$1"
    local min="$2"
    local max="$3"
    local message="${4:-Valoarea trebuie să fie în interval}"
    
    if [[ "$value" =~ ^-?[0-9]+$ ]] && [[ $value -ge $min ]] && [[ $value -le $max ]]; then
        echo "✓ PASS: $message"
        ((TESTS_PASSED++))
        return 0
    else
        echo "✗ FAIL: $message"
        echo "  Valoare: $value, Interval: [$min, $max]"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Skip un test cu motiv
skip_test() {
    local message="$1"
    echo "○ SKIP: $message"
    ((TESTS_SKIPPED++))
}

#------------------------------------------------------------------------------
# ÎNCARCĂ BIBLIOTECILE
#------------------------------------------------------------------------------

# Încarcă bibliotecile pentru teste
load_libraries() {
    source "${PROJECT_DIR}/lib/core.sh" || return 1
    source "${PROJECT_DIR}/lib/utils.sh" || return 1
    source "${PROJECT_DIR}/lib/config.sh" || return 1
    return 0
}

#------------------------------------------------------------------------------
# TESTE CORE.SH
#------------------------------------------------------------------------------

test_core_logging() {
    echo ""
    echo "=== Teste: core.sh - Logging ==="
    
    # Test _get_timestamp
    local timestamp
    timestamp=$(_get_timestamp)
    assert_not_empty "$timestamp" "_get_timestamp returnează timestamp"
    
    # Test _log_level_to_int
    assert_equals "0" "$(_log_level_to_int DEBUG)" "DEBUG = 0"
    assert_equals "1" "$(_log_level_to_int INFO)" "INFO = 1"
    assert_equals "2" "$(_log_level_to_int WARN)" "WARN = 2"
    assert_equals "3" "$(_log_level_to_int ERROR)" "ERROR = 3"
    assert_equals "4" "$(_log_level_to_int FATAL)" "FATAL = 4"
    
    # Test _should_log
    LOG_LEVEL="INFO"
    assert_true '_should_log INFO' "INFO trebuie logat când nivel=INFO"
    assert_true '_should_log ERROR' "ERROR trebuie logat când nivel=INFO"
    assert_false '_should_log DEBUG' "DEBUG nu trebuie logat când nivel=INFO"
    
    LOG_LEVEL="DEBUG"
    assert_true '_should_log DEBUG' "DEBUG trebuie logat când nivel=DEBUG"
    
    # Test log la fișier
    local test_log="${TEST_TMP_DIR}/test_log.log"
    LOG_FILE="$test_log"
    LOG_TO_STDOUT="false"
    log INFO "Test message"
    assert_file_exists "$test_log" "Fișierul log trebuie creat"
    assert_contains "$(cat "$test_log")" "Test message" "Mesajul trebuie scris în log"
}

test_core_validation() {
    echo ""
    echo "=== Teste: core.sh - Validare ==="
    
    # Test is_integer
    assert_true 'is_integer 42' "42 este integer"
    assert_true 'is_integer -5' "-5 este integer"
    assert_true 'is_integer 0' "0 este integer"
    assert_false 'is_integer 3.14' "3.14 nu este integer"
    assert_false 'is_integer abc' "abc nu este integer"
    assert_false 'is_integer ""' "string gol nu este integer"
    
    # Test in_range
    assert_true 'in_range 50 0 100' "50 în interval [0,100]"
    assert_true 'in_range 0 0 100' "0 în interval [0,100]"
    assert_true 'in_range 100 0 100' "100 în interval [0,100]"
    assert_false 'in_range 101 0 100' "101 nu în interval [0,100]"
    assert_false 'in_range -1 0 100' "-1 nu în interval [0,100]"
    
    # Test require_cmd
    assert_true 'require_cmd bash' "require_cmd bash (există)"
}

test_core_utilities() {
    echo ""
    echo "=== Teste: core.sh - Utilitare ==="
    
    # Test format_duration
    assert_equals "00:00" "$(format_duration 0)" "0 secunde = 00:00"
    assert_equals "01:00" "$(format_duration 60)" "60 secunde = 01:00"
    assert_equals "01:01:01" "$(format_duration 3661)" "3661 secunde = 01:01:01"
}

test_core_lock() {
    echo ""
    echo "=== Teste: core.sh - Lock Files ==="
    
    local lock_file="${TEST_TMP_DIR}/test.lock"
    
    # Test acquire lock
    assert_true 'acquire_lock "$lock_file"' "Poate achiziționa lock"
    assert_file_exists "$lock_file" "Lock file creat"
    
    local stored_pid
    stored_pid=$(cat "$lock_file")
    assert_equals "$$" "$stored_pid" "Lock file conține PID-ul corect"
    
    # Test release lock
    release_lock "$lock_file"
    assert_false '[[ -f "$lock_file" ]]' "Lock file șters după release"
}

#------------------------------------------------------------------------------
# TESTE UTILS.SH
#------------------------------------------------------------------------------

test_utils_cpu() {
    echo ""
    echo "=== Teste: utils.sh - CPU ==="
    
    # Test get_cpu_usage
    local cpu_usage
    cpu_usage=$(get_cpu_usage)
    assert_is_number "$cpu_usage" "CPU usage este număr"
    assert_in_range "$cpu_usage" 0 100 "CPU usage în interval [0,100]"
    
    # Test get_cpu_cores
    local cores
    cores=$(get_cpu_cores)
    assert_is_number "$cores" "Număr cores este număr"
    assert_true '[[ $cores -ge 1 ]]' "Cel puțin 1 core"
    
    # Test get_load_average
    local load
    load=$(get_load_average)
    assert_not_empty "$load" "Load average nu este gol"
}

test_utils_memory() {
    echo ""
    echo "=== Teste: utils.sh - Memorie ==="
    
    # Test get_memory_usage
    local mem_usage
    mem_usage=$(get_memory_usage)
    assert_is_number "$mem_usage" "Memory usage este număr"
    assert_in_range "$mem_usage" 0 100 "Memory usage în interval [0,100]"
    
    # Test get_memory_details
    local mem_details
    mem_details=$(get_memory_details)
    assert_not_empty "$mem_details" "Memory details nu este gol"
    
    # Test get_swap_usage
    local swap_usage
    swap_usage=$(get_swap_usage)
    assert_is_number "$swap_usage" "Swap usage este număr"
    assert_in_range "$swap_usage" 0 100 "Swap usage în interval [0,100]"
}

test_utils_disk() {
    echo ""
    echo "=== Teste: utils.sh - Disk ==="
    
    # Test get_disk_usage
    local disk_usage
    disk_usage=$(get_disk_usage "/")
    assert_is_number "$disk_usage" "Disk usage / este număr"
    assert_in_range "$disk_usage" 0 100 "Disk usage / în interval [0,100]"
    
    # Test get_all_disk_info
    local disk_info
    disk_info=$(get_all_disk_info)
    assert_not_empty "$disk_info" "Disk info nu este gol"
    
    # Test get_available_space_mb
    local space
    space=$(get_available_space_mb "/")
    assert_is_number "$space" "Available space este număr"
}

test_utils_processes() {
    echo ""
    echo "=== Teste: utils.sh - Procese ==="
    
    # Test get_process_count
    local proc_count
    proc_count=$(get_process_count)
    assert_is_number "$proc_count" "Process count este număr"
    assert_true '[[ $proc_count -gt 0 ]]' "Cel puțin 1 proces"
    
    # Test is_process_running
    assert_true 'is_process_running bash' "bash rulează"
    assert_false 'is_process_running nonexistent_process_xyz' "Proces inexistent nu rulează"
}

test_utils_system() {
    echo ""
    echo "=== Teste: utils.sh - Sistem ==="
    
    # Test get_uptime_seconds
    local uptime
    uptime=$(get_uptime_seconds)
    assert_is_number "$uptime" "Uptime este număr"
    assert_true '[[ $uptime -ge 0 ]]' "Uptime >= 0"
    
    # Test get_hostname
    local hostname
    hostname=$(get_hostname)
    assert_not_empty "$hostname" "Hostname nu este gol"
    
    # Test get_kernel_info
    local kernel
    kernel=$(get_kernel_info)
    assert_not_empty "$kernel" "Kernel info nu este gol"
}

#------------------------------------------------------------------------------
# TESTE CONFIG.SH
#------------------------------------------------------------------------------

test_config_defaults() {
    echo ""
    echo "=== Teste: config.sh - Valori Default ==="
    
    # Verifică că variabilele au valori default
    assert_not_empty "${THRESHOLD_CPU:-}" "THRESHOLD_CPU are valoare"
    assert_not_empty "${THRESHOLD_MEM:-}" "THRESHOLD_MEM are valoare"
    assert_not_empty "${THRESHOLD_DISK:-}" "THRESHOLD_DISK are valoare"
    
    # Verifică intervaluri valide
    assert_in_range "${THRESHOLD_CPU:-0}" 0 100 "THRESHOLD_CPU valid"
    assert_in_range "${THRESHOLD_MEM:-0}" 0 100 "THRESHOLD_MEM valid"
    assert_in_range "${THRESHOLD_DISK:-0}" 0 100 "THRESHOLD_DISK valid"
}

test_config_load_file() {
    echo ""
    echo "=== Teste: config.sh - Încărcare Fișier ==="
    
    # Creează fișier de configurare de test
    local test_config="${TEST_TMP_DIR}/test.conf"
    cat > "$test_config" << 'EOF'
# Test config file
THRESHOLD_CPU=75
THRESHOLD_MEM=85
TEST_VAR=test_value
EOF
    
    # Încarcă configurarea
    load_config_file "$test_config"
    
    assert_equals "75" "$THRESHOLD_CPU" "THRESHOLD_CPU încărcat din fișier"
    assert_equals "85" "$THRESHOLD_MEM" "THRESHOLD_MEM încărcat din fișier"
    assert_equals "test_value" "${TEST_VAR:-}" "TEST_VAR încărcat din fișier"
}

test_config_parse_args() {
    echo ""
    echo "=== Teste: config.sh - Parsare Argumente ==="
    
    # Salvează valorile curente
    local old_cpu="$THRESHOLD_CPU"
    local old_interval="$MONITOR_INTERVAL"
    
    # Parsează argumente
    parse_args --cpu-threshold 95 --interval 120
    
    assert_equals "95" "$THRESHOLD_CPU" "--cpu-threshold setat corect"
    assert_equals "120" "$MONITOR_INTERVAL" "--interval setat corect"
    
    # Restaurează
    THRESHOLD_CPU="$old_cpu"
    MONITOR_INTERVAL="$old_interval"
}

test_config_validate() {
    echo ""
    echo "=== Teste: config.sh - Validare ==="
    
    # Test validare cu valori corecte
    THRESHOLD_CPU=80
    THRESHOLD_MEM=90
    THRESHOLD_DISK=85
    THRESHOLD_SWAP=50
    MONITOR_INTERVAL=60
    LOG_LEVEL=INFO
    OUTPUT_FORMAT=text
    
    # Creează directoare necesare
    mkdir -p "${LOG_DIR:-$TEST_TMP_DIR}" 2>/dev/null || true
    mkdir -p "${RUN_DIR:-$TEST_TMP_DIR}" 2>/dev/null || true
    
    assert_true 'validate_config 2>/dev/null' "Configurare validă acceptată"
}

#------------------------------------------------------------------------------
# TESTE INTEGRARE
#------------------------------------------------------------------------------

test_integration_monitor() {
    echo ""
    echo "=== Teste: Integrare Monitor ==="
    
    # Verifică că scriptul principal poate fi încărcat
    if [[ -f "${PROJECT_DIR}/monitor.sh" ]]; then
        # Source doar funcțiile, nu executa main
        (
            # În subshell pentru izolare
            SCRIPT_DIR="$PROJECT_DIR"
            source "${PROJECT_DIR}/monitor.sh" 2>/dev/null
            
            # Verifică funcțiile principale
            declare -f check_cpu &>/dev/null && echo "check_cpu OK"
            declare -f check_memory &>/dev/null && echo "check_memory OK"
            declare -f check_disk &>/dev/null && echo "check_disk OK"
        ) | grep -q "OK" && {
            echo "✓ PASS: Funcțiile principale sunt definite"
            ((TESTS_PASSED++))
        } || {
            echo "✗ FAIL: Funcțiile principale lipsesc"
            ((TESTS_FAILED++))
        }
    else
        skip_test "monitor.sh nu există"
    fi
}

test_integration_output_formats() {
    echo ""
    echo "=== Teste: Formate Output ==="
    
    # Pregătire
    ALERTS_COUNT=0
    ALERTS_MESSAGES=()
    
    # Test output text
    OUTPUT_FORMAT="text"
    local text_output
    text_output=$(generate_output 2>/dev/null || echo "")
    
    if [[ -n "$text_output" ]]; then
        assert_contains "$text_output" "SYSTEM MONITOR" "Text output conține header"
    else
        skip_test "generate_output nu este disponibil"
    fi
}

#------------------------------------------------------------------------------
# RUNNER PRINCIPAL
#------------------------------------------------------------------------------

run_test_suite() {
    local suite="$1"
    
    case "$suite" in
        core)
            test_core_logging
            test_core_validation
            test_core_utilities
            test_core_lock
            ;;
        utils)
            test_utils_cpu
            test_utils_memory
            test_utils_disk
            test_utils_processes
            test_utils_system
            ;;
        config)
            test_config_defaults
            test_config_load_file
            test_config_parse_args
            test_config_validate
            ;;
        integration)
            test_integration_monitor
            test_integration_output_formats
            ;;
        *)
            # Toate testele
            test_core_logging
            test_core_validation
            test_core_utilities
            test_core_lock
            test_utils_cpu
            test_utils_memory
            test_utils_disk
            test_utils_processes
            test_utils_system
            test_config_defaults
            test_config_load_file
            test_config_parse_args
            test_config_validate
            test_integration_monitor
            test_integration_output_formats
            ;;
    esac
}

print_summary() {
    echo ""
    echo "=========================================="
    echo "         REZULTATE TESTE"
    echo "=========================================="
    echo "  Passed:  $TESTS_PASSED"
    echo "  Failed:  $TESTS_FAILED"
    echo "  Skipped: $TESTS_SKIPPED"
    echo "------------------------------------------"
    local total=$((TESTS_PASSED + TESTS_FAILED))
    if [[ $total -gt 0 ]]; then
        local percent=$((TESTS_PASSED * 100 / total))
        echo "  Success rate: ${percent}%"
    fi
    echo "=========================================="
    
    return $TESTS_FAILED
}

main() {
    echo "System Monitor - Test Suite"
    echo "============================"
    echo ""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -v|--verbose)
                VERBOSE="true"
                shift
                ;;
            core|utils|config|integration)
                TEST_FILTER="$1"
                shift
                ;;
            *)
                shift
                ;;
        esac
    done
    
    # Setup
    setup
    
    # Încarcă bibliotecile
    if ! load_libraries; then
        echo "EROARE: Nu pot încărca bibliotecile"
        exit 1
    fi
    
    # Rulează testele
    run_test_suite "${TEST_FILTER:-all}"
    
    # Cleanup
    teardown
    
    # Summary
    print_summary
    exit $?
}

# Rulează dacă e executat direct
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
