# 📁 Demo-uri live — SEM02

> **Locație:** `SEM02/scripts/demo/`  
> **Scop:** demonstrații interactive pentru predarea seminarului  
> **Public:** cadre didactice și studenți (pentru lucru „împreună”)

## Conținut

| Demo | Temă | Durată |
|------|-------|----------|
| `S02_01_hook_demo.sh` | introducere „hook” | ~3-5 min |
| `S02_02_demo_pipes.sh` | compunerea pipeline-urilor | ~3-5 min |
| `S02_03_demo_redirection.sh` | redirecționare I/O | ~3-5 min |
| `S02_04_demo_filters.sh` | filtre de text | ~3-5 min |
| `S02_05_demo_loops.sh` | construcții de bucle | ~3-5 min |

## Cum se prezintă

### Pregătire

1. Deschide terminalul în mod fullscreen
2. Mărește fontul: `Ctrl++` sau Terminal → Preferences
3. Folosește, dacă e posibil, un fundal închis pentru vizibilitate
4. Parcurge sursa scriptului demo înainte de curs

### Rulare demo-uri

```bash
# Marchează toate ca executabile (o singură dată)
chmod +x *.sh

# Rulează un demo specific
./S02_0X_demo_topic.sh

# Rulează cu pauze de explicație (afișează comenzile)
bash -v ./S02_0X_demo_topic.sh
```

## Descrieri demo

### S02_01_hook_demo.sh

**Scop:** deschidere care captează atenția la începutul seminarului  
**Durată:** ~3 minute  
**Efecte vizuale:** ASCII art, culori, animații opționale

```bash
# Cu efecte complete (necesită figlet, lolcat)
./S02_01_hook_demo.sh

# Instalare instrumente vizuale opționale (Ubuntu)
sudo apt install figlet lolcat cowsay
```

### S02_02_demo_pipes.sh

**Scop:** compunerea pipeline-urilor

```bash
./S02_02_demo_pipes.sh
```

### S02_03_demo_redirection.sh

**Scop:** redirecționare I/O

```bash
./S02_03_demo_redirection.sh
```

### S02_04_demo_filters.sh

**Scop:** filtre de text

```bash
./S02_04_demo_filters.sh
```

### S02_05_demo_loops.sh

**Scop:** construcții de bucle

```bash
./S02_05_demo_loops.sh
```

## Sugestii didactice

### Pentru cadre didactice

- **Citește sursa mai întâi** — comentariile includ note de predare
- **Oprește-te în punctele cheie** — scripturile au pauze `read` incluse
- **Încurajează predicția** — întreabă studenții ce se va întâmpla înainte de rulare
- **Arată și eșecuri** — cazurile de eroare sunt instructive

### Pentru auto-studiu

```bash
# Parcurgere pas cu pas
bash -x ./demo_script.sh

# Citire cu numere de linie
cat -n ./demo_script.sh | less
```

## Caracteristici ale scripturilor

Toate demo-urile includ:

- `set -euo pipefail` pentru tratarea sigură a erorilor
- output colorat pentru vizibilitate
- comentarii `# TEACHING NOTE:` pentru instructor
- pauze integrate în punctele importante
- curățarea fișierelor temporare

## Personalizare

### Ajustarea vitezei

Editează variabila `PAUSE_DURATION` la începutul scriptului:
```bash
PAUSE_DURATION=2  # secunde între pași
```

### Dezactivarea culorilor

```bash
NO_COLOR=1 ./S02_02_demo_topic.sh
```

---

## Resurse conexe

- [`../bash/`](../bash/) — utilitare pentru studenți
- [`../../docs/`](../../docs/) — documentație completă
- [`../../presentations/`](../../presentations/) — materiale de prezentare

---

*Sfat practic: exersează demo-urile înainte de curs pentru o livrare fluidă*

*Ultima actualizare: ianuarie 2026*
