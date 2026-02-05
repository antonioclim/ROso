# Tema — Seminarul 02: Operatori, redirecționare, filtre, bucle
## Sisteme de Operare | Temă practică Bash

**Fișier**: S02_01_HOMEWORK.md  
**Versiune**: 2.0 | **Dată**: ianuarie 2025  
**Durată estimată**: 2–3 ore  
**Dificultate**: medie  
**Punctaj**: 100% (+ bonus până la 20%)

---

## Obiectiv

Scopul acestei teme este să demonstrezi că poți:

- să folosești corect operatorii de control (`;`, `&&`, `||`, `&`)
- să redirecționezi intrarea/ieșirea (`>`, `>>`, `<`, `2>`, `2>&1`, here documents)
- să construiești pipeline‑uri eficiente cu filtre Unix
- să scrii bucle robuste (`for`, `while`, `until`) cu tratare de erori
- să integrezi tehnicile într‑un script complet, util în practică

---

## Structură obligatorie a directoarelor

Creează directorul temei exact ca mai jos:

```
your_assignment/
├── part1_operators/
│   ├── ex1_operators.sh
│   ├── ex2_conditional_chain.sh
│   └── ex3_background_tasks.sh
├── part2_redirection/
│   ├── ex1_safe_overwrite.sh
│   ├── ex2_error_log.sh
│   ├── ex3_merge_streams.sh
│   └── ex4_here_documents.sh
├── part3_filters/
│   ├── ex1_csv_processor.sh
│   ├── ex2_log_analyser.sh
│   ├── ex3_text_transformer.sh
│   └── ex4_pipeline_builder.sh
├── part4_loops/
│   ├── ex1_batch_processor.sh
│   ├── ex2_file_scanner.sh
│   ├── ex3_countdown.sh
│   └── ex4_menu_system.sh
├── part5_project/
│   └── system_report.sh
├── part6_verification/
│   └── proof_of_understanding.sh
├── REFLECTION.md
└── README.md
```

**Cerințe**:
- Toate scripturile trebuie să aibă shebang: `#!/bin/bash`
- Toate scripturile trebuie să fie executabile: `chmod +x file.sh`
- Respectă exact numele fișierelor (autograder‑ul se bazează pe acestea)

---

## PARTEA 1: Operatori de control (18%)

### Exercițiul 1.1: Operator showcase (6%)

Fișier: `part1_operators/ex1_operators.sh`

Scrie un script care demonstrează efectul fiecărui operator de control:

1. `;` — secvențial
2. `&&` — AND condițional (rulează doar dacă precedentul a reușit)
3. `||` — OR condițional (rulează doar dacă precedentul a eșuat)
4. `&` — execuție în background

**Cerințe**:
- Folosește comenzi reale (`echo`, `ls`, `sleep`, `false`, `true`)
- Afișează clar ce operator este demonstrat
- Include cel puțin un exemplu unde `&&` nu rulează a doua comandă
- Include cel puțin un exemplu unde `||` rulează a doua comandă

---

### Exercițiul 1.2: Conditional chain (6%)

Fișier: `part1_operators/ex2_conditional_chain.sh`

Scrie un script care simulează o secvență de verificări:

1. Verifică dacă un fișier de configurare există (`config.txt`)
2. Dacă există, verifică dacă are cel puțin 3 linii
3. Dacă are, afișează mesajul „Config valid”
4. Dacă ORICARE verificare eșuează, creează fișierul cu conținut default și afișează „Config created”

Folosește `&&` și `||` pentru a implementa logica (nu `if`).

---

### Exercițiul 1.3: Background tasks (6%)

Fișier: `part1_operators/ex3_background_tasks.sh`

Scrie un script care:

1. Pornește 3 sarcini în background (`sleep` cu durate diferite)
2. Afișează imediat „Tasks started”
3. Așteaptă finalizarea tuturor (`wait`)
4. Afișează „All tasks completed”

**Cerință**: Afișează ID‑urile proceselor (PIDs) ale sarcinilor.

---

## PARTEA 2: Redirecționare I/O (18%)

### Exercițiul 2.1: Safe overwrite (4%)

Fișier: `part2_redirection/ex1_safe_overwrite.sh`

Scrie un script care:

1. Primește un nume de fișier ca argument
2. Dacă fișierul există, cere confirmare înainte de suprascriere
3. Dacă utilizatorul confirmă, suprascrie fișierul cu textul „Overwritten at DATE”
4. Dacă utilizatorul refuză, iese fără modificări

