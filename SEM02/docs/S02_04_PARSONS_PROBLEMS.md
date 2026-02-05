# Parsons Problems - Seminarul 3-4
## Sisteme de Operare | Operatori, Redirecționare, Filtre, Bucle

Total probleme: 17 (12 standard + 5 specifice Bash)  
Timp per problemă: 3-5 minute  
Format: Individual sau perechi

---

## CE SUNT PARSONS PROBLEMS?

Parsons Problems sunt exerciții în care primești linii de cod amestecate și trebuie să le aranjezi în ordinea corectă pentru a obține un program funcțional.

### Ce câștigi Cognitive

1. Reduce încărcătura cognitivă - nu trebuie să scrii codul de la zero
2. Focalizează pe structură - înțelegi logica programului
3. Evită blocajul sintactic - elementele sunt deja corecte
4. Identifică distractorii - învață să recunoști codul greșit

### Cum să abordezi un Parsons Problem

```
1. CITEȘTE obiectivul - ce trebuie să facă codul?
2. IDENTIFICĂ elementele cheie - ce recunoști?
3. GĂSEȘTE începutul - ce trebuie să fie prima linie?
4. CONSTRUIEȘTE secvențial - pas cu pas
5. VERIFICĂ distractorii - ce linie e în plus sau greșită?
6. TESTEAZĂ mental - parcurge execuția
```

---

## PROBLEME OPERATORI DE CONTROL

### PP-01: Backup Condiționat
Nivel: ⭐ Ușor | Timp: 3 min | Mod: Individual

```
╔══════════════════════════════════════════════════════════════════════╗
║  🎯 OBIECTIV: Creează backup DOAR dacă fișierul sursă există         ║
║                                                                      ║
║  COMPORTAMENT AȘTEPTAT:                                              ║
║  - Dacă data.txt există → copiază în backup/ și afișează "Succes"   ║
║  - Dacă data.txt NU există → afișează "Fișier inexistent"           ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  LINII AMESTECATE (una e DISTRACTOR):                               ║
║  ────────────────────────────────────────────────────────────────   ║
║     && cp data.txt backup/                                          ║
║     && echo "Backup creat cu succes"                                ║
║     || echo "Fișier inexistent"                                     ║
║     [ -f data.txt ]                                                 ║
║     mkdir -p backup &&               ← DISTRACTOR                   ║
║  ────────────────────────────────────────────────────────────────   ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
```

✅ SOLUȚIA CORECTĂ:
```bash
[ -f data.txt ] && cp data.txt backup/ && echo "Backup creat cu succes" || echo "Fișier inexistent"
```

Explicație distractor: `mkdir -p backup &&` ar crea directorul, dar:
1. Nu verifică dacă fișierul sursă există mai întâi
2. Complicaă inutil problema (backup/ poate exista deja)
3. Ar schimba logica: mkdir reușește → continuă, dar ce dacă data.txt nu există?

---

### PP-02: Proces de Build
Nivel: ⭐⭐ Mediu | Timp: 4 min | Mod: Perechi

```
╔══════════════════════════════════════════════════════════════════════╗
║  🎯 OBIECTIV: Simulează un proces de build cu pași dependenți        ║
║                                                                      ║
║  COMPORTAMENT: Fiecare pas rulează DOAR dacă precedentul reușește   ║
║  Pașii: Compile → Test → Deploy → Notificare                         ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  LINII AMESTECATE (una e DISTRACTOR):                               ║
║  ────────────────────────────────────────────────────────────────   ║
║     && echo "3. Deploy în producție..."                             ║
║     && echo "4. ✓ Build complet!"                                   ║
║     echo "1. Compilare..."                                          ║
║     && echo "2. Rulare teste..."                                    ║
║     || echo "✗ Build eșuat!"                                        ║
║     ; echo "Procesul a fost inițiat"        ← DISTRACTOR            ║
║  ────────────────────────────────────────────────────────────────   ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
```

✅ SOLUȚIA CORECTĂ:
```bash
echo "1. Compilare..." && echo "2. Rulare teste..." && echo "3. Deploy în producție..." && echo "4. ✓ Build complet!" || echo "✗ Build eșuat!"
```

Explicație distractor: `; echo "Procesul a fost inițiat"` folosește `;` care execută indiferent de rezultat - nu face parte din lanțul de dependențe `&&`.

---

