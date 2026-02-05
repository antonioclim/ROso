# 📁 Șabloane de proiect – schelet de pornire

> **Locație:** `04_PROJECTS/templates/`  
> **Scop:** generarea unei structuri standardizate pentru proiectele studenților  
> **Public țintă:** studenți care inițiază proiecte noi

## Conținut

| Fișier | Scop |
|--------|------|
| `project_structure.sh` | Generează scheletul complet al proiectului |
| `README_template.md` | Șablon pentru documentația proiectului |
| `Makefile_template` | Makefile standard cu target-urile obligatorii |

## Pornire rapidă

```bash
# Marchează scriptul ca executabil
chmod +x project_structure.sh

# Creează un proiect nou din șablon
./project_structure.sh my_backup_project --type backup

# Listează tipurile disponibile
./project_structure.sh --list-types
```

---

## project_structure.sh

**Scop:** generează un director de proiect complet, conform standardelor, incluzând fișierele obligatorii.

### Utilizare

```bash
./project_structure.sh <nume_proiect> [opțiuni]

Argumente:
  nume_proiect      Numele directorului de proiect

Opțiuni:
  --type TYPE       Tip de șablon (vezi --list-types)
  --output DIR      Director părinte (implicit: curent)
  --author NAME     Numele autorului pentru documentație
  --list-types      Afișează tipurile disponibile
  --force           Suprascrie directorul existent
```

### Tipuri de proiect disponibile

```bash
$ ./project_structure.sh --list-types

Tipuri disponibile:
  monitor    - Proiect de monitorizare sistem/procese
  backup     - Proiect de automatizare backup
  deployer   - Proiect de automatizare deployment
  analyzer   - Proiect de analiză log/date
  scheduler  - Proiect de planificare sarcini
  custom     - Șablon minimal (construiește pe cont propriu)
```

### Structura generată

```
my_project/
├── README.md              # Șablon de documentație precompletat
├── Makefile               # Target-uri standard: all, test, clean, install
├── .gitignore             # Pattern-uri uzuale de excludere
├── src/
│   ├── main.sh            # Punct de intrare, cu parsare argumente
│   └── lib/
│       ├── config.sh      # Gestionare configurație
│       ├── utils.sh       # Funcții utilitare
│       └── logging.sh     # Funcții suport logging
├── tests/
│   ├── test_main.sh       # Schelet test
│   └── test_helpers.sh    # Utilitare de test
├── docs/
│   ├── DESIGN.md          # Șablon document de design
│   └── CHANGELOG.md       # Șablon istoric versiuni
└── examples/
    └── example_config.conf # Configurație exemplu
```

### Exemplu de utilizare

```bash
# Creează un proiect de backup
./project_structure.sh my_backup_system --type backup --author "John Doe"

# Creează într-un director specific
./project_structure.sh scheduler_v2 --type scheduler --output ~/projects/

# Proiect minimal (custom)
./project_structure.sh experiment --type custom
```

### Output

```
═══════════════════════════════════════════════════════════════
 GENERATOR PROIECT v2.0
═══════════════════════════════════════════════════════════════

Se creează proiectul: my_backup_system
Tip: backup
Locație: /home/student/my_backup_system/

[1/8] Creare structură directoare ··········· Gata
[2/8] Generare README.md ···················· Gata
[3/8] Generare Makefile ····················· Gata
[4/8] Creare main.sh ························ Gata
[5/8] Creare fișiere librărie ··············· Gata (3 fișiere)
[6/8] Creare schelete teste ················· Gata (2 fișiere)
[7/8] Creare documentație ··················· Gata
[8/8] Setare permisiuni ····················· Gata

═══════════════════════════════════════════════════════════════
 SUCCES: Proiect creat în /home/student/my_backup_system/
═══════════════════════════════════════════════════════════════

Pași următori:
  1. cd my_backup_system
  2. Editează README.md cu detaliile proiectului
  3. Implementează src/main.sh
  4. Rulează: make test
```

---

## Fișiere șablon

### README_template.md

Documentație precompletată, incluzând:
- Titlu proiect și placeholder-e pentru descriere
- Instrucțiuni de instalare
- Exemple de utilizare cu comenzi placeholder
- Secțiune de configurare
- Instrucțiuni de testare
- Checklist de criterii de evaluare

### Makefile_template

Makefile standard cu target-urile obligatorii:

```makefile
# Target-uri obligatorii (nu redenumi)
all:        # Build/pregătire proiect
test:       # Rulare teste
clean:      # Curățare artefacte build
install:    # Instalare în sistem (opțional)

# Target-uri opționale
lint:       # Rulare shellcheck
docs:       # Generare documentație
package:    # Creare arhivă de predare
```

---

## Sugestii de personalizare

### După generare

1. **Editează README.md prima dată** – completează descrierea și cerințele
2. **Revizuiește main.sh** – înțelege template-ul de parsare a argumentelor
3. **Verifică Makefile** – asigură-te că target-urile corespund procesului tău
4. **Actualizează .gitignore** – adaugă pattern-uri specifice proiectului

### Modificarea șabloanelor

Dacă ai nevoie să adaptezi șabloanele pentru fluxul tău:

```bash
# Copiere șablon pentru modificare
cp README_template.md my_README_template.md

# Folosire șablon personalizat
./project_structure.sh my_project --readme-template my_README_template.md
```

---

## Integrare cu scripturile auxiliare

După ce creezi proiectul, folosește scripturile din `helpers/`:

```bash
# Validare structură
../helpers/project_validator.sh my_project/

# Rulare teste
../helpers/test_runner.sh my_project/

# Împachetare pentru predare
../helpers/submission_packager.sh my_project/ --student-id ABC123
```

---

*Vezi și: [`../helpers/RUNhere.md`](../helpers/RUNhere.md) pentru instrumente de validare*  
*Vezi și: [`../README.md`](../README.md) pentru specificațiile proiectelor*

*Ultima actualizare: ianuarie 2026*
