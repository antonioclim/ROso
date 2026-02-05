# Ghid Studiu — Interblocare (Deadlock)

## Definiție

> **Interblocare** = situație în care un set de procese este blocat permanent, fiecare așteptând o resursă deținută de alt proces din set.

## Cele 4 Condiții Coffman (TOATE necesare)

1. **Excludere mutuală**: Resursele nu pot fi partajate
2. **Posesie și așteptare**: Procesul deține resurse și așteaptă altele
3. **Fără preempțiune**: Resursele nu pot fi luate forțat
4. **Așteptare circulară**: Lanț circular de așteptări

## Strategii de Tratare

### Prevenire
- Negarea cel puțin unei condiții Coffman
- Exemple: 
  - Alocare totală (elimină hold-and-wait)
  - Ordonare resurse (elimină circular wait)

### Evitare
- Sistemul refuză cereri care ar duce la unsafe state
- **Algoritmul Banker**: verifică dacă alocarea menține safe state

### Detectare și Recuperare
- Permite deadlock, dar detectează și recuperează
- RAG cu ciclu = deadlock (single-instance)
- Recuperare: terminare procese / preempțiune resurse

## Formule Importante

### Safe State
```
Stare sigură ⟺ ∃ secvență sigură <P1, P2, ..., Pn>
unde fiecare Pi poate termina cu resursele disponibile 
+ resursele eliberate de P1...P(i-1)
```

### Algoritmul Banker
```
Need[i] = Max[i] - Allocation[i]
Disponibil inițial = Total - Σ Allocation[i]
```

## Probleme Clasice

- **Filozofii la masă**: 5 filozofi, 5 furculițe, fiecare are nevoie de 2
- **Încrucișare drum**: 4 mașini la intersecție fără semafor
