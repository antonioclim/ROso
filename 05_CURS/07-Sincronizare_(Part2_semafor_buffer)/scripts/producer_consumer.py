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
from typing import Optional

# ═══════════════════════════════════════════════════════════════════════════════
# CONSTANTE
# ═══════════════════════════════════════════════════════════════════════════════

PRODUCE_DELAY_MIN = 0.01
PRODUCE_DELAY_MAX = 0.05
CONSUME_DELAY_MIN = 0.02
CONSUME_DELAY_MAX = 0.06


# ═══════════════════════════════════════════════════════════════════════════════
# CONFIGURARE
# ═══════════════════════════════════════════════════════════════════════════════

def parse_args() -> argparse.Namespace:
    """Parsează argumentele liniei de comandă."""
    p = argparse.ArgumentParser(description="Producer-Consumer Demo")
    p.add_argument("--producers", type=int, default=2, help="Număr producători")
    p.add_argument("--consumers", type=int, default=2, help="Număr consumatori")
    p.add_argument("--items", type=int, default=20, help="Număr total itemi")
    p.add_argument("--buf", type=int, default=5, help="Dimensiune buffer")
    return p.parse_args()


# ═══════════════════════════════════════════════════════════════════════════════
# COUNTER THREAD-SAFE
# ═══════════════════════════════════════════════════════════════════════════════

class ThreadSafeCounter:
    """Counter thread-safe pentru coordonarea producției."""

    def __init__(self, max_value: int) -> None:
        self._value = 0
        self._max = max_value
        self._lock = threading.Lock()

    def try_increment(self) -> Optional[int]:
        """Încearcă să incrementeze. Returnează valoarea sau None."""
        with self._lock:
            if self._value >= self._max:
                return None
            self._value += 1
            return self._value


# ═══════════════════════════════════════════════════════════════════════════════
# WORKERS
# ═══════════════════════════════════════════════════════════════════════════════

def producer_worker(pid: int, queue: Queue, counter: ThreadSafeCounter) -> None:
    """Thread producător: produce itemi până la limită."""
    while True:
        item = counter.try_increment()
        if item is None:
            break
        time.sleep(random.uniform(PRODUCE_DELAY_MIN, PRODUCE_DELAY_MAX))
        queue.put(item)
        print(f"[P{pid}] produced {item}")


def consumer_worker(cid: int, queue: Queue) -> None:
    """Thread consumator: consumă itemi până primește None."""
    while True:
        item = queue.get()
        if item is None:
            queue.task_done()
            break
        time.sleep(random.uniform(CONSUME_DELAY_MIN, CONSUME_DELAY_MAX))
        print(f"    [C{cid}] consumed {item}")
        queue.task_done()


# ═══════════════════════════════════════════════════════════════════════════════
# ORCHESTRARE
# ═══════════════════════════════════════════════════════════════════════════════

def create_threads(args: argparse.Namespace, queue: Queue, counter: ThreadSafeCounter) -> tuple:
    """Creează thread-urile producător și consumator."""
    producers = [
        threading.Thread(target=producer_worker, args=(i, queue, counter), daemon=True)
        for i in range(1, args.producers + 1)
    ]
    consumers = [
        threading.Thread(target=consumer_worker, args=(i, queue), daemon=True)
        for i in range(1, args.consumers + 1)
    ]
    return producers, consumers


def start_all_threads(producers: list, consumers: list) -> None:
    """Pornește toate thread-urile."""
    for t in consumers + producers:
        t.start()


def wait_for_completion(producers: list, consumers: list, queue: Queue) -> None:
    """Așteaptă terminarea și trimite poison pills."""
    for t in producers:
        t.join()

    for _ in consumers:
        queue.put(None)

    queue.join()
    for t in consumers:
        t.join()


# ═══════════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════════

def main() -> int:
    """Punct de intrare principal."""
    args = parse_args()
    queue: Queue[Optional[int]] = Queue(maxsize=args.buf)
    counter = ThreadSafeCounter(args.items)

    producers, consumers = create_threads(args, queue, counter)
    start_all_threads(producers, consumers)
    wait_for_completion(producers, consumers, queue)

    print("OK: done.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
