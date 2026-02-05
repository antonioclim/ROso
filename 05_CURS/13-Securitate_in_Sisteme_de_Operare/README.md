# Sisteme de Operare - Săptămâna 13: Securitate în Sisteme de Operare

> **by Revolvix** | ASE București - CSIE | Anul I, Semestrul 2 | 2025-2026

---

## Obiectivele Săptămânii

După parcurgerea materialelor din această săptămână, vei putea să:

1. **Diferențiezi** între autentificare, autorizare și audit (triada AAA)
2. Explici sistemul de permisiuni Unix și **configurezi** permisiuni corect
3. **Folosești** Access Control Lists (ACL) pentru scenarii avansate
4. Compari modelele de control acces: DAC, MAC, RBAC
5. **Aplici** principiile fundamentale de securitate în administrarea sistemului
6. **Identifici** vulnerabilități comune și măsuri de protecție

---

## Context aplicativ (scenariu didactic): Cum a fost posibil atacul SolarWinds?

În decembrie 2020, s-a descoperit că hackeri (atribuiți serviciilor de informații rusești) au compromis procesul de build al SolarWinds Orion - un software de management IT folosit de mii de organizații, inclusiv agenții guvernamentale americane. Update-ul "legitim", semnat digital, a instalat backdoor-uri pe aproximativ 18.000 de sisteme.

Ce lecții de securitate SO putem extrage?

1. **Principiul privilegiului minim** - Procesele de build aveau prea multe permisiuni
2. **Integritatea lanțului de încredere** - Code signing nu e suficient dacă atacatorul controlează build-ul
3. **Defense in depth** - Un singur punct de eșec a compromis mii de sisteme
4. **Auditare** - Breșa a rămas nedetectată luni de zile

> 💡 **Gândește-te**: Ce s-ar fi întâmplat dacă build server-ul rula cu permisiuni minime și fiecare modificare era auditată automat?

---

## Conținut Curs (13/14)

### 1. Triada AAA: Fundația Securității

#### Definiție Formală

> Securitatea sistemelor se bazează pe trei piloni fundamentali: **Authentication** (cine ești?), **Authorization** (ce poți face?), și **Audit** (ce ai făcut?). Împreună, formează **triada AAA**.

#### Cei Trei Piloni Detaliați

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              TRIADA AAA                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                     1. AUTHENTICATION                                │    │
│  │                     "CINE EȘTI TU?"                                  │    │
│  ├─────────────────────────────────────────────────────────────────────┤    │
│  │                                                                      │    │
│  │  Factori de autentificare:                                          │    │
│  │                                                                      │    │
│  │  ┌───────────────────────────────────────────────────────────────┐  │    │
│  │  │ Something you KNOW    │ Parolă, PIN, răspuns secret           │  │    │
│  │  │ Something you HAVE    │ Smart card, token, telefon (2FA)      │  │    │
│  │  │ Something you ARE     │ Amprentă, iris, voce (biometric)      │  │    │
│  │  │ Somewhere you ARE     │ Locație GPS, IP address               │  │    │
│  │  └───────────────────────────────────────────────────────────────┘  │    │
│  │                                                                      │    │
│  │  Linux:                                                              │    │
│  │  - /etc/passwd: Informații utilizatori (public)                     │    │
│  │  - /etc/shadow: Hash-uri parole (root only)                         │    │
│  │  - SSH keys: Autentificare fără parolă                              │    │
│  │  - PAM: Pluggable Authentication Modules                            │    │
│  │                                                                      │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                     2. AUTHORIZATION                                 │    │
│  │                     "CE POȚI FACE?"                                  │    │
│  ├─────────────────────────────────────────────────────────────────────┤    │
│  │                                                                      │    │
│  │  După autentificare, sistemul verifică CE ai voie să faci:          │    │
│  │                                                                      │    │
│  │  - Permisiuni fișiere (rwx)                                         │    │
│  │  - Access Control Lists (ACL)                                       │    │
│  │  - Capabilities (permisiuni granulare)                              │    │
│  │  - Namespace isolation (containere)                                 │    │
│  │  - SELinux/AppArmor policies (MAC)                                  │    │
│  │                                                                      │    │
│  │  Întrebare cheie: "Este utilizatorul X autorizat să facă Y pe Z?"   │    │
│  │                                                                      │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                        3. AUDIT                                      │    │
│  │                     "CE AI FĂCUT?"                                   │    │
│  ├─────────────────────────────────────────────────────────────────────┤    │
│  │                                                                      │    │
│  │  Înregistrarea acțiunilor pentru:                                   │    │
│  │  - Detectarea breșelor                                              │    │
│  │  - Investigații forensice                                           │    │
│  │  - Conformitate (compliance)                                        │    │
│  │  - Îmbunătățirea securității                                        │    │
│  │                                                                      │    │
│  │  Linux logs:                                                         │    │
│  │  - /var/log/auth.log: Autentificări (login, sudo, ssh)             │    │
│  │  - /var/log/syslog: Evenimente sistem                               │    │
│  │  - /var/log/audit/audit.log: Linux Audit Framework                 │    │
│  │  - journalctl: Systemd journal                                      │    │
│  │                                                                      │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### Verificare Practică: Auditul în Acțiune

