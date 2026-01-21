# M01: Incremental Backup System

> **Nivel:** MEDIUM | **Timp estimat:** 25-35 ore | **Bonus K8s:** +10%

---

## Descriere

Sistem complet de backup incremental cu suport pentru compresie, criptare, rotație automată și restaurare selectivă. Include scheduling și notificări.

---

## Cerințe

### Obligatorii
1. **Backup incremental** - doar fișiere modificate (folosind timestamp sau rsync)
2. **Backup complet** - snapshot periodic configurabil
3. **Compresie** - gzip/bzip2/xz selectabil
4. **Rotație** - păstrare N backup-uri, ștergere automată vechi
5. **Restaurare** - completă sau selectivă (fișiere individuale)
6. **Scheduling** - integrare cron/systemd timer
7. **Logging** - jurnal detaliat operații
8. **Verificare integritate** - checksum fișiere

### Opționale
9. **Criptare** - GPG pentru backup-uri sensibile
10. **Remote backup** - SCP/SFTP destinație
11. **Notificări** - email/webhook la succes/eșec
12. **Deduplicare** - hard links pentru fișiere identice
13. **Excluderi** - pattern-uri de ignorat
14. **Bandwidth limiting** - pentru backup remote

---

## Interfață

```bash
./backup.sh <command> [opțiuni]

Comenzi:
  full                    Backup complet
  incremental            Backup incremental
  restore <backup_id>     Restaurare
  list                    Listare backup-uri
  verify <backup_id>      Verificare integritate
  prune                   Curățare backup-uri vechi
  schedule                Configurare cron job

Opțiuni:
  -s, --source DIR        Director sursă
  -d, --dest DIR          Director destinație
  -c, --compress ALG      Algoritm compresie (gzip|bzip2|xz)
  -e, --encrypt           Activează criptare GPG
  -r, --remote HOST       Destinație remotă (user@host:path)
  --retention N           Păstrează ultimele N backup-uri
  --exclude PATTERN       Exclude fișiere matching pattern
```

---

## Structura

```
M01_Incremental_Backup/
├── src/
│   ├── backup.sh
│   └── lib/
│       ├── full_backup.sh
│       ├── incremental.sh
│       ├── restore.sh
│       ├── compression.sh
│       ├── encryption.sh
│       ├── rotation.sh
│       └── notify.sh
├── etc/
│   ├── backup.conf
│   └── excludes.txt
└── tests/
```

---

## Criterii Specifice

| Criteriu | Pondere |
|----------|---------|
| Backup incremental corect | 20% |
| Backup full | 10% |
| Compresie | 10% |
| Rotație | 10% |
| Restaurare | 15% |
| Funcționalități extra | 10% |
| Calitate cod + teste | 20% |
| Documentație | 5% |

---

*Proiect MEDIUM | Sisteme de Operare | ASE-CSIE*
