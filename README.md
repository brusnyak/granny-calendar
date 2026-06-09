# 📅 Granny Calendar

A simple, no-nonsense calendar app for **Granny's Android phone**.

## ❓ The Problem

Google Calendar's app icon used to show the **actual day of the month**. After an update it got stuck on **31** — forever. Granny didn't like that.

## ✅ The Solution

A custom calendar app where:

- **The launcher icon shows the real date** — today's day number, updated automatically at midnight
- **Big, readable UI** — giant date display + full month grid, swipeable months
- **No setup needed** — install the APK and it just works

## ⬇️ Download

### Latest Release (v1.0.0)

| For your phone | Download |
|---|---|
| **Most modern phones (64-bit)** — Samsung S8+, A series, etc. | [📲 app-arm64-v8a-release.apk](https://github.com/brusnyak/granny-calendar/releases/download/v1.0.0/app-arm64-v8a-release.apk) |
| **Older phones (32-bit)** — Samsung S6, S7, J series | [📲 app-armeabi-v7a-release.apk](https://github.com/brusnyak/granny-calendar/releases/download/v1.0.0/app-armeabi-v7a-release.apk) |

> **Not sure which one?** Try `arm64-v8a` first. If it doesn't install, try `armeabi-v7a`.

### How to install

1. **Download the APK** on her phone (tap the link above)
2. **Open the downloaded file** — Android will ask to allow installation from unknown sources
3. **Tap "Install"**
4. **Open the app** once — the icon will immediately update to today's date
5. After that, the icon updates **automatically at midnight** every day

### Installing remotely (AnyDesk)

1. Download the APK on your computer
2. Open AnyDesk to her phone
3. Drag and drop the APK file into the AnyDesk window
4. On her phone, tap the notification → Install

## ✨ Features

- **Dynamic launcher icon** — shows today's day number (1–31)
- **Auto-updates** — switches to the next day at midnight, even if the app isn't open
- **Survives reboot** — re-schedules itself after phone restart
- **Giant date display** — big enough for older eyes
- **Month grid** — full calendar view with navigation
- **Ukrainian & Russian** — auto-detects device language
- **Clean, minimal** — no ads, no permissions, no nonsense

## 🛠 How it works

```
┌─────────────────────────────────────────┐
│  AndroidManifest.xml                     │
│  ┌─────────────────────────────────┐    │
│  │  activity-alias Day01 (enabled) │    │
│  │  activity-alias Day02 (disabled)│    │
│  │  activity-alias Day03 (disabled)│    │
│  │  ...                            │    │
│  │  activity-alias Day31 (disabled)│    │
│  └─────────────────────────────────┘    │
│                                         │
│  At midnight → AlarmManager fires       │
│  → enables today's alias                │
│  → disables all others                  │
│  → launcher icon updates                │
└─────────────────────────────────────────┘
```

**31 pre-generated icons** (one per day) are bundled in the APK. A native Java `AlarmManager` switches between them using Android's `activity-alias` mechanism.

## 🧑‍💻 Development

```bash
# Get dependencies
flutter pub get

# Generate icons (if you modify them)
python3 scripts/generate_icons.py
python3 scripts/generate_android.py

# Build APKs
flutter build apk --release --split-per-abi --tree-shake-icons
```

Built with **Flutter 3.35.5** + **Java** (Android native layer).

## 📦 Build outputs

Built APKs land in `build/app/outputs/flutter-apk/`.
