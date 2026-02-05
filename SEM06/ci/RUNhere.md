# 📁 Configurație CI — SEM06

> **Locație:** `SEM06/ci/`  
> **Scop:** flux GitHub Actions pentru verificări automate de calitate

## Conținut

| Fișier | Scop |
|------|---------|
| `github_actions.yml` | definirea pipeline‑ului CI pentru acest seminar |

## Ce face

Acest workflow rulează automat la fiecare push/PR și execută:

| Verificare | Instrument | Comportament la eșec |
|-------|------|-------------------|
| Lint pentru Bash | shellcheck | Blochează merge‑ul |
| Lint pentru Python | ruff | Blochează merge‑ul |
| Validare YAML | PyYAML | Blochează merge‑ul |
| Teste unitare | pytest | Blochează merge‑ul |
| Verificare acoperire | pytest-cov | Avertizează dacă < prag |
| Validare structură | Custom | Blochează merge‑ul |
| Verificare linkuri | lychee | Doar avertizează |
| Scanare pattern‑uri AI | Custom | Doar avertizează |

## Cum se utilizează

### Pentru configurarea depozitului

Copiați în locația GitHub Actions:
```bash
cp github_actions.yml ../../.github/workflows/sem06_ci.yml
```

### Pentru testare locală

Rulați verificările individual, local:
```bash
# Lint pentru scripturi Bash
shellcheck scripts/bash/*.sh scripts/demo/*.sh

# Lint pentru Python
pip install ruff && ruff check scripts/python/

# Validare YAML
python3 -c "import yaml; yaml.safe_load(open('formative/quiz.yaml'))"

# Rulare teste
pip install pytest pytest-cov && pytest tests/ -v
```

## Configurare

### Pragul de acoperire

Editați variabila de mediu `COVERAGE_THRESHOLD`:
```yaml
env:
  COVERAGE_THRESHOLD: 75  # procent minim de acoperire
```

### Excluderea fișierelor

Adăugați pattern‑uri de ignorare în linting:
```yaml
- name: Run shellcheck
  run: find scripts/ -name "*.sh" ! -name "excluded.sh" -exec shellcheck {} \;
```

## Job‑urile workflow‑ului

```
┌─────────────┐   ┌─────────────┐   ┌─────────────┐
│  lint-bash  │   │ lint-python │   │validate-yaml│
└──────┬──────┘   └──────┬──────┘   └──────┬──────┘
       │                 │                 │
       └────────────────┼─────────────────┘
                        ▼
                 ┌─────────────┐
                 │    test     │
                 └──────┬──────┘
                        │
       ┌────────────────┼────────────────┐
       ▼                ▼                ▼
┌─────────────┐  ┌─────────────┐  ┌─────────────┐
│ ai-check    │  │ link-check  │  │  structure  │
└─────────────┘  └─────────────┘  └─────────────┘
                        │
                        ▼
                 ┌─────────────┐
                 │   summary   │
                 └─────────────┘
```

## Depanare

| Problemă | Soluție |
|-------|----------|
| Workflow‑ul nu se declanșează | Verificați numele branch‑urilor în secțiunea `on:` |
| Erori shellcheck | Rulați local și corectați avertismentele |
| Acoperire prea mică | Adăugați mai multe teste sau reduceți pragul |
| Timeout la verificarea linkurilor | Linkurile externe pot fi lente; verificați manual |

---

*Oglindește țintele din `Makefile` (directorul părinte)*  
*Vedeți și: [`../Makefile`](../Makefile) pentru automatizare locală*

*Ultima actualizare: ianuarie 2026*
