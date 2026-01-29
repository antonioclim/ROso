# S05_TC02 - Arrays în Bash

> **Sisteme de Operare** | ASE București - CSIE  
> Material de laborator - Seminar 5 (SPLIT din TC6a)

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
- Lucreze cu arrays indexate (0-based)
- Lucreze cu arrays asociative (hash maps)
- Itereze și manipuleze arrays eficient
- Implementeze structuri de date în Bash

---


## 2. Iterare Arrays

### 2.1 Prin Valori

```bash
arr=(alpha beta gamma)

for item in "${arr[@]}"; do
    echo "Item: $item"
done

# IMPORTANT: ghilimelele "${arr[@]}" păstrează elementele cu spații
arr=("first item" "second item")
for item in "${arr[@]}"; do
    echo "-> $item"
done
```

### 2.2 Prin Indici

```bash
arr=(alpha beta gamma)

for i in "${!arr[@]}"; do
    echo "[$i] = ${arr[$i]}"
done

# Output:
# [0] = alpha
# [1] = beta
# [2] = gamma
```

### 2.3 Stil C

```bash
arr=(alpha beta gamma)

for ((i=0; i<${#arr[@]}; i++)); do
    echo "[$i] = ${arr[$i]}"
done
```

---

## 3. Operații pe Arrays

### 3.1 Căutare

```bash
arr=(apple banana cherry)

# Verificare existență
if [[ " ${arr[@]} " =~ " banana " ]]; then
    echo "Găsit!"
fi

# Găsire index
find_index() {
    local needle="$1"
    shift
    local arr=("$@")
    for i in "${!arr[@]}"; do
        if [[ "${arr[$i]}" == "$needle" ]]; then
            echo "$i"
            return 0
        fi
    done
    return 1
}

idx=$(find_index "banana" "${arr[@]}")
echo "Index: $idx"  # 1
```

### 3.2 Sortare

```bash
arr=(delta alpha gamma beta)

# Sortare cu sort
sorted=($(printf '%s\n' "${arr[@]}" | sort))
echo "${sorted[@]}"  # alpha beta delta gamma

# Sortare numerică
nums=(10 2 5 1 20)
sorted=($(printf '%s\n' "${nums[@]}" | sort -n))
echo "${sorted[@]}"  # 1 2 5 10 20
```

### 3.3 Reverse

```bash
arr=(a b c d e)
reversed=()

for ((i=${#arr[@]}-1; i>=0; i--)); do
    reversed+=("${arr[$i]}")
done

echo "${reversed[@]}"  # e d c b a
```

### 3.4 Filtru

```bash
nums=(1 2 3 4 5 6 7 8 9 10)
even=()

for n in "${nums[@]}"; do
    (( n % 2 == 0 )) && even+=("$n")
done

echo "Even: ${even[@]}"  # 2 4 6 8 10
```

### 3.5 Map (Transform)

```bash
arr=(apple banana cherry)
upper=()

for item in "${arr[@]}"; do
    upper+=("${item^^}")  # uppercase
done

echo "${upper[@]}"  # APPLE BANANA CHERRY
```

---

## 4. Arrays Asociative (Hash Maps)

### 4.1 Declarare și Populare

```bash
# OBLIGATORIU: declare -A
declare -A config

# Populare element cu element
config[host]="localhost"
config[port]="8080"
config[user]="admin"

# Sau tot odată
declare -A config=(
    [host]="localhost"
    [port]="8080"
    [user]="admin"
)
```

### 4.2 Acces

```bash
declare -A config=([host]="localhost" [port]="8080")

# Element
echo ${config[host]}        # localhost

# Toate valorile
echo ${config[@]}           # localhost 8080

# Toate cheile
echo ${!config[@]}          # host port

# Număr de elemente
echo ${#config[@]}          # 2

# Default value
echo ${config[missing]:-default}  # default
```

### 4.3 Verificare Existență

