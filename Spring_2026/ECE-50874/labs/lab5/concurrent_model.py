"""
Concurrent extension model.

We model three components:
  - door  : OPEN/CLOSED
  - timer : IDLE/RUNNING (tick only when RUNNING)
  - ctrl  : NOT_COOKING/COOKING (updated by ctrl_step)

The key idea: ctrl is governed by an *oracle law* based on door/timer.
"""

from dataclasses import dataclass
from typing import Dict, List, Set, Tuple

State = str
Event = str


@dataclass(frozen=True)
class Component:
    """A small DFA-like component for concurrent composition."""
    name: str
    states: Set[State]
    alphabet: Set[Event]
    delta: Dict[Tuple[State, Event], State]
    initial: State

    def enabled(self, s: State) -> List[Event]:
        """Enabled local events from local state s."""
        return sorted([a for a in self.alphabet if (s, a) in self.delta])

    def step(self, s: State, a: Event) -> State:
        """Local step (s,a)->s' or raise if invalid."""
        key = (s, a)
        if key not in self.delta:
            raise ValueError(f"{self.name}: invalid event '{a}' from state '{s}'")
        return self.delta[key]


@dataclass(frozen=True)
class ConcurrentSystem:
    """
    Container representing the concurrent system composed of multiple DFAs.

    components:
        The individual DFA components that run concurrently.
    """
    components: List[Component]


DOOR = Component(
    name="door",
    states={"OPEN", "CLOSED"},
    alphabet={"open_door", "close_door"},
    delta={
        ("CLOSED", "open_door"): "OPEN",
        ("OPEN", "close_door"): "CLOSED",
    },
    initial="CLOSED",
)

TIMER = Component(
    name="timer",
    states={"IDLE", "RUNNING"},
    alphabet={"start_timer", "stop_timer", "tick"},
    delta={
        ("IDLE", "start_timer"): "RUNNING",
        ("RUNNING", "stop_timer"): "IDLE",
        ("RUNNING", "tick"): "RUNNING",
    },
    initial="IDLE",
)

CTRL = Component(
    name="ctrl",
    states={"NOT_COOKING", "COOKING"},
    alphabet={"ctrl_step"},
    delta={
        ("NOT_COOKING", "ctrl_step"): "NOT_COOKING",
        ("COOKING", "ctrl_step"): "COOKING",
    },
    initial="NOT_COOKING",
)

COMPONENTS = [DOOR, TIMER, CTRL]

# ✅ define SYSTEM only AFTER COMPONENTS exists
SYSTEM = ConcurrentSystem(COMPONENTS)


def oracle_ctrl_next(door_s: State, timer_s: State, ctrl_s: State) -> State:
    """
    Oracle control law: cook iff door is CLOSED and timer is RUNNING.
    ctrl_s is unused in this oracle, but included to match the signature
    students may expect.
    """
    if door_s == "CLOSED" and timer_s == "RUNNING":
        return "COOKING"
    return "NOT_COOKING"