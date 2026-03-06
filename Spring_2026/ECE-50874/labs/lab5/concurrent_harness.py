"""
Lab 5 — Model-Based Testing (Concurrent Extension)

This harness generates schedules (interleavings) using k-bounded BFS over the
product state space of the components.

Students implement:
  - bfs_concurrent(system, k)

Run:
  python concurrent_harness.py -k 3
"""

from dataclasses import dataclass
from typing import List, Set, Tuple

from concurrent_model import ConcurrentSystem, SYSTEM


@dataclass(frozen=True)
class Step:
    """One scheduled step: choose a component index and one of its enabled events."""
    component: int
    event: str


@dataclass(frozen=True)
class GlobalState:
    """Product state: one local state per component (same order as system.components)."""
    states: Tuple[str, ...]


@dataclass(frozen=True)
class SearchNode:
    """BFS frontier node for concurrent exploration."""
    state: GlobalState
    schedule: List[Step]


def bfs_concurrent(system: ConcurrentSystem, k: int) -> Tuple[List[List[Step]], Set[GlobalState]]:
    """
    k-bounded BFS over concurrent schedules.

    Return:
      schedules: all schedules of length <= k
      reached:   all global states reached within depth k

    How to expand one node:
      - Pick a component i
      - For each enabled local event on that component, apply it to produce a new GlobalState
      - Append Step(i,event) to the schedule
    """
    components = system.components
    # TODO (students): implement k-bounded BFS over product state space.
    raise NotImplementedError("TODO: implement bfs_concurrent(system, k)")


def main() -> None:
    import argparse

    parser = argparse.ArgumentParser(
        description="Lab 5: generate concurrent schedules with k-bounded BFS."
    )
    parser.add_argument("-k", type=int, default=3, help="Max schedule length (k).")
    args = parser.parse_args()

    print("=== Lab 5: Concurrent Harness ===")
    print(f"k = {args.k}")
    print(f"Components: {len(SYSTEM.components)}")

    # Raises until students implement bfs_concurrent()
    schedules, reached = bfs_concurrent(SYSTEM, args.k)

    print(f"Generated schedules: {len(schedules)}")
    print(f"Reached global states: {len(reached)}")


if __name__ == "__main__":
    main()