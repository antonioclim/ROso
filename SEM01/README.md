# Seminar 1: Shell Bash - Pachet Complet

> **Sisteme de Operare** | Academia de Studii Economice București - CSIE

---

## Cuprins

- [Descriere](#descriere)
- [Structura Pachetului](#structura-pachetului)
- [Ghid de Utilizare](#ghid-de-utilizare)
- [Pentru Instructori](#pentru-instructori)
- [Pentru Studenți](#pentru-studenți)
- [Cerințe Tehnice](#cerințe-tehnice)
- [Instalare și Configurare](#instalare-și-configurare)

---

## Descriere

Acest pachet conține toate materialele necesare pentru **Seminar 1: Shell Bash**

> Am dezvoltat aceste materiale pe parcursul a 5+ ani de predare la ASE. Structura reflectă exact greșelile pe care le-am văzut la studenți și soluțiile care chiar funcționează. Dacă găsești erori sau ai sugestii, sunt binevenite! din cadrul cursului de Sisteme de Operare. Pachetul include:

- ✅ Prezentări HTML interactive
- ✅ Scripturi demo pentru live coding
- ✅ Scripturi Python pentru auto-evaluare
- ✅ Teme și template-uri pentru studenți
- ✅ Cheat sheet-uri și resurse
- ✅ Sistem de quiz-uri randomizate
- ✅ Validator automat pentru teme

### Obiective de Învățare

După parcurgerea acestui seminar, studenții vor putea:

1. **Naviga** eficient în sistemul de fișiere Linux
2. **Înțelege** ierarhia FHS și scopul fiecărui director
3. **Lucra** cu variabile shell (locale, mediu, speciale)
4. **Configura** mediul de lucru prin ~/.bashrc
5. **Utiliza** wildcards (globbing) pentru selecție de fișiere
6. **Scrie** scripturi bash de bază

---

## Structura Pachetului

```
Seminar 1_COMPLET/
├── 📄 README.md                           # Acest fișier
├── 📂 docs/                               # Documentație pedagogică
│   ├── S01_00_ANALIZA_SI_PLAN_PEDAGOGIC.md
│   ├── S01_01_GHID_INSTRUCTOR.md
│   ├── S01_02_MATERIAL_PRINCIPAL.md
│   ├── S01_03_PEER_INSTRUCTION.md
│   ├── S01_04_PARSONS_PROBLEMS.md
│   ├── S01_05_LIVE_CODING_GUIDE.md
│   ├── S01_06_EXERCITII_SPRINT.md
│   ├── S01_07_LLM_AWARE_EXERCISES.md
│   ├── S01_08_DEMO_SPECTACULOASE.md
│   ├── S01_09_CHEAT_SHEET_VIZUAL.md
│   └── S01_10_AUTOEVALUARE_REFLEXIE.md
├── 📂 scripts/
│   ├── 📂 bash/                           # Scripturi Bash
│   │   ├── S01_01_setup_seminar.sh        # Pregătire mediu
│   │   ├── S01_02_quiz_interactiv.sh      # Quiz interactiv terminal
│   │   └── S01_03_validator.sh            # Verificare teme
│   ├── 📂 demo/                           # Demo-uri pentru prezentare
│   │   ├── S01_01_hook_demo.sh            # Hook captivant
│   │   ├── S01_02_demo_quoting.sh         # Demonstrație quoting
│   │   ├── S01_03_demo_variabile.sh       # Demonstrație variabile
│   │   ├── S01_04_demo_fhs.sh             # Explorer FHS
│   │   └── S01_05_demo_globbing.sh        # Demonstrație wildcards
│   └── 📂 python/                         # Utilitare Python
│       ├── S01_01_autograder.py           # Evaluator automat teme
│       ├── S01_02_quiz_generator.py       # Generator quiz-uri
│       └── S01_03_report_generator.py     # Generator rapoarte
├── 📂 prezentari/                         # Prezentări HTML
│   ├── S01_01_prezentare.html             # Prezentare principală
│   └── S01_02_cheat_sheet.html            # Cheat sheet interactiv
├── 📂 teme/                               # Teme și template-uri
│   ├── S01_01_TEMA.md                     # Enunț temă
│   └── S01_02_creeaza_tema.sh             # Generator template
├── 📂 resurse/                            # Materiale suplimentare
│   └── S01_RESURSE.md                     # Link-uri și bibliografie
└── 📂 teste/                              # Teste și verificări
    └── (generate automat)
```

---

## Ghid de Utilizare

### Pași Rapizi

```bash
# 1. Dezarhivează pachetul
unzip Seminar 1_COMPLET.zip
cd Seminar 1_COMPLET

# 2. Fă scripturile executabile
chmod +x scripts/**/*.sh

# 3. Rulează setup-ul pentru mediul de laborator
./scripts/bash/S01_01_setup_seminar.sh

# 4. Deschide prezentarea în browser
xdg-open prezentari/S01_01_prezentare.html
# sau pe macOS: open prezentari/seminar1_prezentare.html
```

---

## ‍ Pentru Instructori

### Pregătire Seminar (30 min înainte)

1. **Verifică mediul**:
   ```bash
   ./scripts/bash/S01_01_setup_seminar.sh --full
   ```

2. **Testează demo-urile**:
   ```bash
   ./scripts/demo/S01_01_hook_demo.sh
   ```

3. **Deschide materialele**:
   - Prezentare: `prezentari/S01_01_prezentare.html`
   - Ghid live coding: `docs/S01_05_LIVE_CODING_GUIDE.md`
   - Peer instruction: `docs/S01_03_PEER_INSTRUCTION.md`

### Structura Seminarului (100 min)

| Timp | Activitate | Material |
|------|-----------|----------|
| 0-3 | Hook demo | `S01_01_hook_demo.sh` |
| 3-8 | Peer Instruction Q1 | Slide 6 |
| 8-23 | Live coding navigare | `docs/S01_05_LIVE_CODING_GUIDE.md` |
| 23-28 | Parsons Problem | `docs/S01_04_PARSONS_PROBLEMS.md` |
| 28-43 | Sprint 1: System Explorer | `docs/S01_06_EXERCITII_SPRINT.md` |
| 43-48 | Peer Instruction Q2 | Slide 8 |
| 48-58 | **PAUZĂ** | |
| 58-63 | Quiz reactivare | `S01_02_quiz_interactiv.sh` |
| 63-78 | Live coding variabile | Ghid live coding |
| 78-83 | Peer Instruction Q3 | |
| 83-98 | Sprint 2: Shell Configurator | |
| 98-100 | Wrap-up, temă | |

### Evaluare Teme

```bash
# Evaluare automată pentru un student
python3 scripts/python/S01_01_autograder.py ~/teme/PopescuIon/

# Generare raport pentru toată grupa
python3 scripts/python/S01_03_report_generator.py --input rezultate/ --output rapoarte/

# Generare quiz-uri unice pentru examen
python3 scripts/python/S01_02_quiz_generator.py --students 30 --output quizzes/
```

---

## ‍ Pentru Studenți

### Începe Aici

1. **Deschide cheat sheet-ul**:
   ```bash
   xdg-open prezentari/S01_02_cheat_sheet.html
   ```

2. **Creează structura pentru temă**:
   ```bash
   ./teme/S01_02_creeaza_tema.sh "Numele Tău" "Grupa"
   ```

3. **Testează-ți tema înainte de predare**:
   ```bash
   ./scripts/bash/S01_03_validator.sh ~/tema_seminar1/
   ```

4. **Exersează cu quiz-ul**:
   ```bash
   ./scripts/bash/S01_02_quiz_interactiv.sh
   ```

### Resurse de Studiu

- 📖 Citește: `docs/S01_02_MATERIAL_PRINCIPAL.md`
- 🎯 Exersează: `docs/S01_06_EXERCITII_SPRINT.md`
- 📝 Reflectează: `docs/S01_10_AUTOEVALUARE_REFLEXIE.md`
- 🔗 Explorează: `resurse/S01_RESURSE.md`

---

## Cerințe Tehnice

### Obligatoriu
- Ubuntu 20.04+ / WSL2 / macOS cu Bash 4.0+
- Python 3.8+ (pentru scripturi de evaluare)
- Browser modern (Chrome, Firefox, Edge)

### Opțional (pentru demo-uri spectaculoase)
```bash
sudo apt-get install figlet lolcat cmatrix cowsay tree ncdu pv dialog
```

### Verificare Instalare
```bash
bash --version    # Ar trebui să fie 4.0+
python3 --version # Ar trebui să fie 3.8+
```

---

## Instalare și Configurare

### Metoda 1: Descărcare Directă
```bash
# Descarcă și dezarhivează
wget [URL]/Seminar 1_COMPLET.zip
unzip Seminar 1_COMPLET.zip
cd Seminar 1_COMPLET
```

### Metoda 2: Copiere pe Stick USB
1. Copiază întregul folder `Seminar 1_COMPLET`
2. Copiază pe calculatorul de laborator
3. Rulează `setup_seminar.sh`

### Configurare Laborator (WSL)
```bash
# Credențiale standard laborator
# User: stud
# Pass: stud

# Portainer (dacă e disponibil)
# URL: localhost:9000
# User: stud
# Pass: studstudstud
```

---

## Licență

Materialele sunt create pentru uz educațional în cadrul ASE București - CSIE.
Redistribuirea în afara cursului necesită aprobare.

---

## Probleme Frecvente

### "Permission denied" la rulare script
```bash
chmod +x script.sh
./script.sh
```

### Prezentarea nu se deschide
```bash
# Încearcă direct cu browser
firefox prezentari/seminar1_prezentare.html
# sau
google-chrome prezentari/seminar1_prezentare.html
```

### Python nu găsește module
```bash
pip3 install --user pathlib
```

---

*Creat cu ❤️ pentru studenții ASE București*

**Ultima actualizare**: Ianuarie 2025
