#!/usr/bin/env bash
#
# mini_container.sh - Container minimal folosind doar primitive Linux
# Sisteme de Operare | ASE București - CSIE | 2025-2026
#
# Concepte ilustrate:
# - Namespace-uri Linux (PID, MNT, UTS, IPC, NET)
# - pivot_root pentru schimbarea root filesystem
# - Montarea sistemelor de fișiere speciale (/proc, /sys)
# - Mecanismul fundamental al containerizării
#
# ATENȚIE: Acest script necesită privilegii root și modifică
# sistemul de fișiere. Rulați doar pe sisteme de test!
#
# Utilizare:
#   sudo ./mini_container.sh prepare    # Pregătește rootfs
#   sudo ./mini_container.sh run        # Lansează containerul
#   sudo ./mini_container.sh shell      # Shell interactiv în container
#   sudo ./mini_container.sh clean      # Curăță resursele
#

set -euo pipefail

# Configurare
CONTAINER_NAME="mini-container"
ROOTFS_BASE="/var/lib/mini-containers"
ROOTFS="${ROOTFS_BASE}/${CONTAINER_NAME}"
HOSTNAME="mini-container"

# Culori
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

#######################################
# Funcții utilitate
#######################################

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_ok() {
    echo -e "${GREEN}[OK]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_err() {
    echo -e "${RED}[ERR]${NC} $1"
}

log_step() {
    echo -e "${CYAN}[STEP]${NC} $1"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_err "Acest script necesită privilegii root"
        echo "Rulați: sudo $0 $*"
        exit 1
    fi
}

check_commands() {
    local missing=()
    for cmd in unshare mount chroot; do
        if ! command -v "$cmd" &> /dev/null; then
            missing+=("$cmd")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        log_err "Comenzi lipsă: ${missing[*]}"
        exit 1
    fi
}

#######################################
# Pregătire Root Filesystem
#######################################

prepare_rootfs() {
    log_info "Pregătire root filesystem pentru container..."
    
    # Creare structură directoare
    log_step "Creare structură directoare..."
    mkdir -p "${ROOTFS}"/{bin,sbin,lib,lib64,usr/bin,usr/lib,usr/lib64}
    mkdir -p "${ROOTFS}"/{proc,sys,dev,tmp,root,etc,var/run}
    mkdir -p "${ROOTFS}"/dev/{pts,shm}
    
    # Copiere binare esențiale
    log_step "Copiere binare esențiale..."
    local binaries=(
        /bin/bash
        /bin/sh
        /bin/ls
        /bin/cat
        /bin/echo
        /bin/pwd
        /bin/ps
        /bin/mount
        /bin/umount
        /bin/hostname
        /usr/bin/id
        /usr/bin/whoami
        /usr/bin/env
        /usr/bin/clear
        /usr/bin/tty
    )
    
    for bin in "${binaries[@]}"; do
        if [[ -f "$bin" ]]; then
            cp "$bin" "${ROOTFS}${bin}" 2>/dev/null || true
        fi
    done
    
    # Copiere biblioteci partajate necesare
    log_step "Copiere biblioteci partajate..."
    for bin in "${binaries[@]}"; do
        if [[ -f "$bin" ]]; then
            # Extragere dependențe cu ldd
            ldd "$bin" 2>/dev/null | grep -oE '/[^ ]+' | while read -r lib; do
                if [[ -f "$lib" ]]; then
                    local libdir
                    libdir=$(dirname "${ROOTFS}${lib}")
                    mkdir -p "$libdir"
                    cp "$lib" "${ROOTFS}${lib}" 2>/dev/null || true
                fi
            done
        fi
    done
    
    # Copiere loader dinamic explicit (necesar pentru execuție)
    for loader in /lib64/ld-linux-x86-64.so.* /lib/ld-linux.so.*; do
        if [[ -f "$loader" ]]; then
            cp "$loader" "${ROOTFS}${loader}" 2>/dev/null || true
        fi
    done
    
    # Creare fișiere de configurare minimale
    log_step "Creare configurare minimală..."
    
    # /etc/passwd
    cat > "${ROOTFS}/etc/passwd" << 'EOF'
root:x:0:0:root:/root:/bin/bash
nobody:x:65534:65534:nobody:/nonexistent:/usr/sbin/nologin
EOF

    # /etc/group
    cat > "${ROOTFS}/etc/group" << 'EOF'
root:x:0:
nogroup:x:65534:
EOF

    # /etc/hosts
    cat > "${ROOTFS}/etc/hosts" << EOF
127.0.0.1   localhost
127.0.0.1   ${HOSTNAME}
EOF

    # /etc/hostname
    echo "${HOSTNAME}" > "${ROOTFS}/etc/hostname"
    
    # /etc/resolv.conf (copiere de pe gazdă pentru DNS)
    cp /etc/resolv.conf "${ROOTFS}/etc/resolv.conf" 2>/dev/null || true
    
    # Script de inițializare în container
    cat > "${ROOTFS}/init.sh" << 'EOF'
#!/bin/bash
# Script de inițializare container

# Montare sisteme de fișiere speciale
mount -t proc proc /proc 2>/dev/null || true
mount -t sysfs sysfs /sys 2>/dev/null || true
mount -t devpts devpts /dev/pts 2>/dev/null || true
mount -t tmpfs tmpfs /tmp 2>/dev/null || true

# Setare hostname
hostname mini-container 2>/dev/null || true

# Afișare informații
echo "════════════════════════════════════════════════════════"
echo "  MINI CONTAINER - Demonstrație Izolare Linux"
echo "════════════════════════════════════════════════════════"
echo ""
echo "  Hostname: $(hostname)"
echo "  PID curent: $$"
echo "  User: $(whoami)"
echo ""
echo "  Verificări rapide:"
echo "  • ps aux    - listare procese (doar cele din container)"
echo "  • ls /      - root filesystem izolat"
echo "  • cat /proc/1/cgroup - verificare cgroups"
echo ""
echo "  Tastați 'exit' pentru a ieși din container."
echo "════════════════════════════════════════════════════════"
echo ""

# Lansare shell interactiv
exec /bin/bash
EOF
    chmod +x "${ROOTFS}/init.sh"
    
    log_ok "Root filesystem pregătit în: ${ROOTFS}"
    log_info "Dimensiune: $(du -sh "${ROOTFS}" | cut -f1)"
}

