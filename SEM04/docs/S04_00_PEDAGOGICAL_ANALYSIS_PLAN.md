# Analiză și Plan Pedagogic - Seminar 4
## Sisteme de Operare | Text Processing - Regex, GREP, SED, AWK

> Observație din laborator: notează-ți comenzi‑cheie și output‑ul relevant (2–3 linii) pe măsură ce lucrezi. Te ajută la debug și, sincer, la final îți iese și un README bun fără efort suplimentar.
> Document intern pentru instructori  
> Versiune: 1.0 | Data: Ianuarie 2025

---

## Cuprins

1. [Evaluarea Materialelor Actuale](#1-evaluarea-materialelor-actuale)
2. [Misconcepții Tipice](#2-misconcepții-tipice)
3. [Plan de Îmbunătățire](#3-plan-de-îmbunătățire)
4. [Integrare cu Resursele Existente](#4-integrare-cu-resursele-existente)
5. [Checklist Implementare](#5-checklist-implementare)

---

## 1. EVALUAREA MATERIALELOR ACTUALE

### 1.1 Inventarul Materialelor Primite

| Fișier | Conținut | Linii | Calitate | Utilizare |
|--------|----------|-------|----------|-----------|
| `TC2f_Expresii_Regulate.md` | Regex BRE/ERE/PCRE complet | ~354 | ⭐⭐⭐⭐⭐ Excelent | ✅ Integral |
| `TC4c_AWK.md` | AWK - procesare structurată | ~367 | ⭐⭐⭐⭐⭐ Excelent | ✅ Integral |
| `TC4d_SED.md` | SED - stream editor | ~302 | ⭐⭐⭐⭐ Foarte bun | ✅ Integral |
| `TC4e_GREP.md` | Familia grep completă | ~325 | ⭐⭐⭐⭐⭐ Excelent | ✅ Integral |
| `TC4f_VI_VIM.md` | VI/VIM editor | ~368 | ⭐⭐⭐⭐ Foarte bun | ⚠️ ÎNLOCUIT |
| `ANEXA_Referinte_Seminar4.md` | Diagrame și exerciții | ~518 | ⭐⭐⭐⭐⭐ Excelent | ✅ Parțial |

Total material utilizabil: ~1866 linii (excluzând vim)
Total material ignorat: ~368 linii (TC4f_VI_VIM.md)

### 1.2 Analiza Detaliată per Fișier

#### TC2f_Expresii_Regulate.md

Puncte forte:
- Acoperire completă a metacaracterelor
- Diferențiere clară BRE vs ERE vs PCRE
- Exemple practice pentru fiecare concept
- Cheat sheet bine structurat

Lacune identificate:
- Lipsesc exemple de pattern-uri pentru log-uri web și exerciții de debugging
- Nu menționează regex101.com ca resursă de testare

Recomandări:
- Adaugă secțiune despre greedy vs lazy matching
- Include exemple cu anchors în context real (^ și $ în log parsing)
- Extinde secțiunea de validare cu formate specifice: URL, date în format RO
- Adaugă link către regex101.com pentru testare interactivă

#### TC4c_AWK.md

Puncte forte:
- Model de execuție explicat clar (pattern { action })
- BEGIN/END bine documentate
- Arrays asociative cu exemple utile
- Funcții built-in complete

Lacune identificate:
- Lipsesc exemple cu multiple fișiere (FNR vs NR) și formatare printf avansată
- OFS/ORS insuficient acoperite pentru procesare CSV

Recomandări:
- Adaugă secțiune despre procesare CSV cu header (skip prima linie, NR>1)
- Include exemple de rapoarte formatate cu printf
- Demonstrează pivot tables simple și agregări
- Adaugă exercițiu de conversie date (timestamp → human readable)

#### TC4d_SED.md

Puncte forte:
- Comanda s/// bine explicată
- Adresare completă (număr, pattern, range)
- Comenzi alternative (d, p, i, a, c)
- Exemple practice utile

Lacune identificate:
- Lipsesc exemple cu multiple comenzi în fișier script sed
- Backreferences (& și \1...\9) necesită documentare extinsă

Recomandări:

- Adaugă secțiune despre `sed -i` cu avertismente
- Include pattern-uri pentru procesare config files
- Demonstrează modificări batch pe multiple fișiere


#### TC4e_GREP.md

Puncte forte:
- Variante grep/egrep/fgrep explicate
- Opțiuni complete (-i, -v, -n, -c, -o, -r)
- Context (-A, -B, -C) bine documentat
- Exit codes pentru scripting

Lacune identificate:
- Lipsesc exemple cu --include/--exclude pentru căutare în cod sursă
- Pipeline-uri grep | sort | uniq -c insuficient demonstrate

Recomandări:
- Adaugă secțiune despre grep recursiv în cod sursă
- Include exemple de analiză log-uri (access.log, syslog)
- Demonstrează combinații grep | sort | uniq -c
- Salvează o copie de backup dacă modifici fișiere importante

### 1.3 Decizia Critică: Nano în loc de Vim

#### Argumentație Pedagogică

De ce înlocuim Vim cu Nano?

| Criteriu | Vim | Nano | Câștigător |
|----------|-----|------|------------|
| Curba de învățare | Abruptă (ore/zile) | Zero (minute) | Nano |
| Interfață intuitivă | Moduri ascunse | Comenzi afișate | Nano |
| Focus pe conținut | Distras de editor | Pe task | Nano |
| Experiență inițială | Frustrantă | Pozitivă | Nano |
| Disponibilitate | Universal | Universal | Egal |
| Eficiență (avansat) | Superioară | Adecvată | Vim |

Concluzie: Pentru un curs introductiv de SO unde editarea este auxiliară (nu scopul principal), Nano este alegerea optimă.

#### Ce pierdem renunțând la Vim?

1. Eficiență pentru power users - dar studenții nu sunt power users
2. "Street cred" sysadmin - dar nu e scopul cursului
3. Ubiquitate pe servere legacy - nano e prezent pe majoritatea sistemelor moderne
4. Editare modală avansată - dar complexitatea depășește nevoile cursului

#### Ce câștigăm cu Nano?

1. Timp recuperat - 45+ minute salvate pentru alte concepte
2. Studenți nefrustrati - pot începe imediat
3. Focus pe procesare text - grep/sed/awk primesc atenția cuvenită
4. Curba de învățare lină - nu mai există "blocker" la editor

---

## 2. MISCONCEPȚII TIPICE

### 2.1 Misconcepții despre Expresii Regulate

| ID | Misconcepție | Frecvență | Consecință | Clarificare |
|----|--------------|-----------|------------|-------------|
| M1.1 | "`*` înseamnă orice caracter" | 70% | Confuzie cu shell globbing | `*` = zero sau mai multe din precedent; `.*` = orice |
| M1.2 | "`.` potrivește și newline" | 50% | Pattern-uri incomplete | `.` nu potrivește `\n` implicit |
| M1.3 | "BRE și ERE sunt identice" | 60% | Erori de sintaxă | BRE: `\+`, ERE: `+` |
| M1.4 | "`[^abc]` înseamnă începutul liniei" | 55% | Confuzie context `^` | În `[]`, `^` = negație; solo, `^` = început |
| M1.5 | "Quantificatorii sunt lazy implicit" | 40% | Match-uri prea lungi | Implicit sunt **greedy** |
| M1.6 | "`\d` funcționează în grep" | 65% | Pattern-uri greșite | `\d` e PCRE; în ERE folosește `[0-9]` |
| M1.7 | "Spațiu în regex e ignorat" | 35% | Potriviri greșite | Spațiul este caracter literal |
| M1.8 | "`[a-Z]` include toate literele" | 45% | Include și caractere speciale | Corect: `[a-zA-Z]` |
| M1.9 | "Regex sunt case-sensitive opțional" | 30% | Ignoră -i flag | Implicit sunt case-sensitive |

### 2.2 Misconcepții despre GREP

| ID | Misconcepție | Frecvență | Consecință | Clarificare |
|----|--------------|-----------|------------|-------------|
| M2.1 | "grep -E și egrep sunt diferite" | 45% | Confuzie sintaxă | Sunt **identice** |
| M2.2 | "grep returnează fișierul întreg" | 30% | Așteptări greșite | Returnează doar **liniile** potrivite |
| M2.3 | "grep -o returnează linia" | 50% | Output neașteptat | Returnează doar **match-ul** |
| M2.4 | "grep caută în subdirectoare automat" | 40% | Rezultate incomplete | Necesită `-r` sau `-R` |
| M2.5 | "grep -c numără caractere" | 35% | Statistici greșite | Numără **linii** cu potriviri |
| M2.6 | "grep -v grep în ps e hack" | 25% | Cod fragil | Tehnica `[p]attern` e mai elegantă |
| M2.7 | "grep -l afișează și liniile" | 30% | Surpriză la output | Afișează doar numele fișierelor |

### 2.3 Misconcepții despre SED

| ID | Misconcepție | Frecvență | Consecință | Clarificare |
|----|--------------|-----------|------------|-------------|
| M3.1 | "sed modifică fișierul direct" | 75% | Fișier neschimbat | Scrie la **stdout**; `-i` pentru in-place |
| M3.2 | "`s/old/new/` înlocuiește toate" | 80% | Doar prima schimbată | Fără `/g`, doar prima pe linie |
| M3.3 | "sed -i e sigur" | 45% | Pierdere date | Fără backup = risc; folosește `-i.bak` |
| M3.4 | "Delimitatorul trebuie să fie `/`" | 35% | Escape-uri complicate | Orice caracter merge: `s|old|new|` |
| M3.5 | "`&` în replacement e literal" | 60% | Înlocuiri greșite | `&` = întregul match |
| M3.6 | "sed procesează întreg fișierul simultan" | 40% | Așteptări greșite | Procesează linie cu linie |
| M3.7 | "Pot folosi `\d` în sed" | 45% | Erori regex | sed folosește BRE; `\d` nu există |

### 2.4 Misconcepții despre AWK

| ID | Misconcepție | Frecvență | Consecință | Clarificare |
|----|--------------|-----------|------------|-------------|
| M4.1 | "`$0` e primul câmp" | 65% | Procesare greșită | `$0` = linia întreagă |
| M4.2 | "FS se setează doar cu `-F`" | 40% | Cod inflexibil | Se poate seta în `BEGIN { FS="," }` |
| M4.3 | "`print $1 $2` pune spațiu" | 55% | Output concatenat | Fără virgulă = concatenare; cu `,` = spațiu |
| M4.4 | "NR și FNR sunt identice" | 50% | Bug la multiple fișiere | FNR se resetează per fișier |
| M4.5 | "Arrays încep de la 0" | 60% | Off-by-one errors | `split()` începe de la 1 |
| M4.6 | "awk e lent pentru fișiere mari" | 30% | Evită tool-ul potrivit | awk e foarte **eficient** |
| M4.7 | "Trebuie să declar variabile" | 35% | Cod excesiv | Variabilele se auto-inițializează |
| M4.8 | "Stringuri și numere sunt diferite" | 40% | Confuzie conversii | awk face conversie automată |

## 3. PLAN DE ÎMBUNĂTĂȚIRE

### 3.1 Timeline Seminar (100 minute)

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    STRUCTURA SEMINAR 7-8 (100 min)                      │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  PARTEA I (50 min)                                                     │
│  ├── [0:00-0:05]  HOOK: Log Analysis Demo (5 min)                      │
│  ├── [0:05-0:15]  Regex Fundamentals (10 min)                          │
│  │                 • Metacaractere: . ^ $ \                            │
│  │                 • Clase: [abc] [^abc] [a-z]                         │
│  │                 • Quantificatori: * + ? {n,m}                       │
│  ├── [0:15-0:20]  PEER INSTRUCTION Q1: Globbing vs Regex (5 min)      │
│  ├── [0:20-0:35]  GREP în Profunzime (15 min)                          │
│  │                 • -i -v -n -c -o                                     │
│  │                 • -E pentru ERE                                      │
│  │                 • Exemple practice cu log-uri                       │
│  ├── [0:35-0:45]  SPRINT #1: Grep Master (10 min)                      │
│  └── [0:45-0:50]  PEER INSTRUCTION Q2: sed Substitution (5 min)       │
│                                                                         │
│  ═══════════════════ PAUZĂ (10 min) ═════════════════════              │
│                                                                         │
│  PARTEA II (50 min)                                                    │
│  ├── [0:00-0:05]  Reactivare: Quiz Rapid (5 min)                       │
│  ├── [0:05-0:20]  SED Transformări (15 min)                            │
│  │                 • s/old/new/g                                        │
│  │                 • Adresare: număr, /pattern/, range                 │
│  │                 • -i și backreferences                              │
│  ├── [0:20-0:35]  AWK Procesare (15 min)                               │
│  │                 • $0 $1 $NF NR NF                                    │
│  │                 • -F pentru separator                               │
│  │                 • BEGIN/END și calcule                              │
│  ├── [0:35-0:40]  MINI-SPRINT: AWK Challenge (5 min)                   │
│  ├── [0:40-0:45]  Nano Quick Intro (5 min)                             │
│  │                 • CTRL+O, CTRL+X, CTRL+W                            │
│  ├── [0:45-0:48]  LLM Exercise: Regex Generator (3 min)                │
│  └── [0:48-0:50]  Reflection și Wrap-up (2 min)                        │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### 3.2 Obiective SMART

| Obiectiv | Specific | Măsurabil | Achievable | Relevant | Time-bound |
|----------|----------|-----------|------------|----------|------------|
| O1 | Scrie regex pentru email | Quiz la final | Da, cu practică | Esențial | Min 20 |
| O2 | Folosește grep -E cu opțiuni | Sprint G1 completat | Da | Fundamental | Min 35 |
| O3 | modifică text cu sed s/// | Sprint S1 completat | Da | Practic | Min 60 |
| O4 | Extrage coloane cu awk | Mini-sprint completat | Da | Important | Min 75 |
| O5 | Editează fișier cu nano | Demo live | Da | Util | Min 85 |

### 3.3 Diferențiere pe Nivele

#### Nivel Basic (toți studenții)
- Regex: `. ^ $ * [abc]`
- grep: `-i -v -n -c`
- sed: `s/old/new/g`
- awk: `{print $1, $2}`
- nano: salvare și ieșire

#### Nivel Intermediar (70% studenți)
- Regex: `+ ? {n,m} () |`
- grep: `-o -E -r --include`
- sed: adresare, `-i.bak`, `&`
- awk: `NR > 1`, `$3 > 100`, `BEGIN/END`, și totodată nano: căutare, cut/paste

#### Nivel Avansat (30% studenți)
- Regex: backreferences `\1`, lookahead (PCRE)
- grep: în pipeline-uri complexe
- sed: multiple comenzi, modificări batch
- awk: arrays asociative, printf, calcule agregate
- nano: configurare `.nanorc`

---

## 4. INTEGRARE CU RESURSELE EXISTENTE

### 4.1 Inspirație din BASH_MAGIC_COLLECTION

Demo-uri spectaculoase de integrat:

```bash
# Log Analysis în timp real (adaptat din colecție)
tail -f /var/log/syslog | grep --line-buffered -E 'error|warn' | \
    awk '{print strftime("%H:%M:%S"), $0}'

# CSV Reporter magic
awk -F',' 'NR>1 {sum[$2]+=$4} END {
    printf "%-15s %10s\n", "Category", "Total"
    for(c in sum) printf "%-15s $%9.2f\n", c, sum[c]
}' sales.csv

# Config file cleaner
sed '/^#/d; /^$/d; s/[[:space:]]*=[[:space:]]*/=/' config.txt
```

### 4.2 Sample Data Necesară

Vom genera următoarele fișiere pentru exerciții:

#### access.log (simulat)
```
192.168.1.100 - - [10/Jan/2025:10:15:32] "GET /index.html HTTP/1.1" 200 1234
192.168.1.101 - - [10/Jan/2025:10:15:33] "POST /api/login HTTP/1.1" 401 89
...
```

#### employees.csv
```csv
ID,Name,Department,Salary
101,John Smith,IT,5500
102,Maria Garcia,HR,4800
...
```

#### config.txt
```
# Application Config
server.host=localhost
server.port=8080
...
```

#### emails.txt
```
Contact: john.doe_AT_example_DOT_com
Invalid: not-an-email
...
```

---

## 5. CHECKLIST IMPLEMENTARE

### 5.1 Documente de Generat

| # | Fișier | Status | Linii Min | Note |
|---|--------|--------|-----------|------|
| 1 | README.md | ⬜ | 300 | Ghid principal |
| 2 | S04_00_ANALIZA_SI_PLAN_PEDAGOGIC.md | ⬜ | 350 | Acest document |
| 3 | S04_01_GHID_INSTRUCTOR.md | ⬜ | 700 | Timeline detaliat |
| 4 | S04_02_MATERIAL_PRINCIPAL.md | ⬜ | 1000 | Cel mai dens |
| 5 | S04_03_PEER_INSTRUCTION.md | ⬜ | 600 | 20+ întrebări |
| 6 | S04_04_PARSONS_PROBLEMS.md | ⬜ | 400 | 14+ probleme |
| 7 | S04_05_LIVE_CODING_GUIDE.md | ⬜ | 600 | 5 sesiuni |
| 8 | S04_06_EXERCITII_SPRINT.md | ⬜ | 500 | Sprint-uri |
| 9 | S04_07_LLM_AWARE_EXERCISES.md | ⬜ | 450 | 6+ exerciții |
| 10 | S04_08_DEMO_SPECTACULOASE.md | ⬜ | 450 | Demo-uri |
| 11 | S04_09_CHEAT_SHEET_VIZUAL.md | ⬜ | 400 | One-pager |
| 12 | S04_10_AUTOEVALUARE_REFLEXIE.md | ⬜ | 280 | Checklist |

### 5.2 Scripturi de Generat

| # | Fișier | Scop |
|---|--------|------|
| 1 | scripts/bash/S04_01_setup_seminar.sh | Setup mediu |
| 2 | scripts/bash/S04_02_quiz_interactiv.sh | Quiz dialog |
| 3 | scripts/bash/S04_03_validator.sh | Validare teme |
| 4 | scripts/demo/S04_01_hook_demo.sh | Hook spectaculos |
| 5 | scripts/demo/S04_02_demo_regex.sh | Demo regex |
| 6 | scripts/demo/S04_03_demo_grep.sh | Demo grep |
| 7 | scripts/demo/S04_04_demo_sed.sh | Demo sed |
| 8 | scripts/demo/S04_05_demo_awk.sh | Demo awk |
| 9 | scripts/demo/S04_06_demo_nano.sh | Demo nano |
| 10 | scripts/python/S04_01_autograder.py | Autograder |
| 11 | scripts/python/S04_02_quiz_generator.py | Generator quiz |
| 12 | scripts/python/S04_03_report_generator.py | Rapoarte |

### 5.3 Validări Finale

#### Criterii Critice
- [ ] Toate exemplele testate pe Ubuntu 24.04 LTS
- [ ] Diferență BRE/ERE explicată și demonstrată consistent — și legat de asta, [ ] Sample data furnizată și referențiată corect
- [ ] NANO folosit în loc de vim peste tot
- [ ] Cheat sheet complet pentru densitatea materialului

#### Criterii de Calitate
- [ ] Toate fișierele .md au header consistent
- [ ] Diagrame ASCII pentru concepte complexe, și totodată [ ] Exemple bazate pe date reale (log-uri, CSV-uri)
- [ ] Erori deliberate documentate în live coding
- [ ] Soluții disponibile pentru toate exercițiile

#### Criterii de Consistență
- [ ] Prefixul S04_ pe toate fișierele noi
- [ ] Limba română cu terminologie tehnică în engleză
- [ ] Formatare consistentă (emoji, tabele, cod)
- [ ] Cross-referințe corecte între documente

---

## Anexă: Mapping Conținut Original → Nou

```
TC2f_Expresii_Regulate.md  →  S04_02_MATERIAL_PRINCIPAL.md (Modulul 1)
TC4e_GREP.md               →  S04_02_MATERIAL_PRINCIPAL.md (Modulul 2)
TC4d_SED.md                →  S04_02_MATERIAL_PRINCIPAL.md (Modulul 3)
TC4c_AWK.md                →  S04_02_MATERIAL_PRINCIPAL.md (Modulul 4)
TC4f_VI_VIM.md             →  ⚠️ ÎNLOCUIT cu Nano (Modulul 5)
ANEXA_Referinte_Seminar4.md →  Integrat în diverse documente
```

---

*Document de analiză pentru Seminarul 7-8 de Sisteme de Operare | ASE București - CSIE*
