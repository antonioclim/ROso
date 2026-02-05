# 📁 Scripturi auxiliare – instrumente de validare pentru studenți

> **Locație:** `04_PROJECTS/helpers/`  
> **Scop:** scripturi pentru validare, testare și împachetare înainte de predare  
> **Public țintă:** studenți

## Conținut

| Script | Scop | Când se folosește |
|--------|------|-------------------|
| `project_validator.sh` | Validează structura proiectului și cerințele | Înainte de fiecare commit |
| `submission_packager.sh` | Creează o arhivă de predare conformă | În etapa de predare finală |
| `test_runner.sh` | Rulează testele proiectului local | Pe parcursul dezvoltării |

## Pornire rapidă

```bash
# Marchează toate scripturile ca executabile
chmod +x *.sh

# 1. Validează structura proiectului
./project_validator.sh ~/my_project/

# 2. Rulează testele local
./test_runner.sh ~/my_project/

# 3. Împachetează pentru predare
./submission_packager.sh ~/my_project/ --student-id ABC123
```

---

## project_validator.sh

**Scop:** verifică dacă proiectul respectă cerințele structurale înainte de predare.

### Utilizare

```bash
./project_validator.sh <director_proiect> [opțiuni]

Opțiuni:
  --strict        Eșuează și la avertismente (implicit: doar avertismente)
  --quiet         Suprimă output-ul detaliat
  --report FILE   Generează raport detaliat
```

### Ce verifică

| Verificare | Cerință | Severitate |
|-----------|---------|-----------|
| ✅ README.md | Trebuie să existe și să includă secțiunile cerute | EROARE |
| ✅ Makefile | Trebuie să aibă target-urile `all`, `test`, `clean` | EROARE |
| ✅ director `src/` | Trebuie să conțină scriptul principal | EROARE |
| ✅ director `tests/` | Cel puțin un test | AVERTISMENT |
| ❌ fișiere `.env` | Nu trebuie să existe | EROARE |
| ❌ credențiale | Fără parole/token-uri hardcodate | EROARE |
| ✅ line endings | LF (Unix), nu CRLF | AVERTISMENT |
| ✅ dimensiuni fișiere | Niciun fișier > 10MB | EROARE |
| ✅ shebang | Scripturile trebuie să aibă shebang corect | AVERTISMENT |

### Exemplu de output

```
═══════════════════════════════════════════════════════════════
 VALIDATOR PROIECT v2.1
═══════════════════════════════════════════════════════════════

Se verifică: /home/student/my_monitor_project/

[OK]   README.md există (2.4 KB)
[OK]   Makefile are target-urile obligatorii
[OK]   src/main.sh există și este executabil
[WARN] tests/ are doar 1 fișier de test (recomandat: 3+)
[OK]   Nu au fost găsite fișiere .env
[OK]   Nu au fost detectate credențiale
[OK]   Toate fișierele folosesc LF
[OK]   Nu există fișiere supradimensionate

═══════════════════════════════════════════════════════════════
 REZULTAT: PROMOVAT (1 avertisment)
═══════════════════════════════════════════════════════════════
```

---

## test_runner.sh

**Scop:** rulează suita de teste într-un mediu apropiat de cel de evaluare.

### Utilizare

```bash
./test_runner.sh <director_proiect> [opțiuni]

Opțiuni:
  --verbose       Afișează output detaliat al testelor
  --timeout SEC   Timeout pentru teste (implicit: 60)
  --coverage      Generează raport de acoperire (dacă este disponibil)
  --docker        Rulează testele în container Docker (oglindește evaluarea)
```

### Cum funcționează

1. Încarcă fișierele de test din `tests/`
2. Creează un mediu temporar de test
3. Rulează fiecare fișier `test_*.sh` sau `test_*.py`
4. Raportează rezultatele cu timpi

### Exemplu

```bash
# Rulare de bază
./test_runner.sh ~/my_project/

# Cu Docker (similar mediului de evaluare)
./test_runner.sh ~/my_project/ --docker

# Detaliat, cu timeout extins
./test_runner.sh ~/my_project/ --verbose --timeout 120
```

### Output

