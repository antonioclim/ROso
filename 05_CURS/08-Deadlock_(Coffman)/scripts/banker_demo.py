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
from typing import Optional


# ═══════════════════════════════════════════════════════════════════════════════
# STRUCTURI DATE
# ═══════════════════════════════════════════════════════════════════════════════

@dataclass
class BankerState:
    """Starea sistemului pentru algoritmul bancherului."""
    available: list[int]          # m resurse
    max_demand: list[list[int]]   # n procese x m
    allocation: list[list[int]]   # n procese x m

    @property
    def n(self) -> int:
        """Numărul de procese."""
        return len(self.allocation)

    @property
    def m(self) -> int:
        """Numărul de tipuri de resurse."""
        return len(self.available)

    def need(self) -> list[list[int]]:
        """Calculează matricea Need = Max - Allocation."""
        return [
            [self.max_demand[i][j] - self.allocation[i][j] for j in range(self.m)]
            for i in range(self.n)
        ]


# ═══════════════════════════════════════════════════════════════════════════════
# ALGORITM
# ═══════════════════════════════════════════════════════════════════════════════

def can_finish(need_row: list[int], work: list[int]) -> bool:
    """Verifică dacă un proces poate termina cu resursele disponibile."""
    return all(need_row[j] <= work[j] for j in range(len(work)))


def safe_sequence(state: BankerState) -> Optional[list[int]]:
    """Găsește o secvență sigură sau returnează None dacă starea e unsafe."""
    work = state.available[:]
    finish = [False] * state.n
    need = state.need()
    seq: list[int] = []

    while len(seq) < state.n:
        progressed = False
        for i in range(state.n):
            if finish[i]:
                continue
            if can_finish(need[i], work):
                for j in range(state.m):
                    work[j] += state.allocation[i][j]
                finish[i] = True
                seq.append(i)
                progressed = True
        if not progressed:
            return None
    return seq


# ═══════════════════════════════════════════════════════════════════════════════
# EXEMPLE
# ═══════════════════════════════════════════════════════════════════════════════

def classic_example() -> BankerState:
    """Exemplu clasic din literatura OS (Silberschatz)."""
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


# ═══════════════════════════════════════════════════════════════════════════════
# CONFIGURARE
# ═══════════════════════════════════════════════════════════════════════════════

def parse_args() -> argparse.Namespace:
    """Parsează argumentele liniei de comandă."""
    p = argparse.ArgumentParser(description="Banker's Algorithm Demo")
    p.add_argument("--example", choices=["classic"], default="classic")
    return p.parse_args()


# ═══════════════════════════════════════════════════════════════════════════════
# AFIȘARE
# ═══════════════════════════════════════════════════════════════════════════════

def print_matrix(title: str, matrix: list[list[int]]) -> None:
    """Afișează o matrice cu procese."""
    print(f"{title}:")
    for i, row in enumerate(matrix):
        print(f"  P{i}: {row}")


def print_state(state: BankerState) -> None:
    """Afișează starea curentă a sistemului."""
    print("=== Banker's Algorithm ===")
    print(f"Available:  {state.available}")
    print_matrix("Allocation", state.allocation)
    print_matrix("Max", state.max_demand)
    print_matrix("Need (= Max - Allocation)", state.need())


def print_result(seq: Optional[list[int]]) -> int:
    """Afișează rezultatul și returnează exit code."""
    print()
    if seq is None:
        print("Stare UNSAFE: nu există secvență sigură (în acest model).")
        return 1

    print("Stare SAFE: există secvență sigură.")
    print("Safe sequence:", " -> ".join(f"P{i}" for i in seq))
    return 0


# ═══════════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════════

def main() -> int:
    """Punct de intrare principal."""
    parse_args()  # Pentru extensibilitate viitoare
    state = classic_example()
    print_state(state)
    seq = safe_sequence(state)
    return print_result(seq)


if __name__ == "__main__":
    raise SystemExit(main())
