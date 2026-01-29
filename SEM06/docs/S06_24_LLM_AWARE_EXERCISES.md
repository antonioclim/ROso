# LLM-Aware Exercises — CAPSTONE SEM06

> **Sisteme de Operare** | ASE București - CSIE  
> Seminar 6: Proiecte Integrate (Monitor, Backup, Deployer)

---

## Filosofia LLM-Aware

În era ChatGPT/Claude/Copilot, exercițiile tradiționale pot fi rezolvate instant de AI. Exercițiile LLM-aware sunt proiectate să:

1. **Necesite acces la sistem real** — AI nu poate rula comenzi pe calculatorul tău
2. **Implice output specific mașinii** — hostname, PID, timestamps unice
3. **Ceară debugging în timp real** — analiza unui proces care rulează
4. **Solicite decizii bazate pe context local** — ce servicii rulează ACUM
5. **Combine cod cu înțelegere** — nu doar "scrie cod", ci "explică de ce"

---

## Exercițiul 1: Forensics pe /proc (25 min)

### Context
Un proces "suspect" rulează pe sistem. Trebuie să-l investighezi folosind `/proc`.

### Sarcină

1. Găsește PID-ul procesului `bash` care rulează scriptul curent:
   ```bash
   echo "PID-ul meu: $$"
   ```

2. Investighează `/proc/$$`:
   ```bash
   ls /proc/$$/
   ```

3. Răspunde la întrebări (cu output real):

   a) Care e comanda completă cu care a fost lansat procesul?
   ```bash
   cat /proc/$$/cmdline | tr '\0' ' '
   # Răspunsul tău: _______________
   ```

   b) Ce variabile de environment are? (primele 5)
   ```bash
   head -5 /proc/$$/environ | tr '\0' '\n'
   # Răspunsul tău: _______________
   ```

   c) Ce file descriptori are deschiși?
   ```bash
   ls -la /proc/$$/fd/
   # Răspunsul tău: _______________
   ```

   d) Care e directorul de lucru curent?
   ```bash
   readlink /proc/$$/cwd
   # Răspunsul tău: _______________
   ```

### De ce AI nu poate rezolva
- Răspunsurile depind de sistemul TĂU
- PID-ul e unic pentru fiecare rulare
- Variabilele de environment sunt specifice sesiunii

### Evaluare
- 2p per răspuns corect cu output real
- -1p dacă output-ul pare fabricat

---

## Exercițiul 2: Trace System Calls (20 min)

### Context
Vrei să înțelegi ce face un script "sub capotă".

### Sarcină

1. Creează un script simplu:
   ```bash
   #!/bin/bash
   echo "Start"
   sleep 1
   cat /etc/hostname
   echo "End"
   ```

2. Rulează cu strace și capturează output:
   ```bash
   strace -f -o trace.log ./script.sh
   ```

3. Analizează trace.log și răspunde:

   a) Câte apeluri `write()` s-au făcut? Lista primele 3:
   ```bash
   grep "^write" trace.log | head -3
   # Răspunsul tău: _______________
   ```

   b) Ce apel de sistem deschide /etc/hostname?
   ```bash
   grep "hostname" trace.log
   # Răspunsul tău: _______________
   ```

   c) Ce syscall implementează `sleep 1`?
   ```bash
   grep -E "nanosleep|clock_nanosleep" trace.log
   # Răspunsul tău: _______________
   ```

### De ce AI nu poate rezolva
- strace output e specific kernel-ului/versiunii
- Adresele de memorie și file descriptori sunt unici
- Timestamp-urile sunt reale

### Evaluare
- Trebuie să atașezi trace.log (sau fragmente relevante)
- Output fabricat = 0p

---

## Exercițiul 3: Performance Detective (30 min)

### Context
Sistemul tău e "lent". Investighează cu tool-urile învățate.

### Sarcină

1. Captează starea sistemului în acest moment:
   ```bash
   # CPU
   grep "^cpu " /proc/stat
   
   # Memory
   grep -E "^(MemTotal|MemFree|MemAvailable|Buffers|Cached)" /proc/meminfo
   
   # Load average
   cat /proc/loadavg
   
   # Top 5 procese după CPU
   ps aux --sort=-%cpu | head -6
   ```

2. Rulează un "stress test" simplu:
   ```bash
   # Creează load temporar
   dd if=/dev/zero of=/dev/null bs=1M count=1000 &
   STRESS_PID=$!
   sleep 5
   ```

3. Captează din nou starea și compară:
   ```bash
   # CPU după stress
   grep "^cpu " /proc/stat
   
   # Load average după stress
   cat /proc/loadavg
   ```

4. Oprește stress-ul:
   ```bash
   kill $STRESS_PID 2>/dev/null
   ```

5. Răspunde:
   - Care valoare din /proc/stat s-a schimbat cel mai mult? De ce?
   - Ce s-a întâmplat cu load average?
   - Identifică procesul dd în output-ul ps. Care e %CPU?

### De ce AI nu poate rezolva
- Valorile sunt specifice hardware-ului tău
- Momentul capturii afectează rezultatele
- Load average depinde de numărul de core-uri

---

## Exercițiul 4: Debug Live (20 min)

### Context
Ai un script cu bug-uri. Găsește-le FĂRĂ să le corectezi înainte de analiză.

### Script cu Bug-uri

```bash
#!/bin/bash
# save as: buggy.sh

LOG_FILE = "/tmp/debug.log"

process_file() {
    local file=$1
    if [ -f $file ]; then
        cat $file | wc -l
    fi
}

main() {
    for f in *.txt
        process_file $f
    done
}

main
```

### Sarcină

