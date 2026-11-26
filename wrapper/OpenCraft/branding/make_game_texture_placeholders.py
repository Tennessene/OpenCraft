#!/usr/bin/env python3
"""Turns the lobby's game textures into placeholders that load the real ones at runtime.

The lobby scenery (Assets/WinterLodge) was exported from the game, so some of
its textures are the game's own block and entity textures. OpenCraft doesn't
ship those. Each one is replaced by a same-size image filled with the original's
average colour, and renamed to

    gametex.<path under assets/minecraft/textures, dots for slashes>.png

keeping its .meta file (and GUID), so every material still points at it.
GameTextureLoader.cs reads that name at runtime and swaps in the real texture
from the player's own installed game.

Run once from the wrapper folder:  python3 OpenCraft/branding/make_game_texture_placeholders.py
"""
import os
import struct
import zlib

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
LODGE = os.path.join(ROOT, "Assets", "WinterLodge")

# Game textures outside the exporter's tex/minecraft/ folder, mapped to where they live in the game.
LOOSE = {
    "Mushroom/DIRT.png": "block/dirt",
    "decorated_pot_side.png": "entity/decorated_pot/decorated_pot_side",
    "MW_bed_feet_top.png": "entity/bed/red",
    "tex/jmc2obj/banner/banner_base14.png": "entity/banner_base",
}


def read_png(path):
    data = open(path, "rb").read()
    assert data[:8] == b"\x89PNG\r\n\x1a\n", path
    pos, idat, palette, trns = 8, b"", None, None
    while pos < len(data):
        length, kind = struct.unpack(">I4s", data[pos:pos + 8])
        body = data[pos + 8:pos + 8 + length]
        if kind == b"IHDR":
            width, height, depth, ctype, _, _, interlace = struct.unpack(">IIBBBBB", body)
        elif kind == b"PLTE":
            palette = [tuple(body[i:i + 3]) for i in range(0, len(body), 3)]
        elif kind == b"tRNS":
            trns = body
        elif kind == b"IDAT":
            idat += body
        pos += 12 + length
    if depth != 8 or interlace:
        return width, height, None  # unusual format: caller falls back to grey
    channels = {0: 1, 2: 3, 3: 1, 4: 2, 6: 4}[ctype]
    stride = width * channels
    raw = zlib.decompress(idat)
    rows, prev, i = [], bytearray(stride), 0
    for _ in range(height):
        f = raw[i]; line = bytearray(raw[i + 1:i + 1 + stride]); i += 1 + stride
        for x in range(stride):
            a = line[x - channels] if x >= channels else 0
            b = prev[x]
            c = prev[x - channels] if x >= channels else 0
            if f == 1: line[x] = (line[x] + a) & 255
            elif f == 2: line[x] = (line[x] + b) & 255
            elif f == 3: line[x] = (line[x] + ((a + b) >> 1)) & 255
            elif f == 4:
                p = a + b - c; pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
                line[x] = (line[x] + (a if pa <= pb and pa <= pc else b if pb <= pc else c)) & 255
        rows.append(line); prev = line
    pixels = []
    for line in rows:
        for x in range(width):
            px = line[x * channels:(x + 1) * channels]
            if ctype == 6: pixels.append(tuple(px))
            elif ctype == 2: pixels.append((*px, 255))
            elif ctype == 0: pixels.append((px[0], px[0], px[0], 255))
            elif ctype == 4: pixels.append((px[0], px[0], px[0], px[1]))
            elif ctype == 3:
                r, g, b_ = palette[px[0]]
                alpha = trns[px[0]] if trns and px[0] < len(trns) else 255
                pixels.append((r, g, b_, alpha))
    return width, height, pixels


def average(pixels):
    if not pixels:
        return (128, 128, 128, 255)
    seen = [p for p in pixels if p[3] > 0] or pixels
    n = len(seen)
    alpha = 255 if len(seen) == len(pixels) else 200
    return tuple(sum(p[i] for p in seen) // n for i in range(3)) + (alpha,)


def write_png(path, width, height, colour):
    row = b"\x00" + bytes(colour) * width
    def chunk(tag, body):
        return struct.pack(">I", len(body)) + tag + body + struct.pack(">I", zlib.crc32(tag + body) & 0xFFFFFFFF)
    png = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0))
    png += chunk(b"IDAT", zlib.compress(row * height, 9)) + chunk(b"IEND", b"")
    open(path, "wb").write(png)


def targets():
    for dirpath, _, files in os.walk(os.path.join(LODGE, "tex", "minecraft")):
        for name in files:
            if name.endswith(".png"):
                full = os.path.join(dirpath, name)
                rel = os.path.relpath(full, os.path.join(LODGE, "tex", "minecraft"))
                yield full, rel[:-4].replace(os.sep, "/")
    for rel, game_path in LOOSE.items():
        full = os.path.join(LODGE, rel)
        if os.path.exists(full):
            yield full, game_path


def main():
    count = 0
    for full, game_path in list(targets()):
        width, height, pixels = read_png(full)
        new = os.path.join(os.path.dirname(full), "gametex." + game_path.replace("/", ".") + ".png")
        write_png(new, width, height, average(pixels))
        if new != full:
            os.remove(full)
            os.rename(full + ".meta", new + ".meta")
        count += 1
    print(f"{count} game textures replaced by placeholders")


if __name__ == "__main__":
    main()
