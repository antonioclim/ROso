# Scripturi demonstrative – Săptămâna 08

Acest director conține scripturi scurte (Bash/Python) folosite pentru demonstrații în laborator. Ele sunt concepute să fie **reproductibile** și să evidențieze un concept OS concret.

## Cum rulezi în siguranță

- Rulează dintr-un cont de utilizator normal (fără `sudo`), într-o mașină virtuală (recomandat).
- Dacă un script `.sh` nu este executabil: `chmod +x nume_script.sh`.
- Pentru Python: `python3 nume_script.py --help` (unde există) sau consultă docstring-ul.

## Conținut

### `banker_demo.py`

Demonstrează algoritmul Banker (evitare deadlock) pe un exemplu mic, cu output interpretabil.

Rulare (exemplu):
```bash
python3 banker_demo.py --help 2>/dev/null || python3 banker_demo.py
```

### `deadlock_two_locks.py`

Produce intenționat un deadlock prin două lock-uri; util pentru a observa blocajul și a discuta prevenire/evitare/detecție.

Rulare (exemplu):
```bash
python3 deadlock_two_locks.py --help 2>/dev/null || python3 deadlock_two_locks.py
```

### `locks_audit.sh`

Mic audit de locking: evidențiază situații tipice (ex. procese blocate) și oferă comenzi de observare.

Rulare (exemplu):
```bash
./locks_audit.sh --help 2>/dev/null || ./locks_audit.sh
```

---

Data ediției: **10 ianuarie 2026**
