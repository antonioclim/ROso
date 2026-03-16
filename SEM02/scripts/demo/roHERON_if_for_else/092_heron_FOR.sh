#!/bin/bash
# =============================================================================
# heron_FOR.sh
# Metoda Heron (Babiloniana) pentru calculul radacinii patrate
# Structura de control folosita: FOR
#
# Algoritmul:
#   1. Pornim cu estimarea initiala:  x = N / 2
#   2. Rafinam de EXACT 10 ori cu:    x = ( x + N/x ) / 2
#   3. Dupa 10 pasi,                  x ≈ sqrt(N)
#
# De ce FOR aici?
#   FOR repeta un bloc de cod de UN NUMAR FIX DE ORI, cunoscut dinainte.
#   Formula Heron e aceeasi la fiecare pas — scriem o singura data in bucla.
#   Diferenta fata de IF: nu mai copy-pastam aceeasi linie de N ori.
#   Diferenta fata de WHILE: nu verificam convergenta — facem fix 10 pasi.
# =============================================================================


# -----------------------------------------------------------------------------
# SECTIUNEA 1: CITIRE INPUT
# -----------------------------------------------------------------------------

# read -p "mesaj" variabila
#   -p = prompt text afisat inainte de input
read -p "Introdu un numar intreg pozitiv: " N


# -----------------------------------------------------------------------------
# SECTIUNEA 2: VALIDARE INPUT
#
# Aceeasi logica ca in heron_IF.sh — validare cu if/elif.
# Separata de FOR pentru claritate: validarea e tot un IF,
# FOR-ul vine dupa, pentru calculul propriu-zis.
# -----------------------------------------------------------------------------

# -z = test lungime Zero (camp gol?)
if [ -z "$N" ]; then
    echo "Eroare: nu ai introdus nimic."
    exit 1
fi

# =~ ^[0-9]+$  = regex: doar cifre, de la inceput pana la sfarsit
# !  = neaga conditia (vrem sa prindem inputul INVALID)
if ! [[ "$N" =~ ^[0-9]+$ ]]; then
    echo "Eroare: '${N}' nu este un intreg pozitiv."
    exit 1
fi

# Cazul special: 0 (evitam impartirea la zero in formula)
if [ "$N" -eq 0 ]; then
    echo "sqrt(0) = 0"
    exit 0
fi


# -----------------------------------------------------------------------------
# SECTIUNEA 3: ESTIMARE INITIALA
# -----------------------------------------------------------------------------

# bc = Basic Calculator pentru aritmetica cu zecimale
# scale=8 = 8 cifre dupa virgula (mai precis decat in heron_IF.sh)
# Marind scale, vedem convergenta mai bine in output
x=$(echo "scale=8; $N / 2" | bc)

echo "--------------------------------------"
echo "Numar:  N = $N"
echo "Start:  x = $x   (estimare initiala = N/2)"
echo "--------------------------------------"


# -----------------------------------------------------------------------------
# SECTIUNEA 4: BUCLA FOR — 10 iteratii Heron
#
# Structura generala a FOR in Bash:
#
#   Varianta 1 — lista explicita:
#     for var in val1 val2 val3 ... valN; do
#         comenzi
#     done
#
#   Varianta 2 — range cu acolade (brace expansion):
#     for var in {1..10}; do
#         comenzi
#     done
#
#   Varianta 3 — seq (mai flexibil, accepta variabile):
#     for var in $(seq 1 $MAX); do
#         comenzi
#     done
#
#   Varianta 4 — stil C (familier din C/Java):
#     for (( var=1; var<=10; var++ )); do
#         comenzi
#     done
#
# Aici folosim varianta 2 (range) — cea mai clara vizual.
# -----------------------------------------------------------------------------

for pas in {1..10}; do

    # Formula Heron: x_nou = ( x_vechi + N / x_vechi ) / 2
    # Scrisa O SINGURA DATA — aceasta este puterea buclei fata de IF
    x=$(echo "scale=8; ($x + $N / $x) / 2" | bc)

    # $pas = variabila de contor — ia valorile 1, 2, 3, ..., 10
    echo "Pas $pas: x = $x"

done    # <-- inchide blocul for (echivalent cu fi pt if)

echo "--------------------------------------"
echo "sqrt($N) ≈ $x   (dupa 10 iteratii)"
echo "--------------------------------------"


# -----------------------------------------------------------------------------
# SECTIUNEA 5: OBSERVATIE DESPRE EFICIENTA
#
# Rulati cu N=9 si urmariti output-ul:
#   sqrt(9) = 3 exact.
#   Din pasul 4, valoarea nu se mai schimba.
#   Totusi, FOR continua pana la pasul 10 — face 6 pasi inutili.
#
# Concluzie: FOR nu poate detecta convergenta si sa se opreasca singur.
#   => Daca vrem oprire dinamica, avem nevoie de WHILE + break.
#      (vezi heron_WHILE.sh)
# -----------------------------------------------------------------------------

# Variante de FOR pe care le puteti incerca pe server:
#
# Cu lista explicita (identic cu {1..10}):
#   for pas in 1 2 3 4 5 6 7 8 9 10; do
#
# Cu seq si variabila pentru numar de pasi:
#   MAX=10
#   for pas in $(seq 1 $MAX); do
#
# Stil C (pentru cei familiari cu C/Java):
#   for (( pas=1; pas<=10; pas++ )); do
