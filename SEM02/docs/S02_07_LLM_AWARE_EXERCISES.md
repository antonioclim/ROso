# Exerciții LLM-Aware - Seminarul 3-4
## Sisteme de Operare | Operatori, Redirecționare, Filtre, Bucle

Versiune: 1.0 | Filozofie: Integrarea critică a AI în procesul de învățare  
Competență vizată: Evaluarea și îmbunătățirea codului generat de LLM-uri

---

## FILOZOFIA ACESTOR EXERCIȚII

### De Ce LLM-Aware?

În era inteligenței artificiale generative (ChatGPT, Claude, Gemini, Copilot), paradigma educațională se modifică fundamental:

```
╔════════════════════════════════════════════════════════════════════╗
║  PARADIGMA VECHE              →     PARADIGMA NOUĂ                 ║
╠════════════════════════════════════════════════════════════════════╣
║  Memorare sintaxă             →     Înțelegere concepte            ║
║  Scriere cod de la zero       →     Evaluare cod generat           ║
║  "Nu ai voie să copiezi"      →     "Folosește AI inteligent"      ║
║  Testare cunoștințe factuale  →     Testare gândire critică        ║
║  Studentul = executor         →     Studentul = EVALUATOR          ║
╚════════════════════════════════════════════════════════════════════╝
```

### Competențe Dezvoltate

| Competență | Descriere | De ce e importantă |
|------------|-----------|-------------------|
| Evaluare critică | Identifică greșeli și constrângeri în cod AI | AI-ul face greșeli subtile |
| Prompt engineering | Formulează cereri eficiente | Calitatea output-ului depinde de input |
| Debugging AI | Corectează cod generat | Integrare în workflow real |
| Discernământ | Știe când să folosească/evite AI | Eficiență și etică |
| Meta-învățare | Învață prin evaluare, nu doar execuție | Înțelegere profundă |

---

## REGULI PENTRU EXERCIȚII LLM

```
╔════════════════════════════════════════════════════════════════════╗
║  📋 REGULI EXERCIȚII LLM-AWARE                                     ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  1. POȚI folosi orice LLM: ChatGPT, Claude, Gemini, Copilot       ║
║                                                                    ║
║  2. NU copiezi direct - EVALUEZI și ÎMBUNĂTĂȚEȘTI                  ║
║                                                                    ║
║  3. DOCUMENTEZI:                                                   ║
║     • Ce prompt ai folosit                                         ║
║     • Ce a generat AI-ul                                           ║
║     • Ce probleme ai găsit                                         ║
║     • Cum ai corectat                                              ║
║                                                                    ║
║  4. TESTEZI EFECTIV - nu presupui că funcționează                  ║
║                                                                    ║
║  5. REFLECTEZI - ce ai învățat despre limitările AI?               ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

---

## EXERCIȚIU L1: Evaluatorul de Pipelines

Durată: 10 min | Mod: Individual | Nivel: ⭐⭐

### Obiectiv
Evaluează critic pipeline-uri generate de AI pentru analiza fișierelor de log.

### Partea 1: Generare (3 min)

Folosește următorul prompt cu un LLM la alegere:

```
PROMPT:
Generează 5 pipeline-uri Linux diferite care analizează fișierul 
/var/log/syslog (sau orice fișier de log) și extrag informații utile.
Fiecare pipeline să folosească minim 3 comenzi conectate cu pipe.
Explică ce face fiecare.
```

### Partea 2: Evaluare Critică (5 min)

Pentru FIECARE pipeline generat, completează tabelul:

```
╔════════════════════════════════════════════════════════════════════╗
║  EVALUARE PIPELINE #___                                            ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  Pipeline: ________________________________________________        ║
║  ________________________________________________________________  ║
║                                                                    ║
║  □ Funcționează? (testează efectiv!)                               ║
║    └─ Dacă NU, ce eroare?  _____________________________________   ║
║                                                                    ║
║  □ Output corect și util?                                          ║
║    └─ Ce produce? ____________________________________________     ║
║                                                                    ║
║  □ Eficient?                                                       ║
║    └─ Există alternativă mai simplă? __________________________    ║
║                                                                    ║
║  □ Explicația AI e corectă?                                        ║
║    └─ Ce a greșit/omis? ______________________________________     ║
║                                                                    ║
║  Scor (1-5): ___                                                   ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

