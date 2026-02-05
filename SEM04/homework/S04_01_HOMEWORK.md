# Temă obligatorie — Seminar 04: procesare de text

> Sisteme de Operare | ASE București — CSIE  
> Termen: o săptămână de la seminar  
> Punctaj: 100% (10% din nota finală)  
> Predare: arhivă `.zip` pe platforma de e‑learning

*Avertisment: semestrul trecut trei studenți au predat output‑uri identice pe date „generate aleator”. Toți au primit zero. Semestrul acesta, datele tale sunt unice pentru numărul de matricol. Partajarea soluțiilor nu mai funcționează.*

---

## Obiective

După finalizarea acestei teme, vei demonstra capacitatea de a:
- scrie expresii regulate (BRE și ERE) pentru căutare și validare
- procesa fișiere text folosind `grep`, `sed` și `awk`
- combina instrumente în pipeline‑uri eficiente
- automatiza procesarea de text prin scripturi shell

---

## ⚠️ CRITIC: cerința de date personalizate

Această temă folosește **date de test personalizate**. Fiecare student lucrează cu fișiere unice.

### Pasul 1: Generează datele TALE
```bash
# Rulează din directorul SEM04:
make generate-data ID=YOUR_MATRICOL

# Exemplu:
make generate-data ID=123456
```

Acest lucru creează un folder `student_123456/` cu fișierele tale unice și un **checksum**.

### Pasul 2: Notează checksum‑ul
Generatorul afișează ceva de forma:
```
✓ Data generated successfully!
  Checksum: a7b3c9f2e1d4
```

**Trebuie să incluzi acest checksum în predare.** Îl verificăm.

### Pasul 3: Lucrează cu datele TALE
Toate exercițiile trebuie rezolvate folosind fișierele din folderul tău `student_MATRICOL/`.
Folosirea fișierelor generice `resources/sample_data/` atrage **penalizare −50%**.

---

## Cerințe generale

1. Toate soluțiile trebuie să fie scripturi Bash executabile (`.sh`)
2. Fiecare script trebuie să aibă un header: nume, descriere, autor și dată
3. Folosește `set -euo pipefail` la începutul fiecărui script
4. Testează soluțiile pe datele TALE personalizate înainte de predare

---

## Exercițiul 1: Validare și extragere (25%)

### Sarcina
Creează `ex1_validator.sh` care procesează `contacts.txt`:

1. **(10%)** Validează identificatori de e‑mail (obfuscați) — afișează total găsite, număr valid cu listă și număr invalid cu listă
2. **(8%)** Extrage adrese IP unice, sortate numeric
3. **(7%)** Găsește numere de telefon românești (formate: 07XX-XXX-XXX, 07XX.XXX.XXX și 07XXXXXXXX)

### Utilizare
```bash
./ex1_validator.sh student_123456/contacts.txt
```

### Format de output așteptat
```
=== VALIDARE E-MAIL ===
Total găsite: 12
✅ Valide: 9
  - john.doe_AT_gmail_DOT_com
  - maria.pop_AT_yahoo_DOT_ro
  [...]
❌ Invalide: 3
  - invalid_AT_
  - _AT_missing_DOT_com
  [...]

=== ADRESE IP UNICE ===
8.8.8.8
10.0.0.1
192.168.1.1
[...]

=== NUMERE RO ===
0721-123-456
0733345678
[...]
```

### Sfaturi
Regex‑ul pentru e‑mail trebuie să gestioneze: puncte în partea locală, subdomenii și plus‑addressing (în forma obfuscată).
Sortare IP: `sort -t. -k1,1n -k2,2n -k3,3n -k4,4n` pentru ordine numerică corectă.

---

## Exercițiul 2: Procesare loguri (25%)

### Sarcina
Creează `ex2_log_analyzer.sh` care analizează `server.log`:

1. **(8%)** Numără mesaje pe nivel de severitate (INFO, WARNING, ERROR și DEBUG) cu procente
2. **(9%)** Găsește încercări eșuate de autentificare — extrage timestamp, identificator e‑mail (obfuscat) și IP‑ul sursă
3. **(8%)** Calculează: intervalul de timp al logului, numărul total de evenimente și procentul de erori (error rate)

### Utilizare
```bash
./ex2_log_analyzer.sh student_123456/server.log
```

### Sfaturi
Formatul logului este: `[YYYY-MM-DD HH:MM:SS] [LEVEL] message`
Pentru numărare pe severități: `awk -F'[][]' '{count[$2]++}'` extrage nivelul dintre parantezele pătrate.
Pattern‑uri pentru autentificare eșuată includ: "Authentication failed", "denied" și "invalid credentials"

---

## Exercițiul 3: Transformare date (25%)

### Sarcina
Creează `ex3_data_transform.sh` care procesează `employees.csv`:

1. **(10%)** Afișează ca tabel formatat, cu coloane aliniate; salariile în format `$XX,XXX`
2. **(8%)** Statistici pe departament: număr, salariu mediu/min/max
3. **(7%)** Creează `employees_updated.csv` cu: identificatori e‑mail obfuscați în litere mici, „inactive”→„on_leave” și adăugarea coloanei `years_employed`

### Utilizare
```bash
./ex3_data_transform.sh student_123456/employees.csv
```

### Sfaturi
Formatare monetară în awk: `printf "$%'d", salary` (dependentă de locale) sau formatare manuală.
Calcul ani: `$(date +%Y)` dă anul curent; parsează `hire_date` și scade.

---

## Exercițiul 4: Pipeline combinat (25%)

### Sarcina
Creează `ex4_sales_report.sh` care procesează `sales.csv`:

1. **(10%)** Raport care afișează: top 3 produse după venit, top 3 regiuni și cel mai bun vânzător pe regiune
2. **(8%)** Detectează anomalii: gap‑uri de date și cantități neobișnuit de mari (> media + 2σ)
3. **(7%)** Exportă rezultatele formatate în `sales_summary.txt`

### Utilizare
```bash
./ex4_sales_report.sh student_123456/sales.csv
```

### Sfaturi
Venit = cantitate × preț unitar. 
Deviația standard în awk cere două treceri sau sume de x și x².
Gap‑uri de date: sortează datele, verifică dacă diferențele dintre zile consecutive sunt > 1 zi.

---

## Structura predării

```
FirstnameLastname_Group_HW4/
├── README.txt                 # OBLIGATORIU — vezi mai jos
├── ex1_validator.sh
├── ex2_log_analyzer.sh
├── ex3_data_transform.sh
├── ex4_sales_report.sh
└── output/
    ├── ex1_output.txt
    ├── ex2_output.txt
    ├── ex3_output.txt
    ├── employees_updated.csv
    └── sales_summary.txt
```

### README.txt trebuie să conțină:
```
Name: [Your Full Name]
Group: [Your Group]
Matricol: [Your Number]
Data Checksum: [checksum from generator]
Time Spent: [X hours]

AI Declaration: [Describe any AI tool usage, or "None"]

Notes: [Optional implementation notes]
```

**Checksum lipsă sau invalid = −20%**

---

## Criterii de evaluare

| Criteriu | Pondere | Note |
|-----------|--------|-------|
| Corectitudine | 40% | Scripturile produc output corect pe datele TALE |
| Calitatea codului | 20% | Comentarii, nume clare și structură corectă |
| Tratarea erorilor | 15% | Validare argumente și verificare existență fișiere |
| Eficiență | 15% | Alegeri potrivite de instrumente, fără complexitate inutilă |
| Format output | 10% | Output profesional și lizibil |

---

## Politică anti‑plagiat

- **Cod copiat = 0% pentru TOȚI cei implicați** (fără excepții)
- Discuția despre abordări este OK; partajarea codului nu este
- **Verificare orală:** vi se poate cere să explicați codul în laborator
- Dacă nu puteți explica o linie pe care ați scris‑o, investigăm mai departe

### Politica de utilizare AI
Folosirea asistenților AI (ChatGPT, Claude sau Copilot) este permisă DACĂ:
1. Declarați în README.txt (ce instrument, ce prompt‑uri și ce output)
2. Puteți explica fiecare linie la verificarea orală
3. Codul chiar funcționează pe datele TALE personalizate

*Studenții care copiază output‑ul AI fără înțelegere tind să pice verificarea orală.
Abordarea inteligentă: folosiți AI ca să învățați, nu ca să evitați învățarea.*

---

## Resurse

1. Man pages: `man grep`, `man sed`, `man awk`
2. Datele tale personalizate: `student_YOUR_MATRICOL/`
3. Cheat sheet: `docs/S04_09_VISUAL_CHEAT_SHEET.md`
4. Ghid live coding: `docs/S04_05_LIVE_CODING_GUIDE.md`
5. Întrebări pentru verificare orală: `homework/S04_05_ORAL_VERIFICATION.md` (copie pentru instructor)

---

## Întrebări frecvente (FAQ)

**Î: Pot folosi Python?**  
R: Nu. Scopul este să învățați instrumentele Unix de procesare de text. Python anulează scopul.

**Î: Regex‑ul meu merge pe regex101.com dar nu în grep?**  
R: Verificați BRE vs ERE. Folosiți `grep -E` pentru regex extins. Verificați și diferențele de escapare.

**Î: Windows?**  
R: Folosiți WSL2 sau VM‑ul de laborator. Windows „nativ” nu va funcționa.

**Î: Puncte bonus?**  
R: Până la +10% pentru extensii cu adevărat utile (nu doar „culori” la output).

**Î: Ce fac dacă checksum‑ul nu se potrivește?**  
R: Regenerați datele cu același matricol. Checksums sunt deterministe.

---

*Sisteme de Operare — ASE București CSIE*  
*Actualizat: ianuarie 2025 cu infrastructură anti‑plagiat*
