# Tema Seminar 3-4: Pipeline Master
## Sisteme de Operare | ASE București - CSIE

Document: S02_01_TEMA.md  
Deadline: [A se completa de instructor]  
Punctaj maxim: 100% + 20 bonus

---

## Obiective

La finalul acestei teme, vei demonstra că poți:
- Combina comenzi cu operatori de control (`;`, `&&`, `||`, `&`) și redirecționa I/O corect
- Construi pipeline-uri eficiente pentru procesarea datelor
- Scrie bucle funcționale pentru automatizare
- Evalua și îmbunătăți cod existent

---

## Cerințe Tehnice

- Sistem: Ubuntu 22.04+ / WSL2 / macOS cu Bash 4.0+ și editor nano/pico
- Testare obligatorie: Toate scripturile trebuie funcționale înainte de predare

---

## Structura Temei

```
tema_NumePrenume_Grupa/
├── README.md                    # Completat cu datele tale
├── REFLECTION.md                # Reflecții obligatorii
├── partea1_operatori/
│   ├── ex1_backup_safe.sh
│   ├── ex2_multi_command.sh
│   └── ex3_parallel_demo.sh
├── partea2_redirectare/
│   ├── ex1_log_separator.sh
│   ├── ex2_config_generator.sh
│   └── ex3_silent_runner.sh
├── partea3_filtre/
│   ├── ex1_top_words.sh
│   ├── ex2_csv_analyzer.sh
│   ├── ex3_log_stats.sh
│   └── ex4_frequency_counter.sh
├── partea4_bucle/
│   ├── ex1_batch_rename.sh
│   ├── ex2_file_processor.sh
│   ├── ex3_countdown.sh
│   └── ex4_menu_system.sh
├── partea5_proiect/
│   └── system_report.sh
└── bonus/
    └── [exerciții bonus opționale]
```

---

## PARTEA 1: Operatori de Control (20%)

### Exercițiul 1.1: Backup Safe (7%)

Fișier: `partea1_operatori/ex1_backup_safe.sh`

Scrie un script care:
1. Primește un fișier ca argument (`$1`)
2. Verifică dacă fișierul există
3. Creează directorul `backup/` dacă nu există
4. Copiază fișierul în `backup/` cu timestamp în nume
5. Afișează mesaj de succes SAU eroare

Cerințe:
- Folosește `&&` și `||` (NU if-uri) într-o singură linie de cod pentru logica principală
- Gestionează cazul când nu se dă argument (eroare explicită)

Exemplu:
```bash
./ex1_backup_safe.sh important.txt
# Output succes: " Backup creat: backup/important_20250119_143022.txt"
# Output eroare: " Fișierul important.txt nu există!"
```

Verificare:
```bash
echo "test" > test.txt
./ex1_backup_safe.sh test.txt  # Trebuie să creeze backup
./ex1_backup_safe.sh inexistent.txt  # Trebuie să afișeze eroare
```

### Exercițiul 1.2: Multi-Command (7%)

Fișier: `partea1_operatori/ex2_multi_command.sh`

Scrie un one-liner care:
1. Creează directorul `proiect/`
2. Intră în el
3. Creează fișierele: `README.md`, `main.sh`, `.gitignore`
4. Face `main.sh` executabil
5. Afișează structura cu `ls -la`
6. Toate DOAR dacă pașii anteriori reușesc

Cerințe:
- O singură linie de cod (poate folosi `;`, `&&`)
- Dacă directorul există deja, să afișeze mesaj și să continue

### Exercițiul 1.3: Parallel Demo (6%)

Fișier: `partea1_operatori/ex3_parallel_demo.sh`

Scrie un script care:
1. Pornește 3 procese `sleep 2` în background
2. Afișează PID-urile lor
3. Afișează lista de jobs
4. Așteaptă toate să termine
5. Afișează "Toate procesele au terminat"

Cerințe:
- Folosește `&`, `$!`, `jobs`, `wait`

---

## PARTEA 2: Redirecționare I/O (20%)

