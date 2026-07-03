---
name: game-botter
description: "Game botting automation di Android rooted. Screenshot → AI vision → tap/swipe loop. Multi-account support."
version: 1.0.0
author: hermes
license: MIT
platforms: [linux]
prerequisites:
  commands: ["su"]
metadata:
  hermes:
    tags: [game, bot, automation, android, root, farming, multi-account]
    category: mobile
---

# Game Botter - Android Root Automation

⚠️ **WARNING:** Melanggar ToS game. Bisa kena permanent ban. Risiko ditanggung sendiri.

## Kapan Dipake

- User minta bot game (auto farming, auto battle, dll)
- Multi-account farming di game
- Automasi repetitif di Android

## Workflow Dasar

```
loop forever:
  1. Screenshot layar
  2. Kirim ke AI vision → detect state (menu/battle/loading/reward/dll)
  3. AI tentuin action (tap koordinat, swipe, tunggu)
  4. Random delay (3-8 detik, anti-pattern detection)
  5. Cek apakah perlu switch account
  6. Ulang
```

## Command Reference

### Screenshot → AI Analyze
```bash
# Capture
su -c "screencap -p /sdcard/bot_screen.png"
cp /sdcard/bot_screen.png ~/bot_screen.png
# → kirim ke vision_analyze, tanya "what game state is this? what should I tap?"
```

### Execute Action
```bash
su -c "input tap 540 1200"           # tap
su -c "input swipe 540 1500 540 500 300"  # swipe up
su -c "input keyevent 4"             # back
```

### Random Delay (anti-detection)
```bash
sleep $((RANDOM % 6 + 3))   # 3-8 detik random
```

## Multi-Account Setup

### Method 1: Android Work Profile (RECOMMENDED)
```bash
# Cek existing profiles
su -c "pm list users"

# Buat work profile
su -c "pm create-user 'Farm1'"
su -c "pm create-user 'Farm2'"
# dst...

# Switch user
su -c "am switch-user 10"
su -c "am switch-user 0"   # balik ke main

# Install app di profile tertentu
su -c "pm install-existing --user 10 com.game.package"
```

### Method 2: App Cloner Apps
- **Parallel Space** — clone app, bisa 2+ instance
- **Island** — work profile manager, by Oasis Feng
- **Shelter** — open source work profile

### Method 3: Multiple APK Install
```bash
# Rename package (butuh modifikasi APK, advanced)
# Atau install different version (misal: original + modded)
su -c "pm install -r /sdcard/game_v1.apk"
su -c "pm install -r /sdcard/game_v2.apk"
```

## Pitfalls

1. **Anti-bot detection** — game cek pattern tap. Pakai random delay, random offset koordinat (±10px)
2. **Screen timeout** — matikan auto-lock: `su -c "settings put system screen_off_timeout 2147483647"`
3. **CPU overheat** — HP panas kalau jalan terus. Kasih cooldown period (pause 5 menit tiap 30 menit)
4. **OOM killer** — game bisa di-kill Android. Lock app di recent apps: `su -c "am set-foreground <pid>"`
5. **Network DC** — cek koneksi sebelum start: `ping -c 1 8.8.8.8`
6. **Memory leak** — restart game tiap beberapa jam

## Anti-Detection Tips

- Random delay 3-10 detik antar action
- Random offset ±15px di koordinat tap
- Kadang idle 20-30 detik (simulate player AFK)
- Rotate aktivitas (jangan monoton)
- Jangan jalan 24/7 nonstop
- Sesekali swipe random / tap area kosong
