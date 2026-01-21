#!/bin/bash
#===============================================================================
# test_helpers.sh - Bibliotecă Funcții Testare
#===============================================================================
# Funcții comune pentru toate suitele de teste CAPSTONE
# Include: assertions, fixtures, mocking, utilities
#
# Utilizare:
#   source test_helpers.sh
#
# Copyright (c) 2024 - Educational Use Only
#===============================================================================

#---------------------------------------
# Constante
#---------------------------------------
readonly TEST_HELPERS_VERSION="1.0.0"

# Culori (dacă nu sunt deja definite)
: "${RED:='\033[0;31m'}"
: "${GREEN:='\033[0;32m'}"
: "${YELLOW:='\033[1;33m'}"
: "${BLUE:='\033[0;34m'}"
: "${CYAN:='\033[0;36m'}"
: "${NC:='\033[0m'}"
: "${BOLD:='\033[1m'}"

# Simboluri
: "${CHECK:=✓}"
: "${CROSS:=✗}"
: "${SKIP_SYMBOL:=⊘}"

#---------------------------------------
# Variabile Testare
#---------------------------------------
declare -g TEST_COUNT=0
declare -g TEST_PASSED=0
declare -g TEST_FAILED=0
declare -g TEST_SKIPPED=0
declare -g CURRENT_TEST=""
declare -g TEST_TMPDIR=""
declare -g TEST_VERBOSE=${TEST_VERBOSE:-false}
declare -g TEST_FILTER=${TEST_FILTER:-""}
declare -ga TEST_FAILURES=()
declare -gA TEST_TIMINGS=()

#---------------------------------------
# Inițializare Test Suite
#---------------------------------------
test_suite_init() {
    local suite_name="${1:-TestSuite}"
    
    TEST_COUNT=0
    TEST_PASSED=0
    TEST_FAILED=0
    TEST_SKIPPED=0
    TEST_FAILURES=()
    
    # Creare director temporar pentru teste
    TEST_TMPDIR=$(mktemp -d -t "test_${suite_name}_XXXXXX")
    
    # Trap pentru cleanup
    trap 'test_suite_cleanup' EXIT
    
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC} ${BOLD}Test Suite: ${suite_name}${NC}"
    echo -e "${CYAN}║${NC} Started: $(date '+%Y-%m-%d %H:%M:%S')"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

test_suite_cleanup() {
    # Curățare director temporar
    if [[ -n "$TEST_TMPDIR" && -d "$TEST_TMPDIR" ]]; then
        rm -rf "$TEST_TMPDIR"
    fi
}

#---------------------------------------
# Rulare Test Individual
#---------------------------------------
run_test() {
    local test_name="$1"
    local test_function="$2"
    
    # Verificare filtru
    if [[ -n "$TEST_FILTER" && ! "$test_name" =~ $TEST_FILTER ]]; then
        return 0
    fi
    
    ((TEST_COUNT++))
    CURRENT_TEST="$test_name"
    
    local start_time=$(date +%s%N)
    local test_output=""
    local exit_code=0
    
    # Execuție test cu capturare output
    if [[ "$TEST_VERBOSE" == "true" ]]; then
        echo -e "${BLUE}Running:${NC} $test_name"
        $test_function
        exit_code=$?
    else
        test_output=$($test_function 2>&1)
        exit_code=$?
    fi
    
    local end_time=$(date +%s%N)
    local duration=$(( (end_time - start_time) / 1000000 ))  # ms
    TEST_TIMINGS["$test_name"]=$duration
    
    # Evaluare rezultat
    if [[ $exit_code -eq 0 ]]; then
        ((TEST_PASSED++))
        echo -e "${GREEN}${CHECK} PASS${NC} $test_name ${CYAN}(${duration}ms)${NC}"
    elif [[ $exit_code -eq 77 ]]; then
        ((TEST_SKIPPED++))
        echo -e "${YELLOW}${SKIP_SYMBOL} SKIP${NC} $test_name"
    else
        ((TEST_FAILED++))
        echo -e "${RED}${CROSS} FAIL${NC} $test_name ${CYAN}(${duration}ms)${NC}"
        TEST_FAILURES+=("$test_name: $test_output")
        
        if [[ "$TEST_VERBOSE" == "true" && -n "$test_output" ]]; then
            echo -e "${RED}   Output: $test_output${NC}"
        fi
    fi
    
    CURRENT_TEST=""
}