### PP-03: Job Management
Nivel: ⭐⭐ Mediu | Timp: 4 min | Mod: Individual

```
╔══════════════════════════════════════════════════════════════════════╗
║  🎯 OBIECTIV: Pornește 3 task-uri în background și așteaptă-le      ║
║                                                                      ║
║  COMPORTAMENT:                                                       ║
║  - Pornește 3 sleep-uri în paralel (background)                      ║
║  - Afișează "Aștept..." după ce toate au pornit                      ║
║  - Așteaptă terminarea tuturor                                       ║
║  - Afișează "Toate complete!"                                        ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  LINII AMESTECATE (una e DISTRACTOR):                               ║
║  ────────────────────────────────────────────────────────────────   ║
║     echo "Toate complete!"                                          ║
║     sleep 2 &                                                       ║
║     sleep 3 &                                                       ║
║     wait                                                            ║
║     echo "Aștept terminarea..."                                     ║
║     sleep 1 &                                                       ║
║     fg                                    ← DISTRACTOR              ║
║  ────────────────────────────────────────────────────────────────   ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
```

✅ SOLUȚIA CORECTĂ:
```bash
sleep 1 &
sleep 2 &
sleep 3 &
echo "Aștept terminarea..."
wait
echo "Toate complete!"
```

Explicație distractor: `fg` aduce UN job în foreground (blocant), dar noi vrem să așteptăm TOATE job-urile simultan cu `wait`.

---

## PROBLEME REDIRECȚIONARE

### PP-04: Separator Output
Nivel: ⭐⭐ Mediu | Timp: 4 min | Mod: Perechi

```
╔══════════════════════════════════════════════════════════════════════╗
║  🎯 OBIECTIV: Separă stdout și stderr în fișiere diferite           ║
║                                                                      ║
║  COMPORTAMENT:                                                       ║
║  - Rulează: ls /home /inexistent                                    ║
║  - stdout → success.log                                             ║
║  - stderr → errors.log                                              ║
║  - Afișează "Procesare completă" la final                           ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  LINII AMESTECATE (una e DISTRACTOR):                               ║
║  ────────────────────────────────────────────────────────────────   ║
║     2> errors.log                                                   ║
║     echo "Procesare completă"                                       ║
║     > success.log                                                   ║
║     ls /home /inexistent                                            ║
║     &> combined.log                      ← DISTRACTOR               ║
║  ────────────────────────────────────────────────────────────────   ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
```

✅ SOLUȚIA CORECTĂ:
```bash
ls /home /inexistent > success.log 2> errors.log
echo "Procesare completă"
```

Explicație distractor: `&> combined.log` trimite AMBELE (stdout și stderr) în același fișier, dar cerința era să le SEPARE.

---

### PP-05: Here Document Config
Nivel: ⭐⭐ Mediu | Timp: 5 min | Mod: Individual

```
╔══════════════════════════════════════════════════════════════════════╗
║  🎯 OBIECTIV: Generează un fișier de configurare cu here document   ║
║                                                                      ║
║  COMPORTAMENT:                                                       ║
║  - Creează config.ini cu valorile specificate                       ║
║  - Confirmă crearea                                                  ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  LINII AMESTECATE (una e DISTRACTOR):                               ║
║  ────────────────────────────────────────────────────────────────   ║
║     port=8080                                                       ║
║     CONFIG                                                          ║
║     [server]                                                        ║
║     cat > config.ini << CONFIG                                      ║
║     host=localhost                                                  ║
║     echo "Config creat: config.ini"                                 ║
║     cat > config.ini < template.txt       ← DISTRACTOR              ║
║  ────────────────────────────────────────────────────────────────   ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
```

✅ SOLUȚIA CORECTĂ:
```bash
cat > config.ini << CONFIG
[server]
host=localhost
port=8080
CONFIG
echo "Config creat: config.ini"
```

Explicație distractor: `cat > config.ini < template.txt` citește dintr-un fișier existent, nu creează conținut inline cu here document.

---

### PP-06: Combinare cu tee
Nivel: ⭐⭐⭐ Avansat | Timp: 5 min | Mod: Perechi