```bash
# Vizualizare încercări de autentificare
sudo cat /var/log/auth.log | tail -20

# Sau cu journalctl
journalctl -u sshd --since "1 hour ago"

# Cine e logat acum?
who
w

# Ultimele login-uri
last | head -20

# Încercări eșuate de login
sudo lastb | head -10
```

---

### 2. Sistemul de Permisiuni Unix

#### Definiție Formală

> În Unix/Linux, fiecare fișier și director are asociate **permisiuni** care controlează cine poate **citi** (read), **scrie** (write) sau **executa** (execute). Permisiunile se aplică pentru trei categorii: **owner**, **group**, și **others**.

#### Anatomia Permisiunilor

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     ANATOMIA OUTPUT-ULUI ls -l                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  $ ls -l /home/user/script.sh                                               │
│                                                                              │
│  -rwxr-xr-x  1  user  developers  2048  Jan 15 10:30  script.sh             │
│  │└┬┘└┬┘└┬┘  │   │       │        │          │            │                 │
│  │ │  │  │   │   │       │        │          │            └── Nume fișier   │
│  │ │  │  │   │   │       │        │          └── Dată modificare            │
│  │ │  │  │   │   │       │        └── Dimensiune (bytes)                    │
│  │ │  │  │   │   │       └── Grup proprietar                                │
│  │ │  │  │   │   └── User proprietar                                        │
│  │ │  │  │   └── Număr hard links                                           │
│  │ │  │  │                                                                   │
│  │ │  │  └── OTHERS: r-x = read (4) + execute (1) = 5                       │
│  │ │  └── GROUP: r-x = read (4) + execute (1) = 5                           │
│  │ └── OWNER: rwx = read (4) + write (2) + execute (1) = 7                  │
│  │                                                                           │
│  └── TIP: - regular, d directory, l symlink, b/c device                     │
│                                                                              │
│  Permisiuni în octal: 755                                                    │
│                                                                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│                         TABEL PERMISIUNI                                     │
│                                                                              │
│  ┌────────────┬────────┬───────────────────────────────────────────────┐    │
│  │ Permisiune │ Valoare│ Pentru FIȘIER        │ Pentru DIRECTOR        │    │
│  ├────────────┼────────┼──────────────────────┼────────────────────────┤    │
│  │     r      │    4   │ Citește conținut     │ Listează conținut      │    │
│  │     w      │    2   │ Modifică conținut    │ Creează/șterge fișiere │    │
│  │     x      │    1   │ Execută ca program   │ Accesează (cd into)    │    │
│  │     -      │    0   │ Fără permisiune      │ Fără permisiune        │    │
│  └────────────┴────────┴──────────────────────┴────────────────────────┘    │
│                                                                              │
│  Exemple comune:                                                             │
│  644 (rw-r--r--): Fișier text, toți citesc, owner scrie                     │
│  755 (rwxr-xr-x): Script executabil, toți rulează, owner modifică           │
│  700 (rwx------): Privat, doar owner-ul are acces                           │
│  666 (rw-rw-rw-): Toți scriu (PERICULOS!)                                   │
│  777 (rwxrwxrwx): Acces total (FOARTE PERICULOS!)                           │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### Permisiuni Speciale: setuid, setgid, sticky bit

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        PERMISIUNI SPECIALE                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  1. SETUID (Set User ID) - pentru executabile                               │
│  ───────────────────────────────────────────────                             │
│                                                                              │
│  Când un executabil are setuid, rulează cu permisiunile OWNER-ului,         │
│  nu ale utilizatorului care îl lansează.                                    │
│                                                                              │
│  $ ls -l /usr/bin/passwd                                                    │
│  -rwsr-xr-x 1 root root 68208 ... /usr/bin/passwd                           │
│     ^                                                                        │
│     └── 's' în loc de 'x' = setuid activ                                    │
│                                                                              │
│  De ce? Comanda `passwd` trebuie să modifice /etc/shadow (owned by root),   │
│  dar e rulată de utilizatori normali.                                       │
│                                                                              │
│  ⚠️  RISC MAJOR: Dacă programul setuid are o vulnerabilitate,               │
│      atacatorul poate obține privilegii root!                               │
│                                                                              │
│  ════════════════════════════════════════════════════════════════════════   │
│                                                                              │
│  2. SETGID (Set Group ID)                                                    │
│  ───────────────────────────                                                 │
│                                                                              │
│  Pentru executabile: Rulează cu permisiunile GRUPULUI owner.                │
│  Pentru directoare: Fișierele noi moștenesc grupul directorului.            │
│                                                                              │
│  $ ls -l /usr/bin/write                                                     │
│  -rwxr-sr-x 1 root tty 19024 ... /usr/bin/write                             │
│         ^                                                                    │
│         └── 's' în grup = setgid activ                                      │
│                                                                              │
│  Util pentru directoare colaborative:                                       │
│  $ chmod g+s /shared/project/                                               │
│  Toate fișierele create în /shared/project/ vor avea grupul "project"       │
│                                                                              │
│  ════════════════════════════════════════════════════════════════════════   │
│                                                                              │
│  3. STICKY BIT - pentru directoare                                          │
│  ─────────────────────────────────────                                       │
│                                                                              │
│  Într-un director cu sticky bit, utilizatorii pot șterge DOAR               │
│  fișierele pe care le dețin, chiar dacă au permisiune de scriere.           │
│                                                                              │
│  $ ls -ld /tmp                                                              │
│  drwxrwxrwt 15 root root 4096 ... /tmp                                      │
│          ^                                                                   │
│          └── 't' = sticky bit activ                                         │
│                                                                              │
│  Fără sticky bit pe /tmp, oricine ar putea șterge fișierele altora!         │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### Comenzi pentru Permisiuni

