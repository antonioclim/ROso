# 📁 Șabloane — SEM06

> **Locație:** `SEM06/resources/templates/`  
> **Scop:** șabloane reutilizabile pentru scripturi Bash

## Conținut

| Fișier | Scop |
|------|---------|
| `bash_script_template.sh` | șablon de script Bash (stil, setări de siguranță) |
| `RUNhere.md` | instrucțiuni pentru utilizarea șabloanelor |

## Cum folosiți șablonul

1. Copiați șablonul într-un director de lucru:

```bash
cp resources/templates/bash_script_template.sh my_script.sh
```

2. Faceți fișierul executabil:

```bash
chmod +x my_script.sh
```

3. Editați și completați secțiunile TODO.

## Ce include șablonul

Șablonul include deja:
- shebang corect (`#!/bin/bash`);
- „sfânta treime” pentru scripturi robuste: `set -euo pipefail`;
- funcție de logging cu timestamp;
- tratare de erori și mesaje prietenoase;
- validare de argumente;
- structură recomandată pentru funcții.

## Recomandări

- Păstrați `set -euo pipefail` în scripturi de proiect; scoateți doar dacă înțelegeți consecințele.
- Folosiți `shellcheck` înainte de predare:
  ```bash
  shellcheck my_script.sh
  ```
- Folosiți ghilimele pentru variabile: `"$VAR"` (aproape întotdeauna).
- Evitați căi hardcodate; folosiți argumente sau fișiere de configurare.

---

*Șabloane pentru SEM06 CAPSTONE — Sisteme de Operare*  
*ASE București - CSIE | 2024-2025*
