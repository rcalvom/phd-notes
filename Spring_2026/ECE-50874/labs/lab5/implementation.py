"""
Implementation Under Test (IUT) for the single-DFA part.

INTENTIONALLY BUGGY: the point of the lab is for the model-based tests to reveal
these defects.
"""

from dataclasses import dataclass
from typing import List


@dataclass
class SessionImpl:
    """
    Black-box-ish implementation under test (INTENTIONALLY BUGGY).

    State machine idea:
      DISCONNECTED --connect--> CONNECTED --auth--> AUTHED
      AUTHED --ping--> AUTHED
      AUTHED --logout--> CONNECTED
      AUTHED --timeout--> DISCONNECTED
      CONNECTED --disconnect--> DISCONNECTED

    Bugs are documented inline (so instructors can reason about expected failures).
    """

    _state: str = "DISCONNECTED"
    _ping_count: int = 0
    log: List[str] = None

    def __post_init__(self) -> None:
        if self.log is None:
            self.log = []
        self._log(f"init state={self._state}")

    @property
    def state(self) -> str:
        return self._state

    def _log(self, msg: str) -> None:
        self.log.append(msg)

    def apply(self, event: str) -> None:
        """
        Apply one event to the implementation.

        Events must match the model alphabet:
          connect, disconnect, auth, ping, logout, timeout
        """
        fn = getattr(self, f"_{event}", None)
        if fn is None:
            raise ValueError(f"Unknown event '{event}'")
        fn()

    def _connect(self) -> None:
        if self._state != "DISCONNECTED":
            raise ValueError("connect invalid unless DISCONNECTED")
        # DEFECT #1: wrong next state (should be CONNECTED)
        self._state = "AUTHED"
        self._ping_count = 0
        self._log("connect: DISCONNECTED -> AUTHED   (BUG: should be CONNECTED)")

    def _disconnect(self) -> None:
        if self._state != "CONNECTED":
            raise ValueError("disconnect invalid unless CONNECTED")
        self._state = "DISCONNECTED"
        self._log("disconnect: CONNECTED -> DISCONNECTED")

    def _auth(self) -> None:
        if self._state != "CONNECTED":
            raise ValueError("auth invalid unless CONNECTED")
        self._state = "AUTHED"
        self._ping_count = 0
        self._log("auth: CONNECTED -> AUTHED")

    def _ping(self) -> None:
        if self._state != "AUTHED":
            raise ValueError("ping invalid unless AUTHED")
        self._ping_count += 1

        # DEFECT #3: loop-sensitive: after 4 pings, it spuriously disconnects
        if self._ping_count >= 4:
            self._state = "DISCONNECTED"
            self._log("ping: AUTHED -> DISCONNECTED   (BUG: spurious timeout after 4 pings)")
        else:
            self._log(f"ping: stay AUTHED (ping_count={self._ping_count})")

    def _logout(self) -> None:
        if self._state != "AUTHED":
            raise ValueError("logout invalid unless AUTHED")
        # DEFECT #2: wrong next state (should be CONNECTED)
        self._state = "DISCONNECTED"
        self._ping_count = 0
        self._log("logout: AUTHED -> DISCONNECTED   (BUG: should be CONNECTED)")

    def _timeout(self) -> None:
        if self._state != "AUTHED":
            raise ValueError("timeout invalid unless AUTHED")
        self._state = "DISCONNECTED"
        self._ping_count = 0
        self._log("timeout: AUTHED -> DISCONNECTED")