#---------------------------------------
# Assertions
#---------------------------------------
assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Values should be equal}"
    
    if [[ "$expected" == "$actual" ]]; then
        return 0
    else
        echo "ASSERTION FAILED: $message"
        echo "  Expected: '$expected'"
        echo "  Actual:   '$actual'"
        return 1
    fi
}

assert_not_equals() {
    local unexpected="$1"
    local actual="$2"
    local message="${3:-Values should not be equal}"
    
    if [[ "$unexpected" != "$actual" ]]; then
        return 0
    else
        echo "ASSERTION FAILED: $message"
        echo "  Unexpected: '$unexpected'"
        echo "  Actual:     '$actual'"
        return 1
    fi
}

assert_true() {
    local condition="$1"
    local message="${2:-Condition should be true}"
    
    if eval "$condition"; then
        return 0
    else
        echo "ASSERTION FAILED: $message"
        echo "  Condition: $condition"
        return 1
    fi
}

assert_false() {
    local condition="$1"
    local message="${2:-Condition should be false}"
    
    if ! eval "$condition"; then
        return 0
    else
        echo "ASSERTION FAILED: $message"
        echo "  Condition: $condition (expected false)"
        return 1
    fi
}

assert_empty() {
    local value="$1"
    local message="${2:-Value should be empty}"
    
    if [[ -z "$value" ]]; then
        return 0
    else
        echo "ASSERTION FAILED: $message"
        echo "  Value: '$value' (expected empty)"
        return 1
    fi
}

assert_not_empty() {
    local value="$1"
    local message="${2:-Value should not be empty}"
    
    if [[ -n "$value" ]]; then
        return 0
    else
        echo "ASSERTION FAILED: $message"
        echo "  Value is empty"
        return 1
    fi
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-String should contain substring}"
    
    if [[ "$haystack" == *"$needle"* ]]; then
        return 0
    else
        echo "ASSERTION FAILED: $message"
        echo "  String:    '$haystack'"
        echo "  Substring: '$needle'"
        return 1
    fi
}

assert_not_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-String should not contain substring}"
    
    if [[ "$haystack" != *"$needle"* ]]; then
        return 0
    else
        echo "ASSERTION FAILED: $message"
        echo "  String:    '$haystack'"
        echo "  Substring: '$needle' (should not be present)"
        return 1
    fi
}

assert_matches() {
    local value="$1"
    local pattern="$2"
    local message="${3:-Value should match pattern}"
    
    if [[ "$value" =~ $pattern ]]; then
        return 0
    else
        echo "ASSERTION FAILED: $message"
        echo "  Value:   '$value'"
        echo "  Pattern: '$pattern'"
        return 1
    fi
}

assert_file_exists() {
    local file="$1"
    local message="${2:-File should exist}"
    
    if [[ -f "$file" ]]; then
        return 0
    else
        echo "ASSERTION FAILED: $message"
        echo "  File: $file"
        return 1
    fi
}

assert_file_not_exists() {
    local file="$1"
    local message="${2:-File should not exist}"
    
    if [[ ! -f "$file" ]]; then
        return 0
    else
        echo "ASSERTION FAILED: $message"
        echo "  File: $file (exists but shouldn't)"
        return 1
    fi
}

assert_dir_exists() {
    local dir="$1"
    local message="${2:-Directory should exist}"
    
    if [[ -d "$dir" ]]; then
        return 0
    else
        echo "ASSERTION FAILED: $message"
        echo "  Directory: $dir"
        return 1
    fi
}

assert_exit_code() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Exit code mismatch}"
    
    if [[ "$expected" -eq "$actual" ]]; then
        return 0
    else
        echo "ASSERTION FAILED: $message"
        echo "  Expected exit code: $expected"
        echo "  Actual exit code:   $actual"
        return 1
    fi
}

