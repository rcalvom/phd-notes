"""
Lab 5 — Model-Based Testing (Single DFA)

This harness generates test sequences from the DFA model using k-bounded BFS.

Students implement:
  - bfs_paths(dfa, k)

Run:
  python harness.py -k 4
"""

from dataclasses import dataclass
from collections import deque
from typing import Deque, List, Set, Tuple

from implementation import SessionImpl
from model import DFA, Event, State, MODEL, run


@dataclass(frozen=True)
class SearchNode:
    """
    BFS frontier node.

    state:
        DFA state reached by executing `sequence` from the initial state.
    sequence:
        The input sequence that reached `state`.
    """
    state: State
    sequence: List[Event]


def bfs_paths(dfa: DFA, k: int) -> Tuple[List[List[Event]], Set[State]]:
    """
    Generate sequences using k-bounded BFS over the DFA transition graph.

    Return:
      sequences: list of event sequences of length <= k
      reached:   set of states reached within depth k
    """
    reached = set()
    queue = deque()

    reached.add(dfa.initial)
    if k <= 0:
        return [], reached

    queue.append((dfa.initial, ()))
    seq_tuples = []

    while queue:
        state, seq = queue.popleft()
        if len(seq) >= k:
            continue

        for event in dfa.enabled_events(state):
            next_state = dfa.step(state, event)
            next_seq = seq + (event,)
            seq_tuples.append(next_seq)
            reached.add(next_state)
            queue.append((next_state, next_seq))

    return [list(seq) for seq in seq_tuples], reached


def reachable_states(dfa: DFA) -> Set[State]:
    """Unbounded reachability (provided)."""
    q: Deque[State] = deque([dfa.initial])
    visited: Set[State] = {dfa.initial}

    while q:
        s = q.popleft()
        for ev in dfa.enabled_events(s):
            s2 = dfa.step(s, ev)
            if s2 not in visited:
                visited.add(s2)
                q.append(s2)

    return visited


def main() -> None:
    import argparse

    parser = argparse.ArgumentParser(
        description="Lab 5: generate DFA test sequences with k-bounded BFS."
    )
    parser.add_argument("-k", type=int, default=4, help="Max sequence length (k).")
    args = parser.parse_args()

    print("=== Lab 5: Single-DFA Harness ===")
    print(f"k = {args.k}")
    print(f"Unbounded reachable states: {len(reachable_states(MODEL))}")

    # Raises until students implement bfs_paths()
    sequences, reached = bfs_paths(MODEL, args.k)

    print(f"k-bounded reached states: {len(reached)}")
    print(f"Generated sequences: {len(sequences)}")
    #print(f"States: {reached}")
    #print(f"Sequences: {sequences}")
    
    for sequence in sequences:
        final_state = run(sequence)
        impl = SessionImpl()
        success = True
        for event in sequence:
            try:
                impl.apply(event)
            except ValueError:
                success = False
        if final_state != impl.state:
            success = False
        if not success:
            print(f"Sequence: {sequence} | DFA final: {final_state} | Impl final: {impl.state}")
            print(impl.log)


if __name__ == "__main__":
    main()