**Cerințe**:
- Folosește `>` pentru suprascriere
- Folosește `read -p` pentru input
- Folosește `date` pentru timestamp

---

### Exercițiul 2.2: Error log (4%)

Fișier: `part2_redirection/ex2_error_log.sh`

Scrie un script care:

1. Rulează comanda `ls` pe 3 căi: una validă, una invalidă, una validă
2. Redirecționează toate erorile într‑un fișier `errors.log`
3. Redirecționează output‑ul valid într‑un fișier `output.log`
4. Afișează la final numărul de linii din fiecare fișier

Cerințe:
- Folosește `2>` pentru stderr
- Folosește `>` pentru stdout
- Folosește `wc -l` pentru număr de linii

---

### Exercițiul 2.3: Merge streams (5%)

Fișier: `part2_redirection/ex3_merge_streams.sh`

Scrie un script care:

1. Rulează o comandă care produce și output și eroare (de ex. `ls /home /nonexistent`)
2. Salvează ambele fluxuri (stdout și stderr) în același fișier `combined.log`
3. Demonstrează ambele ordine și explică într‑un comentariu care este corectă și de ce

**Cerințe**:
- Folosește `2>&1`
- Include comentariu despre importanța ordinii

---

### Exercițiul 2.4: Here documents (5%)

Fișier: `part2_redirection/ex4_here_documents.sh`

Scrie un script care:

1. Creează un fișier `template.txt` folosind un here document
2. Include variabile în template (de ex. $USER)
3. Creează al doilea fișier `literal.txt` folosind here document cu ghilimele, astfel încât variabilele să NU fie expandate

Cerințe:
- Folosește `<< EOF` și `<< 'EOF'`
- Include minimum 5 linii în fiecare fișier

---

## PARTEA 3: Filtre și pipeline‑uri (22%)

### Exercițiul 3.1: CSV processor (5%)

Fișier: `part3_filters/ex1_csv_processor.sh`

Scrie un script care procesează un fișier CSV `data.csv` cu format:

```
name,age,city
Ana,22,Bucharest
Ion,25,Cluj
Maria,22,Iasi
```

Scriptul trebuie să:

1. Extragă doar coloana de orașe
2. Sorteze orașele
3. Afișeze fiecare oraș unic împreună cu numărul de apariții

Cerințe:
- Folosește `cut`, `sort`, `uniq -c`
- Ignoră header‑ul

---

### Exercițiul 3.2: Log analyser (6%)

Fișier: `part3_filters/ex2_log_analyser.sh`

Dat un fișier `access.log` (format tipic Apache), scrie un script care:

1. Extragă adresele IP (prima coloană)
2. Calculeze top 5 IP‑uri după numărul de cereri
3. Afișeze top 3 status codes (200, 401, 403 etc.)

Cerințe:
- Folosește pipeline‑uri cu minimum 4 comenzi
- Folosește `sort -rn` pentru sortare numerică descrescătoare

---

### Exercițiul 3.3: Text transformer (5%)

Fișier: `part3_filters/ex3_text_transformer.sh`

Scrie un script care:

1. Primește un fișier text ca argument
2. Transformă toate literele mici în mari
3. Înlocuiește spațiile cu underscore `_`
4. Afișează primele 10 linii transformate

Cerințe:
- Folosește `tr`, `head`

---

### Exercițiul 3.4: Pipeline builder (6%)

Fișier: `part3_filters/ex4_pipeline_builder.sh`

Scrie un script care:

1. Primește un fișier text
2. Afișează numărul de linii
3. Afișează numărul de cuvinte
4. Afișează numărul de caractere
5. Afișează top 5 cele mai frecvente cuvinte (ignoră majuscule/minuscule)

Cerințe:
- Construiește un pipeline pentru top 5 cuvinte
- Folosește `tr`, `sort`, `uniq -c`

---

## PARTEA 4: Bucle (22%)

### Exercițiul 4.1: Batch processor (6%)

Fișier: `part4_loops/ex1_batch_processor.sh`

Scrie un script care:

1. Primește un director ca argument
2. Pentru fiecare fișier `.txt` din director:
   - afișează numele fișierului
   - afișează numărul de linii (`wc -l`)
3. Afișează la final totalul de linii din toate fișierele

Cerințe:
- Folosește o buclă `for`
- Folosește o variabilă acumulatoare

