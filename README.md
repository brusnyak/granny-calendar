# 📅 Granny Calendar

A simple, no-nonsense calendar app for **Granny's Android phone** — with notes, reminders, and a real date on the icon.

## ⬇️ Download

> **Tap a link on your phone** to download and install.

[📲 **Download for most phones (arm64-v8a)**](https://github.com/brusnyak/granny-calendar/releases/latest)

### How to install

1. Tap the link above on your phone
2. Android will ask **"Allow installation from unknown sources?"** → tap **Settings** → enable it
3. Tap **Install**
4. Open the app once — the icon updates to today's date
5. That's it. The icon updates automatically at midnight.

## ✨ What it does

- **Launcher icon shows the real date** — today's day number, updated every midnight
- **Calendar** — month grid with navigation, today highlighted
- **Notes & reminders** — tap a day or press `+` to add a note. Set a time and toggle 🔔 to get a notification
- **Big, readable** — large date display, clear text, built for older eyes
- **Ukrainian & Russian** — auto-detects your phone language
- **No ads, no tracking, no internet needed**

## 📸 What it looks like

```
  ☰   ←  ЧЕРВЕНЬ 2026  →   +

           9
        вівторок

  Пн    3  10  17  24
  Вт    4  11  18  25
  Ср    5  12  19  26
  Чт    6  13  20  27
  Пт    7  14  21  28
  Сб    1   8  15  22  29
  Нд    2   9  16  23  30
```

Tap a day → see your notes. Press `+` → add a note with time & reminder.

## 🛠 Build from source

```bash
flutter pub get
flutter build apk --release --split-per-abi
python3 scripts/generate_icons.py   # optional: regenerate icons
python3 scripts/generate_android.py # optional: regenerate Android files
```

Built with **Flutter** + **Java** (Android native).
