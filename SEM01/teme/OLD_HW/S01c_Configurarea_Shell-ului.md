# S01_TC02 - Configurarea Shell-ului (Variabile)

> **Sisteme de Operare** | ASE București - CSIE  
> Material de laborator - Seminar 1 (Redistribuit)

---

> 🚨 **ÎNAINTE DE A ÎNCEPE TEMA**
>
> 1. Descarcă și configurează pachetul `002HWinit` (vezi GHID_STUDENT_RO.md)
> 2. Deschide un terminal și navighează în `~/HOMEWORKS`
> 3. Pornește înregistrarea cu:
>    ```bash
>    python3 record_homework_tui_RO.py
>    ```
>    sau varianta Bash:
>    ```bash
>    ./record_homework_RO.sh
>    ```
> 4. Completează datele cerute (nume, grupă, nr. temă)
> 5. **ABIA APOI** începe să rezolvi cerințele de mai jos

---

## Obiective

La finalul acestui laborator, studentul va fi capabil să:
- Configureze și personalizeze shell-ul Bash
- Lucreze cu variabile de mediu și variabile locale
- Înțeleagă fișierele de configurare ale shell-ului
- Creeze alias-uri și funcții simple

---


## 2. Variabile de Mediu Importante

### 2.1 PATH

**PATH** conține directoarele în care shell-ul caută executabile.

```bash
# Vizualizează PATH
echo $PATH
# /usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games

# Caută unde este o comandă
which python3
whereis ls

# Adaugă director la PATH
export PATH="$PATH:/home/student/bin"

# Adaugă la începutul PATH (prioritate mai mare)
export PATH="/home/student/bin:$PATH"
```

### 2.2 HOME, USER, SHELL

```bash
echo "Home: $HOME"        # /home/student
echo "User: $USER"        # student  
echo "Shell: $SHELL"      # /bin/bash
echo "Hostname: $HOSTNAME"
echo "PWD: $PWD"          # directorul curent
echo "OLDPWD: $OLDPWD"    # directorul anterior (pentru cd -)
```

### 2.3 Variabile pentru Aplicații

```bash
# Editor implicit
export EDITOR="nano"
export VISUAL="code"

# Localizare
export LANG="ro_RO.UTF-8"
export LC_ALL="ro_RO.UTF-8"

# Java
export JAVA_HOME="/usr/lib/jvm/java-17-openjdk"
export PATH="$JAVA_HOME/bin:$PATH"

# Python
export PYTHONPATH="/home/student/lib/python"
```

---

## 3. Fișiere de Configurare

### 3.1 Ordinea de Încărcare

```
LOGIN SHELL (ssh, login):
┌─────────────────┐
│  /etc/profile   │ ← Global pentru toți utilizatorii
└────────┬────────┘
         ▼
┌─────────────────┐
│  ~/.bash_profile│ ← Personal (sau ~/.bash_login sau ~/.profile)
└────────┬────────┘
         ▼
┌─────────────────┐
│  ~/.bashrc      │ ← De obicei sourced din .bash_profile
└─────────────────┘

NON-LOGIN SHELL (terminal nou):
┌─────────────────┐
│  ~/.bashrc      │ ← Doar acest fișier
└─────────────────┘
```

### 3.2 ~/.bashrc

```bash
# Editează .bashrc
nano ~/.bashrc

# Conținut tipic ~/.bashrc:

#
# ALIAS-URI
#
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias df='df -h'
alias free='free -h'

#
# VARIABILE DE MEDIU
#
export EDITOR="nano"
export HISTSIZE=10000
export HISTFILESIZE=20000

#
# PATH PERSONALIZAT
#
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

#
# PROMPT PERSONALIZAT
#
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# După modificare, aplică schimbările:
source ~/.bashrc
# sau
. ~/.bashrc
```

### 3.3 ~/.bash_profile

```bash
# Conținut tipic ~/.bash_profile:

# Încarcă .bashrc dacă există
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi

# Variabile specifice login
export DISPLAY=:0
```

---

## 4. Alias-uri

### 4.1 Definire Alias-uri

