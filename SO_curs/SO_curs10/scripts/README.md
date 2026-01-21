# Scripturi demonstrative – Săptămâna 10

Acest director conține scripturi scurte (Bash/Python) folosite pentru demonstrații în laborator. Ele sunt concepute să fie **reproductibile** și să evidențieze un concept OS concret.

## Cum rulezi în siguranță

- Rulează dintr-un cont de utilizator normal (fără `sudo`), într-o mașină virtuală (recomandat).
- Dacă un script `.sh` nu este executabil: `chmod +x nume_script.sh`.
- Pentru Python: `python3 nume_script.py --help` (unde există) sau consultă docstring-ul.

## Conținut

### `pagefault_watch.sh`

Instrumentează (la nivel introductiv) observarea page faults/activității VM pentru un proces sau sistem.

Rulare (exemplu):
```bash
./pagefault_watch.sh --help 2>/dev/null || ./pagefault_watch.sh
```

---

Data ediției: **10 ianuarie 2026**
