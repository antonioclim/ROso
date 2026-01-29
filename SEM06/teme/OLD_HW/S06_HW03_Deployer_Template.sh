#!/usr/bin/env bash
#
# S06_HW03_Deployer_Template.sh - Template pentru tema de deployment
#
# INSTRUCȚIUNI:
# 1. Completează funcțiile marcate cu TODO
# 2. Nu modifica signatura funcțiilor
# 3. Rulează testele cu: ./test_hw03.sh
#
# Autor: [Numele tău]
# Grupa: [Grupa ta]
# Data: [Data]
#
# Material NOU pentru Redistribuirea Curriculară
# Sisteme de Operare | ASE București - CSIE
#

set -euo pipefail

# === CONFIGURARE ===
readonly SCRIPT_NAME=$(basename "$0")
readonly VERSION="1.0"
readonly DEFAULT_DEPLOY_DIR="${DEPLOY_DIR:-/var/www/app}"
readonly DEFAULT_BACKUP_DIR="${BACKUP_DIR:-/var/backups/deploys}"
readonly DEFAULT_RELEASES_KEEP=5

# === LOGGING ===
log() {
    local level="${1:-INFO}"
    shift
    printf '[%s] [%-5s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$level" "$*"
}

die() {
    log "FATAL" "$*" >&2
    exit 1
}

# === USAGE ===
usage() {
    cat << EOF
Utilizare: $SCRIPT_NAME <command> [options]

Comenzi:
    deploy      Deploiește o nouă versiune
    rollback    Revine la versiunea anterioară
    list        Listează versiunile disponibile
    status      Afișează statusul curent
    cleanup     Șterge versiunile vechi

Opțiuni deploy:
    -s, --source DIR     Directorul sursă (obligatoriu)
    -d, --dest DIR       Directorul destinație (default: $DEFAULT_DEPLOY_DIR)
    -t, --tag TAG        Tag/versiune pentru release
    --pre-hook SCRIPT    Script de executat înainte de deploy
    --post-hook SCRIPT   Script de executat după deploy
    --no-backup          Nu face backup înainte de deploy

Opțiuni rollback:
    -r, --release ID     ID-ul release-ului pentru rollback
    -n, --steps N        Numărul de versiuni pentru rollback (default: 1)

Opțiuni cleanup:
    -k, --keep N         Numărul de versiuni de păstrat (default: $DEFAULT_RELEASES_KEEP)

Exemple:
    $SCRIPT_NAME deploy -s ./dist -t v1.2.3
    $SCRIPT_NAME rollback -n 1
    $SCRIPT_NAME list
    $SCRIPT_NAME cleanup -k 3

Exit codes:
    0 - Succes
    1 - Eroare generală
    2 - Eroare validare argumente
    3 - Eroare deploy
    4 - Eroare rollback

EOF
    exit "${1:-0}"
}

# === HELPER FUNCTIONS ===

# Generează un ID unic pentru release
# TODO: Implementează această funcție
# Hint: Folosește timestamp + tag
generate_release_id() {
    local tag="${1:-}"
    # TODO: Returnează un ID unic, ex: 20250127_153045_v1.2.3
    echo "TODO"
}

# Verifică dacă directorul sursă este valid
# TODO: Implementează această funcție
validate_source() {
    local source="$1"
    # TODO: Verifică că sursa există și conține fișiere
    return 0
}

# Creează structura de directoare pentru releases
# TODO: Implementează această funcție
setup_release_structure() {
    local deploy_dir="$1"
    # TODO: Creează:
    # - $deploy_dir/releases/
    # - $deploy_dir/shared/
    # - Symlink: $deploy_dir/current -> releases/latest
    return 0
}

# === CORE FUNCTIONS ===

# Deploy function
# TODO: Implementează logica principală de deploy
do_deploy() {
    local source=""
    local dest="$DEFAULT_DEPLOY_DIR"
    local tag=""
    local pre_hook=""
    local post_hook=""
    local no_backup=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -s|--source) source="$2"; shift 2 ;;
            -d|--dest) dest="$2"; shift 2 ;;
            -t|--tag) tag="$2"; shift 2 ;;
            --pre-hook) pre_hook="$2"; shift 2 ;;
            --post-hook) post_hook="$2"; shift 2 ;;
            --no-backup) no_backup=true; shift ;;
            *) die "Unknown option: $1" ;;
        esac
    done

    # Validate
    [[ -n "$source" ]] || die "Source directory required (-s)"
    validate_source "$source" || die "Invalid source: $source"

    local release_id
    release_id=$(generate_release_id "$tag")
    local release_dir="$dest/releases/$release_id"

    log "INFO" "Starting deploy: $release_id"
    log "INFO" "Source: $source"
    log "INFO" "Destination: $release_dir"

    # TODO: Implementează pașii de deploy:
    # 1. Setup release structure (dacă nu există)
    # 2. Backup curent (dacă nu --no-backup)
    # 3. Execută pre-hook (dacă există)
    # 4. Copiază fișierele în release_dir
    # 5. Actualizează symlink-ul "current"
    # 6. Execută post-hook (dacă există)
    # 7. Health check

    log "INFO" "Deploy completed: $release_id"
}

