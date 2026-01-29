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
from dataclasses import dataclass, field
from pathlib import Path

# ═══════════════════════════════════════════════════════════════════════════════
# CONSTANTE
# ═══════════════════════════════════════════════════════════════════════════════

DEFAULT_MAX_DISPLAY = 30


# ═══════════════════════════════════════════════════════════════════════════════
# CONFIGURARE
# ═══════════════════════════════════════════════════════════════════════════════

def parse_args() -> argparse.Namespace:
    """Parsează argumentele liniei de comandă."""
    p = argparse.ArgumentParser(description="Permission Audit Tool")
    p.add_argument("--root", type=Path, default=Path("."), help="Director rădăcină")
    p.add_argument("--max", type=int, default=DEFAULT_MAX_DISPLAY, help="Max itemi")
    return p.parse_args()


# ═══════════════════════════════════════════════════════════════════════════════
# STRUCTURI DATE
# ═══════════════════════════════════════════════════════════════════════════════

@dataclass
class AuditResults:
    """Rezultatele auditului de permisiuni."""
    ww_files: list[Path] = field(default_factory=list)
    suid_files: list[Path] = field(default_factory=list)
    sgid_files: list[Path] = field(default_factory=list)
    ww_dirs_no_sticky: list[Path] = field(default_factory=list)


# ═══════════════════════════════════════════════════════════════════════════════
# SCANARE
# ═══════════════════════════════════════════════════════════════════════════════

def check_file_permissions(path: Path, mode: int, results: AuditResults) -> None:
    """Verifică permisiunile unui fișier regular."""
    if mode & stat.S_IWOTH:
        results.ww_files.append(path)
    if mode & stat.S_ISUID:
        results.suid_files.append(path)
    if mode & stat.S_ISGID:
        results.sgid_files.append(path)


def check_dir_permissions(path: Path, mode: int, results: AuditResults) -> None:
    """Verifică permisiunile unui director."""
    if (mode & stat.S_IWOTH) and not (mode & stat.S_ISVTX):
        results.ww_dirs_no_sticky.append(path)


def scan_directory(root: Path) -> AuditResults:
    """Scanează directorul și colectează problemele de permisiuni."""
    results = AuditResults()

    for path in root.rglob("*"):
        try:
            st = path.lstat()
        except (PermissionError, FileNotFoundError):
            continue

        mode = st.st_mode
        if stat.S_ISREG(mode):
            check_file_permissions(path, mode, results)
        elif stat.S_ISDIR(mode):
            check_dir_permissions(path, mode, results)

    return results


# ═══════════════════════════════════════════════════════════════════════════════
# AFIȘARE
# ═══════════════════════════════════════════════════════════════════════════════

def show_category(title: str, items: list[Path], max_display: int) -> None:
    """Afișează o categorie de rezultate."""
    print(title)
    for path in items[:max_display]:
        print(f"  {path}")
    if len(items) > max_display:
        print(f"  ... ({len(items) - max_display} altele)")
    print()


def print_results(root: Path, results: AuditResults, max_display: int) -> None:
    """Afișează toate rezultatele auditului."""
    print(f"=== Permission audit (Python): {root} ===")
    print()
    show_category("World-writable files:", results.ww_files, max_display)
    show_category("SUID files:", results.suid_files, max_display)
    show_category("SGID files:", results.sgid_files, max_display)
    show_category("World-writable dirs fără sticky bit:", results.ww_dirs_no_sticky, max_display)


# ═══════════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════════

def main() -> int:
    """Punct de intrare principal."""
    args = parse_args()
    results = scan_directory(args.root)
    print_results(args.root, results, args.max)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
