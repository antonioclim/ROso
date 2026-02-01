# Rubrică de evaluare — teme S06

> **Sisteme de Operare** | ASE Bucharest - CSIE  
> Seminar 06: integrare de tip capstone și automatizare

---

## Prezentarea temelor

| ID | Subiect | Durată | Dificultate |
|----|-------|----------|------------|
| S06_HW01 | Șablon monitor | 90 min | ⭐⭐⭐⭐ |
| S06_HW02 | Șablon backup | 90 min | ⭐⭐⭐⭐ |
| S06_HW03 | Șablon deployer | 90 min | ⭐⭐⭐⭐ |

**Notă:** Acestea sunt predări capstone care integrează concepte din toate seminarele anterioare.

---

## S06_HW01 - Monitor (10 puncte)

### Cerințe

Studentul trebuie să creeze un script de monitorizare a sistemului care:

1. Colectează metrici de sistem (CPU, memorie, disc)
2. Monitorizează procese
3. Generează alerte pe praguri
4. Loghează periodic
5. Oferă un sumar

### Criterii de notare

| Criteriu | Puncte | Descriere |
|-----------|--------|-------------|
| Colectare metrici | 2.5 | Utilizare corectă a instrumentelor (ps, top, df, free) |
| Monitorizare procese | 2.0 | Identificare procese, sortare după resurse |
| Sistem de alerte | 2.0 | Praguri configurabile, notificări |
| Logging | 2.0 | Log‑uri cu timestamp, rotire opțional |
| UX și structură | 1.5 | Output clar, funcții, argumente |

### Script așteptat
```bash
./monitor.sh --interval 5 --threshold-cpu 80 --log monitor.log
```

---

## S06_HW02 - Backup (10 puncte)

### Cerințe

Studentul trebuie să creeze un script de backup care:

1. Face backup incremental
2. Comprimă arhivele
3. Verifică integritatea (checksums)
4. Menține o politică de retenție
5. Permite restaurarea

### Criterii de notare

| Criteriu | Puncte | Descriere |
|-----------|--------|-------------|
| Backup logic | 3.0 | Incremental/diferențial corect |
| Compresie | 1.5 | tar/gzip, denumire adecvată |
| Integritate | 2.0 | SHA‑256/MD5, verificare |
| Retenție | 2.0 | Ștergere automată a backup‑urilor vechi |
| Restaurare | 1.5 | Script sau comenzi clare |

### Script așteptat
```bash
./backup.sh --source /home/user/data --dest /backup --keep 7
./backup.sh --restore backup_2025-01-30.tar.gz --to /restore
```

---

## S06_HW03 - Deployer (10 puncte)

### Cerințe

Studentul trebuie să creeze un script de deployment care:

1. Verifică precondiții (dependențe, permisiuni)
2. Instalează aplicația
3. Configurează servicii
4. Gestionează start/stop/restart
5. Verifică starea

### Criterii de notare

| Criteriu | Puncte | Descriere |
|-----------|--------|-------------|
| Verificări precondiții | 2.0 | Validare înainte de instalare |
| Instalare | 2.5 | Copiere fișiere, permisiuni, structură |
| Configurare | 2.0 | Configuri, environment, servicii |
| Control servicii | 2.0 | start/stop/restart/status |
| Robusteză | 1.5 | Tratarea erorilor, rollback opțional |

### Script așteptat
```bash
./deploy.sh --install
./deploy.sh --start
./deploy.sh --status
./deploy.sh --stop
./deploy.sh --undeploy    # Simulate deployment
```

---

## Note generale de notare

### Calitatea codului (se aplică tuturor temelor S06)

| Aspect | Așteptare |
|--------|-------------|
| Shebang | `#!/bin/bash` prezent |
| Strict mode | `set -euo pipefail` |
| Comentarii | Header și documentație inline |
| Funcții | Cod modular, reutilizabil |
| Variabile | Încadrate în ghilimele, nume relevante |
| Tratarea erorilor | Verificarea codurilor de ieșire, validarea input‑ului |

### Depunctări pentru practici slabe

| Problemă | Penalizare |
|-------|---------|
| Fără strict mode | -0.5 |
| Variabile ne‑quoted | -0.5 |
| Fără validare input | -0.5 |
| Fără tratarea erorilor | -1.0 |
| Căi hard‑codate | -0.5 |
| Fără comentarii | -0.5 |

### Oportunități de bonus

| Bonus | Puncte | Descriere |
|-------|--------|-------------|
| ShellCheck curat | +0.5 | Fără avertismente |
| Mesaj de help | +0.5 | -h/--help implementat |
| Output color | +0.25 | Culori ANSI pentru status |
| Validare config | +0.25 | Verificarea sintaxei fișierelor de config |

---

## Integrare cu proiectul de semestru

Aceste teme pregătesc direct studenții pentru proiectul de semestru:

| Temă | Relevanță pentru proiect |
|----------|-------------------|
| S06_HW01 Monitor | Funcții de monitorizare sistem |
| S06_HW02 Backup | Persistență și recuperare date |
| S06_HW03 Deployer | Automatizare și deployment |

Studenții care finalizează aceste teme în mod riguros vor avea o bază solidă pentru implementarea proiectului.

---

*De Revolvix pentru disciplina OPERATING SYSTEMS | licență restricționată 2017-2030*