1. Salvează scriptul și încearcă să-l rulezi
2. Documentează FIECARE eroare în ordinea în care apare:
   ```
   Eroare 1: Linia X, mesaj: "..."
   Cauză: ___
   
   Eroare 2: ...
   ```

3. Corectează erorile una câte una, rulând după fiecare corecție
4. Documentează soluția pentru fiecare

### De ce AI nu poate rezolva
- Mesajele de eroare exacte depind de versiunea Bash
- Ordinea în care descoperi erorile e importantă
- AI poate corecta instant, dar NU poate documenta procesul de debugging

### Evaluare
- Proces de debugging documentat pas cu pas: 10p
- Doar codul corectat fără proces: 3p

---

## Exercițiul 5: Monitor Your Machine (35 min)

### Context
Creează un monitor personalizat pentru CALCULATORUL TĂU.

### Cerințe

1. Scriptul trebuie să afișeze:
   - Hostname-ul real
   - Uptime în format human-readable
   - Utilizare CPU (calculată, nu din top)
   - Top 3 procese după memorie (cu nume reale de pe sistemul tău)
   - Spațiu liber pe / (procentaj real)

2. Output-ul trebuie să includă timestamp-ul exact al rulării

3. Rulează scriptul de 3 ori la interval de 1 minut și salvează output-ul

### Template

```bash
#!/bin/bash
# monitor_my_machine.sh

echo "=== SYSTEM MONITOR ==="
echo "Time: $(date '+%Y-%m-%d %H:%M:%S')"
echo "Host: $(hostname)"
echo ""

# TODO: Implementează restul
# Fiecare valoare trebuie să fie REALĂ de pe sistemul tău
```

### Livrabil
- Scriptul complet
- 3 output-uri consecutive (dovedind că rulează pe sistemul real)

### De ce AI nu poate rezolva
- Hostname-ul e unic
- Top 3 procese variază în timp
- Timestamp-urile trebuie să fie consecutive la ~1 minut distanță

---

## Exercițiul 6: Explain This Code (15 min)

### Context
Primești acest script și trebuie să explici ce face FĂRĂ să-l rulezi.

```bash
#!/bin/bash
set -euo pipefail

readonly LOCK="/var/run/$(basename "$0").lock"

cleanup() { rm -f "$LOCK"; }
trap cleanup EXIT

exec 200>"$LOCK"
flock -n 200 || { echo "Already running"; exit 1; }
echo $$ >&200

while :; do
    find /tmp -type f -mmin +60 -delete 2>/dev/null
    sleep 3600
done
```

### Sarcină

1. Explică fiecare secțiune în cuvintele tale:
   - Ce face `exec 200>"$LOCK"`?
   - Ce e `flock -n 200` și de ce e necesar?
   - Ce face `echo $$ >&200`?
   - Ce curăță bucla while și cât de des?

2. Răspunde:
   - Ce se întâmplă dacă rulezi scriptul de două ori simultan?
   - De ce e trap-ul important aici?
   - Care e problema de securitate potențială?

### De ce AI nu poate rezolva (bine)
- AI poate explica generic, dar nu poate demonstra înțelegere
- Urmărim explicația TA, nu una copiată
- Întrebările sunt deschise și evaluează raționamentul

---

## Exercițiul 7: Reverse Engineering (25 min)

### Context
Ai doar output-ul unui script. Recreează scriptul.

### Output Capturat

```
$ ./mystery.sh /var/log
=== Directory Analysis: /var/log ===
Total files: 47
Total size: 12M
Largest file: /var/log/syslog (2.1M)
Oldest file: /var/log/bootstrap.log (45 days)
File types:
  - .log: 23 files
  - .gz: 15 files
  - (no ext): 9 files
```

### Sarcină

1. Scrie un script care produce output SIMILAR pentru /var/log (sau alt director de pe sistemul tău)

2. Scriptul trebuie să:
   - Accepte un director ca argument
   - Calculeze statisticile afișate
   - Formateze output-ul la fel

3. Rulează pe sistemul tău și atașează output-ul real

### De ce AI nu poate rezolva
- Output-ul final trebuie să fie de pe sistemul tău
- Numerele vor fi diferite
- AI nu poate verifica dacă codul produce output-ul așteptat

---

## Matricea de Evaluare

| Exercițiu | Timp | Puncte | Ce demonstrează |
|-----------|------|--------|-----------------|
| 1. Forensics /proc | 25 min | 10p | Înțelegere /proc |
| 2. Trace syscalls | 20 min | 10p | Debugging low-level |
| 3. Performance | 30 min | 15p | Monitoring real |
| 4. Debug live | 20 min | 10p | Proces de debugging |
| 5. Monitor custom | 35 min | 20p | Integrare concepte |
| 6. Explain code | 15 min | 15p | Înțelegere profundă |
| 7. Reverse eng. | 25 min | 20p | Sinteză |

---

## Cum să Detectezi Soluții AI

Indicatori că soluția e generată de AI:

1. **Output generic** — hostname "ubuntu-server", PID 1234
2. **Timestamps rotunde** — exact :00:00
3. **Prea perfect** — zero typos, structură impecabilă
4. **Valori "convenabile"** — CPU exact 25%, memorie exact 50%
5. **Lipsește procesul** — doar rezultatul final, fără pași intermediari

### Ce să ceri studenților

- Screenshot-uri cu terminal (greu de fabricat)
- Fișiere .log atașate (cu timestamps reale)
- Explicații în propriile cuvinte
- Demonstrații live în seminar

---

*Document generat pentru SEM06 CAPSTONE — Sisteme de Operare*  
*ASE București - CSIE | 2024-2025*