```bash
declare -A config=([host]="localhost")

# Verificare cheie (Bash 4.3+)
if [[ -v config[host] ]]; then
    echo "Host is set"
fi

# Alternativă pentru versiuni mai vechi
if [[ -n "${config[host]+isset}" ]]; then
    echo "Host is set"
fi
```

### 4.4 Iterare

```bash
declare -A config=([host]="localhost" [port]="8080" [user]="admin")

# Prin chei
for key in "${!config[@]}"; do
    echo "$key = ${config[$key]}"
done

# Sortate
for key in $(echo "${!config[@]}" | tr ' ' '\n' | sort); do
    echo "$key = ${config[$key]}"
done
```

### 4.5 Modificare și Ștergere

```bash
declare -A config=([host]="localhost")

# Modificare
config[host]="127.0.0.1"

# Adăugare
config[timeout]="30"

# Ștergere cheie
unset config[timeout]

# Ștergere tot
unset config
# sau
declare -A config=()
```

---

## 5. Exemple Practice

### 5.1 Contorizare Cuvinte

```bash
declare -A word_count

# Citire și contorizare
while read -r word; do
    ((word_count[$word]++))
done < <(tr -cs '[:alpha:]' '\n' < text.txt | tr '[:upper:]' '[:lower:]')

# Afișare sortată
for word in "${!word_count[@]}"; do
    echo "${word_count[$word]} $word"
done | sort -rn | head -10
```

### 5.2 Config Parser

```bash
declare -A CONFIG

parse_config() {
    local file="$1"
    while IFS='=' read -r key value; do
        # Skip comentarii și linii goale
        [[ "$key" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$key" ]] && continue
        
        # Trim whitespace
        key="${key// /}"
        value="${value// /}"
        
        CONFIG["$key"]="$value"
    done < "$file"
}

get_config() {
    local key="$1"
    local default="${2:-}"
    echo "${CONFIG[$key]:-$default}"
}

# Utilizare
parse_config "app.conf"
echo "Host: $(get_config host localhost)"
echo "Port: $(get_config port 8080)"
```

### 5.3 Stack Implementation

```bash
declare -a STACK=()

push() { STACK+=("$1"); }

pop() {
    (( ${#STACK[@]} == 0 )) && { echo "Empty" >&2; return 1; }
    echo "${STACK[-1]}"
    unset 'STACK[-1]'
}

peek() { echo "${STACK[-1]:-}"; }

is_empty() { (( ${#STACK[@]} == 0 )); }

# Test
push "a"
push "b"
push "c"
echo "Pop: $(pop)"   # c
echo "Peek: $(peek)" # b
```

### 5.4 Simple Cache

```bash
declare -A cache

cached_curl() {
    local url="$1"
    
    if [[ -v cache[$url] ]]; then
        echo "${cache[$url]}"
        return
    fi
    
    local result
    result=$(curl -s "$url")
    cache[$url]="$result"
    
    echo "$result"
}
```

---

## 6. Exerciții

### Exercițiul 1
Implementați o funcție `array_unique` care elimină duplicatele dintr-un array.

### Exercițiul 2
Creați un script care citește un CSV și stochează datele într-un array asociativ.

### Exercițiul 3
Implementați o structură Queue (FIFO) folosind arrays.

---

## Cheat Sheet

```bash
# ARRAYS INDEXATE
arr=(a b c)
${arr[0]}           # element
${arr[@]}           # toate (ca listă)
${#arr[@]}          # lungime
${!arr[@]}          # indici
${arr[@]:1:2}       # slice
arr+=(d)            # append
unset arr[1]        # șterge element

# ARRAYS ASOCIATIVE
declare -A hash
hash[key]="value"
${hash[key]}        # acces
${!hash[@]}         # toate cheile
${hash[@]}          # toate valorile
[[ -v hash[key] ]]  # verifică existență
unset hash[key]     # șterge

# ITERARE
for item in "${arr[@]}"; do ...; done
for key in "${!hash[@]}"; do echo "$key=${hash[$key]}"; done

# OPERAȚII
sorted=($(printf '%s\n' "${arr[@]}" | sort))
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
