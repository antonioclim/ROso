# 📁 Demo‑uri spectaculoase — SEM06

> **Locație:** `SEM06/scripts/demo/`  
> **Scop:** demo‑uri live pentru Monitor/Backup/Deployer

---

## Conținut

| Demo | Proiect | Scop |
|------|---------|---------|
| `S06_DEMO_01_monitor_demo.sh` | Monitor | simulează crash și alertă |
| `S06_DEMO_02_backup_demo.sh` | Backup | demonstrează backup + restore |
| `S06_DEMO_03_deployer_demo.sh` | Deployer | demonstrează deploy + rollback |
| `RUNhere.md` | — | instrucțiuni de utilizare |

> ⚠️ Aceste demo‑uri sunt concepute pentru instructor (sau practică atentă).  
> Nu rulați pe sisteme de producție.

---

## Cum se rulează demo‑urile

### 1) Demo Monitor (crash)

```bash
bash S06_DEMO_01_monitor_demo.sh
```

**Ce face:**
- pornește un proces artificial cu consum mare de CPU;
- monitorizează sistemul;
- declanșează o alertă când pragul este depășit;
- curăță procesul la final.

---

### 2) Demo Backup + Restore

```bash
bash S06_DEMO_02_backup_demo.sh
```

**Ce face:**
- creează un folder temporar cu fișiere;
- face backup incremental;
- șterge un fișier;
- restaurează fișierul;
- verifică integritatea.

---

### 3) Demo Deployer + Rollback

```bash
bash S06_DEMO_03_deployer_demo.sh
```

**Ce face:**
- simulează un deploy cu două versiuni;
- introduce un health check care eșuează;
- declanșează rollback automat;
- afișează rezultatul final.

---

## Recomandări pentru prezentare

- rulați demo‑urile pe o mașină curată (VM);
- pre‑instalați dependențele;
- verificați permisiunile;
- pregătiți un output „repetabil” (folder temporar, date controlate).

---

## Depanare

| Problemă | Soluție |
|---------|---------|
| `bash: ./S06_DEMO_*.sh: No such file or directory` | verificați că sunteți în `scripts/demo/` |
| demo se oprește brusc | rulați cu `bash -x` pentru trace |
| lipsesc comenzi (`tar`, `sha256sum`) | instalați `coreutils`/`tar` |

---

*Demo‑uri pentru SEM06 CAPSTONE — Sisteme de Operare*  
*ASE București - CSIE | 2024-2025*