---

### Exercițiul 4.2: File scanner (5%)

Fișier: `part4_loops/ex2_file_scanner.sh`

Scrie un script care:

1. Parcurge recursiv un director
2. Pentru fiecare fișier:
   - afișează calea
   - dacă este `.txt`, afișează numărul de linii
   - dacă este `.log`, afișează primele 3 linii
3. Pentru fiecare fișier `.log`: afișează ultimele 5 linii
4. Afișează un rezumat la final

---

### Exercițiul 4.3: Countdown (5%)

Fișier: `part4_loops/ex3_countdown.sh`

Scrie un script care:

1. Primește un număr N ca argument
2. Numără invers de la N la 0 cu pauză de 1 secundă
3. Afișează „Liftoff!” la 0
4. Permite întreruperea cu Ctrl+C (afișează „Countdown aborted at X”)

---

### Exercițiul 4.4: Menu System (6%)

Fișier: `part4_loops/ex4_menu_system.sh`

Scrie un meniu interactiv:
```
=== FILE MANAGER ===
1) List files
2) Create directory
3) Delete file
4) Show disk space
5) Exit

Choose option:
```

Cerințe:
- Rulează în buclă până când utilizatorul alege Exit
- Validează input‑ul (afișează eroare pentru opțiune invalidă)
- Cere confirmare înainte de ștergere

---

## PARTEA 5: Proiect de integrare (10%)

Fișier: `part5_project/system_report.sh`

Scrie un script complet care generează un raport de sistem.

**Argumente**: fișier de output opțional (implicit: `report_YYYYMMDD_HHMMSS.txt`)

**Secțiuni**:
1. Header: data, hostname, utilizator, uptime
2. **CPU**: model, număr de core‑uri, load average
3. Memorie: total, folosit, liber (format ușor de citit)
4. Disk: spațiu utilizat pe partițiile principale
5. Procese de top: top 5 după CPU și top 5 după memorie
6. Rețea: IP‑urile configurate
7. Footer: timestamp de generare

Cerințe:
- Dacă nu se oferă argument, salvează în `report_YYYYMMDD_HHMMSS.txt`
- Formatare plăcută cu linii și secțiuni clare
- Folosește TOATE tehnicile învățate: operatori, redirecționare, filtre, bucle
- Script robust (tratează erorile)

---

## PARTEA 6: Verificare de înțelegere (5%)

**Această secțiune verifică faptul că înțelegi codul pe care îl predai.**

### Exercițiul 6.1: Script de dovadă locală (3%)

Fișier: `part6_verification/proof_of_understanding.sh`

Creează un script care generează dovada că ai lucrat local la temă:

```bash
#!/bin/bash
# proof_of_understanding.sh
# This script generates evidence of local work

echo "=== ASSIGNMENT VERIFICATION ===" > local_proof.txt
echo "Generated: $(date '+%Y-%m-%d %H:%M:%S')" >> local_proof.txt
echo "Hostname: $(hostname)" >> local_proof.txt
echo "Username: $(whoami)" >> local_proof.txt
echo "Working directory: $(pwd)" >> local_proof.txt
echo "MAC address: $(ip link show 2>/dev/null | grep ether | head -1 | awk '{print $2}')" >> local_proof.txt
echo "" >> local_proof.txt

# List YOUR assignment files with their sizes
echo "=== YOUR ASSIGNMENT FILES ===" >> local_proof.txt
find .. -name "*.sh" -exec ls -la {} \; >> local_proof.txt 2>/dev/null

# Show recent bash history (last 20 commands) - proves you worked in terminal
echo "" >> local_proof.txt
echo "=== RECENT TERMINAL ACTIVITY ===" >> local_proof.txt
tail -20 ~/.bash_history >> local_proof.txt 2>/dev/null || echo "History unavailable" >> local_proof.txt

echo "Proof generated: local_proof.txt"
```

**Cerințe**:
- Rulează acest script din interiorul directorului temei
- Predă fișierul generat `local_proof.txt`
- Adresa MAC și hostname‑ul vor fi verificate pentru consistență

### Exercițiul 6.2: Explicație orală (2%)

**La predare sau în timpul laboratorului, ți se va cere să explici UNUL dintre următoarele concepte din codul tău. Fii pregătit(ă) să răspunzi FĂRĂ să consulți notițe.**

Întrebări posibile (instructorul va alege una la întâmplare):

