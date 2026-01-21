#!/usr/bin/env python3
"""
Demo (Săptămâna 7): Producer–Consumer cu `queue.Queue` (monitor-like) și semafoare.

Concepte:
- buffer finit;
- blocking (nu busy-wait);
- semantica producer/consumer folosită în I/O pipelines, servere, sisteme de logging.

Rulare:
  ./producer_consumer.py --producers 2 --consumers 3 --items 30 --buf 5
"""

from __future__ import annotations

import argparse
import random
import threading
import time
from queue import Queue

def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser()
    p.add_argument("--producers", type=int, default=2)
    p.add_argument("--consumers", type=int, default=2)
    p.add_argument("--items", type=int, default=20, help="număr total de itemi produși")
    p.add_argument("--buf", type=int, default=5, help="dimensiune buffer (Queue)")
    return p.parse_args()

def main() -> int:
    args = parse_args()
    q: Queue[int | None] = Queue(maxsize=args.buf)

    produced = 0
    produced_lock = threading.Lock()

    def producer(pid: int) -> None:
        nonlocal produced
        while True:
            with produced_lock:
                if produced >= args.items:
                    break
                produced += 1
                item = produced
            # simulăm producție variabilă
            time.sleep(random.uniform(0.01, 0.05))
            q.put(item)  # dacă bufferul e plin, producer-ul se blochează aici
            print(f"[P{pid}] produced {item}")

    def consumer(cid: int) -> None:
        while True:
            item = q.get()  # dacă bufferul e gol, consumer-ul se blochează aici
            if item is None:
                q.task_done()
                break
            # simulăm consum
            time.sleep(random.uniform(0.02, 0.06))
            print(f"    [C{cid}] consumed {item}")
            q.task_done()

    producers = [threading.Thread(target=producer, args=(i,), daemon=True) for i in range(1, args.producers + 1)]
    consumers = [threading.Thread(target=consumer, args=(i,), daemon=True) for i in range(1, args.consumers + 1)]

    for t in consumers + producers:
        t.start()

    for t in producers:
        t.join()

    # trimitem „poison pills” pentru consumatori
    for _ in consumers:
        q.put(None)

    q.join()
    for t in consumers:
        t.join()

    print("OK: done.")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
