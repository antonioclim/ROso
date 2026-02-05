# Nivele de diferențiere — Seminarul 03
## Adaptare la niveluri diferite de studenți

> **Versiune:** 1.0 | **Data:** Ianuarie 2025  
> **Scop:** Suport pentru studenții cu dificultăți, provocări pentru cei avansați  
> **Principiu:** Aceleași obiective de învățare, căi diferite

---

## Sistemul cu trei nivele

Nu toată lumea sosește la același nivel. După patru semestre în care am văzut studenți fie panicând fie plictisiți, am formalizat aceasta în trei nivele. Trucul este să identifici ce studenți au nevoie de care nivel *fără* a face pe cineva să se simtă etichetat.

| Nivel | Cine | Semne de urmărit | Buget timp |
|-------|------|------------------|------------|
| **Fundament** | Cu dificultăți la bază | Nu a terminat Sprint-ul la jumătate; întreabă „ce înseamnă -type?"; ecran gol după 5 min | +20% timp |
| **Nucleu** | Progres mediu | Termină Sprint-ul la timp cu erori minore; pune întrebări de clarificare | Standard |
| **Extensie** | Termină rapid | Gata în jumătate din timp; începe să ajute vecinii; pare plictisit | Probleme de provocare |

**Important:** Nu anunța niciodată nivelurile public. Spun lucruri ca „Dacă ai terminat devreme, ia o problemă de provocare de pe tablă" sau „Dacă ești blocat, folosește fișa simplificată de la pagina 2."

---

## Nivelul Fundament: Suport structurat

### F1. Constructor de comenzi find (Fișă vizuală)

Pentru studenții care îngheață la terminalul gol. Înmânează asta discret oricui se uită la ecran după 5 minute.

```
┌─────────────────────────────────────────────────────────────────────┐
│                    CONSTRUIEȘTE COMANDA FIND                         │
│                                                                     │
│  find  [UNDE?]  [CE TIP?]  [CE NUME?]  [APOI FAC?]                 │
│         │           │           │            │                      │
│         ▼           ▼           ▼            ▼                      │
│    ┌─────────┐  ┌─────────┐   ┌──────────┐  ┌──────────┐           │
│    │  /home  │  │ -type f │   │-name "x" │  │   -ls    │           │
│    │    .    │  │ -type d │   │-name "y" │  │ -delete  │           │
│    │  /tmp   │  │         │   │          │  │ -exec    │           │
│    └─────────┘  └─────────┘   └──────────┘  └──────────┘           │
│                                                                     │
│  Comanda ta:  find _______ _________ ___________ ___________       │
└─────────────────────────────────────────────────────────────────────┘

EXEMPLU: „Găsește toate fișierele .log în /var"
  → find /var -type f -name "*.log"
       │       │           │
       │       │           └── se termină cu .log
       │       └── doar fișiere, nu directoare  
       └── începe căutarea în /var
```

### F2. Calculator de permisiuni (Metoda checkbox)

Pentru studentul care nu-și amintește ce înseamnă 7-5-5. Mult mai lent decât calculul mental, dar *funcționează*.

```
┌───────────────────────────────────────────────────────────────────┐
│               CALCULATOR DE PERMISIUNI                             │
│                                                                    │
│  Bifează ce poate face PROPRIETARUL:    Ce pot face CEILALȚI:     │
│    □ Citire   (4)                         □ Citire   (4)          │
│    □ Scriere  (2)                         □ Scriere  (2)          │
│    □ Execuție (1)                         □ Execuție (1)          │
│    ─────────────                         ─────────────            │
│    Total: ___                            Total: ___               │
│                                                                    │
│  Ce poate face GRUPUL:                                             │
│    □ Citire   (4)                                                  │
│    □ Scriere  (2)                        chmod final: ___ ___ ___ │
│    □ Execuție (1)                                   prop grp alt  │
│    ─────────────                                                   │
│    Total: ___                                                      │
└───────────────────────────────────────────────────────────────────┘

EXEMPLU: Proprietarul poate citi+scrie+executa, grupul poate citi+executa, ceilalți nimic
  Proprietar: 4+2+1 = 7
  Grup: 4+0+1 = 5  
  Alții: 0+0+0 = 0
  
  → chmod 750 myfile.sh
```

