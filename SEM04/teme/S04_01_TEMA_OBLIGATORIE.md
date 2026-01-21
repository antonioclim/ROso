# Tema Obligatorie - Seminar 07-08: Text Processing

> Sisteme de Operare | ASE București - CSIE  
> Deadline: O săptămână de la seminar  
> Punctaj: 100% (10% din nota finală)  
> Predare: Arhivă `.zip` cu scripturile pe platforma de e-learning

---

## Obiective

La finalul acestei teme, vei demonstra că poți:
- Utiliza expresii regulate (BRE și ERE) pentru căutare și validare
- Procesa fișiere text cu grep, sed și awk
- Combina unelte în pipeline-uri eficiente
- Automatiza task-uri de procesare text prin scripturi

---

## Cerințe Generale

1. Toate soluțiile trebuie să fie scripturi bash executabile (`.sh`)
2. Fiecare script trebuie să aibă header cu: nume, descriere, autor, dată
3. Codul trebuie comentat și să folosească `set -euo pipefail`
4. Testează soluțiile înainte de predare pe fișierele din `resurse/sample_data/`

---

## Exercițiul 1: Validare și Extragere Date (25%)

### Cerință
Creează scriptul `ex1_validator.sh` care:

1. (10%) Primește ca argument un fișier text și validează că toate email-urile din el sunt în format corect. Afișează:
   - Numărul total de email-uri găsite
   - Email-urile valide
   - Email-urile invalide (dacă există)

2. (8%) Extrage și afișează toate adresele IP unice din fișier, sortate numeric

3. (7%) Identifică și afișează numerele de telefon în format românesc (07XX-XXX-XXX sau 07XXXXXXXX)

### Exemplu de utilizare
```bash
./ex1_validator.sh contacts.txt
```

### Output așteptat
```
=== VALIDARE EMAIL ===
Total găsite: 10
✅ Valide: 8
  - john.doe@gmail.com
  - maria.pop@yahoo.ro
  ...
❌ Invalide: 2
  - invalid@
  - @missing.com

=== ADRESE IP UNICE ===
8.8.8.8
10.0.0.1
192.168.1.1
192.168.1.2
255.255.255.0

=== NUMERE TELEFON RO ===
0721-123-456
0722.234.567
0733 345 678
```

### Hint-uri

Concret: Pentru email: `grep -oE '[pattern]'`. Pentru IP: atenție la validarea strictă (0-255 per octet) vs. simplă. Și Pentru telefon: grupuri opționale `(-?[0-9]{3})`.


---

## Exercițiul 2: Procesare Log-uri (25%)

### Cerință
Creează scriptul `ex2_log_analyzer.sh` care analizează `server.log`:

1. (8%) Generează un raport cu numărul de mesaje per nivel de severitate (INFO, WARNING, ERROR, DEBUG)

2. (9%) Identifică toate încercările eșuate de autentificare și extrage:

Trei lucruri contează aici: username-ul (email), ip-ul de la care s-a încercat, și ora tentativei.


3. (8%) Calculează și afișează:
   - Perioada acoperită de log (prima și ultima timestamp)
   - Numărul total de evenimente
   - Procentul de erori din total

### Exemplu de utilizare
```bash
./ex2_log_analyzer.sh server.log
```

### Output așteptat
```
╔════════════════════════════════════════╗
║        RAPORT ANALIZĂ LOG              ║
╚════════════════════════════════════════╝

📊 DISTRIBUȚIE SEVERITATE:
  INFO:    15 mesaje (55.6%)
  WARNING:  3 mesaje (11.1%)
  ERROR:    4 mesaje (14.8%)
  DEBUG:    5 mesaje (18.5%)

🚨 TENTATIVE AUTENTIFICARE EȘUATE:
  [08:31:22] invalid@test.com de la 192.168.2.99

📈 STATISTICI GENERALE:
  Perioadă: 2024-01-15 08:23:45 → 08:45:00
  Total evenimente: 27
  Rata erori: 14.8%
```

### Hint-uri
- Folosește `awk` pentru agregare și calcule
- `BEGIN` pentru header, `END` pentru statistici finale
- Array-uri asociative: `count[$2]++`

---

## Exercițiul 3: modificare Date (25%)

### Cerință
Creează scriptul `ex3_data_transform.sh` care procesează `employees.csv`:

1. (10%) Convertește CSV-ul într-un format de raport tabelar:
   - Header formatat frumos
   - Coloane aliniate
   - Salariile formatate cu separator de mii și simbol $

2. (8%) Generează statistici per departament:
   - Număr angajați
   - Salariu mediu
   - Salariu minim și maxim

3. (7%) Creează un fișier nou `employees_updated.csv` în care:
   - Email-urile sunt normalizate la lowercase
   - Statusul "inactive" devine "on_leave"
   - Se adaugă o coloană nouă `years_employed` (calculată din `hire_date`)

### Exemplu de utilizare
```bash
./ex3_data_transform.sh employees.csv
```