assert_greater_than() {
    local value="$1"
    local threshold="$2"
    local message="${3:-Value should be greater than threshold}"
    
    if [[ "$value" -gt "$threshold" ]]; then
        return 0
    else
        echo "ASSERTION FAILED: $message"
        echo "  Value:     $value"
        echo "  Threshold: $threshold"
        return 1
    fi
}

assert_less_than() {
    local value="$1"
    local threshold="$2"
    local message="${3:-Value should be less than threshold}"
    
    if [[ "$value" -lt "$threshold" ]]; then
        return 0
    else
        echo "ASSERTION FAILED: $message"
        echo "  Value:     $value"
        echo "  Threshold: $threshold"
        return 1
    fi
}

assert_file_contains() {
    local file="$1"
    local content="$2"
    local message="${3:-File should contain content}"
    
    if [[ ! -f "$file" ]]; then
        echo "ASSERTION FAILED: $message"
        echo "  File does not exist: $file"
        return 1
    fi
    
    if grep -q "$content" "$file"; then
        return 0
    else
        echo "ASSERTION FAILED: $message"
        echo "  File:    $file"
        echo "  Content: '$content'"
        return 1
    fi
}

assert_command_exists() {
    local cmd="$1"
    local message="${2:-Command should exist}"
    
    if command -v "$cmd" >/dev/null 2>&1; then
        return 0
    else
        echo "ASSERTION FAILED: $message"
        echo "  Command: $cmd"
        return 1
    fi
}

#---------------------------------------
# Skip Test
#---------------------------------------
skip_test() {
    local reason="${1:-No reason given}"
    echo "SKIPPED: $reason"
    return 77
}

skip_if() {
    local condition="$1"
    local reason="${2:-Condition met}"
    
    if eval "$condition"; then
        skip_test "$reason"
    fi
}

skip_unless() {
    local condition="$1"
    local reason="${2:-Condition not met}"
    
    if ! eval "$condition"; then
        skip_test "$reason"
    fi
}

skip_if_no_command() {
    local cmd="$1"
    
    if ! command -v "$cmd" >/dev/null 2>&1; then
        skip_test "Command not available: $cmd"
    fi
}

skip_if_root() {
    if [[ $EUID -eq 0 ]]; then
        skip_test "Test cannot run as root"
    fi
}

skip_unless_root() {
    if [[ $EUID -ne 0 ]]; then
        skip_test "Test requires root privileges"
    fi
}

#---------------------------------------
# Fixtures
#---------------------------------------
create_temp_file() {
    local content="${1:-}"
    local filename="${2:-testfile}"
    
    local temp_file="${TEST_TMPDIR}/${filename}_$$"
    echo -n "$content" > "$temp_file"
    echo "$temp_file"
}

create_temp_dir() {
    local dirname="${1:-testdir}"
    
    local temp_dir="${TEST_TMPDIR}/${dirname}_$$"
    mkdir -p "$temp_dir"
    echo "$temp_dir"
}

create_fixture_tree() {
    local base_dir="${1:-${TEST_TMPDIR}/fixture}"
    
    mkdir -p "$base_dir"/{dir1,dir2,dir3}
    echo "file1 content" > "$base_dir/file1.txt"
    echo "file2 content" > "$base_dir/file2.txt"
    echo "nested content" > "$base_dir/dir1/nested.txt"
    echo "deep content" > "$base_dir/dir2/deep.txt"
    
    echo "$base_dir"
}

cleanup_fixture() {
    local path="$1"
    
    if [[ -n "$path" && -e "$path" ]]; then
        rm -rf "$path"
    fi
}

#---------------------------------------
# Mocking
#---------------------------------------
declare -gA MOCK_COMMANDS=()
declare -gA MOCK_RETURNS=()
declare -gA MOCK_OUTPUTS=()
declare -gA MOCK_CALL_COUNTS=()

