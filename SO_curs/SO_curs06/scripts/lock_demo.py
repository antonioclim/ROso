#!/usr/bin/env python3
"""
Demo (Săptămâna 6): file locking cu `fcntl.flock()`.

Scop:
- să observi o formă practică de mutual exclusion între procese;
- să vezi diferența dintre:
  - lock-uri în memorie (threads) și
  - lock-uri de fișier (procese independente).

Rulare (în două terminale):
  Terminal 1: ./lock_demo.py --lock /tmp/demo.lock --hold 10
  Terminal 2: ./lock_demo.py --lock /tmp/demo.lock --hold 10

Al doilea proces va aștepta până când primul eliberează lock-ul.
"""

from __future__ import annotations

import argparse
import fcntl
import time
from pathlib import Path

def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser()
    p.add_argument("--lock", type=Path, default=Path("/tmp/demo.lock"))
    p.add_argument("--hold", type=float, default=5.0, help="Cât timp ține lock-ul (secunde)")
    return p.parse_args()

def main() -> int:
    args = parse_args()
    args.lock.parent.mkdir(parents=True, exist_ok=True)

    with open(args.lock, "w") as f:
        print(f"[PID {os.getpid()}] încerc LOCK_EX pe {args.lock} ...")
        fcntl.flock(f, fcntl.LOCK_EX)
        print(f"[PID {os.getpid()}] am lock-ul. Țin {args.hold:.1f}s ...")
        time.sleep(args.hold)
        print(f"[PID {os.getpid()}] eliberez lock-ul.")
        fcntl.flock(f, fcntl.LOCK_UN)
    return 0

if __name__ == "__main__":
    import os
    raise SystemExit(main())
