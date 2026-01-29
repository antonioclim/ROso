# Teste Automate - Seminar 1

> **Tema:** Shell Basics, Quoting, Variabile, FHS, Globbing

---

## Sumar Teste

| Test | Descriere | Status |
|------|-----------|--------|
| `test_01_shell_basics.sh` | Comenzi fundamentale (ls, cd, pwd) | 🔜 TODO |
| `test_02_quoting.sh` | Single/double quotes, escape | 🔜 TODO |
| `test_03_variabile.sh` | Variabile shell și de mediu | 🔜 TODO |
| `test_04_globbing.sh` | Wildcards (*, ?, [], {}) | 🔜 TODO |
| `run_all_tests.sh` | Runner pentru toate testele | 🔜 TODO |

---

## Utilizare

```bash
# Rulare toate testele
./run_all_tests.sh

# Rulare test individual
./test_01_shell_basics.sh

# Verificare sintaxă
bash -n test_*.sh
```

---

## Template Test

```bash
#!/bin/bash
# test_XX_descriere.sh
set -euo pipefail

pass() { echo "✅ PASS: $1"; ((PASSED++)); }
fail() { echo "❌ FAIL: $1"; ((FAILED++)); }

PASSED=0 FAILED=0

test_exemplu() {
    local result
    result=$(echo "test")
    [[ "$result" == "test" ]] && pass "Echo funcționează" || fail "Echo eșuat"
}

test_exemplu
echo "═══ Rezultat: $PASSED passed, $FAILED failed ═══"
```

---

## Competențe Testate (Bloom)

| Nivel | Competență | Acoperită |
|-------|------------|-----------|
| 1-Cunoaștere | Comenzi de bază | ⬜ |
| 2-Înțelegere | Diferența quotes | ⬜ |
| 3-Aplicare | Navigare FHS | ⬜ |
| 4-Analiză | Debugging variabile | ⬜ |

---

## Referințe

- `../docs/S01_02_MATERIAL_PRINCIPAL.md`
- `../docs/S01_06_EXERCITII_SPRINT.md`
- `../scripts/demo/`
