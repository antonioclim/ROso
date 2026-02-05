# S01_TC03 - Variabile Shell

> **Sisteme de Operare** | ASE București - CSIE  
> Material de laborator - Seminar 1 (MUTAT din SEM02)

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
- Creeze și folosească variabile în scripturi Bash
- Înțeleagă diferența dintre variabile locale și de mediu
- Folosească variabilele speciale și parametrii

---


## 2. Variabile de Mediu

### 2.1 export

```bash
# Variabilă locală (doar shell curent)
LOCAL_VAR="local"

# Variabilă de mediu (moștenită de subprocese)
export ENV_VAR="exportată"

# Verificare
bash -c 'echo "Local: $LOCAL_VAR"'      # gol
bash -c 'echo "Env: $ENV_VAR"'          # "exportată"

# Export în aceeași comandă
export PATH="$PATH:/nou/director"
```

### 2.2 Variabile de Mediu Importante

```bash
echo $HOME          # /home/student
echo $USER          # student
echo $PATH          # căi executabile
echo $PWD           # director curent
echo $OLDPWD        # director anterior
echo $SHELL         # /bin/bash
echo $LANG          # ro_RO.UTF-8
echo $TERM          # tip terminal
echo $EDITOR        # editor implicit
```

---

## 3. Variabile Speciale

| Variabilă | Descriere |
|-----------|-----------|
| `$?` | Exit code ultima comandă |
| `$$` | PID shell curent |
| `$!` | PID ultim proces background |
| `$0` | Numele scriptului |
| `$1-$9` | Parametrii poziționali |
| `${10}` | Parametrul 10+ |
| `$#` | Numărul de parametri |
| `$@` | Toți parametrii (ca listă) |
| `$*` | Toți parametrii (ca string) |

```bash
#!/bin/bash
echo "Script: $0"
echo "Primul argument: $1"
echo "Al doilea: $2"
echo "Număr argumente: $#"
echo "Toate: $@"

# Rulare: ./script.sh arg1 arg2 arg3
```

---

## 4. Substituție și Manipulare

### 4.1 Valori Implicite

```bash
# ${VAR:-default} - folosește default dacă VAR nu e setată
echo ${NEDEFINITA:-"valoare implicită"}

# ${VAR:=default} - setează ȘI folosește default
echo ${DIRECTOR:="/tmp"}
echo $DIRECTOR           # /tmp

# ${VAR:+altceva} - folosește altceva doar dacă VAR e setată
FILE="test.txt"
echo ${FILE:+"fișierul există"}

# ${VAR:?mesaj} - eroare dacă VAR nu e setată
echo ${OBLIGATORIE:?"Variabila lipsește!"}
```

### 4.2 Manipulare Stringuri

```bash
TEXT="Hello World"

# Lungime
echo ${#TEXT}               # 11

# Subșir
echo ${TEXT:0:5}            # Hello
echo ${TEXT:6}              # World
echo ${TEXT: -3}            # rld (ultimele 3, spațiu obligatoriu)

# Înlocuire
FILE="document.txt"
echo ${FILE%.txt}           # document (șterge .txt de la final)
echo ${FILE##*.}            # txt (extensia)
echo ${FILE/txt/pdf}        # document.pdf (prima potrivire)
echo ${FILE//o/0}           # d0cument.txt (toate)

# Pattern-uri
# ${var#pattern} - șterge cea mai scurtă potrivire de la început
# ${var##pattern} - șterge cea mai lungă potrivire de la început
# ${var%pattern} - șterge cea mai scurtă potrivire de la final
# ${var%%pattern} - șterge cea mai lungă potrivire de la final
```

### 4.3 modificări (Bash 4+)

```bash
TEXT="Hello World"

echo ${TEXT^^}              # HELLO WORLD (uppercase)
echo ${TEXT,,}              # hello world (lowercase)
echo ${TEXT^}               # Hello world (prima literă)
```

---

## 5. Array-uri

### 5.1 Array Indexat

