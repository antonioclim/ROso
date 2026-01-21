# Parsons Problems - Seminarul 1-2
## Sisteme de Operare | Shell Basics & Configuration

Total probleme: 12  
Timp mediu per problemă: 3-5 minute  
Format: Reordonare linii de cod + identificare distractori

---

## CE SUNT PARSONS PROBLEMS?

Parsons Problems sunt exerciții în care studenții aranjează linii de cod amestecate în ordinea corectă. Ce câștigi:
- Focus pe logică și structură, nu pe sintaxă
- Sarcină cognitivă mai mică decât scrierea de la zero
- Excelente pentru **consolidare** și **warmup**

---

## PROBLEMĂ 1: Navigare Simplă

Obiectiv: Navighează în home și afișează calea

Nivel: Începător | Timp: 2 min

```
═══════════════════════════════════════════════════════════════
LINII AMESTECATE (4 linii + 1 distractor):

   pwd
   echo "Suntem în home"
   ls -la
   cd ~
   cd /                 ← DISTRACTOR
═══════════════════════════════════════════════════════════════
```

<details>
<summary>🔑 SOLUȚIE</summary>

```bash
cd ~
pwd
echo "Suntem în home"
ls -la
```

Explicație distractorului: `cd /` te duce în rădăcină, nu în home.
</details>

---

## PROBLEMĂ 2: Creare Director și Fișier

Obiectiv: Creează director `proiect`, intră în el, creează `README.md`

Nivel: Începător | Timp: 2 min

```
═══════════════════════════════════════════════════════════════
LINII AMESTECATE (4 linii + 1 distractor):

   echo "# My Project" > README.md
   mkdir proiect
   cat README.md
   cd proiect
   touch mkdir proiect  ← DISTRACTOR
═══════════════════════════════════════════════════════════════
```

<details>
<summary>🔑 SOLUȚIE</summary>

```bash
mkdir proiect
cd proiect
echo "# My Project" > README.md
cat README.md
```

Explicație distractorului: `touch mkdir proiect` creează fișiere numite "mkdir" și "proiect", nu un director!
</details>

---

## PROBLEMĂ 3: Copiere cu Backup

Obiectiv: Copiază `config.txt` în `config.txt.backup`, apoi modifică originalul

Nivel: Începător | Timp: 3 min

```
═══════════════════════════════════════════════════════════════
LINII AMESTECATE (5 linii + 1 distractor):

   cat config.txt
   cp config.txt config.txt.backup
   echo "new line" >> config.txt
   touch config.txt
   echo "original content" > config.txt
   mv config.txt config.txt.backup  ← DISTRACTOR
═══════════════════════════════════════════════════════════════
```

<details>
<summary>🔑 SOLUȚIE</summary>

```bash
touch config.txt
echo "original content" > config.txt
cp config.txt config.txt.backup
echo "new line" >> config.txt
cat config.txt
```

Explicație distractorului: `mv` mută (redenumește), nu copiază - ai pierde originalul!
</details>

---

## PROBLEMĂ 4: Structură de Proiect

Obiectiv: Creează structura: `app/src/`, `app/tests/`, `app/docs/`

Nivel: Intermediar | Timp: 3 min

```
═══════════════════════════════════════════════════════════════
LINII AMESTECATE (3 linii + 2 distractori):

   mkdir -p app/{src,tests,docs}
   tree app
   cd app
   mkdir app && mkdir src tests docs    ← DISTRACTOR 1
   mkdir app/src app/tests app/docs     ← ALTERNATIVĂ VALIDĂ
═══════════════════════════════════════════════════════════════
```

<details>
<summary>🔑 SOLUȚIE</summary>

```bash
mkdir -p app/{src,tests,docs}
tree app
```

SAU varianta mai lungă dar corectă:
```bash
mkdir -p app/src app/tests app/docs
tree app
```

Explicație DISTRACTOR 1: Creează `app` dar apoi `src`, `tests`, `docs` în directorul curent, NU în `app`!
</details>

---

## PROBLEMĂ 5: Variabilă și Echo

Obiectiv: Setează variabilă `SALUT`, afișeaz-o cu text înconjurător

Nivel: Intermediar | Timp: 3 min

```
═══════════════════════════════════════════════════════════════
LINII AMESTECATE (3 linii + 2 distractori):

   SALUT="Bună ziua"
   echo "Mesajul este: $SALUT"
   echo $SALUT
   SALUT = "Bună ziua"        ← DISTRACTOR 1 (spații!)
   echo 'Mesajul este: $SALUT' ← DISTRACTOR 2 (single quotes!)
═══════════════════════════════════════════════════════════════
```

