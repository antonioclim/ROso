#!/bin/bash
#
# TEMPLATE TEMĂ - Seminar 1-2: Shell Bash
# 
# Acest script creează structura de bază pentru tema ta.
# Rulează-l o singură dată, apoi completează fișierele create.
#
# Utilizare: ./creeaza_tema.sh "NumeleTau" "Grupa"
#

# Verifică argumentele
if [ $# -lt 2 ]; then
    echo "Utilizare: $0 \"Numele Tău\" \"Grupa\""
    echo "Exemplu: $0 \"Popescu Ion\" \"1234\""
    exit 1
fi

NUME="$1"
GRUPA="$2"
DATA=$(date +%Y-%m-%d)
TEMA_DIR="$HOME/tema_seminar1"

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║         CREARE STRUCTURĂ TEMĂ - Seminar 1-2                   ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo "Student: $NUME"
echo "Grupa:   $GRUPA"
echo "Data:    $DATA"
echo ""

# Verifică dacă directorul există deja
if [ -d "$TEMA_DIR" ]; then
    echo "⚠️  Directorul $TEMA_DIR există deja!"
    read -p "Dorești să-l ștergi și să creezi unul nou? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$TEMA_DIR"
    else
        echo "Operație anulată."
        exit 1
    fi
fi

# Creează structura
echo "📁 Creare structură directoare..."
mkdir -p "$TEMA_DIR/proiect"/{src,docs,tests}

# Creează AUTOR.txt
echo "📝 Creare AUTOR.txt..."
cat > "$TEMA_DIR/AUTOR.txt" << EOF
═══════════════════════════════════════════════════════════════════════════════
                           INFORMAȚII STUDENT
═══════════════════════════════════════════════════════════════════════════════

Nume:    $NUME
Grupa:   $GRUPA
Data:    $DATA

Tema:    Seminar 1-2 - Shell Bash
Curs:    Sisteme de Operare
Facultate: ASE București - CSIE

═══════════════════════════════════════════════════════════════════════════════
EOF

# Creează README.md
echo "📝 Creare README.md..."
cat > "$TEMA_DIR/proiect/docs/README.md" << EOF
# Proiect Seminar 1-2: Shell Bash

**Autor:** $NUME  
**Grupa:** $GRUPA  
**Data:** $DATA

## Descriere

Acest proiect demonstrează cunoștințele despre:
- Navigarea în sistemul de fișiere Linux
- Lucrul cu variabile shell
- Configurarea mediului de lucru
- Utilizarea wildcards (globbing)

## Structură

\`\`\`
proiect/
├── src/
│   ├── main.sh           # Script principal
│   ├── variabile.sh      # Demonstrație variabile
│   └── info_sistem.sh    # Raport sistem
├── docs/
│   └── README.md         # Acest fișier
└── tests/
    └── test_globbing.sh  # Teste globbing
\`\`\`

## Comenzi Folosite

### Creare structură:
\`\`\`bash
# TODO: Completează cu comenzile folosite
mkdir -p proiect/{src,docs,tests}
\`\`\`

### Alte comenzi:
\`\`\`bash
# TODO: Adaugă comenzile importante pe care le-ai învățat
\`\`\`

## Note

[Adaugă aici observații sau dificultăți întâmpinate]
EOF

# Creează main.sh
echo "📝 Creare main.sh..."
cat > "$TEMA_DIR/proiect/src/main.sh" << 'EOF'
#!/bin/bash
#
# main.sh - Script principal
# Autor: [COMPLETEAZĂ]
# Data: [COMPLETEAZĂ]
#

echo "═══════════════════════════════════════════════════════════════"
echo "              TEMA SEMINAR 1-2: SHELL BASH"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Rulează celelalte scripturi
echo "1. Rulare variabile.sh..."
./variabile.sh 2>/dev/null || echo "   [Script neimplementat încă]"
echo ""

echo "2. Rulare info_sistem.sh..."
./info_sistem.sh 2>/dev/null || echo "   [Script neimplementat încă]"
echo ""

echo "3. Rulare test_globbing.sh..."
(cd ../tests && ./test_globbing.sh) 2>/dev/null || echo "   [Script neimplementat încă]"
echo ""

echo "═══════════════════════════════════════════════════════════════"
echo "                      TEMA COMPLETĂ"
echo "═══════════════════════════════════════════════════════════════"
EOF
chmod +x "$TEMA_DIR/proiect/src/main.sh"

# Creează variabile.sh (template)
echo "📝 Creare variabile.sh (template)..."
cat > "$TEMA_DIR/proiect/src/variabile.sh" << 'EOF'
#!/bin/bash
#
# variabile.sh - Demonstrație variabile Bash
# Autor: [COMPLETEAZĂ]
# Data: [COMPLETEAZĂ]
#

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║              DEMONSTRAȚIE VARIABILE BASH                       ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# 
# SECȚIUNEA 1: Variabile Locale (5%)
# 
echo "═══ VARIABILE LOCALE ═══"

# TODO: Definește cel puțin 3 variabile locale
# Exemplu:
# PRENUME="Ion"
# VARSTA=22
# HOBBY="programare"

# TODO: Afișează variabilele
# echo "Prenume: $PRENUME"

echo ""

# 
# SECȚIUNEA 2: Variabile de Mediu (5%)
# 
echo "═══ VARIABILE DE MEDIU ═══"

# TODO: Afișează variabilele de mediu importante
echo "USER:  $USER"
echo "HOME:  $HOME"
# TODO: Adaugă SHELL și PATH

echo ""

# 
# SECȚIUNEA 3: Demonstrație Export (5%)
# 
echo "═══ DEMONSTRAȚIE EXPORT ═══"

# TODO: Demonstrează diferența între variabilă locală și exportată
# LOCAL_VAR="local"
# export GLOBAL_VAR="global"
# bash -c 'echo "În subshell: LOCAL=$LOCAL_VAR, GLOBAL=$GLOBAL_VAR"'

echo ""

# 
# SECȚIUNEA 4: Exit Code (5%)
# 
echo "═══ EXIT CODE ═══"

# TODO: Demonstrează exit code
# ls /tmp > /dev/null
# echo "Exit code pentru ls /tmp: $?"
# ls /director_inexistent 2>/dev/null
# echo "Exit code pentru director inexistent: $?"

echo ""

# 
# SECȚIUNEA 5: Quoting (5%)
# 
echo "═══ QUOTING ═══"

# TODO: Demonstrează diferența între single și double quotes
# MESAJ="Salut"
# echo 'Single quotes: $MESAJ'     # Afișează literal $MESAJ
# echo "Double quotes: $MESAJ"     # Afișează valoarea

echo ""
echo "═══════════════════════════════════════════════════════════════════"
EOF
chmod +x "$TEMA_DIR/proiect/src/variabile.sh"

# Creează info_sistem.sh (template)
echo "📝 Creare info_sistem.sh (template)..."
cat > "$TEMA_DIR/proiect/src/info_sistem.sh" << 'EOF'
#!/bin/bash
#
# info_sistem.sh - Raport informații sistem
# Autor: [COMPLETEAZĂ]
# Data: [COMPLETEAZĂ]
#

echo "╔════════════════════════════════════════╗"
echo "║         RAPORT SISTEM                  ║"
echo "╠════════════════════════════════════════╣"

# TODO: Completează pentru fiecare cerință (2p fiecare)

# 1. Numele utilizatorului curent
printf "║ Utilizator: %-25s ║\n" "$USER"

# 2. Directorul home
# TODO: printf " Home:       %-25s \n" "..."

# 3. Shell-ul utilizat
# TODO: printf " Shell:      %-25s \n" "..."

# 4. Versiunea kernel-ului (folosește uname -r)
# TODO: printf " Kernel:     %-25s \n" "..."

# 5. Data și ora curentă (folosește date)
# TODO: printf " Data:       %-25s \n" "..."

echo "╚════════════════════════════════════════╝"
EOF
chmod +x "$TEMA_DIR/proiect/src/info_sistem.sh"

# Creează test_globbing.sh (template)
echo "📝 Creare test_globbing.sh (template)..."
cat > "$TEMA_DIR/proiect/tests/test_globbing.sh" << 'EOF'
#!/bin/bash
#
# test_globbing.sh - Demonstrație wildcards/globbing
# Autor: [COMPLETEAZĂ]
# Data: [COMPLETEAZĂ]
#

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║              DEMONSTRAȚIE GLOBBING                             ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Creează directorul de test
TEST_DIR=$(mktemp -d)
cd "$TEST_DIR"

echo "Director de test: $TEST_DIR"
echo ""

# 
# SECȚIUNEA 1: Creare fișiere de test (5%)
# 
echo "═══ CREARE FIȘIERE DE TEST ═══"

# TODO: Creează fișierele de test cu o singură comandă
touch file{1..10}.txt doc{A..E}.pdf image{01..05}.jpg .hidden

echo "Fișiere create:"
ls -la
echo ""

# 
# SECȚIUNEA 2: Pattern-uri (5%)
# 
echo "═══ PATTERN-URI ═══"

echo "1. Doar fișierele .txt:"
# TODO: Completează comanda
# ls *.txt

echo ""
echo "2. file1.txt până la file5.txt (folosind range [1-5]):"
# TODO: Completează comanda
# ls file[1-5].txt

echo ""
echo "3. Fișiere cu exact 5 caractere înainte de extensie:"
# TODO: Completează comanda (hint: folosește ?????)
# ls ?????.???

echo ""

# 
# SECȚIUNEA 3: Explicație .hidden (5%)
# 
echo "═══ FIȘIERE ASCUNSE ═══"

echo "Comanda 'ls *' afișează:"
ls *
echo ""

echo "Comanda 'ls .*' afișează:"
ls .* 2>/dev/null | grep -v "^\.\.$"
echo ""

# TODO: Explică în comentariu de ce ls * nu afișează .hidden
# EXPLICAȚIE:
# [Scrie aici explicația ta]
# Hint: Are legătură cu cum funcționează globbing-ul în Bash

# 
# SECȚIUNEA 4: Brace Expansion (5%)
# 
echo "═══ BRACE EXPANSION ═══"

# TODO: Creează directoarele dir1, dir2, dir3 cu o singură comandă
# mkdir dir{1,2,3}

echo "Directoare create:"
# ls -d dir*/

# Curățare
cd ~
rm -rf "$TEST_DIR"

echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "Test complet!"
EOF
chmod +x "$TEMA_DIR/proiect/tests/test_globbing.sh"

# Creează .bashrc (template)
echo "📝 Creare .bashrc personalizat..."
cat > "$TEMA_DIR/.bashrc" << EOF
#
# ~/.bashrc - Configurare personalizată Bash
# Autor: $NUME
# Grupa: $GRUPA
# Data: $DATA
#

# Dacă shell-ul nu e interactiv, nu face nimic
case \$- in
    *i*) ;;
      *) return;;
esac

# 
# SECȚIUNEA 1: ALIAS-URI (10%)
# 

# Alias obligatoriu: ll pentru listare detaliată
alias ll='ls -la'

# Alias obligatoriu: cls pentru clear
alias cls='clear'

# Alias obligatoriu: .. pentru a urca un nivel
alias ..='cd ..'

# TODO: Adaugă un alias la alegere pentru o comandă frecvent folosită
# alias NUME='comanda'

# 
# SECȚIUNEA 2: FUNCȚII (10%)
# 

# Funcție obligatorie: mkcd - creează director și intră în el
mkcd() {
    # TODO: Implementează funcția
    # Hint: mkdir -p "\$1" && cd "\$1"
    echo "Funcția mkcd nu este implementată încă"
}

# BONUS: Funcție extract pentru dezarhivare (+3p)
# extract() {
#     case "\$1" in
#         *.tar.gz)  tar xzf "\$1" ;;
#         *.tar.bz2) tar xjf "\$1" ;;
#         *.zip)     unzip "\$1" ;;
#         *)         echo "Format necunoscut: \$1" ;;
#     esac
# }

# 
# SECȚIUNEA 3: VARIABILE DE MEDIU (5%)
# 

# Modificare PATH - adaugă \$HOME/bin la început
export PATH="\$HOME/bin:\$PATH"

# Editor implicit
export EDITOR="nano"

# Istoric comenzi mai lung
export HISTSIZE=10000
export HISTFILESIZE=20000

# 
# BONUS: PROMPT PERSONALIZAT PS1 (+3p)
# 

# TODO: Personalizează prompt-ul cu culori
# Exemplu: PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# 
# FIN CONFIGURARE
# 
EOF

# Afișare finală
echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║              STRUCTURĂ CREATĂ CU SUCCES!                      ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo "Director: $TEMA_DIR"
echo ""
echo "Structură creată:"
if command -v tree &>/dev/null; then
    tree "$TEMA_DIR"
else
    find "$TEMA_DIR" -type f | sed 's|'"$TEMA_DIR"'/||'
fi

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "PAȘI URMĂTORI:"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "1. Navighează în directorul temei:"
echo "   cd $TEMA_DIR"
echo ""
echo "2. Completează fișierele (caută TODO-urile):"
echo "   nano proiect/src/variabile.sh"
echo "   nano proiect/src/info_sistem.sh"
echo "   nano proiect/tests/test_globbing.sh"
echo "   nano .bashrc"
echo ""
echo "3. Testează scripturile:"
echo "   bash -n proiect/src/variabile.sh   # Verifică sintaxa"
echo "   ./proiect/src/variabile.sh         # Rulează"
echo ""
echo "4. Creează arhiva pentru predare:"
echo "   cd ~ && zip -r ${NUME// /_}_Seminar1.zip tema_seminar1/"
echo ""
echo "Gata!"