### Partea 3: Reflecție (2 min)

Scrie în fișierul `L1_REFLECTION.txt`:

```bash
cat > L1_REFLECTION.txt << 'EOF'
=== REFLECȚIE EXERCIȚIU L1 ===

1. Cel mai util pipeline a fost #___ pentru că:
   

2. Erori făcute de LLM:
   

3. Cum aș îmbunătăți promptul:
   

4. Ce am învățat despre limitările AI în Bash:
   

EOF
nano L1_REFLECTION.txt
```

### Grading Rubric

| Criteriu | Puncte |
|----------|--------|
| Testare efectivă a tuturor pipeline-urilor | 4p |
| Identificare corectă funcționalitate | 3p |
| Găsire cel puțin 2 probleme/îmbunătățiri | 3p |
| Reflecție substanțială | 2p |
| Total | 12p |

---

## EXERCIȚIU L2: Debuggerul de Scripturi AI

Durată: 15 min | Mod: Perechi | Nivel: ⭐⭐⭐

### Obiectiv
Identifică și corectează probleme în scripturi generate de AI.

### Setup

Cere unui LLM să genereze un script cu acest prompt:

```
PROMPT:
Scrie un script bash complet care:
1. Primește un director ca argument
2. Pentru fiecare fișier .txt din director:
   - Numără liniile
   - Numără cuvintele
   - Calculează dimensiunea în KB
3. Afișează un raport formatat frumos
4. Salvează raportul în report.txt
5. La final afișează totalurile
```

### Sarcină de Evaluare

Pas 1: Creează un director de test cu edge cases:

```bash
# Setup director de test
mkdir -p test_dir
echo "Hello World" > "test_dir/normal.txt"
echo "Test" > "test_dir/file with spaces.txt"
echo "" > "test_dir/empty.txt"
echo -e "Line1\nLine2\nLine3" > "test_dir/multiline.txt"
touch "test_dir/.hidden.txt"
mkdir "test_dir/subdir"
echo "nested" > "test_dir/subdir/nested.txt"
```

Pas 2: Testează scriptul AI și completează checklist-ul:

```
╔════════════════════════════════════════════════════════════════════╗
║  CHECKLIST DEBUGGING SCRIPT AI                                     ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  FUNCȚIONALITATE DE BAZĂ:                                          ║
║  □ Rulează fără erori de sintaxă?                                  ║
║  □ Procesează fișierele normale corect?                            ║
║  □ Calculele (linii, cuvinte, size) sunt corecte?                  ║
║                                                                    ║
║  EDGE CASES:                                                       ║
║  □ Gestionează fișiere cu spații în nume?                          ║
║  □ Gestionează fișier gol (empty.txt)?                             ║
║  □ Ignoră directoarele (subdir/)?                                  ║
║  □ Gestionează fișiere ascunse (.hidden.txt)?                      ║
║  □ Ce face dacă directorul nu există?                              ║
║  □ Ce face dacă nu există fișiere .txt?                            ║
║                                                                    ║
║  ROBUSTEȚE:                                                        ║
║  □ Verifică dacă argumentul e furnizat?                            ║
║  □ Verifică dacă argumentul e un director valid?                   ║
║  □ Are shebang corect (#!/bin/bash)?                               ║
║  □ Folosește quoting corect pentru variabile?                      ║
║                                                                    ║
║  OUTPUT:                                                           ║
║  □ Creează report.txt corect?                                      ║
║  □ Afișează totaluri la final?                                     ║
║  □ Formatarea e clară și lizibilă?                                 ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

Pas 3: Documentează problemele găsite:

```bash
cat > L2_BUGS_FOUND.txt << 'EOF'
=== PROBLEME GĂSITE ÎN SCRIPT AI ===

