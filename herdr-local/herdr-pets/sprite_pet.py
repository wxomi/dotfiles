#!/usr/bin/env python3
"""vscode-pets-style panel for Herdr.

Composites a themed floor + walking PNG cat, then paints the full scene as
truecolor Unicode half-blocks (Kitty graphics do not reliably pass through
Herdr panes).
"""

from __future__ import print_function

import io
import json
import os
import shutil
import signal
import subprocess
import sys
import time

ROOT = os.path.dirname(os.path.abspath(__file__))
SPRITES_DIR = os.path.join(ROOT, "sprites")
THEMES_DIR = os.path.join(ROOT, "themes")

IMG_WALK = [1, 2, 3, 4]
IMG_SIT = 10
IMG_BLOCKED = 11
IMG_HAPPY = 12

# Scene fill (matches vscode-pets dark panel).
BG = (32, 32, 36, 255)
FLOOR = (58, 48, 38, 255)
FLOOR_EDGE = (92, 78, 58, 255)

try:
    from PIL import Image
except ImportError:
    Image = None


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


def _term_size():
    """Return (columns, rows) for the current terminal."""
    try:
        size = shutil.get_terminal_size((40, 14))
        return max(16, size.columns), max(6, size.lines)
    except Exception:
        return 40, 14


def _herdr_bin():
    """Return the Herdr binary path from the plugin environment."""
    return os.environ.get("HERDR_BIN_PATH") or "herdr"


def _load_png(path):
    """Load a PNG path into an RGBA PIL image, or None."""
    if Image is None or not os.path.isfile(path):
        return None
    return Image.open(path).convert("RGBA")


def _load_sprites():
    """Load walk/sit/status PNGs as PIL images keyed by id."""
    paths = {
        IMG_WALK[0]: os.path.join(SPRITES_DIR, "cat_walk_0.png"),
        IMG_WALK[1]: os.path.join(SPRITES_DIR, "cat_walk_1.png"),
        IMG_WALK[2]: os.path.join(SPRITES_DIR, "cat_walk_2.png"),
        IMG_WALK[3]: os.path.join(SPRITES_DIR, "cat_walk_3.png"),
        IMG_SIT: os.path.join(SPRITES_DIR, "cat_sit.png"),
        IMG_BLOCKED: os.path.join(SPRITES_DIR, "cat_blocked.png"),
        IMG_HAPPY: os.path.join(SPRITES_DIR, "cat_happy.png"),
    }
    missing = [p for p in paths.values() if not os.path.isfile(p)]
    if missing:
        sys.stderr.write(
            "sprite_pet: missing sprites under %s\n" % SPRITES_DIR
        )
        for path in missing:
            sys.stderr.write("  - %s\n" % path)
        sys.exit(1)

    data = {}
    for image_id, path in paths.items():
        data[image_id] = _load_png(path)
    return data


def _agent_status():
    """Return agent status string from ``herdr agent list``."""
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
        return "idle"

    if proc.returncode != 0 or not proc.stdout.strip():
        return "idle"

    try:
        payload = json.loads(proc.stdout)
    except ValueError:
        return "idle"

    agents = []
    if isinstance(payload, dict):
        result = payload.get("result") or payload
        if isinstance(result, dict):
            agents = result.get("agents") or []

    if not agents:
        return "idle"

    focused = None
    for agent in agents:
        if agent.get("focused"):
            focused = agent
            break
    chosen = focused or agents[0]
    return chosen.get("agent_status") or "idle"


