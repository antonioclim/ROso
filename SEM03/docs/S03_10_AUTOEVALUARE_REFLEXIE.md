# AUTOEVALUARE ȘI REFLECȚIE: Seminarul 03
## Sisteme de Operare | ASE București - CSIE

> Scop: Evaluează-ți nivelul de înțelegere și identifică zonele care necesită practică suplimentară

---

# CUPRINS

1. [Checklist Competențe per Modul](#-checklist-competențe)
2. [Întrebări de Auto-Evaluare](#-întrebări-de-auto-evaluare)
3. [Exerciții de Reflecție](#-exerciții-de-reflecție)
4. [Plan de Studiu Individual](#-plan-de-studiu-individual)
5. [Jurnal de Învățare](#-jurnal-de-învățare)

---

# CHECKLIST COMPETENȚE

## MODULUL 1: find și xargs

### Nivel BAZĂ (Trebuie să pot)
| # | Competență | Pot? | Exemple |
|---|------------|:----:|---------|
| 1.1 | Caut fișiere după nume | ☐ | `find . -name "*.txt"` |
| 1.2 | Caut fișiere după tip (f/d/l) | ☐ | `find . -type f` |
| 1.3 | Caut fișiere după dimensiune | ☐ | `find . -size +10M` |
| 1.4 | Caut fișiere modificate recent | ☐ | `find . -mtime -7` |
| 1.5 | Execut o comandă pentru fiecare rezultat | ☐ | `find . -exec ls -l {} \;` |

### Nivel INTERMEDIAR (Ar trebui să pot)
| # | Competență | Pot? | Exemple |
|---|------------|:----:|---------|
| 1.6 | Combin criterii cu AND | ☐ | `find . -type f -name "*.log"` |
| 1.7 | Combin criterii cu OR | ☐ | `find . \( -name "*.c" -o -name "*.h" \)` |
| 1.8 | Folosesc -exec cu + pentru eficiență | ☐ | `find . -name "*.txt" -exec cat {} +` |
| 1.9 | Folosesc xargs pentru procesare batch | ☐ | `find . -name "*.txt" \| xargs wc -l` |
| 1.10 | Gestionez fișiere cu spații în nume | ☐ | `find . -print0 \| xargs -0` |

### Nivel AVANSAT (Bonus)
| # | Competență | Pot? | Exemple |
|---|------------|:----:|---------|
| 1.11 | Folosesc -printf pentru output custom | ☐ | `find . -printf '%M %u %p\n'` |
| 1.12 | Paralelizez cu xargs -P | ☐ | `find . \| xargs -P4 -I{} process {}` |
| 1.13 | Caut după permisiuni specifice | ☐ | `find . -perm -u+x` |
| 1.14 | Înțeleg diferența find vs locate | ☐ | Live search vs database |

Scor Modul 1: ___/14 competențe

---

## MODULUL 2: Parametri Script și getopts

### Nivel BAZĂ (Trebuie să pot)
| # | Competență | Pot? | Exemple |
|---|------------|:----:|---------|
| 2.1 | Accesez argumentele $1, $2, ... | ☐ | `echo "Primul: $1"` |
| 2.2 | Verific numărul de argumente cu $# | ☐ | `if [ $# -lt 2 ]; then` |
| 2.3 | Iterez prin argumente cu "$@" | ☐ | `for arg in "$@"; do` |
| 2.4 | Folosesc shift pentru procesare | ☐ | `while [ $# -gt 0 ]; do shift` |
| 2.5 | Setez valori default | ☐ | `OUTPUT=${1:-"default.txt"}` |

### Nivel INTERMEDIAR (Ar trebui să pot)
| # | Competență | Pot? | Exemple |
|---|------------|:----:|---------|
| 2.6 | Înțeleg diferența "$@" vs "$*" | ☐ | Arrays vs single string |
| 2.7 | Folosesc getopts pentru opțiuni scurte | ☐ | `while getopts "hvo:" opt` |
| 2.8 | Gestionez OPTARG pentru valori | ☐ | `o) output="$OPTARG" ;;` |
| 2.9 | Folosesc shift cu OPTIND | ☐ | `shift $((OPTIND-1))` |
| 2.10 | Scriu funcții usage() clare | ☐ | Help message formatat |

### Nivel AVANSAT (Bonus)
| # | Competență | Pot? | Exemple |
|---|------------|:----:|---------|
| 2.11 | Parsez opțiuni lungi manual | ☐ | `case "$1" in --verbose)` |
| 2.12 | Combin opțiuni scurte și lungi | ☐ | `-v` și `--verbose` |
| 2.13 | Validez tipurile argumentelor | ☐ | Verific dacă e număr |
| 2.14 | Gestionez `--` pentru end of options | ☐ | `--) shift; break ;;` |

Scor Modul 2: ___/14 competențe

---

## MODULUL 3: Permisiuni Unix

### Nivel BAZĂ (Trebuie să pot)
| # | Competență | Pot? | Exemple |
|---|------------|:----:|---------|
| 3.1 | Citesc și interpretez rwxr-xr-- | ☐ | Owner: rwx, Group: r-x, Others: r-- |
| 3.2 | Calculez permisiuni octal | ☐ | rwxr-xr-- = 754 |
| 3.3 | Folosesc chmod cu octal | ☐ | `chmod 644 file.txt` |
| 3.4 | Folosesc chmod cu simbolic | ☐ | `chmod u+x script.sh` |
| 3.5 | Înțeleg diferența x pe fișier vs director | ☐ | Execute vs Access |

### Nivel INTERMEDIAR (Ar trebui să pot)
| # | Competență | Pot? | Exemple |
|---|------------|:----:|---------|
| 3.6 | Calculez umask și efectul său | ☐ | umask 022 → fișiere 644 |
| 3.7 | Schimb owner cu chown | ☐ | `chown user:group file` |
| 3.8 | Aplic permisiuni recursiv corect | ☐ | `chmod -R u+rwX,go-w dir/` |
| 3.9 | Înțeleg de ce avem nevoie de w pe dir pt delete | ☐ | Directory entry control |
| 3.10 | Identific fișiere cu permisiuni periculoase | ☐ | 777, world-writable |

### Nivel AVANSAT (Bonus)
| # | Competență | Pot? | Exemple |
|---|------------|:----:|---------|
| 3.11 | Înțeleg și configurez SUID | ☐ | `chmod u+s`, 4755 |
| 3.12 | Înțeleg și configurez SGID pe directoare | ☐ | `chmod g+s dir/` |
| 3.13 | Înțeleg și configurez Sticky Bit | ☐ | `chmod +t /shared` |
| 3.14 | Pot configura un director partajat securizat | ☐ | SGID + permisiuni corecte |

Scor Modul 3: ___/14 competențe

---

## MODULUL 4: Cron și Automatizare

### Nivel BAZĂ (Trebuie să pot)
| # | Competență | Pot? | Exemple |
|---|------------|:----:|---------|
| 4.1 | Înțeleg formatul celor 5 câmpuri | ☐ | min hour dom month dow |
| 4.2 | Scriu expresii cron simple | ☐ | `0 3 * * *` = zilnic 3 AM |
| 4.3 | Editez crontab cu `crontab -e` | ☐ | Deschide editorul |
| 4.4 | Listez crontab cu `crontab -l` | ☐ | Afișează jobs |
| 4.5 | Folosesc căi absolute în cron | ☐ | `/home/user/script.sh` |

### Nivel INTERMEDIAR (Ar trebui să pot)
| # | Competență | Pot? | Exemple |
|---|------------|:----:|---------|
| 4.6 | Folosesc */N pentru intervale | ☐ | `*/15 * * * *` = la 15 min |
| 4.7 | Folosesc ranges și liste | ☐ | `0 9-17 * * 1-5` |
| 4.8 | Redirecționez output în log | ☐ | `>> log.txt 2>&1` |
| 4.9 | Înțeleg mediul limitat cron | ☐ | PATH, variabile diferite |
| 4.10 | Folosesc string-uri speciale | ☐ | `@daily`, `@reboot` |

### Nivel AVANSAT (Bonus)
| # | Competență | Pot? | Exemple |
|---|------------|:----:|---------|
| 4.11 | Previn execuții simultane cu flock | ☐ | `flock -n /tmp/lock` |
| 4.12 | Configurez notificări pentru erori | ☐ | MAILTO sau mail în script |
| 4.13 | Folosesc `at` pentru jobs one-time | ☐ | `at now + 2 hours` |
| 4.14 | Debug cron jobs efectiv | ☐ | Logs, test manual |

Scor Modul 4: ___/14 competențe

---

# ÎNTREBĂRI DE AUTO-EVALUARE

## Secțiunea A: find și xargs

A1. Scrie comanda find care găsește toate fișierele `.log` mai mari de 100MB modificate în ultima săptămână:

```bash
# Răspunsul tău:

```

<details>
<summary>💡 Verifică răspunsul</summary>

```bash
find /var/log -type f -name "*.log" -size +100M -mtime -7
```
</details>

---

A2. De ce această comandă poate eșua pentru fișiere cu spații în nume?
```bash
find . -name "*.txt" | xargs rm
```

```
# Explicația ta:

```

<details>
<summary>💡 Verifică răspunsul</summary>

xargs împarte input-ul după spații. Un fișier "my document.txt" va fi interpretat ca două argumente: "my" și "document.txt", ambele inexistente.

Soluție: `find . -name "*.txt" -print0 | xargs -0 rm`
</details>

---

A3. Care este diferența între `-exec {} \;` și `-exec {} +`?

```
# Răspunsul tău:

```

<details>
<summary>💡 Verifică răspunsul</summary>

- `\;` - Execută comanda o dată pentru FIECARE fișier găsit (lent, multe procese)
- `+` - Execută comanda O SINGURĂ DATĂ cu toate fișierele ca argumente (rapid, un proces)

Exemplu: pentru 1000 fișiere, `\;` creează 1000 procese, `+` creează 1.
</details>

---

## Secțiunea B: Parametri Script

B1. Ce afișează acest script când rulat cu `./script.sh "hello world" test`?
```bash
#!/bin/bash
echo "Argumente: $#"
for arg in $@; do
    echo "- $arg"
done
```

```
# Răspunsul tău:

```

<details>
<summary>💡 Verifică răspunsul</summary>

```
Argumente: 2

Trei lucruri contează aici: hello, world, și test.

```

Problema: `$@` fără ghilimele face word splitting!
Corect: `for arg in "$@"` ar afișa `- hello world` și `- test`
</details>

---

B2. Completează getopts pentru opțiunile: -h (help), -v (verbose), -o FILE (output):

```bash
#!/bin/bash
while getopts "____" opt; do
    case $opt in
        # completează
    esac
done
```

<details>
<summary>💡 Verifică răspunsul</summary>

```bash
while getopts ":hvo:" opt; do
    case $opt in
        h) usage; exit 0 ;;
        v) verbose=true ;;
        o) output="$OPTARG" ;;
        :) echo "Opțiunea -$OPTARG necesită argument"; exit 1 ;;
        \?) echo "Opțiune invalidă: -$OPTARG"; exit 1 ;;
    esac
done
shift $((OPTIND - 1))
```
</details>

---

B3. Ce face `${filename%.*}` dacă `filename="document.backup.tar.gz"`?

```
# Răspunsul tău:

```

<details>
<summary>💡 Verifică răspunsul</summary>

Rezultat: `document.backup.tar`

`%.*` șterge cel mai SCURT sufix care se potrivește cu `.*` (adică `.gz`).

Pentru a obține doar `document`, ai folosi `%%.*` (cel mai LUNG sufix).
</details>

---

## Secțiunea C: Permisiuni

C1. Calculează permisiunile octal pentru: `rwxr-x---`

```
# Calculul tău:

```

<details>
<summary>💡 Verifică răspunsul</summary>

```
Owner:  rwx = 4+2+1 = 7
Group:  r-x = 4+0+1 = 5
Others: --- = 0+0+0 = 0

Răspuns: 750
```
</details>

---

C2. Cu umask 027, ce permisiuni va avea un fișier nou creat?

```
# Calculul tău:

```

<details>
<summary>💡 Verifică răspunsul</summary>

```
Default fișiere: 666 (rw-rw-rw-)
umask:           027
─────────────────────
Rezultat:        640 (rw-r-----)

666 - 027 = 640
```

Verificare: `666` în binar este `110 110 110`, `027` este `000 010 111`
După aplicare umask: `110 100 000` = `640`
</details>

---

C3. De ce SUID pe un script bash nu funcționează ca pe un binary?

```
# Explicația ta:

```

<details>
<summary>💡 Verifică răspunsul</summary>

Din motive de **securitate**, Linux ignoră SUID pe scripturi interpretate.

Motivul: Race condition - între verificarea SUID și execuția scriptului, un atacator ar putea schimba conținutul.

Soluție: Creează un wrapper binary cu SUID care execută scriptul, sau folosește `sudo` cu permisiuni granulare.
</details>

---

C4. Explică ce face această secvență și de ce e importantă pentru directoare partajate:
```bash
chmod 2770 /shared
chgrp developers /shared
```

```
# Explicația ta:

```

<details>
<summary>💡 Verifică răspunsul</summary>

- `2` = SGID (Set Group ID)
- `770` = rwxrwx--- (owner și grup au full access, others nimic)
- `chgrp developers` = grupul devine "developers"

Efectul SGID pe director: Toate fișierele create în `/shared` vor avea automat grupul "developers", nu grupul primar al utilizatorului care le creează.

Fără SGID, fiecare user ar crea fișiere cu propriul grup, și alți membri nu ar avea acces.
</details>

---

## Secțiunea D: Cron

D1. Scrie expresia cron pentru: "La fiecare 15 minute, între 9 AM și 5 PM, de Luni până Vineri"

```
# Răspunsul tău:

```

<details>
<summary>💡 Verifică răspunsul</summary>

```
*/15 9-17 * * 1-5
```

- `*/15` = la fiecare 15 minute (0, 15, 30, 45)
- `9-17` = orele 9:00 - 17:00
- `* *` = orice zi și orice lună
- `1-5` = Luni (1) până Vineri (5)
</details>

---

D2. De ce acest cron job ar putea eșua?
```
0 3 * * * backup.sh >> /var/log/backup.log
```

```
# Probleme identificate:

```

<details>
<summary>💡 Verifică răspunsul</summary>

1. cale raportată la directorul curent (`cwd`) pentru `backup.sh` - cron nu știe unde e
2. **PATH** - cron are PATH minimal, comenzile din script pot eșua
3. Nu capturează stderr - erorile se pierd
4. Permisiuni - /var/log poate să nu fie writable pentru user

Varianta corectă:
```
PATH=/usr/local/bin:/usr/bin:/bin
0 3 * * * /home/user/scripts/backup.sh >> /var/log/backup.log 2>&1
```
</details>

---

D3. Cum previi ca un cron job să se execute de mai multe ori simultan dacă rulează prea mult?

```
# Soluția ta:

```

<details>
<summary>💡 Verifică răspunsul</summary>

Folosește **flock** pentru lock file:

```
0 * * * * flock -n /tmp/myjob.lock /path/to/script.sh
```


Principalele aspecte: `-n` = non-blocking (eșuează imediat dacă lock-ul e ocupat), `/tmp/myjob.lock` = fișierul de lock și dacă jobul anterior încă rulează, noul job nu va porni.


Alternativ în script:
```bash
LOCKFILE="/tmp/myscript.lock"
exec 200>$LOCKFILE
flock -n 200 || { echo "Already running"; exit 1; }
# restul scriptului...
```
</details>

---

# EXERCIȚII DE REFLECȚIE

## Reflecție 1: Momente "Aha!"

Descrie un concept din acest seminar care inițial părea confuz, dar acum are sens:

```
Conceptul:

Ce m-a ajutat să înțeleg:

Cum l-aș explica altcuiva:

```

---

## Reflecție 2: Conexiuni

Cum se leagă conceptele din acest seminar de cele anterioare (redirecționare, pipe-uri, bucle)?

```
Conexiune 1: find + xargs se leagă de pipe-uri pentru că...

Conexiune 2: Permisiunile se leagă de conceptul de utilizator pentru că...

Conexiune 3: Cron se leagă de scripting pentru că...

```

---

## Reflecție 3: Aplicații Practice

Gândește-te la 3 situații reale (la job, proiect personal) unde ai folosi:

```
1. find + xargs:

2. Script cu getopts:

3. Cron job:

```

---

## Reflecție 4: Greșeli de Evitat

Care sunt cele mai periculoase greșeli pe care le-ai putea face cu conceptele de azi?

```
1. Cu find:

2. Cu permisiuni:

3. Cu cron:

```

---

## Reflecție 5: Întrebări Rămase

Ce întrebări ai încă după acest seminar?

```
1.

2.

3.
```

---

# PLAN DE STUDIU INDIVIDUAL

## Săptămâna 1: Fundamentale

| Zi | Focus | Activitate | Timp |
|----|-------|------------|------|
| L | find basics | Exersează -name, -type, -size | 30 min |
| Ma | find avansat | Exersează -exec, operatori | 30 min |
| Mi | xargs | 10 comenzi find \| xargs | 30 min |
| J | Parametri | Scrie 3 scripturi cu $@ | 45 min |
| V | getopts | Modifică scripturile cu opțiuni | 45 min |
| S | Permisiuni | Exerciții chmod octal/simbolic | 30 min |
| D | Recapitulare | Refă exercițiile dificile | 30 min |

## Săptămâna 2: Consolidare

| Zi | Focus | Activitate | Timp |
|----|-------|------------|------|
| L | Permisiuni speciale | Configurează director partajat | 30 min |
| Ma | umask | Testează diverse umask | 20 min |
| Mi | Cron basics | 5 expresii cron | 30 min |
| J | Cron avansat | Cron job cu logging | 45 min |
| V | Integrare | Script complex cu toate | 60 min |
| S | LLM Practice | Evaluează cod generat | 30 min |
| D | Tema | Finalizare temă | 90 min |

---

# JURNAL DE ÎNVĂȚARE

## Sesiunea de azi

Data: ________________

Ce am învățat:
```

```

Ce a fost dificil:
```

```

Ce voi exersa mâine:
```

```

Rating înțelegere (1-5): ___

---

## Progres Cumulativ

| Modul | Înainte | După Seminar | După Practică |
|-------|:-------:|:------------:|:-------------:|
| find/xargs | ☐☐☐☐☐ | ☐☐☐☐☐ | ☐☐☐☐☐ |
| Parametri | ☐☐☐☐☐ | ☐☐☐☐☐ | ☐☐☐☐☐ |
| Permisiuni | ☐☐☐☐☐ | ☐☐☐☐☐ | ☐☐☐☐☐ |
| Cron | ☐☐☐☐☐ | ☐☐☐☐☐ | ☐☐☐☐☐ |

*(Bifează casete pentru a marca nivelul: 1=începător, 5=expert)*

---

# OBIECTIVE SMART PERSONALE

Completează pentru fiecare modul:

## Modul 1: find/xargs
Specific: Vreau să pot...
```

```
Measurable: Voi ști că am reușit când...
```

```
Achievable: Pașii pentru a ajunge acolo...
```

```
Relevant: E important pentru că...
```

```
Time-bound: Termen limită: _______________

---

## Modul 2: Parametri Script
Specific: Vreau să pot...
```

```
Deadline: _______________

---

## Modul 3: Permisiuni
Specific: Vreau să pot...
```

```
Deadline: _______________

---

## Modul 4: Cron
Specific: Vreau să pot...
```

```
Deadline: _______________

---

# CHECKLIST FINAL

Înainte de a considera seminarul complet, verifică:

- [ ] Am înțeles diferența între find și locate
- [ ] Pot scrie comenzi find complexe cu multiple criterii
- [ ] Știu când să folosesc xargs și cum să gestionez spațiile
- [ ] Înțeleg "$@" vs "$*" și folosesc corect ghilimelele
- [ ] Pot scrie un script cu getopts care validează argumente
- [ ] Calculez rapid permisiuni octal ↔ simbolic
- [ ] Înțeleg x pe director vs fișier
- [ ] Știu ce face umask și cum să-l setez
- [ ] Înțeleg SUID, SGID, Sticky și când să le folosesc
- [ ] Pot scrie expresii cron pentru orice program
- [ ] Știu best practices pentru cron jobs (PATH, logging, lock)
- [ ] Am completat tema de seminar
- [ ] Am întrebări clar formulate pentru sesiunea următoare

---

*Document generat pentru Seminarul 03 SO | ASE București - CSIE*
