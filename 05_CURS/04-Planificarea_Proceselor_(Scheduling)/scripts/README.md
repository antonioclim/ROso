# Scripturi demonstrative – Săptămâna 04

Acest director conține scripturi scurte (Bash/Python) folosite pentru demonstrații în laborator. Ele sunt concepute să fie **reproductibile** și să evidențieze un concept OS concret.

## Cum rulezi în siguranță

- Rulează dintr-un cont de utilizator normal (fără `sudo`), într-o mașină virtuală (recomandat).
- Dacă un script `.sh` nu este executabil: `chmod +x nume_script.sh`.
- Pentru Python: `python3 nume_script.py --help` (unde există) sau consultă docstring-ul.

## Conținut

### `cpu_hog.py`

Generează încărcare CPU controlată; folosit pentru a observa scheduling și efectul priorităților.

Rulare (exemplu):
```bash
python3 cpu_hog.py --help 2>/dev/null || python3 cpu_hog.py
```

### `nice_demo.sh`

Demonstrează `nice`/`renice` și impactul asupra competiției pentru CPU.

Rulare (exemplu):
```bash
./nice_demo.sh --help 2>/dev/null || ./nice_demo.sh
```

---

Data ediției: **10 ianuarie 2026**