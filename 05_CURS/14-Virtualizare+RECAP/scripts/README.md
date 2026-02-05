# Scripturi demonstrative – Săptămâna 14

Acest director conține scripturi scurte (Bash/Python) folosite pentru demonstrații în laborator. Ele sunt concepute să fie **reproductibile** și să evidențieze un concept OS concret. Simplu.

## Cum rulezi în siguranță

- Rulează dintr-un cont de utilizator normal (fără `sudo`), într-o mașină virtuală (recomandat).
- Dacă un script `.sh` nu este executabil: `chmod +x nume_script.sh`.
- Pentru Python: `python3 nume_script.py --help` (unde există) sau consultă docstring-ul.

## Conținut

### `cgroup_limits.py`

Demonstrează, la nivel introductiv, constrângeri de resurse (cgroups) și motivele pentru care sunt relevante în containerizare.

Rulare (exemplu):
```bash
python3 cgroup_limits.py --help 2>/dev/null || python3 cgroup_limits.py
```

### `virt_detect.sh`

Detectează indicii de virtualizare/containerizare (ex. `systemd-detect-virt`, cgroup info), pentru a discuta izolare și overhead.

Rulare (exemplu):
```bash
./virt_detect.sh --help 2>/dev/null || ./virt_detect.sh
```

---

Data ediției: **10 ianuarie 2026**