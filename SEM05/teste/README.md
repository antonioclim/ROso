# Teste Automate - Seminar 05

> **Tema:** Funcții, Arrays, Scripting solid, Error Handling

---

## Sumar Teste

| Test | Descriere | Status |
|------|-----------|--------|
| `test_01_functions.sh` | Funcții cu local și return | 🔜 TODO |
| `test_02_arrays_indexed.sh` | Arrays indexate | 🔜 TODO |
| `test_03_arrays_assoc.sh` | Arrays asociative (declare -A) | 🔜 TODO |
| `test_04_error_handling.sh` | set -euo pipefail, trap | 🔜 TODO |
| `test_05_debugging.sh` | set -x, PS4, debugging | 🔜 TODO |
| `run_all_tests.sh` | Runner pentru toate testele | 🔜 TODO |

---

## Utilizare

```bash
# Rulare toate testele
./run_all_tests.sh

# Rulare test individual
./test_01_functions.sh

# Verificare cu shellcheck (OBLIGATORIU!)
shellcheck test_*.sh
```

---

## Exemple de Teste

### Funcții cu local
```bash
test_local_scope() {
    outer_var="outer"
    
    test_func() {
        local outer_var="inner"
        echo "$outer_var"
    }
    
    local result
    result=$(test_func)
    
    [[ "$result" == "inner" && "$outer_var" == "outer" ]] \
        && pass "local scope" || fail "local scope"
}
```

### Arrays Asociative
```bash
test_associative_array() {
    declare -A config
    config[host]="localhost"
    config[port]="8080"
    
    [[ "${config[port]}" == "8080" ]] \
        && pass "associative array" || fail "associative array"
}
```

### Error Handling
```bash
test_set_e_behavior() {
    # Script cu set -e ar trebui să se oprească la prima eroare
    local output
    output=$(bash -c 'set -e; false; echo "should not print"' 2>&1) || true
    
    [[ -z "$output" ]] \
        && pass "set -e stops on error" || fail "set -e"
}

test_trap_exit() {
    local cleanup_file="/tmp/cleanup_test_$$"
    
    bash -c "
        trap 'touch $cleanup_file' EXIT
        exit 0
    "
    
    [[ -f "$cleanup_file" ]] \
        && pass "trap EXIT executed" || fail "trap EXIT"
    rm -f "$cleanup_file"
}
```

---

## Competențe Testate (Bloom)

| Nivel | Competență | Acoperită |
|-------|------------|-----------|
| 1-Cunoaștere | Sintaxă funcții/arrays | ⬜ |
| 2-Înțelegere | Scope variabile | ⬜ |
| 3-Aplicare | Error handling patterns | ⬜ |
| 4-Analiză | Debugging scripturi | ⬜ |
| 5-Sinteză | Template profesional | ⬜ |

---

## Verificări Obligatorii Pre-Predare

```bash
# Shellcheck trebuie să treacă fără erori!
shellcheck -x test_*.sh

# Toate testele trebuie să ruleze
./run_all_tests.sh
```

---

## Referințe


Concret: `../docs/S05_02_MATERIAL_PRINCIPAL.md`. `../scripts/templates/professional_script.sh`. Și `../teme/S05_01_TEMA.md`. Direct.