```
╔══════════════════════════════════════════════════════════════════════╗
║  🎯 OBIECTIV: Salvează și procesează simultan                        ║
║                                                                      ║
║  COMPORTAMENT:                                                       ║
║  - Listează procesele                                                ║
║  - Salvează lista completă în all_procs.txt                         ║
║  - Filtrează pentru "root" și numără                                ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  LINII AMESTECATE (una e DISTRACTOR):                               ║
║  ────────────────────────────────────────────────────────────────   ║
║     | wc -l                                                         ║
║     | grep root                                                     ║
║     ps aux                                                          ║
║     | tee all_procs.txt                                             ║
║     > all_procs.txt |                     ← DISTRACTOR              ║
║  ────────────────────────────────────────────────────────────────   ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
```

✅ SOLUȚIA CORECTĂ:
```bash
ps aux | tee all_procs.txt | grep root | wc -l
```

Explicație distractor: `> all_procs.txt |` e sintaxă invalidă - nu poți pune `|` după `>` (redirecționarea termină pipeline-ul acolo).

---

## PROBLEME FILTRE

### PP-07: Top Frecvențe
Nivel: ⭐⭐ Mediu | Timp: 4 min | Mod: Individual

```
╔══════════════════════════════════════════════════════════════════════╗
║  🎯 OBIECTIV: Găsește cele mai frecvente 5 cuvinte                   ║
║                                                                      ║
║  COMPORTAMENT:                                                       ║
║  - Citește text.txt                                                  ║
║  - Convertește în cuvinte (câte unul pe linie)                      ║
║  - Numără frecvența fiecărui cuvânt                                 ║
║  - Sortează descrescător după frecvență                             ║
║  - Afișează top 5                                                    ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  LINII AMESTECATE (una e DISTRACTOR):                               ║
║  ────────────────────────────────────────────────────────────────   ║
║     | sort -rn                                                      ║
║     | uniq -c                                                       ║
║     cat text.txt                                                    ║
║     | head -5                                                       ║
║     | tr ' ' '\n'                                                   ║
║     | sort                                                          ║
║     | uniq                               ← DISTRACTOR               ║
║  ────────────────────────────────────────────────────────────────   ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
```

✅ SOLUȚIA CORECTĂ:
```bash
cat text.txt | tr ' ' '\n' | sort | uniq -c | sort -rn | head -5
```

Explicație distractor: `| uniq` (fără `-c`) elimină duplicatele DAR nu le numără - pierdem informația de frecvență.

---

### PP-08: Analiză CSV
Nivel: ⭐⭐⭐ Avansat | Timp: 5 min | Mod: Perechi

```
╔══════════════════════════════════════════════════════════════════════╗
║  🎯 OBIECTIV: Extrage și procesează date dintr-un CSV               ║
║                                                                      ║
║  FIȘIER: studenti.csv (format: nume,grupa,nota)                     ║
║  CERINȚĂ: Afișează mediile grupelor, sortate descrescător           ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  LINII AMESTECATE (una e DISTRACTOR):                               ║
║  ────────────────────────────────────────────────────────────────   ║
║     | sort -t',' -k2 -rn                                            ║
║     | tail -n +2                                                    ║
║     cat studenti.csv                                                ║
║     | cut -d',' -f2                                                 ║
║     | uniq -c                                                       ║
║     | sort                                                          ║
║     | cut -d',' -f2,3                     ← DISTRACTOR              ║
║  ────────────────────────────────────────────────────────────────   ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
```

✅ SOLUȚIA CORECTĂ:
```bash
cat studenti.csv | tail -n +2 | cut -d',' -f2 | sort | uniq -c | sort -rn
```

Sau pentru medii reale (cu awk):
```bash
cat studenti.csv | tail -n +2 | awk -F',' '{sum[$2]+=$3; count[$2]++} END {for(g in sum) print g, sum[g]/count[g]}' | sort -k2 -rn
```

Explicație distractor: `cut -d',' -f2,3` extrage și grupa și nota, dar nu avem o metodă simplă de a calcula medii cu sort/uniq singure.

---

## PROBLEME BUCLE

### PP-09: Batch Rename
Nivel: ⭐⭐ Mediu | Timp: 4 min | Mod: Individual

