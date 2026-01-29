# S04_TC02 - Familia GREP - Căutare Text

> **Sisteme de Operare** | ASE București - CSIE  
> Material de laborator - Seminar 4 (Redistribuit)

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
- Căute eficient în fișiere text cu grep
- Folosească expresii regulate în căutări
- Combine grep cu alte comenzi în pipeline-uri
- Aleagă varianta potrivită (grep, egrep, fgrep)

---


## 2. Sintaxa de Bază

```bash
grep [opțiuni] 'pattern' [fișiere]
grep [opțiuni] -e 'pattern1' -e 'pattern2' [fișiere]
grep [opțiuni] -f pattern_file [fișiere]
```

---

## 3. Opțiuni Principale

### 3.1 Opțiuni de Matching

```bash
-i, --ignore-case       # Case-insensitive
-w, --word-regexp       # Cuvânt întreg
-x, --line-regexp       # Linie întreagă
-v, --invert-match      # Inversează (linii care NU conțin)
-e PATTERN              # Multiple pattern-uri
-f FILE                 # Pattern-uri din fișier
```

### 3.2 Opțiuni de Output

```bash
-n, --line-number       # Afișează numerele de linie
-c, --count             # Numără potrivirile
-l, --files-with-matches    # Doar numele fișierelor cu potriviri
-L, --files-without-match   # Fișiere FĂRĂ potriviri
-o, --only-matching     # Afișează doar partea care se potrivește
-m NUM                  # Oprește după NUM potriviri
-q, --quiet             # Silent (doar exit code)
```

### 3.3 Opțiuni de Context

```bash
-A NUM, --after-context=NUM     # NUM linii după match
-B NUM, --before-context=NUM    # NUM linii înainte de match
-C NUM, --context=NUM           # NUM linii înainte și după
```

### 3.4 Opțiuni pentru Fișiere

```bash
-r, --recursive         # Caută recursiv în directoare
-R, --dereference-recursive  # Recursiv, urmează symlinks
--include=GLOB          # Doar fișiere care se potrivesc
--exclude=GLOB          # Exclude fișiere
--exclude-dir=DIR       # Exclude directoare
```

---

## 4. Exemple Practice

### 4.1 Căutări de Bază

```bash
# Căutare simplă
grep 'error' log.txt

# Case-insensitive
grep -i 'error' log.txt

# Cuvânt întreg
grep -w 'the' text.txt          # nu găsește "there", "other"

# Linii care NU conțin pattern
grep -v 'debug' log.txt

# Cu numere de linie
grep -n 'error' log.txt
```

### 4.2 Multiple Pattern-uri

```bash
# Cu -e
grep -e 'error' -e 'warning' log.txt

# Cu ERE și |
grep -E 'error|warning|fatal' log.txt

# Din fișier
echo -e "error\nwarning" > patterns.txt
grep -f patterns.txt log.txt
```

### 4.3 Context

```bash
# 3 linii după match
grep -A 3 'Exception' log.txt

# 2 linii înainte
grep -B 2 'Error' log.txt

# 2 linii înainte și după
grep -C 2 'failure' log.txt
```

### 4.4 Căutare Recursivă

```bash
# Recursiv în toate fișierele
grep -r 'TODO' .

# Doar în fișiere .py
grep -r --include='*.py' 'import' .

# Exclude directoare
grep -r --exclude-dir='.git' --exclude-dir='node_modules' 'pattern' .

# Doar numele fișierelor
grep -rl 'pattern' .
```

### 4.5 Contorizare și Statistici

```bash
# Număr de potriviri
grep -c 'error' log.txt

# Număr de potriviri per fișier
grep -c 'error' *.log

# Fișiere cu potriviri
grep -l 'error' *.log

# Fișiere fără potriviri
grep -L 'error' *.log
```

---

## 5. Pattern-uri Regex în GREP

### 5.1 BRE (Basic)

```bash
grep '^Start' file.txt          # începe cu "Start"
grep 'end$' file.txt            # se termină cu "end"
grep '^$' file.txt              # linii goale
grep 'a.*b' file.txt            # a, orice, b
grep '[0-9]' file.txt           # conține cifră
grep 'ab\+c' file.txt           # ab+c (escape pentru +)
```

### 5.2 ERE (Extended)

```bash
grep -E 'ab+c' file.txt         # ab+c
grep -E 'colou?r' file.txt      # color sau colour
grep -E '(error|warn)' file.txt # error sau warn
grep -E '[0-9]{3}' file.txt     # 3 cifre consecutive
grep -E '\b[A-Z]+\b' file.txt   # cuvinte în uppercase
```

### 5.3 Exemple Utile

```bash
# Email
grep -E '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' file.txt

# IP Address
grep -E '([0-9]{1,3}\.){3}[0-9]{1,3}' log.txt

# URL
grep -E 'https?://[^ ]+' file.txt

# Linii cu comentarii (# sau //)
grep -E '^[[:space:]]*(#|//)' code.txt
```

---

## 6. Grep în Pipeline-uri

```bash
# Filtrare output
ps aux | grep nginx
dmesg | grep -i error

# Combinare cu alte comenzi
cat access.log | grep '404' | wc -l
grep -l 'pattern' *.txt | xargs rm

# Extragere și numărare
grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' access.log | sort | uniq -c | sort -rn

# Excludere procese grep din ps
ps aux | grep '[n]ginx'         # [n]ginx nu se potrivește cu "grep nginx"
```

---

## 7. Exit Codes

```bash
# Exit codes
# 0 - găsit potriviri
# 1 - nu a găsit potriviri
# 2 - eroare

# Utilizare în scripturi
if grep -q 'pattern' file.txt; then
    echo "Găsit"
else
    echo "Nu găsit"
fi
```

---

## 8. Exerciții Practice

### Exercițiul 1: Căutări de Bază
```bash
# Găsește liniile cu "error" (case-insensitive)
grep -i 'error' /var/log/syslog

# Numără câte erori sunt
grep -ci 'error' /var/log/syslog

# Afișează 3 linii context
grep -C 3 -i 'error' /var/log/syslog
```

### Exercițiul 2: Căutare în Cod
```bash
# Găsește toate funcțiile în fișiere Python
grep -rn 'def ' --include='*.py' .

# TODO-uri și FIXME-uri
grep -rn -E '(TODO|FIXME)' --include='*.py' .
```

### Exercițiul 3: Analiza Log-uri
```bash
# Top 10 IP-uri din access.log
grep -oE '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' access.log | sort | uniq -c | sort -rn | head -10
```

---

## Cheat Sheet

```bash
# MATCHING
-i          case-insensitive
-w          cuvânt întreg
-x          linie întreagă
-v          inversează
-e PATTERN  multiple pattern-uri

# OUTPUT
-n          numere de linie
-c          numără
-l          doar fișiere cu match
-L          fișiere fără match
-o          doar match

# CONTEXT
-A N        N linii după
-B N        N linii înainte
-C N        N linii context

# FIȘIERE
-r          recursiv
--include=  doar anumite fișiere
--exclude=  exclude fișiere

# TIPURI REGEX
grep        BRE
grep -E     ERE (egrep)
grep -F     fixed string (fgrep)
grep -P     PCRE

# EXEMPLE
grep -rn 'pattern' .
grep -E 'a|b|c' file
grep -v '^#' config
grep -c 'error' *.log
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
