"""
Concurrent-ish implementation under test (IUT).

INTENTIONALLY BUGGY:
  ctrl_step turns ON when conditions hold,
  but does NOT reliably force NOT_COOKING when conditions are false.
"""

from dataclasses import dataclass
from typing import List, Tuple


@dataclass
class MicrowaveImpl:
    door: str = "CLOSED"
    timer: str = "IDLE"
    ctrl: str = "NOT_COOKING"
    log: List[str] = None

    def __post_init__(self) -> None:
        if self.log is None:
            self.log = []
        self._log(f"init ({self.door}, {self.timer}, {self.ctrl})")

    def _log(self, msg: str) -> None:
        self.log.append(msg)

    def state(self) -> Tuple[str, str, str]:
        """Return the full observed state (door,timer,ctrl)."""
        return (self.door, self.timer, self.ctrl)

    def apply(self, component: str, event: str) -> None:
        """Apply one (component,event) step."""
        if component == "door":
            self._door(event)
        elif component == "timer":
            self._timer(event)
        elif component == "ctrl":
            self._ctrl(event)
        else:
            raise ValueError(f"Unknown component: {component}")

    def _door(self, event: str) -> None:
        if event == "open_door" and self.door == "CLOSED":
            self.door = "OPEN"
            self._log("door: CLOSED->OPEN")
            return
        if event == "close_door" and self.door == "OPEN":
            self.door = "CLOSED"
            self._log("door: OPEN->CLOSED")
            return
        raise ValueError(f"door invalid {event} from {self.door}")

    def _timer(self, event: str) -> None:
        if event == "start_timer" and self.timer == "IDLE":
            self.timer = "RUNNING"
            self._log("timer: IDLE->RUNNING")
            return
        if event == "stop_timer" and self.timer == "RUNNING":
            self.timer = "IDLE"
            self._log("timer: RUNNING->IDLE")
            return
        if event == "tick" and self.timer == "RUNNING":
            self._log("timer: tick")
            return
        raise ValueError(f"timer invalid {event} from {self.timer}")

    def _ctrl(self, event: str) -> None:
        if event != "ctrl_step":
            raise ValueError(f"ctrl invalid event {event}")

        # BUG: can turn ON, but does not force OFF when conditions are false.
        if self.door == "CLOSED" and self.timer == "RUNNING":
            self.ctrl = "COOKING"
            self._log("ctrl_step: -> COOKING")
        else:
            # should set NOT_COOKING
            self._log("ctrl_step: (BUG) did not force NOT_COOKING")