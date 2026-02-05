# 01_INIT_SETUP — Instalarea mediului de lucru

> **Sisteme de Operare** | ASE București - CSIE | An universitar 2024-2025  
> **Versiune:** 2.1 | **Ultima actualizare:** Ianuarie 2025  
> **Autor:** ing. dr. Antonio Clim

---

## Scop

Această secțiune conține ghidurile de configurare inițială distribuite **înainte de SEM01**. Studenții trebuie să finalizeze **UN** traseu de instalare înainte de primul seminar — fără excepții.

În fiecare an, studenții care sar peste acest pas petrec primul seminar cu depanări în loc de învățare. Finalizați ghidul acasă, unde aveți timp și conexiune la internet.

---

## Conținut

| Fișier | Descriere | Recomandat pentru |
|--------|-----------|-------------------|
| `GHID_WSL2_Ubuntu2404_RO.md` | Ghid de instalare WSL2 | Utilizatori Windows 10/11 |
| `GHID_WSL2_Ubuntu2404_INTERACTIV.html` | Versiune HTML interactivă cu urmărirea progresului | Pentru învățare vizuală |
| `GHID_VirtualBox_Ubuntu2404_RO.md` | Ghid VirtualBox + Ubuntu Server | macOS, Linux, Windows mai vechi |
| `GHID_VirtualBox_Ubuntu2404_INTERACTIV.html` | Versiune HTML interactivă | Pentru învățare vizuală |
| `verify_installation.sh` | Script de verificare | Toată lumea (rulați după instalare) |
| `QUICK_START_RO.md` | Listă de verificare în 5 minute | Referință rapidă |

---

## Ce traseu aleg?

```
┌─────────────────────────────────────────────────────────────┐
│                     DIAGRAMĂ DE DECIZIE                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Ce sistem de operare folosiți?                             │
│                                                             │
│  ├── Windows 11 (orice versiune)                            │
│  │   └── RAM ≥ 8 GB?                                        │
│  │       ├── DA  → Folosiți ghidul WSL2 (recomandat)        │
│  │       └── NU  → Folosiți ghidul VirtualBox               │
│  │                                                          │
│  ├── Windows 10                                             │
│  │   └── Versiunea 2004+ (Build 19041+)?                    │
│  │       ├── DA  → Folosiți ghidul WSL2                     │
│  │       └── NU  → Folosiți ghidul VirtualBox               │
│  │                                                          │
│  ├── macOS (Intel sau Apple Silicon)                        │
│  │   └── Folosiți ghidul VirtualBox                         │
│  │                                                          │
│  └── Linux                                                  │
│      └── Folosiți ghidul VirtualBox                         │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Încă nu sunteți siguri?** WSL2 este mai simplu dacă sistemul îl suportă. VirtualBox funcționează aproape oriunde, dar cere mai mult spațiu pe disc.

---

## Estimări de timp

| Traseu | Timp total | Internet necesar |
|--------|------------|------------------|
| WSL2 | 45-70 minute | ~2.5 GB descărcare |
| VirtualBox | 60-90 minute | ~3.5 GB descărcare |

Conexiune lentă sau hardware mai vechi? Adăugați încă 30 de minute la aceste estimări.

---

## După finalizare

După ce treceți scriptul de verificare, sunteți pregătiți pentru SEM01.

**Pași următori:**
1. Descărcați uneltele pentru înregistrarea temelor → vedeți `02_INIT_HOMEWORKS/`
2. Parcurgeți referința Bash → vedeți `03_GUIDES/01_Bash_Scripting_Guide.md`
3. Veniți la SEM01 cu mediul pregătit

---

## Depanare

Fiecare ghid conține o secțiune „Probleme frecvente și soluții". Verificați mai întâi acolo.

Dacă ghidurile nu vă rezolvă problema:
1. Citiți ghidul de debugging → `03_GUIDES/03_Observability_and_Debugging_Guide.md`
2. Întrebați un asistent AI (Claude sau ChatGPT) — vedeți Secțiunea 19/20 din fiecare ghid
3. Postați în forumul cursului cu mesajul de eroare complet
4. Ca ultimă opțiune, contactați cadrul didactic

---

## Istoric versiuni

| Versiune | Dată | Modificări |
|----------|------|------------|
| 2.1 | Ianuarie 2025 | Adăugat scriptul de verificare, checkpoint-uri de timp, greșeli frecvente |
| 2.0 | Octombrie 2024 | Actualizat pentru Ubuntu 24.04 LTS |
| 1.0 | Septembrie 2023 | Lansare inițială |

---

*Pentru cursul Sisteme de Operare la ASE București - CSIE*
