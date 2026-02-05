# C03_04_GHID_STUDIU.md
# Ghid Studiu — Procese

## Concepte Cheie

### Proces vs Program
- **Program**: Fișier executabil pe disk (pasiv)
- **Proces**: Program în execuție + resurse (activ)

### PCB (Process Control Block)
- PID, PPID
- Stare (new, ready, running, waiting, terminated)
- Registre CPU salvate
- Informații scheduling
- Resurse alocate

### System Calls pentru Procese
| Call | Descriere | Return |
|------|-----------|--------|
| fork() | Creează copie proces | 0 în copil, PID în părinte |
| exec() | Înlocuiește imaginea | Nu returnează la succes |
| wait() | Așteaptă copil | PID copil terminat |
| exit() | Termină procesul | Nu returnează |

### Zombie și Orfan
- **Zombie**: Proces terminat, părinte nu a apelat wait()
- **Orfan**: Proces al cărui părinte a murit → adoptat de init

## Auto-Evaluare
1. Ce returnează fork() în părinte vs copil?
2. Ce este un proces zombie?
3. Câte procese creează `fork(); fork();`?