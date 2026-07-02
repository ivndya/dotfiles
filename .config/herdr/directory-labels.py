#!/usr/bin/python3
"""Refresh Herdr sidebar directory tokens; empty output keeps the status area hidden."""

import json
import os
from pathlib import PurePosixPath
import socket
import sys


def main():
    # Status commands run in the server, with active-pane context instead of HERDR_ENV.
    if os.environ.get("HERDR_ENV") != "1" and not os.environ.get("HERDR_ACTIVE_PANE_ID"):
        return
    socket_path = os.environ.get("HERDR_SOCKET_PATH")
    if not socket_path:
        return

    def request(method, params):
        with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as client:
            client.settimeout(1)
            client.connect(socket_path)
            with client.makefile("r", encoding="utf-8") as replies:
                payload = {"id": "user:directory-labels", "method": method, "params": params}
                client.sendall((json.dumps(payload) + "\n").encode("utf-8"))
                reply = json.loads(replies.readline())
                if "error" in reply:
                    raise RuntimeError(json.dumps(reply["error"]))
                return reply["result"]

    snapshot = request("session.snapshot", {})["snapshot"]
    for pane in snapshot["panes"]:
        cwd = pane.get("foreground_cwd") or pane.get("cwd")
        if not cwd:
            continue
        directory = PurePosixPath(cwd).name or "/"
        directory = "".join(c for c in directory if ord(c) >= 32 and ord(c) != 127).strip()[:80]
        if pane.get("tokens", {}).get("directory") == directory:
            continue
        request("pane.report_metadata", {
            "pane_id": pane["pane_id"],
            "source": "user:directory-labels",
            "tokens": {"directory": directory},
        })


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, KeyError, RuntimeError) as error:
        print("Herdr directory labels: " + str(error), file=sys.stderr)
        sys.exit(1)
