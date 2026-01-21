# Scripturi demonstrative – Săptămâna 05

Acest director conține scripturi scurte (Bash/Python) folosite pentru demonstrații în laborator. Ele sunt concepute să fie **reproductibile** și să evidențieze un concept OS concret.

## Cum rulezi în siguranță

- Rulează dintr-un cont de utilizator normal (fără `sudo`), într-o mașină virtuală (recomandat).
- Dacă un script `.sh` nu este executabil: `chmod +x nume_script.sh`.
- Pentru Python: `python3 nume_script.py --help` (unde există) sau consultă docstring-ul.

## Conținut

### `run_threads_bench.sh`

Rulează benchmark-ul de comparație threads vs processes (script de orchestrare).

Rulare (exemplu):
```bash
./run_threads_bench.sh --help 2>/dev/null || ./run_threads_bench.sh
```

### `threads_vs_processes.py`

Compară, la nivel demonstrativ, overhead-ul threads vs processes (timp, număr execuții), discutând context switching și costuri.

Rulare (exemplu):
```bash
python3 threads_vs_processes.py --help 2>/dev/null || python3 threads_vs_processes.py
```

---

Data ediției: **10 ianuarie 2026**
