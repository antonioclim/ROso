#!/usr/bin/env python3
"""
Demo (Săptămâna 8): deadlock cu două lock-uri și două threads (scenariu clasic).

Rulare:
  ./deadlock_two_locks.py --mode deadlock
  ./deadlock_two_locks.py --mode ordered

Moduri:
- deadlock: fiecare thread ia lock-urile în ordine inversă → deadlock posibil.
  (scriptul nu blochează la infinit: folosește timeout și raportează)
- ordered: impune o ordine globală a lock-urilor → evită deadlock.

Legătură didactică:
- condițiile Coffman includ „circular wait"; ordonarea lock-urilor elimină circular wait.
"""

from __future__ import annotations

import argparse
import threading
import time

# ═══════════════════════════════════════════════════════════════════════════════
# CONSTANTE
# ═══════════════════════════════════════════════════════════════════════════════

DEFAULT_TIMEOUT = 1.0
LOCK_HOLD_TIME = 0.1
ORDERED_HOLD_TIME = 0.05


def parse_args() -> argparse.Namespace:
    """Parsează argumentele liniei de comandă."""
    p = argparse.ArgumentParser(description="Demo deadlock cu două lock-uri")
    p.add_argument("--mode", choices=["deadlock", "ordered"], default="deadlock")
    return p.parse_args()


# ═══════════════════════════════════════════════════════════════════════════════
# STRATEGIA DEADLOCK
# ═══════════════════════════════════════════════════════════════════════════════

def worker_deadlock_a(lock_a: threading.Lock, lock_b: threading.Lock) -> None:
    """Thread A: achiziționează lock_a apoi lock_b (ordine A→B)."""
    with lock_a:
        time.sleep(LOCK_HOLD_TIME)
        with lock_b:
            pass


def worker_deadlock_b(lock_a: threading.Lock, lock_b: threading.Lock) -> None:
    """Thread B: achiziționează lock_b apoi lock_a (ordine B→A → circular wait)."""
    with lock_b:
        time.sleep(LOCK_HOLD_TIME)
        with lock_a:
            pass


# ═══════════════════════════════════════════════════════════════════════════════
# STRATEGIA ORDERED (EVITARE DEADLOCK)
# ═══════════════════════════════════════════════════════════════════════════════

def ordered_acquire(l1: threading.Lock, l2: threading.Lock) -> None:
    """Achiziționează lock-urile în ordine globală (după id)."""
    first, second = (l1, l2) if id(l1) < id(l2) else (l2, l1)
    first.acquire()
    try:
        time.sleep(ORDERED_HOLD_TIME)
        second.acquire()
    except Exception:
        first.release()
        raise


def ordered_release(l1: threading.Lock, l2: threading.Lock) -> None:
    """Eliberează ambele lock-uri."""
    l1.release()
    l2.release()


def worker_ordered_a(lock_a: threading.Lock, lock_b: threading.Lock) -> None:
    """Thread A cu ordine globală."""
    ordered_acquire(lock_a, lock_b)
    try:
        time.sleep(LOCK_HOLD_TIME)
    finally:
        ordered_release(lock_a, lock_b)


def worker_ordered_b(lock_a: threading.Lock, lock_b: threading.Lock) -> None:
    """Thread B cu ordine globală."""
    ordered_acquire(lock_b, lock_a)
    try:
        time.sleep(LOCK_HOLD_TIME)
    finally:
        ordered_release(lock_b, lock_a)


# ═══════════════════════════════════════════════════════════════════════════════
# EXECUȚIE DEMO
# ═══════════════════════════════════════════════════════════════════════════════

def create_threads(mode: str, lock_a: threading.Lock, lock_b: threading.Lock) -> tuple:
    """Creează thread-urile în funcție de modul selectat."""
    if mode == "deadlock":
        t1 = threading.Thread(target=worker_deadlock_a, args=(lock_a, lock_b), daemon=True)
        t2 = threading.Thread(target=worker_deadlock_b, args=(lock_a, lock_b), daemon=True)
    else:
        t1 = threading.Thread(target=worker_ordered_a, args=(lock_a, lock_b), daemon=True)
        t2 = threading.Thread(target=worker_ordered_b, args=(lock_a, lock_b), daemon=True)
    return t1, t2


def run_threads(t1: threading.Thread, t2: threading.Thread) -> None:
    """Pornește și așteaptă thread-urile cu timeout."""
    t1.start()
    t2.start()
    t1.join(timeout=DEFAULT_TIMEOUT)
    t2.join(timeout=DEFAULT_TIMEOUT)


def print_results(mode: str, t1: threading.Thread, t2: threading.Thread) -> int:
    """Afișează rezultatele și returnează exit code."""
    print(f"=== Mode: {mode} ===")
    print(f"t1 alive? {t1.is_alive()}")
    print(f"t2 alive? {t2.is_alive()}")

    if t1.is_alive() or t2.is_alive():
        print("Interpretare: threads nu au terminat în timeout; deadlock probabil.")
        return 1

    print("OK: am terminat (deadlock evitat / nu s-a manifestat).")
    return 0


def main() -> int:
    """Punct de intrare principal."""
    args = parse_args()
    lock_a = threading.Lock()
    lock_b = threading.Lock()

    t1, t2 = create_threads(args.mode, lock_a, lock_b)
    run_threads(t1, t2)
    return print_results(args.mode, t1, t2)


if __name__ == "__main__":
    raise SystemExit(main())
