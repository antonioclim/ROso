# E03: Organizator Fișiere în Masă

> **Nivel:** EASY | **Timp estimat:** 15-20 ore | **Componente:** Doar Bash

---

## Descriere

Dezvoltă un instrument pentru organizarea automată a fișierelor în directoare structurate. Suportă organizare după tip, dată, mărime sau pattern-uri custom.

---

## Obiective de Învățare

- Manipulare fișiere și directoare
- Potrivire pattern-uri și globbing
- Operații batch sigure
- Operații undo/rollback

---

## Cerințe Funcționale

### Obligatorii (pentru nota de trecere)

1. **Organizare după tip (extensie)**
   - Grupare: Images/, Documents/, Videos/, Audio/, Archives/, Other/
   - Mapare extensii configurabilă

2. **Organizare după dată**
   - Structură: YYYY/MM/DD sau YYYY-MM
   - Folosește data modificare sau creare

3. **Organizare după mărime**
   - Categorii: tiny (<1KB), small (<1MB), medium (<100MB), large (>100MB)

4. **Mod dry-run**
   - Previzualizare acțiuni fără execuție
   - Raport detaliat al modificărilor propuse

5. **Rollback**
   - Jurnal operații pentru undo
   - Restaurare stare anterioară

### Opționale (pentru punctaj complet)

6. **Organizare după pattern custom** (regex)
7. **Deduplicare** - identificare și gestionare duplicate
8. **Redenumire batch** - redenumire după șablon
9. **Mod watch** - organizare automată pentru fișiere noi

---

## Interfață

```bash
./file_organizer.sh [OPTIONS] <source_dir> [dest_dir]

Options:
  -h, --help              Display help
  -m, --mode MODE         Organisation mode: type|date|size|custom
  -p, --pattern REGEX     Pattern for custom mode
  -d, --dry-run           Simulation without changes
  -r, --recursive         Include subdirectories
  -u, --undo              Undo last operation
  --date-format FORMAT    Date format: YYYY/MM|YYYY-MM-DD
  --keep-original         Copy instead of move
  -v, --verbose           Detailed output

Examples:
  ./file_organizer.sh -m type ~/Downloads ~/Organised
  ./file_organizer.sh -m date --date-format YYYY/MM ~/Photos
  ./file_organizer.sh -d -m type ~/Messy  # dry-run
  ./file_organizer.sh --undo              # rollback
```

---

## Exemplu Output

```
╔══════════════════════════════════════════════════════════════════╗
║              ORGANIZATOR FIȘIERE ÎN MASĂ - DRY RUN               ║
║  Sursă: /home/user/Downloads (234 fișiere)                      ║
║  Mod: type                                                       ║
╚══════════════════════════════════════════════════════════════════╝

📊 REZUMAT MODIFICĂRI
──────────────────────────────────────────────────────────────────
Categorie       Fișiere  Mărime    Destinație
─────────────────────────────────────────────────────────────────
Images/         45       234 MB    → ./Organised/Images/
Documents/      67       45 MB     → ./Organised/Documents/
Videos/         12       1.2 GB    → ./Organised/Videos/
Archives/       23       890 MB    → ./Organised/Archives/
Other/          87       123 MB    → ./Organised/Other/

📝 ACȚIUNI DETALIATE (primele 10):
──────────────────────────────────────────────────────────────────
[MOVE] photo_2025.jpg → Images/photo_2025.jpg
[MOVE] report.pdf → Documents/report.pdf
[MOVE] video.mp4 → Videos/video.mp4
···

⚠️  CONFLICTE DETECTATE:
──────────────────────────────────────────────────────────────────
[!] Images/photo.jpg există deja - va fi redenumit photo_1.jpg

════════════════════════════════════════════════════════════════════
Rulează fără --dry-run pentru a executa aceste modificări
Jurnalul va fi salvat la: ~/.file_organizer/journal_20250120_143000.log
════════════════════════════════════════════════════════════════════
```

---

## Structură Recomandată

```
E03_Bulk_File_Organizer/
├── README.md
├── Makefile
├── src/
│   ├── file_organizer.sh
│   └── lib/
│       ├── organizers/
│       │   ├── by_type.sh
│       │   ├── by_date.sh
│       │   └── by_size.sh
│       ├── journal.sh        # Logging for undo
│       ├── conflicts.sh      # Conflict resolution
│       └── utils.sh
├── etc/
│   └── type_mappings.conf    # extension -> category
├── tests/
└── docs/
```

---

## Indicii de Implementare

```bash
# Categorisation by extension
get_category() {
    local ext="${1##*.}"
    case "${ext,,}" in
        jpg|jpeg|png|gif|bmp) echo "Images" ;;
        pdf|doc|docx|txt|odt) echo "Documents" ;;
        mp4|avi|mkv|mov) echo "Videos" ;;
        mp3|wav|flac|ogg) echo "Audio" ;;
        zip|tar|gz|rar|7z) echo "Archives" ;;
        *) echo "Other" ;;
    esac
}

# Journal for undo
log_operation() {
    echo "$(date +%s)|$1|$2|$3" >> "$JOURNAL_FILE"
    # Format: timestamp|operation|source|destination
}
```

---

## Criterii de Evaluare

| Criteriu | Pondere |
|-----------|--------|
| Organizare tip | 15% |
| Organizare dată | 10% |
| Organizare mărime | 10% |
| Dry-run funcțional | 10% |
| Undo/rollback | 15% |
| Gestionare conflicte | 10% |
| Calitate cod | 15% |
| Teste | 10% |
| Documentație | 5% |

---

*Proiect EASY | Sisteme de Operare | ASE-CSIE*