```
╔══════════════════════════════════════════════════════════════════════╗
║  🎯 OBIECTIV: Redenumește fișiere .txt adăugând prefix "backup_"    ║
║                                                                      ║
║  COMPORTAMENT:                                                       ║
║  - Iterează prin toate fișierele .txt                               ║
║  - Redenumește fiecare cu prefix "backup_"                          ║
║  - Afișează ce s-a redenumit                                        ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  LINII AMESTECATE (una e DISTRACTOR):                               ║
║  ────────────────────────────────────────────────────────────────   ║
║     done                                                            ║
║     mv "$file" "backup_$file"                                       ║
║     for file in *.txt; do                                           ║
║     echo "Redenumit: $file → backup_$file"                          ║
║     for file in *.txt                     ← DISTRACTOR              ║
║  ────────────────────────────────────────────────────────────────   ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
```

✅ SOLUȚIA CORECTĂ:
```bash
for file in *.txt; do
    mv "$file" "backup_$file"
    echo "Redenumit: $file → backup_$file"
done
```

Explicație distractor: `for file in *.txt` fără `; do` la final e sintaxă incompletă.

---

### PP-10: Numărătoare Inversă
Nivel: ⭐⭐ Mediu | Timp: 4 min | Mod: Perechi

```
╔══════════════════════════════════════════════════════════════════════╗
║  🎯 OBIECTIV: Countdown de la N la 0, apoi afișează "START!"        ║
║                                                                      ║
║  COMPORTAMENT:                                                       ║
║  - Citește N de la utilizator                                        ║
║  - Numără descrescător de la N la 1                                 ║
║  - Pauză de 1 secundă între numere                                  ║
║  - La final afișează "START!"                                        ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  LINII AMESTECATE (două sunt DISTRACTORI):                          ║
║  ────────────────────────────────────────────────────────────────   ║
║     read -p "Introdu N: " N                                         ║
║     echo "START!"                                                   ║
║     done                                                            ║
║     sleep 1                                                         ║
║     for ((i=N; i>=1; i--)); do                                      ║
║     echo $i                                                         ║
║     for i in {N..1}; do                   ← DISTRACTOR              ║
║     for i in {$N..1}; do                  ← DISTRACTOR              ║
║  ────────────────────────────────────────────────────────────────   ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
```

✅ SOLUȚIA CORECTĂ:
```bash
read -p "Introdu N: " N
for ((i=N; i>=1; i--)); do
    echo $i
    sleep 1
done
echo "START!"
```

Explicație distractori:
- `for i in {N..1}; do` - N literal, nu variabila
- `for i in {$N..1}; do` - brace expansion NU funcționează cu variabile!

---

### PP-11: Citire Fișier cu Contor
Nivel: ⭐⭐⭐ Avansat | Timp: 5 min | Mod: Individual

```
╔══════════════════════════════════════════════════════════════════════╗
║  🎯 OBIECTIV: Numără liniile non-goale dintr-un fișier              ║
║                                                                      ║
║  COMPORTAMENT:                                                       ║
║  - Citește fișier linie cu linie                                    ║
║  - Sare peste liniile goale                                          ║
║  - Numără liniile cu conținut                                        ║
║  - Afișează totalul la final                                         ║
║                                                                      ║
║  ⚠️ Capcană: Variabila trebuie să persiste după buclă!              ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  LINII AMESTECATE (una e DISTRACTOR):                               ║
║  ────────────────────────────────────────────────────────────────   ║
║     done < fisier.txt                                               ║
║     [ -z "$line" ] && continue                                      ║
║     count=0                                                         ║
║     ((count++))                                                     ║
║     while IFS= read -r line; do                                     ║
║     echo "Total linii non-goale: $count"                            ║
║     cat fisier.txt | while read line; do  ← DISTRACTOR              ║
║  ────────────────────────────────────────────────────────────────   ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
```

✅ SOLUȚIA CORECTĂ:
```bash
count=0
while IFS= read -r line; do
    [ -z "$line" ] && continue
    ((count++))
done < fisier.txt
echo "Total linii non-goale: $count"
```

Explicație distractor: `cat fisier.txt | while read line; do` creează subshell - variabila `count` NU va persista după buclă!

---

### PP-12: Script Complet - System Monitor
Nivel: ⭐⭐⭐⭐ Expert | Timp: 7 min | Mod: Perechi

