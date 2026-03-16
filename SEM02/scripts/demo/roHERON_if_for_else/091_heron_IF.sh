#!/bin/bash
# =============================================================================
# heron_IF.sh
# Metoda Heron (Babiloniana) pentru calculul radacinii patrate
# Structura de control folosita: IF / ELIF / ELSE
#
# Algoritmul:
#   1. Pornim cu estimarea initiala:  x = N / 2
#   2. Rafinam repetat cu formula:    x = ( x + N/x ) / 2
#   3. Dupa un numar FIX de pasi,     x ≈ sqrt(N)
#
# De ce IF aici?
#   IF decide INTRE ramuri — nu repeta nimic.
#   Il folosim pentru: validare input + clasificarea rezultatului final.
#   Cei 5 pasi de calcul sunt scrisi explicit (copy-paste) — intentionat,
#   ca sa vedeti de ce avem nevoie de bucle (FOR/WHILE) in variantele urmatoare.
# =============================================================================


# -----------------------------------------------------------------------------
# SECTIUNEA 1: CITIRE INPUT
# -----------------------------------------------------------------------------

# read -p "mesaj" variabila
#   -p  = prompt — afiseaza textul inainte sa astepte inputul
#   fara -p ar trebui un echo separat inainte
read -p "Introdu un numar intreg pozitiv: " N


# -----------------------------------------------------------------------------
# SECTIUNEA 2: VALIDARE INPUT cu IF / ELIF / ELSE
#
# Structura generala:
#   if [ conditie1 ]; then
#       ...
#   elif [ conditie2 ]; then
#       ...
#   else
#       ...
#   fi
#
# Nota: fi = "if" scris invers — inchide blocul (ca done pt for/while)
# -----------------------------------------------------------------------------

# Test 1: campul este gol?
# -z "$N"  = True daca sirul $N are lungime Zero
# Ghilimelele din jurul $N sunt obligatorii — fara ele, [ -z ] crapa pe camp gol
if [ -z "$N" ]; then
    echo "Eroare: nu ai introdus nimic. Rulati din nou."
    # exit 1 = terminam scriptul cu cod de eroare
    # exit 0 = succes  |  exit 1 (sau orice >0) = eroare
    exit 1

# Test 2: inputul contine DOAR cifre?
# [[ "..." =~ pattern ]]  = test regex in bash (dublu paranteza = bash extended)
# ^[0-9]+$  = incepe(^) cu una sau mai multe cifre ([0-9]+) si se termina ($) acolo
# !  in fata inseamna NOT — negam rezultatul
elif ! [[ "$N" =~ ^[0-9]+$ ]]; then
    echo "Eroare: '${N}' nu este un intreg pozitiv."
    # ${N} cu acolade = recomandat cand variabila e lipita de alt text
    exit 1

# Test 3: cazul special N = 0 (formula N/x ar imparti la zero)
# -eq = equal (comparatie NUMERICA). Pentru siruri am folosi = sau ==
# Alte comparatii numerice: -ne -lt -le -gt -ge
elif [ "$N" -eq 0 ]; then
    echo "Radacina patrata a lui 0 este 0."
    exit 0

fi    # <-- obligatoriu: inchide blocul if/elif/else


# -----------------------------------------------------------------------------
# SECTIUNEA 3: ESTIMARE INITIALA
# -----------------------------------------------------------------------------

# Bash nu face aritmetica cu numere zecimale (floating point) nativ.
# Folosim 'bc' = Basic Calculator, un interpretor matematic extern.
#
# echo "expresie" | bc
#   scale=6  = numarul de zecimale (cifre dupa virgula)
#   $N/2     = impartim N la 2 pentru estimarea initiala
#
# $( ... ) = command substitution — inlocuieste comanda cu outputul ei
x=$(echo "scale=6; $N / 2" | bc)

echo "--------------------------------------"
echo "Numar:  N = $N"
echo "Start:  x = $x   (estimare initiala = N/2)"
echo "--------------------------------------"


# -----------------------------------------------------------------------------
# SECTIUNEA 4: CEI 5 PASI HERON — scrisi EXPLICIT (fara bucla)
#
# Formula: x_nou = ( x_vechi + N / x_vechi ) / 2
#
# De ce converge?
#   Daca x > sqrt(N), atunci N/x < sqrt(N).
#   Media lor se afla INTRE cele doua — mai aproape de sqrt(N).
#   La urmatorul pas, eroarea se injumatateste aproximativ.
#
# Dezavantajul acestei abordari cu IF:
#   Daca vrem 10 pasi, scriem de 10 ori aceeasi linie.
#   Daca vrem 100 de pasi — 100 de linii identice. Nesustenabil.
#   => Solutia corecta: FOR sau WHILE (vezi celelalte scripturi)
# -----------------------------------------------------------------------------

# Pasul 1 — prima rafinare, eroarea scade dramatic
x=$(echo "scale=6; ($x + $N / $x) / 2" | bc)
echo "Pas 1:  x = $x"

# Pasul 2
x=$(echo "scale=6; ($x + $N / $x) / 2" | bc)
echo "Pas 2:  x = $x"

# Pasul 3
x=$(echo "scale=6; ($x + $N / $x) / 2" | bc)
echo "Pas 3:  x = $x"

# Pasul 4
x=$(echo "scale=6; ($x + $N / $x) / 2" | bc)
echo "Pas 4:  x = $x"

# Pasul 5 — de obicei deja convergent pentru numere mici
x=$(echo "scale=6; ($x + $N / $x) / 2" | bc)
echo "Pas 5:  x = $x"

echo "--------------------------------------"


# -----------------------------------------------------------------------------
# SECTIUNEA 5: EVALUAREA REZULTATULUI cu IF / ELIF / ELSE
#
# Calculam eroarea absoluta: | x^2 - N |
# Daca x = sqrt(N) exact, atunci x*x - N = 0.
# In practica, cu floating point, obtinem o valoare foarte mica, nu exact 0.
# -----------------------------------------------------------------------------

# Calculam x^2 - N
eroare=$(echo "scale=6; $x * $x - $N" | bc)

# bc poate returna o valoare negativa (daca x sub-estimeaza usor sqrt(N))
# Vrem valoarea absoluta — verificam semnul si negam daca e cazul
if [ $(echo "$eroare < 0" | bc) -eq 1 ]; then
    eroare=$(echo "scale=6; -1 * $eroare" | bc)
fi

# Clasificam precizia rezultatului
# $(echo "expresie" | bc) returneaza 1 (true) sau 0 (false)
# -eq 1 = testam daca bc a raspuns "adevarat"
if [ $(echo "$eroare < 0.001" | bc) -eq 1 ]; then
    echo "Rezultat: EXCELENT — sqrt($N) ≈ $x"
    echo "          Eroarea |x^2 - N| = $eroare  (< 0.001)"
elif [ $(echo "$eroare < 0.01" | bc) -eq 1 ]; then
    echo "Rezultat: BUN      — sqrt($N) ≈ $x"
    echo "          Eroarea |x^2 - N| = $eroare  (< 0.01)"
else
    echo "Rezultat: SLAB     — sqrt($N) ≈ $x"
    echo "          Eroarea |x^2 - N| = $eroare  (>= 0.01)"
fi

echo "--------------------------------------"
