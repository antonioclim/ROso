# Ghid de utilizare al kitului (ediție didactică)

Acest pachet este conceput ca suport didactic pentru disciplina **Sisteme de Operare** (nivel introductiv), în special pentru activități de curs/seminar/laborator. Conținutul îmbină:
- explicații conceptuale (definiții, modele, proprietăți);
- exemple reproductibile în Linux (Bash + Python), cu accent pe **observabilitate** (ce se întâmplă „înăuntru”) și **siguranță** (comenzi care nu strică sistemul);
- diagrame (PlantUML + ASCII) pentru a fixa structuri și fluxuri de execuție;
- exerciții de tip „exam-style” pentru recapitulare.

## 1. Cum este organizat kitul

- `SO_Saptamana_01` … `SO_Saptamana_14`  
  Fiecare săptămână are un `README.md` cu teoria esențială, exemple, întrebări tip grilă/explicative și o secțiune **Scripting în context (Bash + Python)**.
- `SO_Saptamana_XX/diagrame/` (unde există)  
  Fișiere `.puml` (PlantUML) și resurse comune în `diagrame_common/`.
- `SO_Saptamana_XX/TC_Materials/` (unde există)  
  Materiale de laborator (fișe) în **versiune RO**. Versiunile originale (English) sunt păstrate în `TC_Materials/_EN_Original/`.
- `SO_Saptamana_XX/scripts/`  
  Scripturi scurte (Bash/Python) care ilustrează punctual concepte OS; fiecare director conține și un `README.md` pentru rulare și interpretare.
- `Exercitii_Examene_Partea1.md` … `Exercitii_Examene_Partea3.md`  
  Seturi ample de recapitulare (diagrame ASCII + întrebări).

## 2. Mediu recomandat pentru laborator

Recomandat (pentru consistență între studenți):
- **Ubuntu 24.04 LTS** (nativ / WSL2 / VirtualBox)
- **Bash 5.2+**, **Python 3.12+**
- `git`, `shellcheck` (pentru calitate în scripturi)
- opțional: Java + PlantUML (pentru generarea diagramelor PNG)

> Sugestie didactică: în laborator, folosește un cont de utilizator normal (fără privilegii de root) și un director de lucru dedicat, ex. `~/so-lab/`.

## 3. Flux didactic (recomandare practică)

1. **Înainte de curs**: studenții parcurg „Obiective” + „Conținut curs” (10–15 minute).
2. **În curs**: demonstrații scurte în terminal, cu accent pe legătura dintre concept și observabilitate (`ps`, `/proc`, `strace`, `time`, `vmstat`, `iostat` etc.).
3. **În laborator**:
   - se lucrează pe `TC_Materials` (fișa săptămânii);
   - se rulează demo-urile din `scripts/` (cu discuție despre rezultate);
   - se rezolvă 2–3 exerciții scurte + 1 exercițiu integrator.
4. **După laborator**: recapitulare din fișierele `Exercitii_Examene_...`.

## 4. Reguli de reproducibilitate și siguranță

- Nu rula comenzi distructive fără să înțelegi efectul:
  - evită `rm -rf /`, `dd if=... of=/dev/...`, modificări în `/etc` pe sistemul personal;
  - preferă lucrul într-o mașină virtuală (snapshot înainte de laborator).
- Pentru scripturi:
  - folosește `set -euo pipefail` (unde este adecvat);
  - citează explicit fișierele/ directoarele pe care le modifici;
  - scrie întotdeauna `--help` / `usage()` pentru proiecte.
- Pentru rezultate:
  - salvează output-ul într-un fișier (ex. `tee`, `script`, redirecționări);
  - notează versiunea de kernel (`uname -a`) și distribuția (`lsb_release -a`).

## 5. Cum generezi diagramele PlantUML

În rădăcina kitului există `generate_diagrams.py`, care poate converti fișiere `.puml` în imagini (PNG).
- util pentru fișe/slide-uri;
- opțional pentru studenți, dar foarte util pentru cadru didactic.

## 6. Integritate academică

Exercițiile sunt destinate învățării. În proiecte/teme:
- se acceptă colaborarea la nivel de idei, dar **codul livrat** trebuie să fie înțeles și asumat de echipă;
- este recomandat un workflow Git (commit-uri scurte, mesaje clare, code review).

Data ediției: **10 ianuarie 2026**
