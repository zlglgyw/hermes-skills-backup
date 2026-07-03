#!/data/data/com.termux/files/usr/bin/bash
# Game Botter Automation Loop
# Usage: bash bot_loop.sh [duration_minutes] [cooldown_minutes]
# Default: run 30 min, cooldown 5 min

DURATION=${1:-30}
COOLDOWN=${2:-5}
SCREENSHOT="/sdcard/bot_screen.png"
LOCAL_SCREEN="$HOME/bot_screen.png"
LOGFILE="$HOME/bot_log.txt"
INTERVAL_MIN=3
INTERVAL_MAX=8

log() { echo "[$(date '+%H:%M:%S')] $1" | tee -a "$LOGFILE"; }

random_sleep() {
    local base=$((RANDOM % (INTERVAL_MAX - INTERVAL_MIN + 1) + INTERVAL_MIN))
    local jitter=$((RANDOM % 3))
    sleep $((base + jitter))
}

random_tap() {
    local x=$1 y=$2
    local ox=$((RANDOM % 21 - 10))
    local oy=$((RANDOM % 21 - 10))
    su -c "input tap $((x + ox)) $((y + oy))"
}

take_screenshot() {
    su -c "screencap -p $SCREENSHOT"
    cp "$SCREENSHOT" "$LOCAL_SCREEN"
}

# Matikan screen timeout
su -c "settings put system screen_off_timeout 2147483647"
log "=== BOT STARTED (durasi: ${DURATION}m, cooldown: ${COOLDOWN}m) ==="

START=$(date +%s)
CYCLE=0

while true; do
    NOW=$(date +%s)
    ELAPSED=$(( (NOW - START) / 60 ))
    
    if [ "$ELAPSED" -ge "$DURATION" ]; then
        log "=== COOLDOWN ${COOLDOWN}m ==="
        sleep $((COOLDOWN * 60))
        START=$(date +%s)
        log "=== RESUMED ==="
    fi
    
    CYCLE=$((CYCLE + 1))
    log "Cycle #$CYCLE"
    
    take_screenshot
    log "Screenshot saved → $LOCAL_SCREEN"
    
    # Di sini AI akan analyze screenshot dan decide action
    # Manual mode: uncomment dan edit koordinat
    # random_tap 540 1200
    # sleep 1
    # random_tap 540 800
    
    random_sleep
done
