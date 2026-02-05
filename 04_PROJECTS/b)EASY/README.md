# Proiecte EASY (E01-E05)

> **Dificultate:** ⭐⭐ | **Timp:** 15-20 ore | **Componente:** Doar Bash

---

## Prezentare Generală

Proiectele Easy sunt proiectate pentru studenți cu cunoștințe Bash de bază. Se concentrează pe comenzi fundamentale și modele simple de scripting.

> 💡 **Nota instructorului:** Dacă acesta este primul tău proiect serios Bash, începe de aici. Acestea nu sunt "ușoare" în sensul de a fi triviale — sunt "ușoare" în sensul că conceptele sunt fundamentale. Stăpânește aceste modele și proiectele MEDIUM vor părea abordabile.

---

## Listă Proiecte

| ID | Nume | Comenzi Principale | Recomandat Pentru |
|----|------|---------------|-----------------|
| E01 | File System Auditor | `find`, `du`, `stat` | Începători |
| E02 | Log Analyzer | `grep`, `awk`, `sed` | Practică procesare text |
| E03 | Bulk File Organiser | `mv`, `mkdir`, `find` | Gestionare fișiere |
| E04 | System Health Reporter | `top`, `df`, `free` | Bazele monitorizării |
| E05 | Config File Manager | `cp`, `diff`, `sed` | Workflow-uri configurație |

---

## Ce Vei Învăța

Finalizarea oricărui proiect EASY te va învăța:

- Parsare argumente linie de comandă cu `getopts`
- Operații cu fișiere și directoare
- Pipeline-uri de bază pentru procesare text
- Coduri de ieșire și gestionare erori
- Scrierea de shell scripturi mentenabile

---

## Început

1. Citește specificația proiectului ales (E0X_*.md)
2. Folosește `../templates/project_structure.sh` pentru a crea structura proiectului
3. Urmează `../TECHNICAL_GUIDE.md` pentru best practices
4. Rulează `../helpers/project_validator.sh` înainte de predare

---

## Capcane Comune

Bazat pe predările din anii anteriori:

1. **Folosirea `ls` în scripturi** — Folosește `find` în schimb; gestionează spațiile corect
2. **Uitarea ghilimelelor** — Pune întotdeauna ghilimele la variabile: `"$var"` nu `$var`
3. **Path-uri hardcoded** — Folosește `$HOME` și path-uri relative
4. **Gestionare erori lipsă** — Adaugă `set -euo pipefail` la început

---

## Management Timp

| Săptămână | Milestone |
|------|-----------|
| 1 | Structură proiect creată, argumente CLI funcționează |
| 2 | Funcționalitate de bază implementată |
| 3 | Cazuri limită gestionate, teste scrise |
| 4 | Documentație completă, finisare finală |

---

*Proiecte EASY — OS Kit | Ianuarie 2025*
