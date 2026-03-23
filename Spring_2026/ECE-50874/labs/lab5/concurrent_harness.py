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
from collections import deque
from typing import List, Set, Tuple

from concurrent_model import ConcurrentSystem, SYSTEM, oracle_ctrl_next
from concurrent_implementation import MicrowaveImpl


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
    initial = GlobalState(tuple(component.initial for component in system.components))
    reached = {initial}

    if k <= 0:
        return [], reached

    queue = deque([(initial, ())])
    schedule_tuples = []

    while queue:
        state, schedule = queue.popleft()
        if len(schedule) >= k:
            continue

        states = state.states
        for i, component in enumerate(system.components):
            local_state = states[i]
            for event in component.enabled(local_state):
                next_states = list(states)
                if component.name == "ctrl" and event == "ctrl_step":
                    next_states[i] = oracle_ctrl_next(states[0], states[1], local_state)
                else:
                    next_states[i] = component.step(local_state, event)

                next_state = GlobalState(tuple(next_states))
                next_schedule = schedule + (Step(i, event),)
                schedule_tuples.append(next_schedule)
                reached.add(next_state)
                queue.append((next_state, next_schedule))

    return [list(schedule) for schedule in schedule_tuples], reached


def run_schedule(system: ConcurrentSystem, schedule: List[Step]) -> GlobalState:
    """Execute one schedule on the concurrent model and return the final global state."""
    states = [component.initial for component in system.components]

    for step in schedule:
        component = system.components[step.component]
        if component.name == "ctrl" and step.event == "ctrl_step":
            states[step.component] = oracle_ctrl_next(
                states[0], states[1], states[step.component]
            )
        else:
            states[step.component] = component.step(states[step.component], step.event)

    return GlobalState(tuple(states))


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
    # for schedule in schedules:
    #     print(schedule)

    for schedule in schedules:
        final_state = run_schedule(SYSTEM, schedule)
        impl = MicrowaveImpl()
        success = True

        for step in schedule:
            component_name = SYSTEM.components[step.component].name
            try:
                impl.apply(component_name, step.event)
            except ValueError:
                success = False

        if final_state.states != impl.state():
            success = False

        if not success:
            print(
                f"Schedule: {schedule} | Model final: {final_state.states} | Impl final: {impl.state()}"
            )
            print(impl.log)


if __name__ == "__main__":
    main()
