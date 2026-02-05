# 📁 Configurare CI — SEM02

> **Locație:** `SEM02/ci/`  
> **Scop:** flux GitHub Actions pentru verificări automate de calitate

## Conținut

| Fișier | Scop |
|------|---------|
| `github_actions.yml` | definirea pipeline‑ului CI pentru acest seminar |

## Ce face

Acest workflow rulează automat la fiecare push/PR și execută:

| Verificare | Instrument | Comportament la eșec |
|-------|------|-------------------|
| Lint Bash | shellcheck | Blochează integrarea |
| Lint Python | ruff | Blochează integrarea |
| Validare YAML | PyYAML | Blochează integrarea |
| Teste unitare | pytest | Blochează integrarea |
| Acoperire | pytest-cov | Avertizează dacă < prag |
| Validare structură | Custom | Blochează integrarea |
| Verificare linkuri | lychee | Doar avertisment |
| Scanare pattern-uri AI | Custom | Doar avertisment |

## Cum se folosește

### Pentru configurarea repository‑ului

Copiază în locația GitHub Actions:
```bash
cp github_actions.yml ../../.github/workflows/sem02_ci.yml
```

### Pentru rulare locală

Rulează individual verificările local:
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

### Prag acoperire

Editează variabila de mediu `COVERAGE_THRESHOLD`:
```yaml
env:
  COVERAGE_THRESHOLD: 75  # procent minim pentru acoperire
```

### Excluderea unor fișiere

Adaugă pattern-uri de ignorat la linting:
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
| Workflow-ul nu pornește | Verifică numele de branch în secțiunea `on:` |
| erori shellcheck | Rulează local, corectează avertismentele |
| acoperire prea mică | Adaugă teste sau scade pragul |
| timeouts la link check | Linkurile externe pot fi lente; verifică manual |

---

*Oglindește target-urile din `Makefile` (directorul părinte)*  
*Vezi și: [`../Makefile`](../Makefile) pentru automatizare locală*

*Ultima actualizare: ianuarie 2026*
