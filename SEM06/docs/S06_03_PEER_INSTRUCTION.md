# Peer Instruction — CAPSTONE SEM06

> **Sisteme de Operare** | ASE București - CSIE  
> Seminar 6: Proiecte Integrate (Monitor, Backup, Deployer)

---

## Despre Peer Instruction

Peer Instruction este o metodă de învățare activă dezvoltată de Eric Mazur. Fiecare întrebare urmează ciclul:

1. **Prezentare** (1 min) — instructorul prezintă scenariul
2. **Vot individual** (1 min) — studenții răspund fără discuții
3. **Discuție în perechi** (3 min) — studenții își argumentează pozițiile
4. **Re-vot** (30 sec) — studenții votează din nou
5. **Explicație** (2 min) — instructorul clarifică răspunsul corect

Ținta: ~40-60% răspunsuri corecte la primul vot (suficient de provocator).

---

## PI-01: Spații la Atribuire

### Scenariu

Un student scrie următorul script:

```bash
#!/bin/bash
BACKUP_DIR = "/var/backups"
echo "Directorul de backup: $BACKUP_DIR"
```

### Întrebare

Ce se întâmplă când rulezi acest script?

### Opțiuni

| Opțiune | Răspuns |
|---------|---------|
| **A** | Afișează "Directorul de backup: /var/backups" |
| **B** | Eroare: "BACKUP_DIR: command not found" |
| **C** | Afișează "Directorul de backup: " (variabilă goală) |
| **D** | Eroare de sintaxă la linia 2 |

---

### Notă pentru instructor

**Răspuns corect: B**

**Țintă primul vot:** 35-45% corect

**Concept cheie:** În Bash, atribuirea variabilelor NU permite spații în jurul `=`. Cu spații, Bash interpretează `BACKUP_DIR` ca comandă și `=` ca argument.

**Distractori și misconceptii:**
- **A** — Ignoră că sintaxa e greșită, presupune că Bash e tolerant
- **C** — Confuzie cu variabile nedefinite (fără `set -u`)
- **D** — Răspuns parțial corect dar inexact (e runtime error, nu syntax error)

**Timing:** Prezentare 1min → Vot 1min → Discuție 3min → Revot 30sec → Explicație 2min

---

## PI-02: Ghilimele și Expansiune

### Scenariu

Care e diferența între aceste două comenzi?

```bash
# Comanda 1
echo "Utilizatorul curent: $USER"

# Comanda 2
echo 'Utilizatorul curent: $USER'
```

### Întrebare

Ce afișează fiecare comandă pentru utilizatorul "student"?

### Opțiuni

| Opțiune | Răspuns |
|---------|---------|
| **A** | Ambele afișează "Utilizatorul curent: student" |
| **B** | Prima: "...student", a doua: "...$USER" (literal) |
| **C** | Prima: "...$USER" (literal), a doua: "...student" |
| **D** | Ambele afișează "Utilizatorul curent: $USER" |

---

### Notă pentru instructor

**Răspuns corect: B**

**Țintă primul vot:** 50-60% corect

**Concept cheie:** Ghilimelele duble (`"`) permit expansiunea variabilelor. Ghilimelele simple (`'`) păstrează totul literal, inclusiv `$`.

**Distractori și misconceptii:**
- **A** — Nu înțelege diferența între tipurile de ghilimele
- **C** — Inversează comportamentul ghilimelelor
- **D** — Crede că ghilimelele blochează orice expansiune

**Demonstrație live:** `echo "HOME=$HOME"` vs `echo 'HOME=$HOME'`

---

## PI-03: Test Condiții — `[ ]` vs `[[ ]]`

### Scenariu

```bash
FILE="my file.txt"   # Fișier cu spațiu în nume

# Test 1
if [ -f $FILE ]; then echo "Există"; fi

# Test 2
if [[ -f $FILE ]]; then echo "Există"; fi
```

### Întrebare

Dacă fișierul "my file.txt" există, ce se întâmplă?

### Opțiuni