```bash
# Sintaxă
alias nume='comanda'

# Exemple utile
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias cls='clear'
alias h='history'
alias grep='grep --color=auto'

# Alias-uri pentru siguranță (confirmă înainte de ștergere)
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Alias-uri pentru directoare frecvente
alias cdp='cd ~/proiecte'
alias cdd='cd ~/Downloads'

# Vizualizează toate alias-urile
alias

# Șterge un alias
unalias ll
```

### 4.2 Alias-uri Avansate

```bash
# Alias cu argumente? NU funcționează direct
# Folosește funcții în schimb:

# Funcție pentru mkdir + cd
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Funcție pentru extragere arhive
extract() {
    case "$1" in
        *.tar.gz)  tar xzf "$1" ;;
        *.tar.bz2) tar xjf "$1" ;;
        *.zip)     unzip "$1" ;;
        *.gz)      gunzip "$1" ;;
        *.tar)     tar xf "$1" ;;
        *)         echo "Format necunoscut: $1" ;;
    esac
}
```

---

## 5. Personalizarea Prompt-ului (PS1)

### 5.1 Secvențe Speciale

| Secvență | Semnificație |
|----------|--------------|
| `\u` | Username |
| `\h` | Hostname (scurt) |
| `\H` | Hostname (complet) |
| `\w` | Director curent (cale completă) |
| `\W` | Director curent (doar numele) |
| `\d` | Data |
| `\t` | Ora (HH:MM:SS) |
| `\n` | Linie nouă |
| `\$` | `$` pentru user, `#` pentru root |

### 5.2 Culori ANSI

```bash
# Format: \[\033[CODm\]TEXT\[\033[00m\]

# Coduri culori
# 30-37: text (negru, roșu, verde, galben, albastru, magenta, cyan, alb)
# 40-47: fundal
# 0: reset, 1: bold

# Exemple
PS1='\[\033[01;32m\]\u\[\033[00m\]@\[\033[01;34m\]\h\[\033[00m\]:\w\$ '
# verde bold reset albastru reset

# Prompt simplu colorat
export PS1='\[\e[32m\]\u@\h:\[\e[34m\]\w\[\e[0m\]\$ '

# Prompt cu emoji (dacă terminalul suportă)
export PS1='🐧 \u@\h:\w\$ '
```

### 5.3 Exemple de Prompt-uri

```bash
# Minimal
PS1='\$ '

# Standard Ubuntu
PS1='\u@\h:\w\$ '

# Cu culori
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# Cu dată și oră
PS1='[\d \t] \u@\h:\w\$ '

# Pe două linii
PS1='\u@\h:\w\n\$ '
```

---

## 6. Expansiune Variabile

### 6.1 Sintaxă de Bază

```bash
NUME="Ana"

# Expansiune simplă
echo $NUME
echo ${NUME}    # echivalent, dar mai clar

# Concatenare (${} necesar)
echo "${NUME}_backup"    # Ana_backup
echo "$NUME_backup"      # eroare - caută variabila NUME_backup
```

### 6.2 Valori Implicite

```bash
# ${VAR:-default} - folosește default dacă VAR nu există sau e goală
echo ${NEDEFINITA:-"valoare implicită"}

# ${VAR:=default} - setează VAR la default dacă nu există
echo ${DIRECTOR:="/tmp"}
echo $DIRECTOR    # /tmp

# ${VAR:+altceva} - folosește "altceva" doar dacă VAR există și nu e goală
EXISTA="da"
echo ${EXISTA:+"variabila există"}    # "variabila există"
echo ${INEXISTENTA:+"variabila există"}    # nimic
```

### 6.3 Manipulare Stringuri

```bash
TEXT="Hello World"

# Lungime
echo ${#TEXT}    # 11

# Subșir
echo ${TEXT:0:5}     # Hello (de la poziția 0, 5 caractere)
echo ${TEXT:6}       # World (de la poziția 6 până la final)

# Înlocuire
FILE="document.txt"
echo ${FILE%.txt}        # document (șterge .txt de la final)
echo ${FILE##*.}         # txt (păstrează doar extensia)
echo ${FILE/txt/pdf}     # document.pdf (înlocuiește prima potrivire)
echo ${FILE//o/0}        # d0cument.txt (înlocuiește toate)
```

---

## 7. Exerciții Practice

### Exercițiul 1: Variabile de Bază

