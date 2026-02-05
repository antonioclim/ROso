# 📁 Demo-uri Live — SEM01

> **Locație:** `SEM01/scripts/demo/`  
> **Scop:** Demonstrații interactive pentru predarea seminarului  
> **Public țintă:** Instructori și studenți care urmăresc

## Conținut

| Demo | Subiect | Durată |
|------|---------|--------|
| `S01_01_hook_demo.sh` | Captarea atenției | ~3-5 min |
| `S01_02_demo_quoting.sh` | Citare șiruri | ~3-5 min |
| `S01_03_demo_variables.sh` | Variabile și expandare | ~3-5 min |
| `S01_04_demo_fhs.sh` | Ierarhia sistemului de fișiere | ~3-5 min |
| `S01_05_demo_globbing.sh` | Pattern-uri glob | ~3-5 min |

## Cum să prezentați

### Pregătire

1. Deschideți terminalul în modul ecran complet
2. Măriți dimensiunea fontului: `Ctrl++` sau Terminal → Preferințe
3. Luați în considerare un fundal întunecat pentru vizibilitate
4. Citiți codul sursă al demo-ului înainte de curs

### Rulare demo-uri

```bash
# Faceți toate executabile (o singură dată)
chmod +x *.sh

# Rulați un demo specific
./S01_0X_demo_topic.sh

# Rulați cu pauze de explicație
bash -v ./S01_0X_demo_topic.sh
```

## Descrieri demo-uri

### S01_01_hook_demo.sh

**Scop:** Opener pentru captarea atenției la începutul seminarului  
**Durată:** ~3 minute  
**Efecte vizuale:** ASCII art, culori, animații opționale

```bash
# Cu efecte complete (necesită figlet, lolcat)
./S01_01_hook_demo.sh

# Instalare instrumente vizuale opționale (Ubuntu)
sudo apt install figlet lolcat cowsay
```


### S01_02_demo_quoting.sh

**Scop:** Citare șiruri

```bash
./S01_02_demo_quoting.sh
```

### S01_03_demo_variables.sh

**Scop:** Variabile și expandare

```bash
./S01_03_demo_variables.sh
```

### S01_04_demo_fhs.sh

**Scop:** Ierarhia sistemului de fișiere

```bash
./S01_04_demo_fhs.sh
```

### S01_05_demo_globbing.sh

**Scop:** Pattern-uri glob

```bash
./S01_05_demo_globbing.sh
```


## Sfaturi pentru predare

### Pentru instructori

- **Citiți codul sursă mai întâi** — Comentariile conțin note de predare
- **Faceți pauză la punctele cheie** — Scripturile au pauze `read` încorporate
- **Încurajați predicția** — Întrebați studenții ce se va întâmpla înainte de rulare
- **Arătați și eșecurile** — Cazurile de eroare sunt educative

### Pentru studiu individual

```bash
# Parcurgeți pas cu pas
bash -x ./demo_script.sh

# Citiți cu numere de linie
cat -n ./demo_script.sh | less
```

## Caracteristici scripturi

Toate scripturile demo includ:

- `set -euo pipefail` pentru gestionare sigură a erorilor
- Output colorat pentru vizibilitate
- Comentarii `# NOTĂ PREDARE:` pentru instructori
- Pauze încorporate la punctele de demonstrație
- Curățare a fișierelor temporare create

## Personalizare

### Ajustare viteză

Editați variabila `PAUSE_DURATION` la începutul scriptului:
```bash
PAUSE_DURATION=2  # secunde între pași
```

### Dezactivare culori

```bash
NO_COLOR=1 ./S01_02_demo_topic.sh
```

---

## Resurse conexe

- [`../bash/`](../bash/) — Scripturi utilitare pentru studenți
- [`../../docs/`](../../docs/) — Documentație completă
- [`../../prezentari/`](../../prezentari/) — Materiale prezentări

---

*Sfat pro: Exersați demo-urile înainte de curs pentru livrare fluentă*

*Ultima actualizare: Ianuarie 2026*
