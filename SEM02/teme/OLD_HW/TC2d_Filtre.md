# TC2d - Filtre în Linux

> **Sisteme de Operare** | ASE București - CSIE  
> Material de laborator - Seminar 2

---

## Obiective

> **Tip din practică**: `sort | uniq -c | sort -rn` e combo-ul meu favorit pentru analiză rapidă. Îl folosesc aproape zilnic pentru a vedea ce se întâmplă în log-uri. Memorează-l!

La finalul acestui laborator, studentul va fi capabil să:
- Folosească comenzile de filtrare pentru procesarea textului
- Combine filtre în pipeline-uri eficiente
- Proceseze și transforme date din fișiere

---

## 1. Ce sunt Filtrele?

**Filtrele** sunt comenzi care:
1. Citesc date de la **stdin** (sau din fișiere)
2. **Procesează** datele
3. Scriu rezultatul la **stdout**

```
stdin → [FILTRU] → stdout
```

Acest design permite înlănțuirea în **pipeline-uri**:

```bash
cat date.txt | filtru1 | filtru2 | filtru3 > rezultat.txt
```

---

## 2. sort - Sortare

Sortează liniile alfabetic sau numeric.

```bash
# Sortare alfabetică (implicit)
sort fisier.txt

# Sortare numerică
sort -n numere.txt

# Sortare descrescătoare
sort -r fisier.txt
sort -rn numere.txt            # numeric descrescător

# Sortare după coloană
sort -k2 fisier.txt            # după coloana 2
sort -k2,2 fisier.txt          # doar coloana 2
sort -t',' -k3 -n data.csv     # CSV, coloana 3, numeric

# Alte opțiuni utile
sort -u fisier.txt             # elimină duplicatele (unique)
sort -f fisier.txt             # ignore case
sort -h sizes.txt              # human-readable (1K, 2M, 3G)

# Exemple practice
ls -l | sort -k5 -n            # sortează după dimensiune
du -h * | sort -h              # sortează dimensiuni human
```

---

## 3. uniq - Linii Unice

Elimină sau raportează liniile **consecutive** duplicate.

> ⚠️ Important: Funcționează doar pe linii consecutive! de regulă se folosește după `sort`.

```bash
# Elimină duplicatele consecutive
uniq fisier.txt
sort fisier.txt | uniq         # elimină TOATE duplicatele

# Numără aparițiile
sort fisier.txt | uniq -c      # prefixează cu numărul de apariții

# Afișează doar duplicatele
sort fisier.txt | uniq -d      # doar liniile care se repetă

# Afișează doar liniile unice
sort fisier.txt | uniq -u      # doar liniile care apar o dată

# Ignoră case
sort -f fisier.txt | uniq -i

# Exemple practice
# Top 10 cele mai frecvente linii
sort access.log | uniq -c | sort -rn | head -10
```

---

## 4. cut - Extragere Coloane

Extrage secțiuni din fiecare linie.

```bash
# După delimitator (-d) și câmp (-f)
cut -d':' -f1 /etc/passwd              # primul câmp
cut -d':' -f1,3 /etc/passwd            # câmpurile 1 și 3
cut -d':' -f1-3 /etc/passwd            # câmpurile 1 până la 3
cut -d',' -f2 data.csv                 # coloana 2 din CSV

# După poziție caracter (-c)
cut -c1-10 fisier.txt                  # caracterele 1-10
cut -c5- fisier.txt                    # de la caracterul 5 până la final
cut -c-5 fisier.txt                    # primele 5 caractere

# După bytes (-b)
cut -b1-10 fisier.txt

# Exemple practice
# Extrage username-uri
cut -d':' -f1 /etc/passwd

# Prima coloană din output ps
ps aux | cut -c1-10
```

---

## 5. paste - Îmbinare Coloane

Îmbină liniile din mai multe fișiere, coloană cu coloană.

