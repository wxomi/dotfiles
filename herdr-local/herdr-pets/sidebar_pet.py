#!/usr/bin/env python3
"""Animate an ASCII pet in the Herdr agents sidebar via $pet metadata."""

from __future__ import print_function

import json
import os
import signal
import subprocess
import sys
import time

SOURCE = "wxomi.pets"
TOKEN = "pet"
TTL_MS = 2500
INTERVAL = 0.22

# Compact walk cycle for a narrow agents panel (~14 cols).
WALK_RIGHT = [
    r"  /\_/\   ",
    r" ( o.o )  ",
    r"  > ^ <   ",
    r"   /\_/\  ",
    r"  ( o.o ) ",
    r"   > ^ <  ",
    r"    /\_/\ ",
    r"   ( o.o )",
    r"    > ^ < ",
    r"     /\_/\ ",
    r"    ( -.- )",
    r"     > ^ < ",
]

# Simpler one-line bounce (more reliable in narrow UI).
WALK = [
    "🐈········",
    "·🐈·······",
    "··🐈······",
    "···🐈·····",
    "····🐈····",
    "·····🐈···",
    "······🐈··",
    "·······🐈·",
    "········🐈",
    "·······🐈·",
    "······🐈··",
    "·····🐈···",
    "····🐈····",
    "···🐈·····",
    "··🐈······",
    "·🐈·······",
]

POSES = {
    "blocked": "🙀 blocked",
    "done": "😺 done!",
    "idle": "🐈 zzz",
}


def _herdr():
    """Return Herdr binary path."""
    return os.environ.get("HERDR_BIN_PATH") or "herdr"


def _run_json(args, timeout=2.0):
    """Run herdr and parse JSON stdout; return None on failure."""
    try:
        proc = subprocess.run(
            [_herdr()] + args,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            universal_newlines=True,
            timeout=timeout,
        )
    except (OSError, subprocess.TimeoutExpired):
        return None
    if proc.returncode != 0 or not proc.stdout.strip():
        return None
    try:
        return json.loads(proc.stdout)
    except ValueError:
        return None


def _agent_panes():
    """Return list of (pane_id, status) for panes with a detected agent."""
    payload = _run_json(["pane", "list"])
    if not payload:
        return []
    panes = ((payload.get("result") or {}).get("panes") or [])
    out = []
    for pane in panes:
        agent = pane.get("agent")
        pane_id = pane.get("pane_id")
        if not agent or not pane_id:
            continue
        label = pane.get("label") or ""
        cwd = pane.get("cwd") or ""
        if "Pets" in label or "herdr-pets" in cwd:
            continue
        status = pane.get("agent_status") or "unknown"
        out.append((pane_id, status))
    return out


def _frame_for(status, tick):
    """Pick a one-line pet frame for status + animation tick."""
    if status == "blocked":
        return POSES["blocked"]
    if status == "done":
        return POSES["done"]
    if status == "idle" and (tick // 8) % 5 == 4:
        return POSES["idle"]
    return WALK[tick % len(WALK)]


def _report(pane_id, value):
    """Push $pet metadata for one pane."""
    subprocess.run(
        [
            _herdr(),
            "pane",
            "report-metadata",
            pane_id,
            "--source",
            SOURCE,
            "--token",
            "%s=%s" % (TOKEN, value),
            "--ttl-ms",
            str(TTL_MS),
        ],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        timeout=2.0,
    )


def _pidfile():
    """Return path for the daemon pidfile."""
    state = os.environ.get("HERDR_PLUGIN_STATE_DIR") or os.path.join(
        os.path.expanduser("~/.config/herdr/plugins/state/wxomi.pets")
    )
    os.makedirs(state, exist_ok=True)
    return os.path.join(state, "sidebar_pet.pid")


def _write_pid():
    """Record this process id."""
    with open(_pidfile(), "w") as handle:
        handle.write(str(os.getpid()))


def stop_daemon():
    """Stop a previously started sidebar pet daemon."""
    path = _pidfile()
    if not os.path.isfile(path):
        print("sidebar pet: not running")
        return 0
    try:
        with open(path) as handle:
            pid = int(handle.read().strip())
    except (OSError, ValueError):
        pid = None
    if pid:
        try:
            os.kill(pid, signal.SIGTERM)
        except OSError:
            pass
    try:
        os.remove(path)
    except OSError:
        pass
    # Clear $pet tokens so the row goes blank.
    for pane_id, _status in _agent_panes():
        subprocess.run(
            [
                _herdr(),
                "pane",
                "report-metadata",
                pane_id,
                "--source",
                SOURCE,
                "--clear-token",
                TOKEN,
            ],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
    print("sidebar pet: stopped")
    return 0


def run_loop():
    """Animate $pet on agent panes until signaled."""
    running = {"ok": True}

    def _stop(_signum=None, _frame=None):
        running["ok"] = False

    signal.signal(signal.SIGINT, _stop)
    signal.signal(signal.SIGTERM, _stop)
    _write_pid()
    tick = 0
    while running["ok"]:
        panes = _agent_panes()
        if not panes:
            cur = _run_json(["pane", "current"])
            pane = ((cur or {}).get("result") or {}).get("pane") or {}
            if pane.get("pane_id"):
                panes = [
                    (pane["pane_id"], pane.get("agent_status") or "idle")
                ]
        for pane_id, status in panes:
            _report(pane_id, _frame_for(status, tick))
        tick += 1
        time.sleep(INTERVAL)
    try:
        os.remove(_pidfile())
    except OSError:
        pass


def start_daemon():
    """Double-fork a background animator and exit."""
    stop_daemon()
    if os.fork() > 0:
        time.sleep(0.15)
        print("sidebar pet: started")
        return 0
    os.setsid()
    if os.fork() > 0:
        os._exit(0)
    os.chdir("/")
    devnull = os.open("/dev/null", os.O_RDWR)
    os.dup2(devnull, 0)
    os.dup2(devnull, 1)
    os.dup2(devnull, 2)
    run_loop()
    os._exit(0)


def main(argv):
    """CLI: start | stop | run | status."""
    cmd = (argv[1] if len(argv) > 1 else "start").lower()
    if cmd in ("stop", "quit"):
        return stop_daemon()
    if cmd == "run":
        run_loop()
        return 0
    if cmd == "status":
        path = _pidfile()
        if os.path.isfile(path):
            print("running pid", open(path).read().strip())
            return 0
        print("stopped")
        return 1
    if cmd == "start":
        return start_daemon()
    sys.stderr.write("usage: sidebar_pet.py [start|stop|run|status]\n")
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv) or 0)
