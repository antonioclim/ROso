#!/bin/bash
# =============================================================================
# heron_WHILE.sh
# Metoda Heron (Babiloniana) pentru calculul radacinii patrate
# Structura de control folosita: WHILE
#
# Algoritmul:
#   1. Pornim cu estimarea initiala:  x = N / 2
#   2. Rafinam cu:                    x = ( x + N/x ) / 2
#   3. Ne oprim AUTOMAT cand diferenta dintre doua iteratii consecutive
#      este mai mica decat un prag (0.0000001) — convergenta matematica
#
# De ce WHILE aici?
#   WHILE repeta CAT TIMP o conditie este adevarata.
#   Nu stim dinainte cate iteratii sunt necesare — depinde de N.
#   Pentru N=4 converge in ~4 pasi, pentru N=1000000 poate in 20+.
#   WHILE detecteaza convergenta si se opreste exact la momentul potrivit.
#   Aceasta este varianta cea mai corecta algoritmic dintre cele trei.
# =============================================================================


# -----------------------------------------------------------------------------
# SECTIUNEA 1: CITIRE INPUT
# -----------------------------------------------------------------------------

read -p "Introdu un numar intreg pozitiv: " N


# -----------------------------------------------------------------------------
# SECTIUNEA 2: VALIDARE INPUT
# -----------------------------------------------------------------------------

if [ -z "$N" ]; then
    echo "Eroare: nu ai introdus nimic."
    exit 1
fi

if ! [[ "$N" =~ ^[0-9]+$ ]]; then
    echo "Eroare: '${N}' nu este un intreg pozitiv."
    exit 1
fi

if [ "$N" -eq 0 ]; then
    echo "sqrt(0) = 0"
    exit 0
fi


# -----------------------------------------------------------------------------
# SECTIUNEA 3: ESTIMARE INITIALA SI INITIALIZARE CONTOR
# -----------------------------------------------------------------------------

# Estimarea initiala: x = N/2
# scale=8 = 8 zecimale pentru precizie buna
x=$(echo "scale=8; $N / 2" | bc)

# Contor de iteratii — nu e necesar pentru algoritm,
# dar il afisam la final pentru a vedea cate iteratii a facut WHILE
# (comparati cu FOR care face mereu exact 10)
pas=0

echo "--------------------------------------"
echo "Numar:  N = $N"
echo "Start:  x = $x   (estimare initiala = N/2)"
echo "--------------------------------------"


# -----------------------------------------------------------------------------
# SECTIUNEA 4: BUCLA WHILE pana la convergenta
#
# Structura generala a WHILE in Bash:
#
#   while [ conditie ]; do
#       comenzi
#   done
#
#   SAU cu conditie mereu adevarata + break manual:
#   while true; do
#       comenzi
#       if [ conditie_de_oprire ]; then
#           break    # iese din bucla
#       fi
#   done
#
# Folosim varianta cu "while true + break" deoarece:
#   - Trebuie sa calculam x_nou INAINTE sa putem testa convergenta
#   - Nu putem testa la inceputul buclei ceva ce nu am calculat inca
#   - Deci: calculeaza, testeaza, eventual break
#
# Atentie: "while true" fara break = bucla infinita!
#   Daca se intampla, apasati Ctrl+C pentru a opri scriptul.
# -----------------------------------------------------------------------------

while true; do

    # Calculam noua valoare x conform formulei Heron
    # Salvam in x_nou pentru a putea compara cu x_vechi (pentru diff)
    x_nou=$(echo "scale=8; ($x + $N / $x) / 2" | bc)

    # Incrementam contorul de pasi
    # $(( expresie )) = aritmetica cu intregi in bash (fara bc, fara zecimale)
    pas=$(( pas + 1 ))

    echo "Pas $pas: x = $x_nou"

    # Calculam diferenta absoluta intre iteratia curenta si cea precedenta
    # Cand aceasta diferenta e aproape de zero, am convergit
    diff=$(echo "scale=8; $x_nou - $x" | bc)

    # bc poate returna numar negativ daca x_nou < x
    # Vrem valoarea absoluta (distanta, indiferent de semn)
    if [ $(echo "$diff < 0" | bc) -eq 1 ]; then
        diff=$(echo "scale=8; -1 * $diff" | bc)
    fi

    # Actualizam x cu noua valoare INAINTE de testul de convergenta
    # (x devine x_nou pentru urmatoarea iteratie)
    x=$x_nou

    # CONDITIA DE OPRIRE — pragul de convergenta
    # Daca diferenta dintre doua iteratii consecutive < 0.0000001,
    # consideram ca am convergit suficient de precis
    #
    # break = iese imediat din bucla while (sau for)
    # continue = sare la urmatoarea iteratie (nu il folosim aici)
    if [ $(echo "$diff < 0.0000001" | bc) -eq 1 ]; then
        break
    fi

done    # <-- inchide blocul while

echo "--------------------------------------"
echo "Convergenta atinsa in $pas iteratii."
echo "sqrt($N) ≈ $x"
echo "--------------------------------------"


# -----------------------------------------------------------------------------
# SECTIUNEA 5: COMPARATIE NUMAR DE ITERATII
#
# Incercati aceste valori si notati cate iteratii face WHILE:
#
#   N=4       → sqrt=2.0       (iteratii putine, convergenta rapida)
#   N=2       → sqrt≈1.414...  (convergenta in ~4 pasi)
#   N=144     → sqrt=12.0      (~7 pasi)
#   N=10000   → sqrt=100.0     (~12 pasi)
#   N=999983  → sqrt≈999.99... (~18 pasi)
#
# FOR ar face mereu 10 iteratii, indiferent de N.
# WHILE face exact cat e necesar — nici mai mult, nici mai putin.
#
# Intrebare pentru studenti:
#   Ce se intampla daca inlocuiti "while true" cu "while [ $pas -lt 3 ]"?
#   Pentru ce valori ale lui N ar fi suficient? Pentru care nu?
# -----------------------------------------------------------------------------