### Exercițiul 2.1: Log Separator (7%)

Fișier: `partea2_redirectare/ex1_log_separator.sh`

Scrie un script care rulează:
```bash
find /etc -name "*.conf" -type f 2>/dev/null
ls /inexistent
echo "Procesare completă"
```

Și separă output-ul astfel:

Pe scurt: stdout → `output/success.log`; stderr → `output/errors.log`; Ambele → `output/combined.log`.


Cerințe:
- Creează directorul `output/` dacă nu există
- Folosește `tee` pentru combined.log

### Exercițiul 2.2: Config Generator (7%)

Fișier: `partea2_redirectare/ex2_config_generator.sh`

Scrie un script care generează un fișier de configurare folosind here document:

```bash
# Fișierul generat (config.ini) trebuie să conțină:
[general]
app_name=MyApp
version=1.0
date_generated=<DATA CURENTĂ>
user=<USER CURENT>
home=<HOME DIR>

[paths]
config_dir=/etc/myapp
log_dir=/var/log/myapp
data_dir=/var/lib/myapp

[settings]
debug=false
max_connections=100
```

Cerințe:

- Folosește `<< EOF` (here document)
- Variabilele (`data`, `user`, `home`) trebuie expandate
- Textul din secțiunile `paths` și `settings` trebuie să fie literal


### Exercițiul 2.3: Silent Runner (6%)

Fișier: `partea2_redirectare/ex3_silent_runner.sh`

Scrie un script care:
1. Primește o comandă ca argumente
2. Rulează comanda suprimând TOT output-ul
3. Returnează doar exit code-ul cu mesaj

Exemplu:
```bash
./ex3_silent_runner.sh ls /home
# Output: " Comandă reușită (exit code: 0)"

./ex3_silent_runner.sh ls /inexistent
# Output: " Comandă eșuată (exit code: 2)"
```

---

## PARTEA 3: Filtre de Text (25%)

### Exercițiul 3.1: Top Words (6%)

Fișier: `partea3_filtre/ex1_top_words.sh`

Scrie un script care:
1. Primește un fișier text ca argument
2. Afișează top 10 cele mai frecvente cuvinte
3. Format: `COUNT WORD` (sortate descrescător)

Cerințe:
- Ignoră capitalizarea (case-insensitive)
- Elimină punctuația
- Folosește combinație de: `tr`, `sort`, `uniq`, `head`
- Folosește `man` sau `--help` când ai dubii

Exemplu input (`sample.txt`):
```
The quick brown fox jumps over the lazy dog.
The dog was not amused by the fox.
```

Output așteptat:
```
      3 the
      2 dog
      2 fox
      1 quick
      ...
```

### Exercițiul 3.2: CSV Analyzer (7%)

Fișier: `partea3_filtre/ex2_csv_analyzer.sh`

Având fișierul `studenti.csv`:
```csv
nume,varsta,nota,grupa
Popescu Ion,21,9,1234
Ionescu Maria,22,10,1234
Georgescu Ana,20,8,1235
Vasilescu Dan,23,7,1235
Marinescu Elena,21,9,1234
```

Scrie un script care afișează:
1. Numărul total de studenți
2. Lista de grupe unice
3. Top 3 studenți după notă
4. Numărul de studenți per grupă

Cerințe:
- Folosește `cut`, `sort`, `uniq`, `head`, `tail`
- Exclude header-ul din calcule

### Exercițiul 3.3: Log Stats (6%)

Fișier: `partea3_filtre/ex3_log_stats.sh`

Având un fișier `access.log` în format standard:
```
192.168.1.1 - - [01/Jan/2025:10:00:00] "GET /index.html" 200 1234
```

Scrie un script care afișează:
1. Top 5 IP-uri după număr de request-uri
2. Distribuția codurilor HTTP (200, 404, 500, etc.)
3. Total request-uri

### Exercițiul 3.4: Frequency Counter (6%)

Fișier: `partea3_filtre/ex4_frequency_counter.sh`

