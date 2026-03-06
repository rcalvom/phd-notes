"""
Model for the *single-DFA* part of Lab 5.

This file defines MODEL: a DFA that represents the intended correct behavior.
"""

from typing import Dict, List, Set, Tuple

from dfa import DFA, Event, State

# --- States and Events (Alphabet) ---

STATES: Set[State] = {"DISCONNECTED", "CONNECTED", "AUTHED"}

ALPHABET: Set[Event] = {"connect", "disconnect", "auth", "ping", "logout", "timeout"}

# --- Transition function delta: (state,event) -> next_state ---

DELTA: Dict[Tuple[State, Event], State] = {
    ("DISCONNECTED", "connect"): "CONNECTED",
    ("CONNECTED", "disconnect"): "DISCONNECTED",
    ("CONNECTED", "auth"): "AUTHED",
    ("AUTHED", "ping"): "AUTHED",
    ("AUTHED", "logout"): "CONNECTED",
    ("AUTHED", "timeout"): "DISCONNECTED",
}

MODEL = DFA(states=STATES, alphabet=ALPHABET, delta=DELTA, initial="DISCONNECTED")


# Convenience wrappers (nice for students to read in traces/debugging)

def enabled_events(state: State) -> List[Event]:
    return MODEL.enabled_events(state)

def step(state: State, event: Event) -> State:
    return MODEL.step(state, event)

def run(events: List[Event]) -> State:
    return MODEL.run(events)