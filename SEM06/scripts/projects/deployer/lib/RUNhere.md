# 📁 Module de bibliotecă — Proiectul Deployer

> **Locație:** `SEM06/scripts/projects/deployer/lib/`  
> **Scop:** funcții modulare (bibliotecă) pentru proiectul Deployer

## Conținut

| Modul | Scop |
|--------|---------|
| `config.sh` | încărcare și validare configurație |
| `core.sh` | logica principală de deployment |
| `utils.sh` | utilitare (logging, retry/backoff, validări) |

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
- încărcarea configurației de deploy;
- validarea căilor de release, symlink‑ului `current`, retenție;
- valori implicite.

### core.sh
- strategii (rolling, blue-green);
- health checks și rollback;
- gestionarea versiunilor și a release‑urilor.

### utils.sh
- logging: `log_info`, `log_error`, `log_debug`;
- helper‑e pentru retry și backoff;
- validare argumente și căi.

---

*Vedeți și: [`../deployer.sh`](../deployer.sh) pentru scriptul principal*  
*Vedeți și: [`../tests/`](../tests/) pentru suita de teste*

*Ultima actualizare: ianuarie 2026*