Scrie un script generic care:
1. Primește un fișier și un număr de coloană
2. Afișează frecvența valorilor din acea coloană
3. Suportă delimitator custom (default: spațiu)

Exemplu:
```bash
./ex4_frequency_counter.sh data.txt 2 ","
# Numără frecvența valorilor din coloana 2, delimitator virgulă
```

---

## PARTEA 4: Bucle (25%)

### Exercițiul 4.1: Batch Rename (6%)

Fișier: `partea4_bucle/ex1_batch_rename.sh`

Scrie un script care:
1. Primește un pattern și un prefix nou
2. Redenumește toate fișierele care match-uiesc pattern-ul
3. Afișează fiecare redenumire

Exemplu:
```bash
# Creează fișiere de test
touch file1.txt file2.txt file3.txt

# Rulează
./ex1_batch_rename.sh "*.txt" "document"
# Output:
# file1.txt → document_1.txt
# file2.txt → document_2.txt
# file3.txt → document_3.txt
```

Cerințe:
- Gestionează fișiere cu spații în nume
- Afișează eroare dacă nu există fișiere

### Exercițiul 4.2: File Processor (7%)

Fișier: `partea4_bucle/ex2_file_processor.sh`

Scrie un script care:
1. Primește un director ca argument
2. Pentru fiecare fișier `.txt` din director:
   - Afișează numele
   - Afișează numărul de linii, cuvinte, caractere
   - Afișează prima și ultima linie
3. La final, afișează totaluri

Cerințe:
- Folosește `while read` sau `for` cu glob
- Gestionează directoare goale

### Exercițiul 4.3: Countdown (6%)

Fișier: `partea4_bucle/ex3_countdown.sh`

Scrie un script care:
1. Primește un număr ca argument (default: 10)
2. Face countdown de la acel număr la 0
3. Afișează "GO!" sau mesaj custom la final
4. Interval de 1 secundă între numere

Cerințe:

Concret: Folosește buclă (for sau while). Clear screen între numere (opțional dar recomandat). Și Validează că argumentul e un număr pozitiv.


### Exercițiul 4.4: Menu System (6%)

Fișier: `partea4_bucle/ex4_menu_system.sh`

Scrie un script cu meniu interactiv:
```
╔════════════════════════════════╗
║     SYSTEM INFO MENU           ║
╠════════════════════════════════╣
║  1. Informații CPU             ║
║  2. Informații Memorie         ║
║  3. Informații Disk            ║
║  4. Procese active             ║
║  5. Ieșire                     ║
╚════════════════════════════════╝
Opțiunea ta:
```

Cerințe:
- Buclă infinită până la opțiunea 5
- Validare input (doar 1-5 acceptate)
- După fiecare opțiune, pauză și întoarcere la meniu

---

## PARTEA 5: Proiect Integrat (10%)

### System Report Generator

Fișier: `partea5_proiect/system_report.sh`

Scrie un script complet care generează un raport de sistem:

```bash
./system_report.sh [output_file]
```

Raportul trebuie să conțină:
1. Header: Data, hostname, user, uptime
2. **CPU**: Model, număr cores, load average
3. Memorie: Total, folosită, liberă (format human-readable)
4. Disk: Spațiu folosit pe partiții principale
5. Top Procese: Top 5 după CPU și top 5 după memorie
6. Rețea: IP-uri configurate
7. Footer: Timestamp generare

Cerințe:
- Dacă nu se dă argument, salvează în `report_YYYYMMDD_HHMMSS.txt`
- Formatare frumoasă cu linii și secțiuni clare
- Folosește TOATE tehnicile învățate: operatori, redirecționare, filtre, bucle
- Script solid (gestionează erori)

