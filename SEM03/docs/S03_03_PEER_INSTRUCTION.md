# Peer Instruction - Seminarul 03

## Sisteme de Operare | ASE București - CSIE

> 18+ Întrebări MCQ pentru activități Peer Instruction  
> Format: Întrebare → Vot individual → Discuție perechi → Vot final → Explicație

---


## ÎNTREBĂRI PARAMETRI SCRIPT


### Procedura standard de vot

1. **Vot individual (silenzios):** fiecare student alege un răspuns (fără discuții).
2. **Afișarea distribuției (fără soluție):** instructorul arată rapid distribuția voturilor (de exemplu, A/B/C/D), fără a confirma răspunsul corect.
3. **Discuție în perechi / grupuri mici:** studenții își explică reciproc raționamentul și încearcă să ajungă la un consens local.
4. **Vot din nou:** studenții votează a doua oară (după discuție).
5. **Explicație și debrief:** instructorul explică soluția corectă și clarifică concepțiile greșite.


### Protocol Peer Instruction

1. [1-2 min] Afișează întrebarea
2. [1 min] Vot individual (mâini ridicate / aplicație)
3. [2 min] Dacă nu e consens (>80%), discuție în perechi
4. [1 min] Vot final
5. [2 min] Explicație și demonstrație


### Notația întrebărilor

În materialele Seminarului 03, întrebările pot fi notate cu:
- un identificator (de exemplu, Q1, Q2, …) pentru urmărire și trasabilitate;
- un nivel Bloom (de exemplu, *Understand*, *Apply*, *Analyse*) pentru calibrarea dificultății;
- o referință către secțiunea relevantă din materialul principal.



## Cuprins

1. [Întrebări find și xargs (PI-01 la PI-05)](#-întrebări-find-și-xargs)
2. [Întrebări Parametri Script (PI-06 la PI-09)](#-întrebări-parametri-script)
3. [Întrebări Permisiuni (PI-10 la PI-14)](#-întrebări-permisiuni)
4. [Întrebări Cron (PI-15 la PI-18)](#-întrebări-cron)
5. [Ghid de Utilizare](#-ghid-de-utilizare)

---


## ÎNTREBĂRI FIND ȘI XARGS


### PI-01: find vs locate

```
╔══════════════════════════════════════════════════════════════════╗
║  🗳️ PI-01: find vs locate                                        ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  Tocmai ai creat un fișier: touch ~/proiect/config.txt           ║
║  Imediat după, rulezi: locate config.txt                         ║
║                                                                  ║
║  Ce se întâmplă?                                                 ║
║                                                                  ║
║  A) Găsește fișierul instant                                     ║
║  B) Nu găsește fișierul (database outdated)                      ║
║  C) Eroare - locate nu caută în home                             ║
║  D) Găsește toate fișierele config.txt din sistem,               ║
║     inclusiv cel nou                                             ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

Răspuns corect: B

Explicație:
`locate` folosește o bază de date pre-indexată (`/var/lib/mlocate/mlocate.db`) care se actualizează periodic (de regulă noaptea prin cron). Fișierele create recent nu apar până la următoarea actualizare cu `sudo updatedb`.

Demonstrație:
```bash
touch ~/test_locate_$(date +%s).txt
locate test_locate    # Nu găsește
sudo updatedb
locate test_locate    # Acum găsește
```

Când folosești care:
- `locate` - căutări rapide când nu-ți pasă de fișiere recente
- `find` - căutări în timp real, criterii complexe

---


### PI-02: find cu multiple condiții

```
╔══════════════════════════════════════════════════════════════════╗
║  🗳️ PI-02: find cu multiple condiții                             ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  Ce returnează această comandă?                                  ║
║                                                                  ║
║  find . -type f -name "*.txt" -o -name "*.md"                   ║
║                                                                  ║
║  A) Toate fișierele .txt și toate fișierele .md                 ║
║  B) Toate fișierele .txt și toate FIȘIERELE .md                 ║
║  C) Toate fișierele .txt și ORICE (fișier sau director) .md     ║
║  D) Eroare de sintaxă                                            ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

Răspuns corect: C

Explicație:
Precedența operatorilor în find: Operatorul `-and` are precedență mai mare decât `-or`.

Interpretare:
```
(-type f AND -name "*.txt") OR (-name "*.md")
```

Deci returnează:
- Fișiere care se termină în .txt
- ORICE (fișier sau director) care se termină în .md

Soluție corectă:
```bash
find . -type f \( -name "*.txt" -o -name "*.md" \)
```

---


### PI-03: find -exec \; vs +

```
╔══════════════════════════════════════════════════════════════════╗
║  🗳️ PI-03: -exec \; vs +                                         ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  Ai 100 de fișiere .txt. Câte procese `cat` pornește fiecare?    ║
║                                                                  ║
║  find . -name "*.txt" -exec cat {} \;                            ║
║  find . -name "*.txt" -exec cat {} +                             ║
║                                                                  ║
║  A) Prima: 100 procese, A doua: 100 procese                      ║
║  B) Prima: 100 procese, A doua: 1 proces                         ║
║  C) Prima: 1 proces, A doua: 100 procese                         ║
║  D) Ambele: 1 proces                                             ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

Răspuns corect: B

Explicație:
- `\;` execută comanda pentru FIECARE fișier găsit (100 × `cat file.txt`)
- `+` grupează fișierele și execută O DATĂ (`cat file1.txt file2.txt ... file100.txt`)

Performanță:
- `\;` - lent, multe fork-uri
- `+` - rapid, un singur proces

Când folosești care:
- `\;` - când comanda trebuie să primească exact un argument
- `+` - pentru performanță maximă (similar cu xargs)

---


### PI-04: xargs cu spații

```
╔══════════════════════════════════════════════════════════════════╗
║  🗳️ PI-04: xargs cu spații în nume                               ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  Ai un fișier: "document important.txt"                          ║
║  Rulezi: find . -name "*.txt" | xargs rm                         ║
║                                                                  ║
║  Ce se întâmplă?                                                 ║
║                                                                  ║
║  A) Fișierul este șters corect                                   ║
║  B) Eroare: "document", "important.txt" nu există                ║
║  C) Șterge toate fișierele din director                          ║
║  D) xargs ignoră fișierele cu spații                             ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

