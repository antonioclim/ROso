# 📁 Demo-uri live — SEM05

> **Locație:** `scripts/demo/`  
> **Scop:** demonstrații interactive pentru predarea seminarului  
> **Public:** instructori și studenți (pentru lucru în paralel)

## Conținut

| Demo | Temă | Durată |
|------|------|--------|
| `S05_01_hook_demo.sh` | „hook” de început (captare atenție) | ~3–5 min |
| `S05_02_demo_functions.sh` | definirea funcțiilor | ~3–5 min |
| `S05_03_demo_arrays.sh` | operații pe arrays | ~3–5 min |
| `S05_04_demo_robust.sh` | scripting robust | ~3–5 min |
| `S05_05_demo_logging.sh` | tipare de jurnalizare | ~3–5 min |
| `S05_06_demo_debug.sh` | tehnici de depanare | ~3–5 min |

## Cum să prezentați

### Pregătire

1. Deschideți terminalul pe ecran complet
2. Măriți fontul: `Ctrl++` sau Terminal → Preferences
3. Luați în calcul un fundal închis pentru vizibilitate
4. Citiți sursa scriptului demo înainte de curs

### Rulare demo-uri

```bash
# Faceți toate scripturile executabile (o singură dată)
chmod +x *.sh

# Rulați un demo specific
./S05_0X_demo_topic.sh

# Rulare cu „pauze” explicative (afișează fiecare linie înainte de execuție)
bash -v ./S05_0X_demo_topic.sh
```

## Descrieri demo

### S05_01_hook_demo.sh

**Scop:** deschidere cu impact pentru începutul seminarului  
**Durată:** ~3 minute  
**Efecte vizuale:** ASCII art, culori, animații opționale

```bash
# Cu efecte complete (necesită figlet, lolcat)
./S05_01_hook_demo.sh

# Instalare instrumente vizuale opționale (Ubuntu)
sudo apt install figlet lolcat cowsay
```

### S05_02_demo_functions.sh

**Scop:** definirea funcțiilor

```bash
./S05_02_demo_functions.sh
```

### S05_03_demo_arrays.sh

**Scop:** operații pe arrays

```bash
./S05_03_demo_arrays.sh
```

### S05_04_demo_robust.sh

**Scop:** scripting robust

```bash
./S05_04_demo_robust.sh
```

### S05_05_demo_logging.sh

**Scop:** tipare de jurnalizare

```bash
./S05_05_demo_logging.sh
```

### S05_06_demo_debug.sh

**Scop:** tehnici de depanare

```bash
./S05_06_demo_debug.sh
```

## Sfaturi didactice

### Pentru instructori

- **Citiți sursa întâi** — comentariile conțin note de predare
- **Opriți-vă în punctele cheie** — scripturile au pauze `read` integrate
- **Încurajați predicția** — întrebați studenții ce cred că se va întâmpla înainte de a rula
- **Arătați și eșecuri** — cazurile de eroare sunt educative

### Pentru studiu individual

```bash
# Parcurgere pas cu pas
bash -x ./demo_script.sh

# Citire cu numerotarea liniilor
cat -n ./demo_script.sh | less
```

## Caracteristici ale scripturilor

Toate demo-urile includ:

- `set -euo pipefail` pentru gestionarea sigură a erorilor
- output colorat pentru vizibilitate
- comentarii `# TEACHING NOTE:` pentru instructor
- pauze integrate în punctele de demonstrație
- curățarea fișierelor temporare

## Personalizare

### Ajustarea vitezei

Editați variabila `PAUSE_DURATION` la începutul scriptului:
```bash
PAUSE_DURATION=2  # seconds between steps
```

### Dezactivarea culorilor

```bash
NO_COLOR=1 ./S05_02_demo_topic.sh
```

---

## Resurse conexe

- [`../bash/`](../bash/) — scripturi utilitare pentru studenți
- [`../../docs/`](../../docs/) — documentație completă
- [`../../presentations/`](../../presentations/) — materiale de prezentare

---

*Pro tip: exersați demo-urile înainte de curs pentru o livrare fluentă*

*Ultima actualizare: ianuarie 2026*
