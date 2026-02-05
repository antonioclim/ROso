# 📁 Configurație CI — SEM05

> **Locație:** `ci/github_actions.yml`  
> **Scop:** pipeline GitHub Actions pentru verificări automate de calitate (lint, testare, validare)

---

## Ce face

Acest workflow rulează automat:

| Pas | Instrument | Verifică |
|-----|-----------|----------|
| Python | `python -m compileall` | sintaxă validă în fișierele `.py` |
| Bash | `bash -n` | sintaxă validă în scripturi `.sh` |
| ShellCheck | `shellcheck` | bune practici Bash, erori tipice |
| JSON | `python -m json.tool` | JSON valid |
| YAML | `python -c 'import yaml; ...'` | YAML valid |
| Markdown links | script utilitar | existența link-urilor relative |

---

## Cum se folosește

Nu trebuie să rulați nimic manual pentru CI; workflow-ul este executat automat la push / pull request.

Dacă doriți să simulați local o parte din verificări, puteți folosi:

```bash
make lint
make test
```

---

## Notă

Fișierul de workflow este un artefact tehnic; cheile YAML și pașii trebuie păstrați în formatul așteptat de GitHub Actions.
