#!/bin/bash
#Created by RajMohanAcharya
HEARTBEAT_FILE="/tmp/url_monitor_heartbeat"

if [ ! -f "$HEARTBEAT_FILE" ]; then
    echo "Heartbeat file $HEARTBEAT_FILE not found."
    exit 1
fi

last_timestamp=$(cat "$HEARTBEAT_FILE")
last_date=$(date -d "@$last_timestamp")

current_date=$(date)

echo "Last url_monitor.sh run time: $last_date"
echo "Current system time:         $current_date"