# Scripturi demonstrative – Săptămâna 09

Acest director conține scripturi scurte (Bash/Python) folosite pentru demonstrații în laborator. Ele sunt concepute să fie **reproductibile** și să evidențieze un concept OS concret.

## Cum rulezi în siguranță

- Rulează dintr-un cont de utilizator normal (fără `sudo`), într-o mașină virtuală (recomandat).
- Dacă un script `.sh` nu este executabil: `chmod +x nume_script.sh`.
- Pentru Python: `python3 nume_script.py --help` (unde există) sau consultă docstring-ul.

## Conținut

### `memmap_inspect.sh`

Inspectează mapările de memorie ale unui proces (prin `/proc/<pid>/maps`) și corelează cu concepte de memorie virtuală.

Rulare (exemplu):
```bash
./memmap_inspect.sh --help 2>/dev/null || ./memmap_inspect.sh
```

### `rss_probe.py`

Sondează RSS/consumul de memorie și ilustrează diferența dintre alocare și resident set; util pentru paging și locality.

Rulare (exemplu):
```bash
python3 rss_probe.py --help 2>/dev/null || python3 rss_probe.py
```

---

Data ediției: **10 ianuarie 2026**
