#!/usr/bin/env python3
"""Scope the Herdr agents panel to the focused workspace."""

from __future__ import print_function

import json
import os
import socket
import sys

SOURCE = "wxomi.current-space"
LABEL = "this space"
SOCK = os.path.expanduser("~/.config/herdr/herdr.sock")


def _call(method, params):
    """Send one JSON request to the Herdr server socket."""
    req = {"id": "wxomi.current-space", "method": method, "params": params}
    sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    try:
        sock.connect(SOCK)
        sock.sendall((json.dumps(req) + "\n").encode("utf-8"))
        sock.settimeout(3.0)
        data = b""
        while True:
            chunk = sock.recv(65536)
            if not chunk:
                break
            data += chunk
            if b"\n" in data:
                break
    finally:
        sock.close()
    line = data.split(b"\n", 1)[0].decode("utf-8", "replace")
    return json.loads(line) if line else {}


def apply_filter():
    """Keep only agents whose workspace is the focused one."""
    return _call(
        "agent.view.set",
        {
            "source": SOURCE,
            "label": LABEL,
            "filter": {
                "op": "eq",
                "field": "workspace_id",
                "value": {"context": "current_workspace_id"},
            },
        },
    )


def clear_filter():
    """Remove the current-space agent filter."""
    return _call("agent.view.clear", {"source": SOURCE})


def main(argv):
    """CLI entry: default apply, or clear."""
    cmd = (argv[1] if len(argv) > 1 else "apply").lower()
    if cmd in ("clear", "off", "all"):
        result = clear_filter()
        print("agent view: cleared")
    else:
        result = apply_filter()
        print("agent view: current space only")
    if result.get("error"):
        print(json.dumps(result), file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv) or 0)
