#!/bin/bash
#===============================================================================
#
#          FILE:  record_homework.sh
#
#         USAGE:  ./record_homework.sh
#
#   DESCRIPTION:  Script pentru înregistrarea temelor studenților folosind asciinema
#                 Include: validare date, înregistrare sesiune, semnătură criptografică,
#                 încărcare automată pe server
#
#        AUTHOR:  Operating Systems 2023-2027 - Revolvix/github.com
#       VERSION:  1.1.1
#       CREATED:  2025
#
#===============================================================================

#===============================================================================
# MOD STRICT
# -e: Ieși imediat dacă o comandă returnează un status diferit de zero
# -u: Tratează variabilele nedefinite ca erori
# -o pipefail: Valoarea de retur a unui pipeline este ultima comandă care iese cu non-zero
# IFS: Separator intern de câmpuri - previne problemele de separare a cuvintelor
#===============================================================================
set -euo pipefail
IFS=$'\n\t'

#===============================================================================
# CHEIE PUBLICĂ RSA - NU MODIFICA!
# Folosită pentru semnătura criptografică a temelor
#===============================================================================
readonly PUBLIC_KEY="-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCieNySGxV0PZUBbAjbwksHyUUB
soa9fbLVI9uK7viOAVi0c5ZHjfnwU/LhRxLT4qbBNSlUBoXqiiVAg+Z+NWY2B/eY
POoTxuSLgkS0NfJjd55t2N4gzJHydma6gfwLg3kpDEJoSIlTfI83aFHuyzPxgzbj
HAsViFvWuv8rlbxvHwIDAQAB
-----END PUBLIC KEY-----"

#===============================================================================
# CONFIGURARE SERVER
#===============================================================================
readonly SCP_SERVER="sop.ase.ro"
readonly SCP_PORT="1001"
readonly SCP_PASSWORD="stud"
readonly SCP_BASE_PATH="/home/HOMEWORKS"
readonly MAX_RETRIES=3

#===============================================================================
# CULORI DE AFIȘARE
#===============================================================================
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m' # Fără culoare

#===============================================================================
# FUNCȚII UTILITARE
#===============================================================================

