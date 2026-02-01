# Docker — mediu de evaluare

> **Locație:** `SEM07/project_evaluation/Docker/`  
> **Scop:** Mediu izolat, reproductibil, pentru evaluarea proiectelor

## Conținut

| Fișier | Scop |
|------|---------|
| `Dockerfile` | Definiția imaginii containerului |

---

## Prezentare generală a Dockerfile‑ului

Mediul de evaluare include:

- **Bază:** Ubuntu 24.04 LTS
- **Shell:** Bash 5.x
- **Python:** 3.12+
- **Instrumente:** shellcheck, make, git, curl, jq
- **Securitate:** utilizator non‑root, fără acces la rețea

---

## Construirea imaginii

```bash
# Standard build
docker build -t enos-eval:latest .

# With build arguments
docker build -t enos-eval:latest     --build-arg PYTHON_VERSION=3.12     --build-arg EXTRA_PACKAGES="htop strace"     .

# Verify image
docker images enos-eval
```

---

## Conținutul imaginii

### Pachete instalate

| Categorie | Pachete |
|----------|----------|
| Core | bash, coreutils, findutils, grep, sed, awk |
| Development | make, gcc, python3, pip |
| Analysis | shellcheck, pycodestyle, pylint |
| Utilities | curl, wget, jq, tree |
| Testing | pytest, bats |

### Variabile de mediu

```dockerfile
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV PATH="/home/evaluator/.local/bin:$PATH"
```

### Configurarea utilizatorului

```dockerfile
# Non-root user for security
RUN useradd -m -s /bin/bash -u 1000 evaluator
USER evaluator
WORKDIR /home/evaluator
```

---

## Utilizare

### Testare manuală

```bash
# Interactive shell
docker run -it --rm enos-eval:latest /bin/bash

# Mount project for testing
docker run -it --rm     -v /path/to/project:/project:ro     enos-eval:latest     /bin/bash

# Run tests
docker run --rm     -v /path/to/project:/project:ro     enos-eval:latest     make -C /project test
```

### Limite de resurse

```bash
# Limit memory and CPU
docker run --rm     --memory=512m     --cpus=1     -v /path/to/project:/project:ro     enos-eval:latest     ./run_tests.sh
```

### Izolare de rețea

```bash
# No network access (evaluation mode)
docker run --rm     --network none     -v /path/to/project:/project:ro     enos-eval:latest     ./run_tests.sh
```

---

## Personalizare

### Adăugarea de pachete

Editați Dockerfile:
```dockerfile
RUN apt-get update && apt-get install -y     your-new-package     && rm -rf /var/lib/apt/lists/*
```

Reconstruiți: `docker build -t enos-eval:latest .`

### Pachete Python

```dockerfile
RUN pip install --user     pyyaml     pytest     your-package
```

---

## Depanare

| Problemă | Soluție |
|-------|----------|
| Build eșuează | Verificați rețeaua, actualizați imaginea de bază |
| Permission denied | Asigurați-vă că fișierele sunt lizibile pentru uid 1000 |
| Package not found | Adăugați în Dockerfile, reconstruiți |
| Probleme de memorie | Creșteți limita `--memory` |

---

*Vedeți și: [`../run_auto_eval_EN.sh`](../run_auto_eval_EN.sh) pentru scriptul de evaluare*

*Ultima actualizare: ianuarie 2026*