Răspuns corect: B

Explicație:
xargs implicit splitează pe spații și newlines. "document important.txt" devine trei argumente:
- "document"
- "important.txt"

```bash
rm document        # Eroare: nu există
rm important.txt   # Eroare: nu există
```

Soluție:
```bash
find . -name "*.txt" -print0 | xargs -0 rm
```
- `-print0` - separă cu NULL (nu newline)
- `-0` - xargs citește cu NULL delimiter

---


### PI-05: find -delete vs -exec rm

```
╔══════════════════════════════════════════════════════════════════╗
║  🗳️ PI-05: -delete vs -exec rm                                   ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  Care comandă este mai sigură pentru ștergere?                   ║
║                                                                  ║
║  A) find . -name "*.tmp" -delete                                 ║
║  B) find . -name "*.tmp" -exec rm {} \;                          ║
║  C) find . -name "*.tmp" -exec rm -i {} \;                       ║
║  D) Toate sunt la fel de sigure                                  ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

Răspuns corect: C

Explicație:
- A) `-delete` - ștergere imediată, fără confirmare
- B) `-exec rm {}` - ștergere imediată, fără confirmare
- C) `-exec rm -i {}` - cere confirmare pentru FIECARE fișier ✓

Best practice:
```bash

# Pasul 1: Vezi ce va șterge
find . -name "*.tmp" -print


# Pasul 2: Dacă e OK, șterge
find . -name "*.tmp" -delete

# sau cu confirmare
find . -name "*.tmp" -exec rm -i {} \;
```

---


## ÎNTREBĂRI PERMISIUNI


### PI-06: $@ vs $*

```
╔══════════════════════════════════════════════════════════════════╗
║  🗳️ PI-06: $@ vs $*                                              ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  Script:                                                         ║
║  #!/bin/bash                                                     ║
║  for arg in "$@"; do echo "[$arg]"; done                         ║
║  echo "---"                                                      ║
║  for arg in "$*"; do echo "[$arg]"; done                         ║
║                                                                  ║
║  Rulare: ./script.sh "hello world" test                          ║
║                                                                  ║
║  Ce afișează?                                                    ║
║                                                                  ║
║  A) [hello world] [test] --- [hello world test]                  ║
║  B) [hello] [world] [test] --- [hello] [world] [test]            ║
║  C) [hello world] [test] --- [hello world] [test]                ║
║  D) [hello world test] --- [hello world] [test]                  ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

