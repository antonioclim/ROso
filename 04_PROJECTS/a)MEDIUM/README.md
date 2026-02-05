# Proiecte MEDIUM (M01-M15)

> **Dificultate:** ⭐⭐⭐ | **Timp:** 25-35 ore | **Bonus:** Kubernetes +10%

---

## Prezentare Generală

Proiectele Medium sunt recomandate pentru studenți cu experiență moderată în Bash. Necesită componente multiple, gestionare cuprinzătoare a erorilor și adesea implică interacțiuni la nivel de sistem.

> 💡 **Nota instructorului:** Aici ar trebui să țintească majoritatea studenților. Proiectele MEDIUM te învață modele pe care le vei folosi pe parcursul întregii cariere: monitorizare, backup, deployment, scanare securitate. Alege unul care rezolvă o problemă pe care o ai efectiv — motivația te va purta prin sesiunile de debugging.

---

## Listă Proiecte

| ID | Nume | Competență Centrală | Linii Est. |
|----|------|------------|------------|
| M01 | Sistem Backup Incremental | `tar`, compresie, programare | 400-600 |
| M02 | Monitor Ciclu Viață Procese | `/proc`, semnale, monitorizare | 500-700 |
| M03 | Watchdog Sănătate Servicii | `systemd`, verificări sănătate | 350-500 |
| M04 | Scanner Securitate Rețea | `netcat`, bazele rețelei | 400-550 |
| M05 | Pipeline Deployment | hook-uri `git`, automatizare | 450-600 |
| M06 | Istoric Utilizare Resurse | `sar`, date time-series | 400-500 |
| M07 | Framework Audit Securitate | permisiuni, bazele CVE | 500-650 |
| M08 | Manager Stocare Disc | concepte LVM, cote | 450-600 |
| M09 | Manager Task-uri Programate | `cron`, `at`, systemd timers | 400-550 |
| M10 | Analizator Arbore Procese | `ps`, `pstree`, `/proc` | 400-500 |
| M11 | Instrument Forensics Memorie | `/proc/meminfo`, smaps | 450-550 |
| M12 | Monitor Integritate Fișiere | checksum-uri, `inotify` | 450-600 |
| M13 | Agregator Log-uri | `journalctl`, parsare | 400-550 |
| M14 | Manager Config Environment | dotfiles, templating | 500-650 |
| M15 | Motor Execuție Paralelă | `xargs`, GNU parallel | 450-600 |

---

## Bonus Kubernetes (+10%)

Toate proiectele MEDIUM pot câștiga 10% suplimentar prin adăugarea deployment-ului Kubernetes.

**Cerințe:**
- Deployment funcțional în minikube sau similar
- Fișiere YAML: Deployment, Service, ConfigMap
- Documentație setup K8s

Vezi `../KUBERNETES_INTRO.md` pentru cerințe detaliate.

> ⚠️ **Avertisment corect:** Bonusul K8s necesită 10+ ore pentru învățare dacă nu ai folosit containere niciodată. Urmărește acest bonus doar dacă ai timp de rezervă.

---

## Ce Vei Învăța

Finalizarea unui proiect MEDIUM te va învăța:

- Parsare complexă argumente și configurare
- Gestionare procese și semnale
- Tehnici de monitorizare sistem de fișiere
- Bazele programării rețea
- Logging și debugging la scară

---

## Început

1. Citește specificația proiectului ales temeinic
2. Folosește `../templates/project_structure.sh` pentru structură
3. Planifică modulele înainte de a scrie cod
4. Scrie teste alături de implementare

---

## Capcane Comune

1. **Scope creep** — Implementează cerințele mai întâi, apoi adaugă funcționalități
2. **Ignorarea `/proc`** — Este prietenul tău pentru info procese/memorie
3. **Operații blocante** — Folosește timeout-uri și job-uri în fundal
4. **Fără logging** — Adaugă log-uri devreme; debugging-ul fără ele este dureros

---

*Proiecte MEDIUM — OS Kit | Ianuarie 2025*
