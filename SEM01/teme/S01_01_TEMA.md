# TEMA SEMINAR 1-2: Shell Bash

> **Sisteme de Operare** | ASE București - CSIE  
> **Deadline:** [Se va completa de instructor]  
> **Punctaj maxim:** 100%  
> **Mod de predare:** Arhivă ZIP cu numele `NumePrenume_Seminar1.zip`

---

## Obiective

Această temă verifică înțelegerea conceptelor prezentate în Seminarul 1-2:
- Navigarea în sistemul de fișiere Linux
- Lucrul cu variabile shell
- Configurarea mediului de lucru (.bashrc)
- Utilizarea wildcards (globbing)

---

## Structura Temei

Creează următoarea structură de directoare în directorul tău home:

```
tema_seminar1/
├── proiect/
│   ├── src/
│   │   ├── main.sh           # Script principal
│   │   ├── variabile.sh      # Exercițiul 2
│   │   └── info_sistem.sh    # Exercițiul 5
│   ├── docs/
│   │   └── README.md         # Documentație
│   └── tests/
│       └── test_globbing.sh  # Exercițiul 4
├── .bashrc                   # Configurare personalizată (copie)
└── AUTOR.txt                 # Informații student
```

---

## Exerciții

### Exercițiul 1: Crearea Structurii (20%)

**Cerință:** Creează structura de directoare de mai sus folosind DOAR comenzi shell.

1. (10%) Creează toată ierarhia de directoare cu o singură comandă `mkdir`
2. (5%) Creează fișierul `README.md` cu un titlu și descriere scurtă
3. (5%) Creează fișierul `AUTOR.txt` cu numele și grupa ta

**Comenzi de documentat în README.md:**
```bash
# Scrie aici comenzile pe care le-ai folosit
```

---

### Exercițiul 2: Script Variabile (25%)

**Cerință:** Creează scriptul `variabile.sh` care demonstrează lucrul cu variabile.

Scriptul trebuie să:

1. (5%) Definească cel puțin 3 variabile locale
2. (5%) Afișeze variabilele de mediu importante: `$USER`, `$HOME`, `$SHELL`, `$PATH`
3. (5%) Demonstreze diferența între variabile locale și de mediu (cu export)
4. (5%) Afișeze exit code-ul ultimei comenzi (`$?`)
5. (5%) Folosească corect quoting (single și double quotes)

**Șablon de pornire:**
```bash
#!/bin/bash
# variabile.sh - Demonstrație variabile Bash
# Autor: [Numele tău]
# Data: [Data]

echo "=== VARIABILE LOCALE ==="
# TODO: Definește și afișează variabile locale

echo ""
echo "=== VARIABILE DE MEDIU ==="
# TODO: Afișează variabilele de mediu importante

echo ""
echo "=== DEMONSTRAȚIE EXPORT ==="
# TODO: Arată diferența între local și export

echo ""
echo "=== QUOTING ==="
# TODO: Demonstrează single vs double quotes
```

---

### Exercițiul 3: Configurare .bashrc (25%)

**Cerință:** Personalizează fișierul `.bashrc` cu următoarele elemente:

1. (10%) **Alias-uri obligatorii:**
   - `ll` → `ls -la`
   - `cls` → `clear`
   - `..` → `cd ..`
   - Un alias la alegere pentru o comandă frecvent folosită

2. (10%) **Funcția mkcd:**
   ```bash
   # Creează director și intră în el
   mkcd() {
       # TODO: Implementează
   }
   ```

3. (5%) **Modificare PATH:**
   - Adaugă `$HOME/bin` la începutul PATH

**Observație:** Include un comentariu la fiecare secțiune explicând ce face.

---

### Exercițiul 4: Globbing (20%)

**Cerință:** Creează scriptul `test_globbing.sh` care demonstrează înțelegerea wildcards.

1. (5%) Creează fișiere de test:
   ```bash
   touch file{1..10}.txt doc{A..E}.pdf image{01..05}.jpg .hidden
   ```

2. (5%) Scrie comenzi care:
   - Listează DOAR fișierele `.txt`
   - Listează `file1.txt` până la `file5.txt` (folosind range)
   - Listează toate fișierele care au EXACT 5 caractere înainte de extensie

3. (5%) Explică în comentarii de ce `ls *` nu afișează `.hidden`

4. (5%) Scrie o comandă care folosește brace expansion pentru a crea directoare `dir1`, `dir2`, `dir3`

---

### Exercițiul 5: Script Integrat (10%)

**Cerință:** Creează scriptul `info_sistem.sh` care afișează un raport despre sistem.

Scriptul trebuie să afișeze:
1. (2%) Numele utilizatorului curent
2. (2%) Directorul home
3. (2%) Shell-ul utilizat
4. (2%) Versiunea kernel-ului (`uname -r`)
5. (2%) Data și ora curentă

**Format output recomandat:**
```
╔════════════════════════════════════════╗
║         RAPORT SISTEM                  ║
╠════════════════════════════════════════╣
║ Utilizator: student                    ║
║ Home:       /home/student              ║
║ Shell:      /bin/bash                  ║
║ Kernel:     5.15.0-generic             ║
║ Data:       2024-01-15 14:30:00        ║
╚════════════════════════════════════════╝
```

---

## Criterii de Evaluare

| Criteriu | Punctaj |
|----------|---------|
| Structură corectă | 20% |
| Script variabile funcțional | 25% |
| Configurare .bashrc completă | 25% |
| Demonstrație globbing | 20% |
| Script info sistem | 10% |
| **TOTAL** | **100%** |

### Bonusuri (max 10p extra):
- +3p: Prompt PS1 personalizat cu culori
- +3p: Funcție `extract()` pentru dezarhivare
- +2p: Comentarii detaliate și cod curat
- +2p: Gestionarea erorilor în scripturi

### Penalizări:
- -10p: Erori de sintaxă în scripturi
- -5p: Lipsa comentariilor
- -5p: Nerespectarea structurii cerute
- -20p: Plagiat (verificat automat)

---

## Mod de Predare

1. Creează arhiva:
   ```bash
   cd ~
   zip -r NumePrenume_Seminar1.zip tema_seminar1/
   ```

2. Verifică conținutul:
   ```bash
   unzip -l NumePrenume_Seminar1.zip
   ```

3. Încarcă pe platforma de cursuri înainte de deadline.

---

## Verificare Automată

Tema va fi verificată automat. Poți testa local:

```bash
# Descarcă autograder-ul
python3 autograder.py ~/tema_seminar1/

# Sau verifică manual:
bash -n proiect/src/variabile.sh  # Verifică sintaxa
./proiect/src/variabile.sh        # Rulează scriptul
```

---

## Întrebări Frecvente

**Q: Ce fac dacă nu merge comanda X?**
A: Verifică mai întâi cu `type X` dacă comanda există și cu `man X` cum se folosește.

**Q: Pot folosi alte shell-uri (zsh, fish)?**
A: Nu. Tema trebuie să funcționeze în Bash (`#!/bin/bash`).

**Q: Pot colabora cu colegii?**
A: Poți discuta concepte, dar codul trebuie să fie propriu. Plagiatul se penalizează sever.

---

## Resurse Utile

- `man bash` - Manual Bash
- https://explainshell.com - Explică comenzi shell
- https://tldr.sh - Exemple rapide pentru comenzi
- Materialele de seminar din arhiva cursului

---

