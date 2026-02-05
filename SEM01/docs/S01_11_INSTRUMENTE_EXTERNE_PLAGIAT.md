# Instrumente Externe pentru Detecția Plagiatului

> **Pentru cohorte >50 studenți** | Suplimentează detectorul intern  
> **Versiune:** 1.0 | **Data:** Ianuarie 2025

---

## Prezentare generală

Detectorul intern de plagiat (`S01_05_plagiarism_detector.py`) funcționează bine pentru verificări rapide și cohorte mici. Pentru grupuri mai mari sau când aveți nevoie de comparație structurală între semestre, folosiți MOSS sau JPlag.

| Instrument | Optim pentru | Necesită | Timp răspuns |
|------------|--------------|----------|--------------|
| Detector intern | Verificări rapide, <50 studenți | Python | Imediat |
| MOSS | Cohorte mari, cross-semestru | Internet, Perl | Minute |
| JPlag | Analiză offline, rapoarte detaliate | Java | Imediat |

---

## 1. MOSS (Measure of Software Similarity)

MOSS este un serviciu gratuit de la Stanford, standardul pentru detecția plagiatului academic din 1994.

### 1.1 Înregistrare (o singură dată)

1. Trimiteți un email la adresa serviciului MOSS Stanford
2. **Subiect:** `registeruser`
3. **Corp mesaj:** Doar cuvântul `registeruser` (nimic altceva)
4. Așteptați 24-48 ore
5. Veți primi un script Perl cu ID-ul personal de utilizator încorporat

Salvați scriptul ca `moss.pl` în directorul de lucru.

### 1.2 Utilizare de bază

```bash
# Trimiteți toate fișierele .sh din directoarele studenților
perl moss.pl -l bash -d submissions/*/*.sh

# Cu fișiere de bază (cod șablon de ignorat)
perl moss.pl -l bash -b template.sh -d submissions/*/*.sh

# Comparație cross-semestru
perl moss.pl -l bash -d semester1/*/*.sh semester2/*/*.sh
```

### 1.3 Opțiuni utile

| Opțiune | Scop | Exemplu |
|---------|------|---------|
| `-l bash` | Limbaj (bash, python, c, java etc.) | Obligatoriu |
| `-d` | Compară per director (grupează fișiere per student) | Recomandat |
| `-b file` | Fișier de bază (ignoră potrivirile cu acest șablon) | Pentru cod starter |
| `-m N` | Număr maxim de apariții înainte de ignorare | `-m 10` |
| `-n N` | Număr de potriviri de afișat | `-n 250` |

### 1.4 Interpretarea rezultatelor

MOSS returnează un URL cu rezultatele. Raportul arată:

| Similaritate | Semnificație tipică | Acțiune |
|--------------|---------------------|---------|
| <30% | Variație normală, idiomuri comune | Niciuna |
| 30-50% | Cod partajat, posibilă colaborare | Revizuire manuală |
| 50-70% | Suprapunere substanțială | Probabil colaborare, intervievați ambii |
| 70-90% | Similaritate foarte mare | Plagiat probabil, investigați |
| >90% | Aproape identice | Aproape sigur copiat |

**Important:** Rezultatele MOSS expiră după 14 zile. Descărcați sau faceți captură de ecran imediat!

### 1.5 Integrare Makefile

```bash
# Deja adăugat în Makefile - utilizare:
make moss-check MOSS_USERID=123456789 SUBMISSIONS=./submissions/
```

---

## 2. JPlag

JPlag este o alternativă open-source care rulează local — utilă când nu puteți trimite cod către servere externe.

### 2.1 Instalare

```bash
# Descărcați ultima versiune
wget https://github.com/jplag/JPlag/releases/download/v5.0.0/jplag-5.0.0-jar-with-dependencies.jar -O jplag.jar

# Verificați instalarea
java -jar jplag.jar --version
```

Necesită Java 17 sau mai nou.

### 2.2 Utilizare de bază

```bash
# Comparație de bază
java -jar jplag.jar -l bash submissions/

# Cu prag minim de similaritate
java -jar jplag.jar -l bash -m 50 submissions/

# Specificați directorul de ieșire
java -jar jplag.jar -l bash -r results/ submissions/
```

### 2.3 Opțiuni utile

| Opțiune | Scop | Exemplu |
|---------|------|---------|
| `-l bash` | Limbaj | Obligatoriu pentru scripturi shell |
| `-m N` | Similaritate minimă % de raportat | `-m 40` |
| `-r dir` | Director rezultate | `-r jplag_results/` |
| `-bc dir` | Director cod de bază (șablon de ignorat) | `-bc template/` |
| `-n N` | Număr maxim comparații de stocat | `-n 500` |

### 2.4 Vizualizarea rezultatelor

JPlag generează un raport HTML:

```bash
# Deschide rezultatele (Linux)
xdg-open jplag_results/index.html

# Deschide rezultatele (macOS)
open jplag_results/index.html

# Deschide rezultatele (WSL)
explorer.exe jplag_results/index.html
```

Raportul include:
- Vizualizare cluster arătând grupuri de teme similare
- Comparație perechi cu diff alăturat
- Histogramă distribuție

### 2.5 Integrare Makefile

```bash
# Deja adăugat în Makefile - utilizare:
make jplag-check SUBMISSIONS=./submissions/
```

---

## 3. Flux de lucru recomandat

Iată pipeline-ul complet anti-plagiat pentru un seminar tipic:

```
┌─────────────────────────────────────────────────────────────────┐
│                     TEME PRIMITE                                 │
│              (termen expirat, arhivă colectată)                 │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│  ETAPA 1: Autograder                                            │
│  ───────────────────                                            │
│  • Rulează: python3 S01_01_autograder.py submissions/StudentX/  │
│  • Generează: scor + întrebări orale                            │
│  • Timp: ~30 secunde per student                                │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│  ETAPA 2: Detector Intern Plagiat                               │
│  ────────────────────────────────                               │
│  • Rulează: make plagiarism-check SUBMISSIONS=./submissions/    │
│  • Detectează: copii exacte, reordonare, pattern-uri AI         │
│  • Timp: ~2 minute pentru 50 studenți                           │
└─────────────────────────────────────────────────────────────────┘
                                │
                     Dimensiune cohortă > 50?
                      │           │
                      DA          NU
                      │           │
                      ▼           │
┌─────────────────────────────────┐          │
│  ETAPA 2b: MOSS sau JPlag       │          │
│  ─────────────────────────      │          │
│  • Pentru similaritate struct.  │          │
│  • Comparație cross-semestru    │          │
│  • Timp: 5-10 minute            │          │
└─────────────────────────────────┘          │
                      │                       │
                      ▼                       ▼
┌─────────────────────────────────────────────────────────────────┐
│  ETAPA 3: Revizuire marcaje                                     │
│  ─────────────────────────                                      │
│  • Revizuiți toate perechile >70% similaritate                  │
│  • Verificați colaborare legitimă (programare în perechi)       │
│  • Pregătiți întrebări specifice pentru verificare orală        │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│  ETAPA 4: Verificare orală                                      │
│  ─────────────────────────                                      │
│  • Folosiți: S01_04_JURNAL_VERIFICARE_ORALA.md                  │
│  • Toți studenții (2 întrebări aleatorii)                       │
│  • Studenți marcați (întrebări țintite despre codul suspect)    │
│  • Timp: 3-5 minute per student                                 │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│  ETAPA 5: Decizie finală                                        │
│  ───────────────────────                                        │
│  • Clar: Notați normal                                          │
│  • Suspect: Solicitați retrimitere sau zero                     │
│  • Plagiat confirmat: Proces de integritate academică           │
└─────────────────────────────────────────────────────────────────┘
```

---

## 4. Sfaturi pentru detecție eficientă

### Înainte de temă

1. **Folosiți generatorul de teme** — variantele randomizate fac copierea directă mai dificilă
2. **Anunțați detecția** — disuasiunea funcționează (studenții știu că verificați)
3. **Păstrați temele din semestrele anterioare** — pentru comparație cross-semestru

### În timpul notării

1. **Rulați mai întâi detectorul intern** — e rapid și prinde cazurile evidente
2. **Folosiți MOSS pentru similaritate structurală** — prinde codul „parafrazat"
3. **Aveți încredere în instinct** — dacă codul pare inconsistent cu nivelul studentului, investigați

### Fals pozitive frecvente

Acestea declanșează adesea similaritate mare dar nu sunt plagiat:

- **Cod șablon** — folosiți opțiunea fișier de bază pentru excludere
- **Idiomuri comune** — `set -euo pipefail`, bucle standard
- **Parteneri programare în perechi** — verificați că sunt înregistrați ca pereche
- **Tutoriale online** — similare cu corpusul de bază MOSS

### Documentație

Păstrați întotdeauna:
- [ ] Rapoarte detector plagiat (export JSON)
- [ ] URL-uri MOSS (captură de ecran înainte să expire!)
- [ ] Rapoarte HTML JPlag
- [ ] Jurnale verificare orală
- [ ] Orice corespondență email

---

## 5. Comparație metode de detecție

| Metodă | Copii exacte | Reordonare | Redenumire variabile | Modificări structurale | Generat AI |
|--------|--------------|------------|----------------------|------------------------|------------|
| Intern (hash) | ✓✓✓ | ✗ | ✗ | ✗ | ✗ |
| Intern (sortat) | ✓✓✓ | ✓✓✓ | ✗ | ✗ | ✗ |
| Intern (pattern-uri AI) | ✗ | ✗ | ✗ | ✗ | ✓✓ |
| MOSS | ✓✓✓ | ✓✓ | ✓✓ | ✓ | ✗ |
| JPlag | ✓✓✓ | ✓✓ | ✓✓ | ✓✓ | ✗ |
| Verificare orală | ✓ | ✓ | ✓ | ✓ | ✓✓✓ |

**Legendă:** ✓✓✓ = Excelent, ✓✓ = Bun, ✓ = Parțial, ✗ = Nedetectat

---

## 6. Depanare

### Probleme MOSS

| Problemă | Soluție |
|----------|---------|
| „Connection refused" | Serverele Stanford pot fi indisponibile — încercați mai târziu |
| „Invalid user ID" | Reînregistrați-vă, ID-urile expiră ocazional |
| Niciun URL de rezultate | Verificați că fișierele au fost efectiv încărcate |
| Pagină rezultate goală | Posibil tipuri de fișiere incompatibile |

### Probleme JPlag

| Problemă | Soluție |
|----------|---------|
| „Unsupported class file" | Actualizați Java la versiunea 17+ |
| „No submissions found" | Verificați structura directorului — necesită subdirectoare |
| OutOfMemoryError | Adăugați `-Xmx4g` înainte de `-jar` |
| Raportul nu se deschide | Încercați alt browser, verificați JavaScript activat |

---

*Ghid instrumente externe plagiat | Versiune 1.0 | Ianuarie 2025*  
*Sisteme de Operare | ASE București - CSIE*