print_header() {
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════════════════════╗"
    echo "║                                                                   ║"
    echo "║          📹 HOMEWORK RECORDING SYSTEM - ASCIINEMA                 ║"
    echo "║                Operating Systems 2023-2027                        ║"
    echo "║                                                                   ║"
    echo "╚═══════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

#===============================================================================
# VERIFICĂ ȘI INSTALEAZĂ DEPENDENȚELE
#===============================================================================

check_and_install_prerequisites() {
    echo -e "${BOLD}📦 Verificare și instalare dependențe...${NC}"
    echo ""
    
    local -a packages_to_install=()
    
    # Verifică asciinema
    if ! command -v asciinema &> /dev/null; then
        print_warning "asciinema nu este instalat"
        packages_to_install+=("asciinema")
    else
        print_success "asciinema este instalat"
    fi
    
    # Verifică openssl
    if ! command -v openssl &> /dev/null; then
        print_warning "openssl nu este instalat"
        packages_to_install+=("openssl")
    else
        print_success "openssl este instalat"
    fi
    
    # Verifică sshpass
    if ! command -v sshpass &> /dev/null; then
        print_warning "sshpass nu este instalat"
        packages_to_install+=("sshpass")
    else
        print_success "sshpass este instalat"
    fi
    
    # Instalează pachetele lipsă
    if [[ ${#packages_to_install[@]} -gt 0 ]]; then
        echo ""
        print_info "Se instalează pachetele lipsă: ${packages_to_install[*]}"
        echo ""
        
        # Actualizare și instalare
        sudo apt update -qq
        if sudo apt install -y "${packages_to_install[@]}"; then
            echo ""
            print_success "Toate pachetele au fost instalate cu succes!"
        else
            print_error "Eroare la instalarea pachetelor. Verifică conexiunea la internet."
            exit 1
        fi
    fi
    
    echo ""
}

#===============================================================================
# FUNCȚII DE VALIDARE DATE INTRODUSE
#===============================================================================

# Validează numele de familie (doar litere și cratimă, convertit la MAJUSCULE)
validate_surname() {
    local input="$1"
    
    # Verifică dacă conține doar litere și cratimă
    if [[ ! "$input" =~ ^[a-zA-Z-]+$ ]]; then
        return 1
    fi
    
    # Verifică că nu începe sau se termină cu cratimă
    if [[ "$input" =~ ^- ]] || [[ "$input" =~ -$ ]]; then
        return 1
    fi
    
    return 0
}

# Validează prenumele (doar litere și cratimă)
validate_firstname() {
    local input="$1"
    
    if [[ ! "$input" =~ ^[a-zA-Z-]+$ ]]; then
        return 1
    fi
    
    if [[ "$input" =~ ^- ]] || [[ "$input" =~ -$ ]]; then
        return 1
    fi
    
    return 0
}

# Validează grupa (exact 4 cifre)
validate_group() {
    local input="$1"
    
    if [[ ! "$input" =~ ^[0-9]{4}$ ]]; then
        return 1
    fi
    
    return 0
}

# Validează numărul temei (01-07 urmat de o literă)
validate_homework_number() {
    local input="$1"
    
    # Verifică formatul: 2 cifre (01-07) + 1 literă
    if [[ ! "$input" =~ ^0[1-7][a-zA-Z]$ ]]; then
        return 1
    fi
    
    return 0
}

# Convertește la MAJUSCULE
to_uppercase() {
    echo "$1" | tr '[:lower:]' '[:upper:]'
}

# Convertește la minuscule
to_lowercase() {
    echo "$1" | tr '[:upper:]' '[:lower:]'
}

# Convertește la Title Case
to_titlecase() {
    local input="$1"
    # Prima literă majusculă, restul minuscule (pentru fiecare cuvânt separat prin cratimă)
    echo "$input" | sed 's/\b\(.\)/\u\1/g' | sed 's/-\(.\)/-\u\1/g'
}

#===============================================================================
# COLECTEAZĂ DATELE STUDENTULUI
#===============================================================================

collect_student_data() {
    echo -e "${BOLD}📝 Introdu datele studentului${NC}"
    echo -e "${YELLOW}   (Numele compuse se scriu cu cratimă, ex.: Popescu-Ionescu)${NC}"
    echo ""
    
    # Nume de familie
    while true; do
        read -r -p "   Nume: " SURNAME
        if validate_surname "$SURNAME"; then
            SURNAME=$(to_uppercase "$SURNAME")
            print_success "Nume: $SURNAME"
            break
        else
            print_error "Invalid! Folosește doar litere și cratimă (fără spații)."
        fi
    done
    
    # Prenume
    while true; do
        read -r -p "   Prenume: " FIRSTNAME
        if validate_firstname "$FIRSTNAME"; then
            # Convertește la Title Case
            FIRSTNAME=$(to_lowercase "$FIRSTNAME")
            FIRSTNAME=$(to_titlecase "$FIRSTNAME")
            print_success "Prenume: $FIRSTNAME"
            break
        else
            print_error "Invalid! Folosește doar litere și cratimă (fără spații)."
        fi
    done
    
    # Grupă
    while true; do
        read -r -p "   Numărul grupei (4 cifre, ex.: 1029): " GROUP
        if validate_group "$GROUP"; then
            print_success "Grupă: $GROUP"
            break
        else
            print_error "Invalid! Grupa trebuie să aibă exact 4 cifre."
        fi
    done
    
    # Specializare
    echo ""
    echo -e "${BOLD}   Selectează specializarea:${NC}"
    echo "   1) eninfo  - Economic Informatics (English)"
    echo "   2) grupeid - ID Group"
    echo "   3) roinfo  - Economic Informatics (Romanian)"
    echo ""
    
    while true; do
        read -r -p "   Alege opțiunea (1/2/3): " SPEC_CHOICE
        case $SPEC_CHOICE in
            1)
                SPECIALIZATION="eninfo"
                print_success "Specializare: $SPECIALIZATION"
                break
                ;;
            2)
                SPECIALIZATION="grupeid"
                print_success "Specializare: $SPECIALIZATION"
                break
                ;;
            3)
                SPECIALIZATION="roinfo"
                print_success "Specializare: $SPECIALIZATION"
                break
                ;;
            *)
                print_error "Invalid! Alege 1, 2 sau 3."
                ;;
        esac
    done
    
    # Număr temă
    echo ""
    while true; do
        read -r -p "   Numărul temei (ex.: 01a, 03b, 07c): " HOMEWORK_NUM
        if validate_homework_number "$HOMEWORK_NUM"; then
            # Convertește litera la minuscule
            HOMEWORK_NUM="${HOMEWORK_NUM:0:2}$(to_lowercase "${HOMEWORK_NUM:2:1}")"
            print_success "Temă: HW$HOMEWORK_NUM"
            break
        else
            print_error "Invalid! Format: 01-07 urmat de o literă (ex.: 01a, 03b, 07c)"
        fi
    done
    
    echo ""
}

