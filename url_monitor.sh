#!/bin/bash

# Created by RajMohanAcharya - Enhanced with consecutive failure alert logic
# Store this file under /usr/local/bin and then run setup_url_monitor.sh

POSTFIX_CONF="/etc/postfix/main.cf"

# Check postfix installed and running (unchanged)
check_postfix() {
  if ! command -v postfix &>/dev/null; then
    echo "Postfix is not installed. Please install and configure Postfix before running this script."
    exit 1
  fi
  if command -v systemctl &>/dev/null && pidof systemd &>/dev/null; then
    if ! systemctl is-active --quiet postfix; then
      echo "Postfix service is not running. Please start Postfix before running this script."
      exit 1
    fi
  else
    if ! pgrep -x postfix > /dev/null; then
      echo "Postfix service does not appear to be running. Please start Postfix before running this script."
      exit 1
    fi
  fi
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

CONFIG_FILE="/etc/url_monitor_config.conf"
STATE_DIR="/tmp/url_monitor_states"
HEARTBEAT_FILE="/tmp/url_monitor_heartbeat"
mkdir -p "$STATE_DIR"

# Interactive setup on first run or if config missing
if [ ! -f "$CONFIG_FILE" ]; then
  echo "No config file detected. Running interactive setup..."

  # URLs input
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

  # Emails input
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

  # Slack webhook input
  read -p "Enter Slack Webhook URL (leave empty to disable Slack alerts): " SLACK_WEBHOOK_URL

  # Alert threshold input (1-10, default 5)
  while true; do
    read -p "Enter number of consecutive failures before triggering alert (1-10, default 5): " input_threshold
    if [[ -z "$input_threshold" ]]; then
      FAILURE_THRESHOLD=5
      break
    elif [[ "$input_threshold" =~ ^[0-9]+$ ]] && [ "$input_threshold" -ge 1 ] && [ "$input_threshold" -le 10 ]; then
      FAILURE_THRESHOLD=$input_threshold
      break
    else
      echo "Invalid input. Please enter an integer between 1 and 10, or press Enter for default 5."
    fi
  done

  # Save config to file
  {
    echo "EMAILS=("
    for e in "${EMAILS[@]}"; do
      echo " \"$e\""
    done
    echo ")"
    echo "SLACK_WEBHOOK_URL=\"$SLACK_WEBHOOK_URL\""
    echo "URLS=("
    for u in "${URLS[@]}"; do
      echo " \"$u\""
    done
    echo ")"
    echo "FAILURE_THRESHOLD=$FAILURE_THRESHOLD"
  } | sudo tee "$CONFIG_FILE" > /dev/null

  echo "Setup complete. Config saved to $CONFIG_FILE"
  exit 0
fi

source "$CONFIG_FILE"

LOG_FILE="/var/log/url_monitor.log"
MAX_SIZE=$((1024 * 1024 * 1024)) # 1GB
HOSTNAME=$(hostname)

send_slack_alert() {
  local message="$1"
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
    size=$(stat -c %s "$LOG_FILE")
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
  local fail_count="$4"
  local prev_state="UNKNOWN"

  [ -f "$state_file" ] && prev_state=$(cat "$state_file")

  if [ "$cur_state" == "DOWN" ]; then
    if [ "$fail_count" -eq "$FAILURE_THRESHOLD" ]; then
      local subject="URL: $url is Down"
      local body="The monitored URL: $url is DOWN for $fail_count consecutive checks as of $(date). Please investigate."
    else
      return
    fi
  elif [ "$cur_state" == "UP" ] && [ "$prev_state" == "DOWN" ]; then
    local subject="URL: $url is UP"
    local body="The monitored URL: $url has recovered and is UP as of $(date)."
    # Reset fail_count on recovery
    local fail_count_file="$STATE_DIR/$(echo -n "$url" | md5sum | cut -d' ' -f1).failcount"
    echo "0" > "$fail_count_file"
  else
    # No alert for other cases
    return
  fi

  if [ -n "$subject" ]; then
    local from="URL Monitor Bash Script <donotreply>"
    for recipient in "${EMAILS[@]}"; do
      echo -e "From: \"URL Monitor Bash Script\" <donotreply>\nTo: $recipient\nSubject: $subject\n\n$body" | sendmail -f donotreply -t
    done
    send_slack_alert "$subject - $body"
  fi

  echo "$cur_state" > "$state_file"
}

monitor_urls() {
  rotate_log
  for url in "${URLS[@]}"; do
    local state_file="$STATE_DIR/$(echo -n "$url" | md5sum | cut -d' ' -f1).state"
    local fail_count_file="$STATE_DIR/$(echo -n "$url" | md5sum | cut -d' ' -f1).failcount"

    local status_code
    status_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$url")
    local cur_state

    if [[ "$status_code" =~ ^(2|3)[0-9][0-9]$ ]]; then
      cur_state="UP"
    else
      cur_state="DOWN"
      echo "$(date '+%Y-%m-%d %H:%M:%S') [$cur_state] $url status: $status_code" >> "$LOG_FILE"
    fi

    # Read failure count or initialize
    local fail_count=0
    if [ -f "$fail_count_file" ]; then
      fail_count=$(cat "$fail_count_file")
    fi

    if [ "$cur_state" == "DOWN" ]; then
      fail_count=$((fail_count + 1))
      echo "$fail_count" > "$fail_count_file"
    else
      fail_count=0
      echo "0" > "$fail_count_file"
    fi

    send_alert "$url" "$cur_state" "$state_file" "$fail_count"
  done
  date +%s > "$HEARTBEAT_FILE"
}

monitor_urls
