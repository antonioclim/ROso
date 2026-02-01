# 📁 Scripturi Globale — Infrastructură Kit

> **Locație:** `/scripts/`  
> **Scop:** Automatizări la nivel de kit pentru asigurarea calității și întreținere

## Cuprins

| Script | Scop | Context utilizare |
|--------|------|-------------------|
| `add_print_styles.sh` | Injectare CSS pentru imprimare în prezentări HTML | Proces build |
| `check_links.sh` | Validator comprehensiv linkuri documentație | CI/CD, pre-lansare |
| `verify_links.sh` | Verificator linkuri alternativ (minimalist) | Verificări locale rapide |

## Pornire rapidă

```bash
# Acordă permisiuni de execuție scripturilor (o singură dată)
chmod +x *.sh

# Verifică toate linkurile din documentație
./check_links.sh

# Adaugă stiluri de imprimare la toate fișierele HTML
./add_print_styles.sh ../05_LECTURES/
```

## Utilizare detaliată

### add_print_styles.sh

Injectează reguli CSS `@media print` în prezentările HTML pentru imprimare curată offline.

```bash
# Procesează un singur director
./add_print_styles.sh ../SEM01/presentations/

# Procesează întregul kit
./add_print_styles.sh ../

# Rulare de test (previzualizare modificări)
./add_print_styles.sh --dry-run ../05_LECTURES/
```

**Efecte:**
- Adaugă reguli de întrerupere pagină înaintea elementelor `<h1>`
- Ascunde elementele de navigare la imprimare
- Optimizează dimensiunile fonturilor pentru hârtie
- Păstrează stilurile existente

### check_links.sh

Validează toate linkurile interne și externe din documentația Markdown și HTML.

```bash
# Verificare completă (interne + externe)
./check_links.sh

# Doar linkuri interne (mai rapid)
./check_links.sh --internal-only

# Director specific
./check_links.sh ../SEM03/docs/

# Generare raport
./check_links.sh --report links_report.txt
```

**Coduri de ieșire:**
- `[OK]` — Link valid
- `[WARN]` — Timeout link extern (poate funcționa totuși)
- `[FAIL]` — Link defect

### verify_links.sh

Alternativă minimalistă pentru verificare locală rapidă.

```bash
# Verificare rapidă
./verify_links.sh ../README.md

# Mod detaliat
./verify_links.sh -v ../05_LECTURES/
```

## Integrare cu CI

Aceste scripturi sunt apelate de fluxurile GitHub Actions. Vezi fișierele individuale `SEM*/ci/github_actions.yml` pentru exemple de integrare.

```yaml
# Exemplu pas CI
- name: Verificare linkuri documentație
  run: ./scripts/check_links.sh --internal-only
```

## Dependențe

- `bash` ≥ 4.0
- `curl` (pentru verificări linkuri externe)
- `grep`, `sed`, `awk` (instrumente Unix standard)

## Depanare

| Problemă | Soluție |
|----------|---------|
| „Permission denied" | Rulează `chmod +x *.sh` |
| Timeout linkuri externe | Folosește flag-ul `--internal-only` |
| Fals pozitive la ancore | Verifică dacă fișierul țintă are atributul `id` corespunzător |

---

*Întreținere: Echipa infrastructură kit*  
*Ultima actualizare: Ianuarie 2026*