Răspuns corect: A

Explicație:
- `"$@"` - fiecare argument e un element separat → iterează corect
- `"$*"` - toate argumentele într-un singur string → un singur element

Output:
```
[hello world]
[test]
---
[hello world test]
```

Regula de aur: Folosește `"$@"` pentru iterare!

---


### PI-07: ${10} vs $10

```
╔══════════════════════════════════════════════════════════════════╗
║  🗳️ PI-07: ${10} vs $10                                          ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  Script cu argumente: ./script.sh a b c d e f g h i j k          ║
║                                     1 2 3 4 5 6 7 8 9 10 11      ║
║                                                                  ║
║  echo $10                                                        ║
║                                                                  ║
║  Ce afișează?                                                    ║
║                                                                  ║
║  A) j                                                            ║
║  B) a0                                                           ║
║  C) $10 (literal)                                                ║
║  D) Eroare                                                       ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

Răspuns corect: B

Explicație:
`$10` se interpretează ca `$1` urmat de caracterul `0`.
- `$1` = "a"
- `$1` + "0" = "a0"

Corect:
```bash
echo ${10}    # j
echo ${11}    # k
```

---


### PI-08: shift

```
╔══════════════════════════════════════════════════════════════════╗
║  🗳️ PI-08: Ce face shift?                                        ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  #!/bin/bash                                                     ║
║  echo "Înainte: $1 $2 $3 ($#)"                                   ║
║  shift 2                                                         ║
║  echo "După: $1 $2 $3 ($#)"                                      ║
║                                                                  ║
║  Rulare: ./script.sh A B C D E                                   ║
║                                                                  ║
║  Ce afișează linia "După"?                                       ║
║                                                                  ║
║  A) După: C D E (3)                                              ║
║  B) După: A B C (5)                                              ║
║  C) După: C D  (3)                                               ║
║  D) Eroare - shift nu poate lua argument                         ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

Răspuns corect: A

Explicație:
`shift 2` elimină primele 2 argumente și mută restul:
- Înainte: A B C D E (5 argumente)
- După shift 2: C D E (3 argumente)
  - $1 = C (fostul $3)
  - $2 = D (fostul $4)
  - $3 = E (fostul $5)

---


### PI-09: getopts optstring

```
╔══════════════════════════════════════════════════════════════════╗
║  🗳️ PI-09: getopts optstring                                     ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  while getopts "ab:c" opt; do                                    ║
║      echo "$opt - $OPTARG"                                       ║
║  done                                                            ║
║                                                                  ║
║  Rulare: ./script.sh -a -b value -c                              ║
║                                                                  ║
║  Ce înseamnă "b:" în optstring?                                  ║
║                                                                  ║
║  A) Opțiunea -b este opțională                                   ║
║  B) Opțiunea -b necesită un argument obligatoriu                 ║
║  C) Opțiunea -b poate avea un argument opțional                  ║
║  D) Opțiunea -b este long option (--b)                           ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

Răspuns corect: B

Explicație:
În optstring:
- `a` - opțiunea -a fără argument
- `b:` - opțiunea -b CU argument obligatoriu
- `c` - opțiunea -c fără argument

Dacă rulezi `./script.sh -b` (fără argument), getopts returnează eroare.

---


## PERMISSIONS QUESTIONS


### PI-10: x pe director

```
╔══════════════════════════════════════════════════════════════════╗
║  🗳️ PI-10: Ce înseamnă x pe director?                            ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  chmod 700 mydir/                                                ║
║  chmod 600 mydir/                                                ║
║                                                                  ║
║  După chmod 600, ce NU mai poți face?                            ║
║                                                                  ║
║  A) ls mydir/ (listare conținut)                                 ║
║  B) cd mydir/ (accesare director)                                ║
║  C) cat mydir/file.txt (citire fișier)                          ║
║  D) Toate de mai sus                                             ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

Răspuns corect: B (și implicit C)

Explicație:
Pe director:
- r (4) = poți lista conținutul (ls)
- w (2) = poți crea/șterge fișiere
- x (1) = poți accesa directorul (cd) și fișierele din el

Cu 600 (rw-):
- ✓ ls mydir/ - funcționează (are r)
- ✗ cd mydir/ - NU funcționează (lipsește x)
- ✗ cat mydir/file.txt - NU funcționează (necesită x pentru a accesa)

