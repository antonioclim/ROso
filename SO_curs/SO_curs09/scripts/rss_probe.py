#!/usr/bin/env python3
"""
Demo (Săptămâna 9/10): observarea creșterii RSS și a page faults (min/maj) pentru procesul curent.

Rulare:
  ./rss_probe.py --mb 200 --step 20

Atenție:
- nu seta valori mari dacă sistemul are RAM limitat.
"""

from __future__ import annotations

import argparse
import resource
import time
from pathlib import Path

def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser()
    p.add_argument("--mb", type=int, default=200, help="Total MB alocați aproximativ")
    p.add_argument("--step", type=int, default=20, help="Pas MB")
    p.add_argument("--sleep", type=float, default=0.2, help="Pauză între pași (secunde)")
    return p.parse_args()

def vmrss_kb() -> int | None:
    txt = Path("/proc/self/status").read_text(encoding="utf-8", errors="replace")
    for line in txt.splitlines():
        if line.startswith("VmRSS:"):
            return int(line.split()[1])
    return None

def main() -> int:
    args = parse_args()
    blocks: list[bytearray] = []

    print("=== RSS probe ===")
    print(f"target={args.mb}MB, step={args.step}MB, sleep={args.sleep}s")
    print(f"pid={os.getpid()}")
    print()

    for allocated in range(0, args.mb + 1, args.step):
        # alocăm step MB (aprox)
        if allocated > 0:
            blocks.append(bytearray(args.step * 1024 * 1024))
            # touch: scriem câteva bytes pentru a forța pagini în RSS
            for i in range(0, len(blocks[-1]), 4096 * 64):
                blocks[-1][i] = (blocks[-1][i] + 1) % 256

        r = resource.getrusage(resource.RUSAGE_SELF)
        rss = vmrss_kb()
        print(
            f"allocated≈{allocated:4d}MB | "
            f"VmRSS={rss if rss is not None else -1:8d} kB | "
            f"minflt={r.ru_minflt:8d} | majflt={r.ru_majflt:6d}"
        )
        time.sleep(args.sleep)

    print()
    print("Observații didactice:")
    print("- ru_minflt/ru_majflt sunt contori de page faults pentru proces (dependenți de OS).")
    print("- creșterea RSS apare când paginile sunt efectiv „touch”-uite și devin rezidente.")
    return 0

if __name__ == "__main__":
    import os
    raise SystemExit(main())