PROBLEMA 1:
- Descriere: 
- Linia afectată: 
- Impact: 
- Fix propus: 

PROBLEMA 2:
- Descriere: 
- Linia afectată: 
- Impact: 
- Fix propus: 

[...]

EOF
nano L2_BUGS_FOUND.txt
```

Pas 4: Scrie versiunea corectată:

```bash
nano L2_FIXED_SCRIPT.sh
# Implementează toate fix-urile identificate
```

### Probleme Comune în Scripturi AI (pentru referință)

| Problemă | Frecvență | Exemplu |
|----------|-----------|---------|
| Quoting incorect | 90% | `$file` vs `"$file"` |
| Nu verifică argumente | 85% | Lipsa `[[ -z "$1" ]]` |
| Presupune că fișierele există | 80% | Lipsa verificări |
| for loop periculos | 75% | `for f in *` vs `for f in ./*` |
| Nu gestionează spații | 70% | `for f in $(ls)` |
| Exit codes ignorate | 65% | Nu verifică succes comenzi |

---

## EXERCIȚIU L3: Promptul Perfect

Durată: 12 min | Mod: Individual | Nivel: ⭐⭐

### Obiectiv
Găsește promptul minim și eficient care generează un script funcțional complet.

### Cerință Finală a Scriptului

Un script care:
- Monitorizează un fișier log în timp real
- Când detectează cuvântul "ERROR", afișează alertă
- Rulează în fundal
- Poate fi oprit grațios cu SIGTERM
- Logează activitatea proprie

### Proces Iterativ

Iterația 1 - Prompt vag (2 min):
```
PROMPT V1: "Scrie un script de monitorizare log"

REZULTAT:
[copiază ce a generat]

EVALUARE:
- Ce funcționează: 
- Ce lipsește: 
- Scor: __/10
```

Iterația 2 - Prompt îmbunătățit (2 min):
```
PROMPT V2: "[adaugă detaliile care au lipsit]"

REZULTAT:
[copiază ce a generat]

EVALUARE:
- Ce s-a îmbunătățit: 
- Ce încă lipsește: 
- Scor: __/10
```

Iterația 3 - Prompt precis (2 min):
```
PROMPT V3: "[rafinează și mai mult]"

REZULTAT:
[copiază ce a generat]

EVALUARE:
- Complet? 
- Funcțional? 
- Scor: __/10
```

### Concluzie (4 min)

Documentează formula pentru un prompt eficient:

```bash
cat > L3_PROMPT_FORMULA.txt << 'EOF'
=== FORMULA PROMPT EFICIENT ===

STRUCTURĂ RECOMANDATĂ:
1. Context: [ce face scriptul]
2. Input: [ce primește]
3. Output: [ce produce]
4. Constraints: [restricții, cerințe speciale]
5. Error handling: [cum gestionează erori]
6. Examples: [exemple concrete dacă e util]

PROMPT FINAL OPTIM (cât mai scurt, dar complet):
"""
[scrie aici promptul tău optim]
"""

CE AM ÎNVĂȚAT:
- Un prompt prea vag produce: 
- Elementele esențiale sunt: 
- Lungimea optimă pare să fie: 

EOF
nano L3_PROMPT_FORMULA.txt
```

---

## EXERCIȚIU L4: Code Review Comparativ

Durată: 10 min | Mod: Individual | Nivel: ⭐⭐

### Obiectiv
Compară capacitatea ta de code review cu cea a AI-ului.

### Cod de Analizat

```bash
#!/bin/bash
# Backup script

for f in *; do
    cp $f backup_$f
done
echo Done
```

### Partea 1: Review-ul TĂU (4 min)

Înainte de a folosi AI, listează TOATE problemele pe care le identifici:

```bash
cat > L4_MY_REVIEW.txt << 'EOF'
=== MY CODE REVIEW ===

PROBLEME IDENTIFICATE:

1. [Problemă]: 
   [Severitate]: Critical / Major / Minor
   [Fix]: 

2. [Problemă]: 
   [Severitate]: 
   [Fix]: 

[...]

TOTAL PROBLEME GĂSITE: ___

EOF
nano L4_MY_REVIEW.txt
```

### Partea 2: Review-ul AI (3 min)

Acum cere unui LLM:
```
PROMPT: Fă un code review detaliat pentru acest script bash și identifică 
toate problemele, inclusiv edge cases și best practices nerespectate:

[copiază scriptul]
```

Salvează rezultatul în `L4_AI_REVIEW.txt`.

### Partea 3: Comparație (3 min)

```bash
cat > L4_COMPARISON.txt << 'EOF'
=== COMPARAȚIE REVIEW ===

CE AM GĂSIT EU DAR AI-UL NU:
1. 
2. 

CE A GĂSIT AI-UL DAR EU NU:
1. 
2. 

CINE A FOST MAI COMPLET? □ Eu  □ AI  □ Similar

CONCLUZIE:
AI-ul e mai bun la: 
Eu sunt mai bun la: 
Strategia optimă de review: 

EOF
nano L4_COMPARISON.txt
```

### Toate Problemele din Script (pentru instructor)

| # | Problemă | Severitate | Explicație |
|---|----------|------------|------------|
| 1 | `$f` fără ghilimele | Critical | Eșuează pentru fișiere cu spații |
| 2 | `for f in *` periculos | Major | Include directoare, nu doar fișiere |
| 3 | Nu verifică succes cp | Major | Erori silențioase |
| 4 | `backup_$f` poate suprascrie | Major | Nu verifică dacă există |
| 5 | Nu exclude backup_* | Minor | Poate crea backup_backup_... |
| 6 | Shebang ok dar fără set -e | Minor | Continuă la erori |
| 7 | Mesaj "Done" necondiționat | Minor | Afișat și la eșec |
| 8 | Nu logează ce face | Minor | Debugging dificil |
| 9 | Nu are help/usage | Minor | UX slab |
| 10 | Hardcoded * | Minor | Nu e configurabil |

---

## EXERCIȚIU L5: Translator Bash ↔ Python

Durată: 12 min | Mod: Perechi | Nivel: ⭐⭐⭐

### Obiectiv
Evaluează capacitatea AI de a traduce între limbaje, păstrând funcționalitatea.

### Script Python de Tradus

```python
#!/usr/bin/env python3
import sys
from collections import Counter

if len(sys.argv) < 2:
    print("Usage: script.py <filename>")
    sys.exit(1)

filename = sys.argv[1]
try:
    with open(filename) as f:
        words = f.read().lower().split()
        for word, count in Counter(words).most_common(10):
            print(f"{count:4d} {word}")
except FileNotFoundError:
    print(f"Error: {filename} not found")
    sys.exit(1)
```

### Sarcină

Pas 1: Cere traducerea în Bash:
```
PROMPT: Traduce acest script Python în Bash, păstrând exact aceeași 
funcționalitate, inclusiv error handling și formatare output.
```

Pas 2: Testează ambele versiuni:

```bash
# Creează fișier de test
echo "the quick brown fox jumps over the lazy dog the fox" > test.txt

# Testează Python
python3 original.py test.txt > output_python.txt

# Testează Bash (versiunea AI)
bash translated.sh test.txt > output_bash.txt

# Compară
diff output_python.txt output_bash.txt
```

Pas 3: Documentează diferențele:

```
╔════════════════════════════════════════════════════════════════════╗
║  COMPARAȚIE TRADUCERE                                              ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  FUNCȚIONALITATE:                                                  ║
║  □ Output identic pentru input normal?                             ║
║  □ Error handling echivalent?                                      ║
║  □ Exit codes corecte?                                             ║
║                                                                    ║
║  CE A PIERDUT TRADUCEREA:                                          ║
║  1. ________________________________________________               ║
║  2. ________________________________________________               ║
║                                                                    ║
║  CE A CÂȘTIGAT/E DIFERIT:                                          ║
║  1. ________________________________________________               ║
║  2. ________________________________________________               ║
║                                                                    ║
║  CARE E MAI ELEGANTĂ?                                              ║
║  □ Python  □ Bash  □ Depinde de context                            ║
║                                                                    ║
║  CÂND AȘ FOLOSI FIECARE?                                           ║
║  Python: ________________________________________________          ║
║  Bash: __________________________________________________          ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

---

## MATRICEA COMPETENȚELOR LLM

La finalul acestor exerciții, ar trebui să poți evalua:

| Competență | Nivel Actual | Exercițiu Relevant |
|------------|--------------|-------------------|
| Evaluare critică cod AI | □ Începător □ Mediu □ Avansat | L1, L2 |
| Prompt engineering | □ Începător □ Mediu □ Avansat | L3 |
| Debugging AI output | □ Începător □ Mediu □ Avansat | L2, L4 |
| Comparare Human vs AI | □ Începător □ Mediu □ Avansat | L4 |
| Înțelegere constrângeri AI | □ Începător □ Mediu □ Avansat | Toate |

---

## CONCLUZIE: CÂND SĂ FOLOSEȘTI AI

```
╔════════════════════════════════════════════════════════════════════╗
║  ✓ FOLOSEȘTE AI PENTRU:                                            ║
╠════════════════════════════════════════════════════════════════════╣
║  • Generare boilerplate / structură inițială                       ║
║  • Explorare opțiuni / "cum aș putea face X?"                      ║
║  • Debugging sugestii (dar verifică!)                              ║
║  • Documentare cod existent                                        ║
║  • Traducere între limbaje (cu verificare)                         ║
║  • Explicații concepte                                             ║
╠════════════════════════════════════════════════════════════════════╣
║  ✗ EVITĂ AI PENTRU:                                                ║
╠════════════════════════════════════════════════════════════════════╣
║  • Cod critic fără review manual                                   ║
║  • Securitate și autentificare                                     ║
║  • Presupuneri despre existența fișierelor/comenzilor              ║
║  • Logică de business complexă                                     ║
║  • Când nu poți verifica corectitudinea                            ║
╠════════════════════════════════════════════════════════════════════╣
║  🔑 REGULA DE AUR: AI e un ASISTENT, nu un ÎNLOCUITOR              ║
║     Tu rămâi RESPONSABIL pentru cod!                               ║
╚════════════════════════════════════════════════════════════════════╝
```

---

## REFLECȚIE FINALĂ

Completează la finalul tuturor exercițiilor:

```bash
cat > LLM_FINAL_REFLECTION.txt << 'EOF'
=== REFLECȚIE FINALĂ: AI ÎN PROGRAMARE ===

1. Cel mai mare avantaj al folosirii AI pentru cod:
   

2. Cea mai mare limitare/pericol:
   

3. Cum voi integra AI în workflow-ul meu de lucru:
   

4. Ce fel de sarcini voi da mereu AI-ului:
   

5. Ce fel de sarcini NU voi da niciodată AI-ului fără verificare:
   

6. Nota mea pentru AI ca asistent de programare (1-10): ___

7. Mesaj pentru mine din viitor despre folosirea AI:
   

EOF
nano LLM_FINAL_REFLECTION.txt
```

---

*Document generat pentru Seminarul 3-4 SO | ASE București - CSIE*  
*Exerciții pentru integrarea critică a AI în procesul de învățare*
