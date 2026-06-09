#!/usr/bin/env python3
"""
Generate 31 calendar day icons for Android at all mipmap densities.
Creates icons with a calendar-style white background, red top bar,
and bold day number.
"""

from PIL import Image, ImageDraw, ImageFont
import os
import math

# Android mipmap densities and their sizes (launcher icon)
DENSITIES = {
    "mdpi": 48,
    "hdpi": 72,
    "xhdpi": 96,
    "xxhdpi": 144,
    "xxxhdpi": 192,
}

# Colors
WHITE = (255, 255, 255)
RED_BAR = (220, 50, 47)  # Google Calendar red
NUMBER_COLOR = (60, 60, 60)  # Dark gray
RED_DOT = (220, 50, 47)  # For the dot over 'i' in some fonts? No, just the bar

# Project base
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RES_DIR = os.path.join(BASE_DIR, "android", "app", "src", "main", "res")


def get_font(size):
    """Try to get a bold system font, fall back to default."""
    font_paths = [
        "/System/Library/Fonts/Helvetica.ttc",
        "/System/Library/Fonts/HelveticaNeue.ttc",
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
        "/System/Library/Fonts/Supplemental/Arial.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
        "/usr/share/fonts/TTF/DejaVuSans-Bold.ttf",
    ]
    for path in font_paths:
        if os.path.exists(path):
            try:
                return ImageFont.truetype(path, size=int(size * 0.55))
            except Exception:
                continue
    return ImageFont.load_default()


def draw_calendar_icon(draw, size, number, font):
    """Draw a calendar icon on the given draw context."""
    padding = int(size * 0.08)
    corner_radius = int(size * 0.12)
    bar_height = int(size * 0.28)

    # White rounded rectangle background
    draw.rounded_rectangle(
        [padding, padding, size - padding, size - padding],
        radius=corner_radius,
        fill=WHITE,
        outline=NUMBER_COLOR,
        width=max(1, int(size * 0.02)),
    )

    # Red top bar (calendar header strip)
    bar_top = padding + int(size * 0.02)
    bar_bottom = bar_top + bar_height
    draw.rounded_rectangle(
        [padding + 1, bar_top, size - padding - 1, bar_bottom],
        radius=max(1, int(corner_radius * 0.5)),
        fill=RED_BAR,
    )

    # Draw number
    number_str = str(number)
    try:
        # Calculate font size to fit nicely in the space below the bar
        max_width = size - padding * 4
        max_height = size - bar_bottom - padding * 2
        font_size = int(min(max_width, max_height) * 0.7)

        # Try a few sizes
        for fs in range(font_size, 0, -2):
            try:
                f = ImageFont.truetype(font.path if hasattr(font, 'path') else font_paths[0], size=fs)
            except:
                f = font
            bbox = draw.textbbox((0, 0), number_str, font=f)
            tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
            if tw <= max_width and th <= max_height:
                font_to_use = f
                break
        else:
            font_to_use = font
    except:
        font_to_use = font

    # Get text dimensions
    bbox = draw.textbbox((0, 0), number_str, font=font_to_use)
    tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]

    # Center the number
    cx = size // 2
    cy = (bar_bottom + size - padding) // 2
    tx = cx - tw // 2 - bbox[0]
    ty = cy - th // 2 - bbox[1]

    draw.text((tx, ty), number_str, fill=NUMBER_COLOR, font=font_to_use)


def generate_all_icons():
    """Generate icons for all 31 days at all densities."""
    for day in range(1, 32):
        for density, size in DENSITIES.items():
            mipmap_dir = os.path.join(RES_DIR, f"mipmap-{density}")
            os.makedirs(mipmap_dir, exist_ok=True)

            img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
            draw = ImageDraw.Draw(img)
            font = get_font(size)
            draw_calendar_icon(draw, size, day, font)

            filename = f"ic_day_{day:02d}.png"
            filepath = os.path.join(mipmap_dir, filename)
            img.save(filepath, "PNG")
            print(f"  {density}: {filename} ({size}x{size})")

        print(f"  Day {day:2d} done")

    print(f"\n✅ All icons generated under {RES_DIR}")


def generate_adaptive_icons():
    """Generate adaptive icon XML for API 26+ (foreground only, background is solid)."""
    anydpi_dir = os.path.join(RES_DIR, "mipmap-anydpi-v26")
    drawable_dir = os.path.join(RES_DIR, "drawable")
    os.makedirs(anydpi_dir, exist_ok=True)
    os.makedirs(drawable_dir, exist_ok=True)

    # Create a simple white background drawable
    bg_xml = '<?xml version="1.0" encoding="utf-8"?>\n<shape xmlns:android="http://schemas.android.com/apk/res/android" android:shape="rectangle">\n    <solid android:color="#FFFFFF" />\n    <corners android:radius="12dp" />\n</shape>\n'
    with open(os.path.join(drawable_dir, "ic_calendar_bg.xml"), "w") as f:
        f.write(bg_xml)

    for day in range(1, 32):
        # Adaptive icon XML
        adaptive_xml = f'<?xml version="1.0" encoding="utf-8"?>\n<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n    <background android:drawable="@drawable/ic_calendar_bg" />\n    <foreground android:drawable="@mipmap/ic_day_{day:02d}" />\n</adaptive-icon>\n'
        filename = f"ic_day_{day:02d}.xml"
        with open(os.path.join(anydpi_dir, filename), "w") as f:
            f.write(adaptive_xml)

    print(f"✅ Adaptive icon XMLs generated ({31} files)")


if __name__ == "__main__":
    print("🎨 Generating calendar day icons...")
    generate_all_icons()
    generate_adaptive_icons()
