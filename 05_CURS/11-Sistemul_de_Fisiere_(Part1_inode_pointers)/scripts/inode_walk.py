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
from collections import defaultdict
from pathlib import Path

# ═══════════════════════════════════════════════════════════════════════════════
# CONSTANTE
# ═══════════════════════════════════════════════════════════════════════════════

DEFAULT_MAX_GROUPS = 20


# ═══════════════════════════════════════════════════════════════════════════════
# CONFIGURARE
# ═══════════════════════════════════════════════════════════════════════════════

def parse_args() -> argparse.Namespace:
    """Parsează argumentele liniei de comandă."""
    p = argparse.ArgumentParser(description="Inode Hard Link Finder")
    p.add_argument("--root", type=Path, default=Path("."), help="Director rădăcină")
    p.add_argument("--max", type=int, default=DEFAULT_MAX_GROUPS, help="Max grupuri")
    return p.parse_args()


# ═══════════════════════════════════════════════════════════════════════════════
# SCANARE
# ═══════════════════════════════════════════════════════════════════════════════

def scan_for_hardlinks(root: Path) -> dict[tuple[int, int], list[Path]]:
    """Scanează directorul și grupează fișierele după inode."""
    groups: dict[tuple[int, int], list[Path]] = defaultdict(list)

    for path in root.rglob("*"):
        if not path.is_file() or path.is_symlink():
            continue
        try:
            st = path.stat()
            key = (st.st_dev, st.st_ino)
            groups[key].append(path)
        except (PermissionError, OSError):
            continue

    return groups


def filter_hardlink_groups(groups: dict) -> list[tuple]:
    """Filtrează și sortează grupurile cu mai mult de un hard link."""
    multi = [(k, v) for k, v in groups.items() if len(v) > 1]
    multi.sort(key=lambda kv: len(kv[1]), reverse=True)
    return multi


# ═══════════════════════════════════════════════════════════════════════════════
# AFIȘARE
# ═══════════════════════════════════════════════════════════════════════════════

def print_hardlink_groups(root: Path, groups: list, max_display: int) -> None:
    """Afișează grupurile de hard links."""
    print(f"=== inode groups (hard links) under {root} ===")

    if not groups:
        print("Nu am găsit grupuri cu hard links.")
        return

    for i, ((dev, ino), paths) in enumerate(groups):
        if i >= max_display:
            print(f"... și încă {len(groups) - max_display} grupuri")
            break
        print(f"- dev={dev} ino={ino} count={len(paths)}")
        for p in paths:
            print(f"    {p}")


# ═══════════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════════

def main() -> int:
    """Punct de intrare principal."""
    args = parse_args()
    groups = scan_for_hardlinks(args.root)
    hardlink_groups = filter_hardlink_groups(groups)
    print_hardlink_groups(args.root, hardlink_groups, args.max)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