<details>
<summary>🔑 SOLUȚIE</summary>

```bash
SALUT="Bună ziua"
echo $SALUT
echo "Mesajul este: $SALUT"
```

Explicație distractori:
- DISTRACTOR 1: Spațiile în jurul `=` cauzează eroare!
- DISTRACTOR 2: Single quotes nu expandează `$SALUT`
</details>

---

## PROBLEMĂ 6: Export pentru Subshell

Obiectiv: Creează o variabilă vizibilă într-un subshell

Nivel: Intermediar | Timp: 4 min

```
═══════════════════════════════════════════════════════════════
LINII AMESTECATE (4 linii + 1 distractor):

   export PROIECT="SO_Lab"
   bash -c 'echo "Proiect: $PROIECT"'
   echo "În shell curent: $PROIECT"
   PROIECT="SO_Lab"
   $PROIECT="SO_Lab"            ← DISTRACTOR
═══════════════════════════════════════════════════════════════
```

<details>
<summary>🔑 SOLUȚIE</summary>

```bash
PROIECT="SO_Lab"
export PROIECT
echo "În shell curent: $PROIECT"
bash -c 'echo "Proiect: $PROIECT"'
```

SAU forma compactă:
```bash
export PROIECT="SO_Lab"
echo "În shell curent: $PROIECT"
bash -c 'echo "Proiect: $PROIECT"'
```

Explicație distractor: `$PROIECT="SO_Lab"` încearcă să execute valoarea lui $PROIECT ca comandă!
</details>

---

## PROBLEMĂ 7: Adăugare la .bashrc

Obiectiv: Adaugă un alias și aplică modificările

Nivel: Intermediar | Timp: 4 min

```
═══════════════════════════════════════════════════════════════
LINII AMESTECATE (4 linii + 1 distractor):

   source ~/.bashrc
   alias ll='ls -la'
   echo "alias ll='ls -la'" >> ~/.bashrc
   ll
   cat "alias ll='ls -la'" >> ~/.bashrc  ← DISTRACTOR
═══════════════════════════════════════════════════════════════
```

<details>
<summary>🔑 SOLUȚIE</summary>

```bash
echo "alias ll='ls -la'" >> ~/.bashrc
source ~/.bashrc
ll
```

Observație: `alias ll='ls -la'` singur creează alias-ul temporar, nu persistent.

Explicație distractor: `cat "text"` încearcă să citească un fișier numit "alias...", nu scrie text!
</details>

---

## PROBLEMĂ 8: Găsire și Ștergere Fișiere .tmp

Obiectiv: Găsește toate fișierele .tmp și șterge-le

Nivel: Avansat | Timp: 5 min

```
═══════════════════════════════════════════════════════════════
LINII AMESTECATE (3 linii + 2 distractori):

   find . -name "*.tmp" -type f
   find . -name "*.tmp" -delete
   echo "Fișiere .tmp șterse"
   rm *.tmp                    ← DISTRACTOR 1 (nu e recursiv!)
   find . -name "*.tmp" | rm   ← DISTRACTOR 2 (sintaxă greșită!)
═══════════════════════════════════════════════════════════════
```

<details>
<summary>🔑 SOLUȚIE</summary>

```bash
find . -name "*.tmp" -type f
find . -name "*.tmp" -delete
echo "Fișiere .tmp șterse"
```

Explicații distractori:
- DISTRACTOR 1: `rm *.tmp` șterge doar din directorul curent, nu recursiv
- DISTRACTOR 2: `rm` nu citește de la stdin așa - ar trebui `xargs rm` sau `-exec rm`
</details>

---

## PROBLEMĂ 9: Verificare Exit Code

Obiectiv: Execută comandă și verifică dacă a reușit

Nivel: Intermediar | Timp: 4 min

```
═══════════════════════════════════════════════════════════════
LINII AMESTECATE (5 linii + 1 distractor):

   mkdir test_dir
   if [ $? -eq 0 ]; then
       echo "Director creat cu succes"
   fi
   rmdir test_dir
   if [ $? -eq 1 ]; then     ← DISTRACTOR (logica inversată!)
═══════════════════════════════════════════════════════════════
```

<details>
<summary>🔑 SOLUȚIE</summary>

```bash
mkdir test_dir
if [ $? -eq 0 ]; then
    echo "Director creat cu succes"
fi
rmdir test_dir
```

Explicație distractor: `$? -eq 0` înseamnă succes, nu `$? -eq 1`!
</details>

---

