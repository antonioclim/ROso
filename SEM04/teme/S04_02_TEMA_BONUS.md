# Tema Bonus - Seminar 07-08: Text Processing Avansat

> **Sisteme de Operare** | ASE București - CSIE  
> **Deadline**: Două săptămâni de la seminar  
> **Punctaj**: Până la 20% bonus  
> **Predare**: Arhivă `.zip` separată de tema obligatorie

---

## Descriere

Această temă este **opțională** și oferă puncte bonus pentru studenții care doresc să aprofundeze procesarea textului. Exercițiile sunt mai complexe și necesită combinarea creativă a mai multor tehnici.

**Observație**: Poți rezolva oricare dintre exerciții, în orice ordine. Punctajul se adună.

---

## Exercițiul B1: Log Aggregator Multi-Format (8%)

### Cerință
Creează `bonus1_log_aggregator.sh` care procesează log-uri în **formate diferite** și le unifică.

Programul trebuie să:
1. Detecteze automat formatul fiecărui fișier log (Apache, Nginx, Syslog, JSON)
2. Extragă informațiile comune: timestamp, nivel, mesaj, IP sursă (dacă există)
3. Unifice totul într-un format standard CSV
4. Genereze statistici comparative între surse

### Formate de Recunoscut

**Apache Combined Log:**
```
192.168.1.1 - - [15/Jan/2024:08:23:45 +0000] "GET /page HTTP/1.1" 200 1234
```

**Nginx Error Log:**
```
2024/01/15 08:23:45 [error] 1234#0: *5678 message here
```

**Syslog:**
```
Jan 15 08:23:45 hostname process[1234]: message here
```

**JSON (un obiect per linie):**
```json
{"timestamp":"2024-01-15T08:23:45Z","level":"INFO","message":"text","ip":"10.0.0.1"}
```

### Utilizare
```bash
./bonus1_log_aggregator.sh access.log error.log syslog.log app.json -o unified.csv
```

### Criterii Evaluare
- Detectare corectă format: 2%
- Extragere corectă date: 3%
- Output CSV valid: 2%
- Statistici: 1%

---

## Exercițiul B2: Diff și Patch cu Regex (6%)

### Cerință
Creează `bonus2_smart_diff.sh` care compară două fișiere și identifică diferențele **semantic**, nu doar textual.

Programul trebuie să:
1. Ignore diferențele de whitespace (spații, tab-uri, linii goale)
2. Ignore diferențele de casing în keywords configurate
3. Ignore comentariile (linii care încep cu `#`, `//`, `--`)
4. Raporteze doar diferențele "reale" de conținut

### Utilizare
```bash
./bonus2_smart_diff.sh config_v1.ini config_v2.ini --ignore-comments --ignore-case-keywords
```

### Output Așteptat
```
=== SMART DIFF REPORT ===
Fișier 1: config_v1.ini (45 linii, 12 comentarii)
Fișier 2: config_v2.ini (48 linii, 15 comentarii)

Diferențe semnificative găsite: 3

[Linia 12 vs 14]
- host = 192.168.1.100
+ host = 192.168.1.200

[Linia 25 vs 28]
- timeout = 30
+ timeout = 60

[Doar în v2, linia 45]
+ new_feature = enabled
```

### Criterii Evaluare
- Ignorare whitespace: 1.5 pct
- Ignorare comentarii: 1.5 pct
- Comparație semantică: 2%
- Output clar: 1%

---

## Exercițiul B3: Generator Rapoarte HTML (6%)

### Cerință
Creează `bonus3_html_report.sh` care modifică datele CSV în rapoarte HTML interactive.

Programul trebuie să:
1. Parseze orice fișier CSV (detectare automată separator și header)
2. Genereze o pagină HTML cu tabel sorabil
3. Adauge grafice simple (bare ASCII sau SVG inline)
4. Includă CSS pentru styling profesional

### Utilizare
```bash
./bonus3_html_report.sh employees.csv -o report.html --chart salary --group-by department
```

