# 📁 Demonstrații live — SEM03

> **Locație:** `SEM03/scripts/demo/`  
> **Scop:** demonstrații interactive pentru predarea seminarului  
> **Audiență:** instructori și studenți care urmăresc în paralel


## Conținut

| Demo | Subiect | Durată |
|------|---------|--------|
| `S03_01_hook_demo.sh` | Introducere memorabilă | ~3–5 min |
| `S03_02_demo_find_xargs.sh` | Find & xargs | ~3–5 min |
| `S03_03_demo_getopts.sh` | Parsare opțiuni | ~3–5 min |
| `S03_04_demo_permissions.sh` | Permisiuni fișiere | ~3–5 min |
| `S03_05_demo_cron.sh` | Sarcini programate | ~3–5 min |


## Cum să prezinți


### Pregătire

1. Deschide terminalul în modul fullscreen
2. Mărește fontul: `Ctrl++` sau Terminal → Preferences
3. Consideră un fundal închis pentru vizibilitate
4. Citește sursa scriptului demo înainte de curs


### Rulare demo

```bash

# Make all executable (once)
chmod +x *.sh


# Run specific demo
./S03_0X_demo_topic.sh


# Run with explanation pauses
bash -v ./S03_0X_demo_topic.sh
```


## Caracteristici ale scripturilor

Toate scripturile demo includ:

- `set -euo pipefail` pentru tratarea sigură a erorilor
- output colorat pentru vizibilitate
- comentarii `# TEACHING NOTE:` pentru instructori
- pauze integrate în punctele de demonstrație
- curățare a fișierelor temporare


### S03_01_hook_demo.sh

**Scop:** deschidere care captează atenția la începutul seminarului  
**Durată:** ~3 minute  
**Efecte vizuale:** ASCII art, culori, animații opționale

```bash

# With full effects (requires figlet, lolcat)
./S03_01_hook_demo.sh


# Install optional visual tools (Ubuntu)
sudo apt install figlet lolcat cowsay
```


### S03_02_demo_find_xargs.sh

**Scop:** Find & xargs

```bash
./S03_02_demo_find_xargs.sh
```


### S03_03_demo_getopts.sh

**Scop:** parsare opțiuni

```bash
./S03_03_demo_getopts.sh
```


### S03_04_demo_permissions.sh

**Scop:** permisiuni fișiere

```bash
./S03_04_demo_permissions.sh
```


### S03_05_demo_cron.sh

**Scop:** sarcini programate

```bash
./S03_05_demo_cron.sh
```


## Teaching Tips


### Pentru instructori

- **Citește întâi codul sursă** — comentariile conțin note pentru predare
- **Pauzează în punctele-cheie** — scripturile au pauze `read` integrate
- **Încurajează predicția** — întreabă studenții ce cred că se va întâmpla înainte de rulare
- **Arată și eșecurile** — cazurile de eroare sunt educative


### Pentru auto-studiu

```bash

# Step through manually
bash -x ./demo_script.sh


# Read with line numbers
cat -n ./demo_script.sh | less
```


## Descrierea demo-urilor

All demo scripts include:

- `set -euo pipefail` for safe error handling
- Coloured output for visibility
- `# TEACHING NOTE:` comments for instructors
- Built-in pauses at demonstration points
- Cleanup of any temporary files


## Customisation


### Ajustarea vitezei

Editează variabila `PAUSE_DURATION` din partea de sus a scriptului:

```bash
PAUSE_DURATION=2  # seconds between steps
```


### Dezactivarea culorilor

```bash
NO_COLOR=1 ./S03_02_demo_topic.sh
```

---


## Resurse conexe

- [`../bash/`](../bash/) — utilitare pentru studenți
- [`../../docs/`](../../docs/) — documentație completă
- [`../../presentations/`](../../presentations/) — materiale tip slide

---

*Sfat practic: exersează demo-urile înainte de curs pentru o desfășurare fluentă.*

*Ultima actualizare: ianuarie 2026*

