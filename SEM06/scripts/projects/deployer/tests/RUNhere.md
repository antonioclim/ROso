# 📁 Teste — Proiectul Deployer

> **Locație:** `SEM06/scripts/projects/deployer/tests/`  
> **Scop:** teste unitare și de integrare pentru proiectul Deployer

## Conținut

| Fișier | Scop |
|------|---------|
| `test_deployer.sh` | test runner pentru funcționalitățile de deployment |
| `test_helpers.sh` | funcții comune pentru testare |

---

## Cum rulați testele

Din directorul proiectului:

```bash
cd SEM06/scripts/projects/deployer
bash tests/test_deployer.sh
```

---

## Ce se testează

- creare și comutare release‑uri;
- health checks (success/failure);
- rollback;
- tratarea erorilor și coduri de ieșire.

---

*Vedeți și: [`../deployer.sh`](../deployer.sh) pentru scriptul principal*  
*Vedeți și: [`../lib/`](../lib/) pentru codul bibliotecii*

*Ultima actualizare: ianuarie 2026*
