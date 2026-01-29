# Ghid Studiu — Securitate SO

## Triada CIA
- **Confidentiality**: Acces doar pentru autorizați
- **Integrity**: Date nealterate
- **Availability**: Sistem accesibil când e nevoie

## Permisiuni UNIX
```
Symbolic: rwxr-xr-x
Octal:    755

r=4, w=2, x=1
Owner: 7 = 4+2+1 = rwx
Group: 5 = 4+0+1 = r-x
Other: 5 = 4+0+1 = r-x
```

## Vulnerabilități & Protecții

| Vulnerabilitate | Protecție |
|-----------------|-----------|
| Buffer overflow | Stack canaries, ASLR |
| Code injection | DEP/NX (non-executable stack) |
| Privilege escalation | Least privilege, sandboxing |

## Comenzi Utile
```bash
chmod 755 file
chown user:group file
ls -la
stat file
getfacl file
```
