# Template Submisie - Tema Seminar 07-08

## Structura Arhivei

Creează o arhivă ZIP cu numele: `NumePrenume_Grupa_Tema4.zip`

```
NumePrenume_Grupa_Tema4/
│
├── ex1_validator.sh          # Obligatoriu
├── ex2_log_analyzer.sh       # Obligatoriu
├── ex3_data_transform.sh     # Obligatoriu
├── ex4_sales_report.sh       # Obligatoriu
│
├── output/                   # Folder cu rezultatele generate
│   ├── ex1_output.txt
│   ├── ex2_output.txt
│   ├── ex3_output.txt
│   ├── employees_updated.csv
│   └── sales_summary.txt
│
└── README.txt               # Opțional - note despre implementare
```

---

## Checklist Înainte de Predare

### Scripturi
- [ ] Toate cele 4 scripturi sunt prezente
- [ ] Scripturile au extensia `.sh`
- [ ] Scripturile sunt executabile (`chmod +x *.sh`)
- [ ] Scripturile au header cu nume, descriere, autor
- [ ] Scripturile folosesc `set -euo pipefail`

### Funcționalitate
- [ ] Ex1 rulează corect pe `contacts.txt`
- [ ] Ex2 rulează corect pe `server.log`
- [ ] Ex3 rulează corect pe `employees.csv`
- [ ] Ex4 rulează corect pe `sales.csv`

### Output

Principalele aspecte: [ ] folder `output/` conține toate fișierele generate, [ ] output-urile sunt formatate profesional și [ ] nu există erori în console.


### Calitate
- [ ] Cod comentat și organizat
- [ ] Variabile cu nume descriptive
- [ ] Error handling pentru argumente lipsă
- [ ] Mesaje de eroare clare

---

## README.txt Template

Copiază și completează în README.txt (opțional):

```
=== TEMA SEMINAR 07-08 ===
Nume: [Nume Prenume]
Grupa: [Grupa]
Data: [Data]

=== EXERCIȚII REZOLVATE ===
[x] Ex1 - Validare și Extragere Date
[x] Ex2 - Procesare Log-uri
[x] Ex3 - Transformare Date
[x] Ex4 - Pipeline Combinat

=== NOTE IMPLEMENTARE ===
Ex1: [Scurtă descriere a abordării tale]
Ex2: [Scurtă descriere a abordării tale]
Ex3: [Scurtă descriere a abordării tale]
Ex4: [Scurtă descriere a abordării tale]

=== DIFICULTĂȚI ÎNTÂMPINATE ===
[Descrie ce probleme ai avut și cum le-ai rezolvat]

=== UTILIZARE AI ===
[Dacă ai folosit AI (ChatGPT, Claude, etc.), specifică:

- Ce ai generat cu AI
- Ce ai modificat manual
- Ce ai înțeles și poți explica]


=== TIMP PETRECUT ===
Aproximativ: [X] ore
```

---

## Greșeli Comune de Evitat

### Nu face
- Nu trimite fișiere cu extensia `.txt` în loc de `.sh`
- Nu uita să faci scripturile executabile
- Nu copia cod fără să înțelegi ce face
- Nu ignora erorile - tratează-le

### Fa
- Testează pe fișierele din `resurse/sample_data/`
- Folosește `shellcheck` pentru validare sintaxă
- Verifică pe Linux (nu doar Windows)
- Comentează secțiunile importante

---

## Comenzi Utile

```bash
# Verifică sintaxa bash (instalează: apt install shellcheck)
shellcheck ex1_validator.sh

# Fă toate scripturile executabile
chmod +x *.sh

# Creează arhiva ZIP
zip -r NumePrenume_Grupa_Tema4.zip NumePrenume_Grupa_Tema4/

# Testează un script
./ex1_validator.sh ../resurse/sample_data/contacts.txt

# Verifică dimensiunea arhivei
ls -lh NumePrenume_Grupa_Tema4.zip
```

---

## Predare

1. Verifică că arhiva se dezarhivează corect
2. Încarcă pe platforma de e-learning
3. Verifică că upload-ul a reușit
4. Păstrează o copie locală

**Deadline**: [Vezi tema pentru data exactă]

---

