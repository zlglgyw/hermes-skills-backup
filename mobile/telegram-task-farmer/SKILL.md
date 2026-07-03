---
name: telegram-task-farmer
description: "Full AI Telegram task farming. Buka bot, kerjain task, submit reward, switch akun, repeat. Multi-account support."
version: 1.0.0
author: hermes
license: MIT
platforms: [linux]
prerequisites:
  commands: ["su"]
metadata:
  hermes:
    tags: [telegram, task, farming, automation, android, root, multi-account]
    category: mobile
---

# Telegram Task Farmer

⚠️ **WARNING:** Melanggar ToS Telegram. Bisa kena ban permanen. Risiko ditanggung sendiri.

## Overview

Otomasi penuh: buka Telegram → cari bot → kerjain task → ambil reward → switch akun → repeat.

## Mode Operasi

User pilih mode saat start:
- **`main`** — pakai akun utama Telegram aja
- **`all`** — rotate semua akun yang tersedia (multi-account)

## Workflow

```
START → pilih mode (main/all)
  │
  ├─ [mode main]
  │   loop:
  │     1. buka Telegram
  │     2. cari task bot
  │     3. baca task (screenshot + AI vision)
  │     4. kerjain task
  │     5. submit + ambil reward
  │     6. kalau task habis → DONE
  │
  └─ [mode all]
      loop untuk setiap akun:
        1. switch ke akun N
        2. buka Telegram
        3. cari task bot
        4. baca task (screenshot + AI vision)
        5. kerjain task
        6. submit + ambil reward
        7. kalau task habis → switch akun berikutnya
        8. kalau semua akun selesai → DONE
```

## Setup

### 1. Install dependencies
```bash
pkg install -y termux-api
```

### 2. Config bot target
Edit `~/.hermes/skills/mobile/telegram-task-farmer/config.json`:
```json
{
  "bot_username": "@NamaBotTask",
  "mode": "all",
  "delay_between_tasks": [5, 15],
  "delay_between_accounts": [30, 60],
  "max_tasks_per_account": 50,
  "accounts": [
    {"name": "akun1", "user_id": 0},
    {"name": "akun2", "user_id": 10}
  ]
}
```

### 3. Multi-account setup
```bash
# Buat user profile untuk setiap akun
su -c "pm create-user 'tg_farm1'"
su -c "pm create-user 'tg_farm2'"

# Install Telegram di setiap profile
su -c "pm install-existing --user 10 org.telegram.messenger"
su -c "pm install-existing --user 11 org.telegram.messenger"
```

## Command Reference

### Buka Telegram
```bash
su -c "am start -n org.telegram.messenger/.DefaultAlias"
sleep 3
```

### Switch Android User (multi-account)
```bash
su -c "am switch-user 10"
sleep 5
```

### Screenshot → AI Analyze Task
```bash
su -c "screencap -p /sdcard/tg_screen.png"
cp /sdcard/tg_screen.png ~/tg_screen.png
# → kirim ke vision_analyze: "what task is shown? what buttons to tap?"
```

### Navigasi Telegram
```bash
# Tap search
su -c "input tap 950 200"
sleep 1

# Ketik nama bot
su -c "input text 'NamaBot'"
sleep 2

# Tap hasil search pertama
su -c "input tap 540 500"
sleep 2
```

### Task Actions (AI-driven)
```bash
# AI detect tombol task → tap koordinat
su -c "input tap 540 1200"

# Join channel (kalau task minta join)
su -c "input tap 540 800"
sleep 3
su -c "input keyevent 4"  # back

# Submit task
su -c "input tap 540 1500"
```

## Anti-Detection

- Random delay 5-15 detik antar task
- Random delay 30-60 detik antar akun
- Jangan lebih dari 50 task per akun per hari
- Sesekali skip task (biar gak patterned)
- Koordinat tap kasih offset ±10px random

## Pitfalls

1. **Bot ganti layout** — screenshot + AI vision handle ini, gak hardcode koordinat
2. **Rate limit Telegram** — kalau kena flood wait, tunggu sesuai waktu yang dikasih
3. **Ban wave** — Telegram kadang mass-ban akun farming. Jangan semua akun jalan bareng
4. **Screen timeout** — matikan: `su -c "settings put system screen_off_timeout 2147483647"`
5. **Battery** — HP bakal panas, kasih cooldown period
6. **Verifikasi** — kadang Telegram minta verifikasi ulang (captcha/phone). AI bisa detect dan pause, minta user intervene
