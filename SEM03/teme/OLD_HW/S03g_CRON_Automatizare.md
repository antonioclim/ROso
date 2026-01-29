# S03_TC06 - CRON - Automatizare și Planificare Task-uri

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
- Înțeleagă sistemul cron pentru planificarea task-urilor
- Configureze job-uri cron pentru utilizatori și sistem
- Folosească at pentru task-uri one-time
- Implementeze automatizări profesionale

---


## 2. Formatul Crontab

### 2.1 Structura Liniei Crontab

```
┌───────────── minut (0-59)
│ ┌───────────── oră (0-23)
│ │ ┌───────────── zi din lună (1-31)
│ │ │ ┌───────────── lună (1-12 sau jan-dec)
│ │ │ │ ┌───────────── zi din săptămână (0-7, 0 și 7 = Duminică)
│ │ │ │ │
│ │ │ │ │
* * * * * comandă_de_executat
```

### 2.2 Valori Speciale

| Simbol | Semnificație | Exemplu |
|--------|--------------|---------|
| `*` | Orice valoare | `* * * * *` (fiecare minut) |
| `,` | Lista de valori | `1,15,30` (min 1, 15, 30) |
| `-` | Range | `1-5` (luni-vineri) |
| `/` | Step/increment | `*/5` (la fiecare 5) |

### 2.3 String-uri Speciale

```bash
@reboot     # La pornirea sistemului
@yearly     # 0 0 1 1 * (1 ianuarie)
@annually   # Echivalent cu @yearly
@monthly    # 0 0 1 * * (prima zi din lună)
@weekly     # 0 0 * * 0 (duminică la miezul nopții)
@daily      # 0 0 * * * (la miezul nopții)
@midnight   # Echivalent cu @daily
@hourly     # 0 * * * * (la fiecare oră, minutul 0)
```

---

## 3. Exemple Practice Crontab

### 3.1 Exemple de Bază

```bash
# În fiecare minut
* * * * * /path/to/script.sh

# La fiecare 5 minute
*/5 * * * * /path/to/script.sh

# La fiecare oră (minutul 0)
0 * * * * /path/to/script.sh

# Zilnic la 3:00 AM
0 3 * * * /path/to/backup.sh

# Zilnic la 6:00 AM și 6:00 PM
0 6,18 * * * /path/to/report.sh

# Luni-Vineri la 9:00 AM
0 9 * * 1-5 /path/to/workday.sh

# Prima zi din fiecare lună
0 0 1 * * /path/to/monthly.sh

# În fiecare duminică la 2:30 AM
30 2 * * 0 /path/to/weekly.sh
```

### 3.2 Exemple Avansate

```bash
# La fiecare 15 minute în timpul programului de lucru
*/15 9-17 * * 1-5 /path/to/check.sh

# În zilele 1 și 15 ale lunii
0 0 1,15 * * /path/to/biweekly.sh

# La fiecare 2 ore
0 */2 * * * /path/to/every2hours.sh

# Prima duminică din lună (combinație)
0 0 1-7 * 0 /path/to/first_sunday.sh
```

---

## 4. Gestionarea Crontab

### 4.1 Comenzi crontab

```bash
# Editează crontab-ul utilizatorului curent
crontab -e

# Listează job-urile curente
crontab -l

# Șterge toate job-urile (atenție!)
crontab -r

# Editează crontab-ul altui utilizator (root)
sudo crontab -u username -e

# Listează pentru alt utilizator
sudo crontab -u username -l
```

### 4.2 Locații Crontab

```bash
# Crontab-uri utilizatori
/var/spool/cron/crontabs/username

# Crontab sistem (include câmpul user)
/etc/crontab

# Directoare pentru scripturi periodice
/etc/cron.d/           # Crontab-uri extra
/etc/cron.hourly/      # Scripturi orare
/etc/cron.daily/       # Scripturi zilnice
/etc/cron.weekly/      # Scripturi săptămânale
/etc/cron.monthly/     # Scripturi lunare
```

### 4.3 Formatul /etc/crontab

```bash
# /etc/crontab include câmpul USER
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=Issues: Open an issue in GitHub

# min hour day month dow user command
0 3 * * * root /usr/local/bin/backup.sh
*/5 * * * * www-data /var/www/cron.php
```

---

## 5. Best Practices

### 5.1 Configurarea Mediului

```bash
# În crontab, setează variabile de mediu
SHELL=/bin/bash
PATH=/usr/local/bin:/usr/bin:/bin
HOME=/home/user
MAILTO=user@example.com

# Job-uri cu mediu complet
* * * * * /bin/bash -l -c '/path/to/script.sh'
```