1. „În `ex1_backup_safe.sh`, explică DE CE contează ordinea lui `&&` și `||`. Ce s‑ar întâmpla dacă ai inversa ordinea?”

2. „În `ex2_config_generator.sh`, care este diferența dintre `<< EOF` și `<< 'EOF'`? Arată-mi în cod unde ai folosit fiecare și de ce.”

3. „În `ex3_log_stats.sh`, de ce ai nevoie de `sort` înainte de `uniq -c`? Ce s‑ar întâmpla fără `sort`?”

4. „În `ex4_menu_system.sh`, explică capcana subshell‑ului cu `while read`. Ai întâlnit-o? Cum ai rezolvat-o?”

5. „În `system_report.sh`, arată-mi cum ai tratat cazul în care o comandă eșuează. Ce se întâmplă cu raportul?”

**Notare**:
- Explicație clară și corectă: 2%
- Înțelegere parțială: 1%
- Nu îți poți explica propriul cod: 0% (și declanșează revizuirea întregii predări)

---

## BONUS (până la 20% extra)

### Bonus A: Optimizator de pipeline‑uri (10%)

Scrie un script care primește un pipeline și sugerează optimizări:
```bash
./pipeline_optimizer.sh "cat file | grep pattern | sort | uniq"
# Output: "Suggestion: Replace 'cat file | grep' with 'grep pattern file'"
```

### Bonus B: Monitor live de log (10%)

Scrie un script care monitorizează un fișier de log în timp real și:

- Evidențiază liniile cu „error” în roșu
- Evidențiază liniile cu „warning” în galben
- Numără și afișează statistici la fiecare 10 linii noi

---

## REFLECTION (Obligatoriu)

Completează fișierul `REFLECTION.md` cu:

### 1. Ce am învățat
> Descrie 3 concepte noi pe care le-ai înțeles în profunzime.

### 2. Ce dificultăți am întâmpinat
> Descrie cel puțin o problemă și cum ai rezolvat-o.

### 3. Cum am folosit AI (dacă este cazul)
> Dacă ai folosit ChatGPT/Claude/Gemini:
> - Ce prompturi ai folosit?
> - Codul generat a mers direct sau ai făcut modificări?
> - Ce ai învățat din procesul de evaluare critică a codului generat?

### 4. Ce aș face diferit
> Dacă ai reface tema, ce ai aborda diferit?

---

## Criterii de evaluare

| Componentă | Punctaj | Criterii |
|-----------|-------|----------|
| Partea 1: Operatori | 18% | Funcționalitate, utilizare corectă a operatorilor |
| Partea 2: Redirecționare | 18% | Redirecționare corectă, here documents |
| Partea 3: Filtre | 22% | Pipeline‑uri eficiente, output corect |
| Partea 4: Bucle | 22% | Bucle funcționale, tratare erori |
| Partea 5: Proiect | 10% | Integrare, formatare, stabilitate |
| Partea 6: Verificare | 5% | Script dovadă + explicație orală |
| REFLECTION.md | 5% | Reflecție atentă |
| TOTAL | 100% | |
| Bonus A | +10p | Funcționalitate, acuratețea sugestiei |
| Bonus B | +10p | Monitorizare live, colorare |
| MAXIM | 120% | |

### Penalizări

- Scripturi neexecutabile: -5p per script
- Lipsă shebang (`#!/bin/bash`): -2p per script
- Erori de sintaxă care împiedică execuția: -10p per script
- REFLECTION.md incomplet/lipsă: -15p
- Structură de directoare incorectă: -10p
- Lipsă verificare Partea 6: -5p
- Nu îți poți explica propriul cod la verificarea orală: revizuire integrală

---

## Predare

### Format

- Arhivă zip: `assignment_firstnamelastname_group.zip`
- Structură exact ca mai sus
- Toate scripturile cu permisiuni de execuție
- `local_proof.txt` generat și inclus

### Deadline
- [De completat de instructor]
- -10% per zi întârziere

### Unde
- [Platformă de încărcare — de completat]

---

## Ajutor

1. Întrebări tehnice: forumul cursului / Discord
2. Materiale: consultă `S02_02_MAIN_MATERIAL.md` și `S02_09_VISUAL_CHEAT_SHEET.md`
3. Testare: folosește `./scripts/bash/S02_03_validator.sh your_assignment/` pentru verificare

---

*Temă pentru Seminarul 3-4 SO | ASE Bucharest - CSIE*
