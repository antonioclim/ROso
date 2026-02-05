# Teste Automate — Seminarul 04
## Text Processing: Regex, GREP, SED, AWK

> Sisteme de Operare | ASE București - CSIE  
> Documentație pentru suita de teste automate  
> Versiune: 1.0 | Ianuarie 2025

---

## Prezentare Generală

Acest director conține teste automate pentru verificarea cunoștințelor și funcționalității scripturilor din Seminarul 04.

## Structura Testelor

```
teste/
├── README.md                    # Acest fișier
├── run_all_tests.sh            # Runner principal pentru toate testele
├── test_01_regex_basics.sh     # Teste pentru expresii regulate
├── test_02_grep_mastery.sh     # Teste pentru comanda grep
├── test_03_sed_transforms.sh   # Teste pentru comanda sed
└── test_04_awk_analysis.sh     # Teste pentru comanda awk
```

---

## Rulare Teste

### Rulare completă (toate testele)
```bash
# Din directorul SEM04/
bash teste/run_all_tests.sh

# Sau cu Make
make test
```

### Rulare teste individuale
```bash
# Doar regex
bash teste/test_01_regex_basics.sh

# Doar grep
bash teste/test_02_grep_mastery.sh

# Doar sed
bash teste/test_03_sed_transforms.sh

# Doar awk
bash teste/test_04_awk_analysis.sh
```

### Cu Make (recomandat)
```bash
make test-regex
make test-grep
make test-sed
make test-awk
```

---

## Acoperire per Fișier de Test

### test_01_regex_basics.sh
| Test | Descriere | LO |
|------|-----------|-----|
| T1.1 | Metacaractere de bază (. ^ $ *) | LO1 |
| T1.2 | Character classes [abc] [^abc] | LO1 |
| T1.3 | Quantificatori (+ ? {n,m}) | LO1 |
| T1.4 | Diferențe BRE vs ERE | LO1 |
| T1.5 | Escape caractere speciale | LO1 |
| T1.6 | Anchors și word boundaries | LO1 |

### test_02_grep_mastery.sh
| Test | Descriere | LO |
|------|-----------|-----|
| T2.1 | grep -i (case insensitive) | LO2 |
| T2.2 | grep -v (invert match) | LO2 |
| T2.3 | grep -c (count) | LO2 |
| T2.4 | grep -o (only matching) | LO2 |
| T2.5 | grep -E (extended regex) | LO2 |
| T2.6 | grep -r (recursive) | LO2 |
| T2.7 | grep cu multiple patterns | LO2, LO5 |

### test_03_sed_transforms.sh
| Test | Descriere | LO |
|------|-----------|-----|
| T3.1 | sed s/// (substituție simplă) | LO3 |
| T3.2 | sed s///g (global) | LO3 |
| T3.3 | sed d (delete) | LO3 |
| T3.4 | sed p (print) | LO3 |
| T3.5 | sed cu adresare (linii, range) | LO3 |
| T3.6 | sed -i (in-place edit) | LO3 |
| T3.7 | sed cu back-references | LO3 |

### test_04_awk_analysis.sh
| Test | Descriere | LO |
|------|-----------|-----|
| T4.1 | awk print $1 $2 (câmpuri) | LO4 |
| T4.2 | awk -F (field separator) | LO4 |
| T4.3 | awk NR NF (număr linie/câmpuri) | LO4 |
| T4.4 | awk BEGIN END | LO4 |
| T4.5 | awk calcule (sum, avg) | LO4 |
| T4.6 | awk pattern matching | LO4 |
| T4.7 | awk arrays asociative | LO4 |

---

## Format Output

Testele folosesc un format standardizat pentru output:

```
═══════════════════════════════════════════════════════════════════════════════
  TEST SUITE: [Nume categorie]
═══════════════════════════════════════════════════════════════════════════════

[T1.1] Descriere test scurtă
  ✓ PASSED                                                          [0.01s]

[T1.2] Alt test
  ✗ FAILED: Expected "abc", got "xyz"                               [0.02s]

───────────────────────────────────────────────────────────────────────────────
  REZULTATE: 5/6 passed (83%)
───────────────────────────────────────────────────────────────────────────────
```

---

## Dependențe

Testele necesită:
- Bash 4.0+
- Comenzile standard: grep, sed, awk, cat, echo
- Fișierele de test din `resurse/sample_data/`

### Verificare dependențe
```bash
# Verifică versiunile
bash --version
grep --version
sed --version
awk --version
```

---

## Adăugare Teste Noi

Pentru a adăuga un test nou:

1. Editează fișierul de test corespunzător
2. Folosește funcția helper `run_test`:

```bash
run_test "T1.X" "Descriere test" \
    "comanda_de_testat" \
    "output_asteptat"
```

3. Sau pentru teste complexe:

```bash
test_complex() {
    local result
    result=$(comanda_complexa)
    
    if [[ "$result" == "așteptat" ]]; then
        echo "  ✓ PASSED"
        return 0
    else
        echo "  ✗ FAILED: Got '$result'"
        return 1
    fi
}
```

---

## Integrare CI

Testele sunt rulate automat în GitHub Actions la fiecare push.

Fișier: `ci/github_actions.yml`

Job relevant: `run-tests`

---

## Troubleshooting

### Testele eșuează cu "command not found"
```bash
# Verifică PATH
echo $PATH

# Verifică dacă comanda există
which grep sed awk
```

### Testele eșuează cu "Permission denied"
```bash
# Fă scripturile executabile
chmod +x teste/*.sh
```

### Diferențe de newline (Windows vs Linux)
```bash
# Convertește la format Unix
dos2unix teste/*.sh
```

### Sample data lipsește
```bash
# Rulează setup-ul
bash scripts/bash/S04_01_setup_seminar.sh
```

---

## Contact

Pentru probleme cu testele: Deschide un issue în repository-ul GitHub

---

*Documentație teste — Seminarul 04: Text Processing*