# Rollback function
# TODO: Implementează logica de rollback
do_rollback() {
    local release=""
    local steps=1

    while [[ $# -gt 0 ]]; do
        case $1 in
            -r|--release) release="$2"; shift 2 ;;
            -n|--steps) steps="$2"; shift 2 ;;
            *) die "Unknown option: $1" ;;
        esac
    done

    log "INFO" "Starting rollback..."

    # TODO: Implementează rollback:
    # 1. Găsește release-ul anterior
    # 2. Verifică că există
    # 3. Actualizează symlink-ul "current"
    # 4. Optional: Health check

    log "INFO" "Rollback completed"
}

# List releases
# TODO: Implementează listarea versiunilor
do_list() {
    local deploy_dir="${1:-$DEFAULT_DEPLOY_DIR}"

    log "INFO" "Available releases in $deploy_dir:"

    # TODO: Listează releases în ordine cronologică
    # Marchează release-ul curent cu [CURRENT]

    echo "TODO: List releases"
}

# Show status
# TODO: Implementează afișarea statusului
do_status() {
    local deploy_dir="${1:-$DEFAULT_DEPLOY_DIR}"

    log "INFO" "Deployment status:"

    # TODO: Afișează:
    # - Release curent
    # - Data ultimului deploy
    # - Numărul de releases disponibile
    # - Spațiu ocupat

    echo "TODO: Show status"
}

# Cleanup old releases
# TODO: Implementează curățarea versiunilor vechi
do_cleanup() {
    local keep=$DEFAULT_RELEASES_KEEP
    local deploy_dir="$DEFAULT_DEPLOY_DIR"

    while [[ $# -gt 0 ]]; do
        case $1 in
            -k|--keep) keep="$2"; shift 2 ;;
            -d|--dest) deploy_dir="$2"; shift 2 ;;
            *) die "Unknown option: $1" ;;
        esac
    done

    log "INFO" "Cleaning up, keeping $keep releases..."

    # TODO: Implementează cleanup:
    # 1. Găsește toate release-urile
    # 2. Sortează după dată
    # 3. Păstrează ultimele $keep
    # 4. Șterge restul (nu șterge "current"!)

    log "INFO" "Cleanup completed"
}

# === HEALTH CHECK ===

# Verifică că aplicația funcționează după deploy
# TODO: Implementează health check
health_check() {
    local url="${1:-http://localhost:8080/health}"
    local timeout="${2:-30}"
    local retries="${3:-5}"

    log "INFO" "Running health check: $url"

    # TODO: Implementează:
    # - Verifică că URL-ul răspunde cu 200
    # - Retry cu backoff exponențial
    # - Return 0 pentru succes, 1 pentru eșec

    return 0
}

# === HOOKS ===

# Execută un hook script
run_hook() {
    local hook="$1"
    local stage="$2"

    [[ -n "$hook" ]] || return 0

    if [[ -x "$hook" ]]; then
        log "INFO" "Running $stage hook: $hook"
        if ! "$hook"; then
            log "ERROR" "$stage hook failed"
            return 1
        fi
    else
        log "WARN" "Hook not executable: $hook"
        return 1
    fi
}

# === MAIN ===
main() {
    [[ $# -ge 1 ]] || usage 1

    local command="$1"
    shift

    case "$command" in
        deploy)   do_deploy "$@" ;;
        rollback) do_rollback "$@" ;;
        list)     do_list "$@" ;;
        status)   do_status "$@" ;;
        cleanup)  do_cleanup "$@" ;;
        -h|--help) usage ;;
        -v|--version) echo "$SCRIPT_NAME version $VERSION"; exit 0 ;;
        *) die "Unknown command: $command" ;;
    esac
}

main "$@"

# *By Revolvix for OPERATING SYSTEMS class | restricted licence 2017-2030*