```bash
# Schimbare permisiuni (chmod)
chmod 755 script.sh           # Numeric
chmod u+x script.sh           # Symbolic: add execute for user
chmod g-w file.txt            # Symbolic: remove write for group
chmod o=r file.txt            # Symbolic: set others to read only
chmod a+r file.txt            # Symbolic: add read for all

# Permisiuni speciale
chmod u+s program             # setuid
chmod g+s directory           # setgid pentru director
chmod +t /shared              # sticky bit

chmod 4755 program            # setuid + 755 (4xxx)
chmod 2755 directory          # setgid + 755 (2xxx)
chmod 1777 /tmp               # sticky + 777 (1xxx)

# Schimbare owner/group (chown, chgrp)
sudo chown alice file.txt           # Schimbă owner
sudo chown alice:developers file.txt # Schimbă owner și grup
sudo chgrp developers file.txt      # Schimbă doar grupul

# Default permissions (umask)
umask                         # Afișează umask curent
umask 022                     # Setează: fișiere noi = 644, directoare = 755
umask 077                     # Restrictiv: doar owner are acces
```

#### Umask: Controlul Permisiunilor Implicite

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              UMASK                                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  Umask = "masca" care se scade din permisiunile maxime                      │
│                                                                              │
│  Permisiuni maxime:                                                          │
│  - Fișiere: 666 (rw-rw-rw-)  - fără execute implicit                        │
│  - Directoare: 777 (rwxrwxrwx)                                              │
│                                                                              │
│  Calcul: Permisiune finală = Max - Umask                                    │
│                                                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │ Umask │ Fișier nou │ Director nou │ Descriere                        │   │
│  ├───────┼────────────┼──────────────┼──────────────────────────────────┤   │
│  │  022  │    644     │     755      │ Standard (group/others: no write)│   │
│  │  027  │    640     │     750      │ Mai restrictiv pentru others     │   │
│  │  077  │    600     │     700      │ Privat (doar owner)              │   │
│  │  002  │    664     │     775      │ Colaborativ (group poate scrie)  │   │
│  │  000  │    666     │     777      │ Permisiv (NESIGUR!)              │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  Exemplu cu umask 022:                                                       │
│  - Fișier: 666 - 022 = 644 (rw-r--r--)                                      │
│  - Director: 777 - 022 = 755 (rwxr-xr-x)                                    │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

### 3. Access Control Lists (ACL): Dincolo de rwx

#### Definiție Formală

> **ACL (Access Control List)** extinde modelul tradițional de permisiuni Unix, permițând definirea de permisiuni pentru **utilizatori și grupuri multiple** pe același fișier, nu doar owner/group/others.

