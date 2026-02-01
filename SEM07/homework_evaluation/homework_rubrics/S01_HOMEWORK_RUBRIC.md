# Rubrică de evaluare — teme S01

> **Sisteme de Operare** | ASE Bucharest - CSIE  
> Seminar 01: fundamente de shell

---

## Prezentarea temelor

| ID | Subiect | Durată | Dificultate |
|----|-------|----------|------------|
| S01b | Utilizarea shell‑ului | 30 min | ⭐ |
| S01c | Configurarea shell‑ului | 45 min | ⭐⭐ |
| S01d | Variabile în shell | 40 min | ⭐⭐ |
| S01e | Globbing pentru fișiere | 35 min | ⭐⭐ |
| S01f | Globbing avansat | 45 min | ⭐⭐⭐ |
| S01g | Comenzi fundamentale | 50 min | ⭐⭐ |

---

## S01b - Utilizarea shell‑ului (10 puncte)

### Sarcini
1. Navigați în sistemul de fișiere folosind `cd`, `pwd`, `ls`
2. Utilizați eficient `man` și `--help`
3. Demonstrați navigarea în istoricul comenzilor
4. Utilizați completarea cu Tab

### Criterii de notare

| Criteriu | Puncte | Cerințe |
|-----------|--------|--------------|
| Navigare | 3.0 | Utilizare corectă a `cd`, `pwd`, `ls -la` |
| Sistem de help | 2.0 | Utilizare `man`, `--help`, `info` |
| Istoric | 2.0 | Utilizare `history`, `!!`, `!n` |
| Completare Tab | 2.0 | Demonstrarea completării pentru căi și comenzi |
| Stil | 1.0 | Flux curat, fără comenzi inutile |

### Depunctări uzuale
- `-0.5`: Utilizarea nejustificată a căilor absolute
- `-0.5`: Neutilizarea eficientă a opțiunilor `ls`
- `-1.0`: Incapacitatea de a identifica help‑ul pentru comenzi

---

## S01c - Configurarea shell‑ului (10 puncte)

### Sarcini
1. Vizualizați și modificați `.bashrc`
2. Creați alias‑uri utile
3. Personalizați prompt‑ul PS1
4. Setați și exportați variabile de mediu

### Criterii de notare

| Criteriu | Puncte | Cerințe |
|-----------|--------|--------------|
| Editare `.bashrc` | 3.0 | Editare sigură și reîncărcare (source) |
| Alias‑uri | 2.5 | Creați 3+ alias‑uri utile |
| Prompt PS1 | 2.5 | Personalizare cu informație utilă |
| Variabile | 2.0 | Setare, export, utilizare variabile |

### Output așteptat
```bash
# Alias example
alias ll='ls -la'
alias ..='cd ..'

# PS1 example
export PS1='\u@\h:\w\$ '
```

---

## S01d - Variabile în shell (10 puncte)

### Sarcini
1. Definiți și utilizați variabile locale
2. Lucrați cu variabile de mediu
3. Utilizați variabile speciale ($?, $$, $!, etc.)
4. Demonstrați expansiunea variabilelor

### Criterii de notare

| Criteriu | Puncte | Cerințe |
|-----------|--------|--------------|
| Variabile locale | 2.5 | Sintaxă corectă, quoting |
| Mediu | 2.5 | Manipulare PATH, HOME, USER |
| Variabile speciale | 3.0 | Utilizare $?, $$, $#, $@, $* |
| Expansiune | 2.0 | ${var:-default}, ${#var}, etc. |

### Depunctări uzuale
- `-1.0`: Variabile ne‑quoted corespunzător
- `-0.5`: Sintaxă incorectă de expansiune
- `-0.5`: Confuzie între variabile locale și de mediu

---

## S01e - Globbing pentru fișiere (10 puncte)

### Sarcini
1. Utilizați pattern‑uri `*`, `?`, `[...]`
2. Creați fișiere de test pentru potrivire pe pattern‑uri
3. Utilizați brace expansion
4. Combinați eficient pattern‑urile

### Criterii de notare

| Criteriu | Puncte | Cerințe |
|-----------|--------|--------------|
| Pattern‑uri de bază | 3.0 | Utilizare corectă a *, ?, [...] |
| Brace expansion | 2.5 | {a,b,c}, {1..10} |
| Clase de caractere | 2.5 | [a-z], [0-9], [!...] |
| Pattern‑uri complexe | 2.0 | Combinarea mai multor pattern‑uri |

### Comenzi așteptate
```bash
ls *.txt
ls file?.log
ls [abc]*
echo {1..5}
ls file{1,2,3}.txt
```

---

## S01f - Globbing avansat (10 puncte)

### Sarcini
1. Activați și utilizați extended globbing
2. Utilizați potrivirea recursivă cu `**`
3. Aplicați pattern‑uri de negație
4. Utilizați `@()`, `!()`, `*()`, `+()`, `?()`

### Criterii de notare

| Criteriu | Puncte | Cerințe |
|-----------|--------|--------------|
| Activare extglob | 2.0 | `shopt -s extglob` |
| Pattern‑uri extinse | 4.0 | @(), !(), *(), +(), ?() |
| Recursiv | 2.0 | `**` cu globstar |
| Utilizare practică | 2.0 | Rezolvarea unor probleme reale |

### Comenzi așteptate
```bash
shopt -s extglob
ls !(*.txt)           # Everything except .txt
ls *.@(jpg|png|gif)   # Image files
shopt -s globstar
ls **/*.py            # All Python files recursively
```

---

## S01g - Comenzi fundamentale (10 puncte)

### Sarcini
1. Operații pe fișiere: `cp`, `mv`, `rm`, `mkdir`, `touch`
2. Vizualizare text: `cat`, `less`, `head`, `tail`
3. Informații despre fișiere: `file`, `stat`, `du`, `df`
4. Căutare: `which`, `whereis`, `locate`, `find` (de bază)

### Criterii de notare

| Criteriu | Puncte | Cerințe |
|-----------|--------|--------------|
| Operații pe fișiere | 3.0 | Utilizare sigură, cu opțiuni |
| Vizualizare text | 2.5 | Alegerea instrumentului adecvat |
| Info fișiere | 2.5 | Extragerea informației utile |
| Căutare | 2.0 | Găsirea fișierelor și comenzilor |

### Depunctări uzuale
- `-1.0`: Utilizarea `rm` fără confirmare pe multiple fișiere
- `-0.5`: Neutilizarea `less` pentru output lung
- `-0.5`: Alegeri ineficiente de comenzi

---

## Oportunități de bonus

| Bonus | Puncte | Descriere |
|-------|--------|-------------|
| PS1 creativ | +0.5 | Prompt cu branch Git, culori |
| Alias‑uri utile | +0.5 | Dincolo de exemplele standard |
| Documentație | +0.5 | Comentarii care explică alegeri |

**Maximum total: 10.0 puncte** (bonusurile pot recupera depunctări)

---

*De Revolvix pentru disciplina OPERATING SYSTEMS | licență restricționată 2017-2030*
