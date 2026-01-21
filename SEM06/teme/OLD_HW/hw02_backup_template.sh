#!/usr/bin/env bash
#
# hw02_backup_template.sh - Template pentru tema de backup
#
# INSTRUCȚIUNI:
# 1. Completează funcțiile marcate cu TODO
# 2. Nu modifica signatura funcțiilor
# 3. Rulează testele cu: ./test_hw02.sh
#
# Autor: [Numele tău]
# Grupa: [Grupa ta]
# Data: [Data]
#

set -euo pipefail

# === CONFIGURARE ===
readonly SCRIPT_NAME=$(basename "$0")
readonly VERSION="1.0"
readonly DEFAULT_BACKUP_DIR="${BACKUP_DIR:-/tmp/backups}"
readonly DEFAULT_RETENTION=7

# === FUNCȚII HELPER ===
log() {
    local level="${1:-INFO}"
    shift
    printf '[%s] [%-5s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$level" "$*"
}

die() {
    log "FATAL" "$*" >&2
    exit 1
}

usage() {
    cat << EOF
Utilizare: $SCRIPT_NAME <command> [options]

Comenzi:
    create      Crează un backup nou
    list        Listează backup-urile existente
    restore     Restaurează un backup
    rotate      Șterge backup-uri vechi

Opțiuni create:
    -s, --source DIR    Directorul sursă (obligatoriu)
    -d, --dest DIR      Directorul destinație (default: $DEFAULT_BACKUP_DIR)
    -t, --type TYPE     Tip: full|incremental (default: full)
    -c, --compress ALG  Compresie: gz|bz2|xz (default: gz)

Opțiuni restore:
    -b, --backup ID     ID-ul backup-ului
    -d, --dest DIR      Locația de restaurare

Opțiuni rotate:
    -r, --retention N   Zile de păstrare (default: $DEFAULT_RETENTION)

Exemple:
    $SCRIPT_NAME create -s /var/www -t full
    $SCRIPT_NAME list
    $SCRIPT_NAME restore -b backup_20240115_143022 -d /tmp/restore
    $SCRIPT_NAME rotate -r 7
EOF
    exit 0
}

# === TODO: IMPLEMENTEAZĂ ACESTE FUNCȚII ===

# Funcție: create_backup
# Descriere: Crează un arhivă backup din sursa specificată
# Input: 
#   $1 = source_dir (directorul sursă)
#   $2 = dest_dir (directorul destinație)
#   $3 = type (full sau incremental)
#   $4 = compress (gz, bz2, sau xz)
# Output: Calea către fișierul backup creat
# Return: 0 dacă succes, 1 dacă eroare
create_backup() {
    local source_dir="$1"
    local dest_dir="$2"
    local type="$3"
    local compress="$4"
    
    # TODO: Implementează
    # Pași sugerați:
    # 1. Validează că source_dir există
    # 2. Creează dest_dir dacă nu există
    # 3. Generează nume fișier: backup_YYYYMMDD_HHMMSS.tar.{gz|bz2|xz}
    # 4. Selectează opțiunea tar pentru compresie (z, j, J)
    # 5. Dacă type=incremental, folosește --newer-mtime cu data ultimului backup
    # 6. Execută tar pentru a crea arhiva
    # 7. Verifică că arhiva a fost creată
    # 8. Afișează dimensiunea și returnează calea
    
    log "INFO" "create_backup: NOT IMPLEMENTED"
    return 1
}

# Funcție: list_backups
# Descriere: Listează toate backup-urile din directorul specificat
# Input: $1 = backup_dir
# Output: Lista backup-urilor (nume, dată, dimensiune)
list_backups() {
    local backup_dir="$1"
    
    # TODO: Implementează
    # Pași sugerați:
    # 1. Verifică că backup_dir există
    # 2. Găsește toate fișierele backup_*.tar.*
    # 3. Pentru fiecare, afișează: nume, data modificării, dimensiune
    # 4. Folosește format tabelar
    
    log "INFO" "list_backups: NOT IMPLEMENTED"
}

