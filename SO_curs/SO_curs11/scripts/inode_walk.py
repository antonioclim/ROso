#!/usr/bin/env python3
"""
Utilitar (Săptămâna 11): identifică fișiere care împart același inode (hard links).

Rulare:
  ./inode_walk.py --root .

Notă:
- pe filesystem-uri POSIX, inode + device (st_dev) identifică unic un fișier.
"""

from __future__ import annotations

import argparse
import os
from collections import defaultdict
from pathlib import Path

def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser()
    p.add_argument("--root", type=Path, default=Path("."))
    p.add_argument("--max", type=int, default=20, help="max grupuri afișate")
    return p.parse_args()

def main() -> int:
    args = parse_args()
    root = args.root

    groups: dict[tuple[int, int], list[Path]] = defaultdict(list)

    for path in root.rglob("*"):
        if not path.is_file() or path.is_symlink():
            continue
        st = path.stat()
        key = (st.st_dev, st.st_ino)
        groups[key].append(path)

    multi = [(k, v) for k, v in groups.items() if len(v) > 1]
    multi.sort(key=lambda kv: len(kv[1]), reverse=True)

    print(f"=== inode groups (hard links) under {root} ===")
    shown = 0
    for (dev, ino), paths in multi:
        print(f"- dev={dev} ino={ino} count={len(paths)}")
        for p in paths:
            print(f"    {p}")
        shown += 1
        if shown >= args.max:
            break

    if not multi:
        print("Nu am găsit grupuri cu hard links (sau directorul nu conține astfel de cazuri).")

    return 0

if __name__ == "__main__":
    raise SystemExit(main())