### 5.2 Logging și Debugging

```bash
# Redirecționare output
0 3 * * * /path/to/script.sh >> /var/log/myscript.log 2>&1

# Cu timestamp
0 3 * * * /path/to/script.sh 2>&1 | while read line; do echo "$(date): $line"; done >> /var/log/myscript.log

# Doar erori
0 3 * * * /path/to/script.sh >> /var/log/myscript.log 2>> /var/log/myscript.err

# Suprimă complet output
0 3 * * * /path/to/script.sh > /dev/null 2>&1
```

### 5.3 Locking (Prevenire Execuții Multiple)

```bash
#!/bin/bash
# Script cu lock file

LOCKFILE="/tmp/myscript.lock"

# Verifică și creează lock
if [ -f "$LOCKFILE" ]; then
    echo "Script deja în execuție"
    exit 1
fi

# Creează lock
echo $$ > "$LOCKFILE"

# Cleanup la ieșire
trap "rm -f $LOCKFILE" EXIT

# Logica principală
# ...
```

### 5.4 Căi Absolute

```bash
# GREȘIT - căi raportate la directorul curent (`cwd`)
0 3 * * * backup.sh

# CORECT - căi absolute
0 3 * * * /usr/local/bin/backup.sh

# Sau setează PATH în crontab
PATH=/usr/local/bin:/usr/bin:/bin
0 3 * * * backup.sh
```

---

## 6. Comanda at - Task-uri One-Time

### 6.1 Sintaxă at

```bash
# Execută comandă la o oră specificată
at 15:30
at> /path/to/script.sh
at> <Ctrl+D>

# Forme de timp
at now + 1 hour
at now + 30 minutes
at midnight
at noon
at teatime         # 4:00 PM
at tomorrow
at 10:00 AM Dec 25
at 2:30 PM next week
```

### 6.2 Gestionare at

```bash
# Listează job-uri programate
atq
at -l

# Vizualizează conținutul unui job
at -c job_number

# Șterge un job
atrm job_number
at -d job_number
```

### 6.3 batch - Execuție când sistemul e idle

```bash
# Execută când load average scade sub 1.5
batch
at> /path/to/heavy_script.sh
at> <Ctrl+D>
```

---

## 7. Exerciții Practice

### Exercițiul 1: Backup Zilnic
```bash
# Editează crontab
crontab -e

# Adaugă backup zilnic la 2:00 AM
0 2 * * * /home/user/scripts/backup.sh >> /var/log/backup.log 2>&1
```

### Exercițiul 2: Monitorizare
```bash
# Verifică disk space la fiecare oră
0 * * * * df -h | mail -s "Disk Report" Issues: Open an issue in GitHub
```

### Exercițiul 3: Cleanup Logs
```bash
# Șterge log-uri vechi săptămânal
0 0 * * 0 find /var/log -name "*.log" -mtime +30 -delete
```

### Exercițiul 4: at pentru task one-time
```bash
# Programează restart server mâine la 3 AM
echo "sudo systemctl restart nginx" | at 3:00 AM tomorrow
```

---

## 8. Întrebări de Verificare

1. **Ce înseamnă `*/15 * * * *`?**
   > La fiecare 15 minute (0, 15, 30, 45).

2. **Cum programezi un job pentru prima zi din lună la miezul nopții?**
   > `0 0 1 * *`

3. **De ce nu funcționează job-ul meu cron?**
   > Verifică: căi absolute, variabile de mediu, permisiuni, log-uri (/var/log/syslog).

4. **Diferența dintre crontab -e și /etc/crontab?**
   > crontab -e este per utilizator; /etc/crontab este sistem-wide și include câmpul user.

5. **Cum previi execuții simultane ale aceluiași job?**
   > Folosești un lock file sau flock.

---

## Cheat Sheet

```bash
# FORMAT CRONTAB
# min hour day month dow command
* * * * *           # fiecare minut
*/5 * * * *         # la 5 minute
0 * * * *           # fiecare oră
0 3 * * *           # zilnic 3 AM
0 3 * * 0           # duminică 3 AM
0 0 1 * *           # prima zi lună
0 9 * * 1-5         # L-V 9 AM

# COMENZI
crontab -e          # editează
crontab -l          # listează
crontab -r          # șterge tot

# STRINGS SPECIALE
@reboot             # la boot
@daily              # zilnic
@weekly             # săptămânal
@monthly            # lunar
@hourly             # orar

# AT
at 15:30            # la 15:30
at now + 1 hour     # peste o oră
atq                 # listează
atrm N              # șterge job N

# BEST PRACTICES
/path/to/script.sh >> /var/log/out.log 2>&1
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