```
╔══════════════════════════════════════════════════════════════════════╗
║  🎯 OBIECTIV: Script de monitorizare cu buclă infinită              ║
║                                                                      ║
║  COMPORTAMENT:                                                       ║
║  - Rulează în buclă infinită                                        ║
║  - La fiecare iterație: curăță ecranul, afișează data, procese top 5║
║  - Pauză de 2 secunde între refresh                                  ║
║  - Poate fi oprit cu Ctrl+C (trap pentru cleanup)                   ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  LINII AMESTECATE (două sunt DISTRACTORI):                          ║
║  ────────────────────────────────────────────────────────────────   ║
║     echo "=== $(date) ==="                                          ║
║     while true; do                                                  ║
║     trap "echo 'Oprire monitor'; exit" INT                          ║
║     clear                                                           ║
║     ps aux --sort=-%mem | head -6                                   ║
║     done                                                            ║
║     sleep 2                                                         ║
║     for ((;;)); do                        ← DISTRACTOR (valid dar atipic) ║
║     exit 0                                ← DISTRACTOR              ║
║  ────────────────────────────────────────────────────────────────   ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
```

✅ SOLUȚIA CORECTĂ:
```bash
trap "echo 'Oprire monitor'; exit" INT
while true; do
    clear
    echo "=== $(date) ==="
    ps aux --sort=-%mem | head -6
    sleep 2
done
```

Explicație distractori:
- `for ((;;)); do` - sintaxa e validă (for infinit stil C), dar `while true` e mai clar și idiomtic în Bash
- `exit 0` - ar termina scriptul imediat, nu aparține în buclă

---


## PROBLEME SPECIFICE BASH (BONUS)

### PP-13: Capcana Atribuire Variabile
Nivel: ⭐⭐ Mediu | Timp: 4 min | Mod: Individual

```
╔══════════════════════════════════════════════════════════════════════╗
║  🎯 OBIECTIV: Atribuie valori variabilelor și afișează-le            ║
║                                                                      ║
║  COMPORTAMENT:                                                       ║
║  - Setează NAME la "Alice"                                          ║
║  - Setează AGE la 25                                                ║
║  - Afișează: "NAME are AGE ani"                                      ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  LINII AMESTECATE (două sunt DISTRACTORI):                          ║
║  ────────────────────────────────────────────────────────────────   ║
║     NAME="Alice"                                                    ║
║     AGE=25                                                          ║
║     echo "$NAME are $AGE ani"                                       ║
║     NAME = "Alice"                        ← DISTRACTOR (spații!)    ║
║     echo '$NAME are $AGE ani'             ← DISTRACTOR (ghilimele!) ║
║  ────────────────────────────────────────────────────────────────   ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
```

✅ SOLUȚIA CORECTĂ:
```bash
NAME="Alice"
AGE=25
echo "$NAME are $AGE ani"
```

Explicație distractori:
- `NAME = "Alice"` - spațiile în jurul `=` cauzează eroare de sintaxă
- `echo '$NAME are $AGE ani'` - ghilimelele simple NU expandează variabilele, afișează literal `$NAME`

---

### PP-14: Capcana Paranteze Test
Nivel: ⭐⭐⭐ Avansat | Timp: 5 min | Mod: Perechi

```
╔══════════════════════════════════════════════════════════════════════╗
║  🎯 OBIECTIV: Verifică dacă un număr e în interval [1-100]           ║
║                                                                      ║
║  COMPORTAMENT:                                                       ║
║  - Citește număr de la utilizator                                   ║
║  - Dacă e între 1 și 100 (inclusiv) → "Valid"                       ║
║  - Altfel → "În afara intervalului"                                 ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  LINII AMESTECATE (două sunt DISTRACTORI):                          ║
║  ────────────────────────────────────────────────────────────────   ║
║     read -p "Introdu număr: " num                                   ║
║     if [[ $num -ge 1 && $num -le 100 ]]; then                       ║
║         echo "Valid"                                                 ║
║     else                                                             ║
║         echo "În afara intervalului"                                ║
║     fi                                                               ║
║     if [ $num -ge 1 && $num -le 100 ]; then  ← DISTRACTOR           ║
║     if [[ $num >= 1 && $num <= 100]]; then   ← DISTRACTOR           ║
║  ────────────────────────────────────────────────────────────────   ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
```

✅ SOLUȚIA CORECTĂ:
```bash
read -p "Introdu număr: " num
if [[ $num -ge 1 && $num -le 100 ]]; then
    echo "Valid"
else
    echo "În afara intervalului"
fi
```

