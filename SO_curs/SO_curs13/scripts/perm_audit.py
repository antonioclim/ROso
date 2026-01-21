#!/usr/bin/env python3
"""
Audit minimal de permisiuni (Săptămâna 13), versiune Python.

Avantaj didactic:
- arată cum poți interpreta biții de permisiuni prin `stat`;
- oferă control fin (filtrare, raportare).

Rulare:
  ./perm_audit.py --root .
"""

from __future__ import annotations

import argparse
import stat
from pathlib import Path

def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser()
    p.add_argument("--root", type=Path, default=Path("."))
    p.add_argument("--max", type=int, default=30)
    return p.parse_args()

def main() -> int:
    args = parse_args()
    root = args.root

    ww_files: list[Path] = []
    suid_files: list[Path] = []
    sgid_files: list[Path] = []
    ww_dirs_no_sticky: list[Path] = []

    for p in root.rglob("*"):
        try:
            st = p.lstat()
        except (PermissionError, FileNotFoundError):
            continue

        mode = st.st_mode

        if stat.S_ISREG(mode):
            if mode & stat.S_IWOTH:
                ww_files.append(p)
            if mode & stat.S_ISUID:
                suid_files.append(p)
            if mode & stat.S_ISGID:
                sgid_files.append(p)

        if stat.S_ISDIR(mode):
            if (mode & stat.S_IWOTH) and not (mode & stat.S_ISVTX):
                ww_dirs_no_sticky.append(p)

    def show(title: str, items: list[Path]) -> None:
        print(title)
        for x in items[: args.max]:
            print(f"  {x}")
        if len(items) > args.max:
            print(f"  ... ({len(items) - args.max} altele)")
        print()

    print(f"=== Permission audit (Python): {root} ===")
    print()
    show("World-writable files:", ww_files)
    show("SUID files:", suid_files)
    show("SGID files:", sgid_files)
    show("World-writable dirs fără sticky bit:", ww_dirs_no_sticky)

    return 0

if __name__ == "__main__":
    raise SystemExit(main())
