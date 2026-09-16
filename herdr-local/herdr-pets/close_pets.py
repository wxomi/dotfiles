#!/usr/bin/env python3
"""Close any open wxomi.pets panes and dismiss a pets popup."""

from __future__ import print_function

import json
import os
import socket
import subprocess
import sys


def _herdr():
    """Return Herdr binary path."""
    return os.environ.get("HERDR_BIN_PATH") or "herdr"


def _close_popup():
    """Best-effort popup.close over the Herdr socket."""
    path = os.path.expanduser("~/.config/herdr/herdr.sock")
    try:
        sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        sock.settimeout(1.0)
        sock.connect(path)
        sock.sendall(b'{"id":"1","method":"popup.close","params":{}}\n')
        sock.recv(200)
        sock.close()
    except Exception:
        pass


def main():
    """Close pets panes and popup."""
    _close_popup()
    try:
        proc = subprocess.run(
            [_herdr(), "pane", "list"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            universal_newlines=True,
            timeout=3.0,
        )
    except (OSError, subprocess.TimeoutExpired):
        print("pets: closed popup (no pane list)")
        return 0

    if proc.returncode != 0 or not proc.stdout.strip():
        print("pets: closed popup")
        return 0

    try:
        payload = json.loads(proc.stdout)
    except ValueError:
        print("pets: closed popup")
        return 0

    panes = ((payload.get("result") or {}).get("panes") or [])
    closed = 0
    for pane in panes:
        label = pane.get("label") or ""
        cwd = pane.get("cwd") or ""
        pane_id = pane.get("pane_id")
        if not pane_id:
            continue
        if "Pets" not in label and "herdr-pets" not in cwd:
            continue
        subprocess.run(
            [_herdr(), "plugin", "pane", "close", pane_id],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        closed += 1

    # Also kill any leftover renderers.
    subprocess.run(
        ["pkill", "-f", "herdr-pets/sprite_pet.py"],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    print("pets: closed %d pane(s)" % closed)
    return 0


if __name__ == "__main__":
    sys.exit(main() or 0)