mock_command() {
    local cmd="$1"
    local return_code="${2:-0}"
    local output="${3:-}"
    
    MOCK_COMMANDS["$cmd"]=1
    MOCK_RETURNS["$cmd"]=$return_code
    MOCK_OUTPUTS["$cmd"]="$output"
    MOCK_CALL_COUNTS["$cmd"]=0
    
    # Creare funcție mock
    eval "
    $cmd() {
        ((MOCK_CALL_COUNTS[\"$cmd\"]++))
        echo \"${MOCK_OUTPUTS[$cmd]}\"
        return ${MOCK_RETURNS[$cmd]}
    }
    "
}

unmock_command() {
    local cmd="$1"
    
    unset MOCK_COMMANDS["$cmd"]
    unset MOCK_RETURNS["$cmd"]
    unset MOCK_OUTPUTS["$cmd"]
    unset MOCK_CALL_COUNTS["$cmd"]
    unset -f "$cmd" 2>/dev/null || true
}

unmock_all() {
    for cmd in "${!MOCK_COMMANDS[@]}"; do
        unmock_command "$cmd"
    done
}

assert_mock_called() {
    local cmd="$1"
    local times="${2:-}"
    local message="${3:-Mock should have been called}"
    
    local count=${MOCK_CALL_COUNTS["$cmd"]:-0}
    
    if [[ -n "$times" ]]; then
        if [[ $count -eq $times ]]; then
            return 0
        else
            echo "ASSERTION FAILED: $message"
            echo "  Command: $cmd"
            echo "  Expected calls: $times"
            echo "  Actual calls:   $count"
            return 1
        fi
    else
        if [[ $count -gt 0 ]]; then
            return 0
        else
            echo "ASSERTION FAILED: $message"
            echo "  Command: $cmd was never called"
            return 1
        fi
    fi
}

assert_mock_not_called() {
    local cmd="$1"
    local message="${2:-Mock should not have been called}"
    
    local count=${MOCK_CALL_COUNTS["$cmd"]:-0}
    
    if [[ $count -eq 0 ]]; then
        return 0
    else
        echo "ASSERTION FAILED: $message"
        echo "  Command: $cmd"
        echo "  Called: $count times"
        return 1
    fi
}

#---------------------------------------
# Capturare Output
#---------------------------------------
capture_output() {
    local var_stdout="${1:-CAPTURED_STDOUT}"
    local var_stderr="${2:-CAPTURED_STDERR}"
    local var_exit="${3:-CAPTURED_EXIT}"
    
    shift 3
    
    local stdout_file=$(mktemp)
    local stderr_file=$(mktemp)
    
    "$@" > "$stdout_file" 2> "$stderr_file"
    local exit_code=$?
    
    eval "$var_stdout=\"\$(cat \"\$stdout_file\")\""
    eval "$var_stderr=\"\$(cat \"\$stderr_file\")\""
    eval "$var_exit=$exit_code"
    
    rm -f "$stdout_file" "$stderr_file"
    
    return $exit_code
}

#---------------------------------------
# Timeout
#---------------------------------------
run_with_timeout() {
    local timeout="$1"
    shift
    
    timeout "$timeout" "$@"
    local exit_code=$?
    
    if [[ $exit_code -eq 124 ]]; then
        echo "TIMEOUT: Command exceeded ${timeout}s"
        return 124
    fi
    
    return $exit_code
}

#---------------------------------------
# Test Groups
#---------------------------------------
begin_group() {
    local group_name="$1"
    echo ""
    echo -e "${BLUE}┌─── ${BOLD}$group_name${NC} ${BLUE}───┐${NC}"
}

end_group() {
    echo -e "${BLUE}└$(printf '─%.0s' $(seq 1 40))┘${NC}"
}

#---------------------------------------
# Sumar Final
#---------------------------------------
test_suite_summary() {
    local suite_name="${1:-TestSuite}"
    
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC} ${BOLD}Summary: ${suite_name}${NC}"
    echo -e "${CYAN}╠════════════════════════════════════════════════════════════╣${NC}"
    
    local pass_rate=0
    if [[ $TEST_COUNT -gt 0 ]]; then
        pass_rate=$((TEST_PASSED * 100 / TEST_COUNT))
    fi
    
    printf "${CYAN}║${NC}   Total:   %4d                                           ${CYAN}║${NC}\n" "$TEST_COUNT"
    printf "${CYAN}║${NC}   ${GREEN}Passed:  %4d${NC}                                           ${CYAN}║${NC}\n" "$TEST_PASSED"
    printf "${CYAN}║${NC}   ${RED}Failed:  %4d${NC}                                           ${CYAN}║${NC}\n" "$TEST_FAILED"
    printf "${CYAN}║${NC}   ${YELLOW}Skipped: %4d${NC}                                           ${CYAN}║${NC}\n" "$TEST_SKIPPED"
    printf "${CYAN}║${NC}   Rate:    %3d%%                                           ${CYAN}║${NC}\n" "$pass_rate"
    
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    
    # Afișare eșecuri
    if [[ ${#TEST_FAILURES[@]} -gt 0 ]]; then
        echo ""
        echo -e "${RED}${BOLD}Failed Tests:${NC}"
        for failure in "${TEST_FAILURES[@]}"; do
            echo -e "${RED}  ${CROSS} ${failure}${NC}"
        done
    fi
    
    echo ""
    
    # Return code
    [[ $TEST_FAILED -eq 0 ]]
}

#---------------------------------------
# Helpers Specifice SO
#---------------------------------------
# Verificare permisiuni fișier
assert_file_mode() {
    local file="$1"
    local expected_mode="$2"
    local message="${3:-File mode mismatch}"
    
    if [[ ! -e "$file" ]]; then
        echo "ASSERTION FAILED: File does not exist: $file"
        return 1
    fi
    
    local actual_mode=$(stat -c "%a" "$file" 2>/dev/null || stat -f "%Lp" "$file")
    
    if [[ "$actual_mode" == "$expected_mode" ]]; then
        return 0
    else
        echo "ASSERTION FAILED: $message"
        echo "  File:     $file"
        echo "  Expected: $expected_mode"
        echo "  Actual:   $actual_mode"
        return 1
    fi
}

# Verificare owner fișier
assert_file_owner() {
    local file="$1"
    local expected_owner="$2"
    local message="${3:-File owner mismatch}"
    
    if [[ ! -e "$file" ]]; then
        echo "ASSERTION FAILED: File does not exist: $file"
        return 1
    fi
    
    local actual_owner=$(stat -c "%U" "$file" 2>/dev/null || stat -f "%Su" "$file")
    
    if [[ "$actual_owner" == "$expected_owner" ]]; then
        return 0
    else
        echo "ASSERTION FAILED: $message"
        echo "  File:     $file"
        echo "  Expected: $expected_owner"
        echo "  Actual:   $actual_owner"
        return 1
    fi
}

# Verificare proces rulează
assert_process_running() {
    local process="$1"
    local message="${2:-Process should be running}"
    
    if pgrep -f "$process" >/dev/null 2>&1; then
        return 0
    else
        echo "ASSERTION FAILED: $message"
        echo "  Process: $process"
        return 1
    fi
}

# Verificare port deschis
assert_port_open() {
    local host="$1"
    local port="$2"
    local message="${3:-Port should be open}"
    
    if nc -z "$host" "$port" 2>/dev/null; then
        return 0
    else
        echo "ASSERTION FAILED: $message"
        echo "  Host: $host"
        echo "  Port: $port"
        return 1
    fi
}

#---------------------------------------
# Export Funcții
#---------------------------------------
export -f test_suite_init test_suite_cleanup test_suite_summary
export -f run_test begin_group end_group
export -f assert_equals assert_not_equals assert_true assert_false
export -f assert_empty assert_not_empty assert_contains assert_not_contains
export -f assert_matches assert_file_exists assert_file_not_exists
export -f assert_dir_exists assert_exit_code assert_greater_than assert_less_than
export -f assert_file_contains assert_command_exists
export -f assert_file_mode assert_file_owner assert_process_running assert_port_open
export -f skip_test skip_if skip_unless skip_if_no_command skip_if_root skip_unless_root
export -f create_temp_file create_temp_dir create_fixture_tree cleanup_fixture
export -f mock_command unmock_command unmock_all assert_mock_called assert_mock_not_called
export -f capture_output run_with_timeout
