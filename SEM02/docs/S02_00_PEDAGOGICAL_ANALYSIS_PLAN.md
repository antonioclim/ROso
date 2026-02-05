# Analiză pedagogică și plan — Seminarul 02
## Sisteme de Operare | Operatori, redirecționare, filtre, bucle

**Document**: S02_00_PEDAGOGICAL_ANALYSIS_PLAN.md  
**Versiune**: 1.0 | **Dată**: ianuarie 2025  
**Autor**: ing. dr. Antonio Clim, ASE București - CSIE

---

## 1. Context și rațiune

### De ce contează acest seminar

După introducerea din S01 în elementele de bază ale shell‑ului și comenzile fundamentale, Seminarul 02 reprezintă, din observația mea acumulată pe parcursul a aproximativ opt generații de studenți CSIE, punctul de inflexiune critic. Aici „gândirea în pipeline‑uri” fie se fixează, fie nu se materializează: capacitatea de a descompune probleme complexe în secvențe de transformări simple, fiecare făcând un singur lucru bine.

Din notițele mele didactice de-a lungul anilor:
- Studenții care înțeleg **de ce** funcționează `cmd1 | cmd2` progresează rapid spre automatizare.
- Cei care doar memorează sintaxa se blochează invariabil la primul caz atipic.
- Confuzia clasică `>` versus `>>` versus `2>` persistă până la examene dacă nu este clarificată explicit în primele seminare.

În cele din urmă, nu este vorba doar despre „a scrie comenzi”, ci despre a gândi în fluxuri de date.

### Poziționare în curriculum

```
S01 (Baze shell) ──────► S02 (Pipeline-uri & bucle) ──────► S03 (Procese)
        │                         │                          │
   Fundament CLI             Compunere                  Paralelism
   Navigare FHS              Automatizare               Sincronizare
   Prima interacțiune        Primele scripturi          Controlul job-urilor
```

Acest seminar face puntea între „pot naviga” și „pot automatiza”. Reprezintă un salt cognitiv pe care unii studenți îl fac natural, în timp ce alții au nevoie de sprijin didactic explicit (scaffolding) — de aici varietatea metodelor pedagogice utilizate.

### O mărturisire din anii de început

Sincer: în prima mea iterație a acestui seminar am grăbit partea de bucle ca să „acopăr tot”. A fost un dezastru — jumătate din grupă a predat scripturi cu bug‑uri de tip `{1..$n}`, deoarece am trecut superficial peste motivul pentru care construcția nu funcționează. Acum construiesc deliberat un buffer de 5 minute pentru bucle și le spun studenților de la început: „Aici pică cele mai multe teme. Fiți atenți.”

A doua lecție: să nu demonstrez niciodată `cat | while read` fără să arăt imediat de ce „dispar” variabilele. Am văzut studenți pierzând ore întregi pentru a depana această situație.

---

## 2. Analiza publicului‑țintă

### Profil tipic (Anul 1, Semestrul 2, CSIE)

Aceste observații provin din chestionare de început de semestru și discuții informale:

| Caracteristică | Observație practică |
|----------------|----------------------|
| Experiență Linux | Minimă sau inexistentă; 90% au folosit exclusiv Windows, câțiva macOS |
| Fundal de programare | Algoritmi în C din semestrul 1; unii au Python din liceu |
| Motivație inițială | Variabilă; crește vizibil când văd aplicabilitate practică imediată |
| Disponibilitate de timp | Limitată (mulți au 6+ cursuri); temele trebuie să fie fezabile în 2–3 ore |
| Stil de învățare | Preferă „hands‑on”; teoria pură îi pierde după ~15 minute |

### Misconcepții frecvente (colectate din quiz‑uri și examinări)

Acestea sunt „hit‑urile” recurente, prezente an după an:

1. **„Pipe‑ul transmite fișiere între comenzi.”**  
   Nu, transmite un flux de octeți. Fișierul în sine nu „călătorește” nicăieri.

2. **„2>&1 înseamnă că stderr devine stdout.”**  
   Parțial corect, însă ordinea contează enorm — aproximativ 60% dintre studenți greșesc aici.

3. **„for i in {1..$n} funcționează.”**  
   Nu funcționează, deoarece expandarea acoladelor are loc ÎNAINTE de expandarea variabilelor. Capcană clasică.

4. **„cat file | while read line” este echivalent cu „while read line < file”.**  
   Nu este. Prima variantă creează un subshell; variabilele nu persistă. Am văzut ore pierdute la depanare din această cauză.

5. **„exit 0 înseamnă eroare.”**  
   Este invers. Convenția Unix este contraintuitivă pentru cei veniți din alte paradigme.

---

## 3. Rezultate ale învățării (Learning Outcomes)

Am structurat obiectivele pe trei niveluri ale taxonomiei Anderson‑Bloom, adaptate pentru studenți de anul I.

### Nivelul APPLY (Aplicare)

Acestea sunt competențele de bază — fără ele, studentul nu poate progresa.