```bash
# Îmbinare implicită (tab)
paste fisier1.txt fisier2.txt

# Delimitator custom
paste -d',' fisier1.txt fisier2.txt
paste -d':' file1 file2 file3

# Serializare (toate pe o linie)
paste -s fisier.txt
paste -sd',' fisier.txt            # cu virgulă

# Exemple practice
# Creează CSV din două fișiere
paste -d',' names.txt ages.txt > people.csv
```

---

## 6. tr - Translate/Delete

Translatează sau șterge caractere.

```bash
# Înlocuire caractere
tr 'a-z' 'A-Z' < fisier.txt        # lowercase → uppercase
tr 'A-Z' 'a-z' < fisier.txt        # uppercase → lowercase
tr ':' ',' < fisier.txt            # înlocuiește : cu ,
echo "hello" | tr 'aeiou' '12345'  # h1ll4

# Ștergere caractere (-d)
tr -d '0-9' < fisier.txt           # șterge toate cifrele
tr -d '\n' < fisier.txt            # șterge newlines
tr -d '[:space:]' < fisier.txt     # șterge toate spațiile

# Comprimare caractere repetate (-s)
tr -s ' ' < fisier.txt             # spații multiple → unul singur
tr -s '\n' < fisier.txt            # linii goale multiple → una

# Complement (-c)
tr -cd '0-9\n' < fisier.txt        # păstrează DOAR cifre și newline
tr -cd '[:print:]' < fisier.txt    # păstrează doar printabile

# Clase de caractere
# [:alnum:] [:alpha:] [:digit:] [:lower:] [:upper:]
# [:space:] [:punct:] [:print:] [:cntrl:]

# Exemple practice
echo "Hello World" | tr 'A-Z' 'a-z'
cat messy.txt | tr -s ' \t' ' '    # normalizează whitespace
```

---

## 7. wc - Word Count

Numără linii, cuvinte, bytes.

```bash
# Toate statisticile
wc fisier.txt                      # linii cuvinte bytes nume

# Opțiuni specifice
wc -l fisier.txt                   # doar linii
wc -w fisier.txt                   # doar cuvinte
wc -c fisier.txt                   # doar bytes
wc -m fisier.txt                   # doar caractere
wc -L fisier.txt                   # lungimea liniei celei mai lungi

# Multiple fișiere
wc -l *.txt                        # fiecare + total

# În pipeline
cat access.log | grep "404" | wc -l
ps aux | wc -l                     # număr procese
```

---

## 8. head și tail

### head - Începutul fișierului

```bash
head fisier.txt                    # primele 10 linii
head -n 5 fisier.txt               # primele 5 linii
head -n -5 fisier.txt              # toate EXCEPTÂND ultimele 5
head -c 100 fisier.txt             # primii 100 bytes
```

### tail - Sfârșitul fișierului

```bash
tail fisier.txt                    # ultimele 10 linii
tail -n 20 fisier.txt              # ultimele 20 linii
tail -n +5 fisier.txt              # de la linia 5 până la final
tail -c 100 fisier.txt             # ultimii 100 bytes

# Monitorizare în timp real
tail -f log.txt                    # follow - așteaptă linii noi
tail -F log.txt                    # follow + retry la rotire
```

### Combinații

```bash
# Liniile 15-20
head -n 20 fisier.txt | tail -n 6

# Linia 10
sed -n '10p' fisier.txt
head -n 10 fisier.txt | tail -n 1
```

---

## 9. tee - Duplicare Stream

Scrie la stdout ȘI în fișier(e) simultan.

```bash
# Salvează output și afișează
ls -la | tee lista.txt

# Append în loc de overwrite
ls -la | tee -a lista.txt

# Multiple fișiere
comanda | tee file1.txt file2.txt

# În mijlocul pipeline-ului
cat data.txt | sort | tee sorted.txt | uniq -c > counts.txt

# Debugging pipeline
cat data | filtru1 | tee step1.txt | filtru2 | tee step2.txt > final.txt
```

---

## 10. nl - Numerotare Linii

