# Ghid pentru instructor — CAPSTONE SEM06

> **Sisteme de Operare** | ASE București - CSIE  
> Seminarul 6: Proiecte integrate (Monitor, Backup, Deployer)

---

## Prezentare generală a sesiunii

| Atribut | Valoare |
|-----------|-------|
| Durată | 100 minute (2 ore academice) |
| Format | Sesiune de laborator cu demonstrații |
| Dimensiune grup | 20–30 studenți |
| Prerechizite | finalizarea SEM01–SEM05 |
| Echipament | Ubuntu 22.04 (WSL2 sau VM), proiector |

---

## Rezultate ale învățării pentru această sesiune

La finalul seminarului, studenții vor putea:

1. **LO6.1** să proiecteze o arhitectură modulară pentru scripturi Bash
2. **LO6.2** să implementeze tratarea erorilor cu trap și coduri de ieșire
3. **LO6.3** să construiască sisteme de jurnalizare cu niveluri de severitate
4. **LO6.7** să aplice strategii de deployment (rolling, blue-green)
5. **LO6.8** să implementeze health checks cu retry și backoff

---

## Cronologia sesiunii (100 minute)

| Timp | Durată | Activitate | Materiale | Note |
|------|----------|----------|-----------|-------|
| 0:00 | 8 min | **Hook:** „Server crash la 3 AM” | S06_08_SPECTACULAR_DEMOS.md | Captează atenția printr-un scenariu real |
| 0:08 | 12 min | **Peer Instruction:** PI-01, PI-02 | S06_03_PEER_INSTRUCTION.md | Atribuire variabile și ghilimele |
| 0:20 | 20 min | **Live Coding:** bazele Monitor | S06_05_LIVE_CODING_GUIDE.md | Construire incrementală |
| 0:40 | 10 min | **Sprint:** curățare cu trap (perechi) | S06_06_SPRINT_EXERCISES.md | Protocol Pair Programming |
| 0:50 | 5 min | *Pauză* | — | Studenții se relaxează |
| 0:55 | 15 min | **Demo:** backup incremental | projects/backup/ | Evidențiază find -newer |
| 1:10 | 12 min | **Parsons:** PP-01, PP-02 | S06_04_PARSONS_PROBLEMS.md | Identifică distractorii |
| 1:22 | 10 min | **Discuție:** strategii de deployment | projects/S06_P07_Deployment_Strategies.md | Rolling vs Blue-Green |
| 1:32 | 5 min | **Autoevaluare** | S06_10_SELF_ASSESSMENT_REFLECTION.md | Checklist rapid |
| 1:37 | 3 min | **Încheiere + temă** | homework/S06_01_HOMEWORK_CAPSTONE.md | Așteptări explicite |

---

## Hook de deschidere (8 minute)

### Scenariu: „Server crash la 3 AM”

> „Imaginați-vă că sunteți de gardă. Telefonul vibrează la 3 AM — serverul de producție este indisponibil.  
> Nu există monitorizare. Nu există backup recent. Ultima instalare manuală a durat 4 ore.  
> Cum preveniți să se repete?”

**Întrebări pentru discuție:**
- Ce informații aveți nevoie mai întâi? (Monitor)
- Cum recuperați datele? (Backup)
- Cum deployați o corecție în siguranță? (Deployer)

**Tranziție:** „Astăzi construim instrumente care rezolvă exact aceste probleme.”

> **Notă de laborator:** acest hook este mai eficient dacă aveți o poveste reală. A mea include o bază de date coruptă la 2 AM și un backup vechi de 3 săptămâni. Studenții rețin *povești*, nu abstracțiuni.

---

## Facilitarea Peer Instruction

### PI-01: Atribuire variabile (Țintă: 35–45% corect la primul vot)

**Prezentare (1 min):**
```bash
BACKUP_DIR = "/var/backups"
echo "Backup directory: $BACKUP_DIR"
```

**Secvență:**
1. Prezentați codul (1 min)
2. Vot individual (1 min) — ridicare de mână sau clickere
3. Discuție în perechi (3 min) — „convinge‑ți colegul”
4. Re-vot (30 sec)
5. Explicație (2 min)

**Punct didactic cheie:** Bash NU permite spații în jurul `=` la atribuiri. Aceasta îi încurcă pe cei care vin din Python sau JavaScript.

### PI-02: Ghilimele (Țintă: 50–60% corect)

Accent pe diferența dintre `"$VAR"` (expansiune) și `'$VAR'` (literal).

> **Capcană frecventă:** studenții rezolvă corect izolat, dar omit ulterior în scripturi mai lungi. Automatismul se formează în timp.

---

## Sesiunea de live coding

### Principii de urmat

1. **Tastați totul live** — fără copy‑paste (studenții trebuie să vadă cum apar erorile)
2. **Introduceți erori intenționat** — lăsați studenții să le observe
3. **Predicție înainte de execuție** — „Ce credeți că afișează?”
4. **Verbalizați raționamentul** — „Pun ghilimele pentru că…”

### Construirea scriptului Monitor (20 minute)

**Pasul 1: Schelet (3 min)**
```bash
#!/bin/bash
set -euo pipefail

echo "System Monitor v0.1"
```
*Verificare:* scriptul rulează și afișează mesajul.

**Pasul 2: Citirea CPU (5 min)**
```bash
# Read from /proc/stat
read -r cpu user nice system idle rest < /proc/stat
total=$((user + nice + system + idle))
usage=$((100 * (total - idle) / total))
echo "CPU: ${usage}%"
```
*Întrebare:* „Ce procent vă așteptați?” (majoritatea ghicesc greșit la prima încercare.)

