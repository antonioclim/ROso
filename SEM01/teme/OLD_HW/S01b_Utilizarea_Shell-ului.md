# S01_TC01 - Utilizarea Shell-ului

> Sisteme de Operare | ASE București - CSIE  
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
- Interacționeze cu shell-ul și să execute comenzi din linia de comandă
- Folosească comenzi simple și secvențe de comenzi pentru sarcini de bază
- Înțeleagă rolul kernel-ului, shell-ului și sistemului de fișiere

---


## 1. Teorie

### 1.1 Introducere în Linux

**Linux** este, tehnic vorbind, **kernel-ul** sistemului - controlerul central al tot ce se întâmplă pe calculator. Când cineva spune că "rulează Linux", se referă de regulă la kernel împreună cu suita de unelte care vin cu el (numită distribuție).

> UNIX vs Linux: UNIX a fost dezvoltat la AT&T Bell Labs în anii 1970. Linux nu este oficial UNIX (nu a fost certificat de Open Group), dar este UNIX-like - adoptă majoritatea specificațiilor UNIX.

### 1.2 Rolul Kernel-ului

Cele trei componente principale ale unui sistem de operare sunt:

```
┌─────────────────────────────────────────┐
│           APLICAȚII (User Space)        │
├─────────────────────────────────────────┤
│              SHELL (Bash)               │
├─────────────────────────────────────────┤
│              KERNEL (Linux)             │
├─────────────────────────────────────────┤
│        HARDWARE (CPU, RAM, Disk)        │
└─────────────────────────────────────────┘
```

Kernel-ul funcționează ca un controlor de trafic aerian:

- Alocă memorie - decide ce program primește ce bucată de memorie
- Gestionează procesele - pornește și oprește programe
- Interpretează instrucțiuni - de la utilizator către hardware
- Multitasking preemptiv - comută rapid între sarcini, creând iluzia execuției simultane

### 1.3 Aplicații și Procese

```
Aplicație ──► Cerere către Kernel ──► Resurse (CPU, RAM, Disk)
                    │
                    ▼
              Kernel API
         (abstracție hardware)
```

Un proces este o sarcină încărcată și urmărită de kernel. O aplicație poate avea mai multe procese.

### 1.4 Open Source și Licențiere

| Aspect | Closed Source | Open Source |
|--------|---------------|-------------|
| Cod sursă | Ascuns | Disponibil |
| Modificări | Interzise | Permise |
| Redistribuire | Restricționată | Liberă (cu condiții) |

GPL (GNU Public License) - licența Linux-ului - impune ca modificările să fie făcute publice.

### 1.5 Distribuții Linux

```
                    LINUX KERNEL
                         │
           ┌─────────────┴─────────────┐
           │                           │
      RED HAT                      DEBIAN
           │                           │
    ┌──────┼──────┐             ┌──────┼──────┐
    │      │      │             │      │      │
  RHEL  Fedora  CentOS      Ubuntu  Mint  Kali
```

| Familie | Package Manager | Format | Exemplu comandă |
|---------|-----------------|--------|-----------------|
| Red Hat | rpm/dnf/yum | `.rpm` | `dnf install htop` |
| Debian | apt/dpkg | `.deb` | `apt install htop` |

---

## 2. Shell-ul Bash

### 2.1 Ce este Shell-ul?

Shell-ul este interfața dintre utilizator și kernel.

> Tip din sală: Gândește-te la shell ca la un translator bilingv — tu vorbești "limbajul uman" (comenzi), el traduce în "limbajul mașinii" (apeluri sistem). Și ca orice translator, poate interpreta lucrurile diferit uneori... Primește comenzi text și le transmite kernel-ului pentru execuție.

```bash
# Prompt-ul standard
utilizator@hostname:~/director$
    │         │        │      │
    │         │        │      └── $ = user normal, # = root
    │         │        └── Directorul curent (~ = home)
    │         └── Numele calculatorului
    └── Numele utilizatorului
```

### 2.2 Tipuri de Shell

| Shell | Descriere | Fișier Config |
|-------|-----------|---------------|
| **bash** | Bourne Again Shell (implicit în majoritatea distribuțiilor) | `~/.bashrc` |
| **sh** | Bourne Shell (original) | `~/.profile` |
| **zsh** | Z Shell (macOS default) | `~/.zshrc` |
| **fish** | Friendly Interactive Shell | `~/.config/fish/` |

```bash
# Verifică shell-ul curent
echo $SHELL

# Listează shell-urile disponibile
cat /etc/shells
```

### 2.3 Comenzi de Bază

#### Navigare și Informații

```bash
# Afișează directorul curent
pwd
# Output: /home/student

# Listează conținutul directorului
ls
ls -la          # format lung + fișiere ascunse
ls -lh          # dimensiuni human-readable

# Schimbă directorul
cd /home        # cale absolută
cd ~            # home directory
cd ..           # directorul părinte
cd -            # directorul anterior

# Informații sistem
uname -a        # toate informațiile
hostname        # numele calculatorului
whoami          # utilizatorul curent
```

#### Manipulare Fișiere

```bash
# Creare
touch fisier.txt              # creează fișier gol
mkdir director                # creează director
mkdir -p dir1/dir2/dir3       # creează ierarhie

# Copiere
cp sursa.txt destinatie.txt
cp -r director/ backup/       # recursiv pentru directoare

# Mutare/Redenumire
mv vechi.txt nou.txt
mv fisier.txt /alta/cale/

# Ștergere
rm fisier.txt
rm -r director/               # recursiv
rm -rf director/              # forțat, fără confirmare (ATENȚIE!)

# Vizualizare conținut
cat fisier.txt                # tot conținutul
head -n 10 fisier.txt         # primele 10 linii
tail -n 10 fisier.txt         # ultimele 10 linii
less fisier.txt               # paginat (q pentru ieșire)
```

