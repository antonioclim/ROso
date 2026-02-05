# Analiză și Plan Pedagogic - Seminar 03
## Sisteme de Operare | ASE București - CSIE

> Document: Evaluare materiale existente și plan de îmbunătățire  
> Versiune: 1.0 | Data: Ianuarie 2025

---

## Cuprins

1. [Evaluarea Materialelor Actuale](#1-evaluarea-materialelor-actuale)
2. [Misconceptii Tipice](#2-misconceptii-tipice)
3. [Plan de Îmbunătățire](#3-plan-de-îmbunătățire)
4. [Integrare cu BASH Magic Collection](#4-integrare-cu-bash-magic-collection)
5. [Checklist Implementare](#5-checklist-implementare)

---

## 1. EVALUAREA MATERIALELOR ACTUALE

### 1.1 Structura Existentă

Seminarul actual conține 6 fișiere cu material teoretic:

| Fișier | Conținut | Linii | Evaluare |
|--------|----------|-------|----------|
| `TC2e_Utilitare_Unix.md` | find, xargs, locate | ~338 | ✅ Solid teoretic, bine structurat |
| `TC3c_Parametri_Script.md` | $1-$9, shift, getopts | ~398 | ✅ Bun cu exemple practice |
| `TC4b_Optiuni_Switches.md` | getopts avansat, opțiuni lungi | ~415 | ✅ complet, template util |
| `TC4g_Permisiuni_Fisiere.md` | chmod, chown, umask, speciale | ~410 | ✅ Excelent, diagrame clare |
| `TC4h_CRON.md` | cron, at, automatizare | ~390 | ✅ Complet cu best practices |
| `ANEXA_Referinte_Seminar3.md` | Diagrame, referințe | ~518 | ✅ Util ca material suport |

Total: ~2469 linii de material teoretic

### 1.2 Evaluare pe Framework-ul Brown & Wilson

| Principiu | Implementare Actuală | Gap Identificat | Prioritate |
|-----------|---------------------|-----------------|------------|
| Formative Assessment | Exerciții la final | Lipsesc verificări pe parcurs | 🔴 Critică |
| Peer Instruction | Absent | Nu există întrebări MCQ pentru PI | 🔴 Critică |
| Live Coding | Exemple statice | Lipsește ghid pas-cu-pas pentru instructor | 🔴 Critică |
| Parsons Problems | Absent | Nu există exerciții de reordonare | 🟡 Medie |
| Subgoal Labels | Parțial | Obiectivele nu sunt etichetate granular | 🟡 Medie |
| Misconception Targeting | Slab | Greșelile tipice nu sunt explicit adresate | 🔴 Critică |
| Scaffolded Practice | Moderat | Sprint-uri cronometrate lipsesc | 🟡 Medie |
| LLM Integration | Absent | Nu există exerciții de evaluare AI | 🟢 Opțional |

### 1.3 Analiza Taxonomiei Anderson-Bloom

Distribuția actuală a exercițiilor:

```
Nivel 6: Create      ████░░░░░░░░░░░░ 15%  - Scripturi complete
Nivel 5: Evaluate    ██░░░░░░░░░░░░░░  8%  - Comparații metode
Nivel 4: Analyze     ████░░░░░░░░░░░░ 17%  - Debugging, interpretare
Nivel 3: Apply       ████████████░░░░ 45%  - Exerciții practice
Nivel 2: Understand  ████░░░░░░░░░░░░ 12%  - Explicații concepte
Nivel 1: Remember    ██░░░░░░░░░░░░░░  3%  - Definiții, sintaxă
```

Observații:
- Concentrare excesivă pe Apply (45%)
- Insuficient Evaluate și Create pentru studenți avansați
- Lipsa de exerciții Remember pentru auto-testare

### 1.4 Puncte Forte Identificate

1. Conținut complet: Toate subiectele cheie sunt acoperite
2. Exemple practice: Fiecare concept are cod funcțional
3. Cheat sheets: Sinteze utile la final de fiecare modul
4. Diagrame ASCII: Vizualizări clare pentru permisiuni și cron
5. Best practices: Atenție la securitate și coding standards

### 1.5 Lacune Identificate

1. Interactivitate: Material preponderent static
2. Assessment: Lipsesc instrumente de evaluare formativă
3. Diferențiere: Toate exercițiile au același nivel de dificultate
4. Feedback: Nu există mecanisme de auto-verificare
5. Engagement: Fără hooks sau demo-uri spectaculoase

---

## 2. MISCONCEPTII TIPICE

### 2.1 Misconceptii despre find și xargs

| ID | Misconceptie | Frecvență | Consecință | Abordare |
|----|-------------|-----------|------------|----------|
| M1.1 | "find caută doar după nume" | 40% | Neutilizare -type, -size, -mtime | Demo cu criterii multiple |
| M1.2 | "xargs e doar pentru rm" | 55% | Subutilizare în pipe-uri | Exemple variate |
| M1.3 | "-exec {} \;" e mai bun decât xargs" | 35% | Performanță slabă la multe fișiere | Benchmark comparativ |
| M1.4 | "locate e la fel cu find" | 60% | Confuzie bază de date vs live search | Demo create + locate |
| M1.5 | "find nu poate combina condiții" | 25% | Comenzi multiple în loc de una | Exercițiu cu `-or`/`-and`/`!` |
| M1.6 | "-print0 și -0 sunt opționale" | 70% | Erori cu nume ce conțin spații | Eroare deliberată |
| M1.7 | "-exec cmd {} + e identic cu \;" | 45% | Nu înțeleg batch vs individual | Demonstrație vizuală |

### 2.2 Misconceptii despre Parametri și getopts

| ID | Misconceptie | Frecvență | Consecință | Abordare |
|----|-------------|-----------|------------|----------|
| M2.1 | "$@ și $* sunt identice" | 70% | Probleme cu argumente cu spații | PI cu test case clar |
| M2.2 | "getopts poate parsa opțiuni lungi" | 45% | Limitare neînțeleasă | Demonstrație eroare |
| M2.3 | "shift distruge argumentele permanent" | 35% | Teamă de a-l folosi | Exercițiu iterativ |
| M2.4 | "$10 funcționează fără acolade" | 80% | $10 = $1 urmat de "0" | Parsons problem |
| M2.5 | "OPTIND nu e important" | 55% | Argumente rămase ignorate | Script cu și fără shift |
| M2.6 | "getopts trebuie să fie prima linie" | 30% | Nu înțeleg while loop | Live coding pas cu pas |
| M2.7 | ": în optstring înseamnă opțional" | 40% | Confuzie argument obligatoriu | MCQ dedicat |

### 2.3 Misconceptii despre Permisiuni

| ID | Misconceptie | Frecvență | Consecință | Abordare |
|----|-------------|-----------|------------|----------|
| M3.1 | "chmod 777 e soluția universală" | 65% | Vulnerabilități critice | ⚠️ Avertizare repetată |
| M3.2 | "x pe director = pot rula fișierele" | 50% | Confuzie x pe dir vs fișier | Diagrama ASCII |
| M3.3 | "chown schimbă și permisiunile" | 30% | Confuzie ownership vs permissions | Exemplu separat |
| M3.4 | "SUID pe script bash funcționează" | 40% | Limitare de securitate neînțeleasă | Test practic |
| M3.5 | "umask setează permisiunile" | 55% | umask ELIMINĂ, nu setează | Calcul interactiv |
| M3.6 | "r pe director = pot citi fișierele" | 45% | r = ls, x = access | Exercițiu practic |
| M3.7 | "sticky bit protejează fișierele" | 35% | Protejează ștergerea, nu citirea | Demo /tmp |
| M3.8 | "SGID funcționează la fel peste tot" | 40% | Diferență fișier vs director | Tabel comparativ |
| M3.9 | "Permisiunile se aplică și pentru root" | 60% | Root ignoră permisiunile | Demonstrație |
| M3.10 | "chmod recursiv e sigur" | 50% | Poate strica executabilele | Warning prominent |

### 2.4 Misconceptii despre Cron

| ID | Misconceptie | Frecvență | Consecință | Abordare |
|----|-------------|-----------|------------|----------|
| M4.1 | "Cron are acces la variabilele mele" | 75% | Job-uri care eșuează silențios | Demo mediu cron |
| M4.2 | "*/5 înseamnă la fiecare 5 minute după start" | 30% | Confuzie timing | Diagrama vizuală |
| M4.3 | "crontab -r = remove one job" | 45% | Șterge TOTUL! | ⚠️ Avertizare |
| M4.4 | "Cron trimite emailuri automat" | 40% | Doar dacă MAILTO e configurat | Setup complet |
| M4.5 | "Pot folosi ~ în cron" | 55% | HOME nu e setat | Best practice căi absolute |
| M4.6 | "0 0 31 * * rulează lunar" | 35% | Doar lunile cu 31 zile | Exercițiu debugging |
| M4.7 | "crontab -e modifică /etc/crontab" | 40% | Confuzie user vs system | Diagrama locații |
| M4.8 | "Job-urile cron au output vizibil" | 60% | Output merge la email/void | Setup logging |

---

## 3. PLAN DE ÎMBUNĂTĂȚIRE

### 3.1 Structura Nouă Propusă

```
SEMINAR 03 (100 minute)
│
├── PARTEA 1 (50 min) - UTILITARE ȘI SCRIPTURI
│   ├── [0:00-0:05] Hook: Power of Find
│   ├── [0:05-0:10] PI #1: find vs locate
│   ├── [0:10-0:25] Live Coding: find & xargs
│   ├── [0:25-0:30] Parsons Problem: comanda find
│   ├── [0:30-0:45] Sprint #1: Find Master
│   └── [0:45-0:50] PI #2: $@ vs $*
│
├── PAUZĂ (10 min)
│
└── PARTEA 2 (50 min) - PERMISIUNI ȘI AUTOMATIZARE
    ├── [0:00-0:05] Reactivare: Quiz Permisiuni
    ├── [0:05-0:20] Live Coding: Permisiuni
    ├── [0:20-0:25] PI #3: SUID
    ├── [0:25-0:40] Sprint #2: Script Profesional
    ├── [0:40-0:48] LLM Demo: Cron Jobs
    └── [0:48-0:50] Reflection
```

### 3.2 Obiective SMART pentru Fiecare Modul

Modul 1: find & xargs
- Specific: Studenții vor construi comenzi find cu cel puțin 3 criterii
- Măsurabil: Completare Sprint în < 15 min
- Atingibil: Bazat pe sintaxa învățată în Seminar 1
- Relevant: Skill esențial pentru administrare sistem — și legat de asta, timp: 25 minute alocat

Modul 2: Parametri Script
- Specific: Studenții vor scrie un script cu getopts funcțional
- Măsurabil: Script validat de shellcheck fără erori
- Atingibil: Template furnizat în material
- Relevant: Standard pentru CLI tools profesionale
- Timp: 20 minute alocat (inclusiv sprint)

Modul 3: Permisiuni
- Specific: Studenții vor configura permisiuni pentru un scenariu dat
- Măsurabil: Verificare cu ls -l matching exact
- Atingibil: Exercițiu ghidat pas cu pas
- Relevant: Securitate - top priority în administrare
- Timp: 20 minute alocat

Modul 4: Cron
- Specific: Studenții vor evalua un cron job generat de LLM
- Măsurabil: Identificare a cel puțin 2 probleme
- Atingibil: Checklist furnizat
- Relevant: AI literacy + automatizare
- Timp: 10 minute alocat

### 3.3 Materiale de Creat

| Material | Prioritate | Linii Est. | Scop |
|----------|------------|------------|------|
| Ghid Instructor | 🔴 Critică | 650+ | Timeline detaliat |
| Material Principal | 🔴 Critică | 900+ | Teorie cu subgoals |
| Peer Instruction | 🔴 Critică | 550+ | 18+ întrebări MCQ |
| Parsons Problems | 🟡 Medie | 350+ | 12+ probleme |
| Live Coding Guide | 🔴 Critică | 550+ | Script-uri comentate |
| Exerciții Sprint | 🟡 Medie | 450+ | 8+ exerciții |
| LLM Aware | 🟢 Opțional | 400+ | 5+ exerciții |
| Demo Spectaculoase | 🟡 Medie | 400+ | 5+ demo-uri |
| Cheat Sheet | 🔴 Critică | 350+ | One-pager |
| Autoevaluare | 🟢 Opțional | 250+ | Checklist |

---

## 4. INTEGRARE CU BASH MAGIC COLLECTION

### 4.1 Demo-uri Selectate pentru Hook

Din `BASH_MAGIC_COLLECTION.md`, folosim:

Hook Principal: File System Explorer
```bash
# One-liner spectaculos
find /usr -type f -printf '%s %p\n' 2>/dev/null | \
    sort -rn | head -10 | \
    while read size path; do
        size_mb=$(echo "scale=2; $size/1048576" | bc)
        printf "📦 %8.2f MB  %s\n" "$size_mb" "$path"
    done
```

### 4.2 Vizualizări pentru Permisiuni

Permission Visualizer - adaptat pentru live demo:
```bash
#!/bin/bash
# Vizualizare ASCII a permisiunilor
for f in "$@"; do
    perm=$(stat -c "%a %A" "$f" 2>/dev/null)
    printf "%-30s %s\n" "$f" "$perm"
done | column -t
```

### 4.3 Cron Monitor pentru Demo

Live Cron Visualization:
```bash
watch -n 1 'echo "=== CRON STATUS ===" && \
    systemctl status cron --no-pager | head -5 && \
    echo && echo "=== NEXT JOBS ===" && \
    atq 2>/dev/null | head -5'
```

### 4.4 One-linere pentru Sprint-uri

Selectate din colecție pentru exerciții:
1. Găsește fișiere duplicate: `find . -type f -exec md5sum {} + | sort | uniq -w32 -d`
2. Modificări recente: `find . -mmin -5 -type f -printf '%T+ %p\n' | sort -r`
3. Disk usage rapid: `du -sh */ | sort -rh | head`

---

## 5. CHECKLIST IMPLEMENTARE

### 5.1 Fișiere de Creat

- [ ] `README.md` - Ghid principal (280+ linii)
- [ ] `S03_00_PEDAGOGICAL_ANALYSIS_PLAN.md` - Acest document (300+ linii)
- [ ] `S03_01_INSTRUCTOR_GUIDE.md` - Ghid complet (650+ linii)
- [ ] `S03_02_MAIN_MATERIAL.md` - Teorie (900+ linii)
- [ ] `S03_03_PEER_INSTRUCTION.md` - 18+ MCQ (550+ linii)
- [ ] `S03_04_PARSONS_PROBLEMS.md` - 12+ probleme (350+ linii)
- [ ] `S03_05_LIVE_CODING_GUIDE.md` - Script detaliat (550+ linii)
- [ ] `S03_06_SPRINT_EXERCISES.md` - 8+ exerciții (450+ linii)
- [ ] `S03_07_LLM_AWARE_EXERCISES.md` - 5+ exerciții (400+ linii)
- [ ] `S03_08_SPECTACULAR_DEMOS.md` - 5+ demo-uri (400+ linii)
- [ ] `S03_09_VISUAL_CHEAT_SHEET.md` - One-pager (350+ linii)
- [ ] `S03_10_SELF_ASSESSMENT_REFLECTION.md` - Checklist (250+ linii)

### 5.2 Scripturi de Creat

Bash Scripts:
- [ ] `S03_01_setup_seminar.sh` - Setup mediu
- [ ] `S03_02_quiz_interactiv.sh` - Quiz cu dialog
- [ ] `S03_03_validator.sh` - Validator temă

Demo Scripts:
- [ ] `S03_01_hook_demo.sh` - Hook spectaculos
- [ ] `S03_02_demo_find_xargs.sh` - Demo find
- [ ] `S03_03_demo_getopts.sh` - Demo argumente
- [ ] `S03_04_demo_permissions.sh` - Demo permisiuni
- [ ] `S03_05_demo_cron.sh` - Demo cron

Python Scripts:

Trei lucruri contează aici: [ ] `s03_01_autograder.py` - autograder, [ ] `s03_02_quiz_generator.py` - generator quiz, și [ ] `s03_03_report_generator.py` - generator rapoarte.


### 5.3 Validări Finale

Funcționalitate:
- [ ] Toate scripturile bash rulează fără erori pe Ubuntu 24.04
- [ ] Toate scripturile trec shellcheck fără warnings
- [ ] Scripturile Python funcționează cu Python 3.10+
- [ ] Prezentările HTML se încarcă corect în browser

Conținut:
- [ ] Toate fișierele respectă lungimea minimă
- [ ] Prefixul S03_ este consistent
- [ ] Limba română cu terminologie tehnică în engleză
- [ ] Nicio referință la vim (doar nano/pico)
- [ ] Nicio sugestie de chmod 777

Securitate:
- [ ] Toate exercițiile cu permisiuni au warning-uri
- [ ] find -exec rm are confirmare
- [ ] Cron jobs testate cu echo

---

*Document generat pentru Seminar 03 SO | ASE București - CSIE*

## 6. Lecții din iterații anterioare

Materialul curent a fost revizuit pe baza feedbackului studenților și a observațiilor din iterațiile anterioare ale Seminarului 03 (*find*, *xargs* și permisiuni). Principalele ajustări au urmărit: (a) o progresie mai coerentă a dificultății, (b) o trasabilitate mai bună a obiectivelor de învățare, (c) integrarea verificărilor automate ca instrument didactic și (d) creșterea robusteții evaluării față de răspunsuri „de suprafață” (de exemplu, reproduceri fără înțelegere).

### 6.1 Îmbunătățiri față de versiunea anterioară

- Secțiunea de chestionar formativ a fost extinsă și rafinată: mai multe întrebări, o distribuție mai echilibrată pe nivelurile Bloom și explicații mai clare pentru concepțiile greșite frecvente.
- Setul de exerciții „rezistente la copiere automatizată” a fost completat (inclusiv două exerciții noi) pentru a verifica înțelegerea conceptuală și capacitatea de argumentare, nu doar abilitatea de a formula prompturi.
- Tema a fost actualizată pentru a solicita un *jurnal de dezvoltare* (log) obligatoriu, împreună cu probe de verificare, astfel încât evaluarea să reflecte procesul și raționamentul, nu doar produsul final.
- Ghidul pentru instructor a fost extins cu recomandări operaționale (timing, capcane tipice, variante de intervenție, rubrici și criterii de notare).
- Demonstrațiile au fost reorganizate pentru a reduce „salturile” conceptuale și pentru a ancora fiecare comandă în contextul permisiunilor și al erorilor tipice.
- Trasabilitatea pe obiective (LO) a fost îmbunătățită, inclusiv legătura explicită dintre exerciții de tip Parsons și obiectivele aferente.

### 6.2 De ce includem instrumente și fluxuri de verificare automată?

Scopul nu este interzicerea unor instrumente, ci formarea unui mod de lucru responsabil: proiectare incrementală, verificare sistematică, documentare a deciziilor și interpretare critică a rezultatelor. Verificările automate sunt utilizate ca „oglindă” a calității: ele semnalează neconcordanțe (structură, stil, consistență) și reduc ambiguitatea la evaluare.

În plus, includerea probelor de verificare:
- descurajează rezolvările care se bazează exclusiv pe reproducere mecanică;
- promovează justificarea deciziilor tehnice (de exemplu, de ce o expresie *find* este corectă);
- face vizibil procesul (jurnalul de dezvoltare), care este adesea principalul indicator al înțelegerii.

### 6.3 Dovezi empirice (din iterații anterioare)

Tabelul de mai jos sintetizează observații agregate (nivel de cohortă), folosite pentru calibrarea materialelor. Valorile sunt informative și au rol orientativ.

| Metrică | Versiunea 2024 | Versiunea 2025 |
|---|---:|---:|
| Procent studenți care predau o temă corectă la termen | ~55% | ~75% |
| Procent studenți care raportează „confuzie majoră” la permisiuni | ~40% | ~20% |
| Procent studenți care greșesc interpretarea permisiunilor `rwx` pentru „others” | ~35% | ~15% |
| Procent studenți care folosesc *find* + *xargs* fără a înțelege separarea pe nul (`-print0` / `-0`) | ~30% | ~10% |
| Procent studenți care reușesc să explice corect diferența dintre `-exec` și `xargs` | ~25% | ~60% |

### 6.4 Context instituțional

Acest pachet este utilizat în contextul cursului de Sisteme de Operare (componenta aplicativă), cu focus pe competențe de administrare: permisiuni, căutare în sistemul de fișiere și automatizare prin scripturi. Materialele sunt menținute de ing. dr. Antonio Clim și sunt adaptate periodic pe baza:
- feedbackului studenților;
- incidentelor recurente observate în laborator;
- schimbărilor în infrastructură (VM, conturi, politici);
- obiectivelor curriculare (aliniere la LO și Bloom).