```bash
# Numerotare de bază
nl fisier.txt

# Format număr
nl -n ln fisier.txt               # aliniat stânga
nl -n rn fisier.txt               # aliniat dreapta
nl -n rz fisier.txt               # cu zerouri leading

# Lățime câmp număr
nl -w 3 fisier.txt                # 3 caractere pentru număr

# Ce linii să numeroteze
nl -b a fisier.txt                # toate liniile
nl -b t fisier.txt                # doar non-empty (implicit)
```

---

## 11. Exerciții Practice

### Exercițiul 1: Sortare și Unicitate

```bash
# Creează fișier de test
cat > colors.txt << 'EOF'
roșu
verde
albastru
roșu
galben
verde
roșu
EOF

# Sortează și elimină duplicatele
sort colors.txt | uniq

# Numără aparițiile
sort colors.txt | uniq -c | sort -rn
```

### Exercițiul 2: Procesare CSV

```bash
# Creează CSV de test
cat > studenti.csv << 'EOF'
nume,varsta,nota
Ana,21,9
Ion,22,7
Maria,20,10
Andrei,21,8
EOF

# Extrage numele (coloana 1)
cut -d',' -f1 studenti.csv | tail -n +2

# Sortează după notă
tail -n +2 studenti.csv | sort -t',' -k3 -rn

# Media vârstelor... (mai complex, cu awk)
```

### Exercițiul 3: Pipeline Complet

```bash
# Analiză log: top 10 IP-uri
cat access.log | cut -d' ' -f1 | sort | uniq -c | sort -rn | head -10

# Procesare /etc/passwd
cut -d':' -f1,3 /etc/passwd | sort -t':' -k2 -n | tail -10
```

### Exercițiul 4: modificare Text

```bash
# Normalizare whitespace
echo "text   cu   spatii    multiple" | tr -s ' '

# Lowercase tot
cat mixed_case.txt | tr 'A-Z' 'a-z'

# Șterge caractere non-alfanumerice
echo "Text123!@#Special" | tr -cd '[:alnum:]\n'
```

---

## 12. Întrebări de Verificare

1. **De ce trebuie să folosim `sort` înainte de `uniq`?**
   > `uniq` elimină doar duplicatele **consecutive**. `sort` grupează liniile identice.

2. **Cum extragi coloana 3 dintr-un fișier CSV?**
   > `cut -d',' -f3 fisier.csv`

3. **Cum transformi toate literele în majuscule?**
   > `tr 'a-z' 'A-Z' < fisier.txt`

4. **Ce face `tail -f`?**
   > Monitorizează fișierul în timp real, afișând liniile noi pe măsură ce apar.

5. **Cum numeri doar liniile non-goale?**
   > `nl -b t fisier.txt` (comportament implicit).

---

## Cheat Sheet

```bash
# SORTARE
sort file               # alfabetic
sort -n file            # numeric
sort -r file            # descrescător
sort -k2 file           # după coloana 2
sort -t',' -k3 file     # delimitator virgulă

# UNICITATE
sort | uniq             # elimină duplicate
sort | uniq -c          # numără apariții
sort | uniq -d          # doar duplicate

# EXTRAGERE
cut -d':' -f1 file      # câmpul 1, delimitator :
cut -c1-10 file         # caracterele 1-10

# ÎMBINARE
paste file1 file2       # coloane
paste -d',' f1 f2       # cu delimitator

# modificare
tr 'a-z' 'A-Z'          # lowercase → uppercase
tr -d '0-9'             # șterge cifre
tr -s ' '               # comprimă spații

# NUMĂRARE
wc -l file              # linii
wc -w file              # cuvinte
wc -c file              # bytes

# HEAD/TAIL
head -n N file          # primele N
tail -n N file          # ultimele N
tail -f file            # monitorizare

# DIVERSE
tee file                # duplică stream
nl file                 # numerotare linii
```

---

*Material adaptat pentru cursul de Sisteme de Operare | ASE București - CSIE*
