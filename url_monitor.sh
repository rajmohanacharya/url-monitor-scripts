#!/bin/bash
#Created by RajMohanAcharya

# Pre-requisite check: Postfix installed, running, and configured
POSTFIX_CONF="/etc/postfix/main.cf"

check_postfix() {
    # Check if postfix is installed
    if ! command -v postfix &>/dev/null; then
        echo "Postfix is not installed. Please install and configure Postfix before running this script."
        exit 1
    fi

    # Check if postfix service is running
    # Only try systemctl if available and systemd running
    if command -v systemctl &>/dev/null && pidof systemd &>/dev/null; then
        if ! systemctl is-active --quiet postfix; then
            echo "Postfix service is not running. Please start Postfix before running this script."
            exit 1
        fi
    else
        # Fallback: check postfix process directly
        if ! pgrep -x postfix > /dev/null; then
            echo "Postfix service does not appear to be running. Please start Postfix before running this script."
            exit 1
        fi
    fi

    # Check for basic SMTP parameters in configuration
    if [ ! -f "$POSTFIX_CONF" ]; then
        echo "Postfix config file ($POSTFIX_CONF) not found. Please configure Postfix."
        exit 1
    fi

    if ! grep -q '^mydomain' "$POSTFIX_CONF"; then
        echo "Postfix 'mydomain' parameter missing in config. Please set it in $POSTFIX_CONF."
        exit 1
    fi

    if ! grep -q '^relayhost' "$POSTFIX_CONF"; then
        echo "Postfix 'relayhost' parameter missing in config. Please set it in $POSTFIX_CONF."
        exit 1
    fi

    echo "Postfix installation and configuration checks passed."
}

check_postfix

# Interactive setup on first run - saves config for later runs
CONFIG_FILE="/etc/url_monitor_config.conf"
STATE_DIR="/tmp/url_monitor_states"
HEARTBEAT_FILE="/tmp/url_monitor_heartbeat"

mkdir -p "$STATE_DIR"

# Load existing config or run interactive setup
if [ ! -f "$CONFIG_FILE" ]; then
    echo "No config file detected. Running interactive setup..."

    # Read URLs interactively and save to config
    echo "Enter URLs to monitor (one per line). Enter an empty line to finish:"
    URLS=()
    while true; do
        read -p "URL: " url
        [[ -z "$url" ]] && break
        URLS+=("$url")
    done

    if [ "${#URLS[@]}" -eq 0 ]; then
        echo "No URLs entered. Exiting."
        exit 1
    fi

    # Read destination email IDs interactively and save to config
    echo "Enter destination email IDs for alerts (one per line). Enter an empty line to finish:"
    EMAILS=()
    while true; do
        read -p "Email ID: " email
        [[ -z "$email" ]] && break
        EMAILS+=("$email")
    done

    if [ "${#EMAILS[@]}" -eq 0 ]; then
        echo "No email IDs entered. Exiting."
        exit 1
    fi

    read -p "Enter Slack Webhook URL (leave empty to disable Slack alerts): " SLACK_WEBHOOK_URL

    # Save config to file
    {
        echo "EMAILS=("
        for e in "${EMAILS[@]}"; do
            echo "  \"$e\""
        done
        echo ")"
        echo "SLACK_WEBHOOK_URL=\"$SLACK_WEBHOOK_URL\""
        echo "URLS=("
        for u in "${URLS[@]}"; do
            echo "  \"$u\""
        done
        echo ")"
    } | sudo tee "$CONFIG_FILE" > /dev/null

    echo "Setup complete. Config saved to $CONFIG_FILE"
    exit 0
fi

# Source config file
source "$CONFIG_FILE"

LOG_FILE="/var/log/url_monitor.log"
MAX_SIZE=$((1024 * 1024 * 1024)) # 1GB
HOSTNAME=$(hostname)

send_slack_alert() {
    local message="$1"

    # If Slack webhook URL is empty or not set, skip sending Slack alert
    if [ -z "$SLACK_WEBHOOK_URL" ]; then
        return
    fi

    local escaped_message
    escaped_message=$(echo "$message" | sed 's/"/\\"/g')

    curl -s -X POST -H 'Content-type: application/json' \
        --data "{\"text\":\"$escaped_message\"}" "$SLACK_WEBHOOK_URL" > /dev/null
}

rotate_log() {
    if [ -f "$LOG_FILE" ]; then
        local size
        size=$(stat -c%s "$LOG_FILE")
        if [ "$size" -ge "$MAX_SIZE" ]; then
            mv "$LOG_FILE" "${LOG_FILE}_$(date +%Y%m%d%H%M%S)"
            gzip "${LOG_FILE}_"*
            touch "$LOG_FILE"
        fi
    fi
}

send_alert() {
    local url="$1"
    local cur_state="$2"
    local state_file="$3"

    local prev_state="UNKNOWN"
    [ -f "$state_file" ] && prev_state=$(cat "$state_file")

    if [ "$cur_state" != "$prev_state" ]; then
        local subject=""
        local body=""
        local from="URL Monitor Bash Script <donotreply>"

        if [ "$cur_state" == "DOWN" ]; then
            subject="URL: $url is Down"
            body="The monitored URL: $url is DOWN as of $(date). Please investigate."
        elif [ "$cur_state" == "UP" ] && [ "$prev_state" == "DOWN" ]; then
            subject="URL: $url is UP"
            body="The monitored URL: $url has recovered and is UP as of $(date)."
        fi

        if [ -n "$subject" ]; then
            # Send email alert to all configured recipients
            for recipient in "${EMAILS[@]}"; do
                echo -e "From: \"$from\"\nTo: $recipient\nSubject: $subject\n\n$body" | sendmail -t
            done

            # Slack alert (skips if webhook not set)
            send_slack_alert "$subject - $body"
        fi
    fi
    echo "$cur_state" > "$state_file"
}

monitor_urls() {
    rotate_log

    for url in "${URLS[@]}"; do
        local state_file="$STATE_DIR/$(echo -n "$url" | md5sum | cut -d' ' -f1).state"
        local status_code
        status_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$url")
        local cur_state

        if [[ "$status_code" =~ ^(2|3)[0-9][0-9]$ ]]; then
            cur_state="UP"
        else
            cur_state="DOWN"
            echo "$(date '+%Y-%m-%d %H:%M:%S') [$cur_state] $url status: $status_code" >> "$LOG_FILE"
        fi

        send_alert "$url" "$cur_state" "$state_file"
    done

    date +%s > "$HEARTBEAT_FILE"
}

monitor_urls