def _image_for(status, frame_i):
    """Pick a sprite id for the current agent status."""
    if status == "blocked":
        return IMG_BLOCKED
    if status == "done":
        return IMG_HAPPY
    if status == "idle":
        if (frame_i // 5) % 6 == 5:
            return IMG_SIT
        return IMG_WALK[frame_i % len(IMG_WALK)]
    return IMG_WALK[frame_i % len(IMG_WALK)]


def _speed_for(status):
    """Return (step_px, delay_seconds) for the animation tempo."""
    if status == "working":
        return 3, 0.09
    if status == "blocked":
        return 0, 0.28
    if status == "done":
        return 2, 0.12
    return 2, 0.14


def _scale_cat(cat, panel_w, panel_h):
    """Nearest-neighbor scale — nano pet that fills most of a thin strip."""
    # Leave a little headroom; keep width small so it can walk.
    target_h = max(10, min(int(panel_h * 0.78), panel_h - 4))
    target_w = max(10, min(int(panel_w * 0.18), 36))
    ratio = min(target_w / float(cat.width), target_h / float(cat.height))
    # Prefer integer upscale when close; otherwise shrink cleanly.
    if ratio >= 1.0:
        scale = max(1, int(ratio))
        new_w = cat.width * scale
        new_h = cat.height * scale
        if new_h > target_h or new_w > target_w:
            ratio = min(target_w / float(cat.width), target_h / float(cat.height))
            new_w = max(8, int(round(cat.width * ratio)))
            new_h = max(8, int(round(cat.height * ratio)))
    else:
        new_w = max(8, int(round(cat.width * ratio)))
        new_h = max(8, int(round(cat.height * ratio)))
    if new_h % 2:
        new_h += 1
    return cat.resize((new_w, new_h), Image.NEAREST)


def _compose_scene(cat, width, height, x_px, facing_right=True):
    """Build one vscode-pets-like frame (theme + floor + cat).

    ``width``/``height`` are terminal cells; the bitmap is width x height*2
    so each cell maps to exactly two vertical pixels (half-blocks).
    """
    pw = width
    ph = height * 2
    scene = Image.new("RGBA", (pw, ph), BG)

    # Forest theme only when the panel is large enough to keep pixels crisp.
    use_theme = (
        os.environ.get("HERDR_PETS_THEME", "auto").strip().lower()
    )
    if use_theme == "auto":
        use_theme = "forest" if (pw >= 56 and ph >= 36) else "none"
    if use_theme == "forest":
        bg = _load_png(os.path.join(THEMES_DIR, "forest-bg.png"))
        if bg is not None:
            cover_h = max(1, ph - 8)
            ratio = max(pw / float(bg.width), cover_h / float(bg.height))
            bw = max(pw, int(bg.width * ratio))
            bh = max(cover_h, int(bg.height * ratio))
            bg = bg.resize((bw, bh), Image.NEAREST)
            ox = (pw - bw) // 2
            oy = cover_h - bh
            scene.paste(bg, (ox, oy), bg)

    # Thin floor line (vscode-pets ground) — keep sky mostly empty.
    floor_h = 3 if ph < 24 else max(3, ph // 12)
    floor_y = ph - floor_h
    for y in range(floor_y, ph):
        for x in range(pw):
            scene.putpixel((x, y), FLOOR)
    for x in range(pw):
        scene.putpixel((x, floor_y), FLOOR_EDGE)

    cat_img = _scale_cat(cat, pw, ph)
    if not facing_right:
        cat_img = cat_img.transpose(Image.FLIP_LEFT_RIGHT)

    # Sit cat on the floor edge.
    cy = floor_y - cat_img.height + 2
    cx = int(x_px)
    cx = max(0, min(cx, max(0, pw - cat_img.width)))
    cy = max(0, cy)

    if use_theme == "forest":
        fg = _load_png(os.path.join(THEMES_DIR, "forest-fg.png"))
        if fg is not None:
            cover_h = floor_h + max(4, ph // 10)
            ratio = max(pw / float(fg.width), cover_h / float(fg.height))
            fw = max(pw, int(fg.width * ratio))
            fh = max(cover_h, int(fg.height * ratio))
            fg = fg.resize((fw, fh), Image.NEAREST)
            box = (0, max(0, fh - cover_h), min(fw, pw), fh)
            band = fg.crop(box)
            scene.paste(band, (0, ph - band.height), band)

    scene.paste(cat_img, (cx, cy), cat_img)
    return scene, cat_img.width


def _scene_to_halfblocks(scene):
    """Convert an RGBA scene into ANSI half-block lines (no transparency)."""
    pw, ph = scene.size
    lines = []
    for y in range(0, ph, 2):
        parts = []
        for x in range(pw):
            r1, g1, b1, _a1 = scene.getpixel((x, y))
            if y + 1 < ph:
                r2, g2, b2, _a2 = scene.getpixel((x, y + 1))
            else:
                r2, g2, b2 = r1, g1, b1
            parts.append(
                "\033[38;2;%d;%d;%dm\033[48;2;%d;%d;%dm▄\033[0m"
                % (r2, g2, b2, r1, g1, b1)
            )
        lines.append("".join(parts))
    return lines


def _draw_scene(lines):
    """Paint half-block scene lines to the terminal."""
    sys.stdout.write("\033[H")
    for line in lines:
        sys.stdout.write(line)
        sys.stdout.write("\033[K\n")
    sys.stdout.write("\033[J")
    sys.stdout.flush()


def _read_key(select_mod, delay):
    """Wait up to delay seconds for a quit key (q/Q)."""
    if select_mod is None or not sys.stdin.isatty():
        time.sleep(delay)
        return None

    ready, _, _ = select_mod.select([sys.stdin], [], [], delay)
    if not ready:
        return None

    ch = sys.stdin.read(1)
    if ch in ("q", "Q"):
        return "quit"
    if ch != "\x1b":
        return "other"

    # Drain ESC sequences (resize, stray APC, etc.).
    more, _, _ = select_mod.select([sys.stdin], [], [], 0.05)
    if not more:
        return "other"
    nxt = sys.stdin.read(1)
    if nxt in ("_", "["):
        deadline = time.time() + 0.25
        prev = ""
        while time.time() < deadline:
            r, _, _ = select_mod.select([sys.stdin], [], [], 0.05)
            if not r:
                break
            c = sys.stdin.read(1)
            if nxt == "_" and prev == "\x1b" and c == "\\":
                break
            if nxt == "[" and c and 0x40 <= ord(c) <= 0x7E:
                break
            if c == "\x07":
                break
            prev = c
    return "other"


def main():
    """Run the vscode-pets-style panel until quit."""
    running = {"ok": True}

    def _stop(_signum=None, _frame=None):
        running["ok"] = False

    signal.signal(signal.SIGINT, _stop)
    signal.signal(signal.SIGTERM, _stop)

    if Image is None:
        sys.stderr.write(
            "sprite_pet: Pillow required (brew install pillow)\n"
        )
        sys.exit(1)

    sprites = _load_sprites()

    fd = None
    old_termios = None
    select_mod = None
    try:
        import select as select_mod_import
        import termios
        import tty

        select_mod = select_mod_import
        if sys.stdin.isatty():
            fd = sys.stdin.fileno()
            old_termios = termios.tcgetattr(fd)
            tty.setcbreak(fd)
    except Exception:
        select_mod = None
        fd = None

    _hide_cursor()
    _clear()

    x_px = 4
    direction = 1
    frame_i = 0
    status = "idle"
    last_poll = 0.0
    last_size = (0, 0)
    cat_w = 24

    try:
        while running["ok"]:
            now = time.time()
            if now - last_poll > 1.0:
                status = _agent_status()
                last_poll = now

            width, height = _term_size()
            if (width, height) != last_size:
                last_size = (width, height)
                x_px = max(0, min(x_px, max(0, width - cat_w)))

            step, delay = _speed_for(status)
            image_id = _image_for(status, frame_i)
            cat = sprites[image_id]

            scene, cat_w = _compose_scene(
                cat,
                width,
                height,
                x_px,
                facing_right=(direction > 0),
            )
            lines = _scene_to_halfblocks(scene)
            _draw_scene(lines)

            if step:
                x_px += direction * step
                max_x = max(0, width - cat_w)
                if x_px >= max_x:
                    direction = -1
                    x_px = max_x
                elif x_px <= 0:
                    direction = 1
                    x_px = 0

            frame_i += 1
            key = _read_key(select_mod, delay)
            if key == "quit":
                break
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