### 2.4 Obținerea Ajutorului

```bash
# Manual complet
man ls
man bash

# Ajutor rapid
ls --help
help cd                       # pentru comenzi built-in

# Căutare în manuale
apropos "copy files"
man -k network

# Informații despre comandă
type ls                       # alias, built-in sau extern?
which python                  # calea către executabil
whereis gcc                   # locații binare, surse, man
```

Navigare în `man`:

| Tastă | Acțiune |
|-------|---------|
| `Space` / `Page Down` | Pagină următoare |
| `b` / `Page Up` | Pagină anterioară |
| `/pattern` | Caută pattern |
| `n` | Următoarea potrivire |
| `q` | Ieșire |

---

## 3. Quoting și Caractere Speciale

### 3.1 Caractere Speciale în Bash

| Caracter | Semnificație |
|----------|--------------|
| `*` | Wildcard - orice șir de caractere |
| `?` | Wildcard - un singur caracter |
| `$` | Expansiune variabilă |
| `\` | Escape character |
| `` ` `` | Command substitution (deprecated) |
| `$()` | Command substitution (preferat) |
| `"..."` | Double quotes (permite expansiune) |
| `'...'` | Single quotes (literal) |

### 3.2 Diferența între Ghilimele

```bash
NUME="Student"

# Single quotes - totul literal
echo 'Salut $NUME'
# Output: Salut $NUME

# Double quotes - permite expansiune variabile
echo "Salut $NUME"
# Output: Salut Student

# Fără ghilimele - word splitting
echo Salut      $NUME
# Output: Salut Student (spațiile multiple se comprimă)
```

### 3.3 Escape Character

```bash
# Afișează caracterul special literal
echo "Prețul este \$100"
# Output: Prețul este $100

echo "Linia 1\nLinia 2"     # \n nu funcționează implicit
echo -e "Linia 1\nLinia 2"  # cu -e, interpretează escape sequences
```

---

## 4. Variabile de Mediu

### 4.1 Variabile Importante

```bash
echo $HOME      # /home/student
echo $USER      # student
echo $PATH      # căile de căutare pentru executabile
echo $SHELL     # /bin/bash
echo $PWD       # directorul curent
echo $?         # exit code ultima comandă (0 = succes)
```

### 4.2 Setarea Variabilelor

```bash
# Variabilă locală (doar în shell-ul curent)
MESAJ="Salut lume"
echo $MESAJ

# Variabilă de mediu (moștenită de subprocese)
export JAVA_HOME="/usr/lib/jvm/java-17"

# Într-o singură comandă
VAR=valoare comanda    # VAR există doar pentru această comandă
```

---

## 5. Exerciții Practice

### Exercițiul 1: Navigare

```bash
# 1. Afișează directorul curent
pwd

# 2. Mergi în directorul home
cd ~

# 3. Listează toate fișierele (inclusiv ascunse)
ls -la

# 4. Creează un director de lucru
mkdir -p ~/laborator/tc1a
cd ~/laborator/tc1a
```

### Exercițiul 2: Manipulare Fișiere

```bash
# 1. Creează fișiere de test
touch fisier1.txt fisier2.txt
echo "Conținut test" > fisier3.txt

# 2. Verifică conținutul
cat fisier3.txt
ls -l

# 3. Copiază și redenumește
cp fisier3.txt backup.txt
mv fisier1.txt document.txt

# 4. Curăță
rm fisier2.txt
```

### Exercițiul 3: Informații Sistem

```bash
# 1. Cine ești?
whoami
id

# 2. Ce sistem rulezi?
uname -a
cat /etc/os-release

# 3. Cât spațiu pe disk?
df -h

# 4. Câtă memorie?
free -h
```

### Exercițiul 4: Man Pages

```bash
# 1. Găsește opțiunea pentru ls care sortează după dată
man ls
# Răspuns: ls -lt

# 2. Cum copiezi un director recursiv?
man cp
# Răspuns: cp -r

# 3. Caută comenzi legate de "password"
apropos password
```

---

## 6. Întrebări de Verificare

1. Care este diferența între kernel și shell?
   > Kernel-ul este nucleul SO care gestionează hardware-ul și procesele. Shell-ul este interfața utilizator care primește comenzi și le transmite kernel-ului.

2. Ce face comanda `cd -`?
   > Revine la directorul anterior (echivalent cu "back").

3. Care este diferența între `'$HOME'` și `"$HOME"`?
   > Single quotes: afișează literal `$HOME`. Double quotes: expandează variabila, afișează `/home/student`.

4. Ce returnează `echo $?` după o comandă reușită?
   > Returnează `0` (zero înseamnă succes în Unix).

5. Cum afli ce tip de comandă este `cd`?
   > `type cd` - va arăta că este un "shell builtin".

---

## Cheat Sheet

```bash
# NAVIGARE
pwd                 # director curent
cd DIR              # schimbă director
cd ~                # home
cd ..               # părinte
cd -                # anterior

# LISTARE
ls                  # listează
ls -la              # detaliat + ascunse
ls -lh              # human readable

# FIȘIERE
touch FILE          # creează gol
mkdir DIR           # creează director
cp SRC DST          # copiază
mv SRC DST          # mută/redenumește
rm FILE             # șterge

# VIZUALIZARE
cat FILE            # afișează tot
head -n N FILE      # primele N linii
tail -n N FILE      # ultimele N linii
less FILE           # paginat

# AJUTOR
man CMD             # manual
CMD --help          # ajutor rapid
type CMD            # tip comandă
which CMD           # locație

# VARIABILE
echo $VAR           # afișează variabilă
export VAR=val      # setează env var
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
