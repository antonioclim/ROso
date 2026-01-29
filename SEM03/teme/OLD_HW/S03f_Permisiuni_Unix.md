# S03_TC05 - Permisiuni Fișiere și Ownership

> **Sisteme de Operare** | ASE București - CSIE  
> Material de laborator - Seminar 3 (Redistribuit)

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
- Înțeleagă sistemul de permisiuni Unix
- Modifice permisiunile cu chmod (octal și simbolic)
- Gestioneze ownership cu chown și chgrp
- Folosească permisiuni speciale (SUID, SGID, Sticky)

---


## 2. Vizualizarea Permisiunilor

```bash
# Listare cu permisiuni
ls -l fisier.txt
ls -la                    # include fișiere ascunse
ls -ld director/          # permisiuni director (nu conținut)

# Interpretare output
# -rw-r--r-- = 644
#
# others: r-- = 4 (read only)
# group: r-- = 4 (read only)
# owner: rw- = 6 (read + write)

# Informații detaliate
stat fisier.txt
stat -c "%a %U:%G %n" fisier.txt    # format personalizat
```

---

## 3. chmod - Modificarea Permisiunilor

### 3.1 Modul Octal (Numeric)

```bash
# Format: chmod [opțiuni] NNN fișier
# NNN = 3 cifre octale (owner, group, others)

# Exemple comune
chmod 755 script.sh     # rwxr-xr-x (executabil)
chmod 644 document.txt  # rw-r--r-- (document)
chmod 600 secret.txt    # rw------- (privat)
chmod 700 private/      # rwx------ (director privat)
chmod 777 public/       # rwxrwxrwx (acces total - EVITĂ!)

# Calculare octal
# r=4, w=2, x=1
# rwx = 4+2+1 = 7
# rw- = 4+2+0 = 6
# r-x = 4+0+1 = 5
# r-- = 4+0+0 = 4
```

### 3.2 Modul Simbolic

```bash
# Format: chmod [ugoa][+-=][rwxXst] fișier

# Operatori
# + adaugă permisiune
# - elimină permisiune
# = setează exact

# Exemple
chmod u+x script.sh         # adaugă execute pentru owner
chmod g-w fisier.txt        # elimină write pentru group
chmod o=r fisier.txt        # setează others la doar read
chmod a+r fisier.txt        # adaugă read pentru toți
chmod u=rwx,g=rx,o=r f.txt  # setare completă
chmod go-rwx private.txt    # elimină totul pentru group și others

# Recursive
chmod -R 755 director/      # aplică recursiv
chmod -R u+rwX,go+rX dir/   # X = execute doar pentru directoare
```

### 3.3 Permisiuni pentru Directoare

```bash
# Director accesibil
chmod 755 public/           # Toți pot lista și accesa

# Director privat
chmod 700 private/          # Doar owner poate accesa

# Director shared (grup)
chmod 775 shared/           # Owner și grup pot modifica

# Director read-only
chmod 555 readonly/         # Nimeni nu poate modifica
```

---

## 4. chown și chgrp - Modificarea Ownership

### 4.1 chown - Change Owner

```bash
# Format: chown [opțiuni] owner[:group] fișier

# Schimbă owner
sudo chown john fisier.txt

# Schimbă owner și group
sudo chown john:developers fisier.txt

# Doar group (cu :)
sudo chown :developers fisier.txt

# Recursiv
sudo chown -R john:developers proiect/

# Verbose
sudo chown -v john fisier.txt

# Reference (copiază de la alt fișier)
sudo chown --reference=model.txt target.txt
```

### 4.2 chgrp - Change Group

```bash
# Format: chgrp [opțiuni] group fișier

chgrp developers fisier.txt
chgrp -R developers proiect/
```

### 4.3 Verificare Grupuri

```bash
# Grupurile utilizatorului curent
groups
groups username

# Toate grupurile din sistem
cat /etc/group

# Adăugare utilizator la grup (admin)
sudo usermod -aG developers john
```

---

## 5. umask - Masca de Permisiuni Default

### 5.1 Cum Funcționează

```bash
# umask definește ce permisiuni se ELIMINĂ de la default
# Default fișiere: 666 (rw-rw-rw-)
# Default directoare: 777 (rwxrwxrwx)

# Calculare permisiuni efective:
# Fișiere: 666 - umask
# Directoare: 777 - umask

# Exemplu cu umask 022:
# Fișiere: 666 - 022 = 644 (rw-r--r--)
# Directoare: 777 - 022 = 755 (rwxr-xr-x)

# Exemplu cu umask 077:
# Fișiere: 666 - 077 = 600 (rw-------)
# Directoare: 777 - 077 = 700 (rwx------)
```

### 5.2 Setare umask

```bash
# Verifică umask curent
umask           # afișează în octal
umask -S        # afișează simbolic

# Setare temporară
umask 022       # default comun
umask 077       # foarte restrictiv
umask 002       # permisiv pentru grup

# Setare permanentă (în ~/.bashrc)
echo "umask 022" >> ~/.bashrc
```

