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
import os
import resource
import time
from pathlib import Path

# ═══════════════════════════════════════════════════════════════════════════════
# CONSTANTE
# ═══════════════════════════════════════════════════════════════════════════════

PAGE_SIZE = 4096
TOUCH_INTERVAL = PAGE_SIZE * 64  # Touch every 64 pages


# ═══════════════════════════════════════════════════════════════════════════════
# CONFIGURARE
# ═══════════════════════════════════════════════════════════════════════════════

def parse_args() -> argparse.Namespace:
    """Parsează argumentele liniei de comandă."""
    p = argparse.ArgumentParser(description="RSS Memory Probe")
    p.add_argument("--mb", type=int, default=200, help="Total MB alocați")
    p.add_argument("--step", type=int, default=20, help="Pas MB")
    p.add_argument("--sleep", type=float, default=0.2, help="Pauză între pași")
    return p.parse_args()


# ═══════════════════════════════════════════════════════════════════════════════
# CITIRE MEMORIE
# ═══════════════════════════════════════════════════════════════════════════════

def vmrss_kb() -> int | None:
    """Citește VmRSS din /proc/self/status."""
    try:
        txt = Path("/proc/self/status").read_text(encoding="utf-8", errors="replace")
        for line in txt.splitlines():
            if line.startswith("VmRSS:"):
                return int(line.split()[1])
    except (OSError, ValueError):
        pass
    return None


def get_memory_stats() -> tuple[int | None, int, int]:
    """Returnează (VmRSS_kb, minflt, majflt)."""
    r = resource.getrusage(resource.RUSAGE_SELF)
    return vmrss_kb(), r.ru_minflt, r.ru_majflt


# ═══════════════════════════════════════════════════════════════════════════════
# ALOCARE MEMORIE
# ═══════════════════════════════════════════════════════════════════════════════

def allocate_and_touch(blocks: list[bytearray], step_mb: int) -> None:
    """Alocă step_mb și touch-ează paginile pentru a le face rezidente."""
    block = bytearray(step_mb * 1024 * 1024)
    for i in range(0, len(block), TOUCH_INTERVAL):
        block[i] = (block[i] + 1) % 256
    blocks.append(block)


# ═══════════════════════════════════════════════════════════════════════════════
# AFIȘARE
# ═══════════════════════════════════════════════════════════════════════════════

def print_header(args: argparse.Namespace) -> None:
    """Afișează header-ul cu parametrii."""
    print("=== RSS probe ===")
    print(f"target={args.mb}MB, step={args.step}MB, sleep={args.sleep}s")
    print(f"pid={os.getpid()}")
    print()


def print_status(allocated_mb: int, rss: int | None, minflt: int, majflt: int) -> None:
    """Afișează statusul curent."""
    rss_display = rss if rss is not None else -1
    print(
        f"allocated≈{allocated_mb:4d}MB | "
        f"VmRSS={rss_display:8d} kB | "
        f"minflt={minflt:8d} | majflt={majflt:6d}"
    )


def print_observations() -> None:
    """Afișează observațiile didactice finale."""
    print()
    print("Observații didactice:")
    print("- ru_minflt/ru_majflt sunt contori de page faults pentru proces.")
    print("- creșterea RSS apare când paginile sunt touch-uite și devin rezidente.")


# ═══════════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════════

def main() -> int:
    """Punct de intrare principal."""
    args = parse_args()
    blocks: list[bytearray] = []

    print_header(args)

    for allocated in range(0, args.mb + 1, args.step):
        if allocated > 0:
            allocate_and_touch(blocks, args.step)

        rss, minflt, majflt = get_memory_stats()
        print_status(allocated, rss, minflt, majflt)
        time.sleep(args.sleep)

    print_observations()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())