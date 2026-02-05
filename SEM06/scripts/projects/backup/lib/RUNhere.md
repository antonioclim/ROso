# 📁 Module de bibliotecă — Proiectul Backup

> **Locație:** `SEM06/scripts/projects/backup/lib/`  
> **Scop:** funcții modulare (bibliotecă) pentru proiectul Backup

## Conținut

| Modul | Scop |
|--------|---------|
| `config.sh` | încărcare și validare configurație |
| `core.sh` | funcționalitatea principală de backup |
| `utils.sh` | funcții utilitare (logging, validări) |

---

## Utilizare

Includeți (source) modulele în scriptul principal:
```bash
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/config.sh"
source "${SCRIPT_DIR}/lib/utils.sh"
source "${SCRIPT_DIR}/lib/core.sh"
```

---

## Detalii despre module

### config.sh
- încărcarea configurației din fișier;
- validarea căilor și a setărilor de retenție;
- valori implicite pentru opțiunile lipsă.

### core.sh
- logica de backup incremental;
- compresie (gzip, tar);
- rotație/curățare a backup‑urilor vechi.

### utils.sh
- logging: `log_info`, `log_error`, `log_debug`;
- validare și sanitizare căi;
- calcule de dimensiune și formatare.

---

*Vedeți și: [`../backup.sh`](../backup.sh) pentru scriptul principal*  
*Vedeți și: [`../tests/`](../tests/) pentru suita de teste*

*Ultima actualizare: ianuarie 2026*