### F3. Șablon getopts (Completează spațiile goale)

În loc să se uite la un editor gol, completează spațiile:

```bash
#!/bin/bash
# ȘABLON: Completează spațiile marcate cu ___

# Valori implicite
VERBOSE=false
OUTPUT_FILE=""

# Afișare ajutor
usage() {
    echo "Utilizare: $0 [-h] [-v] [-o FIȘIER]"
    echo "  -h       Afișează acest ajutor"
    echo "  -v       Activează modul detaliat"
    echo "  -o FIȘIER  Scrie rezultatul în FIȘIER"
    exit 0
}

# Parsare opțiuni - COMPLETEAZĂ SPAȚIILE GOALE
while getopts "_____" opt; do    # ← Ce litere? (indiciu: h, v, o cu argument)
    case $opt in
        h) usage ;;
        v) _________=true ;;      # ← Ce variabilă devine true?
        o) OUTPUT_FILE="______" ;;  # ← Cum obții argumentul?
        ?) echo "Opțiune necunoscută"; exit 1 ;;
    esac
done

# Deplasare peste opțiuni
shift $((______ - 1))            # ← Ce variabilă urmărește poziția?

# Acum $@ conține doar argumentele rămase
echo "Detaliat: $VERBOSE"
echo "Output: $OUTPUT_FILE"
echo "Argumente rămase: $@"
```

**Cheie de răspuns** (pentru instructor):
- `"hvo:"` (h și v sunt flag-uri, o ia argument deci două puncte)
- `VERBOSE`
- `$OPTARG`
- `OPTIND`

---

## Nivelul Nucleu: Exerciții standard

Acestea sunt exercițiile principale de Sprint. Majoritatea studenților ar trebui să le completeze cu timp de răgaz.

### C1. Maestru find (15 minute)

1. Găsește toate fișierele `.sh` modificate în ultimele 7 zile
2. Găsește fișierele mai mari de 1MB care NU sunt în `/proc` sau `/sys`
3. Găsește directoarele goale și listează-le
4. Combinație: găsește fișierele `.log` peste 100KB, mai vechi de 30 zile și afișează dimensiunile lor

### C2. Script profesionist (15 minute)

Creează un script `filecount.sh` care:
- Acceptă `-d DIRECTOR` pentru a specifica unde să numere
- Acceptă `-t TIP` pentru a filtra după extensie (ex., `-t txt`)
- Acceptă `-v` pentru output detaliat
- Afișează numărul de fișiere potrivite

### C3. Audit permisiuni (10 minute)

1. Găsește toate fișierele world-writable din directorul home
2. Găsește toate fișierele cu bit SUID setat în `/usr/bin`
3. Creează un director unde membrii grupului pot adăuga fișiere dar nu pot șterge fișierele altora

---

## Nivelul Extensie: Probleme de provocare

Pentru studenții care termină devreme. Acestea depășesc curriculumul dar consolidează conceptele.

### E1. ACL în profunzime (Avansat)

Permisiunile Unix obișnuite sunt limitate. Ce faci dacă trebuie să dai acces unor utilizatori *specifici*?

```bash
# Instalare instrumente ACL (dacă nu sunt prezente)
sudo apt install acl

# Sarcină: Creează un fișier care:
# - Tu poți citi/scrie
# - Utilizatorul 'alice' poate doar citi
# - Grupul 'developers' poate citi/scrie
# - Toți ceilalți: fără acces

# Indiciu: 
# setfacl -m u:alice:r-- fisierul_meu.txt
# getfacl fisierul_meu.txt
```

**Întrebări de provocare:**
1. Ce se întâmplă cu ACL-urile când faci `cp` unui fișier? Când îl `mv`?
2. Cum afectează ACL-urile implicite pe directoare fișierele noi?
3. De ce `ls -l` arată un `+` după permisiuni când sunt setate ACL-uri?

### E2. Monitor de fișiere în timp real

Folosește `inotifywait` pentru a urmări un director și a reacționa la schimbări:

```bash
# Instalare inotify-tools
sudo apt install inotify-tools

# Sarcină: Scrie un script care:
# 1. Urmărește ~/Downloads pentru fișiere noi
# 2. Când apare un .pdf, îl mută în ~/Documents/PDFs/
# 3. Când apare un .jpg, îl mută în ~/Pictures/
# 4. Loghează toate acțiunile cu timestamp-uri

# Start:
inotifywait -m -e create ~/Downloads |
while read path action file; do
    echo "Detectat: $file"
    # Logica ta aici
done
```

### E3. Generator de job-uri cron (Interactiv)

Construiește un script interactiv care ajută utilizatorii să creeze intrări cron:

```bash
# Scriptul ar trebui să:
# 1. Întrebe „Cât de des?" (în fiecare minut, orar, zilnic, săptămânal, lunar, personalizat)
# 2. Pentru personalizat: să întrebe pentru ore specifice
# 3. Să întrebe pentru comanda de rulat
# 4. Să genereze linia cron
# 5. Opțional să o adauge direct în crontab

# Exemplu de interacțiune:
# > Cât de des? [1] În fiecare minut [2] Orar [3] Zilnic [4] Săptămânal [5] Personalizat
# > 3
# > La ce oră? (HH:MM, format 24h)
# > 03:30
# > Comanda de rulat:
# > /home/user/backup.sh
# 
# Generat: 30 3 * * * /home/user/backup.sh
# Adaug în crontab? [y/N]
```

### E4. Backup incremental cu timestamp-uri

Treci dincolo de simplul `tar` la backup-uri incrementale:

```bash
# Sarcină: Creează backup_incremental.sh care:
# 1. La prima rulare, creează backup complet: backup_FULL_20250130.tar.gz
# 2. La rulările următoare, face backup doar fișierelor modificate de la ultimul backup
# 3. Folosește find -newer pentru a detecta schimbările
# 4. Menține un fișier timestamp „last_backup"
# 5. Rotește backup-urile vechi (păstrează doar ultimele 5)

# Indicii:
# - touch -d "2025-01-30 10:00" last_backup_marker
# - find /data -newer last_backup_marker -type f
# - tar --files-from=fisiere_modificate.txt
```

---

## Cum să identifici nivelurile fără jenă

În timpul sprint-urilor, merg prin sală în tăcere. Iată lista mea mentală:

**Semne pentru Fundament** (oferă fișa discret):
- Terminal gol după 5 minute
- Tastează repetat aceeași comandă greșită
- Se uită la ecranul vecinului cu confuzie
- Mâna ridicată dar prea timid să întrebe

**Semne pentru Extensie** (lasă cardul de provocare pe bancă):
- Spate pe spate, brațele încrucișate, expresie de terminat
- Ajută extensiv vecinul
- Adaugă funcții suplimentare necerute
- Întreabă „ce altceva pot încerca?"

**Ce spun:**
- Fundament: „Iată o fișă de referință pe care unii studenți o consideră utilă" (nu „pentru că ai dificultăți")
- Extensie: „Dacă ai terminat, există o provocare extra pe tablă — opțional dar distractiv"

---

## Ajustări de timp

| Scenariu | Fundament | Nucleu | Extensie |
|----------|-----------|--------|----------|
| Sprint 1 (find) | 18 min + fișă | 15 min | 10 min + E1 sau E2 |
| Sprint 2 (script) | 18 min + șablon | 15 min | 10 min + E3 |
| Permisiuni | 12 min + calculator | 10 min | 8 min + ACL |
| Cron | 10 min (doar demo, HW) | 8 min | 5 min + E4 |

---

## Checklist materiale

Printează înainte de seminar:
- [ ] 10× Fișe Fundament (F1, F2, F3) — nu printa prea multe, pare condescendent
- [ ] 5× Carduri provocare Extensie (E1-E4) — laminate, reutilizabile
- [ ] Sticky notes pentru Checkpoint 3

---

*Framework de diferențiere pentru Seminarul 3 | Sisteme de Operare*  
*ASE București — CSIE*  
*Creat: Ianuarie 2025 (v1.0)*