Exemplu output:
```
═══════════════════════════════════════════════════════════════
                    SYSTEM REPORT
═══════════════════════════════════════════════════════════════
Generated: 2025-01-19 14:30:45
Hostname:  my-server
User:      student
Uptime:    3 days, 4:23

─── CPU ───────────────────────────────────────────────────────
Model:      Intel Core i7-10700
Cores:      8
Load Avg:   0.52, 0.48, 0.45

─── MEMORY ────────────────────────────────────────────────────
Total:      16G
Used:       8.2G (51%)
Free:       7.8G

─── DISK ──────────────────────────────────────────────────────
/           45G/100G (45%)
/home       120G/500G (24%)

─── TOP 5 BY CPU ──────────────────────────────────────────────
  1. firefox        12.3%
  2. code           8.1%
  ...

─── TOP 5 BY MEMORY ───────────────────────────────────────────
  1. firefox        1.2G
  2. code           800M
  ...

─── NETWORK ───────────────────────────────────────────────────
eth0:       192.168.1.100
lo:         127.0.0.1

═══════════════════════════════════════════════════════════════
Report generated in 0.45 seconds
═══════════════════════════════════════════════════════════════
```

---

## BONUS (până la 20% extra)

### Bonus A: Pipeline Optimizer (10%)

Scrie un script care primește un pipeline și sugerează optimizări:
```bash
./pipeline_optimizer.sh "cat file | grep pattern | sort | uniq"
# Output: "Sugestie: Înlocuiește 'cat file | grep' cu 'grep pattern file'"
```

### Bonus B: Log Monitor Live (10%)

Scrie un script care monitorizează un fișier log în timp real și:

- Evidențiază liniile cu "error" în roșu
- Evidențiază liniile cu "warning" în galben
- Numără și afișează statistici la fiecare 10 linii noi


---

## REFLECTION (Obligatoriu)

Completează fișierul `REFLECTION.md` cu:

### 1. Ce am învățat
> Descrie 3 concepte noi pe care le-ai înțeles în profunzime.

### 2. Ce dificultăți am întâmpinat
> Descrie cel puțin o problemă și cum ai rezolvat-o.

### 3. Cum am folosit AI (dacă e cazul)
> Dacă ai folosit ChatGPT/Claude/Gemini:
> - Ce prompt-uri ai folosit?
> - Codul generat a funcționat direct sau ai făcut modificări?
> - Ce ai învățat din procesul de evaluare a codului AI?

### 4. Ce aș face diferit
> Dacă ar fi să refaci tema, ce ai aborda altfel?

---

## Criterii de Evaluare

| Componentă | Punctaj | Criterii |
|------------|---------|----------|
| Partea 1: Operatori | 20% | Funcționalitate, folosire corectă operatori |
| Partea 2: Redirecționare | 20% | Redirecționare corectă, here documents |
| Partea 3: Filtre | 25% | Pipeline-uri eficiente, output corect |
| Partea 4: Bucle | 25% | Bucle funcționale, gestionare erori |
| Partea 5: Proiect | 10% | Integrare, formatare, stabilitate |
| TOTAL | 100% | |
| Bonus A | +10p | Funcționalitate, acuratețe sugestii |
| Bonus B | +10p | Monitorizare live, colorare |
| MAXIM | 120% | |

### Depunctări

- Scripturi care nu sunt executabile: -5p per script
- Lipsă shebang (`#!/bin/bash`): -2p per script
- Erori de sintaxă care împiedică rularea: -10p per script
- REFLECTION.md incomplet sau lipsă: -15p
- Structură de directoare incorectă: -10p

---

## Predare

### Format

- Arhivă zip: `tema_numeprenume_grupa.zip`
- Structura exactă ca mai sus
- Toate scripturile cu permisiuni executabile


### Deadline
- [A se completa de instructor]
- -10% per zi de întârziere

### Unde
- [Platformă de upload - a se completa]

---

## Ajutor

1. Întrebări tehnice: Forum/Discord curs
2. Materiale: Consultă `S02_02_MATERIAL_PRINCIPAL.md` și `S02_09_CHEAT_SHEET_VIZUAL.md`
3. Testare: Folosește `./scripts/bash/S02_03_validator.sh tema_ta/` pentru verificare

---

*Temă pentru Seminarul 3-4 SO | ASE București - CSIE*