| Opțiune | Răspuns |
|---------|---------|
| **A** | Ambele afișează "Există" |
| **B** | Test 1 eșuează cu eroare, Test 2 afișează "Există" |
| **C** | Test 1 afișează "Există", Test 2 eșuează |
| **D** | Ambele eșuează cu eroare |

---

### Notă pentru instructor

**Răspuns corect: B**

**Țintă primul vot:** 30-40% corect

**Concept cheie:** `[ ]` (test POSIX) necesită ghilimele pentru variabile cu spații. `[[ ]]` (Bash builtin) gestionează automat spațiile.

**Detalii tehnice:**
- `[ -f $FILE ]` devine `[ -f my file.txt ]` — 3 argumente, eroare
- `[[ -f $FILE ]]` gestionează "my file.txt" ca un singur argument

**Distractori și misconceptii:**
- **A** — Nu înțelege word splitting în `[ ]`
- **C** — Inversează comportamentul
- **D** — Nu știe că `[[ ]]` e mai sigur

**Best practice:** Folosește mereu `[[ ]]` în Bash sau `"$VAR"` în `[ ]`.

---

## PI-04: Command Substitution

### Scenariu

Care e diferența între aceste două forme?

```bash
# Forma 1
files=`ls *.txt`

# Forma 2
files=$(ls *.txt)
```

### Întrebare

Care afirmație e corectă?

### Opțiuni

| Opțiune | Răspuns |
|---------|---------|
| **A** | Sunt identice în funcționalitate și stil |
| **B** | Forma 2 e preferată: poate fi imbricată și e mai lizibilă |
| **C** | Forma 1 e mai rapidă deoarece e mai veche |
| **D** | Forma 2 rulează comanda în subshell, Forma 1 nu |

---

### Notă pentru instructor

**Răspuns corect: B**

**Țintă primul vot:** 45-55% corect

**Concept cheie:** Ambele fac același lucru, dar `$()` e preferată pentru:
- Poate fi imbricată: `$(dirname $(which python))`
- Mai lizibilă în scripturi
- Nu confundă cu ghilimelele simple

**Distractori și misconceptii:**
- **A** — Funcționalitate identică, dar stil diferit
- **C** — Performanța e identică
- **D** — Ambele rulează în subshell

**Notă:** Backticks sunt legacy, încă funcționează dar evită-le în cod nou.

---

## PI-05: Trap și Cleanup

### Scenariu

```bash
#!/bin/bash
TEMP_FILE=$(mktemp)

cleanup() {
    rm -f "$TEMP_FILE"
    echo "Cleanup done"
}

trap cleanup EXIT

echo "Procesez date..."
# ... procesare ...
exit 0
```

### Întrebare

Când se execută funcția `cleanup`?

### Opțiuni

| Opțiune | Răspuns |
|---------|---------|
| **A** | Doar dacă scriptul se termină cu `exit 0` |
| **B** | Doar dacă utilizatorul apasă Ctrl+C |
| **C** | La orice terminare: exit normal, eroare sau Ctrl+C |
| **D** | Doar dacă apelezi explicit `cleanup` |

---

### Notă pentru instructor

**Răspuns corect: C**

**Țintă primul vot:** 40-50% corect

**Concept cheie:** Semnalul `EXIT` se declanșează la ORICE terminare a scriptului:
- `exit 0` sau `exit 1`
- Ctrl+C (după ce INT handler se execută)
- Eroare cu `set -e`
- Sfârșitul natural al scriptului

**Distractori și misconceptii:**
- **A** — EXIT nu verifică codul de ieșire
- **B** — Ctrl+C e SIGINT, nu EXIT (dar EXIT se execută după INT)
- **D** — trap automatizează apelul

**Pattern profesional:** Mereu folosește trap EXIT pentru cleanup de temp files.

---

## PI-06: Exit Codes în Pipe

### Scenariu

```bash
#!/bin/bash
set -e

cat inexistent.txt | grep "pattern" | wc -l
echo "Script continuă..."
```

### Întrebare

Ce se întâmplă dacă fișierul "inexistent.txt" nu există?

