# 📁 Configurare CI — SEM01

> **Locație:** `SEM01/ci/`  
> **Scop:** Workflow GitHub Actions pentru verificări automate de calitate

## Conținut

| Fișier | Scop |
|--------|------|
| `github_actions.yml` | Definiție pipeline CI pentru acest seminar |

## Ce face

Acest workflow rulează automat la fiecare push/PR și efectuează:

| Verificare | Instrument | Comportament la eșec |
|------------|------------|----------------------|
| Lint Bash | shellcheck | Blochează merge |
| Lint Python | ruff | Blochează merge |
| Validare YAML | PyYAML | Blochează merge |
| Teste unitare | pytest | Blochează merge |
| Verificare acoperire | pytest-cov | Avertizare dacă < prag |
| Validare structură | Custom | Blochează merge |
| Verificare linkuri | lychee | Doar avertizare |
| Scanare pattern-uri AI | Custom | Doar avertizare |

## Cum se folosește

### Pentru configurare repository

Copiați în locația GitHub Actions:
```bash
cp github_actions.yml ../../.github/workflows/sem01_ci.yml
```

### Pentru testare locală

Rulați verificări individuale local:
```bash
# Lint scripturi Bash
shellcheck scripts/bash/*.sh scripts/demo/*.sh

# Lint Python
pip install ruff && ruff check scripts/python/

# Validare YAML
python3 -c "import yaml; yaml.safe_load(open('formative/quiz.yaml'))"

# Rulare teste
pip install pytest pytest-cov && pytest tests/ -v
```

## Configurare

### Prag acoperire

Editați variabila de mediu `COVERAGE_THRESHOLD`:
```yaml
env:
  COVERAGE_THRESHOLD: 75  # Procentaj minim acoperire
```

### Excludere fișiere

Adăugați pattern-uri de ignorat în linting:
```yaml
- name: Run shellcheck
  run: find scripts/ -name "*.sh" ! -name "excluded.sh" -exec shellcheck {} \;
```

## Joburi workflow

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
|----------|---------|
| Workflow nu se declanșează | Verificați numele ramurilor în secțiunea `on:` |
| Erori shellcheck | Rulați local mai întâi, corectați avertismentele |
| Acoperire prea mică | Adăugați mai multe teste sau reduceți pragul |
| Timeout verificare linkuri | Linkurile externe pot fi lente, verificați manual |

---

*Oglindește: țintele `Makefile` din părinte*  
*Vezi și: [`../Makefile`](../Makefile) pentru automatizare locală*

*Ultima actualizare: Ianuarie 2026*
