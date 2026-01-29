#!/bin/bash
#===============================================================================
#
#          FILE:  record_homework.sh
#
#         USAGE:  ./record_homework.sh
#
#   DESCRIPTION:  Script pentru înregistrarea temelor studenților folosind asciinema
#                 Include: validare input, înregistrare sesiune, semnătură criptografică,
#                 upload automat pe server
#
#        AUTHOR:  Sisteme de Operare 2023-2027 - Revolvix/github.com
#       VERSION:  1.0
#       CREATED:  2025
#
#===============================================================================

set -e

#===============================================================================
# CHEIE PUBLICĂ RSA - NU MODIFICA!
# Folosită pentru semnătura criptografică a temelor
#===============================================================================
PUBLIC_KEY="-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCieNySGxV0PZUBbAjbwksHyUUB
soa9fbLVI9uK7viOAVi0c5ZHjfnwU/LhRxLT4qbBNSlUBoXqiiVAg+Z+NWY2B/eY
POoTxuSLgkS0NfJjd55t2N4gzJHydma6gfwLg3kpDEJoSIlTfI83aFHuyzPxgzbj
HAsViFvWuv8rlbxvHwIDAQAB
-----END PUBLIC KEY-----"

#===============================================================================
# CONFIGURARE SERVER
#===============================================================================
SCP_SERVER="sop.ase.ro"
SCP_PORT="1001"
SCP_PASSWORD="stud"
SCP_BASE_PATH="/home/HOMEWORKS"
MAX_RETRIES=3

#===============================================================================
# CULORI PENTRU OUTPUT
#===============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

#===============================================================================
# FUNCȚII UTILITARE
#===============================================================================

