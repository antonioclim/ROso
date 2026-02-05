# 📁 Module de bibliotecă — Proiectul Monitor

> **Locație:** `SEM06/scripts/projects/monitor/lib/`  
> **Scop:** funcții modulare (bibliotecă) pentru proiectul Monitor

## Conținut

| Modul | Scop |
|--------|---------|
| `config.sh` | încărcare și validare configurație |
| `core.sh` | colectare metrici și logica principală |
| `utils.sh` | utilitare (parsare /proc, logging, validări) |

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
- încărcarea configurației (praguri, intervale);
- validarea valorilor (procente, căi);
- valori implicite.

### core.sh
- citire /proc pentru CPU, memorie, disc;
- generare de alerte;
- format de raportare.

### utils.sh
- parsare robustă pentru fișiere /proc;
- logging: `log_info`, `log_error`, `log_debug`;
- helper‑e pentru formatare.

---

*Vedeți și: [`../monitor.sh`](../monitor.sh) pentru scriptul principal*  
*Vedeți și: [`../tests/`](../tests/) pentru suita de teste*

*Ultima actualizare: ianuarie 2026*
