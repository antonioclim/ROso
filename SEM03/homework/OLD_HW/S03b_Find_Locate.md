# S03_TC01 - Find și Locate

> **Sisteme de Operare** | ASE București - CSIE  
> Material de laborator - Seminar 3 (SPLIT din TC2e - Redistribuit)

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
- Folosească comanda `find` pentru căutări complexe de fișiere
- Folosească `locate` pentru căutări rapide în baza de date
- Înțeleagă diferențele dintre find și locate
- Combine criteriile de căutare eficient

---



## 2. Comanda locate


### 2.2 Actualizarea Bazei de Date

```bash

# Căutare rapidă în baza de date
locate filename
locate "*.pdf"


# Case-insensitive
locate -i README


# Limitare rezultate
locate -n 10 "*.log"


# CĂUTARE TIP
find . -type f            # fișiere
find . -type d            # directoare
find . -type l            # symlinks


### 2.1 Utilizare de Bază

```bash

# Actualizare manuală (necesită root)
sudo updatedb


# Verificare când a fost ultima actualizare
stat /var/lib/mlocate/mlocate.db
```


### 2.3 Comparație locate vs find

| Aspect | locate | find |
|--------|--------|------|
| Viteză | Foarte rapid | Mai lent |
| Actualizare | Necesită updatedb | Timp real |
| Criterii | Doar nume | Multe criterii |
| Acțiuni | Doar afișare | Multiple acțiuni |
| Resurse | Folosește baza de date indexată | Parcurge filesystem |

---


## 3. Utilitare Complementare


### 3.1 which și whereis

```bash
which python            # calea executabilului
which -a python         # toate versiunile din PATH

whereis ls              # binare, surse, manuale
whereis -b python       # doar binare
```


### 3.2 type și file

```bash
type cd                 # shell builtin
type ls                 # /usr/bin/ls
type ll                 # alias

file document.pdf       # PDF document
file script.sh          # shell script
file /bin/ls            # ELF executable
```

---


## 4. Exerciții Practice


### Exercițiul 1: Căutări cu find
```bash

# Fișiere .log mai mari de 10MB
find /var/log -type f -name "*.log" -size +10M


# Fișiere modificate în ultimele 24h
find ~ -type f -mtime 0


# Șterge fișiere temporare vechi
find /tmp -type f -name "*.tmp" -mtime +7 -delete
```


### Exercițiul 2: Găsește și procesează
```bash

# Toate scripturile fără permisiune de execuție
find . -name "*.sh" ! -perm /111


# Directoare goale pentru cleanup
find . -type d -empty -print


# Fișiere duplicate după dimensiune
find . -type f -printf '%s %p\n' | sort -n | uniq -D -w 10
```

---


## Cheat Sheet Find

```bash

# CĂUTARE DIMENSIUNE
find . -size +10M         # > 10MB
find . -size -1k          # < 1KB
find . -empty             # goale


# CĂUTARE NUME
find . -name "*.txt"      # exact
find . -iname "*.txt"     # case-insensitive
find . -path "*dir*"      # în calea completă


# SIZE SEARCH
find . -size +10M         # > 10MB
find . -size -1k          # < 1KB
find . -empty             # empty


# TIME SEARCH
find . -mtime -7          # last 7 days
find . -mmin -60          # last hour
find . -newer file        # newer than file


# ACȚIUNI
find . -exec cmd {} \;    # execută per fișier
find . -exec cmd {} +     # execută batch
find . -delete            # șterge
find . -print0            # output null-delimited
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

