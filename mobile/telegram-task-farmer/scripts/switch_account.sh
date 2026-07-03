#!/data/data/com.termux/files/usr/bin/bash
# Account Switcher Helper
# Usage: bash switch_account.sh [list|switch|create|remove|setup-telegram]

ACTION=${1:-list}
USER_ID=${2:-""}

log() { echo "[$(date '+%H:%M:%S')] $1"; }

case "$ACTION" in
    list)
        log "=== Android Users ==="
        su -c "pm list users"
        log ""
        log "=== Telegram Installed? ==="
        su -c "pm list packages" | grep -i telegram
        ;;
    
    switch)
        if [ -z "$USER_ID" ]; then
            echo "Usage: switch_account.sh switch <user_id>"
            exit 1
        fi
        log "Switching to user $USER_ID..."
        su -c "am switch-user $USER_ID"
        sleep 5
        log "Switched. Current: $(su -c 'am get-current-user')"
        ;;
    
    create)
        NAME=${2:-"farm_$(date +%s)"}
        log "Creating user: $NAME"
        su -c "pm create-user '$NAME'"
        log "Done. Run 'list' to see user ID."
        ;;
    
    remove)
        if [ -z "$USER_ID" ] || [ "$USER_ID" = "0" ]; then
            echo "Cannot remove user 0 (main). Usage: switch_account.sh remove <user_id>"
            exit 1
        fi
        log "Removing user $USER_ID..."
        su -c "pm remove-user $USER_ID"
        log "Removed."
        ;;
    
    setup-telegram)
        if [ -z "$USER_ID" ]; then
            echo "Usage: switch_account.sh setup-telegram <user_id>"
            exit 1
        fi
        log "Installing Telegram for user $USER_ID..."
        su -c "pm install-existing --user $USER_ID org.telegram.messenger"
        log "Done. Switch to user $USER_ID and login."
        ;;
    
    setup-all)
        log "Setting up Telegram for all non-main users..."
        for uid in $(su -c "pm list users" | grep -oP 'UserInfo\{\K\d+'); do
            if [ "$uid" != "0" ]; then
                log "  → user $uid"
                su -c "pm install-existing --user $uid org.telegram.messenger"
            fi
        done
        log "Done."
        ;;
    
    *)
        echo "Actions: list, switch, create, remove, setup-telegram, setup-all"
        ;;
esac
