# Rubrică de evaluare — teme S03

> **Sisteme de Operare** | ASE Bucharest - CSIE  
> Seminar 03: managementul fișierelor și automatizare

---

## Prezentarea temelor

| ID | Subiect | Durată | Dificultate |
|----|-------|----------|------------|
| S03b | Find și locate | 45 min | ⭐⭐ |
| S03c | Xargs avansat | 40 min | ⭐⭐⭐ |
| S03d | Parametrii unui script | 45 min | ⭐⭐ |
| S03e | CLI cu getopts | 50 min | ⭐⭐⭐ |
| S03f | Permisiuni Unix | 45 min | ⭐⭐ |
| S03g | Automatizare CRON | 40 min | ⭐⭐ |

---

## S03b - Find și locate (10 puncte)

| Criteriu | Puncte | Cerințe |
|-----------|--------|--------------|
| find de bază | 2.5 | -name, -type, -size |
| Predicate temporale | 2.0 | -mtime, -atime, -newer |
| Acțiuni | 2.0 | -exec, -delete, -print |
| Operatori logici | 2.0 | -o, -a, ! |
| Utilizare locate | 1.5 | locate, updatedb |

---

## S03c - Xargs avansat (10 puncte)

| Criteriu | Puncte | Cerințe |
|-----------|--------|--------------|
| xargs de bază | 2.5 | Pipe către xargs |
| Placeholder -I | 2.5 | Substituție personalizată |
| Paralelizare -P | 2.0 | Execuție multi‑proces |
| Delimitator NUL | 1.5 | -0 cu find -print0 |
| Tratarea erorilor | 1.5 | -r, coduri de ieșire |

---

## S03d - Parametrii unui script (10 puncte)

| Criteriu | Puncte | Cerințe |
|-----------|--------|--------------|
| Parametri poziționali | 2.5 | $1, $2, ... $9 |
| Parametri speciali | 2.5 | $#, $@, $*, $0 |
| Comanda shift | 2.0 | Deplasarea parametrilor |
| Valori implicite | 2.0 | ${1:-default} |
| Validare | 1.0 | Verificarea numărului de argumente |

---

## S03e - CLI cu getopts (10 puncte)

| Criteriu | Puncte | Cerințe |
|-----------|--------|--------------|
| getopts de bază | 3.0 | while getopts pattern |
| Argumente pentru opțiuni | 2.5 | Opțiuni cu : |
| Gestionare OPTIND | 2.0 | Shift după parsare |
| Tratarea erorilor | 1.5 | Opțiuni necunoscute |
| Mesaj de help | 1.0 | Implementare -h |

---

## S03f - Permisiuni Unix (10 puncte)

| Criteriu | Puncte | Cerințe |
|-----------|--------|--------------|
| chmod numeric | 2.5 | 755, 644, etc. |
| chmod simbolic | 2.5 | u+x, g-w, o=r |
| Ownership | 2.0 | chown, chgrp |
| Biți speciali | 2.0 | setuid, setgid, sticky |
| umask | 1.0 | Permisiuni implicite |

---

## S03g - Automatizare CRON (10 puncte)

| Criteriu | Puncte | Cerințe |
|-----------|--------|--------------|
| Sintaxă crontab | 3.0 | Câmpuri de timp corecte |
| Comenzi crontab | 2.0 | -l, -e, -r |
| Șiruri speciale | 2.0 | @daily, @hourly, etc. |
| Gestionare output | 2.0 | Redirecționare, mail |
| Job practic | 1.0 | Crearea unui job cron util |

---

*De Revolvix pentru disciplina OPERATING SYSTEMS | licență restricționată 2017-2030*
