# Teste automate — Seminarul 5

> **Subiect:** funcții, arrays, scripting robust, gestionarea erorilor

---

## Rezumat teste

| Test | Descriere | Status |
|------|-----------|--------|
| `test_01_functions.sh` | Funcții cu `local` și „return” prin echo | 🔜 TODO |
| `test_02_arrays_indexed.sh` | Arrays indexate | 🔜 TODO |
| `test_03_arrays_assoc.sh` | Arrays asociative (`declare -A`) | 🔜 TODO |
| `test_04_error_handling.sh` | `set -euo pipefail`, `trap` | 🔜 TODO |
| `test_05_debugging.sh` | `set -x`, `PS4`, tehnici de depanare | 🔜 TODO |
| `run_all_tests.sh` | Runner pentru toate testele | 🔜 TODO |

---

## Utilizare

```bash
# Rulează toate testele
./run_all_tests.sh

# Rulează un test individual
./test_01_functions.sh

# Verificare cu shellcheck (OBLIGATORIU!)
shellcheck test_*.sh
```

---

## Exemple de teste

### Funcții cu `local`
```bash
test_local_scope() {
    outer_var="outer"

    test_func() {
        local outer_var="inner"
        echo "$outer_var"
    }

    local result
    result=$(test_func)

    [[ "$result" == "inner" && "$outer_var" == "outer" ]]         && pass "local scope" || fail "local scope"
}
```

### Arrays asociative
```bash
test_associative_array() {
    declare -A config
    config[host]="localhost"
    config[port]="8080"

    [[ "${config[port]}" == "8080" ]]         && pass "associative array" || fail "associative array"
}
```

### Gestionarea erorilor
```bash
test_set_e_behavior() {
    # Scriptul cu set -e ar trebui să se oprească la prima eroare
    local output
    output=$(bash -c 'set -e; false; echo "should not print"' 2>&1) || true

    [[ -z "$output" ]]         && pass "set -e stops on error" || fail "set -e"
}

test_trap_exit() {
    local cleanup_file="/tmp/cleanup_test_$$"

    bash -c "
        trap 'touch $cleanup_file' EXIT
        exit 0
    "

    [[ -f "$cleanup_file" ]]         && pass "trap EXIT executed" || fail "trap EXIT"
    rm -f "$cleanup_file"
}
```

---

## Competențe testate (Bloom)

| Nivel | Competență | Acoperit |
|------|------------|----------|
| 1-Cunoaștere | Sintaxă funcții/arrays | ⬜ |
| 2-Înțelegere | Scope variabile | ⬜ |
| 3-Aplicare | Tipare de gestionare a erorilor | ⬜ |
| 4-Analiză | Depanare de scripturi | ⬜ |
| 5-Sinteză | Șablon profesional | ⬜ |

---

## Verificări obligatorii înainte de predare

```bash
# Shellcheck trebuie să treacă fără erori!
shellcheck -x test_*.sh

# Toate testele trebuie să ruleze
./run_all_tests.sh
```

---

## Referințe

În mod specific: `../docs/S05_02_MAIN_MATERIAL.md`, `../scripts/templates/professional_script.sh` și `../homework/S05_01_HOMEWORK.md`.