| ID | Rezultat | Verificare |
|----|---------|--------------|
| LO1 | Combină comenzi folosind operatori de control (`;`, `&&`, `\|\|`, `&`) | Script funcțional care demonstrează fiecare operator |
| LO2 | Redirecționează corect intrarea/ieșirea (`>`, `>>`, `<`, `2>`, `2>&1`) | Separă stdout/stderr în fișiere diferite |
| LO3 | Construiește pipeline‑uri cu `\|` și `tee` | Minimum 3 comenzi înlănțuite logic |
| LO4 | Utilizează filtre de text: `sort`, `uniq`, `cut`, `paste`, `tr`, `wc`, `head`, `tail` | Procesează un CSV sau un log cu rezultat corect |
| LO5 | Scrie bucle `for`, `while`, `until` cu `break` și `continue` | Script cu iterație controlată |

### Nivelul ANALYSE (Analiză)

Pentru studenții care vor să înțeleagă nu doar „cum”, ci și „de ce”:

| ID | Rezultat | Verificare |
|----|---------|--------------|
| LO6 | Diagnostichează erori folosind coduri de ieșire și PIPESTATUS | Explică corect un comportament neașteptat |
| LO7 | Compară eficiența unor abordări diferite pentru aceeași problemă | Argumentare pro/contra în REFLECTION.md |
| LO8 | Evaluează critic cod generat de LLM pentru corectitudine | Identifică minimum 3 probleme în codul AI |

### Nivelul CREATE (Creare)

Pentru studenți avansați și pentru proiectul final:

| ID | Rezultat | Verificare |
|----|---------|--------------|
| LO9 | Proiectează pipeline‑uri pentru procesare de date | Soluție originală pentru o problemă nouă |
| LO10 | Automatizează sarcini administrative repetitive | Script reutilizabil, parametrizat |

---

## 4. Strategie pedagogică

### Abordarea „sandwich” (teorie‑practică‑teorie)

Am experimentat, de-a lungul anilor, cu mai multe structuri. Următoarea funcționează cel mai bine pentru cohorta‑țintă:

```
╔═══════════════════════════════════════════════════════════════════════════╗
║  10 min │ HOOK: demonstrație spectaculoasă — arată ce vor putea obține   ║
╠═══════════════════════════════════════════════════════════════════════════╣
║  15 min │ TEORIE: concept cu diagrame vizuale, fără cod încă            ║
╠═══════════════════════════════════════════════════════════════════════════╣
║  25 min │ PRACTICĂ GHIDATĂ: exerciții pas-cu-pas + probleme Parsons     ║
╠═══════════════════════════════════════════════════════════════════════════╣
║  10 min │ PEER INSTRUCTION: vot, discuție în perechi, revot            ║
╠═══════════════════════════════════════════════════════════════════════════╣
║  25 min │ SPRINT: exerciții individuale cu feedback imediat             ║
╠═══════════════════════════════════════════════════════════════════════════╣
║   5 min │ ÎNCHEIERE: sinteză, preview temă, întrebări                   ║
╚═══════════════════════════════════════════════════════════════════════════╝
```

### De ce Probleme Parsons pentru Bash?

Am descoperit această tehnică în literatura de educație în informatică (Parsons & Haden, 2006). Pentru Bash s-a dovedit surprinzător de eficientă:

- **Elimină „anxietatea foii albe”**: studenții au piesele, trebuie doar să le ordoneze.
- **Distractorii evidențiază capcane**: spații în jurul lui `=`, ghilimele incorecte, ordinea redirecționărilor.
- **Timp predictibil**: aproximativ 5 minute per problemă, ușor de planificat.
- **Feedback imediat**: soluțiile pot fi verificate instant prin rulare.

### Integrarea LLM

**Poziția mea pedagogică**: nu interzicem; educăm pentru utilizare critică.

Rațiune: absolvenții noștri vor lucra cu GitHub Copilot, ChatGPT, Claude și instrumente similare. Dacă nu îi învățăm acum să evalueze critic codul generat, vor comite erori costisitoare în producție.

Concret, abordarea noastră:
1. **Exerciții dedicate** pentru evaluarea codului LLM (vezi S02_07)
2. **Prompt engineering** ca abilitate explicită, nu subiect tabu
3. Comparație **„eu versus AI”** pentru dezvoltare metacognitivă
4. **Documentarea obligatorie** a utilizării AI în teme

---

## 5. Plan de evaluare

### Evaluare formativă (în timpul seminarului)

| Instrument | Când | Ce măsoară |
|------------|------|------------------|
| Quiz interactiv YAML | După fiecare secțiune majoră | Înțelegerea conceptelor |
| Probleme Parsons | În practica ghidată | Stăpânirea sintaxei |
| Peer Instruction | La mijlocul seminarului | Clarificarea misconcepțiilor |
| Autoevaluare | Ultimele 5 minute | Reflecție și metacogniție |

