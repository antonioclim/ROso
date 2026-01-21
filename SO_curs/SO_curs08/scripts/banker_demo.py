#!/usr/bin/env python3
"""
Demo (Săptămâna 8): Banker's Algorithm (evitare deadlock).

Concepte:
- matrice Allocation / Max / Need;
- vector Available;
- *safe state* și secvență sigură.

Rulare:
  ./banker_demo.py
  ./banker_demo.py --example classic

Notă:
- Acesta este un exemplu didactic; în sisteme reale, modelul Banker este rar aplicat direct
  (costuri, necesitatea cunoașterii maxime), dar este extrem de util pentru raționament.
"""

from __future__ import annotations

import argparse
from dataclasses import dataclass
from typing import List, Optional

@dataclass
class BankerState:
    available: List[int]          # m resurse
    max_demand: List[List[int]]   # n procese x m
    allocation: List[List[int]]   # n procese x m

    @property
    def n(self) -> int:
        return len(self.allocation)

    @property
    def m(self) -> int:
        return len(self.available)

    def need(self) -> List[List[int]]:
        return [
            [self.max_demand[i][j] - self.allocation[i][j] for j in range(self.m)]
            for i in range(self.n)
        ]

def safe_sequence(state: BankerState) -> Optional[List[int]]:
    work = state.available[:]
    finish = [False] * state.n
    need = state.need()
    seq: List[int] = []

    while len(seq) < state.n:
        progressed = False
        for i in range(state.n):
            if finish[i]:
                continue
            if all(need[i][j] <= work[j] for j in range(state.m)):
                # poate rula până la final (în model)
                for j in range(state.m):
                    work[j] += state.allocation[i][j]
                finish[i] = True
                seq.append(i)
                progressed = True
        if not progressed:
            return None
    return seq

def classic_example() -> BankerState:
    # exemplu clasic din literatura OS
    # resurse: A, B, C
    available = [3, 3, 2]
    allocation = [
        [0, 1, 0],  # P0
        [2, 0, 0],  # P1
        [3, 0, 2],  # P2
        [2, 1, 1],  # P3
        [0, 0, 2],  # P4
    ]
    max_demand = [
        [7, 5, 3],
        [3, 2, 2],
        [9, 0, 2],
        [2, 2, 2],
        [4, 3, 3],
    ]
    return BankerState(available, max_demand, allocation)

def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser()
    p.add_argument("--example", choices=["classic"], default="classic")
    return p.parse_args()

def main() -> int:
    args = parse_args()
    state = classic_example()

    print("=== Banker's Algorithm ===")
    print(f"Available:  {state.available}")
    print("Allocation:")
    for i, row in enumerate(state.allocation):
        print(f"  P{i}: {row}")
    print("Max:")
    for i, row in enumerate(state.max_demand):
        print(f"  P{i}: {row}")
    print("Need (= Max - Allocation):")
    for i, row in enumerate(state.need()):
        print(f"  P{i}: {row}")

    seq = safe_sequence(state)
    print()
    if seq is None:
        print("Stare UNSAFE: nu există secvență sigură (în acest model).")
        return 1

    print("Stare SAFE: există secvență sigură.")
    print("Safe sequence:", " -> ".join(f"P{i}" for i in seq))
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