#===============================================================================
# GENEREAZĂ NUMELE FIȘIERULUI
#===============================================================================

generate_filename() {
    # Format: [Grupă]_[NUME]_[Prenume]_HW[Număr].cast
    FILENAME="${GROUP}_${SURNAME}_${FIRSTNAME}_HW${HOMEWORK_NUM}.cast"
    FILEPATH="$(pwd)/${FILENAME}"
    
    echo -e "${BOLD}📄 Nume fișier generat:${NC}"
    echo -e "   ${CYAN}${FILENAME}${NC}"
    echo ""
}

#===============================================================================
# ÎNREGISTRARE ASCIINEMA
#===============================================================================

start_recording() {
    echo -e "${BOLD}🎬 Se pregătește înregistrarea...${NC}"
    echo ""
    
    # Creează fișier bashrc temporar cu alias
    TEMP_RC=$(mktemp)
    cat > "$TEMP_RC" << 'EOF'
# Încarcă configurația implicită dacă există
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi

# Alias pentru oprirea înregistrării
alias STOP_homework='echo ""; echo "🛑 Înregistrare oprită. Se salvează..."; exit'

# Mesaj de start
echo ""
echo "╔═══════════════════════════════════════════════════════════════════╗"
echo "║                    🔴 ÎNREGISTRARE ÎN CURS                       ║"
echo "╠═══════════════════════════════════════════════════════════════════╣"
echo "║                                                                   ║"
echo "║   Pentru a OPRI și SALVA înregistrarea, tastează:                           ║"
echo "║                                                                   ║"
echo "║                      STOP_homework                                ║"
echo "║                                                                   ║"
echo "║   sau apasă Ctrl+D                                                 ║"
echo "║                                                                   ║"
echo "╚═══════════════════════════════════════════════════════════════════╝"
echo ""
EOF
    
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                    📹 SE ÎNCEPE ÎNREGISTRAREA                           ║${NC}"
    echo -e "${GREEN}╠═══════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${GREEN}║                                                                   ║${NC}"
    echo -e "${GREEN}║   Student: ${SURNAME} ${FIRSTNAME}                                ${NC}"
    echo -e "${GREEN}║   Grupă: ${GROUP} | Specializare: ${SPECIALIZATION}             ${NC}"
    echo -e "${GREEN}║   Temă: HW${HOMEWORK_NUM}                                     ${NC}"
    echo -e "${GREEN}║                                                                   ║${NC}"
    echo -e "${GREEN}║   Pentru a OPRI înregistrarea, tastează: ${YELLOW}STOP_homework${GREEN}                  ║${NC}"
    echo -e "${GREEN}║                                                                   ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    sleep 2
    
    # Pornește înregistrarea asciinema
    asciinema rec --overwrite "$FILEPATH" -c "bash --rcfile $TEMP_RC"
    
    # Șterge fișierul temporar
    rm -f "$TEMP_RC"
    
    echo ""
    print_success "Înregistrare completă!"
    echo ""
}

