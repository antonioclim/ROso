# Seminar 5-6: Utilitare Avansate, Scripturi Profesionale și Automatizare

> Sisteme de Operare | Academia de Studii Economice București - CSIE  
> Versiune: 1.0 | Data: Ianuarie 2025

---

## Cuprins

1. [Descriere](#-descriere)
2. [Obiective de Învățare](#-obiective-de-învățare)
3. [Structura Pachetului](#-structura-pachetului)
4. [Ghid de Utilizare](#-ghid-de-utilizare)
5. [Pentru Instructori](#-pentru-instructori)
6. [Pentru Studenți](#-pentru-studenți)
7. [Cerințe Tehnice](#️-cerințe-tehnice)
8. [Note de Securitate](#-note-de-securitate)
9. [Instalare și Configurare](#-instalare-și-configurare)
10. [Probleme Frecvente](#-probleme-frecvente)
11. [Resurse Suplimentare](#-resurse-suplimentare)
12. [Changelog](#-changelog)

---

## Descriere

### Context Pedagogic

Acest seminar este continuarea directă a SEM03-04 și marchează o tranziție importantă în parcursul educațional:

| De la | Către |
|-------|-------|
| Comenzi interactive | Scripturi profesionale |
| Utilizator obișnuit | Administrator sistem |
| Execuție ad-hoc | Automatizare programată |

### Precondiții

Studenții trebuie să fi parcurs și înțeles:
- SEM01-02: Navigare filesystem, variabile shell, globbing de bază
- SEM03-04: Operatori de control (&&, ||, ;), redirecționare I/O, filtre text, bucle

### Tematică

Seminarul acoperă patru module principale:

1. Utilitare Avansate de Căutare: `find`, `xargs`, `locate` - căutare și procesare în masă
2. Scripturi Profesionale: Parametri ($1-$9, $@, shift), `getopts`, opțiuni lungi
3. Sistemul de Permisiuni Unix: `chmod`, `chown`, `umask`, SUID/SGID/Sticky Bit
4. Automatizare: `cron`, `at`, `batch` - programare task-uri

---

## Obiective de Învățare

La finalul acestui seminar, studenții vor fi capabili să:

### Nivel Cunoaștere (Remember)

- [ ] Enumereze opțiunile principale ale comenzii `find`
- [ ] Descrie structura unei linii crontab
- [ ] Identifice componentele permisiunilor Unix (rwx)


### Nivel Înțelegere (Understand)
- [ ] Explice diferența dintre `$@` și `$*` în scripturi
- [ ] Interpreteze permisiunile în format octal și simbolic
- [ ] Descrie rolul SUID, SGID și Sticky Bit

### Nivel Aplicare (Apply)
- [ ] Construiască căutări complexe cu `find` și criterii multiple
- [ ] Scrie scripturi care acceptă argumente și opțiuni folosind `getopts`
- [ ] Configure permisiuni corecte pentru scenarii date
- Testează mai întâi cu date simple

### Nivel Analiză (Analyze)

- [ ] Depaneze probleme cu job-uri cron care nu funcționează
- [ ] Identifice vulnerabilități de securitate în configurări de permisiuni
- [ ] Evalueze când să folosească `find -exec` vs `xargs`


### Nivel Evaluare (Evaluate)

- [ ] Justifice alegerea unei metode de parsare a argumentelor
- [ ] Critice răspunsuri generate de LLM pentru comenzi shell
- [ ] Propună îmbunătățiri pentru scripturi existente


### Nivel Creare (Create)
- [ ] Dezvolte scripturi complete cu interfață CLI profesională
- [ ] Implementeze soluții de automatizare cu cron și logging
- [ ] Proiecteze scheme de permisiuni pentru scenarii complexe

---

## Structura Pachetului

```
SEM05-06_COMPLET/
│
├── README.md                              # 📖 Acest fișier
│
├── docs/                                  # 📚 Documentație completă
│   ├── S03_00_ANALIZA_SI_PLAN_PEDAGOGIC.md   # Analiză materiale și plan
│   ├── S03_01_GHID_INSTRUCTOR.md             # Ghid pas-cu-pas pentru instructor
│   ├── S03_02_MATERIAL_PRINCIPAL.md          # Material teoretic complet
│   ├── S03_03_PEER_INSTRUCTION.md            # Întrebări MCQ pentru PI
│   ├── S03_04_PARSONS_PROBLEMS.md            # Probleme de reordonare cod
│   ├── S03_05_LIVE_CODING_GUIDE.md           # Ghid pentru live coding
│   ├── S03_06_EXERCITII_SPRINT.md            # Exerciții cronometrate
│   ├── S03_07_LLM_AWARE_EXERCISES.md         # Exerciții cu evaluare LLM
│   ├── S03_08_DEMO_SPECTACULOASE.md          # Demo-uri vizuale
│   ├── S03_09_CHEAT_SHEET_VIZUAL.md          # One-pager referință
│   └── S03_10_AUTOEVALUARE_REFLEXIE.md       # Checklist și reflecție
│
├── scripts/                               # 🔧 Scripturi funcționale
│   ├── bash/                              # Scripturi administrative
│   │   ├── S03_01_setup_seminar.sh           # Setup mediu de lucru
│   │   ├── S03_02_quiz_interactiv.sh         # Quiz cu dialog
│   │   └── S03_03_validator.sh               # Validator temă
│   │
│   ├── demo/                              # Demonstrații live
│   │   ├── S03_01_hook_demo.sh               # Hook spectaculos
│   │   ├── S03_02_demo_find_xargs.sh         # Demo find și xargs
│   │   ├── S03_03_demo_getopts.sh            # Demo parsare argumente
│   │   ├── S03_04_demo_permissions.sh        # Demo permisiuni vizual
│   │   └── S03_05_demo_cron.sh               # Demo cron generator
│   │
│   └── python/                            # Automatizare Python
│       ├── S03_01_autograder.py              # Autograder pentru teme
│       ├── S03_02_quiz_generator.py          # Generator întrebări
│       └── S03_03_report_generator.py        # Generator rapoarte
│
├── prezentari/                            # 🎬 Prezentări interactive
│   ├── S03_01_prezentare.html                # Prezentare principală
│   └── S03_02_cheat_sheet.html               # Cheat sheet interactiv
│
├── teme/                                  # 📝 Teme și materiale originale
│   ├── OLD_HW/                               # Fișierele sursă originale
│   │   ├── TC2e_Utilitare_Unix.md
│   │   ├── TC3c_Parametri_Script.md
│   │   ├── TC4b_Optiuni_Switches.md
│   │   ├── TC4g_Permisiuni_Fisiere.md
│   │   ├── TC4h_CRON.md
│   │   └── ANEXA_Referinte_Seminar3.md
│   ├── S03_01_TEMA.md                        # Enunț temă
│   └── S03_02_creeaza_tema.sh                # Generator structură temă
│
├── resurse/                               # 📎 Resurse suplimentare
│   └── S03_RESURSE.md                        # Link-uri și referințe

> 💡 Mulți studenți subestimează inițial importanța permisiunilor. Apoi întâlnesc primul 'Permission denied' și se luminează.

│
└── teste/                                 # ✅ (în dezvoltare)
    └── TODO.txt
```

---

## Ghid de Utilizare

### Pasul 1: Dezarhivare

```bash
# Descarcă și dezarhivează pachetul
unzip SEM05-06_COMPLET.zip -d ~/seminarii/
cd ~/seminarii/SEM05-06_COMPLET/
```

### Pasul 2: Setare Permisiuni Scripturi

```bash
# Fă toate scripturile executabile
chmod +x scripts/bash/*.sh
chmod +x scripts/demo/*.sh
chmod +x scripts/python/*.py
```

### Pasul 3: Setup Mediu de Lucru

```bash
# Rulează script-ul de setup
./scripts/bash/S03_01_setup_seminar.sh

# Verifică instalarea
./scripts/bash/S03_01_setup_seminar.sh --check
```

### Pasul 4: Verificare Completă

```bash
# Testează toate componentele
./scripts/bash/S03_01_setup_seminar.sh --test-all
```

---

## ‍ Pentru Instructori

### Checklist Pregătire Seminar

#### Cu 1-2 zile înainte:
- [ ] Verifică funcționarea Docker/WSL în laborator
- [ ] Rulează `S03_01_setup_seminar.sh` pe mașina de prezentare
- [ ] Pregătește slide-urile în `prezentari/`
- [ ] Revizuiește ghidul instructor `docs/S03_01_GHID_INSTRUCTOR.md`
- [ ] Printează cheat sheet-uri pentru studenți (opțional)

#### Cu 15 minute înainte:
- [ ] Pornește terminalul cu font mărit (Ctrl+Shift+Plus)
- [ ] Deschide fișierele demo în tabs separate
- [ ] Creează directorul sandbox: `mkdir -p ~/demo_sem3`
- [ ] Verifică că cron-ul funcționează: `systemctl status cron`

### Structura Seminarului (100 min)

| Timp | Durată | Activitate | Materiale |
|------|--------|------------|-----------|
| 0:00 | 5 min | 🎬 Hook: Power of Find | `S03_01_hook_demo.sh` |
| 0:05 | 5 min | 🗳️ PI #1: find vs locate | `S03_03_PEER_INSTRUCTION.md` |
| 0:10 | 15 min | 💻 Live Coding: find & xargs | `S03_05_LIVE_CODING_GUIDE.md` |
| 0:25 | 5 min | 🧩 Parsons Problem | `S03_04_PARSONS_PROBLEMS.md` |
| 0:30 | 15 min | 🏃 Sprint #1: Find Master | `S03_06_EXERCITII_SPRINT.md` |
| 0:45 | 5 min | 🗳️ PI #2: $@ vs $* | PI-06 |
| 0:50 | 10 min | ☕ PAUZĂ | - |
| 1:00 | 5 min | 🔄 Reactivare: Quiz Permisiuni | Quiz rapid |
| 1:05 | 15 min | 💻 Live Coding: Permisiuni | Sesiunea 4 |
| 1:20 | 5 min | 🗳️ PI #3: SUID | PI-13 |
| 1:25 | 15 min | 🏃 Sprint #2: Script Profesional | Sprint S1 |
| 1:40 | 8 min | 🤖 LLM + Cron Demo | `S03_07_LLM_AWARE.md` |
| 1:48 | 2 min | 🧠 Reflection | Întrebări finale |

### Atenționări Importante

> SECURITATE: Acest seminar implică lucrul cu permisiuni. Subliniază întotdeauna riscurile și NICIODATĂ nu demonstra `chmod 777` ca soluție acceptabilă!

- Exercițiile cu permisiuni se fac în `~/sandbox`, NU în directoare sistem
- Demonstrează întotdeauna `find -print` înainte de `-delete` sau `-exec rm`
- Cron jobs se testează cu `echo` înainte de comenzi reale
- Nu folosi sudo pentru exerciții normale

---

## ‍ Pentru Studenți

### Pași de Început

1. Citește materialul principal: `docs/S03_02_MATERIAL_PRINCIPAL.md`
2. Exersează cu demo-urile: `scripts/demo/`
3. Rezolvă exercițiile sprint: `docs/S03_06_EXERCITII_SPRINT.md`
4. Testează-ți cunoștințele: `scripts/bash/S03_02_quiz_interactiv.sh`
5. Completează tema: `teme/S03_01_TEMA.md`

### Resurse de Studiu Recomandate

| Resursă | Descriere | Prioritate |
|---------|-----------|------------|
| Cheat Sheet | One-pager cu toate comenzile | ⭐⭐⭐ |
| Material Principal | Teorie completă cu subgoal labels | ⭐⭐⭐ |
| Demo Scripts | Exemple funcționale comentate | ⭐⭐ |
| Quiz Interactiv | Autoevaluare | ⭐⭐ |

### Cum să Testezi Tema

```bash
# Folosește validatorul inclus
./scripts/bash/S03_03_validator.sh ~/tema_mea/

# Sau testează manual
shellcheck script.sh
bash -n script.sh
```

---

## Cerințe Tehnice

### Sistem de Operare
- Ubuntu 24.04 LTS (sau mai nou)
- **WSL2** pe Windows (Ubuntu)
- macOS cu Homebrew (parțial compatibil)

### Software Necesar

```bash
# Verificare rapidă
which find xargs locate chmod crontab at

# Instalare pachete adiționale (opțional)
sudo apt update
sudo apt install -y dialog shellcheck figlet
```

### Credențiale Laborator

| Parametru | Valoare |
|-----------|---------|
| Utilizator | `stud` |
| Parolă | `stud` |
| Portainer | `localhost:9000` |
| Portainer User | `stud` |
| Portainer Pass | `studstudstud` |

### Cerințe Minime


Concret: **RAM**: 1 GB disponibil. Disk: 100 MB spațiu liber. Și Terminal: suport ANSI colors.


---

## Note de Securitate

### REGULI CRITICE

1. NU rula scripturi necunoscute cu sudo
   ```bash
   # GREȘIT
   sudo ./script_necunoscut.sh
   
   # CORECT - verifică mai întâi
   cat ./script.sh
   shellcheck ./script.sh
   ./script.sh  # fără sudo
   ```

2. Testează permisiunile în directoare dedicate
   ```bash
   mkdir -p ~/sandbox/permissions_test
   cd ~/sandbox/permissions_test
   # Lucrează doar aici pentru exerciții
   ```

3. **Atenție la find cu -exec și rm**
   ```bash
   # GREȘIT - periculos!
   find / -name "*.tmp" -exec rm {} \;
   
   # CORECT - testează întâi
   find /tmp -name "*.tmp" -print  # vezi ce găsește
   find /tmp -name "*.tmp" -exec rm -i {} \;  # cu confirmare
   ```

4. Cron - testează cu echo
   ```bash
   # Testare
   * * * * * echo "Test $(date)" >> /tmp/cron_test.log
   
   # După verificare, adaugă comanda reală
   ```

5. NICIODATĂ chmod 777
   ```bash
   # GREȘIT - vulnerabilitate de securitate
   chmod 777 /var/www/html
   
   # CORECT
   chmod 755 /var/www/html
   chown -R www-data:www-data /var/www/html
   ```

---

## Instalare și Configurare

### Metoda 1: Descărcare Directă

```bash
# Din interfața web a cursului
wget https://curs.ase.ro/.../SEM05-06_COMPLET.zip
unzip SEM05-06_COMPLET.zip
cd SEM05-06_COMPLET
./scripts/bash/S03_01_setup_seminar.sh
```

### Metoda 2: Git Clone

```bash
git clone https://github.com/ase-so/seminar-materials.git
cd seminar-materials/SEM05-06
./scripts/bash/S03_01_setup_seminar.sh
```

### Metoda 3: Copiere de pe USB

```bash
cp -r /media/usb/SEM05-06_COMPLET ~/
cd ~/SEM05-06_COMPLET
chmod +x scripts/**/*.sh
./scripts/bash/S03_01_setup_seminar.sh
```

---

## Probleme Frecvente

### 1. Permission Denied la executare script

Problemă: `bash: ./script.sh: Permission denied`

Soluție:
```bash
chmod +x script.sh
./script.sh
# sau
bash script.sh
```

### 2. find: permission denied pe multiple directoare

Problemă: Multe mesaje de eroare la căutare în sistem

Soluție:
```bash
# Redirecționează erorile
find / -name "*.conf" 2>/dev/null
```

### 3. getopts nu parsează opțiuni lungi (--help)

Problemă: `getopts` nu recunoaște `--help`

Explicație: `getopts` suportă doar opțiuni scurte (-h). Pentru opțiuni lungi, folosește parsare manuală cu `case` și `while`.

### 4. Cron job nu rulează

Checklist:
```bash
# 1. Verifică serviciul cron
systemctl status cron

# 2. Verifică sintaxa
crontab -l

# 3. Verifică căile (trebuie să fie absolute)
which /usr/bin/script.sh

# 4. Verifică log-urile
grep CRON /var/log/syslog
```

### 5. umask nu persistă între sesiuni

Problemă: După logout, umask revine la valoarea implicită

Soluție:
```bash
# Adaugă în ~/.bashrc
echo "umask 022" >> ~/.bashrc
source ~/.bashrc
```

### 6. SUID nu funcționează pe scripturi bash

Explicație: Din motive de securitate, SUID este ignorat pentru scripturi interpretate (bash, python). Funcționează doar pentru binare compilate.

---

## Resurse Suplimentare

- [GNU Find Manual](https://www.gnu.org/software/findutils/manual/html_mono/find.html) — și legat de asta, [Bash Reference Manual](https://www.gnu.org/software/bash/manual/)
- [Linux Permissions Guide](https://linuxhandbook.com/linux-file-permissions/)
- [Crontab Guru](https://crontab.guru/) - Generator vizual crontab
- [ShellCheck](https://www.shellcheck.net/) - Linter pentru scripturi

---

## Changelog

### v1.0 - Ianuarie 2025
- Versiune inițială
- Include toate cele 4 module
- Scripturi testate pe Ubuntu 24.04 LTS
- Integrare completă cu framework-ul Brown & Wilson

---

*Material creat pentru cursul de Sisteme de Operare | ASE București - CSIE*  
*Prefixul fișierelor: S03_ (Seminar 3 în numerotarea internă)*