## PROBLEMĂ 10: Globbing Complex

Obiectiv: Listează doar fișierele .txt și .md din directorul curent

Nivel: Intermediar | Timp: 3 min

```
═══════════════════════════════════════════════════════════════
LINII AMESTECATE (2 linii corecte + 2 alternative + 1 distractor):

   ls *.txt *.md
   ls *.{txt,md}
   ls -la | grep -E "\.(txt|md)$"  ← ALTERNATIVĂ VALIDĂ
   echo "Fișiere text și markdown:"
   ls *.[txt,md]               ← DISTRACTOR (sintaxă greșită!)
═══════════════════════════════════════════════════════════════
```

<details>
<summary>🔑 SOLUȚIE</summary>

```bash
echo "Fișiere text și markdown:"
ls *.txt *.md
```

SAU:
```bash
echo "Fișiere text și markdown:"
ls *.{txt,md}
```

Explicație distractor: `[txt,md]` e un character class, ar potrivi un singur caracter din setul t,x,m,d,virgulă - nu extensii!
</details>

---

## PROBLEMĂ 11: Creare Script Simplu

Obiectiv: Creează un script care afișează data și user-ul

Nivel: Avansat | Timp: 5 min

```
═══════════════════════════════════════════════════════════════
LINII AMESTECATE (6 linii + 1 distractor):

   #!/bin/bash
   echo "Data: $(date)"
   echo "User: $USER"
   chmod +x info.sh
   ./info.sh
   cat > info.sh << 'EOF'
   EOF
   #/bin/bash             ← DISTRACTOR (lipsește !)
═══════════════════════════════════════════════════════════════
```

<details>
<summary>🔑 SOLUȚIE</summary>

```bash
cat > info.sh << 'EOF'
#!/bin/bash
echo "Data: $(date)"
echo "User: $USER"
EOF
chmod +x info.sh
./info.sh
```

Explicație distractor: `#/bin/bash` lipsește `!` - nu va fi recunoscut ca shebang!
</details>

---

## PROBLEMĂ 12: Prompt Personalizat

Obiectiv: Setează un prompt colorat cu user și director

Nivel: Avansat | Timp: 5 min

```
═══════════════════════════════════════════════════════════════
LINII AMESTECATE (4 linii + 1 distractor):

   # Verde pentru user, albastru pentru director
   PS1='\[\033[32m\]\u\[\033[0m\]:\[\033[34m\]\w\[\033[0m\]\$ '
   export PS1
   echo "Prompt nou activat"
   PS1='\[033[32m]\u\[033[0m]:\[034m]\w\[033[0m]\$ '  ← DISTRACTOR
═══════════════════════════════════════════════════════════════
```

<details>
<summary>🔑 SOLUȚIE</summary>

```bash
# Verde pentru user, albastru pentru director
PS1='\[\033[32m\]\u\[\033[0m\]:\[\033[34m\]\w\[\033[0m\]\$ '
export PS1
echo "Prompt nou activat"
```

Explicație distractor: Lipsesc backslash-urile din secvențele escape - prompt-ul va fi corupt!
</details>

---

## GHID DE UTILIZARE

### Când să folosești fiecare problemă:

| Problemă | Moment potrivit | Concepte testate |
|----------|-----------------|------------------|
| P1-P2 | Warmup început | Navigare de bază |
| P3-P4 | După cp/mkdir | Copiere, structuri |
| P5-P6 | După variabile | Asignare, export |
| P7 | După .bashrc | Configurare persistentă |
| P8 | După find | Căutare avansată |
| P9 | După $? | Control flow |
| P10 | După globbing | Wildcards |
| P11-P12 | Spre final | Integrare cunoștințe |

### Format de lucru:
- Individual: 3-5 minute per problemă
- Perechi: Discută înainte de a valida
- Clasă: Un student la tablă, ceilalți ghidează

---

## TEMPLATE PENTRU PROBLEME NOI

```markdown
## PROBLEMĂ X: [TITLU]

Obiectiv: [Ce trebuie să facă codul final]

Nivel: [Începător/Intermediar/Avansat] | Timp: X min

═══════════════════════════════════════════════════════════════
LINII AMESTECATE (N linii + M distractori):

   [linia 1]
   [linia 2]
   [distractor cu explicație]    ← DISTRACTOR
═══════════════════════════════════════════════════════════════

<details>
<summary>🔑 SOLUȚIE</summary>

[cod corect]

Explicație distractor: [de ce e greșit]
</details>
```

---

*Parsons Problems | SO Seminarul 1-2 | ASE-CSIE*