---

## 6. Permisiuni Speciale

### 6.1 SUID (Set User ID) - 4xxx

```bash
# Fișierul se execută cu permisiunile owner-ului
# Afișat ca 's' în loc de 'x' pentru owner

chmod u+s program           # setează SUID
chmod 4755 program          # octal

# Exemplu: passwd
ls -l /usr/bin/passwd
# -rwsr-xr-x 1 root root ... /usr/bin/passwd
# Oricine poate schimba parola (necesită acces la /etc/shadow)

# Verificare SUID
find / -perm -4000 2>/dev/null
```

### 6.2 SGID (Set Group ID) - 2xxx

```bash
# Pe fișiere: execută cu permisiunile grupului
# Pe directoare: fișierele noi moștenesc grupul directorului

chmod g+s director/         # setează SGID
chmod 2775 shared/          # octal

# Exemplu: director de proiect shared
mkdir /projects/team1
chgrp developers /projects/team1
chmod 2775 /projects/team1
# Toate fișierele noi vor aparține grupului "developers"
```

### 6.3 Sticky Bit - 1xxx

```bash
# Pe directoare: doar owner-ul poate șterge fișierele proprii
# Afișat ca 't' în loc de 'x' pentru others

chmod +t /tmp               # setează sticky
chmod 1777 /tmp             # octal

# Exemplu: /tmp
ls -ld /tmp
# drwxrwxrwt 15 root root ... /tmp
# 't' indică sticky bit

# Verificare sticky
find / -perm -1000 2>/dev/null
```

### 6.4 Rezumat Permisiuni Speciale

| Bit | Octal | Pe Fișier | Pe Director |
|-----|-------|-----------|-------------|
| SUID | 4000 | Execută ca owner | - |
| SGID | 2000 | Execută ca group | Moștenire grup |
| Sticky | 1000 | - | Doar owner șterge |

```bash
# Exemple octale
chmod 4755 file     # SUID + rwxr-xr-x
chmod 2775 dir      # SGID + rwxrwxr-x
chmod 1777 dir      # Sticky + rwxrwxrwx
chmod 6755 file     # SUID + SGID + rwxr-xr-x
```

---

## 7. Exerciții Practice

### Exercițiul 1: Permisiuni de Bază
```bash
# Creează fișiere test
touch public.txt private.txt script.sh

# Setează permisiuni
chmod 644 public.txt      # rw-r--r--
chmod 600 private.txt     # rw-------
chmod 755 script.sh       # rwxr-xr-x

# Verifică
ls -l
```

### Exercițiul 2: Director Shared
```bash
# Creează director pentru echipă
sudo mkdir /shared
sudo chgrp developers /shared
sudo chmod 2775 /shared

# Testează
touch /shared/test.txt
ls -l /shared/
```

### Exercițiul 3: umask
```bash
# Salvează umask curent
OLD_UMASK=$(umask)

# Testează diferite valori
umask 077
touch restrictiv.txt
ls -l restrictiv.txt

umask 022
touch normal.txt
ls -l normal.txt

# Restaurează
umask $OLD_UMASK
```

---

## 8. Întrebări de Verificare

1. **Ce înseamnă permisiunea 755 pentru un director?**
   > Owner: rwx (full), Group: r-x (list+enter), Others: r-x (list+enter)

2. **De ce este nevoie de permisiunea x pe un director?**
   > Pentru a putea accesa (cd) directorul și fișierele din el.

3. **Ce face SGID pe un director?**
   > Fișierele noi moștenesc automat grupul directorului.

4. **La ce folosește Sticky Bit pe /tmp?**
   > Previne ștergerea fișierelor altora, deși directorul e world-writable.

5. **Ce permisiuni va avea un fișier nou cu umask 027?**
   > 666 - 027 = 640 (rw-r-----)

---

## Cheat Sheet

```bash
# CHMOD OCTAL
chmod 755 file      # rwxr-xr-x
chmod 644 file      # rw-r--r--
chmod 600 file      # rw-------
chmod 700 dir       # rwx------

# CHMOD SIMBOLIC
chmod u+x file      # +execute owner
chmod g-w file      # -write group
chmod o=r file      # others=read
chmod a+r file      # +read all
chmod -R 755 dir/   # recursiv

# OWNERSHIP
chown user file
chown user:group file
chown -R user:group dir/
chgrp group file

# UMASK
umask               # afișează
umask 022           # setează
umask -S            # simbolic

# SPECIALE
chmod u+s file      # SUID (4xxx)
chmod g+s dir       # SGID (2xxx)
chmod +t dir        # Sticky (1xxx)

# FIND BY PERMISSIONS
find . -perm 644
find . -perm -4000  # SUID files
find . -perm /u+x   # owner executable
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
