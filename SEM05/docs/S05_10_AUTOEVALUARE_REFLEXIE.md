# S05_10 - Autoevaluare și Reflexie

> **Sisteme de Operare** | ASE București - CSIE  
> Seminar 9-10: Advanced Bash Scripting
> Versiune: 2.0.0 | Data: 2025-01

---

## Instrucțiuni

Această fișă de autoevaluare te ajută să:
1. **Identifici** ce ai învățat
2. **Recunoști** ce trebuie să exersezi mai mult
3. **Planifici** pașii următori

**Timp:** 3-5 minute la finalul seminarului
**Format:** Individual, apoi (opțional) discuție în perechi

---

## Partea 1: Checklist Competențe

Evaluează-te onest pe o scară de 1-5:
```
1 = Nu înțeleg deloc
2 = Am auzit, dar nu pot aplica
3 = Pot aplica cu ajutor/documentație
4 = Pot aplica independent
5 = Pot explica altcuiva
```

### Funcții

| Competență | 1 | 2 | 3 | 4 | 5 |
|------------|---|---|---|---|---|
| Definesc și apelez funcții | ○ | ○ | ○ | ○ | ○ |
| Folosesc `local` pentru variabile | ○ | ○ | ○ | ○ | ○ |
| Înțeleg diferența return vs echo | ○ | ○ | ○ | ○ | ○ |
| Pasez și accesez argumente ($1, $@) | ○ | ○ | ○ | ○ | ○ |

### Arrays

| Competență | 1 | 2 | 3 | 4 | 5 |
|------------|---|---|---|---|---|
| Creez și accesez arrays indexate | ○ | ○ | ○ | ○ | ○ |
| Iterez corect cu `"${arr[@]}"` | ○ | ○ | ○ | ○ | ○ |
| Folosesc `declare -A` pentru asociative | ○ | ○ | ○ | ○ | ○ |
| Lucrez cu cheile (`${!arr[@]}`) | ○ | ○ | ○ | ○ | ○ |

### Stabilitate

| Competență | 1 | 2 | 3 | 4 | 5 |
|------------|---|---|---|---|---|
| Aplic `set -euo pipefail` | ○ | ○ | ○ | ○ | ○ |
| Știu când `-e` NU funcționează | ○ | ○ | ○ | ○ | ○ |
| Folosesc valori default `${VAR:-...}` | ○ | ○ | ○ | ○ | ○ |
| Implementez `die()` pentru erori | ○ | ○ | ○ | ○ | ○ |

### Trap și Cleanup

| Competență | 1 | 2 | 3 | 4 | 5 |
|------------|---|---|---|---|---|
| Implementez cleanup cu `trap EXIT` | ○ | ○ | ○ | ○ | ○ |
| Gestionez fișiere temporare sigur | ○ | ○ | ○ | ○ | ○ |
| Înțeleg diferite semnale (INT, ERR) | ○ | ○ | ○ | ○ | ○ |

---

## Partea 2: Întrebări de Reflexie

### Ce a fost nou pentru tine?

_____________________________________________

_____________________________________________

_____________________________________________

### Ce te-a surprins cel mai mult?

_____________________________________________

_____________________________________________

### Ce ai găsit cel mai dificil?

_____________________________________________

_____________________________________________

### Ce vrei să exersezi mai mult?

_____________________________________________

_____________________________________________

---

## Partea 3: Verificare Rapidă (3 minute)

Răspunde fără să te uiți în notițe:

**1. Care e diferența între `return` și `echo` în funcții?**

_____________________________________________

**2. De ce e nevoie de `declare -A` pentru arrays asociative?**

_____________________________________________

**3. Numește 2 situații unde `set -e` NU oprește scriptul:**

1. _____________________________________________

2. _____________________________________________

**4. Scrie pattern-ul pentru cleanup cu trap:**

```bash

```

**5. Cum iterezi corect printr-un array cu elemente ce conțin spații?**

_____________________________________________

---

## Partea 4: Planul Meu de Acțiune

### Săptămâna aceasta voi:

- [ ] Reciti materialul pentru: _______________________
- [ ] Exersez scriind: _______________________
- [ ] Voi întreba pe cineva despre: _______________________

### Pentru temă/proiect voi aplica:

- [ ] `set -euo pipefail` în toate scripturile
- [ ] `local` în toate funcțiile
- [ ] `declare -A` pentru hash-uri
- [ ] Cleanup cu trap EXIT
- [ ] Ghilimele la iterare arrays

---

## Partea 5: Exit Ticket (pentru instructor)

Bifează și predă la ieșire:

**Cel mai util lucru învățat azi:**

_____________________________________________

**O întrebare pe care încă o am:**

_____________________________________________

**Feedback pentru seminar (opțional):**

_____________________________________________

---

## Răspunsuri Cheie (pentru auto-verificare acasă)

<details>
<summary>Verifică răspunsurile tale</summary>

**1. return vs echo:**
- `return` setează exit code (0-255), nu returnează valori
- `echo` scrie pe stdout, poate fi capturat cu `$()`

**2. declare -A:**
- Fără el, Bash tratează array-ul ca indexat
- Cheile text sunt evaluate ca variabile (nedefinite = 0)
- Toate asignările scriu la index 0

**3. set -e nu funcționează în:**
- Condiții if/while/until
- Comenzi cu || sau &&
- Comenzi negate cu !
- Funcții apelate în context de test

**4. Pattern cleanup:**
```bash
cleanup() {
    local exit_code=$?
    # cleanup operations
    exit $exit_code
}
trap cleanup EXIT
```

**5. Iterare corectă:**
```bash
for item in "${arr[@]}"; do
```
Cu ghilimele! Fără ghilimele, word splitting corupe elementele.

</details>

---

## Resurse pentru Continuare

### Documentație Oficială
- GNU Bash Manual: https://www.gnu.org/software/bash/manual/
- Bash Reference Card: https://ss64.com/bash/

### Practice
- ShellCheck: https://www.shellcheck.net/
- Exercism Bash Track: https://exercism.org/tracks/bash
- Advent of Code (în Bash): https://adventofcode.com/

### Style Guides
- Google Shell Style Guide: https://google.github.io/styleguide/shellguide.html
- Bash Best Practices: https://bertvv.github.io/cheat-sheets/Bash.html

---

## Note pentru Instructor

### Cum să folosești acest formular

1. **Distribuie** în ultimele 5 minute ale seminarului
2. **Acordă** 3-4 minute pentru completare individuală
3. **Colectează** Exit Tickets (Partea 5) la ieșire
4. **Analizează** pattern-urile pentru a ajusta seminarul următor

### Ce să urmărești

- Competențe cu multe scoruri 1-2 → necesită re-explicare
- Întrebări frecvente → adaugă în FAQ sau Q&A la început
- Dificultăți comune → ajustează pacing-ul

### Variante

- **Scurtă (2 min):** Doar Părțile 4-5
- **Medie (5 min):** Părțile 2, 4, 5
- **Completă (10 min):** Tot formularul
- **Online:** Google Forms cu același conținut

---

*Material de laborator pentru cursul de Sisteme de Operare | ASE București - CSIE*