---


### PI-11: chmod octal

```
╔══════════════════════════════════════════════════════════════════╗
║  🗳️ PI-11: Calculare chmod octal                                 ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  Vrei ca un script să aibă:                                      ║
║  - Owner: citire, scriere, executare                             ║
║  - Group: citire, executare                                      ║
║  - Others: doar executare                                        ║
║                                                                  ║
║  Ce chmod folosești?                                             ║
║                                                                  ║
║  A) chmod 751                                                    ║
║  B) chmod 754                                                    ║
║  C) chmod 715                                                    ║
║  D) chmod 741                                                    ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

Răspuns corect: A

Calcul:
```
Owner: rwx = 4+2+1 = 7
Group: r-x = 4+0+1 = 5
Others: --x = 0+0+1 = 1

Rezultat: 751
```

---


### PI-12: umask

```
╔══════════════════════════════════════════════════════════════════╗
║  🗳️ PI-12: Cum funcționează umask?                               ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  umask 027                                                       ║
║  touch newfile.txt                                               ║
║                                                                  ║
║  Ce permisiuni va avea newfile.txt?                              ║
║                                                                  ║
║  A) 027 (----w-rwx)                                              ║
║  B) 640 (rw-r-----)                                              ║
║  C) 750 (rwxr-x---)                                              ║
║  D) 027 nu e un umask valid                                      ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

Răspuns corect: B

Explicație:
umask ELIMINĂ biți din permisiunile default:
- Default fișiere: 666 (rw-rw-rw-)
- umask: 027
- Rezultat: 666 - 027 = 640 (rw-r-----)

Detaliu calcul:
```
  666 = rw-rw-rw-
- 027 = ---w--rwx
= 640 = rw-r-----
```

---


### PI-13: SUID

```
╔══════════════════════════════════════════════════════════════════╗
║  🗳️ PI-13: Ce înseamnă SUID?                                     ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  ls -l /usr/bin/passwd                                           ║
║  -rwsr-xr-x 1 root root ... /usr/bin/passwd                      ║
║                                                                  ║
║  Ce înseamnă 's' în poziția owner execute?                       ║
║                                                                  ║
║  A) Fișierul este un symlink                                     ║
║  B) Fișierul rulează cu permisiunile owner-ului (root)           ║
║  C) Fișierul este sticky (nu poate fi șters)                     ║
║  D) Fișierul este shared între useri                             ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

Răspuns corect: B

Explicație:
SUID (Set User ID) face ca procesul să ruleze cu permisiunile owner-ului fișierului, nu ale utilizatorului care îl execută.

De ce /usr/bin/passwd are SUID?
- passwd trebuie să modifice /etc/shadow
- /etc/shadow e owned by root și nu e writable de useri normali
- Cu SUID, când rulezi passwd, procesul are permisiunile lui root

---


### PI-14: Sticky Bit

```
╔══════════════════════════════════════════════════════════════════╗
║  🗳️ PI-14: Sticky Bit pe /tmp                                    ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  ls -ld /tmp                                                     ║
║  drwxrwxrwt 15 root root ... /tmp                                ║
║                                                                  ║
║  User "alice" creează /tmp/alice_file.txt                        ║
║  User "bob" încearcă: rm /tmp/alice_file.txt                     ║
║                                                                  ║
║  Ce se întâmplă?                                                 ║
║                                                                  ║
║  A) Fișierul e șters (bob are w pe /tmp)                         ║
║  B) Permission denied (sticky bit protejează)                    ║
║  C) Bob e întrebat dacă vrea să șteargă                          ║
║  D) Fișierul devine owned by bob                                 ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

Răspuns corect: B

Explicație:
Sticky bit ('t' în others execute) pe director:
- Toți pot crea fișiere (are w)
- Dar fiecare poate șterge DOAR fișierele proprii

Fără sticky bit, bob ar putea șterge orice din /tmp (pentru că are write pe director).

---


## CRON QUESTIONS


### PI-15: Sintaxă crontab