#===============================================================================
# GENEREAZĂ SEMNĂTURA CRIPTOGRAFICĂ
#===============================================================================

generate_signature() {
    echo -e "${BOLD}🔐 Se generează semnătura criptografică...${NC}"
    echo ""
    
    # Verifică dacă fișierul există
    if [[ ! -f "$FILEPATH" ]]; then
        print_error "Fișierul de înregistrare nu a fost găsit!"
        exit 1
    fi
    
    # Colectează datele pentru semnătură
    local FILE_SIZE
    FILE_SIZE=$(stat -c%s "$FILEPATH")
    local CURRENT_DATE
    CURRENT_DATE=$(date +"%d-%m-%Y")
    local CURRENT_TIME
    CURRENT_TIME=$(date +"%H:%M:%S")
    local SYSTEM_USER
    SYSTEM_USER=$(whoami)
    local ABSOLUTE_PATH
    ABSOLUTE_PATH=$(realpath "$FILEPATH")
    
    # Construiește șirul de semnat
    # Format: SURNAME+FIRSTNAME GROUP FileSizeInBytes Date(DD-MM-YYYY) Time(HH:MM:SS) SystemUsername AbsolutePath
    local DATA_TO_SIGN="${SURNAME}+${FIRSTNAME} ${GROUP} ${FILE_SIZE} ${CURRENT_DATE} ${CURRENT_TIME} ${SYSTEM_USER} ${ABSOLUTE_PATH}"
    
    print_info "Date pentru semnătură:"
    echo "   $DATA_TO_SIGN"
    echo ""
    
    # Salvează cheia publică în fișier temporar
    local TEMP_PUBKEY
    TEMP_PUBKEY=$(mktemp)
    echo "$PUBLIC_KEY" > "$TEMP_PUBKEY"
    
    # Criptează cu RSA și convertește la Base64
    local ENCRYPTED_B64
    ENCRYPTED_B64=$(echo -n "$DATA_TO_SIGN" | openssl pkeyutl -encrypt -pubin -inkey "$TEMP_PUBKEY" -pkeyopt rsa_padding_mode:pkcs1 2>/dev/null | base64 -w 0)
    
    # Șterge cheia temporară
    rm -f "$TEMP_PUBKEY"
    
    if [[ -z "$ENCRYPTED_B64" ]]; then
        print_error "Eroare la generarea semnăturii criptografice!"
        exit 1
    fi
    
    # Adaugă semnătura la fișierul .cast
    echo "" >> "$FILEPATH"
    echo "## ${ENCRYPTED_B64}" >> "$FILEPATH"
    
    print_success "Semnătura criptografică a fost adăugată!"
    echo ""
}

#===============================================================================
# ÎNCĂRCARE SCP CU REÎNCERCARE
#===============================================================================

