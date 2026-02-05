# Teste Automate - Seminar 2

> **Tema:** Operatori de Control, Redirecționare I/O, Pipes, Bucle

---

## Sumar Teste

| Test | Descriere | Status |
|------|-----------|--------|
| `test_01_operatori.sh` | Operatori (&&, \|\|, ;, &) | 🔜 TODO |
| `test_02_redirectare.sh` | stdin/stdout/stderr, >, >>, < | 🔜 TODO |
| `test_03_pipes.sh` | Pipeline-uri și filtre | 🔜 TODO |
| `test_04_bucle.sh` | for, while, until, select | 🔜 TODO |
| `run_all_tests.sh` | Runner pentru toate testele | 🔜 TODO |

---

## Utilizare

```bash
# Rulare toate testele
./run_all_tests.sh

# Rulare test individual
./test_01_operatori.sh

# Verificare sintaxă
bash -n test_*.sh
```

---

## Exemple de Teste

### Operatori de Control
```bash
test_and_operator() {
    local result
    result=$(true && echo "yes" || echo "no")
    [[ "$result" == "yes" ]] && pass "AND operator" || fail "AND operator"
}

test_or_operator() {
    local result
    result=$(false || echo "fallback")
    [[ "$result" == "fallback" ]] && pass "OR operator" || fail "OR operator"
}
```

### Redirecționare
```bash
test_stdout_redirect() {
    echo "test" > /tmp/test_out.txt
    [[ "$(cat /tmp/test_out.txt)" == "test" ]] && pass "stdout >" || fail "stdout >"
    rm -f /tmp/test_out.txt
}

test_stderr_redirect() {
    ls /nonexistent 2>/dev/null
    [[ $? -ne 0 ]] && pass "stderr 2>" || fail "stderr 2>"
}
```

---

## Competențe Testate (Bloom)

| Nivel | Competență | Acoperită |
|-------|------------|-----------|
| 1-Cunoaștere | Sintaxă operatori | ⬜ |
| 2-Înțelegere | Ordinea execuției | ⬜ |
| 3-Aplicare | Construire pipelines | ⬜ |
| 4-Analiză | Debugging redirectări | ⬜ |

---

## Referințe

- `../docs/S02_02_MAIN_MATERIAL.md`
- `../docs/S02_06_SPRINT_EXERCISES.md`
- `../scripts/demo/`