### Output așteptat
```
╔═══════════════════════════════════════════════════════════════════╗
║                    RAPORT ANGAJAȚI TECHCORP                        ║
╠═══════════════════════════════════════════════════════════════════╣
║ ID    │ Nume              │ Departament  │ Salariu    │ Status    ║
╠═══════════════════════════════════════════════════════════════════╣
║ 1001  │ Alice Johnson     │ Engineering  │  $75,000   │ active    ║
║ 1002  │ Bob Smith         │ Marketing    │  $62,000   │ active    ║
...

📊 STATISTICI PER DEPARTAMENT:
┌──────────────┬──────────┬────────────┬────────────┬────────────┐
│ Departament  │ Angajați │ Sal. Mediu │ Sal. Min   │ Sal. Max   │
├──────────────┼──────────┼────────────┼────────────┼────────────┤
│ Engineering  │    6     │  $81,667   │  $75,000   │  $91,000   │
│ Marketing    │    3     │  $61,667   │  $59,000   │  $64,000   │
│ HR           │    3     │  $55,000   │  $52,000   │  $58,000   │
│ Sales        │    3     │  $70,667   │  $68,000   │  $73,000   │
└──────────────┴──────────┴────────────┴────────────┴────────────┘
```

### Hint-uri
- `awk -F','` pentru CSV
- `printf "%-15s %10d"` pentru aliniere
- Pentru calcul ani: poți folosi `date` sau aproxima din anul curent

---

## Exercițiul 4: Pipeline Combinat (25%)

### Cerință
Creează scriptul `ex4_sales_report.sh` care procesează `sales.csv`:

1. (10%) Generează un raport de vânzări care include:
   - Top 3 produse după revenue total
   - Top 3 regiuni după revenue total
   - Top vânzător (salesperson) per regiune

2. (8%) Detectează anomalii:
   - Zile fără vânzări (dacă există gaps în date)
   - Produse cu cantitate vândută neobișnuit de mare (>mean + 2*stddev)

3. (7%) Exportă rezultatele într-un fișier `sales_summary.txt` formatat frumos

### Exemplu de utilizare
```bash
./ex4_sales_report.sh sales.csv
```

### Output așteptat
```
╔════════════════════════════════════════════════════════════════╗
║              RAPORT VÂNZĂRI - IANUARIE 2024                    ║
╚════════════════════════════════════════════════════════════════╝

🏆 TOP 3 PRODUSE (după revenue):
   1. Laptop       - $22,800.00 (19 unități)
   2. Monitor      - $10,500.00 (30 unități)  
   3. Headphones   - $ 5,669.37 (63 unități)

🌍 TOP 3 REGIUNI:
   1. North  - $15,847.55
   2. South  - $14,398.45
   3. East   - $12,599.00

👤 CEL MAI BUN VÂNZĂTOR PER REGIUNE:
   North: Alice   ($10,847.55)
   South: Bob     ($8,398.45)
   East:  Carol   ($7,899.00)
   West:  David   ($6,998.00)

⚠️ ANOMALII DETECTATE:
   - Nici o anomalie de cantitate detectată
   - Gap în date: 2024-01-01 (zi lipsă)
```

### Hint-uri
- Pipeline: `awk ... | sort ... | head ...`
- Pentru stddev în awk: calculează în două treceri sau aproximează
- `printf` pentru formatare monedă
- Testează cu date simple înainte de cazuri complexe

---

## Structura Arhivei de Predat

```
NumePrenume_Grupa_Tema4/
├── ex1_validator.sh
├── ex2_log_analyzer.sh
├── ex3_data_transform.sh
├── ex4_sales_report.sh
├── output/                    # Output-urile generate de scripturi
│   ├── ex1_output.txt
│   ├── ex2_output.txt
│   ├── ex3_output.txt
│   ├── employees_updated.csv
│   └── sales_summary.txt
└── README.txt                 # Notițe despre implementare (opțional)
```

---

## Criterii de Evaluare

| Criteriu | Punctaj | Descriere |
|----------|---------|-----------|
| Corectitudine | 40% | Scripturile produc rezultatul corect |
| Cod curat | 20% | Comentarii, structură, denumiri clare |
| Error handling | 15% | Verifică argumente, fișiere existente |
| Eficiență | 15% | Folosește tool-urile potrivite (nu reinventează roata) |
| Formatare output | 10% | Output lizibil și profesional |

---

## Plagiat

- Codul copiat = 0% pentru toți cei implicați
- Poți discuta ideile cu colegii, dar codul trebuie scris individual
- Folosirea AI pentru generare cod este permisă DOAR dacă:
  - Declari explicit în README ce ai generat cu AI
  - Poți explica fiecare linie din cod la verificare

---

## Resurse Recomandate

1. Documentație oficială: `man grep`, `man sed`, `man awk`
2. Fișierele de test: `resurse/sample_data/`
3. Cheat sheet: `docs/S04_09_CHEAT_SHEET_VIZUAL.md`
4. Exemple live coding: `docs/S04_05_LIVE_CODING_GUIDE.md`

---

## Întrebări Frecvente

Q: Pot folosi Python în loc de bash?  
A: Nu. Scopul este să înveți uneltele Unix clasice.

Q: Ce fac dacă nu merge pe Windows?  
A: Folosește WSL, sau mașina virtuală din laborator.

Q: Pot adăuga funcționalități extra?  
A: Da! Bonus de până la 10% pentru extensii creative și utile.

---

*Material pentru cursul de Sisteme de Operare | ASE București - CSIE*
