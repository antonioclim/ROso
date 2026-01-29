#!/bin/bash
#===============================================================================
# test_runner.sh - Test Runner pentru Proiecte CAPSTONE
#===============================================================================
# Orchestrează execuția testelor pentru toate cele 3 proiecte:
# - Monitor (System Monitoring)
# - Backup (Backup System)
# - Deployer (Deployment System)
#
# Utilizare:
#   ./test_runner.sh [OPTIONS] [PROJECT...]
#
# Exemple:
#   ./test_runner.sh                    # Rulează toate testele
#   ./test_runner.sh monitor            # Doar teste monitor
#   ./test_runner.sh --verbose backup   # Teste backup cu output detaliat
#   ./test_runner.sh --coverage         # Cu raport coverage
#   ./test_runner.sh --filter core      # Doar teste core din toate proiectele
#
# Copyright (c) 2024 - Educational Use Only
#===============================================================================

set -euo pipefail

#---------------------------------------
# Constante și Configurare
#---------------------------------------
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECTS_DIR="${SCRIPT_DIR}/projects"
readonly HELPERS_FILE="${SCRIPT_DIR}/test_helpers.sh"
readonly RESULTS_DIR="${SCRIPT_DIR}/test_results"
readonly TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Culori ANSI
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m'
readonly BOLD='\033[1m'

# Simboluri
readonly CHECK="✓"
readonly CROSS="✗"
readonly ARROW="→"
readonly BULLET="•"

# Proiecte disponibile
readonly AVAILABLE_PROJECTS=("monitor" "backup" "deployer")

#---------------------------------------
# Variabile Globale
#---------------------------------------
declare -a PROJECTS_TO_TEST=()
VERBOSE=false
COVERAGE=false
FILTER=""
PARALLEL=false
FAIL_FAST=false
OUTPUT_FORMAT="text"  # text, json, junit
QUIET=false

# Statistici globale
declare -A PROJECT_STATS
TOTAL_TESTS=0
TOTAL_PASSED=0
TOTAL_FAILED=0
TOTAL_SKIPPED=0
START_TIME=0
END_TIME=0

#---------------------------------------
# Funcții Utilitare
#---------------------------------------
print_header() {
    local title="$1"
    local width=70
    
    echo ""
    echo -e "${CYAN}$(printf '═%.0s' $(seq 1 $width))${NC}"
    printf "${CYAN}║${WHITE}${BOLD} %-$((width-4))s ${CYAN}║${NC}\n" "$title"
    echo -e "${CYAN}$(printf '═%.0s' $(seq 1 $width))${NC}"
}

print_subheader() {
    local title="$1"
    echo ""
    echo -e "${BLUE}┌─── ${WHITE}${BOLD}$title${NC} ${BLUE}───┐${NC}"
}

print_separator() {
    echo -e "${BLUE}├$(printf '─%.0s' $(seq 1 60))┤${NC}"
}

log_info() {
    [[ "$QUIET" == "true" ]] && return
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[${CHECK}]${NC} $*"
}

log_error() {
    echo -e "${RED}[${CROSS}]${NC} $*" >&2
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $*"
}

log_verbose() {
    [[ "$VERBOSE" == "true" ]] && echo -e "${MAGENTA}[DEBUG]${NC} $*"
}

#---------------------------------------
# Funcții de Ajutor
#---------------------------------------
show_help() {
    cat << EOF
${BOLD}Test Runner - Proiecte CAPSTONE${NC}

${BOLD}UTILIZARE:${NC}
    $(basename "$0") [OPTIONS] [PROJECT...]

${BOLD}PROIECTE DISPONIBILE:${NC}
    monitor     System Monitoring Tool
    backup      Backup System
    deployer    Deployment System
    all         Toate proiectele (implicit)

${BOLD}OPȚIUNI:${NC}
    -h, --help          Afișează acest mesaj
    -v, --verbose       Output detaliat
    -q, --quiet         Output minimal
    -c, --coverage      Generează raport coverage
    -f, --filter PATTERN Rulează doar testele care conțin PATTERN
    -p, --parallel      Rulează testele în paralel
    --fail-fast         Oprește la prima eroare
    --output FORMAT     Format output: text, json, junit
    --list              Listează testele disponibile fără rulare

${BOLD}EXEMPLE:${NC}
    # Rulează toate testele
    $(basename "$0")

    # Rulează teste pentru un singur proiect
    $(basename "$0") monitor

    # Rulează cu output verbose
    $(basename "$0") --verbose backup deployer

    # Rulează doar teste care conțin "core"
    $(basename "$0") --filter core

    # Generează raport coverage
    $(basename "$0") --coverage

    # Output JSON pentru CI/CD
    $(basename "$0") --output json --quiet

${BOLD}EXIT CODES:${NC}
    0   Toate testele au trecut
    1   Unele teste au eșuat
    2   Eroare de configurare
    3   Proiect inexistent

EOF
}

