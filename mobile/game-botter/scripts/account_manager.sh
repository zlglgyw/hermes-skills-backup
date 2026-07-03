#!/data/data/com.termux/files/usr/bin/bash
# Multi-Account Manager untuk Game Botter
# Usage: bash account_manager.sh [action] [args]
# Actions: list, create, switch, install-app, status

ACTION=${1:-list}
GAME_PKG=${2:-""}

log() { echo "[$(date '+%H:%M:%S')] $1"; }

case "$ACTION" in
    list)
        log "=== Users/Profiles ==="
        su -c "pm list users"
        ;;
    
    create)
        NAME=${2:-"Farm_$(date +%s)"}
        log "Creating user: $NAME"
        su -c "pm create-user '$NAME'"
        log "Done. Cek 'list' untuk lihat ID."
        ;;
    
    switch)
        USER_ID=$2
        if [ -z "$USER_ID" ]; then
            echo "Usage: account_manager.sh switch <user_id>"
            exit 1
        fi
        log "Switching to user $USER_ID"
        su -c "am switch-user $USER_ID"
        sleep 5
        log "Switched."
        ;;
    
    install-app)
        USER_ID=$2
        PKG=$3
        if [ -z "$USER_ID" ] || [ -z "$PKG" ]; then
            echo "Usage: account_manager.sh install-app <user_id> <package>"
            exit 1
        fi
        log "Installing $PKG for user $USER_ID"
        su -c "pm install-existing --user $USER_ID $PKG"
        ;;
    
    remove)
        USER_ID=$2
        if [ -z "$USER_ID" ]; then
            echo "Usage: account_manager.sh remove <user_id>"
            echo "⚠️  JANGAN hapus user 0 (main)!"
            exit 1
        fi
        if [ "$USER_ID" = "0" ]; then
            echo "❌ Tidak bisa hapus user 0 (main)!"
            exit 1
        fi
        log "Removing user $USER_ID"
        su -c "pm remove-user $USER_ID"
        ;;
    
    status)
        log "=== Device Status ==="
        log "Battery: $(su -c 'dumpsys battery' | grep level | awk '{print $2}')%"
        log "RAM: $(su -c 'cat /proc/meminfo' | grep MemAvailable | awk '{print $2}')kB free"
        log "Storage: $(su -c 'df /data' | tail -1 | awk '{print $4}') free"
        log "Temp: $(su -c 'cat /sys/class/thermal/thermal_zone0/temp' 2>/dev/null | awk '{print $1/1000"°C"}')"
        log "Current user: $(su -c 'am get-current-user')"
        ;;
    
    *)
        echo "Actions: list, create, switch, install-app, remove, status"
        ;;
esac