### Opțiuni

| Opțiune | Răspuns |
|---------|---------|
| **A** | Scriptul se oprește imediat după `cat` |
| **B** | Afișează eroare dar continuă și printează "Script continuă..." |
| **C** | Afișează "0" și "Script continuă..." |
| **D** | Depinde de setarea `pipefail` |

---

### Notă pentru instructor

**Răspuns corect: D**

**Țintă primul vot:** 25-35% corect (provocator!)

**Concept cheie:** `set -e` singur NU detectează erori în pipe (doar ultimul exit code contează). Cu `set -o pipefail`, pipe-ul returnează eroarea primei comenzi care eșuează.

**Detalii:**
- Fără pipefail: `wc -l` returnează 0, scriptul continuă
- Cu pipefail: `cat` returnează eroare, scriptul se oprește

**Distractori și misconceptii:**
- **A** — Corect doar cu pipefail
- **B** — Parțial corect fără pipefail
- **C** — Ignoră că e eroare la cat

**Best practice:** Mereu folosește `set -euo pipefail` la începutul scripturilor.

---

## PI-07: Find și -exec vs xargs

### Scenariu

Găsești fișiere și le procesezi:

```bash
# Varianta 1
find /logs -name "*.log" -exec rm {} \;

# Varianta 2
find /logs -name "*.log" | xargs rm
```

### Întrebare

Care e problema potențială cu Varianta 2?

### Opțiuni

| Opțiune | Răspuns |
|---------|---------|
| **A** | Nu există problemă, sunt identice |
| **B** | Varianta 2 eșuează la fișiere cu spații în nume |
| **C** | Varianta 2 e mai lentă din cauza pipe-ului |
| **D** | Varianta 2 nu funcționează cu `rm` |

---

### Notă pentru instructor

**Răspuns corect: B**

**Țintă primul vot:** 40-50% corect

**Concept cheie:** `xargs` implicit desparte input-ul pe spații și newlines. Un fișier "access log.txt" devine două argumente: "access" și "log.txt".

**Soluții:**
```bash
# Soluția 1: -print0 și xargs -0
find /logs -name "*.log" -print0 | xargs -0 rm

# Soluția 2: -exec direct
find /logs -name "*.log" -exec rm {} \;

# Soluția 3: -exec cu + (batch)
find /logs -name "*.log" -exec rm {} +
```

**Distractori și misconceptii:**
- **A** — Nu înțelege word splitting
- **C** — -exec \; e mai lent (un proces per fișier)
- **D** — xargs funcționează cu orice comandă

---

## PI-08: Logging Levels

### Scenariu

Un sistem de logging are nivelurile: DEBUG, INFO, WARN, ERROR.

```bash
LOG_LEVEL="WARN"

log_debug "Detalii procesare..."    # Se afișează?
log_info "Procesare începută"       # Se afișează?
log_warn "Disk 80% plin"            # Se afișează?
log_error "Conexiune eșuată"        # Se afișează?
```

### Întrebare

Cu `LOG_LEVEL="WARN"`, care mesaje se afișează?

### Opțiuni

| Opțiune | Răspuns |
|---------|---------|
| **A** | Doar WARN |
| **B** | WARN și ERROR |
| **C** | DEBUG, INFO, WARN |
| **D** | Toate mesajele |

---

### Notă pentru instructor

**Răspuns corect: B**

**Țintă primul vot:** 55-65% corect

**Concept cheie:** LOG_LEVEL setează pragul minim. Se afișează mesajele de la nivel egal sau superior:
- DEBUG < INFO < WARN < ERROR
- Cu WARN: afișează WARN + ERROR

**Distractori și misconceptii:**
- **A** — Nu înțelege că nivelurile sunt ierarhice
- **C** — Inversează logica (afișează cele mai puțin severe)
- **D** — Ignoră complet scopul LOG_LEVEL

**Analogie:** Ca un filtru de apă — lasă să treacă particulele mai mari decât pragul.

---

## PI-09: Health Check Pattern

