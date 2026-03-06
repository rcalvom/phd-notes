from dataclasses import dataclass
from typing import Dict, Iterable, List, Set, Tuple

State = str
Event = str


@dataclass(frozen=True)
class DFA:
    """
    Deterministic Finite Automaton (DFA) used as a *test oracle*.

    - states: set of all states
    - alphabet: set of all events
    - delta: transition function, as a dict mapping (state,event) -> next_state
    - initial: initial state
    """
    states: Set[State]
    alphabet: Set[Event]
    delta: Dict[Tuple[State, Event], State]
    initial: State

    def enabled_events(self, state: State) -> List[Event]:
        """Return the events enabled from `state` (i.e., those with defined transitions)."""
        return sorted([a for a in self.alphabet if (state, a) in self.delta])

    def step(self, state: State, event: Event) -> State:
        """Take one DFA step (state,event) -> next_state, or raise if invalid."""
        key = (state, event)
        if key not in self.delta:
            raise ValueError(f"Invalid event '{event}' from state '{state}'")
        return self.delta[key]

    def run(self, events: Iterable[Event]) -> State:
        """Run a whole sequence of events starting at the initial state."""
        s = self.initial
        for e in events:
            s = self.step(s, e)
        return s