#!/data/data/com.termux/files/usr/bin/bash
# Telegram Task Farmer — Main Script
# Usage: bash farm.sh [mode]
#   mode: main = akun utama saja | all = rotate semua akun
# Config: ~/.hermes/skills/mobile/telegram-task-farmer/templates/config.json

SKILL_DIR="$(dirname "$(realpath "$0")")/.."
CONFIG="$SKILL_DIR/templates/config.json"
SCREENSHOT="/sdcard/tg_farm_screen.png"
LOGFILE="$HOME/tg_farm_log.txt"
mkdir -p /sdcard/tg_farm

MODE=${1:-all}
TASK_COUNT=0

log() { echo "[$(date '+%H:%M:%S')] $1" | tee -a "$LOGFILE"; }

random_delay() {
    local min=$1 max=$2
    local delay=$((RANDOM % (max - min + 1) + min))
    log "delay ${delay}s..."
    sleep "$delay"
}

random_tap() {
    local x=$1 y=$2
    local ox=$((RANDOM % 21 - 10))
    local oy=$((RANDOM % 21 - 10))
    su -c "input tap $((x + ox)) $((y + oy))"
}

screenshot() {
    su -c "screencap -p $SCREENSHOT"
    cp "$SCREENSHOT" "$HOME/tg_farm_screen.png"
}

open_telegram() {
    su -c "am start -n org.telegram.messenger/.DefaultAlias"
    sleep 3
}

back() {
    su -c "input keyevent 4"
    sleep 1
}

# === PRE-FLIGHT ===
su -c "settings put system screen_off_timeout 2147483647"
su -c "svc wifi enable"
log "=== TG TASK FARM STARTED (mode: $MODE) ==="

# === MAIN LOOP ===
if [ "$MODE" = "main" ]; then
    # Single account mode
    open_telegram
    log "Opened Telegram (main account)"
    log "AI should now: screenshot → analyze → tap tasks → submit"
    log "Run hermes with telegram-task-farmer skill for AI-driven farming"
    screenshot
    log "Screenshot saved → ~/tg_farm_screen.png"
else
    # Multi-account mode
    log "Multi-account mode — accounts listed in config.json"
    log "For each account: switch user → open Telegram → farm tasks → next"
    log "Run hermes with telegram-task-farmer skill for AI-driven farming"
    
    # Parse accounts from config
    for user_id in $(cat "$CONFIG" | python3 -c "
import sys, json
cfg = json.load(sys.stdin)
for a in cfg.get('accounts', []):
    print(a['user_id'])
"); do
        log "=== Switching to user $user_id ==="
        su -c "am switch-user $user_id"
        sleep 5
        
        open_telegram
        screenshot
        log "Screenshot saved → ~/tg_farm_screen.png"
        
        log "AI should farm tasks now for user $user_id"
        random_delay 30 60
    done
fi

log "=== FARM LOOP COMPLETE ==="
