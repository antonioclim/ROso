# Teste Automate — Seminarul 03

> **Tema:** find/xargs, getopts, Permisiuni Unix, CRON  
> **Curs:** Sisteme de Operare | ASE București - CSIE

---


## Sumar Teste

| Categorie | Descriere | Status |
|-----------|-----------|--------|
| Structură fișiere | Verifică prezența fișierelor obligatorii | ✅ Implementat |
| Sintaxă Bash | Validează sintaxa scripturilor .sh | ✅ Implementat |
| Sintaxă Python | Validează sintaxa scripturilor .py | ✅ Implementat |
| Date YAML/JSON | Verifică quiz.yaml și quiz_lms.json | ✅ Implementat |
| Consistență naming | Verifică absența referințelor greșite | ✅ Implementat |
| Calitate cod | Verifică shebang, strict mode | ✅ Implementat |
| Patterns AI | Detectează cuvinte-semnal AI | ✅ Implementat |

---


## Utilizare

```bash

# Rulare toate testele
bash tests/run_all_tests.sh


# Sau din directorul rădăcină cu Make
make test


# Verificare rapidă sintaxă
make lint
```

---


## Structura Testelor

```
tests/
├── README.md              # Acest fișier
└── run_all_tests.sh       # Runner principal pentru toate testele
```


### Categorii de teste în run_all_tests.sh:

1. **test_structure()** — Verifică existența fișierelor și directoarelor obligatorii
2. **test_bash_syntax()** — Rulează `bash -n` pe toate scripturile .sh
3. **test_python_syntax()** — Rulează `python -m py_compile` pe toate .py
4. **test_data_files()** — Validează YAML și JSON pentru quiz-uri
5. **test_naming_consistency()** — Detectează referințe greșite (ex: "Seminar 3")
6. **test_code_quality()** — Verifică best practices (shebang, strict mode)
7. **test_ai_patterns()** — Contorizează cuvinte-semnal AI

---


## Output Exemplu

```
═══════════════════════════════════════════════════════════════
        TESTE SEMINAR 03: System Administration
═══════════════════════════════════════════════════════════════

─── Structură Fișiere ───
  README.md exists                                [PASS]
  Makefile exists                                 [PASS]
  formative/quiz.yaml exists                      [PASS]
  ...

─── Sintaxă Bash ───
  Syntax: S03_01_setup_seminar.sh                 [PASS]
  Syntax: S03_02_quiz_interactiv.sh               [PASS]
  ...

═══════════════════════════════════════════════════════════════
                         SUMAR
═══════════════════════════════════════════════════════════════
  ✓ Passed:  25
  ✗ Failed:  0
  ○ Skipped: 2

  Score: 100% (25/25)
═══════════════════════════════════════════════════════════════
```

---


## Adăugare Teste Noi

Pentru a adăuga teste noi, editează `run_all_tests.sh` și adaugă funcții:

```bash
test_my_category() {
    print_section "Categoria Mea"
    
    run_test "Nume test" "comanda_de_test"
    run_test "Alt test" "[[ -f 'fisier.txt' ]]"
}
```

Apoi apelează funcția în `main()`:

```bash
main() {
    ...
    test_my_category
    ...
}
```

---


## Integrare CI/CD

Testele sunt integrate în GitHub Actions (vezi `ci/github_actions.yml`).

Pipeline-ul rulează automat la fiecare push și include:
1. Linting (shellcheck + ruff)
2. Validare structură
3. Rulare teste
4. Verificare patterns AI

---

*Seminarul 03 | Sisteme de Operare | ASE București - CSIE*

