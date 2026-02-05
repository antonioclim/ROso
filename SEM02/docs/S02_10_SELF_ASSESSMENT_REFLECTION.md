# Autoevaluare și Reflecție - Seminarul 3-4
## Sisteme de Operare | Operatori, Redirecționare, Filtre, Bucle

**Versiune**: 1.0 | **Scop**: Metacogniție și consolidare învățare  
**Filozofie**: Reflecția activă modifică experiența în cunoaștere durabilă

---

## CE ESTE AUTOEVALUAREA METACOGNITIVĂ?

```
╔════════════════════════════════════════════════════════════════════╗
║                    CICLUL ÎNVĂȚĂRII ACTIVE                         ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║       ┌──────────────┐                                             ║
║       │   EXPERIENȚĂ │ ◄─────────────────────────────┐             ║
║       │   (Seminar)  │                               │             ║
║       └──────┬───────┘                               │             ║
║              │                                       │             ║
║              ▼                                       │             ║
║       ┌──────────────┐                               │             ║
║       │   REFLECȚIE  │  ← ACEST DOCUMENT             │             ║
║       │   (Ce am     │                               │             ║
║       │   învățat?)  │                               │             ║
║       └──────┬───────┘                               │             ║
║              │                                       │             ║
║              ▼                                       │             ║
║       ┌──────────────┐                               │             ║
║       │  ABSTRACTIZARE│                              │             ║
║       │  (Concepte)   │                              │             ║
║       └──────┬───────┘                               │             ║
║              │                                       │             ║
║              ▼                                       │             ║
║       ┌──────────────┐                               │             ║
║       │  EXPERIMENTARE│ ──────────────────────────────┘             ║
║       │  (Practică)   │                                            ║
║       └──────────────┘                                             ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

---

## CHECKPOINT 1: OPERATORI DE CONTROL

### Auto-evaluare Cunoștințe

Răspunde sincer (1 = Deloc, 5 = Perfect):

| Competență | 1 | 2 | 3 | 4 | 5 |
|------------|---|---|---|---|---|
| Știu diferența între `;` și `&&` | □ | □ | □ | □ | □ |
| Pot explica ce face `||` | □ | □ | □ | □ | □ |
| Înțeleg ordinea `cmd && succes || eroare` | □ | □ | □ | □ | □ |
| Pot folosi `&` pentru background | □ | □ | □ | □ | □ |
| Știu diferența între `{}` și `()` | □ | □ | □ | □ | □ |
| Înțeleg coduri de ieșire (`$?`, 0=succes) | □ | □ | □ | □ | □ |

### Întrebări de Reflecție

```
1. Care e greșeala cea mai des întâlnită cu operatorii de control?
   
   Răspunsul meu: ________________________________________________
   
   ________________________________________________________________

2. Când aș folosi `;` în loc de `&&`? Dă un exemplu concret.
   
   Răspunsul meu: ________________________________________________
   
   ________________________________________________________________

3. Ce se întâmplă dacă inversez ordinea: `cmd || eroare && succes`?
   
   Răspunsul meu: ________________________________________________
   
   ________________________________________________________________
```

---

## CHECKPOINT 2: REDIRECȚIONARE I/O

### Auto-evaluare Cunoștințe

| Competență | 1 | 2 | 3 | 4 | 5 |
|------------|---|---|---|---|---|
| Știu ce sunt fd 0, 1, 2 | □ | □ | □ | □ | □ |
| Pot folosi `>` și `>>` corect | □ | □ | □ | □ | □ |
| Știu cum să redirecționez stderr | □ | □ | □ | □ | □ |
| Înțeleg ordinea în `2>&1` | □ | □ | □ | □ | □ |
| Pot folosi `<<` (here document) | □ | □ | □ | □ | □ |
| Știu când să folosesc `/dev/null` | □ | □ | □ | □ | □ |

### Întrebări de Reflecție

```
1. Care e diferența între `> file 2>&1` și `2>&1 > file`?
   
   Răspunsul meu: ________________________________________________
   
   ________________________________________________________________