Explicație distractori:
- `[ $num -ge 1 && $num -le 100 ]` - `&&` în interiorul `[ ]` e eroare; folosește `-a` sau `[[ ]]`
- `[[ $num >= 1 && $num <= 100]]` - `>=` și `<=` sunt pentru stringuri, nu numere; lipsește spațiu înainte de `]]`

---

### PP-15: Capcana Substituție Comandă
Nivel: ⭐⭐⭐ Avansat | Timp: 5 min | Mod: Individual

```
╔══════════════════════════════════════════════════════════════════════╗
║  🎯 OBIECTIV: Stochează output-ul comenzii într-o variabilă         ║
║                                                                      ║
║  COMPORTAMENT:                                                       ║
║  - Obține data curentă în format YYYY-MM-DD                         ║
║  - Stochează în variabila TODAY                                     ║
║  - Creează numele fișierului backup: backup_YYYY-MM-DD.tar          ║
║  - Afișează numele fișierului                                        ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  LINII AMESTECATE (două sunt DISTRACTORI):                          ║
║  ────────────────────────────────────────────────────────────────   ║
║     TODAY=$(date +%Y-%m-%d)                                         ║
║     FILENAME="backup_${TODAY}.tar"                                  ║
║     echo "Fișier backup: $FILENAME"                                 ║
║     TODAY=`date +%Y-%m-%d`              ← DISTRACTOR (funcționează dar depreciat) ║
║     TODAY = $(date +%Y-%m-%d)           ← DISTRACTOR (spații!)      ║
║  ────────────────────────────────────────────────────────────────   ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
```

✅ SOLUȚIA CORECTĂ:
```bash
TODAY=$(date +%Y-%m-%d)
FILENAME="backup_${TODAY}.tar"
echo "Fișier backup: $FILENAME"
```

Explicație distractori:
- `` TODAY=`date +%Y-%m-%d` `` - backtick-urile funcționează dar sunt depreciate; `$()` e preferat (imbricabil, mai clar)
- `TODAY = $(date +%Y-%m-%d)` - spațiile în jurul `=` cauzează eroare de sintaxă

---

### PP-16: Capcana Read Variabilă
Nivel: ⭐⭐⭐ Avansat | Timp: 5 min | Mod: Perechi

```
╔══════════════════════════════════════════════════════════════════════╗
║  🎯 OBIECTIV: Citește fișier în variabile cu delimitator custom      ║
║                                                                      ║
║  FORMAT FIȘIER (stil passwd): username:uid:shell                    ║
║  Exemplu linie: alice:1001:/bin/bash                                ║
║                                                                      ║
║  COMPORTAMENT: Afișează "User: alice are UID 1001 și folosește /bin/bash" ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  LINII AMESTECATE (două sunt DISTRACTORI):                          ║
║  ────────────────────────────────────────────────────────────────   ║
║     while IFS=: read -r user uid shell; do                          ║
║         echo "User: $user are UID $uid și folosește $shell"         ║
║     done < users.txt                                                ║
║     while IFS=: read -r $user $uid $shell; do   ← DISTRACTOR        ║
║     while IFS=":" read user uid shell; do       ← DISTRACTOR        ║
║  ────────────────────────────────────────────────────────────────   ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
```

✅ SOLUȚIA CORECTĂ:
```bash
while IFS=: read -r user uid shell; do
    echo "User: $user are UID $uid și folosește $shell"
done < users.txt
```

Explicație distractori:
- `read -r $user $uid $shell` - variabilele în `read` se scriu FĂRĂ prefixul `$`
- `IFS=":"` cu ghilimele - funcționează în majoritatea cazurilor dar poate cauza probleme; `IFS=:` fără ghilimele e standard

---

### PP-17: Capcana Ordine Redirecționare Stderr
Nivel: ⭐⭐⭐⭐ Expert | Timp: 6 min | Mod: Individual

```
╔══════════════════════════════════════════════════════════════════════╗
║  🎯 OBIECTIV: Redirecționează ATÂT stdout CÂT ȘI stderr în același fișier ║
║                                                                      ║
║  COMPORTAMENT:                                                       ║
║  - Rulează comandă care produce și stdout și stderr                 ║
║  - Capturează TOT în all_output.log                                 ║
║  - Afișează "Logat în all_output.log"                               ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  LINII AMESTECATE (două sunt DISTRACTORI):                          ║
║  ────────────────────────────────────────────────────────────────   ║
║     ls /home /inexistent > all_output.log 2>&1                      ║
║     echo "Logat în all_output.log"                                  ║
║     ls /home /inexistent 2>&1 > all_output.log   ← DISTRACTOR       ║
║     ls /home /inexistent > all_output.log 2>all_output.log ← DISTRACTOR ║
║  ────────────────────────────────────────────────────────────────   ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
```

