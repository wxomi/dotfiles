#!/usr/bin/env python3
"""Animated walking pet strip for the wxomi.pets Herdr plugin."""

from __future__ import print_function

import json
import os
import shutil
import signal
import subprocess
import sys
import time

# Side-view walk cycle (3-line sprite).
WALK_FRAMES = [
    [
        r"  /\_/\  ",
        r"__( o.o) ",
        r"  > ^ <  ",
    ],
    [
        r"  /\_/\  ",
        r" ( o.o )_",
        r"  > ^ <  ",
    ],
    [
        r"  /\_/\  ",
        r"_( o.o ) ",
        r"  > ^ <  ",
    ],
    [
        r"  /\_/\  ",
        r" ( o.o)_ ",
        r"  > ^ <  ",
    ],
]

SIT_FRAME = [
    r"  /\_/\  ",
    r" ( -.- ) ",
    r"  (   )  ",
]

BLOCKED_FRAME = [
    r"  /\_/\  ",
    r" ( o_o ) ",
    r"  >~<    ",
]

HAPPY_FRAMES = [
    [
        r"  /\_/\  ",
        r" ( ^.^ ) ",
        r"  > ^ <  ",
    ],
    [
        r"  /\_/\  ",
        r" ( ^.• ) ",
        r"  > ^ <  ",
    ],
]

STATUS_LABELS = {
    "idle": "idle",
    "working": "working",
    "blocked": "blocked",
    "done": "done",
    "unknown": "…",
}


def _hide_cursor():
    """Hide the terminal cursor."""
    sys.stdout.write("\033[?25l")
    sys.stdout.flush()


def _show_cursor():
    """Show the terminal cursor."""
    sys.stdout.write("\033[?25h")
    sys.stdout.flush()


def _clear():
    """Clear the screen and move home."""
    sys.stdout.write("\033[2J\033[H")
    sys.stdout.flush()


def _term_width():
    """Return usable terminal width."""
    try:
        return max(20, shutil.get_terminal_size((80, 6)).columns)
    except Exception:
        return 80


def _herdr_bin():
    """Return the Herdr binary path from the plugin environment."""
    return os.environ.get("HERDR_BIN_PATH") or "herdr"


def _agent_status():
    """Return a light summary of agent state via the Herdr CLI.

    Prefers the focused agent; otherwise picks the busiest status among
    known agents. Returns (status, label) where status is one of the
    Herdr agent states or 'idle' when unavailable.
    """
    herdr = _herdr_bin()
    try:
        proc = subprocess.run(
            [herdr, "agent", "list"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            universal_newlines=True,
            timeout=1.5,
        )
    except (OSError, subprocess.TimeoutExpired):
        return "idle", "no agents"

    if proc.returncode != 0 or not proc.stdout.strip():
        return "idle", "no agents"

    try:
        payload = json.loads(proc.stdout)
    except ValueError:
        return "idle", "no agents"

    agents = []
    if isinstance(payload, dict):
        result = payload.get("result") or payload
        if isinstance(result, dict):
            agents = result.get("agents") or []

    if not agents:
        return "idle", "no agents"

    focused = None
    for agent in agents:
        if agent.get("focused"):
            focused = agent
            break

    chosen = focused or agents[0]
    status = chosen.get("agent_status") or "unknown"
    name = chosen.get("agent") or "agent"
    label = "%s · %s" % (name, STATUS_LABELS.get(status, status))
    return status, label


def _sprite_for(status, frame_i):
    """Pick a sprite frame for the current agent status."""
    if status == "blocked":
        return BLOCKED_FRAME
    if status == "done":
        return HAPPY_FRAMES[frame_i % len(HAPPY_FRAMES)]
    if status == "idle":
        # Gentle sit every few walk frames.
        if (frame_i // 4) % 5 == 4:
            return SIT_FRAME
        return WALK_FRAMES[frame_i % len(WALK_FRAMES)]
    # working / unknown: keep walking
    return WALK_FRAMES[frame_i % len(WALK_FRAMES)]


def _pad_line(text, width):
    """Truncate or pad a line to exactly width columns."""
    if len(text) > width:
        return text[:width]
    return text + (" " * (width - len(text)))


def _draw(x, sprite, status_label, width):
    """Draw the pet strip into the terminal."""
    sprite_w = max(len(line) for line in sprite)
    x = max(0, min(x, max(0, width - sprite_w)))

    lines = []
    title = " ✧ herdr pets "
    meta = " %s · q/esc quit " % status_label
    header = _pad_line(title + ("─" * max(0, width - len(title) - len(meta))) + meta, width)
    lines.append(header)
    lines.append(_pad_line("", width))

    for row in sprite:
        left = " " * x
        lines.append(_pad_line(left + row, width))

    while len(lines) < 5:
        lines.append(_pad_line("", width))

    sys.stdout.write("\033[H")
    sys.stdout.write("\n".join(lines[:5]))
    sys.stdout.write("\033[J")
    sys.stdout.flush()


def _speed_for(status):
    """Return (step, delay) for the animation tempo."""
    if status == "working":
        return 2, 0.08
    if status == "blocked":
        return 0, 0.25
    if status == "done":
        return 1, 0.12
    return 1, 0.16


def main():
    """Run the walking pet animation until quit."""
    running = {"ok": True}

    def _stop(_signum=None, _frame=None):
        running["ok"] = False

    signal.signal(signal.SIGINT, _stop)
    signal.signal(signal.SIGTERM, _stop)

    # Non-blocking single-char quit when stdin is a TTY.
    fd = None
    old_termios = None
    try:
        import select
        import termios
        import tty

        if sys.stdin.isatty():
            fd = sys.stdin.fileno()
            old_termios = termios.tcgetattr(fd)
            tty.setcbreak(fd)
    except Exception:
        select = None
        fd = None

    _hide_cursor()
    _clear()

    x = 0
    direction = 1
    frame_i = 0
    status = "idle"
    status_label = "idle"
    last_poll = 0.0

    try:
        while running["ok"]:
            now = time.time()
            if now - last_poll > 1.0:
                status, status_label = _agent_status()
                last_poll = now

            width = _term_width()
            sprite = _sprite_for(status, frame_i)
            sprite_w = max(len(line) for line in sprite)
            step, delay = _speed_for(status)

            _draw(x, sprite, status_label, width)

            if step:
                x += direction * step
                if x + sprite_w >= width:
                    direction = -1
                    x = max(0, width - sprite_w)
                elif x <= 0:
                    direction = 1
                    x = 0

            frame_i += 1

            if fd is not None and select is not None:
                ready, _, _ = select.select([sys.stdin], [], [], delay)
                if ready:
                    ch = sys.stdin.read(1)
                    if ch in ("q", "Q", "\x1b"):
                        break
            else:
                time.sleep(delay)
    finally:
        if fd is not None and old_termios is not None:
            try:
                import termios

                termios.tcsetattr(fd, termios.TCSADRAIN, old_termios)
            except Exception:
                pass
        _show_cursor()
        _clear()


if __name__ == "__main__":
    main()
