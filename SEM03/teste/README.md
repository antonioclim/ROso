# Teste Automate - Seminar 03

> **Tema:** find/xargs, Permisiuni Unix, getopts, CRON

---

## Sumar Teste

| Test | Descriere | Status |
|------|-----------|--------|
| `test_01_find.sh` | Căutare fișiere cu find | 🔜 TODO |
| `test_02_xargs.sh` | Procesare în lot cu xargs | 🔜 TODO |
| `test_03_permisiuni.sh` | chmod, SUID/SGID, sticky | 🔜 TODO |
| `test_04_getopts.sh` | Parsare argumente script | 🔜 TODO |
| `test_05_cron.sh` | Validare sintaxă crontab | 🔜 TODO |
| `run_all_tests.sh` | Runner pentru toate testele | 🔜 TODO |

---

## Utilizare

```bash
# Rulare toate testele
./run_all_tests.sh

# Rulare test individual
./test_01_find.sh

# Verificare sintaxă
bash -n test_*.sh
```

---

## Exemple de Teste

### find cu criterii multiple
```bash
test_find_by_name() {
    mkdir -p /tmp/test_find
    touch /tmp/test_find/{a,b,c}.txt /tmp/test_find/{x,y}.log
    local count
    count=$(find /tmp/test_find -name "*.txt" | wc -l)
    [[ "$count" -eq 3 ]] && pass "find -name" || fail "find -name (expected 3, got $count)"
    rm -rf /tmp/test_find
}

test_find_by_type_and_size() {
    # Găsește fișiere mai mari de 1M
    find /tmp -type f -size +1M 2>/dev/null | head -1
    pass "find -type -size"
}
```

### xargs sigur
```bash
test_xargs_with_null() {
    mkdir -p /tmp/test_xargs
    touch /tmp/test_xargs/"file with spaces.txt"
    local count
    count=$(find /tmp/test_xargs -print0 | xargs -0 ls 2>/dev/null | wc -l)
    [[ "$count" -ge 1 ]] && pass "xargs -0" || fail "xargs -0"
    rm -rf /tmp/test_xargs
}
```

### Permisiuni
```bash
test_chmod_numeric() {
    touch /tmp/test_perm.txt
    chmod 755 /tmp/test_perm.txt
    local perms
    perms=$(stat -c "%a" /tmp/test_perm.txt)
    [[ "$perms" == "755" ]] && pass "chmod numeric" || fail "chmod numeric"
    rm -f /tmp/test_perm.txt
}
```

---

## Competențe Testate (Bloom)

| Nivel | Competență | Acoperită |
|-------|------------|-----------|
| 1-Cunoaștere | Sintaxă find/xargs | ⬜ |
| 2-Înțelegere | Model permisiuni Unix | ⬜ |
| 3-Aplicare | Scripting cu getopts | ⬜ |
| 4-Analiză | Debugging permisiuni | ⬜ |
| 5-Sinteză | Automatizare CRON | ⬜ |

---

## Referințe

- `../docs/S03_02_MATERIAL_PRINCIPAL.md`
- `../docs/S03_06_EXERCITII_SPRINT.md`
- `../scripts/demo/`
