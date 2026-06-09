#!/usr/bin/env python3
"""
Generate 31 calendar day icons for Android.
Simple design: white rounded square with a blue accent stripe and large bold number.
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

WHITE = (255, 255, 255)
BLUE_ACCENT = (41, 98, 255)
NUMBER_COLOR = (25, 25, 25)

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RES_DIR = os.path.join(BASE_DIR, "android", "app", "src", "main", "res")

FONT_PATHS = [
    "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
    "/System/Library/Fonts/Helvetica.ttc",
    "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
]


def _best_font(draw, num_str, max_size):
    """Try font paths in order, return the largest that fits."""
    best = None
    best_fs = 0
    for fp in FONT_PATHS:
        if not os.path.exists(fp):
            continue
        for fs in range(max_size, int(max_size * 0.25), -2):
            try:
                f = ImageFont.truetype(fp, size=fs)
                bb = draw.textbbox((0, 0), num_str, font=f)
                if bb[2] - bb[0] > 0 and bb[3] - bb[1] > 0:
                    if fs > best_fs:
                        best = f
                        best_fs = fs
                    break  # This size works, try next font
            except Exception:
                continue
    return best or ImageFont.load_default()


def draw_icon(draw, size, number):
    """Draw a clean calendar icon with a big number."""
    pad = int(size * 0.09)
    radius = int(size * 0.15)

    # White rounded square with subtle border
    draw.rounded_rectangle(
        [pad, pad, size - pad, size - pad],
        radius=radius,
        fill=WHITE,
        outline=(210, 210, 210),
        width=max(1, int(size * 0.02)),
    )

    # Small blue accent stripe at top
    ah = int(size * 0.065)
    ay = pad + int(size * 0.035)
    ax1 = pad + int(size * 0.07)
    ax2 = size - pad - int(size * 0.07)
    draw.rounded_rectangle(
        [ax1, ay, ax2, ay + ah],
        radius=max(1, int(radius * 0.3)),
        fill=BLUE_ACCENT,
    )

    # Number: fill all space below the accent stripe
    num_str = str(number)
    avail_w = size - pad * 3
    avail_h = size - ay - ah - pad * 2
    max_fs = int(min(avail_w, avail_h) * 0.95)

    font = _best_font(draw, num_str, max_fs)
    bb = draw.textbbox((0, 0), num_str, font=font)
    tw, th = bb[2] - bb[0], bb[3] - bb[1]

    cx = size // 2
    cy = (ay + ah + size - pad) // 2
    tx = cx - tw // 2 - bb[0]
    ty = cy - th // 2 - bb[1]
    draw.text((tx, ty), num_str, fill=NUMBER_COLOR, font=font)


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
    print(f"\n✅ All icons generated under {RES_DIR}")


if __name__ == "__main__":
    print("Generating icons (big number, blue accent)...")
    generate_all_icons()