```
╔══════════════════════════════════════════════════════════════════╗
║  🗳️ PI-15: Interpretare crontab                                  ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  */15 9-17 * * 1-5 /path/to/script.sh                           ║
║                                                                  ║
║  Când rulează acest job?                                         ║
║                                                                  ║
║  A) La fiecare 15 minute, 24/7                                   ║
║  B) La fiecare 15 minute, între 9:00-17:00, Luni-Vineri          ║
║  C) La ora 15, între 9 și 17, zilele 1-5 ale lunii               ║
║  D) De 15 ori pe oră, în zilele lucrătoare                       ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

Răspuns corect: B

Explicație:
```
*/15    = la fiecare 15 minute (0, 15, 30, 45)
9-17    = orele 9:00-17:59
*       = orice zi din lună
*       = orice lună
1-5     = Luni-Vineri
```

Rezultat: Job-ul rulează la fiecare 15 minute în timpul programului de lucru, Luni-Vineri.

---


### PI-16: */5 vs 5

```
╔══════════════════════════════════════════════════════════════════╗
║  🗳️ PI-16: Diferența */5 vs 5                                    ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  Câmpul "minute" în crontab:                                     ║
║  A) */5 * * * *                                                  ║
║  B) 5 * * * *                                                    ║
║                                                                  ║
║  Care e diferența?                                               ║
║                                                                  ║
║  A) Sunt identice                                                ║
║  B) A: fiecare 5 min; B: minutul 5 al fiecărei ore              ║
║  C) A: minutul 5; B: la fiecare 5 minute                         ║
║  D) A: de 5 ori pe oră; B: o dată pe oră                         ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

Răspuns corect: B

Explicație:
- `*/5` = la fiecare 5 minute (0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55)
- `5` = doar la minutul 5 al fiecărei ore (14:05, 15:05, 16:05...)

---


### PI-17: Mediul cron

```
╔══════════════════════════════════════════════════════════════════╗
║  🗳️ PI-17: De ce nu merge job-ul meu cron?                       ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  În terminal: ./backup.sh funcționează perfect                   ║
║  În crontab:  * * * * * ./backup.sh - nu face nimic              ║
║                                                                  ║
║  Care e cea mai probabilă cauză?                                 ║
║                                                                  ║
║  A) Cron nu poate rula scripturi bash                            ║
║  B) Lipsește permisiunea de executare                            ║
║  C) Cale relativă - cron nu știe directorul curent               ║
║  D) Cron rulează doar dimineața                                  ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

Răspuns corect: C

Explicație:
Cron rulează cu un mediu minim:
- PATH limitat
- HOME poate să nu fie setat
- Nu există "director curent" în sensul sesiunii tale

Soluție:
```bash

# Folosește căi absolute
* * * * * /home/user/scripts/backup.sh


# Sau setează PATH în crontab
PATH=/usr/local/bin:/usr/bin:/bin
* * * * * backup.sh
```

---


### PI-18: @reboot

```
╔══════════════════════════════════════════════════════════════════╗
║  🗳️ PI-18: @reboot în crontab                                    ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  @reboot /home/user/start_service.sh                             ║
║                                                                  ║
║  Când rulează acest job?                                         ║
║                                                                  ║
║  A) La fiecare repornire a serviciului cron                      ║
║  B) La pornirea sistemului (boot)                                ║
║  C) La fiecare minut                                             ║
║  D) Când utilizatorul se loghează                                ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

Răspuns corect: B

Explicație:
`@reboot` este un string special care înseamnă "la pornirea sistemului".

Alte string-uri speciale:
- @yearly, @annually - 1 ianuarie
- @monthly - prima zi din lună
- @weekly - duminică
- @daily, @midnight - miezul nopții
- @hourly - la fiecare oră

---


## GHID DE UTILIZARE


### Tips pentru Instructor

1. Nu dezvălui răspunsul înainte de vot
2. Încurajează argumentarea în perechi
3. Folosește demonstrații live după explicație
4. Întreabă "Cine și-a schimbat răspunsul după discuție?"

---

*Material creat pentru Seminar 03 SO | ASE București - CSIE*


### Interpretare Rezultate

| Corect | Acțiune |
|--------|---------|
| >80% | Explicație scurtă, continuă |
| 40-80% | Discuție perechi, revot |
| <40% | Oprește, explică conceptul de la zero |


### Tips for Instructor

1. Don't reveal the answer before voting
2. Encourage argumentation in pairs
3. Use live demonstrations after explanation
4. Ask "Who changed their answer after discussion?"

---

*Material created for Seminar 3 OS | Bucharest UES - CSIE*

