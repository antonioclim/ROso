# 🧱 Template-uri — SEM05

> **Locație:** `scripts/templates/`  
> **Scop:** șabloane reutilizabile pentru scripturi Bash

---

## Conținut

| Fișier | Rol |
|-------|-----|
| `bash_pro_template.sh` | template complet (argumente, trap, logging, robustețe) |
| `bash_min_template.sh` | template minimal (structură recomandată) |

---

## Utilizare

Copiați template-ul și personalizați:

```bash
cp scripts/templates/bash_pro_template.sh my_script.sh
```

---

## Notă

Păstrați structura, în special:
- `set -euo pipefail`
- funcțiile `cleanup` și `trap`
- jurnalizarea consistentă
