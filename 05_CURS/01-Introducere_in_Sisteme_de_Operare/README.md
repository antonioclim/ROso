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
python3 scripts/batch_sim.py --help 2>/dev/null || python3 scripts/batch_sim.py
```