**Pasul 3: Adăugarea unei funcții (5 min)**
```bash
get_cpu_usage() {
    read -r cpu user nice system idle rest < /proc/stat
    local total=$((user + nice + system + idle))
    echo $((100 * (total - idle) / total))
}

echo "CPU: $(get_cpu_usage)%"
```
*Punct didactic:* funcții cu variabile locale. Cuvântul-cheie `local` contează.

**Pasul 4: Adăugarea trap (5 min)**
```bash
cleanup() {
    echo "Cleaning up..."
}
trap cleanup EXIT

# Rest of script...
```
*Demonstrație:* apăsați Ctrl+C — cleanup rulează totuși. Pentru mulți studenți acesta este momentul „aha”.

---

## Facilitarea exercițiilor de tip sprint

### Protocol Pair Programming

Înainte de Sprint 1:

1. **Formați perechi** — studenți vecini
2. **Stabiliți rolurile:**
   - Studentul din stânga: Driver la început
   - Studentul din dreapta: Navigator la început
3. **Setați timer:** 5 minute, apoi schimbare
4. **Reamintiți:** Navigatorul revizuiește, Driverul tastează. Fără „backseat driving”.

### Sprint 1: Curățare cu trap

**Erori tipice de urmărit:**
- omiterea definirii funcției înainte de trap
- spații la atribuire: `TEMP_DIR = $(mktemp)`
- lipsa ghilimelelor în jurul `$TEMP_DIR`

**Comandă de verificare:**
```bash
./sprint1.sh &
PID=$!
sleep 2
kill -INT $PID
sleep 1
ls /tmp/sprint_* 2>/dev/null || echo "Cleanup worked"
```

---

## Dificultăți frecvente ale studenților

| Problemă | Simptome | Soluție |
|---------|----------|----------|
| „trap nu funcționează” | cleanup nu rulează niciodată | Verificați: funcția este definită înainte de trap? |
| „find -newer nu găsește nimic” | output gol | Există fișierul cu timestamp? Rulați `touch` mai întâi |
| „spații la atribuire” | `command not found` | Demonstrație explicită: `VAR=val` vs `VAR = val` |
| „variabilă goală” | output gol | lipsește `$` sau ghilimele greșite |
| „Permission denied” | scriptul nu rulează | `chmod +x script.sh` |
| „set -e se oprește prea devreme” | scriptul iese neașteptat | identificați comanda eșuată cu `echo $?` |

> **Intervenție rapidă:** păstrați un exemplu de „greșeli tipice” cu erori anonimizate. Faptul că și alții greșesc reduce anxietatea.

---

## Predare diferențiată

### Pentru studenți cu dificultăți

- Concentrați-vă doar pe **proiectul Monitor**
- Omiteți complet Deployer
- Furnizați snippet‑uri completate pentru modificare
- Lucrați în pereche cu un student mai avansat
- Reduceți domeniul sprintului la handler‑ul de trap

### Pentru studenți avansați

- Provocare: implementați o combinație Blue-Green + Canary
- Adăugați format de output JSON în Monitor
- Implementați exponential backoff în health check
- Scrieți teste unitare pentru funcții utilitare
- Explorați integrarea cu systemd timer

---

## Puncte de verificare pentru evaluare

### Verificări rapide în timpul sesiunii

| Timp | Verificare | Metodă |
|------|-------|--------|
| 0:20 | Poate explica sintaxa trap | Întrebați direct 2–3 studenți |
| 0:40 | Sprint 1 finalizat | Verificare vizuală pe ecrane |
| 1:10 | Înțelege find -newer | Thumbs up/down |
| 1:32 | Poate compara Rolling vs Blue-Green | Discuție |

### Exit ticket (ultimele 3 minute)

Studenții scriu pe hârtie:
1. Un lucru învățat astăzi
2. Un lucru care încă este neclar
3. Evaluarea încrederii (1–5) pentru implementarea unui handler de trap

> **Notă de laborator:** citiți aceste răspunsuri înainte de sesiunea următoare. Răspunsurile „neclar” indică ce trebuie reluat.

---

## Checklist de materiale

Înainte de sesiune, verificați:

- [ ] Terminal Ubuntu accesibil (WSL2 sau VM)
- [ ] `shellcheck` instalat (`sudo apt install shellcheck`)
- [ ] Fișierele proiectului extrase în `/home/student/SEM06`
- [ ] `/proc/stat` lizibil (ar trebui să fie întotdeauna)
- [ ] Proiector conectat pentru live coding
- [ ] Timer vizibil pentru Peer Instruction

---

## Note post-sesiune

### Ce a funcționat bine

(Înregistrați după fiecare sesiune)

### Ce trebuie îmbunătățit

(Înregistrați după fiecare sesiune)

### Întrebări ale studenților de adresat data viitoare

(Capturați întrebările la care nu ați putut răspunde complet)

---

## Resurse pentru instructor

### Referință rapidă

- GNU Bash Manual: https://www.gnu.org/software/bash/manual/
- ShellCheck wiki: https://www.shellcheck.net/wiki/
- Documentația Linux /proc: `man 5 proc`

### Referințe pedagogice

- Brown & Wilson (2018). *Ten Quick Tips for Teaching Programming*
- Mazur, E. (1997). *Peer Instruction: A User's Manual*
- Parsons, D. (2006). *Parson's Programming Puzzles*

---

## Contact și suport

- **Consultații:** după seminar sau cu programare
- **Întrebări:** deschideți un issue în depozitul cursului
- **Forum:** platforma de e‑learning a facultății

---

*Ghid pentru instructor — SEM06 CAPSTONE — Sisteme de Operare*  
*ASE București - CSIE | 2024-2025*