#### De Ce Avem Nevoie de ACL?

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    LIMITĂRILE PERMISIUNILOR TRADIȚIONALE                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  SCENARIUL:                                                                  │
│  Fișier: proiect.doc                                                        │
│  - Alice (owner) poate citi și scrie                                        │
│  - Grupul "developers" poate citi                                           │
│  - Bob (nu e în developers) are nevoie să citească                          │
│  - Carol (din developers) are nevoie să scrie                               │
│                                                                              │
│  Cu permisiuni tradiționale: IMPOSIBIL!                                     │
│  - Nu poți da permisiuni individuale pentru Bob                             │
│  - Nu poți da permisiuni diferite membrilor aceluiași grup                  │
│                                                                              │
│  Soluții proaste:                                                            │
│  1. Adaugă Bob în developers → primește acces la TOATE fișierele grupului   │
│  2. Fă fișierul world-readable → toată lumea citește                        │
│  3. Creează grup nou pentru fiecare combinație → explozie de grupuri        │
│                                                                              │
│  Soluția bună: ACL                                                           │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### Utilizare ACL

```bash
# Verificare suport ACL (ext4 are implicit)
mount | grep acl

# Vizualizare ACL
getfacl proiect.doc

# Output:
# # file: proiect.doc
# # owner: alice
# # group: developers
# user::rw-
# user:bob:r--           ← Bob poate citi
# user:carol:rw-         ← Carol poate citi și scrie
# group::r--
# group:managers:r--     ← Grupul managers poate citi
# mask::rw-              ← Permisiune maximă efectivă
# other::---

# Setare ACL pentru utilizator specific
setfacl -m u:bob:r proiect.doc        # Bob: read
setfacl -m u:carol:rw proiect.doc     # Carol: read+write

# Setare ACL pentru grup
setfacl -m g:managers:r proiect.doc

# ACL default pentru directoare (se aplică fișierelor noi)
setfacl -d -m g:developers:rwx /shared/project/

# Ștergere ACL
setfacl -x u:bob proiect.doc          # Șterge ACL pentru Bob
setfacl -b proiect.doc                # Șterge TOATE ACL-urile

# Copiere ACL de la alt fișier
getfacl source.doc | setfacl --set-file=- target.doc
```

#### Indicatorul "+" în ls -l

```bash
$ ls -l
-rw-rw-r--+ 1 alice developers 1024 Jan 15 proiect.doc
          ^
          └── '+' indică prezența ACL-urilor!

# Fără '+' = doar permisiuni tradiționale
# Cu '+' = are ACL setate
```

---

### 4. Modele de Control Acces: DAC, MAC, RBAC

#### Comparație Conceptuală

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      MODELE DE CONTROL ACCES                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  1. DAC - Discretionary Access Control                                       │
│  ──────────────────────────────────────────                                  │
│                                                                              │
│  CINE DECIDE: Owner-ul resursei                                             │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │              Alice (owner)                                           │    │
│  │                  │                                                   │    │
│  │      "Eu decid cine are acces la fișierele mele"                    │    │
│  │                  │                                                   │    │
│  │          ┌───────┴───────┐                                          │    │
│  │          ▼               ▼                                          │    │
│  │     [file.txt]      [private.doc]                                   │    │
│  │     chmod 644       chmod 600                                       │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  Exemplu: Permisiuni Unix tradiționale                                      │
│  ✅ Flexibil, ușor de înțeles                                               │
│  ❌ Utilizatorul poate greși (chmod 777)                                    │
│  ❌ Nu previne exfiltrarea datelor                                          │
│                                                                              │
│  ════════════════════════════════════════════════════════════════════════   │
│                                                                              │
│  2. MAC - Mandatory Access Control                                           │
│  ──────────────────────────────────────                                      │
│                                                                              │
│  CINE DECIDE: Administratorul de sistem / politica centrală                 │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │         POLITICA SISTEM (definită de admin)                          │    │
│  │                     │                                                │    │
│  │     "Utilizatorii NU pot schimba regulile"                          │    │
│  │                     │                                                │    │
│  │         ┌───────────┴───────────┐                                   │    │
│  │         ▼                       ▼                                   │    │
│  │   [CONFIDENTIAL]          [PUBLIC]                                  │    │
│  │   Doar clearance=secret   Oricine citește                           │    │
│  │   Owner-ul NU poate                                                 │    │
│  │   schimba clasificarea!                                             │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  Exemplu: SELinux, AppArmor                                                 │
│  ✅ Previne greșeli utilizator                                              │
│  ✅ Aplică politici la nivel de sistem                                      │
│  ❌ Complex de configurat                                                   │
│  ❌ Poate bloca aplicații legitime                                          │
│                                                                              │
│  ════════════════════════════════════════════════════════════════════════   │
│                                                                              │
│  3. RBAC - Role-Based Access Control                                         │
│  ────────────────────────────────────────                                    │
│                                                                              │
│  CINE DECIDE: Rolurile asociate utilizatorului                              │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                      ROLURI                                          │    │
│  │         ┌──────────────────────────────────────┐                    │    │
│  │         │                                      │                    │    │
│  │    [developer]  [dba]   [auditor]  [admin]    │                    │    │
│  │         │        │         │          │       │                    │    │
│  │         ▼        ▼         ▼          ▼       │                    │    │
│  │      code.git  database  logs     everything  │                    │    │
│  │                                               │                    │    │
│  │    Alice are rolul "developer" → acces la code                     │    │
│  │    Bob are rolurile "developer" + "dba" → acces la code + db       │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  Exemplu: sudo, Kubernetes RBAC, AWS IAM                                    │
│  ✅ Scalabil (adaugi roluri, nu permisiuni individuale)                     │
│  ✅ Ușor de auditat ("cine are rolul X?")                                   │
│  ❌ Necesită planificare atentă a rolurilor                                 │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### SELinux vs AppArmor (MAC în Linux)

