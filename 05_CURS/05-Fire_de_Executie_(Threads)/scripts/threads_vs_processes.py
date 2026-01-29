#!/usr/bin/env python3
"""
Demo (Săptămâna 5): Threads vs Processes în Python (în contextul SO).

Obiective:
- să distingem concurența (interleaving) de paralelism (execuție simultană);
- să observăm impactul GIL pentru workload CPU-bound;
- să comparăm cu multiprocessing (procese).

Rulare:
  ./threads_vs_processes.py --workers 4 --n 20000
"""

from __future__ import annotations

import argparse
import time
from concurrent.futures import ThreadPoolExecutor, ProcessPoolExecutor

def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser()
    p.add_argument("--workers", type=int, default=4)
    p.add_argument("--n", type=int, default=20000, help="Dimensiune workload (prime test).")
    return p.parse_args()

def is_prime(n: int) -> bool:
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    d = 3
    while d * d <= n:
        if n % d == 0:
            return False
        d += 2
    return True

def work(seed: int, n: int) -> int:
    # numără prime într-un interval determinist (CPU-bound)
    start = seed * n
    end = start + n
    c = 0
    for x in range(start, end):
        if is_prime(x):
            c += 1
    return c

def bench(executor_cls, workers: int, n: int) -> tuple[float, int]:
    t0 = time.perf_counter()
    with executor_cls(max_workers=workers) as ex:
        futures = [ex.submit(work, i, n) for i in range(workers)]
        total = sum(f.result() for f in futures)
    t1 = time.perf_counter()
    return t1 - t0, total

def main() -> int:
    args = parse_args()

    print("=== Threads vs Processes (CPU-bound) ===")
    print(f"workers={args.workers}, n={args.n}")
    print()

    dt_threads, primes_threads = bench(ThreadPoolExecutor, args.workers, args.n)
    print(f"Threads:   time={dt_threads:.3f}s, primes_total={primes_threads}")

    dt_procs, primes_procs = bench(ProcessPoolExecutor, args.workers, args.n)
    print(f"Processes: time={dt_procs:.3f}s, primes_total={primes_procs}")

    print()
    print("Observații didactice:")
    print("- Pentru workload CPU-bound, threads Python pot să nu scaleze liniar din cauza GIL.")
    print("- Procesele pot rula în paralel pe core-uri diferite, dar au overhead mai mare (IPC, fork/spawn).")
    print("- În OS, ideea cheie: threads împart adres space; procesele sunt izolate (mai sigur, mai costisitor).")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