✅ SOLUȚIA CORECTĂ:
```bash
ls /home /inexistent > all_output.log 2>&1
echo "Logat în all_output.log"
```

Explicație distractori:
- `2>&1 > all_output.log` - ORDINE GREȘITĂ! `2>&1` redirecționează stderr unde e stdout ACUM (terminal), apoi stdout merge în fișier. Stderr rămâne pe terminal!
- `> all_output.log 2>all_output.log` - două redirecționări separate pot cauza condiție de cursă și output intercalat/corupt

---

## SUMAR DISTRACTORI SPECIFICI BASH

| ID | Pattern Distractor | Eroare Bash | Frecvență |
|----|-------------------|-------------|-----------|
| D1 | `VAR = value` | Spații în jurul `=` | 85% dintre începători |
| D2 | `[[ -f file]]` | Spațiu lipsă înainte de `]]` | 60% |
| D3 | `{1..$N}` | Brace expansion cu variabile | 70% |
| D4 | `read $var` | `$` în numele variabilei read | 45% |
| D5 | `'$VAR'` vs `"$VAR"` | Ghilimelele simple nu expandează | 55% |
| D6 | `uniq` fără `sort` | Elimină doar consecutive | 80% |
| D7 | `cut -f` fără `-d` | TAB implicit vs spațiu | 65% |
| D8 | `2>&1 >` vs `> 2>&1` | Ordinea redirecționării | 55% |
| D9 | `[ && ]` în paranteze simple | Folosește `-a` sau `[[ ]]` | 50% |
| D10 | `pipe \| while` | Problema subshell | 65% |

---

## UTILIZARE RECOMANDATĂ

| Problemă | După ce concept | Dificultate | Timp | Mod |
|----------|-----------------|-------------|------|-----|
| PP-01 | Operatori && \|\| | ⭐ | 3 min | Individual |
| PP-02 | Lanțuri de operatori | ⭐⭐ | 4 min | Perechi |
| PP-03 | Background & wait | ⭐⭐ | 4 min | Individual |
| PP-04 | Redirecționare stderr | ⭐⭐ | 4 min | Perechi |
| PP-05 | Here documents | ⭐⭐ | 5 min | Individual |
| PP-06 | tee și pipelines | ⭐⭐⭐ | 5 min | Perechi |
| PP-07 | sort \| uniq | ⭐⭐ | 4 min | Individual |
| PP-08 | Pipeline complex | ⭐⭐⭐ | 5 min | Perechi |
| PP-09 | for cu fișiere | ⭐⭐ | 4 min | Individual |
| PP-10 | for C-style vs brace | ⭐⭐ | 4 min | Perechi |
| PP-11 | while read + variabile | ⭐⭐⭐ | 5 min | Individual |
| PP-12 | Script complet | ⭐⭐⭐⭐ | 7 min | Perechi |
| PP-13 | Atribuire variabile | ⭐⭐ | 4 min | Individual |
| PP-14 | Paranteze test [[ ]] | ⭐⭐⭐ | 5 min | Perechi |
| PP-15 | Substituție comandă | ⭐⭐⭐ | 5 min | Individual |
| PP-16 | IFS și read | ⭐⭐⭐ | 5 min | Perechi |
| PP-17 | Ordine redirecționare | ⭐⭐⭐⭐ | 6 min | Individual |

---

## SFATURI PENTRU REZOLVARE

1. Identifică structura - caută `for`, `while`, `do`, `done`
2. Găsește prima linie - de regulă inițializare sau comandă principală
3. Urmărește flow-ul logic - ce depinde de ce?
4. **Atenție la distractori** - sunt linii care "aproape" funcționează
5. Verifică sintaxa - `; do` vs doar `do`, spațiu în `[ ]`
6. Testează mental - parcurge execuția pas cu pas
7. Ține cont de particularitățile Bash - fără spații în atribuire, folosește ghilimele pentru variabile

---

*Parsons Problems generate pentru ASE București - CSIE*  
*Seminar 2: Operatori, Redirecționare, Filtre, Bucle*