| Aspect | SELinux | AppArmor |
|--------|---------|----------|
| **Complexitate** | Foarte complex | Mai simplu |
| **Politici** | Bazat pe etichete (labels) | Bazat pe căi (paths) |
| **Distribuții** | RHEL, CentOS, Fedora | Ubuntu, Debian, SUSE |
| **Granularitate** | Foarte fină | Medie |
| **Curba de învățare** | Abruptă | Moderată |

```bash
# Verificare stare SELinux
getenforce
# Enforcing / Permissive / Disabled

# Verificare AppArmor
sudo aa-status

# Comutare temporară SELinux
sudo setenforce 0   # Permissive (logează dar nu blochează)
sudo setenforce 1   # Enforcing (blochează)
```

---

### 5. Principii Fundamentale de Securitate

#### Cele Patru Principii Esențiale

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    PRINCIPII DE SECURITATE                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  1. LEAST PRIVILEGE (Privilegiu Minim)                                       │
│  ──────────────────────────────────────                                      │
│                                                                              │
│  "Dă fiecărui proces/utilizator DOAR permisiunile necesare                  │
│   pentru a-și îndeplini sarcina, nimic mai mult."                           │
│                                                                              │
│  ❌ Greșit:                                                                  │
│     - Web server rulează ca root                                            │
│     - Script de backup are permisiune de scriere peste tot                  │
│     - Toți angajații au acces admin                                         │
│                                                                              │
│  ✅ Corect:                                                                  │
│     - Web server rulează ca www-data, acces doar la /var/www                │
│     - Backup: citire pe surse, scriere doar pe destinație                   │
│     - Angajații au acces doar la ce au nevoie                               │
│                                                                              │
│  ════════════════════════════════════════════════════════════════════════   │
│                                                                              │
│  2. DEFENSE IN DEPTH (Apărare în Adâncime)                                   │
│  ──────────────────────────────────────────────                              │
│                                                                              │
│  "Nu te baza pe un singur strat de securitate.                              │
│   Dacă unul eșuează, altele trebuie să compenseze."                         │
│                                                                              │
│  Straturi de apărare:                                                        │
│                                                                              │
│       ┌─────────────────────────────────────────┐                           │
│       │           FIREWALL PERIMETRAL           │ Strat 1                   │
│       │  ┌───────────────────────────────────┐  │                           │
│       │  │        FIREWALL INTERN            │  │ Strat 2                   │
│       │  │  ┌─────────────────────────────┐  │  │                           │
│       │  │  │     PERMISIUNI FIȘIERE     │  │  │ Strat 3                   │
│       │  │  │  ┌───────────────────────┐  │  │  │                           │
│       │  │  │  │   CRIPTARE DATE       │  │  │  │ Strat 4                   │
│       │  │  │  │  ┌─────────────────┐  │  │  │  │                           │
│       │  │  │  │  │    APLICAȚIE    │  │  │  │  │ Centrul                   │
│       │  │  │  │  └─────────────────┘  │  │  │  │                           │
│       │  │  │  └───────────────────────┘  │  │  │                           │
│       │  │  └─────────────────────────────┘  │  │                           │
│       │  └───────────────────────────────────┘  │                           │
│       └─────────────────────────────────────────┘                           │
│                                                                              │
│  ════════════════════════════════════════════════════════════════════════   │
│                                                                              │
│  3. FAIL SECURE (Eșuează în Siguranță)                                       │
│  ─────────────────────────────────────────                                   │
│                                                                              │
│  "La eroare, sistemul trebuie să blocheze accesul, nu să-l permită."        │
│                                                                              │
│  ❌ Fail OPEN (periculos):                                                   │
│     if (auth_check() == ERROR) { allow_access(); }                          │
│                                                                              │
│  ✅ Fail SECURE:                                                             │
│     if (auth_check() != SUCCESS) { deny_access(); }                         │
│                                                                              │
│  ════════════════════════════════════════════════════════════════════════   │
│                                                                              │
│  4. SEPARATION OF DUTIES (Separarea Responsabilităților)                     │
│  ────────────────────────────────────────────────────────────                │
│                                                                              │
│  "Nicio singură persoană nu trebuie să poată face totul."                   │
│                                                                              │
│  Exemple:                                                                    │
│  - Developer NU poate aproba propriul cod în producție                      │
│  - DBA NU poate vedea datele criptate (nu are cheia)                        │
│  - Admin de rețea NU are acces la servere                                   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