show_version() {
    echo "Test Runner v1.0.0 - Proiecte CAPSTONE"
    echo "Seminar 6 Sisteme de Operare"
}

#---------------------------------------
# Parsare Argumente
#---------------------------------------
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -q|--quiet)
                QUIET=true
                shift
                ;;
            -c|--coverage)
                COVERAGE=true
                shift
                ;;
            -f|--filter)
                FILTER="$2"
                shift 2
                ;;
            -p|--parallel)
                PARALLEL=true
                shift
                ;;
            --fail-fast)
                FAIL_FAST=true
                shift
                ;;
            --output)
                OUTPUT_FORMAT="$2"
                shift 2
                ;;
            --list)
                list_tests
                exit 0
                ;;
            --version)
                show_version
                exit 0
                ;;
            -*)
                log_error "Opțiune necunoscută: $1"
                show_help
                exit 2
                ;;
            *)
                # Argument este nume proiect
                if [[ "$1" == "all" ]]; then
                    PROJECTS_TO_TEST=("${AVAILABLE_PROJECTS[@]}")
                else
                    PROJECTS_TO_TEST+=("$1")
                fi
                shift
                ;;
        esac
    done
    
    # Dacă nu s-au specificat proiecte, rulează toate
    if [[ ${#PROJECTS_TO_TEST[@]} -eq 0 ]]; then
        PROJECTS_TO_TEST=("${AVAILABLE_PROJECTS[@]}")
    fi
}

#---------------------------------------
# Validare
#---------------------------------------
validate_projects() {
    for project in "${PROJECTS_TO_TEST[@]}"; do
        local found=false
        for available in "${AVAILABLE_PROJECTS[@]}"; do
            if [[ "$project" == "$available" ]]; then
                found=true
                break
            fi
        done
        
        if [[ "$found" == "false" ]]; then
            log_error "Proiect necunoscut: $project"
            log_info "Proiecte disponibile: ${AVAILABLE_PROJECTS[*]}"
            exit 3
        fi
        
        local test_file="${PROJECTS_DIR}/${project}/tests/test_${project}.sh"
        if [[ ! -f "$test_file" ]]; then
            log_error "Fișier teste lipsă: $test_file"
            exit 2
        fi
    done
}

validate_environment() {
    # Verificare directoare
    if [[ ! -d "$PROJECTS_DIR" ]]; then
        log_error "Director proiecte lipsă: $PROJECTS_DIR"
        exit 2
    fi
    
    # Creare director rezultate
    mkdir -p "$RESULTS_DIR"
    
    # Verificare helpers
    if [[ ! -f "$HELPERS_FILE" ]]; then
        log_warning "Fișier helpers lipsă, funcționalitate limitată"
    fi
}

#---------------------------------------
# Listare Teste
#---------------------------------------
list_tests() {
    print_header "TESTE DISPONIBILE"
    
    for project in "${AVAILABLE_PROJECTS[@]}"; do
        local test_file="${PROJECTS_DIR}/${project}/tests/test_${project}.sh"
        
        print_subheader "$project"
        
        if [[ -f "$test_file" ]]; then
            # Extrage funcțiile de test
            grep -E "^test_[a-zA-Z_]+\(\)" "$test_file" 2>/dev/null | \
                sed 's/().*$//' | \
                while read -r func; do
                    echo -e "  ${BULLET} ${func}"
                done
        else
            echo -e "  ${YELLOW}(fișier teste lipsă)${NC}"
        fi
    done
    
    echo ""
}

#---------------------------------------
# Execuție Teste
#---------------------------------------
run_project_tests() {
    local project="$1"
    local test_file="${PROJECTS_DIR}/${project}/tests/test_${project}.sh"
    local result_file="${RESULTS_DIR}/${project}_${TIMESTAMP}.log"
    
    print_subheader "Testing: ${project^^}"
    
    local project_start=$(date +%s)
    local passed=0
    local failed=0
    local skipped=0
    local total=0
    
    # Pregătire argumente pentru script test
    local test_args=""
    [[ "$VERBOSE" == "true" ]] && test_args+=" --verbose"
    [[ -n "$FILTER" ]] && test_args+=" --filter $FILTER"
    
    # Rulare teste
    if [[ "$VERBOSE" == "true" ]]; then
        # Cu output
        if bash "$test_file" $test_args 2>&1 | tee "$result_file"; then
            :
        fi
    else
        # Captură output
        if bash "$test_file" $test_args > "$result_file" 2>&1; then
            :
        fi
    fi
    
    local exit_code=${PIPESTATUS[0]:-0}
    
    # Parsare rezultate din output
    if [[ -f "$result_file" ]]; then
        passed=$(grep -c "PASS\|✓" "$result_file" 2>/dev/null || echo 0)
        failed=$(grep -c "FAIL\|✗" "$result_file" 2>/dev/null || echo 0)
        skipped=$(grep -c "SKIP\|⊘" "$result_file" 2>/dev/null || echo 0)
        total=$((passed + failed + skipped))
    fi
    
    local project_end=$(date +%s)
    local duration=$((project_end - project_start))
    
    # Salvare statistici
    PROJECT_STATS["${project}_passed"]=$passed
    PROJECT_STATS["${project}_failed"]=$failed
    PROJECT_STATS["${project}_skipped"]=$skipped
    PROJECT_STATS["${project}_total"]=$total
    PROJECT_STATS["${project}_duration"]=$duration
    
    # Update globale
    ((TOTAL_TESTS += total))
    ((TOTAL_PASSED += passed))
    ((TOTAL_FAILED += failed))
    ((TOTAL_SKIPPED += skipped))
    
    # Afișare rezultat sumar
    if [[ $failed -eq 0 ]]; then
        log_success "${project}: ${passed}/${total} teste trecute (${duration}s)"
    else
        log_error "${project}: ${failed}/${total} teste eșuate (${duration}s)"
    fi
    
    # Fail fast
    if [[ "$FAIL_FAST" == "true" && $failed -gt 0 ]]; then
        log_error "Oprire la prima eroare (--fail-fast)"
        return 1
    fi
    
    return 0
}

run_tests_sequential() {
    for project in "${PROJECTS_TO_TEST[@]}"; do
        run_project_tests "$project" || {
            if [[ "$FAIL_FAST" == "true" ]]; then
                return 1
            fi
        }
    done
}

run_tests_parallel() {
    local pids=()
    
    for project in "${PROJECTS_TO_TEST[@]}"; do
        run_project_tests "$project" &
        pids+=($!)
    done
    
    # Așteptare toate procesele
    local all_success=true
    for pid in "${pids[@]}"; do
        if ! wait $pid; then
            all_success=false
        fi
    done
    
    [[ "$all_success" == "true" ]]
}

#---------------------------------------
# Raport Coverage
#---------------------------------------
generate_coverage_report() {
    print_subheader "Coverage Report"
    
    local coverage_file="${RESULTS_DIR}/coverage_${TIMESTAMP}.txt"
    
    {
        echo "COVERAGE REPORT - $(date)"
        echo "=================================="
        echo ""
        
        for project in "${PROJECTS_TO_TEST[@]}"; do
            local lib_dir="${PROJECTS_DIR}/${project}/lib"
            local test_file="${PROJECTS_DIR}/${project}/tests/test_${project}.sh"
            
            echo "Project: ${project^^}"
            echo "-------------------"
            
            if [[ -d "$lib_dir" ]]; then
                for lib_file in "$lib_dir"/*.sh; do
                    [[ -f "$lib_file" ]] || continue
                    
                    local filename=$(basename "$lib_file")
                    
                    # Numără funcțiile din lib
                    local total_funcs=$(grep -cE "^[a-zA-Z_]+\(\)" "$lib_file" 2>/dev/null || echo 0)
                    
                    # Numără funcțiile testate
                    local tested_funcs=0
                    if [[ -f "$test_file" ]]; then
                        while IFS= read -r func; do
                            func_name=$(echo "$func" | sed 's/().*$//')
                            if grep -q "test_.*${func_name}" "$test_file" 2>/dev/null; then
                                ((tested_funcs++))
                            fi
                        done < <(grep -E "^[a-zA-Z_]+\(\)" "$lib_file" 2>/dev/null)
                    fi
                    
                    local coverage=0
                    [[ $total_funcs -gt 0 ]] && coverage=$((tested_funcs * 100 / total_funcs))
                    
                    printf "  %-20s %3d/%3d functions (%3d%%)\n" \
                        "$filename" "$tested_funcs" "$total_funcs" "$coverage"
                done
            fi
            
            echo ""
        done
    } | tee "$coverage_file"
    
    log_info "Raport salvat: $coverage_file"
}

#---------------------------------------
# Raport Final
#---------------------------------------
print_summary() {
    local duration=$((END_TIME - START_TIME))
    
    print_header "SUMAR TESTE"
    
    # Tabel rezultate pe proiect
    printf "\n${BOLD}%-15s %8s %8s %8s %8s %8s${NC}\n" \
        "Proiect" "Total" "Passed" "Failed" "Skipped" "Durată"
    echo "$(printf '─%.0s' $(seq 1 60))"
    
    for project in "${PROJECTS_TO_TEST[@]}"; do
        local total=${PROJECT_STATS["${project}_total"]:-0}
        local passed=${PROJECT_STATS["${project}_passed"]:-0}
        local failed=${PROJECT_STATS["${project}_failed"]:-0}
        local skipped=${PROJECT_STATS["${project}_skipped"]:-0}
        local dur=${PROJECT_STATS["${project}_duration"]:-0}
        
        local status_color=$GREEN
        [[ $failed -gt 0 ]] && status_color=$RED
        
        printf "${status_color}%-15s %8d %8d %8d %8d %7ds${NC}\n" \
            "$project" "$total" "$passed" "$failed" "$skipped" "$dur"
    done
    
    echo "$(printf '─%.0s' $(seq 1 60))"
    
    # Total
    local total_color=$GREEN
    [[ $TOTAL_FAILED -gt 0 ]] && total_color=$RED
    
    printf "${BOLD}${total_color}%-15s %8d %8d %8d %8d %7ds${NC}\n" \
        "TOTAL" "$TOTAL_TESTS" "$TOTAL_PASSED" "$TOTAL_FAILED" "$TOTAL_SKIPPED" "$duration"
    
    echo ""
    
    # Status final
    if [[ $TOTAL_FAILED -eq 0 ]]; then
        echo -e "${GREEN}${BOLD}══════════════════════════════════════════${NC}"
        echo -e "${GREEN}${BOLD}   ${CHECK} TOATE TESTELE AU TRECUT!          ${NC}"
        echo -e "${GREEN}${BOLD}══════════════════════════════════════════${NC}"
    else
        echo -e "${RED}${BOLD}══════════════════════════════════════════${NC}"
        echo -e "${RED}${BOLD}   ${CROSS} ${TOTAL_FAILED} TESTE AU EȘUAT!              ${NC}"
        echo -e "${RED}${BOLD}══════════════════════════════════════════${NC}"
    fi
    
    echo ""
}

#---------------------------------------
# Output JSON
#---------------------------------------
output_json() {
    local json_file="${RESULTS_DIR}/results_${TIMESTAMP}.json"
    
    {
        echo "{"
        echo "  \"timestamp\": \"$(date -Iseconds)\","
        echo "  \"duration_seconds\": $((END_TIME - START_TIME)),"
        echo "  \"summary\": {"
        echo "    \"total\": $TOTAL_TESTS,"
        echo "    \"passed\": $TOTAL_PASSED,"
        echo "    \"failed\": $TOTAL_FAILED,"
        echo "    \"skipped\": $TOTAL_SKIPPED"
        echo "  },"
        echo "  \"projects\": {"
        
        local first=true
        for project in "${PROJECTS_TO_TEST[@]}"; do
            [[ "$first" == "false" ]] && echo ","
            first=false
            
            echo "    \"$project\": {"
            echo "      \"total\": ${PROJECT_STATS["${project}_total"]:-0},"
            echo "      \"passed\": ${PROJECT_STATS["${project}_passed"]:-0},"
            echo "      \"failed\": ${PROJECT_STATS["${project}_failed"]:-0},"
            echo "      \"skipped\": ${PROJECT_STATS["${project}_skipped"]:-0},"
            echo "      \"duration_seconds\": ${PROJECT_STATS["${project}_duration"]:-0}"
            echo -n "    }"
        done
        
        echo ""
        echo "  },"
        echo "  \"success\": $( [[ $TOTAL_FAILED -eq 0 ]] && echo "true" || echo "false" )"
        echo "}"
    } > "$json_file"
    
    [[ "$QUIET" == "true" ]] && cat "$json_file"
    log_verbose "JSON salvat: $json_file"
}

#---------------------------------------
# Output JUnit XML
#---------------------------------------
output_junit() {
    local junit_file="${RESULTS_DIR}/results_${TIMESTAMP}.xml"
    
    {
        echo '<?xml version="1.0" encoding="UTF-8"?>'
        echo "<testsuites tests=\"$TOTAL_TESTS\" failures=\"$TOTAL_FAILED\" time=\"$((END_TIME - START_TIME))\">"
        
        for project in "${PROJECTS_TO_TEST[@]}"; do
            local total=${PROJECT_STATS["${project}_total"]:-0}
            local failed=${PROJECT_STATS["${project}_failed"]:-0}
            local dur=${PROJECT_STATS["${project}_duration"]:-0}
            
            echo "  <testsuite name=\"$project\" tests=\"$total\" failures=\"$failed\" time=\"$dur\">"
            
            # Parse individual test results from log
            local result_file="${RESULTS_DIR}/${project}_${TIMESTAMP}.log"
            if [[ -f "$result_file" ]]; then
                while IFS= read -r line; do
                    if [[ "$line" =~ (PASS|FAIL|✓|✗).*test_ ]]; then
                        local test_name=$(echo "$line" | grep -oE "test_[a-zA-Z_]+")
                        if [[ "$line" =~ (PASS|✓) ]]; then
                            echo "    <testcase name=\"$test_name\" />"
                        else
                            echo "    <testcase name=\"$test_name\">"
                            echo "      <failure message=\"Test failed\" />"
                            echo "    </testcase>"
                        fi
                    fi
                done < "$result_file"
            fi
            
            echo "  </testsuite>"
        done
        
        echo "</testsuites>"
    } > "$junit_file"
    
    log_verbose "JUnit XML salvat: $junit_file"
}

#---------------------------------------
# Main
#---------------------------------------
main() {
    parse_arguments "$@"
    
    [[ "$QUIET" == "false" ]] && print_header "TEST RUNNER - PROIECTE CAPSTONE"
    
    validate_environment
    validate_projects
    
    log_info "Proiecte de testat: ${PROJECTS_TO_TEST[*]}"
    [[ -n "$FILTER" ]] && log_info "Filtru: $FILTER"
    
    START_TIME=$(date +%s)
    
    # Rulare teste
    if [[ "$PARALLEL" == "true" ]]; then
        log_info "Rulare teste în paralel..."
        run_tests_parallel
    else
        run_tests_sequential
    fi
    
    END_TIME=$(date +%s)
    
    # Raport coverage
    [[ "$COVERAGE" == "true" ]] && generate_coverage_report
    
    # Output în format cerut
    case "$OUTPUT_FORMAT" in
        json)
            output_json
            ;;
        junit)
            output_junit
            ;;
        *)
            print_summary
            ;;
    esac
    
    # Exit code
    [[ $TOTAL_FAILED -eq 0 ]]
}

# Execuție
main "$@"