```
═══════════════════════════════════════════════════════════════
 RUNNER TESTE v2.0
═══════════════════════════════════════════════════════════════

Se rulează testele pentru: my_monitor_project

[1/4] test_basic_functionality.sh ··· PROMOVAT (0.8s)
[2/4] test_error_handling.sh ······· PROMOVAT (1.2s)
[3/4] test_edge_cases.sh ··········· PROMOVAT (0.5s)
[4/4] test_integration.sh ·········· PROMOVAT (2.1s)

═══════════════════════════════════════════════════════════════
 REZUMAT: 4/4 teste promovate (4.6s total)
═══════════════════════════════════════════════════════════════
```

---

## submission_packager.sh

**Scop:** creează o arhivă corect formatată, pregătită pentru predare.

### Utilizare

```bash
./submission_packager.sh <director_proiect> --student-id <ID> [opțiuni]

Opțiuni:
  --student-id ID   Obligatoriu: identificator student (de ex. ABC123)
  --output DIR      Director output (implicit: curent)
  --include-git     Include directorul .git (nerecomandat)
  --dry-run         Afișează ce s-ar împacheta, fără a crea arhiva
```

### Ce face

1. Rulează automat `project_validator.sh`
2. Curăță artefactele de build (`make clean`)
3. Elimină fișiere inutile (`.DS_Store`, `__pycache__`, și altele)
4. Creează arhiva cu timestamp: `{STUDENT_ID}_project_{TIMESTAMP}.tar.gz`
5. Verifică integritatea arhivei

### Exemplu

```bash
# Împachetare standard
./submission_packager.sh ~/my_project/ --student-id ABC123

# Previzualizare fără creare
./submission_packager.sh ~/my_project/ --student-id ABC123 --dry-run

# Output într-o locație specifică
./submission_packager.sh ~/my_project/ --student-id ABC123 --output ~/Desktop/
```

### Output

```
═══════════════════════════════════════════════════════════════
 ÎMPACHETARE PREDARE v2.0
═══════════════════════════════════════════════════════════════

ID student: ABC123
Proiect: my_monitor_project
Timestamp: 2026-01-30_14-32-15

[1/5] Rulare validator ·············· PROMOVAT
[2/5] Curățare artefacte build ······ Gata (12 fișiere eliminate)
[3/5] Eliminare fișiere temporare ··· Gata (3 fișiere eliminate)
[4/5] Creare arhivă ················· Gata
[5/5] Verificare integritate ········ PROMOVAT

═══════════════════════════════════════════════════════════════
 SUCCES: ABC123_project_2026-01-30_14-32-15.tar.gz (45.2 KB)
 Locație: /home/student/ABC123_project_2026-01-30_14-32-15.tar.gz
═══════════════════════════════════════════════════════════════

Încarcă acest fișier pe platforma de predare.
```

---

## Rezumat flux de lucru

```
┌─────────────────────────────────────────────────────────────┐
│                     FLUX RECOMANDAT                          │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│   1. Ciclu de dezvoltare:                                    │
│      ┌──────────┐    ┌───────────┐    ┌──────────┐          │
│      │  Cod     │ ─► │  Validare  │ ─► │   Test   │          │
│      └──────────┘    └───────────┘    └──────────┘          │
│           ▲                                │                 │
│           └────────────────────────────────┘                 │
│                                                              │
│   2. Înainte de predare:                                     │
│      ┌──────────┐    ┌───────────┐    ┌──────────┐          │
│      │ Validare  │ ─►│   Test    │ ─► │ Împachet. │          │
│      │ --strict  │   │  --docker │    │          │          │
│      └──────────┘    └───────────┘    └──────────┘          │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## Probleme frecvente

| Problemă | Soluție |
|---------|---------|
| „Permission denied” | `chmod +x *.sh` |
| Validatorul eșuează la line endings | `dos2unix src/*.sh` sau configurează editorul pe LF |
| Testele intră în timeout | Mărește cu `--timeout 120` |
| Arhiva e prea mare | Verifică dacă ai inclus accidental fișiere de date |
| Docker nu este disponibil | Rulează fără flag-ul `--docker` |

---

*Vezi și: [`../README.md`](../README.md) pentru specificațiile proiectelor*  
*Vezi și: [`../UNIVERSAL_RUBRIC.md`](../UNIVERSAL_RUBRIC.md) pentru criterii de evaluare*

*Ultima actualizare: ianuarie 2026*
