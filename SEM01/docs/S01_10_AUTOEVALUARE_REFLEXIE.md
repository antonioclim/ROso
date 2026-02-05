# Autoevaluare și Reflecție - Seminarul 1-2
## Checkpoints Metacognitive pentru Studenți

**Scop**: Monitorizează-ți propria înțelegere și identifică zonele de îmbunătățit

---

## CHECKPOINT ÎNAINTE DE SEMINAR

Completează ÎNAINTE de a începe seminarul:

```
╔═══════════════════════════════════════════════════════════════════════════╗
║                    EVALUARE INIȚIALĂ - CE ȘTIU DEJA?                      ║
╠═══════════════════════════════════════════════════════════════════════════╣
║                                                                           ║
║  Evaluează-te pe o scară de 1-5 pentru fiecare abilitate:                ║
║  1 = Nu am auzit de asta                                                  ║
║  2 = Am auzit, dar nu am folosit                                          ║
║  3 = Am folosit puțin, dar nu sunt sigur                                  ║
║  4 = Mă descurc, dar mai am de învățat                                    ║
║  5 = Stăpânesc bine                                                       ║
║                                                                           ║
║  ┌───────────────────────────────────────────────────┬──────────────────┐ ║
║  │ ABILITATE                                         │ SCOR (1-5)       │ ║
║  ├───────────────────────────────────────────────────┼──────────────────┤ ║
║  │ Navigare în terminal (cd, ls, pwd)                │ [   ]            │ ║
║  │ Creare fișiere și directoare (touch, mkdir)       │ [   ]            │ ║
║  │ Copiere, mutare, ștergere (cp, mv, rm)            │ [   ]            │ ║
║  │ Variabile în Bash ($VAR, export)                  │ [   ]            │ ║
║  │ Diferența între ' și " (quoting)                  │ [   ]            │ ║
║  │ Wildcards (*, ?, [...])                           │ [   ]            │ ║
║  │ Configurarea .bashrc                              │ [   ]            │ ║
║  │ Ierarhia sistemului de fișiere Linux              │ [   ]            │ ║
║  └───────────────────────────────────────────────────┴──────────────────┘ ║
║                                                                           ║
║  CE SPER SĂ ÎNVĂȚ AZI?                                                    ║
║  _______________________________________________________________________  ║
║  _______________________________________________________________________  ║
║                                                                           ║
║  CE ÎNTREBĂRI AM DEJA?                                                    ║
║  _______________________________________________________________________  ║
║  _______________________________________________________________________  ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝
```

---

## CHECKPOINT LA PAUZĂ (după primele 50 min)

```
╔═══════════════════════════════════════════════════════════════════════════╗
║                    REFLECȚIE DE PAUZĂ - PRIMA PARTE                       ║
╠═══════════════════════════════════════════════════════════════════════════╣
║                                                                           ║
║  1. CE A FOST CEL MAI SURPRINZĂTOR lucru din prima parte?                ║
║     _________________________________________________________________     ║
║     _________________________________________________________________     ║
║                                                                           ║
║  2. CE ÎNCĂ NU ÎNȚELEG COMPLET?                                           ║
║     _________________________________________________________________     ║
║     _________________________________________________________________     ║
║                                                                           ║
║  3. CE ÎNTREBARE VREAU SĂ PUN după pauză?                                ║
║     _________________________________________________________________     ║
║                                                                           ║
║  4. NIVEL DE ENERGIE (1-5): [   ]                                         ║
║                                                                           ║
║  5. NIVEL DE ÎNȚELEGERE până acum (1-5): [   ]                           ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝
```

---

## CHECKPOINT FINAL (după seminar)

```
╔═══════════════════════════════════════════════════════════════════════════╗
║                    EVALUARE FINALĂ - CE AM ÎNVĂȚAT?                       ║
╠═══════════════════════════════════════════════════════════════════════════╣
║                                                                           ║
║  Re-evaluează-te pe aceeași scară (1-5):                                 ║
║                                                                           ║
║  ┌───────────────────────────────────────────────────┬────────┬────────┐ ║
║  │ ABILITATE                                         │ ÎNAINTE│ DUPĂ   │ ║
║  ├───────────────────────────────────────────────────┼────────┼────────┤ ║
║  │ Navigare în terminal (cd, ls, pwd)                │ [   ]  │ [   ]  │ ║
║  │ Creare fișiere și directoare (touch, mkdir)       │ [   ]  │ [   ]  │ ║
║  │ Copiere, mutare, ștergere (cp, mv, rm)            │ [   ]  │ [   ]  │ ║
║  │ Variabile în Bash ($VAR, export)                  │ [   ]  │ [   ]  │ ║
║  │ Diferența între ' și " (quoting)                  │ [   ]  │ [   ]  │ ║
║  │ Wildcards (*, ?, [...])                           │ [   ]  │ [   ]  │ ║
║  │ Configurarea .bashrc                              │ [   ]  │ [   ]  │ ║
║  │ Ierarhia sistemului de fișiere Linux              │ [   ]  │ [   ]  │ ║
║  └───────────────────────────────────────────────────┴────────┴────────┘ ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝
```

---

## VERIFICARE OBIECTIVE DE ÎNVĂȚARE

Bifează ce poți face ACUM:

```
═══════════════════════════════════════════════════════════════════════════

□  Pot naviga în sistemul de fișiere folosind cd, ls, pwd
   → Demonstrație: Navighează de la / la home și înapoi

□  Pot explica diferența conceptuală între kernel, shell și terminal
   → Test: Desenează diagrama celor 3 componente

□  Pot crea structuri de directoare folosind mkdir -p și brace expansion
   → Demonstrație: Creează webapp/{src,tests,docs} într-o comandă

□  Pot prezice output-ul comenzilor cu variabile și quoting diferit
   → Test: Ce afișează echo '$HOME' vs echo "$HOME" ?

□  Pot configura .bashrc cu alias-uri și PATH personalizat
   → Demonstrație: Adaugă un alias și verifică că funcționează

□  Pot evalua cod Bash pentru corectitudine și siguranță
   → Test: Ce e greșit în "VAR = value" ?

□  Pot explica diferența între variabile locale și de mediu
   → Test: De ce bash -c 'echo $VAR' nu afișează nimic pentru VAR local?

═══════════════════════════════════════════════════════════════════════════
```

---

## REFLECȚIE PROFUNDĂ (pentru acasă)

Completează în primele 24 de ore după seminar:

```
╔═══════════════════════════════════════════════════════════════════════════╗
║                         JURNAL DE REFLECȚIE                               ║
╠═══════════════════════════════════════════════════════════════════════════╣
║                                                                           ║
║  1. MOMENTUL "AHA!" - Când ai înțeles ceva care înainte părea confuz?    ║
║     _________________________________________________________________     ║
║     _________________________________________________________________     ║
║     _________________________________________________________________     ║
║                                                                           ║
║  2. CE A FOST CEL MAI GREU? De ce crezi că a fost dificil?               ║
║     _________________________________________________________________     ║
║     _________________________________________________________________     ║
║     _________________________________________________________________     ║
║                                                                           ║
║  3. CUM S-A SCHIMBAT înțelegerea ta despre terminal/shell față de        ║
║     ce credeai înainte?                                                   ║
║     _________________________________________________________________     ║
║     _________________________________________________________________     ║
║     _________________________________________________________________     ║
║                                                                           ║
║  4. CUM AI PUTEA FOLOSI ce ai învățat în viața reală? (proiecte,         ║
║     automatizare, etc.)                                                   ║
║     _________________________________________________________________     ║
║     _________________________________________________________________     ║
║     _________________________________________________________________     ║
║                                                                           ║
║  5. CE ÎNTREBĂRI NOI au apărut? Ce vrei să explorezi mai departe?        ║
║     _________________________________________________________________     ║
║     _________________________________________________________________     ║
║     _________________________________________________________________     ║
║                                                                           ║
║  6. Dacă ar trebui să explici UNUI COLEG ce e shell-ul și cum se         ║
║     folosește, ce ai spune în 3 propoziții?                              ║
║     _________________________________________________________________     ║
║     _________________________________________________________________     ║
║     _________________________________________________________________     ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝
```

---

## PLAN DE PRACTICĂ PERSONALĂ

Pe baza auto-evaluării, creează-ți un plan:

### Săptămâna aceasta voi exersa:

| Zi | Ce voi face (15-30 min) | Resurse necesare |
|----|-------------------------|------------------|
| Luni | | |
| Marți | | |
| Miercuri | | |
| Joi | | |
| Vineri | | |
| Weekend | | |

### Idei de practică:
- [ ] Refac exercițiile de la seminar fără să mă uit la soluții
- [ ] Configurez .bashrc-ul meu cu alias-uri utile
- [ ] Creez un script simplu care automatizează ceva repetitiv
- [ ] Explorez un director nou din sistem (ex: /var/log)
- [ ] Citesc `man bash` secțiunea despre quoting
- [ ] Încerc comenzi noi din BASH_MAGIC_COLLECTION

---

## RUBRICA DE AUTO-EVALUARE

Folosește această rubrică pentru a-ți evalua progresul:

### Nivel: ÎNCEPĂTOR (1-2)
- Pot recunoaște comenzile când le văd
- Am nevoie de cheat sheet pentru majoritatea operațiilor
- Fac erori frecvente de sintaxă
- Înțeleg ce fac comenzile dar nu și DE CE

### Nivel: COMPETENT (3-4)
- Pot folosi comenzile de bază fără ajutor
- Înțeleg diferențele subtile (quoting, wildcards)
- Pot depana erori simple
- Pot explica colegilor conceptele de bază

### Nivel: AVANSAT (5)
- Pot combina comenzi în moduri creative
- Înțeleg implicațiile de siguranță
- Pot scrie scripturi simple
- Pot învăța singur comenzi noi din man pages

---

## FEEDBACK PENTRU INSTRUCTOR

Ajută-ne să îmbunătățim seminarul:

```
1. Ce a funcționat BINE în acest seminar?
   _________________________________________________________________

2. Ce ar fi putut fi MAI BUN?
   _________________________________________________________________

3. Ritmul a fost: □ Prea rapid  □ Potrivit  □ Prea lent

4. Exercițiile au fost: □ Prea ușoare  □ Potrivite  □ Prea grele

5. Ce alt subiect ai vrea să fie acoperit în seminarele viitoare?
   _________________________________________________________________

6. Recomandare pentru colegii din anii următori (sfat pentru seminar):
   _________________________________________________________________
```

---

## CONEXIUNI CU ALTE MATERII

Reflectează cum se leagă ce ai învățat:

| Materie | Conexiune cu seminarul de azi |
|---------|-------------------------------|
| Programare | Variabilele sunt similare cu variabilele din Python/Java |
| Rețele | Voi folosi terminal pentru configurări de rețea |
| Baze de date | Scripturi pentru backup și automatizare |
| Web | Deployment pe servere Linux |

---

*Autoevaluare și Reflecție | SO Seminarul 1-2 | ASE-CSIE*