2. Când ai folosi here document (`<<`) în practică?
   
   Răspunsul meu: ________________________________________________
   
   ________________________________________________________________

3. De ce uneori comenzile par să nu producă output?
   
   Răspunsul meu: ________________________________________________
```

---

## CHECKPOINT 3: FILTRE DE TEXT

### Auto-evaluare Cunoștințe

| Competență | 1 | 2 | 3 | 4 | 5 |
|------------|---|---|---|---|---|
| Pot folosi `sort` cu opțiuni (-n, -r, -k) | □ | □ | □ | □ | □ |
| **Știu că `uniq` necesită `sort` înainte!** | □ | □ | □ | □ | □ |
| Pot extrage coloane cu `cut` | □ | □ | □ | □ | □ |
| Știu că `tr` operează pe CARACTERE | □ | □ | □ | □ | □ |
| Pot construi pipeline-uri complexe | □ | □ | □ | □ | □ |
| Înțeleg când să folosesc `tee` | □ | □ | □ | □ | □ |

### Întrebări de Reflecție

```
1. De ce `echo -e "a\nb\na" | uniq` produce 3 linii, nu 2?
   
   Răspunsul meu: ________________________________________________
   
   ________________________________________________________________

2. Care e delimitatorul implicit pentru `cut`? Cum îl schimbi?
   
   Răspunsul meu: ________________________________________________

3. Ce face `tr 'abc' 'xyz'`? Dar `tr 'abc' 'x'`?
   
   Răspunsul meu: ________________________________________________
   
   ________________________________________________________________
```

---

## CHECKPOINT 4: BUCLE

### Auto-evaluare Cunoștințe

| Competență | 1 | 2 | 3 | 4 | 5 |
|------------|---|---|---|---|---|
| Pot scrie `for` cu listă/brace/files | □ | □ | □ | □ | □ |
| **Știu că `{1..$N}` NU funcționează!** | □ | □ | □ | □ | □ |
| Pot folosi `while` cu condiție | □ | □ | □ | □ | □ |
| **Știu problema subshell cu pipe!** | □ | □ | □ | □ | □ |
| Știu diferența `break` vs `exit` | □ | □ | □ | □ | □ |
| Pot citi fișiere linie cu linie | □ | □ | □ | □ | □ |

### Întrebări de Reflecție

```
1. De ce `N=5; for i in {1..$N}` nu funcționează? Care e soluția?
   
   Răspunsul meu: ________________________________________________
   
   ________________________________________________________________

2. Ce se întâmplă cu variabilele modificate într-un `while` dintr-un pipe?
   
   Răspunsul meu: ________________________________________________
   
   ________________________________________________________________

3. Când ai folosi `until` în loc de `while`?
   
   Răspunsul meu: ________________________________________________
```

---

## RUBRICA DE AUTO-EVALUARE GLOBALĂ

### Scor Total pe Competențe

Calculează scorul tău (sumă răspunsuri × 5 max per întrebare):

| Modul | Scor meu | Scor maxim | Procentaj |
|-------|----------|------------|-----------|
| Operatori | ___/30 | 30 | __% |
| Redirecționare | ___/30 | 30 | __% |
| Filtre | ___/30 | 30 | __% |
| Bucle | ___/30 | 30 | __% |
| **TOTAL** | **___/120** | **120** | **___%** |

### Interpretare Rezultate

```
90-100%: 🌟 EXPERT - Ești gata pentru concepte avansate!
70-89%:  ✅ COMPETENT - Fundamente solide, practică pentru stăpânire
50-69%:  ⚠️ ÎN PROGRES - Revizuiește conceptele cu scor <3
<50%:    🔄 NECESITĂ ATENȚIE - Recomand tutoriat sau studiu suplimentar
```

---

## PLAN PERSONAL DE ÎMBUNĂTĂȚIRE

### Identifică Zonele Slabe

```
Cele 3 concepte la care am cel mai mic scor:

1. _________________________________________________
   Plan de studiu: _________________________________
   
2. _________________________________________________
   Plan de studiu: _________________________________
   
3. _________________________________________________
   Plan de studiu: _________________________________
```

### Acțiuni Concrete

```
╔════════════════════════════════════════════════════════════════════╗
║  PLAN DE ACȚIUNE PENTRU SĂPTĂMÂNA URMĂTOARE                        ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  □ Voi practica ______________ timp de ___ minute/zi               ║
║                                                                    ║
║  □ Voi reciti secțiunea despre _________________ din material      ║
║                                                                    ║
║  □ Voi face exercițiile de la pagina ___ până la ___               ║
║                                                                    ║
║  □ Voi cere ajutor pentru conceptul: _________________________     ║
║                                                                    ║
║  □ Voi testa tema înainte de deadline (da/nu): ____                ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

---

## REFLECȚIE POST-SEMINAR

### Ce Am Învățat Azi

```
Completează în 2-3 propoziții pentru fiecare:

1. CEL MAI IMPORTANT concept nou pentru mine:
   
   ________________________________________________________________
   
   ________________________________________________________________

2. CEL MAI SURPRINZĂTOR lucru (nu mă așteptam):
   
   ________________________________________________________________
   
   ________________________________________________________________

3. CEL MAI UTIL pentru proiectele mele:
   
   ________________________________________________________________
   
   ________________________________________________________________
```

### Întrebări Rămase

```
Întrebări pe care încă le am:

1. ________________________________________________________________

2. ________________________________________________________________

3. ________________________________________________________________
```

---

## RESURSE PENTRU APROFUNDARE

### Documentație Oficială
- **GNU Bash Manual**: https://www.gnu.org/software/bash/manual/
- **POSIX Shell**: https://pubs.opengroup.org/onlinepubs/9699919799/

### Tutoriale Interactive
- **Learn Shell**: https://www.learnshell.org/
- **ShellCheck**: https://www.shellcheck.net/ (validare scripturi)

### Exerciții Practice
- **OverTheWire Bandit**: https://overthewire.org/wargames/bandit/
- **Command Line Challenge**: https://cmdchallenge.com/

### Cărți Recomandate
- "The Linux Command Line" - William Shotts (gratis online)
- "Classic Shell Scripting" - Robbins & Beebe

---

## TEMPLATE JURNALIZARE SĂPTĂMÂNALĂ

```bash
# Creează acest fișier și completează-l săptămânal
cat > ~/jurnal_bash_$(date +%Y%m%d).txt << 'EOF'
=== JURNAL ÎNVĂȚARE BASH ===
Data: [completează]
Timp petrecut: [ore/minute]

CE AM PRACTICAT:
1. 
2. 
3. 

CE AM ÎNVĂȚAT NOU:
1. 
2. 

CE MĂ BLOCHEAZĂ:
1. 

CE VOI FACE SĂPTĂMÂNA VIITOARE:
1. 

NIVEL CONFORT (1-10): ___

EOF
nano ~/jurnal_bash_$(date +%Y%m%d).txt
```

---

## CHECKLIST FINAL SEMINAR

Înainte de a pleca de la seminar, verifică:

```
□ Am completat toate checkpoint-urile de autoevaluare
□ Am identificat cel puțin 2 concepte de revizuit
□ Am un plan concret pentru săptămâna viitoare
□ Am notat întrebările pe care vreau să le pun
□ Am descărcat materialele pentru acasă
□ Înțeleg ce trebuie să fac pentru temă
□ Am testat cel puțin o comandă nouă azi
```

---

*Document generat pentru Seminarul 3-4 SO | ASE București - CSIE*  
*Autoevaluare metacognitivă pentru învățare eficientă*
