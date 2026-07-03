---
name: android-root-control
description: "Kontrol Android rooted via Termux + su. UI automation, app management, system control, backup, modifikasi sistem."
version: 1.0.0
author: hermes
license: MIT
platforms: [linux]
prerequisites:
  commands: ["su"]
metadata:
  hermes:
    tags: [android, root, automation, mobile, termux, control]
    category: mobile
---

# Android Root Control

Kontrol penuh Android rooted dari Termux. Semua command butuh `su`.

## Kapan Dipake

- User minta kontrol HP Android (tap, swipe, buka app, dll)
- Manajemen app (install, uninstall, disable bloatware)
- System settings (brightness, wifi, data, airplane mode)
- Backup/restore data
- Automasi UI (buka app, navigasi, isi form)
- Ambil screenshot, screen record

## Pola Dasar

Semua root command pakai prefix `su -c`:
```bash
su -c "command"
```

Multi-line / complex command:
```bash
su <<'EOF'
command1
command2
EOF
```

## UI Automation

### Tap / Klik
```bash
# Tap di koordinat x,y
su -c "input tap 540 1200"

# Long press (hold 2 detik)
su -c "input swipe 540 1200 540 1200 2000"
```

### Swipe
```bash
# Swipe ke atas (scroll down)
su -c "input swipe 540 1500 540 500 300"

# Swipe ke bawah (scroll up)
su -c "input swipe 540 500 540 1500 300"

# Swipe ke kiri
su -c "input swipe 900 1200 100 1200 300"

# Swipe ke kanan
su -c "input swipe 100 1200 900 1200 300"
```

### Ketik Teks
```bash
# Ketik teks (Inggris/ASCII only)
su -c "input text 'hello world'"

# Ketik dengan spasi (%s = spasi di shell)
su -c "input text 'hello%sworld'"
```

### Tombol Hardware/Nav
```bash
su -c "input keyevent 3"    # Home
su -c "input keyevent 4"    # Back
su -c "input keyevent 26"   # Power
su -c "input keyevent 24"   # Volume Up
su -c "input keyevent 25"   # Volume Down
su -c "input keyevent 187"  # Recent Apps / App Switcher
su -c "input keyevent 223"  # Lock screen
su -c "input keyevent 82"   # Menu (kalau ada)
su -c "input keyevent 67"   # Delete/Backspace
su -c "input keyevent 66"   # Enter
```

### Screenshot & Screen Record
```bash
# Screenshot
su -c "screencap -p /sdcard/screenshot.png"
cp /sdcard/screenshot.png ~/screenshot.png

# Screen record (30 detik max, Ctrl+C untuk stop)
su -c "screenrecord /sdcard/record.mp4 --time-limit 30"
cp /sdcard/record.mp4 ~/record.mp4
```

## App Management

### List Apps
```bash
# Semua app terinstall
su -c "pm list packages"

# App pihak ketiga (non-system)
su -c "pm list packages -3"

# Cari app tertentu
su -c "pm list packages" | grep -i "whatsapp"
```

### Buka / Tutup App
```bash
# Buka app (cari package name dulu)
su -c "am start -n com.whatsapp/.Main"

# Buka app berdasarkan package (launch default activity)
su -c "monkey -p com.whatsapp -c android.intent.category.LAUNCHER 1"

# Force stop app
su -c "am force-stop com.whatsapp"
```

### Disable / Enable Bloatware
```bash
# Disable (nonaktifkan tanpa uninstall)
su -c "pm disable-user com.google.android.youtube"
su -c "pm disable-user com.samsung.android.bixby.agent"

# Enable kembali
su -c "pm enable com.google.android.youtube"
```

### Install / Uninstall
```bash
# Install APK
su -c "pm install /sdcard/app.apk"

# Uninstall
su -c "pm uninstall com.example.app"
```

### Clear Data / Cache
```bash
su -c "pm clear com.example.app"
```

## System Control

### Layar & Display
```bash
# Brightness (0-255)
su -c "settings put system screen_brightness 128"

# Screen timeout (detik)
su -c "settings put system screen_off_timeout 600000"  # 10 menit

# Auto-rotate on/off
su -c "settings put system accelerometer_rotation 0"  # off
su -c "settings put system accelerometer_rotation 1"  # on
```

### Jaringan
```bash
# WiFi
su -c "svc wifi enable"
su -c "svc wifi disable"

# Mobile data
su -c "svc data enable"
su -c "svc data disable"

# Airplane mode
su -c "settings put global airplane_mode_on 1"
su -c "am broadcast -a android.intent.action.AIRPLANE_MODE --ez state true"
```

