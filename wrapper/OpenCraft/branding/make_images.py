#!/usr/bin/env python3
"""Draws OpenCraft's icon, wordmark and link symbols for the Unity wrapper.

Each image overwrites an existing file at the same path and size, so Unity
keeps the .meta file (and its GUID) and every scene reference still resolves.
Only the Python standard library is used.

    python3 OpenCraft/branding/make_images.py
"""
import os
import random
import struct
import zlib

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))

NAVY = (20, 33, 61, 255)
BLUE = (31, 78, 121, 255)
INK = (11, 19, 43, 255)
PAPER = (224, 225, 221, 255)
GREEN_HI = (123, 211, 137, 255)
GREEN = (63, 163, 77, 255)
GREEN_LO = (43, 122, 55, 255)
CLEAR = (0, 0, 0, 0)


class Canvas:
    def __init__(self, w, h, fill=CLEAR):
        self.w, self.h = w, h
        self.px = [list(fill) for _ in range(w * h)]

    def rect(self, x0, y0, x1, y1, c):
        for y in range(max(0, y0), min(self.h, y1)):
            row = y * self.w
            for x in range(max(0, x0), min(self.w, x1)):
                self.px[row + x] = list(c)

    def gradient(self, top, bottom):
        for y in range(self.h):
            t = y / max(1, self.h - 1)
            c = [round(top[i] + (bottom[i] - top[i]) * t) for i in range(4)]
            self.rect(0, y, self.w, y + 1, c)

    def save(self, rel_path):
        raw = bytearray()
        for y in range(self.h):
            raw.append(0)
            for x in range(self.w):
                raw.extend(self.px[y * self.w + x])

        def chunk(tag, data):
            body = tag + data
            return struct.pack(">I", len(data)) + body + struct.pack(">I", zlib.crc32(body) & 0xFFFFFFFF)

        png = b"\x89PNG\r\n\x1a\n"
        png += chunk(b"IHDR", struct.pack(">IIBBBBB", self.w, self.h, 8, 6, 0, 0, 0))
        png += chunk(b"IDAT", zlib.compress(bytes(raw), 9))
        png += chunk(b"IEND", b"")
        path = os.path.join(ROOT, rel_path)
        with open(path, "wb") as f:
            f.write(png)
        print("wrote", rel_path, f"{self.w}x{self.h}")


def blit_grid(canvas, grid, palette, cell, ox, oy):
    """Paints a small character grid onto the canvas, one cell per character."""
    for gy, line in enumerate(grid):
        for gx, ch in enumerate(line):
            c = palette.get(ch)
            if c:
                canvas.rect(ox + gx * cell, oy + gy * cell, ox + (gx + 1) * cell, oy + (gy + 1) * cell, c)


# A headset seen from the front: frame (#), lens rim (o), lens glass (.),
# and a little cube in each lens (h/g/d = light, mid, dark faces).
HEADSET = [
    "...........................",
    "...........................",
    "...........................",
    "...........................",
    "...........................",
    "....###################....",
    "...#####################...",
    "..###ooooooo###ooooooo###..",
    "..##oo.....oo#oo.....oo##..",
    "..##o...h...o#o...h...o##..",
    "..##o..hhh..o#o..hhh..o##..",
    "..##o.ghhhd.o#o.ghhhd.o##..",
    "..##o.gghdd.o#o.gghdd.o##..",
    "..##o.ggddd.o#o.ggddd.o##..",
    "..##o..gdd..o#o..gdd..o##..",
    "..##oo..d..oo#oo..d..oo##..",
    "..###ooooooo###ooooooo###..",
    "...########.....########...",
    "....######.......######....",
    "...........................",
]
HEADSET_PALETTE = {"#": PAPER, "o": PAPER, ".": None, "h": GREEN_HI, "g": GREEN, "d": GREEN_LO}


def app_icon():
    c = Canvas(1080, 1080, CLEAR)
    c.rect(60, 60, 1020, 1020, NAVY)
    for y in range(60, 1020):  # soft vertical shade on the tile
        t = (y - 60) / 960
        col = [round(NAVY[i] + (BLUE[i] - NAVY[i]) * t) for i in range(3)] + [255]
        c.rect(60, y, 1020, y + 1, col)
    cell, oy = 40, 140
    # lens glass behind each cube (grid columns 5-11 and 15-21, rows 8-15)
    for gx0, gx1 in ((5, 12), (15, 22)):
        c.rect(gx0 * cell, oy + 8 * cell, gx1 * cell, oy + 16 * cell, BLUE)
    blit_grid(c, HEADSET, HEADSET_PALETTE, cell, 0, oy)
    c.save("Assets/Resources/Materials/export202201252311597020.png")


# 5x7 pixel font, only the letters we need.
FONT = {
    "O": [".###.", "#...#", "#...#", "#...#", "#...#", "#...#", ".###."],
    "P": ["####.", "#...#", "#...#", "####.", "#....", "#....", "#...."],
    "E": ["#####", "#....", "#....", "####.", "#....", "#....", "#####"],
    "N": ["#...#", "##..#", "#.#.#", "#..##", "#...#", "#...#", "#...#"],
    "C": [".####", "#....", "#....", "#....", "#....", "#....", ".####"],
    "R": ["####.", "#...#", "#...#", "####.", "#.#..", "#..#.", "#...#"],
    "A": [".###.", "#...#", "#...#", "#####", "#...#", "#...#", "#...#"],
    "F": ["#####", "#....", "#....", "####.", "#....", "#....", "#...."],
    "T": ["#####", "..#..", "..#..", "..#..", "..#..", "..#..", "..#.."],
}


def wordmark():
    w, h = 2749, 577
    c = Canvas(w, h, CLEAR)
    text = "OPENCRAFT"
    cell = 50
    total = len(text) * 6 * cell - cell
    ox, oy = (w - total) // 2, (h - 7 * cell) // 2
    for i, ch in enumerate(text):
        colour = PAPER if i < 4 else GREEN_HI
        shadow = INK
        x = ox + i * 6 * cell
        blit_grid(c, FONT[ch], {"#": shadow}, cell, x + 12, oy + 12)
        blit_grid(c, FONT[ch], {"#": colour}, cell, x, oy)
    c.save("Assets/Resources/Pojav_x_Vivecraft.png")


def link_glyphs():
    # Plain "chat" and "link" symbols in white, used where third-party logos were.
    chat = Canvas(528, 400, CLEAR)
    chat.rect(64, 48, 464, 288, PAPER)
    chat.rect(128, 288, 224, 352, PAPER)
    for i, x in enumerate((160, 248, 336)):
        chat.rect(x, 152, x + 40, 192, CLEAR)
    chat.save("Assets/Resources/UI/Discord-Symbol-White.png")

    link = Canvas(256, 256, CLEAR)
    link.rect(40, 96, 136, 160, PAPER)
    link.rect(64, 112, 112, 144, CLEAR)
    link.rect(120, 96, 216, 160, PAPER)
    link.rect(144, 112, 192, 144, CLEAR)
    link.rect(96, 120, 160, 136, PAPER)
    link.save("Assets/Resources/UI/X Logo.png")


if __name__ == "__main__":
    app_icon()
    wordmark()
    link_glyphs()