upload_homework() {
    echo -e "${BOLD}📤 Se încarcă tema pe server...${NC}"
    echo ""
    
    # Construiește acreditările
    local SCP_USER="stud-id"
    local SCP_DEST="${SCP_BASE_PATH}/${SPECIALIZATION}"
    
    print_info "Server: ${SCP_SERVER}:${SCP_PORT}"
    print_info "Utilizator: ${SCP_USER}"
    print_info "Destinație: ${SCP_DEST}"
    echo ""
    
    local attempt=1
    local upload_success=false
    
    # Dezactivează temporar errexit pentru încercările de upload
    set +e
    
    while [[ $attempt -le $MAX_RETRIES ]]; do
        echo -e "${YELLOW}   Încercarea $attempt din $MAX_RETRIES...${NC}"
        
        # SCP cu sshpass și opțiuni pentru a ocoli promptul SSH
        sshpass -p "$SCP_PASSWORD" scp -P "$SCP_PORT" \
            -o StrictHostKeyChecking=no \
            -o UserKnownHostsFile=/dev/null \
            -o LogLevel=ERROR \
            "$FILEPATH" "${SCP_USER}@${SCP_SERVER}:${SCP_DEST}/" 2>/dev/null
        
        if [[ $? -eq 0 ]]; then
            upload_success=true
            break
        else
            print_warning "Încercarea $attempt a eșuat."
            ((attempt++)) || true
            if [[ $attempt -le $MAX_RETRIES ]]; then
                echo "   Se reîncearcă în 3 secunde..."
                sleep 3
            fi
        fi
    done
    
    # Reactivează errexit
    set -e
    
    echo ""
    
    if [[ "$upload_success" == true ]]; then
        echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║                    ✅ ÎNCĂRCARE REUȘITĂ!                           ║${NC}"
        echo -e "${GREEN}╠═══════════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${GREEN}║                                                                   ║${NC}"
        echo -e "${GREEN}║   Fișier: ${FILENAME}${NC}"
        echo -e "${GREEN}║   Server: ${SCP_SERVER}:${SCP_PORT}${NC}"
        echo -e "${GREEN}║   Locație: ${SCP_DEST}/${NC}"
        echo -e "${GREEN}║                                                                   ║${NC}"
        echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════════╝${NC}"
    else
        echo -e "${RED}╔═══════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${RED}║               ❌ NU S-A PUTUT TRIMITE TEMA!                          ║${NC}"
        echo -e "${RED}╠═══════════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${RED}║                                                                   ║${NC}"
        echo -e "${RED}║   Fișierul a fost SALVAT LOCAL                                 ║${NC}"
        echo -e "${RED}║                                                                   ║${NC}"
        echo -e "${RED}╚═══════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║                                                                   ║${NC}"
        printf "${GREEN}║   📁  %-57s  ║${NC}\n" "${FILENAME}"
        echo -e "${GREEN}║                                                                   ║${NC}"
        echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${CYAN}Încearcă mai târziu (după restabilirea conexiunii) folosind:${NC}"
        echo ""
        echo -e "${GREEN}  scp -P ${SCP_PORT} ${FILENAME} ${SCP_USER}@${SCP_SERVER}:${SCP_DEST}/${NC}"
        echo ""
        echo -e "${YELLOW}⚠️  NU modifica fișierul .cast înainte de trimitere!${NC}"
    fi
    
    echo ""
}

#===============================================================================
# FINALIZARE
#===============================================================================

finalize() {
    echo -e "${BOLD}📋 Rezumat final${NC}"
    echo ""
    echo "   Student: ${SURNAME} ${FIRSTNAME}"
    echo "   Grupă: ${GROUP}"
    echo "   Specializare: ${SPECIALIZATION}"
    echo "   Temă: HW${HOMEWORK_NUM}"
    echo "   Fișier: ${FILENAME}"
    echo "   Locație locală: ${FILEPATH}"
    echo ""
    
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                    🎉 PROCES FINALIZAT!                          ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

#===============================================================================
# PRINCIPAL
#===============================================================================

main() {
    clear
    print_header
    
    check_and_install_prerequisites
    
    collect_student_data
    
    generate_filename
    
    # Confirmă înainte de înregistrare
    echo -e "${BOLD}❓ Ești pregătit să începi înregistrarea?${NC}"
    read -r -p "   Apasă ENTER pentru a continua sau Ctrl+C pentru a anula..."
    echo ""
    
    start_recording
    
    generate_signature
    
    upload_homework
    
    finalize
}

# Rulează scriptul
main
