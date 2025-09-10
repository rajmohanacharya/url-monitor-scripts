#!/bin/bash
# Created by RajMohanAcharya

CONFIG_FILE="/etc/url_monitor_config.conf"
SERVICE_NAME="url_monitor.service"
TIMER_NAME="url_monitor.timer"
SERVICE_PATH="/etc/systemd/system/$SERVICE_NAME"
TIMER_PATH="/etc/systemd/system/$TIMER_NAME"
LOG_FILE="/var/log/url_monitor.log"
STATE_DIR="/tmp/url_monitor_states"
HEARTBEAT_FILE="/tmp/url_monitor_heartbeat"
MONITOR_SCRIPT="/usr/local/bin/url_monitor.sh"

pause_monitor() {
    echo "Pausing URL monitor (systemd stop)..."
    sudo systemctl stop "$SERVICE_NAME"
    echo "Monitor paused."
}

resume_monitor() {
    echo "Resuming URL monitor (systemd start)..."
    sudo systemctl start "$SERVICE_NAME"
    echo "Monitor resumed."
}

print_config() {
    echo "----- Current Configuration -----"
    if [ -f "$CONFIG_FILE" ]; then
        cat "$CONFIG_FILE"
    else
        echo "No configuration file found."
    fi
    echo "--------------------------------"
}

add_url() {
    read -p "Enter URL to add: " new_url
    if grep -q "\"$new_url\"" "$CONFIG_FILE"; then
        echo "URL already exists in config."
    else
        sudo sed -i "/^URLS=(/a \ \"$new_url\"" "$CONFIG_FILE"
        echo "URL added."
    fi
}

remove_url() {
    read -p "Enter URL to remove: " rem_url
    sudo sed -i "/\"$rem_url\"/d" "$CONFIG_FILE"
    echo "URL removed (if it existed)."
}

add_email() {
    read -p "Enter Email to add: " new_email
    if grep -q "\"$new_email\"" "$CONFIG_FILE"; then
        echo "Email already exists in config."
    else
        sudo sed -i "/^EMAILS=(/a \ \"$new_email\"" "$CONFIG_FILE"
        echo "Email added."
    fi
}

remove_email() {
    read -p "Enter Email to remove: " rem_email
    sudo sed -i "/\"$rem_email\"/d" "$CONFIG_FILE"
    echo "Email removed (if it existed)."
}

set_slack_webhook() {
    read -p "Enter new Slack Webhook URL (leave blank to unset): " new_slack
    sudo sed -i "/^SLACK_WEBHOOK_URL=/d" "$CONFIG_FILE"
    echo "SLACK_WEBHOOK_URL=\"$new_slack\"" | sudo tee -a "$CONFIG_FILE" > /dev/null
    echo "Slack webhook updated."
}

change_failure_threshold() {
    echo "Current FAILURE_THRESHOLD value:"
    current_threshold=$(grep '^FAILURE_THRESHOLD=' "$CONFIG_FILE" | cut -d'=' -f2)
    echo "  $current_threshold"
    while true; do
        read -p "Enter new number of consecutive failures before triggering alert (1-10): " new_threshold
        if [[ "$new_threshold" =~ ^[0-9]+$ ]] && [ "$new_threshold" -ge 1 ] && [ "$new_threshold" -le 10 ]; then
            sudo sed -i "s/^FAILURE_THRESHOLD=.*/FAILURE_THRESHOLD=$new_threshold/" "$CONFIG_FILE"
            echo "FAILURE_THRESHOLD updated to $new_threshold"
            break
        else
            echo "Invalid input. Please enter an integer between 1 and 10."
        fi
    done
}

uninstall_monitor() {
    echo "Uninstalling URL Monitor..."

    # Stop and disable the timer and service
    sudo systemctl stop "$SERVICE_NAME" "$TIMER_NAME"
    sudo systemctl disable "$SERVICE_NAME" "$TIMER_NAME"

    # Remove systemd unit files
    if [ -f "$SERVICE_PATH" ]; then
        sudo rm -f "$SERVICE_PATH"
        echo "Removed $SERVICE_PATH"
    fi
    if [ -f "$TIMER_PATH" ]; then
        sudo rm -f "$TIMER_PATH"
        echo "Removed $TIMER_PATH"
    fi

    # Reload systemd daemons
    sudo systemctl daemon-reload

    # Remove configuration file
    if [ -f "$CONFIG_FILE" ]; then
        sudo rm -f "$CONFIG_FILE"
        echo "Removed $CONFIG_FILE"
    fi

    # Remove log and state files
    if [ -f "$LOG_FILE" ]; then
        sudo rm -f "$LOG_FILE"
        echo "Removed $LOG_FILE"
    fi

    if [ -d "$STATE_DIR" ]; then
        sudo rm -rf "$STATE_DIR"
        echo "Removed $STATE_DIR"
    fi

    if [ -f "$HEARTBEAT_FILE" ]; then
        sudo rm -f "$HEARTBEAT_FILE"
        echo "Removed $HEARTBEAT_FILE"
    fi

    # Remove main monitor script
    if [ -f "$MONITOR_SCRIPT" ]; then
        sudo rm -f "$MONITOR_SCRIPT"
        echo "Removed $MONITOR_SCRIPT"
    fi

    echo "Uninstall complete. URL Monitor has been removed from this system."
}

while true; do
    echo
    echo "---- URL Monitor Admin ----"
    echo "1. Pause main monitor script"
    echo "2. Resume main monitor script"
    echo "3. Add monitored URL"
    echo "4. Remove monitored URL"
    echo "5. Add alert Email"
    echo "6. Remove alert Email"
    echo "7. Set Slack Webhook URL"
    echo "8. Change consecutive failure alert threshold"
    echo "9. Show configuration"
    echo "10. Uninstall monitor (remove service, timer, config, logs)"
    echo "11. Exit"
    read -p "Select an action [1-11]: " choice

    case $choice in
        1) pause_monitor ;;
        2) resume_monitor ;;
        3) add_url ;;
        4) remove_url ;;
        5) add_email ;;
        6) remove_email ;;
        7) set_slack_webhook ;;
        8) change_failure_threshold ;;
        9) print_config ;;
        10) uninstall_monitor ;;
        11) echo "Exiting admin tool."; exit 0 ;;
        *) echo "Invalid choice. Try again." ;;
    esac
done