### Scenariu

```bash
check_health() {
    local max_retries=3
    local retry=0
    
    while [[ $retry -lt $max_retries ]]; do
        if curl -sf http://localhost:8080/health; then
            return 0
        fi
        ((retry++))
        sleep 2
    done
    return 1
}
```

### Întrebare

Care e scopul sleep-ului între retry-uri?

### Opțiuni

| Opțiune | Răspuns |
|---------|---------|
| **A** | Reduce consumul de CPU al scriptului |
| **B** | Permite aplicației timp să pornească sau să se recupereze |
| **C** | Este obligatoriu în while loops în Bash |
| **D** | Previne timeout-ul curl |

---

### Notă pentru instructor

**Răspuns corect: B**

**Țintă primul vot:** 60-70% corect

**Concept cheie:** "Backoff" între retry-uri:
- Aplicația poate fi în pornire (slow start)
- Poate fi temporar supraîncărcată
- Retry imediat ar face spam și ar înrăutăți situația

**Pattern avansat:** Exponential backoff
```bash
sleep $((2 ** retry))  # 2, 4, 8 secunde
```

**Distractori și misconceptii:**
- **A** — CPU usage e neglijabil oricum
- **C** — sleep nu e obligatoriu
- **D** — curl are propriul timeout

---

## PI-10: Deployment Rollback

### Scenariu

Ai un deployment care a eșuat. Sistemul arată:

```
/app/releases/
├── v1.0.0/     # versiunea stabilă anterioară
├── v1.1.0/     # versiunea curentă (problematică)
└── current -> v1.1.0
```

### Întrebare

Care e cea mai sigură metodă de rollback?

### Opțiuni

| Opțiune | Răspuns |
|---------|---------|
| **A** | `rm -rf v1.1.0 && mv v1.0.0 current` |
| **B** | `ln -sf v1.0.0 current` |
| **C** | `rm current && ln -s v1.0.0 current` |
| **D** | `cp -r v1.0.0/* v1.1.0/` |

---

### Notă pentru instructor

**Răspuns corect: B**

**Țintă primul vot:** 35-45% corect

**Concept cheie:** `ln -sf` (symbolic link, force) este atomic:
- Înlocuiește symlink-ul într-o singură operație
- Zero downtime (nu există moment când current nu există)
- Păstrează v1.1.0 pentru investigație

**Distractori și misconceptii:**
- **A** — Distruge v1.1.0, mv nu creează symlink corect
- **C** — Între rm și ln există un gap (downtime!)
- **D** — Suprascrie în loc să facă rollback curat

**Pattern profesional:** Mereu păstrează release-urile vechi pentru rollback rapid.

---

## Sumar Tematic

| # | Subiect | Dificultate | Concept Testat |
|---|---------|-------------|----------------|
| PI-01 | Atribuire variabile | Ușor | Sintaxă `VAR=val` fără spații |
| PI-02 | Ghilimele | Ușor | `" "` vs `' '` și expansiune |
| PI-03 | Test condiții | Mediu | `[ ]` vs `[[ ]]` și word splitting |
| PI-04 | Command substitution | Ușor | Backticks vs `$()` |
| PI-05 | Trap cleanup | Mediu | Signal EXIT pentru cleanup |
| PI-06 | Exit codes în pipe | Greu | pipefail și error propagation |
| PI-07 | Find și xargs | Mediu | Spații în filenames |
| PI-08 | Logging levels | Ușor | Ierarhie DEBUG→ERROR |
| PI-09 | Health check | Mediu | Retry pattern cu backoff |
| PI-10 | Deployment rollback | Greu | Symlink atomic pentru rollback |

---

## Resurse

- Mazur, E. (1997). *Peer Instruction: A User's Manual*
- Brown & Wilson (2018). *Ten Quick Tips for Teaching Programming*
- GNU Bash Manual: https://www.gnu.org/software/bash/manual/

---

*Document generat pentru SEM06 CAPSTONE — Sisteme de Operare*  
*ASE București - CSIE | 2024-2025*
