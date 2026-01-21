# Idei de proiecte (ancorate în disciplina Sisteme de Operare)

Scopul proiectelor este să consolideze competențe practice: **automatisme în CLI**, **modelarea resurselor**, **solidețea scripturilor**, **observabilitatea** și **securitatea de bază**.

> Recomandare: proiecte în echipă (2–3 persoane), repository Git, documentație minimă (README + exemple de rulare + output demonstrativ).

## 1. Audit de permisiuni și riscuri în home-directory

**Ce face:** scanează un arbore de directoare și raportează:
- fișiere world-writable;
- directoare cu permisiuni riscante;
- fișiere executabile fără proprietar/permisiuni coerente (unde este cazul).

**Legături cu OS:** permisiuni Unix, ownership, securitate, `umask`, `chmod/chown`, conceptul de „least privilege”.

**Implementare recomandată:** Bash pentru colectare rapidă (`find`, `stat`), Python pentru raport (CSV/JSON + top N).

## 2. Monitor de procese „lightweight” (CLI)

**Ce face:** afișează periodic procesele consumatoare de CPU/memorie, cu:
- PID, PPID, comandă;
- evoluția RSS;
- opțional: un „snapshot” în fișier.

**Legături cu OS:** procese, planificare, memorie, `/proc`, semnale (`SIGTERM`, `SIGKILL`).

## 3. Backup incremental cu blocare (lock) și verificare

**Ce face:** arhivează periodic un director, evitând rularea simultană:

- Folosește `flock`/lockfile
- Loghează fiecare execuție
- Verifică integritatea (hash, `tar -t`)


**Legături cu OS:** concurență (race conditions), fișiere, cron/systemd timers, integritate.

## 4. Analizor de log-uri (securitate/operare)

**Ce face:** extrage evenimente (login-uri, eșecuri, restart-uri) din `journalctl` sau fișiere log și produce:

Pe scurt: top IP-uri / utilizatori;; intervale orare cu vârf;; export CSV..


**Legături cu OS:** securitate, audit, text processing (grep/sed/awk), pipeline-uri.

## 5. „Mini shell” educațional (opțional, nivel avansat)

**Ce face:** un shell minimal care suportă:

Concret: executarea comenzilor simple;. redirecționări;. Și pipeline (`|`) pentru 2–3 comenzi..


**Legături cu OS:** `fork/exec`, pipe-uri, file descriptors, semnale, job control (parțial).

Data ediției: **10 ianuarie 2026**