# Funcție: restore_backup
# Descriere: Restaurează un backup în locația specificată
# Input:
#   $1 = backup_file (calea către fișierul backup)
#   $2 = dest_dir (directorul de restaurare)
# Return: 0 dacă succes, 1 dacă eroare
restore_backup() {
    local backup_file="$1"
    local dest_dir="$2"
    
    # TODO: Implementează
    # Pași sugerați:
    # 1. Verifică că backup_file există
    # 2. Creează dest_dir dacă nu există
    # 3. Detectează tipul de compresie din extensie
    # 4. Extrage arhiva în dest_dir
    # 5. Verifică integritatea (optional: checksum)
    
    log "INFO" "restore_backup: NOT IMPLEMENTED"
    return 1
}

# Funcție: rotate_backups
# Descriere: Șterge backup-urile mai vechi de N zile
# Input:
#   $1 = backup_dir
#   $2 = retention_days
# Output: Numărul de fișiere șterse
rotate_backups() {
    local backup_dir="$1"
    local retention_days="$2"
    
    # TODO: Implementează
    # Pași sugerați:
    # 1. Găsește fișierele backup_*.tar.* mai vechi de retention_days
    # 2. Afișează ce va fi șters
    # 3. Șterge fișierele
    # 4. Returnează numărul de fișiere șterse
    
    log "INFO" "rotate_backups: NOT IMPLEMENTED"
    echo "0"
}

# Funcție: calculate_checksum
# Descriere: Calculează și salvează checksum-ul unui fișier
# Input: $1 = file_path
# Output: Checksum MD5 sau SHA256
calculate_checksum() {
    local file="$1"
    
    # TODO: Implementează
    # Folosește md5sum sau sha256sum
    
    echo "NOT_IMPLEMENTED"
}

# Funcție: verify_checksum
# Descriere: Verifică integritatea unui backup
# Input: $1 = backup_file
# Return: 0 dacă valid, 1 dacă invalid
verify_checksum() {
    local backup_file="$1"
    
    # TODO: Implementează
    # Compară checksum-ul curent cu cel salvat
    
    return 1
}

# === MAIN ===
main() {
    [[ $# -lt 1 ]] && usage
    
    local command="$1"
    shift
    
    # Defaults
    local source_dir=""
    local dest_dir="$DEFAULT_BACKUP_DIR"
    local backup_type="full"
    local compress="gz"
    local backup_id=""
    local retention="$DEFAULT_RETENTION"
    
    # Parse subcommand options
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -s|--source) source_dir="$2"; shift 2 ;;
            -d|--dest) dest_dir="$2"; shift 2 ;;
            -t|--type) backup_type="$2"; shift 2 ;;
            -c|--compress) compress="$2"; shift 2 ;;
            -b|--backup) backup_id="$2"; shift 2 ;;
            -r|--retention) retention="$2"; shift 2 ;;
            -h|--help) usage ;;
            *) die "Opțiune necunoscută: $1" ;;
        esac
    done
    
    case "$command" in
        create)
            [[ -z "$source_dir" ]] && die "Specifică directorul sursă cu -s"
            create_backup "$source_dir" "$dest_dir" "$backup_type" "$compress"
            ;;
        list)
            list_backups "$dest_dir"
            ;;
        restore)
            [[ -z "$backup_id" ]] && die "Specifică backup-ul cu -b"
            local backup_file="$DEFAULT_BACKUP_DIR/$backup_id"
            [[ ! -f "$backup_file" ]] && backup_file=$(find "$DEFAULT_BACKUP_DIR" -name "${backup_id}*" | head -1)
            restore_backup "$backup_file" "$dest_dir"
            ;;
        rotate)
            rotate_backups "$dest_dir" "$retention"
            ;;
        *)
            die "Comandă necunoscută: $command"
            ;;
    esac
}

main "$@"
