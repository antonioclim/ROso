# Soluții Exerciții — Seminar 5

> **ATENȚIE**: Acest director conține soluțiile exercițiilor.  
> Este destinat EXCLUSIV instructorilor.  
> NU distribui studenților înainte de deadline!

---

## Conținut

| Fișier | Exercițiu | Concepte Acoperite |
|--------|-----------|-------------------|
| `S05_ex01_functii_sol.sh` | Funcții cu variabile locale | `local`, returnare prin `echo`, validare |
| `S05_ex02_arrays_sol.sh` | Manipulare arrays | indexate, asociative, iterare, slice |
| `S05_ex03_robust_sol.sh` | Scripting defensiv | `set -euo pipefail`, `trap`, cleanup |

---

## Utilizare

Toate soluțiile sunt executabile:

```bash
# Fă executabile
chmod +x *.sh

# Rulează individual
./S05_ex01_functii_sol.sh
./S05_ex02_arrays_sol.sh
./S05_ex03_robust_sol.sh

# Soluția 3 poate simula o eroare pentru a demonstra cleanup
./S05_ex03_robust_sol.sh --simulate-error
```

---

## Puncte de Discuție cu Studenții

### Exercițiul 1 (Funcții)

1. De ce `return 42` nu funcționează ca în Python?
2. Când folosim `local` și când nu?
3. Cum testăm dacă o funcție returnează corect?

### Exercițiul 2 (Arrays)

1. Ce se întâmplă dacă uităm `declare -A`?
2. De ce ghilimelele sunt esențiale la iterare?
3. Ce e un "sparse array" și când apare?

### Exercițiul 3 (Scripting Defensiv)

1. În ce situații `set -e` NU oprește scriptul?
2. De ce `trap cleanup EXIT` și nu doar la eroare?
3. Cum testăm că cleanup-ul funcționează?

---

## Verificare cu ShellCheck

```bash
shellcheck *.sh
```

Toate soluțiile ar trebui să treacă fără warnings.

---

*Director generat pentru instructori — Seminar 5*
