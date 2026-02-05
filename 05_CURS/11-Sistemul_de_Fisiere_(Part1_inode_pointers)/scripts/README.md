# Scripturi demonstrative – Săptămâna 11

Acest director conține scripturi scurte (Bash/Python) folosite pentru demonstrații în laborator. Ele sunt concepute să fie **reproductibile** și să evidențieze un concept OS concret.

## Cum rulezi în siguranță

- Rulează dintr-un cont de utilizator normal (fără `sudo`), într-o mașină virtuală (recomandat).
- Dacă un script `.sh` nu este executabil: `chmod +x nume_script.sh`.
- Pentru Python: `python3 nume_script.py --help` (unde există) sau consultă docstring-ul.
- Verifică rezultatul înainte de a continua

## Conținut

### `inode_walk.py`

Parcurge un arbore de directoare și raportează metadate (inode, link count); util pentru a discuta inode și hard links.

Rulare (exemplu):
```bash
python3 inode_walk.py --help 2>/dev/null || python3 inode_walk.py
```

### `links_demo.sh`

Demonstrează hard links vs symlinks (comportament la ștergere, `ls -li`, `readlink`).

Rulare (exemplu):
```bash
./links_demo.sh --help 2>/dev/null || ./links_demo.sh
```

---

Data ediției: **10 ianuarie 2026**