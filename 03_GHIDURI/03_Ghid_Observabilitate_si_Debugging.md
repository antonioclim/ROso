# Ghid de observabilitate și debugging (Linux, nivel introductiv)

Un sistem de operare este, prin natura lui, „invizibil” până când îl instrumentezi. În laborator, obiectivul nu este doar „să meargă”, ci să poți explica de ce merge sau de ce nu merge.

## 1. Instrumente de bază (fără privilegii speciale)

### Procese și încărcare
- `ps`, `top` / `htop`
- `uptime`
- `time` (măsurare per comandă)

### Memorie
- `free -h`
- `vmstat 1`
- `/proc/meminfo`

### Disc și fișiere
- `df -h`, `du -sh`
- `ls -l`, `stat`
- `lsof` (ce fișiere sunt deschise și de cine)

### Rețea (când este relevant)
- `ss -tulpn` (socket-uri)
- `ip a`, `ip r`

## 2. `strace`: observarea apelurilor de sistem

`strace` este foarte util pentru:
- a vedea ce fișiere încearcă să deschidă un program;
- a înțelege de ce primești `Permission denied`, `No such file or directory`;
- a discuta diferența dintre *API* (funcții libc) și *system calls*.

Exemplu:
```bash
strace -f -o trace.txt ls -l /tmp
```

## 3. Log-uri: `journalctl` și `dmesg`

- `journalctl` (systemd journal) — evenimente pe servicii și sistem
- `dmesg` — mesaje de kernel (driver-e, erori de I/O, OOM killer etc.)

Exemple:
```bash
journalctl -b -p warning
dmesg --level=err,warn | tail -n 50
```

## 4. Debugging în Bash

- rulează cu `bash -x script.sh ...`
- verifică valori cu `printf '%q\n' "$var"` (util la whitespace)
- folosește `trap` pentru cleanup și pentru a afișa context la erori

## 5. Debugging în Python (în context OS)

- afișează informații minimale și reproducibile: PID, timpul, resursele;
- pentru excepții, păstrează traceback-ul (nu „înghiți” erorile).

Data ediției: **10 ianuarie 2026**