### 6. Vulnerabilități și Atacuri Comune

#### Tipuri de Atacuri la Nivel de SO

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      VULNERABILITĂȚI COMUNE                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  1. PRIVILEGE ESCALATION (Escaladare Privilegii)                             │
│  ────────────────────────────────────────────────                            │
│                                                                              │
│  Atacatorul obține acces ca utilizator neprivilegiat,                       │
│  apoi exploatează o vulnerabilitate pentru a deveni root.                   │
│                                                                              │
│  Vectori comuni:                                                             │
│  - Executabile setuid vulnerabile                                           │
│  - Kernel exploits                                                          │
│  - Misconfigurări sudo                                                      │
│  - Parole slabe pentru root                                                 │
│                                                                              │
│  Căutare setuid files:                                                       │
│  $ find / -perm -4000 -type f 2>/dev/null                                   │
│                                                                              │
│  ════════════════════════════════════════════════════════════════════════   │
│                                                                              │
│  2. PATH INJECTION                                                           │
│  ───────────────────                                                         │
│                                                                              │
│  Atacatorul manipulează $PATH pentru a rula un program malițios             │
│  în locul unuia legitim.                                                    │
│                                                                              │
│  ❌ Vulnerabil:                                                              │
│  PATH="." && ./script_calls_ls.sh                                           │
│  # Dacă atacatorul a creat ./ls malițios, va rula ăla!                      │
│                                                                              │
│  ✅ Sigur:                                                                   │
│  - Nu include "." în PATH                                                   │
│  - În scripturi, folosește căi absolute: /bin/ls                            │
│                                                                              │
│  ════════════════════════════════════════════════════════════════════════   │
│                                                                              │
│  3. SYMLINK ATTACKS                                                          │
│  ───────────────────                                                         │
│                                                                              │
│  Atacatorul creează un symlink în /tmp care pointează la un fișier critic,  │
│  iar un script privilegiat scrie accidental în el.                          │
│                                                                              │
│  Exemplu:                                                                    │
│  $ ln -s /etc/passwd /tmp/output.txt                                        │
│  # Scriptul root scrie în /tmp/output.txt → suprascrie /etc/passwd!        │
│                                                                              │
│  Protecție: sticky bit pe /tmp, O_NOFOLLOW flag                             │
│                                                                              │
│  ════════════════════════════════════════════════════════════════════════   │
│                                                                              │
│  4. TIME-OF-CHECK TO TIME-OF-USE (TOCTOU)                                    │
│  ──────────────────────────────────────────────                              │
│                                                                              │
│  Race condition între verificarea accesului și utilizare.                   │
│                                                                              │
│  ❌ Vulnerabil:                                                              │
│  if (access("/tmp/file", R_OK) == 0) {                                      │
│      // ← Între access() și open(), atacatorul schimbă /tmp/file!           │
│      fd = open("/tmp/file", O_RDONLY);                                      │
│  }                                                                           │
│                                                                              │
│  ✅ Sigur: Verificare la nivel de kernel, nu user space                     │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### Audit de Securitate: Ce să Verifici

```bash
# 1. Găsește fișiere world-writable
find / -type f -perm -002 2>/dev/null

# 2. Găsește directoare fără sticky bit (world-writable)
find / -type d -perm -002 ! -perm -1000 2>/dev/null

# 3. Găsește executabile setuid/setgid
find / -perm -4000 -o -perm -2000 -type f 2>/dev/null

# 4. Verifică fișiere fără owner
find / -nouser -o -nogroup 2>/dev/null

# 5. Verifică permisiuni pe fișiere sensibile
ls -la /etc/passwd /etc/shadow /etc/sudoers

# 6. Utilizatori cu UID 0 (root)
awk -F: '$3 == 0 {print $1}' /etc/passwd

# 7. Verifică parole goale
sudo awk -F: '$2 == "" {print $1}' /etc/shadow
```

