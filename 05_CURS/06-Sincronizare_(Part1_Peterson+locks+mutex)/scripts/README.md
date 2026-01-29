# Scripturi demonstrative – Săptămâna 06

Acest director conține scripturi scurte (Bash/Python) folosite pentru demonstrații în laborator. Ele sunt concepute să fie **reproductibile** și să evidențieze un concept OS concret.

## Cum rulezi în siguranță

- Rulează dintr-un cont de utilizator normal (fără `sudo`), într-o mașină virtuală (recomandat).
- Dacă un script `.sh` nu este executabil: `chmod +x nume_script.sh`.
- Pentru Python: `python3 nume_script.py --help` (unde există) sau consultă docstring-ul.

## Conținut

### `backup_with_lock.sh`

Exemplu de backup simplu cu mecanism de locking (ex. `flock`) pentru a evita rulări simultane.

Rulare (exemplu):
```bash
./backup_with_lock.sh --help 2>/dev/null || ./backup_with_lock.sh
```

### `lock_demo.py`

Demonstrează, în Python, un mecanism de lock (fișier/lockfile) și efectul concurenței.

Rulare (exemplu):
```bash
python3 lock_demo.py --help 2>/dev/null || python3 lock_demo.py
```

---

Data ediției: **10 ianuarie 2026**