Feedback‑ul este imediat — nu așteptăm tema ca să corectăm direcția.

### Evaluare sumativă (temă pentru acasă)

Tema cuprinde 6 părți (vezi S02_01_HOMEWORK.md):
- Părțile 1–5: exerciții tehnice progresive (90%)
- Partea 6: verificare de înțelegere — exercițiu anti‑AI (5%)
- REFLECTION.md: document reflexiv obligatoriu (5%)

În plus:
- Bonus pentru soluții deosebit de elegante (+20%)

### Filosofie de notare

Prefer să evaluez **procesul**, nu doar rezultatul:
- Script funcțional, dar cu copy‑paste fără înțelegere = notă medie.
- Script cu erori minore, dar cu REFLECTION.md care arată înțelegere profundă = notă bună.
- Soluție elegantă + reflecție + sprijin pentru colegi = punctaj maxim + recomandare.

---

## 6. Resurse și timp

### Alocare tipică a activităților (90 de minute)

| Secțiune | Durată | Conținut principal |
|---------|----------|------------------------|
| Hook + introducere | 10 min | One‑liner impresionant, setarea contextului |
| Operatori | 15 min | `;` `&&` `\|\|` `&` cu demonstrații |
| Redirecționare | 20 min | `>` `>>` `2>` `2>&1` `<<` + codare live |
| Pauză informală | 5 min | Întrebări, spațiu de respiro |
| Filtre & pipe‑uri | 15 min | Construire progresivă de pipeline |
| Bucle | 20 min | `for` `while` + Parsons *(crescut de la 15)* |
| Încheiere | 5 min | Sinteză, preview temă |

### Materiale necesare (checklist pentru instructor)

- [ ] Laborator cu Ubuntu 22.04 funcțional sau WSL2 pe toate stațiile
- [ ] Videoproiector conectat, terminal vizibil din ultimele rânduri
- [ ] Scriptul `setup_seminar.sh` rulat înainte de curs
- [ ] Runner‑ul de quiz testat (`make quiz`)
- [ ] Fișiere de test în `/tmp/sem02_demo/`
- [ ] PDF de rezervă pentru slide‑uri (în caz de probleme tehnice)

---

## 7. Considerații speciale

### Accesibilitate

- Font mărit în terminal (minimum 18pt) pentru vizibilitate
- Cheat sheet disponibil și în format imprimabil
- Timp extins la exerciții pentru studenții cu nevoi speciale
- Opțiune de înregistrare a sesiunii pentru vizionare ulterioară

### Studenți avansați

Pentru cei care termină rapid exercițiile:
- Exerciții bonus în temă
- Provocare: optimizarea pipeline‑ului pentru viteză
- Rol de „consultant” pentru colegii care au nevoie de sprijin

### Studenți care întâmpină dificultăți

- Ore de consultanță înainte de deadline
- Resurse suplimentare în S02_RESOURCES.md
- Tutorare între colegi încurajată (cu atribuire în REFLECTION.md)

---

## 8. Cartografiere pe programa oficială

| Competență din programă | LO acoperite | Nivel Bloom |
|-------------------------|--------------|-------------|
| K3.1 Utilizarea shell‑ului Linux | LO1, LO2, LO3, LO4, LO5 | Apply |
| K3.2 Automatizarea sarcinilor | LO9, LO10 | Create |
| S2.1 Analiza și rezolvarea problemelor | LO6, LO7 | Analyse |
| S2.2 Gândire critică | LO8 | Evaluate |

---

## 9. Retrospectivă și îmbunătățiri planificate

### Ce a funcționat bine în iterațiile anterioare
- Probleme Parsons — implicare ridicată
- Demonstrații „spectaculoase” la început — captează atenția eficient
- Peer Instruction — clarifică rapid misconcepțiile

### Ce necesită îmbunătățire
- Timpul pentru bucle este adesea insuficient
- Unii studenți încă confundă `>` și `>>` la final
- Exercițiile LLM‑aware necesită actualizări constante (modelele evoluează)

### TODO pentru următoarea iterație
- [ ] Video scurt pentru fiecare concept (flipped classroom)
- [ ] Gamificare: leaderboard pentru quiz‑uri
- [ ] Mai multe exerciții de depanare (studenții cer explicit acestea)

---

## Anexă: bibliografie pedagogică

Abordările din acest seminar sunt informate de:

1. Parsons, D. & Haden, P. (2006). „Parson's Programming Puzzles: A Fun and Effective Learning Tool for First Programming Courses”
2. Mazur, E. (1997). „Peer Instruction: A User's Manual”
3. Wiggins, G. & McTighe, J. (2005). „Understanding by Design” (Backward Design)
4. Anderson, L. W. & Krathwohl, D. R. (2001). „A Taxonomy for Learning, Teaching, and Assessing”

---

*Document de planificare pedagogică pentru uz intern*  
*Seminarul 02 — Sisteme de Operare | ASE București - CSIE*  
*Ultima actualizare: ianuarie 2025*
