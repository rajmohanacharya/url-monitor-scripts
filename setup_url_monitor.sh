#!/bin/bash
#Created by RajMohanAcharya

SCRIPT_PATH="/usr/local/bin/url_monitor.sh"
SERVICE_PATH="/etc/systemd/system/url_monitor.service"
TIMER_PATH="/etc/systemd/system/url_monitor.timer"

if [ ! -f "$SCRIPT_PATH" ]; then
    echo "Error: $SCRIPT_PATH not found. Please ensure url_monitor.sh is saved there."
    exit 1
fi

# Prompt user for interval in minutes
while true; do
    read -p "Enter how often to run the url_monitor script (in minutes, min 2 max 60): " INTERVAL_MIN

    # Check if integer and in the allowed range
    if [[ "$INTERVAL_MIN" =~ ^[0-9]+$ ]] && [ "$INTERVAL_MIN" -ge 2 ] && [ "$INTERVAL_MIN" -le 60 ]; then
        break
    else
        echo "Invalid input. Please enter an integer between 2 and 60."
    fi
done

INTERVAL_SEC=$(( INTERVAL_MIN * 60 ))

# Create systemd service file
sudo tee "$SERVICE_PATH" > /dev/null <<EOF
[Unit]
Description=URL Monitoring Script Service

[Service]
Type=oneshot
ExecStart=$SCRIPT_PATH
EOF

# Create systemd timer file with user-defined interval
sudo tee "$TIMER_PATH" > /dev/null <<EOF
[Unit]
Description=Run URL monitor every $INTERVAL_MIN minute(s)

[Timer]
OnBootSec=$INTERVAL_SEC
OnUnitActiveSec=$INTERVAL_SEC
AccuracySec=1sec
Unit=url_monitor.service

[Install]
WantedBy=timers.target
EOF

# Reload systemd and enable/start timer
sudo systemctl daemon-reload
sudo systemctl enable --now url_monitor.timer

echo "Systemd service and timer installed and started."
echo "Timer interval set to every $INTERVAL_MIN minute(s)."

echo "Running the URL monitor script once for initial configuration..."
sudo bash "$SCRIPT_PATH"

echo "Setup complete. Subsequent runs will be automatic every $INTERVAL_MIN minute(s)."

