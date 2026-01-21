# Material Principal: Operatori, Redirecționare, Filtre, Bucle
## Sisteme de Operare | ASE București - CSIE

> Observație din laborator: notează-ţi comenzi‑cheie şi output‑ul relevant (2–3 linii) pe măsură ce lucrezi. Te ajută la debug şi, sincer, la final îţi iese şi un README bun fără efort suplimentar.
Versiune: 1.0 | Seminar: 3-4  
abordare: Limbaj ca Vehicul (Bash pentru înțelegerea conceptelor SO)  
Timp estimat de studiu: 3-4 ore

---

## Obiective de Învățare

La finalul studierii acestui material, vei putea:

| # | Obiectiv | Nivel Bloom | Verificare |
|---|----------|-------------|------------|
| O1 | Explica diferența dintre `;`, `&&`, `||` și `&` | Înțelegere | Quiz PI |
| O2 | Construi pipeline-uri eficiente cu `\|` | Aplicare | Sprint |
| O3 | Redirecționa stdout, stderr și stdin corect | Aplicare | Exerciții |
| O4 | Utiliza filtrele `sort`, `uniq`, `cut`, `tr`, `wc`, `head`, `tail` | Aplicare | Sprint |
| O5 | Scrie bucle `for`, `while`, `until` cu control flow | Aplicare | Temă |
| O6 | Depana scripturi cu probleme comune (subshell, brace expansion) | Analiză | LLM Exercise |
| O7 | Combina toate elementele într-un script funcțional | Sinteză | Proiect |

---

## Cuprins

