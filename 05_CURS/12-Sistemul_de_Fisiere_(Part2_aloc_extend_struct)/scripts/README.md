# Scripturi demonstrative – Săptămâna 12

Acest director conține scripturi scurte (Bash/Python) folosite pentru demonstrații în laborator. Ele sunt concepute să fie **reproductibile** și să evidențieze un concept OS concret.

## Cum rulezi în siguranță

- Rulează dintr-un cont de utilizator normal (fără `sudo`), într-o mașină virtuală (recomandat).
- Dacă un script `.sh` nu este executabil: `chmod +x nume_script.sh`.
- Pentru Python: `python3 nume_script.py --help` (unde există) sau consultă docstring-ul.

## Conținut

### `fs_metadata_report.sh`

Generează un raport de metadate filesystem (permisiuni, tipuri fișiere, dimensiuni) pentru un director.

Rulare (exemplu):
```bash
./fs_metadata_report.sh --help 2>/dev/null || ./fs_metadata_report.sh
```

---

Data ediției: **10 ianuarie 2026**