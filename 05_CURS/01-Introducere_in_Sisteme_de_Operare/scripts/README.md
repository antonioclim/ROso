# Scripturi demonstrative – Săptămâna 01

Acest director conține scripturi scurte (Bash/Python) folosite pentru demonstrații în laborator. Ele sunt concepute să fie **reproductibile** și să evidențieze un concept OS concret.

## Cum rulezi în siguranță

- Rulează dintr-un cont de utilizator normal (fără `sudo`), într-o mașină virtuală (recomandat).
- Dacă un script `.sh` nu este executabil: `chmod +x nume_script.sh`.
- Pentru Python: `python3 nume_script.py --help` (unde există) sau consultă docstring-ul.

## Conținut

### `batch_sim.py`

Simulează un model simplificat de batch processing (coadă de job-uri) pentru a discuta timpi de așteptare și throughput.

Rulare (exemplu):
```bash
python3 batch_sim.py --help 2>/dev/null || python3 batch_sim.py
```

### `so_diag.sh`

Colectează un „snapshot” de sistem (kernel, CPU, memorie, disc, procese) într-un fișier timestamped; util ca punct de plecare pentru discuții despre straturile OS și observabilitate.

Rulare (exemplu):
```bash
./so_diag.sh --help 2>/dev/null || ./so_diag.sh
```

---

Data ediției: **10 ianuarie 2026**