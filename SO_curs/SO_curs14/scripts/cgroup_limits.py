#!/usr/bin/env python3
"""
Demo (Săptămâna 14): detectare limite cgroup (memorie/CPU) pentru procesul curent.

Rulare:
  ./cgroup_limits.py

Notă:
- În containere (Docker/Kubernetes), cgroups controlează resursele.
- În Linux modern, multe sisteme folosesc cgroup v2.
"""

from __future__ import annotations

from pathlib import Path

def read_first_existing(paths: list[Path]) -> str | None:
    for p in paths:
        if p.exists():
            return p.read_text(encoding="utf-8", errors="replace").strip()
    return None

def main() -> int:
    cgroup_root = Path("/sys/fs/cgroup")

    print("=== cgroup limits (best-effort) ===")

    mem_max = read_first_existing([cgroup_root / "memory.max"])
    mem_cur = read_first_existing([cgroup_root / "memory.current"])
    cpu_max = read_first_existing([cgroup_root / "cpu.max"])

    if mem_max is not None:
        print(f"memory.max:     {mem_max}")
    if mem_cur is not None:
        print(f"memory.current: {mem_cur}")
    if cpu_max is not None:
        print(f"cpu.max:        {cpu_max}  (format: quota period; 'max' = fără limită)")

    if mem_max is None and cpu_max is None:
        print("Nu par să existe fișiere cgroup v2 standard la /sys/fs/cgroup (sau acces restricționat).")

    print()
    print("Observații didactice:")
    print("- cgroups implementează *resource accounting* și *resource limiting* (memorie, CPU, I/O).")
    print("- În containere, aceste limite explică diferențe de performanță față de rularea nativă.")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
