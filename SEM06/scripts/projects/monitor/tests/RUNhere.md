# 📁 Teste — Proiectul Monitor

> **Locație:** `SEM06/scripts/projects/monitor/tests/`  
> **Scop:** teste unitare și de integrare pentru proiectul Monitor

## Conținut

| Fișier | Scop |
|------|---------|
| `test_monitor.sh` | test runner pentru funcționalitățile de monitorizare |
| `test_helpers.sh` | funcții comune pentru testare |

---

## Cum rulați testele

Din directorul proiectului:

```bash
cd SEM06/scripts/projects/monitor
bash tests/test_monitor.sh
```

---

## Ce se testează

- parsarea /proc (CPU, memorie);
- calculul procentelor;
- praguri și alerte;
- tratarea erorilor.

---

*Vedeți și: [`../monitor.sh`](../monitor.sh) pentru scriptul principal*  
*Vedeți și: [`../lib/`](../lib/) pentru codul bibliotecii*

*Ultima actualizare: ianuarie 2026*