### Audio
```bash
# Volume (0-15 biasanya)
su -c "cmd media_session volume --set 10 --stream 3"  # media
su -c "cmd media_session volume --set 10 --stream 1"  # ring
su -c "cmd media_session volume --set 10 --stream 2"  # notification

# Mute/unmute
su -c "cmd audio set-stream-volume STREAM_MUSIC 0 0"
```

### Battery & Info
```bash
# Battery info
su -c "dumpsys battery"

# Device info
su -c "getprop ro.product.model"
su -c "getprop ro.build.version.release"
su -c "getprop ro.product.cpu.abi"

# Running processes
su -c "ps -A" | head -20

# Storage
su -c "df -h"
```

## File System (Root)

```bash
# Akses file sistem manapun
su -c "ls /data/data/"
su -c "cat /data/data/com.whatsapp/databases/msgstore.db"

# Backup app data
su -c "tar czf /sdcard/whatsapp_backup.tar.gz /data/data/com.whatsapp/"

# Copy file dari/ke system
su -c "cp /system/build.prop /sdcard/build.prop.bak"
su -c "cp /sdcard/modified_build.prop /system/build.prop"
```

## Notification & Toast

```bash
# Tampilkan toast message
su -c "am broadcast -a android.intent.action.SEND --es msg 'Hello from Hermes'"

# Kirim notifikasi (butuh termux:API)
termux-notification --title "Hermes" --content "Task selesai"
```

## Workflow Umum

### Buka Aplikasi + Tap + Ketik
```bash
# 1. Buka WhatsApp
su -c "monkey -p com.whatsapp -c android.intent.category.LAUNCHER 1"
sleep 3  # tunggu app load

# 2. Tap search (koordinat perlu disesuaikan per device)
su -c "input tap 950 200"
sleep 1

# 3. Ketik
su -c "input text 'john'"
```

### Cari Koordinat Layar
```bash
# Aktifkan pointer location (debug)
su -c "settings put system pointer_location 1"

# Matikan setelah selesai
su -c "settings put system pointer_location 0"
```

### Auto-detect Resolusi
```bash
# Dapatkan ukuran layar
su -c "wm size"
# Output: Physical size: 1080x2400

# Density
su -c "wm density"
```

## Pitfalls

1. **Koordinat berbeda per device** — resolusi layar beda, koordinat harus disesuaikan. Cek dulu dengan `wm size`.

2. **`input text` gagal di non-ASCII** — karakter Indonesia/special chars gak bisa via `input text`. Pakai clipboard method:
   ```bash
   su -c "am broadcast -a clipper.set -e text 'teks Indonesia'"
   su -c "input keyevent 279"  # paste
   ```
   Butuh app Clipper terinstall.

3. **App butuh waktu load** — selalu `sleep` setelah buka app sebelum tap. Biasanya 2-3 detik cukup.

4. **SELinux bisa blokir** — kalau command gagal tanpa error jelas:
   ```bash
   su -c "getenforce"          # cek status
   su -c "setenforce 0"        # sementara permissive (waspadai security)
   ```

5. **Koordinat landscape vs portrait** — layar berubah orientasi = koordinat berubah. Pastikan orientasi benar sebelum tap.

6. **`su` minta permission** — pertama kali, HP akan popup minta izin root. Harus di-approve manual di HP.

7. **Battery drain** — automation loop yang terus jalan bisa makan baterai. Pakai interval yang wajar.

8. **Don't brick** — jangan edit `/system` file kecuali tau konsekuensinya. Selalu backup dulu.

## Keyevent Reference

| Code | Action |
|------|--------|
| 0 | KEYCODE_UNKNOWN |
| 1 | KEYCODE_MENU |
| 3 | KEYCODE_HOME |
| 4 | KEYCODE_BACK |
| 5 | KEYCODE_CALL |
| 6 | KEYCODE_ENDCALL |
| 24 | KEYCODE_VOLUME_UP |
| 25 | KEYCODE_VOLUME_DOWN |
| 26 | KEYCODE_POWER |
| 27 | KEYCODE_CAMERA |
| 66 | KEYCODE_ENTER |
| 67 | KEYCODE_DEL |
| 82 | KEYCODE_MENU |
| 111 | KEYCODE_ESCAPE |
| 164 | KEYCODE_MUTE |
| 187 | KEYCODE_APP_SWITCH |
| 220 | KEYCODE_BRIGHTNESS_DOWN |
| 221 | KEYCODE_BRIGHTNESS_UP |
| 223 | KEYCODE_SLEEP |
| 224 | KEYCODE_WAKEUP |
| 279 | KEYCODE_PASTE |
