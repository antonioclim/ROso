# Soluții Teme - Seminar 1

## Exerciții și Punctaje

| Exercițiu | Punctaj | Concepte Verificate |
|-----------|---------|---------------------|
| Ex1: Structură directoare | 2p | mkdir -p, brace expansion |
| Ex2: Script navigare | 2p | cd, pwd, variabile |
| Ex3: Variabile mediu | 2p | export, .bashrc |
| Ex4: Pattern matching | 2p | globbing, find |
| Ex5: Script backup | 2p | cp, timestamp, condiții |

## Instrucțiuni Verificare

### Verificare Manuală

```bash
# Rulează scriptul
chmod +x solutie.sh
./solutie.sh

# Verifică output-ul
echo $?  # Trebuie să fie 0
```

### Verificare cu Autograder

```bash
# Din directorul temei
make test
```

## Note Evaluare

- **Punctare parțială:** Acordăm puncte parțiale pentru soluții incomplete dar funcționale
- **Comentarii:** Bonus 0.5p pentru scripturi bine comentate
- **Stil:** Folosirea `set -euo pipefail` și ghilimele la variabile este apreciată
- **Originalitate:** Soluții creative sunt încurajate

## Probleme Frecvente la Studenți

| Problemă | Frecvență | Soluție |
|----------|-----------|---------|
| Spații la `=` | 70% | `VAR="val"` nu `VAR = "val"` |
| Lipsă ghilimele | 60% | Folosește `"$VAR"` mereu |
| Cale relativă vs absolută | 55% | Începe cu `/` pentru absolut |
| `exit` în funcții | 40% | Folosește `return` în funcții |
| Backticks | 35% | Preferă `$(comandă)` |

## Fișiere Soluție

- `S01_ex1_structura.sh` — Creare structură directoare cu README