---

## Laborator/Seminar (Sesiunea 6/7)

### Materiale TC
- TC6a-TC6c: Advanced Scripting, Testing
- TC6d: Security Practices

### Tema 6: `tema6_security_audit.sh`

Script de audit de securitate care:
- Scanează fișiere world-writable
- Detectează executabile setuid/setgid
- Verifică permisiuni pe fișiere critice
- Generează raport HTML sau text
- Opțiuni: `-q` quiet, `-o FILE` output, `--fix` (propune remedieri)

---

## Demonstrații Practice

### Demo 1: Escaladare Privilegii prin setuid

```bash
#!/bin/bash
# DEMO EDUCAȚIONAL - Nu face asta pe sisteme de producție!

# Arătăm de ce setuid e periculos pe scripturi shell
# (De fapt, Linux ignoră setuid pe scripturi, dar principiul rămâne)

# Creează un program C simplu cu setuid
cat > /tmp/demo_vuln.c << 'EOF'
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main() {
    // Acest program are setuid root
    // Dar apelează system() cu input utilizator - PERICULOS!
    printf("Checking disk... (running as UID %d)\n", geteuid());
    system("df -h");  // Ce se întâmplă dacă PATH e manipulat?
    return 0;
}
EOF

echo "În realitate, NICIODATĂ nu faci setuid pe programe care apelează system()!"
```

### Demo 2: ACL în Acțiune

```bash
#!/bin/bash
# Demo: Permisiuni granulare cu ACL

DEMO_DIR=$(mktemp -d)
cd "$DEMO_DIR"

# Creează fișier
echo "Date sensibile" > document.txt

# Permisiuni tradiționale
chmod 640 document.txt
ls -l document.txt

# Adaugă ACL pentru utilizator specific
setfacl -m u:nobody:r document.txt
echo "După ACL:"
getfacl document.txt

# Observă '+' în ls -l
ls -l document.txt

cd - && rm -rf "$DEMO_DIR"
```

---

## Lectură Recomandată