print_header() {
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════════════════════╗"
    echo "║                                                                   ║"
    echo "║          📹 SISTEM ÎNREGISTRARE TEME - ASCIINEMA                  ║"
    echo "║                Sisteme de Operare 2023-2027                       ║"
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
# VERIFICARE ȘI INSTALARE PREREQUISITE
#===============================================================================

check_and_install_prerequisites() {
    echo -e "${BOLD}📦 Verificare și instalare prerequisite...${NC}"
    echo ""
    
    local packages_to_install=""
    
    # Verifică asciinema
    if ! command -v asciinema &> /dev/null; then
        print_warning "asciinema nu este instalat"
        packages_to_install="$packages_to_install asciinema"
    else
        print_success "asciinema este instalat"
    fi
    
    # Verifică openssl
    if ! command -v openssl &> /dev/null; then
        print_warning "openssl nu este instalat"
        packages_to_install="$packages_to_install openssl"
    else
        print_success "openssl este instalat"
    fi
    
    # Verifică sshpass
    if ! command -v sshpass &> /dev/null; then
        print_warning "sshpass nu este instalat"
        packages_to_install="$packages_to_install sshpass"
    else
        print_success "sshpass este instalat"
    fi
    
    # Instalează pachetele lipsă
    if [ -n "$packages_to_install" ]; then
        echo ""
        print_info "Se instalează pachetele lipsă:$packages_to_install"
        echo ""
        
        # Update și instalare
        sudo apt update -qq
        sudo apt install -y $packages_to_install
        
        if [ $? -eq 0 ]; then
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
# FUNCȚII DE VALIDARE INPUT
#===============================================================================

# Validare nume familie (doar litere și cratimă, convertit la UPPERCASE)
validate_surname() {
    local input="$1"
    
    # Verifică dacă conține doar litere și cratimă
    if [[ ! "$input" =~ ^[a-zA-Z-]+$ ]]; then
        return 1
    fi
    
    # Verifică să nu înceapă sau să se termine cu cratimă
    if [[ "$input" =~ ^- ]] || [[ "$input" =~ -$ ]]; then
        return 1
    fi
    
    return 0
}

# Validare prenume (doar litere și cratimă)
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

# Validare grup (exact 4 cifre)
validate_group() {
    local input="$1"
    
    if [[ ! "$input" =~ ^[0-9]{4}$ ]]; then
        return 1
    fi
    
    return 0
}

# Validare număr temă (01-07 urmat de o literă)
validate_homework_number() {
    local input="$1"
    
    # Verifică formatul: 2 cifre (01-07) + 1 literă
    if [[ ! "$input" =~ ^0[1-7][a-zA-Z]$ ]]; then
        return 1
    fi
    
    return 0
}

# Conversie la UPPERCASE
to_uppercase() {
    echo "$1" | tr '[:lower:]' '[:upper:]'
}

# Conversie la lowercase
to_lowercase() {
    echo "$1" | tr '[:upper:]' '[:lower:]'
}

# Conversie la Title Case
to_titlecase() {
    local input="$1"
    # Prima literă mare, restul mici (pentru fiecare cuvânt separat de cratimă)
    echo "$input" | sed 's/\b\(.\)/\u\1/g' | sed 's/-\(.\)/-\u\1/g'
}

#===============================================================================
# COLECTARE DATE STUDENT
#===============================================================================

collect_student_data() {
    echo -e "${BOLD}📝 Introducere date student${NC}"
    echo -e "${YELLOW}   (Numele compuse se scriu cu cratimă, ex: Ionescu-Popescu)${NC}"
    echo ""
    
    # Nume familie
    while true; do
        read -p "   Nume de familie: " SURNAME
        if validate_surname "$SURNAME"; then
            SURNAME=$(to_uppercase "$SURNAME")
            print_success "Nume familie: $SURNAME"
            break
        else
            print_error "Invalid! Folosește doar litere și cratimă (fără spații)."
        fi
    done
    
    # Prenume
    while true; do
        read -p "   Prenume: " FIRSTNAME
        if validate_firstname "$FIRSTNAME"; then
            # Convertim la Title Case
            FIRSTNAME=$(to_lowercase "$FIRSTNAME")
            FIRSTNAME=$(to_titlecase "$FIRSTNAME")
            print_success "Prenume: $FIRSTNAME"
            break
        else
            print_error "Invalid! Folosește doar litere și cratimă (fără spații)."
        fi
    done
    
    # Grup
    while true; do
        read -p "   Număr grupă (4 cifre, ex: 1029): " GROUP
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
    echo "   1) eninfo  - Informatică Economică (Engleză)"
    echo "   2) grupeid - Grupă ID"
    echo "   3) roinfo  - Informatică Economică (Română)"
    echo ""
    
    while true; do
        read -p "   Alege opțiunea (1/2/3): " SPEC_CHOICE
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
        read -p "   Număr temă (ex: 01a, 03b, 07c): " HOMEWORK_NUM
        if validate_homework_number "$HOMEWORK_NUM"; then
            # Convertim litera la lowercase
            HOMEWORK_NUM="${HOMEWORK_NUM:0:2}$(to_lowercase "${HOMEWORK_NUM:2:1}")"
            print_success "Temă: HW$HOMEWORK_NUM"
            break
        else
            print_error "Invalid! Format: 01-07 urmat de o literă (ex: 01a, 03b, 07c)"
        fi
    done
    
    echo ""
}

#===============================================================================
# GENERARE NUME FIȘIER
#===============================================================================

generate_filename() {
    # Format: [Grup]_[NUMEFAMILIE]_[Prenume]_HW[NrTema].cast
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
    echo -e "${BOLD}🎬 Pregătire înregistrare...${NC}"
    echo ""
    
    # Creează fișier bashrc temporar cu alias
    TEMP_RC=$(mktemp)
    cat > "$TEMP_RC" << 'EOF'
# Încarcă configurația implicită dacă există
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi

# Alias pentru oprirea înregistrării
alias STOP_tema='echo ""; echo "🛑 Înregistrare oprită. Se salvează..."; exit'

# Mesaj de start
echo ""
echo "╔═══════════════════════════════════════════════════════════════════╗"
echo "║                    🔴 ÎNREGISTRARE ÎN CURS                        ║"
echo "╠═══════════════════════════════════════════════════════════════════╣"
echo "║                                                                   ║"
echo "║   Pentru a OPRI și SALVA înregistrarea, tastează:                 ║"
echo "║                                                                   ║"
echo "║                      STOP_tema                                ║"
echo "║                                                                   ║"
echo "║   sau apasă Ctrl+D                                                ║"
echo "║                                                                   ║"
echo "╚═══════════════════════════════════════════════════════════════════╝"
echo ""
EOF
    
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                    📹 ÎNCEPE ÎNREGISTRAREA                         ║${NC}"
    echo -e "${GREEN}╠═══════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${GREEN}║                                                                   ║${NC}"
    echo -e "${GREEN}║   Student: ${SURNAME} ${FIRSTNAME}                                ${NC}"
    echo -e "${GREEN}║   Grupa: ${GROUP} | Specializare: ${SPECIALIZATION}               ${NC}"
    echo -e "${GREEN}║   Tema: HW${HOMEWORK_NUM}                                         ${NC}"
    echo -e "${GREEN}║                                                                   ║${NC}"
    echo -e "${GREEN}║   Pentru a OPRI înregistrarea, tastează: ${YELLOW}STOP_tema${GREEN}          ║${NC}"
    echo -e "${GREEN}║                                                                   ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    sleep 2
    
    # Pornește înregistrarea asciinema
    asciinema rec --overwrite "$FILEPATH" -c "bash --rcfile $TEMP_RC"
    
    # Cleanup fișier temporar
    rm -f "$TEMP_RC"
    
    echo ""
    print_success "Înregistrare finalizată!"
    echo ""
}

#===============================================================================
# GENERARE SEMNĂTURĂ CRIPTOGRAFICĂ
#===============================================================================

generate_signature() {
    echo -e "${BOLD}🔐 Generare semnătură criptografică...${NC}"
    echo ""
    
    # Verifică dacă fișierul există
    if [ ! -f "$FILEPATH" ]; then
        print_error "Fișierul înregistrării nu a fost găsit!"
        exit 1
    fi
    
    # Colectează datele pentru semnătură
    local FILE_SIZE=$(stat -c%s "$FILEPATH")
    local CURRENT_DATE=$(date +"%d-%m-%Y")
    local CURRENT_TIME=$(date +"%H:%M:%S")
    local SYSTEM_USER=$(whoami)
    local ABSOLUTE_PATH=$(realpath "$FILEPATH")
    
    # Construiește string-ul de semnat
    # Format: SURNAME+FIRSTNAME GROUP FileSizeInBytes Date(DD-MM-YYYY) Time(HH:MM:SS) SystemUsername AbsolutePath
    local DATA_TO_SIGN="${SURNAME}+${FIRSTNAME} ${GROUP} ${FILE_SIZE} ${CURRENT_DATE} ${CURRENT_TIME} ${SYSTEM_USER} ${ABSOLUTE_PATH}"
    
    print_info "Date pentru semnătură:"
    echo "   $DATA_TO_SIGN"
    echo ""
    
    # Salvează cheia publică într-un fișier temporar
    local TEMP_PUBKEY=$(mktemp)
    echo "$PUBLIC_KEY" > "$TEMP_PUBKEY"
    
    # Criptează cu RSA și convertește la Base64
    local ENCRYPTED_B64=$(echo -n "$DATA_TO_SIGN" | openssl pkeyutl -encrypt -pubin -inkey "$TEMP_PUBKEY" -pkeyopt rsa_padding_mode:pkcs1 2>/dev/null | base64 -w 0)
    
    # Cleanup cheie temporară
    rm -f "$TEMP_PUBKEY"
    
    if [ -z "$ENCRYPTED_B64" ]; then
        print_error "Eroare la generarea semnăturii criptografice!"
        exit 1
    fi
    
    # Append semnătura la fișierul .cast
    echo "" >> "$FILEPATH"
    echo "## ${ENCRYPTED_B64}" >> "$FILEPATH"
    
    print_success "Semnătură criptografică adăugată!"
    echo ""
}

#===============================================================================
# UPLOAD SCP CU RETRY
#===============================================================================

upload_homework() {
    echo -e "${BOLD}📤 Upload temă pe server...${NC}"
    echo ""
    
    # Construiește credențialele
    local SCP_USER="stud-id"
    local SCP_DEST="${SCP_BASE_PATH}/${SPECIALIZATION}"
    
    print_info "Server: ${SCP_SERVER}:${SCP_PORT}"
    print_info "User: ${SCP_USER}"
    print_info "Destinație: ${SCP_DEST}"
    echo ""
    
    local attempt=1
    local upload_success=false
    
    while [ $attempt -le $MAX_RETRIES ]; do
        echo -e "${YELLOW}   Încercare $attempt din $MAX_RETRIES...${NC}"
        
        # SCP cu sshpass și opțiuni pentru bypass SSH prompt
        sshpass -p "$SCP_PASSWORD" scp -P "$SCP_PORT" \
            -o StrictHostKeyChecking=no \
            -o UserKnownHostsFile=/dev/null \
            -o LogLevel=ERROR \
            "$FILEPATH" "${SCP_USER}@${SCP_SERVER}:${SCP_DEST}/" 2>/dev/null
        
        if [ $? -eq 0 ]; then
            upload_success=true
            break
        else
            print_warning "Încercarea $attempt a eșuat."
            ((attempt++))
            if [ $attempt -le $MAX_RETRIES ]; then
                echo "   Se reîncearcă în 3 secunde..."
                sleep 3
            fi
        fi
    done
    
    echo ""
    
    if [ "$upload_success" = true ]; then
        echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║                    ✅ UPLOAD REUȘIT!                               ║${NC}"
        echo -e "${GREEN}╠═══════════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${GREEN}║                                                                   ║${NC}"
        echo -e "${GREEN}║   Fișier: ${FILENAME}${NC}"
        echo -e "${GREEN}║   Server: ${SCP_SERVER}:${SCP_PORT}${NC}"
        echo -e "${GREEN}║   Locație: ${SCP_DEST}/${NC}"
        echo -e "${GREEN}║                                                                   ║${NC}"
        echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════════╝${NC}"
    else
        echo -e "${RED}╔═══════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${RED}║               ❌ NU AM PUTUT TRIMITE TEMA!                         ║${NC}"
        echo -e "${RED}╠═══════════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${RED}║                                                                   ║${NC}"
        echo -e "${RED}║   Fișierul a fost SALVAT LOCAL                                    ║${NC}"
        echo -e "${RED}║                                                                   ║${NC}"
        echo -e "${RED}╚═══════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║                                                                   ║${NC}"
        printf "${GREEN}║   📁  %-57s  ║${NC}\n" "${FILENAME}"
        echo -e "${GREEN}║                                                                   ║${NC}"
        echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${CYAN}Încearcă mai târziu (când restabilești conexiunea) folosind:${NC}"
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
    echo "   Grupa: ${GROUP}"
    echo "   Specializare: ${SPECIALIZATION}"
    echo "   Tema: HW${HOMEWORK_NUM}"
    echo "   Fișier: ${FILENAME}"
    echo "   Locație locală: ${FILEPATH}"
    echo ""
    
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                    🎉 PROCES FINALIZAT!                           ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

#===============================================================================
# MAIN
#===============================================================================

main() {
    clear
    print_header
    
    check_and_install_prerequisites
    
    collect_student_data
    
    generate_filename
    
    # Confirmă înainte de înregistrare
    echo -e "${BOLD}❓ Ești pregătit să începi înregistrarea?${NC}"
    read -p "   Apasă ENTER pentru a continua sau Ctrl+C pentru a anula..."
    echo ""
    
    start_recording
    
    generate_signature
    
    upload_homework
    
    finalize
}

# Rulează scriptul
main
