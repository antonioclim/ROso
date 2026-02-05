# 📁 Configurație CI — SEM04

> **Locație:** `SEM04/ci/`  
> **Scop:** workflow GitHub Actions pentru verificări automate de calitate

## Conținut

| Fișier | Scop |
|------|---------|
| `github_actions.yml` | definiția pipeline‑ului CI pentru acest seminar |

## Ce face

Acest workflow rulează automat la fiecare push/PR și execută:

| Verificare | Instrument | Comportament la eșec |
|-------|------|-------------------|
| Bash lint | shellcheck | Blochează merge‑ul |
| Python lint | ruff | Blochează merge‑ul |
| Validare YAML | PyYAML | Blochează merge‑ul |
| Teste unitare | pytest | Blochează merge‑ul |
| Verificare acoperire | pytest-cov | Avertizează dacă < prag |
| Validare structură | Custom | Blochează merge‑ul |
| Verificare link‑uri | lychee | Doar avertizează |
| Scanare pattern‑uri AI | Custom | Doar avertizează |

## Cum se folosește

### Pentru setarea repository‑ului

Copiați în locația GitHub Actions:
```bash
cp github_actions.yml ../../.github/workflows/sem04_ci.yml
```

### Pentru testare locală

Rulați verificări individuale local:
```bash
# Lint pentru scripturi Bash
shellcheck scripts/bash/*.sh scripts/demo/*.sh

# Lint Python
pip install ruff && ruff check scripts/python/

# Validare YAML
python3 -c "import yaml; yaml.safe_load(open('formative/quiz.yaml'))"

# Rulează testele
pip install pytest pytest-cov && pytest tests/ -v
```

## Configurare

### Prag de acoperire (coverage)

Editați variabila de mediu `COVERAGE_THRESHOLD`:
```yaml
env:
  COVERAGE_THRESHOLD: 75  # Minimum coverage percentage
```

### Excluderea fișierelor

Adăugați pattern‑uri de ignorat în linting:
```yaml
- name: Run shellcheck
  run: find scripts/ -name "*.sh" ! -name "excluded.sh" -exec shellcheck {} \;
```

## Job‑uri în workflow

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
| Erori shellcheck | Rulați local mai întâi și corectați avertismentele |
| Coverage prea mic | Adăugați teste sau reduceți pragul |
| Time‑out la verificarea link‑urilor | Link‑urile externe pot fi lente; verificați manual |

---

*Reflectă: țintele din `Makefile`‑ul părinte*  
*Vezi și: [`../Makefile`](../Makefile) pentru automatizare locală*

*Ultima actualizare: ianuarie 2026*
