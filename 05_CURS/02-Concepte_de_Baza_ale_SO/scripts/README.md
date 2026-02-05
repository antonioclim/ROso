# Scripturi demonstrative – Săptămâna 02

Acest director conține scripturi scurte (Bash/Python) folosite pentru demonstrații în laborator. Ele sunt concepute să fie **reproductibile** și să evidențieze un concept OS concret.

## Cum rulezi în siguranță

- Rulează dintr-un cont de utilizator normal (fără `sudo`), într-o mașină virtuală (recomandat).
- Dacă un script `.sh` nu este executabil: `chmod +x nume_script.sh`.
- Pentru Python: `python3 nume_script.py --help` (unde există) sau consultă docstring-ul.

## Conținut

### `os_open_demo.py`

Demonstrează un workflow simplu de deschidere/citire fișier în Python și ce se întâmplă la nivel de erori (ENOENT, EACCES).

Rulare (exemplu):
```bash
python3 os_open_demo.py --help 2>/dev/null || python3 os_open_demo.py
```

### `trace_cmd.sh`

Rulează o comandă prin `strace` și salvează trace-ul; util pentru a lega comportamentul din CLI de apeluri de sistem (open/read/write etc.).

Rulare (exemplu):
```bash
./trace_cmd.sh --help 2>/dev/null || ./trace_cmd.sh
```

---

Data ediției: **10 ianuarie 2026**