```bash
# 1. Creează variabile locale
PRENUME="Ion"
NUME="Popescu"
VARSTA=22

# 2. Afișează-le
echo "Nume complet: $PRENUME $NUME"
echo "Vârsta: $VARSTA ani"

# 3. Concatenare
NUME_COMPLET="$PRENUME $NUME"
echo $NUME_COMPLET
```

### Exercițiul 2: Variabile de Mediu

```bash
# 1. Verifică variabilele curente
echo "Home: $HOME"
echo "User: $USER"
echo "Path: $PATH"

# 2. Creează o variabilă de mediu
export PROIECT="SO_Lab"

# 3. Verifică în subshell
bash -c 'echo "Proiect: $PROIECT"'

# 4. Adaugă director la PATH
export PATH="$PATH:$HOME/scripts"
```

### Exercițiul 3: Configurare .bashrc

```bash
# 1. Fă backup la .bashrc
cp ~/.bashrc ~/.bashrc.backup

# 2. Adaugă alias-uri
echo "alias ll='ls -la'" >> ~/.bashrc
echo "alias cls='clear'" >> ~/.bashrc

# 3. Aplică modificările
source ~/.bashrc

# 4. Testează
ll
```

### Exercițiul 4: Prompt Personalizat

```bash
# 1. Salvează prompt-ul curent
OLD_PS1=$PS1

# 2. Testează un prompt nou
PS1='[\t] \u:\W\$ '

# 3. Testează cu culori
PS1='\[\e[32m\]\u\[\e[0m\]:\[\e[34m\]\W\[\e[0m\]\$ '

# 4. Restaurează originalul
PS1=$OLD_PS1
```

---

## 8. Întrebări de Verificare

1. **Care este diferența între variabilă locală și de mediu?**
   > Variabila locală există doar în shell-ul curent. Variabila de mediu (export) este moștenită de subprocese.

2. **Ce fișier se execută la deschiderea unui terminal nou?**
   > `~/.bashrc` pentru shell-uri non-login (terminale grafice).

3. **Cum adaugi permanent un director la PATH?**
   > Adaugi `export PATH="$PATH:/director"` în `~/.bashrc`.

4. **Ce returnează `$?` după o comandă eșuată?**
   > Un număr diferit de zero (codul de eroare specific).

5. **Cum faci ca un alias să fie permanent?**
   > Îl adaugi în `~/.bashrc` și rulezi `source ~/.bashrc`.

---

## Cheat Sheet

```bash
# VARIABILE
VAR="valoare"           # locală
export VAR="valoare"    # de mediu
unset VAR               # șterge
echo $VAR               # afișează

# VARIABILE SPECIALE
$?    # exit code ultima comandă
$$    # PID shell curent
$!    # PID ultimul background
$0    # numele scriptului
$1-$9 # parametri

# VARIABILE SISTEM
$HOME     # director home
$USER     # username
$PATH     # căi executabile
$PWD      # director curent
$SHELL    # shell-ul curent

# ALIAS
alias nume='comanda'
unalias nume
alias                   # listează toate

# CONFIGURARE
~/.bashrc              # config shell
~/.bash_profile        # config login
source ~/.bashrc       # reîncarcă config

# EXPANSIUNE
${VAR:-default}        # valoare implicită
${#VAR}                # lungime string
${VAR:0:5}             # subșir
${VAR%.ext}            # șterge sufix
${VAR/old/new}         # înlocuiește
```

---

## 📤 Finalizare și Trimitere

După ce ai terminat toate cerințele:

1. **Oprește înregistrarea** tastând:
   ```bash
   STOP_tema
   ```
   sau apasă `Ctrl+D`

2. **Așteaptă** - scriptul va:
   - Genera semnătura criptografică
   - Încărca automat fișierul pe server

3. **Verifică mesajul final**:
   - ✅ `ÎNCĂRCARE REUȘITĂ!` - tema a fost trimisă
   - ❌ Dacă upload-ul eșuează, fișierul `.cast` este salvat local - trimite-l manual mai târziu cu comanda afișată

> ⚠️ **NU modifica fișierul `.cast`** după generare - semnătura devine invalidă!

---

*By Revolvix for OPERATING SYSTEMS class | restricted licence 2017-2030*