#######################################
# Lansare Container
#######################################

run_container() {
    if [[ ! -d "${ROOTFS}" ]]; then
        log_err "Root filesystem nu există. Rulați mai întâi: $0 prepare"
        exit 1
    fi
    
    log_info "Lansare container cu namespace-uri izolate..."
    
    echo -e "\n${BOLD}Namespace-uri create:${NC}"
    echo "  • PID   - arbore procese izolat"
    echo "  • MNT   - puncte de montare izolate"
    echo "  • UTS   - hostname izolat"
    echo "  • IPC   - IPC izolat"
    echo "  • NET   - (dezactivat pentru simplitate)"
    echo ""
    
    # unshare creează namespace-uri noi și lansează procesul
    # --pid: namespace PID nou (PID 1 în container)
    # --mount: namespace mount nou
    # --uts: namespace UTS (hostname)
    # --ipc: namespace IPC
    # --fork: necesită fork pentru PID namespace
    # --mount-proc: montează /proc automat
    
    unshare \
        --pid \
        --mount \
        --uts \
        --ipc \
        --fork \
        --mount-proc="${ROOTFS}/proc" \
        chroot "${ROOTFS}" /init.sh
    
    log_info "Container oprit."
}

#######################################
# Lansare cu pivot_root (mai avansat)
#######################################

run_container_advanced() {
    if [[ ! -d "${ROOTFS}" ]]; then
        log_err "Root filesystem nu există. Rulați mai întâi: $0 prepare"
        exit 1
    fi
    
    log_info "Lansare container cu pivot_root (metodă avansată)..."
    
    unshare \
        --pid \
        --mount \
        --uts \
        --ipc \
        --fork \
        -- /bin/bash -c "
            # Creare bind mount pentru rootfs
            mount --bind ${ROOTFS} ${ROOTFS}
            
            # Intrare în directorul rootfs
            cd ${ROOTFS}
            
            # Creare director pentru vechiul root
            mkdir -p old_root
            
            # pivot_root schimbă root filesystem
            # Noul root devine directorul curent
            # Vechiul root este mutat în old_root
            pivot_root . old_root
            
            # Montare sisteme de fișiere speciale
            mount -t proc proc /proc
            mount -t sysfs sysfs /sys
            mount -t devpts devpts /dev/pts
            
            # Demontare vechiul root
            umount -l /old_root 2>/dev/null || true
            rmdir /old_root 2>/dev/null || true
            
            # Setare hostname
            hostname ${HOSTNAME}
            
            # Lansare shell
            exec /bin/bash
        "
}