### Output HTML trebuie să conțină
- Tabel cu toate datele, sortabil prin click pe header
- Grafic cu salariile per departament
- Statistici sumare (total, medii, min/max)
- Design responsive (funcționează pe mobil)

### Criterii Evaluare
- Parsare CSV corectă: 1.5 pct
- Tabel HTML valid: 1.5 pct
- Grafice: 2%
- Styling CSS: 1%

---

## Exercițiul B4: Mini Grep cu Highlighting (5%)

### Cerință
Reimplementează grep de la zero folosind **doar bash built-ins și sed**.

`bonus4_mygrep.sh` trebuie să suporte:
- Pattern matching cu expresii regulate de bază
- Opțiunile: `-i` (case insensitive), `-n` (line numbers), `-c` (count), `-v` (invert)
- Colorare (highlighting) a match-urilor în output

### Utilizare
```bash
./bonus4_mygrep.sh -in "error|warning" server.log
```

### Restricții
- NU ai voie să folosești `grep`, `awk`, sau `perl`
- Doar: `bash`, `sed`, `read`, `echo`, `printf`, variabile, loops

### Criterii Evaluare
- Pattern matching funcțional: 2%
- Opțiuni implementate: 2%
- Highlighting: 1%

---

## Exercițiul B5: Config File Linter (5%)

### Cerință
Creează `bonus5_config_linter.sh` care validează fișiere de configurare și raportează probleme.

Verificări de implementat:
1. **Sintaxă**: Secțiuni `[name]` corect închise, `key = value` format valid
2. Valori: Porturi în range valid (1-65535), IP-uri valide, paths existente
3. **Securitate**: Detectează passwords în plain text, permisiuni prea largi
4. **Best practices**: Chei duplicate, secțiuni goale, valori hardcodate

### Utilizare
```bash
./bonus5_config_linter.sh config.ini --strict
```

### Output Așteptat
```
╔══════════════════════════════════════════════════════════════╗
║              CONFIG LINTER - config.ini                       ║
╚══════════════════════════════════════════════════════════════╝

✅ PASSED: Sintaxă validă
✅ PASSED: Toate secțiunile au conținut

⚠️ WARNING [linia 15]: Password în plain text detectat
   password = secret123
   → Recomandare: Folosește variabile de environment

⚠️ WARNING [linia 22]: Port non-standard
   port = 99999
   → Trebuie să fie între 1-65535

❌ ERROR [linia 30]: IP invalid
   host = 999.999.999.999

📊 SUMAR: 0 erori critice, 2 warnings, 1 eroare
```

### Criterii Evaluare
- Validare sintaxă: 1.5 pct
- Validare valori: 1.5 pct
- Detectare probleme securitate: 1.5 pct
- Output profesional: 0.5 pct

---

## Structura Predare

```
NumePrenume_Grupa_Bonus4/
├── bonus1_log_aggregator.sh    (dacă rezolvat)
├── bonus2_smart_diff.sh        (dacă rezolvat)
├── bonus3_html_report.sh       (dacă rezolvat)
├── bonus4_mygrep.sh            (dacă rezolvat)
├── bonus5_config_linter.sh     (dacă rezolvat)
├── test_files/                 # Fișiere folosite pentru testare
│   └── ...
├── output/                     # Output-uri generate
│   └── ...
└── SOLUTIONS.md                # Explicații pentru fiecare exercițiu rezolvat
```

---

## Sfaturi

1. **Alege strategic**: Nu trebuie să rezolvi toate - alege ce te interesează
2. **Documentează**: Codul bine comentat primește punctaj mai mare
3. **Testează**: Include cazuri edge în testare
4. **Fii creativ**: Soluții elegante primesc bonus suplimentar

---

## Reguli Speciale Bonus

- Punctele bonus se adaugă **peste** nota de la tema obligatorie
- Maximum 20% bonus (chiar dacă rezolvi tot)
- Codul trebuie să fie **original** - verificare anti-plagiat strictă
- Dacă folosești AI, declară și explică - altfel penalizare

---

*Material pentru cursul de Sisteme de Operare | ASE București - CSIE*
