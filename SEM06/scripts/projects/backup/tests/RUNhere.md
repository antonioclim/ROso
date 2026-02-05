# 📁 Teste — Proiectul Backup

> **Locație:** `SEM06/scripts/projects/backup/tests/`  
> **Scop:** teste unitare și de integrare pentru proiectul Backup

## Conținut

| Fișier | Scop |
|------|---------|
| `test_backup.sh` | test runner pentru funcționalitățile de backup |
| `test_helpers.sh` | funcții comune pentru testare |

---

## Cum rulați testele

Din directorul proiectului:

```bash
cd SEM06/scripts/projects/backup
bash tests/test_backup.sh
```

Sau, dacă aveți `pytest` configurat pentru shell tests (opțional), rulați în cadrul pipeline‑ului.

---

## Ce se testează

- creare backup full și incremental;
- rotație și curățare;
- validare configurație;
- tratarea erorilor (cazuri-limită).

---

*Vedeți și: [`../backup.sh`](../backup.sh) pentru scriptul principal*  
*Vedeți și: [`../lib/`](../lib/) pentru codul bibliotecii*

*Ultima actualizare: ianuarie 2026*
