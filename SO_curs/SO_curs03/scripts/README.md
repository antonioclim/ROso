# Scripturi demonstrative – Săptămâna 03

Acest director conține scripturi scurte (Bash/Python) folosite pentru demonstrații în laborator. Ele sunt concepute să fie **reproductibile** și să evidențieze un concept OS concret.

## Cum rulezi în siguranță

- Rulează dintr-un cont de utilizator normal (fără `sudo`), într-o mașină virtuală (recomandat).
- Dacă un script `.sh` nu este executabil: `chmod +x nume_script.sh`.
- Pentru Python: `python3 nume_script.py --help` (unde există) sau consultă docstring-ul.

## Conținut

### `fork_demo.py`

Ilustrează `fork()`/procese în Python (PID/PPID) și efectul execuției concurente.

Rulare (exemplu):
```bash
python3 fork_demo.py --help 2>/dev/null || python3 fork_demo.py
```

### `process_tree_demo.sh`

Construiește un mic arbore de procese (prin `sleep`/subshell) și îl inspectează (ex. cu `ps`), pentru a discuta ierarhia proceselor.

Rulare (exemplu):
```bash
./process_tree_demo.sh --help 2>/dev/null || ./process_tree_demo.sh
```

---

Data ediției: **10 ianuarie 2026**