### OSTEP (Operating Systems: Three Easy Pieces)
- [Cap 53 - Security](https://pages.cs.wisc.edu/~remzi/OSTEP/security-intro.pdf)
- [Cap 54 - Authentication](https://pages.cs.wisc.edu/~remzi/OSTEP/security-authentication.pdf)
- [Cap 55 - Access Control](https://pages.cs.wisc.edu/~remzi/OSTEP/security-access.pdf)

### Tanenbaum - Modern Operating Systems
- Capitolul 9: Security (pag. 593+)

### Resurse Suplimentare
- OWASP Cheat Sheets
- CIS Benchmarks for Linux
- `man 5 sudoers`

---

## Sumar Comenzi Noi

| Comandă | Descriere | Exemplu |
|---------|-----------|---------|
| `chmod` | Schimbă permisiuni | `chmod 755 file.sh` |
| `chown` | Schimbă owner | `sudo chown user:group file` |
| `umask` | Setează permisiuni implicite | `umask 077` |
| `getfacl` | Vizualizare ACL | `getfacl file.txt` |
| `setfacl` | Setare ACL | `setfacl -m u:bob:rw file.txt` |
| `last` | Ultimele login-uri | `last \| head` |
| `lastb` | Login-uri eșuate | `sudo lastb` |
| `who` | Utilizatori logați | `who` |
| `getenforce` | Status SELinux | `getenforce` |
| `aa-status` | Status AppArmor | `sudo aa-status` |

---


---


---

## Nuanțe și Cazuri Speciale

### Ce NU am acoperit (limitări didactice)

- **Seccomp-BPF**: Filtrarea syscalls pentru sandboxing (Chrome, Docker, systemd).
- **Landlock**: Sandboxing lightweight introdus în Linux 5.13.
- **Secure boot și measured boot**: Chain of trust de la UEFI până la kernel.

### Greșeli frecvente de evitat

1. **Setarea permisiunilor 777**: Niciodată în producție; aproape întotdeauna greșit.
2. **Root în containere**: Chiar și containerizat, root poate escalada prin vulnerabilități kernel.
3. **Ignorarea audit logs**: Fără logging, nu poți investiga incidentele.

### Întrebări rămase deschise

- Pot sistemele capability-based (seL4, Fuchsia) să înlocuiască modelele tradiționale DAC/MAC?
- Cum va afecta post-quantum cryptography securitatea sistemelor de operare?

## Privire înainte

**Săptămâna 14: Virtualizare + Recapitulare** — Încheiem cursul principal cu virtualizarea: mașini virtuale vs containere, hypervisoare, și o recapitulare a tuturor conceptelor studiate. După aceasta, cursurile suplimentare (15-18) sunt disponibile pentru aprofundare.

**Pregătire recomandată:**
- Instalează Docker dacă nu l-ai instalat încă
- Pregătește întrebări pentru sesiunea de recapitulare

## Rezumat Vizual

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    SĂPTĂMÂNA 13: RECAP - SECURITATE                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  TRIADA AAA                                                                  │
│  ├── Authentication: Cine ești? (parole, SSH keys, biometrie)               │
│  ├── Authorization: Ce poți face? (permisiuni, ACL, RBAC)                   │
│  └── Audit: Ce ai făcut? (/var/log/auth.log, journalctl)                    │
│                                                                              │
│  PERMISIUNI UNIX                                                             │
│  ├── rwx pentru owner / group / others                                      │
│  ├── Numeric: 755, 644, 600                                                 │
│  ├── Speciale: setuid (s), setgid (s), sticky (t)                          │
│  └── umask: controlează permisiuni implicite                                │
│                                                                              │
│  ACL (Access Control Lists)                                                  │
│  ├── Permisiuni granulare pentru utilizatori/grupuri multiple              │
│  └── getfacl / setfacl                                                      │
│                                                                              │
│  MODELE CONTROL ACCES                                                        │
│  ├── DAC: Owner-ul decide (Unix tradițional)                                │
│  ├── MAC: Politica sistem decide (SELinux, AppArmor)                        │
│  └── RBAC: Rolurile decid (sudo, Kubernetes)                                │
│                                                                              │
│  PRINCIPII                                                                   │
│  ├── Least Privilege: Doar permisiunile necesare                            │
│  ├── Defense in Depth: Straturi multiple de securitate                      │
│  ├── Fail Secure: La eroare, blochează                                      │
│  └── Separation of Duties: Nimeni nu face totul                             │
│                                                                              │
│  VULNERABILITĂȚI                                                             │
│  ├── Privilege Escalation: setuid, kernel exploits                          │
│  ├── PATH Injection: Nu include "." în PATH                                 │
│  ├── Symlink Attacks: sticky bit pe /tmp                                    │
│  └── TOCTOU: Race conditions                                                │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```


---

## Auto-evaluare

### Întrebări de verificare

1. **[REMEMBER]** Definește modelul AAA (Authentication, Authorization, Accounting). Dă un exemplu pentru fiecare componentă.
2. **[UNDERSTAND]** Explică sistemul de permisiuni Unix (rwx pentru owner, group, others). Ce înseamnă permisiunea 755 în octal?
3. **[ANALYSE]** Compară ACL (Access Control Lists) cu permisiunile Unix tradiționale. În ce situații sunt ACL-urile necesare?

### Mini-provocare (opțional)

Creează un fișier și experimentează cu `chmod`, `chown`, `setfacl`. Verifică cu `getfacl` și `ls -l` efectele.

---

*Materiale dezvoltate by Revolvix pentru ASE București - CSIE*  
*Sisteme de Operare | Anul I, Semestrul 2 | 2025-2026*

---

## Scripting în context (Bash + Python): Audit de permisiuni

### Fișiere incluse

- Bash: `scripts/perm_audit.sh` — Găsește world-writable, SUID/SGID, directoare fără sticky bit.
- Python: `scripts/perm_audit.py` — Interpretare permisiuni prin `stat` și raportare controlată.

### Rulare rapidă

```bash
./scripts/perm_audit.sh .
./scripts/perm_audit.py --root .
```

### Legătura cu conceptele din această săptămână

- Permisiunile, SUID/SGID și sticky bit sunt mecanisme simple, dar cu impact mare.
- Auditarea este o practică standard: întâi raportezi, apoi remediezi controlat.

### Practică recomandată

- rulează întâi scripturile pe un director de test (nu pe date critice);
- salvează output-ul într-un fișier și atașează-l la raport/temă, dacă este cerut;
- notează versiunea de kernel (`uname -r`) și versiunea Python (`python3 --version`) când compari rezultate.

*Materiale dezvoltate de Revolvix pentru ASE București - CSIE*  
*Sisteme de Operare | Anul I, Semestrul 2 | 2025-2026*