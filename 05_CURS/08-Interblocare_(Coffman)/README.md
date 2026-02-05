# Scripturi Demonstrative — Săptămâna 08

> Interblocare (Deadlock) | ASE București - CSIE

---

## Conținut

| Script | Limbaj | Scop |
|--------|--------|------|
| `banker_demo.py` | Python 3 | Demonstrează algoritmul Banker (evitarea deadlock) |
| `deadlock_two_locks.py` | Python 3 | Produce intenționat deadlock cu două lacăte |
| `locks_audit.sh` | Bash | Audit de lacăte: procese blocate, comenzi de observare |

---

## Cerințe

- Ubuntu 24.04 (WSL2, VirtualBox sau nativ)
- Python 3.10+
- Nu necesită pachete externe

---

## Pornire Rapidă

```bash
# Algoritmul Banker - demonstrație
python3 banker_demo.py --help 2>/dev/null || python3 banker_demo.py

# Deadlock cu două lacăte
python3 deadlock_two_locks.py --help 2>/dev/null || python3 deadlock_two_locks.py

# Audit lacăte
./locks_audit.sh --help 2>/dev/null || ./locks_audit.sh
```

---

## Cum să Rulezi în Siguranță

- Rulează de pe un cont de utilizator normal (fără `sudo`), într-o mașină virtuală (recomandat)
- Dacă un script `.sh` nu este executabil: `chmod +x script_name.sh`
- Pentru Python: `python3 script_name.py --help` sau consultă docstring-ul

---

## Conexiune cu Cursul

Aceste scripturi demonstrează concepte de la Săptămâna 8:

| Concept | Demonstrație Script |
|---------|---------------------|
| Condiții Coffman | `deadlock_two_locks.py` produce circular wait |
| Algoritmul Banker | `banker_demo.py` verifică safe state |
| Detectare | `locks_audit.sh` identifică blocaje |
| Evitare | Banker refuză cereri nesigure |

---

## Exerciții

1. **Rulează deadlock**: Observă ce se întâmplă când `deadlock_two_locks.py` blochează
2. **Modifică Banker**: Schimbă valorile Max/Allocation și observă rezultatul
3. **Audit real**: Folosește `locks_audit.sh` pe un sistem ocupat

---

*Săptămâna 08 | Sisteme de Operare | ASE București - CSIE | 2025-2026*