1. [MODULUL 1: Operatori de Control](#modulul-1-operatori-de-control)
   - 1.1 Introducere în Operatori
   - 1.2 Operatorul Secvențial (`;`)
   - 1.3 Operatorul AND (`&&`)
   - 1.4 Operatorul OR (`||`)
   - 1.5 Combinații AND și OR
   - 1.6 Operatorul Background (`&`)
   - 1.7 Gruparea Comenzilor
   - 1.8 Exit Codes și `$?`

2. [MODULUL 2: Redirecționare I/O](#modulul-2-redirecționare-io)
   - 2.1 File Descriptors
   - 2.2 Redirecționare Output
   - 2.3 Redirecționare Input
   - 2.4 Here Documents
   - 2.5 Here Strings
   - 2.6 Suprimarea Output-ului

3. [MODULUL 3: Filtre de Text](#modulul-3-filtre-de-text)
   - 3.1 Filosofia Unix
   - 3.2 sort - Sortare
   - 3.3 uniq - Eliminare Duplicate
   - 3.4 cut - Extragere Coloane
   - 3.5 paste - Îmbinare Fișiere
   - 3.6 tr - modificare Caractere
   - 3.7 wc - Numărare
   - 3.8 head și tail
   - 3.9 tee - Duplicare Stream
   - 3.10 Pipeline-uri Complexe

*(Pipe-urile sunt geniul Unix-ului. Combin comenzi simple pentru a rezolva probleme complexe.)*


4. [MODULUL 4: Bucle](#modulul-4-bucle)
   - 4.1 Bucla for - Listă
   - 4.2 Bucla for - Stil C
   - 4.3 Bucla while
   - 4.4 Bucla until
   - 4.5 break și continue
   - 4.6 Exemple Practice Integrate

5. [Rezumat și Cheat Sheet](#rezumat-și-cheat-sheet)
6. [Legături cu Alte Concepte](#legături-cu-alte-concepte)

---

# MODULUL 1: OPERATORI DE CONTROL

## 1.1 Introducere în Operatori

Operatorii de control permit combinarea mai multor comenzi într-o singură linie sau script, controlând fluxul de execuție în funcție de rezultatul comenzilor anterioare.

De ce sunt importanți?
- Scripturi mai concise și eficiente
- Gestionarea erorilor fără if-uri explicite
- Automatizarea task-urilor complexe
- Baza pentru scripting avansat

Operatorii pe care îi vom studia:

| Operator | Nume | Comportament |
|----------|------|--------------|
| `;` | Secvențial | Execută toate, ignoră rezultatul |
| `&&` | AND | Execută următoarea DOAR dacă precedenta a REUȘIT |
| `\|\|` | OR | Execută următoarea DOAR dacă precedenta a EȘUAT |
| `&` | Background | Trimite comanda în fundal |
| `\|` | Pipe | Conectează stdout la stdin |

---

## 1.2 Operatorul Secvențial (`;`)

🎯 SUBGOAL 1.2.1: Înțelege execuția secvențială

Operatorul `;` (punct și virgulă) separă comenzi care se execută una după alta, indiferent de rezultat. Este echivalent cu scrierea comenzilor pe linii separate.

```bash
# Trei comenzi separate de ;
echo "Prima comandă" ; echo "A doua comandă" ; echo "A treia comandă"
```

Comportament cheie: Chiar dacă o comandă eșuează, următoarele se execută!

```bash
# Demonstrație: comanda din mijloc eșuează
echo "Start" ; ls /director_inexistent ; echo "Continuăm oricum"
# Output: Start
# ls: cannot access '/director_inexistent': No such file or directory
# Continuăm oricum
```

🎯 SUBGOAL 1.2.2: Aplică în context practic

Când folosim `;`:
- Comenzi independente care nu depind una de alta
- Secvențe simple de operații
- Când vrem să executăm tot, indiferent de erori
- Citește mesajele de eroare cu atenție — conțin indicii valoroase

```bash
# Exemplu practic: cleanup și setup
cd ~ ; rm -rf temp ; mkdir temp ; cd temp
# Toate se execută, chiar dacă rm eșuează (directorul nu există)
```

**⚠️ Atenție**: Pentru operații critice unde eșecul contează, folosește `&&`!

---

## 1.3 Operatorul AND (`&&`)

🎯 SUBGOAL 1.3.1: Înțelege evaluarea scurt-circuit

Operatorul `&&` (AND logic) execută comanda următoare DOAR dacă comanda precedentă a REUȘIT (exit code 0).

```bash
# Structura:
cmd1 && cmd2
# cmd2 se execută DOAR dacă cmd1 returnează exit code 0
```

Demonstrație:
```bash
# Succes → continuă
mkdir proiect && echo "Director creat cu succes!"
# Output: Director creat cu
# Eșec → oprește
mkdir proiect && echo "Creat!"  # a doua oară
# Output: mkdir: cannot create directory 'proiect': File exists
# echo NU se execută!
```

🎯 SUBGOAL 1.3.2: Aplică pattern-uri comune

Pattern 1: Înlănțuire de operații dependente
```bash

*Notă personală: Bash-ul are o sintaxă urâtă, recunosc. Dar rulează peste tot, și asta contează enorm în practică.*

# Toate trebuie să reușească pentru a continua
cd /var/log && grep "error" syslog && echo "Erori găsite"
```

Pattern 2: Verificare înainte de acțiune
```bash
# Verifică existența fișierului înainte de procesare
[ -f config.txt ] && source config.txt
```

Pattern 3: Creare și navigare
```bash
# Creează directorul și intră în el
mkdir -p proiect/src && cd proiect/src
```

---

## 1.4 Operatorul OR (`||`)

🎯 SUBGOAL 1.4.1: Înțelege logica OR

Operatorul `||` (OR logic) execută comanda următoare DOAR dacă comanda precedentă a EȘUAT (exit code non-zero).

> 💡 *La examenele din sesiunile trecute, această întrebare a apărut frecvent — deci merită atenție.*


```bash
# Structura:
cmd1 || cmd2
# cmd2 se execută DOAR dacă cmd1 returnează exit code != 0
```

Demonstrație:
```bash
# Eșec → execută fallback
ls /inexistent || echo "Directorul nu există"
# Output: ls: cannot access...: No such file or directory
# Directorul nu există

# Succes → NU execută fallback
ls /home || echo "Acest mesaj nu apare"
# Output: (listarea directorului /home)
```

🎯 SUBGOAL 1.4.2: Aplică pattern-uri de fallback

Pattern 1: Valoare implicită
```bash
# Folosește directorul din variabilă sau home
cd "$WORKDIR" || cd ~
```

Pattern 2: Creare dacă nu există
```bash
# Creează directorul doar dacă nu există deja
[ -d backup ] || mkdir backup
```

Pattern 3: Mesaj de eroare
```bash
# Raportează eroarea
cp important.txt backup/ || echo "Capcană: Backup eșuat!"
```

---

## 1.5 Combinații AND și OR

🎯 SUBGOAL 1.5.1: Construiește pattern-ul succes/eroare

Combinând `&&` și `||` putem crea structuri complete de handling pentru succes și eroare:

```bash
# Pattern complet: comandă && succes || eroare
mkdir test && echo "Succes" || echo "Eroare"
```

**⚠️ ATENȚIE CRITICĂ: Ordinea contează!**

```bash
# CORECT: succes APOI eroare
mkdir test && echo "OK" || echo "FAIL"
# Dacă mkdir reușește: "OK"
# Dacă mkdir eșuează: "FAIL"

# GREȘIT: eroare APOI succes - comportament neașteptat!
mkdir test || echo "FAIL" && echo "OK"
# Dacă mkdir eșuează: "FAIL" și "OK"! (pentru că echo "FAIL" reușește)
```

🎯 SUBGOAL 1.5.2: Grupare pentru comportament corect

Pentru comportament predictibil, folosește gruparea cu `{}`:

```bash
# Grupare corectă cu acolade
mkdir test && { echo "Succes"; ls test; } || { echo "Eroare"; exit 1; }

> 💡 Am observat că studenții care desenează diagrama pe hârtie înainte de a scrie codul au rezultate mult mai bune.

```

Regulă de aur: Când combini `&&` și `||`, pune întotdeauna acțiunea de succes DUPĂ `&&` și acțiunea de eroare DUPĂ `||`.

---

## 1.6 Operatorul Background (`&`)

🎯 SUBGOAL 1.6.1: Înțelege execuția în fundal

Operatorul `&` (ampersand) la finalul unei comenzi o trimite în **background** (fundal), permițând shell-ului să continue imediat.

```bash
# Sintaxa:
cmd &
# Comanda rulează în fundal, shell-ul e liber pentru altă comandă
```

Demonstrație:
```bash
# Comandă care durează
sleep 10 &
echo "Shell-ul e liber! PID: $!"

# $! conține PID-ul ultimului proces background
```

🎯 SUBGOAL 1.6.2: Gestionează job-urile background

Comenzi pentru job control:

| Comandă | Funcție |
|---------|---------|
| `jobs` | Listează job-urile active |
| `fg` | Aduce job-ul în foreground |
| `fg %n` | Aduce job-ul #n în foreground |
| `bg` | Continuă job-ul suspendat în background |
| `wait` | Așteaptă terminarea tuturor job-urilor |
| `wait $PID` | Așteaptă terminarea unui proces specific |

```bash
# Exemplu complet
sleep 5 &
sleep 3 &
jobs
# Output: [1]- Running sleep 5 &
# [2]+ Running sleep 3 &

wait  # așteaptă ambele
echo "Toate procesele au terminat"
```

Suspendare cu Ctrl+Z:
```bash
sleep 100  # rulează în foreground
# Apasă Ctrl+Z
# Output: [1]+ Stopped sleep 100

bg  # continuă în background
fg  # revino în foreground
```

---

## 1.7 Gruparea Comenzilor

🎯 SUBGOAL 1.7.1: Diferențiază `{}` de `()`

Există două modalități de a grupa comenzi, cu comportamente diferite:

Acolade `{}` - Grupare în shell-ul curent:
```bash
# Comenzile rulează în shell-ul curent
# Capcană: spații și ; sunt obligatorii!
{ echo "Una"; echo "Două"; }

# Variabilele persistă
{ x=10; }
echo $x  # 10
```

Paranteze `()` - Subshell:
```bash
# Comenzile rulează într-un subshell separat
(echo "Una"; echo "Două")

# Variabilele NU persistă
(x=10)
echo $x  # gol sau valoarea anterioară
```

🎯 SUBGOAL 1.7.2: Alege metoda corectă

| Situație | Folosește | Motiv |
|----------|-----------|-------|
| Modifici variabile care trebuie să persiste | `{}` | Rulează în shell-ul curent |
| Schimbi directorul temporar | `()` | cd-ul nu afectează shell-ul principal |
| Grupezi pentru redirecționare | ambele | Ambele funcționează similar |
| Izolezi un mediu de lucru | `()` | Subshell-ul e independent |

```bash
# Exemplu: cd temporar
(cd /tmp; ls)  # listează /tmp
pwd  # încă suntem în directorul original

# vs
{ cd /tmp; ls; }
pwd  # acum suntem în /tmp!
```

---

## 1.8 Exit Codes și `$?`

🎯 SUBGOAL 1.8.1: Înțelege sistemul de exit codes

Fiecare comandă Unix returnează un exit code (cod de ieșire) - un număr între 0 și 255.

| Exit Code | Semnificație |
|-----------|--------------|
| 0 | Succes |
| 1 | Eroare generală |
| 2 | Utilizare greșită a comenzii |
| 126 | Permisiune refuzată (nu e executabil) |
| 127 | Comandă negăsită |
| 128+N | Terminat de semnalul N |
| 130 | Ctrl+C (SIGINT) |
| 137 | kill -9 (SIGKILL) |

Verificarea exit code-ului:
```bash
ls /home
echo $?  # 0 (succes)

ls /inexistent
echo $?  # 2 (eroare)
```

🎯 SUBGOAL 1.8.2: Folosește exit codes în scripturi

Verificare explicită:
```bash
#!/bin/bash
cp fisier.txt backup/
if [ $? -eq 0 ]; then
    echo "Backup reușit"
else
    echo "Backup eșuat"
    exit 1
fi
```

Verificare simplificată cu `&&`/`||`:
```bash
cp fisier.txt backup/ && echo "OK" || echo "FAIL"
```

Comenzi utile pentru teste:
```bash
true   # returnează întotdeauna 0
false  # returnează întotdeauna 1

# Test condiții
[ -f fisier.txt ]  # 0 dacă există, 1 dacă nu
[ -d director ]    # 0 dacă e director, 1 dacă nu
```

---

# MODULUL 2: REDIRECȚIONARE I/O

## 2.1 File Descriptors

🎯 SUBGOAL 2.1.1: Înțelege modelul I/O Unix

În Unix, fiecare proces are trei canale de comunicare standard:

```
┌─────────────────────────────────────────────────────────┐
│                      PROCES                              │
│  ┌─────────┐                                            │
│  │  stdin  │ ←── fd 0: Input (tastatura implicit)       │
│  └─────────┘                                            │
│  ┌─────────┐                                            │
│  │ stdout  │ ──→ fd 1: Output normal (ecran implicit)   │
│  └─────────┘                                            │
│  ┌─────────┐                                            │
│  │ stderr  │ ──→ fd 2: Erori (ecran implicit)           │
│  └─────────┘                                            │
└─────────────────────────────────────────────────────────┘
```

File Descriptor (fd): Un număr care identifică un canal I/O.

| fd | Nume | Implicit | Descriere |
|----|------|----------|-----------|
| 0 | stdin | tastatura | Date de intrare |
| 1 | stdout | ecran | Output normal |
| 2 | stderr | ecran | Mesaje de eroare |

🎯 SUBGOAL 2.1.2: Vizualizează fluxurile

```bash
# Comanda ls produce output pe ambele canale
ls /home /inexistent
# stdout: listarea lui /home
# stderr: "ls: cannot access '/inexistent': No such file or directory"

# Ambele merg la ecran implicit, dar sunt canale SEPARATE
```

---

## 2.2 Redirecționare Output

🎯 SUBGOAL 2.2.1: Redirecționează stdout

Operatorul `>` - Suprascriere:
```bash
# Trimite stdout într-un fișier (SUPRASCRIE!)
echo "Hello" > mesaj.txt
cat mesaj.txt  # Hello

echo "World" > mesaj.txt
cat mesaj.txt  # World (Hello a dispărut!)
```

Operatorul `>>` - Adăugare (append):
```bash
# Adaugă la sfârșitul fișierului
echo "Linia 1" > log.txt
echo "Linia 2" >> log.txt
echo "Linia 3" >> log.txt
cat log.txt
# Linia 1
# Linia 2
# Linia 3
```

🎯 SUBGOAL 2.2.2: Redirecționează stderr

```bash
# 2> redirecționează stderr
ls /inexistent 2> erori.txt
cat erori.txt  # mesajul de eroare

# 2>> adaugă erorile
ls /alta_inexistenta 2>> erori.txt
```

🎯 SUBGOAL 2.2.3: Combină stdout și stderr

Metoda 1: Destinații separate
```bash
# stdout în output.txt, stderr în errors.txt
ls /home /inexistent > output.txt 2> errors.txt
```

Metoda 2: Același fișier (ORDINEA CONTEAZĂ!)
```bash
# CORECT: stdout → fișier, apoi stderr → unde e stdout
ls /home /inexistent > all.txt 2>&1

# GREȘIT: stderr → stdout (ecran), apoi stdout → fișier
ls /home /inexistent 2>&1 > all.txt
# stderr merge tot pe ecran!
```

Metoda 3: Shortcut cu `&>`
```bash
# &> trimite ambele în același fișier
ls /home /inexistent &> all.txt
# Echivalent cu: > all.txt 2>&1
```

---

## 2.3 Redirecționare Input

🎯 SUBGOAL 2.3.1: Citește din fișier cu `<`

```bash
# În loc de: cat fisier | wc -l
# Folosește:
wc -l < fisier.txt

# Diferența: < nu creează un proces suplimentar (cat)
```

Exemplu practic:
```bash
# Sortează conținutul unui fișier
sort < lista.txt

# Echivalent dar mai eficient decât:
cat lista.txt | sort
```

---

## 2.4 Here Documents

🎯 SUBGOAL 2.4.1: Creează input multi-linie

Here Document (`<<`) permite furnizarea de input multi-linie direct în script:

```bash
# Sintaxa:
comandă << DELIMITER
linie 1
linie 2
linie 3
DELIMITER
```

Exemplu: creare fișier:
```bash
cat << EOF > config.txt
# Configurare aplicație
host=localhost
port=8080
debug=true
EOF
```

🎯 SUBGOAL 2.4.2: Controlează expansiunea variabilelor

Cu expansiune (DELIMITER fără ghilimele):
```bash
nume="Ion"
cat << EOF
Salut, $nume!
Directorul curent: $(pwd)
EOF
# Output: Salut, Ion!
# Directorul curent: /home/student
```

Fără expansiune (DELIMITER între ghilimele):
```bash
cat << 'EOF'
Variabila: $nume
Comandă: $(pwd)
EOF
# Output: Variabila: $nume
# Comandă: $(pwd)
```

🎯 SUBGOAL 2.4.3: Gestionează indentarea

`<<-` permite tab-uri la început (pentru scripturi indentate):

> 💡 Un student m-a întrebat odată de ce nu putem folosi doar interfața grafică pentru tot — răspunsul e că terminalul e de 10 ori mai rapid pentru operații repetitive.

```bash
if true; then
    cat <<- EOF
		Acest text e indentat cu tab-uri
		Dar ele vor fi eliminate din output
	EOF
fi
```

---

## 2.5 Here Strings

🎯 SUBGOAL 2.5.1: Furnizează string ca input

Here String (`<<<`) trimite un string direct ca stdin:

```bash
# În loc de: echo "text" | comandă
# Folosește:
wc -w <<< "trei cuvinte aici"
# Output: 3

# Cu variabilă
mesaj="Hello World"
wc -c <<< "$mesaj"
```

Avantaj: Nu creează subshell (ca la pipe cu echo).

---

## 2.6 Suprimarea Output-ului

🎯 SUBGOAL 2.6.1: Folosește /dev/null

`/dev/null` este un "fișier" special care elimină tot ce primește.

```bash
# Suprimă stdout
ls /home > /dev/null
# Nimic nu se afișează

# Suprimă stderr
ls /inexistent 2> /dev/null
# Eroarea nu se afișează

# Suprimă tot
ls /home /inexistent &> /dev/null
# Liniște totală
```

Pattern comun: verificare existență:
```bash
# Verifică dacă comanda există, fără output
command -v python3 &> /dev/null && echo "Python3 instalat"
```

---

# MODULUL 3: FILTRE DE TEXT

## 3.1 Filosofia Unix

🎯 SUBGOAL 3.1.1: Înțelege principiul filtrelor

Filozofia Unix promovează programe mici care fac un singur lucru bine:

```
┌──────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐
│  Input   │ ──→ │ Filter 1 │ ──→ │ Filter 2 │ ──→ │  Output  │
│  (stdin) │     │  (sort)  │     │  (uniq)  │     │ (stdout) │
└──────────┘     └──────────┘     └──────────┘     └──────────┘
```

Caracteristici:
- Citesc de la stdin (implicit sau explicit)
- Scriu la stdout
- Pot fi înlănțuite cu pipe (`|`)
- Fac o singură operație, dar bine

---

## 3.2 sort - Sortare

🎯 SUBGOAL 3.2.1: Sortează text alfabetic și numeric

```bash
# Sortare alfabetică (implicit)
sort fisier.txt

# Sortare numerică
sort -n numere.txt

# Sortare inversă (descrescător)
sort -r fisier.txt
sort -rn numere.txt  # numeric descrescător
```

🎯 SUBGOAL 3.2.2: Sortează după câmpuri

```bash
# Sortare după coloană specifică
# -k N : sortează după câmpul N
# -t DELIM : specifică delimitatorul

# Sortează CSV după coloana 3 (nota)
sort -t',' -k3 -n studenti.csv

# Sortează după coloana 3, apoi 1
sort -t',' -k3,3n -k1,1 studenti.csv
```

Opțiuni utile:

| Opțiune | Efect |
|---------|-------|
| `-n` | Sortare numerică |
| `-r` | Inversare (descrescător) |
| `-k N` | Sortează după câmpul N |
| `-t C` | Folosește C ca delimitator |
| `-u` | Elimină duplicatele (ca `sort \| uniq`) |
| `-h` | Sortare "human-readable" (1K, 2M, 3G) |
| `-f` | Ignoră case (A=a) |

---

## 3.3 uniq - Eliminare Duplicate

🎯 SUBGOAL 3.3.1: Înțelege limitarea critică

**⚠️ ATENȚIE MAXIMĂ**: `uniq` elimină doar duplicate CONSECUTIVE!

```bash
# Date de test
cat > colors.txt << 'EOF'
rosu
verde
rosu
albastru
EOF

# GREȘIT: uniq singur
uniq colors.txt
# rosu
# verde
# rosu ← încă apare!
# albastru

# CORECT: sort APOI uniq
sort colors.txt | uniq
# albastru
# rosu
# verde
```

🎯 SUBGOAL 3.3.2: Numără și filtrează duplicate

```bash
# Numără aparițiile
sort colors.txt | uniq -c
# 1 albastru
# 2 rosu
# 1 verde

# Sortează după frecvență
sort colors.txt | uniq -c | sort -rn
# 2 rosu
# 1 verde
# 1 albastru

# Afișează DOAR duplicatele
sort colors.txt | uniq -d
# rosu

# Afișează DOAR unicatele
sort colors.txt | uniq -u
# albastru
# verde
```

---

## 3.4 cut - Extragere Coloane

🎯 SUBGOAL 3.4.1: Extrage câmpuri cu delimitator

```bash
# -d : delimitator (implicit TAB!)
# -f : câmpuri de extras

# Extrage primul câmp (username din /etc/passwd)
cut -d':' -f1 /etc/passwd

# Extrage câmpurile 1 și 3
cut -d':' -f1,3 /etc/passwd

# Extrage câmpurile 1-3
cut -d':' -f1-3 /etc/passwd
```

🎯 SUBGOAL 3.4.2: Extrage caractere

```bash
# -c : poziții de caractere

# Primele 10 caractere
cut -c1-10 fisier.txt

# Caracterele 5-15
cut -c5-15 fisier.txt

# De la caracterul 20 până la final
cut -c20- fisier.txt
```

**⚠️ constrângeri importante**:
- Delimitatorul e un singur caracter
- Nu suportă regex
- Pentru cazuri complexe, folosește `awk`

---

## 3.5 paste - Îmbinare Fișiere

🎯 SUBGOAL 3.5.1: Combină fișiere în paralel

```bash
# paste pune liniile alăturate, separate de TAB

# Creează fișiere de test
echo -e "1\n2\n3" > numere.txt
echo -e "a\nb\nc" > litere.txt

paste numere.txt litere.txt
# 1 a
# 2 b
# 3 c

# Cu delimitator personalizat
paste -d',' numere.txt litere.txt
# 1,a
# 2,b
# 3,c
```

🎯 SUBGOAL 3.5.2: Serializează pe o singură linie

```bash
# -s : serializare (toate liniile pe un rând)
paste -s -d',' numere.txt
# 1,2,3

# Util pentru creare liste
ls | paste -s -d','
# fisier1.txt,fisier2.txt,fisier3.txt
```

---

## 3.6 tr - modificare Caractere

🎯 SUBGOAL 3.6.1: Înlocuiește caractere

De reținut: `tr` lucrează cu CARACTERE, nu cu stringuri!

```bash
# modificare lowercase → uppercase
echo "hello" | tr 'a-z' 'A-Z'
# HELLO

# Înlocuire set de caractere
echo "hello" | tr 'aeiou' '12345'
# h2ll4

# Capcană: nu înlocuiește stringuri!
echo "hello" | tr 'he' 'HE'
# HEllo (fiecare caracter separat!)
```

🎯 SUBGOAL 3.6.2: Șterge și comprimă caractere

```bash
# Ștergere caractere (-d)
echo "hello123world" | tr -d '0-9'
# helloworld

# Complement (-c): operează pe ce NU e în set
echo "hello123world" | tr -cd '0-9'
# 123

# Squeeze (-s): comprimă repetări consecutive
echo "heeellooo" | tr -s 'eo'
# helo

# Utilitar: normalizare spații
echo "prea   multe    spații" | tr -s ' '
# prea multe spații
```

Clase de caractere:

| Clasă | Semnificație |
|-------|--------------|
| `[:alnum:]` | Alfanumerice |
| `[:alpha:]` | Litere |
| `[:digit:]` | Cifre |
| `[:space:]` | Spații (include tab, newline) |
| `[:upper:]` | Majuscule |
| `[:lower:]` | Minuscule |

```bash
# Convertire cu clase
echo "Hello World" | tr '[:upper:]' '[:lower:]'
# hello world
```

---

## 3.7 wc - Numărare

🎯 SUBGOAL 3.7.1: Numără linii, cuvinte, caractere

```bash
# Toate statisticile
wc fisier.txt
# 10 50 300 fisier.txt
# linii cuvinte bytes

# Doar linii
wc -l fisier.txt

# Doar cuvinte
wc -w fisier.txt

# Doar caractere
wc -c fisier.txt  # bytes
wc -m fisier.txt  # caractere (pentru Unicode)
```

🎯 SUBGOAL 3.7.2: Utilizare în pipeline

```bash
# Câte procese rulează?
ps aux | wc -l

# Câți useri unici?
cut -d':' -f1 /etc/passwd | sort -u | wc -l

# Câte fișiere .txt?
ls *.txt 2>/dev/null | wc -l
```

---

## 3.8 head și tail

🎯 SUBGOAL 3.8.1: Extrage primele/ultimele linii

```bash
# Primele 10 linii (implicit)
head fisier.txt

# Primele N linii
head -n 5 fisier.txt
head -5 fisier.txt  # shortcut

# Ultimele 10 linii (implicit)
tail fisier.txt

# Ultimele N linii
tail -n 5 fisier.txt
tail -5 fisier.txt
```

🎯 SUBGOAL 3.8.2: Monitorizare în timp real

```bash
# Urmărește fișierul în timp real (-f = follow)
tail -f /var/log/syslog

# Urmărește cu număr de linii inițiale
tail -f -n 50 /var/log/syslog

# Oprire: Ctrl+C
```

Combinații utile:
```bash
# Liniile 5-10 (sari primele 4, ia următoarele 6)
head -10 fisier.txt | tail -6

# Alternativ: toate MINUS primele 4
tail -n +5 fisier.txt | head -6
```

---

## 3.9 tee - Duplicare Stream

🎯 SUBGOAL 3.9.1: Salvează și afișează simultan

`tee` scrie în fișier ȘI trimite mai departe pe stdout:

```
            ┌──────────┐
            │ fișier   │
     ┌──────┤   tee    ├──────┐
input│      └──────────┘      │output
─────┴────────────────────────┴─────→
```

```bash
# Salvează output-ul și afișează-l
ls -la | tee listing.txt

# Salvează și procesează mai departe
ps aux | tee procese.txt | grep root

# Adaugă în loc de suprascriere
df -h | tee -a disk_log.txt
```

🎯 SUBGOAL 3.9.2: Debug pipeline-uri

```bash
# Verifică ce produce fiecare pas
cat data.txt | tee step1.txt | sort | tee step2.txt | uniq -c

# Acum poți verifica step1.txt și step2.txt pentru debugging
```

---

## 3.10 Pipeline-uri Complexe

🎯 SUBGOAL 3.10.1: Construiește incremental

Metodologie: Adaugă câte o comandă și verifică output-ul!

```bash
# Obiectiv: Top 5 IP-uri din access.log

# Pas 1: afișează fișierul
cat access.log

# Pas 2: extrage IP-ul (primul câmp)
cat access.log | awk '{print $1}'

# Pas 3: sortează
cat access.log | awk '{print $1}' | sort

# Pas 4: numără duplicatele
cat access.log | awk '{print $1}' | sort | uniq -c

# Pas 5: sortează numeric descrescător
cat access.log | awk '{print $1}' | sort | uniq -c | sort -rn

# Pas 6: ia primele 5
cat access.log | awk '{print $1}' | sort | uniq -c | sort -rn | head -5
```

🎯 SUBGOAL 3.10.2: Pattern-uri comune

Frecvență cuvinte:
```bash
tr -s ' ' '\n' < text.txt | sort | uniq -c | sort -rn | head -20
```

Extensii unice de fișiere:
```bash
find . -type f | sed 's/.*\.//' | sort | uniq -c | sort -rn
```

Procese per user:
```bash
ps aux | awk '{print $1}' | sort | uniq -c | sort -rn
```

---

# MODULUL 4: BUCLE

## 4.1 Bucla for - Listă

🎯 SUBGOAL 4.1.1: Iterează peste listă explicită

```bash
# Sintaxa de bază
for variabila in element1 element2 element3; do
    # comenzi
done

# Exemplu simplu
for culoare in rosu verde albastru; do
    echo "Culoarea: $culoare"
done
```

🎯 SUBGOAL 4.1.2: Folosește brace expansion

```bash
# Interval numeric
for i in {1..5}; do
    echo "Numărul: $i"
done
# 1 2 3 4 5

# Cu pas
for i in {0..10..2}; do
    echo $i
done
# 0 2 4 6 8 10

# Litere
for letter in {a..e}; do
    echo $letter
done
```

⚠️ Capcană: Brace expansion NU funcționează cu variabile!
```bash
N=5
for i in {1..$N}; do echo $i; done
# Output: {1..5} ← GREȘIT!

# Soluții:
for i in $(seq 1 $N); do echo $i; done
for ((i=1; i<=N; i++)); do echo $i; done
```

🎯 SUBGOAL 4.1.3: Iterează peste fișiere (globbing)

```bash
# Toate fișierele .txt
for file in *.txt; do
    echo "Procesez: $file"
    wc -l "$file"
done

# Capcană: folosește ghilimele pentru "$file" (fișiere cu spații)!

# Cu verificare că există fișiere
shopt -s nullglob  # pattern fără match → lista goală
for file in *.pdf; do
    echo "$file"
done
```

---

## 4.2 Bucla for - Stil C

🎯 SUBGOAL 4.2.1: Sintaxa C-style

```bash
# Sintaxa:
for ((inițializare; condiție; increment)); do
    # comenzi
done

# Exemplu clasic
for ((i=1; i<=5; i++)); do
    echo "i = $i"
done

# Countdown
for ((i=10; i>=0; i--)); do
    echo $i
    sleep 0.5
done
```

Puncte forte:
- Funcționează cu variabile
- Familiar pentru programatori C/Java
- Control precis asupra iterației

---

## 4.3 Bucla while

🎯 SUBGOAL 4.3.1: Iterează cât timp condiția e adevărată

```bash
# Sintaxa:
while [ condiție ]; do
    # comenzi
done

# Exemplu: numără până la 5
count=1
while [ $count -le 5 ]; do
    echo "Count: $count"
    ((count++))
done
```

🎯 SUBGOAL 4.3.2: Citește fișier linie cu linie

```bash
# Metoda CORECTĂ de citire fișier
while IFS= read -r line; do
    echo "Linia: $line"
done < fisier.txt

# IFS= : păstrează spațiile de la început/sfârșit
# -r : nu interpretează backslash-uri
```

⚠️ CAPCANA SUBSHELL - Problema #1 cu bucle!

```bash
# GREȘIT: variabila nu persistă
total=0
cat fisier.txt | while read line; do
    ((total++))
done
echo $total  # 0! (subshell)

# CORECT: redirecționare în loc de pipe
total=0
while read line; do
    ((total++))
done < fisier.txt
echo $total  # corect!

# SAU: process substitution
total=0
while read line; do
    ((total++))
done < <(cat fisier.txt)
echo $total  # corect!
```

---

## 4.4 Bucla until

🎯 SUBGOAL 4.4.1: Iterează până când condiția devine adevărată

```bash
# until = "cât timp NU e adevărat"
# Opus lui while

until [ condiție ]; do
    # comenzi (rulează cât timp condiția e FALSĂ)
done

# Exemplu: așteaptă până când fișierul apare
until [ -f /tmp/ready.txt ]; do
    echo "Aștept..."
    sleep 1
done
echo "Fișierul a apărut!"
```

Echivalență:
```bash
# Aceste două sunt echivalente:
until [ -f file ]; do ...; done
while [ ! -f file ]; do ...; done
```

---

## 4.5 break și continue

🎯 SUBGOAL 4.5.1: Controlează fluxul buclei

break - Ieși din buclă:
```bash
for i in {1..10}; do
    if [ $i -eq 5 ]; then
        echo "Opresc la $i"
        break
    fi
    echo $i
done
# Output: 1 2 3 4 Opresc la 5
```

continue - Sari la următoarea iterație:
```bash
for i in {1..5}; do
    if [ $i -eq 3 ]; then
        echo "Sar peste $i"
        continue
    fi
    echo "Procesez: $i"
done
# Output: Procesez: 1
# Procesez: 2
# Sar peste 3
# Procesez: 4
# Procesez: 5
```

🎯 SUBGOAL 4.5.2: break și continue cu N niveluri

```bash
# break N - ieși din N bucle
for i in {1..3}; do
    for j in {1..3}; do
        if [ $j -eq 2 ]; then
            break 2  # ieși din AMBELE bucle
        fi
        echo "$i-$j"
    done
done
# Output: 1-1

# continue N - sari în bucla de nivel N
```

---

## 4.6 Exemple Practice Integrate

🎯 SUBGOAL 4.6.1: Script de backup

```bash
#!/bin/bash
# backup_files.sh - Backup fișiere modificate azi

backup_dir="$HOME/backup_$(date +%Y%m%d)"
mkdir -p "$backup_dir"

count=0
for file in *.txt; do
    [ -f "$file" ] || continue  # skip dacă nu există
    
    if [ -n "$(find "$file" -mtime 0 2>/dev/null)" ]; then
        cp "$file" "$backup_dir/"
        echo "✓ Backup: $file"
        ((count++))
    fi
done

echo "---"
echo "Total fișiere salvate: $count"
```

🎯 SUBGOAL 4.6.2: Procesare batch cu validare

```bash
#!/bin/bash
# process_logs.sh - Analizează log-uri

for logfile in /var/log/*.log; do
    [ -r "$logfile" ] || {
        echo "⚠ Nu pot citi: $logfile"
        continue
    }
    
    errors=$(grep -c "ERROR" "$logfile" 2>/dev/null || echo 0)
    
    if [ "$errors" -gt 0 ]; then
        echo "$(basename "$logfile"): $errors erori"
    fi
done | sort -t':' -k2 -rn | head -10
```

🎯 SUBGOAL 4.6.3: Menu interactiv

```bash
#!/bin/bash
# menu.sh - Meniu simplu

while true; do
    echo ""
    echo "=== MENIU ==="
    echo "1) Afișează data"
    echo "2) Listează fișiere"
    echo "3) Spațiu disk"
    echo "4) Ieșire"
    echo ""
    read -p "Alege opțiunea: " choice
    
    case $choice in
        1) date ;;
        2) ls -la ;;
        3) df -h ;;
        4) echo "La revedere!"; break ;;
        *) echo "Opțiune invalidă!" ;;
    esac
done
```

---

# REZUMAT ȘI CHEAT SHEET

## Operatori de Control

```
cmd1 ; cmd2      Execută ambele, ignoră rezultatul
cmd1 && cmd2     cmd2 doar dacă cmd1 REUȘEȘTE
cmd1 || cmd2     cmd2 doar dacă cmd1 EȘUEAZĂ
cmd &            Rulează în background
cmd1 | cmd2      Pipe: stdout(cmd1) → stdin(cmd2)
{ cmd1; cmd2; }  Grupare în shell-ul curent
( cmd1; cmd2 )   Grupare în subshell
```

## Redirecționare

```
cmd > file       stdout → fișier (suprascrie)
cmd >> file      stdout → fișier (adaugă)
cmd 2> file      stderr → fișier
cmd &> file      stdout+stderr → fișier
cmd < file       citește input din fișier
cmd << EOF       here document
cmd <<< "str"    here string
```

## Filtre

```
sort [-nrk]      sortează linii
uniq [-cd]       elimină duplicate CONSECUTIVE (needs sort!)
cut -d: -f1,3    extrage câmpuri
paste f1 f2      combină fișiere pe coloane
tr 'ab' 'AB'     transformă caractere
wc [-lwc]        numără linii/cuvinte/caractere
head -n N        primele N linii
tail -n N        ultimele N linii
tail -f          urmărește fișierul live
tee file         scrie în fișier ȘI trimite mai departe
```

## Bucle

```bash
# for lista
for x in a b c; do echo $x; done

# for brace
for i in {1..10}; do echo $i; done

# for C-style
for ((i=0; i<10; i++)); do echo $i; done

# while
while [ cond ]; do ...; done

# until
until [ cond ]; do ...; done

# citire fișier
while IFS= read -r line; do ...; done < file
```

---

# LEGĂTURI CU ALTE CONCEPTE

## Recapitulare SEM01-02

Acest seminar construiește pe:
- Navigare: `cd`, `ls`, `pwd` - acum le combinăm cu operatori
- Variabile: `$VAR`, `$?` - acum le folosim în bucle și condiții
- Globbing: `*.txt` - acum îl folosim în bucle for
- Citește mesajele de eroare cu atenție — conțin indicii valoroase

## Preview SEM05-06

În seminarele următoare vom vedea în detaliu:

Concret: Expresii regulate (regex): pattern matching avansat cu `grep`, `sed`, `awk`. Procesare text avansată: `awk` pentru modificări complexe. Și Scripting avansat: funcții, arrays, debugging.


---

*Material Principal generat pentru ASE București - CSIE*  
*Seminar 3-4: Operatori, Redirecționare, Filtre, Bucle*
