#!/usr/bin/env python3
"""
Generate 31 calendar day icons for Android.
Full-bleed solid blue background with large centered white number — Google Calendar style.
"""

from PIL import Image, ImageDraw, ImageFont
import os

DENSITIES = {
    "mdpi": 48,
    "hdpi": 72,
    "xhdpi": 96,
    "xxhdpi": 144,
    "xxxhdpi": 192,
}

BLUE_BG = (41, 98, 255)
WHITE = (255, 255, 255)

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RES_DIR = os.path.join(BASE_DIR, "android", "app", "src", "main", "res")

FONT_PATHS = [
    "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
    "/System/Library/Fonts/Helvetica.ttc",
    "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
]


def _best_font(draw, num_str, max_fs, max_w, max_h):
    """Try font paths in order, return the largest that fits within max_w x max_h."""
    best = None
    best_fs = 0
    for fp in FONT_PATHS:
        if not os.path.exists(fp):
            continue
        for fs in range(max_fs, int(max_fs * 0.25), -2):
            try:
                f = ImageFont.truetype(fp, size=fs)
                bb = draw.textbbox((0, 0), num_str, font=f)
                w, h = bb[2] - bb[0], bb[3] - bb[1]
                if 0 < w <= max_w and 0 < h <= max_h and fs > best_fs:
                    best = f
                    best_fs = fs
                    break
            except Exception:
                continue
    return best or ImageFont.load_default()


def draw_icon(draw, size, number):
    """Full-bleed solid blue background with centered white number."""
    draw.rectangle([0, 0, size - 1, size - 1], fill=BLUE_BG)

    num_str = str(number)
    padding = int(size * 0.05)
    avail = size - padding * 2
    max_fs = int(size * 1.2)

    font = _best_font(draw, num_str, max_fs, avail, avail)
    bb = draw.textbbox((0, 0), num_str, font=font)
    tw, th = bb[2] - bb[0], bb[3] - bb[1]

    cx = size // 2
    cy = size // 2
    tx = cx - tw // 2 - bb[0]
    ty = cy - th // 2 - bb[1]
    draw.text((tx, ty), num_str, fill=WHITE, font=font)


def generate_all_icons():
    for day in range(1, 32):
        for density, size in DENSITIES.items():
            mipmap_dir = os.path.join(RES_DIR, f"mipmap-{density}")
            os.makedirs(mipmap_dir, exist_ok=True)
            img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
            draw = ImageDraw.Draw(img)
            draw_icon(draw, size, day)
            img.save(os.path.join(mipmap_dir, f"ic_day_{day:02d}.png"), "PNG")
        print(f"  Day {day:2d} done")
    print(f"\nAll icons generated under {RES_DIR}")


if __name__ == "__main__":
    print("Generating icons (blue background, white number)...")
    generate_all_icons()