```bash
# Definire
CULORI=("roșu" "verde" "albastru")
NUMERE=(1 2 3 4 5)

# Acces
echo ${CULORI[0]}           # roșu
echo ${CULORI[1]}           # verde
echo ${CULORI[@]}           # toate elementele
echo ${#CULORI[@]}          # numărul de elemente (3)

# Adăugare
CULORI+=("galben")

# Iterare
for culoare in "${CULORI[@]}"; do
    echo "$culoare"
done
```

### 5.2 Array Asociativ (Bash 4+)

```bash
# Declarare obligatorie
declare -A CAPITALA

# Populare
CAPITALA["România"]="București"
CAPITALA["Franța"]="Paris"
CAPITALA["Germania"]="Berlin"

# Acces
echo ${CAPITALA["România"]}

# Toate cheile
echo ${!CAPITALA[@]}

# Iterare
for tara in "${!CAPITALA[@]}"; do
    echo "$tara: ${CAPITALA[$tara]}"
done
```

---

## 6. Citire Input

```bash
# read de bază
echo "Cum te cheamă?"
read NUME
echo "Salut, $NUME!"

# Cu prompt (-p)
read -p "Vârsta: " VARSTA

# Silent (pentru parole) (-s)
read -sp "Parolă: " PAROLA
echo

# Cu timeout (-t)
read -t 5 -p "Răspunde în 5 secunde: " RASPUNS

# Într-un array (-a)
read -a ELEMENTE <<< "unu doi trei"
echo ${ELEMENTE[1]}         # doi

# Multiple variabile
read VAR1 VAR2 VAR3 <<< "a b c"
```

---

## 7. Exerciții Practice

### Exercițiul 1: Variabile de Bază

```bash
#!/bin/bash
NUME="Student"
CURS="Sisteme de Operare"
AN=2025

echo "Bine ai venit, $NUME!"
echo "Curs: $CURS"
echo "Anul: $AN"
```

### Exercițiul 2: Variabile Speciale

```bash
#!/bin/bash
echo "Scriptul: $0"
echo "Argumente: $#"
echo "Primul: $1"
echo "Toate: $@"
echo "PID: $$"
```

### Exercițiul 3: Manipulare Stringuri

```bash
FILE="/home/student/document.txt"

echo "Calea completă: $FILE"
echo "Numele fișierului: ${FILE##*/}"
echo "Directorul: ${FILE%/*}"
echo "Extensia: ${FILE##*.}"
echo "Fără extensie: ${FILE%.*}"
```

### Exercițiul 4: Array-uri

```bash
#!/bin/bash
FRUCTE=("măr" "pară" "banană" "portocală")

echo "Total fructe: ${#FRUCTE[@]}"
echo "Primul: ${FRUCTE[0]}"

for fruct in "${FRUCTE[@]}"; do
    echo "- $fruct"
done
```

---

## Cheat Sheet

```bash
# DEFINIRE
VAR="valoare"           # locală
export VAR="valoare"    # de mediu
unset VAR               # șterge
readonly VAR="const"    # constantă

# SPECIALE
$?    # exit code
$$    # PID curent
$!    # PID background
$0    # nume script
$1-$9 # parametri
$#    # nr. parametri
$@    # toți parametrii

# VALORI IMPLICITE
${VAR:-default}         # default dacă nu există
${VAR:=default}         # setează default
${VAR:+alt}             # alt dacă există

# STRINGURI
${#VAR}                 # lungime
${VAR:start:len}        # subșir
${VAR/old/new}          # înlocuire
${VAR%pattern}          # șterge de la final
${VAR#pattern}          # șterge de la început
${VAR^^}                # UPPERCASE
${VAR,,}                # lowercase

# ARRAY
ARR=(a b c)             # definire
${ARR[0]}               # element
${ARR[@]}               # toate
${#ARR[@]}              # lungime
ARR+=(d)                # adaugă

# CITIRE
read VAR                # input
read -p ":" VAR         # cu prompt
read -s VAR             # silent
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
