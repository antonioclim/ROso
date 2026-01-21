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
- condițiile Coffman includ „circular wait”; ordonarea lock-urilor elimină circular wait.
"""

from __future__ import annotations

import argparse
import threading
import time

def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser()
    p.add_argument("--mode", choices=["deadlock", "ordered"], default="deadlock")
    return p.parse_args()

def main() -> int:
    args = parse_args()

    lock_a = threading.Lock()
    lock_b = threading.Lock()

    def t1_deadlock():
        with lock_a:
            time.sleep(0.1)
            with lock_b:
                pass

    def t2_deadlock():
        with lock_b:
            time.sleep(0.1)
            with lock_a:
                pass

    def ordered_acquire(l1: threading.Lock, l2: threading.Lock):
        # ordine globală: după id() (simplificare didactică)
        first, second = (l1, l2) if id(l1) < id(l2) else (l2, l1)
        first.acquire()
        try:
            time.sleep(0.05)
            second.acquire()
        except Exception:
            first.release()
            raise

    def ordered_release(l1: threading.Lock, l2: threading.Lock):
        l1.release()
        l2.release()

    def t1_ordered():
        ordered_acquire(lock_a, lock_b)
        try:
            time.sleep(0.1)
        finally:
            ordered_release(lock_a, lock_b)

    def t2_ordered():
        ordered_acquire(lock_b, lock_a)
        try:
            time.sleep(0.1)
        finally:
            ordered_release(lock_b, lock_a)

    if args.mode == "deadlock":
        t1 = threading.Thread(target=t1_deadlock, daemon=True)
        t2 = threading.Thread(target=t2_deadlock, daemon=True)
    else:
        t1 = threading.Thread(target=t1_ordered, daemon=True)
        t2 = threading.Thread(target=t2_ordered, daemon=True)

    t1.start()
    t2.start()

    t1.join(timeout=1.0)
    t2.join(timeout=1.0)

    print(f"=== Mode: {args.mode} ===")
    print(f"t1 alive? {t1.is_alive()}")
    print(f"t2 alive? {t2.is_alive()}")

    if t1.is_alive() or t2.is_alive():
        print("Interpretare: threads nu au terminat în timeout; deadlock (sau blocare) este probabil.")
        return 1

    print("OK: am terminat (deadlock evitat / nu s-a manifestat).")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
