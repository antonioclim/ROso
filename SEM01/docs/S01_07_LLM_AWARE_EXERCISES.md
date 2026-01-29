# Exerciții LLM-Aware - Seminarul 1-2
## Sisteme de Operare | Integrarea AI în Învățare

**Filozofie**: LLM-urile sunt instrumente de învățare, nu adversari.  
**Scop**: Dezvoltă abilitatea de a evalua, corecta și îmbunătăți cod generat.

---

## PRINCIPII DE UTILIZARE LLM

### Ce e OK să faci cu LLM:
✅ Să ceri explicații pentru concepte neclare  
✅ Să generezi cod pe care îl ÎNȚELEGI și îl TESTEZI  
✅ Să ceri alternative și să compari abordări  
✅ Să folosești ca "rubber duck" pentru debugging  
✅ Să ceri să-ți explice erori de terminal

### Ce NU e OK:
❌ Să copiezi cod fără să-l înțelegi  
❌ Să trimiți la evaluare fără testare  
❌ Să presupui că output-ul e întotdeauna corect  
❌ Să renunți la gândirea proprie

---

## EXERCIȚIUL 1: Evaluatorul de Alias-uri
**Timp**: 10 minute | **Nivel**: Începător

### Partea A: Generare (3 min)

Trimite acest prompt către ChatGPT/Claude/Gemini:

```
Generează 5 alias-uri Bash utile pentru un student de 
Sisteme de Operare care lucrează frecvent cu:
- Navigare în directoare
- Vizualizare log-uri
- Gestiune procese
- Backup-uri

Pentru fiecare alias, include un comentariu explicativ.
```

### Partea B: Evaluare Critică (5 min)

Pentru **FIECARE** alias generat, completează tabelul:

| Alias | Sintaxă Corectă? | Am testat? | E util pentru MINE? | Risc potențial? |
|-------|------------------|------------|---------------------|-----------------|
|       | ✓ / ✗           | ✓ / ✗      | 1-5                | DA/NU + explicație |
|       |                  |            |                     |                 |

### Partea C: Rafinare (2 min)

Alege UN alias și îmbunătățește-l:
- Adaugă o opțiune utilă
- Fă-l mai sigur (ex: adaugă confirmare)
- Personalizează-l pentru workflow-ul TĂU

### Livrabil:
```
Fișier: llm_alias_eval.txt

ALIAS ALES: [numele]
VERSIUNE ORIGINALĂ: [ce a generat LLM]
VERSIUNE ÎMBUNĂTĂȚITĂ: [ce ai modificat tu]
MOTIVAȚIE: [de ce e mai bun]
```

---

## EXERCIȚIUL 2: Debugger-ul de Scripturi
**Timp**: 12 minute | **Nivel**: Intermediar

### Setup

LLM-ul a generat acest script "funcțional" pentru backup:

```bash
#!/bin/bash
# Script de backup "generat de AI"

SURSA=$HOME/Documents
DEST=$HOME/Backup
DATA=`date +%Y%m%d`

# Creează directorul de backup
mkdir $DEST/$DATA

# Copiază fișierele
cp -r $SURSA $DEST/$DATA

# Șterge backup-uri vechi (mai vechi de 7 zile)
find $DEST -mtime +7 -delete

echo Backup complet!
```

### Task: Găsește și Corectează Problemele

Scriptul are **minimum 5 probleme**. Găsește-le!

<details>
<summary>💡 HINTS (deschide doar dacă ești blocat)</summary>

1. Ce se întâmplă dacă SURSA are spații în nume?
2. Ce se întâmplă dacă DEST nu există?
3. Forma `date` cu backticks e recomandată?
4. `find -delete` fără `-type` e sigur?
5. Echo-ul funcționează cum aștepți?
6. Scriptul verifică dacă SURSA există?

</details>

### Livrabil:

```
Fișier: backup_debug.txt

PROBLEMA 1: [descriere]
LINIA: [număr]
CORECȚIE: [cod corectat]

PROBLEMA 2: ...

SCRIPT CORECTAT COMPLET:
[codul îmbunătățit]
```

### Soluție pentru instructor:

```bash
#!/bin/bash
# Script de backup CORECTAT

SURSA="$HOME/Documents"
DEST="$HOME/Backup"
DATA=$(date +%Y%m%d)

# Verifică că sursa există
if [ ! -d "$SURSA" ]; then
    echo "Eroare: Directorul sursă nu există: $SURSA" >&2
    exit 1
fi

# Creează directorul de backup (cu -p pentru siguranță)
mkdir -p "$DEST/$DATA"

# Copiază fișierele (cu ghilimele pentru spații)
cp -r "$SURSA" "$DEST/$DATA/"

# Șterge backup-uri vechi (doar directoare, cu confirmare)
find "$DEST" -maxdepth 1 -type d -mtime +7 -exec rm -rf {} \;

echo "Backup complet: $DEST/$DATA"
```

---

## EXERCIȚIUL 3: Generare și Învățare Inversă
**Timp**: 15 minute | **Nivel**: Intermediar

### Concept: Învățare prin Predare

Vei cere LLM-ului să-ți genereze cod, apoi vei **preda** colegului ce face.

### Partea A: Generare

Prompt:
```
Scrie un one-liner Bash care:
1. Găsește toate fișierele .log din /var/log
2. Le sortează după dimensiune
3. Afișează top 5 cele mai mari
4. Include dimensiunea în format human-readable

Folosește pipe-uri și comenzi standard Linux.
```

### Partea B: Descompunere

**ÎNAINTE de a rula**, descompune one-liner-ul:

```
COMANDĂ: [one-liner-ul complet]

PARTE 1: [ce face prima comandă]
PARTE 2: [ce face a doua comandă din pipe]
PARTE 3: ...

FLOW DE DATE: 
Input → [transformare 1] → [transformare 2] → Output
```

### Partea C: Predare

Explică colegului tău:
1. Ce face fiecare parte
2. De ce sunt în această ordine
3. Ce s-ar întâmpla dacă schimbi ordinea

### Partea D: Experimentare

Modifică one-liner-ul să:
- Caute și în subdirectoare
- Excludă fișiere mai mici de 1KB
- Salveze rezultatul într-un fișier

### Livrabil:
```
Fișier: oneliner_explained.txt

ONE-LINER ORIGINAL: [cod]

EXPLICAȚIE:
[fiecare parte explicată]

MODIFICARE MEA:
[versiunea ta îmbunătățită + de ce]
```

---

## EXERCIȚIUL 4: Code Review pentru AI
**Timp**: 10 minute | **Nivel**: Avansat

### Scenariul

Ești senior developer și trebuie să faci code review pentru "junior developer" (LLM).

### Task

Cere LLM-ului:
```
Scrie un script Bash pentru monitorizarea resurselor sistem care:
1. Afișează utilizare CPU
2. Afișează utilizare memorie
3. Afișează spațiu disk
4. Se actualizează la fiecare 5 secunde
5. Se oprește frumos la Ctrl+C
```

### Code Review Checklist

Evaluează scriptul pe aceste criterii:

| Criteriu | Punctaj (1-5) | Comentarii |
|----------|---------------|------------|
| **Corectitudine**: Funcționează? |  |  |
| **Portabilitate**: Merge pe orice Linux? |  |  |
| **Lizibilitate**: E clar ce face? |  |  |
| **Stabilitate**: Gestionează erori? |  |  |
| **Eficiență**: E optim? |  |  |
| **Siguranță**: Are riscuri? |  |  |
| **Stil**: Urmează best practices? |  |  |

### Feedback Constructiv

Scrie feedback ca pentru un coleg junior:

```
ASPECTE POZITIVE:
- 
- 

DE ÎMBUNĂTĂȚIT:
- 
- 

SUGESTII CONCRETE:
- 
- 
```

---

## EXERCIȚIUL 5: Provocare de Securitate
**Timp**: 12 minute | **Nivel**: Avansat

### Scenariul

LLM-urile pot genera cod nesigur. Identifică vulnerabilitățile!

### Cod "generat de AI":

```bash
#!/bin/bash
# Script de procesare input utilizator

echo "Introdu numele fișierului de procesat:"
read filename

# Procesează fișierul
cat $filename | grep "important" > results.txt

# Șterge fișierele temporare
rm -rf /tmp/$filename*

# Execută o comandă din fișier
eval $(cat $filename | head -1)

echo "Procesare completă!"
```

### Task: Audit de Securitate

Găsește **toate** vulnerabilitățile:

| # | Linia | Vulnerabilitate | Risc | Cum s-ar exploata |
|---|-------|-----------------|------|-------------------|
| 1 |       |                 | Critic/Mare/Mediu |  |
| 2 |       |                 |      |  |
| ... |     |                 |      |  |

### Rescrie Sigur

Creează versiunea securizată care:
- Validează input-ul
- Folosește quoting corect
- Elimină `eval`
- Restricționează căile

---

## REFLECTION TEMPLATE

La finalul fiecărui exercițiu LLM, completează:

```
═══════════════════════════════════════════════════════════════
🧠 REFLECTION: [Numele exercițiului]
═══════════════════════════════════════════════════════════════

1. CE AM ÎNVĂȚAT DESPRE CODUL GENERAT DE LLM:
   _________________________________________________

2. CE EROARE A FĂCUT LLM-UL (dacă a fost cazul):
   _________________________________________________

3. CUM AM IDENTIFICAT PROBLEMA:
   _________________________________________________

4. CUM AȘ FOLOSI LLM-UL MAI EFICIENT DATA VIITOARE:
   _________________________________________________

5. CE ÎNTREBARE AȘ PUNE ALTFEL:
   _________________________________________________
═══════════════════════════════════════════════════════════════
```

---

## COMPETENȚE DEZVOLTATE

Prin aceste exerciții, dezvolți:

| Competență | Nivel Bloom | Indicator |
|------------|-------------|-----------|
| Evaluare cod extern | EVALUARE | Identifici 80%+ din probleme |
| Debugging sistematic | ANALIZĂ | Urmezi un proces, nu ghicești |
| Comunicare tehnică | SINTEZĂ | Explici clar colegilor |
| Gândire critică | ANALIZĂ | Nu accepți cod fără întrebări |
| Securitate de bază | APLICARE | Recunoști pattern-uri riscante |

---

## PROMPT-URI UTILE PENTRU ÎNVĂȚARE

### Pentru explicații:
```
Explică pas cu pas ce face această comandă Bash:
[comandă]
Presupune că sunt începător și nu știu [concept].
```

### Pentru alternative:
```
Dă-mi 3 moduri diferite de a [task] în Bash.
Pentru fiecare, explică când e mai potrivită.
```

### Pentru debugging:
```
Primesc această eroare când rulez [comandă]:
[eroare]
Ce ar putea fi greșit și cum verific?
```

### Pentru best practices:
```
Am scris acest script:
[cod]
Ce ar face un senior developer diferit?
```

---

*Exerciții LLM-Aware | SO Seminarul 1-2 | ASE-CSIE*
