# E03: Bulk File Organizer

> **Nivel:** EASY | **Timp estimat:** 15-20 ore | **Componente:** Bash only

---

## Descriere

Dezvoltă un tool pentru organizarea automată a fișierelor în directoare structurate. Suportă organizare după tip, dată, dimensiune sau pattern-uri custom.

---

## Obiective de Învățare

- Manipulare fișiere și directoare
- Pattern matching și globbing
- Operații batch sigure
- Undo/rollback operații

---

## Cerințe Funcționale

### Obligatorii

1. **Organizare după tip (extensie)**
   - Grupare: Images/, Documents/, Videos/, Audio/, Archives/, Other/
   - Mapare extensii configurabilă

2. **Organizare după dată**
   - Structură: YYYY/MM/DD sau YYYY-MM
   - Folosire dată modificare sau creare

3. **Organizare după dimensiune**
   - Categorii: tiny (<1KB), small (<1MB), medium (<100MB), large (>100MB)

4. **Mod dry-run**
   - Previzualizare acțiuni fără execuție
   - Raport detaliat al modificărilor propuse

5. **Rollback**
   - Jurnal operații pentru undo
   - Restaurare stare anterioară

### Opționale

6. **Organizare după pattern custom** (regex)
7. **Deduplicare** - identificare și gestionare duplicate
8. **Renaming batch** - redenumire după template
9. **Watch mode** - organizare automată la fișiere noi

---

## Interfață

```bash
./file_organizer.sh [OPȚIUNI] <source_dir> [dest_dir]

Opțiuni:
  -h, --help              Afișează ajutor
  -m, --mode MODE         Mod organizare: type|date|size|custom
  -p, --pattern REGEX     Pattern pentru mod custom
  -d, --dry-run           Simulare fără modificări
  -r, --recursive         Include subdirectoare
  -u, --undo              Anulează ultima operație
  --date-format FORMAT    Format dată: YYYY/MM|YYYY-MM-DD
  --keep-original         Copiază în loc de mutare
  -v, --verbose           Output detaliat

Exemple:
  ./file_organizer.sh -m type ~/Downloads ~/Organized
  ./file_organizer.sh -m date --date-format YYYY/MM ~/Photos
  ./file_organizer.sh -d -m type ~/Messy  # dry-run
  ./file_organizer.sh --undo              # rollback
```

---

## Exemplu Output

```
╔══════════════════════════════════════════════════════════════════╗
║              BULK FILE ORGANIZER - DRY RUN                       ║
║  Source: /home/user/Downloads (234 files)                        ║
║  Mode: type                                                      ║
╚══════════════════════════════════════════════════════════════════╝

📊 SUMMARY OF CHANGES
──────────────────────────────────────────────────────────────────
Category        Files    Size      Destination
─────────────────────────────────────────────────────────────────
Images/         45       234 MB    → ./Organized/Images/
Documents/      67       45 MB     → ./Organized/Documents/
Videos/         12       1.2 GB    → ./Organized/Videos/
Archives/       23       890 MB    → ./Organized/Archives/
Other/          87       123 MB    → ./Organized/Other/

📝 DETAILED ACTIONS (first 10):
──────────────────────────────────────────────────────────────────
[MOVE] photo_2025.jpg → Images/photo_2025.jpg
[MOVE] report.pdf → Documents/report.pdf
[MOVE] video.mp4 → Videos/video.mp4
...

⚠️  CONFLICTS DETECTED:
──────────────────────────────────────────────────────────────────
[!] Images/photo.jpg already exists - will rename to photo_1.jpg

════════════════════════════════════════════════════════════════════
Run without --dry-run to execute these changes
Journal will be saved to: ~/.file_organizer/journal_20250120_143000.log
════════════════════════════════════════════════════════════════════
```

---

## Structura Recomandată

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
│       ├── journal.sh        # Logging pentru undo
│       ├── conflicts.sh      # Rezolvare conflicte
│       └── utils.sh
├── etc/
│   └── type_mappings.conf    # extensie -> categorie
├── tests/
└── docs/
```

---

## Hints Implementare

```bash
# Categorizare după extensie
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

# Jurnal pentru undo
log_operation() {
    echo "$(date +%s)|$1|$2|$3" >> "$JOURNAL_FILE"
    # Format: timestamp|operation|source|destination
}
```

---

## Criterii Evaluare

| Criteriu | Pondere |
|----------|---------|
| Organizare type | 15% |
| Organizare date | 10% |
| Organizare size | 10% |
| Dry-run funcțional | 10% |
| Undo/rollback | 15% |
| Gestionare conflicte | 10% |
| Calitate cod | 15% |
| Teste | 10% |
| Documentație | 5% |

---

*Proiect EASY | Sisteme de Operare | ASE-CSIE*