#######################################
# Curățare
#######################################

cleanup() {
    log_info "Curățare resurse container..."
    
    # Demontare orice mount points rămase
    for mp in "${ROOTFS}"/proc "${ROOTFS}"/sys "${ROOTFS}"/dev/pts "${ROOTFS}"/tmp; do
        umount "$mp" 2>/dev/null || true
    done
    
    # Ștergere rootfs
    if [[ -d "${ROOTFS}" ]]; then
        rm -rf "${ROOTFS}"
        log_ok "Root filesystem șters"
    fi
    
    # Ștergere director bază dacă e gol
    rmdir "${ROOTFS_BASE}" 2>/dev/null || true
    
    log_ok "Curățare completă"
}

#######################################
# Afișare informații
#######################################

show_info() {
    echo -e "${BOLD}════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}  MINI CONTAINER - Script Educațional${NC}"
    echo -e "${BOLD}════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "Acest script demonstrează mecanismele fundamentale ale"
    echo "containerizării Linux: namespace-uri, chroot/pivot_root,"
    echo "și izolarea proceselor."
    echo ""
    echo -e "${CYAN}Concepte demonstrate:${NC}"
    echo "  • PID namespace - procese izolate (PID 1 în container)"
    echo "  • Mount namespace - filesystem izolat"
    echo "  • UTS namespace - hostname propriu"
    echo "  • IPC namespace - semafoare/cozi izolate"
    echo ""
    echo -e "${CYAN}Ce LIPSEȘTE față de Docker:${NC}"
    echo "  • Network namespace (pentru simplitate)"
    echo "  • User namespace (rulăm ca root)"
    echo "  • cgroups (limite resurse)"
    echo "  • Seccomp (filtrare syscalls)"
    echo "  • Image layers (overlay filesystem)"
    echo ""
    echo -e "${CYAN}Locație rootfs:${NC} ${ROOTFS}"
    echo ""
}

#######################################
# Help
#######################################

show_help() {
    cat << EOF
${BOLD}mini_container.sh${NC} - Container minimal pentru demonstrații

${BOLD}UTILIZARE:${NC}
    sudo $0 <comandă>

${BOLD}COMENZI:${NC}
    prepare     Pregătește root filesystem-ul containerului
    run         Lansează containerul (metodă simplă cu chroot)
    advanced    Lansează cu pivot_root (metodă avansată)
    shell       Alias pentru run
    info        Afișează informații despre script
    clean       Curăță resursele (șterge rootfs)
    help        Afișează acest mesaj

${BOLD}EXEMPLE:${NC}
    # Flux complet
    sudo $0 prepare    # Pregătire (o singură dată)
    sudo $0 run        # Lansare container
    sudo $0 clean      # Curățare

${BOLD}ÎN CONTAINER:${NC}
    ps aux             # Veți vedea doar procesele din container
    hostname           # Hostname izolat
    cat /etc/hosts     # Fișier hosts propriu
    ls /proc           # /proc din perspectiva containerului
    exit               # Ieșire din container

${BOLD}NOTE:${NC}
    • Scriptul necesită privilegii root
    • Rulați doar pe sisteme de test
    • Network-ul NU este izolat (pentru simplitate)

EOF
}

#######################################
# Main
#######################################

main() {
    check_root
    check_commands
    
    local cmd="${1:-help}"
    
    case "$cmd" in
        prepare)
            prepare_rootfs
            ;;
        run|shell)
            run_container
            ;;
        advanced)
            run_container_advanced
            ;;
        info)
            show_info
            ;;
        clean)
            cleanup
            ;;
        help|-h|--help)
            show_help
            ;;
        *)
            log_err "Comandă necunoscută: $cmd"
            show_help
            exit 1
            ;;
    esac
}

main "$@"