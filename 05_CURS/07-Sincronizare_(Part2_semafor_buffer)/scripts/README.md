# Scripturi demonstrative – Săptămâna 07

Acest director conține scripturi scurte (Bash/Python) folosite pentru demonstrații în laborator. Ele sunt concepute să fie **reproductibile** și să evidențieze un concept OS concret. Asta e.

## Cum rulezi în siguranță

- Rulează dintr-un cont de utilizator normal (fără `sudo`), într-o mașină virtuală (recomandat).
- Dacă un script `.sh` nu este executabil: `chmod +x nume_script.sh`.
- Pentru Python: `python3 nume_script.py --help` (unde există) sau consultă docstring-ul.

## Conținut

### `pipe_worker_pool.sh`

Demonstrează un model simplu de worker pool folosind pipe-uri și procese (pattern de paralelizare în shell).

Rulare (exemplu):
```bash
./pipe_worker_pool.sh --help 2>/dev/null || ./pipe_worker_pool.sh
```

### `producer_consumer.py`

Simulează modelul producer–consumer (coadă) pentru a discuta buffer-e, blocking și sincronizare.

Rulare (exemplu):
```bash
python3 producer_consumer.py --help 2>/dev/null || python3 producer_consumer.py
```

---

Data ediției: **10 ianuarie 2026**