# Integrarea detecției externe a plagiatului

> **Scop:** Ghid pentru utilizarea instrumentelor externe de detecție a plagiatului împreună cu kit‑ul ENos  
> **Public țintă:** Cadre didactice și asistenți didactici  
> **Ultima actualizare:** ianuarie 2025

Acest ghid explică modul de integrare a instrumentelor externe de detecție a plagiatului (MOSS și JPlag) cu kit‑ul educațional ENos, pentru verificări complete de integritate academică.

---

## Prezentare generală

| Instrument | Tip | Limbaje | Acces | Recomandat pentru |
|-----------|-----|---------|-------|-------------------|
| **MOSS** | Serviciu online | Bash, Python, C, Java, etc. | Gratuit (academic) | Verificări rapide, grupe mari |
| **JPlag** | Rulare locală (self‑hosted) | Java, Python, C, Bash, text | Open‑source | Cazuri sensibile la confidențialitate, utilizare offline |

Ambele instrumente completează verificatorul intern de similaritate (`S01_05_plagiarism_detector.py`), oferind algoritmi de analiză mai sofisticați.

---

## MOSS (Measure of Software Similarity)

### Ce este MOSS?

MOSS este un serviciu gratuit de detecție a plagiatului dezvoltat la Stanford University. Acesta compară fișierele de cod predate și identifică pasaje similare, furnizând un raport web cu potrivirile evidențiate.

**Caracteristici principale:**

- Suport pentru 25+ limbaje de programare
- Excluderea codului de bază/starter din comparație
- Gestionarea eficientă a seturilor mari de predări
- Scoruri procentuale de similaritate
- Gratuit pentru utilizare academică

### Obținerea accesului MOSS

1. **Solicitarea unui cont:**
   ```
   To: [ELIMINAT]
   Subject: New MOSS Account Request

   Dear MOSS Team,

   I am requesting a MOSS account for plagiarism detection.

   Name: [Your name]
   Institution: [Your university]
   Email: [Your institutional email]
   Purpose: Academic integrity for Operating Systems course

   Thank you.
   ```

2. **Primirea scriptului MOSS** (de regulă în 24–48 de ore)

3. **Salvați scriptul** ca `moss.pl` în `SEM07/external_tools/`

4. **Marcați fișierul ca executabil:**
   ```bash
   chmod +x moss.pl
   ```

### Utilizarea MOSS cu ENos

**Utilizare de bază — un singur seminar:**
```bash
# Compare submissions for SEM01 homework
./run_moss.sh /path/to/submissions/SEM01/ -l bash
```

**Excluderea codului‑template (base file):**
```bash
# Ignore provided template file
./run_moss.sh /path/to/submissions/SEM03/ -l bash -b template.sh
```

**Modul director (câte un folder per student):**
```bash
# When each student has their own folder
./run_moss.sh /path/to/submissions/SEM05/ -l bash -d
```

**Mai multe limbaje:**
```bash
# Compare both Bash and Python (if mixed submissions)
./run_moss.sh /path/to/submissions/SEM06/ -l bash -l python
```

**Fișier de configurare user ID:**
MOSS necesită un user ID. În mod uzual, scriptul `run_moss.sh` citește ID‑ul din `~/.moss_userid`:

```bash
echo "YOUR_MOSS_ID" > ~/.moss_userid
chmod 600 ~/.moss_userid
```

### Interpretarea rezultatelor MOSS

MOSS returnează un URL către raportul web. Raportul include:

- perechi de fișiere cu potriviri semnificative
- fragmente de cod evidențiate
- scoruri procentuale pentru fiecare pereche
- opțiunea de a exclude fișiere suplimentare (în iterații ulterioare)

**Interpretare recomandată:**

| Similaritate | Interpretare | Acțiune |
|-------------|--------------|---------|
| 0–30% | Potriviri normale (cod comun, constrângeri) | Nicio acțiune |
| 30–50% | Similaritate ridicată | Review manual, discuție |
| 50–70% | Similaritate foarte ridicată | Investigație, verificare orală |
| >70% | Probabilitate mare de plagiat | Procedură formală de integritate |

**Atenție:** scorurile procentuale nu sunt, singure, o dovadă; se recomandă verificare manuală și verificare orală.

---

## JPlag

### Ce este JPlag?

JPlag este un instrument open‑source de detecție a similarității, care poate fi rulat local (offline). Este util atunci când:

- nu se pot încărca predările către servicii externe (confidențialitate)
- este necesară integrarea într‑un pipeline local
- se dorește arhivarea rezultatelor în infrastructura internă

### Instalare

**Opțiunea 1: Rulare din JAR (recomandat)**
1. Descărcați ultima versiune JPlag (JAR) din sursa oficială.
2. Verificați că aveți Java 11+ instalat:

```bash
java -version
```

**Opțiunea 2: Instalare prin container (Docker)**
Dacă utilizați Docker, puteți rula JPlag într‑un container, fără instalare locală de Java.

> Nota: această opțiune depinde de politica instituțională și de disponibilitatea Docker.

### Utilizarea JPlag cu ENos

**Comparare de bază (Bash):**
```bash
java -jar jplag.jar -l bash -r results_sem02 /path/to/submissions/SEM02/
```

**Excluderea codului comun:**
```bash
java -jar jplag.jar -l bash -r results_sem04 /path/to/submissions/SEM04/ -x "template.sh"
```

**Setări recomandate:**
- utilizați aceeași structură de directoare ca în predări
- excludeți fișierele standard/starter furnizate tuturor
- rulați analiza pe un singur set de predări (un seminar) pentru interpretare mai clară

### Output JPlag

JPlag generează un director de rezultate (`-r results_dir`) care include, de regulă:

- rapoarte HTML cu potrivirile identificate
- fișiere auxiliare cu scoruri și detalii
- grafuri/diagrame ale similarității (în funcție de versiune)

---

## Integrarea cu autograder‑ul ENos

### Flux de lucru recomandat

1. **Verificare internă rapidă** (hash/diff/AST), pentru filtrarea cazurilor evidente.
2. **MOSS** pentru comparație robustă la scară (în special la grupe mari).
3. **JPlag** pentru scenarii offline sau pentru confirmare.
4. **Verificare orală** pentru validarea autoratului.
5. **Documentare** (rapoarte, capturi, note), conform procedurilor instituționale.

### Bune practici

- Excludeți codul comun (starter/template) pentru a reduce fals‑pozitivele.
- Ajustați pragurile în funcție de natura temei (unele sarcini au soluții similare în mod natural).
- Nu evaluați doar pe scoruri; analizați fragmentele și contextul.
- Corelați cu metadate de predare (timestamp, istoricul commit‑urilor, stil).

### Probleme frecvente și soluții

| Problemă | Cauză probabilă | Soluție |
|---------|------------------|---------|
| Scoruri ridicate pentru mulți studenți | Cod starter neexclus | Folosiți base file/excluderi |
| Raport MOSS greu de interpretat | Set mare, prag prea mic | Creșteți pragul, filtrați pe fișiere |
| Restricții de confidențialitate | Politici instituționale | Folosiți JPlag local |
| Fals‑pozitive | Cerințe care impun soluții similare | Verificare manuală + orală |

---

## Referințe

- MOSS: http://theory.stanford.edu/~aiken/moss/
- JPlag: https://github.com/jplag/jplag

---

## Changelog

- January 2025: Initial version for SEM07 integration
