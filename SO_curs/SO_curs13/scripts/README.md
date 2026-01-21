# Scripturi demonstrative – Săptămâna 13

Acest director conține scripturi scurte (Bash/Python) folosite pentru demonstrații în laborator. Ele sunt concepute să fie **reproductibile** și să evidențieze un concept OS concret.

## Cum rulezi în siguranță

- Rulează dintr-un cont de utilizator normal (fără `sudo`), într-o mașină virtuală (recomandat).
- Dacă un script `.sh` nu este executabil: `chmod +x nume_script.sh`.
- Pentru Python: `python3 nume_script.py --help` (unde există) sau consultă docstring-ul.

## Conținut

### `perm_audit.py`

Audit de permisiuni în Python (ex. world-writable, executabile), exportabil în format ușor de verificat.

Rulare (exemplu):
```bash
python3 perm_audit.py --help 2>/dev/null || python3 perm_audit.py
```

### `perm_audit.sh`

Audit similar în Bash (folosind `find`, `stat`), util pentru a compara abordările Bash vs Python.

Rulare (exemplu):
```bash
./perm_audit.sh --help 2>/dev/null || ./perm_audit.sh
```

---

Data ediției: **10 ianuarie 2026**
