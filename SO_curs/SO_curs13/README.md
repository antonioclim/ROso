# Sisteme de Operare - Săptămâna 13: Securitate SO

> **by Revolvix** | ASE București - CSIE | Anul I, Semestrul 2 | 2025-2026

---

## Obiectivele Săptămânii

1. **Diferențiezi** între autentificare, autorizare și audit (AAA)
2. **Configurezi** permisiuni Unix și Access Control Lists (ACL)
3. Explici modelele de control acces: DAC, MAC, RBAC
4. Aplici principiile de securitate în administrarea sistemului

---

## Context aplicativ (scenariu didactic): Cum a fost posibil atacul SolarWinds?

În 2020, hackeri au compromis procesul de build al SolarWinds Orion. Update-ul "legitim" a instalat backdoor-uri pe mii de sisteme. Lecția: securitatea nu e doar despre permisiuni locale - e despre întregul lanț de încredere.

---

## Conținut Curs (13/14)

### 1. Triada AAA

| Concept | Întrebare | Exemplu |
|---------|-----------|---------|
| **Authentication** | Cine ești? | Parolă, SSH key, biometric |
| **Authorization** | Ce poți face? | Permisiuni, ACL, RBAC |
| Audit | Ce ai făcut? | /var/log/auth.log |

---

### 2. Permisiuni Unix

```
-rwxr-xr-x  1  user  group  1024  Jan 10  file.txt
│└┬┘└┬┘└┬┘
│ │  │  └── Others: r-x (read, execute)
│ │  └───── Group:  r-x
│ └──────── Owner:  rwx (read, write, execute)
└────────── Type:   - (regular file)

Permisiuni speciale:
  setuid (s): Rulează cu permisiunile owner-ului
  setgid (s): Rulează cu permisiunile grupului
  sticky (t): Doar owner-ul poate șterge în /tmp
```

```bash
# Modificare permisiuni
chmod 755 script.sh         # rwxr-xr-x
chmod u+s /path/to/binary   # setuid
chmod +t /shared/dir        # sticky bit

# Căutare fișiere setuid
find / -perm -4000 -type f 2>/dev/null
```

---

### 3. Access Control Lists (ACL)

```bash
# Vizualizare ACL
getfacl file.txt

# Setare ACL - Bob primește read+write
setfacl -m u:bob:rw file.txt

# ACL default pentru directoare noi
setfacl -d -m g:team:rwx /shared/project

# Ștergere ACL
setfacl -b file.txt
```

---

### 4. Modele de Control Acces

| Model | Cine decide | Exemple |
|-------|-------------|---------|
| DAC (Discretionary) | Owner-ul | Unix permissions |
| MAC (Mandatory) | Politica sistem | SELinux, AppArmor |
| RBAC (Role-Based) | Rolurile utilizatorului | Kubernetes, AWS IAM |

---

### 5. Principii de Securitate

| Principiu | Descriere | Exemplu |
|-----------|-----------|---------|
| **Least Privilege** | Minime permisiuni necesare | Web server: nu root! |
| **Defense in Depth** | Straturi multiple | Firewall + permisiuni |
| **Fail Secure** | La eroare, blochează | Auth fail → deny |
| **Separation of Duties** | Nicio persoană totul | Deploy ≠ Approve |

---

## Lectură Recomandată

### OSTEP
- [Cap 53 - Security](https://pages.cs.wisc.edu/~remzi/OSTEP/security-intro.pdf)

### Tanenbaum
- Capitolul 9: Security (pag. 593+)

---

*Materiale by Revolvix pentru ASE București - CSIE*

## Scripting în context (Bash + Python): Audit de permisiuni

### Fișiere incluse

- Bash: `scripts/perm_audit.sh` — Găsește world-writable, SUID/SGID, directoare fără sticky bit.
- Python: `scripts/perm_audit.py` — Interpretare permisiuni prin `stat` și raportare controlată.

### Rulare rapidă

```bash
./scripts/perm_audit.sh .
./scripts/perm_audit.py --root .
```

### Legătura cu conceptele din această săptămână

- Permisiunile, SUID/SGID și sticky bit sunt mecanisme simple, dar cu impact mare.
- Auditarea este o practică standard: întâi raportezi, apoi remediezi controlat.

### Practică recomandată

- rulează întâi scripturile pe un director de test (nu pe date critice);
- salvează output-ul într-un fișier și atașează-l la raport/temă, dacă este cerut;
- notează versiunea de kernel (`uname -r`) și versiunea Python (`python3 --version`) când compari rezultate.

*Materiale dezvoltate de Revolvix pentru ASE București - CSIE*
